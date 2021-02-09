unit PGofer.AutoRuns;

interface

uses
   System.Generics.Collections,
   PGofer.Classes;

type
   TAutoRuns = class (TPGItem)
       constructor Create();
       destructor Destroy(); override;
   private
       FComandos : String;
       class var AutoRunsList : TObjectList<TAutoRuns>;
   public
       property Comandos : String read FComandos write FComandos;
       procedure Execute();
   end;

implementation

{ TPGLinks }

constructor TAutoRuns.Create();
begin
    inherited Create('NovoAutoRun');
    FComandos := '';
    AutoRunsList.Add( Self );
end;

destructor TAutoRuns.Destroy();
begin
    FComandos := '';
    AutoRunsList.Remove( Self );
    inherited Destroy();
end;

procedure TAutoRuns.Execute;
begin
    //??????
end;

initialization
    TAutoRuns.AutoRunsList := TObjectList<TAutoRuns>.Create(False);

finalization
    TAutoRuns.AutoRunsList.Free;


end.
