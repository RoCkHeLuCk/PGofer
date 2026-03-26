//Windows.LockWorkStation;

Const Global False:=0;
Const Global True:=1;

if IsDef('Netlimiter')
and Netlimiter.isFileExist
and (not Netlimiter.isRunning) then
begin
  Delay(1000);
  Netlimiter('/minimized');
end;

if IsDef('SystemInformer')
and SystemInformer.isFileExist
and (not SystemInformer.isRunning) then
begin
  Delay(1000);
  SystemInformer;
end;

if isDef('Steam')
and Steam.isFileExist
and (not Steam.isRunning) then
begin
  Delay(1000);
  Steam('-silent');
end;

if IsDef('CorsairLink')
and CorsairLink.isFileExist
and (not CorsairLink.isRunning) then
begin
  Delay(1000);
  CorsairLink('-startup');
end;

if IsDef('Logitech')
and Logitech.isFileExist
and (not Logitech.isRunning) then
begin
  Delay(1000);
  Logitech('/minimized');
end;

if IsDef('WPRun')
and WPRun.isFileExist then
begin
   Delay(1000);
   WPRun;
end;

Process.Kill( Process.FileToPID('ONENOTEM.EXE') );
//File.Script(System.DirCurrent+'\lib\Consts.pas', 1);
File.Delete('%TEMP%\*.*', 1044 );
File.Delete('%SystemRoot%\Prefetch\*.*', 1044 );
File.Delete('%SystemRoot%\Temp\*.*', 1044 );

LinkDef.Auto('%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs','.exe;.lnk');
LinkDef.Auto('%APPDATA%\Microsoft\Windows\Start Menu\Programs','.exe;.lnk');
