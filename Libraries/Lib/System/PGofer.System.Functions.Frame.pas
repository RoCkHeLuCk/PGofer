unit PGofer.System.Functions.Frame;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Controls,
  PGofer.Classes, PGofer.Item.Frame, PGofer.Component.Edit,
  PGofer.System.Functions, PGofer.Forms.AutoComplete,
  PGofer.Component.RichEdit;

type
  TPGFrameFunction = class( TPGFrame )
    gpbScript: TGroupBox;
    EdtScript: TRichEditEx;
    procedure EdtScriptExit( Sender: TObject );
  private
    FItem: TPGFunction;
    frmAutoComplete: TFrmAutoComplete;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

var
  PGFrameFunction: TPGFrameFunction;

implementation

{$R *.dfm}
{ TPGFrameFunction }

constructor TPGFrameFunction.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGFunction( AItem );
  EdtScript.Text := FItem.Script;
  frmAutoComplete := TFrmAutoComplete.Create( EdtScript );
end;

destructor TPGFrameFunction.Destroy;
begin
  FItem := nil;
  frmAutoComplete.Free;
  inherited Destroy( );
end;

procedure TPGFrameFunction.EdtScriptExit( Sender: TObject );
begin
  FItem.Script := EdtScript.Text;
end;

end.
