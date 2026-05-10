unit Pgofer.Component.ComboBox;

interface

uses
  Vcl.StdCtrls, Vcl.ComCtrls;

type

  TPGComboBox = class( TComboBoxEx )
  private
  protected
  public
    procedure SetIndexSilent(AValue: Integer);
  published
    property ItemIndex;
    property Style Default csExDropDownList;
  end;

procedure Register;

implementation
uses
   System.Classes;

procedure Register;
begin
  RegisterComponents( 'PGofer', [ TPGComboBox ] );
end;

{ TComboBoxEx }

procedure TPGComboBox.SetIndexSilent(AValue: Integer);
var
  OldEvent: TNotifyEvent;
begin
  if Self.ItemIndex = AValue then Exit;

  OldEvent := Self.OnChange;
  Self.OnChange := nil;
  Self.ItemIndex := AValue;
  Self.OnChange := OldEvent;
end;

end.
