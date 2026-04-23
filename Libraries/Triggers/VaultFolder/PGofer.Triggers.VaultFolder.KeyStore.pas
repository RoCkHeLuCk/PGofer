unit PGofer.Triggers.VaultFolder.KeyStore;

interface
uses
  System.Classes;

const
  GUID_SIZE = SizeOf(TGUID);

  function KeyStoreIDFromFile(AFileName: string):TGUID;
  function KeyStoreXMLToAES(AXMLStream: TStream; AFileName, APassword: string; AFileID: TGUID):Boolean;
  function KeyStoreXMLFromAES(AFileName, APassword: string): TStream;
  function KeyStoreSavePassword(AFileID: TGUID; APassword: string): TGUID;
  function KeyStoreLoadPassoword(AFileID: TGUID): string;
  function KeyStoreChangeFilePassword(AFileName, AOldPassword, ANewPassword: string; AFileID: TGUID): Boolean;

implementation

uses
  System.SysUtils, System.JSON,

  PGofer.Files.Controls,
  PGofer.Files.Encrypt,
  PGofer.Triggers.VaultFolder;

const
  ENTROPY_SECRET = 'PGofer MasterKey';

function _KeyStoreLoadFile( ): TJSONObject;
var
  Content: string;
  JSONValue: TJSONValue;
begin
  Content := TPGVaultFolder.KeyStoreFile;
  if FileExists(Content) then
    Content := DPAPIDecryptFileToString(Content, ENTROPY_SECRET)
  else
    Content := '';

  JSONValue := TJSONObject.ParseJSONValue(Content);
  if (JSONValue <> nil) and (JSONValue is TJSONObject) then
  begin
    Result := TJSONObject(JSONValue);
  end else begin
    if Assigned(JSONValue) then
      JSONValue.Free;
    Result := TJSONObject.Create();
  end;
end;

function KeyStoreIDFromFile(AFileName: string):TGUID;
var
  Stream: TStream;
begin
  if FileExists(AFileName) then
  begin
    Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
    try
      Stream.Position := 0;
      Stream.Read( Result, GUID_SIZE);
    finally
      Stream.Free;
    end;
  end;
end;

function KeyStoreXMLToAES(AXMLStream: TStream; AFileName, APassword: string; AFileID: TGUID):Boolean;
var
  AESStream: TStream;
  LTempFile: string;
begin
  Result := False;
  if not Assigned(AXMLStream) then Exit;

  LTempFile := AFileName + '.tmp';

  AESStream := TFileStream.Create(LTempFile, fmCreate);
  try
    AESStream.Write(AFileID, GUID_SIZE);
    AESStream.Position := GUID_SIZE;
    AXMLStream.Position := 0;
    Result := AESEncryptStream(AXMLStream, AESStream, APassword);
  finally
    AESStream.Free;
  end;

  if not Result then Exit;

  Result := FileCommitWithBackup(AFileName);
end;

function KeyStoreXMLFromAES(AFileName, APassword: string): TStream;
var
  AESStream: TStream;
begin
  AESStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    AESStream.Position := GUID_SIZE;
    Result := AESDecryptStream(AESStream, APassword);
  finally
    AESStream.Free;
  end;
end;

function KeyStoreSavePassword(AFileID: TGUID; APassword: string): TGUID;
var
  JSONObject: TJSONObject;
  JSONPair: TJSONPair;
  Content : string;
begin
  if AFileID = TGUID.Empty then
  begin
    CreateGUID(AFileID);
  end;
  Result := AFileID;

  JSONObject := _KeyStoreLoadFile();
  if Assigned( JSONObject ) then
  begin
    Content := AFileID.ToString;
    JSONPair := JSONObject.RemovePair(Content);
    if Assigned(JSONPair) then
      JSONPair.Free;
    if APassword <> '' then
      JSONObject.AddPair(Content, APassword);
    Content := JSONObject.ToString;
    if not DPAPIEncryptStringToFile(Content, TPGVaultFolder.KeyStoreFile, ENTROPY_SECRET) then
    begin
      Result := TGUID.Empty;
    end;
    JSONObject.Free;
  end;
end;

function KeyStoreLoadPassoword(AFileID: TGUID): string;
var
  JSONObject: TJSONObject;
  JSONValue: TJSONValue;
begin
  Result := '';
  if (AFileID <> TGUID.Empty) then
  begin
    JSONObject := _KeyStoreLoadFile();
    try
      if Assigned( JSONObject ) then
      begin
        JSONValue := JSONObject.GetValue(AFileID.ToString);
        if Assigned(JSONValue) then
          Result:= JSONValue.Value;
      end;
    finally
      JSONObject.Free;
    end;
  end;
end;

function KeyStoreChangeFilePassword(AFileName, AOldPassword, ANewPassword: string; AFileID: TGUID): Boolean;
var
  XMLStream: TStream;
begin
  Result := False;

  XMLStream := KeyStoreXMLFromAES(AFileName, AOldPassword);
  try
    if Assigned(XMLStream) then
    begin
      Result := KeyStoreXMLToAES(XMLStream, AFileName, ANewPassword, AFileID);
      if Result then
        FileDeleteBackups(AFileName);
    end;
  finally
    if Assigned(XMLStream) then
      XMLStream.Free;
  end;
end;

initialization

finalization

end.
