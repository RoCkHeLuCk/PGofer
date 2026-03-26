inherited PGFolderFrame: TPGFolderFrame
  Height = 138
  ExplicitHeight = 138
  inherited grbAbout: TGroupBox
    Top = 59
    Height = 69
    TabOrder = 1
    ExplicitTop = 59
    ExplicitHeight = 69
    inherited rceAbout: TRichEdit
      Height = 52
      ExplicitHeight = 52
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
      StyleElements = [seFont, seClient]
      OnClick = CkbNamespaceClick
    end
  end
  inherited sptAbout: TPanel
    Top = 131
    TabOrder = 2
    ExplicitTop = 131
  end
end
