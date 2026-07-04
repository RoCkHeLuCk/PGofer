unit PGofer.Forms.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Dialogs,
  PGofer.Classes, PGofer.Forms, PGofer.Component.Edit, PGofer.Item.Frame,
  Pgofer.Component.ComboBox, Pgofer.Component.Checkbox, PGofer.Component.Memo;

type
  TPGFormsFrame = class( TPGItemFrame )
    LblAlphaBlendValue: TLabel;
    LblHeigth: TLabel;
    LblLeft: TLabel;
    LblTop: TLabel;
    LblTransparentColor: TLabel;
    LblWidth: TLabel;
    LblWindowState: TLabel;
    CkbAlphaBlend: TCheckBoxEx;
    UpdAlphaBlendValue: TUpDown;
    CkbEnabled: TCheckBoxEx;
    CkbTransparent: TCheckBoxEx;
    PnlTransparentColor: TPanel;
    CkbVisible: TCheckBoxEx;
    CmbWindowState: TPGComboBox;
    BtnClose: TButton;
    BtnShow: TButton;
    EdtAlphaBlendValue: TEditEx;
    EdtHeigth: TEditEx;
    EdtTop: TEditEx;
    EdtWidth: TEditEx;
    EdtLeft: TEditEx;
    cldTrasparentColor: TColorDialog;
    procedure CkbAlphaBlendClick( Sender: TObject );
    procedure CkbEnabledClick( Sender: TObject );
    procedure CkbTransparentClick( Sender: TObject );
    procedure PnlTransparentColorClick( Sender: TObject );
    procedure CkbVisibleClick( Sender: TObject );
    procedure CmbWindowStateChange( Sender: TObject );
    procedure BtnCloseClick( Sender: TObject );
    procedure BtnShowClick( Sender: TObject );
    procedure EdtAlphaBlendValueAfterValidate(Sender: TObject);
    procedure EdtHeigthAfterValidate(Sender: TObject);
    procedure EdtWidthAfterValidate(Sender: TObject);
    procedure EdtTopAfterValidate(Sender: TObject);
    procedure EdtLeftAfterValidate(Sender: TObject);
  private
  protected
    function GetItem( ): TPGForm; reintroduce;
    property Item: TPGForm read GetItem;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

uses
  System.SysUtils;

{$R *.dfm}
{ TPGFrame1 }

constructor TPGFormsFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  CkbAlphaBlend.SetCheckedSilent( Self.Item.AlphaBlend );
  EdtAlphaBlendValue.SetTextSilent( Self.Item.AlphaBlendValue.ToString() );
  CkbEnabled.SetCheckedSilent( not (pgfDisabled in Self.Item.Flags) );
  EdtHeigth.SetTextSilent( Self.Item.Heigth.ToString() );
  EdtLeft.SetTextSilent( Self.Item.Left.ToString() );
  EdtTop.SetTextSilent( Self.Item.Top.ToString() );
  CkbTransparent.SetCheckedSilent( Self.Item.Transparent );
  PnlTransparentColor.Color := Self.Item.TransparentColor;
  CkbVisible.SetCheckedSilent( Self.Item.Visible );
  EdtWidth.SetTextSilent( Self.Item.Width.ToString() );
  CmbWindowState.SetIndexSilent( Self.Item.WindowState );
end;

destructor TPGFormsFrame.Destroy;
begin
  inherited Destroy( );
end;

procedure TPGFormsFrame.BtnCloseClick( Sender: TObject );
begin
  Self.Item.Close;
end;

procedure TPGFormsFrame.BtnShowClick( Sender: TObject );
begin
  Self.Item.Show( );
end;

procedure TPGFormsFrame.CkbAlphaBlendClick( Sender: TObject );
begin
  if Self.Loading then Exit;
  Self.Item.AlphaBlend := CkbAlphaBlend.Checked;
end;

procedure TPGFormsFrame.CkbEnabledClick( Sender: TObject );
begin
  if Self.Loading then Exit;
  Self.Item.Disabled := not CkbEnabled.Checked;
end;

procedure TPGFormsFrame.CkbTransparentClick( Sender: TObject );
begin
  if Self.Loading then Exit;
  Self.Item.Transparent := CkbTransparent.Checked;
end;

procedure TPGFormsFrame.CkbVisibleClick( Sender: TObject );
begin
  if Self.Loading then Exit;
  Self.Item.Visible := CkbVisible.Checked;
end;

procedure TPGFormsFrame.CmbWindowStateChange( Sender: TObject );
begin
  if Self.Loading then Exit;
  Self.Item.WindowState := CmbWindowState.ItemIndex;
end;

procedure TPGFormsFrame.EdtAlphaBlendValueAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Self.Item.AlphaBlendValue := StrToIntDef( EdtAlphaBlendValue.Text, 0);
end;

procedure TPGFormsFrame.EdtHeigthAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Self.Item.Heigth := StrToIntDef( EdtHeigth.Text , 0);
end;

procedure TPGFormsFrame.EdtLeftAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Self.Item.Left := StrToIntDef( EdtLeft.Text, 0);
end;

procedure TPGFormsFrame.EdtTopAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Self.Item.Top := StrToIntDef( EdtTop.Text, 0);
end;

procedure TPGFormsFrame.EdtWidthAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Self.Item.Width := StrToIntDef( EdtWidth.Text, 0);
end;

function TPGFormsFrame.GetItem: TPGForm;
begin
  Result := TPGForm(inherited Item);
end;

procedure TPGFormsFrame.PnlTransparentColorClick( Sender: TObject );
begin
  cldTrasparentColor.Color := Self.Item.TransparentColor;
  if cldTrasparentColor.Execute( Handle ) then
  begin
    Self.Item.TransparentColor := cldTrasparentColor.Color;
    PnlTransparentColor.Color := cldTrasparentColor.Color;
  end;
end;

end.

