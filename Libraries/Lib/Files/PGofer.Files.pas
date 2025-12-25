unit PGofer.Files;

interface

uses
  PGofer.Sintatico.Classes;

type
  {$WARN SYMBOL_PLATFORM OFF}
  {$M+}
  TPGFile = class( TPGItemCMD )
  private
  public
  published
    function AESEncryptFile(FileFrom, FileTo, Password: string): Boolean;
    function AESDecryptFile(FileFrom, FileTo, Password: string): Boolean;
    function AESEncryptStringToFile(StringFrom, FileTo, Password: string): Boolean;
    function AESDecryptFileToString(FileFrom, Password: string): string;
    function Copy( FileFrom, FileTo: string; Flags: Word ): Integer;
    function Delete( FileFrom: string; Flags: Word ): Integer;
    function DirExists( Directory: string ): Boolean;
    function DPAPIEncryptFile(FileFrom, FileTo, Entropy: string): Boolean;
    function DPAPIDecryptFile(FileFrom, FileTo, Entropy: string): Boolean;
    function DPAPIEncryptStringToFile(StringFrom, FileTo, Entropy: string): Boolean;
    function DPAPIDecryptFileToString(FileFrom, Entropy: string): string;
    function Exec( FileName, Parametro, Diretorio: string; ShowControl: Integer;
      Operation: Byte; Prioridade: Byte ): string;
    function ExtractDir( FileName: string ): string;
    function ExtractExt( FileName: string ): string;
    function ExtractName( FileName: string ): string;
    function ExtractPath( FileName: string ): string;
    function GetAttrib( FileName: string ): Integer;
    function GetSize( FileName: string ): Int64;
    function GetTimeAcess( FileName: string ): string;
    function GetTimeCreate( FileName: string ): string;
    function GetTimeModify( FileName: string ): string;
    function LoadFromText( FileName: string ): string;
    function MkDir( Directory: string ): Boolean;
    function MkLink( Origin, Destine: string; Flag: Word ): Boolean;
    function Move( FileFrom, FileTo: string; Flags: Word ): Integer;
    function FileDialog( Directory: string ): string;
    function DirDialog( Directory: string ): string;
    function PathExpand( FileName: string ): string;
    function PathUnExpand( FileName: string ): string;
    function Rename( FileFrom, FileTo: string; Flags: Word ): Integer;
    function SaveToText( FileName, Text: string ): Boolean;
    function Script( FileName: string; Esperar: Boolean ): Boolean;
    function Search( FileName, DirList: string ): string;
    function SetAttrib( FileName: string; Flags: Integer ): Boolean;
    function SetDateTime( FileName: string;
      CreateTime, ModifyTime, AcessTime: TDateTime ): Boolean;
  end;
  {$TYPEINFO ON}

implementation

uses
  System.SysUtils,
  PGofer.Sintatico, PGofer.Files.Controls, PGofer.Files.Encrypt;

{ TPGFile }

function TPGFile.AESEncryptFile(FileFrom, FileTo, Password: string): Boolean;
begin
  Result := AESEncryptFile(FileFrom, FileTo, Password);
end;

function TPGFile.AESDecryptFile(FileFrom, FileTo, Password: string): Boolean;
begin
  Result := AESDecryptFile(FileFrom, FileTo, Password);
end;

function TPGFile.AESEncryptStringToFile(StringFrom, FileTo, Password: string): Boolean;
begin
  Result := AESEncryptStringToFile(StringFrom, FileTo, Password);
end;

function TPGFile.AESDecryptFileToString(FileFrom, Password: string): string;
begin
   Result := AESDecryptFileToString(FileFrom, Password);
end;

function TPGFile.Copy( FileFrom, FileTo: string; Flags: Word ): Integer;
begin
  Result := FileControl( FileFrom, FileTo, $0002, Flags );
end;

function TPGFile.Delete( FileFrom: string; Flags: Word ): Integer;
begin
  Result := FileControl( FileFrom, '', $0003, Flags );
end;

function TPGFile.DirExists( Directory: string ): Boolean;
begin
  Result := DirectoryExists( Directory, True );
end;

function TPGFile.DPAPIEncryptFile(FileFrom, FileTo, Entropy: string): Boolean;
begin
  Result := DPAPIEncryptFile(FileFrom, FileTo, Entropy);
end;

function TPGFile.DPAPIDecryptFile(FileFrom, FileTo, Entropy: string): Boolean;
begin
  Result := DPAPIDecryptFile(FileFrom, FileTo, Entropy);
end;

function TPGFile.DPAPIEncryptStringToFile(StringFrom, FileTo, Entropy: string): Boolean;
begin
   Result := DPAPIEncryptStringToFile(StringFrom, FileTo, Entropy);
end;

function TPGFile.DPAPIDecryptFileToString(FileFrom, Entropy: string): string;
begin
   Result := DPAPIDecryptFileToString(FileFrom, Entropy);
end;

function TPGFile.Exec( FileName, Parametro, Diretorio: string;
  ShowControl: Integer; Operation: Byte; Prioridade: Byte ): string;
begin
  Result := FileExec( FileName, Parametro, Diretorio, ShowControl, Operation,
    Prioridade );
end;

function TPGFile.ExtractDir( FileName: string ): string;
begin
  Result := ExtractFileDir( FileName );
end;

function TPGFile.ExtractExt( FileName: string ): string;
begin
  Result := ExtractFileExt( FileName );
end;

function TPGFile.ExtractName( FileName: string ): string;
begin
  Result := ExtractFileName( FileName );
end;

function TPGFile.ExtractPath( FileName: string ): string;
begin
  Result := ExtractFilePath( FileName );
end;

function TPGFile.GetAttrib( FileName: string ): Integer;
begin
  Result := FileGetAttr( FileName + #0 + #0, True );
end;

function TPGFile.GetSize( FileName: string ): Int64;
begin
  Result := FileGetSize( FileName );
end;

function TPGFile.GetTimeAcess( FileName: string ): string;
begin
  Result := FileGetAcessTime( FileName );
end;

function TPGFile.GetTimeCreate( FileName: string ): string;
begin
  Result := FileGetCreateTime( FileName );
end;

function TPGFile.GetTimeModify( FileName: string ): string;
begin
  Result := FileGetModifyTime( FileName );
end;

function TPGFile.LoadFromText( FileName: string ): string;
begin
  Result := FileLoadFromText( FileName );
end;

function TPGFile.MkDir( Directory: string ): Boolean;
begin
  try
    System.MkDir( Directory );
  finally
    Result := DirectoryExists( Directory, False );
  end;
end;

function TPGFile.MkLink( Origin, Destine: string; Flag: Word ): Boolean;
begin
  Result := CreateSymbolicLinkW( PWideChar( Destine ), PWideChar( Origin ),
    Cardinal( Flag ) );
end;

function TPGFile.Move( FileFrom, FileTo: string; Flags: Word ): Integer;
begin
  Result := FileControl( FileFrom, FileTo, $0001, Flags );
end;

function TPGFile.FileDialog( Directory: string ): string;
begin
  Result := FileOpenDialog( Directory );
end;

function TPGFile.DirDialog( Directory: string ): string;
begin
  Result := FileDirDialog( Directory );
end;

function TPGFile.PathExpand( FileName: string ): string;
begin
  Result := FileExpandPath( FileName );
end;

function TPGFile.PathUnExpand( FileName: string ): string;
begin
  Result := FileUnExpandPath( FileName );
end;

function TPGFile.Rename( FileFrom, FileTo: string; Flags: Word ): Integer;
begin
  Result := FileControl( FileFrom, FileTo, $0004, Flags );
end;

function TPGFile.SaveToText( FileName, Text: string ): Boolean;
begin
  Result := FileSaveToText( FileName, Text );
end;

function TPGFile.Script( FileName: string; Esperar: Boolean ): Boolean;
begin
  Result := FileScriptExec( FileName, Esperar );
end;

function TPGFile.Search( FileName, DirList: string ): string;
begin
  Result := FileSearch( FileName + #0 + #0, DirList );
end;

function TPGFile.SetAttrib( FileName: string; Flags: Integer ): Boolean;
begin
  Result := ( FileSetAttr( FileName + #0 + #0, Flags, True ) = 0 );
end;

function TPGFile.SetDateTime( FileName: string;
  CreateTime, ModifyTime, AcessTime: TDateTime ): Boolean;
begin
  Result := FileSetDateTime( FileName, CreateTime, ModifyTime, AcessTime );
end;

initialization

TPGFile.Create( GlobalItemCommand );

finalization

end.
