unit PGofer.System.Functions.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Controls,
  PGofer.Classes, PGofer.Item.Frame, PGofer.Component.Edit,
  PGofer.System.Functions,
  PGofer.Component.RichEdit;

type
  TPGFunctionFrame = class( TPGItemFrame )
    GrbScript: TGroupBox;
    EdtScript: TRichEditEx;
    sptScript: TSplitter;
    procedure EdtScriptKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
  private
    FItem: TPGFunction;
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGFunctionFrame: TPGFunctionFrame;

implementation

uses
  PGofer.Forms.AutoComplete;

{$R *.dfm}
{ TPGFrameFunction }

constructor TPGFunctionFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGFunction( AItem );
  EdtScript.Text := FItem.Script;
  FrmAutoComplete.EditCtrlAdd( EdtScript );
end;

destructor TPGFunctionFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtScript );
  FItem.CompileScript( );
  FItem := nil;
  inherited Destroy( );
end;

procedure TPGFunctionFrame.IniConfigLoad;
begin
  inherited IniConfigLoad( );
  GrbScript.Height := FIniFile.ReadInteger( Self.ClassName, 'Scritp',
    GrbScript.Height );
end;

procedure TPGFunctionFrame.IniConfigSave;
begin
  FIniFile.WriteInteger( Self.ClassName, 'Scritp', GrbScript.Height );
  inherited IniConfigSave( );
end;

procedure TPGFunctionFrame.EdtScriptKeyUp( Sender: TObject; var Key: Word;
  Shift: TShiftState );
begin
  FItem.Script := EdtScript.Text;
end;

end.
