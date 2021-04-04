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
    GpbScriptAfter: TGroupBox;
    EdtScriptAfter: TRichEditEx;
    Splitter1: TSplitter;
    procedure EdtFileChange( Sender: TObject );
    procedure EdtPatameterChange( Sender: TObject );
    procedure EdtDiretoryChange( Sender: TObject );
    procedure CmbStateChange( Sender: TObject );
    procedure CmbOperationChange( Sender: TObject );
    procedure CmbPriorityChange( Sender: TObject );
    procedure BtnFileClick( Sender: TObject );
    procedure BtnDiretoryClick( Sender: TObject );
    procedure EdtNameKeyUp( Sender: TObject; var Key: Word;
       Shift: TShiftState );
    procedure EdtScriptAfterChange( Sender: TObject );
    procedure EdtScriptBeforeChange( Sender: TObject );
    procedure BtnTestClick( Sender: TObject );
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
    EdtFile.Text := FileUnExpandPath( OpdLinks.FileName );
    EdtFile.OnChange( nil );
    EdtDiretory.Text := FileUnExpandPath
       ( ExtractFilePath( OpdLinks.FileName ) );
  end;
end;

procedure TPGLinkFrame.BtnDiretoryClick( Sender: TObject );
begin
  EdtDiretory.Text := FileDirDialog( EdtDiretory.Text );
end;

procedure TPGLinkFrame.BtnTestClick( Sender: TObject );
begin
  FItem.Triggering( );
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

procedure TPGLinkFrame.EdtFileChange( Sender: TObject );
begin
  FItem.FileName := EdtFile.Text;
  if FItem.isFileExist then
    EdtFile.Color := clWindow
  else
    EdtFile.Color := clRed;
end;

procedure TPGLinkFrame.EdtDiretoryChange( Sender: TObject );
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

procedure TPGLinkFrame.EdtPatameterChange( Sender: TObject );
begin
  FItem.Parameter := EdtPatameter.Text;
end;

procedure TPGLinkFrame.EdtScriptAfterChange( Sender: TObject );
begin
  FItem.ScriptAfter := EdtScriptAfter.Lines.Text;
end;

procedure TPGLinkFrame.EdtScriptBeforeChange( Sender: TObject );
begin
  FItem.ScriptBefor := EdtScriptBefore.Lines.Text;
end;

procedure TPGLinkFrame.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  Self.GpbScriptAfter.Height := FIniFile.ReadInteger( Self.ClassName, 'Scripts',
     Self.GpbScriptAfter.Height );
end;

procedure TPGLinkFrame.IniConfigSave( );
begin
  FIniFile.WriteInteger( Self.ClassName, 'Scripts',
     Self.GpbScriptAfter.Height );
  inherited IniConfigSave( );
end;

end.
