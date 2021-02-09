object SvcPGofer: TSvcPGofer
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'PGofer V2.0 Service'
  ServiceStartName = 'PGofer2Service'
  Height = 107
  Width = 229
  object IdTCPServer: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnExecute = IdTCPServerExecute
    Left = 32
    Top = 12
  end
  object XMLDocument: TXMLDocument
    Left = 112
    Top = 12
    DOMVendorDesc = 'MSXML'
  end
end
