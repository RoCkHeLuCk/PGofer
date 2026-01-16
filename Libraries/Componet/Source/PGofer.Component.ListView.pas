unit PGofer.Component.ListView;

interface

uses
  System.Classes, System.SysUtils, System.IniFiles,
  Vcl.Controls, Vcl.ComCtrls,
  WinApi.Windows;

type
  TListViewEx = class( TListView )
  private
    FSort: Boolean;
    FOwnsObjectsData: Boolean;
    FColumnAlphaSort: Boolean;
  protected
    procedure ColClick( Column: TListColumn ); override;
    procedure DoEndDrag( Target: TObject; X, Y: Integer ); override;
    procedure Delete( Item: TListItem ); override;
    procedure MouseDown( Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer ); override;
  public
    procedure DragDrop( Source: TObject; X, Y: Integer ); override;
    procedure DeleteSelect( );
    function isSelectWork( ): Boolean;
    procedure FindText( Text: string; SubItem: Boolean = False;
      OffSet: Integer = -1 );
    procedure SuperSelected( Item: TListItem ); overload;
    procedure SuperSelected( ); overload;
    procedure IniConfigSave( AIniFile: TIniFile; ASection: string;
      APrefix: string );
    procedure IniConfigLoad( AIniFile: TIniFile; ASection: string;
      APrefix: string );
  published
    property OwnsObjectsData: Boolean read FOwnsObjectsData
      write FOwnsObjectsData default False;
    property ColumnAlphaSort: Boolean read FColumnAlphaSort
      write FColumnAlphaSort default False;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents( 'PGofer', [ TListViewEx ] );
end;

function AZSort( Item1, Item2: TListItem; lParam: Integer ): Integer; stdcall;
var
   s1, s2: string;
   f1, f2: Extended;
   d1, d2: TDateTime;
begin
  if Assigned( Item1 ) and Assigned( Item2 ) then
  begin
    if lParam < 0 then
    begin
        s1 := Item1.Caption;
        s2 := Item2.Caption;
    end else begin
        s1 := Item1.SubItems[ lParam ];
        s2 := Item2.SubItems[ lParam ];
    end;

    if (TryStrToFloat(s1,f1) and TryStrToFloat(s2,f2)) then
    begin
       if f1 > f2 then
         Result := 1
       else
         if f1 = f2 then
           Result := 0
         else
           Result := -1;
    end else begin
       if (TryStrToDateTime(s1,d1) and TryStrToDateTime(s2,d2)) then
       begin
          if d1 > d2 then
            Result := 1
          else
            if d1 = d2 then
              Result := 0
            else
              Result := -1;
       end else
         Result := lstrcmp( PChar( s1 ), PChar( s2 ) );
    end;
  end else
    Result := 0;
end;

function ZASort( Item1, Item2: TListItem; lParam: Integer ): Integer; stdcall;
begin
   Result := AZSort(Item1, Item2, lParam) * -1;
end;

{ TListViewEx }
procedure TListViewEx.ColClick( Column: TListColumn );
begin
  FSort := not FSort;

  if ( not Assigned( Self.OnCompare ) ) or ( FColumnAlphaSort ) then
  begin
    if FSort then
      Self.CustomSort( @AZSort, Column.Index-1 )
    else
      Self.CustomSort( @ZASort, Column.Index-1 );
  end
  else
    Self.AlphaSort();

  inherited ColClick( Column );
end;

procedure TListViewEx.DoEndDrag( Target: TObject; X, Y: Integer );
begin
  Self.Repaint;
  inherited DoEndDrag( Target, X, Y );
end;

procedure TListViewEx.Delete( Item: TListItem );
begin
  if ( FOwnsObjectsData ) and Assigned( Item ) and Assigned( Item.Data ) then
  begin
    TObject( Item.Data ).Free;
    Item.Data := nil;
  end;
  inherited Delete( Item );
end;

procedure TListViewEx.DragDrop( Source: TObject; X, Y: Integer );
var
  TargetItem: TListItem;
  SourceItem: array of TListItem;
  Aux: TListItem;
  Count: Integer;
  Inserted: Boolean;
begin
  SetLength( SourceItem, Self.SelCount );
  Count := 0;
  for Aux in Items do
  begin
    if Aux.Selected then
    begin
      SourceItem[ Count ] := Aux;
      inc( Count );
    end;
  end;

  TargetItem := Self.GetItemAt( X, Y );
  Inserted := Assigned( TargetItem );
  for Count := low( SourceItem ) to high( SourceItem ) do
  begin
    if Inserted then
      Aux := Items.Insert( TargetItem.Index )
    else
      Aux := Items.Add;

    Aux.Assign( SourceItem[ Count ] );
    Aux.Data := SourceItem[ Count ].Data;
    SourceItem[ Count ].Data := nil;
    SourceItem[ Count ].Free();
  end;

  inherited DragDrop( Source, X, Y );
end;

procedure TListViewEx.MouseDown( Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer );
begin
  if ( not Self.Dragging ) then
    Self.Selected := Self.GetItemAt( X, Y );
  inherited MouseDown( Button, Shift, X, Y );
end;

procedure TListViewEx.SuperSelected( Item: TListItem );
begin
  if Assigned( Item ) then
  begin
    Self.Scroll( Item.Position.X, Item.Position.Y );
    Item.Selected := true;
    Item.MakeVisible( true );
    Item.Focused := true;
  end;
end;

procedure TListViewEx.SuperSelected( );
begin
  Self.SuperSelected( Self.Selected );
end;

procedure TListViewEx.DeleteSelect( );
var
  Count: Integer;
begin
  for Count := Self.Items.Count - 1 downto 0 do
  begin
    if Self.Items[ Count ].Selected then
      Self.Items[ Count ].Delete;
  end;
end;

function TListViewEx.isSelectWork( ): Boolean;
begin
  Result := ( Assigned( Selected ) and Assigned( Selected.Data ) );
end;

procedure TListViewEx.FindText( Text: string; SubItem: Boolean = False;
  OffSet: Integer = -1 );
var
  Count: Integer;
begin
  if OffSet < 0 then
  begin
    if Assigned( Self.Selected ) then
      OffSet := Self.Selected.Index + 1
    else
      OffSet := 0;
  end;

  Self.ClearSelection;

  Count := OffSet;
  while ( Count < Self.Items.Count ) do
  begin
    if ( Pos( LowerCase( Text ), LowerCase( Items[ Count ].Caption ) ) > 0 ) or
      ( Pos( LowerCase( Text ), LowerCase( Items[ Count ].SubItems.Text ) ) > 0 )
    then
    begin
      SuperSelected( Items[ Count ] );
      Exit;
    end;
    inc( Count );
  end;

  Count := 0;
  while ( Count < OffSet ) do
  begin
    if ( Pos( LowerCase( Text ), LowerCase( Items[ Count ].Caption ) ) > 0 ) or
      ( Pos( LowerCase( Text ), LowerCase( Items[ Count ].SubItems.Text ) ) > 0 )
    then
    begin
      SuperSelected( Items[ Count ] );
      Exit;
    end;
    inc( Count );
  end;
end;

procedure TListViewEx.IniConfigLoad( AIniFile: TIniFile; ASection: string;
  APrefix: string );
var
  c: Integer;
begin
  for c := 0 to Self.Columns.Count - 1 do
  begin
    Self.Columns[ c ].Width := AIniFile.ReadInteger( ASection,
      APrefix + 'ColunWidth' + IntToStr( c ), Self.Columns[ c ].Width );
  end;
end;

procedure TListViewEx.IniConfigSave( AIniFile: TIniFile; ASection: string;
  APrefix: string );
var
  c: Integer;
begin
  for c := 0 to Self.Columns.Count - 1 do
  begin
    AIniFile.WriteInteger( ASection, APrefix + 'ColunWidth' + IntToStr( c ),
      Self.Columns[ c ].Width );
  end;
end;

end.
