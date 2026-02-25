unit PGofer.Net;

interface

uses
  PGofer.Runtime, PGofer.Net.Socket;

type

  {$M+}
  TPGNet = class( TPGItemClass )
  private
    FServer: TPGNetServer;
    FClient: TPGNetClient;
    FLogFileName: String;
    FLogMaxSize: UInt64;
  protected
  public
  published
    property Server: TPGNetServer read FServer;
    property Client: TPGNetClient read FClient;
    property LogFileName: String read FLogFileName write FLogFileName;
    property LogMaxSize: UInt64 read FLogMaxSize write FLogMaxSize;
    function SetTCPIP( ANetworkCard, AIPAddress, AMask, AGateWay: string ): Integer;
    function GetTCPIP( ANetworkCard: string ): string;
  end;
  {$TYPEINFO ON}

var
  PGNet: TPGNet;

implementation

uses
  PGofer.Net.Controls;

{ TPGNet }

function TPGNet.SetTCPIP( ANetworkCard, AIPAddress, AMask, AGateWay: string ): Integer;
begin
  Result := NetSetTCPIP( ANetworkCard, AIPAddress, AMask, AGateWay );
end;

function TPGNet.GetTCPIP( ANetworkCard: string ): string;
begin
  // ?????????????
  Result := 'Ainda nao implementado';
end;

initialization

  PGNet := TPGNet.Create( GlobalItemCommand );

finalization

  PGNet := nil;

end.
