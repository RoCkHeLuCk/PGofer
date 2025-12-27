unit PGofer.VaultFolder.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Controls, Vcl.Dialogs,
  PGofer.Classes, PGofer.Item.Frame, PGofer.Component.Edit, PGofer.VaultFolder;

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
    procedure EdtPasswordKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure EdtFileKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ckbSavePasswordClick(Sender: TObject);
    procedure BtnPasswordClick(Sender: TObject);
    procedure BtnFileClick(Sender: TObject);
  private
    { Private declarations }
    FItem: TPGVaultFolder;
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
  PGofer.Files.Controls;

{$R *.dfm}
{ TPGFrameVariants }

constructor TPGVaultFolderFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGVaultFolder( AItem );
  EdtFile.Text := FItem.FileName;
  EdtPassword.Text := FItem.Password;
  ckbSavePassword.Checked := FItem.SavePassword;
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
  end;
end;

procedure TPGVaultFolderFrame.EdtFileKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FItem.FileName := EdtFile.Text;
end;

procedure TPGVaultFolderFrame.EdtPasswordKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Password := EdtPassword.Text;
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

procedure TPGVaultFolderFrame.ckbSavePasswordClick(Sender: TObject);
begin
  FItem.SavePassword := ckbSavePassword.Checked;
end;

end.
