unit PGofer.System.Variants.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Controls,
  PGofer.Classes, PGofer.Item.Frame,
  PGofer.System.Variants, PGofer.Component.Edit;

type
  TPGFrameVariants = class( TPGFrame )
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
  PGFrameVariants: TPGFrame;

implementation

{$R *.dfm}
{ TPGFrameVariants }

constructor TPGFrameVariants.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGVariant( AItem );
  EdtValue.Text := FItem.Value;
  EdtValue.ReadOnly := FItem.Constant;
end;

destructor TPGFrameVariants.Destroy;
begin
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGFrameVariants.EdtValueKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Value := EdtValue.Text;
end;

end.
