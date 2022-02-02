unit PGofer.Math;

interface

uses
  PGofer.Sintatico.Classes;

type
  // ????????? Arrumar o Deg, RAD, GRA do Math

  {$M+}
  TPGMath = class( TPGItemCMD )
  private
  public
  published
    function Abs( Valor: Extended ): Extended;
    function ArcCos( Valor: Extended ): Extended;
    function ArcSin( Valor: Extended ): Extended;
    function ArcTan( Valor: Extended ): Extended;
    function Bin( Valor: Int64 ): string;
    function Cos( Valor: Extended ): Extended;
    function Cosecant( Valor: Extended ): Extended;
    function Cotan( Valor: Extended ): Extended;
    function DegToGrad( Valor: Extended ): Extended;
    function DegToRad( Valor: Extended ): Extended;
    function Format( Prefix: Boolean; Format: string; Valor: Extended ): string;
    function GradToDeg( Valor: Extended ): Extended;
    function GradToRad( Valor: Extended ): Extended;
    function Hex( Valor: UInt64 ): string;
    function Hypot( Base, Valor: Extended ): Extended;
    function Log( Base, Valor: Extended ): Extended;
    function RadToDeg( Valor: Extended ): Extended;
    function RadToGrad( Valor: Extended ): Extended;
    procedure Randomized( );
    function Random( Max: Integer ): Integer;
    function Secant( Valor: Extended ): Extended;
    function Sin( Valor: Extended ): Extended;
    function Tan( Valor: Extended ): Extended;
  end;
  {$TYPEINFO ON}

var
  PGMath: TPGMath;

implementation

uses
  System.SysUtils, System.Math,
  PGofer.Sintatico, PGofer.Math.Controls;

{ TPGMath }

function TPGMath.Abs( Valor: Extended ): Extended;
begin
  Result := System.Abs( Valor );
end;

function TPGMath.ArcCos( Valor: Extended ): Extended;
begin
  Result := System.Math.ArcCos( Valor );
end;

function TPGMath.ArcSin( Valor: Extended ): Extended;
begin
  Result := System.Math.ArcSin( Valor );
end;

function TPGMath.ArcTan( Valor: Extended ): Extended;
begin
  Result := System.ArcTan( Valor );
end;

function TPGMath.Bin( Valor: Int64 ): string;
begin
  Result := IntToBin( Valor );
end;

function TPGMath.Cos( Valor: Extended ): Extended;
begin
  Result := System.Cos( Valor );
end;

function TPGMath.Cosecant( Valor: Extended ): Extended;
begin
  Result := System.Math.Cosecant( Valor );
end;

function TPGMath.Cotan( Valor: Extended ): Extended;
begin
  Result := System.Math.Cotan( Valor );
end;

function TPGMath.DegToGrad( Valor: Extended ): Extended;
begin
  Result := System.Math.DegToGrad( Valor );
end;

function TPGMath.DegToRad( Valor: Extended ): Extended;
begin
  Result := System.Math.DegToRad( Valor );
end;

function TPGMath.Format( Prefix: Boolean; Format: string;
  Valor: Extended ): string;
begin
  Result := PGofer.Math.Controls.FormatConvert( Prefix, Format, Valor );
end;

function TPGMath.GradToDeg( Valor: Extended ): Extended;
begin
  Result := System.Math.GradToDeg( Valor );
end;

function TPGMath.GradToRad( Valor: Extended ): Extended;
begin
  Result := System.Math.GradToRad( Valor );
end;

function TPGMath.Hex( Valor: UInt64 ): string;
begin
  Result := System.SysUtils.IntToHex( Valor );
end;

function TPGMath.Hypot( Base, Valor: Extended ): Extended;
begin
  Result := System.Math.Hypot( Base, Valor );
end;

function TPGMath.Log( Base, Valor: Extended ): Extended;
begin
  Result := System.Math.LogN( Base, Valor );
end;

function TPGMath.RadToDeg( Valor: Extended ): Extended;
begin
  Result := System.Math.RadToDeg( Valor );
end;

function TPGMath.RadToGrad( Valor: Extended ): Extended;
begin
  Result := System.Math.RadToGrad( Valor );
end;

function TPGMath.Random( Max: Integer ): Integer;
begin
  Result := System.Random( Max );
end;

procedure TPGMath.Randomized;
begin
  System.Randomize;
end;

function TPGMath.Secant( Valor: Extended ): Extended;
begin
  Result := System.Math.Secant( Valor );
end;

function TPGMath.Sin( Valor: Extended ): Extended;
begin
  Result := System.Sin( Valor );
end;

function TPGMath.Tan( Valor: Extended ): Extended;
begin
  Result := System.Math.Tan( Valor );
end;

initialization

TPGMath.Create( GlobalItemCommand );

finalization

end.
