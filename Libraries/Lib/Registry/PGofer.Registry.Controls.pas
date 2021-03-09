unit PGofer.Registry.Controls;

interface

function RegistryDelete(RootKey: NativeUInt; OpenKey, Key: String): Boolean;
function RegistryRead(RootKey: NativeUInt; OpenKey, Key: String): String;
function RegistryWrite(RootKey: NativeUInt;
  OpenKey, Key, Value: String): Boolean;

implementation

uses
    System.Win.Registry;

function RegistryDelete(RootKey: NativeUInt; OpenKey, Key: String): Boolean;
var
    Reg: TRegistry;
begin
    Result := False;
    Reg := TRegistry.Create;
    try
        Reg.RootKey := RootKey;
        if (Key = '') then
        begin
            Result := Reg.DeleteKey(OpenKey);
        end
        else
        begin
            if Reg.OpenKey(OpenKey, False) and Reg.ValueExists(Key) then
            begin
                Result := Reg.DeleteValue(Key);
            end;
        end;
    finally
        Reg.free;
    end;
end;

function RegistryRead(RootKey: NativeUInt; OpenKey, Key: String): String;
var
    Reg: TRegistry;
begin
    Result := '';
    Reg := TRegistry.Create;
    try
        Reg.RootKey := RootKey;
        if (Reg.OpenKeyReadOnly(OpenKey)) and (Reg.ValueExists(Key)) then
        begin
            Result := Reg.ReadString(Key);
        end;
    finally
        Reg.free;
    end;
end;

function RegistryWrite(RootKey: NativeUInt;
  OpenKey, Key, Value: String): Boolean;
var
    Reg: TRegistry;
begin
    Result := False;
    Reg := TRegistry.Create;
    try
        Reg.RootKey := RootKey;
        if (Reg.OpenKey(OpenKey, True)) then
        begin
            if not Reg.ValueExists(Key) then
                Reg.CreateKey(Key);
            Reg.WriteString(Key, Value);
            Result := True;
        end;
    finally
        Reg.free;
    end;
end;

end.
