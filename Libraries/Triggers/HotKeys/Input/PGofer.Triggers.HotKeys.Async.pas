unit PGofer.Triggers.HotKeys.Async;

interface

uses
  WinApi.Windows,
  System.Classes,



  PGofer.Triggers.HotKeys.Controls;

type
  TAsyncInput = class ( TThread )
  private
  protected
    procedure Execute( ); override;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
  end;

const
  ASYNC_KEYPRESS = -32768;

implementation

uses
  WinApi.Messages, PGofer.Triggers.HotKeys;

{ TAsyncInput }

constructor TAsyncInput.Create;
begin
  inherited Create( False );
end;

destructor TAsyncInput.Destroy;
begin
  inherited Destroy( );
end;

procedure TAsyncInput.Execute;
var
  c: Integer;
  Result: SmallInt;
  ParamInput: TParamInput;
begin
  while ( not Self.Terminated ) do
  begin
    for c := 1 to 255 do
    begin
      case c of
        VK_SHIFT, VK_CONTROL, VK_MENU:
          Continue;
      end;
      Result := GetAsyncKeyState( c );
      if ( Result = ASYNC_KEYPRESS ) then
      begin
        ParamInput.wParam := WM_KEYDOWN;
        ParamInput.dwVkData := c;
      end else begin
        ParamInput.wParam := WM_KEYUP;
        ParamInput.dwVkData := c;
      end;
      if Self.Terminated then
        Break;
      TPGHotKey.OnProcessKeys( ParamInput );
    end;
    Sleep( 10 );
  end;
end;

initialization

finalization

end.
