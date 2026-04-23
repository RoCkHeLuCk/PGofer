unit PGofer.Standard.Functions;

interface

uses
  System.Classes, System.SysUtils, System.Rtti,
  PGofer.Classes, PGofer.Lexico, PGofer.Sintatico,
  PGofer.Runtime, PGofer.Standard.Variants;

type
  {$M+}
  TPGFunction = class(TPGItemClass)
  strict private
    FTokenList: TPGTokenList;
    FParamsList: TPGItem;
    FScriptSource: string;
    procedure SetScript(const AValue: string);
  public
    class var GlobList: TPGItem;
    constructor Create(AOwner: TPGItem; const AName: string); override;
    destructor Destroy; override;

    procedure Execute(const AGrammar: TPGGrammar); override;
    procedure Frame(AParent: TObject); override;
    procedure Compile();

    property Script: string read FScriptSource write SetScript;
    property ParamsList: TPGItem read FParamsList;
    property Tokens: TPGTokenList read FTokenList;
  published
  end;
  {$TYPEINFO ON}

  TPGFunctionDeclare = class(TPGItemClass)
  strict private
    procedure DeclareInternal(const AGrammar: TPGGrammar; ANivel: TPGItem; AStartPos: Integer);
  public
    constructor Create(AOwner: TPGItem; const AName: string = ''); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

implementation

uses
  PGofer.Sintatico.Controls, PGofer.Standard.Functions.Frame;

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

procedure TPGFunction.Execute(const AGrammar: TPGGrammar);
var
  LParamCount, I: Integer;
  LSubGrammar: TPGGrammar;
  LParamName: string;
  LParamValue: TValue;
  LResultVar: TPGVariant;
begin
  AGrammar.TokenList.Next; // Pula o nome da função (ex: 'teste')

  LParamCount := ReadParameters(AGrammar, 0, FParamsList.Count);

  if not AGrammar.HasError then
  begin
    LSubGrammar := TPGGrammar.Create('$Func:' + Self.Name, AGrammar.Local, False);
    try
      for I := FParamsList.Count - 1 downto 0 do
      begin
        LParamName := FParamsList[I].Name;
        if I < LParamCount then
          LParamValue := AGrammar.Stack.Pop
        else
          LParamValue := TPGVariant(FParamsList[I]).Value;

        TPGVariant.Create(LSubGrammar.Local, LParamName, LParamValue, False);
      end;

      LResultVar := TPGVariant.Create(LSubGrammar.Local, 'Result', TValue.Empty, False);
      LSubGrammar.SetTokens(FTokenList);
      LSubGrammar.Start;
      LSubGrammar.WaitFor;
      AGrammar.HasError := LSubGrammar.HasError;

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

procedure TPGFunction.Compile;
var
  LLexer: TPGLexer;
  LTempGrammar: TPGGrammar;
begin
  // Este método reconstrói a lista de tokens a partir do FScriptSource
  // Útil quando o usuário edita no RichEdit e salva ou aperta F9.
  LLexer := TPGLexer.Create;
  try
    // Usamos uma gramática temporária apenas para extrair a estrutura
    LTempGrammar := TPGGrammar.Create('Compiler', nil, False);
    try
      LTempGrammar.SetScript(FScriptSource);
      // Aqui o interpretador extrai novamente os parâmetros e o corpo
      // ... lógica de extração sintática ...
    finally
      LTempGrammar.Free;
    end;
  finally
    LLexer.Free;
  end;
end;

{ TPGFunctionDeclare }

constructor TPGFunctionDeclare.Create(AOwner: TPGItem; const AName: string);
begin
  inherited;
  TPGLexicalRegistry.RegisterKeyword('global', pgkKeyword, 'global');
end;

procedure TPGFunctionDeclare.Execute(const AGrammar: TPGGrammar);
var
  LStartPos: Integer;
  LTargetNivel: TPGItem;
begin
  LStartPos := AGrammar.TokenList.Current.Coordinate.Offset;
  AGrammar.TokenList.Next; // Pula 'Function'

  if AGrammar.MatchKeyword('global') then
  begin
    AGrammar.TokenList.Next;
    LTargetNivel := TPGFunction.GlobList;
  end
  else
    LTargetNivel := AGrammar.Local;

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
  LID := ANivel.FindName(LName);

  if (LID <> nil) and (not (LID is TPGFunction)) then
  begin
    AGrammar.Error('Error_Interpreter_Id', []);
    Exit;
  end;

  if Assigned(LID) then LID.Free;
  LFunc := TPGFunction.Create(ANivel, LName);

  AGrammar.TokenList.Next; // Pula o nome da função

  if AGrammar.Consume(pgkLPar) then
  begin
    if AGrammar.Match(pgkIdentifier) then
      TPGVariantDeclare.ExecuteEx(AGrammar, LFunc.ParamsList);

    if AGrammar.Consume(pgkRPar) and AGrammar.Consume(pgkSemiColon) then
    begin
      FindEnd(AGrammar, True, LFunc.Tokens);

      if not AGrammar.HasError then
      begin
        // CÁLCULO DO RETRATO: Até o Offset do próximo token (inclusive espaços/newlines)
        LEndPos := AGrammar.TokenList.Current.Coordinate.Offset;

        // Se o token atual for um ";", somamos o comprimento dele para o retrato
        if AGrammar.Match(pgkSemiColon) then
          LEndPos := LEndPos + AGrammar.TokenList.Current.Coordinate.Length;

        LFunc.Script := Copy(AGrammar.Script, AStartPos + 1, LEndPos - AStartPos);
      end;
    end;
  end;
end;

initialization
  TPGFunctionDeclare.Create(GlobalItemCommand, 'Function');
  TPGFunction.GlobList := TPGFolder.Create(GlobalCollection, 'Functions');

end.
