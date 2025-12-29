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
    FLocked: Boolean;
    FPassword: string;
    FSavePassword: Boolean;
    function GetPassword(): string;
  protected
    function BeforeXMLSave(ItemCollect: TPGItemCollect): Boolean; override;
    function BeforeXMLLoad(ItemCollect: TPGItemCollect): Boolean; override;
  public
    constructor Create(AItemDad: TPGItem; AName: string = ''); overload;
    destructor Destroy(); override;
    procedure Frame(AParent: TObject); override;
    property Locked: Boolean read FLocked;
    procedure Updade();
  published
    property Password: string read GetPassword write FPassword;
    property FileName: string read FFileName write FFileName;
    property SavePassword: Boolean read FSavePassword write FSavePassword;
  end;
{$TYPEINFO ON}

implementation

uses
  System.Classes, System.SysUtils,
  PGofer.Files.Encrypt,
  PGofer.Sintatico, PGofer.VaultFolder.Frame;

{ TPGVaultFolder }

function TPGVaultFolder.BeforeXMLLoad(ItemCollect: TPGItemCollect): Boolean;
var
  Stream: TStream;
begin
  Result := False;
  FLocked := True;
  if (FPassword <> '') and (FileExists(FFileName)) then
  begin
    Stream := AESDecryptFileToStream(FFileName, FPassword);
    if Assigned(Stream) then
    begin
      Stream.Position := 0;
      ItemCollect.XMLLoadFromStream(Self, Stream);
      Stream.Free;
      FLocked := False;
    end
    else
      raise Exception.Create('Senha incorreta ou arquivo corrompido.');
  end;
end;

function TPGVaultFolder.BeforeXMLSave(ItemCollect: TPGItemCollect): Boolean;
var
  Stream: TStream;
begin
  Result := False;
  if (not FLocked) and (FPassword <> '') and (FFileName <> '') then
  begin
    Stream := TMemoryStream.Create();
    ItemCollect.XMLSaveToStream(Self, Stream);
    Stream.Position := 0;
    if not AESEncryptStreamToFile(Stream, FFileName, FPassword) then
      raise Exception.Create('Falha na criptografia AES ao salvar.');
    Stream.Free;
  end;
end;

constructor TPGVaultFolder.Create(AItemDad: TPGItem; AName: string);
begin
  inherited Create(AItemDad, AName);
  FFileName := '';
  FLocked := True;
  FPassword := '';
  FSavePassword := False;
end;

destructor TPGVaultFolder.Destroy();
begin
  FFileName := '';
  FLocked := True;
  FPassword := '';
  FSavePassword := False;
  inherited Destroy();
end;

procedure TPGVaultFolder.Frame(AParent: TObject);
begin
  inherited Frame(AParent);
  TPGVaultFolderFrame.Create(Self, AParent);
end;

function TPGVaultFolder.GetPassword( ): string;
begin
  Result := '';
  if FSavePassword then
    Result := FPassword;
end;

procedure TPGVaultFolder.Updade( );
begin
  if FLocked then
  begin
    Self.BeforeXMLLoad( TriggersCollect );
  end else begin
    Self.Clear;
    FLocked := True;
  end;
end;

initialization

TriggersCollect.RegisterClass('VaultFolder', TPGVaultFolder);

finalization

end.
