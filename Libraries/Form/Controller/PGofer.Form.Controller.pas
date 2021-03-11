unit PGofer.Form.Controller;

interface

uses
    System.Classes,
    Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
    Vcl.StdCtrls, Vcl.Menus,
    PGofer.Classes, PGofer.Forms, PGofer.Component.TreeView;

type
    TFrmController = class(TFormEx)
        PnlTreeView: TPanel;
        PnlFind: TPanel;
        PnlButton: TPanel;
        Splitter1: TSplitter;
        EdtFind: TButtonedEdit;
        PnlFrame: TPanel;
        TrvController: TTreeViewEx;
        btnAlphaSort: TButton;
        ppmAlphaSort: TPopupMenu;
        mniAZ: TMenuItem;
        mniZA: TMenuItem;
        mniAlphaSortFolder: TMenuItem;
        mniN1: TMenuItem;
        btnCreate: TButton;
        btnDelete: TButton;
        ppmCreate: TPopupMenu;
        constructor Create(ACollectItem: TPGItemCollect); reintroduce;
        destructor Destroy(); override;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormShow(Sender: TObject);
        procedure TrvControllerGetSelectedIndex(Sender: TObject;
          Node: TTreeNode);
        procedure TrvControllerDragOver(Sender, Source: TObject; X, Y: Integer;
          State: TDragState; var Accept: Boolean);
        procedure EdtFindKeyPress(Sender: TObject; var Key: Char);
        procedure TrvControllerCompare(Sender: TObject; Node1, Node2: TTreeNode;
          Data: Integer; var Compare: Integer);
        procedure TrvControllerDragDrop(Sender, Source: TObject; X, Y: Integer);
        procedure mniAZClick(Sender: TObject);
        procedure mniZAClick(Sender: TObject);
        procedure mniAlphaSortFolderClick(Sender: TObject);
        procedure onCreateItemPopUpClick(Sender: TObject);
        procedure btnDeleteClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
    private
        FAlphaSort: Boolean;
        FAlphaSortFolder: Boolean;
        procedure PanelCleaning();
        procedure CreatePopups();
    protected
        FCollectItem: TPGItemCollect;
        FSelectedItem: TPGItem;
        procedure IniConfigSave(); reintroduce;
        procedure IniConfigLoad(); reintroduce;
    public
    end;

implementation

{$R *.dfm}

uses
    System.RTTI, System.UITypes,
    WinApi.Windows,
    Vcl.Dialogs, PGofer.Sintatico.Classes;

constructor TFrmController.Create(ACollectItem: TPGItemCollect);
begin
    inherited Create(nil);
    FCollectItem := ACollectItem;
    FAlphaSort := True;
    FAlphaSortFolder := True;
    FSelectedItem := nil;
    Self.Name := 'Frm' + FCollectItem.Name;
    TPGForm.Create(Self);
    CreatePopups();
end;

destructor TFrmController.Destroy();
begin
    FSelectedItem := nil;
    FAlphaSort := False;
    FAlphaSortFolder := False;
    FCollectItem.UpdateToFile();
    FCollectItem.TreeViewDetach();
    FCollectItem := nil;
    inherited;
end;

procedure TFrmController.FormCreate(Sender: TObject);
begin
    inherited;
    //
end;

procedure TFrmController.FormShow(Sender: TObject);
begin
    inherited;
    FCollectItem.TreeViewAttach();
    TrvController.AlphaSort(True);
end;

procedure TFrmController.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    inherited;
    FCollectItem.UpdateToFile();
    FCollectItem.TreeViewDetach();
end;

procedure TFrmController.FormDestroy(Sender: TObject);
begin
    inherited;
    //
end;

procedure TFrmController.IniConfigLoad();
begin
    inherited;
    Self.PnlTreeView.Width := FIniFile.ReadInteger(Self.Name, 'TreeViewWidth',
      Self.TrvController.Width);
    Self.FAlphaSort := FIniFile.ReadBool(Self.Name, 'AlphaSort',
      Self.FAlphaSort);
    Self.FAlphaSortFolder := FIniFile.ReadBool(Self.Name, 'AlphaSortFolder',
      FAlphaSortFolder);
    Self.mniAlphaSortFolder.Checked := FAlphaSortFolder;
end;

procedure TFrmController.IniConfigSave();
begin
    inherited;
    FIniFile.WriteInteger(Self.Name, 'TreeViewWidth', Self.TrvController.Width);
    FIniFile.WriteBool(Self.Name, 'AlphaSort', Self.FAlphaSort);
    FIniFile.WriteBool(Self.Name, 'AlphaSortFolder', Self.FAlphaSortFolder);
    FIniFile.UpdateFile;
end;

procedure TFrmController.PanelCleaning();
var
    c: Integer;
begin
    for c := PnlFrame.ControlCount - 1 downto 0 do
    begin
        PnlFrame.Controls[c].Free();
    end;
    FSelectedItem := nil;
end;

procedure TFrmController.EdtFindKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #13 then
        TrvController.FindText(EdtFind.Text);
end;

procedure TFrmController.mniAlphaSortFolderClick(Sender: TObject);
begin
    FAlphaSortFolder := not FAlphaSortFolder;
    mniAlphaSortFolder.Checked := FAlphaSortFolder;
    TrvController.AlphaSort(True);
end;

procedure TFrmController.mniAZClick(Sender: TObject);
begin
    FAlphaSort := True;
    TrvController.AlphaSort(True);
    btnAlphaSort.OnClick := mniZAClick;
    btnAlphaSort.Caption := 'ZA';
end;

procedure TFrmController.mniZAClick(Sender: TObject);
begin
    FAlphaSort := False;
    TrvController.AlphaSort(True);
    btnAlphaSort.OnClick := mniAZClick;
    btnAlphaSort.Caption := 'AZ';
end;

procedure TFrmController.TrvControllerCompare(Sender: TObject;
  Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer);
var
    FolderNode1, FolderNode2: Boolean;
begin
    Compare := lstrcmp(PChar(Node1.Text), PChar(Node2.Text));

    if not FAlphaSort then
        Compare := Compare * -1;

    if FAlphaSortFolder then
    begin
        FolderNode1 := Assigned(Node1.Data) and
          (TPGItem(Node1.Data) is TPGFolder);
        FolderNode2 := Assigned(Node2.Data) and
          (TPGItem(Node2.Data) is TPGFolder);

        if FolderNode1 and (not FolderNode2) then
        begin
            Compare := -1;
        end;

        if (not FolderNode1) and (FolderNode2) then
        begin
            Compare := 1;
        end;
    end;
end;

procedure TFrmController.TrvControllerDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
    Node: TTreeNode;
    ItemDad: TPGItem;
begin
    if Assigned(TrvController.TargetDrag) then
        ItemDad := TPGItem(TrvController.TargetDrag.Data)
    else
        ItemDad := FCollectItem;

    for Node in TrvController.SelectionsDrag do
    begin
        if Assigned(Node.Data) and (TPGItem(Node.Data) is TPGItem) then
        begin
            TPGItem(Node.Data).Parent := ItemDad;
        end;
    end;
end;

procedure TFrmController.TrvControllerDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
    Accept := Sender = Source;
    if Accept then
    begin
        if Assigned(TrvController.TargetDrag) and
          Assigned(TrvController.TargetDrag.Data) and
          (TPGItem(TrvController.TargetDrag.Data) is TPGFolder) then
        begin
            Accept := True;
            TrvController.AttachMode := naInsert;
        end;

        if not Assigned(TrvController.TargetDrag) then
        begin
            Accept := True;
            TrvController.AttachMode := naAdd;
        end;
    end;
end;

procedure TFrmController.TrvControllerGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
    if TrvController.isSelectWork then
    begin
        if Assigned(TrvController.Selected) and
          (TPGItem(TrvController.Selected.Data) is TPGItem) and
          (TPGItem(TrvController.Selected.Data) <> FSelectedItem) then
        begin
            Self.PanelCleaning();
            FSelectedItem := TPGItem(TrvController.Selected.Data);
            FSelectedItem.Frame(PnlFrame);
            PnlFrame.Caption := '';
        end;
    end
    else
    begin
        Self.PanelCleaning();
        PnlFrame.Caption := 'Nenhum item selecionado!';
    end;
    PnlFrame.Update;
    PnlFrame.Refresh;
end;

procedure TFrmController.CreatePopups();
var
    PopUpItem: TMenuItem;
    c, l: Integer;
begin
    l := FCollectItem.RegClassList.Count - 1;
    if l > 0 then
    begin
        btnCreate.Visible := True;
        btnDelete.Visible := True;
        for c := 0 to l do
        begin
            PopUpItem := TMenuItem.Create(ppmCreate);
            ppmCreate.Items.Add(PopUpItem);
            PopUpItem.Caption := FCollectItem.RegClassList.GetNameIndex(c);
            PopUpItem.Tag := c;
            PopUpItem.OnClick := onCreateItemPopUpClick;
        end;
    end;
end;

procedure TFrmController.onCreateItemPopUpClick(Sender: TObject);
var
    IClass: TClass;
    IName: String;
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    Value: TValue;
begin
    IClass := FCollectItem.RegClassList.GetClassIndex(TComponent(Sender).Tag);
    IName := FCollectItem.RegClassList.GetNameIndex(TComponent(Sender).Tag);

    if not Assigned(FSelectedItem) then
    begin
        FSelectedItem := FCollectItem;
    end
    else
    begin
        if (not(FSelectedItem is TPGFolder)) then
        begin
            FSelectedItem := FSelectedItem.Parent;
        end;
    end;

    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(IClass);
    Value := RttiType.GetMethod('Create')
      .Invoke(IClass, [FSelectedItem, IName]);
    TrvController.SuperSelected(TPGItem(Value.AsObject).Node);
end;

procedure TFrmController.btnDeleteClick(Sender: TObject);
begin
    if Vcl.Dialogs.MessageDlg('Excluir os itens selecionados?', mtConfirmation,
      [mbYes, mbNo], 0, mbNo) = mrYes then
    begin
        TrvController.DeleteSelect();
    end;
end;

end.
