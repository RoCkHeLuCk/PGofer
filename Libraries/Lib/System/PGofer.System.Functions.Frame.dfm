inherited PGFrameFunction: TPGFrameFunction
  Height = 241
  ExplicitHeight = 241
  inherited SplitterItem: TSplitter
    Top = 150
  end
  inherited grbAbout: TGroupBox
    Top = 161
    Height = 77
    ExplicitHeight = 94
    inherited rceAbout: TRichEdit
      Height = 60
      ExplicitHeight = 77
    end
  end
  inherited pnlItem: TPanel
    Height = 150
    Constraints.MinHeight = 150
    Constraints.MinWidth = 0
    ExplicitHeight = 150
    object GroupBox1: TGroupBox
      Left = 5
      Top = 33
      Width = 390
      Height = 113
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Conteudo'
      TabOrder = 1
      object mmoContents: TSynMemo
        Left = 2
        Top = 15
        Width = 386
        Height = 96
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 0
        OnExit = mmoContentsExit
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
        FontSmoothing = fsmNone
        ExplicitLeft = -94
        ExplicitTop = -35
        ExplicitWidth = 391
        ExplicitHeight = 207
      end
    end
  end
end
