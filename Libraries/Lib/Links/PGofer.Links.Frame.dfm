inherited PGFrameLinks: TPGFrameLinks
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
    Height = 91
    Constraints.MinHeight = 91
    ExplicitTop = 211
    ExplicitWidth = 410
    ExplicitHeight = 91
    inherited rceAbout: TRichEdit
      Width = 406
      Height = 74
      ExplicitWidth = 406
      ExplicitHeight = 74
    end
  end
  inherited pnlItem: TPanel
    Width = 416
    Height = 200
    Constraints.MinHeight = 200
    Constraints.MinWidth = 0
    ExplicitWidth = 416
    ExplicitHeight = 200
    object LblArquivo: TLabel [1]
      Left = 23
      Top = 36
      Width = 41
      Height = 13
      Caption = 'Arquivo:'
    end
    object LblParametro: TLabel [2]
      Left = 5
      Top = 63
      Width = 59
      Height = 13
      Caption = 'Parametros:'
    end
    object LblDiretorio: TLabel [3]
      Left = 19
      Top = 90
      Width = 45
      Height = 13
      Caption = 'Diretorio:'
    end
    object LblIcone: TLabel [4]
      Left = 33
      Top = 117
      Width = 31
      Height = 13
      Caption = 'Icone:'
    end
    object LblEstado: TLabel [5]
      Left = 27
      Top = 144
      Width = 37
      Height = 13
      Caption = 'Estado:'
    end
    object LblPrioridade: TLabel [6]
      Left = 12
      Top = 171
      Width = 52
      Height = 13
      Caption = 'Prioridade:'
    end
    object LblOperation: TLabel [7]
      Left = 228
      Top = 144
      Width = 51
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Opera'#231#227'o:'
      ExplicitLeft = 212
    end
    inherited EdtName: TEditEx
      Width = 341
      ExplicitWidth = 341
    end
    object EdtArquivo: TEdit
      Left = 70
      Top = 33
      Width = 303
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      BiDiMode = bdLeftToRight
      ParentBiDiMode = False
      TabOrder = 1
      OnChange = EdtArquivoChange
    end
    object BtnArquivo: TButton
      Left = 379
      Top = 33
      Width = 33
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 2
      OnClick = BtnArquivoClick
    end
    object EdtParametro: TEdit
      Left = 70
      Top = 60
      Width = 342
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      OnChange = EdtParametroChange
    end
    object EdtDiretorio: TEdit
      Left = 70
      Top = 87
      Width = 303
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      BiDiMode = bdLeftToRight
      ParentBiDiMode = False
      TabOrder = 4
      OnChange = EdtDiretorioChange
    end
    object BtnDiretorio: TButton
      Left = 379
      Top = 87
      Width = 33
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 5
      OnClick = BtnDiretorioClick
    end
    object EdtIcone: TEdit
      Left = 70
      Top = 114
      Width = 268
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      BiDiMode = bdLeftToRight
      ParentBiDiMode = False
      TabOrder = 6
      OnChange = EdtIconeChange
    end
    object BtnIcone: TButton
      Left = 379
      Top = 114
      Width = 33
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 7
      OnClick = BtnIconeClick
    end
    object EdtIconeIndex: TEdit
      Left = 340
      Top = 114
      Width = 33
      Height = 21
      Anchors = [akTop, akRight]
      NumbersOnly = True
      TabOrder = 8
      Text = '0'
      OnChange = EdtIconeIndexChange
    end
    object CmbEstado: TComboBox
      Left = 70
      Top = 141
      Width = 135
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 9
      Text = 'Normal'
      OnChange = CmbEstadoChange
      Items.Strings = (
        'Oculto'
        'Normal'
        'Minimizado'
        'Maxmizado')
    end
    object CmbPrioridade: TComboBox
      Left = 70
      Top = 168
      Width = 135
      Height = 21
      Style = csDropDownList
      ItemIndex = 3
      TabOrder = 10
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
    object BtnTest: TButton
      Left = 285
      Top = 168
      Width = 127
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Test'
      TabOrder = 11
      OnClick = BtnTestClick
    end
    object CmbOperation: TComboBox
      Left = 285
      Top = 141
      Width = 127
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemIndex = 0
      TabOrder = 12
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
  end
  object OpdLinks: TOpenDialog
    Left = 219
    Top = 87
  end
end
