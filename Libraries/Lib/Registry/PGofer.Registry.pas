unit PGofer.Registry;

interface

uses
    PGofer.Sintatico.Classes;

type
{$M+}
    TPGRegistry = class(TPGItemCMD)
    private
        FEnvironment : TPGItemCMD;
    public
        constructor Create();
        destructor Destroy(); override;
        property Environment: TPGItemCMD read FEnvironment;
    published
        function Delete(RootKey: NativeUInt; OpenKey, Key: String): Boolean;
        function Read(RootKey: NativeUInt; OpenKey, Key: String): String;
        function Write(RootKey: NativeUInt;
            OpenKey, Key, Value: String): Boolean;
    end;
{$TYPEINFO ON}

var
    PGRegistry : TPGRegistry;

implementation

uses
    PGofer.Sintatico, PGofer.Registry.Controls, PGofer.Registry.Environment;

{ TPGRegistry }

constructor TPGRegistry.Create;
begin
    inherited Create();
    FEnvironment := TPGRegistryEnvironment.Create();
    Self.Add(FEnvironment);
end;

destructor TPGRegistry.Destroy;
begin
    FEnvironment.Free;
    inherited Destroy();
end;

function TPGRegistry.Delete(RootKey: NativeUInt; OpenKey, Key: String): Boolean;
begin
    Result := RegistryDelete(RootKey, OpenKey, Key);
end;

function TPGRegistry.Read(RootKey: NativeUInt; OpenKey, Key: String): String;
begin
    Result := RegistryRead(RootKey, OpenKey, Key);
end;

function TPGRegistry.Write(RootKey: NativeUInt;
    OpenKey, Key, Value: String): Boolean;
begin
    Result := RegistryWrite(RootKey, OpenKey, Key, Value);
end;

initialization
    PGRegistry :=  TPGRegistry.Create();
    TGramatica.Global.FindName('Commands').Add(PGRegistry);

finalization

end.
