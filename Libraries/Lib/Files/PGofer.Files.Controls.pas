unit PGofer.Files.Controls;

interface

uses
  WinApi.Windows;

{$WARN SYMBOL_PLATFORM OFF}
function DateTimeToFileTime( DateTime: TDateTime ): PFileTime;
function FileTimeToDateTime( FileTime: TFileTime ): TDateTime;
function FileLimitPathExist( Path: string ): string;
function FileExpandPath( const PathName: string ): string;
function FileUnExpandPath( const PathName: string ): string;
function FileExec( Arquivo, Parametro, Diretorio: string; ShowControl: Integer;
   Operation: Byte; Prioridade: Byte ): string;
function FileControl( FileName, FileAlter: string;
   const Func, Flags: Cardinal ): Integer;
function FileGetSize( FileName: string ): Int64;
function FileLoadFromText( FileName: string ): string;
function FileSaveToText( FileName, Value: string ): Boolean;
function FileListDir( MaskName: string; ExcludeExt: Boolean = False ): string;
function FileOpenDialog( const Dir: string ): string;
function FileDirDialog( Dir: string ): string;
function FileSetDateTime( FileName: string;
   CreateTime, ModifyTime, AcessTime: TDateTime ): Boolean;
function FileGetCreateTime( FileName: string ): string;
function FileGetModifyTime( FileName: string ): string;
function FileGetAcessTime( FileName: string ): string;
function FileExtractOnlyFileName( const FileName: string ): string;
{$WARN SYMBOL_PLATFORM ON}
function GetOperationToStr( Operation: Byte ): PWideChar;
function GetProcessPri( Prioridade: Byte ): Word;
function GetShellExMSGToStr( InstApp: Cardinal ): string;

implementation

uses
{$WARN UNIT_PLATFORM OFF}
  Vcl.Forms, Vcl.FileCtrl, Vcl.Dialogs,
  WinApi.ShellApi, WinApi.ShlwApi,
  System.SysUtils, System.Classes;
{$WARN UNIT_PLATFORM ON}

function DateTimeToFileTime( DateTime: TDateTime ): PFileTime;
var
  FileTime: TFileTime;
  LFT: TFileTime;
  LST: TSystemTime;
begin
  Result := nil;
  if DateTime > 0 then
  begin
    DecodeDate( DateTime, LST.wYear, LST.wMonth, LST.wDay );
    DecodeTime( DateTime, LST.wHour, LST.wMinute, LST.wSecond,
       LST.wMilliSeconds );
    if SystemTimeToFileTime( LST, LFT ) and LocalFileTimeToFileTime( LFT,
       FileTime ) then
    begin
      New( Result );
      Result^ := FileTime;
    end;
  end;
end;

function FileTimeToDateTime( FileTime: TFileTime ): TDateTime;
var
  TimeSystem: TSystemTime;
begin
  FileTimeToSystemTime( FileTime, TimeSystem );
  Result := EncodeDate( TimeSystem.wYear, TimeSystem.wMonth, TimeSystem.wDay ) +
     EncodeTime( TimeSystem.wHour, TimeSystem.wMinute, TimeSystem.wSecond,
     TimeSystem.wMilliSeconds );
end;

function FileLimitPathExist( Path: string ): string;
var
  c, d: Integer;
begin
  Path := FileExpandPath( Path );
  d := Length( Path );
  c := 1;
  while ( c < d ) do
  begin
    while ( ( c < d ) and ( Path[ c ] <> '\' ) ) do
      inc( c );
    if DirectoryExists( copy( Path, 1, c ) ) then
      Result := copy( Path, 1, c )
    else
      c := d;
    inc( c );
  end; // while
end;

function FileExpandPath( const PathName: string ): string;
var
  chrResult: array [ 0 .. 1023 ] of Char;
begin
  if ( ExpandEnvironmentStrings( PChar( PathName ), chrResult, 1024 ) = 0 ) then
    Result := PathName
  else
    Result := Trim( chrResult );
end;

function FileUnExpandPath( const PathName: string ): string;
var
  chrResult: array [ 0 .. 511 ] of Char;
begin
  if not PathUnExpandEnvStrings( PWideChar( PathName ), @chrResult, 512 ) then
    Result := PathName
  else
    Result := Trim( chrResult );
end;

function GetOperationToStr( Operation: Byte ): PWideChar;
begin
  case Operation of
    0:
      Result := 'open';
    1:
      Result := 'edit';
    2:
      Result := 'explore';
    3:
      Result := 'find';
    4:
      Result := 'print';
    5:
      Result := 'properties';
    6:
      Result := 'runas';
  else
    Result := 'open';
  end;
end;

function GetProcessPri( Prioridade: Byte ): Word;
begin
  case Prioridade of
    0:
      Result := IDLE_PRIORITY_CLASS;
    1:
      Result := BELOW_NORMAL_PRIORITY_CLASS;
    2:
      Result := NORMAL_PRIORITY_CLASS;
    3:
      Result := ABOVE_NORMAL_PRIORITY_CLASS;
    4:
      Result := HIGH_PRIORITY_CLASS;
    5:
      Result := REALTIME_PRIORITY_CLASS;
  else
    Result := NORMAL_PRIORITY_CLASS;
  end;
end;

function GetShellExMSGToStr( InstApp: Cardinal ): string;
begin
  case InstApp of
    0:
      Result := 'Erro: Memoria cheia.';
    SE_ERR_FNF:
      Result := 'Erro: Arquivo n�o encontrado.';
    SE_ERR_PNF:
      Result := 'Erro: Diretorio n�o encontrado.';
    SE_ERR_ACCESSDENIED:
      Result := 'Erro: Acesso negado.';
    SE_ERR_OOM:
      Result := 'Erro: Memoria cheia.';
    SE_ERR_DLLNOTFOUND:
      Result := 'Erro: Dll n�o encontrado.';
    SE_ERR_SHARE:
      Result := 'Erro: Compartilhamento n�o encontrado.';
    SE_ERR_ASSOCINCOMPLETE:
      Result := 'Erro: Associa��o incompleta.';
    SE_ERR_DDETIMEOUT:
      Result := 'Erro: Tempo escotado.';
    SE_ERR_DDEFAIL:
      Result := 'Erro: Falha no acesso.';
    SE_ERR_DDEBUSY:
      Result := 'Erro: Debuger.';
    SE_ERR_NOASSOC:
      Result := 'Erro: Nada associado.';
    33, 42:
      Result := 'OK: Executado com exito.';
  else
    Result := 'Erro: Executar Numero: "' + InstApp.ToString + '".';
  end;
end;

function FileExec( Arquivo, Parametro, Diretorio: string; ShowControl: Integer;
   Operation: Byte; Prioridade: Byte ): string;
var
  ShellExecuteInfoW: TShellExecuteInfo;
begin
  Arquivo := FileExpandPath( Arquivo );
  Parametro := FileExpandPath( Parametro );
  Diretorio := FileExpandPath( Diretorio );

  FillChar( ShellExecuteInfoW, SizeOf( TShellExecuteInfoW ), #0 );

  ShellExecuteInfoW.cbSize := SizeOf( TShellExecuteInfoW );
  ShellExecuteInfoW.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfoW.Wnd := Application.Handle;
  ShellExecuteInfoW.lpVerb := GetOperationToStr( Operation );
  ShellExecuteInfoW.lpFile := PWideChar( Arquivo );
  ShellExecuteInfoW.lpParameters := PWideChar( Parametro );
  ShellExecuteInfoW.lpDirectory := PWideChar( Diretorio );
  ShellExecuteInfoW.nShow := ShowControl;

  ShellExecuteExW( @ShellExecuteInfoW );

  if ShellExecuteInfoW.hProcess > 0 then
  begin
    SetPriorityClass( ShellExecuteInfoW.hProcess, GetProcessPri( Prioridade ) );
  end;

  Result := GetShellExMSGToStr( ShellExecuteInfoW.hInstApp );
end;

function FileControl( FileName, FileAlter: string;
   const Func, Flags: Cardinal ): Integer;
var
  Arquivos: TSHFileOpStruct;
begin
  FillChar( Arquivos, SizeOf( Arquivos ), 0 );
  FileName := FileExpandPath( FileName ) + #0 + #0;
  FileAlter := FileExpandPath( FileAlter ) + #0 + #0;
  Arquivos.pFrom := PWideChar( FileName );
  Arquivos.pTo := PWideChar( FileAlter );
  Arquivos.wFunc := Func;
  Arquivos.fFlags := Flags;
  Arquivos.fAnyOperationsAborted := False;
  // executar
  Result := SHFileOperation( Arquivos );
end;

function FileGetSize( FileName: string ): Int64;
var
  SearchRec: TSearchRec;
begin
  Result := 0;
  if FindFirst( FileName + #0 + #0, faAnyFile, SearchRec ) = 0 then
  begin
    Result := SearchRec.Size;
    FindClose( SearchRec );
  end;
end;

function FileLoadFromText( FileName: string ): string;
var
  c: TStringList;
begin
  FileName := FileExpandPath( FileName );
  if FileExists( FileName, True ) then
  begin
    c := TStringList.Create;
    c.LoadFromFile( FileName );
    Result := c.Text;
  end;
end;

function FileSaveToText( FileName, Value: string ): Boolean;
var
  c: TStringList;
begin
  Result := False;
  FileName := FileExpandPath( FileName );
  if FileExists( FileName, True ) then
  begin
    try
      c := TStringList.Create;
      c.Text := Value;
      c.SaveToFile( FileName );
      Result := True;
    except
      Result := False;
    end;
  end;
end;

function FileListDir( MaskName: string; ExcludeExt: Boolean = False ): string;
var
  SearchRec: TSearchRec;
  FileName: string;
  c: Integer;
begin
  Result := '';
  c := FindFirst( FileExpandPath( MaskName ), faAnyFile, SearchRec );
  while ( c = 0 ) do
  begin
    if ExcludeExt then
    begin
      FileName := FileExtractOnlyFileName( SearchRec.Name );
    end
    else
      FileName := SearchRec.Name;

    Result := Result + FileName + #13#10;
    c := FindNext( SearchRec );
  end; // while (c = 0) do
  FindClose( SearchRec );
end;

function FileOpenDialog( const Dir: string ): string;
var
  OpenDialog: TOpenDialog;
begin
  Result := '';
  OpenDialog := TOpenDialog.Create( Application );
  OpenDialog.InitialDir := Dir;
  if OpenDialog.Execute then
    Result := OpenDialog.FileName;
  OpenDialog.Free;
end;

function FileDirDialog( Dir: string ): string;
begin
  Dir := ExtractFilePath( FileLimitPathExist( Dir ) );
  if SelectDirectory( Dir, [ sdAllowCreate, sdPerformCreate, sdPrompt ], 1000 )
  then
    Result := FileUnExpandPath( Dir )
  else
    Result := '';
end;

function FileSetDateTime( FileName: string;
   CreateTime, ModifyTime, AcessTime: TDateTime ): Boolean;
var
  FileHandle: Integer;
  ftCreateTime, ftModifyTime, ftAcessTime: PFileTime;
begin
  ftCreateTime := DateTimeToFileTime( CreateTime );
  ftModifyTime := DateTimeToFileTime( ModifyTime );
  ftAcessTime := DateTimeToFileTime( AcessTime );
  FileHandle := FileOpen( FileExpandPath( FileName ), fmOpenReadWrite or
     fmShareExclusive );

  if FileHandle <> 0 then
  begin
    Result := SetFileTime( FileHandle, ftCreateTime, ftAcessTime,
       ftModifyTime );
    FileClose( FileHandle );
  end
  else
    Result := False;

  Dispose( ftCreateTime );
  Dispose( ftAcessTime );
  Dispose( ftModifyTime );
end;

function FileGetCreateTime( FileName: string ): string;
var
  SearchRec: TSearchRec;
begin
{$WARN SYMBOL_PLATFORM OFF}
  if FindFirst( FileExpandPath( FileName ), faAnyFile, SearchRec ) = 0 then
  begin
    Result := DateTimeToStr
       ( FileTimeToDateTime( SearchRec.FindData.ftCreationTime ) );
    FindClose( SearchRec );
  end
  else
    Result := '';
{$WARN SYMBOL_PLATFORM ON}
end;

function FileGetModifyTime( FileName: string ): string;
var
  SearchRec: TSearchRec;
begin
{$WARN SYMBOL_PLATFORM OFF}
  if FindFirst( FileExpandPath( FileName ), faAnyFile, SearchRec ) = 0 then
  begin
    Result := DateTimeToStr
       ( FileTimeToDateTime( SearchRec.FindData.ftLastWriteTime ) );
    FindClose( SearchRec );
  end
  else
    Result := '';
{$WARN SYMBOL_PLATFORM ON}
end;

function FileGetAcessTime( FileName: string ): string;
var
  SearchRec: TSearchRec;
begin
{$WARN SYMBOL_PLATFORM OFF}
  if FindFirst( FileExpandPath( FileName ), faAnyFile, SearchRec ) = 0 then
  begin
    Result := DateTimeToStr
       ( FileTimeToDateTime( SearchRec.FindData.ftLastAccessTime ) );
    FindClose( SearchRec );
  end
  else
    Result := '';
{$WARN SYMBOL_PLATFORM ON}
end;

function FileExtractOnlyFileName( const FileName: string ): string;
begin
  Result := ExtractFileName( FileName );
  Result := copy( Result, 1, Length( Result ) -
     ExtractFileExt( Result ).Length );
end;

end.
