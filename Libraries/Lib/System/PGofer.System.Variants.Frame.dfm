inherited PGVariantsFrame: TPGVariantsFrame
  Height = 133
  ExplicitHeight = 133
  inherited grbAbout: TGroupBox
    Top = 63
    ExplicitTop = 63
  end
  inherited pnlItem: TPanel
    Height = 60
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
      Width = 325
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      Constraints.MinWidth = 325
      TabOrder = 0
      OnKeyUp = EdtValueKeyUp
    end
    inherited EdtName: TEditEx
      TabOrder = 1
    end
  end
  inherited sptAbout: TPanel
    Top = 126
    ExplicitTop = 126
  end
end
