unit PGofer.Forms.Console;

interface

uses
  System.Classes, Winapi.Windows,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.Controls, Vcl.Buttons,
  PGofer.Forms, Vcl.StdCtrls, Vcl.ComCtrls, PGofer.Component.RichEdit,
  PGofer.Component.Form;

type
  TPGFrmConsole = class;

  TFrmConsole = class( TFormEx )
    PnlConsole: TPanel;
    PnlArrastar: TPanel;
    BtnFixed: TSpeedButton;
    PnlArrastar2: TPanel;
    TmrConsole: TTimer;
    EdtConsole: TRichEditEx;
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
    procedure FormActivate( Sender: TObject );
  private
    { Private declarations }
    FMouseA: TPoint;
    FItem: TPGFrmConsole;
    function GetAutoClose( ): Boolean;
  protected
    procedure CreateParams( var AParams: TCreateParams ); override;
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    property AutoClose: Boolean read GetAutoClose;
    procedure ConsoleNotifyMessage( AThread: TThread; AValue: string;
      ANewLine, AShow: Boolean );
    procedure ForceShow( AFocus: Boolean ); override;
  end;

  {$M+}

  TPGFrmConsole = class( TPGForm )
  private
    FDelay: Cardinal;
    FShowMessage: Boolean;
    FAutoClose: Boolean;
    procedure SetAutoClose( Value: Boolean );
  public
    constructor Create( AForm: TForm ); reintroduce;
    destructor Destroy( ); override;
    procedure Frame( AParent: TObject ); override;
  published
    property AutoClose: Boolean read FAutoClose write SetAutoClose;
    procedure Clear( );
    property Delay: Cardinal read FDelay write FDelay;
    property ShowMessage: Boolean read FShowMessage write FShowMessage;
  end;
  {$TYPEINFO ON}

var
  FrmConsole: TFrmConsole;

implementation

{$R *.dfm}

uses
  Winapi.Messages,
  PGofer.Classes, PGofer.Sintatico, PGofer.Forms.Controls,
  PGofer.Forms.Console.Frame;

{ TFrmConsole }
procedure TFrmConsole.CreateParams( var AParams: TCreateParams );
begin
  inherited;
  AParams.ExStyle := WS_EX_NOACTIVATE;
  Application.AddPopupForm( Self );
  Self.ForceResizable := True;
end;

procedure TFrmConsole.FormCreate( Sender: TObject );
begin
  FItem := TPGFrmConsole.Create( Self );
  PGofer.Sintatico.ConsoleNotify := Self.ConsoleNotifyMessage;
  inherited FormCreate( Sender );
end;

procedure TFrmConsole.FormShow( Sender: TObject );
begin
  Self.TmrConsole.Enabled := False;
  Self.TmrConsole.Interval := FItem.Delay;
  Self.BtnFixed.Down := ( not FItem.AutoClose );
  Self.TmrConsole.Enabled := ( not Self.BtnFixed.Down );
end;

procedure TFrmConsole.ForceShow( AFocus: Boolean );
begin
  FItem.AutoClose := not AFocus;
  inherited ForceShow( AFocus );
end;

procedure TFrmConsole.FormActivate( Sender: TObject );
begin
  // arruma a bagaça para não dar um bug sinistro.
  Width := Width - 1;
  Update;
  Width := Width + 1;
  Update;
end;

procedure TFrmConsole.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  TmrConsole.Enabled := False;
  inherited FormClose( Sender, Action );
end;

procedure TFrmConsole.FormDestroy( Sender: TObject );
begin
  inherited FormDestroy( Sender );
  ConsoleNotify := nil;
  FItem := nil;
end;

procedure TFrmConsole.FormKeyPress( Sender: TObject; var Key: Char );
begin
  // fecha o console
  if Key = #27 then
    Close;
end;

function TFrmConsole.GetAutoClose: Boolean;
begin
  Result := FItem.AutoClose;
end;

procedure TFrmConsole.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  FItem.Delay := FIniFile.ReadInteger( Self.Name, 'Delay', FItem.Delay );
  FItem.ShowMessage := FIniFile.ReadBool( Self.Name, 'ShowMessage',
    FItem.ShowMessage );
  FItem.AutoClose := FIniFile.ReadBool( Self.Name, 'AutoClose',
    FItem.AutoClose );
end;

procedure TFrmConsole.IniConfigSave( );
begin
  FIniFile.WriteInteger( Self.Name, 'Delay', FItem.Delay );
  FIniFile.WriteBool( Self.Name, 'ShowMessage', FItem.ShowMessage );
  FIniFile.WriteBool( Self.Name, 'AutoClose', FItem.AutoClose );
  inherited IniConfigSave( );
end;

procedure TFrmConsole.BtnFixedClick( Sender: TObject );
begin
  // trava o console
  TmrConsole.Enabled := ( not BtnFixed.Down );
  FItem.AutoClose := TmrConsole.Enabled;
end;

procedure TFrmConsole.TmrConsoleTimer( Sender: TObject );
begin
  // fechar se o mouse estiver fora do form
  if ( ( Mouse.CursorPos.X < Left ) or ( Mouse.CursorPos.Y < Top ) or
    ( Mouse.CursorPos.X > Left + Width ) or ( Mouse.CursorPos.Y > Top + Height )
    ) and ( Self.Visible ) then
    Hide;
end;

procedure TFrmConsole.PnlArrastarMouseDown( Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
begin
  if Shift = [ ssLeft ] then
  begin
    FMouseA.X := Mouse.CursorPos.X - Left;
    FMouseA.Y := Mouse.CursorPos.Y - Top;
  end;
end;

procedure TFrmConsole.PnlArrastarMouseMove( Sender: TObject; Shift: TShiftState;
  X, Y: Integer );
begin
  if Shift = [ ssLeft ] then
  begin
    Self.Left := Mouse.CursorPos.X - FMouseA.X;
    Self.Top := Mouse.CursorPos.Y - FMouseA.Y;
  end;
end;

procedure TFrmConsole.ConsoleNotifyMessage( AThread: TThread; AValue: string;
  ANewLine, AShow: Boolean );
begin
  TThread.Synchronize( AThread, procedure
    begin
      if ANewLine then
        Self.EdtConsole.Lines.Append( AValue )
      else
        Self.EdtConsole.Text := Self.EdtConsole.Text + AValue;

      Self.EdtConsole.CaretY := Self.EdtConsole.Lines.Count;

      if AShow then
      begin
        Self.Left := Application.MainForm.Left;
        Self.Top := Application.MainForm.Top + Application.MainForm.Height;
        Self.ForceShow( False );
        Application.ProcessMessages( );
      end;
    end );
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
  TPGFrameConsole.Create( Self, AParent );
end;

procedure TPGFrmConsole.SetAutoClose( Value: Boolean );
begin
  FAutoClose := Value;
  TFrmConsole( FForm ).BtnFixed.Down := ( not FAutoClose );
end;

procedure TPGFrmConsole.Clear;
begin
  TFrmConsole( FForm ).EdtConsole.Clear;
end;

end.
