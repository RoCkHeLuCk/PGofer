unit PGofer3.Client;

interface

uses
    Winapi.Windows, Winapi.Messages,
    System.SysUtils, System.Variants,
    System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms,
    Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus,
    SynEdit,
    PGofer.Forms,
    PGofer.Form.AutoComplete;

type
    TFrmPGofer = class(TFormEx)
        TryPGofer: TTrayIcon;
        PpmMenu: TPopupMenu;
        PnlCommand: TPanel;
        PnlComandMove: TPanel;
        PnlArrastar: TPanel;
        EdtCommand: TSynEdit;
        mniClose: TMenuItem;
        procedure PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
        procedure PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState;
            X, Y: Integer);
        procedure TryPGoferClick(Sender: TObject);
        procedure EdtCommandChange(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure PopUpClick(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormKeyDown(Sender: TObject; var Key: Word;
            Shift: TShiftState);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
    private
        FMouse: TPoint;
        FFrmAutoComplete: TFrmAutoComplete;
    protected
        procedure CreateWindowHandle(const Params: TCreateParams); override;
        procedure OnQueryEndSession(var Msg: TWMQueryEndSession);
            message WM_QueryEndSession;
        procedure WndProc(var Message: TMessage); override;
    public
    end;

var
    FrmPGofer: TFrmPGofer;

implementation

uses
    PGofer.Sintatico, PGofer.Sintatico.Controls,
    PGofer.Forms.Controls;

{$R *.dfm}
{ TFrmPGofer3 }

procedure TFrmPGofer.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited CreateWindowHandle(Params);
    //SetWindowLong(Self.Handle, GWL_STYLE, WS_SIZEBOX);
    SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW
                                    and not WS_EX_APPWINDOW);
end;

procedure TFrmPGofer.OnQueryEndSession(var Msg: TWMQueryEndSession);
begin
    // ?????????? arrumar isso
    if (false) then
    begin
        Msg.Result := 0;
        if (MessageDlg('Algum programa está tentando desligar o computador' +
            #13 + 'Deseja bloquear o desligamento?', mtConfirmation,
            [mbYes, mbNo], mrYes) = mrYes) then
            Msg.Result := 0
        else
            Msg.Result := 1;
    end
    else
        Msg.Result := 1;
end;

procedure TFrmPGofer.WndProc(var Message: TMessage);
begin
    // OnMessage(Message);
    inherited WndProc(Message);
end;

procedure TFrmPGofer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    inherited;
    //
end;

procedure TFrmPGofer.FormCreate(Sender: TObject);
begin
    inherited;
    Self.Height := 30;
    SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
    Self.Constraints.MaxWidth := Screen.DesktopWidth - Self.Left - 10;
    Self.Constraints.MaxHeight := Screen.DesktopHeight - Self.Top - 10;

    FFrmAutoComplete := TFrmAutoComplete.Create(EdtCommand);
    TPGForm.Create(Self);
    FormCreateMnPopUp(PpmMenu, PopUpClick);
end;

procedure TFrmPGofer.FormDestroy(Sender: TObject);
begin
    FFrmAutoComplete.Free();
    inherited;
end;

procedure TFrmPGofer.FormKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
begin
    if (not FFrmAutoComplete.Visible) and (Shift = []) then
    case Key of
        VK_RETURN:
        begin
            ScriptExec('Main', EdtCommand.Text);
            EdtCommand.Clear;
        end;

        VK_ESCAPE:
        begin
            Self.Visible := false;
        end;
    end;
end;

procedure TFrmPGofer.EdtCommandChange(Sender: TObject);
var
    Counter, AuxLength, MaxLength, IndexMaxLength: Integer;
begin
    // ????????????? arrumar isso.
    // verifica o tamanho horizontal das linhas
    MaxLength := 0;
    IndexMaxLength := 0;
    for Counter := 0 to EdtCommand.Lines.Count do
    begin
        AuxLength := Length(EdtCommand.Lines[Counter]);
        if AuxLength > MaxLength then
        begin
            MaxLength := AuxLength;
            IndexMaxLength := Counter;
        end;
    end;

    // ajusta o pgofer para o maior tamanho
    Self.Width := EdtCommand.Canvas.TextWidth(EdtCommand.Lines[IndexMaxLength] +
        'BBBBBB');
    Self.Height := (EdtCommand.Lines.Count * EdtCommand.LineHeight) +
        EdtCommand.Font.Size * 2;
end;

procedure TFrmPGofer.PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
begin
    if Shift = [ssLeft] then
    begin
        FMouse.X := Mouse.CursorPos.X - Self.Left;
        FMouse.Y := Mouse.CursorPos.Y - Self.Top;
    end;
end;

procedure TFrmPGofer.PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState;
    X, Y: Integer);
begin
    if Shift = [ssLeft] then
    begin
        Self.Left := Mouse.CursorPos.X - FMouse.X;
        Self.Top := Mouse.CursorPos.Y - FMouse.Y;
    end;
end;

procedure TFrmPGofer.PopUpClick(Sender: TObject);
begin
    ScriptExec('MainMenu', TMenuItem(Sender).Hint);
end;

procedure TFrmPGofer.TryPGoferClick(Sender: TObject);
begin
    FormForceShow(FrmPGofer, True);
end;

end.
