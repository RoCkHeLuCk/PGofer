unit PGofer.Standard;

interface

uses
  System.SysUtils, System.Rtti,
  PGofer.Sintatico, PGofer.Runtime;

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

  { Controle de Fluxo (O Coração do Script) }
  TPGIf = class(TPGItemClass)
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGFor = class(TPGItemClass)
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGWhile = class(TPGItemClass)
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGRepeat = class(TPGItemClass)
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  { Gestão de Memória de Script }
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
  Vcl.Dialogs, System.Math,
  PGofer.Core, PGofer.Classes, PGofer.Lexico, PGofer.Sintatico.Controls,
  PGofer.Standard.Variants;

{ TPGCopy }
function TPGCopy.ExecuteAction(AValue: string; AStart, ACount: Integer): string;
begin
  Result := Copy(AValue, AStart, ACount);
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
procedure TPGIf.Execute(const AGrammar: TPGGrammar);
var
  LCondition: Boolean;
begin
  AGrammar.TokenList.Next; // Pula 'if'
  Expression(AGrammar);

  if not AGrammar.HasError then
  begin
    LCondition := AGrammar.Stack.Pop.AsBoolean;

    if AGrammar.Consume(tkThen) then
    begin
      if LCondition then
        Commands(AGrammar)
      else
        FindEnd(AGrammar, AGrammar.Match(tkBegin));

      // Trata o ELSE opcional
      if (not AGrammar.HasError) and AGrammar.Match(tkElse) then
      begin
        AGrammar.TokenList.Next;
        if not LCondition then
          Commands(AGrammar)
        else
          FindEnd(AGrammar, AGrammar.Match(tkBegin));
      end;
    end;
  end;
end;

{ TPGFor }
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
    LVar.Execute(AGrammar); // Executa a atribuição inicial (i := 0)
    LStart := ValueToInt64(LVar.Value);

    LIsDownTo := AGrammar.Match(tkDownTo);
    if AGrammar.Match(tkTo) or LIsDownTo then
    begin
      AGrammar.TokenList.Next; // Pula 'to' ou 'downto'
      Expression(AGrammar);
      LLimit := ValueToInt64(AGrammar.Stack.Pop);

      if AGrammar.Consume(tkDo) then
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
          LVar.Value := LStart; // Atualiza a variável de loop
        end;

        AGrammar.TokenList.Position := LStartPos;
        // FindEnd vai pular o comando que o For acabou de repetir
        FindEnd(AGrammar, AGrammar.Match(tkBegin));

        if LCounter >= LLoopLimit then
          AGrammar.Error('Error_Interpreter_LoopLimit', [LLoopLimit]);
      end;
    end;
  end;
end;

{ TPGWhile }
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

    if AGrammar.Stack.Pop.AsBoolean then
    begin
      if AGrammar.Consume(tkDo) then
        Commands(AGrammar)
      else Break;
    end
    else
    begin
      // Condição falsa, pula o corpo do while
      AGrammar.Consume(tkDo);
      FindEnd(AGrammar, AGrammar.Match(tkBegin));
      Break;
    end;
    Inc(LCounter);
  end;
end;

{ TPGRepeat }
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

    if AGrammar.Consume(tkUntil) then
    begin
      Expression(AGrammar);
      if AGrammar.Stack.Pop.AsBoolean then Break;
    end else Break;

    Inc(LCounter);
  until (AGrammar.HasError) or (LCounter >= LLoopLimit);
end;

{ TPGIsDef }
procedure TPGIsDef.Execute(const AGrammar: TPGGrammar);
var LName: string;
begin
  if ReadParameters(AGrammar, 1, 1) = 1 then
  begin
    LName := AGrammar.Stack.Pop.ToString;
    AGrammar.Stack.Push(Assigned(FindID(AGrammar.Local, LName)));
  end;
end;

{ TPGUnDef }
procedure TPGUnDef.Execute(const AGrammar: TPGGrammar);
var
  LName: string;
  LItem: TPGItem;
begin
  if ReadParameters(AGrammar, 1, 1) = 1 then
  begin
    LName := AGrammar.Stack.Pop.ToString;
    LItem := FindID(AGrammar.Local, LName);
    if Assigned(LItem) and (not LItem.SystemNode) then
    begin
      LItem.Free;
      AGrammar.Stack.Push(True);
    end
    else
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
