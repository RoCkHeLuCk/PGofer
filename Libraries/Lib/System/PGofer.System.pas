unit PGofer.System;

interface

uses
    PGofer.Sintatico.Classes;

type
{$M+}
    TPGSystem = class(TPGItemCMD)
    private
        class var FImageIndex: Integer;
        function GetCanClose(): Boolean;
        procedure SetCanClose(Value: Boolean);
        function GetDirCurrent(): String;
        function GetLoopLimite(): Int64;
        procedure SetLoopLimite(Value: Int64);
        function GetCanOff(): Boolean;
        procedure SetCanOff(Value: Boolean);
        function GetReplyFormat(): String;
        procedure SetReplyFormat(Value: String);
        function GetReplyPrefix(): Boolean;
        procedure SetReplyPrefix(Value: Boolean);
        function GetFileListMax(): Cardinal;
        procedure SetFileListMax(Value: Cardinal);
    protected
        class function GetImageIndex(): Integer; override;
    public
    published
        property CanClose: Boolean read GetCanClose write SetCanClose;
        property CanOff: Boolean read GetCanOff write SetCanOff;
        function DateTimeNow(Format: String): String;
        procedure Delay(Valor: Cardinal);
        function DialogMessage(Text: String): Boolean;
        property DirCurrent: String read GetDirCurrent;
        property FileListMax: Cardinal read GetFileListMax write SetFileListMax;
        function FindWindow(Valor: String): NativeUInt;
        function GetTextFromPoint(): String;
        function LockWorkStation(): Boolean;
        property LoopLimite: Int64 read GetLoopLimite write SetLoopLimite;
        function MonitorPower(OnOff: Boolean): NativeInt;
        function PrtScreen(Height, Width, Top, Left: Integer;
          FileName: String): Integer;
        function SendMessage(ClassName: String; Mss: Cardinal;
          wPar, lPar: Integer): Integer;
        function SetScreen(Height, Width, Monitor: Integer): Boolean;
        function SetSuspendState(Enabled: Boolean): Boolean;
        procedure ShowMessage(Texto: String);
        function ShutDown(Valor: Cardinal): Boolean;
        property ReplyFormat: String read GetReplyFormat write SetReplyFormat;
        property ReplyPrefix: Boolean read GetReplyPrefix write SetReplyPrefix;
    end;
{$TYPEINFO ON}

implementation

uses
    WinApi.Windows, System.SysUtils,
    Vcl.Forms,
    PGofer.Sintatico, PGofer.System.Controls,
    PGofer.ImageList;

{ TPGSystem }

function TPGSystem.DateTimeNow(Format: String): String;
begin
    Result := SystemGetDateTimeNow(Format);
end;

procedure TPGSystem.Delay(Valor: Cardinal);
begin
    Sleep(Valor);
end;

function TPGSystem.FindWindow(Valor: String): NativeUInt;
begin
    Result := SystemGetFindWindow(Valor);
end;

function TPGSystem.GetCanClose: Boolean;
begin
    Result := PGofer.Sintatico.CanClose;
end;

function TPGSystem.GetCanOff: Boolean;
begin
    Result := PGofer.Sintatico.CanOff;
end;

function TPGSystem.GetDirCurrent: String;
begin
    Result := PGofer.Sintatico.DirCurrent;
end;

function TPGSystem.GetFileListMax: Cardinal;
begin
    Result := PGofer.Sintatico.FileListMax;
end;

class function TPGSystem.GetImageIndex: Integer;
begin
    Result := FImageIndex;
end;

function TPGSystem.GetLoopLimite: Int64;
begin
    Result := PGofer.Sintatico.LoopLimite;
end;

function TPGSystem.GetReplyFormat: String;
begin
    Result := PGofer.Sintatico.ReplyFormat;
end;

function TPGSystem.GetReplyPrefix: Boolean;
begin
    Result := PGofer.Sintatico.ReplyPrefix;
end;

function TPGSystem.GetTextFromPoint: String;
begin
    Result := PGofer.System.Controls.SystemGetWindowsTextFromPoint();
end;

function TPGSystem.LockWorkStation: Boolean;
begin
    Result := WinApi.Windows.LockWorkStation();
end;

function TPGSystem.MonitorPower(OnOff: Boolean): NativeInt;
begin
    Result := PGofer.System.Controls.SystemMonitorPower(Enabled);
end;

function TPGSystem.PrtScreen(Height, Width, Top, Left: Integer;
  FileName: String): Integer;
begin
    Result := PGofer.System.Controls.SystemPrtScreen(Height, Width, Top, Left,
      FileName);
end;

function TPGSystem.SendMessage(ClassName: String; Mss: Cardinal;
  wPar, lPar: Integer): Integer;
begin
    Result := PGofer.System.Controls.SystemSetSendMessage(ClassName, Mss,
      wPar, lPar);
end;

procedure TPGSystem.SetCanClose(Value: Boolean);
begin
    PGofer.Sintatico.CanClose := Value;
end;

procedure TPGSystem.SetCanOff(Value: Boolean);
begin
    PGofer.Sintatico.CanOff := Value;
end;

procedure TPGSystem.SetFileListMax(Value: Cardinal);
begin
    PGofer.Sintatico.FileListMax := Value;
end;

procedure TPGSystem.SetLoopLimite(Value: Int64);
begin
    PGofer.Sintatico.LoopLimite := Value;
end;

procedure TPGSystem.SetReplyFormat(Value: String);
begin
    PGofer.Sintatico.ReplyFormat := Value;
end;

procedure TPGSystem.SetReplyPrefix(Value: Boolean);
begin
    PGofer.Sintatico.ReplyPrefix := Value;
end;

function TPGSystem.SetScreen(Height, Width, Monitor: Integer): Boolean;
begin
    Result := PGofer.System.Controls.SystemSetScreen(Height, Width, Monitor);
end;

function TPGSystem.SetSuspendState(Enabled: Boolean): Boolean;
begin
    Result := PGofer.System.Controls.SystemSetSuspendState(Enabled,
      True, False);
end;

function TPGSystem.DialogMessage(Text: String): Boolean;
begin
    Result := PGofer.System.Controls.SystemDialogMessage(Text);
end;

procedure TPGSystem.ShowMessage(Texto: String);
begin
    ShowMessage(Texto);
end;

function TPGSystem.ShutDown(Valor: Cardinal): Boolean;
begin
    Result := PGofer.System.Controls.SystemShutDown(Valor);
end;

initialization
    TPGSystem.Create(GlobalItemCommand);
    TPGSystem.FImageIndex := GlogalImageList.AddIcon('System');

finalization

end.
