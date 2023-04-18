unit PGofer.Key.Post;

interface

uses
  System.Classes, Winapi.Windows;

type
  TKeyPost = class( TThread )
  private
    FHandle: HWND;
    FDelay: Cardinal;
    FText: string;
    procedure Event( AKey: Word; APush: Boolean; AKeyEx: Boolean );
    procedure Post( AKey: Word; const AShift: TShiftState; AKeyEx: Boolean );
    procedure PostRaw( AKey: Char );
    procedure PostHWND( AHandle: HWND; AKey: Word; const AShift: TShiftState;
      AKeyEx: Boolean );
    procedure SendChar( AChar: Char );
    procedure SendText( AText: string );
  protected
    procedure Execute( ); override;
  public
    constructor Create( AText: string; ADelay: Cardinal;
      AHandle: HWND = 0 ); overload;
    destructor Destroy( ); override;
  end;

implementation

uses
  System.SysUtils,
  Winapi.Messages;

{ TKeyPost }

constructor TKeyPost.Create( AText: string; ADelay: Cardinal;
  AHandle: HWND = 0 );
begin
  inherited Create( False );
  Self.FreeOnTerminate := False;
  Self.Priority := tpIdle;
  Self.FDelay := ADelay;
  Self.FText := AText;
  Self.FHandle := AHandle;
end;

destructor TKeyPost.Destroy( );
begin
  FHandle := 0;
  FDelay := 0;
  FText := '';
  inherited;
end;

procedure TKeyPost.Execute;
begin
  inherited;
  SendText( FText );
end;

procedure TKeyPost.Event( AKey: Word; APush: Boolean; AKeyEx: Boolean );
var
  Flag: DWORD;
begin
  // mouse
  case AKey of
    VK_LBUTTON:
      if APush then
        Mouse_Event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0 )
      else
        Mouse_Event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0 );

    VK_RBUTTON:
      if APush then
        Mouse_Event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0 )
      else
        Mouse_Event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0 );

    VK_MBUTTON:
      if APush then
        Mouse_Event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN,
          0, 0, 0, 0 )
      else
        Mouse_Event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0 );
  else
    if AKeyEx then
      Flag := KEYEVENTF_EXTENDEDKEY
    else
      Flag := 0;

    if not APush then
      Flag := Flag or KEYEVENTF_KEYUP;

    keybd_event( AKey, MapVirtualKey( AKey, 0 ), Flag, 0 );
  end; // case
end;

procedure TKeyPost.Post( AKey: Word; const AShift: TShiftState;
  AKeyEx: Boolean );
type
  TShiftKeyInfo = record
    Shift: Byte;
    vKey: Byte;
  end;

  ByteSet = set of 0 .. 7;

const
  SHIFTKEYS: array [ 1 .. 3 ] of TShiftKeyInfo = ( ( Shift: Ord( ssCtrl );
    vKey: VK_CONTROL ), ( Shift: Ord( ssShift ); vKey: VK_SHIFT ),
    ( Shift: Ord( ssAlt ); vKey: VK_MENU ) );

var
  bShift: ByteSet absolute AShift;
  C: Integer;
begin
  for C := 1 to 3 do
  begin
    if SHIFTKEYS[ C ].Shift in bShift then
      Self.Event( SHIFTKEYS[ C ].vKey, True, False );
  end;

  Self.Event( AKey, True, AKeyEx );
  Sleep( FDelay );
  Self.Event( AKey, False, AKeyEx );

  for C := 3 downto 1 do
  begin
    if SHIFTKEYS[ C ].Shift in bShift then
      Self.Event( SHIFTKEYS[ C ].vKey, False, False );
  end;
end;

procedure TKeyPost.PostRaw( AKey: Char );
var
  C: Integer;
  numStr: string;
begin
  numStr := Format( '%4.4d', [ Ord( AKey ) ] );
  Self.Event( VK_MENU, True, False );
  for C := 1 to Length( numStr ) do
  begin
    if Self.FHandle > 0 then
      Self.PostHWND( FHandle, VK_NUMPAD0 + Ord( numStr[ C ] ) - Ord( '0' ),
        [ ], False )
    else
      Self.Post( VK_NUMPAD0 + Ord( numStr[ C ] ) - Ord( '0' ), [ ], False );
  end;
  Self.Event( VK_MENU, False, False );
end;

procedure TKeyPost.PostHWND( AHandle: HWND; AKey: Word;
  const AShift: TShiftState; AKeyEx: Boolean );
type
  TBuffers = array [ 0 .. 1 ] of TKeyboardState;
var
  pKeyBuffers: ^TBuffers;
  LPar: LPARAM;
begin
  if IsWindow( AHandle ) then
  begin
    // pKeyBuffers := nil;
    LPar := MakeLong( 0, MapVirtualKey( AKey, 0 ) );

    if AKeyEx then
      LPar := LPar or $1000000;

    New( pKeyBuffers );
    try
      GetKeyboardState( pKeyBuffers^[ 1 ] );
      FillChar( pKeyBuffers^[ 0 ], SizeOf( TKeyboardState ), 0 );
      if ssShift in AShift then
        pKeyBuffers^[ 0 ][ VK_SHIFT ] := $80;
      if ssAlt in AShift then
      begin
        pKeyBuffers^[ 0 ][ VK_MENU ] := $80;
        LPar := LPar or $20000000;
      end;
      if ssCtrl in AShift then
        pKeyBuffers^[ 0 ][ VK_CONTROL ] := $80;
      if ssLeft in AShift then
        pKeyBuffers^[ 0 ][ VK_LBUTTON ] := $80;
      if ssRight in AShift then
        pKeyBuffers^[ 0 ][ VK_RBUTTON ] := $80;
      if ssMiddle in AShift then
        pKeyBuffers^[ 0 ][ VK_MBUTTON ] := $80;

      SetKeyboardState( pKeyBuffers^[ 0 ] );

      if ssAlt in AShift then
      begin
        PostMessage( AHandle, WM_SYSKEYDOWN, AKey, LPar );
        PostMessage( AHandle, WM_SYSKEYUP, AKey, LPar or integer($C0000000));
      end else begin
        PostMessage( AHandle, WM_KEYDOWN, AKey, LPar );
        PostMessage( AHandle, WM_KEYUP, AKey, LPar or integer($C0000000) );
      end;

      SetKeyboardState( pKeyBuffers^[ 1 ] );
    finally
      if pKeyBuffers <> nil then
        Dispose( pKeyBuffers );
    end;
  end;
end;

procedure TKeyPost.SendChar( AChar: Char );
var
  Flags: TShiftState;
  VCode: Word;
  Ret: Word;
  C: Integer;
  Mask: Word;
begin
  Ret := VkKeyScan( AChar );
  if Ret = $FFFF then
  begin
    Self.PostRaw( AChar );
  end else begin
    VCode := Lobyte( Ret );
    Flags := [ ];
    Mask := $100;
    for C := 1 to 3 do
    begin
      if ( Ret and Mask ) <> 0 then
      begin
        case Mask of
          $100:
            Include( Flags, ssShift );
          $200:
            Include( Flags, ssCtrl );
          $400:
            Include( Flags, ssAlt );
        end;
      end;
      Mask := Mask shl 1;
    end;
    if Self.FHandle > 0 then
      Self.PostHWND( FHandle, VCode, Flags, False )
    else
      Self.Post( VCode, Flags, False );
  end;
end;

procedure TKeyPost.SendText( AText: string );
var
  C: Integer;
begin
  for C := 1 to Length( AText ) do
  begin
    Self.SendChar( AText[ C ] );
  end;
end;

end.
