unit PGofer.IconList;

interface

uses
  Vcl.Controls;

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
  System.TypInfo,
  Vcl.Graphics,
  PGofer.Core, PGofer.Language, PGofer.Files.Controls;

{ TPGGlobIconList }

class constructor TPGIconList.Create( );
begin
  FImageList := TImageList.Create(nil);
  LoadIconFromPath(TPGKernel.GetVar('_PathIcons',''));
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
      if FileExistsEx( FileName ) then
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

finalization

end.
