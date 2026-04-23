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
    BtnEdit: TButton;
    BtnRecall: TButton;
    PpmEdit: TPopupMenu;
    MniExpand: TMenuItem;
    MniUnExpand: TMenuItem;
    PpmConttroler: TPopupMenu;
    PnlFrame: TScrollBox;
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
    procedure FormShow( Sender: TObject );
    procedure FormResize( Sender: TObject );
    procedure EdtFindKeyPress( Sender: TObject; var Key: Char );
    procedure TrvControllerCompare( Sender: TObject; Node1, Node2: TTreeNode;
      Data: Integer; var Compare: Integer );
    procedure TrvControllerGetSelectedIndex( Sender: TObject; Node: TTreeNode );
    procedure TrvControllerKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure TrvControllerMouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure TrvControllerCustomDrawItem( Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean );
    procedure MniAZClick( Sender: TObject );
    procedure MniZAClick( Sender: TObject );
    procedure MniAlphaSortFolderClick( Sender: TObject );
    procedure MniExpandClick( Sender: TObject );
    procedure MniUnExpandClick( Sender: TObject );
    procedure BtnRecallClick( Sender: TObject );
    procedure PnlFrameMouseWheelDown( Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean );
    procedure PnlFrameMouseWheelUp( Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean );
    procedure PnlFrameResize(Sender: TObject);
    procedure PnlTreeViewResize(Sender: TObject);
    procedure TrvControllerExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
  private
    FCollectItem: TPGItemCollect;
    FSelectedItem: TPGItem;
    FAlphaSort: Boolean;
    FAlphaSortFolder: Boolean;
    FTreeViewWidth: Integer;
    FFrameWidth: Integer;
    procedure PanelCleaning( );
    procedure FrameShow( );
    procedure FrameHide( );
  protected
    procedure CreateParams( var AParams: TCreateParams ); override;
    procedure CreatePopups( ); virtual;
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    function GetTargetWorking( Node: TTreeNode ): TPGItem;
    property AlphaSortFolder: Boolean read FAlphaSortFolder;
  public
    constructor Create( ACollectItem: TPGItemCollect ); reintroduce;
    destructor Destroy( ); override;

  end;

implementation

{$R *.dfm}

uses
  System.UITypes,
  WinApi.Windows,



  PGofer.Component.RichEdit;

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
  TrvController.Images := ACollectItem.ImageList;
  PpmConttroler.Images := ACollectItem.ImageList;
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

  if PpmConttroler.Items.Count = 0 then
     Self.CreatePopups;
end;

procedure TFrmController.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  FCollectItem.TreeViewDetach( );
  Self.FrameHide( );
end;

procedure TFrmController.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  FTreeViewWidth := IniFile.ReadInteger( Self.Name, 'TreeViewWidth', PnlTreeView.ClientWidth );
  FFrameWidth := IniFile.ReadInteger( Self.Name, 'FrameWidth', FFrameWidth );
  FAlphaSort := IniFile.ReadBool( Self.Name, 'AlphaSort', Self.FAlphaSort );
  FAlphaSortFolder := IniFile.ReadBool( Self.Name, 'AlphaSortFolder', FAlphaSortFolder );

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
  IniFile.WriteInteger( Self.Name, 'TreeViewWidth', FTreeViewWidth );
  IniFile.WriteInteger( Self.Name, 'FrameWidth', FFrameWidth );
  IniFile.WriteBool( Self.Name, 'AlphaSort', FAlphaSort );
  IniFile.WriteBool( Self.Name, 'AlphaSortFolder', FAlphaSortFolder );
  inherited IniConfigSave( );
end;

function TFrmController.GetTargetWorking( Node: TTreeNode ): TPGItem;
begin
  Result := nil;
  if Assigned( Node ) and Assigned( Node.Data ) then
     Result := TPGItem( Node.Data );
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
  if Application.Terminated or (csDestroying in Self.ComponentState) then
    Exit;
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
  TrvController.Items.BeginUpdate;
  try
    BtnAlphaSort.OnClick := MniAZClick;
    BtnAlphaSort.Caption := MniAZ.Caption;
    FAlphaSort := True;
    TrvController.AlphaSort( True );
  finally
    TrvController.Items.EndUpdate;
  end;
end;

procedure TFrmController.MniZAClick( Sender: TObject );
begin
  TrvController.Items.BeginUpdate;
  try
    BtnAlphaSort.OnClick := MniZAClick;
    BtnAlphaSort.Caption := MniZA.Caption;
    FAlphaSort := False;
    TrvController.AlphaSort( True );
  finally
    TrvController.Items.EndUpdate;
  end;
end;

procedure TFrmController.MniAlphaSortFolderClick( Sender: TObject );
begin
  FAlphaSortFolder := not FAlphaSortFolder;
  MniAlphaSortFolder.Checked := FAlphaSortFolder;
  TrvController.AlphaSort( True );
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
  inherited;
  if Assigned( Node.Data ) then
  begin
    Item := TPGItem( Node.Data );

    if not Item.Enabled then
      Sender.Canvas.Font.Style := Sender.Canvas.Font.Style + [fsStrikeOut];

    if Item.ReadOnly then
      Sender.Canvas.Font.Color := clGray;
  end;

end;

procedure TFrmController.TrvControllerExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var
  LItem: TPGItem;
begin
  LItem := Self.GetTargetWorking(Node);
  if Assigned(LItem) and (LItem is TPGItemExecute) then
  begin
    TPGItemExecute(LItem).BeforeAccess();
    if LItem.Count = 0 then
    begin
      Node.HasChildren := False;
      AllowExpansion := False;
    end;
  end;
end;

procedure TFrmController.TrvControllerGetSelectedIndex( Sender: TObject;  Node: TTreeNode );
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
  LPopUpItem, LSubPopUpItem, LNewPopUpItem: TMenuItem;
begin
  LPopUpItem := TMenuItem.Create( PpmConttroler );
  PpmConttroler.Items.Add( LPopUpItem );
  LPopUpItem.Caption := 'Alpha Short';
  for LSubPopUpItem in PpmAlphaSort.Items do
  begin
    LNewPopUpItem := TMenuItem.Create( PpmConttroler );
    LPopUpItem.Add( LNewPopUpItem );
    LNewPopUpItem.Caption := LSubPopUpItem.Caption;
    LNewPopUpItem.ShortCut := LSubPopUpItem.ShortCut;
    LNewPopUpItem.Checked := LSubPopUpItem.Checked;
    LNewPopUpItem.OnClick := LSubPopUpItem.OnClick;
    LNewPopUpItem.Tag := LSubPopUpItem.Tag;
  end;

  LPopUpItem := TMenuItem.Create( PpmConttroler );
  PpmConttroler.Items.Add( LPopUpItem );
  LPopUpItem.Caption := 'Edit';
  for LSubPopUpItem in PpmEdit.Items do
  begin
    LNewPopUpItem := TMenuItem.Create( PpmConttroler );
    LPopUpItem.Add( LNewPopUpItem );
    LNewPopUpItem.Caption := LSubPopUpItem.Caption;
    LNewPopUpItem.ShortCut := LSubPopUpItem.ShortCut;
    LNewPopUpItem.Checked := LSubPopUpItem.Checked;
    LNewPopUpItem.OnClick := LSubPopUpItem.OnClick;
    LNewPopUpItem.Tag := LSubPopUpItem.Tag;
  end;
end;

procedure TFrmController.BtnRecallClick( Sender: TObject );
begin
  if PnlFrame.Visible then
    Self.FrameHide( )
  else
    Self.FrameShow( );
end;

end.
