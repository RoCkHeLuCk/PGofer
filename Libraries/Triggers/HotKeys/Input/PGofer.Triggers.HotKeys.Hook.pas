unit PGofer.Triggers.HotKeys.Hook;

interface

{$INLINE ON} { ON, OFF ou AUTO }

uses
  Winapi.Windows,
  PGofer.Triggers.HotKeys.MMHook,
  PGofer.Triggers.HotKeys.Controls;

type
  THookInput = class
  private
    FKBHook: HHook;
    FMBHook: HHook;
    class function LowLevelProc( ACode: Integer; AwParam: wParam;
      AlParam: lParam ): LRESULT; stdcall; static; inline;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
  end;

implementation

uses
  Winapi.Messages,
  PGofer.Triggers.HotKeys;

{ THookProc }

constructor THookInput.Create( );
begin
  inherited Create( );
  FKBHook := SetWindowsHookEx( WH_KEYBOARD_LL, LowLevelProc, HInstance, 0 );
  FMBHook := SetWindowsHookEx( WH_MOUSE_LL, LowLevelProc, HInstance, 0 );
end;

destructor THookInput.Destroy( );
begin
  UnHookWindowsHookEx( FKBHook );
  UnHookWindowsHookEx( FMBHook );
  FKBHook := 0;
  FMBHook := 0;
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
    TPGHotKey.OnProcessKeys( ParamInput );
  end;
  Result := CallNextHookEx( 0, ACode, AwParam, AlParam );
end;

initialization

finalization

end.
