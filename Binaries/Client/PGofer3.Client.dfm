object FrmPGofer: TFrmPGofer
  Left = 80
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'PGofer V3.0'
  ClientHeight = 40
  ClientWidth = 200
  Color = clBtnFace
  Constraints.MinHeight = 40
  Constraints.MinWidth = 200
  DefaultMonitor = dmDesktop
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Courier New'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 18
  object PnlCommand: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 40
    Align = alClient
    ParentColor = True
    TabOrder = 0
    OnMouseDown = PnlArrastarMouseDown
    OnMouseMove = PnlArrastarMouseMove
    ExplicitHeight = 36
    object PnlComandMove: TPanel
      Left = 1
      Top = 1
      Width = 9
      Height = 38
      Align = alLeft
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      OnMouseDown = PnlArrastarMouseDown
      OnMouseMove = PnlArrastarMouseMove
      ExplicitHeight = 28
      object PnlArrastar: TPanel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 4
        Height = 32
        Margins.Right = 2
        Align = alClient
        BevelOuter = bvNone
        Color = clBtnShadow
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        OnMouseDown = PnlArrastarMouseDown
        OnMouseMove = PnlArrastarMouseMove
        ExplicitHeight = 22
      end
    end
    object EdtCommand: TSynEdit
      AlignWithMargins = True
      Left = 13
      Top = 3
      Width = 183
      Height = 34
      Margins.Top = 2
      Margins.Bottom = 2
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Courier New'
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
      FontSmoothing = fsmNone
      ExplicitHeight = 30
      RemovedKeystrokes = <>
      AddedKeystrokes = <
        item
          Command = ecAutoCompletion
          ShortCut = 16416
        end>
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
