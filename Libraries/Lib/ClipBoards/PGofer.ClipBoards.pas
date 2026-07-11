unit PGofer.ClipBoards;

interface

uses
  PGofer.Core, PGofer.Runtime;

type
  {$M+}
  [TPGClassReg('Commands')]
  TPGClipBoard = class( TPGItemClass )
  private
  public
  published
    procedure Clear( ); reintroduce;
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

finalization

end.
