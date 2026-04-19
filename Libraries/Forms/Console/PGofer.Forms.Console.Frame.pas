unit PGofer.Forms.Console.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls,

  PGofer.Classes, PGofer.Forms.Frame, PGofer.Forms.Console,
  PGofer.Component.Edit, PGofer.Item.Frame, Vcl.Dialogs, Vcl.ExtCtrls, Pgofer.Component.ComboBox,
  Pgofer.Component.Checkbox;

type
  TPGConsoleFrame = class( TPGFormsFrame )
    lblDelay: TLabel;
    EdtDelay: TEditEx;
    updDelay: TUpDown;
    ckbShowMessage: TCheckBoxEx;
    ckbAutoClose: TCheckBoxEx;
    procedure ckbShowMessageClick( Sender: TObject );
    procedure ckbAutoCloseClick( Sender: TObject );
    procedure EdtDelayExit( Sender: TObject );
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

constructor TPGConsoleFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
  FItem := TPGFrmConsole( AItem );
  EdtDelay.SetTextSilent( FItem.Delay.ToString );
  ckbShowMessage.SetCheckedSilent( FItem.ShowMessage );
  ckbAutoClose.SetCheckedSilent( FItem.AutoClose );
end;

destructor TPGConsoleFrame.Destroy;
begin
  FItem := nil;
  inherited Destroy;
end;

procedure TPGConsoleFrame.ckbAutoCloseClick( Sender: TObject );
begin
  if Self.Loading then
    Exit;

  FItem.AutoClose := ckbAutoClose.Checked;
end;

procedure TPGConsoleFrame.ckbShowMessageClick( Sender: TObject );
begin
  if Self.Loading then
    Exit;

  FItem.ShowMessage := ckbShowMessage.Checked;
end;

procedure TPGConsoleFrame.EdtDelayExit( Sender: TObject );
begin
  if Self.Loading then
    Exit;

  FItem.Delay := StrToIntDef( EdtDelay.Text, 0);
end;

procedure TPGConsoleFrame.updDelayChanging( Sender: TObject;
  var AllowChange: Boolean );
begin
  if Self.Loading then
    Exit;

  EdtDelayExit( Sender );
end;

end.
