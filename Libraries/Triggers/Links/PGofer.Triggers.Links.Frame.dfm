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
      Color = clSilver
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Courier New'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      Zoom = 100
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
      Color = clSilver
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Courier New'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      Zoom = 100
      OnKeyUp = EdtScriptBeforeKeyUp
    end
  end
  inherited grbAbout: TGroupBox
    Top = 317
    TabOrder = 3
    ExplicitTop = 317
  end
  inherited pnlItem: TPanel
    Height = 170
    Anchors = []
    TabOrder = 0
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
      Top = 90
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
    object LblOperation: TLabel [5]
      Left = 195
      Top = 117
      Width = 67
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Operation:'
    end
    object EdtFile: TEdit [7]
      Left = 70
      Top = 33
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      Constraints.MinWidth = 290
      TabOrder = 0
      OnKeyUp = EdtFileKeyUp
    end
    object BtnFile: TButton [8]
      Left = 366
      Top = 33
      Width = 29
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 1
      OnClick = BtnFileClick
    end
    object EdtPatameter: TEdit [9]
      Left = 70
      Top = 60
      Width = 325
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      Constraints.MinWidth = 325
      TabOrder = 2
      OnKeyUp = EdtPatameterKeyUp
    end
    object EdtDiretory: TEdit [10]
      Left = 70
      Top = 87
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clSilver
      Constraints.MinWidth = 290
      TabOrder = 3
      OnKeyUp = EdtDiretoryKeyUp
    end
    object BtnDiretory: TButton [11]
      Left = 366
      Top = 87
      Width = 29
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 4
      OnClick = BtnDiretoryClick
    end
    object CmbState: TComboBox [12]
      Left = 70
      Top = 114
      Width = 119
      Height = 21
      Style = csDropDownList
      Color = clSilver
      ItemIndex = 1
      TabOrder = 5
      Text = 'Normal'
      OnChange = CmbStateChange
      Items.Strings = (
        'Hiden'
        'Normal'
        'Minimized'
        'Maxmized')
    end
    object CmbPriority: TComboBox [13]
      Left = 70
      Top = 141
      Width = 119
      Height = 21
      Style = csDropDownList
      Color = clSilver
      ItemIndex = 2
      TabOrder = 6
      Text = 'Normal'
      OnChange = CmbPriorityChange
      Items.Strings = (
        'Low'
        'Below Normal'
        'Normal'
        'Above Normal'
        'High'
        'Real time')
    end
    object BtnTest: TButton [14]
      Left = 340
      Top = 141
      Width = 56
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Test'
      TabOrder = 7
      OnClick = BtnTestClick
    end
    object CmbOperation: TComboBox [15]
      Left = 268
      Top = 114
      Width = 127
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      Color = clSilver
      ItemIndex = 0
      TabOrder = 8
      Text = 'Open'
      OnChange = CmbOperationChange
      Items.Strings = (
        'Open'
        'Edit'
        'Explore'
        'Find'
        'Print'
        'Properties'
        'Runas')
    end
    object ckbCapture: TCheckBox [16]
      Left = 209
      Top = 143
      Width = 97
      Height = 17
      Caption = 'CaptureMsg'
      TabOrder = 9
      OnClick = ckbCaptureClick
    end
    inherited EdtName: TEditEx
      TabOrder = 10
    end
  end
  inherited sptAbout: TPanel
    Top = 380
    TabOrder = 4
    ExplicitTop = 380
  end
  object OpdLinks: TOpenDialog
    Left = 199
    Top = 39
  end
end
