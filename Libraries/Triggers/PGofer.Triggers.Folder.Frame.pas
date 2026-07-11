unit PGofer.Triggers.Folder.Frame;

interface

uses
  System.Classes,
  Vcl.Controls, Vcl.Forms, PGofer.Triggers.Frame, Vcl.StdCtrls,
  Pgofer.Component.Checkbox,
  PGofer.Classes, PGofer.Triggers, Vcl.ExtCtrls, PGofer.Component.Edit, PGofer.Component.Memo;

type
  TPGFolderFrame = class(TPGTriggerFrame)
    CkbNamespace: TCheckBoxEx;
    procedure CkbNamespaceClick(Sender: TObject);
  private
  protected
    function GetItem(): TPGTriggerFolder; reintroduce;
    property Item: TPGTriggerFolder read GetItem;
  public
    constructor Create(const AItem: TPGItem; const AParent: TObject ); override;
    procedure SyncData(); override;
  end;
var
  PGTriggerFrame1: TPGFolderFrame;

implementation

{$R *.dfm}

{ TPGFolderFrame }

constructor TPGFolderFrame.Create(const AItem: TPGItem; const AParent: TObject);
begin
   inherited Create( AItem, AParent );
end;

function TPGFolderFrame.GetItem(): TPGTriggerFolder;
begin
  Result := TPGTriggerFolder(inherited Item);
end;

procedure TPGFolderFrame.SyncData();
begin
  inherited SyncData();
  CkbNamespace.SetCheckedSilent( Self.Item.Namespace );
end;

procedure TPGFolderFrame.CkbNamespaceClick(Sender: TObject);
begin
  Self.Item.Namespace := CkbNamespace.Checked;
  Self.SyncData();
end;

end.
