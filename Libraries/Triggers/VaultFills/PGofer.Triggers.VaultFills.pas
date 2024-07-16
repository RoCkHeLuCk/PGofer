unit PGofer.Triggers.VaultFills;

interface

uses
  System.Classes,
  PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes,
  PGofer.Triggers;

type

  {$M+}
  TPGVaultFills = class( TPGItemTrigger )
  private
    FSpeed : Cardinal;
    FMode : Byte;
    FText : String;
    class var FImageIndex: Integer;
  protected
    class function GetImageIndex( ): Integer; override;
    procedure ExecutarNivel1( Gramatica: TGramatica ); override;
  public
    constructor Create( AName: string; AMirror: TPGItemMirror );
    destructor Destroy( ); override;
    procedure Frame( AParent: TObject ); override;
    class var GlobList: TPGItem;
    procedure Triggering( ); override;
  published
    property Mode: Byte read FMode write FMode;
    property Speed: Cardinal read FSpeed write FSpeed;
    property Text: string read FText write FText;
  end;
  {$TYPEINFO ON}

  TPGVaultFillsDeclare = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGVaultFillsMirror = class( TPGItemMirror )
  protected
    class function GetImageIndex( ): Integer; override;
  public
    constructor Create( AItemDad: TPGItem; AName: string );
    procedure Frame( AParent: TObject ); override;
  end;

  {$M+}
  TPGVaultFolder = class( TPGFolder )
  private
  protected
  public
    constructor Create( AItemDad: TPGItem; AName: string = '' ); overload;
  published
  end;
  {$TYPEINFO ON}


implementation

uses
  System.SysUtils,
  PGofer.Lexico,
  PGofer.Sintatico.Controls,
  PGofer.Triggers.VaultFills.Frame,
  PGofer.ImageList,
  PGofer.Key.Post;

{ TPGVaultFills }

constructor TPGVaultFills.Create( AName: string; AMirror: TPGItemMirror );
begin
  inherited Create( TPGVaultFills.GlobList, AName, AMirror );
  Self.ReadOnly := False;
  FText := '';
  FSpeed := 10;
  FMode := 0;
end;

destructor TPGVaultFills.Destroy( );
begin
  FText := '';
  FSpeed := 10;
  FMode := 0;
  inherited Destroy( );
end;

procedure TPGVaultFills.ExecutarNivel1( Gramatica: TGramatica );
var
  VParam: string;
begin
  if Gramatica.TokenList.Token.Classe = cmdLPar then
  begin
    Gramatica.TokenList.GetNextToken;
    Expressao( Gramatica );
    if ( Gramatica.TokenList.Token.Classe = cmdRPar ) then
    begin
      VParam := Gramatica.Pilha.Desempilhar( '' );
      if not Gramatica.Erro then
        Self.Triggering(); //??????????

      Gramatica.TokenList.GetNextToken;
    end
    else
      Gramatica.ErroAdd( '")" Esperado.' )
  end else if not Gramatica.Erro then
    Self.Triggering();
end;

procedure TPGVaultFills.Frame( AParent: TObject );
begin
  inherited Frame( AParent );
  TPGVaultFillsFrame.Create( Self, AParent );
end;

class function TPGVaultFills.GetImageIndex( ): Integer;
begin
  Result := FImageIndex;
end;

procedure TPGVaultFills.Triggering( );
var
  KeyPost: TKeyPost;
begin
  KeyPost := TKeyPost.Create( self.Text, self.Speed );
  KeyPost.WaitFor( );
  KeyPost.Free( );
end;

{ TPGVaultFillsDeclare }

procedure TPGVaultFillsDeclare.Execute( Gramatica: TGramatica );
var
  Titulo: string;
  Quantidade: Byte;
  VaultFills: TPGVaultFills;
  id: TPGItem;
begin
  Gramatica.TokenList.GetNextToken;
  id := IdentificadorLocalizar( Gramatica );
  if ( not Assigned( id ) ) or ( id is TPGVaultFills ) then
  begin
    Titulo := Gramatica.TokenList.Token.Lexema;
    Quantidade := LerParamentros( Gramatica, 1, 3 );
    if not Gramatica.Erro then
    begin
      if ( not Assigned( id ) ) then
        VaultFills := TPGVaultFills.Create( Titulo, nil )
      else
        VaultFills := TPGVaultFills( id );

      if Quantidade >= 3 then
        VaultFills.Speed := Gramatica.Pilha.Desempilhar( 10 );

      if Quantidade >= 2 then
        VaultFills.Mode := Gramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 1 then
        VaultFills.Text := Gramatica.Pilha.Desempilhar( '' );
    end;
  end
  else
    Gramatica.ErroAdd( 'Identificador esperado ou já existente.' );
end;

{ TPGVaultFillsMirror }

constructor TPGVaultFillsMirror.Create( AItemDad: TPGItem; AName: string );
begin
  AName := TPGItemMirror.TranscendName( AName, TPGVaultFills.GlobList );
  inherited Create( AItemDad, TPGVaultFills.Create( AName, Self ) );
  Self.ReadOnly := False;
end;

procedure TPGVaultFillsMirror.Frame( AParent: TObject );
begin
  TPGVaultFillsFrame.Create( Self.ItemOriginal, AParent );
end;

class function TPGVaultFillsMirror.GetImageIndex: Integer;
begin
  Result := TPGVaultFills.FImageIndex;
end;

{ TPGVaultFolder }

constructor TPGVaultFolder.Create( AItemDad: TPGItem; AName: string );
begin
  inherited Create( AItemDad, AName );
  //algo aqui...
end;

initialization

TPGVaultFillsDeclare.Create( GlobalItemCommand, 'VaultFills' );
TPGVaultFills.GlobList := TPGFolder.Create( GlobalCollection, 'VaultFills' );

TriggersCollect.RegisterClass( 'VaultFills', TPGVaultFillsMirror );
TPGVaultFills.FImageIndex := GlogalImageList.AddIcon( 'VaultFills' );

TriggersCollect.RegisterClass( 'VaultFolder', TPGVaultFolder );
TPGVaultFolder.FImageIndex := GlogalImageList.AddIcon( 'VaultFolder' );


finalization

end.

