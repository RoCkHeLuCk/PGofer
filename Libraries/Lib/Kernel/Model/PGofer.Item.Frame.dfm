object PGItemFrame: TPGItemFrame
  Left = 0
  Top = 0
  Width = 400
  Height = 105
  Margins.Left = 0
  Margins.Top = 0
  Margins.Right = 0
  Margins.Bottom = 0
  Anchors = [akLeft, akTop, akRight]
  Constraints.MinWidth = 400
  Color = clGray
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object grbAbout: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 35
    Width = 394
    Height = 60
    Align = alClient
    Caption = 'About'
    Constraints.MinHeight = 60
    TabOrder = 2
    object rceAbout: TRichEdit
      Left = 2
      Top = 15
      Width = 390
      Height = 43
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'Courier New'
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
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    Constraints.MinWidth = 400
    ParentColor = True
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      400
      32)
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
      Color = clSilver
      TabOrder = 0
      RegExBlockInvalidKeys = True
      RegExExpression = '^[A-Za-z_][A-Za-z0-9_]*$'
      OnAfterValidate = EdtNameAfterValidate
    end
  end
  object sptAbout: TPanel
    Left = 0
    Top = 98
    Width = 400
    Height = 7
    Cursor = crVSplit
    Align = alBottom
    BevelEdges = [beTop, beBottom]
    BevelInner = bvLowered
    BevelKind = bkSoft
    BevelOuter = bvLowered
    Constraints.MaxHeight = 7
    Constraints.MinHeight = 7
    UseDockManager = False
    FullRepaint = False
    Locked = True
    ParentColor = True
    ShowCaption = False
    TabOrder = 1
    OnMouseDown = sptAboutMouseDown
    OnMouseMove = sptAboutMouseMove
    OnMouseUp = sptAboutMouseUp
  end
end
