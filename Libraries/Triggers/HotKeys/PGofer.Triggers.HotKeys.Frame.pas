unit PGofer.Triggers.HotKeys.Frame;

interface

uses
  System.Classes,
  Winapi.Windows,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Menus, Vcl.Graphics,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers.HotKeys, PGofer.Item.Frame,
  PGofer.Forms.AutoComplete,
  PGofer.Component.Edit, PGofer.Component.RichEdit;

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
    class function LowLevelProc( Code: Integer; wParam: wParam; lParam: lParam )
      : NativeInt; stdcall; static;
    {$HINTS ON}
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGFrameHotKey: TPGFrameHotKey;

implementation

uses
  WinApi.Messages, PGofer.Triggers.HotKeys.Hook;

{$R *.dfm}
{ TPGFrameHotKey }

class function TPGFrameHotKey.LowLevelProc( Code: Integer; wParam: wParam;
  lParam: lParam ): NativeInt;
var
  ParamInput : TParamInput;
  Key: TKey;
begin
  if ( Code = HC_ACTION ) then
  begin
    if Assigned( PGFrameHotKey.FItem ) then
    begin
      ParamInput.wParam := wParam;
      if wParam < WM_MOUSEFIRST then
      begin
        ParamInput.dwVkData := PKBDLLHOOKSTRUCT( lParam ).dwVkCode;
        ParamInput.dwScan := PKBDLLHOOKSTRUCT( lParam ).dwScan;
      end else begin
        ParamInput.dwVkData := PMSLLHOOKSTRUCT( lParam ).dwMData;
      end;

      Key := TKey.CalcVirtualKey( ParamInput );
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
      end;
      PGFrameHotKey.MmoHotKeys.Lines.Text := PGFrameHotKey.FItem.GetKeysName( );
    end;
  end;
  Result := CallNextHookEx( 0, Code, wParam, lParam );
end;

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
  if HOOK_ENABLED then
  begin
    PGFrameHotKey := Self;
    MmoHotKeys.Color := clRed;
    THotKeyThread.EnableHook( TPGFrameHotKey.LowLevelProc );
  end;
end;

procedure TPGFrameHotKey.MmoHotKeysExit( Sender: TObject );
begin
  if HOOK_ENABLED then
  begin
    MmoHotKeys.Color := clBtnFace;
    THotKeyThread.EnableHook( );
  end;
end;

end.
