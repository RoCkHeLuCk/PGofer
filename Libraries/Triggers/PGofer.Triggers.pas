unit PGofer.Triggers;

interface

uses
  PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes;

type
  TPGItemMirror = class;

  TPGItemTrigger = class( TPGItemCMD )
  private
    FItemMirror: TPGItemMirror;
  protected
    procedure ExecutarNivel1( Gramatica: TGramatica ); virtual; abstract;
    procedure SetName( AName: string ); override;
  public
    constructor Create( AItemDad: TPGItem; AName: string;
       AItemMirror: TPGItemMirror ); overload;
    destructor Destroy( ); override;
    property ItemMirror: TPGItemMirror read FItemMirror;
    procedure Execute( Gramatica: TGramatica ); override;
    procedure Triggering( ); virtual; abstract;
  end;

  TPGItemMirror = class( TPGItem )
  private
    FItemOriginal: TPGItemTrigger;
  public
    constructor Create( AItemDad: TPGItem;
       AItemOriginal: TPGItemTrigger ); overload;
    destructor Destroy( ); override;
    property ItemOriginal: TPGItemTrigger read FItemOriginal;
    class function TranscendName( AName: string;
       AItemList: TPGItem = nil ): string;
  end;

implementation

uses
  System.SysUtils,
  PGofer.Lexico, PGofer.Sintatico.Controls,
  PGofer.Key.Controls;

{ TPGItemTrigger }

constructor TPGItemTrigger.Create( AItemDad: TPGItem; AName: string;
   AItemMirror: TPGItemMirror );
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

procedure TPGItemTrigger.Execute( Gramatica: TGramatica );
begin
  Gramatica.TokenList.GetNextToken;
  if Gramatica.TokenList.Token.Classe = cmdDot then
  begin
    Gramatica.TokenList.GetNextToken;
    Self.RttiExecute( Gramatica, Self );
  end
  else
    Self.ExecutarNivel1( Gramatica );
end;

{ TPGItemMirror }

constructor TPGItemMirror.Create( AItemDad: TPGItem;
   AItemOriginal: TPGItemTrigger );
begin
  inherited Create( AItemDad, AItemOriginal.Name );
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

class function TPGItemMirror.TranscendName( AName: string;
   AItemList: TPGItem = nil ): string;
var
  C: Word;
begin
  C := 0;
  AName := RemoveCharSpecial( AName, True );

  if AName <> '' then
  begin
    if not CharInSet( AName[ LowString ], [ 'A' .. 'Z', 'a' .. 'z' ] ) then
      AName := 'New' + AName;
  end
  else
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

end.
