inherited PGTaskFrame: TPGTaskFrame
  Height = 215
  ExplicitHeight = 215
  inherited SplitterItem: TSplitter
    Top = 161
    ExplicitTop = 333
  end
  inherited grbAbout: TGroupBox
    Top = 172
    ExplicitTop = 172
  end
  inherited pnlItem: TPanel
    Height = 161
    Constraints.MinHeight = 160
    ExplicitHeight = 161
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
    object CmbTrigger: TComboBox
      Left = 70
      Top = 33
      Width = 100
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'Initializing'
      OnChange = CmbTriggerChange
      Items.Strings = (
        'Initializing'
        'Finishing'
        'Turning off')
    end
    object GrbScript: TGroupBox
      AlignWithMargins = True
      Left = 5
      Top = 84
      Width = 390
      Height = 74
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Script (Run: F9)'
      TabOrder = 2
      object EdtScript: TRichEditEx
        Left = 2
        Top = 15
        Width = 386
        Height = 57
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
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
    object EdtOccurrence: TEditEx
      Left = 202
      Top = 60
      Width = 45
      Height = 21
      TabOrder = 3
      Text = '0'
      OnExit = EdtOccurrenceExit
      OnKeyUp = EdtOccurrenceKeyUp
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object updOccurrence: TUpDown
      Left = 247
      Top = 60
      Width = 16
      Height = 21
      Associate = EdtOccurrence
      Max = 999999999
      TabOrder = 4
      OnChangingEx = updOccurrenceChangingEx
    end
    object EdtRepeat: TEditEx
      Left = 70
      Top = 60
      Width = 45
      Height = 21
      TabOrder = 5
      Text = '0'
      OnKeyUp = EdtRepeatKeyUp
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object UpdRepeat: TUpDown
      Left = 115
      Top = 60
      Width = 16
      Height = 21
      Associate = EdtRepeat
      Max = 999999999
      TabOrder = 6
      OnChangingEx = UpdRepeatChangingEx
    end
  end
end
