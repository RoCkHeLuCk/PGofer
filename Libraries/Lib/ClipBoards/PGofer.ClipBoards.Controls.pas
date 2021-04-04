unit PGofer.ClipBoards.Controls;

interface

uses
  System.Classes;

procedure ClipBoardCopyFromText( Text: string );
procedure ClipBoardClear( );
procedure ClipBoardGetAsHandle( fmt: Cardinal; S: TStream );
function ClipBoardGetFormat( ): string;
function ClipBoardPasteToText( ): string;
function ClipBoardLoadFile( Arquivo: string ): boolean;
procedure ClipBoardLoadFormat( Reader: TReader );
procedure ClipBoardLoadStream( S: TStream );
function ClipBoardSaveFile( Arquivo: string ): boolean;
procedure ClipBoardSaveFormat( fmt: Word; writer: TWriter );
procedure ClipBoardSaveStream( S: TStream );
procedure ClipBoardSetAsHandle( fmt: Cardinal; S: TStream );

implementation

uses
  Winapi.Windows, System.SysUtils, Vcl.ClipBrd;

procedure ClipBoardCopyFromText( Text: string );
begin
  Clipboard.AsText := Text;
end;

procedure ClipBoardClear( );
begin
  Clipboard.Clear;
end;

procedure ClipBoardGetAsHandle( fmt: Cardinal; S: TStream );
var
  hMem: THandle;
  pMem: Pointer;
begin
  Assert( Assigned( S ) );
  hMem := Clipboard.GetAsHandle( fmt );
  if hMem <> 0 then
  begin
    pMem := GlobalLock( hMem );
    if pMem <> nil then
    begin
      try
        S.Write( pMem^, GlobalSize( hMem ) );
        S.Position := 0;
      finally
        GlobalUnlock( hMem );
      end;
    end;
  end;
end;

function ClipBoardGetFormat( ): string;
var
  Continuar: boolean;
  c, d, e: Integer;
  FmtName: array [ 0 .. 128 ] of Char;
  Texto: string;
begin
  Result := '';
  try
    Clipboard.Open;
    c := 0;
    Continuar := True;
    while ( c < Clipboard.FormatCount ) and ( Continuar ) do
    begin
      Continuar := False;
      case Clipboard.Formats[ c ] of
        CF_TEXT, CF_OEMTEXT, CF_UNICODETEXT, CF_DSPTEXT, CF_LOCALE:
          begin
            d := 1;
            while ( d < Clipboard.AsText.Length ) and
               ( CharInSet( Clipboard.AsText[ d ], [ #0 .. #32 ] ) ) do
              inc( d );

            e := d;
            inc( e );
            while ( e < Clipboard.AsText.Length ) and
               ( not CharInSet( Clipboard.AsText[ e ], [ #0 .. #31 ] ) ) do
              inc( e );
            Texto := 'Text: ' + Copy( Clipboard.AsText, d, e - d );
          end;

        CF_BITMAP, CF_METAFILEPICT, CF_ENHMETAFILE, CF_DSPBITMAP,
           CF_DSPMETAFILEPICT, CF_DSPENHMETAFILE, CF_DIB, CF_TIFF,
           CF_PALETTE, CF_DIBV5:
          Texto := 'Picture';

        CF_SYLK:
          Texto := 'Windows Symbolic Link';
        CF_DIF:
          Texto := 'Windows Data Interchange';
        CF_PENDATA:
          Texto := 'Windows Pen Data';
        CF_RIFF:
          Texto := 'Resource Interchange File Format Audio';
        CF_WAVE:
          Texto := 'Wave Audio';
        CF_HDROP:
          Texto := 'Windows File';
        CF_OWNERDISPLAY:
          Texto := 'Owner Display';
      else
        Continuar := True;
        if GetClipboardFormatName( Clipboard.Formats[ c ], FmtName,
           SizeOf( FmtName ) ) <> 0 then
          Texto := FmtName;
      end;

      Result := Texto;
      inc( c );
    end;
  finally
    Clipboard.Close;
  end;
end;

function ClipBoardPasteToText( ): string;
begin
  Result := Clipboard.AsText;
end;

function ClipBoardLoadFile( Arquivo: string ): boolean;
var
  Ms: TMemoryStream;
begin
  Ms := TMemoryStream.Create;
  Ms.LoadFromFile( Arquivo );
  ClipBoardLoadStream( Ms );
  Result := True;
end;

procedure ClipBoardLoadFormat( Reader: TReader );
var
  fmt: Integer;
  FmtName: string;
  Size: Integer;
  Ms: TMemoryStream;
begin
  Assert( Assigned( Reader ) );
  fmt := Reader.ReadInteger;
  FmtName := Reader.ReadString;
  Size := Reader.ReadInteger;
  Ms := TMemoryStream.Create;
  try
    Ms.Size := Size;
    Reader.Read( Ms.memory^, Size );
    if Length( FmtName ) > 0 then
      fmt := RegisterCLipboardFormat( PChar( FmtName ) );
    if fmt <> 0 then
      ClipBoardSetAsHandle( fmt, Ms );
  finally
    Ms.Free;
  end;
end;

procedure ClipBoardLoadStream( S: TStream );
var
  Reader: TReader;
begin
  Assert( Assigned( S ) );
  Reader := TReader.Create( S, 4096 );
  try
    Clipboard.Open;
    try
      Clipboard.Clear;
      Reader.Position := 1;
      while not Reader.EndOfList do
        ClipBoardLoadFormat( Reader );
    finally
      Clipboard.Close;
    end;
  finally
    Reader.Free
  end;
end;

function ClipBoardSaveFile( Arquivo: string ): boolean;
var
  Ms: TMemoryStream;
begin
  Ms := TMemoryStream.Create;
  ClipBoardSaveStream( Ms );
  Ms.SaveToFile( Arquivo );
  Result := True;
end;

procedure ClipBoardSaveFormat( fmt: Word; writer: TWriter );
var
  FmtName: array [ 0 .. 128 ] of Char;
  Ms: TMemoryStream;
begin
  Assert( Assigned( writer ) );
  if 0 = GetClipboardFormatName( fmt, FmtName, SizeOf( FmtName ) ) then
    FmtName[ 0 ] := #0;

  Ms := TMemoryStream.Create;
  try
    ClipBoardGetAsHandle( fmt, Ms );
    if Ms.Size > 0 then
    begin
      writer.WriteInteger( fmt );
      writer.WriteString( FmtName );
      writer.WriteInteger( Ms.Size );
      writer.Write( Ms.memory^, Ms.Size );
    end;
  finally
    Ms.Free
  end;
end;

procedure ClipBoardSaveStream( S: TStream );
var
  writer: TWriter;
  i: Integer;
begin
  Assert( Assigned( S ) );
  writer := TWriter.Create( S, 4096 );
  try
    Clipboard.Open;
    try
      writer.WriteListBegin;
      for i := 0 to Clipboard.FormatCount - 1 do
        ClipBoardSaveFormat( Clipboard.Formats[ i ], writer );
      writer.WriteListEnd;
    finally
      Clipboard.Close;
    end;
  finally
    writer.Free;
  end;
end;

procedure ClipBoardSetAsHandle( fmt: Cardinal; S: TStream );
var
  hMem: THandle;
  pMem: Pointer;
begin
  Assert( Assigned( S ) );
  S.Position := 0;
  hMem := GlobalAlloc( GHND or GMEM_DDESHARE, S.Size );
  if hMem <> 0 then
  begin
    pMem := GlobalLock( hMem );
    if pMem <> nil then
    begin
      try
        S.Read( pMem^, S.Size );
        S.Position := 0;
      finally
        GlobalUnlock( hMem );
      end;
      Clipboard.Open;
      try
        Clipboard.SetAsHandle( fmt, hMem );
      finally
        Clipboard.Close;
      end;
    end else begin
      GlobalFree( hMem );
      OutOfMemoryError;
    end;
  end
  else
    OutOfMemoryError;
end;

end.
