unit Pgofer.Component.TreeView;

interface

uses
    System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls;

type
    TTreeViewEx = class(TTreeView)
    private
        { Private declarations }
        FOwnsObjectsData: boolean;
        FAttachMode: TNodeAttachMode;
    protected
        { Protected declarations }
        procedure Delete(Node: TTreeNode); override;
        procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
            X, Y: Integer); override;
    public
        { Public declarations }
        procedure DragDrop(Source: TObject; X, Y: Integer); override;
        procedure DeleteSelect();
        function isSelectWork(): boolean;
        procedure FindText(Text: String; OffSet: Integer = -1);
        procedure SuperSelected(Node: TTreeNode);
    published
        { Published declarations }
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
    if (FOwnsObjectsData) and Assigned(Node) and Assigned(Node.Data) then
    begin
        TObject(Node.Data).Free;
        Node.Data := nil;
    end;
    inherited;
end;

procedure TTreeViewEx.DragDrop(Source: TObject; X, Y: Integer);
var
    TargetNode: TTreeNode;
    SourceNode: array of TTreeNode;
    Count: Integer;
    NodeAttach: TNodeAttachMode;
begin
    SetLength(SourceNode, Self.SelectionCount);
    for Count := 0 to Self.SelectionCount - 1 do
        SourceNode[Count] := Self.Selections[Count];

    TargetNode := Self.GetNodeAt(X, Y);
    if Assigned(TargetNode) then
        NodeAttach := FAttachMode
    else
        NodeAttach := naAdd;

    for Count := Low(SourceNode) to High(SourceNode) do
        SourceNode[Count].MoveTo(TargetNode, NodeAttach);

    inherited;
end;

procedure TTreeViewEx.DoEndDrag(Target: TObject; X, Y: Integer);
begin
    Self.Repaint;
    inherited;
end;

procedure TTreeViewEx.MouseDown(Button: TMouseButton; Shift: TShiftState;
    X, Y: Integer);
begin
    if (not Self.Dragging) then
        Self.Selected := Self.GetNodeAt(X, Y);
    inherited;
end;

procedure TTreeViewEx.SuperSelected(Node: TTreeNode);
begin
    Node.Selected := true;
    Node.MakeVisible;
    Node.Focused := true;
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
    Result := (Assigned(Selected) and Assigned(Selected.Data));
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
