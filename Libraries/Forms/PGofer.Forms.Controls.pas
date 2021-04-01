unit PGofer.Forms.Controls;

interface

uses
  Vcl.Forms, Vcl.ComCtrls, Vcl.Menus,
  WinApi.Windows, WinApi.Messages,
  System.SysUtils, System.Classes;

const
  WM_SETFOCUS = WM_SETFOCUS;
  WM_PG_HIDE = WM_USER + 1;
  WM_PG_NOFOCUS = WM_USER + 2;
  WM_PG_SETFOCUS = WM_USER + 3;
  WM_PG_CLOSE = WM_USER + 4;
  WM_PG_SCRIPT = WM_USER + 5;
  WM_PG_LINKUPD = WM_USER + 6;
  WM_PG_HOTHEYUPD = WM_USER + 7;

function FormAfterInitialize( H: THandle; DefaultWM: Cardinal ): Boolean;
function FormBeforeInitialize( Classe: PWideChar; DefaultWM: Cardinal )
   : Boolean;
procedure FormForceShow( Form: TForm; Focus: Boolean );
procedure OnMessage( var AMessage: TMessage );
procedure SendScript( Text: string );
procedure LinkUpdate( );

implementation

uses
  PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Controls;

function FormAfterInitialize( H: THandle; DefaultWM: Cardinal ): Boolean;
var
  Parametro: string;
begin
  // se a janela exixte
  if ( H <> 0 ) then
  begin
    Result := False;
    // procura parametros e envia mensagem
    if FindCmdLineSwitch( 'Duplicate', True ) then
      Result := True;
    if FindCmdLineSwitch( 'Hide', True ) then
      SendMessage( H, WM_PG_HIDE, 0, 0 )
    else if FindCmdLineSwitch( 'NoFocus', True ) then
      SendMessage( H, WM_PG_NOFOCUS, 0, 0 )
    else if FindCmdLineSwitch( 'SetFocus', True ) then
      SendMessage( H, WM_PG_SETFOCUS, 0, 0 )
    else if FindCmdLineSwitch( 'Close', True ) then
      SendMessage( H, WM_PG_CLOSE, 0, 0 )
    else if FindCmdLineSwitch( 'Script', Parametro, True,
       [ clstValueNextParam, clstValueAppended ] ) then
      SendMessage( H, WM_PG_SCRIPT, Length( Parametro ),
         GlobalAddAtom( PChar( Parametro ) ) )
    else
      SendMessage( H, DefaultWM, 0, 0 );
  end
  else
    Result := True;
end;

function FormBeforeInitialize( Classe: PWideChar; DefaultWM: Cardinal )
   : Boolean;
begin
  Result := FormAfterInitialize( FindWindow( Classe, nil ), DefaultWM );
end;

procedure FormForceShow( Form: TForm; Focus: Boolean );
var
  ForegroundThreadID: Cardinal;
  ThisThreadID: Cardinal;
  timeout: Cardinal;
  C: NativeInt;
begin
  // WS_OVERLAPPED or WS_EX_OVERLAPPEDWINDOW sobreposta
  // WS_EX_APPWINDOW visivilidade
  // WS_EX_TOPMOST SetWindowPos
  if Focus then
  begin
    Form.Show;
    ShowWindow( Form.Handle, Integer( Form.WindowState ) );
    SetForegroundWindow( Form.Handle );
    ThisThreadID := SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE;
  end else begin
    Form.Visible := True;
    ThisThreadID := SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE;
  end;
  try
    C := BeginDeferWindowPos( 1 );
    C := DeferWindowPos( C, Form.Handle, HWND_TOPMOST, Form.Left, Form.Top,
       Form.Width, Form.Height, ThisThreadID );
    EndDeferWindowPos( C );
  except
    // windows bugado do carai.
  end;

  SetWindowPos( Form.Handle, HWND_TOPMOST, Form.Left, Form.Top, Form.Width,
     Form.Height, ThisThreadID );

  if Focus then
  begin
    BringWindowToTop( Form.Handle );
    Form.SetFocus;

    if IsIconic( Form.Handle ) then
      ShowWindow( Form.Handle, SW_RESTORE );

    if ( ( Win32Platform = VER_PLATFORM_WIN32_NT ) and ( Win32MajorVersion > 4 )
       ) or ( ( Win32Platform = VER_PLATFORM_WIN32_WINDOWS ) and
       ( ( Win32MajorVersion > 4 ) or ( ( Win32MajorVersion = 4 ) and
       ( Win32MinorVersion > 0 ) ) ) ) then
    begin
      ForegroundThreadID := GetWindowThreadProcessID
         ( GetForegroundWindow, nil );
      ThisThreadID := GetWindowThreadProcessID( Form.Handle, nil );
      if AttachThreadInput( ThisThreadID, ForegroundThreadID, True ) then
      begin
        BringWindowToTop( Form.Handle );
        SetForegroundWindow( Form.Handle );
        AttachThreadInput( ThisThreadID, ForegroundThreadID, False );
      end;
      SystemParametersInfo( $2000, 0, @timeout, 0 );
      SystemParametersInfo( $2001, 0, Pointer( 0 ), SPIF_SENDCHANGE );
      BringWindowToTop( Form.Handle );
      SetForegroundWindow( Form.Handle );
      SystemParametersInfo( $2001, 0, Pointer( timeout ), SPIF_SENDCHANGE );
    end else begin
      BringWindowToTop( Form.Handle );
      // SetForegroundWindow(Form.Handle);
    end;

    // focusedThreadID := GetWindowThreadProcessID(wh, nil);
    // if AttachThreadInput(GetCurrentThreadID, focusedThreadID, true) then
    // try
    // Windows.SetFocus(h);
    // finally
    // AttachThreadInput(GetCurrentThreadID, focusedThreadID, false);
    // end;
    // PostMessage(edit2.handle,WM_SETFOCUS,0,0);
  end;

  Form.MakeFullyVisible( Form.Monitor );
end;

procedure OnMessage( var AMessage: TMessage );
var
  Parametro: string;
  Buffer: PChar;
begin
  case AMessage.Msg of
    WM_PG_HIDE:
    begin
      Application.ShowMainForm := False;
      Application.MainForm.Hide;
    end;

    WM_PG_NOFOCUS:
    begin
      FormForceShow( Application.MainForm, False );
      if Assigned( Application.MainForm.OnActivate ) then
        Application.MainForm.OnActivate( nil );
    end;

    WM_PG_SETFOCUS:
    begin
      FormForceShow( Application.MainForm, True );
    end;

    WM_PG_CLOSE:
    begin
      Application.Terminate;
    end;

    WM_PG_SCRIPT:
    begin
      Buffer := StrAlloc( AMessage.WParam + 1 );
      GlobalGetAtomName( AMessage.LParam, Buffer, AMessage.WParam + 1 );
      Parametro := StrPas( Buffer );
      StrDispose( Buffer );
      GlobalDeleteAtom( AMessage.LParam );
      ScriptExec( 'External', Parametro, nil, False );
    end;

    WM_MOUSEACTIVATE:
    begin
      AMessage.Result := MA_NOACTIVATE;
    end;

    WM_NCLBUTTONDOWN:
    begin
      if TWMNCLButtonDown( AMessage ).HitTest = HTCAPTION then
        Application.BringToFront;
    end;
  end;
end;

procedure SendScript( Text: string );
var
  H: THandle;
begin
  H := FindWindow( 'TFrmPGofer', nil );
  if ( H <> 0 ) then
    SendMessage( H, WM_PG_SCRIPT, Length( Text ),
       GlobalAddAtom( PChar( Text ) ) );
end;

procedure LinkUpdate( );
var
  H: THandle;
begin
  H := FindWindow( 'TFrmPGofer', nil );
  if ( H <> 0 ) then
    SendMessage( H, WM_PG_LINKUPD, 0, 0 );
end;

end.
