object FrmController: TFrmController
  Left = 480
  Top = 386
  Margins.Left = 0
  Margins.Top = 0
  Margins.Right = 0
  Margins.Bottom = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Controller'
  ClientHeight = 261
  ClientWidth = 602
  Color = clGray
  Constraints.MinHeight = 300
  DefaultMonitor = dmDesktop
  ParentFont = True
  OldCreateOrder = False
  Position = poDesigned
  ScreenSnap = True
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SptController: TSplitter
    Left = 180
    Top = 0
    Width = 5
    Height = 261
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Beveled = True
    Visible = False
    OnCanResize = SptControllerCanResize
    OnMoved = SptControllerMoved
    ExplicitLeft = 241
    ExplicitHeight = 536
  end
  object PnlTreeView: TPanel
    Left = 0
    Top = 0
    Width = 180
    Height = 261
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alLeft
    BevelOuter = bvNone
    Constraints.MinWidth = 180
    ParentColor = True
    TabOrder = 0
    object PnlFind: TPanel
      Left = 0
      Top = 0
      Width = 180
      Height = 28
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      object EdtFind: TButtonedEdit
        AlignWithMargins = True
        Left = 2
        Top = 2
        Width = 152
        Height = 24
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 0
        Margins.Bottom = 2
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Color = clSilver
        LeftButton.DisabledImageIndex = 0
        LeftButton.Enabled = False
        LeftButton.HotImageIndex = 0
        LeftButton.ImageIndex = 0
        LeftButton.PressedImageIndex = 0
        LeftButton.Visible = True
        RightButton.DisabledImageIndex = 1
        RightButton.HotImageIndex = 1
        RightButton.ImageIndex = 1
        RightButton.PressedImageIndex = 1
        RightButton.Visible = True
        TabOrder = 0
        OnKeyPress = EdtFindKeyPress
        ExplicitHeight = 21
      end
      object BtnRecall: TButton
        AlignWithMargins = True
        Left = 155
        Top = 1
        Width = 24
        Height = 26
        Margins.Left = 1
        Margins.Top = 1
        Margins.Right = 1
        Margins.Bottom = 1
        Align = alRight
        Caption = '>>'
        TabOrder = 1
        OnClick = BtnRecallClick
      end
    end
    object PnlButton: TPanel
      Left = 0
      Top = 225
      Width = 180
      Height = 36
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alBottom
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      object BtnAlphaSort: TButton
        AlignWithMargins = True
        Left = 1
        Top = 1
        Width = 44
        Height = 34
        Margins.Left = 1
        Margins.Top = 1
        Margins.Right = 0
        Margins.Bottom = 1
        Align = alLeft
        Caption = 'AZ'
        DropDownMenu = PpmAlphaSort
        Style = bsSplitButton
        TabOrder = 0
        WordWrap = True
        OnClick = MniAZClick
      end
      object BtnCreate: TButton
        AlignWithMargins = True
        Left = 109
        Top = 1
        Width = 69
        Height = 34
        Margins.Left = 1
        Margins.Top = 1
        Margins.Right = 0
        Margins.Bottom = 1
        Align = alLeft
        Caption = 'Create'
        DropDownMenu = PpmCreate
        Style = bsSplitButton
        TabOrder = 1
        Visible = False
        WordWrap = True
        OnClick = onCreateItemPopUpClick
      end
      object BtnEdit: TButton
        AlignWithMargins = True
        Left = 46
        Top = 1
        Width = 62
        Height = 34
        Margins.Left = 1
        Margins.Top = 1
        Margins.Right = 0
        Margins.Bottom = 1
        Align = alLeft
        Caption = 'Edit'
        DropDownMenu = PpmEdit
        Style = bsSplitButton
        TabOrder = 2
        WordWrap = True
        OnClick = MniDeleteClick
      end
    end
    object TrvController: TTreeViewEx
      AlignWithMargins = True
      Left = 1
      Top = 29
      Width = 178
      Height = 195
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderWidth = 1
      Color = clSilver
      HideSelection = False
      Indent = 19
      MultiSelect = True
      MultiSelectStyle = [msControlSelect, msShiftSelect, msVisibleOnly, msSiblingOnly]
      PopupMenu = PpmConttroler
      ReadOnly = True
      RightClickSelect = True
      RowSelect = True
      TabOrder = 2
      OnCompare = TrvControllerCompare
      OnCustomDrawItem = TrvControllerCustomDrawItem
      OnDragDrop = TrvControllerDragDrop
      OnDragOver = TrvControllerDragOver
      OnExpanded = TrvControllerExpanded
      OnGetSelectedIndex = TrvControllerGetSelectedIndex
      OnKeyUp = TrvControllerKeyUp
      OnMouseDown = TrvControllerMouseDown
      OwnsObjectsData = True
      AttachMode = naAdd
      OnDropFiles = TrvControllerDropFiles
    end
  end
  object PnlFrame: TScrollBox
    Left = 185
    Top = 0
    Width = 417
    Height = 261
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    HorzScrollBar.Smooth = True
    VertScrollBar.Smooth = True
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Constraints.MinWidth = 417
    ParentBackground = True
    TabOrder = 1
    Visible = False
    OnMouseWheelDown = PnlFrameMouseWheelDown
    OnMouseWheelUp = PnlFrameMouseWheelUp
    OnResize = PnlFrameResize
  end
  object PpmAlphaSort: TPopupMenu
    Left = 12
    Top = 36
    object MniAZ: TMenuItem
      Caption = 'AZ'
      ShortCut = 16449
      OnClick = MniAZClick
    end
    object MniZA: TMenuItem
      Caption = 'ZA'
      ShortCut = 16474
      OnClick = MniZAClick
    end
    object MniN1: TMenuItem
      Caption = '-'
    end
    object MniAlphaSortFolder: TMenuItem
      Caption = 'Pastas Primeiro'
      Checked = True
      OnClick = MniAlphaSortFolderClick
    end
  end
  object PpmCreate: TPopupMenu
    OnPopup = PpmCreatePopup
    Left = 68
    Top = 36
  end
  object PpmEdit: TPopupMenu
    Left = 40
    Top = 36
    object MniExpand: TMenuItem
      Caption = 'Expand All'
      ShortCut = 16453
      OnClick = MniExpandClick
    end
    object MniUnExpand: TMenuItem
      Caption = 'UnExpand All'
      ShortCut = 16469
      OnClick = MniUnExpandClick
    end
    object MniN2: TMenuItem
      Caption = '-'
    end
    object MniDelete: TMenuItem
      Caption = 'Delete Selected'
      ShortCut = 16430
      OnClick = MniDeleteClick
    end
  end
  object PpmConttroler: TPopupMenu
    Left = 96
    Top = 36
  end
end
