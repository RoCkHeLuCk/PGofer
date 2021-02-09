program Timers;

uses
  Vcl.Forms,
  UnitTimer in 'UnitTimer.pas' {FrmTimers},
  PGofer.Files in '..\..\Lib\PGofer.Files.pas',
  PGofer.ListView in '..\..\Lib\PGofer.ListView.pas',
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas';

{$R *.res}

begin
    if BeforeInitialize('TFrmTimers',WM_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmTimers, FrmTimers);
        AfterInitialize(FrmTimers.Handle,WM_SETFOCUS);
        Application.Run;
    end;
end.
