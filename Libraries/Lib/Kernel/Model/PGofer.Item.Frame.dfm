object PGItemFrame: TPGItemFrame
  Left = 0
  Top = 0
  Width = 400
  Height = 150
  Margins.Left = 0
  Margins.Top = 0
  Margins.Right = 0
  Margins.Bottom = 0
  Anchors = [akLeft, akTop, akRight]
  Constraints.MinWidth = 400
  ParentBackground = False
  TabOrder = 0
  object grbAbout: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 36
    Width = 394
    Height = 104
    Align = alClient
    Caption = 'About'
    Constraints.MinHeight = 60
    TabOrder = 2
    object mmoAbout: TMemoEx
      Left = 2
      Top = 35
      Width = 390
      Height = 67
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
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object PnlStatus: TFlowPanel
      Left = 2
      Top = 15
      Width = 390
      Height = 20
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      object Label1: TLabel
        Left = 0
        Top = 0
        Width = 381
        Height = 14
        Align = alTop
        AutoSize = False
        Caption = 'Label1'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object pnlItem: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    Constraints.MinWidth = 400
    ParentColor = True
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      400
      33)
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
      Top = 9
      Width = 325
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      RegExBlockInvalidKeys = True
      RegExExpression = '^[A-Za-z_][A-Za-z0-9_]*$'
      OnAfterValidate = EdtNameAfterValidate
      OnBeforeValidate = EdtNameBeforeValidate
    end
  end
  object sptAbout: TPanel
    Left = 0
    Top = 143
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
