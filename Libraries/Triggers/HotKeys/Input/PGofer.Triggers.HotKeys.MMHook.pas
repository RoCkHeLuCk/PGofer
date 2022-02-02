unit PGofer.Triggers.HotKeys.MMHook;

interface

uses
  WinApi.Windows,
  System.SysUtils;

type
  tagKBDLLHOOKSTRUCT = packed record
    dwVkCode: DWORD;
    dwScan: DWORD;
    dwFlags: DWORD;
    dwTime: DWORD;
    iExInfo: ULONG_PTR;
  end;

  KBDLLHOOKSTRUCT = tagKBDLLHOOKSTRUCT;
  PKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT;

  tagMSLLHOOKSTRUCT = record
    dx: LongInt;
    dy: LongInt;
    dwMData: DWORD;
    dwFlags: DWORD;
    dwTime: DWORD;
    dwExInfo: ULONG_PTR;
  end;

  TMSLLHOOKSTRUCT = tagMSLLHOOKSTRUCT;
  PMSLLHOOKSTRUCT = ^TMSLLHOOKSTRUCT;

  TLowLevelProc = function( Code: Integer; wParam: wParam; lParam: lParam )
    : LRESULT; stdcall;

implementation

end.
