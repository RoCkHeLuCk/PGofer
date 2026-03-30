unit PGofer.Standard.Variants;

interface

uses
  System.SysUtils, System.Rtti, System.Generics.Collections,
  PGofer.Classes, PGofer.Sintatico, PGofer.Runtime;

type
  { Variável de Script moderna com suporte a Array }
  TPGVariant = class(TPGItemClass)
  strict private
    FValue: TValue;
    FIsConstant: Boolean;
    function GetValueAsArray: TArray<TValue>;
    procedure SetValueAsArray(const AArray: TArray<TValue>);
  public
    class var GlobList: TPGItem;

    constructor Create(AOwner: TPGItem; const AName: string; const AValue: TValue; AIsConstant: Boolean); reintroduce; overload;
    destructor Destroy; override;

    procedure Execute(const AGrammar: TPGGrammar); override;
    procedure Frame(AParent: TObject); override;

    class function GetOrCreate(const AGrammar: TPGGrammar): TPGVariant;

    property IsConstant: Boolean read FIsConstant;
    property Value: TValue read FValue write FValue;
  end;

  { Declarador de Variáveis e Constantes (Var, Const) }
  TPGVariantDeclare = class(TPGItemClass)
  strict private
    class procedure InternalDeclare(const AGrammar: TPGGrammar; ANivel: TPGItem; AIsConstant: Boolean);
  public
    constructor Create(AOwner: TPGItem; const AName: string = ''); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
    class procedure ExecuteEx(const AGrammar: TPGGrammar; ANivel: TPGItem);
  end;

implementation

uses
  PGofer.Core, PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.Standard.Variants.Frame;

{ TPGVariant }

constructor TPGVariant.Create(AOwner: TPGItem; const AName: string; const AValue: TValue; AIsConstant: Boolean);
begin
  inherited Create(AOwner, AName);
  Self.SystemNode := False;
  FIsConstant := AIsConstant;
  Self.ReadOnly := AIsConstant;
  FValue := AValue;
end;

destructor TPGVariant.Destroy;
begin
  FValue := TValue.Empty;
  inherited;
end;

function TPGVariant.GetValueAsArray: TArray<TValue>;
begin
  if FValue.IsType<TArray<TValue>> then
    Result := FValue.AsType<TArray<TValue>>
  else
    SetLength(Result, 0);
end;

procedure TPGVariant.SetValueAsArray(const AArray: TArray<TValue>);
begin
  FValue := TValue.From<TArray<TValue>>(AArray);
end;

class function TPGVariant.GetOrCreate(const AGrammar: TPGGrammar): TPGVariant;
var
  LID: TPGItem;
  LName: string;
begin
  LName := AGrammar.TokenList.Current.Value.ToString;
  LID := FindID(AGrammar.Local, LName);

  if LID = nil then
    Result := TPGVariant.Create(AGrammar.Local, LName, 0, False)
  else if LID is TPGVariant then
    Result := TPGVariant(LID)
  else
    Result := nil;
end;

procedure TPGVariant.Execute(const AGrammar: TPGGrammar);
var
  LIndex: Integer;
  LArray: TArray<TValue>;
  LNewVal: TValue;
begin
  AGrammar.TokenList.Next; // Pula o nome da variável

  // --- INDEXAÇÃO: Variavel[n] ---
  if AGrammar.Match(pgkLBrack) then
  begin
    AGrammar.TokenList.Next; // Pula '['
    Expression(AGrammar);
    // Usa ValueToInt64 para aceitar arr[1.0] sem erro
    LIndex := ValueToInt64(AGrammar.Stack.Pop);

    if not AGrammar.Consume(pgkRBrack) then Exit;

    LArray := GetValueAsArray;

    if AGrammar.Match(pgkAssign) then
    begin
      if FIsConstant then begin AGrammar.Error('Error_Interpreter_Const', []); Exit; end;
      AGrammar.TokenList.Next;
      Expression(AGrammar);
      LNewVal := AGrammar.Stack.Pop;

      if LIndex >= Length(LArray) then SetLength(LArray, LIndex + 1);
      LArray[LIndex] := LNewVal;
      SetValueAsArray(LArray);
    end
    else
    begin
      if (LIndex >= 0) and (LIndex < Length(LArray)) then
        AGrammar.Stack.Push(LArray[LIndex])
      else
        AGrammar.Stack.Push(TValue.Empty);
    end;
  end
  // --- ATRIBUIÇÃO OU LEITURA ---
  else if AGrammar.Match(pgkAssign) then
  begin
    if FIsConstant then AGrammar.Error('Error_Interpreter_Const', [])
    else begin
      AGrammar.TokenList.Next;
      Expression(AGrammar);
      FValue := AGrammar.Stack.Pop;
    end;
  end
  else
    AGrammar.Stack.Push(FValue);
end;

procedure TPGVariant.Frame(AParent: TObject);
begin
  TPGVariantsFrame.Create(Self, AParent);
end;

{ TPGVariantDeclare }

constructor TPGVariantDeclare.Create(AOwner: TPGItem; const AName: string);
begin
  inherited;
  // Registra a palavra reservada necessária para esta classe
  TPGLexicalRegistry.RegisterKeyword('global', pgkKeyword, 'global');
end;

class procedure TPGVariantDeclare.InternalDeclare(const AGrammar: TPGGrammar; ANivel: TPGItem; AIsConstant: Boolean);
var
  LTitle: string;
  LID: TPGItem;
  LValue: TValue;
begin
  LTitle := AGrammar.TokenList.Current.Value.ToString;
  LID := ANivel.FindName(LTitle);

  if (LID = nil) or (LID is TPGVariant) then
  begin
    AGrammar.TokenList.Next;

    if AGrammar.Match(pgkAssign) then
    begin
      AGrammar.TokenList.Next;
      Expression(AGrammar);
      if not AGrammar.HasError then LValue := AGrammar.Stack.Pop else Exit;
    end
    else
      LValue := 0;

    if (LID = nil) or (LID.Parent <> ANivel) then
    begin
      TPGVariant.Create(ANivel, LTitle, LValue, AIsConstant)
    end else begin
      TPGVariant(LID).Value := LValue;
      AGrammar.Msg('Warning_Interpreter_Redeclare', [LTitle]);
    end;

    if AGrammar.Match(pgkComma) then
    begin
      AGrammar.TokenList.Next;
      InternalDeclare(AGrammar, ANivel, AIsConstant);
    end;
  end
  else
    AGrammar.Error('Error_Interpreter_Id', []);
end;

procedure TPGVariantDeclare.Execute(const AGrammar: TPGGrammar);
var
  LIsConstant: Boolean;
begin
  // Identifica se é Var ou Const pelo nome da instância
  LIsConstant := SameText(Self.Name, 'Const');
  AGrammar.TokenList.Next; // Pula 'var' ou 'const'

  // Verifica se o modificador 'global' está presente
  if AGrammar.MatchKeyword('global') then
  begin
    AGrammar.TokenList.Next; // Pula 'global'
    InternalDeclare(AGrammar, TPGVariant.GlobList, LIsConstant);
  end
  else
    InternalDeclare(AGrammar, AGrammar.Local, LIsConstant);
end;

class procedure TPGVariantDeclare.ExecuteEx(const AGrammar: TPGGrammar; ANivel: TPGItem);
begin
  InternalDeclare(AGrammar, ANivel, False);
end;

initialization
  TPGVariantDeclare.Create(GlobalItemCommand, 'Const');
  TPGVariantDeclare.Create(GlobalItemCommand, 'Var');
  TPGVariant.GlobList := TPGFolder.Create(GlobalCollection, 'Variants');

end.
