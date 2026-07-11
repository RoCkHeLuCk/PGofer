unit PGofer.Sintatico.Controls;

interface

uses
  System.SysUtils, System.Rtti, System.Math,
  PGofer.Core, PGofer.Classes, PGofer.Lexico, PGofer.Sintatico;

{ Estruturas de Controle e Sentenças }
procedure Statements(const AGrammar: TPGGrammar);
procedure Commands(const AGrammar: TPGGrammar);
procedure Identifier(const AGrammar: TPGGrammar);
function ReadParameters(const AGrammar: TPGGrammar; const AMin, AMax: Byte): Byte;
procedure FindEnd(const AGrammar: TPGGrammar; const AIsBeginEnd: Boolean;
  const ATokenList: TPGTokenList = nil);
procedure SkipExpressionTerm(const AGrammar: TPGGrammar; const AStopKinds: TPGTokenKinds);

{ Atribuição }
function Assignment(const AGrammar: TPGGrammar; const ACurrentValue: TValue): TValue;

{ Expressões (A Calculadora Turbinada) }
procedure Expression(const AGrammar: TPGGrammar); // Nível 0: and, or, xor
procedure ExpressionRelational(const AGrammar: TPGGrammar); // Nível 1: =, <>, >, <, >=, <=
procedure ExpressionLevel1(const AGrammar: TPGGrammar); // Nível 2: +, -
procedure ExpressionLevel2(const AGrammar: TPGGrammar); // Nível 3: *, /, mod
procedure ExpressionLevel3(const AGrammar: TPGGrammar); // Nível 4: ^, root
procedure Factor(const AGrammar: TPGGrammar); // Nível 5: Unários, (), [], Identificadores

{ Busca }
function FindID(const AItem: TPGItem; const AName: string): TPGItem;

implementation

uses
  System.StrUtils, PGofer.Runtime;

{ --- Auxiliares de Execução --- }

procedure Statements(const AGrammar: TPGGrammar);
begin
  while (not AGrammar.HasError) and (not AGrammar.Match(pgkEOF)) do
  begin
    if AGrammar.Match(pgkSemiColon) then
    begin
      AGrammar.Next;
      Continue;
    end;

    // SEGREDO: Se o que vem a frente NÃO é o início de um comando,
    // significa que chegamos ao fim do bloco (pode ser um end, else, until, etc.)
    if not AGrammar.IsStartOfCommand then
      Break;

    // Se for um ";" isolado, apenas pula
    if AGrammar.Match(pgkSemiColon) then
    begin
      AGrammar.Next;
      Continue;
    end;

    Commands(AGrammar);

    // --- PENTE FINO DE LINHA (Check de Saúde) ---
    if TPGKernel.ReportMemoryLeaks and (AGrammar.Stack.Count > 1) then
    begin

      // Reporta que esta linha específica "sujou" a pilha
      AGrammar.Msg(
        'Warning_Interpreter_Stack',
        [AGrammar.TokenList.Current.Coordinate.Line,
         AGrammar.Stack.Count]
      );

      // LIMPEZA FORÇADA: Para a próxima linha começar do zero
      while AGrammar.Stack.Count > 0 do AGrammar.Stack.Pop;
    end;

    if AGrammar.HasError then
      Exit;

    // Semicolon opcional antes de fechamento de blocos
    if AGrammar.Match(pgkSemiColon) then
      AGrammar.Next
    else
    begin
      // Se não tem ";" mas o próximo token NÃO é um início de comando,
      // assumimos que o bloco fechou e o ";" era opcional.
      if not AGrammar.IsStartOfCommand then
        Break;

      AGrammar.Error('Error_Expected', [';']);
      Exit;
    end;
  end;
end;

procedure Commands(const AGrammar: TPGGrammar);
var
  LToken: TPGToken;
  LResult: TValue;
begin
  LToken := AGrammar.TokenList.Current;
  if (LToken = nil) or (LToken.Kind = pgkEOF) then
    Exit;

  case LToken.Kind of
    // Modo Calculadora: = 10 + 20
    pgkAssign, pgkEqual:
      begin
        AGrammar.Next;
        Expression(AGrammar);
        if not AGrammar.HasError then
        begin
          LResult := AGrammar.Stack.Pop;
          AGrammar.Msg(FormatCalculatorResult(LResult), []);
        end;
      end;

    pgkBegin:
      begin
        AGrammar.Next;
        Statements(AGrammar);
        AGrammar.Consume(pgkEnd);
      end;

    pgkIdentifier:
      Identifier(AGrammar);
  else
    AGrammar.Error('Error_Interpreter_Struct', []);
  end;
end;

procedure Identifier(const AGrammar: TPGGrammar);
var
  LItem: TPGItem;
  LName: string;
begin
  if AGrammar.HasError then
    Exit;

  LName := AGrammar.TokenList.Current.Value.ToString;

  // Tratamento especial para o comando Debug
  if SameText(LName, 'Debug') then
  begin
    AGrammar.CheckBreakpoint;
    AGrammar.Next;
    Exit;
  end;

  LItem := FindID(AGrammar.Local, LName);

  if Assigned(LItem) then
  begin
    if LItem is TPGItemClass then
    begin
      TPGItemClass(LItem).Execute(AGrammar);
    end else begin
      AGrammar.Error('Error_Interpreter_IdUnRec', [LName]);
      AGrammar.Next;
    end;
  end else begin
    AGrammar.Error('Error_Interpreter_IdUnRec', [LName]);
    AGrammar.Next;
  end;
end;

{ --- Expressões Matemáticas --- }

procedure Expression(const AGrammar: TPGGrammar);
var
  LOp: TPGTokenKind;
  LV1, LV2: TValue;
begin
  ExpressionRelational(AGrammar);

  while AGrammar.TokenList.Current.Kind in [pgkAnd, pgkOr, pgkXor] do
  begin
    LOp := AGrammar.TokenList.Current.Kind;
    //AGrammar.Next;
    LV1 := AGrammar.Stack.Pop;

    // Curto-circuito do AND
    if (LOp = pgkAnd) and (not ValueToBoolean(LV1)) then
    begin
      SkipExpressionTerm(AGrammar, [pgkOr, pgkXor]);
      AGrammar.Stack.Push(False);
      Continue;
    end;

    // Curto-circuito do OR
    if (LOp = pgkOr) and (ValueToBoolean(LV1)) then
    begin
      SkipExpressionTerm(AGrammar, [pgkAnd, pgkXor]);
      AGrammar.Stack.Push(True);
      Continue;
    end;

    // Sem Curto
    AGrammar.Next;
    ExpressionRelational(AGrammar);
    LV2 := AGrammar.Stack.Pop;

    case LOp of
      pgkAnd:
        AGrammar.Stack.Push(ValueToBoolean(LV1) and ValueToBoolean(LV2));
      pgkOr:
        AGrammar.Stack.Push(ValueToBoolean(LV1) or ValueToBoolean(LV2));
      pgkXor:
        AGrammar.Stack.Push(ValueToBoolean(LV1) xor ValueToBoolean(LV2));
    end;
  end;
end;

procedure ExpressionRelational(const AGrammar: TPGGrammar);
var
  LOp: TPGTokenKind;
  LV1, LV2: TValue;
begin
  ExpressionLevel1(AGrammar);
  while AGrammar.TokenList.Current.Kind in [pgkEqual, pgkNotEqual, pgkGreater, pgkLess,
    pgkGreaterEqual, pgkLessEqual] do
  begin
    LOp := AGrammar.TokenList.Current.Kind;
    AGrammar.Next;
    ExpressionLevel1(AGrammar);
    LV2 := AGrammar.Stack.Pop;
    LV1 := AGrammar.Stack.Pop;
    case LOp of
      pgkEqual:
        AGrammar.Stack.Push(ValueToExtended(LV1) = ValueToExtended(LV2));
      pgkNotEqual:
        AGrammar.Stack.Push(ValueToExtended(LV1) <> ValueToExtended(LV2));
      pgkGreater:
        AGrammar.Stack.Push(ValueToExtended(LV1) > ValueToExtended(LV2));
      pgkLess:
        AGrammar.Stack.Push(ValueToExtended(LV1) < ValueToExtended(LV2));
      pgkGreaterEqual:
        AGrammar.Stack.Push(ValueToExtended(LV1) >= ValueToExtended(LV2));
      pgkLessEqual:
        AGrammar.Stack.Push(ValueToExtended(LV1) <= ValueToExtended(LV2));
    end;
  end;
end;

procedure ExpressionLevel1(const AGrammar: TPGGrammar);
var
  LOp: TPGTokenKind;
  LV1, LV2: TValue;
begin
  ExpressionLevel2(AGrammar);
  while AGrammar.TokenList.Current.Kind in [pgkAdd, pgkSub] do
  begin
    LOp := AGrammar.TokenList.Current.Kind;
    AGrammar.Next;
    ExpressionLevel2(AGrammar);
    LV2 := AGrammar.Stack.Pop;
    LV1 := AGrammar.Stack.Pop;
    if LOp = pgkAdd then
      AGrammar.Stack.Push(ValueAdd(LV1, LV2))
    else
      AGrammar.Stack.Push(ValueToExtended(LV1) - ValueToExtended(LV2));
  end;
end;

procedure ExpressionLevel2(const AGrammar: TPGGrammar);
var
  LOp: TPGTokenKind;
  LV1, LV2: TValue;
begin
  ExpressionLevel3(AGrammar);
  while AGrammar.TokenList.Current.Kind in [pgkMult, pgkDiv, pgkMod] do
  begin
    LOp := AGrammar.TokenList.Current.Kind;
    AGrammar.Next;
    ExpressionLevel3(AGrammar);
    LV2 := AGrammar.Stack.Pop;
    LV1 := AGrammar.Stack.Pop;
    case LOp of
      pgkMult:
        AGrammar.Stack.Push(ValueToExtended(LV1) * ValueToExtended(LV2));
      pgkDiv:
        if ValueToExtended(LV2) <> 0 then
          AGrammar.Stack.Push(ValueToExtended(LV1) / ValueToExtended(LV2))
        else
          AGrammar.Error('Error_Interpreter_Div0', []);
      pgkMod:
        AGrammar.Stack.Push(Trunc(ValueToExtended(LV1)) mod Trunc(ValueToExtended(LV2)));
    end;
  end;
end;

procedure ExpressionLevel3(const AGrammar: TPGGrammar);
var
  LOp: TPGTokenKind;
  LV1, LV2: TValue;
begin
  Factor(AGrammar);
  while AGrammar.TokenList.Current.Kind in [pgkPower, pgkRoot] do
  begin
    LOp := AGrammar.TokenList.Current.Kind;
    AGrammar.Next;
    Factor(AGrammar);
    LV2 := AGrammar.Stack.Pop;
    LV1 := AGrammar.Stack.Pop;
    if LOp = pgkRoot then
      if ValueToExtended(LV2) <> 0 then
        AGrammar.Stack.Push(Power(ValueToExtended(LV1), 1 / ValueToExtended(LV2)))
      else
        AGrammar.Error('Error_Interpreter_Root0', [])
    else
      AGrammar.Stack.Push(Power(ValueToExtended(LV1), ValueToExtended(LV2)));
  end;
end;

procedure Factor(const AGrammar: TPGGrammar);
var
  LArray: TArray<TValue>;
begin
  if AGrammar.HasError then Exit;

  case AGrammar.TokenList.Current.Kind of
    pgkNumber, pgkString:
      begin
        AGrammar.Stack.Push(AGrammar.TokenList.Current.Value);
        AGrammar.Next;
      end;

    pgkIdentifier:
      Identifier(AGrammar);

    pgkLPar:
      begin
        AGrammar.Next;
        Expression(AGrammar);
        AGrammar.Consume(pgkRPar);
      end;

    pgkLBrack: // Arrays [1, 2, 3]
      begin
        AGrammar.Next;
        SetLength(LArray, 0);
        while (not AGrammar.Match(pgkRBrack)) and (not AGrammar.HasError) do
        begin
          Expression(AGrammar);
          SetLength(LArray, Length(LArray) + 1);
          LArray[High(LArray)] := AGrammar.Stack.Pop;
          if AGrammar.Match(pgkComma) then
            AGrammar.Next;
        end;
        AGrammar.Consume(pgkRBrack);
        AGrammar.Stack.Push(TValue.From < TArray < TValue >> (LArray));
      end;

    pgkSub: // Unário negativo
      begin
        AGrammar.Next;
        Factor(AGrammar);
        AGrammar.Stack.Push(ValueToExtended(AGrammar.Stack.Pop) * -1);
      end;

    pgkNot: // Unário not
      begin
        AGrammar.Next;
        Factor(AGrammar);
        AGrammar.Stack.Push(not ValueToBoolean(AGrammar.Stack.Pop));
      end;
  else
    AGrammar.Error('Error_Interpreter_Expression', []);
  end;
end;

{ --- Estruturas Auxiliares --- }

function ReadParameters(const AGrammar: TPGGrammar; const AMin, AMax: Byte): Byte;
var
  LCount: Byte;
begin
  Result := 0;
  if not AGrammar.Match(pgkLPar) then
  begin
    if AMin > 0 then
      AGrammar.Error('Error_Expected', ['(']);
    Exit;
  end;

  AGrammar.Next;
  LCount := 0;
  while (LCount < AMax) and (not AGrammar.Match(pgkRPar)) and (not AGrammar.HasError) do
  begin
    Expression(AGrammar);
    Inc(LCount);
    if AGrammar.Match(pgkComma) then
      AGrammar.Next;
  end;

  if (LCount < AMin) then
    AGrammar.Error('Error_Interpreter_TooFewParams', [AMin])
  else if AGrammar.Consume(pgkRPar) then
    Result := LCount;
end;

procedure FindEnd(const AGrammar: TPGGrammar; const AIsBeginEnd: Boolean; const ATokenList: TPGTokenList);
var
  LStartLevel: Integer;
begin
  LStartLevel := AGrammar.NestingLevel;

  if AIsBeginEnd then
  begin
    // 1. Consome o 'begin' inicial. O NestingLevel vai subir (ex: de 0 para 1)
    AGrammar.Next;

    // 2. Continua consumindo tokens enquanto estiver "dentro" do bloco
    // Para quando o nível voltar a ser o que era antes do 'begin'
    while (AGrammar.NestingLevel > LStartLevel) and (not AGrammar.Match(pgkEOF)) and (not AGrammar.HasError) do
    begin
      if Assigned(ATokenList) then
        ATokenList.Add(AGrammar.TokenList.Current.Kind, AGrammar.TokenList.Current.Value, AGrammar.TokenList.Current.Coordinate);

      AGrammar.Next;
    end;
  end
  else
  begin
    // COMANDO ÚNICO: pula até o próximo ";" ou delimitador no MESMO nível
    while not (AGrammar.Match(pgkEOF) or AGrammar.HasError) do
    begin
      if (AGrammar.NestingLevel = LStartLevel) then
      begin
        if AGrammar.Match(pgkSemiColon) or AGrammar.MatchKeyword('else') or AGrammar.MatchKeyword('until') then
          Break;
      end;

      // Se o comando único fechou um bloco (ex: 'if A then Exit)'), paramos.
      if AGrammar.NestingLevel < LStartLevel then Break;

      AGrammar.Next;
    end;
  end;
end;

procedure SkipExpressionTerm(const AGrammar: TPGGrammar; const AStopKinds: TPGTokenKinds);
var
  LStartLevel: Integer;
  LKind: TPGTokenKind;
begin
  LStartLevel := AGrammar.NestingLevel;

  while not (AGrammar.Match(pgkEOF) or AGrammar.HasError) do
  begin
    LKind := AGrammar.TokenList.Current.Kind;

    if AGrammar.IsCloser(LKind) and (AGrammar.NestingLevel <= LStartLevel) then
      Exit;

    if AGrammar.NestingLevel = LStartLevel then
    begin
      if (LKind in [pgkSemiColon, pgkComma]) or (LKind in AStopKinds) then
        Exit;

      if LKind = pgkKeyword then
        if MatchText(AGrammar.TokenList.Current.Value.ToString,
           ['then', 'do', 'to', 'downto', 'until', 'else']) then Exit;
    end;

    AGrammar.Next;
  end;
end;

function Assignment(const AGrammar: TPGGrammar; const ACurrentValue: TValue): TValue;
begin
  AGrammar.Next;
  if AGrammar.Match(pgkAssign) then
  begin
    AGrammar.Next;
    Expression(AGrammar);
    Result := AGrammar.Stack.Pop;
  end
  else
  begin
    AGrammar.Stack.Push(ACurrentValue);
    Result := ACurrentValue;
  end;
end;

function FindID(const AItem: TPGItem; const AName: string): TPGItem;
var
  LCurrentScope: TPGItem;
begin
  Result := nil;
  if AName = '' then
    Exit;

  LCurrentScope := AItem;
  while Assigned(LCurrentScope) do
  begin
    Result := LCurrentScope.FindName(AName);
    if Assigned(Result) then
      Exit;
    LCurrentScope := LCurrentScope.Parent;
  end;
  Result := TPGItem.FindName(nil, AName);
end;



end.

