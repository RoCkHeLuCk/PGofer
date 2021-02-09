unit PGofer.Registry.Environment;

interface

uses
    PGofer.Sintatico.Classes;

type
{$M+}
    TPGRegistryEnvironment = class(TPGItemCMD)
    private
    public
        constructor Create();
    published
        function Delete(Key: String): Boolean;
        function Read(Key: String): String;
        function Write(Key, Value: String): Boolean;
        function Add(Key, Value: String): Boolean;
        function Remove(Key, Value: String): Boolean;
    end;
{$TYPEINFO ON}


implementation
uses
   Winapi.Windows, Winapi.Messages, PGofer.Registry.Controls;

{ Registry Environment }
const
    REG_ENVIRONMENT_LOCATION =
        'System\CurrentControlSet\Control\Session Manager\Environment';


constructor TPGRegistryEnvironment.Create;
begin
    inherited Create('Environment');
end;

function TPGRegistryEnvironment.Delete(Key: String): Boolean;
begin
    if Key <> '' then
        Result := RegistryDelete(HKEY_LOCAL_MACHINE,
            REG_ENVIRONMENT_LOCATION, Key)
    else
        Result := False;
end;

function TPGRegistryEnvironment.Read(Key: String): String;
begin
    Result := RegistryRead(HKEY_LOCAL_MACHINE, REG_ENVIRONMENT_LOCATION, Key);
end;

function TPGRegistryEnvironment.Write(Key, Value: String): Boolean;
begin
    Result := RegistryWrite(HKEY_LOCAL_MACHINE, REG_ENVIRONMENT_LOCATION,
        Key, Value);

    // SendMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0,
    // LPARAM(PChar('Environment')));
    SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0,
        LPARAM(PChar('Environment')), SMTO_ABORTIFHUNG, 5000, nil);
end;

function TPGRegistryEnvironment.Add(Key, Value: String): Boolean;
var
    Content : String;
begin
    Content := Self.Read(Key);
    if Pos(Value, Content) = -1 then
       Result := Self.Write(Key, Content  + Value)
    else
       Result := false;
end;

function TPGRegistryEnvironment.Remove(Key, Value: String): Boolean;
var
    Content : String;
    I : Integer;
begin
    Content := Self.Read(Key);
    I := Pos(Value, Content);
    if I <> -1 then
    begin
       System.Delete(Content, I, Length(Value));
       Result := Self.Write(Key, Content);
    end else
       Result := false;
end;


end.
