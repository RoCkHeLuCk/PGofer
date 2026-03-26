unit PGofer.Core;

interface

uses
  System.Classes, System.SyncObjs, System.Generics.Collections, System.Rtti,
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
    class var FConsoleBuffer: TQueue<TConsoleBuffer>;
    class var FConsoleNotify: TPGConsoleNotify;
    class var FConsoleFlush: Boolean;
    class var FConsoleLock: TCriticalSection;
    class procedure ConsoleFlush(); static;
    class procedure SetConsoleNotify(AValue: TPGConsoleNotify); static;
    class procedure ConsoleLocked();
    class procedure ConsoleUnlocked();

    //translate
    class var FTranslate: TDictionary<string, string>;
    //class var FTranslateLock: TCriticalSection;
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
    //???
    class function IfThen<T>(const ACondition: Boolean; const ATrue, AFalse: T): T; static; inline;
  end;

  TPGAboutAttribute = class(TCustomAttribute)
  private
    FText: string;
  public
    constructor Create(const AArgs: string); overload;
    property Text: string read FText;
    class function GetFromRtti(ARttiObject: TRttiObject): string; static;
    class function GetFromClass(AClass: TClass): string; static;
    class function GetFromProperty(AProp: TRttiProperty): string; static;
    class function GetFromMethod(AMethod: TRttiMethod): string; static;
    class function GetFromParameter(AParameter: TRttiParameter): string; static;
  end;

  TPGArgsAttribute = class(TCustomAttribute)
  private
    FArgs: TArray<string>;
  public
    constructor Create(const AArgs: String); overload;
    property Args: TArray<string> read FArgs;
    class function GetFromRtti(ARttiObject: TRttiObject): TArray<string>; static;
    class function GetFromClass(AClass: TClass): TArray<string>; static;
  end;

  procedure RunInMainThread(AMethod: TThreadMethod; Sync:Boolean = True); overload;
  procedure RunInMainThread(AProc: TThreadProcedure; Sync:Boolean = True); overload;

  function ValueToInt64(const AValue: TValue): Int64;
  function ValueToExtended(const AValue: TValue): Extended;
  function ValueToBoolean(const AValue: TValue): Boolean;
  function ValueToString(const AValue: TValue): string;
  function ValueAlign(const AValue: TValue; ATargetType: TRttiType): TValue;

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
  TPGKernel.FConsoleLock := TCriticalSection.Create();
  TPGKernel.FRttiContext := TRttiContext.Create;
  TPGKernel.FPathCurrent:= IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));;
  TPGKernel.FReportMemoryLeaks := False;
  TPGKernel.FLoopLimit := 1000000;
  TPGKernel.FReplyFormat := '';
  TPGKernel.FReplyPrefix := False;
  TPGKernel.FConsoleMessage := True;

  //console
  FConsoleBuffer := TQueue<TConsoleBuffer>.Create;
  FConsoleFlush := False;
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
  TPGKernel.FConsoleFlush := False;
  TPGKernel.FConsoleNotify := nil;
  TPGKernel.FConsoleBuffer.Free;
  TPGKernel.FConsoleLock.Free;

  TPGKernel.FTranslate.Free;
  //TPGKernel.FRttiContext.Free;
end;

class procedure TPGKernel.ConsoleLocked;
begin
  TPGKernel.FConsoleLock.Acquire;
end;

class procedure TPGKernel.ConsoleUnlocked;
begin
  TPGKernel.FConsoleLock.Release;
end;

class procedure TPGKernel.ConsoleFlush();
var
  LBatchText: TStringBuilder;
  LItem: TConsoleBuffer;
  LCount: Integer;
begin
  LBatchText := TStringBuilder.Create;
  try
    TPGKernel.ConsoleLocked;
    try
      LCount := 0;
      while (FConsoleBuffer.Count > 0) and (LCount < 100) do
      begin
        LItem := FConsoleBuffer.Dequeue;
        if LItem.IsShow then
        begin
          LBatchText.Append(LItem.Msg);
          if LItem.IsNewLine then
            LBatchText.AppendLine;
        end;
        Inc(LCount);
      end;

      if FConsoleBuffer.Count > 0 then
        TThread.Queue(nil, ConsoleFlush)
      else
        FConsoleFlush := False;
    finally
      TPGKernel.ConsoleUnlocked;
    end;

    if (LBatchText.Length > 0) and Assigned(FConsoleNotify) then
      FConsoleNotify(LBatchText.ToString, False, True);

  finally
    LBatchText.Free;
  end;
end;

class procedure TPGKernel.SetConsoleNotify(AValue: TPGConsoleNotify);
begin
  TPGKernel.ConsoleLocked;
  try
    FConsoleNotify := AValue;
    if Assigned(FConsoleNotify) and (FConsoleBuffer.Count > 0) then
    begin
      if not FConsoleFlush then
      begin
        FConsoleFlush := True;
        RunInMainThread(ConsoleFlush, False);
      end;
    end;
  finally
    TPGKernel.ConsoleUnlocked;
  end;
end;

class procedure TPGKernel.Console(const AValue: string; ANewLine, AShow: Boolean);
var
  LItem: TConsoleBuffer;
begin
  LItem.Msg := AValue;
  LItem.IsNewLine := ANewLine;
  LItem.IsShow := AShow;

  TPGKernel.ConsoleLocked;
  try
    FConsoleBuffer.Enqueue(LItem);
    if not FConsoleFlush then
    begin
      FConsoleFlush := True;
      RunInMainThread(ConsoleFlush, False);
    end;
  finally
    TPGKernel.ConsoleUnlocked;
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

class procedure TPGKernel.SetLanguageFile(const AValue: String);
begin
  FLanguageFile := AValue;
  TPGKernel.LoadTranslateFile( FLanguageFile );
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
    if Content = '' then Exit;
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

class function TPGKernel.IfThen<T>(const ACondition: Boolean; const ATrue, AFalse: T): T;
begin
  if ACondition then
    Result := ATrue
  else
    Result := AFalse;
end;

{ TPGAboutAttribute }

constructor TPGAboutAttribute.Create(const AArgs: string);
begin
  inherited Create( );
  FText := AArgs;
end;

class function TPGAboutAttribute.GetFromRtti(ARttiObject: TRttiObject): string;
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
      if LAttrib[LIndex] is TPGAboutAttribute then
        Result := Result + TPGAboutAttribute(LAttrib[LIndex]).Text;
      if LIndex < High(LAttrib) then
        Result := Result + #13;
    end;
  end;
end;

class function TPGAboutAttribute.GetFromClass(AClass: TClass): string;
begin
  Result := GetFromRtti( TPGKernel.RttiContext.GetType(AClass) );
end;

class function TPGAboutAttribute.GetFromProperty(AProp: TRttiProperty): string;
begin
  Result := GetFromRtti(AProp);
end;

class function TPGAboutAttribute.GetFromMethod(AMethod: TRttiMethod): string;
begin
  Result := GetFromRtti(AMethod);
end;

class function TPGAboutAttribute.GetFromParameter(AParameter: TRttiParameter): string;
begin
  Result := GetFromRtti(AParameter);
end;

{ TPGArgsAttribute }

constructor TPGArgsAttribute.Create(const AArgs: String);
var
  LArr: TArray<string>;
  i: Integer;
begin
  inherited Create();
  LArr := AArgs.Split([',']);
  SetLength(FArgs, Length(LArr));
  for i := 0 to High(LArr) do
    FArgs[i] := LArr[i].Trim;
end;

class function TPGArgsAttribute.GetFromRtti(ARttiObject: TRttiObject): TArray<string>;
var
  LAttrib: TArray<TCustomAttribute>;
  LIndex: Integer;
begin
  SetLength(Result, 0);
  if Assigned(ARttiObject) then
  begin
    LAttrib := ARttiObject.GetAttributes;
    for LIndex := Low(LAttrib) to High(LAttrib) do
    begin
      if LAttrib[LIndex] is TPGArgsAttribute then
        Exit(TPGArgsAttribute(LAttrib[LIndex]).Args); // Retorna o array pronto!
    end;
  end;
end;

class function TPGArgsAttribute.GetFromClass(AClass: TClass): TArray<string>;
begin
  Result := GetFromRtti(TPGKernel.RttiContext.GetType(AClass));
end;

{ }

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

function ValueToInt64(const AValue: TValue): Int64;
begin
  if AValue.IsEmpty then Exit(0);
  case AValue.Kind of
    tkInteger, tkInt64: Result := AValue.AsInt64;
    tkFloat:            Result := Trunc(AValue.AsExtended);
    tkEnumeration:      Result := AValue.AsOrdinal;
    tkString, tkUString, tkWString, tkLString: Result := StrToInt64Def(AValue.ToString, 0);
  else Result := 0;
  end;
end;

function ValueToExtended(const AValue: TValue): Extended;
begin
  if AValue.IsEmpty then Exit(0.0);
  case AValue.Kind of
    tkFloat:            Result := AValue.AsExtended;
    tkInteger, tkInt64: Result := AValue.AsInt64;
    tkString, tkUString, tkWString: Result := StrToFloatDef(AValue.ToString, 0.0);
  else Result := 0.0;
  end;
end;

function ValueToBoolean(const AValue: TValue): Boolean;
begin
  if AValue.IsEmpty then Exit(False);
  case AValue.Kind of
    tkEnumeration:      Result := AValue.AsBoolean;
    tkInteger, tkInt64: Result := AValue.AsInt64 <> 0;
    tkFloat:            Result := AValue.AsExtended <> 0;
    tkString, tkUString, tkWString: Result := StrToBoolDef(AValue.ToString, False);
  else Result := False;
  end;
end;

function ValueToString(const AValue: TValue): string;
begin
  if AValue.IsEmpty then Exit('');
  Result := AValue.ToString;
end;

function ValueAlign(const AValue: TValue; ATargetType: TRttiType): TValue;
begin
  if ATargetType = nil then Exit(AValue);

  case ATargetType.TypeKind of
    tkInteger, tkInt64:
      Result := TValue.From<Int64>(ValueToInt64(AValue));

    tkFloat:
      Result := TValue.From<Extended>(ValueToExtended(AValue));

    tkEnumeration:
    begin
      if ATargetType.Handle = TypeInfo(Boolean) then
        Result := TValue.From<Boolean>(ValueToBoolean(AValue))
      else
        Result := TValue.FromOrdinal(ATargetType.Handle, ValueToInt64(AValue));
    end;

    tkUString, tkString, tkWString, tkLString:
      Result := TValue.From<string>(ValueToString(AValue));

  else
    Result := AValue;
  end;
end;


initialization

finalization

end.

