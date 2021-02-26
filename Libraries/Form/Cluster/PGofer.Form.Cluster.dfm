inherited FrmCluster: TFrmCluster
  Caption = 'FrmCluster'
  PixelsPerInch = 96
  TextHeight = 13
  inherited PnlTreeView: TPanel
    inherited PnlButton: TPanel
      object btnCreate: TButton
        Left = 46
        Top = 2
        Width = 61
        Height = 32
        Caption = 'Create'
        DropDownMenu = ppmCreate
        Style = bsSplitButton
        TabOrder = 1
      end
      object btnDelete: TButton
        Left = 108
        Top = 3
        Width = 61
        Height = 31
        Caption = 'Delete'
        TabOrder = 2
        OnClick = btnDeleteClick
      end
    end
    inherited TrvController: TTreeViewEx
      DragMode = dmAutomatic
    end
  end
  inherited ppmAlphaSort: TPopupMenu
    Top = 200
  end
  object ppmCreate: TPopupMenu
    Left = 100
    Top = 200
  end
end
