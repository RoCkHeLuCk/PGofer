inherited PGFrameVariants: TPGFrameVariants
  Height = 114
  ExplicitHeight = 114
  inherited SplitterItem: TSplitter
    Top = 60
    ExplicitTop = 61
  end
  inherited grbAbout: TGroupBox
    Top = 71
  end
  inherited pnlItem: TPanel
    Height = 60
    Constraints.MinHeight = 60
    Constraints.MinWidth = 0
    ExplicitHeight = 60
    object LblValue: TLabel [0]
      Left = 5
      Top = 36
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Value:'
    end
    object EdtValue: TEdit [2]
      Left = 70
      Top = 33
      Width = 324
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = EdtValueChange
    end
    inherited EdtName: TEditEx
      TabOrder = 1
    end
  end
end
