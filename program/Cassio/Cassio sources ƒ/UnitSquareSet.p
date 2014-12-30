UNIT UnitSquareSet;




INTERFACE







USES MacTypes,UnitOth0;

type SquareSet = SET of 0..127;

     {le type suivant defini un ensemble de cases plus compact, mais la representation 
      est privee : on ne doit y acceder que par les fonctions d'acces}
     PackedSquareSet = record
                         private : SET of 0..63;  
                       end;
     
   
     {types fonctionels pour les iterateurs}
     SquareSetIteratorProc=procedure(var whichSquare : SInt16; var continuer : boolean);
     SquareSetIteratorProcAvecResult=procedure(var whichSquare : SInt16; var result : SInt32; var continuer : boolean);
     SquareGivesSquareFunc=function(whichSquare : SInt16) : SInt16; 
     SquareGivesSquareFuncAvecParam=function(whichSquare : SInt16; parametre : SInt32) : SInt16; 
   
{fonction de traduction}
function PackSquareSet(whichSet : SquareSet) : PackedSquareSet;
function UnpackSquareSet(whichSet : PackedSquareSet) : SquareSet;

{fonctions d'ecriture en string}
function SquareSetEnString(ensemble : SquareSet) : str255;
function PackedSquareSetEnString(ensemble : PackedSquareSet) : str255;

{iterateurs}
procedure ForEachSquareInSetDo(ensemble : SquareSet;DoWhat:SquareSetIteratorProc);
procedure ForEachSquareInPackedSetDo(ensemble : PackedSquareSet;DoWhat:SquareSetIteratorProc);
procedure ForEachSquareInSetDoAvecResult(ensemble : SquareSet;DoWhat:SquareSetIteratorProcAvecResult; var result : SInt32);
procedure ForEachSquareInPackedSetDoAvecResult(ensemble : PackedSquareSet;DoWhat:SquareSetIteratorProcAvecResult; var result : SInt32);
function MapOnSquareSet(ensemble : SquareSet;f:SquareGivesSquareFunc) : SquareSet;
function MapOnSquareSetAvecParam(ensemble : SquareSet;f:SquareGivesSquareFuncAvecParam;parametre : SInt32) : SquareSet;

{fonctions de calcul sur les PackedSquareSet}
function SquareInPackedSquareSet(whichSquare : SInt16; whichSet : PackedSquareSet) : boolean;
function UnionOfPackedSquareSet(S1,S2 : PackedSquareSet) : PackedSquareSet;
function DiffOfPackedSquareSet(S1,S2 : PackedSquareSet) : PackedSquareSet;

{fonction d'acces}
function CoupsLegauxEnSquareSet() : SquareSet;
function SquareInSquareSet(whichSquare : SInt16; whichSet : SquareSet) : boolean;

 
IMPLEMENTATION







USES UnitScannerOthellistique;




function PackSquareSet(whichSet : SquareSet) : PackedSquareSet;
var result : PackedSquareSet;
    i,j : SInt16; 
begin
  with result do
    begin
      private := [];
      for i := 1 to 8 do
        for j := 1 to 8 do
          if (i*10+j) in whichSet
            then private := private + [8*i+j-9];
    end;
  PackSquareSet := result;
end;


function UnpackSquareSet(whichSet : PackedSquareSet) : SquareSet;
var result : SquareSet;
    i : SInt16; 
begin
  result := [];
  for i := 0 to 63 do
    if i in whichSet.private 
      then result := result + [(i div 8)*10+(i mod 8)+11];
  UnpackSquareSet := result;
end;

function SquareSetEnString(ensemble : SquareSet) : str255;
var aux,i,j : SInt16; 
    s : str255;
    empty,toutEntier : boolean;
begin
  empty := true;
  toutEntier := true;
  s := '';
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        aux := j+10*i;
        if aux in ensemble 
          then 
	          begin
	            if empty
	              then s := Concat(s,'[',CoupEnStringEnMinuscules(aux),']')
	              else s := Concat(s,'[',CoupEnStringEnMinuscules(aux),']');
	            empty := false;
	          end
          else
            toutEntier := false;
      end;
  if empty 
    then SquareSetEnString := '[]'
    else SquareSetEnString := s;
end;

function PackedSquareSetEnString(ensemble : PackedSquareSet) : str255;
var aux,i,j : SInt16; 
    s : str255;
    empty : boolean;
begin
  empty := true;
  s := '';
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        aux := 8*i+j-9;
        if aux in ensemble.private then 
          begin
            if empty
              then s := Concat(s,'[',CoupEnStringEnMinuscules(i*10+j),']')
              else s := Concat(s,'[',CoupEnStringEnMinuscules(i*10+j),']');
            empty := false;
          end;
      end;
  if empty
    then PackedSquareSetEnString := '[]'
    else PackedSquareSetEnString := s;
end;


procedure ForEachSquareInSetDo(ensemble : SquareSet;DoWhat:SquareSetIteratorProc);
var i,j,aux : SInt16; 
    continuer : boolean;
begin
  continuer := true;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        aux := i*10+j;
        if aux in ensemble then
          begin
            DoWhat(aux,continuer);
            if not(continuer) then exit(ForEachSquareInSetDo);
          end;
      end;
end;

procedure ForEachSquareInPackedSetDo(ensemble : PackedSquareSet;DoWhat:SquareSetIteratorProc);
var i,j,aux : SInt16; 
    continuer : boolean;
begin
  continuer := true;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        if (8*i+j-9) in ensemble.private then
          begin
            aux := (i*10+j);
            DoWhat(aux,continuer);
            if not(continuer) then exit(ForEachSquareInPackedSetDo);
          end;
      end;
end;

procedure ForEachSquareInSetDoAvecResult(ensemble : SquareSet;DoWhat:SquareSetIteratorProcAvecResult; var result : SInt32);
var i,j,aux : SInt16; 
    continuer : boolean;
begin
  continuer := true;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        aux := i*10+j;
        if aux in ensemble then
          begin
            DoWhat(aux,result,continuer);
            if not(continuer) then exit(ForEachSquareInSetDoAvecResult);
          end;
      end;
end;

procedure ForEachSquareInPackedSetDoAvecResult(ensemble : PackedSquareSet;DoWhat:SquareSetIteratorProcAvecResult; var result : SInt32);
var i,j,aux : SInt16; 
    continuer : boolean;
begin
  continuer := true;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        if (8*i+j-9) in ensemble.private then
          begin
            aux := (i*10+j);
            DoWhat(aux,result,continuer);
            if not(continuer) then exit(ForEachSquareInPackedSetDoAvecResult);
          end;
      end;
end;

function MapOnSquareSet(ensemble : SquareSet;f:SquareGivesSquareFunc) : SquareSet;
var i,j,square,f_square : SInt16; 
    result : SquareSet;
begin
  result := [];
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        square := i*10+j;
        if square in ensemble then
          begin
            f_square := f(square);
            if (f_square>=11) & (f_square<=88) then result := result + [f_square];
          end;
      end;
  MapOnSquareSet := result;
end;

function MapOnSquareSetAvecParam(ensemble : SquareSet;f:SquareGivesSquareFuncAvecParam;parametre : SInt32) : SquareSet;
var i,j,square,f_square : SInt16; 
    result : SquareSet;
begin
  result := [];
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        square := i*10+j;
        if square in ensemble then
          begin
            f_square := f(square,parametre);
            if (f_square>=11) & (f_square<=88) then result := result + [f_square];
          end;
      end;
  MapOnSquareSetAvecParam := result;
end;


function SquareInPackedSquareSet(whichSquare : SInt16; whichSet : PackedSquareSet) : boolean;
begin
  SquareInPackedSquareSet := ((whichSquare div 10)*8+(whichSquare mod 10)-9) in whichSet.private;
end;

function UnionOfPackedSquareSet(S1,S2 : PackedSquareSet) : PackedSquareSet;
begin
  UnionOfPackedSquareSet.private := S1.private + S2.private; 
end;

function DiffOfPackedSquareSet(S1,S2 : PackedSquareSet) : PackedSquareSet;
begin
  DiffOfPackedSquareSet.private := S1.private - S2.private;
end;

function CoupsLegauxEnSquareSet() : SquareSet;
var i,j,square : SInt16; 
    result : SquareSet;
begin
  result := [];
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        square := i*10+j;
        if possibleMove[square] then
          result := result + [square];
      end;
  CoupsLegauxEnSquareSet := result;
end;

function SquareInSquareSet(whichSquare : SInt16; whichSet : SquareSet) : boolean;
begin
  SquareInSquareSet := whichSquare in whichSet;
end;

end.