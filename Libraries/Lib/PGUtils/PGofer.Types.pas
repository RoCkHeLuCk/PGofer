unit PGofer.Types;

interface

uses
    System.SysUtils, System.Rtti, System.TypInfo;

function ConvertVatiantToValue(Valor: Variant; TypeKind: TTypeKind): TValue;
function ConvertValueToVatiant(Valor: TValue; TypeKind: TTypeKind): Variant;

implementation

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

end.
