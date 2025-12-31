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
    FPassword: string;
    FSavePassword: Boolean;
    function GetPassword(): string;
    function GetIsFileName(): Boolean;
    function GetIsPassword(): Boolean;
  protected
    function BeforeXMLSave(ItemCollect: TPGItemCollect): Boolean; override;
    function BeforeXMLLoad(ItemCollect: TPGItemCollect): Boolean; override;
    procedure SetLocked(AValue:Boolean); override;
    function GetIsValid( ): Boolean; override;
  public
    constructor Create(AItemDad: TPGItem; AName: string = ''); overload;
    destructor Destroy(); override;
    procedure Frame(AParent: TObject); override;
  published
    property Password: string read GetPassword write FPassword;
    property FileName: string read FFileName write FFileName;
    property SavePassword: Boolean read FSavePassword write FSavePassword;
    property isFileName: Boolean read GetIsFileName;
    property isPassword: Boolean read GetIsPassword;
  end;
{$TYPEINFO ON}

implementation

uses
  System.Classes, System.SysUtils,
  PGofer.Files.Encrypt,
  PGofer.Files.Controls, PGofer.Sintatico, PGofer.VaultFolder.Frame;

{ TPGVaultFolder }

constructor TPGVaultFolder.Create(AItemDad: TPGItem; AName: string);
begin
  inherited Create(AItemDad, AName);
  FFileName := '';
  FPassword := '';
  FSavePassword := False;
  inherited SetLocked( True );
end;

destructor TPGVaultFolder.Destroy();
begin
  inherited SetLocked( True );
  FSavePassword := False;
  FPassword := '';
  FFileName := '';
  inherited Destroy();
end;

function TPGVaultFolder.BeforeXMLLoad(ItemCollect: TPGItemCollect): Boolean;
var
  Stream: TStream;
begin
  Result := False;
  if (not FLocked) and (Self.isValid) then
  begin
    FLocked := True;
    Stream := AESDecryptFileToStream(FFileName, FPassword);
    if Assigned(Stream) then
    begin
      Stream.Position := 0;
      ItemCollect.XMLLoadFromStream(Self, Stream);
      Stream.Free;
      FLocked := False;
    end else begin
      raise Exception.Create('Senha incorreta ou arquivo corrompido.');
    end;
  end;
  inherited SetLocked(FLocked);
end;

function TPGVaultFolder.BeforeXMLSave(ItemCollect: TPGItemCollect): Boolean;
var
  Stream: TStream;
begin
  Result := False;
  if (FFileName <> '') and ( (not FLocked) or (not Self.GetIsFileName())) then
  begin
    Stream := TMemoryStream.Create();
    try
      ItemCollect.XMLSaveToStream(Self, Stream);
      Stream.Position := 0;
      if not AESEncryptStreamToFile(Stream, FFileName, FPassword) then
        raise Exception.Create('Falha na criptografia AES ao salvar.');
    finally
      Stream.Free;
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

function TPGVaultFolder.GetPassword( ): string;
begin
  Result := '';
  if FSavePassword then
    Result := FPassword;
end;

procedure TPGVaultFolder.SetLocked(AValue: Boolean);
begin
   if (Self.isValid) and (AValue <> (FLocked)) then
   begin
      FLocked := AValue;
      if not FLocked then
      begin
        Self.BeforeXMLLoad( TriggersCollect );
      end else begin
        Self.Clear;
        if not FSavePassword then
          FPassword := '';
        inherited SetLocked(True);
      end;
   end;
end;

initialization

TriggersCollect.RegisterClass('VaultFolder', TPGVaultFolder);

finalization

end.
