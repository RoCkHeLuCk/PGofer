unit PGofer.Sound.Controls;

interface

uses
  PGofer.Sound.DevApi;

function SoundCreateInstance( SoundDriver: Cardinal;
   var endpointVolume: IAudioEndpointVolume ): Boolean;
function SoundPlayFile( FileName: string; Flag: Cardinal ): Boolean;
function SoundSetMute( SoundDriver: Cardinal ): Integer;
function SoundVolumeStepUp( SoundDriver: Cardinal ): Integer;
function SoundVolumeStepDown( SoundDriver: Cardinal ): Integer;
function SoundGetVolume( SoundDriver: Cardinal ): Integer;
function SoundSetVolume( SoundDriver: Cardinal; Value: Extended ): Integer;

implementation

uses
  WinApi.MMSystem, WinApi.ActiveX, System.SysUtils;

function SoundCreateInstance( SoundDriver: Cardinal;
   var endpointVolume: IAudioEndpointVolume ): Boolean;
var
  deviceEnumerator: IMMDeviceEnumerator;
  defaultDevice   : IMMDevice;
begin
  try
    CoCreateInstance( CLASS_IMMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER,
       IID_IMMDeviceEnumerator, deviceEnumerator );
    deviceEnumerator.GetDefaultAudioEndpoint( eRender, SoundDriver,
       defaultDevice );
    defaultDevice.Activate( IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil,
       endpointVolume );
    Result := ( endpointVolume <> nil );
  except
    Result := False;
  end;
end;

function SoundPlayFile( FileName: string; Flag: Cardinal ): Boolean;
begin
  Result := SndPlaySound( PWideChar( FileName ), Flag );
end;

function SoundSetMute( SoundDriver: Cardinal ): Integer;
var
  endpointVolume: IAudioEndpointVolume;
  Mudo          : Boolean;
  Volume        : Cardinal;
begin
  if ( Win32MajorVersion >= 6 ) then
  begin
    if ( SoundCreateInstance( SoundDriver, endpointVolume ) ) then
    begin
      endpointVolume.GetMute( Mudo );
      Mudo := not Mudo;
      Result := endpointVolume.SetMute( Mudo, nil );
    end
    else
      Result := 0;
  end else begin
    waveOutGetVolume( SoundDriver, @Volume );
    if Volume <> $0000 then
      Result := waveOutSetVolume( SoundDriver, $0000 )
    else
      Result := waveOutSetVolume( SoundDriver, $FFFF );
  end;

end;

function SoundVolumeStepUp( SoundDriver: Cardinal ): Integer;
var
  endpointVolume: IAudioEndpointVolume;
  Volume        : Cardinal;
begin
  Result := 0;
  if ( Win32MajorVersion >= 6 ) then
  begin
    if ( SoundCreateInstance( SoundDriver, endpointVolume ) ) then
      Result := endpointVolume.VolumeStepUp( nil );
  end else begin
    waveOutGetVolume( SoundDriver, @Volume );
    if Volume < $F0F0 then
      Result := waveOutSetVolume( SoundDriver, Volume + $0F0F )
  end;
end;

function SoundVolumeStepDown( SoundDriver: Cardinal ): Integer;
var
  endpointVolume: IAudioEndpointVolume;
  Volume        : Cardinal;
begin
  Result := 0;
  if ( Win32MajorVersion >= 6 ) then
  begin
    if ( SoundCreateInstance( SoundDriver, endpointVolume ) ) then
      Result := endpointVolume.VolumeStepDown( nil )
  end else begin
    waveOutGetVolume( SoundDriver, @Volume );
    if Volume > $0F0F then
      Result := waveOutSetVolume( SoundDriver, Volume - $0F0F );
  end;
end;

function SoundGetVolume( SoundDriver: Cardinal ): Integer;
var
  endpointVolume: IAudioEndpointVolume;
  Volume        : Single;
  Volume2       : Cardinal;
begin
  if ( Win32MajorVersion >= 6 ) then
  begin
    if ( SoundCreateInstance( SoundDriver, endpointVolume ) ) then
    begin
      endpointVolume.GetMasterVolumeLevelScaler( Volume );
      Result := Trunc( Volume * 100 );
    end
    else
      Result := 0;
  end else begin
    waveOutGetVolume( SoundDriver, @Volume2 );
    Result := ( Volume2 * 100 ) div 65535;
  end;
end;

function SoundSetVolume( SoundDriver: Cardinal; Value: Extended ): Integer;
var
  endpointVolume: IAudioEndpointVolume;
  Volume        : Single;
  Volume2       : Cardinal;
begin
  if ( Win32MajorVersion >= 6 ) then
  begin
    if ( SoundCreateInstance( SoundDriver, endpointVolume ) ) then
    begin
      Volume := ( Value / 100 );
      Result := endpointVolume.SetMasterVolumeLevelScalar( Volume, nil );
    end
    else
      Result := 0;
  end else begin
    Volume2 := ( Trunc( Value ) * 65535 ) div 100;
    Result := waveOutSetVolume( SoundDriver, Volume2 );
  end;
end;

end.
