unit PGofer.Item.Frame;

interface

uses
    Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
    System.Classes,
    PGofer.Classes, PGofer.Component.Edit;

type
    TPGFrame = class(TFrame)
        LblName: TLabel;
        EdtName: TEditEx;
        procedure EdtNameExit(Sender: TObject);
    private
        FItem: TPGItem;
    public
        constructor Create(Item: TPGItem; Parent: TObject); reintroduce;
        destructor Destroy(); override;
    end;

implementation

{$R *.dfm}

constructor TPGFrame.Create(Item: TPGItem; Parent: TObject);
begin
    inherited Create(nil);
    Self.Parent := TWinControl(Parent);
    Self.Align := alClient;
    FItem := Item;
    EdtName.Text := FItem.Name;
    EdtName.ReadOnly := FItem.ReadOnly;
    EdtName.ParentColor := FItem.ReadOnly;
end;

destructor TPGFrame.Destroy;
begin
    FItem := nil;
    inherited Destroy();
end;

procedure TPGFrame.EdtNameExit(Sender: TObject);
begin
    FItem.Name := EdtName.Text;
end;

end.
