unit PGofer.Classes;

interface

uses
  System.SyncObjs, System.Generics.Collections,
  Vcl.ImgList, Vcl.Comctrls,
  PGofer.Component.Form, PGofer.Component.TreeView, PGofer.Core;
{$M+}
type
  TPGItemCollect = class;
  TPGItemType = class of TPGItem;

  TPGItemFlag = (
    pgfInvalid,
    pgfLocked,
    pgfDisabled,
    pgfReadOnly,
    pgfNamespace,
    pgfInternal,
    pgfExpanded,
    pgfHasChildren
  );
  TPGItemFlags = set of TPGItemFlag;

  TPGItem = class(TObjectList<TPGItem>)
  private
    FName: string;
    FDestroying: Boolean;
    FFlags: TPGItemFlags;
    FParent: TPGItem;
    FCollectDad: TPGItemCollect;
    FNode: TTreeNode;
    FisUpdate: Boolean;
    function GetFlags: TPGItemFlags;
    function IsCanHaveNode(): Boolean;
    procedure SetNode(const AValue: TTreeNode);

    class var FIconCache: TDictionary<TClass, Integer>;
    class var FOverlayCache: TDictionary<TPGItemFlag, Integer>;
    class var FIconList: TCustomImageList;
  protected
    class var FAbout: TObjectDictionary<TClass, TDictionary<string, string>>;

    function GetAbout(): String; virtual;
    function GetName(): String; virtual;
    function GetIconIndex(): Integer; virtual;
    function GetMaxOverlayFlag(): TPGItemFlag; virtual;
    function GetOverlayIndex(): Integer; virtual;

    procedure SetName(const AName: string); virtual;
    procedure SetParent(const AParent: TPGItem); virtual;
    procedure UpdateFlag(const AFlag: TPGItemFlag; const AValue: Boolean); virtual;

    function GetDisabled: Boolean;
    function GetExpanded: Boolean;
    function GetHasChildren: Boolean;
    function GetInvalid: Boolean;
    function GetLocked: Boolean;
    function GetNamespace: Boolean;
    function GetReadOnly: Boolean;
    function GetInternal: Boolean;

    procedure SetDisabled(const AValue: Boolean);
    procedure SetExpanded(const AValue: Boolean);
    procedure SetHasChildren(const AValue: Boolean);
    procedure SetInvalid(const AValue: Boolean);
    procedure SetNamespace(const AValue: Boolean); virtual;
    procedure SetLocked(const AValue: Boolean); virtual;
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetInternal(const AValue: Boolean);

    procedure Notify(const Value: TPGItem; Action: TCollectionNotification); override;
  public
    class function ClassNameEx(): String; virtual;
    class function ClassIconIndex(): Integer;
    class function ClassOverlayIndex(const AFlag: TPGItemFlag): Integer;
    class property IconList: TCustomImageList read FIconList;

    class function FindName(const AScope: TPGItem; const AName: string): TPGItem; overload;
    class function FindNameList(const AScope: TPGItem; const AName: string): TArray<TPGItem>; overload;

    constructor Create(const AParent: TPGItem; const AName: string  = ''); reintroduce; virtual;
    procedure BeforeDestruction(); override;
    destructor Destroy(); override;

    property Destroying: Boolean read FDestroying;

    property Name: string read GetName write SetName;
    property About: string read GetAbout;

    property Flags: TPGItemFlags read GetFlags;
    property Invalid: Boolean read GetInvalid write SetInvalid;
    property Locked: Boolean read GetLocked write SetLocked;
    property Disabled: Boolean read GetDisabled write SetDisabled;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property Namespace: Boolean read GetNamespace write SetNamespace;
    property Internal: Boolean read GetInternal write SetInternal;
    property Expanded: Boolean read GetExpanded write SetExpanded;
    property HasChildren: Boolean read GetHasChildren write SetHasChildren;

    property IconIndex: Integer read GetIconIndex;
    property OverlayIndex: Integer read GetOverlayIndex;
    property MaxOverlayIndex: TPGItemFlag read GetMaxOverlayFlag;

    property Parent: TPGItem read FParent write SetParent;
    property Node: TTreeNode read FNode;
    property CollectDad: TPGItemCollect read FCollectDad;

    procedure UpdateNode();
    procedure Frame(const AParent: TObject); virtual;

    function FindName(const AName: string): TPGItem; overload;
    function FindNameList(const AName: string): TArray<TPGItem>; overload;
  end;

  TPGItemCollect = class(TPGItem)
  private
    FAttached: Boolean;
    FHiddeInternal: Boolean;
    FCollectLock: TCriticalSection;
    FUpdateList: TList<TPGItem>;
    FUpdateCount: Integer;
    FTreeView: TTreeViewEx;
    FForm: TFormEx;

    class var FCollectList: TList<TPGItemCollect>;
  protected
    procedure SetParent(const AParent: TPGItem); override;
    procedure SetForm(const AValue: TFormEx); virtual;
    procedure CollectLocked();
    procedure CollectUnlocked();
  public
    constructor Create(const AParent: TPGItem; const AName: string); override;
    destructor Destroy(); override;

    property Form: TFormEx read FForm write SetForm;
    property TreeView: TTreeViewEx read FTreeView;
    property Attached: Boolean read FAttached;
    property HiddeInternal: Boolean read FHiddeInternal write FHiddeInternal;

    procedure BeginUpdate();
    function BlockUpdate():Boolean;
    procedure EndUpdate();
    procedure TreeViewAttach();
    procedure TreeViewDetach(const AItem: TPGItem = nil);
    procedure FormShow();
  end;

  procedure Initialize();
  procedure Finalize();

var
  GlobalCollection: TPGItemCollect;

implementation

uses
  System.Classes, System.SysUtils, System.TypInfo,
  Vcl.Forms, Vcl.Graphics,
  PGofer.Item.Frame, PGofer.Forms.Controller;

procedure Initialize();
begin
  TPGItemCollect.FCollectList := TList<TPGItemCollect>.Create;
  TPGItem.FAbout := TObjectDictionary<TClass, TDictionary<string, string>>.Create([doOwnsValues]);
  TPGItem.FIconCache := TDictionary<TClass, Integer>.Create;
  TPGItem.FOverlayCache := TDictionary<TPGItemFlag, Integer>.Create;

  TPGItem.FIconList := TCustomImageList.Create(nil);
  TPGItem.FIconList.ColorDepth := cd32bit;
  TPGItem.FIconList.Width := 16;
  TPGItem.FIconList.Height := 16;

  GlobalCollection := TPGItemCollect.Create(nil, 'Globals');
end;

procedure Finalize();
begin
  GlobalCollection.Free;
  GlobalCollection := nil;

  TPGItem.FIconList.Free;
  TPGItem.FIconList := nil;
  TPGItem.FOverlayCache.Free;
  TPGItem.FOverlayCache := nil;
  TPGItem.FIconCache.Free;
  TPGItem.FIconCache := nil;
  TPGItem.FAbout.Free;
  TPGItem.FAbout := nil;
  TPGItemCollect.FCollectList.Free;
  TPGItemCollect.FCollectList := nil;

  {$IFDEF DEBUG}
  {$ENDIF}
end;

{ TPGItem }

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
  if TPGKernel.Finalized
  or (not Assigned(TPGItem.FIconCache)) then
    Exit(-1);

  LClass := Self;
  if not TPGItem.FIconCache.TryGetValue( LClass, Result ) then
  begin
    Result := LLoadForClass();
    TPGItem.FIconCache.Add( LClass , Result);
  end;
end;

class function TPGItem.ClassOverlayIndex(const AFlag: TPGItemFlag): Integer;
var
  LIcon: TIcon;
  LIconFileName: string;
begin
  if TPGKernel.Finalized
  or (not Assigned(TPGItem.FOverlayCache)) then
    Exit(-1);

  if TPGItem.FOverlayCache.TryGetValue(AFlag, Result) then
    Exit(Result);

  Result := -1;
  LIconFileName := GetEnumName(TypeInfo(TPGItemFlag), Ord(AFlag)).Substring(3);
  LIconFileName := TPGKernel.PathIcon + 'State\' + LIconFileName + '.ico';
  if FileExists(LIconFileName) then
  begin
    LIcon := TIcon.Create( );
    try
      LIcon.LoadFromFile( LIconFileName );
      Result := TPGItem.FOverlayCache.Count + 1;
      TPGItem.FIconList.Overlay( TPGItem.FIconList.AddIcon(LIcon) , Result);
    finally
      LIcon.Free( );
    end;
  end;
  TPGItem.FOverlayCache.Add(AFlag, Result);
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

class function TPGItem.FindName(const AScope: TPGItem; const AName: string): TPGItem;
var
  LItem: TPGItem;
  LRoot: TPGItemCollect;
begin
  if AName = '' then
    Exit(nil);

  Result := nil;
  if AScope = nil then
  begin
    if Assigned(TPGItemCollect.FCollectList) then
      for LRoot in TPGItemCollect.FCollectList do
      begin
        Result := FindName(LRoot, AName);
        if Assigned(Result) then Exit;
      end;
    Exit;
  end;

  for LItem in AScope do
    if SameText(LItem.Name, AName) then
      Exit(LItem);

  for LItem in AScope do
    if (LItem.Count > 0) and (not LItem.Namespace) then
    begin
      Result := FindName(LItem, AName);
      if Assigned(Result) then Exit;
    end;
end;

class function TPGItem.FindNameList(const AScope: TPGItem; const AName: string): TArray<TPGItem>;
var
  LItem: TPGItem;
  LRoot: TPGItemCollect;
  LSubList: TArray<TPGItem>;
  LSearch: string;
begin
  SetLength(Result, 0);
  LSearch := LowerCase(AName);

  if AScope = nil then
  begin
    if Assigned(TPGItemCollect.FCollectList) then
      for LRoot in TPGItemCollect.FCollectList do
      begin
        LSubList := FindNameList(LRoot, AName);
        Result := Result + LSubList;
      end;
    Exit;
  end;

  for LItem in AScope do
  begin
    if (LSearch = '') or (Pos(LSearch, LowerCase(LItem.Name)) > 0) then
      Result := Result + [LItem];

    if (LItem.Count > 0) and (not LItem.Namespace) then
    begin
      LSubList := FindNameList(LItem, AName);
      Result := Result + LSubList;
    end;
  end;
end;

constructor TPGItem.Create(const AParent: TPGItem; const AName: string);
begin
  FDestroying := False;
  inherited Create(True);
  FFlags := [pgfInternal];
  FNode := nil;
  FisUpdate := False;
  FParent := nil;
  FCollectDad := nil;

  if AName = '' then
    Self.Name := Self.ClassNameEx
  else
    Self.Name := AName;

  Self.Parent := AParent;
end;

procedure TPGItem.BeforeDestruction();
begin
  FDestroying := True;
  inherited BeforeDestruction();
end;

destructor TPGItem.Destroy();
begin
  if Assigned(FCollectDad) and Assigned(FParent) and (not FParent.Destroying) then
  begin
    FCollectDad.TreeViewDetach(Self);
    FParent.Extract(Self);
  end;
  FParent := nil;
  FCollectDad := nil;

  if Assigned(FNode) then
  begin
    FNode.Data := nil;
    FNode := nil;
  end;

  FisUpdate := False;
  FName := '';
  FFlags := [];

  inherited Destroy();
end;

function TPGItem.GetAbout(): String;
begin
  Result := Self.ClassNameEx;
end;

function TPGItem.IsCanHaveNode(): Boolean;
begin
  if FName.StartsWith('_') then
    Exit(False);
  Result := not (Self.Internal and FCollectDad.HiddeInternal);
end;

procedure TPGItem.SetNode(const AValue: TTreeNode);
var
  LIndex : Integer;
begin
  if (FNode = AValue) then
    Exit;

  FNode := AValue;
  if Assigned(FNode) then
  begin
    FNode.Data := Self;
    LIndex := Self.IconIndex;
    FNode.ImageIndex := LIndex;
    FNode.SelectedIndex := LIndex;
    FNode.ExpandedImageIndex := LIndex;

    Self.UpdateNode;
  end;
end;

procedure TPGItem.SetParent(const AParent: TPGItem);
var
  LNodeParent: TTreeNode;
begin
  if (FParent = AParent) or (Self.Internal and Assigned(FParent)) then
    Exit;

  if Assigned(FParent) then FParent.Extract(Self);
  if Assigned(AParent) then
  begin
    if not Assigned(AParent.FCollectDad) then
       raise Exception.Create('Error: CollectDad no Fount in Parent.');

    FCollectDad := AParent.FCollectDad; //antes no notify
    AParent.Add(Self);
  end else
    FCollectDad := nil;

  FParent := AParent;

  if (not Assigned(FCollectDad))
  or (not FCollectDad.Attached)
  or (not Self.IsCanHaveNode)
  or TPGKernel.Finalized then
  begin
    FNode := nil;
    Exit;
  end;

  if FParent = FCollectDad then
    LNodeParent := nil
  else
    LNodeParent := FParent.Node;

  RunInMainThread(
    procedure
      procedure LRefreshBranch(AItem: TPGItem);
      var LChild: TPGItem;
      begin
        AItem.UpdateNode();
        for LChild in AItem do
          LRefreshBranch(LChild);
      end;
    begin
      if not Assigned(FNode) then
        Self.SetNode( FCollectDad.TreeView.Items.AddChild(LNodeParent, Self.Name) )
      else begin
        FNode.MoveTo(LNodeParent, naAddChild);
        LRefreshBranch( Self );
      end;
    end,
  True);
end;

procedure TPGItem.UpdateNode();
begin
  if not Assigned(FNode) then
    Exit;

  if FCollectDad.BlockUpdate then
  begin
    if not FisUpdate then
    begin
       FisUpdate := True;
       FCollectDad.FUpdateList.Add(Self);
    end;
    Exit;
  end;

  FNode.Text := Self.Name;
  FNode.OverlayIndex := -1; //força atualizar
  FNode.OverlayIndex := Self.OverlayIndex;
  FNode.HasChildren := Self.HasChildren;
  FNode.Expanded := Self.Expanded;
end;

procedure TPGItem.SetDisabled(const AValue: Boolean);
begin
  Self.UpdateFlag(pgfDisabled, AValue);
end;

procedure TPGItem.SetInvalid(const AValue: Boolean);
begin
  Self.UpdateFlag(pgfInvalid, AValue);
end;

procedure TPGItem.SetReadOnly(const AValue: Boolean);
begin
  Self.UpdateFlag(pgfReadOnly, AValue);
end;

procedure TPGItem.SetInternal(const AValue: Boolean);
begin
  Self.UpdateFlag(pgfInternal, AValue);
end;

procedure TPGItem.SetLocked(const AValue: Boolean);
begin
  if (pgfLocked in FFlags) = AValue then Exit;

  if AValue then
    FFlags := FFlags - [pgfExpanded, pgfHasChildren]
  else if (Self.Count > 0) then
    Include(FFlags, pgfHasChildren);

  Self.UpdateFlag(pgfLocked, AValue);
end;

procedure TPGItem.SetExpanded(const AValue: Boolean);
begin
  if AValue and (pgfHasChildren in FFlags) and (not (pgfLocked in FFlags)) then
    Self.UpdateFlag(pgfExpanded, True)
  else
    Self.UpdateFlag(pgfExpanded, False);
end;

procedure TPGItem.SetHasChildren(const AValue: Boolean);
begin
  if not AValue then
    Exclude(FFlags, pgfExpanded);
  Self.UpdateFlag(pgfHasChildren, AValue);
end;

procedure TPGItem.SetNamespace(const AValue: Boolean);
begin
  if (pgfNamespace in FFlags) = AValue then Exit;
  Self.UpdateFlag(pgfNamespace, AValue);
end;

procedure TPGItem.SetName(const AName: string);
begin
  if FName = AName then Exit;
  FName := AName;
  Self.UpdateNode;
end;

procedure TPGItem.Frame(const AParent: TObject);
begin
  TPGItemFrame.Create(Self, AParent);
end;

function TPGItem.GetIconIndex(): Integer;
begin
  Result := TPGItemType(Self.ClassType).ClassIconIndex();
end;

function TPGItem.GetFlags(): TPGItemFlags;
begin
  Result := FFlags;
end;

function TPGItem.GetDisabled(): Boolean;
begin
  Result := (pgfDisabled in FFlags);
end;

function TPGItem.GetExpanded(): Boolean;
begin
  Result := (pgfExpanded in FFlags);
end;

function TPGItem.GetHasChildren(): Boolean;
begin
  Result := (pgfHasChildren in FFlags);
end;

function TPGItem.GetInvalid(): Boolean;
begin
  Result := (pgfInvalid in FFlags);
end;

function TPGItem.GetLocked(): Boolean;
begin
  Result := (pgfLocked in FFlags);
end;

function TPGItem.GetMaxOverlayFlag(): TPGItemFlag;
begin
  Result := pgfReadOnly;
end;

function TPGItem.GetNamespace(): Boolean;
begin
  Result := (pgfNamespace in FFlags);
end;

function TPGItem.GetReadOnly(): Boolean;
begin
  Result := (pgfReadOnly in FFlags);
end;

function TPGItem.GetInternal(): Boolean;
begin
  Result := (pgfInternal in FFlags);
end;

function TPGItem.GetName(): String;
begin
   Result := FName;
end;

function TPGItem.GetOverlayIndex(): Integer;
var
  LFlag: TPGItemFlag;
  LMax: TPGItemFlag;
begin
  Result := -1;
  LMax := Self.GetMaxOverlayFlag;
  for LFlag := Low(TPGItemFlag) to LMax do
  begin
    if LFlag in FFlags then
    begin
      Result := TPGItem.ClassOverlayIndex(LFlag);
      Break;
    end;
  end;
end;

procedure TPGItem.Notify(const Value: TPGItem; Action: TCollectionNotification);
begin
  inherited;
  case Action of
    cnAdded:
    begin
      if Value.IsCanHaveNode and (not Self.HasChildren) then
        Self.HasChildren := True;
    end;
    cnRemoved:
    begin
      if Count = 0 then
        Self.HasChildren := False;
    end;
  end;
end;

procedure TPGItem.UpdateFlag(const AFlag: TPGItemFlag; const AValue: Boolean);
begin
  if ((AFlag in FFlags) = AValue) then Exit;

  if AValue then
    Include(FFlags, AFlag)
  else
    Exclude(FFlags, AFlag);

  Self.UpdateNode();
end;

function TPGItem.FindName(const AName: string): TPGItem;
begin
  Result := TPGItem.FindName(Self, AName);
end;

function TPGItem.FindNameList(const AName: string): TArray<TPGItem>;
begin
  Result := TPGItem.FindNameList(Self, AName);
end;

{ TPGCollectItem }

constructor TPGItemCollect.Create(const AParent: TPGItem; const AName: string);
begin
  Self.FCollectDad := Self; //antes de tudo para ele ja ser ele!
  inherited Create(AParent, AName);
  FAttached := False;
  FHiddeInternal := False;
  FTreeView := nil;
  FForm := nil;


  FUpdateList := TList<TPGItem>.Create();
  FUpdateCount:= 0;

  FCollectLock := TCriticalSection.Create;
  TPGItemCollect.FCollectList.Add(Self);
end;

destructor TPGItemCollect.Destroy();
begin
  TPGItemCollect.FCollectList.Remove(Self);
  FUpdateCount:= 9999;
  FUpdateList.Free;
  FUpdateList := nil;
  FAttached := False;
  FHiddeInternal := False;
  FTreeView := nil;
  FForm := nil;
  FCollectLock.Free;
  FCollectLock := nil;
  inherited Destroy();
end;

procedure TPGItemCollect.BeginUpdate();
begin
  if (FUpdateCount <= 0) and Self.Attached then
    Self.TreeView.Items.BeginUpdate;
  Inc(FUpdateCount);
end;

function TPGItemCollect.BlockUpdate(): Boolean;
begin
  Result := FUpdateCount > 0;
end;

procedure TPGItemCollect.EndUpdate();
var
  LItem: TPGItem;
begin
  if FUpdateCount > 0 then
  begin
    Dec(FUpdateCount);
    if (FUpdateCount <= 0) then
    begin
      try
        for LItem in FUpdateList do
        begin
          LItem.FisUpdate := False;
          LItem.UpdateNode();
        end;
      finally
        FUpdateList.Clear;
        if Self.Attached then
          Self.TreeView.Items.EndUpdate;
      end;
    end;
  end;
end;

procedure TPGItemCollect.CollectLocked();
begin
  if TPGKernel.Finalized
  or (not Assigned(Self.FCollectLock)) then
    Exit;

  Self.FCollectLock.Acquire;
end;

procedure TPGItemCollect.CollectUnlocked();
begin
  if TPGKernel.Finalized
  or (not Assigned(Self.FCollectLock)) then
    Exit;

  Self.FCollectLock.Release;
end;

procedure TPGItemCollect.FormShow();
begin
  if Assigned(FForm) then
    FForm.ForceShow(True);
end;

procedure TPGItemCollect.SetForm(const AValue: TFormEx);
begin
  if TPGKernel.Finalized then
    Exit;

  if AValue <> nil then
  begin
    FForm := AValue;
    FTreeView := TFrmController(AValue).TrvController;
    FTreeView.Images := TPGItem.FIconList;
  end else begin
    try
      if Assigned(FForm) and FAttached and (not FDestroying) then
        Self.TreeViewDetach();
    finally
      FAttached := False;
      FTreeView := nil;
      FForm := nil;
    end;
  end;
end;

procedure TPGItemCollect.SetParent(const AParent: TPGItem);
begin
  //sem frescura
  FCollectDad := Self;
  //FParent := nil;
  //sem processo
  //inherited;
end;

procedure TPGItemCollect.TreeViewAttach();
  procedure LNodeAttach(const AItem: TPGItem);
  var
    LNodeParent: TTreeNode;
    LItemChild: TPGItem;
  begin
    if (not AItem.IsCanHaveNode) then
      Exit;

    if Assigned(AItem.Parent) then
      LNodeParent := AItem.Parent.Node
    else
      LNodeParent := nil;

    AItem.SetNode( FTreeView.Items.AddChild(LNodeParent, AItem.Name));

    for LItemChild in AItem do
      LNodeAttach(LItemChild);
  end;

var
  LItem: TPGItem;
begin
  if TPGKernel.Finalized
  or (not Assigned(FTreeView))
  or (not FTreeView.HandleAllocated)
  or FAttached then
    Exit;

  Self.CollectLocked;
  Self.BeginUpdate;
  try
    FTreeView.Items.Clear;
    FAttached := True;
    for LItem in Self do
      LNodeAttach(LItem);
  finally
    Self.EndUpdate;
    Self.CollectUnlocked;
  end;
end;

procedure TPGItemCollect.TreeViewDetach(const AItem: TPGItem = nil);
  procedure LNodeDetach(const ASubItem: TPGItem);
  var
    LChild: TPGItem;
  begin
    if not Assigned(ASubItem) then Exit;
    for LChild in ASubItem do
      LNodeDetach(LChild);

    if Assigned(ASubItem.FNode) then
    begin
      ASubItem.FNode.Data := nil;
      ASubItem.FNode := nil;
      FUpdateList.Remove(ASubItem);
    end;
  end;
var
  LItem : TPGItem;
  LNode : TTreeNode;
  LIsFullClear: Boolean;
begin
  if TPGKernel.Finalized
  or (not Assigned(FTreeView))
  or (not FTreeView.HandleAllocated)
  or not FAttached then
    Exit;

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
