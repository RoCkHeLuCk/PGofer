unit PGofer.Key.Controls;

interface

procedure KeyMacroPress(Texto: String; Delay: Cardinal);
procedure KeyPressAllUp();
procedure KeySetPress(Key: Word; Push: Boolean);
function CharToKey(Key: Char): SmallInt;
function KeyGetPress(Key: Word): Boolean;
function KeyVirtualToStr(KeyCode: Word): String;
function RemoveCharSpecial(Nome: String; Todos: Boolean): String;
function PassWordGenerator(Up, Number, CharEsp: Boolean; Size: Word): String;

implementation

uses
    Winapi.Windows, System.SysUtils, System.Character;

procedure KeyMacroPress(Texto: String; Delay: Cardinal);
const
    VKDOWN    = KEYEVENTF_EXTENDEDKEY or 0;
    VKUP      = KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP;
    CHARSHIFT = '~!@#$%^&*()_+{}|:<>?"';
    CHARSPACE = '`~^"' + #39;
    // ----------------------------------------------------------------------------//
    procedure PressKeys(Key: Char; Shift, Alt, Space: Boolean);
    var
        smallKeysScan: SmallInt;
        mpVirtuals: Cardinal;
    begin
        smallKeysScan := VkKeyScan(Key);
        mpVirtuals := MapVirtualKey(Cardinal(Key), 0);

        if Shift then
            keybd_event(VK_SHIFT, 1, VKDOWN, 0);

        if Alt then
            keybd_event(VK_MENU, 1, VKDOWN, 0);

        sleep(Delay);
        keybd_event(smallKeysScan, mpVirtuals, VKDOWN, 0);
        sleep(Delay);
        keybd_event(smallKeysScan, mpVirtuals, VKUP, 0);
        sleep(Delay);

        if Space then
        begin
            keybd_event(VK_SPACE, 1, VKDOWN, 0);
            keybd_event(VK_SPACE, 1, VKUP, 0);
        end;

        if Shift then
            keybd_event(VK_SHIFT, 1, VKUP, 0);

        if Alt then
            keybd_event(VK_MENU, 1, VKUP, 0);

    end;

var
    Key: Char;
    c, d: Cardinal;
    KeyState: TKeyboardState;
    Capslook: Boolean;
    Shift: Boolean;
    Alt: Boolean;
    Space: Boolean;
begin
    GetKeyboardState(KeyState);
    Capslook := KeyState[VK_CAPITAL] = 1;
    d := length(Texto);
    sleep(100);
    for c := 1 to d do
    begin
        Key := Texto[c];
        if Key <> #13 then
        begin
            Shift := ((Key.IsLower and Capslook) or
                (Key.IsUpper and not Capslook) or (pos(Key, CHARSHIFT) <> 0));
            Alt := False;
            Space := pos(Key, CHARSPACE) <> 0;
            PressKeys(Key, Shift, Alt, Space);
        end;
    end;

end;

procedure KeyPressAllUp();
var
    Key: Byte;
begin
    for Key := 0 to 255 do
    begin
        sleep(5);
        keybd_event(Key, $45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
    end;
end;

procedure KeySetPress(Key: Word; Push: Boolean);
begin
    // mouse
    Case Key of
        VK_LBUTTON:
            if Push then
                Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN,
                    0, 0, 0, 0)
            else
                Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP,
                    0, 0, 0, 0);

        VK_RBUTTON:
            if Push then
                Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN,
                    0, 0, 0, 0)
            else
                Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP,
                    0, 0, 0, 0);

        VK_MBUTTON:
            if Push then
                Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN,
                    0, 0, 0, 0)
            else
                Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP,
                    0, 0, 0, 0);
    else
        if Push then
            keybd_event(Key, OemKeyScan(Key), KEYEVENTF_EXTENDEDKEY, 0)
        else
            keybd_event(Key, OemKeyScan(Key), KEYEVENTF_EXTENDEDKEY or
                KEYEVENTF_KEYUP, 0);
    end; // case
end;

function CharToKey(Key: Char): SmallInt;
begin
    Result := VkKeyScan(Key);
end;

function KeyGetPress(Key: Word): Boolean;
begin
    Result := GetAsyncKeyState(Key) <> 0;
end;

function KeyVirtualToStr(KeyCode: Word): String;
begin
    case KeyCode of
        { Keyboard }
        $000:
            Result := 'KEYNULL';
        $001:
            Result := 'LBUTTON';
        $002:
            Result := 'RBUTTON';
        $003:
            Result := 'CANCEL';
        $004:
            Result := 'MBUTTON';
        $005:
            Result := 'BUTTON1';
        $006:
            Result := 'BUTTON2';
        $007:
            Result := 'BUTTON3';
        $008:
            Result := 'BACK';
        $009:
            Result := 'TAB';
        // $00A..$00B : Result:='UNDEF0A';
        $00C:
            Result := 'CLEAR';
        $00D:
            Result := 'RETURN';
        // $00E-00F : Result:='UNDEF0E';
        $010:
            Result := 'SHIFT';
        $011:
            Result := 'CONTROL';
        $012:
            Result := 'ALT';
        $013:
            Result := 'PAUSE';
        $014:
            Result := 'CAPITAL';
        $015:
            Result := 'KANA';
        // $016 : Result:='UNDEF16';
        $017:
            Result := 'JUNJA';
        $018:
            Result := 'FINAL';
        $019:
            Result := 'HANJA';
        // $01A : Result:='UNDEF1A';
        $01B:
            Result := 'ESCAPE';
        $01C:
            Result := 'CONVERT';
        $01D:
            Result := 'NONCONVERT';
        $01E:
            Result := 'ACCEPT';
        $01F:
            Result := 'MODECHANGE';
        $020:
            Result := 'SPACE';
        $021:
            Result := 'PAGEUP';
        $022:
            Result := 'PAGEDOWN';
        $023:
            Result := 'END';
        $024:
            Result := 'HOME';
        $025:
            Result := 'LEFT';
        $026:
            Result := 'UP';
        $027:
            Result := 'RIGHT';
        $028:
            Result := 'DOWN';
        $029:
            Result := 'SELECT';
        $02A:
            Result := 'PRINT';
        $02B:
            Result := 'EXECUTE';
        $02C:
            Result := 'PRTSCREEN';
        $02D:
            Result := 'INSERT';
        $02E:
            Result := 'DELETE';
        $02F:
            Result := 'HELP';
        // $030..$039,
        // $03A..$05A : Result:=Char( MapVirtualKeyEx(KeyCode, MAPVK_VK_TO_CHAR, GetKeyboardLayout(0)) );
        $05B:
            Result := 'LWIN';
        $05C:
            Result := 'RWIN';
        $05D:
            Result := 'APPS';
        // $05E : Result:='UNDEF5E';
        $05F:
            Result := 'SLEEP';
        $060 .. $069:
            Result := 'NUMPAD' + Char(KeyCode - $30);
        $06A:
            Result := 'NUMPAD_MULT';
        $06B:
            Result := 'NUMPAD_ADD';
        $06C:
            Result := 'NUMPAD_SEPAR';
        $06D:
            Result := 'NUMPAD_SUB';
        $06E:
            Result := 'NUMPAD_DEC';
        $06F:
            Result := 'NUMPAD_DIV';
        $070 .. $087:
            Result := 'F' + IntToStr(KeyCode - $6F);
        // $088..$08F : Result:='UNDEF88';
        $090:
            Result := 'NUMLOCK';
        $091:
            Result := 'SCROLL';
        $092:
            Result := 'JISHO';
        $093:
            Result := 'MASHU';
        $094:
            Result := 'TOUROKU';
        $095:
            Result := 'LOYA';
        $096:
            Result := 'ROYA';
        // $097..$09F : Result:='UNDEF97';
        $0A0:
            Result := 'LSHIFT';
        $0A1:
            Result := 'RSHIFT';
        $0A2:
            Result := 'LCONTROL';
        $0A3:
            Result := 'RCONTROL';
        $0A4:
            Result := 'LALT';
        $0A5:
            Result := 'RALT';
        $0A6:
            Result := 'BROWSER_BACK';
        $0A7:
            Result := 'BROWSER_FORWARD';
        $0A8:
            Result := 'BROWSER_REFRESH';
        $0A9:
            Result := 'BROWSER_STOP';
        $0AA:
            Result := 'BROWSER_SEARCH';
        $0AB:
            Result := 'BROWSER_FAVORITES';
        $0AC:
            Result := 'BROWSER_HOME';
        $0AD:
            Result := 'VOLUME_MUTE';
        $0AE:
            Result := 'VOLUME_DOWN';
        $0AF:
            Result := 'VOLUME_UP';
        $0B0:
            Result := 'MEDIA_NEXT_TRACK';
        $0B1:
            Result := 'MEDIA_PREV_TRACK';
        $0B2:
            Result := 'MEDIA_STOP';
        $0B3:
            Result := 'MEDIA_PLAY_PAUSE';
        $0B4:
            Result := 'LAUNCH_MAIL';
        $0B5:
            Result := 'LAUNCH_MEDIA_SELECT';
        $0B6:
            Result := 'LAUNCH_APP1';
        $0B7:
            Result := 'LAUNCH_APP2';
        // $0B8..$0B9 : Result:='UNDEFB8';
        // $0BA : Result:=Char( MapVirtualKeyEx(KeyCode, MAPVK_VK_TO_CHAR, GetKeyboardLayout(0)) );
        $0BB:
            Result := 'ADD';
        $0BC:
            Result := 'COMMA';
        $0BD:
            Result := 'MINUS';
        $0BE:
            Result := 'PERIOD';
        // $0BF..$0E4 : Result:=Char( MapVirtualKeyEx(KeyCode, MAPVK_VK_TO_CHAR, GetKeyboardLayout(0)) );
        $0E5:
            Result := 'PROCESSKEY';
        // $0E6 : Result:=Char( MapVirtualKeyEx(KeyCode, MAPVK_VK_TO_CHAR, GetKeyboardLayout(0)) );
        $0E7:
            Result := 'PACKET';
        // $0E8..$0F5 : Result:=Char( MapVirtualKeyEx(KeyCode, MAPVK_VK_TO_CHAR, GetKeyboardLayout(0)) );
        $0F6:
            Result := 'ATTN';
        $0F7:
            Result := 'CRSEL';
        $0F8:
            Result := 'EXSEL';
        $0F9:
            Result := 'EREOF';
        $0FA:
            Result := 'PLAY';
        $0FB:
            Result := 'ZOOM';
        $0FC:
            Result := 'NONAME';
        $0FD:
            Result := 'PA1';
        $0FE:
            Result := 'OEM_CLEAR';
        $0FF:
            Result := 'LAUNCH_APP3';

        $030 .. $039, $03A .. $05A, $0BA, $0BF .. $0E4, $0E6, $0E8 .. $0F5:
            Result := Char(MapVirtualKeyEx(KeyCode, MAPVK_VK_TO_CHAR,
                GetKeyboardLayout(0)));

        { Mouse }

        $200:
            Result := 'MOUSEMOVE';

        // $201 : Result:='LBUTTONDOWN';
        // $202 : Result:='LBUTTONUP';
        $201 .. $202:
            Result := 'LBUTTON';
        // $203 : Result:='LBUTTONDBLCLK';

        // $204 : Result:='RBUTTONDOWN';
        // $205 : Result:='RBUTTONUP';
        $204 .. $205:
            Result := 'RBUTTON';
        // $206 : Result:='RBUTTONDBLCLK';

        // $207 : Result:='MBUTTONDOWN';
        // $208 : Result:='MBUTTONUP';
        $207 .. $208:
            Result := 'MBUTTON';
        // $209 : Result:='MBUTTONDBLCLK';

        $209:
            Result := 'VWHEELDOWN';
        $20A:
            Result := 'VWHEELUP';

        // $20B : Result:='XBUTTONDOWN';
        // $20C : Result:='XBUTTONUP';
        $20B:
            Result := 'XBUTTON1';
        $20C:
            Result := 'XBUTTON2';
        // $20D : Result:='XBUTTONDBLCLK';

        $20D:
            Result := 'HWHEELRIGHT';
        $20E:
            Result := 'HWHEELLEFT';
    else
        Result := 'CODE_0h' + IntToHex(KeyCode, 2);
    end;
end;

function RemoveCharSpecial(Nome: String; Todos: Boolean): String;
const
    ComAcento = 'äéöûü¿¡¬√ƒ≈«»… ÀÃÕŒœ–—“”‘’÷Ÿ⁄€‹›‡·‚„‰ÂÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˘˙˚¸˝ˇ';
    SemAcento = 'SZszYAAAAAACEEEEIIIIDNOOOOOUUUUYaaaaaaceeeeiiiinooooouuuuyy';
    Simbolos  = ' "!"#$%&' + #39 +
        '()*+,-_./:;<=>?@[\]^`{|}{~ÄÅÇÉÑÖÜáàâãåçèêëíìîïñóòôõúù†°¢£§•¶ß®©™´¨≠ÆØ∞±≤≥¥µ∂∑∏π∫ªºΩæø∆Êﬁﬂ◊ÿ˜¯˛';

var
    c, d: Integer;
    Caracteres: String;
begin
    // todos os caracteres ou so acentos
    if Todos then
        Caracteres := ComAcento + Simbolos
    else
        Caracteres := ComAcento;

    // localizar substituir ou remover
    c := length(Nome);
    while c > 0 do
    begin
        d := pos(Nome[c], Caracteres);
        if d <> 0 then
        begin
            if d <= length(SemAcento) then
                Nome[c] := SemAcento[d]
            else
                Delete(Nome, c, 1);
        end;
        dec(c);
    end;

    Result := Nome;
end;

function PassWordGenerator(Up, Number, CharEsp: Boolean; Size: Word): String;
const
    Minusculo = [97 .. 122];
    Maiusculo = [65 .. 90];
    Numero    = [48 .. 57];
    Caracter  = [33 .. 47, 58 .. 54, 91 .. 96, 123 .. 126];
var
    c: Word;
    K: Byte;
begin
    Randomize;
    c := 1;
    Result := '';
    while c < Size do
    begin
        K := Byte(Random(255));
        if (pos(Char(K), Result) = 0) and
            ((K in Minusculo) or (Up and (K in Maiusculo)) or
            (Number and (K in Numero)) or (CharEsp and (K in Caracter))) then
        begin
            Result := Result + Char(K);
            Inc(c);
        end;
    end;
end;

end.
