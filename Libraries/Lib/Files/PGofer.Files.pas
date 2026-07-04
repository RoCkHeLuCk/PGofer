unit PGofer.Files;

interface

uses
  PGofer.Core, PGofer.Runtime;

{$M+}
type
  TPGFileEncrypt = class;

  {$WARN SYMBOL_PLATFORM OFF}
  [TPGClassReg('Commands')]
  TPGFile = class( TPGItemClass )
  private
    FEncrypt : TPGFileEncrypt;
  public
  published
    property Encrypt: TPGFileEncrypt read FEncrypt;
    function Copy( FileFrom, FileTo: string; Flags: Word ): Integer;
    function Delete( FileFrom: string; Flags: Word ): Integer;
    function DirExists( Directory: string ): Boolean;
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
    function Script( FileName: string; Esperar: Boolean = False ): Boolean;
    function Search( FileName, DirList: string ): string;
    function SetAttrib( FileName: string; Flags: Integer ): Boolean;
    function SetDateTime( FileName: string;
      CreateTime, ModifyTime, AcessTime: TDateTime ): Boolean;
  end;

  TPGFileEncrypt = class( TPGItemClass )
  private
  public
  published
    function AESEncryptFile(FileFrom, FileTo, Password: string): Boolean;
    function AESDecryptFile(FileFrom, FileTo, Password: string): Boolean;
    function AESEncryptStringToFile(StringFrom, FileTo, Password: string): Boolean;
    function AESDecryptFileToString(FileFrom, Password: string): string;
    function DPAPIEncryptFile(FileFrom, FileTo, Entropy: string): Boolean;
    function DPAPIDecryptFile(FileFrom, FileTo, Entropy: string): Boolean;
    function DPAPIEncryptStringToFile(StringFrom, FileTo, Entropy: string): Boolean;
    function DPAPIDecryptFileToString(FileFrom, Entropy: string): string;
  end;


implementation

uses
  System.SysUtils,
  PGofer.Files.Controls,
  PGofer.Files.Encrypt;

{ TPGFile }

function TPGFile.Copy( FileFrom, FileTo: string; Flags: Word ): Integer;
begin
  Result := PGofer.Files.Controls.FileControl( FileFrom, FileTo, $0002, Flags );
end;

function TPGFile.Delete( FileFrom: string; Flags: Word ): Integer;
begin
  Result := PGofer.Files.Controls.FileControl( FileFrom, '', $0003, Flags );
end;

function TPGFile.DirExists( Directory: string ): Boolean;
begin
  Result := System.SysUtils.DirectoryExists( Directory, True );
end;

function TPGFile.Exec( FileName, Parametro, Diretorio: string;
  ShowControl: Integer; Operation: Byte; Prioridade: Byte ): string;
begin
  Result := PGofer.Files.Controls.FileExec( FileName, Parametro, Diretorio, ShowControl, Operation, Prioridade );
end;

function TPGFile.ExtractDir( FileName: string ): string;
begin
  Result := System.SysUtils.ExtractFileDir( FileName );
end;

function TPGFile.ExtractExt( FileName: string ): string;
begin
  Result := System.SysUtils.ExtractFileExt( FileName );
end;

function TPGFile.ExtractName( FileName: string ): string;
begin
  Result := System.SysUtils.ExtractFileName( FileName );
end;

function TPGFile.ExtractPath( FileName: string ): string;
begin
  Result := System.SysUtils.ExtractFilePath( FileName );
end;

function TPGFile.GetAttrib( FileName: string ): Integer;
begin
  Result := System.SysUtils.FileGetAttr( FileName + #0 + #0, True );
end;

function TPGFile.GetSize( FileName: string ): Int64;
begin
  Result := PGofer.Files.Controls.FileGetSize( FileName );
end;

function TPGFile.GetTimeAcess( FileName: string ): string;
begin
  Result := PGofer.Files.Controls.FileGetAcessTime( FileName );
end;

function TPGFile.GetTimeCreate( FileName: string ): string;
begin
  Result := PGofer.Files.Controls.FileGetCreateTime( FileName );
end;

function TPGFile.GetTimeModify( FileName: string ): string;
begin
  Result := PGofer.Files.Controls.FileGetModifyTime( FileName );
end;

function TPGFile.LoadFromText( FileName: string ): string;
begin
  Result := PGofer.Files.Controls.FileLoadFromText( FileName );
end;

function TPGFile.MkDir( Directory: string ): Boolean;
begin
  try
    System.MkDir( Directory );
  finally
    Result := System.SysUtils.DirectoryExists( Directory, False );
  end;
end;

function TPGFile.MkLink( Origin, Destine: string; Flag: Word ): Boolean;
begin
  Result := PGofer.Files.Controls.CreateSymbolicLinkW( PWideChar( Destine ), PWideChar( Origin ), Cardinal( Flag ) );
end;

function TPGFile.Move( FileFrom, FileTo: string; Flags: Word ): Integer;
begin
  Result := PGofer.Files.Controls.FileControl( FileFrom, FileTo, $0001, Flags );
end;

function TPGFile.FileDialog( Directory: string ): string;
begin
  Result := PGofer.Files.Controls.FileOpenSaveDialog('', '', Directory, False );
end;

function TPGFile.DirDialog( Directory: string ): string;
begin
  Result := PGofer.Files.Controls.FileDirDialog( Directory );
end;

function TPGFile.PathExpand( FileName: string ): string;
begin
  Result := PGofer.Files.Controls.FileExpandPath( FileName );
end;

function TPGFile.PathUnExpand( FileName: string ): string;
begin
  Result := PGofer.Files.Controls.FileUnExpandPath( FileName );
end;

function TPGFile.Rename( FileFrom, FileTo: string; Flags: Word ): Integer;
begin
  Result := PGofer.Files.Controls.FileControl( FileFrom, FileTo, $0004, Flags );
end;

function TPGFile.SaveToText( FileName, Text: string ): Boolean;
begin
  Result := PGofer.Files.Controls.FileSaveToText( FileName, Text );
end;

function TPGFile.Script( FileName: string; Esperar: Boolean ): Boolean;
begin
  Result := PGofer.Runtime.FileScriptExec( FileName, Esperar );
end;

function TPGFile.Search( FileName, DirList: string ): string;
begin
  Result := System.SysUtils.FileSearch( FileName + #0 + #0, DirList );
end;

function TPGFile.SetAttrib( FileName: string; Flags: Integer ): Boolean;
begin
  Result := ( System.SysUtils.FileSetAttr( FileName + #0 + #0, Flags, True ) = 0 );
end;

function TPGFile.SetDateTime( FileName: string; CreateTime, ModifyTime, AcessTime: TDateTime ): Boolean;
begin
  Result := PGofer.Files.Controls.FileSetDateTime( FileName, CreateTime, ModifyTime, AcessTime );
end;

{ TPGFileEncrypt }

function TPGFileEncrypt.AESEncryptFile(FileFrom, FileTo, Password: string): Boolean;
begin
  Result := PGofer.Files.Encrypt.AESEncryptFile(FileFrom, FileTo, Password);
end;

function TPGFileEncrypt.AESDecryptFile(FileFrom, FileTo, Password: string): Boolean;
begin
  Result := PGofer.Files.Encrypt.AESDecryptFile(FileFrom, FileTo, Password);
end;

function TPGFileEncrypt.AESEncryptStringToFile(StringFrom, FileTo, Password: string): Boolean;
begin
  Result := PGofer.Files.Encrypt.AESEncryptStringToFile(StringFrom, FileTo, Password);
end;

function TPGFileEncrypt.AESDecryptFileToString(FileFrom, Password: string): string;
begin
   Result := PGofer.Files.Encrypt.AESDecryptFileToString(FileFrom, Password);
end;

function TPGFileEncrypt.DPAPIEncryptFile(FileFrom, FileTo, Entropy: string): Boolean;
begin
  Result := PGofer.Files.Encrypt.DPAPIEncryptFile(FileFrom, FileTo, Entropy);
end;

function TPGFileEncrypt.DPAPIDecryptFile(FileFrom, FileTo, Entropy: string): Boolean;
begin
  Result := PGofer.Files.Encrypt.DPAPIDecryptFile(FileFrom, FileTo, Entropy);
end;

function TPGFileEncrypt.DPAPIEncryptStringToFile(StringFrom, FileTo, Entropy: string): Boolean;
begin
   Result := PGofer.Files.Encrypt.DPAPIEncryptStringToFile(StringFrom, FileTo, Entropy);
end;

function TPGFileEncrypt.DPAPIDecryptFileToString(FileFrom, Entropy: string): string;
begin
   Result := PGofer.Files.Encrypt.DPAPIDecryptFileToString(FileFrom, Entropy);
end;

initialization

finalization

end.
