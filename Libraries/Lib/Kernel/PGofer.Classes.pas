unit PGofer.Classes;

interface

uses
    System.Classes,
    System.Generics.Collections,
    Vcl.Comctrls;

const
    LowString = Low(String);

type
    TPGItem = class(TObjectList<TPGItem>)
        constructor Create(AParent: TPGItem; Name: String); overload;
        destructor Destroy(); override;
    private
        FName: String;
        FEnabled: Boolean;
        FReadOnly: Boolean;
        FParent: TPGItem;
        FNode: TTreeNode;
        procedure SetParent(AParent: TPGItem);
        function GetCollectDad(): TPGItem;
    protected
        procedure SetName(Name: String); virtual;
        procedure SetEnabled(Value: Boolean); virtual;
        procedure SetReadOnly(Value: Boolean); virtual;
    public
        property Name: String read FName write SetName;
        property Enabled: Boolean read FEnabled write SetEnabled;
        property ReadOnly: Boolean read FReadOnly write SetReadOnly;
        property Parent: TPGItem read FParent write SetParent;
        property Node: TTreeNode read FNode write FNode;
        property CollectDad: TPGItem read GetCollectDad;
        procedure Frame(Parent: TObject); virtual;
        function FindName(Name: String): TPGItem;
        function FindNameList(Name: String; Partial: Boolean): TArray<TPGItem>;
    end;


implementation

uses
    System.SysUtils,
    PGofer.Collection,
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
            if (AParent is TPGItemCollect)
            and(Assigned(TPGItemCollect(AParent).TreeView)) then
            begin
                FNode := TPGItemCollect(AParent).TreeView
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

procedure TPGItem.SetReadOnly(Value: Boolean);
begin
    FReadOnly := Value;
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

function TPGItem.GetCollectDad: TPGItem;
begin
    if Assigned(Self.Parent) then
       Result := Self.Parent.CollectDad
    else if Self is TPGItemCollect then
       Result := TPGItemCollect(Self)
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

initialization

finalization

end.
