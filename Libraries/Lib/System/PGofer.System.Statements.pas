unit PGofer.System.Statements;

interface

uses
  PGofer.Sintatico,
  PGofer.Sintatico.Classes;

type
  TPGCopy = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGDelete = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGFor = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGIf = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGIsDef = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGInsert = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGRead = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGRepeat = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGUnDef = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGWhile = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

  TPGWrite = class( TPGItemCMD )
  public
    procedure Execute( Gramatica: TGramatica ); override;
  end;

implementation

uses
  System.SysUtils,
  Vcl.Dialogs,
  PGofer.Classes,
  PGofer.Lexico,
  PGofer.Sintatico.Controls,
  PGofer.System.Variants;

{ TPGCopy }

procedure TPGCopy.Execute( Gramatica: TGramatica );
var
  Valor: string;
  Inicio, Fim: SmallInt;
begin
  LerParamentros( Gramatica, 3, 3 );
  Fim := Gramatica.Pilha.Desempilhar( 0 );
  Inicio := Gramatica.Pilha.Desempilhar( 0 );
  Valor := Gramatica.Pilha.Desempilhar( '' );
  if ( not Gramatica.Erro ) then
  begin
    Gramatica.Pilha.Empilhar( Copy( Valor, Inicio, Fim ) );
  end;
end;

{ TPGDelete }

procedure TPGDelete.Execute( Gramatica: TGramatica );
var
  Valor: string;
  Inicio, Fim: SmallInt;
begin
  LerParamentros( Gramatica, 3, 3 );
  Fim := Gramatica.Pilha.Desempilhar( 0 );
  Inicio := Gramatica.Pilha.Desempilhar( 0 );
  Valor := Gramatica.Pilha.Desempilhar( '' );
  if ( not Gramatica.Erro ) then
  begin
    System.Delete( Valor, Inicio, Fim );
    Gramatica.Pilha.Empilhar( Valor );
  end;
end;

{ TPGFor }

procedure TPGFor.Execute( Gramatica: TGramatica );
var
  ID: TPGItem;
  Variavel: TPGVariant;
  VarInicio, VarLimite: Int64;
  LoopContador: Int64;
  Decrecente: Boolean;
  PositionIni: FixedInt;
begin
  Gramatica.TokenList.GetNextToken;
  ID := IdentificadorLocalizar( Gramatica );

  if ( ID.ClassType = TPGVariant ) then
  begin
    Variavel := TPGVariant( ID );
    Variavel.Execute( Gramatica );
    VarInicio := Variavel.Value;
    if ( not Gramatica.Erro ) and ( Gramatica.TokenList.Token.Classe
       in [ cmdRes_downto, cmdRes_to ] ) then
    begin
      Decrecente := ( Gramatica.TokenList.Token.Classe = cmdRes_downto );
      Gramatica.TokenList.GetNextToken;
      Expressao( Gramatica );
      VarLimite := Gramatica.Pilha.Desempilhar( 0 );
      if ( not Gramatica.Erro ) and
         ( Gramatica.TokenList.Token.Classe = cmdRes_do ) then
      begin
        Gramatica.TokenList.GetNextToken;
        PositionIni := Gramatica.TokenList.Position;
        if ( VarInicio <> VarLimite ) then
        begin
          LoopContador := 0;
          while ( not Gramatica.Erro ) and ( LoopContador < LoopLimite ) and
             ( ( ( not Decrecente ) and ( VarInicio <= VarLimite ) ) or
             ( ( Decrecente ) and ( VarInicio >= VarLimite ) ) ) do
          begin
            Gramatica.TokenList.Position := PositionIni;
            Comandos( Gramatica );

            if Decrecente then
              Dec( VarInicio )
            else
              Inc( VarInicio );

            Inc( LoopContador );
            Variavel.Value := VarInicio;
          end;

          if ( LoopContador >= LoopLimite ) then
          begin
            Gramatica.ErroAdd( 'Loops Excedidos.' );
          end;

        end
        else
          EncontrarFim( Gramatica,
             ( Gramatica.TokenList.Token.Classe = cmdRes_begin ) );
      end
      else
        Gramatica.ErroAdd( '"Do" esperado.' );
    end
    else
      Gramatica.ErroAdd( '"To" ou "DownTo" esperado.' );
  end
  else
    Gramatica.ErroAdd( 'Variavel esperada.' );
end;

{ TPGIf }

procedure TPGIf.Execute( Gramatica: TGramatica );
var
  Continuar: Boolean;
begin
  // executa a condição
  Gramatica.TokenList.GetNextToken;
  Expressao( Gramatica );

  if ( not Gramatica.Erro ) then
  begin
    Continuar := Gramatica.Pilha.Desempilhar( false );

    if ( Gramatica.TokenList.Token.Classe = cmdRes_then ) then
    begin
      Gramatica.TokenList.GetNextToken;
      if Continuar then
        Comandos( Gramatica )
      else
        EncontrarFim( Gramatica,
           ( Gramatica.TokenList.Token.Classe = cmdRes_begin ) );
    end
    else
      Gramatica.ErroAdd( '"Then" Esperado.' );

    // verifica se tem ELSE
    if ( not Gramatica.Erro ) and
       ( Gramatica.TokenList.Token.Classe = cmdRes_else ) then
    begin
      Gramatica.TokenList.GetNextToken;
      if not Continuar then
        Comandos( Gramatica )
      else
        EncontrarFim( Gramatica,
           ( Gramatica.TokenList.Token.Classe = cmdRes_begin ) );
    end;
  end
  else
    Gramatica.ErroAdd( '"Expressão Booleana" Esperado.' );
end;

{ TPGisDef }

procedure TPGIsDef.Execute( Gramatica: TGramatica );
var
  Nome: string;
begin
  Gramatica.TokenList.GetNextToken;
  if Gramatica.TokenList.Token.Classe = cmdLPar then
  begin
    Gramatica.TokenList.GetNextToken;
    Expressao( Gramatica );
    if ( Gramatica.TokenList.Token.Classe <> cmdRPar ) then
      Gramatica.ErroAdd( '")" Esperado.' )
    else
    begin
      Nome := Gramatica.Pilha.Desempilhar( '' );
      Gramatica.Pilha.Empilhar( Assigned( FindID( Gramatica.Local, Nome ) ) );
      Gramatica.TokenList.GetNextToken;
    end;
  end
  else
    Gramatica.ErroAdd( '"(" Esperado.' );
end;

{ TPGInsert }

procedure TPGInsert.Execute( Gramatica: TGramatica );
var
  Valor1, Valor2: string;
  Inicio: SmallInt;
begin
  LerParamentros( Gramatica, 3, 3 );
  Inicio := Gramatica.Pilha.Desempilhar( 0 );
  Valor2 := Gramatica.Pilha.Desempilhar( '' );
  Valor1 := Gramatica.Pilha.Desempilhar( '' );
  if ( not Gramatica.Erro ) then
  begin
    System.Insert( Valor2, Valor1, Inicio );
    Gramatica.Pilha.Empilhar( Valor1 );
  end;
end;

{ TPGRead }

procedure TPGRead.Execute( Gramatica: TGramatica );
var
  S, P: string;
begin
  // read
  LerParamentros( Gramatica, 2, 2 );
  P := Gramatica.Pilha.Desempilhar( '' );
  S := Gramatica.Pilha.Desempilhar( '' );
  if ( not Gramatica.Erro ) then
    Gramatica.Pilha.Empilhar( InputBox( 'PGofer', S, P ) );
end;

{ TPGRepeat }

procedure TPGRepeat.Execute( Gramatica: TGramatica );
var
  LoopContador: Int64;
  Continuar: Boolean;
  PositionIni: FixedInt;
begin
  LoopContador := 0;
  Continuar := false;
  Gramatica.TokenList.GetNextToken;
  PositionIni := Gramatica.TokenList.Position;
  repeat
    Gramatica.TokenList.Position := PositionIni;
    // executa a sentença
    Sentencas( Gramatica );

    // verifica a condição
    if ( Gramatica.TokenList.Token.Classe = cmdRes_until ) then
    begin
      Gramatica.TokenList.GetNextToken;
      Expressao( Gramatica );
      Continuar := Gramatica.Pilha.Desempilhar( false );
    end
    else
      Gramatica.ErroAdd( '"Until" esperado' );
    Inc( LoopContador );
    // verifica e executa novamente
  until ( Continuar or Gramatica.Erro or ( LoopContador >= LoopLimite ) );

  if ( LoopContador >= LoopLimite ) then
    Gramatica.ErroAdd( 'Loops Excedidos.' );
end;

{ TPGUnDef }

procedure TPGUnDef.Execute( Gramatica: TGramatica );
var
  Nome: string;
  Item: TPGItem;
begin
  Gramatica.TokenList.GetNextToken;
  if Gramatica.TokenList.Token.Classe = cmdLPar then
  begin
    Gramatica.TokenList.GetNextToken;
    Expressao( Gramatica );
    if ( Gramatica.TokenList.Token.Classe <> cmdRPar ) then
      Gramatica.ErroAdd( '")" Esperado.' )
    else
    begin
      Nome := Gramatica.Pilha.Desempilhar( '' );
      Item := FindID( Gramatica.Local, Nome );
      if Assigned( Item ) then
      begin
        Item.Free;
        Gramatica.Pilha.Empilhar( True );
      end
      else
        Gramatica.Pilha.Empilhar( false );
      Gramatica.TokenList.GetNextToken;
    end;
  end
  else
    Gramatica.ErroAdd( '"(" Esperado.' );
end;

{ TPGWhile }

procedure TPGWhile.Execute( Gramatica: TGramatica );
var
  LoopContador: Int64;
  Continuar: Boolean;
  PositionIni: FixedInt;
begin
  Gramatica.TokenList.GetNextToken;
  PositionIni := Gramatica.TokenList.Position;
  LoopContador := 0;
  Continuar := True;
  while ( Continuar ) and ( not Gramatica.Erro ) and
     ( LoopContador < LoopLimite ) do
  begin
    Gramatica.TokenList.Position := PositionIni;
    // Expressao
    Expressao( Gramatica );
    if ( not Gramatica.Erro ) then
    begin
      Continuar := Gramatica.Pilha.Desempilhar( false );
      // Executar
      if ( Gramatica.TokenList.Token.Classe = cmdRes_do ) then
      begin
        Gramatica.TokenList.GetNextToken;
        if Continuar then
          Comandos( Gramatica )
        else
          EncontrarFim( Gramatica,
             ( Gramatica.TokenList.Token.Classe = cmdRes_begin ) );
      end
      else
        Gramatica.ErroAdd( '"Do" esperado.' );
    end;
    Inc( LoopContador );
  end;

  if ( LoopContador >= LoopLimite ) then
    Gramatica.ErroAdd( 'Loops Excedidos.' );
end;

{ TPGWrite }

procedure TPGWrite.Execute( Gramatica: TGramatica );
var
  S: string;
begin
  // write
  LerParamentros( Gramatica, 1, 1 );
  S := Gramatica.Pilha.Desempilhar( '' );
  Gramatica.MSGsAdd( S );
end;

initialization

TPGCopy.Create( GlobalItemCommand );
TPGDelete.Create( GlobalItemCommand );
TPGFor.Create( GlobalItemCommand );
TPGIf.Create( GlobalItemCommand );
TPGIsDef.Create( GlobalItemCommand );
TPGInsert.Create( GlobalItemCommand );
TPGRead.Create( GlobalItemCommand );
TPGRepeat.Create( GlobalItemCommand );
TPGUnDef.Create( GlobalItemCommand );
TPGWhile.Create( GlobalItemCommand );
TPGWrite.Create( GlobalItemCommand );

finalization

end.
