unit UnitLinks;

interface

{$WARN UNIT_PLATFORM OFF}

uses

   Vcl.Forms, Vcl.Menus, Vcl.ImgList, Vcl.Controls, Vcl.Dialogs, Vcl.ComCtrls,
   Vcl.StdCtrls, Vcl.Buttons, Vcl.FileCtrl,
   Winapi.Windows, Winapi.Messages,
   System.SysUtils, System.Classes, System.UITypes,
   SynEdit;

type
  TFrmLinks = class(TForm)
    OpdLinks: TOpenDialog;
    ImlLinks: TImageList;
    GrbLinks: TGroupBox;
    LblComando: TLabel;
    LblArquivo: TLabel;
    LblParametro: TLabel;
    LblComentario: TLabel;
    LblAbrir: TLabel;
    LblLista: TLabel;
    LblIcone: TLabel;
    EdtComando: TEdit;
    EdtComentario: TEdit;
    CmbAbrir: TComboBox;
    CmbLista: TComboBox;
    BtnArquivo: TBitBtn;
    BtnTeste: TBitBtn;
    BtnAdd: TBitBtn;
    BtnIcone: TBitBtn;
    GrbLista: TGroupBox;
    LtvLinks: TListView;
    PpmLinks: TPopupMenu;
    MniDeletar: TMenuItem;
    MniDeletarLista: TMenuItem;
    BtnNovo: TBitBtn;
    MniDeletarMarcados: TMenuItem;
    MniMostrar: TMenuItem;
    MniN1: TMenuItem;
    MniIcones: TMenuItem;
    MniLista: TMenuItem;
    MniDetalhes: TMenuItem;
    MniIconesPequenos: TMenuItem;
    EdtArquivo: TSynEdit;
    EdtParametro: TSynEdit;
    EdtIcone: TSynEdit;
    BtnSalvar: TBitBtn;
    LblDiretorio: TLabel;
    EdtDiretorio: TSynEdit;
    BtnDiretorio: TBitBtn;
    MniMarcarLinkQuebrados: TMenuItem;
    procedure BtnArquivoClick(Sender: TObject);
    procedure BtnIconeClick(Sender: TObject);
    procedure CmbListaClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure MniDeletarListaClick(Sender: TObject);
    procedure MniDeletarClick(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure LtvLinksSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure MniDeletarMarcadosClick(Sender: TObject);
    procedure BtnTesteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MniIconesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EdtComandoChange(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnDiretorioClick(Sender: TObject);
    procedure MniMarcarLinkQuebradosClick(Sender: TObject);
    procedure EdtArquivoChange(Sender: TObject);
  private
    Arquivo : String;
    function IdentifieldIsExists(const Id:String):Boolean;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
  end;

var
  FrmLinks: TFrmLinks;

implementation

{$R *.dfm}

uses  PGofer.Files, PGofer.Controls , PGofer.ListView, PGofer.Key;

//---------------------------------------------------------------------------//
procedure TFrmLinks.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;
//----------------------------------------------------------------------------//
function TFrmLinks.IdentifieldIsExists(const Id:String):Boolean;
begin
    //?????????????????
    Result := False;
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.FormCreate(Sender: TObject);
begin
    //seta eventos
    LtvLinks.OnColumnClick:=PGListView.OnColumnClick;
    LtvLinks.OnCompare:=PGListView.OnCompare;
    LtvLinks.OnDragDrop:=PGListView.OnDragDrop;
    LtvLinks.OnDragOver:=PGListView.OnDragOver;

    //criar pasta
    if not DirectoryExists(DirCurrent+'Links\') then
       CreateDir(DirCurrent+'Links\');

    //carrega config
    IniLoadFromFile(Self, LtvLinks, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.FormShow(Sender: TObject);
begin
    //limpa entradas
    CmbLista.Clear;

    //mostra os arquivos
    CmbLista.Items.Text :=  FileListDir(DirCurrent+'Links\*.ini');
    CmbLista.Items.Insert(0,'"Nova Lista"');
    if CmbLista.Items.Count > 1 then
    begin
        CmbLista.ItemIndex:=1;
        ListViewLoadFromFile(LtvLinks, DirCurrent+'Links\'+CmbLista.Text, 3);
    end else
        CmbLista.ItemIndex:=0;
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    //verifica se foi modificado
    if (Arquivo <> '')
    and(MessageDlg('A Lista nao foi salva, deseja salvar?', mtConfirmation, [mbYes, mbNo], mrYes) = mrYes) then
       BtnSalvar.Click
    else
       Arquivo:='';

    //limpa tudo
    BtnNovo.Click;
    PGListView.OnClear(LtvLinks);

    //salva o config
    IniSaveToFile(Self, LtvLinks, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.CmbListaClick(Sender: TObject);
begin
    //verifica se salvou
    if (Arquivo <> '')
    and(MessageDlg('A Lista nao foi salva, deseja salvar?', mtConfirmation, [mbYes, mbNo], mrYes) = mrYes) then
       BtnSalvar.Click
    else
       Arquivo:='';

    //carrega a lista selecionada
    if CmbLista.ItemIndex = 0 then
    begin
        //nova lista
        PGListView.OnClear(LtvLinks);
        Arquivo := InputBox('De um nome para a Lista','Nome:','');
        if Arquivo <> '' then
        begin
            if CompareText(ExtractFileExt(arquivo),'.ini') <> 0 then
               Arquivo:=arquivo+'.ini';
            CmbLista.Items.Add(arquivo);
            CmbLista.ItemIndex:=CmbLista.Items.Capacity-1;
        end;
    end else begin
        PGListView.OnClear(LtvLinks);
        ListViewLoadFromFile(LtvLinks, DirCurrent+'Links\'+CmbLista.Text, 3);
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.BtnArquivoClick(Sender: TObject);
begin
    //Abrir arquivo de link
    OpdLinks.Title:='Arquivo';
    OpdLinks.Filter:='Todos Arquivos(*.*)|*.*';
    OpdLinks.InitialDir:=FileLimitPathExist( EdtArquivo.Text );
    OpdLinks.FileName:=ExtractFileName( EdtArquivo.Text );

    if OpdLinks.Execute then
    begin
        //carrega
        EdtArquivo.Text:= FileUnExpandPath(OpdLinks.FileName);
        FrmLinks.EdtArquivo.OnChange(nil);
        if EdtDiretorio.Text = '' then
           EdtDiretorio.Text := FileUnExpandPath(ExtractFilePath(OpdLinks.FileName));
        if EdtIcone.Text = '' then
           EdtIcone.Text := EdtArquivo.Text+',0';
    end;//if opdlink.execute
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.BtnIconeClick(Sender: TObject);
begin
    //abrir o icone de link
    OpdLinks.Title:='Icone';
    OpdLinks.Filter:='Todos Icones(*.jpg;*.bmp;*.ico;*.exe;*.dll)|*.jpg;*.bmp;*.ico;*.exe;*.dll|Todos Arquivos(*.*)|*.*';
    OpdLinks.InitialDir:=FileLimitPathExist( EdtIcone.Text );
    OpdLinks.FileName:=ExtractFileName( EdtIcone.Text );
    if OpdLinks.Execute then
       EdtIcone.Text:=OpdLinks.FileName+';0';
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.BtnAddClick(Sender: TObject);
var
    Item:TListItem;
begin

    //verifica nome
    if (CmbLista.Text = '') or (CmbLista.ItemIndex = 0) then
       CmbLista.Text := InputBox('De um nome para a Lista','Nome:','');

    if(CmbLista.Text <> '')and(EdtComando.Text <> '') then
    begin
        //adiciona extenção
        if CompareText(ExtractFileExt(CmbLista.Text),'.ini') <> 0 then
           CmbLista.Text := CmbLista.Text+'.ini';

        Item := LtvLinks.FindCaption(0, EdtComando.Text , false, true, false);

        if IdentifieldIsExists(EdtComando.Text) or ( Item <> nil ) then
           ShowMessage('Este identificador já exite')
        else begin
             LtvLinks.OnCompare:=nil;

             if Item = nil then
                Item:=LtvLinks.Items.Add;
             Item.Caption:=EdtComando.Text;
             Item.Checked:=false;
             Item.ImageIndex:=-1;
             Item.SubItems.Clear;
             Item.SubItems.Add(EdtArquivo.Text);
             Item.SubItems.Add(EdtParametro.Text);
             Item.SubItems.Add(CmbAbrir.Text);

             if EdtIcone.Text <> '' then
                Item.SubItems.Add(EdtIcone.Text)
             else
                Item.SubItems.Add(EdtArquivo.Text+',0');

             if EdtDiretorio.Text <> '' then
                Item.SubItems.Add(EdtDiretorio.Text)
             else
                Item.SubItems.Add(EdtArquivo.Text);

             Item.SubItems.Add(EdtComentario.Text);

             ListViewIconeLoadFromFile(LtvLinks, Item, 3);

             LtvLinks.OnCompare := PGListView.OnCompare;
        end;//if repetido

        BtnNovo.Click;
        Arquivo:=DirCurrent+'Links\'+CmbLista.Text;
        CmbLista.Items.Text :=  FileListDir(DirCurrent+'Links\*.ini');
    end;//if cmblista.text <> ''
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.MniDeletarClick(Sender: TObject);
var c:integer;
begin
    //deleta Link
    for c:=LtvLinks.Items.Count-1 downto 0 do
        if LtvLinks.Items[c].Selected then
           LtvLinks.Items[c].Delete;
    BtnNovo.Click;
    Arquivo:=DirCurrent+'Links\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.MniDeletarMarcadosClick(Sender: TObject);
var c:Integer;
begin
    //deleta Link
    for c:=LtvLinks.Items.Count-1 downto 0 do
        if LtvLinks.Items[c].Checked then
           LtvLinks.Items[c].Delete;
    BtnNovo.Click;
    Arquivo:=DirCurrent+'Links\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.MniDeletarListaClick(Sender: TObject);
begin
    //deleta lista
    if DeleteFile(DirCurrent+'Links\'+CmbLista.Text) then
    begin
        ShowMessage('Lista deletada.');
        PGListView.OnClear(LtvLinks);
    end else
        ShowMessage('Erro ao deletar a lista.');
    Arquivo:='';
    BtnNovo.Click;
    LinkUpdate();
    //atualiza a lista
    OnShow(nil);
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.BtnNovoClick(Sender: TObject);
begin
    //cria um novo link
    EdtComando.Clear;
    CmbAbrir.ItemIndex:=1;
    EdtArquivo.Clear;
    EdtParametro.Clear;
    EdtIcone.Clear;
    EdtDiretorio.Clear;
    EdtComentario.Clear;
    LtvLinks.Checkboxes:=false;
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.LtvLinksSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
    //selecione link
    EdtComando.Text:=Item.Caption;
    EdtArquivo.Text:=Item.SubItems[0];
    EdtParametro.Text:=Item.SubItems[1];
    try
        CmbAbrir.ItemIndex:=StrToInt(Item.SubItems[2][1]);
    except
        CmbAbrir.ItemIndex:=1;
    end;
    EdtIcone.Text:=Item.SubItems[3];
    EdtDiretorio.Text:=Item.SubItems[4];
    EdtComentario.Text:=Item.SubItems[5];
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.BtnTesteClick(Sender: TObject);
begin
    //testa parametro
    FileExec(EdtArquivo.Text, EdtParametro.Text, ExtractFilePath(EdtArquivo.Text),
             CmbAbrir.ItemIndex );
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.MniMarcarLinkQuebradosClick(Sender: TObject);
var c:Integer;
begin
    //marca links quebrados
    LtvLinks.Checkboxes:=true;
    for c:=0 to LtvLinks.Items.Count-1 do
        LtvLinks.Items[c].Checked:=(not FileExists(  FileExpandPath( LtvLinks.Items[c].SubItems[0])  ));
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.MniIconesClick(Sender: TObject);
begin
    //muda a lista
    LtvLinks.ViewStyle:=TViewStyle(TMenuItem(Sender).tag);
    Arquivo:=DirCurrent+'Links\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.EdtArquivoChange(Sender: TObject);
begin
    EdtComando.Text:=FileExtractOnliFileName(EdtArquivo.Text);
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.EdtComandoChange(Sender: TObject);
var c:Integer;
begin
    //nao deixa escrever nome de comando invalido.
    if (Length(EdtComando.Text) > 0)
    and(not( CharInSet(EdtComando.Text[1],['A'..'Z','a'..'z']))) then
    begin
        ShowMessage('É permitido apenas letras no primero caracter.');
        EdtComando.Clear;
    end;

    c:=EdtComando.SelStart;
    EdtComando.Text:=RemoveCharSpecial(EdtComando.Text,True);
    EdtComando.SelStart:=c;
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.BtnSalvarClick(Sender: TObject);
var
    texto : String;
begin
   //salva a lista
   if EdtComando.Text <> '' then
      BtnAdd.Click;

    if Arquivo = '' then
       Arquivo:=DirCurrent+'Links\'+CmbLista.Text;

    LtvLinks.Checkboxes:=false;
    BtnNovo.Click;
    ListViewSaveToFile(LtvLinks, Arquivo, false);
    texto := CmbLista.Text;
    CmbLista.Clear;
    CmbLista.Items.Text :=  FileListDir(DirCurrent+'Links\*.ini');
    CmbLista.Items.Insert(0,'"Nova Lista"');
    CmbLista.Text := texto;
    Arquivo:='';
    //atualiza a lista
    LinkUpdate();
end;
//----------------------------------------------------------------------------//
procedure TFrmLinks.BtnDiretorioClick(Sender: TObject);
var Path:string;
begin
    //seleciona o diretorio
    Path := ExtractFilePath( FileLimitPathExist( EdtDiretorio.Text ) );
    if SelectDirectory( Path, [sdAllowCreate, sdPerformCreate, sdPrompt], 1000) then
       EdtDiretorio.Text:=FileUnExpandPath(Path);
end;

end.
