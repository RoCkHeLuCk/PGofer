hotkey teste(':=0;');
link meleca('asdf');

const global coco := 10;
var global macaco := 'asdf';
var global teta := 0;

function global soma(a,b);
begin
    result := a + b;
end;

function global permuta(a);
begin
    if a > 1 then
       result := a + permuta(a-1)
    else
       result := 1;
    system.Delay(1000);        
end;


:= permuta(10);