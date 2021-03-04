unit PGofer.Component.Edit;

interface

uses
    System.Classes, System.RegularExpressions,
    Vcl.StdCtrls;

type
    TRegExample = (reNone, reAll, reWord, reUnsignedInt, reSignedInt,
        reUnsignedFloat, reSignedFloat, reLetter, reID);

    TEditEx = class(TEdit)
    private
        { Private declarations }
        FRegExample: TRegExample;
        FExpression: String;
        FRegExp: TRegEx;
        procedure SetRegExample(Value: TRegExample);
        procedure SetRegExp(Value: String);
    protected
        procedure KeyPress(var Key: Char); override;
    public
        { Public declarations }
    published
        { Published declarations }
        property RegExamples: TRegExample read FRegExample write SetRegExample
            default reAll;
        property RegExpression: string read FExpression write SetRegExp;
        property Text;
        property OnKeyPress;
    end;

procedure Register;

implementation

uses
   Winapi.Windows;

procedure Register;
begin
    RegisterComponents('PGofer', [TEditEx]);
end;

{ TPGEditNumeric }

procedure TEditEx.KeyPress(var Key: Char);
var
    NewText : String;
    SelStart, SelLength: Integer;
begin
    case Key of
        #8,
        #46:
        begin

        end;

        #13:
        begin
            if Assigned(Self.OnExit) then
                Self.OnExit(Self);
        end;
    else
        if FExpression = '' then
            FExpression := '/w';

        NewText := Self.Text;
        SelStart := Self.GetSelStart+1;
        SelLength := Self.GetSelLength;
        if SelLength > 0 then
           Delete(NewText,SelStart, SelLength);
        Insert(Key, NewText, SelStart);
        if not FRegExp.IsMatch(NewText) then
            Key := #0;
    end;
    inherited;
end;

procedure TEditEx.SetRegExample(Value: TRegExample);
begin
    FRegExample := Value;
    case Value of
        reAll:
            FExpression := '.';
        reWord:
            FExpression := '\w';
        reUnsignedInt:
            FExpression := '^\d*$';
        reSignedInt:
            FExpression := '^-?\d*$';
        reUnsignedFloat:
            FExpression := '^\d*\,?\d*$';
        reSignedFloat:
            FExpression := '^-?\d*\,?\d*$';
        reLetter:
            FExpression := '^[A-Za-z]*$';
        reId:
            FExpression := '^[A-Za-z_]+\w*$';
    end;
    FRegExp.Create(FExpression);
end;

procedure TEditEx.SetRegExp(Value: String);
begin
    FRegExp.Create(Value);
    FExpression := Value;
    FRegExample := reNone;
end;

end.
