inherited PGLinkFrame: TPGLinkFrame
  Height = 387
  ExplicitHeight = 387
  object sptScriptBefore: TSplitter [0]
    Left = 0
    Top = 236
    Width = 400
    Height = 6
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    MinSize = 1
    ExplicitTop = 242
  end
  object sptScriptAfter: TSplitter [1]
    Left = 0
    Top = 308
    Width = 400
    Height = 6
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    MinSize = 1
    ExplicitLeft = 3
    ExplicitTop = 357
  end
  object GrbScriptAfter: TGroupBox [2]
    AlignWithMargins = True
    Left = 3
    Top = 245
    Width = 394
    Height = 60
    Align = alTop
    Caption = 'Script After (Run: F9)'
    Constraints.MinHeight = 60
    TabOrder = 1
    object EdtScriptAfter: TRichEditEx
      Left = 2
      Top = 15
      Width = 390
      Height = 43
      Align = alClient
      BorderWidth = 1
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      OnKeyUp = EdtScriptAfterKeyUp
    end
  end
  object GrbScriptBefore: TGroupBox [3]
    AlignWithMargins = True
    Left = 3
    Top = 173
    Width = 394
    Height = 60
    Align = alTop
    Caption = 'Script Before (Run: F9)'
    Constraints.MinHeight = 60
    TabOrder = 2
    object EdtScriptBefore: TRichEditEx
      Left = 2
      Top = 15
      Width = 390
      Height = 43
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      OnKeyUp = EdtScriptBeforeKeyUp
    end
  end
  inherited grbAbout: TGroupBox
    Top = 317
    TabOrder = 4
    ExplicitTop = 317
  end
  inherited pnlItem: TPanel
    Height = 170
    Anchors = []
    ExplicitHeight = 170
    object LblFile: TLabel [0]
      Left = 5
      Top = 36
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'File:'
    end
    object LblParameter: TLabel [1]
      Left = 5
      Top = 63
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Parameter:'
    end
    object LblDirectory: TLabel [2]
      Left = 5
      Top = 95
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Path:'
    end
    object LblState: TLabel [3]
      Left = 5
      Top = 117
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'State:'
    end
    object LblPriority: TLabel [4]
      Left = 5
      Top = 144
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Priority:'
    end
    object EdtFile: TEditEx [6]
      Left = 70
      Top = 33
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Constraints.MinWidth = 290
      TabOrder = 1
      ValidationMode = vmOpenFile
      ActionButtonShow = True
      PathAutoUnExpand = True
      PathDialogFilter = 'All Files(*.*)|*.*'
      PathDialogTitle = 'File'
      ValidationColorNormal = clWhite
      OnActionButtonClick = EdtFileActionButtonClick
      OnAfterValidate = EdtFileAfterValidate
    end
    object EdtPatameter: TEditEx [7]
      Left = 70
      Top = 60
      Width = 325
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Constraints.MinWidth = 325
      TabOrder = 3
      OnAfterValidate = EdtPatameterAfterValidate
    end
    object EdtDiretory: TEditEx [8]
      Left = 70
      Top = 89
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Constraints.MinWidth = 290
      TabOrder = 4
      ValidationMode = vmPathExists
      ActionButtonShow = True
      PathAutoUnExpand = True
      OnAfterValidate = EdtDiretoryAfterValidate
    end
    object CmbState: TPGComboBox [9]
      Left = 70
      Top = 114
      Width = 119
      Height = 22
      ItemsEx = <
        item
          Caption = 'Hiden'
        end
        item
          Caption = 'Normal'
        end
        item
          Caption = 'Minimized'
        end
        item
          Caption = 'Maxmized'
        end>
      Style = csExDropDownList
      TabOrder = 6
      Text = 'Normal'
      OnChange = CmbStateChange
      ItemIndex = 1
    end
    object CmbPriority: TPGComboBox [10]
      Left = 70
      Top = 141
      Width = 119
      Height = 22
      ItemsEx = <
        item
          Caption = 'Low'
        end
        item
          Caption = 'Below Normal'
        end
        item
          Caption = 'Normal'
        end
        item
          Caption = 'Above Normal'
        end
        item
          Caption = 'High'
        end
        item
          Caption = 'Real time'
        end>
      Style = csExDropDownList
      TabOrder = 7
      Text = 'Normal'
      OnChange = CmbPriorityChange
      ItemIndex = 2
    end
    object BtnTest: TButton [11]
      Left = 318
      Top = 139
      Width = 61
      Height = 21
      Caption = 'Test'
      TabOrder = 10
      OnClick = BtnTestClick
    end
    object ckbCapture: TCheckBoxEx [12]
      Left = 311
      Top = 116
      Width = 97
      Height = 17
      Caption = 'CaptureMsg'
      TabOrder = 9
      OnClick = ckbCaptureClick
    end
    object ckbAdministrator: TCheckBoxEx
      Left = 199
      Top = 116
      Width = 97
      Height = 17
      Caption = 'Run Admintrator'
      TabOrder = 8
      OnClick = ckbAdministratorClick
    end
    object CkbSingleInstance: TCheckBoxEx
      Left = 199
      Top = 141
      Width = 97
      Height = 17
      Caption = 'Single Instance'
      TabOrder = 11
      OnClick = CkbSingleInstanceClick
    end
  end
  inherited sptAbout: TPanel
    Top = 380
    TabOrder = 3
    ExplicitTop = 380
  end
end
