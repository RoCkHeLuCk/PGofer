unit UnitMain;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, SynEdit,
    Vcl.Menus, System.TypInfo, PGofer.Form.AutoComplete;

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
        procedure Lexico1Click(Sender: TObject);
        procedure Sintatico1Click(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure Salvar1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    private
        { Private declarations }
        FFrmAutoComplete : TFrmAutoComplete;
    public
        { Public declarations }
    end;

var
    FrmMain: TFrmMain;

implementation

uses
    PGofer.Classes, PGofer.Lexico, PGofer.Sintatico, PGofer.Forms,
    PGofer.Form.Console;

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
begin
    if (FileExists(paramstr(0) + '.pas')) then
        SynEdit1.Lines.LoadFromFile(paramstr(0) + '.pas');

    TPGItem.OnMsgNotify := FrmConsole.ConsoleMessage;
    FFrmAutoComplete := TFrmAutoComplete.Create(Self,SynEdit1);
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
    FFrmAutoComplete.Free;
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
    Gramatica := TGramatica.Create('Gramatica', TGramatica.Global, True);
    Gramatica.SetAlgoritimo(SynEdit1.Text);
    Gramatica.Start;
end;

end.
