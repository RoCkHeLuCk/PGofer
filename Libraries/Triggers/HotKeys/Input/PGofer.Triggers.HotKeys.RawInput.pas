unit PGofer.Triggers.HotKeys.RawInput;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils,
  PGofer.Triggers.HotKeys.MMRawInput,
  PGofer.Triggers.HotKeys.Controls;


const
  // Mapeamento exato dos 10 primeiros bits do usButtonFlags
  RAW_TO_WM: array[0..9] of Word = (
    WM_LBUTTONDOWN, WM_LBUTTONUP,     // Bits 0, 1 (Left)
    WM_RBUTTONDOWN, WM_RBUTTONUP,     // Bits 2, 3 (Right)
    WM_MBUTTONDOWN, WM_MBUTTONUP,     // Bits 4, 5 (Middle)
    WM_XBUTTONDOWN, WM_XBUTTONUP,     // Bits 6, 7 (XBUTTON 1)
    WM_XBUTTONDOWN, WM_XBUTTONUP      // Bits 8, 9 (XBUTTON 2)
  );

type
  TRawInput = class(TThread)
  private
    FRAWInputHandle: THandle;
    FRAWInputDevice: packed array [0 .. 1] of TRAWInputDevice;
    FBuffer: array of Byte;
    procedure ProcessSingleInput(Raw: PRawInput);
    procedure ProcessCurrentInput(hRawInput: HRAWINPUT);
    procedure ReadBufferedInputs;
    procedure WMRawInput(var MSG: TMessage); message WM_INPUT;
    procedure DeallocateWindow;
  protected
    procedure Execute(); override;
  public
    constructor Create(); overload;
    destructor Destroy(); override;
  end;

implementation

uses
  PGofer.Core,
  PGofer.Triggers.HotKeys;

{ TRawInput }

constructor TRawInput.Create();
begin
  inherited Create(False);
  Self.FreeOnTerminate := False;
  Self.Priority := tpTimeCritical;
end;

destructor TRawInput.Destroy();
begin
  Self.Terminate();
  if FRAWInputHandle <> 0 then
    PostMessage(FRAWInputHandle, WM_NULL, 0, 0);
  Self.WaitFor();
  inherited Destroy();
end;

procedure TRawInput.DeallocateWindow();
begin
  FRAWInputDevice[0].dwFlags := RIDEV_REMOVE;
  FRAWInputDevice[0].hwndTarget := 0;
  FRAWInputDevice[1].dwFlags := RIDEV_REMOVE;
  FRAWInputDevice[1].hwndTarget := 0;

  RegisterRawInputDevices(@FRAWInputDevice, 2, SizeOf(TRAWInputDevice));
  if FRAWInputHandle <> 0 then
  begin
      DeallocateHWnd(FRAWInputHandle);
      FRAWInputHandle := 0;
  end;
end;

procedure TRawInput.Execute();
var
  Msg: TMsg;
begin
  FRAWInputHandle := AllocateHWnd(WMRawInput);

  try
    FRAWInputDevice[0].usUsagePage := HID_USAGE_PAGE_GENERIC;
    FRAWInputDevice[0].usUsage := HID_USAGE_GENERIC_MOUSE;
    FRAWInputDevice[0].dwFlags := RIDEV_INPUTSINK;
    FRAWInputDevice[0].hwndTarget := FRAWInputHandle;

    FRAWInputDevice[1].usUsagePage := HID_USAGE_PAGE_GENERIC;
    FRAWInputDevice[1].usUsage := HID_USAGE_GENERIC_KEYBOARD;
    FRAWInputDevice[1].dwFlags := RIDEV_INPUTSINK;
    FRAWInputDevice[1].hwndTarget := FRAWInputHandle;

    if not RegisterRawInputDevices(@FRAWInputDevice, 2, SizeOf(TRAWInputDevice)) then
    begin
      TPGKernel.ConsoleTr('Error_RawInput_NInstal');
      Exit;
    end;

    while not Terminated and GetMessage(Msg, 0, 0, 0) do
    begin
      if Msg.message = WM_QUIT then Break;
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;

  finally
    Self.DeallocateWindow();
  end;
end;

procedure TRawInput.WMRawInput(var MSG: TMessage);
begin
  if MSG.Msg <> WM_INPUT then
  begin
    MSG.Result := DefWindowProc(FRAWInputHandle, MSG.Msg, MSG.WParam, MSG.LParam);
    Exit;
  end;

  ProcessCurrentInput(HRAWINPUT(MSG.LParam));
  ReadBufferedInputs;

  MSG.Result := DefWindowProc(FRAWInputHandle, MSG.Msg, MSG.WParam, MSG.LParam);
end;

procedure TRawInput.ProcessCurrentInput(hRawInput: HRAWINPUT);
var
  dwSize: UINT;
  LocalBuffer: array[0..1023] of Byte;
  Raw: PRawInput;
begin
  dwSize := SizeOf(LocalBuffer);
  if GetRawInputData(hRawInput, RID_INPUT, @LocalBuffer[0], dwSize, RAWINPUTHEADERSIZE) > 0 then
  begin
    Raw := PRawInput(@LocalBuffer[0]);
    ProcessSingleInput(Raw);
  end;
end;

procedure TRawInput.ReadBufferedInputs;
var
  dwSize: UINT;
  Raw: PRawInput;
  Count: Integer;
begin
  dwSize := 0;
  if GetRawInputBuffer(nil, dwSize, RAWINPUTHEADERSIZE) <> 0 then Exit;
  if dwSize = 0 then Exit;
  if Length(FBuffer) < SmallInt(dwSize * 16) then
     SetLength(FBuffer, dwSize * 16);

  dwSize := Length(FBuffer);
  Count := GetRawInputBuffer(PRawInput(FBuffer), dwSize, RAWINPUTHEADERSIZE);

  if (Count <= 0) or (Count > 1000) then Exit;

  Raw := PRawInput(FBuffer);

  while Count > 0 do
  begin
    ProcessSingleInput(Raw);
    Raw := NEXTRAWINPUTBLOCK(Raw);
    Dec(Count);
  end;
end;

procedure TRawInput.ProcessSingleInput(Raw: PRawInput);
var
  ParamInput: TParamInput;
  Flags, I : Word;
begin
  case Raw.header.dwType of
    RIM_TYPEMOUSE:
      begin
        Flags := Raw.mouse.union.usButtonFlags;
        // Processa os bot�es (Bits 0 a 9)
        if (Flags and $3FF) <> 0 then
        begin
          for i := 0 to 9 do
          begin
            if (Flags and (1 shl i)) <> 0 then
            begin
              ParamInput.wParam := RAW_TO_WM[i];

              // Ajuste do XButton:
              // Se for bits 6,7 (X1) ou 8,9 (X2)
              if i >= 6 then
              begin
                // Se i=6 ou 7 -> (6 div 2) = 3; 3-2 = 1 (XBUTTON1)
                // Se i=8 ou 9 -> (8 div 2) = 4; 4-2 = 2 (XBUTTON2)
                //ParamInput.dwVkData := ((i div 2) - 2) shl 16;
                ParamInput.dwVkData := 0;
                if (i = 6) or (i = 8) then // X1 Down/Up
                   ParamInput.wParam := $20B
                else // X2 Down/Up
                   ParamInput.wParam := $20C;

              end else
                ParamInput.dwVkData := 0;

              TPGHotKey.OnProcessKeys(ParamInput);
            end;
          end;
        end;

        // Scroll Vertical
        if (Flags and RI_MOUSE_WHEEL) <> 0 then
        begin
          ParamInput.wParam := WM_MOUSEWHEEL;
          ParamInput.dwVkData := DWORD(Raw.mouse.union.usButtonData) shl 16;
          TPGHotKey.OnProcessKeys(ParamInput);
        end;

        // Scroll Horizontal
        if (Flags and RI_MOUSE_HORIZONTAL_WHEEL) <> 0 then
        begin
          ParamInput.wParam := WM_MOUSEHWHEEL;
          ParamInput.dwVkData := DWORD(Raw.mouse.union.usButtonData) shl 16;
          TPGHotKey.OnProcessKeys(ParamInput);
        end;

      end;

    RIM_TYPEKEYBOARD:
      begin
        if (Raw.keyboard.Flags and RI_KEY_BREAK) <> 0 then
          ParamInput.wParam := WM_KEYUP
        else
          ParamInput.wParam := WM_KEYDOWN;

        ParamInput.dwVkData := Raw.keyboard.VKey;
        ParamInput.dwScan := Raw.keyboard.MakeCode;

        if (Raw.keyboard.Flags and RI_KEY_E0) <> 0 then
           ParamInput.dwScan := ParamInput.dwScan or $E000;

        case ParamInput.dwVkData of
          VK_CONTROL:
            if (Raw.keyboard.Flags and RI_KEY_E0) <> 0 then
              ParamInput.dwVkData := VK_RCONTROL
            else
              ParamInput.dwVkData := VK_LCONTROL;

          VK_MENU:
            if (Raw.keyboard.Flags and RI_KEY_E0) <> 0 then
              ParamInput.dwVkData := VK_RMENU
            else
              ParamInput.dwVkData := VK_LMENU;

          VK_SHIFT:
            ParamInput.dwVkData := MapVirtualKey(Raw.keyboard.MakeCode, MAPVK_VSC_TO_VK_EX);
        end;

        TPGHotKey.OnProcessKeys(ParamInput);
      end;
  end;
end;

end.
