unit PGofer.Standard;

interface

uses
  System.SysUtils, System.Rtti,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime;

type
  { Utilitários de String }
  [TPGClassReg('Commands')]
  TPGCopy = class(TPGItemClass)
  public
    function ExecuteAction(const AValue: string; const AStart, ACount: Integer): string;
  end;

  [TPGClassReg('Commands')]
  TPGDelete = class(TPGItemClass)
  public
    function ExecuteAction(const AValue: string; const AStart, ACount: Integer): string;
  end;

  [TPGClassReg('Commands')]
  TPGInsert = class(TPGItemClass)
  public
    function ExecuteAction(const ATarget, AValue: string; const AStart: Integer): string;
  end;

  { Sistema }
  [TPGClassReg('Commands')]
  TPGDelay = class(TPGItemClass)
  public
    procedure ExecuteAction(const ADelayMS: Cardinal);
  end;

  [TPGClassReg('Commands')]
  TPGRead = class(TPGItemClass)
  public
    function ExecuteAction(const ATitle, ADefault: string): string;
  end;

  { Controle de Fluxo }

  [TPGClassReg('Commands')]
  TPGIf = class(TPGItemClass)
  public
    constructor Create(const AOwner: TPGItem; const AName: string = ''); override;
    function ExecuteAction(const ACondition: Boolean; const ATrueValue, AFalseValue: TValue): TValue;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  [TPGClassReg('Commands')]
  TPGFor = class(TPGItemClass)
  public
    constructor Create(const AOwner: TPGItem; const AName: string = ''); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  [TPGClassReg('Commands')]
  TPGWhile = class(TPGItemClass)
  public
    constructor Create(const AOwner: TPGItem; const AName: string = ''); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  [TPGClassReg('Commands')]
  TPGRepeat = class(TPGItemClass)
  public
    constructor Create(const AOwner: TPGItem; const AName: string = ''); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  { Gestão de Memória }
  [TPGClassReg('Commands')]
  TPGIsDef = class(TPGItemClass)
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  [TPGClassReg('Commands')]
  TPGUnDef = class(TPGItemClass)
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  { Saída de Console }
  [TPGClassReg('Commands')]
  TPGWrite = class(TPGItemClass)
  public
    procedure ExecuteAction(const AText: string; const ANewLine: Boolean = False);
  end;

  [TPGClassReg('Commands')]
  TPGWriteLN = class(TPGWrite)
  public
    procedure ExecuteAction(const AText: string); overload;
  end;

implementation

uses
  Vcl.Dialogs,
  PGofer.Lexico, PGofer.Sintatico.Controls,
  PGofer.Standard.Variants;

{ TPGCopy }
function TPGCopy.ExecuteAction(const AValue: string; const AStart, ACount: Integer): string;
begin
  Result := System.Copy(AValue, AStart, ACount);
end;

{ TPGDelete }
function TPGDelete.ExecuteAction(const AValue: string; const AStart, ACount: Integer): string;
var
  LValue : String;
begin
  LValue := AValue;
  System.Delete(LValue, AStart, ACount);
  Result := LValue;
end;

{ TPGInsert }
function TPGInsert.ExecuteAction(const ATarget, AValue: string; const AStart: Integer): string;
var LTemp: string;
begin
  LTemp := ATarget;
  System.Insert(AValue, LTemp, AStart);
  Result := LTemp;
end;

{ TPGDelay }
procedure TPGDelay.ExecuteAction(const ADelayMS: Cardinal);
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
constructor TPGIf.Create(const AOwner: TPGItem; const AName: string);
begin
  inherited;
  TPGLexicalRegistry.RegisterKeyword('then', pgkKeyword, 'then');
  TPGLexicalRegistry.RegisterKeyword('else', pgkKeyword, 'else');
end;

function TPGIf.ExecuteAction(const ACondition: Boolean; const ATrueValue, AFalseValue: TValue): TValue;
begin
  if ACondition then Result := ATrueValue else Result := AFalseValue;
end;

procedure TPGIf.Execute(const AGrammar: TPGGrammar);
var
  LCondition: Boolean;
begin
  if (AGrammar.TokenList.Peek(1).Kind = pgkLPar) then
  begin
    inherited Execute(AGrammar);
    Exit;
  end;

  AGrammar.Next; // Pula 'if'
  Expression(AGrammar);  // exetuca até o 'then'

  if AGrammar.HasError then
    Exit;

  LCondition := ValueToBoolean(AGrammar.Stack.Pop);

  if AGrammar.ConsumeKeyword('then') then
  begin
    // --- BLOCO THEN ---
    if LCondition then
      Commands(AGrammar)
    else
      FindEnd(AGrammar, AGrammar.Match(pgkBegin));

    if AGrammar.HasError then
      Exit;

    // --- TRATAMENTO DO ELSE ---
    // Se houver um ";" entre o comando do THEN e o ELSE, pulamos ele para checar o ELSE
    if AGrammar.Match(pgkSemiColon)
    and SameText(AGrammar.TokenList.Peek(1).Value.ToString, 'else') then
        AGrammar.Next; // Pula o ";" apenas se o próximo for o ELSE

    if AGrammar.MatchKeyword('else') then
    begin
      AGrammar.Next; // Pula 'else'

      // --- BLOCO ELSE ---
      if not LCondition then
        Commands(AGrammar)
      else
        FindEnd(AGrammar, AGrammar.Match(pgkBegin));
    end;
  end;
end;

{ TPGFor }
constructor TPGFor.Create(const AOwner: TPGItem; const AName: string);
begin
  inherited;
  TPGLexicalRegistry.RegisterKeyword('to', pgkKeyword, 'to');
  TPGLexicalRegistry.RegisterKeyword('downto', pgkKeyword, 'downto');
  TPGLexicalRegistry.RegisterKeyword('do', pgkKeyword, 'do');
end;

procedure TPGFor.Execute(const AGrammar: TPGGrammar);
var
  LVar: TPGVariant;
  LStart, LStackLevel, LLimit: Int64;
  LCounter, LLoopLimit: Cardinal;
  LIsDownTo: Boolean;
  LStartPos: Integer;
begin
  LLoopLimit := TPGKernel.LoopLimit;
  AGrammar.Next; // Pula 'for'

  LVar := TPGVariant.GetOrCreate(AGrammar);
  if Assigned(LVar) then
  begin
    LVar.Execute(AGrammar); // Processa "i := 0"
    LStart := ValueToInt64(LVar.Value);

    LIsDownTo := AGrammar.MatchKeyword('downto');
    if AGrammar.MatchKeyword('to') or LIsDownTo then
    begin
      AGrammar.Next; // Pula 'to'/'downto'
      Expression(AGrammar);
      LLimit := ValueToInt64(AGrammar.Stack.Pop);

      if AGrammar.ConsumeKeyword('do') then
      begin
        if AGrammar.HasError then Exit;
        LStackLevel := AGrammar.NestingLevel;
        LStartPos := AGrammar.TokenList.Position;
        LCounter := 0;

        while (not AGrammar.HasError) and (LCounter < LLoopLimit) and
              (((not LIsDownTo) and (LStart <= LLimit)) or
               (LIsDownTo and (LStart >= LLimit))) do
        begin
          AGrammar.SetNestingLevel(LStackLevel);
          AGrammar.TokenList.Position := LStartPos;
          Commands(AGrammar);
          if LIsDownTo then Dec(LStart) else Inc(LStart);
          Inc(LCounter);
          LVar.Value := LStart;
        end;

        AGrammar.SetNestingLevel(LStackLevel);
        AGrammar.TokenList.Position := LStartPos;
        FindEnd(AGrammar, AGrammar.Match(pgkBegin));

        if LCounter >= LLoopLimit then
          AGrammar.Error('Error_Interpreter_LoopLimit', [LLoopLimit]);
      end;
    end;
  end;
end;

{ TPGWhile }
constructor TPGWhile.Create(const AOwner: TPGItem; const AName: string);
begin
  inherited;
  TPGLexicalRegistry.RegisterKeyword('do', pgkKeyword, 'do');
end;

procedure TPGWhile.Execute(const AGrammar: TPGGrammar);
var
  LStartPos, LStackLevel: Integer;
  LLoopLimit: Cardinal;
  LCounter: Cardinal;
begin
  LLoopLimit := TPGKernel.LoopLimit;
  LCounter := 0;
  AGrammar.Next; // Pula 'while'

  LStackLevel := AGrammar.NestingLevel;
  LStartPos := AGrammar.TokenList.Position;

  while (not AGrammar.HasError) and (LCounter < LLoopLimit) do
  begin
    AGrammar.SetNestingLevel(LStackLevel);
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
constructor TPGRepeat.Create(const AOwner: TPGItem; const AName: string);
begin
  inherited;
  TPGLexicalRegistry.RegisterKeyword('until', pgkKeyword, 'until');
end;

procedure TPGRepeat.Execute(const AGrammar: TPGGrammar);
var
  LStartPos, LStackLevel: Integer;
  LLoopLimit: Cardinal;
  LCounter: Cardinal;
begin
  LLoopLimit := TPGKernel.LoopLimit;
  LCounter := 0;
  AGrammar.Next; // Pula 'repeat'

  LStackLevel := AGrammar.NestingLevel;
  LStartPos := AGrammar.TokenList.Position;

  repeat
    AGrammar.SetNestingLevel(LStackLevel);
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
var
  LName: string;
  LItem: TPGItem;
begin
  AGrammar.Next; // Pula nome
  if ReadParameters(AGrammar, 1, 1) = 1 then
  begin
    //carrega o parametro
    LName := ValueToString(AGrammar.Stack.Pop);
    LItem := TPGFolder.FindPath(LName, False, nil, nil);
    AGrammar.Stack.Push( Assigned( LItem ) );
  end;
end;

{ TPGUnDef }
procedure TPGUnDef.Execute(const AGrammar: TPGGrammar);
var
  LName: string;
  LItem: TPGItem;
begin
  AGrammar.Next; // Pula nome
  if ReadParameters(AGrammar, 1, 1) = 1 then
  begin
    LName := ValueToString(AGrammar.Stack.Pop);
    LItem := FindID(AGrammar.Local, LName);
    if Assigned(LItem) and not (pgfInternal in Self.Flags) then
    begin
      LItem.Free;
      AGrammar.Stack.Push(True);
    end else
      AGrammar.Stack.Push(False);
  end;
end;

{ TPGWrite }
procedure TPGWrite.ExecuteAction(const AText: string; const ANewLine: Boolean);
begin
  TPGKernel.Console(AText, ANewLine, TPGKernel.ConsoleMessage);
end;

{ TPGWriteLN }
procedure TPGWriteLN.ExecuteAction(const AText: string);
begin
  inherited ExecuteAction(AText, True);
end;

initialization

end.
