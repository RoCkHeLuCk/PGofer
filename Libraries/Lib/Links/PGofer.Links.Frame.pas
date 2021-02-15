unit PGofer.Links.Frame;

interface

uses
    Vcl.Forms, Vcl.Dialogs, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics,
    System.SysUtils, System.Classes,
    PGofer.Classes, PGofer.Links, PGofer.Item.Frame, Pgofer.Component.Edit,
  Vcl.ExtCtrls, Vcl.ComCtrls;

type
    TPGFrameLinks = class(TPGFrame)
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
    private
        FItem: TPGLinks;
    public
        constructor Create(Item: TPGItem; Parent: TObject); reintroduce;
        destructor Destroy(); override;
    end;

var
    PGFrameLinks: TPGFrame;

implementation

uses
    PGofer.Files.Controls;
{$R *.dfm}
{ TPGFrame1 }

procedure TPGFrameLinks.BtnArquivoClick(Sender: TObject);
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

procedure TPGFrameLinks.BtnDiretorioClick(Sender: TObject);
begin
    EdtDiretorio.Text := FileDirDialog(EdtDiretorio.Text);
end;

procedure TPGFrameLinks.BtnIconeClick(Sender: TObject);
begin
    OpdLinks.Title := 'Icone';
    OpdLinks.Filter :=
        'Todos Icones(*.jpg;*.bmp;*.ico;*.exe;*.dll)|*.jpg;*.bmp;*.ico;*.exe;*.dll|Todos Arquivos(*.*)|*.*';
    OpdLinks.InitialDir := FileLimitPathExist(EdtIcone.Text);
    OpdLinks.FileName := ExtractFileName(EdtIcone.Text);
    if OpdLinks.Execute then
        EdtIcone.Text := FileUnExpandPath(OpdLinks.FileName);
end;

procedure TPGFrameLinks.BtnTestClick(Sender: TObject);
begin
    FItem.Execute(nil);
end;

procedure TPGFrameLinks.CmbEstadoChange(Sender: TObject);
begin
    FItem.Estado := CmbEstado.ItemIndex;
end;

procedure TPGFrameLinks.CmbOperationChange(Sender: TObject);
begin
    FItem.Operation := CmbOperation.ItemIndex;
end;

procedure TPGFrameLinks.CmbPrioridadeChange(Sender: TObject);
begin
    FItem.Prioridade := CmbPrioridade.ItemIndex;
end;

constructor TPGFrameLinks.Create(Item: TPGItem; Parent: TObject);
begin
    inherited Create(Item, Parent);
    FItem := TPGLinks(Item);
    EdtArquivo.Text := FItem.Arquivo;
    EdtParametro.Text := FItem.Parametro;
    EdtDiretorio.Text := FItem.Diretorio;
    EdtIcone.Text := FItem.IconeFile;
    EdtIconeIndex.Text := FItem.IconeIndex.ToString;
    CmbEstado.ItemIndex := FItem.Estado;
    CmbPrioridade.ItemIndex := FItem.Prioridade;
    CmbOperation.ItemIndex := FItem.Operation;
end;

destructor TPGFrameLinks.Destroy;
begin
    FItem := nil;
    inherited Destroy();
end;

procedure TPGFrameLinks.EdtArquivoChange(Sender: TObject);
begin
    FItem.Arquivo := EdtArquivo.Text;
    if FItem.isFileExist then
        EdtArquivo.Color := clWindow
    else
        EdtArquivo.Color := clRed;
end;

procedure TPGFrameLinks.EdtDiretorioChange(Sender: TObject);
begin
    FItem.Diretorio := EdtDiretorio.Text;
    if FItem.isDirExist then
        EdtDiretorio.Color := clWindow
    else
        EdtDiretorio.Color := clRed;
end;

procedure TPGFrameLinks.EdtIconeChange(Sender: TObject);
begin
    FItem.IconeFile := EdtIcone.Text;
    if FItem.isIconExist then
        EdtIcone.Color := clWindow
    else
        EdtIcone.Color := clRed;
end;

procedure TPGFrameLinks.EdtIconeIndexChange(Sender: TObject);
begin
    if EdtIconeIndex.Text <> '' then
        FItem.IconeIndex := StrToInt(EdtIconeIndex.Text);
end;

procedure TPGFrameLinks.EdtParametroChange(Sender: TObject);
begin
    FItem.Parametro := EdtParametro.Text;
end;

end.
