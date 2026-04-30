unit PGofer.Forms.Controls;

interface

uses
  WinApi.Messages, WinApi.Windows, System.SysUtils;

const
  WM_PG_SETFOCUS = WM_USER + 1;
  WM_PG_SCRIPT   = WM_USER + 2;
  MSGFLT_ALLOW = 1;

function ChangeWindowMessageFilterEx(hWnd: HWND; message: UINT; action: DWORD;
          pFilterStatus: Pointer): BOOL; stdcall; external 'user32.dll';
procedure PresetMessageFilter(AHandle: HWND);
procedure FormAfterInitialize();
function FormBeforeInitialize(Classe: PWideChar): Boolean;
procedure OnMessage(var AMessage: TMessage);

implementation

uses
  Vcl.Forms, PGofer.Runtime;

procedure PresetMessageFilter(AHandle: HWND);
begin
  if AHandle = 0 then Exit;

  ChangeWindowMessageFilterEx(AHandle, WM_PG_SETFOCUS, MSGFLT_ALLOW, nil);
  ChangeWindowMessageFilterEx(AHandle, WM_PG_SCRIPT, MSGFLT_ALLOW, nil);
end;

procedure FormAfterInitialize();
var
  LParam: string;
begin
  PresetMessageFilter( Application.MainForm.Handle );

  if FindCmdLineSwitch('script', LParam, True) then
    ScriptExec('External', LParam, nil, False)
  else
    Application.MainForm.Show;
end;

function FormBeforeInitialize(Classe: PWideChar): Boolean;
var
  H: HWND;
  LParam: string;
begin
  if FindCmdLineSwitch('Duplicate', True) then
    Exit(True);

  Result := True;
  H := FindWindow(Classe, nil);

  if H <> 0 then
  begin
    Result := False;

    if FindCmdLineSwitch('script', LParam, True) then
      SendMessage(H, WM_PG_SCRIPT, Length(LParam), GlobalAddAtom(PWideChar(LParam)))
    else
      SendMessage(H, WM_PG_SETFOCUS, 0, 0);
  end;
end;

procedure OnMessage(var AMessage: TMessage);
var
  Buffer: PWideChar;
  Parametro: string;
begin
  case AMessage.Msg of
    WM_PG_SETFOCUS:
    begin
      if Assigned(Application.MainForm) then
        Application.MainForm.Show;
    end;

    WM_PG_SCRIPT:
    begin
      Buffer := StrAlloc(AMessage.WParam + 1);
      try
        if GlobalGetAtomName(AMessage.LParam, Buffer, AMessage.WParam + 1) > 0 then
        begin
          Parametro := StrPas(Buffer);
          ScriptExec('External', Parametro, nil, False);
        end;
      finally
        StrDispose(Buffer);
        GlobalDeleteAtom(AMessage.LParam);
      end;
    end;

    WM_MOUSEACTIVATE:
    begin
       AMessage.Result := MA_NOACTIVATE;
    end;

    WM_NCLBUTTONDOWN:
    begin
      if TWMNCLButtonDown(AMessage).HitTest = HTCAPTION then
         Application.BringToFront;
    end;
  end;
end;

end.
