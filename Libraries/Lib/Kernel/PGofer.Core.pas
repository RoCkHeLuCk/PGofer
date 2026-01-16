unit PGofer.Core;

interface

uses
  System.Classes, System.Generics.Collections, System.Rtti;

const
  LOW_STRING = low( string );
  GUID_SIZE = SizeOf(TGUID);

type
  TPGKernel = class
  private
    class var FVars: TDictionary<string, TValue>;
  public
    class constructor Create();
    class destructor Destroy();
    class procedure SetVar(const AName: string; const AValue: TValue);

    class function GetVar(const AName: string; const ADefault: TValue): TValue; overload;
    class function GetVar(const AName: string; ADefault: Boolean): Boolean; overload;
    class function GetVar(const AName: string; ADefault: Integer): Integer; overload;
    class function GetVar(const AName: string; ADefault: Cardinal): Cardinal; overload;
    class function GetVar(const AName: string; ADefault: Int64): Int64; overload;
    class function GetVar(const AName: string; ADefault: Double): Double; overload;
    class function GetVar(const AName: string; ADefault: Currency): Currency; overload;
    class function GetVar(const AName: string; const ADefault: string): string; overload;

    class function Exists(const AName: string): Boolean;
  end;

  TPGAttribText = class(TCustomAttribute)
  private
    FText: string;
    FTranslate: Boolean;
  public
    constructor Create(const AText: string; const ATranslate: Boolean = True); overload;
    destructor Destroy( ); override;
    property Text: string read FText;
  end;

  TPGIcon = ( pgiItem, pgiMethod, pgiFolder, pgiVault, pgiSystem, pgiVariant,
              pgiFunction, pgiForm, pgiAutoFill, pgiHotKey, pgiLink, pgiTask );

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

  procedure RunInMainThread(AMethod: TThreadMethod; Sync:Boolean = True); overload;
  procedure RunInMainThread(AProc: TThreadProcedure; Sync:Boolean = True); overload;

implementation

uses
  System.SysUtils, Winapi.Windows;

{ TPGKernel }

class constructor TPGKernel.Create();
var
  LPath: string;
begin
  FVars := TDictionary<string, TValue>.Create;

  LPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  SetVar('_PathCurrent', LPath);
  SetVar('_FileKeyStore', LPath + 'KeyStore.pgk');
  SetVar('_FileIniConfig', LPath + 'Config.ini');
  SetVar('_FileAutoComplete', LPath + 'AutoComplete.ini');
  SetVar('_FileLog', LPath + 'System.log');


  {$IFDEF DEBUG}
    SetVar('_FileLanguage', LPath + '..\..\..\..\Documents\Languages\Language.json');
    SetVar('_PathIcons', LPath + '..\..\..\..\Documents\Imagens\Icons\');
  {$ELSE}
    SetVar('_FileLanguage', LPath + 'Language.json');
    SetVar('_PathIcons', LPath + 'Icons\');
  {$ENDIF}

  SetVar('ReportMemoryLeaks', False);
  SetVar('LoopLimit', Int64(1000000));
  SetVar('FileListMax', Cardinal(100));
  SetVar('ReplyFormat', '');
  SetVar('ReplyPrefix', False);
  SetVar('ConsoleMessage', True);
  SetVar('LogMaxSize', Int64(10000));
  SetVar('CanOff', True);
  SetVar('CanClose', True);
end;

class destructor TPGKernel.Destroy();
begin
  FVars.Free;
end;

class procedure TPGKernel.SetVar(const AName: string; const AValue: TValue);
begin
  if (not AName.StartsWith('_')) then
  begin
    FVars.AddOrSetValue(AName, AValue);
  end else begin
    if (not FVars.ContainsKey(AName)) then
    begin
      FVars.Add(AName, AValue);
    end else begin
      {$IFDEF DEBUG}
        raise Exception.Create('Error Kernel: Variable "'+AName+'" mind read only!');
      {$ENDIF}
    end;
  end;
end;

class function TPGKernel.GetVar(const AName: string; const ADefault: TValue): TValue;
begin
  if not FVars.TryGetValue(AName, Result) then
  begin
    Result := ADefault;
    {$IFDEF DEBUG}
      raise Exception.Create('Error Kernel: Variable "'+AName+'" not found!');
    {$ENDIF}
  end;
end;

class function TPGKernel.GetVar(const AName: string; ADefault: Boolean): Boolean;
begin
  Result := GetVar(AName, TValue.From<Boolean>(ADefault)).AsBoolean;
end;

class function TPGKernel.GetVar(const AName: string; ADefault: Integer): Integer;
begin
  Result := GetVar(AName, TValue.From<Integer>(ADefault)).AsInteger;
end;

class function TPGKernel.GetVar(const AName: string; ADefault: Int64): Int64;
begin
  Result := GetVar(AName, TValue.From<Int64>(ADefault)).AsInt64;
end;

class function TPGKernel.GetVar(const AName: string; ADefault: Cardinal): Cardinal;
begin
  Result := GetVar(AName, TValue.From<Cardinal>(ADefault)).AsOrdinal;
end;

class function TPGKernel.GetVar(const AName: string; ADefault: Double): Double;
begin
  Result := GetVar(AName, TValue.From<Double>(ADefault)).AsExtended;
end;

class function TPGKernel.GetVar(const AName: string; ADefault: Currency): Currency;
begin
  Result := GetVar(AName, TValue.From<Currency>(ADefault)).AsCurrency;
end;

class function TPGKernel.GetVar(const AName: string; const ADefault: string): string;
begin
  Result := GetVar(AName, TValue.From<string>(ADefault)).AsString;
end;

class function TPGKernel.Exists(const AName: string): Boolean;
begin
  Result := FVars.ContainsKey(AName);
end;

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

procedure RunInMainThread(AMethod: TThreadMethod; Sync:Boolean = True);
begin
  if GetCurrentThreadId = MainThreadID then
    AMethod()
  else begin
    if Sync then
      TThread.Synchronize(nil, AMethod)
    else
      TThread.Queue(nil, AMethod);
  end;
end;

procedure RunInMainThread(AProc: TThreadProcedure; Sync:Boolean = True);
begin
  if GetCurrentThreadId = MainThreadID then
    AProc()
  else begin
    if Sync then
      TThread.Synchronize(nil, AProc)
    else
      TThread.Queue(nil, AProc);
  end;
end;

initialization

finalization

end.
