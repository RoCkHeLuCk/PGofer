inherited PGFrameVariants: TPGFrameVariants
  Height = 175
  ExplicitHeight = 175
  inherited SplitterItem: TSplitter
    Top = 61
    ExplicitTop = 61
  end
  inherited grbAbout: TGroupBox
    Top = 72
    ExplicitTop = 72
  end
  inherited pnlItem: TPanel
    Height = 61
    Constraints.MinHeight = 60
    Constraints.MinWidth = 0
    ExplicitHeight = 61
    object LblValue: TLabel [1]
      Left = 36
      Top = 36
      Width = 28
      Height = 13
      Caption = 'Valor:'
    end
    object edtValue: TEdit
      Left = 70
      Top = 33
      Width = 324
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnChange = edtValueChange
    end
  end
end
