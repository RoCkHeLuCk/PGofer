inherited PGFunctionFrame: TPGFunctionFrame
  Height = 196
  ExplicitHeight = 196
  object sptScript: TSplitter [0]
    Left = 0
    Top = 118
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
    Top = 35
    Width = 394
    Height = 80
    Align = alTop
    Caption = 'Script (Run = F9)'
    Constraints.MinHeight = 60
    TabOrder = 0
    object EdtScript: TRichEditEx
      Left = 2
      Top = 15
      Width = 390
      Height = 63
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
      OnKeyUp = EdtScriptKeyUp
    end
  end
  inherited grbAbout: TGroupBox
    Top = 126
    TabOrder = 2
    ExplicitTop = 126
  end
  inherited sptAbout: TPanel
    Top = 189
    TabOrder = 3
    ExplicitTop = 189
  end
end
