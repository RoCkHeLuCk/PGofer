object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'Analise Lexico'
  ClientHeight = 692
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
    Height = 331
    Align = alRight
    Beveled = True
    ExplicitLeft = 434
    ExplicitHeight = 294
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 331
    Width = 700
    Height = 5
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
    ExplicitTop = 312
    ExplicitWidth = 615
  end
  object SynEdit1: TSynEdit
    Left = 0
    Top = 0
    Width = 455
    Height = 331
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 0
    CodeFolding.GutterShapeSize = 11
    CodeFolding.CollapsedLineColor = clGrayText
    CodeFolding.FolderBarLinesColor = clGrayText
    CodeFolding.IndentGuidesColor = clGray
    CodeFolding.IndentGuides = True
    CodeFolding.ShowCollapsedLine = False
    CodeFolding.ShowHintMark = True
    UseCodeFolding = False
    Gutter.AutoSize = True
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.ShowLineNumbers = True
    Lines.Strings = (
      'write( -2^3 );')
    WantTabs = True
    FontSmoothing = fsmNone
  end
  object Panel1: TPanel
    Left = 460
    Top = 0
    Width = 240
    Height = 331
    Align = alRight
    Caption = 'Panel1'
    TabOrder = 1
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 238
      Height = 329
      Align = alClient
      TabOrder = 0
    end
  end
  object Memo2: TMemo
    Left = 0
    Top = 336
    Width = 700
    Height = 356
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object MainMenu1: TMainMenu
    Left = 340
    Top = 104
    object Arquivos1: TMenuItem
      Caption = 'Arquivos'
      object Salvar1: TMenuItem
        Caption = 'Salvar'
        ShortCut = 16467
        OnClick = Salvar1Click
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
