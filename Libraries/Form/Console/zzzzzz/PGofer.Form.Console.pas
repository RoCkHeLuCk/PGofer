unit PGofer.Form.Console;

interface

uses
    Vcl.Forms, Vcl.ExtCtrls, SynEdit, Vcl.Controls, Vcl.Buttons,
    System.Classes, Winapi.Windows;

type
    TFrmConsole = class(TForm)
        PnlConsole: TPanel;
        PnlArrastar: TPanel;
        TmrConsole: TTimer;
        BtnFixed: TSpeedButton;
        PnlArrastar2: TPanel;
        EdtConsole: TSynEdit;
        constructor Create(AOwner: TComponent); reintroduce;
        destructor Destroy(); override;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormKeyPress(Sender: TObject; var Key: Char);
        procedure TmrConsoleTimer(Sender: TObject);
        procedure PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
        procedure PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState;
            X, Y: Integer);
        procedure BtnFixedClick(Sender: TObject);
    private
        FMouseA: TPoint;
    protected
        procedure CreateWindowHandle(const Params: TCreateParams); override;
    public
        procedure ConsoleClear();
        procedure ConsoleMessage(Texto: String; ShowConsole: Boolean = True);
    end;

implementation

{$R *.dfm}

uses
    PGofer.Classes, PGofer.Sintatico, PGofer.Forms.Controls;

constructor TFrmConsole.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    Self.Parent := TWinControl(AOwner);
    // carrega config
    FormIniLoadFromFile(Self, PGofer.Sintatico.DirCurrent + 'Config.ini');
end;

procedure TFrmConsole.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited CreateWindowHandle(Params);
    // sem borda e ajustavel
    SetWindowLong(Self.Handle, GWL_STYLE, WS_SIZEBOX); // WS_POPUP or
    // configura a janela para não aparecer na barra e não ativado.
    SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_NOACTIVATE or
        WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
    // adiciona como popup
    Application.AddPopupForm(Self);
end;

destructor TFrmConsole.Destroy;
begin
    inherited Destroy();
end;

procedure TFrmConsole.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    TmrConsole.Enabled := False;
    // salva config
    FormIniSaveToFile(Self, PGofer.Sintatico.DirCurrent + 'Config.ini');
end;

procedure TFrmConsole.FormKeyPress(Sender: TObject; var Key: Char);
begin
    // fecha o console
    if Key = #27 then
        Close;
end;

procedure TFrmConsole.BtnFixedClick(Sender: TObject);
begin
    // trava o console
    TmrConsole.Enabled := (not BtnFixed.Down);
end;

procedure TFrmConsole.TmrConsoleTimer(Sender: TObject);
begin
    try
        // fechar se o mouse estiver fora do form
        if (Mouse.CursorPos.X < Left) or (Mouse.CursorPos.Y < Top) or
           (Mouse.CursorPos.X > Left + Width) or
           (Mouse.CursorPos.Y > Top + Height) then
           Close;
    except
    end;
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
        Left := Mouse.CursorPos.X - FMouseA.X;
        Top := Mouse.CursorPos.Y - FMouseA.Y;
    end;
end;

procedure TFrmConsole.ConsoleClear();
begin
    Self.EdtConsole.Clear;
end;

procedure TFrmConsole.ConsoleMessage(Texto: String; ShowConsole: Boolean = True);
begin
    Self.EdtConsole.Lines.Add(Texto);
    Self.EdtConsole.CaretY := Self.EdtConsole.Lines.Capacity;

    if ShowConsole then
    begin
        // ajusta posicao do console
        Self.Left := TForm(Self.Parent).Left + 10;
        Self.Top := TForm(Self.Parent).Top + TForm(Self.Parent).Height;
        FormPositionFixed(Self);
        FormForceShow(Self, False);
        Self.TmrConsole.Enabled := False;
        Self.TmrConsole.Interval := PGofer.Sintatico.ConsoleDelay;
        Self.TmrConsole.Enabled := (not Self.BtnFixed.Down);
    end;
end;

end.
