unit PGofer.Forms.Console.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Dialogs,
  PGofer.Classes, PGofer.Forms.Frame, PGofer.Forms.Console,
  PGofer.Component.Edit, PGofer.Item.Frame;

type
  TPGConsoleFrame = class( TPGFormsFrame )
    lblDelay: TLabel;
    edtDelay: TEditEx;
    updDelay: TUpDown;
    ckbShowMessage: TCheckBox;
    ckbAutoClose: TCheckBox;
    procedure ckbShowMessageClick( Sender: TObject );
    procedure ckbAutoCloseClick( Sender: TObject );
    procedure edtDelayExit( Sender: TObject );
    procedure updDelayChanging( Sender: TObject; var AllowChange: Boolean );
  private
    FItem: TPGFrmConsole;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
  end;

implementation

uses
  System.SysUtils;

{$R *.dfm}
{ TPGFrameConsole }

procedure TPGConsoleFrame.ckbAutoCloseClick( Sender: TObject );
begin
  FItem.AutoClose := ckbAutoClose.Checked;
end;

procedure TPGConsoleFrame.ckbShowMessageClick( Sender: TObject );
begin
  FItem.ShowMessage := ckbShowMessage.Checked;
end;

constructor TPGConsoleFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGFrmConsole( AItem );
  edtDelay.Text := FItem.Delay.ToString;
  ckbShowMessage.Checked := FItem.ShowMessage;
  ckbAutoClose.Checked := FItem.AutoClose;
end;

destructor TPGConsoleFrame.Destroy;
begin
  FItem := nil;
  inherited Destroy;
end;

procedure TPGConsoleFrame.edtDelayExit( Sender: TObject );
begin
  FItem.Delay := StrToInt( edtDelay.Text );
end;

procedure TPGConsoleFrame.updDelayChanging( Sender: TObject;
  var AllowChange: Boolean );
begin
  edtDelayExit( Sender );
end;

end.
