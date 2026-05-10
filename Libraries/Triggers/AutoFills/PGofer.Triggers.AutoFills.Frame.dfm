inherited PGAutoFillsFrame: TPGAutoFillsFrame
  Height = 283
  ExplicitHeight = 283
  object sptScript: TSplitter [0]
    Left = 0
    Top = 181
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
    Top = 93
    Width = 394
    Height = 85
    Align = alTop
    Caption = 'Text'
    Constraints.MinHeight = 60
    TabOrder = 2
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
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      OnKeyUp = EdtTextKeyUp
    end
  end
  inherited grbAbout: TGroupBox
    Top = 190
    Height = 83
    TabOrder = 1
    ExplicitTop = 190
    ExplicitHeight = 83
    inherited rceAbout: TRichEdit
      Height = 66
      ExplicitHeight = 66
    end
  end
  inherited pnlItem: TPanel
    Height = 90
    Anchors = []
    ExplicitHeight = 90
    object LblSpeed: TLabel [1]
      Left = 205
      Top = 36
      Width = 59
      Height = 13
      Alignment = taRightJustify
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
      Caption = 'Mode:'
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
      Width = 13
      Height = 13
      Caption = 'ms'
    end
    object Lblmilisec2: TLabel [5]
      Left = 169
      Top = 36
      Width = 13
      Height = 13
      Caption = 'ms'
    end
    object EdtSpeed: TEditEx
      Left = 270
      Top = 33
      Width = 75
      Height = 21
      TabOrder = 3
      Text = '10'
      RegExExpression = '^\d*$'
      OnAfterValidate = EdtSpeedAfterValidate
    end
    object UpdSpeed: TUpDown
      Left = 345
      Top = 33
      Width = 16
      Height = 21
      Associate = EdtSpeed
      Max = 255
      Position = 10
      TabOrder = 4
      OnChangingEx = UpdSpeedChangingEx
    end
    object CmbMode: TPGComboBox
      Left = 70
      Top = 60
      Width = 147
      Height = 22
      ItemsEx = <
        item
          Caption = 'Write'
        end
        item
          Caption = 'Send Point'
        end
        item
          Caption = 'Copy'
        end
        item
          Caption = 'Copy and Paste'
        end
        item
          Caption = 'Script'
        end>
      Style = csExDropDownList
      TabOrder = 5
      Text = 'Write'
      OnChange = CmbModeChange
      ItemIndex = 0
    end
    object EdtDelay: TEditEx
      Left = 70
      Top = 33
      Width = 75
      Height = 21
      TabOrder = 1
      Text = '200'
      RegExExpression = '^\d*$'
      OnAfterValidate = EdtDelayAfterValidate
    end
    object updDelay: TUpDown
      Left = 145
      Top = 33
      Width = 16
      Height = 21
      Associate = EdtDelay
      Max = 255
      Position = 200
      TabOrder = 2
      OnChangingEx = updDelayChangingEx
    end
  end
  inherited sptAbout: TPanel
    Top = 276
    TabOrder = 3
    ExplicitTop = 276
  end
end
