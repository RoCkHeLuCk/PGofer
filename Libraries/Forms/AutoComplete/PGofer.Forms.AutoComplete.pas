unit PGofer.Forms.AutoComplete;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.IniFiles,
  Vcl.Controls, Vcl.ComCtrls, Vcl.Forms, Vcl.Menus, Vcl.ExtCtrls,
  PGofer.Classes, PGofer.Forms, PGofer.Component.ListView,
  PGofer.Component.RichEdit, PGofer.Component.Form;

type
  TSelectCMD = ( selUp, selDown, selEnter );

  TFrmAutoComplete = class( TFormEx )
    ltvAutoComplete: TListViewEx;
    ppmAutoComplete: TPopupMenu;
    mniPriority: TMenuItem;
    trmAutoComplete: TTimer;
    constructor Create( AEditCtrl: TRichEditEx ); reintroduce;
    destructor Destroy( ); override;
    procedure FormCreate( Sender: TObject );
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
    procedure FormDestroy( Sender: TObject );
    procedure FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyPress( Sender: TObject; var Key: Char );
    procedure FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormDropFile( Sender: TObject; AFiles: TStrings );
    procedure mniPriorityClick( Sender: TObject );
    procedure trmAutoCompleteTimer( Sender: TObject );
    procedure ltvAutoCompleteDblClick( Sender: TObject );
    procedure ltvAutoCompleteCompare( Sender: TObject; Item1, Item2: TListItem;
       Data: Integer; var Compare: Integer );
  private
    FEditCtrl: TRichEditEx;
    FEditKeyDown: TOnKeyDownUP;
    FEditKeyPress: TOnKeyPress;
    FEditKeyUp: TOnKeyDownUP;
    FEditDropFile: TOnDropFile;
    FMemoryIniFile: TIniFile;
    FMemoryNoCtrl: Boolean;
    FMemoryList: TStringList;
    FMemoryPosition: Integer;
    FEditControlPress: Boolean;
    FCommandCompare: string;
    FCommandCompareLength: Integer;
    procedure ListViewAdd( ACaption, AOrigin: string ); overload;
    procedure ListViewAdd( AItem: TPGItem ); overload;
    procedure PriorityStep( );
    procedure SetPriority( AValue: FixedInt );
    procedure ProcurarComandos( ACommand: string ); overload;
    procedure FileNameList( AFileName: string );
    procedure FindCMD( );
    procedure SelectCMD( ASelected: TSelectCMD );
    procedure ShowAutoComplete( );
    procedure SetCommandCompare( AValue: string );
    property CommandCompare: string read FCommandCompare
       write SetCommandCompare;
  protected
    procedure CreateWindowHandle( const Params: TCreateParams ); override;
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    property MemoryNoCtrl: Boolean read FMemoryNoCtrl write FMemoryNoCtrl;
  end;

implementation

uses
  Winapi.Messages,
  Vcl.Dialogs,
  PGofer.Lexico, PGofer.Sintatico, PGofer.Sintatico.Controls,
  PGofer.Files.Controls, PGofer.Forms.Controls, PGofer.Utils;

{$R *.dfm}

const
  Caracteres: TSysCharSet = [ #10, #13, ' ', ',', ';', ':', '=', '+', '-', '*',
     '\', '/', '<', '>', '(', ')', '[', ']', '!', '@', '#', '%', '^', '$', '&',
     '?', '|', '''', '"', '.' ];

procedure TFrmAutoComplete.CreateWindowHandle( const Params: TCreateParams );
begin
  inherited CreateWindowHandle( Params );
  SetWindowLong( Self.Handle, GWL_STYLE, WS_SIZEBOX );
  SetWindowLong( Self.Handle, GWL_EXSTYLE, WS_EX_NOACTIVATE or
     WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW );
  Application.AddPopupForm( Self );
end;

constructor TFrmAutoComplete.Create( AEditCtrl: TRichEditEx );
begin
  inherited Create( nil );
  // guarda os eventos do edit
  FEditCtrl := AEditCtrl;
  FEditKeyDown := FEditCtrl.OnKeyDown;
  FEditKeyPress := FEditCtrl.OnKeyPress;
  FEditKeyUp := FEditCtrl.OnKeyUp;
  FEditDropFile := FEditCtrl.OnDropFiles;

  // Sobescreve os eventos do edid
  FEditCtrl.OnKeyDown := Self.FormKeyDown;
  FEditCtrl.OnKeyPress := Self.FormKeyPress;
  FEditCtrl.OnKeyUp := Self.FormKeyUp;
  FEditCtrl.OnDropFiles := Self.FormDropFile;

  // carrega arquivos ini
  FMemoryIniFile := TIniFile.Create( PGofer.Sintatico.DirCurrent +
     'AutoComplete.ini' );
  // controle de memorização de comandos
  FMemoryNoCtrl := False;
  FMemoryPosition := 0;
  FMemoryList := TStringList.Create( );

  FEditControlPress := False;
end;

destructor TFrmAutoComplete.Destroy( );
begin
  // restaura eventos originais
  FEditCtrl.OnKeyDown := FEditKeyDown;
  FEditCtrl.OnKeyPress := FEditKeyPress;
  FEditCtrl.OnKeyUp := FEditKeyUp;
  FEditCtrl.OnDropFiles := FEditDropFile;

  FEditKeyDown := nil;
  FEditKeyPress := nil;
  FEditKeyUp := nil;
  FEditCtrl := nil;

  FMemoryIniFile.Free( );
  FMemoryList.Free( );
  FMemoryPosition := 0;
  FMemoryNoCtrl := False;

  FEditControlPress := False;

  inherited Destroy( );
end;

procedure TFrmAutoComplete.FormClose( Sender: TObject;
   var Action: TCloseAction );
begin
  inherited FormClose( Sender, Action );
  trmAutoComplete.Enabled := False;
end;

procedure TFrmAutoComplete.FormCreate( Sender: TObject );
begin
  inherited FormCreate( Sender );
  //
end;

procedure TFrmAutoComplete.FormDestroy( Sender: TObject );
begin
  inherited FormDestroy( Sender );
  //
end;

procedure TFrmAutoComplete.FormDropFile( Sender: TObject; AFiles: TStrings );
begin
  if AFiles.Text <> '' then
  begin
    FEditCtrl.Lines.Add( AFiles.Text );
  end;

  if Assigned( FEditDropFile ) then
    FEditDropFile( Sender, AFiles );
end;

procedure TFrmAutoComplete.FormKeyDown( Sender: TObject; var Key: Word;
   Shift: TShiftState );
var
  c: Word;
begin
  if Self.Visible then
  begin
    case Key of
      VK_RETURN:
        begin
          Self.SelectCMD( selEnter );
          Key := 0;
        end;

      VK_ESCAPE:
        begin
          Self.Close;
          Key := 0;
        end;

      VK_UP:
        begin
          Self.SelectCMD( selUp );
          Key := 0;
        end;

      VK_DOWN:
        begin
          Self.SelectCMD( selDown );
          Key := 0;
        end;

      VK_LEFT, VK_RIGHT:
        begin
          Self.FindCMD( );
        end;
    end;
  end else begin
    // not visible
    case Key of

      VK_RETURN:
        begin
          if FEditCtrl.Text <> '' then
          begin
            FMemoryPosition := FMemoryList.Count;
            FMemoryList.Add( FEditCtrl.Lines[ FEditCtrl.CaretY - 1 ] );
            if FMemoryPosition > 100 then
              FMemoryList.Delete( 0 );
          end;
        end;

      VK_SPACE:
        begin
          if Shift = [ ssCtrl ] then
          begin
            Self.FindCMD( );
            Key := 0;
            FEditControlPress := True;
          end;
        end;

      VK_PRIOR, VK_NEXT:
        begin
          if ( Shift = [ ssCtrl ] ) or ( FMemoryNoCtrl ) then
          begin
            c := FMemoryList.Count;
            if c > 0 then
            begin
              // anteriores
              if ( Key in [ VK_PRIOR, VK_UP ] ) then
              begin
                if FMemoryPosition > 0 then
                  Dec( FMemoryPosition )
                else
                  FMemoryPosition := c - 1;
              end;
              // posteriores
              if ( Key = VK_NEXT ) then
              begin
                if FMemoryPosition < c - 1 then
                  Inc( FMemoryPosition )
                else
                  FMemoryPosition := 0;
              end;
              // escreve no edit
              FEditCtrl.Lines[ FEditCtrl.CaretY - 1 ] :=
                 FMemoryList[ FMemoryPosition ];
              Key := 0;
            end;
          end;
        end;
    end;
  end;

  if Assigned( FEditKeyDown ) then
    FEditKeyDown( Sender, Key, Shift );
end;

procedure TFrmAutoComplete.FormKeyPress( Sender: TObject; var Key: Char );
begin
  if ( Key = ' ' ) and FEditControlPress then
  begin
    Key := #0;
    FEditControlPress := False;
  end;

  if Assigned( FEditKeyPress ) then
    FEditKeyPress( Sender, Key );
end;

procedure TFrmAutoComplete.FormKeyUp( Sender: TObject; var Key: Word;
   Shift: TShiftState );
begin
  if Shift = [ ] then
    case Key of
      8 { bcks } , // backspace
      48 { 0 } .. 57 { 9 } , // numero
      65 { A } .. 92 { Z } , // letra
      96 { 0 } .. 105 { 9 } , // numpad
      106 { * } , 107 { + } , 109 { - } , 110 { . } , 111 { / } , 187 { = } ,
         186 { ; } , 188 { , } , 189 { - } , 190 { . } , 191 { / } , 219 { [ } ,
         220 { \ } , 221 { ] } , 222 { ' } , 226 { \ } :
        begin
          if FEditCtrl.Text <> '' then
            Self.FindCMD( )
          else
            Self.Close;
        end; // $30..$39,

      VK_F9:
        begin
          ScriptExec( 'Test', FEditCtrl.Lines.Text, nil, False );
        end;
    end; // case

  FEditControlPress := False;

  if Assigned( FEditKeyUp ) then
    FEditKeyUp( Sender, Key, Shift );
end;

procedure TFrmAutoComplete.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  ltvAutoComplete.IniConfigLoad( FIniFile );
end;

procedure TFrmAutoComplete.IniConfigSave;
begin
  ltvAutoComplete.IniConfigSave( FIniFile );
  inherited IniConfigSave( );
end;

procedure TFrmAutoComplete.ltvAutoCompleteCompare( Sender: TObject;
   Item1, Item2: TListItem; Data: Integer; var Compare: Integer );
var
  v1, v2: Integer;
  b1, b2: Boolean;
begin
  v1 := 0;
  b1 := false;
  if Assigned( Item1 ) then
  begin
    if ( Item1.SubItems.Count > 1 ) then
      TryStrToInt( Item1.SubItems[ 1 ], v1 );

    b1 := SameText( Copy( Item1.Caption, LowString, FCommandCompareLength ),
       FCommandCompare );
  end;

  v2 := 0;
  b2 := false;
  if Assigned( Item2 ) then
  begin
    if ( Item2.SubItems.Count > 1 ) then
      TryStrToInt( Item2.SubItems[ 1 ], v2 );

    b2 := SameText( Copy( Item2.Caption, LowString, FCommandCompareLength ),
       FCommandCompare );
  end;


  if b1 xor b2 then
  begin
    if b1 then
       Compare := 0
    else
       Compare := 1;
  end else
     Compare := v2 - v1;
end;

procedure TFrmAutoComplete.ltvAutoCompleteDblClick( Sender: TObject );
begin
  SelectCMD( selEnter );
end;

procedure TFrmAutoComplete.mniPriorityClick( Sender: TObject );
var
  N: Integer;
begin
  if TryStrToInt( InputBox( 'Priority', 'Valor',
     ltvAutoComplete.ItemFocused.SubItems[ 1 ] ), N ) then
    SetPriority( N );
end;

procedure TFrmAutoComplete.trmAutoCompleteTimer( Sender: TObject );
begin
  if ( not FEditCtrl.Focused ) and ( not ltvAutoComplete.Focused ) then
    Self.Close;
end;

procedure TFrmAutoComplete.PriorityStep( );
var
  Value: FixedInt;
begin
  Value := ltvAutoComplete.ItemFocused.SubItems[ 1 ].ToInteger( );
  Inc( Value );
  Self.SetPriority( Value );
end;

procedure TFrmAutoComplete.SetCommandCompare( AValue: string );
begin
  FCommandCompare := AValue;
  FCommandCompareLength := FCommandCompare.Length;
end;

procedure TFrmAutoComplete.SetPriority( AValue: FixedInt );
begin
  ltvAutoComplete.ItemFocused.SubItems[ 1 ] := IntToStr( AValue );
  FMemoryIniFile.WriteInteger( 'AutoComplete',
     ltvAutoComplete.ItemFocused.SubItems[ 0 ] + '.' +
     ltvAutoComplete.ItemFocused.Caption, AValue );
  ltvAutoComplete.Update( );
  FMemoryIniFile.UpdateFile( );
end;

procedure TFrmAutoComplete.ShowAutoComplete( );
var
  Point: TPoint;
begin
  Point := FEditCtrl.DisplayXY;
  Self.Top := FEditCtrl.ClientOrigin.Y + Point.Y + FEditCtrl.CharHeight + 2;
  Self.Left := FEditCtrl.ClientOrigin.X + Point.X + 2;
  trmAutoComplete.Enabled := True;
  Self.ForceShow( True );
  FEditCtrl.SetFocus;
  Self.ForceShow( False );
end;

procedure TFrmAutoComplete.ListViewAdd( ACaption, AOrigin: string );
var
  ListItem: TListItem;
begin
  if ACaption <> '' then
  begin
    ListItem := ltvAutoComplete.Items.Add;
    ListItem.ImageIndex := -1;
    ListItem.Caption := ACaption;
    ListItem.SubItems.Add( AOrigin );
    ListItem.SubItems.Add( FMemoryIniFile.ReadString( 'AutoComplete',
       AOrigin + '.' + ACaption, '0' ) );
    ListItem.Data := nil;
  end;
end;

procedure TFrmAutoComplete.ListViewAdd( AItem: TPGItem );
var
  ListItem: TListItem;
begin
  ListItem := ltvAutoComplete.Items.Add;
  ListItem.ImageIndex := -1;
  ListItem.Caption := AItem.Name;
  if Assigned( AItem.Parent ) then
    ListItem.SubItems.Add( AItem.Parent.Name )
  else
    ListItem.SubItems.Add( '' );
  ListItem.SubItems.Add( FMemoryIniFile.ReadString( 'AutoComplete',
     ListItem.SubItems[ 0 ] + '.' + ListItem.Caption, '0' ) );
  ListItem.Data := AItem;
end;

procedure TFrmAutoComplete.ProcurarComandos( ACommand: string );
var
  SubCMD: TArray< string >;
  Item: TPGItem;
  ItemAux: TPGItem;
  c, l: Integer;
begin
  SubCMD := SplitEx( ACommand, '.' );
  l := Length( SubCMD );
  if l = 1 then
  begin
    for Item in GlobalCollection do
    begin
      for ItemAux in Item.FindNameList( SubCMD[ 0 ], True ) do
      begin
        ListViewAdd( ItemAux );
      end;
    end;
    CommandCompare := SubCMD[ 0 ];
  end else begin
    Item := GlobalCollection;
    c := 0;
    repeat
      Item := FindID( Item, SubCMD[ c ] );
      Inc( c );
    until ( c > l - 2 ) or ( not Assigned( Item ) );

    if Assigned( Item ) then
      for ItemAux in Item.FindNameList( SubCMD[ c ], True ) do
      begin
        ListViewAdd( ItemAux );
      end;

    CommandCompare := SubCMD[ c ];
  end;
end;

procedure TFrmAutoComplete.FileNameList( AFileName: string );
var
  SearchRec: TSearchRec;
  c: Integer;
  d: Cardinal;
begin
  ChDir( PGofer.Sintatico.DirCurrent );

  c := FindFirst( AFileName + '*', faAnyFile, SearchRec );
  d := 0;
  while ( c = 0 ) and ( d < PGofer.Sintatico.FileListMax ) do
  begin
    if ( SearchRec.Attr and faDirectory ) = faDirectory then
      ListViewAdd( SearchRec.Name + '\', 'Directory' )
    else
      ListViewAdd( SearchRec.Name, 'File' );

    Inc( d );
    c := FindNext( SearchRec );
  end;

  FindClose( SearchRec );
  ChDir( PGofer.Sintatico.DirCurrent );
  CommandCompare := ExtractFileName( AFileName );
end;

procedure TFrmAutoComplete.FindCMD( );
var
  Automato: TAutomato;
  TokenList: TTokenList;
  Classe: TLexicoClass;
  Diretorio, Comando: string;
  SelStart: Integer;
begin
  // limpa tudo
  ltvAutoComplete.OnCompare := nil;
  ltvAutoComplete.Items.Clear( );

  // pega a posição do cursor texto
  SelStart := FEditCtrl.SelStart + FEditCtrl.CaretY - 1;

  // le o algoritimo
  Automato := TAutomato.Create( );
  TokenList := Automato.TokenListCreate( Copy( FEditCtrl.Text, 1, SelStart ) );
  Automato.Free;

  // procura o ultimo comando corrente
  TokenList.Position := 0;
  Classe := cmdEOF;
  Comando := '';
  while TokenList.Token.Classe <> cmdEOF do
  begin
    if ( TokenList.Token.Classe in [ cmdDot ] ) or ( Classe in [ cmdDot ] ) then
      Comando := Comando + TokenList.Token.Lexema
    else
      Comando := TokenList.Token.Lexema;
    Classe := TokenList.Token.Classe;
    TokenList.GetNextToken;
  end;
  TokenList.Free;

  // verificar se é arquivo
  if ( Classe = cmdString ) and ( Length( Comando ) > 2 ) then
    Diretorio := ExtractFilePath( FileExpandPath( Comando ) );

  if not DirectoryExists( Diretorio ) then
  begin
    if not( Classe in [ cmdNumeric, cmdComment ] ) then
      ProcurarComandos( Comando );
  end else begin
    FileNameList( Comando );
  end;

  // se encotrou seleciona no auto complete
  if ( ltvAutoComplete.Items.Count > 0 ) then
  begin
    ltvAutoComplete.OnCompare := ltvAutoCompleteCompare;
    ltvAutoComplete.AlphaSort;
    ShowAutoComplete( );
    ltvAutoComplete.SuperSelected( ltvAutoComplete.Items[ 0 ] );
    FEditCtrl.SetFocus;
  end else begin
    // se nao encontrou fecha
    Self.Close( );
  end;
end;

procedure TFrmAutoComplete.SelectCMD( ASelected: TSelectCMD );
var
  SelStart, SelConvert, SelInicio, SelFinal, LengthText: Integer;
begin
  if ( Self.Visible ) and ( ltvAutoComplete.Items.Count > 0 ) then
  begin
    LengthText := Length( FEditCtrl.Lines.Text );
    SelConvert := FEditCtrl.CaretY - 1;
    SelStart := FEditCtrl.SelStart + SelConvert;

    // localiza o final
    SelFinal := SelStart;
    while ( SelFinal < LengthText ) and
       ( not CharInSet( FEditCtrl.Lines.Text[ SelFinal ], Caracteres ) ) do
      Inc( SelFinal );
    SelFinal := SelFinal - SelConvert;

    // localiza o inicio
    SelInicio := SelStart;
    while ( SelInicio > 0 ) and
       ( not CharInSet( FEditCtrl.Lines.Text[ SelInicio ], Caracteres ) ) do
      Dec( SelInicio );

    SelInicio := SelInicio - SelConvert;

    // move selecao
    case ASelected of

      selUp:
        begin
          if ltvAutoComplete.ItemIndex > 0 then
            ltvAutoComplete.ItemIndex := ltvAutoComplete.ItemIndex - 1;
        end;

      selDown:
        begin
          if ltvAutoComplete.ItemIndex < ltvAutoComplete.Items.Count - 1 then
            ltvAutoComplete.ItemIndex := ltvAutoComplete.ItemIndex + 1;
        end;

      selEnter:
        begin
          FEditCtrl.SelStart := SelInicio;
          if SelFinal > SelInicio then
            FEditCtrl.SelLength := SelFinal - SelInicio - 1;
          FEditCtrl.SelText := ltvAutoComplete.ItemFocused.Caption;
          Self.PriorityStep( );
          Self.Close;
        end;
    end;

    ltvAutoComplete.SuperSelected( );
  end; // if count > 0
end;

end.
