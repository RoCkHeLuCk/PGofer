unit PGofer.ZLib;

interface

uses
  System.ZLib, System.Classes;

function ZLibCompress( const MStream: TMemoryStream;
   const FileName, Password: string ): Boolean;
function ZLibDecompress( const FileName, Password: string ): TMemoryStream;
procedure Criptografar( Stream: TStream; Password: string );

implementation

// ----------------------------------------------------------------------------//
function ZLibCompress( const MStream: TMemoryStream;
   const FileName, Password: string ): Boolean;
var
  LTempStream: TMemoryStream;
  LCompressedStream: TCompressionStream;
begin
  try
    LTempStream := TMemoryStream.create;
    LCompressedStream := TCompressionStream.create( LTempStream );
    MStream.Seek( 0, soBeginning );
    LCompressedStream.CopyFrom( MStream, MStream.Size );
    LCompressedStream.Free;
    Criptografar( LTempStream, Password );
    LTempStream.SaveToFile( FileName );
    Result := True;
    LTempStream.Free;
  except
    Result := False;
  end;
end;

// ----------------------------------------------------------------------------//
function ZLibDecompress( const FileName, Password: string ): TMemoryStream;
var
  LTempStream: TMemoryStream;
  LDecompressionStream: TDecompressionStream;
begin
  try
    LTempStream := TMemoryStream.create;
    LTempStream.LoadFromFile( FileName );
    Criptografar( LTempStream, Password );
    LDecompressionStream := TDecompressionStream.create( LTempStream );
    LDecompressionStream.Seek( 0, soBeginning );
    Result := TMemoryStream.create;
    Result.CopyFrom( LDecompressionStream, LDecompressionStream.Size );
    LDecompressionStream.Free;
    LTempStream.Free;
    Result.Position := 0;
  except
    Result := nil;
  end;
end;

// ----------------------------------------------------------------------------//
procedure Criptografar( Stream: TStream; Password: string );
var
  x: Integer;
  y: Int64;
  c: Byte;
  l: Word;
begin
  l := Length( Password );
  if ( l > 0 ) and ( Stream <> nil ) then
  begin
    x := 1;
    y := 0;
    while y < Stream.Size do
    begin
      Stream.Position := y;
      Stream.Read( c, sizeof( c ) );
      c := Byte( Password[ x ] ) xor c;
      Stream.Position := y;
      Stream.Write( c, sizeof( c ) );
      if x >= l then
        x := 1
      else
        inc( x );
      y := y + 1;
    end;
    Stream.Position := 0;
  end;
end;
// ----------------------------------------------------------------------------//

end.
