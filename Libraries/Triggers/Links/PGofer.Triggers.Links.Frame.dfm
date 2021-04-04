inherited PGLinkFrame: TPGLinkFrame
  Height = 364
  Constraints.MinHeight = 200
  ExplicitHeight = 364
  inherited SplitterItem: TSplitter
    Top = 310
    ExplicitTop = 200
    ExplicitWidth = 416
  end
  inherited grbAbout: TGroupBox
    Top = 321
    ExplicitTop = 321
  end
  inherited pnlItem: TPanel
    Height = 310
    Constraints.MinHeight = 310
    Constraints.MinWidth = 0
    ExplicitHeight = 310
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
      TabOrder = 0
      OnChange = EdtFileChange
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
      TabOrder = 2
      OnChange = EdtPatameterChange
    end
    object EdtDiretory: TEdit [10]
      Left = 70
      Top = 87
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      OnChange = EdtDiretoryChange
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
      Left = 269
      Top = 141
      Width = 127
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
    inherited EdtName: TEditEx
      TabOrder = 9
    end
    object pnlScript: TPanel
      Left = 0
      Top = 168
      Width = 400
      Height = 142
      Align = alBottom
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelOuter = bvNone
      TabOrder = 10
      object Splitter1: TSplitter
        Left = 0
        Top = 68
        Width = 400
        Height = 8
        Cursor = crVSplit
        Align = alBottom
        Beveled = True
        ExplicitTop = 94
      end
      object GrbScriptBefore: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 394
        Height = 62
        Align = alClient
        Caption = 'Script Before (Run: F9)'
        Constraints.MinHeight = 60
        TabOrder = 0
        object EdtScriptBefore: TRichEditEx
          Left = 2
          Top = 15
          Width = 390
          Height = 45
          Align = alClient
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
          WantTabs = True
          Zoom = 100
          OnChange = EdtScriptBeforeChange
        end
      end
      object GpbScriptAfter: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 79
        Width = 394
        Height = 60
        Align = alBottom
        Caption = 'Script After (Run: F9)'
        Constraints.MinHeight = 60
        TabOrder = 1
        object EdtScriptAfter: TRichEditEx
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
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
          WantTabs = True
          Zoom = 100
          OnChange = EdtScriptAfterChange
        end
      end
    end
  end
  object OpdLinks: TOpenDialog
    Left = 199
    Top = 39
  end
end
