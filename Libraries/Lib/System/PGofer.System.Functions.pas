unit PGofer.System.Functions;

interface

uses
  System.Classes,
  PGofer.Classes, PGofer.Lexico, PGofer.Sintatico,
  PGofer.Sintatico.Classes, PGofer.System.Variants;

type

  {$M+}
  TPGFunction = class( TPGItemCMD )
  private
    FTokenList: TTokenList;
    FVariantList: TPGItem;
    FScript: TStrings;
    class var FImageIndex: Integer;
    procedure SetScript( AValue: string );
    function GetScript: string;
  public
    constructor Create( AItemDad: TPGItem; AName: string ); overload;
    destructor Destroy( ); override;
    class var GlobList: TPGItem;
    class function GetImageIndex( ): Integer; override;
    procedure Execute( Gramatica: TGramatica ); override;
    procedure Frame( AParent: TObject ); override;
    property Script: string read GetScript write SetScript;
    procedure CompileScript( );
  published
  end;
  {$TYPEINFO ON}

  TPGFunctionDeclare = class( TPGItemCMD )
  private
    FCordIni: Integer;
    procedure DeclaraNivel1( Gramatica: TGramatica; Nivel: TPGItem );
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

implementation

uses
  PGofer.Sintatico.Controls,
  PGofer.System.Functions.Frame,
  PGofer.ImageList;

{ TPGFunction }

procedure TPGFunction.CompileScript( );
begin
  ScriptExec( 'Function: ' + Self.Name, FScript.Text, nil, False );
end;

constructor TPGFunction.Create( AItemDad: TPGItem; AName: string );
begin
  inherited Create( AItemDad, AName );
  FScript := TStringList.Create;
  FTokenList := TTokenList.Create( );
  FVariantList := TPGItem.Create( nil, 'VariantList' );
end;

destructor TPGFunction.Destroy( );
begin
  FScript.Free;
  FTokenList.Free( );
  FVariantList.Free( );
  inherited Destroy( );
end;

procedure TPGFunction.Execute( Gramatica: TGramatica );
var
  C: Integer;
  CountParam: Integer;
  Gramatica2: TGramatica;
  VarTitulo: string;
  VarValor: Variant;
  Resultado: TPGVariant;
begin
  CountParam := LerParamentros( Gramatica, 0, Self.FVariantList.Count ) - 1;
  if not Gramatica.Erro then
  begin
    Gramatica2 := TGramatica.Create( '$Function: ' + Self.Name,
      Gramatica.Local, False );

    for C := Self.FVariantList.Count - 1 downto 0 do
    begin
      VarTitulo := Self.FVariantList[ C ].Name;

      if C > CountParam then
        VarValor := TPGVariant( Self.FVariantList[ C ] ).Value
      else
        VarValor := Gramatica.Pilha.Desempilhar
          ( TPGVariant( Self.FVariantList[ C ] ).Value );

      TPGVariant.Create( Gramatica2.Local, VarTitulo, VarValor, False );
    end;

    Resultado := TPGVariant.Create( Gramatica2.Local, 'Result', '', False );
    Gramatica2.SetTokens( Self.FTokenList );

    Gramatica2.Start;
    Gramatica2.WaitFor;
    Gramatica.Erro := Gramatica2.Erro;

    if not Gramatica.Erro then
    begin
      VarValor := Resultado.Value;
      Gramatica.Pilha.Empilhar( VarValor );
    end;

    Gramatica2.Free;
  end;
end;

procedure TPGFunction.Frame( AParent: TObject );
begin
  TPGFunctionFrame.Create( Self, AParent );
end;

class function TPGFunction.GetImageIndex: Integer;
begin
  Result := FImageIndex;
end;

function TPGFunction.GetScript: string;
begin
  Result := FScript.Text;
end;

procedure TPGFunction.SetScript( AValue: string );
begin
  FScript.Text := AValue;
end;

{ TPGFunctionDeclare }

procedure TPGFunctionDeclare.DeclaraNivel1( Gramatica: TGramatica;
  Nivel: TPGItem );
var
  Titulo: string;
  ID: TPGItem;
  Fuck: TPGFunction;
begin
  ID := IdentificadorLocalizar( Gramatica );
  if ( not Assigned( ID ) ) or ( ID is TPGFunction ) then
  begin
    if Assigned( ID ) then
    begin
      Fuck := TPGFunction( ID );
      Fuck.Free( );
    end;

    Titulo := Gramatica.TokenList.Token.Lexema;
    Fuck := TPGFunction.Create( Nivel, Titulo );

    Gramatica.TokenList.GetNextToken;
    if Gramatica.TokenList.Token.Classe = cmdLPar then
    begin
      Gramatica.TokenList.GetNextToken;
      if Gramatica.TokenList.Token.Classe = cmdID then
        TPGVariantDeclare.ExecuteEx( Gramatica, Fuck.FVariantList );

      if ( not Gramatica.Erro ) then
      begin
        if Gramatica.TokenList.Token.Classe = cmdRPar then
        begin
          Gramatica.TokenList.GetNextToken;
          if Gramatica.TokenList.Token.Classe = cmdDotComa then
          begin
            Gramatica.TokenList.GetNextToken;
            EncontrarFim( Gramatica, True, Fuck.FTokenList );
            if ( not Gramatica.Erro ) then
            begin
              Fuck.FScript.Text := copy( Gramatica.Script, FCordIni,
                Gramatica.TokenList.Token.Cordenada.Single - FCordIni );
            end;
          end
          else
            Gramatica.ErroAdd( '";" Esperado.' );
        end
        else
          Gramatica.ErroAdd( '")" Esperado.' );
      end;
    end
    else
      Gramatica.ErroAdd( '"(" Esperado.' );
  end
  else
    Gramatica.ErroAdd( 'Identificador esperado.' );
end;

procedure TPGFunctionDeclare.Execute( Gramatica: TGramatica );
begin
  FCordIni := Gramatica.TokenList.Token.Cordenada.Single;
  Gramatica.TokenList.GetNextToken;
  if Gramatica.TokenList.Token.Classe = cmdRes_global then
  begin
    Gramatica.TokenList.GetNextToken;
    DeclaraNivel1( Gramatica, TPGFunction.GlobList );
  end
  else
    DeclaraNivel1( Gramatica, Gramatica.Local );
end;

initialization

TPGFunctionDeclare.Create( GlobalItemCommand, 'Function' );
TPGFunction.GlobList := TPGFolder.Create( GlobalCollection, 'Functions' );
TPGFunction.FImageIndex := GlogalImageList.AddIcon( 'Function' );

finalization

end.
