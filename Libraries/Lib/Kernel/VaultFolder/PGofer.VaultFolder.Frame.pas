unit PGofer.VaultFolder.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Controls, Vcl.Dialogs,
  PGofer.Classes, PGofer.Item.Frame, PGofer.Component.Edit,
  Pgofer.Component.Checkbox, PGofer.VaultFolder;

type
  TPGVaultFolderFrame = class( TPGItemFrame )
    LblPassword: TLabel;
    LblFileName: TLabel;
    EdtFile: TEdit;
    BtnFile: TButton;
    EdtPassword: TEdit;
    BtnPassword: TButton;
    ckbSavePassword: TCheckBox;
    svdVault: TSaveDialog;
    ckbLocked: TCheckBoxEx;
    procedure EdtPasswordKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtFileKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ckbSavePasswordClick(Sender: TObject);
    procedure BtnPasswordClick(Sender: TObject);
    procedure BtnFileClick(Sender: TObject);
    procedure ckbLockedClick(Sender: TObject);
  private
    { Private declarations }
    FItem: TPGVaultFolder;
  protected
    procedure isFileName( );
    procedure isPassword( );
  public
    { Public declarations }
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGVaultFolderFrame: TPGItemFrame;

implementation

uses
  System.SysUtils,
  Vcl.Graphics,
  PGofer.Files.Controls;

{$R *.dfm}
{ TPGFrameVariants }

constructor TPGVaultFolderFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGVaultFolder( AItem );
  EdtFile.Text := FItem.FileName;
  Self.isFileName( );
  EdtPassword.Text := FItem.Password;
  ckbSavePassword.Checked := FItem.SavePassword;
  ckbLocked.SetCheckedSilent( FItem.Locked );
end;

destructor TPGVaultFolderFrame.Destroy;
begin
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGVaultFolderFrame.BtnFileClick(Sender: TObject);
begin
  svdVault.Title := 'Vault File';
  svdVault.Filter := 'PGofer Vault (*.pgv)|*.pgv|All Files (*.*)|*.*';
  svdVault.InitialDir := FileLimitPathExist( EdtFile.Text );
  svdVault.FileName := ExtractFileName( EdtFile.Text );

  if svdVault.Execute then
  begin
    FItem.FileName := FileUnExpandPath( svdVault.FileName );
    EdtFile.Text := FItem.FileName;
    Self.isFileName( );
  end;
end;

procedure TPGVaultFolderFrame.EdtFileKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FItem.FileName := EdtFile.Text;
  Self.isFileName( );
end;

procedure TPGVaultFolderFrame.EdtPasswordKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Password := EdtPassword.Text;
  Self.isPassword();
end;

procedure TPGVaultFolderFrame.BtnPasswordClick(Sender: TObject);
begin
  if EdtPassword.PasswordChar = '*' then
  begin
    EdtPassword.PasswordChar := #0;
    BtnPassword.Caption := '(O)';
  end else begin
    EdtPassword.PasswordChar := '*';
    BtnPassword.Caption := '(_)';
  end;
end;

procedure TPGVaultFolderFrame.ckbLockedClick(Sender: TObject);
begin
  try
    FItem.Locked := ckbLocked.Checked;
  finally
    ckbLocked.SetCheckedSilent( FItem.Locked );
  end;
end;

procedure TPGVaultFolderFrame.ckbSavePasswordClick(Sender: TObject);
begin
  FItem.SavePassword := ckbSavePassword.Checked;
end;

procedure TPGVaultFolderFrame.isFileName( );
begin
  if FItem.isFileName then
    EdtFile.Color := clWindow
  else
    EdtFile.Color := clRed;
end;

procedure TPGVaultFolderFrame.isPassword( );
begin
  if FItem.isPassword then
    EdtPassword.Color := clWindow
  else
    EdtPassword.Color := clRed;
end;


end.
