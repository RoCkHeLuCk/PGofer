unit PGofer.Triggers.Links.Thread;

interface

uses
  System.Classes,
  PGofer.Triggers.Links;

type
  TLinkThread = class(TThread)
  private
    FLink: TPGLink;
    FConsoleMessage: Boolean;
    FParameter: string;
    FRunAdmin: Boolean;
    FSingleInstance: Boolean;
    FState: Byte;

    procedure PipeLines();
    procedure ShellExec();
    procedure CreateProcess();
  protected
    procedure Execute; override;
  public
    constructor Create(
      ALink: TPGLink;
      AWaitFor: Boolean;
      AParameter: string;
      ARunAdmin: Boolean;
      ASingleInstance: Boolean;
      AState: Byte
    ); overload;
    destructor Destroy(); override;
  end;

implementation

uses
  System.SysUtils,
  WinApi.Windows,
  WinApi.ShellApi,
  Vcl.Forms,
  PGofer.Core,
  PGofer.Runtime,
  PGofer.Files.Controls,
  PGofer.Triggers.Links.ProcessUI;

{ TLinkThread }

constructor TLinkThread.Create(
    ALink: TPGLink;
    AWaitFor: Boolean;
    AParameter: string;
    ARunAdmin: Boolean;
    ASingleInstance: Boolean;
    AState: Byte
  );
begin
  inherited Create(True);
  Self.FreeOnTerminate := not AWaitFor;
  Self.Priority := tpIdle;

  FLink := ALink;
  FConsoleMessage := TPGKernel.ConsoleMessage;

  FParameter:= AParameter;
  FRunAdmin:= ARunAdmin;
  FSingleInstance:= ASingleInstance;
  FState:= AState;
end;

destructor TLinkThread.Destroy();
begin
  FParameter:= '';
  FState:= 0;
  FRunAdmin:= False;
  FSingleInstance:= False;
  FLink := nil;
  inherited Destroy();
end;

procedure TLinkThread.Execute();
begin
  FLink.CanExecute := True;
  if FLink.ScriptBefor <> '' then
    ScriptExec('Link Befor: ' + FLink.Name, FLink.ScriptBefor, nil, True);

  if FSingleInstance and FLink.isRunning then
  begin
    TPGKernel.ConsoleTr('Error_Link_SingleInstance',[FLink.Name], True, FConsoleMessage);
    FLink.CanExecute := False;
  end;

  if FLink.CanExecute then
  begin
    if FLink.CaptureMsg then
    begin
      PipeLines()
    end else begin
      if FRunAdmin then
         ShellExec( )
      else
         CreateProcess();
    end;

    if (FLink.ScriptAfter <> '') then
      ScriptExec('Link After: ' + FLink.Name, FLink.ScriptAfter, nil, True);
  end;
end;

procedure TLinkThread.PipeLines();
const
  CReadBuffer = 2400;
var
  SecurityAttribute: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  FileName, Param, Directory: string;
  hRead: THandle;
  hWrite: THandle;
  pBuffer: PAnsiChar;
  dRead: DWord;
  dRunning: DWord;
begin
  SecurityAttribute.nLength := SizeOf(TSecurityAttributes);
  SecurityAttribute.bInheritHandle := True;
  SecurityAttribute.lpSecurityDescriptor := nil;

  if CreatePipe(hRead, hWrite, @SecurityAttribute, 0) then
  begin
    StartupInfo := Default( TStartupInfo );
    StartupInfo.cb := SizeOf(TStartupInfo);
    StartupInfo.hStdInput := hRead;
    StartupInfo.hStdOutput := hWrite;
    StartupInfo.hStdError := hWrite;
    StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := FState;
    StartupInfo.lpTitle := PWideChar(FLink.Name);
    FileName := FileExpandPath(FLink.FileName);
    Param := FileExpandPath(FParameter);
    Directory := FileExpandPath(FLink.Directory);

    ProcessInfo := default (TProcessInformation);

    if CreateProcessW(
      PWideChar(FileName),
      PWideChar('"' + FileName + '" ' + Param),
      @SecurityAttribute,
      @SecurityAttribute,
      True,
      GetProcessPri(FLink.Priority),
      nil,
      PWideChar(Directory),
      StartupInfo,
      ProcessInfo) then
    begin
      pBuffer := AllocMem(CReadBuffer + 1);
      TPGKernel.ConsoleTr('Link ' + FLink.Name + ' : ', True, FConsoleMessage);

      repeat
        dRunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
        repeat
          dRead := 0;
          ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
          pBuffer[dRead] := #0;

          OemToAnsi(pBuffer, pBuffer);
          TPGKernel.ConsoleTr(string(pBuffer), False, FConsoleMessage);
        until (dRead < CReadBuffer);
      until (dRunning <> WAIT_TIMEOUT);

      FreeMem(pBuffer);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;

    CloseHandle(hRead);
    CloseHandle(hWrite);
  end;
end;

procedure TLinkThread.CreateProcess();
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  FileName, Param, Directory: string;
  ReturnCode : Cardinal;
begin
  StartupInfo := Default(TStartupInfo);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := FState;
  StartupInfo.lpTitle := PWideChar(FLink.Name);
  FileName := FileExpandPath(FLink.FileName);
  Param := FileExpandPath(FParameter);

  if FLink.Directory <> '' then
    Directory := FileExpandPath(FLink.Directory)
  else
    Directory := FileExpandPath(ExtractFilePath(FLink.FileName));

  ProcessInfo := Default(TProcessInformation);

  ReturnCode := CreateProcessRunCurrent(
    FileName,                         //application
    '"' + FileName + '" ' + Param,    //command line
    GetProcessPri(FLink.Priority)     ,    //create flag
    nil,                              //Enviroment
    Directory,                        //Current Diretory
    StartupInfo,                      //StartupInfo
    ProcessInfo                       //ProcessInfo
  );

  if ReturnCode = 740 then
  begin
    ShellExec();
  end else begin
    if ReturnCode <> 0 then
    begin
      TPGKernel.ConsoleTr(
        'Link ' + FLink.Name + ' : ' + SysErrorMessage(ReturnCode),
        True,
        FConsoleMessage
      );
    end else begin
      TPGKernel.ConsoleTr(
        'Link ' + FLink.Name + ' : Ok: File Executed.',
        True,
        FConsoleMessage
      );
      if (FLink.ScriptAfter <> '') or (not Self.FreeOnTerminate) then
      begin
        while WaitForSingleObject(ProcessInfo.hProcess, 500) <> WAIT_OBJECT_0 do;
      end;
    end;
  end;

  CloseHandle(ProcessInfo.hThread);
  CloseHandle(ProcessInfo.hProcess);
end;

procedure TLinkThread.ShellExec();
var
  ShellExecuteInfoW: TShellExecuteInfo;
  sText: string;
begin
  FillChar(ShellExecuteInfoW, SizeOf(TShellExecuteInfoW), #0);

  ShellExecuteInfoW.cbSize := SizeOf(TShellExecuteInfoW);
  ShellExecuteInfoW.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfoW.Wnd := Application.Handle;
  ShellExecuteInfoW.lpVerb := PWideChar('RunAs');
  ShellExecuteInfoW.lpFile := PWideChar(FileExpandPath(FLink.FileName));
  ShellExecuteInfoW.lpParameters := PWideChar(FileExpandPath(FParameter));
  ShellExecuteInfoW.lpDirectory := PWideChar(FileExpandPath(FLink.Directory));
  ShellExecuteInfoW.nShow := FState;

  ShellExecuteExW(@ShellExecuteInfoW);

  if ShellExecuteInfoW.hProcess <> INVALID_HANDLE_VALUE then
  begin
    SetPriorityClass(ShellExecuteInfoW.hProcess, GetProcessPri(FLink.Priority));
  end;

  sText := GetShellExMSGToStr(ShellExecuteInfoW.hInstApp);
  if sText <> '' then
    TPGKernel.ConsoleTr('Link ' + FLink.Name + ' : ' + sText, True,
      FConsoleMessage);

  if (FLink.ScriptAfter <> '') or (not Self.FreeOnTerminate) then
  begin
    while WaitForSingleObject(ShellExecuteInfoW.hProcess, 500) <>
      WAIT_OBJECT_0 do;
  end;

  CloseHandle(ShellExecuteInfoW.hProcess);
end;

end.
