unit PGofer.Forms.AutoComplete;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.IniFiles,
  System.Generics.Collections, Vcl.Controls, Vcl.ComCtrls, Vcl.Forms, Vcl.Menus,
  Vcl.ExtCtrls, Vcl.StdCtrls, PGofer.Component.ListView, PGofer.Component.RichEdit,
  PGofer.Component.Form, PGofer.Component.IniFile, PGofer.Classes, PGofer.Forms;

type
  TSelectCMD = (selClick, selUp, selDown, selEnter);

  TEditOnCtrl = record
    OnKeyDown: TOnKeyDownUP;
    OnKeyPress: TOnKeyPress;
    OnKeyUp: TOnKeyDownUP;
    OnDropFile: TOnDropFile;
  end;

  TPGFrmAutoComplete = class;

  TFrmAutoComplete = class(TFormEx)
    ltvAutoComplete: TListViewEx;
    ppmAutoComplete: TPopupMenu;
    mniPriority: TMenuItem;
    trmAutoComplete: TTimer;
    rceAbout: TRichEditEx;
    sptAbout: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDropFile(Sender: TObject; AFiles: TStrings);
    procedure mniPriorityClick(Sender: TObject);
    procedure trmAutoCompleteTimer(Sender: TObject);
    procedure ltvAutoCompleteDblClick(Sender: TObject);
    procedure ltvAutoCompleteCompare( Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer );
    procedure rceAboutDblClick(Sender: TObject);
    procedure ltvAutoCompleteMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
  private
    FEditList: TDictionary<TRichEditEx, TEditOnCtrl>;
    FEditCtrl: TRichEditEx;
    FMemoryIniFile: TMemIniFileEx;
    FMemoryNoCtrl: Boolean;
    FMemoryList: TStringList;
    FMemoryPosition: Integer;
    FCommandCompare: string;
    FCommandCompareLength: Integer;
    FItem: TPGFrmAutoComplete;

    procedure ListViewAdd(const ACaption, AOrigin: string; AData: Pointer = nil); overload;
    procedure ListViewAdd(AItem: TPGItem); overload;
    procedure PriorityStep();
    procedure SetPriority( AValue: FixedInt );
    procedure About();
    procedure ProcurarComandos(const ACommand: string);
    procedure FileNameList(const AFileName: string);
    procedure FindCMD;
    procedure SelectCMD(ASelected: TSelectCMD);
    procedure SetCommandCompare(const AValue: string);
    property CommandCompare: string read FCommandCompare write SetCommandCompare;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure IniConfigSave; override;
    procedure IniConfigLoad; override;
  public
    property MemoryNoCtrl: Boolean read FMemoryNoCtrl write FMemoryNoCtrl default True;
    procedure EditCtrlAdd(AValue: TRichEditEx);
    procedure EditCtrlRemove(AValue: TRichEditEx);
  end;

{$M+}

  TPGFrmAutoComplete = class(TPGForm)
  private
    FFileListMax: Cardinal;
  public
    constructor Create(AForm: TForm); reintroduce;
    destructor Destroy; override;
    procedure Frame( AParent: TObject ); override;
  published
    property FileListMax: Cardinal read FFileListMax write FFileListMax;
  end;
{$TYPEINFO ON}

var
  FrmAutoComplete: TFrmAutoComplete;

implementation

uses
  Vcl.Dialogs,
  PGofer.Core, PGofer.Lexico, PGofer.Runtime, PGofer.Sintatico,
  PGofer.Sintatico.Controls, PGofer.Files.Controls, PGofer.Forms.Frame;

{$R *.dfm}

const
  Caracteres: TSysCharSet = [#0 .. #32, ',', ';', ':', '=', '+', '-', '*', '/', '\', '<', '>', '(',
    ')', '[', ']', '!', '@', '#', '$', '%', '^', '&', '?', '|', '.', '"', #39];

  { TFrmAutoComplete }

procedure TFrmAutoComplete.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.Style := AParams.Style or WS_BORDER;
  AParams.ExStyle := WS_EX_NOACTIVATE;
  Application.AddPopupForm( Self );
  Self.ForceResizable := True;
end;

procedure TFrmAutoComplete.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_NOACTIVATE);
end;

procedure TFrmAutoComplete.FormCreate(Sender: TObject);
begin
  FItem := TPGFrmAutoComplete.Create(Self);

  FMemoryIniFile := TMemIniFileEx.Create(TPGKernel.PathCurrent + 'AutoComplete.ini');
  FMemoryNoCtrl := False;
  FMemoryPosition := 0;
  FMemoryList := TStringList.Create( );

  FEditList := TDictionary<TRichEditEx, TEditOnCtrl>.Create( );
  FEditCtrl := nil;
end;

procedure TFrmAutoComplete.FormDestroy(Sender: TObject);
begin
  FEditCtrl := nil;
  FEditList.Clear( );
  FEditList.Free( );
  FEditList := nil;
  FMemoryIniFile.Free( );
  FMemoryIniFile := nil;
  FMemoryList.Free( );
  FMemoryList := nil;
  FMemoryPosition := 0;
  FMemoryNoCtrl := False;
end;

procedure TFrmAutoComplete.EditCtrlAdd(AValue: TRichEditEx);
var
  LOnCtrl: TEditOnCtrl;
begin
  if Assigned(FEditList) and Assigned(AValue)
  and not FEditList.ContainsKey(AValue) then
  begin
    LOnCtrl.OnKeyDown := AValue.OnKeyDown;
    LOnCtrl.OnKeyPress := AValue.OnKeyPress;
    LOnCtrl.OnKeyUp := AValue.OnKeyUp;
    LOnCtrl.OnDropFile := AValue.OnDropFiles;

    AValue.OnKeyDown := FormKeyDown;
    AValue.OnKeyPress := FormKeyPress;
    AValue.OnKeyUp := FormKeyUp;
    AValue.OnDropFiles := FormDropFile;

    FEditList.Add(AValue, LOnCtrl);
  end;
end;

procedure TFrmAutoComplete.EditCtrlRemove(AValue: TRichEditEx);
var
  LOnCtrl: TEditOnCtrl;
begin
  if Assigned(FEditList) and FEditList.TryGetValue(AValue, LOnCtrl) then
  begin
    AValue.OnKeyDown := LOnCtrl.OnKeyDown;
    AValue.OnKeyPress := LOnCtrl.OnKeyPress;
    AValue.OnKeyUp := LOnCtrl.OnKeyUp;
    AValue.OnDropFiles := LOnCtrl.OnDropFile;
    FEditList.Remove(AValue);
  end;
end;

procedure TFrmAutoComplete.FormKeyDown( Sender: TObject; var Key: Word;
  Shift: TShiftState );
var
  c: Word;
  OnKeyDown: TOnKeyDownUP;
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
    if (not Assigned(Sender)) or (not (Sender is TRichEditEx)) then
      exit;

    FEditCtrl := TRichEditEx( Sender );
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
          if ( Shift = [ ssCtrl ] ) then
          begin
            Self.FindCMD( );
            Key := 0;
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
    OnKeyDown := FEditList.Items[ FEditCtrl ].OnKeyDown;
    if Assigned( OnKeyDown ) then
      OnKeyDown( Sender, Key, Shift );
  end;
end;

procedure TFrmAutoComplete.FormKeyPress( Sender: TObject; var Key: Char );
var
  OnKeyPress: TOnKeyPress;
begin
  if (not Assigned(Sender)) or (not (Sender is TRichEditEx)) then
    exit;

  FEditCtrl := TRichEditEx( Sender );
  if ( Key = ' ' ) and ( GetKeyState( VK_CONTROL ) < 0 ) then
  begin
    Key := #0;
  end;
  OnKeyPress := FEditList.Items[ FEditCtrl ].OnKeyPress;
  if Assigned( OnKeyPress ) then
    OnKeyPress( Sender, Key );
end;

procedure TFrmAutoComplete.FormKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
var
  OnKeyUp: TOnKeyDownUP;
begin
  if (not Assigned(Sender)) or (not (Sender is TRichEditEx)) then
    exit;

  FEditCtrl := TRichEditEx( Sender );
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

  OnKeyUp := FEditList.Items[ FEditCtrl ].OnKeyUp;
  if Assigned( OnKeyUp ) then
    OnKeyUp( Sender, Key, Shift );
end;

procedure TFrmAutoComplete.FindCMD;
var
  LLexer: TPGLexer;
  LTokens: TPGTokenList;
  LTokenAux: TPGToken;
  LComando, LDiretorio: string;
  LLineIndex, LCharPos, I: Integer;
  LTextLine: string;
  LKind: TPGTokenKind;
  LPoint: TPoint;
begin
  if (FEditCtrl = nil) then Exit;

  LLineIndex := FEditCtrl.CaretY - 1;
  LTextLine := FEditCtrl.Lines[LLineIndex];
  LCharPos := FEditCtrl.SelStart - FEditCtrl.Perform(EM_LINEINDEX, LLineIndex, 0);

  // Se a linha estiver vazia e não for o prompt, sai
  if (LTextLine = '') and (FEditCtrl.Owner.Name <> 'FrmPGofer') then
  begin
    Self.Close;
    Exit;
  end;

  ltvAutoComplete.Items.BeginUpdate;
  try
    ltvAutoComplete.OnCompare := nil;
    ltvAutoComplete.Items.Clear;

    LLexer := TPGLexer.Create;
    try
      LTokens := TPGTokenList.Create;
      try
        LLexer.Tokenize(Copy(LTextLine, 1, LCharPos), LTokens);

        LComando := '';
        LKind := pgkUnknown;

        for I := 0 to LTokens.Count - 1 do
        begin
          LTokenAux := LTokens.Items[I];

          if (LTokenAux.Kind = pgkSemiColon) or (LTokenAux.Kind = pgkEqual) then
          begin
            LComando := '';
            LKind := pgkUnknown;
            Continue;
          end;

          if (LTokenAux.Kind <> pgkEOF) then
          begin
            if (LTokenAux.Kind = pgkDot) or (LKind = pgkDot) then
              LComando := LComando + LTokenAux.Value.ToString
            else
              LComando := LTokenAux.Value.ToString;

            LKind := LTokenAux.Kind;
          end;
        end;

        // --- LÓGICA DO SISTEMA ANTIGO (RESTURADA E MELHORADA) ---
        LDiretorio := '';

        // Se for uma string, verificamos se ela aponta para um diretório real
        if (LKind = pgkString) and (Length(LComando) > 0) then
        begin
          // FileExpandPath resolve ./ e ../ e nomes de drivers
          LDiretorio := ExtractFilePath(FileExpandPath(LComando));
        end;

        // REGRA: Se o diretório existe (ex: 'C:\', './'), lista arquivos.
        // CASO CONTRÁRIO (mesmo que seja string), sugere comandos/objetos.
        if (LDiretorio <> '') and DirectoryExists(LDiretorio) then
        begin
          FileNameList(LComando);
        end
        else
        begin
          // Se não for número ou comentário, procura comandos
          if not (LKind in [pgkNumber]) then
            ProcurarComandos(LComando);
        end;

      finally
        LTokens.Free;
      end;
    finally
      LLexer.Free;
    end;

    // ... Lógica de Exibição VCL (Inalterada) ...
    if ltvAutoComplete.Items.Count > 0 then
    begin
      ltvAutoComplete.OnCompare := ltvAutoCompleteCompare;
      ltvAutoComplete.AlphaSort;
      LPoint := FEditCtrl.DisplayXY;
      Self.Top := FEditCtrl.ClientOrigin.Y + LPoint.Y + FEditCtrl.CharHeight + 2;
      Self.Left := FEditCtrl.ClientOrigin.X + LPoint.X + 2;
      if not Self.Visible then Self.ForceShow(False);
      ltvAutoComplete.ItemIndex := 0;
      ltvAutoComplete.SuperSelected(ltvAutoComplete.Items[0]);
      About;
      FEditCtrl.SetFocus;
    end
    else
      Self.Close;

  finally
    ltvAutoComplete.Items.EndUpdate;
  end;
end;

procedure TFrmAutoComplete.SelectCMD( ASelected: TSelectCMD );
var
  SelStart, SelConvert, SelInicio, SelFinal, LengthText: Integer;
  SuperSelect : Boolean;
begin
  SuperSelect := true;
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
      selClick:
      begin
          SuperSelect := False;
      end;

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

    if SuperSelect then
       ltvAutoComplete.SuperSelected( );
    Self.About();
  end; // if count > 0
end;

procedure TFrmAutoComplete.ProcurarComandos(const ACommand: string);
var
  LSubCMD: TArray<string>;
  LItem, LItemAux: TPGItem;
  I: Integer;
  LKeyword: string;
  LSearchText: string;
begin
  // 1. PROTEÇÃO INICIAL: Se não houver o que pesquisar, limpa e sai
  LSubCMD := ACommand.Split(['.']);

  if Length(LSubCMD) = 0 then
  begin
    //CommandCompare := '';
    //LSearchText := '';
    Exit;
  end;

  // Pega o último fragmento com segurança
  LSearchText := LSubCMD[High(LSubCMD)];
  CommandCompare := LSearchText;

  // 2. PESQUISA RAIZ (Keywords + Globais)
  // Ocorre quando não há pontos no comando OU quando o array tem apenas 1 elemento
  if Length(LSubCMD) <= 1 then
  begin
    // Busca parcial em Keywords
    for LKeyword in TPGLexicalRegistry.Keywords.Keys do
    begin
      // Se ACommand for vazio (Ctrl+Space puro), mostra todas as Keywords
      if (LSearchText = '') or (Pos(LowerCase(LSearchText), LowerCase(LKeyword)) > 0) then
        ListViewAdd(LKeyword, 'Keyword');
    end;

    // Busca em Itens Globais
    if Assigned(GlobalCollection) then
    begin
      for LItem in GlobalCollection do
      begin
        if Assigned(LItem) then
          for LItemAux in LItem.FindNameList(LSearchText, True) do
            ListViewAdd(LItemAux);
      end;
    end;
  end
  // 3. PESQUISA HIERÁRQUICA (Ex: Link1.Prop)
  else
  begin
    LItem := GlobalCollection;

    // Navega com segurança até o penúltimo nível
    for I := 0 to High(LSubCMD) - 1 do
    begin
      if Assigned(LItem) then
      begin
        LItem := FindID(LItem, LSubCMD[I]);
      end else
        Break;
    end;

    // Se encontrou o objeto pai, lista o que tem dentro dele
    if Assigned(LItem) then
    begin
      if Assigned(LItem) and (LItem is TPGItemExecute) then
         TPGItemExecute(LItem).BeforeAccess;

      for LItemAux in LItem.FindNameList(LSearchText, True) do
        if LItemAux <> LItem then
          ListViewAdd(LItemAux);
    end;
  end;
end;

procedure TFrmAutoComplete.ListViewAdd(const ACaption, AOrigin: string; AData: Pointer);
var
  ListItem: TListItem;
  LOrigin : String;
begin
  if (ACaption = '') or (ACaption = '.') then Exit;

  ListItem := ltvAutoComplete.Items.Add;
  ListItem.Caption := ACaption;
  ListItem.SubItems.Add(AOrigin);
  LOrigin := FMemoryIniFile.ReadString('AutoComplete', AOrigin + '.' + ACaption, '0');
  ListItem.SubItems.Add(LOrigin);
  ListItem.Data := AData;
end;

procedure TFrmAutoComplete.ListViewAdd(AItem: TPGItem);
var
 LOrigin: String;
begin
  if Assigned( AItem.Parent ) then
    LOrigin := AItem.Parent.Name
  else
    LOrigin := 'Global';

  ListViewAdd(AItem.Name, LOrigin, AItem);
end;

procedure TFrmAutoComplete.FormDropFile(Sender: TObject; AFiles: TStrings);
var
  OnDrop: TOnDropFile;
begin
  if (not Assigned(Sender)) or (not (Sender is TRichEditEx)) then
    Exit;

  FEditCtrl := TRichEditEx( Sender );

  if AFiles.Text <> '' then
  begin
    FEditCtrl.Lines.Add( AFiles.Text );
  end;

  OnDrop := FEditList.Items[ FEditCtrl ].OnDropFile;
  if Assigned( OnDrop ) then
    OnDrop( Sender, AFiles );
end;

procedure TFrmAutoComplete.FormShow(Sender: TObject);
var
  Point: TPoint;
begin
  inherited;
  Point := FEditCtrl.DisplayXY;
  Self.Top := FEditCtrl.ClientOrigin.Y + Point.Y + FEditCtrl.CharHeight + 2;
  Self.Left := FEditCtrl.ClientOrigin.X + Point.X + 2;
  trmAutoComplete.Enabled := True;
  Self.ForceShow( False );
end;

procedure TFrmAutoComplete.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  trmAutoComplete.Enabled := False;
  rceAbout.Text :=  '';
  //inherited FormClose( Sender, Action );
end;

procedure TFrmAutoComplete.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  ltvAutoComplete.IniConfigLoad( IniFile, Self.Name, 'List' );
  rceAbout.Height := IniFile.ReadInteger(Self.Name, 'AboutHeight', 20);
end;

procedure TFrmAutoComplete.IniConfigSave;
begin
  IniFile.WriteInteger(Self.Name, 'AboutHeight', rceAbout.Height);
  ltvAutoComplete.IniConfigSave( IniFile, Self.Name, 'List' );
  inherited IniConfigSave( );
end;

procedure TFrmAutoComplete.rceAboutDblClick(Sender: TObject);
begin
  inherited;
  // autocompleta com parametros
end;

procedure TFrmAutoComplete.ltvAutoCompleteMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SelectCMD(selClick);
end;

procedure TFrmAutoComplete.trmAutoCompleteTimer(Sender: TObject);
begin
  if (FEditCtrl <> nil) and (not FEditCtrl.Focused) and (not ltvAutoComplete.Focused) then
    Self.Close;
end;

procedure TFrmAutoComplete.ltvAutoCompleteDblClick(Sender: TObject);
begin
  SelectCMD(selEnter);
end;

procedure TFrmAutoComplete.ltvAutoCompleteCompare( Sender: TObject;
  Item1, Item2: TListItem; Data: Integer; var Compare: Integer );
var
  v1, v2: Integer;
  b1, b2: Boolean;
begin
  v1 := 0;
  b1 := False;
  if Assigned( Item1 ) then
  begin
    if ( Item1.SubItems.Count > 1 ) then
      TryStrToInt( Item1.SubItems[ 1 ], v1 );

    b1 := SameText( Copy( Item1.Caption, LOW_STRING, FCommandCompareLength ),
      FCommandCompare );
  end;

  v2 := 0;
  b2 := False;
  if Assigned( Item2 ) then
  begin
    if ( Item2.SubItems.Count > 1 ) then
      TryStrToInt( Item2.SubItems[ 1 ], v2 );

    b2 := SameText( Copy( Item2.Caption, LOW_STRING, FCommandCompareLength ),
      FCommandCompare );
  end;

  if b1 xor b2 then
  begin
    if b1 then
      Compare := 0
    else
      Compare := 1;
  end
  else
    Compare := v2 - v1;
end;

procedure TFrmAutoComplete.mniPriorityClick(Sender: TObject);
var
  N: Integer;
begin
  if (ltvAutoComplete.ItemFocused <> nil) and
    TryStrToInt(InputBox('Priority', 'Value', ltvAutoComplete.ItemFocused.SubItems[1]), N) then
    Self.SetPriority(N);
end;

procedure TFrmAutoComplete.PriorityStep( );
var
  Value: FixedInt;
begin
  Value := ltvAutoComplete.ItemFocused.SubItems[ 1 ].ToInteger( );
  Inc( Value );
  Self.SetPriority( Value );
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

procedure TFrmAutoComplete.About();
begin
  rceAbout.Text := '';

  if Assigned(ltvAutoComplete.ItemFocused)
  and Assigned(ltvAutoComplete.ItemFocused.Data) then
    rceAbout.Text := TPGItem(ltvAutoComplete.ItemFocused.Data).About;
end;

procedure TFrmAutoComplete.SetCommandCompare(const AValue: string);
begin
  FCommandCompare := AValue;
  FCommandCompareLength := FCommandCompare.Length;
end;

procedure TFrmAutoComplete.FileNameList(const AFileName: string);
var
  LSearchRec: TSearchRec;
  LCount: Cardinal;
  LPath, LFilter: string;
begin
  ChDir( TPGKernel.PathCurrent );
  // Resolve o caminho completo para a busca
  LPath := FileExpandPath(AFileName);

  LFilter := ExtractFileName(LPath); // O que o usuário já começou a digitar do nome
  LPath := ExtractFilePath(LPath);   // A pasta onde vamos buscar

  // Se o caminho estiver vazio após o expand, usa a pasta atual do PGofer
  if LPath = '' then LPath := TPGKernel.PathCurrent;

  CommandCompare := LFilter; // Define para o ltvAutoCompleteCompare priorizar o texto
  LCount := 0;
  if FindFirst(LPath + LFilter + '*', faAnyFile, LSearchRec) = 0 then
  begin
    repeat
      // FILTRO: Ignora "." e ".." para não sujar a lista
      if (LSearchRec.Name = '.') or (LSearchRec.Name = '..') then
        Continue;

      if (LSearchRec.Attr and faDirectory) = faDirectory then
        ListViewAdd(LSearchRec.Name + '\', 'Directory')
      else
        ListViewAdd(LSearchRec.Name, 'File');

      Inc(LCount);
    until (FindNext(LSearchRec) <> 0) or (LCount >= FItem.FileListMax);
    FindClose(LSearchRec);
  end;
end;

constructor TPGFrmAutoComplete.Create(AForm: TForm);
begin
  inherited Create(AForm);
  FFileListMax := 100;
end;

destructor TPGFrmAutoComplete.Destroy;
begin
  inherited;
end;

procedure TPGFrmAutoComplete.Frame( AParent: TObject );
begin
  TPGFormsFrame.Create( Self, AParent );
end;

end.
