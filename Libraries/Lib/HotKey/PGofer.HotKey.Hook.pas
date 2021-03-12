unit PGofer.HotKey.Hook;

interface

uses
    Winapi.Windows,
    System.Generics.Collections;

type
    TKDState = (kd_Down, kd_Press, kd_Up, kd_Wheel);

    tagKBDLLHOOKSTRUCT = packed record
        dwVkCode: DWord;
        dwScan: DWord;
        dwFlags: DWord;
        dwTime: DWord;
        iExInfo: Integer;
    end;

    KBDLLHOOKSTRUCT = tagKBDLLHOOKSTRUCT;
    PKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT;

    tagMSLLHOOKSTRUCT = record
        Point: TPoint;
        dwMData: DWord;
        dwFlags: DWord;
        dwTime: DWord;
        dwExInfo: DWord;
    end;

    TMSLLHOOKSTRUCT = tagMSLLHOOKSTRUCT;
    PMSLLHOOKSTRUCT = ^TMSLLHOOKSTRUCT;

    TLowLevelProc = function(Code: Integer; wParam: wParam; lParam: lParam)
      : LRESULT; stdcall;

    TKey = record
        wKey: Word;
        bDetect: TKDState;
    end;

    THookProc = class
    private
        class var FKBHook: HHook;
        class var FMBHook: HHook;
        class var FKey: TKey;
        class var FShootKeys: TList<Word>;
        class function LowLevelProc(Code: Integer; wParam: wParam;
          lParam: lParam): LRESULT; stdcall; static;
    public
        class procedure CalcVirtualKey(wParam: wParam; lParam: lParam;
          var Key: TKey);
        class procedure EnableHoot(LLProc: TLowLevelProc = nil);
        class procedure DisableHoot();
    end;

implementation

uses
    Winapi.Messages,
    PGofer.HotKey;

{ THookProc }

class procedure THookProc.EnableHoot(LLProc: TLowLevelProc = nil);
begin
    THookProc.DisableHoot();

    if not Assigned(LLProc) then
        LLProc := THookProc.LowLevelProc;

    FKBHook := SetWindowsHookEx(WH_KEYBOARD_LL, LLProc, HInstance, 0);
    FMBHook := SetWindowsHookEx(WH_MOUSE_LL, LLProc, HInstance, 0);
end;

class procedure THookProc.DisableHoot();
begin
    FShootKeys.Clear;
    if FKBHook > 0 then
        UnHookWindowsHookEx(FKBHook);
    if FMBHook > 0 then
        UnHookWindowsHookEx(FMBHook);
end;

class function THookProc.LowLevelProc(Code: Integer; wParam: wParam;
  lParam: lParam): LRESULT;
var
    AuxHotKey: TPGHotKey;
    Inibir: Boolean;
begin
    Inibir := False;
    if (Code = HC_ACTION) then
    begin
        CalcVirtualKey(wParam, lParam, FKey);
        if FKey.wKey > 0 then
        begin
            if FKey.bDetect in [kd_Down, kd_Wheel] then
            begin
                if (FShootKeys.Contains(FKey.wKey)) then
                    FKey.bDetect := kd_Press
                else
                    FShootKeys.Add(FKey.wKey);
            end;

            AuxHotKey := TPGHotKey.LocateHotKeys(FShootKeys);
            if Assigned(AuxHotKey) and
              ((FKey.bDetect = kd_Wheel) or
              (AuxHotKey.Detect = Byte(FKey.bDetect))) then
            begin
                AuxHotKey.Execute(nil);
                Inibir := AuxHotKey.Inhibit;
            end;

            if FKey.bDetect in [kd_Up, kd_Wheel] then
                FShootKeys.Remove(FKey.wKey);
        end;
    end;

    if Inibir then
        Result := -1
    else
        Result := CallNextHookEx(0, Code, wParam, lParam);
end;

class procedure THookProc.CalcVirtualKey(wParam: wParam; lParam: lParam;
  var Key: TKey);
begin
    Key.wKey := 0;
    Key.bDetect := kd_Down;

    case wParam of

        WM_KEYDOWN, WM_SYSKEYDOWN:
            begin
                Key.bDetect := kd_Down;
                Key.wKey := PKBDLLHOOKSTRUCT(lParam).dwVkCode;
            end;

        WM_KEYUP, WM_SYSKEYUP:
            begin
                Key.bDetect := kd_Up;
                Key.wKey := PKBDLLHOOKSTRUCT(lParam).dwVkCode;
            end;
        {
          WM_MOUSEMOVE:
          begin
          Result.bDetect := kd_Wheel;
          Result.wKey := 0;
          end;
        }
        WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN, WM_XBUTTONDOWN:
            begin
                Key.bDetect := kd_Down;
                Key.wKey := wParam;
            end;

        WM_LBUTTONUP, WM_RBUTTONUP, WM_MBUTTONUP, WM_XBUTTONUP:
            begin
                Key.bDetect := kd_Up;
                Key.wKey := wParam - 1;
            end;

        WM_MOUSEWHEEL, WM_MOUSEHWHEEL:
            begin
                Key.bDetect := kd_Wheel;
                if SmallInt(PMSLLHOOKSTRUCT(lParam).dwMData shr 16) < 0 then
                    Key.wKey := wParam
                else
                    Key.wKey := wParam - 1;
            end;
    end;

    case Key.wKey of

        255:
            begin
                inc(Key.wKey, PKBDLLHOOKSTRUCT(lParam).dwScan);
            end;

        WM_XBUTTONDOWN:
            begin
                if SmallInt(PMouseInput(lParam).mouseData shr 16) > 1 then
                    Key.wKey := wParam + 1
                else
                    Key.wKey := wParam;
            end;
    end;
end;

initialization
    THookProc.FShootKeys := TList<Word>.Create();
{$IFNDEF DEBUG}
    THookProc.EnableHoot();
{$ENDIF}

finalization
    THookProc.DisableHoot();
    THookProc.FShootKeys.Free;

end.
