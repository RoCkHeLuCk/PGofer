unit PGofer.System.VirtualDesktop;

interface

uses
    ActiveX, Comobj;

Const
    IID_VDM: TGUID   = '{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}';
    CLSID_VDM: TGUID = '{AA509086-5CA9-4C25-8F95-589D3C07B48A}';

type
    {$EXTERNALSYM IVirtualDesktopManager}
    IVirtualDesktopManager = interface(IUnknown)
        ['{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}']
        function IsWindowOnCurrentVirtualDesktop(Wnd: cardinal;
            var IsTrue: boolean): HResult; stdcall;
        function GetWindowDesktopId(Wnd: cardinal; pDesktopID: PGUID)
            : HResult; stdcall;
        function MoveWindowToDesktop(Wnd: cardinal; DesktopID: PGUID)
            : HResult; stdcall;
    end;

function IsOnCurrentDesktop(Wnd: cardinal): boolean;
procedure GetWindowDesktopId(Wnd: cardinal; pDesktopID: PGUID);
procedure MoveWindowToDesktop(Wnd: cardinal; DesktopID: PGUID);

implementation

function IsOnCurrentDesktop(Wnd: cardinal): boolean;
var
    vdm: IVirtualDesktopManager;
begin
    CoInitialize(nil);
    OleCheck(CoCreateInstance(CLSID_VDM, nil, CLSCTX_INPROC_SERVER,
        IVirtualDesktopManager, vdm));
    OleCheck(vdm.IsWindowOnCurrentVirtualDesktop(Wnd, result));
    CoUninitialize;
end;

procedure GetWindowDesktopId(Wnd: cardinal; pDesktopID: PGUID);
var
    vdm: IVirtualDesktopManager;
begin
    CoInitialize(nil);
    OleCheck(CoCreateInstance(CLSID_VDM, nil, CLSCTX_INPROC_SERVER,
        IVirtualDesktopManager, vdm));
    OleCheck(vdm.GetWindowDesktopId(Wnd, pDesktopID));
    CoUninitialize;
end;

procedure MoveWindowToDesktop(Wnd: cardinal; DesktopID: PGUID);
var
    vdm: IVirtualDesktopManager;
begin
    CoInitialize(nil);
    OleCheck(CoCreateInstance(CLSID_VDM, nil, CLSCTX_INPROC_SERVER,
        IVirtualDesktopManager, vdm));
    OleCheck(vdm.MoveWindowToDesktop(Wnd, DesktopID));
    CoUninitialize;
end;

end.
