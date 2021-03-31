unit Pgofer.Component.ListView;

interface

uses
  System.Classes, System.SysUtils, Vcl.Controls, Vcl.ComCtrls,
  WinApi.Windows, WinApi.CommCtrl;

type
  TListViewEx = class( TListView )
  private
    { Private declarations }
    FOwnsObjectsData: Boolean;
    FColumnAlphaSort: Boolean;
    FSort           : Boolean;
  protected
    { Protected declarations }
    procedure ColClick( Column: TListColumn ); override;
    procedure DoEndDrag( Target: TObject; X, Y: Integer ); override;
    procedure Delete( Item: TListItem ); override;
    procedure MouseDown( Button: TMouseButton; Shift: TShiftState;
       X, Y: Integer ); override;
  public
    { Public declarations }
    procedure DragDrop( Source: TObject; X, Y: Integer ); override;
    procedure DeleteSelect( );
    function isSelectWork( ): Boolean;
    procedure FindText( Text: string; OffSet: Integer = -1 );
    procedure SuperSelected( Item: TListItem ); overload;
    procedure SuperSelected( ); overload;
  published
    { Published declarations }
    property OwnsObjectsData: Boolean read FOwnsObjectsData
       write FOwnsObjectsData default false;
    property ColumnAlphaSort: Boolean read FColumnAlphaSort
       write FColumnAlphaSort default false;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents( 'PGofer', [ TListViewEx ] );
end;

{ TListViewEx }

procedure TListViewEx.ColClick( Column: TListColumn );

  function AZSort( Item1, Item2: TListItem; lParam: Integer ): Integer; stdcall;
  begin
    if lParam < 0 then
      Result := lstrcmp( PChar( Item1.Caption ), PChar( Item2.Caption ) )
    else
      Result := lstrcmp( PChar( Item1.SubItems[ lParam ] ),
         PChar( Item2.SubItems[ lParam ] ) );
  end;

  function ZASort( Item1, Item2: TListItem; lParam: Integer ): Integer; stdcall;
  begin
    if lParam < 0 then
      Result := lstrcmp( PChar( Item1.Caption ), PChar( Item2.Caption ) ) * -1
    else
      Result := lstrcmp( PChar( Item1.SubItems[ lParam ] ),
         PChar( Item2.SubItems[ lParam ] ) ) * -1;
  end;

begin
  FSort := not FSort;
  if ( not Assigned( Self.OnCompare ) ) or ( FColumnAlphaSort ) then
  begin
    if FSort then
      ListView_SortItems( Self.Handle, @AZSort, Column.Index - 1 )
    else
      ListView_SortItems( Self.Handle, @ZASort, Column.Index - 1 );
  end
  else
    Self.AlphaSort;

  inherited;
end;

procedure TListViewEx.DoEndDrag( Target: TObject; X, Y: Integer );
begin
  Self.Repaint;
  inherited;
end;

procedure TListViewEx.Delete( Item: TListItem );
begin
  if ( FOwnsObjectsData ) and Assigned( Item ) and Assigned( Item.Data ) then
  begin
    TObject( Item.Data ).Free;
    Item.Data := nil;
  end;
  inherited;
end;

procedure TListViewEx.DragDrop( Source: TObject; X, Y: Integer );
var
  TargetItem: TListItem;
  SourceItem: array of TListItem;
  Aux       : TListItem;
  Count     : Integer;
  Inserted  : Boolean;
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
    SourceItem[ Count ].Free;
  end;

  inherited;
end;

procedure TListViewEx.MouseDown( Button: TMouseButton; Shift: TShiftState;
   X, Y: Integer );
begin
  if ( not Self.Dragging ) then
    Self.Selected := Self.GetItemAt( X, Y );
  inherited;
end;

procedure TListViewEx.SuperSelected( Item: TListItem );
begin
  Item.Selected := true;
  Item.MakeVisible( true );
  Item.Focused := true;
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

procedure TListViewEx.FindText( Text: string; OffSet: Integer = -1 );
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
  while ( Count < Items.Count ) do
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

end.
