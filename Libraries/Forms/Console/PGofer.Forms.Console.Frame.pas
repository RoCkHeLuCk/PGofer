unit PGofer.Forms.Console.Frame;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls,
  PGofer.Classes, PGofer.Forms.Frame, PGofer.Forms.Console,
  PGofer.Component.Edit, PGofer.Item.Frame,
  Pgofer.Component.Checkbox, Vcl.Dialogs, Vcl.ExtCtrls, Pgofer.Component.ComboBox,
  PGofer.Component.Memo;

type
  TPGConsoleFrame = class( TPGFormsFrame )
    lblDelay: TLabel;
    EdtDelay: TEditEx;
    updDelay: TUpDown;
    ckbShowMessage: TCheckBoxEx;
    ckbAutoClose: TCheckBoxEx;
    procedure ckbShowMessageClick( Sender: TObject );
    procedure ckbAutoCloseClick( Sender: TObject );
    procedure EdtDelayAfterValidate(Sender: TObject);
  private
  protected
    function GetItem( ): TPGFrmConsole; reintroduce;
    property Item: TPGFrmConsole read GetItem;
  public
    constructor Create( AItem: TPGItem; AParent: TObject ); reintroduce;
    destructor Destroy( ); override;
    procedure SyncData(); override;
  end;

implementation

uses
  System.SysUtils;

{$R *.dfm}
{ TPGFrameConsole }

constructor TPGConsoleFrame.Create( AItem: TPGItem; AParent: TObject );
begin
  inherited Create( AItem, AParent );
end;

destructor TPGConsoleFrame.Destroy;
begin
  inherited Destroy;
end;

procedure TPGConsoleFrame.EdtDelayAfterValidate(Sender: TObject);
begin
  if Self.Loading then Exit;
  Item.Delay := StrToIntDef( EdtDelay.Text, 0);
end;

function TPGConsoleFrame.GetItem: TPGFrmConsole;
begin
  Result := TPGFrmConsole(inherited Item);
end;

procedure TPGConsoleFrame.SyncData();
begin
  inherited SyncData();

  EdtDelay.SetTextSilent( Item.Delay.ToString );
  ckbShowMessage.SetCheckedSilent( Item.ShowMessage );
  ckbAutoClose.SetCheckedSilent( Item.AutoClose );
end;

procedure TPGConsoleFrame.ckbAutoCloseClick( Sender: TObject );
begin
  if Self.Loading then Exit;
  Item.AutoClose := ckbAutoClose.Checked;
end;

procedure TPGConsoleFrame.ckbShowMessageClick( Sender: TObject );
begin
  if Self.Loading then Exit;
  Item.ShowMessage := ckbShowMessage.Checked;
end;

end.
