unit PGofer.Types;

interface

uses
  System.Classes, System.SysUtils, System.Rtti;

const
  LOW_STRING = low( string );
  GUID_SIZE = SizeOf(TGUID);

type
  TPGIcon = ( pgiItem, pgiMethod, pgiFolder, pgiVault, pgiSystem, pgiVariant,
              pgiFunction, pgiForm, pgiAutoFill, pgiHotKey, pgiLink, pgiTask );

  TPGAttribText = class(TCustomAttribute)
  private
    FText: string;
    FTranslate: Boolean;
  public
    constructor Create(const AText: string; const ATranslate: Boolean = True); overload;
    destructor Destroy( ); override;
    property Text: string read FText;
  end;

  TPGAttribIcon = class(TCustomAttribute)
  private
    FIconIndex: TPGIcon;
  public
    constructor Create(const AIconIndex: TPGIcon); overload;
    destructor Destroy( ); override;
    property IconIndex: TPGIcon read FIconIndex;
  end;

  function ConvertVariantToValue(const AValor: Variant;const ATypeKind: TTypeKind ): TValue;
  function ConvertValueToVariant(const AValor: TValue;const ATypeKind: TTypeKind ): Variant;

  procedure RunInMainThread(AMethod: TThreadMethod); overload;
  procedure RunInMainThread(AProc: TProc); overload;

  function SplitEx(const AText, ASeparator: string ): TArray<string>;

var
  DirCurrent: string;
  IniConfigFile: string;

implementation

uses
  System.Variants, Winapi.Windows;

{ TPGAttribText }

constructor TPGAttribText.Create(const AText: string; const ATranslate: Boolean = True);
begin
  inherited Create( );
  FText := AText;
  FTranslate := ATranslate;
end;

destructor TPGAttribText.Destroy( );
begin
  FText := '';
  FTranslate := False;
  inherited Destroy( );
end;

{ PGAttribIcon }

constructor TPGAttribIcon.Create(const AIconIndex: TPGIcon);
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

function ConvertVariantToValue(const AValor: Variant;const ATypeKind: TTypeKind ): TValue;
begin
  case ATypeKind of
    tkUnknown:
      ;

    tkEnumeration:
      Result := Boolean( AValor );

    tkInteger:
      Result := Integer( AValor );

    tkInt64:
      Result := Int64( AValor );

    tkFloat:
      Result := Double( AValor );

    tkChar, tkString, tkWChar, tkLString, tkWString, tkUString:
      Result := string( AValor );

    tkSet:
      ;
    tkClass:
      ;
    tkMethod:
      ;
    tkVariant:
      Result.FromVariant( AValor );
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

function ConvertValueToVariant(const AValor: TValue; const ATypeKind: TTypeKind ): Variant;
begin
  case ATypeKind of
    tkUnknown:
      ;

    tkEnumeration:
      Result := AValor.AsBoolean;

    tkInteger:
      Result := AValor.AsInteger;

    tkInt64:
      Result := AValor.AsInt64;

    tkFloat:
      Result := AValor.AsCurrency;

    tkChar, tkString, tkWChar, tkLString, tkWString, tkUString:
      Result := AValor.AsString;

    tkSet:
      ;
    tkClass:
      ;
    tkMethod:
      ;
    tkVariant:
      Result := AValor.AsVariant;
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

procedure RunInMainThread(AMethod: TThreadMethod);
begin
  if GetCurrentThreadId = MainThreadID then
    AMethod()
  else
    TThread.Synchronize(nil, AMethod);
end;

procedure RunInMainThread(AProc: TProc);
begin
  if GetCurrentThreadId = MainThreadID then
    AProc()
  else
    TThread.Synchronize(nil, procedure
    begin
      AProc();
    end);
end;

function SplitEx(const AText, ASeparator: string ): TArray<string>;
var
  TxtBgn, TxtEnd, RstLength, TxtLength, SptLength: FixedInt;
begin
  RstLength := 0;
  SetLength( Result, RstLength );
  TxtLength := AText.Length + 1;
  SptLength := ASeparator.Length;
  TxtBgn := LOW_STRING;
  while TxtBgn <= TxtLength do
  begin
    TxtEnd := Pos( ASeparator, AText, TxtBgn );
    if TxtEnd = 0 then
      TxtEnd := TxtLength + 1;

    Inc( RstLength );
    SetLength( Result, RstLength );
    Result[ RstLength - 1 ] := Copy( AText, TxtBgn, TxtEnd - TxtBgn );
    TxtBgn := TxtEnd + SptLength;
  end;
end;

initialization

  DirCurrent := ExtractFilePath( ParamStr( 0 ) );
  IniConfigFile := DirCurrent + 'Config.ini';

finalization

  DirCurrent := '';
  IniConfigFile := '';


end.
