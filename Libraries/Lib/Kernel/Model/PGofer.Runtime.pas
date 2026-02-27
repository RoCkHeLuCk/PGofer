unit PGofer.Runtime;

interface

uses
  System.Generics.Collections, System.RTTI,
  PGofer.Classes, PGofer.Sintatico;

type
  TPGItemClass = class( TPGItem )
  private
    procedure RttiCreate( );
  protected
    function GetAbout(): String; override;
    function TryExecuteChild( AGramatica: TGramatica ): Boolean;
    function GetNextChild( AGramatica: TGramatica ): TPGItem;
  public
    constructor Create( AItemDad: TPGItem; AName: string = ''); reintroduce; virtual;
    destructor Destroy( ); override;
    procedure Execute( AGramatica: TGramatica ); virtual;
  end;

  TPGItemMember = class( TPGItem )
  private
  protected
    FMember : TRttiMember;
  public
    constructor Create( AItemDad: TPGItem; AMember: TRttiMember ); overload; virtual;
    destructor Destroy( ); override;
    procedure Execute( AGramatica: TGramatica ); virtual; abstract;
  end;

  TPGItemProperty = class( TPGItemMember )
  private
  protected
    function GetAbout(): String; override;
  public
    constructor Create( AItemDad: TPGItem; AMember: TRttiMember ); override;
    procedure Execute( AGramatica: TGramatica ); override;
  end;

  TPGItemMethod = class( TPGItemMember )
  private
  protected
    function GetAbout(): String; override;
  public
    procedure Execute( AGramatica: TGramatica ); override;
  end;

  {$M+}
  TPGFolder = class( TPGItem )
  private
  protected
  public
  published
  end;
  {$TYPEINFO ON}

  procedure ScriptExec( AName, AScript: string; ANivel: TPGItem = nil; AWaitFor: Boolean = False );
  function FileScriptExec( FileName: string; Esperar: Boolean ): Boolean;


var
  GlobalCollection: TPGItemCollect;
  GlobalItemCommand: TPGItem;
  GlobalItemTrigger: TPGItem;

implementation

uses
  System.Classes, System.SysUtils, System.TypInfo,
  PGofer.Core, PGofer.Lexico, PGofer.Sintatico.Controls;

{ TPGItemCMD }

constructor TPGItemClass.Create( AItemDad: TPGItem; AName: string);
begin
  if AName = '' then
    AName := Self.ClassNameEx;
  inherited Create( AItemDad, AName );
  Self.RttiCreate( );
end;

destructor TPGItemClass.Destroy( );
begin
  inherited Destroy( );
end;

function TPGItemClass.GetAbout(): String;
var
  LClassAbout: TDictionary<string, string>;
  LAux: String;
begin
  Result := '';

  if not FAbout.TryGetValue(Self.ClassType, LClassAbout) then
  begin
    LClassAbout := TDictionary<string, string>.Create;
    LClassAbout.Clear;
    FAbout.Add(Self.ClassType, LClassAbout);
  end;

  if not LClassAbout.TryGetValue('', Result) then
  begin
    Result := 'Class '+ Self.ClassNameEx + ';';
    LAux := TPGAttribText.GetFromClass(TPGItemClass);
    if LAux <> '' then
      Result := Result + #13 + LAux;
    LClassAbout.Add('', Result);
  end;
end;

function TPGItemClass.GetNextChild( AGramatica: TGramatica ): TPGItem;
var
  LPGItem : TPGItem;
begin
  Result := nil;
  AGramatica.TokenList.GetNextToken;
  if AGramatica.TokenList.Token.Classe = cmdDot then
  begin
    AGramatica.TokenList.GetNextToken;
    LPGItem := Self.FindName( AGramatica.TokenList.Token.Lexema );
    if Assigned(LPGItem) and ((LPGItem is TPGItemClass) or (LPGItem is TPGItemMember)) then
      Result := LPGItem
    else
      AGramatica.ErroAdd('Error_Interpreter_Unrecog');
  end;
end;

function TPGItemClass.TryExecuteChild( AGramatica: TGramatica ): Boolean;
var
  LPGItem : TPGItem;
begin
  Result := False;
  LPGItem := Self.GetNextChild( AGramatica );
  if Assigned(LPGItem) then
  begin
    TPGItemMember(LPGItem).Execute(AGramatica);
    Result := not AGramatica.Erro;
  end;
end;

procedure TPGItemClass.Execute( AGramatica: TGramatica );
begin
  if not Self.TryExecuteChild( AGramatica ) then
    AGramatica.ErroAdd('Error_Interpreter_.');
end;

procedure TPGItemClass.RttiCreate( );
var
  LRttiType: TRttiType;
  LRttiProperty: TRttiProperty;
  LRttiMethod: TRttiMethod;
  LRttiField: TRttiField;
  LRttiInstanceType: TRttiInstanceType;
  LMetaClass: TClass;
  LObject: TObject;
begin
  LRttiType := TPGKernel.RttiContext.GetType(Self.ClassType);
  if Self.CollectDad = GlobalCollection then
  begin
    //Property
    for LRttiProperty in LRttiType.GetProperties do
    begin
      if (LRttiProperty.Visibility = mvPublished) and (not LRttiProperty.Name.StartsWith('_')) then
      begin
        //Object
        if LRttiProperty.PropertyType.IsInstance then
        begin
          LRttiInstanceType := TRttiInstanceType(LRttiProperty.PropertyType);
          LRttiMethod := LRttiInstanceType.GetMethod('Create');
          if not Assigned(LRttiMethod) then
            continue;

          LMetaClass := LRttiInstanceType.MetaclassType;
          LObject := nil;

          //TPGItemClass
          if LMetaClass.InheritsFrom(TPGItemClass) then
            LObject := LRttiMethod.Invoke( LMetaClass, [Self, LRttiProperty.Name] ).AsObject
          else
             continue;  //while there are no others
          //others
          //.....

          if not Assigned(LObject) then
            continue;

          //set value
          if LRttiProperty.IsWritable then
            LRttiProperty.SetValue(Self, LObject)
          else begin
            LRttiField := LRttiType.GetField('F' + LRttiProperty.Name);
            if Assigned(LRttiField) then
              LRttiField.SetValue(Self, LObject);
          end;
        end else begin
          //Variable
          TPGItemProperty.Create(Self, LRttiProperty);
        end;
      end;
    end;

    //Method
    for LRttiMethod in LRttiType.GetMethods do
      if (LRttiMethod.Visibility = mvPublished) and (not LRttiMethod.Name.StartsWith('_')) then
        TPGItemMethod.Create(Self, LRttiMethod);
  end;
end;

{ TPGItemMember }

constructor TPGItemMember.Create(AItemDad: TPGItem; AMember: TRttiMember);
begin
  inherited Create(AItemDad, AMember.Name );
  FMember := AMember;
end;

destructor TPGItemMember.Destroy( );
begin
  FMember := nil;
  inherited Destroy;
end;

{ TPGFolder }


{ TPGItemProperty }

constructor TPGItemProperty.Create(AItemDad: TPGItem; AMember: TRttiMember);
begin
  inherited;
  Self.ReadOnly := not TRttiProperty(AMember).IsWritable;
end;

procedure TPGItemProperty.Execute(AGramatica: TGramatica);
var
  LRttiProperty: TRttiProperty;
  LValue: TValue;
  LAux: Variant;
begin
  LRttiProperty := TRttiProperty(FMember);
  if LRttiProperty.IsReadable then
    LValue := LRttiProperty.GetValue( Self.Parent );

  LAux := ConvertValueToVariant( LValue, LRttiProperty.PropertyType.TypeKind );
  LAux := Atribuicao( AGramatica, LAux );
  if not AGramatica.Erro then
  begin
    LValue := ConvertVariantToValue( LAux, LRttiProperty.PropertyType.TypeKind );
    if LRttiProperty.IsWritable then
      LRttiProperty.SetValue( Self.Parent, LValue );
  end;

  LValue.Empty;
end;

function TPGItemProperty.GetAbout(): String;
var
  LClassAbout: TDictionary<string, string>;
  LProp: TRttiProperty;
  LAux: String;
begin
  Result := '';

  if not FAbout.TryGetValue(Self.Parent.ClassType, LClassAbout) then
  begin
    LClassAbout := TDictionary<string, string>.Create;
    LClassAbout.Clear;
    FAbout.Add(Self.Parent.ClassType, LClassAbout);
  end;

  if not LClassAbout.TryGetValue(Self.Name, Result) then
  begin
    LProp := TRttiProperty(FMember);
    Result := 'Property ' + LProp.Name + ': ' + LProp.PropertyType.Name + '; {';
    if LProp.IsReadable then
      Result := Result + 'R';

    if LProp.IsWritable then
    begin
      if LProp.IsReadable then
        Result := Result + ',';
      Result := Result + 'W';
    end;
    Result := Result + '}';
    LAux := TPGAttribText.GetFromProperty(LProp);
    if LAux <> '' then
      Result := Result + #13 + LAux;
    LClassAbout.Add(Self.Name, Result);
  end;
end;

{ TPGItemMethod }

procedure TPGItemMethod.Execute(AGramatica: TGramatica);
var
  LRttiMethods: TRttiMethod;
  LParameters: TArray<TRttiParameter>;
  LValue: TValue;
  LValues: array of TValue;
  LAux: Variant;
  LMaxParams, LQtdeLida, I: Integer;
begin
  LRttiMethods := TRttiMethod(FMember);
  LParameters := LRttiMethods.GetParameters;

  LMaxParams := Length( LParameters );
  SetLength( LValues, LMaxParams );
  LQtdeLida := LerParamentros( AGramatica, LMaxParams, LMaxParams );
  if not AGramatica.Erro then
  begin
    for I := LQtdeLida - 1 downto 0 do
    begin
      LAux := AGramatica.Pilha.Desempilhar( '' );
      LValues[ I ] := ConvertVariantToValue( LAux,
        LParameters[ I ].ParamType.TypeKind );
    end;

    if Assigned( LRttiMethods.ReturnType ) then
    begin
      LValue := LRttiMethods.Invoke( Self.Parent, LValues );
      LAux := ConvertValueToVariant( LValue,
        LRttiMethods.ReturnType.TypeKind );
      AGramatica.Pilha.Empilhar( LAux );
    end
    else
      LRttiMethods.Invoke( Self.Parent, LValues );
  end;

  LValue.Empty;
  SetLength( LValues, 0 );
  SetLength( LParameters, 0 );
end;

function TPGItemMethod.GetAbout(): String;
var
  LClassAbout: TDictionary<string, string>;
  LMethod: TRttiMethod;
  LParams: TArray<TRttiParameter>;
  LIndex : SmallInt;
  LPrefix, LAux: string;
  LFlag: TParamFlag;
begin
  Result := '';

  if not FAbout.TryGetValue(Self.Parent.ClassType, LClassAbout) then
  begin
    LClassAbout := TDictionary<string, string>.Create;
    LClassAbout.Clear;
    FAbout.Add(Self.Parent.ClassType, LClassAbout);
  end;

  if not LClassAbout.TryGetValue(Self.Name, Result) then
  begin
    LMethod := TRttiMethod(FMember);
    Result := 'Function ' + Self.Name + '(';
    LParams := LMethod.GetParameters;
    for LIndex := Low(LParams) to High(LParams) do
    begin
      for LFlag := Low(TParamFlag) to High(TParamFlag) do
      begin
        if LFlag <> pfResult then
          LPrefix := GetEnumName(TypeInfo(TParamFlag), Ord(LFlag)).Substring(2) + ' ';
      end;
      Result := Result + LPrefix + LParams[LIndex].Name + ': ' + LParams[LIndex].ParamType.Name;
      LAux := TPGAttribText.GetFromParameter(LParams[LIndex]);
      if LAux <> '' then
        Result := Result + ' ['+LAux+']';
      if LIndex < High(LParams) then
        Result := Result + '; ';
    end;
    Result := Result + ')';
    if LMethod.ReturnType <> nil then
      Result := Result + ': ' + LMethod.ReturnType.Name;
    Result := Result + ';';

    LAux := TPGAttribText.GetFromMethod(LMethod);
    if LAux <> '' then
      Result := Result + #13 + LAux;

    LClassAbout.Add(Self.Name, Result);
  end;
end;

procedure ScriptExec( AName, AScript: string; ANivel: TPGItem = nil; AWaitFor: Boolean = False );
var
  Gramatica: TGramatica;
begin
  if not Assigned( ANivel ) then
    ANivel := GlobalCollection;

  Gramatica := TGramatica.Create( AName, ANivel, not AWaitFor );
  Gramatica.SetScript( AScript );
  Gramatica.Start;
  if AWaitFor then
  begin
    Gramatica.WaitFor( );
    Gramatica.Free( );
  end;
end;

function FileScriptExec( FileName: string; Esperar: Boolean ): Boolean;
var
  Texto: TStringList;
begin
  if FileExists( FileName ) then
  begin
    Texto := TStringList.Create;
    Texto.LoadFromFile( FileName );
    ScriptExec( 'FileScript: ' + ExtractFileName( FileName ), Texto.Text, nil, Esperar );
    Texto.Free;
    Result := True;
  end
  else
    Result := False;
end;

initialization
  GlobalCollection := TPGItemCollect.Create( 'Globals' );
  GlobalItemCommand := TPGFolder.Create( GlobalCollection, 'Commands' );

finalization
  GlobalCollection.Free;

end.

