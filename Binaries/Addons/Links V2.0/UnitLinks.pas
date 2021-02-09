unit UnitLinks;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.ImageList, System.Classes,
  Vcl.Forms, Vcl.ImgList, Vcl.Controls, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  SynEdit;

type
  TFrmLinks = class(TForm)
    ImlButton: TImageList;
    PnlList: TPanel;
    BtnAddItem: TButton;
    BtnDelItem: TButton;
    BtnSort: TButton;
    BtnAddFolder: TButton;
    TrvList: TTreeView;
    PnlVisible: TPanel;
    PnlItem: TPanel;
    PnlHotKey: TPanel;
    PnlTitulo: TPanel;
    LblTitulo: TLabel;
    EdtTitulo: TEdit;
    SplList: TSplitter;
    LblArquivo: TLabel;
    EdtArquivo: TEdit;
    BtnArquivo: TButton;
    LblParametro: TLabel;
    EdtParametro: TEdit;
    LblDiretorio: TLabel;
    EdtDiretorio: TEdit;
    BtnDiretorio: TButton;
    LblIcone: TLabel;
    EdtIcone: TEdit;
    BtnIcone: TButton;
    EdtIconeIndex: TEdit;
    CmbEstado: TComboBox;
    CmbPrioridade: TComboBox;
    LblEstado: TLabel;
    LblPrioridade: TLabel;
    OpdLinks: TOpenDialog;
    BtnTest: TButton;
    procedure BtnAddFolderClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure BtnAddItemClick(Sender: TObject);
    procedure BtnDelItemClick(Sender: TObject);
    procedure BtnSortClick(Sender: TObject);
    procedure EdtTituloChange(Sender: TObject);
    procedure EdtArquivoChange(Sender: TObject);
    procedure EdtParametroChange(Sender: TObject);
    procedure EdtIconeChange(Sender: TObject);
    procedure EdtIconeIndexChange(Sender: TObject);
    procedure CmbEstadoClick(Sender: TObject);
    procedure CmbPrioridadeClick(Sender: TObject);
    procedure BtnArquivoClick(Sender: TObject);
    procedure BtnIconeClick(Sender: TObject);
    procedure BtnDiretorioClick(Sender: TObject);
    procedure EdtDiretorioChange(Sender: TObject);
    procedure BtnTestClick(Sender: TObject);
    procedure TrvListCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure TrvListGetSelectedIndex(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
  end;

var
  FrmLinks: TFrmLinks;

implementation

uses
   PGofer.Controls, PGofer.Links, PGofer.TreeView, PGofer.Files;

{$R *.dfm}

procedure TFrmLinks.BtnAddFolderClick(Sender: TObject);
begin
    TrvList.FolderCreate();
end;

procedure TFrmLinks.BtnAddItemClick(Sender: TObject);
begin
    TrvList.ItemCreate<TLink>();
end;

procedure TFrmLinks.BtnArquivoClick(Sender: TObject);
begin
    OpdLinks.Title := 'Arquivo';
    OpdLinks.Filter := 'Todos Arquivos(*.*)|*.*';
    OpdLinks.InitialDir := FileLimitPathExist( EdtArquivo.Text );
    OpdLinks.FileName := ExtractFileName( EdtArquivo.Text );

    if OpdLinks.Execute then
    begin
        EdtArquivo.Text:= FileUnExpandPath(OpdLinks.FileName);
        FrmLinks.EdtArquivo.OnChange(nil);
        EdtDiretorio.Text := FileUnExpandPath(ExtractFilePath(OpdLinks.FileName));
        EdtIcone.Text := EdtArquivo.Text;
    end;
end;

procedure TFrmLinks.BtnDelItemClick(Sender: TObject);
begin
    TrvList.SelectDelete();
end;

procedure TFrmLinks.BtnDiretorioClick(Sender: TObject);
begin
    EdtDiretorio.Text := FileDirDialog(EdtDiretorio.Text);
end;

procedure TFrmLinks.BtnIconeClick(Sender: TObject);
begin
    OpdLinks.Title := 'Icone';
    OpdLinks.Filter := 'Todos Icones(*.jpg;*.bmp;*.ico;*.exe;*.dll)|*.jpg;*.bmp;*.ico;*.exe;*.dll|Todos Arquivos(*.*)|*.*';
    OpdLinks.InitialDir := FileLimitPathExist( EdtIcone.Text );
    OpdLinks.FileName := ExtractFileName( EdtIcone.Text );
    if OpdLinks.Execute then
       EdtIcone.Text:= FileUnExpandPath(OpdLinks.FileName);
end;

procedure TFrmLinks.BtnSortClick(Sender: TObject);
begin
    TrvList.SelectSort();
end;

procedure TFrmLinks.BtnTestClick(Sender: TObject);
begin
    if TrvList.isSelectWork then
       TLink(TrvList.Selected.Data).Execute;
end;

procedure TFrmLinks.CmbEstadoClick(Sender: TObject);
begin
    if TrvList.isSelectWork then
       TLink(TrvList.Selected.Data).Estado := CmbEstado.ItemIndex;
end;

procedure TFrmLinks.CmbPrioridadeClick(Sender: TObject);
begin
    if TrvList.isSelectWork then
       TLink(TrvList.Selected.Data).Prioridade := CmbPrioridade.ItemIndex;
end;

procedure TFrmLinks.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited CreateWindowHandle(Params);
    //configura a janela para não aparecer na barra e não ativado.
    SetWindowLong(Handle, gwl_exstyle, ws_ex_toolwindow and not Ws_ex_appwindow);
end;

procedure TFrmLinks.EdtArquivoChange(Sender: TObject);
begin
    if TrvList.isSelectWork then
    begin
        TLink(TrvList.Selected.Data).Arquivo := EdtArquivo.Text;

        if not TLink(TrvList.Selected.Data).isFileExist then
        begin
            LblArquivo.Font.Color := 255;
            EdtArquivo.Font.Color := 255;
        end else begin
            LblArquivo.ParentFont := True;
            EdtArquivo.ParentFont := True;
        end;

    end;
end;

procedure TFrmLinks.EdtDiretorioChange(Sender: TObject);
begin
    if TrvList.isSelectWork then
    begin
        TLink(TrvList.Selected.Data).Diretorio := EdtDiretorio.Text;

        if not TLink(TrvList.Selected.Data).isDirExist then
        begin
            LblDiretorio.Font.Color := 255;
            EdtDiretorio.Font.Color := 255;
        end else begin
            LblDiretorio.ParentFont := True;
            EdtDiretorio.ParentFont := True;
        end;
    end;
end;

procedure TFrmLinks.EdtIconeChange(Sender: TObject);
begin
    if TrvList.isSelectWork then
    begin
        TLink(TrvList.Selected.Data).Icone := EdtIcone.Text;

        if not TLink(TrvList.Selected.Data).isIcoExist then
        begin
            LblIcone.Font.Color := 255;
            EdtIcone.Font.Color := 255;
        end else begin
            LblIcone.ParentFont := True;
            EdtIcone.ParentFont := True;
        end;
    end;
end;

procedure TFrmLinks.EdtIconeIndexChange(Sender: TObject);
begin
    if TrvList.isSelectWork and (EdtIconeIndex.Text <> '') then
       TLink(TrvList.Selected.Data).IconeIndex := StrToInt(EdtIconeIndex.Text);
end;

procedure TFrmLinks.EdtParametroChange(Sender: TObject);
begin
    if TrvList.isSelectWork then
       TLink(TrvList.Selected.Data).Parametro := EdtParametro.Text;
end;

procedure TFrmLinks.EdtTituloChange(Sender: TObject);
begin
    if TrvList.isSelectWork then
    begin
        TLink(TrvList.Selected.Data).Titulo := EdtTitulo.Text;
        TrvList.Selected.Text := EdtTitulo.Text;
    end;
end;

procedure TFrmLinks.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    IniSaveToFile(Self, DirCurrent+'Config.ini');
    TrvList.XMLSaveToFile<TLink>(DirCurrent+'Links.xml', 'PGofer_Links');
end;

procedure TFrmLinks.FormCreate(Sender: TObject);
begin
    TrvList.SetOnprocedHelpers;
    IniLoadFromFile(Self, DirCurrent+'Config.ini');

    if FileExists(DirCurrent+'Links.xml') then
       TrvList.XMLLoadFromFile<TLink>(DirCurrent+'Links.xml', 'PGofer_Links');
end;

procedure TFrmLinks.TrvListCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
    if  Assigned(Node) and (Node.ImageIndex > 0)
    and Assigned(Node.Data) and (not TLink(Node.Data).isFileExist) then
        Sender.Canvas.Font.Color := 255;
end;

procedure TFrmLinks.TrvListGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
    if TrvList.isSelectWork then
    begin
        PnlItem.Visible := True;
        if (TrvList.Selected.ImageIndex > 0) then
        begin
            PnlHotKey.Visible := True;
            with TLink(TrvList.Selected.Data) do
            begin
                EdtTitulo.Text := Titulo;
                EdtArquivo.Text := Arquivo;
                EdtArquivo.OnChange(nil);
                EdtParametro.Text := Parametro;
                EdtDiretorio.Text := Diretorio;
                EdtDiretorio.OnChange(nil);
                EdtIcone.Text := Icone;
                EdtIcone.OnChange(nil);
                EdtIconeIndex.Text := IconeIndex.ToString;
                CmbEstado.ItemIndex := Estado;
                CmbPrioridade.ItemIndex := Prioridade;
            end;
        end else begin
            PnlHotKey.Visible := False;
            EdtTitulo.Text := TTreeNodeFolder(TrvList.Selected.Data).Titulo;
        end;
    end else
        PnlItem.Visible := False;
end;

procedure TFrmLinks.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;


end.
