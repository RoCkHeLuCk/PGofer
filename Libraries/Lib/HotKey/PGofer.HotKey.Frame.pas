unit PGofer.HotKey.Frame;

interface

uses
    System.Classes,
    Winapi.Windows,
    Vcl.Forms, Vcl.StdCtrls, Vcl.Menus, Vcl.Graphics,
    Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
    SynEdit,
    PGofer.Classes, PGofer.HotKey, PGofer.Item.Frame, PGofer.Form.AutoComplete,
    PGofer.Component.Edit;

type
    TPGFrameHotKey = class(TPGFrame)
        PpmNull: TPopupMenu;
        GrbTeclas: TGroupBox;
        MmoTeclas: TMemo;
        BtnClear: TButton;
        LblDetectar: TLabel;
        CmbDetectar: TComboBox;
        CkbInibir: TCheckBox;
        GrbScript: TGroupBox;
        EdtScript: TSynEdit;
        procedure CkbInibirClick(Sender: TObject);
        procedure CmbDetectarChange(Sender: TObject);
        procedure MmoTeclasEnter(Sender: TObject);
        procedure MmoTeclasExit(Sender: TObject);
        procedure BtnClearClick(Sender: TObject);
        procedure EdtNameKeyUp(Sender: TObject; var Key: Word;
          Shift: TShiftState);
        procedure EdtScriptKeyUp(Sender: TObject; var Key: Word;
          Shift: TShiftState);
    private
        FItem: TPGHotKey;
        FFrmAutoComplete: TFrmAutoComplete;
{$HINTS OFF}
        class function LowLevelProc(Code: Integer; wParam: wParam;
          lParam: lParam): NativeInt; stdcall; static;
{$HINTS ON}
    public
        constructor Create(Item: TPGItem; Parent: TObject); reintroduce;
        destructor Destroy(); override;
    end;

var
    PGFrameHotKey: TPGFrameHotKey;

implementation

uses
    PGofer.HotKey.Hook;

{$R *.dfm}
{ TPGFrameHotKey }

class function TPGFrameHotKey.LowLevelProc(Code: Integer; wParam: wParam;
  lParam: lParam): NativeInt;
var
    Key: TKey;
begin
    if Assigned(PGFrameHotKey.FItem) then
    begin
        if (Code = HC_ACTION) then
        begin
            THookProc.CalcVirtualKey(wParam, lParam, Key);
            if Key.wKey > 0 then
            begin
                if Key.bDetect in [kd_Down, kd_Wheel] then
                begin
                    if not(PGFrameHotKey.FItem.Keys.Contains(Key.wKey)) then
                        PGFrameHotKey.FItem.Keys.Add(Key.wKey);
                end;
            end;
        end;

        PGFrameHotKey.MmoTeclas.Lines.Text := PGFrameHotKey.FItem.GetKeysName();
    end;
    Result := CallNextHookEx(0, Code, wParam, lParam);
end;

constructor TPGFrameHotKey.Create(Item: TPGItem; Parent: TObject);
begin
    inherited Create(Item, Parent);
    FItem := TPGHotKey(Item);
    CmbDetectar.ItemIndex := Byte(FItem.Detect);
    CkbInibir.Checked := FItem.Inhibit;
    EdtScript.Text := FItem.Script;
    MmoTeclas.Lines.Text := FItem.GetKeysName();
    FFrmAutoComplete := TFrmAutoComplete.Create(EdtScript);
end;

destructor TPGFrameHotKey.Destroy;
begin
    FFrmAutoComplete.Free();
    MmoTeclas.OnExit(Self);
    FItem := nil;
    inherited Destroy();
end;

procedure TPGFrameHotKey.EdtNameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if FItem.isItemExist(EdtName.Text) then
    begin
        EdtName.Color := clRed;
    end
    else
    begin
        EdtName.Color := clWindow;
        inherited;
    end;
end;

procedure TPGFrameHotKey.EdtScriptKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    FItem.Script := EdtScript.Text;
end;

procedure TPGFrameHotKey.BtnClearClick(Sender: TObject);
begin
    FItem.Keys.Clear;
    MmoTeclas.Clear;
end;

procedure TPGFrameHotKey.CkbInibirClick(Sender: TObject);
begin
    FItem.Inhibit := CkbInibir.Checked;
end;

procedure TPGFrameHotKey.CmbDetectarChange(Sender: TObject);
begin
    FItem.Detect := CmbDetectar.ItemIndex;
end;

procedure TPGFrameHotKey.MmoTeclasEnter(Sender: TObject);
begin
    PGFrameHotKey := Self;
{$IFNDEF DEBUG}
    THookProc.EnableHoot(TPGFrameHotKey.LowLevelProc);
{$ENDIF}
end;

procedure TPGFrameHotKey.MmoTeclasExit(Sender: TObject);
begin
{$IFNDEF DEBUG}
    THookProc.EnableHoot();
{$ENDIF}
end;

end.
