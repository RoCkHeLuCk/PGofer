unit PGofer.Triggers.HotKeys.RawInput;

interface

uses
  Winapi.Messages,
  System.Classes,

  PGofer.Triggers.HotKeys.MMRawInput,
  PGofer.Triggers.HotKeys.Controls;

type
  TRawInput = class
  private
    FRAWInputHandle: THandle;
    FRAWInputDevice: packed array [ 0 .. 3 ] of TRAWInputDevice;
  protected
    procedure WMRawInput( var MSG: TMessage ); message WM_INPUT;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
  end;

implementation

uses
  PGofer.Triggers.HotKeys;

{ THotKeyRawInput }

constructor TRawInput.Create( );
begin
  inherited Create( );

  FRAWInputHandle := AllocateHWnd( WMRawInput );

  FRAWInputDevice[ 0 ].usUsagePage := HID_USAGE_PAGE_GENERIC;
  FRAWInputDevice[ 0 ].usUsage := HID_USAGE_GENERIC_MOUSE;
  FRAWInputDevice[ 0 ].dwFlags := RIDEV_INPUTSINK;
  FRAWInputDevice[ 0 ].hwndTarget := FRAWInputHandle;

  FRAWInputDevice[ 1 ].usUsagePage := HID_USAGE_PAGE_GENERIC;
  FRAWInputDevice[ 1 ].usUsage := HID_USAGE_GENERIC_JOYSTICK;
  FRAWInputDevice[ 1 ].dwFlags := RIDEV_INPUTSINK;
  FRAWInputDevice[ 1 ].hwndTarget := FRAWInputHandle;

  FRAWInputDevice[ 2 ].usUsagePage := HID_USAGE_PAGE_GENERIC;
  FRAWInputDevice[ 2 ].usUsage := HID_USAGE_GENERIC_GAMEPAD;
  FRAWInputDevice[ 2 ].dwFlags := RIDEV_INPUTSINK;
  FRAWInputDevice[ 2 ].hwndTarget := FRAWInputHandle;

  FRAWInputDevice[ 3 ].usUsagePage := HID_USAGE_PAGE_GENERIC;
  FRAWInputDevice[ 3 ].usUsage := HID_USAGE_GENERIC_KEYBOARD;
  FRAWInputDevice[ 3 ].dwFlags := RIDEV_INPUTSINK;
  FRAWInputDevice[ 3 ].hwndTarget := FRAWInputHandle;

  RegisterRawInputDevices( @FRAWInputDevice, Length( FRAWInputDevice ),
    SizeOf( TRAWInputDevice ) );
end;

destructor TRawInput.Destroy( );
begin
  FRAWInputDevice[ 0 ].dwFlags := RIDEV_REMOVE;
  FRAWInputDevice[ 1 ].dwFlags := RIDEV_REMOVE;
  FRAWInputDevice[ 2 ].dwFlags := RIDEV_REMOVE;
  FRAWInputDevice[ 3 ].dwFlags := RIDEV_REMOVE;

  RegisterRawInputDevices( @FRAWInputDevice, 3, SizeOf( TRAWInputDevice ) );
  DeallocateHWnd( FRAWInputHandle );

  inherited Destroy( );
end;

procedure TRawInput.WMRawInput( var MSG: TMessage );
var
  RAWInputKey: PRawInput;
  ParamInput: TParamInput;
  dwSize: Cardinal;
begin
  MSG.Result := 0;
  try
    GetRawInputData( MSG.LParam, RID_INPUT, nil, dwSize, RAWINPUTHEADERSIZE );
  finally
    if dwSize > 0 then
    begin
      GetMem( RAWInputKey, dwSize * RAWINPUTHEADERSIZE );
      try
        if GetRawInputData( MSG.LParam, RID_INPUT, RAWInputKey, dwSize,
          RAWINPUTHEADERSIZE ) = dwSize then
        begin
          case RAWInputKey.header.dwType of
            RIM_TYPEMOUSE:
              begin
                if RAWInputKey.mouse.union.ulButtons <> 0 then
                begin
                  ParamInput.wParam := RAWInputKey.mouse.union.usButtonFlags;
                  ParamInput.dwVkData := RAWInputKey.mouse.union.usButtonData;
                  TPGHotKey.OnProcessKeys( ParamInput );
                end;
              end;
            RIM_TYPEKEYBOARD:
              begin
                ParamInput.wParam := RAWInputKey.keyboard.Message;
                ParamInput.dwVkData := RAWInputKey.keyboard.VKey;
                ParamInput.dwScan := RAWInputKey.keyboard.ExtraInformation;
                TPGHotKey.OnProcessKeys( ParamInput );
              end;
          end;
        end;
      finally
        FreeMem( RAWInputKey );
      end;
    end;
  end;
end;

initialization

finalization

end.
