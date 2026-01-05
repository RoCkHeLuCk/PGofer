unit PGofer.Triggers.Frame;

interface

uses
  System.Classes, System.IniFiles,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Dialogs, Vcl.Graphics,
  PGofer.Classes, PGofer.Runtime, PGofer.Component.Edit,
  PGofer.Item.Frame, PGofer.Triggers;

type
  TPGTriggerFrame = class(TPGItemFrame)
    procedure EdtNameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FItem: TPGItemTrigger;
  protected
  public
    constructor Create( AItem: TPGItemTrigger; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

{$R *.dfm}

constructor TPGTriggerFrame.Create( AItem: TPGItemTrigger; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGItemTrigger( AItem );
end;

destructor TPGTriggerFrame.Destroy( );
begin
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGTriggerFrame.EdtNameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FItem.isItemExist( EdtName.Text, False ) then
  begin
    EdtName.Color := clRed;
  end else begin
    EdtName.Color := clWindow;
    inherited EdtNameKeyUp( Sender, Key, Shift );
  end;
end;

end.
