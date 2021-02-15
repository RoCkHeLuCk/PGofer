unit PGofer.Forms;

interface

uses
    Vcl.Forms, PGofer.Sintatico, PGofer.Sintatico.Classes;

type
{$M+}
    TPGForm = class(TPGItemCMD)
    private
        FForm: TForm;
        function GetAlphaBlend(): Boolean;
        procedure SetAlphaBlend(AlphaBlend: Boolean);
        function GetAlphaBlendValue(): Byte;
        procedure SetAlphaBlendValue(AlphaBlendValue: Byte);
        function GetEnabled(): Boolean;
        procedure SetEnabled(Enabled: Boolean);
        function GetHeigth(): Integer;
        procedure SetHeigth(Heigth: Integer);
        function GetLeft(): Integer;
        procedure SetLeft(Left: Integer);
        function GetTop(): Integer;
        procedure SetTop(Top: Integer);
        function GetTransparent(): Boolean;
        procedure SetTransparent(Transparent: Boolean);
        function GetTransparentColor(): Integer;
        procedure SetTransparentColor(TransparentColor: Integer);
        function GetVisible(): Boolean;
        procedure SetVisible(Visible: Boolean);
        function GetWidth(): Integer;
        procedure SetWidth(Width: Integer);
        function GetWindowState(): Byte;
        procedure SetWindowState(WindowState: Byte);
    public
        constructor Create(Form: TForm);
        destructor Destroy(); override;
        procedure Frame(Parent: TObject); override;
        procedure Execute(Gramatica: TGramatica); override;
        class procedure Carregar();
    published
        property AlphaBlend: Boolean read GetAlphaBlend write SetAlphaBlend;
        property AlphaBlendValue: Byte read GetAlphaBlendValue
            write SetAlphaBlendValue;
        procedure Close();
        property Enabled: Boolean read GetEnabled write SetEnabled;
        property Heigth: Integer read GetHeigth write SetHeigth;
        property Left: Integer read GetLeft write SetLeft;
        property Name;
        procedure Show(Focus: Boolean = true);
        property Top: Integer read GetTop write SetTop;
        property Transparent: Boolean read GetTransparent write SetTransparent;
        property TransparentColor: Integer read GetTransparentColor
            write SetTransparentColor;
        property Visible: Boolean read GetVisible write SetVisible;
        property Width: Integer read GetWidth write SetWidth;
        property WindowState: Byte read GetWindowState write SetWindowState;
    end;
{$TYPEINFO ON}

implementation

uses
    PGofer.Classes, PGofer.Lexico, PGofer.Types, PGofer.Forms.Controls,
    PGofer.Forms.Frame;

{ TPGForm }

constructor TPGForm.Create(Form: TForm);
begin
    inherited Create(Form.Name);
    FForm := Form;
end;

destructor TPGForm.Destroy();
begin
    FForm := nil;
    inherited Destroy();
end;

function TPGForm.GetAlphaBlend: Boolean;
begin
    Result := FForm.AlphaBlend;
end;

procedure TPGForm.SetAlphaBlend(AlphaBlend: Boolean);
begin
    FForm.AlphaBlend := AlphaBlend;
end;

function TPGForm.GetAlphaBlendValue: Byte;
begin
    Result := FForm.AlphaBlendValue;
end;

procedure TPGForm.SetAlphaBlendValue(AlphaBlendValue: Byte);
begin
    FForm.AlphaBlendValue := AlphaBlendValue;
end;

procedure TPGForm.Close();
begin
    FForm.Close;
end;

function TPGForm.GetEnabled(): Boolean;
begin
    Result := FForm.Enabled;
end;

procedure TPGForm.SetEnabled(Enabled: Boolean);
begin
    FForm.Enabled := Enabled;
end;

procedure TPGForm.SetHeigth(Heigth: Integer);
begin
    FForm.Height := Heigth;
end;

function TPGForm.GetHeigth: Integer;
begin
    Result := FForm.Height;
end;

procedure TPGForm.SetLeft(Left: Integer);
begin
    FForm.Left := Left;
end;

function TPGForm.GetLeft: Integer;
begin
    Result := FForm.Left;
end;

procedure TPGForm.Show(Focus: Boolean = true);
begin
    FormForceShow(FForm, Focus);
end;

procedure TPGForm.SetTop(Top: Integer);
begin
    FForm.Top := Top;
end;

function TPGForm.GetTop: Integer;
begin
    Result := FForm.Top;
end;

procedure TPGForm.SetTransparent(Transparent: Boolean);
begin
    FForm.TransparentColor := Transparent;
end;

function TPGForm.GetTransparent: Boolean;
begin
    Result := FForm.TransparentColor;
end;

procedure TPGForm.SetTransparentColor(TransparentColor: Integer);
begin
    FForm.TransparentColorValue := TransparentColor;
end;

function TPGForm.GetTransparentColor: Integer;
begin
    Result := FForm.TransparentColorValue;
end;

procedure TPGForm.SetVisible(Visible: Boolean);
begin
    FForm.Visible := Visible;
end;

function TPGForm.GetVisible: Boolean;
begin
    Result := FForm.Visible;
end;

procedure TPGForm.SetWidth(Width: Integer);
begin
    FForm.Width := Width;
end;

function TPGForm.GetWidth: Integer;
begin
    Result := FForm.Width;
end;

procedure TPGForm.SetWindowState(WindowState: Byte);
begin
    FForm.WindowState := TWindowState(WindowState);
end;

function TPGForm.GetWindowState: Byte;
begin
    Result := Byte(FForm.WindowState);
end;

procedure TPGForm.Execute(Gramatica: TGramatica);
begin
    inherited Execute(Gramatica);
    if Gramatica.TokenList.Token.Classe <> cmdDot then
       Self.Show(true);
    Application.ProcessMessages();
end;

procedure TPGForm.Frame(Parent: TObject);
begin
    inherited Frame(Parent);
    TPGFrameForms.Create(Self, Parent);
end;

class procedure TPGForm.Carregar();
var
    C: Integer;
    Forms: TPGItem;
begin
    Forms := TGramatica.Global.Add('Forms');
    for C := 0 to Application.ComponentCount - 1 do
    begin
        if Application.Components[C].ClassParent = TForm then
        begin
            Forms.Add(TPGForm.Create(TForm(Application.Components[C])));
        end;
    end;
end;

initialization

finalization

end.
