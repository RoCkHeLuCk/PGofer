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
        function GetKeysHex():String;
        procedure SetKeysHex(Value:String);
        procedure ExecutarNivel1();
//{$HINTS OFF}
//{$HINTS ON}
    public
        constructor Create(); overload;
        destructor Destroy(); override;
        property Keys: TList<Word> read FKeys;
        function GetKeysName(): String;
        procedure Execute(Gramatica: TGramatica); override;
        procedure Frame(Parent: TObject); override;
        class var HotKeyGlobList: TPGItem;
        class function LocateHotKeys(Keys: TList<Word>): TPGHotKeys;
    published
        property HotKeysHex: String read GetKeysHex write SetKeysHex;
        property Detect: Byte read FDetect write FDetect;
        property Inhibit: Boolean read FInhibit write FInhibit;
        property Script: String read FScript write FScript;
    end;
{$TYPEINFO ON}

    TPGHotKey = class(TPGItemCMD)
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

implementation

uses
    System.SysUtils, PGofer.Key.Controls,
    PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.Types,
    PGofer.HotKey.Frame;

{ TPGHotKey }

constructor TPGHotKeys.Create();
begin
    inherited Create('hk_newHotKey');
    Self.ReadOnly := False;
    FKeys := TList<Word>.Create;
    FDetect := 0;
    FInhibit := False;
    FScript := '';
end;

destructor TPGHotKeys.Destroy();
begin
    FDetect := 0;
    FInhibit := False;
    FScript := '';
    FKeys.Clear;
    FKeys.Free;
    FKeys := nil;
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
    if Self.Count > 0 then
    begin
        for Key in FKeys do
        begin
            if Result.IsEmpty then
               Result := KeyVirtualToStr(Key)
            else
               Result := Result + ' + ' + KeyVirtualToStr(Key);
        end;
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
        ListCount := TPGHotKeys.HotKeyGlobList.Count;
        Find := False;
        C := 0;
        while (C < ListCount) and (not Find) do
        begin
            AuxHotKeys := TPGHotKeys(TPGHotKeys.HotKeyGlobList[C]);
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

{ TPGHotKey }

procedure TPGHotKey.Execute(Gramatica: TGramatica);
var
    Titulo: String;
    Quantidade: Byte;
    Detect: Byte;
    Inibir: Boolean;
    HotKeyHex: String;
    Script: String;
    HotKey: TPGHotKeys;
begin
    Gramatica.TokenList.GetNextToken;
    if (not Assigned(IdentificadorLocalizar(Gramatica))) then
    begin
        Titulo := Gramatica.TokenList.Token.Lexema;
        Quantidade := LerParamentros(Gramatica, 1, 4);
        if not Gramatica.Erro then
        begin
            // ?????????? tentar otimizar isso
            if Quantidade = 4 then
                Detect := Gramatica.Pilha.Desempilhar(0)
            else
                Detect := 0;

            if Quantidade >= 3 then
                Inibir := Gramatica.Pilha.Desempilhar(False)
            else
                Inibir := False;

            if Quantidade >= 2 then
                HotKeyHex := Gramatica.Pilha.Desempilhar('')
            else
                HotKeyHex := '';

            if Quantidade >= 1 then
                Script := Gramatica.Pilha.Desempilhar('');

            HotKey := TPGHotKeys.Create();
            HotKey.Name := Titulo;
            HotKey.Script := Script;
            HotKey.SetKeysHex(HotKeyHex);
            HotKey.Inhibit := Inibir;
            HotKey.Detect := Detect;
            TPGHotKeys.HotKeyGlobList.Add(HotKey);
        end;
    end
    else
        Gramatica.ErroAdd('Identificador esperado.');
end;

initialization
    TGramatica.Global.FindName('Commands').Add(TPGHotKey.Create('HotKey'));
    TPGHotKeys.HotKeyGlobList := TGramatica.Global.Add('HotKeys');

finalization


end.
