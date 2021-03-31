unit PGofer.Math.Controls;

interface

function BoolToStr( const Valor: Boolean ): string; overload;
function TryBinToInt64( const S: string; var Value: Int64 ): Boolean;
function IntToBin( Valor: Int64 ): string;
function FormatConvert( const Prefixo: Boolean; const Formato: string;
   Valor: Extended ): string;
function Module( const Valor: Extended ): Extended;
function TryPower( Base, Expoente: Extended; out Resposta: Extended ): Boolean;

implementation

uses
  System.SysUtils, System.Math;

function BoolToStr( const Valor: Boolean ): string; overload;
begin
  if Valor then
    Result := '1'
  else
    Result := '0';
end;

function TryBinToInt64( const S: string; var Value: Int64 ): Boolean;
var
  c, d: Word;
begin
  d := Length( S );
  if d > 0 then
  begin
    Value := 0;
    Result := True;
    for c := 0 to d do
      if S[ c ] = '1' then
        Value := Value + ( 1 shl ( d - c ) );
  end
  else
    Result := False;
end;

function IntToBin( Valor: Int64 ): string;
begin
  while Valor > 0 do
  begin
    if ( Valor and 1 ) = 1 then
      Result := '1' + Result
    else
      Result := '0' + Result;
    Valor := Valor shr 1;
  end;
end;

function FormatConvert( const Prefixo: Boolean; const Formato: string;
   Valor: Extended ): string;
var
  pre, teste: Extended;
  c         : Int8;
begin
  if Prefixo then
  begin
    teste := Module( Valor );

    c := 0;
    repeat
      pre := Power10( 1, ( c * 3 ) - 24 );
      inc( c );
    until ( teste < pre ) or ( c > 16 );

    Result := FormatFloat( Formato, Valor / ( pre / 1000 ), FormatSettings );
    dec( c, 2 );

    case c of
      0:
      Result := Result + 'y';
      1:
      Result := Result + 'z';
      2:
      Result := Result + 'a';
      3:
      Result := Result + 'f';
      4:
      Result := Result + 'p';
      5:
      Result := Result + 'n';
      6:
      Result := Result + 'u';
      7:
      Result := Result + 'm';
      // 8 :
      9:
      Result := Result + 'k';
      10:
      Result := Result + 'M';
      11:
      Result := Result + 'G';
      12:
      Result := Result + 'T';
      13:
      Result := Result + 'P';
      14:
      Result := Result + 'E';
      15:
      Result := Result + 'Z';
      16:
      Result := Result + 'Y';
    end;
  end
  else
    Result := FormatFloat( Formato, Valor, FormatSettings );
end;

function Module( const Valor: Extended ): Extended;
begin

  if Valor < 0 then
    Result := Valor * -1
  else
    Result := Valor;
end;

function TryPower( Base, Expoente: Extended; out Resposta: Extended ): Boolean;
begin
  Resposta := 0;
  Result := not( ( Base < 0 ) and ( Frac( ( 1 / Expoente ) / 2 ) = 0 ) );

  if ( Base = 0 ) and ( Expoente = 0 ) then
    Resposta := 0
  else
  begin
    if ( Base = 0 ) then
      Resposta := 0;

    if ( Expoente = 0 ) then
      Resposta := 1;
  end;

  if ( ( Base < 0 ) and ( Expoente < 0 ) ) then
    Resposta := 1 / Exp( -Expoente * Ln( -Base ) )
  else if ( ( Base < 0 ) and ( Expoente >= 0 ) ) then
    Resposta := Exp( Expoente * Ln( -Base ) )
  else if ( ( Base > 0 ) and ( Expoente < 0 ) ) then
    Resposta := 1 / Exp( -Expoente * Ln( Base ) )
  else if ( ( Base > 0 ) and ( Expoente >= 0 ) ) then
    Resposta := Exp( Expoente * Ln( Base ) );

  if ( ( Base < 0 ) and ( Frac( Expoente / 2 ) <> 0 ) ) then
    Resposta := -Resposta;
end;

end.
