unit PGofer.Forms.Controller;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Menus,
  PGofer.ImageList, PGofer.Classes, PGofer.Forms, PGofer.Component.TreeView,
  PGofer.Component.Form;

type
  TFrmController = class( TFormEx )
    PnlTreeView: TPanel;
    PnlFind: TPanel;
    PnlButton: TPanel;
    Splitter1: TSplitter;
    EdtFind: TButtonedEdit;
    PnlFrame: TPanel;
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
  private
    FAlphaSort: Boolean;
    FAlphaSortFolder: Boolean;
    procedure PanelCleaning( );
    procedure CreatePopups( );
    procedure FrameShow( );
    procedure FrameHide( );
    function GetTargetWorking( ): TPGItem;
  protected
    FCollectItem: TPGItemCollect;
    FSelectedItem: TPGItem;
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
  end;

implementation

{$R *.dfm}

uses
  System.RTTI, System.UITypes, System.SysUtils,
  WinApi.Windows,
  Vcl.Dialogs,
  PGofer.Sintatico.Classes, PGofer.Files.Controls,
  PGofer.Triggers.Links;

constructor TFrmController.Create( ACollectItem: TPGItemCollect );
begin
  inherited Create( nil );
  FCollectItem := ACollectItem;
  FAlphaSort := True;
  FAlphaSortFolder := True;
  FSelectedItem := nil;
  Self.Name := 'Frm' + FCollectItem.Name;
  Self.Caption := FCollectItem.Name;
  TPGForm.Create( Self );
  CreatePopups( );
  TrvController.Images := GlogalImageList.ImageList;
end;

destructor TFrmController.Destroy( );
begin
  FSelectedItem := nil;
  FAlphaSort := False;
  FAlphaSortFolder := False;
  FCollectItem := nil;
  inherited Destroy( );
end;

procedure TFrmController.FormShow( Sender: TObject );
begin
  // inherited FormShow( Sender);
  FCollectItem.TreeViewAttach( );
  TrvController.AlphaSort( True );
  if not TrvController.isSelectWork then
    FrameHide( );
end;

procedure TFrmController.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  inherited FormClose( Sender, Action );
  FrameHide( );
  FCollectItem.TreeViewDetach( );
end;

procedure TFrmController.FormCreate( Sender: TObject );
begin
  inherited FormCreate( Sender );
  //
end;

procedure TFrmController.FormDestroy( Sender: TObject );
begin
  inherited FormDestroy( Sender );
  //
end;

procedure TFrmController.FormResize( Sender: TObject );
begin
  if not Self.PnlFrame.Visible then
  begin
    Self.PnlTreeView.ClientHeight := Self.ClientHeight;
    Self.PnlTreeView.ClientWidth := Self.ClientWidth;
  end;
end;

procedure TFrmController.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  Self.PnlTreeView.ClientWidth := FIniFile.ReadInteger( Self.Name,
     'TreeViewWidth', Self.TrvController.ClientWidth );
  Self.PnlFrame.ClientWidth := FIniFile.ReadInteger( Self.Name, 'FrameWidth',
     Self.PnlFrame.ClientWidth );
  Self.FAlphaSort := FIniFile.ReadBool( Self.Name, 'AlphaSort',
     Self.FAlphaSort );
  Self.FAlphaSortFolder := FIniFile.ReadBool( Self.Name, 'AlphaSortFolder',
     FAlphaSortFolder );
  Self.MniAlphaSortFolder.Checked := FAlphaSortFolder;
  if Self.FAlphaSort then
    MniAZ.Click
  else
    MniZA.Click;
end;

procedure TFrmController.IniConfigSave( );
begin
  FIniFile.WriteInteger( Self.Name, 'Width', Self.PnlTreeView.ClientWidth +
     Self.Splitter1.ClientWidth + Self.PnlFrame.ClientWidth );
  FIniFile.WriteInteger( Self.Name, 'TreeViewWidth',
     Self.PnlTreeView.ClientWidth );
  FIniFile.WriteInteger( Self.Name, 'FrameWidth', Self.PnlFrame.ClientWidth );
  FIniFile.WriteBool( Self.Name, 'AlphaSort', Self.FAlphaSort );
  FIniFile.WriteBool( Self.Name, 'AlphaSortFolder', Self.FAlphaSortFolder );
  inherited IniConfigSave( );
end;

procedure TFrmController.FrameHide( );
begin
  Self.PanelCleaning( );
  PnlFrame.Visible := False;
  Splitter1.Visible := False;
  Self.ClientWidth := PnlTreeView.ClientWidth;
  BtnRecall.Caption := '>>';
end;

procedure TFrmController.FrameShow( );
begin
  Splitter1.Visible := True;
  PnlFrame.Visible := True;
  TrvController.OnGetSelectedIndex( nil, nil );
  BtnRecall.Caption := '<<';
  Self.ClientWidth := PnlTreeView.ClientWidth + Splitter1.ClientWidth +
     PnlFrame.ClientWidth;
end;

procedure TFrmController.PanelCleaning( );
var
  c: Integer;
begin
  FCollectItem.UpdateToFile( );
  for c := PnlFrame.ControlCount - 1 downto 0 do
  begin
    PnlFrame.Controls[ c ].Free( );
  end;
  FSelectedItem := nil;
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

function TFrmController.GetTargetWorking( ): TPGItem;
begin
  if Assigned( TrvController.TargetDrag ) then
  begin
    Result := TPGItem( TrvController.TargetDrag.Data );
    if not( Result is TPGFolder ) then
      Result := Result.Parent;
  end
  else
    Result := FCollectItem;
end;

procedure TFrmController.TrvControllerDropFiles( Sender: TObject;
   AFiles: TStrings );
var
  sFileName: string;
  ItemDad: TPGItem;
begin
  ItemDad := GetTargetWorking( );
  for sFileName in AFiles do
  begin
    with TPGLink( TPGLinkMirror.Create( ItemDad,
       FileExtractOnlyFileName( sFileName ) ).ItemOriginal ) do
    begin
      FileName := FileUnExpandPath( sFileName );
      Directory := FileUnExpandPath( ExtractFilePath( sFileName ) );
    end;
  end;
  FCollectItem.UpdateToFile( );
end;

procedure TFrmController.TrvControllerDragDrop( Sender, Source: TObject;
   X, Y: Integer );
var
  Node: TTreeNode;
  ItemDad: TPGItem;
begin
  ItemDad := GetTargetWorking( );

  for Node in TrvController.SelectionsDrag do
  begin
    if Assigned( Node.Data ) and ( TPGItem( Node.Data ) is TPGItem ) then
    begin
      TPGItem( Node.Data ).Parent := ItemDad;
    end;
  end;
  FCollectItem.UpdateToFile;
end;

procedure TFrmController.TrvControllerDragOver( Sender, Source: TObject;
   X, Y: Integer; State: TDragState; var Accept: Boolean );
begin
  Accept := Sender = Source;
  if Accept then
  begin
    if Assigned( TrvController.TargetDrag ) and
       Assigned( TrvController.TargetDrag.Data ) and
       ( TPGItem( TrvController.TargetDrag.Data ) is TPGFolder ) then
    begin
      Accept := True;
      TrvController.AttachMode := naInsert;
    end;

    if not Assigned( TrvController.TargetDrag ) then
    begin
      Accept := True;
      TrvController.AttachMode := naAdd;
    end;
  end;
end;

procedure TFrmController.TrvControllerGetSelectedIndex( Sender: TObject;
   Node: TTreeNode );
begin
  if PnlFrame.Visible then
  begin
    if TrvController.isSelectWork then
    begin
      if ( TPGItem( TrvController.Selected.Data ) <> FSelectedItem ) then
      begin
        Self.PanelCleaning( );
        FSelectedItem := TPGItem( TrvController.Selected.Data );
        FSelectedItem.Frame( PnlFrame );
        PnlFrame.Caption := '';
      end;
    end else begin
      Self.PanelCleaning( );
      PnlFrame.Caption := 'No items selected!';
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
    if ( not( FSelectedItem is TPGFolder ) ) then
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
