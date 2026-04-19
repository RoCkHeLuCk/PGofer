unit PGofer.Services.Controls;

interface

function ServiceQueryConfig3( hService: THandle; dwInfoLevel: Cardinal;
  lpBuffer: Pointer; cbBufSize: Cardinal; var pcbBytesNeeded: Cardinal )
  : LongBool; stdcall; external 'advapi32.dll' name 'QueryServiceConfig2W';

// Novas funções expostas para o sistema
function ResolveServiceMask(const AMask: string): TArray<string>;
function ServiceGetLastErrorMessage: string;

// Todas as strings e tipos primitivos de entrada agora usam "const"
function ServiceStatusToAccess( const AStatus: Cardinal ): string;
function ServiceStatusToDrive( const AStatus: Cardinal ): Integer;
function ServiceStatusToState( const AStatus: Cardinal ): string;
function ServiceStatusToSystem( const AStatus: Cardinal ): string;
function ServiceStatusToConfig( const AStatus: Cardinal ): string;
function ServiceSetState( const AMachine, AService: string; const Control: Byte ): Boolean;
function ServiceGetState( const AMachine, AService: string ): Cardinal;
function ServiceSetConfig( const AMachine, AService: string; const Config: Byte ): Boolean;
function ServiceGetConfig( const AMachine, AService: string ): Cardinal;
function ServiceDelete( const AMachine, AService: string ): Boolean;
function ServiceCreate( const AMachine, AService, ADisplayName, APathFile: string )
  : Cardinal;
function ServiceGetDescription( const AMachine, AService: string ): string;
function ServiceSetDescription( const AMachine, AService, ADescription: string ): Boolean;

implementation

uses
  WinApi.Windows, WinApi.WinSvc,
  System.SysUtils, System.Win.Registry, System.Classes, System.Masks; // Classes e Masks adicionados

const
  REG_SERVICES_LOCATION =
    'SYSTEM\CurrentControlSet\Services\';

threadvar
  _LastServiceErrorCode: DWORD;

function ServiceGetLastErrorMessage: string;
begin
  if _LastServiceErrorCode = 0 then
    Result := ''
  else
    Result := SysErrorMessage(_LastServiceErrorCode);
end;

function ResolveServiceMask(const AMask: string): TArray<string>;
var
  Reg: TRegistry;
  Keys: TStringList;
  I: Integer;
begin
  SetLength(Result, 0);

  // Se não tem máscara, devolve um array com 1 posição contendo o nome exato
  if Pos('*', AMask) = 0 then
  begin
    SetLength(Result, 1);
    Result[0] := AMask;
    Exit;
  end;

  Reg := TRegistry.Create(KEY_READ);
  Keys := TStringList.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly(REG_SERVICES_LOCATION) then
    begin
      Reg.GetKeyNames(Keys);
      for I := 0 to Keys.Count - 1 do
      begin
        if MatchesMask(Keys[I], AMask) then
        begin
          // Adiciona cada clone encontrado à lista
          SetLength(Result, Length(Result) + 1);
          Result[High(Result)] := Keys[I];
        end;
      end;
    end;
  finally
    Keys.Free;
    Reg.Free;
  end;
end;

function ServiceStatusToAccess( const AStatus: Cardinal ): string;
begin
  Result := '';
  if ( AStatus and SERVICE_ACCEPT_STOP = SERVICE_ACCEPT_STOP ) then
    Result := Result + '"Parar" ';
  if ( AStatus and SERVICE_ACCEPT_PAUSE_CONTINUE = SERVICE_ACCEPT_PAUSE_CONTINUE )
  then
    Result := Result + '"Pausar" ';
  if ( AStatus and SERVICE_ACCEPT_SHUTDOWN = SERVICE_ACCEPT_SHUTDOWN ) then
    Result := Result + '"Fechar" ';
  if ( AStatus and SERVICE_ACCEPT_PARAMCHANGE = SERVICE_ACCEPT_PARAMCHANGE ) then
    Result := Result + '"Configurar" ';
  if ( AStatus and SERVICE_ACCEPT_NETBINDCHANGE = SERVICE_ACCEPT_NETBINDCHANGE )
  then
    Result := Result + '"Configuração pela Rede" ';
  if ( AStatus and SERVICE_ACCEPT_HARDWAREPROFILECHANGE =
    SERVICE_ACCEPT_HARDWAREPROFILECHANGE ) then
    Result := Result + '"Configuração pelo Hardware" ';
  if ( AStatus and SERVICE_ACCEPT_POWEREVENT = SERVICE_ACCEPT_POWEREVENT ) then
    Result := Result + '"Acordar o PC" ';
  if ( AStatus and SERVICE_ACCEPT_SESSIONCHANGE = SERVICE_ACCEPT_SESSIONCHANGE )
  then
    Result := Result + '"Configuração por Sessões" ';
  if ( AStatus and SERVICE_ACCEPT_PRESHUTDOWN = SERVICE_ACCEPT_PRESHUTDOWN ) then
    Result := Result + '"Pré Fechamento" ';
  if ( AStatus and SERVICE_ACCEPT_TIMECHANGE = SERVICE_ACCEPT_TIMECHANGE ) then
    Result := Result + '"Configuração por Tempo" ';
  if ( AStatus and SERVICE_ACCEPT_TRIGGEREVENT = SERVICE_ACCEPT_TRIGGEREVENT )
  then
    Result := Result + '"Configuração por Tentativa" ';
end;

function ServiceStatusToDrive( const AStatus: Cardinal ): Integer;
begin
  case ( AStatus ) of
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

function ServiceStatusToState( const AStatus: Cardinal ): string;
begin
  case ( AStatus ) of
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
    Result := IntToStr( AStatus );
  end; // case
end;

function ServiceStatusToSystem( const AStatus: Cardinal ): string;
begin
  case ( AStatus ) of
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
    Result := IntToStr( AStatus );
  end; // case
end;

function ServiceStatusToConfig( const AStatus: Cardinal ): string;
begin
  case ( AStatus ) of
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
    Result := IntToStr( AStatus );
  end;
end;

function ServiceSetState( const AMachine, AService: string; const Control: Byte ): Boolean;
var
  sc_Machie, sc_Service: SC_Handle;
  ss_Status: TServiceStatus;
  Tempo: PChar;
begin
  Result := False;
  _LastServiceErrorCode := 0;

  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( AMachine ), nil,
    SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( AService ), SERVICE_START or
      SERVICE_STOP or SERVICE_PAUSE_CONTINUE or SERVICE_QUERY_STATUS );
    if ( sc_Service > 0 ) then
    begin
      case ( Control ) of
        1:
          Result := ControlService( sc_Service, SERVICE_CONTROL_STOP,
            ss_Status );
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

      if not Result then _LastServiceErrorCode := GetLastError;

      CloseServiceHandle( sc_Service );
    end else _LastServiceErrorCode := GetLastError;

    CloseServiceHandle( sc_Machie );
  end else _LastServiceErrorCode := GetLastError;
end;

function ServiceGetState( const AMachine, AService: string ): Cardinal;
var
  sc_Machie, sc_Service: SC_Handle;
  ss_Status: TServiceStatus;
begin
  Result := 0;
  _LastServiceErrorCode := 0;

  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( AMachine ), nil,
    SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( AService ),
      SERVICE_QUERY_STATUS );
    if ( sc_Service > 0 ) then
    begin
      if QueryServiceStatus( sc_Service, ss_Status ) then
        Result := ss_Status.dwCurrentState
      else
        _LastServiceErrorCode := GetLastError;

      CloseServiceHandle( sc_Service );
    end else _LastServiceErrorCode := GetLastError;

    CloseServiceHandle( sc_Machie );
  end else _LastServiceErrorCode := GetLastError;
end;

function ServiceSetConfig( const AMachine, AService: string; const Config: Byte ): Boolean;
var
  sc_Machie, sc_Service: SC_Handle;
  Reg: TRegistry;
begin
  Result := False;
  _LastServiceErrorCode := 0;

  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( AMachine ), nil,
    SC_MANAGER_MODIFY_BOOT_CONFIG );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( AService ),
      SERVICE_CHANGE_CONFIG or SERVICE_QUERY_STATUS );
    if ( sc_Service > 0 ) then
    begin
      // configura
      Result := ChangeServiceConfig( sc_Service, SERVICE_NO_CHANGE, Config,
        SERVICE_ERROR_NORMAL, nil, nil, nil, nil, nil, nil, nil );

      if not Result then _LastServiceErrorCode := GetLastError;

      CloseServiceHandle( sc_Service );
    end else _LastServiceErrorCode := GetLastError;

    CloseServiceHandle( sc_Machie );
  end else _LastServiceErrorCode := GetLastError;

  // Força no registro se a API falhar
  if not Result then
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if ( Reg.OpenKey( REG_SERVICES_LOCATION + AService, True ) ) then
      begin
        if not Reg.ValueExists( 'Start' ) then
          Reg.CreateKey( 'Start' );
        Reg.WriteInteger( 'Start', Config );
        Result := True;
        _LastServiceErrorCode := 0; // Limpa o erro, pois forçamos com sucesso
      end;
    finally
      Reg.free;
    end;
  end;
end;

function ServiceGetConfig( const AMachine, AService: string ): Cardinal;
var
  sc_Machie, sc_Service: SC_Handle;
  nBytesNeeded: DWord;
  sConfig: Pointer;
  pConfig: PQueryServiceConfigA;
begin
  Result := 0;
  _LastServiceErrorCode := 0;

  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( AMachine ), nil,
    SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( AService ),
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
          try // <-- INÍCIO DA BLINDAGEM DE MEMÓRIA
            if QueryServiceConfig( sc_Service, sConfig, nBytesNeeded, nBytesNeeded )
            then
            begin
              pConfig := PQueryServiceConfigA( sConfig );
              Result := pConfig.dwStartType;
            end else _LastServiceErrorCode := GetLastError;
          finally
            FreeMem( sConfig, nBytesNeeded ); // <-- O ASSASSINO DE LEAKS AQUI!
          end;
        end else _LastServiceErrorCode := GetLastError;
      end;
      CloseServiceHandle( sc_Service );
    end else _LastServiceErrorCode := GetLastError;

    CloseServiceHandle( sc_Machie );
  end else _LastServiceErrorCode := GetLastError;
end;

function ServiceDelete( const AMachine, AService: string ): Boolean;
var
  sc_Machie, sc_Service: SC_Handle;
begin
  Result := False;
  _LastServiceErrorCode := 0;

  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( AMachine ), nil,
    SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( AService ),
      SERVICE_ALL_ACCESS );
    if ( sc_Service > 0 ) then
    begin
      // Deleta;
      Result := DeleteService( sc_Service );
      if not Result then _LastServiceErrorCode := GetLastError;
      CloseServiceHandle( sc_Service );
    end else _LastServiceErrorCode := GetLastError;

    CloseServiceHandle( sc_Machie );
  end else _LastServiceErrorCode := GetLastError;
end;

function ServiceCreate( const AMachine, AService, ADisplayName, APathFile: string )
  : Cardinal;
var
  sc_Machie: SC_Handle;
begin
  Result := 0;
  _LastServiceErrorCode := 0;

  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( AMachine ), nil,
    SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // cria
    Result := CreateService( sc_Machie, PWideChar( AService ),
      PWideChar( ADisplayName ), SERVICE_ALL_ACCESS, SERVICE_WIN32,
      SERVICE_DISABLED, SERVICE_ERROR_NORMAL, PWideChar( APathFile ), nil, nil,
      nil, nil, nil );

    if Result = 0 then _LastServiceErrorCode := GetLastError;

    CloseServiceHandle( sc_Machie );
  end else _LastServiceErrorCode := GetLastError;
end;

function ServiceGetDescription( const AMachine, AService: string ): string;
var
  dwNeeded: DWord;
  Buffer: LPSERVICE_DESCRIPTION;
  sc_Machie, sc_Service: SC_Handle;
begin
  Result := '';
  _LastServiceErrorCode := 0;
  dwNeeded := 0;
  Buffer := nil;

  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( AMachine ), nil,
    SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( AService ),
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
            Result := Buffer^.lpDescription
          else
            _LastServiceErrorCode := GetLastError;
        finally
          FreeMem( Buffer, dwNeeded );
        end;
      end else if GetLastError <> ERROR_INSUFFICIENT_BUFFER then
        _LastServiceErrorCode := GetLastError;

      CloseServiceHandle( sc_Service );
    end else _LastServiceErrorCode := GetLastError;

    CloseServiceHandle( sc_Machie );
  end else _LastServiceErrorCode := GetLastError;
end;

function ServiceSetDescription( const AMachine, AService, ADescription: string ): Boolean;
var
  Sc_Buffer: SERVICE_DESCRIPTION;
  sc_Machie, sc_Service: SC_Handle;
begin
  Result := False;
  _LastServiceErrorCode := 0;

  // abre a maquina
  sc_Machie := OpenSCManager( PWideChar( AMachine ), nil,
    SC_MANAGER_ALL_ACCESS );
  if ( sc_Machie > 0 ) then
  begin
    // abre o serviço
    sc_Service := OpenService( sc_Machie, PWideChar( AService ),
      SERVICE_ALL_ACCESS );
    if ( sc_Service > 0 ) then
    begin
      Sc_Buffer.lpDescription := PWideChar( ADescription );
      Result := ChangeServiceConfig2( sc_Service, SERVICE_CONFIG_DESCRIPTION,
        @Sc_Buffer );

      if not Result then _LastServiceErrorCode := GetLastError;

      CloseServiceHandle( sc_Service );
    end else _LastServiceErrorCode := GetLastError;

    CloseServiceHandle( sc_Machie );
  end else _LastServiceErrorCode := GetLastError;
end;

end.
