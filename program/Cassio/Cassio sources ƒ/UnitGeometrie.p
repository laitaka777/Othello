UNIT UnitGeometrie;


INTERFACE







USES MacTypes,QuickDraw,UnitMacExtras;

function  ADroite(x1,y1,x2,y2,xM,yM : SInt32) : boolean;
procedure Intersection(xA1,yA1,xA2,yA2,XB1,yB1,xB2,YB2 : SInt32; var x,y : SInt32);
function InterpolerRectangles(rectA,rectB : rect;n,k : SInt32) : rect;
function SegmentIntersecteRect(M1,M2 : Point;theRect : rect) : boolean;

IMPLEMENTATION







{ renvoie true si M est a droite de la droite M1,M2}
function  ADroite(x1,y1,x2,y2,xM,yM : SInt32) : boolean;
var dx,dy : extended;
begin
  dx := x1-x2;
  dy := y1-y2;
  ADroite := (xM-x1)*dy-(yM-y1)*dx < 0;
end;


{renvoie dans x,y l'Intersection des droites (A1,A2) et (B1,B2)}
procedure Intersection(xA1,yA1,xA2,yA2,XB1,yB1,xB2,YB2 : SInt32; var x,y : SInt32);
var dxA,dyA,dxB,dyB,A,B,delta : extended;
begin
  dxA := xA1-xA2;
  dyA := yA1-yA2;
  dxB := xB1-xB2;
  dyB := yB1-yB2;
  A := xA1*1.0*dyA-yA1*1.0*dxA;
  B := xB1*1.0*dyB-yB1*1.0*dxB;
  delta := -(dyA*dxB-dxA*dyB);
  if delta <> 0.0
    then
      begin
        x := MyTrunc((dxA*B-dxB*A)*1.0/delta+0.5);
        y := MyTrunc((dyA*B-dyB*A)*1.0/delta+0.5);
      end
    else  {erreur!!! droites paralleles !!! => on renvoie A1}
      begin
        x := xA1;
        y := yA1;
      end;
end;


{on renvoye A + u(B-A)}
function InterpolerExtended(A,B : extended;u : extended) : extended;
begin
  InterpolerExtended := A + u*(B-A);
end;

{renvoie le k-ieme rectangle d'interpolation entre 
  rectA = le 0-ieme rectangle
  rectB = le n-ieme rectangle }
function InterpolerRectangles(rectA,rectB : rect;n,k : SInt32) : rect;
var xMilA,yMilA,xMilB,yMilB,xMilRes,yMilRes : extended;
    largA,largB,hautA,hautB,hautRes,largRes : extended;
    ratio : extended;
    result : rect;
begin
  
  if n <> 0
    then ratio := (k*1.0)/(n*1.0)
    else ratio := 0;  {erreur !! on va donc renvoyer rectA...}
  
  xMilA := 0.5 * (rectA.left + rectA.right);
  yMilA := 0.5 * (rectA.top + rectA.bottom);
  
  xMilB := 0.5 * (rectB.left + rectB.right);
  yMilB := 0.5 * (rectB.top + rectB.bottom);
  
  xMilRes := InterpolerExtended(xMilA,xMilB,ratio);
  yMilRes := InterpolerExtended(yMilA,yMilB,ratio);
  
  largA := rectA.right  - rectA.left;
  hautA := rectA.bottom - rectA.top;
  
  largB := rectB.right  - rectB.left;
  hautB := rectB.bottom - rectB.top;
  
  largRes := InterpolerExtended(largA,largB,ratio);
  hautRes := InterpolerExtended(hautA,hautB,ratio);
  
  with result do
    begin
      left    := MyTrunc(xMilRes - 0.5*largRes + 0.49999);
      right   := MyTrunc(xMilRes + 0.5*largRes + 0.49999);
      top     := MyTrunc(yMilRes - 0.5*hautRes + 0.49999);
      bottom  := MyTrunc(yMilRes + 0.5*hautRes + 0.49999);
    end;
  
  InterpolerRectangles := result;
end;


{renvoie true si le segment M1-M2 intersecte le rectangle theRect}
function SegmentIntersecteRect(M1,M2 : Point;theRect : rect) : boolean;
var auxRect,inter : rect;
    droite,tousDuMemeCote : boolean;
begin
  InSetRect(theRect,-3,-3);
  if PtInRect(M1,theRect) | PtInRect(M2,theRect) then
    begin
      SegmentIntersecteRect := true;
      exit(SegmentIntersecteRect);
    end;
    
  {les points M1 et M2 sont en dehors de theRect}
  auxRect := MakeRect(Min(M1.h,M2.h)-1,Min(M1.v,M2.v)-1,Max(M1.h,M2.h)+1,Max(M1.v,M2.v)+1);
  
  {si les bounding box sont disjointes, pas d'intersection...}
  if not(SectRect(auxRect,theRect,inter)) then
    begin
      SegmentIntersecteRect := false;
      exit(SegmentIntersecteRect);
    end;
    
  {les quatre angles du rectangle sont-ils du meme cote ?}
  with theRect do
    begin
      tousDuMemeCote := true;
      droite := ADroite(M1.h,M1.v,M2.h,M2.v,left,top);
      tousDuMemeCote := tousDuMemeCote & (droite = ADroite(M1.h,M1.v,M2.h,M2.v,left,bottom));
      tousDuMemeCote := tousDuMemeCote & (droite = ADroite(M1.h,M1.v,M2.h,M2.v,right,bottom));
      tousDuMemeCote := tousDuMemeCote & (droite = ADroite(M1.h,M1.v,M2.h,M2.v,right,top));
    end;
     
  SegmentIntersecteRect := not(tousDuMemeCote);
end;



END.