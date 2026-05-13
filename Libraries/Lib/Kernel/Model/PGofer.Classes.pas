unit PGofer.Classes;

interface

uses
  System.SyncObjs, System.Generics.Collections,
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
    FSystemNode: Boolean;
    FDestroying: Boolean;
    FParent: TPGItem;
    FNode: TTreeNode;
    function GetCollectDad(): TPGItemCollect;
    class var FIconCache: TDictionary<TClass, Integer>;
    class var FIconList: TCustomImageList;
    class var FStateCache: TDictionary<String, Integer>;
    class var FStateList: TCustomImageList;
    procedure SetSystemNode(const Value: Boolean);
    procedure SetReadOnly(const Value: Boolean);
  protected
    class var FAbout: TObjectDictionary<TClass, TDictionary<string, string>>;
    function GetAbout(): String; virtual;
    function GetIsValid(): Boolean; virtual;
    function GetName(): String; virtual;
    function GetIconIndex(): Integer; virtual;
    function GetStateIndex: Integer; virtual;
    procedure SetName(AName: string); virtual;
    procedure SetNameForced(AName: string); virtual;
    procedure SetEnabled(AValue: Boolean); virtual;
    procedure SetParent(AParent: TPGItem); virtual;
    procedure SetNode(AValue: TTreeNode); virtual;
    procedure UpdateStateIcon();
  public
    class constructor Create();
    class destructor Destroy();
    class function ClassNameEx(): String; virtual;
    class function ClassIconIndex(): Integer;
    class function ClassStateIconIndex(AStateName: String): Integer;

    constructor Create(AParent: TPGItem; AName: string); overload; virtual;
    destructor Destroy(); override;
    procedure BeforeDestruction(); override;
    property Destroying: Boolean read FDestroying;

    property Name: string read GetName write SetName;
    property About: string read GetAbout;

    property SystemNode: Boolean read FSystemNode write SetSystemNode;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property IsValid: Boolean read GetIsValid;

    property IconIndex: Integer read GetIconIndex;
    property StateIndex: Integer read GetStateIndex;

    property Parent: TPGItem read FParent write SetParent;
    property Node: TTreeNode read FNode write SetNode;
    property CollectDad: TPGItemCollect read GetCollectDad;
    procedure Frame(AParent: TObject); virtual;
    function FindName(AName: string): TPGItem;
    function FindNameList(AName: string; APartial: Boolean): TArray<TPGItem>;
  end;

  TPGItemCollect = class(TPGItem)
  private
    FAttached: Boolean;
    FCollectLock: TCriticalSection;
    FTreeView: TTreeViewEx;
    FForm: TFormEx;
    class function GetImageList(): TCustomImageList;
    class function GetStateImageList(): TCustomImageList;
  protected
    procedure SetTreeView(AValue: TTreeViewEx);
    procedure SetForm(AValue: TFormEx);
  public
    constructor Create(AName: string); overload;
    destructor Destroy(); override;
    property ImageList: TCustomImageList read GetImageList;
    property StateImageList: TCustomImageList read GetStateImageList;
    property TreeView: TTreeViewEx read FTreeView;
    property Form: TFormEx read FForm;
    property Attached: Boolean read FAttached;
    procedure FormCreate(); virtual;
    procedure FormShow();
    procedure TreeViewAttach();
    procedure TreeViewDetach(AItem: TPGItem = nil);
    procedure CollectLocked();
    procedure CollectUnlocked();
  end;

implementation

uses
  System.Classes, System.SysUtils,
  Vcl.Graphics,
  PGofer.Core, PGofer.Item.Frame, PGofer.Forms.Controller;

{ TPGItem }

class constructor TPGItem.Create();
begin
  FAbout := TObjectDictionary<TClass, TDictionary<string, string>>.Create([doOwnsValues]);
  FIconCache := TDictionary<TClass, Integer>.Create;
  FStateCache := TDictionary<String, Integer>.Create;

  FIconList := TCustomImageList.Create(nil);
  FIconList.Width := 16;
  FIconList.Height := 16;

  FStateList := TCustomImageList.Create(nil);
  FStateList.Width := 16;
  FStateList.Height := 16;
end;

class destructor TPGItem.Destroy();
begin
  FStateList.Free;
  FStateList := nil;
  FIconList.Free;
  FIconList := nil;
  FStateCache.Free;
  FStateCache := nil;
  FIconCache.Free;
  FIconCache := nil;
  FAbout.Free;
  FAbout := nil;
end;

class function TPGItem.ClassIconIndex(): Integer;
var
  LClass: TClass;
  function LLoadForClass(): Integer;
  var
    LCurrentClass: TClass;
    LIcon: TIcon;
    LIconFileName: string;
  begin
    Result := 0;

    LCurrentClass := LClass;
    while (LCurrentClass <> nil) and (LCurrentClass.InheritsFrom(TPGItem)) do
    begin
      LIconFileName := TPGKernel.PathIcon + TPGItemType(LCurrentClass).ClassNameEx + '.ico';
      if FileExists(LIconFileName) then
      begin
        LIcon := TIcon.Create( );
        try
          LIcon.LoadFromFile( LIconFileName );
          Result := FIconList.AddIcon( LIcon );
        finally
          LIcon.Free( );
        end;
        Exit;
      end;
      LCurrentClass := LCurrentClass.ClassParent;
    end;
  end;
begin
  LClass := Self;
  if not FIconCache.TryGetValue( LClass, Result ) then
  begin
    Result := LLoadForClass();
    FIconCache.Add( LClass , Result);
  end;
end;

class function TPGItem.ClassStateIconIndex(AStateName: String): Integer;
var
  LIcon: TIcon;
  LFileName: string;
begin
  if not FStateCache.TryGetValue(AStateName, Result) then
  begin
    Result := -1;
    LFileName := TPGKernel.PathIcon + 'state\' + AStateName + '.ico';

    if FileExists(LFileName) then
    begin
      LIcon := TIcon.Create;
      try
        LIcon.LoadFromFile(LFileName);
        Result := FStateList.AddIcon(LIcon);
        FStateCache.Add(AStateName, Result);
      finally
        LIcon.Free;
      end;
    end;
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
  FDestroying := False;
  inherited Create(True);
  FName := AName;
  FEnabled := True;
  FReadOnly := False;
  FSystemNode := True;
  FNode := nil;
  FParent := nil;
  Self.Parent := AParent;
end;

procedure TPGItem.BeforeDestruction();
begin
  FDestroying := True;
  inherited BeforeDestruction();
end;

destructor TPGItem.Destroy;
var
  LCollectDad: TPGItemCollect;
begin
  FDestroying := True;
  LCollectDad := GetCollectDad();

  if Assigned(LCollectDad) and (FParent <> nil) and (not FParent.Destroying) then
    LCollectDad.TreeViewDetach(Self);

  if Assigned(FParent) and (not FParent.Destroying) then
    FParent.Extract(Self);

  FName := '';
  FEnabled := False;
  FReadOnly := False;
  FSystemNode := False;

  inherited Destroy();
end;

function TPGItem.GetAbout(): String;
begin
  Result := '';
end;

procedure TPGItem.SetEnabled(AValue: Boolean);
begin
  FEnabled := AValue;
  Self.UpdateStateIcon();
end;

procedure TPGItem.SetNode(AValue: TTreeNode);
var
  LIndex : Integer;
begin
  if FNode = AValue then Exit;
  
  FNode := AValue;
  if Assigned(FNode) then
  begin
    FNode.Text := FName;
    FNode.Data := Self;
    LIndex := Self.IconIndex;
    FNode.ImageIndex := LIndex;
    FNode.SelectedIndex := LIndex;
    FNode.ExpandedImageIndex := LIndex;
    FNode.StateIndex := Self.StateIndex;
  end;
end;

procedure TPGItem.SetParent(AParent: TPGItem);
var
  LNewCollectDad: TPGItemCollect;
begin
  if (FParent = AParent) or (FSystemNode and Assigned(FParent)) then Exit;

  LNewCollectDad := nil;
  if Assigned(AParent) then LNewCollectDad := AParent.CollectDad;

  try
    if Assigned(FParent) then FParent.Extract(Self);
    if Assigned(AParent) then AParent.Add(Self);
  finally
    FParent := AParent;
  end;

  RunInMainThread(
    procedure
    var
      LTreeView: TTreeView;
      LNodeParent: TTreeNode;
    begin
      if not Assigned(FParent) then Exit;
      if not Assigned(LNewCollectDad) or not LNewCollectDad.Attached then Exit;

      LTreeView := LNewCollectDad.TreeView;
      if not Assigned(LTreeView) then Exit;

      if FParent is TPGItemCollect then
         LNodeParent := nil
      else
         LNodeParent := FParent.Node;

      if not Assigned(FNode) then
        Self.Node := LTreeView.Items.AddChild(LNodeParent, FName)
      else
        FNode.MoveTo(LNodeParent, naAddChild);
    end,
    True
  );
end;

procedure TPGItem.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
  Self.UpdateStateIcon();
end;

procedure TPGItem.SetSystemNode(const Value: Boolean);
begin
  FSystemNode := Value;
  Self.UpdateStateIcon();
end;

procedure TPGItem.SetName(AName: string);
begin
  if FSystemNode then Exit;
  Self.SetNameForced(AName);
end;

procedure TPGItem.SetNameForced(AName: string);
begin
  if FName = AName then Exit;
  FName := AName;
  if Assigned(FNode) then
    FNode.Text := FName;
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

function TPGItem.GetIconIndex: Integer;
begin
  Result := TPGItemType(Self.ClassType).ClassIconIndex();
end;

function TPGItem.GetIsValid(): Boolean;
begin
  Result := True;
end;

function TPGItem.GetName(): String;
begin
   Result := FName;
end;

function TPGItem.GetStateIndex: Integer;
begin
  Result := -1;
end;

procedure TPGItem.UpdateStateIcon();
begin
  if Assigned(FNode) then
    FNode.StateIndex := Self.StateIndex;
end;

function TPGItem.FindName(AName: string): TPGItem;
var
  LItem : TPGItem;
begin
  Result := nil;
  for LItem in Self do
  begin
    if SameText(AName, LItem.Name) then
      Exit(LItem);
  end;
end;

function TPGItem.FindNameList(AName: string; APartial: Boolean): TArray<TPGItem>;
var
  LItem: TPGItem;
begin
  SetLength(Result, 0);
  for LItem in Self do
  begin
    if (APartial and (Pos(LowerCase(AName), LowerCase(LItem.Name)) > 0)) or
      (not APartial and SameText(AName, LItem.Name)) or (AName = '') then
    begin
      Result := Result + [LItem];
    end;
  end;
end;

{ TPGCollectItem }

class function TPGItemCollect.GetImageList(): TCustomImageList;
begin
   Result := TPGItem.FIconList;
end;

class function TPGItemCollect.GetStateImageList(): TCustomImageList;
begin
   Result := TPGItem.FStateList;
end;

constructor TPGItemCollect.Create(AName: string);
begin
  inherited Create(nil, AName);
  FCollectLock := TCriticalSection.Create;
end;

destructor TPGItemCollect.Destroy();
begin
  if FAttached then
    Self.TreeViewDetach();
  FTreeView := nil;

  if Assigned(FForm) then
    FForm.Free();
  FForm := nil;

  FCollectLock.Free;
  FCollectLock := nil;

  inherited Destroy();
end;

procedure TPGItemCollect.CollectLocked;
begin
  FCollectLock.Acquire;
end;

procedure TPGItemCollect.CollectUnlocked;
begin
  FCollectLock.Release;
end;

procedure TPGItemCollect.FormCreate();
begin
  if not Assigned(FForm) then
  begin
    FForm := TFrmController.Create(Self);
    FTreeView := TFrmController(FForm).TrvController;
  end;
end;

procedure TPGItemCollect.FormShow();
begin
  FForm.ForceShow(True);
end;

procedure TPGItemCollect.SetForm(AValue: TFormEx);
begin
  FForm := AValue;
end;

procedure TPGItemCollect.SetTreeView(AValue: TTreeViewEx);
begin
  FTreeView := AValue;
end;

procedure TPGItemCollect.TreeViewAttach();
  procedure LNodeAttach(AItem: TPGItem);
  var
    LNode: TTreeNode;
    LItemChild: TPGItem;
  begin
    if Assigned(AItem.Parent) then
      LNode := AItem.Parent.Node
    else
      LNode := nil;

    AItem.Node := FTreeView.Items.AddChild(LNode, AItem.Name);

    for LItemChild in AItem do
      LNodeAttach(LItemChild);
  end;

var
  LItem: TPGItem;
begin
  if not Assigned(FTreeView) or not FTreeView.HandleAllocated or FAttached then Exit;

  Self.CollectLocked;
  FTreeView.Items.BeginUpdate;
  try
    FTreeView.Items.Clear;
    for LItem in Self do
      LNodeAttach(LItem);
  finally
    FAttached := True;
    FTreeView.Items.EndUpdate;
    Self.CollectUnlocked;
  end;
end;

procedure TPGItemCollect.TreeViewDetach(AItem: TPGItem = nil);
  procedure LNodeDetach(Item: TPGItem);
  var
    LChild: TPGItem;
  begin
    if not Assigned(Item) then Exit;
    for LChild in Item do
      LNodeDetach(LChild);
    if Assigned(Item.Node) then
      Item.Node.Data := nil;
    Item.Node := nil;
  end;
var
  LItem : TPGItem;
  LNode : TTreeNode;
  LIsFullClear: Boolean;
begin
  if not Assigned(FTreeView) or not FAttached then Exit;

  if Assigned(AItem) then
  begin
    LIsFullClear := False;
    if not Assigned(AItem.Node) then Exit;
  end else
    LIsFullClear := True;

  LNode := nil;
  Self.CollectLocked;
  try
    if Assigned(AItem) then
    begin
      LNode := AItem.Node;
      LNodeDetach(AItem);
    end else begin
      for LItem in Self do
        LNodeDetach(LItem);
    end;
  finally
    if not Assigned(AItem) then
      FAttached := False;
    Self.CollectUnlocked;
  end;

  RunInMainThread(
    procedure
    begin
      FTreeView.Items.BeginUpdate;
      try
        if FTreeView.HandleAllocated then
          if Assigned(LNode) and not LNode.Deleting then
             LNode.Delete
          else
            if LIsFullClear then
               FTreeView.Items.Clear();
      finally
        FTreeView.Items.EndUpdate;
      end;
    end,
    False
  );
end;

initialization

finalization

end.
