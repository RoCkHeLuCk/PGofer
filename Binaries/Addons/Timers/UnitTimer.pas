unit UnitTimer;

interface

uses
     Vcl.Forms, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Menus,
     Vcl.ComCtrls, Vcl.Controls, Vcl.CheckLst, Vcl.Dialogs,
     Winapi.Messages, Winapi.Windows,
     System.Classes, System.IniFiles, System.DateUtils, System.SysUtils, system.UITypes,
     SynEdit;

type

//lista do Timer
  TListTimer = Record
      Index : Word;
       Exec : Byte;
    CkbHora : Boolean;
       Hora : TTime;
    CkbData : Boolean;
       Data : TDate;
       Rptr : Word;
       List : Array of Boolean;
    Command : String;
       Last : TDateTime;
     replic : Word;
        dir : String;
  end;

  TFrmTimers = class(TForm)
    GrbTimer: TGroupBox;
    LblValor: TLabel;
    LblComentario: TLabel;
    LblLista: TLabel;
    BtnValor: TBitBtn;
    BtnNovo: TBitBtn;
    BtnAdd: TBitBtn;
    EdtComentario: TEdit;
    EdtComando: TSynEdit;
    CmbLista: TComboBox;
    BtnSalvar: TBitBtn;
    GrbLista: TGroupBox;
    LtvTimer: TListView;
    PpmTimer: TPopupMenu;
    Marcar1: TMenuItem;
    MarcarTudo1: TMenuItem;
    DesmarcarTudo1: TMenuItem;
    InverterMarcas1: TMenuItem;
    Mostrar1: TMenuItem;
    Icones1: TMenuItem;
    IconesPequenos1: TMenuItem;
    Lista1: TMenuItem;
    Detalhes1: TMenuItem;
    N1: TMenuItem;
    Deletar1: TMenuItem;
    Deletar2: TMenuItem;
    Deletar3: TMenuItem;
    GrpExecutar: TRadioGroup;
    GrpAgenda: TGroupBox;
    CkbHora: TCheckBox;
    LblHora: TLabel;
    LblRepetir: TLabel;
    EdtRepetir: TEdit;
    UpdRepetir: TUpDown;
    GrpLista: TGroupBox;
    CkbData: TCheckBox;
    LblData: TLabel;
    EdtData: TEdit;
    EdtHora: TEdit;
    ClbLista: TCheckListBox;
    AtualizarLista1: TMenuItem;
    TmrTimer: TTimer;
    procedure GrpExecutarClick(Sender: TObject);
    procedure CkbHoraClick(Sender: TObject);
    procedure CkbDataClick(Sender: TObject);
    procedure BtnValorClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnNovoClick(Sender: TObject);
    procedure EdtHoraKeyPress(Sender: TObject; var Key: Char);
    procedure EdtDataKeyPress(Sender: TObject; var Key: Char);
    procedure BtnAddClick(Sender: TObject);
    procedure CmbListaClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure LtvTimerSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Detalhes1Click(Sender: TObject);
    procedure Deletar1Click(Sender: TObject);
    procedure Deletar2Click(Sender: TObject);
    procedure Deletar3Click(Sender: TObject);
    procedure MarcarTudo1Click(Sender: TObject);
    procedure DesmarcarTudo1Click(Sender: TObject);
    procedure InverterMarcas1Click(Sender: TObject);
    procedure AtualizarLista1Click(Sender: TObject);
    procedure TmrTimerTimer(Sender: TObject);
  private
    { Private declarations }
    ListTimer : Array of TListTimer;
    IndexD : Integer;
    Arquivo :String;
    procedure UpdateTimer();
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
  end;

var
  FrmTimers: TFrmTimers;

implementation
{$R *.dfm}

uses PGofer.Files, PGofer.ListView, PGofer.Controls;


//---------------------------------------------------------------------------//
procedure TFrmTimers.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.UpdateTimer();
var
    Lista, Seção : TStringList;
    Ini : TIniFile;
    c,d,e,f : Integer;
    Marcador : String;
begin
    SetLength(ListTimer, 0);
    Lista := TStringList.Create;
    Seção := TStringList.Create;
    Lista.Text := FileListDir(DirCurrent+'Timer\*.ini');
    for d := 0 to Lista.Count-1 do
    begin
        Ini := TIniFile.Create( DirCurrent+'Timer\'+ Lista[d] );
        Ini.ReadSections(Seção);
        //Varre lista de Seçoes
        for c:=0 to Seção.Count-1 do
        begin
            if (SameText(Seção[c],'Config')) and (ini.ReadBool(Seção[c],'Check',False)) then
            begin
                e := Length( ListTimer );
                SetLength(ListTimer, e+1);
                ListTimer[e].Index :=  StrToInt(Seção[c]);
                ListTimer[e].Command := ini.ReadString(Seção[c],'Comando','');

                try
                   ListTimer[e].Exec := StrToInt(ini.ReadString(Seção[c],'Executar','0')[1]);
                except end;

                ListTimer[e].Hora := ini.ReadTime(Seção[c],'Hora',0);
                ListTimer[e].CkbHora := ListTimer[e].Hora <> 0;

                ListTimer[e].Data := ini.ReadDate(Seção[c],'Data',0);
                ListTimer[e].CkbData := ListTimer[e].Data <> 0;
                ListTimer[e].Rptr := ini.ReadInteger(Seção[c],'Repetir',0);

                Marcador := ini.ReadString(Seção[c],'Marcador','');
                //converte e adiciona as lista
                if Marcador <> '' then
                begin
                     SetLength(ListTimer[e].List, Length(Marcador) );
                     for f := 0 to Length(ListTimer[e].List)-1 do
                         ListTimer[e].List[f] := ( copy(Marcador, f+1, 1) = '1' );
                end;

               ListTimer[e].Last := ini.ReadDateTime(Seção[c],'Ultimo',0);
               ListTimer[e].replic := ini.ReadInteger(Seção[c],'Repetições',0);

               //pegar o arquivo origem.
               ListTimer[e].dir := Lista[d];
            end;//if config
        end;// for

        Ini.Free;
    end;
    Seção.Free;
    Lista.Free;
    TmrTimer.Enabled:=(Length(ListTimer) > 0);
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited;
    //configura a janela para não aparecer na barra e não ativado.
    SetWindowLong(Handle, gwl_exstyle, ws_ex_toolwindow and not Ws_ex_appwindow);
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.FormCreate(Sender: TObject);
begin
    if not DirectoryExists(DirCurrent+'Timer\') then
       CreateDir(DirCurrent+'Timer\');
    LtvTimer.OnColumnClick := PGListView.OnColumnClick;
    LtvTimer.OnCompare := PGListView.OnCompare;
    LtvTimer.OnDragDrop := PGListView.OnDragDrop;
    LtvTimer.OnDragOver := PGListView.OnDragOver;

    IndexD:=-1;
    //carrega config
    IniLoadFromFile(Self, LtvTimer, DirCurrent+'Config.ini');

    UpdateTimer();
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.FormShow(Sender: TObject);
begin
    //mostra os arquivos
    PGListView.OnClear(LtvTimer, True);
    CmbLista.Clear;
    CmbLista.Items.Text :=  FileListDir(DirCurrent+'Timer\*.ini');
    CmbLista.Items.Insert(0,'"Nova Lista"');
    if CmbLista.Items.Count > 1 then
       begin
           CmbLista.ItemIndex:=1;
           ListViewLoadFromFile(LtvTimer, DirCurrent+'Timer\'+CmbLista.Text, 3);
       end else CmbLista.ItemIndex:=0;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.FormClose(Sender: TObject; var Action: TCloseAction);
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
    PGListView.OnClear(LtvTimer, True);
    //salva o config
    IniSaveToFile(Self, LtvTimer, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.BtnNovoClick(Sender: TObject);
begin
    EdtHora.Text:='00:00:00';
    EdtData.Text:='00/00/0000';
    UpdRepetir.Position:=0;
    GrpExecutar.ItemIndex:=0;
    EdtComando.Clear;
    EdtComentario.Clear;
    IndexD:=-1;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.GrpExecutarClick(Sender: TObject);
var c:integer;
begin
    case GrpExecutar.ItemIndex of
        0,1: begin
              ClbLista.Enabled:=false;
              ClbLista.Clear;
              CkbData.Checked:=true;
              CkbData.Enabled:=true;
              LblData.Enabled:=true;
              EdtData.Enabled:=true;
           end;// 0,1
       2..4: begin
              ClbLista.Enabled:=true;
              ClbLista.Clear;
              CkbData.Checked:=false;
              CkbData.Enabled:=false;
              LblData.Enabled:=false;
              EdtData.Enabled:=false;
              case GrpExecutar.ItemIndex of
                  2: begin
                         for c:=1 to 31 do
                            ClbLista.Items.Add( FormatFloat('00', c) );
                      end;
                  3: begin
                        ClbLista.Items.Add( 'Segunda' );
                        ClbLista.Items.Add( 'Terça' );
                        ClbLista.Items.Add( 'Quarta' );
                        ClbLista.Items.Add( 'Quinta' );
                        ClbLista.Items.Add( 'Sexta' );
                        ClbLista.Items.Add( 'Sabado' );
                        ClbLista.Items.Add( 'Domingo' );
                     end;
                  4: begin
                        ClbLista.Items.Add( 'Janeiro' );
                        ClbLista.Items.Add( 'Fevereiro' );
                        ClbLista.Items.Add( 'Março' );
                        ClbLista.Items.Add( 'Abril' );
                        ClbLista.Items.Add( 'Maio' );
                        ClbLista.Items.Add( 'Junho' );
                        ClbLista.Items.Add( 'Julho' );
                        ClbLista.Items.Add( 'Agosto' );
                        ClbLista.Items.Add( 'Setembro' );
                        ClbLista.Items.Add( 'Outubro' );
                        ClbLista.Items.Add( 'Novembro' );
                        ClbLista.Items.Add( 'Dezembro' );
                     end;
              end; //case case 2..4
           end;//2..4
    end;//case
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.CkbHoraClick(Sender: TObject);
begin
   LblHora.Enabled:=CkbHora.Checked;
   EdtHora.Enabled:=CkbHora.Checked;
   if (GrpExecutar.ItemIndex < 2)
   and(not CkbHora.Checked) then
      CkbData.Checked:=true;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.CkbDataClick(Sender: TObject);
begin
   LblData.Enabled:=CkbData.Checked;
   EdtData.Enabled:=CkbData.Checked;
   if (GrpExecutar.ItemIndex < 2)
   and(not CkbData.Checked) then
      CkbHora.Checked:=true;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.BtnValorClick(Sender: TObject);
begin
    SendScript(EdtComando.Text);
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.EdtHoraKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #8 then
       begin
           EdtHora.SelStart:=EdtHora.SelStart-1;
           EdtHora.SelLength:=1;
           if EdtHora.SelStart in[2,5] then
              EdtHora.SelText:=':'
           else
              EdtHora.SelText:='0';
           Key:=#0;
           EdtHora.SelStart:=EdtHora.SelStart-1;
       end
    else
    if EdtHora.SelStart > 7 then
       Key := #0
    else
    if EdtHora.SelStart in[2,5] then
       begin
           if CharInSet(Key,['0'..'9']) then
              begin
                 EdtHora.SelStart:=EdtHora.SelStart+1;
              end else
                 Key := ':';
           EdtHora.SelLength:=1;
       end
    else
    if not CharInSet(Key,['0'..'9']) then
       Key := #0
    else
       EdtHora.SelLength:=1;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.EdtDataKeyPress(Sender: TObject; var Key: Char);
begin
    //mask EdtData
    if Key = #8 then
       begin
           EdtData.SelStart:=EdtData.SelStart-1;
           EdtData.SelLength:=1;
           if EdtData.SelStart in[2,5] then
              EdtData.SelText:='/'
           else
              EdtData.SelText:='0';
           Key:=#0;
           EdtData.SelStart:=EdtData.SelStart-1;
       end
    else
    if EdtData.SelStart > 9 then
       Key := #0
    else
    if EdtData.SelStart in[2,5] then
       begin
           if CharInSet(Key,['0'..'9']) then
              begin
                 EdtData.SelStart:=EdtData.SelStart+1;
              end else
                 Key := ':';
           EdtData.SelLength:=1;
       end
    else
    if not CharInSet(Key,['0'..'9']) then
       Key := #0
    else
       EdtData.SelLength:=1;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.BtnAddClick(Sender: TObject);
    //------------------------------------------------------------------------//
    function ListToStr():string;
    var c:Integer;
    begin
        Result := '';
        for c:=0 to ClbLista.Items.Count-1 do
            Result := Result + BoolToStr(ClbLista.Checked[c]);
    end;
    //------------------------------------------------------------------------//
    function ValidateDateTime():Boolean;
    var Tempo:TDateTime;
        DD, MM, YY:Word;
    begin
        Result:=true;
        //validar hora
        if CkbHora.Checked then
        if (not TryStrToTime(EdtHora.Text,Tempo))
        or ((GrpExecutar.ItemIndex = 0)
        and (Tempo = 0)) then
           begin
               Result:=false;
               ShowMessage('Erro: Hora Invalida.');
           end;

         DD:=StrToInt(copy(EdtData.Text,1,2));
         MM:=StrToInt(copy(EdtData.Text,4,2));
         YY:=StrToInt(copy(EdtData.Text,7,4));

        //validar Data
        if CkbData.Checked then
        if ((GrpExecutar.ItemIndex = 0)
        and(TryEncodeDate(yy+1899,mm+12,dd+30, Tempo))
        and(Tempo =0))
        or ((GrpExecutar.ItemIndex <> 0)
        and(not TryEncodeDate(yy,mm,dd, Tempo))) then
           begin
               Result:=false;
               ShowMessage('Erro: Data Invalida.');
           end;
    end;
    //------------------------------------------------------------------------//
var Items:TListItem;
    Ultima :String;
begin
    //verifica nome
    if (CmbLista.Text = '') or (CmbLista.ItemIndex = 0) then
       CmbLista.Text:=InputBox('De um nome para a Lista','Nome:','');

    if CmbLista.Text <> '' then
       begin
           //adiciona extenção
           if CompareText(ExtractFileExt(CmbLista.Text),'.ini') <> 0 then
              CmbLista.Text:=CmbLista.Text+'.ini';

           //adicionar
           if (EdtComando.Text <> '')and( ValidateDateTime()) then
              begin
                  Items:=LtvTimer.FindCaption(0, FormatFloat('000',IndexD) , false, true, false);
                  if Items = nil then
                     begin
                         Items:=LtvTimer.Items.Add;
                         IndexD:=LtvTimer.Items.Count-1;
                         Items.Checked:=true;
                         Ultima :=  DateTimeToStr( Time + Date);
                     end else
                         Ultima := Items.SubItems[6];

                  Items.Caption:=FormatFloat('000',IndexD);
                  Items.SubItems.Clear;
                  Items.SubItems.Add( IntToStr(GrpExecutar.ItemIndex) + ' = ' +GrpExecutar.Items[GrpExecutar.ItemIndex] );

                  if CkbHora.Checked then
                     Items.SubItems.Add( EdtHora.Text )
                  else
                     Items.SubItems.Add('');

                  if CkbData.Checked then
                     Items.SubItems.Add( EdtData.Text )
                  else
                     Items.SubItems.Add('');


                  Items.SubItems.Add( IntToStr(UpdRepetir.Position) );
                  Items.SubItems.Add(ListToStr());
                  Items.SubItems.Add(EdtComando.Text);
                  Items.SubItems.Add(Ultima);
                  Items.SubItems.Add('0');
                  Items.SubItems.Add(EdtComentario.Text);

                  BtnNovo.Click;
                  Arquivo:=DirCurrent+'Timer\'+CmbLista.Text;
                  CmbLista.Items.Text :=  FileListDir(DirCurrent+'Timer\*.ini');
              end; //if EdtComando.text <> ''
       end;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.CmbListaClick(Sender: TObject);
begin
    if (Arquivo <> '')
    and(MessageDlg('A Lista nao foi salva, deseja salvar?', mtConfirmation, [mbYes, mbNo], mrYes) = mrYes) then
       BtnSalvar.Click
    else
       Arquivo:='';

    //carrega a lista selecionada
    if CmbLista.ItemIndex = 0 then
       begin
           //nova lista
           PGListView.OnClear(LtvTimer, True);
           LtvTimer.Checkboxes:=true;
           arquivo := InputBox('De um nome para a Lista','Nome:','');
           if arquivo <> '' then
              begin
                  if CompareText(ExtractFileExt(arquivo),'.ini') <> 0 then
                     arquivo:=arquivo+'.ini';
                  CmbLista.Items.Add(arquivo);
                  CmbLista.ItemIndex:=CmbLista.Items.Capacity-1;
              end;
       end else begin
            PGListView.OnClear(LtvTimer);
            ListViewLoadFromFile(LtvTimer, DirCurrent+'Timer\'+CmbLista.Text, 3);
            AtualizarLista1.Click;
       end;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.BtnSalvarClick(Sender: TObject);
var c:integer;
    texto : String;
begin
   if EdtComando.Text <> '' then
      BtnAdd.Click;

    if Arquivo = '' then
       Arquivo:=DirCurrent+'Timer\'+CmbLista.Text;

    for c:=0 to LtvTimer.Items.Count-1 do
        LtvTimer.Items[c].Caption:=FormatFloat('000',c);

    BtnNovo.Click;
    ListViewSaveToFile(LtvTimer, Arquivo, false);
    texto := CmbLista.Text;
    CmbLista.Clear;
    CmbLista.Items.Text :=  FileListDir(DirCurrent+'Timer\*.ini');
    CmbLista.Items.Insert(0,'"Nova Lista"');
    CmbLista.Text := texto;
    Arquivo:='';
    UpdateTimer();
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.LtvTimerSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
    //------------------------------------------------------------------------//
    procedure StrToList(Text:string);
    var c:Integer;
    begin
       if Length(Text) = ClbLista.Items.Count then
          for c:=0 to ClbLista.Items.Count-1 do
              ClbLista.Checked[c]:=(Text[c+1] = '1');
    end;
    //------------------------------------------------------------------------//
begin
    //selecione link
    IndexD:=StrToInt(Item.Caption);
    try
       GrpExecutar.ItemIndex:=StrToInt(Item.SubItems[0][1]);
    except
       GrpExecutar.ItemIndex:=0;
    end;

    if Item.SubItems[1] <> '' then
       begin
          CkbHora.Checked:=true;
          EdtHora.Text:=Item.SubItems[1];
       end else begin
          CkbHora.Checked:=false;
          EdtHora.Text:='00:00:00';
       end;

    if Item.SubItems[2] <> '' then
       begin
          CkbData.Checked:=true;
          EdtData.Text:=Item.SubItems[2];
       end else begin
          CkbData.Checked:=false;
          EdtData.Text:='00/00/0000';
       end;

    try
       UpdRepetir.Position:=StrToInt(Item.SubItems[3]);
    except
       UpdRepetir.Position:=0;
    end;

    StrToList(Item.SubItems[4]);
    EdtComando.Text:=Item.SubItems[5];
    EdtComentario.Text:=Item.SubItems[8];
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.Detalhes1Click(Sender: TObject);
begin
    LtvTimer.ViewStyle:=TViewStyle(TMenuItem(Sender).tag);
    Arquivo:=DirCurrent+'Timer\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.Deletar1Click(Sender: TObject);
var c:integer;
begin
    //deleta selecionados
    for c:=LtvTimer.Items.Count-1 downto 0 do
        if LtvTimer.Items[c].Selected then
           LtvTimer.Items[c].Delete;
    BtnNovo.Click;
    Arquivo:=DirCurrent+'Timer\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.Deletar2Click(Sender: TObject);
var c:integer;
begin
    //deleta marcas
    for c:=LtvTimer.Items.Count-1 downto 0 do
        if LtvTimer.Items[c].Checked then
           LtvTimer.Items[c].Delete;
    BtnNovo.Click;
    Arquivo:=DirCurrent+'Timer\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.Deletar3Click(Sender: TObject);
begin
    //deleta lista
    if DeleteFile(DirCurrent+'Timer\'+CmbLista.Text) then
       begin
           ShowMessage('Lista deletada.');
           PGListView.OnClear(LtvTimer, True);
           LtvTimer.Checkboxes:=true;
       end else
           ShowMessage('Erro ao deletar a lista.');
    Arquivo:='';
    BtnNovo.Click;
    UpdateTimer();
    //atualiza a lista
    OnShow(nil);
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.MarcarTudo1Click(Sender: TObject);
var c:integer;
begin
    //marcar tudo
    for c:=0 to LtvTimer.Items.Count-1 do
        LtvTimer.Items[c].Checked:=true;

    Arquivo:=DirCurrent+'Timer\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.DesmarcarTudo1Click(Sender: TObject);
var c:integer;
begin
    //desmarcar tudo
    for c:=0 to LtvTimer.Items.Count-1 do
        LtvTimer.Items[c].Checked:=false;

    Arquivo:=DirCurrent+'Timer\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.InverterMarcas1Click(Sender: TObject);
var c:integer;
begin
    //inverter marcas
    for c:=0 to LtvTimer.Items.Count-1 do
        LtvTimer.Items[c].Checked:=not LtvTimer.Items[c].Checked;

    Arquivo:=DirCurrent+'Timer\'+CmbLista.Text;
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.AtualizarLista1Click(Sender: TObject);
begin
   PGListView.OnClear(LtvTimer, True);
   LtvTimer.Checkboxes:=true;
   ListViewLoadFromFile(LtvTimer, DirCurrent+'Timer\'+CmbLista.Text, -1);
end;
//----------------------------------------------------------------------------//
procedure TFrmTimers.TmrTimerTimer(Sender: TObject);
var c : integer;
    yy,mm,dd:word;
    //------------------------------------------------------------------------//
    procedure ExecTimer();
    var  ini : TIniFile;
    begin
         if (ListTimer[c].Rptr = 0) or (ListTimer[c].replic < ListTimer[c].Rptr) then
            begin
               ListTimer[c].Last:=Time+Date+0.00002;
               ListTimer[c].replic:=ListTimer[c].replic+1;
               ini:=TIniFile.Create(ListTimer[c].dir);
               ini.WriteString(FormatFloat('000',ListTimer[c].Index),'Ultimo', DateTimeToStr(ListTimer[c].Last));
               ini.WriteInteger(FormatFloat('000',ListTimer[c].Index),'Repetições', ListTimer[c].replic);
               ini.Free;
               Sleep(1000);
               SendScript(ListTimer[c].Command);
            end;//if repetir
    end;//exectimer
   //-------------------------------------------------------------------------//
   function TimeNow( ):Boolean;
   begin
       result:= (  (ListTimer[c].Hora >= Time-0.0000116)
                 and(ListTimer[c].Hora <= Time+0.0000116)
                 and(ListTimer[c].Last < Time+Date)       );
   end;
   //-------------------------------------------------------------------------//
begin
   // Agendador - timer
   try
       for c:=0 to Length(ListTimer)-1 do
          begin
              case ListTimer[c].Exec of
                  0 : begin //Tempos
                          if (((Time+Date) - ListTimer[c].Last) >= ListTimer[c].Hora+ListTimer[c].Data) then
                             begin
                                 ExecTimer();
                             end;
                      end;//0
                  1 : begin //Data e Hora
                          if (ListTimer[c].CkbHora)and(ListTimer[c].CkbData) then
                             begin
                                if (ListTimer[c].Hora+ListTimer[c].Data >= Date+Time-0.0000116)
                                and(ListTimer[c].Hora+ListTimer[c].Data <= Date+Time+0.0000116) then
                                   ExecTimer();
                             end else
                                if((ListTimer[c].CkbHora)and(TimeNow()))
                                or((ListTimer[c].CkbData)and(Date = ListTimer[c].Data)
                                   and(Date <> StrToDate(DateToStr(ListTimer[c].Last)))) then
                                   ExecTimer();
                      end;//1
                  2 : begin //Dias do mes
                          if (Length(ListTimer[c].List) = 31)
                          and(ListTimer[c].List[StrToInt(FormatDateTime('dd',Date))-1])
                          and(Date <> StrToDate(DateToStr(ListTimer[c].Last))) then
                             begin
                                if (ListTimer[c].CkbHora) then
                                   begin
                                      if TimeNow() then
                                         ExecTimer();
                                   end else
                                      ExecTimer();
                             end;//if list dia
                      end;//2
                  3 : begin //Dia da semana
                          DecodeDateWeek(Date,yy,mm,dd);
                          if (Length(ListTimer[c].List) = 7)
                          and(ListTimer[c].List[dd-1])
                          and(Date <> StrToDate(DateToStr(ListTimer[c].Last))) then
                             begin
                                if (ListTimer[c].CkbHora) then
                                   begin
                                      if TimeNow() then
                                         ExecTimer();
                                   end else
                                      ExecTimer();
                             end;//if list dia
                      end;//2
                  4 : begin //Mes
                          if (Length(ListTimer[c].List) = 12)
                          and(ListTimer[c].List[StrToInt(FormatDateTime('mm',Date))-1])
                          and(FormatDateTime('mmyyyy',date) <> FormatDateTime('mmyyyy',ListTimer[c].Last) ) then
                             begin
                                if (ListTimer[c].CkbHora) then
                                   begin
                                      if TimeNow() then
                                         ExecTimer();
                                   end else
                                      ExecTimer();
                             end;//if list dia
                      end;//2

              end;//case
          end;//for
   except

   end;
end;
//----------------------------------------------------------------------------//


end.
