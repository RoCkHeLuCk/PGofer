unit PGofer.Triggers.HotKeys;

interface

uses
  System.Classes, System.SyncObjs,
  System.Generics.Collections,
  PGofer.Core, PGofer.Classes, PGofer.Runtime,
  PGofer.Triggers, PGofer.Triggers.HotKeys.Controls;

type
  {$M+}
  [TPGClassReg('Defines', 'HotKeyDef')]
  TPGHotKey = class(TPGItemTrigger)
  private
    FKeys: TList<Word>;
    FDetect: Byte;
    FInhibit: Boolean;
    FScript: TStrings;

    function GetKeysHex(): string;
    procedure SetKeysHex(const AValue: string);
    procedure SetInhibit(const AValue: Boolean);
    function GetScript: string;
    procedure SetScript(const AValue: string);

    class var FInputLock: TCriticalSection;
    class var FHotKeyList: TList<TPGHotKey>;
    class var FShootKeys: TList<Word>;
    class var FOnProcessKeys: TProcessKeys;
    class var FTypeInput: TThread;
    class var FTypeIndex: Byte;
    class function LocateHotKeys(const AKeys: TList<Word>): TPGHotKey;
    class function DefaultOnProcessKeys(const AParamInput: TParamInput): Boolean;
    procedure SetDetect(const Value: Byte);
  protected
    class function GetFrameClass(): TPGItemFrameClass; override;
  public
    class function OnProcessKeys(const AParamInput: TParamInput): Boolean;
    class procedure SetProcessKeys(const ProcessKeys: TProcessKeys = nil);

    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
    destructor Destroy(); override;
    procedure Triggering(); override;
    function GetKeysName(): string;
    property Keys: TList<Word> read FKeys;
  published
    property HotKeysHex: string read GetKeysHex write SetKeysHex;
    [TPGAbout('0:Down; 1:Press; 2:Up; 3:Wheel;')]
    property Detect: Byte read FDetect write SetDetect;
    property Inhibit: Boolean read FInhibit write SetInhibit;
    property Script: string read GetScript write SetScript;
    property Disabled;

    [TPGAbout('0:None; 1:AsyncInput; 2:THookInput;')]
    class procedure SetInputType(const AType: Byte);
    class function  GetInputType(): Byte;
    class procedure InputRestart();
    class procedure ShootKeysList();
    class procedure ShootKeysClear();
  end;
  {$TYPEINFO ON}

  procedure Initialize();
  procedure Finalize();

implementation

uses
  System.SysUtils,
  Winapi.Windows,
  PGofer.Key.Controls,
  PGofer.Triggers.HotKeys.Frame,
  {$IFNDEF DEBUG}
    PGofer.Triggers.HotKeys.Hook,
  {$ENDIF}
  PGofer.Triggers.HotKeys.Async;

{ TPGHotKey }

procedure Initialize();
begin
  TPGHotKey.FInputLock := TCriticalSection.Create();
  TPGHotKey.FHotKeyList := TList<TPGHotKey>.Create();
  TPGHotKey.FShootKeys := TList<Word>.Create();
  TPGHotKey.FOnProcessKeys := nil;
  TPGHotKey.FTypeIndex := 0;
  TPGHotKey.SetInputType(2);
end;

procedure Finalize();
begin
  TPGHotKey.SetInputType(0);
  TPGHotKey.FOnProcessKeys := nil;

  TPGHotKey.FShootKeys.Free();
  TPGHotKey.FShootKeys := nil;

  TPGHotKey.FHotKeyList.Free();
  TPGHotKey.FHotKeyList := nil;

  TPGHotKey.FInputLock.Free;
  TPGHotKey.FInputLock := nil;

  {$IFDEF DEBUG}
  {$ENDIF}
end;

constructor TPGHotKey.Create(const AItemDad: TPGItem; const AName: string);
begin
  FKeys := TList<Word>.Create;
  FKeys.Capacity := 20;
  FDetect := 0;
  FInhibit := False;
  FScript := TStringList.Create;
  inherited Create(AItemDad, AName);
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

class function TPGHotKey.GetFrameClass(): TPGItemFrameClass;
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

procedure TPGHotKey.SetKeysHex(const AValue: string);
var
  Count, Key: Word;
begin
  FKeys.Clear;
  Count := low(AValue);
  while Count + 2 <= Length(AValue) do
  begin
    Key := StrToInt('$' + copy(AValue, Count, 3));
    if (Key > 0) and (not FKeys.Contains(Key)) then
      FKeys.Add(Key);
    inc(Count, 3);
  end;

  Self.Invalid := (FScript.Text.IsEmpty or (FKeys.Count = 0));
end;

function TPGHotKey.GetScript: string;
begin
  Result := FScript.Text;
end;

procedure TPGHotKey.SetScript(const AValue: string);
begin
  FScript.Text := AValue;
  Self.Invalid := (FScript.Text.IsEmpty or (FKeys.Count = 0));
end;

procedure TPGHotKey.SetDetect(const Value: Byte);
begin
  FDetect := Value;
  Self.SetInhibit(FInhibit);
end;

procedure TPGHotKey.SetInhibit(const AValue: Boolean);
begin
  if (FDetect = 0) and (FTypeIndex = 2) then
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

class function TPGHotKey.LocateHotKeys(const AKeys: TList<Word>): TPGHotKey;
var
  LKeysCount: Word;
  LHotKeys: TPGHotKey;
  LKeys: Word;
  LFind: Boolean;
begin
  Result := nil;
  if not Assigned(AKeys) then Exit(nil);

  LKeysCount := AKeys.Count;
  if LKeysCount < 1 then Exit(nil);

  for LHotKeys in FHotKeyList do
  begin
    if (not LHotKeys.Disabled)
    and (not LHotKeys.Invalid)
    and (LHotKeys.FKeys.Count = LKeysCount) then
    begin
      LFind := True;
      for LKeys in AKeys do
      begin
        if not LHotKeys.FKeys.Contains(LKeys) then
        begin
          LFind := False;
          Break;
        end;
      end;

      if LFind then
        Exit(LHotKeys);
    end;
  end;
end;

class function TPGHotKey.OnProcessKeys(const AParamInput: TParamInput): Boolean;
begin
  if Assigned(TPGHotKey.FOnProcessKeys) then
    Result := TPGHotKey.FOnProcessKeys(AParamInput)
  else
    Result := TPGHotKey.DefaultOnProcessKeys(AParamInput);
end;

class function TPGHotKey.DefaultOnProcessKeys(const AParamInput: TParamInput): Boolean;
var
  LKey: TKey;
  LHotKey: TPGHotKey;
  LIndex: Integer;
begin
  Result := False;
  LKey := TKey.CalcVirtualKey(AParamInput);
  if LKey.wKey < 1 then
    Exit(False);

  for LIndex := FShootKeys.Count - 1 downto 0 do
  begin
    if (GetAsyncKeyState(FShootKeys[LIndex]) and $8000) = 0 then
      FShootKeys.Delete(LIndex); // Exorciza o fantasma!
  end;

  if LKey.bDetect in [kd_Down, kd_Wheel] then
  begin
    if (not FShootKeys.Contains(LKey.wKey)) then
      TPGHotKey.FShootKeys.Add(LKey.wKey)
    else
      LKey.bDetect := kd_Press;
  end;

  try
    LHotKey := TPGHotKey.LocateHotKeys(FShootKeys);
    if Assigned(LHotKey) then
    begin
      if LHotKey.Inhibit and (LHotKey.Detect = 0) and (FTypeIndex = 2) then
        Result := True;

      if (LKey.bDetect in [kd_Wheel])
      or (LHotKey.Detect = Byte(LKey.bDetect)) then
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

class procedure TPGHotKey.SetProcessKeys(const ProcessKeys: TProcessKeys);
begin
  if Assigned(ProcessKeys) then
    TPGHotKey.FOnProcessKeys := ProcessKeys
  else
    TPGHotKey.FOnProcessKeys := nil;
end;

class procedure TPGHotKey.SetInputType(const AType: Byte);
begin
  FInputLock.Enter;
  try
    FTypeIndex := AType;
    if Assigned(TPGHotKey.FTypeInput) then
    begin
      TPGHotKey.FTypeInput.Terminate;
      PostThreadMessage(TPGHotKey.FTypeInput.ThreadID, 0, 0, 0);
      TPGHotKey.FTypeInput.WaitFor;
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
          //FTypeIndex := 1;
        {$ENDIF}
      end;
    else
      TPGKernel.ConsoleTr('Ok_HotKey_SetNone');
      FTypeIndex := 0;
    end;
    FInputLock.Leave;
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


initialization


finalization

end.
