inherited PGFolderFrame: TPGFolderFrame
  Height = 149
  ExplicitHeight = 149
  inherited grbAbout: TGroupBox
    Top = 79
    Height = 60
    ExplicitTop = 79
    ExplicitHeight = 60
    inherited mmoAbout: TMemoEx
      Height = 43
      ExplicitHeight = 32
    end
  end
  inherited pnlItem: TPanel
    Height = 56
    ExplicitHeight = 56
    DesignSize = (
      400
      56)
    object CkbNamespace: TCheckBoxEx [1]
      Left = 70
      Top = 33
      Width = 97
      Height = 17
      Caption = 'Namespace'
      TabOrder = 1
      OnClick = CkbNamespaceClick
    end
  end
  inherited sptAbout: TPanel
    Top = 142
    ExplicitTop = 131
  end
end
