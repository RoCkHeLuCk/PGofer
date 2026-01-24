unit PGofer.Triggers.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,

  PGofer.Runtime,
  PGofer.Item.Frame, PGofer.Triggers, PGofer.Component.Edit, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TPGTriggerFrame = class(TPGItemFrame)
    procedure EdtNameBeforeValidate(ASender: TObject; var AIsValid: Boolean);
  private
  protected
    FLocalFind : Boolean;
    function GetItem( ): TPGItemTrigger; reintroduce;
    property Item: TPGItemTrigger read GetItem;
  public
    constructor Create( AItem: TPGItemTrigger; AParent: TObject ); reintroduce;
  end;

implementation

{$R *.dfm}

constructor TPGTriggerFrame.Create(AItem: TPGItemTrigger; AParent: TObject);
begin
   inherited Create( AItem, AParent );
   FLocalFind := True;
end;

procedure TPGTriggerFrame.EdtNameBeforeValidate(ASender: TObject; var AIsValid: Boolean);
begin
  AIsValid := not Item.isItemExist( EdtName.Text, FLocalFind );
end;

function TPGTriggerFrame.GetItem(): TPGItemTrigger;
begin
  Result := TPGItemTrigger( FItem );
end;

end.
