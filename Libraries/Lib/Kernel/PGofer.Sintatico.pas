unit PGofer.Sintatico;

interface

uses
    System.SysUtils, System.Classes, System.Generics.Collections,
    PGofer.Classes, PGofer.Lexico;

type

    TPGPilha = class(TPGItem)
        constructor Create();
        destructor Destroy(); override;
    private
        FPilha: TStack<Variant>;
    public
        procedure Empilhar(Valor: Variant);
        function Desempilhar(Padrao: Variant): Variant;
    end;

    TGramatica = class(TThread)
        constructor Create(Name: String; Pai: TPGItem;
            AutoTerminar: Boolean); overload;
        destructor Destroy(); override;
    private
        FPai: TPGItem;
        FLocal: TPGItem;
        FPilha: TPGPilha;
        FErro: Boolean;
        FTokenList: TTokenList;
    public
        class var Global: TPGItem;
        property Pilha: TPGPilha read FPilha;
        property Local: TPGItem read FLocal;
        property TokenList: TTokenList read FTokenList;
        property Erro: Boolean read FErro write FErro;
        procedure ErroAdd(Texto: String);
        procedure MSGsAdd(Texto: String);
        procedure SetAlgoritimo(Algoritimo: String);
        procedure SetTokens(TokenList: TTokenList);
    protected
        procedure Execute; override;
    end;

    procedure ScriptExec(Name, Texto: String; Nivel: TPGItem = nil);

var
    LoopLimite: Int64 = 1000000;
    FileListMax: Cardinal = 200;
    ReplyFormat: String  = '';
    ReplyPrefix: Boolean = False;
    DirCurrent : String;

implementation

uses
    PGofer.Sintatico.Controls;

{ TPilha }

constructor TPGPilha.Create;
begin
    inherited Create('$Pilha');
    FPilha := TStack<Variant>.Create;
end;

destructor TPGPilha.Destroy;
begin
    FPilha.Free;
    FPilha := nil;
    inherited Destroy();
end;

procedure TPGPilha.Empilhar(Valor: Variant);
begin
    FPilha.Push(Valor);
end;

function TPGPilha.Desempilhar(Padrao: Variant): Variant;
begin
    if FPilha.Count > 0 then
    begin
        Result := FPilha.Pop;
    end
    else
        Result := Padrao;
end;

{ Gramatica }

constructor TGramatica.Create(Name: String; Pai: TPGItem;
    AutoTerminar: Boolean);
begin
    inherited Create(True);
    Self.FreeOnTerminate := AutoTerminar;
    Self.Priority := tpNormal;
    FPai := Pai;
    if Assigned(FPai) then
        FLocal := FPai.Add(TPGItem.Create(Name))
    else
        FLocal := TGramatica.Global.Add(TPGItem.Create(Name));

    FPilha := TPGPilha(FLocal.Add(TPGPilha.Create));
    FErro := False;
end;

destructor TGramatica.Destroy();
begin
    // MSGsAdd('Pilha ['+FLocal.Titulo+'] terminou com: '+FPilha.Count.ToString);
    // MSGsAdd('Filhos ['+FLocal.Titulo+'] terminou com '+FLocal.Count.ToString);
    FPilha.Free;
    FPilha := nil;
    FLocal.Free;
    FLocal := nil;
    FPai := nil;
    FTokenList.Free;
    FTokenList := nil;
    FErro := False;
    inherited Destroy();
end;

procedure TGramatica.ErroAdd(Texto: String);
begin
    FErro := True;
    if Assigned(TPGItem.OnMsgNotify) then
        Synchronize(
            procedure
            begin
                TPGItem.OnMsgNotify('[' + Self.TokenList.Token.Cordenada.
                    ToString + '] "' + String(Self.TokenList.Token.Lexema) +
                    '" : ' + Texto);
            end);
end;

procedure TGramatica.MSGsAdd(Texto: String);
begin
    if Assigned(TPGItem.OnMsgNotify) then
        Synchronize(
            procedure
            begin
                TPGItem.OnMsgNotify(Texto);
            end);
end;

procedure TGramatica.SetAlgoritimo(Algoritimo: String);
var
    Automato: TAutomato;
begin
    Automato := TAutomato.Create();
    FTokenList := Automato.TokenListCreate(Algoritimo);
    Automato.Free;
end;

procedure TGramatica.SetTokens(TokenList: TTokenList);
begin
    FTokenList := TTokenList.Create();
    FTokenList.Assign(TokenList);
end;

procedure TGramatica.Execute();
begin
    SetCurrentDir(PGofer.Sintatico.DirCurrent);
    ChDir(PGofer.Sintatico.DirCurrent);
    Sentencas(Self);
end;

procedure ScriptExec(Name, Texto: String; Nivel: TPGItem = nil);
var
    Gramatica: TGramatica;
begin
    if Assigned(Nivel) then
        Nivel := TGramatica.Global;

    Gramatica := TGramatica.Create(Name, Nivel, True);
    Gramatica.SetAlgoritimo(Texto);
    Gramatica.Start;
end;

initialization
    DirCurrent := ExtractFilePath(ParamStr(0));
    TGramatica.Global := TPGItem.Create('Global');
    TGramatica.Global.Add('Commands');

finalization
    TGramatica.Global.Free;

end.
