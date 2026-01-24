inherited PGConsoleFrame: TPGConsoleFrame
  Height = 337
  ExplicitHeight = 337
  inherited grbAbout: TGroupBox
    Top = 283
    Height = 44
    Constraints.MinHeight = 44
    ExplicitTop = 283
    ExplicitHeight = 44
    inherited rceAbout: TRichEdit
      Height = 27
      ExplicitHeight = 27
    end
  end
  inherited pnlItem: TPanel
    Height = 280
    ExplicitHeight = 280
    object lblDelay: TLabel [8]
      Left = 5
      Top = 257
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Delay:'
    end
    inherited CkbEnabled: TCheckBox
      Width = 101
      ExplicitWidth = 101
    end
    inherited CmbWindowState: TComboBox
      ParentColor = True
    end
    inherited EdtAlphaBlendValue: TEditEx
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited EdtHeigth: TEditEx
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited EdtTop: TEditEx
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited EdtWidth: TEditEx
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited EdtLeft: TEditEx
      StyleElements = [seFont, seClient, seBorder]
    end
    object edtDelay: TEditEx [23]
      Left = 70
      Top = 254
      Width = 51
      Height = 21
      Color = clSilver
      TabOrder = 14
      Text = '0'
      OnExit = edtDelayExit
    end
    object updDelay: TUpDown [24]
      Left = 121
      Top = 254
      Width = 16
      Height = 21
      Associate = edtDelay
      Max = 255
      TabOrder = 15
      OnChanging = updDelayChanging
    end
    object ckbShowMessage: TCheckBox [25]
      Left = 160
      Top = 256
      Width = 114
      Height = 17
      Caption = 'ShowMessage'
      TabOrder = 16
      OnClick = ckbShowMessageClick
    end
    object ckbAutoClose: TCheckBox [26]
      Left = 294
      Top = 256
      Width = 101
      Height = 17
      Caption = 'AutoClose'
      TabOrder = 17
      OnClick = ckbAutoCloseClick
    end
    inherited EdtName: TEditEx
      TabOrder = 18
    end
  end
  inherited sptAbout: TPanel
    Top = 330
    ExplicitTop = 330
  end
  inherited cldTrasparentColor: TColorDialog
    Left = 164
  end
end
