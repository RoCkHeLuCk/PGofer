
//configurando sistema
System.AutoClose := False ;
System.FormatReply( True , '' );
System.ConsoleDelay := 5000 ;
System.FileListMax :=  100 ;
System.IconLoader := True ;
System.LoopLimite := 1e10 ;
System.NoOff := True ;

//configurando pgofer
PGofer.Left := 20;
PGofer.Top := 20;
//PGofer.Hide;

//iniciar Process Explorer
if ( not Process.FindFile( 'procexpX64.exe' ) ) then
begin  
    PROCESSXP;
end;

//iniciar NETLIMITER
if ( not Process.FindFile( 'NLClientApp.exe' ) ) then
begin  
    NETLIMITER('/tray');
end;

//iniciar QuikSet
if ( not Process.FindFile( 'quickset.exe' ) ) then
begin  
    QuickSet;
end;

//parando serviços
Service.SetState('LocalHost','PnkBstrA', 1 );

//limpar lixo
File.Delete('c:\Users\Administrator\AppData\Local\Temp\*.*', 1044 );

//papel de parede
System.Delay(1000);
File.Exec('d:\Program Files\Utilits\Wallpaper\WPRun.exe','/run','',0);