program Launcher;

uses
  Winapi.ShellAPI,
  System.SysUtils;

var
  CurrentDir: PWideChar;

begin
  CurrentDir := PWideChar( ExtractFilePath( ParamStr( 0 ) ) );
  ShellExecute( 0, 'open', PWideChar( CurrentDir + 'PGofer3.exe' ),
     '"FrmPGofer.Show(1);"', CurrentDir, 1 );

end.
