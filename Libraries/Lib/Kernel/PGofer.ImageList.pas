unit PGofer.ImageList;

interface

uses
  Vcl.Controls;

type
  TGlobalImageList = class
  private
    FImageList: TImageList;
    FCurrentPath: string;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
    property ImageList: TImageList read FImageList;
    property CurrentPath: string read FCurrentPath write FCurrentPath;
    function AddIcon( AFileName: string ): Integer;
  end;

var
  GlogalImageList: TGlobalImageList;

implementation

uses
  System.SysUtils, Vcl.Graphics;

{ TGlobalImageList }

constructor TGlobalImageList.Create;
begin
  FImageList := TImageList.Create( nil );
end;

destructor TGlobalImageList.Destroy;
begin
  FImageList.Free;
end;

function TGlobalImageList.AddIcon( AFileName: string ): Integer;
var
  Icon: TIcon;
begin
  AFileName := FCurrentPath + AFileName + '.ico';
  if FileExists( AFileName ) then
  begin
    Icon := TIcon.Create( );
    Icon.LoadFromFile( AFileName );
    Result := FImageList.AddIcon( Icon );
    Icon.Free( );
  end
  else
    Result := 0;
end;

initialization

GlogalImageList := TGlobalImageList.Create( );

finalization

GlogalImageList.Free;

end.
