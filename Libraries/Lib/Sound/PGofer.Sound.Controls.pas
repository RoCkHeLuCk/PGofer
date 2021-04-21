unit PGofer.Sound.Controls;

interface

uses
  PGofer.Sound.MMDevApi;

function SoundCreateInstance( SoundDriver: Cardinal ): IAudioEndpointVolume;
function SoundPlayFile( FileName: string; Flag: Cardinal ): Boolean;
function SoundSetMute( SoundDriver: Cardinal ): Integer;
function SoundVolumeStepUp( SoundDriver: Cardinal ): Integer;
function SoundVolumeStepDown( SoundDriver: Cardinal ): Integer;
function SoundGetVolume( SoundDriver: Cardinal ): Integer;
function SoundSetVolume( SoundDriver: Cardinal; Value: Extended ): Integer;
function SoundGetDevList( ): string;
function SoundSetDevice( SoundDriver: Cardinal; AValue: Cardinal ): Boolean;

implementation

uses
  System.Classes, WinApi.MMSystem, WinApi.ActiveX, System.SysUtils;

function SoundCreateInstance( SoundDriver: Cardinal ): IAudioEndpointVolume;
var
  deviceEnumerator: IMMDeviceEnumerator;
  defaultDevice: IMMDevice;
  EndPoint: IAudioEndpointVolume;
begin
  EndPoint := nil;
  TThread.Synchronize( nil,
    procedure
    begin
      try
        CoCreateInstance( CLASS_IMMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER,
           IID_IMMDeviceEnumerator, deviceEnumerator );
        deviceEnumerator.GetDefaultAudioEndpoint( eRender, SoundDriver,
           defaultDevice );
        defaultDevice.Activate( IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER,
           nil, EndPoint );
      except
      end;
    end );
  Result := EndPoint;
end;

function SoundPlayFile( FileName: string; Flag: Cardinal ): Boolean;
begin
  Result := SndPlaySound( PWideChar( FileName ), Flag );
end;

function SoundSetMute( SoundDriver: Cardinal ): Integer;
var
  EndPoint: IAudioEndpointVolume;
  Mudo: Boolean;
  Volume: Cardinal;
begin
  if ( Win32MajorVersion >= 6 ) then
  begin
    EndPoint := SoundCreateInstance( SoundDriver );
    if Assigned( EndPoint ) then
    begin
      EndPoint.GetMute( Mudo );
      Mudo := not Mudo;
      Result := EndPoint.SetMute( Mudo, nil );
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
  EndPoint: IAudioEndpointVolume;
  Volume: Cardinal;
begin
  Result := 0;
  if ( Win32MajorVersion >= 6 ) then
  begin
    EndPoint := SoundCreateInstance( SoundDriver );
    if Assigned( EndPoint ) then
      Result := EndPoint.VolumeStepUp( nil );
  end else begin
    waveOutGetVolume( SoundDriver, @Volume );
    if Volume < $F0F0 then
      Result := waveOutSetVolume( SoundDriver, Volume + $0F0F )
  end;
end;

function SoundVolumeStepDown( SoundDriver: Cardinal ): Integer;
var
  EndPoint: IAudioEndpointVolume;
  Volume: Cardinal;
begin
  Result := 0;
  if ( Win32MajorVersion >= 6 ) then
  begin
    EndPoint := SoundCreateInstance( SoundDriver );
    if Assigned( EndPoint ) then
      Result := EndPoint.VolumeStepDown( nil )
  end else begin
    waveOutGetVolume( SoundDriver, @Volume );
    if Volume > $0F0F then
      Result := waveOutSetVolume( SoundDriver, Volume - $0F0F );
  end;
end;

function SoundGetVolume( SoundDriver: Cardinal ): Integer;
var
  EndPoint: IAudioEndpointVolume;
  Volume: Single;
  Volume2: Cardinal;
begin
  if ( Win32MajorVersion >= 6 ) then
  begin
    EndPoint := SoundCreateInstance( SoundDriver );
    if Assigned( EndPoint ) then
    begin
      EndPoint.GetMasterVolumeLevelScaler( Volume );
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
  EndPoint: IAudioEndpointVolume;
  Volume: Single;
  Volume2: Cardinal;
begin
  if ( Win32MajorVersion >= 6 ) then
  begin
    EndPoint := SoundCreateInstance( SoundDriver );
    if Assigned( EndPoint ) then
    begin
      Volume := ( Value / 100 );
      Result := EndPoint.SetMasterVolumeLevelScalar( Volume, nil );
    end
    else
      Result := 0;
  end else begin
    Volume2 := ( Trunc( Value ) * 65535 ) div 100;
    Result := waveOutSetVolume( SoundDriver, Volume2 );
  end;
end;

function SoundGetDevList( ): string;
var
  WaveOutCaps: TWaveOutCaps;
  c: Integer;
begin
  Result := '';
  for c := 0 to WaveOutGetNumDevs do
  begin
    waveOutGetDevCaps( c, @WaveOutCaps, sizeof( WaveOutCaps ) );
    Result := Result + IntToStr( c ) + ': ' + WaveOutCaps.szPname + #13#10;
  end;
end;

function SoundSetDevice( SoundDriver: Cardinal; AValue: Cardinal ): Boolean;
var
  Resposta : Boolean;
begin
  TThread.Synchronize( nil,
    procedure
    begin
      Resposta := waveOutMessage( HWAVEIN( WAVE_MAPPER ),
         DRVM_MAPPER_PREFERRED_SET, SoundDriver, AValue ) = MMSYSERR_NOERROR;
    end );
  Result := Resposta;
end;

end.
