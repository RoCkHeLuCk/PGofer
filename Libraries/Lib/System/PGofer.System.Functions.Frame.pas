unit PGofer.System.Functions.Frame;

interface

uses
    System.Classes,
    Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Controls,
    SynEdit, SynMemo,
    PGofer.Classes, PGofer.Item.Frame, PGofer.Component.Edit,
    PGofer.System.Functions, PGofer.Form.AutoComplete;

type
    TPGFrameFunction = class(TPGFrame)
        GroupBox1: TGroupBox;
        mmoContents: TSynMemo;
        procedure mmoContentsExit(Sender: TObject);
    private
        { Private declarations }
        FItem: TPGFunction;
        frmAutoComplete: TFrmAutoComplete;
    public
        { Public declarations }
        constructor Create(Item: TPGItem; Parent: TObject); reintroduce;
        destructor Destroy(); override;
    end;

var
    PGFrameFunction: TPGFrameFunction;

implementation

{$R *.dfm}
{ TPGFrameFunction }

constructor TPGFrameFunction.Create(Item: TPGItem; Parent: TObject);
begin
    inherited Create(Item, Parent);
    FItem := TPGFunction(Item);
    mmoContents.Text := FItem.Contents;
    frmAutoComplete := TFrmAutoComplete.Create(mmoContents);
end;

destructor TPGFrameFunction.Destroy;
begin
    FItem := nil;
    frmAutoComplete.Free;
    inherited Destroy();
end;

procedure TPGFrameFunction.mmoContentsExit(Sender: TObject);
begin
    FItem.Contents := mmoContents.Text;
end;

end.
