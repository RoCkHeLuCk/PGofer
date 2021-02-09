program Links;

uses
  Vcl.Forms,
  UnitLinks in 'UnitLinks.pas' {FrmLinks},
  PGofer.Controls in '..\..\Lib\PGofer.Controls.pas',
  PGofer.TreeView in '..\..\Lib\PGofer.TreeView.pas',
  PGofer.Links in '..\..\Lib\PGofer.Links.pas',
  PGofer.Files in '..\..\Lib\PGofer.Files.pas',
  PGofer.Classes in '..\..\Lib\PGofer.Classes.pas';

{$R *.res}

begin
    {$IFDEF DEBUG}
        ReportMemoryLeaksOnShutdown:=true;
    {$ENDIF}
    if BeforeInitialize('TFrmLinks',WM_SETFOCUS) then
    begin
        Application.Initialize;
        Application.MainFormOnTaskbar := True;
        Application.CreateForm(TFrmLinks, FrmLinks);
        AfterInitialize(FrmLinks.Handle,WM_SETFOCUS);
        Application.Run;
    end;
end.
