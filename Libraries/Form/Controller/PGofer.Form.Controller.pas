unit PGofer.Form.Controller;

interface

uses
    System.Classes, System.IniFiles,
    Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
    Vcl.StdCtrls, Vcl.Menus,
    PGofer.Classes, PGofer.Component.TreeView;

type
    TFrmController = class(TForm)
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
        constructor Create(ACollectItem: TPGItemCollect); reintroduce;
        destructor Destroy(); override;
        procedure TrvControllerGetSelectedIndex(Sender: TObject;
            Node: TTreeNode);
        procedure TrvControllerDragOver(Sender, Source: TObject; X, Y: Integer;
            State: TDragState; var Accept: Boolean);
        procedure EdtFindKeyPress(Sender: TObject; var Key: Char);
        procedure TrvControllerCompare(Sender: TObject; Node1, Node2: TTreeNode;
            Data: Integer; var Compare: Integer);
        procedure TrvControllerDragDrop(Sender, Source: TObject; X, Y: Integer);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure mniAZClick(Sender: TObject);
        procedure mniZAClick(Sender: TObject);
        procedure mniAlphaSortFolderClick(Sender: TObject);
    private
        FIniFile: TIniFile;
        FAlphaSort: Boolean;
        FAlphaSortFolder: Boolean;
        procedure PanelCleaning();
    protected
        FCollectItem: TPGItemCollect;
        FSelectedItem: TPGItem;
        FItemForm: TPGItem;
        procedure IniConfigSave(); virtual;
        procedure IniConfigLoad(); virtual;
    public
    end;

implementation

{$R *.dfm}

uses
    WinApi.Windows,
    PGofer.Sintatico.Classes, PGofer.Sintatico,
    PGofer.Forms, PGofer.Forms.Controls;

constructor TFrmController.Create(ACollectItem: TPGItemCollect);
begin
    inherited Create(nil);
    FIniFile := TIniFile.Create(PGofer.Sintatico.IniConfigFile);
    FCollectItem := ACollectItem;
    FCollectItem.TreeViewCreate(TrvController);
    FAlphaSort := True;
    FAlphaSortFolder := True;
    FSelectedItem := nil;
    Self.Name := 'Frm'+FCollectItem.Name;
    FItemForm := TPGForm.Create(Self);
    IniConfigLoad();
    TrvController.AlphaSort(True);
end;

destructor TFrmController.Destroy();
begin
    IniConfigSave();
    FIniFile.Free;
    FCollectItem.TreeViewDestroy();
    FAlphaSort := False;
    FAlphaSortFolder := False;
    FSelectedItem := nil;
    FItemForm.Free;
    FItemForm := nil;
    inherited Destroy();
end;

procedure TFrmController.PanelCleaning();
var
    c: Integer;
begin
    for c := PnlFrame.ControlCount - 1 downto 0 do
    begin
        PnlFrame.Controls[c].Free;
    end;
    FSelectedItem := nil;
end;

procedure TFrmController.EdtFindKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #13 then
        TrvController.FindText(EdtFind.Text);
end;

procedure TFrmController.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    IniConfigSave();
end;

procedure TFrmController.IniConfigLoad();
begin
    Self.Left := FIniFile.ReadInteger(Self.Name, 'Left', Self.Left);
    Self.Top := FIniFile.ReadInteger(Self.Name, 'Top', Self.Top);
    Self.Width := FIniFile.ReadInteger(Self.Name, 'Width', Self.Width);
    Self.Height := FIniFile.ReadInteger(Self.Name, 'Height', Self.Height);
    Self.PnlTreeView.Width :=
        FIniFile.ReadInteger(Self.Name,'TreeViewWidth',
                             Self.TrvController.Width);
    Self.FAlphaSort :=
        FIniFile.ReadBool(Self.Name,'AlphaSort',Self.FAlphaSort);
    Self.FAlphaSortFolder :=
        FIniFile.ReadBool(Self.Name,'AlphaSortFolder', FAlphaSortFolder);
    Self.mniAlphaSortFolder.Checked := FAlphaSortFolder;
    FormPositionFixed(Self);
    if FIniFile.ReadBool(Self.Name, 'Maximized', False) then
        Self.WindowState := wsMaximized;
end;

procedure TFrmController.IniConfigSave();
begin
    FormPositionFixed(Self);
    if Self.WindowState <> wsMaximized then
    begin
        FIniFile.WriteInteger(Self.Name, 'Left', Self.Left);
        FIniFile.WriteInteger(Self.Name, 'Top', Self.Top);
        FIniFile.WriteInteger(Self.Name, 'Width', Self.Width);
        FIniFile.WriteInteger(Self.Name, 'Height', Self.Height);
        FIniFile.WriteBool(Self.Name, 'Maximized', False);
    end
    else
        FIniFile.WriteBool(Self.Name, 'Maximized', True);

    FIniFile.WriteInteger(Self.Name,'TreeViewWidth',Self.TrvController.Width);
    FIniFile.WriteBool(Self.Name,'AlphaSort',Self.FAlphaSort);
    FIniFile.WriteBool(Self.Name,'AlphaSortFolder', Self.FAlphaSortFolder);

    FIniFile.UpdateFile;
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

end.
