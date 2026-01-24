unit PGofer.Triggers.Links.ProcessUI;

interface

uses
  Winapi.Windows;

function CreateProcessRunCurrent(
  ApplicationName: string;
  CommandLine: string;
  CreationFlags: DWORD;
  Environment: LPVOID;
  CurrentDirectory: string;
  const StartupInfo: TStartupInfoW;
  var ProcessInformation: TProcessInformation
): DWORD;

implementation

uses
  PGofer.Process.Controls;

  function CreateProcessWithTokenW(hToken: THandle; dwLogonFlags: DWORD;
    ApplicationName: LPCWSTR; CommandLine: LPWSTR; dwCreationFlags: DWORD;
    lpEnvironment: LPVOID; CurrentDirectory: LPCWSTR;
    const lpStartupInfo: TStartupInfoW; out lpProcessInfo: TProcessInformation)
    : BOOL; stdcall; external 'advapi32.dll' name 'CreateProcessWithTokenW';

  function CreateProcessWithLogonW(lpUsername: PWideChar; lpDomain: PWideChar;
    lpPassword: PWideChar; dwLogonFlags: DWORD; lpApplicationName: PWideChar;
    lpCommandLine: PWideChar; dwCreationFlags: DWORD; lpEnvironment: Pointer;
    lpCurrentDirectory: PWideChar; const lpStartupInfo: TStartupInfo;
    var lpProcessInformation: TProcessInformation): BOOL; stdcall;
    external 'advapi32.dll' name 'CreateProcessWithLogonW';

  function GetShellWindow: HWND; stdcall;
    external 'user32.dll' name 'GetShellWindow';

const
  LOGON_WITH_PROFILE = $00000001;
  LOGON_NETCREDENTIALS_ONLY = $00000002;


function CreateProcessRunCurrent(
  ApplicationName: string;
  CommandLine: string;
  CreationFlags: DWORD;
  Environment: LPVOID;
  CurrentDirectory: string;
  const StartupInfo: TStartupInfoW;
  var ProcessInformation: TProcessInformation): DWORD;
var
  ExplorerHWND: THandle;
  ExplorerPID: DWORD;
  ExplorerToken: THandle;
  NewToken: THandle;
begin
  ExplorerToken := 0;
  NewToken := 0;
  //Result := ERROR_GEN_FAILURE;

  GetWindowThreadProcessId( GetShellWindow() , ExplorerPID);
  if ExplorerPID = 0 then
     ExplorerPID := ProcessFileToPID('explorer.exe');

  if ExplorerPID = 0 then
  begin
    Result := ERROR_FILE_NOT_FOUND;
    Exit;
  end;

  ExplorerHWND := OpenProcess(PROCESS_QUERY_INFORMATION, False, ExplorerPID);
  if ExplorerHWND = 0 then
  begin
    Result := GetLastError();
    Exit;
  end;

  try
    if OpenProcessToken(ExplorerHWND, TOKEN_DUPLICATE, ExplorerToken) then
    begin
      if DuplicateTokenEx(
           ExplorerToken,
           TOKEN_ALL_ACCESS,
           nil,
           SecurityImpersonation,
           TokenPrimary,
           NewToken
        ) then
      begin
        if CreateProcessWithTokenW(
            NewToken,
            LOGON_WITH_PROFILE,
            PWideChar(ApplicationName),
            PWideChar(CommandLine),
            CreationFlags,
            Environment,
            PWideChar(CurrentDirectory),
            StartupInfo,
            ProcessInformation
          ) then
        begin
          Result := ERROR_SUCCESS;
        end else begin
          Result := GetLastError;
        end;
      end else begin
        Result := GetLastError;
      end;
    end else begin
      Result := GetLastError;
    end;

  finally
    if ExplorerToken <> 0 then CloseHandle(ExplorerToken);
    if NewToken <> 0 then CloseHandle(NewToken);
    if ExplorerHWND <> 0 then CloseHandle(ExplorerHWND);
  end;
end;

end.
