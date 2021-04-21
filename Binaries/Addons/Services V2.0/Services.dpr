program Services;

uses
  PGofer.ClipBoards.Controls in '..\..\..\Libraries\Lib\ClipBoards\PGofer.ClipBoards.Controls.pas',
  PGofer.Files.Controls in '..\..\..\Libraries\Lib\Files\PGofer.Files.Controls.pas',
  PGofer.Component.ListView in '..\..\..\Libraries\Componet\Source\PGofer.Component.ListView.pas',
  PGofer.Services.Controls in '..\..\..\Libraries\Lib\Services\PGofer.Services.Controls.pas',
  PGofer.Services.Thread in '..\..\..\Libraries\Lib\Services\PGofer.Services.Thread.pas',
  PGofer.Component.Form in '..\..\..\Libraries\Componet\Source\PGofer.Component.Form.pas' {FormEx},
  Vcl.Forms,
  UnitServices in 'UnitServices.pas' {FrmServices};

{$R *.res}

begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm( TFrmServices, FrmServices );
    Application.Run;
end.
