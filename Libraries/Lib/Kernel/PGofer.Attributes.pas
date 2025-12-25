unit PGofer.Attributes;

interface

uses
  System.SysUtils;

type
  { Atributo simples de Texto }
  TPGAttribText = class(TCustomAttribute)
  private
    FText: string;
  public
    constructor Create(AText: string); overload;
    destructor Destroy( ); override;
    property Text: string read FText;
  end;

implementation

{ TPGAttribText }

constructor TPGAttribText.Create(AText: string);
begin
  inherited Create( );
  FText := AText;
end;

destructor TPGAttribText.Destroy;
begin
  FText := '';
  inherited Destroy( );
end;

end.
