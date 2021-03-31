unit PGofer.Triggers.Links.ThreadLoadImage;

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics;

type
  TThreadLoadImage = class( TThread )
    constructor Create( Icone: TIcon; Index: Word );
  private
    { Private declarations }
    FIcone: TIcon;
    FIndex: Word;
  protected
    procedure Execute; override;
  public

  end;

implementation

uses

  Vcl.Controls, Winapi.ShellAPI,
  PGofer.Files.Controls;

{ TThreadLoadImage }

constructor TThreadLoadImage.Create( Icone: TIcon; Index: Word );
begin
  // cria thread
  inherited Create( true );
  Priority := tpIdle;
  FreeOnTerminate := true;
  FIcone := Icone;
  FIndex := index;
end;

procedure TThreadLoadImage.Execute( );
var
  IconFileName: string;
begin
  try
    IconFileName := FileExpandPath( IconFileName );
    if ( FileExists( IconFileName ) ) and ( not FileIsReadOnly( IconFileName ) )
    then
    begin
      FIcone := TIcon.Create;
      FIcone.Handle := ExtractAssociatedIcon( 1,
         PWideChar( IconFileName ), FIndex );
      if FIcone.Handle = 0 then
      begin
        FIcone.Free;
        FIcone := nil;
      end;
    end;
  except
  end;
end;
// ----------------------------------------------------------------------------//

end.
