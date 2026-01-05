unit PGofer.Registry.Environment;

interface

uses
  PGofer.Runtime;

type
  {$M+}
  TPGRegistryEnvironment = class( TPGItemCMD )
  private
  public
  published
    function Delete( Key: string ): Boolean;
    function Read( Key: string ): string;
    function Write( Key, Value: string ): Boolean;
    function Add( Key, Value: string ): Boolean;
    function Remove( Key, Value: string ): Boolean;
  end;
  {$TYPEINFO ON}

implementation

uses
  PGofer.Registry.Controls;

{ Registry Environment }

function TPGRegistryEnvironment.Delete( Key: string ): Boolean;
begin
  Result := RegistryEnvironmentDelete( Key );
end;

function TPGRegistryEnvironment.Read( Key: string ): string;
begin
  Result := RegistryEnvironmentRead( Key );
end;

function TPGRegistryEnvironment.Write( Key, Value: string ): Boolean;
begin
  Result := RegistryEnvironmentWrite( Key, Value );
end;

function TPGRegistryEnvironment.Add( Key, Value: string ): Boolean;
begin
  Result := RegistryEnvironmentAdd( Key, Value );
end;

function TPGRegistryEnvironment.Remove( Key, Value: string ): Boolean;
begin
  Result := RegistryEnvironmentRemove( Key, Value );
end;

end.
