unit PGofer.Sintatico;

interface

uses
  System.Classes, System.SyncObjs, System.Generics.Collections, System.Rtti,
  PGofer.Core, PGofer.Classes, PGofer.Lexico;

type
  { Pilha de Execução Moderna usando TValue }
  TPGStack = class(TPGItem)
  private
    FValues: TStack<TValue>;
  private
    function GetCount: Integer;
  public
    constructor Create(const AParent: TPGItem; const AName: string); override;
    destructor Destroy; override;
    procedure Push(const AValue: TValue);
    function Pop: TValue;
    property Count: Integer read GetCount;
  end;

  { Classe Base da Gramática / Interpretador }
  TPGGrammar = class(TThread)
  private
    FError: Boolean;
    FShowMessages: Boolean;
    FParent: TPGItem;
    FLocal: TPGItem;
    FStack: TPGStack;
    FScript: string;
    FTokenList: TPGTokenList;

    // Suporte a Debug
    FBreakpointEvent: TEvent;
    FIsDebugging: Boolean;

    // controle de aninhamento
    FBracketStack: TStack<TPGTokenKind>;
    function GetNestingLevel: Integer;

    class var FGrammarList: TList<TPGGrammar>;
    class var FGrammarLock: TObject;
  protected
    procedure Execute; override;
  public
    class procedure WaitForAll(ATimeoutMS: Cardinal);

    constructor Create(const AName: string; AParent: TPGItem; ATerminate: Boolean);
    destructor Destroy; override;

    { Gerenciamento de Script }
    procedure SetScript(const AScript: string);
    procedure SetTokens(ASource: TPGTokenList);
    procedure Next;

    { Helpers Sintáticos }
    function Match(const AKind: TPGTokenKind): Boolean;
    function MatchKeyword(const AWord: string): Boolean;
    function Consume(const AKind: TPGTokenKind; const AErrorMessageKey: string = ''): Boolean;
    function ConsumeKeyword(const AWord: string): Boolean;
    procedure Error(const AMessageKey: string; const AArgs: array of const);
    procedure Msg(const AMessageKey: string; const AArgs: array of const);

    { Controle de Debug }
    procedure CheckBreakpoint;
    procedure ResumeExecution;
    procedure DumpTokens;

    property Stack: TPGStack read FStack;
    property Local: TPGItem read FLocal;
    property TokenList: TPGTokenList read FTokenList;
    property HasError: Boolean read FError write FError;
    property Script: string read FScript;
    property IsDebugging: Boolean read FIsDebugging;
    function IsStartOfCommand: Boolean;


    { Controle de Aninhamento }
    function IsOpener(const AKind: TPGTokenKind): Boolean; inline;
    function IsCloser(const AKind: TPGTokenKind): Boolean; inline;
    property NestingLevel: Integer read GetNestingLevel;
    procedure SetNestingLevel(AValue: Integer);

  end;

  procedure Initialize();
  procedure Finalize();

implementation

uses
  System.SysUtils, System.StrUtils, System.TypInfo,
  Winapi.ActiveX,
  Vcl.Forms,
  PGofer.Sintatico.Controls, PGofer.Runtime;


procedure Initialize();
begin
  TPGGrammar.FGrammarList := TList<TPGGrammar>.Create;
  TPGGrammar.FGrammarLock := TObject.Create;
end;

procedure Finalize();
begin
  TPGGrammar.FGrammarList.Free;
  TPGGrammar.FGrammarList := nil;
  TPGGrammar.FGrammarLock.Free;
  TPGGrammar.FGrammarLock := nil;

  {$IFDEF DEBUG}
  {$ENDIF}
end;

{ TPGStack }

constructor TPGStack.Create(const AParent: TPGItem; const AName: string);
begin
  inherited Create(AParent, '$Stack_'+AName);
  FValues := TStack<TValue>.Create;
end;

destructor TPGStack.Destroy;
begin
  FValues.Free;
  FValues := nil;
  inherited Destroy();
end;

function TPGStack.GetCount: Integer;
begin
  Result := FValues.Count;
end;

procedure TPGStack.Push(const AValue: TValue);
begin
  FValues.Push(AValue);
end;

function TPGStack.Pop: TValue;
begin
  if FValues.Count > 0 then
    Result := FValues.Pop
  else
    Result := TValue.Empty;
end;

{ TPGGrammar }

class procedure TPGGrammar.WaitForAll(ATimeoutMS: Cardinal);
var
  LStartTime: Cardinal;
  LRunning: Integer;
begin
  LStartTime := GetTickCount;
  repeat
    System.TMonitor.Enter(FGrammarLock);
    try
      LRunning := FGrammarList.Count;
    finally
      System.TMonitor.Exit(FGrammarLock);
    end;

    if LRunning = 0 then Break;

    if (GetTickCount - LStartTime) > ATimeoutMS then
      Exit; // Timeout de segurança

    CheckSynchronize(10);
    Application.ProcessMessages;
    Sleep(10);
  until False;
end;

constructor TPGGrammar.Create(const AName: string; AParent: TPGItem; ATerminate: Boolean);
begin
  inherited Create(True);
  Self.FreeOnTerminate := ATerminate;

  FParent := AParent;
  if not Assigned(FParent) then
    FParent := GlobalCollection;

  FLocal := TPGItem.Create(FParent, AName);
  FStack := TPGStack.Create(FLocal, AName);
  FBracketStack := TStack<TPGTokenKind>.Create;
  FTokenList := TPGTokenList.Create;
  FBreakpointEvent := TEvent.Create(nil, True, False, ''); // Manual Reset

  FError := False;
  FShowMessages := TPGKernel.ConsoleMessage;

  System.TMonitor.Enter(FGrammarLock);
  try
    FGrammarList.Add(Self);
  finally
    System.TMonitor.Exit(FGrammarLock);
  end;
end;

destructor TPGGrammar.Destroy;
begin
  // Sinaliza para qualquer espera de debug terminar
  FBreakpointEvent.SetEvent;

  System.TMonitor.Enter(FGrammarLock);
  try
    if Assigned(FGrammarList) then
      FGrammarList.Remove(Self);
  finally
    System.TMonitor.Exit(FGrammarLock);
  end;

  FLocal.Free;
  FTokenList.Free;
  FBracketStack.Free;
  FBreakpointEvent.Free;
  inherited;
end;

procedure TPGGrammar.SetScript(const AScript: string);
var
  LLexer: TPGLexer;
begin
  FScript := AScript;
  LLexer := TPGLexer.Create;
  try
    // FTokenList já foi criado no constructor da TPGGrammar
    LLexer.Tokenize(FScript, FTokenList);
  finally
    LLexer.Free;
  end;
end;

procedure TPGGrammar.SetTokens(ASource: TPGTokenList);
begin
  FTokenList.Assign(ASource);
end;

{ Métodos de Suporte à Análise }

function TPGGrammar.Match(const AKind: TPGTokenKind): Boolean;
begin
  Result := (FTokenList.Current <> nil) and (FTokenList.Current.Kind = AKind);
end;

function TPGGrammar.MatchKeyword(const AWord: string): Boolean;
begin
  // Verifica se o token atual é uma palavra reservada E se o texto bate
  Result := (TokenList.Current <> nil) and
            (TokenList.Current.Kind = pgkKeyword) and
            SameText(TokenList.Current.Value.ToString, AWord);
end;

function TPGGrammar.ConsumeKeyword(const AWord: string): Boolean;
begin
  if MatchKeyword(AWord) then
  begin
    TokenList.Next;
    Exit(True);
  end;
  // Se não for a palavra esperada, gera erro
  Error('Error_Expected', [AWord]);
  Result := False;
end;

{ Novo Helper: Verifica se o token atual é o início de um comando válido }
function TPGGrammar.IsStartOfCommand: Boolean;
var
  LKind: TPGTokenKind;
begin
  if (TokenList.Current = nil) then
    Exit(False);
  LKind := TokenList.Current.Kind;

  // Um comando pode começar com:
  // 1. Identificador (Nome de classe ou variável)
  // 2. Begin (Início de bloco)
  // 3. "=" (Modo calculadora)
  // 4. ";" (Comando vazio)
  if LKind in [pgkIdentifier, pgkBegin, pgkEqual, pgkSemiColon] then
    Exit(True);

  if LKind = pgkKeyword then
  begin
    // 'until', 'else', 'end', 'then', 'do' NÃO entram aqui,
    // pois eles marcam o FIM ou a DIVISÃO de um comando.
    Result := MatchText(TokenList.Current.Value.ToString,
      ['if', 'for', 'while', 'repeat', 'var', 'const', 'function', 'global', 'Debug']);
  end
  else
    Result := False;
end;

function TPGGrammar.Consume(const AKind: TPGTokenKind; const AErrorMessageKey: string): Boolean;
begin
  if Match(AKind) then
  begin
    FTokenList.Next;
    Exit(True);
  end;

  if AErrorMessageKey <> '' then
    Error(AErrorMessageKey, [TPGLexicalRegistry.GetFriendlyName(AKind)])
  else
    Error('Error_Expected', [TPGLexicalRegistry.GetFriendlyName(AKind)]);

  Result := False;
end;

procedure TPGGrammar.Error(const AMessageKey: string; const AArgs: array of const);
var
  LText, LLexema, LCoordStr: string;
  LToken: TPGToken;
begin
  FError := True;

  // Captura o token uma única vez para evitar race conditions ou mudanças de ponteiro
  LToken := FTokenList.Current;

  if (LToken <> nil) then
  begin
    LCoordStr := LToken.Coordinate.ToString;
    LLexema := LToken.Value.ToString;

    // Se o valor for vazio (keywords, símbolos), usa o nome amigável
    if LLexema = '' then
      LLexema := TPGLexicalRegistry.GetFriendlyName(LToken.Kind);

    LLexema := '"' + LLexema + '" ';
  end
  else
  begin
    // Fallback caso o token seja nulo (fim catastrófico do script)
    LCoordStr := 'EOF';
    LLexema := 'EOF ';
  end;

  LText := TPGKernel.Translate(AMessageKey, AArgs);

  // Agora é impossível dar AV aqui
  TPGKernel.Console(
    Format('%s [%s] %s: %s', [FLocal.Name, LCoordStr, LLexema, LText]),
    True, FShowMessages
  );
end;

procedure TPGGrammar.Msg(const AMessageKey: string; const AArgs: array of const);
begin
  TPGKernel.Console(TPGKernel.Translate(AMessageKey, AArgs), True, FShowMessages);
end;

{ Controle de Debugging }

procedure TPGGrammar.CheckBreakpoint;
begin
  // Se houver um comando "Debug" ou se o sistema marcar este token como break
  FIsDebugging := True;
  FBreakpointEvent.ResetEvent;

  // Notifica a UI que paramos (pode usar um PostMessage ou Callback aqui)
  TPGKernel.Console(Format('>> Debug: Breakpoint at %s', [FTokenList.Current.Coordinate.ToString]));

  // A Thread para aqui até que ResumeExecution seja chamado pela UI
  FBreakpointEvent.WaitFor(INFINITE);
  FIsDebugging := False;
end;

procedure TPGGrammar.ResumeExecution;
begin
  FBreakpointEvent.SetEvent;
end;

procedure TPGGrammar.Execute;
var
  LDir: string;
begin
  LDir := TPGKernel.PathCurrent;
  SetCurrentDir(LDir);
  CoInitialize(nil); //ActiveX

  // Início da Análise Sintática
  PGofer.Sintatico.Controls.Statements(Self);

end;

procedure TPGGrammar.DumpTokens;
var
  I: Integer;
  LMarker: string;
  LToken: TPGToken;
begin
  TPGKernel.Console('--- DEBUG TOKEN LIST ---', True, True);
  for I := 0 to FTokenList.Count - 1 do
  begin
    LToken := FTokenList.Items[I]; // Assumindo que você tem acesso à lista interna
    if I = FTokenList.Position then LMarker := '>>> ' else LMarker := '    ';

    TPGKernel.Console(Format('%s[%d] Kind: %s | Val: %s | Coord: %s', [
      LMarker, I,
      GetEnumName(TypeInfo(TPGTokenKind), Ord(LToken.Kind)),
      LToken.Value.ToString,
      LToken.Coordinate.ToString
    ]), True, True);
  end;
  TPGKernel.Console('--- END DUMP ---', True, True);
end;

function TPGGrammar.IsOpener(const AKind: TPGTokenKind): Boolean;
begin
  Result := AKind in [pgkLPar, pgkLBrack, pgkBegin];
end;

function TPGGrammar.IsCloser(const AKind: TPGTokenKind): Boolean;
begin
  Result := AKind in [pgkRPar, pgkRBrack, pgkEnd];
end;

procedure TPGGrammar.SetNestingLevel(AValue: Integer);
begin
  // Remove itens da pilha até voltar ao nível desejado
  while FBracketStack.Count > AValue do
    FBracketStack.Pop;
end;

procedure TPGGrammar.Next;
var
  LCurrentKind, LOpenKind: TPGTokenKind;
begin
  if FError
  or (FTokenList.Current.Kind = pgkEOF) then
    Exit;

  LCurrentKind := FTokenList.Current.Kind;

  // 1. MONITORAMENTO DE ABERTURA: Empilha o que abriu
  if IsOpener(LCurrentKind) then
    FBracketStack.Push(LCurrentKind);

  // 2. MONITORAMENTO DE FECHAMENTO: Valida o par correto
  if IsCloser(LCurrentKind) then
  begin
    if FBracketStack.Count > 0 then
    begin
      LOpenKind := FBracketStack.Pop;
      // Validação de paridade (A criança não chora mais!)
      case LCurrentKind of
        pgkRPar:   if LOpenKind <> pgkLPar   then Error('Error_Expected', [')']);
        pgkRBrack: if LOpenKind <> pgkLBrack then Error('Error_Expected', [']']);
        pgkEnd:    if LOpenKind <> pgkBegin  then Error('Error_Expected', ['end']);
      end;
    end
    else
      // Tentativa de fechar o que nunca foi aberto
      Error('Error_Extra_Closer', [TPGLexicalRegistry.GetFriendlyName(LCurrentKind)]);
  end;

  // Só avança o ponteiro se não houver erro de mismatch detectado
  if not FError then
    FTokenList.Next;
end;

function TPGGrammar.GetNestingLevel: Integer;
begin
  Result := FBracketStack.Count;
end;

initialization

finalization

end.
