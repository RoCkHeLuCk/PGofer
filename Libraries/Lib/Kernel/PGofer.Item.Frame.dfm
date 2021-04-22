object PGFrame: TPGFrame
  Left = 0
  Top = 0
  Width = 400
  Height = 89
  AutoScroll = True
  Constraints.MinWidth = 400
  TabOrder = 0
  object SplitterItem: TSplitter
    Left = 0
    Top = 35
    Width = 400
    Height = 8
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
    ExplicitLeft = 12
    ExplicitTop = 85
  end
  object grbAbout: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 46
    Width = 394
    Height = 40
    Align = alBottom
    Caption = 'About'
    Constraints.MinHeight = 40
    TabOrder = 0
    object rceAbout: TRichEdit
      Left = 2
      Top = 15
      Width = 390
      Height = 23
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = True
      ParentFont = False
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
    Align = alClient
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
      Caption = 'Title:'
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
