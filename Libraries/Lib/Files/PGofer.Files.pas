unit PGofer.Files;

interface

uses
    PGofer.Sintatico.Classes;

type
{$WARN SYMBOL_PLATFORM OFF}
{$M+}
    TPGFile = class(TPGItemCMD)
    private
    public
    published
        function Copy(FileFrom, FileTo: String; Flags: Word): Integer;
        function Delete(FileFrom: String; Flags: Word): Integer;
        function DirExists(Directory: String): Boolean;
        function Exec(FileName, Parametro, Diretorio: String;
          ShowControl: Integer; Operation: Byte; Prioridade: Byte): String;
        function ExtractDir(FileName: String): String;
        function ExtractExt(FileName: String): String;
        function ExtractName(FileName: String): String;
        function ExtractPath(FileName: String): String;
        function GetAttrib(FileName: String): Integer;
        function GetSize(FileName: String): Int64;
        function GetTimeAcess(FileName: String): String;
        function GetTimeCreate(FileName: String): String;
        function GetTimeModify(FileName: String): String;
        function LoadFromText(FileName: String): String;
        function MkDir(Directory: String): Boolean;
        function Move(FileFrom, FileTo: String; Flags: Word): Integer;
        function FileDialog(Directory: String): String;
        function DirDialog(Directory: String): String;
        function PathExpand(FileName: String): String;
        function PathUnExpand(FileName: String): String;
        function Rename(FileFrom, FileTo: String; Flags: Word): Integer;
        function SaveToText(FileName, Text: String): Boolean;
        function Script(FileName: String; Esperar: Boolean): Boolean;
        function Search(FileName, DirList: String): String;
        function SetAttrib(FileName: String; Flags: Integer): Boolean;
        function SetDateTime(FileName: String;
          CreateTime, ModifyTime, AcessTime: TDateTime): Boolean;
    end;
{$TYPEINFO ON}

implementation

uses
    System.SysUtils,
    PGofer.Sintatico, PGofer.Files.Controls;

{ TPGFile }

function TPGFile.Copy(FileFrom, FileTo: String; Flags: Word): Integer;
begin
    Result := FileControl(FileFrom, FileTo, $0002, Flags);
end;

function TPGFile.Delete(FileFrom: String; Flags: Word): Integer;
begin
    Result := FileControl(FileFrom, '', $0003, Flags);
end;

function TPGFile.DirExists(Directory: String): Boolean;
begin
    Result := DirectoryExists(Directory, True);
end;

function TPGFile.Exec(FileName, Parametro, Diretorio: String;
  ShowControl: Integer; Operation: Byte; Prioridade: Byte): String;
begin
    Result := FileExec(FileName, Parametro, Diretorio, ShowControl, Operation,
      Prioridade);
end;

function TPGFile.ExtractDir(FileName: String): String;
begin
    Result := ExtractFileDir(FileName);
end;

function TPGFile.ExtractExt(FileName: String): String;
begin
    Result := ExtractFileExt(FileName);
end;

function TPGFile.ExtractName(FileName: String): String;
begin
    Result := ExtractFileName(FileName);
end;

function TPGFile.ExtractPath(FileName: String): String;
begin
    Result := ExtractFilePath(FileName);
end;

function TPGFile.GetAttrib(FileName: String): Integer;
begin
    Result := FileGetAttr(FileName + #0 + #0, True);
end;

function TPGFile.GetSize(FileName: String): Int64;
begin
    Result := FileGetSize(FileName);
end;

function TPGFile.GetTimeAcess(FileName: String): String;
begin
    Result := FileGetAcessTime(FileName);
end;

function TPGFile.GetTimeCreate(FileName: String): String;
begin
    Result := FileGetCreateTime(FileName);
end;

function TPGFile.GetTimeModify(FileName: String): String;
begin
    Result := FileGetModifyTime(FileName);
end;

function TPGFile.LoadFromText(FileName: String): String;
begin
    Result := FileLoadFromText(FileName);
end;

function TPGFile.MkDir(Directory: String): Boolean;
begin
    try
        System.MkDir(Directory);
    finally
        Result := DirectoryExists(Directory, False);
    end;
end;

function TPGFile.Move(FileFrom, FileTo: String; Flags: Word): Integer;
begin
    Result := FileControl(FileFrom, FileTo, $0001, Flags);
end;

function TPGFile.FileDialog(Directory: String): String;
begin
    Result := FileOpenDialog(Directory);
end;

function TPGFile.DirDialog(Directory: String): String;
begin
    Result := FileDirDialog(Directory);
end;

function TPGFile.PathExpand(FileName: String): String;
begin
    Result := FileExpandPath(FileName);
end;

function TPGFile.PathUnExpand(FileName: String): String;
begin
    Result := FileUnExpandPath(FileName);
end;

function TPGFile.Rename(FileFrom, FileTo: String; Flags: Word): Integer;
begin
    Result := FileControl(FileFrom, FileTo, $0004, Flags);
end;

function TPGFile.SaveToText(FileName, Text: String): Boolean;
begin
    Result := FileSaveToText(FileName, Text);
end;

function TPGFile.Script(FileName: String; Esperar: Boolean): Boolean;
begin
    Result := FileScript(FileName, Esperar);
end;

function TPGFile.Search(FileName, DirList: String): String;
begin
    Result := FileSearch(FileName + #0 + #0, DirList);
end;

function TPGFile.SetAttrib(FileName: String; Flags: Integer): Boolean;
begin
    Result := (FileSetAttr(FileName + #0 + #0, Flags, True) = 0);
end;

function TPGFile.SetDateTime(FileName: String;
  CreateTime, ModifyTime, AcessTime: TDateTime): Boolean;
begin
    Result := FileSetDateTime(FileName, CreateTime, ModifyTime, AcessTime);
end;

initialization
    TPGFile.Create(GlobalItemCommand);

finalization

end.
