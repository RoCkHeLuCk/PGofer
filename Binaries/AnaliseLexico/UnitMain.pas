unit UnitMain;

interface

uses
    Winapi.Windows, Winapi.Messages,
    System.SysUtils, System.Variants, System.Classes, System.TypInfo,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
    Vcl.StdCtrls, Vcl.Menus,
    SynEdit,
    PGofer.Form.AutoComplete,
    PGofer.Form.Controller,
    PGofer.Form.Cluster;

type
    TFrmMain = class(TForm)
        SynEdit1: TSynEdit;
        Splitter1: TSplitter;
        MainMenu1: TMainMenu;
        Compilar1: TMenuItem;
        Lexico1: TMenuItem;
        Panel1: TPanel;
        Memo1: TMemo;
        Sintatico1: TMenuItem;
        Arquivos1: TMenuItem;
        Salvar1: TMenuItem;
        mniOpcoes: TMenuItem;
        Controller1: TMenuItem;
        Cluster1: TMenuItem;
        procedure Lexico1Click(Sender: TObject);
        procedure Sintatico1Click(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure Salvar1Click(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure Controller1Click(Sender: TObject);
    procedure Cluster1Click(Sender: TObject);
    private
        { Private declarations }
        FFrmAutoComplete: TFrmAutoComplete;
    public
        { Public declarations }
    end;

var
    FrmMain: TFrmMain;

implementation

uses
    PGofer.Classes, PGofer.Lexico, PGofer.Sintatico, PGofer.Forms,
    PGofer.Forms.Controls;

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
begin
    if (FileExists(paramstr(0) + '.pas')) then
        SynEdit1.Lines.LoadFromFile(paramstr(0) + '.pas');

    FFrmAutoComplete := TFrmAutoComplete.Create(SynEdit1, 'FrmAutoComplete');
    FormIniLoadFromFile(Self, PGofer.Sintatico.DirCurrent + 'Config.ini');

    TPGForm.Create(Self);
    FrmCluster := TFrmCluster.Create();
    FrmController := TFrmController.Create(GlobalCollection);
    FrmCluster.Show;
    FrmController.Show;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
    if Assigned(FrmController) then
        FrmController.Free;

    if Assigned(FrmCluster) then
        FrmCluster.Free;

    FFrmAutoComplete.Free;
    FormIniSaveToFile(Self, PGofer.Sintatico.DirCurrent + 'Config.ini');
end;

procedure TFrmMain.Cluster1Click(Sender: TObject);
begin
    if not Assigned(FrmCluster) then
        FrmCluster := TFrmCluster.Create();
    FrmCluster.Show;
end;

procedure TFrmMain.Controller1Click(Sender: TObject);
begin
    if not Assigned(FrmController) then
        FrmController := TFrmController.Create(GlobalCollection);
    FrmController.Show;
end;

procedure TFrmMain.Lexico1Click(Sender: TObject);
var
    Automato: TAutomato;
    TokenList: TTokenList;
begin
    Memo1.Clear;
    Memo1.Visible := False;

    Automato := TAutomato.Create();
    TokenList := Automato.TokenListCreate(SynEdit1.Text);
    Automato.Free;
    repeat
        Memo1.Lines.Add('Lexema: ' + String(TokenList.Token.Lexema));
        Memo1.Lines.Add('Classe: ' + GetEnumName(TypeInfo(TLexicoClass),
            Integer(TokenList.Token.Classe)));
        Memo1.Lines.Add('');
        TokenList.GetNextToken;
    until (TokenList.Token.Classe in [cmdUnDeclar, cmdEOF]);
    TokenList.Free;

    Memo1.Visible := True;
end;

procedure TFrmMain.Salvar1Click(Sender: TObject);
begin
    SynEdit1.Lines.SaveToFile(paramstr(0) + '.pas');
end;

procedure TFrmMain.Sintatico1Click(Sender: TObject);
var
    Gramatica: TGramatica;
begin
    Gramatica := TGramatica.Create('Gramatica', GlobalCollection, True);
    Gramatica.SetAlgoritimo(SynEdit1.Text);
    Gramatica.Start;
end;

end.
