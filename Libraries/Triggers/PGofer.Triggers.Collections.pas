unit PGofer.Triggers.Collections;

interface

uses
 System.Classes, System.Generics.Collections,
 Pgofer.Component.Form,
 PGofer.Core, PGofer.Classes;

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
    procedure AddClass(const AValue: TClass );
    function TryGetClass(const AName: string; out OValue: TClass): Boolean;
    function TryGetName(const AValue: TClass; out OName: string): Boolean;
  end;

  TPGItemCollectTrigger = class(TPGItemCollect)
  private
    FClassList: TClassList;
    FFileName: string;
  protected
    procedure SetForm(const AForm: TFormEx); override;
  public
    constructor Create(const AParent: TPGItem; const AName: string); override;
    destructor Destroy(); override;
    procedure XMLLoadFromStream(const AItemDad: TPGItem; const AXMLStream: TStream);
    procedure XMLLoadFromFile();
    procedure XMLSaveToStream(const AItemDad: TPGItem; const AXMLStream: TStream);
    procedure XMLSaveToFile();
    property ClassList: TClassList read FClassList;
    procedure RegisterClass(const AClass: TClass);
  end;

implementation

uses
   System.SysUtils, System.IOUtils, System.RTTI, System.TypInfo,
   XML.XMLIntf, XML.XMLDoc,
   PGofer.Triggers, PGofer.Triggers.Form,
   PGofer.Key.Controls, PGofer.Files.Controls;

{ TClassList }

destructor TClassList.Destroy();
begin
  Self.Clear;
  inherited Destroy();
end;

procedure TClassList.AddClass(const AValue: TClass);
type
  TPGTriggerFolderType = class of TPGTriggerFolder;
var
  LItem: TClassItem;
begin
  LItem.ClassType := AValue;
  LItem.Name      := TPGTriggerFolderType(AValue).ClassNameEx;
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

function TClassList.TryGetName(const AValue: TClass; out OName: string): Boolean;
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

constructor TPGItemCollectTrigger.Create(const AParent: TPGItem; const AName: string);
begin
  inherited Create(AParent, AName);
  Self.Internal := False;
  FClassList := TClassList.Create();
  FFileName := TPGKernel.PathData + AName + '.xml';
end;

destructor TPGItemCollectTrigger.Destroy();
begin
  FClassList.Free();
  FFileName := '';
  inherited Destroy();
end;

procedure TPGItemCollectTrigger.RegisterClass(const AClass: TClass);
begin
  FClassList.AddClass( AClass );
end;

procedure TPGItemCollectTrigger.SetForm(const AForm: TFormEx);
begin
  inherited SetForm(AForm);
  if Assigned(AForm) then
    Self.XMLLoadFromFile();
end;

procedure TPGItemCollectTrigger.XMLSaveToStream(const AItemDad: TPGItem; const AXMLStream: TStream);
  procedure CreateNode(const AItem: TPGItem; const AXMLNodeDad: IXMLNode);
  var
    LRttiType: TRttiType;
    LRttiProperty: TRttiProperty;
    LXMLNodeProperty: IXMLNode;
    LXMLNode: IXMLNode;
    LItemChild: TPGItem;
    LClassName, LPropValue: string;
  begin
    if not FClassList.TryGetName(AItem.ClassType, LClassName) then
      Exit;

    LXMLNode := AXMLNodeDad.AddChild(LClassName);
    LXMLNode.Attributes['Name'] := SanitizeText( AItem.Name );

    LRttiType := TPGKernel.RttiContext.GetType(AItem.ClassType);

    for LRttiProperty in LRttiType.GetProperties do
    begin
      if (LRttiProperty.Visibility in [mvPublished]) and (LRttiProperty.IsReadable) and
        (LRttiProperty.IsWritable) then
      begin
        LXMLNodeProperty := LXMLNode.AddChild(LRttiProperty.Name);
        LXMLNodeProperty.Attributes['Type'] := LRttiProperty.PropertyType.ToString;
        LPropValue := TValue(LRttiProperty.GetValue(AItem)).ToString;
        LXMLNodeProperty.NodeValue := SanitizeText(LPropValue);
      end;
    end;

    if (AItem is TPGTriggerFolder) and (TPGTriggerFolder(AItem).BeforeXMLSave(Self)) then
      for LItemChild in AItem do
        CreateNode(LItemChild, LXMLNode);
  end;

var
  LXMLDocument: IXMLDocument;
  LXMLRoot: IXMLNode;
  LItem: TPGItem;
begin
  if not Assigned(AXMLStream) or not Assigned(Self.TreeView) then Exit;
  Self.CollectLocked;
  try
    LXMLDocument := NewXMLDocument;
    LXMLDocument.Encoding := 'utf-8';
    LXMLDocument.Options := [doNodeAutoCreate, doNodeAutoIndent];
    LXMLDocument.Active := True;
    LXMLRoot := LXMLDocument.AddChild(AItemDad.Name);
    LXMLRoot.Attributes['Version'] := '1.0';
    for LItem in AItemDad do
    begin
      CreateNode(LItem, LXMLRoot);
    end;
    AXMLStream.Position := 0;
    LXMLDocument.SaveToStream(AXMLStream);
  finally
    LXMLDocument.Active := False;
    Self.CollectUnlocked;
  end;
end;

procedure TPGItemCollectTrigger.XMLSaveToFile();
  function SaveToFile(const AFileName: String): Boolean;
  var
    LFileStream: TFileStream;
    LMemStream: TMemoryStream;
  begin
    Result := False;
    LMemStream := TMemoryStream.Create;
    try
      try
        Self.XMLSaveToStream(Self, LMemStream);
      except
        on E: Exception do
        begin
          TPGKernel.ConsoleTr('Error_XML_Save', [FFileName, E.Message]);
          Exit;
        end;
      end;

      LMemStream.Position := 0;

      try
        LFileStream := TFileStream.Create(AFileName, fmCreate);
        try
          LFileStream.CopyFrom(LMemStream, 0);
          Result := True;
        finally
          LFileStream.Free;
        end;
      except
        on E: Exception do
          TPGKernel.ConsoleTr('Error_XML_Save', [AFileName, E.Message]);
      end;
    finally
      LMemStream.Free;
    end;
  end;

var
  LTempFile: string;
begin
  if (FFileName = '') then
    Exit;

  LTempFile := FFileName + '.tmp';
  if not SaveToFile(LTempFile) then
    Exit;

  FileCommitWithBackup(FFileName);
end;

procedure TPGItemCollectTrigger.XMLLoadFromStream(const AItemDad: TPGItem; const AXMLStream: TStream);

  procedure CreateItem(const AItemDad: TPGItem; const AXMLNode: IXMLNode);
  var
    LRttiType: TRttiType;
    LRttiProperty: TRttiProperty;
    LXMLNodeChild: IXMLNode;
    LClassRegister: TClass;
    LValue: TValue;
    LItem: TPGItem;
    LNodeName: string;

    procedure LAssignProperty(AProp: TRttiProperty);
    var
      XMLNodeProperty: IXMLNode;
    begin
      XMLNodeProperty := AXMLNode.ChildNodes.FindNode(AProp.Name);
      if Assigned(XMLNodeProperty) then
      begin
        try
          case AProp.PropertyType.TypeKind of
            tkInteger, tkInt64:
              AProp.SetValue(LItem, StrToInt64Def(XMLNodeProperty.Text, 0));
            tkEnumeration:
              AProp.SetValue(LItem, StrToBoolDef(XMLNodeProperty.Text, False));
            tkFloat:
              AProp.SetValue(LItem, StrToFloatDef(XMLNodeProperty.Text, 0));
            tkString, tkLString, tkWString, tkUString:
              AProp.SetValue(LItem, UnicodeString(XMLNodeProperty.Text));
          end;
        except
          TPGKernel.ConsoleTr('Error_XML_LoadValue', [AXMLNode.NodeName, AProp.Name, FFileName]);
        end;
      end;
    end;
  begin
    if (not FClassList.TryGetClass(AXMLNode.NodeName, LClassRegister)) or
      (not AXMLNode.HasAttribute('Name')) then
      Exit;

    LNodeName := AXMLNode.Attributes['Name'];
    LRttiType := TPGKernel.RttiContext.GetType(LClassRegister);
    LValue := LRttiType.GetMethod('Create').Invoke(LClassRegister, [AItemDad, LNodeName]);
    LItem := TPGItem(LValue.AsObject);
    LRttiType := TPGKernel.RttiContext.GetType(LItem.ClassType);

    for LRttiProperty in LRttiType.GetProperties do
      if (LRttiProperty.Visibility in [mvPublished]) and (LRttiProperty.IsReadable) and (LRttiProperty.IsWritable) then
        LAssignProperty(LRttiProperty);

    if (LItem is TPGTriggerFolder) and (TPGTriggerFolder(LItem).BeforeXMLLoad(Self)) then
    begin
      LXMLNodeChild := AXMLNode.ChildNodes.First();
      while Assigned(LXMLNodeChild) do
      begin
        CreateItem(LItem, LXMLNodeChild);
        LXMLNodeChild := LXMLNodeChild.NextSibling();
      end;
    end;
  end;

var
  LXMLDocument: IXMLDocument;
  LXMLRoot, LXMLNode: IXMLNode;
begin
  if not Assigned(AXMLStream) or not Assigned(Self.TreeView) then Exit;

  Self.BeginUpdate;
  LXMLDocument := NewXMLDocument;
  try
    AItemDad.Clear;
    AXMLStream.Position := 0;
    try
      LXMLDocument.LoadFromStream(AXMLStream);
      LXMLDocument.Active := True;
      LXMLRoot := LXMLDocument.DocumentElement;
    except
      TPGKernel.ConsoleTr('Error_XML_Load',[FFileName]);
    end;
    if Assigned(LXMLRoot) then
    begin
      LXMLNode := LXMLRoot.ChildNodes.First;
      while Assigned(LXMLNode) do
      begin
        CreateItem(AItemDad, LXMLNode);
        LXMLNode := LXMLNode.NextSibling;
      end;
    end;
  finally
    LXMLDocument.Active := False;
    Self.EndUpdate;
  end;
end;

procedure TPGItemCollectTrigger.XMLLoadFromFile();
  function LoadFromFile(const AFileName: String): Boolean;
  var
    LStream: TStream;
  begin
    Result := False;
    if TFile.Exists(AFileName) and (PGofer.Files.Controls.FileGetSize(AFileName) > 0) then
    begin
      LStream := TFileStream.Create(AFileName, fmOpenRead);
      try
        Self.XMLLoadFromStream(Self, LStream);
      finally
        LStream.Free;
        Result := True;
      end;
    end;
  end;

var
  LBackupFile: string;
  LCount: Integer;
  LLoaded: Boolean;
begin
  LBackupFile := FFileName;

  LLoaded := LoadFromFile(LBackupFile);
  LCount := 1;

  while (not LLoaded) and (LCount <= 10) do
  begin
    LBackupFile := FFileName + '.bak' + IntToStr(LCount);
    LLoaded := LoadFromFile(LBackupFile);
    Inc(LCount);
  end;

  if LLoaded and (LBackupFile <> FFileName) then
  begin
    if TFile.Exists(FFileName) then
       TFile.Delete(FFileName);
    TFile.Copy(LBackupFile, FFileName, True);
    TPGKernel.ConsoleTr('Warning_RestoreBackup', [LBackupFile]);
  end;
end;

end.
