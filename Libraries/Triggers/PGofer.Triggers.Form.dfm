inherited FrmTriggerController: TFrmTriggerController
  Caption = 'FrmTriggerController'
  ClientWidth = 672
  ExplicitWidth = 688
  PixelsPerInch = 96
  TextHeight = 13
  inherited PnlTreeView: TPanel
    inherited PnlButton: TPanel
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
        TabOrder = 2
        Visible = False
        WordWrap = True
      end
    end
    inherited TrvController: TTreeViewEx
      OnDragDrop = TrvControllerDragDrop
      OnDragOver = TrvControllerDragOver
      OnDropFiles = TrvControllerDropFiles
    end
  end
  inherited PnlFrame: TScrollBox
    Width = 487
    ExplicitWidth = 487
  end
  inherited PpmEdit: TPopupMenu
    object N1: TMenuItem
      Caption = '-'
    end
    object MniDelete: TMenuItem
      Caption = 'Delete Item'
      ShortCut = 16430
      OnClick = MniDeleteClick
    end
  end
  object PpmCreate: TPopupMenu
    Left = 96
    Top = 36
  end
end
