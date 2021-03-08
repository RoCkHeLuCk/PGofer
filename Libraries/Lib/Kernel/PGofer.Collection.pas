unit PGofer.Collection;

interface

uses
   System.Classes, System.Generics.Collections,
   Vcl.Comctrls, Vcl.Forms,
   PGofer.Classes;

type

    TClassList = class
    private
        FNameList: TList<String>;
        FClassList: TList<TClass>;
    public
        constructor Create(); overload;
        destructor Destroy(); override;
        procedure Add(Name: String; Value: TClass);
        function Count(): Integer;
        function GetNameIndex(Index: Integer): String;
        function GetClassIndex(Index: Integer): TClass;
        function TryGetValue(Name: String; out Value: TClass): Boolean;
        function TryGetName(Value: TClass; out Name: String): Boolean;
    end;

    TPGItemCollect = class(TPGItem)
        constructor Create(AName: String); overload;
        destructor Destroy(); override;
    private
        FClassList: TClassList;
        FTreeView: TTreeView;
        FForm: TForm;
        procedure XMLSaveToFile(FileName: String);
        procedure XMLSaveToStream(Stream: TStream);
        procedure XMLLoadFromFile(FileName: String);
        procedure XMLLoadFromStream(Stream: TStream);
    public
        property Form: TForm read FForm;
        property TreeView: TTreeView read FTreeView;
        property RegClassList: TClassList read FClassList;
        procedure RegisterClass(AName:String; AClass: TClass);
        function GetRegClassName(AName: String): TClass;
        procedure TreeViewCreate();
        procedure TreeViewDestroy();
        procedure LoadFromFile();
        procedure UpdateToFile();
    end;


implementation

uses
    System.SysUtils, System.RTTI, System.TypInfo,
    XML.XMLDoc, XML.XMLIntf,
    PGofer.Item.Frame, PGofer.Sintatico.Classes,
    PGofer.Form.Controller;

{ TClassList }

function TClassList.Count(): Integer;
begin
    Result := Self.FNameList.Count;
end;

constructor TClassList.Create();
begin
    inherited;
    Self.FNameList := TList<String>.Create();
    Self.FClassList := TList<TClass>.Create();
end;

destructor TClassList.Destroy();
begin
    Self.FNameList.Free();
    Self.FClassList.Free();
    inherited;
end;

function TClassList.GetClassIndex(Index: Integer): TClass;
begin
    Result := Self.FClassList[Index];
end;

function TClassList.GetNameIndex(Index: Integer): String;
begin
    Result := Self.FNameList[Index];
end;

procedure TClassList.Add(Name: String; Value: TClass);
begin
    Self.FNameList.Add(Name);
    Self.FClassList.Add(Value);
end;

function TClassList.TryGetName(Value: TClass; out Name: String): Boolean;
begin
    if Self.FClassList.Contains(Value) then
    begin
       Name := Self.FNameList[Self.FClassList.IndexOf(Value)];
       Result := True;
    end else
       Result := False;
end;

function TClassList.TryGetValue(Name: String; out Value: TClass): Boolean;
begin
    if Self.FNameList.Contains(Name) then
    begin
       Value := Self.FClassList[Self.FNameList.IndexOf(Name)];
       Result := True;
    end else
       Result := False;
end;

{ TPGCollectItem }

constructor TPGItemCollect.Create(AName: String);
begin
    inherited Create(nil, AName);
    FClassList := TClassList.Create();
    FForm := TFrmController.Create(Self);
    FTreeView := TFrmController(FForm).TrvController;
end;

destructor TPGItemCollect.Destroy();
begin
    FClassList.Free();
    FForm.Free();
    FTreeView := nil;
    inherited;
end;

procedure TPGItemCollect.RegisterClass(AName:String; AClass: TClass);
begin
    FClassList.Add(AName, AClass);
end;

function TPGItemCollect.GetRegClassName(AName: String): TClass;
begin
    FClassList.TryGetValue(AName, Result);
end;

procedure TPGItemCollect.TreeViewCreate();

    procedure NodeCreate(Item: TPGItem);
    var
        Node: TTreeNode;
        ItemChild: TPGItem;
    begin
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
    for Item in Self do
        NodeCreate(Item);
end;

procedure TPGItemCollect.TreeViewDestroy();
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

procedure TPGItemCollect.XMLSaveToFile(FileName: String);
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

procedure TPGItemCollect.XMLSaveToStream(Stream: TStream);

    procedure CreateNode(Item: TPGItem; XMLNodeDad: IXMLNode);
    var
        RttiContext: TRttiContext;
        RttiType: TRttiType;
        RttiProperty : TRttiProperty;
        XMLNodeProperty: IXMLNode;
        XMLNode: IXMLNode;
        ItemChild: TPGItem;
        ItemOriginal: TPGItem;
        ClassName: String;
    begin
        if not FClassList.TryGetName(Item.ClassType, ClassName) then
           Exit;

        if Item is TPGItemMirror then
           ItemOriginal := TPGItemMirror(Item).ItemOriginal
        else
           ItemOriginal := Item;

        XMLNode := XMLNodeDad.AddChild( ClassName );
        XMLNode.Attributes['Name'] := ItemOriginal.Name;
        XMLNode.Attributes['Enabled'] := ItemOriginal.Enabled;
        XMLNode.Attributes['ReadOnly'] := ItemOriginal.ReadOnly;

        RttiContext := TRttiContext.Create();
        RttiType := RttiContext.GetType( ItemOriginal.ClassType );

        for RttiProperty in RttiType.GetProperties do
        begin
            if (RttiProperty.Visibility in [mvPublished])
            and (RttiProperty.IsWritable) then
            begin
                XMLNodeProperty := XMLNode.AddChild(RttiProperty.Name);
                XMLNodeProperty.Attributes['Type'] :=
                     RttiProperty.PropertyType.ToString;
                XMLNodeProperty.Text := RttiProperty.GetValue(ItemOriginal).ToString;
            end;
        end;

        RttiContext.Free;

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

procedure TPGItemCollect.XMLLoadFromFile(FileName: String);
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

procedure TPGItemCollect.XMLLoadFromStream(Stream: TStream);

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
        ItemOriginal : TPGItem;
        Name : String;
    begin
        if (not FClassList.TryGetValue(XMLNode.NodeName, ClassRegister))
        or (not XMLNode.HasAttribute('Name')) then
           Exit;

        Name := XMLNode.Attributes['Name'];
        RttiContext := TRttiContext.Create();
        RttiType := RttiContext.GetType(ClassRegister);
        Value := RttiType.GetMethod('Create').Invoke( ClassRegister,
                              [ItemDad, Name]);
        Item := TPGItem(Value.AsObject);

        if Item is TPGItemMirror then
        begin
           ItemOriginal := TPGItemMirror(Item).ItemOriginal;
           RttiContext.Free;
           RttiContext := TRttiContext.Create();
           RttiType := RttiContext.GetType(ItemOriginal.ClassType);
        end else
           ItemOriginal := Item;

        if XMLNode.HasAttribute('Enabled') then
           ItemOriginal.Enabled := XMLNode.Attributes['Enabled'];

        if XMLNode.HasAttribute('ReadOnly') then
           ItemOriginal.ReadOnly := XMLNode.Attributes['ReadOnly'];


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
                                   ItemOriginal,
                                   StrToIntDef(XMLNodeProperty.Text,0));
                           tkEnumeration :
                               RttiProperty.SetValue(
                                   ItemOriginal,
                                   StrToBoolDef(XMLNodeProperty.Text,False));
                           tkFloat :
                               RttiProperty.SetValue(
                                   ItemOriginal,
                                   StrToFloatDef(XMLNodeProperty.Text,0));
                           tkString,
                           tkLString,
                           tkWString,
                           tkUString :
                               RttiProperty.SetValue(
                                   ItemOriginal,
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

        RttiContext.Free;

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
    try
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
    except
    end;
end;

end.
