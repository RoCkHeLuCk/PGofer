program Launcher;

uses
  Winapi.ShellAPI,
  System.SysUtils;

var
  CurrentDir: PWideChar;

begin
  CurrentDir := PWideChar( ExtractFilePath( ParamStr( 0 ) ) );
  ShellExecuteW( 0, 'open', PWideChar( CurrentDir + 'PGofer3.exe' ),
     PWideChar('/SetFocus'), CurrentDir, 1 );
end.
