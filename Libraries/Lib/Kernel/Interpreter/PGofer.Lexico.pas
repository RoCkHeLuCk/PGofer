unit PGofer.Lexico;


interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults, System.Hash,
  System.Rtti, System.Character, System.TypInfo;

type
  { Enumeração dos Tipos de Tokens - Minimalista e focada em estrutura }
  TPGTokenKind = (
    pgkUnknown, pgkIdentifier, pgkKeyword, pgkNumber, pgkString, pgkEOF,
    // Símbolos e Operadores
    pgkDot, pgkDotDot, pgkComma, pgkColon, pgkSemiColon, pgkLPar, pgkRPar,
    pgkLBrack, pgkRBrack, pgkAssign, pgkEqual, pgkNotEqual, pgkGreater,
    pgkLess, pgkGreaterEqual, pgkLessEqual, pgkAdd, pgkSub, pgkMult, pgkDiv,
    pgkMod, pgkNot, pgkAnd, pgkOr, pgkXor, pgkPower, pgkRoot,
    // Delimitadores de Bloco
    pgkBegin, pgkEnd
  );

  TPGTokenKinds = set of TPGTokenKind;

  { Coordenada com suporte a Offset absoluto para o "Retrato" do script }
  TPGCoordinate = record
  private
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
    constructor Create(AKind: TPGTokenKind; AFriendlyName: string; AIsReserved: Boolean);
  end;

  { Registro Global de Vocabulário }
  TPGLexicalRegistry = class
  private
    class var FKeywords: TDictionary<string, TPGTokenKind>;
    class var FTokenInfos: TDictionary<TPGTokenKind, TPGTokenInfo>;
  public
    class function GetKind(const AIdentifier: string): TPGTokenKind;
    class function GetFriendlyName(const AKind: TPGTokenKind): string;
    class procedure RegisterKeyword(const AWord: string; const AKind: TPGTokenKind; const AFriendlyName: string);
    class property Keywords: TDictionary<string, TPGTokenKind> read FKeywords;
  end;

  { Representação de um Token individual }
  TPGToken = class
  private
    FKind: TPGTokenKind;
    FValue: TValue;
    FCoordinate: TPGCoordinate;
  public
    constructor Create(const AKind: TPGTokenKind; const AValue: TValue; const ACoordinate: TPGCoordinate);
    destructor Destroy; override;
    procedure Update(const AKind: TPGTokenKind; const AValue: TValue);

    property Kind: TPGTokenKind read FKind;
    property Value: TValue read FValue;
    property Coordinate: TPGCoordinate read FCoordinate;
  end;

  { Lista de Tokens }
  TPGTokenList = class
  private
    FItems: TObjectList<TPGToken>;
    FPosition: Integer;
    function GetLast: TPGToken;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AKind: TPGTokenKind; const AValue: TValue; const ACoordinate: TPGCoordinate);
    procedure Clear;
    function Current: TPGToken;
    function Peek(const AOffset: Integer = 1): TPGToken;
    procedure Next;
    procedure Assign(ASource: TPGTokenList);

    property Last: TPGToken read GetLast;
    property Position: Integer read FPosition write FPosition;
    property Count: Integer read GetCount;
    property Items: TObjectList<TPGToken> read FItems;
  end;

  { O Motor Léxico (Lexer) }
  TPGLexer = class
  private
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

  procedure Initialize();
  procedure Finalize();

implementation

uses
  PGofer.Math.Controls;

procedure Initialize();
begin
  TPGLexicalRegistry.FKeywords := TDictionary<string, TPGTokenKind>.Create(
    TEqualityComparer<string>.Construct(
      function(const L, R: string): Boolean
      begin
        Result := SameText(L, R);
      end,
      function(const V: string): Integer
      begin
        if V = '' then Exit(0);
        Result := THashBobJenkins.GetHashValue(Pointer(LowerCase(V))^, Length(V) * SizeOf(Char));
      end
    )
  );

  TPGLexicalRegistry.FTokenInfos := TDictionary<TPGTokenKind, TPGTokenInfo>.Create;

  // 1. Delimitadores de Bloco (Pilar Central)
  TPGLexicalRegistry.RegisterKeyword('begin', pgkBegin, 'begin');
  TPGLexicalRegistry.RegisterKeyword('end',   pgkEnd,   'end');
  TPGLexicalRegistry.RegisterKeyword('and',   pgkAnd,   'and');
  TPGLexicalRegistry.RegisterKeyword('or',    pgkOr,    'or');
  TPGLexicalRegistry.RegisterKeyword('xor',   pgkXor,   'xor');
  TPGLexicalRegistry.RegisterKeyword('not',   pgkNot,   'not');
  TPGLexicalRegistry.RegisterKeyword('mod',   pgkMod,   'mod');
  TPGLexicalRegistry.RegisterKeyword('root',  pgkRoot,  'root');

  // Registro de Símbolos para Erros Amigáveis
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkSemiColon,    TPGTokenInfo.Create(pgkSemiColon,    ';', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkLPar,         TPGTokenInfo.Create(pgkLPar,         '(', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkRPar,         TPGTokenInfo.Create(pgkRPar,         ')', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkLBrack,       TPGTokenInfo.Create(pgkLBrack,       '[', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkRBrack,       TPGTokenInfo.Create(pgkRBrack,       ']', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkAssign,       TPGTokenInfo.Create(pgkAssign,       ':=', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkDot,          TPGTokenInfo.Create(pgkDot,          '.', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkComma,        TPGTokenInfo.Create(pgkComma,        ',', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkEqual,        TPGTokenInfo.Create(pgkEqual,        '=', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkNotEqual,     TPGTokenInfo.Create(pgkNotEqual,     '<>', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkGreater,      TPGTokenInfo.Create(pgkGreater,      '>', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkLess,         TPGTokenInfo.Create(pgkLess,         '<', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkGreaterEqual, TPGTokenInfo.Create(pgkGreaterEqual, '>=', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkLessEqual,    TPGTokenInfo.Create(pgkLessEqual,    '<=', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkAdd,          TPGTokenInfo.Create(pgkAdd,          '+', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkSub,          TPGTokenInfo.Create(pgkSub,          '-', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkMult,         TPGTokenInfo.Create(pgkMult,         '*', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkDiv,          TPGTokenInfo.Create(pgkDiv,          '/', False));
  TPGLexicalRegistry.FTokenInfos.AddOrSetValue(pgkPower,        TPGTokenInfo.Create(pgkPower,        '^', False));
end;

procedure Finalize();
begin
  TPGLexicalRegistry.FKeywords.Free;
  TPGLexicalRegistry.FKeywords := nil;
  TPGLexicalRegistry.FTokenInfos.Free;
  TPGLexicalRegistry.FTokenInfos := nil;

  {$IFDEF DEBUG}
  {$ENDIF}
end;

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

{ TPGTokenInfo }

constructor TPGTokenInfo.Create(AKind: TPGTokenKind; AFriendlyName: string; AIsReserved: Boolean);
begin
  FKind := AKind;
  FFriendlyName := AFriendlyName;
  FIsReserved := AIsReserved;
end;

{ TPGLexicalRegistry }

class procedure TPGLexicalRegistry.RegisterKeyword(const AWord: string; const AKind: TPGTokenKind; const AFriendlyName: string);
begin
  FKeywords.AddOrSetValue(AWord, AKind);
  FTokenInfos.AddOrSetValue(AKind, TPGTokenInfo.Create(AKind, AFriendlyName, True));
end;

class function TPGLexicalRegistry.GetKind(const AIdentifier: string): TPGTokenKind;
begin
  if not FKeywords.TryGetValue(AIdentifier, Result) then
    Result := pgkIdentifier;
end;

class function TPGLexicalRegistry.GetFriendlyName(const AKind: TPGTokenKind): string;
var
  LInfo: TPGTokenInfo;
begin
  if FTokenInfos.TryGetValue(AKind, LInfo) then
    Result := LInfo.FFriendlyName
  else
    Result := GetEnumName(TypeInfo(TPGTokenKind), Ord(AKind));
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

procedure TPGTokenList.Add(const AKind: TPGTokenKind; const AValue: TValue; const ACoordinate: TPGCoordinate);
begin
  FItems.Add(TPGToken.Create(AKind, AValue, ACoordinate));
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
    Result := FItems.Last
  else
    Result := nil;
end;

function TPGTokenList.Peek(const AOffset: Integer = 1): TPGToken;
var
  LIndex: Integer;
begin
  LIndex := FPosition + AOffset;
  if (LIndex >= 0) and (LIndex < FItems.Count) then
    Result := FItems[LIndex]
  else if FItems.Count > 0 then
    Result := FItems.Last // Retorna tkEOF por segurança
  else
    Result := nil;
end;

function TPGTokenList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TPGTokenList.GetLast: TPGToken;
begin
  if FItems.Count > 0 then Result := FItems.Last else Result := nil;
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
      Advance;
      HandleNumber(ATokenList);
      LLast := ATokenList.Last;
      if Assigned(LLast) and (LLast.Kind = pgkNumber) then
        LLast.Update(pgkString, TValue.From<Char>(Char(LLast.Value.AsInteger)));
    end
    else
      HandleSymbol(ATokenList);
  end;

  FCoordinate.Length := 0;
  ATokenList.Add(pgkEOF, 'EOF', FCoordinate);
end;

procedure TPGLexer.SkipWhitespaceAndComments;
begin
  while not AtEnd do
  begin
    case FCurrent^ of
      #10: begin
             FCoordinate.IncLine;
             Advance;
           end;
      #1..#9, #11..#13, #32: Advance;
      '{': begin
             while (not AtEnd) and (FCurrent^ <> '}') do
             begin
               if FCurrent^ = #10 then
                 FCoordinate.IncLine;
               Advance;
             end;
             Advance;
           end;
      '/': begin
             if Peek = '/' then
               while (not AtEnd) and (FCurrent^ <> #10) do
                 Advance
             else
               Break;
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
  LIsHex := False; LIsBin := False;

  if (FCurrent^ = '0') then
  begin
    if (Peek = 'h') or (Peek = 'H') then
    begin
      LIsHex := True; Advance; Advance; FStart := FCurrent;
      while (not AtEnd) and CharInSet(FCurrent^, ['0'..'9', 'A'..'F', 'a'..'f']) do Advance;
    end
    else if (Peek = 'b') or (Peek = 'B') then
    begin
      LIsBin := True; Advance; Advance; FStart := FCurrent;
      while (not AtEnd) and CharInSet(FCurrent^, ['0', '1']) do Advance;
    end;
  end;

  if (not LIsHex) and (not LIsBin) then
  begin
    while (not AtEnd) and (FCurrent^.IsDigit or (FCurrent^ = '.')) do Advance;
    if (FCurrent^ = 'e') or (FCurrent^ = 'E') then
    begin
      Advance; if (FCurrent^ = '-') or (FCurrent^ = '+') then Advance;
      while (not AtEnd) and FCurrent^.IsDigit do Advance;
    end;
  end;

  LCoord.Length := FCurrent - FStart;
  SetString(LText, FStart, LCoord.Length);

  if LIsHex then LValue := StrToInt64('$' + LText)
  else if LIsBin then LValue := BinToInt(LText)
  else
  begin
    LValue := StrToFloat(LText);
    if (not AtEnd) and CharInSet(FCurrent^, ['y','z','a','f','p','n','u','m','k','M','G','T','P','E','Z','Y']) then
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
      Advance;
    end;
  end;

  AList.Add(pgkNumber, LValue, LCoord);
  Result := True;
end;

function TPGLexer.HandleString(const AList: TPGTokenList; const AQuote: Char): Boolean;
var
  LText: string;
  LCoord: TPGCoordinate;
begin
  LCoord := FCoordinate;
  Advance; FStart := FCurrent;
  while (not AtEnd) and (FCurrent^ <> AQuote) do
  begin
    if FCurrent^ = #10 then FCoordinate.IncLine;
    Advance;
  end;
  LCoord.Length := FCurrent - FStart;
  SetString(LText, FStart, LCoord.Length);
  Advance;
  LCoord.Length := LCoord.Length + 2; // Inclui aspas na coordenada
  AList.Add(pgkString, LText, LCoord);
  Result := True;
end;

function TPGLexer.HandleSymbol(const AList: TPGTokenList): Boolean;
var
  LKind: TPGTokenKind;
  LCoord: TPGCoordinate;
  LText: string;
begin
  LCoord := FCoordinate;
  LKind := pgkUnknown;

  case Advance of
    '.': if FCurrent^ = '.' then begin Advance; LKind := pgkDotDot; end else LKind := pgkDot;
    ',': LKind := pgkComma;
    ';': LKind := pgkSemiColon;
    '(': LKind := pgkLPar;
    ')': LKind := pgkRPar;
    '[': LKind := pgkLBrack;
    ']': LKind := pgkRBrack;
    '+': LKind := pgkAdd;
    '-': LKind := pgkSub;
    '*': if FCurrent^ = '*' then begin Advance; LKind := pgkPower; end else LKind := pgkMult;
    '/': LKind := pgkDiv;
    '^': LKind := pgkPower;
    '=': LKind := pgkEqual;
    ':': if FCurrent^ = '=' then begin Advance; LKind := pgkAssign; end else LKind := pgkColon;
    '>': if FCurrent^ = '=' then begin Advance; LKind := pgkGreaterEqual; end else LKind := pgkGreater;
    '<': if FCurrent^ = '=' then begin Advance; LKind := pgkLessEqual; end
         else if FCurrent^ = '>' then begin Advance; LKind := pgkNotEqual; end
         else LKind := pgkLess;
  end;

  LCoord.Length := FCurrent - FStart;
  SetString(LText, FStart, LCoord.Length);
  AList.Add(LKind, LText, LCoord);
  Result := True;
end;

function TPGLexer.Advance: Char;
begin
  Result := FCurrent^;
  if Result <> #0 then
  begin
    Inc(FCurrent);
    FCoordinate.IncCol(1);
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

initialization

finalization

end.

