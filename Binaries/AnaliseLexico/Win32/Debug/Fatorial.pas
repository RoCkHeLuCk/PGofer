function fat(a);
begin
    if (a > 0) then
    begin
        result := a * fat(a-1);
    end else begin
        result := 1;
    end;
end;

var c := 0;
var c := 10;
:=c;