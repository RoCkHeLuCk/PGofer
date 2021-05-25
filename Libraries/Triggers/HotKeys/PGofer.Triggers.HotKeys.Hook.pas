unit PGofer.Triggers.HotKeys.Hook;

interface

{$INLINE ON} { ON, OFF ou AUTO }

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Diagnostics,
  System.SyncObjs,
  System.Generics.Collections;

  {$IFDEF DEBUG}
    const HOOK_ENABLED : Boolean = False;
  {$ELSE}
    const HOOK_ENABLED : Boolean = True;
  {$ENDIF}

type

  TKDState = ( kd_Down, kd_Press, kd_Up, kd_Wheel );

  tagKBDLLHOOKSTRUCT = packed record
    dwVkCode: DWORD; // sim
    dwScan: DWORD; // sim
    dwFlags: DWORD;
    dwTime: DWORD;
    iExInfo: ULONG_PTR;
  end;

  KBDLLHOOKSTRUCT = tagKBDLLHOOKSTRUCT;
  PKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT;

  tagMSLLHOOKSTRUCT = record
    dx: LongInt;
    dy: LongInt;
    dwMData: DWORD; // sim
    dwFlags: DWORD;
    dwTime: DWORD;
    dwExInfo: ULONG_PTR;
  end;

  TMSLLHOOKSTRUCT = tagMSLLHOOKSTRUCT;
  PMSLLHOOKSTRUCT = ^TMSLLHOOKSTRUCT;

  TParamInput = record
    wParam: wParam;
    dwVkData: DWORD;
    dwScan: DWORD;
  end;

  TLowLevelProc = function( Code: Integer; wParam: wParam; lParam: lParam )
    : LRESULT; stdcall;

  TKey = record
    wKey: Word;
    bDetect: TKDState;
  public
    class function CalcVirtualKey( AParam: TParamInput ): TKey; static;
  end;

  THotKeyThread = class( TThread )
  private
    FParam: TQueue<TParamInput>;
    FShootKeys: TList<Word>;
    FEvent: TEvent;
    procedure ProcessKeys( );
    procedure KBEnqueue( AwParam: wParam; AlParam: lParam );
    procedure MBEnqueue( AwParam: wParam; AlParam: lParam );
    class var FHotKeyThread: THotKeyThread;
    class var FKBHook: HHook;
    class var FMBHook: HHook;
    class function KBLowLevelProc( Code: Integer; wParam: wParam;
      lParam: lParam ): LRESULT; stdcall; static; inline;
    class function MBLowLevelProc( Code: Integer; wParam: wParam;
      lParam: lParam ): LRESULT; stdcall; static; inline;
  protected
    procedure Execute; override;
  public
    class procedure EnableHook( LLProc: TLowLevelProc = nil ); static;
    class procedure DisableHook( ); static;
    constructor Create( ); overload;
    destructor Destroy( ); override;
    procedure Terminate( ); overload;
  end;


implementation

uses
  Winapi.Messages, PGofer.Triggers.HotKeys, PGofer.Sintatico;

{ TKey }

class function TKey.CalcVirtualKey( AParam: TParamInput ): TKey;
begin
  Result.wKey := 0;
  Result.bDetect := kd_Down;

  case AParam.wParam of

    WM_KEYDOWN, WM_SYSKEYDOWN:
      begin
        Result.wKey := AParam.dwVkData;
      end;

    WM_KEYUP, WM_SYSKEYUP:
      begin
        Result.bDetect := kd_Up;
        Result.wKey := AParam.dwVkData;
      end;

    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN, WM_XBUTTONDOWN:
      begin
        Result.wKey := AParam.wParam;
      end;

    WM_LBUTTONUP, WM_RBUTTONUP, WM_MBUTTONUP, WM_XBUTTONUP:
      begin
        Result.bDetect := kd_Up;
        Result.wKey := AParam.wParam - 1;
      end;

    WM_MOUSEWHEEL, WM_MOUSEHWHEEL:
      begin
        Result.bDetect := kd_Wheel;
        if SmallInt( AParam.dwVkData shr 16 ) < 0 then
          Result.wKey := AParam.wParam
        else
          Result.wKey := AParam.wParam - 1;
      end;
  end;

  case Result.wKey of

    255:
      begin
        inc( Result.wKey, AParam.dwScan );
      end;

    WM_XBUTTONDOWN:
      begin
        if SmallInt( AParam.dwVkData shr 16 ) > 1 then
          Result.wKey := AParam.wParam + 1
        else
          Result.wKey := AParam.wParam;
      end;
  end;
end;

{ THookProc }

class procedure THotKeyThread.EnableHook( LLProc: TLowLevelProc = nil );
begin
  try
    try
      THotKeyThread.DisableHook( );
      THotKeyThread.FHotKeyThread := THotKeyThread.Create( );
    finally
      if not Assigned( LLProc ) then
      begin
        THotKeyThread.FKBHook := SetWindowsHookEx( WH_KEYBOARD_LL,
          THotKeyThread.KBLowLevelProc, HInstance, 0 );
        THotKeyThread.FMBHook := SetWindowsHookEx( WH_MOUSE_LL,
          THotKeyThread.MBLowLevelProc, HInstance, 0 );
      end else begin
        THotKeyThread.FKBHook := SetWindowsHookEx( WH_KEYBOARD_LL, LLProc,
          HInstance, 0 );
        THotKeyThread.FMBHook := SetWindowsHookEx( WH_MOUSE_LL, LLProc,
          HInstance, 0 );
      end;
    end;
  except
    THotKeyThread.DisableHook( );
  end;
end;

class procedure THotKeyThread.DisableHook( );
begin
  if THotKeyThread.FKBHook > 0 then
    UnHookWindowsHookEx( THotKeyThread.FKBHook );

  if THotKeyThread.FMBHook > 0 then
    UnHookWindowsHookEx( THotKeyThread.FMBHook );

  if Assigned( THotKeyThread.FHotKeyThread ) then
  begin
    THotKeyThread.FHotKeyThread.Terminate;
    THotKeyThread.FHotKeyThread := nil;
  end;
end;

class function THotKeyThread.KBLowLevelProc( Code: Integer; wParam: wParam;
  lParam: lParam ): LRESULT;
begin
  if ( Code = HC_ACTION ) then
    THotKeyThread.FHotKeyThread.KBEnqueue( wParam, lParam );
  Result := CallNextHookEx( 0, Code, wParam, lParam );
end;

class function THotKeyThread.MBLowLevelProc( Code: Integer; wParam: wParam;
  lParam: lParam ): LRESULT;
begin
  if ( Code = HC_ACTION ) and ( wParam <> WM_MOUSEMOVE ) then
    THotKeyThread.FHotKeyThread.MBEnqueue( wParam, lParam );
  Result := CallNextHookEx( 0, Code, wParam, lParam );
end;


// class procedure THookProc.SubLowLevelProc( AwParam: wParam; AlParam: lParam );
// var
// Key: TKey;
// VHotKey: TPGHotKey;
// Stopwatch: TStopwatch;
// begin
// Stopwatch := TStopwatch.Create;
// Stopwatch.Start;
//
// CalcVirtualKey( AwParam, AlParam, Key );
//
// if Stopwatch.Elapsed.Ticks > PGofer.Sintatico.ElapsedTimeOut then
// begin
// ConsoleNotify( nil, 'Error: HotKey Timeout Calc: Elapsed ' +
// Stopwatch.Elapsed.Ticks.ToString, True, True );
// Exit;
// end;
// Stopwatch.StartNew;
//
// if Key.wKey > 0 then
// begin
// if Key.bDetect in [ kd_Down, kd_Wheel ] then
// begin
// if ( FShootKeys.Contains( Key.wKey ) ) then
// Key.bDetect := kd_Press
// else
// FShootKeys.Add( Key.wKey );
// end;
//
// VHotKey := TPGHotKey.LocateHotKeys( FShootKeys );
// if Stopwatch.Elapsed.Ticks > PGofer.Sintatico.ElapsedTimeOut then
// begin
// ConsoleNotify( nil, 'Error: HotKey Timeout Locate: Elapsed ' +
// Stopwatch.Elapsed.Ticks.ToString, True, True );
// FShootKeys.Clear;
// Exit;
// end;
// Stopwatch.StartNew;
//
// if Assigned( VHotKey ) then
// begin
// if ( ( Key.bDetect = kd_Wheel ) or
// ( VHotKey.Detect = Byte( Key.bDetect ) ) ) then
// begin
// VHotKey.Triggering( );
// if Stopwatch.Elapsed.Ticks > PGofer.Sintatico.ElapsedTimeOut then
// begin
// ConsoleNotify( nil, 'Error: HotKey Timeout Trigger: Elapsed ' +
// Stopwatch.Elapsed.Ticks.ToString, True, True );
// FShootKeys.Clear;
// Exit;
// end;
// // if ( VHotKey.Detect <> Byte( kd_Up ) )
// // // and( FKey.wKey = VHotKey.Keys.Last )
// // and ( VHotKey.Inhibit ) then
// // Result := True;
// end;
// end;
//
// if Key.bDetect in [ kd_Up, kd_Wheel ] then
// FShootKeys.Remove( Key.wKey );
// end;
// Stopwatch.Stop;
// end;

constructor THotKeyThread.Create( );
begin
  Self.FParam := TQueue<TParamInput>.Create( );
  //Self.FParam.Capacity := 10;
  Self.FShootKeys := TList<Word>.Create( );
  Self.FEvent := TEvent.Create( nil, False, False, 'HotKeyEvent' );
  Self.FEvent.ResetEvent;
  inherited Create( False );
  Self.Priority := tpIdle;
  Self.FreeOnTerminate := True;
end;

destructor THotKeyThread.Destroy( );
begin
  Self.FShootKeys.Free( );
  Self.FShootKeys := nil;
  Self.FParam.Free( );
  Self.FParam := nil;
  Self.FEvent.Free( );
  Self.FEvent := nil;
  inherited Destroy( );
end;

procedure THotKeyThread.Terminate( );
begin
  inherited Terminate( );
  Self.FEvent.SetEvent;
end;

procedure THotKeyThread.Execute( );
var
  VEvent: TWaitResult;
begin
  while not Self.Terminated do
  begin
    VEvent := Self.FEvent.WaitFor( INFINITE );
    case VEvent of
      wrSignaled:
        ProcessKeys( );
      wrTimeout:
        Continue;
      wrAbandoned, wrError, wrIOCompletion:
        begin
          ConsoleNotify( Self, 'TEvent Aborted.', True, True );
          Exit;
        end;
    end;
    Self.FEvent.ResetEvent;
  end;
end;

procedure THotKeyThread.KBEnqueue( AwParam: wParam; AlParam: lParam );
var
  ParamInput : TParamInput;
begin
  ParamInput.wParam := AwParam;
  ParamInput.dwVkData := PKBDLLHOOKSTRUCT( AlParam ).dwVkCode;
  ParamInput.dwScan := PKBDLLHOOKSTRUCT( AlParam ).dwScan;
  Self.FParam.Enqueue( ParamInput );
  Self.FEvent.SetEvent;
end;

procedure THotKeyThread.MBEnqueue( AwParam: wParam; AlParam: lParam );
var
  ParamInput : TParamInput;
begin
  ParamInput.wParam := AwParam;
  ParamInput.dwVkData := PMSLLHOOKSTRUCT( AlParam ).dwMData;
  Self.FParam.Enqueue( ParamInput );
  Self.FEvent.SetEvent;
end;

procedure THotKeyThread.ProcessKeys( );
var
  Key: TKey;
  VHotKey: TPGHotKey;
  // Stopwatch: TStopwatch;
begin
  while ( Self.FParam.Count > 0 ) and ( not Self.Terminated ) do
  begin

    if Self.FParam.Count > PGofer.Sintatico.HookQueueMaxCount then
       PGofer.Sintatico.HookQueueMaxCount := Self.FParam.Count;

    Key := TKey.CalcVirtualKey( Self.FParam.Dequeue( ) );

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
          // if ( VHotKey.Detect <> Byte( kd_Up ) )
          // // and( FKey.wKey = VHotKey.Keys.Last )
          // and ( VHotKey.Inhibit ) then
          // Result := True;
        end;
      end;

      if Key.bDetect in [ kd_Up, kd_Wheel ] then
        FShootKeys.Remove( Key.wKey );
    end; // if key #0
  end; // while Queue Count
end;

initialization
  if HOOK_ENABLED then
     THotKeyThread.EnableHook( );

finalization
  THotKeyThread.DisableHook( );

end.
