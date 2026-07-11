inherited PGVariantsFrame: TPGVariantsFrame
  Height = 153
  ExplicitHeight = 153
  inherited grbAbout: TGroupBox
    Top = 63
    Height = 80
    ExplicitTop = 63
    ExplicitHeight = 80
    inherited mmoAbout: TMemoEx
      Height = 43
      ExplicitHeight = 43
    end
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
    object EdtValue: TEditEx [2]
      Left = 70
      Top = 33
      Width = 325
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      Constraints.MinWidth = 325
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnAfterValidate = EdtValueAfterValidate
    end
  end
  inherited sptAbout: TPanel
    Top = 146
    ExplicitTop = 146
  end
end
