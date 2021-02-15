unit PGofer.Sintatico.Classes;

interface

uses
    System.RTTI,
    PGofer.Classes, PGofer.Sintatico;

type
    TPGItemCMD = class(TPGItem)
    private
        procedure RttiCreate(Item: TPGItemCMD);
        procedure RttiExecute(Gramatica: TGramatica; Item: TPGItemCMD);
    public
        constructor Create(); overload;
        constructor Create(Name: String); overload;
        destructor Destroy(); override;
        procedure Execute(Gramatica: TGramatica); virtual;

    end;

implementation

uses
    System.TypInfo,
    PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.Types;

{ TPGItemCMD }

constructor TPGItemCMD.Create();
begin
    inherited Create(copy(Self.ClassName, 4, Length(Self.ClassName)));
    self.RttiCreate(Self);
end;

constructor TPGItemCMD.Create(Name: String);
begin
    inherited Create(Name);
    self.RttiCreate(Self);
end;

destructor TPGItemCMD.Destroy;
begin
    inherited Destroy();
end;

procedure TPGItemCMD.Execute(Gramatica: TGramatica);
begin
    Gramatica.TokenList.GetNextToken;
    if Gramatica.TokenList.Token.Classe = cmdDot then
    begin
        Gramatica.TokenList.GetNextToken;
        Self.RttiExecute(Gramatica, Self);
    end;
end;

procedure TPGItemCMD.RttiCreate(Item: TPGItemCMD);
    procedure CreateItems(RttiMemberList: TArray<TRttiMember>);
    var
        ItemAux : TPGItemCMD;
        RttiMember : TRttiMember;
    begin
        for RttiMember in RttiMemberList do
        begin
            if (RttiMember.Visibility in [mvPublished]) then
            begin
                ItemAux := TPGItemCMD.Create(RttiMember.Name);
                Item.Add(ItemAux);
            end;
        end;
    end;

var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
begin
    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(Item.ClassType);
    CreateItems(TArray<TRttiMember>(RttiType.GetProperties));
    CreateItems(TArray<TRttiMember>(RttiType.GetMethods));
    RttiContext.Free;
end;

procedure TPGItemCMD.RTTIExecute(Gramatica: TGramatica; Item: TPGItemCMD);
var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    RttiProperty: TRttiProperty;
    RttiMethods: TRttiMethod;
    Parametros: TArray<TRttiParameter>;
    Tamanho: SmallInt;
    Valor: TValue;
    Valores: array of TValue;
    Aux: Variant;
    ItemAux: TPGItemCMD;
begin
    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(Item.ClassType);

    RttiProperty := RttiType.GetProperty(Gramatica.TokenList.Token.Lexema);
    if Assigned(RttiProperty) and (RttiProperty.Visibility in [mvPublished])
    then
    begin
        if RttiProperty.IsReadable then
            Valor := RttiProperty.GetValue(Item);

        Aux := ConvertValueToVatiant(Valor, RttiProperty.PropertyType.TypeKind);
        Aux := Atribuicao(Gramatica, Aux);
        if not Gramatica.Erro then
        begin
            Valor := ConvertVatiantToValue(Aux,
                RttiProperty.PropertyType.TypeKind);

            if RttiProperty.IsWritable then
                RttiProperty.SetValue(Item, Valor);
        end;
    end
    else
    begin
        RttiMethods := RttiType.GetMethod(Gramatica.TokenList.Token.Lexema);
        if Assigned(RttiMethods) and (RttiMethods.Visibility in [mvPublished])
        then
        begin
            Parametros := RttiMethods.GetParameters;
            Tamanho := Length(Parametros);
            SetLength(Valores, Tamanho);
            LerParamentros(Gramatica, Tamanho, Tamanho);
            if not Gramatica.Erro then
            begin
                for Tamanho := Tamanho - 1 downto 0 do
                begin
                    Aux := Gramatica.Pilha.Desempilhar('');
                    Valores[Tamanho] := ConvertVatiantToValue(Aux,
                        Parametros[Tamanho].ParamType.TypeKind);
                end;

                if Assigned(RttiMethods.ReturnType) then
                begin
                    Valor := RttiMethods.Invoke(Item, Valores);
                    Aux := ConvertValueToVatiant(Valor,
                        RttiMethods.ReturnType.TypeKind);
                    Gramatica.Pilha.Empilhar(Aux);
                end
                else
                    RttiMethods.Invoke(Item, Valores);
            end;
        end
        else
        begin
            ItemAux :=
                TPGItemCMD(Item.FindName(Gramatica.TokenList.Token.Lexema));
            if Assigned(ItemAux) then
            begin
                ItemAux.Execute(Gramatica);
            end
            else
                Gramatica.ErroAdd('Identificador não reconhecido: ' +
                    Gramatica.TokenList.Token.Lexema);
        end;
    end;

    Valor.Empty;
    SetLength(Valores, 0);
    SetLength(Parametros, 0);
    RttiContext.Free;
end;

initialization

finalization

end.
