unit PGofer.Component.RichEdit;

interface

uses
    System.Classes, System.Types, WinApi.Windows, WinApi.Messages,
    Vcl.ComCtrls;

type
    TOnKeyDownUP = procedure(Sender: TObject; var Key: Word; Shift: TShiftState)
      of object;
    TOnKeyPress = procedure(Sender: TObject; var Key: Char) of object;
    TOnExit = procedure(Sender: TObject) of object;
    TOnDropFile = procedure(Sender: TObject; AFiles: TStrings) of object;

    TRichEditEx = class(TRichEdit)
    private
        FOnDropFiles: TOnDropFile;
        function GetCaretX(): Integer;
        procedure SetCaretX(AValue: Integer);
        function GetCaretY(): Integer;
        procedure SetCaretY(AValue: Integer);
        procedure DoDropFiles(var msg: TWMDropFiles); message WM_DROPFILES;
        procedure SetOnDropFiles(AValue: TOnDropFile);
        function GetDisplayXY: TPoint;
    protected
    public
        property CaretY: Integer read GetCaretY write SetCaretY;
        property CaretX: Integer read GetCaretX write SetCaretX;
        property CaretXY: TPoint read GetCaretPos write SetCaretPos;
        property DisplayXY: TPoint read GetDisplayXY;
    published
        property OnDropFiles: TOnDropFile read FOnDropFiles write SetOnDropFiles;
    end;

procedure Register;

implementation

uses
    WinApi.ShellApi;

procedure Register;
begin
    RegisterComponents('PGofer', [TRichEditEx]);
end;

{ TRichEditEx }

function TRichEditEx.GetCaretX: Integer;
begin
    Result := Self.GetCaretPos.X + 1;
end;

function TRichEditEx.GetCaretY: Integer;
begin
    Result := Self.GetCaretPos.Y + 1;
end;

function TRichEditEx.GetDisplayXY: TPoint;
begin
   Self.Perform(EM_POSFROMCHAR, WPARAM(@Result), Self.SelStart);
end;

procedure TRichEditEx.SetCaretX(AValue: Integer);
begin
    Self.SetCaretPos(Point(AValue, -1));
end;

procedure TRichEditEx.SetCaretY(AValue: Integer);
begin
    Self.SetCaretPos(Point(-1, AValue));
end;

procedure TRichEditEx.SetOnDropFiles(AValue: TOnDropFile);
begin
    DragAcceptFiles(Self.Handle, Assigned(AValue));
    FOnDropFiles := AValue;
end;

procedure TRichEditEx.DoDropFiles(var msg: TWMDropFiles);
var
    C, FileCount: Integer;
    FileName: array [0 .. MAX_PATH] of Char;
    FileList: TStrings;
begin
    if Assigned(FOnDropFiles) then
    begin
        FileList := TStringList.Create;
        FileCount := DragQueryFile(msg.Drop, $FFFFFFFF, nil, MAX_PATH);
        for C := 0 to -1 + FileCount do
        begin
            DragQueryFile(msg.Drop, C, FileName, MAX_PATH);
            FileList.Add(FileName);
        end;
        DragFinish(msg.Drop);
        FOnDropFiles(Self, FileList);
        FileList.Free;
    end;
end;

end.
