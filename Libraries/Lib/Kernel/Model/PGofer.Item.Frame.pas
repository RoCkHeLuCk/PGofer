unit PGofer.Item.Frame;

interface

uses
  System.Classes, System.IniFiles,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls,
  PGofer.Component.Edit, PGofer.Component.IniFile, PGofer.Component.Memo,
  PGofer.Classes;

type
  TPGItemFrame = class( TFrame )
    grbAbout: TGroupBox;
    mmoAbout: TMemoEx;
    pnlItem: TPanel;
    LblName: TLabel;
    EdtName: TEditEx;
    sptAbout: TPanel;
    PnlStatus: TFlowPanel;
    Label1: TLabel;
    procedure sptAboutMouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure sptAboutMouseMove( Sender: TObject; Shift: TShiftState;
      X, Y: Integer );
    procedure sptAboutMouseUp( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure EdtNameAfterValidate(Sender: TObject);
    procedure EdtNameBeforeValidate(ASender: TObject; var AIsValid: Boolean);
  private
    FAboutSplitter: Boolean;
    FItem: TPGItem;
    FLoading: Boolean;
    function GetIniFile(): TMemIniFileEx;
  protected
    procedure IniConfigSave( ); virtual;
    procedure IniConfigLoad( ); virtual;
    function GetItem( ): TPGItem; virtual;
    property Item: TPGItem read GetItem;
    property Loading: Boolean read FLoading;
  public
    constructor Create(const AItem: TPGItem; const AParent: TObject ); reintroduce; virtual;
    destructor Destroy( ); override;
    procedure AfterConstruction(); override;
    procedure SyncData(); virtual;
    property IniFile: TMemIniFileEx read GetIniFile;
  end;

implementation

{$R *.dfm}

uses
  System.SysUtils, System.TypInfo, PGofer.Component.Form;

constructor TPGItemFrame.Create(const AItem: TPGItem; const AParent: TObject );
begin
  FLoading := True;
  inherited Create( nil );
  Self.Parent := TWinControl( AParent );
  Self.Width := TControl( AParent ).Width - 16;
  FAboutSplitter := False;
  Self.IniConfigLoad( );
  FItem := AItem;
end;

destructor TPGItemFrame.Destroy( );
begin
  Self.IniConfigSave( );
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGItemFrame.AfterConstruction();
begin
  inherited AfterConstruction();
  if Assigned(FItem) then
  begin
     EdtName.ReadOnly := FItem.Internal;
     mmoAbout.Lines.Text := FItem.About;
     Self.SyncData;
  end;
  FLoading := False;
end;

procedure TPGItemFrame.IniConfigLoad( );
begin
  Self.mmoAbout.Zoom := IniFile.ReadInteger( Self.ClassName, 'AboutZoom', Self.mmoAbout.Zoom );
  Self.Height := IniFile.ReadInteger( Self.ClassName, 'Height', Self.Height );
end;

procedure TPGItemFrame.IniConfigSave( );
begin
  IniFile.WriteInteger( Self.ClassName, 'AboutZoom', Self.mmoAbout.Zoom );
  IniFile.WriteInteger( Self.ClassName, 'Height', Self.Height );
  IniFile.UpdateFile();
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
  if Self.Loading then
    Exit;

  FItem.Name := EdtName.Text;
end;

procedure TPGItemFrame.EdtNameBeforeValidate(ASender: TObject; var AIsValid: Boolean);
var
  LCollision: TPGItem;
begin
  if Assigned(FItem.Parent) then
  begin
    LCollision := FItem.Parent.FindName(EdtName.Text);
    AIsValid := (LCollision = nil) or (LCollision = FItem);
  end;
end;

function TPGItemFrame.GetItem( ): TPGItem;
begin
   Result := FItem;
end;

function TPGItemFrame.GetIniFile: TMemIniFileEx;
begin
  Result := TFormEx.IniFile;
end;

procedure TPGItemFrame.SyncData();
var
  LFlag: TPGItemFlag;
  LMax: TPGItemFlag;
  LName: String;
begin
  Label1.Caption := '';
  LMax := Item.MaxOverlayIndex;
  for LFlag := Low(TPGItemFlag) to LMax do
  begin
    if (LFlag in FItem.Flags) then
    begin
      LName := GetEnumName(TypeInfo(TPGItemFlag), Ord(LFlag)).Substring(3);
      if Label1.Caption = '' then
         Label1.Caption := 'Flags: [ ' + LName
      else
         Label1.Caption := Label1.Caption + ', ' + LName;
    end;
  end;
  if Label1.Caption = '' then
     Label1.Caption := 'Flags: [ ';
  Label1.Caption := Label1.Caption + ' ]';

  EdtName.SetTextSilent( FItem.Name );
end;


end.
