inherited PGFrameHotKey: TPGFrameHotKey
  Width = 401
  Height = 388
  Constraints.MinHeight = 250
  OnExit = MmoTeclasExit
  ExplicitWidth = 401
  ExplicitHeight = 388
  inherited SplitterItem: TSplitter
    Top = 280
    Width = 401
    ExplicitTop = 34
    ExplicitWidth = 393
  end
  inherited grbAbout: TGroupBox
    Top = 291
    Width = 395
    Height = 94
    Constraints.MinHeight = 94
    ExplicitTop = 291
    ExplicitWidth = 395
    ExplicitHeight = 94
    inherited rceAbout: TRichEdit
      Width = 391
      Height = 77
      ExplicitWidth = 391
      ExplicitHeight = 77
    end
  end
  inherited pnlItem: TPanel
    Width = 401
    Height = 280
    Constraints.MinHeight = 280
    Constraints.MinWidth = 0
    ExplicitWidth = 401
    ExplicitHeight = 280
    DesignSize = (
      401
      280)
    object LblDetectar: TLabel [1]
      Left = 110
      Top = 118
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a HotKey'
      AutoSize = False
      BiDiMode = bdRightToLeft
      Caption = 'Detectar:'
      ParentBiDiMode = False
    end
    inherited EdtName: TEditEx
      Width = 326
      ExplicitWidth = 326
    end
    object GrbTeclas: TGroupBox
      Left = 5
      Top = 33
      Width = 390
      Height = 72
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Teclas'
      TabOrder = 1
      object MmoTeclas: TMemo
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
        OnEnter = MmoTeclasEnter
        OnExit = MmoTeclasExit
        OnMouseEnter = MmoTeclasEnter
        OnMouseLeave = MmoTeclasExit
      end
    end
    object BtnClear: TButton
      Left = 10
      Top = 113
      Width = 94
      Height = 26
      Caption = 'Limpar'
      ImageIndex = 6
      TabOrder = 2
      TabStop = False
      OnClick = BtnClearClick
    end
    object CmbDetectar: TComboBox
      Left = 175
      Top = 115
      Width = 96
      Height = 21
      Hint = 'Forma de detectar a HotKey'
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 3
      Text = 'Pressionar'
      OnChange = CmbDetectarChange
      Items.Strings = (
        'Pressionar'
        'Pressionado'
        'Soltar'
        'Wheel')
    end
    object CkbInibir: TCheckBox
      Left = 295
      Top = 117
      Width = 98
      Height = 17
      Hint = 'Bloqueia a tecla detectada'
      Caption = 'Inibir Teclas'
      TabOrder = 4
      OnClick = CkbInibirClick
    end
    object GrbScript: TGroupBox
      AlignWithMargins = True
      Left = 5
      Top = 145
      Width = 390
      Height = 131
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Script'
      TabOrder = 5
      object EdtScript: TSynEdit
        AlignWithMargins = True
        Left = 5
        Top = 18
        Width = 380
        Height = 108
        Hint = 'Programa'#231#227'o que ser'#225' executada'
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = True
        TabOrder = 0
        OnKeyUp = EdtScriptKeyUp
        CodeFolding.GutterShapeSize = 11
        CodeFolding.CollapsedLineColor = clGrayText
        CodeFolding.FolderBarLinesColor = clGrayText
        CodeFolding.IndentGuidesColor = clGray
        CodeFolding.IndentGuides = True
        CodeFolding.ShowCollapsedLine = False
        CodeFolding.ShowHintMark = True
        UseCodeFolding = False
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 1
        Gutter.ShowLineNumbers = True
        Gutter.UseFontStyle = False
        WantTabs = True
        WordWrap = True
        WordWrapGlyph.Visible = False
        FontSmoothing = fsmNone
        RemovedKeystrokes = <>
        AddedKeystrokes = <
          item
            Command = ecAutoCompletion
            ShortCut = 16416
          end>
      end
    end
  end
  object PpmNull: TPopupMenu
    OwnerDraw = True
    Left = 245
    Top = 65
  end
end
