unit PGofer.Triggers.HotKeys.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Menus, Vcl.Graphics,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Item.Frame, PGofer.Triggers.HotKeys,
  PGofer.Forms.AutoComplete,
  PGofer.Component.Edit, PGofer.Component.RichEdit,
  PGofer.Triggers.HotKeys.Controls;

type
  TPGFrameHotKey = class( TPGFrame )
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
    FFrmAutoComplete: TFrmAutoComplete;
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
  PGFrameHotKey: TPGFrameHotKey;

implementation

uses
  Winapi.Messages,
  PGofer.Triggers.HotKeys.Hook,
  PGofer.Triggers.HotKeys.RawInput,
  PGofer.Triggers.HotKeys.Async;

{$R *.dfm}
{ TPGFrameHotKey }

constructor TPGFrameHotKey.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGHotKey( AItem );
  CmbDetect.ItemIndex := FItem.Detect;
  CkbInhibit.Checked := FItem.Inhibit;
  EdtScript.Lines.Text := FItem.Script;
  MmoHotKeys.Lines.Text := FItem.GetKeysName( );
  FFrmAutoComplete := TFrmAutoComplete.Create( EdtScript );
end;

destructor TPGFrameHotKey.Destroy;
begin
  FFrmAutoComplete.Free( );
  MmoHotKeys.OnExit( Self );
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGFrameHotKey.EdtNameKeyUp( Sender: TObject; var Key: Word;
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

procedure TPGFrameHotKey.EdtScriptKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Script := EdtScript.Lines.Text;
end;

procedure TPGFrameHotKey.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  GrbScript.Height := FIniFile.ReadInteger( Self.ClassName, 'Scritp',
    GrbScript.Height );
end;

procedure TPGFrameHotKey.IniConfigSave;
begin
  FIniFile.WriteInteger( Self.ClassName, 'Scritp', GrbScript.Height );
  inherited IniConfigSave( );
end;

procedure TPGFrameHotKey.BtnCleanClick( Sender: TObject );
begin
  FItem.Keys.Clear;
  MmoHotKeys.Clear;
end;

procedure TPGFrameHotKey.CkbInhibitClick( Sender: TObject );
begin
  FItem.Inhibit := CkbInhibit.Checked;
end;

procedure TPGFrameHotKey.CmbDetectChange( Sender: TObject );
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

procedure TPGFrameHotKey.MmoHotKeysEnter( Sender: TObject );
begin
  PGFrameHotKey := Self;
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

procedure TPGFrameHotKey.MmoHotKeysExit( Sender: TObject );
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

procedure TPGFrameHotKey.OnProcessKeys( AParamInput: TParamInput );
var
  Key: TKey;
begin
  Key := TKey.CalcVirtualKey( AParamInput );
  if Key.wKey > 0 then
  begin
    if Key.bDetect in [ kd_Down, kd_Wheel ] then
    begin
      if not( PGFrameHotKey.FItem.Keys.Contains( Key.wKey ) ) then
      begin
        PGFrameHotKey.FItem.Keys.Add( Key.wKey );
        PGFrameHotKey.CkbInhibit.Checked := False;
        PGFrameHotKey.FItem.Inhibit := False;
      end;
    end;
    PGFrameHotKey.MmoHotKeys.Lines.Text := PGFrameHotKey.FItem.GetKeysName( );
  end;
end;

end.
