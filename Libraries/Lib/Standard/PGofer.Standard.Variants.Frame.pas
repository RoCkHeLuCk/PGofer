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
  protected
    function GetItem( ): TPGVariant; reintroduce;
  public
    property Item: TPGVariant read GetItem;
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
  end;

var
  PGVariantsFrame: TPGItemFrame;

implementation

{$R *.dfm}

uses System.Rtti;

{ TPGFrameVariants }

constructor TPGVariantsFrame.Create( AItem: TPGItem; AParent: TObject );
var
  LVal: TValue;
  LArray: TArray<TValue>;
  LStr: string;
  I: Integer;
begin
  inherited Create(AItem, AParent);
  LVal := Item.Value;

  // Se for Array, monta a string representativa
  if LVal.IsType<TArray<TValue>> then
  begin
    LArray := LVal.AsType<TArray<TValue>>;
    LStr := '[';
    for I := 0 to High(LArray) do
    begin
      LStr := LStr + LArray[I].ToString;
      if I < High(LArray) then LStr := LStr + ', ';
    end;
    LStr := LStr + ']';
    EdtValue.SetTextSilent(LStr);
  end
  else
    EdtValue.SetTextSilent(LVal.ToString);

  EdtValue.ReadOnly := Item.IsConstant;
end;

function TPGVariantsFrame.GetItem(): TPGVariant;
begin
  Result := TPGVariant(inherited Item);
end;

procedure TPGVariantsFrame.EdtValueAfterValidate(Sender: TObject);
begin
  if Self.Loading then
    Exit;

  Item.Value := EdtValue.Text;
end;

end.
