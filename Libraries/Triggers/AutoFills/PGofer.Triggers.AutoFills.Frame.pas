unit PGofer.Triggers.AutoFills.Frame;

interface

uses
  System.Classes, System.SysUtils,

  Vcl.Forms, Vcl.StdCtrls, Vcl.Controls,Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Triggers, PGofer.Triggers.AutoFills, PGofer.Triggers.Frame,
  PGofer.Component.Edit, PGofer.Component.RichEdit, PGofer.Classes,
  Pgofer.Component.ComboBox;

type
  TPGAutoFillsFrame = class( TPGTriggerFrame )
    GrbText: TGroupBox;
    EdtText: TRichEditEx;
    sptScript: TSplitter;
    LblSpeed: TLabel;
    EdtSpeed: TEditEx;
    UpdSpeed: TUpDown;
    LblMode: TLabel;
    CmbMode: TPGComboBox;
    LblDelay: TLabel;
    EdtDelay: TEditEx;
    updDelay: TUpDown;
    Lblmilisec1: TLabel;
    Lblmilisec2: TLabel;
    procedure CmbModeChange(Sender: TObject);
    procedure UpdSpeedChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Integer; Direction: TUpDownDirection);
    procedure EdtTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure updDelayChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Integer;
      Direction: TUpDownDirection);
    procedure EdtDelayAfterValidate(Sender: TObject);
    procedure EdtSpeedAfterValidate(Sender: TObject);
  private
    function GetItem( ): TPGAutoFill;
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    property Item: TPGAutoFill read GetItem;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); override;
    destructor Destroy( ); override;
  end;

implementation

uses
  PGofer.Forms.AutoComplete;

{$R *.dfm}

{ TPGAutoFillsFrame }
constructor TPGAutoFillsFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  EdtText.SetTextSilent( Item.Text );
  CmbMode.SetIndexSilent( Item.Mode );
  EdtSpeed.SetTextSilent( Item.Speed.ToString() );
  EdtDelay.SetTextSilent( Item.Delay.ToString() );
end;

destructor TPGAutoFillsFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtText );
  inherited Destroy( );
end;

function TPGAutoFillsFrame.GetItem: TPGAutoFill;
begin
  Result := TPGAutoFill(FItem);
end;

procedure TPGAutoFillsFrame.EdtDelayAfterValidate(Sender: TObject);
begin
  Item.Delay := StrToInt(EdtDelay.Text);
end;

procedure TPGAutoFillsFrame.updDelayChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Integer; Direction: TUpDownDirection);
begin
  Item.Delay := NewValue;
end;

procedure TPGAutoFillsFrame.UpdSpeedChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection);
begin
  Item.Speed := NewValue;
end;

procedure TPGAutoFillsFrame.EdtSpeedAfterValidate(Sender: TObject);
begin
  Item.Speed := StrToInt(EdtSpeed.Text);
end;

procedure TPGAutoFillsFrame.EdtTextKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Item.Text := EdtText.Text;
end;

procedure TPGAutoFillsFrame.CmbModeChange(Sender: TObject);
begin
  Item.Mode := CmbMode.ItemIndex;
  if Item.Mode = 4 then
  begin
     FrmAutoComplete.EditCtrlAdd( EdtText );
  end else begin
     FrmAutoComplete.EditCtrlRemove( EdtText );
  end;
end;

procedure TPGAutoFillsFrame.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  GrbText.Height := Self.IniFile.ReadInteger( Self.ClassName, 'Text',
    GrbText.Height );
end;

procedure TPGAutoFillsFrame.IniConfigSave;
begin
  Self.IniFile.WriteInteger( Self.ClassName, 'Text', GrbText.Height );
  inherited IniConfigSave( );
end;

end.
