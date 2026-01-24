unit PGofer.Forms.Style;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Graphics,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Component.Form;

type

  {$M+}
  TPGStyle = class( TPGItemCMD )
  private
    FForm : TFormEx;
    FColorBodyBack : Integer;
    FColorBodyMain : Integer;
    FColorBodyErro : Integer;
    FColorTextBack : Integer;
    FColorTextMain : Integer;
    FColorTextErro : Integer;
    procedure SetColorBodyBack(const Value: Integer);
    procedure SetColorBodyMain(const Value: Integer);
    procedure SetColorBodyErro(const Value: Integer);
    procedure SetColorTextBack(const Value: Integer);
    procedure SetColorTextErro(const Value: Integer);
    procedure SetColorTextMain(const Value: Integer);
  protected
  public
    constructor Create( AItemDad: TPGItem; AForm: TFormEx ); overload;
    destructor Destroy( ); override;
  published
    property ColorBodyBack : Integer read FColorBodyBack write SetColorBodyBack;
    property ColorBodyMain : Integer read FColorBodyMain write SetColorBodyMain;
    property ColorBodyErro : Integer read FColorBodyErro write SetColorBodyErro;
    property ColorTextBack : Integer read FColorTextBack write SetColorTextBack;
    property ColorTextMain : Integer read FColorTextMain write SetColorTextMain;
    property ColorTextErro : Integer read FColorTextErro write SetColorTextErro;
  end;
  {$TYPEINFO ON}

implementation

uses
  PGofer.Lexico,
  PGofer.Forms.Frame;


{ TPGFormStyle }

constructor TPGStyle.Create(AItemDad: TPGItem; AForm: TFormEx);
begin
   inherited Create(AItemDad);
   FForm := AForm;
   FColorBodyBack := $808080;
   FColorBodyMain := $C0C0C0;
   FColorBodyErro := $0000FF;
   FColorTextBack := $C0C0C0;
   FColorTextMain := $000000;
   FColorTextErro := $5555FF;
end;

destructor TPGStyle.Destroy;
begin
  FForm := nil;
  FColorBodyBack := $000000;
  FColorBodyMain := $000000;
  FColorBodyErro := $000000;
  FColorTextBack := $000000;
  FColorTextMain := $000000;
  FColorTextErro := $000000;
  inherited;
end;

procedure TPGStyle.SetColorBodyBack(const Value: Integer);
begin
  FColorBodyBack := Value;
  FForm.Color := FColorBodyBack;
end;

procedure TPGStyle.SetColorBodyMain(const Value: Integer);
begin
  FColorBodyMain := Value;
end;

procedure TPGStyle.SetColorBodyErro(const Value: Integer);
begin
  FColorBodyErro := Value;
end;

procedure TPGStyle.SetColorTextBack(const Value: Integer);
begin
  FColorTextBack := Value;
end;

procedure TPGStyle.SetColorTextErro(const Value: Integer);
begin
  FColorTextErro := Value;
end;

procedure TPGStyle.SetColorTextMain(const Value: Integer);
begin
  FColorTextMain := Value;
  FForm.Font.Color := FColorTextMain;
end;

initialization

finalization

end.
