unit UnitPGofer;

interface

uses
  Vcl.Forms, Vcl.ImgList, Vcl.Controls, Vcl.Menus, Vcl.ExtCtrls, Vcl.Dialogs,
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.UiTypes, System.Classes,
  SynEdit, System.ImageList;

type
  TFrmPGofer = class(TForm)
    TryPGofer: TTrayIcon;
    EdtCommand: TSynEdit;
    PnlArrastar: TPanel;
    PnlComandMove: TPanel;
    PnlCommand: TPanel;
    PpmMenu: TPopupMenu;
    MniClose: TMenuItem;
    MiniN1: TMenuItem;
    MniPGofer: TMenuItem;
    ImlIcons: TImageList;
    procedure EdtCommandChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MniCloseClick(Sender: TObject);
    procedure PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
                                   Shift: TShiftState; X, Y: Integer);
    procedure TryPGoferClick(Sender: TObject);
    procedure EdtCommandKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    MouseA : TPoint;
    MemoriaComandos : Array of String;
    MemoriaPosicao : Word;
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure OnQueryEndSession (var Msg : TWMQueryEndSession); message WM_QueryEndSession;
  public
  end;

var
     FrmPGofer: TFrmPGofer;

implementation
{$R *.dfm}
uses
    PGofer.Classes, PGofer.Controls, PGofer.Sintatico,
    UnitConsole, UnitAutoComplete;

//----------------------------------------------------------------------------//
procedure TFrmPGofer.CreateWindowHandle(const Params: TCreateParams);
begin
    inherited;
    SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
end;
//---------------------------------------------------------------------------//
procedure TFrmPGofer.WndProc(var Message: TMessage);
begin
    OnMessage(Message);
    inherited WndProc(Message);
end;
//----------------------------------------------------------------------------//
procedure TFrmPGofer.OnQueryEndSession (var Msg : TWMQueryEndSession);
begin
    if (NoOff) then
       begin
           Msg.Result:= 0;
           if (MessageDlg('Algum programa está tentando desligar o computador'
                          +#13+'Deseja bloquear o desligamento?', mtConfirmation, [mbYes, mbNo], mrYes) = mrYes) then
               Msg.Result:= 0
           else
               Msg.Result:= 1;
       end else
           Msg.Result:= 1;
end;
//----------------------------------------------------------------------------//
procedure TFrmPGofer.FormCreate(Sender: TObject);
begin
    EdtCommand.OnDropFiles := PGSynEdit.OnDropFiles;
    EdtCommand.OnKeyUp := PGSynEdit.OnKeyUp;

    //seta a prioridade realtime
    SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);

    //Inicia Variaveis Globais
    SetLength(VarGlobal,0);
    SetLength(FuncGlobal,0);
    SetLength(AtalhoGlobal,0);

    //cria diretorios
    if not DirectoryExists(DirCurrent+'Lib\') then
       CreateDir(DirCurrent+'Lib\');

    if not DirectoryExists(DirCurrent+'AutoRun\') then
       CreateDir(DirCurrent+'AutoRun\');

end;
//----------------------------------------------------------------------------//
procedure TFrmPGofer.MniCloseClick(Sender: TObject);
begin
    CompilarComando( TMenuItem(Sender).Hint, nil );
end;
//----------------------------------------------------------------------------//
procedure TFrmPGofer.EdtCommandChange(Sender: TObject);
var c, d, e, f : Integer;
begin
    //verifica o tamanho horizontal das linhas
    e := 0;
    f := 0;
    for c := 0 to EdtCommand.Lines.Count do
    begin
        d := Length(EdtCommand.Lines[c]);
        if d > e then
        begin
            e := d;
            f := c;
        end;
    end;
    //ajusta o pgofer para o maior tamanho
    Width := EdtCommand.Canvas.TextWidth( EdtCommand.Lines[f]+'BBBBBB');
    Height := (EdtCommand.Lines.Count * EdtCommand.LineHeight) +16;
end;
//----------------------------------------------------------------------------//
procedure TFrmPGofer.EdtCommandKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
    Edit : TSynEdit;
    c : SmallInt;
begin
    Edit := TSynEdit(Sender);
    case Key of
         //ENTER
         VK_RETURN : begin
                         if not FrmAutoCompletes.Visible then
                         begin
                             //Executar Comando
                             if(Edit.Text <> '')and(Shift = []) then
                             begin
                                 //memorizar comando
                                 MemoriaPosicao := Length( MemoriaComandos )+1;
                                 if MemoriaPosicao > 100 then
                                    MemoriaPosicao := 0;
                                 SetLength(MemoriaComandos, MemoriaPosicao);
                                 MemoriaComandos[MemoriaPosicao-1] := Edit.Text;
                                 //executar
                                 CompilarComando(Edit.Text, nil);
                                 //limpar
                                 Edit.Clear();
                                 Key := 0;
                                 if ConsoleAutoClose then
                                    FrmPGofer.Hide;
                                 Edit.OnChange(nil);
                             end;//if <> ''
                         end;
                     end;

         VK_PRIOR,
         VK_NEXT   : begin
                          if not FrmAutoCompletes.Visible then
                          begin
                              //seleciona memoria de comando
                              if Key in [VK_PRIOR,VK_NEXT] then
                              begin
                                  c := Length( MemoriaComandos );
                                  if c > 0 then
                                  begin
                                      //anteriores
                                      if (Key = VK_PRIOR) then
                                      begin
                                          if MemoriaPosicao > 0 then
                                             Dec(MemoriaPosicao)
                                          else
                                             MemoriaPosicao := c-1;
                                      end;
                                      //posteriores
                                      if (Key = VK_NEXT ) then
                                      begin
                                          if MemoriaPosicao < c-1 then
                                             Inc(MemoriaPosicao)
                                          else
                                             MemoriaPosicao := 0;
                                      end;
                                      //escreve no edit
                                      Edit.Text := MemoriaComandos[MemoriaPosicao];
                                      Edit.OnChange(Sender);
                                      Key:=0;
                                  end;
                              end;
                          end;
                     end;
    end;//case

    PGSynEdit.OnKeyDown(Sender,Key,Shift);
end;
//----------------------------------------------------------------------------//
procedure TFrmPGofer.FormPaint(Sender: TObject);
begin
    Constraints.MaxWidth :=  Screen.Width - Left - 10;
    Constraints.MaxHeight := Screen.Height - Top - 10;
end;
//----------------------------------------------------------------------------//
procedure TFrmPGofer.PnlArrastarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    if Shift = [ssLeft] then
    begin
        MouseA.X := Mouse.CursorPos.X - Left;
        MouseA.Y := Mouse.CursorPos.Y - Top;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmPGofer.PnlArrastarMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
    if Shift = [ssLeft] then
    begin
        Left := Mouse.CursorPos.X - MouseA.X;
        Top := Mouse.CursorPos.Y - MouseA.Y;
    end;
end;
//----------------------------------------------------------------------------//
procedure TFrmPGofer.TryPGoferClick(Sender: TObject);
begin
    FormForceShow(FrmPGofer, True);
end;
//----------------------------------------------------------------------------//

end.
