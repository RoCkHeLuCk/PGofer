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
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = True
      ParentFont = False
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
    TabOrder = 1
    DesignSize = (
      400
      35)
    object LblName: TLabel
      Left = 34
      Top = 9
      Width = 30
      Height = 13
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
      OnChange = EdtNameChange
      RegExamples = reNone
      RegExpression = '.'
    end
  end
end
