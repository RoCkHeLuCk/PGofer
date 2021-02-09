unit UnitAutoRuns;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.ImageList, System.Classes,
  Vcl.Forms, Vcl.ImgList, Vcl.Controls, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  SynEdit;

type
  TFrmAutoRuns = class(TForm)
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
    EdtComandos: TSynEdit;
    BtnEnableDisable: TButton;
    procedure BtnAddFolderClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure BtnAddItemClick(Sender: TObject);
    procedure BtnDelItemClick(Sender: TObject);
    procedure BtnSortClick(Sender: TObject);
    procedure TrvListGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure EdtTituloChange(Sender: TObject);
    procedure EdtComandosChange(Sender: TObject);
    procedure BtnEnableDisableClick(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
  end;

var
  FrmAutoRuns: TFrmAutoRuns;

implementation

uses
   PGofer.Controls, PGofer.AutoRuns, PGofer.TreeView, PGofer.Files;

{$R *.dfm}

procedure TFrmAutoRuns.BtnAddFolderClick(Sender: TObject);
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

procedure TFrmAutoRuns.BtnAddItemClick(Sender: TObject);
var
    TreeNode : TTreeNode;
    AutoRuns : TAutoRuns;
begin
    TreeNode := TrvList.AddTreeNode(TrvList.Selected,1);
    TreeNode.Selected := True;
    TreeNode.Focused := True;
    AutoRuns := TAutoRuns.Create;
    TreeNode.Data := AutoRuns;
    TrvList.OnAddition(nil,TreeNode);

    if Assigned(TrvList.Selected) then
       TrvList.Selected.Expand(True);
end;

procedure TFrmAutoRuns.BtnDelItemClick(Sender: TObject);
begin
    TrvList.DeleteSelect();
end;

procedure TFrmAutoRuns.BtnEnableDisableClick(Sender: TObject);
var
    c : Cardinal;
begin
    if Assigned(TrvList.Selected) then
    begin
        for c := 0 to TrvList.SelectionCount-1 do
        begin
            if (TrvList.Selections[c].ImageIndex = 1) then
            begin
                TrvList.Selections[c].Enabled := not TrvList.Selections[c].Enabled;
                if Assigned(TrvList.Selections[c].Data) then
                   TAutoRuns(TrvList.Selections[c].Data).Enabled := TrvList.Selections[c].Enabled;
            end;
        end;
    end;
end;

procedure TFrmAutoRuns.BtnSortClick(Sender: TObject);
begin
    if Assigned(TrvList.Selected) then
       TrvList.Selected.AlphaSort
    else
       TrvList.AlphaSort;
end;

procedure TFrmAutoRuns.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited CreateWindowHandle(Params);
    //configura a janela para não aparecer na barra e não ativado.
    SetWindowLong(Handle, gwl_exstyle, ws_ex_toolwindow and not Ws_ex_appwindow);
end;

procedure TFrmAutoRuns.EdtComandosChange(Sender: TObject);
begin
    if TrvList.isSelectWork then
       TAutoRuns(TrvList.Selected.Data).Comandos := EdtComandos.Text;
end;

procedure TFrmAutoRuns.EdtTituloChange(Sender: TObject);
begin
    if TrvList.isSelectWork then
    begin
        with EdtTitulo do
        begin
            TrvList.Selected.Text := Text;
            TTreeNodeFolder(TrvList.Selected.Data).Titulo := Text;
        end;
    end;
end;

procedure TFrmAutoRuns.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    IniSaveToFile(Self, DirCurrent+'Config.ini');
    //Action := caNone;
    //Hide;
    TrvList.XMLSaveToFile<TAutoRuns>(DirCurrent+'Functions.xml', 'PGofer_Functions');
end;

procedure TFrmAutoRuns.FormCreate(Sender: TObject);
begin
    TrvList.SetOnprocedHelpers;
    IniLoadFromFile(Self, DirCurrent+'Config.ini');

    if FileExists(DirCurrent+'Functions.xml') then
       TrvList.XMLLoadFromFile<TAutoRuns>(DirCurrent+'Functions.xml', 'PGofer_Functions');
end;

procedure TFrmAutoRuns.TrvListGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
    if TrvList.isSelectWork then
    begin
        PnlItem.Visible := True;
        if (TrvList.Selected.ImageIndex > 0) then
        begin
            PnlFunctions.Visible := True;
            with TAutoRuns(TrvList.Selected.Data) do
            begin
                EdtTitulo.Text := Titulo;
                EdtComandos.Text := Comandos;
            end;
        end else begin
            PnlFunctions.Visible := False;
            EdtTitulo.Text := TTreeNodeFolder(TrvList.Selected.Data).Titulo;
        end;
    end else
        PnlItem.Visible := False;
end;

procedure TFrmAutoRuns.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;


end.
