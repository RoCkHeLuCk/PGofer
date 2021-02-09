unit UnitPassWord;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask;

type
  TFrmPassword = class(TForm)
    EdtPassWord: TMaskEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CbxPassWord: TCheckBox;
    LblPassWord: TLabel;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPassword: TFrmPassword;

implementation

{$R *.dfm}

procedure TFrmPassword.BitBtn1Click(Sender: TObject);
begin
    if (CbxPassWord.Checked) and (Length(EdtPassWord.Text) < 6) then
       ShowMessage('A senha deve ter no mínimo 6 dígitos.')
    else
       ModalResult := mrOk;
end;

procedure TFrmPassword.SpeedButton1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    EdtPassWord.PasswordChar := #0;
end;

procedure TFrmPassword.SpeedButton1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    EdtPassWord.PasswordChar := '*';
end;

end.
