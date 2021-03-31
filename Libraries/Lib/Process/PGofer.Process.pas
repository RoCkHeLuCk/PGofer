unit PGofer.Process;

interface

uses
  PGofer.Sintatico.Classes;

type
{$M+}
  TPGProcess = class( TPGItemCMD )
  private
  public
  published
    function FileToPID( FileName: string ): Cardinal;
    function FileFromPID( PID: Cardinal ): string;
    function GetPriority( PID: Cardinal ): Byte;
    function GetForeground( ): Cardinal;
    function Kill( PID: Cardinal ): Boolean;
    function SetPriority( PID: Cardinal; Priority: Byte ): Boolean;
  end;
{$TYPEINFO ON}

implementation

uses
  PGofer.Sintatico, PGofer.Process.Controls;

{ TPGProcess }

function TPGProcess.FileToPID( FileName: string ): Cardinal;
begin
  Result := ProcessFileToPID( FileName );
end;

function TPGProcess.FileFromPID( PID: Cardinal ): string;
begin
  Result := ProcessFileFromPID( PID );
end;

function TPGProcess.GetForeground: Cardinal;
begin
  Result := ProcessGetForeground( );
end;

function TPGProcess.GetPriority( PID: Cardinal ): Byte;
begin
  Result := ProcessGetPriority( PID );
end;

function TPGProcess.Kill( PID: Cardinal ): Boolean;
begin
  Result := ProcessKill( PID );
end;

function TPGProcess.SetPriority( PID: Cardinal; Priority: Byte ): Boolean;
begin
  Result := ProcessSetPriority( PID, Priority );
end;

initialization

TPGProcess.Create( GlobalItemCommand );

finalization

end.
