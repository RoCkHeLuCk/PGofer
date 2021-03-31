unit PGofer.Component.RichEdit;

interface

uses
  System.Classes, System.Types,
  WinApi.Windows, WinApi.Messages,
  Vcl.ComCtrls;

type
  TOnKeyDownUP = procedure( Sender: TObject; var Key: Word; Shift: TShiftState )
     of object;
  TOnKeyPress = procedure( Sender: TObject; var Key: Char ) of object;
  TOnExit = procedure( Sender: TObject ) of object;
  TOnDropFile = procedure( Sender: TObject; AFiles: TStrings ) of object;

  TRichEditEx = class( TRichEdit )
  private
    FOnDropFiles: TOnDropFile;
    FCharHeight : Integer;
    FCharWidth  : Integer;
    function GetCaretX( ): Integer;
    procedure SetCaretX( AValue: Integer );
    function GetCaretY( ): Integer;
    procedure SetCaretY( AValue: Integer );
    function GetDisplayX: Integer;
    procedure SetDisplayX( const Value: Integer );
    function GetDisplayY: Integer;
    procedure SetDisplayY( const Value: Integer );
    function GetDisplayXY: TPoint;
    procedure SetDisplayXY( const Value: TPoint );
    procedure DoDropFiles( var msg: TWMDropFiles ); message WM_DROPFILES;
    procedure SetOnDropFiles( AValue: TOnDropFile );
    function GetTextMetric( ): TTextMetric;
    function GetCharHeight: Integer;
    function GetCharWidth: Integer;
  protected
  public
    property CaretY    : Integer read GetCaretY write SetCaretY;
    property CaretX    : Integer read GetCaretX write SetCaretX;
    property CaretXY   : TPoint read GetCaretPos write SetCaretPos;
    property CharHeight: Integer read GetCharHeight;
    property CharWidth : Integer read GetCharWidth;
    property DisplayX  : Integer read GetDisplayX write SetDisplayX;
    property DisplayY  : Integer read GetDisplayY write SetDisplayY;
    property DisplayXY : TPoint read GetDisplayXY write SetDisplayXY;
  published
    property OnDropFiles: TOnDropFile read FOnDropFiles write SetOnDropFiles;
  end;

procedure Register;

implementation

uses
  WinApi.ShellApi;

procedure Register;
begin
  RegisterComponents( 'PGofer', [ TRichEditEx ] );
end;

{ TRichEditEx }

function TRichEditEx.GetCaretX( ): Integer;
begin
  Result := Self.GetCaretPos.X + 1;
end;

procedure TRichEditEx.SetCaretX( AValue: Integer );
begin
  Self.SetCaretPos( Point( AValue, -1 ) );
end;

function TRichEditEx.GetCaretY( ): Integer;
begin
  Result := Self.GetCaretPos.Y + 1;
end;

function TRichEditEx.GetCharHeight: Integer;
begin
  if FCharHeight = 0 then
    FCharHeight := GetTextMetric( ).tmHeight;
  Result := FCharHeight;
end;

function TRichEditEx.GetCharWidth: Integer;
begin
  if FCharWidth = 0 then
    FCharWidth := GetTextMetric( ).tmAveCharWidth;
  Result := FCharWidth;
end;

procedure TRichEditEx.SetCaretY( AValue: Integer );
begin
  Self.SetCaretPos( Point( -1, AValue ) );
end;

function TRichEditEx.GetDisplayX( ): Integer;
begin
  Result := GetDisplayXY.X;
end;

procedure TRichEditEx.SetDisplayX( const Value: Integer );
begin
  SetDisplayXY( Point( Value, GetDisplayY ) );
end;

function TRichEditEx.GetDisplayY: Integer;
begin
  Result := GetDisplayXY.Y;
end;

procedure TRichEditEx.SetDisplayY( const Value: Integer );
begin
  SetDisplayXY( Point( GetDisplayX, Value ) );
end;

function TRichEditEx.GetDisplayXY: TPoint;
begin
  Self.Perform( EM_POSFROMCHAR, WPARAM( @Result ), Self.SelStart );
end;

procedure TRichEditEx.SetDisplayXY( const Value: TPoint );
begin
  Self.Perform( EM_CHARFROMPOS, 0, Long( @Value ) );
  // MakeLong(Value.X, Value.Y)
end;

function TRichEditEx.GetTextMetric( ): TTextMetric;
var
  TextMetric: TTextMetric;
  aDC       : HDC;
  aFont     : HFONT;
begin
  aDC := GetDC( Self.Handle );
  aFont := SelectObject( aDC, Self.Font.Handle );
  GetTextMetrics( aDC, TextMetric );
  SelectObject( aDC, aFont );
  ReleaseDC( Self.Handle, aDC );
  Result := TextMetric;
end;

procedure TRichEditEx.SetOnDropFiles( AValue: TOnDropFile );
begin
  DragAcceptFiles( Self.Handle, Assigned( AValue ) );
  FOnDropFiles := AValue;
end;

procedure TRichEditEx.DoDropFiles( var msg: TWMDropFiles );
var
  C, FileCount: Integer;
  FileName    : array [ 0 .. MAX_PATH ] of Char;
  FileList    : TStrings;
begin
  if Assigned( FOnDropFiles ) then
  begin
    FileList := TStringList.Create;
    FileCount := DragQueryFile( msg.Drop, $FFFFFFFF, nil, MAX_PATH );
    for C := 0 to -1 + FileCount do
    begin
      DragQueryFile( msg.Drop, C, FileName, MAX_PATH );
      FileList.Add( FileName );
    end;
    DragFinish( msg.Drop );
    FOnDropFiles( Self, FileList );
    FileList.Free;
  end;
end;

end.
