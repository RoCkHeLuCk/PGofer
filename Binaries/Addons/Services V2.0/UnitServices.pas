unit UnitServices;

interface

uses
    Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ImgList, Vcl.Controls, Vcl.StdCtrls,
    Vcl.Buttons, Vcl.ComCtrls, Vcl.CheckLst, Vcl.ExtCtrls,
    Winapi.Messages, Winapi.Winsvc, Winapi.Windows,
    System.Classes, System.SysUtils, System.ImageList, System.UITypes,
    System.IniFiles;

type
  TFrmServices = class(TForm)
    GrbFiltro: TGroupBox;
    GrbLista: TGroupBox;
    ImlServices: TImageList;
    PpmServices: TPopupMenu;
    LtvServices: TListView;
    GrbTipo: TGroupBox;
    ClbTipo: TCheckListBox;
    GrbConfig: TGroupBox;
    ClbConfig: TCheckListBox;
    GrbStatus: TGroupBox;
    ClbStatus: TCheckListBox;
    GrbAcesso: TGroupBox;
    ClbAcesso: TCheckListBox;
    MniMostrar: TMenuItem;
    MniIcones: TMenuItem;
    MniIconesPequenos: TMenuItem;
    MniLista: TMenuItem;
    MniDetalhes: TMenuItem;
    MniAtualizar: TMenuItem;
    MniConfigurao: TMenuItem;
    MniBootAutomatico: TMenuItem;
    MniSistemaAutomatico: TMenuItem;
    MniLoginAutomatico: TMenuItem;
    MniManual: TMenuItem;
    MniDesabilitado: TMenuItem;
    MniIniciar: TMenuItem;
    MniParar: TMenuItem;
    MniPausar: TMenuItem;
    MniN1: TMenuItem;
    MniGerarScript: TMenuItem;
    MniN2: TMenuItem;
    MniConectar: TMenuItem;
    MniDeletar: TMenuItem;
    MniN3: TMenuItem;
    MniSelecionarTudo: TMenuItem;
    MniCopiarValor: TMenuItem;
    MniNome: TMenuItem;
    MinNomeInterno: TMenuItem;
    MniProcurar: TMenuItem;
    MniEstado: TMenuItem;
    SdgServices: TSaveDialog;
    GrbDercricao: TGroupBox;
    Splitter1: TSplitter;
    MemDescricao: TMemo;
    StbSercive: TStatusBar;
    Splitter2: TSplitter;
    GrbProcurar: TGroupBox;
    LblPalavra: TLabel;
    EdtProcurar: TEdit;
    BtnDown: TSpeedButton;
    CbxProcurar: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MniAtualizarClick(Sender: TObject);
    procedure MniIconesClick(Sender: TObject);
    procedure MniBootAutomaticoClick(Sender: TObject);
    procedure MniIniciarClick(Sender: TObject);
    procedure MniGerarScriptClick(Sender: TObject);
    procedure LtvServicesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure MniConectarClick(Sender: TObject);
    procedure MniDeletarClick(Sender: TObject);
    procedure MniSelecionarTudoClick(Sender: TObject);
    procedure MniNomeClick(Sender: TObject);
    procedure MinNomeInternoClick(Sender: TObject);
    procedure MniProcurarClick(Sender: TObject);
    procedure BtnDownClick(Sender: TObject);
    procedure EdtProcurarKeyPress(Sender: TObject; var Key: Char);
    procedure PpmServicesPopup(Sender: TObject);
  private
    PC : String;
    Servidor : SC_Handle;
    function FilterTipe():Cardinal;
    function FilterState():Cardinal;
    function FilterAcesso():Cardinal;
    function FilterConfig(Status:Cardinal):Boolean;
    procedure ServiceUpdate();
  protected
    procedure WndProc(var Message: TMessage); override;
  public
  end;

var
  FrmServices: TFrmServices;

implementation

{$R *.dfm}

uses
    PGofer.ClipBoards, PGofer.ListView, PGofer.Service,
    PGofer.Service.Thread, PGofer.Controls;

//---------------------------------------------------------------------------//
procedure TFrmServices.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;
//----------------------------------------------------------------------------//
function TFrmServices.FilterTipe():Cardinal;
begin
    Result := 0;
    if ClbTipo.Checked[0] then
       Result := Result or SERVICE_KERNEL_DRIVER;
    if ClbTipo.Checked[1] then
       Result := Result or SERVICE_FILE_SYSTEM_DRIVER;
    if ClbTipo.Checked[2] then
       Result := Result or SERVICE_ADAPTER;
    if ClbTipo.Checked[3] then
       Result := Result or SERVICE_RECOGNIZER_DRIVER;
    if ClbTipo.Checked[4] then
       Result := Result or SERVICE_WIN32_OWN_PROCESS;
    if ClbTipo.Checked[5] then
       Result := Result or SERVICE_WIN32_SHARE_PROCESS;
    if ClbTipo.Checked[6] then
       Result := Result or SERVICE_INTERACTIVE_PROCESS;
end;
//----------------------------------------------------------------------------//
function TFrmServices.FilterState():Cardinal;
begin
    Result := 0;
    if ClbStatus.Checked[0] then
       Result := Result or SERVICE_ACTIVE;
    if ClbStatus.Checked[1] then
       Result := Result or SERVICE_INACTIVE;
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.BtnDownClick(Sender: TObject);
var
    ItemIndex : Integer;
begin

    ItemIndex := LtvServices.FindCaption(EdtProcurar.Text,LtvServices.ItemIndex,CbxProcurar.Checked);
    if ItemIndex > -1 then
    begin
        LtvServices.ClearSelection;
        LtvServices.ItemIndex := ItemIndex;
        LtvServices.ItemFocused := LtvServices.Items[ItemIndex];
        LtvServices.Selected := LtvServices.Items[ItemIndex];
        LtvServices.Items[ItemIndex].MakeVisible(True);
    end;
    LtvServices.SetFocus;
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.EdtProcurarKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #13 then
       BtnDown.Click;
end;
//----------------------------------------------------------------------------//
function TFrmServices.FilterAcesso():Cardinal;
begin
    Result := 0;
    if ClbAcesso.Checked[0] then
       Result := Result or SERVICE_ACCEPT_STOP;
    if ClbAcesso.Checked[1] then
       Result := Result or SERVICE_ACCEPT_PAUSE_CONTINUE;
    if ClbAcesso.Checked[2] then
       Result := Result or SERVICE_ACCEPT_SHUTDOWN;
    if ClbAcesso.Checked[3] then
       Result := Result or SERVICE_ACCEPT_PARAMCHANGE;
    if ClbAcesso.Checked[4] then
       Result := Result or SERVICE_ACCEPT_NETBINDCHANGE;
    if ClbAcesso.Checked[5] then
       Result := Result or SERVICE_ACCEPT_HARDWAREPROFILECHANGE;
    if ClbAcesso.Checked[6] then
       Result := Result or SERVICE_ACCEPT_POWEREVENT;
    if ClbAcesso.Checked[7] then
       Result := Result or SERVICE_ACCEPT_SESSIONCHANGE;
    if ClbAcesso.Checked[8] then
       Result := Result or SERVICE_ACCEPT_PRESHUTDOWN;
    if ClbAcesso.Checked[9] then
       Result := Result or SERVICE_ACCEPT_TIMECHANGE;
    if ClbAcesso.Checked[10] then
       Result := Result or SERVICE_ACCEPT_TRIGGEREVENT;
end;
//----------------------------------------------------------------------------//
function TFrmServices.FilterConfig(Status:Cardinal):Boolean;
begin
    Result := (ClbConfig.Checked[Status]);
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniSelecionarTudoClick(Sender: TObject);
begin
    LtvServices.SelectAll;
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.PpmServicesPopup(Sender: TObject);
begin
    MniConfigurao.Enabled := False;
    MniEstado.Enabled := False;
    MniGerarScript.Enabled := False;
    MniDeletar.Enabled := False;
    MniCopiarValor.Enabled := False;

    if LtvServices.Selected <> nil then
    begin
        MniConfigurao.Enabled := True;
        MniEstado.Enabled := True;
        MniGerarScript.Enabled := True;
        MniDeletar.Enabled := True;
        MniCopiarValor.Enabled := True;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.ServiceUpdate();
const
    cnMaxServices = 4096;
type
   TSvcA = array[0..cnMaxServices] of TEnumServiceStatus;
   PSvcA = ^TSvcA;

var
   c : integer;
   Service: SC_Handle;
   nBytesNeeded, nServices, nResumeHandle : Cardinal;
   ssa : PSvcA;

   sConfig: Pointer;
   pConfig: PQueryServiceConfig;

   Item : TListItem;
   Filtrodeacesso: Cardinal;
   
begin
    //Se tiver Conectado
    if (Servidor > 0)then
    begin
        //carrega lista de servidores
        New(ssa);
        nResumeHandle := 0;
        Filtrodeacesso := FilterAcesso();
        EnumServicesStatus(Servidor, FilterTipe(), FilterState(), ssa^[0], SizeOf(ssa^), nBytesNeeded, nServices, nResumeHandle );
        if nServices <> 0 then
        for c := 0 to nServices-1 do
        begin
            //carrega o serviço
            Service := OpenService(Servidor, ssa^[c].lpServiceName , SERVICE_QUERY_CONFIG);
            if (Service > 0) then
            begin
                sConfig := nil;
                pConfig := nil;

                try
                    //pega informações
                    if not QueryServiceConfig(Service,sConfig,0,nBytesNeeded) then
                    begin
                         if (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
                         begin
                             GetMem(sConfig,nBytesNeeded);
                             if QueryServiceConfig(Service,sConfig,nBytesNeeded,nBytesNeeded) then
                                pConfig := PQueryServiceConfig(sConfig);
                         end;//if error
                    end;//if Query

                    if ((ssa^[c].ServiceStatus.dwControlsAccepted and Filtrodeacesso) = Filtrodeacesso )
                    and(FilterConfig(pConfig.dwStartType) ) then
                    begin
                        //adiciona um item
                        Item := LtvServices.Items.Add;
                        //Nome
                        Item.Caption := StrPas(ssa^[c].lpDisplayName);
                        //Status
                        Item.SubItems.Add( ServiceStatusToState(ssa^[c].ServiceStatus.dwCurrentState) );
                        //Boot
                        Item.SubItems.Add( ServiceStatusToConfig( pConfig.dwStartType ) );
                        //Tipo
                        Item.SubItems.Add( ServiceStatusToSystem(ssa^[c].ServiceStatus.dwServiceType) );
                        //Acesso
                        Item.SubItems.Add( ServiceStatusToAccess(ssa^[c].ServiceStatus.dwControlsAccepted) );
                        //nome interno
                        Item.SubItems.Add( StrPas(ssa^[c].lpServiceName) );
                        //ordem
                        Item.SubItems.Add( pConfig.lpLoadOrderGroup );
                        //dependentes
                        Item.SubItems.Add( pConfig.lpDependencies  );
                        //Start name
                        Item.SubItems.Add( pConfig.lpServiceStartName );
                        //Path
                        Item.SubItems.Add( pConfig.lpBinaryPathName );
                        //Interns
                        Item.SubItems.Add( Char(ssa^[c].ServiceStatus.dwCurrentState) + Char(pConfig.dwStartType) );
                        //icone
                        Item.ImageIndex:=ServiceStatusToDrive(ssa^[c].ServiceStatus.dwServiceType);
                     end;//if filtro.
                    Dispose(pConfig);
                except
                    ShowMessage('Erro ao Carregar Serviço: "'+ssa^[c].lpServiceName+'".');
                end;
                CloseServiceHandle(Service);
            end; //if service
        end;//For
        Dispose(ssa);
        StbSercive.Panels[0].Text:='Conectado: '+PC;
    end else
        StbSercive.Panels[0].Text:='Desconectado: '+PC;

    StbSercive.Panels[1].Text:='Total de Serviços: '+FormatFloat('0',LtvServices.Items.Count);
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.FormCreate(Sender: TObject);
var
   ini:TIniFile;

   procedure CarregarFiltro( CheckListBox:TCheckListBox; Padrao:Boolean );
   var
       c:byte;
   begin
       for c:=0 to CheckListBox.Count-1 do
           CheckListBox.Checked[c]:=ini.ReadBool( Self.Name,
           'Service_'+CheckListBox.Name+'_'+FormatFloat('00',c), Padrao );
   end;
begin
    LtvServices.SetOnProcedHelpers;
    //carregar filtro
    ini:=TIniFile.Create(DirCurrent+'Config.ini');
    GrbDercricao.Height := ini.ReadInteger( Self.Name, 'Dercrição', GrbDercricao.Height );
    GrbFiltro.Height := ini.ReadInteger( Self.Name, 'Filtro', GrbFiltro.Height );
    CarregarFiltro( ClbStatus, True);
    CarregarFiltro( ClbConfig, True);
    CarregarFiltro( ClbTipo, True);
    CarregarFiltro( ClbAcesso, False);
    ini.Free;

    //carrega config
    IniLoadFromFile(Self, DirCurrent+'Config.ini', LtvServices);

    PC := 'LocalHost';
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.FormShow(Sender: TObject);
begin
    Servidor := OpenSCManager( PChar(PC), nil, SC_MANAGER_ENUMERATE_SERVICE);
    MniAtualizar.Click;
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.FormClose(Sender: TObject; var Action: TCloseAction);
var
   ini:TIniFile;

   procedure SalvarFiltro( CheckListBox:TCheckListBox);
   var
       c:byte;
   begin
       for c:=0 to CheckListBox.Count-1 do
          ini.WriteBool( Self.Name, 'Service_'+CheckListBox.Name+'_'+FormatFloat('00',c)
                       , CheckListBox.Checked[c] );
   end;
begin
    LtvServices.Clear;
    
    //Salvar filtro
    ini:=TIniFile.Create(DirCurrent+'Config.ini');
    ini.WriteInteger( Self.Name, 'Dercrição', GrbDercricao.Height );
    ini.WriteInteger( Self.Name, 'Filtro', GrbFiltro.Height );
    SalvarFiltro( ClbStatus );
    SalvarFiltro( ClbConfig );
    SalvarFiltro( ClbTipo );
    SalvarFiltro( ClbAcesso );
    ini.Free;

    //salva o config
    IniSaveToFile(Self, DirCurrent+'Config.ini', LtvServices);

    CloseServiceHandle(Servidor);
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MinNomeInternoClick(Sender: TObject);
begin
    ClipBoardCopyFromText( LtvServices.ItemFocused.SubItems[4] );
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniAtualizarClick(Sender: TObject);
begin
    LtvServices.Clear;
    MemDescricao.Clear;
    ServiceUpdate();
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniIconesClick(Sender: TObject);
begin
    LtvServices.ViewStyle:=TViewStyle(TMenuItem(Sender).tag);
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniBootAutomaticoClick(Sender: TObject);
var
   c : Word;
begin
    for c:=0 to LtvServices.Items.Count-1 do
    begin
        if LtvServices.Items[c].Selected then
        begin
            if ServiceSetConfig(PC, LtvServices.Items[c].SubItems[4], TMenuItem(Sender).Tag) then
            begin
                LtvServices.Items[c].SubItems[1]:= ServiceStatusToConfig( TMenuItem(Sender).Tag );
                LtvServices.Items[c].SubItems[9]:= LtvServices.Items[c].SubItems[9][1] + Char(TMenuItem(Sender).Tag);
            end else
                ShowMessage('Não foi possivel configirar o serviço: '+LtvServices.Items[c].Caption);
        end;//if select
    end;//for
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniIniciarClick(Sender: TObject);
var
   c : Word;
   ThreadService : TThreadService;
begin
   for c:=0 to LtvServices.Items.Count-1 do
   begin
       if LtvServices.Items[c].Selected then
       begin
           ThreadService := TThreadService.Create(PC,LtvServices.Items[c],TMenu(Sender).Tag);
           ThreadService.Start;
       end;//if select
   end;//for
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniNomeClick(Sender: TObject);
begin
    ClipBoardCopyFromText(LtvServices.ItemFocused.Caption);
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniProcurarClick(Sender: TObject);
begin
    if EdtProcurar.Text = '' then
       EdtProcurar.SetFocus
    else
       BtnDown.Click;
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniDeletarClick(Sender: TObject);
var
   c : Word;
begin
   for c:=0 to LtvServices.Items.Count-1 do
   begin
       if LtvServices.Items[c].Selected then
       begin
           if (MessageDlg('Tem certeza deletar o Serviço: '+#13
                         +LtvServices.Items[c].SubItems[4], mtConfirmation, [mbYes, mbNo], mrNo) = mrYes) then
            begin
                if (ServiceDelete(PC, LtvServices.Items[c].SubItems[4])) then
                begin
                    LtvServices.Items[c].SubItems[0]:= 'Deletado';
                    LtvServices.Items[c].SubItems[1]:= 'Deletado';
                    LtvServices.Items[c].SubItems[9]:= #255+#255;
                end else
                    ShowMessage('Não foi possivel deletar o serviço: '+LtvServices.Items[c].Caption);
           end;
       end;//if select
   end;//for
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniGerarScriptClick(Sender: TObject);
var
   c, d, e : Word;
   Script: TStringList;
begin
    if SdgServices.Execute then
    begin
        Script:=TStringList.Create;
        Script.Add('//PGofer Script Services.');
        Script.Add('');
        d:=0;
        for c:=0 to LtvServices.Items.Count-1 do
        begin
            if LtvServices.Items[c].Selected then
            begin
                Script.Add('//Serviço: '+LtvServices.Items[c].Caption);

                e := Byte(LtvServices.Items[c].SubItems[9][2]);
                Script.Add('Service.SetConfig( '''+PC+''', '''+LtvServices.Items[c].SubItems[4]+''', '+IntToStr(e)+' ); //'+ServiceStatusToConfig(e));

                e := Byte(LtvServices.Items[c].SubItems[9][1]);
                Script.Add('Service.SetState( '''+PC+''', '''+LtvServices.Items[c].SubItems[4]+''', '+IntToStr(e)+' ); //'+ServiceStatusToState(e));

                Script.Add('');
                inc(d);
            end;//if select
        end;//for
        Script.Add('//Total de Serviços: '+FormatFloat('0',d));
        Script.SaveToFile(SdgServices.FileName);
        Script.Free;
        ShowMessage('Script Grerado.');
   end;//if save
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.LtvServicesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
    if LtvServices.ItemFocused <> nil then
       MemDescricao.Text := ServiceGetDesciption(PC,LtvServices.ItemFocused.SubItems[4]);
end;
//----------------------------------------------------------------------------//
procedure TFrmServices.MniConectarClick(Sender: TObject);
begin
    PC := PChar(InputBox('Services', 'Nome ou ip do computador:', PC ));
    CloseServiceHandle(Servidor);
    Servidor := OpenSCManager( PChar(PC), nil, SC_MANAGER_ENUMERATE_SERVICE);
    MniAtualizar.Click;
end;
//----------------------------------------------------------------------------//

end.
