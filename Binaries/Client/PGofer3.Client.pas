unit PGofer3.Client;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus,
  PGofer.Forms,
  PGofer.Forms.AutoComplete, Vcl.StdCtrls, Vcl.ComCtrls,
  PGofer.Component.RichEdit,
  PGofer.Component.Form;

type
  TFrmPGofer = class( TFormEx )
    EdtScript: TRichEditEx;
    TryPGofer: TTrayIcon;
    PpmMenu: TPopupMenu;
    PnlCommand: TPanel;
    PnlComandMove: TPanel;
    PnlArrastar: TPanel;
    mniClose: TMenuItem;
    mniN1: TMenuItem;
    mniGlobals: TMenuItem;
    mniTriggers: TMenuItem;
    procedure EdtScriptKeyDown( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure FormCreate( Sender: TObject );
    procedure FormDestroy( Sender: TObject );
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
    procedure FormShow( Sender: TObject );
    procedure FormCloseQuery( Sender: TObject; var CanClose: Boolean );
    procedure PopUpClick( Sender: TObject );
    procedure FormMouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure FormMouseMove( Sender: TObject; Shift: TShiftState;
      X, Y: Integer );
    procedure TryPGoferClick( Sender: TObject );
    procedure EdtScriptChange( Sender: TObject );
  private
    FMouse: TPoint;
    FHotKey_FrmPGofer: ATOM;
    FHotKey_ToggleHook: ATOM;
    FFrmAutoComplete: TFrmAutoComplete;
    procedure FormAutoSize( );
  protected
    procedure CreateWindowHandle( const Params: TCreateParams ); override;
    procedure OnQueryEndSession( var Msg: TWMQueryEndSession );
      message WM_QueryEndSession;
    procedure WndProc( var Message: TMessage ); override;
    procedure WMHotKey( var Message: TWMHotKey ); message WM_HOTKEY;
  public
  end;

var
  FrmPGofer: TFrmPGofer;

implementation

uses
  PGofer.Classes,
  PGofer.Sintatico,
  PGofer.System.Controls,
  PGofer.Forms.Controls, PGofer.Forms.Console,
  PGofer.Triggers.Links, PGofer.Triggers.Tasks,
  PGofer.Triggers.HotKeys.Hook;

{$R *.dfm}
{ TFrmPGofer3 }

procedure TFrmPGofer.CreateWindowHandle( const Params: TCreateParams );
begin
  inherited CreateWindowHandle( Params );
  SetWindowLong( Self.Handle, GWL_STYLE, WS_SIZEBOX );
  SetWindowLong( Self.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW and
    not WS_EX_APPWINDOW );
end;

procedure TFrmPGofer.WMHotKey( var Message: TWMHotKey );
begin

  if message.HotKey = FHotKey_FrmPGofer then
    FrmPGofer.ForceShow( True );

  if message.HotKey = FHotKey_ToggleHook then
  begin
    if THotKeyThread.isEnableHook then
    begin
      THotKeyThread.DisableHook( );
      ConsoleNotify(nil, 'Hook Disable', true, true);
    end else begin
      THotKeyThread.EnableHook( );
      ConsoleNotify(nil, 'Hook Enabled', true, true);
    end;
  end;
end;

procedure TFrmPGofer.WndProc( var Message: TMessage );
begin
  OnMessage( message );
  inherited WndProc( message );
end;

procedure TFrmPGofer.FormCreate( Sender: TObject );
begin
  inherited FormCreate( Sender );
  Self.Constraints.MaxWidth := Screen.DesktopWidth - Self.Left - 10;
  Self.Constraints.MaxHeight := Screen.DesktopHeight - Self.Top - 10;

  FFrmAutoComplete := TFrmAutoComplete.Create( EdtScript );
  FFrmAutoComplete.MemoryNoCtrl := True;
  TPGForm.Create( Self );

  FHotKey_FrmPGofer := GlobalAddAtom( 'FrmPGofer' );
  RegisterHotKey( Self.Handle, FHotKey_FrmPGofer, MOD_WIN or MOD_NOREPEAT, 71 );

  FHotKey_ToggleHook := GlobalAddAtom( 'ToggleHook' );
  RegisterHotKey( Self.Handle, FHotKey_ToggleHook,
    MOD_WIN or MOD_NOREPEAT, 72 );

end;

procedure TFrmPGofer.OnQueryEndSession( var Msg: TWMQueryEndSession );
begin
  TPGTask.Working( 2, True );
  if PGofer.Sintatico.CanOff then
    Msg.Result := 0
  else
    Msg.Result := 1;

  // ?????????????????? fechar todos os forms para salvar tudo
end;

procedure TFrmPGofer.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  TPGTask.Working( 1, True );
  CanClose := PGofer.Sintatico.CanClose;
end;

procedure TFrmPGofer.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  FormAutoSize( );
  inherited FormClose( Sender, Action );
end;

procedure TFrmPGofer.FormDestroy( Sender: TObject );
begin
  FFrmAutoComplete.Free( );
  UnRegisterHotKey( Self.Handle, FHotKey_FrmPGofer );
  inherited FormDestroy( Sender );
end;

procedure TFrmPGofer.FormShow( Sender: TObject );
begin
  FormAutoSize( );
end;

procedure TFrmPGofer.FormAutoSize( );
var
  TextHeight, TextWidth: Integer;
  Counter, AuxLength, MaxLength, IndexMaxLength: Integer;
begin
  MaxLength := 0;
  IndexMaxLength := 0;
  for Counter := 0 to EdtScript.Lines.Count do
  begin
    AuxLength := Length( EdtScript.Lines[ Counter ] );
    if AuxLength > MaxLength then
    begin
      MaxLength := AuxLength;
      IndexMaxLength := Counter;
    end;
  end;

  Canvas.Font.Assign( EdtScript.Font );
  TextWidth := Canvas.TextWidth( EdtScript.Lines[ IndexMaxLength ] );
  Self.ClientWidth := TextWidth + EdtScript.Left + EdtScript.CharWidth * 3;

  MaxLength := Length( EdtScript.Text ) - 1;
  IndexMaxLength := 1;
  for Counter := LowString to MaxLength do
  begin
    if EdtScript.Text[ Counter ] = #13 then
      Inc( IndexMaxLength );
  end;

  TextHeight := IndexMaxLength * EdtScript.CharHeight;
  Self.ClientHeight := TextHeight + 12;

  EdtScript.Perform( WM_VSCROLL, SB_TOP and SB_LEFT, 0 );
end;

procedure TFrmPGofer.EdtScriptChange( Sender: TObject );
begin
  FormAutoSize( );
end;

procedure TFrmPGofer.EdtScriptKeyDown( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  if ( not FFrmAutoComplete.Visible ) and ( Shift = [ ] ) then
    case Key of
      VK_RETURN:
        begin
          if ( EdtScript.Text <> '' ) then
          begin
            ScriptExec( 'Main', EdtScript.Text );
            EdtScript.Clear;

            if FrmConsole.AutoClose then
              Self.Hide;
            Key := 0;
            EdtScript.OnChange( nil );
          end;
        end;

      VK_ESCAPE:
        begin
          Self.Hide;
        end;
    end;
end;

procedure TFrmPGofer.FormMouseDown( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  if Shift = [ ssLeft ] then
  begin
    FMouse.X := Mouse.CursorPos.X - Self.Left;
    FMouse.Y := Mouse.CursorPos.Y - Self.Top;
  end;
end;

procedure TFrmPGofer.FormMouseMove( Sender: TObject; Shift: TShiftState;
  X, Y: Integer );
begin
  if Shift = [ ssLeft ] then
  begin
    Self.Left := Mouse.CursorPos.X - FMouse.X;
    Self.Top := Mouse.CursorPos.Y - FMouse.Y;
  end;
end;

procedure TFrmPGofer.PopUpClick( Sender: TObject );
begin
  ScriptExec( 'MainMenu', TMenuItem( Sender ).Hint );
end;

procedure TFrmPGofer.TryPGoferClick( Sender: TObject );
begin
  FrmPGofer.ForceShow( True );
end;

end.
