unit PGofer3.AutoLoading;

interface

procedure Initialize();
procedure AfterInitialize();
procedure BeforeFinalize();
procedure Finalize();

implementation

uses
  Winapi.Windows, Winapi.MMSystem,
  System.SysUtils,
  Vcl.Forms,
  { Kernel & Base }
  PGofer.Core,
  PGofer.Classes,
  PGofer.Runtime,

  { Interpreter }
  PGofer.Lexico,
  PGofer.Sintatico,
  PGofer.Sintatico.Controls,

  { Standard Libraries }
  PGofer.Standard.Variants,
  PGofer.Standard.Functions,
  PGofer.Standard.Environment,
  PGofer.Standard,

  { System Libraries }
  PGofer.ClipBoards,
  PGofer.Files,
  PGofer.Key,
  PGofer.Math,
  PGofer.Net,
  PGofer.Process,
  PGofer.Registry,
  PGofer.Scheduler,
  PGofer.Services,
  PGofer.Sound,
  PGofer.Windows,

  { Triggers System }
  PGofer.Triggers.Collections,
  PGofer.Triggers.Form,
  PGofer.Triggers,
  PGofer.Triggers.VaultFolder,
  PGofer.Triggers.AutoFills,
  PGofer.Triggers.HotKeys,
  PGofer.Triggers.Links,
  PGofer.Triggers.Tasks,

  { Forms & UI Management }
  PGofer.Forms,
  PGofer.Forms.Controller,
  PGofer.Forms.Console,
  PGofer.Forms.AutoComplete,
  PGofer.Forms.Controls;

procedure Initialize();
begin
  if not (PGofer.Forms.Controls.FormBeforeInitialize( 'TFrmPGofer' )) then
    Halt(0);

  {$IFDEF DEBUG}
    ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  SetPriorityClass( GetCurrentProcess, REALTIME_PRIORITY_CLASS );
  SetProcessPriorityBoost( GetCurrentProcess, False );
  SetProcessWorkingSetSize(GetCurrentProcess, 32 * 1024 * 1024, 64 * 1024 * 1024);
  SetProcessShutdownParameters($4FF, 0);
  timeBeginPeriod(1);

  // Kernerl
  PGofer.Core.Initialize;
  PGofer.Classes.Initialize;

  // Gramatica
  PGofer.Lexico.Initialize;
  PGofer.Sintatico.Initialize;

  // Standard
  PGofer.Standard.Variants.Initialize;
  PGofer.Standard.Functions.Initialize;

  // Triggers
  PGofer.Triggers.VaultFolder.Initialize;
  PGofer.Triggers.AutoFills.Initialize;
  PGofer.Triggers.HotKeys.Initialize;
  PGofer.Triggers.Links.Initialize;
  PGofer.Triggers.Tasks.Initialize;

  PGofer.Triggers.Initialize;
  PGofer.Runtime.Initialize;
end;

procedure AfterInitialize();
begin
  PGofer.Triggers.Tasks.TPGTask.Working( 0, False );
  PGofer.Forms.Controls.FormAfterInitialize( );
  {$IFDEF DEBUG}
    FrmController.Visible := True;
    FrmTriggerController.Visible := True;
  {$ENDIF}
end;

procedure BeforeFinalize();
var
  Index : Integer;
begin
  for Index := 1 to 10 do
  begin
    Application.ProcessMessages;
    if Screen.FormCount = 0 then Break;
    Sleep(10);
  end;

  PGofer.Core.BeforeFinalize;
end;

procedure Finalize();
begin
  // Triggers
  PGofer.Triggers.VaultFolder.Finalize;
  PGofer.Triggers.AutoFills.Finalize;
  PGofer.Triggers.HotKeys.Finalize;
  PGofer.Triggers.Links.Finalize;
  PGofer.Triggers.Tasks.Finalize;

  PGofer.Triggers.Finalize;

  // Standard
  PGofer.Standard.Variants.Finalize;
  PGofer.Standard.Functions.Finalize;

  // Gramatica
  PGofer.Runtime.Finalize;
  PGofer.Sintatico.Finalize;
  PGofer.Lexico.Finalize;

  // Kernerl
  PGofer.Classes.Finalize;
  PGofer.Core.Finalize;
end;

end.
