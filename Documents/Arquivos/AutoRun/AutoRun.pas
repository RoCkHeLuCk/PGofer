//Script de auto inicializa��o
//Este Script � o primerio a ser executado
//e apartir dele que � chamdado os demais.
System.ConsoleMsg := 0 ;
File.Script( System.DirCurrent+'AutoRun\Consts.pas', 6, 0 );
File.Script( System.DirCurrent+'AutoRun\Fun�oes.pas', 0, 0 );
File.Script( System.DirCurrent+'AutoRun\Winamp.pas', 0, 0 );
File.Script( System.DirCurrent+'AutoRun\Start.pas', 0, 0);
