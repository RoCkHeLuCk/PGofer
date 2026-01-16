unit PGofer.Classes;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Comctrls,
  XML.XMLIntf,
  PGofer.Component.Form,
  PGofer.Component.TreeView,
  PGofer.Core;

type
  TPGItemCollect = class;
  TClassList = class;

  TPGItem = class(TObjectList<TPGItem>)
  private
    FName: string;
    FAbout: string;
    FEnabled: Boolean;
    FReadOnly: Boolean;
    FIconIndex: Integer;
    FParent: TPGItem;
    FNode: TTreeNode;
    procedure SetParent(AParent: TPGItem);
    function GetCollectDad(): TPGItemCollect;
    procedure SetNode(AValue: TTreeNode);
    procedure UpdateIconIndex();
  protected
    procedure SetName(AName: string); virtual;
    procedure SetEnabled(AValue: Boolean); virtual;
    function GetIsValid(): Boolean; virtual;

    function BeforeXMLSave(ItemCollect: TPGItemCollect): Boolean; virtual;
    function BeforeXMLLoad(ItemCollect: TPGItemCollect): Boolean; virtual;

    procedure SetIconIndex(AIconIndex: Integer);
  public
    constructor Create(AParent: TPGItem; AName: string); overload;
    destructor Destroy(); override;
    property About: string read FAbout write FAbout;
    property Name: string read FName write SetName;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property IconIndex: Integer read FIconIndex write SetIconIndex;
    property isValid: Boolean read GetIsValid;
    property Parent: TPGItem read FParent write SetParent;
    property Node: TTreeNode read FNode write SetNode;
    property CollectDad: TPGItemCollect read GetCollectDad;
    procedure Frame(AParent: TObject); virtual;
    function FindName(AName: string): TPGItem;
    function FindNameList(AName: string; APartial: Boolean): TArray<TPGItem>;
  end;

  TClassList = class
  private
    FNameList: TList<string>;
    FClassList: TList<TClass>;
  protected
  public
    constructor Create(); overload;
    destructor Destroy(); override;
    procedure Add(AName: string; AValue: TClass);
    function Count(): Integer;
    function GetNameIndex(AIndex: Integer): string;
    function GetClassIndex(AIndex: Integer): TClass;
    function TryGetValue(AName: string; out OValue: TClass): Boolean;
    function TryGetName(AValue: TClass; out OName: string): Boolean;
  end;

  TPGItemCollect = class(TPGItem)
    constructor Create(AName: string; ALoadFile: Boolean = False); overload;
    destructor Destroy(); override;
  private
    FClassList: TClassList;
    FTreeView: TTreeViewEx;
    FForm: TFormEx;
    FFileName: string;
  protected
  public
    procedure XMLLoadFromStream(ItemFirst: TPGItem; AXMLStream: TStream);
    procedure XMLLoadFromFile();
    procedure XMLSaveToStream(ItemFirst: TPGItem; AXMLStream: TStream);
    procedure XMLSaveToFile();
    property TreeView: TTreeViewEx read FTreeView;
    property RegClassList: TClassList read FClassList;
    procedure RegisterClass(AName: string; AClass: TClass);
    function GetRegClassName(AName: string): TClass;
    procedure TreeViewAttach();
    procedure TreeViewDetach();
    procedure FormShow();
  end;

implementation

uses
  System.SysUtils, System.RTTI, System.TypInfo,

  XML.XMLDoc,
  PGofer.Language, PGofer.Item.Frame,
  PGofer.Forms.Controller, PGofer.Triggers;

{ TPGItem }

constructor TPGItem.Create(AParent: TPGItem; AName: string);
begin
  inherited Create(True);
  FName := AName;
  FAbout := '';
  FEnabled := True;
  FReadOnly := True;
  FIconIndex := 0;
  FNode := nil;
  FParent := AParent;
  if Assigned(AParent) then
  begin
    AParent.Add(Self);
    if Assigned(AParent.FNode) then
    begin
      Self.Node := TTreeView(AParent.FNode.TreeView).Items.AddChild(AParent.FNode, FName);
    end else begin
      if (AParent is TPGItemCollect) and (Assigned(TPGItemCollect(AParent).TreeView)) then
      begin
        Self.Node := TPGItemCollect(AParent).TreeView.Items.AddChild(nil, FName);
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
  FAbout := '';
  FEnabled := False;
  FReadOnly := False;
  FIconIndex := 0;
  if Assigned(FParent) then
    FParent.Extract(Self);
  FParent := nil;
  inherited Destroy();
end;

procedure TPGItem.SetEnabled(AValue: Boolean);
begin
  FEnabled := AValue;
  if Assigned(FNode) then
  begin
    FNode.Enabled := FEnabled;
  end;
end;

procedure TPGItem.UpdateIconIndex();
begin
  if Assigned(FNode) then
  begin
    FNode.ImageIndex := FIconIndex;
    FNode.SelectedIndex := FIconIndex;
    FNode.ExpandedImageIndex := FIconIndex;
  end;
end;

procedure TPGItem.SetIconIndex(AIconIndex: Integer);
begin
  FIconIndex := AIconIndex;
  Self.UpdateIconIndex();
end;

procedure TPGItem.SetNode(AValue: TTreeNode);
begin
  FNode := AValue;
  if Assigned(FNode) then
  begin
    FNode.Data := Self;
    Self.UpdateIconIndex();
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

procedure TPGItem.SetName(AName: string);
begin
  FName := AName;
  if Assigned(FNode) then
  begin
    FNode.Text := FName;
  end;
end;

procedure TPGItem.Frame(AParent: TObject);
begin
  TPGItemFrame.Create(Self, AParent);
end;

function TPGItem.GetCollectDad: TPGItemCollect;
begin
  if Assigned(Self.Parent) then
    Result := Self.Parent.CollectDad
  else if Self is TPGItemCollect then
    Result := TPGItemCollect(Self)
  else
    Result := nil;
end;

function TPGItem.GetIsValid: Boolean;
begin
  Result := True;
end;

function TPGItem.BeforeXMLSave(ItemCollect: TPGItemCollect): Boolean;
begin
  Result := True;
end;

function TPGItem.BeforeXMLLoad(ItemCollect: TPGItemCollect): Boolean;
begin
  Result := True;
end;

function TPGItem.FindName(AName: string): TPGItem;
var
  C: FixedInt;
begin
  Result := nil;
  C := 0;
  while (C < Self.Count) and (not Assigned(Result)) do
  begin
    if SameText(AName, Self[C].Name) then
      Result := Self[C];
    inc(C);
  end;
end;

function TPGItem.FindNameList(AName: string; APartial: Boolean): TArray<TPGItem>;
var
  Item: TPGItem;
begin
  SetLength(Result, 0);
  for Item in Self do
  begin
    if (APartial and (Pos(LowerCase(AName), LowerCase(Item.Name)) > 0)) or
      (not APartial and SameText(AName, Item.Name)) or (AName = '') then
    begin
      Result := Result + [Item];
    end;
  end;
end;

{ TClassList }

function TClassList.Count(): Integer;
begin
  Result := Self.FNameList.Count;
end;

constructor TClassList.Create();
begin
  inherited Create();
  Self.FNameList := TList<string>.Create();
  Self.FClassList := TList<TClass>.Create();
end;

destructor TClassList.Destroy();
begin
  Self.FNameList.Free();
  Self.FClassList.Free();
  inherited Destroy();
end;

function TClassList.GetClassIndex(AIndex: Integer): TClass;
begin
  Result := Self.FClassList[AIndex];
end;

function TClassList.GetNameIndex(AIndex: Integer): string;
begin
  Result := Self.FNameList[AIndex];
end;

procedure TClassList.Add(AName: string; AValue: TClass);
begin
  Self.FNameList.Add(AName);
  Self.FClassList.Add(AValue);
end;

function TClassList.TryGetName(AValue: TClass; out OName: string): Boolean;
begin
  if Self.FClassList.Contains(AValue) then
  begin
    OName := Self.FNameList[Self.FClassList.IndexOf(AValue)];
    Result := True;
  end
  else
    Result := False;
end;

function TClassList.TryGetValue(AName: string; out OValue: TClass): Boolean;
begin
  if Self.FNameList.Contains(AName) then
  begin
    OValue := Self.FClassList[Self.FNameList.IndexOf(AName)];
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

{ TPGCollectItem }

constructor TPGItemCollect.Create(AName: string; ALoadFile: Boolean = False);
begin
  inherited Create(nil, AName);
  FClassList := TClassList.Create();
  if ALoadFile then
  begin
    FFileName := TPGKernel.GetVar('_PathCurrent','') + AName + '.xml';
  end else begin
    FFileName := '';
  end;
end;

destructor TPGItemCollect.Destroy();
begin
  FTreeView := nil;
  if Assigned(FForm) then
    FForm.Free();
  FClassList.Free();
  FFileName := '';
  inherited Destroy();
end;

procedure TPGItemCollect.FormShow();
begin
  FForm.ForceShow(True);
end;

procedure TPGItemCollect.RegisterClass(AName: string; AClass: TClass);
begin
  FClassList.Add(AName, AClass);
end;

function TPGItemCollect.GetRegClassName(AName: string): TClass;
begin
  FClassList.TryGetValue(AName, Result);
end;

procedure TPGItemCollect.TreeViewAttach();

  procedure NodeAttach(Item: TPGItem);
  var
    Node: TTreeNode;
    ItemChild: TPGItem;
  begin
    if Assigned(Item.Parent) then
      Node := Item.Parent.Node
    else
      Node := nil;

    Item.Node := FTreeView.Items.AddChild(Node, Item.Name);

    for ItemChild in Item do
      NodeAttach(ItemChild);
  end;

var
  Item: TPGItem;
begin
  if Assigned(FForm) then
  begin
    FTreeView := TFrmController(FForm).TrvController;
    for Item in Self do
      NodeAttach(Item);
  end;
end;

procedure TPGItemCollect.TreeViewDetach();
  procedure NodeDetach(Item: TPGItem);
  var
    ItemChild: TPGItem;
  begin
    if Assigned(Item.Node) then
    begin
      for ItemChild in Item do
        NodeDetach(ItemChild);
      Item.Node.Data := nil;
      Item.Node := nil;
    end;
  end;

var
  Item: TPGItem;
begin
  if Assigned(FTreeView) then
  begin
    for Item in Self do
      NodeDetach(Item);

    FTreeView.Items.Clear();
    FTreeView := nil;
  end;
end;

procedure TPGItemCollect.XMLSaveToStream(ItemFirst: TPGItem; AXMLStream: TStream);

  procedure CreateNode(Item: TPGItem; XMLNodeDad: IXMLNode);
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
    if not FClassList.TryGetName(Item.ClassType, ClassName) then
      Exit;

    if Item is TPGItemMirror then
      ItemOriginal := TPGItemMirror(Item).ItemOriginal
    else
      ItemOriginal := Item;

    XMLNode := XMLNodeDad.AddChild(ClassName);
    XMLNode.Attributes['Name'] := ItemOriginal.Name;
    XMLNode.Attributes['Enabled'] := ItemOriginal.Enabled;
    XMLNode.Attributes['ReadOnly'] := ItemOriginal.ReadOnly;

    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(ItemOriginal.ClassType);

    for RttiProperty in RttiType.GetProperties do
    begin
      if (RttiProperty.Visibility in [mvPublished]) and (RttiProperty.IsReadable) and
        (RttiProperty.IsWritable) then
      begin
        XMLNodeProperty := XMLNode.AddChild(RttiProperty.Name);
        XMLNodeProperty.Attributes['Type'] := RttiProperty.PropertyType.ToString;
        XMLNodeProperty.Text := RttiProperty.GetValue(ItemOriginal).ToString;
      end;
    end;

    RttiContext.Free;

    if ItemOriginal.BeforeXMLSave(Self) then
      for ItemChild in Item do
        CreateNode(ItemChild, XMLNode);
  end;

var
  XMLDocument: IXMLDocument;
  XMLRoot: IXMLNode;
  Item: TPGItem;
begin
  if Assigned(AXMLStream) then
  begin
    XMLDocument := NewXMLDocument;
    XMLDocument.Encoding := 'utf-8';
    XMLDocument.Options := [doNodeAutoCreate, doNodeAutoIndent];
    XMLDocument.Active := True;
    XMLRoot := XMLDocument.AddChild(ItemFirst.Name);
    XMLRoot.Attributes['Version'] := '1.0';
    for Item in ItemFirst do
    begin
      CreateNode(Item, XMLRoot);
    end;
    AXMLStream.Position := 0;
    XMLDocument.SaveToStream(AXMLStream);
    XMLDocument.Active := False;
  end;
end;

procedure TPGItemCollect.XMLSaveToFile();
var
  FileStream: TFileStream;
  MemStream: TMemoryStream;
begin
  if (FFileName <> '') then
  begin
    MemStream := TMemoryStream.Create;
    try
      try
        Self.XMLSaveToStream(Self, MemStream);
        MemStream.Position := 0;
        FileStream := TFileStream.Create(FFileName, fmCreate);
        try
          FileStream.CopyFrom(MemStream, 0);
        finally
          FileStream.Free;
        end;
      except
        on E: Exception do TrC('Error_XML_Save', [FFileName, E.Message]);
      end;
    finally
      MemStream.Free;
    end;
  end;
end;

procedure TPGItemCollect.XMLLoadFromStream(ItemFirst: TPGItem; AXMLStream: TStream);

  procedure CreateItem(ItemDad: TPGItem; XMLNode: IXMLNode);
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
    if (not FClassList.TryGetValue(XMLNode.NodeName, ClassRegister)) or
      (not XMLNode.HasAttribute('Name')) then
      Exit;

    NodeName := XMLNode.Attributes['Name'];
    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(ClassRegister);
    Value := RttiType.GetMethod('Create').Invoke(ClassRegister, [ItemDad, NodeName]);
    Item := TPGItem(Value.AsObject);

    if Item is TPGItemMirror then
    begin
      ItemOriginal := TPGItemMirror(Item).ItemOriginal;
      RttiContext.Free;
      RttiContext := TRttiContext.Create();
      RttiType := RttiContext.GetType(ItemOriginal.ClassType);
    end else begin
      ItemOriginal := Item;
    end;

    if XMLNode.HasAttribute('Enabled') then
      ItemOriginal.Enabled := XMLNode.Attributes['Enabled'];

    if XMLNode.HasAttribute('ReadOnly') then
      ItemOriginal.ReadOnly := XMLNode.Attributes['ReadOnly'];

    for RttiProperty in RttiType.GetProperties do
    begin
      if (RttiProperty.Visibility in [mvPublished]) and (RttiProperty.IsReadable) and
        (RttiProperty.IsWritable) then
      begin
        XMLNodeProperty := XMLNode.ChildNodes.FindNode(RttiProperty.Name);
        if Assigned(XMLNodeProperty) then
        begin
          try
            case RttiProperty.PropertyType.TypeKind of
              tkInteger:
                RttiProperty.SetValue(ItemOriginal, StrToIntDef(XMLNodeProperty.Text, 0));
              tkEnumeration:
                RttiProperty.SetValue(ItemOriginal, StrToBoolDef(XMLNodeProperty.Text, False));
              tkFloat:
                RttiProperty.SetValue(ItemOriginal, StrToFloatDef(XMLNodeProperty.Text, 0));
              tkString, tkLString, tkWString, tkUString:
                RttiProperty.SetValue(ItemOriginal, UnicodeString(XMLNodeProperty.Text));
            end;
          except
            TrC('Error_XML_LoadValue',[XMLNode.NodeName, RttiProperty.Name, FFileName]);
          end;
        end;
      end;
    end;

    RttiContext.Free;
    if ItemOriginal.BeforeXMLLoad(Self) then
    begin
      XMLNodeChild := XMLNode.ChildNodes.First();
      while Assigned(XMLNodeChild) do
      begin
        CreateItem(Item, XMLNodeChild);
        XMLNodeChild := XMLNodeChild.NextSibling();
      end;
    end;
  end;

var
  XMLDocument: IXMLDocument;
  XMLRoot, XMLNode: IXMLNode;
begin
  if Assigned(AXMLStream) then
  begin
    ItemFirst.Clear;
    XMLDocument := NewXMLDocument;
    try
      AXMLStream.Position := 0;
      try
        XMLDocument.LoadFromStream(AXMLStream);
        XMLDocument.Active := True;
        XMLRoot := XMLDocument.DocumentElement;
      except
        TrC('Error_XML_Load',[FFileName]);
      end;
      if Assigned(XMLRoot) then
      begin
        XMLNode := XMLRoot.ChildNodes.First;
        while Assigned(XMLNode) do
        begin
          CreateItem(ItemFirst, XMLNode);
          XMLNode := XMLNode.NextSibling;
        end;
      end;
    finally
      XMLDocument.Active := False;
    end;
  end;
end;

procedure TPGItemCollect.XMLLoadFromFile();
var
  Stream: TStream;
begin
  if not Assigned(FForm) then
  begin
    FForm := TFrmController.Create(Self);
  end;

  if (FFileName <> '') and FileExists(FFileName) then
  begin
    Stream := TFileStream.Create(FFileName, fmOpenRead);
    try
      Self.XMLLoadFromStream(Self, Stream);
    finally
      Stream.Free;
    end;
  end;
end;

initialization

finalization

end.
