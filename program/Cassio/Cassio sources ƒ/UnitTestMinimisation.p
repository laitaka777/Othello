UNIT UnitTestMinimisation;


INTERFACE






  
  
procedure TestMinimisation;
procedure TestStraightLineFitting;


IMPLEMENTATION







USES UnitMinimisation,UnitRapport,UnitStatisticalFitting,SNStrings;


function f(x : PointMultidimensionnel) : TypeReel;
begin
  f := sqr(x^[1]-1.0)+sqr(x^[2]+5.0)+sqr(x^[3]-3.141592659);
end;


procedure TestMinimisation;
var j,n,nbiter : SInt32;
    p : PointMultidimensionnel;
    resultat,tolerance : TypeReel;
begin
  n := 3;
  if AllocatePointMultidimensionnel(n,p) then
    begin
      for j := 1 to n do 
        p^[j] := 100.0;
      
      tolerance := 0.001;
      MinimisationMultidimensionnelleParConjugateGradient(f,p,tolerance,nbiter,resultat);
      
      WritelnStringAndNumDansRapport('nbiter=',nbiter);
      WritelnDansRapport('positions du minimum :');
      for j := 1 to n do
        begin
          WritelnDansRapport('p['+NumEnString(j)+']='+ReelEnStringAvecDecimales(p^[j],10));
        end;
      WritelnDansRapport('minimum='+ReelEnStringAvecDecimales(resultat,10));
      
      DisposePointMultidimensionnel(p);
    end;
  
end;

procedure TestStraightLineFitting;
var n,k : SInt32;
    valPetiteProf,valGrandeProf : TypeReel;
    x,y,sigma : PointMultidimensionnel;
    a,b,sigmaa,sigmab,chi2,q : TypeReel;
    pente : TypeReel;
begin
  n := 100;
  x := NIL;
  y := NIL;
  sigma := NIL;
  if AllocatePointMultidimensionnel(n,x) & 
     AllocatePointMultidimensionnel(n,y) then
    begin
      RandomizeTimer;
      for k := 1 to n do
        begin
        
          pente := Abs(Random())/32768.0;   {nombre aleatoire entre 0.0 et 1.0}
        
          valPetiteProf := RandomLongintEntreBornes(-6400,6400);
          valGrandeProf := pente*valPetiteProf + RandomLongintEntreBornes(-500,500);
          
          x^[k] := valPetiteProf;
          y^[k] := valGrandeProf;
        end;
      
      
      
      StraightLineFitting(x,y,sigma,n,false,a,b,sigmaa,sigmab,chi2,q);
                              
      WritelnDansRapport('a='+ReelEnStringAvecDecimales(a,10));
      WritelnDansRapport('b='+ReelEnStringAvecDecimales(b,10));
      WritelnDansRapport('sigmaa='+ReelEnStringAvecDecimales(sigmaa,10));
      WritelnDansRapport('sigmab='+ReelEnStringAvecDecimales(sigmab,10));
      WritelnDansRapport('chi2='+ReelEnStringAvecDecimales(chi2,10));
      WritelnDansRapport('sigdata='+ReelEnStringAvecDecimales(sqrt(chi2/(n-2)),10));
      WritelnDansRapport('q='+ReelEnStringAvecDecimales(q,10));
      
      DisposePointMultidimensionnel(x);
      DisposePointMultidimensionnel(y);
      DisposePointMultidimensionnel(sigma);
    end;
  
  
end;


END.