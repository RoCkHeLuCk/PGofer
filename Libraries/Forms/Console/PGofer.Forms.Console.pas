unit PGofer.Forms.Console;

interface

uses
    System.Classes, Winapi.Windows,
    Vcl.Forms, Vcl.ExtCtrls, Vcl.Controls, Vcl.Buttons,
    SynEdit, PGofer.Forms;

type
    TPGFrmConsole = class;

    TFrmConsole = class(TFormEx)
        PnlConsole: TPanel;
        PnlArrastar: TPanel;
        BtnFixed: TSpeedButton;
        PnlArrastar2: TPanel;
        EdtConsole: TSynEdit;
        TmrConsole: TTimer;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormKeyPress(Sender: TObject; var Key: Char);
        procedure TmrConsoleTimer(Sender: TObject);
        procedure PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
        procedure PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState;
          X, Y: Integer);
        procedure BtnFixedClick(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
    private
        { Private declarations }
        FMouseA: TPoint;
        FItem: TPGFrmConsole;
        function GetAutoClose():Boolean;
    protected
        procedure CreateWindowHandle(const Params: TCreateParams); override;
        procedure IniConfigSave(); override;
        procedure IniConfigLoad(); override;
    public
        property AutoClose: Boolean read GetAutoClose;
        procedure ConsoleNotifyMessage(Value: String; Show: Boolean);
    end;

{$M+}
    TPGFrmConsole = class(TPGForm)
        constructor Create(AForm: TForm); reintroduce;
        destructor Destroy(); override;
    private
        FDelay: Cardinal;
        FShowMessage: Boolean;
        FAutoClose: Boolean;
        procedure SetAutoClose(Value: Boolean);
    public
        procedure Frame(Parent: TObject); override;
    published
        property AutoClose: Boolean read FAutoClose write SetAutoClose;
        procedure Clear();
        property Delay: Cardinal read FDelay write FDelay;
        property ShowMessage: Boolean read FShowMessage write FShowMessage;
    end;
{$TYPEINFO ON}


var
    FrmConsole: TFrmConsole;

implementation

{$R *.dfm}

uses
    PGofer.Classes, PGofer.Sintatico, PGofer.Forms.Controls,
    PGofer.Forms.Console.Frame;

{ TFrmConsole }

procedure TFrmConsole.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited CreateWindowHandle(Params);
    SetWindowLong(Self.Handle, GWL_STYLE, WS_SIZEBOX);
    SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_NOACTIVATE or
                  WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
    Application.AddPopupForm(Self);
end;

procedure TFrmConsole.FormCreate(Sender: TObject);
begin
    FItem := TPGFrmConsole.Create(Self);
    PGofer.Sintatico.ConsoleNotify := Self.ConsoleNotifyMessage;
    inherited;
end;

procedure TFrmConsole.FormShow(Sender: TObject);
begin
    Self.TmrConsole.Enabled := False;
    Self.TmrConsole.Interval := FItem.Delay;
    Self.BtnFixed.Down := (not FItem.AutoClose);
    Self.TmrConsole.Enabled := (not Self.BtnFixed.Down);
end;

procedure TFrmConsole.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    TmrConsole.Enabled := False;
    inherited;
end;

procedure TFrmConsole.FormDestroy(Sender: TObject);
begin
    inherited;
    ConsoleNotify := nil;
    FItem := nil;
end;

procedure TFrmConsole.FormKeyPress(Sender: TObject; var Key: Char);
begin
    // fecha o console
    if Key = #27 then
        Close;
end;

function TFrmConsole.GetAutoClose: Boolean;
begin
    Result := FItem.AutoClose;
end;

procedure TFrmConsole.IniConfigLoad();
begin
    inherited;
    FItem.Delay := FIniFile.ReadInteger(Self.Name, 'Delay', FItem.Delay);
    FItem.ShowMessage := FIniFile.ReadBool(Self.Name, 'ShowMessage',
        FItem.ShowMessage);
    FItem.AutoClose := FIniFile.ReadBool(Self.Name, 'AutoClose', FItem.AutoClose);
end;

procedure TFrmConsole.IniConfigSave();
begin
    FIniFile.WriteInteger(Self.Name, 'Delay', FItem.Delay);
    FIniFile.WriteBool(Self.Name, 'ShowMessage',
        FItem.ShowMessage);
    FIniFile.WriteBool(Self.Name, 'AutoClose', FItem.AutoClose);
    inherited;
end;

procedure TFrmConsole.BtnFixedClick(Sender: TObject);
begin
    // trava o console
    TmrConsole.Enabled := (not BtnFixed.Down);
    FItem.AutoClose := TmrConsole.Enabled;
end;

procedure TFrmConsole.TmrConsoleTimer(Sender: TObject);
begin
    // fechar se o mouse estiver fora do form
    if((Mouse.CursorPos.X < Left)
    or (Mouse.CursorPos.Y < Top)
    or (Mouse.CursorPos.X > Left + Width)
    or (Mouse.CursorPos.Y > Top + Height))
    and (Self.Visible) then
       Hide;
end;

procedure TFrmConsole.PnlArrastarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if Shift = [ssLeft] then
    begin
        FMouseA.X := Mouse.CursorPos.X - Left;
        FMouseA.Y := Mouse.CursorPos.Y - Top;
    end;
end;

procedure TFrmConsole.PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
    if Shift = [ssLeft] then
    begin
        Self.Left := Mouse.CursorPos.X - FMouseA.X;
        Self.Top := Mouse.CursorPos.Y - FMouseA.Y;
    end;
end;

procedure TFrmConsole.ConsoleNotifyMessage(Value: String; Show: Boolean);
begin
    Self.EdtConsole.Lines.Add(Value);
    Self.EdtConsole.CaretY := Self.EdtConsole.Lines.Capacity;

    if Show then
    begin
        // ajusta posicao do console
        Self.Left := Application.MainForm.Left;
        Self.Top := Application.MainForm.Top + Application.MainForm.Height;
        FormForceShow(Self, False);
    end;
end;

{ TPGFrmConsole }
constructor TPGFrmConsole.Create(AForm: TForm);
begin
    inherited;
    FDelay := 2000;
    FShowMessage := True;
    FAutoClose := True;
end;

destructor TPGFrmConsole.Destroy;
begin
    FDelay := 0;
    FShowMessage := False;
    FAutoClose := False;
    inherited;
end;

procedure TPGFrmConsole.Frame(Parent: TObject);
begin
    TPGFrameConsole.Create(Self, Parent);
end;

procedure TPGFrmConsole.SetAutoClose(Value: Boolean);
begin
    FAutoClose := Value;
    TFrmConsole(FForm).BtnFixed.Down := (not FAutoClose);
end;

procedure TPGFrmConsole.Clear;
begin
    TFrmConsole(FForm).EdtConsole.Clear;
end;


end.
