inherited PGConsoleFrame: TPGConsoleFrame
  Height = 337
  ExplicitHeight = 337
  inherited grbAbout: TGroupBox
    Top = 287
    Height = 40
    Constraints.MinHeight = 40
    ExplicitTop = 287
    ExplicitHeight = 40
    inherited mmoAbout: TMemoEx
      Height = 23
      ExplicitHeight = 23
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
    inherited UpdAlphaBlendValue: TUpDown
      Width = 16
      ExplicitWidth = 16
    end
    inherited CkbEnabled: TCheckBoxEx
      Width = 101
      ExplicitWidth = 101
    end
    inherited PnlTransparentColor: TPanel
      TabOrder = 16
    end
    inherited CmbWindowState: TPGComboBox
      TabOrder = 17
      Text = ''
      ItemIndex = -1
    end
    object EdtDelay: TEditEx [18]
      Left = 70
      Top = 233
      Width = 51
      Height = 21
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      Text = '0'
      ValidationColorNormal = clSilver
      OnAfterValidate = EdtDelayAfterValidate
    end
    object updDelay: TUpDown [19]
      Left = 121
      Top = 233
      Width = 16
      Height = 21
      Associate = EdtDelay
      Max = 255
      TabOrder = 6
    end
    object ckbShowMessage: TCheckBoxEx [20]
      Left = 160
      Top = 234
      Width = 114
      Height = 17
      Caption = 'ShowMessage'
      TabOrder = 9
      OnClick = ckbShowMessageClick
    end
    object ckbAutoClose: TCheckBoxEx [21]
      Left = 294
      Top = 234
      Width = 101
      Height = 17
      Caption = 'AutoClose'
      TabOrder = 10
      OnClick = ckbAutoCloseClick
    end
    inherited EdtAlphaBlendValue: TEditEx
      TabOrder = 18
    end
    inherited EdtHeigth: TEditEx
      TabOrder = 12
    end
    inherited EdtWidth: TEditEx
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
