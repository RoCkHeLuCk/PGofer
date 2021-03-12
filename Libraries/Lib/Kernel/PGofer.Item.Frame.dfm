object PGFrame: TPGFrame
  Left = 0
  Top = 0
  Width = 400
  Height = 149
  AutoScroll = True
  Constraints.MinWidth = 400
  TabOrder = 0
  object SplitterItem: TSplitter
    Left = 0
    Top = 35
    Width = 400
    Height = 8
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ExplicitTop = 216
  end
  object grbAbout: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 46
    Width = 394
    Height = 100
    Align = alClient
    Caption = 'Sobre'
    Constraints.MinHeight = 100
    TabOrder = 0
    object rceAbout: TRichEdit
      Left = 2
      Top = 15
      Width = 390
      Height = 83
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      ParentColor = True
      PlainText = True
      ReadOnly = True
      TabOrder = 0
      Zoom = 100
    end
  end
  object pnlItem: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    Constraints.MinHeight = 35
    Constraints.MinWidth = 400
    ParentColor = True
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      400
      35)
    object LblName: TLabel
      Left = 3
      Top = 9
      Width = 61
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Titulo:'
    end
    object EdtName: TEditEx
      Left = 70
      Top = 6
      Width = 325
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      TabOrder = 0
      OnKeyUp = EdtNameKeyUp
      RegExamples = reNone
      RegExpression = '^[A-Za-z_]+\w*$'
    end
  end
end
