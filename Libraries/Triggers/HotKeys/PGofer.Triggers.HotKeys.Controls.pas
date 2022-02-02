unit PGofer.Triggers.HotKeys.Controls;

interface

uses
  WinApi.Windows,
  System.SysUtils;

type
  TInputEnum = ( HOOK, RAW, ASYNC, HOTKEY );

  TParamInput = record
    wParam: wParam;
    dwVkData: DWORD;
    dwScan: DWORD;
  end;

  TProcessKeys = procedure( AParamInput: TParamInput ) of object;

  TKey = record
    wKey: Word;
    bDetect: ( kd_Down, kd_Press, kd_Up, kd_Wheel );
  public
    class function CalcVirtualKey( AParam: TParamInput ): TKey; static;
  end;

const
  INPUT_TYPE: TInputEnum = ASYNC;

implementation

uses
  WinApi.Messages;

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

end.
