unit PGofer.Sound;

interface

uses
  PGofer.Classes, PGofer.Sintatico.Classes;

type
{$M+}
  TPGSound = class( TPGItemCMD )
  private
  public
  published
    function GetDevList( ): string;
    function GetVolume( SoundDriver: Cardinal ): Integer;
    function Mute( SoundDriver: Cardinal ): Integer;
    function PlayFile( FileName: string; Flag: Cardinal ): Boolean;
    function SetVolume( SoundDriver: Cardinal; Volume: Extended ): Integer;
    function SetDevice( SoundDriver: Cardinal; AValue: Cardinal ): Boolean;
    function VolumeStepUp( SoundDriver: Cardinal ): Integer;
    function VolumeStepDown( SoundDriver: Cardinal ): Integer;
  end;
{$TYPEINFO ON}

implementation

uses
  PGofer.Sintatico, PGofer.Sound.Controls;

{ TPGSound }

function TPGSound.GetDevList( ): string;
begin
  Result := SoundGetDevList( );
end;

function TPGSound.GetVolume( SoundDriver: Cardinal ): Integer;
begin
  Result := SoundGetVolume( SoundDriver );
end;

function TPGSound.Mute( SoundDriver: Cardinal ): Integer;
begin
  Result := SoundSetMute( SoundDriver );
end;

function TPGSound.PlayFile( FileName: string; Flag: Cardinal ): Boolean;
begin
  Result := SoundPlayFile( FileName, Flag );
end;

function TPGSound.SetDevice( SoundDriver: Cardinal; AValue: Cardinal ): Boolean;
begin
  Result := SoundSetDevice( SoundDriver , AValue );
end;

function TPGSound.SetVolume( SoundDriver: Cardinal; Volume: Extended ): Integer;
begin
  Result := SoundSetVolume( SoundDriver, Volume );
end;

function TPGSound.VolumeStepDown( SoundDriver: Cardinal ): Integer;
begin
  Result := SoundVolumeStepDown( SoundDriver );
end;

function TPGSound.VolumeStepUp( SoundDriver: Cardinal ): Integer;
begin
  Result := SoundVolumeStepUp( SoundDriver );
end;

initialization

TPGSound.Create( GlobalItemCommand );

finalization

end.
