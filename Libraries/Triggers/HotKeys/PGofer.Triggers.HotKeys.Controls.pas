unit PGofer.Triggers.HotKeys.Controls;

interface

{$INLINE ON}

uses
  WinApi.Windows,
  System.SysUtils;

type
  TParamInput = record
    wParam: wParam;
    dwVkData: DWORD;
    dwScan: DWORD;
  end;

  TKey = record
    wKey: Word;
    bDetect: ( kd_Down, kd_Press, kd_Up, kd_Wheel );
  public
    class function CalcVirtualKey( AParam: TParamInput ): TKey; static; inline;
  end;

  TProcessKeys = function( AParamInput: TParamInput ): Boolean of object;

implementation

uses
  WinApi.Messages;

{ TKey }

class function TKey.CalcVirtualKey( AParam: TParamInput ): TKey;
begin
  Result.wKey := 0;
  Result.bDetect := kd_Down;

  case AParam.wParam of
    // -------------------------------------------------------------
    // 1. TECLADO E CLIQUE DE MOUSE VIA ASYNCINPUT
    // Ambos os motores mandam o c�digo VK limpinho no dwVkData
    // -------------------------------------------------------------
    WM_KEYDOWN, WM_SYSKEYDOWN:
    begin
      Result.wKey := AParam.dwVkData;
    end;

    WM_KEYUP, WM_SYSKEYUP:
    begin
      Result.bDetect := kd_Up;
      Result.wKey := AParam.dwVkData;
    end;

    // -------------------------------------------------------------
    // 2. MOUSE VIA HOOKINPUT
    // O Hook separa bot�es em mensagens WM dedicadas. Traduzimos!
    // -------------------------------------------------------------
    WM_LBUTTONDOWN: Result.wKey := VK_LBUTTON;
    WM_LBUTTONUP:   begin Result.bDetect := kd_Up; Result.wKey := VK_LBUTTON; end;

    WM_RBUTTONDOWN: Result.wKey := VK_RBUTTON;
    WM_RBUTTONUP:   begin Result.bDetect := kd_Up; Result.wKey := VK_RBUTTON; end;

    WM_MBUTTONDOWN: Result.wKey := VK_MBUTTON;
    WM_MBUTTONUP:   begin Result.bDetect := kd_Up; Result.wKey := VK_MBUTTON; end;

    WM_XBUTTONDOWN:
    begin
      // No Hook, o High-Word do dwMData cont�m 1 ou 2 para o XButton
      if (AParam.dwVkData shr 16) = 1 then
        Result.wKey := VK_XBUTTON1
      else
        Result.wKey := VK_XBUTTON2;
    end;

    WM_XBUTTONUP:
    begin
      Result.bDetect := kd_Up;
      if (AParam.dwVkData shr 16) = 1 then
        Result.wKey := VK_XBUTTON1
      else
        Result.wKey := VK_XBUTTON2;
    end;

    // -------------------------------------------------------------
    // 3. SCROLL DO MOUSE (Exclusivo do Hook)
    // -------------------------------------------------------------
    WM_MOUSEWHEEL, WM_MOUSEHWHEEL:
    begin
      Result.bDetect := kd_Wheel;
      // Scroll Up/Down. Mantemos a sua l�gica de desvio do wParam
      if SmallInt( Word( AParam.dwVkData shr 16 ) ) < 0 then
        Result.wKey := AParam.wParam
      else
        Result.wKey := AParam.wParam - 1;
    end;
  end;
end;

//class function TKey.CalcVirtualKey( AParam: TParamInput ): TKey;
//begin
//  Result.wKey := 0;
//  Result.bDetect := kd_Down;
//
//  case AParam.wParam of
//
//    WM_KEYDOWN, WM_SYSKEYDOWN:
//    begin
//      Result.wKey := AParam.dwVkData;
//    end;
//
//    WM_KEYUP, WM_SYSKEYUP:
//    begin
//      Result.bDetect := kd_Up;
//      Result.wKey := AParam.dwVkData;
//    end;
//
//    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN, WM_XBUTTONDOWN:
//    begin
//      Result.wKey := AParam.wParam;
//    end;
//
//    WM_LBUTTONUP, WM_RBUTTONUP, WM_MBUTTONUP, WM_XBUTTONUP:
//    begin
//      Result.bDetect := kd_Up;
//      Result.wKey := AParam.wParam - 1;
//    end;
//
//    WM_MOUSEWHEEL, WM_MOUSEHWHEEL:
//    begin
//      Result.bDetect := kd_Wheel;
//      if SmallInt( Word( AParam.dwVkData shr 16 ) ) < 0 then
//        Result.wKey := AParam.wParam
//      else
//        Result.wKey := AParam.wParam - 1;
//    end;
//  end;
//
//  case Result.wKey of
//
//    255:
//    begin
//      inc( Result.wKey, AParam.dwScan );
//    end;
//
//    WM_XBUTTONDOWN:
//    begin
//      if SmallInt( Word( AParam.dwVkData shr 16 ) ) > 1 then
//        Result.wKey := AParam.wParam + 1
//      else
//        Result.wKey := AParam.wParam;
//    end;
//  end;
//end;

end.
