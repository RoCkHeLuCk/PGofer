//winamp Preview
function global WinampPreview ( ) 
begin 
    System.ConsoleMsg := False;
    System.SendMessage("Winamp v1.x", stmsmCommand, 40044, 0);
end;

//winamp Play
function global WinampPlay ( ) 
begin 
    System.ConsoleMsg := False;
    System.SendMessage("Winamp v1.x", stmsmCommand, 40045, 0);
end;

//winamp Pause
function global WinampPause ( ) 
begin 
    System.ConsoleMsg := False;
    System.SendMessage("Winamp v1.x", stmsmCommand, 40046, 0);
end;

//winamp Stop
function global WinampStop ( ) 
begin 
    System.ConsoleMsg := False;
    System.SendMessage("Winamp v1.x", stmsmCommand, 40047, 0);
end;

//winamp Next
function global WinampNext ( ) 
begin 
    System.ConsoleMsg := False;
    System.SendMessage("Winamp v1.x", stmsmCommand, 40048, 0);
end;

//winamp VolumeUp
function global WinampVolumeUp ( ) 
begin 
    System.ConsoleMsg := False;
    System.SendMessage("Winamp v1.x", stmsmCommand, 40058, 0);
end;

//winamp VolumeDown
function global WinampVolumeDown ( ) 
begin 
    System.ConsoleMsg := False;
    System.SendMessage("Winamp v1.x", stmsmCommand, 40059, 0);
end;

//winamp Step Up 
function global WinampStepUp ( ) 
begin 
    System.ConsoleMsg := False;
    System.SendMessage("Winamp v1.x", stmsmCommand, 40060, 0);
end;

//winamp Step Down 
function global WinampStepDown ( ) 
begin 
    System.ConsoleMsg := False;
    System.SendMessage("Winamp v1.x", stmsmCommand, 40061, 0);
end;

//winamp Start 
function global WinampStart ( ) 
begin 
    //System.ConsoleMsg := False;
    if System.FindWindow('Winamp v1.x') then
    begin   
        WinampPlay;
    end else begin 
        WINAMP;
        var c := 0 ;
        while (not System.FindWindow('Winamp v1.x')) and ( c < 100 ) do
        begin
            System.Delay( 100 );
            inc( c );
        end; 
        WinampPlay;
    end;    
end;

