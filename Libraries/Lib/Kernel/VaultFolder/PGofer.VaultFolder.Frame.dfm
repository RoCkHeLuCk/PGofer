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
    object EdtFile: TEdit
      Left = 70
      Top = 33
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      Constraints.MinWidth = 290
      TabOrder = 1
      OnKeyUp = EdtFileKeyUp
    end
    object BtnFile: TButton
      Left = 366
      Top = 33
      Width = 29
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 2
      OnClick = BtnFileClick
    end
    object EdtPassword: TEdit
      Left = 70
      Top = 60
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      Constraints.MinWidth = 290
      PasswordChar = '*'
      TabOrder = 3
      OnKeyUp = EdtPasswordKeyUp
    end
    object BtnPassword: TButton
      Left = 366
      Top = 59
      Width = 29
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '(_)'
      TabOrder = 4
      OnClick = BtnPasswordClick
    end
    object ckbSavePassword: TCheckBox
      Left = 70
      Top = 84
      Width = 97
      Height = 17
      Caption = 'Save Password'
      Checked = True
      State = cbChecked
      TabOrder = 5
      OnClick = ckbSavePasswordClick
    end
  end
  inherited sptAbout: TPanel
    Top = 177
    ExplicitTop = 177
  end
  object svdVault: TSaveDialog
    DefaultExt = '.pgv'
    Filter = 'PGofer Vault (*.pgv)|*.pgv|All Files (*.*)|*.*'
    Options = [ofEnableSizing]
    Title = 'Save Vault'
    Left = 200
    Top = 32
  end
end
