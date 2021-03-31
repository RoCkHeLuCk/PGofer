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
    procedure SetName( Name: string ); override;
  public
    constructor Create( ItemDad: TPGItem; Name: string;
       ItemMirror: TPGItemMirror ); overload;
    destructor Destroy( ); override;
    property ItemMirror: TPGItemMirror read FItemMirror;
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGItemMirror = class( TPGItem )
  private
    FItemOriginal: TPGItemTrigger;
  public
    constructor Create( ItemDad: TPGItem;
       ItemOriginal: TPGItemTrigger ); overload;
    destructor Destroy( ); override;
    property ItemOriginal: TPGItemTrigger read FItemOriginal;
    class function TranscendName( AName: string;
       ItemList: TPGItem = nil ): string;
  end;

implementation

uses
  System.SysUtils,
  PGofer.Lexico, PGofer.Sintatico.Controls,
  PGofer.Key.Controls;

{ TPGItemTrigger }

constructor TPGItemTrigger.Create( ItemDad: TPGItem; Name: string;
   ItemMirror: TPGItemMirror );
begin
  inherited Create( ItemDad, name );
  FItemMirror := ItemMirror;
end;

destructor TPGItemTrigger.Destroy( );
begin
  if Assigned( FItemMirror ) then
  begin
    FItemMirror.FItemOriginal := nil;
    FItemMirror.Free( );
  end;
  inherited;
end;

procedure TPGItemTrigger.SetName( Name: string );
begin
  inherited;
  if Assigned( FItemMirror ) then
    FItemMirror.Name := name;
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

constructor TPGItemMirror.Create( ItemDad: TPGItem;
   ItemOriginal: TPGItemTrigger );
begin
  inherited Create( ItemDad, ItemOriginal.Name );
  FItemOriginal := ItemOriginal;
end;

destructor TPGItemMirror.Destroy( );
begin
  if Assigned( FItemOriginal ) then
  begin
    FItemOriginal.FItemMirror := nil;
    FItemOriginal.Free;
  end;
  inherited;
end;

class function TPGItemMirror.TranscendName( AName: string;
   ItemList: TPGItem = nil ): string;
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
  if Assigned( ItemList ) and ( ItemList <> GlobalCollection ) then
  begin
    while Assigned( ItemList.FindName( Result ) ) do
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
