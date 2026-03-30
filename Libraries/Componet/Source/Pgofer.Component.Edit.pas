unit PGofer.Component.Edit;

interface

uses
  System.RegularExpressions, System.Classes, System.SysUtils,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls;

type
  { Evento }
  TValidateCustomEvent = procedure(ASender: TObject; var AIsValid: Boolean) of object;

  { Modos de Valida��o de infraestrutura }
  TValidationMode = (vmNone, vmPassword, vmOpenFile, vmSaveFile, vmPathExists);

  { Exemplos de Express�es Regulares, agora incluindo File e Path }
  TRegExample = (reNone, reAll, reWord, reUnsignedInt, reSignedInt, reUnsignedFloat,
                 reSignedFloat, reLetter, reID, rePassword, reEmail, reURL, reFileName, rePathName);

  TEditEx = class(TEdit)
  private
    { Validation / Appearance }
    FValidationMode: TValidationMode;
    FValidationColorError: TColor;
    FValidationColorNormal: TColor;
    FValidationIsValid: Boolean;
    FSelectAllOnFocus: Boolean;

    { Path / Dialog }
    FPathAutoUnExpand: Boolean;
    FPathDialogFilter: string;
    FPathDialogTitle: string;
    FPathDefaultExt: string;

    { RegEx }
    FRegEx: TRegEx;
    FRegExBlockInvalidKeys: Boolean;
    FRegExCompiled: Boolean;
    FRegExExamples: TRegExample;
    FRegExExpression: string;

    { Action Button}
    FActionButtonShow: Boolean;
    FActionButton: TButton;

    { Events }
    FOnActionButtonClick : TNotifyEvent;
    FOnBeforeValidate: TValidateCustomEvent;
    FOnAfterValidate: TNotifyEvent;

    { Setters }
    procedure SetValidationMode(AValue: TValidationMode);
    procedure SetValidationColorError(AValue: TColor);
    procedure SetValidationColorNormal(AValue: TColor);
    procedure SetValidationIsValid(AValue: Boolean);
    procedure SetActionButtonShow(AValue: Boolean);
    procedure SetRegExExpression(AValue: string);
    procedure SetRegExExamples(AValue: TRegExample);

    { M�todos de Apoio Interno }
    procedure UpdateActionButton;
    procedure UpdateRegExEngine;
    procedure ActionButtonClick(ASender: TObject);
  protected
    { Overrides da VCL }
    procedure Loaded; override;

   { L�gica de Valida��o }
    procedure Validate;

    procedure KeyPress(var AKey: Char); override;
    procedure Change(); override;
    procedure DoEnter();  override;

  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    { Propriedade p�blica para consulta via c�digo }
    property IsValid: Boolean read FValidationIsValid write SetValidationIsValid;
    procedure SetTextSilent(const AValue: String);
  published
    { Ordem de persist�ncia RTTI: ValidationMode � o c�rebro }
    property ValidationMode: TValidationMode read FValidationMode write SetValidationMode default vmNone;
    property ActionButtonShow: Boolean read FActionButtonShow write SetActionButtonShow default False;

    { Grupo: Path }
    property PathAutoUnExpand: Boolean read FPathAutoUnExpand write FPathAutoUnExpand default False;
    property PathDialogFilter: string read FPathDialogFilter write FPathDialogFilter;
    property PathDialogTitle: string read FPathDialogTitle write FPathDialogTitle;
    property PathDefaultExt: string read FPathDefaultExt write FPathDefaultExt;

    { Grupo: RegEx - Agora funciona em conjunto com qualquer ValidationMode }
    property RegExBlockInvalidKeys: Boolean read FRegExBlockInvalidKeys write FRegExBlockInvalidKeys default False;
    property RegExExpression: string read FRegExExpression write SetRegExExpression;
    property RegExExamples: TRegExample read FRegExExamples write SetRegExExamples default reNone;

    { Grupo: Validation / Appearance }
    property ValidationColorError: TColor read FValidationColorError write SetValidationColorError default clRed;
    property ValidationColorNormal: TColor read FValidationColorNormal write SetValidationColorNormal default clSilver;
    property SelectAllOnFocus: Boolean read FSelectAllOnFocus write FSelectAllOnFocus default False;

    { Evento Customizado no Object Inspector }
    property OnActionButtonClick: TNotifyEvent read FOnActionButtonClick write FOnActionButtonClick;
    property OnAfterValidate: TNotifyEvent read FOnAfterValidate write FOnAfterValidate;
    property OnBeforeValidate: TValidateCustomEvent read FOnBeforeValidate write FOnBeforeValidate;

    { Property }
    property OnChange;
    property OnEnter;
    property OnExit;
    property Text;

  end;

procedure Register;

implementation

uses
  PGofer.Files.Controls;

procedure Register;
begin
  RegisterComponents('PGofer', [TEditEx]);
end;

{ TEditEx }

constructor TEditEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FValidationMode := vmNone;
  FValidationColorError := clRed;
  FValidationColorNormal := clSilver;
  FValidationIsValid := False;
  FSelectAllOnFocus := False;

  FPathAutoUnExpand := False;
  FPathDialogFilter := '';
  FPathDialogTitle := '';
  FActionButtonShow := False;

  FRegExBlockInvalidKeys := False;
  FRegExCompiled := False;
  FRegExExamples := reNone;
  FRegExExpression := '';

  { Configura��o de Estilo Visual }
  Self.StyleElements := [seFont, seClient, seBorder];
  Self.Color := FValidationColorNormal;
end;

procedure TEditEx.Loaded( );
begin
  inherited Loaded;
  if Assigned(FActionButton) then
    FActionButton.TabOrder := Self.TabOrder + 1;
end;

procedure TEditEx.Change( );
begin
  Self.Validate( );
  inherited Change;
end;

procedure TEditEx.DoEnter;
begin
  inherited DoEnter;
  if FSelectAllOnFocus then
    Self.SelectAll;
end;

procedure TEditEx.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  Self.UpdateActionButton;
end;

procedure TEditEx.SetValidationMode(AValue: TValidationMode);
begin
  FValidationMode := AValue;
end;

procedure TEditEx.SetValidationColorError(AValue: TColor);
begin
  FValidationColorError := AValue;
end;

procedure TEditEx.SetValidationColorNormal(AValue: TColor);
begin
  FValidationColorNormal := AValue;
end;

procedure TEditEx.SetActionButtonShow(AValue: Boolean);
begin
  if FActionButtonShow <> AValue then
  begin
    if AValue and (FValidationMode > vmNone) then
    begin
      if not Assigned(FActionButton) then
      begin
        FActionButton := TButton.Create(Self);
        FActionButton.Name := Self.Name + '_BtnAction';
        FActionButton.Parent := Self.Parent;
        FActionButton.Height := Self.Height;
        FActionButton.Width := 30;
        FActionButton.TabOrder := Self.TabOrder+1;
        FActionButton.OnClick := Self.ActionButtonClick;
      end;

      case FValidationMode of
        vmPassword:
        begin
          if Self.PasswordChar = '*' then
            FActionButton.Caption := 'abc'
          else
            FActionButton.Caption := '***';
        end;
        vmOpenFile,
        vmSaveFile,
        vmPathExists:
        begin
          FActionButton.Caption := '...';
        end;
      end;

      FActionButton.Visible := True;
      FActionButtonShow := True;
      Self.UpdateActionButton( );
    end else begin
      FreeAndNil(FActionButton);
      FActionButtonShow := False;
    end;
  end;
end;

procedure TEditEx.SetRegExExpression(AValue: string);
begin
  FRegExExpression := AValue;
  Self.UpdateRegExEngine( );
end;

procedure TEditEx.SetRegExExamples(AValue: TRegExample);
begin
  case AValue of
    reAll:           FRegExExpression := '.*';
    reWord:          FRegExExpression := '^\w*$';
    reUnsignedInt:   FRegExExpression := '^\d*$';
    reSignedInt:     FRegExExpression := '^-?\d*$';
    reUnsignedFloat: FRegExExpression := '^\d*[\,\.]?\d*$';
    reSignedFloat:   FRegExExpression := '^-?\d*[\,\.]?\d*$';
    reLetter:        FRegExExpression := '^[A-Za-z]*$';
    reID:            FRegExExpression := '^[A-Za-z_][A-Za-z0-9_]*$';
    rePassword:      FRegExExpression := '^.{6,}$';
    reEmail:         FRegExExpression := '^[\w\.\-]+@[\w\.\-]+\.[a-zA-Z]{2,7}$';
    reURL:           FRegExExpression := '^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';
    reFileName:      FRegExExpression := '^[^\\\/\:\*\?\"\<\>\|]+$';
    rePathName:      FRegExExpression := '^([a-zA-Z]\:)?(\\[^\\\/\:\*\?\"\<\>\|]+)*\\?$';
    reNone:          ;
  end;
  Self.UpdateRegExEngine( );
end;

procedure TEditEx.UpdateActionButton;
begin
  if Assigned(FActionButton) and Assigned(FActionButton.Parent) then
    FActionButton.SetBounds(Self.Left + Self.Width + 5, Self.Top, 30, Self.Height);
end;

procedure TEditEx.UpdateRegExEngine;
begin
  FRegExCompiled := False;
  if (FRegExExpression <> '') then
  begin
    try
      FRegEx := TRegEx.Create(FRegExExpression);
      FRegExCompiled := True;
    except
      FRegExCompiled := False;
    end;
  end;
end;

procedure TEditEx.ActionButtonClick(ASender: TObject);
var
  LNewPath: string;
begin
  case FValidationMode of
    vmPassword:
      begin
        if Self.PasswordChar = #0 then
        begin
          Self.PasswordChar := '*';
          FActionButton.Caption := 'abc';
        end else begin
          Self.PasswordChar := #0;
          FActionButton.Caption := '***';
        end;
      end;
    vmOpenFile:
      LNewPath := FileOpenSaveDialog(FPathDialogTitle, FPathDialogFilter, Self.Text, False);
    vmSaveFile:
      begin
        LNewPath := FileOpenSaveDialog(FPathDialogTitle, FPathDialogFilter, Self.Text, True);
        if (LNewPath <> '') and (FPathDefaultExt <> '') and (ExtractFileExt(LNewPath) = '') then
          LNewPath := LNewPath + '.' + FPathDefaultExt;
      end;
    vmPathExists:
      LNewPath := FileDirDialog(Self.Text);
  else
    Exit;
  end;

  if LNewPath <> '' then
  begin
    if FPathAutoUnExpand then
      Self.Text := FileUnExpandPath( LNewPath )
    else
      Self.Text := LNewPath;
    if Assigned(Self.OnChange) then Self.OnChange(Self);
  end;

  { Custom Event }
  if Assigned(Self.FOnActionButtonClick) then
    Self.FOnActionButtonClick(Self);

  Self.Validate( );
end;

procedure TEditEx.KeyPress(var AKey: Char);
var
  LNewText: string;
begin
  { O RegEx agora bloqueia teclas em qualquer modo, desde que a express�o exista }
  if (AKey >= #32) and FRegExBlockInvalidKeys and FRegExCompiled then
  begin
    LNewText := Self.Text;
    Delete(LNewText, Self.SelStart + 1, Self.SelLength);
    Insert(AKey, LNewText, Self.SelStart + 1);
    if not FRegEx.IsMatch(LNewText) then
    begin
      AKey := #0;
      Exit;
    end;
  end;

  if AKey = #13 then
  begin
    if Assigned(Self.OnExit) then Self.OnExit(Self);
    AKey := #0;
  end;

  inherited KeyPress(AKey);
end;

procedure TEditEx.Validate();
var
  LValid: Boolean;
begin
  LValid := True;

  { Regex }
  if FRegExCompiled then
    LValid := FRegEx.IsMatch(Self.Text);

  { FileExists }
  if LValid then
  begin
    case FValidationMode of
      vmOpenFile:
        LValid := FileExistsEx(Self.Text);
      vmSaveFile,
      vmPathExists:
        LValid := DirectoryExistsFileEx(Self.Text);
    end;
  end;

  { Custom Event Before }
  if Assigned(FOnBeforeValidate) then
    FOnBeforeValidate(Self, LValid);

  Self.SetValidationIsValid(LValid);

  { Custom Event After }
  if Self.FValidationIsValid and Assigned(Self.FOnAfterValidate) then
    Self.FOnAfterValidate(Self);
end;

procedure TEditEx.SetValidationIsValid(AValue: Boolean);
begin
  if FValidationIsValid <> AValue then
  begin
    FValidationIsValid := AValue;
    if FValidationIsValid then
      Self.Color := FValidationColorNormal
    else
      Self.Color := FValidationColorError;
  end;
end;

procedure TEditEx.SetTextSilent(const AValue: String);
var
  OldEvent: TNotifyEvent;
begin
  if Self.Text = AValue then Exit;

  OldEvent := Self.OnChange;
  Self.OnChange := nil;
  Self.Text := AValue;
  Self.OnChange := OldEvent;
end;


end.
