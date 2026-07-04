inherited PGVaultFolderFrame: TPGVaultFolderFrame
  Height = 231
  ExplicitHeight = 231
  inherited grbAbout: TGroupBox
    Top = 141
    ExplicitTop = 141
    inherited mmoAbout: TMemoEx
      ExplicitHeight = 43
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
      OnClick = CkbLockedClick
    end
    object EdtFile: TEditEx [5]
      Left = 70
      Top = 56
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      ValidationMode = vmSaveFile
      ActionButtonShow = True
      PathAutoUnExpand = True
      PathDialogFilter = 'PGofer Vault (*.pgv)|*.pgv|All Files (*.*)|*.*'
      PathDialogTitle = 'Vault File'
      PathDefaultExt = 'pgv'
      OnAfterValidate = EdtFileAfterValidate
    end
    inherited CkbNamespace: TCheckBoxEx
      TabOrder = 3
    end
    object EdtAutoLock: TEditEx [7]
      Left = 70
      Top = 83
      Width = 45
      Height = 21
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      NumbersOnly = True
      ParentFont = False
      TabOrder = 4
      Text = '0'
      OnAfterValidate = EdtAutoLockAfterValidate
    end
    object UpdAutoLock: TUpDown [8]
      Left = 115
      Top = 83
      Width = 16
      Height = 21
      Associate = EdtAutoLock
      Max = 999999999
      TabOrder = 5
    end
    object CkbSavePassword: TCheckBoxEx [9]
      Left = 185
      Top = 85
      Width = 110
      Height = 17
      Caption = 'Save Password'
      TabOrder = 6
      OnClick = CkbSavePasswordClick
    end
    object BtnPassword: TButton [10]
      Left = 160
      Top = 107
      Width = 75
      Height = 25
      Anchors = [akTop]
      Caption = 'Password'
      TabOrder = 7
      OnClick = BtnPasswordClick
    end
    inherited EdtName: TEditEx
      TabOrder = 8
    end
  end
  inherited sptAbout: TPanel
    Top = 224
    ExplicitTop = 224
  end
end
