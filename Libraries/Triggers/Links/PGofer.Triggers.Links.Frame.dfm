inherited PGLinkFrame: TPGLinkFrame
  Height = 364
  Constraints.MinHeight = 200
  ExplicitHeight = 364
  inherited SplitterItem: TSplitter
    Top = 310
    ExplicitTop = 200
    ExplicitWidth = 416
  end
  inherited grbAbout: TGroupBox
    Top = 321
    ExplicitTop = 321
    inherited rceAbout: TRichEdit
      ExplicitHeight = 23
    end
  end
  inherited pnlItem: TPanel
    Height = 310
    Constraints.MinHeight = 310
    Constraints.MinWidth = 0
    ExplicitHeight = 310
    object LblArquivo: TLabel [0]
      Left = 5
      Top = 36
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Arquivo:'
    end
    object LblParametro: TLabel [1]
      Left = 5
      Top = 63
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Parametros:'
    end
    object LblDiretorio: TLabel [2]
      Left = 5
      Top = 90
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Diretorio:'
    end
    object LblEstado: TLabel [3]
      Left = 5
      Top = 117
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Estado:'
    end
    object LblPrioridade: TLabel [4]
      Left = 5
      Top = 144
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Prioridade:'
    end
    object LblOperation: TLabel [5]
      Left = 195
      Top = 117
      Width = 67
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Opera'#231#227'o:'
    end
    object EdtArquivo: TEdit [7]
      Left = 70
      Top = 33
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = EdtArquivoChange
    end
    object BtnArquivo: TButton [8]
      Left = 366
      Top = 33
      Width = 29
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 1
      OnClick = BtnArquivoClick
    end
    object EdtParametro: TEdit [9]
      Left = 70
      Top = 60
      Width = 325
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      OnChange = EdtParametroChange
    end
    object EdtDiretorio: TEdit [10]
      Left = 70
      Top = 87
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      OnChange = EdtDiretorioChange
    end
    object BtnDiretorio: TButton [11]
      Left = 366
      Top = 87
      Width = 29
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 4
      OnClick = BtnDiretorioClick
    end
    object CmbEstado: TComboBox [12]
      Left = 70
      Top = 114
      Width = 119
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 5
      Text = 'Normal'
      OnChange = CmbEstadoChange
      Items.Strings = (
        'Oculto'
        'Normal'
        'Minimizado'
        'Maxmizado')
    end
    object CmbPrioridade: TComboBox [13]
      Left = 70
      Top = 141
      Width = 119
      Height = 21
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 6
      Text = 'Normal'
      OnChange = CmbPrioridadeChange
      Items.Strings = (
        'Baixa'
        'Abaixo do Normal'
        'Normal'
        'Acima do Normal'
        'Alta'
        'Tempo Real')
    end
    object BtnTest: TButton [14]
      Left = 269
      Top = 141
      Width = 127
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Test'
      TabOrder = 7
      OnClick = BtnTestClick
    end
    object CmbOperation: TComboBox [15]
      Left = 268
      Top = 114
      Width = 127
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemIndex = 0
      TabOrder = 8
      Text = 'Open'
      OnChange = CmbOperationChange
      Items.Strings = (
        'Open'
        'Edit'
        'Explore'
        'Find'
        'Print'
        'Properties'
        'Runas')
    end
    inherited EdtName: TEditEx
      TabOrder = 9
    end
    object pnlScript: TPanel
      Left = 0
      Top = 168
      Width = 400
      Height = 142
      Align = alBottom
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelOuter = bvNone
      TabOrder = 10
      object Splitter1: TSplitter
        Left = 0
        Top = 66
        Width = 400
        Height = 8
        Cursor = crVSplit
        Align = alTop
        Beveled = True
        ExplicitTop = 94
      end
      object GrbScriptIni: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 394
        Height = 60
        Align = alTop
        Caption = 'Script Inicio (Run: F9)'
        Constraints.MinHeight = 60
        TabOrder = 0
        object EdtScriptIni: TRichEditEx
          Left = 2
          Top = 15
          Width = 390
          Height = 43
          Align = alClient
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          Zoom = 100
          OnChange = EdtScriptIniChange
        end
      end
      object gpbScriptEnd: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 77
        Width = 394
        Height = 62
        Align = alClient
        Caption = 'Script Final (Run: F9)'
        Constraints.MinHeight = 60
        TabOrder = 1
        object edtScriptEnd: TRichEditEx
          Left = 2
          Top = 15
          Width = 390
          Height = 45
          Align = alClient
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          Zoom = 100
          OnChange = edtScriptEndChange
        end
      end
    end
  end
  object OpdLinks: TOpenDialog
    Left = 199
    Top = 39
  end
end
