inherited FrmVaultFolderPassword: TFrmVaultFolderPassword
  AutoSize = True
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Vault Folder Password'
  ClientHeight = 130
  ClientWidth = 314
  FormStyle = fsStayOnTop
  KeyPreview = True
  Position = poScreenCenter
  StyleElements = [seFont, seClient]
  OnKeyDown = FormKeyDown
  ExplicitWidth = 320
  ExplicitHeight = 159
  PixelsPerInch = 96
  TextHeight = 13
  object PnlCurrentPassword: TPanel
    Left = 0
    Top = 0
    Width = 314
    Height = 27
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    StyleElements = [seFont, seClient]
    object LblCurrentPassword: TLabel
      Left = 8
      Top = 8
      Width = 93
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Current Password:'
    end
    object EdtCurrentPassword: TEditEx
      Left = 107
      Top = 6
      Width = 190
      Height = 21
      Color = clSilver
      PasswordChar = '*'
      TabOrder = 0
      StyleElements = [seFont, seClient]
      OnKeyDown = EdtCurrentPasswordKeyDown
      ValidationMode = vmPassword
      ActionButtonShow = True
      RegExExpression = '^.{6,}$'
      SelectAllOnFocus = True
    end
  end
  object PnlNewPassword: TPanel
    Left = 0
    Top = 27
    Width = 314
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    StyleElements = [seFont, seClient]
    object LblNewPassword: TLabel
      Left = 8
      Top = 7
      Width = 93
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'New Password:'
    end
    object EdtNewPassword: TEditEx
      Left = 107
      Top = 4
      Width = 190
      Height = 21
      Color = clSilver
      PasswordChar = '*'
      TabOrder = 0
      StyleElements = [seFont, seClient]
      OnKeyDown = EdtNewPasswordKeyDown
      ValidationMode = vmPassword
      ActionButtonShow = True
      RegExExpression = '^.{6,}$'
    end
    object mmoWarning: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 31
      Width = 304
      Height = 31
      Margins.Left = 5
      Margins.Right = 5
      Align = alBottom
      Alignment = taCenter
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = clGray
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        'Caution: Changing your password will permanently erase all '
        'previous security backups.')
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
      WantReturns = False
      StyleElements = [seFont, seClient]
    end
  end
  object PnlButtons: TPanel
    Left = 0
    Top = 92
    Width = 314
    Height = 38
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    StyleElements = [seFont, seClient]
    object BtnOk: TButton
      Left = 64
      Top = 6
      Width = 75
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
      StyleElements = [seFont, seClient]
    end
    object BtnCancel: TButton
      Left = 207
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      StyleElements = [seFont, seClient]
    end
  end
end
