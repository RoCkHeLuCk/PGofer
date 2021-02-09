unit UnitHotKey;

interface

uses
     Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, Vcl.Controls, Vcl.ComCtrls, Vcl.Dialogs,
     Vcl.StdCtrls, Vcl.Buttons,
     Winapi.Messages, Winapi.Windows,
     System.Classes, System.IniFiles, System.SysUtils, System.UITypes,
     SynEdit;

type

  //teclas sendo precionadas
  THotKeyz = Record
        Key : Byte;
       Down : Boolean;
      Press : Boolean;
  end;

  //lista de hotkeys
  TListKeyz = Record
         Key : Array of Byte;
      Detect : Byte;
     Command : String;
        Wait : Word;
       Count : Word;
  end;

  TFrmHotKeys = class(TForm)
    GrbHotKey: TGroupBox;
    LblHotKey: TLabel;
    LblComando: TLabel;
    LblComentario: TLabel;
    BtnTeste: TBitBtn;
    BtnNovo: TBitBtn;
    BtnAdd: TBitBtn;
    EdtComentario: TEdit;
    EdtComando: TSynEdit;
    GrbLista: TGroupBox;
    LtvHotKey: TListView;
    PpmHotKey: TPopupMenu;
    Mostrar1: TMenuItem;
    Icones1: TMenuItem;
    IconesPequenos1: TMenuItem;
    Lista1: TMenuItem;
    Detalhes1: TMenuItem;
    N1: TMenuItem;
    Deletar1: TMenuItem;
    Deletar2: TMenuItem;
    Deletar3: TMenuItem;
    LblDetectar: TLabel;
    CmbDetectar: TComboBox;
    MarcarTudo1: TMenuItem;
    DesmarcarTudo1: TMenuItem;
    InverterMarcas1: TMenuItem;
    LblLista: TLabel;
    CmbLista: TComboBox;
    Marcar1: TMenuItem;
    BtnSalvar: TBitBtn;
    EdtHotKey: TEdit;
    PopupMenu1: TPopupMenu;
    LblTempo: TLabel;
    EdtTempo: TEdit;
    LblTempMs: TLabel;
    UpdTempo: TUpDown;
    TmrHotKeyD: TTimer;
    TmrHotKeyZ: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnNovoClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure Detalhes1Click(Sender: TObject);
    procedure Deletar1Click(Sender: TObject);
    procedure Deletar2Click(Sender: TObject);
    procedure Deletar3Click(Sender: TObject);
    procedure MarcarTudo1Click(Sender: TObject);
    procedure DesmarcarTudo1Click(Sender: TObject);
    procedure InverterMarcas1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CmbListaClick(Sender: TObject);
    procedure LtvHotKeySelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure BtnTesteClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure CmbDetectarChange(Sender: TObject);
    procedure TmrHotKeyDTimer(Sender: TObject);
    procedure EdtHotKeyEnter(Sender: TObject);
    procedure EdtHotKeyExit(Sender: TObject);
    procedure TmrHotKeyZTimer(Sender: TObject);
  private
    { Private declarations }
    HotKeyz : Array of THotKeyz;
    HotKeyD : Array of THotKeyz;
    ListKeyz : Array of TListKeyz;
    IndexD : Integer;
    TimerLost : Boolean;
    Arquivo :String;
    procedure HotKeyUpdate();
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

uses PGofer.Controls, PGofer.Files, PGofer.Key, PGofer.ListView;
//---------------------------------------------------------------------------//
procedure TFrmHotKeys.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.HotKeyUpdate();
var
    Lista, Seção : TStringList;
    Teclas : String;
    Ini : TIniFile;
    c,d,e,f : Integer;
begin
    SetLength(ListKeyz, 0);
    Lista := TStringList.Create;
    Seção := TStringList.Create;
    Lista.Text := FileListDir(DirCurrent+'HotKey\*.ini');
    for d := 0 to Lista.Count-1 do
    begin
        Ini := TIniFile.Create( DirCurrent+'HotKey\'+ Lista[d] );
        Ini.ReadSections(Seção);
        //Varre lista de Seçoes
        for c:=0 to Seção.Count-1 do
        begin
            if (SameText(Seção[c],'Config')) and (ini.ReadBool(Seção[c],'Check',False)) then
            begin
                e := Length( ListKeyz );
                SetLength(ListKeyz, e+1);

                ListKeyz[e].Command := ini.ReadString(Seção[c],'Comando','');
                ListKeyz[e].Detect := ini.ReadInteger(Seção[c],'Detectar',0);
                ListKeyz[e].Wait := ini.ReadInteger(Seção[c],'Tempo',0) div 10;
                Teclas := ini.ReadString(Seção[c],'Interns','');
                //converte e adiciona as teclas para a lista
                SetLength(ListKeyz[e].Key, Length(Teclas) div 3 );
                for f:=0 to Length(ListKeyz[e].Key)-1 do
                    ListKeyz[e].Key[f] := StrToInt( copy( Teclas, f*3+1, 3) );
            end;//if config
        end;// for

        Ini.Free;
    end;
    Seção.Free;
    Lista.Free;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited;
    //configura a janela para não aparecer na barra e não ativado.
    SetWindowLong(Handle, gwl_exstyle, ws_ex_toolwindow and not Ws_ex_appwindow);
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.FormCreate(Sender: TObject);
begin
    if not DirectoryExists(DirCurrent+'HotKey\') then
       CreateDir(DirCurrent+'HotKey\');
	
	   LtvHotKey.OnColumnClick := PGListView.OnColumnClick;
    LtvHotKey.OnCompare := PGListView.OnCompare;
    LtvHotKey.OnDragDrop := PGListView.OnDragDrop;
    LtvHotKey.OnDragOver := PGListView.OnDragOver;

    IndexD := -1;

    HotKeyUpdate();
    //carrega config
    IniLoadFromFile(Self, LtvHotKey, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.FormShow(Sender: TObject);
begin
    //mostra os arquivos
    PGListView.OnClear(LtvHotKey, True);
    CmbLista.Clear;
    CmbLista.Items.Text :=  FileListDir(DirCurrent+'HotKey\*.ini');
    CmbLista.Items.Insert(0,'"Nova Lista"');
    if CmbLista.Items.Count > 1 then
    begin
        CmbLista.ItemIndex:=1;
        ListViewLoadFromFile(LtvHotKey, DirCurrent+'HotKey\'+CmbLista.Text, -1);
    end else
        CmbLista.ItemIndex:=0;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    if (Arquivo <> '')
    and(MessageDlg('A Lista nao foi salva, deseja salvar?', mtConfirmation, [mbYes, mbNo], mrYes) = mrYes) then
       BtnSalvar.Click
    else
       Arquivo:='';

    //desabilita fechar e oculta
    Action := caNone;
    Hide;

    BtnNovo.Click;
    PGListView.OnClear(LtvHotKey,True);
    LtvHotKey.Checkboxes:=true;
    IniSaveToFile(Self, LtvHotKey, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.BtnNovoClick(Sender: TObject);
begin
    EdtHotKey.Clear;
    CmbDetectar.ItemIndex:=0;
    EdtComando.Clear;
    EdtComentario.Clear;
    CmbDetectar.OnChange(Sender);
    IndexD := -1;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.BtnAddClick(Sender: TObject);
    //------------------------------------------------------------------------//
    function KeyzToStr():string;
    var c:Integer;
    begin
        Result := '';
        for c:=0 to Length(HotKeyD)-1 do
            Result := Result + FormatFloat('000',HotKeyD[c].Key);
    end;
    //------------------------------------------------------------------------//
var Items:TListItem;
begin
    //verifica nome
    if (CmbLista.Text = '') or (CmbLista.ItemIndex = 0) then
       CmbLista.Text := InputBox('De um nome para a Lista','Nome:','');

    if CmbLista.Text <> '' then
    begin
        //adiciona extenção
        if CompareText(ExtractFileExt(CmbLista.Text),'.ini') <> 0 then
           CmbLista.Text := CmbLista.Text+'.ini';

        //adicionar
        if EdtHotKey.Text <> '' then
        begin
            Items:=LtvHotKey.FindCaption(0, FormatFloat('000',IndexD) , false, true, false);
            if Items = nil then
            begin
                Items:=LtvHotKey.Items.Add;
                IndexD:=LtvHotKey.Items.Count-1;
                Items.Checked:=true;
            end;

            Items.Caption:=FormatFloat('000',IndexD);
            Items.SubItems.Clear;
            Items.SubItems.Add(EdtHotKey.Text);
            Items.SubItems.Add(EdtComando.Text);
            Items.SubItems.Add(CmbDetectar.Text);
            if CmbDetectar.ItemIndex = 1 then
               Items.SubItems.Add(EdtTempo.Text)
            else
               Items.SubItems.Add('100');
            Items.SubItems.Add(EdtComentario.Text);
            Items.SubItems.Add(KeyzToStr());
        end;
        BtnNovo.Click;
        Arquivo:=DirCurrent+'HotKey\'+CmbLista.Text;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.LtvHotKeySelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
    //------------------------------------------------------------------------//
    procedure StrToKeyz(Text:string);
    var c :Integer;
    begin
        SetLength(HotKeyD, Length(Text) div 3 );
        for c:=0 to Length(HotKeyD)-1 do
            HotKeyD[c].Key:=StrToInt( copy(Text, c*3+1, 3)) ;
    end;
    //------------------------------------------------------------------------//
begin
    //selecione link
    IndexD:=StrToInt(Item.Caption);
    EdtHotKey.Text:=Item.SubItems[0];
    EdtComando.Text:=Item.SubItems[1];
    try
        CmbDetectar.ItemIndex:=StrToInt(Item.SubItems[2][1]);
    except
        CmbDetectar.ItemIndex:=0;
    end;
    if Item.SubItems[3] = '' then
       EdtTempo.Text:='100'
    else
       EdtTempo.Text:=Item.SubItems[3];
    EdtComentario.Text:=Item.SubItems[4];
    StrToKeyz(Item.SubItems[5]);
    CmbDetectar.OnChange(Sender);
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.Detalhes1Click(Sender: TObject);
begin
    LtvHotKey.ViewStyle:=TViewStyle(TMenuItem(Sender).tag);
    Arquivo:=DirCurrent+'HotKey\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.Deletar1Click(Sender: TObject);
var c:integer;
begin
    //deleta selecionados
    for c:=LtvHotKey.Items.Count-1 downto 0 do
        if LtvHotKey.Items[c].Selected then
           LtvHotKey.Items[c].Delete;
    BtnNovo.Click;
    Arquivo:=DirCurrent+'HotKey\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.Deletar2Click(Sender: TObject);
var c:integer;
begin
    //deleta marcas
    for c:=LtvHotKey.Items.Count-1 downto 0 do
        if LtvHotKey.Items[c].Checked then
           LtvHotKey.Items[c].Delete;
    BtnNovo.Click;
    Arquivo:=DirCurrent+'HotKey\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.Deletar3Click(Sender: TObject);
begin
    //deleta lista
    if DeleteFile(DirCurrent+'HotKey\'+CmbLista.Text) then
    begin
        ShowMessage('Lista deletada.');
        PGListView.OnClear(LtvHotKey,True);
        LtvHotKey.Checkboxes:=true;
    end else
        ShowMessage('Erro ao deletar a lista.');
    Arquivo:='';
    BtnNovo.Click;
    HotKeyUpdate();
    //atualiza a lista
    OnShow(nil);
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.MarcarTudo1Click(Sender: TObject);
var c:integer;
begin
    //marcar tudo
    for c:=0 to LtvHotKey.Items.Count-1 do
        LtvHotKey.Items[c].Checked:=true;

    Arquivo:=DirCurrent+'HotKey\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.DesmarcarTudo1Click(Sender: TObject);
var c:integer;
begin
    //desmarcar tudo
    for c:=0 to LtvHotKey.Items.Count-1 do
        LtvHotKey.Items[c].Checked:=false;

    Arquivo:=DirCurrent+'HotKey\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.InverterMarcas1Click(Sender: TObject);
var c:integer;
begin
    //inverter marcas
    for c:=0 to LtvHotKey.Items.Count-1 do
        LtvHotKey.Items[c].Checked:=not LtvHotKey.Items[c].Checked;

    Arquivo:=DirCurrent+'HotKey\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.CmbListaClick(Sender: TObject);
begin
    if (Arquivo <> '')
    and(MessageDlg('A Lista nao foi salva, deseja salvar?', mtConfirmation, [mbYes, mbNo], mrYes) = mrYes) then
       BtnSalvar.Click
    else
       Arquivo:='';

    BtnNovo.Click;
    //carrega a lista selecionada
    if CmbLista.ItemIndex = 0 then
    begin
        //nova lista
        PGListView.OnClear(LtvHotKey, True);
        LtvHotKey.Checkboxes:=true;
        arquivo := InputBox('De um nome para a Lista','Nome:','');
        if arquivo <> '' then
        begin
            if CompareText(ExtractFileExt(arquivo),'.ini') <> 0 then
               arquivo:=arquivo+'.ini';
            CmbLista.Items.Add(arquivo);
            CmbLista.ItemIndex:=CmbLista.Items.Capacity-1;
        end;
    end else begin
        PGListView.OnClear(LtvHotKey, True);
        LtvHotKey.Checkboxes:=true;
        ListViewLoadFromFile(LtvHotKey, DirCurrent+'HotKey\'+CmbLista.Text, -1);
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.BtnTesteClick(Sender: TObject);
begin
     SendScript(EdtComando.Text);
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.BtnSalvarClick(Sender: TObject);
var c:integer;
begin
   if EdtHotKey.Text <> '' then
      BtnAdd.Click;

    if Arquivo = '' then
       Arquivo:=DirCurrent+'HotKey\'+CmbLista.Text;

    for c:=0 to LtvHotKey.Items.Count-1 do
        LtvHotKey.Items[c].Caption:=FormatFloat('000',c);

    BtnNovo.Click;
    ListViewSaveToFile(LtvHotKey, Arquivo, true);
    HotKeyUpdate();
    Arquivo:='';
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.CmbDetectarChange(Sender: TObject);
begin
     LblTempo.Enabled := (CmbDetectar.ItemIndex = 1);
     LblTempMs.Enabled := LblTempo.Enabled;
     EdtTempo.Enabled := LblTempo.Enabled;
     UpdTempo.Enabled := LblTempo.Enabled;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.TmrHotKeyZTimer(Sender: TObject);
var c:Byte;
    d:SmallInt;
    //-----------------------------------------------------------------------//
    procedure InsertHotKey;
    var l,p:Byte;
    begin
        l:=Length(HotKeyz);
        p:=0;
        while (p < l) and (HotKeyz[p].Key <> c) do
            inc(p);

        if (p = l) then
        begin
            SetLength(HotKeyz, l+1);
            p:=l;
            HotKeyz[p].Key:=c;
        end;

        if HotKeyz[p].Down then
           HotKeyz[p].Press:=true
        else
           HotKeyz[p].Down:=true;
    end;
    //-----------------------------------------------------------------------//
    procedure DeleteHotKey;
    var l,p:Integer;
    begin
        l:=Length(HotKeyz);
        if l > 0 then
        begin
            p:=0;
            while (p < l) and (HotKeyz[p].Key <> c) do
                inc(p);

            if (p < l) and (HotKeyz[p].Key = c) then
            begin
                if HotKeyz[p].Press then
                begin
                    HotKeyz[p].Down:=false;
                    HotKeyz[p].Press:=false;
                end else begin
                    for p:=p to l-2 do
                       HotKeyz[p]:=HotKeyz[p+1];
                    SetLength(HotKeyz, l-1);
                end;
            end;//if d < c
        end;//if c > 0
    end;
    //-----------------------------------------------------------------------//
    procedure FindListHotKey;
    var l, p : Word;
        k, y : Byte;
    begin
        l := Length(ListKeyz);
        k := Length(HotKeyz);
        //varre lista
        if (l > 0) then
        for p:=0 to l-1 do
        begin
           //verifica se a lista é igual a keyz
           if k = Length(ListKeyz[p].Key) then
           begin
               y:=0;
               while (y < k) and (ListKeyz[p].Key[y] = HotKeyz[y].Key) do
                   inc(y);

               //se for igual
               if (y = k) then
               begin
                   case ListKeyz[p].Detect of
                       0 : begin
                               if (HotKeyz[y-1].Down) and (not HotKeyz[y-1].Press) then
                                  SendScript(ListKeyz[p].Command);
                           end;// 0 precionar
                       1 : begin
                               if (HotKeyz[y-1].Press) then
                               begin
                                  // teste ... EdtCommand.Text := IntToStr( ListKeyz[p].Count );
                                  if ListKeyz[p].Count > ListKeyz[p].Wait then
                                  begin
                                     SendScript(ListKeyz[p].Command);
                                     ListKeyz[p].Count := 0;
                                  end;
                                  ListKeyz[p].Count := ListKeyz[p].Count+TmrHotKeyZ.Interval;
                               end;

                           end;//1 precionado
                       2 : begin
                               if (not HotKeyz[y-1].Down) and (not HotKeyz[y-1].Press) then
                                  SendScript(ListKeyz[p].Command);
                           end;//2 soltar
                   end;
               end else
                   ListKeyz[p].Count := 0;
           end; //if length = length
        end;//for
    end;
    //-----------------------------------------------------------------------//
begin
   // Result:= GetAsyncKeyState(VK_KEY);
   // if result = 0      then Status nulo
   // if result = -32767 then Status modificado ou repetindo
   // if result = -32768 then Status mantido
   try
       if (not TimerLost) then
       begin
           TimerLost:=true;

           if TmrHotKeyZ.Interval > 1 then
              TmrHotKeyZ.Interval:=TmrHotKeyZ.Interval-1;

           for c:=1 to 254 do
           begin
               if not (c in [VK_SHIFT, VK_CONTROL, VK_MENU]) then
               begin
                   d := GetAsyncKeyState(c);
                   case d of
                        -32768..-32767: InsertHotKey;
                             0: DeleteHotKey;
                   end;//case
               end;
           end;//for;

           if not FrmHotKeys.EdtHotKey.Focused then
              FindListHotKey;

       end else begin
           if TmrHotKeyZ.Interval < 100 then
              TmrHotKeyZ.Interval := TmrHotKeyZ.Interval + 1;
       end;
       TimerLost:=false;
   except

   end;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.TmrHotKeyDTimer(Sender: TObject);
var
    z, d, c : integer;
    Igual : Boolean;
begin
    z := Length(HotKeyZ);
    d := Length(HotKeyD);
    Igual := False;

    if z <= d then
    begin
        c:=0;
        while (c < z) and (HotKeyZ[c].Key =  HotKeyD[c].Key) do
            inc(c);
        if c >= z then
           Igual := True;
    end;

    if (not Igual) and (z > 0) then
    begin
        SetLength(HotKeyD,z);
        EdtHotKey.Text := KeyVirtualToStr(HotKeyz[0].Key);
        HotKeyD[0].Key := HotKeyz[0].Key;

        for c:=1 to z-1 do
        begin
            HotKeyD[c].Key := HotKeyz[c].Key;
            EdtHotKey.Text := EdtHotKey.Text + ' + ' + KeyVirtualToStr(HotKeyz[c].Key);
        end;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.EdtHotKeyEnter(Sender: TObject);
begin
    TmrHotKeyD.Enabled := True;
end;
//----------------------------------------------------------------------------//
procedure TFrmHotKeys.EdtHotKeyExit(Sender: TObject);
begin
    TmrHotKeyD.Enabled := False;
end;

end.
