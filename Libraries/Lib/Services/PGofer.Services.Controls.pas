unit PGofer.Services.Controls;

interface

function ServiceQueryConfig3( hService: THandle; dwInfoLevel: Cardinal;
   lpBuffer: Pointer; cbBufSize: Cardinal; var pcbBytesNeeded: Cardinal )
   : LongBool; stdcall; external 'advapi32.dll' name 'QueryServiceConfig2W';

function ServiceStatusToAccess( Status: Cardinal ): string;
function ServiceStatusToDrive( Status: Cardinal ): Integer;
function ServiceStatusToState( Status: Cardinal ): string;
function ServiceStatusToSystem( Status: Cardinal ): string;
function ServiceStatusToConfig( Status: Cardinal ): string;
function ServiceSetState( Machine, Service: string; Control: Byte ): Boolean;
function ServiceGetState( Machine, Service: string ): Cardinal;
function ServiceSetConfig( Machine, Service: string; Config: Byte ): Boolean;
function ServiceGetConfig( Machine, Service: string ): Cardinal;
function ServiceDelete( Machine, Service: string ): Boolean;
function ServiceCreate( Machine, Service, DisplayName, PathFile: string )
   : Cardinal;
function ServiceGetDesciption( Machine, Service: string ): string;
function ServiceSetDesciption( Machine, Service, Description: string ): Boolean;

implementation

uses
  WinApi.Windows, WinApi.WinSvc, System.SysUtils;

function ServiceStatusToAccess( Status: Cardinal ): string;
begin
  Result := '';
  if ( Status and SERVICE_ACCEPT_STOP = SERVICE_ACCEPT_STOP ) then
    Result := Result + '"Parar" ';
  if ( Status and SERVICE_ACCEPT_PAUSE_CONTINUE = SERVICE_ACCEPT_PAUSE_CONTINUE )
  then
    Result := Result + '"Pausar" ';
  if ( Status and SERVICE_ACCEPT_SHUTDOWN = SERVICE_ACCEPT_SHUTDOWN ) then
    Result := Result + '"Fechar" ';
  if ( Status and SERVICE_ACCEPT_PARAMCHANGE = SERVICE_ACCEPT_PARAMCHANGE ) then
    Result := Result + '"Configurar" ';
  if ( Status and SERVICE_ACCEPT_NETBINDCHANGE = SERVICE_ACCEPT_NETBINDCHANGE )
  then
    Result := Result + '"Configuração pela Rede" ';
  if ( Status and SERVICE_ACCEPT_HARDWAREPROFILECHANGE =
     SERVICE_ACCEPT_HARDWAREPROFILECHANGE ) then
    Result := Result + '"Configuração pelo Hardware" ';
  if ( Status and SERVICE_ACCEPT_POWEREVENT = SERVICE_ACCEPT_POWEREVENT ) then
    Result := Result + '"Acordar o PC" ';
  if ( Status and SERVICE_ACCEPT_SESSIONCHANGE = SERVICE_ACCEPT_SESSIONCHANGE )
  then
    Result := Result + '"Configuração por Sessões" ';
  if ( Status and SERVICE_ACCEPT_PRESHUTDOWN = SERVICE_ACCEPT_PRESHUTDOWN ) then
    Result := Result + '"Pré Fechamento" ';
  if ( Status and SERVICE_ACCEPT_TIMECHANGE = SERVICE_ACCEPT_TIMECHANGE ) then
    Result := Result + '"Configuração por Tempo" ';
  if ( Status and SERVICE_ACCEPT_TRIGGEREVENT = SERVICE_ACCEPT_TRIGGEREVENT )
  then
    Result := Result + '"Configuração por Tentativa" ';
end;

function ServiceStatusToDrive( Status: Cardinal ): Integer;
begin
  case ( Status ) of
    SERVICE_KERNEL_DRIVER:
    Result := 0;
    SERVICE_FILE_SYSTEM_DRIVER:
    Result := 1;
    SERVICE_ADAPTER:
    Result := 2;
    SERVICE_RECOGNIZER_DRIVER:
    Result := 3;
    SERVICE_WIN32_OWN_PROCESS, 272, 288:
    Result := 4;
    SERVICE_WIN32_SHARE_PROCESS:
    Result := 5;
    SERVICE_INTERACTIVE_PROCESS:
    Result := 6;
  else
  Result := -1;
  end; // case
end;

function ServiceStatusToState( Status: Cardinal ): string;
begin
  case ( Status ) of
    SERVICE_STOPPED:
    Result := 'Parado';
    SERVICE_START_PENDING:
    Result := 'Iniciando...';
    SERVICE_STOP_PENDING:
    Result := 'Parando...';
    SERVICE_RUNNING:
    Result := 'Iniciado';
    SERVICE_CONTINUE_PENDING:
    Result := 'Esperando...';
    SERVICE_PAUSE_PENDING:
    Result := 'Pausando...';
    SERVICE_PAUSED:
    Result := 'Pausado';
  else
  Result := intToStr( Status );
  end; // case
end;

function ServiceStatusToSystem( Status: Cardinal ): string;
begin
  case ( Status ) of
    SERVICE_KERNEL_DRIVER:
    Result := 'Driver Interno';
    SERVICE_FILE_SYSTEM_DRIVER:
    Result := 'Sistema de Arquivos';
    SERVICE_ADAPTER:
    Result := 'Adaptadores';
    SERVICE_RECOGNIZER_DRIVER:
    Result := 'Driver de Reconhecimento';
    SERVICE_DRIVER:
    Result := 'Driver Geral';
    SERVICE_WIN32_OWN_PROCESS, 272, 288:
    Result := 'Serviço Comum';
    SERVICE_WIN32_SHARE_PROCESS:
    Result := 'Serviço Compartilhado';
    SERVICE_WIN32:
    Result := 'Serviço Geral';
    SERVICE_INTERACTIVE_PROCESS:
    Result := 'Interação de Processos';
    SERVICE_TYPE_ALL:
    Result := 'Todos';
  else
  Result := intToStr( Status );
  end; // case
end;

function ServiceStatusToConfig( Status: Cardinal ): string;
begin
  case ( Status ) of
    SERVICE_BOOT_START:
    Result := 'Boot Automatico';
    SERVICE_SYSTEM_START:
    Result := 'Sistema Automatico';
    SERVICE_AUTO_START:
    Result := 'Login Automatico';
    SERVICE_DEMAND_START:
    Result := 'Manual';
    SERVICE_DISABLED:
    Result := 'Desabilitado';
  else
  Result := intToStr( Status );
  end;
end;

function ServiceSetState( Machine, Service: string; Control: Byte ): Boolean;
var
  sc_Machie, sc_Service: SC_Handle;
  ss_Status            : TServiceStatus;
  Tempo                : PChar;
begin
  Result := False;
  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( Machine ), nil,
     SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( Service ), SERVICE_START or
       SERVICE_STOP or SERVICE_PAUSE_CONTINUE or SERVICE_QUERY_STATUS );
    if ( sc_Service > 0 ) then
    begin
      case ( Control ) of
        1:
        Result := ControlService( sc_Service, SERVICE_CONTROL_STOP, ss_Status );
        4:
        begin
          QueryServiceStatus( sc_Service, ss_Status );
          if ss_Status.dwCurrentState = SERVICE_PAUSED then
          begin
            Result := ControlService( sc_Service, SERVICE_CONTROL_CONTINUE,
               ss_Status );
          end else begin
            Tempo := nil;
            Result := StartService( sc_Service, 0, Tempo );
          end; // if paused
        end;
        7:
        Result := ControlService( sc_Service, SERVICE_CONTROL_PAUSE,
           ss_Status );
      end; // case control
      CloseServiceHandle( sc_Service );
    end; // if service
    CloseServiceHandle( sc_Machie );
  end; // if servidor
end;

function ServiceGetState( Machine, Service: string ): Cardinal;
var
  sc_Machie, sc_Service: SC_Handle;
  ss_Status            : TServiceStatus;
begin
  Result := 0;
  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( Machine ), nil,
     SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( Service ),
       SERVICE_QUERY_STATUS );
    if ( sc_Service > 0 ) then
    begin
      if QueryServiceStatus( sc_Service, ss_Status ) then
        Result := ss_Status.dwCurrentState;
      CloseServiceHandle( sc_Service );
    end; // if service
    CloseServiceHandle( sc_Machie );
  end; // if servidor
end;

function ServiceSetConfig( Machine, Service: string; Config: Byte ): Boolean;
var
  sc_Machie, sc_Service: SC_Handle;
begin
  Result := False;
  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( Machine ), nil,
     SC_MANAGER_MODIFY_BOOT_CONFIG );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( Service ),
       SERVICE_CHANGE_CONFIG or SERVICE_QUERY_STATUS );
    if ( sc_Service > 0 ) then
    begin
      // configura
      Result := ChangeServiceConfig( sc_Service, SERVICE_NO_CHANGE, Config,
         SERVICE_ERROR_NORMAL, nil, nil, nil, nil, nil, nil, nil );
      CloseServiceHandle( sc_Service );
    end; // if service
    CloseServiceHandle( sc_Machie );
  end; // if servidor
end;

function ServiceGetConfig( Machine, Service: string ): Cardinal;
var
  sc_Machie, sc_Service: SC_Handle;
  nBytesNeeded         : DWord;
  sConfig              : Pointer;
  pConfig              : PQueryServiceConfigA;
begin
  Result := 0;
  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( Machine ), nil,
     SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( Service ),
       SERVICE_QUERY_STATUS );
    if ( sc_Service > 0 ) then
    begin
      sConfig := nil;
      // pega informações
      if not QueryServiceConfig( sc_Service, sConfig, 0, nBytesNeeded ) then
      begin
        if ( GetLastError = ERROR_INSUFFICIENT_BUFFER ) then
        begin
          GetMem( sConfig, nBytesNeeded );
          if QueryServiceConfig( sc_Service, sConfig, nBytesNeeded, nBytesNeeded )
          then
          begin
            pConfig := PQueryServiceConfigA( sConfig );
            Result := pConfig.dwStartType;
          end;
        end; // if error
      end; // if Query
      CloseServiceHandle( sc_Service );
    end; // if service
    CloseServiceHandle( sc_Machie );
  end; // if servidor
end;

function ServiceDelete( Machine, Service: string ): Boolean;
var
  sc_Machie, sc_Service: SC_Handle;
begin
  Result := False;
  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( Machine ), nil,
     SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( Service ),
       SERVICE_ALL_ACCESS );
    if ( sc_Service > 0 ) then
    begin
      // Deleta;
      Result := DeleteService( sc_Service );
      CloseServiceHandle( sc_Service );
    end; // if service
    CloseServiceHandle( sc_Machie );
  end; // if servidor
end;

function ServiceCreate( Machine, Service, DisplayName, PathFile: string )
   : Cardinal;
var
  sc_Machie: SC_Handle;
begin
  Result := 0;
  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( Machine ), nil,
     SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // cria
    Result := CreateService( sc_Machie, PWideChar( Service ),
       PWideChar( DisplayName ), SERVICE_ALL_ACCESS, SERVICE_WIN32,
       SERVICE_DISABLED, SERVICE_ERROR_NORMAL, PWideChar( PathFile ), nil, nil,
       nil, nil, nil );
    CloseServiceHandle( sc_Machie );
  end; // if servidor
end;

function ServiceGetDesciption( Machine, Service: string ): string;
var
  dwNeeded             : DWord;
  Buffer               : LPSERVICE_DESCRIPTION;
  sc_Machie, sc_Service: SC_Handle;
begin
  Result := '';
  dwNeeded := 0;
  Buffer := nil;
  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( Machine ), nil,
     SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( Service ),
       SERVICE_ALL_ACCESS );
    if ( sc_Service > 0 ) then
    begin
      if ( not ServiceQueryConfig3( sc_Service, 1, nil, 0, dwNeeded ) ) and
         ( GetLastError = ERROR_INSUFFICIENT_BUFFER ) then
      begin
        try
          GetMem( Buffer, dwNeeded );
          if ServiceQueryConfig3( sc_Service, 1, Buffer, dwNeeded, dwNeeded )
          then
            Result := Buffer^.lpDescription;
        finally
          FreeMem( Buffer, dwNeeded );
        end;
      end;
      CloseServiceHandle( sc_Service );
    end; // if service
    CloseServiceHandle( sc_Machie );
  end; // if servidor
end;

function ServiceSetDesciption( Machine, Service, Description: string ): Boolean;
var
  Sc_Buffer            : SERVICE_DESCRIPTION;
  sc_Machie, sc_Service: SC_Handle;
begin
  Result := False;
  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( Machine ), nil,
     SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( Service ),
       SERVICE_ALL_ACCESS );
    if ( sc_Service > 0 ) then
    begin
      Sc_Buffer.lpDescription := PWideChar( Description );
      Result := ChangeServiceConfig2( sc_Service, SERVICE_CONFIG_DESCRIPTION,
         @Sc_Buffer );
      CloseServiceHandle( sc_Service );
    end; // if service
    CloseServiceHandle( sc_Machie );
  end; // if servidor
end;

end.
