unit PGofer.System;

interface

uses
  PGofer.Types, PGofer.Classes, PGofer.Sintatico.Classes;

type
  {$M+}
  [TPGAttribIcon(pgiSystem)]
  TPGSystem = class( TPGItemCMD )
  private
    FMouse: TPGItemCMD;
    function GetCanClose( ): Boolean;
    procedure SetCanClose( Value: Boolean );
    function GetDirCurrent( ): string;
    function GetLoopLimite( ): Int64;
    procedure SetLoopLimite( Value: Int64 );
    function GetCanOff( ): Boolean;
    procedure SetCanOff( Value: Boolean );
    function GetReplyFormat( ): string;
    procedure SetReplyFormat( Value: string );
    function GetReplyPrefix( ): Boolean;
    procedure SetReplyPrefix( Value: Boolean );
    function GetFileListMax( ): Cardinal;
    procedure SetFileListMax( Value: Cardinal );
  protected
  public
    constructor Create( AItemDad: TPGItem );
    destructor Destroy( ); override;
    property Mouse: TPGItemCMD read FMouse;
  published
    property CanClose: Boolean read GetCanClose write SetCanClose;
    property CanOff: Boolean read GetCanOff write SetCanOff;
    function DateTimeNow( Format: string ): string;
    procedure Delay( Valor: Cardinal );
    function DialogMessage( Text: string ): Boolean;
    property DirCurrent: string read GetDirCurrent;
    property FileListMax: Cardinal read GetFileListMax write SetFileListMax;
    function FindWindow( Valor: string ): NativeUInt;
    function GetTextFromPoint( ): string;
    function LockWorkStation( ): Boolean;
    property LoopLimite: Int64 read GetLoopLimite write SetLoopLimite;
    function MonitorPower( OnOff: Boolean ): NativeInt;
    function PrtScreen( Height, Width, Top, Left: Integer;
      FileName: string ): Integer;
    function SendMessage( ClassName: string; Mss: Cardinal;
      wPar, lPar: Integer ): Integer;
    function SetScreen( Height, Width, Monitor: Integer ): Boolean;
    function SetSuspendState( Enabled: Boolean ): Boolean;
    procedure ShowMessage( Texto: string );
    function ShutDown( Valor: Cardinal ): Boolean;
    property ReplyFormat: string read GetReplyFormat write SetReplyFormat;
    property ReplyPrefix: Boolean read GetReplyPrefix write SetReplyPrefix;
  end;
  {$TYPEINFO ON}

implementation

uses
  WinApi.Windows,
  System.SysUtils, System.Classes,
  Vcl.Forms,
  PGofer.Sintatico, PGofer.System.Controls,
  PGofer.System.Mouse;

{ TPGSystem }

constructor TPGSystem.Create( AItemDad: TPGItem );
begin
  inherited Create( AItemDad );
  FMouse := TPGMouse.Create( Self );
end;

destructor TPGSystem.Destroy;
begin
  FMouse.Free;
  inherited Destroy( );
end;

function TPGSystem.DateTimeNow( Format: string ): string;
begin
  Result := SystemGetDateTimeNow( Format );
end;

procedure TPGSystem.Delay( Valor: Cardinal );
begin
  Sleep( Valor );
end;

function TPGSystem.FindWindow( Valor: string ): NativeUInt;
begin
  Result := SystemGetFindWindow( Valor );
end;

function TPGSystem.GetCanClose: Boolean;
begin
  Result := PGofer.Sintatico.CanClose;
end;

function TPGSystem.GetCanOff: Boolean;
begin
  Result := PGofer.Sintatico.CanOff;
end;

function TPGSystem.GetDirCurrent: string;
begin
  Result := PGofer.Sintatico.DirCurrent;
end;

function TPGSystem.GetFileListMax: Cardinal;
begin
  Result := PGofer.Sintatico.FileListMax;
end;

function TPGSystem.GetLoopLimite: Int64;
begin
  Result := PGofer.Sintatico.LoopLimite;
end;

function TPGSystem.GetReplyFormat: string;
begin
  Result := PGofer.Sintatico.ReplyFormat;
end;

function TPGSystem.GetReplyPrefix: Boolean;
begin
  Result := PGofer.Sintatico.ReplyPrefix;
end;

function TPGSystem.GetTextFromPoint: string;
begin
  Result := PGofer.System.Controls.SystemGetWindowsTextFromPoint( );
end;

function TPGSystem.LockWorkStation: Boolean;
begin
  Result := WinApi.Windows.LockWorkStation( );
end;

function TPGSystem.MonitorPower( OnOff: Boolean ): NativeInt;
begin
  Result := PGofer.System.Controls.SystemMonitorPower( Enabled );
end;

function TPGSystem.PrtScreen( Height, Width, Top, Left: Integer;
  FileName: string ): Integer;
begin
  Result := PGofer.System.Controls.SystemPrtScreen( Height, Width, Top, Left,
    FileName );
end;

function TPGSystem.SendMessage( ClassName: string; Mss: Cardinal;
  wPar, lPar: Integer ): Integer;
begin
  Result := PGofer.System.Controls.SystemSetSendMessage( ClassName, Mss,
    wPar, lPar );
end;

procedure TPGSystem.SetCanClose( Value: Boolean );
begin
  PGofer.Sintatico.CanClose := Value;
end;

procedure TPGSystem.SetCanOff( Value: Boolean );
begin
  if Value then
  begin
    SetThreadExecutionState(ES_CONTINUOUS or ES_SYSTEM_REQUIRED or ES_AWAYMODE_REQUIRED);
  end else begin
    SetThreadExecutionState(ES_CONTINUOUS);
  end;
  PGofer.Sintatico.CanOff := Value;
end;

procedure TPGSystem.SetFileListMax( Value: Cardinal );
begin
  PGofer.Sintatico.FileListMax := Value;
end;

procedure TPGSystem.SetLoopLimite( Value: Int64 );
begin
  PGofer.Sintatico.LoopLimite := Value;
end;

procedure TPGSystem.SetReplyFormat( Value: string );
begin
  PGofer.Sintatico.ReplyFormat := Value;
end;

procedure TPGSystem.SetReplyPrefix( Value: Boolean );
begin
  PGofer.Sintatico.ReplyPrefix := Value;
end;

function TPGSystem.SetScreen( Height, Width, Monitor: Integer ): Boolean;
begin
  Result := PGofer.System.Controls.SystemSetScreen( Height, Width, Monitor );
end;

function TPGSystem.SetSuspendState( Enabled: Boolean ): Boolean;
begin
  setThreadExecutionState( ES_CONTINUOUS );
  Result := PGofer.System.Controls.SystemSetSuspendState( Enabled,
    True, False );
end;

function TPGSystem.DialogMessage( Text: string ): Boolean;
var
  R: Boolean;
begin
  TThread.Synchronize( nil, procedure
    begin
      R := PGofer.System.Controls.SystemDialogMessage( Text );
    end );
  Result := R;
end;

procedure TPGSystem.ShowMessage( Texto: string );
begin
  TThread.Synchronize( nil, procedure
    begin
      ShowMessage( Texto );
    end );
end;

function TPGSystem.ShutDown( Valor: Cardinal ): Boolean;
begin
  Result := PGofer.System.Controls.SystemShutDown( Valor );
end;

initialization

TPGSystem.Create( GlobalItemCommand );

finalization

end.
