unit PGofer.Net.Controls;

interface

uses
  System.Win.ScktComp;

function NetErrorToStr( Error: TErrorEvent ): string;
procedure NetSendMessage( Texto: string; Socket: TCustomWinSocket );
function NetSetTCPIP( NetworkCard, IPAddress, Mask, GateWay: string ): Integer;
procedure NetLogSrvSocket( Text: string );

implementation

uses
  System.Variants, System.Win.ComObj, System.Classes, System.SysUtils,
  Winapi.ActiveX,
  PGofer.Sintatico, PGofer.Sintatico.Controls;

function NetErrorToStr( Error: TErrorEvent ): string;
begin
  case Error of
    eeGeneral:
    Result := 'General';
    eeSend:
    Result := 'Send';
    eeReceive:
    Result := 'Receive';
    eeConnect:
    Result := 'Connect';
    eeDisconnect:
    Result := 'Disconnect';
    eeAccept:
    Result := 'Accept';
    eeLookup:
    Result := 'Lookup';
  end;
end;

procedure NetSendMessage( Texto: string; Socket: TCustomWinSocket );
begin
  if Assigned( Socket ) then
    Socket.SendText( AnsiString( Texto ) );
end;

function NetSetTCPIP( NetworkCard, IPAddress, Mask, GateWay: string ): Integer;

  function ArrayToVarArray( Arr: array of string ): OleVariant; overload;
  var
    i: Integer;
  begin
    Result := VarArrayCreate( [ 0, high( Arr ) ], varVariant );
    for i := low( Arr ) to high( Arr ) do
      Result[ i ] := Arr[ i ];
  end;

const
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator: OleVariant;
  FWMIService: OleVariant;
  FWbemObjectSet: OleVariant;
  FWbemObject: OleVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;
  vIPAddress: OleVariant;
  vSubnetMask: OleVariant;
  vDefaultIPGateway: OleVariant;
  vGatewayCostMetric: OleVariant;
begin
  Result := 0;
  FSWbemLocator := CreateOleObject( 'WbemScripting.SWbemLocator' );
  FWMIService := FSWbemLocator.ConnectServer( 'localhost',
     'root\CIMV2', '', '' );
  FWbemObjectSet := FWMIService.ExecQuery
     ( 'SELECT * FROM Win32_NetworkAdapterConfiguration Where Description = "' +
     NetworkCard + '"', 'WQL', wbemFlagForwardOnly );
  oEnum := IUnknown( FWbemObjectSet._NewEnum ) as IEnumvariant;

  while oEnum.Next( 1, FWbemObject, iValue ) = 0 do
  begin
    if IPAddress <> '' then
    begin
      vIPAddress := ArrayToVarArray( [ IPAddress ] );
      vSubnetMask := ArrayToVarArray( [ Mask ] );
      Result := FWbemObject.EnableStatic( vIPAddress, vSubnetMask );
      if Result = 0 then
      begin
        vDefaultIPGateway := ArrayToVarArray( [ GateWay ] );
        vGatewayCostMetric := ArrayToVarArray( [ '1' ] );
        Result := FWbemObject.SetGateways( vDefaultIPGateway,
           vGatewayCostMetric );
      end;

      VarClear( vIPAddress );
      VarClear( vSubnetMask );
      VarClear( vDefaultIPGateway );
      VarClear( vGatewayCostMetric );
    end
    else
      FWbemObject.EnableDHCP;

    FWbemObject := Unassigned;
  end;
end;

procedure NetLogSrvSocket( Text: string );
var
  Arquivo: TStringList;
begin
  Arquivo := TStringList.Create;
  if FileExists( PGofer.Sintatico.LogFile ) then
    Arquivo.LoadFromFile( PGofer.Sintatico.LogFile );
  Arquivo.Add( Text );
  while ( Arquivo.Count > PGofer.Sintatico.LogMaxSize ) do
    Arquivo.Delete( 0 );
  Arquivo.SaveToFile( PGofer.Sintatico.LogFile );
  Arquivo.Free;
end;

end.
