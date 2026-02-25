unit PGofer.Registry;

interface

uses
  PGofer.Runtime, PGofer.Registry.Environment;

type
  {$M+}
  TPGRegistry = class( TPGItemClass )
  private
    FEnvironment: TPGRegistryEnvironment;
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

function TPGRegistry.Delete( RootKey: NativeUInt;
  OpenKey, Key: string ): Boolean;
begin
  Result := RegistryDelete( RootKey, OpenKey, Key );
end;

function TPGRegistry.Read( RootKey: NativeUInt; OpenKey, Key: string ): string;
begin
  Result := RegistryRead( RootKey, OpenKey, Key );
end;

function TPGRegistry.Write( RootKey: NativeUInt;
  OpenKey, Key, Value: string ): Boolean;
begin
  Result := RegistryWrite( RootKey, OpenKey, Key, Value );
end;

initialization

  PGRegistry := TPGRegistry.Create( GlobalItemCommand );

finalization

  PGRegistry := nil;

end.
