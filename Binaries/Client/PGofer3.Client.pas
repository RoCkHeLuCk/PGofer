unit PGofer3.Client;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Menus,
  PGofer.Component.Form,
  PGofer.Component.Memo,
  PGofer.Core, PGofer.Classes, PGofer.Forms;

type
  TPGFrmPGofer = class;

  TFrmPGofer = class( TFormEx )
    EdtScript: TMemoEx;
    TryPGofer: TTrayIcon;
    PpmMenu: TPopupMenu;
    PnlCommand: TPanel;
    PnlComandMove: TPanel;
    mniClose: TMenuItem;
    mniN1: TMenuItem;
    mniGlobals: TMenuItem;
    mniTriggers: TMenuItem;
    shpDrag: TShape;
    procedure FormCreate( Sender: TObject );
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
    procedure EdtScriptKeyDown( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtScriptKeyPress(Sender: TObject; var Key: Char);
  private
    FMouse: TPoint;
    FCanClose: Boolean;
    procedure FormAutoSize();
    procedure CloseAllForms();
  protected
    procedure CreateParams( var AParams: TCreateParams ); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure OnQueryEndSession( var Msg: TWMQueryEndSession ); message WM_QUERYENDSESSION;
    procedure OnEndSession(var Msg: TWMEndSession); message WM_ENDSESSION;
    procedure WndProc( var Msg: TMessage ); override;
    procedure WMPowerBroadcast(var Msg: TMessage); message WM_POWERBROADCAST;
  public
    property CanClose: Boolean read FCanClose write FCanClose;
  end;

  {$M+}
  [TPGClassReg('Forms', 'FrmPGofer')]
  TPGFrmPGofer = class( TPGForm )
  private
    function GetCanClose: Boolean;
    procedure SetCanClose(const AValue: Boolean);
  protected
    function GetForm( ): TFrmPGofer; reintroduce;
    property Form: TFrmPGofer read GetForm;
  public
    procedure Frame(const AParent: TObject ); override;
  published
    procedure Close(); override;
    property CanClose: Boolean read GetCanClose write SetCanClose;
    function GetVersion: string;
  end;
  {$TYPEINFO ON}

var
  FrmPGofer: TFrmPGofer;

implementation

uses
  PGofer.Sintatico, PGofer.Runtime, PGofer.Windows,
  PGofer.Forms.Controls, PGofer.Forms.Console, PGofer.Forms.Frame,
  PGofer.Triggers.Tasks, PGofer.Files.Controls,
  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TFrmPGofer3 }

procedure TFrmPGofer.CreateParams( var AParams: TCreateParams );
begin
  inherited;
  AParams.Style := AParams.Style or WS_BORDER;
  AParams.ExStyle := (AParams.ExStyle or WS_EX_TOOLWINDOW) and (not WS_EX_APPWINDOW);
  Self.ForceResizable := True;
end;

procedure TFrmPGofer.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
end;

procedure TFrmPGofer.WndProc( var Msg: TMessage );
begin
  OnMessage( Msg );
  inherited WndProc( Msg );
end;

procedure TFrmPGofer.WMPowerBroadcast(var Msg: TMessage);
const
  PBT_APMRESUMESUSPEND   = $0007;
begin
  inherited;
  if (Msg.WParam = PBT_APMRESUMESUSPEND) then
  begin
    ScriptExec( 'MainMessage', 'HotKeyDef.InputRestart;' );
  end;
end;

procedure TFrmPGofer.OnQueryEndSession( var Msg: TWMQueryEndSession );
begin
  if not PGWindows.CanOff then
  begin
    Msg.Result := 0;
    TPGTask.Working( 2, False );
  end else begin
    Msg.Result := 1;
  end;
end;

procedure TFrmPGofer.OnEndSession(var Msg: TWMEndSession);
begin
  if not PGWindows.CanOff then Exit;
  if Msg.EndSession then
  begin
    Self.CloseAllForms();
  end;
end;

procedure TFrmPGofer.FormCreate( Sender: TObject );
begin
  FCanClose := True;
  Self.Caption := 'PGofer V'+ FileGetVersion( ParamStr(0) );
  Self.TryPGofer.Hint := Self.Caption;
  Application.Title := Self.Caption;

  Self.Constraints.MaxWidth := Screen.DesktopWidth - Self.Left - 10;
  Self.Constraints.MaxHeight := Screen.DesktopHeight - Self.Top - 10;
end;

procedure TFrmPGofer.FormShow( Sender: TObject );
begin
  FCanClose := True;
  Self.FormAutoSize( );
  Self.EdtScript.SetFocus;
end;

procedure TFrmPGofer.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  TPGTask.Working( 1, True );
  CanClose := FCanClose;
end;

procedure TFrmPGofer.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  FrmAutoComplete.EditCtrlRemove( FrmPGofer.EdtScript );
  TPGGrammar.WaitForAll(5000);
  Self.CloseAllForms();
end;

procedure TFrmPGofer.CloseAllForms();
var
  I: Integer;
begin
  for I := Screen.FormCount - 1 downto 0 do
  begin
    if Screen.Forms[I] <> Application.MainForm then
      Screen.Forms[I].Close;
    Application.ProcessMessages;
  end;
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
  for Counter := LOW_STRING to MaxLength do
  begin
    if EdtScript.Text[ Counter ] = #13 then
      Inc( IndexMaxLength );
  end;

  TextHeight := IndexMaxLength * EdtScript.CharHeight;
  Self.ClientHeight := TextHeight + EdtScript.Font.Size;

  EdtScript.Perform( WM_VSCROLL, SB_TOP and SB_LEFT, 0 );
end;

procedure TFrmPGofer.EdtScriptChange( Sender: TObject );
begin
  FormAutoSize( );
end;

procedure TFrmPGofer.EdtScriptKeyDown( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  if ( not FrmAutoComplete.Visible ) and ( Shift = [ ] ) then
  begin
    case Key of
      VK_RETURN:
        begin
          if ( EdtScript.Text <> '' ) then
          begin
            ScriptExec( 'Main', EdtScript.Text );
            EdtScript.Clear;

            if FrmConsole.AutoClose then Self.Hide;
            Key := 0;
          end;
        end;

      VK_ESCAPE:
        begin
          if FrmConsole.Visible then FrmConsole.Hide;
          if Self.Visible then Self.Hide;
          Key := 0;
        end;
    end;
  end;
end;

procedure TFrmPGofer.EdtScriptKeyPress(Sender: TObject; var Key: Char);
begin
  if (EdtScript.Text = '') and CharInSet(Key,['~','`','''','"','^']) then
  begin
    Key := #0;
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

{ TPGFrmPGofer }

procedure TPGFrmPGofer.Close( );
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(200);
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(Form) then
            inherited Close;
        end
      );
    end
  ).Start;
end;

procedure TPGFrmPGofer.Frame(const AParent: TObject );
begin
  TPGFormsFrame.Create( Self, AParent );
end;

function TPGFrmPGofer.GetCanClose: Boolean;
begin
  Result := Self.form.CanClose;
end;

function TPGFrmPGofer.GetForm: TFrmPGofer;
begin
  Result := TFrmPGofer(inherited Form);
end;

function TPGFrmPGofer.GetVersion(): string;
begin
  Result := FileGetVersion( ParamStr(0) );
end;

procedure TPGFrmPGofer.SetCanClose(const AValue: Boolean);
begin
  Self.Form.CanClose := AValue;
end;

end.
