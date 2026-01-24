unit PGofer.Triggers.HotKeys.Hook;

interface

{$INLINE ON} { ON, OFF ou AUTO }

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils,
  PGofer.Triggers.HotKeys.MMHook,
  PGofer.Triggers.HotKeys.Controls;

type
  THookInput = class (TThread)
  private
    FKBHook: HHook;
    FMBHook: HHook;
    class function LowLevelProc( ACode: Integer; AwParam: wParam;
      AlParam: lParam ): LRESULT; stdcall; static;
  protected
    procedure Execute( ); override;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
  end;

implementation

uses
  PGofer.Language,
  PGofer.Triggers.HotKeys;

{ THookProc }

constructor THookInput.Create( );
begin
  inherited Create( False );
  Self.FreeOnTerminate := False;
  Self.Priority := tpTimeCritical;
end;

destructor THookInput.Destroy( );
begin
  Self.Terminate();
  if Self.ThreadID <> 0 then
    PostThreadMessage(Self.ThreadID, WM_NULL, 0, 0);
  Self.WaitFor();
  inherited Destroy();
end;

procedure THookInput.Execute( );
var
  Msg: TMsg;
begin
  FKBHook := SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelProc, HInstance, 0);
  FMBHook := SetWindowsHookEx(WH_MOUSE_LL, LowLevelProc, HInstance, 0);

  if (FKBHook = 0) or (FMBHook = 0) then
  begin
    TrC( 'ERROR: Set windows hook HotKey.', False );
    Self.Terminate();
  end;

  try
    while not Self.Terminated and GetMessage(Msg, 0, 0, 0) do
    begin
      if Msg.message = WM_QUIT then Break;
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  finally
    if FKBHook <> 0 then
    begin
      UnHookWindowsHookEx(FKBHook);
      FKBHook := 0;
    end;

    if FMBHook <> 0 then
    begin
      UnHookWindowsHookEx(FMBHook);
      FMBHook := 0;
    end;
  end;
end;

class function THookInput.LowLevelProc( ACode: Integer; AwParam: wParam;
  AlParam: lParam ): LRESULT;
var
  ParamInput: TParamInput;
  PKB: PKBDLLHOOKSTRUCT;
begin
  if ( ACode = HC_ACTION ) then
  begin
    ParamInput.wParam := AwParam;
    if AwParam < WM_MOUSEFIRST then
    begin
      PKB := PKBDLLHOOKSTRUCT( AlParam );
      ParamInput.dwVkData := PKB.dwVkCode;
      ParamInput.dwScan := PKB.dwScan;
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
