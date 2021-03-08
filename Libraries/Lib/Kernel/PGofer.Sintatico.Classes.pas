unit PGofer.Sintatico.Classes;

interface

uses
    System.Generics.Collections, System.RTTI,
    PGofer.Classes, PGofer.Sintatico;

type
    TPGAttributeType = (attText, attDocFile, attDocComent, attParam);
    TPGRttiAttribute = class (TCustomAttribute)
    private
        FType: TPGAttributeType;
        FValue: String;
    public
        constructor Create(AttType: TPGAttributeType; Value: String); overload;
        destructor Destroy(); override;
        property AttType : TPGAttributeType read FType;
        property Value : String read FValue;
    end;

    TPGItemCMD = class(TPGItem)
    private
        FAttributeList : TObjectList<TPGRttiAttribute>;
        constructor Create(ItemDad: TPGItem; Name: String; Attrib: Boolean); overload;
        procedure RttiCreate();
        procedure RttiExecute(Gramatica: TGramatica; Item: TPGItemCMD);
    public
        constructor Create(ItemDad: TPGItem; Name: String = ''); overload;
        destructor Destroy(); override;
        procedure Execute(Gramatica: TGramatica); virtual;
        procedure AttributeAdd(AttType: TPGAttributeType; Value: String);
        property AttributeList: TObjectList<TPGRttiAttribute> read FAttributeList;
        function isItemExist(AName:String): Boolean; virtual;
    end;

    TPGFolder = class (TPGItemCMD)
    private
        function GetExpanded(): Boolean;
        procedure SetExpanded(Value: Boolean);
    public
        constructor Create(ItemDad: TPGItem; Name: String = ''); overload;
        property Expanded: Boolean read GetExpanded write SetExpanded;
    end;

    TPGItemMirror = class;

    TPGItemOriginal = class (TPGItemCMD)
    private
        FItemMirror : TPGItemMirror;
    protected
        procedure SetName(Name: String); override;
    public
        constructor Create(ItemDad: TPGItem; Name: String;
                           ItemMirror: TPGItemMirror); overload;
        destructor Destroy(); override;
        property ItemMirror: TPGItemMirror read FItemMirror;
    end;

    TPGItemMirror = class (TPGItem)
    private
        FItemOriginal : TPGItemOriginal;
    public
        constructor Create(ItemDad: TPGItem;
                           ItemOriginal : TPGItemOriginal); overload;
        destructor Destroy(); override;
        property ItemOriginal: TPGItemOriginal read FItemOriginal;
        class function TranscendName(AName: String): String;
    end;


implementation

uses
    System.Classes, System.SysUtils, System.TypInfo,
    PGofer.Lexico, PGofer.Types, PGofer.Sintatico.Controls;

{ TPGAttribute }

constructor TPGRttiAttribute.Create(AttType: TPGAttributeType; Value: String);
begin
    FType := AttType;
    FValue := Value;
end;

destructor TPGRttiAttribute.Destroy();
begin
    FType := attText;
    FValue := '';
    inherited Destroy();
end;

{ TPGItemCMD }
constructor TPGItemCMD.Create(ItemDad: TPGItem; Name: String = '');
begin
    if Name = '' then
       Name := copy(Self.ClassName, 4, Length(Self.ClassName));

    inherited Create(ItemDad, Name);
    FAttributeList := TObjectList<TPGRttiAttribute>.Create(True);
    Self.RttiCreate();
end;

constructor TPGItemCMD.Create(ItemDad: TPGItem; Name: String;
                              Attrib: Boolean);
begin
    inherited Create(ItemDad, Name);
    FAttributeList := TObjectList<TPGRttiAttribute>.Create(True);
    if Attrib then
       Self.RttiCreate();
end;

destructor TPGItemCMD.Destroy();
begin
    FAttributeList.Free;
    inherited Destroy();
end;

procedure TPGItemCMD.AttributeAdd(AttType: TPGAttributeType; Value: String);
begin
    FAttributeList.Add( TPGRttiAttribute.Create(AttType,Value) );
end;

procedure TPGItemCMD.Execute(Gramatica: TGramatica);
begin
    Gramatica.TokenList.GetNextToken;
    if Gramatica.TokenList.Token.Classe = cmdDot then
    begin
        Gramatica.TokenList.GetNextToken;
        Self.RttiExecute(Gramatica, Self);
    end;
end;

function TPGItemCMD.isItemExist(AName: String): Boolean;
var
    Item : TPGItem;
begin
    Item := FindID(GlobalCollection, AName);
    Result := (Assigned(Item) and (Item <> Self));
end;

procedure TPGItemCMD.RttiCreate();
    procedure AttributesAdd(
         AtributeList: TArray<TCustomAttribute>;
         ItemAtt: TPGItemCMD);
    var
        RttiAttribute: TCustomAttribute;
    begin
        if ItemAtt.FAttributeList.Count = 0 then
        begin
            for RttiAttribute in AtributeList do
            begin
                if RttiAttribute is TPGRttiAttribute then
                begin
                   with TPGRttiAttribute(RttiAttribute) do
                   begin
                       ItemAtt.AttributeAdd(FType,FValue);
                   end;
                end;
            end;
        end;
    end;

    procedure CreateItems(RttiMemberList: TArray<TRttiMember>);
    var
        ItemAux : TPGItemCMD;
        RttiMember : TRttiMember;
    begin
        for RttiMember in RttiMemberList do
        begin
            if (RttiMember.Visibility in [mvPublished]) then
            begin
                ItemAux := TPGItemCMD.Create(Self, RttiMember.Name, False);
                AttributesAdd(RttiMember.GetAttributes,ItemAux);
            end;
        end;
    end;

var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
begin
    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(Self.ClassType);
    AttributesAdd(RttiType.GetAttributes,Self);

    if Self.CollectDad = GlobalCollection then
    begin
        CreateItems(TArray<TRttiMember>(RttiType.GetProperties));
        CreateItems(TArray<TRttiMember>(RttiType.GetMethods));
    end;

    RttiContext.Free;
end;

procedure TPGItemCMD.RTTIExecute(Gramatica: TGramatica; Item: TPGItemCMD);
var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    RttiProperty: TRttiProperty;
    RttiMethods: TRttiMethod;
    Parametros: TArray<TRttiParameter>;
    Tamanho: SmallInt;
    Valor: TValue;
    Valores: array of TValue;
    Aux: Variant;
    ItemAux: TPGItemCMD;
begin
    RttiContext := TRttiContext.Create();
    RttiType := RttiContext.GetType(Item.ClassType);

    RttiProperty := RttiType.GetProperty(Gramatica.TokenList.Token.Lexema);
    if Assigned(RttiProperty) and (RttiProperty.Visibility in [mvPublished])
    then
    begin
        if RttiProperty.IsReadable then
            Valor := RttiProperty.GetValue(Item);

        Aux := ConvertValueToVatiant(Valor, RttiProperty.PropertyType.TypeKind);
        Aux := Atribuicao(Gramatica, Aux);
        if not Gramatica.Erro then
        begin
            Valor := ConvertVatiantToValue(Aux,
                RttiProperty.PropertyType.TypeKind);

            if RttiProperty.IsWritable then
                RttiProperty.SetValue(Item, Valor);
        end;
    end
    else
    begin
        RttiMethods := RttiType.GetMethod(Gramatica.TokenList.Token.Lexema);
        if Assigned(RttiMethods) and (RttiMethods.Visibility in [mvPublished])
        then
        begin
            Parametros := RttiMethods.GetParameters;
            Tamanho := Length(Parametros);
            SetLength(Valores, Tamanho);
            LerParamentros(Gramatica, Tamanho, Tamanho);
            if not Gramatica.Erro then
            begin
                for Tamanho := Tamanho - 1 downto 0 do
                begin
                    Aux := Gramatica.Pilha.Desempilhar('');
                    Valores[Tamanho] := ConvertVatiantToValue(Aux,
                        Parametros[Tamanho].ParamType.TypeKind);
                end;

                if Assigned(RttiMethods.ReturnType) then
                begin
                    Valor := RttiMethods.Invoke(Item, Valores);
                    Aux := ConvertValueToVatiant(Valor,
                        RttiMethods.ReturnType.TypeKind);
                    Gramatica.Pilha.Empilhar(Aux);
                end
                else
                    RttiMethods.Invoke(Item, Valores);
            end;
        end
        else
        begin
            ItemAux :=
                TPGItemCMD(Item.FindName(Gramatica.TokenList.Token.Lexema));
            if Assigned(ItemAux) then
            begin
                ItemAux.Execute(Gramatica);
            end
            else
                Gramatica.ErroAdd('Identificador não reconhecido: ' +
                    Gramatica.TokenList.Token.Lexema);
        end;
    end;

    Valor.Empty;
    SetLength(Valores, 0);
    SetLength(Parametros, 0);
    RttiContext.Free;
end;

{ TPGFolder }

constructor TPGFolder.Create(ItemDad: TPGItem; Name: String);
begin
    inherited;
    Self.ReadOnly := False;
end;

function TPGFolder.GetExpanded: Boolean;
begin
    if Assigned(Node) then
       Result := Node.Expanded
    else
       Result := False;
end;

procedure TPGFolder.SetExpanded(Value: Boolean);
begin
    if Assigned(Node) then
       Node.Expanded := Value;
end;

{ TPGItemMirror }

constructor TPGItemOriginal.Create(ItemDad: TPGItem; Name: String;
                                   ItemMirror: TPGItemMirror);
begin
    inherited Create(ItemDad, Name);
    FItemMirror := ItemMirror;
end;

destructor TPGItemOriginal.Destroy();
begin
    if Assigned(FItemMirror) then
       FItemMirror.Free();
    FItemMirror := nil;
    inherited;
end;

procedure TPGItemOriginal.SetName(Name: String);
begin
    inherited;
    if Assigned(FItemMirror) then
       FItemMirror.Name := Name;
end;

{ TPGItemMirror }

constructor TPGItemMirror.Create(ItemDad: TPGItem;
                                 ItemOriginal : TPGItemOriginal);
begin
    inherited Create(ItemDad, ItemOriginal.Name);
    FItemOriginal := ItemOriginal;
end;

destructor TPGItemMirror.Destroy();
begin
    FItemOriginal.FItemMirror := nil;
    FItemOriginal.Free;
    inherited;
end;


class function TPGItemMirror.TranscendName(AName: String): String;
var
    C : Word;
begin
    C := 0;
    Result := AName;
    while Assigned(FindID(GlobalCollection, Result)) do
    begin
        Inc(C);
        Result := AName + IntToStr(C);
    end;
end;

initialization
   GlobalCollection.RegisterClass('Folder',TPGFolder);

finalization

end.
