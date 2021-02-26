unit PGofer.Net;

interface

uses
    PGofer.Classes, PGofer.Sintatico.Classes;

type

{$M+}
    TPGNet = class(TPGItemCMD)
    private
        FClient: TPGItemCMD;
        FServer: TPGItemCMD;
    public
        constructor Create(ItemDad: TPGItem);
        destructor Destroy(); override;
        property Client: TPGItemCMD read FClient;
        property Server: TPGItemCMD read FServer;
    published
        function SetTCPIP(NetworkCard, IPAddress, Mask,
            GateWay: String): Integer;
        function GetTCPIP(NetworkCard: String): String;
    end;
{$TYPEINFO ON}

var
    PGNet : TPGNet;

implementation

uses
    PGofer.Sintatico, PGofer.Net.Controls, PGofer.Net.Socket;

{ TPGNet }

constructor TPGNet.Create(ItemDad: TPGItem);
begin
    inherited Create(ItemDad);
    FClient := TPGNetClient.Create(Self);
    FServer := TPGNetServer.Create(Self);
end;

destructor TPGNet.Destroy;
begin
    FClient.Free;
    FServer.Free;
    inherited Destroy();
end;

function TPGNet.SetTCPIP(NetworkCard, IPAddress, Mask, GateWay: String) : Integer;
begin
    Result := NetSetTCPIP(NetworkCard, IPAddress, Mask, GateWay);
end;

function TPGNet.GetTCPIP(NetworkCard: String): String;
begin
    // ?????????????
    Result := 'Ainda nao implementado';
end;

initialization
    TPGNet.Create(GlobalItemCommand);

finalization

end.
