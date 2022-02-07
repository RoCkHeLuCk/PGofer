unit PGofer.Component.Form;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.IniFiles,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

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
  public
    procedure ForceShow( AFocus: boolean ); virtual;
  published
    property IniFileName: string read FIniFileName write FIniFileName;
    property ForceResizable: boolean read FForceResizable write FForceResizable
      default False;
    // property ParentsColor: boolean read FParentsColor write FParentsColor default True;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents( 'PGofer', [ TFormEx ] );
end;

{$R *.dfm}
{ TFormEx }

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
    C := DeferWindowPos( C, Self.Handle, HWND_TOPMOST, Self.Left, Self.Top,
      Self.Width, Self.Height, ThisThreadID );
    // C := DeferWindowPos( C, Self.Handle, HWND_TOPMOST, 0, 0, 0, 0,
    // ThisThreadID );
    EndDeferWindowPos( C );
  except
    // windows bugado do carai.
  end;

  SetWindowPos( Self.Handle, HWND_TOPMOST, Self.Left, Self.Top, Self.Width,
    Self.Height, ThisThreadID );
  // SetWindowPos( Self.Handle, HWND_TOPMOST, 0, 0, 0, 0, ThisThreadID );

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

end.
