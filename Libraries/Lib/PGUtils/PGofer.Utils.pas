unit PGofer.Utils;

interface
uses
    System.SysUtils;

    function SplitEx(Text, Separator: String): TArray<String>;

implementation
uses
    PGofer.Classes;


function SplitEx(Text, Separator: String): TArray<String>;
var
    TxtBgn, TxtEnd, RstLength, TxtLength, SptLength : FixedInt;
begin
    RstLength := 0;
    SetLength(Result, RstLength);
    TxtLength := Text.Length+1;
    SptLength := Separator.Length;
    TxtBgn := LowString;
    while TxtBgn <= TxtLength do
    begin
        TxtEnd := Pos(Separator,Text,TxtBgn);
        if TxtEnd = 0 then
           TxtEnd := TxtLength+1;

        Inc(RstLength);
        SetLength(Result, RstLength);
        Result[RstLength-1] := Copy(Text,TxtBgn,TxtEnd-TxtBgn);
        TxtBgn := TxtEnd + SptLength;
    end;
end;



end.
