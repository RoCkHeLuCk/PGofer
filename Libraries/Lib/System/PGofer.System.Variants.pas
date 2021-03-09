unit PGofer.System.Variants;

interface

uses
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes;

type
{$M+}
    TPGConstant = class(TPGItemCMD)
    protected
        FValor: Variant;
    public
        class var GlobList: TPGItem;
        constructor Create(ItemDad: TPGItem; Name: String;
          Valor: Variant); overload;
        destructor Destroy(); override;
        procedure Execute(Gramatica: TGramatica); override;
        procedure Frame(Parent: TObject); override;
    published
        property Valor: Variant read FValor;
    end;
{$TYPEINFO ON}

    TPGConstantDeclare = class(TPGItemCMD)
    protected
        class procedure DeclaraNivel1(Gramatica: TGramatica; Nivel: TPGItem);
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

    TPGVariable = class(TPGConstant)
    public
        class var GlobList: TPGItem;
        procedure Execute(Gramatica: TGramatica); override;
        property Valor: Variant read FValor write FValor;
    end;

    TPGVariableDeclare = class(TPGConstantDeclare)
    public
        class procedure ExecuteEx(Gramatica: TGramatica; Nivel: TPGItem);
    end;

implementation

uses
    PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.System.Variants.Frame;

{ TPGConstante }

constructor TPGConstant.Create(ItemDad: TPGItem; Name: String; Valor: Variant);
begin
    inherited Create(ItemDad, Name);
    FValor := Valor;
end;

destructor TPGConstant.Destroy;
begin
    FValor := '';
    inherited Destroy();
end;

procedure TPGConstant.Execute(Gramatica: TGramatica);
begin
    Gramatica.TokenList.GetNextToken;
    if (Gramatica.TokenList.Token.Classe <> cmdAttrib) then
        Gramatica.Pilha.Empilhar(Self.FValor)
    else
        Gramatica.ErroAdd('Constante é somente leitura.');
end;

procedure TPGConstant.Frame(Parent: TObject);
begin
    TPGFrameVariants.Create(Self, Parent);
end;

{ TPGConst }

class procedure TPGConstantDeclare.DeclaraNivel1(Gramatica: TGramatica;
  Nivel: TPGItem);
var
    Titulo: String;
    ID: TPGItem;
    Valor: Variant;
begin
    ID := IdentificadorLocalizar(Gramatica);
    if (not Assigned(ID)) or (ID.ClassParent = TPGConstant) then
    begin
        Titulo := Gramatica.TokenList.Token.Lexema;
        Gramatica.TokenList.GetNextToken;
        if Gramatica.TokenList.Token.Classe = cmdAttrib then
        begin
            Gramatica.TokenList.GetNextToken;
            Expressao(Gramatica);
            Valor := Gramatica.Pilha.Desempilhar('');
        end
        else
            Valor := '';

        TPGConstant.Create(Nivel, Titulo, Valor);

        if Gramatica.TokenList.Token.Classe = cmdComa then
        begin
            Gramatica.TokenList.GetNextToken;
            DeclaraNivel1(Gramatica, Nivel);
        end;

    end
    else
        Gramatica.ErroAdd('Identificador esperado.');
end;

procedure TPGConstantDeclare.Execute(Gramatica: TGramatica);
begin
    Gramatica.TokenList.GetNextToken;
    // global
    if Gramatica.TokenList.Token.Classe = cmdRes_global then
    begin
        Gramatica.TokenList.GetNextToken;
        if Self is TPGVariableDeclare then
            DeclaraNivel1(Gramatica, TPGVariable.GlobList)
        else
            DeclaraNivel1(Gramatica, TPGConstant.GlobList);
    end
    else
        DeclaraNivel1(Gramatica, Gramatica.Local);
end;

{ TVariavel }

procedure TPGVariable.Execute(Gramatica: TGramatica);
begin
    Gramatica.TokenList.GetNextToken;
    if AtribuicaoNivel1(Gramatica) then
        Self.FValor := Gramatica.Pilha.Desempilhar(Self.FValor)
    else
        Gramatica.Pilha.Empilhar(Self.FValor);
end;

{ TPGVarDeclare }

class procedure TPGVariableDeclare.ExecuteEx(Gramatica: TGramatica; Nivel: TPGItem);
begin
    DeclaraNivel1(Gramatica, Nivel);
end;

initialization
    TPGConstantDeclare.Create(GlobalItemCommand, 'Const');
    TPGVariableDeclare.Create(GlobalItemCommand, 'Var');
    TPGConstant.GlobList := TPGFolder.Create(GlobalCollection, 'Constantes');
    TPGVariable.GlobList := TPGFolder.Create(GlobalCollection, 'Variables');

finalization

end.
