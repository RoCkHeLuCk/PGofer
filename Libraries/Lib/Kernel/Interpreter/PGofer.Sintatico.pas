unit PGofer.Sintatico;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,

  PGofer.Core, PGofer.Classes, PGofer.Lexico;

type
  TPGPilha = class( TPGItem )
    constructor Create( AItemDad: TPGItem );
    destructor Destroy( ); override;
  private
    FPilha: TStack<Variant>;
  public
    procedure Empilhar( AValue: Variant );
    function Desempilhar( ADefault: Variant ): Variant;
  end;

  TGramatica = class( TThread )
  private
    FErro: Boolean;
    FConsoleShowMessage: Boolean;
    FPai: TPGItem;
    FLocal: TPGItem;
    FPilha: TPGPilha;
    FScript: string;
    FTokenList: TTokenList;
  protected
    procedure Execute; override;
  public
    constructor Create( AName: string; AItemDad: TPGItem;
      ATerminate: Boolean ); overload;
    destructor Destroy( ); override;
    property Pilha: TPGPilha read FPilha;
    property local: TPGItem read FLocal;
    property TokenList: TTokenList read FTokenList;
    property Erro: Boolean read FErro write FErro;
    property Script: string read FScript;
    procedure ErroAdd( AText: string );
    procedure MSGsAdd( AText: string );
    procedure SetScript( AScript: string );
    procedure SetTokens( TokenList: TTokenList );
  end;

procedure ScriptExec( AName, AScript: string; ANivel: TPGItem = nil;
  AWaitFor: Boolean = False );
function FileScriptExec( FileName: string; Esperar: Boolean ): Boolean;

implementation

uses
  PGofer.Language, PGofer.Sintatico.Controls, PGofer.Runtime;

{ TPilha }

constructor TPGPilha.Create( AItemDad: TPGItem );
begin
  inherited Create( AItemDad, '$Stack' );
  FPilha := TStack<Variant>.Create;
end;

destructor TPGPilha.Destroy( );
begin
  FPilha.Free;
  FPilha := nil;
  inherited Destroy( );
end;

procedure TPGPilha.Empilhar( AValue: Variant );
begin
  FPilha.Push( AValue );
end;

function TPGPilha.Desempilhar( ADefault: Variant ): Variant;
begin
  if FPilha.Count > 0 then
  begin
    Result := FPilha.Pop;
  end
  else
    Result := ADefault;
end;

{ Gramatica }

constructor TGramatica.Create( AName: string; AItemDad: TPGItem;
  ATerminate: Boolean );
begin
  inherited Create( True );
  Self.FreeOnTerminate := ATerminate;
  Self.Priority := tpNormal;
  FConsoleShowMessage := TPGKernel.GetVar('ConsoleMessage',True);
  FPai := AItemDad;
  if Assigned( FPai ) then
    FLocal := TPGFolder.Create( AItemDad, AName )
  else
    FLocal := TPGFolder.Create( GlobalCollection, AName );

  FPilha := TPGPilha.Create( FLocal );
  FErro := False;
  FScript := '';
end;

destructor TGramatica.Destroy( );
begin
  if TPGKernel.GetVar('ReportMemoryLeaks',False) then
  begin
    if FPilha.Count > 1 then
       MSGsAdd( Tr('Warning_Interpreter_Stack', [FPilha.name, FPilha.Count-1]) );
    if FLocal.Count > 1 then
       MSGsAdd( Tr('Warning_Interpreter_StackChild', [FLocal.name, FLocal.Count-1]) );
  end;

  FPilha.Free;
  FPilha := nil;
  FLocal.Free;
  FLocal := nil;
  FPai := nil;
  FConsoleShowMessage := False;
  FTokenList.Free;
  FTokenList := nil;
  FErro := False;
  FScript := '';
  inherited Destroy( );
end;

procedure TGramatica.ErroAdd( AText: string );
var
  LexicoName: string;
begin
  FErro := True;
  LexicoName := string( Self.TokenList.Token.Lexema );
  if LexicoName = #0 then
    LexicoName := ''
  else
    LexicoName := '"' + LexicoName + '" ';

    TrC( FLocal.name + ' [' +
      Self.TokenList.Token.Cordenada.ToString + '] ' + LexicoName + ': ' +
      AText, True, FConsoleShowMessage );
end;

procedure TGramatica.MSGsAdd( AText: string );
begin
    TrC( AText, True, FConsoleShowMessage );
end;

procedure TGramatica.SetScript( AScript: string );
var
  Automato: TAutomato;
begin
  FScript := AScript;
  Automato := TAutomato.Create( );
  FTokenList := Automato.TokenListCreate( FScript );
  Automato.Free;
end;

procedure TGramatica.SetTokens( TokenList: TTokenList );
begin
  FTokenList := TTokenList.Create( );
  FTokenList.Assign( TokenList );
end;

procedure TGramatica.Execute( );
var
  Dir: String;
begin
  Dir := TPGKernel.GetVar('_PathCurrent','');
  SetCurrentDir( Dir );
  ChDir( Dir );
  Sentencas( Self );
end;

procedure ScriptExec( AName, AScript: string; ANivel: TPGItem = nil;
  AWaitFor: Boolean = False );
var
  Gramatica: TGramatica;
begin
  if not Assigned( ANivel ) then
    ANivel := GlobalCollection;

  Gramatica := TGramatica.Create( AName, ANivel, not AWaitFor );
  Gramatica.SetScript( AScript );
  Gramatica.Start;
  if AWaitFor then
  begin
    Gramatica.WaitFor( );
    Gramatica.Free( );
  end;
end;

function FileScriptExec( FileName: string; Esperar: Boolean ): Boolean;
var
  Texto: TStringList;
begin
  if FileExists( FileName ) then
  begin
    Texto := TStringList.Create;
    Texto.LoadFromFile( FileName );
    ScriptExec( 'FileScript: ' + ExtractFileName( FileName ), Texto.Text, nil,
      Esperar );
    Texto.Free;
    Result := True;
  end
  else
    Result := False;
end;

initialization

finalization

end.
