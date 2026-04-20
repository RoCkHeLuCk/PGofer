unit PGofer.Triggers.HotKeys;

interface

uses
  System.Classes,
  System.Generics.Collections,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers, PGofer.Triggers.HotKeys.Controls;

type
  {$M+}
  [TPGArgs('HotKeysHex, Inhibit, Detect, Script')]
  TPGHotKey = class(TPGItemTrigger)
  private
    FKeys: TList<Word>;
    FDetect: Byte;
    FInhibit: Boolean;
    FScript: TStrings;
    function GetKeysHex(): string;
    function GetScript: string;
    procedure SetKeysHex(AValue: string);
    procedure SetScript(const AValue: string);
    procedure SetInhibit(AValue: Boolean);
    class var FHotKeyList: TList<TPGHotKey>;
    class var FShootKeys: TList<Word>;
    class var FOnProcessKeys: TProcessKeys;
    class var FTypeInput: TThread;
    class var FTypeIndex: Byte;
    class function LocateHotKeys(Keys: TList<Word>): TPGHotKey;
    class function DefaultOnProcessKeys(AParamInput: TParamInput): Boolean;
    //class procedure SetInput(AType: Byte);
  protected
    class function GetFrameType: TPGTriggerFrameType; override;
  public
    class constructor Create();
    class destructor Destroy();
    class function OnProcessKeys(AParamInput: TParamInput): Boolean;
    class procedure SetProcessKeys(ProcessKeys: TProcessKeys = nil);
    constructor Create(AMirror: TPGItemMirror; AName: string); override;
    destructor Destroy(); override;
    procedure Triggering(); override;
    function GetKeysName(): string;
    property Keys: TList<Word> read FKeys;
  published
    property Enabled;
    property HotKeysHex: string read GetKeysHex write SetKeysHex;
    [TPGAbout('0:Press; 1:Down; 2:Up; 3:Wheel;')]
    property Detect: Byte read FDetect write FDetect;
    property Inhibit: Boolean read FInhibit write SetInhibit;
    property Script: string read GetScript write SetScript;

    [TPGAbout('0:None; 1:AsyncInput; 2:THookInput;')]
    class procedure SetInputType(AType: Byte);
    class function  GetInputType(): Byte;
    class procedure InputRestart();
    class procedure ShootKeysList();
    class procedure ShootKeysClear();
  end;
  {$TYPEINFO ON}

  TPGHotKeyMirror = class(TPGItemMirror)
  protected
    class function GetTriggerType: TPGItemTriggerType; override;
  end;

implementation

uses
  System.SysUtils,
  Winapi.Windows,
  PGofer.Lexico,
  PGofer.Sintatico.Controls,
  PGofer.Key.Controls,
  PGofer.Triggers.HotKeys.Frame,
  PGofer.Triggers.HotKeys.Async,
  PGofer.Triggers.HotKeys.Hook;

{ TPGHotKey }

class constructor TPGHotKey.Create;
begin
  FHotKeyList := TList<TPGHotKey>.Create();
  FShootKeys := TList<Word>.Create();
  FOnProcessKeys := nil;
  FTypeIndex := 0;
  TPGHotKey.SetInputType(2);
end;

class destructor TPGHotKey.Destroy;
begin
  TPGHotKey.SetInputType(0);
  FOnProcessKeys := nil;
  FShootKeys.Free();
  FShootKeys := nil;
  FHotKeyList.Free();
  FHotKeyList := nil;
end;

constructor TPGHotKey.Create(AMirror: TPGItemMirror; AName: string);
begin
  FKeys := TList<Word>.Create;
  FKeys.Capacity := 20;
  FDetect := 0;
  FInhibit := False;
  FScript := TStringList.Create;
  inherited Create(AMirror, AName);
  FHotKeyList.Add(Self);
end;

destructor TPGHotKey.Destroy();
begin
  if Assigned(FHotKeyList) then
    FHotKeyList.Remove(Self);
  FDetect := 0;
  FInhibit := False;
  FScript.Free;
  FScript := nil;
  FKeys.Clear;
  FKeys.Free;
  FKeys := nil;
  inherited Destroy();
end;

class function TPGHotKey.GetFrameType(): TPGTriggerFrameType;
begin
  Result := TPGHotKeyFrame;
end;

class function TPGHotKey.GetInputType(): Byte;
begin
  Result := TPGHotKey.FTypeIndex;
end;

procedure TPGHotKey.Triggering();
begin
  ScriptExec('HotKey: ' + Self.Name, Self.Script, nil, False);
end;

function TPGHotKey.GetKeysHex(): string;
var
  Key: Word;
begin
  Result := '';
  for Key in FKeys do
    Result := Result + IntToHex(Key, 3);
end;

procedure TPGHotKey.SetKeysHex(AValue: string);
var
  Count, Key: Word;
begin
  FKeys.Clear;
  Count := low(AValue);
  while Count + 2 <= high(AValue) do
  begin
    Key := StrToInt('$' + copy(AValue, Count, 3));
    if not FKeys.Contains(Key) then
      FKeys.Add(Key);
    inc(Count, 3);
  end;
end;

function TPGHotKey.GetScript: string;
begin
  Result := FScript.Text;
end;

procedure TPGHotKey.SetScript(const AValue: string);
begin
  FScript.Text := AValue;
end;

procedure TPGHotKey.SetInhibit(AValue: Boolean);
begin
  if FTypeIndex = 2 then
    FInhibit := AValue
  else
    FInhibit := False;
end;

function TPGHotKey.GetKeysName(): string;
var
  Key: Word;
begin
  Result := '';
  for Key in FKeys do
  begin
    if Result = '' then
      Result := KeyVirtualToStr(Key)
    else
      Result := Result + ' + ' + KeyVirtualToStr(Key);
  end;
end;

class function TPGHotKey.LocateHotKeys(Keys: TList<Word>): TPGHotKey;
var
  LKeysCount, LListCount, LCount1, LCount2: Word;
  LAuxHotKeys: TPGHotKey;
  LFind: Boolean;
begin
  Result := nil;
  if not Assigned(Keys) then Exit;

  LKeysCount := Keys.Count;
  if LKeysCount <= 1 then Exit;

  LListCount := FHotKeyList.Count;
  if LListCount < 1 then Exit;

  for LCount1 := 0 to LListCount - 1 do
  begin
    LAuxHotKeys := TPGHotKey(FHotKeyList[LCount1]);
    if LAuxHotKeys.Enabled and (LAuxHotKeys.FKeys.Count = LKeysCount) then
    begin
      LFind := True;
      for LCount2 := 0 to LKeysCount - 1 do
      begin
        if LAuxHotKeys.FKeys[LCount2] <> Keys[LCount2] then
        begin
          LFind := False;
          Break;
        end;
      end;

      if LFind then
      begin
        Result := LAuxHotKeys;
        Break;
      end;
    end;
  end;
end;

class function TPGHotKey.OnProcessKeys(AParamInput: TParamInput): Boolean;
begin
  if Assigned(TPGHotKey.FOnProcessKeys) then
    Result := TPGHotKey.FOnProcessKeys(AParamInput)
  else
    Result := TPGHotKey.DefaultOnProcessKeys(AParamInput);
end;

class function TPGHotKey.DefaultOnProcessKeys(AParamInput: TParamInput): Boolean;
var
  LKey: TKey;
  LHotKey: TPGHotKey;
  I: Integer;
begin
  Result := False;
  LKey := TKey.CalcVirtualKey(AParamInput);
  if LKey.wKey <= 0 then Exit;

  for i := FShootKeys.Count - 1 downto 0 do
  begin
    if (GetAsyncKeyState(FShootKeys[i]) and $8000) = 0 then
      FShootKeys.Delete(i); // Exorciza o fantasma!
  end;

  if LKey.bDetect in [kd_Down, kd_Wheel] then
  begin
    if (FShootKeys.Contains(LKey.wKey)) then
      LKey.bDetect := kd_Press
    else
      TPGHotKey.FShootKeys.Add(LKey.wKey);
  end else begin
    if (LKey.bDetect = kd_Up) and (not FShootKeys.Contains(LKey.wKey)) then
    begin
      TPGHotKey.FShootKeys.Add(LKey.wKey);
    end;
  end;

  try
    LHotKey := TPGHotKey.LocateHotKeys(FShootKeys);
    if Assigned(LHotKey) then
    begin
      if LHotKey.Inhibit and (FTypeIndex = 2) then
        Result := True;

      if ((LKey.bDetect = kd_Wheel) or (LHotKey.Detect = Byte(LKey.bDetect))) then
      begin
        TThread.Queue(nil,
          procedure
          begin
            LHotKey.Triggering();
          end
        );
      end;
    end;
  finally
    if LKey.bDetect in [kd_Up, kd_Wheel] then
      TPGHotKey.FShootKeys.Remove(LKey.wKey);
  end;
end;

class procedure TPGHotKey.SetProcessKeys(ProcessKeys: TProcessKeys);
begin
  if Assigned(ProcessKeys) then
    TPGHotKey.FOnProcessKeys := ProcessKeys
  else
    TPGHotKey.FOnProcessKeys := nil;
end;

class procedure TPGHotKey.SetInputType(AType: Byte);
begin
  FTypeIndex := AType;
  try
    if Assigned(TPGHotKey.FTypeInput) then
    begin
      TPGHotKey.FTypeInput.Free();
      TPGHotKey.FTypeInput := nil;
      TPGHotKey.FShootKeys.Clear;
    end;
  finally
    case FTypeIndex of
      1:
      begin
        TPGHotKey.FTypeInput := TAsyncInput.Create();
        TPGKernel.ConsoleTr('Ok_HotKey_SetAsyncInput');
      end;
      2:
      begin
        {$IFNDEF DEBUG}
          TPGHotKey.FTypeInput := THookInput.Create();
          TPGKernel.ConsoleTr('Ok_HotKey_SetHookInput');
        {$ELSE}
          TPGKernel.Console('HotKey: Debug mode, Set AsyncInput.');
          FTypeIndex := 1;
        {$ENDIF}
      end;
    else
      TPGKernel.ConsoleTr('Ok_HotKey_SetNone');
      FTypeIndex := 0;
    end;
  end;
end;

class procedure TPGHotKey.InputRestart();
begin
  TPGHotKey.SetInputType(FTypeIndex);
end;

class procedure TPGHotKey.ShootKeysClear;
begin
   TPGHotKey.FShootKeys.Clear;
end;

class procedure TPGHotKey.ShootKeysList();
var
   LKey : Word;
begin
   TPGKernel.Console('**** ShootKeysList Start ****', True);
   for LKey in TPGHotKey.FShootKeys do
   begin
      TPGKernel.Console('  [' + LKey.ToString() + '] - ' + KeyVirtualToStr(LKey), True);
   end;
   TPGKernel.Console('**** ShootKeysList End ****', True);
end;


{ TPGHotKeyMirror }

class function TPGHotKeyMirror.GetTriggerType: TPGItemTriggerType;
begin
  Result := TPGHotKey;
end;

initialization
  TPGItemDef.Create(TPGHotKey);
  TriggersCollect.RegisterClass(TPGHotKeyMirror);

finalization

end.
