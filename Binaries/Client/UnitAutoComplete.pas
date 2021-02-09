unit UnitAutoComplete;

interface

uses
    Vcl.Forms, Vcl.Menus, Vcl.ImgList, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls,
    Vcl.ExtCtrls, Vcl.Dialogs, Winapi.Windows, System.Classes, System.SysUtils,
    System.IniFiles, SynEdit, System.ImageList;

type
  TFrmAutoCompletes = class(TForm)
    PnlAutoComplete: TPanel;
    LtvAutoComplete: TListView;
    ImlAutoComplete: TImageList;
    PpmAutoComplete: TPopupMenu;
    MniIcones: TMenuItem;
    MniIconesPequenos: TMenuItem;
    MniLista: TMenuItem;
    MniDetalhes: TMenuItem;
    LtvListaPalavras: TListView;
    TmrAutoComplete: TTimer;
    LtvListaVariaveis: TListView;
    LtvListaAtalhos: TListView;
    LtvListaFuncao: TListView;
    MniN1: TMenuItem;
    MniMostrar: TMenuItem;
    MniZerar: TMenuItem;
    MniAlterar: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LtvAutoCompleteDblClick(Sender: TObject);
    procedure LtvAutoCompleteKeyPress(Sender: TObject; var Key: Char);
    procedure MniIconesClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TmrAutoCompleteTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LtvAutoCompleteCompare(Sender: TObject; Item1, Item2: TListItem;
                                     Data: Integer; var Compare: Integer);
    procedure MniZerarClick(Sender: TObject);
    procedure MniAlterarClick(Sender: TObject);
  private
    EdtPointer : TSynEdit;
    IniAutoComplete : TIniFile;
    procedure SetarPrioridade(ListItem:TListItem;const Prioridade:Word);
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
  public
    procedure FindCommand(EdtComplete:TSynEdit);
    procedure SelectUpDown(EdtComplete:TSynEdit; Up:Boolean; Down:Boolean);

    procedure CriarItem(ListView:TListView;const Caption,Icone:String);
    procedure CarregarPalavras();
    procedure CarregarFunção();
    procedure CarregarAtalho();
    procedure CarregarDiretorios(FileName:String);
    procedure ProcuraComandos(ListView:TListView;const Comando:String);
    procedure LinksUpdate();

  end;


  TPGSynEdit = class
    procedure OnDropFiles(Sender: TObject; X, Y: Integer; AFiles: TStrings);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

const                           // '.',
  Caracteres : TSysCharSet = [' ',',',';',':','=','+','-','*','\','/','<','>','(',')',
                              '[',']','!','@','#','%','^','$','&','?','|','''','"'];

var
  FrmAutoCompletes: TFrmAutoCompletes;
  PGSynEdit : TPGSynEdit;

implementation
uses
    UnitPGofer, PGofer.Classes, PGofer.Controls, PGofer.Lexico, PGofer.Files,
    PGofer.ListView;

{$R *.dfm}
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited;
    SetWindowLong(Handle, GWL_STYLE, WS_SIZEBOX); //WS_POPUP or
    SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_NOACTIVATE);
    Application.AddPopupForm(FrmAutoCompletes);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.LinksUpdate();
var
    Lista, Seção : TStringList;
    Ini : TIniFile;
    c,d,e : Integer;
begin
    //cria variaveis
    SetLength(AtalhoGlobal, 0);
    Lista := TStringList.Create;
    Seção := TStringList.Create;
    //carrega listas
    Lista.Text := FileListDir(DirCurrent+'Links\*.ini');
    for d := 0 to Lista.Count-1 do
    begin
        //abre arquivo
        Ini := TIniFile.Create( DirCurrent+'Links\'+ Lista[d] );
        Ini.ReadSections(Seção);
        //Varre lista de Seçoes
        for c:=0 to Seção.Count-1 do
        begin
            if CompareText(Seção[c],'Config') <> 0 then
            begin
                //adiciona link
                e := Length( AtalhoGlobal );
                SetLength(AtalhoGlobal, e+1);
                AtalhoGlobal[e].Nome := Seção[c];
                AtalhoGlobal[e].Arquivo := Ini.ReadString(Seção[c],'Arquivo','');
                AtalhoGlobal[e].Parametro := Ini.ReadString(Seção[c],'Parametro','');
                AtalhoGlobal[e].Diretorio := Ini.ReadString(Seção[c],'Diretorio','');
                AtalhoGlobal[e].Icone := Ini.ReadString(Seção[c],'Icone','');
                AtalhoGlobal[e].ShowControl := Ini.ReadInteger(Seção[c],'Abrir',1);
            end;//if config
        end;// for
    //limpar
        Ini.Free;
    end;
    Seção.Free;
    Lista.Free;
    FrmAutoCompletes.CarregarAtalho();
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.CriarItem(ListView:TListView;const Caption,Icone:String);
var
     Item : TListItem;
begin
    if Caption <> '' then
    begin
        //cria item
        Item := ListView.Items.Add;
        Item.ImageIndex := -1;
        Item.Caption := Caption;
        Item.SubItems.Clear;
        Item.SubItems.Add( IniAutoComplete.ReadString('AutoComplete',Caption,'0') );
        Item.SubItems.Add(Icone);
        Item.Data := Item;

        //carrega icones
        if (IconLoader) and (Icone <> '') then
           ListViewIconeLoadFromFile(ListView, Item, 2);
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.CarregarPalavras();
var
   c , d : integer;
   Arquivo : TStringList;
   Forms : TStringList;
begin

    LtvListaPalavras.Clear;
    //carrega o arquivo Autocomplete
    if FileExists(DirCurrent+'Lib\AutoComplete.txt') then
    begin
        //carrega os Forms
        Forms := TStringList.Create;
        for c := 0 to Application.ComponentCount-1 do
        begin
            if Application.Components[c].ClassParent = TForm then
            begin
                Forms.Add( TForm(Application.Components[c]).Caption  );
                CriarItem( LtvListaPalavras , TForm(Application.Components[c]).Caption+'.', '');
            end;
        end;
        //carregar comandos
        Arquivo := TStringList.Create();
        Arquivo.LoadFromFile(DirCurrent+'Lib\AutoComplete.txt');
        for c := 0 to Arquivo.Count-1 do
        begin
            if (Arquivo[c] <> '') and (Arquivo[c][1] <> '/') then
            begin
               if Arquivo[c][1] = '%'  then
               begin
                   for d := 0 to Forms.Count-1 do
                       CriarItem( LtvListaPalavras, Forms[d]+copy(Arquivo[c],2,length(Arquivo[c])), '');
               end else
                   CriarItem( LtvListaPalavras, Arquivo[c], '');
            end;
        end;// for
        Arquivo.Free;
        Forms.Free;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.CarregarFunção();
var
    texto : string;
    c, d, e, f : integer;
begin
    LtvListaFuncao.Clear;

    //carregar funcao
    c := Length(FuncGlobal)-1;
    for d := 0 to c do
    begin
        e := Length(FuncGlobal[d].Variaveis)-1;

        Texto := FuncGlobal[d].Nome;

        if e > 0 then
        begin
            Texto:=Texto+'(';
            f := 0;
            while (f < e-1) do
            begin
                Texto := Texto + ' | ,';
                inc(f);
            end;
            Texto := Texto + ' | )';
        end;
        Texto := Texto +';';

        FrmAutoCompletes.CriarItem( LtvListaFuncao, Texto, '');
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.CarregarAtalho();
var
    c, d : integer;
begin
    ImlAutoComplete.Clear;
    LtvListaAtalhos.Clear;
    //carregar Atalhos
    c := Length(AtalhoGlobal)-1;
    for d := 0 to c do
    begin
        CriarItem( LtvListaAtalhos, AtalhoGlobal[d].Nome+';',AtalhoGlobal[d].Icone);
        CriarItem( LtvListaAtalhos, AtalhoGlobal[d].Nome+'.Directory:=',AtalhoGlobal[d].Icone);
        CriarItem( LtvListaAtalhos, AtalhoGlobal[d].Nome+'.File:=',AtalhoGlobal[d].Icone);
        CriarItem( LtvListaAtalhos, AtalhoGlobal[d].Nome+'.Icon:=',AtalhoGlobal[d].Icone);
        CriarItem( LtvListaAtalhos, AtalhoGlobal[d].Nome+'.Parameter:=',AtalhoGlobal[d].Icone);
        CriarItem( LtvListaAtalhos, AtalhoGlobal[d].Nome+'.ParamExec( | );',AtalhoGlobal[d].Icone);
        CriarItem( LtvListaAtalhos, AtalhoGlobal[d].Nome+'.ShowControl:=',AtalhoGlobal[d].Icone);
    end;
end;
//----------------------------------------------------------------------------//
Procedure TFrmAutoCompletes.CarregarDiretorios(FileName:String);
var SearchRec : TSearchRec;
    c , d: integer;
    Icone : String;
begin
    ChDir(DirCurrent);
    //localiza os aquivos e adiciona na lista
    c := FindFirst(FileName+'*', faAnyFile , SearchRec );
    d:=0;
    while (c = 0)and( d <  FileListMax ) do
    begin
        //ajusta o icone
        if (SearchRec.Attr and faDirectory) = faDirectory  then
           Icone := '%SystemRoot%\System32\shell32.dll,3'
        else
           Icone := ExtractFilePath(FileName)+SearchRec.Name;

        CriarItem( LtvAutoComplete, SearchRec.Name , Icone );

        inc(d);
        c := FindNext( SearchRec );
    end;//while (c = 0) do
    FindClose( SearchRec );
    ChDir(DirCurrent);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.ProcuraComandos(ListView:TListView;const Comando:String);
var
    Item, Item2 : TListItem;
begin
    //procura
    Item:=ListView.FindCaption(0, Comando , True, True, False);
    while Item <> nil do
    begin
        //adiciona
        Item2 := LtvAutoComplete.Items.Add;
        Item2.Caption := Item.Caption;
        Item2.SubItems := Item.SubItems;
        Item2.ImageIndex := Item.ImageIndex;
        Item2.Data := Item;
        //procura
        Item:=ListView.FindCaption(Item.Index+1, Comando , True, True, False);
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.FindCommand(EdtComplete:TSynEdit);
var
    Display : TDisplayCoord;
    Ponto : TPoint;
    Token : TToken;
    Classe : Word;
    Diretorio, Comando : String;
    SelStart : Integer;
begin
    //anota o ponteiro do edit
    EdtPointer := EdtComplete;
    SelStart := EdtComplete.RowColToCharIndex( EdtComplete.CaretXY );

    //limpa tudo
    LtvAutoComplete.OnCompare := nil;
    LtvAutoComplete.Items.Clear();

    //cria o token para localizar o comando.
    Token := TToken.Create(copy(EdtComplete.Text,1,SelStart),nil);
    Classe := cmdNone;
    Token.Lexico();

    //roda o Lexico
    while Token.Classe <> cmdEnd do
    begin
        if (Token.Classe in [cmdDot]) or (Classe in [cmdDot]) then
           Comando := Comando + Token.Lexema
        else
           Comando := Token.Lexema;
        Classe := Token.Classe;
        Token.Lexico();
    end;
    Token.Free;

    //verificar se é arquivo
    if (Classe = cmdString) and (Length(Comando)>2) then
       Diretorio := ExtractFilePath(FileExpandPath(Comando));

    //se nao for arquivo carrega os comandos
    if not DirectoryExists(Diretorio) then
    begin
        //procura nas listas
        if (not (Classe in [cmdNone,cmdNumeric,cmdString,cmdRes_begin,cmdRes_repeat,cmdRes_var]))
        and (Comando <> '') then
        begin
            ProcuraComandos( LtvListaPalavras, Comando );
            ProcuraComandos( LtvListaVariaveis, Comando );
            ProcuraComandos( LtvListaFuncao, Comando );
            ProcuraComandos( LtvListaAtalhos, Comando );
        end;
    end else //if DirFile
        CarregarDiretorios(Comando);

    //se encotrou seleciona no auto complete
    if (LtvAutoComplete.Items.Count > 0) then
    begin
        LtvAutoComplete.OnCompare := PGListView.OnCompare;
        //organiza em ordem alfabetica
        ColIndex := 0;
        ColIndexU := -1;
        LtvAutoComplete.AlphaSort;

        //organiza prioridades dos comandos
        LtvAutoComplete.OnCompare := LtvAutoCompleteCompare;
        LtvAutoComplete.AlphaSort;

        LtvAutoComplete.OnCompare := PGListView.OnCompare;

        //ajusta a posicao do autocomplete e do hint
        Display.Column := EdtComplete.CaretX;
        Display.Row := EdtComplete.CaretY + 1;
        Ponto := EdtComplete.RowColumnToPixels( Display );
        Top := EdtComplete.ClientOrigin.Y + Ponto.Y + 2;
        Left := EdtComplete.ClientOrigin.X + Ponto.X ;

        //seleciona o primeiro
        if LtvAutoComplete.Items[0].Caption <> '' then
        begin
            LtvAutoComplete.ItemFocused:=LtvAutoComplete.Items[0];
            LtvAutoComplete.Selected:=LtvAutoComplete.Items[0];
            LtvAutoComplete.Items[0].MakeVisible( True );
        end;

        FormForceShow( FrmAutoCompletes, True);
        TmrAutoComplete.Enabled := True;
        EdtComplete.SetFocus;

    end else begin
        //se nao encontrou fecha
        FrmAutoCompletes.Close;
    end;

end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.SetarPrioridade(ListItem:TListItem;const Prioridade:Word);
begin
    ListItem.SubItems[0] := IntToStr(Prioridade);
    TListItem( ListItem.Data ).SubItems[0] := ListItem.SubItems[0];
    IniAutoComplete.WriteInteger('AutoComplete', ListItem.Caption , Prioridade );
    LtvAutoComplete.Update;
end;
//----------------------------------------------------------------------------//
Procedure TFrmAutoCompletes.SelectUpDown(EdtComplete:TSynEdit; Up:Boolean; Down:Boolean);
var
    SelInicio, SelFinal : Integer;
begin
    if (LtvAutoComplete.Items.Count > 0) then
    begin
        //localiza o final
        SelFinal := EdtComplete.CaretX;
        while (SelFinal < Length(EdtComplete.LineText))
        and (not CharInSet(EdtComplete.LineText[SelFinal] , Caracteres)) do
               inc(SelFinal);

        //localiza o inicio
        SelInicio := EdtComplete.CaretX-1;
        while (SelInicio > 0)
        and (SelInicio <= Length(EdtComplete.LineText))
        and (not CharInSet(EdtComplete.LineText[SelInicio], Caracteres)) do
               Dec(SelInicio);

        inc(SelInicio);

        //move selecao
        if Up then
        begin
            //seleciona para cima
            if LtvAutoComplete.ItemIndex > 0 then
               LtvAutoComplete.ItemIndex := LtvAutoComplete.ItemIndex-1;
        end else begin
            if Down then
            begin
                //seleciona para baixo
                if LtvAutoComplete.ItemIndex < LtvAutoComplete.Items.Count-1 then
                   LtvAutoComplete.ItemIndex := LtvAutoComplete.ItemIndex+1;
            end else begin
                //insere no texto
                EdtComplete.CaretX := SelInicio;
                EdtComplete.SelLength := SelFinal-SelInicio;
                EdtComplete.SelText := LtvAutoComplete.ItemFocused.Caption;
                //incrementa +1 na prioridade
                SelInicio := StrToInt( LtvAutoComplete.ItemFocused.SubItems[0] ) + 1;
                SetarPrioridade(LtvAutoComplete.ItemFocused, SelInicio);
                FrmAutoCompletes.Close;
            end;
        end;

        //seleciona opcao
        LtvAutoComplete.Items[LtvAutoComplete.ItemIndex].MakeVisible( True);
        LtvAutoComplete.Items[LtvAutoComplete.ItemIndex].Selected := True;
    end;//if count > 0
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.TmrAutoCompleteTimer(Sender: TObject);
begin
    //fecha o autocomplete se o foco sair do programa.
    if Assigned(EdtPointer) and (not EdtPointer.Focused) and (not LtvAutoComplete.Focused) then
       FrmAutoCompletes.Close;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.FormCreate(Sender: TObject);
begin
    //seta eventos
    LtvAutoComplete.OnColumnClick := PGListView.OnColumnClick;
    LtvAutoComplete.OnCompare := PGListView.OnCompare;

    //carrega config
    IniLoadFromFile(Self, DirCurrent+'Config.ini');
    EdtPointer := nil;

    //carrega prioridades de autocomplete
    IniAutoComplete := TIniFile.Create(DirCurrent+'AutoCompleteMark.ini');

    //carregar
    //LinksUpdate();
    CarregarPalavras();
    //AutoRunUpdate();
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.FormDestroy(Sender: TObject);
begin
    IniAutoComplete.Free;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.FormActivate(Sender: TObject);
begin
    //arruma a bagaça para não dar um bug sinistro.
    Width := Width -1;
    Update;
    Width := Width +1;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.FormClose(Sender: TObject;  var Action: TCloseAction);
begin
    //salva config
    IniSaveToFile(Self, DirCurrent+'Config.ini');
    EdtPointer := nil;
    TmrAutoComplete.Enabled := False;
    IniAutoComplete.UpdateFile;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.LtvAutoCompleteCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
    v1,v2 : integer;
begin
    //ajusta a ordem dos comando por valor de execução.
    TryStrToInt(Item1.SubItems[0],v1);
    TryStrToInt(Item2.SubItems[0],v2);
    Compare := v2-v1;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.LtvAutoCompleteDblClick(Sender: TObject);
begin
    //dbclik seleciona
    SelectUpDown(EdtPointer, False, False);
    Close;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.LtvAutoCompleteKeyPress(Sender: TObject; var Key: Char);
begin
    //seleciona ou sai
    case Key of
       #13 : SelectUpDown(EdtPointer, False, False);
       #27 : Close;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.MniIconesClick(Sender: TObject);
begin
    LtvAutoComplete.ViewStyle := TViewStyle(TMenuItem(Sender).Tag);
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.MniAlterarClick(Sender: TObject);
var
   N : Integer;
begin
    if TryStrToInt(InputBox('Prioridade', 'Valor', LtvAutoComplete.ItemFocused.SubItems[0]),N) then
       SetarPrioridade( LtvAutoComplete.ItemFocused, N );
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoCompletes.MniZerarClick(Sender: TObject);
begin
    SetarPrioridade( LtvAutoComplete.ItemFocused, 0 );
end;
//----------------------------------------------------------------------------//
//-------------------------------SYNEDIT--------------------------------------//
//----------------------------------------------------------------------------//
procedure TPGSynEdit.OnDropFiles(Sender: TObject; X, Y: Integer; AFiles: TStrings);
begin
    if AFiles.Text <> '' then
    begin
        TSynEdit(Sender).Lines.Add( AFiles.Text );
    end;
end;
//----------------------------------------------------------------------------//
procedure TPGSynEdit.OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
    c : Word;
    Edit : TSynEdit;
begin
    Edit := TSynEdit(Sender);
    case Key of
         //ENTER
         VK_RETURN : begin
                         //Autocomplete
                         if FrmAutoCompletes.Visible then
                         begin
                             FrmAutoCompletes.SelectUpDown( Edit, False, False);
                             //seleciona |
                             c := Pos( '|', Edit.Lines[ Edit.CaretY-1 ]);
                             if c > 0 then
                             begin
                                 Edit.CaretX := c;
                                 Edit.SelLength := 1;
                                 Edit.SelText := '';
                                 FrmAutoCompletes.FindCommand( Edit );
                             end;//if c > 0 then

                             Key := 0;
                         end;
                     end;//VK_RETURN
         //ESQ
         VK_ESCAPE : begin
                         if FrmAutoCompletes.Visible then
                         begin
                             FrmAutoCompletes.Close;
                             Key := 0;
                         end;
                     end;//VK_ESCAPE

        //ESPAÇO
        VK_SPACE : begin
                         if Shift = [ssCtrl] then
                         begin
                             FrmAutoCompletes.FindCommand(Edit);
                             Key := 0;
                         end;
                     end;//VK_ESCAPE

         VK_UP,
         VK_DOWN,
         VK_PRIOR,
         VK_NEXT   : begin
                          //seleciona Commando
                          if FrmAutoCompletes.Visible then
                          begin
                              FrmAutoCompletes.SelectUpDown( Edit,(Key in [VK_UP,VK_PRIOR]), (Key in [VK_DOWN,VK_NEXT]));
                              Key := 0;
                          end;
                     end;

         VK_LEFT,
         VK_RIGHT  : begin
                         if FrmAutoCompletes.Visible then
                            FrmAutoCompletes.FindCommand(Edit);
                     end;
    end; //case
end;
//----------------------------------------------------------------------------//
procedure TPGSynEdit.OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
    Edit : TSynEdit;
begin
    Edit := TSynEdit(Sender);
    case key of
      8,
      48{0}..57 {9}, //numero
      65{A}..92 {Z},
      96{0}..105{9}, //numpad
      106{*},
      107{+},109{-},
      110{.},111{/},
      187{=},186{;},
      188{,},189{-},
      190{.},191{/},
      219{[},220{\},
      221{]},222{'},
      226{\}
                   : begin
                         if Edit.LineText <> '' then
                            FrmAutoCompletes.FindCommand(Edit)
                         else
                            FrmAutoCompletes.Close;
                     end;//$30..$39,

       VK_LEFT,
       VK_RIGHT    : begin
                         if Copy(Edit.Lines[Edit.CaretY-1],Edit.CaretX,1) = '|' then
                         begin
                             Edit.SelLength := 1;
                             Edit.SelText := '';
                             FrmAutoCompletes.FindCommand(Edit);
                         end;
                     end;
    end;//case

end;
//----------------------------------------------------------------------------//

end.
