unit PGofer.Triggers.VaultFolder.Password.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, PGofer.Component.Form, Vcl.StdCtrls,
  Pgofer.Component.Checkbox, PGofer.Component.Edit, Vcl.ExtCtrls;

type
  TFrmVaultFolderPassword = class(TFormEx)
    PnlCurrentPassword: TPanel;
    LblCurrentPassword: TLabel;
    EdtCurrentPassword: TEditEx;
    PnlNewPassword: TPanel;
    LblNewPassword: TLabel;
    EdtNewPassword: TEditEx;
    PnlButtons: TPanel;
    BtnOk: TButton;
    BtnCancel: TButton;
    mmoWarning: TMemo;
    procedure EdtCurrentPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdtNewPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrmVaultFolderPassword.EdtCurrentPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_RETURN then
  begin
    Key := 0;
    if PnlNewPassword.Visible then
       EdtNewPassword.SetFocus
    else
       Self.ModalResult := mrOk;
  end;
end;

procedure TFrmVaultFolderPassword.EdtNewPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_RETURN then
  begin
    Key := 0;
    Self.ModalResult := mrOk;
  end;
end;

procedure TFrmVaultFolderPassword.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
     Self.ModalResult := mrCancel;
end;

end.
