program AutoKeys;

uses
  Vcl.Forms,
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas',
  PGofer.TreeView in '..\..\Lib\PGofer.TreeView.pas',
  PGofer.Files in '..\..\Lib\PGofer.Files.pas',
  UnitAutoKeys in 'UnitAutoKeys.pas' {FrmAutoKeys},
  PGofer.AutoKeys in '..\..\Lib\PGofer.AutoKeys.pas',
  PGofer.Classes in '..\..\Lib\PGofer.Classes.pas';

{$R *.res}

begin
    {$IFDEF DEBUG}
        ReportMemoryLeaksOnShutdown:=true;
    {$ENDIF}
    if BeforeInitialize('TFrmAutoKeys',WM_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmAutoKeys, FrmAutoKeys);
        AfterInitialize(FrmAutoKeys.Handle,WM_SETFOCUS);
        Application.Run;
    end;
end.
