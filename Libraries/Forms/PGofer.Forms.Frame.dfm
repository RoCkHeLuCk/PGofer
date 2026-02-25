inherited PGFormsFrame: TPGFormsFrame
  Height = 310
  ExplicitHeight = 310
  inherited grbAbout: TGroupBox
    Top = 236
    Height = 64
    ExplicitTop = 255
    ExplicitHeight = 64
    inherited rceAbout: TRichEdit
      Height = 47
      ExplicitHeight = 47
    end
  end
  inherited pnlItem: TPanel
    Height = 233
    Constraints.MinHeight = 230
    ExplicitHeight = 233
    DesignSize = (
      400
      233)
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
      Top = 121
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Heigth:'
    end
    object LblLeft: TLabel [2]
      Left = 173
      Top = 149
      Width = 74
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Left:'
    end
    object LblTop: TLabel [3]
      Left = 5
      Top = 149
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Top:'
    end
    object LblTransparentColor: TLabel [4]
      Left = 144
      Top = 68
      Width = 148
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Transparent Color:'
    end
    object LblWidth: TLabel [5]
      Left = 173
      Top = 121
      Width = 74
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Width:'
    end
    object LblWindowState: TLabel [6]
      Left = 5
      Top = 178
      Width = 93
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'WindowState:'
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
      OnChangingEx = UpdAlphaBlendValueChangingEx
    end
    object CkbEnabled: TCheckBox [10]
      Left = 244
      Top = 92
      Width = 76
      Height = 17
      Caption = 'Enabled'
      TabOrder = 2
      OnClick = CkbEnabledClick
    end
    object CkbTransparent: TCheckBox [11]
      Left = 49
      Top = 64
      Width = 89
      Height = 17
      Caption = 'Transparent'
      TabOrder = 3
      OnClick = CkbTransparentClick
    end
    object PnlTransparentColor: TPanel [12]
      Left = 298
      Top = 64
      Width = 22
      Height = 22
      Color = clBlack
      ParentBackground = False
      TabOrder = 4
      OnClick = PnlTransparentColorClick
    end
    object CkbVisible: TCheckBox [13]
      Left = 49
      Top = 92
      Width = 97
      Height = 17
      Caption = 'Visible'
      TabOrder = 5
      OnClick = CkbVisibleClick
    end
    object CmbWindowState: TComboBox [14]
      Left = 104
      Top = 175
      Width = 117
      Height = 21
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csDropDownList
      Color = clSilver
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
      Left = 199
      Top = 202
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 7
      OnClick = BtnCloseClick
    end
    object BtnShow: TButton [16]
      Left = 118
      Top = 202
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
      Color = clSilver
      TabOrder = 9
      Text = '0'
      OnKeyUp = EdtAlphaBlendValueKeyUp
    end
    object EdtHeigth: TEditEx [18]
      Left = 70
      Top = 118
      Width = 76
      Height = 21
      Color = clSilver
      TabOrder = 10
      OnKeyUp = EdtHeigthKeyUp
    end
    object EdtTop: TEditEx [19]
      Left = 70
      Top = 145
      Width = 76
      Height = 21
      Color = clSilver
      TabOrder = 11
      OnKeyUp = EdtTopKeyUp
    end
    object EdtWidth: TEditEx [20]
      Left = 253
      Top = 118
      Width = 76
      Height = 21
      Color = clSilver
      TabOrder = 12
      OnKeyUp = EdtWidthKeyUp
    end
    object EdtLeft: TEditEx [21]
      Left = 253
      Top = 145
      Width = 76
      Height = 21
      Color = clSilver
      TabOrder = 13
      OnKeyUp = EdtLeftKeyUp
    end
    inherited EdtName: TEditEx
      TabOrder = 14
    end
  end
  inherited sptAbout: TPanel
    Top = 303
    ExplicitTop = 318
  end
  object cldTrasparentColor: TColorDialog
    Options = [cdFullOpen, cdPreventFullOpen, cdShowHelp, cdSolidColor, cdAnyColor]
    Left = 356
    Top = 56
  end
end
