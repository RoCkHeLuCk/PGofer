unit PGofer.Triggers.VaultFolder.Frame;

interface

uses
  System.Classes, System.SysUtils,
  Vcl.StdCtrls, Vcl.Controls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers.Folder.Frame, PGofer.Component.Edit,
  Pgofer.Component.Checkbox, PGofer.Triggers.VaultFolder, PGofer.Item.Frame, Vcl.ExtCtrls;

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
    procedure UpdAutoLockChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Integer;
      Direction: TUpDownDirection);
    procedure CkbSavePasswordClick(Sender: TObject);
    procedure BtnPasswordClick(Sender: TObject);
  private
  protected
    function GetItem( ): TPGVaultFolder; reintroduce;
    property Item: TPGVaultFolder read GetItem;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
  end;

var
  PGVaultFolderFrame: TPGFolderFrame;

implementation

{$R *.dfm}
{ TPGFrameVariants }

constructor TPGVaultFolderFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  EdtFile.SetTextSilent( Item.FileName );
  EdtAutoLock.SetTextSilent( Item.AutoLock.ToString );
  CkbSavePassword.SetCheckedSilent( Item.SavePassword );
  ckbLocked.SetCheckedSilent( Item._Locked );
end;

function TPGVaultFolderFrame.GetItem: TPGVaultFolder;
begin
  Result := TPGVaultFolder(inherited Item);
end;

procedure TPGVaultFolderFrame.UpdAutoLockChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Integer; Direction: TUpDownDirection);
begin
//  if Self.Loading then
//    Exit;
//  Item.AutoLock := NewValue;
end;

procedure TPGVaultFolderFrame.EdtAutoLockAfterValidate(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  Item.AutoLock := StrToIntDef(EdtAutoLock.Text,0);
end;

procedure TPGVaultFolderFrame.EdtFileAfterValidate(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  Item.FileName := EdtFile.Text;
end;

procedure TPGVaultFolderFrame.CkbSavePasswordClick(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  Item.SavePassword := CkbSavePassword.Checked;
end;

procedure TPGVaultFolderFrame.BtnPasswordClick(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  Item.RequestPassword( Item.isPassword );
end;

procedure TPGVaultFolderFrame.CkbLockedClick(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  try
    Item._Locked := ckbLocked.Checked;
  finally
    ckbLocked.SetCheckedSilent( Item._Locked );
  end;
end;

end.
