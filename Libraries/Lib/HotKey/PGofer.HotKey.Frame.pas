unit PGofer.HotKey.Frame;

interface

uses
    Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, Vcl.Menus,
    Winapi.Windows,
    System.Classes,
    SynEdit,
    PGofer.Classes, PGofer.HotKey.Hook, PGofer.HotKey, PGofer.Item.Frame,
    PGofer.Component.Edit, Vcl.ExtCtrls, Vcl.ComCtrls;

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
        procedure EdtScriptChange(Sender: TObject);
    private
        FItem: TPGHotKeys;
        class function LowLevelProc(Code: Integer; wParam: wParam;
            lParam: lParam): NativeInt; stdcall; static;
    public
        constructor Create(Item: TPGItem; Parent: TObject); reintroduce;
        destructor Destroy(); override;
    end;

var
    PGFrameHotKey: TPGFrameHotKey;

implementation

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
                    if not (PGFrameHotKey.FItem.Keys.Contains(Key.wKey)) then
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
    FItem := TPGHotKeys(Item);
    CmbDetectar.ItemIndex := Byte(FItem.Detect);
    CkbInibir.Checked := FItem.Inhibit;
    EdtScript.Text := FItem.Script;
    MmoTeclas.Lines.Text := FItem.GetKeysName();
end;

destructor TPGFrameHotKey.Destroy;
begin
    MmoTeclas.OnExit(Self);
    FItem := nil;
    inherited Destroy();
end;

procedure TPGFrameHotKey.EdtScriptChange(Sender: TObject);
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
