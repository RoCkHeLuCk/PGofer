unit PGofer.Classes;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Forms, Vcl.Comctrls,
  PGofer.Component.TreeView;

const
  LowString = low( string );

type
  TPGItemCollect = class;

  TPGItem = class( TObjectList<TPGItem> )
  private
    FName: string;
    FAbout: string;
    FEnabled: Boolean;
    FReadOnly: Boolean;
    FParent: TPGItem;
    FNode: TTreeNode;
    procedure SetParent( AParent: TPGItem );
    function GetCollectDad( ): TPGItemCollect;
    procedure SetNode( AValue: TTreeNode );
  protected
    procedure SetName( AName: string ); virtual;
    procedure SetEnabled( AValue: Boolean ); virtual;
    procedure SetReadOnly( AValue: Boolean ); virtual;
    function GetIsValid( ): Boolean; virtual;
    class function GetImageIndex( ): Integer; virtual;
  public
    constructor Create( AParent: TPGItem; AName: string ); overload;
    destructor Destroy( ); override;
    property About: string read FAbout write FAbout;
    property Name: string read FName write SetName;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property readonly: Boolean read FReadOnly write SetReadOnly;
    property isValid: Boolean read GetIsValid;
    property Parent: TPGItem read FParent write SetParent;
    property Node: TTreeNode read FNode write SetNode;
    property CollectDad: TPGItemCollect read GetCollectDad;
    procedure Frame( AParent: TObject ); virtual;
    function FindName( AName: string ): TPGItem;
    function FindNameList( AName: string; APartial: Boolean ): TArray<TPGItem>;
  end;

  TClassList = class
  private
    FNameList: TList<string>;
    FClassList: TList<TClass>;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
    procedure Add( AName: string; AValue: TClass );
    function Count( ): Integer;
    function GetNameIndex( AIndex: Integer ): string;
    function GetClassIndex( AIndex: Integer ): TClass;
    function TryGetValue( AName: string; out OValue: TClass ): Boolean;
    function TryGetName( AValue: TClass; out OName: string ): Boolean;
  end;

  TPGItemCollect = class( TPGItem )
    constructor Create( AName: string; ALoadFile: Boolean = False ); overload;
    destructor Destroy( ); override;
  private
    FClassList: TClassList;
    FTreeView: TTreeViewEx;
    FForm: TForm;
    FFileName: string;
    procedure XMLSaveToStream( AStream: TStream );
    procedure XMLSaveToFile( AFileName: string );
    procedure XMLSaveToFileEncrypted( AFileName, APassword: string );
    procedure XMLLoadFromStream( AStream: TStream );
    procedure XMLLoadFromFile( AFileName: string );
    procedure XMLLoadFromFileEncrypted( AFileName, APassword: string );
  public
    property TreeView: TTreeViewEx read FTreeView;
    property RegClassList: TClassList read FClassList;
    procedure RegisterClass( AName: string; AClass: TClass );
    function GetRegClassName( AName: string ): TClass;
    procedure TreeViewAttach( );
    procedure TreeViewDetach( );
    procedure FormShow( );

    procedure LoadFromFile( );
    procedure SaveToFile( );
  end;

implementation

uses
  System.SysUtils, System.RTTI, System.TypInfo,
  XML.XMLDoc, XML.XMLIntf,
  PGofer.Item.Frame, PGofer.Sintatico, PGofer.Sintatico.Classes,
  PGofer.Forms.Controller, PGofer.Triggers, PGofer.Files.Encrypt;

{ TPGItem }

constructor TPGItem.Create( AParent: TPGItem; AName: string );
begin
  inherited Create( True );
  FName := AName;
  FAbout := '';
  FEnabled := True;
  FReadOnly := True;
  FNode := nil;
  FParent := AParent;
  if Assigned( AParent ) then
  begin
    AParent.Add( Self );
    if Assigned( AParent.FNode ) then
    begin
      Self.Node := TTreeView( AParent.FNode.TreeView )
        .Items.AddChild( AParent.FNode, FName );
    end else begin
      if ( AParent is TPGItemCollect ) and
        ( Assigned( TPGItemCollect( AParent ).TreeView ) ) then
      begin
        Self.Node := TPGItemCollect( AParent ).TreeView.Items.AddChild
          ( nil, FName );
      end;
    end;
  end;
end;

destructor TPGItem.Destroy( );
begin
  if Assigned( FNode ) and ( not FNode.Deleting ) then
  begin
    FNode.Data := nil;
    FNode.Free( );
  end;
  FNode := nil;

  FName := '';
  FAbout := '';
  FEnabled := False;
  FReadOnly := False;
  if Assigned( FParent ) then
    FParent.Extract( Self );
  FParent := nil;
  inherited Destroy( );
end;

procedure TPGItem.SetEnabled( AValue: Boolean );
begin
  FEnabled := AValue;
  if Assigned( FNode ) then
  begin
    FNode.Enabled := FEnabled;
  end;
end;

procedure TPGItem.SetParent( AParent: TPGItem );
var
  OwnerNode: TTreeNode;
begin
  if FParent <> AParent then
  begin
    if Assigned( FParent ) then
      FParent.Extract( Self );

    if Assigned( AParent ) then
      AParent.Add( Self );

    FParent := AParent;
  end;

  if Assigned( FNode ) then
  begin
    if Assigned( FParent ) then
      OwnerNode := FParent.Node
    else
      OwnerNode := nil;

    FNode.MoveTo( OwnerNode, naAddChild );
  end;
end;

procedure TPGItem.SetReadOnly( AValue: Boolean );
begin
  FReadOnly := AValue;
end;

procedure TPGItem.SetName( AName: string );
begin
  FName := AName;
  if Assigned( FNode ) then
  begin
    FNode.Text := FName;
  end;
end;

procedure TPGItem.SetNode( AValue: TTreeNode );
begin
  FNode := AValue;
  if Assigned( FNode ) then
  begin
    FNode.Data := Self;
    Self.Node.ImageIndex := GetImageIndex( );
    Self.Node.SelectedIndex := GetImageIndex( );
    Self.Node.ExpandedImageIndex := GetImageIndex( );
  end;
end;

procedure TPGItem.Frame( AParent: TObject );
begin
  TPGItemFrame.Create( Self, AParent );
end;

function TPGItem.GetCollectDad: TPGItemCollect;
begin
  if Assigned( Self.Parent ) then
    Result := Self.Parent.CollectDad
  else if Self is TPGItemCollect then
    Result := TPGItemCollect( Self )
  else
    Result := nil;
end;

class function TPGItem.GetImageIndex: Integer;
begin
  Result := 0;
end;

function TPGItem.GetIsValid: Boolean;
begin
  Result := True;
end;

function TPGItem.FindName( AName: string ): TPGItem;
var
  C: FixedInt;
begin
  Result := nil;
  C := 0;
  while ( C < Self.Count ) and ( not Assigned( Result ) ) do
  begin
    if SameText( AName, Self[ C ].Name ) then
      Result := Self[ C ];
    inc( C );
  end;
end;

function TPGItem.FindNameList( AName: string; APartial: Boolean )
  : TArray<TPGItem>;
var
  Item: TPGItem;
begin
  SetLength( Result, 0 );
  for Item in Self do
  begin
    if ( APartial and ( Pos( LowerCase( AName ), LowerCase( Item.Name ) ) > 0 )
      ) or ( not APartial and SameText( AName, Item.Name ) ) or ( AName = '' )
    then
    begin
      Result := Result + [ Item ];
    end;
  end;
end;

{ TClassList }

function TClassList.Count( ): Integer;
begin
  Result := Self.FNameList.Count;
end;

constructor TClassList.Create( );
begin
  inherited Create( );
  Self.FNameList := TList<string>.Create( );
  Self.FClassList := TList<TClass>.Create( );
end;

destructor TClassList.Destroy( );
begin
  Self.FNameList.Free( );
  Self.FClassList.Free( );
  inherited Destroy( );
end;

function TClassList.GetClassIndex( AIndex: Integer ): TClass;
begin
  Result := Self.FClassList[ AIndex ];
end;

function TClassList.GetNameIndex( AIndex: Integer ): string;
begin
  Result := Self.FNameList[ AIndex ];
end;

procedure TClassList.Add( AName: string; AValue: TClass );
begin
  Self.FNameList.Add( AName );
  Self.FClassList.Add( AValue );
end;

function TClassList.TryGetName( AValue: TClass; out OName: string ): Boolean;
begin
  if Self.FClassList.Contains( AValue ) then
  begin
    OName := Self.FNameList[ Self.FClassList.IndexOf( AValue ) ];
    Result := True;
  end
  else
    Result := False;
end;

function TClassList.TryGetValue( AName: string; out OValue: TClass ): Boolean;
begin
  if Self.FNameList.Contains( AName ) then
  begin
    OValue := Self.FClassList[ Self.FNameList.IndexOf( AName ) ];
    Result := True;
  end else begin
    Result := False;
  end;
end;

{ TPGCollectItem }

constructor TPGItemCollect.Create( AName: string; ALoadFile: Boolean = False );
begin
  inherited Create( nil, AName );
  FClassList := TClassList.Create( );
  if ALoadFile then
  begin
    FFileName := PGofer.Sintatico.DirCurrent + '\' + AName;
  end else begin
    FFileName := '';
  end;
end;

destructor TPGItemCollect.Destroy( );
begin
  FTreeView := nil;
  if Assigned( FForm ) then
    FForm.Free( );
  FClassList.Free( );
  FFileName := '';
  inherited Destroy( );
end;

procedure TPGItemCollect.FormShow;
begin
  FForm.Show;
end;

procedure TPGItemCollect.RegisterClass( AName: string; AClass: TClass );
begin
  FClassList.Add( AName, AClass );
end;

function TPGItemCollect.GetRegClassName( AName: string ): TClass;
begin
  FClassList.TryGetValue( AName, Result );
end;

procedure TPGItemCollect.TreeViewAttach( );

  procedure NodeAttach( Item: TPGItem );
  var
    Node: TTreeNode;
    ItemChild: TPGItem;
  begin
    if Assigned( Item.Parent ) then
      Node := Item.Parent.Node
    else
      Node := nil;

    Item.Node := FTreeView.Items.AddChild( Node, Item.Name );

    for ItemChild in Item do
      NodeAttach( ItemChild );
  end;

var
  Item: TPGItem;
begin
  if Assigned( FForm ) then
  begin
    FTreeView := TFrmController( FForm ).TrvController;
    for Item in Self do
      NodeAttach( Item );
  end;
end;

procedure TPGItemCollect.TreeViewDetach( );
  procedure NodeDetach( Item: TPGItem );
  var
    ItemChild: TPGItem;
  begin
    if Assigned( Item.Node ) then
    begin
      for ItemChild in Item do
        NodeDetach( ItemChild );
      Item.Node.Data := nil;
      Item.Node := nil;
    end;
  end;

var
  Item: TPGItem;
begin
  if Assigned( FTreeView ) then
  begin
    for Item in Self do
      NodeDetach( Item );

    FTreeView.Items.Clear( );
    FTreeView := nil;
  end;
end;

procedure TPGItemCollect.XMLSaveToStream( AStream: TStream );

  procedure CreateNode( Item: TPGItem; XMLNodeDad: IXMLNode );
  var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    RttiProperty: TRttiProperty;
    XMLNodeProperty: IXMLNode;
    XMLNode: IXMLNode;
    ItemChild: TPGItem;
    ItemOriginal: TPGItem;
    ClassName: string;
  begin
    if not FClassList.TryGetName( Item.ClassType, ClassName ) then
      Exit;

    if Item is TPGItemMirror then
      ItemOriginal := TPGItemMirror( Item ).ItemOriginal
    else
      ItemOriginal := Item;

    XMLNode := XMLNodeDad.AddChild( ClassName );
    XMLNode.Attributes[ 'Name' ] := ItemOriginal.Name;
    XMLNode.Attributes[ 'Enabled' ] := ItemOriginal.Enabled;
    XMLNode.Attributes[ 'ReadOnly' ] := ItemOriginal.ReadOnly;

    RttiContext := TRttiContext.Create( );
    RttiType := RttiContext.GetType( ItemOriginal.ClassType );

    for RttiProperty in RttiType.GetProperties do
    begin
      if ( RttiProperty.Visibility in [ mvPublished ] ) and
        ( RttiProperty.IsReadable ) and ( RttiProperty.IsWritable ) then
      begin
        XMLNodeProperty := XMLNode.AddChild( RttiProperty.Name );
        XMLNodeProperty.Attributes[ 'Type' ] :=
          RttiProperty.PropertyType.ToString;
        XMLNodeProperty.Text := RttiProperty.GetValue( ItemOriginal ).ToString;
      end;
    end;

    RttiContext.Free;

    for ItemChild in Item do
      CreateNode( ItemChild, XMLNode );
  end;

var
  XMLDocument: IXMLDocument;
  XMLRoot: IXMLNode;
  Item: TPGItem;
begin
  XMLDocument := NewXMLDocument;
  XMLDocument.Encoding := 'utf-8';
  XMLDocument.Options := [ doNodeAutoCreate, doNodeAutoIndent ];
  XMLDocument.Active := True;
  XMLRoot := XMLDocument.AddChild( Self.Name );
  XMLRoot.Attributes[ 'Version' ] := '1.0';
  for Item in Self do
  begin
    CreateNode( Item, XMLRoot );
  end;
  XMLDocument.SaveToStream( AStream );
  XMLDocument.Active := False;
end;

procedure TPGItemCollect.XMLSaveToFile( AFileName: string );
var
  Stream: TStream;
begin
  Stream := TFileStream.Create( AFileName, fmCreate );
  try
    Self.XMLSaveToStream( Stream );
  finally
    Stream.Free;
  end;
end;

procedure TPGItemCollect.XMLSaveToFileEncrypted(AFileName, APassword: string);
var
  MemStr: TMemoryStream;
  FileStr: TFileStream;
begin
  if APassword = '' then
  begin
      Self.XMLSaveToFile(AFileName);
      Exit;
  end;

  MemStr := TMemoryStream.Create;
  try
    Self.XMLSaveToStream( MemStr );

    MemStr.Position := 0;
    FileStr := TFileStream.Create( AFileName, fmCreate );
    try
      if not AESEncryptStream(MemStr, FileStr, APassword) then
        raise Exception.Create('Falha na criptografia AES ao salvar.');
    finally
      FileStr.Free;
    end;
  finally
    MemStr.Free;
  end;
end;

procedure TPGItemCollect.XMLLoadFromStream( AStream: TStream );

  procedure CreateItem( ItemDad: TPGItem; XMLNode: IXMLNode );
  var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    RttiProperty: TRttiProperty;
    XMLNodeProperty: IXMLNode;
    XMLNodeChild: IXMLNode;
    ClassRegister: TClass;
    Value: TValue;
    Item: TPGItem;
    ItemOriginal: TPGItem;
    NodeName: string;
  begin
    if ( not FClassList.TryGetValue( XMLNode.NodeName, ClassRegister ) ) or
      ( not XMLNode.HasAttribute( 'Name' ) ) then
      Exit;

    NodeName := XMLNode.Attributes[ 'Name' ];
    RttiContext := TRttiContext.Create( );
    RttiType := RttiContext.GetType( ClassRegister );
    Value := RttiType.GetMethod( 'Create' ).Invoke( ClassRegister,
      [ ItemDad, NodeName ] );
    Item := TPGItem( Value.AsObject );

    if Item is TPGItemMirror then
    begin
      ItemOriginal := TPGItemMirror( Item ).ItemOriginal;
      RttiContext.Free;
      RttiContext := TRttiContext.Create( );
      RttiType := RttiContext.GetType( ItemOriginal.ClassType );
    end
    else
      ItemOriginal := Item;

    if XMLNode.HasAttribute( 'Enabled' ) then
      ItemOriginal.Enabled := XMLNode.Attributes[ 'Enabled' ];

    if XMLNode.HasAttribute( 'ReadOnly' ) then
      ItemOriginal.ReadOnly := XMLNode.Attributes[ 'ReadOnly' ];

    for RttiProperty in RttiType.GetProperties do
    begin
      if ( RttiProperty.Visibility in [ mvPublished ] ) and
        ( RttiProperty.IsReadable ) and ( RttiProperty.IsWritable ) then
      begin
        XMLNodeProperty := XMLNode.ChildNodes.FindNode( RttiProperty.Name );
        if Assigned( XMLNodeProperty ) then
        begin
          try
            case RttiProperty.PropertyType.TypeKind of
              tkInteger:
                RttiProperty.SetValue( ItemOriginal,
                  StrToIntDef( XMLNodeProperty.Text, 0 ) );
              tkEnumeration:
                RttiProperty.SetValue( ItemOriginal,
                  StrToBoolDef( XMLNodeProperty.Text, False ) );
              tkFloat:
                RttiProperty.SetValue( ItemOriginal,
                  StrToFloatDef( XMLNodeProperty.Text, 0 ) );
              tkString, tkLString, tkWString, tkUString:
                RttiProperty.SetValue( ItemOriginal,
                  UnicodeString( XMLNodeProperty.Text ) );
            end;
          except
            raise Exception.Create( 'Erro: "' + XMLNode.NodeName + '", Campo "'
              + RttiProperty.Name + '" contem valor invalido.' );
          end;
        end;
      end;
    end;

    RttiContext.Free;

    XMLNodeChild := XMLNode.ChildNodes.First( );
    while Assigned( XMLNodeChild ) do
    begin
      CreateItem( Item, XMLNodeChild );
      XMLNodeChild := XMLNodeChild.NextSibling( );
    end;
  end;

var
  XMLDocument: IXMLDocument;
  XMLNode: IXMLNode;
begin
  Self.Clear;
  XMLDocument := NewXMLDocument;
  try
    XMLDocument.LoadFromStream( AStream );
    XMLDocument.Active := True;
    XMLNode := XMLDocument.ChildNodes.FindNode( Self.Name );
    if Assigned( XMLNode ) then
    begin
      XMLNode := XMLNode.ChildNodes.First;
      while Assigned( XMLNode ) do
      begin
        CreateItem( Self, XMLNode );
        XMLNode := XMLNode.NextSibling;
      end;
    end;
    XMLDocument.Active := False;
  except
  end;
end;

procedure TPGItemCollect.XMLLoadFromFile( AFileName: string );
var
  Stream: TStream;
begin
  Stream := TFileStream.Create( AFileName, fmOpenRead );
  try
    Self.XMLLoadFromStream( Stream );
  finally
    Stream.Free;
  end;
end;

procedure TPGItemCollect.XMLLoadFromFileEncrypted(AFileName, APassword: string);
var
  FileStr: TFileStream;
  MemStr: TMemoryStream;
begin
  FileStr := TFileStream.Create( AFileName, fmOpenRead or fmShareDenyWrite );
  try
    MemStr := TMemoryStream.Create;
    try
      if AESDecryptStream(FileStr, MemStr, APassword) then
      begin
        MemStr.Position := 0;
        Self.XMLLoadFromStream( MemStr );
      end else
        raise Exception.Create('Senha incorreta ou arquivo corrompido.');
    finally
      MemStr.Free;
    end;
  finally
    FileStr.Free;
  end;
end;

procedure TPGItemCollect.LoadFromFile( );
begin
  Self.FForm := TFrmController.Create( Self );
  if ( Self.FFileName <> '' ) and FileExists( Self.FFileName ) then
    Self.XMLLoadFromFile( Self.FFileName );
end;

procedure TPGItemCollect.SaveToFile( );
begin
  if ( Self.FFileName <> '' ) then
    Self.XMLSaveToFile( Self.FFileName );
end;

initialization

finalization

end.
