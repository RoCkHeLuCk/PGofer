unit PGofer.Form.Cluster;

interface

uses
    System.Classes, System.RTTI,
    Vcl.Forms, Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls,
    PGofer.Classes,
    PGofer.Form.Controller, Vcl.ComCtrls, Pgofer.Component.TreeView;

type
    TFrmCluster = class(TFrmController)
        btnCreate: TButton;
        ppmCreate: TPopupMenu;
        btnDelete: TButton;
        constructor Create(); reintroduce;
        destructor Destroy(); override;
        procedure onCreatePopupClick(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure btnDeleteClick(Sender: TObject);
    private
        FFileName: String;
        procedure CreatePopups();
    public
    end;

var
    FrmCluster: TFrmCluster;

implementation

uses
    System.SysUtils, System.UITypes,
    Vcl.Dialogs,
    PGofer.Sintatico.Classes, PGofer.Sintatico;

{$R *.dfm}
{ TFrmCluster }

constructor TFrmCluster.Create();
begin
    FCollectItem := TPGCollectItem.Create('Cluster', True);
    FCollectItem.RegisterClasses(GlobalCollection.ClassList);

    FFileName := PGofer.Sintatico.DirCurrent + 'bla.xml';
    if FileExists(FFileName) then
        FCollectItem.XMLLoadFromFile(FFileName);

    inherited Create(FCollectItem);
    CreatePopups();
    FrmCluster := Self;
end;

destructor TFrmCluster.Destroy();
begin
    inherited;
    FCollectItem.Free();
    FCollectItem := nil;
    FrmCluster := nil;
end;

procedure TFrmCluster.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    inherited;
    FCollectItem.XMLSaveToFile(FFileName);
end;

procedure TFrmCluster.CreatePopups();
var
    PopUpItem: TMenuItem;
    ClassItem: TClass;
begin
    for ClassItem in FCollectItem.ClassList do
    begin
        PopUpItem := TMenuItem.Create(ppmCreate);
        ppmCreate.Items.Add(PopUpItem);
        PopUpItem.Caption := copy(ClassItem.ClassName, 4,
            Length(ClassItem.ClassName));
        PopUpItem.Tag := Integer(ClassItem);
        PopUpItem.OnClick := onCreatePopupClick;
    end;
end;

procedure TFrmCluster.onCreatePopupClick(Sender: TObject);
var
    IClass: TClass;
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    Value: TValue;
begin
    inherited;
    if not(Sender is TMenuItem) then
        Exit;

    IClass := TClass(TMenuItem(Sender).Tag);

    if not Assigned(FSelectedItem) then
    begin
        FSelectedItem := FCollectItem;
    end
    else
    begin
        if (not(FSelectedItem is TPGFolder)) then
        begin
            FSelectedItem := FSelectedItem.Parent;
        end;
    end;

    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(IClass);
    Value := RttiType.GetMethod('Create').Invoke(IClass,
                      [FSelectedItem, '']);
    TrvController.SuperSelected(TPGItem(Value.AsObject).Node);
end;

procedure TFrmCluster.btnDeleteClick(Sender: TObject);
begin
    if Vcl.Dialogs.MessageDlg(
           'Excluir os itens selecionados?',
                   mtConfirmation,
                  [mbYes, mbNo], 0, mbNo) = mrYes then
    begin
        TrvController.DeleteSelect();
    end;
    inherited;
end;

end.
