unit PGofer.Forms.Frame;

interface

uses
    System.Classes, System.SysUtils,
    Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls,
    Vcl.ComCtrls,
    PGofer.Classes, PGofer.Forms, PGofer.Item.Frame, Pgofer.Component.Edit;

type
    TPGFrameForms = class(TPGFrame)
    LblAlphaBlendValue: TLabel;
    LblHeigth: TLabel;
    LblLeft: TLabel;
    LblTop: TLabel;
    LblTransparentColor: TLabel;
    LblWidth: TLabel;
    LblWindowState: TLabel;
    CkbAlphaBlend: TCheckBox;
    UpdAlphaBlendValue: TUpDown;
    CkbEnabled: TCheckBox;
    CkbTransparent: TCheckBox;
    PnlTransparentColor: TPanel;
    CkbVisible: TCheckBox;
    CmbWindowState: TComboBox;
    BtnClose: TButton;
    BtnShow: TButton;
    EdtAlphaBlendValue: TEditEx;
    EdtHeigth: TEditEx;
    EdtTop: TEditEx;
    EdtWidth: TEditEx;
    EdtLeft: TEditEx;
    cldTrasparentColor: TColorDialog;
        procedure CkbAlphaBlendClick(Sender: TObject);
        procedure UpdAlphaBlendValueChanging(Sender: TObject;
            var AllowChange: Boolean);
        procedure EdtAlphaBlendValueExit(Sender: TObject);
        procedure CkbEnabledClick(Sender: TObject);
        procedure EdtHeigthExit(Sender: TObject);
        procedure EdtLeftExit(Sender: TObject);
        procedure EdtTopExit(Sender: TObject);
        procedure CkbTransparentClick(Sender: TObject);
        procedure PnlTransparentColorClick(Sender: TObject);
        procedure CkbVisibleClick(Sender: TObject);
        procedure EdtWidthExit(Sender: TObject);
        procedure CmbWindowStateChange(Sender: TObject);
        procedure BtnCloseClick(Sender: TObject);
        procedure BtnShowClick(Sender: TObject);
    private
        FItem: TPGForm;
    public
        constructor Create(Item: TPGItem; Parent: TObject); reintroduce;
        destructor Destroy(); override;
    end;

var
    PGFrameForms: TPGFrameForms;

implementation

{$R *.dfm}
{ TPGFrame1 }

constructor TPGFrameForms.Create(Item: TPGItem; Parent: TObject);
begin
    inherited Create(Item, Parent);
    FItem := TPGForm(Item);
    CkbAlphaBlend.Checked := FItem.AlphaBlend;
    EdtAlphaBlendValue.Text := FItem.AlphaBlendValue.ToString;
    CkbEnabled.Checked := FItem.Enabled;
    EdtHeigth.Text := FItem.Heigth.ToString;
    EdtLeft.Text := FItem.Left.ToString;
    EdtTop.Text := FItem.Top.ToString;
    CkbTransparent.Checked := FItem.Transparent;
    PnlTransparentColor.Color := FItem.TransparentColor;
    CkbVisible.Checked := FItem.Visible;
    EdtWidth.Text := FItem.Width.ToString;
    CmbWindowState.ItemIndex := FItem.WindowState;
end;

destructor TPGFrameForms.Destroy;
begin
    FItem := nil;
    inherited Destroy();
end;

procedure TPGFrameForms.BtnCloseClick(Sender: TObject);
begin
    FItem.Close;
end;

procedure TPGFrameForms.BtnShowClick(Sender: TObject);
begin
    FItem.Show();
end;

procedure TPGFrameForms.CkbAlphaBlendClick(Sender: TObject);
begin
    FItem.AlphaBlend := CkbAlphaBlend.Checked;
end;

procedure TPGFrameForms.CkbEnabledClick(Sender: TObject);
begin
    FItem.Enabled := CkbEnabled.Checked;
end;

procedure TPGFrameForms.CkbTransparentClick(Sender: TObject);
begin
    FItem.Transparent := CkbTransparent.Checked;
end;

procedure TPGFrameForms.CkbVisibleClick(Sender: TObject);
begin
    FItem.Visible := CkbVisible.Checked;
end;

procedure TPGFrameForms.CmbWindowStateChange(Sender: TObject);
begin
    FItem.WindowState := CmbWindowState.ItemIndex;
end;

procedure TPGFrameForms.EdtAlphaBlendValueExit(Sender: TObject);
begin
    FItem.AlphaBlendValue := StrToInt(EdtAlphaBlendValue.Text);
end;

procedure TPGFrameForms.EdtHeigthExit(Sender: TObject);
begin
    FItem.Heigth := StrToInt(EdtHeigth.Text);
end;

procedure TPGFrameForms.EdtLeftExit(Sender: TObject);
begin
    FItem.Left := StrToInt(EdtLeft.Text);
end;

procedure TPGFrameForms.EdtTopExit(Sender: TObject);
begin
    FItem.Top := StrToInt(EdtTop.Text);
end;

procedure TPGFrameForms.EdtWidthExit(Sender: TObject);
begin
    FItem.Width := StrToInt(EdtWidth.Text);
end;

procedure TPGFrameForms.PnlTransparentColorClick(Sender: TObject);
begin
    cldTrasparentColor.Color := FItem.TransparentColor;
    if cldTrasparentColor.Execute(Handle) then
    begin
        FItem.TransparentColor := cldTrasparentColor.Color;
        PnlTransparentColor.Color := cldTrasparentColor.Color;
    end;
end;

procedure TPGFrameForms.UpdAlphaBlendValueChanging(Sender: TObject;
    var AllowChange: Boolean);
begin
    EdtAlphaBlendValueExit(Sender);
end;

end.
