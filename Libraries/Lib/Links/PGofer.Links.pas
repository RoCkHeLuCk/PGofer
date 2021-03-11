unit PGofer.Links;

interface

uses
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes;

type

{$M+}
    TPGLink = class(TPGItemOriginal)
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
        class var FlockCollection: TPGItemCollect;
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

    TPGLinkMirror = class(TPGItemMirror)
    public
        constructor Create(ItemDad: TPGItem; AName: String);
        procedure Frame(Parent: TObject); override;
    end;

implementation

uses
    System.SysUtils,
    PGofer.Lexico, PGofer.Sintatico.Controls,
    PGofer.Files.Controls, PGofer.Links.Frame;

{ TPGLinks }

constructor TPGLink.Create(Name: String; Mirror: TPGItemMirror);
begin
    inherited Create(TPGLink.GlobList, Name, Mirror);
    Self.ReadOnly := False;
    FArquivo := '';
    FParametro := '';
    FDiretorio := '';
    FIconeFile := '';
    FIconeIndex := 0;
    FEstado := 1;
    FPrioridade := 3;
    FOperation := 0;
end;

destructor TPGLink.Destroy;
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

procedure TPGLink.SetIco(FileName: String);
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

function TPGLink.ExecutarNivel1(): String;
begin
    Result := FileExec(FArquivo, FParametro, FDiretorio, FEstado, FOperation,
      FPrioridade);
end;

procedure TPGLink.Frame(Parent: TObject);
begin
    inherited Frame(Parent);
    TPGLinkFrame.Create(Self, Parent);
end;

function TPGLink.GetDirExist: Boolean;
begin
    Result := DirectoryExists(FileExpandPath(FDiretorio));
end;

function TPGLink.GetFileExist: Boolean;
begin
    Result := FileExists(FileExpandPath(FArquivo));
end;

function TPGLink.GetIconExist: Boolean;
begin
    if FIconeFile <> '' then
        Result := FileExists(FileExpandPath(FIconeFile))
    else
        Result := True;
end;

procedure TPGLink.Execute(Gramatica: TGramatica);
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
    Link: TPGLink;
begin
    Gramatica.TokenList.GetNextToken;
    Id := IdentificadorLocalizar(Gramatica);
    if (not Assigned(Id)) or (Id is TPGLink) then
    begin
        Titulo := Gramatica.TokenList.Token.Lexema;
        Quantidade := LerParamentros(Gramatica, 1, 7);
        if not Gramatica.Erro then
        begin
            if (not Assigned(Id)) then
                Link := TPGLink.Create(Titulo, nil)
            else
                Link := TPGLink(Id);

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

{ TPGLinkMirror }
constructor TPGLinkMirror.Create(ItemDad: TPGItem; AName: String);
begin
    AName := TPGItemMirror.TranscendName(AName);
    inherited Create(ItemDad, TPGLink.Create(AName, Self));
    Self.ReadOnly := False;
end;

procedure TPGLinkMirror.Frame(Parent: TObject);
begin
    TPGLinkFrame.Create(Self.ItemOriginal, Parent);
end;

initialization
    TPGLinkDeclare.Create(GlobalItemCommand, 'Link');
    TPGLink.GlobList := TPGFolder.Create(GlobalCollection, 'Links');
    TPGLink.FlockCollection := TPGItemCollect.Create('Links', True);
    TPGLink.FlockCollection.RegisterClass('Folder', TPGFolder);
    TPGLink.FlockCollection.RegisterClass('Link', TPGLinkMirror);
    GlobalFlockList.Add(TPGLink.FlockCollection);

finalization

end.
