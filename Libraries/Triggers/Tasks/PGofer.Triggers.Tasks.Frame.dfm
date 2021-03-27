inherited PGTaskFrame: TPGTaskFrame
  Height = 215
  ExplicitHeight = 215
  inherited SplitterItem: TSplitter
    Top = 161
    ExplicitTop = 333
  end
  inherited grbAbout: TGroupBox
    Top = 172
    ExplicitTop = 172
    inherited rceAbout: TRichEdit
      ExplicitHeight = 23
    end
  end
  inherited pnlItem: TPanel
    Height = 161
    Constraints.MinHeight = 160
    ExplicitHeight = 161
    object LblTipo: TLabel [1]
      Left = 5
      Top = 36
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Tipo:'
      ParentBiDiMode = False
    end
    object lblDate: TLabel [2]
      Left = 207
      Top = 37
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Data:'
      Enabled = False
      ParentBiDiMode = False
    end
    object lblTime: TLabel [3]
      Left = 207
      Top = 64
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Hora:'
      Enabled = False
      ParentBiDiMode = False
    end
    object lblRepeat: TLabel [4]
      Left = 5
      Top = 63
      Width = 59
      Height = 13
      Hint = 'Forma de detectar a Tarefa'
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Repetir:'
      Enabled = False
      ParentBiDiMode = False
    end
    object CmbTipo: TComboBox
      Left = 70
      Top = 33
      Width = 119
      Height = 21
      Hint = 'Forma de detectar a Tarefa'
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'Inicializando '
      OnChange = CmbTipoChange
      Items.Strings = (
        'Inicializando '
        'Finalizando'
        'Desligando')
    end
    object GrbScript: TGroupBox
      AlignWithMargins = True
      Left = 5
      Top = 84
      Width = 390
      Height = 74
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Script (Run: F9)'
      TabOrder = 2
      object EdtScript: TRichEditEx
        Left = 2
        Top = 15
        Width = 386
        Height = 57
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Zoom = 100
      end
    end
    object dtpDate: TDateTimePicker
      Left = 272
      Top = 33
      Width = 123
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Date = 44277.868612233800000000
      Time = 44277.868612233800000000
      ShowCheckbox = True
      Enabled = False
      ParseInput = True
      TabOrder = 3
    end
    object dtpTime: TDateTimePicker
      Left = 272
      Top = 60
      Width = 123
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Date = 44277.868612233800000000
      Time = 44277.868612233800000000
      ShowCheckbox = True
      Enabled = False
      Kind = dtkTime
      ParseInput = True
      TabOrder = 4
    end
    object edtRepeat: TEditEx
      Left = 70
      Top = 60
      Width = 51
      Height = 21
      Enabled = False
      TabOrder = 5
      Text = '0'
      RegExamples = reNone
      RegExpression = '^\d*$'
    end
    object updRepeat: TUpDown
      Left = 121
      Top = 60
      Width = 16
      Height = 21
      Associate = edtRepeat
      Enabled = False
      Max = 255
      TabOrder = 6
    end
  end
end
