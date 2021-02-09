program Commands;

uses
  Vcl.Forms,
  UnitCommands in 'UnitCommands.pas' {Form1},
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas',
  PGofer.Files in '..\..\Lib\PGofer.Files.pas',
  PGofer.TreeView in '..\..\Lib\PGofer.TreeView.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
