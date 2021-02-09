unit PGofer.ListView;

interface

uses
     Vcl.Controls, Vcl.ComCtrls, Vcl.Graphics, Vcl.Dialogs,
     System.Classes, System.SysUtils, System.UITypes;

type

   TListViewHelper = class helper for TListView
   private
   public
      procedure SetOnProcedHelpers();
      procedure OnColumnClickHelper(Sender: TObject; Column: TListColumn);
      procedure OnCompareHelper(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
      procedure OnDragDropHelper(Sender, Source: TObject; X, Y: Integer);
      procedure OnDragOverHelper(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
      procedure OnEndDragHelper(Sender, Target: TObject; X, Y: Integer);
      procedure OnDeletionHelper(Sender: TObject; Item: TListItem);
      procedure XMLSaveToFile<TDataClass:Class>(FileName:String; DocumentName:String);
      procedure XMLSaveToStream<TDataClass:Class>(Stream: TStream; DocumentName:String);
      procedure XMLLoadFromFile<TDataClass:Class, Constructor>(FileName:String; DocumentName:String);
      procedure XMLLoadFromStream<TDataClass:Class, Constructor>(Stream: TStream; DocumentName:String);
      function FindCaption(Palavra:String;OffSet:Integer;All:Boolean):Integer;
      //procedure ListViewIconeLoadFromFile(ListView:TListView; Item:TListItem; IconeIndex:Integer);
   end;

   function FindMaskString(Str, MaskStr: string): Boolean;

var
    ColIndex : Integer = 0;
    ColIndexU : Integer = 1;

implementation

uses PGofer.Files, xml.XMLIntf, Xml.XMLDoc, System.Rtti;

 { TListViewHelper }

procedure TListViewHelper.SetOnProcedHelpers();
begin
    OnColumnClick := OnColumnClickHelper;
    OnCompare := OnCompareHelper;
    OnDragDrop := OnDragDropHelper;
    OnDragOver := OnDragOverHelper;
    OnEndDrag := OnEndDragHelper;
    OnDeletion := OnDeletionHelper;
end;

procedure TListViewHelper.OnColumnClickHelper(Sender: TObject; Column: TListColumn);
begin
    if (ColIndex <> Column.Index) or (ColIndexU = -1) then
       ColIndexU:=1
    else
       ColIndexU:=-1;

    ColIndex:= Column.Index;
    TListView(Sender).AlphaSort;
end;

procedure TListViewHelper.OnCompareHelper(Sender: TObject; Item1, Item2: TListItem;
                              Data: Integer; var Compare: Integer);
begin
    if ColIndex = 0 Then
       Compare := CompareText(Item1.Caption, Item2.Caption) * ColIndexU
    else
       Compare := CompareText(Item1.SubItems[ColIndex-1], Item2.SubItems[ColIndex-1]) * ColIndexU;
end;

procedure TListViewHelper.OnDragDropHelper(Sender, Source: TObject; X, Y: Integer) ;
var
    c : Integer;
    SourceItem : Array of TListItem;
    TargetItem : TListItem;
    Aux : TListItem;
    Inserted : Boolean;
begin
    with TListView(Sender) do
    begin
        TargetItem := GetItemAt(X, Y);
        c := 0;
        for Aux in Items do
        begin
            if Aux.Selected then
            begin
                SetLength(SourceItem,c+1);
                SourceItem[c] := Aux;
                inc(c);
            end;
        end;
        Inserted := Assigned(TargetItem);
        for c := Low(SourceItem) to High(SourceItem) do
        begin
            if Inserted then
               Aux := Items.Insert(TargetItem.Index)
            else
               Aux := Items.Add;

            Aux.Assign( SourceItem[c] );
            Aux.Data := SourceItem[c].Data;
            SourceItem[c].Data := nil;
            SourceItem[c].Free;
        end;
    end;
end;

procedure TListViewHelper.OnDragOverHelper(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean) ;
begin
    Accept := (Sender = Source);
end;

procedure TListViewHelper.OnEndDragHelper(Sender, Target: TObject; X, Y: Integer);
begin
    TControl(Sender).Repaint;
end;

procedure TListViewHelper.OnDeletionHelper(Sender: TObject; Item: TListItem);
begin
    if Assigned(Item.Data) then
    begin
        TObject(Item.Data).Free;
        Item.Data := nil;
    end;
end;

procedure TListViewHelper.XMLSaveToFile<TDataClass>(FileName: String; DocumentName:String);
var
    Stream: TStream;
begin
    Stream := TFileStream.Create(FileName, fmCreate);
    try
        XMLSaveToStream<TDataClass>(Stream, DocumentName);
    finally
        Stream.Free;
    end;
end;

procedure TListViewHelper.XMLSaveToStream<TDataClass>(Stream: TStream; DocumentName:String);
var
    XMLDocument : IXMLDocument;
    XMLNode : IXMLNode;
    ListItem : TListItem;
    RttiContext : TRttiContext;
    RttiType : TRttiType;
    RttiProperty : TRttiProperty;
begin
    XMLDocument := TXMLDocument.Create(nil);
    XMLDocument.Active := True;
    XMLDocument.DocumentElement := XMLDocument.CreateNode(DocumentName, ntElement,'');
    XMLDocument.DocumentElement.Attributes['Version'] := '1.0';

    for ListItem in Items do
    begin
        XMLNode := XMLDocument.DocumentElement.AddChild( 'Item'+ListItem.Index.ToString );
        RttiContext := TRttiContext.Create();
        RttiType := RttiContext.GetType(TypeInfo(TDataClass));
        for RttiProperty in RttiType.GetProperties do
            XMLNode.Attributes[ RttiProperty.Name ] := RttiProperty.GetValue(ListItem.Data).ToString;
    end;

    XMLDocument.SaveToStream(Stream);
    XMLDocument.Active := False;
end;


procedure TListViewHelper.XMLLoadFromFile<TDataClass>(FileName:String; DocumentName:String);
var
    Stream: TStream;
begin
    Stream := TFileStream.Create(FileName, fmOpenRead);
    try
        XMLLoadFromStream<TDataClass>(Stream, DocumentName);
    finally
        Stream.Free;
    end;
end;

procedure TListViewHelper.XMLLoadFromStream<TDataClass>(Stream: TStream; DocumentName:String);
var
    XMLDocument : IXMLDocument;
    XMLNode : IXMLNode;
    ListItem : TListItem;
    DataClass : TDataClass;
    RttiContext : TRttiContext;
    RttiType : TRttiType;
    RttiProperty : TRttiProperty;
begin
    Clear;
    XMLDocument := TXMLDocument.Create(nil);
    XMLDocument.LoadFromStream( Stream );
    XMLDocument.Active := True;

    XMLNode := XMLDocument.ChildNodes.FindNode(DocumentName);
    if Assigned(XMLNode) then
    begin
        XMLNode := XMLNode.ChildNodes.First;
        while XMLNode <> nil do
        begin
            DataClass := TDataClass.Create;
            ListItem := Items.Add();
            ListItem.Data := Pointer(DataClass);
            RttiContext := TRttiContext.Create();
            RttiType := RttiContext.GetType( TypeInfo(TDataClass) );
            for RttiProperty in RttiType.GetProperties do
            begin
                if XMLNode.HasAttribute( RttiProperty.Name ) then
                begin
                    try
                       case RttiProperty.PropertyType.TypeKind of
                           tkInteger     : RttiProperty.SetValue(ListItem.Data, Integer(XMLNode.Attributes[ RttiProperty.Name ]) );
                           tkEnumeration : RttiProperty.SetValue(ListItem.Data, Boolean(XMLNode.Attributes[ RttiProperty.Name ]) );
                           tkFloat       : RttiProperty.SetValue(ListItem.Data, Real(XMLNode.Attributes[ RttiProperty.Name ]) );
                           tkUString      : RttiProperty.SetValue(ListItem.Data, String(XMLNode.Attributes[ RttiProperty.Name ]) );
                       end;
                    except
                        raise Exception.Create('Erro: "'+ XMLNode.NodeName +'", Campo "'+RttiProperty.Name+'" contem valor invalido.');
                    end;
                end;
            end;
            OnInsert(Self,ListItem);
            XMLNode := XMLNode.NextSibling;
        end;
    end;
    XMLDocument.Active := False;
end;

function TListViewHelper.FindCaption(Palavra:String;OffSet:Integer;All:Boolean):Integer;
var
    SubIndex: Byte;
begin
    Result := -1;
    inc(OffSet);
    while (OffSet < Items.Count) and (Result = -1) do
    begin
        if FindMaskString(Items[OffSet].Caption,Palavra) then
           Result := OffSet;

        if All then
        begin
            SubIndex := 0;
            while (SubIndex < Items[OffSet].SubItems.Count ) and (Result = -1) do
            begin
                if FindMaskString(Items[OffSet].SubItems[SubIndex],Palavra) then
                   Result := OffSet;
                inc(SubIndex);
            end;
        end;
        inc(OffSet);
        if (OffSet >= Items.Count)
        and(MessageDlg('Nada foi encontrado,'+#13+'deseja reiniciar a procura?',
                        mtConfirmation, [mbOK, mbCancel],0,mbCancel) = mrOk ) then
            OffSet := 0;
    end;
end;

function FindMaskString(Str, MaskStr: string): Boolean;
var
    StrIndex, MaskIndex : Integer;
    StrLength, MaskLength : SmallInt;
begin
    Result := False;
    StrLength := Length(Str);
    MaskLength := Length(MaskStr);
    if (StrLength > 0) and (MaskLength > 0) then
    begin
        StrIndex := 1;
        MaskIndex := 1;

        while (StrIndex <= StrLength ) and (MaskIndex <= MaskLength) do
        begin
            case MaskStr[MaskIndex] of
               '?' : begin
                         Inc(StrIndex);
                         Inc(MaskIndex);
                     end;
               '*' : begin
                         Inc(MaskIndex);
                         if (MaskIndex > MaskLength) or (MaskStr[MaskIndex] <> '*') then
                         begin
                             while (StrIndex <= StrLength) and (Str[StrIndex] <> MaskStr[MaskIndex]) do
                                   Inc(StrIndex);
                         end;
                     end;
            else
                if SameText(Str[StrIndex],MaskStr[MaskIndex]) then
                begin
                   Inc(StrIndex);
                   Inc(MaskIndex);
                end else begin
                   MaskIndex := 1;
                   StrIndex := StrLength+1; //StrIndex + 1; para * no inicio
                end;
            end;
        end;

        if (MaskIndex >= MaskLength) then
           Result := True;

        if (StrIndex >= StrLength) and (MaskIndex <= MaskLength) then
           Result := False;
    end;
end;

{
procedure ListViewIconeLoadFromFile(ListView:TListView; Item:TListItem; IconeIndex:Integer);
var
    c, e : Word;
    d : Integer;
    Icone : TIcon;
    IconFileName : String;
    ItemA : TListItem;
    //ThreadLoadImage : TThreadLoadImage;
begin
    //ThreadLoadImage := TThreadLoadImage.Create(ListView,Item,IconeIndex);
    //ThreadLoadImage.Start;
    Try
        if IconeIndex < Item.SubItems.Count then
           IconFileName := Item.SubItems[IconeIndex];

        if IconFileName <> '' then
        begin
            ItemA := ListView.FindCaption(0, IconFileName , False, True, False);
            if ItemA <> nil then
               Item.ImageIndex := ItemA.ImageIndex
            else begin
                //verifica numero do icone
                d := 0;
                e := Length(IconFileName);
                c := pos(',',IconFileName);
                if c > 0 then
                begin
                    if not TryStrToInt( copy(IconFileName,c+1,e-c) ,d) then
                       d := 0;
                    IconFileName := copy(IconFileName,1,c-1);
                end;
                IconFileName := FileExpandPath(IconFileName);

                if (FileExists(IconFileName)) and (not FileIsReadOnly(IconFileName)) then
                begin
                    e := d;
                    Icone := TIcon.Create;
                    Icone.Handle:=ExtractAssociatedIcon(1, PWideChar(IconFileName), e );
                    if Icone.Handle <> 0 then
                       Item.ImageIndex := ListView.SmallImages.AddIcon(Icone);
                    Icone.Free;
                end;//if fileexist
            end;//if item <> ''
        end;//if iconFileName <> ''
    except
    end;
end;
 }


end.
