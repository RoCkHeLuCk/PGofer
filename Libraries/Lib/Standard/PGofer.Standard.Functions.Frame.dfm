inherited PGFunctionFrame: TPGFunctionFrame
  Height = 217
  ExplicitHeight = 217
  object sptScript: TSplitter [0]
    Left = 0
    Top = 119
    Width = 400
    Height = 5
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ExplicitLeft = -8
    ExplicitTop = 111
  end
  object GrbScript: TGroupBox [1]
    AlignWithMargins = True
    Left = 3
    Top = 36
    Width = 394
    Height = 80
    Align = alTop
    Caption = 'Script (Run = F9)'
    Constraints.MinHeight = 60
    TabOrder = 3
    object EdtScript: TMemoEx
      Left = 2
      Top = 15
      Width = 390
      Height = 44
      Align = alClient
      Color = clSilver
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      OnKeyUp = EdtScriptKeyUp
      ShowStatusBar = True
      ExplicitHeight = 63
    end
  end
  inherited grbAbout: TGroupBox
    Top = 127
    Height = 80
    ExplicitTop = 127
    ExplicitHeight = 80
    inherited mmoAbout: TMemoEx
      Height = 43
      ExplicitHeight = 43
    end
  end
  inherited pnlItem: TPanel
    inherited EdtName: TEditEx
      StyleElements = [seFont, seClient]
    end
  end
  inherited sptAbout: TPanel
    Top = 210
    ExplicitTop = 210
  end
end
