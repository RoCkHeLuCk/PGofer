unit PGofer.Triggers;

interface

uses
  System.Generics.Collections,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers.Collections, PGofer.Triggers.Frame;

type
  TPGTriggerFrameType = class of TPGTriggerFrame;

  TPGItemTrigger = class(TPGItemClass)
  private
  protected
    class function GetFrameClass(): TPGItemFrameClass; override;

    function RttiSyncChildren(const AHaveChildren:Boolean): Boolean; override;
    procedure SetName(const AName: string); override;
    procedure SetParent(const AParent: TPGItem); override;
    procedure SetNamespace(const AValue: Boolean); override;
    procedure ExecuteDefault(const AGrammar: TPGGrammar); override;
  public
    class procedure AutoRegister(const AAttr: TPGClassRegAttribute); override;
    class function CalculateUniqueName(AItem: TPGItem; const AOriginName: string): string;
    class function OnDropFile(const AItemDad: TPGItem; const AFileName: string): Boolean; virtual;

    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
    procedure Triggering(); virtual; abstract;
  end;

  [TPGClassReg('Defines', 'FolderDef')]
  TPGTriggerFolder = class(TPGFolder)
  private
  protected
    class function GetFrameClass(): TPGItemFrameClass; override;

    procedure SetName(const AName: string); override;
    procedure SetParent(const AParent: TPGItem); override;
    procedure SetNamespace(const AValue: Boolean); override;
  public
    class procedure AutoRegister(const AAttr: TPGClassRegAttribute); override;
    class function OnDropFile(const AItemDad: TPGItem; const AFileName: string): Boolean; virtual;
    class function ClassNameEx(): string; override;

    constructor Create(const AItemDad: TPGItem; const AName: string); override;

    function BeforeXMLSave(const ItemCollect: TPGItemCollectTrigger): Boolean; virtual;
    function BeforeXMLLoad(const ItemCollect: TPGItemCollectTrigger): Boolean; virtual;
  published
    property _Namespace: Boolean read GetNamespace write SetNamespace;
  end;

  TPGTriggerDef = class(TPGItemClass)
  private
    FTargetClass: TPGItemClassType;
  protected
    function RttiSyncChildren(const AHaveChildren:Boolean): Boolean; override;
    function GetAbout: string; override;
    function GetIconIndex: Integer; override;
  public
    constructor Create(const AItemDad: TPGItem; const AClass: TPGItemClassType; const AName: string = ''); reintroduce;
    procedure Execute(const AGrammar: TPGGrammar); override;
  end;

  [TPGClassReg('Commands')]
  TPGMove = class(TPGItemClass)
  public
    procedure ExecuteAction(const AItemPath, ATargetPath: string);
  end;

  procedure Initialize();
  procedure Finalize();

var
  TriggersCollect: TPGItemCollectTrigger;

implementation

uses
  System.SysUtils, System.Rtti, System.TypInfo,
  PGofer.Lexico, PGofer.Sintatico.Controls,
  PGofer.Key.Controls, PGofer.Triggers.Folder.Frame;

procedure Initialize();
begin
  TriggersCollect := TPGItemCollectTrigger.Create(nil, 'Triggers');
  TriggersCollect.HiddeInternal := True;
end;

procedure Finalize();
begin
  TriggersCollect.Free;
  TriggersCollect := nil;
  {$IFDEF DEBUG}
  {$ENDIF}
end;

{ TPGItemTrigger }

class function TPGItemTrigger.CalculateUniqueName(AItem: TPGItem; const AOriginName: string): string;
var
  LBaseName, ResultName: string;
  LCount: Integer;
  LCollision, LScope: TPGItem;
begin
  LBaseName := NormalizeID(AOriginName);
  if LBaseName = '' then LBaseName := 'New' + AItem.ClassNameEx;
  ResultName := LBaseName;

  LScope := AItem.Parent;
  while Assigned(LScope) do
  begin
    if (LScope is TPGItemCollect) or (pgfNamespace in LScope.Flags) then Break;
    LScope := LScope.Parent;
  end;

  if Assigned(LScope) then
  begin
    LCount := 0;
    while True do
    begin
      LCollision := LScope.FindName(ResultName);
      if (not Assigned(LCollision)) or (LCollision = AItem) then Break;
      Inc(LCount);
      ResultName := LBaseName + IntToStr(LCount);
    end;
  end;
  Result := ResultName;
end;

class procedure TPGItemTrigger.AutoRegister(const AAttr: TPGClassRegAttribute);
var
  LTargetFolder: TPGItem;
  LClassName: string;
begin
  // 1. Resolve o nome
  if (AAttr.Name <> '') then
    LClassName := AAttr.Name
  else
    LClassName := Self.ClassNameEx;

  // 2. Resolve a pasta
  LTargetFolder := TPGFolder.FindPath(AAttr.Path, True, GlobalCollection, TPGFolder);

  if Assigned(LTargetFolder) then
     TPGTriggerDef.Create(LTargetFolder, Self, LClassName);

  // Registra automaticamente para o menu de "Novo" e XML
  TriggersCollect.RegisterClass(Self);
end;

constructor TPGItemTrigger.Create(const AItemDad: TPGItem; const AName: string);
begin
  inherited Create(AItemDad, AName);
  Self.Internal := False;
  Self.Invalid := True;
end;

procedure TPGItemTrigger.SetName(const AName: string);
var
  LNewName: String;
begin
  LNewName := TPGItemTrigger.CalculateUniqueName(Self, AName);
  if AName <> LNewName then
     TPGKernel.ConsoleTr('Warning_Interpreter_AutoRename',[AName,LNewName]);
  inherited SetName( LNewName );
end;

procedure TPGItemTrigger.SetNamespace(const AValue: Boolean);
begin
  if (Self.Namespace = AValue) then
    Exit;

  inherited SetNamespace(AValue);
  Self.SetName( Self.Name );
end;

procedure TPGItemTrigger.SetParent(const AParent: TPGItem);
begin
  if (Self.Parent = AParent) then
    Exit;

  //aqui atualiza para ele aparecer na lista
  Self.Internal := False;

  inherited SetParent(AParent);
  Self.SetName( Self.Name );
end;

procedure TPGItemTrigger.ExecuteDefault(const AGrammar: TPGGrammar);
begin
  Self.Triggering();
end;

class function TPGItemTrigger.GetFrameClass: TPGItemFrameClass;
begin
  Result := TPGTriggerFrame;
end;

class function TPGItemTrigger.OnDropFile(const AItemDad: TPGItem; const AFileName: string): Boolean;
begin
  Result := False;
end;

function TPGItemTrigger.RttiSyncChildren(const AHaveChildren: Boolean): Boolean;
begin
  if TriggersCollect.HiddeInternal and AHaveChildren then
    Exit(False);

  Result := inherited RttiSyncChildren(False);
end;

{ TPGTriggerFolder }

class function TPGTriggerFolder.ClassNameEx(): string;
begin
  Result := 'Folder';
end;

constructor TPGTriggerFolder.Create(const AItemDad: TPGItem; const AName: string);
begin
  inherited Create(AItemDad, AName);
  Self.Internal := False;
  Self.Namespace := True;
end;

class function TPGTriggerFolder.GetFrameClass: TPGItemFrameClass;
begin
  Result := TPGFolderFrame;
end;

class function TPGTriggerFolder.OnDropFile(const AItemDad: TPGItem; const AFileName: string): Boolean;
begin
  Result := DirectoryExists(AFileName);
  if Result then
    TPGTriggerFolder.Create(AItemDad, ExtractFileName(AFileName));
end;

procedure TPGTriggerFolder.SetName(const AName: string);
var
  LNewName: String;
begin
  LNewName := TPGItemTrigger.CalculateUniqueName(Self, AName);
  if AName <> LNewName then
     TPGKernel.ConsoleTr('Warning_Interpreter_AutoRename',[AName,LNewName]);
  inherited SetName( LNewName );
end;

procedure TPGTriggerFolder.SetNamespace(const AValue: Boolean);
begin
  if (Self.Namespace = AValue) then
    Exit;

  inherited SetNamespace(AValue);
  Self.SetName(Self.Name);
end;

procedure TPGTriggerFolder.SetParent(const AParent: TPGItem);
begin
  if (Self.Parent = AParent) then
    Exit;

  //aqui atualiza para ele aparecer na lista
  Self.Internal := False;

  inherited SetParent(AParent);
  Self.SetName(Self.Name);
end;

function TPGTriggerFolder.BeforeXMLSave(const ItemCollect: TPGItemCollectTrigger): Boolean;
begin
  Result := True;
end;

class procedure TPGTriggerFolder.AutoRegister(const AAttr: TPGClassRegAttribute);
var
  LTargetFolder: TPGItem;
  LClassName: string;
begin
  // 1. Resolve o nome
  if (AAttr.Name <> '') then
    LClassName := AAttr.Name
  else
    LClassName := Self.ClassNameEx;

  // 2. Resolve a pasta
  LTargetFolder := TPGFolder.FindPath(AAttr.Path, True, GlobalCollection, TPGFolder);

  if Assigned(LTargetFolder) then
     TPGTriggerDef.Create(LTargetFolder, Self, LClassName);

  // Registra automaticamente para o menu de "Novo" e XML
  TriggersCollect.RegisterClass(Self);
end;

function TPGTriggerFolder.BeforeXMLLoad(const ItemCollect: TPGItemCollectTrigger): Boolean;
begin
  Result := True;
end;

{ TPGTriggerDef }

constructor TPGTriggerDef.Create(const AItemDad: TPGItem; const AClass: TPGItemClassType; const AName: string);
begin
  FTargetClass := AClass;
  inherited Create(AItemDad, AName);
end;

function TPGTriggerDef.RttiSyncChildren(const AHaveChildren:Boolean): Boolean;
var
  LType: TRttiType;
  LMethod: TRttiMethod;
begin
  Result := False;
  if (not Assigned(FTargetClass)) then
    Exit(False);

  LType := TPGKernel.RttiContext.GetType(FTargetClass);
  for LMethod in LType.GetMethods do
    if (LMethod.Visibility = mvPublished) and LMethod.IsClassMethod then
    begin
      if AHaveChildren then
        Exit(True);
      TPGItemMethod.Create(Self, LMethod, FTargetClass);
    end;

  inherited RttiSyncChildren(AHaveChildren);
end;

procedure TPGTriggerDef.Execute(const AGrammar: TPGGrammar);
var
  LPath, LName, LParentPath: string;
  LDots: Integer;
  LTargetParent: TPGItem;
  LExisting: TPGItem;
  LNewObj: TPGItemClass;
begin
  if (not Assigned(FTargetClass)) then
    Exit;

  AGrammar.Next;
  if AGrammar.Match(pgkLPar) then
  begin
    if (ReadParameters(AGrammar, 1, 1) = 1) and (not AGrammar.HasError) then
    begin
      //carrega o parametro
      LPath := ValueToString(AGrammar.Stack.Pop);

      //resolve o escopo e o nome
      LDots := LastDelimiter('.', LPath);

      if LDots > 0 then
      begin
        // LParentPath: Do início até antes do ponto
        LParentPath := Copy(LPath, 1, LDots - 1);
        // LName: Do caractere após o ponto até o fim
        LName := Copy(LPath, LDots + 1, MaxInt);
      end else begin
        LParentPath := '';
        LName := LPath;
      end;

      //localiza e cria o escopo
      LTargetParent := TPGFolder.FindPath(LParentPath, True, TriggersCollect, TPGTriggerFolder);

      if Assigned(LTargetParent) then
      begin
        // Busca se já existe na raiz
        LExisting := LTargetParent.FindName(LName);

        if Assigned(LExisting) then
        begin
          if not (LExisting is FTargetClass) then
          begin
            AGrammar.Error('Error_Interpreter_TypeMismatch', [LName, FTargetClass.ClassNameEx]);
            Exit;
          end;

          LNewObj := TPGItemClass(LExisting);
          // Se mudou de pasta, move
          if LNewObj.Parent <> LTargetParent then
          begin
             LNewObj.Parent := LTargetParent;
             AGrammar.Msg('Warning_Interpreter_Moved', [LName, LTargetParent.Name]);
          end;
        end else
          FTargetClass.Create(LTargetParent, LName);

        // salvar
        TriggersCollect.XMLSaveToFile();
      end;
    end;
  end else begin
    if AGrammar.Match(pgkDot) then
      Self.ExecuteMember(AGrammar)
    else
      AGrammar.Error('Error_Interpreter_Unrecog', []);
  end;
end;

function TPGTriggerDef.GetAbout(): string;
var
  LType: TRttiType;
  LMethod: TRttiMethod;
  AText, AAux: string;
begin
  if (not Assigned(FTargetClass)) then
    Exit('');

  Result := 'Factory Class: ' + FTargetClass.ClassNameEx + ';';

  AText := TPGAboutAttribute.GetFromClass(FTargetClass);
  if AText <> '' then
    Result := Result  + sLineBreak + AText;

  // 1. Assinatura do construtor
  Result := Result + sLineBreak + '[Create]'
    + sLineBreak + '  ' + Self.Name + '("Path.Name");';

  // 2. Ferramentas estáticas
  Result := Result + sLineBreak + '[Class Tools]';
  LType := TPGKernel.RttiContext.GetType(FTargetClass);
  for LMethod in LType.GetMethods do
  begin
    if LMethod.IsClassMethod and (LMethod.Visibility = mvPublished) then
    begin
      AText := TPGItemClass.GetMethodSignature(LMethod);
      AAux := TPGAboutAttribute.GetFromMethod(LMethod);
      if AAux <> '' then
        Result := Result + sLineBreak + '  //' + AAux + sLineBreak + '  '+ AText;
    end;
  end;
end;

function TPGTriggerDef.GetIconIndex(): Integer;
begin
  if Assigned(FTargetClass) then
    Result := TPGItemType(FTargetClass).ClassIconIndex
  else
    Result := inherited GetIconIndex;
end;

{ TPGMove }

procedure TPGMove.ExecuteAction(const AItemPath, ATargetPath: string);
var
  LItem, LTarget: TPGItem;
begin
  LItem := TPGFolder.FindPath(AItemPath, False, TriggersCollect, TPGTriggerFolder);
  LTarget := TPGFolder.FindPath(ATargetPath, True, TriggersCollect, TPGTriggerFolder);

  if Assigned(LItem) and Assigned(LTarget) then
    LItem.Parent := LTarget;
end;

initialization

finalization

end.
