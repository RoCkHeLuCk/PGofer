unit PGofer.Triggers.Tasks;

interface

uses
  System.Classes,
  PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers;

type

  {$M+}
  TPGTask = class( TPGItemTrigger )
  private
    FOccurrence: Cardinal;
    FRepeat: Cardinal;
    FScript: TStrings;
    FTrigger: Byte;
    function GetScript: string;
    procedure SetScript( AValue: string );
  protected
    procedure ExecuteWithArgs( Gramatica: TGramatica ); override;
  public
    constructor Create( AName: string; AMirror: TPGItemMirror ); overload;
    destructor Destroy( ); override;
    procedure Frame( AParent: TObject ); override;
    class var GlobList: TPGItem;
    class procedure Working( AType: Byte; AWaitFor: Boolean = False );
    class function IconIndex(): Integer; override;
    procedure Triggering( ); override;
  published
    property Occurrence: Cardinal read FOccurrence write FOccurrence;
    property Repeats: Cardinal read FRepeat write FRepeat;
    property Script: string read GetScript write SetScript;
    property Trigger: Byte read FTrigger write FTrigger;
  end;
  {$TYPEINFO ON}

  TPGTaskDeclare = class( TPGItemClass )
  protected
  public
    class function IconIndex(): Integer; override;
    procedure Execute( AGramatica: TGramatica ); override;
  end;

  TPGTaskMirror = class( TPGItemMirror )
  protected
  public
    class function ClassNameEx(): String; override;
    class function IconIndex(): Integer; override;
    constructor Create( AItemDad: TPGItem; AName: string = ''); override;
    procedure Frame( AParent: TObject ); override;
  end;

implementation

uses
  System.SysUtils,
  PGofer.Core,
  PGofer.Sintatico.Controls,
  PGofer.Triggers.Tasks.Frame;

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

procedure TPGTask.ExecuteWithArgs( Gramatica: TGramatica );
begin
  ScriptExec( 'Task: ' + Self.Name, Self.Script, Gramatica.Local );
end;

procedure TPGTask.Frame( AParent: TObject );
begin
  inherited Frame( AParent );
  TPGTaskFrame.Create( Self, AParent );
end;

class function TPGTask.IconIndex: Integer;
begin
  Result := Ord(pgiTask);
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
  Self.ExecuteWithArgs( nil );
end;

class procedure TPGTask.Working( AType: Byte; AWaitFor: Boolean = False );
var
  Item: TPGTask;
  C: Integer;
  NeedSave: Boolean;
begin
  NeedSave := False;
  if Assigned(TPGTask.GlobList) then
  begin
    for C := 0 to TPGTask.GlobList.Count - 1 do
    begin
      Item := TPGTask( TPGTask.GlobList[ C ] );
      if ( Item.Trigger = AType ) and ( Item.Enabled ) and
        ( ( Item.Repeats = 0 ) or ( Item.Occurrence < Item.Repeats ) ) then
      begin
        ScriptExec( 'Task: ' + Item.Name, TPGTask( Item ).Script, nil, AWaitFor );
        Item.Occurrence := Item.Occurrence + 1;
        NeedSave := True;
      end;
    end;

    if NeedSave and Assigned(TriggersCollect) then
       TriggersCollect.XMLSaveToFile( );
  end;
end;

{ TPGTaskDeclare }

procedure TPGTaskDeclare.Execute( AGramatica: TGramatica );
var
  Titulo: string;
  Quantidade: Byte;
  Task: TPGTask;
  id: TPGItem;
begin
  if Self.TryExecuteChild(AGramatica) then
  Exit;

  id := IdentificadorLocalizar( AGramatica );
  if ( not Assigned( id ) ) or ( id is TPGTask ) then
  begin
    Titulo := AGramatica.TokenList.Token.Lexema;
    Quantidade := LerParamentros( AGramatica, 1, 3 );
    if not AGramatica.Erro then
    begin
      if ( not Assigned( id ) ) then
        Task := TPGTask.Create( Titulo, nil )
      else
        Task := TPGTask( id );

      if Quantidade = 3 then
        Task.Repeats := AGramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 2 then
        Task.Trigger := AGramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 1 then
        Task.Script := AGramatica.Pilha.Desempilhar( '' );
    end;
  end
  else
    AGramatica.ErroAdd( 'Error_Interpreter_IdExist' );
end;

class function TPGTaskDeclare.IconIndex: Integer;
begin
  Result := Ord(pgiTask);
end;

{ TPGTaskMirror }

constructor TPGTaskMirror.Create( AItemDad: TPGItem; AName: string );
begin
  if AName = '' then AName := 'NewTask';
  AName := TPGItemMirror.TranscendName( AName, TPGTask.GlobList );
  inherited Create( AItemDad, TPGTask.Create( AName, Self ) );
end;

procedure TPGTaskMirror.Frame( AParent: TObject );
begin
  TPGTaskFrame.Create( Self.ItemOriginal, AParent );
end;

class function TPGTaskMirror.ClassNameEx: String;
begin
  Result := TPGTask.ClassNameEx();
end;

class function TPGTaskMirror.IconIndex: Integer;
begin
  Result := Ord(pgiTask);
end;

initialization

TPGTaskDeclare.Create( GlobalItemCommand, 'Task' );
TPGTask.GlobList := TPGFolder.Create( GlobalItemTrigger, 'Tasks' );
TriggersCollect.RegisterClass( TPGTaskMirror );

finalization

end.
