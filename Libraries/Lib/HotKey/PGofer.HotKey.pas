unit PGofer.HotKey;

interface

uses
    System.Generics.Collections,
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes,
    PGofer.HotKey.Hook;

type
    TPGHotKeyMirror = class;

{$M+}
    TPGHotKeyMain = class(TPGItemOriginal)
    private
        FKeys: TList<Word>;
        FDetect: Byte;
        FInhibit: Boolean;
        FScript: String;
        function GetKeysHex():String;
        procedure SetKeysHex(Value:String);
        procedure ExecutarNivel1();
    public
        constructor Create(Name: String; Mirror: TPGItemMirror); overload;
        destructor Destroy(); override;
        class var GlobList: TPGItem;
        procedure Execute(Gramatica: TGramatica); override;
        procedure Frame(Parent: TObject); override;
        property Keys: TList<Word> read FKeys;
        function GetKeysName(): String;
        class function LocateHotKeys(Keys: TList<Word>): TPGHotKeyMain;
    published
        property HotKeysHex: String read GetKeysHex write SetKeysHex;
        property Detect: Byte read FDetect write FDetect;
        property Inhibit: Boolean read FInhibit write FInhibit;
        property Script: String read FScript write FScript;
    end;
{$TYPEINFO ON}

    TPGHotKeyDeclare = class(TPGItemCMD)
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

{$M+}
    TPGHotKeyMirror = class(TPGItemMirror)
    protected
        FOriginal : TPGHotKeyMain;
    public
        constructor Create(ItemDad: TPGItem; Name: String); overload;
        procedure Frame(Parent: TObject); override;
        function GetKeysHex(): String;
        procedure SetKeysHex(Value: String);
        function GetDetect(): Byte;
        procedure SetDetect(Value: Byte);
        function GetInhibit(): Boolean;
        procedure SetInhibit(Value: Boolean);
        function GetScript(): String;
        procedure SetScript(Value: String);
    published
        property HotKeysHex: String read GetKeysHex write SetKeysHex;
        property Detect: Byte read GetDetect write SetDetect;
        property Inhibit: Boolean read GetInhibit write SetInhibit;
        property Script: String read GetScript write SetScript;
    end;
{$TYPEINFO ON}


implementation

uses
    System.SysUtils, PGofer.Key.Controls,
    PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.Types,
    PGofer.HotKey.Frame;

{ TPGHotKeyMain }

constructor TPGHotKeyMain.Create(Name: String; Mirror: TPGItemMirror);
begin
    inherited Create(TPGHotKeyMain.GlobList, Name, Mirror);
    Self.ReadOnly := False;
    FKeys := TList<Word>.Create;
    FDetect := 0;
    FInhibit := False;
    FScript := '';
end;

destructor TPGHotKeyMain.Destroy();
begin
    FDetect := 0;
    FInhibit := False;
    FScript := '';
    FKeys.Clear;
    FKeys.Free;
    FKeys := nil;
    inherited;
end;

procedure TPGHotKeyMain.ExecutarNivel1();
begin
    ScriptExec('HotKey: ' + Self.Name, Self.Script, nil);
end;

procedure TPGHotKeyMain.Execute(Gramatica: TGramatica);
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

procedure TPGHotKeyMain.Frame(Parent: TObject);
begin
    inherited Frame(Parent);
    TPGFrameHotKey.Create(Self, Parent);
end;

function TPGHotKeyMain.GetKeysHex(): String;
var
    Key: Word;
begin
    Result := '';
    for Key in FKeys do
        Result := Result + IntToHex(Key, 3);
end;

procedure TPGHotKeyMain.SetKeysHex(Value: String);
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

function TPGHotKeyMain.GetKeysName(): String;
var
    Key: Word;
begin
    Result := '';
    for Key in FKeys do
    begin
        if Result <> '' then
           Result := KeyVirtualToStr(Key)
        else
           Result := Result + ' + ' + KeyVirtualToStr(Key);
    end;
end;

class function TPGHotKeyMain.LocateHotKeys(Keys: TList<Word>): TPGHotKeyMain;
var
    KeysCount: SmallInt;
    ListCount: SmallInt;
    AuxHotKeys: TPGHotKeyMain;
    C, D: SmallInt;
    Find: Boolean;
begin
    Result := nil;
    KeysCount := Keys.Count;
    if KeysCount > 0 then
    begin
        ListCount := TPGHotKeyMain.GlobList.Count;
        Find := False;
        C := 0;
        while (C < ListCount) and (not Find) do
        begin
            AuxHotKeys := TPGHotKeyMain(TPGHotKeyMain.GlobList[C]);
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

{ TPGHotKeyDeclare }

procedure TPGHotKeyDeclare.Execute(Gramatica: TGramatica);
var
    Titulo: String;
    Quantidade: Byte;
    HotKey: TPGHotKeyMain;
    id : TPGItem;
begin
    Gramatica.TokenList.GetNextToken;
    id := IdentificadorLocalizar(Gramatica);
    if (not Assigned(id)) or (id is TPGHotKeyMain) then
    begin
        Titulo := Gramatica.TokenList.Token.Lexema;
        Quantidade := LerParamentros(Gramatica, 1, 4);
        if not Gramatica.Erro then
        begin
            if (not Assigned(id)) then
               HotKey := TPGHotKeyMain.Create(Titulo, nil)
            else
               HotKey := TPGHotKeyMain(Id);

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

{ TPGHotKeysMirror }

constructor TPGHotKeyMirror.Create(ItemDad: TPGItem; Name: String);
begin
    inherited Create(ItemDad, Name, TPGHotKeyMain.Create(Name, Self));
    Self.ReadOnly := False;
end;

procedure TPGHotKeyMirror.Frame(Parent: TObject);
begin
    inherited Frame(Parent);
    TPGFrameHotKey.Create(Self.FOriginal, Parent);
end;

function TPGHotKeyMirror.GetDetect: Byte;
begin
    Result := FOriginal.Detect;
end;

function TPGHotKeyMirror.GetInhibit: Boolean;
begin
    Result := FOriginal.Inhibit;
end;

function TPGHotKeyMirror.GetKeysHex: String;
begin
    Result := FOriginal.GetKeysHex;
end;

function TPGHotKeyMirror.GetScript: String;
begin
    Result := FOriginal.Script;
end;

procedure TPGHotKeyMirror.SetDetect(Value: Byte);
begin
    FOriginal.Detect := Value;
end;

procedure TPGHotKeyMirror.SetInhibit(Value: Boolean);
begin
    FOriginal.Inhibit := Value;
end;

procedure TPGHotKeyMirror.SetKeysHex(Value: String);
begin
    FOriginal.SetKeysHex(Value);
end;

procedure TPGHotKeyMirror.SetScript(Value: String);
begin
    FOriginal.Script := Value;
end;

initialization
    TPGHotKeyDeclare.Create(GlobalItemCommand,'HotKey');
    TPGHotKeyMain.GlobList := TPGFolder.Create(GlobalItemTrigger,'HotKey');
    GlobalCollection.RegisterClass(TPGHotKeyMirror);

finalization

end.
