unit Services.Thread;

interface

uses
  System.Classes, Vcl.ComCtrls;

type
  TThreadService = class( TThread )
    constructor Create(const AHost: string; const AItem: TListItem; const AConfig: Cardinal );
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
  System.Sysutils, Winapi.Windows,
  PGofer.Services.Controls, UnitServices;

{ TThreadService }
// ----------------------------------------------------------------------------//
constructor TThreadService.Create(const AHost: string; const AItem: TListItem;
  const AConfig: Cardinal );
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
procedure TThreadService.Execute;
var
  NomeReal, MsgErro: string;
  Sucesso: Boolean;
  c, d, e: Cardinal;
begin
  NomeReal := ItemA.SubItems[4];

  // 2. Tenta executar a ação
  Sucesso := ServiceSetState(HostA, NomeReal, ConfigA);

  if not Sucesso then
  begin
    // Monta a mensagem de erro formatada
    MsgErro := Format('Falha ao alterar %s: %s',
      [NomeReal, ServiceGetLastErrorMessage]);

    // Dispara para a tela (Main Thread) de forma assíncrona
    TThread.Queue(nil,
      procedure
      begin
        frmServices.LogMessage(MsgErro);
      end);

    Terminate;
    Exit;
  end;

  // 3. Se deu sucesso, continua o loop original monitorando a mudança de estado
  c := 0;
  d := 0;
  e := 0;
  while ( c <> ConfigA ) and ( d < 100 ) and (not Terminated) do
  begin
    Sleep( 100 );
    c := ServiceGetState( HostA, NomeReal ); // <-- Use o NomeReal aqui também!
    Inc( d );
    if c <> e then
    begin
      e := c;
      TThread.Queue(nil, // Trocado de Synchronize para Queue para não gerar gargalo
        procedure
        begin
          ItemA.SubItems[0] := ServiceStatusToState(c);
          ItemA.SubItems[9] := Char(c) + ItemA.SubItems[9][2];
        end);
    end;
  end;

  Terminate;
end;
// ----------------------------------------------------------------------------//

end.
