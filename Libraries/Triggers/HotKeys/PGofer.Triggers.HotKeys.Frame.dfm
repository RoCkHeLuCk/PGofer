inherited PGFrameHotKey: TPGFrameHotKey
  Height = 304
  OnExit = MmoHotKeysExit
  ExplicitHeight = 304
  object sptScript: TSplitter [0]
    Left = 0
    Top = 225
    Width = 400
    Height = 6
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ExplicitTop = 176
  end
  inherited grbAbout: TGroupBox
    Top = 234
    TabOrder = 2
    ExplicitTop = 234
  end
  inherited pnlItem: TPanel
    Height = 145
    ExplicitHeight = 145
    DesignSize = (
      400
      145)
    object LblDetect: TLabel [1]
      Left = 110
      Top = 118
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a HotKey'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Detect:'
      ParentBiDiMode = False
    end
    object GrbHotKeys: TGroupBox [2]
      Left = 5
      Top = 33
      Width = 389
      Height = 72
      Anchors = [akLeft, akTop, akRight]
      Caption = 'HotKeys'
      TabOrder = 0
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
        PopupMenu = PpmNull
        ReadOnly = True
        TabOrder = 0
        WantReturns = False
        WordWrap = False
        StyleElements = []
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
      OnClick = BtnCleanClick
    end
    object CmbDetect: TComboBox [4]
      Left = 175
      Top = 115
      Width = 96
      Height = 21
      Hint = 'Forma de detectar a HotKey'
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 2
      Text = 'Down'
      OnChange = CmbDetectChange
      Items.Strings = (
        'Down'
        'Press'
        'Up'
        'Wheel')
    end
    object CkbInhibit: TCheckBox [5]
      Left = 295
      Top = 117
      Width = 98
      Height = 17
      Hint = 'Bloqueia a tecla detectada'
      Caption = 'Inhibit last key'
      TabOrder = 3
      OnClick = CkbInhibitClick
    end
    inherited EdtName: TEditEx
      Width = 324
      TabOrder = 4
      ExplicitWidth = 324
    end
  end
  object GrbScript: TGroupBox [3]
    AlignWithMargins = True
    Left = 3
    Top = 148
    Width = 394
    Height = 74
    Align = alTop
    Caption = 'Script (Run: F9)'
    Constraints.MinHeight = 60
    TabOrder = 0
    object EdtScript: TRichEditEx
      Left = 2
      Top = 15
      Width = 390
      Height = 57
      Align = alClient
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
  inherited sptAbout: TPanel
    Top = 297
    TabOrder = 3
    ExplicitTop = 297
  end
  object PpmNull: TPopupMenu
    OwnerDraw = True
    Left = 245
    Top = 65
  end
end
