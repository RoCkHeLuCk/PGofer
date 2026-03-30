unit PGofer.Sintatico.Controls;

interface

uses
  System.SysUtils, System.Rtti, System.Math,
  PGofer.Classes, PGofer.Lexico, PGofer.Sintatico;

{ Estruturas de Controle e Sentenças }
procedure Statements(const AGrammar: TPGGrammar);
procedure Commands(const AGrammar: TPGGrammar);
procedure Identifier(const AGrammar: TPGGrammar);
function  ReadParameters(const AGrammar: TPGGrammar; const AMin, AMax: Byte): Byte;
procedure FindEnd(const AGrammar: TPGGrammar; const AIsBeginEnd: Boolean; const ATokenList: TPGTokenList = nil);

{ Atribuição }
function Assignment(const AGrammar: TPGGrammar; const ACurrentValue: TValue): TValue;

{ Expressões (A Calculadora Turbinada) }
procedure Expression(const AGrammar: TPGGrammar);          // Nível 0: and, or, xor
procedure ExpressionRelational(const AGrammar: TPGGrammar); // Nível 1: =, <>, >, <, >=, <=
procedure ExpressionLevel1(const AGrammar: TPGGrammar);     // Nível 2: +, -
procedure ExpressionLevel2(const AGrammar: TPGGrammar);     // Nível 3: *, /, mod
procedure ExpressionLevel3(const AGrammar: TPGGrammar);     // Nível 4: ^, root
procedure Factor(const AGrammar: TPGGrammar);               // Nível 5: Unários, (), [], Identificadores

{ Busca }
function FindID(const AItem: TPGItem; const AName: string): TPGItem;

implementation

uses
  PGofer.Core, PGofer.Runtime, PGofer.Math.Controls;

{ --- Auxiliares de Execução --- }

procedure Statements(const AGrammar: TPGGrammar);
begin
  while (not AGrammar.HasError) and (not AGrammar.Match(pgkEOF)) do
  begin
    if AGrammar.Match(pgkSemiColon) then
    begin
      AGrammar.TokenList.Next;
      Continue;
    end;

    // SEGREDO: Se o que vem a frente NÃO é o início de um comando,
    // significa que chegamos ao fim do bloco (pode ser um end, else, until, etc.)
    if not AGrammar.IsStartOfCommand then
      Break;

    // Se for um ";" isolado, apenas pula
    if AGrammar.Match(pgkSemiColon) then
    begin
      AGrammar.TokenList.Next;
      Continue;
    end;

    Commands(AGrammar);

    if AGrammar.HasError then Exit;

    // Semicolon opcional antes de fechamento de blocos
    if AGrammar.Match(pgkSemiColon) then
      AGrammar.TokenList.Next
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
  if (LToken = nil) or (LToken.Kind = pgkEOF) then Exit;

  case LToken.Kind of
    // Modo Calculadora: = 10 + 20
    pgkEqual:
    begin
      AGrammar.TokenList.Next;
      Expression(AGrammar);
      if not AGrammar.HasError then
      begin
        LResult := AGrammar.Stack.Pop;
        AGrammar.Msg(FormatCalculatorResult(LResult), []);
      end;
    end;

    pgkBegin:
    begin
      AGrammar.TokenList.Next;
      Statements(AGrammar);
      AGrammar.Consume(pgkEnd);
    end;

    pgkIdentifier: Identifier(AGrammar);
  else
    AGrammar.Error('Error_Interpreter_Struct', []);
  end;
end;

procedure Identifier(const AGrammar: TPGGrammar);
var
  LItem: TPGItem;
  LName: string;
begin
  if AGrammar.HasError then Exit;

  LName := AGrammar.TokenList.Current.Value.ToString;

  // Tratamento especial para o comando Debug
  if SameText(LName, 'Debug') then
  begin
    AGrammar.CheckBreakpoint;
    AGrammar.TokenList.Next;
    Exit;
  end;

  LItem := FindID(AGrammar.Local, LName);

  if Assigned(LItem) then
  begin
    if LItem is TPGItemClass then
    begin
      // Lógica de "Engolir" se desabilitado
      if not LItem.Enabled then
      begin
        AGrammar.TokenList.Next;
        if AGrammar.Match(pgkLPar) then ReadParameters(AGrammar, 0, 255);
      end
      else
        TPGItemClass(LItem).Execute(AGrammar);
    end
    else
      AGrammar.Error('Error_Interpreter_IdUnRec', [LName]);
  end
  else
    AGrammar.Error('Error_Interpreter_IdUnRec', [LName]);
end;

{ --- Expressões Matemáticas --- }

procedure Expression(const AGrammar: TPGGrammar);
var LOp: TPGTokenKind; LV1, LV2: TValue;
begin
  ExpressionRelational(AGrammar);
  while AGrammar.TokenList.Current.Kind in [pgkAnd, pgkOr, pgkXor] do
  begin
    LOp := AGrammar.TokenList.Current.Kind; AGrammar.TokenList.Next;
    ExpressionRelational(AGrammar);
    LV2 := AGrammar.Stack.Pop; LV1 := AGrammar.Stack.Pop;
    case LOp of
      pgkAnd: AGrammar.Stack.Push(ValueToBoolean(LV1) and ValueToBoolean(LV2));
      pgkOr:  AGrammar.Stack.Push(ValueToBoolean(LV1) or ValueToBoolean(LV2));
      pgkXor: AGrammar.Stack.Push(ValueToBoolean(LV1) xor ValueToBoolean(LV2));
    end;
  end;
end;

procedure ExpressionRelational(const AGrammar: TPGGrammar);
var LOp: TPGTokenKind; LV1, LV2: TValue;
begin
  ExpressionLevel1(AGrammar);
  while AGrammar.TokenList.Current.Kind in [pgkEqual, pgkNotEqual, pgkGreater, pgkLess, pgkGreaterEqual, pgkLessEqual] do
  begin
    LOp := AGrammar.TokenList.Current.Kind; AGrammar.TokenList.Next;
    ExpressionLevel1(AGrammar);
    LV2 := AGrammar.Stack.Pop; LV1 := AGrammar.Stack.Pop;
    case LOp of
      pgkEqual:        AGrammar.Stack.Push(ValueToExtended(LV1) = ValueToExtended(LV2));
      pgkNotEqual:     AGrammar.Stack.Push(ValueToExtended(LV1) <> ValueToExtended(LV2));
      pgkGreater:      AGrammar.Stack.Push(ValueToExtended(LV1) > ValueToExtended(LV2));
      pgkLess:         AGrammar.Stack.Push(ValueToExtended(LV1) < ValueToExtended(LV2));
      pgkGreaterEqual: AGrammar.Stack.Push(ValueToExtended(LV1) >= ValueToExtended(LV2));
      pgkLessEqual:    AGrammar.Stack.Push(ValueToExtended(LV1) <= ValueToExtended(LV2));
    end;
  end;
end;

procedure ExpressionLevel1(const AGrammar: TPGGrammar);
var LOp: TPGTokenKind; LV1, LV2: TValue;
begin
  ExpressionLevel2(AGrammar);
  while AGrammar.TokenList.Current.Kind in [pgkAdd, pgkSub] do
  begin
    LOp := AGrammar.TokenList.Current.Kind; AGrammar.TokenList.Next;
    ExpressionLevel2(AGrammar);
    LV2 := AGrammar.Stack.Pop; LV1 := AGrammar.Stack.Pop;
    if LOp = pgkAdd then
      AGrammar.Stack.Push( ValueAdd( LV1, LV2 ) )
    else
      AGrammar.Stack.Push( ValueToExtended(LV1) - ValueToExtended(LV2) );
  end;
end;

procedure ExpressionLevel2(const AGrammar: TPGGrammar);
var LOp: TPGTokenKind; LV1, LV2: TValue;
begin
  ExpressionLevel3(AGrammar);
  while AGrammar.TokenList.Current.Kind in [pgkMult, pgkDiv, pgkMod] do
  begin
    LOp := AGrammar.TokenList.Current.Kind; AGrammar.TokenList.Next;
    ExpressionLevel3(AGrammar);
    LV2 := AGrammar.Stack.Pop; LV1 := AGrammar.Stack.Pop;
    case LOp of
      pgkMult: AGrammar.Stack.Push(ValueToExtended(LV1) * ValueToExtended(LV2));
      pgkDiv:  if ValueToExtended(LV2) <> 0 then AGrammar.Stack.Push(ValueToExtended(LV1) / ValueToExtended(LV2))
              else AGrammar.Error('Error_Interpreter_Div0', []);
      pgkMod:  AGrammar.Stack.Push(Trunc(ValueToExtended(LV1)) mod Trunc(ValueToExtended(LV2)));
    end;
  end;
end;

procedure ExpressionLevel3(const AGrammar: TPGGrammar);
var LOp: TPGTokenKind; LV1, LV2: TValue;
begin
  Factor(AGrammar);
  while AGrammar.TokenList.Current.Kind in [pgkPower, pgkRoot] do
  begin
    LOp := AGrammar.TokenList.Current.Kind; AGrammar.TokenList.Next;
    Factor(AGrammar);
    LV2 := AGrammar.Stack.Pop; LV1 := AGrammar.Stack.Pop;
    if LOp = pgkRoot then
      if ValueToExtended(LV2) <> 0 then AGrammar.Stack.Push(Power(ValueToExtended(LV1), 1 / ValueToExtended(LV2)))
      else AGrammar.Error('Error_Interpreter_Root0', [])
    else
      AGrammar.Stack.Push(Power(ValueToExtended(LV1), ValueToExtended(LV2)));
  end;
end;

procedure Factor(const AGrammar: TPGGrammar);
var
  LArray: TArray<TValue>;
begin
  case AGrammar.TokenList.Current.Kind of
    pgkNumber, pgkString:
    begin
      AGrammar.Stack.Push(AGrammar.TokenList.Current.Value);
      AGrammar.TokenList.Next;
    end;

    pgkIdentifier: Identifier(AGrammar);

    pgkLPar:
    begin
      AGrammar.TokenList.Next;
      Expression(AGrammar);
      AGrammar.Consume(pgkRPar);
    end;

    pgkLBrack: // Arrays [1, 2, 3]
    begin
      AGrammar.TokenList.Next;
      SetLength(LArray, 0);
      while (not AGrammar.Match(pgkRBrack)) and (not AGrammar.HasError) do
      begin
        Expression(AGrammar);
        SetLength(LArray, Length(LArray) + 1);
        LArray[High(LArray)] := AGrammar.Stack.Pop;
        if AGrammar.Match(pgkComma) then AGrammar.TokenList.Next;
      end;
      AGrammar.Consume(pgkRBrack);
      AGrammar.Stack.Push(TValue.From<TArray<TValue>>(LArray));
    end;

    pgkSub: // Unário negativo
    begin
      AGrammar.TokenList.Next;
      Factor(AGrammar);
      AGrammar.Stack.Push(ValueToExtended(AGrammar.Stack.Pop) * -1);
    end;

    pgkNot: // Unário not
    begin
      AGrammar.TokenList.Next;
      Factor(AGrammar);
      AGrammar.Stack.Push(not ValueToBoolean(AGrammar.Stack.Pop));
    end;
  else
    AGrammar.Error('Error_Interpreter_Expression', []);
  end;
end;

{ --- Estruturas Auxiliares --- }

function ReadParameters(const AGrammar: TPGGrammar; const AMin, AMax: Byte): Byte;
var LCount: Byte;
begin
  Result := 0;
  if not AGrammar.Match(pgkLPar) then
  begin
    if AMin > 0 then AGrammar.Error('Error_Expected', ['(']);
    Exit;
  end;

  AGrammar.TokenList.Next;
  LCount := 0;
  while (LCount < AMax) and (not AGrammar.Match(pgkRPar)) and (not AGrammar.HasError) do
  begin
    Expression(AGrammar);
    Inc(LCount);
    if AGrammar.Match(pgkComma) then AGrammar.TokenList.Next;
  end;

  if (LCount < AMin) then AGrammar.Error('Error_Interpreter_TooFewParams', [AMin])
  else if AGrammar.Consume(pgkRPar) then Result := LCount;
end;

procedure FindEnd(const AGrammar: TPGGrammar; const AIsBeginEnd: Boolean; const ATokenList: TPGTokenList);
var LBeginCount: Integer; LToken: TPGToken;
begin
  if AIsBeginEnd then
  begin
    if not AGrammar.Match(pgkBegin) then AGrammar.Error('Error_Expected', ['begin'])
    else begin
      LBeginCount := 1; AGrammar.TokenList.Next;
      repeat
        LToken := AGrammar.TokenList.Current;
        case LToken.Kind of
          pgkBegin: Inc(LBeginCount);
          pgkEnd: Dec(LBeginCount);
        end;
        if (LBeginCount <> 0) then begin
          if Assigned(ATokenList) then ATokenList.Add(LToken.Kind, LToken.Value, LToken.Coordinate);
          AGrammar.TokenList.Next;
        end;
      until (AGrammar.Match(pgkEOF)) or (LBeginCount = 0);
      AGrammar.Consume(pgkEnd);
    end;
  end
  else begin
    while not (AGrammar.TokenList.Current.Kind in [pgkEOF, pgkSemiColon]) do begin
      LToken := AGrammar.TokenList.Current;
      if Assigned(ATokenList) then ATokenList.Add(LToken.Kind, LToken.Value, LToken.Coordinate);
      AGrammar.TokenList.Next;
    end;
  end;
  // Sinaliza o fim para interpretadores locais (Funções)
  if Assigned(ATokenList) then ATokenList.Add(pgkEOF, 'EOF', AGrammar.TokenList.Current.Coordinate);
end;

function Assignment(const AGrammar: TPGGrammar; const ACurrentValue: TValue): TValue;
begin
  AGrammar.TokenList.Next;
  if AGrammar.Match(pgkAssign) then begin
    AGrammar.TokenList.Next;
    Expression(AGrammar);
    Result := AGrammar.Stack.Pop;
  end
  else begin
    AGrammar.Stack.Push(ACurrentValue);
    Result := ACurrentValue;
  end;
end;

function FindID(const AItem: TPGItem; const AName: string): TPGItem;
var LChild: TPGItem;
begin
  Result := nil;
  if not Assigned(AItem) then Exit;
  Result := AItem.FindName(AName);
  if (Result = nil) and (AItem.Parent <> nil) then Result := FindID(AItem.Parent, AName);
  if (Result = nil) and (AItem = GlobalCollection) then
    for LChild in GlobalCollection do begin
       Result := LChild.FindName(AName);
       if Assigned(Result) then Break;
    end;
end;

end.
