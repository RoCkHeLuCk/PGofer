unit PGofer.Triggers;

interface

uses
  System.Generics.Collections,
  PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers.Collections, PGofer.Triggers.Frame;

type
  TPGTriggerFrameType = class of TPGTriggerFrame;

  TPGItemTrigger = class(TPGItemClass)
  protected
    function GetMaxOverlayFlag(): TPGItemFlag; override;
    procedure SetName(const AName: string); override;
    procedure SetParent(const AParent: TPGItem); override;
    procedure SetNamespace(const AValue: Boolean); override;
    procedure ExecuteDefault(const AGrammar: TPGGrammar); override;
    class function GetFrameType: TPGTriggerFrameType; virtual;
  public
    class function GetDefaultRoot(): TPGItem; override;
    class function OnDropFile(const AItemDad: TPGItem; const AFileName: string): Boolean; virtual;

    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
    procedure Frame(const AParent: TObject); override;
    procedure Triggering(); virtual; abstract;
  end;

  TPGTriggerFolder = class(TPGFolder)
  protected
    procedure SetName(const AName: string); override;
    procedure SetParent(const AParent: TPGItem); override;
    procedure SetNamespace(const AValue: Boolean); override;
  public
    class function OnDropFile(const AItemDad: TPGItem; const AFileName: string): Boolean; virtual;
    class function ClassNameEx(): string; override;

    constructor Create(const AItemDad: TPGItem; const AName: string); override;
    procedure Frame(const AParent: TObject); override;
    function BeforeXMLSave(const ItemCollect: TPGItemCollectTrigger): Boolean; virtual;
    function BeforeXMLLoad(const ItemCollect: TPGItemCollectTrigger): Boolean; virtual;
  published
    property _Namespace: Boolean read GetNamespace write SetNamespace;
  end;

  procedure Initialize();
  procedure Finalize();
  function CalculateUniqueName(AItem: TPGItem; const AOriginName: string): string;

var
  TriggersCollect: TPGItemCollectTrigger;

implementation

uses
  System.SysUtils, PGofer.Key.Controls, PGofer.Triggers.Folder.Frame;

procedure Initialize();
begin
  TriggersCollect := TPGItemCollectTrigger.Create(nil, 'Triggers');
  TriggersCollect.HiddeInternal := True;
  TriggersCollect.RegisterClass(TPGTriggerFolder);
end;

procedure Finalize();
begin
  TriggersCollect.Free;
  TriggersCollect := nil;
  {$IFDEF DEBUG}
  {$ENDIF}
end;

function CalculateUniqueName(AItem: TPGItem; const AOriginName: string): string;
var
  LBaseName, ResultName: string;
  LCount: Integer;
  LCollision, LScope: TPGItem;
begin
  LBaseName := NormalizeID(AOriginName);
  if LBaseName = '' then LBaseName := 'New' + AItem.ClassNameEx;
  ResultName := LBaseName;

  LScope := AItem.Parent;
  while Assigned(LScope) do
  begin
    if (LScope is TPGItemCollect) or (pgfNamespace in LScope.Flags) then Break;
    LScope := LScope.Parent;
  end;

  if Assigned(LScope) then
  begin
    LCount := 0;
    while True do
    begin
      LCollision := LScope.FindName(ResultName);
      if (not Assigned(LCollision)) or (LCollision = AItem) then Break;
      Inc(LCount);
      ResultName := LBaseName + IntToStr(LCount);
    end;
  end;
  Result := ResultName;
end;

{ TPGItemTrigger }

constructor TPGItemTrigger.Create(const AItemDad: TPGItem; const AName: string);
begin
  inherited Create(AItemDad, AName);
  Self.Internal := False;
  Self.Invalid := True;
  Self.HasChildren := False;
end;

procedure TPGItemTrigger.SetName(const AName: string);
begin
  inherited SetName( CalculateUniqueName(Self, AName) );
end;

procedure TPGItemTrigger.SetNamespace(const AValue: Boolean);
begin
  if (Self.Namespace = AValue) then
    Exit;

  inherited SetNamespace(AValue);
  Self.SetName( Self.Name );
end;

procedure TPGItemTrigger.SetParent(const AParent: TPGItem);
begin
  if (Self.Parent = AParent) then
    Exit;

  //aqui atualiza para ele aparecer na lista
  Self.Internal := False; //mas que achado!!!!

  inherited SetParent(AParent);
  Self.SetName( Self.Name );
end;

procedure TPGItemTrigger.ExecuteDefault(const AGrammar: TPGGrammar);
begin
  Self.Triggering();
end;

class function TPGItemTrigger.GetDefaultRoot: TPGItem;
begin
  Result := TriggersCollect;
end;

class function TPGItemTrigger.GetFrameType: TPGTriggerFrameType;
begin
  Result := TPGTriggerFrame;
end;

function TPGItemTrigger.GetMaxOverlayFlag(): TPGItemFlag;
begin
  Result := pgfReadOnly;
end;

class function TPGItemTrigger.OnDropFile(const AItemDad: TPGItem; const AFileName: string): Boolean;
begin
  Result := False;
end;

procedure TPGItemTrigger.Frame(const AParent: TObject);
begin
  Self.GetFrameType.Create(Self, AParent);
end;

{ TPGTriggerFolder }

class function TPGTriggerFolder.ClassNameEx(): string;
begin
  Result := 'Folder';
end;

constructor TPGTriggerFolder.Create(const AItemDad: TPGItem; const AName: string);
begin
  inherited Create(AItemDad, AName);
  Self.Internal := False;
end;

class function TPGTriggerFolder.OnDropFile(const AItemDad: TPGItem; const AFileName: string): Boolean;
begin
  Result := DirectoryExists(AFileName);
  if Result then
    TPGTriggerFolder.Create(AItemDad, ExtractFileName(AFileName));
end;

procedure TPGTriggerFolder.SetName(const AName: string);
begin
  inherited SetName( CalculateUniqueName(Self, AName) );
end;

procedure TPGTriggerFolder.SetNamespace(const AValue: Boolean);
begin
  if (Self.Namespace = AValue) then
    Exit;

  inherited SetNamespace(AValue);
  Self.SetName(Self.Name);
end;

procedure TPGTriggerFolder.SetParent(const AParent: TPGItem);
begin
  if (Self.Parent = AParent) then
    Exit;

  //aqui atualiza para ele aparecer na lista
  Self.Internal := False; //mas que achado!!!!

  inherited SetParent(AParent);
  Self.SetName(Self.Name);
end;

function TPGTriggerFolder.BeforeXMLSave(const ItemCollect: TPGItemCollectTrigger): Boolean;
begin
  Result := True;
end;

function TPGTriggerFolder.BeforeXMLLoad(const ItemCollect: TPGItemCollectTrigger): Boolean;
begin
  Result := True;
end;

procedure TPGTriggerFolder.Frame(const AParent: TObject);
begin
  TPGFolderFrame.Create(Self, AParent);
end;

initialization

finalization

end.
