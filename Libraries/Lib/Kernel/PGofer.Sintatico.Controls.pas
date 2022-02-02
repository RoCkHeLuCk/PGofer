unit PGofer.Sintatico.Controls;

interface

uses
  PGofer.Classes, PGofer.Lexico, PGofer.Sintatico;

// -------------------------------Estruturas-----------------------------------//
function LerParamentros( Gramatica: TGramatica;
  const QuantMin, QuantMax: Byte ): Byte;
procedure EncontrarFim( Gramatica: TGramatica; BeginEnd: Boolean;
  TokenList: TTokenList = nil );
// --------------------------------ATRIBUIÇÃO----------------------------------//
function AtribuicaoNivel1( Gramatica: TGramatica ): Boolean;
function Atribuicao( Gramatica: TGramatica; Valor: Variant ): Variant;
// --------------------------------SENTENCAS-----------------------------------//
procedure Sentencas( Gramatica: TGramatica );
procedure SentencasNivel1( Gramatica: TGramatica );
procedure Comandos( Gramatica: TGramatica );
procedure ComecoFinal( Gramatica: TGramatica );
procedure ValorFinal( Gramatica: TGramatica );
// --------------------------------EXPRESSAO-----------------------------------//
procedure Expressao( Gramatica: TGramatica );
procedure ExpressaoNivel1( Gramatica: TGramatica );
procedure ExpressaoNivel2( Gramatica: TGramatica );
procedure ExpressaoAddSub( Gramatica: TGramatica );
procedure ExpressaoMulDiv( Gramatica: TGramatica );
procedure ExpressaoPowSqt( Gramatica: TGramatica );
procedure ExpressaoFator( Gramatica: TGramatica );
// --------------------------------IDENTIFICADOR-------------------------------//
function FindID( AItem: TPGItem; AName: string ): TPGItem;
function IdentificadorLocalizar( Gramatica: TGramatica ): TPGItem;
procedure Identificador( Gramatica: TGramatica );

implementation

uses
  System.SysUtils,
  PGofer.Sintatico.Classes, PGofer.Math.Controls;

function LerParamentros( Gramatica: TGramatica;
  const QuantMin, QuantMax: Byte ): Byte;
var
  c: Byte;
begin
  Result := 0;
  Gramatica.TokenList.GetNextToken;
  if ( Gramatica.TokenList.Token.Classe = cmdLPar ) then
  begin
    Gramatica.TokenList.GetNextToken;
    c := 0;
    while ( c < QuantMax ) and ( Gramatica.TokenList.Token.Classe <> cmdRPar )
      and ( not Gramatica.Erro ) do
    begin
      Expressao( Gramatica );
      if ( Gramatica.TokenList.Token.Classe = cmdComa ) then
        Gramatica.TokenList.GetNextToken;
      inc( c );
    end;

    if ( c < QuantMin ) then
      Gramatica.ErroAdd( '"," Esperado.' )
    else
    begin
      if ( Gramatica.TokenList.Token.Classe <> cmdRPar ) then
        Gramatica.ErroAdd( '")" Esperado.' )
      else
      begin
        Gramatica.TokenList.GetNextToken;
        Result := c;
      end;
    end;
  end else begin
    if QuantMin <> 0 then
      Gramatica.ErroAdd( '"(" Esperado.' );
  end;
end;

procedure EncontrarFim( Gramatica: TGramatica; BeginEnd: Boolean;
  TokenList: TTokenList = nil );
var
  BeginCount: Word;
begin
  if ( BeginEnd ) then
  begin
    if ( Gramatica.TokenList.Token.Classe <> cmdRes_begin ) then
    begin
      Gramatica.ErroAdd( '"Begin" Esperado.' )
    end else begin
      BeginCount := 1;
      Gramatica.TokenList.GetNextToken;
      repeat

        case ( Gramatica.TokenList.Token.Classe ) of
          cmdRes_begin:
            inc( BeginCount );
          cmdRes_end:
            Dec( BeginCount );
        end;

        if ( BeginCount <> 0 ) then
        begin
          if Assigned( TokenList ) then
            TokenList.AssignToken( Gramatica.TokenList.Token );
          Gramatica.TokenList.GetNextToken;
        end;

      until ( Gramatica.TokenList.Token.Classe in [ cmdEOF, cmdRes_end ] ) and
        ( BeginCount = 0 );

      if ( Gramatica.TokenList.Token.Classe <> cmdRes_end ) then
        Gramatica.ErroAdd( '"End" Esperado.' )
      else
        Gramatica.TokenList.GetNextToken;
    end;
  end else begin
    while not( Gramatica.TokenList.Token.Classe in [ cmdEOF, cmdDotComa,
      cmdRes_else ] ) do
    begin
      if Assigned( TokenList ) then
        TokenList.AssignToken( Gramatica.TokenList.Token );
      Gramatica.TokenList.GetNextToken;
    end;
  end;

  if ( not Gramatica.Erro ) and Assigned( TokenList ) then
    TokenList.TokenAdd( '', cmdEOF, CreateCordenada( ) );
end;

// ----------------------------------------------------------------------------//
// -----------------------------ATRIBUIÇÃO-------------------------------------//
// ----------------------------------------------------------------------------//
function AtribuicaoNivel1( Gramatica: TGramatica ): Boolean;
begin
  if ( Gramatica.TokenList.Token.Classe = cmdAttrib ) then
  begin
    Gramatica.TokenList.GetNextToken;
    Expressao( Gramatica );
    Result := ( not Gramatica.Erro );
  end
  else
    Result := False;
end;

function Atribuicao( Gramatica: TGramatica; Valor: Variant ): Variant;
begin
  Gramatica.TokenList.GetNextToken;
  if AtribuicaoNivel1( Gramatica ) then
    Result := Gramatica.Pilha.Desempilhar( Valor )
  else
  begin
    Gramatica.Pilha.Empilhar( Valor );
    Result := Valor;
  end;
end;

// ----------------------------------------------------------------------------//
// -------------------------------SENTENCAS------------------------------------//
// ----------------------------------------------------------------------------//
procedure Sentencas( Gramatica: TGramatica );
begin
  if ( not Gramatica.Erro ) and ( Gramatica.TokenList.Token.Classe <> cmdEOF )
  then
  begin
    Comandos( Gramatica );
    SentencasNivel1( Gramatica );
  end;

  // tratamento de erros
  if ( not Gramatica.Erro ) then
    case Gramatica.TokenList.Token.Classe of
      cmdEOF:
        ;
      cmdUnDeclar:
        Gramatica.ErroAdd( 'Comando ou valor não reconhecido.' );
    end;
end;

procedure SentencasNivel1( Gramatica: TGramatica );
begin
  if ( not Gramatica.Erro ) and ( Gramatica.TokenList.Token.Classe = cmdDotComa )
  then
  begin
    Gramatica.TokenList.GetNextToken;
    if not( Gramatica.TokenList.Token.Classe in [ cmdEOF, cmdRes_end,
      cmdRes_until ] ) then
      Sentencas( Gramatica );
  end else begin
    if ( not Gramatica.Erro ) and ( Gramatica.TokenList.Token.Classe <> cmdEOF )
    then
      Gramatica.ErroAdd( '";" Esperado.' );
  end;
end;

// -------------------------------COMANDOS-------------------------------------//

procedure Comandos( Gramatica: TGramatica );
begin
  case Gramatica.TokenList.Token.Classe of

    cmdEqual, cmdAttrib:
      ValorFinal( Gramatica );

    cmdRes_begin:
      ComecoFinal( Gramatica ); // Begin End

    cmdID:
      Identificador( Gramatica );

  else
    Gramatica.ErroAdd( 'Extrutura não reconhecida.' );
  end;
end;

procedure ComecoFinal( Gramatica: TGramatica );
begin
  if not Gramatica.Erro then
  begin
    // se tiver um begin
    Gramatica.TokenList.GetNextToken;
    Sentencas( Gramatica );
    if not Gramatica.Erro then
    begin
      // espera um end.
      if Gramatica.TokenList.Token.Classe = cmdRes_end then
        Gramatica.TokenList.GetNextToken
      else
        Gramatica.ErroAdd( '"End" Esperado.' );
    end;
  end;
end;

procedure ValorFinal( Gramatica: TGramatica );
var
  Valor: string;
  Numero: Extended;
begin
  Gramatica.TokenList.GetNextToken;
  Expressao( Gramatica );
  if not Gramatica.Erro then
  begin
    Valor := Gramatica.Pilha.Desempilhar( '' );
    if TryStrToFloat( Valor, Numero ) then
      Gramatica.MSGsAdd( FormatConvert( PGofer.Sintatico.ReplyPrefix,
        PGofer.Sintatico.ReplyFormat, Numero ) )
    else
      Gramatica.MSGsAdd( Valor );
  end;
end;

// -------------------------------EXPRESSAO------------------------------------//

procedure Expressao( Gramatica: TGramatica );
begin
  if ( not Gramatica.Erro ) then
  begin
    ExpressaoNivel1( Gramatica );
    ExpressaoAddSub( Gramatica );
  end;
end;

procedure ExpressaoNivel1( Gramatica: TGramatica );
begin
  ExpressaoNivel2( Gramatica );
  ExpressaoMulDiv( Gramatica );
end;

procedure ExpressaoNivel2( Gramatica: TGramatica );
begin
  ExpressaoFator( Gramatica );
  ExpressaoPowSqt( Gramatica );
end;

procedure ExpressaoAddSub( Gramatica: TGramatica );
var
  Operador: TLexicoClass;
  S1, S2: string;
  N1, N2: Extended;
  B1, B2: Boolean;
begin
  if ( Gramatica.TokenList.Token.Classe in [ cmdAdd, cmdSub, cmdRes_and,
    cmdRes_or, cmdRes_xor ] ) then
  begin
    // carrega e continua analizando
    Operador := Gramatica.TokenList.Token.Classe;
    Gramatica.TokenList.GetNextToken;
    ExpressaoNivel1( Gramatica );
    // desempilha
    S2 := Gramatica.Pilha.Desempilhar( '' );
    S1 := Gramatica.Pilha.Desempilhar( '' );

    // se for operador matematico
    if ( Operador in [ cmdAdd, cmdSub ] ) then
    begin
      // converte para numero
      if TryStrToFloat( S1, N1, FormatSettings ) and
        TryStrToFloat( S2, N2, FormatSettings ) then
      begin
        // executa a operação matematica
        case Operador of
          cmdAdd:
            N1 := N1 + N2;
          cmdSub:
            N1 := N1 - N2;
        end;
        Gramatica.Pilha.Empilhar( N1 );
      end else begin
        // concatena o texto
        if Operador = cmdAdd then
          S1 := S1 + S2
        else
        begin
          System.Delete( S1, pos( S2, S1 ), Length( S2 ) );
        end;
        Gramatica.Pilha.Empilhar( S1 );
      end;
    end else begin
      // se nao compara com relação boleana
      B1 := S1.ToBoolean;
      B2 := S2.ToBoolean;
      case Operador of
        cmdRes_and:
          B1 := ( B1 and B2 );
        cmdRes_or:
          B1 := ( B1 or B2 );
        cmdRes_xor:
          B1 := ( B1 xor B2 );
      end;
      Gramatica.Pilha.Empilhar( B1 );
    end;
    ExpressaoAddSub( Gramatica );
  end;
end;

procedure ExpressaoMulDiv( Gramatica: TGramatica );
var
  Operador: TLexicoClass;
  N1, N2: Extended;
begin
  if ( Gramatica.TokenList.Token.Classe in [ cmdMult, cmdBar, cmdRes_mod ] )
  then
  begin
    // carrega e continua analizando
    Operador := Gramatica.TokenList.Token.Classe;
    Gramatica.TokenList.GetNextToken;
    ExpressaoNivel2( Gramatica );
    // desempilha
    N2 := Gramatica.Pilha.Desempilhar( 0.0 );
    N1 := Gramatica.Pilha.Desempilhar( 0.0 );

    // calcula a operação matematica
    case Operador of
      cmdMult:
        Gramatica.Pilha.Empilhar( N1 * N2 );
      cmdBar:
        begin
          // verifica divisão por 0
          if N2 <> 0 then
          begin
            N1 := N1 / N2;
            Gramatica.Pilha.Empilhar( N1 );
          end
          else
            Gramatica.ErroAdd( 'Divisão por 0.' );
        end;
      cmdRes_mod:
        begin
          // verifica divisão por 0
          if N2 <> 0 then
          begin
            N1 := Trunc( N1 ) mod Trunc( N2 );
            Gramatica.Pilha.Empilhar( N1 )
          end
          else
            Gramatica.ErroAdd( 'Divisão por 0.' );
        end;
    end;
    ExpressaoMulDiv( Gramatica );
  end;
end;

procedure ExpressaoPowSqt( Gramatica: TGramatica );
var
  Operador: TLexicoClass;
  S1, S2: string;
  N1, N2: Extended;
begin
  if ( Gramatica.TokenList.Token.Classe in [ cmdTone, cmdRes_root, cmdEqual,
    cmdMore, cmdMinor, cmdMoreEqual, cmdMinorEqual, cmdDifferent ] ) then
  begin
    // carrega e continua analizando
    Operador := Gramatica.TokenList.Token.Classe;
    Gramatica.TokenList.GetNextToken;
    ExpressaoFator( Gramatica );
    // desempilha
    S2 := Gramatica.Pilha.Desempilhar( '' );
    S1 := Gramatica.Pilha.Desempilhar( '' );
    // tenta converter para numero
    if TryStrToFloat( S1, N1, FormatSettings ) and
      TryStrToFloat( S2, N2, FormatSettings ) then
    begin
      // calcula a operação matematica
      case Operador of
        cmdTone:
          begin
            if TryPower( N1, N2, N1 ) then
              Gramatica.Pilha.Empilhar( N1 )
            else
              Gramatica.ErroAdd( 'Potencia Invalida' );
          end;
        cmdRes_root:
          begin
            if TryPower( N1, 1 / N2, N1 ) then
              Gramatica.Pilha.Empilhar( N1 )
            else
              Gramatica.ErroAdd( 'Raiz Invalida' );
          end;
        cmdEqual:
          Gramatica.Pilha.Empilhar( N1 = N2 );
        cmdMore:
          Gramatica.Pilha.Empilhar( N1 > N2 );
        cmdMinor:
          Gramatica.Pilha.Empilhar( N1 < N2 );
        cmdMoreEqual:
          Gramatica.Pilha.Empilhar( N1 >= N2 );
        cmdMinorEqual:
          Gramatica.Pilha.Empilhar( N1 <= N2 );
        cmdDifferent:
          Gramatica.Pilha.Empilhar( N1 <> N2 );
      end;

    end else begin
      // se nao compara com relação boleana
      case Operador of
        cmdEqual:
          Gramatica.Pilha.Empilhar( S1 = S2 );
        cmdDifferent:
          Gramatica.Pilha.Empilhar( S1 <> S2 );
      else
        Gramatica.ErroAdd( 'Operação não reconhecida.' );
      end;
    end;
    ExpressaoPowSqt( Gramatica );
  end;
end;

procedure ExpressaoFator( Gramatica: TGramatica );
begin
  case Gramatica.TokenList.Token.Classe of

    cmdID:
      Identificador( Gramatica ); // comandos

    cmdNumeric, cmdString:
      begin
        // empilha texto
        Gramatica.Pilha.Empilhar( Gramatica.TokenList.Token.Lexema );
        Gramatica.TokenList.GetNextToken;
      end;

    cmdSub:
      begin
        // atribui valor negativo para numeros
        Gramatica.TokenList.GetNextToken;
        ExpressaoFator( Gramatica );
        Gramatica.Pilha.Empilhar( Gramatica.Pilha.Desempilhar( 0.0 ) * -1 );
      end;

    cmdLPar:
      begin
        // abre parentes.
        Gramatica.TokenList.GetNextToken;
        Expressao( Gramatica );
        // fecha parentes.
        if Gramatica.TokenList.Token.Classe in [ cmdRPar, cmdEOF, cmdDotComa ]
        then
          Gramatica.TokenList.GetNextToken
        else
          Gramatica.ErroAdd( '")" Esperado.' );
      end;

    cmdRes_not:
      begin
        Gramatica.TokenList.GetNextToken;
        Expressao( Gramatica );
        Gramatica.Pilha.Empilhar
          ( not Boolean( Gramatica.Pilha.Desempilhar( False ) ) );
      end;
  else
    Gramatica.ErroAdd( 'Expressão Invalida.' );
  end;
end;

// -----------------------------IDENTIFICADOR----------------------------------//
function FindID( AItem: TPGItem; AName: string ): TPGItem;
begin
  Result := nil;
  if Assigned( AItem ) then
  begin
    if AItem = GlobalCollection then
    begin
      for AItem in GlobalCollection do
      begin
        Result := AItem.FindName( AName );
        if Assigned( Result ) then
          exit;
      end;
    end else begin
      Result := AItem.FindName( AName );
      if not Assigned( Result ) and Assigned( AItem.Parent ) then
        Result := FindID( AItem.Parent, AName );
    end;
  end;
end;

function IdentificadorLocalizar( Gramatica: TGramatica ): TPGItem;
begin
  Result := FindID( Gramatica.Local, Gramatica.TokenList.Token.Lexema );
end;

procedure Identificador( Gramatica: TGramatica );
var
  ID: TPGItemCMD;
begin
  if ( not Gramatica.Erro ) then
  begin
    ID := TPGItemCMD( IdentificadorLocalizar( Gramatica ) );
    if Assigned( ID ) then
      ID.Execute( Gramatica )
    else
      Gramatica.ErroAdd( 'Identificador não existente.' );
  end;
end;

initialization

finalization

end.
