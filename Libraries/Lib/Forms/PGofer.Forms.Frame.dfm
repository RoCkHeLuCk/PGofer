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
      ParentColor = True
      ScrollBars = ssBoth
      WantTabs = True
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
    object LblAlphaBlendValue: TLabel [1]
      Left = 160
      Top = 40
      Width = 89
      Height = 13
      Alignment = taRightJustify
      Caption = 'Alpha Blend Value:'
    end
    object LblHeigth: TLabel [2]
      Left = 29
      Top = 134
      Width = 35
      Height = 13
      Caption = 'Heigth:'
    end
    object LblLeft: TLabel [3]
      Left = 226
      Top = 162
      Width = 23
      Height = 13
      Caption = 'Left:'
    end
    object LblTop: TLabel [4]
      Left = 41
      Top = 162
      Width = 22
      Height = 13
      Caption = 'Top:'
    end
    object LblTransparentColor: TLabel [5]
      Left = 204
      Top = 73
      Width = 91
      Height = 13
      Caption = 'Transparent Color:'
    end
    object LblWidth: TLabel [6]
      Left = 214
      Top = 134
      Width = 32
      Height = 13
      Caption = 'Width:'
    end
    object LblWindowState: TLabel [7]
      Left = 30
      Top = 191
      Width = 68
      Height = 13
      Caption = 'WindowState:'
    end
    inherited EdtName: TEditEx
      Width = 338
      ExplicitWidth = 338
    end
    object CkbAlphaBlend: TCheckBox
      Left = 49
      Top = 39
      Width = 89
      Height = 17
      Caption = 'Alpha Blend'
      TabOrder = 1
      OnClick = CkbAlphaBlendClick
    end
    object UpdAlphaBlendValue: TUpDown
      Left = 305
      Top = 37
      Width = 15
      Height = 21
      Associate = EdtAlphaBlendValue
      Max = 255
      TabOrder = 2
      OnChanging = UpdAlphaBlendValueChanging
    end
    object CkbEnabled: TCheckBox
      Left = 244
      Top = 103
      Width = 76
      Height = 17
      Caption = 'Enabled'
      TabOrder = 3
      OnClick = CkbEnabledClick
    end
    object CkbTransparent: TCheckBox
      Left = 49
      Top = 69
      Width = 89
      Height = 17
      Caption = 'Transparent'
      TabOrder = 4
      OnClick = CkbTransparentClick
    end
    object PnlTransparentColor: TPanel
      Left = 298
      Top = 69
      Width = 22
      Height = 22
      Color = clBlack
      ParentBackground = False
      TabOrder = 5
      OnClick = PnlTransparentColorClick
    end
    object CkbVisible: TCheckBox
      Left = 49
      Top = 103
      Width = 97
      Height = 17
      Caption = 'Visible'
      TabOrder = 6
      OnClick = CkbVisibleClick
    end
    object CmbWindowState: TComboBox
      Left = 104
      Top = 188
      Width = 117
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 7
      Text = 'wsNormal'
      OnChange = CmbWindowStateChange
      Items.Strings = (
        'wsNormal'
        'wsMinimized'
        'wsMaximized')
    end
    object BtnClose: TButton
      Left = 245
      Top = 219
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 8
      OnClick = BtnCloseClick
    end
    object BtnShow: TButton
      Left = 70
      Top = 219
      Width = 75
      Height = 25
      Caption = 'Show'
      TabOrder = 9
      OnClick = BtnShowClick
    end
    object EdtAlphaBlendValue: TEditEx
      Left = 254
      Top = 37
      Width = 51
      Height = 21
      TabOrder = 10
      Text = '0'
      OnExit = EdtAlphaBlendValueExit
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object EdtHeigth: TEditEx
      Left = 70
      Top = 131
      Width = 76
      Height = 21
      TabOrder = 11
      OnExit = EdtHeigthExit
      RegExamples = reNone
      RegExpression = '^-?\d*$'
    end
    object EdtTop: TEditEx
      Left = 70
      Top = 158
      Width = 76
      Height = 21
      TabOrder = 12
      OnExit = EdtTopExit
      RegExamples = reNone
      RegExpression = '^-?\d*$'
    end
    object EdtWidth: TEditEx
      Left = 253
      Top = 131
      Width = 76
      Height = 21
      TabOrder = 13
      OnExit = EdtWidthExit
      RegExamples = reNone
      RegExpression = '^-?\d*$'
    end
    object EdtLeft: TEditEx
      Left = 253
      Top = 158
      Width = 76
      Height = 21
      TabOrder = 14
      OnExit = EdtLeftExit
      RegExamples = reNone
      RegExpression = '^-?\d*$'
    end
  end
  object cldTrasparentColor: TColorDialog
    Options = [cdFullOpen, cdPreventFullOpen, cdShowHelp, cdSolidColor, cdAnyColor]
    Left = 344
    Top = 52
  end
end
