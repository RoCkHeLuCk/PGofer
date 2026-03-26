unit PGofer.Forms.AutoComplete;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils,
  System.IniFiles, System.Generics.Collections, Vcl.Controls, Vcl.ComCtrls,
  Vcl.Forms, Vcl.Menus, Vcl.ExtCtrls, Vcl.StdCtrls,
  PGofer.Component.ListView, PGofer.Component.RichEdit, PGofer.Component.Form,
  PGofer.Component.IniFile, PGofer.Classes, PGofer.Forms;

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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDropFile(Sender: TObject; AFiles: TStrings);
    procedure mniPriorityClick(Sender: TObject);
    procedure trmAutoCompleteTimer(Sender: TObject);
    procedure ltvAutoCompleteDblClick(Sender: TObject);
    procedure ltvAutoCompleteCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure ltvAutoCompleteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
  private
    FEditList: TDictionary<TRichEditEx, TEditOnCtrl>;
    FEditCtrl: TRichEditEx;
    FMemoryIniFile: TMemIniFileEx;
    FMemoryNoCtrl: Boolean;
    FMemoryList: TStringList;
    FMemoryPosition: Integer;
    FPartialWord: string; // O que o usuário está digitando no momento
    FItem: TPGFrmAutoComplete;

    procedure ListViewAdd(const ACaption, AOrigin: string; AData: Pointer = nil); overload;
    procedure ListViewAdd(AItem: TPGItem); overload;
    procedure PriorityStep;
    procedure SetPriority(AValue: Integer);
    procedure UpdateAbout;
    procedure ProcurarComandos(const ACommand: string);
    procedure FileNameList(const AFileName: string);
    procedure FindCMD;
    procedure SelectCMD(ASelected: TSelectCMD);
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
  PGofer.Sintatico.Controls, PGofer.Files.Controls;

{$R *.dfm}

const
  Delimitadores: TSysCharSet = [#0..#32, ',', ';', ':', '=', '+', '-', '*', '/', '\',
                                '<', '>', '(', ')', '[', ']', '!', '@', '#', '$',
                                '%', '^', '&', '?', '|', '.', '"', #39];

{ TFrmAutoComplete }

procedure TFrmAutoComplete.CreateParams( var AParams: TCreateParams );
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
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_NOACTIVATE
                or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
end;

procedure TFrmAutoComplete.FormCreate(Sender: TObject);
begin
  FItem := TPGFrmAutoComplete.Create(Self);
  FMemoryIniFile := TMemIniFileEx.Create(TPGKernel.PathCurrent + 'AutoComplete.ini');
  FMemoryList := TStringList.Create;
  FEditList := TDictionary<TRichEditEx, TEditOnCtrl>.Create;
  FMemoryNoCtrl := False;
  FMemoryPosition := 0;
end;

procedure TFrmAutoComplete.FormDestroy(Sender: TObject);
begin
  // Evita vazamento: O dicionário deve ser limpo e as referências aos controles removidas
  FEditList.Free;
  FMemoryIniFile.Free;
  FMemoryList.Free;
end;

procedure TFrmAutoComplete.FormDropFile(Sender: TObject; AFiles: TStrings);
begin
  //asdfsadf
end;

procedure TFrmAutoComplete.UpdateAbout;
begin
  rceAbout.Text := '';
  if Assigned(ltvAutoComplete.ItemFocused) and Assigned(ltvAutoComplete.ItemFocused.Data) then
    rceAbout.Text := TPGItem(ltvAutoComplete.ItemFocused.Data).About;
end;

procedure TFrmAutoComplete.FindCMD;
var
  LLexer: TPGLexer;
  LTokens: TPGTokenList;
  LPoint: TPoint;
  LSelStart: Integer;
begin
  if (FEditCtrl = nil) or (FEditCtrl.Text = '') then
  begin
    Self.Close;
    Exit;
  end;

  // 1. POSICIONAMENTO DINÂMICO
  LPoint := FEditCtrl.DisplayXY;
  Self.Top := FEditCtrl.ClientOrigin.Y + LPoint.Y + FEditCtrl.CharHeight + 2;
  Self.Left := FEditCtrl.ClientOrigin.X + LPoint.X + 2;

  ltvAutoComplete.Items.BeginUpdate;
  try
    ltvAutoComplete.Items.Clear;
    FPartialWord := '';
    LSelStart := FEditCtrl.SelStart;

    // 2. LÉXICO PARA CONTEXTO (Garante limpeza de memória com try..finally)
    LLexer := TPGLexer.Create;
    try
      LTokens := TPGTokenList.Create();
      LLexer.Tokenize(Copy(FEditCtrl.Text, 1, LSelStart), LTokens);
      try
        if LTokens.Count > 1 then
        begin
          LTokens.Position := LTokens.Count - 2; // Último token antes do EOF
          if LTokens.Current <> nil then
          begin
            FPartialWord := LTokens.Current.Value.ToString;

            if LTokens.Current.Kind = tkString then
              FileNameList(FPartialWord)
            else
              ProcurarComandos(FPartialWord);
          end;
        end;
      finally
        LTokens.Free; // ELIMINA VAZAMENTO DE MEMÓRIA
      end;
    finally
      LLexer.Free;
    end;

    // 3. EXIBIÇÃO E FILTRO
    if ltvAutoComplete.Items.Count > 0 then
    begin
      ltvAutoComplete.AlphaSort;

      // SISTEMÁTICO: Sempre foca o primeiro
      ltvAutoComplete.ItemIndex := 0;
      ltvAutoComplete.ItemFocused := ltvAutoComplete.Items[0];
      ltvAutoComplete.Selected := ltvAutoComplete.Items[0];

      // Mostra o form apenas se já tiver o que mostrar
      if not Self.Visible then
      begin
        Self.ForceShow(False);
      end;

      // O SuperSelected deve ser chamado para garantir o scroll visual da VCL
      ltvAutoComplete.SuperSelected;
      UpdateAbout;
    end
    else
      Self.Close;

  finally
    ltvAutoComplete.Items.EndUpdate;
  end;
end;

procedure TFrmAutoComplete.ProcurarComandos(const ACommand: string);
var
  LItem, LItemAux: TPGItem;
  LKeyword: string;
begin
  // Adiciona Palavras Reservadas da Linguagem
  for LKeyword in TPGLexicalRegistry.Keywords.Keys do
    if LKeyword.StartsWith(ACommand, True) then
      ListViewAdd(LKeyword, 'Keyword');

  // Adiciona Identificadores Globais
  for LItem in GlobalCollection do
    for LItemAux in LItem.FindNameList(ACommand, True) do
      ListViewAdd(LItemAux);
end;

procedure TFrmAutoComplete.SelectCMD(ASelected: TSelectCMD);
var
  LText: string;
  LCaretX, LWordStart, LAux: Integer;
LIndex: Integer;
begin
  if (not Self.Visible) or (ltvAutoComplete.Items.Count = 0) then
  begin
    Self.Close;
    Exit;
  end;

  case ASelected of
    selUp:
    begin
      LIndex := ltvAutoComplete.ItemIndex;
      if LIndex > 0 then Dec(LIndex) else LIndex := ltvAutoComplete.Items.Count - 1;
      ltvAutoComplete.ItemIndex := LIndex;
      ltvAutoComplete.SuperSelected; // Usa seu helper do componente
    end;

    selDown:
    begin
      LIndex := ltvAutoComplete.ItemIndex;
      if LIndex < ltvAutoComplete.Items.Count - 1 then Inc(LIndex) else LIndex := 0;
      ltvAutoComplete.ItemIndex := LIndex;
      ltvAutoComplete.SuperSelected; // Usa seu helper do componente
    end;

    selEnter:
    begin
      LText := FEditCtrl.Lines[FEditCtrl.CaretY - 1];
      LCaretX := FEditCtrl.CaretX;
      // Localiza o início da palavra atual para substituição
      LWordStart := LCaretX - 1;
      while (LWordStart > 0) and (not CharInSet(LText[LWordStart], Delimitadores)) do Dec(LWordStart);
      Inc(LWordStart);

      LAux := (LCaretX - LWordStart);
      if LAux <= FEditCtrl.SelStart then
        FEditCtrl.SelStart := FEditCtrl.SelStart - LAux;

      FEditCtrl.SelLength := LAux;
      FEditCtrl.SelText := ltvAutoComplete.ItemFocused.Caption;

      PriorityStep;
      Self.Close;

      if (ASelected = selEnter) and (FEditCtrl.Owner.Name = 'FrmPGofer') then
      begin
        ScriptExec('MainPromp',FEditCtrl.Text, nil, false );
        FEditCtrl.Clear;
      end;
    end;
  end;

  if ASelected <> selClick then ltvAutoComplete.SuperSelected;
  UpdateAbout;
end;

procedure TFrmAutoComplete.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LOriginalEvents: TEditOnCtrl;
begin
  if (Sender is TRichEditEx) then
    FEditCtrl := TRichEditEx(Sender)
  else
    Exit;

  if (Shift = []) then
  begin
    case Key of
      VK_F9:
      begin
        if FEditCtrl.Text <> '' then
           ScriptExec('F9_Execute', FEditCtrl.Text, nil, False);
        Key := 0;
        Exit;
      end;

      // Teclas que disparam ou atualizam o filtro
      VK_BACK, $30..$39, $41..$5A, VK_NUMPAD0..VK_NUMPAD9,
      189, 190, 191, 106, 107, 109, 110, 111:
      begin
        FEditCtrl := TRichEditEx(Sender);
        FindCMD;
      end;
      VK_ESCAPE: Self.Close;
    end;
  end;

  // 3. REPASSE PARA O EVENTO ORIGINAL (Essencial para atualizar Item.Script nos Frames)
  // Isso resolve o problema do frame da função não "saber" que o texto mudou.
  if FEditList.TryGetValue(FEditCtrl, LOriginalEvents) then
  begin
    if Assigned(LOriginalEvents.OnKeyUp) then
      LOriginalEvents.OnKeyUp(Sender, Key, Shift);
  end;
end;

procedure TFrmAutoComplete.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LCount: Integer;
begin
  if (Sender is TRichEditEx) then
    FEditCtrl := TRichEditEx(Sender);
  if FEditCtrl = nil then
    Exit;

  // --- 1. LÓGICA DE HISTÓRICO (CTRL + PGUP / PGDN) - PRIORIDADE ---
  if (Shift = [ssCtrl]) and (Key in [VK_PRIOR, VK_NEXT]) then
  begin
    LCount := FMemoryList.Count;
    if LCount > 0 then
    begin
      if Key = VK_PRIOR then // Para trás no tempo
      begin
        Dec(FMemoryPosition);
        if FMemoryPosition < 0 then FMemoryPosition := LCount - 1;
      end else begin
        Inc(FMemoryPosition);
        if FMemoryPosition >= LCount then FMemoryPosition := 0;
      end;

      // Injeta o comando na linha atual
      FEditCtrl.Lines[FEditCtrl.CaretY - 1] := FMemoryList[FMemoryPosition];

      // Move o cursor para o final da linha injetada
      FEditCtrl.SelStart := FEditCtrl.Perform(EM_LINEINDEX, FEditCtrl.CaretY - 1, 0) +
                            Length(FMemoryList[FMemoryPosition]);

      if Self.Visible then Self.Close; // Fecha o autocomplete ao navegar no histórico
      Key := 0;
      Exit;
    end;
  end;

  // --- 2. SE O AUTOCOMPLETE ESTIVER VISÍVEL (NAVEGAÇÃO NA LISTA) ---
  if Self.Visible then
  begin
    case Key of
      VK_RETURN: begin SelectCMD(selEnter); Key := 0; Exit; end;
      VK_ESCAPE: begin Self.Close; Key := 0; Exit; end;
      VK_UP:     begin SelectCMD(selUp);    Key := 0; Exit; end;
      VK_DOWN:   begin SelectCMD(selDown);  Key := 0; Exit; end;
    end;
  end;

  // --- 3. ENTER NO PROMPT (FrmPGofer) ---
  if (Key = VK_RETURN) and (Shift = []) and SameText(FEditCtrl.Owner.Name, 'FrmPGofer') then
  begin
    if FEditCtrl.Text <> '' then
    begin
      // Adiciona ao histórico (Sistemático: apenas se for diferente do último)
      if (FMemoryList.Count = 0) or (FMemoryList[FMemoryList.Count-1] <> FEditCtrl.Text) then
        FMemoryList.Add(FEditCtrl.Text);

      FMemoryPosition := FMemoryList.Count; // Reset da posição do histórico

      ScriptExec('Prompt', FEditCtrl.Text, nil, False);
      FEditCtrl.Clear;
    end;
    Key := 0;
    Exit;
  end;
end;

{ --- Métodos Auxiliares --- }

procedure TFrmAutoComplete.ListViewAdd(const ACaption, AOrigin: string; AData: Pointer);
var
  I: Integer;
begin
  if ACaption = '' then Exit;
  // VERIFICAÇÃO DE DUPLICIDADE
  for I := 0 to ltvAutoComplete.Items.Count - 1 do
    if SameText(ltvAutoComplete.Items[I].Caption, ACaption) then Exit;

  with ltvAutoComplete.Items.Add do
  begin
    Caption := ACaption;
    SubItems.Add(AOrigin);
    SubItems.Add(FMemoryIniFile.ReadString('AutoComplete', AOrigin + '.' + ACaption, '0'));
    Data := AData;
  end;
end;

procedure TFrmAutoComplete.ListViewAdd(AItem: TPGItem);
begin
  ListViewAdd(AItem.Name, TPGKernel.IfThen<string>(AItem.Parent <> nil, AItem.Parent.Name, 'Global'), AItem);
end;

procedure TFrmAutoComplete.ltvAutoCompleteCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
var P1, P2: Integer; B1, B2: Boolean;
begin
  B1 := SameText(Copy(Item1.Caption, 1, Length(FPartialWord)), FPartialWord);
  B2 := SameText(Copy(Item2.Caption, 1, Length(FPartialWord)), FPartialWord);
  if B1 <> B2 then begin
    if B1 then Compare := -1 else Compare := 1;
    Exit;
  end;
  P1 := StrToIntDef(Item1.SubItems[1], 0);
  P2 := StrToIntDef(Item2.SubItems[1], 0);
  Compare := P2 - P1;
  if Compare = 0 then Compare := CompareText(Item1.Caption, Item2.Caption);
end;

procedure TFrmAutoComplete.FileNameList(const AFileName: string);
var
  LSearchRec: TSearchRec;
  LCount: Cardinal;
begin
  LCount := 0;
  if FindFirst(AFileName + '*', faAnyFile, LSearchRec) = 0 then
  begin
    repeat
      if (LSearchRec.Attr and faDirectory) = faDirectory then
        ListViewAdd(LSearchRec.Name + '\', 'Directory')
      else
        ListViewAdd(LSearchRec.Name, 'File');
      Inc(LCount);
    until (FindNext(LSearchRec) <> 0) or (LCount >= FItem.FileListMax);
    FindClose(LSearchRec);
  end;
end;

procedure TFrmAutoComplete.EditCtrlAdd(AValue: TRichEditEx);
var
  LEvents: TEditOnCtrl;
begin
  if not FEditList.ContainsKey(AValue) then
  begin
    LEvents.OnKeyDown := AValue.OnKeyDown;
    LEvents.OnKeyUp := AValue.OnKeyUp;
    LEvents.OnKeyPress := AValue.OnKeyPress;
    LEvents.OnDropFile := AValue.OnDropFiles;
    AValue.OnKeyDown := Self.FormKeyDown;
    AValue.OnKeyUp := Self.FormKeyUp;
    AValue.OnKeyPress := Self.FormKeyPress;
    AValue.OnDropFiles := Self.FormDropFile;
    FEditList.Add(AValue, LEvents);
  end;
end;

procedure TFrmAutoComplete.EditCtrlRemove(AValue: TRichEditEx);
var LEvents: TEditOnCtrl;
begin
  if FEditList.TryGetValue(AValue, LEvents) then
  begin
    AValue.OnKeyDown := LEvents.OnKeyDown;
    AValue.OnKeyUp := LEvents.OnKeyUp;
    AValue.OnKeyPress := LEvents.OnKeyPress;
    AValue.OnDropFiles := LEvents.OnDropFile;
    FEditList.Remove(AValue);
  end;
end;

procedure TFrmAutoComplete.PriorityStep;
var LVal: Integer;
begin
  if ltvAutoComplete.ItemFocused <> nil then
  begin
    LVal := StrToIntDef(ltvAutoComplete.ItemFocused.SubItems[1], 0);
    SetPriority(LVal + 1);
  end;
end;

procedure TFrmAutoComplete.SetPriority(AValue: Integer);
var LKey: string;
begin
  ltvAutoComplete.ItemFocused.SubItems[1] := AValue.ToString;
  LKey := ltvAutoComplete.ItemFocused.SubItems[0] + '.' + ltvAutoComplete.ItemFocused.Caption;
  FMemoryIniFile.WriteInteger('AutoComplete', LKey, AValue);
  FMemoryIniFile.UpdateFile;
end;

procedure TFrmAutoComplete.FormShow(Sender: TObject);
begin
  inherited;
  trmAutoComplete.Enabled := True;
end;

procedure TFrmAutoComplete.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  trmAutoComplete.Enabled := False;
end;

procedure TFrmAutoComplete.IniConfigLoad;
begin
  inherited;
  ltvAutoComplete.IniConfigLoad(IniFile, Name, 'List');
end;

procedure TFrmAutoComplete.IniConfigSave;
begin
  ltvAutoComplete.IniConfigSave(IniFile, Name, 'List');
  inherited;
end;

procedure TFrmAutoComplete.ltvAutoCompleteMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SelectCMD(selClick);
end;

procedure TFrmAutoComplete.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = ' ') and (GetKeyState(VK_CONTROL) < 0) then Key := #0;
end;

procedure TFrmAutoComplete.trmAutoCompleteTimer(Sender: TObject);
begin
  if (FEditCtrl <> nil) and (not FEditCtrl.Focused) and (not ltvAutoComplete.Focused) then Close;
end;

procedure TFrmAutoComplete.ltvAutoCompleteDblClick(Sender: TObject);
begin
  SelectCMD(selEnter);
end;

procedure TFrmAutoComplete.mniPriorityClick(Sender: TObject);
var N: Integer;
begin
  if (ltvAutoComplete.ItemFocused <> nil)
  and TryStrToInt(InputBox('Priority', 'Valor', ltvAutoComplete.ItemFocused.SubItems[1]), N) then
    SetPriority(N);
end;

{ TPGFrmAutoComplete }
constructor TPGFrmAutoComplete.Create(AForm: TForm);
begin
  inherited Create(AForm);
  FFileListMax := 100;
end;

destructor TPGFrmAutoComplete.Destroy;
begin
  inherited;
end;

end.
