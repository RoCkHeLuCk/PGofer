unit PGofer.Triggers.Links.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Dialogs, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers.Links, PGofer.Item.Frame,
  PGofer.Component.Edit, PGofer.Component.RichEdit;

type
  TPGLinkFrame = class( TPGItemFrame )
    LblFile: TLabel;
    LblParameter: TLabel;
    LblDirectory: TLabel;
    LblState: TLabel;
    LblPriority: TLabel;
    EdtFile: TEdit;
    BtnFile: TButton;
    EdtPatameter: TEdit;
    EdtDiretory: TEdit;
    BtnDiretory: TButton;
    CmbState: TComboBox;
    CmbPriority: TComboBox;
    BtnTest: TButton;
    OpdLinks: TOpenDialog;
    GrbScriptBefore: TGroupBox;
    EdtScriptBefore: TRichEditEx;
    GrbScriptAfter: TGroupBox;
    EdtScriptAfter: TRichEditEx;
    sptScriptBefore: TSplitter;
    ckbCapture: TCheckBox;
    sptScriptAfter: TSplitter;
    ckbAdministrator: TCheckBox;
    procedure CmbStateChange( Sender: TObject );
    procedure CmbPriorityChange( Sender: TObject );
    procedure BtnFileClick( Sender: TObject );
    procedure BtnDiretoryClick( Sender: TObject );
    procedure EdtNameKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure BtnTestClick( Sender: TObject );
    procedure EdtFileKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtPatameterKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtDiretoryKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtScriptBeforeKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtScriptAfterKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure ckbCaptureClick( Sender: TObject );
    procedure ckbAdministratorClick(Sender: TObject);
  private
    FItem: TPGLink;
    procedure isFileName( );
    procedure isDirectory( );
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGLinkFrame: TPGItemFrame;

implementation

uses
  System.SysUtils,
  PGofer.Files.Controls, PGofer.Sintatico,
  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TPGFrame1 }

constructor TPGLinkFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGLink( AItem );

  EdtFile.Text := FItem.FileName;
  isFileName( );

  EdtPatameter.Text := FItem.Parameter;
  EdtDiretory.Text := FItem.Directory;
  isDirectory( );

  CmbState.ItemIndex := FItem.State;
  CmbPriority.ItemIndex := FItem.Priority;
  ckbAdministrator.Checked := FItem.RunAdmin;
  ckbCapture.Checked := FItem.CaptureMsg;
  EdtScriptBefore.Lines.Text := FItem.ScriptBefor;
  EdtScriptAfter.Lines.Text := FItem.ScriptAfter;

  FrmAutoComplete.EditCtrlAdd( EdtScriptBefore );
  FrmAutoComplete.EditCtrlAdd( EdtScriptAfter );
end;

destructor TPGLinkFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtScriptBefore );
  FrmAutoComplete.EditCtrlRemove( EdtScriptAfter );
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGLinkFrame.BtnFileClick( Sender: TObject );
begin
  OpdLinks.Title := 'File';
  OpdLinks.Filter := 'All Files(*.*)|*.*';
  OpdLinks.InitialDir := FileLimitPathExist( EdtFile.Text );
  OpdLinks.FileName := ExtractFileName( EdtFile.Text );

  if OpdLinks.Execute then
  begin
    FItem.FileName := FileUnExpandPath( OpdLinks.FileName );
    FItem.Directory := FileUnExpandPath( ExtractFilePath( OpdLinks.FileName ) );
    EdtFile.Text := FItem.FileName;
    EdtDiretory.Text := FItem.Directory;
    isFileName( );
    isDirectory( );
  end;
end;

procedure TPGLinkFrame.BtnDiretoryClick( Sender: TObject );
begin
  FItem.Directory := FileUnExpandPath( FileDirDialog( EdtDiretory.Text ) );
  EdtDiretory.Text := FItem.Directory;
  isDirectory( );
end;

procedure TPGLinkFrame.BtnTestClick( Sender: TObject );
begin
  FItem.Triggering( );
end;

procedure TPGLinkFrame.ckbAdministratorClick(Sender: TObject);
begin
  FItem.RunAdmin := ckbAdministrator.Checked;
end;

procedure TPGLinkFrame.ckbCaptureClick( Sender: TObject );
begin
  FItem.CaptureMsg := ckbCapture.Checked;
  if ckbCapture.Checked then
  begin
    ckbAdministrator.Checked := True;
    ckbAdministrator.Enabled := False;
  end else begin
    ckbAdministrator.Enabled := True;
  end;
end;

procedure TPGLinkFrame.CmbStateChange( Sender: TObject );
begin
  FItem.State := CmbState.ItemIndex;
end;

procedure TPGLinkFrame.CmbPriorityChange( Sender: TObject );
begin
  FItem.Priority := CmbPriority.ItemIndex;
end;

procedure TPGLinkFrame.EdtFileKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.FileName := EdtFile.Text;
  isFileName( );
end;

procedure TPGLinkFrame.EdtDiretoryKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Directory := EdtDiretory.Text;
  isDirectory( );
end;

procedure TPGLinkFrame.EdtNameKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  if FItem.isItemExist( EdtName.Text, False ) then
  begin
    EdtName.Color := clRed;
  end else begin
    EdtName.Color := clWindow;
    inherited EdtNameKeyUp( Sender, Key, Shift );
  end;
end;

procedure TPGLinkFrame.EdtPatameterKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Parameter := EdtPatameter.Text;
end;

procedure TPGLinkFrame.EdtScriptAfterKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.ScriptAfter := EdtScriptAfter.Lines.Text;
end;

procedure TPGLinkFrame.EdtScriptBeforeKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.ScriptBefor := EdtScriptBefore.Lines.Text;
end;

procedure TPGLinkFrame.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  Self.GrbScriptBefore.Height := FIniFile.ReadInteger( Self.ClassName,
    'ScriptsBefore', Self.GrbScriptBefore.Height );
  Self.GrbScriptAfter.Height := FIniFile.ReadInteger( Self.ClassName,
    'ScriptsAfter', Self.GrbScriptAfter.Height );
end;

procedure TPGLinkFrame.IniConfigSave( );
begin
  FIniFile.WriteInteger( Self.ClassName, 'ScriptsBefore',
    Self.GrbScriptBefore.Height );
  FIniFile.WriteInteger( Self.ClassName, 'ScriptsAfter',
    Self.GrbScriptAfter.Height );
  inherited IniConfigSave( );
end;

procedure TPGLinkFrame.isDirectory;
begin
  if FItem.isDirExist then
    EdtDiretory.Color := clWindow
  else
    EdtDiretory.Color := clRed;
end;

procedure TPGLinkFrame.isFileName;
begin
  if FItem.isFileExist then
    EdtFile.Color := clWindow
  else
    EdtFile.Color := clRed;
end;

end.
