unit PGofer.Item.Frame;

interface

uses
    Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
    System.Classes,
    PGofer.Classes, PGofer.Component.Edit, Vcl.ComCtrls, Vcl.ExtCtrls;

type
    TPGFrame = class(TFrame)
        grbAbout: TGroupBox;
        rceAbout: TRichEdit;
        pnlItem: TPanel;
        LblName: TLabel;
        EdtName: TEditEx;
        SplitterItem: TSplitter;
        procedure EdtNameExit(Sender: TObject);
    private
        FItem: TPGItem;
    public
        constructor Create(Item: TPGItem; Parent: TObject); reintroduce;
        destructor Destroy(); override;
    end;

implementation
{$R *.dfm}
uses
    PGofer.Sintatico.Classes;

constructor TPGFrame.Create(Item: TPGItem; Parent: TObject);
var
    Attribute : TPGRttiAttribute;
begin
    inherited Create(nil);
    Self.Parent := TWinControl(Parent);
    Self.Align := alClient;
    FItem := Item;
    EdtName.Text := FItem.Name;
    EdtName.ReadOnly := FItem.ReadOnly;
    EdtName.ParentColor := FItem.ReadOnly;
    if FItem is TPGItemCMD then
    begin
        for Attribute in TPGItemCMD(FItem).AttributeList do
        begin
            rceAbout.Lines.Add( Attribute.Value );
        end;
    end;
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
