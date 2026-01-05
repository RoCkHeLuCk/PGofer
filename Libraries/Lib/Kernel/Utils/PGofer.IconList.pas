unit PGofer.IconList;

interface

uses
  Vcl.Controls, PGofer.Types;

type
  TPGIconList = class
  private
    class var FImageList: TImageList;
  public
    class constructor Create( );
    class procedure LoadIconFromPath(const ACurrentPath: string );
    class destructor Destroy( );
    class property ImageList: TImageList read FImageList;
  end;

implementation

uses
  System.SysUtils, System.TypInfo,
  Vcl.Graphics,
  PGofer.Sintatico, PGofer.Language;

{ TPGGlobIconList }

class constructor TPGIconList.Create( );
begin
  FImageList := TImageList.Create(nil);
end;

class destructor TPGIconList.Destroy( );
begin
  FImageList.Free;
end;

class procedure TPGIconList.LoadIconFromPath(const ACurrentPath: string );
var
  IconEnum: TPGIcon;
  FileName: string;
  Icon: TIcon;
begin

  for IconEnum := Low(TPGIcon) to High(TPGIcon) do
  begin
    FileName := GetEnumName(TypeInfo(TPGIcon), Ord(IconEnum));
    FileName := copy(FileName, 4, Length(FileName));
    FileName := ACurrentPath + FileName + '.ico';

    Icon := TIcon.Create( );
    try
      if FileExists( FileName ) then
      begin
        Icon.LoadFromFile( FileName );
      end else begin
        TrC('Error_IconNoFound',[FileName]);
      end;
      FImageList.AddIcon( Icon );
    finally
      Icon.Free( );
    end;
  end;
end;

initialization

{$IFNDEF DEBUG}
  TPGIconList.LoadIconFromPath( DirCurrent + 'Icons\' );
{$ELSE}
  TPGIconList.LoadIconFromPath( '..\..\..\..\Documents\Imagens\Icons\' );
{$ENDIF}

finalization

end.
