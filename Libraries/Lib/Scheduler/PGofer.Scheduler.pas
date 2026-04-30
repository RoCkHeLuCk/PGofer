unit PGofer.Scheduler;

interface

uses
  System.SysUtils, System.Rtti, System.IOUtils, PGofer.Core, PGofer.Classes, PGofer.Runtime;

type
  {$M+}
  [TPGAboutAttribute('Windows Task Scheduler Management')]
  [TPGAboutAttribute('Controls scheduled tasks locally or remotely.')]
  TPGScheduler = class( TPGItemClass )
  private
    FMachineName: string;
    procedure CheckResult(ASuccess: Boolean; const ATask: string);
  public
    constructor Create( AItemDad: TPGItem; const AName: string = '' ); override;
  published
    [TPGAboutAttribute('Target Computer Name or IP Address.')]
    property MachineName: string read FMachineName write FMachineName;

    [TPGAboutAttribute('Runs tasks matching the mask. Returns True if all succeed.')]
    function Run(const ATaskMask: string): Boolean;

    [TPGAboutAttribute('Stops tasks matching the mask.')]
    function Stop(const ATaskMask: string): Boolean;

    [TPGAboutAttribute('Deletes tasks matching the mask.')]
    function Delete(const ATaskMask: string): Boolean;

    [TPGAboutAttribute('Enables or disables tasks. AEnabled: 1=Enable, 0=Disable.')]
    function SetConfig(const ATaskMask: string; const AEnabled: Byte): Boolean;

    [TPGAboutAttribute('Gets the state of tasks. 1=Disabled, 3=Ready, 4=Running.')]
    function GetConfig(const ATaskMask: string): TValue;

    [TPGAboutAttribute('Returns True if the task exists in the system.')]
    function Exists(const ATaskPath: string): Boolean;

    [TPGAboutAttribute('Gets the last exit code (HRESULT) of the task.')]
    function GetLastResult(const ATaskMask: string): TValue;

    [TPGAboutAttribute('Registers a task using a Raw XML string.')]
    function RegisterXML(const ATaskPath, AFileName: string): Boolean;
  end;
  {$TYPEINFO ON}

var
  PGScheduler: TPGScheduler;

implementation

uses
  PGofer.Scheduler.Controls;

{ TPGScheduler }

constructor TPGScheduler.Create(AItemDad: TPGItem; const AName: string);
begin
  inherited Create(AItemDad, AName);
  FMachineName := '';
end;

procedure TPGScheduler.CheckResult(ASuccess: Boolean; const ATask: string);
var
  LError: string;
begin
  if not ASuccess then
  begin
    LError := SchedulerGetLastErrorMessage;
    if LError <> '' then
      TPGKernel.Console('Error Scheduler: Failed on [%s] - %s', [ATask, LError]);
  end;
end;

function TPGScheduler.Run(const ATaskMask: string): Boolean;
var
  Lista: TArray<string>;
  Tarefa: string;
begin
  Result := True;
  Lista := SchedulerResolveMask(FMachineName, ATaskMask);
  if Length(Lista) = 0 then Exit(False);

  for Tarefa in Lista do
    if not SchedulerRun(FMachineName, Tarefa) then
    begin
      Result := False;
      CheckResult(Result, Tarefa);
    end;
end;

function TPGScheduler.Stop(const ATaskMask: string): Boolean;
var
  Lista: TArray<string>;
  Tarefa: string;
  Res: Boolean;
begin
  Result := True;
  Lista := SchedulerResolveMask(FMachineName, ATaskMask);
  if Length(Lista) = 0 then Exit(False);

  for Tarefa in Lista do
  begin
    Res := SchedulerStop(FMachineName, Tarefa);
    CheckResult(Res, Tarefa);
    if not Res then Result := False;
  end;
end;

function TPGScheduler.SetConfig(const ATaskMask: string; const AEnabled: Byte): Boolean;
var
  Lista: TArray<string>;
  Tarefa: string;
  Res: Boolean;
begin
  Result := True;
  Lista := SchedulerResolveMask(FMachineName, ATaskMask);

  // NOVO: Feedback se a máscara foi inútil
  if Length(Lista) = 0 then
  begin
    TPGKernel.Console('Scheduler Warning: No tasks found matching mask [' + ATaskMask + ']');
    Exit(False);
  end;

  for Tarefa in Lista do
  begin
    Res := SchedulerSetConfig(FMachineName, Tarefa, AEnabled = 1);
    CheckResult(Res, Tarefa);
    if not Res then Result := False;
  end;
end;

function TPGScheduler.Delete(const ATaskMask: string): Boolean;
var
  Lista: TArray<string>;
  Tarefa: string;
  Res: Boolean;
begin
  Result := True;
  Lista := SchedulerResolveMask(FMachineName, ATaskMask);
  for Tarefa in Lista do
  begin
    Res := SchedulerDelete(FMachineName, Tarefa);
    CheckResult(Res, Tarefa);
    if not Res then Result := False;
  end;
end;

function TPGScheduler.GetConfig(const ATaskMask: string): TValue;
var
  Lista: TArray<string>;
  Arr: TArray<TValue>;
  I: Integer;
begin
  Lista := SchedulerResolveMask(FMachineName, ATaskMask);
  if Length(Lista) = 0 then Exit(TValue.Empty);
  if Length(Lista) = 1 then Exit(TValue.From<Integer>(SchedulerGetConfig(FMachineName, Lista[0])));

  SetLength(Arr, Length(Lista));
  for I := 0 to High(Lista) do
    Arr[I] := TValue.From<Integer>(SchedulerGetConfig(FMachineName, Lista[I]));
  Result := TValue.From<TArray<TValue>>(Arr);
end;

function TPGScheduler.GetLastResult(const ATaskMask: string): TValue;
var
  Lista: TArray<string>;
  Arr: TArray<TValue>;
  I: Integer;
begin
  Lista := SchedulerResolveMask(FMachineName, ATaskMask);
  if Length(Lista) = 0 then Exit(TValue.Empty);
  if Length(Lista) = 1 then Exit(TValue.From<Integer>(SchedulerGetLastResult(FMachineName, Lista[0])));

  SetLength(Arr, Length(Lista));
  for I := 0 to High(Lista) do
    Arr[I] := TValue.From<Integer>(SchedulerGetLastResult(FMachineName, Lista[I]));
  Result := TValue.From<TArray<TValue>>(Arr);
end;

function TPGScheduler.Exists(const ATaskPath: string): Boolean;
begin
  Result := SchedulerGetConfig(FMachineName, ATaskPath) <> -1;
end;

function TPGScheduler.RegisterXML(const ATaskPath, AFileName: string): Boolean;
var
  XMLContent: string;
begin
  Result := False;
  if not TFile.Exists(AFileName) then
  begin
    TPGKernel.Console('Error Scheduler: XML file not found - ' + AFileName);
    Exit;
  end;

  try
    // Task Scheduler espera XML em UTF-16 ou UTF-8 com BOM
    XMLContent := TFile.ReadAllText(AFileName, TEncoding.Unicode);
    Result := SchedulerRegisterXML(FMachineName, ATaskPath, XMLContent);
    CheckResult(Result, ATaskPath);
  except
    on E: Exception do TPGKernel.Console('Error Scheduler: File access error - ' + E.Message);
  end;
end;

initialization
  PGScheduler := TPGScheduler.Create( GlobalItemCommand );

finalization
  PGScheduler := nil;

end.
