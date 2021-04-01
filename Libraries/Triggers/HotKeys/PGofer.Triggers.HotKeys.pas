unit PGofer.Triggers.HotKeys;

interface

uses
  System.Classes,
  System.Generics.Collections,
  PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes,
  PGofer.Triggers, PGofer.Triggers.HotKeys.Hook;

type

{$M+}
  TPGHotKey = class( TPGItemTrigger )
  private
    FKeys: TList< Word >;
    FDetect: Byte;
    FInhibit: Boolean;
    FScript: TStrings;
    class var FImageIndex: Integer;
    function GetKeysHex( ): string;
    procedure SetKeysHex( Value: string );
    function GetScript: string;
    procedure SetScript(const Value: string);
  protected
    procedure ExecutarNivel1( Gramatica: TGramatica ); override;
    class function GetImageIndex( ): Integer; override;
  public
    constructor Create( Name: string; Mirror: TPGItemMirror ); overload;
    destructor Destroy( ); override;
    class var GlobList: TPGItem;
    procedure Frame( Parent: TObject ); override;
    property Keys: TList< Word > read FKeys;
    function GetKeysName( ): string;
    class function LocateHotKeys( Keys: TList< Word > ): TPGHotKey;
    procedure Triggering( ); override;
  published
    property HotKeysHex: string read GetKeysHex write SetKeysHex;
    property Detect: Byte read FDetect write FDetect;
    property Inhibit: Boolean read FInhibit write FInhibit;
    property Script: string read GetScript write SetScript;
  end;
{$TYPEINFO ON}

  TPGHotKeyDeclare = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGHotKeyMirror = class( TPGItemMirror )
  protected
    class function GetImageIndex( ): Integer; override;
  public
    constructor Create( ItemDad: TPGItem; AName: string ); overload;
    procedure Frame( Parent: TObject ); override;
  end;

implementation

uses
  System.SysUtils,
  PGofer.Sintatico.Controls,
  PGofer.Key.Controls,
  PGofer.Triggers.HotKeys.Frame,
  PGofer.ImageList;

{ TPGHotKeyMain }

constructor TPGHotKey.Create( Name: string; Mirror: TPGItemMirror );
begin
  inherited Create( TPGHotKey.GlobList, name, Mirror );
  Self.ReadOnly := False;
  FKeys := TList< Word >.Create;
  FDetect := 0;
  FInhibit := False;
  FScript := TStringList.Create;
end;

destructor TPGHotKey.Destroy( );
begin
  FDetect := 0;
  FInhibit := False;
  FScript.Free;
  FKeys.Clear;
  FKeys.Free;
  FKeys := nil;
  inherited;
end;

procedure TPGHotKey.ExecutarNivel1( Gramatica: TGramatica );
begin
  ScriptExec( 'HotKey: ' + Self.Name, Self.Script, Gramatica.Local );
end;

procedure TPGHotKey.Frame( Parent: TObject );
begin
  TPGFrameHotKey.Create( Self, Parent );
end;

class function TPGHotKey.GetImageIndex: Integer;
begin
  Result := FImageIndex;
end;

function TPGHotKey.GetKeysHex( ): string;
var
  Key: Word;
begin
  Result := '';
  for Key in FKeys do
    Result := Result + IntToHex( Key, 3 );
end;

procedure TPGHotKey.SetKeysHex( Value: string );
var
  c: SmallInt;
  Key: Word;
begin
  FKeys.Clear;
  c := low( Value );
  while c + 2 <= high( Value ) do
  begin
    Key := StrToInt( '$' + copy( Value, c, 3 ) );
    if not FKeys.Contains( Key ) then
      FKeys.Add( Key );
    inc( c, 3 );
  end;
end;

procedure TPGHotKey.SetScript(const Value: string);
begin
    FScript.Text := Value;
end;

procedure TPGHotKey.Triggering( );
begin
  ScriptExec( 'HotKey: ' + Self.Name, Self.Script, nil );
end;

function TPGHotKey.GetKeysName( ): string;
var
  Key: Word;
begin
  Result := '';
  for Key in FKeys do
  begin
    if Result = '' then
      Result := KeyVirtualToStr( Key )
    else
      Result := Result + ' + ' + KeyVirtualToStr( Key );
  end;
end;

function TPGHotKey.GetScript: string;
begin
    Result := FScript.Text;
end;

class function TPGHotKey.LocateHotKeys( Keys: TList< Word > ): TPGHotKey;
var
  KeysCount: SmallInt;
  ListCount: SmallInt;
  AuxHotKeys: TPGHotKey;
  c, D: SmallInt;
  Find: Boolean;
begin
  Result := nil;
  KeysCount := Keys.Count;
  if KeysCount > 0 then
  begin
    ListCount := TPGHotKey.GlobList.Count;
    Find := False;
    c := 0;
    while ( c < ListCount ) and ( not Find ) do
    begin
      AuxHotKeys := TPGHotKey( TPGHotKey.GlobList[ c ] );
      if AuxHotKeys.Enabled and ( AuxHotKeys.FKeys.Count = KeysCount ) and
         ( AuxHotKeys.Script <> '' ) then
      begin
        if KeysCount = AuxHotKeys.Keys.Count then
        begin
          D := 0;
          Find := True;
          while ( D < KeysCount ) and ( Find ) do
          begin
            Find := AuxHotKeys.FKeys[ D ] = Keys[ D ];
            inc( D );
          end;
          if Find then
            Result := AuxHotKeys;
        end;
      end;
      inc( c );
    end;
  end;
end;

{ TPGHotKeyDeclare }

procedure TPGHotKeyDeclare.Execute( Gramatica: TGramatica );
var
  Titulo: string;
  Quantidade: Byte;
  HotKey: TPGHotKey;
  id: TPGItem;
begin
  Gramatica.TokenList.GetNextToken;
  id := IdentificadorLocalizar( Gramatica );
  if ( not Assigned( id ) ) or ( id is TPGHotKey ) then
  begin
    Titulo := Gramatica.TokenList.Token.Lexema;
    Quantidade := LerParamentros( Gramatica, 1, 4 );
    if not Gramatica.Erro then
    begin
      if ( not Assigned( id ) ) then
        HotKey := TPGHotKey.Create( Titulo, nil )
      else
        HotKey := TPGHotKey( id );

      if Quantidade = 4 then
        HotKey.Detect := Gramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 3 then
        HotKey.Inhibit := Gramatica.Pilha.Desempilhar( False );

      if Quantidade >= 2 then
        HotKey.SetKeysHex( Gramatica.Pilha.Desempilhar( '' ) );

      if Quantidade >= 1 then
        HotKey.Script := Gramatica.Pilha.Desempilhar( '' );
    end;
  end
  else
    Gramatica.ErroAdd( 'Identificador esperado o já existente.' );
end;

{ TPGHotKeysMirror }

constructor TPGHotKeyMirror.Create( ItemDad: TPGItem; AName: string );
begin
  AName := TPGItemMirror.TranscendName( AName, TPGHotKey.GlobList );
  inherited Create( ItemDad, TPGHotKey.Create( AName, Self ) );
  Self.ReadOnly := False;
end;

procedure TPGHotKeyMirror.Frame( Parent: TObject );
begin
  TPGFrameHotKey.Create( Self.ItemOriginal, Parent );
end;

class function TPGHotKeyMirror.GetImageIndex: Integer;
begin
  Result := TPGHotKey.FImageIndex;
end;

initialization

TPGHotKeyDeclare.Create( GlobalItemCommand, 'HotKey' );
TPGHotKey.GlobList := TPGFolder.Create( GlobalItemTrigger, 'HotKey' );

TriggersCollect.RegisterClass( 'HotKeys', TPGHotKeyMirror );
TPGHotKey.FImageIndex := GlogalImageList.AddIcon( 'HotKey' );

finalization

end.
