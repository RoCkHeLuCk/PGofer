unit PGofer.Triggers;

interface

uses
  System.Classes, System.Generics.Collections,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers.Collections;

type
  TPGItemMirror = class;

  TPGItemTrigger = class( TPGItemClass )
  private
    FItemMirror: TPGItemMirror;
  protected
    procedure ExecuteWithArgs( AGramatica: TGramatica ); virtual; abstract;
    procedure SetName( AName: string ); override;
    function GetIsValid(): Boolean; virtual;
  public
    constructor Create( AItemDad: TPGItem; AName: string; AItemMirror: TPGItemMirror ); reintroduce; overload; virtual;
    destructor Destroy( ); override;
    property ItemMirror: TPGItemMirror read FItemMirror;
    property isValid: Boolean read GetIsValid;
    procedure Execute( AGramatica: TGramatica ); override;
    procedure Triggering( ); virtual; abstract;
    function isItemExist( AName: string; ALocal: Boolean ): Boolean; virtual;
  end;

  TPGItemMirror = class( TPGItem )
  private
    FItemOriginal: TPGItemTrigger;
  protected
    function GetIsValid( ): Boolean; virtual;
  public
    constructor Create( AItemDad: TPGItem; AItemOriginal: TPGItemTrigger ); overload; virtual;
    destructor Destroy( ); override;
    property isValid: Boolean read GetIsValid;
    property ItemOriginal: TPGItemTrigger read FItemOriginal;
    class function OnDropFile( AItemDad: TPGItem; AFileName: String ): Boolean; virtual;
    class function TranscendName( AName: string; AItemList: TPGItem = nil ): string;
  end;

  {$M+}
  TPGFolderMirror = class( TPGItemMirror )
  private
    FExpanded: Boolean;
    FPersist: Boolean;
    procedure SetExpanded( AValue: Boolean );
  protected
    FLocked: Boolean;
    procedure SetLocked(AValue:Boolean); virtual;
  public
    constructor Create( AItemDad: TPGItem; AName: string = '' ); override;
    destructor Destroy( ); override;
    function BeforeXMLSave(ItemCollect: TPGItemCollectTrigger): Boolean; virtual;
    function BeforeXMLLoad(ItemCollect: TPGItemCollectTrigger): Boolean; virtual;
    class function OnDropFile( AItemDad: TPGItem; AFileName: String ): boolean; override;
    class function ClassNameEx(): String; override;
    class function IconIndex(): Integer; override;
  published
    property Expanded: Boolean read FExpanded write SetExpanded;
    property Locked: Boolean read FLocked write SetLocked;
    property Persist: Boolean read FPersist write FPersist;
  end;
  {$TYPEINFO ON}

var
  TriggersCollect: TPGItemCollectTrigger;

implementation

uses
  System.SysUtils,
  PGofer.Lexico, PGofer.Sintatico.Controls,
  PGofer.Key.Controls;

{ TPGItemTrigger }

constructor TPGItemTrigger.Create( AItemDad: TPGItem; AName: string; AItemMirror: TPGItemMirror );
begin
  inherited Create( AItemDad, AName );
  FItemMirror := AItemMirror;
end;

destructor TPGItemTrigger.Destroy( );
begin
  if Assigned( FItemMirror ) then
  begin
    FItemMirror.FItemOriginal := nil;
    FItemMirror.Free( );
  end;
  inherited Destroy( );
end;

procedure TPGItemTrigger.SetName( AName: string );
begin
  inherited SetName( AName );
  if Assigned( FItemMirror ) then
    FItemMirror.Name := AName;
end;

function TPGItemTrigger.GetIsValid: Boolean;
begin
  Result := True;
end;

procedure TPGItemTrigger.Execute( AGramatica: TGramatica );
begin
  if Self.TryExecuteChild(AGramatica) then
    Exit;

  if AGramatica.TokenList.Token.Classe = cmdLPar then
    Self.ExecuteWithArgs( AGramatica )
  else
    Self.Triggering;
end;

function TPGItemTrigger.isItemExist( AName: string; ALocal: Boolean ): Boolean;
var
  Item: TPGItem;
begin
  if ALocal then
    Item := Self.Parent.FindName( AName )
  else
    Item := FindID( GlobalCollection, AName );

  Result := ( Assigned( Item ) and ( Item <> Self ) );
end;

{ TPGItemMirror }

constructor TPGItemMirror.Create( AItemDad: TPGItem; AItemOriginal: TPGItemTrigger );
begin
  inherited Create( AItemDad, AItemOriginal.Name );
  Self.ReadOnly := False;
  FItemOriginal := AItemOriginal;
end;

destructor TPGItemMirror.Destroy( );
begin
  if Assigned( FItemOriginal ) then
  begin
    FItemOriginal.FItemMirror := nil;
    FItemOriginal.Free;
  end;
  inherited Destroy( );
end;

function TPGItemMirror.GetIsValid( ): Boolean;
begin
  if Assigned( FItemOriginal ) then
    Result := FItemOriginal.isValid
  else
    Result := True;
end;

class function TPGItemMirror.OnDropFile(AItemDad: TPGItem; AFileName: String): boolean;
begin
   Result := False;
end;

class function TPGItemMirror.TranscendName( AName: string; AItemList: TPGItem = nil ): string;
var
  C: Word;
begin
  C := 0;
  AName := RemoveCharSpecial( AName, True );

  if AName <> '' then
  begin
    if not CharInSet( AName[ LOW_STRING ], [ 'A' .. 'Z', '_', 'a' .. 'z'] ) then
      AName := 'New' + AName;
  end else
    AName := 'New';

  Result := AName;
  if Assigned( AItemList ) and ( AItemList <> GlobalCollection ) then
  begin
    while Assigned( AItemList.FindName( Result ) ) do
    begin
      inc( C );
      Result := AName + IntToStr( C );
    end;
  end else begin
    while Assigned( FindID( GlobalCollection, Result ) ) do
    begin
      inc( C );
      Result := AName + IntToStr( C );
    end;
  end;
end;

{ TPGFolder }

constructor TPGFolderMirror.Create( AItemDad: TPGItem; AName: string );
begin
  if AName = '' then AName := 'NewFolder';
  inherited Create( AItemDad, AName );
  FLocked := False;
  FExpanded := False;
end;

destructor TPGFolderMirror.Destroy( );
begin
  Self.ReadOnly := False;
  FLocked := False;
  FExpanded := False;
  inherited Destroy( );
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
    TPGFolder.Create(AItemDad, ExtractFileName(AFileName));
  end;
end;

class function TPGFolderMirror.ClassNameEx: String;
begin
  Result := 'Folder';
end;

class function TPGFolderMirror.IconIndex: Integer;
begin
  Result := Ord(pgiFolder);
end;

procedure TPGFolderMirror.SetExpanded( AValue: Boolean );
begin
  if not FLocked then
  begin
    FExpanded := AValue;
    if Assigned( Self.Node ) then
      Self.Node.Expanded := FExpanded;
  end;
end;

procedure TPGFolderMirror.SetLocked(AValue: Boolean);
begin
   FLocked := AValue;
   if FLocked then
     Self.SetExpanded( False );
end;

initialization
  GlobalItemTrigger := TPGFolder.Create( GlobalCollection, 'Triggers' );
  TriggersCollect := TPGItemCollectTrigger.Create( 'Triggers' );
  TriggersCollect.RegisterClass( TPGFolderMirror );

finalization
  TriggersCollect.Free;

end.
