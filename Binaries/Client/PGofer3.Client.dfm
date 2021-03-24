object FrmPGofer: TFrmPGofer
  Left = 80
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'PGofer V3.0'
  ClientHeight = 30
  ClientWidth = 200
  Color = clBtnFace
  Constraints.MinHeight = 30
  Constraints.MinWidth = 200
  DefaultMonitor = dmDesktop
  ParentFont = True
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PnlCommand: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 30
    Align = alClient
    ParentColor = True
    TabOrder = 0
    OnMouseDown = PnlArrastarMouseDown
    OnMouseMove = PnlArrastarMouseMove
    object PnlComandMove: TPanel
      Left = 1
      Top = 1
      Width = 9
      Height = 28
      Align = alLeft
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      OnMouseDown = PnlArrastarMouseDown
      OnMouseMove = PnlArrastarMouseMove
      object PnlArrastar: TPanel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 4
        Height = 22
        Margins.Right = 2
        Align = alClient
        BevelOuter = bvNone
        Color = clBtnShadow
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        OnMouseDown = PnlArrastarMouseDown
        OnMouseMove = PnlArrastarMouseMove
      end
    end
    object EdtCommand: TSynEdit
      AlignWithMargins = True
      Left = 13
      Top = 3
      Width = 183
      Height = 24
      Margins.Top = 2
      Margins.Bottom = 2
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = True
      TabOrder = 0
      OnKeyDown = EdtCommandKeyDown
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
      OnDropFiles = EdtCommandDropFiles
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
    object mniTriggers: TMenuItem
      Caption = 'Triggers'
      Hint = 'FrmTriggers;'
      OnClick = PopUpClick
    end
    object mniGlobals: TMenuItem
      Caption = 'Globals'
      Hint = 'FrmGlobals;'
      OnClick = PopUpClick
    end
    object mniN1: TMenuItem
      Caption = '-'
    end
    object mniClose: TMenuItem
      Caption = 'Close'
      Hint = 'FrmPGofer.Close;'
      ShortCut = 32883
      OnClick = PopUpClick
    end
  end
end
