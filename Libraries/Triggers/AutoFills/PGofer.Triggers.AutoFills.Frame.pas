unit PGofer.Triggers.AutoFills.Frame;

interface

uses
  System.Classes, System.SysUtils,

  Vcl.Forms, Vcl.StdCtrls, Vcl.Controls,Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Triggers.AutoFills, PGofer.Triggers.Frame,
  PGofer.Component.Edit, PGofer.Component.Memo, PGofer.Classes,
  Pgofer.Component.ComboBox;

type
  TPGAutoFillsFrame = class( TPGTriggerFrame )
    GrbText: TGroupBox;
    EdtText: TMemoEx;
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
    procedure EdtTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdtDelayAfterValidate(Sender: TObject);
    procedure EdtSpeedAfterValidate(Sender: TObject);
  private
    procedure ModeChange();
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    function GetItem( ): TPGAutoFill; reintroduce;
    property Item: TPGAutoFill read GetItem;
  public
    constructor Create(const AItem: TPGItem; const AParent: TObject ); override;
    destructor Destroy( ); override;
    procedure SyncData(); override;
  end;

implementation

uses
  PGofer.Forms.AutoComplete;

{$R *.dfm}

{ TPGAutoFillsFrame }
constructor TPGAutoFillsFrame.Create(const AItem: TPGItem; const AParent: TObject );
begin
  inherited Create( AItem, AParent );
end;

destructor TPGAutoFillsFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtText );
  inherited Destroy( );
end;

function TPGAutoFillsFrame.GetItem(): TPGAutoFill;
begin
  Result := TPGAutoFill(inherited Item);
end;

procedure TPGAutoFillsFrame.EdtDelayAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Item.Delay := StrToIntDef(EdtDelay.Text,0);
end;

procedure TPGAutoFillsFrame.EdtSpeedAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Item.Speed := StrToIntDef(EdtSpeed.Text,0);
end;

procedure TPGAutoFillsFrame.EdtTextKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Self.Loading then Exit;
  Item.Text := EdtText.Text;
end;

procedure TPGAutoFillsFrame.CmbModeChange(Sender: TObject);
begin
  if Self.Loading then Exit;
  Item.Mode := CmbMode.ItemIndex;
  Self.ModeChange();
end;

procedure TPGAutoFillsFrame.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  EdtText.Zoom := Self.IniFile.ReadInteger( Self.ClassName, 'TextZoom', EdtText.Zoom );
  GrbText.Height := Self.IniFile.ReadInteger( Self.ClassName, 'Text', GrbText.Height );
end;

procedure TPGAutoFillsFrame.IniConfigSave;
begin
  Self.IniFile.WriteInteger( Self.ClassName, 'TextZoom', EdtText.Zoom );
  Self.IniFile.WriteInteger( Self.ClassName, 'Text', GrbText.Height );
  inherited IniConfigSave( );
end;

procedure TPGAutoFillsFrame.ModeChange();
begin
  if Item.Mode = 4 then
  begin
     FrmAutoComplete.EditCtrlAdd( EdtText );
  end else begin
     FrmAutoComplete.EditCtrlRemove( EdtText );
  end;
end;

procedure TPGAutoFillsFrame.SyncData();
begin
  inherited SyncData();
  EdtText.SetTextSilent( Item.Text );
  CmbMode.SetIndexSilent( Item.Mode );
  EdtSpeed.SetTextSilent( Item.Speed.ToString() );
  EdtDelay.SetTextSilent( Item.Delay.ToString() );
  Self.ModeChange();
end;

end.
