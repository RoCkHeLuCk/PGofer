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

  { Declarador de Variáveis e Constantes }
  TPGVariantDeclare = class(TPGItemClass)
  strict private
    class procedure DeclareLevel1(const AGrammar: TPGGrammar; ANivel: TPGItem; AIsConstant: Boolean);
  public
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
    Result := nil; // Colisão de nomes com outro tipo de objeto
end;

procedure TPGVariant.Execute(const AGrammar: TPGGrammar);
var
  LIndex: Integer;
  LArray: TArray<TValue>;
  LNewVal: TValue;
begin
  AGrammar.TokenList.Next; // Avança o nome da variável

  // --- SUPORTE A INDEXAÇÃO: Variavel[n] ---
  if AGrammar.Match(tkLBrack) then
  begin
    AGrammar.TokenList.Next; // Pula '['
    Expression(AGrammar);
    LIndex := AGrammar.Stack.Pop.AsInteger;
    AGrammar.Consume(tkRBrack);

    LArray := GetValueAsArray;

    // Se for ATRIBUIÇÃO ao índice: Variavel[0] := 10
    if AGrammar.Match(tkAssign) then
    begin
      if FIsConstant then
      begin
        AGrammar.Error('Error_Interpreter_Const', []);
        Exit;
      end;

      AGrammar.TokenList.Next; // Pula ':='
      Expression(AGrammar);
      LNewVal := AGrammar.Stack.Pop;

      // Garante que o array tenha tamanho suficiente
      if LIndex >= Length(LArray) then
        SetLength(LArray, LIndex + 1);

      LArray[LIndex] := LNewVal;
      SetValueAsArray(LArray);
    end
    else
    begin
      // Se for LEITURA do índice: x := Variavel[0]
      if (LIndex >= 0) and (LIndex < Length(LArray)) then
        AGrammar.Stack.Push(LArray[LIndex])
      else
        AGrammar.Stack.Push(TValue.Empty);
    end;
  end
  // --- ATRIBUIÇÃO NORMAL OU LEITURA ---
  else if AGrammar.Match(tkAssign) then
  begin
    if FIsConstant then
      AGrammar.Error('Error_Interpreter_Const', [])
    else
    begin
      AGrammar.TokenList.Next; // Pula ':='
      Expression(AGrammar);
      FValue := AGrammar.Stack.Pop;
    end;
  end
  else
    // Apenas leitura da variável: empilha o valor total
    AGrammar.Stack.Push(FValue);
end;

procedure TPGVariant.Frame(AParent: TObject);
begin
  TPGVariantsFrame.Create(Self, AParent);
end;

{ TPGVariantDeclare }

class procedure TPGVariantDeclare.DeclareLevel1(const AGrammar: TPGGrammar; ANivel: TPGItem; AIsConstant: Boolean);
var
  LTitle: string;
  LID: TPGItem;
  LValue: TValue;
begin
  LTitle := AGrammar.TokenList.Current.Value.ToString;
  LID := FindID(ANivel, LTitle);

  if (LID = nil) or (LID is TPGVariant) then
  begin
    AGrammar.TokenList.Next;

    // Inicialização opcional: var x := 10;
    if AGrammar.Match(tkAssign) then
    begin
      AGrammar.TokenList.Next;
      Expression(AGrammar);
      if not AGrammar.HasError then
        LValue := AGrammar.Stack.Pop
      else
        Exit;
    end
    else
      LValue := 0; // Default

    if (LID = nil) or (LID.Parent <> ANivel) then
      TPGVariant.Create(ANivel, LTitle, LValue, AIsConstant)
    else
    begin
      // Re-declaração no mesmo nível: apenas atualiza
      TPGVariant(LID).Value := LValue;
      AGrammar.Msg('Warning_Interpreter_Redeclare', [LTitle]);
    end;

    // Suporte a declaração múltipla: var a, b, c;
    if AGrammar.Match(tkComma) then
    begin
      AGrammar.TokenList.Next;
      DeclareLevel1(AGrammar, ANivel, AIsConstant);
    end;
  end
  else
    AGrammar.Error('Error_Interpreter_Id', []);
end;

procedure TPGVariantDeclare.Execute(const AGrammar: TPGGrammar);
var
  LIsConstant: Boolean;
begin
  LIsConstant := SameText(AGrammar.TokenList.Current.Value.ToString, 'Const');
  AGrammar.TokenList.Next;

  if AGrammar.Match(tkGlobal) then
  begin
    AGrammar.TokenList.Next;
    DeclareLevel1(AGrammar, TPGVariant.GlobList, LIsConstant);
  end
  else
    DeclareLevel1(AGrammar, AGrammar.Local, LIsConstant);
end;

class procedure TPGVariantDeclare.ExecuteEx(const AGrammar: TPGGrammar; ANivel: TPGItem);
begin
  DeclareLevel1(AGrammar, ANivel, False);
end;

initialization
  TPGVariantDeclare.Create(GlobalItemCommand, 'Const');
  TPGVariantDeclare.Create(GlobalItemCommand, 'Var');
  TPGVariant.GlobList := TPGFolder.Create(GlobalCollection, 'Variants');

end.
