object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'Analise Lexico'
  ClientHeight = 277
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 455
    Top = 0
    Width = 5
    Height = 258
    Align = alRight
    Beveled = True
    ExplicitLeft = 434
    ExplicitHeight = 294
  end
  object Panel1: TPanel
    Left = 460
    Top = 0
    Width = 240
    Height = 258
    Align = alRight
    Caption = 'Panel1'
    TabOrder = 0
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 238
      Height = 256
      Align = alClient
      TabOrder = 0
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 258
    Width = 700
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 50
      end>
  end
  object EdtScript: TRichEditEx
    Left = 0
    Top = 0
    Width = 455
    Height = 258
    Align = alClient
    TabOrder = 2
    Zoom = 100
    OnSelectionChange = EdtScriptSelectionChange
    ExplicitLeft = 108
    ExplicitTop = 84
    ExplicitWidth = 185
    ExplicitHeight = 89
  end
  object MainMenu1: TMainMenu
    Left = 248
    Top = 16
    object Arquivos1: TMenuItem
      Caption = 'Arquivos'
      object Salvar1: TMenuItem
        Caption = 'Salvar'
        ShortCut = 16467
        OnClick = Salvar1Click
      end
    end
    object mniOpcoes: TMenuItem
      Caption = 'Op'#231#245'es'
      object SetCaret1: TMenuItem
        Caption = 'SetCaret'
        OnClick = SetCaret1Click
      end
    end
    object Compilar1: TMenuItem
      Caption = 'Compilar'
      object Lexico1: TMenuItem
        Caption = 'Lexico'
        ShortCut = 119
        OnClick = Lexico1Click
      end
      object Sintatico1: TMenuItem
        Caption = 'Sintatico'
        ShortCut = 120
        OnClick = Sintatico1Click
      end
    end
  end
end
