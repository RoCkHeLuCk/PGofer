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
    function GetPassword( ) : string;
  protected
  public
    constructor Create( AItemDad: TPGItem; AName: string = '' ); overload;
    destructor Destroy( ); override;
    procedure Frame( AParent: TObject ); override;
    property Locked: Boolean read FLocked write FLocked;
    property Password: string read GetPassword write FPassword;
  published
    property FileName: string read FFileName write FFileName;
    property SavePassword: Boolean read FSavePassword write FSavePassword;
  end;
  {$TYPEINFO ON}


implementation

uses
  PGofer.Sintatico, PGofer.VaultFolder.Frame;

{ TPGVaultFolder }

constructor TPGVaultFolder.Create( AItemDad: TPGItem; AName: string );
begin
  inherited Create( AItemDad, AName );
  FFileName := '';
  FLocked := True;
  FPassword := '';
  FSavePassword := False;
end;

destructor TPGVaultFolder.Destroy( );
begin
  FFileName := '';
  FLocked := True;
  FPassword := '';
  FSavePassword := False;
  inherited Destroy( );
end;

procedure TPGVaultFolder.Frame(AParent: TObject);
begin
  inherited Frame( AParent );
  TPGVaultFolderFrame.Create( Self, AParent );
end;

function TPGVaultFolder.GetPassword: string;
begin
  Result := '';
  if FSavePassword then
    Result := FPassword;
end;

initialization

TriggersCollect.RegisterClass( 'VaultFolder', TPGVaultFolder );

finalization

end.
