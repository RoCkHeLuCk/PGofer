program PGofer3;

uses
  PGofer.Classes in '..\..\Libraries\Lib\Kernel\PGofer.Classes.pas',
  PGofer.Item.Frame in '..\..\libraries\lib\kernel\PGofer.Item.Frame.pas' {PGFrame: TFrame},
  PGofer.Lexico in '..\..\Libraries\Lib\Kernel\PGofer.Lexico.pas',
  PGofer.Sintatico in '..\..\Libraries\Lib\Kernel\PGofer.Sintatico.pas',
  PGofer.Sintatico.Classes in '..\..\Libraries\Lib\Kernel\PGofer.Sintatico.Classes.pas',
  PGofer.Sintatico.Controls in '..\..\Libraries\Lib\Kernel\PGofer.Sintatico.Controls.pas',
  PGofer.ClipBoards in '..\..\Libraries\Lib\ClipBoards\PGofer.ClipBoards.pas',
  PGofer.ClipBoards.Controls in '..\..\Libraries\Lib\ClipBoards\PGofer.ClipBoards.Controls.pas',
  PGofer.Files in '..\..\Libraries\Lib\Files\PGofer.Files.pas',
  PGofer.Files.Controls in '..\..\Libraries\Lib\Files\PGofer.Files.Controls.pas',
  PGofer.Forms in '..\..\Libraries\Lib\Forms\PGofer.Forms.pas',
  PGofer.Forms.Controls in '..\..\Libraries\Lib\Forms\PGofer.Forms.Controls.pas',
  PGofer.Forms.Frame in '..\..\Libraries\Lib\Forms\PGofer.Forms.Frame.pas' {PGFrameForms: TFrame},
  PGofer.HotKey in '..\..\Libraries\Lib\HotKey\PGofer.HotKey.pas',
  PGofer.HotKey.Frame in '..\..\Libraries\Lib\HotKey\PGofer.HotKey.Frame.pas' {PGFrameHotKey: TFrame},
  PGofer.HotKey.Hook in '..\..\Libraries\Lib\HotKey\PGofer.HotKey.Hook.pas',
  PGofer.Key in '..\..\Libraries\Lib\Key\PGofer.Key.pas',
  PGofer.Key.Controls in '..\..\Libraries\Lib\Key\PGofer.Key.Controls.pas',
  PGofer.Links in '..\..\Libraries\Lib\Links\PGofer.Links.pas',
  PGofer.Links.Frame in '..\..\Libraries\Lib\Links\PGofer.Links.Frame.pas' {PGLinkFrame: TFrame},
  PGofer.Links.ThreadLoadImage in '..\..\Libraries\Lib\Links\PGofer.Links.ThreadLoadImage.pas',
  PGofer.Math in '..\..\Libraries\Lib\Math\PGofer.Math.pas',
  PGofer.Math.Controls in '..\..\Libraries\Lib\Math\PGofer.Math.Controls.pas',
  PGofer.Net in '..\..\Libraries\Lib\Net\PGofer.Net.pas',
  PGofer.Net.Controls in '..\..\Libraries\Lib\Net\PGofer.Net.Controls.pas',
  PGofer.Net.Socket in '..\..\Libraries\Lib\Net\PGofer.Net.Socket.pas',
  PGofer.Process in '..\..\Libraries\Lib\Process\PGofer.Process.pas',
  PGofer.Process.Controls in '..\..\Libraries\Lib\Process\PGofer.Process.Controls.pas',
  PGofer.Registry in '..\..\Libraries\Lib\Registry\PGofer.Registry.pas',
  PGofer.Registry.Controls in '..\..\Libraries\Lib\Registry\PGofer.Registry.Controls.pas',
  PGofer.Registry.Environment in '..\..\Libraries\Lib\Registry\PGofer.Registry.Environment.pas',
  PGofer.Services in '..\..\Libraries\Lib\Services\PGofer.Services.pas',
  PGofer.Services.Controls in '..\..\Libraries\Lib\Services\PGofer.Services.Controls.pas',
  PGofer.Services.Thread in '..\..\Libraries\Lib\Services\PGofer.Services.Thread.pas',
  PGofer.Sound in '..\..\Libraries\Lib\Sound\PGofer.Sound.pas',
  PGofer.Sound.Controls in '..\..\Libraries\Lib\Sound\PGofer.Sound.Controls.pas',
  PGofer.Sound.DevApi in '..\..\Libraries\Lib\Sound\PGofer.Sound.DevApi.pas',
  PGofer.System in '..\..\Libraries\Lib\System\PGofer.System.pas',
  PGofer.System.Controls in '..\..\Libraries\Lib\System\PGofer.System.Controls.pas',
  PGofer.System.Statements in '..\..\Libraries\Lib\System\PGofer.System.Statements.pas',
  PGofer.System.Variants in '..\..\Libraries\Lib\System\PGofer.System.Variants.pas',
  PGofer.System.Variants.Frame in '..\..\Libraries\Lib\System\PGofer.System.Variants.Frame.pas' {PGFrame1: TFrame},
  PGofer.System.Functions in '..\..\Libraries\Lib\System\PGofer.System.Functions.pas',
  PGofer.System.Functions.Frame in '..\..\Libraries\Lib\System\PGofer.System.Functions.Frame.pas' {PGFrameFunction: TFrame},
  PGofer.System.VirtualDesktop in '..\..\Libraries\Lib\System\PGofer.System.VirtualDesktop.pas',
  PGofer.Utils in '..\..\Libraries\Lib\PGUtils\PGofer.Utils.pas',
  PGofer.Types in '..\..\Libraries\Lib\PGUtils\PGofer.Types.pas',
  PGofer.ZLib in '..\..\Libraries\Lib\PGUtils\PGofer.ZLib.pas',
  PGofer.Component.Edit in '..\..\Libraries\Componet\Source\PGofer.Component.Edit.pas',
  PGofer.Component.ListView in '..\..\Libraries\Componet\Source\PGofer.Component.ListView.pas',
  PGofer.Component.TreeView in '..\..\Libraries\Componet\Source\PGofer.Component.TreeView.pas',
  PGofer.Form.Controller in '..\..\Libraries\Form\Controller\PGofer.Form.Controller.pas' {FrmController},
  PGofer.Form.AutoComplete in '..\..\Libraries\Form\AutoComplete\PGofer.Form.AutoComplete.pas' {FrmAutoComplete},
  PGofer.Form.Console in '..\..\Libraries\Form\Console\PGofer.Form.Console.pas' {FrmConsole},
  Vcl.Forms,
  PGofer3.Client in 'PGofer3.Client.pas' {FrmPGofer},
  Vcl.Themes,
  Vcl.Styles,
  PGofer.Form.Console.Frame in '..\..\Libraries\Form\Console\PGofer.Form.Console.Frame.pas' {PGFrameConsole: TFrame};

{$R *.res}

begin
    if FormBeforeInitialize('TFrmPGofer', WM_PG_SETFOCUS) then
    begin
        ReportMemoryLeaksOnShutdown := True;
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.Title := 'PGofer V3.0';
        Application.CreateForm(TFrmPGofer, FrmPGofer);
        Application.CreateForm(TFrmConsole, FrmConsole);
        FormAfterInitialize(FrmPGofer.Handle, WM_PG_SETFOCUS);
        //CompilarComando('File.Script( '+DirCurrent+'Lib\Consts.pas , 0 , 1 );', nil );
        //CompilarComando('File.Script( '+DirCurrent+'AutoRun\AutoRun.pas , 0 , 1 );', nil );
        Application.Run;
   end;
end.
