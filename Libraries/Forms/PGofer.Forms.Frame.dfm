inherited PGFormsFrame: TPGFormsFrame
  Height = 310
  ExplicitHeight = 310
  inherited grbAbout: TGroupBox
    Top = 236
    Height = 64
    ExplicitTop = 236
    ExplicitHeight = 64
    inherited mmoAbout: TMemoEx
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
    object CkbAlphaBlend: TCheckBoxEx [8]
      Left = 49
      Top = 39
      Width = 89
      Height = 17
      Caption = 'Alpha Blend'
      Color = clBtnFace
      ParentColor = False
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
    end
    object CkbEnabled: TCheckBoxEx [10]
      Left = 244
      Top = 92
      Width = 76
      Height = 17
      Caption = 'Enabled'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 2
      OnClick = CkbEnabledClick
    end
    object CkbTransparent: TCheckBoxEx [11]
      Left = 49
      Top = 64
      Width = 89
      Height = 17
      Caption = 'Transparent'
      Color = clBtnFace
      ParentColor = False
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
      StyleElements = [seFont, seBorder]
      OnClick = PnlTransparentColorClick
    end
    object CkbVisible: TCheckBoxEx [13]
      Left = 49
      Top = 92
      Width = 97
      Height = 17
      Caption = 'Visible'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 5
      OnClick = CkbVisibleClick
    end
    object CmbWindowState: TPGComboBox [14]
      Left = 104
      Top = 174
      Width = 117
      Height = 22
      ItemsEx = <
        item
          Caption = 'wsNormal'
        end
        item
          Caption = 'wsMinimized'
        end
        item
          Caption = 'wsMaximized'
        end>
      Style = csExDropDown
      Color = clSilver
      TabOrder = 6
      Text = 'wsNormal'
      OnChange = CmbWindowStateChange
      ItemIndex = 0
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
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 9
      Text = '0'
      ValidationColorNormal = clSilver
      OnAfterValidate = EdtAlphaBlendValueAfterValidate
    end
    object EdtHeigth: TEditEx [18]
      Left = 70
      Top = 118
      Width = 76
      Height = 21
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 10
      OnAfterValidate = EdtHeigthAfterValidate
    end
    object EdtTop: TEditEx [19]
      Left = 70
      Top = 147
      Width = 76
      Height = 21
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 11
      OnAfterValidate = EdtTopAfterValidate
    end
    object EdtWidth: TEditEx [20]
      Left = 253
      Top = 118
      Width = 76
      Height = 21
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 12
      OnAfterValidate = EdtWidthAfterValidate
    end
    object EdtLeft: TEditEx [21]
      Left = 253
      Top = 145
      Width = 76
      Height = 21
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 13
      OnAfterValidate = EdtLeftAfterValidate
    end
    inherited EdtName: TEditEx
      TabOrder = 14
    end
  end
  inherited sptAbout: TPanel
    Top = 303
    ExplicitTop = 303
  end
  object cldTrasparentColor: TColorDialog
    Options = [cdFullOpen, cdPreventFullOpen, cdShowHelp, cdSolidColor, cdAnyColor]
    Left = 356
    Top = 56
  end
end
