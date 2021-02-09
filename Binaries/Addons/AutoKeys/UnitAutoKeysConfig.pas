unit UnitAutoKeysConfig;

interface

uses
   Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.ComCtrls,
   Vcl.Controls, System.Classes, PGofer.Controls, SynEdit;


type
  TFrmAutoKeysConfig = class(TForm)
    GrbTexto: TGroupBox;
    PnlItens: TPanel;
    BtOk: TBitBtn;
    BtCancel: TBitBtn;
    RgOpções: TRadioGroup;
    EdtAutoKey: TSynEdit;
    LbVelocidade: TLabel;
    EdtVelocidade: TEdit;
    UdVelocidade: TUpDown;
    LbUnidade: TLabel;
    CbxApagarTrasf: TCheckBox;
    BtnPlay: TSpeedButton;
    BtnGravar: TSpeedButton;
    BtnParar: TSpeedButton;
    GrbGerarPW: TGroupBox;
    CkbLetrasMaiusculas: TCheckBox;
    CkbNumeros: TCheckBox;
    CkbCaracteres: TCheckBox;
    LblDigitos: TLabel;
    EdtDigitos: TEdit;
    UpdDigitos: TUpDown;
    BtnGerar: TButton;
    procedure RgOpçõesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnGerarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAutoKeysConfig: TFrmAutoKeysConfig;

implementation

{$R *.dfm}

uses UnitAutoKeys, PGofer.Key;

//----------------------------------------------------------------------------//
procedure TFrmAutoKeysConfig.BtnGerarClick(Sender: TObject);
begin
    EdtAutoKey.Lines.Add( PassWordGenerator(CkbLetrasMaiusculas.Checked, CkbNumeros.Checked, CkbCaracteres.Checked, UpdDigitos.Position) );
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysConfig.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    IniSaveToFile(Self, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysConfig.FormCreate(Sender: TObject);
begin
    IniLoadFromFile(Self, DirCurrent+'Config.ini');
end;
//----------------------------------------------------------------------------//
procedure TFrmAutoKeysConfig.RgOpçõesClick(Sender: TObject);
begin
    LbVelocidade.Visible := False;
    EdtVelocidade.Visible := False;
    UdVelocidade.Visible := False;
    LbUnidade.Visible := False;
    CbxApagarTrasf.Visible := False;
    BtnPlay.Visible := False;
    BtnGravar.Visible := False;
    BtnParar.Visible := False;

    case (RgOpções.ItemIndex) of
      0 : begin
              LbVelocidade.Visible := True;
              EdtVelocidade.Visible := True;
              UdVelocidade.Visible := True;
           end;

      1 : begin
              CbxApagarTrasf.Visible := True;
          end;

      2 : begin
              BtnPlay.Visible := True;
              BtnGravar.Visible := True;
              BtnParar.Visible := True;
          end;
    end;
end;
//----------------------------------------------------------------------------//

end.
