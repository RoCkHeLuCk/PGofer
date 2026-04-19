unit PGofer.Triggers;

interface

uses
  System.Classes, System.Generics.Collections,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers.Collections, PGofer.Triggers.Frame;

type
  TPGItemMirror = class;
  TPGTriggerFrameType = class of TPGTriggerFrame;
  TPGItemTriggerType = class of TPGItemTrigger;

  TPGItemTrigger = class( TPGItemClass )
  private
    FItemMirror: TPGItemMirror;
    function GetParentNamespace(): TPGFolder;
  protected
    procedure SetName( AName: string ); override;
    procedure SetParent(AParent: TPGItem); override;
    procedure ExecuteDefault(const AGrammar: TPGGrammar); override;
    class function GetFrameType: TPGTriggerFrameType; virtual;
  public
    constructor Create( AItemMirror: TPGItemMirror; AName: string ); reintroduce; virtual;
    destructor Destroy(); override;
    property ItemMirror: TPGItemMirror read FItemMirror;
    property ParentNamespace: TPGFolder read GetParentNamespace;
    procedure Frame(AParent: TObject); override;
    procedure Triggering(); virtual; abstract;
    class function TranscendName( AName: string; AItemList: TPGItem = nil; AIgnoreItem: TPGItem = nil ): string;
  end;


  TPGItemMirror = class( TPGItem )
  private
    FItemOriginal: TPGItemTrigger;
  protected
    class function GetTriggerType: TPGItemTriggerType; virtual;
    procedure SetName(AName: string); override;
    procedure SetParent(AParent: TPGItem); override;
  public
    constructor Create( AItemDad: TPGItem; AName: string ); reintroduce; virtual;
    destructor Destroy(); override;
    property ItemOriginal: TPGItemTrigger read FItemOriginal;
    procedure Frame(AParent: TObject); override;
    class function ClassNameEx(): string; override;
    class function OnDropFile( AItemDad: TPGItem; AFileName: string ): Boolean; virtual;
  end;

  TPGFolderMirror = class;

  TPGFolderOriginal = class( TPGFolder )
  private
    FFolderMirror :TPGFolderMirror;
  protected
    procedure SetName( AName: string ); override;
  public
    constructor Create( AFolderMirror: TPGFolderMirror; AName: string ); reintroduce; virtual;
    destructor Destroy(); override;
    procedure BeforeAccess(); override;
  end;

  {$M+}
  TPGFolderMirror = class( TPGFolder )
  private
    FFolderOriginal: TPGFolder;
    FNamespace: Boolean;
    procedure SetNamespace( AValue: Boolean );
    function GetParentNamespace(): TPGFolder;
  protected
    procedure SetParent(AParent: TPGItem); override;
    procedure SetName(AName: string); override;
  public
    class function OnDropFile( AItemDad: TPGItem; AFileName: string ): Boolean; virtual;
    class function ClassNameEx(): string; override;
    constructor Create( AItemDad: TPGItem; AName: string); reintroduce; virtual;
    destructor Destroy(); override;
    property FolderOriginal: TPGFolder read FFolderOriginal;
    property ParentNamespace: TPGFolder read GetParentNamespace;
    procedure Frame( AParent: TObject ); override;
    function BeforeXMLSave(ItemCollect: TPGItemCollectTrigger): Boolean; virtual;
    function BeforeXMLLoad(ItemCollect: TPGItemCollectTrigger): Boolean; virtual;
    function TranscendName( AName: string; AItemList: TPGItem = nil ): string;
  published
    property Namespace: Boolean read FNamespace write SetNamespace;
  end;
  {$TYPEINFO ON}

var
  TriggersCollect: TPGItemCollectTrigger;
  GlobalTriggerFolder: TPGFolder;

implementation

uses
  System.SysUtils, System.RTTI, System.TypInfo,
  PGofer.Lexico, PGofer.Sintatico.Controls,
  PGofer.Key.Controls, PGofer.Triggers.Folder.Frame;

{ TPGItemTrigger }

constructor TPGItemTrigger.Create( AItemMirror: TPGItemMirror; AName: string );
var
  LParent: TPGItem;
begin
  FItemMirror := AItemMirror;
  if AName = '' then AName := 'New' + Self.ClassNameEx;

  if Assigned(FItemMirror) then
    LParent := Self.GetParentNamespace()
  else
    LParent := GlobalTriggerFolder;

  inherited Create( LParent, AName );
  Self.SystemNode := False;
  if Assigned(FItemMirror) then
     FItemMirror.Name := Self.Name;
end;

destructor TPGItemTrigger.Destroy();
begin
  if Assigned( FItemMirror ) and (not FItemMirror.Destroying) then
  begin
    FItemMirror.FItemOriginal := nil;
    FItemMirror.Free();
  end;
  FItemMirror := nil;
  inherited Destroy();
end;

procedure TPGItemTrigger.SetName( AName: string );
begin
  if Self.Name = AName then Exit;
  Self.SetNameForced( AName );
  if Assigned( FItemMirror ) then
    FItemMirror.SetNameForced( AName );
end;

class function TPGItemTrigger.TranscendName(AName: string; AItemList: TPGItem; AIgnoreItem: TPGItem): string;
var
  C: Word;
  LFound: TPGItem;
begin
  AName := RemoveCharSpecial( AName, True );
  if AName <> '' then
  begin
    if not CharInSet( AName[ LOW_STRING ], [ 'A' .. 'Z', '_', 'a' .. 'z'] ) then
      AName := 'New' + AName;
  end else
    AName := 'New';

  Result := AName;
  c := 0;
  if Assigned( AItemList ) and ( AItemList <> GlobalTriggerFolder ) then
  begin
    LFound := AItemList.FindName( Result );
    while Assigned( LFound ) do
    begin
      if (LFound = AIgnoreItem) then
         Break;
      inc( C );
      Result := AName + IntToStr( C );
      LFound := AItemList.FindName( Result );
    end;
  end else begin
    LFound := FindID( GlobalCollection, Result );
    while Assigned( LFound ) do
    begin
      if (LFound = AIgnoreItem) then
         Break;
      inc( C );
      Result := AName + IntToStr( C );
      LFound := FindID( GlobalCollection, Result );
    end;
  end;
end;

procedure TPGItemTrigger.SetParent(AParent: TPGItem);
var
  LOldParent: TPGItem;
begin
  LOldParent := Self.Parent;
  if LOldParent <> AParent then
  begin
    Self.SystemNode := False;
    Self.Name := Self.TranscendName(Self.Name, AParent, Self);
    inherited SetParent(AParent);
  end;
end;

function TPGItemTrigger.GetParentNamespace(): TPGFolder;
var
  LItem: TPGItem;
begin
   LItem := FItemMirror.Parent;
   while Assigned(LItem) do
   begin
      if (LItem is TPGFolderMirror) and TPGFolderMirror(LItem).Namespace then
         Exit( TPGFolderMirror(LItem).FFolderOriginal );
      LItem := LItem.Parent;
   end;
   Result := GlobalTriggerFolder;
end;

procedure TPGItemTrigger.ExecuteDefault(const AGrammar: TPGGrammar);
begin
  Self.Triggering();
end;

class function TPGItemTrigger.GetFrameType(): TPGTriggerFrameType;
begin
  Result := TPGTriggerFrame;
end;

procedure TPGItemTrigger.Frame(AParent: TObject);
var
  LFrameType: TPGTriggerFrameType;
begin
  LFrameType := Self.GetFrameType;
  if Assigned(LFrameType) then
    LFrameType.Create(Self, AParent)
  else
    inherited Frame(AParent);
end;

{ TPGItemMirror }

class function TPGItemMirror.OnDropFile(AItemDad: TPGItem; AFileName: string): boolean;
begin
   Result := False;
end;

class function TPGItemMirror.GetTriggerType: TPGItemTriggerType;
begin
  Result := TPGItemTrigger;
end;

class function TPGItemMirror.ClassNameEx(): string;
begin
  Result := Self.GetTriggerType.ClassNameEx();
end;

constructor TPGItemMirror.Create( AItemDad: TPGItem; AName: string );
begin
  inherited Create( AItemDad, AName );
  Self.SystemNode := False;
  FItemOriginal := Self.GetTriggerType.Create( Self, AName );
end;

destructor TPGItemMirror.Destroy();
begin
  if Assigned( FItemOriginal ) and (not FItemOriginal.Destroying) then
  begin
    FItemOriginal.FItemMirror := nil;
    FItemOriginal.Free;
  end;
  FItemOriginal := nil;
  inherited Destroy();
end;

procedure TPGItemMirror.SetName(AName: string);
begin
  Self.SetNameForced(AName);
  if Assigned( FItemOriginal ) then
    FItemOriginal.SetNameForced(AName);
end;

procedure TPGItemMirror.SetParent(AParent: TPGItem);
var
  LOldParent: TPGItem;
begin
  LOldParent := Self.Parent;
  inherited SetParent(AParent);
  if (LOldParent <> AParent) and Assigned(FItemOriginal) then
  begin
    FItemOriginal.Parent := FItemOriginal.GetParentNamespace();
  end;
end;

procedure TPGItemMirror.Frame(AParent: TObject);
begin
  if Assigned(FItemOriginal) then
    FItemOriginal.Frame(AParent);
end;

{ TPGFolderOriginal }

constructor TPGFolderOriginal.Create( AFolderMirror: TPGFolderMirror; AName: string );
begin
  inherited Create(GlobalTriggerFolder, AName);
  FFolderMirror := AFolderMirror;
end;

destructor TPGFolderOriginal.Destroy;
begin
  if Assigned( FFolderMirror ) and (not FFolderMirror.Destroying) then
  begin
    FFolderMirror.FFolderOriginal := nil;
    FFolderMirror.Free();
  end;
  FFolderMirror := nil;
  inherited Destroy();
end;

procedure TPGFolderOriginal.SetName(AName: string);
begin
  if Self.Name = AName then Exit;
  Self.SetNameForced(AName);
  if Assigned(FFolderMirror) then
    FFolderMirror.SetNameForced(AName);
end;

procedure TPGFolderOriginal.BeforeAccess();
begin
  inherited BeforeAccess;
  if Assigned( FFolderMirror ) then
     FFolderMirror.BeforeAccess();
end;

{ TPGFolderMirror }

constructor TPGFolderMirror.Create( AItemDad: TPGItem; AName: string );
begin
  if AName = '' then AName := 'New' + Self.ClassNameEx;
  AName := Self.TranscendName(AName, AItemDad);
  inherited Create( AItemDad, AName );
  Self.SystemNode := False;
  FFolderOriginal := GlobalTriggerFolder;
  FNamespace := False;
end;

destructor TPGFolderMirror.Destroy( );
begin
  Self.Clear;

  if Assigned(FFolderOriginal) and (FFolderOriginal <> GlobalTriggerFolder)
  and (not FFolderOriginal.Destroying) then
    FFolderOriginal.Free;
  FFolderOriginal := nil;
  FNamespace := False;
  Self._Locked := False;
  Self._Expanded := False;
  inherited Destroy( );
end;

procedure TPGFolderMirror.Frame(AParent: TObject);
begin
  TPGFolderFrame.Create( Self, AParent );
end;

function TPGFolderMirror.BeforeXMLSave(ItemCollect: TPGItemCollectTrigger): Boolean;
begin
  Result := True;
end;

function TPGFolderMirror.BeforeXMLLoad(ItemCollect: TPGItemCollectTrigger): Boolean;
begin
  Result := True;
end;

class function TPGFolderMirror.OnDropFile(AItemDad: TPGItem; AFileName: String): boolean;
begin
  Result := DirectoryExists(AFileName);
  if Result then
  begin
    TPGFolderOriginal.Create( TPGFolderMirror(AItemDad), ExtractFileName(AFileName));
  end;
end;

class function TPGFolderMirror.ClassNameEx: String;
begin
  Result := 'Folder';
end;

procedure TPGFolderMirror.SetNamespace(AValue: Boolean);
var
  LItem : TPGFolder;

  // Fun��o interna para mover recursivamente os originais pela �rvore de execu��o
  procedure MoveOriginalsTo(AMirrorFolder: TPGItem; ANewParentNamespace: TPGFolder);
  var
    LChild: TPGItem;
  begin
    for LChild in AMirrorFolder do
    begin
      if LChild is TPGItemMirror then
      begin
        // Se for um trigger comum, move o Original dele para o novo Namespace
        if Assigned(TPGItemMirror(LChild).ItemOriginal) then
          TPGItemMirror(LChild).ItemOriginal.Parent := ANewParentNamespace;
      end
      else if LChild is TPGFolderMirror then
      begin
        // Se a subpasta TAMB�M for um namespace, movemos a pasta Original dela inteira
        if TPGFolderMirror(LChild).Namespace then
        begin
          if Assigned(TPGFolderMirror(LChild).FolderOriginal) and
             (TPGFolderMirror(LChild).FolderOriginal <> GlobalTriggerFolder) then
            TPGFolderMirror(LChild).FolderOriginal.Parent := ANewParentNamespace;
        end
        else
        begin
          // Se for uma pasta comum (sem namespace), ela � "transparente" na execu��o.
          // Ent�o, entramos nela recursivamente para mover os filhos l�gicos.
          MoveOriginalsTo(LChild, ANewParentNamespace);
        end;
      end;
    end;
  end;

begin
  if (AValue = FNamespace) then
    Exit;

  FNamespace := AValue;

  if not FNamespace then
  begin
    // DESMARCOU: O usu�rio n�o quer mais que seja namespace.
    // Pega quem � o namespace pai e devolve todo mundo para ele.
    if Assigned(FFolderOriginal) and (FFolderOriginal <> GlobalTriggerFolder) then
    begin
      LItem := Self.GetParentNamespace();
      MoveOriginalsTo(Self, LItem);

      FFolderOriginal.Free;
      FFolderOriginal := GlobalTriggerFolder; // Volta para o padr�o

      // Atualiza o nome do mirror para garantir que n�o colida com nada visualmente
      Self.Name :=  Self.TranscendName(Self.Name, Self.Parent);
    end;
    Exit;
  end;

  // MARCOU: O usu�rio quer que esta pasta seja um namespace de execu��o.
  LItem := Self.GetParentNamespace();

  // Garante um nome �nico no namespace pai antes de criar a pasta l�gica
  Self.Name := Self.TranscendName(Self.Name, LItem);

  // Cria a pasta de execu��o correspondente
  FFolderOriginal := TPGFolderOriginal.Create(Self, Self.Name);

  // Varre os filhos do Mirror visual e joga os Originais para dentro da nova pasta l�gica
  MoveOriginalsTo(Self, FFolderOriginal);
end;

procedure TPGFolderMirror.SetParent(AParent: TPGItem);
var
  LOldParent: TPGItem;
begin
  LOldParent := Self.Parent;
  if LOldParent <> AParent then
  begin
    Self.Name := Self.TranscendName(Self.Name, AParent);
    inherited SetParent(AParent);
    if FNamespace and Assigned(FFolderOriginal) and (FFolderOriginal <> GlobalTriggerFolder) then
      FFolderOriginal.Parent := Self.GetParentNamespace();
  end;
end;

procedure TPGFolderMirror.SetName(AName: string);
begin
  Self.SetNameForced( AName );
  if FNamespace and Assigned(FFolderOriginal)
  and (FFolderOriginal <> GlobalTriggerFolder) then
    TPGFolderOriginal(FFolderOriginal).SetNameForced( AName );
end;

function TPGFolderMirror.TranscendName(AName: string; AItemList: TPGItem): string;
begin
  // Chega de c�digo duplicado! Usa o motor robusto que criamos acima.
  Result := TPGItemTrigger.TranscendName(AName, AItemList, Self);
end;


function TPGFolderMirror.GetParentNamespace(): TPGFolder;
var
  LItem: TPGItem;
begin
   LItem := Self.Parent;
   while Assigned(LItem) do
   begin
      if (LItem is TPGFolderMirror) and TPGFolderMirror(LItem).Namespace then
         Exit( TPGFolderMirror(LItem).FFolderOriginal );
      LItem := LItem.Parent;
   end;
   Result := GlobalTriggerFolder;
end;

initialization
  TriggersCollect := TPGItemCollectTrigger.Create( 'Triggers' );
  TriggersCollect.RegisterClass( TPGFolderMirror );
  GlobalTriggerFolder := TPGFolder.Create( GlobalCollection, 'Triggers' );

finalization
  TriggersCollect.Free;
  TriggersCollect := nil;
  GlobalTriggerFolder := nil;
end.
