unit PGofer.Forms.AutoComplete;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.IniFiles,
  System.Generics.Collections, Vcl.Controls, Vcl.ComCtrls, Vcl.Forms,
  Vcl.ExtCtrls, Vcl.StdCtrls, PGofer.Component.ListView,
  PGofer.Component.Form, PGofer.Component.IniFile,
  PGofer.Component.Memo, PGofer.Core, PGofer.Classes, PGofer.Forms, Vcl.Menus;

type
  TSelectCMD = (selClick, selUp, selDown, selEnter);

  TEditOnCtrl = record
    OnKeyDown: TOnKeyDownUP;
    OnKeyPress: TOnKeyPress;
    OnKeyUp: TOnKeyDownUP;
    OnDropFile: TOnDropFile;
    OnMouseUp: TMouseEvent;
  end;

  TPGFrmAutoComplete = class;

  TFrmAutoComplete = class(TFormEx)
    ltvAutoComplete: TListViewEx;
    ppmAutoComplete: TPopupMenu;
    mniPriority: TMenuItem;
    trmAutoComplete: TTimer;
    mmoAbout: TMemoEx;
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
    procedure mmoAboutDblClick(Sender: TObject);
    procedure ltvAutoCompleteMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FEditList: TDictionary<TMemoEx, TEditOnCtrl>;
    FEditCtrl: TMemoEx;
    FMemoryIniFile: TMemIniFileEx;
    FMemoryNoCtrl: Boolean;
    FMemoryList: TStringList;
    FMemoryPosition: Integer;
    FCommandCompare: string;
    FCommandCompareLength: Integer;
    FFileListMax: Cardinal;
    FKeyConsumed: Boolean;

    procedure ListViewAdd(const ACaption, AOrigin: string; AItem: TPGItem = nil); overload;
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
    property MemoryNoCtrl: Boolean read FMemoryNoCtrl write FMemoryNoCtrl;
    property FileListMax: Cardinal read FFileListMax write FFileListMax;
    procedure EditCtrlAdd(AValue: TMemoEx);
    procedure EditCtrlRemove(AValue: TMemoEx);
  end;

  {$M+}
  [TPGClassReg('Forms', 'FrmAutoComplete')]
  TPGFrmAutoComplete = class(TPGForm)
  private
    function GetFileListMax: Cardinal;
    procedure SetFileListMax(const AValue: Cardinal);
  protected
    function GetForm( ): TFrmAutoComplete; reintroduce;
    property Form: TFrmAutoComplete read GetForm;
  public
    procedure Frame(const AParent: TObject ); override;
  published
    property FileListMax: Cardinal read GetFileListMax write SetFileListMax;
  end;
 {$TYPEINFO ON}

var
  FrmAutoComplete: TFrmAutoComplete;

implementation

uses
  Vcl.Dialogs,
  PGofer.Lexico, PGofer.Runtime,
  PGofer.Sintatico.Controls, PGofer.Files.Controls, PGofer.Forms.Frame,
  PGofer3.Client;

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
  SetWindowLong(
    Application.Handle,
    GWL_EXSTYLE,
    GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_NOACTIVATE
  );
end;

procedure TFrmAutoComplete.FormCreate(Sender: TObject);
begin
  FMemoryIniFile := TMemIniFileEx.Create(TPGKernel.PathData + 'AutoComplete.ini');
  FMemoryNoCtrl := False;
  FMemoryPosition := 0;
  FMemoryList := TStringList.Create( );
  FFileListMax := 100;

  FEditList := TDictionary<TMemoEx, TEditOnCtrl>.Create( );
  FEditCtrl := nil;

  ltvAutoComplete.SmallImages := TPGItem.IconList;
  FrmAutoComplete.EditCtrlAdd( FrmPGofer.EdtScript );
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

procedure TFrmAutoComplete.EditCtrlAdd(AValue: TMemoEx);
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
    LOnCtrl.OnMouseUp := AValue.OnMouseUp;

    AValue.OnKeyDown := FormKeyDown;
    AValue.OnKeyPress := FormKeyPress;
    AValue.OnKeyUp := FormKeyUp;
    AValue.OnDropFiles := FormDropFile;
    AValue.OnMouseUp := FormMouseUp;

    FEditList.Add(AValue, LOnCtrl);
  end;
end;

procedure TFrmAutoComplete.EditCtrlRemove(AValue: TMemoEx);
var
  LOnCtrl: TEditOnCtrl;
begin
  if Assigned(FEditList) and FEditList.TryGetValue(AValue, LOnCtrl) then
  begin
    AValue.OnKeyDown := LOnCtrl.OnKeyDown;
    AValue.OnKeyPress := LOnCtrl.OnKeyPress;
    AValue.OnKeyUp := LOnCtrl.OnKeyUp;
    AValue.OnDropFiles := LOnCtrl.OnDropFile;
    AValue.OnMouseUp := LOnCtrl.OnMouseUp;

    FEditList.Remove(AValue);
  end;
end;

procedure TFrmAutoComplete.FormKeyDown( Sender: TObject; var Key: Word;
  Shift: TShiftState );
var
  c: Word;
  OnKeyDown: TOnKeyDownUP;
begin
  FKeyConsumed := False;

  if Self.Visible then
  begin
    case Key of
      VK_RETURN:
        begin
          Self.SelectCMD( selEnter );
          FKeyConsumed := True;
        end;

      VK_ESCAPE:
        begin
          Self.Close;
          FKeyConsumed := True;
        end;

      VK_UP:
        begin
          Self.SelectCMD( selUp );
          FKeyConsumed := True;
        end;

      VK_DOWN:
        begin
          Self.SelectCMD( selDown );
          FKeyConsumed := True;
        end;

//      VK_LEFT, VK_RIGHT:
//        begin
//          Self.FindCMD( );
//        end;
    end;
  end else begin
    if (not Assigned(Sender)) or (not (Sender is TMemoEx)) then
      exit;

    FEditCtrl := TMemoEx( Sender );
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
            FKeyConsumed := True;
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
              FKeyConsumed := True;
            end;
          end;
        end;
    end;

    if not FKeyConsumed then
    begin
      OnKeyDown := FEditList.Items[FEditCtrl].OnKeyDown;
      if Assigned(OnKeyDown) then
        OnKeyDown(Sender, Key, Shift);
    end;
  end;

  if FKeyConsumed then
    Key := 0;

end;

procedure TFrmAutoComplete.FormKeyPress( Sender: TObject; var Key: Char );
var
  OnKeyPress: TOnKeyPress;
begin
  if (not Assigned(Sender)) or (not (Sender is TMemoEx)) then
    Exit;

  FEditCtrl := TMemoEx( Sender );

  if FKeyConsumed then
  begin
    Key := #0;
    Exit;
  end;

  if (Key = #13) and SameText(FEditCtrl.Owner.Name, 'FrmPGofer') then
  begin
    FKeyConsumed := True;
    Key := #0;
    Exit;
  end;

//  if (Key = #13) or (Key = #27) then
//  begin
//    Key := #0;
//  end;
//
//  if ( Key = ' ' ) and ( GetKeyState( VK_CONTROL ) < 0 ) then
//  begin
//    Key := #0;
//  end;

  if Key <> #0 then
  begin
    OnKeyPress := FEditList.Items[FEditCtrl].OnKeyPress;
    if Assigned(OnKeyPress) then
      OnKeyPress(Sender, Key);
  end;
end;

procedure TFrmAutoComplete.FormKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
var
  OnKeyUp: TOnKeyDownUP;
begin
  if (not Assigned(Sender)) or (not (Sender is TMemoEx)) then
    Exit;

  FEditCtrl := TMemoEx( Sender );

  if FKeyConsumed then
  begin
    Key := 0;
    FKeyConsumed := False;
    Exit;
  end;

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

      VK_LEFT, VK_RIGHT:
        begin
          Self.FindCMD();
        end;
    end; // case

  if Key <> 0  then
  begin
    OnKeyUp := FEditList.Items[ FEditCtrl ].OnKeyUp;
    if Assigned( OnKeyUp ) then
      OnKeyUp( Sender, Key, Shift );
  end;
end;

procedure TFrmAutoComplete.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  OnMouseUp: TMouseEvent;
begin
  if (not Assigned(Sender)) or (not (Sender is TMemoEx)) then
    Exit;

  FEditCtrl := TMemoEx(Sender);

  //Self.FindCMD();
  Self.Close;

  OnMouseUp := FEditList.Items[FEditCtrl].OnMouseUp;
  if Assigned(OnMouseUp) then
    OnMouseUp(Sender, Button, Shift, X, Y);
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

        LDiretorio := '';
        if (LKind = pgkString) and (Length(LComando) > 0) then
        begin
          LDiretorio := ExtractFilePath(FileExpandPath(LComando));
        end;

        if (LDiretorio <> '') and DirectoryExists(LDiretorio) then
        begin
          FileNameList(LComando);
        end
        else
        begin
          if not (LKind in [pgkNumber]) then
            ProcurarComandos(LComando);
        end;

      finally
        LTokens.Free;
      end;
    finally
      LLexer.Free;
    end;

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

procedure TFrmAutoComplete.SelectCMD(ASelected: TSelectCMD);
var
  SelAtual, SelInicio, SelFinal: Integer;
  Texto: string;
  SuperSelect: Boolean;
begin
  SuperSelect := True;
  if (Self.Visible) and (ltvAutoComplete.Items.Count > 0) then
  begin
    SelAtual := FEditCtrl.SelStart;
    Texto := FEditCtrl.Text;

    SelInicio := SelAtual;
    while (SelInicio > 0) and (not CharInSet(Texto[SelInicio], Caracteres)) do
      Dec(SelInicio);

    SelFinal := SelAtual;
    while (SelFinal < Length(Texto)) and (not CharInSet(Texto[SelFinal + 1], Caracteres)) do
      Inc(SelFinal);

    case ASelected of
      selClick: SuperSelect := False;

      selUp:
        if ltvAutoComplete.ItemIndex > 0 then
          ltvAutoComplete.ItemIndex := ltvAutoComplete.ItemIndex - 1;

      selDown:
        if ltvAutoComplete.ItemIndex < ltvAutoComplete.Items.Count - 1 then
          ltvAutoComplete.ItemIndex := ltvAutoComplete.ItemIndex + 1;

      selEnter:
        begin
          FEditCtrl.SelStart := SelInicio;
          FEditCtrl.SelLength := SelFinal - SelInicio;
          FEditCtrl.SelText := ltvAutoComplete.ItemFocused.Caption;

          Self.PriorityStep;
          Self.Close;
        end;
    end;

    if SuperSelect then
      ltvAutoComplete.SuperSelected;
    Self.About;
  end;
end;

procedure TFrmAutoComplete.ProcurarComandos(const ACommand: string);
var
  LSubCMD: TArray<string>;
  LSearchText: string;
  LItem: TPGItem;
  LFound: TPGItem;
  LKeyword: string;
  Index: Integer;
begin
  LSubCMD := ACommand.Split(['.']);
  if Length(LSubCMD) = 0 then Exit;

  LSearchText := LSubCMD[High(LSubCMD)];
  CommandCompare := LSearchText;

  ltvAutoComplete.Items.BeginUpdate;
  try
    if Length(LSubCMD) <= 1 then
    begin
      for LKeyword in TPGLexicalRegistry.Keywords.Keys do
      begin
        if (LSearchText = '') or (Pos(LowerCase(LSearchText), LowerCase(LKeyword)) > 0) then
          ListViewAdd(LKeyword, 'Keyword');
      end;

      for LItem in TPGItem.FindNameList(nil, LSearchText) do
        ListViewAdd(LItem);

    end else begin
      LFound := TPGItem.FindName(nil, LSubCMD[0]);
      for Index := 1 to High(LSubCMD) - 1 do
        if Assigned(LFound) then LFound := LFound.FindName(LSubCMD[Index]);

      if Assigned(LFound) then
      begin
        if LFound is TPGItemExecute then TPGItemExecute(LFound).BeforeAccess;
        for LItem in LFound.FindNameList(LSearchText) do
          ListViewAdd(LItem);
      end;
    end;
  finally
    ltvAutoComplete.Items.EndUpdate;
  end;
end;

procedure TFrmAutoComplete.ListViewAdd(const ACaption, AOrigin: string; AItem: TPGItem = nil);
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
  if Assigned(AItem) then
  begin
     ListItem.ImageIndex := AItem.IconIndex;
     ListItem.OverlayIndex := AItem.OverlayIndex;
  end;
  ListItem.Data := AItem;
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
  if (not Assigned(Sender)) or (not (Sender is TMemoEx)) then
    Exit;

  FEditCtrl := TMemoEx( Sender );

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
  mmoAbout.Text :=  '';
  //inherited FormClose( Sender, Action );
end;

procedure TFrmAutoComplete.IniConfigLoad( );
begin
  inherited IniConfigLoad( );
  ltvAutoComplete.IniConfigLoad( IniFile, Self.Name, 'List' );
  mmoAbout.Zoom := IniFile.ReadInteger(Self.Name, 'AboutZoom', mmoAbout.Zoom);
  mmoAbout.Height := IniFile.ReadInteger(Self.Name, 'AboutHeight', mmoAbout.Height);
end;

procedure TFrmAutoComplete.IniConfigSave;
begin
  IniFile.WriteInteger(Self.Name, 'AboutZoom', mmoAbout.Zoom);
  IniFile.WriteInteger(Self.Name, 'AboutHeight', mmoAbout.Height);
  ltvAutoComplete.IniConfigSave( IniFile, Self.Name, 'List' );
  inherited IniConfigSave( );
end;

procedure TFrmAutoComplete.mmoAboutDblClick(Sender: TObject);
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
  mmoAbout.Text := '';

  if Assigned(ltvAutoComplete.ItemFocused)
  and Assigned(ltvAutoComplete.ItemFocused.Data) then
    mmoAbout.Text := TPGItem(ltvAutoComplete.ItemFocused.Data).About;
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
  LPath := FileExpandPath(AFileName);

  LFilter := ExtractFileName(LPath);
  LPath := ExtractFilePath(LPath);
  if LPath = '' then LPath := TPGKernel.PathCurrent;

  CommandCompare := LFilter;
  LCount := 0;
  if FindFirst(LPath + LFilter + '*', faAnyFile, LSearchRec) = 0 then
  begin
    repeat
      if (LSearchRec.Name = '.') then //or (LSearchRec.Name = '..')
        Continue;

      if (LSearchRec.Attr and faDirectory) = faDirectory then
        ListViewAdd(LSearchRec.Name + '\', 'Directory')
      else
        ListViewAdd(LSearchRec.Name, 'File');

      Inc(LCount);
    until (FindNext(LSearchRec) <> 0) or (LCount >= FFileListMax);
    FindClose(LSearchRec);
  end;
end;

procedure TPGFrmAutoComplete.Frame(const AParent: TObject );
begin
  TPGFormsFrame.Create( Self, AParent );
end;

function TPGFrmAutoComplete.GetFileListMax(): Cardinal;
begin
  Result := Self.Form.FileListMax;
end;

function TPGFrmAutoComplete.GetForm: TFrmAutoComplete;
begin
  Result := TFrmAutoComplete(inherited Form);
end;

procedure TPGFrmAutoComplete.SetFileListMax(const AValue: Cardinal);
begin
  Self.Form.FileListMax := AValue;
end;

end.

