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
      object btnRecall: TButton
        Left = 151
        Top = 3
        Width = 26
        Height = 23
        Anchors = [akTop, akRight, akBottom]
        Caption = '>>'
        TabOrder = 1
        OnClick = btnRecallClick
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
      object btnAlphaSort: TButton
        Left = 2
        Top = 2
        Width = 43
        Height = 32
        Caption = 'AZ'
        DropDownMenu = ppmAlphaSort
        Style = bsSplitButton
        TabOrder = 0
        WordWrap = True
        OnClick = mniAZClick
      end
      object btnCreate: TButton
        Left = 46
        Top = 2
        Width = 69
        Height = 32
        Caption = 'Create'
        DropDownMenu = ppmCreate
        Style = bsSplitButton
        TabOrder = 1
        Visible = False
        WordWrap = True
        OnClick = onCreateItemPopUpClick
      end
      object btnDelete: TButton
        Left = 116
        Top = 3
        Width = 61
        Height = 31
        Caption = 'Delete'
        TabOrder = 2
        Visible = False
        WordWrap = True
        OnClick = btnDeleteClick
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
      ReadOnly = True
      RightClickSelect = True
      RowSelect = True
      TabOrder = 2
      OnCompare = TrvControllerCompare
      OnDragDrop = TrvControllerDragDrop
      OnDragOver = TrvControllerDragOver
      OnGetSelectedIndex = TrvControllerGetSelectedIndex
      OwnsObjectsData = True
      AttachMode = naAdd
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
  object ppmAlphaSort: TPopupMenu
    Left = 12
    Top = 36
    object mniAZ: TMenuItem
      Caption = 'AZ'
      OnClick = mniAZClick
    end
    object mniZA: TMenuItem
      Caption = 'ZA'
      OnClick = mniZAClick
    end
    object mniN1: TMenuItem
      Caption = '-'
    end
    object mniAlphaSortFolder: TMenuItem
      Caption = 'Pastas Primeiro'
      Checked = True
      OnClick = mniAlphaSortFolderClick
    end
  end
  object ppmCreate: TPopupMenu
    Left = 44
    Top = 36
  end
end
