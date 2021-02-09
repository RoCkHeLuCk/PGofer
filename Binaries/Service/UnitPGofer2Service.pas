unit UnitPGofer2Service;

interface

uses
   Vcl.SvcMgr, Vcl.Dialogs, Winapi.Windows, Winapi.Messages, System.Classes,
   System.SysUtils, IdContext, IdBaseComponent, IdComponent, IdCustomTCPServer,
   IdTCPServer, Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc;

type
  TSvcPGofer = class(TService)
    IdTCPServer: TIdTCPServer;
    XMLDocument: TXMLDocument;
    procedure ServiceExecute(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceDestroy(Sender: TObject);
    procedure IdTCPServerExecute(AContext: TIdContext);
    procedure ServiceCreate(Sender: TObject);
  private
    { Private declarations }
    CurrentDir : AnsiString;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  SvcPGofer: TSvcPGofer;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.DFM}

//----------------------------------------------------------------------------//
procedure ServiceController(CtrlCode: DWord); stdcall;
begin
    SvcPGofer.Controller(CtrlCode);
end;
//----------------------------------------------------------------------------//
function TSvcPGofer.GetServiceController: TServiceController;
begin
    Result := ServiceController;
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.IdTCPServerExecute(AContext: TIdContext);
begin
   //
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.ServiceAfterInstall(Sender: TService);
begin
    LogMessage('Install PGofer Service OK.', EVENTLOG_SUCCESS, 0, 1);
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.ServiceAfterUninstall(Sender: TService);
begin
    LogMessage('Uninstall PGofer Service OK.', EVENTLOG_SUCCESS, 0, 1);
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
    Continued := True;
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.ServiceCreate(Sender: TObject);
begin
    CurrentDir := ExtractFilePath(Application.GetNamePath);
    XMLDocument.LoadFromFile(CurrentDir+'\Config.xml');
    XMLDocument.ChildNodes.FindNode('PGofer V2.0 Service');
    XMLDocument.Active := False;
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.ServiceDestroy(Sender: TObject);
begin
   //
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.ServiceExecute(Sender: TService);
begin
    while not Terminated do
    begin
        ServiceThread.ProcessRequests(False);
    end;
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.ServicePause(Sender: TService; var Paused: Boolean);
begin
    IdTCPServer.Active := False;
    Paused := True;
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.ServiceStart(Sender: TService; var Started: Boolean);
begin
    Started := True;
    IdTCPServer.Active := True;
end;
//----------------------------------------------------------------------------//
procedure TSvcPGofer.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
    IdTCPServer.Active := False;
    Stopped := True;
end;
//----------------------------------------------------------------------------//

end.
