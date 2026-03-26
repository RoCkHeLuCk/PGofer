unit PGofer.Triggers.HotKeys.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Triggers, PGofer.Triggers.Frame, PGofer.Triggers.HotKeys,
  PGofer.Component.RichEdit,
  PGofer.Triggers.HotKeys.Controls, PGofer.Item.Frame, PGofer.Component.Edit,
  PGofer.Classes, Pgofer.Component.Checkbox, Pgofer.Component.ComboBox;

type
  TPGHotKeyFrame = class( TPGTriggerFrame )
    GrbHotKeys: TGroupBox;
    MmoHotKeys: TMemo;
    BtnClean: TButton;
    LblDetect: TLabel;
    CmbDetect: TPGComboBox;
    CkbInhibit: TCheckBoxEx;
    GrbScript: TGroupBox;
    EdtScript: TRichEditEx;
    sptScript: TSplitter;
    procedure CkbInhibitClick( Sender: TObject );
    procedure CmbDetectChange( Sender: TObject );
    procedure MmoHotKeysEnter( Sender: TObject );
    procedure MmoHotKeysExit( Sender: TObject );
    procedure BtnCleanClick( Sender: TObject );
    procedure EdtScriptKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
  private
    {$HINTS OFF}
    function OnProcessKeys(AParamInput: TParamInput): Boolean;
    {$HINTS ON}
    function GetItem( ): TPGHotKey;
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    property Item: TPGHotKey read GetItem;
    procedure InhibitToogle();
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); override;
    destructor Destroy( ); override;
  end;

var
  PGHotKeyFrame: TPGHotKeyFrame;

implementation

uses
  Winapi.Windows,
  PGofer.Core,
  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TPGFrameHotKey }

constructor TPGHotKeyFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  CmbDetect.SetIndexSilent( Item.Detect );
  CkbInhibit.SetCheckedSilent( Item.Inhibit );
  EdtScript.SetTextSilent( Item.Script );
  MmoHotKeys.Lines.Text := Item.GetKeysName( );
  FrmAutoComplete.EditCtrlAdd( EdtScript );
  Self.InhibitToogle();
  CkbInhibit.Hint := TPGKernel.Translate('Hint_HotKey_InhibitSupport');
end;

destructor TPGHotKeyFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtScript );
  MmoHotKeys.OnExit( Self );
  inherited Destroy( );
end;

function TPGHotKeyFrame.GetItem: TPGHotKey;
begin
  Result := TPGHotKey(FItem);
end;

procedure TPGHotKeyFrame.EdtScriptKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  Item.Script := EdtScript.Text;
end;

procedure TPGHotKeyFrame.InhibitToogle();
var
  LVisible: Boolean;
begin
  LVisible := ((TPGHotKey.GetInputType = 2) and (Item.Detect = 1));
  CkbInhibit.Checked := LVisible;
  CkbInhibit.Enabled := LVisible;
  CkbInhibit.ShowHint := not LVisible;
end;

procedure TPGHotKeyFrame.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  GrbScript.Height := Self.IniFile.ReadInteger( Self.ClassName, 'Scritp',
    GrbScript.Height );
end;

procedure TPGHotKeyFrame.IniConfigSave;
begin
  Self.IniFile.WriteInteger( Self.ClassName, 'Scritp', GrbScript.Height );
  inherited IniConfigSave( );
end;

procedure TPGHotKeyFrame.BtnCleanClick( Sender: TObject );
begin
  Item.Keys.Clear;
  MmoHotKeys.Clear;
end;

procedure TPGHotKeyFrame.CkbInhibitClick( Sender: TObject );
begin
  Item.Inhibit := CkbInhibit.Checked;
end;

procedure TPGHotKeyFrame.CmbDetectChange( Sender: TObject );
begin
  Item.Detect := CmbDetect.ItemIndex;
  Self.InhibitToogle();
end;

procedure TPGHotKeyFrame.MmoHotKeysEnter( Sender: TObject );
begin
  PGHotKeyFrame := Self;
  MmoHotKeys.Color := clWhite;
  TPGHotKey.SetProcessKeys( OnProcessKeys );
end;

procedure TPGHotKeyFrame.MmoHotKeysExit( Sender: TObject );
begin
  MmoHotKeys.Color := clSilver;
  TPGHotKey.SetProcessKeys( nil );
end;

function TPGHotKeyFrame.OnProcessKeys( AParamInput: TParamInput ): Boolean;
var
  Key: TKey;
begin
  Result := False;
  Key := TKey.CalcVirtualKey( AParamInput );
  if Key.wKey > 0 then
  begin
    if Key.bDetect in [ kd_Down, kd_Wheel ] then
    begin
      if not( PGHotKeyFrame.Item.Keys.Contains( Key.wKey ) ) then
      begin
        PGHotKeyFrame.Item.Keys.Add( Key.wKey );
        PGHotKeyFrame.CkbInhibit.Checked := False;
        PGHotKeyFrame.Item.Inhibit := False;
      end;
    end;
    PGHotKeyFrame.MmoHotKeys.Text := PGHotKeyFrame.Item.GetKeysName( );
    Result := True;
  end;
end;

end.
