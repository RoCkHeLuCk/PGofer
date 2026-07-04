unit PGofer.Triggers.Links;

interface

uses
  System.Classes, System.Generics.Collections,
  PGofer.Core, PGofer.Classes, PGofer.Runtime,
  PGofer.Triggers;

type
  {$M+}
  [TPGClassReg('Defines', 'LinkDef', True)]
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
    function GetIsRunning: Boolean;
    procedure SetScriptAfter(const AValue: string );
    procedure SetScriptBefor(const AValue: string );
    procedure SetFileName(const Value: string);

    class var FLinkList: TList<TPGLink>;
  protected
    class function GetFrameType: TPGTriggerFrameType; override;
  public
    class function OnDropFile(const AItemDad: TPGItem; const AFileName: String ): boolean; override;

    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
    destructor Destroy(); override;
    procedure Triggering(); override;
    procedure ExecuteAction(const AParameter: string = ''; const AWait: Boolean = False;
      const AState: Byte = 1; const ARunAdmin: Boolean = False; const ASingleInstance: Boolean = False);
  published
    class procedure Auto(const ADir: string; const AMask: string);

    procedure WaitFor(const AParameter: string = ''; const AState: Byte = 1);
    function KillMe(): Boolean;
    property FileName: string read FFileName write SetFileName;
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

  procedure Initialize();
  procedure Finalize();

implementation

uses
  System.SysUtils, System.StrUtils,
  PGofer.Files.Controls,
  PGofer.Files.WinShell,
  PGofer.Process.Controls,
  PGofer.Triggers.Links.Frame,
  PGofer.Triggers.Links.Thread;

procedure Initialize();
begin
  TPGLink.FLinkList := TList<TPGLink>.Create;
  TriggersCollect.RegisterClass(TPGLink);
end;

procedure Finalize();
begin
  TPGLink.FLinkList.Free();
  TPGLink.FLinkList := nil;
  {$IFDEF DEBUG}
  {$ENDIF}
end;

{ TPGLink }

constructor TPGLink.Create(const AItemDad: TPGItem; const AName: string);
begin
  FFileName := '';
  FParameter := '';
  FDirectory := '';
  FState := 1;
  FPriority := 2;
  FRunAdmin := False;
  FCanExecute := true;
  FSingleInstance := False;
  FScriptBefor := TStringList.Create();
  FScriptAfter := TStringList.Create();
  inherited Create(AItemDad, AName);
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

class function TPGLink.GetFrameType(): TPGTriggerFrameType;
begin
  Result := TPGLinkFrame;
end;

function TPGLink.GetDirExist(): Boolean;
begin
  Result := DirectoryExistsEx(FDirectory);
end;

function TPGLink.GetIsRunning(): Boolean;
begin
  Result := ProcessFileToPID(ExtractFileName(FFileName)) <> 0;
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

procedure TPGLink.SetFileName(const Value: string);
begin
  if FFileName = Value then Exit;
  FFileName := Value;
  Self.Invalid := not Self.GetFileExist();
end;

procedure TPGLink.SetScriptAfter(const AValue: string);
begin
  FScriptAfter.Text := AValue;
end;

procedure TPGLink.SetScriptBefor(const AValue: string);
begin
  FScriptBefor.Text := AValue;
end;

procedure TPGLink.Triggering();
begin
  Self.ExecuteAction(FParameter, False, FState, FRunAdmin, FSingleInstance);
end;

procedure TPGLink.ExecuteAction(const AParameter: string; const AWait: Boolean; const AState: Byte;
  const ARunAdmin, ASingleInstance: Boolean);
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

procedure TPGLink.WaitFor(const AParameter: string; const AState: Byte);
begin
  Self.ExecuteAction(AParameter, True, AState, FRunAdmin, FSingleInstance);
end;

class procedure TPGLink.Auto(const ADir: string; const AMask: string);
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
  procedure SearchFile(const ASubDir: string);
  var
    LSearchRec: TSearchRec;
    LLink: TPGLink;
    LName, LExt, LSubDir: string;
    LShell: TShellLinkInfo;
    LCount: Integer;
    LTargetFileName, LTargetParam, LTargetDir: string;
    LTargetState: Byte;
  begin
    {$WARN SYMBOL_PLATFORM OFF}
    LSubDir := IncludeTrailingBackslash(ASubDir);
    {$WARN SYMBOL_PLATFORM ON}

    LCount := FindFirst(LSubDir + '*', faDirectory or faAnyFile, LSearchRec);
    while (LCount = 0) do
    begin
      if (LSearchRec.Attr and faDirectory) = 0 then
      begin
        LExt := ExtractFileExt(LSearchRec.Name);
        if pos(LExt, AMask) > 0 then
        begin
          if SameText(LExt, '.lnk') then
          begin
            LShell := GetShellLinkInfo(ASubDir + LSearchRec.Name);
            LTargetFileName := FileUnExpandPath(LShell.PathName);
            LTargetParam := FileUnExpandPath(LShell.Arguments);
            LTargetDir := FileUnExpandPath(LShell.WorkingDirectory);
            LTargetState := LShell.ShowCmd;
          end else begin
            LTargetFileName := FileUnExpandPath(ASubDir + LSearchRec.Name);
            LTargetParam := '';
            LTargetDir := '';
            LTargetState := 1;
          end;

          if (LTargetFileName <> '') and not IsLinkAlreadyLoaded(LTargetFileName, LTargetParam) then
          begin
            LName := FileExtractOnlyFileName(LSearchRec.Name);
            LLink := TPGLink.Create(nil, LName);
            LLink.FFileName := LTargetFileName;
            LLink.FParameter := LTargetParam;
            LLink.FDirectory := LTargetDir;
            LLink.FState := LTargetState;
            if not LLink.isFileExist then
              LLink.Free;
          end;
        end;
      end else begin
        if (LSearchRec.Name <> '.') and (LSearchRec.Name <> '..') then
          SearchFile(ASubDir + LSearchRec.Name + '\');
      end;

      LCount := FindNext(LSearchRec);
    end;
    FindClose(LSearchRec);
  end;

begin
  TriggersCollect.BeginUpdate;
  try
    SearchFile(FileExpandPath(ADir));
  finally
    TriggersCollect.EndUpdate;
  end;
end;

class function TPGLink.OnDropFile(const AItemDad: TPGItem; const AFileName: String): boolean;
var
  LLink: TPGLink;
begin
  Result := False;
  if MatchText(ExtractFileExt(AFileName),
   ['.exe', '.lnk', '.bat', '.cmd', '.ps1', '.url', '.msc']) then
  begin
    LLink := TPGLink.Create(AItemDad, FileExtractOnlyFileName(AFileName));
    LLink.FileName := FileUnExpandPath(AFileName);
    LLink.Directory := FileUnExpandPath(ExtractFilePath(AFileName));
    Result := True;
  end;
end;

initialization

finalization

end.
