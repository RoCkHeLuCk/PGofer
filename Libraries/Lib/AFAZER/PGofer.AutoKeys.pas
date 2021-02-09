unit PGofer.AutoKeys;

interface

uses System.Generics.Collections, PGofer.Classes;

type
   TAutoKeys = class (TPGItem)
       constructor Create();
       destructor Destroy(); override;
   private
       class var AutoKeysList : TObjectList<TAutoKeys>;
   public
   end;

implementation

{ TAutoKeys }

constructor TAutoKeys.Create;
begin
    inherited Create();
    TAutoKeys.AutoKeysList.Add( Self );
end;

destructor TAutoKeys.Destroy;
begin
    TAutoKeys.AutoKeysList.Remove( Self );
    inherited Destroy();
end;

initialization
    TAutoKeys.AutoKeysList := TObjectList<TAutoKeys>.Create(False);

finalization
    TAutoKeys.AutoKeysList.Free;

end.
