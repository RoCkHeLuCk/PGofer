inherited PGFrameVariants: TPGFrameVariants
  Height = 60
  ExplicitHeight = 60
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
    TabOrder = 1
    OnChange = edtValueChange
  end
end
