unit PGofer.Registry;

interface

uses
  PGofer.Classes, PGofer.Runtime;

type
  {$M+}
  TPGRegistry = class( TPGItemCMD )
  private
    FEnvironment: TPGItemCMD;
  public
    constructor Create( AItemDad: TPGItem );
    destructor Destroy( ); override;
    property Environment: TPGItemCMD read FEnvironment;
  published
    function Delete( RootKey: NativeUInt; OpenKey, Key: string ): Boolean;
    function Read( RootKey: NativeUInt; OpenKey, Key: string ): string;
    function Write( RootKey: NativeUInt; OpenKey, Key, Value: string ): Boolean;
  end;
  {$TYPEINFO ON}

implementation

uses
  PGofer.Registry.Controls, PGofer.Registry.Environment;

{ TPGRegistry }

constructor TPGRegistry.Create( AItemDad: TPGItem );
begin
  inherited Create( AItemDad );
  FEnvironment := TPGRegistryEnvironment.Create( Self, 'Environment' );
end;

destructor TPGRegistry.Destroy( );
begin
  FEnvironment.Free( );
  inherited Destroy( );
end;

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

TPGRegistry.Create( GlobalItemCommand );

finalization

end.
