unit PGofer.System.Controls;

interface

function SystemShutDown(Off: Cardinal): Boolean;
function SystemSetSuspendState(hibernate, forcecritical, disablewakeevent
  : Boolean): Boolean; stdcall; external 'powrprof.dll' name 'SetSuspendState';
function SystemSetScreen(Height, Width, Monitor: Integer): Boolean;
function SystemSetSendMessage(ClassName: String; Mss: Cardinal;
  wPar, lPar: Integer): Integer;
function SystemPrtScreen(Height, Width, Top, Left: Integer;
  FileName: String): Integer;
function SystemGetFindWindow(ClassName: String): NativeInt;
function SystemGetDateTimeNow(Format: String): String;
function SystemGetWindowsTextFromPoint(): String;
function SystemShowDialogMessage(Text: String;
  Tipo, Botoes, Botao: Word): Integer;
function SystemMonitorPower(OnOff: Boolean): NativeInt;
// QueryPerformanceCounter(StartTime);
// QueryPerformanceFrequency(Frequency);

implementation

uses
    WinApi.Windows, Vcl.Graphics, System.SysUtils,
    System.UITypes, Vcl.Dialogs, Vcl.Forms;

function SystemShutDown(Off: Cardinal): Boolean;
var
    TokenPriv: TTokenPrivileges;
    H: DWORD;
    HToken: THandle;
begin
    OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, HToken);
    LookUpPrivilegeValue(nil, 'SeShutdownPrivilege',
      TokenPriv.Privileges[0].Luid);
    TokenPriv.PrivilegeCount := 1;
    TokenPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    H := 0;
    AdjustTokenPrivileges(HToken, False, TokenPriv, 0,
      PTokenPrivileges(nil)^, H);
    CloseHandle(HToken);
    Result := ExitWindowsEx(Off, 0);
end;

function SystemSetScreen(Height, Width, Monitor: Integer): Boolean;
var
    lpDevMode: TDeviceMode;
begin
    Result := False;
    if EnumDisplaySettings(nil, 0, lpDevMode) then
    begin
        lpDevMode.dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
        lpDevMode.dmPelsWidth := Width;
        lpDevMode.dmPelsHeight := Height;
        Result := (ChangeDisplaySettings(lpDevMode, Monitor)
          = DISP_CHANGE_SUCCESSFUL);
    end; // enum
end;

function SystemSetSendMessage(ClassName: String; Mss: Cardinal;
  wPar, lPar: Integer): Integer;
var
    Prc: HWND;
    C: PWideChar;
begin
    C := PWideChar(ClassName);
    Prc := FindWindow(C, nil);
    if Prc = 0 then
        Prc := FindWindow(nil, C);
    // executar
    if Prc <> 0 then
        Result := SendMessage(Prc, Mss, wPar, lPar)
    else
        Result := Prc;
end;

function SystemPrtScreen(Height, Width, Top, Left: Integer;
  FileName: String): Integer;
var
    B: TBitmap;
    S: NativeInt;
    F: String;
begin
    // execute
    B := TBitmap.Create;
    B.Width := Width - Left;
    B.Height := Height - Top;
    S := GetDC(0);
    BitBlt(B.Canvas.Handle, 0, 0, Width, Height, S, Left, Top, SRCCOPY);
    F := FileName + 'ScreenShot(' + FormatDateTime('YYYY-MM-DD - HH-NN-SS',
      Date + Time) + ').bmp';
    B.SaveToFile(F);
    Result := ReleaseDC(0, S);
    B.Free;
end;

function SystemGetFindWindow(ClassName: String): NativeInt;
var
    C: PWideChar;
begin
    C := PWideChar(ClassName);
    Result := FindWindow(C, nil);
    if Result = 0 then
        Result := FindWindow(nil, C);
end;

function SystemGetDateTimeNow(Format: String): String;
begin
    Result := FormatDateTime(Format, now);
end;

function SystemGetWindowsTextFromPoint(): String;
var
    Buffer: String;
    txSize: Integer;
    cPoint: TPoint;
    Handle1, Handle2: NativeInt;
begin
    Buffer := '';
    GetCursorPos(cPoint);
    Handle2 := 0;
    Handle1 := WindowFromPoint(cPoint);
    if Handle1 <> 0 then
    begin
        txSize := GetWindowTextLength(Handle2);
        if txSize > 0 then
        begin
            SetLength(Buffer, txSize);
            GetWindowText(Handle1, PWideChar(Buffer), txSize + 1);
        end;
    end;
    Result := Buffer;
end;

function SystemShowDialogMessage(Text: String;
  Tipo, Botoes, Botao: Word): Integer;
begin
    { ??????????????
      Butao :=  TMsgDlgBtn( Trunc( Sqrt( Gramatica.Pilha.Desempilhar(0) )-1 ) );
      Butoes := TMsgDlgButtons( word( Gramatica.Pilha.Desempilhar(0)) );
      Tipo := TMsgDlgType( Gramatica.Pilha.Desempilhar(0) );
    }
    try
        Result := MessageDlg(Text, TMsgDlgType(Tipo), TMsgDlgButtons(Botoes), 0,
          TMsgDlgBtn(Botao));
    except
        Result := 9;
    end;

end;

function SystemMonitorPower(OnOff: Boolean): NativeInt;
begin
    // corrigir plataforma ???????????
    if not OnOff then
    begin
        // Windows XP e 2000
        SendMessage(Application.Handle, $0112, SC_MONITORPOWER, 1);
        // Windows Vista 32/64 e Windows 7 32/64 e provavelmente os superiores.
        Result := SendMessage(Application.Handle, $0112, SC_MONITORPOWER, 2);
    end
    else
        Result := SendMessage(Application.Handle, $0112, SC_MONITORPOWER, -1);
end;

end.
