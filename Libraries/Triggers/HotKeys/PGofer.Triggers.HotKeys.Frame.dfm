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
    ExplicitTop = 234
    inherited rceAbout: TRichEdit
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
    ExplicitTop = 148
    object EdtScript: TRichEditEx
      Left = 2
      Top = 15
      Width = 390
      Height = 57
      Align = alClient
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
      StyleElements = [seFont, seClient]
    end
    object GrbHotKeys: TGroupBox [2]
      Left = 5
      Top = 33
      Width = 389
      Height = 72
      Anchors = [akLeft, akTop, akRight]
      Caption = 'HotKeys'
      TabOrder = 4
      StyleElements = [seFont, seClient]
      object MmoHotKeys: TMemo
        Left = 2
        Top = 15
        Width = 385
        Height = 55
        Align = alClient
        Alignment = taCenter
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          '')
        ParentColor = True
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        WantReturns = False
        WordWrap = False
        StyleElements = [seFont, seClient]
        OnEnter = MmoHotKeysEnter
        OnExit = MmoHotKeysExit
        OnMouseEnter = MmoHotKeysEnter
        OnMouseLeave = MmoHotKeysExit
      end
    end
    object BtnClean: TButton [3]
      Left = 10
      Top = 113
      Width = 94
      Height = 26
      Caption = 'Clean'
      ImageIndex = 6
      TabOrder = 1
      TabStop = False
      StyleElements = [seFont, seClient]
      OnClick = BtnCleanClick
    end
    object CmbDetect: TPGComboBox [4]
      Left = 175
      Top = 115
      Width = 96
      Height = 21
      Hint = 'Forma de detectar a HotKey'
      Style = csDropDownList
      Color = clSilver
      ItemIndex = 0
      TabOrder = 2
      Text = 'Down'
      StyleElements = [seFont, seClient]
      OnChange = CmbDetectChange
      Items.Strings = (
        'Down'
        'Press'
        'Up'
        'Wheel')
    end
    object CkbInhibit: TCheckBoxEx [5]
      Left = 295
      Top = 109
      Width = 98
      Height = 17
      Hint = 'Bloqueia a tecla detectada'
      Caption = 'Inhibit last key'
      TabOrder = 3
      StyleElements = [seFont, seClient]
      OnClick = CkbInhibitClick
    end
    object CkbEnable: TCheckBoxEx
      Left = 295
      Top = 129
      Width = 97
      Height = 17
      Caption = 'Enable'
      TabOrder = 5
      StyleElements = [seFont, seClient]
      OnClick = CkbEnableClick
    end
  end
  inherited sptAbout: TPanel
    Top = 307
    TabOrder = 3
    ExplicitTop = 297
  end
end
