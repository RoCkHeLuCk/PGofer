unit PGofer.Triggers.Links.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Triggers, PGofer.Triggers.Links, PGofer.Triggers.Frame,
  PGofer.Component.Edit, PGofer.Component.RichEdit, PGofer.Item.Frame;

type
  TPGLinkFrame = class( TPGTriggerFrame )
    LblFile: TLabel;
    LblParameter: TLabel;
    LblDirectory: TLabel;
    LblState: TLabel;
    LblPriority: TLabel;
    EdtFile: TEditEx;
    EdtPatameter: TEditEx;
    EdtDiretory: TEditEx;
    CmbState: TComboBox;
    CmbPriority: TComboBox;
    BtnTest: TButton;
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
    procedure BtnTestClick( Sender: TObject );
    procedure EdtScriptBeforeKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtScriptAfterKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure ckbCaptureClick( Sender: TObject );
    procedure ckbAdministratorClick(Sender: TObject);
    procedure EdtFileAfterValidate(Sender: TObject);
    procedure EdtPatameterAfterValidate(Sender: TObject);
    procedure EdtDiretoryAfterValidate(Sender: TObject);
    procedure EdtFileActionButtonClick(Sender: TObject);
  private
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    function GetItem( ): TPGLink; virtual;
    property Item: TPGLink read GetItem;
  public
    constructor Create( AItem: TPGItemTrigger; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

uses

  PGofer.Files.Controls,
  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TPGFrame1 }

constructor TPGLinkFrame.Create( AItem: TPGItemTrigger; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  EdtFile.Text := Item.FileName;
  EdtPatameter.Text := Item.Parameter;
  EdtDiretory.Text := Item.Directory;
  CmbState.ItemIndex := Item.State;
  CmbPriority.ItemIndex := Item.Priority;
  ckbAdministrator.Checked := Item.RunAdmin;
  ckbCapture.Checked := Item.CaptureMsg;
  EdtScriptBefore.Lines.Text := Item.ScriptBefor;
  EdtScriptAfter.Lines.Text := Item.ScriptAfter;
  FrmAutoComplete.EditCtrlAdd( EdtScriptBefore );
  FrmAutoComplete.EditCtrlAdd( EdtScriptAfter );
end;

destructor TPGLinkFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtScriptBefore );
  FrmAutoComplete.EditCtrlRemove( EdtScriptAfter );
  inherited Destroy( );
end;

function TPGLinkFrame.GetItem: TPGLink;
begin
  Result := TPGLink(FItem);
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

procedure TPGLinkFrame.BtnTestClick( Sender: TObject );
begin
  Item.Triggering( );
end;

procedure TPGLinkFrame.ckbAdministratorClick(Sender: TObject);
begin
  Item.RunAdmin := ckbAdministrator.Checked;
end;

procedure TPGLinkFrame.ckbCaptureClick( Sender: TObject );
begin
  Item.CaptureMsg := ckbCapture.Checked;
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
  Item.State := CmbState.ItemIndex;
end;

procedure TPGLinkFrame.CmbPriorityChange( Sender: TObject );
begin
  Item.Priority := CmbPriority.ItemIndex;
end;

procedure TPGLinkFrame.EdtFileActionButtonClick(Sender: TObject);
begin
  EdtDiretory.Text := FileLimitPathExist( EdtFile.Text );
end;

procedure TPGLinkFrame.EdtFileAfterValidate(Sender: TObject);
begin
  Item.FileName := EdtFile.Text;
end;

procedure TPGLinkFrame.EdtDiretoryAfterValidate(Sender: TObject);
begin
  Item.Directory := EdtDiretory.Text;
end;

procedure TPGLinkFrame.EdtPatameterAfterValidate(Sender: TObject);
begin
  Item.Parameter := EdtPatameter.Text;
end;

procedure TPGLinkFrame.EdtScriptAfterKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  Item.ScriptAfter := EdtScriptAfter.Lines.Text;
end;

procedure TPGLinkFrame.EdtScriptBeforeKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  Item.ScriptBefor := EdtScriptBefore.Lines.Text;
end;

end.
