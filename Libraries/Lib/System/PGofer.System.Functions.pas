unit PGofer.System.Functions;

interface

uses
    PGofer.Classes, PGofer.Lexico, PGofer.Sintatico,
    PGofer.Sintatico.Classes;

type

{$M+}
    TPGFunction = class(TPGItemCMD)
    private
        FTokenList: TTokenList;
        function getContent(): String;
        procedure setContent(Content: String);
    public
        class var GlobList: TPGItem;
        destructor Destroy(); override;
        procedure Execute(Gramatica: TGramatica); override;
        procedure Frame(Parent: TObject); override;
    published
        property Contents: String read getContent write setContent;
    end;
{$TYPEINFO ON}

    TPGFunctionDeclare = class(TPGItemCMD)
    private
        procedure DeclaraNivel1(Gramatica: TGramatica; Nivel: TPGItem);
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

implementation

uses
    PGofer.Sintatico.Controls, PGofer.System.Variants,
    PGofer.System.Functions.Frame;

{ TPGFunção }

destructor TPGFunction.Destroy();
begin
    FTokenList.Free;
    FTokenList := nil;
    inherited Destroy();
end;

procedure TPGFunction.Execute(Gramatica: TGramatica);
var
    C: FixedInt;
    Gramatica2: TGramatica;
    VarTitulo: String;
    VarValor: Variant;
begin
    C := LerParamentros(Gramatica, 0, Self.Count - 1);
    if not Gramatica.Erro then
    begin
        Gramatica2 := TGramatica.Create('$Função: ' + Self.Name,
          Gramatica.Local, False);

        while C > 0 do
        begin
            VarTitulo := Self[C].Name;
            VarValor := Gramatica.Pilha.Desempilhar
              (TPGConstant(Self[C]).Valor);
            TPGVariable.Create(Gramatica2.Local, VarTitulo, VarValor);
            Dec(C);
        end;
        TPGVariable.Create(Gramatica2.Local, 'Result', '');
        Gramatica2.SetTokens(Self.FTokenList);

        Gramatica2.Start;
        Gramatica2.WaitFor;
        Gramatica.Erro := Gramatica2.Erro;

        if not Gramatica.Erro then
        begin
            VarValor := TPGVariable(Gramatica2.Local.FindName('Result')).Valor;
            Gramatica.Pilha.Empilhar(VarValor);
        end;

        Gramatica2.Free;
    end;
end;

procedure TPGFunction.Frame(Parent: TObject);
begin
    TPGFrameFunction.Create(Self, Parent);
end;

function TPGFunction.getContent: String;
var
    Automato: TAutomato;
begin
    Automato := TAutomato.Create();
    Result := Automato.TokenListToStr(FTokenList);
    Automato.Free;
end;

procedure TPGFunction.setContent(Content: String);
var
    Automato: TAutomato;
begin
    FTokenList.Free;
    Automato := TAutomato.Create();
    FTokenList := Automato.TokenListCreate(Content);
    Automato.Free;
end;

{ TPGFunction }

procedure TPGFunctionDeclare.DeclaraNivel1(Gramatica: TGramatica; Nivel: TPGItem);
var
    Função: TPGFunction;
begin
    IdentificadorLocalizar(Gramatica);
    if (Gramatica.TokenList.Token.Classe = cmdID) then
    begin
        Função := TPGFunction.Create(Nivel,
          String(Gramatica.TokenList.Token.Lexema));
        Gramatica.TokenList.GetNextToken;
        if Gramatica.TokenList.Token.Classe = cmdLPar then
        begin
            Gramatica.TokenList.GetNextToken;
            if Gramatica.TokenList.Token.Classe = cmdID then
                TPGVariableDeclare.ExecuteEx(Gramatica, Função);

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

procedure TPGFunctionDeclare.Execute(Gramatica: TGramatica);
begin
    // declara global ou local
    Gramatica.TokenList.GetNextToken;
    if Gramatica.TokenList.Token.Classe = cmdRes_global then
    begin
        Gramatica.TokenList.GetNextToken;
        DeclaraNivel1(Gramatica, TPGFunction.GlobList);
    end
    else
        DeclaraNivel1(Gramatica, Gramatica.Local);
end;

initialization
    TPGFunctionDeclare.Create(GlobalItemCommand);
    TPGFunction.GlobList := TPGFolder.Create(GlobalCollection, 'Functions');

finalization

end.
