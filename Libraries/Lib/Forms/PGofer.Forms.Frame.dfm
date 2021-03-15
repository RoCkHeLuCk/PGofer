inherited PGFrameForms: TPGFrameForms
  Width = 414
  Height = 378
  Constraints.MinHeight = 255
  DoubleBuffered = True
  ParentDoubleBuffered = False
  ExplicitWidth = 414
  ExplicitHeight = 378
  inherited SplitterItem: TSplitter
    Top = 255
    Width = 414
    ExplicitTop = 252
    ExplicitWidth = 502
  end
  inherited grbAbout: TGroupBox
    Top = 266
    Width = 408
    Height = 109
    ExplicitTop = 266
    ExplicitWidth = 408
    ExplicitHeight = 109
    inherited rceAbout: TRichEdit
      Width = 404
      Height = 92
      ExplicitWidth = 404
      ExplicitHeight = 92
    end
  end
  inherited pnlItem: TPanel
    Width = 414
    Height = 255
    Constraints.MinHeight = 255
    Constraints.MinWidth = 0
    ExplicitWidth = 414
    ExplicitHeight = 255
    DesignSize = (
      414
      255)
    object LblAlphaBlendValue: TLabel [0]
      Left = 144
      Top = 40
      Width = 104
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Alpha Blend Value:'
    end
    object LblHeigth: TLabel [1]
      Left = 5
      Top = 134
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Heigth:'
      ParentBiDiMode = False
    end
    object LblLeft: TLabel [2]
      Left = 173
      Top = 162
      Width = 74
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Left:'
      ParentBiDiMode = False
    end
    object LblTop: TLabel [3]
      Left = 5
      Top = 162
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Top:'
      ParentBiDiMode = False
    end
    object LblTransparentColor: TLabel [4]
      Left = 144
      Top = 73
      Width = 148
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Transparent Color:'
    end
    object LblWidth: TLabel [5]
      Left = 173
      Top = 134
      Width = 74
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Width:'
      ParentBiDiMode = False
    end
    object LblWindowState: TLabel [6]
      Left = 5
      Top = 191
      Width = 93
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'WindowState:'
      ParentBiDiMode = False
    end
    object CkbAlphaBlend: TCheckBox [8]
      Left = 49
      Top = 39
      Width = 89
      Height = 17
      Caption = 'Alpha Blend'
      TabOrder = 0
      OnClick = CkbAlphaBlendClick
    end
    object UpdAlphaBlendValue: TUpDown [9]
      Left = 305
      Top = 37
      Width = 15
      Height = 21
      Associate = EdtAlphaBlendValue
      Max = 255
      TabOrder = 1
      OnChanging = UpdAlphaBlendValueChanging
    end
    object CkbEnabled: TCheckBox [10]
      Left = 244
      Top = 103
      Width = 76
      Height = 17
      Caption = 'Enabled'
      TabOrder = 2
      OnClick = CkbEnabledClick
    end
    object CkbTransparent: TCheckBox [11]
      Left = 49
      Top = 69
      Width = 89
      Height = 17
      Caption = 'Transparent'
      TabOrder = 3
      OnClick = CkbTransparentClick
    end
    object PnlTransparentColor: TPanel [12]
      Left = 298
      Top = 69
      Width = 22
      Height = 22
      Color = clBlack
      ParentBackground = False
      TabOrder = 4
      OnClick = PnlTransparentColorClick
    end
    object CkbVisible: TCheckBox [13]
      Left = 49
      Top = 103
      Width = 97
      Height = 17
      Caption = 'Visible'
      TabOrder = 5
      OnClick = CkbVisibleClick
    end
    object CmbWindowState: TComboBox [14]
      Left = 104
      Top = 188
      Width = 117
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 6
      Text = 'wsNormal'
      OnChange = CmbWindowStateChange
      Items.Strings = (
        'wsNormal'
        'wsMinimized'
        'wsMaximized')
    end
    object BtnClose: TButton [15]
      Left = 245
      Top = 219
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 7
      OnClick = BtnCloseClick
    end
    object BtnShow: TButton [16]
      Left = 70
      Top = 219
      Width = 75
      Height = 25
      Caption = 'Show'
      TabOrder = 8
      OnClick = BtnShowClick
    end
    object EdtAlphaBlendValue: TEditEx [17]
      Left = 254
      Top = 37
      Width = 51
      Height = 21
      TabOrder = 9
      Text = '0'
      OnExit = EdtAlphaBlendValueExit
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object EdtHeigth: TEditEx [18]
      Left = 70
      Top = 131
      Width = 76
      Height = 21
      TabOrder = 10
      OnExit = EdtHeigthExit
      RegExamples = reNone
      RegExpression = '^-?\d*$'
    end
    object EdtTop: TEditEx [19]
      Left = 70
      Top = 158
      Width = 76
      Height = 21
      TabOrder = 11
      OnExit = EdtTopExit
      RegExamples = reNone
      RegExpression = '^-?\d*$'
    end
    object EdtWidth: TEditEx [20]
      Left = 253
      Top = 131
      Width = 76
      Height = 21
      TabOrder = 12
      OnExit = EdtWidthExit
      RegExamples = reNone
      RegExpression = '^-?\d*$'
    end
    object EdtLeft: TEditEx [21]
      Left = 253
      Top = 158
      Width = 76
      Height = 21
      TabOrder = 13
      OnExit = EdtLeftExit
      RegExamples = reNone
      RegExpression = '^-?\d*$'
    end
    inherited EdtName: TEditEx
      TabOrder = 14
    end
  end
  object cldTrasparentColor: TColorDialog
    Options = [cdFullOpen, cdPreventFullOpen, cdShowHelp, cdSolidColor, cdAnyColor]
    Left = 344
    Top = 52
  end
end
