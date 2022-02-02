unit PGofer.Triggers.HotKeys.Hook;

interface

{$INLINE ON} { ON, OFF ou AUTO }

uses
  Winapi.Windows,
  System.Generics.Collections,
  PGofer.Triggers.HotKeys.MMHook,
  PGofer.Triggers.HotKeys.Controls;

type
  THookInput = class
  private
    FKBHook: HHook;
    FMBHook: HHook;
    FShootKeys: TList<Word>;
    FOnProcessKeys: TProcessKeys;
    procedure OnProcessKeys( AParamInput: TParamInput );
    class function LowLevelProc( ACode: Integer; AwParam: wParam;
      AlParam: lParam ): LRESULT; stdcall; static; inline;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
    procedure SetProcessKeys( ProcessKeys: TProcessKeys = nil );
  end;

var
  HookInput: THookInput;

implementation

uses
  Winapi.Messages, PGofer.Triggers.HotKeys;

{ THookProc }

constructor THookInput.Create( );
begin
  inherited Create( );
  Self.FShootKeys := TList<Word>.Create( );
  FOnProcessKeys := Self.OnProcessKeys;
  FKBHook := SetWindowsHookEx( WH_KEYBOARD_LL, LowLevelProc, HInstance, 0 );
  FMBHook := SetWindowsHookEx( WH_MOUSE_LL, LowLevelProc, HInstance, 0 );
end;

destructor THookInput.Destroy( );
begin
  UnHookWindowsHookEx( FKBHook );
  UnHookWindowsHookEx( FMBHook );
  FKBHook := 0;
  FMBHook := 0;
  FOnProcessKeys := nil;
  Self.FShootKeys.Free( );
  Self.FShootKeys := nil;
  inherited Destroy( );
end;

class function THookInput.LowLevelProc( ACode: Integer; AwParam: wParam;
  AlParam: lParam ): LRESULT;
var
  ParamInput: TParamInput;
begin
  if ( ACode = HC_ACTION ) then
  begin
    ParamInput.wParam := AwParam;
    if AwParam < WM_MOUSEFIRST then
    begin
      ParamInput.dwVkData := PKBDLLHOOKSTRUCT( AlParam ).dwVkCode;
      ParamInput.dwScan := PKBDLLHOOKSTRUCT( AlParam ).dwScan;
    end else begin
      ParamInput.dwVkData := PMSLLHOOKSTRUCT( AlParam ).dwMData;
    end;
    HookInput.FOnProcessKeys( ParamInput );
  end;
  Result := CallNextHookEx( 0, ACode, AwParam, AlParam );
end;

procedure THookInput.OnProcessKeys( AParamInput: TParamInput );
var
  Key: TKey;
  VHotKey: TPGHotKey;
begin
  Key := TKey.CalcVirtualKey( AParamInput );

  if Key.wKey > 0 then
  begin
    if Key.bDetect in [ kd_Down, kd_Wheel ] then
    begin
      if ( FShootKeys.Contains( Key.wKey ) ) then
        Key.bDetect := kd_Press
      else
        FShootKeys.Add( Key.wKey );
    end;

    VHotKey := TPGHotKey.LocateHotKeys( FShootKeys );

    if Assigned( VHotKey ) then
    begin
      if ( ( Key.bDetect = kd_Wheel ) or
        ( VHotKey.Detect = Byte( Key.bDetect ) ) ) then
      begin
        VHotKey.Triggering( );
      end;
    end;

    if Key.bDetect in [ kd_Up, kd_Wheel ] then
      FShootKeys.Remove( Key.wKey );
  end; // if key #0
end;

procedure THookInput.SetProcessKeys( ProcessKeys: TProcessKeys );
begin
  if Assigned( ProcessKeys ) then
  begin
    FOnProcessKeys := ProcessKeys;
  end else begin
    FOnProcessKeys := Self.OnProcessKeys;
  end;
end;

initialization

{$IFDEF DEBUG}
if INPUT_TYPE = Hook then
  HookInput := THookInput.Create( );
{$ENDIF}

finalization

{$IFDEF DEBUG}
if INPUT_TYPE = Hook then
  HookInput.Free( );
{$ENDIF}

end.
