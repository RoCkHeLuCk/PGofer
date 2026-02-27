unit PGofer.Item.Frame;

interface

uses
  System.Classes, System.IniFiles,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  PGofer.Classes, PGofer.Runtime, PGofer.Component.Edit, PGofer.Component.IniFile;

type
  TPGItemFrame = class( TFrame )
    grbAbout: TGroupBox;
    rceAbout: TRichEdit;
    pnlItem: TPanel;
    LblName: TLabel;
    EdtName: TEditEx;
    sptAbout: TPanel;
    procedure sptAboutMouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure sptAboutMouseMove( Sender: TObject; Shift: TShiftState;
      X, Y: Integer );
    procedure sptAboutMouseUp( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure EdtNameAfterValidate(Sender: TObject);
  private
    FAboutSplitter: Boolean;
    class var FIniFile: TMemIniFileEx;
  protected
    FItem: TPGItem;
    class property IniFile: TMemIniFileEx read FiniFile;
    procedure IniConfigSave( ); virtual;
    procedure IniConfigLoad( ); virtual;
    function GetItem( ): TPGItem;
    property Item: TPGItem read GetItem;
  public
    class constructor Create();
    class destructor Destroy();
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

{$R *.dfm}

uses
  PGofer.Core;


class constructor TPGItemFrame.Create();
begin
  FIniFile := TMemIniFileEx.Create( TPGKernel.PathCurrent + 'Config.ini' );
end;

class destructor TPGItemFrame.Destroy();
begin
  FIniFile.Free;
  FIniFile := nil;
end;

constructor TPGItemFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( nil );
  FItem := AItem;
  Self.Parent := TWinControl( AParent );
  Self.Width := TControl( AParent ).Width - 16;
  FAboutSplitter := False;
  EdtName.Text := FItem.Name;
  EdtName.ReadOnly := FItem.ReadOnly;
  rceAbout.Lines.Text := FItem.About;
  Self.IniConfigLoad( );
end;

destructor TPGItemFrame.Destroy( );
begin
  Self.IniConfigSave( );
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGItemFrame.IniConfigLoad( );
begin
  Self.Height := FIniFile.ReadInteger( Self.ClassName, 'Height', Self.Height );
end;

procedure TPGItemFrame.IniConfigSave( );
begin
  FIniFile.WriteInteger( Self.ClassName, 'Height', Self.Height );
  FIniFile.UpdateFile();
end;

procedure TPGItemFrame.sptAboutMouseDown( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  FAboutSplitter := True;
end;

procedure TPGItemFrame.sptAboutMouseMove( Sender: TObject; Shift: TShiftState;
  X, Y: Integer );
begin
  if FAboutSplitter then
    Self.Height := ScreenToClient( Mouse.CursorPos ).Y;
end;

procedure TPGItemFrame.sptAboutMouseUp( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  if FAboutSplitter then
    Self.Height := ScreenToClient( Mouse.CursorPos ).Y;

  FAboutSplitter := False;
end;

procedure TPGItemFrame.EdtNameAfterValidate(Sender: TObject);
begin
  FItem.Name := EdtName.Text;
end;

function TPGItemFrame.GetItem( ): TPGItem;
begin
   Result := FItem;
end;

end.
