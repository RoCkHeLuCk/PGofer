unit PGofer.Triggers.VaultFolder;

interface

uses
  System.Generics.Collections,
  Vcl.ExtCtrls,
  PGofer.Core, PGofer.Classes, PGofer.Runtime,
  PGofer.Triggers.Collections, PGofer.Triggers;

type
  [TPGClassReg('Defines', 'VaultDef')]
  TPGVaultFolder = class(TPGTriggerFolder)
  private
    FFileName: string;
    FFileID: TGUID;
    FPassword: string;
    FSavePassword: Boolean;
    FAutoLock: Integer;
    FLastAccess: TDateTime;
    FLoading: Boolean;

    procedure SetSavePassword(const Value: Boolean);
    procedure SetPassword(const Value: string);
    procedure SetAutoLockMinutes(const Value: Integer);
    procedure SetFileName(const Value: string);
    function TryResolvePassword(const AInteractive: Boolean): Boolean;

    class var FKeyStoreFile: String;
    class var FVaultList: TList<TPGVaultFolder>;
    class var FTimer: TTimer;
    class procedure OnTimerTick(Sender: TObject);
  protected
    class function GetFrameClass(): TPGItemFrameClass; override;
    procedure SetLocked(const AValue:Boolean); override;
  public
    class function OnDropFile(const AItemDad: TPGItem; const AFileName: String ): boolean; override;
    class function ClassNameEx(): String; override;
    class property KeyStoreFile: String read FKeyStoreFile write FKeyStoreFile;

    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
    destructor Destroy(); override;

    procedure BeforeAccess(); override;
    procedure Clear(); override;

    function BeforeXMLLoad(const ItemCollect: TPGItemCollectTrigger): Boolean; override;
    function BeforeXMLSave(const ItemCollect: TPGItemCollectTrigger): Boolean; override;
    function RequestPassword(const AChange: Boolean ): Boolean;

    function GetIsFileCan(): Boolean;
    function GetIsFileReal(): Boolean;
    function GetIsPassword(): Boolean;
    function GetIsValid(): Boolean;
  published
    property _FileName: string read FFileName write SetFileName;
    property _Password: string write SetPassword;
    property _SavePassword: Boolean read FSavePassword write SetSavePassword;
    property _AutoLock: Integer read FAutoLock write SetAutoLockMinutes;
    property _Locked: Boolean read GetLocked write SetLocked;
  end;

  procedure Initialize();
  procedure Finalize();

implementation

uses
  System.Classes, System.SysUtils, System.StrUtils, System.DateUtils,
  Vcl.Forms, Vcl.Controls,
  PGofer.Files.Controls, PGofer.Triggers.VaultFolder.Frame,
  PGofer.Triggers.VaultFolder.KeyStore,
  PGofer.Triggers.VaultFolder.Password.Form;

{ TPGVaultFolder }

procedure Initialize();
begin
  TPGVaultFolder.FKeyStoreFile := TPGKernel.PathData + 'KeyStore.pgk';
  TPGVaultFolder.FVaultList := TList<TPGVaultFolder>.Create;
  TPGVaultFolder.FTimer := TTimer.Create(nil);
  TPGVaultFolder.FTimer.Interval := 30000;
  TPGVaultFolder.FTimer.OnTimer := TPGVaultFolder.OnTimerTick;
  TPGVaultFolder.FTimer.Enabled := False;
end;

procedure Finalize();
begin
  TPGVaultFolder.FTimer.Enabled := False;
  TPGVaultFolder.FTimer.Free;
  TPGVaultFolder.FTimer := nil;
  TPGVaultFolder.FVaultList.Free;
  TPGVaultFolder.FVaultList := nil;

  {$IFDEF DEBUG}
  {$ENDIF}
end;

class procedure TPGVaultFolder.OnTimerTick(Sender: TObject);
var
  LVault: TPGVaultFolder;
  LHasActive: Boolean;
begin
  if (not Assigned(FVaultList)) or TPGKernel.Finalized then
    Exit;

  LHasActive := False;
  for LVault in FVaultList do
    if (not LVault._Locked) and (LVault._AutoLock > 0) then
    begin
      LHasActive := True;
      if MinutesBetween(Now, LVault.FLastAccess) >= LVault._AutoLock then
        LVault.SetLocked(True);
    end;
  FTimer.Enabled := LHasActive;
end;


class function TPGVaultFolder.OnDropFile(const AItemDad: TPGItem; const AFileName: String): boolean;
var
  LVaultFoder : TPGVaultFolder;
begin
  Result := False;
  if MatchText(ExtractFileExt(AFileName), ['.pgv']) then
  begin
    LVaultFoder := TPGVaultFolder.Create( AItemDad, FileExtractOnlyFileName( AFileName ) );
    LVaultFoder._FileName := FileUnExpandPath( AFileName );
    Result := True;
  end;
end;

class function TPGVaultFolder.ClassNameEx(): String;
begin
  inherited ClassNameEx();
  Result := 'VaultFolder';
end;

procedure TPGVaultFolder.Clear();
var
  I: Integer;
begin
  Self.CollectDad.BeginUpdate;
  try
    // Varre de trás para frente para não bugar o índice
    for I := Self.Count - 1 downto 0 do
    begin
      // SÓ deleta o que NÃO é interno (ignora _FileName, _Locked, etc.)
      if not (pgfInternal in Self[I].Flags) then
        Self.Delete(I);
    end;
  finally
    Self.CollectDad.EndUpdate;
  end;
end;

constructor TPGVaultFolder.Create(const AItemDad: TPGItem; const AName: string );
begin
  FLoading := True;
  FFileName := '';
  FPassword := '';
  FSavePassword := False;
  FAutoLock := 0;
  inherited Create(AItemDad, AName);
  inherited SetLocked(True);
  Self.Invalid := True;
  FVaultList.Add(Self);
end;

destructor TPGVaultFolder.Destroy();
begin
  if Assigned(FVaultList) then
    FVaultList.Remove(Self);

  FAutoLock := 0;
  FSavePassword := False;
  FPassword := '';
  FFileName := '';
  inherited Destroy( );
end;

class function TPGVaultFolder.GetFrameClass: TPGItemFrameClass;
begin
  Result := TPGVaultFolderFrame;
end;

procedure TPGVaultFolder.BeforeAccess();
begin
  inherited BeforeAccess;

  FLastAccess := Now();

  if FAutoLock > 0 then
    FTimer.Enabled := True;

  if Self.Locked then
    Self.SetLocked(False);
end;

function TPGVaultFolder.RequestPassword(const AChange: Boolean): Boolean;
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
              Self._Password := LPassNew;
              LResult := True;
            end
            else
              TPGKernel.ConsoleTr('Error_VaultSave', [FFileName]);
          end else begin
            Self.FPassword := LPassUser;
            LResult := Self.GetisPassword;
          end;

          if not LResult then
          begin
            TPGKernel.ConsoleTr('Error_VaultPassword', [Self.Name]);
            FPassword := '';
          end;
        end;
      finally
        LFrmPassword.Free();
      end;
    end,
    True
  );

  Result := LResult;
end;

function TPGVaultFolder.BeforeXMLLoad(const ItemCollect: TPGItemCollectTrigger): Boolean;
var
  XMLStream : TStream;
begin
  // O BeforeXMLLoad e BeforeXMLSave tem que retornar "False" para o Vault ser dono dos seus itens.
  // Se ele retornar true, o collect vai salvar os itens dentro do xml descriptografado!
  Result := False;

  if FLoading then
  begin
    FLoading := False;

    if (Self.Locked) or (FAutoLock <> 0)
    or (not FSavePassword) or (not TryResolvePassword(False)) then
    begin
      inherited SetLocked(True);
      Exit;
    end;
  end;

  if (not Self._Locked) and (Self.GetIsFileReal) then
  begin
    if not TryResolvePassword(True) then
    begin
       inherited SetLocked(True);
       Exit;
    end;

    XMLStream := KeyStoreXMLFromAES(FFileName, FPassword);
    try
      try
        Self.BeforeAccess;
        if Assigned(XMLStream) then
          ItemCollect.XMLLoadFromStream(Self, XMLStream);
      except
        TPGKernel.ConsoleTr('Error_VaultLoad',[FFileName]);
        FPassword := '';
        inherited SetLocked(True);
      end;
    finally
      XMLStream.Free;
    end;
  end;
end;

function TPGVaultFolder.BeforeXMLSave(const ItemCollect: TPGItemCollectTrigger): Boolean;
var
  XMLStream: TStream;
begin
  // O BeforeXMLLoad e BeforeXMLSave tem que retornar "False" para o Vault ser dono dos seus itens.
  // Se ele retornar true, o collect vai salvar os itens dentro do xml descriptografado!
  Result := False;

  if (not Self._Locked) and (Self.GetIsValid) then
  begin
    XMLStream := TMemoryStream.Create();
    try
      ItemCollect.XMLSaveToStream(Self, XMLStream);
      if Assigned(XMLStream) then
      begin
        if not KeyStoreXMLToAES(XMLStream, FFileName, FPassword, FFileID) then
        begin
           TPGKernel.ConsoleTr('Error_VaultSave',[FFileName]);
           FPassword := '';
        end;
      end;
    finally
      XMLStream.Free;
    end;
  end;
end;

function TPGVaultFolder.GetIsFileCan(): Boolean;
begin
  Result := DirectoryExistsFileEx( FFileName );
end;

function TPGVaultFolder.GetIsFileReal(): Boolean;
begin
  Result := FileExistsEx( FFileName );
end;

function TPGVaultFolder.GetIsPassword(): Boolean;
begin
  Result := ( (FPassword <> '') and ( Length(FPassword) >= 6 ) {and ....});
end;

function TPGVaultFolder.GetIsValid(): Boolean;
begin
  Result := ( GetIsFileCan() and GetIsPassword());
end;

procedure TPGVaultFolder.SetAutoLockMinutes(const Value: Integer);
begin
  FAutoLock := Value;
  FTimer.Enabled := FTimer.Enabled or (FAutoLock > 0);
end;

procedure TPGVaultFolder.SetFileName(const Value: string);
begin
  FFileName := Value;
  Self.Invalid := not Self.GetIsFileCan();
end;

function TPGVaultFolder.TryResolvePassword(const AInteractive: Boolean): Boolean;
begin
  if GetisPassword then
    Exit(True);

  if FSavePassword then
  begin
    if (Self.GetIsFileReal) and (FFileID = TGUID.Empty) then
      FFileID := KeyStoreIDFromFile(FFileName);

    if (FFileID <> TGUID.Empty) then
    begin
      FPassword := KeyStoreLoadPassoword(FFileID);
      if GetisPassword then
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
  if (AValue = Self._Locked) or Destroying then Exit;

  if FLoading then
  begin
    inherited SetLocked(AValue);
    Exit;
  end;

  if AValue then
  begin
    Self.BeforeXMLSave(TriggersCollect);
    Self.Clear;
    if not FSavePassword then
      FPassword := '';
    inherited SetLocked(True);
  end else begin
    if Self.TryResolvePassword(True) then
    begin
      inherited SetLocked(False);
      Self.BeforeXMLLoad( TriggersCollect );
    end else begin
      if not FSavePassword then
        FPassword := '';
      inherited SetLocked(True);
    end;
  end;
end;

procedure TPGVaultFolder.SetPassword(const Value: string);
begin
  FPassword := Value;

  if (FPassword <> '') and FSavePassword then
  begin
    if (FFileID = TGUID.Empty) and GetIsFileReal then
      FFileID := KeyStoreIDFromFile(FFileName);
    FFileID := KeyStoreSavePassword(FFileID, FPassword);
  end;
end;

procedure TPGVaultFolder.SetSavePassword(const Value: Boolean);
begin
  if FSavePassword = Value then
    Exit;

  FSavePassword := Value;

  if FLoading then
    Exit;

  if not FSavePassword then
  begin
    if FFileID <> TGUID.Empty then
       KeyStoreSavePassword(FFileID, '');
    FPassword := '';
    Exit;
  end;


  if not TryResolvePassword(True) then
  begin
    FSavePassword := False;
    Exit;
  end;

  if (FFileID = TGUID.Empty) and GetIsFileReal then
    FFileID := KeyStoreIDFromFile(FFileName);

  if GetIsPassword then
    FFileID := KeyStoreSavePassword(FFileID, FPassword);
end;

initialization

finalization

end.
