unit PGofer.Net;

interface

uses
  PGofer.Classes, PGofer.Runtime, PGofer.Net.Socket;

type

  {$M+}
  TPGNet = class( TPGItemClass )
  private
    FServer: TPGNetServer;
    FClient: TPGNetClient;
    FLogFileName: String;
    FLogMaxSize: Cardinal;
  protected
  public
    constructor Create( AItemDad: TPGItem; const AName: string = ''); override;
  published
    property LogMaxSize: Cardinal read FLogMaxSize write FLogMaxSize;
    property Server: TPGNetServer read FServer;
    property Client: TPGNetClient read FClient;
    property LogFileName: String read FLogFileName write FLogFileName;
    function SetTCPIP( ANetworkCard, AIPAddress, AMask, AGateWay: string ): Integer;
    function GetTCPIP( ANetworkCard: string ): string;
  end;
  {$TYPEINFO ON}

var
  PGNet: TPGNet;

implementation

uses
  PGofer.Net.Controls, PGofer.Core;

{ TPGNet }

constructor TPGNet.Create(AItemDad: TPGItem; const AName: string = '');
begin
   inherited Create(AItemDad, 'Net');
   FLogMaxSize := 1000000;
end;

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
