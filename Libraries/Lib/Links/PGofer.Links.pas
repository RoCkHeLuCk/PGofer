unit PGofer.Links;

interface

uses
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes;

type

{$M+}
    TPGLinks = class(TPGItemCMD)
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
        class var LinkGlobList: TPGItem;
        constructor Create(Nome, Arquivo, Parametro, Diretorio,
            IconeFile: String; IconeIndex, Estado, Operation, Prioridade: Byte);
        destructor Destroy(); override;
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

    TPGLinkDec = class(TPGItemCMD)
    public
        procedure Execute(Gramatica: TGramatica); override;
    end;

implementation

uses
    System.SysUtils,
    PGofer.Lexico, PGofer.Sintatico.Controls,
    PGofer.Files.Controls, PGofer.Types, PGofer.Links.Frame;

{ TPGLinks }

constructor TPGLinks.Create(Nome, Arquivo, Parametro, Diretorio,
    IconeFile: String; IconeIndex, Estado, Operation, Prioridade: Byte);
begin
    inherited Create(Nome);
    FArquivo := Arquivo;
    FParametro := Parametro;
    FDiretorio := Diretorio;
    FIconeFile := IconeFile;
    FIconeIndex := IconeIndex;
    FEstado := Estado;
    FPrioridade := Prioridade;
    FOperation := Operation;
    ReadOnly := False;
end;

destructor TPGLinks.Destroy;
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

procedure TPGLinks.SetIco(FileName: String);
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

function TPGLinks.ExecutarNivel1(): String;
begin
    Result := FileExec(FArquivo, FParametro, FDiretorio, FEstado, FOperation,
        FPrioridade);
end;

procedure TPGLinks.Frame(Parent: TObject);
begin
    inherited Frame(Parent);
    TPGFrameLinks.Create(Self, Parent);
end;

function TPGLinks.GetDirExist: Boolean;
begin
    Result := DirectoryExists(FileExpandPath(FDiretorio));
end;

function TPGLinks.GetFileExist: Boolean;
begin
    Result := FileExists(FileExpandPath(FArquivo));
end;

function TPGLinks.GetIconExist: Boolean;
begin
    if FIconeFile <> '' then
        Result := FileExists(FileExpandPath(FIconeFile))
    else
        Result := True;
end;

procedure TPGLinks.Execute(Gramatica: TGramatica);
begin
    if Assigned(Gramatica) then
    begin
        Gramatica.TokenList.GetNextToken;
        if Gramatica.TokenList.Token.Classe = cmdDot then
        begin
            Gramatica.TokenList.GetNextToken;
            PGofer.Types.Executar(Gramatica, Self);
        end
        else
            Gramatica.Pilha.Empilhar(Self.ExecutarNivel1());
    end
    else
    begin
        Self.ExecutarNivel1();
    end;
end;

{ TPGLinkDec }
procedure TPGLinkDec.Execute(Gramatica: TGramatica);
var
    Titulo: String;
    Arquivo: String;
    Parametro: String;
    Diretorio: String;
    IconeFile: String;
    IconeIndex: Word;
    Estado: Byte;
    Operation: Byte;
    Prioridade: Byte;
    Quantidade: Byte;
    Link: TPGLinks;
begin
    Gramatica.TokenList.GetNextToken;
    if (not Assigned(IdentificadorLocalizar(Gramatica))) then
    begin
        Titulo := Gramatica.TokenList.Token.Lexema;
        Quantidade := LerParamentros(Gramatica, 1, 7);
        if not Gramatica.Erro then
        begin
            // ?????????? tentar otimizar isso
            if Quantidade = 8 then
                Prioridade := Gramatica.Pilha.Desempilhar(3)
            else
                Prioridade := 3;

            if Quantidade >= 7 then
                Operation := Gramatica.Pilha.Desempilhar(0)
            else
                Operation := 0;

            if Quantidade >= 6 then
                Estado := Gramatica.Pilha.Desempilhar(1)
            else
                Estado := 1;

            if Quantidade >= 5 then
                IconeIndex := Gramatica.Pilha.Desempilhar(0)
            else
                IconeIndex := 0;

            if Quantidade >= 4 then
                IconeFile := Gramatica.Pilha.Desempilhar(0);

            if Quantidade >= 3 then
                Diretorio := Gramatica.Pilha.Desempilhar('');

            if Quantidade >= 2 then
                Parametro := Gramatica.Pilha.Desempilhar('');

            if Quantidade >= 1 then
                Arquivo := Gramatica.Pilha.Desempilhar('');

            Link := TPGLinks.Create(Titulo, Arquivo, Parametro, Diretorio,
                IconeFile, IconeIndex, Estado, Operation, Prioridade);

            TPGLinks.LinkGlobList.Add(Link);
        end;
    end
    else
        Gramatica.ErroAdd('Identificador esperado.');
end;

initialization
    TGramatica.Global.FindName('Commands').Add(TPGLinkDec.Create('Link'));
    TPGLinks.LinkGlobList := TGramatica.Global.Add('Links');

finalization

end.
