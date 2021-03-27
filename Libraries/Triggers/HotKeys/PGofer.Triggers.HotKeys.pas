unit PGofer.Triggers.HotKeys;

interface

uses
    System.Generics.Collections,
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes,
    PGofer.Triggers, PGofer.Triggers.HotKeys.Hook;

type

{$M+}
    TPGHotKey = class(TPGItemTrigger)
    private
        FKeys: TList<Word>;
        FDetect: Byte;
        FInhibit: Boolean;
        FScript: String;
        class var FImageIndex: Integer;
        function GetKeysHex(): String;
        procedure SetKeysHex(Value: String);
    protected
        procedure ExecutarNivel1(); override;
        class function GetImageIndex(): Integer; override;
    public
        constructor Create(Name: String; Mirror: TPGItemMirror); overload;
        destructor Destroy(); override;
        class var GlobList: TPGItem;
        procedure Frame(Parent: TObject); override;
        property Keys: TList<Word> read FKeys;
        function GetKeysName(): String;
        class function LocateHotKeys(Keys: TList<Word>): TPGHotKey;
        function isItemExist(AName: String): Boolean; override;
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

    TPGHotKeyMirror = class(TPGItemMirror)
    protected
        class function GetImageIndex(): Integer; override;
    public
        constructor Create(ItemDad: TPGItem; AName: String); overload;
        procedure Frame(Parent: TObject); override;
    end;

implementation

uses
    System.SysUtils,
    PGofer.Sintatico.Controls,
    PGofer.Key.Controls,
    PGofer.Triggers.HotKeys.Frame,
    PGofer.ImageList;

{ TPGHotKeyMain }

constructor TPGHotKey.Create(Name: String; Mirror: TPGItemMirror);
begin
    inherited Create(TPGHotKey.GlobList, Name, Mirror);
    Self.ReadOnly := False;
    FKeys := TList<Word>.Create;
    FDetect := 0;
    FInhibit := False;
    FScript := '';
end;

destructor TPGHotKey.Destroy();
begin
    FDetect := 0;
    FInhibit := False;
    FScript := '';
    FKeys.Clear;
    FKeys.Free;
    FKeys := nil;
    inherited;
end;

procedure TPGHotKey.ExecutarNivel1();
begin
    ScriptExec('HotKey: ' + Self.Name, Self.Script);
end;

procedure TPGHotKey.Frame(Parent: TObject);
begin
    TPGFrameHotKey.Create(Self, Parent);
end;

class function TPGHotKey.GetImageIndex: Integer;
begin
    Result := FImageIndex;
end;

function TPGHotKey.GetKeysHex(): String;
var
    Key: Word;
begin
    Result := '';
    for Key in FKeys do
        Result := Result + IntToHex(Key, 3);
end;

procedure TPGHotKey.SetKeysHex(Value: String);
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

function TPGHotKey.GetKeysName(): String;
var
    Key: Word;
begin
    Result := '';
    for Key in FKeys do
    begin
        if Result = '' then
            Result := KeyVirtualToStr(Key)
        else
            Result := Result + ' + ' + KeyVirtualToStr(Key);
    end;
end;

function TPGHotKey.isItemExist(AName: String): Boolean;
var
    Item: TPGItem;
begin
    Item := TPGHotKey.GlobList.FindName(AName);
    Result := (Assigned(Item) and (Item <> Self));
end;

class function TPGHotKey.LocateHotKeys(Keys: TList<Word>): TPGHotKey;
var
    KeysCount: SmallInt;
    ListCount: SmallInt;
    AuxHotKeys: TPGHotKey;
    c, D: SmallInt;
    Find: Boolean;
begin
    Result := nil;
    KeysCount := Keys.Count;
    if KeysCount > 0 then
    begin
        ListCount := TPGHotKey.GlobList.Count;
        Find := False;
        c := 0;
        while (c < ListCount) and (not Find) do
        begin
            AuxHotKeys := TPGHotKey(TPGHotKey.GlobList[c]);
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
            inc(c);
        end;
    end;
end;

{ TPGHotKeyDeclare }

procedure TPGHotKeyDeclare.Execute(Gramatica: TGramatica);
var
    Titulo: String;
    Quantidade: Byte;
    HotKey: TPGHotKey;
    id: TPGItem;
begin
    Gramatica.TokenList.GetNextToken;
    id := IdentificadorLocalizar(Gramatica);
    if (not Assigned(id)) or (id is TPGHotKey) then
    begin
        Titulo := Gramatica.TokenList.Token.Lexema;
        Quantidade := LerParamentros(Gramatica, 1, 4);
        if not Gramatica.Erro then
        begin
            if (not Assigned(id)) then
                HotKey := TPGHotKey.Create(Titulo, nil)
            else
                HotKey := TPGHotKey(id);

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
        Gramatica.ErroAdd('Identificador esperado o j� existente.');
end;

{ TPGHotKeysMirror }

constructor TPGHotKeyMirror.Create(ItemDad: TPGItem; AName: String);
begin
    AName := TPGItemMirror.TranscendName(AName, TPGHotKey.GlobList);
    inherited Create(ItemDad, TPGHotKey.Create(AName, Self));
    Self.ReadOnly := False;
end;

procedure TPGHotKeyMirror.Frame(Parent: TObject);
begin
    TPGFrameHotKey.Create(Self.ItemOriginal, Parent);
end;

class function TPGHotKeyMirror.GetImageIndex: Integer;
begin
    Result := TPGHotKey.FImageIndex;
end;

initialization
    TPGHotKeyDeclare.Create(GlobalItemCommand, 'HotKey');
    TPGHotKey.GlobList := TPGFolder.Create(GlobalItemTrigger, 'HotKey');

    TriggersCollect.RegisterClass('HotKeys', TPGHotKeyMirror);
    TPGHotKey.FImageIndex := GlogalImageList.AddIcon('HotKey');

finalization

end.
