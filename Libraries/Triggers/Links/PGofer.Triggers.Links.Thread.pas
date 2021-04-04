unit PGofer.Triggers.Links.Thread;

interface

uses
  System.Classes,
  PGofer.Triggers.Links;

type
  TLinkThread = class( TThread )
  private
    FLink: TPGLink;
  protected
    procedure Execute; override;
  public
    constructor Create( ALink: TPGLink; ATerminate: Boolean ); overload;
    destructor Destroy( ); override;
  end;

implementation

uses
  WinApi.Windows,
  WinApi.ShellApi,
  Vcl.Forms,
  PGofer.Sintatico,
  PGofer.Files.Controls;

{ TLinkThread }

constructor TLinkThread.Create( ALink: TPGLink; ATerminate: Boolean );
begin
  inherited Create( True );
  Self.FreeOnTerminate := ATerminate;
  Self.Priority := tpIdle;
  FLink := ALink;
end;

destructor TLinkThread.Destroy( );
begin
  FLink := nil;
  inherited Destroy( );
end;

procedure TLinkThread.Execute( );
var
  ShellExecuteInfoW: TShellExecuteInfo;
begin
  FLink.CanExecute := True;
  if FLink.ScriptBefor <> '' then
    ScriptExec( 'Link Befor: ' + FLink.Name, FLink.ScriptBefor, nil, True );

  if FLink.CanExecute then
  begin
    FillChar( ShellExecuteInfoW, SizeOf( TShellExecuteInfoW ), #0 );

    ShellExecuteInfoW.cbSize := SizeOf( TShellExecuteInfoW );
    ShellExecuteInfoW.fMask := SEE_MASK_NOCLOSEPROCESS;
    ShellExecuteInfoW.Wnd := Application.Handle;
    ShellExecuteInfoW.lpVerb := GetOperationToStr( FLink.Operation );
    ShellExecuteInfoW.lpFile := PWideChar( FileExpandPath( FLink.FileName ) );
    ShellExecuteInfoW.lpParameters :=
       PWideChar( FileExpandPath( FLink.Parameter ) );
    ShellExecuteInfoW.lpDirectory :=
       PWideChar( FileExpandPath( FLink.Directory ) );
    ShellExecuteInfoW.nShow := FLink.State;

    ShellExecuteExW( @ShellExecuteInfoW );

    if ShellExecuteInfoW.hProcess <> INVALID_HANDLE_VALUE then
    begin
      SetPriorityClass( ShellExecuteInfoW.hProcess,
         GetProcessPri( FLink.Priority ) );
    end;

    Self.Synchronize(
      procedure
      begin
        ConsoleNotify( 'Link ' + FLink.Name + ' : ' +
           GetShellExMSGToStr( ShellExecuteInfoW.hInstApp ), ConsoleMessage );
      end );

    if ( FLink.ScriptAfter <> '' ) or ( not Self.FreeOnTerminate ) then
    begin
      while WaitForSingleObject( ShellExecuteInfoW.hProcess, 500 ) <>
         WAIT_OBJECT_0 do;
      ScriptExec( 'Link After: ' + FLink.Name, FLink.ScriptAfter, nil, True );
    end;

    CloseHandle( ShellExecuteInfoW.hProcess );
  end;
end;

end.
