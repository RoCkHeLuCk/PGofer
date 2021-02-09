unit PGofer.Sintatico.Classes;

interface

uses
    PGofer.Classes, PGofer.Sintatico;

type
    TPGItemCMD = class(TPGItem)
    private
    public
        constructor Create(); overload;
        constructor Create(Name: String); overload;
        destructor Destroy(); override;
        procedure Execute(Gramatica: TGramatica); virtual;
    end;

implementation

uses
    PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.Types;

{ TPGItemCMD }

constructor TPGItemCMD.Create();
begin
    inherited Create(copy(Self.ClassName, 4, Length(Self.ClassName)));
    PGofer.Types.Construir(Self);
end;

constructor TPGItemCMD.Create(Name: String);
begin
    inherited Create(Name);
    PGofer.Types.Construir(Self);
end;

destructor TPGItemCMD.Destroy;
begin
    inherited Destroy();
end;

procedure TPGItemCMD.Execute(Gramatica: TGramatica);
begin
    Gramatica.TokenList.GetNextToken;
    if Gramatica.TokenList.Token.Classe = cmdDot then
    begin
        Gramatica.TokenList.GetNextToken;
        PGofer.Types.Executar(Gramatica, Self);
    end;
end;

initialization

finalization

end.
