unit PGofer.HotKey;

interface

uses
    System.Generics.Collections,
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes,
    PGofer.HotKey.Hook;

type
{$M+}
    TPGHotKeys = class(TPGItemCMD)
    private
        FKeys: TList<Word>;
        FDetect: Byte;
        FInhibit: Boolean;
        FScript: String;
        FMirror: TPGHotKeys;
        function GetKeysHex():String;
        procedure SetKeysHex(Value:String);
        procedure ExecutarNivel1();
    public
        constructor Create(ItemDad: TPGItem; Name: String); overload;
        destructor Destroy(); override;
        property Keys: TList<Word> read FKeys;
        function GetKeysName(): String;
        procedure Execute(Gramatica: TGramatica); override;
        procedure Frame(Parent: TObject); override;
        procedure Mirroring();
        class var GlobList: TPGItem;
        class function LocateHotKeys(Keys: TList<Word>): TPGHotKeys;
    published
        property HotKeysHex: String read GetKeysHex write SetKeysHex;
        property Detect: Byte read FDetect write FDetect;
        property Inhibit: Boolean read FInhibit write FInhibit;
        property Script: String read FScript write FScript;
    end;
{$TYPEINFO ON}

    TPGHotKeyDec = class(TPGItemCMD)
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

implementation

uses
    System.SysUtils, PGofer.Key.Controls,
    PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.Types,
    PGofer.HotKey.Frame;

{ TPGHotKey }

constructor TPGHotKeys.Create(ItemDad: TPGItem; Name: String);
begin
    inherited Create(ItemDad, Name);
    Self.ReadOnly := False;
    FKeys := TList<Word>.Create;
    FDetect := 0;
    FInhibit := False;
    FScript := '';
    if ItemDad <> TPGHotKeys.GlobList then
       FMirror := TPGHotKeys.Create(TPGHotKeys.GlobList, Name)
    else
       FMirror := nil;
end;

destructor TPGHotKeys.Destroy();
begin
    FDetect := 0;
    FInhibit := False;
    FScript := '';
    FKeys.Clear;
    FKeys.Free;
    FKeys := nil;
    if Assigned(FMirror) then
       FMirror.Free();
    FMirror := nil;
    inherited;
end;

procedure TPGHotKeys.ExecutarNivel1();
begin
    ScriptExec('HotKey: ' + Self.Name, Self.Script, nil);
end;

procedure TPGHotKeys.Execute(Gramatica: TGramatica);
begin
    if Assigned(Gramatica) then
    begin
        inherited Execute(Gramatica);
        if Gramatica.TokenList.Token.Classe <> cmdDot then
           Self.ExecutarNivel1();
    end
    else
    begin
        Self.ExecutarNivel1();
    end;
end;

procedure TPGHotKeys.Frame(Parent: TObject);
begin
    inherited Frame(Parent);
    TPGFrameHotKey.Create(Self, Parent);
end;

function TPGHotKeys.GetKeysHex(): String;
var
    Key: Word;
begin
    Result := '';
    for Key in FKeys do
        Result := Result + IntToHex(Key, 3);
end;

procedure TPGHotKeys.SetKeysHex(Value: String);
var
    c: SmallInt;
    Key: Word;
begin
    FKeys.Clear;
    c := Low(Value);
    while c + 2 <= High(Value) do
    begin
        Key := StrToInt('$' + copy(Value, c, 3));
        if not FKeys.Contains(Key) then
           FKeys.Add(Key);
        inc(c, 3);
    end;
end;

function TPGHotKeys.GetKeysName(): String;
var
    Key: Word;
begin
    Result := '';
    for Key in FKeys do
    begin
        if Result.IsEmpty then
           Result := KeyVirtualToStr(Key)
        else
           Result := Result + ' + ' + KeyVirtualToStr(Key);
    end;
end;

class function TPGHotKeys.LocateHotKeys(Keys: TList<Word>): TPGHotKeys;
var
    KeysCount: SmallInt;
    ListCount: SmallInt;
    AuxHotKeys: TPGHotKeys;
    C, D: SmallInt;
    Find: Boolean;
begin
    Result := nil;
    KeysCount := Keys.Count;
    if KeysCount > 0 then
    begin
        ListCount := TPGHotKeys.GlobList.Count;
        Find := False;
        C := 0;
        while (C < ListCount) and (not Find) do
        begin
            AuxHotKeys := TPGHotKeys(TPGHotKeys.GlobList[C]);
            if AuxHotKeys.Enabled then
            begin
                if KeysCount = AuxHotKeys.Keys.Count then
                begin
                    D := 0;
                    Find := True;
                    while (D < KeysCount) and (Find) do
                    begin
                        Find := AuxHotKeys.FKeys[D] = Keys[D];
                        inc(D);
                    end;
                    if Find then
                        Result := AuxHotKeys;
                end;
            end;
            inc(C);
        end;
    end;
end;

procedure TPGHotKeys.Mirroring();
begin
    FMirror.Enabled := Self.Enabled;
    FMirror.ReadOnly := Self.ReadOnly;
    FMirror.FKeys := Self.FKeys;
    FMirror.FDetect := Self.FDetect;
    FMirror.FInhibit := Self.FInhibit;
    FMirror.FScript := Self.FScript;
end;

{ TPGHotKey }

procedure TPGHotKeyDec.Execute(Gramatica: TGramatica);
var
    Titulo: String;
    Quantidade: Byte;
    HotKey: TPGHotKeys;
    id : TPGItem;
begin
    Gramatica.TokenList.GetNextToken;
    id := IdentificadorLocalizar(Gramatica);
    if (not Assigned(id)) or (id is TPGHotKeys) then
    begin
        Titulo := Gramatica.TokenList.Token.Lexema;
        Quantidade := LerParamentros(Gramatica, 1, 4);
        if not Gramatica.Erro then
        begin
            if (not Assigned(id)) then
               HotKey := TPGHotKeys.Create(TPGHotKeys.GlobList, Titulo)
            else
               HotKey := TPGHotKeys(Id);

            if Quantidade = 4 then
               HotKey.Detect := Gramatica.Pilha.Desempilhar(0);

            if Quantidade >= 3 then
               HotKey.Inhibit := Gramatica.Pilha.Desempilhar(False);

            if Quantidade >= 2 then
               HotKey.SetKeysHex(Gramatica.Pilha.Desempilhar(''));

            if Quantidade >= 1 then
                HotKey.Script := Gramatica.Pilha.Desempilhar('');
        end;
    end
    else
        Gramatica.ErroAdd('Identificador esperado o já existente.');
end;

initialization
    TPGHotKeyDec.Create(GlobalItemCommand,'HotKey');
    TPGHotKeys.GlobList := TPGFolder.Create(GlobalItemTrigger,'HotKey');
    GlobalCollection.RegisterClass(TPGHotKeys);

finalization

end.
