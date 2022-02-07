inherited PGTaskFrame: TPGTaskFrame
  Height = 255
  ExplicitHeight = 255
  object sptScript: TSplitter [0]
    Left = 0
    Top = 176
    Width = 400
    Height = 6
    Cursor = crVSplit
    Align = alTop
    Beveled = True
  end
  object GrbScript: TGroupBox [1]
    AlignWithMargins = True
    Left = 3
    Top = 93
    Width = 394
    Height = 80
    Align = alTop
    Caption = 'Script (Run: F9)'
    Constraints.MinHeight = 60
    TabOrder = 0
    object EdtScript: TRichEditEx
      Left = 2
      Top = 15
      Width = 390
      Height = 63
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
      OnKeyUp = EdtScriptKeyUp
    end
  end
  inherited grbAbout: TGroupBox
    Top = 185
    TabOrder = 2
    ExplicitTop = 185
  end
  inherited pnlItem: TPanel
    Height = 90
    Anchors = []
    ExplicitHeight = 90
    object LblTrigger: TLabel [1]
      Left = 5
      Top = 36
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Trigger:'
      ParentBiDiMode = False
    end
    object lblOccurrence: TLabel [2]
      Left = 137
      Top = 63
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Occurrence:'
      ParentBiDiMode = False
    end
    object LblRepeat: TLabel [3]
      Left = 13
      Top = 63
      Width = 51
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Repeat:'
      ParentBiDiMode = False
    end
    object CmbTrigger: TComboBox [4]
      Left = 70
      Top = 33
      Width = 100
      Height = 21
      Style = csDropDownList
      Color = clSilver
      ItemIndex = 0
      TabOrder = 0
      Text = 'Initializing'
      OnChange = CmbTriggerChange
      Items.Strings = (
        'Initializing'
        'Finishing'
        'Turning off')
    end
    object EdtOccurrence: TEditEx [5]
      Left = 202
      Top = 60
      Width = 45
      Height = 21
      Color = clSilver
      TabOrder = 1
      Text = '0'
      OnExit = EdtOccurrenceExit
      OnKeyUp = EdtOccurrenceKeyUp
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object updOccurrence: TUpDown [6]
      Left = 247
      Top = 60
      Width = 16
      Height = 21
      Associate = EdtOccurrence
      Max = 999999999
      TabOrder = 2
      OnChangingEx = updOccurrenceChangingEx
    end
    object EdtRepeat: TEditEx [7]
      Left = 70
      Top = 60
      Width = 45
      Height = 21
      Color = clSilver
      TabOrder = 3
      Text = '0'
      OnKeyUp = EdtRepeatKeyUp
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object UpdRepeat: TUpDown [8]
      Left = 115
      Top = 60
      Width = 16
      Height = 21
      Associate = EdtRepeat
      Max = 999999999
      TabOrder = 4
      OnChangingEx = UpdRepeatChangingEx
    end
    inherited EdtName: TEditEx
      TabOrder = 5
    end
  end
  inherited sptAbout: TPanel
    Top = 248
    TabOrder = 3
    ExplicitTop = 248
  end
end
