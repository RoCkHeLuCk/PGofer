unit PGofer.Form.Controller;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, Winapi.CommCtrl,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
    Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Menus,
    PGofer.Classes, PGofer.Component.ListView, PGofer.Component.TreeView;

type
    TFrmController = class(TForm)
        PnlTreeView: TPanel;
        PnlFind: TPanel;
        PnlButton: TPanel;
        Splitter1: TSplitter;
        EdtFind: TButtonedEdit;
        PnlFrame: TPanel;
        TrvController: TTreeViewEx;
        Button1: TButton;
        procedure FormCreate(Sender: TObject);
        procedure TrvControllerGetSelectedIndex(Sender: TObject;
            Node: TTreeNode);
        procedure TrvControllerDragOver(Sender, Source: TObject; X, Y: Integer;
            State: TDragState; var Accept: Boolean);
        procedure EdtFindKeyPress(Sender: TObject; var Key: Char);
    private
        { Private declarations }
        SelectItem: TPGItem;
        procedure NodeCreate(Item: TPGItem);
        procedure NodeNotify(Sender: TPGItem; Action: TPGItemNotification);
    public
        { Public declarations }
    end;

var
    FrmController: TFrmController;

implementation

{$R *.dfm}

uses
    PGofer.Forms, PGofer.Sintatico.Classes, PGofer.Sintatico, PGofer.HotKey;

procedure TFrmController.FormCreate(Sender: TObject);
begin
    Self.NodeCreate(TGramatica.Global);
    TPGItem.OnItemNotify := Self.NodeNotify;
end;

procedure TFrmController.NodeCreate(Item: TPGItem);
var
    Node: TTreeNode;
    c: FixedInt;
begin
    if Assigned(Item) then
    begin
        if Assigned(Item.Dad) then
            Node := TTreeNode(Item.Dad.Node)
        else
            Node := nil;
        Item.Node := TrvController.Items.AddChild(Node, Item.Name);
        TTreeNode(Item.Node).Data := Item;
        for c := 0 to Item.Count - 1 do
            NodeCreate(Item[c]);
    end;
end;

procedure TFrmController.NodeNotify(Sender: TPGItem; Action: TPGItemNotification);
var
    Node: TTreeNode;
begin
    case Action of
        cmCreate:
        begin
            if Assigned(Sender.Dad) then
                Node := TTreeNode(Sender.Dad.Node)
            else
                Node := nil;
            Sender.Node := TrvController.Items.AddChild(Node, Sender.Name);
            TTreeNode(Sender.Node).Data := Sender;
        end;

        cmDestroy:
        begin
            TTreeNode(Sender.Node).Delete;
            Sender.Node := nil;
        end;

        cmEdit:
        begin
            TTreeNode(Sender.Node).Text := Sender.Name;
            TTreeNode(Sender.Node).Enabled := Sender.Enabled;
        end;

        cmMove:
        begin
            if Assigned(Sender.Dad) then
                Node := TTreeNode(Sender.Dad.Node)
            else
                Node := nil;

            TTreeNode(Sender.Node).MoveTo(Node, naAddChild);
        end;

    end;
end;

procedure TFrmController.EdtFindKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #13 then
        TrvController.FindText(EdtFind.Text);
end;

procedure TFrmController.TrvControllerDragOver(Sender, Source: TObject;
    X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
    Accept := (Sender = Source);
end;

procedure TFrmController.TrvControllerGetSelectedIndex(Sender: TObject;
    Node: TTreeNode);
begin
    if TrvController.isSelectWork then
    begin
        if Assigned(TrvController.Selected) and
            (SelectItem <> TPGItem(TrvController.Selected.Data)) then
        begin
            TPGItem(TrvController.Selected.Data).Frame(PnlFrame);
            SelectItem := TPGItem(TrvController.Selected.Data);
            PnlFrame.Caption := '';
        end;
    end
    else
    begin
        if PnlFrame.ControlCount > 0 then
        begin
            PnlFrame.Controls[0].Free;
            PnlFrame.Update;
        end;
        PnlFrame.Caption := 'Nenhum item selecionado!';
    end;
end;

end.
