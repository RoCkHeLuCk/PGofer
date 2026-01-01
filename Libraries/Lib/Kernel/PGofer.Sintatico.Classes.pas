unit PGofer.Sintatico.Classes;

interface

uses
  System.Generics.Collections, System.RTTI,
  PGofer.Types, PGofer.Classes, PGofer.Sintatico;

type
  [TPGAttribIcon(pgiMethod)]
  TPGItemCMD = class( TPGItem )
  private
    procedure RttiCreate( );
    function RttiGenerate(AObject: TRttiObject): string;
    function RttiAttrib(AObject: TRttiObject): string;
  protected
    procedure RttiExecute( Gramatica: TGramatica; AItem: TPGItemCMD );
  public
    constructor Create( AItemDad: TPGItem; AName: string = '' ); overload;
    destructor Destroy( ); override;
    procedure Execute( Gramatica: TGramatica ); virtual;
    function isItemExist( AName: string; ALocal: Boolean ): Boolean; virtual;
  end;

  {$M+}
  [TPGAttribIcon(pgiFolder)]
  TPGFolder = class( TPGItemCMD )
  private
    FExpanded: Boolean;
    procedure SetExpanded( AValue: Boolean );
  protected
    FLocked: Boolean;
    procedure SetLocked(AValue:Boolean); virtual;
  public
    constructor Create( AItemDad: TPGItem; AName: string = '' ); overload;
    destructor Destroy( ); override;
    property Locked: Boolean read FLocked write SetLocked;
  published
    property _Expanded: Boolean read FExpanded write SetExpanded;
  end;
  {$TYPEINFO ON}

implementation

uses
  System.TypInfo,
  PGofer.Lexico, PGofer.Sintatico.Controls, PGofer.IconList;

{ TPGItemCMD }
constructor TPGItemCMD.Create( AItemDad: TPGItem; AName: string = '' );
begin
  if AName = '' then
    AName := copy( Self.ClassName, 4, Length( Self.ClassName ) );

  inherited Create( AItemDad, AName );
  Self.RttiCreate( );
end;

destructor TPGItemCMD.Destroy( );
begin
  inherited Destroy( );
end;

procedure TPGItemCMD.Execute( Gramatica: TGramatica );
begin
  Gramatica.TokenList.GetNextToken;
  if Gramatica.TokenList.Token.Classe = cmdDot then
  begin
    Gramatica.TokenList.GetNextToken;
    Self.RttiExecute( Gramatica, Self );
  end;
end;

function TPGItemCMD.isItemExist( AName: string; ALocal: Boolean ): Boolean;
var
  Item: TPGItem;
begin
  if ALocal then
    Item := Self.Parent.FindName( AName )
  else
    Item := FindID( GlobalCollection, AName );

  Result := ( Assigned( Item ) and ( Item <> Self ) );
end;

function TPGItemCMD.RttiGenerate(AObject: TRttiObject): string;
var
  Method: TRttiMethod;
  Prop: TRttiProperty;
  Params: TArray<TRttiParameter>;
  i : SmallInt;
begin
  Result := '';

  if AObject is TRttiType then
  begin
    Result := 'Class ' + TRttiType(AObject).Name+ '; ';
  end else begin
    if AObject is TRttiProperty then
    begin
      Prop := TRttiProperty(AObject);
      Result := 'Property ' + Prop.Name + ': ' + Prop.PropertyType.Name + '; ';

      if Prop.IsReadable then
      begin
        Result := Result + '{Read';
      end;

      if Prop.IsWritable then
      begin
        if Prop.IsReadable then
        begin
          Result := Result + ',';
        end else begin
          Result := Result + '{';
        end;
        Result := Result + 'Write';
      end;
      Result := Result + '}';

    end else begin
      if AObject is TRttiMethod then
      begin
        Method := TRttiMethod(AObject);
        Result := 'Function ' + Method.Name + '(';
        Params := Method.GetParameters;
        for i := Low(Params) to High(Params) do
        begin
          Result := Result + Params[i].Name + ': ' + Params[i].ParamType.Name;
          if i < High(Params) then Result := Result + '; ';
        end;
        Result := Result + ')';
        if Method.ReturnType <> nil then
          Result := Result + ': ' + Method.ReturnType.Name;
        Result := Result + ';';
      end;
    end;
  end;
end;

function TPGItemCMD.RttiAttrib(AObject: TRttiObject): string;
var
  Attrib : TCustomAttribute;
begin
  Result := '';
  for Attrib in AObject.GetAttributes do
  begin
    if Attrib is TPGAttribText then
    begin
      Result := Result + TPGAttribText(Attrib).Text + #13;
    end else begin
      if Attrib is TPGAttribIcon then
      begin
         Self.IconIndex := Ord( TPGAttribIcon(Attrib).IconIndex );
      end;
    end;
  end;
end;

procedure TPGItemCMD.RttiCreate( );
  procedure CreateItems( RttiMemberList: TArray<TRttiMember> );
  var
    RttiMember: TRttiMember;
    Item: TPGItem;
  begin
    for RttiMember in RttiMemberList do
    begin
      if ( RttiMember.Visibility in [ mvPublished ] ) and
        ( RttiMember.Name[ LOW_STRING ] <> '_' ) then
      begin
        Item := TPGItem.Create( Self, RttiMember.Name );
        Item.About := Self.RttiGenerate(RttiMember);
        Item.About := Item.About + #13 + Self.RttiAttrib(RttiMember);
      end;
    end;
  end;

var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
begin
  RttiContext := TRttiContext.Create( );
  RttiType := RttiContext.GetType( Self.ClassType );

  Self.About := 'Class ' + Self.Name + ';';
  Self.About := Self.About + #13 + Self.RttiAttrib( RttiType );

  if Self.CollectDad = GlobalCollection then
  begin
    CreateItems( TArray<TRttiMember>( RttiType.GetProperties ) );
    CreateItems( TArray<TRttiMember>( RttiType.GetMethods ) );
  end;

  RttiContext.Free;
end;

procedure TPGItemCMD.RttiExecute( Gramatica: TGramatica; AItem: TPGItemCMD );
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
  RttiMethods: TRttiMethod;
  Parametros: TArray<TRttiParameter>;
  Tamanho: SmallInt;
  Valor: TValue;
  Valores: array of TValue;
  Aux: Variant;
  ItemAux: TPGItemCMD;
begin
  RttiContext := TRttiContext.Create( );
  RttiType := RttiContext.GetType( AItem.ClassType );

  RttiProperty := RttiType.GetProperty( Gramatica.TokenList.Token.Lexema );
  if Assigned( RttiProperty ) and ( RttiProperty.Visibility in [ mvPublished ] )
  then
  begin
    if RttiProperty.IsReadable then
      Valor := RttiProperty.GetValue( AItem );

    Aux := ConvertValueToVatiant( Valor, RttiProperty.PropertyType.TypeKind );
    Aux := Atribuicao( Gramatica, Aux );
    if not Gramatica.Erro then
    begin
      Valor := ConvertVatiantToValue( Aux, RttiProperty.PropertyType.TypeKind );

      if RttiProperty.IsWritable then
        RttiProperty.SetValue( AItem, Valor );
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
          Valor := RttiMethods.Invoke( AItem, Valores );
          Aux := ConvertValueToVatiant( Valor,
            RttiMethods.ReturnType.TypeKind );
          Gramatica.Pilha.Empilhar( Aux );
        end
        else
          RttiMethods.Invoke( AItem, Valores );
      end;
    end else begin
      ItemAux := TPGItemCMD
        ( AItem.FindName( Gramatica.TokenList.Token.Lexema ) );
      if Assigned( ItemAux ) and ( ItemAux is TPGItemCMD ) then
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
constructor TPGFolder.Create( AItemDad: TPGItem; AName: string );
begin
  inherited Create( AItemDad, AName );
  FLocked := False;
  FExpanded := False;
  Self.ReadOnly := False;
end;

destructor TPGFolder.Destroy( );
begin
  Self.ReadOnly := False;
  FLocked := False;
  FExpanded := False;
  inherited Destroy( );
end;

procedure TPGFolder.SetExpanded( AValue: Boolean );
begin
  if not FLocked then
  begin
    FExpanded := AValue;
    if Assigned( Self.Node ) then
      Self.Node.Expanded := FExpanded;
  end;
end;

procedure TPGFolder.SetLocked(AValue: Boolean);
begin
   FLocked := AValue;
   if FLocked then
     Self._Expanded := False;
end;

initialization

TriggersCollect.RegisterClass( 'Folder', TPGFolder );

finalization

end.
