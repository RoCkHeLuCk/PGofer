unit PGofer.Triggers.HotKeys.Async;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils,
  PGofer.Triggers.HotKeys.Controls;

type
  TAsyncInput = class ( TThread )
  private
    FShootKeys: array[0..255] of Boolean;
    procedure ProcessAsyncKeyState();
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
  PGofer.Triggers.HotKeys;

{ TAsyncInput }

constructor TAsyncInput.Create();
begin
  inherited Create( False );
  Self.FreeOnTerminate := False;
  Self.Priority := tpIdle;
end;

destructor TAsyncInput.Destroy();
begin
  Self.Terminate();
  Self.WaitFor();
  inherited Destroy( );
end;

procedure TAsyncInput.Execute();
begin
  FillChar(FShootKeys, SizeOf(FShootKeys), 0);
  while not Self.Terminated do
  begin
    Self.ProcessAsyncKeyState();
    Sleep( 10 );
  end;
end;

procedure TAsyncInput.ProcessAsyncKeyState();
var
  LCount: Integer;
  LKeyValue: SmallInt;
  LKeyState: Boolean;
  LParamInput: TParamInput;
begin
  for LCount := 1 to 255 do
  begin
    if LCount in [VK_SHIFT, VK_CONTROL, VK_MENU] then continue;

    LKeyValue := GetAsyncKeyState( LCount );
    LKeyState := ((LKeyValue and ASYNC_KEYPRESS) <> 0);
    if (LKeyState) or (LKeyState <> FShootKeys[LCount]) then
    begin
      FShootKeys[LCount] := LKeyState;

      if LKeyState then
        LParamInput.wParam := WM_KEYDOWN
      else
        LParamInput.wParam := WM_KEYUP;
      LParamInput.dwVkData := LCount;
      LParamInput.dwScan := MapVirtualKey(LCount, 0);

      if not Self.Terminated then
        TPGHotKey.OnProcessKeys( LParamInput );
    end;
  end;
end;

initialization

finalization

end.
