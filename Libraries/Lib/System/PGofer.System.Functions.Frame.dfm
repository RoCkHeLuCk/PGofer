inherited PGFrameFunction: TPGFrameFunction
  Height = 204
  ExplicitHeight = 204
  inherited SplitterItem: TSplitter
    Top = 150
    ExplicitTop = 150
  end
  inherited grbAbout: TGroupBox
    Top = 161
    ExplicitTop = 161
  end
  inherited pnlItem: TPanel
    Height = 150
    Constraints.MinHeight = 150
    Constraints.MinWidth = 0
    ExplicitHeight = 150
    object gpbScript: TGroupBox [1]
      Left = 5
      Top = 33
      Width = 390
      Height = 114
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Script (Run = F9)'
      TabOrder = 0
      object EdtScript: TRichEditEx
        Left = 2
        Top = 15
        Width = 386
        Height = 97
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
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
    inherited EdtName: TEditEx
      TabOrder = 1
    end
  end
end
