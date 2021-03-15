object FrmConsole: TFrmConsole
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Console'
  ClientHeight = 80
  ClientWidth = 200
  Color = clBtnFace
  Constraints.MinHeight = 80
  Constraints.MinWidth = 200
  DefaultMonitor = dmDesktop
  DoubleBuffered = True
  ParentFont = True
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PnlConsole: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 80
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    OnMouseDown = PnlArrastarMouseDown
    OnMouseMove = PnlArrastarMouseMove
    object PnlArrastar: TPanel
      Left = 0
      Top = 0
      Width = 200
      Height = 12
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      OnMouseDown = PnlArrastarMouseDown
      OnMouseMove = PnlArrastarMouseMove
      DesignSize = (
        200
        12)
      object BtnFixed: TSpeedButton
        AlignWithMargins = True
        Left = 183
        Top = 0
        Width = 15
        Height = 13
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        AllowAllUp = True
        Anchors = [akTop, akRight]
        GroupIndex = 1
        Glyph.Data = {
          D2040000424DD20400000000000036040000280000000A0000000D0000000100
          0800000000009C00000000000000000000000001000000000000000000000000
          80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
          A6000020400000206000002080000020A0000020C0000020E000004000000040
          20000040400000406000004080000040A0000040C0000040E000006000000060
          20000060400000606000006080000060A0000060C0000060E000008000000080
          20000080400000806000008080000080A0000080C0000080E00000A0000000A0
          200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
          200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
          200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
          20004000400040006000400080004000A0004000C0004000E000402000004020
          20004020400040206000402080004020A0004020C0004020E000404000004040
          20004040400040406000404080004040A0004040C0004040E000406000004060
          20004060400040606000406080004060A0004060C0004060E000408000004080
          20004080400040806000408080004080A0004080C0004080E00040A0000040A0
          200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
          200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
          200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
          20008000400080006000800080008000A0008000C0008000E000802000008020
          20008020400080206000802080008020A0008020C0008020E000804000008040
          20008040400080406000804080008040A0008040C0008040E000806000008060
          20008060400080606000806080008060A0008060C0008060E000808000008080
          20008080400080806000808080008080A0008080C0008080E00080A0000080A0
          200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
          200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
          200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
          2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
          2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
          2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
          2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
          2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
          2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
          2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00070707070707
          07070707000007070707075B07070707000007070707075B0707070700000707
          0707075B07070707000007070707075B07070707000007075B5B5B5B5B5B5B07
          00000707075BFFFF5B5B070700000707075BFFFF5B5B070700000707075BFFFF
          5B5B070700000707075BFFFF5B5B070700000707075B5B5B5B5B070700000707
          07070707070707070000070707070707070707070000}
        Margin = 0
        Spacing = 0
        OnClick = BtnFixedClick
        ExplicitLeft = 142
      end
      object PnlArrastar2: TPanel
        Left = 3
        Top = 4
        Width = 177
        Height = 4
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        Color = clBtnShadow
        ParentBackground = False
        TabOrder = 0
        OnMouseDown = PnlArrastarMouseDown
        OnMouseMove = PnlArrastarMouseMove
      end
    end
    object EdtConsole: TSynEdit
      Left = 0
      Top = 12
      Width = 200
      Height = 68
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = True
      TabOrder = 1
      OnKeyPress = FormKeyPress
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
      Options = [eoAutoIndent, eoDragDropEditing, eoEnhanceEndKey, eoGroupUndo, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabsToSpaces]
      ReadOnly = True
      ScrollBars = ssVertical
      WantTabs = True
      FontSmoothing = fsmNone
    end
  end
  object TmrConsole: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = TmrConsoleTimer
    Left = 48
    Top = 20
  end
end
