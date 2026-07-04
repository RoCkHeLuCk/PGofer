unit PGofer.Forms;

interface

uses
  System.Classes,
  Vcl.Forms,
  PGofer.Component.Form,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime;

type

  {$M+}
  [TPGClassReg('Forms', 'FrmGlobals')]
  [TPGClassReg('Forms', 'FrmTriggers')]
  TPGForm = class( TPGItemClass )
  private
    FForm: TFormEx;
    function GetAlphaBlend( ): Boolean;
    procedure SetAlphaBlend(const AAlphaBlend: Boolean );
    function GetAlphaBlendValue( ): Byte;
    procedure SetAlphaBlendValue(const AAlphaBlendValue: Byte );
    function GetHeigth( ): Integer;
    procedure SetHeigth(const AHeigth: Integer );
    function GetLeft( ): Integer;
    procedure SetLeft(const ALeft: Integer );
    function GetTop( ): Integer;
    procedure SetTop(const ATop: Integer );
    function GetTransparent( ): Boolean;
    procedure SetTransparent(const ATransparent: Boolean );
    function GetTransparentColor( ): Integer;
    procedure SetTransparentColor(const ATransparentColor: Integer );
    function GetVisible( ): Boolean;
    procedure SetVisible(const AVisible: Boolean );
    function GetWidth( ): Integer;
    procedure SetWidth(const AWidth: Integer );
    function GetWindowState( ): Byte;
    procedure SetWindowState(const AWindowState: Byte );
  protected
    function GetForm(): TFormEx; virtual;
    property Form: TFormEx read GetForm;
  public
    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
    destructor Destroy( ); override;
    procedure Frame(const AParent: TObject ); override;
    procedure Execute(const AGrammar: TPGGrammar ); override;
  published
    property AlphaBlend: Boolean read GetAlphaBlend write SetAlphaBlend;
    property AlphaBlendValue: Byte read GetAlphaBlendValue write SetAlphaBlendValue;
    procedure Close(); virtual;
    property Heigth: Integer read GetHeigth write SetHeigth;
    procedure Hide();
    property Left: Integer read GetLeft write SetLeft;
    procedure Show(const AFocus: Boolean = true );
    property Top: Integer read GetTop write SetTop;
    property Transparent: Boolean read GetTransparent write SetTransparent;
    property TransparentColor: Integer read GetTransparentColor write SetTransparentColor;
    property Visible: Boolean read GetVisible write SetVisible;
    property Width: Integer read GetWidth write SetWidth;
    property WindowState: Byte read GetWindowState write SetWindowState;
  end;
  {$TYPEINFO ON}

implementation

uses
  System.SysUtils, PGofer.Lexico, PGofer.Forms.Frame;

{ TPGForm }

constructor TPGForm.Create(const AItemDad: TPGItem; const AName: string = '');
begin
  inherited Create(AItemDad, AName );
  FForm := nil;
end;

destructor TPGForm.Destroy( );
begin
  FForm := nil;
  inherited Destroy( );
end;

function TPGForm.GetAlphaBlend( ): Boolean;
begin
  Result := Self.Form.AlphaBlend;
end;

procedure TPGForm.SetAlphaBlend(const AAlphaBlend: Boolean );
begin
  Self.Form.AlphaBlend := AAlphaBlend;
end;

function TPGForm.GetAlphaBlendValue( ): Byte;
begin
  Result := Self.Form.AlphaBlendValue;
end;

function TPGForm.GetForm(): TFormEx;
var
  I: Integer;
  LName: String;
begin
  if not Assigned(FForm) then
  begin
    if Self.Name.StartsWith('Frm') then
      LName := Self.Name
    else
      LName := 'Frm' + Self.Name;

    for I := 0 to Screen.FormCount - 1 do
      if Screen.Forms[I].Name = Self.Name then
      begin
        FForm := TFormEx(Screen.Forms[I]);
        Break;
      end;
  end;
  Result := FForm;
end;

procedure TPGForm.SetAlphaBlendValue(const AAlphaBlendValue: Byte );
begin
  Self.Form.AlphaBlendValue := AAlphaBlendValue;
end;

procedure TPGForm.Close( );
begin
  Self.Form.Close;
end;

procedure TPGForm.SetHeigth(const AHeigth: Integer );
begin
  Self.Form.Height := AHeigth;
end;

function TPGForm.GetHeigth( ): Integer;
begin
  Result := Self.Form.Height;
end;

procedure TPGForm.SetLeft(const ALeft: Integer );
begin
  Self.Form.Left := ALeft;
end;

function TPGForm.GetLeft( ): Integer;
begin
  Result := Self.Form.Left;
end;

procedure TPGForm.Show(const AFocus: Boolean = true );
begin
  Self.Form.ForceShow( AFocus );
end;

procedure TPGForm.SetTop(const ATop: Integer );
begin
  Self.Form.Top := ATop;
end;

function TPGForm.GetTop( ): Integer;
begin
  Result := Self.Form.Top;
end;

procedure TPGForm.SetTransparent(const ATransparent: Boolean );
begin
  Self.Form.TransparentColor := ATransparent;
end;

function TPGForm.GetTransparent( ): Boolean;
begin
  Result := Self.Form.TransparentColor;
end;

procedure TPGForm.SetTransparentColor(const ATransparentColor: Integer );
begin
  Self.Form.TransparentColorValue := ATransparentColor;
end;

function TPGForm.GetTransparentColor( ): Integer;
begin
  Result := Self.Form.TransparentColorValue;
end;

procedure TPGForm.SetVisible(const AVisible: Boolean );
begin
  Self.Form.Visible := AVisible;
end;

function TPGForm.GetVisible( ): Boolean;
begin
  Result := Self.Form.Visible;
end;

procedure TPGForm.SetWidth(const AWidth: Integer );
begin
  Self.Form.Width := AWidth;
end;

function TPGForm.GetWidth( ): Integer;
begin
  Result := Self.Form.Width;
end;

procedure TPGForm.SetWindowState(const AWindowState: Byte );
begin
  Self.Form.WindowState := TWindowState( AWindowState );
end;

function TPGForm.GetWindowState( ): Byte;
begin
  Result := Byte( Self.Form.WindowState );
end;

procedure TPGForm.Hide( );
begin
  Self.Form.Hide;
end;

procedure TPGForm.Execute(const AGrammar: TPGGrammar );
begin
  if (not Assigned(Self.Form)) then
    Exit;

  AGrammar.TokenList.Next;
  RunInMainThread(
    procedure
    begin
      case AGrammar.TokenList.Current.Kind of
        pgkDot:
        begin
          Self.ExecuteMember(AGrammar);
        end;

        pgkSemiColon, pgkEOF:
        begin
          Self.Form.ForceShow(True);
        end
      else
        AGrammar.Error('Error_Interpreter_Unrecog',[AGrammar.TokenList.Current.Value.ToString]);
      end;
    end,
    True
  );
end;

procedure TPGForm.Frame(const AParent: TObject );
begin
  TPGFormsFrame.Create( Self, AParent );
end;

initialization

finalization

end.
