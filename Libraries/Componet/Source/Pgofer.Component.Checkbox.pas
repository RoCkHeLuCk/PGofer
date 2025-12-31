unit Pgofer.Component.Checkbox;

interface

uses
  Vcl.StdCtrls;

type

  TCheckBoxEx = class( TCheckBox )
  private
  protected
  public
    procedure SetCheckedSilent(AValue: Boolean);
  published
  end;

procedure Register;

implementation
uses
   System.Classes;

procedure Register;
begin
  RegisterComponents( 'PGofer', [ TCheckBoxEx ] );
end;

{ TCheckBoxEx }

procedure TCheckBoxEx.SetCheckedSilent(AValue: Boolean);
var
  OldEvent: TNotifyEvent;
begin
  if Self.Checked = AValue then Exit;

  OldEvent := Self.OnClick;
  Self.OnClick := nil;
  Self.Checked := AValue;
  Self.OnClick := OldEvent;
end;

end.
