unit PGofer.Triggers.VaultFolder;

interface

uses
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Triggers.Collections, PGofer.Triggers;

type
  {$M+}
  TPGVaultFolder = class(TPGFolderMirror)
  private
    FFileName: string;
    FFileID: TGUID;
    FPassword: string;
    FPasswordBuffer: string;
    FSavePassword: Boolean;
    function GetIsFileCan(): Boolean;
    function GetIsFileReal(): Boolean;
    function GetIsPassword(): Boolean;
    class var FKeyStoreFile: String;
    procedure SetSavePassword(const Value: Boolean);
    procedure SetPassword(const Value: string);
  protected
    procedure SetLocked(const AValue:Boolean); override;
    function GetIsValid( ): Boolean; override;
  public
    class constructor Create();
    class function OnDropFile( AItemDad: TPGItem; AFileName: String ): boolean; override;
    class function ClassNameEx(): String; override;
    class property KeyStoreFile: String read FKeyStoreFile write FKeyStoreFile;
    constructor Create( AItemDad: TPGItem; AName: string); override;
    destructor Destroy(); override;
    procedure Frame(AParent: TObject); override;
    property PasswordFrame: string read FPasswordBuffer;
    function BeforeXMLLoad(ItemCollect: TPGItemCollectTrigger): Boolean; override;
    function BeforeXMLSave(ItemCollect: TPGItemCollectTrigger): Boolean; override;
  published
    property FileName: string read FFileName write FFileName;
    property Password: string write SetPassword;
    property SavePassword: Boolean read FSavePassword write SetSavePassword;
    property isFileName: Boolean read GetIsFileCan;
    property isPassword: Boolean read GetIsPassword;
  end;
  {$TYPEINFO ON}

implementation

uses
  System.Classes, System.SysUtils, System.StrUtils,
  PGofer.Runtime,
  PGofer.Files.Controls, PGofer.Triggers.VaultFolder.Frame,
  PGofer.Triggers.VaultFolder.KeyStore;

{ TPGVaultFolder }

class constructor TPGVaultFolder.Create;
begin
  FKeyStoreFile := TPGKernel.PathCurrent + 'KeyStore.pgk';
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

class function TPGVaultFolder.ClassNameEx: String;
begin
  Result := 'VaultFolder';
end;

constructor TPGVaultFolder.Create( AItemDad: TPGItem; AName: string );
begin
  inherited Create(AItemDad, AName);
  FFileName := '';
  FPassword := '';
  FPasswordBuffer := '';
  FSavePassword := False;
  Self.SetLockedForced( True );
end;

destructor TPGVaultFolder.Destroy();
begin
  Self.SetLockedForced( False );
  FSavePassword := False;
  FPassword := '';
  FPasswordBuffer := '';
  FFileName := '';
  inherited Destroy( );
end;

function TPGVaultFolder.BeforeXMLLoad(ItemCollect: TPGItemCollectTrigger): Boolean;
var
  XMLStream : TStream;
begin
  Result := False;

  if (not Self._Locked) and (Self.GetIsFileReal) and (Self.IsPassword) then
  begin
    XMLStream := KeyStoreXMLFromAES(FFileName, FPassword);
    try
      if Assigned(XMLStream) then
      begin
        ItemCollect.XMLLoadFromStream(Self, XMLStream);
      end else begin
        TPGKernel.ConsoleTr('Error_VaultLoad',[FFileName]);
        Self.SetLockedForced( True );
      end;
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
  if (not Self._Locked) and (Self.IsValid) then
  begin
    XMLStream := TMemoryStream.Create();
    try
      ItemCollect.XMLSaveToStream(Self, XMLStream);
      if Assigned(XMLStream) then
      begin
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

function TPGVaultFolder.GetIsValid(): Boolean;
begin
  Result := ( GetIsFileCan() and GetIsPassword() );
end;

procedure TPGVaultFolder.SetLocked(const AValue: Boolean);
begin
  if AValue = Self._Locked then Exit;

  if (not AValue) and (not Self.isValid) then
  begin
    inherited SetLocked( True );
    Exit;
  end;

  Self.SetLockedForced( False );
  if AValue then
  begin
    Self.BeforeXMLSave( TriggersCollect );
    Self.Clear;
    inherited SetLocked( True );
  end else begin
    Self.BeforeXMLLoad( TriggersCollect );
  end;

  inherited SetLocked( Self._Locked );
end;

procedure TPGVaultFolder.SetPassword(const Value: string);
begin
  if (FPassword = Value) or ( Value = '********') then Exit;
  FPassword := Value;
  FPasswordBuffer := FPassword;
  if Self.isPassword and FSavePassword then
    Self.SetSavePassword(True);
end;

procedure TPGVaultFolder.SetSavePassword(const Value: Boolean);
begin
  FSavePassword := Value;
  if not FSavePassword then
  begin
     KeyStoreSavePassword(FFileID, '');
     Exit;
  end;
  
  if (Self.GetIsFileReal) and (FFileID = TGUID.Empty) then
    FFileID := KeyStoreIDFromFile(FFileName);

  if isPassword then
    FFileID := KeyStoreSavePassword(FFileID, FPassword )
  else
    if (FFileID <> TGUID.Empty) then
      FPassword := KeyStoreLoadPassoword(FFileID);

  if isPassword and (FPasswordBuffer = '') then
    FPasswordBuffer := '********';
end;

initialization
   TriggersCollect.RegisterClass( TPGVaultFolder );

finalization

end.
