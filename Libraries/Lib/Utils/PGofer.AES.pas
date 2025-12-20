unit PGofer.AES;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows;

type
  HCRYPTPROV = type THandle;
  HCRYPTHASH = type THandle;
  HCRYPTKEY  = NativeUInt;

  EAESError = class(Exception);

  TPGAES = class
  public
    // Criptografa stream usando uma senha (string)
    class procedure EncryptStream(Source, Dest: TStream; const Password: string);
    // Descriptografa stream usando uma senha
    class procedure DecryptStream(Source, Dest: TStream; const Password: string);
  end;

implementation

const
  PROV_RSA_AES = 24;
  CALG_AES_256 = $00006610;
  CALG_SHA1    = $00008004;

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

{ TPGAES }

class procedure TPGAES.EncryptStream(Source, Dest: TStream; const Password: string);
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

class procedure TPGAES.DecryptStream(Source, Dest: TStream; const Password: string);
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

end.
