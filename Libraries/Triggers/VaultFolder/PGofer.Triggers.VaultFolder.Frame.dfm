inherited PGVaultFolderFrame: TPGVaultFolderFrame
  Height = 216
  ExplicitHeight = 216
  inherited grbAbout: TGroupBox
    Top = 140
    Height = 66
    ExplicitTop = 140
    ExplicitHeight = 66
    inherited rceAbout: TRichEdit
      Height = 49
      ExplicitHeight = 49
    end
  end
  inherited pnlItem: TPanel
    Height = 137
    ExplicitHeight = 137
    object LblPassword: TLabel [0]
      Left = 5
      Top = 83
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Password:'
      StyleElements = [seFont, seClient]
    end
    object LblFileName: TLabel [2]
      Left = 5
      Top = 56
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'File:'
      StyleElements = [seFont, seClient]
    end
    object ckbSavePassword: TCheckBoxEx
      Left = 70
      Top = 104
      Width = 131
      Height = 17
      Caption = 'Save Password'
      TabOrder = 6
      StyleElements = [seFont, seClient]
      OnClick = ckbSavePasswordClick
    end
    object ckbLocked: TCheckBoxEx
      Left = 240
      Top = 105
      Width = 120
      Height = 17
      Caption = 'Locked'
      Checked = True
      State = cbChecked
      TabOrder = 7
      StyleElements = [seFont, seClient]
      OnClick = ckbLockedClick
    end
    object EdtFile: TEditEx
      Left = 70
      Top = 53
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      TabOrder = 2
      Text = ''
      StyleElements = [seFont, seClient]
      ValidationMode = vmSaveFile
      ActionButtonShow = True
      PathAutoUnExpand = True
      PathDialogFilter = 'PGofer Vault (*.pgv)|*.pgv|All Files (*.*)|*.*'
      PathDialogTitle = 'Vault File'
      OnAfterValidate = EdtFileAfterValidate
    end
    object EdtPassword: TEditEx
      Left = 70
      Top = 80
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      PasswordChar = '*'
      TabOrder = 4
      Text = ''
      StyleElements = [seFont, seClient]
      ValidationMode = vmPassword
      ActionButtonShow = True
      RegExExpression = '^.{6,}$'
      SelectAllOnFocus = True
      OnAfterValidate = EdtPasswordAfterValidate
    end
  end
  inherited sptAbout: TPanel
    Top = 209
    ExplicitTop = 209
  end
end
