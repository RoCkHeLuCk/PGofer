unit PGofer.Services;

interface

uses
  System.SysUtils, System.Rtti, PGofer.Core, PGofer.Classes, PGofer.Runtime;

type
  {$M+}
  [TPGAboutAttribute('Advanced Windows Service Management')]
  [TPGAboutAttribute('Allows control of local or remote services.')]
  TPGService = class( TPGItemClass )
  private
    FMachineName: string;
    FLastError: string;
    procedure CheckResult(ASuccess: Boolean; const AService: string);
  public
    constructor Create( AItemDad: TPGItem; const AName: string = '' ); override;
    property LastError: string read FLastError;
  published

    [TPGAboutAttribute('Target Computer Name or IP Address.')]
    [TPGAboutAttribute('Leave empty for Localhost.')]
    property MachineName: string read FMachineName write FMachineName;

    [TPGAboutAttribute('Creates a new Service. Returns the Service Handle.')]
    [TPGAboutAttribute('Params: ServiceName, DisplayName, ExePath')]
    function Created( const AService, ADisplayName, APathFile: string ): Cardinal;

    [TPGAboutAttribute('Deletes an existing Service. Returns True on success.')]
    [TPGAboutAttribute('Params: ServiceName')]
    function Delete( const AService: string ): Boolean;

    [TPGAboutAttribute('Gets Startup Type. Supports Wildcards (*). Returns Byte or Array of Bytes.')]
    function GetConfig( const AService: string ): TValue;

    [TPGAboutAttribute('Gets the service description text. Supports Wildcards (*). Returns String or Array of Strings.')]
    function GetDescription( const AService: string ): TValue;

    [TPGAboutAttribute('Gets Current Status. Supports Wildcards (*). Returns Byte or Array of Bytes.')]
    function GetState( const AService: string ): TValue;

    [TPGAboutAttribute('Sets Startup Type. Values: 2=Auto, 3=Manual, 4=Disabled. Supports Wildcards (*).')]
    function SetConfig( const AService: string; const AConfig: Byte ): Boolean;

    [TPGAboutAttribute('Sets the service description text. Supports Wildcards (*).')]
    function SetDescription( const AService, ADescription: string ): Boolean;

    [TPGAboutAttribute('Controls Service State. Action: 1=Stop, 4=Start/Continue, 7=Pause. Supports Wildcards (*).')]
    function SetState( const AService: string; const AControl: Byte ): Boolean;

    [TPGAboutAttribute('Waits for service(s) to reach a specific state. Supports Wildcards (*).')]
    [TPGAboutAttribute('Params: ServiceName, TargetState=4 (1=Stop, 4=Run), TimeoutMs=2000')]
    [TPGAboutAttribute('Returns True if state reached, False if Timeout.')]
    function WaitFor( const AService: string; const AState: Byte = 4; const ATimeout: Cardinal = 2000 ): Boolean;
  end;
  {$TYPEINFO ON}

var
  PGService: TPGService;

implementation

uses
  WinApi.Windows,
  PGofer.Services.Controls;

{ TPGService }

constructor TPGService.Create( AItemDad: TPGItem; const AName: string = '' );
begin
  inherited Create( AItemDad, AName );
  FMachineName := '';
  FLastError := '';
end;

procedure TPGService.CheckResult(ASuccess: Boolean; const AService: string);
begin
  if not ASuccess then
  begin
    FLastError := ServiceGetLastErrorMessage;
    // Joga o erro graciosamente no console nativo do PGofer (sem travar a thread)
    TPGKernel.Console(Format('Error Service: Failed on [%s] - %s', [AService, FLastError]));
  end
  else
  begin
    FLastError := '';
  end;
end;

function TPGService.Created( const AService, ADisplayName, APathFile: string ): Cardinal;
begin
  // Criar não usa curinga
  Result := ServiceCreate( FMachineName, AService, ADisplayName, APathFile );
  CheckResult(Result > 0, AService);
end;

function TPGService.Delete( const AService: string ): Boolean;
var
  Lista: TArray<string>;
  NomeReal: string;
  Res: Boolean;
begin
  Result := True;
  Lista := ResolveServiceMask(AService);
  for NomeReal in Lista do
  begin
    Res := ServiceDelete( FMachineName, NomeReal );
    CheckResult(Res, NomeReal);
    if not Res then Result := False;
  end;
end;

function TPGService.GetConfig( const AService: string ): TValue;
var
  Lista: TArray<string>;
  Arr: TArray<TValue>;
  I: Integer;
begin
  Lista := ResolveServiceMask(AService);
  if Length(Lista) = 0 then Exit(TValue.Empty);

  if Length(Lista) = 1 then
    Exit(TValue.From<Byte>(ServiceGetConfig(FMachineName, Lista[0])));

  SetLength(Arr, Length(Lista));
  for I := 0 to High(Lista) do
    Arr[I] := TValue.From<Byte>(ServiceGetConfig(FMachineName, Lista[I]));

  Result := TValue.From<TArray<TValue>>(Arr);
end;

function TPGService.GetDescription( const AService: string ): TValue;
var
  Lista: TArray<string>;
  Arr: TArray<TValue>;
  I: Integer;
begin
  Lista := ResolveServiceMask(AService);
  if Length(Lista) = 0 then Exit(TValue.Empty);

  if Length(Lista) = 1 then
    Exit(TValue.From<string>(ServiceGetDescription(FMachineName, Lista[0])));

  SetLength(Arr, Length(Lista));
  for I := 0 to High(Lista) do
    Arr[I] := TValue.From<string>(ServiceGetDescription(FMachineName, Lista[I]));

  Result := TValue.From<TArray<TValue>>(Arr);
end;

function TPGService.GetState( const AService: string ): TValue;
var
  Lista: TArray<string>;
  Arr: TArray<TValue>;
  I: Integer;
begin
  Lista := ResolveServiceMask(AService);
  if Length(Lista) = 0 then Exit(TValue.Empty);

  if Length(Lista) = 1 then
    Exit(TValue.From<Byte>(ServiceGetState(FMachineName, Lista[0])));

  SetLength(Arr, Length(Lista));
  for I := 0 to High(Lista) do
    Arr[I] := TValue.From<Byte>(ServiceGetState(FMachineName, Lista[I]));

  Result := TValue.From<TArray<TValue>>(Arr);
end;

function TPGService.SetConfig( const AService: string; const AConfig: Byte ): Boolean;
var
  Lista: TArray<string>;
  NomeReal: string;
  Res: Boolean;
begin
  Result := True;
  Lista := ResolveServiceMask(AService);

  if Length(Lista) = 0 then Exit(False);

  for NomeReal in Lista do
  begin
    Res := ServiceSetConfig( FMachineName, NomeReal, AConfig );
    CheckResult(Res, NomeReal);
    if not Res then Result := False; // Se um falhar, o retorno geral é falso, mas continua tentando
  end;
end;

function TPGService.SetDescription( const AService, ADescription: string ): Boolean;
var
  Lista: TArray<string>;
  NomeReal: string;
  Res: Boolean;
begin
  Result := True;
  Lista := ResolveServiceMask(AService);

  if Length(Lista) = 0 then Exit(False);

  for NomeReal in Lista do
  begin
    Res := ServiceSetDescription( FMachineName, NomeReal, ADescription );
    CheckResult(Res, NomeReal);
    if not Res then Result := False;
  end;
end;

function TPGService.SetState( const AService: string; const AControl: Byte ): Boolean;
var
  Lista: TArray<string>;
  NomeReal: string;
  Res: Boolean;
begin
  Result := True;
  Lista := ResolveServiceMask(AService);

  if Length(Lista) = 0 then Exit(False);

  for NomeReal in Lista do
  begin
    Res := ServiceSetState( FMachineName, NomeReal, AControl );
    CheckResult(Res, NomeReal);
    if not Res then Result := False;
  end;
end;

function TPGService.WaitFor( const AService: string; const AState: Byte; const ATimeout: Cardinal ): Boolean;
var
  Start: Cardinal;
  Lista: TArray<string>;
  NomeReal: string;
  AllDone: Boolean;
begin
  Result := False;
  Lista := ResolveServiceMask(AService);

  if Length(Lista) = 0 then Exit(False);

  for NomeReal in Lista do
  begin
    if ServiceGetState( FMachineName, NomeReal ) <> AState then
    begin
      CheckResult(ServiceSetState( FMachineName, NomeReal, AState ), NomeReal);
    end;
  end;

  Start := GetTickCount;

  // Fica no laço esperando TODOS atingirem o estado
  while ( GetTickCount - Start ) < ATimeout do
  begin
    AllDone := True;
    for NomeReal in Lista do
    begin
      if ServiceGetState( FMachineName, NomeReal ) <> AState then
      begin
        AllDone := False;
        Break; // Achou um que ainda não terminou, aborta a checagem atual
      end;
    end;

    if AllDone then
    begin
      Result := True;
      Exit();
    end;

    Sleep( 100 );
  end;

  // Se atingiu o timeout, chora bonito no console
  if not Result then
  begin
    FLastError := 'Timeout atingido aguardando mudança de estado.';
    TPGKernel.Console(Format('Error Service: Timeout on [%s] - %s', [AService, FLastError]));
  end;
end;

initialization

  PGService := TPGService.Create( GlobalItemCommand );

finalization

  PGService := nil;

end.
