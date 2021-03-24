unit PGofer.Triggers.Links.Frame;

interface

uses
    System.Classes,
    Vcl.Forms, Vcl.Dialogs, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics,
    Vcl.ExtCtrls, Vcl.ComCtrls,
    PGofer.Classes, PGofer.Triggers.Links, PGofer.Item.Frame,
    PGofer.Component.Edit;

type
    TPGLinkFrame = class(TPGFrame)
        LblArquivo: TLabel;
        LblParametro: TLabel;
        LblDiretorio: TLabel;
        LblIcone: TLabel;
        LblEstado: TLabel;
        LblPrioridade: TLabel;
        LblOperation: TLabel;
        EdtArquivo: TEdit;
        BtnArquivo: TButton;
        EdtParametro: TEdit;
        EdtDiretorio: TEdit;
        BtnDiretorio: TButton;
        EdtIcone: TEdit;
        BtnIcone: TButton;
        EdtIconeIndex: TEdit;
        CmbEstado: TComboBox;
        CmbPrioridade: TComboBox;
        BtnTest: TButton;
        CmbOperation: TComboBox;
        OpdLinks: TOpenDialog;
        procedure EdtArquivoChange(Sender: TObject);
        procedure EdtParametroChange(Sender: TObject);
        procedure EdtDiretorioChange(Sender: TObject);
        procedure EdtIconeChange(Sender: TObject);
        procedure EdtIconeIndexChange(Sender: TObject);
        procedure CmbEstadoChange(Sender: TObject);
        procedure CmbOperationChange(Sender: TObject);
        procedure CmbPrioridadeChange(Sender: TObject);
        procedure BtnTestClick(Sender: TObject);
        procedure BtnArquivoClick(Sender: TObject);
        procedure BtnDiretorioClick(Sender: TObject);
        procedure BtnIconeClick(Sender: TObject);
        procedure EdtNameKeyUp(Sender: TObject; var Key: Word;
          Shift: TShiftState);
    private
        FItem: TPGLink;
    public
        constructor Create(Item: TPGItem; Parent: TObject); reintroduce;
        destructor Destroy(); override;
    end;

var
    PGLinkFrame: TPGFrame;

implementation

uses
    System.SysUtils, PGofer.Files.Controls;
{$R *.dfm}
{ TPGFrame1 }

procedure TPGLinkFrame.BtnArquivoClick(Sender: TObject);
begin
    OpdLinks.Title := 'Arquivo';
    OpdLinks.Filter := 'Todos Arquivos(*.*)|*.*';
    OpdLinks.InitialDir := FileLimitPathExist(EdtArquivo.Text);
    OpdLinks.FileName := ExtractFileName(EdtArquivo.Text);

    if OpdLinks.Execute then
    begin
        EdtArquivo.Text := FileUnExpandPath(OpdLinks.FileName);
        EdtArquivo.OnChange(nil);
        EdtDiretorio.Text := FileUnExpandPath
          (ExtractFilePath(OpdLinks.FileName));
        EdtIcone.Text := EdtArquivo.Text;
    end;
end;

procedure TPGLinkFrame.BtnDiretorioClick(Sender: TObject);
begin
    EdtDiretorio.Text := FileDirDialog(EdtDiretorio.Text);
end;

procedure TPGLinkFrame.BtnIconeClick(Sender: TObject);
begin
    OpdLinks.Title := 'Icone';
    OpdLinks.Filter :=
      'Todos Icones(*.jpg;*.bmp;*.ico;*.exe;*.dll)|*.jpg;*.bmp;*.ico;*.exe;*.dll|Todos Arquivos(*.*)|*.*';
    OpdLinks.InitialDir := FileLimitPathExist(EdtIcone.Text);
    OpdLinks.FileName := ExtractFileName(EdtIcone.Text);
    if OpdLinks.Execute then
        EdtIcone.Text := FileUnExpandPath(OpdLinks.FileName);
end;

procedure TPGLinkFrame.BtnTestClick(Sender: TObject);
begin
    FItem.Execute(nil);
end;

procedure TPGLinkFrame.CmbEstadoChange(Sender: TObject);
begin
    FItem.Estado := CmbEstado.ItemIndex;
end;

procedure TPGLinkFrame.CmbOperationChange(Sender: TObject);
begin
    FItem.Operation := CmbOperation.ItemIndex;
end;

procedure TPGLinkFrame.CmbPrioridadeChange(Sender: TObject);
begin
    FItem.Prioridade := CmbPrioridade.ItemIndex;
end;

constructor TPGLinkFrame.Create(Item: TPGItem; Parent: TObject);
begin
    inherited Create(Item, Parent);
    FItem := TPGLink(Item);
    EdtArquivo.Text := FItem.Arquivo;
    EdtParametro.Text := FItem.Parametro;
    EdtDiretorio.Text := FItem.Diretorio;
    EdtIcone.Text := FItem.IconeFile;
    EdtIconeIndex.Text := FItem.IconeIndex.ToString;
    CmbEstado.ItemIndex := FItem.Estado;
    CmbPrioridade.ItemIndex := FItem.Prioridade;
    CmbOperation.ItemIndex := FItem.Operation;
end;

destructor TPGLinkFrame.Destroy;
begin
    FItem := nil;
    inherited Destroy();
end;

procedure TPGLinkFrame.EdtArquivoChange(Sender: TObject);
begin
    FItem.Arquivo := EdtArquivo.Text;
    if FItem.isFileExist then
        EdtArquivo.Color := clWindow
    else
        EdtArquivo.Color := clRed;
end;

procedure TPGLinkFrame.EdtDiretorioChange(Sender: TObject);
begin
    FItem.Diretorio := EdtDiretorio.Text;
    if FItem.isDirExist then
        EdtDiretorio.Color := clWindow
    else
        EdtDiretorio.Color := clRed;
end;

procedure TPGLinkFrame.EdtIconeChange(Sender: TObject);
begin
    FItem.IconeFile := EdtIcone.Text;
    if FItem.isIconExist then
        EdtIcone.Color := clWindow
    else
        EdtIcone.Color := clRed;
end;

procedure TPGLinkFrame.EdtIconeIndexChange(Sender: TObject);
begin
    if EdtIconeIndex.Text <> '' then
        FItem.IconeIndex := StrToInt(EdtIconeIndex.Text);
end;

procedure TPGLinkFrame.EdtNameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if FItem.isItemExist(EdtName.Text) then
    begin
        EdtName.Color := clRed;
    end
    else
    begin
        EdtName.Color := clWindow;
        inherited;
    end;
end;

procedure TPGLinkFrame.EdtParametroChange(Sender: TObject);
begin
    FItem.Parametro := EdtParametro.Text;
end;

end.
