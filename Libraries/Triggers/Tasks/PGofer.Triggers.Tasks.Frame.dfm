inherited PGTaskFrame: TPGTaskFrame
  Height = 295
  ExplicitHeight = 295
  object sptScript: TSplitter [0]
    Left = 0
    Top = 216
    Width = 400
    Height = 6
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ExplicitTop = 176
  end
  object GrbScript: TGroupBox [1]
    AlignWithMargins = True
    Left = 3
    Top = 93
    Width = 394
    Height = 120
    Align = alTop
    Caption = 'Script (Run: F9)'
    Constraints.MinHeight = 120
    TabOrder = 1
    object EdtScript: TMemoEx
      Left = 2
      Top = 15
      Width = 390
      Height = 84
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      Color = clSilver
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      OnKeyUp = EdtScriptKeyUp
      ShowStatusBar = True
      ExplicitLeft = 4
      ExplicitTop = 17
      ExplicitHeight = 63
    end
  end
  inherited grbAbout: TGroupBox
    Top = 225
    Height = 60
    ExplicitTop = 185
    ExplicitHeight = 80
    inherited mmoAbout: TMemoEx
      Height = 23
      ExplicitHeight = 43
    end
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
      Caption = 'Trigger:'
    end
    object LblOccurrence: TLabel [2]
      Left = 137
      Top = 63
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Occurrence:'
    end
    object LblRepeat: TLabel [3]
      Left = 13
      Top = 63
      Width = 51
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Repeat:'
    end
    object CmbTrigger: TPGComboBox [4]
      Left = 70
      Top = 33
      Width = 100
      Height = 22
      ItemsEx = <
        item
          Caption = 'Initializing'
        end
        item
          Caption = 'Finishing'
        end
        item
          Caption = 'Shutdown'
        end>
      Style = csExDropDown
      Color = clSilver
      TabOrder = 4
      Text = 'Initializing'
      OnChange = CmbTriggerChange
      ItemIndex = 0
    end
    object EdtOccurrence: TEditEx [5]
      Left = 202
      Top = 60
      Width = 45
      Height = 21
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      Text = '0'
      ValidationColorNormal = clSilver
    end
    object EdtRepeat: TEditEx [6]
      Left = 70
      Top = 60
      Width = 45
      Height = 21
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      Text = '0'
      ValidationColorNormal = clSilver
      OnAfterValidate = EdtRepeatAfterValidate
    end
    object UpdRepeat: TUpDown [7]
      Left = 115
      Top = 60
      Width = 16
      Height = 21
      Associate = EdtRepeat
      Max = 999999999
      TabOrder = 3
    end
    object CkbDisabled: TCheckBoxEx
      Left = 202
      Top = 33
      Width = 97
      Height = 17
      Caption = 'Disabled'
      TabOrder = 5
      OnClick = CkbDisabledClick
    end
  end
  inherited sptAbout: TPanel
    Top = 288
    TabOrder = 3
    ExplicitTop = 268
  end
end
