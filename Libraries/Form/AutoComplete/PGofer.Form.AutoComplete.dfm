object FrmAutoComplete: TFrmAutoComplete
  Left = 960
  Top = 154
  BorderStyle = bsNone
  Caption = 'FrmAutoComplete'
  ClientHeight = 115
  ClientWidth = 342
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  OnActivate = FormActivate
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ltvAutoComplete: TListViewEx
    Left = 0
    Top = 0
    Width = 342
    Height = 115
    Align = alClient
    Columns = <
      item
        Caption = 'Command'
        Width = 100
      end
      item
        Caption = 'Origin'
        Width = 100
      end
      item
        Caption = 'Priority'
      end>
    FlatScrollBars = True
    HideSelection = False
    RowSelect = True
    PopupMenu = ppmAutoComplete
    SortType = stBoth
    TabOrder = 0
    ViewStyle = vsReport
    OnCompare = ltvAutoCompleteCompare
    OnDblClick = ltvAutoCompleteDblClick
    ColumnAlphaSort = True
  end
  object ppmAutoComplete: TPopupMenu
    Left = 136
    Top = 44
    object mniPriority: TMenuItem
      Caption = 'Alterar Prioridade'
      ShortCut = 16449
      OnClick = mniPriorityClick
    end
  end
  object trmAutoComplete: TTimer
    Enabled = False
    Interval = 500
    OnTimer = trmAutoCompleteTimer
    Left = 216
    Top = 44
  end
end
