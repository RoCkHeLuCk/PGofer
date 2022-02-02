unit PGofer.Services;

interface

uses
  PGofer.Sintatico.Classes;

type
  {$M+}
  TPGService = class( TPGItemCMD )
  private
  public
  published
    function Created( Maquina, Servico, DisplayName, PathFile: string )
      : Cardinal;
    function Delete( Maquina, Servico: string ): Boolean;
    function GetConfig( Maquina, Servico: string ): Byte;
    function GetDesciption( Maquina, Servico: string ): string;
    function GetState( Maquina, Servico: string ): Byte;
    function SetConfig( Maquina, Servico: string; Controle: Byte ): Boolean;
    function SetDesciption( Maquina, Servico, Desciption: string ): Boolean;
    function SetState( Maquina, Servico: string; Controle: Byte ): Boolean;
  end;
  {$TYPEINFO ON}

implementation

uses
  PGofer.Sintatico, PGofer.Services.Controls;

{ TPGService }

function TPGService.Created( Maquina, Servico, DisplayName, PathFile: string )
  : Cardinal;
begin
  Result := ServiceCreate( Maquina, Servico, DisplayName, PathFile );
end;

function TPGService.Delete( Maquina, Servico: string ): Boolean;
begin
  Result := ServiceDelete( Maquina, Servico );
end;

function TPGService.GetConfig( Maquina, Servico: string ): Byte;
begin
  Result := ServiceGetConfig( Maquina, Servico );
end;

function TPGService.GetDesciption( Maquina, Servico: string ): string;
begin
  Result := ServiceGetDesciption( Maquina, Servico );
end;

function TPGService.GetState( Maquina, Servico: string ): Byte;
begin
  Result := ServiceGetState( Maquina, Servico );
end;

function TPGService.SetConfig( Maquina, Servico: string;
  Controle: Byte ): Boolean;
begin
  Result := ServiceSetConfig( Maquina, Servico, Controle );
end;

function TPGService.SetDesciption( Maquina, Servico,
  Desciption: string ): Boolean;
begin
  Result := ServiceSetDesciption( Maquina, Servico, Desciption );
end;

function TPGService.SetState( Maquina, Servico: string;
  Controle: Byte ): Boolean;
begin
  Result := ServiceSetState( Maquina, Servico, Controle );
end;

initialization

TPGService.Create( GlobalItemCommand );

finalization

end.
