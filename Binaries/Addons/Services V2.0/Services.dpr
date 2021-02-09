program Services;

uses
  Vcl.Forms,
  UnitServices in 'UnitServices.pas' {FrmServices},
  PGofer.Service in '..\..\Lib\PGofer.Service.pas',
  PGofer.Service.Thread in '..\..\Lib\PGofer.Service.Thread.pas',
  PGofer.ListView in '..\..\Lib\PGofer.ListView.pas',
  PGofer.Files in '..\..\Lib\PGofer.Files.pas',
  PGofer.ClipBoards in '..\..\Lib\PGofer.ClipBoards.pas',
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas';

{$R *.res}

begin
    if BeforeInitialize('TFrmLinks', WM_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmServices, FrmServices);
        AfterInitialize(FrmServices.Handle,WM_SETFOCUS);
        Application.Run;
    end;
end.
