unit PGofer.Types;

interface

uses
    System.SysUtils, System.Rtti, System.TypInfo,
    PGofer.Sintatico, PGofer.Sintatico.Classes;

function ConvertVatiantToValue(Valor: Variant; TypeKind: TTypeKind): TValue;
function ConvertValueToVatiant(Valor: TValue; TypeKind: TTypeKind): Variant;
procedure Construir(Item: TPGItemCMD);
procedure Executar(Gramatica: TGramatica; Item: TPGItemCMD);

implementation

uses
    PGofer.Sintatico.Controls;

function ConvertVatiantToValue(Valor: Variant; TypeKind: TTypeKind): TValue;
begin
    case TypeKind of
        tkUnknown:
            ;

        tkEnumeration:
            Result := Boolean(Valor);

        tkInteger:
            Result := Integer(Valor);

        tkInt64:
            Result := Int64(Valor);

        tkFloat:
            Result := Currency(Valor);

        tkChar, tkString, tkWChar, tkLString, tkWString, tkUString:
            Result := String(Valor);

        tkSet:
            ;
        tkClass:
            ;
        tkMethod:
            ;
        tkVariant:
            ;
        tkArray:
            ;
        tkRecord:
            ;
        tkInterface:
            ;
        tkDynArray:
            ;
        tkClassRef:
            ;
        tkPointer:
            ;
        tkProcedure:
            ;
    end;
end;

function ConvertValueToVatiant(Valor: TValue; TypeKind: TTypeKind): Variant;
begin
    case TypeKind of
        tkUnknown:
            ;

        tkEnumeration:
            Result := Valor.AsBoolean;

        tkInteger:
            Result := Valor.AsInteger;

        tkInt64:
            Result := Valor.AsInt64;

        tkFloat:
            Result := Valor.AsCurrency;

        tkChar, tkString, tkWChar, tkLString, tkWString, tkUString:
            Result := Valor.AsString;

        tkSet:
            ;
        tkClass:
            ;
        tkMethod:
            ;
        tkVariant:
            ;
        tkArray:
            ;
        tkRecord:
            ;
        tkInterface:
            ;
        tkDynArray:
            ;
        tkClassRef:
            ;
        tkPointer:
            ;
        tkProcedure:
            ;
    end;
end;

{ TPGRtti }

procedure Construir(Item: TPGItemCMD);
var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    RttiProperty: TRttiProperty;
    RttiMethods: TRttiMethod;
begin
    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(Item.ClassType);

    for RttiProperty in RttiType.GetProperties do
    begin
        if (RttiProperty.Visibility in [mvPublished]) then
            Item.Add(TPGItemCMD.Create(RttiProperty.Name));
    end;

    for RttiMethods in RttiType.GetMethods do
    begin
        if RttiMethods.Visibility in [mvPublished] then
            Item.Add(TPGItemCMD.Create(RttiMethods.Name));
    end;

    RttiContext.Free;
end;

procedure Executar(Gramatica: TGramatica; Item: TPGItemCMD);
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

end.
