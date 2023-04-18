unit Pgofer.Component.TreeView;

interface

uses
  System.Classes, System.SysUtils,
  WinApi.Messages,
  Vcl.Controls, Vcl.ComCtrls;

type
  TOnDropFile = procedure( Sender: TObject; AFiles: TStrings ) of object;

  TTreeViewEx = class( TTreeView )
  private
    FDropFileAccept: Boolean;
    FOnDropFiles: TOnDropFile;
    FOwnsObjectsData: Boolean;
    FAttachMode: TNodeAttachMode;
    FTargetDrag: TTreeNode;
    FSelectionsDrag: TArray<TTreeNode>;
    procedure DoDropFiles( var msg: TWMDropFiles ); message WM_DROPFILES;
    procedure SetDropFileAccept( AValue: Boolean );
  protected
    procedure Delete( Node: TTreeNode ); override;
    procedure DoEndDrag( Target: TObject; X, Y: Integer ); override;
    procedure MouseDown( Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer ); override;
  public
    procedure DragOver( Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean ); override;
    procedure DragDrop( Source: TObject; X, Y: Integer ); override;
    procedure DeleteSelect( );
    function isSelectWork( ): Boolean;
    procedure FindText( Text: string; OffSet: Integer = -1 );
    procedure SuperSelected( Node: TTreeNode );
    property TargetDrag: TTreeNode read FTargetDrag write FTargetDrag;
    property SelectionsDrag: TArray<TTreeNode> read FSelectionsDrag;
  published
    property OwnsObjectsData: Boolean read FOwnsObjectsData
      write FOwnsObjectsData default False;
    property AttachMode: TNodeAttachMode read FAttachMode write FAttachMode
      default naInsert;
    property DropFileAccept: Boolean read FDropFileAccept
      write SetDropFileAccept default False;
    property OnDropFiles: TOnDropFile read FOnDropFiles write FOnDropFiles;
  end;

procedure Register;

implementation

uses
  WinApi.Windows, WinApi.ShellApi;

procedure Register;
begin
  RegisterComponents( 'PGofer', [ TTreeViewEx ] );
end;

{ TTreeViewEx }

procedure TTreeViewEx.Delete( Node: TTreeNode );
begin
  if FOwnsObjectsData and Assigned( Node ) and Assigned( Node.Data ) and Node.Deleting
  then
  begin
    TObject( Node.Data ).Free;
    Node.Data := nil;
  end;
  inherited Delete( Node );
end;

procedure TTreeViewEx.DragDrop( Source: TObject; X, Y: Integer );
var
  Node: TTreeNode;
  NodeAttach: TNodeAttachMode;
begin
  if Assigned( FTargetDrag ) then
    NodeAttach := FAttachMode
  else
    NodeAttach := naAdd;

  for Node in FSelectionsDrag do
    Node.MoveTo( FTargetDrag, NodeAttach );

  inherited DragDrop( Source, X, Y );
end;

procedure TTreeViewEx.DragOver( Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean );
var
  C: Integer;
begin
  inherited DragOver( Source, X, Y, State, Accept );
  try
    FTargetDrag := Self.GetNodeAt( X, Y );
    SetLength( FSelectionsDrag, 0 );
    for C := 0 to Self.SelectionCount - 1 do
      FSelectionsDrag := FSelectionsDrag + [ Self.Selections[ C ] ];
  except
    Accept := False;
  end;
end;

procedure TTreeViewEx.SetDropFileAccept( AValue: Boolean );
var i: integer;
begin
  FDropFileAccept := AValue;
  DragAcceptFiles( Self.Handle, AValue );
  //ChangeWindowMessageFilter(WM_DROPFILES, MSGFLT_ADD);
  //ChangeWindowMessageFilter(WM_COPYDATA, MSGFLT_ADD);
  //ChangeWindowMessageFilter(WM_COPYGLOBALDATA, MSGFLT_ADD);
  for I := 0 to WM_DROPFILES do
  begin
     ChangeWindowMessageFilter (i, MSGFLT_ADD);
  end;
end;

procedure TTreeViewEx.DoDropFiles( var msg: TWMDropFiles );
var
  C, FileCount: Integer;
  TargetPoint: TPoint;
  FileName: array [ 0 .. MAX_PATH ] of Char;
  FileList: TStrings;
begin
  if FDropFileAccept and Assigned( FOnDropFiles ) then
  begin
    if DragQueryPoint( msg.Drop, TargetPoint ) then
    begin
      FTargetDrag := Self.GetNodeAt( TargetPoint.X, TargetPoint.Y );
      FileList := TStringList.Create;
      FileCount := DragQueryFile( msg.Drop, $FFFFFFFF, nil, MAX_PATH );
      for C := 0 to -1 + FileCount do
      begin
        DragQueryFile( msg.Drop, C, FileName, MAX_PATH );
        FileList.Add( FileName );
      end;
      FOnDropFiles( Self, FileList );
      FileList.Free( );
    end;
  end;
  DragFinish( msg.Drop );
end;

procedure TTreeViewEx.DoEndDrag( Target: TObject; X, Y: Integer );
begin
  Self.Repaint( );
  FTargetDrag := nil;
  SetLength( FSelectionsDrag, 0 );
  inherited DoEndDrag( Target, X, Y );
end;

procedure TTreeViewEx.SuperSelected( Node: TTreeNode );
begin
  if Assigned( Node ) then
  begin
    Node.Selected := true;
    Node.MakeVisible;
    Node.Focused := true;
  end;
end;

procedure TTreeViewEx.DeleteSelect( );
var
  Count: Integer;
begin
  for Count := Self.SelectionCount - 1 downto 0 do
  begin
    Self.Selections[ Count ].DeleteChildren;
    Self.Selections[ Count ].Delete;
  end;

  if Self.Visible then
    Self.OnGetSelectedIndex( nil, Selected );
end;

function TTreeViewEx.isSelectWork( ): Boolean;
begin
  Result := ( Assigned( Self.Selected ) and Assigned( Self.Selected.Data ) );
end;

procedure TTreeViewEx.MouseDown( Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer );
begin
  if ( not Self.Dragging ) then
    Self.Selected := Self.GetNodeAt( X, Y );
  inherited MouseDown( Button, Shift, X, Y );
end;

procedure TTreeViewEx.FindText( Text: string; OffSet: Integer = -1 );
var
  Count: Integer;
begin
  if OffSet < 0 then
  begin
    if Assigned( Self.Selected ) then
      OffSet := Self.Selected.AbsoluteIndex + 1
    else
      OffSet := 0;
  end;
  Self.ClearSelection( );
  Count := OffSet;
  while ( Count < Items.Count ) do
  begin
    if Pos( LowerCase( Text ), LowerCase( Items.Item[ Count ].Text ) ) > 0 then
    begin
      SuperSelected( Items.Item[ Count ] );
      Exit;
    end;
    inc( Count );
  end;

  Count := 0;
  while ( Count < OffSet ) do
  begin
    if Pos( LowerCase( Text ), LowerCase( Items.Item[ Count ].Text ) ) > 0 then
    begin
      SuperSelected( Items.Item[ Count ] );
      Exit;
    end;
    inc( Count );
  end;
end;

end.
