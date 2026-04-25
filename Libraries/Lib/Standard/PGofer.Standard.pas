unit PGofer.Standard;

interface

uses
  System.SysUtils, System.Rtti,
  PGofer.Sintatico, PGofer.Classes, PGofer.Runtime;

type
  { Utilitários de String }
  TPGCopy = class(TPGItemClass)
  public
    function ExecuteAction(AValue: string; AStart, ACount: Integer): string;
  end;

  TPGDelete = class(TPGItemClass)
  public
    function ExecuteAction(AValue: string; AStart, ACount: Integer): string;
  end;

  TPGInsert = class(TPGItemClass)
  public
    function ExecuteAction(const ATarget, AValue: string; AStart: Integer): string;
  end;

  { Sistema }
  TPGDelay = class(TPGItemClass)
  public
    procedure ExecuteAction(ADelayMS: Cardinal);
  end;

  TPGRead = class(TPGItemClass)
  public
    function ExecuteAction(const ATitle, ADefault: string): string;
  end;

  { Controle de Fluxo }
  TPGIf = class(TPGItemClass)
  public
    constructor Create(AOwner: TPGItem; const AName: string = ''); override;
    function ExecuteAction(ACondition: Boolean; const ATrueValue, AFalseValue: TValue): TValue;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGFor = class(TPGItemClass)
  public
    constructor Create(AOwner: TPGItem; const AName: string = ''); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGWhile = class(TPGItemClass)
  public
    constructor Create(AOwner: TPGItem; const AName: string = ''); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGRepeat = class(TPGItemClass)
  public
    constructor Create(AOwner: TPGItem; const AName: string = ''); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  { Gestão de Memória }
  TPGIsDef = class(TPGItemClass)
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGUnDef = class(TPGItemClass)
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  { Saída de Console }
  TPGWrite = class(TPGItemClass)
  public
    procedure ExecuteAction(const AText: string; ANewLine: Boolean = False);
  end;

  TPGWriteLN = class(TPGWrite)
  public
    procedure ExecuteAction(const AText: string); overload;
  end;

implementation

uses
  Vcl.Dialogs,
  PGofer.Core, PGofer.Lexico, PGofer.Sintatico.Controls,
  PGofer.Standard.Variants;

{ TPGCopy }
function TPGCopy.ExecuteAction(AValue: string; AStart, ACount: Integer): string;
begin
  Result := System.Copy(AValue, AStart, ACount);
end;

{ TPGDelete }
function TPGDelete.ExecuteAction(AValue: string; AStart, ACount: Integer): string;
begin
  System.Delete(AValue, AStart, ACount);
  Result := AValue;
end;

{ TPGInsert }
function TPGInsert.ExecuteAction(const ATarget, AValue: string; AStart: Integer): string;
var LTemp: string;
begin
  LTemp := ATarget;
  System.Insert(AValue, LTemp, AStart);
  Result := LTemp;
end;

{ TPGDelay }
procedure TPGDelay.ExecuteAction(ADelayMS: Cardinal);
begin
  Sleep(ADelayMS);
end;

{ TPGRead }
function TPGRead.ExecuteAction(const ATitle, ADefault: string): string;
var LInput: string;
begin
  LInput := ADefault;
  RunInMainThread(procedure begin
    InputQuery('PGofer', ATitle, LInput);
  end, True);
  Result := LInput;
end;

{ TPGIf }
constructor TPGIf.Create(AOwner: TPGItem; const AName: string);
begin
  inherited;
  TPGLexicalRegistry.RegisterKeyword('then', pgkKeyword, 'then');
  TPGLexicalRegistry.RegisterKeyword('else', pgkKeyword, 'else');
end;

function TPGIf.ExecuteAction(ACondition: Boolean; const ATrueValue, AFalseValue: TValue): TValue;
begin
  if ACondition then Result := ATrueValue else Result := AFalseValue;
end;

procedure TPGIf.Execute(const AGrammar: TPGGrammar);
var
  LCondition: Boolean;
begin
  if AGrammar.TokenList.Peek(1).Kind = pgkLPar then
  begin
    inherited Execute(AGrammar); // Chama TPGItemClass.Execute (RTTI Funcional)
    Exit;
  end;

  AGrammar.TokenList.Next; // Pula 'if'
  Expression(AGrammar);    // Avalia a condição

  if not AGrammar.HasError then
  begin
    LCondition := ValueToBoolean(AGrammar.Stack.Pop);

    if AGrammar.ConsumeKeyword('then') then
    begin
      // --- BLOCO THEN ---
      if LCondition then
        Commands(AGrammar)
      else
        FindEnd(AGrammar, AGrammar.Match(pgkBegin));

      // --- TRATAMENTO DO ELSE ---
      // Se houver um ";" entre o comando do THEN e o ELSE, pulamos ele para checar o ELSE
      if AGrammar.Match(pgkSemiColon) then
      begin
        // Espia o próximo token sem avançar o ponteiro principal
        if SameText(AGrammar.TokenList.Items[AGrammar.TokenList.Position + 1].Value.ToString, 'else') then
          AGrammar.TokenList.Next; // Pula o ";" apenas se o próximo for o ELSE
      end;

      if (not AGrammar.HasError) and AGrammar.MatchKeyword('else') then
      begin
        AGrammar.TokenList.Next; // Pula 'else'

        // --- BLOCO ELSE ---
        if not LCondition then
          Commands(AGrammar)
        else
          FindEnd(AGrammar, AGrammar.Match(pgkBegin));
      end;
    end;
  end;
end;

{ TPGFor }
constructor TPGFor.Create(AOwner: TPGItem; const AName: string);
begin
  inherited;
  TPGLexicalRegistry.RegisterKeyword('to', pgkKeyword, 'to');
  TPGLexicalRegistry.RegisterKeyword('downto', pgkKeyword, 'downto');
  TPGLexicalRegistry.RegisterKeyword('do', pgkKeyword, 'do');
end;

procedure TPGFor.Execute(const AGrammar: TPGGrammar);
var
  LVar: TPGVariant;
  LStart, LLimit: Int64;
  LCounter, LLoopLimit: Cardinal;
  LIsDownTo: Boolean;
  LStartPos: Integer;
begin
  LLoopLimit := TPGKernel.LoopLimit;
  AGrammar.TokenList.Next; // Pula 'for'

  LVar := TPGVariant.GetOrCreate(AGrammar);
  if Assigned(LVar) then
  begin
    LVar.Execute(AGrammar); // Processa "i := 0"
    LStart := ValueToInt64(LVar.Value);

    LIsDownTo := AGrammar.MatchKeyword('downto');
    if AGrammar.MatchKeyword('to') or LIsDownTo then
    begin
      AGrammar.TokenList.Next; // Pula 'to'/'downto'
      Expression(AGrammar);
      LLimit := ValueToInt64(AGrammar.Stack.Pop);

      if AGrammar.ConsumeKeyword('do') then
      begin
        if AGrammar.HasError then Exit;
        LStartPos := AGrammar.TokenList.Position;
        LCounter := 0;

        while (not AGrammar.HasError) and (LCounter < LLoopLimit) and
              (((not LIsDownTo) and (LStart <= LLimit)) or
               (LIsDownTo and (LStart >= LLimit))) do
        begin
          AGrammar.TokenList.Position := LStartPos;
          Commands(AGrammar);
          if LIsDownTo then Dec(LStart) else Inc(LStart);
          Inc(LCounter);
          LVar.Value := LStart;
        end;

        AGrammar.TokenList.Position := LStartPos;
        FindEnd(AGrammar, AGrammar.Match(pgkBegin));

        if LCounter >= LLoopLimit then
          AGrammar.Error('Error_Interpreter_LoopLimit', [LLoopLimit]);
      end;
    end;
  end;
end;

{ TPGWhile }
constructor TPGWhile.Create(AOwner: TPGItem; const AName: string);
begin
  inherited;
  TPGLexicalRegistry.RegisterKeyword('do', pgkKeyword, 'do');
end;

procedure TPGWhile.Execute(const AGrammar: TPGGrammar);
var
  LStartPos: Integer;
  LLoopLimit: Cardinal;
  LCounter: Cardinal;
begin
  LLoopLimit := TPGKernel.LoopLimit;
  LCounter := 0;
  AGrammar.TokenList.Next; // Pula 'while'
  LStartPos := AGrammar.TokenList.Position;

  while (not AGrammar.HasError) and (LCounter < LLoopLimit) do
  begin
    AGrammar.TokenList.Position := LStartPos;
    Expression(AGrammar);

    if ValueToBoolean(AGrammar.Stack.Pop) then
    begin
      if AGrammar.ConsumeKeyword('do') then
        Commands(AGrammar)
      else Break;
    end
    else
    begin
      AGrammar.ConsumeKeyword('do');
      FindEnd(AGrammar, AGrammar.Match(pgkBegin));
      Break;
    end;
    Inc(LCounter);
  end;
end;

{ TPGRepeat }
constructor TPGRepeat.Create(AOwner: TPGItem; const AName: string);
begin
  inherited;
  TPGLexicalRegistry.RegisterKeyword('until', pgkKeyword, 'until');
end;

procedure TPGRepeat.Execute(const AGrammar: TPGGrammar);
var
  LStartPos: Integer;
  LLoopLimit: Cardinal;
  LCounter: Cardinal;
begin
  LLoopLimit := TPGKernel.LoopLimit;
  LCounter := 0;
  AGrammar.TokenList.Next; // Pula 'repeat'
  LStartPos := AGrammar.TokenList.Position;

  repeat
    AGrammar.TokenList.Position := LStartPos;
    Statements(AGrammar);

    if AGrammar.ConsumeKeyword('until') then
    begin
      Expression(AGrammar);
      if ValueToBoolean(AGrammar.Stack.Pop) then Break;
    end else Break;

    Inc(LCounter);
  until (AGrammar.HasError) or (LCounter >= LLoopLimit);
end;

{ TPGIsDef }
procedure TPGIsDef.Execute(const AGrammar: TPGGrammar);
var LName: string;
begin
  AGrammar.TokenList.Next; // Pula nome
  if ReadParameters(AGrammar, 1, 1) = 1 then
  begin
    LName := ValueToString(AGrammar.Stack.Pop);
    AGrammar.Stack.Push(Assigned(FindID(AGrammar.Local, LName)));
  end;
end;

{ TPGUnDef }
procedure TPGUnDef.Execute(const AGrammar: TPGGrammar);
var
  LName: string;
  LItem: TPGItem;
begin
  AGrammar.TokenList.Next; // Pula nome
  if ReadParameters(AGrammar, 1, 1) = 1 then
  begin
    LName := ValueToString(AGrammar.Stack.Pop);
    LItem := FindID(AGrammar.Local, LName);
    if Assigned(LItem) and (not LItem.SystemNode) then
    begin
      LItem.Free;
      AGrammar.Stack.Push(True);
    end else
      AGrammar.Stack.Push(False);
  end;
end;

{ TPGWrite }
procedure TPGWrite.ExecuteAction(const AText: string; ANewLine: Boolean);
begin
  TPGKernel.Console(AText, ANewLine, TPGKernel.ConsoleMessage);
end;

{ TPGWriteLN }
procedure TPGWriteLN.ExecuteAction(const AText: string);
begin
  inherited ExecuteAction(AText, True);
end;

initialization
  TPGCopy.Create(GlobalItemCommand);
  TPGDelete.Create(GlobalItemCommand);
  TPGInsert.Create(GlobalItemCommand);
  TPGDelay.Create(GlobalItemCommand);
  TPGRead.Create(GlobalItemCommand);
  TPGIf.Create(GlobalItemCommand);
  TPGFor.Create(GlobalItemCommand);
  TPGWhile.Create(GlobalItemCommand);
  TPGRepeat.Create(GlobalItemCommand);
  TPGIsDef.Create(GlobalItemCommand);
  TPGUnDef.Create(GlobalItemCommand);
  TPGWrite.Create(GlobalItemCommand);
  TPGWriteLN.Create(GlobalItemCommand);

end.
