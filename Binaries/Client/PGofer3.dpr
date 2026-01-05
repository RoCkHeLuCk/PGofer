program PGofer3;
{$DEFINE MSWINDOWS}

uses
  PGofer.Types in '..\..\Libraries\Lib\Kernel\PGofer.Types.pas',
  PGofer.Language in '..\..\Libraries\Lib\Kernel\Utils\PGofer.Language.pas',
  PGofer.IconList in '..\..\Libraries\Lib\Kernel\Utils\PGofer.IconList.pas',
  PGofer.Classes in '..\..\Libraries\Lib\Kernel\PGofer.Classes.pas',
  PGofer.Lexico in '..\..\Libraries\Lib\Kernel\PGofer.Lexico.pas',
  PGofer.Sintatico in '..\..\Libraries\Lib\Kernel\PGofer.Sintatico.pas',
  PGofer.Runtime in '..\..\Libraries\Lib\Kernel\PGofer.Runtime.pas',
  PGofer.VaultFolder in '..\..\Libraries\Lib\Kernel\VaultFolder\PGofer.VaultFolder.pas',
  PGofer.VaultFolder.Frame in '..\..\Libraries\Lib\Kernel\VaultFolder\PGofer.VaultFolder.Frame.pas' {PGVaultFolderFrame: TFrame},
  PGofer.VaultFolder.KeyStore in '..\..\Libraries\Lib\Kernel\VaultFolder\PGofer.VaultFolder.KeyStore.pas',
  PGofer.Sintatico.Controls in '..\..\Libraries\Lib\Kernel\PGofer.Sintatico.Controls.pas',
  PGofer.Item.Frame in '..\..\libraries\lib\kernel\PGofer.Item.Frame.pas' {PGItemFrame: TFrame},
  PGofer.ClipBoards in '..\..\Libraries\Lib\ClipBoards\PGofer.ClipBoards.pas',
  PGofer.ClipBoards.Controls in '..\..\Libraries\Lib\ClipBoards\PGofer.ClipBoards.Controls.pas',
  PGofer.Files in '..\..\Libraries\Lib\Files\PGofer.Files.pas',
  PGofer.Files.Controls in '..\..\Libraries\Lib\Files\PGofer.Files.Controls.pas',
  PGofer.Files.WinShell in '..\..\Libraries\Lib\Files\PGofer.Files.WinShell.pas',
  PGofer.Files.Encrypt in '..\..\Libraries\Lib\Files\PGofer.Files.Encrypt.pas',
  PGofer.Key in '..\..\Libraries\Lib\Key\PGofer.Key.pas',
  PGofer.Key.Controls in '..\..\Libraries\Lib\Key\PGofer.Key.Controls.pas',
  PGofer.Key.Post in '..\..\Libraries\Lib\Key\PGofer.Key.Post.pas',
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
  PGofer.Sound.MMDevApi in '..\..\Libraries\Lib\Sound\PGofer.Sound.MMDevApi.pas',
  PGofer.System in '..\..\Libraries\Lib\System\PGofer.System.pas',
  PGofer.System.Mouse in '..\..\Libraries\Lib\System\PGofer.System.Mouse.pas',
  PGofer.System.Controls in '..\..\Libraries\Lib\System\PGofer.System.Controls.pas',
  PGofer.System.Statements in '..\..\Libraries\Lib\System\PGofer.System.Statements.pas',
  PGofer.System.Variants in '..\..\Libraries\Lib\System\PGofer.System.Variants.pas',
  PGofer.System.Variants.Frame in '..\..\Libraries\Lib\System\PGofer.System.Variants.Frame.pas' {PGVariantsFrame: TFrame},
  PGofer.System.Functions in '..\..\Libraries\Lib\System\PGofer.System.Functions.pas',
  PGofer.System.Functions.Frame in '..\..\Libraries\Lib\System\PGofer.System.Functions.Frame.pas' {PGFunctionFrame: TFrame},
  PGofer.System.VirtualDesktop in '..\..\Libraries\Lib\System\PGofer.System.VirtualDesktop.pas',
  PGofer.Forms in '..\..\Libraries\Forms\PGofer.Forms.pas',
  PGofer.Forms.Controls in '..\..\Libraries\Forms\PGofer.Forms.Controls.pas',
  PGofer.Forms.Frame in '..\..\Libraries\Forms\PGofer.Forms.Frame.pas' {PGFormsFrame: TFrame},
  PGofer.Forms.Controller in '..\..\Libraries\Forms\Controller\PGofer.Forms.Controller.pas' {FrmController},
  PGofer.Forms.AutoComplete in '..\..\Libraries\Forms\AutoComplete\PGofer.Forms.AutoComplete.pas' {FrmAutoComplete},
  PGofer.Forms.Console in '..\..\Libraries\Forms\Console\PGofer.Forms.Console.pas' {FrmConsole},
  PGofer.Forms.Console.Frame in '..\..\Libraries\Forms\Console\PGofer.Forms.Console.Frame.pas' {PGConsoleFrame: TFrame},
  PGofer.Triggers in '..\..\Libraries\Triggers\PGofer.Triggers.pas',
  PGofer.Triggers.Frame in '..\..\Libraries\Triggers\PGofer.Triggers.Frame.pas' {PGTriggerFrame: TFrame},
  PGofer.Triggers.HotKeys in '..\..\Libraries\Triggers\HotKeys\PGofer.Triggers.HotKeys.pas',
  PGofer.Triggers.HotKeys.Controls in '..\..\Libraries\Triggers\HotKeys\PGofer.Triggers.HotKeys.Controls.pas',
  PGofer.Triggers.HotKeys.MMHook in '..\..\Libraries\Triggers\HotKeys\Input\PGofer.Triggers.HotKeys.MMHook.pas',
  PGofer.Triggers.HotKeys.Hook in '..\..\Libraries\Triggers\HotKeys\Input\PGofer.Triggers.HotKeys.Hook.pas',
  PGofer.Triggers.HotKeys.MMRawInput in '..\..\Libraries\Triggers\HotKeys\Input\PGofer.Triggers.HotKeys.MMRawInput.pas',
  PGofer.Triggers.HotKeys.RawInput in '..\..\Libraries\Triggers\HotKeys\Input\PGofer.Triggers.HotKeys.RawInput.pas',
  PGofer.Triggers.HotKeys.Async in '..\..\Libraries\Triggers\HotKeys\Input\PGofer.Triggers.HotKeys.Async.pas',
  PGofer.Triggers.HotKeys.Frame in '..\..\Libraries\Triggers\HotKeys\PGofer.Triggers.HotKeys.Frame.pas' {PGHotKeyFrame: TFrame},
  PGofer.Triggers.Links in '..\..\Libraries\Triggers\Links\PGofer.Triggers.Links.pas',
  PGofer.Triggers.Links.Thread in '..\..\Libraries\Triggers\Links\PGofer.Triggers.Links.Thread.pas',
  PGofer.Triggers.Links.ProcessUI in '..\..\Libraries\Triggers\Links\PGofer.Triggers.Links.ProcessUI.pas',
  PGofer.Triggers.Links.Frame in '..\..\Libraries\Triggers\Links\PGofer.Triggers.Links.Frame.pas' {PGLinkFrame: TFrame},
  PGofer.Triggers.Tasks in '..\..\Libraries\Triggers\Tasks\PGofer.Triggers.Tasks.pas',
  PGofer.Triggers.Tasks.Frame in '..\..\Libraries\Triggers\Tasks\PGofer.Triggers.Tasks.Frame.pas' {PGTaskFrame: TFrame},
  PGofer.Triggers.AutoFills in '..\..\Libraries\Triggers\AutoFills\PGofer.Triggers.AutoFills.pas',
  PGofer.Triggers.AutoFills.Frame in '..\..\Libraries\Triggers\AutoFills\PGofer.Triggers.AutoFills.Frame.pas' {PGAutoFillsFrame: TFrame},
  Pgofer.Component.Edit in '..\..\Libraries\Componet\Source\Pgofer.Component.Edit.pas',
  Pgofer.Component.Checkbox in '..\..\Libraries\Componet\Source\Pgofer.Component.Checkbox.pas',
  PGofer.Component.ListView in '..\..\Libraries\Componet\Source\PGofer.Component.ListView.pas',
  PGofer.Component.RichEdit in '..\..\Libraries\Componet\Source\PGofer.Component.RichEdit.pas',
  PGofer.Component.TreeView in '..\..\Libraries\Componet\Source\PGofer.Component.TreeView.pas',
  PGofer.Component.Form in '..\..\Libraries\Componet\Source\PGofer.Component.Form.pas' {FormEx},
  PGofer3.Client in 'PGofer3.Client.pas' {FrmPGofer},
  Winapi.Windows,
  Vcl.Forms;

{$R *.res}

begin
  if FormBeforeInitialize( 'TFrmPGofer', WM_PG_SETFOCUS ) then
  begin
    {$IFDEF DEBUG}
    ReportMemoryLeaksOnShutdown := True;
    {$ENDIF}
    SetPriorityClass( GetCurrentProcess, REALTIME_PRIORITY_CLASS );
    SetProcessPriorityBoost( GetCurrentProcess, False );

    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.ModalPopupMode := pmAuto;
    Application.Title := 'PGofer V3.0';
    Application.CreateForm(TFrmPGofer, FrmPGofer);
    Application.CreateForm(TFrmAutoComplete, FrmAutoComplete);
    Application.CreateForm(TFrmConsole, FrmConsole);
    FrmAutoComplete.EditCtrlAdd( FrmPGofer.EdtScript );
    GlobalCollection.XMLLoadFromFile( );
    TriggersCollect.XMLLoadFromFile( );
    TPGTask.Working( 0, False );
    FormAfterInitialize( FrmPGofer.Handle, WM_PG_SETFOCUS );
    Application.Run;
  end;

end.
