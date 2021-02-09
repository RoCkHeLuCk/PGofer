unit UnitHotKeys;

interface

uses
   Vcl.Forms, Vcl.ImgList, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
   Winapi.Windows, Winapi.Messages,
   System.SysUtils, System.Classes, System.ImageList,
   SynEdit,
   PGofer.Controls, PGofer.TreeView, PGofer.HotKey;

type
 TFrmHotKeys = class(TForm)
    PnlList: TPanel;
    SplList: TSplitter;
    BtnAddItem: TButton;
    BtnDelItem: TButton;
    ImlButton: TImageList;
    BtnSort: TButton;
    TrvList: TTreeView;
    PnlVisible: TPanel;
    PnlItem: TPanel;
    PnlHotKey: TPanel;
    LblDetectar: TLabel;
    GrbTeclas: TGroupBox;
    BtnTeclas: TButton;
    GrbScript: TGroupBox;
    EdtScript: TSynEdit;
    CmbDetectar: TComboBox;
    CkbInibir: TCheckBox;
    PnlTitulo: TPanel;
    LblTitulo: TLabel;
    EdtTitulo: TEdit;
    BtnEnableDisable: TButton;
    procedure BtnTeclasClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EdtTituloChange(Sender: TObject);
    procedure CkbInibirClick(Sender: TObject);
    procedure CmbDetectarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnAddFolderClick(Sender: TObject);
    procedure BtnAddItemClick(Sender: TObject);
    procedure BtnDelItemClick(Sender: TObject);
    procedure BtnSortClick(Sender: TObject);
    procedure TrvListGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure EdtScriptChange(Sender: TObject);
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
   FrmHotKeys: TFrmHotKeys;

implementation

{$R *.dfm}

uses UnitDetectar;


procedure TFrmHotKeys.BtnAddFolderClick(Sender: TObject);
begin
    TrvList.FolderCreate();
end;

procedure TFrmHotKeys.BtnAddItemClick(Sender: TObject);
begin
    TrvList.ItemCreate<TPGHotKey>();
end;

procedure TFrmHotKeys.BtnDelItemClick(Sender: TObject);
begin
    TrvList.DeleteSelect();
end;

procedure TFrmHotKeys.BtnEnableDisableClick(Sender: TObject);
begin
    TrvList.SelectEnabDisab();
end;

procedure TFrmHotKeys.BtnSortClick(Sender: TObject);
begin
    if Assigned(TrvList.Selected) then
       TrvList.Selected.AlphaSort
    else
       TrvList.AlphaSort;
end;

procedure TFrmHotKeys.BtnTeclasClick(Sender: TObject);
begin
    if Assigned(TrvList.Selected) and Assigned(TrvList.Selected.Data) then
    begin
        TPGHotKey.DisableHoot;
        FrmDetectar := TFrmDetectar.Create(Application.MainForm);
        FrmDetectar.HotKey := TPGHotKey(TrvList.Selected.Data);
        FrmDetectar.LblDetectar.Caption := TPGHotKey(TrvList.Selected.Data).GetHotKeyNames;
        FrmDetectar.ShowModal;
        BtnTeclas.Caption := TPGHotKey(TrvList.Selected.Data).GetHotKeyNames;
        TPGHotKey.EnableHoot;
    end;
end;

procedure TFrmHotKeys.CkbInibirClick(Sender: TObject);
begin
    if Assigned(TrvList.Selected) and Assigned(TrvList.Selected.Data) then
       TPGHotKey(TrvList.Selected.Data).Inibir := CkbInibir.Checked;
end;

procedure TFrmHotKeys.CmbDetectarClick(Sender: TObject);
begin
    if Assigned(TrvList.Selected) and Assigned(TrvList.Selected.Data) then
       TPGHotKey(TrvList.Selected.Data).Detectar := CmbDetectar.ItemIndex;
end;

procedure TFrmHotKeys.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited CreateWindowHandle(Params);
    //configura a janela para não aparecer na barra e não ativado.
    SetWindowLong(Handle, gwl_exstyle, ws_ex_toolwindow and not Ws_ex_appwindow);
end;

procedure TFrmHotKeys.EdtScriptChange(Sender: TObject);
begin
    if Assigned(TrvList.Selected) and Assigned(TrvList.Selected.Data) then
       TPGHotKey(TrvList.Selected.Data).Script := EdtScript.Text;
end;

procedure TFrmHotKeys.EdtTituloChange(Sender: TObject);
begin
    if Assigned(TrvList.Selected) and Assigned(TrvList.Selected.Data) then
    begin
        with EdtTitulo do
        begin
            TrvList.Selected.Text := Text;
            TTreeNodeFolder(TrvList.Selected.Data).Titulo := Text;
        end;
    end;
end;

procedure TFrmHotKeys.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    IniSaveToFile(Self, DirCurrent+'Config.ini');
    //Action := caNone;
    //Hide;
    TrvList.XMLSaveToFile<TPGHotKey>(DirCurrent+'HotKey.xml', 'PGofer_HotKeys');
end;

procedure TFrmHotKeys.FormCreate(Sender: TObject);
begin
    TrvList.SetOnprocedHelpers;

    IniLoadFromFile(Self, DirCurrent+'Config.ini');

    if FileExists(DirCurrent+'HotKey.xml') then
       TrvList.XMLLoadFromFile<TPGHotKey>(DirCurrent+'HotKey.xml', 'PGofer_HotKeys');
end;

procedure TFrmHotKeys.TrvListGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
    if Assigned(TrvList.Selected) and Assigned(TrvList.Selected.Data) then
    begin
        PnlItem.Visible := True;
        if (TrvList.Selected.ImageIndex = 1) then
        begin
            PnlHotKey.Visible := True;
            with TPGHotKey(TrvList.Selected.Data) do
            begin
                EdtTitulo.Text := Titulo;
                BtnTeclas.Caption := GetHotKeyNames;
                CmbDetectar.ItemIndex := integer(Detectar);
                CkbInibir.Checked := Inibir;
                EdtScript.Text := Script;
                CmbDetectar.OnClick(nil);
            end;
        end else begin
            PnlHotKey.Visible := False;
            EdtTitulo.Text := TTreeNodeFolder(TrvList.Selected.Data).Titulo;
        end;
    end else
        PnlItem.Visible := False;
end;

procedure TFrmHotKeys.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;

end.
