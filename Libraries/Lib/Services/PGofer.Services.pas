unit PGofer.Services;

interface

uses
  PGofer.Core, PGofer.Classes, PGofer.Runtime;

type
  {$M+}
  [TPGAboutAttribute('Advanced Windows Service Management')]
  [TPGAboutAttribute('Allows control of local or remote services.')]
  TPGService = class( TPGItemClass )
  private
    FMachineName: string;
  public
    constructor Create( AItemDad: TPGItem; const AName: string = '' ); override;
  published

    [TPGAboutAttribute('Target Computer Name or IP Address.')]
    [TPGAboutAttribute('Leave empty for Localhost.')]
    property MachineName: string read FMachineName write FMachineName;

    [TPGAboutAttribute('Creates a new Service. Returns the Service Handle.')]
    [TPGAboutAttribute('Params: ServiceName, DisplayName, ExePath')]
    function Created( AService, ADisplayName, APathFile: string ): Cardinal;

    [TPGAboutAttribute('Deletes an existing Service. Returns True on success.')]
    [TPGAboutAttribute('Params: ServiceName')]
    function Delete( AService: string ): Boolean;

    [TPGAboutAttribute('Gets Startup Type. Returns: 2=Auto, 3=Manual, 4=Disabled, 0=Boot, 1=System')]
    function GetConfig( AService: string ): Byte;

    [TPGAboutAttribute('Gets the service description text.')]
    function GetDescription( AService: string ): string;

    [TPGAboutAttribute('Gets Current Status. Returns: 1=Stopped, 4=Running, 7=Paused')]
    function GetState( AService: string ): Byte;

    [TPGAboutAttribute('Sets Startup Type. Values: 2=Auto, 3=Manual, 4=Disabled')]
    function SetConfig( AService: string; AConfig: Byte ): Boolean;

    [TPGAboutAttribute('Sets the service description text.')]
    function SetDescription( AService, ADescription: string ): Boolean;

    [TPGAboutAttribute('Controls Service State. Action: 1=Stop, 4=Start/Continue, 7=Pause')]
    function SetState( AService: string; AControl: Byte ): Boolean;

    [TPGAboutAttribute('Waits for service to reach a specific state.')]
    [TPGAboutAttribute('Params: ServiceName, TargetState=4 (1=Stop, 4=Run), TimeoutMs=2000')]
    [TPGAboutAttribute('Returns True if state reached, False if Timeout.')]
    function WaitFor( AService: string; AState: Byte = 4; ATimeout: Cardinal = 2000 ): Boolean;
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
end;

function TPGService.Created( AService, ADisplayName, APathFile: string ): Cardinal;
begin
  Result := ServiceCreate( FMachineName, AService, ADisplayName, APathFile );
end;

function TPGService.Delete( AService: string ): Boolean;
begin
  Result := ServiceDelete( FMachineName, AService );
end;

function TPGService.GetConfig( AService: string ): Byte;
begin
  Result := ServiceGetConfig( FMachineName, AService );
end;

function TPGService.GetDescription( AService: string ): string;
begin
  Result := ServiceGetDescription( FMachineName, AService );
end;

function TPGService.GetState( AService: string ): Byte;
begin
  Result := ServiceGetState( FMachineName, AService );
end;

function TPGService.SetConfig( AService: string; AConfig: Byte ): Boolean;
begin
  Result := ServiceSetConfig( FMachineName, AService, AConfig );
end;

function TPGService.SetDescription( AService, ADescription: string ): Boolean;
begin
  Result := ServiceSetDescription( FMachineName, AService, ADescription );
end;

function TPGService.SetState( AService: string; AControl: Byte ): Boolean;
begin
  Result := ServiceSetState( FMachineName, AService, AControl );
end;

function TPGService.WaitFor( AService: string; AState: Byte; ATimeout: Cardinal ): Boolean;
var
  Start: Cardinal;
begin
  Result := False;
  Start := GetTickCount;
  ServiceSetState( FMachineName, AService, AState );
  while ( GetTickCount - Start ) < ATimeout do
  begin
    if ServiceGetState( FMachineName, AService ) = AState then
    begin
      Result := True;
      Exit();
    end;
    Sleep( 100 );
  end;
end;

initialization

  PGService := TPGService.Create( GlobalItemCommand );

finalization

  PGService := nil;

end.
