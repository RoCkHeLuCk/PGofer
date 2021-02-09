//variaveis
var global Serial := 'ABCabc123!@#[]\';

//fecha o pgofer
function global Close (  )
begin  
    PGofer.Close;
end;

//desligar
function global Off ( ) 
begin
    System.ShutDown( stmsdShutDown );
end;

//reiniciar
function global Reset ( ) 
begin
    System.ShutDown( stmsdReBoot );
end;

//StandBy
function global StandBy ( ) 
begin
    System.ConsoleMsg := False ;
    System.SetSuspendState( False );
end;

//InstallServices 
function global InstallServices ( ) 
begin 
    File.Script( System.DirCurrent + 'Scripts\Services.pas' ,flsIdle, 0 );
end;

//InstallRegister 
function global InstallRegister ( ) 
begin 
    File.Script( System.DirCurrent + 'Scripts\Registros.pas' ,flsIdle, 0 );
end;

//InstallDeleteFolders 
function global InstallDeleteFolders ( ) 
begin 
    File.Script( System.DirCurrent + 'Scripts\DeletePastas.pas' ,flsIdle, 0 );
end;

//InstallHibernate 
function global InstallHibernate ( ) 
begin 
    File.Exec( 'POWERCFG' , '-H OFF' , '' , flxNormal );
end;

//Atualizar 
function global Atualizar ( ) 
begin 
    File.Exec( System.DirCurrent + 'Atualizar.cmd' , '' , '' , flxNormal );
    PGofer.Close;
end;

//CorelDraw 
function global CorelDraw ( ) 
begin 
    var c := 0;

    //iniciar serviço
    Service.SetState( 'LocalHost', 'PSI_SVC_2', svsRun );
    while ( Service.GetState( 'LocalHost' , 'PSI_SVC_2' ) <> svsRun ) and ( c < 100 ) do
    begin 
        System.Delay( 100 );
        inc( c );
    end;

    //iniciar corel
    CORELDR;
    
    //esperar o corel fechar
    System.Delay( 10000 );
    c := 0;
    while ( Process.FindFile( 'CorelDRW.exe' ) ) and ( c < 10000 ) do
    begin 
        System.Delay( 10000 );
        inc( c );
    end;
    
    //parar o serviço
    Service.SetState( 'LocalHost', 'PSI_SVC_2', svsStop );
    
    //deleta a pasta corel
    File.Delete( 'D:\Documents\Corel\' , 1044 );
    File.Delete( 'D:\Documents\My Palettes\' , 1044 );
    
end;
