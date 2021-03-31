unit PGofer.Sintatico.Classes;

interface

uses
  System.Generics.Collections, System.RTTI,
  PGofer.Classes, PGofer.Sintatico;

type
  {
    TPGAttributeType = (attText, attDocFile, attDocComent, attParam, attIcon);

    TPGRttiAttribute = class(TCustomAttribute)
    private
    FType: TPGAttributeType;
    FValue: String;
    public
    constructor Create(AttType: TPGAttributeType; Value: String); overload;
    destructor Destroy(); override;
    property AttType: TPGAttributeType read FType;
    property Value: String read FValue;
    end;
  }

  TPGItemCMD = class( TPGItem )
  private
    // FAttributeList: TObjectList<TPGRttiAttribute>;
    // constructor Create(ItemDad: TPGItem; Name: String;
    // Attrib: Boolean); overload;
    class var FImageIndex: Integer;
    procedure RttiCreate( );
  protected
    class function GetImageIndex( ): Integer; override;
    procedure RttiExecute( Gramatica: TGramatica; Item: TPGItemCMD );
  public
    constructor Create( ItemDad: TPGItem; Name: string = '' ); overload;
    destructor Destroy( ); override;
    procedure Execute( Gramatica: TGramatica ); virtual;
    // procedure AttributeAdd(AttType: TPGAttributeType; Value: String);
    // property AttributeList: TObjectList<TPGRttiAttribute>
    // read FAttributeList;
    function isItemExist( AName: string ): Boolean; virtual;
  end;

{$M+}

  TPGFolder = class( TPGItemCMD )
  private
    function GetExpanded( ): Boolean;
    procedure SetExpanded( Value: Boolean );
    class var FImageIndex: Integer;
  protected
    class function GetImageIndex( ): Integer; override;
  public
    constructor Create( ItemDad: TPGItem; Name: string = '' ); overload;
  published
    property _Expanded: Boolean read GetExpanded write SetExpanded;
  end;
{$TYPEINFO ON}

implementation

uses
  System.SysUtils, System.TypInfo,
  PGofer.Lexico, PGofer.Types, PGofer.Sintatico.Controls, PGofer.ImageList;

{ TPGAttribute }
{
  constructor TPGRttiAttribute.Create(AttType: TPGAttributeType; Value: String);
  begin
  FType := AttType;
  FValue := Value;
  end;

  destructor TPGRttiAttribute.Destroy();
  begin
  FType := attText;
  FValue := '';
  inherited Destroy();
  end;
}
{ TPGItemCMD }
constructor TPGItemCMD.Create( ItemDad: TPGItem; Name: string = '' );
begin
  if name = '' then
    name := copy( Self.ClassName, 4, Length( Self.ClassName ) );

  inherited Create( ItemDad, name );
  // FAttributeList := TObjectList<TPGRttiAttribute>.Create(True);
  Self.RttiCreate( );
end;

{
  constructor TPGItemCMD.Create(ItemDad: TPGItem; Name: String; Attrib: Boolean);
  begin
  inherited Create(ItemDad, Name);
  FAttributeList := TObjectList<TPGRttiAttribute>.Create(True);
  if Attrib then
  Self.RttiCreate();
  end;
}
destructor TPGItemCMD.Destroy( );
begin
  // FAttributeList.Free;
  inherited Destroy( );
end;

{
  procedure TPGItemCMD.AttributeAdd(AttType: TPGAttributeType; Value: String);
  begin
  FAttributeList.Add(TPGRttiAttribute.Create(AttType, Value));
  end;
}
procedure TPGItemCMD.Execute( Gramatica: TGramatica );
begin
  Gramatica.TokenList.GetNextToken;
  if Gramatica.TokenList.Token.Classe = cmdDot then
  begin
    Gramatica.TokenList.GetNextToken;
    Self.RttiExecute( Gramatica, Self );
  end;
end;

class function TPGItemCMD.GetImageIndex: Integer;
begin
  Result := FImageIndex;
end;

function TPGItemCMD.isItemExist( AName: string ): Boolean;
var
  Item: TPGItem;
begin
  Item := FindID( GlobalCollection, AName );
  Result := ( Assigned( Item ) and ( Item <> Self ) );
end;

procedure TPGItemCMD.RttiCreate( );
{
  procedure AttributesCreate(AtributeList: TArray<TCustomAttribute>;
  ItemAtt: TPGItemCMD);
  var
  RttiAttribute: TCustomAttribute;
  begin
  if ItemAtt.FAttributeList.Count = 0 then
  begin
  for RttiAttribute in AtributeList do
  begin
  if RttiAttribute is TPGRttiAttribute then
  begin
  with TPGRttiAttribute(RttiAttribute) do
  begin
  ItemAtt.AttributeAdd(FType, FValue);
  end;
  end;
  end;
  end;
  end;
}
  procedure CreateItems( RttiMemberList: TArray< TRttiMember > );
  var
    // ItemAux: TPGItem;
    RttiMember: TRttiMember;
  begin
    for RttiMember in RttiMemberList do
    begin
      if ( RttiMember.Visibility in [ mvPublished ] ) and
         ( RttiMember.Name[ LowString ] <> '_' ) then
      begin
        // ItemAux :=
        TPGItem.Create( Self, RttiMember.Name );
        // AttributesCreate(RttiMember.GetAttributes, ItemAux);
      end;
    end;
  end;

var
  RttiContext: TRttiContext;
  RttiType   : TRttiType;
begin
  RttiContext := TRttiContext.Create( );
  RttiType := RttiContext.GetType( Self.ClassType );
  // AttributesCreate(RttiType.GetAttributes, Self);

  if Self.CollectDad = GlobalCollection then
  begin
    CreateItems( TArray< TRttiMember >( RttiType.GetProperties ) );
    CreateItems( TArray< TRttiMember >( RttiType.GetMethods ) );
  end;

  RttiContext.Free;
end;

procedure TPGItemCMD.RttiExecute( Gramatica: TGramatica; Item: TPGItemCMD );
var
  RttiContext : TRttiContext;
  RttiType    : TRttiType;
  RttiProperty: TRttiProperty;
  RttiMethods : TRttiMethod;
  Parametros  : TArray< TRttiParameter >;
  Tamanho     : SmallInt;
  Valor       : TValue;
  Valores     : array of TValue;
  Aux         : Variant;
  ItemAux     : TPGItemCMD;
begin
  RttiContext := TRttiContext.Create( );
  RttiType := RttiContext.GetType( Item.ClassType );

  RttiProperty := RttiType.GetProperty( Gramatica.TokenList.Token.Lexema );
  if Assigned( RttiProperty ) and ( RttiProperty.Visibility in [ mvPublished ] )
  then
  begin
    if RttiProperty.IsReadable then
      Valor := RttiProperty.GetValue( Item );

    Aux := ConvertValueToVatiant( Valor, RttiProperty.PropertyType.TypeKind );
    Aux := Atribuicao( Gramatica, Aux );
    if not Gramatica.Erro then
    begin
      Valor := ConvertVatiantToValue( Aux, RttiProperty.PropertyType.TypeKind );

      if RttiProperty.IsWritable then
        RttiProperty.SetValue( Item, Valor );
    end;
  end else begin
    RttiMethods := RttiType.GetMethod( Gramatica.TokenList.Token.Lexema );
    if Assigned( RttiMethods ) and ( RttiMethods.Visibility in [ mvPublished ] )
    then
    begin
      Parametros := RttiMethods.GetParameters;
      Tamanho := Length( Parametros );
      SetLength( Valores, Tamanho );
      LerParamentros( Gramatica, Tamanho, Tamanho );
      if not Gramatica.Erro then
      begin
        for Tamanho := Tamanho - 1 downto 0 do
        begin
          Aux := Gramatica.Pilha.Desempilhar( '' );
          Valores[ Tamanho ] := ConvertVatiantToValue( Aux,
             Parametros[ Tamanho ].ParamType.TypeKind );
        end;

        if Assigned( RttiMethods.ReturnType ) then
        begin
          Valor := RttiMethods.Invoke( Item, Valores );
          Aux := ConvertValueToVatiant( Valor,
             RttiMethods.ReturnType.TypeKind );
          Gramatica.Pilha.Empilhar( Aux );
        end
        else
          RttiMethods.Invoke( Item, Valores );
      end;
    end else begin
      ItemAux := TPGItemCMD
         ( Item.FindName( Gramatica.TokenList.Token.Lexema ) );
      if Assigned( ItemAux ) then
      begin
        ItemAux.Execute( Gramatica );
      end
      else
        Gramatica.ErroAdd( 'Identificador não reconhecido: ' +
           Gramatica.TokenList.Token.Lexema );
    end;
  end;

  Valor.Empty;
  SetLength( Valores, 0 );
  SetLength( Parametros, 0 );
  RttiContext.Free;
end;

{ TPGFolder }

constructor TPGFolder.Create( ItemDad: TPGItem; Name: string );
begin
  inherited;
  Self.ReadOnly := False;
end;

function TPGFolder.GetExpanded: Boolean;
begin
  if Assigned( Node ) then
    Result := Node.Expanded
  else
    Result := False;
end;

class function TPGFolder.GetImageIndex: Integer;
begin
  Result := FImageIndex;
end;

procedure TPGFolder.SetExpanded( Value: Boolean );
begin
  if Assigned( Node ) then
    Node.Expanded := Value;
end;

initialization

TriggersCollect.RegisterClass( 'Folder', TPGFolder );
TPGItemCMD.FImageIndex := GlogalImageList.AddIcon( 'Method' );
TPGFolder.FImageIndex := GlogalImageList.AddIcon( 'Folder' );

finalization

end.
