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
  PGofer.Sintatico, PGofer.Files.Controls;

{ TPGFile }

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
