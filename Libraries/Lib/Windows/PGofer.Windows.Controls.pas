unit PGofer.Windows.Controls;

interface

uses
  Winapi.Windows, System.SysUtils;

  function WindowsShutDownReasonCreate(hWnd: HWND; pwszReason: LPCWSTR): BOOL; stdcall; external user32 name 'ShutdownBlockReasonCreate';
  function WindowsShutDownReasonDestroy(hWnd: HWND): BOOL; stdcall; external user32 name 'ShutdownBlockReasonDestroy';
  function WindowsShutDown( Off: Cardinal ): Boolean;
  function WindowsSetSuspendState( hibernate, forcecritical, disablewakeevent
    : Boolean ): Boolean; stdcall; external 'powrprof.dll' name 'SetSuspendState';
  function WindowsSetScreen( Height, Width, Monitor: Integer ): Boolean;
  function WindowsSetSendMessage( ClassName: string; Mss: Cardinal;
    wPar, lPar: Integer ): Integer;
  function WindowsPrtScreen( Height, Width, Top, Left: Integer;
    FileName: string ): Integer;
  function WindowsGetFindWindow( ClassName: string ): NativeInt;
  function WindowsGetWindowsTextFromPoint( ): string;
  function WindowsDialogMessage( Text: string ): Boolean;
  function WindowsMonitorPower( OnOff: Boolean ): NativeInt;
  function WindowsGetControlFocus( ): HDWP;
  // QueryPerformanceCounter(StartTime);
  // QueryPerformanceFrequency(Frequency);

implementation

uses
  Vcl.Graphics,
  System.UITypes, Vcl.Dialogs, Vcl.Forms;

function WindowsShutDown( Off: Cardinal ): Boolean;
var
  TokenPriv: TTokenPrivileges;
  H: DWORD;
  HToken: THandle;
begin
  setThreadExecutionState( ES_CONTINUOUS );
  OpenProcessToken( GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, HToken );
  LookUpPrivilegeValue( nil, 'SeShutdownPrivilege',
    TokenPriv.Privileges[ 0 ].Luid );
  TokenPriv.PrivilegeCount := 1;
  TokenPriv.Privileges[ 0 ].Attributes := SE_PRIVILEGE_ENABLED;
  H := 0;
  AdjustTokenPrivileges( HToken, False, TokenPriv, 0,
    PTokenPrivileges( nil )^, H );
  CloseHandle( HToken );
  Result := ExitWindowsEx( Off, 0 );
end;

function WindowsSetScreen( Height, Width, Monitor: Integer ): Boolean;
var
  lpDevMode: TDeviceMode;
begin
  Result := False;
  if EnumDisplaySettings( nil, 0, lpDevMode ) then
  begin
    lpDevMode.dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
    lpDevMode.dmPelsWidth := Width;
    lpDevMode.dmPelsHeight := Height;
    Result := ( ChangeDisplaySettings( lpDevMode, Monitor )
      = DISP_CHANGE_SUCCESSFUL );
  end; // enum
end;

function WindowsSetSendMessage( ClassName: string; Mss: Cardinal;
  wPar, lPar: Integer ): Integer;
var
  Prc: HWND;
  C: PWideChar;
begin
  C := PWideChar( ClassName );
  Prc := FindWindow( C, nil );
  if Prc = 0 then
    Prc := FindWindow( nil, C );
  // executar
  if Prc <> 0 then
    Result := SendMessage( Prc, Mss, wPar, lPar )
  else
    Result := Prc;
end;

function WindowsPrtScreen( Height, Width, Top, Left: Integer;
  FileName: string ): Integer;
var
  B: TBitmap;
  S: NativeInt;
  F: string;
begin
  // execute
  B := TBitmap.Create;
  B.Width := Width - Left;
  B.Height := Height - Top;
  S := GetDC( 0 );
  BitBlt( B.Canvas.Handle, 0, 0, Width, Height, S, Left, Top, SRCCOPY );
  F := FileName + 'ScreenShot(' + FormatDateTime( 'YYYY-MM-DD - HH-NN-SS',
    Date + Time ) + ').bmp';
  B.SaveToFile( F );
  Result := ReleaseDC( 0, S );
  B.Free;
end;

function WindowsGetFindWindow( ClassName: string ): NativeInt;
var
  C: PWideChar;
begin
  C := PWideChar( ClassName );
  Result := FindWindow( C, nil );
  if Result = 0 then
    Result := FindWindow( nil, C );
end;

function WindowsGetWindowsTextFromPoint( ): string;
var
  Buffer: string;
  txSize: Integer;
  cPoint: TPoint;
  Handle1, Handle2: NativeInt;
begin
  Buffer := '';
  GetCursorPos( cPoint );
  Handle2 := 0;
  Handle1 := WindowFromPoint( cPoint );
  if Handle1 <> 0 then
  begin
    txSize := GetWindowTextLength( Handle2 );
    if txSize > 0 then
    begin
      SetLength( Buffer, txSize );
      GetWindowText( Handle1, PWideChar( Buffer ), txSize + 1 );
    end;
  end;
  Result := Buffer;
end;

function WindowsDialogMessage( Text: string ): Boolean;
begin
  Result := MessageDlg( Text, mtConfirmation, [ mbYes, mbNo ], 0 ) = mrYes;
end;

function WindowsMonitorPower( OnOff: Boolean ): NativeInt;
begin
  // corrigir plataforma ???????????
  if not OnOff then
  begin
    // Windows XP e 2000
    SendMessage( Application.Handle, $0112, SC_MONITORPOWER, 1 );
    // Windows Vista 32/64 e Windows 7 32/64 e provavelmente os superiores.
    Result := SendMessage( Application.Handle, $0112, SC_MONITORPOWER, 2 );
  end
  else
    Result := SendMessage( Application.Handle, $0112, SC_MONITORPOWER, -1 );
end;

function WindowsGetControlFocus( ): HDWP;
var
  Wnd: HWND;
  TId, PId: DWORD;
begin
  Result := GetFocus( );
  if Result = 0 then
  begin
    Wnd := GetForegroundWindow( );
    if Wnd <> 0 then
    begin
      TId := GetWindowThreadProcessId( Wnd, PId );
      if AttachThreadInput( GetCurrentThreadId, TId, True ) then
      begin
        Result := GetFocus( );
        AttachThreadInput( GetCurrentThreadId, TId, False );
      end;
    end;
  end;
end;

end.
