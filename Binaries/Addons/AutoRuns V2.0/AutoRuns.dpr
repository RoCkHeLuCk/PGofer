program AutoRuns;

uses
  Vcl.Forms,
  UnitAutoRuns in 'UnitAutoRuns.pas' {FrmAutoRuns},
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas',
  PGofer.TreeView in '..\..\Lib\PGofer.TreeView.pas',
  PGofer.Files in '..\..\Lib\PGofer.Files.pas',
  PGofer.AutoRuns in '..\..\Lib\PGofer.AutoRuns.pas',
  PGofer.Classes in '..\..\Lib\PGofer.Classes.pas';

{$R *.res}

begin
    {$IFDEF DEBUG}
        ReportMemoryLeaksOnShutdown:=true;
    {$ENDIF}
    if BeforeInitialize('TFrmAutoRuns',WM_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmAutoRuns, FrmAutoRuns);
  AfterInitialize(FrmAutoRuns.Handle,WM_SETFOCUS);
        Application.Run;
    end;
end.
