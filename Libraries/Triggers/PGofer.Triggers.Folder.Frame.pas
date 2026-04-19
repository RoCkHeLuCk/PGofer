unit PGofer.Triggers.Folder.Frame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, PGofer.Triggers.Frame, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Pgofer.Component.Checkbox, PGofer.Component.Edit,
  PGofer.Classes, PGofer.Triggers;

type
  TPGFolderFrame = class(TPGTriggerFrame)
    CkbNamespace: TCheckBoxEx;
    procedure CkbNamespaceClick(Sender: TObject);
  private
  protected
    function GetItem(): TPGFolderMirror; reintroduce;
    property Item: TPGFolderMirror read GetItem;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); override;
  end;
var
  PGTriggerFrame1: TPGFolderFrame;

implementation

{$R *.dfm}

{ TPGFolderFrame }

constructor TPGFolderFrame.Create(AItem: TPGItem; AParent: TObject);
begin
   inherited Create( AItem, AParent );
   CkbNamespace.SetCheckedSilent( Self.Item.Namespace );
end;

function TPGFolderFrame.GetItem(): TPGFolderMirror;
begin
  Result := TPGFolderMirror(inherited Item);
end;

procedure TPGFolderFrame.CkbNamespaceClick(Sender: TObject);
begin
  Self.Item.Namespace := CkbNamespace.Checked;
end;

end.
