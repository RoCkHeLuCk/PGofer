unit PGofer.Lexico;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Rtti, System.Character;

type
  { Enumeração dos Tipos de Tokens (Tokens Kinds) }
  TPGTokenKind = (
    tkUnknown, tkIdentifier, tkNumber, tkString, tkEOF,
    // Símbolos e Operadores
    tkDot, tkDotDot, tkComma, tkColon, tkSemiColon, tkLPar, tkRPar,
    tkLBrack, tkRBrack, tkAssign, tkEqual, tkNotEqual, tkGreater,
    tkLess, tkGreaterEqual, tkLessEqual, tkAdd, tkSub, tkMult, tkDiv,
    tkMod, tkNot, tkAnd, tkOr, tkXor, tkPower, tkRoot, tkTone,
    // Palavras Reservadas
    tkBegin, tkEnd, tkIf, tkThen, tkElse, tkFor, tkTo, tkDownTo,
    tkDo, tkWhile, tkRepeat, tkUntil, tkCase, tkOf, tkGlobal, tkNull,
    tkConst, tkVar, tkFunction
  );

  { Coordenada com suporte a Span para seleção no Editor }
  TPGCoordinate = record
  strict private
    FLine: Integer;
    FColumn: Integer;
    FOffset: Integer;
    FLength: Integer;
  public
    procedure Initialize;
    procedure IncLine;
    procedure IncCol(const AAmount: Integer = 1);
    function ToString: string;

    property Line: Integer read FLine;
    property Column: Integer read FColumn;
    property Offset: Integer read FOffset;
    property Length: Integer read FLength write FLength;
  end;

  { Classe de metadados para erros e autocomplete }
  TPGTokenInfo = record
    FKind: TPGTokenKind;
    FFriendlyName: string;
    FIsReserved: Boolean;
  public
    constructor Create( AKind: TPGTokenKind; AFriendlyName: string; AIsReserved: Boolean);
  end;

  { Registro Global de Vocabulário }
  TPGLexicalRegistry = class
  strict private
    class var FKeywords: TDictionary<string, TPGTokenKind>;
    class var FTokenInfos: TDictionary<TPGTokenKind, TPGTokenInfo>;
    class constructor Create;
    class destructor Destroy;
  public
    class function GetKind(const AIdentifier: string): TPGTokenKind;
    class function GetFriendlyName(const AKind: TPGTokenKind): string;
    class procedure RegisterKeyword(const AWord: string; const AKind: TPGTokenKind; const AFriendlyName: string);
    class property Keywords: TDictionary<string, TPGTokenKind> read FKeywords;
  end;

  { Representação de um Token individual }
  TPGToken = class
  strict private
    FKind: TPGTokenKind;
    FValue: TValue;
    FCoordinate: TPGCoordinate;
  protected
    procedure Update(const AKind: TPGTokenKind; const AValue: TValue);
  public
    constructor Create(const AKind: TPGTokenKind; const AValue: TValue; const ACoordinate: TPGCoordinate);
    destructor Destroy(); override;
    property Kind: TPGTokenKind read FKind;
    property Value: TValue read FValue;
    property Coordinate: TPGCoordinate read FCoordinate;
  end;

  { Lista de Tokens resultante da análise }
  TPGTokenList = class
  strict private
    FItems: TObjectList<TPGToken>;
    FPosition: Integer;
    function GetLast: TPGToken;
  private
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AKind: TPGTokenKind; const AValue: TValue; const ACoordinate: TPGCoordinate);
    procedure Clear;
    function Current: TPGToken;
    procedure Next;
    procedure Assign(ASource: TPGTokenList);
    property Last: TPGToken read GetLast;
    property Position: Integer read FPosition write FPosition;
    property Count: Integer read GetCount;
  end;

  { O Motor Léxico (Lexer) }
  TPGLexer = class
  strict private
    FScript: string;
    FCurrent: PChar;
    FStart: PChar;
    FCoordinate: TPGCoordinate;

    procedure SkipWhitespaceAndComments;
    function HandleIdentifier(const AList: TPGTokenList): Boolean;
    function HandleNumber(const AList: TPGTokenList): Boolean;
    function HandleString(const AList: TPGTokenList; const AQuote: Char): Boolean;
    function HandleSymbol(const AList: TPGTokenList): Boolean;

    function AtEnd: Boolean; inline;
    function Peek(const AOffset: Integer = 1): Char; inline;
    function Advance: Char; inline;
  public
    procedure Tokenize(const AScript: string; ATokenList: TPGTokenList);
  end;

implementation

uses
  PGofer.Math.Controls;

{ TPGCoordinate }

procedure TPGCoordinate.Initialize;
begin
  FLine := 1;
  FColumn := 1;
  FOffset := 0;
  FLength := 0;
end;

procedure TPGCoordinate.IncCol(const AAmount: Integer);
begin
  Inc(FColumn, AAmount);
  Inc(FOffset, AAmount);
end;

procedure TPGCoordinate.IncLine;
begin
  Inc(FLine);
  FColumn := 0;
end;

function TPGCoordinate.ToString: string;
begin
  Result := Format('%d:%d', [FLine, FColumn]);
end;

{ TPGLexicalRegistry }

class constructor TPGLexicalRegistry.Create;
begin
  FKeywords := TDictionary<string, TPGTokenKind>.Create();
  FTokenInfos := TDictionary<TPGTokenKind, TPGTokenInfo>.Create;

  // Registro de Palavras Reservadas e Nomes Amigáveis para Erros
  RegisterKeyword('and', tkAnd, 'and');
  RegisterKeyword('begin', tkBegin, 'begin');
  RegisterKeyword('case', tkCase, 'case');
  RegisterKeyword('const', tkConst, 'const');
  RegisterKeyword('do', tkDo, 'do');
  RegisterKeyword('downto', tkDownTo, 'downto');
  RegisterKeyword('else', tkElse, 'else');
  RegisterKeyword('end', tkEnd, 'end');
  RegisterKeyword('for', tkFor, 'for');
  RegisterKeyword('function', tkFunction, 'function');
  RegisterKeyword('global', tkGlobal, 'global');
  RegisterKeyword('if', tkIf, 'if');
  RegisterKeyword('mod', tkMod, 'mod');
  RegisterKeyword('not', tkNot, 'not');
  RegisterKeyword('null', tkNull, 'null');
  RegisterKeyword('of', tkOf, 'of');
  RegisterKeyword('or', tkOr, 'or');
  RegisterKeyword('repeat', tkRepeat, 'repeat');
  RegisterKeyword('then', tkThen, 'then');
  RegisterKeyword('to', tkTo, 'to');
  RegisterKeyword('until', tkUntil, 'until');
  RegisterKeyword('var', tkVar, 'var');
  RegisterKeyword('while', tkWhile, 'while');
  RegisterKeyword('xor', tkXor, 'xor');

  // Nomes Amigáveis para Símbolos (Melhora ErroAdd)
  FTokenInfos.AddOrSetValue(tkAssign, TPGTokenInfo.Create(tkAssign, ':=', False));
  FTokenInfos.AddOrSetValue(tkLPar, TPGTokenInfo.Create(tkLPar, '(', False));
  FTokenInfos.AddOrSetValue(tkRPar, TPGTokenInfo.Create(tkRPar, ')', False));
  FTokenInfos.AddOrSetValue(tkSemiColon, TPGTokenInfo.Create(tkSemiColon, ';', False));
end;

class destructor TPGLexicalRegistry.Destroy;
begin
  FKeywords.Free;
  FTokenInfos.Free;
end;

class procedure TPGLexicalRegistry.RegisterKeyword(const AWord: string; const AKind: TPGTokenKind; const AFriendlyName: string);
var
  LInfo: TPGTokenInfo;
begin
  FKeywords.Add(AWord, AKind);
  LInfo.FKind := AKind;
  LInfo.FFriendlyName := AFriendlyName;
  LInfo.FIsReserved := True;
  FTokenInfos.Add(AKind, LInfo);
end;

class function TPGLexicalRegistry.GetKind(const AIdentifier: string): TPGTokenKind;
begin
  if not FKeywords.TryGetValue(AIdentifier, Result) then
    Result := tkIdentifier;
end;

class function TPGLexicalRegistry.GetFriendlyName(const AKind: TPGTokenKind): string;
var
  LInfo: TPGTokenInfo;
begin
  if FTokenInfos.TryGetValue(AKind, LInfo) then
    Result := LInfo.FFriendlyName
  else
    Result := 'unknown';
end;

{ TPGToken }

constructor TPGToken.Create(const AKind: TPGTokenKind; const AValue: TValue; const ACoordinate: TPGCoordinate);
begin
  inherited Create;
  FKind := AKind;
  FValue := AValue;
  FCoordinate := ACoordinate;
end;

destructor TPGToken.Destroy;
begin
  FValue := TValue.Empty;
  inherited;
end;

procedure TPGToken.Update(const AKind: TPGTokenKind; const AValue: TValue);
begin
  FKind := AKind;
  FValue := AValue;
end;

{ TPGTokenList }

constructor TPGTokenList.Create;
begin
  FItems := TObjectList<TPGToken>.Create(True);
  FPosition := 0;
end;

destructor TPGTokenList.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPGTokenList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TPGTokenList.Add(const AKind: TPGTokenKind; const AValue: TValue; const ACoordinate: TPGCoordinate);
begin
  FItems.Add(TPGToken.Create(AKind, AValue, ACoordinate));
end;

function TPGTokenList.GetLast: TPGToken;
begin
  if FItems.Count > 0 then
    Result := FItems.Last
  else
    Result := nil;
end;

procedure TPGTokenList.Assign(ASource: TPGTokenList);
var
  LItem: TPGToken;
begin
  Self.Clear;
  for LItem in ASource.FItems do
    Self.Add(LItem.Kind, LItem.Value, LItem.Coordinate);
end;

procedure TPGTokenList.Clear;
begin
  FItems.Clear;
  FPosition := 0;
end;

function TPGTokenList.Current: TPGToken;
begin
  if (FPosition >= 0) and (FPosition < FItems.Count) then
    Result := FItems[FPosition]
  else if FItems.Count > 0 then
    Result := FItems.Last // Retorna o tkEOF que o Lexer sempre adiciona no fim
  else
    Result := nil;
end;

procedure TPGTokenList.Next;
begin
  Inc(FPosition);
end;

{ TPGLexer }

procedure TPGLexer.Tokenize(const AScript: string; ATokenList: TPGTokenList);
var
  LLast: TPGToken;
begin
  FScript := AScript;
  FCurrent := PChar(FScript);
  FCoordinate.Initialize;
  ATokenList.Clear;

  while not AtEnd do
  begin
    SkipWhitespaceAndComments;
    if AtEnd then Break;

    FStart := FCurrent;

    if FCurrent^.IsLetter or (FCurrent^ = '_') then
      HandleIdentifier(ATokenList)
    else if FCurrent^.IsDigit then
      HandleNumber(ATokenList)
    else if (FCurrent^ = #39) or (FCurrent^ = '"') then
      HandleString(ATokenList, FCurrent^)
    else if (FCurrent^ = '#') then
    begin
      Advance; // Pula o '#'
      HandleNumber(ATokenList); // Isso vai adicionar um tkNumber na lista
      LLast := ATokenList.Last;
      if Assigned(LLast) and (LLast.Kind = tkNumber) then
      begin
        // Converte o número (ex: 65) em caractere ('A') e muda o tipo do token
        LLast.Update(tkString, TValue.From<Char>(Char(LLast.Value.AsInteger)));
      end;
    end
    else
      HandleSymbol(ATokenList);
  end;

  ATokenList.Add(tkEOF, TValue.Empty, FCoordinate);
end;

procedure TPGLexer.SkipWhitespaceAndComments;
begin
  while not AtEnd do
  begin
    case FCurrent^ of
      #10: begin
             FCoordinate.IncLine;
             Advance; // Advance garante que o \n seja contado no Offset
           end;
      #1..#9, #11, #12, #13, #32: Advance;
      '{': begin
             while (not AtEnd) and (FCurrent^ <> '}') do
             begin
               if FCurrent^ = #10 then begin FCoordinate.IncLine; Advance; end
               else Advance;
             end;
             Advance; // Pula '}'
           end;
      '/': begin
             if Peek = '/' then
             begin
               while (not AtEnd) and (FCurrent^ <> #10) do Advance;
             end else Break;
           end;
    else
      Break;
    end;
  end;
end;

function TPGLexer.HandleIdentifier(const AList: TPGTokenList): Boolean;
var
  LText: string;
  LCoord: TPGCoordinate;
begin
  LCoord := FCoordinate;
  while (not AtEnd) and (FCurrent^.IsLetterOrDigit or (FCurrent^ = '_')) do
    Advance;

  LCoord.Length := FCurrent - FStart;
  SetString(LText, FStart, LCoord.Length);
  AList.Add(TPGLexicalRegistry.GetKind(LText), LText, LCoord);
  Result := True;
end;

function TPGLexer.HandleNumber(const AList: TPGTokenList): Boolean;
var
  LText: string;
  LValue: Extended;
  LCoord: TPGCoordinate;
  LIsHex, LIsBin: Boolean;
begin
  LCoord := FCoordinate;
  LIsHex := False;
  LIsBin := False;

  // Suporte a 0h (Hex) e 0b (Bin)
  if (FCurrent^ = '0') then
  begin
    if (Peek = 'h') or (Peek = 'H') then
    begin
      LIsHex := True;
      Advance; Advance; // Pula 0h
      FStart := FCurrent;
      while (not AtEnd) and CharInSet(FCurrent^,['0'..'9', 'A'..'F', 'a'..'f']) do Advance;
    end
    else if (Peek = 'b') or (Peek = 'B') then
    begin
      LIsBin := True;
      Advance; Advance; // Pula 0b
      FStart := FCurrent;
      while (not AtEnd) and CharInSet(FCurrent^,['0', '1']) do Advance;
    end;
  end;

  if (not LIsHex) and (not LIsBin) then
  begin
    while (not AtEnd) and (FCurrent^.IsDigit or (FCurrent^ = '.')) do Advance;

    // Científico (e-10)
    if (FCurrent^ = 'e') or (FCurrent^ = 'E') then
    begin
      Advance;
      if (FCurrent^ = '-') or (FCurrent^ = '+') then Advance;
      while (not AtEnd) and (FCurrent^.IsDigit) do Advance;
    end;
  end;

  SetString(LText, FStart, FCurrent - FStart);
  LCoord.Length := FCurrent - FStart;

  if LIsHex then
    LValue := StrToInt64('$' + LText)
  else if LIsBin then
    LValue := BinToInt(LText) // Função em Math.Controls
  else
  begin
    LValue := StrToFloat(LText);

    // Tratamento de Prefixos SI (y..Y)
    if (not AtEnd) and CharInSet(FCurrent^,['y','z','a','f','p','n','u','m','k','M','G','T','P','E','Z','Y']) then
    begin
      case FCurrent^ of
        'y': LValue := LValue * 1e-24; 'z': LValue := LValue * 1e-21;
        'a': LValue := LValue * 1e-18; 'f': LValue := LValue * 1e-15;
        'p': LValue := LValue * 1e-12; 'n': LValue := LValue * 1e-9;
        'u': LValue := LValue * 1e-6;  'm': LValue := LValue * 1e-3;
        'k': LValue := LValue * 1e3;   'M': LValue := LValue * 1e6;
        'G': LValue := LValue * 1e9;   'T': LValue := LValue * 1e12;
        'P': LValue := LValue * 1e15;  'E': LValue := LValue * 1e18;
        'Z': LValue := LValue * 1e21;  'Y': LValue := LValue * 1e24;
      end;
      Self.Advance;
    end;
  end;

  AList.Add(tkNumber, LValue, LCoord);
  Result := True;
end;

function TPGLexer.HandleString(const AList: TPGTokenList; const AQuote: Char): Boolean;
var
  LText: string;
  LCoord: TPGCoordinate;
begin
  LCoord := FCoordinate;
  Advance; // Aspa inicial
  FStart := FCurrent;
  while (not AtEnd) and (FCurrent^ <> AQuote) do
  begin
    if FCurrent^ = #10 then Inc(FCurrent) else Advance;
  end;
  SetString(LText, FStart, FCurrent - FStart);
  Advance; // Aspa final
  LCoord.Length := FCurrent - FStart;
  AList.Add(tkString, LText, LCoord);
  Result := True;
end;

function TPGLexer.HandleSymbol(const AList: TPGTokenList): Boolean;
var
  LKind: TPGTokenKind;
  LCoord: TPGCoordinate;
  LBegin: PChar;
begin
  LCoord := FCoordinate;
  LKind := tkUnknown;
  LBegin := FCurrent;

  case Advance of
    '.': if FCurrent^ = '.' then begin Advance; LKind := tkDotDot; end else LKind := tkDot;
    ',': LKind := tkComma;
    ';': LKind := tkSemiColon;
    '(': LKind := tkLPar;
    ')': LKind := tkRPar;
    '[': LKind := tkLBrack;
    ']': LKind := tkRBrack;
    '+': LKind := tkAdd;
    '-': LKind := tkSub;
    '*': if FCurrent^ = '*' then begin Advance; LKind := tkPower; end else LKind := tkMult;
    '/': LKind := tkDiv;
    '^': LKind := tkTone;
    '=': LKind := tkEqual;
    ':': if FCurrent^ = '=' then begin Advance; LKind := tkAssign; end else LKind := tkColon;
    '>': if FCurrent^ = '=' then begin Advance; LKind := tkGreaterEqual; end else LKind := tkGreater;
    '<': if FCurrent^ = '=' then begin Advance; LKind := tkLessEqual; end
         else if FCurrent^ = '>' then begin Advance; LKind := tkNotEqual; end
         else LKind := tkLess;
  end;

  LCoord.Length := FCurrent - LBegin;
  AList.Add(LKind, TValue.Empty, LCoord);
  Result := True;
end;

function TPGLexer.Advance: Char;
begin
  Result := FCurrent^;
  if Result <> #0 then
  begin
    Inc(FCurrent);
    FCoordinate.IncCol;
  end;
end;

function TPGLexer.Peek(const AOffset: Integer): Char;
begin
  Result := (FCurrent + AOffset)^;
end;

function TPGLexer.AtEnd: Boolean;
begin
  Result := FCurrent^ = #0;
end;

{ TPGTokenInfo }

constructor TPGTokenInfo.Create(AKind: TPGTokenKind; AFriendlyName: string; AIsReserved: Boolean);
begin
  Self.FKind := AKind;
  Self.FFriendlyName := AFriendlyName;
  Self.FIsReserved := AIsReserved;
end;

initialization

finalization

end.
