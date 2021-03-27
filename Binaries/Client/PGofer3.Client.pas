unit PGofer3.Client;

interface

uses
    Winapi.Windows, Winapi.Messages,
    System.SysUtils, System.Variants,
    System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms,
    Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus,
    PGofer.Forms,
    PGofer.Forms.AutoComplete, Vcl.StdCtrls, Vcl.ComCtrls,
    PGofer.Component.RichEdit;

type
    TFrmPGofer = class(TFormEx)
    EdtScript: TRichEditEx;
    private
        FMouse: TPoint;
        FFrmAutoComplete: TFrmAutoComplete;
    protected
        procedure CreateWindowHandle(const Params: TCreateParams); override;
        procedure OnQueryEndSession(var Msg: TWMQueryEndSession);
          message WM_QueryEndSession;
        procedure WndProc(var Message: TMessage); override;
    public
        TryPGofer: TTrayIcon;
        PpmMenu: TPopupMenu;
        PnlCommand: TPanel;
        PnlComandMove: TPanel;
        PnlArrastar: TPanel;
        mniClose: TMenuItem;
        mniN1: TMenuItem;
        mniGlobals: TMenuItem;
        mniTriggers: TMenuItem;
        procedure EdtScriptKeyDown(Sender: TObject; var Key: Word;
          Shift: TShiftState);
        procedure EdtScriptChange(Sender: TObject);
        procedure EdtScriptDropFiles(Sender: TObject; X, Y: Integer;
          AFiles: TStrings);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormShow(Sender: TObject);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormHide(Sender: TObject);
        procedure PopUpClick(Sender: TObject);
        procedure PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
        procedure PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState;
          X, Y: Integer);
        procedure TryPGoferClick(Sender: TObject);
    end;

var
    FrmPGofer: TFrmPGofer;

implementation

uses
    PGofer.Sintatico,
    PGofer.System.Controls,
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

    FFrmAutoComplete := TFrmAutoComplete.Create(EdtScript);
    FFrmAutoComplete.MemoryNoCtrl := True;
    FFrmAutoComplete.DropFiles := false;
    TPGForm.Create(Self);
end;

procedure TFrmPGofer.OnQueryEndSession(var Msg: TWMQueryEndSession);
begin
    TPGTask.Working(2, True);
    if PGofer.Sintatico.CanOff then
        Msg.Result := 0
    else
        Msg.Result := 1;
end;

procedure TFrmPGofer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    TPGTask.Working(1, True);
    CanClose := PGofer.Sintatico.CanClose;
end;

procedure TFrmPGofer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Self.EdtScriptChange(Sender);
    inherited;
end;

procedure TFrmPGofer.FormDestroy(Sender: TObject);
begin
    FFrmAutoComplete.Free();
    inherited;
end;

procedure TFrmPGofer.FormHide(Sender: TObject);
begin
    Self.EdtScriptChange(Sender);
    inherited;
end;

procedure TFrmPGofer.FormShow(Sender: TObject);
begin
    Self.EdtScriptChange(Sender);
    inherited;
end;

procedure TFrmPGofer.EdtScriptChange(Sender: TObject);
var
    TextHeight, TextWidth: Integer;
    Counter, AuxLength, MaxLength, IndexMaxLength: Integer;
begin
    MaxLength := 0;
    IndexMaxLength := 0;
    for Counter := 0 to EdtScript.Lines.Count do
    begin
        AuxLength := Length(EdtScript.Lines[Counter]);
        if AuxLength > MaxLength then
        begin
            MaxLength := AuxLength;
            IndexMaxLength := Counter;
        end;
    end;

    TextWidth := EdtScript.Font.Size;
    TextWidth := (TextWidth * EdtScript.Lines[IndexMaxLength].Length) +
      TextWidth * 2;
    Self.ClientWidth := TextWidth + EdtScript.Left + 12;

    TextHeight := EdtScript.Font.Size;
    if EdtScript.Lines.Count > 0 then
        TextHeight := TextHeight * EdtScript.Lines.Count;
    Self.ClientHeight := TextHeight + 12;
end;

procedure TFrmPGofer.EdtScriptDropFiles(Sender: TObject; X, Y: Integer;
  AFiles: TStrings);
begin
    TPGLinkMirror.DropFiles(AFiles);
end;

procedure TFrmPGofer.EdtScriptKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (not FFrmAutoComplete.Visible) and (Shift = []) then
        case Key of
            VK_RETURN:
                begin
                    if (EdtScript.Text <> '') then
                    begin
                        ScriptExec('Main', EdtScript.Text);
                        EdtScript.Clear;

                        if FrmConsole.AutoClose then
                            Self.Hide;
                        Key := 0;
                        EdtScript.OnChange(nil);
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
