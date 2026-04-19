inherited PGVaultFolderFrame: TPGVaultFolderFrame
  Height = 222
  ExplicitHeight = 222
  inherited grbAbout: TGroupBox
    Top = 141
    Height = 71
    ExplicitTop = 141
    ExplicitHeight = 71
    inherited rceAbout: TRichEdit
      Height = 54
      ExplicitHeight = 54
    end
  end
  inherited pnlItem: TPanel
    Height = 138
    ExplicitHeight = 138
    object LblFileName: TLabel [0]
      Left = 5
      Top = 59
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'File:'
      StyleElements = [seFont, seClient]
    end
    object LblRepeat: TLabel [2]
      Left = 5
      Top = 86
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Auto Lock:'
      StyleElements = [seFont, seClient]
    end
    object LblMinute: TLabel [3]
      Left = 137
      Top = 88
      Width = 42
      Height = 13
      AutoSize = False
      Caption = 'minute'
    end
    object CkbLocked: TCheckBoxEx [4]
      Left = 301
      Top = 85
      Width = 94
      Height = 17
      Caption = 'Locked'
      Checked = True
      State = cbChecked
      TabOrder = 2
      StyleElements = [seFont, seClient]
      OnClick = CkbLockedClick
    end
    object EdtFile: TEditEx [5]
      Left = 70
      Top = 56
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      TabOrder = 0
      StyleElements = [seFont, seClient]
      ValidationMode = vmSaveFile
      ActionButtonShow = True
      PathAutoUnExpand = True
      PathDialogFilter = 'PGofer Vault (*.pgv)|*.pgv|All Files (*.*)|*.*'
      PathDialogTitle = 'Vault File'
      PathDefaultExt = 'pgv'
      OnAfterValidate = EdtFileAfterValidate
    end
    inherited CkbNamespace: TCheckBoxEx
      TabOrder = 4
    end
    inherited EdtName: TEditEx
      TabOrder = 3
    end
    object EdtAutoLock: TEditEx
      Left = 70
      Top = 83
      Width = 45
      Height = 21
      Color = clSilver
      NumbersOnly = True
      TabOrder = 5
      Text = '0'
      StyleElements = [seFont, seClient]
      OnAfterValidate = EdtAutoLockAfterValidate
    end
    object UpdAutoLock: TUpDown
      Left = 115
      Top = 83
      Width = 16
      Height = 21
      Associate = EdtAutoLock
      Max = 999999999
      TabOrder = 6
      StyleElements = [seFont, seClient]
      OnChangingEx = UpdAutoLockChangingEx
    end
    object CkbSavePassword: TCheckBoxEx
      Left = 185
      Top = 85
      Width = 110
      Height = 17
      Caption = 'Save Password'
      TabOrder = 7
      StyleElements = [seFont, seClient]
      OnClick = CkbSavePasswordClick
    end
    object BtnPassword: TButton
      Left = 160
      Top = 107
      Width = 75
      Height = 25
      Anchors = [akTop]
      Caption = 'Password'
      TabOrder = 8
      StyleElements = [seFont, seClient]
      OnClick = BtnPasswordClick
    end
  end
  inherited sptAbout: TPanel
    Top = 215
    ExplicitTop = 215
  end
end
