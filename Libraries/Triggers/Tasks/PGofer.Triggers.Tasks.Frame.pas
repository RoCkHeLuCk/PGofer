unit PGofer.Triggers.Tasks.Frame;

interface

uses
  System.Classes, System.SysUtils,

  Vcl.Forms, Vcl.StdCtrls, Vcl.Controls,Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers.Tasks, PGofer.Triggers.Frame,
  PGofer.Component.Edit, PGofer.Component.Memo, Pgofer.Component.ComboBox,
  Pgofer.Component.Checkbox;

type
  TPGTaskFrame = class( TPGTriggerFrame )
    LblTrigger: TLabel;
    LblOccurrence: TLabel;
    LblRepeat: TLabel;
    CmbTrigger: TPGComboBox;
    GrbScript: TGroupBox;
    UpdRepeat: TUpDown;
    EdtOccurrence: TEditEx;
    EdtScript: TMemoEx;
    EdtRepeat: TEditEx;
    sptScript: TSplitter;
    CkbDisabled: TCheckBoxEx;
    procedure CmbTriggerChange( Sender: TObject );
    procedure EdtScriptKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtRepeatAfterValidate(Sender: TObject);
    procedure CkbDisabledClick(Sender: TObject);
  private
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    function GetItem( ): TPGTask; reintroduce;
    property Item: TPGTask read GetItem;
  public
    constructor Create(const AItem: TPGItem; const AParent: TObject ); override;
    destructor Destroy( ); override;
  end;

implementation

uses
  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TPGTaskFrame }

constructor TPGTaskFrame.Create(const AItem: TPGItem; const AParent: TObject );
begin
  inherited Create( AItem, AParent );
  EdtScript.SetTextSilent( Item.Script );
  EdtRepeat.SetTextSilent( Item.Repeats.ToString() );
  EdtOccurrence.SetTextSilent( Item.Occurrence.ToString() );
  CmbTrigger.SetIndexSilent( Item.Trigger );
  CkbDisabled.SetCheckedSilent( Item.Disabled );
  FrmAutoComplete.EditCtrlAdd( EdtScript );
end;

destructor TPGTaskFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtScript );
  inherited Destroy( );
end;

function TPGTaskFrame.GetItem(): TPGTask;
begin
   Result := TPGTask(inherited Item);
end;

procedure TPGTaskFrame.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  EdtScript.Zoom := Self.IniFile.ReadInteger( Self.ClassName, 'ScritpZoom', EdtScript.Zoom );
  GrbScript.Height := Self.IniFile.ReadInteger( Self.ClassName, 'Scritp', GrbScript.Height );
end;

procedure TPGTaskFrame.IniConfigSave;
begin
  Self.IniFile.WriteInteger( Self.ClassName, 'ScritpZoom', EdtScript.Zoom );
  Self.IniFile.WriteInteger( Self.ClassName, 'Scritp', GrbScript.Height );
  inherited IniConfigSave( );
end;

procedure TPGTaskFrame.EdtRepeatAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Item.Repeats := StrToIntDef( EdtRepeat.Text, 0);
end;

procedure TPGTaskFrame.EdtScriptKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  if Self.Loading then Exit;
  Item.Script := EdtScript.Text;
  Self.UpdateStatusBadges();
end;

procedure TPGTaskFrame.CkbDisabledClick(Sender: TObject);
begin
  if Self.Loading then  Exit;
  Item.Disabled := CkbDisabled.Checked;
  Self.UpdateStatusBadges();
end;

procedure TPGTaskFrame.CmbTriggerChange( Sender: TObject );
begin
  if Self.Loading then Exit;
  Item.Trigger := CmbTrigger.ItemIndex;
end;

end.
