unit PGofer.Triggers.Tasks;

interface

uses
  System.Classes,
  PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes,
  PGofer.Triggers;

type

  {$M+}
  TPGTask = class( TPGItemTrigger )
  private
    FOccurrence: Cardinal;
    FRepeat: Cardinal;
    FScript: TStrings;
    FTrigger: Byte;
    class var FImageIndex: Integer;
    function GetScript: string;
    procedure SetScript( AValue: string );
  protected
    class function GetImageIndex( ): Integer; override;
    procedure ExecutarNivel1( Gramatica: TGramatica ); override;
  public
    constructor Create( AName: string; AMirror: TPGItemMirror );
    destructor Destroy( ); override;
    procedure Frame( AParent: TObject ); override;
    class var GlobList: TPGItem;
    class procedure Working( AType: Byte; AWaitFor: Boolean = False );
    procedure Triggering( ); override;
  published
    property Occurrence: Cardinal read FOccurrence write FOccurrence;
    property Repeats: Cardinal read FRepeat write FRepeat;
    property Script: string read GetScript write SetScript;
    property Trigger: Byte read FTrigger write FTrigger;
  end;
  {$TYPEINFO ON}

  TPGTaskDeclare = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGTaskMirror = class( TPGItemMirror )
  protected
    class function GetImageIndex( ): Integer; override;
  public
    constructor Create( AItemDad: TPGItem; AName: string );
    procedure Frame( AParent: TObject ); override;
  end;

implementation

uses
  System.SysUtils,
  PGofer.Sintatico.Controls,
  PGofer.Triggers.Tasks.Frame,
  PGofer.ImageList;

{ TPGTask }

constructor TPGTask.Create( AName: string; AMirror: TPGItemMirror );
begin
  inherited Create( TPGTask.GlobList, AName, AMirror );
  Self.ReadOnly := False;
  FScript := TStringList.Create( );
  FOccurrence := 0;
  FTrigger := 0;
end;

destructor TPGTask.Destroy( );
begin
  FScript.Free;
  FOccurrence := 0;
  FTrigger := 0;
  inherited Destroy( );
end;

procedure TPGTask.ExecutarNivel1( Gramatica: TGramatica );
begin
  ScriptExec( 'Task: ' + Self.Name, Self.Script, Gramatica.Local );
end;

procedure TPGTask.Frame( AParent: TObject );
begin
  inherited Frame( AParent );
  TPGTaskFrame.Create( Self, AParent );
end;

class function TPGTask.GetImageIndex( ): Integer;
begin
  Result := FImageIndex;
end;

function TPGTask.GetScript( ): string;
begin
  Result := FScript.Text;
end;

procedure TPGTask.SetScript( AValue: string );
begin
  FScript.Text := AValue;
end;

procedure TPGTask.Triggering( );
begin
  Self.ExecutarNivel1( nil );
end;

class procedure TPGTask.Working( AType: Byte; AWaitFor: Boolean = False );
var
  Item: TPGTask;
  C: Integer;
begin
  for C := 0 to TPGTask.GlobList.Count - 1 do
  begin
    Item := TPGTask( TPGTask.GlobList[ C ] );
    if ( Item.Trigger = AType ) and ( Item.Enabled ) and
      ( ( Item.Repeats = 0 ) or ( Item.Occurrence < Item.Repeats ) ) then
    begin
      ScriptExec( 'Task: ' + Item.Name, TPGTask( Item ).Script, nil, AWaitFor );
      Item.Occurrence := Item.Occurrence + 1;
      Item.CollectDad.UpdateToFile( );
    end;
  end;
end;

{ TPGTaskDeclare }

procedure TPGTaskDeclare.Execute( Gramatica: TGramatica );
var
  Titulo: string;
  Quantidade: Byte;
  Task: TPGTask;
  id: TPGItem;
begin
  Gramatica.TokenList.GetNextToken;
  id := IdentificadorLocalizar( Gramatica );
  if ( not Assigned( id ) ) or ( id is TPGTask ) then
  begin
    Titulo := Gramatica.TokenList.Token.Lexema;
    Quantidade := LerParamentros( Gramatica, 1, 3 );
    if not Gramatica.Erro then
    begin
      if ( not Assigned( id ) ) then
        Task := TPGTask.Create( Titulo, nil )
      else
        Task := TPGTask( id );

      if Quantidade = 3 then
        Task.Repeats := Gramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 2 then
        Task.Trigger := Gramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 1 then
        Task.Script := Gramatica.Pilha.Desempilhar( '' );
    end;
  end
  else
    Gramatica.ErroAdd( 'Identificador esperado ou já existente.' );
end;

{ TPGTaskMirror }

constructor TPGTaskMirror.Create( AItemDad: TPGItem; AName: string );
begin
  AName := TPGItemMirror.TranscendName( AName, TPGTask.GlobList );
  inherited Create( AItemDad, TPGTask.Create( AName, Self ) );
  Self.ReadOnly := False;
end;

procedure TPGTaskMirror.Frame( AParent: TObject );
begin
  TPGTaskFrame.Create( Self.ItemOriginal, AParent );
end;

class function TPGTaskMirror.GetImageIndex: Integer;
begin
  Result := TPGTask.FImageIndex;
end;

initialization

TPGTaskDeclare.Create( GlobalItemCommand, 'Task' );
TPGTask.GlobList := TPGFolder.Create( GlobalItemTrigger, 'Tasks' );

TriggersCollect.RegisterClass( 'Task', TPGTaskMirror );
TPGTask.FImageIndex := GlogalImageList.AddIcon( 'Task' );

finalization

end.
