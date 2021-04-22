unit PGofer.Triggers.Links.Thread;

interface

uses
  System.Classes,
  PGofer.Triggers.Links;

type
  TLinkThread = class( TThread )
  private
    FLink: TPGLink;
    FParam: string;
    procedure PipeLines( );
    procedure ShellExec( );
  protected
    procedure Execute; override;
  public
    constructor Create( ALink: TPGLink; AParam: string;
       ATerminate: Boolean ); overload;
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

constructor TLinkThread.Create( ALink: TPGLink; AParam: string;
   ATerminate: Boolean );
begin
  inherited Create( True );
  Self.FreeOnTerminate := ATerminate;
  Self.Priority := tpIdle;
  FLink := ALink;
  FParam := AParam;
end;

destructor TLinkThread.Destroy( );
begin
  FLink := nil;
  inherited Destroy( );
end;

procedure TLinkThread.Execute( );
begin
  FLink.CanExecute := True;
  if FLink.ScriptBefor <> '' then
    ScriptExec( 'Link Befor: ' + FLink.Name, FLink.ScriptBefor, nil, True );

  if FLink.CanExecute then
  begin
    if FLink.CaptureMsg then
      PipeLines( )
    else
      ShellExec( );

    if ( FLink.ScriptAfter <> '' ) then
      ScriptExec( 'Link After: ' + FLink.Name, FLink.ScriptAfter, nil, True );
  end;
end;

{
  procedure TLinkThread.WritePipeLine( OutputPipe: THandle; InString: PWideChar );
  var
  byteswritten: DWord;
  begin
  InString := InString + #13#10;
  WriteFile(OutputPipe, Instring[1], Length(Instring), byteswritten, nil);
  end;

  function TLinkThread.ReadPipeLine( InputPipe: THandle;
  var BytesRem: integer ): string;
  var
  TextBuffer: array [ 1 .. 32767 ] of AnsiChar; // char;
  TextString: string;
  BytesRead: Cardinal;
  PipeSize: integer;
  begin
  Result := '';
  PipeSize := Length( TextBuffer );
  // check if there is something to read in pipe
  PeekNamedPipe( InputPipe, nil, PipeSize, @BytesRead, @PipeSize, @BytesRem );
  if BytesRead > 0 then
  begin
  ReadFile( InputPipe, TextBuffer, PipeSize, BytesRead, nil );
  // a requirement for Windows OS system components
  OemToChar( @TextBuffer, @TextBuffer );
  TextString := string( TextBuffer );
  SetLength( TextString, BytesRead );
  Result := TextString;
  end;
  end;
}

procedure TLinkThread.PipeLines( );
const
  CReadBuffer = 2400;
var
  SecurityAttribute: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  hRead: THandle;
  hWrite: THandle;
  pBuffer: PAnsiChar;
  dRead: DWord;
  dRunning: DWord;
begin
  SecurityAttribute.nLength := SizeOf( TSecurityAttributes );
  SecurityAttribute.bInheritHandle := True;
  SecurityAttribute.lpSecurityDescriptor := nil;

  if CreatePipe( hRead, hWrite, @SecurityAttribute, 0 ) then
  begin
    FillChar( StartupInfo, SizeOf( TStartupInfo ), #0 );
    StartupInfo.cb := SizeOf( TStartupInfo );
    StartupInfo.hStdInput := hRead;
    StartupInfo.hStdOutput := hWrite;
    StartupInfo.hStdError := hWrite;
    StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := FLink.State;
    StartupInfo.lpTitle := PWideChar( FLink.Name );

    ProcessInfo := default ( TProcessInformation );

    if CreateProcessW( PWideChar( FileExpandPath( FLink.FileName ) ),
       PWideChar( '"' + FileExpandPath( FLink.FileName ) + '" ' +
       FileExpandPath( FParam ) ), @SecurityAttribute, @SecurityAttribute, True,
       GetProcessPri( FLink.Priority ), nil,
       PWideChar( FileExpandPath( FLink.Directory ) ), StartupInfo, ProcessInfo )
    then
    begin
      pBuffer := AllocMem( CReadBuffer + 1 );

      repeat
        dRunning := WaitForSingleObject( ProcessInfo.hProcess, 100 );
        repeat
          dRead := 0;
          ReadFile( hRead, pBuffer[ 0 ], CReadBuffer, dRead, nil );
          pBuffer[ dRead ] := #0;

          OemToAnsi( pBuffer, pBuffer );

          Self.Synchronize(
            procedure
            begin
              ConsoleNotify( 'Link ' + FLink.Name + ' : ' + string( pBuffer ),
                 ConsoleMessage );
            end );
        until ( dRead < CReadBuffer );
      until ( dRunning <> WAIT_TIMEOUT );

      FreeMem( pBuffer );
      CloseHandle( ProcessInfo.hProcess );
      CloseHandle( ProcessInfo.hThread );
    end;

    CloseHandle( hRead );
    CloseHandle( hWrite );
  end;
end;

procedure TLinkThread.ShellExec( );
var
  ShellExecuteInfoW: TShellExecuteInfo;
begin
  FillChar( ShellExecuteInfoW, SizeOf( TShellExecuteInfoW ), #0 );

  ShellExecuteInfoW.cbSize := SizeOf( TShellExecuteInfoW );
  ShellExecuteInfoW.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfoW.Wnd := Application.Handle;
  ShellExecuteInfoW.lpVerb := GetOperationToStr( FLink.Operation );
  ShellExecuteInfoW.lpFile := PWideChar( FileExpandPath( FLink.FileName ) );
  ShellExecuteInfoW.lpParameters := PWideChar( FileExpandPath( FParam ) );
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
  end;

  CloseHandle( ShellExecuteInfoW.hProcess );
end;

end.
