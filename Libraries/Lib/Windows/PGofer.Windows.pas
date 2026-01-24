unit PGofer.Windows;

interface

uses
  PGofer.Core, PGofer.Classes, PGofer.Runtime;

type

{$M+}
  [TPGAttribIcon(pgiWindows)]
  TPGWindows = class(TPGItemCMD)
  private
    FMouse: TPGItemCMD;
    procedure SetCanOff(Value: Boolean);
    function GetCanOff: Boolean;
  public
    constructor Create(AItemDad: TPGItem);
    destructor Destroy(); override;
    property Mouse: TPGItemCMD read FMouse;
  published
    property CanOff: Boolean read GetCanOff write SetCanOff;
    function DialogMessage(Text: string): Boolean;
    function FindWindow(Valor: string): NativeUInt;
    function GetTextFromPoint(): string;
    function LockWorkStation(): Boolean;
    function MonitorPower(OnOff: Boolean): NativeInt;
    function PrtScreen(Height, Width, Top, Left: Integer; FileName: string): Integer;
    function SendMessage(ClassName: string; Mss: Cardinal; wPar, lPar: Integer): Integer;
    function SetScreen(Height, Width, Monitor: Integer): Boolean;
    function SetSuspendState(Enabled: Boolean): Boolean;
    procedure ShowMessage(Texto: string);
    function ShutDown(Valor: Cardinal): Boolean;
    procedure MoveToCurrentDesktop();
  end;
{$TYPEINFO ON}

implementation

uses
  WinApi.Windows,
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.Dialogs,
  PGofer.Windows.Controls,
  PGofer.Windows.Input,
  PGofer.Windows.VirtualDesktop;

{ TPGWindows }

constructor TPGWindows.Create(AItemDad: TPGItem);
begin
  inherited Create(AItemDad);
  FMouse := TPGMouse.Create(Self);
end;

destructor TPGWindows.Destroy;
begin
  FMouse.Free;
  inherited Destroy();
end;

function TPGWindows.FindWindow(Valor: string): NativeUInt;
begin
  Result := WindowsGetFindWindow(Valor);
end;

function TPGWindows.GetCanOff: Boolean;
begin
  Result := TPGKernel.GetVar('CanOff', True);
end;

function TPGWindows.GetTextFromPoint: string;
begin
  Result := WindowsGetWindowsTextFromPoint();
end;

function TPGWindows.LockWorkStation: Boolean;
begin
  Result := WinApi.Windows.LockWorkStation();
end;

function TPGWindows.MonitorPower(OnOff: Boolean): NativeInt;
begin
  Result := WindowsMonitorPower(OnOff);
end;

procedure TPGWindows.MoveToCurrentDesktop;
begin
  RunInMainThread(
    procedure
    begin
      PGofer.Windows.VirtualDesktop.MoveToCurrentDesktop(Application.Handle);
    end
  );
end;

function TPGWindows.PrtScreen(Height, Width, Top, Left: Integer; FileName: string): Integer;
begin
  Result := WindowsPrtScreen(Height, Width, Top, Left, FileName);
end;

function TPGWindows.SendMessage(ClassName: string; Mss: Cardinal; wPar, lPar: Integer): Integer;
begin
  Result := WindowsSetSendMessage(ClassName, Mss, wPar, lPar);
end;

procedure TPGWindows.SetCanOff(Value: Boolean);
begin
  if TPGKernel.GetVar('CanOff', True) <> Value then
  begin
    TPGKernel.SetVar('CanOff', Value);
    if not Value then
    begin
      WindowsShutDownReasonCreate(Application.Handle, PWideChar('PGofer: Desligamento bloqueado!'));
    end else begin
      WindowsShutDownReasonDestroy(Application.Handle);
    end;
  end;
end;

function TPGWindows.SetScreen(Height, Width, Monitor: Integer): Boolean;
begin
  Result := WindowsSetScreen(Height, Width, Monitor);
end;

function TPGWindows.SetSuspendState(Enabled: Boolean): Boolean;
begin
  setThreadExecutionState(ES_CONTINUOUS);
  Result := WindowsSetSuspendState(Enabled, True, False);
end;

function TPGWindows.DialogMessage(Text: string): Boolean;
var
  R: Boolean;
begin
  RunInMainThread(
    procedure
    begin
      R := WindowsDialogMessage(Text);
    end
  );
  Result := R;
end;

procedure TPGWindows.ShowMessage(Texto: string);
begin
  RunInMainThread(
    procedure
    begin
      Vcl.Dialogs.ShowMessage(Texto);
    end
  );
end;

function TPGWindows.ShutDown(Valor: Cardinal): Boolean;
begin
  Result := WindowsShutDown(Valor);
end;

initialization

TPGWindows.Create(GlobalItemCommand);

finalization

end.
