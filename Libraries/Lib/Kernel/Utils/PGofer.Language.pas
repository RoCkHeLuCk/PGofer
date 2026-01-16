unit PGofer.Language;

interface

uses
  PGofer.Core, System.Generics.Collections;

type
  TPGConsoleNotify = procedure(const AValue: string; const ANewLine, AShow: Boolean) of object;

  TLogBufferItem = record
    Msg: string;
    IsNewLine: Boolean;
    IsShow: Boolean;
  end;

  TPGLanguage = class
  private
    class var FDictionary: TDictionary<string, string>;
    class var FConsoleNotify: TPGConsoleNotify;
    class var FActive: Boolean;
    class var FLogBuffer: TList<TLogBufferItem>;
    class var FLanguage: string;
    class procedure InternalLog(const AMsg: String; const ANewLine, AShow: Boolean); static;
    class procedure SetConsoleNotify(const AValue: TPGConsoleNotify); static;
  public
    class constructor Create();
    class destructor Destroy();
    class property ConsoleNotify: TPGConsoleNotify read FConsoleNotify write SetConsoleNotify;
    class procedure LoadLangFromFile(const AFileName: string);
    class function Translate(const AKey: string; const ATranslating: Boolean = True): string; overload; static;
    class function Translate(const AKey: string; const AArgs: array of const; const ATranslating: Boolean = True): string; overload; static;
    class procedure ConsoleTranslate(const AKey: string; const ATranslating: Boolean = True); overload; static;
    class procedure ConsoleTranslate(const AKey: string; const AArgs: array of const; const ATranslating: Boolean = True); overload; static;
    class procedure ConsoleTranslate(const AValue: string; const ANewLine, AShow: Boolean; const ATranslating: Boolean = True); overload; static;
    class procedure ConsoleTranslate(const AKey: string; const AArgs: array of const; const ANewLine, AShow: Boolean; const ATranslating: Boolean = True); overload; static;
    class property Language: string read FLanguage;
  end;

  function Tr(const AKey: string): string; overload; inline;
  function Tr(const AKey: string; const AArgs: array of const; const ATranslating: Boolean = True): string; overload;
  procedure TrC(const AKey: string; const ATranslating: Boolean = True); overload;
  procedure TrC(const AKey: string; const AArgs: array of const; const ATranslating: Boolean = True); overload;
  procedure TrC(const AValue: string; const ANewLine, AShow: Boolean; const ATranslating: Boolean = True); overload;
  procedure TrC(const AKey: string; const AArgs: array of const; const ANewLine, AShow: Boolean; const ATranslating: Boolean = True); overload;

implementation

uses
  System.SysUtils, System.IOUtils, System.JSON, Winapi.Windows,
  PGofer.Files.Controls;

{ TPGLanguage }

class constructor TPGLanguage.Create;
begin
  FDictionary := TDictionary<string, string>.Create;
  FLogBuffer := TList<TLogBufferItem>.Create;
  FActive := False;
  FConsoleNotify := nil;
  LoadLangFromFile(TPGKernel.GetVar('_FileLanguage',''));
end;

class destructor TPGLanguage.Destroy;
begin
  FConsoleNotify := nil;
  FActive := False;
  FDictionary.Free;
  FLogBuffer.Free;
end;

class procedure TPGLanguage.InternalLog(const AMsg: String; const ANewLine, AShow: Boolean);
var
  LogItem: TLogBufferItem;
begin
  if Assigned(FConsoleNotify) then
  begin
    RunInMainThread(
      procedure
      begin
        FConsoleNotify(AMsg, ANewLine, AShow);
      end
    );
  end else begin
    {$IFDEF DEBUG}
    OutputDebugString(PChar('PGofer: ' + AMsg));
    {$ENDIF}

    LogItem.Msg := AMsg;
    LogItem.IsNewLine := ANewLine;
    LogItem.IsShow := AShow;
    FLogBuffer.Add(LogItem);
  end;
end;

class procedure TPGLanguage.SetConsoleNotify(const AValue: TPGConsoleNotify);
var
  Item: TLogBufferItem;
begin
  FConsoleNotify := AValue;
  if Assigned(FConsoleNotify) and (FLogBuffer.Count > 0) then
  begin
    for Item in FLogBuffer do
    begin
      FConsoleNotify(Item.Msg, Item.IsNewLine, Item.IsShow);
    end;
    FLogBuffer.Clear;
  end;
end;

class procedure TPGLanguage.LoadLangFromFile(const AFileName: string);
var
  JSONObject: TJSONObject;
  JSONValue: TJSONValue;
  JSONPair: TJSONPair;
  Content: string;
begin
  FDictionary.Clear;
  FActive := False;

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
            FDictionary.AddOrSetValue(
              JSONPair.JsonString.Value,
              JSONPair.JsonValue.Value
            );
          end;
          FActive := (FDictionary.Count > 0);
          FDictionary.TryGetValue('Language',FLanguage);
        end;
      finally
        JSONValue.Free;
      end;
    end else
      TPGLanguage.InternalLog('Error: JSON invalid: ' + AFileName, True, True);
  end else begin
    TPGLanguage.InternalLog('Error: Lang file missing: ' + AFileName, True, True);
  end;
end;

class function TPGLanguage.Translate(const AKey: string; const ATranslating: Boolean = True): string;
begin
  if (not ATranslating) or (not FActive) or (not FDictionary.TryGetValue(AKey, Result)) then
    Result := AKey;
end;

class function TPGLanguage.Translate(const AKey: string; const AArgs: array of const; const ATranslating: Boolean = True): string;
var
  FormatStr: string;
begin
  FormatStr := Translate(AKey, ATranslating);
  try
    Result := Format(FormatStr, AArgs);
  except
    Result := FormatStr;
    TPGLanguage.InternalLog('Error: Format Key: ' + AKey, True, True);
  end;
end;

class procedure TPGLanguage.ConsoleTranslate(const AKey: string; const ATranslating: Boolean = True);
var
  msg: string;
begin
  msg := TPGLanguage.Translate(AKey, ATranslating);
  TPGLanguage.InternalLog(msg, True, True);
end;

class procedure TPGLanguage.ConsoleTranslate(const AKey: string; const AArgs: array of const; const ATranslating: Boolean = True);
var
  msg: string;
begin
  msg := TPGLanguage.Translate(AKey, AArgs, ATranslating);
  TPGLanguage.InternalLog(msg, True, True);
end;

class procedure TPGLanguage.ConsoleTranslate(const AValue: string; const ANewLine, AShow: Boolean; const ATranslating: Boolean = True);
var
  msg: string;
begin
  msg := TPGLanguage.Translate(AValue, ATranslating);
  TPGLanguage.InternalLog(msg, ANewLine, AShow);
end;

class procedure TPGLanguage.ConsoleTranslate(const AKey: string; const AArgs: array of const; const ANewLine, AShow: Boolean; const ATranslating: Boolean = True);
var
  msg: string;
begin
  msg := TPGLanguage.Translate(AKey, AArgs, ATranslating);
  TPGLanguage.InternalLog(msg, ANewLine, AShow);
end;

{ Globals }

function Tr(const AKey: string): string;
begin
  Result := TPGLanguage.Translate(AKey, True);
end;

function Tr(const AKey: string; const AArgs: array of const; const ATranslating: Boolean = True): string;
begin
  Result := TPGLanguage.Translate(AKey, AArgs, ATranslating);
end;

procedure TrC(const AKey: string; const ATranslating: Boolean = True);
begin
  TPGLanguage.ConsoleTranslate(AKey, ATranslating);
end;

procedure TrC(const AKey: string; const AArgs: array of const; const ATranslating: Boolean = True);
begin
  TPGLanguage.ConsoleTranslate(AKey, AArgs, ATranslating);
end;

procedure TrC(const AValue: string; const ANewLine, AShow: Boolean; const ATranslating: Boolean = True);
begin
  TPGLanguage.ConsoleTranslate(AValue, ANewLine, AShow, ATranslating);
end;

procedure TrC(const AKey: string; const AArgs: array of const; const ANewLine, AShow: Boolean; const ATranslating: Boolean = True);
begin
  TPGLanguage.ConsoleTranslate(AKey, AArgs, ANewLine, AShow, ATranslating);
end;

initialization

finalization

end.
