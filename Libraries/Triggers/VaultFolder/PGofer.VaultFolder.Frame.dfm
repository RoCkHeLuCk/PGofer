inherited PGVaultFolderFrame: TPGVaultFolderFrame
  Height = 184
  ExplicitHeight = 184
  inherited grbAbout: TGroupBox
    Top = 108
    Height = 66
    ExplicitTop = 108
    ExplicitHeight = 66
    inherited rceAbout: TRichEdit
      Height = 49
      ExplicitHeight = 49
    end
  end
  inherited pnlItem: TPanel
    Height = 105
    ExplicitHeight = 105
    object LblPassword: TLabel [0]
      Left = 5
      Top = 63
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Password:'
    end
    object LblFileName: TLabel [2]
      Left = 5
      Top = 36
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'File:'
    end
    object ckbSavePassword: TCheckBox
      Left = 70
      Top = 84
      Width = 131
      Height = 17
      Caption = 'Save Password'
      TabOrder = 5
      OnClick = ckbSavePasswordClick
    end
    object ckbLocked: TCheckBoxEx
      Left = 240
      Top = 85
      Width = 120
      Height = 17
      Caption = 'Locked'
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = ckbLockedClick
    end
    object EdtFile: TEditEx
      Left = 70
      Top = 33
      Width = 290
      Height = 21
      Color = clRed
      TabOrder = 1
      StyleElements = [seFont, seBorder]
      ValidationMode = vmSaveFile
      ActionButtonShow = True
      PathAutoUnExpand = True
      PathDialogFilter = 'PGofer Vault (*.pgv)|*.pgv|All Files (*.*)|*.*'
      PathDialogTitle = 'Vault File'
      OnAfterValidate = EdtFileAfterValidate
    end
    object EdtPassword: TEditEx
      Left = 70
      Top = 60
      Width = 290
      Height = 21
      Color = clRed
      PasswordChar = '*'
      TabOrder = 3
      StyleElements = [seFont, seBorder]
      ValidationMode = vmPassword
      ActionButtonShow = True
      RegExExpression = '^.{6,}$'
      SelectAllOnFocus = True
      OnAfterValidate = EdtPasswordAfterValidate
    end
  end
  inherited sptAbout: TPanel
    Top = 177
    ExplicitTop = 177
  end
end
