object FrmController: TFrmController
  Left = 480
  Top = 386
  BorderStyle = bsSizeToolWin
  Caption = 'Controller'
  ClientHeight = 302
  ClientWidth = 689
  Color = clBtnFace
  DoubleBuffered = True
  ParentFont = True
  OldCreateOrder = False
  Position = poDesigned
  ScreenSnap = True
  ShowHint = True
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 327
    Top = 0
    Width = 5
    Height = 302
    Beveled = True
    ExplicitLeft = 241
    ExplicitHeight = 536
  end
  object PnlTreeView: TPanel
    Left = 0
    Top = 0
    Width = 327
    Height = 302
    Align = alLeft
    TabOrder = 0
    object PnlFind: TPanel
      Left = 1
      Top = 1
      Width = 325
      Height = 28
      Align = alTop
      TabOrder = 0
      DesignSize = (
        325
        28)
      object EdtFind: TButtonedEdit
        Left = 3
        Top = 3
        Width = 319
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
    end
    object PnlButton: TPanel
      Left = 1
      Top = 265
      Width = 325
      Height = 36
      Align = alBottom
      TabOrder = 1
      object btnAlphaSort: TButton
        Left = 2
        Top = 2
        Width = 43
        Height = 32
        Caption = 'AZ'
        DoubleBuffered = False
        DropDownMenu = ppmAlphaSort
        ParentDoubleBuffered = False
        Style = bsSplitButton
        TabOrder = 0
        WordWrap = True
        OnClick = mniAZClick
      end
    end
    object TrvController: TTreeViewEx
      Left = 1
      Top = 29
      Width = 325
      Height = 236
      Align = alClient
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
    Left = 332
    Top = 0
    Width = 357
    Height = 302
    Align = alClient
    Caption = 'Nenhum item selecionado!'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 1
  end
  object ppmAlphaSort: TPopupMenu
    Left = 28
    Top = 160
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
end
