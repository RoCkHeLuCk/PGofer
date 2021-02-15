unit PGofer.Net.Socket;

interface

uses
    System.Win.ScktComp, PGofer.Sintatico.Classes;
type
{$M+}
    TPGNetServer = class(TPGItemCMD)
    private
        FServer: TServerSocket;
        FMaxConnect: Word;
        FPassWord: String;
        FLog: Boolean;
        function GetPort(): Word;
        procedure SetPort(Port: Word);
        function GetActive(): Boolean;
        procedure SetActive(Active: Boolean);

        procedure OnClientConnect(Sender: TObject; Socket: TCustomWinSocket);
        procedure OnClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
        procedure OnClientError(Sender: TObject; Socket: TCustomWinSocket;
            ErrorEvent: TErrorEvent; var ErrorCode: Integer);
        procedure OnClientRead(Sender: TObject; Socket: TCustomWinSocket);
    public
        constructor Create();
        destructor Destroy(); override;
    published
        property Active: Boolean read GetActive write SetActive;
        property Log: Boolean read FLog write FLog;
        property MaxConnect: Word read FMaxConnect write FMaxConnect;
        property PassWord: String read FPassWord write FPassWord;
        property Port: Word read GetPort write SetPort;
        function SendMessage(Text: String): Integer;
    end;
{$TYPEINFO ON}
{$M+}
    TPGNetClient = class(TPGItemCMD)
    private
        FClient: TClientSocket;
        FPassWord: String;

        function GetPort(): Word;
        procedure SetPort(Port: Word);
        function GetAddress(): String;
        procedure SetAddress(Address: String);
        function GetActive(): Boolean;
        procedure SetActive(Active: Boolean);

        procedure OnClientConnect(Sender: TObject; Socket: TCustomWinSocket);
        procedure OnClientConnecting(Sender: TObject; Socket: TCustomWinSocket);
        procedure OnClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
        procedure OnClientError(Sender: TObject; Socket: TCustomWinSocket;
            ErrorEvent: TErrorEvent; var ErrorCode: Integer);
        procedure OnClientRead(Sender: TObject; Socket: TCustomWinSocket);
    public
        constructor Create();
        destructor Destroy(); override;
    published
        property Active: Boolean read GetActive write SetActive;
        property Address: String read GetAddress write SetAddress;
        property PassWord: String read FPassWord write FPassWord;
        property Port: Word read GetPort write SetPort;
        function SendCommand(Text: String): Integer;
    end;
{$TYPEINFO ON}

implementation

uses
    System.SysUtils,
    PGofer.Classes,  PGofer.Sintatico, PGofer.Net.Controls;

{ TPGNetServer }

constructor TPGNetServer.Create;
begin
    inherited Create('Server');

    FServer := TServerSocket.Create(nil);
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
    inherited Destroy();
end;

function TPGNetServer.GetActive: Boolean;
begin
    Result := FServer.Active;
end;

procedure TPGNetServer.SetActive(Active: Boolean);
begin
    FServer.Active := Active;
end;

function TPGNetServer.GetPort: Word;
begin
    Result := FServer.Port;
end;

procedure TPGNetServer.SetPort(Port: Word);
begin
    FServer.Port := Port;
end;

function TPGNetServer.SendMessage(Text: String): Integer;
begin
    Result := FServer.Socket.SendText(AnsiString(Text));
end;

procedure TPGNetServer.OnClientConnect(Sender: TObject;
    Socket: TCustomWinSocket);
var
    Texto: String;
begin
    Texto := 'Client Connect: ' + Socket.RemoteAddress;
    TPGItemCMD.OnMsgNotify(Texto);

    if FLog then
        NetLogSrvSocket(Texto);

    if FServer.Socket.ActiveConnections > FMaxConnect then
    begin
        Texto := 'Client Denided: MaxConnect.';
        TPGItemCMD.OnMsgNotify(Texto);
        if FLog then
            NetLogSrvSocket(Texto);
        Socket.SendText('MaxConnect.');
        Socket.Close;
    end
    else
        Socket.Data := nil;
end;

procedure TPGNetServer.OnClientDisconnect(Sender: TObject;
    Socket: TCustomWinSocket);
var
    Texto: String;
begin
    Texto := 'Client Disconnect: ' + Socket.RemoteAddress;
    TPGItemCMD.OnMsgNotify(Texto);
    if FLog then
        NetLogSrvSocket(Texto);
end;

procedure TPGNetServer.OnClientError(Sender: TObject; Socket: TCustomWinSocket;
    ErrorEvent: TErrorEvent; var ErrorCode: Integer);
var
    Texto: String;
begin
    Texto := 'Net Error [' + Socket.RemoteAddress + ']: ' +
        NetErrorToStr(ErrorEvent) + ' Code: ' + IntToStr(ErrorCode);
    TPGItemCMD.OnMsgNotify(Texto);
    if FLog then
        NetLogSrvSocket(Texto);
end;

procedure TPGNetServer.OnClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
    Texto: String;
begin

    // ??????????????//otimizar
    Texto := String(Socket.ReceiveText);
    if Socket.Data = nil then
    begin
        if (Texto = FPassWord) or (FPassWord = '') then
        begin
            TPGItemCMD.OnMsgNotify('Client Accepted.');
            Socket.SendText('Client Accepted.');
            Socket.Data := Socket;
            if FLog then
                NetLogSrvSocket('Client Accepted [' + Socket.RemoteAddress +
                    '] Password: ' + Texto);
        end
        else
        begin
            TPGItemCMD.OnMsgNotify('Client Denided: Invalid Password.');
            Socket.SendText('Invalid Password.');
            Socket.Close;
            if FLog then
                NetLogSrvSocket('Client Denided [' + Socket.RemoteAddress +
                    '] Invalid Password: ' + Texto);
        end;
    end
    else
    begin
        if Texto <> '' then
        begin
            TPGItemCMD.OnMsgNotify('Clinet Send Command, Server Working...');
            ScriptExec('Script: ' + Socket.RemoteAddress, Texto, nil);
            if FLog then
                NetLogSrvSocket('Client [' + Socket.RemoteAddress +
                    '] Resceive Text: ' + Texto);
        end;
    end;
end;

{ TPGNetClient }

constructor TPGNetClient.Create;
begin
    inherited Create('Client');

    FClient := TClientSocket.Create(nil);
    FClient.OnConnecting := Self.OnClientConnecting;
    FClient.OnConnect := Self.OnClientConnect;
    FClient.OnDisconnect := Self.OnClientDisconnect;
    FClient.OnRead := Self.OnClientRead;
    FClient.OnError := Self.OnClientError;
    // FClient.Host := '127.0.0.1';
    FPassWord := '';
end;

destructor TPGNetClient.Destroy;
begin
    FPassWord := '';
    FClient.Free;
    inherited Destroy();
end;

function TPGNetClient.GetActive: Boolean;
begin
    Result := FClient.Active;
end;

procedure TPGNetClient.SetActive(Active: Boolean);
begin
    FClient.Active := Active;
end;

function TPGNetClient.GetAddress: String;
begin
    Result := FClient.Address;
end;

procedure TPGNetClient.SetAddress(Address: String);
begin
    FClient.Address := Address;
end;

function TPGNetClient.GetPort: Word;
begin
    Result := FClient.Port;
end;

procedure TPGNetClient.SetPort(Port: Word);
begin
    FClient.Port := Port;
end;

function TPGNetClient.SendCommand(Text: String): Integer;
begin
    Result := FClient.Socket.SendText(AnsiString(Text));
end;

procedure TPGNetClient.OnClientConnect(Sender: TObject;
    Socket: TCustomWinSocket);
begin
    TPGItemCMD.OnMsgNotify('Connect to Server.');
    FClient.Socket.SendText(AnsiString(FPassWord));
end;

procedure TPGNetClient.OnClientConnecting(Sender: TObject;
    Socket: TCustomWinSocket);
begin
    TPGItemCMD.OnMsgNotify('Connecting to Server...');
end;

procedure TPGNetClient.OnClientDisconnect(Sender: TObject;
    Socket: TCustomWinSocket);
begin
    TPGItemCMD.OnMsgNotify('Disconnect from Server...');
end;

procedure TPGNetClient.OnClientError(Sender: TObject; Socket: TCustomWinSocket;
    ErrorEvent: TErrorEvent; var ErrorCode: Integer);
var
    Texto: String;
begin
    Texto := 'Net Error [' + Socket.RemoteAddress + ']: ' +
        NetErrorToStr(ErrorEvent) + ' Code: ' + IntToStr(ErrorCode);
    TPGItemCMD.OnMsgNotify(Texto);
end;

procedure TPGNetClient.OnClientRead(Sender: TObject; Socket: TCustomWinSocket);
begin
    TPGItemCMD.OnMsgNotify('Message from Server: ' +
        String(Socket.ReceiveText));
end;

end.
