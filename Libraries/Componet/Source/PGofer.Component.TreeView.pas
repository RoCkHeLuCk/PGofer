unit Pgofer.Component.TreeView;

interface

uses
    System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls;

type
    TTreeViewEx = class(TTreeView)
    private
        FOwnsObjectsData: boolean;
        FAttachMode: TNodeAttachMode;
        FTargetDrag: TTreeNode;
        FSelectionsDrag: TArray<TTreeNode>;
    protected
        procedure Delete(Node: TTreeNode); override;
        procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    public
        procedure DragOver(Source: TObject; X, Y: Integer;
                  State: TDragState; var Accept: Boolean); override;
        procedure DragDrop(Source: TObject; X, Y: Integer); override;
        procedure DeleteSelect();
        function isSelectWork(): boolean;
        procedure FindText(Text: String; OffSet: Integer = -1);
        procedure SuperSelected(Node: TTreeNode);
        property TargetDrag: TTreeNode read FTargetDrag write FTargetDrag;
        property SelectionsDrag: TArray<TTreeNode> read FSelectionsDrag;
    published
        property OwnsObjectsData: boolean read FOwnsObjectsData
            write FOwnsObjectsData default False;
        property AttachMode: TNodeAttachMode read FAttachMode write FAttachMode
            default naInsert;
    end;

procedure Register;

implementation


procedure Register;
begin
    RegisterComponents('PGofer', [TTreeViewEx]);
end;

{ TTreeViewEx }

procedure TTreeViewEx.Delete(Node: TTreeNode);
begin
    if FOwnsObjectsData
    and Assigned(Node)
    and Assigned(Node.Data)
    and Node.Deleting then
    begin
        TObject(Node.Data).Free;
        Node.Data := nil;
    end;
    inherited;
end;

procedure TTreeViewEx.DragDrop(Source: TObject; X, Y: Integer);
var
    Node: TTreeNode;
    NodeAttach: TNodeAttachMode;
begin
    if Assigned(FTargetDrag) then
        NodeAttach := FAttachMode
    else
        NodeAttach := naAdd;

    for Node in FSelectionsDrag do
        Node.MoveTo(FTargetDrag, NodeAttach);

    inherited;
end;

procedure TTreeViewEx.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
    C : Integer;
begin
    inherited;
    FTargetDrag := Self.GetNodeAt(X, Y);
    SetLength(FSelectionsDrag,0);
    for c := 0 to Self.SelectionCount-1 do
       FSelectionsDrag := FSelectionsDrag + [Self.Selections[c]];
end;

procedure TTreeViewEx.DoEndDrag(Target: TObject; X, Y: Integer);
begin
    Self.Repaint;
    FTargetDrag := nil;
    SetLength(FSelectionsDrag,0);
    inherited;
end;

procedure TTreeViewEx.SuperSelected(Node: TTreeNode);
begin
    if Assigned(Node) then
    begin
        Node.Selected := true;
        Node.MakeVisible;
        Node.Focused := true;
    end;
end;

procedure TTreeViewEx.DeleteSelect();
var
    Count: Integer;
begin
    for Count := Self.SelectionCount - 1 downto 0 do
    begin
        Self.Selections[Count].DeleteChildren;
        Self.Selections[Count].Delete;
    end;

    if Self.Visible then
        Self.OnGetSelectedIndex(nil, Selected);
end;

function TTreeViewEx.isSelectWork(): boolean;
begin
    Result := (Assigned(Self.Selected) and Assigned(Self.Selected.Data));
end;

procedure TTreeViewEx.FindText(Text: String; OffSet: Integer = -1);
var
    Count: Integer;
begin
    if OffSet < 0 then
    begin
        if Assigned(Self.Selected) then
            OffSet := Self.Selected.AbsoluteIndex + 1
        else
            OffSet := 0;
    end;
    Self.ClearSelection();
    Count := OffSet;
    while (Count < Items.Count) do
    begin
        if Pos(LowerCase(Text), LowerCase(Items.Item[Count].Text)) > 0 then
        begin
            SuperSelected(Items.Item[Count]);
            Exit;
        end;
        inc(Count);
    end;

    Count := 0;
    while (Count < OffSet) do
    begin
        if Pos(LowerCase(Text), LowerCase(Items.Item[Count].Text)) > 0 then
        begin
            SuperSelected(Items.Item[Count]);
            Exit;
        end;
        inc(Count);
    end;
end;

end.
