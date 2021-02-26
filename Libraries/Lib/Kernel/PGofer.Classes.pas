unit PGofer.Classes;

interface

uses
    System.Classes,
    System.Generics.Collections, Vcl.Comctrls;

const
    LowString = Low(String);

type
    TPGCollectItem = class;

    TPGItem = class(TObjectList<TPGItem>)
        constructor Create(AParent: TPGItem; Name: String); overload;
        destructor Destroy(); override;
    private
        FName: String;
        FEnabled: Boolean;
        FReadOnly: Boolean;
        FParent: TPGItem;
        FNode: TTreeNode;
        procedure SetName(Name: String);
        procedure SetEnabled(Value: Boolean);
        procedure SetParent(AParent: TPGItem);
        function GetCollectDad(): TPGCollectItem;
    public
        property Name: String read FName write SetName;
        property Enabled: Boolean read FEnabled write SetEnabled;
        property ReadOnly: Boolean read FReadOnly write FReadOnly;
        property Parent: TPGItem read FParent write SetParent;
        property Node: TTreeNode read FNode write FNode;
        property CollectDad: TPGCollectItem read GetCollectDad;
        procedure Frame(Parent: TObject); virtual;
        function FindName(Name: String): TPGItem;
        function FindNameList(Name: String; Partial: Boolean): TArray<TPGItem>;
    end;

    TPGCollectItem = class(TPGItem)
        constructor Create(AName: String;
                           AOnlyRegister: Boolean = False); overload;
        destructor Destroy(); override;
    private
        FClassList: TList<TClass>;
        FTreeView: TTreeView;
        FOnlyRegister: Boolean;
    public
        property ClassList: TList<TClass> read FClassList;
        property OnlyRegister: Boolean read FOnlyRegister;
        procedure RegisterClass(AClass: TClass);
        procedure RegisterClasses(AClasses: TList<TClass>);
        function GetRegisterClass(AClassName: String): TClass;
        procedure TreeViewCreate(ATreeView: TTreeView);
        procedure TreeViewDestroy();
        procedure XMLSaveToFile(FileName: String);
        procedure XMLSaveToStream(Stream: TStream);
        procedure XMLLoadFromFile(FileName: String);
        procedure XMLLoadFromStream(Stream: TStream);
    end;

implementation

uses
    System.SysUtils, System.RTTI, System.TypInfo,
    XML.XMLDoc, XML.XMLIntf,
    PGofer.Item.Frame;

{ TPGItem }

constructor TPGItem.Create(AParent: TPGItem; Name: String);
begin
    inherited Create(True);
    FName := Name;
    FEnabled := True;
    FReadOnly := True;
    FNode := nil;
    FParent := AParent;
    if Assigned(AParent) then
    begin
        AParent.Add(Self);
        if Assigned(AParent.FNode) then
        begin
            FNode := TTreeView(AParent.FNode.TreeView)
                    .Items.AddChild(AParent.FNode, FName);
            FNode.Data := Self;
        end else begin
            if (AParent is TPGCollectItem)
            and(Assigned(TPGCollectItem(AParent).FTreeView)) then
            begin
                FNode := TPGCollectItem(AParent).FTreeView
                        .Items.AddChild(nil, FName);
                FNode.Data := Self;
            end;
        end;
    end;

end;

destructor TPGItem.Destroy();
begin
    if Assigned(FNode) and (not FNode.Deleting) then
    begin
        FNode.Data := nil;
        FNode.Free();
    end;
    FNode := nil;

    FName := '';
    FEnabled := False;
    FReadOnly := False;
    if Assigned(FParent) then
        FParent.Extract(Self);
    FParent := nil;
    inherited Destroy();
end;

procedure TPGItem.SetEnabled(Value: Boolean);
begin
    FEnabled := Value;
    if Assigned(FNode) then
    begin
       FNode.Enabled := FEnabled;
    end;
end;

procedure TPGItem.SetParent(AParent: TPGItem);
var
    OwnerNode: TTreeNode;
begin
    if FParent <> AParent then
    begin
        if Assigned(FParent) then
           FParent.Extract(Self);

        if Assigned(AParent) then
           AParent.Add(Self);

        FParent := AParent;
    end;

    if Assigned(FNode) then
    begin
        if Assigned(FParent) then
            OwnerNode := FParent.Node
        else
            OwnerNode := nil;

        FNode.MoveTo(OwnerNode, naAddChild);
    end;
end;

procedure TPGItem.SetName(Name: String);
begin
    FName := Name;
    if Assigned(FNode) then
    begin
       FNode.Text := FName;
    end;
end;

procedure TPGItem.Frame(Parent: TObject);
begin
    TPGFrame.Create(Self, Parent);
end;

function TPGItem.GetCollectDad: TPGCollectItem;
begin
    if Assigned(Self.Parent) then
       Result := Self.Parent.CollectDad
    else if Self is TPGCollectItem then
       Result := TPGCollectItem(Self)
    else
       Result := nil;
end;

function TPGItem.FindName(Name: String): TPGItem;
var
    C: FixedInt;
begin
    Result := nil;
    C := 0;
    while (C < Self.Count) and (not Assigned(Result)) do
    begin
        if SameText(Name, Self[C].Name) then
            Result := Self[C];
        inc(C);
    end;
end;

function TPGItem.FindNameList(Name: String; Partial: Boolean): TArray<TPGItem>;
var
    Item : TPGItem;
begin
    SetLength(Result,0);
    for Item in Self do
    begin
        if (Partial and (Pos(LowerCase(Name),LowerCase(Item.Name)) > 0))
        or (not Partial and SameText(Name, Item.Name))
        or (Name = '') then
        begin
            Result := Result + [Item];
        end;
    end;
end;

{ TPGCollectItem }

constructor TPGCollectItem.Create(AName: String;
                                  AOnlyRegister: Boolean = False);
begin
    inherited Create(nil, AName);
    FClassList := TList<TClass>.Create();
    FOnlyRegister := AOnlyRegister;
end;

destructor TPGCollectItem.Destroy();
begin
    FClassList.Free;
    inherited;
end;

procedure TPGCollectItem.RegisterClass(AClass: TClass);
begin
    FClassList.Add(AClass);
end;

procedure TPGCollectItem.RegisterClasses(AClasses: TList<TClass>);
begin
    FClassList.AddRange(AClasses);
end;

function TPGCollectItem.GetRegisterClass(AClassName: String): TClass;
var
    C, L : integer;
begin
    C := 0;
    L := FClassList.Count-1;

    while (C < L) and (FClassList[C].ClassName <> AClassName) do
      Inc(C);

    if (FClassList[C].ClassName = AClassName) then
       Result := FClassList[C]
    else
       Result := nil;
end;

procedure TPGCollectItem.TreeViewCreate(ATreeView: TTreeView);

    procedure NodeCreate(Item: TPGItem);
    var
        Node: TTreeNode;
        ItemChild: TPGItem;
    begin
        //if FOnlyRegister
        //and (not Self.FClassList.Contains(Item.ClassType)) then
        //   exit;

        if Assigned(Item.Parent) then
            Node := Item.Parent.Node
        else
            Node := nil;
        Item.Node := FTreeView.Items.AddChild(Node, Item.Name);
        Item.Node.Data := Item;
        for ItemChild in Item do
            NodeCreate(ItemChild);
    end;

var
    Item: TPGItem;
begin
    FTreeView := ATreeView;
    for Item in Self do
        NodeCreate(Item);
end;

procedure TPGCollectItem.TreeViewDestroy;
    procedure NodeDestroy(Item: TPGItem);
    var
        ItemChild: TPGItem;
    begin
        if Assigned(Item.Node) then
        begin
            for ItemChild in Item do
                NodeDestroy(ItemChild);
            Item.Node.Data := nil;
            Item.Node := nil;
        end;
    end;

var
    Item: TPGItem;
begin
    for Item in Self do
        NodeDestroy(Item);
    FTreeView := nil;
end;

procedure TPGCollectItem.XMLSaveToFile(FileName: String);
var
    Stream: TStream;
begin
    Stream := TFileStream.Create(FileName, fmCreate);
    try
        Self.XMLSaveToStream(Stream);
    finally
        Stream.Free;
    end;
end;

procedure TPGCollectItem.XMLSaveToStream(Stream: TStream);

    procedure CreateNode(Item: TPGItem; XMLNodeDad: IXMLNode);
    var
        RttiContext: TRttiContext;
        RttiType: TRttiType;
        RttiProperty : TRttiProperty;
        XMLNodeProperty: IXMLNode;
        XMLNode: IXMLNode;
        ItemChild: TPGItem;
    begin
        if not FClassList.Contains(Item.ClassType) then
           Exit;

        XMLNode := XMLNodeDad.AddChild( Item.ClassName );
        XMLNode.Attributes['Name'] := Item.Name;
        XMLNode.Attributes['Enabled'] := Item.Enabled;

        RttiContext := TRttiContext.Create();
        RttiType := RttiContext.GetType( Item.ClassType );

        for RttiProperty in RttiType.GetProperties do
        begin
            if (RttiProperty.Visibility in [mvPublished])
            and (RttiProperty.IsWritable) then
            begin
                XMLNodeProperty := XMLNode.AddChild(RttiProperty.Name);
                XMLNodeProperty.Attributes['Type'] :=
                     RttiProperty.PropertyType.ToString;
                XMLNodeProperty.Text := RttiProperty.GetValue(Item).ToString;
            end;
        end;

        for ItemChild in Item do
            CreateNode(ItemChild, XMLNode);
    end;

var
    XMLDocument: IXMLDocument;
    XMLRoot: IXMLNode;
    Item: TPGItem;
begin
    XMLDocument := NewXMLDocument;
    XMLDocument.Encoding := 'utf-8';
    XMLDocument.Options := [doNodeAutoCreate,doNodeAutoIndent];
    XMLDocument.Active := true;
    XMLRoot := XMLDocument.AddChild(Self.Name);
    XMLRoot.Attributes['Version'] := '1.0';
    for Item in Self do
    begin
        CreateNode(Item, XMLRoot);
    end;
    XMLDocument.SaveToStream(Stream);
    XMLDocument.Active := False;
end;

procedure TPGCollectItem.XMLLoadFromFile(FileName: String);
var
    Stream: TStream;
begin
    Stream := TFileStream.Create(FileName, fmOpenRead);
    try
        Self.XMLLoadFromStream(Stream);
    finally
        Stream.Free;
    end;
end;

procedure TPGCollectItem.XMLLoadFromStream(Stream: TStream);

    procedure CreateItem(ItemDad: TPGItem; XMLNode: IXMLNode);
    var
        RttiContext: TRttiContext;
        RttiType: TRttiType;
        RttiProperty : TRttiProperty;
        XMLNodeProperty: IXMLNode;
        XMLNodeChild: IXMLNode;
        ClassRegister : TClass;
        Value: TValue;
        Item : TPGItem;
        Name : String;
    begin
        ClassRegister := Self.GetRegisterClass(XMLNode.NodeName);
        if (not Assigned(ClassRegister))
        or (not XMLNode.HasAttribute('Name')) then
           Exit;

        Name := XMLNode.Attributes['Name'];
        RttiContext := TRttiContext.Create();
        RttiType := RttiContext.GetType(ClassRegister);
        Value := RttiType.GetMethod('Create').Invoke( ClassRegister,
                              [ItemDad, Name]);
        Item := TPGItem(Value.AsObject);

        if XMLNode.HasAttribute('Enabled') then
           Item.Enabled := XMLNode.Attributes['Enabled'];

        for RttiProperty in RttiType.GetProperties do
        begin
            if (RttiProperty.Visibility in [mvPublished]) then
            begin
                XMLNodeProperty := XMLNode.ChildNodes.FindNode(
                     RttiProperty.Name);
                if Assigned(XMLNodeProperty) then
                begin
                    try
                       case RttiProperty.PropertyType.TypeKind of
                           tkInteger :
                               RttiProperty.SetValue(
                                   Item,
                                   StrToIntDef(XMLNodeProperty.Text,0));
                           tkEnumeration :
                               RttiProperty.SetValue(
                                   Item,
                                   StrToBoolDef(XMLNodeProperty.Text,False));
                           tkFloat :
                               RttiProperty.SetValue(
                                   Item,
                                   StrToFloatDef(XMLNodeProperty.Text,0));
                           tkString,
                           tkLString,
                           tkWString,
                           tkUString :
                               RttiProperty.SetValue(
                                   Item,
                                   XMLNodeProperty.Text);
                       end;
                    except
                        raise Exception.Create(
                            'Erro: "'+ XMLNode.NodeName
                            +'", Campo "'+RttiProperty.Name
                            +'" contem valor invalido.');
                    end;
                end;
            end;
        end;

        XMLNodeChild := XMLNode.ChildNodes.First();
        while Assigned(XMLNodeChild) do
        begin
            CreateItem(Item, XMLNodeChild);
            XMLNodeChild := XMLNodeChild.NextSibling();
        end;
    end;

var
    XMLDocument: IXMLDocument;
    XMLNode: IXMLNode;
begin
    Self.Clear;
    XMLDocument := NewXMLDocument;
    XMLDocument.LoadFromStream(Stream);
    XMLDocument.Active := true;
    XMLNode := XMLDocument.ChildNodes.FindNode(Self.Name);
    if Assigned(XMLNode) then
    begin
        XMLNode := XMLNode.ChildNodes.First;
        while Assigned(XMLNode) do
        begin
            CreateItem(Self, XMLNode);
            XMLNode := XMLNode.NextSibling;
        end;
    end;
    XMLDocument.Active := False;
end;

initialization

finalization

end.
