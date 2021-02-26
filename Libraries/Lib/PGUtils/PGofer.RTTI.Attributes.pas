unit PGofer.RTTI.Attributes;

interface

uses
    System.Classes, System.RTTI,
    PGofer.Classes;

type
    TPGHelpAttribute = class(TCustomAttribute)
        constructor Create(Mensagem: String); overload;
        destructor Destroy(); override;
    private
        FMensagem: string;
    public

    end;

implementation

{ TPGHelp }

constructor TPGHelpAttribute.Create(Mensagem: String);
begin
    inherited Create();
    FMensagem := Mensagem;
end;

destructor TPGHelpAttribute.Destroy;
begin
    FMensagem := '';
    inherited;
end;



end.
