object FrmNotePads: TFrmNotePads
  Left = 523
  Top = 132
  Caption = 'NotePads'
  ClientHeight = 299
  ClientWidth = 516
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MmmNotepad
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object EdtNotePad: TSynEdit
    Left = 0
    Top = 0
    Width = 516
    Height = 280
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 0
    OnClick = EdtNotePadChange
    OnKeyUp = EdtNotePadKeyUp
    Gutter.AutoSize = True
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.ShowLineNumbers = True
    Gutter.ZeroStart = True
    Options = [eoAutoIndent, eoDragDropEditing, eoDropFiles, eoEnhanceEndKey, eoGroupUndo, eoScrollPastEol, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabsToSpaces]
    WantReturns = False
    WantTabs = True
    OnChange = EdtNotePadChange
    OnDropFiles = EdtNotePadDropFiles
    FontSmoothing = fsmNone
  end
  object StbNotepad: TStatusBar
    Left = 0
    Top = 280
    Width = 516
    Height = 19
    Panels = <
      item
        Text = 'Linha[0]:Coluna[0]'
        Width = 150
      end
      item
        Text = 'Modificado: N'#227'o'
        Width = 100
      end
      item
        Text = 'Arquivo:'
        Width = 50
      end>
  end
  object MmmNotepad: TMainMenu
    Left = 304
    Top = 192
    object MniArquivo: TMenuItem
      Caption = 'Arquivo'
      object MniNovo: TMenuItem
        Caption = 'Novo'
        ShortCut = 16462
        OnClick = MniNovoClick
      end
      object MniSalvar: TMenuItem
        Caption = 'Salvar'
        ShortCut = 16467
        OnClick = MniSalvarClick
      end
      object MniSalvarComo: TMenuItem
        Caption = 'Salvar Como..'
        OnClick = MniSalvarComoClick
      end
      object MniAbrir: TMenuItem
        Caption = 'Abrir'
        ShortCut = 16463
        OnClick = MniAbrirClick
      end
      object MniN1: TMenuItem
        Caption = '-'
      end
      object MniSair: TMenuItem
        Caption = 'Sair'
        ShortCut = 32883
        OnClick = MniSairClick
      end
    end
    object MniEditar: TMenuItem
      Caption = 'Editar'
      object MniProcurar: TMenuItem
        Caption = 'Procurar e Substituir'
        ShortCut = 16454
        OnClick = MniProcurarClick
      end
      object MniSelecionar: TMenuItem
        Caption = 'Selecionar Tudo'
        ShortCut = 16449
        OnClick = MniSelecionarClick
      end
    end
    object MniCompilar: TMenuItem
      Caption = 'Compilar'
      object MniRun: TMenuItem
        Caption = 'Compilar'
        ShortCut = 120
        OnClick = MniRunClick
      end
    end
  end
  object OdgNotepad: TOpenDialog
    DefaultExt = 'pas'
    Filter = 
      'Pascal(*.pas)|*pas|Text(*.txt)|*.txt|Ini(*.ini)|*.ini|CFG(*.cfg)' +
      '|*.cfg|All File(*.*)|*.*'
    Left = 332
    Top = 192
  end
  object SdgNotePad: TSaveDialog
    DefaultExt = 'pas'
    Filter = 
      'Pascal(*.pas)|*.pas|Text(*.txt)|*.txt|CFG(*.cfg)|*.cfg|All File(' +
      '*.*)|*.*'
    Left = 360
    Top = 192
  end
  object RdgNotePad: TReplaceDialog
    OnFind = RdgNotePadFind
    OnReplace = RdgNotePadReplace
    Left = 388
    Top = 192
  end
end
