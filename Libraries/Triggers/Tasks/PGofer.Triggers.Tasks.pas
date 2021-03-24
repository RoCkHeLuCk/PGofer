unit PGofer.Triggers.Tasks;

interface

uses
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes,
    PGofer.Triggers;

type

{$M+}
    TPGTask = class(TPGItemTrigger)
    private
        FDateTime: TDateTime;
        FRepeat: Word;
        FScript: String;
        FType: Byte;
    protected
        procedure ExecutarNivel1(); override;
    public
        constructor Create(Name: String; Mirror: TPGItemMirror);
        destructor Destroy(); override;
        procedure Frame(Parent: TObject); override;
        class var GlobList: TPGItem;
        class procedure Initializations();
        class procedure Finalizations();
    published
        property Script: String read FScript write FScript;
        property DateTime: TDateTime read FDateTime write FDateTime;
        property Repetir: Word read FRepeat write FRepeat;
        property Tipo: Byte read FType write FType;
    end;
{$TYPEINFO ON}

    TPGTaskDeclare = class(TPGItemCMD)
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

    TPGTaskMirror = class(TPGItemMirror)
    public
        constructor Create(ItemDad: TPGItem; AName: String);
        procedure Frame(Parent: TObject); override;
    end;

implementation

uses
    System.SysUtils,
    PGofer.Sintatico.Controls,
    PGofer.Triggers.Tasks.Frame;

{ TPGTask }

constructor TPGTask.Create(Name: String; Mirror: TPGItemMirror);
begin
    inherited Create(TPGTask.GlobList, Name, Mirror);
    Self.ReadOnly := False;
    FScript := '';
    FDateTime := 0;
    FRepeat := 0;
    FType := 0;
end;

destructor TPGTask.Destroy;
begin
    FScript := '';
    FDateTime := 0;
    FRepeat := 0;
    FType := 0;
    inherited;
end;

procedure TPGTask.ExecutarNivel1();
begin
    ScriptExec('Task: ' + Self.Name, Self.Script);
end;

procedure TPGTask.Frame(Parent: TObject);
begin
    inherited Frame(Parent);
    TPGTaskFrame.Create(Self, Parent);
end;

class procedure TPGTask.Initializations;
var
    Item : TPGItem;
begin
    for Item in TPGTask.GlobList do
    begin
        if TPGTask(Item).Tipo = 0 then
           ScriptExec('Task'+Item.Name,TPGTask(Item).Script);
    end;
end;

class procedure TPGTask.Finalizations;
var
    Item : TPGItem;
begin
    for Item in TPGTask.GlobList do
    begin
        if TPGTask(Item).Tipo = 1 then
        begin
            ScriptExec('Task'+Item.Name, TPGTask(Item).Script, nil, True);
        end;
    end;
end;

{ TPGTaskDeclare }

procedure TPGTaskDeclare.Execute(Gramatica: TGramatica);
var
    Titulo: String;
    Quantidade: Byte;
    Task: TPGTask;
    id: TPGItem;
begin
    Gramatica.TokenList.GetNextToken;
    id := IdentificadorLocalizar(Gramatica);
    if (not Assigned(id)) or (id is TPGTask) then
    begin
        Titulo := Gramatica.TokenList.Token.Lexema;
        Quantidade := LerParamentros(Gramatica, 1, 4);
        if not Gramatica.Erro then
        begin
            if (not Assigned(id)) then
                Task := TPGTask.Create(Titulo, nil)
            else
                Task := TPGTask(id);

            if Quantidade = 4 then
                Task.Tipo := Gramatica.Pilha.Desempilhar(0);

            if Quantidade >= 3 then
                Task.Repetir := Gramatica.Pilha.Desempilhar(0);

            if Quantidade >= 2 then
                Task.DateTime := Gramatica.Pilha.Desempilhar(0);

            if Quantidade >= 1 then
                Task.Script := Gramatica.Pilha.Desempilhar('');
        end;
    end
    else
        Gramatica.ErroAdd('Identificador esperado o já existente.');
end;

{ TPGTaskMirror }

constructor TPGTaskMirror.Create(ItemDad: TPGItem; AName: String);
begin
    AName := TPGItemMirror.TranscendName(AName, TPGTask.GlobList);
    inherited Create(ItemDad, TPGTask.Create(AName, Self));
    Self.ReadOnly := False;
end;

procedure TPGTaskMirror.Frame(Parent: TObject);
begin
    TPGTaskFrame.Create(Self.ItemOriginal, Parent);
end;

initialization
    TPGTaskDeclare.Create(GlobalItemCommand, 'Task');
    TPGTask.GlobList := TPGFolder.Create(GlobalItemTrigger, 'Tasks');

    TriggersCollect.RegisterClass('Task', TPGTaskMirror);
finalization


end.
