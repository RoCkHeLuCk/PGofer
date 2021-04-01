unit PGofer.Triggers.Links.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Dialogs, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers.Links, PGofer.Item.Frame,
  PGofer.Component.Edit, PGofer.Component.RichEdit,
  PGofer.Forms.AutoComplete;

type
  TPGLinkFrame = class( TPGFrame )
    LblArquivo: TLabel;
    LblParametro: TLabel;
    LblDiretorio: TLabel;
    LblEstado: TLabel;
    LblPrioridade: TLabel;
    LblOperation: TLabel;
    EdtArquivo: TEdit;
    BtnArquivo: TButton;
    EdtParametro: TEdit;
    EdtDiretorio: TEdit;
    BtnDiretorio: TButton;
    CmbEstado: TComboBox;
    CmbPrioridade: TComboBox;
    BtnTest: TButton;
    CmbOperation: TComboBox;
    OpdLinks: TOpenDialog;
    pnlScript: TPanel;
    GrbScriptIni: TGroupBox;
    EdtScriptIni: TRichEditEx;
    GpbScriptEnd: TGroupBox;
    EdtScriptEnd: TRichEditEx;
    Splitter1: TSplitter;
    procedure EdtArquivoChange( Sender: TObject );
    procedure EdtParametroChange( Sender: TObject );
    procedure EdtDiretorioChange( Sender: TObject );
    procedure CmbEstadoChange( Sender: TObject );
    procedure CmbOperationChange( Sender: TObject );
    procedure CmbPrioridadeChange( Sender: TObject );
    procedure BtnArquivoClick( Sender: TObject );
    procedure BtnDiretorioClick( Sender: TObject );
    procedure EdtNameKeyUp( Sender: TObject; var Key: Word;
       Shift: TShiftState );
    procedure EdtScriptEndChange( Sender: TObject );
    procedure EdtScriptIniChange( Sender: TObject );
    procedure BtnTestClick( Sender: TObject );
  private
    FItem: TPGLink;
    FFrmAutoCompleteI: TFrmAutoComplete;
    FFrmAutoCompleteE: TFrmAutoComplete;
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    constructor Create( Item: TPGItem; Parent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGLinkFrame: TPGFrame;

implementation

uses
  System.SysUtils, PGofer.Files.Controls, PGofer.Sintatico;
{$R *.dfm}
{ TPGFrame1 }

procedure TPGLinkFrame.BtnArquivoClick( Sender: TObject );
begin
  OpdLinks.Title := 'Arquivo';
  OpdLinks.Filter := 'Todos Arquivos(*.*)|*.*';
  OpdLinks.InitialDir := FileLimitPathExist( EdtArquivo.Text );
  OpdLinks.FileName := ExtractFileName( EdtArquivo.Text );

  if OpdLinks.Execute then
  begin
    EdtArquivo.Text := FileUnExpandPath( OpdLinks.FileName );
    EdtArquivo.OnChange( nil );
    EdtDiretorio.Text := FileUnExpandPath
       ( ExtractFilePath( OpdLinks.FileName ) );
  end;
end;

procedure TPGLinkFrame.BtnDiretorioClick( Sender: TObject );
begin
  EdtDiretorio.Text := FileDirDialog( EdtDiretorio.Text );
end;

procedure TPGLinkFrame.BtnTestClick( Sender: TObject );
begin
  FItem.Triggering( );
end;

procedure TPGLinkFrame.CmbEstadoChange( Sender: TObject );
begin
  FItem.Estado := CmbEstado.ItemIndex;
end;

procedure TPGLinkFrame.CmbOperationChange( Sender: TObject );
begin
  FItem.Operation := CmbOperation.ItemIndex;
end;

procedure TPGLinkFrame.CmbPrioridadeChange( Sender: TObject );
begin
  FItem.Prioridade := CmbPrioridade.ItemIndex;
end;

constructor TPGLinkFrame.Create( Item: TPGItem; Parent: TObject );
begin
  inherited Create( Item, Parent );
  FItem := TPGLink( Item );
  EdtArquivo.Text := FItem.Arquivo;
  EdtParametro.Text := FItem.Parametro;
  EdtDiretorio.Text := FItem.Diretorio;
  CmbEstado.ItemIndex := FItem.Estado;
  CmbPrioridade.ItemIndex := FItem.Prioridade;
  CmbOperation.ItemIndex := FItem.Operation;
  EdtScriptIni.Lines.Text := FItem.ScriptIni;
  EdtScriptEnd.Lines.Text := FItem.ScriptEnd;
  FFrmAutoCompleteI := TFrmAutoComplete.Create( EdtScriptIni );
  FFrmAutoCompleteE := TFrmAutoComplete.Create( EdtScriptEnd );

end;

destructor TPGLinkFrame.Destroy;
begin
  FItem := nil;
  FFrmAutoCompleteI.Free( );
  FFrmAutoCompleteE.Free( );
  inherited Destroy( );
end;

procedure TPGLinkFrame.EdtArquivoChange( Sender: TObject );
begin
  FItem.Arquivo := EdtArquivo.Text;
  if FItem.isFileExist then
    EdtArquivo.Color := clWindow
  else
    EdtArquivo.Color := clRed;
end;

procedure TPGLinkFrame.EdtDiretorioChange( Sender: TObject );
begin
  FItem.Diretorio := EdtDiretorio.Text;
  if FItem.isDirExist then
    EdtDiretorio.Color := clWindow
  else
    EdtDiretorio.Color := clRed;
end;

procedure TPGLinkFrame.EdtNameKeyUp( Sender: TObject; var Key: Word;
   Shift: TShiftState );
begin
  if FItem.isItemExist( EdtName.Text, False ) then
  begin
    EdtName.Color := clRed;
  end else begin
    EdtName.Color := clWindow;
    inherited;
  end;
end;

procedure TPGLinkFrame.EdtParametroChange( Sender: TObject );
begin
  FItem.Parametro := EdtParametro.Text;
end;

procedure TPGLinkFrame.EdtScriptEndChange( Sender: TObject );
begin
  FItem.ScriptEnd := EdtScriptEnd.Lines.Text;
end;

procedure TPGLinkFrame.EdtScriptIniChange( Sender: TObject );
begin
  FItem.ScriptIni := EdtScriptIni.Lines.Text;
end;

procedure TPGLinkFrame.IniConfigLoad;
begin
  inherited;
  Self.GpbScriptEnd.Height := FIniFile.ReadInteger( Self.ClassName, 'Scripts',
     Self.GpbScriptEnd.Height );
end;

procedure TPGLinkFrame.IniConfigSave;
begin
  FIniFile.WriteInteger( Self.ClassName, 'Scripts', Self.GpbScriptEnd.Height );
  inherited;
end;

end.
