unit PGofer.Triggers.HotKeys.Async;

interface

uses
  WinApi.Windows,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  PGofer.Triggers.HotKeys.MMHook,
  PGofer.Triggers.HotKeys.Controls;

type
  TAsyncInput = class( TThread )
  private
    FShootKeys: TList<Word>;
    FOnProcessKeys: TProcessKeys;
    procedure OnProcessKeys( AParamInput: TParamInput );
  protected
    procedure Execute( ); override;
  public
    constructor Create( ); overload;
    destructor Destroy( ); override;
    procedure SetProcessKeys( ProcessKeys: TProcessKeys = nil );
  end;

const
  ASYNC_KEYPRESS = -32768;

var
  AsyncInput: TAsyncInput;

implementation

uses
  WinApi.Messages, PGofer.Triggers.HotKeys;

{ TAsyncInput }

constructor TAsyncInput.Create;
begin
  Self.FShootKeys := TList<Word>.Create( );
  FOnProcessKeys := Self.OnProcessKeys;
  inherited Create( False );
end;

destructor TAsyncInput.Destroy;
begin
  FOnProcessKeys := nil;
  Self.FShootKeys.Free( );
  Self.FShootKeys := nil;
  inherited Destroy( );
end;

procedure TAsyncInput.Execute;
var
   c : Integer;
   Result : SmallInt;
   ParamInput: TParamInput;
begin
  while (not Self.Terminated) do
  begin
    for c := 1 to 255 do
    begin
      case c of
         VK_SHIFT, VK_CONTROL, VK_MENU: Continue;
      end;
      Result := GetAsyncKeyState( c );
      if (Result = ASYNC_KEYPRESS) then
      begin
          ParamInput.wParam := WM_KEYDOWN;
          ParamInput.dwVkData := c;
      end else begin
          ParamInput.wParam := WM_KEYUP;
          ParamInput.dwVkData := c;
      end;
      FOnProcessKeys(ParamInput);
    end;
    Sleep(10);
  end;
end;

procedure TAsyncInput.OnProcessKeys( AParamInput: TParamInput );
var
  Key: TKey;
  VHotKey: TPGHotKey;
begin
  Key := TKey.CalcVirtualKey( AParamInput );

  if Key.wKey > 0 then
  begin
    if Key.bDetect in [ kd_Down, kd_Wheel ] then
    begin
      if ( FShootKeys.Contains( Key.wKey ) ) then
        Key.bDetect := kd_Press
      else
        FShootKeys.Add( Key.wKey );
    end;

    VHotKey := TPGHotKey.LocateHotKeys( FShootKeys );

    if Assigned( VHotKey ) then
    begin
      if ( ( Key.bDetect = kd_Wheel ) or
        ( VHotKey.Detect = Byte( Key.bDetect ) ) ) then
      begin
        VHotKey.Triggering( );
      end;
    end;

    if Key.bDetect in [ kd_Up, kd_Wheel ] then
      FShootKeys.Remove( Key.wKey );
  end; // if key #0
end;

procedure TAsyncInput.SetProcessKeys( ProcessKeys: TProcessKeys );
begin
  if Assigned( ProcessKeys ) then
  begin
    FOnProcessKeys := ProcessKeys;
  end else begin
    FOnProcessKeys := Self.OnProcessKeys;
  end;
end;

initialization

if INPUT_TYPE = ASYNC then
  AsyncInput := TAsyncInput.Create( );

finalization

if INPUT_TYPE = ASYNC then
  AsyncInput.Free( );

end.
