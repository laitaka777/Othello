UNIT UnitHashing;



{ Fonction generique de hachage }

INTERFACE







USES MacTypes,UnitServicesMemoire,UnitMacExtras;


procedure InitUnitHashing;

{La fonction polymorphe de hachage}
function GenericHash(data : Ptr;tailleData : SInt32) : SInt32;

{fonctions de hachage specialisees}
function HashString(const s : string) : SInt32;


IMPLEMENTATION








type PackedMemory = packed array[0..0] of 0..255;
     PackedMemoryPtr= ^PackedMemory;
     
const initialisation_done : boolean = false;

var XORValues : array[0..255,0..3] of SInt32;

procedure InitUnitHashing;
var i,j : SInt16; 
    aux : SInt32;
begin
  {RandomizeTimer;}
  SetQDGlobalsRandomSeed(1000);
  
  for j := 0 to 3 do
    for i := 0 to 255 do
      begin
        aux := RandomLongint();
        if aux=0 then aux := RandomLongint();
        if aux=0 then aux := RandomLongint();
        if aux=0 then aux := RandomLongint();
        if aux=0 then aux := RandomLongint();
        if aux=0 then aux := RandomLongint();
        if aux=0 then aux := RandomLongint();
        if aux=0 then aux := RandomLongint();
        XORValues[i,j] := aux;
      end;
  initialisation_done := true;
end;

function GenericHash(data : Ptr;tailleData : SInt32) : SInt32;
var aux,result,i : SInt32;
    memoryBuffer:PackedMemoryPtr;
begin
  if not(initialisation_done) then 
    begin
      (* Writeln('Calling InitUnitHashing for you : you should do it yourself !'); *)
      InitUnitHashing;
    end;

  memoryBuffer := PackedMemoryPtr(data);
  aux := 1013904223; (* See Numerical Recipes in C, 2nd Edition, p.284 *)
  for i := 0 to tailleData-1 do
    begin
      (* Writeln('aux=',aux); *)
      
      (* 1664525 = nb impair pas trop pres d'une puissance de deux.
         See Numerical Recipes in C, 2nd Edition, p.284 *)
      aux := aux*1664525+memoryBuffer^[i];  
      
      (* Writeln(chr(memoryBuffer^[i]),memoryBuffer^[i]); *)
    end;
  
  (* Writeln('');
     Writeln('aux=',aux);  *)
    
  memoryBuffer := PackedMemoryPtr(@aux);
 
  (* 
  Writeln('aux[0]=',memoryBuffer^[0]); 
  Writeln('aux[1]=',memoryBuffer^[1]);
  Writeln('aux[2]=',memoryBuffer^[2]);
  Writeln('aux[3]=',memoryBuffer^[3]);
  *)
  
  result := BXOR(XORValues[memoryBuffer^[0],0], XORValues[memoryBuffer^[1],1]);
  result := BXOR(result, XORValues[memoryBuffer^[2],2]);
  result := BXOR(result, XORValues[memoryBuffer^[3],3]);
  
  GenericHash := result;
end;


function HashString(const s : string) : SInt32;
begin
  HashString := GenericHash(@s,Length(s)+1);
end;


END.











