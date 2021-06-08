unit PGofer.Registry.Controls;

interface

function RegistryDelete( RootKey: NativeUInt; OpenKey, Key: string ): Boolean;
function RegistryRead( RootKey: NativeUInt; OpenKey, Key: string ): string;
function RegistryWrite( RootKey: NativeUInt;
  OpenKey, Key, Value: string ): Boolean;

function RegistryEnvironmentDelete( Key: string ): Boolean;
function RegistryEnvironmentRead( Key: string ): string;
function RegistryEnvironmentWrite( Key, Value: string ): Boolean;
function RegistryEnvironmentAdd( Key, Value: string ): Boolean;
function RegistryEnvironmentRemove( Key, Value: string ): Boolean;

implementation

uses
  Winapi.Windows, Winapi.Messages, System.Win.Registry;

const
  REG_ENVIRONMENT_LOCATION =
    'System\CurrentControlSet\Control\Session Manager\Environment';

function RegistryDelete( RootKey: NativeUInt; OpenKey, Key: string ): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := RootKey;
    if ( Key = '' ) then
    begin
      Result := Reg.DeleteKey( OpenKey );
    end else begin
      if Reg.OpenKey( OpenKey, False ) and Reg.ValueExists( Key ) then
      begin
        Result := Reg.DeleteValue( Key );
      end;
    end;
  finally
    Reg.free;
  end;
end;

function RegistryRead( RootKey: NativeUInt; OpenKey, Key: string ): string;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create;
  try
    Reg.RootKey := RootKey;
    if ( Reg.OpenKeyReadOnly( OpenKey ) ) and ( Reg.ValueExists( Key ) ) then
    begin
      Result := Reg.ReadString( Key );
    end;
  finally
    Reg.free;
  end;
end;

function RegistryWrite( RootKey: NativeUInt;
  OpenKey, Key, Value: string ): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := RootKey;
    if ( Reg.OpenKey( OpenKey, True ) ) then
    begin
      if not Reg.ValueExists( Key ) then
        Reg.CreateKey( Key );
      Reg.WriteString( Key, Value );
      Result := True;
    end;
  finally
    Reg.free;
  end;
end;

function RegistryEnvironmentDelete( Key: string ): Boolean;
begin
  if Key <> '' then
    Result := RegistryDelete( HKEY_LOCAL_MACHINE,
      REG_ENVIRONMENT_LOCATION, Key )
  else
    Result := False;
end;

function RegistryEnvironmentRead( Key: string ): string;
begin
  Result := RegistryRead( HKEY_LOCAL_MACHINE, REG_ENVIRONMENT_LOCATION, Key );
end;

function RegistryEnvironmentWrite( Key, Value: string ): Boolean;
begin
  Result := RegistryWrite( HKEY_LOCAL_MACHINE, REG_ENVIRONMENT_LOCATION,
    Key, Value );

  // SendMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0,
  // LPARAM(PChar('Environment')));
  SendMessageTimeout( HWND_BROADCAST, WM_SETTINGCHANGE, 0,
    LPARAM( PChar( 'Environment' ) ), SMTO_ABORTIFHUNG, 5000, nil );
end;

function RegistryEnvironmentAdd( Key, Value: string ): Boolean;
var
  Content: string;
begin
  Content := RegistryEnvironmentRead( Key );
  if Pos( Value, Content ) = -1 then
    Result := RegistryEnvironmentWrite( Key, Content + Value )
  else
    Result := False;
end;

function RegistryEnvironmentRemove( Key, Value: string ): Boolean;
var
  Content: string;
  I: Integer;
begin
  Content := RegistryEnvironmentRead( Key );
  I := Pos( Value, Content );
  if I <> -1 then
  begin
    System.Delete( Content, I, Length( Value ) );
    Result := RegistryEnvironmentWrite( Key, Content );
  end
  else
    Result := False;
end;

end.
