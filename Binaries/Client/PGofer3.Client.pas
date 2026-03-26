unit PGofer3.Client;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.ExtCtrls, Vcl.Menus,
  Vcl.StdCtrls, Vcl.ComCtrls,
  PGofer.Forms,
  PGofer.Component.RichEdit,
  PGofer.Component.Form;

type
  TPGFrmPGofer = class;

  TFrmPGofer = class( TFormEx )
    EdtScript: TRichEditEx;
    TryPGofer: TTrayIcon;
    PpmMenu: TPopupMenu;
    PnlCommand: TPanel;
    PnlComandMove: TPanel;
    mniClose: TMenuItem;
    mniN1: TMenuItem;
    mniGlobals: TMenuItem;
    mniTriggers: TMenuItem;
    shpDrag: TShape;
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
    procedure EdtScriptKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FMouse: TPoint;
    FItem: TPGFrmPGofer;
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
  end;

  {$M+}
  TPGFrmPGofer = class( TPGForm )
  private
    FCanClose: Boolean;
  public
    constructor Create( AForm: TForm ); reintroduce;
    destructor Destroy( ); override;
    procedure Frame( AParent: TObject ); override;
  published
    procedure Close(); override;
    property CanClose: Boolean read FCanClose write FCanClose;
    function GetVersion: string;
  end;
  {$TYPEINFO ON}

var
  FrmPGofer: TFrmPGofer;

implementation

uses
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime, PGofer.Windows,
  PGofer.Forms.Controls, PGofer.Forms.Console, PGofer.Forms.Frame,
  PGofer.Triggers.Tasks,
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
  PBT_APMRESUMEAUTOMATIC = $0012; // Acordou sozinho (Task, Update)
  PBT_APMRESUMESUSPEND   = $0007; // Acordou pelo usuário (Mouse/Teclado/Botão)
begin
  inherited; // Deixa o Windows processar o padrão
  if (Msg.WParam in [PBT_APMRESUMEAUTOMATIC,PBT_APMRESUMESUSPEND]) then
  begin
    ScriptExec( 'MainMessage', 'HotKeyDef.InputRestart;' );
  end;
end;

procedure TFrmPGofer.OnQueryEndSession( var Msg: TWMQueryEndSession );
begin
  if not PGWindows.CanOff then
  begin
    Msg.Result := 0;
    PostMessage(Handle, WM_USER + 101, 0, 0);
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
  FItem := TPGFrmPGofer.Create( Self );
  Self.Caption := 'PGofer V'+ FItem.GetVersion;
  Self.TryPGofer.Hint := Self.Caption;
  Application.Title := Self.Caption;

  Self.Constraints.MaxWidth := Screen.DesktopWidth - Self.Left - 10;
  Self.Constraints.MaxHeight := Screen.DesktopHeight - Self.Top - 10;
end;

procedure TFrmPGofer.FormShow( Sender: TObject );
begin
  Self.FormAutoSize( );
end;

procedure TFrmPGofer.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  TPGTask.Working( 1, True );
  CanClose := FItem.CanClose;
end;

procedure TFrmPGofer.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  TPGGrammar.WaitForAll(5000);
  Self.CloseAllForms();
  FrmAutoComplete.EditCtrlRemove( FrmPGofer.EdtScript );
end;

procedure TFrmPGofer.FormDestroy( Sender: TObject );
begin
  FItem := nil;
end;

procedure TFrmPGofer.CloseAllForms();
var
  I: Integer;
begin
  for I := Screen.FormCount - 1 downto 0 do
  begin
    if Screen.Forms[I] <> Application.MainForm then
      Screen.Forms[I].Close;
  end;
end;

procedure TFrmPGofer.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
     Self.Hide;
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

            if FrmConsole.AutoClose then
              Self.Hide;
            Key := 0;
            EdtScript.OnChange( nil );
          end;
        end;

      VK_ESCAPE:
        begin
          if FrmConsole.Visible then
            FrmConsole.Hide;
          if Self.Visible then
            Self.Hide;
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

constructor TPGFrmPGofer.Create( AForm: TForm );
begin
  inherited Create( AForm );
  FCanClose := True;
end;

destructor TPGFrmPGofer.Destroy( );
begin
  FCanClose := True;
  inherited Destroy( );
end;

procedure TPGFrmPGofer.Frame( AParent: TObject );
begin
  TPGFormsFrame.Create( Self, AParent );
end;

function TPGFrmPGofer.GetVersion(): string;
var
  Size, Dummy: DWORD;
  Buffer: TBytes;
  FixedFileInfo: PVSFixedFileInfo;
  FileInfoLen: UINT;
  FileName : String;
begin
  Result := '0.0.0.0';
  // Pega o nome do executável atual
  FileName := ParamStr(0);
  Size := GetFileVersionInfoSize(PChar(FileName), Dummy);
  if Size > 0 then
  begin
    SetLength(Buffer, Size);
    if GetFileVersionInfo(PChar(FileName), 0, Size, Buffer) then
    begin
      if VerQueryValue(Buffer, '\', Pointer(FixedFileInfo), FileInfoLen) then
      begin
        Result := Format('%d.%d.%d.%d', [
          HiWord(FixedFileInfo.dwFileVersionMS), // Major
          LoWord(FixedFileInfo.dwFileVersionMS), // Minor
          HiWord(FixedFileInfo.dwFileVersionLS), // Release
          LoWord(FixedFileInfo.dwFileVersionLS)  // Build
        ]);
      end;
    end;
  end;
end;


end.
