unit PGofer.Triggers.AutoFills;

interface

uses
  System.Classes,
  PGofer.Core, PGofer.Classes, PGofer.Sintatico, PGofer.Runtime,
  PGofer.Triggers;

type
  {$M+}
  [TPGArgs('Text, Mode, Speed, Delay')]
  TPGAutoFill = class( TPGItemTrigger )
  private
    FDelay : Cardinal;
    FSpeed : Cardinal;
    FMode : Byte;
    FText : String;
  protected
    class function GetFrameType: TPGTriggerFrameType; override;
  public
    constructor Create(AMirror: TPGItemMirror; AName: string); override;
    destructor Destroy( ); override;
    procedure Triggering( ); override;
    procedure ExecuteAction(AMode: Byte = 255; ASpeed: Cardinal = 0; ADelay: Cardinal = 0);
  published
    property Text: string read FText write FText;
    [TPGAbout('0:Write; 1:Send Point; 2:Copy; 3:Copy and Paste; 4:Script;')]
    property Mode: Byte read FMode write FMode;
    [TPGAbout('Value in milliseconds;')]
    property Speed: Cardinal read FSpeed write FSpeed;
    [TPGAbout('Value in milliseconds;')]
    property Delay: Cardinal read FDelay write FDelay;
  end;
  {$TYPEINFO ON}

  TPGAutoFillMirror = class( TPGItemMirror )
  protected
    class function GetTriggerType: TPGItemTriggerType; override;
  public
    class function OnDropFile( AItemDad: TPGItem; AFileName: String ): boolean; override;
  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils, System.StrUtils,
  PGofer.Lexico,
  PGofer.Sintatico.Controls,
  PGofer.Files.Controls,
  PGofer.Key.Post,
  PGofer.ClipBoards.Controls,
  PGofer.Process.Controls,
  PGofer.Triggers.AutoFills.Frame;

{ TPGAutoFill }

constructor TPGAutoFill.Create(AMirror: TPGItemMirror; AName: string);
begin
  inherited Create( AMirror, AName );
  FText := '';
  FSpeed := 10;
  FDelay := 500;
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

class function TPGAutoFill.GetFrameType: TPGTriggerFrameType;
begin
  Result := TPGAutoFillsFrame;
end;

procedure TPGAutoFill.Triggering( );
begin
  Self.ExecuteAction(FMode, FSpeed, FDelay);
end;

procedure TPGAutoFill.ExecuteAction(AMode: Byte; ASpeed, ADelay: Cardinal);
var
  KeyPost: TKeyPost;
begin
  // Fallbacks: Se o usuário não informou no script (ou passou valor padrão), usa o da instância
  if AMode > 4  then AMode := FMode;
  if ASpeed = 0 then ASpeed := FSpeed;
  if ADelay = 0 then ADelay := FDelay;

  Sleep(ADelay);

  case AMode of
     0:begin
        KeyPost := TKeyPost.Create( FText, ASpeed);
        KeyPost.WaitFor( );
        KeyPost.Free( );
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
       Sleep(ASpeed*2);
       keybd_event( VK_CONTROL, 0, KEYEVENTF_EXTENDEDKEY, 0 );
       Sleep(ASpeed);
       keybd_event( 86, 0, KEYEVENTF_EXTENDEDKEY, 0 ); //v
       Sleep(ASpeed);
       keybd_event( 86, 0, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0 ); //v
       Sleep(ASpeed);
       keybd_event( VK_CONTROL, 0, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0 );
     end;

     4:begin
       ScriptExec( 'AutoFill: ' + Self.Name, FText, nil );
     end;
  end;
end;

{ TPGAutoFillMirror }

class function TPGAutoFillMirror.GetTriggerType: TPGItemTriggerType;
begin
  Result := TPGAutoFill;
end;

class function TPGAutoFillMirror.OnDropFile(AItemDad: TPGItem; AFileName: String): boolean;
var
  LList: TStringList;
  LRow: string;
  LName, LValue: string;
  LAutoFill: TPGAutoFill;
  LFolder: TPGItem;
  LParts: TArray<string>;
begin
  Result := MatchText(ExtractFileExt(AFileName), ['.csv']);
  if not Result then Exit;

  LList := TStringList.Create;
  try
    LList.LoadFromFile(AFileName);
    LFolder := TPGFolder.Create(AItemDad, FileExtractOnlyFileName(AFileName));

    for LRow in LList do
    begin
      if LRow.Trim = '' then Continue;
      LParts := LRow.Split([',', ';']);

      if Length(LParts) >= 2 then
      begin
        LName := LParts[0].Trim;
        LValue := LParts[1].Trim;
        LAutoFill := TPGAutoFill(TPGAutoFillMirror.Create(LFolder, LName).ItemOriginal);
        LAutoFill.Text := LValue;
      end;
    end;
  finally
    LList.Free;
  end;
end;

initialization
  TPGItemDef.Create(TPGAutoFill, 'AutoFillDef');
  TriggersCollect.RegisterClass( TPGAutoFillMirror );

finalization

end.
