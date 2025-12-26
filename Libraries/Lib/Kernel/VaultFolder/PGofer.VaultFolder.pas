unit PGofer.VaultFolder;

interface

uses
  PGofer.Types, PGofer.Classes, PGofer.Sintatico.Classes;

type
  {$M+}
  [TPGAttribText('Pasta criptografada.')]
  [TPGAttribIcon(pgiVault)]
  TPGVaultFolder = class( TPGFolder )
  private
    FFileName: string;
    FLocked: Boolean;
    FPassword: string;
    FSavePassword: Boolean;
  protected
  public
    constructor Create( AItemDad: TPGItem; AName: string = '' ); overload;
    destructor Destroy( ); override;
  published
    property FileName: string read FFileName write FFileName;
    property Locked: Boolean read FLocked write FLocked;
    property Password: string read FPassword write FPassword;
    property SavePassword: Boolean read FSavePassword write FSavePassword;
  end;
  {$TYPEINFO ON}


implementation

uses
  PGofer.Sintatico;

{ TPGVaultFolder }

constructor TPGVaultFolder.Create( AItemDad: TPGItem; AName: string );
begin
  inherited Create( AItemDad, AName );
  FFileName := '';
  FLocked := True;
  FPassword := '';
  FSavePassword := False;
end;

destructor TPGVaultFolder.Destroy;
begin
  FFileName := '';
  FLocked := True;
  FPassword := '';
  FSavePassword := False;
  inherited Destroy( );
end;

initialization

TriggersCollect.RegisterClass( 'VaultFolder', TPGVaultFolder );

finalization

end.
