unit UnitAutoKeys;

interface

uses
    Vcl.Forms, Vcl.ImgList, Vcl.Controls, Vcl.Menus, Vcl.StdCtrls, Vcl.Graphics,
    Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs,
    System.SysUtils, System.Classes, System.IniFiles, System.ImageList,
    Winapi.Windows, Winapi.Messages;

type
  TFrmAutoKeysA = class(TForm)
    PpmAutoKeys: TPopupMenu;
    TrvAutoKeys: TTreeView;
    ImlTreeView: TImageList;
    PgcAutoKeys: TPageControl;
    TbsAutoKey: TTabSheet;
    TbsClipBoard: TTabSheet;
    TrvClipBoard: TTreeView;
    PpmClipBorad: TPopupMenu;
    PnlClipBoard: TPanel;
    ImlClipBoard: TImage;
    LblClipBoard: TLabel;
    PpmClipBoardTrv: TPopupMenu;
    OpdClipBoard: TOpenDialog;
    SvdClipBoard: TSaveDialog;
    MniEditar: TMenuItem;
    MniNovaPasta: TMenuItem;
    MniN1: TMenuItem;
    MniUsar: TMenuItem;
    MniDeletar: TMenuItem;
    MniNovoItem: TMenuItem;
    MniRenomear: TMenuItem;
    MniN2: TMenuItem;
    MniFechar: TMenuItem;
    MniExportXML: TMenuItem;
    MniImportXML: TMenuItem;
    MniN3: TMenuItem;
    MniSalvar: TMenuItem;
    MniLimpar: TMenuItem;
    MniCriarPasta: TMenuItem;
    MniDeletarCB: TMenuItem;
    MniRenomearCB: TMenuItem;
    MniCopyClipBoard: TMenuItem;
    MniN4: TMenuItem;
    MniN5: TMenuItem;
    MniSalvarArquivo: TMenuItem;
    MniCarregarArquivo: TMenuItem;
    MniSalvarAutomatico: TMenuItem;
    MniOpções: TMenuItem;
    MniMaximo: TMenuItem;
    MniPassWord: TMenuItem;
    MniNovo: TMenuItem;
    MniNovoPassWord: TMenuItem;
    MniN6: TMenuItem;
    PnlClipBoardKey: TPanel;
    ImgClipBoardKey: TImage;
    LblClipBoardKey: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MniNovaPastaClick(Sender: TObject);
    procedure MniRenomearClick(Sender: TObject);
    procedure MniNovoItemClick(Sender: TObject);
    procedure PpmAutoKeysPopup(Sender: TObject);
    procedure MniDeletarClick(Sender: TObject);
    procedure MniUsarClick(Sender: TObject);
    procedure MniEditarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure MniFecharClick(Sender: TObject);
    procedure MniExportXMLClick(Sender: TObject);
    procedure MniImportXMLClick(Sender: TObject);
    procedure MniSalvarClick(Sender: TObject);
    procedure MniLimparClick(Sender: TObject);
    procedure MniRenomearCBClick(Sender: TObject);
    procedure MniDeletarCBClick(Sender: TObject);
    procedure MniCriarPastaClick(Sender: TObject);
    procedure MniCopyClipBoardClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PpmClipBoardTrvPopup(Sender: TObject);
    procedure MniSalvarArquivoClick(Sender: TObject);
    procedure MniCarregarArquivoClick(Sender: TObject);
    procedure MniMaximoClick(Sender: TObject);
    procedure MniPassWordClick(Sender: TObject);
    procedure MniNovoPassWordClick(Sender: TObject);
    procedure ImgClipBoardKeyDblClick(Sender: TObject);
  private
    { Private declarations }

    //clipboard
    NextInChain : THandle;
    Carrengando : Boolean;
    AutoSaveMax : Integer;

    //password
    PassSave : Boolean;
    PassWord : String;

  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MessageDrawClipboard(var Msg: TMessage); message WM_DRAWCLIPBOARD;
    procedure MessageChangeCBChain(var Msg: TMessage); message WM_CHANGECBCHAIN;
  public
    { Public declarations }
  end;

var
   FrmAutoKeysA: TFrmAutoKeysA;

implementation

{$R *.dfm}

uses
    PGofer.ClipBoards, PGofer.Controls, PGofer.Key, PGofer.ZLib,
    PGofer.TreeView, UnitPassWord, UnitAutoKeysConfig;

//---------------------------------------------------------------------------//
procedure TFrmAutoKeysA.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;
//--------------------------------------------------------------------//
procedure TFrmAutoKeysA.MessageDrawClipboard(var Msg:TMessage) ;
var
    MemoryStream : TMemoryStream;
    NodeItem, NodeFolder : TTreeNode;
begin
    try
       LblClipBoard.Caption := ClipBoardGetFormat();
       PnlClipBoardKey.Visible := False;
       if (LblClipBoard.Caption <> '') then
       begin
           ImlClipBoard.Visible := True;
           LblClipBoard.Visible := True;
           MniSalvar.Enabled := True;
           MniLimpar.Enabled := True;

           PnlClipBoardKey.Visible := (copy(LblClipBoard.Caption,1,4) = 'Text');

           //salvar automatico
           if (MniSalvarAutomatico.Checked) and (not Carrengando)then
           begin

               MemoryStream := TMemoryStream.Create;
               ClipBoardSaveStream(MemoryStream);

               //procura a pasta AutoSave ou cria
               NodeFolder := TrvClipBoard.FindCaption('AutoSave',0);
               if NodeFolder = nil then
               begin
                   NodeFolder := TrvClipBoard.AddTreeNode(nil,0);
                   NodeFolder.Text := 'AutoSave';
               end;

               NodeItem := TrvClipBoard.AddTreeNode(NodeItem,2);
               NodeItem.Text := LblClipBoard.Caption;
               NodeItem.Data := MemoryStream;

               //deleta items sobrando
               if NodeFolder.Count > AutoSaveMax then
                  NodeFolder.Item[0].Delete;

               NodeFolder.Expanded := True;
           end;

           Carrengando := False;
       end else begin
           ImlClipBoard.Visible := False;
           LblClipBoard.Visible := False;
           MniSalvar.Enabled := False;
           MniLimpar.Enabled := False;
       end;

    except
       LblClipBoard.Caption := '';
    end;

    //Passa a mensagem para o proximo programa.
    if NextInChain <> 0 then
       SendMessage(NextInChain, WM_DrawClipboard, 0, 0);
end;
//--------------------------------------------------------------------//
procedure TFrmAutoKeysA.MessageChangeCBChain(var Msg: TMessage) ;
begin
    if NextInChain = Msg.WParam then
       NextInChain := Msg.LParam
    else
       if NextInChain <> 0 then
          SendMessage(NextInChain, WM_ChangeCBChain, Msg.WParam, Msg.LParam);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniExportXMLClick(Sender: TObject);
begin
    TrvAutoKeys.XMLSaveToFile( DirCurrent+'\AutoKeys.xml', 'AutoKeys' );
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.FormActivate(Sender: TObject);
var
    CursorPoint : TPoint;
begin
    //pega a posição do cursor e posiciona a janela
    GetCursorPos(CursorPoint);
    Left := CursorPoint.X;
    Top := CursorPoint.Y;
    FormPositionFixed(FrmAutoKeysA);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.FormClose(Sender: TObject; var Action: TCloseAction);
var
    Ini : TIniFile;
    MemoryStream : TStringStream;
begin
    //desabilita fechar e oculta
    Action := caNone;
    Hide;

    //salva configurações no ini
    IniSaveToFile(Self, DirCurrent+'Config.ini');
    Ini := TIniFile.Create(DirCurrent+'Config.ini');
    Ini.WriteBool(Self.Name,'AutoSave',MniSalvarAutomatico.Checked);
    Ini.WriteInteger(Self.Name,'SaveMax',AutoSaveMax);
    Ini.WriteBool(Self.Name,'SavePass', PassSave);

    //criptografa e salva o Password
    if PassSave then
    begin
        MemoryStream := TStringStream.Create(PassWord);
        Criptografar(MemoryStream,'AuToKeYs');
        ini.WriteBinaryStream(Self.Name,'PassWord',MemoryStream);
        MemoryStream.Free;
    end else
        ini.DeleteKey(Self.Name,'PassWord');

    Ini.Free;


    TrvAutoKeys.XMLSaveToFile( DirCurrent+'\AutoKeys.xml' ); //  PassWord

end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited;
    //configura a janela para não aparecer na barra e não ativado.
    SetWindowLong(Handle, gwl_exstyle, WS_EX_NOACTIVATE
                  or ws_ex_toolwindow and not Ws_ex_appwindow);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.FormCreate(Sender: TObject);
var
    Ini : TIniFile;
    MaxError : Byte;
    StringStream : TStringStream;
begin
    //seta os onEvents para os treeViews
    TrvAutoKeys.SetOnProcedHelpers;
    TrvClipBoard.SetOnProcedHelpers;

    //carrega configurações do ini
    IniLoadFromFile(Self, nil, DirCurrent+'Config.ini');
    Ini := TIniFile.Create(DirCurrent+'Config.ini');
    MniSalvarAutomatico.Checked := Ini.ReadBool(Self.Name,'AutoSave',False);
    AutoSaveMax := Ini.ReadInteger(Self.Name,'SaveMax',5);
    MniMaximo.Caption := 'Maximo: '+IntToStr(AutoSaveMax);

    //desencriptografa o PassWord
    PassSave := ini.ReadBool(Self.Name,'SavePass',False);
    if PassSave then
    begin
        StringStream := TStringStream.Create('');
        ini.ReadBinaryStream(Self.Name,'PassWord',StringStream);
        Criptografar(StringStream,'AuToKeYs');
        PassWord := StringStream.DataString;
        StringStream.Free;
    end;

    ini.Free;


    TrvAutoKeys.XMLLoadFromFile( DirCurrent+'\AutoKeys.xml' );
    {//abre o documento ou pede a senha
    MaxError := 0;
    while (not TreeViewLoadFromFile(TrvAutoKeys, XMLDocument, DirCurrent+'\AutoKeys\AutoKeys.dat',PassWord))
      and (MaxError < 3) do
    begin
        sleep(MaxError*1000);
        MniPassWord.Click;
        inc(MaxError);
    end;
    //fecha se não acertar a senha
    if MaxError >= 3 then
    begin
        Halt;
    end;
     }
    //habilita clipboard view
    NextInChain := SetClipboardViewer(Handle);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.FormDestroy(Sender: TObject);
begin
    //desabilita o clipboard view
    ChangeClipboardChain(Handle, NextInChain);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.ImgClipBoardKeyDblClick(Sender: TObject);
begin
    KeyMacroPress( ClipBoardPasteToText , 10 );
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniImportXMLClick(Sender: TObject);
begin
    TrvAutoKeys.XMLLoadFromFile( DirCurrent+'\AutoKeys.xml' );
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniCarregarArquivoClick(Sender: TObject);
var
    MemoryStream : TMemoryStream;
    Node : TTreeNode;
begin
    if OpdClipBoard.Execute then
    begin
        MemoryStream := TMemoryStream.Create;
        MemoryStream.LoadFromFile(OpdClipBoard.FileName);

        if (TrvClipBoard.Selected <> nil) and (TrvClipBoard.Selected.ImageIndex > 0) then
            TrvClipBoard.Selected := TrvClipBoard.Selected.Parent;

        Node := TrvClipBoard.AddTreeNode(TrvClipBoard.Selected,2);
        Node.Text := ExtractFileName(OpdClipBoard.FileName);
        Node.Data := MemoryStream;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniCopyClipBoardClick(Sender: TObject);
begin
    //carrega para o clipboard
    Carrengando := True;
    ClipBoardLoadStream( TMemoryStream(TrvClipBoard.Selected.Data) );
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniCriarPastaClick(Sender: TObject);
begin

    TreeViewCreateItem(TrvClipBoard,TrvClipBoard.Selected,'Nova Pasta',0,nil);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniDeletarCBClick(Sender: TObject);
begin
    TrvClipBoard.DeleteSelect();
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniDeletarClick(Sender: TObject);
begin
    TreeViewDeleteSelect(TrvAutoKeys);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniEditarClick(Sender: TObject);
var
    Item : TItemMacro;
    FrmConfig : TFrmAutoKeysConfig;
begin
    if (TrvAutoKeys.Selected <> nil) then
    begin
        FrmConfig := TFrmAutoKeysConfig.Create(self);
        if(TrvAutoKeys.Selected.Data <> nil) then
        begin
            Item :=  TItemMacro(TrvAutoKeys.Selected.Data);
            FrmConfig.EdtAutoKey.Lines.Text := Item.Texto;
            FrmConfig.RgOpções.ItemIndex := Item.Opção;
            FrmConfig.UdVelocidade.Position := Item.Velocidade;
            FrmConfig.CbxApagarTrasf.Checked := Item.Apagar;
        end else begin
            Item := nil;
            FrmConfig.EdtAutoKey.Clear;
            FrmConfig.UdVelocidade.Position := 10;
        end;
        FrmAutoKeysA.FormStyle := fsNormal;
        if FrmConfig.ShowModal = mrOk then
        begin
            if Item = nil then
            begin
                Item := TItemMacro.Create;
                TrvAutoKeys.Selected.Data := Pointer(Item);
            end;
            Item.Texto := FrmConfig.EdtAutoKey.Lines.Text;
            Item.Opção := FrmConfig.RgOpções.ItemIndex;
            Item.Velocidade := FrmConfig.UdVelocidade.Position;
            Item.Apagar := FrmConfig.CbxApagarTrasf.Checked;
        end;
        FrmConfig.Free;
        FrmAutoKeysA.FormStyle := fsStayOnTop;
        FormForceShow(FrmAutoKeysA,False);
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniFecharClick(Sender: TObject);
begin
    Close;
    Application.Terminate;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniLimparClick(Sender: TObject);
begin
    ClipBoardClear();
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniMaximoClick(Sender: TObject);
var
    Texto : String;
    Temp : Integer;
begin
    Texto := InputBox('ClipBoard','Numero Maximo Auto Save:', IntToStr(AutoSaveMax) );
    if TryStrToInt(Texto,Temp) and (Temp > 1) and (Temp < 200) then
       AutoSaveMax := Temp;
    MniMaximo.Caption := 'Maximo: '+IntToStr(AutoSaveMax);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniNovaPastaClick(Sender: TObject);
begin
    if (TrvAutoKeys.Selected <> Nil) and (TrvAutoKeys.Selected.ImageIndex > 0) then
       TrvAutoKeys.Selected := TrvAutoKeys.Selected.Parent;

    TreeViewCreateItem(TrvAutoKeys,TrvAutoKeys.Selected,'Nova Pasta',0,nil);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniNovoItemClick(Sender: TObject);
begin
    if (TrvAutoKeys.Selected <> Nil) and (TrvAutoKeys.Selected.ImageIndex > 0) then
       TrvAutoKeys.Selected := TrvAutoKeys.Selected.Parent;

    TreeViewCreateItem(TrvAutoKeys,TrvAutoKeys.Selected,'Novo Item',1,nil);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniNovoPassWordClick(Sender: TObject);
var
    Item : TTreeNode;
begin
    if (TrvAutoKeys.Selected <> Nil) and (TrvAutoKeys.Selected.ImageIndex > 0) then
       TrvAutoKeys.Selected := TrvAutoKeys.Selected.Parent;

    Item := TreeViewCreateItem(TrvAutoKeys,TrvAutoKeys.Selected,'Novo PassWord',0,nil);
    TreeViewCreateItem(TrvAutoKeys,Item,'Usuario',1,nil);
    TreeViewCreateItem(TrvAutoKeys,Item,'Senha',1,nil);
    Item.Selected := true;
    Item.Expand(True);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniRenomearCBClick(Sender: TObject);
begin
    TrvClipBoard.Selected.EditText;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniRenomearClick(Sender: TObject);
begin
    TrvAutoKeys.Selected.EditText;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniSalvarArquivoClick(Sender: TObject);
begin
    if SvdClipBoard.Execute then
    begin
        TMemoryStream(TrvClipBoard.Selected.Data).SaveToFile(SvdClipBoard.FileName);
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniSalvarClick(Sender: TObject);
var
    Ms : TMemoryStream;
begin
    Ms := TMemoryStream.Create;
    ClipBoardSaveStream(Ms);
    TreeViewCreateItem(TrvClipBoard,nil,LblClipBoard.Caption,2,Ms);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniUsarClick(Sender: TObject);
begin
    if (TrvAutoKeys.Selected <> nil) and (TrvAutoKeys.Selected.Data <> nil)
    and (not TrvAutoKeys.IsEditing) then
    begin
        Hide;

        case (TItemMacro(TrvAutoKeys.Selected.Data).Opção) of
               //digita o texto
           0 : begin
                   KeyMacroPress( TItemMacro(TrvAutoKeys.Selected.Data).Texto ,
                                  TItemMacro(TrvAutoKeys.Selected.Data).Velocidade );
               end;
               //cola o texto
           1 : begin
                   ClipBoardCopyFromText(TItemMacro(TrvAutoKeys.Selected.Data).Texto);
                   KeySetPress( VK_CONTROL, True);
                   KeySetPress( Byte('V') , True);
                   KeySetPress( Byte('V') , False);
                   KeySetPress( VK_CONTROL, False);
                   sleep(100);
                   if TItemMacro(TrvAutoKeys.Selected.Data).Velocidade <> 0 then
                      ClipBoardClear();
               end;
               //roda o script (macro)
           2 : begin
                   SendScript(TItemMacro(TrvAutoKeys.Selected.Data).Texto);
               end;
        end;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.MniPassWordClick(Sender: TObject);
var
    FormPass : TFrmPassword;
begin
    FormPass := TFrmPassword.Create(Self);
    FormPass.CbxPassWord.Checked := PassSave;
    if PassSave then
       FormPass.EdtPassWord.Text := PassWord
    else
       FormPass.EdtPassWord.Text := '';

    if FormPass.ShowModal = mrOk then
    begin
        PassWord := FormPass.EdtPassWord.Text;
        PassSave := FormPass.CbxPassWord.Checked;
    end;
    FormPass.Free;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.PpmAutoKeysPopup(Sender: TObject);
begin
    MniUsar.Enabled := False;
    MniRenomear.Enabled := False;
    MniDeletar.Enabled := False;
    MniEditar.Enabled := False;
    if TrvAutoKeys.Selected <> nil then
    begin
        MniRenomear.Enabled := True;
        MniDeletar.Enabled := True;
        if TrvAutoKeys.Selected.ImageIndex = 1 then
        begin
            MniUsar.Enabled := True;
            MniEditar.Enabled := True;
        end;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysA.PpmClipBoardTrvPopup(Sender: TObject);
begin
    MniCopyClipBoard.Enabled := False;
    MniDeletarCB.Enabled := False;
    MniRenomearCB.Enabled := False;
    MniSalvarArquivo.Enabled := False;

    if TrvClipBoard.Selected <> nil then
    begin
        if TrvClipBoard.Selected.ImageIndex > 0 then
        begin
            MniCopyClipBoard.Enabled := True;
            MniSalvarArquivo.Enabled := True;
        end;
        MniDeletarCB.Enabled := True;
        MniRenomearCB.Enabled := True;
    end;
end;
//----------------------------------------------------------------------------//
end.
