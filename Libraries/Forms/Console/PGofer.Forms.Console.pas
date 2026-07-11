unit PGofer.Forms.Console;

interface

uses
  System.Classes, Winapi.Windows,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.Controls, Vcl.Buttons,
  Vcl.StdCtrls,
  PGofer.Component.Memo, PGofer.Component.Form, PGofer.Core,
  PGofer.Classes, PGofer.Runtime, PGofer.Forms, Vcl.Menus;

type
  TPGFrmConsole = class;

  TFrmConsole = class( TFormEx )
    PnlConsole: TPanel;
    PnlArrastar: TPanel;
    BtnFixed: TSpeedButton;
    TmrConsole: TTimer;
    EdtConsole: TMemoEx;
    ShpDrag: TShape;
    ppmConsole: TPopupMenu;
    mniCopy: TMenuItem;
    mniSelectAll: TMenuItem;
    mniClear: TMenuItem;
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
    procedure FormKeyPress( Sender: TObject; var Key: Char );
    procedure TmrConsoleTimer( Sender: TObject );
    procedure PnlArrastarMouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure PnlArrastarMouseMove( Sender: TObject; Shift: TShiftState;
      X, Y: Integer );
    procedure BtnFixedClick( Sender: TObject );
    procedure FormShow( Sender: TObject );
    procedure FormCreate( Sender: TObject );
    procedure FormDestroy( Sender: TObject );
    procedure mniCopyClick(Sender: TObject);
    procedure mniSelectAllClick(Sender: TObject);
    procedure mniClearClick(Sender: TObject);
  private
    { Private declarations }
    FMouseA: TPoint;
    FDelay: Cardinal;
    FShowMessage: Boolean;
    FAutoClose: Boolean;
    procedure TimerReset();
    procedure SetDelay(const AValue: Cardinal);
    procedure SetAutoClose(const AValue: Boolean);
  protected
    procedure CreateParams( var AParams: TCreateParams ); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    property AutoClose: Boolean read FAutoClose write SetAutoClose;
    property ShowMessage: Boolean read FShowMessage write FShowMessage;
    property Delay: Cardinal read FDelay write SetDelay;
    procedure ConsoleNotifyMessage(const AValue: string; const ANewLine, AShow: Boolean );
  end;

  {$M+}
  [TPGClassReg('Forms', 'FrmConsole')]
  TPGFrmConsole = class( TPGForm )
  private
    procedure SetAutoClose(const AValue: Boolean );
    procedure SetDelay(const AValue: Cardinal );
    function GetAutoClose: Boolean;
    function GetDelay: Cardinal;
    function GetShowMessage: Boolean;
    procedure SetShowMessage(const AValue: Boolean);
  protected
    class function GetFrameClass(): TPGItemFrameClass; override;
    function GetForm( ): TFrmConsole; reintroduce;
    property Form: TFrmConsole read GetForm;
  public
  published
    property AutoClose: Boolean read GetAutoClose write SetAutoClose;
    procedure Clear( ); reintroduce;
    property Delay: Cardinal read GetDelay write SetDelay;
    property ShowMessage: Boolean read GetShowMessage write SetShowMessage;
  end;
  {$TYPEINFO ON}

var
  FrmConsole: TFrmConsole;

implementation

{$R *.dfm}

uses
  Winapi.Messages,
  System.SysUtils,
  PGofer.Forms.Console.Frame;

{ TFrmConsole }
procedure TFrmConsole.CreateParams( var AParams: TCreateParams );
begin
  inherited;
  AParams.Style := AParams.Style or WS_BORDER;
  AParams.ExStyle := WS_EX_NOACTIVATE;
  Application.AddPopupForm( Self );
  Self.ForceResizable := True;
end;

procedure TFrmConsole.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  SetWindowLong(
    Application.Handle,
    GWL_EXSTYLE, WS_EX_NOACTIVATE
    or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW
  );
end;

procedure TFrmConsole.FormCreate( Sender: TObject );
begin
  FDelay := 2000;
  FShowMessage := True;
  FAutoClose := True;
  TPGKernel.ConsoleNotify := Self.ConsoleNotifyMessage;
end;

procedure TFrmConsole.FormShow( Sender: TObject );
begin
  Self.Left := Application.MainForm.Left;
  Self.Top := Application.MainForm.Top + Application.MainForm.Height;
  Self.TimerReset();
end;

procedure TFrmConsole.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  TmrConsole.Enabled := False;
end;

procedure TFrmConsole.FormDestroy( Sender: TObject );
begin
  TmrConsole.Enabled := False;
  TPGKernel.ConsoleNotify := nil;
  FDelay := 0;
  FShowMessage := False;
  FAutoClose := False;
end;

procedure TFrmConsole.FormKeyPress( Sender: TObject; var Key: Char );
begin
  if Key = #27 then
    Self.Close();
end;

procedure TFrmConsole.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  EdtConsole.Zoom := IniFile.ReadInteger( Self.Name, 'Zoom', EdtConsole.Zoom);
  FDelay := IniFile.ReadInteger( Self.Name, 'Delay', FDelay );
  FShowMessage := IniFile.ReadBool( Self.Name, 'ShowMessage',
    FShowMessage );
  FAutoClose := IniFile.ReadBool( Self.Name, 'AutoClose',
    FAutoClose );
end;

procedure TFrmConsole.IniConfigSave( );
begin
  IniFile.WriteInteger( Self.Name, 'Zoom', EdtConsole.Zoom);
  IniFile.WriteInteger( Self.Name, 'Delay', FDelay );
  IniFile.WriteBool( Self.Name, 'ShowMessage', FShowMessage );
  IniFile.WriteBool( Self.Name, 'AutoClose', FAutoClose );
  inherited IniConfigSave( );
end;

procedure TFrmConsole.mniClearClick(Sender: TObject);
begin
  EdtConsole.Clear;
end;

procedure TFrmConsole.mniCopyClick(Sender: TObject);
begin
  EdtConsole.CopyToClipboard;
end;

procedure TFrmConsole.mniSelectAllClick(Sender: TObject);
begin
  EdtConsole.SelectAll;
end;

procedure TFrmConsole.BtnFixedClick( Sender: TObject );
begin
  // trava o console
  TmrConsole.Enabled := ( not BtnFixed.Down );
  FAutoClose := TmrConsole.Enabled;
end;

procedure TFrmConsole.TimerReset();
begin
  Self.TmrConsole.Interval := FDelay;
  Self.TmrConsole.Enabled := False;
  Self.TmrConsole.Enabled := ( not Self.BtnFixed.Down );
end;

procedure TFrmConsole.TmrConsoleTimer( Sender: TObject );
begin
  // fechar se o mouse estiver fora do form
  if ( ( Mouse.CursorPos.X < Left ) or ( Mouse.CursorPos.Y < Top ) or
    ( Mouse.CursorPos.X > Left + Width ) or ( Mouse.CursorPos.Y > Top + Height )
    ) and ( Self.Visible ) then
    Self.Close;
end;

procedure TFrmConsole.PnlArrastarMouseDown( Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
begin
  Self.TimerReset();
  if Shift = [ ssLeft ] then
  begin
    FMouseA.X := Mouse.CursorPos.X - Left;
    FMouseA.Y := Mouse.CursorPos.Y - Top;
  end;
end;

procedure TFrmConsole.PnlArrastarMouseMove( Sender: TObject; Shift: TShiftState;
  X, Y: Integer );
begin
  Self.TimerReset();
  if Shift = [ ssLeft ] then
  begin
    Self.Left := Mouse.CursorPos.X - FMouseA.X;
    Self.Top := Mouse.CursorPos.Y - FMouseA.Y;
  end;
end;

procedure TFrmConsole.SetAutoClose(const AValue: Boolean);
begin
  FAutoClose := AValue;
  Self.BtnFixed.Down := ( not FAutoClose );
end;

procedure TFrmConsole.SetDelay(const AValue: Cardinal);
begin
  if (AValue > 500) then
     FDelay := AValue;
end;

procedure TFrmConsole.ConsoleNotifyMessage(const AValue: string;
  const ANewLine, AShow: Boolean );
begin
  Self.EdtConsole.Lines.BeginUpdate;
  try
    EdtConsole.SelStart := EdtConsole.GetTextLen;
    EdtConsole.SelLength := 0;

    // WPARAM = 0 (Não permite Undo para economizar memória)
    // LPARAM = Ponteiro para a string
    SendMessage(EdtConsole.Handle, EM_REPLACESEL, 0, LPARAM(PChar(AValue)));

    // 3. Auto-scroll opcional (apenas se o usuário não estiver rolando manualmente)
    SendMessage(EdtConsole.Handle, WM_VSCROLL, SB_BOTTOM, 0);
  finally
    Self.EdtConsole.Lines.EndUpdate;
  end;

  if AShow then
  begin
    Self.TimerReset();
    Self.ForceShow( False );
  end;
end;

{ TPGFrmConsole }

class function TPGFrmConsole.GetFrameClass(): TPGItemFrameClass;
begin
  Result := TPGConsoleFrame;
end;

function TPGFrmConsole.GetAutoClose(): Boolean;
begin
  Result := Self.Form.AutoClose;
end;

function TPGFrmConsole.GetDelay(): Cardinal;
begin
  Result := Self.Form.Delay;
end;

function TPGFrmConsole.GetForm: TFrmConsole;
begin
  Result := TFrmConsole(inherited Form);
end;

function TPGFrmConsole.GetShowMessage(): Boolean;
begin
  Result := Self.Form.ShowMessage;
end;

procedure TPGFrmConsole.SetAutoClose(const AValue: Boolean );
begin
  Self.Form.AutoClose := AValue;
end;

procedure TPGFrmConsole.SetDelay(const AValue: Cardinal);
begin
  Self.Form.Delay := AValue;
end;

procedure TPGFrmConsole.SetShowMessage(const AValue: Boolean);
begin
  Self.Form.ShowMessage := AValue;
end;

procedure TPGFrmConsole.Clear;
begin
  TFrmConsole( Self.Form ).EdtConsole.Clear;
end;

end.
