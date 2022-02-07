unit PGofer.Triggers.Tasks.Frame;

interface

uses
  System.Classes, System.SysUtils,
  Winapi.Windows,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Menus, Vcl.Graphics,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers.Tasks, PGofer.Item.Frame,
  PGofer.Component.Edit, PGofer.Component.RichEdit;

type
  TPGTaskFrame = class( TPGItemFrame )
    LblTrigger: TLabel;
    CmbTrigger: TComboBox;
    GrbScript: TGroupBox;
    EdtOccurrence: TEditEx;
    updOccurrence: TUpDown;
    lblOccurrence: TLabel;
    EdtScript: TRichEditEx;
    LblRepeat: TLabel;
    EdtRepeat: TEditEx;
    UpdRepeat: TUpDown;
    sptScript: TSplitter;
    procedure CmbTriggerChange( Sender: TObject );
    procedure EdtScriptKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtNameKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtOccurrenceExit( Sender: TObject );
    procedure EdtRepeatKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtOccurrenceKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure UpdRepeatChangingEx( Sender: TObject; var AllowChange: Boolean;
      NewValue: Integer; Direction: TUpDownDirection );
    procedure updOccurrenceChangingEx( Sender: TObject;
      var AllowChange: Boolean; NewValue: Integer;
      Direction: TUpDownDirection );
  private
    FItem: TPGTask;
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

uses
  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TPGTaskFrame }

constructor TPGTaskFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGTask( AItem );
  CmbTrigger.ItemIndex := FItem.Trigger;
  EdtScript.Lines.Text := FItem.Script;
  EdtRepeat.Text := FItem.Repeats.ToString;
  EdtOccurrence.Text := FItem.Occurrence.ToString;
  FrmAutoComplete.EditCtrlAdd( EdtScript );
end;

destructor TPGTaskFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtScript );
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGTaskFrame.EdtNameKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  if FItem.isItemExist( EdtName.Text, True ) then
  begin
    EdtName.Color := clRed;
  end else begin
    EdtName.Color := clWindow;
    inherited EdtNameKeyUp( Sender, Key, Shift );
  end;
end;

procedure TPGTaskFrame.EdtOccurrenceExit( Sender: TObject );
begin
  FItem.Occurrence := StrToInt( EdtOccurrence.Text );
end;

procedure TPGTaskFrame.EdtOccurrenceKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Occurrence := StrToInt( EdtOccurrence.Text );
end;

procedure TPGTaskFrame.EdtRepeatKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Repeats := StrToInt( EdtRepeat.Text );
end;

procedure TPGTaskFrame.EdtScriptKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Script := EdtScript.Lines.Text;
end;

procedure TPGTaskFrame.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  GrbScript.Height := FIniFile.ReadInteger( Self.ClassName, 'Scritp',
    GrbScript.Height );
end;

procedure TPGTaskFrame.IniConfigSave;
begin
  FIniFile.WriteInteger( Self.ClassName, 'Scritp', GrbScript.Height );
  inherited IniConfigSave( );
end;

procedure TPGTaskFrame.updOccurrenceChangingEx( Sender: TObject;
  var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection );
begin
  FItem.Occurrence := NewValue;
end;

procedure TPGTaskFrame.UpdRepeatChangingEx( Sender: TObject;
  var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection );
begin
  FItem.Repeats := NewValue;
end;

procedure TPGTaskFrame.CmbTriggerChange( Sender: TObject );
begin
  FItem.Trigger := CmbTrigger.ItemIndex;
end;

end.
