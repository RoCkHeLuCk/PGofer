unit PGofer.Triggers.AutoFills;

interface

uses
  System.Classes,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers;

type

  {$M+}
  TPGAutoFill = class( TPGItemTrigger )
  private
    FDelay : Cardinal;
    FSpeed : Cardinal;
    FMode : Byte;
    FText : String;
  protected
    procedure ExecuteWithArgs( Gramatica: TGramatica ); override;
  public
    class var GlobList: TPGItem;
    class function IconIndex(): Integer; override;
    constructor Create( AName: string; AMirror: TPGItemMirror ); overload;
    destructor Destroy( ); override;
    procedure Frame( AParent: TObject ); override;
    procedure Triggering( ); override;
  published
    [TPGAttribText('0:Write; 1:Send Point; 2:Copy; 3:Copy and Paste; 4:Script;')]
    property Mode: Byte read FMode write FMode;
    [TPGAttribText('Value millesecond;')]
    property Delay: Cardinal read FDelay write FDelay;
    [TPGAttribText('Value millesecond;')]
    property Speed: Cardinal read FSpeed write FSpeed;
    property Text: string read FText write FText;
  end;
  {$TYPEINFO ON}

  TPGAutoFillDeclare = class( TPGItemClass )
  protected
  public
    class function IconIndex(): Integer; override;
    procedure Execute( AGramatica: TGramatica ); override;
  end;

  TPGAutoFillMirror = class( TPGItemMirror )
  protected
  public
    constructor Create( AItemDad: TPGItem; AName: string = ''); override;
    procedure Frame( AParent: TObject ); override;
    class function OnDropFile( AItemDad: TPGItem; AFileName: String ): boolean; override;
    class function ClassNameEx(): String; override;
    class function IconIndex(): Integer; override;
  end;


implementation

uses
  Winapi.Windows,
  System.SysUtils, System.StrUtils,
  PGofer.Lexico,
  PGofer.Sintatico.Controls,
  PGofer.Triggers.AutoFills.Frame,
  PGofer.Files.Controls,
  PGofer.Key.Post,
  PGofer.ClipBoards.Controls,
  PGofer.Process.Controls;

{ TPGAutoFills }

constructor TPGAutoFill.Create( AName: string; AMirror: TPGItemMirror );
begin
  inherited Create( TPGAutoFill.GlobList, AName, AMirror );
  Self.ReadOnly := False;
  FText := '';
  FSpeed := 10;
  FDelay := 500;
  FMode := 0;
end;

destructor TPGAutoFill.Destroy( );
begin
  FText := '';
  FSpeed := 0;
  FDelay := 0;
  FMode := 0;
  inherited Destroy( );
end;

procedure TPGAutoFill.ExecuteWithArgs( Gramatica: TGramatica );
var
  LParam, LText: string;
begin
  Gramatica.TokenList.GetNextToken;
  Expressao( Gramatica );
  if ( Gramatica.TokenList.Token.Classe = cmdRPar ) then
  begin
    LParam := Gramatica.Pilha.Desempilhar( '' );
    if not Gramatica.Erro then
    begin
      LText := Self.Text;
      Self.Text := LParam;
      Self.Triggering();
      Self.Text := LText;
    end;
    Gramatica.TokenList.GetNextToken;
  end else
    Gramatica.ErroAdd('Error_Interpreter_)');
end;

procedure TPGAutoFill.Frame( AParent: TObject );
begin
  inherited Frame( AParent );
  TPGAutoFillsFrame.Create( Self, AParent );
end;

class function TPGAutoFill.IconIndex: Integer;
begin
  Result := Ord(pgiAutoFill);
end;

procedure TPGAutoFill.Triggering( );
var
  KeyPost: TKeyPost;
begin
  sleep(FDelay);
  case self.Mode of
     0:begin
        KeyPost := TKeyPost.Create( self.Text, self.Speed);
        KeyPost.WaitFor( );
        KeyPost.Free( );
     end;

     1:begin
        SendMessage(
          ProcessGetFocusedControl(),
          $000C ,
          0,
          LPARAM(PChar(self.Text))
        );
     end;

     2:begin
       ClipBoardCopyFromText(self.Text);
     end;

     3:begin
       ClipBoardCopyFromText(self.Text);
       sleep(self.Speed*2);
       keybd_event( VK_CONTROL, 0, KEYEVENTF_EXTENDEDKEY, 0 );
       sleep(self.Speed);
       keybd_event( 86, 0, KEYEVENTF_EXTENDEDKEY, 0 ); //v
       sleep(self.Speed);
       keybd_event( 86, 0, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0 ); //v
       sleep(self.Speed);
       keybd_event( VK_CONTROL, 0, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0 );
     end;

     4:begin
       ScriptExec( 'AutoFill: ' + Self.Name, Self.Text, nil );
     end;

  end;

end;

{ TPGAutoFillsDeclare }

class function TPGAutoFillDeclare.IconIndex: Integer;
begin
  Result := Ord(pgiAutoFill);
end;

procedure TPGAutoFillDeclare.Execute( AGramatica: TGramatica );
var
  Titulo: string;
  Quantidade: Byte;
  AutoFills: TPGAutoFill;
  id: TPGItem;
begin
  if Self.TryExecuteChild(AGramatica) then
    Exit;

  id := IdentificadorLocalizar( AGramatica );
  if ( not Assigned( id ) ) or ( id is TPGAutoFill ) then
  begin
    Titulo := AGramatica.TokenList.Token.Lexema;
    Quantidade := LerParamentros( AGramatica, 1, 3 );
    if not AGramatica.Erro then
    begin
      if ( not Assigned( id ) ) then
        AutoFills := TPGAutoFill.Create( Titulo, nil )
      else
        AutoFills := TPGAutoFill( id );

      if Quantidade >= 4 then
        AutoFills.Delay := AGramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 3 then
        AutoFills.Speed := AGramatica.Pilha.Desempilhar( 10 );

      if Quantidade >= 2 then
        AutoFills.Mode := AGramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 1 then
        AutoFills.Text := AGramatica.Pilha.Desempilhar( '' );
    end;
  end
  else
    AGramatica.ErroAdd('Error_Interpreter_IdExist');
end;

{ TPGAutoFillsMirror }

constructor TPGAutoFillMirror.Create( AItemDad: TPGItem; AName: string );
begin
  if AName = '' then AName := 'NewAutoFill';
  AName := TPGItemMirror.TranscendName( AName );
  inherited Create( AItemDad, TPGAutoFill.Create( AName, Self ) );
end;

procedure TPGAutoFillMirror.Frame( AParent: TObject );
begin
  TPGAutoFillsFrame.Create( Self.ItemOriginal, AParent );
end;

class function TPGAutoFillMirror.ClassNameEx(): String;
begin
  Result := TPGAutoFill.ClassNameEx;
end;

class function TPGAutoFillMirror.IconIndex: Integer;
begin
  Result := Ord(pgiAutoFill);
end;

class function TPGAutoFillMirror.OnDropFile(AItemDad: TPGItem; AFileName: String): boolean;
var
  LList: TStringList;
  LRow: string;
  LName, LValue: string;
  LAutoFill: TPGAutoFill;
  LFolder: TPGItem;
  LParts: TArray<string>;
begin
  // Aceita .csv e .txt
  Result := MatchText(ExtractFileExt(AFileName), ['.csv']);
  if not Result then Exit;

  LList := TStringList.Create;
  try
    LList.LoadFromFile(AFileName);

    // Cria uma pasta com o nome do arquivo para organizar os dados importados
    LFolder := TPGFolder.Create(AItemDad, FileExtractOnlyFileName(AFileName));

    for LRow in LList do
    begin
      if LRow.Trim = '' then Continue;

      // Split simples por vírgula ou ponto-e-vírgula
      LParts := LRow.Split([',', ';']);

      if Length(LParts) >= 2 then
      begin
        LName := LParts[0].Trim;
        LValue := LParts[1].Trim;

        // Cria o Mirror dentro da nova pasta
        LAutoFill := TPGAutoFill(TPGAutoFillMirror.Create(LFolder, LName).ItemOriginal);
        LAutoFill.Text := LValue;
      end;
    end;
  finally
    LList.Free;
  end;
end;

initialization

TPGAutoFillDeclare.Create( GlobalItemCommand, 'AutoFill' );
TPGAutoFill.GlobList := TPGFolder.Create( GlobalCollection, 'AutoFills' );
TriggersCollect.RegisterClass( TPGAutoFillMirror );

finalization

end.
