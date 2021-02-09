program AutoKeys;

uses
  Vcl.Forms,
  UnitAutoKeys in 'UnitAutoKeys.pas' {FrmAutoKeysA},
  UnitAutoKeysConfig in 'UnitAutoKeysConfig.pas' {FrmAutoKeysConfig},
  PGofer.Key in '..\..\Lib\PGofer.Key.pas',
  PGofer.ClipBoards in '..\..\Lib\PGofer.ClipBoards.pas',
  PGofer.ZLib in '..\..\Lib\PGofer.ZLib.pas',
  UnitPassWord in 'UnitPassWord.pas' {FrmPassword},
  PGofer.TreeView in '..\..\Lib\PGofer.TreeView.pas',
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas';

{$R *.res}

begin
    {$IFDEF DEBUG}
        ReportMemoryLeaksOnShutdown:=true;
    {$ENDIF}
    if BeforeInitialize('TFrmAutoKeysA',WM_PG_NOFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmAutoKeysA, FrmAutoKeysA);
        AfterInitialize(FrmAutoKeysA.Handle,WM_PG_NOFOCUS);
        Application.Run;
    end;
end.
