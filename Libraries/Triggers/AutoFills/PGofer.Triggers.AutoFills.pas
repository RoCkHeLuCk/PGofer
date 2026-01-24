unit PGofer.Triggers.AutoFills;

interface

uses
  System.Classes,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers;

type

  {$M+}
  [TPGAttribIcon(pgiAutoFill)]
  TPGAutoFills = class( TPGItemTrigger )
  private
    FDelay : Cardinal;
    FSpeed : Cardinal;
    FMode : Byte;
    FText : String;
  protected
    procedure ExecutarNivel1( Gramatica: TGramatica ); override;
  public
    constructor Create( AName: string; AMirror: TPGItemMirror );
    destructor Destroy( ); override;
    procedure Frame( AParent: TObject ); override;
    class var GlobList: TPGItem;
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

  [TPGAttribIcon(pgiAutoFill)]
  TPGAutoFillsDeclare = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  [TPGAttribIcon(pgiAutoFill)]
  TPGAutoFillsMirror = class( TPGItemMirror )
  protected
  public
    constructor Create( AItemDad: TPGItem; AName: string );
    procedure Frame( AParent: TObject ); override;
  end;


implementation

uses
  Winapi.Windows,
  System.SysUtils,
  PGofer.Language,
  PGofer.Lexico,
  PGofer.Sintatico.Controls,
  PGofer.Triggers.AutoFills.Frame,

  PGofer.Key.Post,
  PGofer.ClipBoards.Controls,
  PGofer.Process.Controls;

{ TPGAutoFills }

constructor TPGAutoFills.Create( AName: string; AMirror: TPGItemMirror );
begin
  inherited Create( TPGAutoFills.GlobList, AName, AMirror );
  Self.ReadOnly := False;
  FText := '';
  FSpeed := 10;
  FDelay := 0;
  FMode := 0;
end;

destructor TPGAutoFills.Destroy( );
begin
  FText := '';
  FSpeed := 10;
  FDelay := 0;
  FMode := 0;
  inherited Destroy( );
end;

procedure TPGAutoFills.ExecutarNivel1( Gramatica: TGramatica );
var
  VParam: string;
begin
  if Gramatica.TokenList.Token.Classe = cmdLPar then
  begin
    Gramatica.TokenList.GetNextToken;
    Expressao( Gramatica );
    if ( Gramatica.TokenList.Token.Classe = cmdRPar ) then
    begin
      VParam := Gramatica.Pilha.Desempilhar( '' );
      if not Gramatica.Erro then
        Self.Triggering();
      Gramatica.TokenList.GetNextToken;
    end else
      Gramatica.ErroAdd( Tr('Error_Interpreter_)') );
  end else if not Gramatica.Erro then
    Self.Triggering();
end;

procedure TPGAutoFills.Frame( AParent: TObject );
begin
  inherited Frame( AParent );
  TPGAutoFillsFrame.Create( Self, AParent );
end;

procedure TPGAutoFills.Triggering( );
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

procedure TPGAutoFillsDeclare.Execute( Gramatica: TGramatica );
var
  Titulo: string;
  Quantidade: Byte;
  AutoFills: TPGAutoFills;
  id: TPGItem;
begin
  Gramatica.TokenList.GetNextToken;
  id := IdentificadorLocalizar( Gramatica );
  if ( not Assigned( id ) ) or ( id is TPGAutoFills ) then
  begin
    Titulo := Gramatica.TokenList.Token.Lexema;
    Quantidade := LerParamentros( Gramatica, 1, 3 );
    if not Gramatica.Erro then
    begin
      if ( not Assigned( id ) ) then
        AutoFills := TPGAutoFills.Create( Titulo, nil )
      else
        AutoFills := TPGAutoFills( id );

      if Quantidade >= 4 then
        AutoFills.Delay := Gramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 3 then
        AutoFills.Speed := Gramatica.Pilha.Desempilhar( 10 );

      if Quantidade >= 2 then
        AutoFills.Mode := Gramatica.Pilha.Desempilhar( 0 );

      if Quantidade >= 1 then
        AutoFills.Text := Gramatica.Pilha.Desempilhar( '' );
    end;
  end
  else
    Gramatica.ErroAdd( Tr('Error_Interpreter_IdExist') );
end;

{ TPGAutoFillsMirror }

constructor TPGAutoFillsMirror.Create( AItemDad: TPGItem; AName: string );
begin
  AName := TPGItemMirror.TranscendName( AName );
  inherited Create( AItemDad, TPGAutoFills.Create( AName, Self ) );
  Self.ReadOnly := False;
end;

procedure TPGAutoFillsMirror.Frame( AParent: TObject );
begin
  TPGAutoFillsFrame.Create( Self.ItemOriginal, AParent );
end;

initialization

TPGAutoFillsDeclare.Create( GlobalItemCommand, 'AutoFill' );
TPGAutoFills.GlobList := TPGFolder.Create( GlobalCollection, 'AutoFills' );
TriggersCollect.RegisterClass( 'AutoFill', pgiAutoFill, TPGAutoFillsMirror );

finalization

end.
