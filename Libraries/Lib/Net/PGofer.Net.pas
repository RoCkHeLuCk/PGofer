unit PGofer.Net;

interface

uses
  PGofer.Classes, PGofer.Runtime;

type

  {$M+}
  TPGNet = class( TPGItemCMD )
  private
    FClient: TPGItemCMD;
    FServer: TPGItemCMD;
  public
    constructor Create( AItemDad: TPGItem );
    destructor Destroy( ); override;
    property Client: TPGItemCMD read FClient;
    property Server: TPGItemCMD read FServer;
  published
    function SetTCPIP( ANetworkCard, AIPAddress, AMask,
      AGateWay: string ): Integer;
    function GetTCPIP( ANetworkCard: string ): string;
  end;
  {$TYPEINFO ON}

var
  PGNet: TPGNet;

implementation

uses
  PGofer.Sintatico, PGofer.Net.Controls, PGofer.Net.Socket;

{ TPGNet }

constructor TPGNet.Create( AItemDad: TPGItem );
begin
  inherited Create( AItemDad );
  FClient := TPGNetClient.Create( Self );
  FServer := TPGNetServer.Create( Self );
end;

destructor TPGNet.Destroy;
begin
  FClient.Free;
  FServer.Free;
  inherited Destroy( );
end;

function TPGNet.SetTCPIP( ANetworkCard, AIPAddress, AMask,
  AGateWay: string ): Integer;
begin
  Result := NetSetTCPIP( ANetworkCard, AIPAddress, AMask, AGateWay );
end;

function TPGNet.GetTCPIP( ANetworkCard: string ): string;
begin
  // ?????????????
  Result := 'Ainda nao implementado';
end;

initialization

TPGNet.Create( GlobalItemCommand );

finalization

end.
