program PGofer;

uses
  Vcl.Forms,
  UnitPGofer in 'UnitPGofer.pas' {FrmPGofer},
  UnitConsole in 'UnitConsole.pas' {FrmConsoles},
  UnitAutoComplete in 'UnitAutoComplete.pas' {FrmAutoCompletes},
  PGofer.Classes in '..\Lib\PGofer.Classes.pas',
  PGofer.ClipBoards in '..\Lib\PGofer.ClipBoards.pas',
  PGofer.Controls in '..\Lib\PGofer.Controls.pas',
  PGofer.Files in '..\Lib\PGofer.Files.pas',
  PGofer.Key in '..\Lib\PGofer.Key.pas',
  PGofer.Lexico in '..\Lib\PGofer.Lexico.pas',
  PGofer.ListView in '..\Lib\PGofer.ListView.pas',
  PGofer.Math in '..\Lib\PGofer.Math.pas',
  PGofer.Net in '..\Lib\PGofer.Net.pas',
  PGofer.Process in '..\Lib\PGofer.Process.pas',
  PGofer.Registry in '..\Lib\PGofer.Registry.pas',
  PGofer.Service in '..\Lib\PGofer.Service.pas',
  PGofer.Sintatico in '..\Lib\PGofer.Sintatico.pas',
  PGofer.Sound.DevApi in '..\Lib\PGofer.Sound.DevApi.pas',
  PGofer.Sound in '..\Lib\PGofer.Sound.pas',
  PGofer.System in '..\Lib\PGofer.System.pas',
  PGofer.Links in '..\Lib\PGofer.Links.pas';

{$R *.res}

begin
    if BeforeInitialize('TFrmPGofer', WM_PG_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := true;
        Application.CreateForm(TFrmPGofer, FrmPGofer);
        Application.CreateForm(TFrmConsoles, FrmConsoles);
        Application.CreateForm(TFrmAutoCompletes, FrmAutoCompletes);
        AfterInitialize(FrmPGofer.Handle, WM_PG_SETFOCUS);
        CompilarComando('File.Script( '+DirCurrent+'Lib\Consts.pas , 0 , 1 );', nil );
        CompilarComando('File.Script( '+DirCurrent+'AutoRun\AutoRun.pas , 0 , 1 );', nil );
        Application.Run;
   end;
end.
