unit UnitNotePads;

interface

uses
   Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.Controls, Vcl.ComCtrls,
   WinApi.Messages,
   System.SysUtils, System.Classes, System.UITypes,
   SynEdit;

type
  TFrmNotePads = class(TForm)
    EdtNotePad: TSynEdit;
    MmmNotepad: TMainMenu;
    MniArquivo: TMenuItem;
    MniProcurar: TMenuItem;
    MniNovo: TMenuItem;
    MniSalvar: TMenuItem;
    MniSalvarComo: TMenuItem;
    MniAbrir: TMenuItem;
    MniSair: TMenuItem;
    MniN1: TMenuItem;
    OdgNotepad: TOpenDialog;
    SdgNotePad: TSaveDialog;
    MniEditar: TMenuItem;
    MniSelecionar: TMenuItem;
    MniCompilar: TMenuItem;
    MniRun: TMenuItem;
    StbNotepad: TStatusBar;
    RdgNotePad: TReplaceDialog;
    procedure MniAbrirClick(Sender: TObject);
    procedure MniNovoClick(Sender: TObject);
    procedure MniSalvarClick(Sender: TObject);
    procedure MniSalvarComoClick(Sender: TObject);
    procedure MniSairClick(Sender: TObject);
    procedure RdgNotePadFind(Sender: TObject);
    procedure RdgNotePadReplace(Sender: TObject);
    procedure MniProcurarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MniSelecionarClick(Sender: TObject);
    procedure EdtNotePadDropFiles(Sender: TObject; X, Y: Integer; AFiles: TStrings);
    procedure MniRunClick(Sender: TObject);
    procedure EdtNotePadKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdtNotePadChange(Sender: TObject);
  private
       Arquivo : String;
       procedure Salvar();
  protected
    procedure WndProc(var Message: TMessage); override;
  public
  end;

var
    FrmNotePads: TFrmNotePads;

implementation
{$R *.dfm}

uses  PGofer.Controls, PGofer.Sintatico;

//---------------------------------------------------------------------------//
procedure TFrmNotePads.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.Salvar();
begin
   //salvar
   if SdgNotePad.Execute then
   begin
       //verifica se o arquivo ja existe
       if (not FileExists(SdgNotePad.FileName))
       or (MessageDlg('Este arquivo já existe!'+#13+'Deseja substituir?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes) then
       begin
           //salva novo ou substitui.
           EdtNotePad.Lines.SaveToFile(SdgNotePad.FileName);
           Arquivo := SdgNotePad.FileName;
           StbNotepad.Panels[1].Text := 'Modificado: Não';
           StbNotepad.Panels[2].Text := 'Arquivo: '+Arquivo;
           EdtNotePad.Modified:=false;
       end;
   end;
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.MniAbrirClick(Sender: TObject);
begin
   //verifica se foi modificado
   if EdtNotePad.Modified then
   begin
       //salva ou nao
       case MessageDlg('Deseja salvar?',mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
            mrYes: MniSalvar.Click;
            mrCancel: Exit;
       end;
   end;

   //abrir arquivo
   OdgNotepad.InitialDir := DirCurrent;
   if OdgNotepad.Execute then
   begin
       EdtNotePad.Lines.LoadFromFile(OdgNotepad.FileName);
       Arquivo := OdgNotepad.FileName;
       StbNotepad.Panels[1].Text := 'Modificado: Não';
       StbNotepad.Panels[2].Text := 'Arquivo: '+Arquivo;
       EdtNotePad.Modified := false;
   end;
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.MniNovoClick(Sender: TObject);
begin
   //verifica se foi modificado
   if EdtNotePad.Modified then
   begin
       //salva ou nao
       case MessageDlg('Deseja salvar?',mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
            mrYes : MniSalvar.Click;
            mrCancel : Exit;
       end;
   end;

   //limpa tudo
   EdtNotePad.Clear;
   Arquivo := '';
   StbNotepad.Panels[1].Text := 'Modificado: Não';
   StbNotepad.Panels[2].Text := 'Arquivo: '+Arquivo;
   EdtNotePad.Modified := false;
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.MniSalvarClick(Sender: TObject);
begin
   //se nao tiver arquivo
   if Arquivo = '' then
   begin
       Salvar();
   end else begin
       //salva arquivo existente
       EdtNotePad.Lines.SaveToFile(Arquivo);
       EdtNotePad.Modified:=false;
   end;
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.MniSalvarComoClick(Sender: TObject);
begin
    Salvar();
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    //verifica se modifico
    if EdtNotePad.Modified then
    begin
        //salva ou nao
        case MessageDlg('Deseja salvar?',mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
             mrYes:MniSalvar.Click;
             mrCancel:Action:=caNone;
        end;
    end;
    //salva configuração
    IniSaveToFile(Self, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.MniSelecionarClick(Sender: TObject);
begin
    EdtNotePad.SelectAll;
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.MniSairClick(Sender: TObject);
begin
    Close;
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.RdgNotePadFind(Sender: TObject);
var c,d:integer;
begin
    //localizar texto
    c:=0;
    d:=0;
    //pegar posiçao do cursor
    if frFindNext in RdgNotePad.Options then
    begin
        c:= EdtNotePad.CaretY-1;
        d:= EdtNotePad.CaretX;
    end;

    while(c < EdtNotePad.Lines.Count)do
    begin
        while(d < Length(EdtNotePad.Lines[c]))do
        begin
            //localizar a palavra
            if(SameText(RdgNotePad.FindText,Copy(EdtNotePad.Lines[c],d,Length(RdgNotePad.FindText))))then
            begin
                //selecionar a palavra e sair do loop.
                EdtNotePad.CaretY:=c+1;
                EdtNotePad.CaretX:=d;
                EdtNotePad.SelLength:=Length(RdgNotePad.FindText);
                exit;
            end;
            inc(d);
        end;
        d:=1;
        inc(c);
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.RdgNotePadReplace(Sender: TObject);
var c,d:integer;
    texto: string;
begin
    //substituir texto

    //pegar posiçao do cursor
    c:= EdtNotePad.CaretY-1;
    d:= EdtNotePad.CaretX;

    while(c < EdtNotePad.Lines.Count)do
    begin
        while(d < Length(EdtNotePad.Lines[c]))do
        begin
            if(CompareText(RdgNotePad.FindText,Copy(EdtNotePad.Lines[c],d,Length(RdgNotePad.FindText)))=0)then
            begin
                //substituir texto
                texto:= EdtNotePad.Lines[c];
                Delete(texto,d,Length(RdgNotePad.FindText));
                texto:=Copy(texto,1,d-1)+RdgNotePad.ReplaceText+Copy(texto,d,length(texto));
                EdtNotePad.Lines.Delete(c);
                EdtNotePad.Lines.Insert(c,texto);
                //se replace all nao sai.
                if(frReplace in RdgNotePad.Options)then exit;

            end;
            inc(d)
        end;
        d:=1;
        inc(c)
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.MniProcurarClick(Sender: TObject);
begin
    RdgNotePad.Execute;
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.FormCreate(Sender: TObject);
begin
    //carrega configuração
    IniLoadFromFile(Self, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.MniRunClick(Sender: TObject);
var
    Comp : TGramatica;
begin
    //Salvar();
    Comp := TGramatica.Create( EdtNotePad.Text, tpNormal, true, nil );
    Comp.Start;
    //SendScript( EdtNotePad.Text );
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.EdtNotePadChange(Sender: TObject);
begin
    //atualiza status bar
    StbNotepad.Panels[0].Text := 'Linha['+IntToStr(EdtNotePad.CaretXY.Line-1)+']:Coluna['+IntToStr(EdtNotePad.CaretXY.Char-1)+']';
    if EdtNotePad.Modified then
       StbNotepad.Panels[1].Text := 'Modificado: Sim'
    else
       StbNotepad.Panels[1].Text := 'Modificado: Não';
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.EdtNotePadDropFiles(Sender: TObject; X, Y: Integer;
  AFiles: TStrings);
begin
    //adiciona arquivos arrastados
    EdtNotePad.Lines.AddStrings( AFiles );
end;
//----------------------------------------------------------------------------//
procedure TFrmNotePads.EdtNotePadKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    //FrmPGofer.EdtCommand.OnKeyUp(Sender,Key,Shift);
end;
//----------------------------------------------------------------------------//

end.
