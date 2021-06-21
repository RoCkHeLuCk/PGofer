unit PGofer.Triggers.HotKeys.RawInput;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  PGofer.Triggers.HotKeys.MMRawInput;

type

  THotKeyRawInput = class
  private
    FShootKeys: TList<Word>;
    FRAWInputHandle: HWND;
    FRAWInputDevice: packed array [ 0 .. 3 ] of TRAWInputDevice;
  protected
    procedure WMRawInput( var MSG: TMessage ); message WM_INPUT;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
  end;

var
  HotKeyRawInput: THotKeyRawInput;

implementation

uses
  PGofer.Triggers.HotKeys, PGofer.Sintatico;

{ THotKeyRawInput }

constructor THotKeyRawInput.Create( );
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

  RegisterRawInputDevices( @FRAWInputDevice, 4, SizeOf( TRAWInputDevice ) );

  FShootKeys := TList<Word>.Create( );
end;

destructor THotKeyRawInput.Destroy( );
begin
  FRAWInputDevice[ 0 ].dwFlags := RIDEV_REMOVE;
  FRAWInputDevice[ 1 ].dwFlags := RIDEV_REMOVE;
  FRAWInputDevice[ 2 ].dwFlags := RIDEV_REMOVE;
  FRAWInputDevice[ 3 ].dwFlags := RIDEV_REMOVE;

  RegisterRawInputDevices( @FRAWInputDevice, 3, SizeOf( TRAWInputDevice ) );
  DeallocateHWnd( FRAWInputHandle );

  FShootKeys.Free( );
  FShootKeys := nil;
  inherited Destroy( );
end;

procedure THotKeyRawInput.WMRawInput( var MSG: TMessage );
var
  RAWInputKey: PRawInput;
  dwSize: DWord;
  W: Word;
begin
  GetRawInputData( MSG.LParam, RID_INPUT, nil, dwSize,
    SizeOf( TRawInputHeader ) );

  if dwSize = 0 then
    Exit;

  GetMem( RAWInputKey, dwSize * SizeOf( TRawInputHeader ) );

  try
    if GetRawInputData( MSG.LParam, RID_INPUT, RAWInputKey, dwSize,
      SizeOf( TRawInputHeader ) ) <> dwSize then
      Exit;

    case RAWInputKey.header.dwType of
      RIM_TYPEMOUSE:
        begin
          W := RAWInputKey.mouse.union.usButtonFlags;
          if ( W and RI_MOUSE_LEFT_BUTTON_DOWN ) = RI_MOUSE_LEFT_BUTTON_DOWN
          then
            ConsoleNotify( nil, 'Left', true, true )
          else if ( W and RI_MOUSE_RIGHT_BUTTON_DOWN ) = RI_MOUSE_RIGHT_BUTTON_DOWN
          then
            ConsoleNotify( nil, 'Right', true, true );
        end;
    end;
  finally
    FreeMem( RAWInputKey );
  end;
end;

initialization

HotKeyRawInput := THotKeyRawInput.Create( );

finalization

HotKeyRawInput.Free( );

end.
