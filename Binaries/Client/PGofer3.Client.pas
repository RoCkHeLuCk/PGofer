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
    PGofer.Forms.AutoComplete;

type
    TFrmPGofer = class(TFormEx)
        TryPGofer: TTrayIcon;
        PpmMenu: TPopupMenu;
        PnlCommand: TPanel;
        PnlComandMove: TPanel;
        PnlArrastar: TPanel;
        EdtCommand: TSynEdit;
        mniClose: TMenuItem;
        mniN1: TMenuItem;
        mniGlobals: TMenuItem;
        mniTriggers: TMenuItem;
        procedure PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
        procedure PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState;
          X, Y: Integer);
        procedure TryPGoferClick(Sender: TObject);
        procedure EdtCommandChange(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure PopUpClick(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure EdtCommandKeyDown(Sender: TObject; var Key: Word;
          Shift: TShiftState);
        procedure FormShow(Sender: TObject);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormHide(Sender: TObject);
        procedure EdtCommandDropFiles(Sender: TObject; X, Y: Integer;
          AFiles: TStrings);
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
    PGofer.Sintatico,
    PGofer.Forms.Controls, PGofer.Forms.Console,
    PGofer.Triggers.Links, PGofer.Triggers.Tasks;

{$R *.dfm}
{ TFrmPGofer3 }

procedure TFrmPGofer.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited CreateWindowHandle(Params);
    SetWindowLong(Self.Handle, GWL_STYLE, WS_SIZEBOX);
    SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW and
      not WS_EX_APPWINDOW);
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
    OnMessage(Message);
    inherited WndProc(Message);
end;

procedure TFrmPGofer.FormCreate(Sender: TObject);
begin
    inherited;
    Self.Constraints.MaxWidth := Screen.DesktopWidth - Self.Left - 10;
    Self.Constraints.MaxHeight := Screen.DesktopHeight - Self.Top - 10;

    FFrmAutoComplete := TFrmAutoComplete.Create(EdtCommand);
    FFrmAutoComplete.MemoryNoCtrl := True;
    FFrmAutoComplete.DropFiles := false;
    TPGForm.Create(Self);
end;

procedure TFrmPGofer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    TPGTask.Finalizations();
    CanClose := True;
end;

procedure TFrmPGofer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Self.EdtCommandChange(Sender);
    inherited;
end;

procedure TFrmPGofer.FormDestroy(Sender: TObject);
begin
    FFrmAutoComplete.Free();
    inherited;
end;

procedure TFrmPGofer.FormHide(Sender: TObject);
begin
    Self.EdtCommandChange(Sender);
    inherited;
end;

procedure TFrmPGofer.FormShow(Sender: TObject);
begin
    Self.EdtCommandChange(Sender);
    inherited;
end;

procedure TFrmPGofer.EdtCommandChange(Sender: TObject);
var
    TextHeight, TextWidth: Integer;
    Counter, AuxLength, MaxLength, IndexMaxLength: Integer;
begin
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

    TextWidth := EdtCommand.Font.Size;
    TextWidth := (TextWidth * EdtCommand.Lines[IndexMaxLength].Length) +
      TextWidth * 2;
    Self.ClientWidth := TextWidth + EdtCommand.Left + 12;

    TextHeight := EdtCommand.LineHeight;
    if EdtCommand.Lines.Count > 0 then
        TextHeight := TextHeight * EdtCommand.Lines.Count;
    Self.ClientHeight := TextHeight + 12;
end;

procedure TFrmPGofer.EdtCommandDropFiles(Sender: TObject; X, Y: Integer;
  AFiles: TStrings);
begin
    TPGLinkMirror.DropFiles(AFiles);
end;

procedure TFrmPGofer.EdtCommandKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (not FFrmAutoComplete.Visible) and (Shift = []) then
        case Key of
            VK_RETURN:
                begin
                    if (EdtCommand.Text <> '') then
                    begin
                        ScriptExec('Main', EdtCommand.Text);
                        EdtCommand.Clear;

                        if FrmConsole.AutoClose then
                            Self.Hide;
                        Key := 0;
                        EdtCommand.OnChange(nil);
                    end;
                end;

            VK_ESCAPE:
                begin
                    Self.Hide;
                end;
        end;
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
