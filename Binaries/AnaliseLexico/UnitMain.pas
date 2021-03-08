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
    PGofer.Form.Controller.Flock;

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
        Globals1: TMenuItem;
        Hotkeys1: TMenuItem;
        Links1: TMenuItem;
        procedure Lexico1Click(Sender: TObject);
        procedure Sintatico1Click(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure Salvar1Click(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure Globals1Click(Sender: TObject);
        procedure Hotkeys1Click(Sender: TObject);
        procedure Links1Click(Sender: TObject);
    private
        FFrmAutoComplete: TFrmAutoComplete;
        FFrmGlobal: TFrmController;
        FFrmHotKeys: TFrmFlock;
        FFrmLinks: TFrmFlock;
    public
    end;

var
    FrmMain: TFrmMain;

implementation

uses
    PGofer.Classes, PGofer.Lexico, PGofer.Sintatico, PGofer.Forms,
    PGofer.Links, PGofer.Hotkey,
    PGofer.Forms.Controls;

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
begin
    if (FileExists(paramstr(0) + '.pas')) then
        SynEdit1.Lines.LoadFromFile(paramstr(0) + '.pas');

    FFrmAutoComplete := TFrmAutoComplete.Create(SynEdit1);
    FormIniLoadFromFile(Self, PGofer.Sintatico.DirCurrent + 'Config.ini');

    TPGForm.Create(Self);
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
    FFrmAutoComplete.Free();

    if Assigned(FFrmHotKeys) then
        FFrmHotKeys.Free();
    if Assigned(FFrmLinks) then
        FFrmLinks.Free();
    if Assigned(FFrmGlobal) then
        FFrmGlobal.Free();

    FormIniSaveToFile(Self, PGofer.Sintatico.DirCurrent + 'Config.ini');
end;

procedure TFrmMain.Globals1Click(Sender: TObject);
begin
    if not Assigned(FFrmGlobal) then
        FFrmGlobal := TFrmController.Create(GlobalCollection);
    FFrmGlobal.Show;
end;

procedure TFrmMain.Hotkeys1Click(Sender: TObject);
begin
    if not Assigned(FFrmHotKeys) then
        FFrmHotKeys := TFrmFlock.Create(TPGHotKey.FlockCollection);
    FFrmHotKeys.Show;
end;

procedure TFrmMain.Links1Click(Sender: TObject);
begin
    if not Assigned(FFrmLinks) then
        FFrmLinks := TFrmFlock.Create(TPGLink.FlockCollection);
    FFrmLinks.Show;
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
