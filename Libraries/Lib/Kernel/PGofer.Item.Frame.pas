unit PGofer.Item.Frame;

interface

uses
  System.Classes, System.IniFiles,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  PGofer.Classes, PGofer.Sintatico.Classes, PGofer.Component.Edit;

type
  TPGFrame = class( TFrame )
    grbAbout: TGroupBox;
    rceAbout: TRichEdit;
    pnlItem: TPanel;
    LblName: TLabel;
    EdtName: TEditEx;
    SplitterItem: TSplitter;
    procedure EdtNameKeyUp( Sender: TObject; var Key: Word;
       Shift: TShiftState );
  private
    FItem: TPGItem;
  protected
    FIniFile: TIniFile;
    procedure IniConfigSave( ); virtual;
    procedure IniConfigLoad( ); virtual;
  public
    constructor Create( Item: TPGItem; Parent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

{$R *.dfm}

uses
   PGofer.Sintatico;

constructor TPGFrame.Create( Item: TPGItem; Parent: TObject );
begin
  inherited Create( nil );
  Self.Parent := TWinControl( Parent );
  Self.Align := alClient;
  FItem := Item;
  EdtName.Text := FItem.Name;
  EdtName.ReadOnly := FItem.ReadOnly;
  EdtName.ParentColor := FItem.ReadOnly;
  FIniFile := TIniFile.Create( PGofer.Sintatico.IniConfigFile );
  Self.IniConfigLoad( );
end;

destructor TPGFrame.Destroy;
begin
  Self.IniConfigSave( );
  FIniFile.Free;
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGFrame.IniConfigLoad( );
begin
  Self.grbAbout.Height := FIniFile.ReadInteger( Self.ClassName, 'About',
     Self.grbAbout.Height );
end;

procedure TPGFrame.IniConfigSave( );
begin
  FIniFile.WriteInteger( Self.ClassName, 'About', Self.grbAbout.Height );
  FIniFile.UpdateFile;
end;

procedure TPGFrame.EdtNameKeyUp( Sender: TObject; var Key: Word;
   Shift: TShiftState );
begin
  FItem.Name := EdtName.Text;
end;

end.
