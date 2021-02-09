unit UnitDetectar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, PGofer.HotKey;

type
  TFrmDetectar = class(TForm)
    LblAviso: TLabel;
    BtnClear: TButton;
    LblDetectar: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure LblDetectarMouseEnter(Sender: TObject);
  private
    { Private declarations }
    FKBHook : HHook;
    FMBHook : HHook;
    FHotKey : TPGHotKey;
    class function LowLevelProc(Code: Integer; wParam : WPARAM; lParam : LPARAM): NativeInt; stdcall; static;
  protected
  public
    { Public declarations }
     property HotKey : TPGHotKey write FHotKey;
  end;

var
  FrmDetectar: TFrmDetectar;

implementation

{$R *.dfm}

uses UnitHotKeys;

class function TFrmDetectar.LowLevelProc(Code: Integer; wParam : WPARAM; lParam : LPARAM): NativeInt;
var
    Key : TKey;
begin
    if Assigned(FrmDetectar.FHotKey) then
    begin
        if (Code = HC_ACTION) then
        begin
            Key := TPGHotkey.CalcVirtualKey(wParam,lParam);
            if Key.bDetect in [kd_Down, kd_Wheel] then
               FrmDetectar.FHotKey.InsertKey(Key.wKey);
        end;

        FrmDetectar.LblDetectar.Caption := FrmDetectar.FHotKey.GetHotKeyNames;
    end;
    Result := CallNextHookEx(0, Code, wParam, lParam);
end;

procedure TFrmDetectar.BtnClearClick(Sender: TObject);
begin
    if Assigned(FHotKey) then
    begin
        FHotKey.Clear;
        LblDetectar.Caption := FHotKey.GetHotKeyNames;
    end;
end;

procedure TFrmDetectar.FormCreate(Sender: TObject);
begin
    LblAviso.Caption := 'Mantenha o cursor do Mouse sobre está area'+#13#10
                        +'para detectar Botões e teclas.';
end;

procedure TFrmDetectar.FormDestroy(Sender: TObject);
begin
    //MouseLeave tambem chama isso
    if FKBHook > 0 then
       UnHookWindowsHookEx(FKBHook);
    if FMBHook > 0 then
       UnHookWindowsHookEx(FMBHook);
end;

procedure TFrmDetectar.LblDetectarMouseEnter(Sender: TObject);
begin
    FKBHook := SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelProc , HInstance, 0);
    FMBHook := SetWindowsHookEx(WH_MOUSE_LL, LowLevelProc, HInstance, 0);
end;

end.
