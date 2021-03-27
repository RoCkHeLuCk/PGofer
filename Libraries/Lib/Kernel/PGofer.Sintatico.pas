unit PGofer.Sintatico;

interface

uses
    System.SysUtils, System.Classes, System.Generics.Collections,
    Vcl.Controls,
    PGofer.Classes, PGofer.Lexico;

type
    TPGConsoleNotify = procedure(Value: String; Show: Boolean) of object;

    TPGPilha = class(TPGItem)
        constructor Create(ItemDad: TPGItem);
        destructor Destroy(); override;
    private
        FPilha: TStack<Variant>;
    public
        procedure Empilhar(Valor: Variant);
        function Desempilhar(Padrao: Variant): Variant;
    end;

    TGramatica = class(TThread)
        constructor Create(Name: String; ItemDad: TPGItem;
          AutoTerminar: Boolean); overload;
        destructor Destroy(); override;
    private
        FErro: Boolean;
        FConsoleShowMessage: Boolean;
        FPai: TPGItem;
        FLocal: TPGItem;
        FPilha: TPGPilha;
        FTokenList: TTokenList;
    public
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

    procedure ScriptExec(Name, Texto: String; Nivel: TPGItem = nil;
                         WaitFor: Boolean = False);

var
    DirCurrent: String;
    IniConfigFile: String;
    LogFile: String;

    GlobalCollection: TPGItemCollect;
    TriggersCollect: TPGItemCollect;
    GlobalItemCommand: TPGItem;
    GlobalItemTrigger: TPGItem;
    LoopLimite: Int64 = 1000000;
    FileListMax: Cardinal = 200;
    ReplyFormat: String = '';
    ReplyPrefix: Boolean = False;
    ConsoleNotify: TPGConsoleNotify;
    ConsoleMessage: Boolean = True;
    LogMaxSize: Integer = 10000;
    CanOff: Boolean = false;
    CanClose: Boolean = True;

implementation

uses
    PGofer.Sintatico.Classes, PGofer.Sintatico.Controls, PGofer.ImageList;

{ TPilha }

constructor TPGPilha.Create(ItemDad: TPGItem);
begin
    inherited Create(ItemDad, '$Pilha');
    FPilha := TStack<Variant>.Create;
end;

destructor TPGPilha.Destroy();
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

constructor TGramatica.Create(Name: String; ItemDad: TPGItem;
  AutoTerminar: Boolean);
begin
    inherited Create(True);
    Self.FreeOnTerminate := AutoTerminar;
    Self.Priority := tpNormal;
    FConsoleShowMessage := ConsoleMessage;
    FPai := ItemDad;
    if Assigned(FPai) then
        FLocal := TPGFolder.Create(ItemDad, Name)
    else
        FLocal := TPGFolder.Create(GlobalCollection, Name);

    FPilha := TPGPilha.Create(FLocal);
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
    FConsoleShowMessage := False;
    FTokenList.Free;
    FTokenList := nil;
    FErro := False;
    inherited Destroy();
end;

procedure TGramatica.ErroAdd(Texto: String);
begin
    FErro := True;
    if Assigned(ConsoleNotify) then
        Synchronize(
            procedure
            begin
                ConsoleNotify('[' + Self.TokenList.Token.Cordenada.ToString +
                  '] "' + String(Self.TokenList.Token.Lexema) + '" : ' + Texto,
                  FConsoleShowMessage);
            end);
end;

procedure TGramatica.MSGsAdd(Texto: String);
begin
    if Assigned(ConsoleNotify) then
       Synchronize(
            procedure
            begin
                ConsoleNotify(Texto, FConsoleShowMessage);
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

procedure ScriptExec(Name, Texto: String; Nivel: TPGItem = nil;
                     WaitFor: Boolean = False);
var
    Gramatica: TGramatica;
begin
    if not Assigned(Nivel) then
        Nivel := GlobalCollection;

    Gramatica := TGramatica.Create(Name, Nivel, not WaitFor);
    Gramatica.SetAlgoritimo(Texto);
    Gramatica.Start;
    if WaitFor then
    begin
       Gramatica.WaitFor();
       Gramatica.Free();
    end;
end;

initialization
    DirCurrent := ExtractFilePath(ParamStr(0));
    IniConfigFile := DirCurrent + 'Config.ini';
    LogFile := DirCurrent + 'PGofer.log';

    GlobalCollection := TPGItemCollect.Create('Globals', False);
    GlobalItemCommand := TPGFolder.Create(GlobalCollection, 'Commands');
    GlobalItemTrigger := TPGFolder.Create(GlobalCollection, 'Triggers');

    TriggersCollect := TPGItemCollect.Create('Triggers', True);

    {$IFNDEF DEBUG}
        GlogalImageList.CurrentPath := DirCurrent + 'Icons\';
    {$ELSE}
        GlogalImageList.CurrentPath := '..\..\..\..\Documents\Imagens\Icons\';
    {$ENDIF}

    GlogalImageList.AddIcon('Item');

finalization
    GlobalCollection.Free;
    TriggersCollect.Free;

end.
