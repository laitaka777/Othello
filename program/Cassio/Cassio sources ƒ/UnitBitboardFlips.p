UNIT UnitBitboardFlips;


INTERFACE







USES UnitBitboardTypes;



{$IFC USING_BITBOARD}

function TrierFastestFirstBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;nbCasesVides : SInt32; var listeCoupsLegaux:listeVides;coupAMettreEnTete : SInt32) : SInt32;
function TrierFastestFirstBitboardMobilite(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;nbCasesVides : SInt32; var listeCoupsLegaux:listeVides;coupAMettreEnTete : SInt32) : SInt32;


function TrierFastestFirstPariteBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;nbCasesVides,vecteurParite : SInt32; var listeCoupsLegaux:listeVides;coupAMettreEnTete : SInt32) : SInt32;


                                             
procedure EcritTriFastestFirstBitboardDansRapport(var position:bitboard);

{$ENDC}



IMPLEMENTATION







{$IFC USING_BITBOARD}


USES UnitRapport,UnitMacExtras,UnitBitboardModifPlat,UnitBitboardPeutJouerIci,UnitBitboardStabilite,UnitBitboardHash,UnitVariablesGlobalesFinale;


{ tri des coups legaux par fastest-first; 
  on renvoie le nombre de coups legaux pour la couleur qui a le trait}
function TrierFastestFirstBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;nbCasesVides : SInt32; var listeCoupsLegaux:listeVides;coupAMettreEnTete : SInt32) : SInt32;
var i,k : SInt32;
    celluleDepart:celluleCaseVideDansListeChaineePtr;
    celluleDansListeChaineeCasesVides1:celluleCaseVideDansListeChaineePtr;
    celluleNext1:celluleCaseVideDansListeChaineePtr;
    celluleDansListeChaineeCasesVides2:celluleCaseVideDansListeChaineePtr;
    celluleNext2:celluleCaseVideDansListeChaineePtr;
    position:bitboard;
    nbCoups,mobAdverse,coupTest,coupdiv : SInt32;
    diffBidon,mobiliteMin,mobiliteMax : SInt32;
    my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32;
    coupLegal : boolean;
    
label LeCoupEstLegal,LeCoupEstIllegal,SuiteBoucleMobilite;
begin
   
   {$IFC DEBUG_BITBOARD_ALPHA_BETA}
   WritelnDansRapport('');
   WritelnDansRapport('Entrée dans TrierFastestFirstBitboard :');
   {$ENDC}

	 diffBidon := 0;
	 
	 
	 for i := 0 to nbCasesVides + 5 do
	   denombrementPourCetteMobilite[i] := 0;

	 
	 mobiliteMax := -1000;
	 mobiliteMin :=  1000;
	 

   celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
   celluleDansListeChaineeCasesVides1 := celluleDepart^.next;
   repeat 
		 with celluleDansListeChaineeCasesVides1^ do
		   begin {1}
		     celluleNext1 := next;
		     coupTest := square;
		     
		     coupLegal := ModifPlatPlausible(coupTest,pos_opp_bits_low,pos_opp_bits_high) &
		                  (ModifPlatBitboard(coupTest,0,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffBidon) <> 0);
		                  
		     if coupLegal
		       then
		         begin {2}
		             
		           { Si coupTest est le coup a mettre en tete, on force artificiellement 
		            la mobilite adverse a zero pour ce coup : cela tendra a le mettre en tete
		            dans le tri fastest first. Sinon, on calcule normalement la mobilite de 
		            l'adversaire }
		            
		           if (coupTest = coupAMettreEnTete) 
		             then 
		               begin {3}
		                 mobAdverse := 0;
		               end {3}
		             else
  		             begin {3}
  		               
  		               
  		               mobAdverse := 1;
  		               
  		               
      		           celluleDansListeChaineeCasesVides2 := celluleDepart^.next;
      		           repeat
      		             celluleNext2 := celluleDansListeChaineeCasesVides2^.next;
      		             if celluleDansListeChaineeCasesVides2<>celluleDansListeChaineeCasesVides1 then
      		               begin {4}
      		                 coupDiv := celluleDansListeChaineeCasesVides2^.square;
      		                 
      		                 {if PeutJouerIciBitboard(coupDiv,position) then inc(mobAdverse);  inline!}
      		                 
      		                  with position do
      										    begin {5}
      										  
      										      my_bits_low := g_my_bits_low   ;
      										      my_bits_high := g_my_bits_high  ;
      										      opp_bits_low := g_opp_bits_low  ;
      										      opp_bits_high := g_opp_bits_high ;
      										  
      										  
      										  
      										      if not(ModifPlatPlausible(coupDiv,opp_bits_low,opp_bits_high))
      										        then goto LeCoupEstIllegal
      										        else
          												  case coupDiv of
          										        11 :    { A1 }
          										          begin
          										            if BAND(opp_bits_low+$00000002,BAND(my_bits_low,$000000FC))<>0 then begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        12 :    { B1 }
          										          begin
          										            if BAND(opp_bits_low+$00000004,BAND(my_bits_low,$000000F8))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        13 :    { C1 }
          										          begin
          										            if BAND(opp_bits_low+$00000008,BAND(my_bits_low,$000000F0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000002))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        14 :    { D1 }
          										          begin
          										            if BAND(opp_bits_low+$00000010,BAND(my_bits_low,$000000E0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000004))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        15 :    { E1 }
          										          begin
          										            if BAND(opp_bits_low+$00000020,BAND(my_bits_low,$000000C0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000008))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        16 :    { F1 }
          										          begin
          										            if BAND(opp_bits_low+$00000040,BAND(my_bits_low,$00000080))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000010))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        17 :    { G1 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000020))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        18 :    { H1 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000040))<>0 then begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end;
          										            if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        21 :    { A2 }
          										          begin
          										            if BAND(opp_bits_low+$00000200,BAND(my_bits_low,$0000FC00))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        22 :    { B2 }
          										          begin
          										            if BAND(opp_bits_low+$00000400,BAND(my_bits_low,$0000F800))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        23 :    { C2 }
          										          begin
          										            if BAND(opp_bits_low+$00000800,BAND(my_bits_low,$0000F000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000200))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        24 :    { D2 }
          										          begin
          										            if BAND(opp_bits_low+$00001000,BAND(my_bits_low,$0000E000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000400))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        25 :    { E2 }
          										          begin
          										            if BAND(opp_bits_low+$00002000,BAND(my_bits_low,$0000C000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000800))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        26 :    { F2 }
          										          begin
          										            if BAND(opp_bits_low+$00004000,BAND(my_bits_low,$00008000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00001000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        27 :    { G2 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00002000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        28 :    { H2 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00004000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        31 :    { A3 }
          										          begin
          										            if BAND(opp_bits_low+$00020000,BAND(my_bits_low,$00FC0000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        32 :    { B3 }
          										          begin
          										            if BAND(opp_bits_low+$00040000,BAND(my_bits_low,$00F80000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        33 :    { C3 }
          										          begin
          										            if BAND(opp_bits_low+$00080000,BAND(my_bits_low,$00F00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00020000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        34 :    { D3 }
          										          begin
          										            if BAND(opp_bits_low+$00100000,BAND(my_bits_low,$00E00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00040000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        35 :    { E3 }
          										          begin
          										            if BAND(opp_bits_low+$00200000,BAND(my_bits_low,$00C00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00080000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        36 :    { F3 }
          										          begin
          										            if BAND(opp_bits_low+$00400000,BAND(my_bits_low,$00800000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00100000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        37 :    { G3 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00200000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        38 :    { H3 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00400000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        41 :    { A4 }
          										          begin
          										            if BAND(opp_bits_low+$02000000,BAND(my_bits_low,$FC000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        42 :    { B4 }
          										          begin
          										            if BAND(opp_bits_low+$04000000,BAND(my_bits_low,$F8000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        43 :    { C4 }
          										          begin
          										            if BAND(opp_bits_low+$08000000,BAND(my_bits_low,$F0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$02000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        44 :    { D4 }
          										          begin
          										            if BAND(opp_bits_low+$10000000,BAND(my_bits_low,$E0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$04000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        45 :    { E4 }
          										          begin
          										            if BAND(opp_bits_low+$20000000,BAND(my_bits_low,$C0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$08000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        46 :    { F4 }
          										          begin
          										            if BAND(opp_bits_low+$40000000,BAND(my_bits_low,$80000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$10000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        47 :    { G4 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$20000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        48 :    { H4 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$40000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        51 :    { A5 }
          										          begin
          										            if BAND(opp_bits_high+$00000002,BAND(my_bits_high,$000000FC))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        52 :    { B5 }
          										          begin
          										            if BAND(opp_bits_high+$00000004,BAND(my_bits_high,$000000F8))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        53 :    { C5 }
          										          begin
          										            if BAND(opp_bits_high+$00000008,BAND(my_bits_high,$000000F0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000002))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        54 :    { D5 }
          										          begin
          										            if BAND(opp_bits_high+$00000010,BAND(my_bits_high,$000000E0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000004))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        55 :    { E5 }
          										          begin
          										            if BAND(opp_bits_high+$00000020,BAND(my_bits_high,$000000C0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000008))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        56 :    { F5 }
          										          begin
          										            if BAND(opp_bits_high+$00000040,BAND(my_bits_high,$00000080))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000010))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        57 :    { G5 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000020))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        58 :    { H5 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000040))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        61 :    { A6 }
          										          begin
          										            if BAND(opp_bits_high+$00000200,BAND(my_bits_high,$0000FC00))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        62 :    { B6 }
          										          begin
          										            if BAND(opp_bits_high+$00000400,BAND(my_bits_high,$0000F800))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        63 :    { C6 }
          										          begin
          										            if BAND(opp_bits_high+$00000800,BAND(my_bits_high,$0000F000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000200))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        64 :    { D6 }
          										          begin
          										            if BAND(opp_bits_high+$00001000,BAND(my_bits_high,$0000E000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000400))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        65 :    { E6 }
          										          begin
          										            if BAND(opp_bits_high+$00002000,BAND(my_bits_high,$0000C000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000800))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        66 :    { F6 }
          										          begin
          										            if BAND(opp_bits_high+$00004000,BAND(my_bits_high,$00008000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00001000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        67 :    { G6 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00002000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        68 :    { H6 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00004000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        71 :    { A7 }
          										          begin
          										            if BAND(opp_bits_high+$00020000,BAND(my_bits_high,$00FC0000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        72 :    { B7 }
          										          begin
          										            if BAND(opp_bits_high+$00040000,BAND(my_bits_high,$00F80000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        73 :    { C7 }
          										          begin
          										            if BAND(opp_bits_high+$00080000,BAND(my_bits_high,$00F00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00020000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        74 :    { D7 }
          										          begin
          										            if BAND(opp_bits_high+$00100000,BAND(my_bits_high,$00E00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00040000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        75 :    { E7 }
          										          begin
          										            if BAND(opp_bits_high+$00200000,BAND(my_bits_high,$00C00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00080000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        76 :    { F7 }
          										          begin
          										            if BAND(opp_bits_high+$00400000,BAND(my_bits_high,$00800000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00100000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        77 :    { G7 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00200000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        78 :    { H7 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00400000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        81 :    { A8 }
          										          begin
          										            if BAND(opp_bits_high+$02000000,BAND(my_bits_high,$FC000000))<>0 then begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end;
          										            if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        82 :    { B8 }
          										          begin
          										            if BAND(opp_bits_high+$04000000,BAND(my_bits_high,$F8000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        83 :    { C8 }
          										          begin
          										            if BAND(opp_bits_high+$08000000,BAND(my_bits_high,$F0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$02000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        84 :    { D8 }
          										          begin
          										            if BAND(opp_bits_high+$10000000,BAND(my_bits_high,$E0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$04000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        85 :    { E8 }
          										          begin
          										            if BAND(opp_bits_high+$20000000,BAND(my_bits_high,$C0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$08000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        86 :    { F8 }
          										          begin
          										            if BAND(opp_bits_high+$40000000,BAND(my_bits_high,$80000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$10000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        87 :    { G8 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$20000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        88 :    { H8 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$40000000))<>0 then begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										     end; {case}
      										  end; {with position do}  {5}
      										 LeCoupEstLegal : inc(mobAdverse);
      		                 LeCoupEstIllegal : ;
      		                 SuiteBoucleMobilite : ;
      		               end; {4}
      				         celluleDansListeChaineeCasesVides2 := celluleNext2;
      		           until celluleDansListeChaineeCasesVides2 = celluleDepart;
      		         end; {3}
		               
		           if mobAdverse > mobiliteMax then mobiliteMax := mobAdverse;
		           if mobAdverse < mobiliteMin then mobiliteMin := mobAdverse;
		              
		           k := denombrementPourCetteMobilite[mobAdverse];
		           k := k+1;
		           denombrementPourCetteMobilite[mobAdverse] := k;
		           triParDenombrementMobilite[mobAdverse][k] := coupTest;

		         end; {if coupLegal then } {2}
		         
		     celluleDansListeChaineeCasesVides1 := celluleNext1;
		     
		   end; {with celluleDansListeChaineeCasesVides1^ do} {1}
		   
	 until celluleDansListeChaineeCasesVides1 = celluleDepart;
	   
	 {$IFC (DEBUG_BITBOARD_ALPHA_BETA) }
	 WritelnStringAndNumDansRapport('mobiliteMin=',mobiliteMin);
	 WritelnStringAndNumDansRapport('mobiliteMax=',mobiliteMax);
	 {$ENDC}
	 
	 nbCoups := 0;
	 for i := mobiliteMin to mobiliteMax do
	   for k := 1 to denombrementPourCetteMobilite[i] do
	     begin
	       inc(nbCoups);
	       listeCoupsLegaux[nbCoups] := triParDenombrementMobilite[i][k];
	       {$IFC (DEBUG_BITBOARD_ALPHA_BETA) }
	       WriteStringAndNumDansRapport('mob='+NumEnString(i)+' pour la case ',listeCoupsLegaux[nbCoups]);
	       WritelnStringAndCoupDansRapport(' ie la case ',listeCoupsLegaux[nbCoups]);
	       {$ENDC}
	     end;
	     
	 {$IFC (DEBUG_BITBOARD_ALPHA_BETA) }
	 WritelnStringAndNumDansRapport('donc  nbCoupsLegaux=',nbCoups);
	 WritelnDansRapport('sortie de TrierFastestFirstBitboard.');
   WritelnDansRapport('');
	 {$ENDC}
	 TrierFastestFirstBitboard := nbCoups;
end;




{ tri des coups legaux par fastest-first et la parite; 
  on renvoie le nombre de coups legaux pour la couleur qui a le trait}
function TrierFastestFirstPariteBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;nbCasesVides,vecteurParite : SInt32; var listeCoupsLegaux:listeVides;coupAMettreEnTete : SInt32) : SInt32;
var i,k : SInt32;
    celluleDepart:celluleCaseVideDansListeChaineePtr;
    celluleDansListeChaineeCasesVides1:celluleCaseVideDansListeChaineePtr;
    celluleNext1:celluleCaseVideDansListeChaineePtr;
    celluleDansListeChaineeCasesVides2:celluleCaseVideDansListeChaineePtr;
    celluleNext2:celluleCaseVideDansListeChaineePtr;
    position:bitboard;
    nbCoups,mobAdverse,coupTest,coupdiv : SInt32;
    diffBidon,mobiliteMin,mobiliteMax : SInt32;
    my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32;
    coupLegal : boolean;
    
label LeCoupEstLegal,LeCoupEstIllegal,SuiteBoucleMobilite;
begin
   
   {$IFC DEBUG_BITBOARD_ALPHA_BETA}
   WritelnDansRapport('');
   WritelnDansRapport('Entrée dans TrierFastestFirstPariteBitboard :');
   {$ENDC}

	 diffBidon := 0;
	 
	 
	 for i := 0 to 2*(nbCasesVides + 4) + 2 do
	   denombrementPourCetteMobilite[i] := 0;

	 
	 mobiliteMax := -1000;
	 mobiliteMin :=  1000;
	 

   celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
   celluleDansListeChaineeCasesVides1 := celluleDepart^.next;
   repeat 
		 with celluleDansListeChaineeCasesVides1^ do
		   begin {1}
		     celluleNext1 := next;
		     coupTest := square;
		     
		     coupLegal := ModifPlatPlausible(coupTest,pos_opp_bits_low,pos_opp_bits_high) &
		                  (ModifPlatBitboard(coupTest,0,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffBidon) <> 0);
		                  
		     if coupLegal
		       then
		         begin {2}
		             
		           { Si coupTest est le coup a mettre en tete, on force artificiellement 
		            la mobilite adverse a zero pour ce coup : cela tendra a le mettre en tete
		            dans le tri fastest first. Sinon, on calcule normalement la mobilite de 
		            l'adversaire }
		            
		           if (coupTest = coupAMettreEnTete) 
		             then 
		               begin {3}
		                 mobAdverse := 0; 
		               end {3}
		             else
  		             begin {3}
  		               
  		               
  		               mobAdverse := 0;
  		               
  		               
      		           celluleDansListeChaineeCasesVides2 := celluleDepart^.next;
      		           repeat
      		             celluleNext2 := celluleDansListeChaineeCasesVides2^.next;
      		             if celluleDansListeChaineeCasesVides2<>celluleDansListeChaineeCasesVides1 then
      		               begin {4}
      		                 coupDiv := celluleDansListeChaineeCasesVides2^.square;
      		                 
      		                 {if PeutJouerIciBitboard(coupDiv,position) then inc(mobAdverse);  inline!}
      		                 
      		                  with position do
      										    begin {5}
      										  
      										      my_bits_low := g_my_bits_low   ;
      										      my_bits_high := g_my_bits_high  ;
      										      opp_bits_low := g_opp_bits_low  ;
      										      opp_bits_high := g_opp_bits_high ;
      										  
      										  
      										  
      										      if not(ModifPlatPlausible(coupDiv,opp_bits_low,opp_bits_high))
      										        then goto LeCoupEstIllegal
      										        else
          												  case coupDiv of
          										        11 :    { A1 }
          										          begin
          										            if BAND(opp_bits_low+$00000002,BAND(my_bits_low,$000000FC))<>0 then begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        12 :    { B1 }
          										          begin
          										            if BAND(opp_bits_low+$00000004,BAND(my_bits_low,$000000F8))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        13 :    { C1 }
          										          begin
          										            if BAND(opp_bits_low+$00000008,BAND(my_bits_low,$000000F0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000002))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        14 :    { D1 }
          										          begin
          										            if BAND(opp_bits_low+$00000010,BAND(my_bits_low,$000000E0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000004))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        15 :    { E1 }
          										          begin
          										            if BAND(opp_bits_low+$00000020,BAND(my_bits_low,$000000C0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000008))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        16 :    { F1 }
          										          begin
          										            if BAND(opp_bits_low+$00000040,BAND(my_bits_low,$00000080))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000010))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        17 :    { G1 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000020))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        18 :    { H1 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000040))<>0 then begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end;
          										            if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        21 :    { A2 }
          										          begin
          										            if BAND(opp_bits_low+$00000200,BAND(my_bits_low,$0000FC00))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        22 :    { B2 }
          										          begin
          										            if BAND(opp_bits_low+$00000400,BAND(my_bits_low,$0000F800))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        23 :    { C2 }
          										          begin
          										            if BAND(opp_bits_low+$00000800,BAND(my_bits_low,$0000F000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000200))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        24 :    { D2 }
          										          begin
          										            if BAND(opp_bits_low+$00001000,BAND(my_bits_low,$0000E000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000400))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        25 :    { E2 }
          										          begin
          										            if BAND(opp_bits_low+$00002000,BAND(my_bits_low,$0000C000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00000800))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        26 :    { F2 }
          										          begin
          										            if BAND(opp_bits_low+$00004000,BAND(my_bits_low,$00008000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00001000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        27 :    { G2 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00002000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        28 :    { H2 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00004000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        31 :    { A3 }
          										          begin
          										            if BAND(opp_bits_low+$00020000,BAND(my_bits_low,$00FC0000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        32 :    { B3 }
          										          begin
          										            if BAND(opp_bits_low+$00040000,BAND(my_bits_low,$00F80000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        33 :    { C3 }
          										          begin
          										            if BAND(opp_bits_low+$00080000,BAND(my_bits_low,$00F00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00020000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        34 :    { D3 }
          										          begin
          										            if BAND(opp_bits_low+$00100000,BAND(my_bits_low,$00E00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00040000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        35 :    { E3 }
          										          begin
          										            if BAND(opp_bits_low+$00200000,BAND(my_bits_low,$00C00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00080000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        36 :    { F3 }
          										          begin
          										            if BAND(opp_bits_low+$00400000,BAND(my_bits_low,$00800000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00100000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        37 :    { G3 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00200000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        38 :    { H3 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$00400000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        41 :    { A4 }
          										          begin
          										            if BAND(opp_bits_low+$02000000,BAND(my_bits_low,$FC000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        42 :    { B4 }
          										          begin
          										            if BAND(opp_bits_low+$04000000,BAND(my_bits_low,$F8000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        43 :    { C4 }
          										          begin
          										            if BAND(opp_bits_low+$08000000,BAND(my_bits_low,$F0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$02000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        44 :    { D4 }
          										          begin
          										            if BAND(opp_bits_low+$10000000,BAND(my_bits_low,$E0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$04000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        45 :    { E4 }
          										          begin
          										            if BAND(opp_bits_low+$20000000,BAND(my_bits_low,$C0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$08000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        46 :    { F4 }
          										          begin
          										            if BAND(opp_bits_low+$40000000,BAND(my_bits_low,$80000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$10000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        47 :    { G4 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$20000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        48 :    { H4 }
          										          begin
          										            if BAND(BSR(opp_bits_low,1)+my_bits_low,BAND(opp_bits_low,$40000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        51 :    { A5 }
          										          begin
          										            if BAND(opp_bits_high+$00000002,BAND(my_bits_high,$000000FC))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        52 :    { B5 }
          										          begin
          										            if BAND(opp_bits_high+$00000004,BAND(my_bits_high,$000000F8))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        53 :    { C5 }
          										          begin
          										            if BAND(opp_bits_high+$00000008,BAND(my_bits_high,$000000F0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000002))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00010000)<>0 then { if plat[A7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        54 :    { D5 }
          										          begin
          										            if BAND(opp_bits_high+$00000010,BAND(my_bits_high,$000000E0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000004))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00020000)<>0 then { if plat[B7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        55 :    { E5 }
          										          begin
          										            if BAND(opp_bits_high+$00000020,BAND(my_bits_high,$000000C0))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000008))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00040000)<>0 then { if plat[C7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        56 :    { F5 }
          										          begin
          										            if BAND(opp_bits_high+$00000040,BAND(my_bits_high,$00000080))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000010))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00080000)<>0 then { if plat[D7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        57 :    { G5 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000020))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00400000)<>0 then { if plat[G7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00100000)<>0 then { if plat[E7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        58 :    { H5 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000040))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00800000)<>0 then { if plat[H7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00200000)<>0 then { if plat[F7]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        61 :    { A6 }
          										          begin
          										            if BAND(opp_bits_high+$00000200,BAND(my_bits_high,$0000FC00))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        62 :    { B6 }
          										          begin
          										            if BAND(opp_bits_high+$00000400,BAND(my_bits_high,$0000F800))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        63 :    { C6 }
          										          begin
          										            if BAND(opp_bits_high+$00000800,BAND(my_bits_high,$0000F000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000200))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$01000000)<>0 then { if plat[A8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        64 :    { D6 }
          										          begin
          										            if BAND(opp_bits_high+$00001000,BAND(my_bits_high,$0000E000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000400))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$02000000)<>0 then { if plat[B8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        65 :    { E6 }
          										          begin
          										            if BAND(opp_bits_high+$00002000,BAND(my_bits_high,$0000C000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00000800))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$04000000)<>0 then { if plat[C8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        66 :    { F6 }
          										          begin
          										            if BAND(opp_bits_high+$00004000,BAND(my_bits_high,$00008000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00001000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$08000000)<>0 then { if plat[D8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        67 :    { G6 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00002000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$40000000)<>0 then { if plat[G8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$10000000)<>0 then { if plat[E8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        68 :    { H6 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00004000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$80000000)<>0 then { if plat[H8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$20000000)<>0 then { if plat[F8]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										              begin
          										                if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        71 :    { A7 }
          										          begin
          										            if BAND(opp_bits_high+$00020000,BAND(my_bits_high,$00FC0000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        72 :    { B7 }
          										          begin
          										            if BAND(opp_bits_high+$00040000,BAND(my_bits_high,$00F80000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        73 :    { C7 }
          										          begin
          										            if BAND(opp_bits_high+$00080000,BAND(my_bits_high,$00F00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00020000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        74 :    { D7 }
          										          begin
          										            if BAND(opp_bits_high+$00100000,BAND(my_bits_high,$00E00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00040000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        75 :    { E7 }
          										          begin
          										            if BAND(opp_bits_high+$00200000,BAND(my_bits_high,$00C00000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00080000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        76 :    { F7 }
          										          begin
          										            if BAND(opp_bits_high+$00400000,BAND(my_bits_high,$00800000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00100000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        77 :    { G7 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00200000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        78 :    { H7 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$00400000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        81 :    { A8 }
          										          begin
          										            if BAND(opp_bits_high+$02000000,BAND(my_bits_high,$FC000000))<>0 then begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end;
          										            if BAND(opp_bits_high,$00010000)<>0 then { if plat[A7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000100)<>0 then { if plat[A6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000001)<>0 then { if plat[A5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$01000000)<>0 then { if plat[A4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00010000)<>0 then { if plat[A3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000100)<>0 then { if plat[A2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        82 :    { B8 }
          										          begin
          										            if BAND(opp_bits_high+$04000000,BAND(my_bits_high,$F8000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000002)<>0 then { if plat[B1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        83 :    { C8 }
          										          begin
          										            if BAND(opp_bits_high+$08000000,BAND(my_bits_high,$F0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$02000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00020000)<>0 then { if plat[B7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00000100)<>0 then { if plat[A6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000400)<>0 then { if plat[C2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000004)<>0 then { if plat[C1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000400)<>0 then { if plat[C2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        84 :    { D8 }
          										          begin
          										            if BAND(opp_bits_high+$10000000,BAND(my_bits_high,$E0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$04000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00040000)<>0 then { if plat[C7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000200)<>0 then { if plat[B6]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000001)<>0 then { if plat[A5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000200)<>0 then { if plat[B6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00080000)<>0 then { if plat[D3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000800)<>0 then { if plat[D2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000008)<>0 then { if plat[D1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000800)<>0 then { if plat[D2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00080000)<>0 then { if plat[D3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        85 :    { E8 }
          										          begin
          										            if BAND(opp_bits_high+$20000000,BAND(my_bits_high,$C0000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$08000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00080000)<>0 then { if plat[D7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000400)<>0 then { if plat[C6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000002)<>0 then { if plat[B5]=adversaire then }
          										                      begin
          										                        if BAND(my_bits_low,$01000000)<>0 then { if plat[A4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000002)<>0 then { if plat[B5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000400)<>0 then { if plat[C6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$10000000)<>0 then { if plat[E4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00100000)<>0 then { if plat[E3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00001000)<>0 then { if plat[E2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000010)<>0 then { if plat[E1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00001000)<>0 then { if plat[E2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00100000)<>0 then { if plat[E3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$10000000)<>0 then { if plat[E4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                  begin
          										                    if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        86 :    { F8 }
          										          begin
          										            if BAND(opp_bits_high+$40000000,BAND(my_bits_high,$80000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$10000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00100000)<>0 then { if plat[E7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00000800)<>0 then { if plat[D6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000004)<>0 then { if plat[C5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$02000000)<>0 then { if plat[B4]=adversaire then }
          										                          begin
          										                            if BAND(my_bits_low,$00010000)<>0 then { if plat[A3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$02000000)<>0 then { if plat[B4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000004)<>0 then { if plat[C5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00000800)<>0 then { if plat[D6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000020)<>0 then { if plat[F5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$20000000)<>0 then { if plat[F4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00200000)<>0 then { if plat[F3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00002000)<>0 then { if plat[F2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000020)<>0 then { if plat[F1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00002000)<>0 then { if plat[F2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00200000)<>0 then { if plat[F3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$20000000)<>0 then { if plat[F4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000020)<>0 then { if plat[F5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        87 :    { G8 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$20000000))<>0 then goto LeCoupEstLegal;
          										            if BAND(opp_bits_high,$00200000)<>0 then { if plat[F7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00001000)<>0 then { if plat[E6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000008)<>0 then { if plat[D5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$04000000)<>0 then { if plat[C4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00020000)<>0 then { if plat[B3]=adversaire then }
          										                              begin
          										                                if BAND(my_bits_low,$00000100)<>0 then { if plat[A2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00020000)<>0 then { if plat[B3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$04000000)<>0 then { if plat[C4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000008)<>0 then { if plat[D5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00001000)<>0 then { if plat[E6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00004000)<>0 then { if plat[G6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000040)<>0 then { if plat[G5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$40000000)<>0 then { if plat[G4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00400000)<>0 then { if plat[G3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00004000)<>0 then { if plat[G2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000040)<>0 then { if plat[G1]=couleur then }
          										                                      goto LeCoupEstLegal
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00004000)<>0 then { if plat[G2]=couleur then }
          										                                  goto LeCoupEstLegal
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00400000)<>0 then { if plat[G3]=couleur then }
          										                              goto LeCoupEstLegal
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$40000000)<>0 then { if plat[G4]=couleur then }
          										                          goto LeCoupEstLegal
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000040)<>0 then { if plat[G5]=couleur then }
          										                      goto LeCoupEstLegal
          										                  end
          										                else
          										                if BAND(my_bits_high,$00004000)<>0 then { if plat[G6]=couleur then }
          										                  goto LeCoupEstLegal
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										        88 :    { H8 }
          										          begin
          										            if BAND(BSR(opp_bits_high,1)+my_bits_high,BAND(opp_bits_high,$40000000))<>0 then begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end;
          										            if BAND(opp_bits_high,$00400000)<>0 then { if plat[G7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00002000)<>0 then { if plat[F6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000010)<>0 then { if plat[E5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$08000000)<>0 then { if plat[D4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00040000)<>0 then { if plat[C3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00000200)<>0 then { if plat[B2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000001)<>0 then { if plat[A1]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00000200)<>0 then { if plat[B2]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00040000)<>0 then { if plat[C3]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$08000000)<>0 then { if plat[D4]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000010)<>0 then { if plat[E5]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_high,$00002000)<>0 then { if plat[F6]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            if BAND(opp_bits_high,$00800000)<>0 then { if plat[H7]=adversaire then }
          										              begin
          										                if BAND(opp_bits_high,$00008000)<>0 then { if plat[H6]=adversaire then }
          										                  begin
          										                    if BAND(opp_bits_high,$00000080)<>0 then { if plat[H5]=adversaire then }
          										                      begin
          										                        if BAND(opp_bits_low,$80000000)<>0 then { if plat[H4]=adversaire then }
          										                          begin
          										                            if BAND(opp_bits_low,$00800000)<>0 then { if plat[H3]=adversaire then }
          										                              begin
          										                                if BAND(opp_bits_low,$00008000)<>0 then { if plat[H2]=adversaire then }
          										                                  begin
          										                                    if BAND(my_bits_low,$00000080)<>0 then { if plat[H1]=couleur then }
          										                                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                                  end
          										                                else
          										                                if BAND(my_bits_low,$00008000)<>0 then { if plat[H2]=couleur then }
          										                                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                              end
          										                            else
          										                            if BAND(my_bits_low,$00800000)<>0 then { if plat[H3]=couleur then }
          										                              begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                          end
          										                        else
          										                        if BAND(my_bits_low,$80000000)<>0 then { if plat[H4]=couleur then }
          										                          begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                      end
          										                    else
          										                    if BAND(my_bits_high,$00000080)<>0 then { if plat[H5]=couleur then }
          										                      begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										                  end
          										                else
          										                if BAND(my_bits_high,$00008000)<>0 then { if plat[H6]=couleur then }
          										                  begin mobAdverse := mobAdverse+2; goto SuiteBoucleMobilite; end
          										              end;
          										            goto LeCoupEstIllegal;
          										          end;
          										     end; {case}
      										  end; {with position do}  {5}
      										 LeCoupEstLegal : inc(mobAdverse);
      		                 LeCoupEstIllegal : ;
      		                 SuiteBoucleMobilite : ;
      		               end; {4}
      				         celluleDansListeChaineeCasesVides2 := celluleNext2;
      		           until celluleDansListeChaineeCasesVides2 = celluleDepart;
      		           
      		           
      		           mobAdverse := 2*MobAdverse;
      		           
      		           if (BAND(vecteurParite,constantePariteDeSquare) = 0)  
      		             then mobAdverse := mobAdverse + 2         {les coups pairs ont un leger malus}
      		             else mobAdverse := mobAdverse + 1;
      		           
      		           
      		         end; {3}
		               
		           if mobAdverse > mobiliteMax then mobiliteMax := mobAdverse;
		           if mobAdverse < mobiliteMin then mobiliteMin := mobAdverse;
		              
		           k := denombrementPourCetteMobilite[mobAdverse];
		           k := k+1;
		           denombrementPourCetteMobilite[mobAdverse] := k;
		           triParDenombrementMobilite[mobAdverse][k] := coupTest;

		         end; {if coupLegal then } {2}
		         
		     celluleDansListeChaineeCasesVides1 := celluleNext1;
		     
		   end; {with celluleDansListeChaineeCasesVides1^ do} {1}
		   
	 until celluleDansListeChaineeCasesVides1 = celluleDepart;
	   
	 {$IFC (DEBUG_BITBOARD_ALPHA_BETA) }
	 WritelnStringAndNumDansRapport('mobiliteMin=',mobiliteMin);
	 WritelnStringAndNumDansRapport('mobiliteMax=',mobiliteMax);
	 {$ENDC}
	 
	 nbCoups := 0;
	 for i := mobiliteMin to mobiliteMax do
	   for k := 1 to denombrementPourCetteMobilite[i] do
	     begin
	       inc(nbCoups);
	       listeCoupsLegaux[nbCoups] := triParDenombrementMobilite[i][k];
	       {$IFC (DEBUG_BITBOARD_ALPHA_BETA) }
	       WriteStringAndNumDansRapport('mob='+NumEnString(i)+' pour la case ',listeCoupsLegaux[nbCoups]);
	       WritelnStringAndCoupDansRapport(' ie la case ',listeCoupsLegaux[nbCoups]);
	       {$ENDC}
	     end;
	     
	 {$IFC (DEBUG_BITBOARD_ALPHA_BETA) }
	 WritelnStringAndNumDansRapport('donc  nbCoupsLegaux=',nbCoups);
	 WritelnDansRapport('sortie de TrierFastestFirstPariteBitboard.');
   WritelnDansRapport('');
	 {$ENDC}
	 TrierFastestFirstPariteBitboard := nbCoups;
end;

{ tri des coups legaux par fastest-first; 
  on renvoie le nombre de coups legaux pour la couleur qui a le trait}
function TrierFastestFirstBitboardMobilite(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;nbCasesVides : SInt32; var listeCoupsLegaux:listeVides;coupAMettreEnTete : SInt32) : SInt32;
var i,k : SInt32;
    celluleDepart:celluleCaseVideDansListeChaineePtr;
    celluleDansListeChaineeCasesVides1:celluleCaseVideDansListeChaineePtr;
    celluleNext1:celluleCaseVideDansListeChaineePtr;
    position:bitboard;
    nbCoups,mobAdverse,coupTest : SInt32;
    diffBidon,mobiliteMin,mobiliteMax : SInt32;
    my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32;
    
    coup_legaux_lo,coup_legaux_hi : UInt32;
    constante2,constante3,constante4,constante5,constante6,constante7 : UInt32;
    opp,my : UInt32;
    result_lo,result_hi : UInt32;
    
begin
   
   {$IFC DEBUG_BITBOARD_ALPHA_BETA}
   WritelnDansRapport('');
   WritelnDansRapport('Entrée dans TrierFastestFirstBitboardMobilite :');
   {$ENDC}

	 diffBidon := 0;
	 
	 for i := 0 to nbCasesVides + 5 do
	   denombrementPourCetteMobilite[i] := 0;
	 
	 mobiliteMax := -1000;
	 mobiliteMin :=  1000;
	 
	 celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
   celluleDansListeChaineeCasesVides1 := celluleDepart^.next;
   repeat 
		 with celluleDansListeChaineeCasesVides1^ do
		   begin
		     celluleNext1 := next;
		     coupTest := square;
		     
		     if ModifPlatPlausible(coupTest,pos_opp_bits_low,pos_opp_bits_high) &
		       (ModifPlatBitboard(coupTest,0,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffBidon)<>0)
		       then
		         begin
		         
		               
	              {
	              with position do
	                mobAdverse := CalculeMobiliteBitboard(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high);
	              inline !
	              }
	              
	             { Si coupTest est le coup a mettre en tete, on force artificiellement 
		             la mobilite adverse a zero pour ce coup : cela tendra a le mettre en tete
		             dans le tri fastest first. Sinon, on calcule normalement la mobilite de 
		             l'adversaire } 
	              
	             
	             if (coupTest = coupAMettreEnTete)
	               then 
	                 begin
	                   mobAdverse := 0;
	                 end
	               else
	                 begin
	              
      	              with position do
      									begin
      							      my_bits_low := g_my_bits_low   ;
      							      my_bits_high := g_my_bits_high  ;
      							      opp_bits_low := g_opp_bits_low  ;
      							      opp_bits_high := g_opp_bits_high ;
      							    end;
      							    
      	               
      	               
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
      							  
      							  constante7 := $80808080;
      							  constante6 := $C0C0C0C0;
      							  constante5 := $E0E0E0E0;
      							  constante4 := $F0F0F0F0;
      							  constante3 := $F8F8F8F8;
      							  constante2 := $FCFCFCFC;
      							  
      							  
      							  
      							  (* this version is faster that the obvious one : it uses carries to "flip" bits *)
      							  
      							  my             := (my_bits_low shl 1);
      							  opp            := (opp_bits_low and $7E7E7E7E);
      							  coup_legaux_lo := coup_legaux_lo or ((my + opp) and not(my));
      							  
      							  my             := (my_bits_high shl 1);
      							  opp            := (opp_bits_high and $7E7E7E7E);
      							  coup_legaux_hi := coup_legaux_hi or ((my + opp) and not(my));
      							  
      							  {retournements diagonaux de A1 vers H8 de haut en bas}
      							  
      							  
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
      							      result_lo := (result_lo + (result_lo shr 8));
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
      								
      								mobAdverse := 1 + result_lo + result_hi;
      								
		               end;
		               
		               
		           if mobAdverse > mobiliteMax then mobiliteMax := mobAdverse;
		           if mobAdverse < mobiliteMin then mobiliteMin := mobAdverse;
		              
		           k := denombrementPourCetteMobilite[mobAdverse];
		           k := k+1;
		           denombrementPourCetteMobilite[mobAdverse] := k;
		           triParDenombrementMobilite[mobAdverse][k] := coupTest;

		         end;
		     celluleDansListeChaineeCasesVides1 := celluleNext1;
		   end;
	 until celluleDansListeChaineeCasesVides1 = celluleDepart;
	   
	 {$IFC (DEBUG_BITBOARD_ALPHA_BETA) }
	 WritelnStringAndNumDansRapport('mobiliteMin=',mobiliteMin);
	 WritelnStringAndNumDansRapport('mobiliteMax=',mobiliteMax);
	 {$ENDC}
	 
	 nbCoups := 0;
	 for i := mobiliteMin to mobiliteMax do
	   for k := 1 to denombrementPourCetteMobilite[i] do
	     begin
	       inc(nbCoups);
	       listeCoupsLegaux[nbCoups] := triParDenombrementMobilite[i][k];
	       {$IFC (DEBUG_BITBOARD_ALPHA_BETA) }
	       WriteStringAndNumDansRapport('mob='+NumEnString(i)+' pour la case ',listeCoupsLegaux[nbCoups]);
	       WritelnStringAndCoupDansRapport(' ie la case ',listeCoupsLegaux[nbCoups]);
	       {$ENDC}
	     end;
	     
	 {$IFC (DEBUG_BITBOARD_ALPHA_BETA) }
	 WritelnStringAndNumDansRapport('donc  nbCoupsLegaux=',nbCoups);
	 WritelnDansRapport('sortie de TrierFastestFirstBitboardMobilite.');
   WritelnDansRapport('');
	 {$ENDC}
	 TrierFastestFirstBitboardMobilite := nbCoups;
end;



procedure EcritTriFastestFirstBitboardDansRapport(var position:bitboard);
var listeCasesVides:listeVides;
    nbCasesVides,i,square,nbCoupsLegaux : SInt32;
    v : UInt32;
begin
  nbCasesVides := 0;
  for i := 1 to 64 do
    begin
      square := othellier[i];
      v := othellierBitboardDescr[square].constanteHexa;
      if othellierBitboardDescr[square].isLow
        then
          begin
            if (BAND(position.g_my_bits_low,v)=0) & (BAND(position.g_opp_bits_low,v)=0) then
              begin
                inc(nbCasesVides);
                listeCasesVides[nbCasesVides] := square;
              end;
          end
        else
          begin
            if (BAND(position.g_my_bits_high,v)=0) & (BAND(position.g_opp_bits_high,v)=0) then
              begin
                inc(nbCasesVides);
                listeCasesVides[nbCasesVides] := square;
              end;
          end;
    end;
  
  with position do
    nbCoupsLegaux := TrierFastestFirstBitboard(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,nbCasesVides,listeCasesVides,0);
    
end;


{$ENDC}

END.