unit PGofer.Triggers.HotKeys.RawInput;

interface

uses
  Winapi.Messages,
  System.Classes,
  System.Generics.Collections,
  PGofer.Triggers.HotKeys.MMRawInput,
  PGofer.Triggers.HotKeys.Controls;

type
  TRawInput = class
  private
    FShootKeys: TList<Word>;
    FRAWInputHandle: THandle;
    FRAWInputDevice: packed array [ 0 .. 3 ] of TRAWInputDevice;
    FOnProcessKeys: TProcessKeys;
    procedure OnProcessKeys( AParamInput: TParamInput );
  protected
    procedure WMRawInput( var MSG: TMessage ); message WM_INPUT;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
    procedure SetProcessKeys( ProcessKeys: TProcessKeys = nil );
  end;

var
  RawInput: TRawInput;

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

  FShootKeys := TList<Word>.Create( );

  FOnProcessKeys := Self.OnProcessKeys;

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

  FShootKeys.Free( );
  FShootKeys := nil;
  FOnProcessKeys := nil;
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
                  FOnProcessKeys( ParamInput );
                end;
              end;
            RIM_TYPEKEYBOARD:
              begin
                ParamInput.wParam := RAWInputKey.keyboard.Message;
                ParamInput.dwVkData := RAWInputKey.keyboard.VKey;
                ParamInput.dwScan := RAWInputKey.keyboard.ExtraInformation;
                FOnProcessKeys( ParamInput );
              end;
          end;
        end;
      finally
        FreeMem( RAWInputKey );
      end;
    end;
  end;
end;

procedure TRawInput.OnProcessKeys( AParamInput: TParamInput );
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

procedure TRawInput.SetProcessKeys( ProcessKeys: TProcessKeys );
begin
  if Assigned( ProcessKeys ) then
  begin
    FOnProcessKeys := ProcessKeys;
  end else begin
    FOnProcessKeys := Self.OnProcessKeys;
  end;
end;

initialization

if INPUT_TYPE = RAW then
  RawInput := TRawInput.Create( );

finalization

if INPUT_TYPE = RAW then
  RawInput.Free( );

end.
