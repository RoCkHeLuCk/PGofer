unit PGofer.Triggers;

interface
uses
    PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes;

type
    TPGItemMirror = class;

    TPGItemTrigger = class(TPGItemCMD)
    private
        FItemMirror: TPGItemMirror;
    protected
        procedure ExecutarNivel1(); virtual; abstract;
        procedure SetName(Name: String); override;
    public
        constructor Create(ItemDad: TPGItem; Name: String;
          ItemMirror: TPGItemMirror); overload;
        destructor Destroy(); override;
        property ItemMirror: TPGItemMirror read FItemMirror;
        procedure Execute(Gramatica: TGramatica); override;
    end;

    TPGItemMirror = class(TPGItem)
    private
        FItemOriginal: TPGItemTrigger;
    public
        constructor Create(ItemDad: TPGItem;
          ItemOriginal: TPGItemTrigger); overload;
        destructor Destroy(); override;
        property ItemOriginal: TPGItemTrigger read FItemOriginal;
        class function TranscendName(AName: String;
                                     ItemList: TPGItem = nil): String;
    end;


implementation
uses
   System.SysUtils,
   PGofer.Lexico, PGofer.Sintatico.Controls,
   PGofer.Key.Controls;

{ TPGItemTrigger }

constructor TPGItemTrigger.Create(ItemDad: TPGItem; Name: String;
  ItemMirror: TPGItemMirror);
begin
    inherited Create(ItemDad, Name);
    FItemMirror := ItemMirror;
end;

destructor TPGItemTrigger.Destroy();
begin
    if Assigned(FItemMirror) then
    begin
        FItemMirror.FItemOriginal := nil;
        FItemMirror.Free();
    end;
    inherited;
end;

procedure TPGItemTrigger.SetName(Name: String);
begin
    inherited;
    if Assigned(FItemMirror) then
        FItemMirror.Name := Name;
end;

procedure TPGItemTrigger.Execute(Gramatica: TGramatica);
begin
    if Assigned(Gramatica) then
    begin
        inherited Execute(Gramatica);
        if Gramatica.TokenList.Token.Classe <> cmdDot then
            Self.ExecutarNivel1();
    end
    else
    begin
        Self.ExecutarNivel1();
    end;
end;

{ TPGItemMirror }

constructor TPGItemMirror.Create(ItemDad: TPGItem;
  ItemOriginal: TPGItemTrigger);
begin
    inherited Create(ItemDad, ItemOriginal.Name);
    FItemOriginal := ItemOriginal;
end;

destructor TPGItemMirror.Destroy();
begin
    if Assigned(FItemOriginal) then
    begin
        FItemOriginal.FItemMirror := nil;
        FItemOriginal.Free;
    end;
    inherited;
end;

class function TPGItemMirror.TranscendName(AName: String;
                                           ItemList: TPGItem = nil): String;
var
    C: Word;
begin
    C := 0;
    AName := RemoveCharSpecial(AName, True);

    if AName <> '' then
    begin
       if not CharInSet(AName[LowString],['A'..'Z','a'..'z']) then
          AName := 'New'+AName;
    end else
       AName := 'New';


    Result := AName;
    if Assigned(ItemList)
    and (ItemList <> GlobalCollection) then
    begin
        while Assigned(ItemList.FindName(Result)) do
        begin
            inc(C);
            Result := AName + IntToStr(C);
        end;
    end else begin
        while Assigned(FindID(GlobalCollection, Result)) do
        begin
            Inc(C);
            Result := AName + IntToStr(C);
        end;
    end;
end;

end.
