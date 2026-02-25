unit PGofer.Files.ZLib;

interface

uses
  System.Classes;

function ZLibCompress(const MStream: TMemoryStream; const FileName, Password: string): Boolean;
function ZLibDecompress(const FileName, Password: string): TMemoryStream;

implementation

uses
  System.ZLib;

function ZLibCompress(const MStream: TMemoryStream; const FileName, Password: string): Boolean;
var
  LTempStream: TMemoryStream;
  LCompressedStream: TCompressionStream;
begin
  try
    LTempStream := TMemoryStream.create;
    LCompressedStream := TCompressionStream.create(LTempStream);
    MStream.Seek(0, soBeginning);
    LCompressedStream.CopyFrom(MStream, MStream.Size);
    LCompressedStream.Free;
    LTempStream.SaveToFile(FileName);
    Result := True;
    LTempStream.Free;
  except
    Result := False;
  end;
end;

function ZLibDecompress(const FileName, Password: string): TMemoryStream;
var
  LTempStream: TMemoryStream;
  LDecompressionStream: TDecompressionStream;
begin
  try
    LTempStream := TMemoryStream.create;
    LTempStream.LoadFromFile(FileName);
    LDecompressionStream := TDecompressionStream.create(LTempStream);
    LDecompressionStream.Seek(0, soBeginning);
    Result := TMemoryStream.create;
    Result.CopyFrom(LDecompressionStream, LDecompressionStream.Size);
    LDecompressionStream.Free;
    LTempStream.Free;
    Result.Position := 0;
  except
    Result := nil;
  end;
end;

end.
