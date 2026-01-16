unit PGofer.System.Mouse;

interface

uses
  PGofer.Classes, PGofer.Runtime;

type
  {$M+}
  TPGMouse = class( TPGItemCMD )
  private
    function GetCursorPosX: Integer;
    function GetCursorPosY: Integer;
    procedure SetCursorPosX(Value: Integer);
    procedure SetCursorPosY(Value: Integer);
  public
  published
    property CursorPosX: Integer read GetCursorPosX write SetCursorPosX;
    property CursorPosY: Integer read GetCursorPosY write SetCursorPosY;
  end;
  {$TYPEINFO ON}

implementation

uses
  Vcl.Controls,
  System.Types;

{ TPGMouse }

function TPGMouse.GetCursorPosX: Integer;
begin
    Result := Mouse.CursorPos.X;
end;

function TPGMouse.GetCursorPosY: Integer;
begin
    Result := Mouse.CursorPos.Y;
end;

procedure TPGMouse.SetCursorPosX(Value: Integer);
begin
    Mouse.CursorPos := TPoint.Create(Value, Mouse.CursorPos.Y);
end;

procedure TPGMouse.SetCursorPosY(Value: Integer);
begin
    Mouse.CursorPos := TPoint.Create( Mouse.CursorPos.X, Value);
end;

end.
