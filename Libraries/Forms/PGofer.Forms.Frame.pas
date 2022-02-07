unit PGofer.Forms.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Dialogs,
  PGofer.Classes, PGofer.Forms, PGofer.Component.Edit, PGofer.Item.Frame;

type
  TPGFormsFrame = class( TPGItemFrame )
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
    procedure CkbAlphaBlendClick( Sender: TObject );
    procedure CkbEnabledClick( Sender: TObject );
    procedure CkbTransparentClick( Sender: TObject );
    procedure PnlTransparentColorClick( Sender: TObject );
    procedure CkbVisibleClick( Sender: TObject );
    procedure CmbWindowStateChange( Sender: TObject );
    procedure BtnCloseClick( Sender: TObject );
    procedure BtnShowClick( Sender: TObject );
    procedure EdtHeigthKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtTopKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure EdtWidthKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtLeftKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtAlphaBlendValueKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure UpdAlphaBlendValueChangingEx( Sender: TObject;
      var AllowChange: Boolean; NewValue: Integer;
      Direction: TUpDownDirection );
  private
    FItem: TPGForm;
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
  FItem := TPGForm( AItem );
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

destructor TPGFormsFrame.Destroy;
begin
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGFormsFrame.BtnCloseClick( Sender: TObject );
begin
  FItem.Close;
end;

procedure TPGFormsFrame.BtnShowClick( Sender: TObject );
begin
  FItem.Show( );
end;

procedure TPGFormsFrame.CkbAlphaBlendClick( Sender: TObject );
begin
  FItem.AlphaBlend := CkbAlphaBlend.Checked;
end;

procedure TPGFormsFrame.CkbEnabledClick( Sender: TObject );
begin
  FItem.Enabled := CkbEnabled.Checked;
end;

procedure TPGFormsFrame.CkbTransparentClick( Sender: TObject );
begin
  FItem.Transparent := CkbTransparent.Checked;
end;

procedure TPGFormsFrame.CkbVisibleClick( Sender: TObject );
begin
  FItem.Visible := CkbVisible.Checked;
end;

procedure TPGFormsFrame.CmbWindowStateChange( Sender: TObject );
begin
  FItem.WindowState := CmbWindowState.ItemIndex;
end;

procedure TPGFormsFrame.EdtAlphaBlendValueKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.AlphaBlendValue := StrToInt( EdtAlphaBlendValue.Text );
end;

procedure TPGFormsFrame.EdtHeigthKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Heigth := StrToInt( EdtHeigth.Text );
end;

procedure TPGFormsFrame.EdtLeftKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Left := StrToInt( EdtLeft.Text );
end;

procedure TPGFormsFrame.EdtTopKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Top := StrToInt( EdtTop.Text );
end;

procedure TPGFormsFrame.EdtWidthKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Width := StrToInt( EdtWidth.Text );
end;

procedure TPGFormsFrame.PnlTransparentColorClick( Sender: TObject );
begin
  cldTrasparentColor.Color := FItem.TransparentColor;
  if cldTrasparentColor.Execute( Handle ) then
  begin
    FItem.TransparentColor := cldTrasparentColor.Color;
    PnlTransparentColor.Color := cldTrasparentColor.Color;
  end;
end;

procedure TPGFormsFrame.UpdAlphaBlendValueChangingEx( Sender: TObject;
  var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection );
begin
  FItem.AlphaBlendValue := NewValue;
end;

end.
