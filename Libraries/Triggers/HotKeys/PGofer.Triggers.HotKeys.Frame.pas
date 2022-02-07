unit PGofer.Triggers.HotKeys.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Menus, Vcl.Graphics,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Item.Frame, PGofer.Triggers.HotKeys,
  PGofer.Component.Edit, PGofer.Component.RichEdit,
  PGofer.Triggers.HotKeys.Controls;

type
  TPGHotKeyFrame = class( TPGItemFrame )
    PpmNull: TPopupMenu;
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
    procedure EdtNameKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtScriptKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
  private
    FItem: TPGHotKey;
    {$HINTS OFF}
    procedure OnProcessKeys( AParamInput: TParamInput );
    {$HINTS ON}
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGHotKeyFrame: TPGHotKeyFrame;

implementation

uses
  Winapi.Messages,
  PGofer.Triggers.HotKeys.Hook,
  PGofer.Triggers.HotKeys.RawInput,
  PGofer.Triggers.HotKeys.Async,
  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TPGFrameHotKey }

constructor TPGHotKeyFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGHotKey( AItem );
  CmbDetect.ItemIndex := FItem.Detect;
  CkbInhibit.Checked := FItem.Inhibit;
  EdtScript.Lines.Text := FItem.Script;
  MmoHotKeys.Lines.Text := FItem.GetKeysName( );
  FrmAutoComplete.EditCtrlAdd( EdtScript );
end;

destructor TPGHotKeyFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtScript );
  MmoHotKeys.OnExit( Self );
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGHotKeyFrame.EdtNameKeyUp( Sender: TObject; var Key: Word;
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

procedure TPGHotKeyFrame.EdtScriptKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Script := EdtScript.Lines.Text;
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
  FItem.Keys.Clear;
  MmoHotKeys.Clear;
end;

procedure TPGHotKeyFrame.CkbInhibitClick( Sender: TObject );
begin
  FItem.Inhibit := CkbInhibit.Checked;
end;

procedure TPGHotKeyFrame.CmbDetectChange( Sender: TObject );
begin
  FItem.Detect := CmbDetect.ItemIndex;
  if FItem.Detect = 2 then
  begin
    CkbInhibit.Checked := False;
    CkbInhibit.Enabled := False;
    FItem.Inhibit := False;
  end else begin
    CkbInhibit.Enabled := True;
  end;
end;

procedure TPGHotKeyFrame.MmoHotKeysEnter( Sender: TObject );
begin
  PGHotKeyFrame := Self;
  MmoHotKeys.Color := clRed;
  case INPUT_TYPE of
    Hook:
      HookInput.SetProcessKeys( OnProcessKeys );
    RAW:
      RawInput.SetProcessKeys( OnProcessKeys );
    Async:
      AsyncInput.SetProcessKeys( OnProcessKeys );
  end;
end;

procedure TPGHotKeyFrame.MmoHotKeysExit( Sender: TObject );
begin
  MmoHotKeys.Color := clBtnFace;
  case INPUT_TYPE of
    Hook:
      HookInput.SetProcessKeys( nil );
    RAW:
      RawInput.SetProcessKeys( nil );
    Async:
      AsyncInput.SetProcessKeys( nil );
  end;
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
      if not( PGHotKeyFrame.FItem.Keys.Contains( Key.wKey ) ) then
      begin
        PGHotKeyFrame.FItem.Keys.Add( Key.wKey );
        PGHotKeyFrame.CkbInhibit.Checked := False;
        PGHotKeyFrame.FItem.Inhibit := False;
      end;
    end;
    PGHotKeyFrame.MmoHotKeys.Lines.Text := PGHotKeyFrame.FItem.GetKeysName( );
  end;
end;

end.
