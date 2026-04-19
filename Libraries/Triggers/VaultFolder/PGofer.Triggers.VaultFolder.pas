unit PGofer.Triggers.VaultFolder;

interface

uses
  System.Generics.Collections,
  Vcl.ExtCtrls,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico,
  PGofer.Triggers.Collections, PGofer.Triggers;

type
  {$M+}
  TPGVaultFolder = class(TPGFolderMirror)
  private
    FFileName: string;
    FFileID: TGUID;
    FPassword: string;
    FSavePassword: Boolean;
    FAutoLock: Integer;
    FLastAccess: TDateTime;
    FLoading: Boolean;

    function GetIsFileCan(): Boolean;
    function GetIsFileReal(): Boolean;
    function GetIsPassword(): Boolean;
    procedure SetSavePassword(const Value: Boolean);
    procedure SetPassword(const Value: string);
    procedure SetAutoLockMinutes(const Value: Integer);
    function TryResolvePassword(AInteractive: Boolean): Boolean;

    class var FKeyStoreFile: String;
    class var FVaultList: TList<TPGVaultFolder>;
    class var FTimer: TTimer;
    class procedure OnTimerTick(Sender: TObject);
  protected
    procedure SetLocked(const AValue:Boolean); override;
    function GetIsValid(): Boolean; override;
  public
    class constructor Create();
    class destructor Destroy();
    class function OnDropFile( AItemDad: TPGItem; AFileName: String ): boolean; override;
    class function ClassNameEx(): String; override;
    class property KeyStoreFile: String read FKeyStoreFile write FKeyStoreFile;

    constructor Create( AItemDad: TPGItem; AName: string); override;
    destructor Destroy(); override;

    procedure BeforeAccess(); override;
    procedure Frame(AParent: TObject); override;
    function BeforeXMLLoad(ItemCollect: TPGItemCollectTrigger): Boolean; override;
    function BeforeXMLSave(ItemCollect: TPGItemCollectTrigger): Boolean; override;
    function RequestPassword( AChange: Boolean ): Boolean;
  published
    property FileName: string read FFileName write FFileName;
    property Password: string write SetPassword;
    property SavePassword: Boolean read FSavePassword write SetSavePassword;
    property isFileName: Boolean read GetIsFileCan;
    property isPassword: Boolean read GetIsPassword;
    property AutoLock: Integer read FAutoLock write SetAutoLockMinutes;
  end;
  {$TYPEINFO ON}

implementation

uses
  System.Classes, System.SysUtils, System.StrUtils, System.DateUtils,
  Vcl.Forms, Vcl.Controls,
  PGofer.Runtime,
  PGofer.Files.Controls, PGofer.Triggers.VaultFolder.Frame,
  PGofer.Triggers.VaultFolder.KeyStore,
  PGofer.Triggers.VaultFolder.Password.Form;

{ TPGVaultFolder }

class constructor TPGVaultFolder.Create();
begin
  FKeyStoreFile := TPGKernel.PathCurrent + 'KeyStore.pgk';
  FVaultList := TList<TPGVaultFolder>.Create;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 30000;
  FTimer.OnTimer := OnTimerTick;
  FTimer.Enabled := False;
end;

class destructor TPGVaultFolder.Destroy();
begin
  if Assigned(FTimer) then
  begin
    FTimer.Enabled := False;
    FTimer.Free;
  end;

  if Assigned(FVaultList) then
    FVaultList.Free;
end;

class procedure TPGVaultFolder.OnTimerTick(Sender: TObject);
var
  LVault: TPGVaultFolder;
  LHasActive: Boolean;
begin
  LHasActive := False;
  for LVault in FVaultList do
    if (not LVault._Locked) and (LVault.AutoLock > 0) then
    begin
      LHasActive := True;
      if MinutesBetween(Now, LVault.FLastAccess) >= LVault.AutoLock then
        LVault.SetLocked(True);
    end;
  FTimer.Enabled := LHasActive;
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

class function TPGVaultFolder.ClassNameEx(): String;
begin
  Result := 'VaultFolder';
end;

constructor TPGVaultFolder.Create( AItemDad: TPGItem; AName: string );
begin
  FLoading := True;
  inherited Create(AItemDad, AName);
  FFileName := '';
  FPassword := '';
  FSavePassword := False;
  FAutoLock := 0;
  Self.SetLockedForced( True );
  FVaultList.Add(Self);
end;

destructor TPGVaultFolder.Destroy();
begin
  FVaultList.Remove(Self);
  Self.SetLockedForced( False );
  FAutoLock := 0;
  FSavePassword := False;
  FPassword := '';
  FFileName := '';
  inherited Destroy( );
end;

procedure TPGVaultFolder.BeforeAccess();
begin
  inherited BeforeAccess;

  if FAutoLock > 0 then
  begin
    FLastAccess := Now();
    FTimer.Enabled := True;
  end;

  Self.SetLocked(False);
end;

function TPGVaultFolder.RequestPassword(AChange: Boolean): Boolean;
var
  LFrmPassword: TFrmVaultFolderPassword;
  LPassUser, LPassNew: String;
  LResult: Boolean;
begin
  LResult := False;

  RunInMainThread(
    procedure
    begin
      LFrmPassword := TFrmVaultFolderPassword.Create( Application.MainForm );
      LFrmPassword.PnlNewPassword.Visible := AChange;
      try
        if LFrmPassword.ShowModal = mrOk then
        begin
          LPassUser := LFrmPassword.EdtCurrentPassword.Text;
          LPassNew  := LFrmPassword.EdtNewPassword.Text;

          if AChange then
          begin
            if KeyStoreChangeFilePassword(FFileName, LPassUser, LPassNew, FFileID) then
            begin
              Self.Password := LPassNew;
              LResult := True;
            end
            else
              TPGKernel.ConsoleTr('Error_VaultSave', [FFileName]);
          end else begin
            Self.FPassword := LPassUser;
            LResult := Self.isPassword;
          end;

          if not LResult then
            TPGKernel.ConsoleTr('Error_VaultPassword', [Self.Name]);
        end;
      finally
        LFrmPassword.Free();
      end;
    end,
    True
  );

  Result := LResult;
end;

function TPGVaultFolder.BeforeXMLLoad(ItemCollect: TPGItemCollectTrigger): Boolean;
var
  XMLStream : TStream;
begin
  Result := False;

  if FLoading then
  begin
    FLoading := False;
    if not FSavePassword then
     Self.SetLockedForced( True );
    Exit;
  end;

  if (not Self._Locked) and (Self.GetIsFileReal) then
  begin
    if not TryResolvePassword(True) then
    begin
       Self.SetLockedForced( True );
       Exit;
    end;

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

procedure TPGVaultFolder.SetAutoLockMinutes(const Value: Integer);
begin
  FAutoLock := Value;
  FTimer.Enabled := FTimer.Enabled or (FAutoLock > 0);
end;

function TPGVaultFolder.TryResolvePassword(AInteractive: Boolean): Boolean;
begin
  if isPassword then
    Exit(True);

  if FSavePassword then
  begin
    if (Self.GetIsFileReal) and (FFileID = TGUID.Empty) then
      FFileID := KeyStoreIDFromFile(FFileName);

    if (FFileID <> TGUID.Empty) then
    begin
      FPassword := KeyStoreLoadPassoword(FFileID);
      if isPassword then
        Exit(True);
    end;
  end;

  if AInteractive then
    Result := Self.RequestPassword(False)
  else
    Result := False;
end;

procedure TPGVaultFolder.SetLocked(const AValue: Boolean);
begin
  if AValue = Self._Locked then Exit;

  if FLoading then
  begin
    Self.SetLockedForced(AValue);
    Exit;
  end;

  if AValue then
  begin
    Self.BeforeXMLSave(TriggersCollect);
    Self.Clear;
    FPassword := '';
    Self.SetLockedForced( True );
  end else begin
    Self.SetLockedForced( False );
    Self.BeforeXMLLoad( TriggersCollect );
  end;

  inherited SetLocked( Self._Locked );
end;

procedure TPGVaultFolder.SetPassword(const Value: string);
begin
  if (FPassword = Value) then
    Exit;

  FPassword := Value;

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
end;

initialization
   TriggersCollect.RegisterClass( TPGVaultFolder );

finalization

end.
