unit PGofer.System.Variants.Frame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, PGofer.Item.Frame, Vcl.StdCtrls,
  Pgofer.Component.Edit, PGofer.Classes, PGofer.System.Variants, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TPGFrameVariants = class(TPGFrame)
    LblValue: TLabel;
    edtValue: TEdit;
    procedure edtValueChange(Sender: TObject);
  private
    { Private declarations }
    FItem : TPGVariavel;
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
    FItem := TPGVariavel(Item);
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
