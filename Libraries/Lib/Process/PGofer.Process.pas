unit PGofer.Process;

interface

uses
  PGofer.Runtime;

type
  {$M+}
  TPGProcess = class( TPGItemCMD )
  private
  public
  published
    function FileToPID( FileName: string ): Cardinal;
    function PIDToFile( PID: Cardinal ): string;
    function GetPriority( PID: string ): Byte;
    function GetForeground( ): Cardinal;
    function GetFocusedControl( ) : Cardinal;
    function Kill( PID: string ): Boolean;
    function SetPriority( PID: string; Priority: Byte ): Boolean;
  end;
  {$TYPEINFO ON}

implementation

uses
  System.SysUtils,
  PGofer.Process.Controls;

{ TPGProcess }

function TPGProcess.FileToPID( FileName: string ): Cardinal;
begin
  Result := ProcessFileToPID( FileName );
end;

function TPGProcess.PIDToFile( PID: Cardinal ): string;
begin
  Result := ProcessPIDToFile( PID );
end;

function TPGProcess.GetForeground: Cardinal;
begin
  Result := ProcessGetForeground( );
end;

function TPGProcess.GetFocusedControl: Cardinal;
begin
    Result := ProcessGetFocusedControl( );
end;

function TPGProcess.GetPriority( PID: string ): Byte;
var
  iPID: Cardinal;
begin
  if TryStrToUInt( PID, iPID ) then
    Result := ProcessGetPriority( iPID )
  else
    Result := ProcessGetPriority( ProcessFileToPID( string( PID ) ) );
end;

function TPGProcess.Kill( PID: string ): Boolean;
var
  iPID: Cardinal;
begin
  if TryStrToUInt( PID, iPID ) then
    Result := ProcessKill( iPID )
  else
    Result := ProcessKill( ProcessFileToPID( string( PID ) ) );
end;

function TPGProcess.SetPriority( PID: string; Priority: Byte ): Boolean;
var
  iPID: Cardinal;
begin
  if TryStrToUInt( PID, iPID ) then
    Result := ProcessSetPriority( iPID, Priority )
  else
    Result := ProcessSetPriority( ProcessFileToPID( string( PID ) ), Priority );
end;

initialization

TPGProcess.Create( GlobalItemCommand );

finalization

end.
