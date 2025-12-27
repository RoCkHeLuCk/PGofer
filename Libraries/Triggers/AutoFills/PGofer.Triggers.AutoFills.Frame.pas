unit PGofer.Triggers.AutoFills.Frame;

interface

uses
  System.Classes, System.SysUtils,
  Winapi.Windows,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Controls,Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Triggers, PGofer.Triggers.AutoFills, PGofer.Triggers.Frame,
  PGofer.Component.Edit, PGofer.Component.RichEdit;

type
  TPGAutoFillsFrame = class( TPGTriggerFrame )
    GrbText: TGroupBox;
    EdtText: TRichEditEx;
    sptScript: TSplitter;
    LblSpeed: TLabel;
    EdtSpeed: TEditEx;
    UpdSpeed: TUpDown;
    LblMode: TLabel;
    CmbMode: TComboBox;
    LblDelay: TLabel;
    EdtDelay: TEditEx;
    updDelay: TUpDown;
    Lblmilisec1: TLabel;
    Lblmilisec2: TLabel;
    procedure CmbModeChange(Sender: TObject);
    procedure EdtSpeedKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UpdSpeedChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Integer; Direction: TUpDownDirection);
    procedure EdtTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdtDelayKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure updDelayChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Integer;
      Direction: TUpDownDirection);
  private
    FItem: TPGAutoFills;
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    constructor Create( AItem: TPGItemTrigger; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

uses
  PGofer.Forms.AutoComplete;

{$R *.dfm}

{ TPGAutoFillsFrame }
constructor TPGAutoFillsFrame.Create( AItem: TPGItemTrigger; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGAutoFills( AItem );
  EdtText.Lines.Text := FItem.Text;
  CmbMode.ItemIndex := FItem.Mode;
  EdtSpeed.Text := FItem.Speed.ToString();
end;

destructor TPGAutoFillsFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtText );
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGAutoFillsFrame.EdtDelayKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FItem.Delay := StrToInt(EdtDelay.Text);
end;

procedure TPGAutoFillsFrame.updDelayChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Integer; Direction: TUpDownDirection);
begin
  FItem.Delay := NewValue;
end;

procedure TPGAutoFillsFrame.UpdSpeedChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection);
begin
  FItem.Speed := NewValue;
end;

procedure TPGAutoFillsFrame.EdtSpeedKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FItem.Speed := StrToInt(EdtSpeed.Text);
end;

procedure TPGAutoFillsFrame.EdtTextKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FItem.Text := EdtText.Lines.Text;
end;

procedure TPGAutoFillsFrame.CmbModeChange(Sender: TObject);
begin
  FItem.Mode := CmbMode.ItemIndex;
  if FItem.Mode = 4 then
  begin
     FrmAutoComplete.EditCtrlAdd( EdtText );
  end else begin
     FrmAutoComplete.EditCtrlRemove( EdtText );
  end;
end;

procedure TPGAutoFillsFrame.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  GrbText.Height := FIniFile.ReadInteger( Self.ClassName, 'Text',
    GrbText.Height );
end;

procedure TPGAutoFillsFrame.IniConfigSave;
begin
  FIniFile.WriteInteger( Self.ClassName, 'Text', GrbText.Height );
  inherited IniConfigSave( );
end;

end.
