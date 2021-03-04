unit PGofer.Form.Controller.Flock;

interface

uses
    System.Classes, System.RTTI,
    Vcl.Forms, Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls,
    PGofer.Classes,
    PGofer.Form.Controller, Vcl.ComCtrls, Pgofer.Component.TreeView;

type
    TFrmFlock = class(TFrmController)
        btnCreate: TButton;
        ppmCreate: TPopupMenu;
        btnDelete: TButton;
        constructor Create(ACollectItem: TPGItemCollect); reintroduce;
        destructor Destroy(); override;
        procedure onCreateItemPopUpClick(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure btnDeleteClick(Sender: TObject);
    private
        FFileName: String;
        procedure CreatePopups();
    public
    end;

implementation

uses
    System.SysUtils, System.UITypes,
    Vcl.Dialogs,
    PGofer.Sintatico.Classes, PGofer.Sintatico;

{$R *.dfm}

{ TFrmFlock }

constructor TFrmFlock.Create(ACollectItem: TPGItemCollect);
begin
    FFileName := PGofer.Sintatico.DirCurrent+'\'+ACollectItem.Name+'.xml';
    if FileExists(FFileName) then
        ACollectItem.XMLLoadFromFile(FFileName);
    inherited Create(ACollectItem);
    CreatePopups();
end;

destructor TFrmFlock.Destroy();
begin
    FCollectItem.XMLSaveToFile(FFileName);
    FFileName := '';
    inherited;
end;

procedure TFrmFlock.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    FCollectItem.XMLSaveToFile(FFileName);
end;

procedure TFrmFlock.CreatePopups();
var
    PopUpItem: TMenuItem;
    C : Integer;
begin
    for C := 0 to FCollectItem.RegClassList.Count -1 do
    begin
        PopUpItem := TMenuItem.Create(ppmCreate);
        ppmCreate.Items.Add(PopUpItem);
        PopUpItem.Caption := FCollectItem.RegClassList.GetNameIndex(C);
        PopUpItem.Tag := C;
        PopUpItem.OnClick := onCreateItemPopUpClick;
    end;
end;

procedure TFrmFlock.onCreateItemPopUpClick(Sender: TObject);
var
    IClass: TClass;
    IName: String;
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    Value: TValue;
begin
    IClass := FCollectItem.RegClassList.GetClassIndex(TComponent(Sender).Tag);
    IName := FCollectItem.RegClassList.GetNameIndex(TComponent(Sender).Tag);

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
    RttiType := RttiContext.GetType( IClass );
    Value := RttiType.GetMethod('Create').Invoke(IClass,
                           [FSelectedItem,IName]);
    TrvController.SuperSelected(TPGItem(Value.AsObject).Node);
end;

procedure TFrmFlock.btnDeleteClick(Sender: TObject);
begin
    if Vcl.Dialogs.MessageDlg(
           'Excluir os itens selecionados?',
           mtConfirmation,
           [mbYes, mbNo], 0, mbNo) = mrYes then
    begin
        TrvController.DeleteSelect();
    end;
end;

end.
