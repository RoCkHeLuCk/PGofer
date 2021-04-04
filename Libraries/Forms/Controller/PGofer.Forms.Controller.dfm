object FrmController: TFrmController
  Left = 480
  Top = 386
  BorderStyle = bsSizeToolWin
  Caption = 'Controller'
  ClientHeight = 137
  ClientWidth = 585
  Color = clBtnFace
  Constraints.MinHeight = 165
  Constraints.MinWidth = 190
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
  object Splitter1: TSplitter
    Left = 180
    Top = 0
    Width = 5
    Height = 137
    Beveled = True
    ExplicitLeft = 241
    ExplicitHeight = 536
  end
  object PnlTreeView: TPanel
    Left = 0
    Top = 0
    Width = 180
    Height = 137
    Align = alLeft
    Constraints.MinWidth = 180
    ParentColor = True
    TabOrder = 0
    object PnlFind: TPanel
      Left = 1
      Top = 1
      Width = 178
      Height = 28
      Align = alTop
      Constraints.MinWidth = 178
      ParentColor = True
      TabOrder = 0
      DesignSize = (
        178
        28)
      object EdtFind: TButtonedEdit
        Left = 3
        Top = 3
        Width = 146
        Height = 21
        Anchors = [akLeft, akTop, akRight, akBottom]
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
      end
      object BtnRecall: TButton
        Left = 151
        Top = 3
        Width = 26
        Height = 23
        Anchors = [akTop, akRight, akBottom]
        Caption = '>>'
        TabOrder = 1
        OnClick = BtnRecallClick
      end
    end
    object PnlButton: TPanel
      Left = 1
      Top = 100
      Width = 178
      Height = 36
      Align = alBottom
      Constraints.MinWidth = 178
      ParentColor = True
      TabOrder = 1
      object BtnAlphaSort: TButton
        Left = 2
        Top = 2
        Width = 43
        Height = 32
        Caption = 'AZ'
        DropDownMenu = PpmAlphaSort
        Style = bsSplitButton
        TabOrder = 0
        WordWrap = True
        OnClick = MniAZClick
      end
      object BtnCreate: TButton
        Left = 108
        Top = 2
        Width = 69
        Height = 32
        Caption = 'Create'
        DropDownMenu = PpmCreate
        Style = bsSplitButton
        TabOrder = 1
        Visible = False
        WordWrap = True
        OnClick = onCreateItemPopUpClick
      end
      object BtnEdit: TButton
        Left = 46
        Top = 2
        Width = 61
        Height = 32
        Caption = 'Edit'
        DropDownMenu = PpmEdit
        Style = bsSplitButton
        TabOrder = 2
        WordWrap = True
        OnClick = MniDeleteClick
      end
    end
    object TrvController: TTreeViewEx
      Left = 1
      Top = 29
      Width = 178
      Height = 71
      Align = alClient
      Constraints.MinHeight = 70
      Constraints.MinWidth = 178
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
      OnDragDrop = TrvControllerDragDrop
      OnDragOver = TrvControllerDragOver
      OnGetSelectedIndex = TrvControllerGetSelectedIndex
      OnKeyUp = TrvControllerKeyUp
      OnMouseDown = TrvControllerMouseDown
      OwnsObjectsData = True
      AttachMode = naAdd
      OnDropFiles = TrvControllerDropFiles
    end
  end
  object PnlFrame: TPanel
    Left = 185
    Top = 0
    Width = 400
    Height = 137
    Align = alClient
    Caption = 'Nenhum item selecionado!'
    Constraints.MinHeight = 135
    Constraints.MinWidth = 400
    ParentColor = True
    TabOrder = 1
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
