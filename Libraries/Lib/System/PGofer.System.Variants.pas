unit PGofer.System.Variants;

interface

uses
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes;

type
    {$M+}
    TPGConstante = class(TPGItemCMD)
    protected
        FValor: Variant;
    public
        class var GlobList: TPGItem;
        constructor Create(ItemDad: TPGItem; Name: String; Valor: Variant); overload;
        destructor Destroy(); override;
        procedure Execute(Gramatica: TGramatica); override;
        procedure Frame(Parent: TObject); override;
    published
        property Valor: Variant read FValor;
    end;
    {$TYPEINFO ON}

    TPGConstDec = class(TPGItemCMD)
    protected
        class procedure DeclaraNivel1(Gramatica: TGramatica; Nivel: TPGItem);
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

    TPGVariavel = class(TPGConstante)
    public
        class var GlobList: TPGItem;
        procedure Execute(Gramatica: TGramatica); override;
        property Valor: Variant read FValor write FValor;
    end;

    TPGVarDec = class(TPGConstDec)
    public
        class procedure ExecuteEx(Gramatica: TGramatica; Nivel: TPGItem);
    end;

implementation

uses
    PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.System.Variants.Frame;

{ TPGConstante }

constructor TPGConstante.Create(ItemDad: TPGItem; Name: String; Valor: Variant);
begin
    inherited Create(ItemDad, Name);
    FValor := Valor;
end;

destructor TPGConstante.Destroy;
begin
    FValor := '';
    inherited Destroy();
end;

procedure TPGConstante.Execute(Gramatica: TGramatica);
begin
    Gramatica.TokenList.GetNextToken;
    if (Gramatica.TokenList.Token.Classe <> cmdAttrib) then
        Gramatica.Pilha.Empilhar(Self.FValor)
    else
        Gramatica.ErroAdd('Constante é somente leitura.');
end;

procedure TPGConstante.Frame(Parent: TObject);
begin
    TPGFrameVariants.Create(Self, Parent);
end;

{ TPGConst }

class procedure TPGConstDec.DeclaraNivel1(Gramatica: TGramatica; Nivel: TPGItem);
var
    Titulo: String;
    ID: TPGItem;
    Valor: Variant;
begin
    ID := IdentificadorLocalizar(Gramatica);
    if (not Assigned(ID)) or (ID.ClassParent = TPGConstante) then
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

        TPGConstante.Create(Nivel, Titulo, Valor);

        if Gramatica.TokenList.Token.Classe = cmdComa then
        begin
            Gramatica.TokenList.GetNextToken;
            DeclaraNivel1(Gramatica, Nivel);
        end;

    end
    else
        Gramatica.ErroAdd('Identificador esperado.');
end;

procedure TPGConstDec.Execute(Gramatica: TGramatica);
begin
    Gramatica.TokenList.GetNextToken;
    // global
    if Gramatica.TokenList.Token.Classe = cmdRes_global then
    begin
        Gramatica.TokenList.GetNextToken;
        if Self is TPGVarDec then
           DeclaraNivel1(Gramatica, TPGVariavel.GlobList)
        else
           DeclaraNivel1(Gramatica, TPGConstante.GlobList);
    end
    else
        DeclaraNivel1(Gramatica, Gramatica.Local);
end;

{ TVariavel }

procedure TPGVariavel.Execute(Gramatica: TGramatica);
begin
    Gramatica.TokenList.GetNextToken;
    if AtribuicaoNivel1(Gramatica) then
        Self.FValor := Gramatica.Pilha.Desempilhar(Self.FValor)
    else
        Gramatica.Pilha.Empilhar(Self.FValor);
end;

{ TPGVarDeclare }

class procedure TPGVarDec.ExecuteEx(Gramatica: TGramatica; Nivel: TPGItem);
begin
    DeclaraNivel1(Gramatica, Nivel);
end;

initialization
    TPGConstDec.Create(GlobalItemCommand, 'Const');
    TPGVarDec.Create(GlobalItemCommand, 'Var');
    TPGConstante.GlobList := TPGFolder.Create(GlobalCollection, 'Constantes');
    TPGVariavel.GlobList := TPGFolder.Create(GlobalCollection, 'Variables');

finalization

end.
