program HotKeys;

uses
  Vcl.Forms,
  UnitHotKey in 'UnitHotKey.pas' {FrmHotKeys},
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas',
  PGofer.Files in '..\..\Lib\PGofer.Files.pas',
  PGofer.Key in '..\..\Lib\PGofer.Key.pas',
  PGofer.ListView in '..\..\Lib\PGofer.ListView.pas';

{$R *.res}

begin
    if BeforeInitialize('TFrmHotKeys',WM_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmHotKeys, FrmHotKeys);
        AfterInitialize(FrmHotKeys.Handle,WM_SETFOCUS);
        Application.Run;
    end;
end.
