unit PGofer.Files.Encrypt;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows;

{ AES }
function AESEncryptStream(StreamFrom, StreamTo: TStream; Password: string): Boolean; overload;
function AESDecryptStream(StreamFrom, StreamTo: TStream; Password: string): Boolean; overload;
function AESEncryptStream(StreamFrom: TStream; Password: string): TStream; overload;
function AESDecryptStream(StreamFrom: TStream; Password: string): TStream; overload;
function AESEncryptFile(FileFrom, FileTo: string; Password: string): Boolean;
function AESDecryptFile(FileFrom, FileTo: string; Password: string): Boolean;
function AESEncryptStreamToFile(StreamFrom: TStream; FileTo: string; Password: string): Boolean;
function AESDecryptFileToStream(FileFrom: string; Password: string): TStream;
function AESEncryptStringToFile(StringFrom: string; FileTo: string; Password: string): Boolean;
function AESDecryptFileToString(FileFrom: string; Password: string): string;

{ DPAPI }
function DPAPIEncryptStream(StreamFrom, StreamTo: TStream; Entropy: string): Boolean; overload;
function DPAPIDecryptStream(StreamFrom, StreamTo: TStream; Entropy: string): Boolean; overload;
function DPAPIEncryptStream(StreamFrom: TStream; Entropy: string): TStream; overload;
function DPAPIDecryptStream(StreamFrom: TStream; Entropy: string): TStream; overload;
function DPAPIEncryptFile(FileFrom, FileTo: string; Entropy: string): Boolean;
function DPAPIDecryptFile(FileFrom, FileTo: string; Entropy: string): Boolean;
function DPAPIEncryptStreamToFile(StreamFrom: TStream; FileTo: string; Entropy: string): Boolean;
function DPAPIDecryptFileToStream(FileFrom: string; Entropy: string): TStream;
function DPAPIEncryptStringToFile(StringFrom: string; const FileTo: string; Entropy: string): Boolean;
function DPAPIDecryptFileToString(FileFrom: string; Entropy: string): string;

implementation

const
  CRYPT_VERIFYCONTEXT = $F0000000;
  CRYPTPROTECT_UI_FORBIDDEN = $1;
  PROV_RSA_AES = 24;
  CALG_AES_256 = $00006610;
  CALG_SHA1 = $00008004;

type
  HCRYPTPROV = type THandle;
  HCRYPTHASH = type THandle;
  HCRYPTKEY = NativeUInt;
  ALG_ID = Cardinal;

  DATA_BLOB = record
    cbData: DWORD;
    pbData: PByte;
  end;

  PDATA_BLOB = ^DATA_BLOB;

  { API Windows }
function CryptAcquireContext(var phProv: HCRYPTPROV; pszContainer: LPCSTR; pszProvider: LPCSTR;
  dwProvType: DWORD; dwFlags: DWORD): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptAcquireContextA';
function CryptCreateHash(hProv: HCRYPTPROV; Algid: ALG_ID; hKey: HCRYPTKEY; dwFlags: DWORD;
  var phHash: HCRYPTHASH): BOOL; stdcall; external 'advapi32.dll' name 'CryptCreateHash';
function CryptHashData(hHash: HCRYPTHASH; pbData: PByte; dwDataLen: DWORD; dwFlags: DWORD): BOOL;
  stdcall; external 'advapi32.dll' name 'CryptHashData';
function CryptDeriveKey(hProv: HCRYPTPROV; Algid: ALG_ID; hBaseData: HCRYPTHASH; dwFlags: DWORD;
  var phKey: HCRYPTKEY): BOOL; stdcall; external 'advapi32.dll' name 'CryptDeriveKey';
function CryptEncrypt(hKey: HCRYPTKEY; hHash: HCRYPTHASH; Final: BOOL; dwFlags: DWORD;
  pbData: PByte; var pdwDataLen: DWORD; dwBufLen: DWORD): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptEncrypt';
function CryptDecrypt(hKey: HCRYPTKEY; hHash: HCRYPTHASH; Final: BOOL; dwFlags: DWORD;
  pbData: PByte; var pdwDataLen: DWORD): BOOL; stdcall; external 'advapi32.dll' name 'CryptDecrypt';
function CryptDestroyKey(hKey: HCRYPTKEY): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptDestroyKey';
function CryptDestroyHash(hHash: HCRYPTHASH): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptDestroyHash';
function CryptReleaseContext(hProv: HCRYPTPROV; dwFlags: DWORD): BOOL; stdcall;
  external 'advapi32.dll' name 'CryptReleaseContext';
function CryptProtectData(pDataIn: PDATA_BLOB; szDataDescr: LPCWSTR; pOptionalEntropy: PDATA_BLOB;
  pvReserved: Pointer; pPromptStruct: Pointer; dwFlags: DWORD; pDataOut: PDATA_BLOB): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptProtectData';
function CryptUnprotectData(pDataIn: PDATA_BLOB; ppszDataDescr: PPWideChar;
  pOptionalEntropy: PDATA_BLOB; pvReserved: Pointer; pPromptStruct: Pointer; dwFlags: DWORD;
  pDataOut: PDATA_BLOB): BOOL; stdcall; external 'crypt32.dll' name 'CryptUnprotectData';

{ AES }
function AESEncryptStream(StreamFrom, StreamTo: TStream; Password: string): Boolean;
var
  hProv: HCRYPTPROV;
  hHash: HCRYPTHASH;
  hKey: HCRYPTKEY;
  Buffer: TBytes;
  DataLen, BufLen: DWORD;
  PasswordBytes: TBytes;
begin
  Result := False;
  hProv := 0;
  hHash := 0;
  hKey := 0;
  try
    if not CryptAcquireContext(hProv, nil, nil, PROV_RSA_AES, CRYPT_VERIFYCONTEXT) then
      Exit;
    if not CryptCreateHash(hProv, CALG_SHA1, 0, 0, hHash) then
      Exit;
    PasswordBytes := TEncoding.UTF8.GetBytes(Password);
    if not CryptHashData(hHash, @PasswordBytes[0], Length(PasswordBytes), 0) then
      Exit;
    if not CryptDeriveKey(hProv, CALG_AES_256, hHash, 0, hKey) then
      Exit;

    DataLen := StreamFrom.Size - StreamFrom.Position;
    BufLen := DataLen + 32;
    SetLength(Buffer, BufLen);

    if DataLen > 0 then
      StreamFrom.ReadBuffer(Buffer[0], DataLen);

    if not CryptEncrypt(hKey, 0, True, 0, @Buffer[0], DataLen, BufLen) then
      Exit;

    StreamTo.WriteBuffer(Buffer[0], DataLen);
    Result := True;
  finally
    if hKey <> 0 then
      CryptDestroyKey(hKey);
    if hHash <> 0 then
      CryptDestroyHash(hHash);
    if hProv <> 0 then
      CryptReleaseContext(hProv, 0);
  end;
end;

function AESDecryptStream(StreamFrom, StreamTo: TStream; Password: string): Boolean;
var
  hProv: HCRYPTPROV;
  hHash: HCRYPTHASH;
  hKey: HCRYPTKEY;
  Buffer: TBytes;
  DataLen: DWORD;
  PasswordBytes: TBytes;
begin
  Result := False;
  hProv := 0;
  hHash := 0;
  hKey := 0;
  try
    if not CryptAcquireContext(hProv, nil, nil, PROV_RSA_AES, CRYPT_VERIFYCONTEXT) then
      Exit;
    if not CryptCreateHash(hProv, CALG_SHA1, 0, 0, hHash) then
      Exit;
    PasswordBytes := TEncoding.UTF8.GetBytes(Password);
    if not CryptHashData(hHash, @PasswordBytes[0], Length(PasswordBytes), 0) then
      Exit;
    if not CryptDeriveKey(hProv, CALG_AES_256, hHash, 0, hKey) then
      Exit;

    DataLen := StreamFrom.Size - StreamFrom.Position;
    if DataLen = 0 then
    begin
      Result := True;
      Exit;
    end;

    SetLength(Buffer, DataLen);
    StreamFrom.ReadBuffer(Buffer[0], DataLen);

    if not CryptDecrypt(hKey, 0, True, 0, @Buffer[0], DataLen) then
      Exit;

    StreamTo.WriteBuffer(Buffer[0], DataLen);
    Result := True;
  finally
    if hKey <> 0 then
      CryptDestroyKey(hKey);
    if hHash <> 0 then
      CryptDestroyHash(hHash);
    if hProv <> 0 then
      CryptReleaseContext(hProv, 0);
  end;
end;

function AESEncryptStream(StreamFrom: TStream; Password: string): TStream;
begin
  Result := TMemoryStream.Create;
  if not AESEncryptStream(StreamFrom, Result, Password) then
    FreeAndNil(Result)
  else
    Result.Position := 0;
end;

function AESDecryptStream(StreamFrom: TStream; Password: string): TStream;
begin
  Result := TMemoryStream.Create;
  if not AESDecryptStream(StreamFrom, Result, Password) then
    FreeAndNil(Result)
  else
    Result.Position := 0;
end;

function AESEncryptFile(FileFrom, FileTo: string; Password: string): Boolean;
var
  fsIn, fsOut: TFileStream;
begin
  Result := False;
  if not FileExists(FileFrom) then
    Exit;
  fsIn := TFileStream.Create(FileFrom, fmOpenRead or fmShareDenyWrite);
  try
    fsOut := TFileStream.Create(FileTo, fmCreate);
    try
      Result := AESEncryptStream(fsIn, fsOut, Password);
    finally
      fsOut.Free;
      if (not Result) and FileExists(FileTo) then
        DeleteFile(PWideChar(FileTo));
    end;
  finally
    fsIn.Free;
  end;
end;

function AESDecryptFile(FileFrom, FileTo: string; Password: string): Boolean;
var
  fsIn, fsOut: TFileStream;
begin
  Result := False;
  if not FileExists(FileFrom) then
    Exit;
  fsIn := TFileStream.Create(FileFrom, fmOpenRead or fmShareDenyWrite);
  try
    fsOut := TFileStream.Create(FileTo, fmCreate);
    try
      Result := AESDecryptStream(fsIn, fsOut, Password);
    finally
      fsOut.Free;
      if (not Result) and FileExists(FileTo) then
        DeleteFile(PWideChar(FileTo));
    end;
  finally
    fsIn.Free;
  end;
end;

function AESEncryptStreamToFile(StreamFrom: TStream; FileTo: string; Password: string): Boolean;
var
  fsOut: TFileStream;
begin
  Result := False;
  fsOut := TFileStream.Create(FileTo, fmCreate);
  try
    Result := AESEncryptStream(StreamFrom, fsOut, Password);
  finally
    fsOut.Free;
    if (not Result) and FileExists(FileTo) then
      DeleteFile(PWideChar(FileTo));
  end;
end;

function AESDecryptFileToStream(FileFrom: string; Password: string): TStream;
var
  fsIn: TFileStream;
begin
  Result := nil;
  if not FileExists(FileFrom) then
    Exit;
  fsIn := TFileStream.Create(FileFrom, fmOpenRead or fmShareDenyWrite);
  try
    Result := AESDecryptStream(fsIn, Password);
  finally
    fsIn.Free;
  end;
end;

function AESEncryptStringToFile(StringFrom: string; FileTo: string; Password: string): Boolean;
var
  ssIn: TStringStream;
begin
  Result := False;
  ssIn := TStringStream.Create(StringFrom, TEncoding.UTF8);
  try
    Result := AESEncryptStreamToFile(ssIn, FileTo, Password);
  finally
    ssIn.Free;
  end;
end;

function AESDecryptFileToString(FileFrom: string; Password: string): string;
var
  msOut: TStream;
  ssOut: TStringStream;
begin
  Result := '';
  msOut := AESDecryptFileToStream(FileFrom, Password);
  if Assigned(msOut) then
    try
      ssOut := TStringStream.Create('', TEncoding.UTF8);
      try
        ssOut.CopyFrom(msOut, 0);
        Result := ssOut.DataString;
      finally
        ssOut.Free;
      end;
    finally
      msOut.Free;
    end;
end;

{ DPAPI }

function DPAPIEncryptStream(StreamFrom, StreamTo: TStream; Entropy: string): Boolean;
var
  Input, Output, EntropyBlob: DATA_BLOB;
  pEntropy: PDATA_BLOB;
  EntropyBytes: TBytes;
  InputMem: TMemoryStream;
begin
  Result := False;
  InputMem := TMemoryStream.Create;
  try
    InputMem.CopyFrom(StreamFrom, 0);
    InputMem.Position := 0;
    Input.cbData := InputMem.Size;
    Input.pbData := InputMem.Memory;
    Output.cbData := 0;
    Output.pbData := nil;

    pEntropy := nil;
    if Entropy <> '' then
    begin
      EntropyBytes := TEncoding.UTF8.GetBytes(Entropy);
      EntropyBlob.cbData := Length(EntropyBytes);
      EntropyBlob.pbData := @EntropyBytes[0];
      pEntropy := @EntropyBlob;
    end;

    if not CryptProtectData(@Input, nil, pEntropy, nil, nil, CRYPTPROTECT_UI_FORBIDDEN, @Output)
    then
      Exit;

    try
      StreamTo.WriteBuffer(Output.cbData, SizeOf(DWORD));
      StreamTo.WriteBuffer(Output.pbData^, Output.cbData);
      Result := True;
    finally
      if Output.pbData <> nil then
        LocalFree(HLOCAL(Output.pbData));
    end;
  finally
    InputMem.Free;
  end;
end;

function DPAPIDecryptStream(StreamFrom, StreamTo: TStream; Entropy: string): Boolean;
var
  Input, Output, EntropyBlob: DATA_BLOB;
  pEntropy: PDATA_BLOB;
  EntropyBytes: TBytes;
  DataSize: DWORD;
  Buffer: TBytes;
begin
  Result := False;
  try
    if StreamFrom.Read(DataSize, SizeOf(DWORD)) < SizeOf(DWORD) then
      Exit;
    SetLength(Buffer, DataSize);
    if StreamFrom.Read(Buffer[0], DataSize) < Integer(DataSize) then
      Exit;

    Input.cbData := DataSize;
    Input.pbData := @Buffer[0];
    Output.cbData := 0;
    Output.pbData := nil;

    pEntropy := nil;
    if Entropy <> '' then
    begin
      EntropyBytes := TEncoding.UTF8.GetBytes(Entropy);
      EntropyBlob.cbData := Length(EntropyBytes);
      EntropyBlob.pbData := @EntropyBytes[0];
      pEntropy := @EntropyBlob;
    end;

    if not CryptUnprotectData(@Input, nil, pEntropy, nil, nil, CRYPTPROTECT_UI_FORBIDDEN, @Output)
    then
      Exit;

    try
      StreamTo.WriteBuffer(Output.pbData^, Output.cbData);
      Result := True;
    finally
      if Output.pbData <> nil then
        LocalFree(HLOCAL(Output.pbData));
    end;
  except
    Result := False;
  end;
end;

function DPAPIEncryptStream(StreamFrom: TStream; Entropy: string): TStream;
begin
  Result := TMemoryStream.Create;
  if not DPAPIEncryptStream(StreamFrom, Result, Entropy) then
    FreeAndNil(Result)
  else
    Result.Position := 0;
end;

function DPAPIDecryptStream(StreamFrom: TStream; Entropy: string): TStream;
begin
  Result := TMemoryStream.Create;
  if not DPAPIDecryptStream(StreamFrom, Result, Entropy) then
    FreeAndNil(Result)
  else
    Result.Position := 0;
end;

function DPAPIEncryptFile(FileFrom, FileTo: string; Entropy: string): Boolean;
var
  fsIn, fsOut: TFileStream;
begin
  Result := False;
  if not FileExists(FileFrom) then
    Exit;
  fsIn := TFileStream.Create(FileFrom, fmOpenRead or fmShareDenyWrite);
  try
    fsOut := TFileStream.Create(FileTo, fmCreate);
    try
      Result := DPAPIEncryptStream(fsIn, fsOut, Entropy);
    finally
      fsOut.Free;
      if (not Result) and FileExists(FileTo) then
        DeleteFile(PWideChar(FileTo));
    end;
  finally
    fsIn.Free;
  end;
end;

function DPAPIDecryptFile(FileFrom, FileTo: string; Entropy: string): Boolean;
var
  fsIn, fsOut: TFileStream;
begin
  Result := False;
  if not FileExists(FileFrom) then
    Exit;
  fsIn := TFileStream.Create(FileFrom, fmOpenRead or fmShareDenyWrite);
  try
    fsOut := TFileStream.Create(FileTo, fmCreate);
    try
      Result := DPAPIDecryptStream(fsIn, fsOut, Entropy);
    finally
      fsOut.Free;
      if (not Result) and FileExists(FileTo) then
        DeleteFile(PWideChar(FileTo));
    end;
  finally
    fsIn.Free;
  end;
end;

function DPAPIEncryptStreamToFile(StreamFrom: TStream; FileTo: string; Entropy: string): Boolean;
var
  fsOut: TFileStream;
begin
  Result := False;
  fsOut := TFileStream.Create(FileTo, fmCreate);
  try
    Result := DPAPIEncryptStream(StreamFrom, fsOut, Entropy);
  finally
    fsOut.Free;
    if (not Result) and FileExists(FileTo) then
      DeleteFile(PWideChar(FileTo));
  end;
end;

function DPAPIDecryptFileToStream(FileFrom: string; Entropy: string): TStream;
var
  fsIn: TFileStream;
begin
  Result := nil;
  if not FileExists(FileFrom) then
    Exit;
  fsIn := TFileStream.Create(FileFrom, fmOpenRead or fmShareDenyWrite);
  try
    Result := DPAPIDecryptStream(fsIn, Entropy);
  finally
    fsIn.Free;
  end;
end;

function DPAPIEncryptStringToFile(StringFrom: string; const FileTo: string;
  Entropy: string): Boolean;
var
  ssIn: TStringStream;
begin
  Result := False;
  ssIn := TStringStream.Create(StringFrom, TEncoding.UTF8);
  try
    Result := DPAPIEncryptStreamToFile(ssIn, FileTo, Entropy);
  finally
    ssIn.Free;
  end;
end;

function DPAPIDecryptFileToString(FileFrom: string; Entropy: string): string;
var
  msOut: TStream;
  ssOut: TStringStream;
begin
  Result := '';
  msOut := DPAPIDecryptFileToStream(FileFrom, Entropy);
  if Assigned(msOut) then
    try
      ssOut := TStringStream.Create('', TEncoding.UTF8);
      try
        ssOut.CopyFrom(msOut, 0);
        Result := ssOut.DataString;
      finally
        ssOut.Free;
      end;
    finally
      msOut.Free;
    end;
end;

end.
