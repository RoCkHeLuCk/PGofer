unit PGofer.Item.Frame;

interface

uses
  System.Classes, System.IniFiles, Vcl.Dialogs,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  PGofer.Classes, PGofer.Runtime, PGofer.Component.Edit;

type
  TPGItemFrame = class( TFrame )
    grbAbout: TGroupBox;
    rceAbout: TRichEdit;
    pnlItem: TPanel;
    LblName: TLabel;
    EdtName: TEditEx;
    sptAbout: TPanel;
    procedure EdtNameKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
    procedure sptAboutMouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure sptAboutMouseMove( Sender: TObject; Shift: TShiftState;
      X, Y: Integer );
    procedure sptAboutMouseUp( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
  private
    FItem: TPGItem;
    FAboutSplitter: Boolean;
  protected
    FIniFile: TIniFile;
    procedure IniConfigSave( ); virtual;
    procedure IniConfigLoad( ); virtual;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

{$R *.dfm}

uses
  PGofer.Types;

constructor TPGItemFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( nil );
  Self.Parent := TWinControl( AParent );
  Self.Width := TControl( AParent ).Width - 16;
  FItem := AItem;
  FAboutSplitter := False;
  EdtName.Text := FItem.Name;
  EdtName.ReadOnly := FItem.ReadOnly;
  EdtName.ParentColor := FItem.ReadOnly;

  rceAbout.Lines.Text := FItem.About;

  FIniFile := TIniFile.Create( PGofer.Types.IniConfigFile );
  Self.IniConfigLoad( );
end;

destructor TPGItemFrame.Destroy;
begin
  Self.IniConfigSave( );
  FIniFile.Free;
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

procedure TPGItemFrame.EdtNameKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Name := EdtName.Text;
end;

end.
