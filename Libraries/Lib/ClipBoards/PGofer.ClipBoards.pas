unit PGofer.ClipBoards;

interface

uses
    PGofer.Sintatico.Classes;

type
{$M+}
    TPGClipBoard = class(TPGItemCMD)
    private
    public
    published
        procedure Clear();
        procedure CopyFromText(Text: String);
        function GetFormat(): String;
        function LoadFromFile(FileName: String): Boolean;
        function PasteToText(): String;
        function SaveToFile(FileName: String): Boolean;
    end;
{$TYPEINFO ON}

var
    PGClipBoard : TPGClipBoard;

implementation

uses
    PGofer.Sintatico, PGofer.ClipBoards.Controls;

{ TPGClipBoard }

procedure TPGClipBoard.Clear();
begin
    ClipBoardClear();
end;

procedure TPGClipBoard.CopyFromText(Text: String);
begin
    ClipBoardCopyFromText(Text);
end;

function TPGClipBoard.GetFormat: String;
begin
    Result := ClipBoardGetFormat();
end;

function TPGClipBoard.LoadFromFile(FileName: String): Boolean;
begin
    Result := ClipBoardLoadFile(FileName);
end;

function TPGClipBoard.PasteToText: String;
begin
    Result := ClipBoardPasteToText();
end;

function TPGClipBoard.SaveToFile(FileName: String): Boolean;
begin
    Result := ClipBoardSaveFile(FileName);
end;

initialization
    PGClipBoard := TPGClipBoard.Create();
    TGramatica.Global.FindName('Commands').Add(PGClipBoard);

finalization

end.
