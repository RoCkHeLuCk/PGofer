unit PGofer.Triggers.Links.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Dialogs, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers.Links, PGofer.Item.Frame,
  PGofer.Component.Edit, PGofer.Component.RichEdit,
  PGofer.Forms.AutoComplete;

type
  TPGLinkFrame = class( TPGFrame )
    LblFile: TLabel;
    LblParameter: TLabel;
    LblDirectory: TLabel;
    LblState: TLabel;
    LblPriority: TLabel;
    LblOperation: TLabel;
    EdtFile: TEdit;
    BtnFile: TButton;
    EdtPatameter: TEdit;
    EdtDiretory: TEdit;
    BtnDiretory: TButton;
    CmbState: TComboBox;
    CmbPriority: TComboBox;
    BtnTest: TButton;
    CmbOperation: TComboBox;
    OpdLinks: TOpenDialog;
    pnlScript: TPanel;
    GrbScriptBefore: TGroupBox;
    EdtScriptBefore: TRichEditEx;
    GrbScriptAfter: TGroupBox;
    EdtScriptAfter: TRichEditEx;
    Splitter1: TSplitter;
    ckbCapture: TCheckBox;
    procedure CmbStateChange( Sender: TObject );
    procedure CmbOperationChange( Sender: TObject );
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
    procedure Splitter1CanResize( Sender: TObject; var NewSize: Integer;
       var Accept: Boolean );
  private
    FItem: TPGLink;
    FFrmAutoCompleteBefore: TFrmAutoComplete;
    FFrmAutoCompleteAfter: TFrmAutoComplete;
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGLinkFrame: TPGFrame;

implementation

uses
  System.SysUtils, PGofer.Files.Controls, PGofer.Sintatico;
{$R *.dfm}
{ TPGFrame1 }

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
  end;
end;

procedure TPGLinkFrame.BtnDiretoryClick( Sender: TObject );
begin
  FItem.Directory := FileUnExpandPath( FileDirDialog( EdtDiretory.Text ) );
  EdtDiretory.Text := FItem.Directory;
end;

procedure TPGLinkFrame.BtnTestClick( Sender: TObject );
begin
  FItem.Triggering( );
end;

procedure TPGLinkFrame.ckbCaptureClick( Sender: TObject );
begin
  FItem.CaptureMsg := ckbCapture.Checked;
  if ckbCapture.Checked then
  begin
    CmbOperation.ItemIndex := 0;
    CmbOperation.Enabled := False;
    LblOperation.Enabled := False;
  end else begin
    CmbOperation.Enabled := True;
    LblOperation.Enabled := True;
  end;
end;

procedure TPGLinkFrame.CmbStateChange( Sender: TObject );
begin
  FItem.State := CmbState.ItemIndex;
end;

procedure TPGLinkFrame.CmbOperationChange( Sender: TObject );
begin
  FItem.Operation := CmbOperation.ItemIndex;
end;

procedure TPGLinkFrame.CmbPriorityChange( Sender: TObject );
begin
  FItem.Priority := CmbPriority.ItemIndex;
end;

constructor TPGLinkFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGLink( AItem );
  EdtFile.Text := FItem.FileName;
  EdtPatameter.Text := FItem.Parameter;
  EdtDiretory.Text := FItem.Directory;
  CmbState.ItemIndex := FItem.State;
  CmbPriority.ItemIndex := FItem.Priority;
  CmbOperation.ItemIndex := FItem.Operation;
  ckbCapture.Checked := FItem.CaptureMsg;
  EdtScriptBefore.Lines.Text := FItem.ScriptBefor;
  EdtScriptAfter.Lines.Text := FItem.ScriptAfter;
  FFrmAutoCompleteBefore := TFrmAutoComplete.Create( EdtScriptBefore );
  FFrmAutoCompleteAfter := TFrmAutoComplete.Create( EdtScriptAfter );
end;

destructor TPGLinkFrame.Destroy;
begin
  FItem := nil;
  FFrmAutoCompleteBefore.Free( );
  FFrmAutoCompleteAfter.Free( );
  inherited Destroy( );
end;

procedure TPGLinkFrame.EdtFileKeyUp( Sender: TObject; var Key: Word;
   Shift: TShiftState );
begin
  FItem.FileName := EdtFile.Text;
  if FItem.isFileExist then
    EdtFile.Color := clWindow
  else
    EdtFile.Color := clRed;
end;

procedure TPGLinkFrame.EdtDiretoryKeyUp( Sender: TObject; var Key: Word;
   Shift: TShiftState );
begin
  FItem.Directory := EdtDiretory.Text;
  if FItem.isDirExist then
    EdtDiretory.Color := clWindow
  else
    EdtDiretory.Color := clRed;
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
  Self.GrbScriptAfter.Height := FIniFile.ReadInteger( Self.ClassName, 'Scripts',
     Self.GrbScriptAfter.Height );
end;

procedure TPGLinkFrame.IniConfigSave( );
begin
  FIniFile.WriteInteger( Self.ClassName, 'Scripts',
     Self.GrbScriptAfter.Height );
  inherited IniConfigSave( );
end;

procedure TPGLinkFrame.Splitter1CanResize( Sender: TObject;
   var NewSize: Integer; var Accept: Boolean );
begin
  Accept := ( NewSize >= (GrbScriptBefore.Constraints.MinHeight + Splitter1.Height ))
  and ( NewSize <= pnlScript.Height -
     ( GrbScriptAfter.Constraints.MinHeight + Splitter1.Height*3 ) );
end;

end.
