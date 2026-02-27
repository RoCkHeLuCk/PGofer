unit PGofer.Triggers.VaultFolder;

interface

uses
  PGofer.Classes, PGofer.Triggers.Collections, PGofer.Triggers;

type

  {$M+}
  TPGVaultFolder = class(TPGFolderMirror)
  private
    FFileName: string;
    FFileID: TGUID;
    FPassword: string;
    FSavePassword: Boolean;
    class var FKeyStoreFile: String;
    function GetIsFileCan(): Boolean;
    function GetIsFileReal(): Boolean;
    function GetIsPassword(): Boolean;
  protected
    procedure SetLocked(AValue:Boolean); override;
    function GetIsValid( ): Boolean; override;
  public
    class constructor Create();
    constructor Create(AItemDad: TPGItem; AName: string = ''); override;
    destructor Destroy(); override;
    procedure Frame(AParent: TObject); override;
    property PasswordFrame: string read FPassword write FPassword;
    function BeforeXMLLoad(ItemCollect: TPGItemCollectTrigger): Boolean; override;
    function BeforeXMLSave(ItemCollect: TPGItemCollectTrigger): Boolean; override;
    class function OnDropFile( AItemDad: TPGItem; AFileName: String ): boolean; override;
    class function ClassNameEx(): String; override;
    class property KeyStoreFile: String read FKeyStoreFile write FKeyStoreFile;
  published
    property FileName: string read FFileName write FFileName;
    property Password: string write FPassword;
    property SavePassword: Boolean read FSavePassword write FSavePassword;
    property isFileName: Boolean read GetIsFileCan;
    property isPassword: Boolean read GetIsPassword;
  end;
  {$TYPEINFO ON}

implementation

uses
  System.Classes, System.SysUtils, System.StrUtils,
  PGofer.Core, PGofer.Runtime,
  PGofer.Files.Controls, PGofer.Triggers.VaultFolder.Frame,
  PGofer.Triggers.VaultFolder.KeyStore;

{ TPGVaultFolder }

class function TPGVaultFolder.ClassNameEx: String;
begin
  Result := 'VaultFolder';
end;

class constructor TPGVaultFolder.Create;
begin
  FKeyStoreFile := TPGKernel.PathCurrent + 'KeyStore.pgk';
end;

constructor TPGVaultFolder.Create(AItemDad: TPGItem; AName: string);
begin
  if AName = '' then
    AName := 'NewVaultFolder';
  inherited Create(AItemDad, AName);
  FFileName := '';
  FPassword := '';
  FSavePassword := False;
  FLocked := False;
end;

destructor TPGVaultFolder.Destroy();
begin
  FLocked := False;
  FSavePassword := False;
  FPassword := '';
  FFileName := '';
  inherited Destroy();
end;

function TPGVaultFolder.BeforeXMLLoad(ItemCollect: TPGItemCollectTrigger): Boolean;
var
  XMLStream : TStream;
begin
  Result := False;

  if (FileExistsEx(FFilename)) and (FFileID = TGUID.Empty) then
    FFileID := KeyStoreIDFromFile(FFileName);

  if (FSavePassword) and (FFileID <> TGUID.Empty) then
    FPassword := KeyStoreLoadPassoword(FFileID);

  if (not FLocked) and (GetIsFileReal) and (GetIsPassword) then
  begin
    FLocked := True;
    XMLStream := KeyStoreXMLFromAES(FFileName, FPassword);
    try
      if Assigned(XMLStream) then
      begin
        ItemCollect.XMLLoadFromStream(Self, XMLStream);
      end else begin
        TPGKernel.ConsoleTr('Error_VaultLoad',[FFileName]);
      end;
      FLocked := False;
    finally
      XMLStream.Free;
    end;
  end;
end;

function TPGVaultFolder.BeforeXMLSave(ItemCollect: TPGItemCollectTrigger): Boolean;
var
  XMLStream: TStream;
begin
  Result := False;
  if (not FLocked) and (GetIsValid) then
  begin
    XMLStream := TMemoryStream.Create();
    try
      ItemCollect.XMLSaveToStream(Self, XMLStream);
      if Assigned(XMLStream) then
      begin
        FFileID := KeyStoreSavePassword(FFileID, FPassword );
        if not KeyStoreXMLToAES(XMLStream, FFileName, FPassword, FFileID) then
           TPGKernel.ConsoleTr('Error_VaultSave',[FFileName]);
      end;
    finally
      XMLStream.Free;
    end;
  end;
end;

procedure TPGVaultFolder.Frame(AParent: TObject);
begin
  inherited Frame(AParent);
  TPGVaultFolderFrame.Create(Self, AParent);
end;

function TPGVaultFolder.GetIsFileCan: Boolean;
begin
  Result := DirectoryExistsFileEx( FFileName );
end;

function TPGVaultFolder.GetIsFileReal: Boolean;
begin
  Result := FileExistsEx( FFileName );
end;

function TPGVaultFolder.GetIsPassword: Boolean;
begin
  Result := ( (FPassword <> '') and ( Length(FPassword) >= 6 ) {and ....});
end;

function TPGVaultFolder.GetIsValid: Boolean;
begin
  Result := ( GetIsFileCan() and GetIsPassword() );
end;

class function TPGVaultFolder.OnDropFile(AItemDad: TPGItem; AFileName: String): boolean;
var
  LVaultFoder : TPGVaultFolder;
begin
  Result := False;
  if MatchText(ExtractFileExt(AFileName), ['.pgv']) then
  begin
    LVaultFoder := TPGVaultFolder.Create( AItemDad, FileExtractOnlyFileName( AFileName ) );
    LVaultFoder.FileName := FileUnExpandPath( AFileName );
    Result := True;
  end;
end;

procedure TPGVaultFolder.SetLocked(AValue: Boolean);
begin
   if (AValue <> FLocked) then
   begin
      FLocked := AValue;
      if (not FLocked) and (Self.isValid) then
      begin
        if FileExistsEx(FFileName) then
          Self.BeforeXMLLoad( TriggersCollect )
        else
          Self.BeforeXMLSave( TriggersCollect );
      end else begin
        Self.Clear;
        inherited SetLocked(True);
      end;
   end;
end;

initialization

TriggersCollect.RegisterClass( TPGVaultFolder );

finalization

end.
