unit PGofer.Net.Socket;

interface

uses
  System.Win.ScktComp, PGofer.Classes, PGofer.Sintatico.Classes;

type
  {$M+}
  TPGNetServer = class( TPGItemCMD )
  private
    FServer: TServerSocket;
    FMaxConnect: Word;
    FPassWord: string;
    FLog: Boolean;
    FConsoleMessage: Boolean;
    function GetPort( ): Word;
    procedure SetPort( Port: Word );
    function GetActive( ): Boolean;
    procedure SetActive( Active: Boolean );
    procedure OnClientConnect( Sender: TObject; Socket: TCustomWinSocket );
    procedure OnClientDisconnect( Sender: TObject; Socket: TCustomWinSocket );
    procedure OnClientError( Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer );
    procedure OnClientRead( Sender: TObject; Socket: TCustomWinSocket );
    procedure ConsoleSendMSG( Value: string );
  public
    constructor Create( AItemDad: TPGItem );
    destructor Destroy( ); override;
  published
    property Active: Boolean read GetActive write SetActive;
    property ConsoleMessage: Boolean read FConsoleMessage write FConsoleMessage;
    property Log: Boolean read FLog write FLog;
    property MaxConnect: Word read FMaxConnect write FMaxConnect;
    property PassWord: string read FPassWord write FPassWord;
    property Port: Word read GetPort write SetPort;
    function SendMessage( AText: string ): Integer;
  end;
  {$TYPEINFO ON}
  {$M+}

  TPGNetClient = class( TPGItemCMD )
  private
    FClient: TClientSocket;
    FPassWord: string;
    FConsoleMessage: Boolean;
    function GetPort( ): Word;
    procedure SetPort( Port: Word );
    function GetAddress( ): string;
    procedure SetAddress( Address: string );
    function GetActive( ): Boolean;
    procedure SetActive( Active: Boolean );
    procedure OnClientConnect( Sender: TObject; Socket: TCustomWinSocket );
    procedure OnClientConnecting( Sender: TObject; Socket: TCustomWinSocket );
    procedure OnClientDisconnect( Sender: TObject; Socket: TCustomWinSocket );
    procedure OnClientError( Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer );
    procedure OnClientRead( Sender: TObject; Socket: TCustomWinSocket );
    procedure ConsoleSendMSG( Value: string );

  public
    constructor Create( AItemDad: TPGItem );
    destructor Destroy( ); override;
  published
    property Active: Boolean read GetActive write SetActive;
    property Address: string read GetAddress write SetAddress;
    property ConsoleMessage: Boolean read FConsoleMessage write FConsoleMessage;
    property PassWord: string read FPassWord write FPassWord;
    property Port: Word read GetPort write SetPort;
    function SendCommand( AText: string ): Integer;
  end;
  {$TYPEINFO ON}

implementation

uses
  System.SysUtils,
  PGofer.Sintatico, PGofer.Sintatico.Controls, PGofer.Net.Controls;

{ TPGNetServer }

procedure TPGNetServer.ConsoleSendMSG( Value: string );
begin
  if Assigned( ConsoleNotify ) then
    ConsoleNotify( nil, Value, True, ConsoleMessage );
end;

constructor TPGNetServer.Create( AItemDad: TPGItem );
begin
  inherited Create( AItemDad, 'Server' );

  FServer := TServerSocket.Create( nil );
  FServer.OnAccept := Self.OnClientConnect;
  FServer.OnClientConnect := Self.OnClientConnect;
  FServer.OnClientDisconnect := Self.OnClientDisconnect;
  FServer.OnClientError := Self.OnClientError;
  FServer.OnClientRead := Self.OnClientRead;
  // FServer.Service := 'PGofer';
  FMaxConnect := 0;
  FPassWord := '';
end;

destructor TPGNetServer.Destroy;
begin
  FMaxConnect := 0;
  FPassWord := '';
  FServer.Free;
  inherited Destroy( );
end;

function TPGNetServer.GetActive: Boolean;
begin
  Result := FServer.Active;
end;

procedure TPGNetServer.SetActive( Active: Boolean );
begin
  FServer.Active := Active;
end;

function TPGNetServer.GetPort: Word;
begin
  Result := FServer.Port;
end;

procedure TPGNetServer.SetPort( Port: Word );
begin
  FServer.Port := Port;
end;

function TPGNetServer.SendMessage( AText: string ): Integer;
begin
  Result := FServer.Socket.SendText( AnsiString( AText ) );
end;

procedure TPGNetServer.OnClientConnect( Sender: TObject;
  Socket: TCustomWinSocket );
var
  Texto: string;
begin
  Texto := 'Client Connect: ' + Socket.RemoteAddress;
  Self.ConsoleSendMSG( Texto );

  if FLog then
    NetLogSrvSocket( Texto );

  if FServer.Socket.ActiveConnections > FMaxConnect then
  begin
    Texto := 'Client Denided: MaxConnect.';
    Self.ConsoleSendMSG( Texto );
    if FLog then
      NetLogSrvSocket( Texto );
    Socket.SendText( 'MaxConnect.' );
    Socket.Close;
  end
  else
    Socket.Data := nil;
end;

procedure TPGNetServer.OnClientDisconnect( Sender: TObject;
  Socket: TCustomWinSocket );
var
  Texto: string;
begin
  Texto := 'Client Disconnect: ' + Socket.RemoteAddress;
  Self.ConsoleSendMSG( Texto );
  if FLog then
    NetLogSrvSocket( Texto );
end;

procedure TPGNetServer.OnClientError( Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer );
var
  Texto: string;
begin
  Texto := 'Net Error [' + Socket.RemoteAddress + ']: ' +
    NetErrorToStr( ErrorEvent ) + ' Code: ' + IntToStr( ErrorCode );
  Self.ConsoleSendMSG( Texto );
  if FLog then
    NetLogSrvSocket( Texto );
end;

procedure TPGNetServer.OnClientRead( Sender: TObject;
  Socket: TCustomWinSocket );
var
  Texto: string;
begin

  // ??????????????//otimizar
  Texto := string( Socket.ReceiveText );
  if Socket.Data = nil then
  begin
    if ( Texto = FPassWord ) or ( FPassWord = '' ) then
    begin
      Self.ConsoleSendMSG( 'Client Accepted.' );
      Socket.SendText( 'Client Accepted.' );
      Socket.Data := Socket;
      if FLog then
        NetLogSrvSocket( 'Client Accepted [' + Socket.RemoteAddress +
          '] Password: ' + Texto );
    end else begin
      Self.ConsoleSendMSG( 'Client Denided: Invalid Password.' );
      Socket.SendText( 'Invalid Password.' );
      Socket.Close;
      if FLog then
        NetLogSrvSocket( 'Client Denided [' + Socket.RemoteAddress +
          '] Invalid Password: ' + Texto );
    end;
  end else begin
    if Texto <> '' then
    begin
      Self.ConsoleSendMSG( 'Clinet Send Command, Server Working...' );
      ScriptExec( 'Remote: ' + Socket.RemoteAddress, Texto );
      if FLog then
        NetLogSrvSocket( 'Client [' + Socket.RemoteAddress + '] Resceive Text: '
          + Texto );
    end;
  end;
end;

{ TPGNetClient }

procedure TPGNetClient.ConsoleSendMSG( Value: string );
begin
  if Assigned( ConsoleNotify ) then
    ConsoleNotify( nil, Value, True, ConsoleMessage );
end;

constructor TPGNetClient.Create( AItemDad: TPGItem );
begin
  inherited Create( AItemDad, 'Client' );

  FClient := TClientSocket.Create( nil );
  FClient.OnConnecting := Self.OnClientConnecting;
  FClient.OnConnect := Self.OnClientConnect;
  FClient.OnDisconnect := Self.OnClientDisconnect;
  FClient.OnRead := Self.OnClientRead;
  FClient.OnError := Self.OnClientError;
  FPassWord := '';
end;

destructor TPGNetClient.Destroy;
begin
  FPassWord := '';
  FClient.OnConnecting := nil;
  FClient.OnConnect := nil;
  FClient.OnDisconnect := nil;
  FClient.OnRead := nil;
  FClient.OnError := nil;
  FClient.Free;
  inherited Destroy( );
end;

function TPGNetClient.GetActive: Boolean;
begin
  Result := FClient.Active;
end;

procedure TPGNetClient.SetActive( Active: Boolean );
begin
  FClient.Active := Active;
end;

function TPGNetClient.GetAddress: string;
begin
  Result := FClient.Address;
end;

procedure TPGNetClient.SetAddress( Address: string );
begin
  FClient.Address := Address;
end;

function TPGNetClient.GetPort: Word;
begin
  Result := FClient.Port;
end;

procedure TPGNetClient.SetPort( Port: Word );
begin
  FClient.Port := Port;
end;

function TPGNetClient.SendCommand( AText: string ): Integer;
begin
  Result := FClient.Socket.SendText( AnsiString( AText ) );
end;

procedure TPGNetClient.OnClientConnect( Sender: TObject;
  Socket: TCustomWinSocket );
begin
  Self.ConsoleSendMSG( 'Connect to Server.' );
  FClient.Socket.SendText( AnsiString( FPassWord ) );
end;

procedure TPGNetClient.OnClientConnecting( Sender: TObject;
  Socket: TCustomWinSocket );
begin
  Self.ConsoleSendMSG( 'Connecting to Server...' );
end;

procedure TPGNetClient.OnClientDisconnect( Sender: TObject;
  Socket: TCustomWinSocket );
begin
  Self.ConsoleSendMSG( 'Disconnect from Server...' );
end;

procedure TPGNetClient.OnClientError( Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer );
var
  Texto: string;
begin
  Texto := 'Net Error [' + Socket.RemoteAddress + ']: ' +
    NetErrorToStr( ErrorEvent ) + ' Code: ' + IntToStr( ErrorCode );
  Self.ConsoleSendMSG( Texto );
end;

procedure TPGNetClient.OnClientRead( Sender: TObject;
  Socket: TCustomWinSocket );
begin
  Self.ConsoleSendMSG( 'Message from Server: ' + string( Socket.ReceiveText ) );
end;

end.
