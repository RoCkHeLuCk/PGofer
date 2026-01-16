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
    function GetItem( ): TPGItemTrigger; reintroduce;
    property Item: TPGItemTrigger read GetItem;
  public
  end;

implementation

{$R *.dfm}

function TPGTriggerFrame.GetItem(): TPGItemTrigger;
begin
  Result := TPGItemTrigger( FItem );
end;

procedure TPGTriggerFrame.EdtNameBeforeValidate(ASender: TObject; var AIsValid: Boolean);
begin
  AIsValid := not Item.isItemExist( EdtName.Text, False );
end;

end.
