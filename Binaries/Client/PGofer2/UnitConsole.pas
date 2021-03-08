unit UnitConsole;

interface

uses
    Vcl.Forms, Vcl.ExtCtrls, SynEdit, Vcl.Controls, Vcl.Buttons,
    System.Classes, Winapi.Windows;

type
  TFrmConsoles = class(TForm)
    PnlConsole: TPanel;
    PnlArrastar: TPanel;
    TmrConsole: TTimer;
    BtnFixed: TSpeedButton;
    PnlArrastar2: TPanel;
    EdtConsole: TSynEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure TmrConsoleTimer(Sender: TObject);
    procedure PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BtnFixedClick(Sender: TObject);
  private
    MouseA : TPoint;
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
  public
    procedure ConsoleClear();
    procedure ConsoleMessage(Texto:String; ShowConsole:Boolean);
  end;

var
    FrmConsoles: TFrmConsoles;

implementation
{$R *.dfm}

uses
    PGofer.Classes, PGofer.Controls, UnitPGofer;

//----------------------------------------------------------------------------//
procedure TFrmConsoles.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited;
    SetWindowLong(Handle, GWL_STYLE,  WS_SIZEBOX); //WS_POPUP or
    SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_NOACTIVATE);
end;
//----------------------------------------------------------------------------//
procedure TFrmConsoles.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    TmrConsole.Enabled:=False;
    //salva config
    IniSaveToFile(Self,  DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmConsoles.FormCreate(Sender: TObject);
begin
    //carrega config
    IniLoadFromFile(Self, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmConsoles.FormKeyPress(Sender: TObject; var Key: Char);
begin
    //fecha o console
    if Key = #27 then
       Close;
end;
//----------------------------------------------------------------------------//
procedure TFrmConsoles.BtnFixedClick(Sender: TObject);
begin
    //trava o console
    TmrConsole.Enabled:= (not BtnFixed.Down);
end;
//----------------------------------------------------------------------------//
procedure TFrmConsoles.TmrConsoleTimer(Sender: TObject);
begin
    try
        //fechar se o mouse estiver fora do form
        if (Mouse.CursorPos.X < Left)
        or (Mouse.CursorPos.Y < Top)
        or (Mouse.CursorPos.X > Left+Width)
        or (Mouse.CursorPos.Y > Top+Height) then
           Close;
     except end;
end;
//----------------------------------------------------------------------------//
procedure TFrmConsoles.PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    if Shift = [ssLeft] then
    begin
        MouseA.X:=Mouse.CursorPos.X - Left;
        MouseA.Y:=Mouse.CursorPos.Y - Top;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmConsoles.PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
    if Shift = [ssLeft] then
    begin
        Left := Mouse.CursorPos.X - MouseA.X;
        Top := Mouse.CursorPos.Y - MouseA.Y;
    end;
end;
//---------------------------------------------------------------------------//
procedure TFrmConsoles.ConsoleClear();
begin
    FrmConsoles.EdtConsole.Clear;
end;
//---------------------------------------------------------------------------//
procedure TFrmConsoles.ConsoleMessage(Texto:String; ShowConsole:Boolean);
begin
    FrmConsoles.EdtConsole.Lines.Add(Texto);
    FrmConsoles.EdtConsole.CaretY := FrmConsoles.EdtConsole.Lines.Capacity;

    if ShowConsole then
    begin
        //ajusta posicao do console
        FrmConsoles.Left := FrmPgofer.Left + FrmPgofer.PnlComandMove.Width;
        FrmConsoles.Top := FrmPGofer.Top + FrmPgofer.Height;
        FormPositionFixed(FrmConsoles);
        FormForceShow(FrmConsoles,False);
        FrmConsoles.TmrConsole.Enabled := False;
        FrmConsoles.TmrConsole.Interval := ConsoleDelay;
        FrmConsoles.TmrConsole.Enabled := (not FrmConsoles.BtnFixed.Down);
    end;
end;
//----------------------------------------------------------------------------//

end.
