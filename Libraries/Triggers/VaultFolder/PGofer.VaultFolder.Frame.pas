unit PGofer.VaultFolder.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.Controls,
  PGofer.Classes, PGofer.Item.Frame, PGofer.Component.Edit,
  Pgofer.Component.Checkbox, PGofer.VaultFolder, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TPGVaultFolderFrame = class( TPGItemFrame )
    LblPassword: TLabel;
    LblFileName: TLabel;
    ckbSavePassword: TCheckBox;
    ckbLocked: TCheckBoxEx;
    EdtFile: TEditEx;
    EdtPassword: TEditEx;
    procedure ckbSavePasswordClick(Sender: TObject);
    procedure ckbLockedClick(Sender: TObject);
    procedure EdtFileAfterValidate(Sender: TObject);
    procedure EdtPasswordAfterValidate(Sender: TObject);
  private
  protected
    function GetItem( ): TPGVaultFolder; virtual;
    property Item: TPGVaultFolder read GetItem;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
  end;

var
  PGVaultFolderFrame: TPGItemFrame;

implementation



{$R *.dfm}
{ TPGFrameVariants }

constructor TPGVaultFolderFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  EdtFile.Text := Item.FileName;
  EdtPassword.Text := Item.PasswordFrame;
  ckbSavePassword.Checked := Item.SavePassword;
  ckbLocked.SetCheckedSilent( Item._Locked );
end;

function TPGVaultFolderFrame.GetItem: TPGVaultFolder;
begin
  Result := TPGVaultFolder(FItem);
end;

procedure TPGVaultFolderFrame.EdtFileAfterValidate(Sender: TObject);
begin
  Item.FileName := EdtFile.Text;
end;

procedure TPGVaultFolderFrame.EdtPasswordAfterValidate(Sender: TObject);
begin
  Item.PasswordFrame := EdtPassword.Text;
end;

procedure TPGVaultFolderFrame.ckbLockedClick(Sender: TObject);
begin
  try
    Item._Locked := ckbLocked.Checked;
  finally
    ckbLocked.SetCheckedSilent( Item._Locked );
  end;
end;

procedure TPGVaultFolderFrame.ckbSavePasswordClick(Sender: TObject);
begin
  Item.SavePassword := ckbSavePassword.Checked;
end;

end.
