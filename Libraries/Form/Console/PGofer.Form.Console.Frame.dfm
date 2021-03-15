inherited PGFrameConsole: TPGFrameConsole
  Width = 400
  Height = 404
  ExplicitWidth = 400
  ExplicitHeight = 404
  inherited SplitterItem: TSplitter
    Top = 282
    Width = 400
  end
  inherited grbAbout: TGroupBox
    Top = 293
    Width = 394
    Height = 108
    inherited rceAbout: TRichEdit
      Width = 390
      Height = 91
    end
  end
  inherited pnlItem: TPanel
    Width = 400
    Height = 282
    ExplicitHeight = 282
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
    object edtDelay: TEditEx [23]
      Left = 70
      Top = 254
      Width = 51
      Height = 21
      TabOrder = 14
      Text = '0'
      OnExit = edtDelayExit
      RegExamples = reNone
      RegExpression = '^\d*$'
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
  inherited cldTrasparentColor: TColorDialog
    Left = 164
    Top = 64
  end
end
