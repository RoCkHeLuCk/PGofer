unit PGofer.Forms.Controller;

interface

uses
  System.Classes, System.Types,

  Vcl.Forms, Vcl.Controls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.Graphics,
  PGofer.Classes, PGofer.Runtime, PGofer.Forms, PGofer.Component.TreeView,
  PGofer.Component.Form;

type
  TFrmController = class( TFormEx )
    PnlTreeView: TPanel;
    PnlFind: TPanel;
    PnlButton: TPanel;
    SptController: TSplitter;
    EdtFind: TButtonedEdit;
    TrvController: TTreeViewEx;
    BtnAlphaSort: TButton;
    PpmAlphaSort: TPopupMenu;
    MniAZ: TMenuItem;
    MniZA: TMenuItem;
    MniAlphaSortFolder: TMenuItem;
    MniN1: TMenuItem;
    BtnCreate: TButton;
    BtnEdit: TButton;
    PpmCreate: TPopupMenu;
    BtnRecall: TButton;
    PpmEdit: TPopupMenu;
    MniDelete: TMenuItem;
    MniExpand: TMenuItem;
    MniUnExpand: TMenuItem;
    MniN2: TMenuItem;
    PpmConttroler: TPopupMenu;
    PnlFrame: TScrollBox;
    constructor Create( ACollectItem: TPGItemCollect ); reintroduce;
    destructor Destroy( ); override;
    procedure FormCreate( Sender: TObject );
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
    procedure FormShow( Sender: TObject );
    procedure FormDestroy( Sender: TObject );
    procedure FormResize( Sender: TObject );
    procedure onCreateItemPopUpClick( Sender: TObject );
    procedure EdtFindKeyPress( Sender: TObject; var Key: Char );
    procedure TrvControllerCompare( Sender: TObject; Node1, Node2: TTreeNode;
      Data: Integer; var Compare: Integer );
    procedure TrvControllerGetSelectedIndex( Sender: TObject; Node: TTreeNode );
    procedure TrvControllerDragOver( Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean );
    procedure TrvControllerDragDrop( Sender, Source: TObject; X, Y: Integer );
    procedure TrvControllerDropFiles( Sender: TObject; AFiles: TStrings );
    procedure TrvControllerKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure TrvControllerMouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure MniAZClick( Sender: TObject );
    procedure MniZAClick( Sender: TObject );
    procedure MniAlphaSortFolderClick( Sender: TObject );
    procedure MniDeleteClick( Sender: TObject );
    procedure MniExpandClick( Sender: TObject );
    procedure MniUnExpandClick( Sender: TObject );
    procedure BtnRecallClick( Sender: TObject );
    procedure PnlFrameMouseWheelDown( Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean );
    procedure PnlFrameMouseWheelUp( Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean );
    procedure TrvControllerCustomDrawItem( Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean );
    procedure PnlFrameResize(Sender: TObject);
    procedure PnlTreeViewResize(Sender: TObject);
  private
    FAlphaSort: Boolean;
    FAlphaSortFolder: Boolean;
    FTreeViewWidth: Integer;
    FFrameWidth: Integer;
    procedure PanelCleaning( );
    procedure CreatePopups( );
    procedure FrameShow( );
    procedure FrameHide( );
    function GetTargetWorking( Node: TTreeNode ): TPGItem;
    function GetFolderWorking( Node: TTreeNode ): TPGItem;
  protected
    FCollectItem: TPGItemCollect;
    FSelectedItem: TPGItem;
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    procedure CreateParams( var AParams: TCreateParams ); override;
  public
  end;

implementation

{$R *.dfm}

uses
  System.RTTI, System.UITypes, System.SysUtils,
  WinApi.Windows,
  Vcl.Dialogs,
  PGofer.Files.Controls,
  PGofer.Triggers.Links,
  PGofer.Component.RichEdit,
  PGofer.Triggers,
  PGofer.IconList;

{ TFrmController }

procedure TFrmController.CreateParams( var AParams: TCreateParams );
begin
  inherited;
  Self.ForceResizable := True;
end;

constructor TFrmController.Create( ACollectItem: TPGItemCollect );
begin
  inherited Create( nil );
  FCollectItem := ACollectItem;
  FAlphaSort := True;
  FAlphaSortFolder := True;
  FSelectedItem := nil;
  FFrameWidth := PnlFrame.Width;
  FTreeViewWidth := PnlTreeView.Width;
  Self.Name := 'Frm' + FCollectItem.Name;
  Self.Caption := FCollectItem.Name;
  TPGForm.Create( Self );
  CreatePopups( );
  TrvController.Images := TPGIconList.ImageList;
  PpmCreate.Images := TPGIconList.ImageList;
  PpmConttroler.Images := TPGIconList.ImageList;
end;

destructor TFrmController.Destroy( );
begin
  FTreeViewWidth := 0;
  FFrameWidth := 0;
  FSelectedItem := nil;
  FAlphaSort := False;
  FAlphaSortFolder := False;
  FCollectItem := nil;
  inherited Destroy( );
end;

procedure TFrmController.FormShow( Sender: TObject );
begin
  FCollectItem.TreeViewAttach( );
  TrvController.AlphaSort( True );
  if not TrvController.isSelectWork then
    Self.FrameHide( );
end;

procedure TFrmController.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  inherited FormClose( Sender, Action );
  Self.FrameHide( );
  FCollectItem.TreeViewDetach( );
end;

procedure TFrmController.FormCreate( Sender: TObject );
begin
  inherited FormCreate( Sender );
end;

procedure TFrmController.FormDestroy( Sender: TObject );
begin
  inherited FormDestroy( Sender );
end;

procedure TFrmController.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  FTreeViewWidth := FIniFile.ReadInteger( Self.Name, 'TreeViewWidth', PnlTreeView.ClientWidth );
  FFrameWidth := FIniFile.ReadInteger( Self.Name, 'FrameWidth', FFrameWidth );
  FAlphaSort := FIniFile.ReadBool( Self.Name, 'AlphaSort', Self.FAlphaSort );
  FAlphaSortFolder := FIniFile.ReadBool( Self.Name, 'AlphaSortFolder', FAlphaSortFolder );

  PnlTreeView.ClientWidth := FTreeViewWidth;
  PnlFrame.ClientWidth := FFrameWidth;
  MniAlphaSortFolder.Checked := FAlphaSortFolder;
  if FAlphaSort then
    MniAZ.Click
  else
    MniZA.Click;
end;

procedure TFrmController.IniConfigSave( );
begin
  FCollectItem.XMLSaveToFile( );
  FIniFile.WriteInteger( Self.Name, 'TreeViewWidth', FTreeViewWidth );
  FIniFile.WriteInteger( Self.Name, 'FrameWidth', FFrameWidth );
  FIniFile.WriteBool( Self.Name, 'AlphaSort', FAlphaSort );
  FIniFile.WriteBool( Self.Name, 'AlphaSortFolder', FAlphaSortFolder );
  inherited IniConfigSave( );
end;

procedure TFrmController.FrameHide( );
begin
  PnlFrame.Visible := False;
  SptController.Visible := False;
  Self.PanelCleaning( );
  Self.ClientWidth := FTreeViewWidth;
  BtnRecall.Caption := '>>';
end;

procedure TFrmController.FrameShow( );
begin
  PnlFrame.OnResize := nil;
  PnlFrame.Visible := True;
  Self.ClientWidth := FTreeViewWidth + SptController.ClientWidth + FFrameWidth;
  SptController.Visible := True;
  BtnRecall.Caption := '<<';
  TrvController.OnGetSelectedIndex( nil, nil );
  PnlFrame.OnResize := PnlFrameResize;
end;

procedure TFrmController.PnlFrameResize(Sender: TObject);
begin
  if PnlFrame.Visible then
     FFrameWidth := PnlFrame.ClientWidth;
end;

procedure TFrmController.PnlTreeViewResize(Sender: TObject);
begin
  FTreeViewWidth := PnlTreeView.ClientWidth;
end;

procedure TFrmController.FormResize( Sender: TObject );
begin
  if not PnlFrame.Visible then
    PnlTreeView.ClientWidth := Self.ClientWidth;
end;

procedure TFrmController.PanelCleaning( );
var
  c: Integer;
begin
  for c := PnlFrame.ControlCount - 1 downto 0 do
  begin
    PnlFrame.Controls[ c ].Free( );
  end;
  FSelectedItem := nil;
end;

procedure TFrmController.PnlFrameMouseWheelDown( Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean );
var
  Control: TWinControl;
begin
  Control := FindVCLWindow( MousePos );
  if ( Control is TRichEditEx ) then
  begin
    with TRichEditEx( Control ) do
    begin
      if VerticalScrollPos < VerticalScrollMax then
        exit;
    end;
  end;
  PnlFrame.VertScrollBar.Position := PnlFrame.VertScrollBar.ScrollPos +
    PnlFrame.VertScrollBar.Increment;
end;

procedure TFrmController.PnlFrameMouseWheelUp( Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean );
var
  Control: TWinControl;
begin
  Control := FindVCLWindow( MousePos );
  if ( Control is TRichEditEx ) then
  begin
    if TRichEditEx( Control ).VerticalScrollPos > 0 then
      exit;
  end;
  PnlFrame.VertScrollBar.Position := PnlFrame.VertScrollBar.ScrollPos -
    PnlFrame.VertScrollBar.Increment;
end;

procedure TFrmController.EdtFindKeyPress( Sender: TObject; var Key: Char );
begin
  if Key = #13 then
    TrvController.FindText( EdtFind.Text );
end;

procedure TFrmController.MniAZClick( Sender: TObject );
begin
  BtnAlphaSort.OnClick := MniAZClick;
  BtnAlphaSort.Caption := MniAZ.Caption;
  FAlphaSort := True;
  TrvController.AlphaSort( True );
end;

procedure TFrmController.MniZAClick( Sender: TObject );
begin
  BtnAlphaSort.OnClick := MniZAClick;
  BtnAlphaSort.Caption := MniZA.Caption;
  FAlphaSort := False;
  TrvController.AlphaSort( True );
end;

procedure TFrmController.MniAlphaSortFolderClick( Sender: TObject );
begin
  FAlphaSortFolder := not FAlphaSortFolder;
  MniAlphaSortFolder.Checked := FAlphaSortFolder;
  TrvController.AlphaSort( True );
end;

procedure TFrmController.MniDeleteClick( Sender: TObject );
begin
  if Vcl.Dialogs.MessageDlg( 'Delete Selected Item?', mtConfirmation,
    [ mbYes, mbNo ], 0, mbNo ) = mrYes then
  begin
    TrvController.DeleteSelect( );
  end;
  BtnEdit.Caption := MniDelete.Caption;
  BtnEdit.OnClick := MniDelete.OnClick;
end;

procedure TFrmController.MniExpandClick( Sender: TObject );
begin
  TrvController.FullExpand( );
  BtnEdit.Caption := MniExpand.Caption;
  BtnEdit.OnClick := MniExpand.OnClick;
end;

procedure TFrmController.MniUnExpandClick( Sender: TObject );
begin
  TrvController.FullCollapse( );
  BtnEdit.Caption := MniUnExpand.Caption;
  BtnEdit.OnClick := MniUnExpand.OnClick;
end;

procedure TFrmController.TrvControllerCompare( Sender: TObject;
  Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer );
var
  FolderNode1, FolderNode2: Boolean;
begin
  Compare := lstrcmp( PChar( Node1.Text ), PChar( Node2.Text ) );

  if not FAlphaSort then
    Compare := Compare * -1;

  if FAlphaSortFolder then
  begin
    FolderNode1 := Assigned( Node1.Data ) and
      ( TPGItem( Node1.Data ) is TPGFolder );
    FolderNode2 := Assigned( Node2.Data ) and
      ( TPGItem( Node2.Data ) is TPGFolder );

    if ( FolderNode1 ) and ( not FolderNode2 ) then
    begin
      Compare := -1;
    end;

    if ( not FolderNode1 ) and ( FolderNode2 ) then
    begin
      Compare := 1;
    end;
  end;
end;

procedure TFrmController.TrvControllerCustomDrawItem( Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean );
var
  Item: TPGItem;
begin
  if not (cdsSelected in State) then
  begin
    Sender.Canvas.Brush.Color := TrvController.Color;
    Sender.Canvas.Brush.Style := bsSolid;
  end;

  inherited;
  if Assigned( Node.Data ) then
  begin
    Item := TPGItem( Node.Data );
    if ( not Item.isValid ) then
    begin
      Sender.Canvas.Font.Color := clRed;
    end else if ( not Item.Enabled ) then
    begin
      Sender.Canvas.Font.Color := clGray;
    end;

    if ( Item is TPGFolder ) and ( TPGFolder(Item)._Locked ) then
    begin
      Sender.Canvas.Font.Style := [ fsItalic ];
    end;
  end;
end;

function TFrmController.GetTargetWorking( Node: TTreeNode ): TPGItem;
begin
  Result := nil;
  if Assigned( Node ) and Assigned( Node.Data ) then
     Result := TPGItem( Node.Data );
end;

function TFrmController.GetFolderWorking( Node: TTreeNode ): TPGItem;
begin
  Result := GetTargetWorking( Node );
  if Assigned(Result) then
  begin
    if not (Result is TPGFolder ) then
    begin
      Result := Result.Parent;
    end else begin
      if TPGFolder(Result)._Locked then
        Result := nil;
    end;
  end else begin
    Result := FCollectItem;
  end;
end;

procedure TFrmController.TrvControllerDropFiles( Sender: TObject;
  AFiles: TStrings );
var
  sFileName: string;
  ItemDad: TPGItem;
begin
  ItemDad := GetFolderWorking( TrvController.TargetDrag );
  if Assigned(ItemDad) then
  begin
    for sFileName in AFiles do
    begin
      with TPGLink( TPGLinkMirror.Create( ItemDad,
        FileExtractOnlyFileName( sFileName ) ).ItemOriginal ) do
      begin
        FileName := FileUnExpandPath( sFileName );
        Directory := FileUnExpandPath( ExtractFilePath( sFileName ) );
      end;
    end;
    FCollectItem.XMLSaveToFile( );
  end;
end;

procedure TFrmController.TrvControllerDragDrop( Sender, Source: TObject;
  X, Y: Integer );
var
  Node: TTreeNode;
  ItemDad: TPGItem;
begin
  ItemDad := GetFolderWorking( TrvController.TargetDrag );

  if Assigned(ItemDad) then
  begin
    for Node in TrvController.SelectionsDrag do
    begin
      if Assigned( Node.Data ) and ( TPGItem( Node.Data ) is TPGItem ) then
      begin
        TPGItem( Node.Data ).Parent := ItemDad;
      end;
    end;
    FCollectItem.XMLSaveToFile;
  end;
end;

procedure TFrmController.TrvControllerDragOver( Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean );
var
  Item : TPGItem;
begin
  Accept := Sender = Source;
  if Accept then
  begin
    Item := GetTargetWorking(TrvController.TargetDrag);
    if Assigned(Item) then
    begin
      if ( Item is TPGFolder ) and (not TPGFolder(Item)._Locked ) then
      begin
        Accept := True;
        TrvController.AttachMode := naInsert;
      end else begin
        Accept := False;
      end;
    end else begin
      Accept := True;
      TrvController.AttachMode := naAdd;
    end;
  end;
end;

procedure TFrmController.TrvControllerGetSelectedIndex( Sender: TObject;
  Node: TTreeNode );
var
  Item : TPGItem;
begin
  if PnlFrame.Visible then
  begin
    Item := GetTargetWorking(TrvController.Selected);
    if Assigned(Item) then
    begin
      if ( Item <> FSelectedItem ) then
      begin
        Self.PanelCleaning( );
        FSelectedItem := Item;
        FSelectedItem.Frame( PnlFrame );
      end;
    end else begin
      Self.PanelCleaning( );
    end;
    PnlFrame.Update;
    PnlFrame.Refresh;
  end;
end;

procedure TFrmController.TrvControllerKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  case Key of
    VK_RETURN:
      Self.FrameShow( );
    VK_ESCAPE:
      Self.FrameHide( );
  end;
end;

procedure TFrmController.TrvControllerMouseDown( Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
begin
  if TrvController.isSelectWork then
    Self.FrameShow( )
  else
    Self.FrameHide( );
end;

procedure TFrmController.CreatePopups( );
var
  PopUpItem, SubPopUpItem, NewPopUpItem: TMenuItem;
  c, l: Integer;
begin
  l := FCollectItem.RegClassList.Count - 1;
  if l > 0 then
  begin
    BtnCreate.Visible := True;
    TrvController.DragMode := dmAutomatic;
    TrvController.DropFileAccept := True;
    for c := 0 to l do
    begin
      PopUpItem := TMenuItem.Create( PpmCreate );
      PpmCreate.Items.Add( PopUpItem );
      PopUpItem.Caption := FCollectItem.RegClassList.GetNameIndex( c );
      PopUpItem.ImageIndex := FCollectItem.RegClassList.GetIconIndex( c );
      PopUpItem.ShortCut := TextToShortCut( 'ALT+' + IntToStr( c + 1 ) );
      PopUpItem.Tag := c;
      PopUpItem.OnClick := onCreateItemPopUpClick;
    end;
  end;

  PopUpItem := TMenuItem.Create( PpmConttroler );
  PpmConttroler.Items.Add( PopUpItem );
  PopUpItem.Caption := 'Alpha Short';
  for SubPopUpItem in PpmAlphaSort.Items do
  begin
    NewPopUpItem := TMenuItem.Create( PpmConttroler );
    PopUpItem.Add( NewPopUpItem );
    NewPopUpItem.Caption := SubPopUpItem.Caption;
    NewPopUpItem.ShortCut := SubPopUpItem.ShortCut;
    NewPopUpItem.Checked := SubPopUpItem.Checked;
    NewPopUpItem.OnClick := SubPopUpItem.OnClick;
    NewPopUpItem.Tag := SubPopUpItem.Tag;
  end;

  PopUpItem := TMenuItem.Create( PpmConttroler );
  PpmConttroler.Items.Add( PopUpItem );
  PopUpItem.Caption := 'Edit';
  for SubPopUpItem in PpmEdit.Items do
  begin
    NewPopUpItem := TMenuItem.Create( PpmConttroler );
    PopUpItem.Add( NewPopUpItem );
    NewPopUpItem.Caption := SubPopUpItem.Caption;
    NewPopUpItem.ShortCut := SubPopUpItem.ShortCut;
    NewPopUpItem.Checked := SubPopUpItem.Checked;
    NewPopUpItem.OnClick := SubPopUpItem.OnClick;
    NewPopUpItem.Tag := SubPopUpItem.Tag;
  end;

  PopUpItem := TMenuItem.Create( PpmConttroler );
  PpmConttroler.Items.Add( PopUpItem );
  PopUpItem.Caption := 'Create';
  for SubPopUpItem in PpmCreate.Items do
  begin
    NewPopUpItem := TMenuItem.Create( PpmConttroler );
    PopUpItem.Add( NewPopUpItem );
    NewPopUpItem.Caption := SubPopUpItem.Caption;
    NewPopUpItem.ShortCut := SubPopUpItem.ShortCut;
    NewPopUpItem.Checked := SubPopUpItem.Checked;
    NewPopUpItem.OnClick := SubPopUpItem.OnClick;
    NewPopUpItem.Tag := SubPopUpItem.Tag;
    NewPopUpItem.ImageIndex := SubPopUpItem.ImageIndex;
  end;

end;

procedure TFrmController.onCreateItemPopUpClick( Sender: TObject );
var
  NumItem: Integer;
  IClass: TClass;
  IName: string;
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  Value: TValue;
begin
  if ( Sender is TMenuItem ) then
  begin
    with TMenuItem( Sender ) do
    begin
      BtnCreate.Caption := Caption;
      BtnCreate.Tag := Tag;
    end;
  end;
  NumItem := TComponent( Sender ).Tag;

  IClass := FCollectItem.RegClassList.GetClassIndex( NumItem );
  IName := FCollectItem.RegClassList.GetNameIndex( NumItem );

  if not Assigned( FSelectedItem ) then
  begin
    FSelectedItem := FCollectItem;
  end else begin
    if ( not( FSelectedItem is TPGFolder ) ) or ( TPGFolder(FSelectedItem)._Locked ) then
    begin
      FSelectedItem := FSelectedItem.Parent;
    end;
  end;

  RttiContext := TRttiContext.Create( );
  RttiType := RttiContext.GetType( IClass );
  Value := RttiType.GetMethod( 'Create' )
    .Invoke( IClass, [ FSelectedItem, IName ] );
  TrvController.SuperSelected( TPGItem( Value.AsObject ).Node );
end;

procedure TFrmController.BtnRecallClick( Sender: TObject );
begin
  if PnlFrame.Visible then
    Self.FrameHide( )
  else
    Self.FrameShow( );
end;

end.
