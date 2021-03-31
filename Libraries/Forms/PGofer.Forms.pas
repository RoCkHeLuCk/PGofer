unit PGofer.Forms;

interface

uses
  System.Classes, System.IniFiles,
  Vcl.Forms,
  PGofer.Classes, PGofer.Sintatico, PGofer.Sintatico.Classes;

type
{$M+}
  TPGForm = class( TPGItemCMD )
  private
    class var FImageIndex: Integer;
    function GetAlphaBlend( ): Boolean;
    procedure SetAlphaBlend( AlphaBlend: Boolean );
    function GetAlphaBlendValue( ): Byte;
    procedure SetAlphaBlendValue( AlphaBlendValue: Byte );
    function GetEnabled( ): Boolean;
    procedure SetFormEnabled( Value: Boolean );
    function GetHeigth( ): Integer;
    procedure SetHeigth( Heigth: Integer );
    function GetLeft( ): Integer;
    procedure SetLeft( Left: Integer );
    function GetTop( ): Integer;
    procedure SetTop( Top: Integer );
    function GetTransparent( ): Boolean;
    procedure SetTransparent( Transparent: Boolean );
    function GetTransparentColor( ): Integer;
    procedure SetTransparentColor( TransparentColor: Integer );
    function GetVisible( ): Boolean;
    procedure SetVisible( Visible: Boolean );
    function GetWidth( ): Integer;
    procedure SetWidth( Width: Integer );
    function GetWindowState( ): Byte;
    procedure SetWindowState( WindowState: Byte );
  protected
    FForm: TForm;
    class function GetImageIndex( ): Integer; override;
  public
    constructor Create( AForm: TForm ); reintroduce;
    destructor Destroy( ); override;
    procedure Frame( Parent: TObject ); override;
    procedure Execute( Gramatica: TGramatica ); override;
    class var GlobList: TPGItem;
  published
    property AlphaBlend     : Boolean read GetAlphaBlend write SetAlphaBlend;
    property AlphaBlendValue: Byte read GetAlphaBlendValue
       write SetAlphaBlendValue;
    procedure Close( );
    property Enabled: Boolean read GetEnabled write SetFormEnabled;
    property Heigth: Integer read GetHeigth write SetHeigth;
    procedure Hide( );
    property Left: Integer read GetLeft write SetLeft;
    property name;
    procedure Show( Focus: Boolean = true );
    property Top: Integer read GetTop write SetTop;
    property Transparent: Boolean read GetTransparent write SetTransparent;
    property TransparentColor: Integer read GetTransparentColor
       write SetTransparentColor;
    property Visible: Boolean read GetVisible write SetVisible;
    property Width: Integer read GetWidth write SetWidth;
    property WindowState: Byte read GetWindowState write SetWindowState;
  end;
{$TYPEINFO ON}

  TFormEx = class( TForm )
  private
  protected
    FIniFile: TIniFile;
    procedure IniConfigSave( ); virtual;
    procedure IniConfigLoad( ); virtual;
  public
    procedure FormCreate( Sender: TObject );
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
    procedure FormDestroy( Sender: TObject );
  end;

implementation

uses
  PGofer.Lexico, PGofer.Forms.Controls,
  PGofer.Forms.Frame,
  PGofer.ImageList;

{ TPGForm }

constructor TPGForm.Create( AForm: TForm );
begin
  inherited Create( TPGForm.GlobList, AForm.Name );
  FForm := AForm;
end;

destructor TPGForm.Destroy( );
begin
  FForm := nil;
  inherited;
end;

function TPGForm.GetAlphaBlend( ): Boolean;
begin
  Result := FForm.AlphaBlend;
end;

procedure TPGForm.SetAlphaBlend( AlphaBlend: Boolean );
begin
  FForm.AlphaBlend := AlphaBlend;
end;

function TPGForm.GetAlphaBlendValue( ): Byte;
begin
  Result := FForm.AlphaBlendValue;
end;

procedure TPGForm.SetAlphaBlendValue( AlphaBlendValue: Byte );
begin
  FForm.AlphaBlendValue := AlphaBlendValue;
end;

procedure TPGForm.Close( );
begin
  FForm.Close;
end;

function TPGForm.GetEnabled( ): Boolean;
begin
  Result := FForm.Enabled;
end;

procedure TPGForm.SetFormEnabled( Value: Boolean );
begin
  FForm.Enabled := Value;
end;

procedure TPGForm.SetHeigth( Heigth: Integer );
begin
  FForm.Height := Heigth;
end;

function TPGForm.GetHeigth( ): Integer;
begin
  Result := FForm.Height;
end;

class function TPGForm.GetImageIndex: Integer;
begin
  Result := FImageIndex;
end;

procedure TPGForm.SetLeft( Left: Integer );
begin
  FForm.Left := Left;
end;

function TPGForm.GetLeft( ): Integer;
begin
  Result := FForm.Left;
end;

procedure TPGForm.Show( Focus: Boolean = true );
begin
  FormForceShow( FForm, Focus );
end;

procedure TPGForm.SetTop( Top: Integer );
begin
  FForm.Top := Top;
end;

function TPGForm.GetTop( ): Integer;
begin
  Result := FForm.Top;
end;

procedure TPGForm.SetTransparent( Transparent: Boolean );
begin
  FForm.TransparentColor := Transparent;
end;

function TPGForm.GetTransparent( ): Boolean;
begin
  Result := FForm.TransparentColor;
end;

procedure TPGForm.SetTransparentColor( TransparentColor: Integer );
begin
  FForm.TransparentColorValue := TransparentColor;
end;

function TPGForm.GetTransparentColor( ): Integer;
begin
  Result := FForm.TransparentColorValue;
end;

procedure TPGForm.SetVisible( Visible: Boolean );
begin
  FForm.Visible := Visible;
end;

function TPGForm.GetVisible( ): Boolean;
begin
  Result := FForm.Visible;
end;

procedure TPGForm.SetWidth( Width: Integer );
begin
  FForm.Width := Width;
end;

function TPGForm.GetWidth( ): Integer;
begin
  Result := FForm.Width;
end;

procedure TPGForm.SetWindowState( WindowState: Byte );
begin
  FForm.WindowState := TWindowState( WindowState );
end;

function TPGForm.GetWindowState( ): Byte;
begin
  Result := Byte( FForm.WindowState );
end;

procedure TPGForm.Hide( );
begin
  FForm.Hide;
end;

procedure TPGForm.Execute( Gramatica: TGramatica );
begin
  TThread.Synchronize( Gramatica,
    procedure
    begin
      Gramatica.TokenList.GetNextToken;
      if Gramatica.TokenList.Token.Classe = cmdDot then
      begin
        Gramatica.TokenList.GetNextToken;
        Self.RttiExecute( Gramatica, Self );
      end
      else
        Self.Show( true );
      Application.ProcessMessages( );
    end );
end;

procedure TPGForm.Frame( Parent: TObject );
begin
  TPGFrameForms.Create( Self, Parent );
end;

{ TFormEx }

procedure TFormEx.FormCreate( Sender: TObject );
begin
  FIniFile := TIniFile.Create( PGofer.Sintatico.IniConfigFile );
  Self.IniConfigLoad( );
end;

procedure TFormEx.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  Self.IniConfigSave( );
end;

procedure TFormEx.FormDestroy( Sender: TObject );
begin
  Self.IniConfigSave( );
  FIniFile.Free;
end;

procedure TFormEx.IniConfigLoad( );
begin
  Self.Left := FIniFile.ReadInteger( Self.Name, 'Left', Self.Left );
  Self.Top := FIniFile.ReadInteger( Self.Name, 'Top', Self.Top );
  Self.ClientWidth := FIniFile.ReadInteger( Self.Name, 'Width',
     Self.ClientWidth );
  Self.ClientHeight := FIniFile.ReadInteger( Self.Name, 'Height',
     Self.ClientHeight );
  Self.MakeFullyVisible( Self.Monitor );
  if FIniFile.ReadBool( Self.Name, 'Maximized', False ) then
    Self.WindowState := wsMaximized;
end;

procedure TFormEx.IniConfigSave( );
begin
  Self.MakeFullyVisible( Self.Monitor );
  if Self.WindowState <> wsMaximized then
  begin
    FIniFile.WriteInteger( Self.Name, 'Left', Self.Left );
    FIniFile.WriteInteger( Self.Name, 'Top', Self.Top );
    FIniFile.WriteInteger( Self.Name, 'Width', Self.ClientWidth );
    FIniFile.WriteInteger( Self.Name, 'Height', Self.ClientHeight );
    FIniFile.WriteBool( Self.Name, 'Maximized', False );
  end
  else
    FIniFile.WriteBool( Self.Name, 'Maximized', true );
  FIniFile.UpdateFile;
end;

initialization

TPGForm.GlobList := TPGFolder.Create( GlobalCollection, 'Forms' );
TPGForm.FImageIndex := GlogalImageList.AddIcon( 'Form' );

finalization

end.
