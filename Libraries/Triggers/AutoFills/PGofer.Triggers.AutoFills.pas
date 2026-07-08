unit PGofer.Triggers.AutoFills;

interface

uses
  System.Classes,
  PGofer.Core, PGofer.Classes, PGofer.Runtime,
  PGofer.Triggers;

type
  {$M+}
  [TPGClassReg('Defines', 'AutoFillDef')]
  TPGAutoFill = class( TPGItemTrigger )
  private
    FDelay : Cardinal;
    FSpeed : Cardinal;
    FMode : Byte;
    FText : String;
    procedure SetText(const AValue: string);
  protected
    class function GetFrameType: TPGTriggerFrameType; override;
  public
    class function OnDropFile(const AItemDad: TPGItem; const AFileName: String ): boolean; override;
    constructor Create(const AItemDad: TPGItem; const AName: string = ''); override;
    destructor Destroy( ); override;
    procedure Triggering( ); override;
    procedure ExecuteAction(const AMode: Byte = 255; const ASpeed: Cardinal = 0; const ADelay: Cardinal = 0);
  published
    property Text: string read FText write SetText;
    [TPGAbout('0:Write; 1:Send Point; 2:Copy; 3:Copy and Paste; 4:Script;')]
    property Mode: Byte read FMode write FMode;
    [TPGAbout('Value in milliseconds;')]
    property Speed: Cardinal read FSpeed write FSpeed;
    [TPGAbout('Value in milliseconds;')]
    property Delay: Cardinal read FDelay write FDelay;
  end;
  {$TYPEINFO ON}

  procedure Initialize();
  procedure Finalize();

implementation

uses
  Winapi.Windows,
  System.SysUtils, System.StrUtils,
  PGofer.Files.Controls,
  PGofer.Key.Post,
  PGofer.ClipBoards.Controls,
  PGofer.Process.Controls,
  PGofer.Triggers.AutoFills.Frame;

procedure Initialize();
begin
end;

procedure Finalize();
begin
  {$IFDEF DEBUG}
  {$ENDIF}
end;

{ TPGAutoFill }

constructor TPGAutoFill.Create(const AItemDad: TPGItem; const AName: string);
begin
  inherited Create( AItemDad, AName );
  FText := '';
  FSpeed := 10;
  FDelay := 200;
  FMode := 0;
end;

destructor TPGAutoFill.Destroy( );
begin
  FText := '';
  FSpeed := 0;
  FDelay := 0;
  FMode := 0;
  inherited Destroy( );
end;

class function TPGAutoFill.GetFrameType(): TPGTriggerFrameType;
begin
  Result := TPGAutoFillsFrame;
end;

procedure TPGAutoFill.SetText(const AValue: string);
begin
  if FText = AValue then Exit;
  FText := AValue;
  Self.Invalid := FText.IsEmpty;
end;

procedure TPGAutoFill.Triggering( );
begin
  Self.ExecuteAction(FMode, FSpeed, FDelay);
end;

procedure TPGAutoFill.ExecuteAction(const AMode: Byte; const ASpeed, ADelay: Cardinal);
var
  LKeyPost: TKeyPost;
  LMode: Byte;
  LSpeed, LDelay: Cardinal;
begin

  if AMode > 4  then LMode := FMode else LMode := AMode;
  if ASpeed = 0 then LSpeed := FSpeed else LSpeed := ASpeed;
  if ADelay = 0 then LDelay := FDelay else LDelay := ADelay;
  Sleep(LDelay);

  case LMode of
     0:begin
        LKeyPost := TKeyPost.Create( FText, LSpeed);
        LKeyPost.WaitFor( );
        LKeyPost.Free( );
     end;

     1:begin
        SendMessage(
          ProcessGetFocusedControl(),
          $000C ,
          0,
          LPARAM(PChar(FText))
        );
     end;

     2:begin
       ClipBoardCopyFromText(FText);
     end;

     3:begin
       ClipBoardCopyFromText(FText);
       Sleep(LSpeed*2);
       keybd_event( VK_CONTROL, 0, KEYEVENTF_EXTENDEDKEY, 0 );
       Sleep(LSpeed);
       keybd_event( 86, 0, KEYEVENTF_EXTENDEDKEY, 0 ); //v
       Sleep(LSpeed);
       keybd_event( 86, 0, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0 ); //v
       Sleep(LSpeed);
       keybd_event( VK_CONTROL, 0, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0 );
     end;

     4:begin
       ScriptExec( 'AutoFill: ' + Self.Name, FText, nil );
     end;
  end;
end;

class function TPGAutoFill.OnDropFile(const AItemDad: TPGItem; const AFileName: string): Boolean;
var
  LList: TStringList;
  LRow, LUrl, LUser, LPass, LHost, LUserFolder: string;
  LParts: TArray<string>;
  LMainFolder, LHostFolder, LFinalFolder: TPGTriggerFolder;
  I: Integer;
begin
  Result := SameText(ExtractFileExt(AFileName), '.csv');
  if not Result then Exit;

  LList := TStringList.Create;
  try
    LList.LoadFromFile(AFileName);
    if LList.Count <= 1 then Exit;

    LMainFolder := TPGTriggerFolder.Create(AItemDad, FileExtractOnlyFileName(AFileName));

    for I := 0 to LList.Count - 1 do
    begin
      LRow := LList[I].Trim;
      if (LRow = '') or ((I = 0) and ContainsText(LRow, 'url')) then Continue;

      LParts := LRow.Split([',', ';', #9]);
      if Length(LParts) >= 3 then
      begin
        LUrl  := LParts[0].Trim(['"', ' ']);
        LUser := LParts[1].Trim(['"', ' ']);
        LPass := LParts[2].Trim(['"', ' ']);

        if LPass = '' then Continue;

        LHost := LUrl;
        if ContainsText(LHost, '://') then LHost := LHost.Split(['://'])[1];
        LHost := LHost.Split(['/', ':', '?'])[0];
        LHost := ReplaceStr(LHost, 'www.', '');

        LHostFolder := TPGTriggerFolder(LMainFolder.FindName(LHost));
        if LHostFolder = nil then
        begin
          LHostFolder := TPGTriggerFolder.Create(LMainFolder, LHost);
          LHostFolder.Namespace := True;
        end;

        LUserFolder := IfThen(LUser = '', 'default', LUser);
        LFinalFolder := TPGTriggerFolder(LHostFolder.FindName(LUserFolder));
        if LFinalFolder = nil then
        begin
          LFinalFolder := TPGTriggerFolder.Create(LHostFolder, LUserFolder);
          LFinalFolder.Namespace := True;
          with TPGAutoFill.Create(LFinalFolder, 'user') do Text := LUser;
          with TPGAutoFill.Create(LFinalFolder, 'pass') do Text := LPass;
        end;
      end;
    end;
  finally
    LList.Free;
  end;
end;

initialization

finalization

end.
