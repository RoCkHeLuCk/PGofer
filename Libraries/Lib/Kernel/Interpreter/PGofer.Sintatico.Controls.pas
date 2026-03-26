unit PGofer.Sintatico.Controls;

interface

uses
  System.SysUtils, System.Rtti, System.Math,
  PGofer.Classes, PGofer.Lexico, PGofer.Sintatico;

{ Estruturas de Controle }
function ReadParameters(const AGrammar: TPGGrammar; const AMin, AMax: Byte): Byte;
procedure FindEnd(const AGrammar: TPGGrammar; const AIsBeginEnd: Boolean; const ATokenList: TPGTokenList = nil);

{ Atribuição e Sentenças }
function Assignment(const AGrammar: TPGGrammar; const ACurrentValue: TValue): TValue;
procedure Statements(const AGrammar: TPGGrammar);
procedure Commands(const AGrammar: TPGGrammar);
procedure Identifier(const AGrammar: TPGGrammar);

{ Expressões }
procedure Expression(const AGrammar: TPGGrammar);
procedure ExpressionLevel1(const AGrammar: TPGGrammar);
procedure ExpressionLevel2(const AGrammar: TPGGrammar);
procedure Factor(const AGrammar: TPGGrammar);

{ Busca de Identificadores }
function FindID(const AItem: TPGItem; const AName: string): TPGItem;

implementation

uses
  System.Variants, System.Character,
  PGofer.Core, PGofer.Runtime, PGofer.Math.Controls;

{ --- Auxiliares de Matemática com TValue --- }

function TValueAdd(const AV1, AV2: TValue): TValue;
begin
  if (AV1.IsType<string>) or (AV2.IsType<string>) then
    Result := AV1.ToString + AV2.ToString
  else
    Result := AV1.AsExtended + AV2.AsExtended;
end;

{ --- Implementação das Estruturas --- }

function ReadParameters(const AGrammar: TPGGrammar; const AMin, AMax: Byte): Byte;
var
  LCount: Byte;
begin
  Result := 0;
  if not AGrammar.Match(tkLPar) then
  begin
    if AMin > 0 then AGrammar.Error('Error_Expected', ['(']);
    Exit;
  end;

  AGrammar.TokenList.Next;
  LCount := 0;
  while (LCount < AMax) and (not AGrammar.Match(tkRPar)) and (not AGrammar.HasError) do
  begin
    Expression(AGrammar);
    Inc(LCount);
    if AGrammar.Match(tkComma) then AGrammar.TokenList.Next;
  end;

  if (LCount < AMin) then
    AGrammar.Error('Error_Interpreter_TooFewParams', [AMin])
  else if AGrammar.Consume(tkRPar) then
    Result := LCount;
end;

procedure FindEnd(const AGrammar: TPGGrammar; const AIsBeginEnd: Boolean; const ATokenList: TPGTokenList);
var
  LBeginCount: Integer;
begin
  if AIsBeginEnd then
  begin
    if not AGrammar.Match(tkBegin) then
      AGrammar.Error('Error_Expected', ['begin'])
    else
    begin
      LBeginCount := 1;
      AGrammar.TokenList.Next;
      repeat
        case AGrammar.TokenList.Current.Kind of
          tkBegin: Inc(LBeginCount);
          tkEnd: Dec(LBeginCount);
        end;
        if (LBeginCount <> 0) then
        begin
          if Assigned(ATokenList) then
            ATokenList.Add(
              AGrammar.TokenList.Current.Kind,
              AGrammar.TokenList.Current.Value,
              AGrammar.TokenList.Current.Coordinate
            );
          AGrammar.TokenList.Next;
        end;
      until (AGrammar.Match(tkEOF)) or (LBeginCount = 0);
      AGrammar.Consume(tkEnd);
    end;
  end
  else
  begin
    while not (AGrammar.TokenList.Current.Kind in [tkEOF, tkSemiColon, tkElse]) do
    begin
      if Assigned(ATokenList) then
        ATokenList.Add(
          AGrammar.TokenList.Current.Kind,
          AGrammar.TokenList.Current.Value,
          AGrammar.TokenList.Current.Coordinate
        );
      AGrammar.TokenList.Next;
    end;
  end;

  if Assigned(ATokenList) and (not AGrammar.HasError) then
  begin
    ATokenList.Add(tkEOF, TValue.Empty, AGrammar.TokenList.Current.Coordinate);
  end;
end;

{ --- Sentenças e Comandos --- }

procedure Statements(const AGrammar: TPGGrammar);
begin
  // Enquanto não houver erro e não for o fim do script
  while (not AGrammar.HasError) and (not AGrammar.Match(tkEOF)) do
  begin
    // Se o próximo token for algo que fecha um bloco, paramos o loop de sentenças
    // para devolver o controle para quem chamou (ex: Commands ou o próprio script)
    if AGrammar.Match(tkEnd) or AGrammar.Match(tkUntil) or AGrammar.Match(tkElse) then
      Break;

    // Se o token for um ";" isolado (comando vazio), apenas pula
    if AGrammar.Match(tkSemiColon) then
    begin
      AGrammar.TokenList.Next;
      Continue;
    end;

    // Executa o comando atual
    Commands(AGrammar);

    if AGrammar.HasError then Exit;

    // Tratamento flexível de Ponto e Vírgula
    if AGrammar.Match(tkSemiColon) then
    begin
      AGrammar.TokenList.Next;
      // Após o ";", se for fim de bloco ou arquivo, o loop termina naturalmente
    end
    else
    begin
       // Se não tem ";" mas o próximo token fecha o bloco, ignoramos a falta do ";"
       if AGrammar.Match(tkEOF) or AGrammar.Match(tkEnd) or AGrammar.Match(tkUntil) or AGrammar.Match(tkElse) then
        Break;

       AGrammar.Error('Error_Expected', [';']);
       Exit;
    end;
  end;
end;

procedure Commands(const AGrammar: TPGGrammar);
var
  LToken: TPGToken;
  LItem: TPGItem;
begin
  if AGrammar.HasError then Exit;

  // Pega o token atual com segurança
  LToken := AGrammar.TokenList.Current;

  // Se for nil ou Fim de Arquivo, apenas sai silenciosamente
  if (LToken = nil) or (LToken.Kind = tkEOF) then
    Exit;

  case LToken.Kind of
    tkEqual: // Modo calculadora
    begin
      AGrammar.TokenList.Next;
      Expression(AGrammar);
      if not AGrammar.HasError then
        AGrammar.Msg('Result: %s', [AGrammar.Stack.Pop.ToString]);
    end;

    tkBegin:
    begin
      AGrammar.TokenList.Next;
      Statements(AGrammar);
      AGrammar.Consume(tkEnd);
    end;

    tkIf, tkFor, tkWhile, tkRepeat, tkConst, tkVar, tkFunction:
    begin
      // Busca o objeto de comando (ex: 'for')
      LItem := GlobalItemCommand.FindName(TPGLexicalRegistry.GetFriendlyName(LToken.Kind));
      if Assigned(LItem) and (LItem is TPGItemClass) then
        TPGItemClass(LItem).Execute(AGrammar)
      else
        AGrammar.Error('Error_Interpreter_Struct', []);
    end;

    tkIdentifier:
    begin
      if SameText(LToken.Value.ToString, 'Debug') then
      begin
        AGrammar.CheckBreakpoint;
        AGrammar.TokenList.Next;
      end
      else
        Identifier(AGrammar);
    end;
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
  LItem := FindID(AGrammar.Local, LName);

  if Assigned(LItem) then
  begin
    if LItem is TPGItemClass then
    begin
      if not LItem.Enabled then
      begin
        AGrammar.TokenList.Next;
        if AGrammar.Match(tkLPar) then ReadParameters(AGrammar, 0, 255);
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

{ --- Expressões e Matemática --- }

procedure Expression(const AGrammar: TPGGrammar);
var
  LOperator: TPGTokenKind;
  LV1, LV2: TValue;
begin
  ExpressionLevel1(AGrammar);

  while AGrammar.TokenList.Current.Kind in [tkAdd, tkSub, tkOr, tkAnd, tkXor] do
  begin
    LOperator := AGrammar.TokenList.Current.Kind;
    AGrammar.TokenList.Next;
    ExpressionLevel1(AGrammar);

    LV2 := AGrammar.Stack.Pop;
    LV1 := AGrammar.Stack.Pop;

    case LOperator of
      tkAdd: AGrammar.Stack.Push(TValueAdd(LV1, LV2));
      tkSub: AGrammar.Stack.Push(LV1.AsExtended - LV2.AsExtended);
      tkOr:  AGrammar.Stack.Push(LV1.AsBoolean or LV2.AsBoolean);
      tkAnd: AGrammar.Stack.Push(LV1.AsBoolean and LV2.AsBoolean);
      tkXor: AGrammar.Stack.Push(LV1.AsBoolean xor LV2.AsBoolean);
    end;
  end;
end;

procedure ExpressionLevel1(const AGrammar: TPGGrammar);
var
  LOperator: TPGTokenKind;
  LV1, LV2: TValue;
begin
  ExpressionLevel2(AGrammar);

  while AGrammar.TokenList.Current.Kind in [tkMult, tkDiv, tkMod] do
  begin
    LOperator := AGrammar.TokenList.Current.Kind;
    AGrammar.TokenList.Next;
    ExpressionLevel2(AGrammar);

    LV2 := AGrammar.Stack.Pop;
    LV1 := AGrammar.Stack.Pop;

    case LOperator of
      tkMult: AGrammar.Stack.Push(LV1.AsExtended * LV2.AsExtended);
      tkDiv:
        if LV2.AsExtended <> 0 then AGrammar.Stack.Push(LV1.AsExtended / LV2.AsExtended)
        else AGrammar.Error('Error_Interpreter_Div0', []);
      tkMod:  AGrammar.Stack.Push(Trunc(LV1.AsExtended) mod Trunc(LV2.AsExtended));
    end;
  end;
end;

procedure ExpressionLevel2(const AGrammar: TPGGrammar);
var
  LOperator: TPGTokenKind;
  LV1, LV2: TValue;
begin
  Factor(AGrammar);

  // POTENCIAÇÃO (^) E RAIZ (root)
  while AGrammar.TokenList.Current.Kind in [tkPower, tkRoot, tkTone] do
  begin
    LOperator := AGrammar.TokenList.Current.Kind;
    AGrammar.TokenList.Next;
    Factor(AGrammar);

    LV2 := AGrammar.Stack.Pop;
    LV1 := AGrammar.Stack.Pop;

    case LOperator of
      tkPower, tkTone:
        AGrammar.Stack.Push(Power(LV1.AsExtended, LV2.AsExtended));
      tkRoot:
        if LV2.AsExtended <> 0 then
          AGrammar.Stack.Push(Power(LV1.AsExtended, 1 / LV2.AsExtended))
        else
          AGrammar.Error('Error_Interpreter_Root0', []);
    end;
  end;
end;

procedure Factor(const AGrammar: TPGGrammar);
var
  LArrayValues: TArray<TValue>;
begin
  case AGrammar.TokenList.Current.Kind of
    tkNumber, tkString:
    begin
      AGrammar.Stack.Push(AGrammar.TokenList.Current.Value);
      AGrammar.TokenList.Next;
    end;

    tkIdentifier: Identifier(AGrammar);

    tkLPar:
    begin
      AGrammar.TokenList.Next;
      Expression(AGrammar);
      AGrammar.Consume(tkRPar);
    end;

    tkLBrack:
    begin
      AGrammar.TokenList.Next;
      SetLength(LArrayValues, 0);
      while (not AGrammar.Match(tkRBrack)) and (not AGrammar.HasError) do
      begin
        Expression(AGrammar);
        SetLength(LArrayValues, Length(LArrayValues) + 1);
        LArrayValues[High(LArrayValues)] := AGrammar.Stack.Pop;
        if AGrammar.Match(tkComma) then AGrammar.TokenList.Next;
      end;
      AGrammar.Consume(tkRBrack);
      AGrammar.Stack.Push(TValue.From<TArray<TValue>>(LArrayValues));
    end;

    tkSub:
    begin
      AGrammar.TokenList.Next;
      Factor(AGrammar);
      AGrammar.Stack.Push(AGrammar.Stack.Pop.AsExtended * -1);
    end;

    tkNot:
    begin
      AGrammar.TokenList.Next;
      Factor(AGrammar);
      AGrammar.Stack.Push(not AGrammar.Stack.Pop.AsBoolean);
    end;
  else
    AGrammar.Error('Error_Interpreter_Expression', []);
  end;
end;

function FindID(const AItem: TPGItem; const AName: string): TPGItem;
var
  LChild: TPGItem;
begin
  Result := nil;
  if not Assigned(AItem) then Exit;
  Result := AItem.FindName(AName);
  if (Result = nil) and (AItem.Parent <> nil) then
    Result := FindID(AItem.Parent, AName);
  if (Result = nil) and (AItem = GlobalCollection) then
  begin
    for LChild in GlobalCollection do
    begin
       Result := LChild.FindName(AName);
       if Assigned(Result) then Break;
    end;
  end;
end;

function Assignment(const AGrammar: TPGGrammar; const ACurrentValue: TValue): TValue;
begin
  AGrammar.TokenList.Next;
  if AGrammar.Match(tkAssign) then
  begin
    AGrammar.TokenList.Next;
    Expression(AGrammar);
    Result := AGrammar.Stack.Pop;
  end
  else
  begin
    AGrammar.Stack.Push(ACurrentValue);
    Result := ACurrentValue;
  end;
end;

end.
