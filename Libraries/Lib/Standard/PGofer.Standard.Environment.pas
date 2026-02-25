unit PGofer.Standard.Environment;

interface

uses
  PGofer.Core, PGofer.Classes, PGofer.Runtime;

type
  {$M+}
  TPGEnvironment = class( TPGItemClass )
  private
    function GetPathCurrent( ): string;
    function GetLoopLimite( ): UInt64;
    procedure SetLoopLimite( Value: UInt64 );
    function GetReplyFormat( ): string;
    procedure SetReplyFormat( Value: string );
    function GetReplyPrefix( ): Boolean;
    procedure SetReplyPrefix( Value: Boolean );
    function GetFileListMax( ): Cardinal;
    procedure SetFileListMax( Value: Cardinal );
    function GetLanguage():string;
    function GetReportMemoryLeaks: Boolean;
    procedure SetReportMemoryLeaks(const Value: Boolean);
  protected
  public
    class function IconIndex(): Integer; override;
  published
    function DateTimeNow( Format: string ): string;
    property PathCurrent: string read GetPathCurrent;
    property FileListMax: Cardinal read GetFileListMax write SetFileListMax;
    property LoopLimite: UInt64 read GetLoopLimite write SetLoopLimite;
    property ReplyFormat: string read GetReplyFormat write SetReplyFormat;
    property ReplyPrefix: Boolean read GetReplyPrefix write SetReplyPrefix;
    property Language:string read GetLanguage;
    property ReportMemoryLeaks: Boolean read GetReportMemoryLeaks write SetReportMemoryLeaks;
    procedure IconLoadFromPath(const ACurrentPath: string);
  end;
  {$TYPEINFO ON}

var
  PGEnvironment: TPGEnvironment;

implementation

uses
  WinApi.Windows,
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.Dialogs;

{ TPGEnvironment }

function TPGEnvironment.DateTimeNow( Format: string ): string;
begin
  Result := FormatDateTime( Format, Now );
end;

function TPGEnvironment.GetPathCurrent( ): string;
begin
  Result := TPGKernel.GetVar<String>('_PathCurrent');
end;

function TPGEnvironment.GetFileListMax( ): Cardinal;
begin
  Result := TPGKernel.GetVar<Cardinal>('FileListMax');
end;

class function TPGEnvironment.IconIndex( ): Integer;
begin
  Result := Ord(pgiEnvironment);
end;

function TPGEnvironment.GetLanguage( ): string;
begin
  Result := TPGKernel.Translate('Language');
end;

function TPGEnvironment.GetLoopLimite( ): UInt64;
begin
  Result := TPGKernel.GetVar<UInt64>('LoopLimite');
end;

function TPGEnvironment.GetReplyFormat( ): String;
begin
  Result := TPGKernel.GetVar<String>('ReplyFormat');
end;

function TPGEnvironment.GetReplyPrefix( ): Boolean;
begin
  Result := TPGKernel.GetVar<Boolean>('ReplyPrefix');
end;

function TPGEnvironment.GetReportMemoryLeaks: Boolean;
begin
  Result := TPGKernel.GetVar<Boolean>('ReportMemoryLeaks');
end;

procedure TPGEnvironment.IconLoadFromPath(const ACurrentPath: string);
begin
  TPGKernel.LoadIconFromPath(ACurrentPath);
end;

procedure TPGEnvironment.SetFileListMax( Value: Cardinal );
begin
  TPGKernel.SetVar('FileListMax', Value);
end;

procedure TPGEnvironment.SetLoopLimite( Value: UInt64 );
begin
  TPGKernel.SetVar('LoopLimite', Value);
end;

procedure TPGEnvironment.SetReplyFormat( Value: string );
begin
  TPGKernel.SetVar('ReplyFormat', Value);
end;

procedure TPGEnvironment.SetReplyPrefix( Value: Boolean );
begin
  TPGKernel.SetVar('ReplyPrefix', Value);
end;

procedure TPGEnvironment.SetReportMemoryLeaks(const Value: Boolean);
begin
  TPGKernel.SetVar('ReportMemoryLeaks', Value);
end;

initialization

  PGEnvironment := TPGEnvironment.Create( GlobalItemCommand );

finalization

  PGEnvironment := nil;

end.
