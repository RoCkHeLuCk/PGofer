unit PGofer.Triggers.HotKeys;

interface

uses
  System.Classes,
  System.Generics.Collections,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers, PGofer.Triggers.HotKeys.Controls;

type

{$M+}
  TPGHotKey = class(TPGItemTrigger)
  private
    FKeys: TList<Word>;
    FDetect: Byte;
    FInhibit: Boolean;
    FScript: TStrings;
    class var FShootKeys: TList<Word>;
    class var FOnProcessKeys: TProcessKeys;
    class function LocateHotKeys(Keys: TList<Word>): TPGHotKey;
    class procedure DefaultOnProcessKeys(AParamInput: TParamInput);
    function GetKeysHex(): string;
    function GetScript: string;
    procedure SetKeysHex(AValue: string);
    procedure SetScript(const AValue: string);
  protected
    procedure ExecuteWithArgs(Gramatica: TGramatica); override;
  public
    constructor Create(AName: string; AMirror: TPGItemMirror); overload;
    destructor Destroy(); override;
    class var GlobList: TPGItem;
    procedure Frame(AParent: TObject); override;
    property Keys: TList<Word> read FKeys;
    function GetKeysName(): string;
    procedure Triggering(); override;
    class procedure OnProcessKeys(AParamInput: TParamInput);
    class procedure SetProcessKeys(ProcessKeys: TProcessKeys = nil);
  published
    property HotKeysHex: string read GetKeysHex write SetKeysHex;
    property Detect: Byte read FDetect write FDetect;
    property Inhibit: Boolean read FInhibit write FInhibit;
    property Script: string read GetScript write SetScript;
  end;
{$TYPEINFO ON}

  TPGHotKeyDeclare = class(TPGItemClass)
  private
    class var FTypeInput: TThread;
    class var FTypeIndex: Byte;
  protected
  public
    constructor Create(AItemDad: TPGItem; AName: string = ''; AType: Integer = 0); reintroduce; overload;
    destructor Destroy(); override;
    procedure Execute(Gramatica: TGramatica); override;
    class procedure SetInput(AType: Byte);
    class function GetInput(): Byte;
  published
    [TPGAttribText('0:None; 1:AsyncInput; 2:THookInput; 3:RawInput;')]
    property InputType: Byte read GetInput write SetInput;
    procedure InputRestart();
    procedure ShootKeysList();
  end;

  TPGHotKeyMirror = class(TPGItemMirror)
  protected
  public
    class function ClassNameEx(): String; override;
    constructor Create(AItemDad: TPGItem; AName: string = ''); override;
    procedure Frame(AParent: TObject); override;
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
  PGofer.Triggers.HotKeys.Hook,
  PGofer.Triggers.HotKeys.RawInput;

{ TPGHotKeyMain }

constructor TPGHotKey.Create(AName: string; AMirror: TPGItemMirror);
begin
  inherited Create(TPGHotKey.GlobList, AName, AMirror);
  Self.ReadOnly := False;
  FKeys := TList<Word>.Create;
  FKeys.Capacity := 20;
  FDetect := 0;
  FInhibit := False;
  FScript := TStringList.Create;
end;

destructor TPGHotKey.Destroy();
begin
  FDetect := 0;
  FInhibit := False;
  FScript.Free;
  FScript := nil;
  FKeys.Clear;
  FKeys.Free;
  FKeys := nil;
  inherited Destroy();
end;

procedure TPGHotKey.ExecuteWithArgs(Gramatica: TGramatica);
begin
  ScriptExec('HotKey: ' + Self.Name, Self.Script, Gramatica.Local);
end;

procedure TPGHotKey.Frame(AParent: TObject);
begin
  TPGHotKeyFrame.Create(Self, AParent);
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

procedure TPGHotKey.SetScript(const AValue: string);
begin
  FScript.Text := AValue;
end;

procedure TPGHotKey.Triggering();
begin
  ScriptExec('HotKey: ' + Self.Name, Self.Script, nil, False);
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

function TPGHotKey.GetScript: string;
begin
  Result := FScript.Text;
end;

class function TPGHotKey.LocateHotKeys(Keys: TList<Word>): TPGHotKey;
var
  LKeysCount: Word;
  LListCount: Word;
  LAuxHotKeys: TPGHotKey;
  LCount1, LCount2: Word;
  LFind: Boolean;
begin
  Result := nil;
  if not Assigned(Keys)then Exit;

  LKeysCount := Keys.Count;
  if LKeysCount <= 1 then Exit;

  LListCount := TPGHotKey.GlobList.Count;
  if LListCount < 1 then Exit;

  for LCount1 := 0 to LListCount-1 do
  begin
    LAuxHotKeys := TPGHotKey(TPGHotKey.GlobList[LCount1]);
    if LAuxHotKeys.Enabled and (LAuxHotKeys.FKeys.Count = LKeysCount) then
    begin
      LFind := True;
      for LCount2 := 0 to LKeysCount-1 do
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

class procedure TPGHotKey.OnProcessKeys(AParamInput: TParamInput);
begin
  if Assigned(TPGHotKey.FOnProcessKeys) then
  begin
    TPGHotKey.FOnProcessKeys(AParamInput);
  end else begin
    TPGHotKey.DefaultOnProcessKeys(AParamInput);
  end;
end;

class procedure TPGHotKey.DefaultOnProcessKeys(AParamInput: TParamInput);
var
  LKey: TKey;
  LHotKey: TPGHotKey;
begin
  LKey := TKey.CalcVirtualKey(AParamInput);

  if LKey.wKey > 0 then
  begin
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
        if ((LKey.bDetect = kd_Wheel) or (LHotKey.Detect = Byte(LKey.bDetect))) then
        begin
          LHotKey.Triggering();
        end;
      end;
    finally
      if LKey.bDetect in [kd_Up, kd_Wheel] then
        TPGHotKey.FShootKeys.Remove(LKey.wKey);
    end;
  end; // if key #0
end;

class procedure TPGHotKey.SetProcessKeys(ProcessKeys: TProcessKeys);
begin
  if Assigned(ProcessKeys) then
  begin
    TPGHotKey.FOnProcessKeys := ProcessKeys;
  end else begin
    TPGHotKey.FOnProcessKeys := nil;
  end;
end;

{ TPGHotKeyDeclare }
constructor TPGHotKeyDeclare.Create(AItemDad: TPGItem; AName: string = ''; AType: Integer = 0);
begin
  inherited Create(AItemDad, AName);
  FTypeIndex := 0;
  if AType > 0 then
    Self.SetInput(AType);
end;

destructor TPGHotKeyDeclare.Destroy();
begin
  TPGHotKeyDeclare.SetInput(0);
  inherited Destroy();
end;

class procedure TPGHotKeyDeclare.SetInput(AType: Byte);
begin
  FTypeIndex := AType;
  try
    if Assigned(TPGHotKeyDeclare.FTypeInput) then
    begin
      TPGHotKeyDeclare.FTypeInput.Free();
      TPGHotKeyDeclare.FTypeInput := nil;
      TPGHotKey.FShootKeys.Clear;
    end;
  finally
    case FTypeIndex of
      1:begin
          TPGHotKeyDeclare.FTypeInput := TAsyncInput.Create();
          TPGKernel.ConsoleTr( 'Ok_HotKey_SetAsyncInput' );
        end;

      2:begin
          {$IFNDEF DEBUG}
            TPGHotKeyDeclare.FTypeInput := THookInput.Create();
            TPGKernel.ConsoleTr( 'Ok_HotKey_SetHookInput' );
          {$ELSE}
            TPGKernel.Console( 'ERROR: Debug mode, Not set HookInput.' );
            FTypeIndex := 0;
          {$ENDIF}
        end;

      3:begin
          TPGHotKeyDeclare.FTypeInput := TRawInput.Create();
          TPGKernel.ConsoleTr( 'Ok_HotKey_SetRawInput' );
        end;
    else
       TPGKernel.ConsoleTr( 'Ok_HotKey_SetNone' );
    end;
  end;
end;

procedure TPGHotKeyDeclare.ShootKeysList;
var
   LKey : Word;
begin
   TPGKernel.Console('**** ShootKeysList Start ****',False);
   for LKey in TPGHotKey.FShootKeys do
   begin
      TPGKernel.Console('  ['+LKey.ToString()+'] - '+KeyVirtualToStr(LKey),False);
   end;
   TPGKernel.Console('**** ShootKeysList End ****',False);
end;

procedure TPGHotKeyDeclare.Execute(Gramatica: TGramatica);
var
  Titulo: string;
  Quantidade: Byte;
  HotKey: TPGHotKey;
  LPGItem : TPGItem;
begin
  if Self.TryExecuteChild(Gramatica) then
    Exit;

  LPGItem := IdentificadorLocalizar(Gramatica);
  if (not Assigned(LPGItem)) or (LPGItem is TPGHotKey) then
  begin
    Titulo := Gramatica.TokenList.Token.Lexema;
    Quantidade := LerParamentros(Gramatica, 1, 4);
    if not Gramatica.Erro then
    begin
      if (not Assigned(LPGItem)) then
        HotKey := TPGHotKey.Create(Titulo, nil)
      else
        HotKey := TPGHotKey(LPGItem);

      if Quantidade = 4 then
        HotKey.Detect := Gramatica.Pilha.Desempilhar(0);

      if Quantidade >= 3 then
        HotKey.Inhibit := Gramatica.Pilha.Desempilhar(False);

      if Quantidade >= 2 then
        HotKey.SetKeysHex(Gramatica.Pilha.Desempilhar(''));

      if Quantidade >= 1 then
        HotKey.Script := Gramatica.Pilha.Desempilhar('');
    end;
  end else
    Gramatica.ErroAdd( 'Error_Interpreter_IdExist' );
end;

class function TPGHotKeyDeclare.GetInput(): Byte;
begin
   Result := FTypeIndex;
end;

procedure TPGHotKeyDeclare.InputRestart( );
begin
  Self.InputType := FTypeIndex;
end;

{ TPGHotKeysMirror }

constructor TPGHotKeyMirror.Create(AItemDad: TPGItem; AName: string);
begin
  if AName = '' then AName := 'NewHotKey';
  AName := TPGItemMirror.TranscendName(AName, TPGHotKey.GlobList);
  inherited Create(AItemDad, TPGHotKey.Create(AName, Self));
end;

procedure TPGHotKeyMirror.Frame(AParent: TObject);
begin
  TPGHotKeyFrame.Create(Self.ItemOriginal, AParent);
end;

class function TPGHotKeyMirror.ClassNameEx: String;
begin
  Result := TPGHotKey.ClassNameEx();
end;

initialization

TPGHotKey.FShootKeys := TList<Word>.Create();
TPGHotKey.FOnProcessKeys := nil;

TPGHotKeyDeclare.Create(GlobalItemCommand, 'HotKey', 3);
TPGHotKey.GlobList := TPGFolder.Create(GlobalItemTrigger, 'HotKeys');

TriggersCollect.RegisterClass( TPGHotKeyMirror );

finalization

TPGHotKeyDeclare.SetInput(0);
TPGHotKey.FOnProcessKeys := nil;
TPGHotKey.FShootKeys.Free();
TPGHotKey.FShootKeys := nil;

end.
