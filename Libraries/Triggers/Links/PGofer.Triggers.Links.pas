unit PGofer.Triggers.Links;

interface

uses
  System.Classes,
  PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes,
  PGofer.Triggers;

type
  {$M+}
  TPGLink = class( TPGItemTrigger )
  private
    FFile: string;
    FParameter: string;
    FDirectory: string;
    FScriptBefor: TStrings;
    FScriptAfter: TStrings;
    FState: Byte;
    FPriority: Byte;
    FRunAdmin: Boolean;
    FCaptureMsg: Boolean;
    FCanExecute: Boolean;
    class var FImageIndex: Integer;
    function GetDirExist( ): Boolean;
    function GetFileExist( ): Boolean;
    function GetFileRepeat( ): Boolean;
    function GetScriptAfter: string;
    function GetScriptBefor: string;
    procedure SetScriptAfter( AValue: string );
    procedure SetScriptBefor( AValue: string );
    procedure ThreadExecute( AWaitFor: Boolean; AParam: string );
    function GetIsRunning: Boolean;
  protected
    procedure ExecutarNivel1( Gramatica: TGramatica ); override;
    function GetIsValid( ): Boolean; override;
    class function GetImageIndex( ): Integer; override;
  public
    constructor Create( AName: string; AMirror: TPGItemMirror );
    destructor Destroy( ); override;
    class var GlobList: TPGItem;
    procedure Frame( AParent: TObject ); override;
    procedure Triggering( ); override;
  published
    property FileName: string read FFile write FFile;
    property Parameter: string read FParameter write FParameter;
    property Directory: string read FDirectory write FDirectory;
    property State: Byte read FState write FState;
    property Priority: Byte read FPriority write FPriority;
    property RunAdmin: Boolean read FRunAdmin write FRunAdmin;
    property CaptureMsg: Boolean read FCaptureMsg write FCaptureMsg;
    property ScriptBefor: string read GetScriptBefor write SetScriptBefor;
    property ScriptAfter: string read GetScriptAfter write SetScriptAfter;
    property isFileExist: Boolean read GetFileExist;
    property isFileRepeat: Boolean read GetFileRepeat;
    property isDirExist: Boolean read GetDirExist;
    property CanExecute: Boolean read FCanExecute write FCanExecute;
    property isRunning: Boolean read GetIsRunning;
    procedure WaitFor( );
    function KillMe( ): Boolean;
  end;
  {$TYPEINFO ON}

  TPGLinkDeclare = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  published
    procedure Auto( ADir: string; AMask: string );
  end;

  TPGLinkMirror = class( TPGItemMirror )
  private
  protected
    class function GetImageIndex( ): Integer; override;
  public
    constructor Create( AItemDad: TPGItem; AName: string );
    procedure Frame( AParent: TObject ); override;
  end;

implementation

uses
  System.SysUtils,
  PGofer.Lexico,
  PGofer.Sintatico.Controls,
  PGofer.Key.Controls,
  PGofer.Files.Controls,
  PGofer.Files.WinShell,
  PGofer.Process.Controls,
  PGofer.Triggers.Links.Frame,
  PGofer.Triggers.Links.Thread,
  PGofer.ImageList;

{ TPGLinks }

constructor TPGLink.Create( AName: string; AMirror: TPGItemMirror );
begin
  inherited Create( TPGLink.GlobList, AName, AMirror );
  Self.ReadOnly := False;
  FFile := '';
  FParameter := '';
  FDirectory := '';
  FState := 1;
  FPriority := 2;
  FRunAdmin := False;
  FScriptBefor := TStringList.Create( );
  FScriptAfter := TStringList.Create( );
  FCanExecute := true;
end;

destructor TPGLink.Destroy( );
begin
  FFile := '';
  FParameter := '';
  FDirectory := '';
  FState := 1;
  FPriority := 2;
  FRunAdmin := False;
  FScriptBefor.Free( );
  FScriptAfter.Free( );
  FCanExecute := False;
  inherited Destroy( );
end;

procedure TPGLink.Frame( AParent: TObject );
begin
  inherited Frame( AParent );
  TPGLinkFrame.Create( Self, AParent );
end;

function TPGLink.GetDirExist: Boolean;
begin
  Result := DirectoryExists( FileExpandPath( FDirectory ) );
end;

function TPGLink.GetIsRunning( ): Boolean;
begin
  Result := ProcessFileToPID( ExtractFileName( FFile ) ) <> 0;
end;

function TPGLink.GetIsValid( ): Boolean;
begin
  Result := GetFileExist( );
end;

function TPGLink.GetFileExist( ): Boolean;
begin
  Result := FileExists( FileExpandPath( FFile ) );
end;

function TPGLink.GetFileRepeat( ): Boolean;
var
  Item: TPGItem;
  Text: string;
begin
  Result := False;
  Text := FileUnExpandPath( Self.FFile );
  for Item in TPGLink.GlobList do
  begin
    if SameText( FileUnExpandPath( TPGLink( Item ).FFile ), Text ) and
      SameText( TPGLink( Item ).FParameter, Self.FParameter ) and ( Item <> Self )
    then
    begin
      Result := true;
      Break;
    end;
  end;
end;

class function TPGLink.GetImageIndex( ): Integer;
begin
  Result := FImageIndex;
end;

function TPGLink.GetScriptAfter( ): string;
begin
  Result := FScriptAfter.Text;
end;

function TPGLink.GetScriptBefor( ): string;
begin
  Result := FScriptBefor.Text;
end;

function TPGLink.KillMe( ): Boolean;
begin
  Result := ProcessKill( ProcessFileToPID( ExtractFileName( FFile ) ) );
end;

procedure TPGLink.SetScriptAfter( AValue: string );
begin
  FScriptAfter.Text := AValue;
end;

procedure TPGLink.SetScriptBefor( AValue: string );
begin
  FScriptBefor.Text := AValue;
end;

procedure TPGLink.ThreadExecute( AWaitFor: Boolean; AParam: string );
var
  LinkThread: TLinkThread;
begin
  LinkThread := TLinkThread.Create( Self, AParam, not AWaitFor );
  LinkThread.Start;
  if AWaitFor then
  begin
    LinkThread.WaitFor( );
    LinkThread.Free( );
  end;
end;

procedure TPGLink.Triggering( );
begin
  Self.ThreadExecute( False, Self.FParameter );
end;

procedure TPGLink.WaitFor( );
begin
  Self.ThreadExecute( true, Self.FParameter );
end;

procedure TPGLink.ExecutarNivel1( Gramatica: TGramatica );
var
  VParam: string;
begin
  if Gramatica.TokenList.Token.Classe = cmdLPar then
  begin
    Gramatica.TokenList.GetNextToken;
    Expressao( Gramatica );
    if ( Gramatica.TokenList.Token.Classe = cmdRPar ) then
    begin
      VParam := Gramatica.Pilha.Desempilhar( '' );
      if not Gramatica.Erro then
        Self.ThreadExecute( False, VParam );

      Gramatica.TokenList.GetNextToken;
    end
    else
      Gramatica.ErroAdd( '")" Esperado.' )
  end else if not Gramatica.Erro then
    Self.ThreadExecute( False, Self.FParameter );
end;

{ TPGLinkDec }
procedure TPGLinkDeclare.Execute( Gramatica: TGramatica );
var
  Titulo: string;
  Quantidade: Byte;
  Id: TPGItem;
  Link: TPGLink;
begin
  Gramatica.TokenList.GetNextToken;
  if Gramatica.TokenList.Token.Classe = cmdDot then
  begin
    Gramatica.TokenList.GetNextToken;
    Self.RttiExecute( Gramatica, Self );
  end else begin
    Id := IdentificadorLocalizar( Gramatica );
    if ( not Assigned( Id ) ) or ( Id is TPGLink ) then
    begin
      Titulo := Gramatica.TokenList.Token.Lexema;
      Quantidade := LerParamentros( Gramatica, 1, 7 );
      if not Gramatica.Erro then
      begin
        if ( not Assigned( Id ) ) then
          Link := TPGLink.Create( Titulo, nil )
        else
          Link := TPGLink( Id );

        if Quantidade >= 8 then
          Link.ScriptAfter := Gramatica.Pilha.Desempilhar( 0 );

        if Quantidade >= 7 then
          Link.ScriptBefor := Gramatica.Pilha.Desempilhar( 0 );

        if Quantidade = 6 then
          Link.Priority := Gramatica.Pilha.Desempilhar( 3 );

        if Quantidade >= 5 then
          Link.RunAdmin := Gramatica.Pilha.Desempilhar( False );

        if Quantidade >= 4 then
          Link.State := Gramatica.Pilha.Desempilhar( 1 );

        if Quantidade >= 3 then
          Link.Directory := Gramatica.Pilha.Desempilhar( '' );

        if Quantidade >= 2 then
          Link.Parameter := Gramatica.Pilha.Desempilhar( '' );

        if Quantidade >= 1 then
          Link.FileName := Gramatica.Pilha.Desempilhar( '' );
      end;
    end
    else
      Gramatica.ErroAdd( 'Identificador esperado ou existente.' );
  end;
end;

procedure TPGLinkDeclare.Auto( ADir: string; AMask: string );
  procedure SearchFile( ASubDir: string );
  var
    SearchRec: TSearchRec;
    Link: TPGLink;
    Name, Ext: string;
    Shell: TShellLinkInfo;
    c: Integer;
  begin
    {$WARN SYMBOL_PLATFORM OFF}
    ASubDir := IncludeTrailingBackslash( ASubDir );
    {$WARN SYMBOL_PLATFORM ON}
    c := FindFirst( ASubDir + '*', faDirectory or faAnyFile, SearchRec );
    while ( c = 0 ) do
    begin
      if ( SearchRec.Attr and faDirectory ) = 0 then
      begin
        Ext := ExtractFileExt( SearchRec.Name );
        if pos( Ext, AMask ) > 0 then
        begin
          name := FileExtractOnlyFileName( SearchRec.Name );
          name := TPGItemMirror.TranscendName( name, nil );
          Link := TPGLink.Create( name, nil );

          if Ext = '.lnk' then
          begin
            Shell := GetShellLinkInfo( ASubDir + SearchRec.Name );
            Link.FFile := FileUnExpandPath( Shell.PathName );
            Link.FParameter := FileUnExpandPath( Shell.Arguments );
            Link.FDirectory := FileUnExpandPath( Shell.WorkingDirectory );
            Link.FState := Shell.ShowCmd;
          end else begin
            Link.FFile := FileUnExpandPath( ASubDir + SearchRec.Name );
          end;

          if ( not Link.isFileExist ) or ( Link.isFileRepeat ) then
            Link.Free;
        end;
      end else begin
        if ( SearchRec.Name <> '.' ) and ( SearchRec.Name <> '..' ) then
          SearchFile( ASubDir + SearchRec.Name + '\' );
      end;

      c := FindNext( SearchRec );
    end;
    FindClose( SearchRec );
  end;

begin
  SearchFile( FileExpandPath( ADir ) );
end;

{ TPGLinkMirror }
constructor TPGLinkMirror.Create( AItemDad: TPGItem; AName: string );
begin
  AName := TPGItemMirror.TranscendName( AName );
  inherited Create( AItemDad, TPGLink.Create( AName, Self ) );
  Self.ReadOnly := False;
end;

procedure TPGLinkMirror.Frame( AParent: TObject );
begin
  TPGLinkFrame.Create( Self.ItemOriginal, AParent );
end;

class function TPGLinkMirror.GetImageIndex: Integer;
begin
  Result := TPGLink.FImageIndex;
end;

initialization

TPGLinkDeclare.Create( GlobalItemCommand, 'Link' );
TPGLink.GlobList := TPGFolder.Create( GlobalCollection, 'Links' );

TriggersCollect.RegisterClass( 'Link', TPGLinkMirror );
TPGLink.FImageIndex := GlogalImageList.AddIcon( 'Link' );

finalization

end.
