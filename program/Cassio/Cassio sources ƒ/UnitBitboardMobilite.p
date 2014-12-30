UNIT UnitBitboardMobilite;


INTERFACE







USES UnitBitboardTypes,UnitPositionEtTrait;



{$IFC USING_BITBOARD}


procedure TestMobiliteBitbooard(var whichPosition : PositionEtTraitRec);
function CalculeMobiliteBitboard(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32) : SInt32;
function PositionEtTraitToBitboard(var whichPosition : PositionEtTraitRec):bitboard;



{$ENDC}



IMPLEMENTATION







USES MacTypes,UnitUtilitaires,SNStrings,UnitStrategie,UnitRapport;


{$IFC USING_BITBOARD}


{  $ p r a g m a c  optimization_level 4}

function CalculeMobiliteBitboard(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32) : SInt32;
var coup_legaux_lo,coup_legaux_hi : UInt32;
    constante2,constante3,constante4,constante5,constante6,constante7 : UInt32;
    opp,my : UInt32;
    result_lo,result_hi : UInt32;
begin

  (*
  EcritBitboardDansRapport('position = ',MakeBitboard(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high));
  *)
  
  {retournements horizontaux de droite a gauche }
  
  constante7 := $01010101;
  constante6 := $03030303;
  constante5 := $07070707;
  constante4 := $0F0F0F0F;
  constante3 := $1F1F1F1F;
  constante2 := $3F3F3F3F;
  
  
  
  result_lo := ((my_bits_low  shr 7) and constante7) and (opp_bits_low shr 6);
  
  opp       := (opp_bits_low shr 5);
  my        := (my_bits_low  shr 6)  and constante6;
  result_lo := (result_lo or my) and opp;
  
  opp       := (opp_bits_low shr 4);
  my        := (my_bits_low  shr 5)  and constante5;
  result_lo := (result_lo or my) and opp;
  
  opp       := (opp_bits_low shr 3);
  my        := (my_bits_low  shr 4)  and constante4;
  result_lo := (result_lo or my) and opp;
  
  opp       := (opp_bits_low shr 2);
  my        := (my_bits_low  shr 3)  and constante3;
  result_lo := (result_lo or my) and opp;
  
  opp       := (opp_bits_low shr 1);
  my        := (my_bits_low  shr 2)  and constante2;
  coup_legaux_lo := (result_lo or my) and opp;
  
  result_hi := ((my_bits_high  shr 7) and constante7) and (opp_bits_high shr 6);
  
  opp       := (opp_bits_high shr 5);
  my        := (my_bits_high  shr 6) and constante6;
  result_hi := (result_hi or my) and opp;
  
  opp       := (opp_bits_high shr 4);
  my        := (my_bits_high  shr 5) and constante5;
  result_hi := (result_hi or my) and opp;
  
  opp       := (opp_bits_high shr 3);
  my        := (my_bits_high  shr 4) and constante4;
  result_hi := (result_hi or my) and opp;
  
  opp       := (opp_bits_high shr 2);
  my        := (my_bits_high  shr 3) and constante3;
  result_hi := (result_hi or my) and opp;
  
  opp       := (opp_bits_high shr 1);
  my        := (my_bits_high  shr 2) and constante2;
  coup_legaux_hi := (result_hi or my) and opp;
  
  
  
  
  
  {retournements diagonaux de H1 vers A8 de haut en bas}
    
  result_hi := ((my_bits_low shl 17) and constante7) and (opp_bits_low shl 10);
  
  opp       := (opp_bits_low shl 3);
  my        := (my_bits_low shl 10);
  result_hi := (result_hi or (my and constante6)) and opp;
  
  opp       := (opp_bits_high shl 28) or (opp_bits_low shr 4);
  my        := (my_bits_low shl 3);
  result_hi := (result_hi or (my and constante5)) and opp;
  
  opp       := (opp_bits_high shl 21) or (opp_bits_low shr 11);
  my        := (my_bits_high  shl 28) or (my_bits_low shr 4);
  result_hi := (result_hi or (my and constante4)) and opp;
  
  opp       := (opp_bits_high shl 14) or (opp_bits_low shr 18);
  my        := (my_bits_high  shl 21) or (my_bits_low  shr 11);
  result_hi := (result_hi or (my and constante3)) and opp;
  
  opp       := (opp_bits_high shl 7)  or (opp_bits_low shr 25);
  my        := (my_bits_high  shl 14) or (my_bits_low  shr 18);
  coup_legaux_hi := coup_legaux_hi or ((result_hi or (my and constante2)) and opp);
  
  
  opp       := (opp_bits_low  shl 21);
  my        := (my_bits_low   shl 28);
  result_lo := (my and constante4) and opp;
  
  opp       := (opp_bits_low  shl 14);
  my        := (my_bits_low   shl 21);
  result_lo := (result_lo or (my and constante3)) and opp;
  
  opp       := (opp_bits_low  shl 7);
  my        := (my_bits_low   shl 14);
  coup_legaux_lo := coup_legaux_lo or ((result_lo or (my and constante2)) and opp);
  
  
  
  {retournements diagonaux de H8 vers A1 vers le haut}
  
  result_lo := ((my_bits_high shr 31) and constante7) and (opp_bits_high shr 22);
  
  opp       := (opp_bits_high shr 13);
  my        := (my_bits_high shr 22);
  result_lo := (result_lo or (my and constante6)) and opp;
  
  opp       := (opp_bits_high shr 4);
  my        := (my_bits_high shr 13);
  result_lo := (result_lo or (my and constante5)) and opp;
  
  opp       := (opp_bits_low  shr 27) or (opp_bits_high shl 5);
  my        := (my_bits_high shr 4);
  result_lo := (result_lo or (my and constante4)) and opp;
  
  opp       := (opp_bits_low shr 18) or (opp_bits_high shl 14);
  my        := (my_bits_low  shr 27) or (my_bits_high  shl 5);
  result_lo := (result_lo or (my and constante3)) and opp;
  
  opp       := (opp_bits_low shr 9)  or (opp_bits_high shl 23);
  my        := (my_bits_low  shr 18) or (my_bits_high  shl 14);
  coup_legaux_lo := coup_legaux_lo or ((result_lo or (my and constante2)) and opp);
  
  
  opp       := (opp_bits_high  shr 18);
  my        := (my_bits_high   shr 27);
  result_hi := ((my and constante3)) and opp;
  
  opp       := (opp_bits_high  shr 9);
  my        := (my_bits_high   shr 18);
  coup_legaux_hi := coup_legaux_hi or ((result_hi or (my and constante2)) and opp);
  
  
  
  {retournements horizontaux de gauche a droite }
  
  constante2 := $7E7E7E7E;
  
  { this version is faster that the obvious one : it uses carries to "flip" bits }
  my             := (my_bits_low shl 1);
  opp            := (opp_bits_low and constante2);
  coup_legaux_lo := coup_legaux_lo or ((my + opp) and not(my));
  
  my             := (my_bits_high shl 1);
  opp            := (opp_bits_high and constante2);
  coup_legaux_hi := coup_legaux_hi or ((my + opp) and not(my));
  
  
  
  {retournements diagonaux de A1 vers H8 de haut en bas}
  
  
  constante7 := $80808080;
  constante6 := $C0C0C0C0;
  constante5 := $E0E0E0E0;
  constante4 := $F0F0F0F0;
  constante3 := $F8F8F8F8;
  constante2 := $FCFCFCFC;

  
  result_hi := ((my_bits_low shl 31) and constante7) and (opp_bits_low shl 22);
  
  opp       := (opp_bits_low shl 13);
  my        := (my_bits_low shl 22);
  result_hi := (result_hi or (my and constante6)) and opp;
  
  opp       := (opp_bits_low shl 4);
  my        := (my_bits_low shl 13);
  result_hi := (result_hi or (my and constante5)) and opp;
  
  opp       := (opp_bits_high shl 27) or (opp_bits_low shr 5);
  my        := (my_bits_low shl 4);
  result_hi := (result_hi or (my and constante4)) and opp;
  
  opp       := (opp_bits_high shl 18) or (opp_bits_low shr 14);
  my        := (my_bits_high  shl 27) or (my_bits_low  shr 5);
  result_hi := (result_hi or (my and constante3)) and opp;
  
  opp       := ((opp_bits_high shl 9)  or (opp_bits_low shr 23)) ;
  my        := ((my_bits_high  shl 18) or (my_bits_low  shr 14)) ;
  coup_legaux_hi := coup_legaux_hi or ((result_hi or (my and constante2)) and opp); 
  
   
  opp       := (opp_bits_low  shl 18);
  my        := (my_bits_low   shl 27);
  result_lo := ((my and constante3)) and opp;
  
  opp       := (opp_bits_low  shl 9) ;
  my        := (my_bits_low   shl 18) ;
  coup_legaux_lo := coup_legaux_lo or ((result_lo or (my and constante2)) and opp);
  
  {retournements diagonaux de A8 vers H1 vers le haut}
    
  result_lo := ((my_bits_high shr 17) and constante7) and (opp_bits_high shr 10);

  opp       := (opp_bits_high shr 3);
  my        := (my_bits_high shr 10);
  result_lo := (result_lo or (my and constante6)) and opp;
  
  opp       := (opp_bits_low shr 28) or (opp_bits_high shl 4);
  my        := (my_bits_high shr 3);
  result_lo := (result_lo or (my and constante5)) and opp;
  
  opp       := (opp_bits_low shr 21) or (opp_bits_high shl 11);
  my        := (my_bits_low  shr 28) or (my_bits_high shl 4);
  result_lo := (result_lo or (my and constante4)) and opp;
  
  opp       := (opp_bits_low shr 14) or (opp_bits_high shl 18);
  my        := (my_bits_low  shr 21) or (my_bits_high  shl 11);
  result_lo := (result_lo or (my and constante3)) and opp;
  
  opp       := (opp_bits_low shr 7)  or (opp_bits_high shl 25);
  my        := (my_bits_low  shr 14) or (my_bits_high  shl 18);
  coup_legaux_lo := coup_legaux_lo or ((result_lo or (my and constante2)) and opp);
  
  opp       := (opp_bits_high  shr 21);
  my        := (my_bits_high   shr 28);
  result_hi := (my and constante4) and opp;
  
  opp       := (opp_bits_high  shr 14);
  my        := (my_bits_high   shr 21);
  result_hi := (result_hi or (my and constante3)) and opp;
  
  opp       := (opp_bits_high  shr 7);
  my        := (my_bits_high   shr 14);
  coup_legaux_hi := coup_legaux_hi or ((result_hi or (my and constante2)) and opp);
    
  {retournements verticaux de haut en bas}
    
 
  result_hi := (my_bits_low shl 24) and (opp_bits_low shl 16);

  opp       := (opp_bits_low shl 8);
  my        := (my_bits_low shl 16);
  result_hi := (result_hi or my) and opp;

  opp       := (opp_bits_low);
  my        := (my_bits_low shl 8);
  result_hi := (result_hi or my) and opp;
  
  opp       := (opp_bits_high shl 24) or (opp_bits_low shr 8);
  my        := my_bits_low;
  result_hi := (result_hi or my) and opp;
  
  opp       := (opp_bits_high shl 16) or (opp_bits_low shr 16);
  my        := (my_bits_high  shl 24) or (my_bits_low  shr 8);
  result_hi := (result_hi or my) and opp;
  
  opp       := (opp_bits_high shl 8)  or (opp_bits_low shr 24);
  my        := (my_bits_high  shl 16) or (my_bits_low  shr 16);
  coup_legaux_hi := coup_legaux_hi or ((result_hi or my) and opp);
  
  opp       := (opp_bits_low  shl 16);
  my        := (my_bits_low   shl 24);
  result_lo := my and opp;
  
  opp       := (opp_bits_low  shl 8);
  my        := (my_bits_low   shl 16);
  coup_legaux_lo := coup_legaux_lo or ((result_lo or my) and opp);
  
  
  {retournements verticaux de bas en haut}
  
  result_lo := (my_bits_high shr 24) and (opp_bits_high shr 16);
  
  opp       := (opp_bits_high shr 8);
  my        := (my_bits_high shr 16);
  result_lo := (result_lo or my) and opp;
  
  opp       := (opp_bits_high);
  my        := (my_bits_high shr 8);
  result_lo := (result_lo or my) and opp;
  
  opp       := (opp_bits_low shr 24) or (opp_bits_high shl 8);
  my        := (my_bits_high);
  result_lo := (result_lo or my) and opp;
  
  opp       := (opp_bits_low shr 16) or (opp_bits_high shl 16);
  my        := (my_bits_low  shr 24) or (my_bits_high  shl 8);
  result_lo := (result_lo or my) and opp;
  
  opp       := (opp_bits_low shr 8)  or (opp_bits_high shl 24);
  my        := (my_bits_low  shr 16) or (my_bits_high  shl 16);
  coup_legaux_lo := coup_legaux_lo or ((result_lo or my) and opp);
  
  
  opp       := (opp_bits_high  shr 16);
  my        := (my_bits_high   shr 24);
  result_hi := my and opp;
  
  opp       := (opp_bits_high  shr 8);
  my        := (my_bits_high  shr 16);
  coup_legaux_hi := coup_legaux_hi or ((result_hi or my) and opp);
  
  
  
  {finalement, une case doit etre vide pour etre un coup legal}
  
  coup_legaux_lo := coup_legaux_lo and not(my_bits_low or opp_bits_low);
  coup_legaux_hi := coup_legaux_hi and not(my_bits_high or opp_bits_high);
  
  (*
  if debugMobilite then
  EcritBitboardDansRapport('coups legaux = ',MakeBitboard(coup_legaux_lo,coup_legaux_hi,0,0));
  *)
  
  constante2 := $55555555;
  constante3 := $33333333;
  constante4 := $0F0F0F0F;
  constante5 := $000000FF;
  (*
  constante2 := $55555555;
  constante3 := $33333333;
  constante4 := $0F0F0F0F;
  constante5 := $00FF00FF;
  constante6 := $0000FFFF;
  *)
  
  {calcul du nombre de bits a 1 dans coup_legaux_lo et coup_legaux_hi}
  
  if coup_legaux_lo<>0 then
    begin
      result_lo := ((coup_legaux_lo shr 1) and constante2) + (coup_legaux_lo and constante2);
      result_lo := ((result_lo shr 2) and constante3)  + (result_lo and constante3);
      result_lo := (result_lo + (result_lo shr 4)) and constante4;
      result_lo := result_lo + (result_lo shr 8);
      result_lo := (result_lo + (result_lo shr 16)) and constante5;
      
      (*
      result_lo := ((coup_legaux_lo shr 1) and constante2) + (coup_legaux_lo and constante2);
      result_lo := ((result_lo shr 2) and constante3)  + (result_lo and constante3);
      result_lo := ((result_lo shr 4) and constante4)  + (result_lo and constante4);
      result_lo := ((result_lo shr 8) and constante5)  + (result_lo and constante5);
      result_lo := ((result_lo shr 16) and constante6) + (result_lo and constante6);
      *)
      
      {Attention ! cette routine ne calcule pas la vraie mobilite :
       ici on on ajoute un pour chaque coin (donc les coins comptent 
       pour deux coups. Commenter les lignes suivantes pour avoir la 
       vraie mobilite}
      
      result_lo := result_lo +  (coup_legaux_lo and $00000001);
      result_lo := result_lo + ((coup_legaux_lo shr 7) and $00000001);
            
	  end
	  else result_lo := 0;
	  
  if (coup_legaux_hi<>0) then
    begin
      result_hi := ((coup_legaux_hi shr 1) and constante2) + (coup_legaux_hi and constante2);
      result_hi := ((result_hi shr 2) and constante3)  + (result_hi and constante3);
      result_hi := (result_hi + (result_hi shr 4)) and constante4;
      result_hi := result_hi + (result_hi shr 8);
      result_hi := (result_hi + (result_hi shr 16)) and constante5;
      
      (*
      result_hi := ((coup_legaux_hi shr 1) and constante2) + (coup_legaux_hi and constante2);
      result_hi := ((result_hi shr 2) and constante3)  + (result_hi and constante3);
      result_hi := ((result_hi shr 4) and constante4)  + (result_hi and constante4);
      result_hi := ((result_hi shr 8) and constante5)  + (result_hi and constante5);
      result_hi := ((result_hi shr 16) and constante6) + (result_hi and constante6);
      *)
      
      {Attention ! cette routine ne calcule pas la vraie mobilite :
       ici on on ajoute un pour chaque coin (donc les coins comptent 
       pour deux coups. Commenter les lignes suivantes pour avoir la 
       vraie mobilite}
      
      result_hi := result_hi + ((coup_legaux_hi shr 31) and $00000001);
      result_hi := result_hi + ((coup_legaux_hi shr 24) and $00000001);
      
    end
    else result_hi := 0;
	
	CalculeMobiliteBitboard := result_lo + result_hi;

end;


{  $ p r a g m a c  optimization_level reset}


function PositionEtTraitToBitboard(var whichPosition : PositionEtTraitRec):bitboard;
var couleur,adversaire : SInt32;
    i,j,square,myBitsLow,myBitsHigh,oppBitsLow,oppBitsHigh : UInt32;
    theBitBoard  : bitboard;
begin

  myBitsLow := 0;
	myBitsHigh := 0;
	oppBitsLow := 0;
	oppBitsHigh := 0;

  {transforme un plateauOthello en bitboard}
	with whichPosition do
	  begin
	    if GetTraitOfPosition(whichPosition) = pionVide
	      then couleur := pionNoir
	      else couleur := GetTraitOfPosition(whichPosition);
	    
	    adversaire := -couleur;
			for j := 1 to 4 do
			  for i := 1 to 8 do
			    begin
			      square := j*10 + i;
			      if position[square] = couleur then myBitsLow := BOR(myBitsLow,othellierBitboardDescr[square].constanteHexa)  else
			      if position[square] = adversaire then oppBitsLow := BOR(oppBitsLow,othellierBitboardDescr[square].constanteHexa)
			    end;
			for j := 5 to 8 do
			  for i := 1 to 8 do
			    begin
			      square := j*10 + i;
			      if position[square] = couleur then myBitsHigh := BOR(myBitsHigh,othellierBitboardDescr[square].constanteHexa)  else
			      if position[square] = adversaire then oppBitsHigh := BOR(oppBitsHigh,othellierBitboardDescr[square].constanteHexa)
			    end;
	 end;
		
	with theBitBoard do
	  begin
	    g_my_bits_low := myBitsLow;
	    g_my_bits_high := myBitsHigh;
	    g_opp_bits_low := oppBitsLow;
	    g_opp_bits_high := oppBitsHigh;
	  end;
	
	PositionEtTraitToBitboard := theBitboard;
end;


procedure TestMobiliteBitbooard(var whichPosition : PositionEtTraitRec);
var couleur,adversaire : SInt32;
    i,j,square,myBitsLow,myBitsHigh,oppBitsLow,oppBitsHigh : UInt32;
    theBitBoard  : bitboard;
    n,compteur,tick : SInt32;
begin  
  
  
  if GetTraitOfPosition(whichPosition) <> pionVide then
    begin
  
		  {transforme un plateauOthello en bitboard}
			myBitsLow := 0;
			myBitsHigh := 0;
			oppBitsLow := 0;
			oppBitsHigh := 0;
			
			with whichPosition do
			  begin
			    if GetTraitOfPosition(whichPosition) = pionVide
			      then couleur := pionNoir
			      else couleur := GetTraitOfPosition(whichPosition);
			    
			    adversaire := -couleur;
					for j := 1 to 4 do
					  for i := 1 to 8 do
					    begin
					      square := j*10 + i;
					      if position[square] = couleur then myBitsLow := BOR(myBitsLow,othellierBitboardDescr[square].constanteHexa)  else
					      if position[square] = adversaire then oppBitsLow := BOR(oppBitsLow,othellierBitboardDescr[square].constanteHexa)
					    end;
					for j := 5 to 8 do
					  for i := 1 to 8 do
					    begin
					      square := j*10 + i;
					      if position[square] = couleur then myBitsHigh := BOR(myBitsHigh,othellierBitboardDescr[square].constanteHexa)  else
					      if position[square] = adversaire then oppBitsHigh := BOR(oppBitsHigh,othellierBitboardDescr[square].constanteHexa)
					    end;
			 end;
			
			with theBitBoard do
			  begin
			    g_my_bits_low := myBitsLow;
			    g_my_bits_high := myBitsHigh;
			    g_opp_bits_low := oppBitsLow;
			    g_opp_bits_high := oppBitsHigh;
			  end;
			  
			
			  
			WritelnStringDansRapport('entrŽe dans TestMobiliteBitbooard');
			
			tick := TickCount();
			for compteur := 1 to 1 do
			  n := CalculeMobiliteBitboard(myBitsLow,myBitsHigh,oppBitsLow,oppBitsHigh);
			tick := TickCount() - tick;
			  
			  
			WritelnStringAndNumDansRapport('   ==> mobilite bitboard = ',n);
			WritelnStringAndNumDansRapport('             temps = ',tick);
			
			tick := TickCount();
			for compteur := 1 to 1 do
			  n := CalculeMobilitePlatSeulement(whichPosition.position,GetTraitOfPosition(whichPosition));
			tick := TickCount() - tick;
			
			WritelnStringAndNumDansRapport('   ==> mobilite normale = ',n);
			WritelnStringAndNumDansRapport('             temps = ',tick);
			
	  end;
	  
end;

{$ENDC}


END.
