unit PGofer.Forms.Controls;

interface

uses
    Vcl.Forms, Vcl.ComCtrls,
    WinApi.Windows, WinApi.Messages,
    System.IniFiles, System.SysUtils, System.Classes;

const
    WM_SETFOCUS     = WM_SETFOCUS;
    WM_PG_HIDE      = WM_USER + 1;
    WM_PG_NOFOCUS   = WM_USER + 2;
    WM_PG_SETFOCUS  = WM_USER + 3;
    WM_PG_CLOSE     = WM_USER + 4;
    WM_PG_SCRIPT    = WM_USER + 5;
    WM_PG_LINKUPD   = WM_USER + 6;
    WM_PG_HOTHEYUPD = WM_USER + 7;

function FormAfterInitialize(H: THandle; DefaultWM: Cardinal): Boolean;
function FormBeforeInitialize(Classe: PWideChar; DefaultWM: Cardinal): Boolean;
procedure FormForceShow(Form: TForm; Focus: Boolean);
procedure FormPositionFixed(Form: TForm);
procedure FormIniLoadFromFile(Form: TForm; FileName: String;
    Lista: TListView = nil);
procedure FormIniSaveToFile(Form: TForm; FileName: String; Lista: TListView = nil);
procedure OnMessage(var Message: TMessage);
procedure SendScript(Text: String);
procedure LinkUpdate();

implementation


// ---------------------------------------------------------------------------//
function FormAfterInitialize(H: THandle; DefaultWM: Cardinal): Boolean;
var
    Parametro: String;
begin
    // se a janela exixte
    if (H <> 0) then
    begin
        Result := False;
        // procura parametros e envia mensagem
        if FindCmdLineSwitch('Duplicate', True) then
            Result := True;

        if FindCmdLineSwitch('Hide', True) then
            SendMessage(H, WM_PG_HIDE, 0, 0)
        else if FindCmdLineSwitch('NoFocus', True) then
            SendMessage(H, WM_PG_NOFOCUS, 0, 0)
        else if FindCmdLineSwitch('SetFocus', True) then
            SendMessage(H, WM_PG_SETFOCUS, 0, 0)
        else if FindCmdLineSwitch('Close', True) then
            SendMessage(H, WM_PG_CLOSE, 0, 0)
        else if FindCmdLineSwitch('Script', Parametro, True,
            [clstValueNextParam, clstValueAppended]) then
            SendMessage(H, WM_PG_SCRIPT, Length(Parametro),
                GlobalAddAtom(PChar(Parametro)))
        else
            SendMessage(H, DefaultWM, 0, 0);
    end
    else
        Result := True;

end;
// ---------------------------------------------------------------------------//
function FormBeforeInitialize(Classe: PWideChar; DefaultWM: Cardinal): Boolean;
begin
    Result := FormAfterInitialize(FindWindow(Classe, nil), DefaultWM);
end;
// ---------------------------------------------------------------------------//
procedure FormForceShow(Form: TForm; Focus: Boolean);
var
    ForegroundThreadID: Cardinal;
    ThisThreadID: Cardinal;
    timeout: Cardinal;
    c: NativeInt;
begin
    // WS_OVERLAPPED or WS_EX_OVERLAPPEDWINDOW sobreposta
    // WS_EX_APPWINDOW visivilidade
    // WS_EX_TOPMOST SetWindowPos

    if Focus then
    begin
        Form.Show;
        ShowWindow(Form.Handle, Integer(Form.WindowState));
        SetForegroundWindow(Form.Handle);
        ThisThreadID := SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW;
    end
    else
    begin
        Form.Visible := True;
        ThisThreadID := SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE;
    end;

    c := BeginDeferWindowPos(1);
    c := DeferWindowPos(c, Form.Handle, HWND_TOPMOST, Form.Left, Form.Top,
        Form.Width, Form.Height, ThisThreadID);
    EndDeferWindowPos(c);

    SetWindowPos(Form.Handle, HWND_TOPMOST, Form.Left, Form.Top, Form.Width,
        Form.Height, ThisThreadID);

    if Focus then
    begin
        BringWindowToTop(Form.Handle);
        Form.SetFocus;

        if IsIconic(Form.Handle) then
            ShowWindow(Form.Handle, SW_RESTORE);

        if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4))
            or ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
            ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and
            (Win32MinorVersion > 0)))) then
        begin
            ForegroundThreadID := GetWindowThreadProcessID
                (GetForegroundWindow, nil);
            ThisThreadID := GetWindowThreadProcessID(Form.Handle, nil);
            if AttachThreadInput(ThisThreadID, ForegroundThreadID, True) then
            begin
                BringWindowToTop(Form.Handle);
                SetForegroundWindow(Form.Handle);
                AttachThreadInput(ThisThreadID, ForegroundThreadID, False);
            end;
            SystemParametersInfo($2000, 0, @timeout, 0);
            SystemParametersInfo($2001, 0, Pointer(0), SPIF_SENDCHANGE);
            BringWindowToTop(Form.Handle);
            SetForegroundWindow(Form.Handle);
            SystemParametersInfo($2001, 0, Pointer(timeout), SPIF_SENDCHANGE);
        end
        else
        begin
            BringWindowToTop(Form.Handle);
            SetForegroundWindow(Form.Handle);
        end;
    end;
end;

// ----------------------------------------------------------------------------//
procedure FormPositionFixed(Form: TForm);
begin
    // verifica posiçoes na tela
    if (Form.Left < Screen.WorkAreaLeft) then
        Form.Left := 0
    else if (Form.Left > Screen.WorkAreaWidth - Form.Width) then
        Form.Left := Screen.WorkAreaWidth - Form.Width;

    if (Form.Top < Screen.WorkAreaTop) then
        Form.Top := 0
    else if (Form.Top > Screen.WorkAreaHeight - Form.Height) then
        Form.Top := Screen.WorkAreaHeight - Form.Height;
end;

// ----------------------------------------------------------------------------//
procedure FormIniLoadFromFile(Form: TForm; FileName: String;
    Lista: TListView = nil);
var
    ini: TIniFile;
    c: Integer;
begin
    // carrega o config
    ini := TIniFile.Create(FileName);
    Form.Left := ini.ReadInteger(Form.Name, 'Left', Form.Left);
    Form.Top := ini.ReadInteger(Form.Name, 'Top', Form.Top);
    Form.Width := ini.ReadInteger(Form.Name, 'Width', Form.Width);
    Form.Height := ini.ReadInteger(Form.Name, 'Height', Form.Height);
    FormPositionFixed(Form);
    if ini.ReadBool(Form.Name, 'Maximized', False) then
        Form.WindowState := wsMaximized;

    // Carrega colunas
    if Lista <> nil then
    begin
        for c := 0 to Lista.Columns.Count - 1 do
            Lista.Column[c].Width := ini.ReadInteger(Form.Name,
                'Width' + IntToStr(c), Lista.Column[c].Width);
        Lista.ViewStyle := TViewStyle(ini.ReadInteger(Form.Name, 'Style',
            Integer(Lista.ViewStyle)));
    end;

    ini.Free;
end;

// ----------------------------------------------------------------------------//
procedure FormIniSaveToFile(Form: TForm; FileName: String; Lista: TListView = nil);
var
    ini: TIniFile;
    c: Integer;
begin
    // salvar configurações no Ini
    ini := TIniFile.Create(FileName);

    // salva forms
    FormPositionFixed(Form);
    if Form.WindowState <> wsMaximized then
    begin
        ini.WriteInteger(Form.Name, 'Left', Form.Left);
        ini.WriteInteger(Form.Name, 'Top', Form.Top);
        ini.WriteInteger(Form.Name, 'Width', Form.Width);
        ini.WriteInteger(Form.Name, 'Height', Form.Height);
        ini.WriteBool(Form.Name, 'Maximized', False);
    end
    else
        ini.WriteBool(Form.Name, 'Maximized', True);

    // Salva Colunas
    if Lista <> nil then
    begin
        for c := 0 to Lista.Columns.Count - 1 do
            ini.WriteInteger(Form.Name, 'Width' + IntToStr(c),
                Lista.Column[c].Width);
        ini.WriteInteger(Form.Name, 'Style', Integer(Lista.ViewStyle));
    end;
    ini.Free;
end;

// ---------------------------------------------------------------------------//
procedure OnMessage(var Message: TMessage);
var
    Parametro: String;
    Buffer: PChar;
begin
    case Message.Msg of
        WM_PG_HIDE:
            begin
                Application.ShowMainForm := False;
                Application.MainForm.Hide;
            end;
        WM_PG_NOFOCUS:
            begin
                FormForceShow(Application.MainForm, False);
                if Assigned(Application.MainForm.OnActivate) then
                    Application.MainForm.OnActivate(nil);
            end;
        WM_PG_SETFOCUS:
            begin
                FormForceShow(Application.MainForm, True);
            end;
        WM_PG_CLOSE:
            begin
                Application.Terminate;
            end;
        WM_PG_SCRIPT:
            begin
                Buffer := StrAlloc(Message.WParam + 1);
                GlobalGetAtomName(Message.LParam, Buffer, Message.WParam + 1);
                Parametro := StrPas(Buffer);
                StrDispose(Buffer);
                GlobalDeleteAtom(Message.LParam);
                // CompilarComando ( Parametro, nil );
            end;
        WM_MOUSEACTIVATE:
            begin
                Message.Result := MA_NOACTIVATE;
            end;
        WM_NCLBUTTONDOWN:
            begin
                if TWMNCLButtonDown(Message).HitTest = HTCAPTION then
                    Application.BringToFront;
            end;
    end;
end;

// ----------------------------------------------------------------------------//
procedure SendScript(Text: String);
var
    H: THandle;
begin
    H := FindWindow('TFrmPGofer', nil);
    if (H <> 0) then
        SendMessage(H, WM_PG_SCRIPT, Length(Text), GlobalAddAtom(PChar(Text)));
end;

// ----------------------------------------------------------------------------//
procedure LinkUpdate();
var
    H: THandle;
begin
    H := FindWindow('TFrmPGofer', nil);
    if (H <> 0) then
        SendMessage(H, WM_PG_LINKUPD, 0, 0);
end;
// ----------------------------------------------------------------------------//

end.
