object FrmPGofer: TFrmPGofer
  Left = 0
  Top = 0
  Margins.Left = 0
  Margins.Top = 0
  Margins.Right = 0
  Margins.Bottom = 0
  BorderStyle = bsNone
  Caption = 'PGofer V3.0'
  ClientHeight = 30
  ClientWidth = 200
  Color = clBtnFace
  Constraints.MinHeight = 30
  Constraints.MinWidth = 200
  DefaultMonitor = dmDesktop
  DoubleBuffered = True
  ParentFont = True
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  ScreenSnap = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PnlCommand: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 30
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    BevelOuter = bvNone
    Ctl3D = True
    ParentColor = True
    ParentCtl3D = False
    TabOrder = 0
    OnMouseDown = PnlArrastarMouseDown
    OnMouseMove = PnlArrastarMouseMove
    object PnlComandMove: TPanel
      Left = 0
      Top = 0
      Width = 10
      Height = 30
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alLeft
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      OnMouseDown = PnlArrastarMouseDown
      OnMouseMove = PnlArrastarMouseMove
      ExplicitHeight = 62
      DesignSize = (
        10
        30)
      object PnlArrastar: TPanel
        Left = 4
        Top = 3
        Width = 3
        Height = 24
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        Color = clSilver
        ParentBackground = False
        TabOrder = 0
        OnMouseDown = PnlArrastarMouseDown
        OnMouseMove = PnlArrastarMouseMove
      end
    end
    object EdtCommand: TSynEdit
      AlignWithMargins = True
      Left = 12
      Top = 2
      Width = 186
      Height = 26
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      TabOrder = 0
      OnKeyDown = FormKeyDown
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
      Gutter.Visible = False
      Gutter.Width = 0
      InsertCaret = ctHorizontalLine
      Options = [eoAutoIndent, eoDragDropEditing, eoDropFiles, eoEnhanceEndKey, eoGroupUndo, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabsToSpaces]
      ScrollBars = ssNone
      WantTabs = True
      OnChange = EdtCommandChange
      FontSmoothing = fsmNone
    end
  end
  object TryPGofer: TTrayIcon
    Hint = 'PGofer V3.0'
    PopupMenu = PpmMenu
    Visible = True
    OnClick = TryPGoferClick
    OnDblClick = TryPGoferClick
    Left = 40
    Top = 1
  end
  object PpmMenu: TPopupMenu
    Left = 68
    Top = 1
    object mniClose: TMenuItem
      Caption = 'Close'
      Hint = 'FrmPGofer.Close;'
      ShortCut = 32883
      OnClick = PopUpClick
    end
  end
end
