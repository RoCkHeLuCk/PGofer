unit PGofer.Triggers.VaultFolder.Frame;

interface

uses
  System.Classes, System.SysUtils,
  Vcl.StdCtrls, Vcl.Controls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers.Folder.Frame, PGofer.Component.Edit,
  Pgofer.Component.Checkbox, PGofer.Triggers.VaultFolder, PGofer.Item.Frame, Vcl.ExtCtrls,
  PGofer.Component.Memo;

type
  TPGVaultFolderFrame = class( TPGFolderFrame )
    LblFileName: TLabel;
    CkbLocked: TCheckBoxEx;
    EdtFile: TEditEx;
    LblRepeat: TLabel;
    EdtAutoLock: TEditEx;
    UpdAutoLock: TUpDown;
    LblMinute: TLabel;
    CkbSavePassword: TCheckBoxEx;
    BtnPassword: TButton;
    procedure CkbLockedClick(Sender: TObject);
    procedure EdtFileAfterValidate(Sender: TObject);
    procedure EdtAutoLockAfterValidate(Sender: TObject);
    procedure CkbSavePasswordClick(Sender: TObject);
    procedure BtnPasswordClick(Sender: TObject);
  private
  protected
    function GetItem( ): TPGVaultFolder; reintroduce;
    property Item: TPGVaultFolder read GetItem;
  public
    constructor Create(const AItem: TPGItem; const AParent: TObject ); reintroduce;
  end;

var
  PGVaultFolderFrame: TPGFolderFrame;

implementation

{$R *.dfm}
{ TPGFrameVariants }

constructor TPGVaultFolderFrame.Create(const AItem: TPGItem; const AParent: TObject );
begin
  inherited Create( AItem, AParent );
  EdtFile.SetTextSilent( Item._FileName );
  EdtAutoLock.SetTextSilent( Item._AutoLock.ToString );
  CkbSavePassword.SetCheckedSilent( Item._SavePassword );
  ckbLocked.SetCheckedSilent( Item._Locked );
end;

function TPGVaultFolderFrame.GetItem: TPGVaultFolder;
begin
  Result := TPGVaultFolder(inherited Item);
end;

procedure TPGVaultFolderFrame.EdtAutoLockAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Item._AutoLock := StrToIntDef(EdtAutoLock.Text,0);
end;

procedure TPGVaultFolderFrame.EdtFileAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Item._FileName := EdtFile.Text;
   Self.UpdateStatusBadges();
end;

procedure TPGVaultFolderFrame.CkbSavePasswordClick(Sender: TObject);
begin
  if Self.Loading then Exit;
  Item._SavePassword := CkbSavePassword.Checked;
  Self.UpdateStatusBadges();
end;

procedure TPGVaultFolderFrame.BtnPasswordClick(Sender: TObject);
begin
  if Self.Loading then Exit;
  Item.RequestPassword( Item.GetIsPassword );
  Self.UpdateStatusBadges();
end;

procedure TPGVaultFolderFrame.CkbLockedClick(Sender: TObject);
begin
  if Self.Loading then Exit;
  try
    Item._Locked := ckbLocked.Checked;
  finally
    ckbLocked.SetCheckedSilent( Item._Locked );
  end;
  Self.UpdateStatusBadges();
end;

end.
