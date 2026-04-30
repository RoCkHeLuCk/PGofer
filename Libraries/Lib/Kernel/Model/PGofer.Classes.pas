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
    class var FImageList: TCustomImageList;
    class var FIconPath: String;
    class procedure SetIconPath(const Value: String); static;
  protected
    class var FAbout: TObjectDictionary<TClass, TDictionary<string, string>>;

    function GetAbout(): String; virtual;
    function GetIsValid(): Boolean; virtual;
    function GetName(): String; virtual;
    procedure SetName(AName: string); virtual;
    procedure SetNameForced(AName: string); virtual;
    procedure SetEnabled(AValue: Boolean); virtual;
    procedure SetParent(AParent: TPGItem); virtual;
    procedure SetNode(AValue: TTreeNode); virtual;
  public
    class constructor Create();
    class destructor Destroy();
    class function ClassNameEx(): String; virtual;
    class function IconIndex(): Integer; virtual;
    class property IconPath: String read FIconPath write SetIconPath;

    constructor Create(AParent: TPGItem; AName: string); overload; virtual;
    destructor Destroy(); override;
    procedure BeforeDestruction; override;

    property About: string read GetAbout;
    property Name: string read GetName write SetName;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property SystemNode: Boolean read FSystemNode write FSystemNode;
    property Parent: TPGItem read FParent write SetParent;
    property Node: TTreeNode read FNode write SetNode;
    property isValid: Boolean read GetIsValid;
    property CollectDad: TPGItemCollect read GetCollectDad;
    property Destroying: Boolean read FDestroying;
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
  protected
    procedure SetTreeView(AValue: TTreeViewEx);
    procedure SetForm(AValue: TFormEx);
  public
    constructor Create(AName: string); overload;
    destructor Destroy(); override;
    property ImageList: TCustomImageList read GetImageList;
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

class function TPGItem.IconIndex(): Integer;
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
  if Assigned(FNode) then
    FNode.Enabled := FEnabled;
end;

class procedure TPGItem.SetIconPath(const Value: String);
begin
  if SameText(FIconPath,Value) then Exit;

  FIconPath := Value;
  FIconCache.Clear;
  FImageList.Clear;
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
    FNode.Enabled := FEnabled;
    LIndex := Self.IconIndex;
    FNode.ImageIndex := LIndex;
    FNode.SelectedIndex := LIndex;
    FNode.ExpandedImageIndex := LIndex;
  end;
end;

procedure TPGItem.SetParent(AParent: TPGItem);
var
  //LCollectDad,
  LNewCollectDad: TPGItemCollect;
begin
  if (FParent = AParent) or (FSystemNode and Assigned(FParent)) then Exit;

  //LCollectDad := GetCollectDad();
  LNewCollectDad := nil;
  if Assigned(AParent) then LNewCollectDad := AParent.CollectDad;

//  // 1. Trava as listas em mem�ria
//  if Assigned(LCollectDad) then
//   LCollectDad.LockSection;
//  if Assigned(LNewCollectDad) and (LNewCollectDad <> LCollectDad) then
//   LNewCollectDad.LockSection;

  try
    if Assigned(FParent) then FParent.Extract(Self);
    if Assigned(AParent) then AParent.Add(Self);
  finally
    FParent := AParent;
//    if Assigned(LNewCollectDad) and (LNewCollectDad <> LCollectDad) then
//      LNewCollectDad.UnlockSection;
//    if Assigned(LCollectDad) then
//      LCollectDad.UnlockSection;
  end;

  // 2. Atualiza��o VCL encapsulada na Main Thread
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

function TPGItem.GetIsValid(): Boolean;
begin
  Result := True;
end;

function TPGItem.GetName(): String;
begin
   Result := FName;
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

class function TPGItemCollect.GetImageList(): TCustomImageList;
begin
   Result := TPGItem.FImageList;
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
