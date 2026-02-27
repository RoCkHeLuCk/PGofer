unit PGofer.Standard.Environment;

interface

uses
  PGofer.Core, PGofer.Classes, PGofer.Runtime;

type
  {$M+}
  TPGEnvironment = class( TPGItemClass )
  private
    function GetPathCurrent( ): string;
    function GetLoopLimit( ): Cardinal;
    procedure SetLoopLimit( Value: Cardinal );
    function GetReplyFormat( ): string;
    procedure SetReplyFormat( Value: string );
    function GetReplyPrefix( ): Boolean;
    procedure SetReplyPrefix( Value: Boolean );
    function GetReportMemoryLeaks: Boolean;
    procedure SetReportMemoryLeaks(const Value: Boolean);
  protected
  public
  published
    function DateTimeNow( Format: string ): string;
    property PathCurrent: string read GetPathCurrent;
    property LoopLimit: Cardinal read GetLoopLimit write SetLoopLimit;
    property ReplyFormat: string read GetReplyFormat write SetReplyFormat;
    property ReplyPrefix: Boolean read GetReplyPrefix write SetReplyPrefix;
    property ReportMemoryLeaks: Boolean read GetReportMemoryLeaks write SetReportMemoryLeaks;
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
  Result := TPGKernel.PathCurrent;
end;

function TPGEnvironment.GetLoopLimit( ): Cardinal;
begin
  Result := TPGKernel.LoopLimit;
end;

function TPGEnvironment.GetReplyFormat( ): String;
begin
  Result := TPGKernel.ReplyFormat;
end;

function TPGEnvironment.GetReplyPrefix( ): Boolean;
begin
  Result := TPGKernel.ReplyPrefix;
end;

function TPGEnvironment.GetReportMemoryLeaks: Boolean;
begin
  Result := TPGKernel.ReportMemoryLeaks;
end;

procedure TPGEnvironment.SetLoopLimit( Value: Cardinal );
begin
  TPGKernel.LoopLimit := Value;
end;

procedure TPGEnvironment.SetReplyFormat( Value: string );
begin
  TPGKernel.ReplyFormat := Value;
end;

procedure TPGEnvironment.SetReplyPrefix( Value: Boolean );
begin
  TPGKernel.ReplyPrefix := Value;
end;

procedure TPGEnvironment.SetReportMemoryLeaks(const Value: Boolean);
begin
  TPGKernel.ReportMemoryLeaks := Value;
end;

initialization

  PGEnvironment := TPGEnvironment.Create( GlobalItemCommand );

finalization

  PGEnvironment := nil;

end.
