inherited PGFunctionFrame: TPGFunctionFrame
  Height = 217
  ExplicitHeight = 217
  object sptScript: TSplitter [0]
    Left = 0
    Top = 139
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
    Top = 56
    Width = 394
    Height = 80
    Align = alTop
    Caption = 'Script (Run = F9)'
    Constraints.MinHeight = 60
    TabOrder = 4
    object EdtScript: TMemoEx
      Left = 2
      Top = 15
      Width = 390
      Height = 63
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
    end
  end
  inherited grbAbout: TGroupBox
    Top = 147
    Height = 60
    ExplicitTop = 147
    inherited mmoAbout: TMemoEx
      Height = 43
    end
  end
  inherited pnlItem: TPanel
    inherited EdtName: TEditEx
      StyleElements = [seFont, seClient]
    end
  end
  inherited sptAbout: TPanel
    Top = 210
    ExplicitTop = 189
  end
end
