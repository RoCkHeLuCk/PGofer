unit PGofer.Triggers.HotKeys.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Triggers, PGofer.Triggers.Frame, PGofer.Triggers.HotKeys,
  PGofer.Component.RichEdit,
  PGofer.Triggers.HotKeys.Controls, PGofer.Item.Frame, PGofer.Component.Edit;

type
  TPGHotKeyFrame = class( TPGTriggerFrame )
    GrbHotKeys: TGroupBox;
    MmoHotKeys: TMemo;
    BtnClean: TButton;
    LblDetect: TLabel;
    CmbDetect: TComboBox;
    CkbInhibit: TCheckBox;
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
    procedure OnProcessKeys( AParamInput: TParamInput );
    {$HINTS ON}
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    function GetItem( ): TPGHotKey; virtual;
    property Item: TPGHotKey read GetItem;
  public
    constructor Create( AItem: TPGItemTrigger; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGHotKeyFrame: TPGHotKeyFrame;

implementation

uses




  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TPGFrameHotKey }

constructor TPGHotKeyFrame.Create( AItem: TPGItemTrigger; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  CmbDetect.ItemIndex := Item.Detect;
  CkbInhibit.Checked := Item.Inhibit;
  EdtScript.Lines.Text := Item.Script;
  MmoHotKeys.Lines.Text := Item.GetKeysName( );
  FrmAutoComplete.EditCtrlAdd( EdtScript );
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
  Item.Script := EdtScript.Lines.Text;
end;

procedure TPGHotKeyFrame.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  GrbScript.Height := FIniFile.ReadInteger( Self.ClassName, 'Scritp',
    GrbScript.Height );
end;

procedure TPGHotKeyFrame.IniConfigSave;
begin
  FIniFile.WriteInteger( Self.ClassName, 'Scritp', GrbScript.Height );
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
  if Item.Detect = 2 then
  begin
    CkbInhibit.Checked := False;
    CkbInhibit.Enabled := False;
    Item.Inhibit := False;
  end else begin
    CkbInhibit.Enabled := True;
  end;
end;

procedure TPGHotKeyFrame.MmoHotKeysEnter( Sender: TObject );
begin
  PGHotKeyFrame := Self;
  MmoHotKeys.Color := clRed;
  TPGHotKey.SetProcessKeys( OnProcessKeys );
end;

procedure TPGHotKeyFrame.MmoHotKeysExit( Sender: TObject );
begin
  MmoHotKeys.Color := clBtnFace;
  TPGHotKey.SetProcessKeys( nil );
end;

procedure TPGHotKeyFrame.OnProcessKeys( AParamInput: TParamInput );
var
  Key: TKey;
begin
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
    PGHotKeyFrame.MmoHotKeys.Lines.Text := PGHotKeyFrame.Item.GetKeysName( );
  end;
end;

end.
