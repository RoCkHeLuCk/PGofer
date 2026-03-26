unit PGofer.Forms.Console;

interface

uses
  System.Classes, Winapi.Windows,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.Controls, Vcl.Buttons,
  Vcl.StdCtrls, Vcl.ComCtrls,
  PGofer.Component.RichEdit, PGofer.Component.Form, PGofer.Forms;

type
  TPGFrmConsole = class;

  TFrmConsole = class( TFormEx )
    PnlConsole: TPanel;
    PnlArrastar: TPanel;
    BtnFixed: TSpeedButton;
    TmrConsole: TTimer;
    EdtConsole: TRichEditEx;
    ShpDrag: TShape;
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
  private
    { Private declarations }
    FMouseA: TPoint;
    FItem: TPGFrmConsole;
    function GetAutoClose( ): Boolean;
    procedure TimerReset();
  protected
    procedure CreateParams( var AParams: TCreateParams ); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    property AutoClose: Boolean read GetAutoClose;
    procedure ConsoleNotifyMessage(const AValue: string;
      const ANewLine, AShow: Boolean );
  end;

  {$M+}
  TPGFrmConsole = class( TPGForm )
  private
    FDelay: Cardinal;
    FShowMessage: Boolean;
    FAutoClose: Boolean;
    procedure SetAutoClose( AValue: Boolean );
    procedure SetDelay( AValue: Cardinal );
  public
    constructor Create( AForm: TForm ); reintroduce;
    destructor Destroy( ); override;
    procedure Frame( AParent: TObject ); override;
  published
    property AutoClose: Boolean read FAutoClose write SetAutoClose;
    procedure Clear( );
    property Delay: Cardinal read FDelay write SetDelay;
    property ShowMessage: Boolean read FShowMessage write FShowMessage;
  end;
  {$TYPEINFO ON}

var
  FrmConsole: TFrmConsole;

implementation

{$R *.dfm}

uses
  Winapi.Messages,
  System.SysUtils,
  PGofer.Core,
  PGofer.Classes,
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
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_NOACTIVATE
                or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
end;

procedure TFrmConsole.FormCreate( Sender: TObject );
begin
  FItem := TPGFrmConsole.Create( Self );
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
  FItem := nil;
end;

procedure TFrmConsole.FormKeyPress( Sender: TObject; var Key: Char );
begin
  if Key = #27 then
    Self.Close();
end;

function TFrmConsole.GetAutoClose: Boolean;
begin
  Result := FItem.AutoClose;
end;

procedure TFrmConsole.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  FItem.Delay := IniFile.ReadInteger( Self.Name, 'Delay', FItem.Delay );
  FItem.ShowMessage := IniFile.ReadBool( Self.Name, 'ShowMessage',
    FItem.ShowMessage );
  FItem.AutoClose := IniFile.ReadBool( Self.Name, 'AutoClose',
    FItem.AutoClose );
end;

procedure TFrmConsole.IniConfigSave( );
begin
  IniFile.WriteInteger( Self.Name, 'Delay', FItem.Delay );
  IniFile.WriteBool( Self.Name, 'ShowMessage', FItem.ShowMessage );
  IniFile.WriteBool( Self.Name, 'AutoClose', FItem.AutoClose );
  inherited IniConfigSave( );
end;

procedure TFrmConsole.BtnFixedClick( Sender: TObject );
begin
  // trava o console
  TmrConsole.Enabled := ( not BtnFixed.Down );
  FItem.AutoClose := TmrConsole.Enabled;
end;

procedure TFrmConsole.TimerReset();
begin
  Self.TmrConsole.Interval := FItem.Delay;
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
constructor TPGFrmConsole.Create( AForm: TForm );
begin
  inherited Create( AForm );
  FDelay := 2000;
  FShowMessage := True;
  FAutoClose := True;
end;

destructor TPGFrmConsole.Destroy( );
begin
  FDelay := 0;
  FShowMessage := False;
  FAutoClose := False;
  inherited Destroy( );
end;

procedure TPGFrmConsole.Frame( AParent: TObject );
begin
  TPGConsoleFrame.Create( Self, AParent );
end;

procedure TPGFrmConsole.SetAutoClose( AValue: Boolean );
begin
  FAutoClose := AValue;
  if Assigned( Self.Form) then
    TFrmConsole( Self.Form ).BtnFixed.Down := ( not FAutoClose );
end;

procedure TPGFrmConsole.SetDelay(AValue: Cardinal);
begin
   if (AValue > 500) then
     FDelay := AValue;
end;

procedure TPGFrmConsole.Clear;
begin
  TFrmConsole( Self.Form ).EdtConsole.Clear;
end;

end.
