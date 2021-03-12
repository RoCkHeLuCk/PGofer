inherited PGLinkFrame: TPGLinkFrame
  Width = 416
  Height = 305
  Constraints.MinHeight = 200
  ExplicitWidth = 416
  ExplicitHeight = 305
  inherited SplitterItem: TSplitter
    Top = 200
    Width = 416
    ExplicitTop = 200
    ExplicitWidth = 416
  end
  inherited grbAbout: TGroupBox
    Top = 211
    Width = 410
    inherited rceAbout: TRichEdit
      Width = 406
    end
  end
  inherited pnlItem: TPanel
    Width = 416
    Height = 200
    Constraints.MinHeight = 200
    Constraints.MinWidth = 0
    ExplicitWidth = 416
    ExplicitHeight = 200
    object LblArquivo: TLabel [0]
      Left = 5
      Top = 36
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Arquivo:'
    end
    object LblParametro: TLabel [1]
      Left = 5
      Top = 63
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Parametros:'
    end
    object LblDiretorio: TLabel [2]
      Left = 5
      Top = 90
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Diretorio:'
    end
    object LblIcone: TLabel [3]
      Left = 5
      Top = 117
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Icone:'
    end
    object LblEstado: TLabel [4]
      Left = 5
      Top = 144
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Estado:'
    end
    object LblPrioridade: TLabel [5]
      Left = 5
      Top = 171
      Width = 59
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Prioridade:'
    end
    object LblOperation: TLabel [6]
      Left = 212
      Top = 144
      Width = 67
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Opera'#231#227'o:'
    end
    object EdtArquivo: TEdit [8]
      Left = 70
      Top = 33
      Width = 303
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = EdtArquivoChange
    end
    object BtnArquivo: TButton [9]
      Left = 379
      Top = 33
      Width = 33
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 1
      OnClick = BtnArquivoClick
    end
    object EdtParametro: TEdit [10]
      Left = 70
      Top = 60
      Width = 342
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      OnChange = EdtParametroChange
    end
    object EdtDiretorio: TEdit [11]
      Left = 70
      Top = 87
      Width = 303
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      OnChange = EdtDiretorioChange
    end
    object BtnDiretorio: TButton [12]
      Left = 379
      Top = 87
      Width = 33
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 4
      OnClick = BtnDiretorioClick
    end
    object EdtIcone: TEdit [13]
      Left = 70
      Top = 114
      Width = 268
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 5
      OnChange = EdtIconeChange
    end
    object BtnIcone: TButton [14]
      Left = 379
      Top = 114
      Width = 33
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 6
      OnClick = BtnIconeClick
    end
    object EdtIconeIndex: TEdit [15]
      Left = 340
      Top = 114
      Width = 33
      Height = 21
      Anchors = [akTop, akRight]
      NumbersOnly = True
      TabOrder = 7
      Text = '0'
      OnChange = EdtIconeIndexChange
    end
    object CmbEstado: TComboBox [16]
      Left = 70
      Top = 141
      Width = 135
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 8
      Text = 'Normal'
      OnChange = CmbEstadoChange
      Items.Strings = (
        'Oculto'
        'Normal'
        'Minimizado'
        'Maxmizado')
    end
    object CmbPrioridade: TComboBox [17]
      Left = 70
      Top = 168
      Width = 135
      Height = 21
      Style = csDropDownList
      ItemIndex = 3
      TabOrder = 9
      Text = 'Normal'
      OnChange = CmbPrioridadeChange
      Items.Strings = (
        'Suspenso'
        'Baixa'
        'Abaixo do Normal'
        'Normal'
        'Acima do Normal'
        'Alta'
        'Tempo Real')
    end
    object BtnTest: TButton [18]
      Left = 285
      Top = 168
      Width = 127
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Test'
      TabOrder = 10
      OnClick = BtnTestClick
    end
    object CmbOperation: TComboBox [19]
      Left = 285
      Top = 141
      Width = 127
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemIndex = 0
      TabOrder = 11
      Text = 'Open'
      OnChange = CmbOperationChange
      Items.Strings = (
        'Open'
        'Edit'
        'Explore'
        'Find'
        'Print'
        'Properties')
    end
    inherited EdtName: TEditEx
      TabOrder = 12
    end
  end
  object OpdLinks: TOpenDialog
    Left = 219
    Top = 87
  end
end
