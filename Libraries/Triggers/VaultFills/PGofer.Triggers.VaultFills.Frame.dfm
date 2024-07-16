inherited PGVaultFillsFrame: TPGVaultFillsFrame
  Height = 241
  ExplicitHeight = 241
  object sptScript: TSplitter [0]
    Left = 0
    Top = 150
    Width = 400
    Height = 6
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ExplicitTop = 176
  end
  object GrbText: TGroupBox [1]
    AlignWithMargins = True
    Left = 3
    Top = 62
    Width = 394
    Height = 85
    Align = alTop
    Caption = 'Text'
    Constraints.MinHeight = 60
    TabOrder = 0
    object EdtText: TRichEditEx
      Left = 2
      Top = 15
      Width = 390
      Height = 68
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderWidth = 1
      Color = clSilver
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Courier New'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      Zoom = 100
      OnKeyUp = EdtTextKeyUp
    end
  end
  inherited grbAbout: TGroupBox
    Top = 159
    Height = 72
    TabOrder = 2
    ExplicitTop = 159
    ExplicitHeight = 72
    inherited rceAbout: TRichEdit
      Height = 55
      ExplicitHeight = 55
    end
  end
  inherited pnlItem: TPanel
    Height = 59
    Anchors = []
    ExplicitHeight = 59
    object LblSpeed: TLabel [1]
      Left = 250
      Top = 36
      Width = 70
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Speed:'
    end
    object LblMode: TLabel [2]
      Left = 5
      Top = 36
      Width = 59
      Height = 13
      Hint = 'Forma de enviar o Texto'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Mode:'
      ParentBiDiMode = False
    end
    object EdtSpeed: TEditEx
      Left = 326
      Top = 33
      Width = 51
      Height = 21
      Color = clSilver
      TabOrder = 1
      Text = '10'
      OnKeyUp = EdtSpeedKeyUp
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object UpdSpeed: TUpDown
      Left = 377
      Top = 33
      Width = 16
      Height = 21
      Associate = EdtSpeed
      Max = 255
      Position = 10
      TabOrder = 2
      OnChangingEx = UpdSpeedChangingEx
    end
    object CmbMode: TComboBox
      Left = 70
      Top = 33
      Width = 147
      Height = 21
      Style = csDropDownList
      Color = clSilver
      ItemIndex = 0
      TabOrder = 3
      Text = 'Write'
      OnChange = CmbModeChange
      Items.Strings = (
        'Write'
        'Copy'
        'Copy and Paste'
        'Send'
        'Script')
    end
  end
  inherited sptAbout: TPanel
    Top = 234
    TabOrder = 3
    ExplicitTop = 234
  end
end
