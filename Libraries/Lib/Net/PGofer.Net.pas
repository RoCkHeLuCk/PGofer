unit PGofer.Net;

interface

uses
  PGofer.Core, PGofer.Classes, PGofer.Runtime, PGofer.Net.Socket;

type

  {$M+}
  [TPGClassReg('Commands')]
  TPGNet = class( TPGItemClass )
  private
    FServer: TPGNetServer;
    FClient: TPGNetClient;
    function GetLogFileName: String;
    function GetLogMaxSize: Cardinal;
    procedure SetLogFileName(const AValue: String);
    procedure SetLogMaxSize(const AValue: Cardinal);
  protected
  public
    class var FLogFileName: String;
    class var FLogMaxSize: Cardinal;
    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
  published
    property LogMaxSize: Cardinal read GetLogMaxSize write SetLogMaxSize;
    property LogFileName: String read GetLogFileName write SetLogFileName;
    property Server: TPGNetServer read FServer;
    property Client: TPGNetClient read FClient;
    function SetTCPIP(const ANetworkCard, AIPAddress, AMask, AGateWay: string ): Integer;
    function GetTCPIP(const ANetworkCard: string ): string;
  end;
  {$TYPEINFO ON}

implementation

uses
  PGofer.Net.Controls;

{ TPGNet }

constructor TPGNet.Create(const AItemDad: TPGItem; const AName: string = '');
begin
   inherited Create(AItemDad, 'Net');
   FLogMaxSize := 1000000;
end;

procedure TPGNet.SetLogFileName(const AValue: String);
begin
  FLogFileName := AValue;
end;

procedure TPGNet.SetLogMaxSize(const AValue: Cardinal);
begin
  FLogMaxSize := AValue;
end;

function TPGNet.SetTCPIP(const ANetworkCard, AIPAddress, AMask, AGateWay: string ): Integer;
begin
  Result := NetSetTCPIP( ANetworkCard, AIPAddress, AMask, AGateWay );
end;

function TPGNet.GetLogFileName(): String;
begin
  Result := FLogFileName;
end;

function TPGNet.GetLogMaxSize(): Cardinal;
begin
  Result := FLogMaxSize;
end;

function TPGNet.GetTCPIP(const ANetworkCard: string ): string;
begin
  // ?????????????
  Result := 'Ainda nao implementado';
end;

initialization

finalization

end.
