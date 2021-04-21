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
    FOperation: Byte;
    FCaptureMsg: Boolean;
    FCanExecute: Boolean;
    class var FImageIndex: Integer;
    function GetDirExist( ): Boolean;
    function GetFileExist( ): Boolean;
    function GetScriptAfter: string;
    function GetScriptBefor: string;
    procedure SetScriptAfter( AValue: string );
    procedure SetScriptBefor( AValue: string );
    procedure ThreadExecute( AWaitFor: Boolean; AParam: string );
  protected
    procedure ExecutarNivel1( Gramatica: TGramatica ); override;
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
    property Operation: Byte read FOperation write FOperation;
    property CaptureMsg: Boolean read FCaptureMsg write FCaptureMsg;
    property ScriptBefor: string read GetScriptBefor write SetScriptBefor;
    property ScriptAfter: string read GetScriptAfter write SetScriptAfter;
    property isFileExist: Boolean read GetFileExist;
    property isDirExist: Boolean read GetDirExist;
    property CanExecute: Boolean read FCanExecute write FCanExecute;
    procedure WaitFor( );
  end;
{$TYPEINFO ON}

  TPGLinkDeclare = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
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
  PGofer.Files.Controls,
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
  FOperation := 0;
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
  FOperation := 0;
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

function TPGLink.GetFileExist: Boolean;
begin
  Result := FileExists( FileExpandPath( FFile ) );
end;

class function TPGLink.GetImageIndex: Integer;
begin
  Result := FImageIndex;
end;

function TPGLink.GetScriptAfter: string;
begin
  Result := FScriptAfter.Text;
end;

function TPGLink.GetScriptBefor: string;
begin
  Result := FScriptBefor.Text;
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
        Link.Operation := Gramatica.Pilha.Desempilhar( 0 );

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
