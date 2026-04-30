unit PGofer.Scheduler.Controls;

interface

uses
  System.SysUtils, System.Classes, System.Win.ComObj, System.Masks, System.IOUtils,
  Winapi.ActiveX, Winapi.Windows, System.Variants;

function SchedulerGetLastErrorMessage: string;
function SchedulerResolveMask(const AMachine, AMask: string): TArray<string>;
function SchedulerRun(const AMachine, ATaskPath: string): Boolean;
function SchedulerStop(const AMachine, ATaskPath: string): Boolean;
function SchedulerSetConfig(const AMachine, ATaskPath: string; const AEnabled: Boolean): Boolean;
function SchedulerDelete(const AMachine, ATaskPath: string): Boolean;
function SchedulerGetConfig(const AMachine, ATaskPath: string): Integer;
function SchedulerGetLastResult(const AMachine, ATaskPath: string): Integer;
function SchedulerRegisterXML(const AMachine, ATaskPath, AXMLContent: string): Boolean;

implementation

threadvar
  _LastSchedulerErrorCode: DWORD;

function SchedulerGetLastErrorMessage: string;
begin
  if _LastSchedulerErrorCode = 0 then
    Result := ''
  else
    Result := SysErrorMessage(_LastSchedulerErrorCode);
end;

function GetTaskService(const AMachine: string): OleVariant;
begin
  Result := CreateOleObject('Schedule.Service');
  if AMachine <> '' then
    Result.Connect(AMachine, EmptyParam, EmptyParam, EmptyParam)
  else
    Result.Connect();
end;

procedure EnumerateTasks(const Folder: OleVariant; const AMask: string; var List: TArray<string>);
var
  Tasks, SubFolders, CurrentTask: OleVariant;
  I: Integer;
  TPath, UMask, UPath, TName: string;
begin
  UMask := UpperCase(AMask);
  if (UMask <> '*') and (not UMask.StartsWith('\')) and (not UMask.StartsWith('*')) then
    UMask := '*' + UMask;

  try
    Tasks := Folder.GetTasks(1);
    for I := 1 to Tasks.Count do
    begin
      try
        CurrentTask := Tasks.Item[I];
        TPath := CurrentTask.Path;
        TName := CurrentTask.Name;
        UPath := UpperCase(TPath);

        if (UMask = '*') or MatchesMask(UPath, UMask) or MatchesMask(UpperCase(TName), UMask) then
        begin
          SetLength(List, Length(List) + 1);
          List[High(List)] := TPath;
        end;
      except
        continue;
      end;
    end;
  except
  end;

  try
    SubFolders := Folder.GetFolders(0);
    for I := 1 to SubFolders.Count do
    begin
      try
        EnumerateTasks(SubFolders.Item[I], AMask, List);
      except
        continue;
      end;
    end;
  except
  end;
end;

function SchedulerResolveMask(const AMachine, AMask: string): TArray<string>;
var
  Service, RootFolder: OleVariant;
  ComInit: HRESULT;
begin
  SetLength(Result, 0);
  _LastSchedulerErrorCode := 0;
  ComInit := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    try
      Service := GetTaskService(AMachine);
      RootFolder := Service.GetFolder('\');
      EnumerateTasks(RootFolder, AMask, Result);
    except
      on E: Exception do _LastSchedulerErrorCode := ERROR_SERVICE_NOT_ACTIVE;
    end;
  finally
    if Succeeded(ComInit) then CoUninitialize;
  end;
end;

function SchedulerRun(const AMachine, ATaskPath: string): Boolean;
var
  Service: OleVariant;
  ComInit: HRESULT;
begin
  Result := False;
  _LastSchedulerErrorCode := 0;
  ComInit := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    try
      Service := GetTaskService(AMachine);
      Service.GetFolder('\').GetTask(ATaskPath).Run(0);
      Result := True;
    except
      on E: EOleException do _LastSchedulerErrorCode := Cardinal(E.ErrorCode);
      on E: Exception do _LastSchedulerErrorCode := ERROR_SERVICE_SPECIFIC_ERROR;
    end;
  finally
    if Succeeded(ComInit) then CoUninitialize;
  end;
end;

function SchedulerStop(const AMachine, ATaskPath: string): Boolean;
var
  Service: OleVariant;
  ComInit: HRESULT;
begin
  Result := False;
  _LastSchedulerErrorCode := 0;
  ComInit := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    try
      Service := GetTaskService(AMachine);
      Service.GetFolder('\').GetTask(ATaskPath).Stop(0);
      Result := True;
    except
      on E: EOleException do _LastSchedulerErrorCode := Cardinal(E.ErrorCode);
      on E: Exception do _LastSchedulerErrorCode := ERROR_SERVICE_SPECIFIC_ERROR;
    end;
  finally
    if Succeeded(ComInit) then CoUninitialize;
  end;
end;

function SchedulerSetConfig(const AMachine, ATaskPath: string; const AEnabled: Boolean): Boolean;
var
  Service: OleVariant;
  ComInit: HRESULT;
begin
  Result := False;
  _LastSchedulerErrorCode := 0;
  ComInit := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    try
      Service := GetTaskService(AMachine);
      Service.GetFolder('\').GetTask(ATaskPath).Enabled := AEnabled;
      Result := True;
    except
      on E: EOleException do _LastSchedulerErrorCode := Cardinal(E.ErrorCode);
      on E: Exception do _LastSchedulerErrorCode := ERROR_SERVICE_SPECIFIC_ERROR;
    end;
  finally
    if Succeeded(ComInit) then CoUninitialize;
  end;
end;

function SchedulerDelete(const AMachine, ATaskPath: string): Boolean;
var
  Service: OleVariant;
  Path, Name: string;
  LPos: Integer;
  ComInit: HRESULT;
begin
  Result := False;
  _LastSchedulerErrorCode := 0;
  ComInit := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    try
      Service := GetTaskService(AMachine);
      LPos := LastDelimiter('\', ATaskPath);
      if LPos > 0 then
      begin
        Path := Copy(ATaskPath, 1, LPos - 1);
        Name := Copy(ATaskPath, LPos + 1, MaxInt);
        if Path = '' then Path := '\';
        Service.GetFolder(Path).DeleteTask(Name, 0);
      end
      else
        Service.GetFolder('\').DeleteTask(ATaskPath, 0);
      Result := True;
    except
      on E: EOleException do _LastSchedulerErrorCode := Cardinal(E.ErrorCode);
      on E: Exception do _LastSchedulerErrorCode := ERROR_SERVICE_SPECIFIC_ERROR;
    end;
  finally
    if Succeeded(ComInit) then CoUninitialize;
  end;
end;

function SchedulerGetConfig(const AMachine, ATaskPath: string): Integer;
var
  ComInit: HRESULT;
begin
  Result := -1;
  ComInit := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    try
      Result := GetTaskService(AMachine).GetFolder('\').GetTask(ATaskPath).State;
    except
    end;
  finally
    if Succeeded(ComInit) then CoUninitialize;
  end;
end;

function SchedulerGetLastResult(const AMachine, ATaskPath: string): Integer;
var
  ComInit: HRESULT;
begin
  Result := -1;
  ComInit := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    try
      Result := GetTaskService(AMachine).GetFolder('\').GetTask(ATaskPath).LastTaskResult;
    except
    end;
  finally
    if Succeeded(ComInit) then CoUninitialize;
  end;
end;

function SchedulerRegisterXML(const AMachine, ATaskPath, AXMLContent: string): Boolean;
var
  Service, RootFolder: OleVariant;
  ComInit: HRESULT;
const
  TASK_CREATE_OR_UPDATE = 6;
  TASK_LOGON_NONE = 0;
begin
  Result := False;
  _LastSchedulerErrorCode := 0;
  ComInit := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    try
      Service := GetTaskService(AMachine);
      RootFolder := Service.GetFolder('\');
      RootFolder.RegisterTaskXML(ATaskPath, AXMLContent, TASK_CREATE_OR_UPDATE,
        EmptyParam, EmptyParam, TASK_LOGON_NONE);
      Result := True;
    except
      on E: EOleException do _LastSchedulerErrorCode := Cardinal(E.ErrorCode);
      on E: Exception do _LastSchedulerErrorCode := ERROR_SERVICE_SPECIFIC_ERROR;
    end;
  finally
    if Succeeded(ComInit) then CoUninitialize;
  end;
end;

end.
