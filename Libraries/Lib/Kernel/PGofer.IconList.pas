unit PGofer.IconList;

interface

uses
  Vcl.Controls, PGofer.Types;

type
  TPGGlobIconList = class
  private
    var FImageList: TImageList;
  public
    constructor Create( ACurrentPath: string ); overload;
    destructor Destroy( ); override;
    property ImageList: TImageList read FImageList;
  end;

var
  GlobIconList: TPGGlobIconList;

implementation

uses
  System.SysUtils, System.TypInfo,
  Vcl.Graphics;

{ TPGGlobIconList }

constructor TPGGlobIconList.Create( ACurrentPath: string );
var
  IconEnum: TPGIcon;
  FileName: string;
  Icon: TIcon;
begin
  inherited Create( );
  FImageList := TImageList.Create(nil);
  for IconEnum := Low(TPGIcon) to High(TPGIcon) do
  begin
    FileName := GetEnumName(TypeInfo(TPGIcon), Ord(IconEnum));
    FileName := copy(FileName, 4, Length(FileName));
    FileName := ACurrentPath + FileName + '.ico';

    Icon := TIcon.Create( );
    if FileExists( FileName ) then
    begin
      Icon.LoadFromFile( FileName );
    end else begin
      //aviso "não erro" no compilador
    end;
    FImageList.AddIcon( Icon );
    Icon.Free( );
  end;
end;

destructor TPGGlobIconList.Destroy( );
begin
  FImageList.Free;
  inherited Destroy( );
end;

initialization

{$IFNDEF DEBUG}
  GlobIconList := TPGGlobIconList.Create( DirCurrent + 'Icons\' );
{$ELSE}
  GlobIconList := TPGGlobIconList.Create( '..\..\..\..\Documents\Imagens\Icons\' );
{$ENDIF}

finalization

GlobIconList.Free;

end.
