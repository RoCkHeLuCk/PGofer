//Script de auto inicialização
//Este Script é o primerio a ser executado
//e apartir dele que é chamdado os demais.
System.ConsoleMsg := 0 ;
File.Script( System.DirCurrent+'AutoRun\Consts.pas', 6, 0 );
File.Script( System.DirCurrent+'AutoRun\Funçoes.pas', 0, 0 );
File.Script( System.DirCurrent+'AutoRun\Winamp.pas', 0, 0 );
File.Script( System.DirCurrent+'AutoRun\Start.pas', 0, 0);
