unit PGofer.Form.AutoComplete;

interface

uses
    Winapi.Windows,
    System.Classes, System.SysUtils, System.IniFiles,
    Vcl.Controls, Vcl.ComCtrls, Vcl.Forms, Vcl.Menus, Vcl.ExtCtrls,
    SynEdit,
    PGofer.Classes, PGofer.Forms, PGofer.Component.ListView;

type
    TOnKeyDownUP = procedure(Sender: TObject; var Key: Word; Shift: TShiftState)
      of object;
    TOnKeyPress = procedure(Sender: TObject; var Key: Char) of object;
    TOnExit = procedure(Sender: TObject) of object;
    TSelectCMD = (selUp, selDown, selEnter);

    TFrmAutoComplete = class(TFormEx)
        ltvAutoComplete: TListViewEx;
        ppmAutoComplete: TPopupMenu;
        mniPriority: TMenuItem;
        trmAutoComplete: TTimer;
        constructor Create(EditCtrl: TSynEdit); reintroduce;
        destructor Destroy(); override;
        procedure FormActivate(Sender: TObject);
        procedure FormKeyDown(Sender: TObject; var Key: Word;
          Shift: TShiftState);
        procedure FormKeyPress(Sender: TObject; var Key: Char);
        procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure ltvAutoCompleteDblClick(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure mniPriorityClick(Sender: TObject);
        procedure trmAutoCompleteTimer(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure ltvAutoCompleteCompare(Sender: TObject;
          Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
    private
        FEditCtrl: TSynEdit;
        FEditKeyDown: TOnKeyDownUP;
        FEditKeyPress: TOnKeyPress;
        FEditKeyUp: TOnKeyDownUP;
        FShift: TShiftState;
        FMemoryIniFile: TIniFile;
        FMemoryNoCtrl: Boolean;
        FMemoryList: TStringList;
        FMemoryPosition: Integer;
        FMemoryFile: String;
        procedure ListViewAdd(Caption, Origin: String); overload;
        procedure ListViewAdd(Item: TPGItem); overload;
        procedure PriorityStep();
        procedure SetPriority(Value: FixedInt);
        procedure ProcurarComandos(Comando: String); overload;
        procedure FilePathList(FileName: String);
        procedure FindCMD();
        procedure SelectCMD(Selected: TSelectCMD);
    protected
        procedure CreateWindowHandle(const Params: TCreateParams); override;
        procedure IniConfigSave(); reintroduce;
        procedure IniConfigLoad(); reintroduce;
    public
        property MemoryNoCtrl: Boolean read FMemoryNoCtrl write FMemoryNoCtrl;
    end;

implementation

uses
    Vcl.Dialogs,
    PGofer.Lexico, PGofer.Sintatico, PGofer.Sintatico.Controls,
    PGofer.Files.Controls, PGofer.Forms.Controls, PGofer.Utils;

{$R *.dfm}

const
    Caracteres: TSysCharSet = [' ', ',', ';', ':', '=', '+', '-', '*', '\', '/',
      '<', '>', '(', ')', '[', ']', '!', '@', '#', '%', '^', '$', '&', '?', '|',
      '''', '"', '.'];

constructor TFrmAutoComplete.Create(EditCtrl: TSynEdit);
begin
    inherited Create(nil);
    // guarda os eventos do edit
    FEditCtrl := EditCtrl;
    FEditKeyDown := FEditCtrl.OnKeyDown;
    FEditKeyPress := FEditCtrl.OnKeyPress;
    FEditKeyUp := FEditCtrl.OnKeyUp;
    // Sobescreve os eventos do edid
    FEditCtrl.OnKeyDown := Self.FormKeyDown;
    FEditCtrl.OnKeyPress := Self.FormKeyPress;
    FEditCtrl.OnKeyUp := Self.FormKeyUp;

    // carrega arquivos ini
    FMemoryIniFile := TIniFile.Create(PGofer.Sintatico.DirCurrent
                                      +'AutoComplete.ini');
    //?????????
    FShift := [];

    //controle de memorização de comandos
    FMemoryNoCtrl := False;
    FMemoryPosition := 0;
    FMemoryList := TStringList.Create();
    FMemoryFile := PGofer.Sintatico.DirCurrent+'AutoCompleteMen.txt';
    if FileExists(FMemoryFile) then
       FMemoryList.LoadFromFile(FMemoryFile);
end;

procedure TFrmAutoComplete.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited CreateWindowHandle(Params);
    SetWindowLong(Self.Handle, GWL_STYLE, WS_SIZEBOX);
    SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_NOACTIVATE or
                  WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
    Application.AddPopupForm(Self);
end;

destructor TFrmAutoComplete.Destroy();
begin
    // restaura eventos originais
    FEditCtrl.OnKeyDown := FEditKeyDown;
    FEditCtrl.OnKeyPress := FEditKeyPress;
    FEditCtrl.OnKeyUp := FEditKeyUp;

    FEditKeyDown := nil;
    FEditKeyPress := nil;
    FEditKeyUp := nil;
    FEditCtrl := nil;

    FMemoryIniFile.Free();
    FMemoryList.SaveToFile(FMemoryFile);
    FMemoryList.Free();
    FMemoryPosition := 0;
    FMemoryNoCtrl := False;

    FShift := [];
    inherited;
end;

procedure TFrmAutoComplete.FormActivate(Sender: TObject);
begin
    // arruma a bagaça para não dar um bug sinistro em algum lugar.
    // Width := Width - 1;
    // Update;
    // Width := Width + 1;
    trmAutoComplete.Enabled := True;
end;

procedure TFrmAutoComplete.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    inherited;
    trmAutoComplete.Enabled := False;
end;

procedure TFrmAutoComplete.FormCreate(Sender: TObject);
begin
    inherited;
    //
end;

procedure TFrmAutoComplete.FormDestroy(Sender: TObject);
begin
    inherited;
    //
end;

procedure TFrmAutoComplete.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
    c: Word;
    Edit: TSynEdit;
begin
    Edit := TSynEdit(Sender);

    if Self.Visible then
    begin
        // visible
        case Key of
            // ENTER
            VK_RETURN:
                begin
                    Self.SelectCMD(selEnter);
                    // seleciona |
                    c := Pos('|', Edit.Lines[Edit.CaretY - 1]);
                    if c > 0 then
                    begin
                        Edit.CaretX := c;
                        Edit.SelLength := 1;
                        Edit.SelText := '';
                        Self.FindCMD();
                    end; // if c > 0 then

                    Key := 0;
                end; // VK_RETURN

            // ESQ
            VK_ESCAPE:
                begin
                    Self.Close;
                    Key := 0;
                end; // VK_ESCAPE

            // ESPAÇO
            VK_SPACE:
                begin
                    if Shift = [ssCtrl] then
                    begin
                        Key := 0;
                    end;
                end; // VK_ESCAPE

            VK_UP:
                begin
                    Self.SelectCMD(selUp);
                end;
            VK_DOWN:
                begin
                    Self.SelectCMD(selDown);
                    Key := 0;
                end;

            VK_LEFT, VK_RIGHT:
                begin
                    Self.FindCMD();
                end;
        end; // case
    end
    else
    begin
        // not visible
        case Key of
            // enter
            VK_RETURN:
                begin
                    FMemoryPosition := FMemoryList.Count;
                    FMemoryList.Add(Edit.Lines[Edit.CaretY - 1]);
                    if FMemoryPosition > 100 then
                        FMemoryList.Delete(0);
                end;

            // PGup PGDown
            VK_PRIOR, VK_NEXT:
                begin
                    if (Shift = [ssCtrl]) or (FMemoryNoCtrl) then
                    begin
                        c := FMemoryList.Count;
                        if c > 0 then
                        begin
                            // anteriores
                            if (Key in [VK_PRIOR, VK_UP]) then
                            begin
                                if FMemoryPosition > 0 then
                                    Dec(FMemoryPosition)
                                else
                                    FMemoryPosition := c - 1;
                            end;
                            // posteriores
                            if (Key = VK_NEXT) then
                            begin
                                if FMemoryPosition < c - 1 then
                                    Inc(FMemoryPosition)
                                else
                                    FMemoryPosition := 0;
                            end;
                            // escreve no edit
                            Edit.Lines[Edit.CaretY - 1] :=
                              FMemoryList[FMemoryPosition];
                            Key := 0;
                        end;
                    end;
                end;
        end;
    end;

    if Assigned(FEditKeyDown) then
        FEditKeyDown(Sender, Key, Shift);
end;

procedure TFrmAutoComplete.FormKeyPress(Sender: TObject; var Key: Char);
begin
    // seleciona ou sai
    case Key of
        #13:
            SelectCMD(selEnter);
        #27:
            Close;
    end;

    if Assigned(FEditKeyPress) then
        FEditKeyPress(Sender, Key);
end;

procedure TFrmAutoComplete.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
    Edit: TSynEdit;
begin
    Edit := TSynEdit(Sender);
    case Key of
        8 { bcks } , // backspace
        48 { 0 } .. 57 { 9 } , // numero
        65 { A } .. 92 { Z } , // letra
        96 { 0 } .. 105 { 9 } , // numpad
        106 { * } , 107 { + } , 109 { - } , 110 { . } , 111 { / } , 187 { = } ,
          186 { ; } , 188 { , } , 189 { - } , 190 { . } , 191 { / } ,
          219 { [ } , 220 { \ } , 221 { ] } , 222 { ' } , 226 { \ } :
            begin
                if Edit.LineText <> '' then
                    Self.FindCMD()
                else
                    Self.Close;
            end; // $30..$39,

        VK_LEFT, VK_RIGHT:
            begin
                if Copy(Edit.Lines[Edit.CaretY - 1], Edit.CaretX, 1) = '|' then
                begin
                    Edit.SelLength := 1;
                    Edit.SelText := '';
                    Self.FindCMD();
                end;
            end;

        // ESPAÇO
        VK_SPACE:
            begin
                if Shift = [ssCtrl] then
                begin
                    Self.FindCMD();
                    Key := 0;
                    Shift := [];
                end;
            end;

    end; // case

    if Assigned(FEditKeyUp) then
        FEditKeyUp(Sender, Key, Shift);
end;

procedure TFrmAutoComplete.FormShow(Sender: TObject);
var
    DisplayCoord: TDisplayCoord;
    Point: TPoint;
begin
    DisplayCoord := FEditCtrl.DisplayXY;
    Inc(DisplayCoord.Row);
    Point := FEditCtrl.RowColumnToPixels(DisplayCoord);
    Self.Top := FEditCtrl.ClientOrigin.Y + Point.Y + 2;
    Self.Left := FEditCtrl.ClientOrigin.X + Point.X + 2;
    FormForceShow(Self, False);
end;

procedure TFrmAutoComplete.IniConfigLoad;
var
    c: Integer;
begin
    inherited;
    for c := 0 to ltvAutoComplete.Columns.Count do
    begin
        ltvAutoComplete.Columns[c].Width := FIniFile.ReadInteger(Self.Name,
          'ColunWidth' + IntToStr(c), ltvAutoComplete.Columns[c].Width);
    end;
end;

procedure TFrmAutoComplete.IniConfigSave;
var
    c: Integer;
begin
    for c := 0 to ltvAutoComplete.Columns.Count do
    begin
        FIniFile.WriteInteger(Self.Name, 'ColunWidth' + IntToStr(c),
          ltvAutoComplete.Columns[c].Width);
    end;
    inherited;
end;

procedure TFrmAutoComplete.ltvAutoCompleteCompare(Sender: TObject;
  Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
var
    v1, v2: Integer;
begin
    if Assigned(Item1) and Assigned(Item2) and (Item1.SubItems.Count > 1) and
      (Item2.SubItems.Count > 1) then
    begin
        TryStrToInt(Item1.SubItems[1], v1);
        TryStrToInt(Item2.SubItems[1], v2);
        Compare := v2 - v1;
    end
    else
        Compare := 0;
end;

procedure TFrmAutoComplete.ltvAutoCompleteDblClick(Sender: TObject);
begin
    SelectCMD(selEnter);
end;

procedure TFrmAutoComplete.mniPriorityClick(Sender: TObject);
var
    N: Integer;
begin
    if TryStrToInt(InputBox('Prioridade', 'Valor',
      ltvAutoComplete.ItemFocused.SubItems[1]), N) then
        SetPriority(N);
end;

procedure TFrmAutoComplete.ListViewAdd(Caption, Origin: String);
var
    ListItem: TListItem;
begin
    if Caption <> '' then
    begin
        ListItem := ltvAutoComplete.Items.Add;
        ListItem.ImageIndex := -1;
        ListItem.Caption := Caption;
        ListItem.SubItems.Add(Origin);
        ListItem.SubItems.Add(FMemoryIniFile.ReadString('AutoComplete',
          Origin + '.' + Caption, '0'));
        ListItem.Data := nil;
    end;
end;

procedure TFrmAutoComplete.ListViewAdd(Item: TPGItem);
var
    ListItem: TListItem;
begin
    ListItem := ltvAutoComplete.Items.Add;
    ListItem.ImageIndex := -1;
    ListItem.Caption := Item.Name;
    if Assigned(Item.Parent) then
        ListItem.SubItems.Add(Item.Parent.Name)
    else
        ListItem.SubItems.Add('');
    ListItem.SubItems.Add(FMemoryIniFile.ReadString('AutoComplete',
      ListItem.SubItems[0] + '.' + ListItem.Caption, '0'));
    ListItem.Data := Item;
end;

procedure TFrmAutoComplete.PriorityStep();
var
    Value: FixedInt;
begin
    Value := ltvAutoComplete.ItemFocused.SubItems[1].ToInteger();
    Inc(Value);
    FMemoryIniFile.WriteInteger('AutoComplete', ltvAutoComplete.ItemFocused.SubItems
      [0] + '.' + ltvAutoComplete.ItemFocused.Caption, Value);
    ltvAutoComplete.ItemFocused.SubItems[1] := Value.ToString;
    ltvAutoComplete.Update();
    FMemoryIniFile.UpdateFile();
end;

procedure TFrmAutoComplete.SetPriority(Value: FixedInt);
begin
    ltvAutoComplete.ItemFocused.SubItems[1] := IntToStr(Value);
    FMemoryIniFile.WriteInteger('AutoComplete', ltvAutoComplete.ItemFocused.SubItems
      [0] + '.' + ltvAutoComplete.ItemFocused.Caption, Value);
    ltvAutoComplete.Update();
    FMemoryIniFile.UpdateFile();
end;

procedure TFrmAutoComplete.trmAutoCompleteTimer(Sender: TObject);
begin
    if (not FEditCtrl.Focused) and (not ltvAutoComplete.Focused) then
        Self.Close;
end;

procedure TFrmAutoComplete.ProcurarComandos(Comando: String);
var
    SubCMD: TArray<String>;
    Item: TPGItem;
    ItemAux: TPGItem;
    c, l: Integer;
begin
    SubCMD := SplitEx(Comando, '.');
    l := Length(SubCMD);
    if l = 1 then
    begin
        for Item in GlobalCollection do
        begin
            for ItemAux in Item.FindNameList(SubCMD[0], True) do
            begin
                ListViewAdd(ItemAux);
            end;
        end;
    end
    else
    begin
        Item := GlobalCollection;
        c := 0;
        repeat
            Item := FindID(Item, SubCMD[c]);
            Inc(c);
        until (c > l - 2) or (not Assigned(Item));

        for ItemAux in Item.FindNameList(SubCMD[c], True) do
        begin
            ListViewAdd(ItemAux);
        end;
    end;
end;

Procedure TFrmAutoComplete.FilePathList(FileName: String);
var
    SearchRec: TSearchRec;
    c, d: cardinal;
    // Icone : String;
begin
    ChDir(PGofer.Sintatico.DirCurrent);
    // localiza os aquivos e adiciona na lista
    c := FindFirst(FileName + '*', faAnyFile, SearchRec);
    d := 0;
    while (c = 0) and (d < PGofer.Sintatico.FileListMax) do
    begin
        {
          //ajusta o icone
          if (SearchRec.Attr and faDirectory) = faDirectory  then
          Icone := '%SystemRoot%\System32\shell32.dll,3'
          else
          Icone := ExtractFilePath(FileName)+SearchRec.Name;
        }
        if (SearchRec.Attr and faDirectory) = faDirectory then
            ListViewAdd(SearchRec.Name + '\', 'Directory')
        else
            ListViewAdd(SearchRec.Name, 'File');

        Inc(d);
        c := FindNext(SearchRec);
    end;

    FindClose(SearchRec);
    ChDir(PGofer.Sintatico.DirCurrent);
end;

procedure TFrmAutoComplete.FindCMD();
var
    Automato: TAutomato;
    TokenList: TTokenList;
    Classe: TLexicoClass;
    Diretorio, Comando: String;
    SelStart: Integer;
begin
    // limpa tudo
    ltvAutoComplete.Items.Clear();

    // pega a posição do cursor texto
    SelStart := FEditCtrl.RowColToCharIndex(FEditCtrl.CaretXY);

    // le o algoritimo
    Automato := TAutomato.Create();
    TokenList := Automato.TokenListCreate(Copy(FEditCtrl.Text, 1, SelStart));
    Automato.Free;

    // procura o ultimo comando corrente
    TokenList.Position := 0;
    Classe := cmdUnDeclar;
    while TokenList.Token.Classe <> cmdEOF do
    begin
        if (TokenList.Token.Classe in [cmdDot]) or (Classe in [cmdDot]) then
            Comando := Comando + TokenList.Token.Lexema
        else
            Comando := TokenList.Token.Lexema;
        Classe := TokenList.Token.Classe;
        TokenList.GetNextToken;
    end;
    TokenList.Free;

    // verificar se é arquivo
    if (Classe = cmdString) and (Length(Comando) > 2) then
    begin
        Diretorio := ExtractFilePath(FileExpandPath(Comando));
        if DirectoryExists(Diretorio) then
            FilePathList(Comando);
    end
    else
    begin
        if (Comando <> '') and (not(Classe in [cmdUnDeclar .. cmdNumeric])) then
        begin
            ProcurarComandos(Comando);
        end;
    end;

    // se encotrou seleciona no auto complete
    if (ltvAutoComplete.Items.Count > 0) then
    begin
        Self.FormShow(nil);
        ltvAutoComplete.SuperSelected(ltvAutoComplete.Items[0]);
        FEditCtrl.SetFocus();
    end
    else
    begin
        // se nao encontrou fecha
        Self.Close();
    end;
end;

procedure TFrmAutoComplete.SelectCMD(Selected: TSelectCMD);
var
    SelInicio, SelFinal: Integer;
begin
    if (Self.Visible) and (ltvAutoComplete.Items.Count > 0) then
    begin
        // localiza o final
        SelFinal := FEditCtrl.CaretX;
        while (SelFinal < Length(FEditCtrl.LineText)) and
          (not CharInSet(FEditCtrl.LineText[SelFinal], Caracteres)) do
            Inc(SelFinal);

        // localiza o inicio
        SelInicio := FEditCtrl.CaretX - 1;
        while (SelInicio > 0) and (SelInicio <= Length(FEditCtrl.LineText)) and
          (not CharInSet(FEditCtrl.LineText[SelInicio], Caracteres)) do
            Dec(SelInicio);

        Inc(SelInicio);

        // move selecao
        case Selected of

            selUp:
                begin
                    if ltvAutoComplete.ItemIndex > 0 then
                        ltvAutoComplete.ItemIndex :=
                          ltvAutoComplete.ItemIndex - 1;
                end;

            selDown:
                begin
                    if ltvAutoComplete.ItemIndex < ltvAutoComplete.Items.Count - 1
                    then
                        ltvAutoComplete.ItemIndex :=
                          ltvAutoComplete.ItemIndex + 1;
                end;

            selEnter:
                begin
                    FEditCtrl.CaretX := SelInicio;
                    FEditCtrl.SelLength := SelFinal - SelInicio;
                    FEditCtrl.SelText := ltvAutoComplete.ItemFocused.Caption;
                    Self.PriorityStep();
                    Self.Close;
                end;

        end;

        ltvAutoComplete.SuperSelected();
    end; // if count > 0
end;

end.
