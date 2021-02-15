unit PGofer.Sintatico.Classes;

interface

uses
    System.Generics.Collections, System.RTTI,
    PGofer.Classes, PGofer.Sintatico;

type
    TPGAttributeType = (attText, attDocFile, attDocComent, attParam);
    TPGRttiAttribute = class (TCustomAttribute)
    private
        FType: TPGAttributeType;
        FValue: String;
    public
        constructor Create(AttType: TPGAttributeType; Value: String); overload;
        destructor Destroy(); override;
        property AttType : TPGAttributeType read FType;
        property Value : String read FValue;
    end;

    TPGItemCMD = class(TPGItem)
    private
        FAttributeList : TObjectList<TPGRttiAttribute>;
        procedure RttiCreate();
        procedure RttiExecute(Gramatica: TGramatica; Item: TPGItemCMD);
    public
        constructor Create(); overload;
        constructor Create(Name: String); overload;
        constructor CreateOutAttrib(Name: String); overload;
        destructor Destroy(); override;
        procedure Execute(Gramatica: TGramatica); virtual;
        procedure AttributeAdd(AttType: TPGAttributeType; Value: String);
        property AttributeList: TObjectList<TPGRttiAttribute> read FAttributeList;
    end;

implementation

uses
    System.TypInfo,
    PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.Types;

{ TPGAttribute }

constructor TPGRttiAttribute.Create(AttType: TPGAttributeType; Value: String);
begin
    FType := AttType;
    FValue := Value;
end;

destructor TPGRttiAttribute.Destroy();
begin
    FType := attText;
    FValue := '';
    inherited Destroy();
end;

{ TPGItemCMD }

constructor TPGItemCMD.Create();
begin
    inherited Create(copy(Self.ClassName, 4, Length(Self.ClassName)));
    FAttributeList := TObjectList<TPGRttiAttribute>.Create(True);
    self.RttiCreate();
end;

constructor TPGItemCMD.Create(Name: String);
begin
    inherited Create(Name);
    FAttributeList := TObjectList<TPGRttiAttribute>.Create(True);
    self.RttiCreate();
end;

constructor TPGItemCMD.CreateOutAttrib(Name: String);
begin
    inherited Create(Name);
    FAttributeList := TObjectList<TPGRttiAttribute>.Create(True);
end;

destructor TPGItemCMD.Destroy;
begin
    FAttributeList.Free;
    inherited Destroy();
end;

procedure TPGItemCMD.AttributeAdd(AttType: TPGAttributeType; Value: String);
begin
    FAttributeList.Add( TPGRttiAttribute.Create(AttType,Value) );
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

procedure TPGItemCMD.RttiCreate();
    procedure AttributesAdd(
         AtributeList: TArray<TCustomAttribute>;
         ItemAtt: TPGItemCMD);
    var
        RttiAttribute: TCustomAttribute;
    begin
        if ItemAtt.FAttributeList.Count = 0 then
        begin
            for RttiAttribute in AtributeList do
            begin
                if RttiAttribute is TPGRttiAttribute then
                begin
                   with TPGRttiAttribute(RttiAttribute) do
                   begin
                       ItemAtt.AttributeAdd(FType,FValue);
                   end;
                end;
            end;
        end;
    end;

    procedure CreateItems(RttiMemberList: TArray<TRttiMember>);
    var
        ItemAux : TPGItemCMD;
        RttiMember : TRttiMember;
    begin
        for RttiMember in RttiMemberList do
        begin
            if (RttiMember.Visibility in [mvPublished]) then
            begin
                ItemAux := TPGItemCMD.CreateOutAttrib(RttiMember.Name);
                Self.Add(ItemAux);
                AttributesAdd(RttiMember.GetAttributes,ItemAux);
            end;
        end;
    end;

var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
begin
    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(Self.ClassType);
    AttributesAdd(RttiType.GetAttributes,Self);
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
