unit UnitMain;

interface

uses
    Winapi.Windows, Winapi.Messages,
    System.SysUtils, System.Variants, System.Classes, System.TypInfo,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
    Vcl.StdCtrls, Vcl.Menus,
    SynEdit,
    PGofer.Forms, PGofer.Form.AutoComplete;

type
    TFrmMain = class(TFormEx)
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
        procedure Lexico1Click(Sender: TObject);
        procedure Sintatico1Click(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure Salvar1Click(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    private
        FFrmAutoComplete: TFrmAutoComplete;
    public
    end;

var
    FrmMain: TFrmMain;

implementation

uses
    PGofer.Classes, PGofer.Lexico, PGofer.Sintatico,
    PGofer.Links, PGofer.Hotkey,
    PGofer.Forms.Controls;

{$R *.dfm}

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    inherited;
    //
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
    inherited;
    if (FileExists(paramstr(0) + '.pas')) then
        SynEdit1.Lines.LoadFromFile(paramstr(0) + '.pas');

    FFrmAutoComplete := TFrmAutoComplete.Create(SynEdit1);
    TPGForm.Create(Self);
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
    FFrmAutoComplete.Free();
    inherited;
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
