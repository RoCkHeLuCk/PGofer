inherited PGHotKeyFrame: TPGHotKeyFrame
  Height = 314
  OnExit = MmoHotKeysExit
  ExplicitHeight = 314
  object sptScript: TSplitter [0]
    Left = 0
    Top = 233
    Width = 400
    Height = 6
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ExplicitTop = 176
  end
  inherited grbAbout: TGroupBox
    Top = 242
    Height = 62
    TabOrder = 1
    ExplicitTop = 242
    ExplicitHeight = 62
    inherited mmoAbout: TMemoEx
      Height = 45
    end
  end
  object GrbScript: TGroupBox [2]
    AlignWithMargins = True
    Left = 3
    Top = 156
    Width = 394
    Height = 74
    Align = alTop
    Caption = 'Script (Run: F9)'
    Constraints.MinHeight = 60
    TabOrder = 2
    object EdtScript: TMemoEx
      Left = 2
      Top = 15
      Width = 390
      Height = 57
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
    end
  end
  inherited pnlItem: TPanel
    Height = 153
    Anchors = []
    ExplicitHeight = 153
    DesignSize = (
      400
      153)
    object LblDetect: TLabel [0]
      Left = 110
      Top = 118
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a HotKey'
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Detect:'
    end
    object GrbHotKeys: TGroupBox [2]
      Left = 5
      Top = 33
      Width = 389
      Height = 72
      Anchors = [akLeft, akTop, akRight]
      Caption = 'HotKeys'
      TabOrder = 4
      object MmoHotKeys: TMemo
        Left = 2
        Top = 15
        Width = 385
        Height = 55
        Align = alClient
        Alignment = taCenter
        BevelInner = bvNone
        BevelOuter = bvNone
        Lines.Strings = (
          '')
        ParentColor = True
        ReadOnly = True
        TabOrder = 0
        WantReturns = False
        WordWrap = False
        OnEnter = MmoHotKeysEnter
        OnExit = MmoHotKeysExit
        OnMouseEnter = MmoHotKeysEnter
        OnMouseLeave = MmoHotKeysExit
      end
    end
    object BtnClean: TButton [3]
      Left = 10
      Top = 111
      Width = 94
      Height = 26
      Caption = 'Clean'
      ImageIndex = 6
      TabOrder = 1
      TabStop = False
      OnClick = BtnCleanClick
    end
    object CmbDetect: TPGComboBox [4]
      Left = 175
      Top = 111
      Width = 96
      Height = 22
      Hint = 'Forma de detectar a HotKey'
      ItemsEx = <
        item
          Caption = 'Press'
        end
        item
          Caption = 'Down'
        end
        item
          Caption = 'Up'
        end>
      Style = csExDropDown
      Color = clSilver
      TabOrder = 2
      Text = 'Down'
      OnChange = CmbDetectChange
      ItemIndex = 1
    end
    object CkbInhibit: TCheckBoxEx [5]
      Left = 295
      Top = 111
      Width = 98
      Height = 17
      Hint = 'Bloqueia a tecla detectada'
      Caption = 'Inhibit last key'
      TabOrder = 3
      OnClick = CkbInhibitClick
    end
    object CkbEnable: TCheckBoxEx
      Left = 295
      Top = 129
      Width = 97
      Height = 17
      Caption = 'Enable'
      TabOrder = 5
      OnClick = CkbEnableClick
    end
  end
  inherited sptAbout: TPanel
    Top = 307
    TabOrder = 3
    ExplicitTop = 307
  end
end
