unit PGofer.Triggers.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,  Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Component.Edit, PGofer.Classes, PGofer.Item.Frame;

type
  TPGTriggerFrame = class(TPGItemFrame)
    procedure EdtNameBeforeValidate(ASender: TObject; var AIsValid: Boolean);
  private
    function GetItem( ): TPGItem; virtual;
  protected
    property Item: TPGItem read GetItem;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); override;
  end;

implementation

{$R *.dfm}

uses
  PGofer.Runtime, PGofer.Triggers, PGofer.Sintatico.Controls;

constructor TPGTriggerFrame.Create(AItem: TPGItem; AParent: TObject);
begin
   inherited Create( AItem, AParent );
end;

procedure TPGTriggerFrame.EdtNameBeforeValidate(ASender: TObject; var AIsValid: Boolean);
var
  LFoundItem: TPGItem;
begin
  // 1. Regra herdada do FolderMirror: Se for pasta e N�O for namespace, n�o precisa validar colis�o
  if (Item is TPGFolderMirror) and (not TPGFolderMirror(Item).Namespace) then
  begin
    AIsValid := True;
    Exit;
  end;


  if Assigned(Item.Parent) then
  begin
    if Item.Parent = TriggersCollect then
      LFoundItem := FindID(GlobalCollection, EdtName.Text)
    else
      LFoundItem := Item.Parent.FindName(EdtName.Text)
  end else
    LFoundItem := nil;

  // 3. � v�lido se N�O achar ningu�m com esse nome, ou se o que achar for ele mesmo
  AIsValid := not (Assigned(LFoundItem) and (LFoundItem <> Item));
end;

function TPGTriggerFrame.GetItem(): TPGItem;
begin
  Result := TPGItemTrigger(FItem);
end;

end.
