unit UnitAutoKeys;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.ImageList, System.Classes,
  Vcl.Forms, Vcl.ImgList, Vcl.Controls, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  SynEdit;

type
  TFrmAutoKeys = class(TForm)
    ImlButton: TImageList;
    PnlList: TPanel;
    BtnAddItem: TButton;
    BtnDelItem: TButton;
    BtnSort: TButton;
    BtnAddFolder: TButton;
    TrvList: TTreeView;
    PnlVisible: TPanel;
    PnlItem: TPanel;
    PnlFunctions: TPanel;
    PnlTitulo: TPanel;
    LblTitulo: TLabel;
    EdtTitulo: TEdit;
    SplList: TSplitter;
    procedure BtnAddFolderClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure BtnAddItemClick(Sender: TObject);
    procedure BtnDelItemClick(Sender: TObject);
    procedure BtnSortClick(Sender: TObject);
    procedure TrvListGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure EdtTituloChange(Sender: TObject);
  private
    { Private declarations }
    function isSelectWork():Boolean;
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
  end;

var
  FrmAutoKeys: TFrmAutoKeys;

implementation

uses
   PGofer.Controls, PGofer.AutoKeys, PGofer.TreeView, PGofer.Files;

{$R *.dfm}

procedure TFrmAutoKeys.BtnAddFolderClick(Sender: TObject);
var
    TreeNode : TTreeNode;
    Folder : TTreeNodeFolder;
begin
    TreeNode := TrvList.AddTreeNode(TrvList.Selected,0);
    TreeNode.Selected := True;
    TreeNode.Focused := True;
    Folder := TTreeNodeFolder.Create;
    TreeNode.Data := Folder;
    TrvList.OnAddition(nil,TreeNode);

    if Assigned(TrvList.Selected) then
       TrvList.Selected.Expand(True);
end;

procedure TFrmAutoKeys.BtnAddItemClick(Sender: TObject);
var
    TreeNode : TTreeNode;
    AutoKeys : TAutoKeys;
begin
    TreeNode := TrvList.AddTreeNode(TrvList.Selected,1);
    TreeNode.Selected := True;
    TreeNode.Focused := True;
    AutoKeys := TAutoKeys.Create;
    TreeNode.Data := AutoKeys;
    TrvList.OnAddition(nil,TreeNode);

    if Assigned(TrvList.Selected) then
       TrvList.Selected.Expand(True);
end;

procedure TFrmAutoKeys.BtnDelItemClick(Sender: TObject);
begin
    TrvList.DeleteSelect();
    TrvList.OnGetSelectedIndex(nil,TrvList.Selected);
end;

procedure TFrmAutoKeys.BtnSortClick(Sender: TObject);
begin
    if Assigned(TrvList.Selected) then
       TrvList.Selected.AlphaSort
    else
       TrvList.AlphaSort;
end;

procedure TFrmAutoKeys.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited CreateWindowHandle(Params);
    //configura a janela para não aparecer na barra e não ativado.
    SetWindowLong(Handle, gwl_exstyle, ws_ex_toolwindow and not Ws_ex_appwindow);
end;

procedure TFrmAutoKeys.EdtTituloChange(Sender: TObject);
begin
    if isSelectWork then
    begin
        with EdtTitulo do
        begin
            TrvList.Selected.Text := Text;
            TTreeNodeFolder(TrvList.Selected.Data).Titulo := Text;
        end;
    end;
end;

procedure TFrmAutoKeys.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    IniSaveToFile(Self, DirCurrent+'Config.ini');
    //Action := caNone;
    //Hide;
    TrvList.XMLSaveToFile<TAutoKeys>(DirCurrent+'Functions.xml', 'PGofer_Functions');
end;

procedure TFrmAutoKeys.FormCreate(Sender: TObject);
begin
    TrvList.SetOnprocedHelpers;
    IniLoadFromFile(Self, DirCurrent+'Config.ini');

    if FileExists(DirCurrent+'Functions.xml') then
       TrvList.XMLLoadFromFile<TAutoKeys>(DirCurrent+'Functions.xml', 'PGofer_Functions');
end;

function TFrmAutoKeys.isSelectWork: Boolean;
begin
    Result := (Assigned(TrvList.Selected) and Assigned(TrvList.Selected.Data));
end;

procedure TFrmAutoKeys.TrvListGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
    if isSelectWork then
    begin
        PnlItem.Visible := True;
        if (TrvList.Selected.ImageIndex > 0) then
        begin
            PnlFunctions.Visible := True;
            with TAutoKeys(TrvList.Selected.Data) do
            begin
                EdtTitulo.Text := Titulo;
            end;
        end else begin
            PnlFunctions.Visible := False;
            EdtTitulo.Text := TTreeNodeFolder(TrvList.Selected.Data).Titulo;
        end;
    end else
        PnlItem.Visible := False;
end;

procedure TFrmAutoKeys.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;


end.
