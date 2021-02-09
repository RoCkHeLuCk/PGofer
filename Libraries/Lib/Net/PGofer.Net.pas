unit PGofer.Net;

interface

uses
    PGofer.Sintatico.Classes;

type

{$M+}
    TPGNet = class(TPGItemCMD)
    private
        FClient: TPGItemCMD;
        FServer: TPGItemCMD;
    public
        constructor Create();
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
    PGofer.Classes, PGofer.Sintatico, PGofer.Net.Controls, PGofer.Net.Socket;

{ TPGNet }

constructor TPGNet.Create;
begin
    inherited Create();
    FClient := TPGNetClient.Create();
    Self.Add(FClient);
    FServer := TPGNetServer.Create();
    Self.Add(FServer);
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
    PGNet := TPGNet.Create();
    TGramatica.Global.FindName('Commands').Add(PGNet);

finalization

end.
