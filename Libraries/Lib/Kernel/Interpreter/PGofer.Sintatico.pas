unit PGofer.Sintatico;

interface

uses
  System.Classes, System.SyncObjs, System.Generics.Collections, System.Rtti,
  PGofer.Classes, PGofer.Lexico;

type
  { Pilha de Execução Moderna usando TValue }
  TPGStack = class(TPGItem)
  strict private
    FValues: TStack<TValue>;
  private
    function GetCount: Integer;
  public
    constructor Create(AOwner: TPGItem);
    destructor Destroy; override;
    procedure Push(const AValue: TValue);
    function Pop: TValue;
    property Count: Integer read GetCount;
  end;

  { Classe Base da Gramática / Interpretador }
  TPGGrammar = class(TThread)
  strict private
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

    class var FGrammarList: TList<TPGGrammar>;
    class var FGrammarLock: TObject;
  protected
    procedure Execute; override;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure WaitForAll(ATimeoutMS: Cardinal);

    constructor Create(const AName: string; AParent: TPGItem; ATerminate: Boolean);
    destructor Destroy; override;

    { Gerenciamento de Script }
    procedure SetScript(const AScript: string);
    procedure SetTokens(ASource: TPGTokenList);

    { Helpers Sintáticos }
    function Match(const AKind: TPGTokenKind): Boolean;
    function Consume(const AKind: TPGTokenKind; const AErrorMessageKey: string = ''): Boolean;
    procedure Error(const AMessageKey: string; const AArgs: array of const);
    procedure Msg(const AMessageKey: string; const AArgs: array of const);

    { Controle de Debug }
    procedure CheckBreakpoint;
    procedure ResumeExecution;

    property Stack: TPGStack read FStack;
    property Local: TPGItem read FLocal;
    property TokenList: TPGTokenList read FTokenList;
    property HasError: Boolean read FError write FError;
    property Script: string read FScript;
    property IsDebugging: Boolean read FIsDebugging;
  end;

implementation

uses
  System.SysUtils, Vcl.Forms,
  PGofer.Core, PGofer.Sintatico.Controls, PGofer.Runtime;

{ TPGStack }

constructor TPGStack.Create(AOwner: TPGItem);
begin
  inherited Create(AOwner, '$Stack');
  FValues := TStack<TValue>.Create;
end;

destructor TPGStack.Destroy;
begin
  FValues.Free;
  inherited;
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

class constructor TPGGrammar.Create;
begin
  FGrammarList := TList<TPGGrammar>.Create;
  FGrammarLock := TObject.Create;
end;

class destructor TPGGrammar.Destroy;
begin
  FGrammarList.Free;
  FGrammarLock.Free;
end;

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
  FStack := TPGStack.Create(FLocal);
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
  LText, LLexema: string;
begin
  FError := True;

  if FTokenList.Current <> nil then
    LLexema := '"' + FTokenList.Current.Value.ToString + '" '
  else
    LLexema := 'EOF';

  LText := TPGKernel.Translate(AMessageKey, AArgs);

  TPGKernel.Console(
    Format('%s [%s]: %s', [
      FLocal.Name,
      LLexema,
      LText
    ]),
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

  // Início da Análise Sintática
  PGofer.Sintatico.Controls.Statements(Self);
end;

initialization

finalization

end.
