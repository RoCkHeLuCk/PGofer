program Services;
uses
  PGofer.ClipBoards.Controls in '..\..\..\Libraries\Lib\ClipBoards\PGofer.ClipBoards.Controls.pas',
  PGofer.Files.Controls in '..\..\..\Libraries\Lib\Files\PGofer.Files.Controls.pas',
  PGofer.Component.IniFile in '..\..\..\Libraries\Componet\Source\PGofer.Component.IniFile.pas',
  PGofer.Component.ListView in '..\..\..\Libraries\Componet\Source\PGofer.Component.ListView.pas',
  PGofer.Services.Controls in '..\..\..\Libraries\Lib\Services\PGofer.Services.Controls.pas',
  PGofer.Component.Form in '..\..\..\Libraries\Componet\Source\PGofer.Component.Form.pas' {FormEx},
  Services.Thread in 'Services.Thread.pas',
  UnitServices in 'UnitServices.pas' {FrmServices},
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'PGofer Services V2.0';
  Application.CreateForm(TFrmServices, FrmServices);
  Application.Run;
end.
