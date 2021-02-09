program Links;

uses
  Vcl.Forms,
  UnitLinks in 'UnitLinks.pas' {FrmLinks},
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas',
  PGofer.Files in '..\..\Lib\PGofer.Files.pas',
  PGofer.ListView in '..\..\Lib\PGofer.ListView.pas',
  PGofer.Key in '..\..\Lib\PGofer.Key.pas';

{$R *.res}

begin
    if BeforeInitialize('TFrmLinks', WM_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmLinks, FrmLinks);
        AfterInitialize(FrmLinks.Handle,WM_SETFOCUS);
        Application.Run;
    end;
end.
