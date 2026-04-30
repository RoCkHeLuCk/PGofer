unit PGofer.Registry.Controls;

interface

function RegistryGetLastErrorMessage: string;

function RegistryDelete( RootKey: NativeUInt; OpenKey, Key: string ): Boolean;
function RegistryRead( RootKey: NativeUInt; OpenKey, Key: string ): string;
function RegistryWrite( RootKey: NativeUInt; OpenKey, Key, Value: string ): Boolean;

function RegistryEnvironmentDelete( Key: string ): Boolean;
function RegistryEnvironmentRead( Key: string ): string;
function RegistryEnvironmentWrite( Key, Value: string ): Boolean;
function RegistryEnvironmentAdd( Key, Value: string ): Boolean;
function RegistryEnvironmentRemove( Key, Value: string ): Boolean;

implementation

uses
  System.SysUtils, Winapi.Windows, Winapi.Messages, System.Win.Registry;

const
  REG_ENVIRONMENT_LOCATION =
    'System\CurrentControlSet\Control\Session Manager\Environment';

threadvar
  _LastRegistryErrorCode: DWORD;

function RegistryGetLastErrorMessage: string;
begin
  if _LastRegistryErrorCode = 0 then
    Result := ''
  else
    Result := SysErrorMessage(_LastRegistryErrorCode);
end;

function RegistryDelete( RootKey: NativeUInt; OpenKey, Key: string ): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  _LastRegistryErrorCode := 0;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := RootKey;
    if ( Key = '' ) then
      Result := Reg.DeleteKey( OpenKey )
    else if Reg.OpenKey( OpenKey, False ) then
      Result := Reg.DeleteValue( Key );

    if not Result then _LastRegistryErrorCode := GetLastError;
  finally
    Reg.free;
  end;
end;

function RegistryRead( RootKey: NativeUInt; OpenKey, Key: string ): string;
var
  Reg: TRegistry;
begin
  Result := '';
  _LastRegistryErrorCode := 0;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := RootKey;
    if Reg.OpenKeyReadOnly( OpenKey ) then
    begin
      if Reg.ValueExists( Key ) then
        Result := Reg.ReadString( Key )
      else
        _LastRegistryErrorCode := ERROR_FILE_NOT_FOUND;
    end
    else
      _LastRegistryErrorCode := GetLastError;
  finally
    Reg.free;
  end;
end;

function RegistryWrite( RootKey: NativeUInt; OpenKey, Key, Value: string ): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  _LastRegistryErrorCode := 0;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := RootKey;
    if Reg.OpenKey( OpenKey, True ) then
    begin
      try
        Reg.WriteString( Key, Value );
        Result := True;
      except
        _LastRegistryErrorCode := GetLastError;
      end;
    end
    else
      _LastRegistryErrorCode := GetLastError;
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

  //update environment
  if Result then
  begin
    SetEnvironmentVariable(PChar(Key), PChar(Value));
    SendMessageTimeout( HWND_BROADCAST, WM_SETTINGCHANGE, 0,
      LPARAM( PChar( 'Environment' ) ), SMTO_ABORTIFHUNG, 5000, nil );
  end;
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
