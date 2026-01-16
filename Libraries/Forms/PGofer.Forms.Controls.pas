unit PGofer.Forms.Controls;

interface

uses
  WinApi.Messages;

const
  WM_SETFOCUS = WM_SETFOCUS;
  WM_PG_HIDE = WM_USER + 1;
  WM_PG_NOFOCUS = WM_USER + 2;
  WM_PG_SETFOCUS = WM_USER + 3;
  WM_PG_CLOSE = WM_USER + 4;
  WM_PG_SCRIPT = WM_USER + 5;
  WM_PG_LINKUPD = WM_USER + 6;
  WM_PG_HOTHEYUPD = WM_USER + 7;
  WM_PG_SHUTDOWN = WM_USER + 101;

function FormAfterInitialize( H: THandle; DefaultWM: Cardinal ): Boolean;
function FormBeforeInitialize( Classe: PWideChar; DefaultWM: Cardinal )
  : Boolean;
procedure OnMessage( var AMessage: TMessage );
procedure SendScript( Text: string );
procedure LinkUpdate( );

implementation

uses
  System.SysUtils,
  WinApi.Windows,
  Vcl.Forms,
  PGofer.Sintatico, PGofer.Triggers.Tasks;

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
      Result := True
    else if FindCmdLineSwitch( 'Hide', True ) then
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
        Application.MainForm.Visible := True;
        if Assigned( Application.MainForm.OnActivate ) then
          Application.MainForm.OnActivate( nil );
      end;

    WM_PG_SETFOCUS:
      begin
        Application.MainForm.Show;
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

    WM_PG_SHUTDOWN:
      begin
         TPGTask.Working( 2, False );
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
