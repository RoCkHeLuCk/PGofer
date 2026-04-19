unit PGofer.Triggers.Links.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers, PGofer.Triggers.Links, PGofer.Triggers.Frame,
  PGofer.Component.Edit, PGofer.Component.RichEdit, PGofer.Item.Frame, Pgofer.Component.Checkbox,
  Pgofer.Component.ComboBox;

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
    CmbState: TPGComboBox;
    CmbPriority: TPGComboBox;
    BtnTest: TButton;
    GrbScriptBefore: TGroupBox;
    EdtScriptBefore: TRichEditEx;
    GrbScriptAfter: TGroupBox;
    EdtScriptAfter: TRichEditEx;
    sptScriptBefore: TSplitter;
    ckbCapture: TCheckBoxEx;
    sptScriptAfter: TSplitter;
    ckbAdministrator: TCheckBoxEx;
    CkbSingleInstance: TCheckBoxEx;
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
    procedure CkbSingleInstanceClick(Sender: TObject);
  private
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    function GetItem( ): TPGLink; reintroduce;
    property Item: TPGLink read GetItem;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); override;
    destructor Destroy( ); override;
  end;

implementation

uses

  PGofer.Files.Controls,
  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TPGFrame1 }

constructor TPGLinkFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  EdtFile.SetTextSilent( Item.FileName );
  EdtPatameter.SetTextSilent( Item.Parameter );
  EdtDiretory.SetTextSilent( Item.Directory );
  CmbState.SetIndexSilent( Item.State );
  CmbPriority.SetIndexSilent( Item.Priority );
  ckbAdministrator.SetCheckedSilent( Item.RunAdmin );
  CkbSingleInstance.SetCheckedSilent( Item.SingleInstance );
  ckbCapture.SetCheckedSilent( Item.CaptureMsg );
  EdtScriptBefore.SetTextSilent( Item.ScriptBefor );
  EdtScriptAfter.SetTextSilent( Item.ScriptAfter );
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
  Result := TPGLink(inherited Item);
end;

procedure TPGLinkFrame.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  Self.GrbScriptBefore.Height := Self.IniFile.ReadInteger( Self.ClassName,
    'ScriptsBefore', Self.GrbScriptBefore.Height );
  Self.GrbScriptAfter.Height := Self.IniFile.ReadInteger( Self.ClassName,
    'ScriptsAfter', Self.GrbScriptAfter.Height );
end;

procedure TPGLinkFrame.IniConfigSave( );
begin
  Self.IniFile.WriteInteger( Self.ClassName, 'ScriptsBefore',
    Self.GrbScriptBefore.Height );
  Self.IniFile.WriteInteger( Self.ClassName, 'ScriptsAfter',
    Self.GrbScriptAfter.Height );
  inherited IniConfigSave( );
end;

procedure TPGLinkFrame.BtnTestClick( Sender: TObject );
begin
  Item.Triggering( );
end;

procedure TPGLinkFrame.ckbAdministratorClick(Sender: TObject);
begin
  if Self.Loading then
   Exit;

  Item.RunAdmin := ckbAdministrator.Checked;
end;

procedure TPGLinkFrame.ckbCaptureClick( Sender: TObject );
begin
  if Self.Loading then
    Exit;

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
  if Self.Loading then
    Exit;

  Item.State := CmbState.ItemIndex;
end;

procedure TPGLinkFrame.CkbSingleInstanceClick(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  Item.SingleInstance := CkbSingleInstance.Checked;
end;

procedure TPGLinkFrame.CmbPriorityChange( Sender: TObject );
begin
  if Self.Loading then
    Exit;

  Item.Priority := CmbPriority.ItemIndex;
end;

procedure TPGLinkFrame.EdtFileActionButtonClick(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  EdtDiretory.Text := FileLimitPathExist( EdtFile.Text );
end;

procedure TPGLinkFrame.EdtFileAfterValidate(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  Item.FileName := EdtFile.Text;
end;

procedure TPGLinkFrame.EdtDiretoryAfterValidate(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  Item.Directory := EdtDiretory.Text;
end;

procedure TPGLinkFrame.EdtPatameterAfterValidate(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  Item.Parameter := EdtPatameter.Text;
end;

procedure TPGLinkFrame.EdtScriptAfterKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  if Self.Loading then
    Exit;

  Item.ScriptAfter := EdtScriptAfter.Lines.Text;
end;

procedure TPGLinkFrame.EdtScriptBeforeKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  if Self.Loading then
    Exit;

  Item.ScriptBefor := EdtScriptBefore.Lines.Text;
end;

end.
