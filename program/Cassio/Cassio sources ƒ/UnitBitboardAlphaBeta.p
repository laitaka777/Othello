UNIT UnitBitboardAlphaBeta;


INTERFACE







{$DEFINEC AVEC_DEBUG_UNROLLED FALSE}
{$DEFINEC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES false}

USES UnitBitboardTypes,UnitOth0;



{$IFC USING_BITBOARD}
function LanceurBitboardAlphaBeta(var plat:plOthEndgame;couleur,ESprof,alpha,beta,diffPions : SInt32) : SInt32;
function PeutFaireFinaleBitboardCettePosition(var plat : plateauOthello;couleur,alphaMilieu,betaMilieu,nbNoirs,nbBlancs : SInt32; var note : SInt32) : boolean;


function ABFinBitboardQuatreCasesVides(var position:bitboard;alpha_4,beta_4,diffPions_4,vecteurParite_4 : SInt32{;debugageUnrolled : boolean}) : SInt32;
function ABFinBitboardPariteSansStabilite(var position:bitboard;ESprof,alpha,beta,diffPions,vecteurParite : SInt32;vientDePasser : boolean) : SInt32;
function ABFinBitboardParite(var position:bitboard;ESprof,alpha,beta,diffPions,vecteurParite : SInt32;vientDePasser : boolean) : SInt32;
function ABFinBitboardPariteHachage(var position:bitboard;ESprof,alpha,beta,diffPions,vecteurParite : SInt32;vientDePasser : boolean) : SInt32;
function ABFinBitboardFastestFirst(var position:bitboard;ESprof,alpha,beta,diffPions,vecteurParite : SInt32;vientDePasser : boolean) : SInt32;
{$ENDC}


{$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
procedure ResetStatistiquesOrdreOptimumDesCases;
procedure EcritStatistiquesOrdreOptimumDesCasesDansRapport;
{$ENDC}


IMPLEMENTATION

USES UnitMacExtras,UnitBitboardHash,UnitMiniProfiler,UnitRapport,UnitBitboardQuatreSimple,
     UnitBitboardDernierCoup,UnitBitboardModifPlat,UnitBitboardDeuxCasesVides,
     UnitBitboardFlips,UnitBitboardStabilite,UnitVariablesGlobalesFinale,
     UnitBitboardQuatreCasesVides,UnitBitboardMobilite;







{$IFC USING_BITBOARD}



  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
  
  var gOrdreOptimum : record
                        nombre_statistiques : SInt32;
                        meilleur_coup_dans_cette_case : plOthLongint;
                        ce_coup_est_legal : plOthLongint;
                      end;
  
  {$ENDC}


	{$IFC UTILISE_MINIPROFILER_POUR_MILIEU OR UTILISE_MINIPROFILER_POUR_LANCEUR_BITBOARD}
	var microSecondesCurrentBitboard : array[0..64] of UnsignedWide;
    	microSecondesDepartBitboard : array[0..64] of UnsignedWide;

	procedure BeginMiniprofilerBitboard(nroDuCoup : SInt32);
  	begin
    	Microseconds(microSecondesDepartBitboard[nroDuCoup]);
		end;
	
	procedure EndMiniprofilerBitboard(nroDuCoup : SInt32);
  	begin
    	Microseconds(microSecondesCurrentBitboard[nroDuCoup]);
	  	AjouterTempsDansMiniProfiler(nroDuCoup,-1,microSecondesCurrentBitboard[nroDuCoup].lo-microSecondesDepartBitboard[nroDuCoup].lo,ktempsMoyen+kpourcentage);
		end;
	
	{$ENDC}




{$IFC NOT(USING_DEUXCASESVIDESBITBOARDFAST) }


{ DeuxCasesVidesBitboard pour quand il reste deux cases vides.
  Attention : position est modifiee par cette routine ! 
  Remarque : DeuxCasesVidesBitboardFast est nettement plus rapide }
function DeuxCasesVidesBitboard(var position:bitboard;alpha,beta,diffPionsDeuxCasesVides : SInt32;vientDePasser : boolean) : SInt32;
var my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32;
    diffPions : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    iCourant1,iCourant2 : SInt32;
    celluleDansListeChaineeCasesVides:celluleCaseVideDansListeChaineePtr;
begin

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME) }
  inc(nbreNoeudsGeneresFinale);
  {$ENDC}
    
  maxPourBestDefABFinPetite := -noteMax;
  with position do
   begin
     my_bits_low   := g_my_bits_low;
     my_bits_high  := g_my_bits_high;
     opp_bits_low  := g_opp_bits_low;
     opp_bits_high := g_opp_bits_high;
   end;
  diffPions := diffPionsDeuxCasesVides;
  
  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans DeuxCasesVidesBitboard :',position,2,alpha,beta,diffPionsDeuxCasesVides);
  AttendFrappeClavier;
  {$ENDC}
		
  celluleDansListeChaineeCasesVides := gTeteListeChaineeCasesVides.next;
  with celluleDansListeChaineeCasesVides^ do
    begin
      iCourant1 := square;
      iCourant2 := next^.square;
    end;
      
  if ModifPlatPlausible(iCourant1,opp_bits_low,opp_bits_high) &
     (ModifPlatBitboard(iCourant1,0,my_bits_low,my_bits_high,opp_bits_low,opp_bits_high,position,diffPions) <> 0) then
    BEGIN
      with position do
        noteCourante := DernierCoupBitboard(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,diffPions,iCourant2);
        
      maxPourBestDefABFinPetite := noteCourante;
      if (noteCourante>alpha) then 
        begin
          if (noteCourante>=beta) then 
            begin
              DeuxCasesVidesBitboard := noteCourante;
              exit(DeuxCasesVidesBitboard);
            end;
          alpha := noteCourante;
        end;
      diffPions := diffPionsDeuxCasesVides;
    END;
  
  if ModifPlatPlausible(iCourant2,opp_bits_low,opp_bits_high) &
     (ModifPlatBitboard(iCourant2,0,my_bits_low,my_bits_high,opp_bits_low,opp_bits_high,position,diffPions) <> 0) then
    BEGIN
      with position do
        noteCourante := DernierCoupBitboard(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,diffPions,iCourant1);

		  if noteCourante>maxPourBestDefABFinPetite then
		    begin
		      maxPourBestDefABFinPetite := noteCourante;
		      if (noteCourante>alpha) then 
		        begin
		          if (noteCourante>=beta) then 
		            begin
		              DeuxCasesVidesBitboard := noteCourante;
		              exit(DeuxCasesVidesBitboard);
		            end;
		          alpha := noteCourante;
		        end;
		   end;
    END;
  
 
{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       DeuxCasesVidesBitboard := maxPourBestDefABFinPetite;
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}
           
           if diffPionsDeuxCasesVides>0 then 
             begin
               DeuxCasesVidesBitboard := diffPionsDeuxCasesVides + 2;
               exit(DeuxCasesVidesBitboard);
             end;
           if diffPionsDeuxCasesVides<0 then 
             begin
               DeuxCasesVidesBitboard := diffPionsDeuxCasesVides - 2;
               exit(DeuxCasesVidesBitboard);
             end;
           DeuxCasesVidesBitboard := 0;
           exit(DeuxCasesVidesBitboard);
         end          
       else
         begin
           { passe! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}
           
           with position do
             begin
               g_my_bits_high  := opp_bits_high;
               g_opp_bits_high := my_bits_high;
               g_my_bits_low   := opp_bits_low;
               g_opp_bits_low  := my_bits_low;
             end;
           DeuxCasesVidesBitboard := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffPionsDeuxCasesVides,true);
         end;
     end;
end;   { DeuxCasesVidesBitboard }  

{$ENDC}




{ ABFinBitboardQuatreCasesVides : pour quand il reste quatre cases vides.
  Attention : position est modifiee par cette routine ! }
function ABFinBitboardQuatreCasesVides(var position:bitboard;alpha_4,beta_4,diffPions_4,vecteurParite_4 : SInt32{;debugageUnrolled : boolean}) : SInt32;
var neVientPasDePasser : SInt32;
    temp : SInt32;

var { variables pour la prof 4 }
    pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4 : UInt32;
    diffEssai_4 : SInt32;
    notecourante_4,maxPourBestDefABFinPetite_4 : SInt32;
    iCourant_4 : SInt32; 
    celluleDansListeChaineeCasesVides_4:celluleCaseVideDansListeChaineePtr;
    celluleDepart_4:celluleCaseVideDansListeChaineePtr;
    cellulePrevious_4:celluleCaseVideDansListeChaineePtr;
    pairesImpaires_4 : SInt32;
 
var { variables pour la prof 3 }

    alpha_3,beta_3 : SInt32;
    pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3 : UInt32;
    diffPions_3,diffEssai_3 : SInt32;
    maxPourBestDefABFinPetite_3 : SInt32;
    iCourant_3 : SInt32; 
    celluleDansListeChaineeCasesVides_3:celluleCaseVideDansListeChaineePtr;
    celluleDepart_3:celluleCaseVideDansListeChaineePtr;
    cellulePrevious_3:celluleCaseVideDansListeChaineePtr;
    vecteurParite_3,pairesImpaires_3 : SInt32;

label { labels pour la prof 4 }
      testerCetteParite_prof_4,debut_prof_4,fin_prof_4;
      


label { labels pour la prof 3 }
      testerCetteParite_prof_3,debut_prof_3,fin_prof_3;
      
    

begin

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  inc(nbreNoeudsGeneresFinale);
  {$ENDC}
   
  
  with position do
    begin
      pos_my_bits_low_4   := g_my_bits_low;
      pos_my_bits_high_4  := g_my_bits_high;
      pos_opp_bits_low_4  := g_opp_bits_low;
      pos_opp_bits_high_4 := g_opp_bits_high;
    end;
  
  if (alpha_4 >= 50) |
     ((alpha_4 >= 0) & (diffPions_4 <= alpha_4 - 24)) then
    begin
      { Calculons la note maximale que l'on peut obtenir, 
        connaissant les pions definitifs de l'adversaire }
      noteCourante_4 := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low_4,pos_opp_bits_high_4,pos_my_bits_low_4,pos_my_bits_high_4, BSR(65-alpha_4,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante_4 <= alpha_4 then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardQuatreCasesVides :',MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),4,alpha_4,beta_4,diffPions_4);
          WritelnStringAndNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low_4,pos_opp_bits_high_4,pos_my_bits_low_4,pos_my_bits_high_4, BSR(65-alpha_4,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardQuatreCasesVides := noteCourante_4;
          exit(ABFinBitboardQuatreCasesVides);
        end;
    end;
  if (beta_4 <= -50) | 
     ((beta_4 <= 0) & (diffPions_4 >= beta_4 + 24)) then
    begin
      { Calculons la note minimale que l'on peut obtenir, 
        connaissant nos pions definitifs }
      noteCourante_4 := -64 + 2*CalculePionsStablesBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4, BSR(65+beta_4,1));
      { noteCourante = la note minimale que l'on peut esperer obtenir}
      if noteCourante_4 >= beta_4 then { coupure beta !... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardQuatreCasesVides :',MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),4,alpha_4,beta_4,diffPions_4);
          WritelnStringAndNumDansRapport('pions stables amis = ',CalculePionsStablesBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4, BSR(65+beta_4,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardQuatreCasesVides := noteCourante_4;
          exit(ABFinBitboardQuatreCasesVides);
        end;
    end;
  
  
  
  
  
  
  neVientPasDePasser := (neVientPasDePasser OR $00000010);   { bit set 4    : a priori on passe pas à prof 4}
  neVientPasDePasser := (neVientPasDePasser AND $FFFFBFFF);  { bit clear 14 : on ne sait pas encore si on va jouer à prof 4}
  maxPourBestDefABFinPetite_4 := -noteMax;
  
debut_prof_4:
  
  diffEssai_4 := diffPions_4;
  
  {$IFC AVEC_DEBUG_UNROLLED}
  if debugageUnrolled then
    begin
		  EcritBitboardState('label debut_prof_4 dans ABFinBitboardQuatreCasesVides :',
		                      MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),
		                      4,alpha_4,beta_4,diffPions_4);
		  if (4>=3) then
		    begin
		      WritelnStringAndBooleanDansRapport('vient de passer = ',not(((neVientPasDePasser AND $00000010) <> 0)));
				  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAND(vecteurParite_4,constanteDeParite[11])=0);
				  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAND(vecteurParite_4,constanteDeParite[18])=0);
				  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAND(vecteurParite_4,constanteDeParite[81])=0);
				  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAND(vecteurParite_4,constanteDeParite[88])=0);
				end;
		  AttendFrappeClavier;
		end;
  {$ENDC}
  
  
  
 
 
 if (BAND(vecteurParite_4,15) <> 0)
   then pairesImpaires_4 := vecteurParite_4        {s'il y a des coups impairs, on teste d'abord les coups impairs}
   else pairesImpaires_4 := not(vecteurParite_4);  {sinon, on commence directement tous les coups pairs}
   
   
   
 testerCetteParite_prof_4 :
 
  celluleDepart_4 := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides_4 := celluleDepart_4^.next;
  cellulePrevious_4 := celluleDepart_4;
  repeat 
    with celluleDansListeChaineeCasesVides_4^ do
      begin
      
        iCourant_4 := square;

        if BAND(pairesImpaires_4,constantePariteDeSquare) <> 0 then
	        begin
	          {$IFC AVEC_DEBUG_UNROLLED}
	          if debugageUnrolled then
	            begin
			          EcritBitboardState('dans ABFinBitboardQuatreCasesVides :',
			                              MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),
			                              4,alpha_4,beta_4,diffPions_4);
			          WritelnDansRapport('pairesImpaires_4 = '+Hexa(pairesImpaires_4));
			          if BAND(pairesImpaires_4,$00008000)=0 
			            then WritelnStringAndCoupDansRapport('coup impair : ',iCourant_4)
			            else WritelnStringAndCoupDansRapport('coup pair : ',iCourant_4);
			          WritelnDansRapport('');
			          AttendFrappeClavier;
	            end;
	          {$ENDC}
	          
	          if ModifPlatPlausible(iCourant_4,pos_opp_bits_low_4,pos_opp_bits_high_4)
	            then vecteurParite_3 := ModifPlatBitboard(iCourant_4,vecteurParite_4, pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4,position,diffEssai_4)
	            else vecteurParite_3 := vecteurParite_4;
	            
	          if (vecteurParite_3 <> vecteurParite_4) then
		          BEGIN
			          
			          
			          neVientPasDePasser := (neVientPasDePasser OR $00004000);  { bit set 14 : on a joue a profondeur 4 }
			          
			         {EnleverDeLaListeChaineeDesCasesVides(iCourant_4)}
			          cellulePrevious_4^.next := next;
		            
		            (*
		            
			          if (profMoins1=2) 
			            then 
			              begin
			                {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
			                with position do
			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,
			                                                              -beta_4,-alpha_4,-diffEssai_4,false);
			                {$ELSEC}
			                noteCourante := -DeuxCasesVidesBitboard(position,-beta_4,-alpha_4,-diffEssai_4,false);
			                {$ENDC}
			              end
			            else 
			              noteCourante := -ABFinBitboardQuatreCasesVides(position,profMoins1,-beta_4,-alpha_4,-diffEssai_4,nouvelleParite,debugageUnrolled);
			              
			          *)
	
	(****************************************************************************)
	(******************* appel recursif à prof 3  *******************************)
  (****************************************************************************)			          
			          
  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  inc(nbreNoeudsGeneresFinale);
  {$ENDC}
   
   
  alpha_3 := -beta_4;
  beta_3 := -alpha_4;
  diffPions_3 := -diffEssai_4;
  
  with position do
    begin
      pos_my_bits_low_3   := g_my_bits_low;
      pos_my_bits_high_3  := g_my_bits_high;
      pos_opp_bits_low_3  := g_opp_bits_low;
      pos_opp_bits_high_3 := g_opp_bits_high;
    end;
  neVientPasDePasser := (neVientPasDePasser OR $00000008);   { bit set 3    : a priori on ne passe pas à prof 3}
  neVientPasDePasser := (neVientPasDePasser AND $FFFFDFFF);  { bit clear 13 : on ne sait pas encore si on va jouer à prof 3}
  maxPourBestDefABFinPetite_3 := -noteMax;
    
debut_prof_3:
  
  diffEssai_3 := diffPions_3;
  
  {$IFC AVEC_DEBUG_UNROLLED}
  if debugageUnrolled then
    begin
		  EcritBitboardState('label debut_prof_3 dans ABFinBitboardQuatreCasesVides_3 :',
		                      MakeBitboard(pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3),
		                      3,alpha_3,beta_3,diffEssai_3);
		  if (3>=3) then
		    begin
		      WritelnStringAndBooleanDansRapport('vient de passer = ',not(((neVientPasDePasser AND $00000008) <> 0)));
				  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAND(vecteurParite_3,constanteDeParite[11])=0);
				  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAND(vecteurParite_3,constanteDeParite[18])=0);
				  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAND(vecteurParite_3,constanteDeParite[81])=0);
				  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAND(vecteurParite_3,constanteDeParite[88])=0);
				end;
		  AttendFrappeClavier;
		end;
  {$ENDC}
		
 pairesImpaires_3 := vecteurParite_3;  {d'abord les coups impairs}
 
 testerCetteParite_prof_3 :
  
  celluleDepart_3 := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides_3 := celluleDepart_3^.next;
  cellulePrevious_3 := celluleDepart_3;
  repeat 
    with celluleDansListeChaineeCasesVides_3^ do
      begin
      
        iCourant_3 := square;

        if BAND(pairesImpaires_3,constantePariteDeSquare) <> 0 then
	        begin
	          {$IFC AVEC_DEBUG_UNROLLED}
	          if debugageUnrolled then
	            begin
			          EcritBitboardState('dans ABFinBitboardQuatreCasesVides_3 :',
			                              MakeBitboard(pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3),
			                              3,alpha_3,beta_3,diffEssai_3);
			          WritelnDansRapport('pairesImpaires_3 = '+Hexa(pairesImpaires_3));
			          if BAND(pairesImpaires_3,$00008000)=0 
			            then WritelnStringAndCoupDansRapport('coup impair : ',iCourant_3)
			            else WritelnStringAndCoupDansRapport('coup pair : ',iCourant_3);
			          WritelnDansRapport('');
			          AttendFrappeClavier;
	            end;
	          {$ENDC}
	          
	           if ModifPlatPlausible(iCourant_3,pos_opp_bits_low_3,pos_opp_bits_high_3) &
                (ModifPlatBitboard(iCourant_3,0,pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3,position,diffEssai_3) <> 0)
              then
              
		          BEGIN
		          
		            neVientPasDePasser := (neVientPasDePasser OR $00002000);  { bit set 13 : on a joue a profondeur 3 }
			          
			         {EnleverDeLaListeChaineeDesCasesVides(iCourant_3)}
			          cellulePrevious_3^.next := next;
		            
		            {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
		            
                with position do
                  temp := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,
                                                              -beta_3,-alpha_3,-diffEssai_3,false);
                    
                {$ELSEC}
                
                temp := -DeuxCasesVidesBitboard(position,-beta_3,-alpha_3,-diffEssai_3,false);
                
                {$ENDC}
			              
			              
			              
			              
			              
			         {RemettreDansLaListeChaineeDesCasesVides(iCourant_3);}
			          cellulePrevious_3^.next := celluleDansListeChaineeCasesVides_3;
							 							 
							 	if temp > maxPourBestDefABFinPetite_3 then
							 	  begin
		                if temp > alpha_3 then 
		                  begin
		                    if temp >= beta_3 then 
		                      begin
		                        if ((neVientPasDePasser AND $00000008) <> 0)  { bit test 3 : est-ce un coup normal à prof 3… ? }
										          then 
										            begin
										              noteCourante_4 := -temp;
										              {$IFC AVEC_DEBUG_UNROLLED}
										              if debugageUnrolled then
										                WritelnStringAndNumDansRapport('beta-coupure à prof 3, soit ',-temp); 
										              {$ENDC}
										            end
										          else                                         { …ou le resultat d'un passe a profondeur 3 ? }
										            begin
										              noteCourante_4 := temp; 
										              {$IFC AVEC_DEBUG_UNROLLED}
										              if debugageUnrolled then
										                WritelnStringAndNumDansRapport('- beta-coupure à prof 3, soit ',temp);
										              {$ENDC}
										            end;
		                        goto fin_prof_3;
		                      end;
		                    alpha_3 := temp;
		                  end; { if temp > alpha_3 }
                    maxPourBestDefABFinPetite_3 := temp;
                  end; { if temp > maxPourBestDefABFinPetite_3 }
                  
			          diffEssai_3 := diffPions_3;
	            END;
	        end;    
	      cellulePrevious_3 := celluleDansListeChaineeCasesVides_3;
        celluleDansListeChaineeCasesVides_3 := next;
      end;
  until celluleDansListeChaineeCasesVides_3 = celluleDepart_3;


  if BAND(pairesImpaires_3,$00008000)=0 then 
    begin
      pairesImpaires_3 := not(vecteurParite_3);   {puis les coups pairs}
      goto testerCetteParite_prof_3;
    end;
  

 
{fin:}
 if ((neVientPasDePasser AND $00002000) <> 0) { bit test 13 : a-t-on joue à prof 3 ?}
   then
     begin
       if ((neVientPasDePasser AND $00000008) <> 0) { bit test 3 : est-ce un coup normal à prof 3… ? }
         then 
           begin
             noteCourante_4 := -maxPourBestDefABFinPetite_3;
             {$IFC AVEC_DEBUG_UNROLLED}
             if debugageUnrolled then
							 WritelnStringAndNumDansRapport('on renvoie -maxPourBestDefABFinPetite_3, soit ',-maxPourBestDefABFinPetite_3);
						 {$ENDC}
					 end
         else                        { …ou le resultat d'un passe à prof 3 ? }
           begin
             noteCourante_4 := maxPourBestDefABFinPetite_3; 
             {$IFC AVEC_DEBUG_UNROLLED}
             if debugageUnrolled then
							 WritelnStringAndNumDansRapport('on renvoie maxPourBestDefABFinPetite_3, soit ',maxPourBestDefABFinPetite_3);
						 {$ENDC}
					 end;
       goto fin_prof_3;
     end
   else
     begin
      if ((neVientPasDePasser AND $00000008) <> 0)   { si l'adversaire ne vient pas de passer a profondeur 3… }
       then
         begin
           { passe! }
           
           {$IFC AVEC_DEBUG_UNROLLED}
           if debugageUnrolled then
             begin
               WritelnDansRapport('passe !');
               AttendFrappeClavier;
             end;
           {$ENDC}
           
           neVientPasDePasser := (neVientPasDePasser AND $FFFFFFF7);
           
           temp                := pos_opp_bits_high_3;
           pos_opp_bits_high_3 := pos_my_bits_high_3;
           pos_my_bits_high_3  := temp;
           temp                := pos_opp_bits_low_3;
           pos_opp_bits_low_3  := pos_my_bits_low_3;
           pos_my_bits_low_3   := temp;
           
           temp    := -alpha_3;
           alpha_3 := -beta_3;
           beta_3  := temp;
           diffPions_3 := -diffPions_3;
           
           goto debut_prof_3;
         end
       else
         begin
           { terminé! }
           
           {$IFC AVEC_DEBUG_UNROLLED}
           if debugageUnrolled then
             begin
               EcritBitboardState('position à trois cases vides :',
			                              MakeBitboard(pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3),
			                              3,alpha_3,beta_3,diffEssai_3);
		           WritelnDansRapport('terminé : il reste 3 cases vides !!');
		           AttendFrappeClavier;
		         end;
		       {$ENDC}
           
           if diffPions_3 > 0 then 
             begin
               noteCourante_4 := (diffPions_3 + 3);
               goto fin_prof_3;
             end;
           if diffPions_3 < 0 then 
             begin
               noteCourante_4 := (diffPions_3 - 3) ;
               goto fin_prof_3;
             end;
           noteCourante_4 := 0;
           goto fin_prof_3;
         end;
     end;
   
   
   fin_prof_3 :
			          
	(****************************************************************************)
	(******************* fin de l'appel recursif à prof 3  **********************)
  (****************************************************************************)			          
			              
			              
			              
			         {RemettreDansLaListeChaineeDesCasesVides(iCourant_4);}
			          cellulePrevious_4^.next := celluleDansListeChaineeCasesVides_4;
							 	
							 	if noteCourante_4 > maxPourBestDefABFinPetite_4 then
							 	  begin	 
		                if noteCourante_4 > alpha_4 then 
		                  begin
		                    if noteCourante_4 >= beta_4 then 
		                      begin
		                        if ((neVientPasDePasser AND $00000010) <> 0)
										          then 
										            begin
										              ABFinBitboardQuatreCasesVides := noteCourante_4;
										              {$IFC AVEC_DEBUG_UNROLLED}
										              if debugageUnrolled then
										                WritelnStringAndNumDansRapport('beta-coupure à prof 4, soit ',noteCourante_4); 
										              {$ENDC}
										            end
										          else 
										            begin
										              ABFinBitboardQuatreCasesVides := -noteCourante_4; 
										              {$IFC AVEC_DEBUG_UNROLLED}
										              if debugageUnrolled then
										                WritelnStringAndNumDansRapport('- beta-coupure à prof 4, soit ',-noteCourante_4);
										              {$ENDC}
										            end;
		                        goto fin_prof_4;
		                      end;
		                    alpha_4 := noteCourante_4;
		                  end; { if noteCourante_4 > alpha_4 }
		                maxPourBestDefABFinPetite_4 := noteCourante_4;
		              end; { if noteCourante_4 > maxPourBestDefABFinPetite_4 }
			          diffEssai_4 := diffPions_4;
	            END;
	        end;
	      cellulePrevious_4 := celluleDansListeChaineeCasesVides_4;
        celluleDansListeChaineeCasesVides_4 := next;
      end;
  until celluleDansListeChaineeCasesVides_4 = celluleDepart_4;


 if BAND(pairesImpaires_4,$00008000)=0 then
   begin
     pairesImpaires_4 := not(vecteurParite_4);   {puis les coups pairs}
     goto testerCetteParite_prof_4;
   end;

 
{fin:}
 if ((neVientPasDePasser AND $00004000) <> 0)  { bit test 14 : a-t-on joue à prof 4 ?}
   then
     begin
       if ((neVientPasDePasser AND $00000010) <> 0)  { bit test 4 : est-ce un coup normal à prof 4… ? }
         then 
           begin
             ABFinBitboardQuatreCasesVides := maxPourBestDefABFinPetite_4;
             {$IFC AVEC_DEBUG_UNROLLED}
             if debugageUnrolled then
							 WritelnStringAndNumDansRapport('on renvoie maxPourBestDefABFinPetite_4, soit ',maxPourBestDefABFinPetite_4);
						 {$ENDC}
					 end
         else                         { …ou le resultat d'un passe à prof 4 ? }
           begin
             ABFinBitboardQuatreCasesVides := -maxPourBestDefABFinPetite_4; 
             {$IFC AVEC_DEBUG_UNROLLED}
             if debugageUnrolled then
							 WritelnStringAndNumDansRapport('on renvoie -maxPourBestDefABFinPetite_4, soit ',-maxPourBestDefABFinPetite_4);
						 {$ENDC}
					 end;
       goto fin_prof_4;
     end
   else
     begin
      if ((neVientPasDePasser AND $00000010) <> 0)
       then
         begin
           { passe! }
           
           {$IFC AVEC_DEBUG_UNROLLED}
           if debugageUnrolled then
             begin
               WritelnDansRapport('passe !');
               AttendFrappeClavier;
             end;
           {$ENDC}
           
           neVientPasDePasser := (neVientPasDePasser AND $FFFFFFEF);
           
           temp                := pos_opp_bits_high_4;
           pos_opp_bits_high_4 := pos_my_bits_high_4;
           pos_my_bits_high_4  := temp;
           temp                := pos_opp_bits_low_4;
           pos_opp_bits_low_4  := pos_my_bits_low_4;
           pos_my_bits_low_4   := temp;
           
           temp    := -alpha_4;
           alpha_4 := -beta_4;
           beta_4  := temp;
           diffPions_4 := -diffPions_4;
           
           goto debut_prof_4;
         end
       else
         begin
           { terminé! }
           
           {$IFC AVEC_DEBUG_UNROLLED}
           if debugageUnrolled then
             begin
               EcritBitboardState('position à quatre cases vides :',
			                              MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),
			                              4,alpha_4,beta_4,diffEssai_4);
		           WritelnDansRapport('terminé : il reste 4 cases vides !!');
		           AttendFrappeClavier;
		         end;
		       {$ENDC}
           
           if diffPions_4 > 0 then 
             begin
               ABFinBitboardQuatreCasesVides := - (diffPions_4 + 4);
               goto fin_prof_4;
             end;
           if diffPions_4 < 0 then 
             begin
               ABFinBitboardQuatreCasesVides :=   4 - diffPions_4 ;
               goto fin_prof_4;
             end;
           ABFinBitboardQuatreCasesVides := 0;
           goto fin_prof_4;
         end;
     end;
   
   
   fin_prof_4 :
    
end;   { ABFinBitboardQuatreCasesVides }  



{ ABFinBitboardPariteSansStabilite pour les petites profondeurs ( 4 < p <= 7 ).
  On utilise un ordre fixe des cases en jouant la parité.
  Attention : position est modifiee par cette routine ! }
  
function ABFinBitboardPariteSansStabilite(var position:bitboard;ESprof,alpha,beta,diffPions,vecteurParite : SInt32;vientDePasser : boolean) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    iCourant : SInt32; 
    celluleDansListeChaineeCasesVides:celluleCaseVideDansListeChaineePtr;
    celluleNext,cellulePrevious:celluleCaseVideDansListeChaineePtr;
    celluleDepart:celluleCaseVideDansListeChaineePtr;
    nouvelleParite : SInt32;
    {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		bestmove : SInt32;
		{$ENDC}
    {
    sauvegardePosition:bitboard;
    autreNoteCourante : SInt32;
    }
    
begin

  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  inc(nbreNoeudsGeneresFinale);
  {$ENDC}
  
  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
  if (gOrdreOptimum.nombre_statistiques < 2000000000) then
    begin
      inc(gOrdreOptimum.nombre_statistiques);
      alpha := -64;
      beta  := 64;
      bestmove := 0;
    end;
  {$ENDC}
   
  profMoins1 := pred(ESprof);   
  maxPourBestDefABFinPetite := -noteMax;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai := diffPions;
  
  
  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardPariteSansStabilite :',position,ESprof,alpha,beta,diffPions);
  if (ESProf>=3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAND(vecteurParite,constanteDeParite[11])=0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAND(vecteurParite,constanteDeParite[18])=0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAND(vecteurParite,constanteDeParite[81])=0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAND(vecteurParite,constanteDeParite[88])=0);
		end;
  AttendFrappeClavier;
  {$ENDC}



  if (BAND(vecteurParite,15) <> 0) then  {y a-t-il des coups impairs ?}
    BEGIN
		
    {impairs:}
      celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
      celluleDansListeChaineeCasesVides := celluleDepart^.next;
      cellulePrevious := celluleDepart;
      repeat 
        with celluleDansListeChaineeCasesVides^ do
          begin
            celluleNext := next;
            iCourant := square;
            
            if (BAND(vecteurParite,constantePariteDeSquare) <> 0) then
    	        begin
    	          {$IFC DEBUG_BITBOARD_ALPHA_BETA}
    	          EcritBitboardState('dans ABFinBitboardPariteSansStabilite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
    	          WritelnStringAndCoupDansRapport('coup impair : ',iCourant);
    	          WritelnDansRapport('');
    	          AttendFrappeClavier;
    	          {$ENDC}
    	          
    	          if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
    	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
    	            else nouvelleParite := vecteurParite;
    	          
    	          if nouvelleParite <> vecteurParite then
    		          BEGIN
    			          
    			          {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			          if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
    			          {$ENDC}
    			          
    			         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
    			          cellulePrevious^.next := celluleNext;
    		            
    		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    		            EndMiniprofilerBitboard(ESProf);
    		            {$ENDC}
    		            
    			          if (profMoins1 = 4) 
    			            then 
    			              begin
    			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      BeginMiniprofilerBitboard(4);
		                      {$ENDC}
		                  
		                    	{$IFC USING_QUATRECASESVIDESBITBOARDFAST}
		                    	noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite);
                          {$ELSEC}
                          noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                          noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                          {$ENDC}
		                      
		                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      EndMiniprofilerBitboard(4);
		                      {$ENDC}
    			              end
    			            else 
    			              begin
    			                if (profMoins1 = 2)
    			                  then 
    			                    begin
    			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
          			                with position do
          			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,false);
          			                {$ELSEC}
          			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
          			                {$ENDC}
    			                    end
    			                  else noteCourante := -ABFinBitboardPariteSansStabilite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,false);
    			              end;
    			         
    			         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                    BeginMiniprofilerBitboard(ESProf);
                   {$ENDC}
    			              
    			         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
    			          cellulePrevious^.next := celluleDansListeChaineeCasesVides;
    							 							 
    			          if (noteCourante > maxPourBestDefABFinPetite) then 
    			            begin
    			              {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			              if (gOrdreOptimum.nombre_statistiques < 2000000000) then bestmove := iCourant;
    			              {$ENDC}
    			              if (noteCourante >= beta) then 
    	                    begin
    	                      ABFinBitboardPariteSansStabilite := noteCourante;
    	                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    			                  EndMiniprofilerBitboard(ESProf);
    		                   {$ENDC}
    		                    exit(ABFinBitboardPariteSansStabilite);
    	                    end;
    			              if (noteCourante > alpha) then alpha := noteCourante;
    			              maxPourBestDefABFinPetite := noteCourante;
    			            end;
      			        
    			          diffEssai := diffPions;
    	            END;
    	        end;    
            cellulePrevious := celluleDansListeChaineeCasesVides;
            celluleDansListeChaineeCasesVides := celluleNext;
          end;
      until celluleDansListeChaineeCasesVides = celluleDepart;
      
    END;
  
{pairs:}
  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides := celluleDepart^.next;
  cellulePrevious := celluleDepart;
  repeat 
	  with celluleDansListeChaineeCasesVides^ do
	    begin
	      celluleNext := next;
	      iCourant := square;

	      if (BAND(vecteurParite,constantePariteDeSquare) = 0) then
          begin
            {$IFC DEBUG_BITBOARD_ALPHA_BETA}
	          EcritBitboardState('dans ABFinBitboardPariteSansStabilite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
	          WritelnStringAndCoupDansRapport('coup pair : ',iCourant);
	          WritelnDansRapport('');
	          AttendFrappeClavier;
	          {$ENDC}
          
          
            if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
	            else nouvelleParite := vecteurParite;
              
	          if nouvelleParite <> vecteurParite then
		          BEGIN
		            
		            {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		            if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
		            {$ENDC}
			          
			         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
			          cellulePrevious^.next := celluleNext;
		            
		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		            EndMiniprofilerBitboard(ESProf);
		            {$ENDC}
		            
			          if (profMoins1 = 4) 
			            then 
			              begin
			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  BeginMiniprofilerBitboard(4);
		                  {$ENDC}
		            
			                {$IFC USING_QUATRECASESVIDESBITBOARDFAST}
                      noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite);
                      {$ELSEC}
                      noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                      noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                      {$ENDC}
                      
                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  EndMiniprofilerBitboard(4);
		                  {$ENDC}
			              end
			            else 
			              begin
			                if (profMoins1 = 2)
			                  then 
			                    begin
			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
      			                with position do
      			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,false);
      			                {$ELSEC}
      			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
      			                {$ENDC}
			                    end
			                  else noteCourante := -ABFinBitboardPariteSansStabilite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,false);
			              end;
			          
			          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                BeginMiniprofilerBitboard(ESProf);
                {$ENDC}
			              
			         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
			          cellulePrevious^.next := celluleDansListeChaineeCasesVides;
							  
							  
							  if (noteCourante > maxPourBestDefABFinPetite) then 
			            begin
			              {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
			              if (gOrdreOptimum.nombre_statistiques < 2000000000) then bestmove := iCourant;
			              {$ENDC}
			              if (noteCourante >= beta) then 
	                    begin
	                      ABFinBitboardPariteSansStabilite := noteCourante;
	                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
			                  EndMiniprofilerBitboard(ESProf);
		                   {$ENDC}
		                    exit(ABFinBitboardPariteSansStabilite);
	                    end;
			              if (noteCourante > alpha) then alpha := noteCourante;
			              maxPourBestDefABFinPetite := noteCourante;
			            end;
			            
			          diffEssai := diffPions;
		          END;
		      end;
	      cellulePrevious := celluleDansListeChaineeCasesVides;
        celluleDansListeChaineeCasesVides := celluleNext;
	    end;
	 until celluleDansListeChaineeCasesVides = celluleDepart;

 
{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardPariteSansStabilite := maxPourBestDefABFinPetite; 
       {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
       if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.meilleur_coup_dans_cette_case[bestmove]);
       {$ENDC}
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}
           
           if diffPions>0 then 
             begin
               ABFinBitboardPariteSansStabilite := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardPariteSansStabilite);
             end;
           if diffPions<0 then 
             begin
               ABFinBitboardPariteSansStabilite := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
				      exit(ABFinBitboardPariteSansStabilite);
             end;
           ABFinBitboardPariteSansStabilite := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardPariteSansStabilite);
         end          
       else
         begin
           { passe! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}
           
           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardPariteSansStabilite := -ABFinBitboardPariteSansStabilite(position,ESprof,-beta,-alpha,-diffPions,vecteurParite,true);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardPariteSansStabilite }  



{ ABFinBitboardParite pour les petites profondeurs ( 4 < p <= 7 ).
  On utilise  a) les pions définitifs pour les positions a tres gros score
              b) un ordre fixe des cases en jouant la parité.
              
  Attention : position est modifiee par cette routine ! 
  Attention : toujours appeler cette routine avec au moins 5 cases vides, 
              sinon on boucle. ABFinBitboardFastestFirst est une routine 
              plus robuste, qui peut etre utilisee pour 0 <= p <= profForceBrute }
function ABFinBitboardParite(var position:bitboard;ESprof,alpha,beta,diffPions,vecteurParite : SInt32;vientDePasser : boolean) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    iCourant : SInt32; 
    celluleDansListeChaineeCasesVides:celluleCaseVideDansListeChaineePtr;
    celluleNext,cellulePrevious:celluleCaseVideDansListeChaineePtr;
    celluleDepart:celluleCaseVideDansListeChaineePtr;
    nouvelleParite : SInt32;
    {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		bestmove : SInt32;
		{$ENDC}
    {
    sauvegardePosition:bitboard;
    autreNoteCourante : SInt32;
    }
    
begin

  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  inc(nbreNoeudsGeneresFinale);
  {$ENDC}
  
  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
  if (gOrdreOptimum.nombre_statistiques < 2000000000) then
    begin
      inc(gOrdreOptimum.nombre_statistiques);
      alpha := -64;
      beta  := 64;
      bestmove := 0;
    end;
  {$ENDC}
   
  profMoins1 := pred(ESprof);   
  maxPourBestDefABFinPetite := -noteMax;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai := diffPions;
  
  if (alpha >= stability_alpha[ESProf]) {& (diffPions <= alpha-ESProf)} then
    begin
      { Calculons la note maximale que l'on peut obtenir, 
        connaissant les pions definitifs de l'adversaire }
      noteCourante := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSR(65-alpha,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante <= alpha then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardParite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
          WritelnStringAndNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSR(65-alpha,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardParite := noteCourante;
         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					EndMiniprofilerBitboard(ESProf);
				 {$ENDC}
          exit(ABFinBitboardParite);
        end;
      if noteCourante < beta then beta := noteCourante;
    end;

  
  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardParite :',position,ESprof,alpha,beta,diffPions);
  if (ESProf>=3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAND(vecteurParite,constanteDeParite[11])=0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAND(vecteurParite,constanteDeParite[18])=0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAND(vecteurParite,constanteDeParite[81])=0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAND(vecteurParite,constanteDeParite[88])=0);
		end;
  AttendFrappeClavier;
  {$ENDC}



  if (BAND(vecteurParite,15) <> 0) then  {y a-t-il des coups impairs ?}
    BEGIN
		
    {impairs:}
      celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
      celluleDansListeChaineeCasesVides := celluleDepart^.next;
      cellulePrevious := celluleDepart;
      repeat 
        with celluleDansListeChaineeCasesVides^ do
          begin
            celluleNext := next;
            iCourant := square;
            
            if (BAND(vecteurParite,constantePariteDeSquare) <> 0) then
    	        begin
    	          {$IFC DEBUG_BITBOARD_ALPHA_BETA}
    	          EcritBitboardState('dans ABFinBitboardParite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
    	          WritelnStringAndCoupDansRapport('coup impair : ',iCourant);
    	          WritelnDansRapport('');
    	          AttendFrappeClavier;
    	          {$ENDC}
    	          
    	          if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
    	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
    	            else nouvelleParite := vecteurParite;
    	          
    	          if nouvelleParite <> vecteurParite then
    		          BEGIN
    			          
    			          {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			          if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
    			          {$ENDC}
    			          
    			         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
    			          cellulePrevious^.next := celluleNext;
    		            
    		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    		            EndMiniprofilerBitboard(ESProf);
    		            {$ENDC}
    		            
    			          if (profMoins1 = 4) 
    			            then 
    			              begin
    			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      BeginMiniprofilerBitboard(4);
		                      {$ENDC}
		                  
		                    	{$IFC USING_QUATRECASESVIDESBITBOARDFAST}
		                    	noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite);
                          {$ELSEC}
                          noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                          noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                          {$ENDC}
		                      
		                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      EndMiniprofilerBitboard(4);
		                      {$ENDC}
    			              end
    			            else 
    			              begin
    			                if (profMoins1 = 2)
    			                  then 
    			                    begin
    			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
          			                with position do
          			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,false);
          			                {$ELSEC}
          			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
          			                {$ENDC}
    			                    end
    			                  else 
    			                    noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,false);
    			              end;
    			         
    			         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                    BeginMiniprofilerBitboard(ESProf);
                   {$ENDC}
    			              
    			         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
    			          cellulePrevious^.next := celluleDansListeChaineeCasesVides;
    							 							 
    			          if (noteCourante > maxPourBestDefABFinPetite) then 
    			            begin
    			              {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			              if (gOrdreOptimum.nombre_statistiques < 2000000000) then bestmove := iCourant;
    			              {$ENDC}
    			              if (noteCourante >= beta) then 
    	                    begin
    	                      ABFinBitboardParite := noteCourante;
    	                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    			                  EndMiniprofilerBitboard(ESProf);
    		                   {$ENDC}
    		                    exit(ABFinBitboardParite);
    	                    end;
    			              if (noteCourante > alpha) then alpha := noteCourante;
    			              maxPourBestDefABFinPetite := noteCourante;
    			            end;
      			        
    			          diffEssai := diffPions;
    	            END;
    	        end;    
            cellulePrevious := celluleDansListeChaineeCasesVides;
            celluleDansListeChaineeCasesVides := celluleNext;
          end;
      until celluleDansListeChaineeCasesVides = celluleDepart;
      
    END;
  
{pairs:}
  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides := celluleDepart^.next;
  cellulePrevious := celluleDepart;
  repeat 
	  with celluleDansListeChaineeCasesVides^ do
	    begin
	      celluleNext := next;
	      iCourant := square;

	      if (BAND(vecteurParite,constantePariteDeSquare) = 0) then
          begin
            {$IFC DEBUG_BITBOARD_ALPHA_BETA}
	          EcritBitboardState('dans ABFinBitboardParite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
	          WritelnStringAndCoupDansRapport('coup pair : ',iCourant);
	          WritelnDansRapport('');
	          AttendFrappeClavier;
	          {$ENDC}
          
          
            if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
	            else nouvelleParite := vecteurParite;
              
	          if nouvelleParite <> vecteurParite then
		          BEGIN
		            
		            {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		            if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
		            {$ENDC}
			          
			         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
			          cellulePrevious^.next := celluleNext;
		            
		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		            EndMiniprofilerBitboard(ESProf);
		            {$ENDC}
		            
			          if (profMoins1 = 4) 
			            then 
			              begin
			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  BeginMiniprofilerBitboard(4);
		                  {$ENDC}
		            
			                {$IFC USING_QUATRECASESVIDESBITBOARDFAST}
                      noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite);
                      {$ELSEC}
                      noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                      noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                      {$ENDC}
                      
                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  EndMiniprofilerBitboard(4);
		                  {$ENDC}
			              end
			            else 
			              begin
			                if (profMoins1 = 2)
			                  then 
			                    begin
			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
      			                with position do
      			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,false);
      			                {$ELSEC}
      			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
      			                {$ENDC}
			                    end
			                  else 
			                    noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,false);
			              end;
			          
			          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                BeginMiniprofilerBitboard(ESProf);
                {$ENDC}
			              
			         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
			          cellulePrevious^.next := celluleDansListeChaineeCasesVides;
							  
							  
							  if (noteCourante > maxPourBestDefABFinPetite) then 
			            begin
			              {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
			              if (gOrdreOptimum.nombre_statistiques < 2000000000) then bestmove := iCourant;
			              {$ENDC}
			              if (noteCourante >= beta) then 
	                    begin
	                      ABFinBitboardParite := noteCourante;
	                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
			                  EndMiniprofilerBitboard(ESProf);
		                   {$ENDC}
		                    exit(ABFinBitboardParite);
	                    end;
			              if (noteCourante > alpha) then alpha := noteCourante;
			              maxPourBestDefABFinPetite := noteCourante;
			            end;
			            
			          diffEssai := diffPions;
		          END;
		      end;
	      cellulePrevious := celluleDansListeChaineeCasesVides;
        celluleDansListeChaineeCasesVides := celluleNext;
	    end;
	 until celluleDansListeChaineeCasesVides = celluleDepart;

 
{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardParite := maxPourBestDefABFinPetite; 
       {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
       if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.meilleur_coup_dans_cette_case[bestmove]);
       {$ENDC}
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}
           
           if diffPions>0 then 
             begin
               ABFinBitboardParite := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardParite);
             end;
           if diffPions<0 then 
             begin
               ABFinBitboardParite := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
				      exit(ABFinBitboardParite);
             end;
           ABFinBitboardParite := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardParite);
         end          
       else
         begin
           { passe! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}
           
           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardParite := -ABFinBitboardParite(position,ESprof,-beta,-alpha,-diffPions,vecteurParite,true);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardParite }  



{ ABFinBitboardPariteHachage pour les petites profondeurs ( 4 < p <= 7 ).
  On utilise  a) les pions définitifs pour les positions a tres gros score
              b) la table de hachage bitboard
              c) un ordre fixe des cases en jouant la parité.
  
  Attention : position est modifiee par cette routine ! 
  Attention : toujours appeler cette routine avec au moins 5 cases vides, 
              sinon on boucle. ABFinBitboardFastestFirst est une routine 
              plus robuste, qui peut etre utilisee pour 0 <= p <= profForceBrute }
function ABFinBitboardPariteHachage(var position:bitboard;ESprof,alpha,beta,diffPions,vecteurParite : SInt32;vientDePasser : boolean) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    iCourant : SInt32; 
    celluleDansListeChaineeCasesVides:celluleCaseVideDansListeChaineePtr;
    celluleNext,cellulePrevious:celluleCaseVideDansListeChaineePtr;
    celluleDepart:celluleCaseVideDansListeChaineePtr;
    nouvelleParite : SInt32;
    alphaDepart,betaDepart : SInt32;
    hash:BitboardHash;
    hash_table:BitboardHashTable;
    hash_index : UInt32;
		bestmove : SInt32;
    {
    sauvegardePosition:bitboard;
    autreNoteCourante : SInt32;
    }
    
begin

  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  inc(nbreNoeudsGeneresFinale);
  {$ENDC}
  
  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
  if (gOrdreOptimum.nombre_statistiques < 2000000000) then
    begin
      inc(gOrdreOptimum.nombre_statistiques);
      alpha := -64;
      beta  := 64;
    end;
  {$ENDC}
   
  profMoins1 := pred(ESprof);   
  maxPourBestDefABFinPetite := -noteMax;
  bestmove := 0;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai := diffPions;
  alphaDepart := alpha;
  betaDepart  := beta;
  
  
  if (alpha >= stability_alpha[ESProf]) {& (diffPions <= alpha-ESProf)} then
    begin
      { Calculons la note maximale que l'on peut obtenir, 
        connaissant les pions definitifs de l'adversaire }
      noteCourante := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSR(65-alpha,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante <= alpha then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardPariteHachage :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
          WritelnStringAndNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSR(65-alpha,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardPariteHachage := noteCourante;
         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					EndMiniprofilerBitboard(ESProf);
				 {$ENDC}
          exit(ABFinBitboardPariteHachage);
        end;
      if noteCourante < beta then beta := noteCourante;
    end;

  
  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardPariteHachage :',position,ESprof,alpha,beta,diffPions);
  if (ESProf>=3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAND(vecteurParite,constanteDeParite[11])=0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAND(vecteurParite,constanteDeParite[18])=0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAND(vecteurParite,constanteDeParite[81])=0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAND(vecteurParite,constanteDeParite[88])=0);
		end;
  AttendFrappeClavier;
  {$ENDC}


  hash_table := gBitboardHashTable;
  hash := BitboardHashGet(hash_table,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,hash_index);
	if (hash <> NIL) then
	  with hash^ do
  	  begin
  		  if (beta > upper) then
  			  begin
  			    beta := upper;
  			    if (alpha >= beta) then
  			      begin
  			        ABFinBitboardPariteHachage := beta;
  			        exit(ABFinBitboardPariteHachage);
  			      end;
  		    end;
  		  if (alpha < lower) then
  		    begin
  			    alpha := lower;
  			    if (alpha >= beta) then
  			      begin
  			        ABFinBitboardPariteHachage := alpha;
  			        exit(ABFinBitboardPariteHachage);
  			      end;
  			  end;
  		  bestmove := stored_move;
  		end;



  if (BAND(vecteurParite,15) <> 0) then  {y a-t-il des coups impairs ?}
    BEGIN
		
    {impairs:}
      celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
      celluleDansListeChaineeCasesVides := celluleDepart^.next;
      cellulePrevious := celluleDepart;
      repeat 
        with celluleDansListeChaineeCasesVides^ do
          begin
            celluleNext := next;
            iCourant := square;
            
            if (BAND(vecteurParite,constantePariteDeSquare) <> 0) then
    	        begin
    	          {$IFC DEBUG_BITBOARD_ALPHA_BETA}
    	          EcritBitboardState('dans ABFinBitboardPariteHachage :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
    	          WritelnStringAndCoupDansRapport('coup impair : ',iCourant);
    	          WritelnDansRapport('');
    	          AttendFrappeClavier;
    	          {$ENDC}
    	          
    	          if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
    	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
    	            else nouvelleParite := vecteurParite;
    	          
    	          if nouvelleParite <> vecteurParite then
    		          BEGIN
    			          
    			          {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			          if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
    			          {$ENDC}
    			          
    			         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
    			          cellulePrevious^.next := celluleNext;
    		            celluleNext^.previous := cellulePrevious;
    		            
    		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    		            EndMiniprofilerBitboard(ESProf);
    		            {$ENDC}
    		            
    			          if (profMoins1 = 4) 
    			            then 
    			              begin
    			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      BeginMiniprofilerBitboard(4);
		                      {$ENDC}
		                  
		                    	{$IFC USING_QUATRECASESVIDESBITBOARDFAST}
                          noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite);
                          {$ELSEC}
                           noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                           noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                          {$ENDC}
		                      
		                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      EndMiniprofilerBitboard(4);
		                      {$ENDC}
    			              end
    			            else 
    			              begin
    			                if (profMoins1 = 2)
    			                  then 
    			                    begin
    			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
          			                with position do
          			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,false);
          			                {$ELSEC}
          			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
          			                {$ENDC}
    			                    end
    			                  else 
    			                    noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,false);
    			              end;
    			         
    			         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                    BeginMiniprofilerBitboard(ESProf);
                   {$ENDC}
    			              
    			         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
    			          cellulePrevious^.next := celluleDansListeChaineeCasesVides;
    			          celluleNext^.previous := celluleDansListeChaineeCasesVides;
    							 							 
    			          if (noteCourante > maxPourBestDefABFinPetite) then 
    			             begin
    			               bestmove := iCourant;
    			               if (noteCourante > alpha) then 
    			                 begin
    			                   if (noteCourante >= beta) then 
    			                      begin
    			                        ABFinBitboardPariteHachage := noteCourante;
    			                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    					                    EndMiniprofilerBitboard(ESProf);
    				                     {$ENDC}
    				                      BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,noteCourante,bestmove);
    				                      exit(ABFinBitboardPariteHachage);
    			                      end;
    			                   alpha := noteCourante;
    			                 end;
    			               maxPourBestDefABFinPetite := noteCourante;
    			             end;
    			          diffEssai := diffPions;
    	            END;
    	        end;    
            cellulePrevious := celluleDansListeChaineeCasesVides;
            celluleDansListeChaineeCasesVides := celluleNext;
          end;
      until celluleDansListeChaineeCasesVides = celluleDepart;
      
    END;
  
{pairs:}
  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides := celluleDepart^.next;
  cellulePrevious := celluleDepart;
  repeat 
	  with celluleDansListeChaineeCasesVides^ do
	    begin
	      celluleNext := next;
	      iCourant := square;

	      if (BAND(vecteurParite,constantePariteDeSquare) = 0) then
          begin
            {$IFC DEBUG_BITBOARD_ALPHA_BETA}
	          EcritBitboardState('dans ABFinBitboardPariteHachage :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
	          WritelnStringAndCoupDansRapport('coup pair : ',iCourant);
	          WritelnDansRapport('');
	          AttendFrappeClavier;
	          {$ENDC}
          
          
            if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
	            else nouvelleParite := vecteurParite;
              
	          if nouvelleParite <> vecteurParite then
		          BEGIN
		            
		            {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		            if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
		            {$ENDC}
			          
			         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
			          cellulePrevious^.next := celluleNext;
		            celluleNext^.previous := cellulePrevious;
		            
		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		            EndMiniprofilerBitboard(ESProf);
		            {$ENDC}
		            
			          if (profMoins1 = 4) 
			            then 
			              begin
			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  BeginMiniprofilerBitboard(4);
		                  {$ENDC}
		            
			                {$IFC USING_QUATRECASESVIDESBITBOARDFAST}
                      noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite);
                      {$ELSEC}
                      noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                      noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                      {$ENDC}
                      
                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  EndMiniprofilerBitboard(4);
		                  {$ENDC}
			              end
			            else 
			              begin
			                if (profMoins1 = 2)
			                  then 
			                    begin
			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
      			                with position do
      			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,false);
      			                {$ELSEC}
      			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
      			                {$ENDC}
			                    end
			                  else 
			                    noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,false);
			              end;
			          
			          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                BeginMiniprofilerBitboard(ESProf);
                {$ENDC}
			              
			         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
			          cellulePrevious^.next := celluleDansListeChaineeCasesVides;
			          celluleNext^.previous := celluleDansListeChaineeCasesVides;
							  					      
			          if (noteCourante > maxPourBestDefABFinPetite) then 
			            begin
			              bestmove := iCourant;
			              if (noteCourante > alpha) then 
			                begin
			                  if (noteCourante >= beta) then 
			                    begin
			                      ABFinBitboardPariteHachage := noteCourante;
			                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					                  EndMiniprofilerBitboard(ESProf);
				                   {$ENDC}
				                    BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,noteCourante,bestmove);
				                    exit(ABFinBitboardPariteHachage);
			                    end;
			                  alpha := noteCourante;
			                end;
			              maxPourBestDefABFinPetite := noteCourante;
			            end;
			          diffEssai := diffPions;
		          END;
		      end;
	      cellulePrevious := celluleDansListeChaineeCasesVides;
        celluleDansListeChaineeCasesVides := celluleNext;
	    end;
	 until celluleDansListeChaineeCasesVides = celluleDepart;

 
{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardPariteHachage := maxPourBestDefABFinPetite; 
       BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);
       {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
       if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.meilleur_coup_dans_cette_case[bestmove]);
       {$ENDC}
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}
           
           if diffPions>0 then 
             begin
               ABFinBitboardPariteHachage := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardPariteHachage);
             end;
           if diffPions<0 then 
             begin
               ABFinBitboardPariteHachage := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
				      exit(ABFinBitboardPariteHachage);
             end;
           ABFinBitboardPariteHachage := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardPariteHachage);
         end          
       else
         begin
           { passe! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}
           
           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardPariteHachage := -ABFinBitboardPariteHachage(position,ESprof,-beta,-alpha,-diffPions,vecteurParite,true);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardPariteHachage }  



{ ABFinBitboardFastestFirst pour les petites profondeurs ( 7 < prof <= profForceBrute ) 
  On utilise  a) les pions définitifs pour les positions a tres gros score
              b) la table de hachage bitboard
              c) Fastest First pour trier les coups selon la divergence adversaire decroissante.
  Attention : position est modifiee par cette routine ! }
function ABFinBitboardFastestFirst(var position:bitboard;ESprof,alpha,beta,diffPions,vecteurParite : SInt32;vientDePasser : boolean) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    i,iCourant : SInt32; 
    nbCoupsLegaux : SInt32;
    celluleDansListeChaineeCasesVides:celluleCaseVideDansListeChaineePtr;
    celluleNext,cellulePrevious:celluleCaseVideDansListeChaineePtr;
    nouvelleParite : SInt32;
    listeCoupsLegaux:listeVides;
    bestmove : SInt32;
    alphaDepart,betaDepart : SInt32;
    hash:BitboardHash;
    hash_table:BitboardHashTable;
    hash_index : UInt32;
    
begin
  
  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  inc(nbreNoeudsGeneresFinale);
  {$ENDC}
   
  profMoins1 := pred(ESprof);   
  maxPourBestDefABFinPetite := -noteMax;
  bestmove := 0;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai   := diffPions;
  alphaDepart := alpha;
  betaDepart  := beta;
  
  if (alpha >= stability_alpha[ESProf]) {& (diffPions <= alpha-ESProf)} then
    begin
      { Calculons la note maximale que l'on peut obtenir, 
        connaissant les pions definitifs de l'adversaire }
      noteCourante := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSR(65-alpha,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante <= alpha then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardFastestFirst :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
          WritelnStringAndNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSR(65-alpha,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardFastestFirst := noteCourante;
         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					EndMiniprofilerBitboard(ESProf);
				 {$ENDC}
          exit(ABFinBitboardFastestFirst);
        end;
      if noteCourante < beta then beta := succ(noteCourante);
    end;
    
  
  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardFastestFirst :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
  if (ESProf>=3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAND(vecteurParite,constanteDeParite[11])=0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAND(vecteurParite,constanteDeParite[18])=0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAND(vecteurParite,constanteDeParite[81])=0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAND(vecteurParite,constanteDeParite[88])=0);
		end;
  AttendFrappeClavier;
  {$ENDC}
  
  
  hash_table := gBitboardHashTable;
  hash := BitboardHashGet(hash_table,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,hash_index);
	if (hash <> NIL) then
	  with hash^ do
  	  begin
  		  if (beta > upper) then
  			  begin
  			    beta := upper;
  			    if (alpha >= beta) then
  			      begin
  			        ABFinBitboardFastestFirst := beta;
  			        exit(ABFinBitboardFastestFirst);
  			      end;
  		    end;
  		  if (alpha < lower) then
  		    begin
  			    alpha := lower;
  			    if (alpha >= beta) then
  			      begin
  			        ABFinBitboardFastestFirst := alpha;
  			        exit(ABFinBitboardFastestFirst);
  			      end;
  			  end;
  		  bestmove := stored_move;
  		end;
  		
  nbCoupsLegaux := TrierFastestFirstBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,listeCoupsLegaux,bestmove);

  for i := 1 to nbCoupsLegaux do
    begin
    
      iCourant := listeCoupsLegaux[i];
      
      nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai);
      
	    if nouvelleParite <> vecteurParite
        then
          BEGIN
	          
	          {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
	          celluleDansListeChaineeCasesVides := gTableDesPointeurs[iCourant];
	          with celluleDansListeChaineeCasesVides^ do
	            begin
	              celluleNext := next;
	              cellulePrevious := previous;
	              cellulePrevious^.next := celluleNext;
			          celluleNext^.previous := cellulePrevious;
			          
			          {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
                 tempoNbNoeudsDansABFinPetite[profMoins1] := nbreNoeudsGeneresFinale;
                {$ENDC}
                
                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                EndMiniprofilerBitboard(ESProf);
                {$ENDC}
                
			          if (i = 1) & (profMoins1 = 8)
                  then 
                    noteCourante := -ABFinBitboardPariteHachage(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,false)
                  else
                    if (profMoins1 = 7)
            				  then noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,false)
            				  else noteCourante := -ABFinBitboardFastestFirst(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,false);
			              
			          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                BeginMiniprofilerBitboard(ESProf);
                {$ENDC}
			          
			          {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
			          if (nbreNoeudsGeneresFinale > tempoNbNoeudsDansABFinPetite[profMoins1]) then {pas de gag d'overflow!}
			            begin
			              inc(nbAppelsABFinPetite[profMoins1]);
		                tempoNbNoeudsDansABFinPetite[profMoins1] := nbreNoeudsGeneresFinale - tempoNbNoeudsDansABFinPetite[profMoins1];
		                nbNoeudsDansABFinPetite[profMoins1] := nbNoeudsDansABFinPetite[profMoins1] + tempoNbNoeudsDansABFinPetite[profMoins1];
		              end;
		            {$ENDC}
			          
			          {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
			          cellulePrevious^.next := celluleDansListeChaineeCasesVides;
							  celluleNext^.previous := celluleDansListeChaineeCasesVides;
							end;
					 					 
	          if (noteCourante>maxPourBestDefABFinPetite) then 
	             begin
	               maxPourBestDefABFinPetite := noteCourante;
	               bestmove                  := iCourant;
	               
	               if (noteCourante > alpha) then 
	                 begin
	                   alpha := noteCourante;
	                   if (alpha >= beta) then 
	                      begin
	                        ABFinBitboardFastestFirst := maxPourBestDefABFinPetite;
	                        BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);
	                        
	                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					                EndMiniprofilerBitboard(ESProf);
				                 {$ENDC}
	                        exit(ABFinBitboardFastestFirst);
	                      end;
	                 end;
	             end;
	          diffEssai := diffPions;
          END;
    end;
 
{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardFastestFirst := maxPourBestDefABFinPetite; 
       BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}
           
           if diffPions>0 then 
             begin
               ABFinBitboardFastestFirst := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardFastestFirst);
             end;
           if diffPions<0 then 
             begin
               ABFinBitboardFastestFirst := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardFastestFirst);
             end;
           ABFinBitboardFastestFirst := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardFastestFirst);
         end          
       else
         begin
           { passe! }
           
           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}
           
           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardFastestFirst := -ABFinBitboardFastestFirst(position,ESprof,-beta,-alpha,-diffPions,vecteurParite,true);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardFastestFirst }  




function LanceurBitboardAlphaBeta(var plat:plOthEndgame;couleur,ESprof,alpha,beta,diffPions : SInt32) : SInt32;
var note,adversaire,square,i,j,myBitsLow,myBitsHigh,oppBitsLow,oppBitsHigh : UInt32;
    position  : bitboard;
begin  
  
  
  {transforme un plateauOthello en bitboard}
	myBitsLow := 0;
	myBitsHigh := 0;
	oppBitsLow := 0;
	oppBitsHigh := 0;
	adversaire := -couleur;
	
	for j := 1 to 4 do
	  for i := 1 to 8 do
	    begin
	      square := j*10 + i;
	      if plat[square] = couleur then myBitsLow := BOR(myBitsLow,othellierBitboardDescr[square].constanteHexa)  else
	      if plat[square] = adversaire then oppBitsLow := BOR(oppBitsLow,othellierBitboardDescr[square].constanteHexa)
	    end;
	for j := 5 to 8 do
	  for i := 1 to 8 do
	    begin
	      square := j*10 + i;
	      if plat[square] = couleur then myBitsHigh := BOR(myBitsHigh,othellierBitboardDescr[square].constanteHexa)  else
	      if plat[square] = adversaire then oppBitsHigh := BOR(oppBitsHigh,othellierBitboardDescr[square].constanteHexa)
	    end;
	
	with position do
	  begin
	    g_my_bits_low := myBitsLow;
	    g_my_bits_high := myBitsHigh;
	    g_opp_bits_low := oppBitsLow;
	    g_opp_bits_high := oppBitsHigh;
	  end;
  
  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  WritelnDansRapport('plateau recu en parametre dans LanceurBitboardAlphaBeta: ');
  WritelnPositionEtTraitDansRapport(plat,couleur);
  WritelnStringAndNumDansRapport('diffPions=',diffPions);
  EcritBitboardState('dans LanceurBitboardAlphaBeta : ',position,ESprof,alpha,beta,diffPions);
  EcritTriFastestFirstBitboardDansRapport(position);
  AttendFrappeClavier;  
  {$ENDC}
  
  (*
  WritelnDansRapport('plateau recu en parametre dans LanceurBitboardAlphaBeta: ');
  WritelnPositionEtTraitDansRapport(plat,couleur);
  EcritTriFastestFirstBitboardDansRapport(position);
  AttendFrappeClavier;  
  *)
  
  {$IFC UTILISE_MINIPROFILER_POUR_LANCEUR_BITBOARD}
  BeginMiniprofilerBitboard(ESProf);
  {$ENDC}
  
  note := ABFinBitboardFastestFirst(position,ESProf,alpha,beta,diffPions,gVecteurParite,false);
  {note := ABFinBitboardParite(position,ESProf,alpha,beta,diffPions,gVecteurParite,false);}
  
  {$IFC UTILISE_MINIPROFILER_POUR_LANCEUR_BITBOARD}
  EndMiniprofilerBitboard(ESProf);
  {$ENDC}
  
  LanceurBitboardAlphaBeta := note;
  
  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  WritelnStringAndNumDansRapport('  ==>  note=',note);
  EcritBitboardState('à la fin de LanceurBitboardAlphaBeta : ',position,ESProf,alpha,beta,diffPions);
  AttendFrappeClavier;
  {$ENDC}
		  
end;


function PeutFaireFinaleBitboardCettePosition(var plat : plateauOthello;couleur,alphaMilieu,betaMilieu,nbNoirs,nbBlancs : SInt32; var note : SInt32) : boolean;
var alphaFinale,betaFinale : SInt32;
begin  
  
  if ListeChaineeDesCasesVidesEstDisponible() 
    then
      begin
        CreeListeCasesVidesDeCettePosition(plat,true);
		    CreerListeChaineeDesCasesVides(gNbreVides_entreeCoupGagnant,
		                                   gTeteListeChaineeCasesVides,
		                                   gBufferCellulesListeChainee,
		                                   gTableDesPointeurs,
		                                   'PeutFaireFinaleBitboardCettePosition');
        SetListeChaineeDesCasesVidesEstDisponible(false);
          
          
        (* on transforme les bornes de milieu en bornes de finale *)
        if alphaMilieu < 0 then alphaMilieu := alphaMilieu - 99;
        if betaMilieu  < 0 then betaMilieu  := betaMilieu  - 99;
        alphaFinale := alphaMilieu div 100;
        betaFinale  := (betaMilieu + 99) div 100;
        
        
        if (alphaFinale >  64) then alphaFinale :=  64;
        if (alphaFinale < -64) then alphaFinale := -64;
        if (betaFinale  >  64) then betaFinale  :=  64;
        if (betaFinale  < -64) then betaFinale  := -64;
        
        if (alphaFinale = -64) & (betaFinale = -64) then betaFinale  := -63;
        if (alphaFinale =  64) & (betaFinale =  64) then alphaFinale :=  63;
        
        if (alphaFinale > 64) | (alphaFinale < -64) | (alphaFinale > 64) | (alphaFinale < -64) then
          begin
            SysBeep(0);
            WritelnDansRapport('ASSERT : alphaFinale ou betaFinale est out of range dans PeutFaireFinaleBitboardCettePosition');
            WritelnPositionEtTraitDansRapport(plat,couleur);
            WritelnStringAndNumDansRapport('alphaFinale = ',alphaFinale);
            WritelnStringAndNumDansRapport('betaFinale  = ',betaFinale);
            WritelnStringAndNumDansRapport('alphaMilieu = ',alphaMilieu);
            WritelnStringAndNumDansRapport('betaMilieu =  ',betaMilieu);
            WritelnStringAndNumDansRapport('nbNoirs =  ',nbNoirs);
            WritelnStringAndNumDansRapport('nbBlancs =  ',nbBlancs);
            WritelnDansRapport('tapez une touche…');
            WritelnDansRapport('');
            AttendFrappeClavier;
          end;
        
        (*
        WritelnDansRapport('plateau recu en parametre dans PeutFaireFinaleBitboardCettePosition : ');
        WritelnPositionEtTraitDansRapport(plat,couleur);
        WritelnStringAndNumDansRapport('gNbreVides_entreeCoupGagnant = ',gNbreVides_entreeCoupGagnant);
        WritelnStringAndNumDansRapport('alphaFinale = ',alphaFinale);
        WritelnStringAndNumDansRapport('betaFinale  = ',betaFinale);
        WritelnStringAndNumDansRapport('alphaMilieu = ',alphaMilieu);
        WritelnStringAndNumDansRapport('betaMilieu =  ',betaMilieu);
        WritelnDansRapport('tapez une touche…');
        WritelnDansRapport('');
        AttendFrappeClavier;
        *)
            
        if alphaFinale >= betaFinale then
          begin
            SysBeep(0);
            WritelnDansRapport('ASSERT : alphaFinale >= betaFinale dans PeutFaireFinaleBitboardCettePosition');
            WritelnPositionEtTraitDansRapport(plat,couleur);
            WritelnStringAndNumDansRapport('alphaFinale = ',alphaFinale);
            WritelnStringAndNumDansRapport('betaFinale  = ',betaFinale);
            WritelnStringAndNumDansRapport('alphaMilieu = ',alphaMilieu);
            WritelnStringAndNumDansRapport('betaMilieu =  ',betaMilieu);
          end;
        
        
        
        
        if couleur = pionNoir
          then note := LanceurBitboardAlphaBeta(plat,couleur,gNbreVides_entreeCoupGagnant,alphaFinale,betaFinale,nbNoirs-nbBlancs)
          else note := LanceurBitboardAlphaBeta(plat,couleur,gNbreVides_entreeCoupGagnant,alphaFinale,betaFinale,nbBlancs-nbNoirs);
        
        
        (* on transforme inversement la note de finale en note de milieu *)
        note := 100*note;
        
        if (note < -6400) | (note > 6400) then
          begin
            SysBeep(0);
            WritelnDansRapport('ASSERT : (note < -6400) | (note > 6400) dans PeutFaireFinaleBitboardCettePosition');
            WritelnPositionEtTraitDansRapport(plat,couleur);
            WritelnStringAndNumDansRapport('note = ',note);
            WritelnStringAndNumDansRapport('alphaFinale = ',alphaFinale);
            WritelnStringAndNumDansRapport('betaFinale  = ',betaFinale);
            WritelnStringAndNumDansRapport('alphaMilieu = ',alphaMilieu);
            WritelnStringAndNumDansRapport('betaMilieu =  ',betaMilieu);
            WritelnDansRapport('tapez une touche…');
            WritelnDansRapport('');
            AttendFrappeClavier;
          end;
        
        SetListeChaineeDesCasesVidesEstDisponible(true);
        
        PeutFaireFinaleBitboardCettePosition := true;
      end
    else
      begin
        SysBeep(0);
        WritelnDansRapport('ASSERT : liste chainee non disponible dans PeutFaireFinaleBitboardCettePosition');
        
        PeutFaireFinaleBitboardCettePosition := false;
      end;
		  
end;

{$ENDC}



{$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}

procedure ResetStatistiquesOrdreOptimumDesCases;
var i : SInt32;
begin
  with gOrdreOptimum do
    begin
      nombre_statistiques := 0;
      for i := 0 to 99 do
        meilleur_coup_dans_cette_case[i] := 0;
      for i := 0 to 99 do
        ce_coup_est_legal[i] := 0;
    end;
end;

procedure EcritStatistiquesOrdreOptimumDesCasesDansRapport;
var i,n,p,square : SInt32;
begin
  WritelnDansRapport('Statistiques pour déterminer l''ordre optimum des cases : ');
  with gOrdreOptimum do
    begin
      WritelnStringAndNumDansRapport('nombre_statistiques = ',nombre_statistiques);
      if (nombre_statistiques <> 0) then
        for i := 64 downto 1 do
          begin
            square := worst2bestOrder[i];
            
            if (ce_coup_est_legal[square] <> 0)
              then
                begin
                  WriteCoupDansRapport(square);
                  
                  {nombre de fois où le meilleur coup a ete "square"}
                  n := meilleur_coup_dans_cette_case[square];
                  WriteStringAndNumEnSeparantLesMilliersDansRapport(', best = ',n);
                  
                  {nombre de fois où "square" a ete legal}
                  p := ce_coup_est_legal[square];
                  WriteStringAndNumEnSeparantLesMilliersDansRapport(', legal = ',p);
                  
                  {rapport entre les deux}
                  if (p <> 0) 
                    then WritelnStringAndReelDansRapport(', % =', 100.0*n/p,4)
                    else WritelnDansRapport('');
                end;
          end;
    end;
end;

{$ENDC}


END.


(*
nombre_statistiques = 1976212046
H8, best = 127 339 615, legal = 284 999 846, % =44.68
A8, best = 107 615 771, legal = 245 756 404, % =43.78
H1, best = 146 244 136, legal = 335 222 974, % =43.62
A1, best = 151 886 797, legal = 347 701 248, % =43.68

F8, best = 31 519 640, legal = 110 319 449, % =28.57
C8, best = 27 172 577, legal = 99 398 649, % =27.33
H6, best = 36 639 923, legal = 129 968 443, % =28.19
A6, best = 39 938 217, legal = 152 450 245, % =26.19
H3, best = 37 798 831, legal = 143 025 326, % =26.42
A3, best = 31 861 533, legal = 118 444 179, % =26.90
F1, best = 23 401 325, legal = 76 314 757, % =30.66
C1, best = 15 865 410, legal = 58 526 030, % =27.10

F6, best = 1 201 012, legal = 3 300 915, % =36.38
F3, best = 40 918, legal = 115 406, % =35.45

E8, best = 16 134 663, legal = 59 333 732, % =27.19
D8, best = 25 090 125, legal = 86 838 141, % =28.89
H5, best = 36 819 423, legal = 126 169 747, % =29.18
A5, best = 45 621 993, legal = 160 570 752, % =28.41
H4, best = 38 306 028, legal = 139 110 517, % =27.53
A4, best = 43 038 108, legal = 151 414 868, % =28.42
E1, best = 12 392 907, legal = 42 614 738, % =29.08
D1, best = 12 175 672, legal = 43 083 595, % =28.26

E6, best = 248 823, legal = 497 364, % =50.02
F4, best = 722 934, legal = 1 680 795, % =43.01

E7, best = 3 514 882, legal = 14 087 895, % =24.94
D7, best = 10 067 082, legal = 33 113 734, % =30.40
G5, best = 7 655 764, legal = 28 728 264, % =26.64
B5, best = 5 760 729, legal = 21 362 971, % =26.96
G4, best = 10 034 775, legal = 37 919 616, % =26.46
B4, best = 15 054 657, legal = 56 954 481, % =26.43
E2, best = 1 231 042, legal = 3 237 873, % =38.02
D2, best = 12 664 936, legal = 42 322 608, % =29.92

F7, best = 7 415 603, legal = 28 605 687, % =25.92
C7, best = 5 750 344, legal = 25 797 871, % =22.28
G6, best = 8 534 313, legal = 38 251 867, % =22.31
B6, best = 9 659 848, legal = 41 745 433, % =23.13
G3, best = 13 174 995, legal = 58 644 271, % =22.46
F2, best = 6 799 031, legal = 27 495 257, % =24.72
C2, best = 22 661 165, legal = 92 169 209, % =24.58

G8, best = 85 450 688, legal = 317 577 519, % =26.90
B8, best = 54 483 603, legal = 231 300 969, % =23.55
H7, best = 59 026 953, legal = 232 089 622, % =25.43
A7, best = 76 360 863, legal = 306 183 127, % =24.93
H2, best = 98 481 475, legal = 408 397 189, % =24.11
A2, best = 56 489 086, legal = 253 995 379, % =22.24
G1, best = 81 104 004, legal = 341 934 205, % =23.71
B1, best = 86 099 010, legal = 330 229 754, % =26.07

G7, best = 66 907 961, legal = 327 578 011, % =20.42
B7, best = 30 950 445, legal = 156 959 670, % =19.71
G2, best = 44 553 249, legal = 228 091 037, % =19.53
B2, best = 53 150 234, legal = 244 325 817, % =21.75
*)