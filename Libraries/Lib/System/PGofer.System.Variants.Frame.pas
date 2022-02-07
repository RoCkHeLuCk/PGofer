unit PGofer.System.Variants.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Controls,
  PGofer.Classes, PGofer.Item.Frame,
  PGofer.System.Variants, PGofer.Component.Edit;

type
  TPGVariantsFrame = class( TPGItemFrame )
    LblValue: TLabel;
    EdtValue: TEdit;
    procedure EdtValueKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
  private
    { Private declarations }
    FItem: TPGVariant;
  public
    { Public declarations }
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGVariantsFrame: TPGItemFrame;

implementation

{$R *.dfm}
{ TPGFrameVariants }

constructor TPGVariantsFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGVariant( AItem );
  EdtValue.Text := FItem.Value;
  EdtValue.ReadOnly := FItem.Constant;
end;

destructor TPGVariantsFrame.Destroy;
begin
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGVariantsFrame.EdtValueKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Value := EdtValue.Text;
end;

end.
