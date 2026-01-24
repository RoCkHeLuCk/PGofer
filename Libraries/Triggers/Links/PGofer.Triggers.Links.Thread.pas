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
    FState: Byte;
    FPriority: Byte;
    FRunAdmin: Boolean;
    FCaptureMsg: Boolean;
    FSingleInstance: Boolean;

    procedure PipeLines();
    procedure ShellExec();
    procedure CreateProcess();
  protected
    procedure Execute; override;
  public
    constructor Create(
      ALink: TPGLink;
      ATerminate: Boolean;
      AParameter: string;
      ARunAdmin: Boolean;
      ASingleInstance: Boolean;
      APriority: Byte;
      AState: Byte;
      ACaptureMsg: Boolean
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
  PGofer.Language,
  PGofer.Sintatico,
  PGofer.Files.Controls,
  PGofer.Triggers.Links.ProcessUI;

{ TLinkThread }

constructor TLinkThread.Create(
    ALink: TPGLink;
    ATerminate: Boolean;
    AParameter: string;
    ARunAdmin: Boolean;
    ASingleInstance: Boolean;
    APriority: Byte;
    AState: Byte;
    ACaptureMsg: Boolean
  );
begin
  inherited Create(True);
  Self.FreeOnTerminate := ATerminate;
  Self.Priority := tpIdle;

  FLink := ALink;
  FConsoleMessage := TPGKernel.GetVar('ConsoleMessage',True);

  FParameter:= AParameter;
  FState:= AState;
  FPriority:= APriority;
  FRunAdmin:= ARunAdmin;
  FCaptureMsg:= ACaptureMsg;
  FSingleInstance:= ASingleInstance;
end;

destructor TLinkThread.Destroy();
begin
  FParameter:= '';
  FState:= 0;
  FPriority:= 0;
  FRunAdmin:= False;
  FCaptureMsg:= False;
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
    TrC('Error_Link_SingleInstance',[FLink.Name], True, FConsoleMessage);
    FLink.CanExecute := False;
  end;

  if FLink.CanExecute then
  begin
    if FCaptureMsg then
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
      GetProcessPri(FPriority),
      nil,
      PWideChar(Directory),
      StartupInfo,
      ProcessInfo) then
    begin
      pBuffer := AllocMem(CReadBuffer + 1);
      TrC('Link ' + FLink.Name + ' : ', True, FConsoleMessage);

      repeat
        dRunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
        repeat
          dRead := 0;
          ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
          pBuffer[dRead] := #0;

          OemToAnsi(pBuffer, pBuffer);
          TrC(string(pBuffer), False, FConsoleMessage);
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
    GetProcessPri(FPriority)     ,    //create flag
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
      TrC(
        'Link ' + FLink.Name + ' : ' + SysErrorMessage(ReturnCode),
        True,
        FConsoleMessage
      );
    end else begin
      TrC(
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
    SetPriorityClass(ShellExecuteInfoW.hProcess, GetProcessPri(FPriority));
  end;

  sText := GetShellExMSGToStr(ShellExecuteInfoW.hInstApp);
  if sText <> '' then
    TrC('Link ' + FLink.Name + ' : ' + sText, True,
      FConsoleMessage);

  if (FLink.ScriptAfter <> '') or (not Self.FreeOnTerminate) then
  begin
    while WaitForSingleObject(ShellExecuteInfoW.hProcess, 500) <>
      WAIT_OBJECT_0 do;
  end;

  CloseHandle(ShellExecuteInfoW.hProcess);
end;

end.
