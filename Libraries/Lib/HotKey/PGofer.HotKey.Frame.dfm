inherited PGFrameHotKey: TPGFrameHotKey
  Width = 409
  Height = 388
  Constraints.MinHeight = 250
  OnExit = MmoTeclasExit
  ExplicitWidth = 409
  ExplicitHeight = 388
  inherited SplitterItem: TSplitter
    Top = 280
    Width = 409
    ExplicitTop = 34
    ExplicitWidth = 393
  end
  inherited grbAbout: TGroupBox
    Top = 291
    Width = 403
    Height = 94
    ExplicitTop = 357
    ExplicitWidth = 400
    ExplicitHeight = 103
    inherited rceAbout: TRichEdit
      Width = 399
      Height = 77
      ExplicitWidth = 396
      ExplicitHeight = 86
    end
  end
  inherited pnlItem: TPanel
    Width = 409
    Height = 280
    Constraints.MinHeight = 280
    Constraints.MinWidth = 0
    ExplicitWidth = 409
    ExplicitHeight = 280
    DesignSize = (
      409
      280)
    object LblDetectar: TLabel [1]
      Left = 123
      Top = 118
      Width = 46
      Height = 13
      Hint = 'Forma de detectar a HotKey'
      Caption = 'Detectar:'
    end
    inherited EdtName: TEditEx
      Width = 340
      ExplicitWidth = 340
    end
    object GrbTeclas: TGroupBox
      Left = 5
      Top = 33
      Width = 398
      Height = 72
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Teclas'
      TabOrder = 1
      object MmoTeclas: TMemo
        Left = 2
        Top = 15
        Width = 394
        Height = 55
        ParentCustomHint = False
        Align = alClient
        Alignment = taCenter
        BevelInner = bvNone
        BevelOuter = bvNone
        Ctl3D = False
        DoubleBuffered = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Lines.Strings = (
          '')
        ParentColor = True
        ParentCtl3D = False
        ParentDoubleBuffered = False
        ParentFont = False
        ParentShowHint = False
        PopupMenu = PpmNull
        ReadOnly = True
        ShowHint = False
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
      Left = 308
      Top = 117
      Width = 83
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
      Width = 398
      Height = 131
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Script'
      TabOrder = 5
      ExplicitHeight = 124
      object EdtScript: TSynEdit
        AlignWithMargins = True
        Left = 5
        Top = 18
        Width = 388
        Height = 108
        Hint = 'Programa'#231#227'o que ser'#225' executada'
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 0
        CodeFolding.GutterShapeSize = 11
        CodeFolding.CollapsedLineColor = clGrayText
        CodeFolding.FolderBarLinesColor = clGrayText
        CodeFolding.IndentGuidesColor = clGray
        CodeFolding.IndentGuides = True
        CodeFolding.ShowCollapsedLine = False
        CodeFolding.ShowHintMark = True
        UseCodeFolding = False
        Gutter.AutoSize = True
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 1
        Gutter.ShowLineNumbers = True
        OnChange = EdtScriptChange
        FontSmoothing = fsmNone
        ExplicitWidth = 379
        ExplicitHeight = 101
      end
    end
  end
  object PpmNull: TPopupMenu
    OwnerDraw = True
    Left = 245
    Top = 65
  end
end
