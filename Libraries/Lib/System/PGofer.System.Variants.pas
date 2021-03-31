unit PGofer.System.Variants;

interface

uses
  PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes;

type

{$M+}
  TPGVariant = class( TPGItemCMD )
  private
    FValue               : Variant;
    FConstant            : Boolean;
    class var FImageIndex: Integer;
  protected
    class function GetImageIndex( ): Integer; override;
  public
    class var GlobList: TPGItem;
    constructor Create( AItemDad: TPGItem; AName: string; AValue: Variant;
       AConstant: Boolean ); overload;
    destructor Destroy( ); override;
    procedure Execute( Gramatica: TGramatica ); override;
    procedure Frame( AParent: TObject ); override;
    property Constant: Boolean read FConstant;
  published
    property Value: Variant read FValue write FValue;
  end;
{$TYPEINFO ON}

  TPGVariantDeclare = class( TPGItemCMD )
  private
    class procedure DeclaraNivel1( Gramatica: TGramatica; Nivel: TPGItem;
       Constant: Boolean );
  public
    procedure Execute( Gramatica: TGramatica ); override;
    class procedure ExecuteEx( Gramatica: TGramatica; Nivel: TPGItem );
  end;

implementation

uses
  System.SysUtils,
  PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.System.Variants.Frame,
  PGofer.ImageList;

{ TPGVariant }

constructor TPGVariant.Create( AItemDad: TPGItem; AName: string;
   AValue: Variant; AConstant: Boolean );
begin
  inherited Create( AItemDad, AName );
  FConstant := AConstant;
  FValue := AValue;
end;

destructor TPGVariant.Destroy;
begin
  FValue := '';
  FConstant := False;
  inherited Destroy( );
end;

procedure TPGVariant.Execute( Gramatica: TGramatica );
begin
  Gramatica.TokenList.GetNextToken;

  if Self.FConstant then
  begin
    if ( Gramatica.TokenList.Token.Classe <> cmdAttrib ) then
      Gramatica.Pilha.Empilhar( Self.FValue )
    else
      Gramatica.ErroAdd( 'Constante é somente leitura.' );
  end else begin
    if AtribuicaoNivel1( Gramatica ) then
      Self.FValue := Gramatica.Pilha.Desempilhar( Self.FValue )
    else
      Gramatica.Pilha.Empilhar( Self.FValue );
  end;
end;

procedure TPGVariant.Frame( AParent: TObject );
begin
  TPGFrameVariants.Create( Self, AParent );
end;

class function TPGVariant.GetImageIndex: Integer;
begin
  Result := FImageIndex;
end;

{ TPGVariantDeclare }

class procedure TPGVariantDeclare.DeclaraNivel1( Gramatica: TGramatica;
   Nivel: TPGItem; Constant: Boolean );
var
  Titulo: string;
  ID    : TPGItem;
  Valor : Variant;
begin
  ID := IdentificadorLocalizar( Gramatica );
  if ( not Assigned( ID ) ) or ( ID is TPGVariant ) then
  begin
    Titulo := Gramatica.TokenList.Token.Lexema;
    Gramatica.TokenList.GetNextToken;
    if Gramatica.TokenList.Token.Classe = cmdAttrib then
    begin
      Gramatica.TokenList.GetNextToken;
      Expressao( Gramatica );
      if not Gramatica.Erro then
        Valor := Gramatica.Pilha.Desempilhar( '' )
      else
        Exit;
    end
    else
      Valor := '';

    if ( not Assigned( ID ) ) or ( ( Nivel <> TPGVariant.GlobList ) and
       ( ID.Parent <> Nivel ) ) then
    begin
      TPGVariant.Create( Nivel, Titulo, Valor, Constant );
    end else begin
      with TPGVariant( ID ) do
      begin
        Value := Valor;
        Gramatica.MSGsAdd( 'Redeclare: ' + name );
      end;
    end;

    if Gramatica.TokenList.Token.Classe = cmdComa then
    begin
      Gramatica.TokenList.GetNextToken;
      DeclaraNivel1( Gramatica, Nivel, Constant );
    end;

  end
  else
    Gramatica.ErroAdd( 'Identificador esperado.' );
end;

procedure TPGVariantDeclare.Execute( Gramatica: TGramatica );
var
  Constant: Boolean;
begin
  Constant := SameText( Gramatica.TokenList.Token.Lexema, 'Const' );
  Gramatica.TokenList.GetNextToken;

  if Gramatica.TokenList.Token.Classe = cmdRes_global then
  begin
    Gramatica.TokenList.GetNextToken;
    DeclaraNivel1( Gramatica, TPGVariant.GlobList, Constant );
  end
  else
    DeclaraNivel1( Gramatica, Gramatica.Local, Constant );
end;

class procedure TPGVariantDeclare.ExecuteEx( Gramatica: TGramatica;
   Nivel: TPGItem );
begin
  DeclaraNivel1( Gramatica, Nivel, False );
end;

initialization

TPGVariantDeclare.Create( GlobalItemCommand, 'Const' );
TPGVariantDeclare.Create( GlobalItemCommand, 'Var' );
TPGVariant.GlobList := TPGFolder.Create( GlobalCollection, 'Variants' );
TPGVariant.FImageIndex := GlogalImageList.AddIcon( 'Variants' );

finalization

end.
