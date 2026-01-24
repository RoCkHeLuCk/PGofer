unit PGofer.Standard.Functions.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls,
  PGofer.Classes, PGofer.Item.Frame,
  PGofer.Standard.Functions,
  PGofer.Component.RichEdit, PGofer.Component.Edit, Vcl.ComCtrls;

type
  TPGFunctionFrame = class( TPGItemFrame )
    GrbScript: TGroupBox;
    EdtScript: TRichEditEx;
    sptScript: TSplitter;
    procedure EdtScriptKeyUp( Sender: TObject; var Key: Word;
      Shift: TShiftState );
  private
  protected
    procedure IniConfigSave( ); override;
    procedure IniConfigLoad( ); override;
    function GetItem( ): TPGFunction; virtual;
    property Item: TPGFunction read GetItem;
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
  EdtScript.Text := Item.Script;
  FrmAutoComplete.EditCtrlAdd( EdtScript );
end;

destructor TPGFunctionFrame.Destroy( );
begin
  FrmAutoComplete.EditCtrlRemove( EdtScript );
  if EdtScript.Modified then
    Item.CompileScript( );
  inherited Destroy( );
end;

function TPGFunctionFrame.GetItem: TPGFunction;
begin
  Result := TPGFunction(FItem);
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
  Item.Script := EdtScript.Text;
end;

end.
