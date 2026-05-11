inherited PGConsoleFrame: TPGConsoleFrame
  Height = 337
  ExplicitHeight = 337
  inherited grbAbout: TGroupBox
    Top = 267
    Height = 60
    Constraints.MinHeight = 44
    ExplicitTop = 267
    ExplicitHeight = 60
    inherited mmoAbout: TMemoEx
      Height = 43
    end
  end
  inherited pnlItem: TPanel
    Height = 264
    ExplicitHeight = 264
    object lblDelay: TLabel [8]
      Left = 5
      Top = 235
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Delay:'
    end
    inherited CkbEnabled: TCheckBoxEx
      Width = 101
      ExplicitWidth = 101
    end
    inherited PnlTransparentColor: TPanel
      TabOrder = 18
    end
    inherited CmbWindowState: TPGComboBox
      ParentColor = True
      Text = ''
      ItemIndex = -1
    end
    inherited EdtHeigth: TEditEx
      TabOrder = 16
    end
    object EdtDelay: TEditEx [20]
      Left = 70
      Top = 232
      Width = 51
      Height = 21
      TabOrder = 4
      Text = '0'
      OnExit = EdtDelayExit
    end
    object updDelay: TUpDown [21]
      Left = 121
      Top = 232
      Width = 16
      Height = 21
      Associate = EdtDelay
      Max = 255
      TabOrder = 10
      OnChanging = updDelayChanging
    end
    object ckbShowMessage: TCheckBoxEx [22]
      Left = 160
      Top = 234
      Width = 114
      Height = 17
      Caption = 'ShowMessage'
      TabOrder = 12
      OnClick = ckbShowMessageClick
    end
    object ckbAutoClose: TCheckBoxEx [23]
      Left = 294
      Top = 234
      Width = 101
      Height = 17
      Caption = 'AutoClose'
      TabOrder = 14
      OnClick = ckbAutoCloseClick
    end
    inherited EdtWidth: TEditEx
      TabOrder = 17
    end
    inherited EdtName: TEditEx
      TabOrder = 15
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
