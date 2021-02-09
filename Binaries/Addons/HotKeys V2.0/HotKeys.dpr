program HotKeys;

uses
  Vcl.Forms,
  UnitHotKeys in 'UnitHotKeys.pas' {FrmHotKeys},
  UnitDetectar in 'UnitDetectar.pas' {FrmDetectar},
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas',
  PGofer.HotKey in '..\..\Lib\PGofer.HotKey.pas',
  PGofer.TreeView in '..\..\Lib\PGofer.TreeView.pas',
  PGofer.Classes in '..\..\Lib\PGofer.Classes.pas',
  PGofer.Key.Controls in '..\..\Lib\PGofer.Key.Controls.pas';

{$R *.res}

begin
    {$IFDEF DEBUG}
        ReportMemoryLeaksOnShutdown:=true;
    {$ENDIF}
    if BeforeInitialize('TFrmHotKeys',WM_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmHotKeys, FrmHotKeys);
  AfterInitialize(FrmHotKeys.Handle,WM_SETFOCUS);
        Application.Run;
    end;
end.
