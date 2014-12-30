UNIT UnitPackedOthelloPosition;



INTERFACE







USES UnitOth0;
  


type 
  PackedOthelloPosition = packed array[0..15] of 0..255;
  
  
{fonctions de conversion}
function PlOthToPackedOthelloPosition(const board : plateauOthello):PackedOthelloPosition;
function PackedOthelloPositionToPlOth(const packedBoard:PackedOthelloPosition) : plateauOthello;
  
  
{compile et decompile une position dans une chaine de 16 caracteres}
procedure CompilerPosition(plat : plateauOthello; var chaineCompilee : str255);
procedure DecompilerPosition(chaineCompilee : str255; var plat : plateauOthello);



IMPLEMENTATION







USES UnitMacExtras;


{fonctions de conversion}


function PlOthToPackedOthelloPosition(const board : plateauOthello):PackedOthelloPosition;
var s : str255;
    i : SInt32;
    result:PackedOthelloPosition;
begin
  CompilerPosition(board,s);
  for i := 1 to 16 do
    result[i-1] := ord(s[i]);
  PlOthToPackedOthelloPosition := result;
end;


function PackedOthelloPositionToPlOth(const packedBoard:PackedOthelloPosition) : plateauOthello;
var s : str255;
    i : SInt32;
    result : plateauOthello;
begin
  s[0] := chr(16);
  for i := 1 to 16 do
    s[i] := chr(packedBoard[i-1]);
  DecompilerPosition(s,result);
  PackedOthelloPositionToPlOth := result;
end;


{compile une position en 16 octets dans chaineCompilee}
procedure CompilerPosition(plat : plateauOthello; var chaineCompilee : str255);
var i,j,x : SInt16; 
    s : str255;
    intermed : deuxOctets;
    puiss2 : array[0..15] of SInt32;
    somme : SInt32;
begin
  puiss2[15] := 1;
  for i := 14 downto 0 do
    puiss2[i] := 2*puiss2[i+1];
  s := '';
  for j := 1 to 8 do
    begin
      somme := 0;
      for i := 1 to 8 do
        begin
          x := 10*j+i;
          if plat[x] = pionVide
            then
              begin
                somme := somme+puiss2[i*2-2]*0;
                somme := somme+puiss2[i*2-1]*0;
              end
            else
              begin
                somme := somme+puiss2[i*2-2]*1;
                if plat[x] = pionNoir 
                  then somme := somme+puiss2[i*2-1]*1
                  else somme := somme+puiss2[i*2-1]*0;
              end;
        end;
      intermed[0] := somme div 256;
      intermed[1] := somme mod 256;
      s := s + chr(intermed[0]) + chr(intermed[1]);
    end;
  chaineCompilee := s;
end;

{decompile les 16 octets de chaineCompilee et met la position resultante dans plat}
procedure DecompilerPosition(chaineCompilee : str255; var plat : plateauOthello);
var i,j,x : SInt16; 
    intermed : deuxOctets;
    aux,code : SInt32;
begin
  if Length(chaineCompilee)=16 then
    begin
      MemoryFillChar(@plat,sizeof(plat),chr(0));
      for i := 0 to 99 do
        if interdit[i] then plat[i] := PionInterdit;
      for j := 1 to 8 do
        begin
          intermed[0] := ord(chaineCompilee[2*j-1]);
          intermed[1] := ord(chaineCompilee[2*j]);
          aux := 256*intermed[0]+intermed[1];
          if aux<0 then aux := aux+65536;
          for i := 1 to 8 do
            begin
              x := 10*j+(9-i);
              code := aux mod 4;
              if (code=1) | (code=0)
                then plat[x] := pionVide
                else
                  begin
                    if (code=3)
                      then plat[x] := pionNoir
                      else plat[x] := pionBlanc;
                  end;
               aux := aux div 4;
            end;
        end;
    end;
end;

END.