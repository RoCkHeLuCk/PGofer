unit PGofer.DPAPI;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows;

type
  EProtectionError = class(Exception);

  // Wrapper para a DPAPI do Windows
  TDPAPI = class
  public
    // Criptografa um Stream inteiro
    class procedure ProtectStream(Source, Dest: TStream);
    // Descriptografa um Stream inteiro
    class procedure UnprotectStream(Source, Dest: TStream);
  end;

implementation

const
  CRYPTPROTECT_UI_FORBIDDEN = $1;

type
  DATA_BLOB = record
    cbData: DWORD;
    pbData: PByte;
  end;
  PDATA_BLOB = ^DATA_BLOB;

function CryptProtectData(pDataIn: PDATA_BLOB; szDataDescr: LPCWSTR;
  pOptionalEntropy: PDATA_BLOB; pvReserved: Pointer;
  pPromptStruct: Pointer; dwFlags: DWORD; pDataOut: PDATA_BLOB): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptProtectData';

function CryptUnprotectData(pDataIn: PDATA_BLOB; ppszDataDescr: PPWideChar;
  pOptionalEntropy: PDATA_BLOB; pvReserved: Pointer;
  pPromptStruct: Pointer; dwFlags: DWORD; pDataOut: PDATA_BLOB): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptUnprotectData';

{ TDPAPI }

class procedure TDPAPI.ProtectStream(Source, Dest: TStream);
var
  Input, Output: DATA_BLOB;
  InputMem: TMemoryStream;
begin
  InputMem := TMemoryStream.Create;
  try
    // Copia o XML original para memória para preparar o BLOB
    InputMem.CopyFrom(Source, 0);

    Input.cbData := InputMem.Size;
    Input.pbData := InputMem.Memory;
    Output.cbData := 0;
    Output.pbData := nil;

    // A mágica: Criptografa usando as credenciais do usuário atual
    if not CryptProtectData(@Input, nil, nil, nil, nil, CRYPTPROTECT_UI_FORBIDDEN, @Output) then
      RaiseLastOSError;

    try
      // Grava o tamanho do bloco criptografado (cabeçalho simples)
      Dest.WriteBuffer(Output.cbData, SizeOf(DWORD));
      // Grava os dados criptografados
      Dest.WriteBuffer(Output.pbData^, Output.cbData);
    finally
      LocalFree(HLOCAL(Output.pbData));
    end;
  finally
    InputMem.Free;
  end;
end;

class procedure TDPAPI.UnprotectStream(Source, Dest: TStream);
var
  Input, Output: DATA_BLOB;
  DataSize: DWORD;
  Buffer: TBytes;
begin
  // Lê o tamanho do bloco
  if Source.Read(DataSize, SizeOf(DWORD)) < SizeOf(DWORD) then
    raise EProtectionError.Create('Arquivo inválido ou corrompido.');

  SetLength(Buffer, DataSize);
  Source.ReadBuffer(Buffer[0], DataSize);

  Input.cbData := DataSize;
  Input.pbData := @Buffer[0];
  Output.cbData := 0;
  Output.pbData := nil;

  // Tenta descriptografar. Se for outra máquina/usuário, falha aqui.
  if not CryptUnprotectData(@Input, nil, nil, nil, nil, CRYPTPROTECT_UI_FORBIDDEN, @Output) then
    raise EProtectionError.Create('Acesso negado: Este arquivo não pertence a este usuário/máquina.');

  try
    Dest.WriteBuffer(Output.pbData^, Output.cbData);
    Dest.Position := 0; // Reseta para leitura do XML
  finally
    LocalFree(HLOCAL(Output.pbData));
  end;
end;

end.
