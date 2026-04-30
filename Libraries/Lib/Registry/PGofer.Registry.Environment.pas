unit PGofer.Registry.Environment;

interface

uses
  PGofer.Core, PGofer.Runtime;

type
  {$M+}
  TPGRegistryEnvironment = class( TPGItemClass )
  private
    procedure CheckResult(ASuccess: Boolean; const AKey: string);
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

procedure TPGRegistryEnvironment.CheckResult(ASuccess: Boolean; const AKey: string);
begin
  if not ASuccess then
    TPGKernel.Console('Error Environment: Failed on [%s] - %s',
      [AKey, RegistryGetLastErrorMessage]);
end;

function TPGRegistryEnvironment.Delete( Key: string ): Boolean;
begin
  Result := RegistryEnvironmentDelete( Key );
  CheckResult(Result, Key);
end;

function TPGRegistryEnvironment.Read( Key: string ): string;
begin
  Result := RegistryEnvironmentRead( Key );
end;

function TPGRegistryEnvironment.Write( Key, Value: string ): Boolean;
begin
  Result := RegistryEnvironmentWrite( Key, Value );
  CheckResult(Result, Key);
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
