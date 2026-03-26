unit PGofer.Triggers.Links;

interface

uses
  System.Classes, System.Generics.Collections,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers;

type
  {$M+}
  [TPGArgs('FileName, Parameter, Directory, State, SingleInstance, '+
           'RunAdmin, CaptureMsg, Priority, ScriptBefor, ScriptAfter')]
  TPGLink = class( TPGItemTrigger )
  private
    FFileName: string;
    FParameter: string;
    FDirectory: string;
    FScriptBefor: TStrings;
    FScriptAfter: TStrings;
    FState: Byte;
    FPriority: Byte;
    FRunAdmin: Boolean;
    FCaptureMsg: Boolean;
    FCanExecute: Boolean;
    FSingleInstance: Boolean;
    function GetDirExist(): Boolean;
    function GetFileExist(): Boolean;
    function GetFileRepeat(): Boolean;
    function GetScriptAfter: string;
    function GetScriptBefor: string;
    procedure SetScriptAfter( AValue: string );
    procedure SetScriptBefor( AValue: string );
    function GetIsRunning: Boolean;
    class var FLinkList: TList<TPGLink>;
  protected
    function GetIsValid(): Boolean; override;
    class function GetFrameType: TPGTriggerFrameType; override;
  public
    class constructor Create();
    class destructor Destroy();
    constructor Create(AMirror: TPGItemMirror; AName: string); override;
    destructor Destroy(); override;
    procedure Triggering(); override;
    procedure ExecuteAction(AParameter: string = ''; AWait: Boolean = False;
      AState: Byte = 1; ARunAdmin: Boolean = False; ASingleInstance: Boolean = False);
  published
    class procedure Auto(ADir: string; AMask: string);
    procedure WaitFor(AParameter: string = ''; AState: Byte = 1);
    function KillMe(): Boolean;
    property FileName: string read FFileName write FFileName;
    property Parameter: string read FParameter write FParameter;
    property Directory: string read FDirectory write FDirectory;
    property State: Byte read FState write FState;
    property SingleInstance: Boolean read FSingleInstance write FSingleInstance;
    property Priority: Byte read FPriority write FPriority;
    property RunAdmin: Boolean read FRunAdmin write FRunAdmin;
    property CaptureMsg: Boolean read FCaptureMsg write FCaptureMsg;
    property ScriptBefor: string read GetScriptBefor write SetScriptBefor;
    property ScriptAfter: string read GetScriptAfter write SetScriptAfter;
    property isFileExist: Boolean read GetFileExist;
    property isFileRepeat: Boolean read GetFileRepeat;
    property isDirExist: Boolean read GetDirExist;
    property CanExecute: Boolean read FCanExecute write FCanExecute;
    property isRunning: Boolean read GetIsRunning;
  end;
  {$TYPEINFO ON}

  TPGLinkMirror = class( TPGItemMirror )
  protected
    class function GetTriggerType: TPGItemTriggerType; override;
  public
    class function OnDropFile( AItemDad: TPGItem; AFileName: String ): boolean; override;
  end;

implementation

uses
  System.SysUtils, System.StrUtils,
  PGofer.Lexico,
  PGofer.Sintatico.Controls,
  PGofer.Files.Controls,
  PGofer.Files.WinShell,
  PGofer.Process.Controls,
  PGofer.Triggers.Links.Frame,
  PGofer.Triggers.Links.Thread;

{ TPGLink }

class constructor TPGLink.Create;
begin
  FLinkList := TList<TPGLink>.Create;
end;

class destructor TPGLink.Destroy;
begin
  FLinkList.Free();
  FLinkList := nil;
end;

constructor TPGLink.Create(AMirror: TPGItemMirror; AName: string);
begin
  FFileName := '';
  FParameter := '';
  FDirectory := '';
  FState := 1;
  FPriority := 2;
  FRunAdmin := False;
  FScriptBefor := TStringList.Create();
  FScriptAfter := TStringList.Create();
  FCanExecute := true;
  FSingleInstance := False;
  inherited Create(AMirror, AName);
  FLinkList.Add(Self);
end;

destructor TPGLink.Destroy();
begin
  if Assigned(FLinkList) then
    FLinkList.Remove(Self);
  FFileName := '';
  FParameter := '';
  FDirectory := '';
  FState := 1;
  FPriority := 2;
  FRunAdmin := False;
  FScriptBefor.Free();
  FScriptAfter.Free();
  FCanExecute := False;
  FSingleInstance := False;
  inherited Destroy();
end;

class function TPGLink.GetFrameType: TPGTriggerFrameType;
begin
  Result := TPGLinkFrame;
end;

function TPGLink.GetDirExist: Boolean;
begin
  Result := DirectoryExistsEx(FDirectory);
end;

function TPGLink.GetIsRunning(): Boolean;
begin
  Result := ProcessFileToPID(ExtractFileName(FFileName)) <> 0;
end;

function TPGLink.GetIsValid(): Boolean;
begin
  Result := GetFileExist();
end;

function TPGLink.GetFileExist(): Boolean;
begin
  Result := FileExistsEx(FFileName);
end;

function TPGLink.GetFileRepeat(): Boolean;
var
  Item: TPGLink;
  Text: string;
begin
  Result := False;
  Text := FileUnExpandPath(Self.FFileName);
  for Item in TPGLink.FLinkList do
  begin
    if SameText(FileUnExpandPath(Item.FFileName), Text)
    and SameText(Item.FParameter, Self.FParameter)
    and (Item <> Self) then
    begin
      Result := true;
      Break;
    end;
  end;
end;

function TPGLink.GetScriptAfter(): string;
begin
  Result := FScriptAfter.Text;
end;

function TPGLink.GetScriptBefor(): string;
begin
  Result := FScriptBefor.Text;
end;

function TPGLink.KillMe(): Boolean;
begin
  Result := ProcessKill(ProcessFileToPID(ExtractFileName(FFileName)));
end;

procedure TPGLink.SetScriptAfter(AValue: string);
begin
  FScriptAfter.Text := AValue;
end;

procedure TPGLink.SetScriptBefor(AValue: string);
begin
  FScriptBefor.Text := AValue;
end;

procedure TPGLink.Triggering();
begin
  Self.ExecuteAction(FParameter, False, FState, FRunAdmin, FSingleInstance);
end;

procedure TPGLink.ExecuteAction(AParameter: string; AWait: Boolean; AState: Byte;
  ARunAdmin, ASingleInstance: Boolean);
var
  LinkThread: TLinkThread;
begin
  LinkThread := TLinkThread.Create(
    Self,
    AWait,
    AParameter,
    ARunAdmin,
    ASingleInstance,
    AState
  );

  LinkThread.Start;

  if AWait then
  begin
    LinkThread.WaitFor();
    LinkThread.Free();
  end;
end;

procedure TPGLink.WaitFor(AParameter: string; AState: Byte);
begin
  Self.ExecuteAction(AParameter, True, AState, FRunAdmin, FSingleInstance);
end;

class procedure TPGLink.Auto(ADir: string; AMask: string);

  // Fun��o encapsulada para checar a exist�ncia pr�via na FLinkList
  function IsLinkAlreadyLoaded(const AFileName, AParameter: string): Boolean;
  var
    Item: TPGLink;
    TargetName: string;
  begin
    Result := False;
    TargetName := FileUnExpandPath(AFileName);

    for Item in TPGLink.FLinkList do
    begin
      if SameText(FileUnExpandPath(Item.FFileName), TargetName) and
         SameText(Item.FParameter, AParameter) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  // Fun��o recursiva de busca
  procedure SearchFile(ASubDir: string);
  var
    SearchRec: TSearchRec;
    Link: TPGLink;
    Name, Ext: string;
    Shell: TShellLinkInfo;
    c: Integer;
    TargetFileName, TargetParam, TargetDir: string;
    TargetState: Byte;
  begin
    {$WARN SYMBOL_PLATFORM OFF}
    ASubDir := IncludeTrailingBackslash(ASubDir);
    {$WARN SYMBOL_PLATFORM ON}

    c := FindFirst(ASubDir + '*', faDirectory or faAnyFile, SearchRec);
    while (c = 0) do
    begin
      if (SearchRec.Attr and faDirectory) = 0 then
      begin
        Ext := ExtractFileExt(SearchRec.Name);
        if pos(Ext, AMask) > 0 then
        begin
          // 1. Resolve os dados alvo ANTES de instanciar a classe
          if SameText(Ext, '.lnk') then
          begin
            Shell := GetShellLinkInfo(ASubDir + SearchRec.Name);
            TargetFileName := FileUnExpandPath(Shell.PathName);
            TargetParam := FileUnExpandPath(Shell.Arguments);
            TargetDir := FileUnExpandPath(Shell.WorkingDirectory);
            TargetState := Shell.ShowCmd;
          end else begin
            TargetFileName := FileUnExpandPath(ASubDir + SearchRec.Name);
            TargetParam := '';
            TargetDir := '';
            TargetState := 1;
          end;

          // 2. Verifica se o link j� foi carregado e se possui um alvo v�lido
          if (TargetFileName <> '') and not IsLinkAlreadyLoaded(TargetFileName, TargetParam) then
          begin
            Name := FileExtractOnlyFileName(SearchRec.Name);
            Name := TPGLink.TranscendName(Name, nil);

            // 3. Instancia o objeto apenas sendo in�dito
            Link := TPGLink.Create(nil, Name);
            Link.FFileName := TargetFileName;
            Link.FParameter := TargetParam;
            Link.FDirectory := TargetDir;
            Link.FState := TargetState;

            // 4. Valida��o final de integridade: se o arquivo f�sico destino n�o existir, remove o objeto
            if not Link.isFileExist then
              Link.Free;
          end;
        end;
      end else begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          SearchFile(ASubDir + SearchRec.Name + '\');
      end;

      c := FindNext(SearchRec);
    end;
    FindClose(SearchRec);
  end;

begin
  SearchFile(FileExpandPath(ADir));
end;

{ TPGLinkMirror }

class function TPGLinkMirror.GetTriggerType: TPGItemTriggerType;
begin
  Result := TPGLink;
end;

class function TPGLinkMirror.OnDropFile(AItemDad: TPGItem; AFileName: String): boolean;
var
  LLink: TPGLink;
begin
  Result := False;
  if MatchText(ExtractFileExt(AFileName),
   ['.exe', '.lnk', '.bat', '.cmd', '.ps1', '.url', '.msc']) then
  begin
    LLink := TPGLink(TPGLinkMirror.Create(AItemDad,
         FileExtractOnlyFileName(AFileName)).ItemOriginal);
    LLink.FileName := FileUnExpandPath(AFileName);
    LLink.Directory := FileUnExpandPath(ExtractFilePath(AFileName));
    Result := True;
  end;
end;

initialization
  TPGItemDef.Create(TPGLink, 'LinkDef');
  TriggersCollect.RegisterClass(TPGLinkMirror);

finalization

end.
