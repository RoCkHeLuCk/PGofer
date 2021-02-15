unit PGofer.Classes;

interface

uses
    System.Generics.Collections;

const
    LowString = Low(String);

type
    TPGItem = class;

    TPGItemNotification = (cmCreate, cmDestroy, cmEdit, cmMove);
    TPGItemNotify = procedure(Sender: TPGItem; Action: TPGItemNotification)
        of object;
    TPGMsgNotify = procedure(Texto: String) of object;

    TPGAttributeType = (attText, attDocFile, attDocComent, attParam);
    TPGItemAttribute = class
    private
        FType: TPGAttributeType;
        FValue: String;
    public
        constructor Create(AttType: TPGAttributeType; Value: String); overload;
        destructor Destroy(); override;
        property AttType : TPGAttributeType read FType;
        property Value : String read FValue;
    end;

    TPGItem = class(TObjectList<TPGItem>)
        constructor Create(Name: String); overload;
        destructor Destroy(); override;
    private
        FName: String;
        FEnabled: Boolean;
        FReadOnly: Boolean;
        FDad: TPGItem;
        FNode: TObject;
        FAttribute : TArray<TPGItemAttribute>;
        class var FItemNotify: TPGItemNotify;
        class var FMsgNotify: TPGMsgNotify;
        procedure SetName(Name: String);
        procedure SetEnabled(Enabled: Boolean);
        procedure SetDad(Dad: TPGItem);
        procedure ChildNotify(Sender: TObject; const Value: TPGItem;
            Action: TCollectionNotification);
    public
        property Name: String read FName write SetName;
        property Enabled: Boolean read FEnabled write SetEnabled;
        property ReadOnly: Boolean read FReadOnly write FReadOnly;
        property Dad: TPGItem read FDad write SetDad;
        property Node: TObject read FNode write FNode;
        property Attibutes: TArray<TPGItemAttribute> read FAttribute;
        procedure Frame(Parent: TObject); virtual;
        function FindName(Name: String): TPGItem;
        function FindNameList(Name: String; Partial: Boolean): TArray<TPGItem>;
        function Add(Item: TPGItem): TPGItem; overload;
        function Add(Name: String): TPGItem; overload;
        class property OnItemNotify: TPGItemNotify read FItemNotify
            write FItemNotify;
        class property OnMsgNotify: TPGMsgNotify read FMsgNotify
            write FMsgNotify;
    end;

implementation

uses
    System.SysUtils, PGofer.Item.Frame;

{ TPGAttribute }

constructor TPGItemAttribute.Create(AttType: TPGAttributeType; Value: String);
begin
    inherited Create();
    FType := AttType;
    FValue := Value;
end;

destructor TPGItemAttribute.Destroy;
begin
    FType := attText;
    FValue := '';
    inherited Destroy();
end;

{ TPGItem }
constructor TPGItem.Create(Name: String);
begin
    inherited Create(True);
    FName := Name;
    FEnabled := True;
    FReadOnly := True;
    Self.OnNotify := ChildNotify;
    FNode := nil;
    if Assigned(FItemNotify) then
        FItemNotify(Self, cmCreate);
end;

destructor TPGItem.Destroy();
begin
    if Assigned(FItemNotify) then
        FItemNotify(Self, cmDestroy);

    FName := '';
    FEnabled := False;
    FReadOnly := False;
    if Assigned(FDad) then
        FDad.Extract(Self);

    FNode := nil;

    inherited Destroy();
end;

procedure TPGItem.ChildNotify(Sender: TObject; const Value: TPGItem;
    Action: TCollectionNotification);
begin
    case Action of
        cnAdded:
            begin
                Value.Dad := Self;
            end;

        cnRemoved, cnExtracted:
            begin

            end;
    end;
end;

procedure TPGItem.SetEnabled(Enabled: Boolean);
begin
    FEnabled := Enabled;
    if Assigned(FItemNotify) then
        FItemNotify(Self, cmEdit);
end;

procedure TPGItem.SetDad(Dad: TPGItem);
begin
    FDad := Dad;
    if Assigned(FItemNotify) then
        FItemNotify(Self, cmMove);
end;

procedure TPGItem.SetName(Name: String);
begin
    FName := Name;
    if Assigned(FItemNotify) then
        FItemNotify(Self, cmEdit);
end;

procedure TPGItem.Frame(Parent: TObject);
begin
    TPGFrame.Create(Self, Parent);
end;

function TPGItem.FindName(Name: String): TPGItem;
var
    C: FixedInt;
begin
    Result := nil;
    C := 0;
    while (C < Self.Count) and (not Assigned(Result)) do
    begin
        if SameText(Name, Self[C].Name) then
            Result := Self[C];
        inc(C);
    end;
end;

function TPGItem.FindNameList(Name: String; Partial: Boolean): TArray<TPGItem>;
var
    C, D: FixedInt;
begin
    D := 0;
    SetLength(Result,0);
    for C := 0 to Self.Count-1 do
    begin
        if (Partial and (Pos(LowerCase(Name),LowerCase(Self[C].Name)) > 0))
        or (not Partial and SameText(Name, Self[C].Name))
        or (Name = '') then
        begin
           Inc(D);
           SetLength(Result,D);
           Result[D-1] := Self[C];
        end;
    end;
end;

function TPGItem.Add(Item: TPGItem): TPGItem;
begin
    inherited Add(Item);
    Result := Item;
end;

function TPGItem.Add(Name: string): TPGItem;
begin
    Result := TPGItem.Create(Name);
    inherited Add(Result);
end;

initialization

finalization

end.
