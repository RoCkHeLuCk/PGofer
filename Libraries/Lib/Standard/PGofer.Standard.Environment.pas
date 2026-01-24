unit PGofer.Standard.Environment;

interface

uses
  PGofer.Core, PGofer.Classes, PGofer.Runtime;

type
  {$M+}
  [TPGAttribIcon(pgiEnvironment)]
  TPGEnvironment = class( TPGItemCMD )
  private
    function GetCanClose( ): Boolean;
    procedure SetCanClose( Value: Boolean );
    function GetPathCurrent( ): string;
    function GetLoopLimite( ): Int64;
    procedure SetLoopLimite( Value: Int64 );
    function GetReplyFormat( ): string;
    procedure SetReplyFormat( Value: string );
    function GetReplyPrefix( ): Boolean;
    procedure SetReplyPrefix( Value: Boolean );
    function GetFileListMax( ): Cardinal;
    procedure SetFileListMax( Value: Cardinal );
    function GetLanguage():string;
    function GetReportMemoryLeaks: Boolean;
    procedure SetReportMemoryLeaks(const Value: Boolean);
  public
    constructor Create( AItemDad: TPGItem );
    destructor Destroy( ); override;
  published
    function DateTimeNow( Format: string ): string;
    property CanClose: Boolean read GetCanClose write SetCanClose;
    property PathCurrent: string read GetPathCurrent;
    property FileListMax: Cardinal read GetFileListMax write SetFileListMax;
    property LoopLimite: Int64 read GetLoopLimite write SetLoopLimite;
    property ReplyFormat: string read GetReplyFormat write SetReplyFormat;
    property ReplyPrefix: Boolean read GetReplyPrefix write SetReplyPrefix;
    property Language:string read GetLanguage;
    property ReportMemoryLeaks: Boolean read GetReportMemoryLeaks write SetReportMemoryLeaks;
    procedure IconLoadFromPath(const ACurrentPath: string);
  end;
  {$TYPEINFO ON}

implementation

uses
  WinApi.Windows,
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.Dialogs,
  PGofer.Language, PGofer.IconList;

{ TPGEnvironment }

constructor TPGEnvironment.Create( AItemDad: TPGItem );
begin
  inherited Create( AItemDad );
end;

destructor TPGEnvironment.Destroy;
begin
  inherited Destroy( );
end;

function TPGEnvironment.DateTimeNow( Format: string ): string;
begin
  Result := FormatDateTime( Format, Now );
end;

function TPGEnvironment.GetCanClose: Boolean;
begin
  Result := TPGKernel.GetVar('CanClose',True);
end;

function TPGEnvironment.GetPathCurrent: string;
begin
  Result := TPGKernel.GetVar('_PathCurrent','');
end;

function TPGEnvironment.GetFileListMax: Cardinal;
begin
  Result := TPGKernel.GetVar('FileListMax',0);
end;

function TPGEnvironment.GetLanguage: string;
begin
  Result := TPGLanguage.Language;
end;

function TPGEnvironment.GetLoopLimite: Int64;
begin
  Result := TPGKernel.GetVar('LoopLimite',0);
end;

function TPGEnvironment.GetReplyFormat: string;
begin
  Result := TPGKernel.GetVar('ReplyFormat','');
end;

function TPGEnvironment.GetReplyPrefix: Boolean;
begin
  Result := TPGKernel.GetVar('ReplyPrefix',False);
end;

function TPGEnvironment.GetReportMemoryLeaks: Boolean;
begin
  Result := TPGKernel.GetVar('ReportMemoryLeaks',False);
end;

procedure TPGEnvironment.IconLoadFromPath(const ACurrentPath: string);
begin
  TPGIconList.LoadIconFromPath(ACurrentPath);
end;

procedure TPGEnvironment.SetCanClose( Value: Boolean );
begin
  TPGKernel.SetVar('CanClose', Value);
end;

procedure TPGEnvironment.SetFileListMax( Value: Cardinal );
begin
  TPGKernel.SetVar('FileListMax', Value);
end;

procedure TPGEnvironment.SetLoopLimite( Value: Int64 );
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

TPGEnvironment.Create( GlobalItemCommand );

finalization

end.
