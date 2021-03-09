unit PGofer.System.Variants.Frame;

interface

uses
    System.Classes,
    Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Controls,
    PGofer.Classes, PGofer.Item.Frame,
    PGofer.System.Variants, PGofer.Component.Edit;

type
    TPGFrameVariants = class(TPGFrame)
        LblValue: TLabel;
        edtValue: TEdit;
        procedure edtValueChange(Sender: TObject);
    private
        { Private declarations }
        FItem: TPGVariable;
    public
        { Public declarations }
        constructor Create(Item: TPGItem; Parent: TObject); reintroduce;
        destructor Destroy(); override;
    end;

var
    PGFrameVariants: TPGFrame;

implementation

{$R *.dfm}
{ TPGFrameVariants }

constructor TPGFrameVariants.Create(Item: TPGItem; Parent: TObject);
begin
    inherited Create(Item, Parent);
    FItem := TPGVariable(Item);
    edtValue.Text := FItem.Valor;
end;

destructor TPGFrameVariants.Destroy;
begin
    FItem := nil;
    inherited Destroy();
end;

procedure TPGFrameVariants.edtValueChange(Sender: TObject);
begin
    FItem.Valor := edtValue.Text;

end;

end.
