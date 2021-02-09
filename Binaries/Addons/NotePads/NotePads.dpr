program NotePads;

uses
  Vcl.Forms,
  UnitNotePads in 'UnitNotePads.pas' {FrmNotePads},
  PGofer.Classes in '..\..\Lib\PGofer.Classes.pas',
  PGofer.ClipBoards in '..\..\Lib\PGofer.ClipBoards.pas',
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas',
  PGofer.Files in '..\..\Lib\PGofer.Files.pas',
  PGofer.HotKey in '..\..\Lib\PGofer.HotKey.pas',
  PGofer.Key in '..\..\Lib\PGofer.Key.pas',
  PGofer.Lexico in '..\..\Lib\PGofer.Lexico.pas',
  PGofer.Links in '..\..\Lib\PGofer.Links.pas',
  PGofer.ListView in '..\..\Lib\PGofer.ListView.pas',
  PGofer.Math in '..\..\Lib\PGofer.Math.pas',
  PGofer.Net in '..\..\Lib\PGofer.Net.pas',
  PGofer.Process in '..\..\Lib\PGofer.Process.pas',
  PGofer.Registry in '..\..\Lib\PGofer.Registry.pas',
  PGofer.Service in '..\..\Lib\PGofer.Service.pas',
  PGofer.Service.Thread in '..\..\Lib\PGofer.Service.Thread.pas',
  PGofer.Sintatico in '..\..\Lib\PGofer.Sintatico.pas',
  PGofer.Sound.DevApi in '..\..\Lib\PGofer.Sound.DevApi.pas',
  PGofer.Sound in '..\..\Lib\PGofer.Sound.pas',
  PGofer.System in '..\..\Lib\PGofer.System.pas',
  PGofer.TreeView in '..\..\Lib\PGofer.TreeView.pas',
  PGofer.ZLib in '..\..\Lib\PGofer.ZLib.pas';

{$R *.res}

begin
    if BeforeInitialize('TFrmNotePads', WM_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmNotePads, FrmNotePads);
  AfterInitialize(FrmNotePads.Handle, WM_SETFOCUS);
        Application.Run;
    end;
end.
