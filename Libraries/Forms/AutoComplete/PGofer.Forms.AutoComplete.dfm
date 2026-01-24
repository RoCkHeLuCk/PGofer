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
    Top = 89
    Width = 261
    Height = 5
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    Beveled = True
    MinSize = 20
    ExplicitTop = 5
    ExplicitWidth = 267
  end
  object ltvAutoComplete: TListViewEx
    Left = 2
    Top = 2
    Width = 261
    Height = 87
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
  object rceAbout: TRichEditEx
    Left = 2
    Top = 94
    Width = 261
    Height = 38
    Align = alBottom
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    Constraints.MinHeight = 20
    ParentColor = True
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
    Zoom = 100
    OnDblClick = rceAboutDblClick
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
