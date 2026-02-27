unit PGofer.Classes;

interface

uses
  System.Generics.Collections,
  Vcl.ImgList, Vcl.Comctrls,
  PGofer.Component.Form, PGofer.Component.TreeView;

type
  TPGItemCollect = class;
  TPGItemType = class of TPGItem;

  TPGItem = class(TObjectList<TPGItem>)
  private
    FName: string;
    FEnabled: Boolean;
    FReadOnly: Boolean;
    FParent: TPGItem;
    FNode: TTreeNode;
    procedure SetParent(AParent: TPGItem);
    function GetCollectDad(): TPGItemCollect;
    procedure SetNode(AValue: TTreeNode);
    class var FIconCache: TDictionary<TClass, Integer>;
    class var FImageList: TCustomImageList;
    class var FIconPath: String;
    class function LoadForClass(AClass: TClass): Integer;
    class procedure SetIconPath(const Value: String); static;
  protected
    class var FAbout: TObjectDictionary<TClass, TDictionary<string, string>>;
    function GetAbout(): String; virtual;
    procedure SetName(AName: string); virtual;
    procedure SetEnabled(AValue: Boolean); virtual;
  public
    class constructor Create();
    class destructor Destroy();
    class function ClassNameEx(): String; virtual;
    class function IconIndex(): Integer; virtual;
    class property IconPath: String read FIconPath write SetIconPath;
    constructor Create(AParent: TPGItem; AName: string); overload; virtual;
    destructor Destroy(); override;
    property About: string read GetAbout;
    property Name: string read FName write SetName;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property Parent: TPGItem read FParent write SetParent;
    property Node: TTreeNode read FNode write SetNode;
    property CollectDad: TPGItemCollect read GetCollectDad;
    procedure Frame(AParent: TObject); virtual;
    function FindName(AName: string): TPGItem;
    function FindNameList(AName: string; APartial: Boolean): TArray<TPGItem>;
  end;

  TPGItemCollect = class(TPGItem)
  private
    FTreeView: TTreeViewEx;
    class function GetImageList(): TCustomImageList;
  protected
    FForm: TFormEx;
  public
    constructor Create(AName: string); overload;
    destructor Destroy(); override;
    property ImageList: TCustomImageList read GetImageList;
    property TreeView: TTreeViewEx read FTreeView;
    property Form: TFormEx read FForm;
    procedure FormCreate(); virtual;
    procedure FormShow();
    procedure TreeViewAttach();
    procedure TreeViewDetach();
  end;

implementation

uses
  System.SysUtils,
  Vcl.Graphics,
  PGofer.Core, PGofer.Item.Frame, PGofer.Forms.Controller;

{ TPGItem }

class constructor TPGItem.Create();
begin
  FAbout := TObjectDictionary<TClass, TDictionary<string, string>>.Create([doOwnsValues]);
  FIconCache := TDictionary<TClass, Integer>.Create;
  {$IFDEF DEBUG}
    FIconPath := TPGKernel.PathCurrent + '..\..\..\..\Documents\Imagens\Icons\';
  {$ELSE}
    FIconPath := TPGKernel.PathCurrent + 'Icons\';
  {$ENDIF}

  TPGItem.FImageList := TCustomImageList.Create(nil);
  TPGItem.FImageList.Width := 16;
  TPGItem.FImageList.Height := 16;
end;

class destructor TPGItem.Destroy();
begin
  FImageList.Free;
  FIconCache.Free;
  FAbout.Free;
end;

class function TPGItem.LoadForClass(AClass: TClass): Integer;
var
  LCurrentClass: TClass;
  LIcon: TIcon;
  LIconFileName: string;
begin
  Result := 0;

  LCurrentClass := AClass;
  while (LCurrentClass <> nil) and (LCurrentClass.InheritsFrom(TPGItem)) do
  begin
    LIconFileName := FIconPath + TPGItemType(LCurrentClass).ClassNameEx + '.ico';
    if FileExists(LIconFileName) then
    begin
      LIcon := TIcon.Create( );
      try
        LIcon.LoadFromFile( LIconFileName );
        Result := FImageList.AddIcon( LIcon );
      finally
        LIcon.Free( );
      end;
      Exit;
    end;
    //Next
    LCurrentClass := LCurrentClass.ClassParent;
  end;
end;

class function TPGItem.IconIndex(): Integer;
var
  LClass: TClass;
begin
  LClass := Self;
  if not FIconCache.TryGetValue( LClass, Result ) then
  begin
    Result := TPGItem.LoadForClass( LClass );
    FIconCache.Add( LClass , Result);
  end;
end;

class function TPGItem.ClassNameEx(): String;
begin
  if Self.ClassName.StartsWith('TPG',True) then
  begin
    Result := Self.ClassName.Substring(3);
  end else begin
    Result := Self.ClassName.Substring(1);
  end;
end;

constructor TPGItem.Create(AParent: TPGItem; AName: string);
begin
  inherited Create(True);
  FName := AName;
  FEnabled := True;
  FReadOnly := False;
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
  FEnabled := False;
  FReadOnly := False;
  if Assigned(FParent) then
    FParent.Extract(Self);
  FParent := nil;
  inherited Destroy();
end;

function TPGItem.GetAbout(): String;
begin
  Result := '';
end;

procedure TPGItem.SetEnabled(AValue: Boolean);
begin
  FEnabled := AValue;
  if Assigned(FNode) then
  begin
    FNode.Enabled := FEnabled;
  end;
end;

class procedure TPGItem.SetIconPath(const Value: String);
begin
  FIconPath := Value;
  FIconCache.Clear;
  FImageList.Clear;
end;

procedure TPGItem.SetNode(AValue: TTreeNode);
var
  LIndex : Integer;
begin
  FNode := AValue;
  if Assigned(FNode) then
  begin
    FNode.Data := Self;
    LIndex := Self.IconIndex;
    FNode.ImageIndex := LIndex;
    FNode.SelectedIndex := LIndex;
    FNode.ExpandedImageIndex := LIndex;
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

{ TPGCollectItem }

constructor TPGItemCollect.Create(AName: string);
begin
  inherited Create(nil, AName);
end;

destructor TPGItemCollect.Destroy();
begin
  FTreeView := nil;
  if Assigned(FForm) then
    FForm.Free();
  inherited Destroy();
end;

procedure TPGItemCollect.FormCreate();
begin
  if not Assigned(FForm) then
  begin
    FForm := TFrmController.Create(Self);
  end;
end;

procedure TPGItemCollect.FormShow();
begin
  FForm.ForceShow(True);
end;

class function TPGItemCollect.GetImageList(): TCustomImageList;
begin
   Result := TPGItem.FImageList;
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

initialization

finalization

end.
