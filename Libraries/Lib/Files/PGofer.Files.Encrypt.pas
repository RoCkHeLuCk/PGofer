unit PGofer.Files.Encrypt;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows;

type
  HCRYPTPROV = type THandle;
  HCRYPTHASH = type THandle;
  HCRYPTKEY  = NativeUInt;
  EAESError = class(Exception);
  EDPAPIError = class(Exception);

  procedure AESEncryptStream(Source, Dest: TStream; const Password: string);
  procedure AESDecryptStream(Source, Dest: TStream; const Password: string);
  procedure AESEncryptFile(Source, Dest: string; const Password: string);
  procedure AESDecryptFile(Source, Dest: string; const Password: string);
  procedure DPAPIEncryptStream(Source, Dest: TStream);
  procedure DPAPIDecryptStream(Source, Dest: TStream);
  procedure DPAPIEncryptFile(Source, Dest: string);
  procedure DPAPIDecryptFile(Source, Dest: string);

implementation

const
  CRYPTPROTECT_UI_FORBIDDEN = $1;
  PROV_RSA_AES = 24;
  CALG_AES_256 = $00006610;
  CALG_SHA1    = $00008004;

type
  DATA_BLOB = record
    cbData: DWORD;
    pbData: PByte;
  end;
  PDATA_BLOB = ^DATA_BLOB;


// Declarações manuais da wincrypt (para garantir compatibilidade)
function CryptAcquireContext(var phProv: HCRYPTPROV; pszContainer: LPCSTR;
  pszProvider: LPCSTR; dwProvType: DWORD; dwFlags: DWORD): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptAcquireContextA';

function CryptCreateHash(hProv: HCRYPTPROV; Algid: ALG_ID; hKey: HCRYPTKEY;
  dwFlags: DWORD; var phHash: HCRYPTHASH): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptCreateHash';

function CryptHashData(hHash: HCRYPTHASH; pbData: PBYTE; dwDataLen: DWORD;
  dwFlags: DWORD): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptHashData';

function CryptDeriveKey(hProv: HCRYPTPROV; Algid: ALG_ID; hBaseData: HCRYPTHASH;
  dwFlags: DWORD; var phKey: HCRYPTKEY): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptDeriveKey';

function CryptEncrypt(hKey: HCRYPTKEY; hHash: HCRYPTHASH; Final: BOOL;
  dwFlags: DWORD; pbData: PBYTE; var pdwDataLen: DWORD; dwBufLen: DWORD): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptEncrypt';

function CryptDecrypt(hKey: HCRYPTKEY; hHash: HCRYPTHASH; Final: BOOL;
  dwFlags: DWORD; pbData: PBYTE; var pdwDataLen: DWORD): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptDecrypt';

function CryptDestroyKey(hKey: HCRYPTKEY): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptDestroyKey';

function CryptDestroyHash(hHash: HCRYPTHASH): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptDestroyHash';

function CryptReleaseContext(hProv: HCRYPTPROV; dwFlags: DWORD): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptReleaseContext';

function CryptProtectData(pDataIn: PDATA_BLOB; szDataDescr: LPCWSTR;
  pOptionalEntropy: PDATA_BLOB; pvReserved: Pointer;
  pPromptStruct: Pointer; dwFlags: DWORD; pDataOut: PDATA_BLOB): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptProtectData';

function CryptUnprotectData(pDataIn: PDATA_BLOB; ppszDataDescr: PPWideChar;
  pOptionalEntropy: PDATA_BLOB; pvReserved: Pointer;
  pPromptStruct: Pointer; dwFlags: DWORD; pDataOut: PDATA_BLOB): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptUnprotectData';


{ TPGAES }

procedure FileAESEncryptStream(Source, Dest: TStream; const Password: string);
var
  hProv: HCRYPTPROV;
  hHash: HCRYPTHASH;
  hKey: HCRYPTKEY;
  Buffer: TBytes;
  DataLen, BufLen: DWORD;
  PasswordBytes: TBytes;
begin
  if not CryptAcquireContext(hProv, nil, nil, PROV_RSA_AES, CRYPT_VERIFYCONTEXT) then
    RaiseLastOSError;
  try
    if not CryptCreateHash(hProv, CALG_SHA1, 0, 0, hHash) then
      RaiseLastOSError;
    try
      PasswordBytes := TEncoding.UTF8.GetBytes(Password);
      if not CryptHashData(hHash, @PasswordBytes[0], Length(PasswordBytes), 0) then
        RaiseLastOSError;

      // Gera a chave AES-256 baseada no Hash da senha
      if not CryptDeriveKey(hProv, CALG_AES_256, hHash, 0, hKey) then
        RaiseLastOSError;

      try
        DataLen := Source.Size;
        // O AES trabalha em blocos, precisamos de margem
        BufLen := DataLen + 32;
        SetLength(Buffer, BufLen);
        Source.ReadBuffer(Buffer[0], DataLen);

        if not CryptEncrypt(hKey, 0, True, 0, @Buffer[0], DataLen, BufLen) then
          RaiseLastOSError;

        Dest.WriteBuffer(Buffer[0], DataLen);
      finally
        CryptDestroyKey(hKey);
      end;
    finally
      CryptDestroyHash(hHash);
    end;
  finally
    CryptReleaseContext(hProv, 0);
  end;
end;

procedure FileAESDecryptStream(Source, Dest: TStream; const Password: string);
var
  hProv: HCRYPTPROV;
  hHash: HCRYPTHASH;
  hKey: HCRYPTKEY;
  Buffer: TBytes;
  DataLen: DWORD;
  PasswordBytes: TBytes;
begin
  if not CryptAcquireContext(hProv, nil, nil, PROV_RSA_AES, CRYPT_VERIFYCONTEXT) then
    RaiseLastOSError;
  try
    if not CryptCreateHash(hProv, CALG_SHA1, 0, 0, hHash) then
      RaiseLastOSError;
    try
      PasswordBytes := TEncoding.UTF8.GetBytes(Password);
      CryptHashData(hHash, @PasswordBytes[0], Length(PasswordBytes), 0);
      CryptDeriveKey(hProv, CALG_AES_256, hHash, 0, hKey);

      try
        DataLen := Source.Size;
        SetLength(Buffer, DataLen);
        Source.ReadBuffer(Buffer[0], DataLen);

        if not CryptDecrypt(hKey, 0, True, 0, @Buffer[0], DataLen) then
          raise EAESError.Create('Senha incorreta ou arquivo corrompido.');

        Dest.WriteBuffer(Buffer[0], DataLen);
      finally
        CryptDestroyKey(hKey);
      end;
    finally
      CryptDestroyHash(hHash);
    end;
  finally
    CryptReleaseContext(hProv, 0);
  end;
end;

procedure AESEncryptFile(Source, Dest: string; const Password: string);
begin

end;

procedure AESDecryptFile(Source, Dest: string; const Password: string);
begin

end;


procedure DPAPIEncryptStream(Source, Dest: TStream);
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

procedure DPAPIDecryptStream(Source, Dest: TStream);
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
