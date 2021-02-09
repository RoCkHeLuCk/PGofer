unit PGofer.System.Functions;

interface

uses
    PGofer.Classes, PGofer.Lexico, PGofer.Sintatico, PGofer.Sintatico.Classes;

type

    {$M+}
    TPGFuncao = class(TPGItemCMD)
    private
        FTokenList: TTokenList;
        function getContent():String;
        procedure setContent(Content:String);
    public
        class var GlobList: TPGItem;
        constructor Create(Name: String);
        destructor Destroy(); override;
        procedure Execute(Gramatica: TGramatica); override;
        procedure Frame(Parent: TObject); override;
    published
        property Contents : String read getContent write setContent;
    end;
    {$TYPEINFO ON}

    TPGFunction = class(TPGItemCMD)
    private
        procedure DeclaraNivel1(Gramatica: TGramatica; Nivel: TPGItem);
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

implementation

uses
    PGofer.Sintatico.Controls, PGofer.System.Variants, PGofer.System.Functions.Frame;

{ TPGFunção }

constructor TPGFuncao.Create(Name: String);
begin
    inherited Create(Name);
end;

destructor TPGFuncao.Destroy();
begin
    FTokenList.Free;
    FTokenList := nil;
    inherited Destroy();
end;

procedure TPGFuncao.Execute(Gramatica: TGramatica);
var
    C: FixedInt;
    Gramatica2: TGramatica;
    VarTitulo: String;
    VarValor: Variant;
begin
    C := LerParamentros(Gramatica, 0, Self.Count);
    if not Gramatica.Erro then
    begin
        Gramatica2 := TGramatica.Create('$Função: ' + Self.Name,
            Gramatica.Local, False);
        for C := C - 1 downto 0 do
        begin
            with TPGConstante(Self[C]) do
            begin
                VarTitulo := Name;
                VarValor := Gramatica.Pilha.Desempilhar(Valor);
            end;
            Gramatica2.Local.Add(TPGVariavel.Create(VarTitulo, VarValor));
        end;
        Gramatica2.Local.Add(TPGVariavel.Create('Result', ''));
        Gramatica2.SetTokens(Self.FTokenList);

        Gramatica2.Start;
        Gramatica2.WaitFor;
        Gramatica.Erro := Gramatica2.Erro;

        if not Gramatica.Erro then
        begin
            VarValor := TPGVariavel(Gramatica2.Local.FindName('Result')).Valor;
            Gramatica.Pilha.Empilhar(VarValor);
        end;

        Gramatica2.Free;
    end;
end;

procedure TPGFuncao.Frame(Parent: TObject);
begin
    inherited Frame(Parent);
    TPGFrameFunction.Create(Self, Parent);
end;

function TPGFuncao.getContent: String;
var
    Automato: TAutomato;
begin
    Automato := TAutomato.Create();
    Result := Automato.TokenListToStr(FTokenList);
    Automato.Free;
end;

procedure TPGFuncao.setContent(Content: String);
var
    Automato: TAutomato;
begin
    FTokenList.Free;
    Automato := TAutomato.Create();
    FTokenList := Automato.TokenListCreate(Content);
    Automato.Free;
end;

{ TPGFunction }

procedure TPGFunction.DeclaraNivel1(Gramatica: TGramatica; Nivel: TPGItem);
var
    Função: TPGFuncao;
begin
    IdentificadorLocalizar(Gramatica);
    if (Gramatica.TokenList.Token.Classe = cmdID) then
    begin
        Função := TPGFuncao.Create(Gramatica.TokenList.Token.Lexema);
        Gramatica.TokenList.GetNextToken;
        if Gramatica.TokenList.Token.Classe = cmdLPar then
        begin
            Gramatica.TokenList.GetNextToken;
            if Gramatica.TokenList.Token.Classe = cmdID then
                TPGVar.ExecuteEx(Gramatica, Função);

            if (not Gramatica.Erro) then
            begin
                if Gramatica.TokenList.Token.Classe = cmdRPar then
                begin
                    Gramatica.TokenList.GetNextToken;
                    if Gramatica.TokenList.Token.Classe = cmdDotComa then
                    begin
                        Gramatica.TokenList.GetNextToken;
                        EncontrarFim(Gramatica, True, True);
                        if (not Gramatica.Erro) then
                        begin
                            Função.FTokenList :=
                                TTokenList
                                (NativeInt(Gramatica.Pilha.Desempilhar(0)));
                            Nivel.Add(Função);
                            exit;
                        end;
                    end
                    else
                        Gramatica.ErroAdd('";" Esperado.');
                end
                else
                    Gramatica.ErroAdd('")" Esperado.');
            end;
        end
        else
            Gramatica.ErroAdd('"(" Esperado.');
        Função.Free;
    end
    else
        Gramatica.ErroAdd('Identificador esperado.');
end;

procedure TPGFunction.Execute(Gramatica: TGramatica);
begin
    // declara global ou local
    Gramatica.TokenList.GetNextToken;
    if Gramatica.TokenList.Token.Classe = cmdRes_global then
    begin
        Gramatica.TokenList.GetNextToken;
        DeclaraNivel1(Gramatica, TPGFuncao.GlobList);
    end
    else
        DeclaraNivel1(Gramatica, Gramatica.Local);
end;

initialization
    with TGramatica.Global.FindName('Commands') do
    begin
        Add(TPGFunction.Create());
    end;
    TPGFuncao.GlobList := TGramatica.Global.Add('Functions');

finalization

end.
