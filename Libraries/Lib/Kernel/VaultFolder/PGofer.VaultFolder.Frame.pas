unit PGofer.VaultFolder.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Controls,
  PGofer.Classes, PGofer.Item.Frame, PGofer.Component.Edit, PGofer.VaultFolder;

type
  TPGVaultFolderFrame = class( TPGItemFrame )
    LblFilename: TLabel;
    EdtFileName: TEdit;
    procedure EdtFileNameKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
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

{$R *.dfm}
{ TPGFrameVariants }

constructor TPGVaultFolderFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGVaultFolder( AItem );
  EdtFileName.Text := FItem.FileName;
end;

destructor TPGVaultFolderFrame.Destroy;
begin
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGVaultFolderFrame.EdtFileNameKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.FileName := EdtFileName.Text;
end;

end.
