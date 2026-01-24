unit PGofer.Windows.VirtualDesktop;

interface

uses
  WinApi.Windows, System.SysUtils, ActiveX, Comobj;

const
  IID_VDM: TGUID = '{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}';
  CLSID_VDM: TGUID = '{AA509086-5CA9-4C25-8F95-589D3C07B48A}';

type
  {$EXTERNALSYM IVirtualDesktopManager}
  IVirtualDesktopManager = interface(IUnknown)
    ['{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}']
    function IsWindowOnCurrentVirtualDesktop(Wnd: Cardinal; var IsTrue: Boolean): HResult; stdcall;
    function GetWindowDesktopId(Wnd: Cardinal; pDesktopID: PGUID): HResult; stdcall;
    function MoveWindowToDesktop(Wnd: Cardinal; DesktopID: PGUID): HResult; stdcall;
  end;

  function GetDesktopIdFromWindow(Wnd: Cardinal): TGUID;
  function MoveToCurrentDesktop(TargetWnd: Cardinal): Boolean;

implementation

function GetDesktopIdFromWindow(Wnd: Cardinal): TGUID;
var
  vdm: IVirtualDesktopManager;
begin
  Result := TGUID.Empty;
  CoInitialize(nil);
  try
    if Succeeded(CoCreateInstance(CLSID_VDM, nil, CLSCTX_INPROC_SERVER, IVirtualDesktopManager, vdm)) then
    begin
      vdm.GetWindowDesktopId(Wnd, @Result);
    end;
  finally
    CoUninitialize;
  end;
end;

function MoveToCurrentDesktop(TargetWnd: Cardinal): Boolean;
var
  vdm: IVirtualDesktopManager;
  ForeWnd: Cardinal;
  CurrentDesktopID: TGUID;
  IsOnCurrent: Boolean;
begin
  Result := False;

  // 1. Descobrir qual é a janela que o usuário está olhando
  ForeWnd := GetForegroundWindow;
  if ForeWnd = 0 then
    ForeWnd := GetDesktopWindow;

  // 2. Descobrir o ID do Desktop dessa janela
  CurrentDesktopID := GetDesktopIdFromWindow(ForeWnd);

  // Se não conseguimos identificar o desktop atual, aborta
  if IsEqualGUID(CurrentDesktopID, TGUID.Empty) then
    Exit;

  // 3. Mover a janela alvo para lá
  CoInitialize(nil);
  try
    if Succeeded(CoCreateInstance(CLSID_VDM, nil, CLSCTX_INPROC_SERVER, IVirtualDesktopManager, vdm)) then
    begin
      if Succeeded(vdm.IsWindowOnCurrentVirtualDesktop(TargetWnd, IsOnCurrent)) and (not IsOnCurrent) then
      if Succeeded(vdm.MoveWindowToDesktop(TargetWnd, @CurrentDesktopID)) then
        Result := True;
    end;
  finally
    CoUninitialize;
  end;
end;

end.
