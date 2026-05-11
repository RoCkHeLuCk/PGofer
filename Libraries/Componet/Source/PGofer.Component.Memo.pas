unit PGofer.Component.Memo;

interface

uses
  System.Classes, System.Types, System.SysUtils,
  WinApi.Windows, WinApi.Messages, WinApi.ShellApi,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms;

type
  TOnDropFile = procedure(Sender: TObject; AFiles: TStrings) of object;

  TMemoEx = class(TMemo)
  private
    FOnDropFiles: TOnDropFile;
    FCharHeight: Integer;
    FCharWidth: Integer;
    FBaseFontSize: Integer;
    FZoomValue: Integer;

    function GetCaretX: Integer;
    procedure SetCaretX(AValue: Integer);
    function GetCaretY: Integer;
    procedure SetCaretY(AValue: Integer);

    function GetDisplayX: Integer;
    procedure SetDisplayX(const Value: Integer);
    function GetDisplayY: Integer;
    procedure SetDisplayY(const Value: Integer);
    function GetDisplayXY: TPoint;
    procedure SetDisplayXY(const Value: TPoint);

    procedure DoDropFiles(var msg: TWMDropFiles); message WM_DROPFILES;
    procedure SetOnDropFiles(AValue: TOnDropFile);

    function GetTextMetric: TTextMetric;
    function GetCharHeight: Integer;
    function GetCharWidth: Integer;

    procedure SetVerticalScrollPos(const AValue: Integer);
    function GetVerticalScrollPos: Integer;
    function GetVerticalScrollMax: Integer;

    function GetZoomValue: Integer;
    procedure SetZoomValue(AValue: Integer);
  protected
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;

    property CaretY: Integer read GetCaretY write SetCaretY;
    property CaretX: Integer read GetCaretX write SetCaretX;
    property CaretXY: TPoint read GetCaretPos write SetCaretPos;

    property CharHeight: Integer read GetCharHeight;
    property CharWidth: Integer read GetCharWidth;

    property DisplayX: Integer read GetDisplayX write SetDisplayX;
    property DisplayY: Integer read GetDisplayY write SetDisplayY;
    property DisplayXY: TPoint read GetDisplayXY write SetDisplayXY;

    property VerticalScrollPos: Integer read GetVerticalScrollPos write SetVerticalScrollPos;
    property VerticalScrollMax: Integer read GetVerticalScrollMax;

    procedure SetTextSilent(const AValue: String);
  published
    property OnDropFiles: TOnDropFile read FOnDropFiles write SetOnDropFiles;
    property Zoom: Integer read GetZoomValue write SetZoomValue default 100;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('PGofer', [TMemoEx]);
end;

{ TMemoEx }

constructor TMemoEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FZoomValue := 100;
  FBaseFontSize := Font.Size;
end;

procedure TMemoEx.CreateWnd;
begin
  inherited;
  DragAcceptFiles(Handle, Assigned(FOnDropFiles));
end;

function TMemoEx.GetCaretX: Integer;
begin
  Result := SelStart - Perform(EM_LINEINDEX, WPARAM(-1), 0) + 1;
end;

procedure TMemoEx.SetCaretX(AValue: Integer);
var
  LineIdx: Integer;
begin
  LineIdx := Perform(EM_LINEINDEX, WPARAM(GetCaretY - 1), 0);
  SelStart := LineIdx + AValue - 1;
end;

function TMemoEx.GetCaretY: Integer;
begin
  Result := Perform(EM_LINEFROMCHAR, WPARAM(-1), 0) + 1;
end;

procedure TMemoEx.SetCaretY(AValue: Integer);
begin
  SelStart := Perform(EM_LINEINDEX, WPARAM(AValue - 1), 0);
  Perform(EM_SCROLLCARET, 0, 0);
end;

function TMemoEx.GetCharHeight: Integer;
begin
  FCharHeight := GetTextMetric.tmHeight;
  Result := FCharHeight;
end;

function TMemoEx.GetCharWidth: Integer;
begin
  FCharWidth := GetTextMetric.tmAveCharWidth;
  Result := FCharWidth;
end;

function TMemoEx.GetDisplayX: Integer;
begin
  Result := GetDisplayXY.X;
end;

procedure TMemoEx.SetDisplayX(const Value: Integer);
begin
  SetDisplayXY(Point(Value, GetDisplayY));
end;

function TMemoEx.GetDisplayY: Integer;
begin
  Result := GetDisplayXY.Y;
end;

procedure TMemoEx.SetDisplayY(const Value: Integer);
begin
  SetDisplayXY(Point(GetDisplayX, Value));
end;

function TMemoEx.GetDisplayXY: TPoint;
begin
  Winapi.Windows.GetCaretPos(Result);
end;

procedure TMemoEx.SetDisplayXY(const Value: TPoint);
begin
  SelStart := Perform(EM_CHARFROMPOS, 0, MakeLParam(Value.X, Value.Y));
end;

function TMemoEx.GetTextMetric: TTextMetric;
var
  DC: HDC;
  OldFont: HFONT;
begin
  DC := GetDC(Handle);
  try
    OldFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Result);
    SelectObject(DC, OldFont);
  finally
    ReleaseDC(Handle, DC);
  end;
end;

function TMemoEx.GetVerticalScrollPos: Integer;
var
  SI: TScrollInfo;
begin
  SI.cbSize := SizeOf(SI);
  SI.fMask := SIF_POS;
  GetScrollInfo(Handle, SB_VERT, SI);
  Result := SI.nPos;
end;

procedure TMemoEx.SetVerticalScrollPos(const AValue: Integer);
var
  SI: TScrollInfo;
begin
  SI.cbSize := SizeOf(SI);
  SI.fMask := SIF_POS;
  SI.nPos := AValue;
  SetScrollInfo(Handle, SB_VERT, SI, True);
  SendMessage(Handle, WM_VSCROLL, MakeWParam(SB_THUMBPOSITION, AValue), 0);
end;

function TMemoEx.GetVerticalScrollMax: Integer;
var
  SI: TScrollInfo;
begin
  SI.cbSize := SizeOf(SI);
  SI.fMask := SIF_RANGE or SIF_PAGE;
  GetScrollInfo(Handle, SB_VERT, SI);
  Result := SI.nMax - Integer(SI.nPage);
end;

procedure TMemoEx.WMMouseWheel(var Message: TWMMouseWheel);
begin
  if (GetKeyState(VK_CONTROL) < 0) then
  begin
    if Message.WheelDelta > 0 then
      SetZoomValue(FZoomValue + 10)
    else
      SetZoomValue(FZoomValue - 10);
    Message.Result := 1;
  end
  else
    inherited;
end;

function TMemoEx.GetZoomValue: Integer;
begin
  Result := FZoomValue;
end;

procedure TMemoEx.SetZoomValue(AValue: Integer);
var
  NewSize: Integer;
begin
  if AValue < 10 then AValue := 10;
  if AValue > 500 then AValue := 500;

  FZoomValue := AValue;

  if FBaseFontSize = 0 then FBaseFontSize := Abs(Font.Size);

  NewSize := Round((FBaseFontSize * FZoomValue) / 100);
  if NewSize < 1 then NewSize := 1;

  if Font.Size <> NewSize then
    Font.Size := NewSize;
end;

procedure TMemoEx.SetOnDropFiles(AValue: TOnDropFile);
begin
  FOnDropFiles := AValue;
  if HandleAllocated then
    DragAcceptFiles(Handle, Assigned(FOnDropFiles));
end;

procedure TMemoEx.DoDropFiles(var msg: TWMDropFiles);
var
  C, FileCount: Integer;
  FileName: array[0..MAX_PATH] of Char;
  FileList: TStrings;
begin
  if Assigned(FOnDropFiles) then
  begin
    FileList := TStringList.Create;
    try
      FileCount := DragQueryFile(msg.Drop, $FFFFFFFF, nil, MAX_PATH);
      for C := 0 to FileCount - 1 do
      begin
        DragQueryFile(msg.Drop, C, FileName, MAX_PATH);
        FileList.Add(FileName);
      end;
      FOnDropFiles(Self, FileList);
    finally
      FileList.Free;
      DragFinish(msg.Drop);
    end;
  end;
end;

procedure TMemoEx.SetTextSilent(const AValue: String);
var
  OldEvent: TNotifyEvent;
begin
  if Text = AValue then Exit;
  OldEvent := OnChange;
  try
    OnChange := nil;
    Text := AValue;
  finally
    OnChange := OldEvent;
  end;
end;

end.
