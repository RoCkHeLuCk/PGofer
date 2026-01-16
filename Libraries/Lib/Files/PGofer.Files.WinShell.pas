unit PGofer.Files.WinShell;

interface

uses
  SysUtils, Windows, ActiveX, ShlObj;

type
  EShellOleError = class( Exception );

  TShellLinkInfo = record
    PathName: string;
    Arguments: string;
    Description: string;
    WorkingDirectory: string;
    IconLocation: string;
    IconIndex: integer;
    ShowCmd: integer;
    HotKey: word;
  end;

  TSpecialFolderInfo = record
    Name: string;
    ID: integer;
  end;

const
  SpecialFolders: array [ 0 .. 29 ] of TSpecialFolderInfo =
    ( ( name: 'Alt Startup'; ID: CSIDL_ALTSTARTUP ), ( name: 'Application Data';
    ID: CSIDL_APPDATA ), ( name: 'Recycle Bin'; ID: CSIDL_BITBUCKET ),
    ( name: 'Common Alt Startup'; ID: CSIDL_COMMON_ALTSTARTUP ),
    ( name: 'Common Desktop'; ID: CSIDL_COMMON_DESKTOPDIRECTORY ),
    ( name: 'Common Favorites'; ID: CSIDL_COMMON_FAVORITES ),
    ( name: 'Common Programs'; ID: CSIDL_COMMON_PROGRAMS ),
    ( name: 'Common Start Menu'; ID: CSIDL_COMMON_STARTMENU ),
    ( name: 'Common Startup'; ID: CSIDL_COMMON_STARTUP ), ( name: 'Controls';
    ID: CSIDL_CONTROLS ), ( name: 'Cookies'; ID: CSIDL_COOKIES ),
    ( name: 'Desktop'; ID: CSIDL_DESKTOP ), ( name: 'Desktop Directory';
    ID: CSIDL_DESKTOPDIRECTORY ), ( name: 'Drives'; ID: CSIDL_DRIVES ),
    ( name: 'Favorites'; ID: CSIDL_FAVORITES ), ( name: 'Fonts';
    ID: CSIDL_FONTS ), ( name: 'History'; ID: CSIDL_HISTORY ),
    ( name: 'Internet'; ID: CSIDL_INTERNET ), ( name: 'Internet Cache';
    ID: CSIDL_INTERNET_CACHE ), ( name: 'Network Neighborhood';
    ID: CSIDL_NETHOOD ), ( name: 'Network Top'; ID: CSIDL_NETWORK ),
    ( name: 'Personal'; ID: CSIDL_PERSONAL ), ( name: 'Printers';
    ID: CSIDL_PRINTERS ), ( name: 'Printer Links'; ID: CSIDL_PRINTHOOD ),
    ( name: 'Programs'; ID: CSIDL_PROGRAMS ), ( name: 'Recent Documents';
    ID: CSIDL_RECENT ), ( name: 'Send To'; ID: CSIDL_SENDTO ),
    ( name: 'Start Menu'; ID: CSIDL_STARTMENU ), ( name: 'Startup';
    ID: CSIDL_STARTUP ), ( name: 'Templates'; ID: CSIDL_TEMPLATES ) );

function CreateShellLink( const AppName, Desc: string; Dest: integer ): string;
function GetSpecialFolderPath( Folder: integer; CanCreate: Boolean ): string;
function GetShellLinkInfo( const LinkFile: WideString ): TShellLinkInfo;
procedure SetShellLinkInfo( const LinkFile: WideString;
  const SLI: TShellLinkInfo );

implementation

uses
  ComObj;

function GetSpecialFolderPath( Folder: integer; CanCreate: Boolean ): string;
var
  FilePath: array [ 0 .. MAX_PATH ] of char;
begin
  { Get path of selected location }
  SHGetSpecialFolderPathW( 0, FilePath, Folder, CanCreate );
  Result := FilePath;
end;

function CreateShellLink( const AppName, Desc: string; Dest: integer ): string;
{ Creates a shell link for application or document specified in }
{ AppName with description Desc. Link will be located in folder }
{ specified by Dest, which is one of the string constants shown }
{ at the top of this unit. Returns the full path name of the }
{ link file. }
var
  SL: IShellLink;
  PF: IPersistFile;
  LnkName: WideString;
begin
  OleCheck( CoCreateInstance( CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,
    IShellLink, SL ) );
  { The IShellLink implementer must also support the IPersistFile }
  { interface. Get an interface pointer to it. }
  PF := SL as IPersistFile;
  OleCheck( SL.SetPath( PChar( AppName ) ) ); // set link path to proper file
  if Desc <> '' then
    OleCheck( SL.SetDescription( PChar( Desc ) ) ); // set description
  { create a path location and filename for link file }
  LnkName := GetSpecialFolderPath( Dest, True ) + '\' +
    ChangeFileExt( AppName, 'lnk' );
  PF.Save( PWideChar( LnkName ), True ); // save link file
  Result := LnkName;
end;

function GetShellLinkInfo( const LinkFile: WideString ): TShellLinkInfo;
{ Retrieves information on an existing shell link }
var
  SL: IShellLink;
  PF: IPersistFile;
  FindData: TWin32FindData;
  AStr: array [ 0 .. MAX_PATH ] of char;
begin
  CoInitialize(SL);
  OleCheck( CoCreateInstance( CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,
    IShellLink, SL ) );
  { The IShellLink implementer must also support the IPersistFile }
  { interface. Get an interface pointer to it. }
  PF := SL as IPersistFile;
  { Load file into IPersistFile object }
  OleCheck( PF.Load( PWideChar( LinkFile ), STGM_READ ) );
  { Resolve the link by calling the Resolve interface function. }
  OleCheck( SL.Resolve( 0, SLR_ANY_MATCH or SLR_NO_UI ) );
  { Get all the info! }
  with Result do
  begin
    OleCheck( SL.GetPath( AStr, MAX_PATH, FindData, SLGP_RAWPATH ) );
    PathName := AStr;
    OleCheck( SL.GetArguments( AStr, MAX_PATH ) );
    Arguments := AStr;
    //OleCheck( SL.GetDescription( AStr, MAX_PATH ) );
    //Description := AStr;
    OleCheck( SL.GetWorkingDirectory( AStr, MAX_PATH ) );
    WorkingDirectory := AStr;
    //OleCheck( SL.GetIconLocation( AStr, MAX_PATH, IconIndex ) );
    //IconLocation := AStr;
    OleCheck( SL.GetShowCmd( ShowCmd ) );
    //OleCheck( SL.GetHotKey( HotKey ) );
  end;
end;

procedure SetShellLinkInfo( const LinkFile: WideString;
  const SLI: TShellLinkInfo );
{ Sets information for an existing shell link }
var
  SL: IShellLink;
  PF: IPersistFile;
begin
  OleCheck( CoCreateInstance( CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,
    IShellLink, SL ) );
  { The IShellLink implementer must also support the IPersistFile }
  { interface. Get an interface pointer to it. }
  PF := SL as IPersistFile;
  { Load file into IPersistFile object }
  OleCheck( PF.Load( PWideChar( LinkFile ), STGM_SHARE_DENY_WRITE ) );
  { Resolve the link by calling the Resolve interface function. }
  OleCheck( SL.Resolve( 0, SLR_ANY_MATCH or SLR_UPDATE or SLR_NO_UI ) );
  { Set all the info! }
  with SLI, SL do
  begin
    OleCheck( SetPath( PChar( PathName ) ) );
    OleCheck( SetArguments( PChar( Arguments ) ) );
    OleCheck( SetDescription( PChar( Description ) ) );
    OleCheck( SetWorkingDirectory( PChar( WorkingDirectory ) ) );
    OleCheck( SetIconLocation( PChar( IconLocation ), IconIndex ) );
    OleCheck( SetShowCmd( ShowCmd ) );
    OleCheck( SetHotKey( HotKey ) );
  end;
  PF.Save( PWideChar( LinkFile ), True ); // save file
end;

end.
