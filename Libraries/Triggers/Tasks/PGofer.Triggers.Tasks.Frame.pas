unit PGofer.Triggers.Tasks.Frame;

interface

uses
  System.Classes,
  Winapi.Windows,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Menus, Vcl.Graphics,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Triggers.Tasks, PGofer.Item.Frame,
  PGofer.Forms.AutoComplete,
  PGofer.Component.Edit, PGofer.Component.RichEdit;

type
  TPGTaskFrame = class( TPGFrame )
    LblTipo: TLabel;
    CmbTipo: TComboBox;
    GrbScript: TGroupBox;
    dtpDate: TDateTimePicker;
    dtpTime: TDateTimePicker;
    lblDate: TLabel;
    lblTime: TLabel;
    edtRepeat: TEditEx;
    updRepeat: TUpDown;
    lblRepeat: TLabel;
    EdtScript: TRichEditEx;
    procedure CmbTipoChange( Sender: TObject );
    procedure EdtScriptKeyUp( Sender: TObject; var Key: Word;
       Shift: TShiftState );
    procedure EdtNameKeyUp( Sender: TObject; var Key: Word;
       Shift: TShiftState );
  private
    FItem: TPGTask;
    FFrmAutoComplete: TFrmAutoComplete;
  public
    constructor Create( Item: TPGItem; Parent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

{$R *.dfm}
{ TPGTaskFrame }

constructor TPGTaskFrame.Create( Item: TPGItem; Parent: TObject );
begin
  inherited Create( Item, Parent );
  FItem := TPGTask( Item );
  CmbTipo.ItemIndex := FItem.Tipo;
  EdtScript.Lines.Text := FItem.Script;
  FFrmAutoComplete := TFrmAutoComplete.Create( EdtScript );
end;

destructor TPGTaskFrame.Destroy;
begin
  FFrmAutoComplete.Free( );
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGTaskFrame.EdtNameKeyUp( Sender: TObject; var Key: Word;
   Shift: TShiftState );
begin
  if FItem.isItemExist( EdtName.Text, True ) then
  begin
    EdtName.Color := clRed;
  end else begin
    EdtName.Color := clWindow;
    inherited;
  end;
end;

procedure TPGTaskFrame.EdtScriptKeyUp( Sender: TObject; var Key: Word;
   Shift: TShiftState );
begin
  FItem.Script := EdtScript.Lines.Text;
end;

procedure TPGTaskFrame.CmbTipoChange( Sender: TObject );
begin
  FItem.Tipo := CmbTipo.ItemIndex;
end;

end.
