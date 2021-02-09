object PGFrame: TPGFrame
  Left = 0
  Top = 0
  Width = 400
  Height = 36
  AutoScroll = True
  Constraints.MinWidth = 400
  TabOrder = 0
  DesignSize = (
    400
    36)
  object LblName: TLabel
    Left = 34
    Top = 9
    Width = 30
    Height = 13
    Caption = 'Titulo:'
  end
  object EdtName: TEditEx
    Left = 70
    Top = 6
    Width = 324
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnExit = EdtNameExit
    RegExamples = reNone
    RegExpression = '^[A-Za-z_]+\w*$'
  end
end
