unit PGofer.Key;

interface

uses
    PGofer.Sintatico.Classes;

type

{$M+}
    TPGKey = class(TPGItemCMD)
    private
    public
    published
        procedure AllUp();
        procedure ExecMacro(Text: String; Delay: Cardinal);
        function FromChar(Key: Char): SmallInt;
        function isPress(Key: Word): Boolean;
        procedure SetPress(Key: SmallInt);
        procedure SetUp(Key: SmallInt);
        function ToChar(Key: SmallInt): Char;
    end;
{$TYPEINFO ON}

var
    PGKey : TPGKey;

implementation

uses
    PGofer.Sintatico, PGofer.Key.Controls;

{ TPGRegistry }

procedure TPGKey.AllUp;
begin
    KeyPressAllUp();
end;

procedure TPGKey.ExecMacro(Text: String; Delay: Cardinal);
begin
    KeyMacroPress(Text, Delay);
end;

function TPGKey.FromChar(Key: Char): SmallInt;
begin
    Result := CharToKey(Key);
end;

function TPGKey.isPress(Key: Word): Boolean;
begin
    Result := KeyGetPress(Key);
end;

procedure TPGKey.SetPress(Key: SmallInt);
begin
    KeySetPress(Key, True);
end;

procedure TPGKey.SetUp(Key: SmallInt);
begin
    KeySetPress(Key, False);
end;

function TPGKey.ToChar(Key: SmallInt): Char;
begin
    Result := Char(Key);
end;

initialization
    PGKey := TPGKey.Create();
    TGramatica.Global.FindName('Commands').Add(PGKey);

finalization

end.
