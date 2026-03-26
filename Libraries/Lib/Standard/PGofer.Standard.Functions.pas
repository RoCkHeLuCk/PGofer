unit PGofer.Standard.Functions;

interface

uses
  System.Classes, System.SysUtils, System.Rtti,
  PGofer.Classes, PGofer.Lexico, PGofer.Sintatico,
  PGofer.Runtime, PGofer.Standard.Variants;

type
  { Objeto que representa uma função definida pelo usuário }
  {$M+}
  TPGFunction = class(TPGItemClass)
  strict private
    FTokenList: TPGTokenList;
    FParamsList: TPGItem; // Lista de nomes de parâmetros (TPGVariant)
    FScriptSource: string;
    procedure SetScript(const AValue: string);
  public
    class var GlobList: TPGItem;
    constructor Create(AOwner: TPGItem; const AName: string); override;
    destructor Destroy; override;

    procedure Execute(const AGrammar: TPGGrammar); override;
    procedure Frame(AParent: TObject); override;
    procedure Compile;

    property Script: string read FScriptSource write SetScript;
    property ParamsList: TPGItem read FParamsList;
    property Tokens: TPGTokenList read FTokenList;
  published
  end;
  {$TYPEINFO ON}

  { Comando 'Function' para declarar novas funções no script }
  TPGFunctionDeclare = class(TPGItemClass)
  strict private
    procedure DeclareInternal(const AGrammar: TPGGrammar; ANivel: TPGItem; AStartPos: Integer);
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

implementation

uses
  PGofer.Core, PGofer.Sintatico.Controls, PGofer.Standard.Functions.Frame;

{ TPGFunction }

constructor TPGFunction.Create(AOwner: TPGItem; const AName: string);
begin
  inherited Create(AOwner, AName);
  Self.SystemNode := False;
  FTokenList := TPGTokenList.Create;
  FParamsList := TPGItem.Create(nil, 'Params');
  FScriptSource := '';
end;

destructor TPGFunction.Destroy;
begin
  FTokenList.Free;
  FParamsList.Free;
  inherited;
end;

procedure TPGFunction.Compile;
begin
  // Apenas para trigger manual de compilação se necessário
end;

procedure TPGFunction.Execute(const AGrammar: TPGGrammar);
var
  LParamCount, I: Integer;
  LSubGrammar: TPGGrammar;
  LParamName: string;
  LParamValue: TValue;
  LResultVar: TPGVariant;
begin
  AGrammar.TokenList.Next;
  // 1. Lê os parâmetros passados na chamada: Min = 0, Max = Qtd definida na função
  LParamCount := ReadParameters(AGrammar, 0, FParamsList.Count);

  if not AGrammar.HasError then
  begin
    // 2. Cria uma sub-gramática para execução local (Escopo da Função)
    LSubGrammar := TPGGrammar.Create('$Func:' + Self.Name, AGrammar.Local, False);
    try
      // 3. Alimenta as variáveis locais com os valores da pilha (ordem inversa)
      for I := FParamsList.Count - 1 downto 0 do
      begin
        LParamName := FParamsList[I].Name;

        if I < LParamCount then
          LParamValue := AGrammar.Stack.Pop
        else
          LParamValue := TPGVariant(FParamsList[I]).Value; // Valor default se não passado

        TPGVariant.Create(LSubGrammar.Local, LParamName, LParamValue, False);
      end;

      // 4. Cria a variável mágica 'Result'
      LResultVar := TPGVariant.Create(LSubGrammar.Local, 'Result', TValue.Empty, False);

      // 5. Executa os tokens da função
      LSubGrammar.SetTokens(FTokenList);
      LSubGrammar.Start;
      LSubGrammar.WaitFor;

      AGrammar.HasError := LSubGrammar.HasError;

      // 6. Devolve o valor de 'Result' para a pilha da gramática pai
      if not AGrammar.HasError then
        AGrammar.Stack.Push(LResultVar.Value);

    finally
      LSubGrammar.Free;
    end;
  end;
end;

procedure TPGFunction.Frame(AParent: TObject);
begin
  TPGFunctionFrame.Create(Self, AParent);
end;

procedure TPGFunction.SetScript(const AValue: string);
begin
  FScriptSource := AValue;
end;

{ TPGFunctionDeclare }

procedure TPGFunctionDeclare.Execute(const AGrammar: TPGGrammar);
var
  LStartPos: Integer;
  LTargetNivel: TPGItem;
begin
  // 1. O PONTO DE PARTIDA: Captura o Offset ANTES de consumir a palavra 'Function'
  LStartPos := AGrammar.TokenList.Current.Coordinate.Offset;

  AGrammar.TokenList.Next; // Agora sim, pula o 'Function'

  if AGrammar.Match(tkGlobal) then
  begin
    AGrammar.TokenList.Next;
    LTargetNivel := TPGFunction.GlobList;
  end
  else
    LTargetNivel := AGrammar.Local;

  // Passamos o LStartPos para o método interno
  DeclareInternal(AGrammar, LTargetNivel, LStartPos);
end;

procedure TPGFunctionDeclare.DeclareInternal(const AGrammar: TPGGrammar; ANivel: TPGItem; AStartPos: Integer);
var
  LName: string;
  LID: TPGItem;
  LFunc: TPGFunction;
  LEndPos: Integer;
begin
  LName := AGrammar.TokenList.Current.Value.ToString;
  LID := FindID(ANivel, LName);

  if (LID <> nil) and (not (LID is TPGFunction)) then
  begin
    AGrammar.Error('Error_Interpreter_Id', []);
    Exit;
  end;

  if Assigned(LID) then LID.Free;
  LFunc := TPGFunction.Create(ANivel, LName);

  AGrammar.TokenList.Next; // Pula o nome da função

  if AGrammar.Consume(tkLPar) then
  begin
    if AGrammar.Match(tkIdentifier) then
      TPGVariantDeclare.ExecuteEx(AGrammar, LFunc.ParamsList);

    if AGrammar.Consume(tkRPar) and AGrammar.Consume(tkSemiColon) then
    begin
      // 1. Extrai o corpo. O FindEnd consome até o 'end' inclusive.
      FindEnd(AGrammar, True, LFunc.Tokens);

      if not AGrammar.HasError then
      begin
        // Agora o AGrammar.TokenList.Current aponta para o que vem DEPOIS da função.
        // Ex: O início da chamada "teste(1000);"
        // O Offset desse próximo token é exatamente o fim da nossa declaração.
        LEndPos := AGrammar.TokenList.Current.Coordinate.Offset;

        // Caso especial: Se o usuário colocou um ';' após o 'end',
        // queremos que esse ';' entre no FScriptSource.
        if AGrammar.Match(tkSemiColon) then
        begin
          // Somamos o comprimento do ';' para que o Copy o inclua
          LEndPos := LEndPos + AGrammar.TokenList.Current.Coordinate.Length;
        end;

        // 3. A CÓPIA MILIMÉTRICA
        // AStartPos: Início da palavra 'Function'
        // LEndPos: Fim do caractere ';' ou do 'end'
        LFunc.Script := Copy(AGrammar.Script, AStartPos + 1, LEndPos - AStartPos);

        // Se a cópia ainda parecer faltar um caractere,
        // verifique se o seu Léxico está contando o Length corretamente para o 'end'.
      end;
    end;
  end;
end;
initialization
  TPGFunctionDeclare.Create(GlobalItemCommand, 'Function');
  TPGFunction.GlobList := TPGFolder.Create(GlobalCollection, 'Functions');

end.
