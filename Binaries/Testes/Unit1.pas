unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  PGofer.Component.RichEdit, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    RichEditEx1: TRichEditEx;
    Timer1: TTimer;
    Memo1: TMemo;
    StatusBar1: TStatusBar;
    Button1: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses Unit2;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    StatusBar1.Panels[0].Text := 'Y: '+Mouse.CursorPos.Y.ToString +
       'X: '+Mouse.CursorPos.X.ToString;
    StatusBar1.Panels[1].Text := 'Row: '+RichEditEx1.CaretY.ToString+
      ' Col: '+RichEditEx1.CaretX.ToString;
    StatusBar1.Panels[2].Text := 'Y: '+RichEditEx1.DisplayXY.Y.ToString+
      ' X: '+RichEditEx1.DisplayXY.X.ToString;
    StatusBar1.Panels[3].Text := 'SelStart: '+RichEditEx1.SelStart.ToString+
       ' SelLength: '+RichEditEx1.SelLength.ToString+' SelText:'+RichEditEx1.SelText;
    StatusBar1.Panels[4].Text := 'Length Lines: '+RichEditEx1.Lines.Text.Length.ToString+
       ' Length Text: '+Length(RichEditEx1.Text).ToString;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    memo1.Clear;
    Memo1.Lines.Add('CH.Height: '+RichEditEx1.CharHeight.ToString);
    Memo1.Lines.Add('CW.Width: '+RichEditEx1.CharWidth.ToString);
    Memo1.Lines.Add('F.Size: '+RichEditEx1.Font.Size.ToString);
    Memo1.Lines.Add('F.Height: '+RichEditEx1.Font.Height.ToString);
    Memo1.Lines.Add('F.PixelsPerInch: '+RichEditEx1.Font.PixelsPerInch.ToString);
    Memo1.Lines.Add('S.PixelsPerInch: '+Screen.PixelsPerInch.ToString);
    if RichEditEx1.SelStart > 0 then
      Memo1.Lines.Add('Text Cursor:'+RichEditEx1.Text[RichEditEx1.SelStart] );

end;

end.
