program Services;
uses
  Vcl.Forms, Vcl.Themes, Vcl.Styles, System.SysUtils,
  PGofer.ClipBoards.Controls in '..\..\..\Libraries\Lib\ClipBoards\PGofer.ClipBoards.Controls.pas',
  PGofer.Files.Controls in '..\..\..\Libraries\Lib\Files\PGofer.Files.Controls.pas',
  PGofer.Component.IniFile in '..\..\..\Libraries\Componet\Source\PGofer.Component.IniFile.pas',
  PGofer.Component.ListView in '..\..\..\Libraries\Componet\Source\PGofer.Component.ListView.pas',
  PGofer.Services.Controls in '..\..\..\Libraries\Lib\Services\PGofer.Services.Controls.pas',
  PGofer.Component.Form in '..\..\..\Libraries\Componet\Source\PGofer.Component.Form.pas' {FormEx},
  Services.Thread in 'Services.Thread.pas',
  UnitServices in 'UnitServices.pas' {FrmServices};

{$R *.res}

begin
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'PGofer Services V2.0';
  Application.CreateForm(TFrmServices, FrmServices);
  Application.Run;
end.
