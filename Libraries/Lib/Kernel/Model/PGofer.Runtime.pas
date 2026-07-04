unit PGofer.Runtime;

interface

uses
  System.Generics.Collections, System.Rtti, System.SysUtils,

  PGofer.Core, PGofer.Classes, PGofer.Sintatico;

type
  TPGItemClassType = class of TPGItemClass;

  TPGItemExecute = class(TPGItem)
  public
    procedure Execute(const AGrammar: TPGGrammar); virtual; abstract;
    procedure BeforeAccess(); virtual;
  end;

  TPGItemClass = class(TPGItemExecute)
  private
    FDefaultAction: TRttiMethod;
    FRttiLoaded: Boolean;
  protected
    procedure RttiCreateChildren; virtual;
    procedure RttiCreateDefaultAction; virtual;
    procedure ExecuteMember(const AGrammar: TPGGrammar);
    procedure ExecuteDefault(const AGrammar: TPGGrammar); virtual;
    function GetAbout: string; override;
    class function GetClassArgsMap(const AClass: TClass): TArray<TRttiProperty>;
    class function ExecuteRttiMethod(const AGrammar: TPGGrammar; const AMethod: TRttiMethod; const ATarget: TValue): Boolean;
    class function GetMethodSignature(const AMethod: TRttiMethod; const ACustomName: string = ''): string;
  public
    class function GetDefaultRoot(): TPGItem; virtual;

    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
    procedure BeforeAccess; override;
  end;

  TPGItemMember = class(TPGItemExecute)
  protected
    FMember: TRttiMember;
    FTargetClass: TClass;
  public
    constructor Create(const AItemDad: TPGItem; const AMember: TRttiMember; const ATargetClass: TClass = nil); reintroduce; virtual;
  end;

  TPGItemProperty = class(TPGItemMember)
  protected
    function GetAbout: string; override;
  public
    constructor Create(const AItemDad: TPGItem; const AMember: TRttiMember; const ATargetClass: TClass = nil); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGItemMethod = class(TPGItemMember)
  protected
    function GetAbout: string; override;
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGItemDef = class(TPGItemClass)
  private
    FTargetClass: TPGItemClassType;
    FArgsMap: TArray<TRttiProperty>;
  protected
    procedure RttiCreateChildren; override;
    function GetAbout: string; override;
    function GetIconIndex: Integer; override;
  public
    constructor Create(const AItemDad: TPGItem; const AClass: TPGItemClassType; const AName: string = ''); reintroduce;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  { Pastas de Organização }
  {$M+}
  TPGFolder = class(TPGItemClass)
  private
  protected
    function GetMaxOverlayFlag(): TPGItemFlag; override;
  public
    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
    procedure ExecuteAction(const AExpanded: Boolean = True; const ALocked: Boolean = False);
  published
    property _Expanded: Boolean read GetExpanded write SetExpanded;
  end;
  {$TYPEINFO ON}

  procedure Initialize();
  procedure Finalize();
  procedure DiscoverAndRegisterClasses();

  { Funções Globais de Execução }
  procedure ScriptExec(const AName, AScript: string; const ANivel: TPGItem = nil; const AWaitFor: Boolean = False);
  function FileScriptExec(const AFileName: string; const AWait: Boolean): Boolean;

var
  GlobalCollection: TPGItemCollect;

implementation

uses
  System.Classes, System.TypInfo,
  PGofer.Lexico, PGofer.Sintatico.Controls;

procedure Initialize();
begin
  GlobalCollection := TPGItemCollect.Create(nil, 'Globals');
  DiscoverAndRegisterClasses();
end;

procedure Finalize();
begin
  GlobalCollection.Free;
  GlobalCollection := nil;
  {$IFDEF DEBUG}
  {$ENDIF}
end;

procedure DiscoverAndRegisterClasses();
var
  LType: TRttiType;
  LAttr: TCustomAttribute;
  LRegAttr: TPGClassRegAttribute;

  function GetOrCreateFolder(const APath: string): TPGItem;
  var
    LParts: TArray<string>;
    LPart: string;
    LCurrent, LNext: TPGItem;
  begin
    LCurrent := GlobalCollection; // Ponto de partida
    if APath = '' then Exit(LCurrent);

    // Divide o caminho por pontos (ex: 'Commands.Net.Socket')
    LParts := APath.Split(['.']);
    for LPart in LParts do
    begin
      // Procura a pasta no nível atual
      LNext := LCurrent.FindName(LPart);

      // Se não existe, cria agora!
      if LNext = nil then
      begin
        LNext := TPGFolder.Create(LCurrent, LPart);
        // Opcional: Configurar flags padrão para pastas criadas automaticamente
        LNext.Namespace := False;
      end;

      LCurrent := LNext;
    end;
    Result := LCurrent;
  end;

var
  LTargetFolder: TPGItem;
  LClassName: string;
  LClass: TClass;
begin
  for LType in TPGKernel.RttiContext.GetTypes do
  begin
    // Apenas herdeiros de TPGItemClass
    if not (LType.IsInstance and LType.AsInstance.MetaclassType.InheritsFrom(TPGItemClass)) then
       Continue;

    for LAttr in LType.GetAttributes do
    begin
      // Apenas TPGClassRegAttribute
      if not (LAttr is TPGClassRegAttribute) then
        Continue;

      LRegAttr := TPGClassRegAttribute(LAttr);

      // Obtem ou Cria a Pasta
      LTargetFolder := GetOrCreateFolder(LRegAttr.Path);

      // Obtem o nome
      LClassName := LRegAttr.Name;
      if LClassName = '' then
        LClassName := TPGItemClassType(LType.AsInstance.MetaclassType).ClassNameEx;

      // Cria o Objeto/Define
      LClass := LType.AsInstance.MetaclassType;
      if LRegAttr.Factory then
        TPGItemDef.Create(LTargetFolder, TPGItemClassType(LClass), LClassName)
      else
        TPGItemClassType(LClass).Create(LTargetFolder, LClassName);
    end;
  end;
end;

{ TPGItemExecute }

procedure TPGItemExecute.BeforeAccess();
begin
  if Self.Count = 0 then
     Self.HasChildren := False;
end;

{ TPGItemClass }

procedure TPGItemClass.BeforeAccess;
begin
  if FRttiLoaded then Exit;
  try
    FRttiLoaded := True;
    Self.RttiCreateChildren;
  except
    on E: Exception do
    begin
      FRttiLoaded := False;
      TPGKernel.Console('Error_RTTI_Load: ' + Self.ClassName + ' - ' + E.Message, True);
    end;
  end;
  inherited BeforeAccess;
end;

constructor TPGItemClass.Create(const AItemDad: TPGItem; const AName: string);
begin
  inherited Create(AItemDad, AName);
  Self.Namespace := True;
  Self.HasChildren := True;
end;

procedure TPGItemClass.RttiCreateChildren();
var
  LType: TRttiType;
  LProp: TRttiProperty;
  LMethod: TRttiMethod;
begin
  LType := TPGKernel.RttiContext.GetType(Self.ClassType);

  for LProp in LType.GetProperties do
  begin
    if (LProp.Visibility = mvPublished)
    and (not Assigned(Self.FindName(LProp.Name))) then
    begin
      if (LProp.PropertyType.IsInstance)
      and(LProp.PropertyType.AsInstance.MetaclassType.InheritsFrom(TPGItemClass)) then
        TPGItemClassType(LProp.PropertyType.AsInstance.MetaclassType).Create(Self, LProp.Name)
      else
        TPGItemProperty.Create(Self, LProp);
    end;
  end;

  for LMethod in LType.GetMethods do
  begin
    if (LMethod.Visibility = mvPublished)
    and (not LMethod.IsClassMethod)
    and (not Assigned(Self.FindName(LMethod.Name))) then
      TPGItemMethod.Create(Self, LMethod);
  end;

end;

procedure TPGItemClass.RttiCreateDefaultAction();
var
  LType: TRttiType;
begin
  if not Assigned(FDefaultAction) then
  begin
    LType := TPGKernel.RttiContext.GetType(Self.ClassType);
    FDefaultAction := LType.GetMethod('ExecuteAction');
  end;
end;

procedure TPGItemClass.Execute(const AGrammar: TPGGrammar);
begin
  AGrammar.TokenList.Next;

  case AGrammar.TokenList.Current.Kind of
    pgkDot:   ExecuteMember(AGrammar);
    pgkLPar:
    begin
      Self.RttiCreateDefaultAction();
      if Assigned(FDefaultAction) then
        ExecuteRttiMethod(AGrammar, FDefaultAction, Self)
      else
        AGrammar.Error('Error_Interpreter_NoArgsSupported', []);
    end;
    pgkSemiColon, pgkEOF, pgkEnd: ExecuteDefault(AGrammar);
  else
    AGrammar.Error('Error_Interpreter_Unrecog', []);
  end;
end;

procedure TPGItemClass.ExecuteMember(const AGrammar: TPGGrammar);
var
  LMemberName: String;
  LMember: TPGItem;
begin
  Self.BeforeAccess();
  AGrammar.TokenList.Next; // Pula o "."
  LMemberName := AGrammar.TokenList.Current.Value.ToString;
  LMember := Self.FindName(LMemberName);

  if Assigned(LMember) and (LMember is TPGItemExecute) then
  begin
    TPGItemExecute(LMember).BeforeAccess();
    TPGItemExecute(LMember).Execute(AGrammar);
  end else
    AGrammar.Error('Error_Interpreter_MemberNotFound', [Self.Name]);
end;

procedure TPGItemClass.ExecuteDefault(const AGrammar: TPGGrammar);
begin
  // Ação padrão quando apenas o nome do objeto é citado
end;

class function TPGItemClass.ExecuteRttiMethod(const AGrammar: TPGGrammar; const AMethod: TRttiMethod; const ATarget: TValue): Boolean;
var
  LParams: TArray<TRttiParameter>;
  LValues: array of TValue;
  LCount, I: Integer;
  LResult: TValue;
begin
  Result := False;
  if not Assigned(AMethod) then Exit;

  LParams := AMethod.GetParameters;
  SetLength(LValues, Length(LParams));
  LCount := ReadParameters(AGrammar, 0, Length(LParams));

  if not AGrammar.HasError then
  begin
    if ATarget.IsObject and (pgfDisabled in TPGItem(ATarget.AsObject).Flags) then
    begin
      for I := 0 to LCount - 1 do AGrammar.Stack.Pop;
      Exit(True);
    end;

    for I := LCount - 1 downto 0 do LValues[I] := AGrammar.Stack.Pop;

    for I := LCount to High(LParams) do
      LValues[I] := TValue.Empty;

    for I := 0 to High(LValues) do
      LValues[I] := ValueAlign(LValues[I], LParams[I].ParamType);

    try
      if Assigned(AMethod.ReturnType) then
      begin
        LResult := AMethod.Invoke(ATarget, LValues);
        if (LResult.Kind = tkRecord) and (LResult.TypeInfo = TypeInfo(TValue)) then
          LResult := LResult.AsType<TValue>;
        AGrammar.Stack.Push(LResult);
      end else
        AMethod.Invoke(ATarget, LValues);
      Result := True;
    except
      on E: Exception do AGrammar.Error('Error_Runtime', [E.Message]);
    end;
  end;
end;

class function TPGItemClass.GetClassArgsMap(const AClass: TClass): TArray<TRttiProperty>;
var
  LArgNames: TArray<string>;
  LType: TRttiType;
  LProp: TRttiProperty;
  I: Integer;
begin
  LType := TPGKernel.RttiContext.GetType(AClass);
  LArgNames := TPGArgsAttribute.GetFromClass(AClass);

  if Length(LArgNames) > 0 then
  begin
    SetLength(Result, Length(LArgNames));
    for I := 0 to High(LArgNames) do
      Result[I] := LType.GetProperty(LArgNames[I]);
  end else begin
    for LProp in LType.GetProperties do
      if (LProp.Visibility = mvPublished) and LProp.IsWritable then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := LProp;
      end;
  end;
end;

class function TPGItemClass.GetDefaultRoot(): TPGItem;
begin
  Result := GlobalCollection;
end;

class function TPGItemClass.GetMethodSignature(const AMethod: TRttiMethod; const ACustomName: string = ''): string;
var
  LParams: TArray<TRttiParameter>;
  LIndex: Integer;
  LPrefix, LAux: string;
begin
  if not Assigned(AMethod) then Exit('');

  if ACustomName <> '' then
    Result := ACustomName + '('
  else
    Result := 'Function ' + AMethod.Name + '(';

  LParams := AMethod.GetParameters;
  for LIndex := Low(LParams) to High(LParams) do
  begin
    LPrefix := '';
    if pfVar in LParams[LIndex].Flags then LPrefix := 'Var '
    else if pfOut in LParams[LIndex].Flags then LPrefix := 'Out '
    else if pfConst in LParams[LIndex].Flags then LPrefix := 'Const ';

    Result := Result + LPrefix + LParams[LIndex].Name;

    if Assigned(LParams[LIndex].ParamType) then
      Result := Result + ': ' + LParams[LIndex].ParamType.Name;

    LAux := TPGAboutAttribute.GetFromParameter(LParams[LIndex]);
    if LAux <> '' then
      Result := Result + ' [' + LAux + ']';

    if LIndex < High(LParams) then
      Result := Result + '; ';
  end;
  Result := Result + ')';

  if AMethod.ReturnType <> nil then
    Result := Result + ': ' + AMethod.ReturnType.Name;

  Result := Result + ';';
end;

function TPGItemClass.GetAbout: string;
var
  LClassAbout: TDictionary<string, string>;
  AttribText: String;
begin
  if not FAbout.TryGetValue(Self.ClassType, LClassAbout) then
  begin
    LClassAbout := TDictionary<string, string>.Create;
    FAbout.Add(Self.ClassType, LClassAbout);
  end;

  if not LClassAbout.TryGetValue(Self.ClassName, Result) then
  begin
    Result := 'Class ' + Self.ClassNameEx + ';';

    AttribText := TPGAboutAttribute.GetFromClass(Self.ClassType);
    if AttribText <> '' then
       Result := Result + #13 + AttribText;

    Self.RttiCreateDefaultAction;
    if Assigned(FDefaultAction) then
      Result := Result + #13 + GetMethodSignature(FDefaultAction, Self.Name);

    LClassAbout.Add(Self.ClassName, Result);
  end;
end;

{ TPGItemMember }

constructor TPGItemMember.Create(const AItemDad: TPGItem; const AMember: TRttiMember; const ATargetClass: TClass);
begin
  inherited Create(AItemDad, AMember.Name);
  FMember := AMember;
  FTargetClass := ATargetClass;
end;

{ TPGItemProperty }

constructor TPGItemProperty.Create(const AItemDad: TPGItem; const AMember: TRttiMember; const ATargetClass: TClass);
begin
  inherited;
  if not TRttiProperty(FMember).IsWritable then
     Self.ReadOnly := True;
end;

procedure TPGItemProperty.Execute(const AGrammar: TPGGrammar);
var
  LProp: TRttiProperty;
  LTarget: TValue;
  LVal: TValue;
begin
  LProp := TRttiProperty(FMember);

  LTarget := TPGKernel.IfThen<TValue>(
     Assigned(FTargetClass),
     TValue.From<TClass>(FTargetClass),
     TValue.From<TPGItem>(Self.Parent)
  );

  if LProp.IsReadable then
    LVal := LProp.GetValue(LTarget.AsObject);

  LVal := Assignment(AGrammar, LVal);

  if (not AGrammar.HasError) and LProp.IsWritable then
  begin
    try
      LVal := ValueAlign(LVal, LProp.PropertyType);
      LProp.SetValue(LTarget.AsObject, LVal);
    except
      on E: Exception do
        AGrammar.Error('Error_Runtime_Typecast', [LProp.Name, E.Message]);
    end;
  end;
end;

function TPGItemProperty.GetAbout(): string;
var
  LClassAbout: TDictionary<string, string>;
  LProp: TRttiProperty;
  LAux: String;
  LTargetClass: TClass;
begin
  Result := '';

  if Assigned(FTargetClass) then
    LTargetClass := FTargetClass
  else
    LTargetClass := Self.Parent.ClassType;

  if not FAbout.TryGetValue(LTargetClass, LClassAbout) then
  begin
    LClassAbout := TDictionary<string, string>.Create;
    FAbout.Add(LTargetClass, LClassAbout);
  end;

  if not LClassAbout.TryGetValue(Self.Name, Result) then
  begin
    LProp := TRttiProperty(FMember);
    Result := 'Property ' + LProp.Name + ': ' + LProp.PropertyType.Name + '; {';

    if LProp.IsReadable then
      Result := Result + 'R';

    if LProp.IsWritable then
    begin
      if LProp.IsReadable then
        Result := Result + ',';
      Result := Result + 'W';
    end;
    Result := Result + '}';

    LAux := TPGAboutAttribute.GetFromProperty(LProp);
    if LAux <> '' then
      Result := Result + #13 + LAux;

    LClassAbout.Add(Self.Name, Result);
  end;
end;

{ TPGItemMethod }

procedure TPGItemMethod.Execute(const AGrammar: TPGGrammar);
var
  LTarget: TValue;
begin
  AGrammar.TokenList.Next;
  LTarget := TPGKernel.IfThen<TValue>(Assigned(FTargetClass), TValue.From<TClass>(FTargetClass), TValue.From<TPGItem>(Self.Parent));
  TPGItemClass.ExecuteRttiMethod(AGrammar, TRttiMethod(FMember), LTarget);
end;

function TPGItemMethod.GetAbout(): string;
var
  LClassAbout: TDictionary<string, string>;
  LTargetClass: TClass;
  LAux: string;
begin
  Result := '';
  if Assigned(FTargetClass) then
    LTargetClass := FTargetClass
  else
    LTargetClass := Self.Parent.ClassType;

  if not FAbout.TryGetValue(LTargetClass, LClassAbout) then
  begin
    LClassAbout := TDictionary<string, string>.Create;
    FAbout.Add(LTargetClass, LClassAbout);
  end;

  if not LClassAbout.TryGetValue(Self.Name, Result) then
  begin
    Result := TPGItemClass.GetMethodSignature(TRttiMethod(FMember));
    LAux := TPGAboutAttribute.GetFromMethod(TRttiMethod(FMember));
    if LAux <> '' then
      Result := Result + #13 + LAux;

    LClassAbout.Add(Self.Name, Result);
  end;
end;

{ TPGItemDef }

constructor TPGItemDef.Create(const AItemDad: TPGItem; const AClass: TPGItemClassType; const AName: string);
begin
  FTargetClass := AClass;
  inherited Create(AItemDad, AName);
end;

procedure TPGItemDef.RttiCreateChildren();
var
  LType: TRttiType;
  LMethod: TRttiMethod;
begin
  if Assigned(FTargetClass) then
  begin
    LType := TPGKernel.RttiContext.GetType(FTargetClass);
    for LMethod in LType.GetMethods do
      if (LMethod.Visibility = mvPublished) and LMethod.IsClassMethod then
        TPGItemMethod.Create(Self, LMethod, FTargetClass);
  end;
  inherited;
end;

procedure TPGItemDef.Execute(const AGrammar: TPGGrammar);
var
  LCount, I: Integer;
  LParams: TArray<TValue>;
  LName: string;
  LNewObj: TPGItemClass;
  LTargetRoot: TPGItem;
begin
  Self.BeforeAccess();
  AGrammar.TokenList.Next;
  if AGrammar.Match(pgkLPar) then
  begin
    if FArgsMap = nil then FArgsMap := TPGItemClass.GetClassArgsMap(FTargetClass);

    LCount := ReadParameters(AGrammar, 1, Length(FArgsMap) + 1);
    if not AGrammar.HasError then
    begin
      SetLength(LParams, LCount - 1);
      for I := High(LParams) downto 0 do LParams[I] := AGrammar.Stack.Pop;
      LName := AGrammar.Stack.Pop.ToString;

      LTargetRoot := FTargetClass.GetDefaultRoot;
      LNewObj := TPGItemClass(FindID(LTargetRoot, LName));

      if not Assigned(LNewObj) then
        LNewObj := FTargetClass.Create(LTargetRoot, LName);

      for I := 0 to High(LParams) do
        if Assigned(FArgsMap[I]) then
          FArgsMap[I].SetValue(LNewObj, LParams[I]);
    end;
  end
  else if AGrammar.Match(pgkDot) then
    ExecuteMember(AGrammar)
  else
    AGrammar.Error('Error_Interpreter_Unrecog', []);
end;

function TPGItemDef.GetAbout(): string;
begin
  Result := 'Factory for ' + FTargetClass.ClassNameEx + #13 + TPGAboutAttribute.GetFromClass(FTargetClass);
end;

function TPGItemDef.GetIconIndex(): Integer;
begin
  if Assigned(FTargetClass) then
    Result := TPGItemType(FTargetClass).ClassIconIndex
  else
    Result := inherited GetIconIndex;
end;

{ TPGFolder }

constructor TPGFolder.Create(const AItemDad: TPGItem; const AName: string);
begin
  inherited Create(AItemDad, AName);
  Self.Namespace := False;
  Self.HasChildren := False;
end;

procedure TPGFolder.ExecuteAction(const AExpanded, ALocked: Boolean);
begin
  Self.Expanded := AExpanded;
  Self.Locked := ALocked;
end;

function TPGFolder.GetMaxOverlayFlag(): TPGItemFlag;
begin
  Result := pgfNamespace;
end;

{ Execução de Scripts }

procedure ScriptExec(const AName, AScript: string; const ANivel: TPGItem; const AWaitFor: Boolean);
var
  LGrammar: TPGGrammar;
begin
  LGrammar := TPGGrammar.Create(AName, ANivel, not AWaitFor);
  LGrammar.SetScript(AScript);
  LGrammar.Start;
  if AWaitFor then
  begin
    LGrammar.WaitFor;
    LGrammar.Free;
  end;
end;

function FileScriptExec(const AFileName: string; const AWait: Boolean): Boolean;
var
  LContent: TStringList;
begin
  Result := FileExists(AFileName);
  if Result then
  begin
    LContent := TStringList.Create;
    try
      LContent.LoadFromFile(AFileName);
      ScriptExec(ExtractFileName(AFileName), LContent.Text, nil, AWait);
    finally
      LContent.Free;
    end;
  end;
end;

initialization

finalization

end.
