unit PGofer.Triggers.Tasks.Frame;

interface

uses
  System.Classes, System.SysUtils,

  Vcl.Forms, Vcl.StdCtrls, Vcl.Controls,Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers, PGofer.Triggers.Tasks, PGofer.Triggers.Frame,
  PGofer.Component.Edit, PGofer.Component.RichEdit, Pgofer.Component.ComboBox;

type
  TPGTaskFrame = class( TPGTriggerFrame )
    LblTrigger: TLabel;
    LblOccurrence: TLabel;
    LblRepeat: TLabel;
    CmbTrigger: TPGComboBox;
    GrbScript: TGroupBox;
    UpdOccurrence: TUpDown;
    UpdRepeat: TUpDown;
    EdtOccurrence: TEditEx;
    EdtScript: TRichEditEx;
    EdtRepeat: TEditEx;
    sptScript: TSplitter;
    procedure CmbTriggerChange( Sender: TObject );
    procedure EdtScriptKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure UpdRepeatChangingEx( Sender: TObject; var AllowChange: Boolean;
      NewValue: Integer; Direction: TUpDownDirection );
    procedure UpdOccurrenceChangingEx( Sender: TObject;
      var AllowChange: Boolean; NewValue: Integer;
      Direction: TUpDownDirection );
    procedure EdtRepeatAfterValidate(Sender: TObject);
    procedure EdtOccurrenceAfterValidate(Sender: TObject);
  private
    function GetItem( ): TPGTask;
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    property Item: TPGTask read GetItem;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); override;
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
  EdtScript.SetTextSilent( Item.Script );
  EdtRepeat.SetTextSilent( Item.Repeats.ToString() );
  EdtOccurrence.SetTextSilent( Item.Occurrence.ToString() );
  CmbTrigger.SetIndexSilent( Item.Trigger );
  FrmAutoComplete.EditCtrlAdd( EdtScript );
end;

destructor TPGTaskFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtScript );
  inherited Destroy( );
end;

function TPGTaskFrame.GetItem(): TPGTask;
begin
   Result := TPGTask( FItem );
end;

procedure TPGTaskFrame.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  GrbScript.Height := Self.IniFile.ReadInteger( Self.ClassName, 'Scritp',
    GrbScript.Height );
end;

procedure TPGTaskFrame.IniConfigSave;
begin
  Self.IniFile.WriteInteger( Self.ClassName, 'Scritp', GrbScript.Height );
  inherited IniConfigSave( );
end;

procedure TPGTaskFrame.EdtOccurrenceAfterValidate(Sender: TObject);
begin
  Item.Occurrence := StrToInt( EdtOccurrence.Text );
end;

procedure TPGTaskFrame.EdtRepeatAfterValidate(Sender: TObject);
begin
  Item.Repeats := StrToInt( EdtRepeat.Text );
end;

procedure TPGTaskFrame.EdtScriptKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  Item.Script := EdtScript.Text;
end;

procedure TPGTaskFrame.UpdOccurrenceChangingEx( Sender: TObject;
  var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection );
begin
  Item.Occurrence := NewValue;
end;

procedure TPGTaskFrame.UpdRepeatChangingEx( Sender: TObject;
  var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection );
begin
  Item.Repeats := NewValue;
end;

procedure TPGTaskFrame.CmbTriggerChange( Sender: TObject );
begin
  Item.Trigger := CmbTrigger.ItemIndex;
end;

end.
