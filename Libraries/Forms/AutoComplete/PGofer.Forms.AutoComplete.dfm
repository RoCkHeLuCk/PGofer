object FrmAutoComplete: TFrmAutoComplete
  Left = 960
  Top = 154
  Margins.Left = 0
  Margins.Top = 0
  Margins.Right = 0
  Margins.Bottom = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'FrmAutoComplete'
  ClientHeight = 134
  ClientWidth = 265
  Color = clGray
  Constraints.MinHeight = 80
  Constraints.MinWidth = 260
  Ctl3D = False
  DefaultMonitor = dmDesktop
  ParentFont = True
  FormStyle = fsStayOnTop
  KeyPreview = True
  Padding.Left = 2
  Padding.Top = 2
  Padding.Right = 2
  Padding.Bottom = 2
  OldCreateOrder = True
  PopupMenu = ppmAutoComplete
  Position = poDefault
  StyleElements = [seFont, seClient]
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object sptAbout: TSplitter
    Left = 2
    Top = 88
    Width = 261
    Height = 6
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    Beveled = True
    MinSize = 20
    StyleElements = [seFont, seClient]
    ExplicitTop = 86
  end
  object ltvAutoComplete: TListViewEx
    Left = 2
    Top = 2
    Width = 261
    Height = 86
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    Color = clSilver
    Columns = <
      item
        Caption = 'Command'
        Width = 100
      end
      item
        Caption = 'Origin'
        Width = 100
      end
      item
        Caption = 'Priority'
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    PopupMenu = ppmAutoComplete
    ShowWorkAreas = True
    SortType = stText
    TabOrder = 0
    ViewStyle = vsReport
    OnCompare = ltvAutoCompleteCompare
    OnDblClick = ltvAutoCompleteDblClick
    OnKeyDown = FormKeyDown
    OnKeyPress = FormKeyPress
    OnKeyUp = FormKeyUp
    OnMouseDown = ltvAutoCompleteMouseDown
    ColumnAlphaSort = True
  end
  object mmoAbout: TMemoEx
    Left = 2
    Top = 94
    Width = 261
    Height = 38
    Align = alBottom
    BevelInner = bvNone
    BevelOuter = bvNone
    Constraints.MinHeight = 20
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentColor = True
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
    OnClick = mmoAboutDblClick
  end
  object ppmAutoComplete: TPopupMenu
    Left = 24
    Top = 24
    object mniPriority: TMenuItem
      Caption = 'Alterar Prioridade'
      ShortCut = 16449
      OnClick = mniPriorityClick
    end
  end
  object trmAutoComplete: TTimer
    Enabled = False
    Interval = 500
    OnTimer = trmAutoCompleteTimer
    Left = 52
    Top = 24
  end
end
