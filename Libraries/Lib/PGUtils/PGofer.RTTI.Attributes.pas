unit PGofer.RTTI.Attributes;

interface

uses
   System.RTTI;

type
   TPGHelp = class( TCustomAttribute )
      constructor Create( Mensagem: String ); overload;
      destructor Destroy( ); override;
   private
      FMensagem: string;
   public

   end;

implementation

{ TPGHelp }

constructor TPGHelp.Create( Mensagem: String );
begin
   inherited Create( );
   FMensagem := Mensagem;
end;

destructor TPGHelp.Destroy;
begin
   FMensagem := '';
   inherited Destroy( );
end;

end.
