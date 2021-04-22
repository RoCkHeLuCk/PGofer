unit UnitServices;

interface

uses
  Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ImgList, Vcl.Controls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.CheckLst, Vcl.ExtCtrls,
  Winapi.Messages, Winapi.Winsvc, Winapi.Windows,
  System.Classes, System.SysUtils, System.ImageList, System.UITypes,
  System.IniFiles, Pgofer.Component.ListView, Pgofer.Component.Form;

type
  TFrmServices = class( TFormEx )
    GrbFilter: TGroupBox;
    GrbList: TGroupBox;
    ImlServices: TImageList;
    PpmServices: TPopupMenu;
    LtvServices: TListViewEx;
    GrbType: TGroupBox;
    ClbType: TCheckListBox;
    GrbConfig: TGroupBox;
    ClbConfig: TCheckListBox;
    GrbStatus: TGroupBox;
    ClbStatus: TCheckListBox;
    GrbAccess: TGroupBox;
    ClbAccess: TCheckListBox;
    MniShow: TMenuItem;
    MniIcons: TMenuItem;
    MniIconsSmall: TMenuItem;
    MniList: TMenuItem;
    MniDetails: TMenuItem;
    MniUpdate: TMenuItem;
    MniConfig: TMenuItem;
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
    GrbDercription: TGroupBox;
    Splitter1: TSplitter;
    MemDescription: TMemo;
    StbSercive: TStatusBar;
    Splitter2: TSplitter;
    GrbSearch: TGroupBox;
    LblWords: TLabel;
    EdtSearch: TEdit;
    CbxSearch: TCheckBox;
    btnFilter: TButton;
    BtnDescription: TButton;
    BtnSearch: TButton;
    procedure FormCreate( Sender: TObject );
    procedure FormShow( Sender: TObject );
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
    procedure MniUpdateClick( Sender: TObject );
    procedure MniIconsClick( Sender: TObject );
    procedure MniBootAutomaticoClick( Sender: TObject );
    procedure MniIniciarClick( Sender: TObject );
    procedure MniGerarScriptClick( Sender: TObject );
<<<<<<< HEAD
=======
    procedure LtvServicesChange( Sender: TObject; Item: TListItem;
       Change: TItemChange );
>>>>>>> c3c63536427a8e61ccb4830f4dee68a022344625
    procedure MniConectarClick( Sender: TObject );
    procedure MniDeletarClick( Sender: TObject );
    procedure MniSelecionarTudoClick( Sender: TObject );
    procedure MniNomeClick( Sender: TObject );
    procedure MinNomeInternoClick( Sender: TObject );
    procedure MniProcurarClick( Sender: TObject );
    procedure EdtSearchKeyPress( Sender: TObject; var Key: Char );
    procedure PpmServicesPopup( Sender: TObject );
    procedure FormDestroy( Sender: TObject );
    procedure btnFilterClick(Sender: TObject);
    procedure BtnDescriptionClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
<<<<<<< HEAD
    procedure LtvServicesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure LtvServicesCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure LtvServicesColumnClick(Sender: TObject; Column: TListColumn);
  private
    FHostName: string;
    FHostHandle: SC_Handle;
    FSort : Boolean;
    FColumn: Byte;
=======
  private
    FHostName: string;
    FHostHandle: SC_Handle;
>>>>>>> c3c63536427a8e61ccb4830f4dee68a022344625
    function FilterTipe( ): Cardinal;
    function FilterState( ): Cardinal;
    function FilterAcesso( ): Cardinal;
    function FilterConfig( Status: Cardinal ): Boolean;
    procedure ServiceUpdate( );
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
  end;

var
  FrmServices: TFrmServices;

implementation

{$R *.dfm}

uses
  Pgofer.ClipBoards.Controls,
  Pgofer.Files.Controls,
  Pgofer.Services.Controls,
  Pgofer.Services.Thread;

{ TFrmServices }

function TFrmServices.FilterTipe( ): Cardinal;
begin
  Result := 0;
  if ClbType.Checked[ 0 ] then
    Result := Result or SERVICE_KERNEL_DRIVER;
  if ClbType.Checked[ 1 ] then
    Result := Result or SERVICE_FILE_SYSTEM_DRIVER;
  if ClbType.Checked[ 2 ] then
    Result := Result or SERVICE_ADAPTER;
  if ClbType.Checked[ 3 ] then
    Result := Result or SERVICE_RECOGNIZER_DRIVER;
  if ClbType.Checked[ 4 ] then
    Result := Result or SERVICE_WIN32_OWN_PROCESS;
  if ClbType.Checked[ 5 ] then
    Result := Result or SERVICE_WIN32_SHARE_PROCESS;
  if ClbType.Checked[ 6 ] then
    Result := Result or SERVICE_INTERACTIVE_PROCESS;
end;

function TFrmServices.FilterState( ): Cardinal;
begin
  Result := 0;
  if ClbStatus.Checked[ 0 ] then
    Result := Result or SERVICE_ACTIVE;
  if ClbStatus.Checked[ 1 ] then
    Result := Result or SERVICE_INACTIVE;
end;

procedure TFrmServices.BtnDescriptionClick(Sender: TObject);
begin
   if BtnDescription.Tag = 0 then
   begin
       BtnDescription.Caption := '>>';
       BtnDescription.Tag := GrbDercription.Height;
       GrbDercription.Height := 17;
   end else begin
       GrbDercription.Height := BtnDescription.Tag;
       BtnDescription.Caption := '<<';
       BtnDescription.Tag := 0;
   end;
end;

procedure TFrmServices.btnFilterClick(Sender: TObject);
begin
   if btnFilter.Tag = 0 then
   begin
       btnFilter.Caption := '>>';
       btnFilter.Tag := GrbFilter.Height;
       GrbFilter.Height := 17;
   end else begin
       GrbFilter.Height := btnFilter.Tag;
       btnFilter.Caption := '<<';
       btnFilter.Tag := 0;
   end;
end;

procedure TFrmServices.BtnSearchClick(Sender: TObject);
begin
  LtvServices.FindText( EdtSearch.Text, CbxSearch.Checked );
end;

procedure TFrmServices.EdtSearchKeyPress( Sender: TObject; var Key: Char );
begin
  if Key = #13 then
    BtnSearch.Click;
end;

function TFrmServices.FilterAcesso( ): Cardinal;
begin
  Result := 0;
  if ClbAccess.Checked[ 0 ] then
    Result := Result or SERVICE_ACCEPT_STOP;
  if ClbAccess.Checked[ 1 ] then
    Result := Result or SERVICE_ACCEPT_PAUSE_CONTINUE;
  if ClbAccess.Checked[ 2 ] then
    Result := Result or SERVICE_ACCEPT_SHUTDOWN;
  if ClbAccess.Checked[ 3 ] then
    Result := Result or SERVICE_ACCEPT_PARAMCHANGE;
  if ClbAccess.Checked[ 4 ] then
    Result := Result or SERVICE_ACCEPT_NETBINDCHANGE;
  if ClbAccess.Checked[ 5 ] then
    Result := Result or SERVICE_ACCEPT_HARDWAREPROFILECHANGE;
  if ClbAccess.Checked[ 6 ] then
    Result := Result or SERVICE_ACCEPT_POWEREVENT;
  if ClbAccess.Checked[ 7 ] then
    Result := Result or SERVICE_ACCEPT_SESSIONCHANGE;
  if ClbAccess.Checked[ 8 ] then
    Result := Result or SERVICE_ACCEPT_PRESHUTDOWN;
  if ClbAccess.Checked[ 9 ] then
    Result := Result or SERVICE_ACCEPT_TIMECHANGE;
  if ClbAccess.Checked[ 10 ] then
    Result := Result or SERVICE_ACCEPT_TRIGGEREVENT;
end;

function TFrmServices.FilterConfig( Status: Cardinal ): Boolean;
begin
  Result := ( ClbConfig.Checked[ Status ] );
end;

procedure TFrmServices.MniSelecionarTudoClick( Sender: TObject );
begin
  LtvServices.SelectAll;
end;

procedure TFrmServices.PpmServicesPopup( Sender: TObject );
begin
  MniConfig.Enabled := False;
  MniEstado.Enabled := False;
  MniGerarScript.Enabled := False;
  MniDeletar.Enabled := False;
  MniCopiarValor.Enabled := False;

  if LtvServices.Selected <> nil then
  begin
    MniConfig.Enabled := True;
    MniEstado.Enabled := True;
    MniGerarScript.Enabled := True;
    MniDeletar.Enabled := True;
    MniCopiarValor.Enabled := True;
  end;
end;

procedure TFrmServices.ServiceUpdate( );
const
  cnMaxServices = 4096;
type
  TSvcA = array [ 0 .. cnMaxServices ] of TEnumServiceStatus;
  PSvcA = ^TSvcA;

var
  c: Integer;
  Service: SC_Handle;
  nBytesNeeded, nServices, nResumeHandle: Cardinal;
  ssa: PSvcA;
<<<<<<< HEAD

  sConfig: Pointer;
  pConfig: PQueryServiceConfig;

=======

  sConfig: Pointer;
  pConfig: PQueryServiceConfig;

>>>>>>> c3c63536427a8e61ccb4830f4dee68a022344625
  Item: TListItem;
  Filtrodeacesso: Cardinal;

begin
  // Se tiver Conectado
  if ( FHostHandle > 0 ) then
  begin
    // carrega lista de servidores
    New( ssa );
    nResumeHandle := 0;
    Filtrodeacesso := FilterAcesso( );
    EnumServicesStatus( FHostHandle, FilterTipe( ), FilterState( ), ssa^[ 0 ],
       SizeOf( ssa^ ), nBytesNeeded, nServices, nResumeHandle );
    if nServices <> 0 then
      for c := 0 to nServices - 1 do
      begin
        // carrega o serviço
        Service := OpenService( FHostHandle, ssa^[ c ].lpServiceName,
           SERVICE_QUERY_CONFIG );
        if ( Service > 0 ) then
        begin
          sConfig := nil;
          pConfig := nil;

          try
            // pega informações
            if not QueryServiceConfig( Service, sConfig, 0, nBytesNeeded ) then
            begin
              if ( GetLastError = ERROR_INSUFFICIENT_BUFFER ) then
              begin
                GetMem( sConfig, nBytesNeeded );
                if QueryServiceConfig( Service, sConfig, nBytesNeeded,
                   nBytesNeeded ) then
                  pConfig := PQueryServiceConfig( sConfig );
              end; // if error
            end; // if Query

            if ( ( ssa^[ c ].ServiceStatus.dwControlsAccepted and
               Filtrodeacesso ) = Filtrodeacesso ) and
               ( FilterConfig( pConfig.dwStartType ) ) then
            begin
              // adiciona um item
              Item := LtvServices.Items.Add;
              // Nome
              Item.Caption := StrPas( ssa^[ c ].lpDisplayName );
              // Status
              Item.SubItems.Add
                 ( ServiceStatusToState( ssa^[ c ]
                 .ServiceStatus.dwCurrentState ) );
              // Boot
              Item.SubItems.Add( ServiceStatusToConfig( pConfig.dwStartType ) );
              // Tipo
              Item.SubItems.Add
                 ( ServiceStatusToSystem( ssa^[ c ]
                 .ServiceStatus.dwServiceType ) );
              // Acesso
              Item.SubItems.Add
                 ( ServiceStatusToAccess( ssa^[ c ]
                 .ServiceStatus.dwControlsAccepted ) );
              // nome interno
              Item.SubItems.Add( StrPas( ssa^[ c ].lpServiceName ) );
              // ordem
              Item.SubItems.Add( pConfig.lpLoadOrderGroup );
              // dependentes
              Item.SubItems.Add( pConfig.lpDependencies );
              // Start name
              Item.SubItems.Add( pConfig.lpServiceStartName );
              // Path
              Item.SubItems.Add( pConfig.lpBinaryPathName );
              // Interns
              Item.SubItems.Add( Char( ssa^[ c ].ServiceStatus.dwCurrentState )
                 + Char( pConfig.dwStartType ) );
              // icone
              Item.ImageIndex := ServiceStatusToDrive
                 ( ssa^[ c ].ServiceStatus.dwServiceType );
            end; // if filtro.
            Dispose( pConfig );
          except
            ShowMessage( 'Erro ao Carregar Serviço: "' + ssa^[ c ]
               .lpServiceName + '".' );
          end;
          CloseServiceHandle( Service );
        end; // if service
      end; // For
    Dispose( ssa );
    StbSercive.Panels[ 0 ].Text := 'Conectado: ' + FHostName;
  end
  else
    StbSercive.Panels[ 0 ].Text := 'Desconectado: ' + FHostName;

  StbSercive.Panels[ 1 ].Text := 'Total de Serviços: ' +
     FormatFloat( '0', LtvServices.Items.Count );
<<<<<<< HEAD
  LtvServices.AlphaSort;
=======
>>>>>>> c3c63536427a8e61ccb4830f4dee68a022344625
end;

procedure TFrmServices.FormCreate( Sender: TObject );
begin
  inherited FormCreate( Sender );
<<<<<<< HEAD
  FColumn := 0;
  FSort := False;
=======
>>>>>>> c3c63536427a8e61ccb4830f4dee68a022344625
  FHostName := 'LocalHost';
end;

procedure TFrmServices.FormDestroy( Sender: TObject );
begin
  inherited FormDestroy( Sender );
  LtvServices.Clear;
  CloseServiceHandle( FHostHandle );
end;

procedure TFrmServices.FormShow( Sender: TObject );
<<<<<<< HEAD
begin
  FHostHandle := OpenSCManager( PChar( FHostName ), nil,
     SC_MANAGER_ENUMERATE_SERVICE );
  MniUpdate.Click;
end;

procedure TFrmServices.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  inherited FormClose( Sender, Action );
  //
end;

procedure TFrmServices.IniConfigLoad( );
  procedure CarregarFiltro( CheckListBox: TCheckListBox; Padrao: Boolean );
  var
    c: byte;
  begin
    for c := 0 to CheckListBox.Count - 1 do
      CheckListBox.Checked[ c ] := FIniFile.ReadBool( Self.Name,
         'Service_' + CheckListBox.Name + '_' + FormatFloat( '00', c ),
         Padrao );
  end;

begin
  inherited IniConfigLoad( );

  GrbDercription.Height := FIniFile.ReadInteger( Self.Name, 'Dercription',
     GrbDercription.Height );
  if FIniFile.ReadBool( Self.Name, 'DercriptionHide', False) then
     btnDescription.Click;

  GrbFilter.Height := FIniFile.ReadInteger( Self.Name, 'Filter',
     GrbFilter.Height );
  if FIniFile.ReadBool( Self.Name, 'FilterHide', False) then
     btnFilter.Click;

  CarregarFiltro( ClbStatus, True );
  CarregarFiltro( ClbConfig, True );
  CarregarFiltro( ClbType, True );
  CarregarFiltro( ClbAccess, False );
  LtvServices.IniConfigLoad( FIniFile );
end;

procedure TFrmServices.IniConfigSave( );
  procedure SalvarFiltro( CheckListBox: TCheckListBox );
  var
    c: byte;
  begin
    for c := 0 to CheckListBox.Count - 1 do
      FIniFile.WriteBool( Self.Name, 'Service_' + CheckListBox.Name + '_' +
         FormatFloat( '00', c ), CheckListBox.Checked[ c ] );
  end;

begin
  if BtnDescription.Tag = 0 then
  begin
     FIniFile.WriteBool( Self.Name, 'DercriptionHide', False );
     FIniFile.WriteInteger( Self.Name, 'Dercription', GrbDercription.Height );
  end else begin
     FIniFile.WriteBool( Self.Name, 'DercriptionHide', True );
     FIniFile.WriteInteger( Self.Name, 'Dercription', btnDescription.Tag );
  end;

  if btnFilter.Tag = 0 then
  begin
     FIniFile.WriteBool( Self.Name, 'FilterHide', False );
     FIniFile.WriteInteger( Self.Name, 'Filter', GrbFilter.Height );
  end else begin
     FIniFile.WriteBool( Self.Name, 'FilterHide', True );
     FIniFile.WriteInteger( Self.Name, 'Filter', btnFilter.Tag );
  end;

  SalvarFiltro( ClbStatus );
  SalvarFiltro( ClbConfig );
  SalvarFiltro( ClbType );
  SalvarFiltro( ClbAccess );
  LtvServices.IniConfigSave( FIniFile );
  inherited IniConfigSave( );
end;

procedure TFrmServices.MinNomeInternoClick( Sender: TObject );
begin
  ClipBoardCopyFromText( LtvServices.ItemFocused.SubItems[ 4 ] );
end;

procedure TFrmServices.MniUpdateClick( Sender: TObject );
begin
  LtvServices.Clear;
  MemDescription.Clear;
  ServiceUpdate( );
end;

procedure TFrmServices.MniIconsClick( Sender: TObject );
begin
  LtvServices.ViewStyle := TViewStyle( TMenuItem( Sender ).tag );
end;

=======
begin
  FHostHandle := OpenSCManager( PChar( FHostName ), nil,
     SC_MANAGER_ENUMERATE_SERVICE );
  MniUpdate.Click;
end;

procedure TFrmServices.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  inherited FormClose( Sender, Action );
  //
end;

procedure TFrmServices.IniConfigLoad( );
  procedure CarregarFiltro( CheckListBox: TCheckListBox; Padrao: Boolean );
  var
    c: byte;
  begin
    for c := 0 to CheckListBox.Count - 1 do
      CheckListBox.Checked[ c ] := FIniFile.ReadBool( Self.Name,
         'Service_' + CheckListBox.Name + '_' + FormatFloat( '00', c ),
         Padrao );
  end;

begin
  inherited IniConfigLoad( );

  GrbDercription.Height := FIniFile.ReadInteger( Self.Name, 'Dercription',
     GrbDercription.Height );
  if FIniFile.ReadBool( Self.Name, 'DercriptionHide', False) then
     btnDescription.Click;

  GrbFilter.Height := FIniFile.ReadInteger( Self.Name, 'Filter',
     GrbFilter.Height );
  if FIniFile.ReadBool( Self.Name, 'FilterHide', False) then
     btnFilter.Click;

  CarregarFiltro( ClbStatus, True );
  CarregarFiltro( ClbConfig, True );
  CarregarFiltro( ClbType, True );
  CarregarFiltro( ClbAccess, False );
  LtvServices.IniConfigLoad( FIniFile );
end;

procedure TFrmServices.IniConfigSave( );
  procedure SalvarFiltro( CheckListBox: TCheckListBox );
  var
    c: byte;
  begin
    for c := 0 to CheckListBox.Count - 1 do
      FIniFile.WriteBool( Self.Name, 'Service_' + CheckListBox.Name + '_' +
         FormatFloat( '00', c ), CheckListBox.Checked[ c ] );
  end;

begin
  if BtnDescription.Tag = 0 then
  begin
     FIniFile.WriteBool( Self.Name, 'DercriptionHide', False );
     FIniFile.WriteInteger( Self.Name, 'Dercription', GrbDercription.Height );
  end else begin
     FIniFile.WriteBool( Self.Name, 'DercriptionHide', True );
     FIniFile.WriteInteger( Self.Name, 'Dercription', btnDescription.Tag );
  end;

  if btnFilter.Tag = 0 then
  begin
     FIniFile.WriteBool( Self.Name, 'FilterHide', False );
     FIniFile.WriteInteger( Self.Name, 'Filter', GrbFilter.Height );
  end else begin
     FIniFile.WriteBool( Self.Name, 'FilterHide', True );
     FIniFile.WriteInteger( Self.Name, 'Filter', btnFilter.Tag );
  end;

  SalvarFiltro( ClbStatus );
  SalvarFiltro( ClbConfig );
  SalvarFiltro( ClbType );
  SalvarFiltro( ClbAccess );
  LtvServices.IniConfigSave( FIniFile );
  inherited IniConfigSave( );
end;

procedure TFrmServices.MinNomeInternoClick( Sender: TObject );
begin
  ClipBoardCopyFromText( LtvServices.ItemFocused.SubItems[ 4 ] );
end;

procedure TFrmServices.MniUpdateClick( Sender: TObject );
begin
  LtvServices.Clear;
  MemDescription.Clear;
  ServiceUpdate( );
end;

procedure TFrmServices.MniIconsClick( Sender: TObject );
begin
  LtvServices.ViewStyle := TViewStyle( TMenuItem( Sender ).tag );
end;

>>>>>>> c3c63536427a8e61ccb4830f4dee68a022344625
procedure TFrmServices.MniBootAutomaticoClick( Sender: TObject );
var
  c: Word;
begin
  for c := 0 to LtvServices.Items.Count - 1 do
  begin
    if LtvServices.Items[ c ].Selected then
    begin
      if ServiceSetConfig( FHostName, LtvServices.Items[ c ].SubItems[ 4 ],
         TMenuItem( Sender ).tag ) then
      begin
        LtvServices.Items[ c ].SubItems[ 1 ] :=
           ServiceStatusToConfig( TMenuItem( Sender ).tag );
        LtvServices.Items[ c ].SubItems[ 9 ] := LtvServices.Items[ c ].SubItems
           [ 9 ][ 1 ] + Char( TMenuItem( Sender ).tag );
      end
      else
        ShowMessage( 'Não foi possivel configirar o serviço: ' +
           LtvServices.Items[ c ].Caption );
    end; // if select
  end; // for
end;

procedure TFrmServices.MniIniciarClick( Sender: TObject );
var
  c: Word;
  ThreadService: TThreadService;
begin
  for c := 0 to LtvServices.Items.Count - 1 do
  begin
    if LtvServices.Items[ c ].Selected then
    begin
      ThreadService := TThreadService.Create( FHostName, LtvServices.Items[ c ],
         TMenu( Sender ).tag );
      ThreadService.Start;
    end; // if select
  end; // for
end;

procedure TFrmServices.MniNomeClick( Sender: TObject );
begin
  ClipBoardCopyFromText( LtvServices.ItemFocused.Caption );
end;

procedure TFrmServices.MniProcurarClick( Sender: TObject );
begin
  if EdtSearch.Text = '' then
    EdtSearch.SetFocus
  else
    BtnSearch.Click;
end;

procedure TFrmServices.MniDeletarClick( Sender: TObject );
var
  c: Word;
begin
  for c := 0 to LtvServices.Items.Count - 1 do
  begin
    if LtvServices.Items[ c ].Selected then
    begin
      if ( MessageDlg( 'Tem certeza deletar o Serviço: ' + #13 +
         LtvServices.Items[ c ].SubItems[ 4 ], mtConfirmation, [ mbYes, mbNo ],
         mrNo ) = mrYes ) then
      begin
        if ( ServiceDelete( FHostName, LtvServices.Items[ c ].SubItems[ 4 ] ) )
        then
        begin
          LtvServices.Items[ c ].SubItems[ 0 ] := 'Deletado';
          LtvServices.Items[ c ].SubItems[ 1 ] := 'Deletado';
          LtvServices.Items[ c ].SubItems[ 9 ] := #255 + #255;
        end
        else
          ShowMessage( 'Não foi possivel deletar o serviço: ' +
             LtvServices.Items[ c ].Caption );
      end;
    end; // if select
  end; // for
end;

procedure TFrmServices.MniGerarScriptClick( Sender: TObject );
var
  c, d, e: Word;
  Script: TStringList;
begin
  if SdgServices.Execute then
  begin
    Script := TStringList.Create;
    Script.Add( '//PGofer Script Services.' );
    Script.Add( '' );
    d := 0;
    for c := 0 to LtvServices.Items.Count - 1 do
    begin
      if LtvServices.Items[ c ].Selected then
      begin
        Script.Add( '//Serviço: ' + LtvServices.Items[ c ].Caption );

        e := byte( LtvServices.Items[ c ].SubItems[ 9 ][ 2 ] );
        Script.Add( 'Service.SetConfig( ''' + FHostName + ''', ''' +
           LtvServices.Items[ c ].SubItems[ 4 ] + ''', ' + IntToStr( e ) +
           ' ); //' + ServiceStatusToConfig( e ) );

        e := byte( LtvServices.Items[ c ].SubItems[ 9 ][ 1 ] );
        Script.Add( 'Service.SetState( ''' + FHostName + ''', ''' +
           LtvServices.Items[ c ].SubItems[ 4 ] + ''', ' + IntToStr( e ) +
           ' ); //' + ServiceStatusToState( e ) );

        Script.Add( '' );
        inc( d );
      end; // if select
    end; // for
    Script.Add( '//Total de Serviços: ' + FormatFloat( '0', d ) );
    Script.SaveToFile( SdgServices.FileName );
    Script.Free;
    ShowMessage( 'Script Grerado.' );
  end; // if save
<<<<<<< HEAD
end;

procedure TFrmServices.LtvServicesColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if FColumn <> Column.Index then
  begin
     FColumn := Column.Index;
     FSort := False;
  end else
     FSort := not FSort;
  LtvServices.AlphaSort;
end;

procedure TFrmServices.LtvServicesCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if FColumn = 0 then
    Compare := CompareText( Item1.Caption,Item2.Caption)
  else
    Compare := CompareText( Item1.SubItems[ FColumn-1 ],
      Item2.SubItems[ FColumn-1 ]);

  if FSort then
     Compare := -Compare;
end;

procedure TFrmServices.LtvServicesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
    MemDescription.Text := ServiceGetDesciption( FHostName,
       Item.SubItems[ 4 ] );
=======
end;

procedure TFrmServices.LtvServicesChange( Sender: TObject; Item: TListItem;
   Change: TItemChange );
begin
  if LtvServices.ItemFocused <> nil then
    MemDescription.Text := ServiceGetDesciption( FHostName,
       LtvServices.ItemFocused.SubItems[ 4 ] );
>>>>>>> c3c63536427a8e61ccb4830f4dee68a022344625
end;

procedure TFrmServices.MniConectarClick( Sender: TObject );
begin
  FHostName := PChar( InputBox( 'Services', 'Nome ou ip do computador:',
     FHostName ) );
  CloseServiceHandle( FHostHandle );
  FHostHandle := OpenSCManager( PChar( FHostName ), nil,
     SC_MANAGER_ENUMERATE_SERVICE );
  MniUpdate.Click;
end;

end.
