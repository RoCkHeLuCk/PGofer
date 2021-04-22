program Launcher;

uses
  Winapi.ShellAPI,
  System.SysUtils;

var
  CurrentDir: PWideChar;

begin
  CurrentDir := PWideChar( ExtractFilePath( ParamStr( 0 ) ) );
<<<<<<< HEAD
  ShellExecute( 0, 'open', PWideChar( CurrentDir + 'PGofer3.exe' ),
     '"FrmPGofer.Show(1);"', CurrentDir, 1 );
=======
  ShellExecute( 0, 'open', PWideChar( CurrentDir + 'PGofer.exe' ),
     '"PGofer.Show(1);"', CurrentDir, 1 );
>>>>>>> c3c63536427a8e61ccb4830f4dee68a022344625

end.
