//Constantes declaradas.

//Booleano
var const global True := 1; //Verdadeiro
var const global False := 0; //Falso

var const global Pi := 3.14159265358979; //Pi

//File.Exec
var const global flxHide := 0; //Janela no estado Normal
var const global flxNormal := 1; //Janela no estado Normal
var const global flxMinimized := 2; //Janela no estado Minimizado
var const global flxMaximized := 3; //Janela no estado Maximizado

//File.Script
var const global flsIdle := 0; //Prioridade Inativo
var const global flsLowest := 1; //Prioridade Mais Baixo
var const global flsLower := 2; //Prioridade Baixo
var const global flsNormal := 3; //Prioridade Normal
var const global flsHigher := 4; //Prioridade Alto
var const global flsHighest := 5; //Prioridade Mais Alto
var const global flsTimeCritical := 6; //Prioridade Tempo Real

//File.Copy;File.Delete;File.Move;File.Rename;
var const global flcNull := 1; //Nulo
var const global flcMultiDestFiles := 1; //Para Especificar m�ltiplos diret�rios para cada arquivo de origem
var const global flcConfirmMouse := 2; //N�o Utilizado
var const global flcSilent := 4; //N�o mostrar um progresso caixa de di�logo
var const global flcRenameOnCollision := 8; //Cria um novo nome para o arquivo de destino se j� existir um igual no destino
var const global flcNoConfirmation := 16; //Responder Sim para todos para qualquer caixa de di�logo que � exibida
var const global flcWantMappingHandle := 32; //Para fofRenameOnCollision, cria uma lista dos arquivos
var const global flcAllOwUndo := 64; //Para que a opera��o possa ser desfeita
var const global flcFilesOnly := 128; //Executa a opera��o apenas em arquivos, ignora os diretorios
var const global flcSimpleProgress := 256; //Exibe uma caixa de di�logo de progresso simples
var const global flcNoConfirmMKDir := 512; //N�o pergunta a cria��o de um novo diret�rio se a opera��o requer um a ser criado
var const global flcNoErrorUi := 1024; //N�o exibir uma caixa de di�logo se um erro ocorre.

//File.GetAttrib;File.SetAttrib;
var const global flaReadOnly := 1; //Somente leitura
var const global flaHidden := 2; //Oculto
var const global flaSysFile := 4; //Sistema
var const global flaVolumeID := 8; //Volume ID
var const global flaDirectory := 16; //Diret�rio
var const global flaArchive := 32; //Ficheiro
var const global flaSymLink := 64; //Link Simb�lico

//Sound.*
var const global sndrvDefault := 0; //Placa de som padr�o
var const global sndrvMultimi := 1; //Placa de som multimidia padr�o
var const global sndrvComunic := 2; //Placa de som comunica��o padr�o

//Sound.PlaySound
var const global sndcSync := 0; //Espera terminar
var const global sndcAsync := 1; //N�o espera terminar
var const global sndcNoDefault := 2; //N�o usa a placa de som padr�o
var const global sndcMemory := 4; //Toca som da memoria (N�o usado)
var const global sndcLoop := 8; //Repete o som at� tocar um proximo
var const global sndcNoStop := 16; //N�o para de tocar o som  se vier tocar um proximo

//Service.GetConfig;Service.SetConfig;
var const global svcBootStart := 0; //Inicia com o Boot
var const global svcSystemStart := 1; //Inicia com o Sistema
var const global svcAutoStart := 2; //Inicia com o Login
var const global svcDemandStart := 3; //Inicia Manualmente
var const global svcDisabled := 4; //Desabilitado

//Service.GetState;Service.SetState;
var const global svsStop := 1; //servi�o parado
var const global svsRunning := 2; //iniciando o servi�o
var const global svsStoping := 3; //parando o servi�o
var const global svsRun := 4; //servi�o iniciado 
var const global svsPending := 5; //servi�o Pendente 
var const global svsPausing := 6; //pausando o servi�o 
var const global svsPause := 7; //servi�o pausado 

//Registry.*
var const global hkeyClassesRoot := 0h80000000; //HKEY_CLASSES_ROOT
var const global hkeyCurrentUser := 0h80000001; //HKEY_CURRENT_USER
var const global hkeyLocalMachine := 0h80000002; //HKEY_LOCAL_MACHINE
var const global hkeyUsers := 0h80000003; //HKEY_USERS
var const global hkeyPerformData := 0h80000004; //HKEY_PERFORMANCE_DATA
var const global hkeyCurrentConfig := 0h80000005; //HKEY_CURRENT_CONFIG
var const global hkeyDynData := 0h80000006; //HKEY_DYN_DATA

//System.ShowMessage Type
var const global stmtWarning := 0; //Aviso
var const global stmtError := 1; //Erro
var const global stmtInformation := 2; //Informa��o
var const global stmtConfirmation := 3; //Confirma��o
var const global stmtCustom := 4; //Customizada

//System.ShowMessage Buttons
var const global stmbYes := 1; //Sim
var const global stmbNo := 2; //N�o
var const global stmbOK := 4; //Ok
var const global stmbCancel := 8; //Cancelar
var const global stmbAbort := 16; //Abortar
var const global stmbRetry := 32; //Repetir
var const global stmbIgnore := 64; //Iginorar
var const global stmbAll := 128; //Tudo
var const global stmbNoToAll := 256; //N�o pra tudo
var const global stmbYesToAll := 512; //Sim pra tudo
var const global stmbHelp := 1024; //Ajuda
var const global stmbClose := 2048; //Fechar

//System.ShowMessage Result
var const global stmrNone := 0; //Nada
var const global stmrOk := 1; //Ok
var const global stmrCancel := 2; //Cancelar
var const global stmrAbort := 3; //Abortar
var const global stmrRetry := 4; //Repetir
var const global stmrIgnore := 5; //Ignorar
var const global stmrYes := 6; //Sim 
var const global stmrNo := 7; //N�o
var const global stmrClose := 8; //Fechar
var const global stmrHelp := 9; //Ajuda 
var const global stmrTryAgain := 10; //Tentar Novamente
var const global stmrContinue := 11; //Continuar
var const global stmrAll := 12; //Tudo
var const global stmrNoToAll := 13;//N�o para Todos
var const global stmrYesToAll := 14;//Sim para Todos

//System.ShutDown
var const global stmsdLogOff := 0; //LogOff
var const global stmsdShutDown := 1; //Desliga apenas o Windows, n�o o computador
var const global stmsdReBoot := 2; //Reinicia o computador
var const global stmsdForce := 4; //Desliga o computador for�adamente
var const global stmsdPowerOff := 8; //Desliga o computador completamente
var const global stmsdForceIfHung := 16; //Desliga o computador for�adamente de leve

//System.SendMessage
var const global stmsmNull := 0;
var const global stmsmCreate := 1;
var const global stmsmDestroy := 2;
var const global stmsmMove := 3;
var const global stmsmSize := 5;
var const global stmsmActivate := 6;
var const global stmsmSetfocus := 7;
var const global stmsmKillFocus := 8;
var const global stmsmEnable := 10;
var const global stmsmSetRedraw := 11;
var const global stmsmSetText := 12;
var const global stmsmGetText := 13;
var const global stmsmGetTextLength := 14;
var const global stmsmPaint := 15;
var const global stmsmClose := 16;
var const global stmsmQueryEndSession := 17;
var const global stmsmQuit := 18;
var const global stmsmQueryOpen := 19;
var const global stmsmEraseBkgnd := 20;
var const global stmsmSysColorChange := 21;
var const global stmsmEndSession := 22;
var const global stmsmSysTemerror := 23;
var const global stmsmShowWindow := 24;
var const global stmsmCtlColor := 25;
var const global stmsmWinIniChange := 26;
var const global stmsmDevModeChange := 27;
var const global stmsmActivateApp := 28;
var const global stmsmFontChange := 29;
var const global stmsmTimeChange := 30;
var const global stmsmCancelMode := 31;
var const global stmsmSetCursor := 32;
var const global stmsmMouseActivate := 33;
var const global stmsmChildActivate := 34;
var const global stmsmQueueSync := 35;
var const global stmsmGetMinMaxInfo := 36;
var const global stmsmPaintIcon := 38;
var const global stmsmIconeRaseBkgnd := 39;
var const global stmsmNextDlgCtl := 40;
var const global stmsmSpoolerStatus := 42;
var const global stmsmDrawItem := 43;
var const global stmsmMeasureItem := 44;
var const global stmsmDeleteItem := 45;
var const global stmsmVkeytoItem := 46;
var const global stmsmChartoItem := 47;
var const global stmsmSetFont := 48;
var const global stmsmGetFont := 49;
var const global stmsmSetHotkey := 50;
var const global stmsmGetHotkey := 51;
var const global stmsmQueryDragIcon := 55;
var const global stmsmCompareItem := 57;
var const global stmsmGetObject := 61;
var const global stmsmCompacting := 65;
var const global stmsmCommNotify := 68;
var const global stmsmWindowPoschanging := 70;
var const global stmsmWindowPoschanged := 71;
var const global stmsmPower := 72;
var const global stmsmCopyData := 74;
var const global stmsmCancelJournal := 75;
var const global stmsmNotify := 78;
var const global stmsmInputLangchangeRequest := 80;
var const global stmsmInputLangchange := 81;
var const global stmsmTcard := 82;
var const global stmsmHelp := 83;
var const global stmsmUserChanged := 84;
var const global stmsmNotifyFormat := 85;
var const global stmsmContextMenu := 123;
var const global stmsmStyleChanging := 124;
var const global stmsmStyleChanged := 125;
var const global stmsmDisplayChange := 126;
var const global stmsmGetIcon := 127;
var const global stmsmSetIcon := 128;
var const global stmsmNcCreate := 129;
var const global stmsmNcDestroy := 130;
var const global stmsmNcCalcSize := 131;
var const global stmsmNcHitTest := 132;
var const global stmsmNcPaint := 133;
var const global stmsmNcActivate := 134;
var const global stmsmGetDlgCode := 135;
var const global stmsmNcMouseMove := 160;
var const global stmsmNclButtonDown := 161;
var const global stmsmNclButtonUp := 162;
var const global stmsmNclButtondBlclk := 163;
var const global stmsmNcrButtonDown := 164;
var const global stmsmNcrButtonUp := 165;
var const global stmsmNcrButtondBlclk := 166;
var const global stmsmNcmButtonDown := 167;
var const global stmsmNcmButtonUp := 168;
var const global stmsmNcmButtonDblClk := 169;
var const global stmsmNcxButtonDown := 171;
var const global stmsmNcxButtonUp := 172;
var const global stmsmNcxButtonDblClk := 173;
var const global stmsmInput := 255;
var const global stmsmKeyFirst := 256;
var const global stmsmKeyDown := 256;
var const global stmsmKeyUp := 257;
var const global stmsmChar := 258;
var const global stmsmDeadChar := 259;
var const global stmsmSysKeyDown := 260;
var const global stmsmSysKeyUp := 261;
var const global stmsmSysChar := 262;
var const global stmsmSysDeadChar := 263;
var const global stmsmKeyLast := 264;
var const global stmsmInitDialog := 272;
var const global stmsmCommand := 273;
var const global stmsmSysCommand := 274;
var const global stmsmTimer := 275;
var const global stmsmHScroll := 276;
var const global stmsmVScroll := 277;
var const global stmsmInitMenu := 278;
var const global stmsmInitMenuPopUp := 279;
var const global stmsmMenuSelect := 287;
var const global stmsmMenuChar := 288;
var const global stmsmEnterIdle := 289;
var const global stmsmMenuRButtonUp := 290;
var const global stmsmMenuDrag := 291;
var const global stmsmMenuGetObject := 292;
var const global stmsmUnInitMenuPoPup := 293;
var const global stmsmMenuCommand := 294;
var const global stmsmChangeUIState := 295;
var const global stmsmUpdateUIState := 296;
var const global stmsmQueryUIState := 297;
var const global stmsmCtlColorMsgBox := 306;
var const global stmsmCtlColorEdit := 307;
var const global stmsmCtlColorListBox := 308;
var const global stmsmCtlColorBtn := 309;
var const global stmsmCtlColorDlg := 310;
var const global stmsmCtlColorScrollBar := 311;
var const global stmsmCtlColorStatic := 312;
var const global stmsmMouseFirst := 512;
var const global stmsmMouseMove := 512;
var const global stmsmLButtonDown := 513;
var const global stmsmLButtonUp := 514;
var const global stmsmLButtondBlclk := 515;
var const global stmsmRButtonDown := 516;
var const global stmsmRButtonUp := 517;
var const global stmsmRButtonDblClk := 518;
var const global stmsmMButtonDown := 519;
var const global stmsmMButtonUp := 520;
var const global stmsmMButtonDblClk := 521;
var const global stmsmMouseWheel := 522;
var const global stmsmMouseLast := 522;
var const global stmsmParentNotify := 528;
var const global stmsmEnterMenuLoop := 529;
var const global stmsmExitMenuLoop := 530;
var const global stmsmNextMenu := 531;
var const global stmsmSizing := 532;
var const global stmsmCaptureChanged := 533;
var const global stmsmMoving := 534;
var const global stmsmPowerBroadcast := 535;
var const global stmsmDeviceChange := 536;
var const global stmsmIme_StartComposition := 269;
var const global stmsmIme_EndComposition := 270;
var const global stmsmIme_Composition := 271;
var const global stmsmIme_KeyLast := 271;
var const global stmsmIme_SetContext := 641;
var const global stmsmIme_Notify := 642;
var const global stmsmIme_Control := 643;
var const global stmsmIme_CompositionFull := 644;
var const global stmsmIme_Select := 645;
var const global stmsmIme_Char := 646;
var const global stmsmIme_Request := 648;
var const global stmsmIme_KeyDown := 656;
var const global stmsmIme_KeyUp := 657;
var const global stmsmMdiCreate := 544;
var const global stmsmMdiDestroy := 545;
var const global stmsmMdiActivate := 546;
var const global stmsmMdiRestore := 547;
var const global stmsmMdiNext := 548;
var const global stmsmMdiMaximize := 549;
var const global stmsmMdiTile := 550;
var const global stmsmMdiCascade := 551;
var const global stmsmMdiIconArrange := 552;
var const global stmsmMdiGetActive := 553;
var const global stmsmMdiSetMenu := 560;
var const global stmsmEntErSizeMove := 561;
var const global stmsmExitSizeMove := 562;
var const global stmsmDropFiles := 563;
var const global stmsmMDireFreshMenu := 564;
var const global stmsmMouseHover := 673;
var const global stmsmMouseLeave := 675;
var const global stmsmNCMouseHover := 672;
var const global stmsmNCMouseLeave := 674;
var const global stmsmWTsSession_Change := 689;
var const global stmsmTablet_First := 704;
var const global stmsmTablet_Last := 735;
var const global stmsmCut := 768;
var const global stmsmCopy := 769;
var const global stmsmPaste := 770;
var const global stmsmClear := 771;
var const global stmsmUndo := 772;
var const global stmsmRenderFormat := 773;
var const global stmsmRenderAllFormats := 774;
var const global stmsmDestroyClipboard := 775;
var const global stmsmDrawClipboard := 776;
var const global stmsmPaintClipboard := 777;
var const global stmsmVScrollClipboard := 778;
var const global stmsmSizeClipboard := 779;
var const global stmsmAskCBFormatName := 780;
var const global stmsmChangeCBChain := 781;
var const global stmsmHScrollClipboard := 782;
var const global stmsmQueryNewPalette := 783;
var const global stmsmPaletteIsChanging := 784;
var const global stmsmPaletteChanged := 785;
var const global stmsmHotKey := 786;
var const global stmsmPrint := 791;
var const global stmsmPrintClient := 792;
var const global stmsmAppCommand := 793;
var const global stmsmThemeChanged := 794;
var const global stmsmHandHeldFirst := 856;
var const global stmsmHandHeldLast := 863;
var const global stmsmPenWinFirst := 896;
var const global stmsmPenwinlast := 911;
var const global stmsmCoalesce_First := 912;
var const global stmsmCoalesce_Last := 927;
var const global stmsmDDE_First := 992;
var const global stmsmDDE_Initiate := 992;
var const global stmsmDDE_Terminate := 993;
var const global stmsmDDE_Advise := 994;
var const global stmsmDDE_UnAdvise := 995;
var const global stmsmDDE_ACK := 996;
var const global stmsmDDE_Data := 997;
var const global stmsmDDE_Request := 998;
var const global stmsmDDE_Poke := 999;
var const global stmsmDDE_Execute := 1000;
var const global stmsmDDE_Last := 1000;
var const global stmsmUser := 1024;
var const global stmsmApp := 32768;
