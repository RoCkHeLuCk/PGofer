inherited PGAutoFillsFrame: TPGAutoFillsFrame
  Height = 283
  ExplicitHeight = 283
  object sptScript: TSplitter [0]
    Left = 0
    Top = 172
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
    Top = 84
    Width = 394
    Height = 85
    Align = alTop
    Caption = 'Text'
    Constraints.MinHeight = 60
    TabOrder = 0
    ExplicitTop = 62
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
    Top = 181
    Height = 92
    TabOrder = 2
    ExplicitTop = 159
    ExplicitHeight = 72
    inherited rceAbout: TRichEdit
      Height = 75
      ExplicitHeight = 55
    end
  end
  inherited pnlItem: TPanel
    Height = 81
    Anchors = []
    ExplicitHeight = 81
    object LblSpeed: TLabel [1]
      Left = 205
      Top = 36
      Width = 59
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Speed:'
    end
    object LblMode: TLabel [2]
      Left = 5
      Top = 63
      Width = 59
      Height = 13
      Hint = 'Forma de enviar o Texto'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Mode:'
      ParentBiDiMode = False
    end
    object LblDelay: TLabel [3]
      Left = 3
      Top = 36
      Width = 61
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Delay:'
    end
    object Lblmilisec1: TLabel [4]
      Left = 367
      Top = 36
      Width = 26
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'ms'
    end
    object Lblmilisec2: TLabel [5]
      Left = 169
      Top = 36
      Width = 26
      Height = 13
      Caption = 'ms'
    end
    object EdtSpeed: TEditEx
      Left = 270
      Top = 33
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Color = clSilver
      TabOrder = 1
      Text = '10'
      OnKeyUp = EdtSpeedKeyUp
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object UpdSpeed: TUpDown
      Left = 345
      Top = 33
      Width = 16
      Height = 21
      Anchors = [akTop, akRight]
      Associate = EdtSpeed
      Max = 255
      Position = 10
      TabOrder = 2
      OnChangingEx = UpdSpeedChangingEx
    end
    object CmbMode: TComboBox
      Left = 70
      Top = 60
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
        'Send Point'
        'Copy'
        'Copy and Paste'
        'Script')
    end
    object EdtDelay: TEditEx
      Left = 70
      Top = 33
      Width = 75
      Height = 21
      Color = clSilver
      TabOrder = 4
      Text = '0'
      OnKeyUp = EdtDelayKeyUp
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object updDelay: TUpDown
      Left = 147
      Top = 33
      Width = 16
      Height = 21
      Associate = EdtDelay
      Max = 255
      TabOrder = 5
      OnChangingEx = updDelayChangingEx
    end
  end
  inherited sptAbout: TPanel
    Top = 276
    TabOrder = 3
    ExplicitTop = 234
  end
end
