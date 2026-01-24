unit PGofer.Standard.Variants.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.Controls,
  PGofer.Classes, PGofer.Item.Frame,
  PGofer.Standard.Variants, PGofer.Component.Edit, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TPGVariantsFrame = class( TPGItemFrame )
    LblValue: TLabel;
    EdtValue: TEditEx;
    procedure EdtValueAfterValidate(Sender: TObject);
  private
  public
    function GetItem( ): TPGVariant; virtual;
    property Item: TPGVariant read GetItem;
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
  end;

var
  PGVariantsFrame: TPGItemFrame;

implementation

{$R *.dfm}
{ TPGFrameVariants }

constructor TPGVariantsFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  EdtValue.Text := Item.Value;
  EdtValue.ReadOnly := Item.Constant;
end;

function TPGVariantsFrame.GetItem: TPGVariant;
begin
  Result := TPGVariant(FItem);
end;

procedure TPGVariantsFrame.EdtValueAfterValidate(Sender: TObject);
begin
  Item.Value := EdtValue.Text;
end;

end.
