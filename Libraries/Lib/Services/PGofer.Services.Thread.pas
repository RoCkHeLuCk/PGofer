unit PGofer.Services.Thread;

interface

uses
  System.Classes, Vcl.ComCtrls;

type
  TThreadService = class( TThread )
    constructor Create( AHost: string; AItem: TListItem; AConfig: Cardinal );
  private
    { Private declarations }
    HostA: string;
    ItemA: TListItem;
    ConfigA: Cardinal;
  protected
    procedure Execute; override;
  public

  end;

implementation

uses
  PGofer.Services, PGofer.Services.Controls;

{ TThreadLoadImage }
// ----------------------------------------------------------------------------//
constructor TThreadService.Create( AHost: string; AItem: TListItem;
   AConfig: Cardinal );
begin
  // cria thread
  inherited Create( true );
  Priority := tpIdle;
  FreeOnTerminate := true;

  HostA := AHost;
  ItemA := AItem;
  ConfigA := AConfig;
end;

// ----------------------------------------------------------------------------//
procedure TThreadService.Execute( );
var
  c, d, e: Cardinal;
begin
  ServiceSetState( HostA, ItemA.SubItems[ 4 ], ConfigA );
  c := 0;
  d := 0;
  e := 0;
  while ( c <> ConfigA ) and ( d < 100 ) do
  begin
    sleep( 100 );
    c := ServiceGetState( HostA, ItemA.SubItems[ 4 ] );
    inc( d );
    if c <> e then
    begin
      e := c;
      Synchronize(
        procedure
        begin
          ItemA.SubItems[ 0 ] := ServiceStatusToState( c );
          ItemA.SubItems[ 9 ] := Char( c ) + ItemA.SubItems[ 9 ][ 2 ];
        end );
    end;
  end;
  Terminate;
end;
// ----------------------------------------------------------------------------//

end.
