unit PGofer.Links;

interface

uses
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes;

type
    TPGLinkMirror = class;

{$M+}
    TPGLinkMain = class(TPGItemOriginal)
    private
        FArquivo: String;
        FParametro: String;
        FDiretorio: String;
        FIconeFile: String;
        FIconeIndex: Byte;
        FEstado: Byte;
        FPrioridade: Byte;
        FOperation: Byte;
        procedure SetIco(FileName: String);
        function GetDirExist(): Boolean;
        function GetFileExist(): Boolean;
        function GetIconExist(): Boolean;
        function ExecutarNivel1(): String;
    public
        constructor Create(Name: String; Mirror: TPGItemMirror);
        destructor Destroy(); override;
        class var GlobList: TPGItem;
        procedure Execute(Gramatica: TGramatica); override;
        procedure Frame(Parent: TObject); override;
    published
        property Arquivo: String read FArquivo write FArquivo;
        property Parametro: String read FParametro write FParametro;
        property Diretorio: String read FDiretorio write FDiretorio;
        property IconeFile: String read FIconeFile write SetIco;
        property IconeIndex: Byte read FIconeIndex write FIconeIndex;
        property Estado: Byte read FEstado write FEstado;
        property Prioridade: Byte read FPrioridade write FPrioridade;
        property Operation: Byte read FOperation write FOperation;
        property isFileExist: Boolean read GetFileExist;
        property isDirExist: Boolean read GetDirExist;
        property isIconExist: Boolean read GetIconExist;
    end;
{$TYPEINFO ON}

    TPGLinkDeclare = class(TPGItemCMD)
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

{$M+}
    TPGLinkMirror = class(TPGItemMirror)
    private
        function GetFileName(): String;
        procedure SetFileName(Value: String);
        function GetParameter(): String;
        procedure SetParameter(Value: String);
        function GetPath(): String;
        procedure SetPath(Value: String);
        function GetIconFile(): String;
        procedure SetIcoFile(Value: String);
        function GetIconIndex(): Byte;
        procedure SetIconIndex(Value: Byte);
        function GetState(): Byte;
        procedure SetState(Value: Byte);
        function GetPriority(): Byte;
        procedure SetPriority(Value: Byte);
        function GetOperation(): Byte;
        procedure SetOperation(Value: Byte);
    protected
        FOriginal : TPGLinkMain;
    public
        constructor Create(ItemDad: TPGItem; Name: String);
        procedure Frame(Parent: TObject); override;
    published
        property Arquivo: String read GetFileName write SetFileName;
        property Parametro: String read GetParameter write SetParameter;
        property Diretorio: String read GetPath write SetPath;
        property IconeFile: String read GetIconFile write SetIcoFile;
        property IconeIndex: Byte read GetIconIndex write SetIconIndex;
        property Estado: Byte read GetState write SetState;
        property Prioridade: Byte read GetPriority write SetPriority;
        property Operation: Byte read GetOperation write SetOperation;
    end;
{$TYPEINFO ON}


implementation

uses
    System.SysUtils,
    PGofer.Lexico, PGofer.Sintatico.Controls,
    PGofer.Files.Controls, PGofer.Types, PGofer.Links.Frame;

{ TPGLinks }

constructor TPGLinkMain.Create(Name: String; Mirror: TPGItemMirror);
begin
    inherited Create(TPGLinkMain.GlobList, Name, Mirror);
    FArquivo := '';
    FParametro := '';
    FDiretorio := '';
    FIconeFile := '';
    FIconeIndex := 0;
    FEstado := 1;
    FPrioridade := 3;
    FOperation := 0;
    ReadOnly := False;
end;

destructor TPGLinkMain.Destroy;
begin
    FArquivo := '';
    FParametro := '';
    FDiretorio := '';
    FIconeFile := '';
    FIconeIndex := 0;
    FEstado := 1;
    FPrioridade := 3;
    FOperation := 0;
    inherited;
end;

procedure TPGLinkMain.SetIco(FileName: String);
begin
    FIconeFile := FileName;
    {
      var
      FileName : String;
      begin
      if (IconLoader) then
      begin
      FileName := FileExpandPath(FIcone);
      if (FileExists(FileName)) and (not FileIsReadOnly(FileName)) then
      begin
      if not Assigned(FIconeImage) then
      FIconeImage := TIcon.Create;
      FIconeImage.Handle := ExtractAssociatedIcon(1, PWideChar(FileName), FIconeIndex );
      end;//if fileexist
      end;
    }

end;

function TPGLinkMain.ExecutarNivel1(): String;
begin
    Result := FileExec(FArquivo, FParametro, FDiretorio, FEstado, FOperation,
        FPrioridade);
end;

procedure TPGLinkMain.Frame(Parent: TObject);
begin
    inherited Frame(Parent);
    TPGFrameLinks.Create(Self, Parent);
end;

function TPGLinkMain.GetDirExist: Boolean;
begin
    Result := DirectoryExists(FileExpandPath(FDiretorio));
end;

function TPGLinkMain.GetFileExist: Boolean;
begin
    Result := FileExists(FileExpandPath(FArquivo));
end;

function TPGLinkMain.GetIconExist: Boolean;
begin
    if FIconeFile <> '' then
        Result := FileExists(FileExpandPath(FIconeFile))
    else
        Result := True;
end;

procedure TPGLinkMain.Execute(Gramatica: TGramatica);
begin
    if Assigned(Gramatica) then
    begin
        inherited Execute(Gramatica);
        if Gramatica.TokenList.Token.Classe <> cmdDot then
            Gramatica.Pilha.Empilhar(Self.ExecutarNivel1());
    end
    else
    begin
        Self.ExecutarNivel1();
    end;
end;

{ TPGLinkDec }
procedure TPGLinkDeclare.Execute(Gramatica: TGramatica);
var
    Titulo: String;
    Quantidade: Byte;
    Id: TPGItem;
    Link: TPGLinkMain;
begin
    Gramatica.TokenList.GetNextToken;
    Id := IdentificadorLocalizar(Gramatica);
    if (not Assigned(Id)) or (Id is TPGLinkMain) then
    begin
        Titulo := Gramatica.TokenList.Token.Lexema;
        Quantidade := LerParamentros(Gramatica, 1, 7);
        if not Gramatica.Erro then
        begin
            if (not Assigned(Id)) then
               Link := TPGLinkMain.Create(Titulo, nil)
            else
               Link := TPGLinkMain(Id);

            if Quantidade = 8 then
                Link.Prioridade := Gramatica.Pilha.Desempilhar(3);

            if Quantidade >= 7 then
                Link.Operation := Gramatica.Pilha.Desempilhar(0);

            if Quantidade >= 6 then
                Link.Estado := Gramatica.Pilha.Desempilhar(1);

            if Quantidade >= 5 then
                Link.IconeIndex := Gramatica.Pilha.Desempilhar(0);

            if Quantidade >= 4 then
                Link.IconeFile := Gramatica.Pilha.Desempilhar(0);

            if Quantidade >= 3 then
                Link.Diretorio := Gramatica.Pilha.Desempilhar('');

            if Quantidade >= 2 then
                Link.Parametro := Gramatica.Pilha.Desempilhar('');

            if Quantidade >= 1 then
                Link.Arquivo := Gramatica.Pilha.Desempilhar('');
        end;
    end
    else
        Gramatica.ErroAdd('Identificador esperado ou existente.');
end;

initialization
    TPGLinkDeclare.Create(GlobalItemCommand, 'Link');
    TPGLinkMain.GlobList := TPGFolder.Create(GlobalCollection, 'Links');
    GlobalCollection.RegisterClass(TPGLinkMain);

finalization

end.
