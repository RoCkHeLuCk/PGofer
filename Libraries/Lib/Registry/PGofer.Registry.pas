unit PGofer.Registry;

interface

uses
   PGofer.Core, PGofer.Runtime, PGofer.Registry.Environment;

type
  {$M+}
  TPGRegistry = class( TPGItemClass )
  private
    FEnvironment: TPGRegistryEnvironment;
    procedure CheckResult(ASuccess: Boolean; const AKey: string);
  public
  published
    property Environment: TPGRegistryEnvironment read FEnvironment;
    function Delete( RootKey: NativeUInt; OpenKey, Key: string ): Boolean;
    function Read( RootKey: NativeUInt; OpenKey, Key: string ): string;
    function Write( RootKey: NativeUInt; OpenKey, Key, Value: string ): Boolean;
  end;
  {$TYPEINFO ON}

var
  PGRegistry: TPGRegistry;

implementation

uses
  PGofer.Registry.Controls;

{ TPGRegistry }

procedure TPGRegistry.CheckResult(ASuccess: Boolean; const AKey: string);
begin
  if not ASuccess then
    TPGKernel.Console('Error Registry: Failed on [%s] - %s', [AKey, RegistryGetLastErrorMessage]);
end;

function TPGRegistry.Delete( RootKey: NativeUInt;
  OpenKey, Key: string ): Boolean;
begin
  Result := RegistryDelete( RootKey, OpenKey, Key );
  CheckResult(Result, OpenKey + '\' + Key);
end;

function TPGRegistry.Read( RootKey: NativeUInt; OpenKey, Key: string ): string;
begin
  Result := RegistryRead( RootKey, OpenKey, Key );
  if (Result = '') and (RegistryGetLastErrorMessage <> '') then
     CheckResult(False, OpenKey + '\' + Key);
end;

function TPGRegistry.Write( RootKey: NativeUInt;
  OpenKey, Key, Value: string ): Boolean;
begin
  Result := RegistryWrite( RootKey, OpenKey, Key, Value );
  CheckResult(Result, OpenKey + '\' + Key);
end;

initialization

  PGRegistry := TPGRegistry.Create( GlobalItemCommand );

finalization

  PGRegistry := nil;

end.
