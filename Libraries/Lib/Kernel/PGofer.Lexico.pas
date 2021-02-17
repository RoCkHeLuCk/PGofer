unit PGofer.Lexico;

interface

uses
    System.SysUtils, System.Generics.Collections;

const
    cIgnore  = [#9, #10, #11, #13, ' '];
    cNumeric = ['0' .. '9'];
    cBinary  = ['0', '1'];
    cHexadec = ['0' .. '9', 'A' .. 'F', 'a' .. 'f'];
    cPrefix = ['y', 'z', 'a', 'f', 'p', 'n', 'u', 'm', 'k', 'M', 'G', 'T', 'P',
        'E', 'Z', 'Y'];
    cAlphabet = ['A' .. 'Z', 'a' .. 'z', 'À' .. 'ÿ'];

type
    TLexicoClass = (cmdUnDeclar, cmdIgnore, cmdComment, cmdNumeric, cmdString,
        cmdStream, cmdDot, cmd2Dot, cmdDotComa, cmdComa, cmdEqual, cmdMore,
        cmdMinor, cmdAdd, cmdSub, cmdMult, cmdBar, cmdCtrBar, cmdLPar, cmdRPar,
        cmdLBrack, cmdRBrack, cmdExclam, cmdArroba, cmdSharp, cmdPercent,
        cmdTone, cmdAnd, cmdQuery, cmdPipe, cmdDolar, cmdAttrib, cmdMoreEqual,
        cmdMinorEqual, cmdDifferent, cmdDriver, cmdNetwork,

        cmdID,

        cmdRes_and, cmdRes_begin, cmdRes_case, cmdRes_do, cmdRes_downto,
        cmdRes_else, cmdRes_end, cmdRes_global, cmdRes_mod, cmdRes_not,
        cmdRes_null, cmdRes_of, cmdRes_or, cmdRes_root, cmdRes_then, cmdRes_to,
        cmdRes_until, cmdRes_xor, cmdEOF);

    TCordenada = record
    private
        FLinha: FixedInt;
        FColuna: FixedInt;
        procedure IncColuna();
        procedure IncLina();
        procedure Zero();
        function AsString(): string;
    public
        property Linha: FixedInt read FLinha;
        property Coluna: FixedInt read FColuna;
        property ToString: string read AsString;
    end;

    TToken = class
        constructor Create(Lexema: Variant; Classe: TLexicoClass;
            Cordenada: TCordenada);
        destructor Destroy(); override;
    private
        FLexema: Variant;
        FClasse: TLexicoClass;
        FCordenada: TCordenada;
        // FItem : TPGItem;
        // procedure SetItem(Item: TPGItem);
    public
        property Lexema: Variant read FLexema;
        property Classe: TLexicoClass read FClasse write FClasse;
        property Cordenada: TCordenada read FCordenada;
        // property Item : TPGItem read FItem write SetItem;
    end;

    TTokens = TObjectList<TToken>;

    TTokenList = class
        constructor Create();
        destructor Destroy(); override;
    private
        FTokenList: TTokens;
        FTokenPosition: FixedInt;
        function GetToken(): TToken;
    public
        property Token: TToken read GetToken;
        property Position: FixedInt read FTokenPosition write FTokenPosition;
        procedure Assign(TokenList: TTokenList);
        procedure TokenAdd(Lexema: Variant; Classe: TLexicoClass;
            Cordenada: TCordenada);
        procedure GetNextToken();
    end;

    TAutomato = class
        constructor Create();
        destructor Destroy(); override;
    private type
        TFita = record
        private
            FValor: String;
            FHigh: FixedInt;
            FPosição: FixedInt;
            FCabeça: Char;
            FCordenada: TCordenada;
        public
            procedure Create(Value: string);
            procedure Destroy();
            procedure Incrementa();
            property Cabeça: Char read FCabeça;
            property Cordenada: TCordenada read FCordenada;
        end;

        TLexema = record
            Lexema: Variant;
            Classe: TLexicoClass;
            Cordenada: TCordenada;
        end;

    var
        FFita: TFita;
        FLexema: TLexema;

        procedure IncCabeça(AddLexico: Boolean);
        function ReadCharInSet(Caracteres: TSysCharSet;
            AddLexico: Boolean): Boolean;
        function ReadCharOutSet(Caracteres: TSysCharSet;
            AddLexico: Boolean): Boolean;
        procedure Ignorados();
        procedure Comentario(Caracteres: TSysCharSet);
        procedure Caracter();
        procedure Numero();
        procedure Identificadores();
        procedure Texto();
        procedure Simbolos();
        procedure Fim();
    public
        function TokenListCreate(Algoritimo: String): TTokenList;
        function TokenListToStr( TokenList: TTokenList ) : String;
    end;

    function CreateCordenada(): TCordenada;

implementation

uses
    System.TypInfo, PGofer.Classes, PGofer.Math.Controls;

{ TCordenada }

function TCordenada.AsString: string;
begin
    result := Format('%d:%d', [FLinha, FColuna]);
end;

procedure TCordenada.IncColuna;
begin
    Inc(FColuna);
end;

procedure TCordenada.IncLina;
begin
    Inc(FLinha);
    FColuna := LowString;
end;

procedure TCordenada.Zero;
begin
    FLinha := LowString;
    FColuna := LowString;
end;

function CreateCordenada(): TCordenada;
begin
    result.Zero;
end;

{ TToken }

constructor TToken.Create(Lexema: Variant; Classe: TLexicoClass;
    Cordenada: TCordenada);
begin
    inherited Create();
    FLexema := Lexema;
    FClasse := Classe;
    FCordenada := Cordenada;
    // FItem := nil;
end;

destructor TToken.Destroy();
begin
    FLexema := '';
    FClasse := cmdUnDeclar;
    FCordenada.Zero;
    // FItem := nil;
    inherited Destroy();
end;

{
  procedure TToken.SetItem(Item: TPGItem);
  var
  ClassAux : String;
  Aux : FixedInt;
  begin
  FItem := Item;
  ClassAux := LowerCase(Item.ClassName);
  Delete(ClassAux,1,1);
  Aux := GetEnumValue(TypeInfo(TLexicoClass),'cmdId_'+ClassAux);
  if Aux = -1 then
  Self.FClasse := cmdID
  else
  Self.FClasse := TLexicoClass(Aux);
  end;
}
{ TTokenList }
constructor TTokenList.Create;
begin
    inherited Create;
    FTokenList := TTokens.Create(True);
    FTokenPosition := 0;
end;

destructor TTokenList.Destroy;
begin
    FreeAndNil(FTokenList);
    FTokenPosition := 0;
    inherited Destroy;
end;

procedure TTokenList.Assign(TokenList: TTokenList);
var
    c: FixedInt;
    TokenAux: TToken;
begin
    for c := 0 to TokenList.FTokenList.Count - 1 do
    begin
        TokenAux := TToken.Create(TokenList.FTokenList[c].Lexema,
            TokenList.FTokenList[c].Classe, TokenList.FTokenList[c].Cordenada);
        Self.FTokenList.Add(TokenAux);
    end;
    FTokenPosition := 0;
end;

procedure TTokenList.GetNextToken();
begin
    if FTokenPosition <= Self.FTokenList.Count then
        Inc(FTokenPosition);
end;

function TTokenList.GetToken: TToken;
begin
    if FTokenPosition < Self.FTokenList.Count then
        result := Self.FTokenList[FTokenPosition]
    else
        result := nil;
end;

procedure TTokenList.TokenAdd(Lexema: Variant; Classe: TLexicoClass;
    Cordenada: TCordenada);
begin
    Self.FTokenList.Add(TToken.Create(Lexema, Classe, Cordenada));
    if Classe = cmdUnDeclar then
        FTokenPosition := Self.FTokenList.Count - 1;
end;

{ TAutomato.TFita }

procedure TAutomato.TFita.Create(Value: string);
begin
    FValor := Value + #0;
    FHigh := High(Value);
    FPosição := Low(Value);
    FCordenada.Zero;
    FCabeça := FValor[FPosição];
end;

procedure TAutomato.TFita.Destroy();
begin
    FValor := #0;
    FHigh := 0;
    FPosição := 0;
    FCordenada.Zero;
    FCabeça := #0;
end;

procedure TAutomato.TFita.Incrementa();
begin
    if FCabeça = #13 then
        FCordenada.IncLina
    else
        FCordenada.IncColuna;

    Inc(FPosição);

    if FPosição <= FHigh then
        FCabeça := FValor[FPosição]
    else
        FCabeça := #0;
end;

{ TAutomato }

constructor TAutomato.Create();
begin
    inherited Create;
end;

destructor TAutomato.Destroy();
begin
    FFita.Destroy();
    FLexema.Lexema := '';
    FLexema.Classe := cmdUnDeclar;
    FLexema.Cordenada.Zero;
    inherited Destroy();
end;

procedure TAutomato.IncCabeça(AddLexico: Boolean);
begin
    if (AddLexico) then
        FLexema.Lexema := FLexema.Lexema + FFita.Cabeça;
    FFita.Incrementa;
end;

function TAutomato.ReadCharInSet(Caracteres: TSysCharSet;
    AddLexico: Boolean): Boolean;
begin
    result := (CharInSet(FFita.Cabeça, Caracteres));
    if result then
        IncCabeça(AddLexico);
end;

function TAutomato.ReadCharOutSet(Caracteres: TSysCharSet;
    AddLexico: Boolean): Boolean;
begin
    result := (not CharInSet(FFita.Cabeça, Caracteres));
    if result then
        IncCabeça(AddLexico);
end;

procedure TAutomato.Ignorados();
begin
    while ReadCharInSet(cIgnore, False) do;
    FLexema.Classe := cmdIgnore;
end;

procedure TAutomato.Comentario(Caracteres: TSysCharSet);
begin
    while ReadCharOutSet(Caracteres, False) do;
    IncCabeça(False);
    FLexema.Classe := cmdIgnore;
end;

procedure TAutomato.Caracter();
var
    Aux: Integer;
begin
    IncCabeça(False);
    while ReadCharInSet(cNumeric, True) do;
    if (FLexema.Lexema <> '') and (TryStrToInt(FLexema.Lexema, Aux)) then
    begin
        FLexema.Classe := cmdString;
        FLexema.Lexema := Char(Aux);
    end;
end;

procedure TAutomato.Numero();
var
    iAux: Int64;
    fAux: Extended;
begin
    // binario, Hexadec
    if (FFita.Cabeça = '0') then
    begin
        IncCabeça(True);

        case FFita.Cabeça of

            'B', 'b':
                begin
                    IncCabeça(False);
                    while ReadCharInSet(cBinary, True) do;
                    if (FLexema.Lexema <> '') and
                        (TryBinToInt64(FLexema.Lexema, iAux)) then
                    begin
                        FLexema.Lexema := iAux;
                        FLexema.Classe := cmdNumeric;
                    end;
                    Exit;
                end;

            'H', 'h':
                begin
                    IncCabeça(False);
                    FLexema.Lexema := '$';
                    while ReadCharInSet(cHexadec, True) do;
                    if (FLexema.Lexema <> '') and
                        (TryStrToInt64(FLexema.Lexema, iAux)) then
                    begin
                        FLexema.Lexema := iAux;
                        FLexema.Classe := cmdNumeric;
                    end;
                    Exit;
                end;

        end;
    end;

    // inteiro
    while ReadCharInSet(cNumeric, True) do;

    // float
    if ReadCharInSet(['.'], True) then
        while ReadCharInSet(cNumeric, True) do;

    // expereção
    if ReadCharInSet(['e'], True) then
    begin
        ReadCharInSet(['-'], True);
        while ReadCharInSet(cNumeric, True) do;
    end
    else
    begin
        // prefixo
        if CharInSet(FFita.Cabeça, cPrefix) then
        begin
            // verifica o caracter
            case FFita.Cabeça of
                'y':
                    FLexema.Lexema := FLexema.Lexema + 'e-24';
                'z':
                    FLexema.Lexema := FLexema.Lexema + 'e-21';
                'a':
                    FLexema.Lexema := FLexema.Lexema + 'e-18';
                'f':
                    FLexema.Lexema := FLexema.Lexema + 'e-15';
                'p':
                    FLexema.Lexema := FLexema.Lexema + 'e-12';
                'n':
                    FLexema.Lexema := FLexema.Lexema + 'e-9';
                'u':
                    FLexema.Lexema := FLexema.Lexema + 'e-6';
                'm':
                    FLexema.Lexema := FLexema.Lexema + 'e-3';
                // ' ' :
                'k':
                    FLexema.Lexema := FLexema.Lexema + 'e3';
                'M':
                    FLexema.Lexema := FLexema.Lexema + 'e6';
                'G':
                    FLexema.Lexema := FLexema.Lexema + 'e9';
                'T':
                    FLexema.Lexema := FLexema.Lexema + 'e12';
                'P':
                    FLexema.Lexema := FLexema.Lexema + 'e15';
                'E':
                    FLexema.Lexema := FLexema.Lexema + 'e18';
                'Z':
                    FLexema.Lexema := FLexema.Lexema + 'e21';
                'Y':
                    FLexema.Lexema := FLexema.Lexema + 'e24';
            end;
            IncCabeça(False);
        end;
    end;

    if (FLexema.Lexema <> '') and (TryStrToFloat(FLexema.Lexema, fAux)) then
    begin
        FLexema.Lexema := fAux;
        FLexema.Classe := cmdNumeric;
    end;
end;

procedure TAutomato.Identificadores();
var
    Aux: Integer;
    id: String;
begin
    IncCabeça(True);
    while ReadCharInSet(cNumeric + cAlphabet + ['_'], True) do;

    id := LowerCase(FLexema.Lexema);
    Aux := GetEnumValue(TypeInfo(TLexicoClass), 'cmdRes_' + id);
    if Aux = -1 then
        FLexema.Classe := cmdID
    else
        FLexema.Classe := TLexicoClass(Aux);
end;

procedure TAutomato.Texto();
var
    Caracter: Char;
begin
    Caracter := FFita.Cabeça;
    IncCabeça(False);
    while ReadCharOutSet([#0, #13, Caracter], True) do;
    FLexema.Classe := cmdString;
    IncCabeça(False);
end;

procedure TAutomato.Simbolos();
begin
    IncCabeça(True);

    if Length(FLexema.Lexema) > 0 then
        case String(FLexema.Lexema)[1] of

            '.':
                FLexema.Classe := cmdDot;

            ':':
                begin
                    if ReadCharInSet(['='], True) then
                        FLexema.Classe := cmdAttrib
                    else if ReadCharInSet(['\'], True) then
                        FLexema.Classe := cmdDriver
                    else
                        FLexema.Classe := cmd2Dot;
                end;

            ';':
                FLexema.Classe := cmdDotComa;

            ',':
                FLexema.Classe := cmdComa;

            '=':
                FLexema.Classe := cmdEqual;

            '>':
                begin
                    if ReadCharInSet(['='], True) then
                        FLexema.Classe := cmdMoreEqual
                    else
                        FLexema.Classe := cmdMore;
                end;

            '<':
                begin
                    if ReadCharInSet(['='], True) then
                        FLexema.Classe := cmdMinorEqual
                    else if ReadCharInSet(['>'], True) then
                        FLexema.Classe := cmdDifferent
                    else
                        FLexema.Classe := cmdMinor;
                end;

            '+':
                FLexema.Classe := cmdAdd;

            '-':
                FLexema.Classe := cmdSub;

            '*':
                FLexema.Classe := cmdMult;

            '/':
                begin
                    if ReadCharInSet(['/'], True) then
                        Comentario([#0,#13])
                    else
                        FLexema.Classe := cmdBar;
                end;

            '\':
                begin
                    if ReadCharInSet(['\'], True) then
                        FLexema.Classe := cmdNetwork
                    else
                        FLexema.Classe := cmdCtrBar;
                end;

            '(':
                FLexema.Classe := cmdLPar;

            ')':
                FLexema.Classe := cmdRPar;

            '[':
                FLexema.Classe := cmdLBrack;

            ']':
                FLexema.Classe := cmdRBrack;

            '!':
                FLexema.Classe := cmdExclam;

            '@':
                FLexema.Classe := cmdArroba;

            '%':
                FLexema.Classe := cmdPercent;

            '^':
                FLexema.Classe := cmdTone;

            '&':
                FLexema.Classe := cmdAnd;

            '?':
                FLexema.Classe := cmdQuery;

            '|':
                FLexema.Classe := cmdPipe;

            '$':
                FLexema.Classe := cmdDolar;
        else
            FLexema.Classe := cmdUnDeclar;
        end;
end;

procedure TAutomato.Fim();
begin
    IncCabeça(True);
    FLexema.Classe := cmdEOF;
end;

function TAutomato.TokenListCreate(Algoritimo: String): TTokenList;
begin
    FFita.Create(Algoritimo);
    result := TTokenList.Create();

    repeat
        FLexema.Lexema := '';
        FLexema.Classe := cmdUnDeclar;
        FLexema.Cordenada := FFita.Cordenada;

        case FFita.Cabeça of

            #0:
                Fim();

            #9, #10, #11, #13, ' ':
                Ignorados();

            '{':
                Comentario(['}']);

            '#':
                Caracter();

            '0' .. '9':
                Numero();

            'A' .. 'Z', 'a' .. 'z', 'À' .. 'ÿ':
                Identificadores();

            #39, '"':
                Texto();
        else
            Simbolos();
        end; // case

        if FLexema.Classe <> cmdIgnore then
            result.TokenAdd(FLexema.Lexema, FLexema.Classe, FLexema.Cordenada);

    until (FLexema.Classe in [cmdEOF, cmdUnDeclar]);
end;

function TAutomato.TokenListToStr(TokenList: TTokenList): String;
begin
    TokenList.Position := 0;
    repeat
        Result := Result + ' ' + String(TokenList.Token.Lexema);
        case TokenList.Token.Classe of
            cmdDotComa,
            cmdRes_begin,
            cmdRes_do,
            cmdRes_downto,
            cmdRes_else,
            cmdRes_end,
            cmdRes_then :
            begin
                Result := Result + #10#13;
            end;
        end;

        TokenList.GetNextToken;
    until TokenList.Token.Classe = cmdEOF;
end;

initialization
    FormatSettings.DecimalSeparator := '.';

finalization

end.
