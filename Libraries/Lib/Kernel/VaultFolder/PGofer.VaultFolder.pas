unit PGofer.VaultFolder;

interface

uses
  PGofer.Types, PGofer.Classes, PGofer.Sintatico.Classes;

type
{$M+}

  [TPGAttribText('Pasta criptografada.')]
  [TPGAttribIcon(pgiVault)]
  TPGVaultFolder = class(TPGFolder)
  private
    FFileName: string;
    FFileID: TGUID;
    FPassword: string;
    FSavePassword: Boolean;
    function GetIsFileName(): Boolean;
    function GetIsPassword(): Boolean;
  protected
    function BeforeXMLLoad(ItemCollect: TPGItemCollect): Boolean; override;
    function BeforeXMLSave(ItemCollect: TPGItemCollect): Boolean; override;
    procedure SetLocked(AValue:Boolean); override;
    function GetIsValid( ): Boolean; override;
  public
    constructor Create(AItemDad: TPGItem; AName: string = ''); overload;
    destructor Destroy(); override;
    procedure Frame(AParent: TObject); override;
    property PasswordFrame: string read FPassword write FPassword;
  published
    property FileName: string read FFileName write FFileName;
    property Password: string write FPassword;
    property SavePassword: Boolean read FSavePassword write FSavePassword;
    property isFileName: Boolean read GetIsFileName;
    property isPassword: Boolean read GetIsPassword;
  end;
{$TYPEINFO ON}

implementation

uses
  System.Classes, System.SysUtils,
  PGofer.Files.Encrypt,
  PGofer.Files.Controls, PGofer.Sintatico, PGofer.VaultFolder.Frame,
  PGofer.VaultFolder.KeyStore;

{ TPGVaultFolder }

constructor TPGVaultFolder.Create(AItemDad: TPGItem; AName: string);
begin
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

function TPGVaultFolder.BeforeXMLLoad(ItemCollect: TPGItemCollect): Boolean;
var
  XMLStream : TStream;
begin
  Result := False;

  if (Self.GetIsFileName) and (FFileID = TGUID.Empty) then
    FFileID := KeyStoreIDFromFile(FFileName);

  if (FSavePassword) and (FPassword = '') and (FFileID <> TGUID.Empty) then
    FPassword := KeyStoreLoadPassoword(FFileID);

  if (not FLocked) and (Self.isValid) then
  begin
    FLocked := True;
    XMLStream := KeyStoreXMLFromAES(FFileName, FPassword);
    try
      if Assigned(XMLStream) then
      begin
        ItemCollect.XMLLoadFromStream(Self, XMLStream);
      end else begin
        raise Exception.Create('Senha incorreta ou arquivo corrompido.');
      end;
      FLocked := False;
    finally
      XMLStream.Free;
    end;
  end;
  //inherited SetLocked(FLocked);
end;

function TPGVaultFolder.BeforeXMLSave(ItemCollect: TPGItemCollect): Boolean;
var
  XMLStream: TStream;
begin
  Result := False;
  if (not FLocked) and (FFileName <> '') and (GetIsPassword) then
  begin
    XMLStream := TMemoryStream.Create();
    try
      ItemCollect.XMLSaveToStream(Self, XMLStream);
      if Assigned(XMLStream) then
      begin
        FFileID := KeyStoreSavePassword(FFileID, FPassword );
        if not KeyStoreXMLToAES(XMLStream, FFileName, FPassword, FFileID) then
           raise Exception.Create('Falha na criptografia AES ao salvar.');
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

function TPGVaultFolder.GetIsFileName: Boolean;
begin
  Result := FileExists( FileExpandPath( FFileName ) );
end;

function TPGVaultFolder.GetIsPassword: Boolean;
begin
  Result := ( (FPassword <> '') and ( Length(FPassword) >= 6 ) {and ....});
end;

function TPGVaultFolder.GetIsValid: Boolean;
begin
  Result := ( GetIsFileName() and GetIsPassword() );
end;

procedure TPGVaultFolder.SetLocked(AValue: Boolean);
begin
   if (AValue <> (FLocked)) then
   begin
      FLocked := AValue;
      if (not FLocked) and (Self.isValid) then
      begin
        Self.BeforeXMLLoad( TriggersCollect );
      end else begin
        Self.Clear;
        inherited SetLocked(True);
      end;
   end;
end;

initialization

TriggersCollect.RegisterClass('VaultFolder', TPGVaultFolder);

finalization

end.
