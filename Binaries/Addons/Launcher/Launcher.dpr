program Launcher;

uses
  WinApi.Windows,
  Winapi.ShellAPI,
  System.SysUtils;

  function FormBeforeInitialize(Classe: PWideChar): Boolean;
  const
    WM_PG_SETFOCUS =  $0400 + 1;
    WM_PG_SCRIPT   =  $0400 + 2;
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

var
  CurrentDir: PWideChar;
begin
  if not FormBeforeInitialize('TFrmPGofer') then
    Exit;

  CurrentDir := PWideChar( ExtractFilePath( ParamStr( 0 ) ) );
  ShellExecuteW( 0, 'open', PWideChar( CurrentDir + 'PGofer3.exe' ),
     PWideChar(GetCommandLine), CurrentDir, 1 );

  Sleep(1000);
  FormBeforeInitialize('TFrmPGofer');
end.
