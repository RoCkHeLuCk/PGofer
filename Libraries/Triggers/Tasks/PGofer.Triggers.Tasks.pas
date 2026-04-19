unit PGofer.Triggers.Tasks;

interface

uses
  System.Classes, System.Generics.Collections,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers;

type
  {$M+}
  [TPGArgs('Script, Trigger, Repeats')]
  TPGTask = class( TPGItemTrigger )
  private
    FOccurrence: Cardinal;
    FRepeat: Cardinal;
    FScript: TStrings;
    FTrigger: Byte;
    function GetScript: string;
    procedure SetScript( AValue: string );
    class var FTaskList: TThreadList<TPGTask>;
  protected
    class function GetFrameType: TPGTriggerFrameType; override;
  public
    class constructor Create();
    class destructor Destroy();
    class procedure Working( AType: Byte; AWaitFor: Boolean = False );
    constructor Create( AMirror: TPGItemMirror; AName: string ); override;
    destructor Destroy( ); override;
    procedure Triggering( ); override;
    procedure ExecuteAction(AScript: string = '');
  published
    property Occurrence: Cardinal read FOccurrence;
    property Repeats: Cardinal read FRepeat write FRepeat;
    property Script: string read GetScript write SetScript;

    [TPGAbout('Trigger: 0=Initializing, 1=Finishing, 2=Shutdown;')]
    property Trigger: Byte read FTrigger write FTrigger;
  end;
  {$TYPEINFO ON}

  TPGTaskMirror = class( TPGItemMirror )
  protected
    class function GetTriggerType: TPGItemTriggerType; override;
  end;

implementation

uses
  System.SysUtils, System.IniFiles,
  PGofer.Sintatico.Controls,
  PGofer.Triggers.Tasks.Frame;

{ TPGTask }

class constructor TPGTask.Create;
begin
   FTaskList := TThreadList<TPGTask>.Create;
end;

class destructor TPGTask.Destroy;
begin
  FTaskList.Free();
  FTaskList := nil;
end;

class function TPGTask.GetFrameType: TPGTriggerFrameType;
begin
  Result := TPGTaskFrame;
end;

class procedure TPGTask.Working(AType: Byte; AWaitFor: Boolean = False);
var
  LList: TList<TPGTask>;
  LItem: TPGTask;
  LIni: TMemIniFile;
  LNeedSave: Boolean;
begin
  LNeedSave := False;

  // Abre o arquivo de estados uma única vez antes do loop
  LIni := TMemIniFile.Create(TPGKernel.PathCurrent + 'TaskStates.ini');
  try
    LList := FTaskList.LockList;
    try
      for LItem in LList do
      begin
        if (LItem.Trigger = AType) and (LItem.Enabled) and
           ((LItem.Repeats = 0) or (LItem.Occurrence < LItem.Repeats)) then
        begin
          ScriptExec('Task: ' + LItem.Name, LItem.Script, nil, AWaitFor);
          LItem.FOccurrence := LItem.Occurrence + 1;

          // Grava na RAM do MemIniFile
          LIni.WriteInteger(LItem.Name, 'Occurrence', LItem.Occurrence);
          LNeedSave := True;
        end;
      end;
    finally
      FTaskList.UnlockList;
    end;

    // Se alguma task rodou, descarrega a RAM para o disco de uma vez só!
    if LNeedSave then
       LIni.UpdateFile;

  finally
    LIni.Free;
  end;
end;

constructor TPGTask.Create( AMirror: TPGItemMirror; AName: string );
var
  LIni: TMemIniFile;
begin
  FScript := TStringList.Create( );
  FOccurrence := 0;
  FRepeat := 0;
  FTrigger := 0;
  inherited Create( AMirror, AName );
  FTaskList.Add(Self);

  LIni := TMemIniFile.Create(TPGKernel.PathCurrent + 'TaskStates.ini');
  try
    FOccurrence := LIni.ReadInteger(Self.Name, 'Occurrence', 0);
  finally
    LIni.Free;
  end;
end;

destructor TPGTask.Destroy( );
begin
  if Assigned(FTaskList) then
    FTaskList.Remove(Self);
  FScript.Free;
  FOccurrence := 0;
  FTrigger := 0;
  inherited Destroy( );
end;

function TPGTask.GetScript( ): string;
begin
  Result := FScript.Text;
end;

procedure TPGTask.SetScript( AValue: string );
begin
  FScript.Text := AValue;
end;

procedure TPGTask.Triggering( );
begin
  Self.ExecuteAction(FScript.Text);
end;

procedure TPGTask.ExecuteAction(AScript: string);
begin
  if AScript = '' then AScript := FScript.Text;

  if AScript.Trim <> '' then
    ScriptExec( 'Task: ' + Self.Name, AScript, nil, False );
end;

{ TPGTaskMirror }

class function TPGTaskMirror.GetTriggerType: TPGItemTriggerType;
begin
  Result := TPGTask;
end;

initialization
  TPGItemDef.Create(TPGTask, 'TaskDef');
  TriggersCollect.RegisterClass( TPGTaskMirror );

finalization

end.
