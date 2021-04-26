inherited PGFrameHotKey: TPGFrameHotKey
  Width = 401
  Height = 275
  Constraints.MinHeight = 250
  OnExit = MmoHotKeysExit
  ExplicitWidth = 401
  ExplicitHeight = 275
  inherited SplitterItem: TSplitter
    Top = 221
    Width = 401
    ExplicitTop = 34
    ExplicitWidth = 393
  end
  inherited grbAbout: TGroupBox
    Top = 232
    Width = 395
    ExplicitTop = 232
    ExplicitWidth = 395
    inherited rceAbout: TRichEdit
      Width = 391
      ExplicitWidth = 391
    end
  end
  inherited pnlItem: TPanel
    Width = 401
    Height = 221
    Constraints.MinHeight = 220
    Constraints.MinWidth = 0
    ExplicitWidth = 401
    ExplicitHeight = 221
    DesignSize = (
      401
      221)
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
    inherited EdtName: TEditEx
      Width = 326
      ExplicitWidth = 326
    end
    object GrbHotKeys: TGroupBox
      Left = 5
      Top = 33
      Width = 390
      Height = 72
      Anchors = [akLeft, akTop, akRight]
      Caption = 'HotKeys'
      TabOrder = 1
      object MmoHotKeys: TMemo
        Left = 2
        Top = 15
        Width = 386
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
    object BtnClean: TButton
      Left = 10
      Top = 113
      Width = 94
      Height = 26
      Caption = 'Clean'
      ImageIndex = 6
      TabOrder = 2
      TabStop = False
      OnClick = BtnCleanClick
    end
    object CmbDetect: TComboBox
      Left = 175
      Top = 115
      Width = 96
      Height = 21
      Hint = 'Forma de detectar a HotKey'
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 3
      Text = 'Down'
      OnChange = CmbDetectChange
      Items.Strings = (
        'Down'
        'Press'
        'Up'
        'Wheel')
    end
    object CkbInhibit: TCheckBox
      Left = 295
      Top = 117
      Width = 98
      Height = 17
      Hint = 'Bloqueia a tecla detectada'
      Caption = 'Inhibit last key'
      TabOrder = 4
      OnClick = CkbInhibitClick
    end
    object GrbScript: TGroupBox
      AlignWithMargins = True
      Left = 5
      Top = 145
      Width = 390
      Height = 74
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Script (Run: F9)'
      TabOrder = 5
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
  end
  object PpmNull: TPopupMenu
    OwnerDraw = True
    Left = 245
    Top = 65
  end
end
