unit PGofer.TreeView;

interface
uses
    Vcl.ComCtrls, System.SysUtils, System.UITypes, System.Classes,
    xml.XMLIntf, Xml.XMLDoc;

type
    TTreeNodeFolder = class
       constructor Create();
       destructor Destroy(); override;
    private
       FName : String;
       FExpanded : Boolean;
    public
       property Name : String read FName write FName;
       property Expanded : Boolean read FExpanded write FExpanded;
    end;

    TTreeViewHelper = class helper for TTreeView
    private
      procedure XMLSaveRtti<TDataClass:Class>(DataClass:TDataClass; XMLNode: IXMLNode);
      procedure XMLSaveNodes<TDataClass:Class>(TreeNode: TTreeNode; XMLNode: IXMLNode);
      procedure XMLLoadRtti<TDataClass:Class, Constructor>(var TreeNode: TTreeNode; XMLNode: IXMLNode);
      procedure XMLLoadNodes<TDataClass:Class, Constructor>(TreeNode: TTreeNode; XMLNode: IXMLNode);
    public
      procedure SetOnProcedHelpers();
      procedure OnAdditionHelper(Sender: TObject; Node: TTreeNode);
      procedure OnDeletionHelper(Sender: TObject; Node: TTreeNode);
      procedure OnDragDropHelper(Sender, Source: TObject; X, Y: Integer);
      procedure OnDragOverHelper(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
      procedure OnEndDragHelper(Sender, Target: TObject; X, Y: Integer);
      procedure OnMouseDownHelper(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure OnCollapsingHelper(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
      procedure OnExpandingHelper(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
      procedure DeleteSelect();
      function isSelectWork():Boolean;
      function FindCaption(ACaption: String; OffSet: Integer): TTreeNode;
      function AddTreeNode(TreeNode:TTreeNode; ImageIndex:SmallInt):TTreeNode;
      procedure XMLSaveToFile<TDataClass:Class>(FileName:String; DocumentName:String);
      procedure XMLSaveToStream<TDataClass:Class>(Stream: TStream; DocumentName:String);
      procedure XMLLoadFromFile<TDataClass:Class, Constructor>(FileName:String; DocumentName:String);
      procedure XMLLoadFromStream<TDataClass:Class, Constructor>(Stream: TStream; DocumentName:String);
    end;

implementation

uses
   System.Rtti;

{ TPGTreeNodeFolder }

constructor TTreeNodeFolder.Create();
begin
    inherited Create();
    FName := 'Nova Pasta';
    FExpanded := False;
end;

destructor TTreeNodeFolder.Destroy();
begin
    FName := '';
    FExpanded := False;
    inherited Destroy();
end;

{ TTreeViewHelper }

procedure TTreeViewHelper.SetOnProcedHelpers();
begin
    OnDeletion := OnDeletionHelper;
    OnDragDrop := OnDragDropHelper;
    OnDragOver := OnDragOverHelper;
    OnEndDrag := OnEndDragHelper;
    OnMouseDown := OnMouseDownHelper;
    OnCollapsing := OnCollapsingHelper;
    OnExpanding := OnExpandingHelper;
    OnAddition := OnAdditionHelper;
end;

procedure TTreeViewHelper.OnAdditionHelper(Sender: TObject;  Node: TTreeNode);
begin
   if Assigned(Node) and Assigned(Node.Data) then
    begin
        with TTreeNodeFolder(Node.Data) do
        begin
            Node.Text := Name;
            if Node.ImageIndex = 0 then
               Node.Expanded := Expanded;
        end;
    end;
end;

procedure TTreeViewHelper.OnDeletionHelper(Sender: TObject; Node: TTreeNode);
begin
    if Assigned(Node) and Assigned(Node.Data) then
    begin
       TObject(Node.Data).Free;
       Node.Data := nil;
    end;
end;

procedure TTreeViewHelper.OnDragDropHelper(Sender, Source: TObject; X, Y: Integer);
var
    Tree : TTreeView;
    TargetNode : TTreeNode;
    SourceNode : array of TTreeNode;
    c : integer;
    b : Boolean;
begin
    Tree := TTreeView(Sender);

    SetLength(SourceNode,Tree.SelectionCount);
    for c := 0 to Tree.SelectionCount-1 do
        SourceNode[c] := Tree.Selections[c];

    TargetNode := Tree.GetNodeAt(X, Y);
    b := Assigned(TargetNode);

    for c := 0 to Length(SourceNode)-1 do
    begin
        if b then
        begin
            if (TargetNode.ImageIndex > 0) then
               SourceNode[c].MoveTo (TargetNode, naInsert )
            else
               SourceNode[c].MoveTo (TargetNode, naAddChildFirst );
        end else begin
            SourceNode[c].MoveTo (TargetNode, naAdd );
        end;
    end;

end;

procedure TTreeViewHelper.OnDragOverHelper(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
    if Sender = Source then
       Accept := True;
end;

procedure TTreeViewHelper.OnEndDragHelper(Sender, Target: TObject; X, Y: Integer);
begin
    TTreeView(Sender).Repaint;
end;

procedure TTreeViewHelper.OnMouseDownHelper(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    //(ssRight in Shift) and
    if (not TTreeView(Sender).Dragging) then
       TTreeView(Sender).Selected := TTreeView(Sender).GetNodeAt(X, Y);
end;

procedure TTreeViewHelper.OnCollapsingHelper(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
begin
    TTreeNodeFolder(Node.Data).Expanded := False;
end;

procedure TTreeViewHelper.OnExpandingHelper(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
begin
    TTreeNodeFolder(Node.Data).Expanded := True;
end;

function TTreeViewHelper.AddTreeNode(TreeNode: TTreeNode; ImageIndex: SmallInt): TTreeNode;
begin
    if Assigned(TreeNode) and (TreeNode.ImageIndex = 0) then
       Result := Items.AddChild( TreeNode , '' )
    else
       Result := Items.Add( TreeNode , '' );

    Result.ImageIndex := ImageIndex;
    Result.ExpandedImageIndex := ImageIndex;
    Result.SelectedIndex := ImageIndex;
    Result.StateIndex := -1;
    Result.Data := nil;
end;

Procedure TTreeViewHelper.DeleteSelect();
var c : Integer;
begin
    c := SelectionCount-1;
    while (c >= 0) do
    begin
        Selections[c].DeleteChildren;
        Selections[c].Delete;
        Dec(c);
    end;
    if Self.Visible then
       Self.OnGetSelectedIndex(nil,Selected);
end;

function TTreeViewHelper.isSelectWork(): Boolean;
begin
    Result := (Assigned(Selected) and Assigned(Selected.Data));
end;

function TTreeViewHelper.FindCaption(ACaption: String; OffSet: Integer): TTreeNode;
var
    LCount: Integer;
begin
    Result := nil;
    LCount := OffSet;
    while (LCount < Items.Count) and (Result = nil) do
    begin
        if SameText(Items.Item[LCount].Text,ACaption)
        and (Items.Item[LCount].Parent = nil) then
            Result := Items.Item[LCount];
        inc(LCount);
    end;
end;

procedure TTreeViewHelper.XMLSaveRtti<TDataClass>(DataClass:TDataClass; XMLNode: IXMLNode);
var
    RttiContext : TRttiContext;
    RttiType : TRttiType;
    RttiProperty : TRttiProperty;
    NodeAux: IXMLNode;
begin
    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(TypeInfo(TDataClass));
    for RttiProperty in RttiType.GetProperties do
    begin
        if RttiProperty.IsReadable and RttiProperty.IsWritable then
        begin
            NodeAux := XMLNode.AddChild(RttiProperty.Name);
            NodeAux.Attributes['Tipo'] := UpperCase(RttiProperty.PropertyType.ToString);
            NodeAux.Text := RttiProperty.GetValue(Pointer(DataClass)).ToString;
        end;
    end;
end;

procedure TTreeViewHelper.XMLSaveNodes<TDataClass>(TreeNode: TTreeNode; XMLNode: IXMLNode);
var
    AuxXMLNode : IXMLNode;
begin
    if Assigned(TreeNode) then
    begin
        if (TreeNode.ImageIndex = 0) then
        begin
            AuxXMLNode := XMLNode.AddChild( 'Pasta' );
            XMLSaveRtti<TTreeNodeFolder>(TreeNode.Data, AuxXMLNode);

            TreeNode:= TreeNode.getFirstChild;
            while Assigned(TreeNode) do
            begin
                XMLSaveNodes<TDataClass>(TreeNode, AuxXMLNode);
                TreeNode:= TreeNode.getNextSibling;
            end;
        end else begin
            AuxXMLNode := XMLNode.AddChild( 'Item' );
            XMLSaveRtti<TDataClass>(TDataClass(TreeNode.Data), AuxXMLNode);
        end;
    end;
end;

procedure TTreeViewHelper.XMLSaveToFile<TDataClass>(FileName: String; DocumentName:String);
var
    Stream: TStream;
begin
    Stream := TFileStream.Create(FileName, fmCreate);
    try
        XMLSaveToStream<TDataClass>(Stream, DocumentName);
    finally
        Stream.Free;
    end;
end;

procedure TTreeViewHelper.XMLSaveToStream<TDataClass>(Stream: TStream; DocumentName:String);
var
    XMLDocument : IXMLDocument;
    TreeNode : TTreeNode;
begin
    XMLDocument := TXMLDocument.Create(nil);
    XMLDocument.Options := [doNodeAutoCreate, doNodeAutoIndent, doAttrNull, doAutoPrefix, doNamespaceDecl, doAutoSave];
    XMLDocument.Active := True;
    XMLDocument.DocumentElement := XMLDocument.CreateNode(DocumentName,ntElement,'');
    XMLDocument.DocumentElement.Attributes['Version'] := '1.0';

    TreeNode := Items.GetFirstNode;
    while Assigned(TreeNode) do
    begin
        XMLSaveNodes<TDataClass>(TreeNode, XMLDocument.DocumentElement);
        TreeNode := TreeNode.GetNextSibling;
    end;

    XMLDocument.SaveToStream(Stream);
    XMLDocument.Active := False;
end;

procedure TTreeViewHelper.XMLLoadRtti<TDataClass>(var TreeNode: TTreeNode; XMLNode: IXMLNode);
var
    DataClass : TDataClass;
    RttiContext : TRttiContext;
    RttiType : TRttiType;
    RttiProperty : TRttiProperty;
    NodeAux : IXMLNode;
begin
    DataClass := TDataClass.Create;
    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType( TypeInfo(TDataClass) );
    for RttiProperty in RttiType.GetProperties do
    begin
        NodeAux := XMLNode.ChildNodes.FindNode( RttiProperty.Name );
        if Assigned(NodeAux) then
        begin
            try
               case RttiProperty.PropertyType.TypeKind of
                   tkInteger     : RttiProperty.SetValue(Pointer(DataClass), StrToIntDef(NodeAux.Text,0) );
                   tkEnumeration : RttiProperty.SetValue(Pointer(DataClass), StrToBoolDef(NodeAux.Text,False) );
                   tkFloat       : RttiProperty.SetValue(Pointer(DataClass), StrToFloatDef(NodeAux.Text,0) );
                   tkString,
                   tkLString,
                   tkWString,
                   tkUString      : RttiProperty.SetValue(Pointer(DataClass), NodeAux.Text );
               end;
            except
                raise Exception.Create('Erro: "'+ XMLNode.NodeName +'", Campo "'+RttiProperty.Name+'" contem valor invalido.');
            end;

            if (SameText(RttiProperty.Name,'Enabled')) then
                TreeNode.Enabled := StrToBoolDef(NodeAux.Text,False);
        end;
    end;
    TreeNode.Data := Pointer(DataClass);
end;

procedure TTreeViewHelper.XMLLoadNodes<TDataClass>(TreeNode: TTreeNode; XMLNode: IXMLNode);
begin
    if Assigned(XMLNode) then
    begin
        if XMLNode.NodeName = 'Pasta' then
        begin
            TreeNode := AddTreeNode(TreeNode,0);
            XMLLoadRtti<TTreeNodeFolder>(TreeNode, XMLNode);

            XMLNode := XMLNode.ChildNodes.First;
            while XMLNode <> nil do
            begin
              XMLLoadNodes<TDataClass>(TreeNode, XMLNode);
              XMLNode := XMLNode.NextSibling;
            end;
        end else begin
            if XMLNode.NodeName = 'Item' then
            begin
               TreeNode := AddTreeNode(TreeNode,1);
               XMLLoadRtti<TDataClass>(TreeNode, XMLNode);
            end;
        end;

        OnAddition(Self,TreeNode);
    end;
end;

procedure TTreeViewHelper.XMLLoadFromFile<TDataClass>(FileName:String; DocumentName:String);
var
    Stream: TStream;
begin
    Stream := TFileStream.Create(FileName, fmOpenRead);
    try
        XMLLoadFromStream<TDataClass>(Stream, DocumentName);
    finally
        Stream.Free;
    end;
end;

procedure TTreeViewHelper.XMLLoadFromStream<TDataClass>(Stream: TStream; DocumentName:String);
var
    XMLDocument : IXMLDocument;
    XMLNode : IXMLNode;
begin
    Items.Clear;
    XMLDocument := TXMLDocument.Create(nil);
    XMLDocument.LoadFromStream( Stream );
    XMLDocument.Active := True;
    XMLNode := XMLDocument.ChildNodes.FindNode(DocumentName);
    if Assigned(XMLNode) then
    begin
        XMLNode := XMLNode.ChildNodes.First;
        while XMLNode <> nil do
        begin
            XMLLoadNodes<TDataClass>(nil, XMLNode);
            XMLNode := XMLNode.NextSibling;
        end;
    end;
    XMLDocument.Active := False;
end;


end.
