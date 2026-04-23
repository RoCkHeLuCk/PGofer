unit PGofer.Triggers.Form;

interface

uses

  System.SysUtils, System.Classes,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls,
  Pgofer.Component.TreeView, PGofer.Forms.Controller,
  PGofer.Classes, PGofer.Triggers.Collections, Vcl.ExtCtrls;

type
  TFrmTriggerController = class(TFrmController)
    N1: TMenuItem;
    MniDelete: TMenuItem;
    BtnCreate: TButton;
    PpmCreate: TPopupMenu;
    procedure MniDeleteClick( Sender: TObject );
    procedure TrvControllerCompare( Sender: TObject; Node1, Node2: TTreeNode;
      Data: Integer; var Compare: Integer );
    procedure TrvControllerCustomDrawItem( Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean );
    procedure TrvControllerDragOver( Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean );
    procedure TrvControllerDragDrop( Sender, Source: TObject; X, Y: Integer );
    procedure TrvControllerDropFiles( Sender: TObject; AFiles: TStrings );
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCollectItem: TPGItemCollectTrigger;
    function GetFolderWorking( Node: TTreeNode ): TPGItem;
  protected
    procedure CreatePopups( ); override;
    procedure onCreateItemPopUpClick( Sender: TObject );
  public
    constructor Create( ACollectItem: TPGItemCollectTrigger ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  FrmTriggerController: TFrmTriggerController;

implementation

{$R *.dfm}

uses
  System.UITypes, System.RTTI,
  PGofer.Triggers;

constructor TFrmTriggerController.Create( ACollectItem: TPGItemCollectTrigger );
begin
  FCollectItem := ACollectItem;
  inherited Create( ACollectItem );
  PpmCreate.Images := ACollectItem.ImageList;
end;

destructor TFrmTriggerController.Destroy( );
begin
  FCollectItem := nil;
  inherited Destroy( );
end;

procedure TFrmTriggerController.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FCollectItem.XMLSaveToFile( );
  inherited FormClose(Sender,Action);
end;

function TFrmTriggerController.GetFolderWorking( Node: TTreeNode ): TPGItem;
begin
  Result := GetTargetWorking( Node );
  if Assigned(Result) then
  begin
    if not (Result is TPGFolderMirror ) then
    begin
      Result := Result.Parent;
    end else begin
      if TPGFolderMirror(Result)._Locked then
        Result := nil;
    end;
  end else begin
    Result := FCollectItem;
  end;
end;

procedure TFrmTriggerController.TrvControllerDropFiles( Sender: TObject; AFiles: TStrings );
var
  LModified: Boolean;
  LFileName: string;
  LItemDad: TPGItem;
  LClassItem: TClassItem;
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LMethod: TRttiMethod;
begin
  LItemDad := GetFolderWorking(TrvController.TargetDrag);
  if not Assigned(LItemDad) then Exit;

  LRttiContext := TRttiContext.Create;
  LModified := False;
  for LFileName in AFiles do
  begin
    for LClassItem in FCollectItem.ClassList do
    begin
      LRttiType := LRttiContext.GetType( LClassItem.ClassType );
      LMethod := LRttiType.GetMethod( 'OnDropFile' );
      if Assigned(LMethod) then
      begin
        if LMethod.Invoke( LClassItem.ClassType , [LItemDad, LFileName]).AsBoolean then
        begin
          LModified := True;
          Break;
        end;
      end;
    end;
  end;
  LRttiContext.Free;

  if LModified then
    FCollectItem.XMLSaveToFile();
end;

procedure TFrmTriggerController.TrvControllerDragDrop( Sender, Source: TObject;
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
    FCollectItem.XMLSaveToFile( );
  end;
end;

procedure TFrmTriggerController.TrvControllerDragOver( Sender, Source: TObject;
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
      if ( Item is TPGFolderMirror ) and (not TPGFolderMirror(Item)._Locked ) then
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

procedure TFrmTriggerController.MniDeleteClick( Sender: TObject );
begin
  if Vcl.Dialogs.MessageDlg( 'Delete Selected Item?', mtConfirmation,
    [ mbYes, mbNo ], 0, mbNo ) = mrYes then
  begin
    TrvController.Items.BeginUpdate();
    try
      TrvController.DeleteSelect();
    finally
      TrvController.Items.EndUpdate(); // Desenha tudo pronto de uma vez só
    end;
  end;
  BtnEdit.Caption := MniDelete.Caption;
  BtnEdit.OnClick := MniDelete.OnClick;
end;


procedure TFrmTriggerController.TrvControllerCompare( Sender: TObject;
  Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer );
var
  FolderNode1, FolderNode2: Boolean;
begin
  inherited;
  if AlphaSortFolder then
  begin
    FolderNode1 := Assigned( Node1.Data ) and
      ( TPGItem( Node1.Data ) is TPGFolderMirror );
    FolderNode2 := Assigned( Node2.Data ) and
      ( TPGItem( Node2.Data ) is TPGFolderMirror );

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


procedure TFrmTriggerController.TrvControllerCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  Item: TPGItem;
begin
  inherited;
  if Assigned(Node.Data) then
  begin
    Item := TPGItem(Node.Data);

    if (Item is TPGFolderMirror) and (TPGFolderMirror(Item)._Locked) then
        Sender.Canvas.Font.Style := Sender.Canvas.Font.Style + [fsItalic];

    if (not Item.isValid) then
    begin
       if Item.ReadOnly then
         Sender.Canvas.Font.Color := clWebLightSalmon
       else
        Sender.Canvas.Font.Color := clRed;
    end;
  end;
end;

procedure TFrmTriggerController.CreatePopups( );
var
  LPopUpItem, LSubPopUpItem, LNewPopUpItem: TMenuItem;
  LIndex, LClassLength: Integer;
begin
  inherited CreatePopups();

  LClassLength := FCollectItem.ClassList.Count;
  if LClassLength > 0 then
  begin
    BtnCreate.Visible := True;
    TrvController.DragMode := dmAutomatic;
    TrvController.DropFileAccept := True;
    for LIndex := 0 to LClassLength-1 do
    begin
      LPopUpItem := TMenuItem.Create( PpmCreate );
      PpmCreate.Items.Add( LPopUpItem );
      LPopUpItem.Caption := FCollectItem.ClassList[ LIndex ].Name;
      LPopUpItem.ImageIndex := TPGItemType(FCollectItem.ClassList[ LIndex ].ClassType).IconIndex;
      LPopUpItem.ShortCut := TextToShortCut( 'ALT+' + IntToStr( LIndex + 1 ) );
      LPopUpItem.Tag := LIndex;
      LPopUpItem.OnClick := onCreateItemPopUpClick;
    end;
  end;

  LPopUpItem := TMenuItem.Create( PpmConttroler );
  PpmConttroler.Items.Add( LPopUpItem );
  LPopUpItem.Caption := 'Create';
  for LSubPopUpItem in PpmCreate.Items do
  begin
    LNewPopUpItem := TMenuItem.Create( PpmConttroler );
    LPopUpItem.Add( LNewPopUpItem );
    LNewPopUpItem.Caption := LSubPopUpItem.Caption;
    LNewPopUpItem.ShortCut := LSubPopUpItem.ShortCut;
    LNewPopUpItem.Checked := LSubPopUpItem.Checked;
    LNewPopUpItem.OnClick := LSubPopUpItem.OnClick;
    LNewPopUpItem.Tag := LSubPopUpItem.Tag;
    LNewPopUpItem.ImageIndex := LSubPopUpItem.ImageIndex;
  end;

  LPopUpItem := TMenuItem.Create( PpmConttroler );
  PpmConttroler.Items.Add( LPopUpItem );
  LPopUpItem.Caption := MniDelete.Caption;
  LPopUpItem.ShortCut := MniDelete.ShortCut;
  LPopUpItem.Checked := MniDelete.Checked;
  LPopUpItem.OnClick := MniDelete.OnClick;
  LPopUpItem.Tag := MniDelete.Tag;
  LPopUpItem.ImageIndex := MniDelete.ImageIndex;
end;

procedure TFrmTriggerController.onCreateItemPopUpClick( Sender: TObject );
var
  LItemDad: TPGItem;
  LIndex: Integer;
  LClass: TClass;
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LValue: TValue;
begin
  LItemDad := Self.GetFolderWorking(TrvController.Selected);
  if not Assigned(LItemDad) then
    Exit;

  if ( Sender is TMenuItem ) then
  begin
    with TMenuItem( Sender ) do
    begin
      BtnCreate.Caption := Caption;
      BtnCreate.Tag := Tag;
    end;
  end;

  LIndex := TComponent( Sender ).Tag;
  LClass := FCollectItem.ClassList[ LIndex ].ClassType;
  LRttiContext := TRttiContext.Create( );
  LRttiType := LRttiContext.GetType( LClass );
  LValue := LRttiType.GetMethod( 'Create' ).Invoke( LClass, [ LItemDad, '' ] );
  TrvController.SuperSelected( TPGItem( LValue.AsObject ).Node );
  LRttiContext.Free;
end;

end.
