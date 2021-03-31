unit PGofer.Process.Controls;

interface

function ProcessFileToPID( const FileName: string ): Cardinal;
function ProcessFileFromPID( const PID: Cardinal ): string;
function ProcessKill( const PID: Cardinal ): Boolean;
function ProcessSetPriority( const PID, Priority: Cardinal ): Boolean;
function ProcessGetPriority( const PID: Cardinal ): Cardinal;
function ProcessGetForeground( ): Cardinal;

implementation

uses
  Winapi.Windows, Winapi.PsApi, System.SysUtils;

function ProcessFileToPID( const FileName: string ): Cardinal;
var
  PID             : array [ 0 .. 1023 ] of Cardinal;
  aModule         : array [ 0 .. 299 ] of Char;
  cbNeeded        : Cardinal;
  cProcesses, C   : Cardinal;
  hProcess, hModul: THandle;
begin
  Result := 0;
  if EnumProcesses( @PID, SizeOf( PID ), cbNeeded ) then
  begin
    cProcesses := cbNeeded;
    C := 0;
    while C < cProcesses do
    begin
      hProcess := OpenProcess( PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
         false, PID[ C ] );
      if ( hProcess <> 0 ) then
      begin
        if EnumProcessModules( hProcess, @hModul, SizeOf( hModul ), cbNeeded )
        then
        begin
          GetModuleFilenameEx( hProcess, hModul, aModule, SizeOf( aModule ) );
          if SameText( ExtractFileName( aModule ), FileName ) then
          begin
            Result := PID[ C ];
            C := cProcesses;
          end;
        end;
        CloseHandle( hProcess );
      end;
      inc( C );
    end;
  end;
end;

function ProcessFileFromPID( const PID: Cardinal ): string;
var
  aModule         : array [ 0 .. 299 ] of Char;
  hProcess, hModul: THandle;
  cbNeeded        : Cardinal;
begin
  hProcess := OpenProcess( PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
     false, PID );
  if ( hProcess <> 0 ) then
  begin
    if EnumProcessModules( hProcess, @hModul, SizeOf( hModul ), cbNeeded ) then
    begin
      if GetModuleFilenameEx( hProcess, hModul, aModule, SizeOf( aModule ) ) <> 0
      then
        Result := ExtractFileName( aModule );
    end;
  end;
end;

function ProcessKill( const PID: Cardinal ): Boolean;
var
  hProcess: THandle;
begin
  Result := false;
  hProcess := OpenProcess( PROCESS_TERMINATE or PROCESS_QUERY_INFORMATION,
     false, PID );
  if hProcess <> 0 then
  begin
    if TerminateProcess( hProcess, 0 ) then
      Result := True;
    CloseHandle( hProcess );
  end;
end;

function ProcessSetPriority( const PID, Priority: Cardinal ): Boolean;
var
  hProcess: THandle;
begin
  Result := false;
  hProcess := OpenProcess( PROCESS_SET_INFORMATION or PROCESS_QUERY_INFORMATION,
     false, PID );
  if hProcess <> 0 then
  begin
    if SetPriorityClass( hProcess, Priority ) then
      Result := True;
    CloseHandle( hProcess );
  end;
end;

function ProcessGetPriority( const PID: Cardinal ): Cardinal;
var
  hProcess: THandle;
begin
  Result := 0;
  hProcess := OpenProcess( PROCESS_QUERY_INFORMATION or PROCESS_VM_WRITE,
     false, PID );
  if hProcess <> 0 then
  begin
    Result := GetPriorityClass( hProcess );
    CloseHandle( hProcess );
  end;
end;

function ProcessGetForeground( ): Cardinal;
var
  activeWinHandle: HWND;
begin
  activeWinHandle := GetForegroundWindow( );
  GetWindowThreadProcessID( activeWinHandle, @Result );
end;

end.
