unit PGofer.Triggers.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls,
  PGofer.Component.Edit, PGofer.Classes, PGofer.Item.Frame, Vcl.ExtCtrls, Vcl.StdCtrls,
  PGofer.Component.Memo;

type
  TPGTriggerFrame = class(TPGItemFrame)
    procedure EdtNameBeforeValidate(ASender: TObject; var AIsValid: Boolean);
  private
  protected
    function GetItem( ): TPGItem; reintroduce;
    property Item: TPGItem read GetItem;
  public
    constructor Create(const AItem: TPGItem; const AParent: TObject ); override;
  end;

implementation

{$R *.dfm}

uses
  PGofer.Runtime, PGofer.Triggers, PGofer.Sintatico.Controls;

constructor TPGTriggerFrame.Create(const AItem: TPGItem; const AParent: TObject);
begin
   inherited Create( AItem, AParent );
end;

procedure TPGTriggerFrame.EdtNameBeforeValidate(ASender: TObject; var AIsValid: Boolean);
var
  LFoundItem: TPGItem;
begin
  if Self.Loading then
    Exit;

  if (Item is TPGTriggerFolder) and (not TPGTriggerFolder(Item).Namespace) then
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
  Result := TPGItemTrigger(inherited Item);
end;

end.
