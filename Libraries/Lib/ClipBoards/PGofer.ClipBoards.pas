unit PGofer.ClipBoards;

interface

uses
  PGofer.Runtime;

type
  {$M+}
  TPGClipBoard = class( TPGItemCMD )
  private
  public
  published
    procedure Clear( );
    procedure CopyFromText( Text: string );
    function GetFormat( ): string;
    function LoadFromFile( FileName: string ): Boolean;
    function PasteToText( ): string;
    function SaveToFile( FileName: string ): Boolean;
  end;
  {$TYPEINFO ON}

implementation

uses
  PGofer.ClipBoards.Controls;

{ TPGClipBoard }

procedure TPGClipBoard.Clear( );
begin
  ClipBoardClear( );
end;

procedure TPGClipBoard.CopyFromText( Text: string );
begin
  ClipBoardCopyFromText( Text );
end;

function TPGClipBoard.GetFormat: string;
begin
  Result := ClipBoardGetFormat( );
end;

function TPGClipBoard.LoadFromFile( FileName: string ): Boolean;
begin
  Result := ClipBoardLoadFile( FileName );
end;

function TPGClipBoard.PasteToText: string;
begin
  Result := ClipBoardPasteToText( );
end;

function TPGClipBoard.SaveToFile( FileName: string ): Boolean;
begin
  Result := ClipBoardSaveFile( FileName );
end;

initialization

TPGClipBoard.Create( GlobalItemCommand );

finalization

end.
