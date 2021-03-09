unit PGofer.Services;

interface

uses
    PGofer.Sintatico.Classes;

type
{$M+}
    TPGService = class(TPGItemCMD)
    private
    public
    published
        function Created(Maquina, Servico, DisplayName, PathFile: String)
          : Cardinal;
        function Delete(Maquina, Servico: String): Boolean;
        function GetConfig(Maquina, Servico: String): Byte;
        function GetDesciption(Maquina, Servico: String): String;
        function GetState(Maquina, Servico: String): Byte;
        function SetConfig(Maquina, Servico: String; Controle: Byte): Boolean;
        function SetDesciption(Maquina, Servico, Desciption: String): Boolean;
        function SetState(Maquina, Servico: String; Controle: Byte): Boolean;
    end;
{$TYPEINFO ON}

implementation

uses
    PGofer.Sintatico, PGofer.Services.Controls;

{ TPGService }

function TPGService.Created(Maquina, Servico, DisplayName, PathFile: String)
  : Cardinal;
begin
    Result := ServiceCreate(Maquina, Servico, DisplayName, PathFile);
end;

function TPGService.Delete(Maquina, Servico: String): Boolean;
begin
    Result := ServiceDelete(Maquina, Servico);
end;

function TPGService.GetConfig(Maquina, Servico: String): Byte;
begin
    Result := ServiceGetConfig(Maquina, Servico);
end;

function TPGService.GetDesciption(Maquina, Servico: String): String;
begin
    Result := ServiceGetDesciption(Maquina, Servico);
end;

function TPGService.GetState(Maquina, Servico: String): Byte;
begin
    Result := ServiceGetState(Maquina, Servico);
end;

function TPGService.SetConfig(Maquina, Servico: String; Controle: Byte)
  : Boolean;
begin
    Result := ServiceSetConfig(Maquina, Servico, Controle);
end;

function TPGService.SetDesciption(Maquina, Servico, Desciption: String)
  : Boolean;
begin
    Result := ServiceSetDesciption(Maquina, Servico, Desciption);
end;

function TPGService.SetState(Maquina, Servico: String; Controle: Byte): Boolean;
begin
    Result := ServiceSetState(Maquina, Servico, Controle);
end;

initialization
    TPGService.Create(GlobalItemCommand);

finalization

end.
