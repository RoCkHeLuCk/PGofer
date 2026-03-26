unit PGofer.Triggers.Collections;

interface

uses
 System.Classes, System.Generics.Collections,
 PGofer.Classes;

type
  TClassItem = record
    Name: string;
    ClassType: TClass;
  end;

  TClassList = class (TList<TClassItem>)
  private
  protected
  public
    destructor Destroy(); override;
    procedure AddClass( AValue: TClass );
    function TryGetClass(const AName: string; out OValue: TClass): Boolean;
    function TryGetName(AValue: TClass; out OName: string): Boolean;
  end;

  TPGItemCollectTrigger = class(TPGItemCollect)
    constructor Create(AName: string); overload;
    destructor Destroy(); override;
  private
    FClassList: TClassList;
    FFileName: string;
  protected
  public
    procedure XMLLoadFromStream(AItemDad: TPGItem; AXMLStream: TStream);
    procedure XMLLoadFromFile();
    procedure XMLSaveToStream(AItemDad: TPGItem; AXMLStream: TStream);
    procedure XMLSaveToFile();
    property ClassList: TClassList read FClassList;
    procedure RegisterClass(AClass: TClass);
    procedure FormCreate(); override;
  end;

implementation

uses
   System.SysUtils, System.RTTI, System.TypInfo,
   XML.XMLIntf, XML.XMLDoc,
   PGofer.Core, PGofer.Triggers, PGofer.Triggers.Form,
   PGofer.Key.Controls;

{ TClassList }

destructor TClassList.Destroy();
begin
  Self.Clear;
  inherited Destroy();
end;

procedure TClassList.AddClass(AValue: TClass);
type
  TPGItemMirrorType = class of TPGItemMirror;
var
  LItem: TClassItem;
begin
  LItem.ClassType := AValue;
  LItem.Name      := TPGItemMirrorType(AValue).ClassNameEx;
  Self.Add(LItem);
end;

function TClassList.TryGetClass(const AName: string; out OValue: TClass): Boolean;
var
  LItem: TClassItem;
begin
  Result := False;
  OValue := nil;
  for LItem in Self do
  begin
    if SameText(LItem.Name, AName) or SameText(LItem.ClassType.ClassName, AName) then
    begin
      OValue := LItem.ClassType;
      Exit(True);
    end;
  end;
end;

function TClassList.TryGetName(AValue: TClass; out OName: string): Boolean;
var
  LItem: TClassItem;
begin
  Result := False;
  OName := '';
  for LItem in Self do
  begin
    if LItem.ClassType = AValue then
    begin
      OName := LItem.Name;
      Exit(True);
    end;
  end;
end;

{ TPGItemCollectTrigger }

constructor TPGItemCollectTrigger.Create(AName: string);
begin
  inherited Create(AName);
  FClassList := TClassList.Create();
  FFileName := TPGKernel.PathCurrent + AName + '.xml';
end;

destructor TPGItemCollectTrigger.Destroy();
begin
  FClassList.Free();
  FFileName := '';
  inherited Destroy();
end;

procedure TPGItemCollectTrigger.FormCreate();
begin
  if not Assigned(Self.Form) then
  begin
    SetForm( TFrmTriggerController.Create(Self) );
    SetTreeView( TFrmTriggerController(Self.Form).TrvController);
  end;

  Self.XMLLoadFromFile();
end;

procedure TPGItemCollectTrigger.RegisterClass(AClass: TClass);
begin
  FClassList.AddClass( AClass );
end;

procedure TPGItemCollectTrigger.XMLSaveToStream(AItemDad: TPGItem; AXMLStream: TStream);
  procedure CreateNode(Item: TPGItem; XMLNodeDad: IXMLNode);
  var
    RttiType: TRttiType;
    RttiProperty: TRttiProperty;
    XMLNodeProperty: IXMLNode;
    XMLNode: IXMLNode;
    ItemChild: TPGItem;
    ItemOriginal: TPGItem;
    ClassName, LPropValue: string;
  begin
    if not FClassList.TryGetName(Item.ClassType, ClassName) then
      Exit;

    if (Item is TPGItemMirror) and (Assigned(TPGItemMirror(Item).ItemOriginal)) then
      ItemOriginal := TPGItemMirror(Item).ItemOriginal
    else
      ItemOriginal := Item;

    XMLNode := XMLNodeDad.AddChild(ClassName);
    XMLNode.Attributes['Name'] := SanitizeText( ItemOriginal.Name );
    XMLNode.Attributes['Enabled'] := ItemOriginal.Enabled;
    XMLNode.Attributes['ReadOnly'] := ItemOriginal.ReadOnly;

    RttiType := TPGKernel.RttiContext.GetType(ItemOriginal.ClassType);

    for RttiProperty in RttiType.GetProperties do
    begin
      if (RttiProperty.Visibility in [mvPublished]) and (RttiProperty.IsReadable) and
        (RttiProperty.IsWritable) then
      begin
        XMLNodeProperty := XMLNode.AddChild(RttiProperty.Name);
        XMLNodeProperty.Attributes['Type'] := RttiProperty.PropertyType.ToString;
        LPropValue := TValue(RttiProperty.GetValue(ItemOriginal)).ToString;
        XMLNodeProperty.NodeValue := SanitizeText(LPropValue);
      end;
    end;

    if (Item is TPGFolderMirror) and (TPGFolderMirror(Item).BeforeXMLSave(Self)) then
      for ItemChild in Item do
        CreateNode(ItemChild, XMLNode);
  end;

var
  XMLDocument: IXMLDocument;
  XMLRoot: IXMLNode;
  Item: TPGItem;
begin
  if not Assigned(AXMLStream) or not Assigned(Self.TreeView) then Exit;
  Self.CollectLocked;
  try
    XMLDocument := NewXMLDocument;
    XMLDocument.Encoding := 'utf-8';
    XMLDocument.Options := [doNodeAutoCreate, doNodeAutoIndent];
    XMLDocument.Active := True;
    XMLRoot := XMLDocument.AddChild(AItemDad.Name);
    XMLRoot.Attributes['Version'] := '1.0';
    for Item in AItemDad do
    begin
      CreateNode(Item, XMLRoot);
    end;
    AXMLStream.Position := 0;
    XMLDocument.SaveToStream(AXMLStream);
  finally
    XMLDocument.Active := False;
    Self.CollectUnlocked;
  end;
end;

procedure TPGItemCollectTrigger.XMLSaveToFile();
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
        on E: Exception do TPGKernel.ConsoleTr(
          'Error_XML_Save', [FFileName, E.Message]
        );
      end;
    finally
      MemStream.Free;
    end;
  end;
end;

procedure TPGItemCollectTrigger.XMLLoadFromStream(AItemDad: TPGItem; AXMLStream: TStream);

  procedure CreateItem(ItemDad: TPGItem; XMLNode: IXMLNode);
  var
    RttiType: TRttiType;
    RttiProperty: TRttiProperty;
    XMLNodeChild: IXMLNode;
    ClassRegister: TClass;
    Value: TValue;
    Item: TPGItem;
    ItemOriginal: TPGItem;
    NodeName: string;

    procedure LAssignProperty(AProp: TRttiProperty);
    var
      XMLNodeProperty: IXMLNode;
    begin
      XMLNodeProperty := XMLNode.ChildNodes.FindNode(AProp.Name);
      if Assigned(XMLNodeProperty) then
      begin
        try
          case AProp.PropertyType.TypeKind of
            tkInteger:
              AProp.SetValue(ItemOriginal, StrToIntDef(XMLNodeProperty.Text, 0));
            tkEnumeration:
              AProp.SetValue(ItemOriginal, StrToBoolDef(XMLNodeProperty.Text, False));
            tkFloat:
              AProp.SetValue(ItemOriginal, StrToFloatDef(XMLNodeProperty.Text, 0));
            tkString, tkLString, tkWString, tkUString:
              AProp.SetValue(ItemOriginal, UnicodeString(XMLNodeProperty.Text));
          end;
        except
          TPGKernel.ConsoleTr('Error_XML_LoadValue', [XMLNode.NodeName, AProp.Name, FFileName]);
        end;
      end;
    end;
  begin
    if (not FClassList.TryGetClass(XMLNode.NodeName, ClassRegister)) or
      (not XMLNode.HasAttribute('Name')) then
      Exit;

    NodeName := XMLNode.Attributes['Name'];
    RttiType := TPGKernel.RttiContext.GetType(ClassRegister);
    Value := RttiType.GetMethod('Create').Invoke(ClassRegister, [ItemDad, NodeName]);
    Item := TPGItem(Value.AsObject);

    if (Item is TPGItemMirror) and (Assigned(TPGItemMirror(Item).ItemOriginal)) then
    begin
      ItemOriginal := TPGItemMirror(Item).ItemOriginal;
      RttiType := TPGKernel.RttiContext.GetType(ItemOriginal.ClassType);
    end else begin
      ItemOriginal := Item;
    end;

    if XMLNode.HasAttribute('Enabled') then
      ItemOriginal.Enabled := XMLNode.Attributes['Enabled'];

    if XMLNode.HasAttribute('ReadOnly') then
      ItemOriginal.ReadOnly := XMLNode.Attributes['ReadOnly'];

    for RttiProperty in RttiType.GetProperties do
    begin
      if (RttiProperty.Visibility in [mvPublished]) and (RttiProperty.IsReadable) and (RttiProperty.IsWritable) then
      begin
        if not RttiProperty.Name.StartsWith('_') then
          LAssignProperty(RttiProperty);
      end;
    end;

    for RttiProperty in RttiType.GetProperties do
    begin
      if (RttiProperty.Visibility in [mvPublished]) and (RttiProperty.IsReadable) and (RttiProperty.IsWritable) then
      begin
        if RttiProperty.Name.StartsWith('_') then
          LAssignProperty(RttiProperty);
      end;
    end;

    if (item is TPGFolderMirror) and (TPGFolderMirror(Item).BeforeXMLLoad(Self)) then
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
  if not Assigned(AXMLStream) or not Assigned(Self.TreeView) then Exit;
  Self.TreeView.Items.BeginUpdate;

  AItemDad.Clear;
  XMLDocument := NewXMLDocument;
  try
    AXMLStream.Position := 0;
    try
      XMLDocument.LoadFromStream(AXMLStream);
      XMLDocument.Active := True;
      XMLRoot := XMLDocument.DocumentElement;
    except
      TPGKernel.ConsoleTr('Error_XML_Load',[FFileName]);
    end;
    if Assigned(XMLRoot) then
    begin
      XMLNode := XMLRoot.ChildNodes.First;
      while Assigned(XMLNode) do
      begin
        CreateItem(AItemDad, XMLNode);
        XMLNode := XMLNode.NextSibling;
      end;
    end;
  finally
    XMLDocument.Active := False;
    Self.TreeView.Items.EndUpdate;
  end;
end;

procedure TPGItemCollectTrigger.XMLLoadFromFile();
var
  Stream: TStream;
begin
  if FileExists(FFileName) then
  begin
    Stream := TFileStream.Create(FFileName, fmOpenRead);
    try
      Self.XMLLoadFromStream(Self, Stream);
    finally
      Stream.Free;
    end;
  end;
end;


end.
