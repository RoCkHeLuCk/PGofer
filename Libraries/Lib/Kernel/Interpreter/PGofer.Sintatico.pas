unit PGofer.Sintatico;

interface

uses
  System.Classes, System.Generics.Collections,
  PGofer.Classes, PGofer.Lexico;

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
    constructor Create( const AName: string; AItemDad: TPGItem; ATerminate: Boolean ); overload;
    destructor Destroy( ); override;
    property Pilha: TPGPilha read FPilha;
    property local: TPGItem read FLocal;
    property TokenList: TTokenList read FTokenList;
    property Erro: Boolean read FErro write FErro;
    property Script: string read FScript;
    procedure ErroAdd( const AValue: string ); overload;
    procedure ErroAdd( const AKey: string; const AArgs: array of const ); overload;
    procedure MSGsAdd( const AValue: string ); overload;
    procedure MSGsAdd( const AKey: string; const AArgs: array of const ); overload;
    procedure SetScript( const AScript: string );
    procedure SetTokens( TokenList: TTokenList );
  end;

implementation

uses
  System.SysUtils,
  PGofer.Core, PGofer.Sintatico.Controls, PGofer.Runtime;

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

constructor TGramatica.Create( const AName: string; AItemDad: TPGItem;
  ATerminate: Boolean );
begin
  inherited Create( True );
  Self.FreeOnTerminate := ATerminate;
  Self.Priority := tpNormal;
  FConsoleShowMessage := TPGKernel.ConsoleMessage;
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
  if TPGKernel.ReportMemoryLeaks then
  begin
    if FPilha.Count > 1 then
       MSGsAdd('Warning_Interpreter_Stack', [FPilha.name, FPilha.Count-1] );
    if FLocal.Count > 1 then
       MSGsAdd('Warning_Interpreter_StackChild', [FLocal.name, FLocal.Count-1] );
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

procedure TGramatica.ErroAdd( const AValue: string );
var
  LText, LLexicoName: string;
begin
  FErro := True;
  LLexicoName := string( Self.TokenList.Token.Lexema );
  if LLexicoName = #0 then
    LLexicoName := ''
  else
    LLexicoName := '"' + LLexicoName + '" ';

  LText := TPGKernel.Translate(AValue);

  TPGKernel.Console(
    FLocal.name +
    ' [' + Self.TokenList.Token.Cordenada.ToString + '] ' +
    LLexicoName + ': ' +
    LText,
    True,
    FConsoleShowMessage
  );
end;

procedure TGramatica.ErroAdd( const AKey: string; const AArgs: array of const );
var
  LText, LLexicoName: string;
begin
  FErro := True;
  LLexicoName := string( Self.TokenList.Token.Lexema );
  if LLexicoName = #0 then
    LLexicoName := ''
  else
    LLexicoName := '"' + LLexicoName + '" ';

  LText := TPGKernel.Translate(AKey, AArgs);

  TPGKernel.Console(
    FLocal.name +
    ' [' + Self.TokenList.Token.Cordenada.ToString + '] ' +
    LLexicoName + ': ' +
    LText,
    True,
    FConsoleShowMessage
  );
end;

procedure TGramatica.MSGsAdd( const AValue: string );
var
  AText : String;
begin
  AText := TPGKernel.Translate(AValue);
  TPGKernel.Console( AText, True, FConsoleShowMessage );
end;

procedure TGramatica.MSGsAdd( const AKey: string; const AArgs: array of const );
var
  AText : String;
begin
  AText := TPGKernel.Translate(AKey, AArgs);
  TPGKernel.Console( AText, True, FConsoleShowMessage );
end;

procedure TGramatica.SetScript( const AScript: string );
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
  Dir := TPGKernel.PathCurrent;
  SetCurrentDir( Dir );
  ChDir( Dir );
  Sentencas( Self );
end;

initialization

finalization

end.
