unit PGofer.Windows;

interface

uses
  PGofer.Runtime, PGofer.Windows.Input;

type

{$M+}
  TPGWindows = class(TPGItemClass)
  private
    FCanOff: Boolean;
    FMouse: TPGMouse;
    procedure SetCanOff(Value: Boolean);
  protected
  public
  published
    property CanOff: Boolean read FCanOff write SetCanOff;
    property Mouse: TPGMouse read FMouse;
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

var
   PGWindows: TPGWindows;

implementation

uses
  WinApi.Windows,
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.Dialogs,
  PGofer.Core, PGofer.Windows.Controls, PGofer.Windows.VirtualDesktop;

{ TPGWindows }

function TPGWindows.FindWindow(Valor: string): NativeUInt;
begin
  Result := WindowsGetFindWindow(Valor);
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
  if FCanOff <> Value then
  begin
    FCanOff := Value;
    if not FCanOff then
    begin
      WindowsShutDownReasonCreate(Application.Handle, PWideChar('PGofer: Shutdown Block!'));
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

PGWindows := TPGWindows.Create(GlobalItemCommand);

finalization

PGWindows := nil;

end.
