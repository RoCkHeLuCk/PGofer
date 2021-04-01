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
    FArquivo: string;
    FParametro: string;
    FDiretorio: string;
    FScriptIni: TStrings;
    FScriptEnd: TStrings;
    FEstado: Byte;
    FPrioridade: Byte;
    FOperation: Byte;
    FCanExecute: Boolean;
    class var FImageIndex: Integer;
    function GetDirExist( ): Boolean;
    function GetFileExist( ): Boolean;
    function GetScriptEnd: string;
    function GetScriptIni: string;
    procedure SetScriptEnd(const Value: string);
    procedure SetScriptIni(const Value: string);
  protected
    procedure ExecutarNivel1( Gramatica: TGramatica ); override;
    class function GetImageIndex( ): Integer; override;
  public
    constructor Create( Name: string; Mirror: TPGItemMirror );
    destructor Destroy( ); override;
    class var GlobList: TPGItem;
    procedure Frame( Parent: TObject ); override;
    procedure Triggering( ); override;
  published
    property Arquivo: string read FArquivo write FArquivo;
    property Parametro: string read FParametro write FParametro;
    property Diretorio: string read FDiretorio write FDiretorio;
    property Estado: Byte read FEstado write FEstado;
    property Prioridade: Byte read FPrioridade write FPrioridade;
    property Operation: Byte read FOperation write FOperation;
    property ScriptIni: string read GetScriptIni write SetScriptIni;
    property ScriptEnd: string read GetScriptEnd write SetScriptEnd;
    property isFileExist: Boolean read GetFileExist;
    property isDirExist: Boolean read GetDirExist;
    property CanExecute: Boolean write FCanExecute;
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
    constructor Create( ItemDad: TPGItem; AName: string );
    procedure Frame( Parent: TObject ); override;
  end;

implementation

uses
  System.SysUtils,
  WinApi.Windows,
  WinApi.ShellApi,
  Vcl.Forms,
  PGofer.Sintatico.Controls,
  PGofer.Files.Controls,
  PGofer.Triggers.Links.Frame,
  PGofer.ImageList;

{ TPGLinks }

constructor TPGLink.Create( Name: string; Mirror: TPGItemMirror );
begin
  inherited Create( TPGLink.GlobList, name, Mirror );
  Self.ReadOnly := False;
  FArquivo := '';
  FParametro := '';
  FDiretorio := '';
  FEstado := 1;
  FPrioridade := 3;
  FOperation := 0;
  FScriptIni := TStringList.Create();
  FScriptEnd := TStringList.Create();
  FCanExecute := true;
end;

destructor TPGLink.Destroy;
begin
  FArquivo := '';
  FParametro := '';
  FDiretorio := '';
  FEstado := 1;
  FPrioridade := 3;
  FOperation := 0;
  FScriptIni.Free();
  FScriptEnd.Free();
  FCanExecute := False;
  inherited;
end;

procedure TPGLink.Frame( Parent: TObject );
begin
  inherited Frame( Parent );
  TPGLinkFrame.Create( Self, Parent );
end;

function TPGLink.GetDirExist: Boolean;
begin
  Result := DirectoryExists( FileExpandPath( FDiretorio ) );
end;

function TPGLink.GetFileExist: Boolean;
begin
  Result := FileExists( FileExpandPath( FArquivo ) );
end;

class function TPGLink.GetImageIndex: Integer;
begin
  Result := FImageIndex;
end;

function TPGLink.GetScriptEnd: string;
begin
    Result := FScriptEnd.Text;
end;

function TPGLink.GetScriptIni: string;
begin
    Result := FScriptIni.Text;
end;

procedure TPGLink.SetScriptEnd(const Value: string);
begin
    FScriptEnd.Text := Value;
end;

procedure TPGLink.SetScriptIni(const Value: string);
begin
    FScriptIni.Text := Value;
end;

procedure TPGLink.Triggering( );
begin
  ScriptExec( 'Link: ' + Self.Name, Self.Name, nil, False );
end;

procedure TPGLink.ExecutarNivel1( Gramatica: TGramatica );
var
  ShellExecuteInfoW: TShellExecuteInfo;
begin
  Self.FCanExecute := true;
  if Self.ScriptIni <> '' then
    ScriptExec( 'Link ini: ' + Self.Name, Self.ScriptIni,
       Gramatica.Local, true );

  if Self.FCanExecute then
  begin
    FillChar( ShellExecuteInfoW, SizeOf( TShellExecuteInfoW ), #0 );

    ShellExecuteInfoW.cbSize := SizeOf( TShellExecuteInfoW );
    ShellExecuteInfoW.fMask := SEE_MASK_NOCLOSEPROCESS;
    ShellExecuteInfoW.Wnd := Application.Handle;
    ShellExecuteInfoW.lpVerb := GetOperationToStr( Self.Operation );
    ShellExecuteInfoW.lpFile := PWideChar( FileExpandPath( Self.Arquivo ) );
    ShellExecuteInfoW.lpParameters :=
       PWideChar( FileExpandPath( Self.Parametro ) );
    ShellExecuteInfoW.lpDirectory :=
       PWideChar( FileExpandPath( Self.Diretorio ) );
    ShellExecuteInfoW.nShow := Self.FEstado;

    ShellExecuteExW( @ShellExecuteInfoW );

    if ShellExecuteInfoW.hProcess <> INVALID_HANDLE_VALUE then
    begin
      SetPriorityClass( ShellExecuteInfoW.hProcess,
         GetProcessPri( Prioridade ) );
    end;
    Gramatica.MSGsAdd( GetShellExMSGToStr( ShellExecuteInfoW.hInstApp ) );

    while WaitForSingleObject( ShellExecuteInfoW.hProcess, 500 ) <>
       WAIT_OBJECT_0 do;

    CloseHandle( ShellExecuteInfoW.hProcess );

    if Self.ScriptEnd <> '' then
      ScriptExec( 'Link end: ' + Self.Name, Self.ScriptEnd,
         Gramatica.Local, true );
  end;
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
        Link.ScriptEnd := Gramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 7 then
        Link.ScriptIni := Gramatica.Pilha.Desempilhar( 0 );

      if Quantidade = 6 then
        Link.Prioridade := Gramatica.Pilha.Desempilhar( 3 );

      if Quantidade >= 5 then
        Link.Operation := Gramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 4 then
        Link.Estado := Gramatica.Pilha.Desempilhar( 1 );

      if Quantidade >= 3 then
        Link.Diretorio := Gramatica.Pilha.Desempilhar( '' );

      if Quantidade >= 2 then
        Link.Parametro := Gramatica.Pilha.Desempilhar( '' );

      if Quantidade >= 1 then
        Link.Arquivo := Gramatica.Pilha.Desempilhar( '' );
    end;
  end
  else
    Gramatica.ErroAdd( 'Identificador esperado ou existente.' );
end;

{ TPGLinkMirror }
constructor TPGLinkMirror.Create( ItemDad: TPGItem; AName: string );
begin
  AName := TPGItemMirror.TranscendName( AName );
  inherited Create( ItemDad, TPGLink.Create( AName, Self ) );
  Self.ReadOnly := False;
end;

procedure TPGLinkMirror.Frame( Parent: TObject );
begin
  TPGLinkFrame.Create( Self.ItemOriginal, Parent );
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
