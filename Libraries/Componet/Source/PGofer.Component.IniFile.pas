unit PGofer.Component.IniFile;

interface

uses
  System.SysUtils, System.IniFiles;

type
  TMemIniFileEx = class(TMemIniFile)
  private
    FIsDirty: Boolean;
    procedure SetDirty;
  public
    constructor Create(const FileName: string);
    procedure WriteString(const Section, Ident, Value: string); override;
    procedure WriteInteger(const Section, Ident: string; Value: Integer); override;
    procedure WriteBool(const Section, Ident: string; Value: Boolean); override;
    procedure UpdateFile; override;
    property IsDirty: Boolean read FIsDirty;
  end;

implementation

{ TMemIniFileEx }

constructor TMemIniFileEx.Create(const FileName: string);
begin
  inherited Create(FileName);
  FIsDirty := False;
end;

procedure TMemIniFileEx.SetDirty;
begin
  FIsDirty := True;
end;

procedure TMemIniFileEx.WriteBool(const Section, Ident: string; Value: Boolean);
begin
  if ReadBool(Section, Ident, not Value) <> Value then
  begin
    inherited WriteBool(Section, Ident, Value);
    SetDirty;
  end;
end;

procedure TMemIniFileEx.WriteInteger(const Section, Ident: string; Value: Integer);
begin
  if ReadInteger(Section, Ident, -1) <> Value then
  begin
    inherited WriteInteger(Section, Ident, Value);
    SetDirty;
  end;
end;

procedure TMemIniFileEx.WriteString(const Section, Ident, Value: string);
begin
  if ReadString(Section, Ident, '') <> Value then
  begin
    inherited WriteString(Section, Ident, Value);
    SetDirty;
  end;
end;

procedure TMemIniFileEx.UpdateFile;
begin
  if FIsDirty then
  begin
    inherited UpdateFile;
    FIsDirty := False;
  end;
end;

end.
