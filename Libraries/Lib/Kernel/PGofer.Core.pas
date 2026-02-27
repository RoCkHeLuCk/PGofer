unit PGofer.Core;

interface

uses
  System.Classes, System.Generics.Collections, System.Rtti,
  Vcl.Controls;

const
  LOW_STRING = low( string );

type
  TPGConsoleNotify = procedure(const AValue: string; const ANewLine, AShow: Boolean) of object;

  TPGKernel = class
  private
    //vars
    class var FRttiContext: TRttiContext;
    class var FPathCurrent: String;
    class var FLanguageFile: String;
    class var FConsoleMessage: Boolean;
    class var FReplyFormat: String;
    class var FReplyPrefix: Boolean;
    class var FLoopLimit: Cardinal;
    class var FReportMemoryLeaks: Boolean;
    class procedure SetLanguageFile(const AValue: String); static;
    //console
    type TConsoleBuffer = record
      Msg: string;
      IsNewLine: Boolean;
      IsShow: Boolean;
    end;
    class var FConsoleNotify: TPGConsoleNotify;
    class var FConsoleBuffer: TList<TConsoleBuffer>;
    class procedure SetConsoleNotify(AValue: TPGConsoleNotify); static;
    //translate
    class var FTranslate: TDictionary<string, string>;
  public
    class constructor Create();
    class destructor Destroy();
    //vars
    class property RttiContext: TRttiContext read FRttiContext;
    class property PathCurrent: String read FPathCurrent;
    class property LanguageFile: String read FLanguageFile write SetLanguageFile;
    class property ReportMemoryLeaks: Boolean read FReportMemoryLeaks write FReportMemoryLeaks;
    class property LoopLimit: Cardinal read FLoopLimit write FLoopLimit;
    class property ReplyFormat: String read FReplyFormat write FReplyFormat;
    class property ReplyPrefix: Boolean read FReplyPrefix write FReplyPrefix;
    class property ConsoleMessage: Boolean read FConsoleMessage write FConsoleMessage;
    //console
    class property ConsoleNotify: TPGConsoleNotify read FConsoleNotify write SetConsoleNotify;
    class procedure Console(const AValue: string; ANewLine: Boolean = True; AShow: Boolean = True); overload; static;
    class procedure Console(const AKey: string; const AArgs: array of const; ANewLine: Boolean = True; AShow: Boolean = True); overload; static;
    //translate
    class procedure LoadTranslateFile(const AFileName: string);
    class function Translate(const AValue: string): string; overload; static;
    class function Translate(const AKey: string; const AArgs: array of const): string; overload; static;
    //console translate
    class procedure ConsoleTr(const AValue: string; ANewLine: Boolean = True; AShow: Boolean = True); overload; static;
    class procedure ConsoleTr(const AKey: string; const AArgs: array of const; ANewLine: Boolean = True; AShow: Boolean = True); overload; static;
  end;

  TPGAttribText = class(TCustomAttribute)
  private
    FText: string;
  public
    constructor Create(const AText: string); overload;
    destructor Destroy( ); override;
    property Text: string read FText;
    class function GetFromRtti(ARttiObject: TRttiObject): string; static;
    class function GetFromClass(AClass: TClass): string; static;
    class function GetFromProperty(AProp: TRttiProperty): string; static;
    class function GetFromMethod(AMethod: TRttiMethod): string; static;
    class function GetFromParameter(AParameter: TRttiParameter): string; static;
  end;

  function ConvertVariantToValue(const AValor: Variant;const ATypeKind: TTypeKind ): TValue;
  function ConvertValueToVariant(const AValor: TValue;const ATypeKind: TTypeKind ): Variant;

  procedure RunInMainThread(AMethod: TThreadMethod; Sync:Boolean = True); overload;
  procedure RunInMainThread(AProc: TThreadProcedure; Sync:Boolean = True); overload;

implementation

uses
  System.SysUtils, System.IOUtils, System.JSON, System.TypInfo,
  Winapi.Windows,
  Vcl.Graphics,
  PGofer.Files.Controls;

{ TPGKernel }

class constructor TPGKernel.Create();
begin
  //var
  FRttiContext := TRttiContext.Create;
  TPGKernel.FPathCurrent:= IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));;
  TPGKernel.FReportMemoryLeaks := False;
  TPGKernel.FLoopLimit := 1000000;
  TPGKernel.FReplyFormat := '';
  TPGKernel.FReplyPrefix := False;
  TPGKernel.FConsoleMessage := True;

  //console
  FConsoleBuffer := TList<TConsoleBuffer>.Create;
  FConsoleNotify := nil;

  //translate
  FTranslate := TDictionary<string, string>.Create;

  {$IFDEF DEBUG}
    TPGKernel.SetLanguageFile(FPathCurrent + '..\..\..\..\Documents\Languages\Language.json');
  {$ELSE}
    TPGKernel.SetLanguageFile(FPathCurrent + 'Language.json');
  {$ENDIF}

end;

class destructor TPGKernel.Destroy();
begin
  FConsoleNotify := nil;
  FConsoleBuffer.Free;
  FTranslate.Free;
  FRttiContext.Free;
end;

class procedure TPGKernel.SetConsoleNotify(AValue: TPGConsoleNotify);
var
  LLogBuffer: TConsoleBuffer;
begin
  FConsoleNotify := AValue;
  if Assigned(FConsoleNotify) and (FConsoleBuffer.Count > 0) then
  begin
    for LLogBuffer in FConsoleBuffer do
    begin
      FConsoleNotify(LLogBuffer.Msg, LLogBuffer.IsNewLine, LLogBuffer.IsShow);
    end;
    FConsoleBuffer.Clear;
  end;
end;

class procedure TPGKernel.SetLanguageFile(const AValue: String);
begin
  FLanguageFile := AValue;
  TPGKernel.LoadTranslateFile( FLanguageFile );
end;

class procedure TPGKernel.Console(const AValue: string; ANewLine, AShow: Boolean);
var
  LLogBuffer: TConsoleBuffer;
begin
  if Assigned(FConsoleNotify) then
  begin
    RunInMainThread(
      procedure
      begin
        FConsoleNotify(AValue, ANewLine, AShow);
      end
    );
  end else begin
    {$IFDEF DEBUG}
    OutputDebugString(PChar('PGofer: ' + AValue));
    {$ENDIF}

    LLogBuffer.Msg := AValue;
    LLogBuffer.IsNewLine := ANewLine;
    LLogBuffer.IsShow := AShow;
    FConsoleBuffer.Add(LLogBuffer);
  end;
end;

class procedure TPGKernel.Console(const AKey: string; const AArgs: array of const; ANewLine, AShow: Boolean);
var
  LValue: string;
begin
  try
    LValue := Format(AKey, AArgs);
  except
    TPGKernel.Console('Error Kernel: Format Key "%s"!',[AKey]);
  end;
  TPGKernel.Console(LValue, ANewLine, AShow);
end;

class procedure TPGKernel.ConsoleTr(const AValue: string; ANewLine, AShow: Boolean);
begin
   TPGKernel.Console( TPGKernel.Translate(AValue), ANewLine, AShow);
end;

class procedure TPGKernel.ConsoleTr(const AKey: string; const AArgs: array of const; ANewLine,
  AShow: Boolean);
begin
   TPGKernel.Console( TPGKernel.Translate(AKey, AArgs), ANewLine, AShow);
end;

class procedure TPGKernel.LoadTranslateFile(const AFileName: string);
var
  JSONObject: TJSONObject;
  JSONValue: TJSONValue;
  JSONPair: TJSONPair;
  Content: string;
begin
  FTranslate.Clear;
  if FileExistsEx(AFileName) then
  begin
    Content := TFile.ReadAllText(AFileName, TEncoding.UTF8);
    JSONValue := TJSONObject.ParseJSONValue(Content);
    if Assigned(JSONValue) then
    begin
      try
        if (JSONValue is TJSONObject) then
        begin
          JSONObject := TJSONObject(JSONValue);
          for JSONPair in JSONObject do
          begin
            FTranslate.AddOrSetValue(
              JSONPair.JsonString.Value,
              JSONPair.JsonValue.Value
            );
          end;
        end;
      finally
        JSONValue.Free;
      end;
    end else
      TPGKernel.Console('Error Translate: JSON invalid "%s".',[AFileName]);
  end else begin
    TPGKernel.Console('Error Translate: File missing "%s".',[AFileName]);
  end;
end;

class function TPGKernel.Translate(const AValue: string): string;
begin
  if not FTranslate.TryGetValue(AValue, Result) then
    Result := AValue;
end;

class function TPGKernel.Translate(const AKey: string; const AArgs: array of const): string;
var
  FormatStr: string;
begin
  FormatStr := Translate(AKey);
  try
    Result := Format(FormatStr, AArgs);
  except
    Result := FormatStr;
    TPGKernel.Console('Error Translate: Format Key[%s]', [AKey]);
  end;
end;

{ TPGAttribText }

constructor TPGAttribText.Create(const AText: string);
begin
  inherited Create( );
  FText := AText;
end;

destructor TPGAttribText.Destroy( );
begin
  FText := '';
  inherited Destroy( );
end;

class function TPGAttribText.GetFromRtti(ARttiObject: TRttiObject): string;
var
  LAttrib: TArray<TCustomAttribute>;
  LIndex: Integer;
begin
  Result := '';
  if Assigned(ARttiObject) then
  begin
    LAttrib := ARttiObject.GetAttributes;
    for LIndex := Low(LAttrib) to High(LAttrib) do
    begin
      if LAttrib[LIndex] is TPGAttribText then
        Result := Result + TPGAttribText(LAttrib[LIndex]).Text;
      if LIndex < High(LAttrib) then
        Result := Result + #13;
    end;
  end;
end;

class function TPGAttribText.GetFromClass(AClass: TClass): string;
begin
  Result := GetFromRtti( TPGKernel.RttiContext.GetType(AClass) );
end;

class function TPGAttribText.GetFromProperty(AProp: TRttiProperty): string;
begin
  Result := GetFromRtti(AProp);
end;

class function TPGAttribText.GetFromMethod(AMethod: TRttiMethod): string;
begin
  Result := GetFromRtti(AMethod);
end;

class function TPGAttribText.GetFromParameter(AParameter: TRttiParameter): string;
begin
  Result := GetFromRtti(AParameter);
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
