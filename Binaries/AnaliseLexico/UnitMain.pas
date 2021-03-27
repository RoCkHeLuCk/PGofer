unit UnitMain;

interface

uses
    Winapi.Windows, Winapi.Messages,
    System.SysUtils, System.Variants, System.Classes, System.TypInfo,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
    Vcl.StdCtrls, Vcl.Menus,
    PGofer.Forms, PGofer.Forms.AutoComplete, Vcl.ComCtrls,
    PGofer.Component.RichEdit;

type
    TFrmMain = class(TFormEx)
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
        StatusBar1: TStatusBar;
        SetCaret1: TMenuItem;
    EdtScript: TRichEditEx;
        procedure Lexico1Click(Sender: TObject);
        procedure Sintatico1Click(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure Salvar1Click(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormDestroy(Sender: TObject);
        procedure EdtScriptSelectionChange(Sender: TObject);
        procedure SetCaret1Click(Sender: TObject);
    private
        FFrmAutoComplete: TFrmAutoComplete;
    public
    end;

var
    FrmMain: TFrmMain;

implementation

uses
    PGofer.Classes, PGofer.Lexico, PGofer.Sintatico, PGofer.Sintatico.Controls,
    PGofer.Triggers.Links, PGofer.Forms.Controls;

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
        EdtScript.Lines.LoadFromFile(paramstr(0) + '.pas');
    TPGForm.Create(Self);
    FFrmAutoComplete := TFrmAutoComplete.Create(EdtScript);
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
    TokenList := Automato.TokenListCreate(EdtScript.Text);
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

procedure TFrmMain.EdtScriptSelectionChange(Sender: TObject);
begin
    StatusBar1.Panels[0].Text := 'Row: ' + EdtScript.CaretY.ToString
                              + ' Col: ' + EdtScript.CaretX.ToString;
end;

procedure TFrmMain.Salvar1Click(Sender: TObject);
begin
    EdtScript.Lines.SaveToFile(paramstr(0) + '.pas');
end;

procedure TFrmMain.SetCaret1Click(Sender: TObject);
begin
    EdtScript.CaretY := 3;
    EdtScript.CaretX := 3;
end;

procedure TFrmMain.Sintatico1Click(Sender: TObject);
var
    Gramatica: TGramatica;
begin
    Gramatica := TGramatica.Create('Gramatica', GlobalCollection, True);
    Gramatica.SetAlgoritimo(EdtScript.Text);
    Gramatica.Start;
end;

end.
