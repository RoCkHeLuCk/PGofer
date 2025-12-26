unit PGofer.Types;

interface

uses
  System.SysUtils, System.Rtti;

type
  TPGAttribText = class(TCustomAttribute)
  private
    FText: string;
  public
    constructor Create(AText: string); overload;
    destructor Destroy( ); override;
    property Text: string read FText;
  end;

  TPGIcon = ( pgiItem, pgiMethod, pgiFolder, pgiVault, pgiSystem, pgiVariant, pgiFunction,
              pgiForm, pgiAutoFill, pgiHotKey, pgiLink, pgiTask );

  TPGAttribIcon = class(TCustomAttribute)
  private
    FIconIndex: TPGIcon;
  public
    constructor Create(AIconIndex: TPGIcon); overload;
    destructor Destroy( ); override;
    property IconIndex: TPGIcon read FIconIndex;
  end;

  function ConvertVatiantToValue( Valor: Variant; TypeKind: TTypeKind ): TValue;
  function ConvertValueToVatiant( Valor: TValue; TypeKind: TTypeKind ): Variant;

implementation

uses
  System.Variants;

{ TPGAttribText }

constructor TPGAttribText.Create(AText: string);
begin
  inherited Create( );
  FText := AText;
end;

destructor TPGAttribText.Destroy( );
begin
  FText := '';
  inherited Destroy( );
end;

{ PGAttribIcon }

constructor TPGAttribIcon.Create(AIconIndex: TPGIcon);
begin
  inherited Create( );
  FIconIndex := AIconIndex;
end;

destructor TPGAttribIcon.Destroy( );
begin
  FIconIndex := pgiItem;
  inherited Destroy( );
end;

{ ConvertV }

function ConvertVatiantToValue( Valor: Variant; TypeKind: TTypeKind ): TValue;
begin
  case TypeKind of
    tkUnknown:
      ;

    tkEnumeration:
      Result := Boolean( Valor );

    tkInteger:
      Result := Integer( Valor );

    tkInt64:
      Result := Int64( Valor );

    tkFloat:
      Result := Currency( Valor );

    tkChar, tkString, tkWChar, tkLString, tkWString, tkUString:
      Result := string( Valor );

    tkSet:
      ;
    tkClass:
      ;
    tkMethod:
      ;
    tkVariant:
      Result.FromVariant( Valor );
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

function ConvertValueToVatiant( Valor: TValue; TypeKind: TTypeKind ): Variant;
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
      Result := Valor.AsVariant;
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
