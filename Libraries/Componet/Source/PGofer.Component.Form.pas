unit PGofer.Component.Form;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.IniFiles,
  Vcl.Controls, Vcl.Forms;

type
  TFormEx = class( TForm )
    procedure FormCreate( Sender: TObject );
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
    procedure FormDestroy( Sender: TObject );
  private
  protected
    FIniFile: TIniFile;
    FIniFileName: string;
    FForceResizable: boolean;
    procedure IniConfigSave( ); virtual;
    procedure IniConfigLoad( ); virtual;
    procedure WMNCHitTest( var AMessage: TWMNCHitTest ); message WM_NCHITTEST;
    procedure CreateParams( var AParams: TCreateParams ); override;
  public
    procedure ForceShow( AFocus: boolean ); virtual;
  published
    property IniFileName: string read FIniFileName write FIniFileName;
    property ForceResizable: boolean read FForceResizable write FForceResizable
      default False;
    // property ParentsColor: boolean read FParentsColor write FParentsColor default True;
  end;

  procedure SwitchToThisWindow(hWnd: HWND; fAltTab: BOOL); stdcall; external user32 name 'SwitchToThisWindow';

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents( 'PGofer', [ TFormEx ] );
end;

{$R *.dfm}
{ TFormEx }

procedure TFormEx.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  if Assigned(Application.MainForm) and (Application.MainForm <> Self) then
    AParams.WndParent := Application.MainForm.Handle;
end;

procedure TFormEx.FormCreate( Sender: TObject );
begin
  FIniFile := TIniFile.Create( ExtractFilePath( ParamStr( 0 ) ) +
    'Config.ini' );
  Self.IniConfigLoad( );
end;

procedure TFormEx.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  Self.IniConfigSave( );
end;

procedure TFormEx.FormDestroy( Sender: TObject );
begin
  Self.IniConfigSave( );
  FIniFile.Free;
end;

procedure TFormEx.IniConfigLoad( );
begin
  Self.Left := FIniFile.ReadInteger( Self.Name, 'Left', Self.Left );
  Self.Top := FIniFile.ReadInteger( Self.Name, 'Top', Self.Top );
  Self.ClientWidth := FIniFile.ReadInteger( Self.Name, 'Width',
    Self.ClientWidth );
  Self.ClientHeight := FIniFile.ReadInteger( Self.Name, 'Height',
    Self.ClientHeight );
  Self.MakeFullyVisible( Self.Monitor );
  if FIniFile.ReadBool( Self.Name, 'Maximized', False ) then
    Self.WindowState := wsMaximized;
end;

procedure TFormEx.IniConfigSave( );
begin
  Self.MakeFullyVisible( Self.Monitor );
  if Self.WindowState <> wsMaximized then
  begin
    FIniFile.WriteInteger( Self.Name, 'Left', Self.Left );
    FIniFile.WriteInteger( Self.Name, 'Top', Self.Top );
    FIniFile.WriteInteger( Self.Name, 'Width', Self.ClientWidth );
    FIniFile.WriteInteger( Self.Name, 'Height', Self.ClientHeight );
    FIniFile.WriteBool( Self.Name, 'Maximized', False );
  end
  else
    FIniFile.WriteBool( Self.Name, 'Maximized', true );
  FIniFile.UpdateFile;
end;

procedure TFormEx.WMNCHitTest( var AMessage: TWMNCHitTest );
const
  EDGEDETECT = 7; // adjust
var
  deltaRect: TRect;
begin
  inherited;
  if FForceResizable then
    with AMessage, deltaRect do
    begin
      Left := XPos - BoundsRect.Left;
      Right := BoundsRect.Right - XPos;
      Top := YPos - BoundsRect.Top;
      Bottom := BoundsRect.Bottom - YPos;
      if ( Top < EDGEDETECT ) and ( Left < EDGEDETECT ) then
        Result := HTTOPLEFT
      else if ( Top < EDGEDETECT ) and ( Right < EDGEDETECT ) then
        Result := HTTOPRIGHT
      else if ( Bottom < EDGEDETECT ) and ( Left < EDGEDETECT ) then
        Result := HTBOTTOMLEFT
      else if ( Bottom < EDGEDETECT ) and ( Right < EDGEDETECT ) then
        Result := HTBOTTOMRIGHT
      else if ( Top < EDGEDETECT ) then
        Result := HTTOP
      else if ( Left < EDGEDETECT ) then
        Result := HTLEFT
      else if ( Bottom < EDGEDETECT ) then
        Result := HTBOTTOM
      else if ( Right < EDGEDETECT ) then
        Result := HTRIGHT
    end;
end;


procedure TFormEx.ForceShow(AFocus: Boolean);
var
  ForegroundThreadID, ThisThreadID, timeout: Cardinal;
  hWinPosInfo: HDWP; // Handle da transação
begin
  //1. destrava o windows
  SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(0), SPIF_SENDCHANGE);
  AllowSetForegroundWindow(GetCurrentProcessId);

  //2. Prepara as flags
  ThisThreadID := SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE;
  if not AFocus then ThisThreadID := ThisThreadID or SWP_NOACTIVATE;

  //3. mostra a tela
  if AFocus then
  begin
    Self.Show;
    ShowWindow(Self.Handle, Integer(Self.WindowState));
    SetForegroundWindow(Self.Handle);
  end else begin
    Self.Visible := true;
    ShowWindow(Self.Handle, SW_SHOWNOACTIVATE);
  end;

  // 4. Tenta iniciar a transação para 1 janela
  hWinPosInfo := BeginDeferWindowPos(1);
  if hWinPosInfo <> 0 then
  begin
    // 5. Tenta adicionar a janela à transação
    hWinPosInfo := DeferWindowPos(hWinPosInfo, Self.Handle, HWND_TOPMOST,
                                 Self.Left, Self.Top, Self.Width, Self.Height,
                                 ThisThreadID);
    if hWinPosInfo <> 0 then
    begin
      // 6. Tenta aplicar tudo. Se falhar aqui, o Windows libera o handle sozinho.
      EndDeferWindowPos(hWinPosInfo);
    end;
  end;

  // 7. Joga tudo para o Topo
  SetWindowPos(Self.Handle, HWND_TOPMOST, Self.Left, Self.Top, Self.Width,
    Self.Height, ThisThreadID);

  // 8. Força para o topo com foco
  if AFocus then
  begin
    BringWindowToTop(Self.Handle);

    // [MODERNO] SwitchToThisWindow: O "fura-fila" para janelas exclusivas (Quake 3)
    SwitchToThisWindow(Self.Handle, True);

    if IsIconic(Self.Handle) then
      ShowWindow(Self.Handle, SW_RESTORE);

    ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow, nil);
    ThisThreadID := GetWindowThreadProcessID(Self.Handle, nil);

    if (ForegroundThreadID <> 0) and (ThisThreadID <> ForegroundThreadID) then
    begin
      if AttachThreadInput(ThisThreadID, ForegroundThreadID, true) then
      begin
        try
          BringWindowToTop(Self.Handle);
          SetForegroundWindow(Self.Handle);
          //// Reforço do foco para o Windows 11
          ///SwitchToThisWindow(Self.Handle, True);
        finally
          AttachThreadInput(ThisThreadID, ForegroundThreadID, False);
        end;
      end;
    end;

    // 9. controle de Timeout
    SystemParametersInfo($2000, 0, @timeout, 0);
    SystemParametersInfo($2001, 0, Pointer(0), SPIF_SENDCHANGE);
    BringWindowToTop(Self.Handle);
    SetForegroundWindow(Self.Handle);
    SystemParametersInfo($2001, 0, Pointer(timeout), SPIF_SENDCHANGE);

    SetWindowLong(Self.Handle, GWL_EXSTYLE,
      GetWindowLong(Self.Handle, GWL_EXSTYLE) or WS_EX_TOPMOST);

    Self.SetFocus;
  end;

  Self.MakeFullyVisible(Self.Monitor);
end;
//}


{ //OLD
procedure TFormEx.ForceShow( AFocus: boolean );
var
  ForegroundThreadID: Cardinal;
  ThisThreadID: Cardinal;
  timeout: Cardinal;
  C: NativeInt;
begin
  // WS_OVERLAPPED or WS_EX_OVERLAPPEDWINDOW sobreposta
  // WS_EX_APPWINDOW visivilidade
  // WS_EX_TOPMOST SetWindowPos
  if AFocus then
  begin
    Self.Show;
    ShowWindow( Self.Handle, Integer( Self.WindowState ) );
    SetForegroundWindow( Self.Handle );
    ThisThreadID := SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE;
  end else begin
    ShowWindow( Self.Handle, SW_SHOWNOACTIVATE );
    Self.Visible := true;
    ThisThreadID := SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_NOMOVE or
      SWP_NOSIZE;
  end;

  try
    C := BeginDeferWindowPos( 1 );
    if c <> 0 then
    begin
      C := DeferWindowPos( C, Self.Handle, HWND_TOPMOST, Self.Left, Self.Top,
        Self.Width, Self.Height, ThisThreadID );
    end;
    EndDeferWindowPos( C );
  except
    // windows bugado do carai.
  end;

  SetWindowPos( Self.Handle, HWND_TOPMOST, Self.Left, Self.Top, Self.Width,
    Self.Height, ThisThreadID );

  if AFocus then
  begin
    BringWindowToTop( Self.Handle );
    Self.SetFocus;

    if IsIconic( Self.Handle ) then
      ShowWindow( Self.Handle, SW_RESTORE );

    // if ( ( Win32Platform = VER_PLATFORM_WIN32_NT ) and ( Win32MajorVersion > 4 )
    // ) or ( ( Win32Platform = VER_PLATFORM_WIN32_WINDOWS ) and
    // ( ( Win32MajorVersion > 4 ) or ( ( Win32MajorVersion = 4 ) and
    // ( Win32MinorVersion > 0 ) ) ) ) then
    // begin
    ForegroundThreadID := GetWindowThreadProcessID( GetForegroundWindow, nil );
    ThisThreadID := GetWindowThreadProcessID( Self.Handle, nil );
    if AttachThreadInput( ThisThreadID, ForegroundThreadID, true ) then
    begin
      BringWindowToTop( Self.Handle );
      SetForegroundWindow( Self.Handle );
      AttachThreadInput( ThisThreadID, ForegroundThreadID, False );
    end;
    SystemParametersInfo( $2000, 0, @timeout, 0 );
    SystemParametersInfo( $2001, 0, Pointer( 0 ), SPIF_SENDCHANGE );
    BringWindowToTop( Self.Handle );
    SetForegroundWindow( Self.Handle );
    SystemParametersInfo( $2001, 0, Pointer( timeout ), SPIF_SENDCHANGE );
    // end else begin
    // BringWindowToTop( Self.Handle );
    // // SetForegroundWindow(Self.Handle);
    // end;

    // focusedThreadID := GetWindowThreadProcessID(wh, nil);
    // if AttachThreadInput(GetCurrentThreadID, focusedThreadID, true) then
    // try
    // Windows.SetFocus(h);
    // finally
    // AttachThreadInput(GetCurrentThreadID, focusedThreadID, false);
    // end;
    // PostMessage(edit2.handle,WM_SETFOCUS,0,0);
  end;

  Self.MakeFullyVisible( Self.Monitor );
end;
//}



end.
