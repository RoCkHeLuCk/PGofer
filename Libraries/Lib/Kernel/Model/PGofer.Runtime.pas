unit PGofer.Runtime;

interface

uses
  System.Generics.Collections, System.Rtti, System.SysUtils,
  PGofer.Classes, PGofer.Sintatico;

type
  TPGItemClassType = class of TPGItemClass;

  { Classe base para itens que executam algo no script }
  TPGItemExecute = class(TPGItem)
  public
    procedure Execute(const AGrammar: TPGGrammar); virtual; abstract;
  end;

  { Classe base para Objetos do motor (Links, Tasks, Forms) }
  TPGItemClass = class(TPGItemExecute)
  strict private
    FDefaultAction: TRttiMethod; // Cache de performance para ExecuteAction
  protected
    procedure RttiCreate; virtual;
    procedure ExecuteMember(const AGrammar: TPGGrammar);
    procedure ExecuteDefault(const AGrammar: TPGGrammar); virtual;
    function GetAbout: string; override;

    // Callbacks para as classes filhas
    procedure AfterCreate(const AGrammar: TPGGrammar); virtual;
    procedure BeforeDestroy(const AGrammar: TPGGrammar); virtual;

    class function GetClassArgsMap(AClass: TClass): TArray<TRttiProperty>;
    class function ExecuteRttiMethod(const AGrammar: TPGGrammar; AMethod: TRttiMethod; ATarget: TValue): Boolean;
  public
    constructor Create(AItemDad: TPGItem; const AName: string = ''); reintroduce; virtual;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  { Representa uma Propriedade ou Método via RTTI }
  TPGItemMember = class(TPGItemExecute)
  protected
    FMember: TRttiMember;
    FTargetClass: TClass;
  public
    constructor Create(AOwner: TPGItem; AMember: TRttiMember; ATargetClass: TClass = nil); virtual;
  end;

  TPGItemProperty = class(TPGItemMember)
  protected
    function GetAbout: string; override;
  public
    constructor Create(AOwner: TPGItem; AMember: TRttiMember; ATargetClass: TClass = nil); override;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  TPGItemMethod = class(TPGItemMember)
  protected
    function GetAbout: string; override;
  public
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  { Fábrica de Objetos (Ex: TaskDef, LinkDef) }
  TPGItemDef = class(TPGItemClass)
  strict private
    FTargetClass: TPGItemClassType;
    FArgsMap: TArray<TRttiProperty>; // Cache do mapa de argumentos
  protected
    procedure RttiCreate; override;
    function GetAbout: string; override;
  public
    constructor Create(AClass: TPGItemClassType; const AName: string = ''); reintroduce;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  { Pastas de Organização }
  {$M+}
  TPGFolder = class(TPGItemClass)
  strict private
    FExpanded: Boolean;
    FLocked: Boolean;
  protected
    procedure SetExpanded(const AValue: Boolean); virtual;
    procedure SetLocked(const AValue: Boolean); virtual;
    procedure SetLockedForced(const AValue: Boolean);
  public
    constructor Create(AOwner: TPGItem; const AName: string); override;
    procedure ExecuteAction(AExpanded: Boolean = True; ALocked: Boolean = False);
  published
    property _Expanded: Boolean read FExpanded write SetExpanded;
    property _Locked: Boolean read FLocked write SetLocked;
  end;
  {$TYPEINFO ON}

  { Funções Globais de Execução }
  procedure ScriptExec(const AName, AScript: string; ANivel: TPGItem = nil; AWaitFor: Boolean = False);
  function FileScriptExec(const AFileName: string; AWait: Boolean): Boolean;

var
  GlobalCollection: TPGItemCollect;
  GlobalItemCommand: TPGFolder;
  GlobalItemDefines: TPGFolder;

implementation

uses
  System.Classes, System.TypInfo,
  PGofer.Core, PGofer.Lexico, PGofer.Sintatico.Controls;

{ TPGItemClass }

constructor TPGItemClass.Create(AItemDad: TPGItem; const AName: string);
begin
  inherited Create(AItemDad, TPGKernel.IfThen<String>(AName = '', Self.ClassNameEx, AName));
  RttiCreate;
end;

procedure TPGItemClass.RttiCreate;
var
  LType: TRttiType;
  LProp: TRttiProperty;
  LMethod: TRttiMethod;
begin
  LType := TPGKernel.RttiContext.GetType(Self.ClassType);

  // Cache da ação padrão ()
  FDefaultAction := LType.GetMethod('ExecuteAction');

  if Self.CollectDad = GlobalCollection then
  begin
    // Mapeamento automático de Propriedades Published
    for LProp in LType.GetProperties do
      if (LProp.Visibility = mvPublished) and (not LProp.Name.StartsWith('_')) then
        TPGItemProperty.Create(Self, LProp);

    // Mapeamento automático de Métodos Published
    for LMethod in LType.GetMethods do
      if (LMethod.Visibility = mvPublished) and (not LMethod.Name.StartsWith('_')) and (not LMethod.IsClassMethod) then
        TPGItemMethod.Create(Self, LMethod);
  end;
end;

procedure TPGItemClass.Execute(const AGrammar: TPGGrammar);
begin
  AGrammar.TokenList.Next;

  case AGrammar.TokenList.Current.Kind of
    pgkDot:   ExecuteMember(AGrammar); // Obj.Membro
    pgkLPar:                           // Obj(Args)
    begin
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
  LMember: TPGItem;
begin
  AGrammar.TokenList.Next; // Pula o "."
  LMember := Self.FindName(AGrammar.TokenList.Current.Value.ToString);

  if Assigned(LMember) and (LMember is TPGItemExecute) then
    TPGItemExecute(LMember).Execute(AGrammar)
  else
    AGrammar.Error('Error_Interpreter_MemberNotFound', []);
end;

procedure TPGItemClass.ExecuteDefault(const AGrammar: TPGGrammar);
begin
  // Ação padrão quando apenas o nome do objeto é citado
end;

class function TPGItemClass.ExecuteRttiMethod(const AGrammar: TPGGrammar; AMethod: TRttiMethod; ATarget: TValue): Boolean;
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
    // Proteção de execução se o objeto estiver Disabled
    if ATarget.IsObject and (not TPGItem(ATarget.AsObject).Enabled) then
    begin
      for I := 0 to LCount - 1 do AGrammar.Stack.Pop;
      Exit(True);
    end;

    for I := LCount - 1 downto 0 do LValues[I] := AGrammar.Stack.Pop;

    // Preenchimento de parâmetros restantes com propriedades do objeto ou default
    for I := LCount to High(LParams) do
      LValues[I] := TValue.Empty; // Placeholder

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

class function TPGItemClass.GetClassArgsMap(AClass: TClass): TArray<TRttiProperty>;
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
  end
  else
  begin
    // Fallback: todas as propriedades published escritíveis
    for LProp in LType.GetProperties do
      if (LProp.Visibility = mvPublished) and LProp.IsWritable then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := LProp;
      end;
  end;
end;

function TPGItemClass.GetAbout: string;
begin
  Result := 'Class ' + Self.ClassNameEx + ';' + #13 + TPGAboutAttribute.GetFromClass(Self.ClassType);
end;

procedure TPGItemClass.AfterCreate(const AGrammar: TPGGrammar); begin end;
procedure TPGItemClass.BeforeDestroy(const AGrammar: TPGGrammar); begin end;

{ TPGItemMember }

constructor TPGItemMember.Create(AOwner: TPGItem; AMember: TRttiMember; ATargetClass: TClass);
begin
  inherited Create(AOwner, AMember.Name);
  FMember := AMember;
  FTargetClass := ATargetClass;
end;

{ TPGItemProperty }

constructor TPGItemProperty.Create(AOwner: TPGItem; AMember: TRttiMember; ATargetClass: TClass);
begin
  inherited;
  Self.ReadOnly := not TRttiProperty(FMember).IsWritable;
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

  // Atribuição ou Leitura
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

function TPGItemProperty.GetAbout: string;
begin
  Result := 'Property ' + FMember.Name + ': ' + TRttiProperty(FMember).PropertyType.Name + ';' +
            #13 + TPGAboutAttribute.GetFromProperty(TRttiProperty(FMember));
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

function TPGItemMethod.GetAbout: string;
begin
  Result := 'Method ' + FMember.Name + ';' + #13 + TPGAboutAttribute.GetFromMethod(TRttiMethod(FMember));
end;

{ TPGItemDef }

constructor TPGItemDef.Create(AClass: TPGItemClassType; const AName: string);
begin
  FTargetClass := AClass;
  inherited Create(GlobalItemDefines, TPGKernel.IfThen<string>(AName = '', AClass.ClassNameEx + 'Def', AName));
end;

procedure TPGItemDef.RttiCreate;
var
  LType: TRttiType;
  LMethod: TRttiMethod;
begin
  inherited;
  if Assigned(FTargetClass) then
  begin
    LType := TPGKernel.RttiContext.GetType(FTargetClass);
    for LMethod in LType.GetMethods do
      if (LMethod.Visibility = mvPublished) and LMethod.IsClassMethod then
        TPGItemMethod.Create(Self, LMethod, FTargetClass);
  end;
end;

procedure TPGItemDef.Execute(const AGrammar: TPGGrammar);
var
  LCount, I: Integer;
  LParams: TArray<TValue>;
  LName: string;
  LNewObj: TPGItemClass;
begin
  AGrammar.TokenList.Next;
  if AGrammar.Match(pgkLPar) then
  begin
    // Lazy load do mapa de argumentos
    if FArgsMap = nil then FArgsMap := TPGItemClass.GetClassArgsMap(FTargetClass);

    LCount := ReadParameters(AGrammar, 1, Length(FArgsMap) + 1);
    if not AGrammar.HasError then
    begin
      SetLength(LParams, LCount - 1);
      for I := High(LParams) downto 0 do LParams[I] := AGrammar.Stack.Pop;
      LName := AGrammar.Stack.Pop.ToString;

      // Criação ou Recuperação
      LNewObj := TPGItemClass(FindID(GlobalCollection, LName));
      if not Assigned(LNewObj) then
        LNewObj := FTargetClass.Create(nil, LName);

      // Injeção de propriedades via RTTI
      for I := 0 to High(LParams) do
        if Assigned(FArgsMap[I]) then
          FArgsMap[I].SetValue(LNewObj, LParams[I]);

      LNewObj.AfterCreate(AGrammar);
    end;
  end
  else if AGrammar.Match(pgkDot) then
    ExecuteMember(AGrammar)
  else
    AGrammar.Error('Error_Interpreter_Unrecog', []);
end;

function TPGItemDef.GetAbout: string;
begin
  Result := 'Factory for ' + FTargetClass.ClassNameEx + #13 + TPGAboutAttribute.GetFromClass(FTargetClass);
end;

{ TPGFolder }

constructor TPGFolder.Create(AOwner: TPGItem; const AName: string);
begin
  inherited;
  FLocked := False;
  FExpanded := False;
end;

procedure TPGFolder.ExecuteAction(AExpanded, ALocked: Boolean);
begin
  SetLocked(ALocked);
  SetExpanded(AExpanded);
end;

procedure TPGFolder.SetExpanded(const AValue: Boolean);
begin
  if not FLocked then
  begin
    FExpanded := AValue;
    if Assigned(Node) then Node.Expanded := FExpanded;
  end;
end;

procedure TPGFolder.SetLocked(const AValue: Boolean);
begin
  if AValue = FLocked then Exit;
  FLocked := AValue;
  if FLocked then SetExpanded(False);
end;

procedure TPGFolder.SetLockedForced(const AValue: Boolean);
begin
  FLocked := AValue;
end;

{ Execução de Scripts }

procedure ScriptExec(const AName, AScript: string; ANivel: TPGItem; AWaitFor: Boolean);
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

function FileScriptExec(const AFileName: string; AWait: Boolean): Boolean;
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
  GlobalCollection := TPGItemCollect.Create('Globals');
  GlobalItemCommand := TPGFolder.Create(GlobalCollection, 'Commands');
  GlobalItemDefines := TPGFolder.Create(GlobalCollection, 'Defines');

finalization
  GlobalCollection.Free;

end.
