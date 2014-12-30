UNIT UnitFinaleFast;


{$DEFINEC USE_PROFILER_FINALE_FAST   FALSE}


{$DEFINEC USE_DEBUG_HASH_VALUES    FALSE}

INTERFACE







USES 
{$IFC USE_PROFILER_FINALE_FAST}
     Profiler,
{$ENDC}
   UnitOth0;
  
     

function CoupGagnant(var meilleurX,bstdef : SInt32;couleurFinale,MFprof,nbBl,nbNo : SInt32;gameTreeNode : GameTree;
                     var jeu : plateauOthello; var empl : plBool; var frontiereFinale : InfoFrontRec;
                     MessageHandle:MessageFinaleHdl; var meilleurScore : SInt32;
                     commentaireDansRapport,doitAbsolumentRamenerLaSuite : boolean;
                     typeCalculFinale : SInt32) : boolean;

                      
                                       
                                       
type  AmeliorationsAlphaRec = 
            record
              cardinal : SInt32;
              liste : array[1..64] of 
                      record
                        coup : SInt32;
                        val : SInt32;
                        alphaAvant : SInt32;
                      end;
				    end;


IMPLEMENTATION







USES UnitActions,UnitSuperviseur,UnitEvaluation,Unit_AB_simple,UnitEndgameTree,UnitHashTableExacte,UnitStringSet,
     UnitPositionEtTraitSet,UnitNotesSurCases,UnitRapportImplementation,UnitUtilitaires,UnitAffichageReflexion,
     UnitScannerOthellistique,UnitArbreDeJeuCourant,UnitAfficheArbreDeJeuCourant,UnitServicesDialogs,UnitMoveRecords,UnitStrategie,
     UnitSearchValues,UnitBitboardHash,UnitMiniProfiler,UnitOth2,UnitJaponais,UnitRapport,UnitUtilitairesFinale,
     UnitListeChaineeCasesVides,UnitTore,UnitRegressionLineaire,UnitPhasesPartie,UnitSuperviseur,UnitOth1,SNStrings,
     UnitBitboardAlphaBeta,UnitBitboardFlips,UnitHashTableExacte,MyStrings,UnitGestionDuTemps,UnitBitboardHash,
     UnitCourbe,UnitFenetres,UnitScripts,UnitGeneralSort;



CONST kNbCasesVidesPourAnnonceDansRapport = 10;

      kPropagationMinimax     = 1;
      kPropagationProofNumber = 2;


{$IFC USE_DEBUG_HASH_VALUES}
var positionsDejaAffichees:PositionEtTraitSet;
    hashStockeeDansSet : SInt32;
{$ENDC}
  

procedure CopyEnPlOthEndgame(var source : plateauOthello; var dest:plOthEndgame);
var i : SInt32;
begin
  for i := 0 to 99 do
    dest[i] := source[i];
end;



function ModifPlatFinDiffFastLongint(a,couleur,couleurEnnemie : SInt32; var jeu:plOthEndgame; var diffPions : SInt32) : boolean;
var x1,x2,x3,x4,x5,x6,dx,t,nbprise : SInt32;
begin
   nbprise := 0;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x1 := a+dx;
       if jeu[x1]=couleurEnnemie then {1}
         begin
           x2 := x1+dx;
           if jeu[x2]=couleurEnnemie then  {2}
           begin
             x3 := x2+dx;
             if jeu[x3]=couleurEnnemie then  {3}
		           begin
		             x4 := x3+dx;
		             if jeu[x4]=couleurEnnemie then  {4}
				           begin
				             x5 := x4+dx;
				             if jeu[x5]=couleurEnnemie then  {5}
						           begin
						             x6 := x5+dx;
						             if jeu[x6]=couleurEnnemie then  {6}
								           begin
								             if jeu[x6+dx]=couleur then  {seul cas à tester}
									             begin
									               nbprise := nbprise+12;
									               Jeu[x6] := couleur;
									               Jeu[x5] := couleur;
									               Jeu[x4] := couleur;
									               Jeu[x3] := couleur;
									               Jeu[x2] := couleur;
									               Jeu[x1] := couleur;
									             end;
								           end
								           else
								           if jeu[x6]=couleur then
								             begin
								               nbprise := nbprise+10;
								               Jeu[x5] := couleur;
								               Jeu[x4] := couleur;
								               Jeu[x3] := couleur;
								               Jeu[x2] := couleur;
								               Jeu[x1] := couleur;
								             end;
						           end
						           else
						           if jeu[x5]=couleur then
						             begin
						               nbprise := nbprise+8;
						               Jeu[x4] := couleur;
						               Jeu[x3] := couleur;
						               Jeu[x2] := couleur;
						               Jeu[x1] := couleur;
						             end;
				           end
                   else
				           if jeu[x4]=couleur then
				             begin
				               nbprise := nbprise+6;
				               Jeu[x3] := couleur;
				               Jeu[x2] := couleur;
				               Jeu[x1] := couleur;
				             end;
		           end
		           else
		           if jeu[x3]=couleur then
		             begin
		               nbprise := nbprise+4;
		               Jeu[x2] := couleur;
		               Jeu[x1] := couleur;
		             end;
           end
           else
           if jeu[x2]=couleur then
             begin
               nbprise := nbprise+2;
               Jeu[x1] := couleur;
             end;
        end;
     end; 
   if (nbprise>0) 
     then
	     begin
	       diffPions := succ(diffPions+nbprise);
	       jeu[a] := couleur;
	       ModifPlatFinDiffFastLongint := true;
	     end
	   else
	     ModifPlatFinDiffFastLongint := false;
end;




function ModifPlatFinLongint(a,coul : SInt32; var jeu : plateauOthello; var nbbl,nbno : SInt32) : boolean;
var x,dx,i,t,nbprise : SInt32;
    pionEnnemi,compteur : SInt32;
    modifie : boolean;
begin
   modifie := false;nbprise := 0;
   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x := a+dx;
       if jeu[x]=pionennemi then
         begin
           compteur := 0;
           repeat
             inc(compteur);
             x := x+dx;         
           until jeu[x]<>pionennemi;
           if (jeu[x]=coul)then
             begin
               modifie := true; 
               for i := 1 to compteur do
                 begin
                  x := x-dx;
                  Jeu[x] := coul; 
                 end; 
               nbprise := nbprise+compteur;
             end;
        end;
     end; 
   if modifie then
     begin
       if coul = pionNoir 
         then begin
             nbNo := succ(nbNo+nbprise);
             nbbl := nbbl-nbprise;
           end
         else begin
             nbNo := nbNo-nbprise;
             nbbl := succ(nbbl+nbprise);
           end;
       jeu[a] := coul;
     end;
   ModifPlatFinLongint := modifie;
end;




function EtablitListeCasesVidesParOrdreJCW(var plat : plateauOthello;ESprof : SInt32; var listeCasesVides:listeVides) : SInt32;
var nbVidesTrouvees,i,caseTestee : SInt32;
begin
  nbVidesTrouvees := 0;
  i := 0;
  repeat
    inc(i);
    caseTestee := gCasesVides_entreeCoupGagnant[i];   
    if plat[caseTestee] = pionVide then  
      begin 
        inc(nbVidesTrouvees);
        listeCasesVides[nbVidesTrouvees] := caseTestee;
      end;
  until nbVidesTrouvees>=ESprof;
  EtablitListeCasesVidesParOrdreJCW := nbVidesTrouvees;
end;


 

function CoupGagnant(var meilleurX,bstdef : SInt32;couleurFinale,MFprof,nbBl,nbNo : SInt32;gameTreeNode : GameTree;
                     var jeu : plateauOthello; var empl : plBool; var frontiereFinale : InfoFrontRec;
                     MessageHandle:MessageFinaleHdl; var meilleurScore : SInt32;
                     commentaireDansRapport,doitAbsolumentRamenerLaSuite : boolean;
                     typeCalculFinale : SInt32) : boolean;


var 
    CoulPourMeilleurFin,coulDefense : SInt32;
    positionEtTraitDeCoupGagnant : PositionEtTraitRec;
    maxPourOrdonnancement : SInt32;
    classement : ListOfMoveRecords;
    valeurCible : SInt32;
    i,nbCoup : SInt32;
    infini : SInt32;
    defense : SInt32;
    MFniv : SInt32;
    endgameNode : GameTree;
    numeroEndgameTreeActif : SInt32;
    magicCookieEndgameTree : SInt32;
    clefHashageCoupGagnant : SInt32;
    dernierCoupJoue : SInt32;
    platClass : plateauOthello;
    jouableClass : plBool;
    nbBlancClass,nbNoirClass : SInt32;
    frontClass : InfoFrontRec;
    noteClass : SInt32;
    suiteJouee:t_suiteJouee;
    meilleureSuite : t_meilleureSuite;
    typeDataDansHandle : SInt32;
    scoreDeNoir : SInt32;
    noCoupRecherche : SInt32;
    tempsGlobalDeLaFonction : SInt32;
    coupDontLeScoreEstConnu : SInt32;
    scoreDuCoupDontLeScoreEstConnu : SInt32;
    defenseDuCoupDontLeScoreEstConnu : SInt32;
    profForceBrute : SInt32;
    profForceBrutePlusUn : SInt32;
    profPourTriSelonDivergence : SInt32;
    profondeurDepartPreordre,profondeurArretPreordre : SInt32;
    indexDuCoupDansFntrReflexion : SInt32;
    TickChrono : SInt32;
    InfosPourcentagesCertitudesAffiches:
      array[0..3] of record
                       mobiliteCetteProf : SInt32;
                       indexDuCoupCetteProf : SInt32;
                       PourcentageAfficheCetteProf : SInt32;
                     end;
    estimationPositionDApresMilieu : SInt32;
    mob : SInt32;
    move : plBool;
    bestMode : boolean;
    termine : boolean;
    passeDeRechercheAuMoinsValeurCible : boolean;
    FenetreLargePourRechercheScoreExact : boolean;
    resultatSansCalcul : boolean;
    bestmodeArriveeDansCoupGagnant : boolean;
    chainesDejaEcrites : StringSet;
    rechercheDejaAnnonceeDansRapport : boolean;
    coupGagnantUtiliseEndgameTrees : boolean;
    listeChaineeEstDisponibleArrivee : boolean;
    tempoUserCoeffDansNouvelleEval : boolean;
    dernierePasseTerminee : boolean;
    CassioEtaitEnTrainDeReflechir : boolean;
    passeEhancedTranspositionCutOffEstEnCours : boolean;
    
    
{$IFC USE_PROFILER_FINALE_FAST}
    nomFichierProfile : str255;
{$ENDC}






function DoitPasserFin(couleur : SInt32; var plat : plateauOthello) : boolean;
var a,x,dx,t,adversaire,n : SInt32;
begin
  adversaire := -couleur;
  for n := 1 to gNbreVides_entreeCoupGagnant do
    begin
      a := gCasesVides_entreeCoupGagnant[n];
      if plat[a] = pionVide then
        for t := dirPriseDeb[a] to dirPriseFin[a] do
          begin
            dx := dirPrise[t];
            x := a+dx;
            if plat[x]=adversaire then
              begin
                repeat
                  x := x+dx;
                until plat[x]<>adversaire;
                if (plat[x]=couleur) then
                  begin
                    DoitPasserFin := false;
                    exit(DoitPasserFin)
                  end;
              end;
          end;
    end;
  DoitPasserFin := true;
end; 


function DernierCoup(var plat:plOthEndgame;couleur,couleurEnnemie,diffPions : SInt32) : SInt32;
var t,dx,x1,x2,x3,x4,x5,x6,nbprise,iCourant : SInt32;
begin
  inc(nbreNoeudsGeneresFinale); 
	iCourant := gTeteListeChaineeCasesVides.next^.square;
	if plat[iCourant] = pionVide then   
	  begin  
	    nbprise := 0;
	    for t := dirPriseDeb[iCourant] to dirPriseFin[iCourant] do
	      begin
	        dx := dirPrise[t];
	        {on calcule les retournements suivant cette direction}
	        x1 := iCourant+dx;
					if plat[x1]=couleurEnnemie then {1}
					  begin
					    x2 := x1+dx;
					    if plat[x2]=couleurEnnemie then  {2}
					      begin
					        x3 := x2+dx;
					        if plat[x3]=couleurEnnemie then  {3}
					          begin
					            x4 := x3+dx;
					            if plat[x4]=couleurEnnemie then  {4}
						            begin
						              x5 := x4+dx;
						              if plat[x5]=couleurEnnemie then  {5}
								            begin
								              x6 := x5+dx;
								              if plat[x6]=couleurEnnemie then  {6}
										            begin
										              {seul cas à tester}
										              if plat[x6+dx]=couleur then nbprise := nbprise+12;
										            end
										          else
										            if plat[x6]=couleur then nbprise := nbprise+10;
								            end
								          else
								            if plat[x5]=couleur then nbprise := nbprise+8;
						            end
					            else
						            if plat[x4]=couleur then nbprise := nbprise+6;
					          end
					        else
					          if plat[x3]=couleur then nbprise := nbprise+4;
					      end
					    else
					      if plat[x2]=couleur then nbprise := nbprise+2;
					  end;
	      end;

	   if (nbprise>0)
	     then
	       begin
	         DernierCoup := succ(diffPions+nbprise);
	         exit(DernierCoup);      
	       end
	     else
	       begin
	        {nbprise := 0;} {deja Initialise ci-dessus}
	        for t := dirPriseDeb[iCourant] to dirPriseFin[iCourant] do
	          begin
	            dx := dirPrise[t];
	            {on calcule les retournements suivant cette direction}
	            x1 := iCourant+dx;
	            if plat[x1]=couleur then {1}
	              begin
	                x2 := x1+dx;
	                if plat[x2]=couleur then  {2}
	                  begin
	                    x3 := x2+dx;
	                    if plat[x3]=couleur then  {3}
			                  begin
			                    x4 := x3+dx;
			                    if plat[x4]=couleur then  {4}
					                  begin
					                    x5 := x4+dx;
					                    if plat[x5]=couleur then  {5}
							                  begin
							                    x6 := x5+dx;
							                    if plat[x6]=couleur then  {6}
						                        begin
								                      {seul cas à tester}
								                      if plat[x6+dx]=couleurEnnemie then nbprise := nbprise+12;
					                          end
									                else
									                  if plat[x6]=couleurEnnemie then nbprise := nbprise+10;
							                  end
							                else
							                  if plat[x5]=couleurEnnemie then nbprise := nbprise+8;
					                  end
	                        else
					                  if plat[x4]=couleurEnnemie then nbprise := nbprise+6;
			                  end
			                else
			                  if plat[x3]=couleurEnnemie then nbprise := nbprise+4;
	                  end
	                else
	                  if plat[x2]=couleurEnnemie then nbprise := nbprise+2;
	              end;
	          end; 
	      
	      if (nbPrise>0) 
	        then
	          begin
	            DernierCoup := pred(diffPions-nbprise);
	            exit(DernierCoup);      
	          end
	        else
	          begin
	            if diffPions>0 then 
	              begin
	                DernierCoup := succ(diffPions);  {une case vide au vainqueur}
	                exit(DernierCoup);
	              end;
	            if diffPions<0 then 
	              begin
	                DernierCoup := pred(diffPions);  {une case vide au vainqueur}
	                exit(DernierCoup);
	              end; 
	            DernierCoup := 0;             {nulle}
	            exit(DernierCoup);
	          end;
	     end
	  end;
  DernierCoup := diffPions;  {pas de case vide}
end;   { DernierCoup }


{ABFinPetite pour les petites profondeurs ( <= profForceBrute )}
function ABFinPetite(var plat:plOthEndgame;couleur,ESprof,alpha,beta,diffPions : SInt32;vientDePasser : boolean) : SInt32;
var platEssai:plOthEndgame;
    DiffEssai : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    aJoue : boolean; 
    iCourant,constanteDePariteDeiCourant : SInt32; 
    celluleDansListeChaineeCasesVides:celluleCaseVideDansListeChaineePtr;
    celluleDepart:celluleCaseVideDansListeChaineePtr;  

begin
  inc(nbreNoeudsGeneresFinale);
   
  adversaire := -couleur;
  profMoins1 := pred(ESprof);   
  maxPourBestDefABFinPetite := -noteMax;
  aJoue := false; 
  platEssai := plat;
  DiffEssai := diffPions;
  
  (*
  if (ESprof>=3) then
    begin
		  WritelnDansRapport('');
		  WritelnPositionEtTraitDansRapport(plat,couleur);
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAND(gVecteurParite,constanteDeParite[11])=0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAND(gVecteurParite,constanteDeParite[18])=0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAND(gVecteurParite,constanteDeParite[81])=0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAND(gVecteurParite,constanteDeParite[88])=0);
		  AttendFrappeClavier;
		end;
  *)
		
{impairs:}
  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides := celluleDepart^.next;
  repeat 
    with celluleDansListeChaineeCasesVides^ do
      begin
        iCourant := square;
        constanteDePariteDeiCourant := constantePariteDeSquare;

        if (ESprof<3) | (BAND(gVecteurParite,constanteDePariteDeiCourant) <> 0) then
  
  
        if ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platEssai,diffEssai) 
          then
	          BEGIN
		          aJoue := true;
		          
		          if (ESprof>=3) then
		            gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
		          
		         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
		          previous^.next := next;
		          next^.previous := previous;
		          if (profMoins1=1) 
		            then noteCourante := -DernierCoup(platEssai,adversaire,couleur,-diffEssai)
		            else noteCourante := -ABFinPetite(platEssai,adversaire,profMoins1,-beta,-alpha,-diffEssai,false);
		         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
		          previous^.next := celluleDansListeChaineeCasesVides;
						  next^.previous := celluleDansListeChaineeCasesVides;
						 
						 if (ESprof>=3) then
		            gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
						 
		          if (noteCourante>maxPourBestDefABFinPetite) then 
		             begin
		               maxPourBestDefABFinPetite := noteCourante;
		               if (noteCourante>alpha) then 
		                 begin
		                   alpha := noteCourante;
		                   if (alpha>=beta) then 
		                      begin
		                        ABFinPetite := maxPourBestDefABFinPetite;
		                        exit(ABFinPetite);
		                      end;
		                 end;
		             end;
						  platEssai := plat;
		          diffEssai := diffPions;
            END;
        celluleDansListeChaineeCasesVides := next;
      end;
  until celluleDansListeChaineeCasesVides = celluleDepart;
  
{pairs:}
if (ESprof>=3) then
  begin
  
  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides := celluleDepart^.next;
  repeat 
    with celluleDansListeChaineeCasesVides^ do
      begin
        iCourant := square;
        constanteDePariteDeiCourant := constantePariteDeSquare;
  
        if BAND(gVecteurParite,constanteDePariteDeiCourant)=0 then
  
        if ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platEssai,diffEssai) 
          then
	          BEGIN
		          aJoue := true;
		          
		          gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
		         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
		          previous^.next := next;
		          next^.previous := previous;
		          if (profMoins1=1) 
		            then noteCourante := -DernierCoup(platEssai,adversaire,couleur,-diffEssai)
		            else noteCourante := -ABFinPetite(platEssai,adversaire,profMoins1,-beta,-alpha,-diffEssai,false);
		         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
		          previous^.next := celluleDansListeChaineeCasesVides;
						  next^.previous := celluleDansListeChaineeCasesVides;
						  gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
						 
		          if (noteCourante>maxPourBestDefABFinPetite) then 
		             begin
		               maxPourBestDefABFinPetite := noteCourante;
		               if (noteCourante>alpha) then 
		                 begin
		                   alpha := noteCourante;
		                   if (alpha>=beta) then 
		                      begin
		                        ABFinPetite := maxPourBestDefABFinPetite;
		                        exit(ABFinPetite);
		                      end;
		                 end;
		             end;
						  platEssai := plat;
		          diffEssai := diffPions;
            END;
        celluleDansListeChaineeCasesVides := next;
      end;
  until celluleDansListeChaineeCasesVides = celluleDepart;
 end;
 
{fin:}
 if Ajoue
   then
     begin
       ABFinPetite := maxPourBestDefABFinPetite; 
     end
   else
     begin
       if vientDePasser then
         begin
           if diffPions>0 then 
             begin
               ABFinPetite := diffPions + ESprof;
               exit(ABFinPetite);
             end;
           if diffPions<0 then 
             begin
               ABFinPetite := diffPions - ESprof;
               exit(ABFinPetite);
             end;
           ABFinPetite := 0;
           exit(ABFinPetite);
         end          
       else
         ABFinPetite := -ABFinPetite(plat,adversaire,ESprof,-beta,-alpha,-diffPions,true);
     end;
end;   { ABFinPetite }  


function DernierCoupPourSuite(var plat:plOthEndgame; var meiDef : SInt32;couleur,adversaire,diffPions : SInt32) : SInt32;
var i,x,t,dx,nbprise,compteur,iCourant : SInt32;
    modifie : boolean;
begin
   inc(nbreNoeudsGeneresFinale); 
   
   for i := 1 to gNbreVides_entreeCoupGagnant do 
   BEGIN
    iCourant := gCasesVides_entreeCoupGagnant[i];      
    if plat[iCourant] = pionVide then   
      begin  
        {if modifScoreFin(iCourant,couleur,plat,nBla,nNoi) }
        
        modifie := false;nbprise := 0;
        for t := dirPriseDeb[iCourant] to dirPriseFin[iCourant] do
          begin
              dx := dirPrise[t];
              x := iCourant+dx;
              if plat[x]=adversaire then
                begin
                  compteur := 0;
                  repeat
                    inc(compteur);
                    x := x+dx;         
                  until plat[x]<>adversaire;
                  if (plat[x]=couleur) then
                     begin
                        modifie := true; 
                        nbprise := nbprise+compteur;
                     end;
                end;
           end; 

       if modifie
         then
            begin
              meiDef := iCourant;
              meilleuresuite[1,1] := meiDef;
              DernierCoupPourSuite := succ(diffPions+nbprise+nbprise);
              exit(DernierCoupPourSuite);      
            end
          else
            begin
              {if modifScoreFin(iCourant,adversaire,plat,nBla,nNoi) }
              
              
                {modifie := false;nbprise := 0;}                   {deja Initialises ci-dessus}
                for t := dirPriseDeb[iCourant] to dirPriseFin[iCourant] do
                  begin
                      dx := dirPrise[t];
                      x := iCourant+dx;
                      if plat[x]=couleur then
                        begin
                          compteur := 0;
                          repeat
                            inc(compteur);
                            x := x+dx;         
                          until plat[x]<>couleur;
                          if (plat[x]=adversaire) then
                            begin
                               modifie := true; 
                               nbprise := nbprise+compteur;
                            end;
                        end;
                   end; 
              
               if modifie 
                then
                  begin
                    meiDef := iCourant;
                    meilleuresuite[1,1] := meiDef;
                    DernierCoupPourSuite := pred(diffPions-nbprise-nbprise);
                    exit(DernierCoupPourSuite);      
                  end
                else
                  begin
                    meiDef := 44;
                    meilleuresuite[1,1] := 0;
                    if diffPions>0 then 
                      begin
                        DernierCoupPourSuite := succ(diffPions);
                        exit(DernierCoupPourSuite);
                      end;
                    if diffPions<0 then 
                      begin
                        DernierCoupPourSuite := pred(diffPions);
                        exit(DernierCoupPourSuite);
                      end;
                    DernierCoupPourSuite := 0;
                    exit(DernierCoupPourSuite);
                  end;
            end
      end;
   END; 
  DernierCoupPourSuite := diffPions;    {pas de case vide}
end;   { DernierCoupPourSuite }


function ABFinPetitePourSuite(var plat:plOthEndgame; var meiDef : SInt32;couleur,ESprof,alpha,beta,diffPions : SInt32;
                              vientDePasser : boolean) : SInt32;
{ABFinPetitePourSuite pour les petites profondeurs ( <= profForceBrute )}
var platEssai:plOthEndgame;
    diffEssai : SInt32;
    i,k : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetitePourSuite : SInt32;
    aJoue : boolean; 
    nbVidesTrouvees,nbCoupsPourCoul : SInt32;
    iCourant : SInt32; 
    bestSuite : SInt32;
    listeCasesVides:listeVides;
label fin;   
begin
  if (interruptionReflexion = pasdinterruption) then   
    begin 
	   if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
	   inc(nbreNoeudsGeneresFinale);
	   
	   adversaire := -couleur;
	   profMoins1 := pred(ESprof);   
	   maxPourBestDefABFinPetitePourSuite := -noteMax;
	   aJoue := false; 
	   
	   platEssai := plat;
	   diffEssai := diffPions;
	   
	   nbVidesTrouvees := EtablitListeCasesVidesParOrdreJCW(plat,ESprof,listeCasesVides);
	   if ESprof >= 9
	     then nbCoupsPourCoul := TrierSelonDivergenceSansMilieu(plat,couleur,nbVidesTrouvees,listeCasesVides,listeCasesVides)
	     else nbCoupsPourCoul := nbVidesTrouvees;
	   
	   (*
	   WritelnPositionEtTraitDansRapport(plat,couleur);
	   WritelnStringAndNumDansRapport('ESprof=',ESprof);
	   WritelnStringAndNumDansRapport('nbCoupsPourCoul=',nbCoupsPourCoul);
	   for i := 1 to nbCoupsPourCoul do
	     begin
	       WriteStringAndNumDansRapport('-- ',listeCasesVides[i]);
	       WriteStringAndCoupDansRapport(' ',listeCasesVides[i]);
	     end;
	   WritelnDansRapport('');
	   AttendFrappeClavier;
	   *)
	   
	   for i := 1 to nbCoupsPourCoul do
		   BEGIN
		    iCourant := listeCasesVides[i];         
		    if plat[iCourant] = pionVide then   
		      begin
		        if ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platEssai,diffEssai) then
		          BEGIN
		           aJoue := true;
		           EnleverDeLaListeChaineeDesCasesVides(iCourant);
		           if (profMoins1<=1) 
		             then noteCourante := -DernierCoupPourSuite(platEssai,bestSuite,adversaire,couleur,-diffEssai)
		             else noteCourante := -ABFinPetitePourSuite(platEssai,bestSuite,adversaire,profMoins1,-beta,-alpha,-diffEssai,false);
		           RemettreDansLaListeChaineeDesCasesVides(iCourant);

		           if (noteCourante>maxPourBestDefABFinPetitePourSuite) then 
		              begin
		                
		                maxPourBestDefABFinPetitePourSuite := noteCourante;
		                meiDef := iCourant;
		                for k := 1 to profMoins1 do
		                   meilleureSuite[ESprof,k] := meilleureSuite[profMoins1,k];
		                meilleureSuite[ESprof,ESprof] := meiDef;
		                
		                if (noteCourante>alpha) then 
		                  begin
		                    alpha := noteCourante;
		                    if (alpha>=beta) then 
		                       begin
		                         ABFinPetitePourSuite := maxPourBestDefABFinPetitePourSuite;
		                         exit(ABFinPetitePourSuite);
		                       end;
		                  end;
		              end;
		           platEssai := plat;
		           diffEssai := diffPions;
		          END;
		       end;
		   END;      
	 
	 fin:
	  if Ajoue
	    then
	      begin
	        ABFinPetitePourSuite := maxPourBestDefABFinPetitePourSuite; 
	      end
	    else
	      begin
	        if vientDePasser then
	          begin
	            for k := 1 to ESprof do meilleureSuite[ESprof,k] := 0;
	            if diffPions>0 then 
	              begin
	                ABFinPetitePourSuite := diffPions + ESprof;
	                exit(ABFinPetitePourSuite);
	              end;
	            if diffPions<0 then 
	              begin
	                ABFinPetitePourSuite := diffPions - ESprof;
	                exit(ABFinPetitePourSuite);
	              end;
	            ABFinPetitePourSuite := 0;
	            exit(ABFinPetitePourSuite);
	          end          
	        else
	          ABFinPetitePourSuite := -ABFinPetitePourSuite(plat,meiDef,adversaire,ESprof,-beta,-alpha,-diffPions,true);
	      end;
	 end;    {if not(interromp) }
end;   { ABFinPetitePourSuite }  




                 


procedure MetPosDansHashTableExacte(var whichElement:HashTableExacteElement;
                                    var codagePosition:codePositionRec;
                                    whichEvaluationHeuristique : SInt32);
  begin
    with whichElement,codagePosition do
      begin
        ligne1 := platLigne1;
        ligne2 := platLigne2;
        ligne3 := platLigne3;
        ligne4 := platLigne4;
        ligne5 := platLigne5;
        ligne6 := platLigne6;
        ligne7 := platLigne7;
        ligne8 := platLigne8;
        SetTraitDansHashExacte(couleurCodage,whichElement);
        profondeur := nbreVidesCodage;
        flags := 0;
        evaluationHeuristique := whichEvaluationHeuristique;
      end;
  end;

procedure AttacheCoupsLegauxDansHash(indexmin,indexmax : SInt32; var whichLegalMoves:CoupsLegauxHashPtr;clefHashExacte : SInt32; var listeFinale:listeVides);
  var n : byte;
  begin
    n := succ(indexmax-indexmin);
    if (n<=nbMaxCoupsLegauxDansHash) 
      then
        begin
          whichLegalMoves^[clefHashExacte,0] := n;
          for n := indexmin to indexmax do
            whichLegalMoves^[clefHashExacte,succ(n-indexmin)] := listeFinale[n];
        end
      else
        whichLegalMoves^[clefHashExacte,0] := 0;
  end;

procedure ValiderCetteEntreeCoupsLegauxHash(var whichElement:HashTableExacteElement;entreeValide : boolean);
  begin
    with whichElement do
      if entreeValide
        then flags := BAND(flags,BNOT(kMaskRecalculerCoupsLegaux))  { elle est valide, on ne la recalculera pas }
        else flags := BOR(flags,kMaskRecalculerCoupsLegaux); { il faudra la recalculer }
  end;


procedure MetCoupEnTeteEtAttacheCoupsLegauxDansHash(indexmin,indexmax,coupAMettreEnTete : SInt32; var whichLegalMoves:CoupsLegauxHashPtr;clefHashExacte : SInt32; var listeFinale:listeVides);
  var n,k,coup : SInt32;
  begin
    n := succ(indexmax-indexmin);
    if n<=nbMaxCoupsLegauxDansHash
      then
        begin
          whichLegalMoves^[clefHashExacte,0] := n;
          
          if (coupAMettreEnTete <> 0)
            then
              begin
                whichLegalMoves^[clefHashExacte,1] := coupAMettreEnTete;
                k := 2;
              end
            else
              begin
                k := 1;
              end;
              
          for n := indexmin to indexmax do
            begin
              coup := listeFinale[n];
              if coup<>coupAMettreEnTete then
                begin
                  whichLegalMoves^[clefHashExacte,k] := coup;
                  inc(k);
                end;
            end;
        end
      else
        whichLegalMoves^[clefHashExacte,0] := 0;
  end;

procedure MetAmeliorationsAphaPuisCoupsLegauxDansHash(indexmin,indexmax : SInt32; var ameliorations:ameliorationsAlphaRec;
                                                     var whichLegalMoves:CoupsLegauxHashPtr;clefHashExacte : SInt32; var listeFinale:listeVides);
  var n,k,t,coup : SInt32;
      coupsEnTete : set of 0..99;
  begin
    n := succ(indexmax-indexmin);
    if n<=nbMaxCoupsLegauxDansHash
      then
        begin
          whichLegalMoves^[clefHashExacte,0] := n;
          coupsEnTete := [];
          k:=1;
          with ameliorations do
	          for t := cardinal downto 1 do
	            begin
	              coup := liste[t].coup;
	              coupsEnTete := coupsEnTete + [coup];
	              whichLegalMoves^[clefHashExacte,k] := coup;
	              inc(k);
	            end;
          for t := indexmin to indexmax do
            begin
              coup := listeFinale[t];
              if not(coup in coupsEnTete) then
                begin
                  whichLegalMoves^[clefHashExacte,k] := coup;
                  inc(k);
                end;
            end;
        end
      else
        whichLegalMoves^[clefHashExacte,0] := 0;
  end;


function PasListeFinaleStockeeDansHash(nbVides : SInt32; var whichLegalMoves:CoupsLegauxHashPtr;clefHashExacte : SInt32; var listeFinale:listeVides; var nbCoupsPourCoul : SInt32) : boolean;
  var i,uncoup,n : SInt32;
  begin
    n := whichLegalMoves^[clefHashExacte,0];
    if (n>0) & (n<=nbVides) then
      begin
        for i := 1 to n do
          begin
            uncoup := whichLegalMoves^[clefHashExacte,i];
            listeFinale[i] := uncoup;
          end;
          nbCoupsPourCoul := n;
          PasListeFinaleStockeeDansHash := false;          
        end
      else
        begin
          PasListeFinaleStockeeDansHash := true;
          whichLegalMoves^[clefHashExacte,0] := 0;
        end;
  end;

  

const kNoteBidonPositionNonTrouveeDansHash = -2536383;  {ou n'importe quoi d'aberrant}


function EstUneNoteDeETCNonValide(note : SInt32) : boolean;
begin
  EstUneNoteDeETCNonValide := 
                  ((note >=  kNoteBidonPositionNonTrouveeDansHash - 5) & (note <=  kNoteBidonPositionNonTrouveeDansHash + 5))
                | ((note >= -kNoteBidonPositionNonTrouveeDansHash - 5) & (note <= -kNoteBidonPositionNonTrouveeDansHash + 5));
end;


function ValeurDeFinaleInexploitable(whichNote : SInt32) : boolean;
begin
  ValeurDeFinaleInexploitable := EstUneNoteDeETCNonValide(whichNote) | (interruptionReflexion <> pasdinterruption);
end;
              


function ABFin(var plat:plOthEndgame; var meiDef : SInt32;pere,couleur,ESprof,alpha,beta,diffPions : SInt32;
               var IndiceHashTableExacteRetour : SInt32;vientDePasser : boolean; var InfosMilieuDePartie:InfosMilieuRec;
               var NbNoeudsCoupesParHeuristique : SInt32;essayerMoinsPrecis,seulementChercherDansHash : boolean) : SInt32;
label entree_ABFin;
var platEssai:plOthEndgame;
    diffEssai : SInt32;
    InfosMilieuEssai:InfosMilieuRec;
    i,k : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDef : SInt32;
    aJoue : boolean; 
    nbEvalue,nbVidesTrouvees : SInt32;
    iCourant,nbCoupsPourCoul,constanteDePariteDeiCourant,nbCoupsEnvisages : SInt32; 
    bestSuite : SInt32;
    caseTestee : SInt32;
    meiDefenseSansHeuristique : SInt32;
    listeCasesVides,listeTemp:listeVides;
    listeFinale:listeVides;
    clefHashConseil,conseilHash : SInt32;
    quelleHashTableExacte:HashTableExactePtr;
    quelleHashTableCoupsLegaux:CoupsLegauxHashPtr;
    indiceHashDesFils : array[1..64] of SInt32;
    valeurExacteMax,valeurExacteMin : SInt32;
    valeurHeuristiqueDeLaPosition : SInt32;
    bornes:DecompressionHashExacteRec;
    clefHashExacte,nroTableExacte : SInt32;
    codagePosition:codePositionRec;
    ordreDuMeilleur : SInt32;
    bas_fenetre,haut_fenetre : SInt32;
    largeur_fenetre : SInt32;
    valeurMaxParPionsDefinitifs : SInt32;
    valeurMinParPionsDefinitifs : SInt32;
    alphaInitial,betaInitial : SInt32;
    utiliseMilieuDePartie : boolean;
    coupLegal,dansHashExacte : boolean;
    listeFinaleFromScratch : boolean;
    switchToBitboardAlphaBeta : boolean;
    estPresqueSurementUneCoupureBeta : boolean;
    estPresqueSurementUneCoupureAlpha : boolean;
    celluleDansListeChaineeCasesVides:celluleCaseVideDansListeChaineePtr;
    NbNoeudsHeuristiquesDansCeFils : SInt32;
    NbNoeudsHeuristiquesDansTousLesFils : SInt32;
    NbNoeudsHeuristiquesPourAjusterAlpha : SInt32;
    NbNoeudsHeuristiquesPourAjusterBeta : SInt32;
    ameliorationsAlpha:AmeliorationsAlphaRec;
    {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
    microSecondesCurrentInfos,microSecondesDepartInfos:UnsignedWide;
    {$ENDC}
    
    
    


  
    
  
procedure LiberePlacesHashTableExacte(nroPremierFils,nroDernierFils : SInt32);
  var i,t : SInt32;
  begin
    for i := nroPremierFils to nroDernierFils do
      begin
        t := indiceHashDesFils[i];
        if t>=0 then
          begin
            with HashTableExacte[t div 1024]^[BAND(t,1023)] do
              flags := BOR(flags,kMaskLiberee);
            indiceHashDesFils[i] := -3000;
          end;
      end;
  end;
  
procedure EtablitListeCasesVidesParListeChainee;
  var celluleDansListeChaineeCasesVides:celluleCaseVideDansListeChaineePtr;
      celluleDepart:celluleCaseVideDansListeChaineePtr;
	begin
	  nbVidesTrouvees := 0;
	  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
    celluleDansListeChaineeCasesVides := celluleDepart^.next;
	  repeat 
	    with celluleDansListeChaineeCasesVides^ do
	    BEGIN
	      inc(nbVidesTrouvees);
	      listeCasesVides[nbVidesTrouvees] := square;
	      celluleDansListeChaineeCasesVides := next;
	    END;
	  until celluleDansListeChaineeCasesVides = celluleDepart;
	end;

    
function CaseVideIsolee(CaseVide : SInt32) : boolean;
  var t : SInt32;
  begin
    for t := DirVoisineDeb[CaseVide] to DirVoisineFin[caseVide] do
      if plat[CaseVide+DirVoisine[t]] = pionVide then 
        begin
          CaseVideIsolee := false;
          exit(CaseVideIsolee);
        end;
    CaseVideIsolee := true;
  end;
   
procedure TrierCasesVidesIsolees;  {cases isolées d'abord}
   var ii,j,k : SInt32;
   begin
     if (plat[conseilHash] = pionVide)
       then 
         begin
           j := 1;
           k := 0;
           for ii := 1 to nbVidesTrouvees do
             begin
               caseTestee := listeCasesVides[ii];
               if caseTestee=conseilHash
                 then 
                   begin
                     listeFinale[1] := caseTestee;
                   end
                 else
                   if CaseVideIsolee(caseTestee)
                     then
                       begin
                         inc(j);
                         listeFinale[j] := caseTestee;
                       end
                     else
                       begin
                         inc(k);
                         listeTemp[k] := caseTestee;
                       end;
              end;
         end
       else 
         begin
           j := 0;
           k := 0;
           for ii := 1 to nbVidesTrouvees do
             begin
               caseTestee := listeCasesVides[ii];
               if CaseVideIsolee(caseTestee)
	               then
	                 begin
	                   inc(j);
	                   listeFinale[j] := caseTestee;
	                 end
	               else
	                 begin
	                   inc(k);
	                   listeTemp[k] := caseTestee;
	                 end;
	            end;
          end;     
     for ii := 1 to k do
       begin
         listeFinale[j+ii] := listeTemp[ii];
       end;
   end;
   


  
procedure AfficheResultatsPremiersNiveaux(couleurAffichee : SInt32;nro,total : SInt32);
  var typeAffichage,noteAffichee,noteDeTeteVisible : SInt32;
      pourcentageDejaVisible,pourcentageAffiche : SInt32;
      pourcentagePartielProf2 : SInt32;
      profDansArbre : SInt32;
  begin
  
    if analyseRetrograde.EnCours & passeDeRechercheAuMoinsValeurCible & (ReflexData^.class[1].note<valeurCible)
      then noteDeTeteVisible := valeurCible-1
      else noteDeTeteVisible := ReflexData^.class[1].note;
  
    pourcentageDejaVisible := ReflexData^.class[indexDuCoupDansFntrReflexion].pourcentageCertitude;
    if total>0
       then pourcentageAffiche := RoundToL(100.0*nro/(1.0*total) - 0.01)
       else pourcentageAffiche := 100;
  
    profDansArbre := gNbreVides_entreeCoupGagnant-ESprof;
    with InfosPourcentagesCertitudesAffiches[profDansArbre] do
      begin
        mobiliteCetteProf := total;
        indexDuCoupCetteProf := nro;
        PourcentageAfficheCetteProf := pourcentageAffiche;
      end;
      
    
    if profDansArbre<>2 
      then pourcentagePartielProf2 := pourcentageAffiche
      else with InfosPourcentagesCertitudesAffiches[1] do
        begin
          pourcentagePartielProf2 := RoundToL(100.0*(indexDuCoupCetteProf - 1 + nro/total)/mobiliteCetteProf -0.01);  
        end;
        
    if (ESprof<=gNbreVides_entreeCoupGagnant-2) &
       not(passeDeRechercheAuMoinsValeurCible) &
       (maxPourBestDef>noteDeTeteVisible) &
       (pourcentagePartielProf2>pourcentageAffiche) 
       then pourcentageAffiche := pourcentagePartielProf2;
     
    if (ESprof<=gNbreVides_entreeCoupGagnant-2) &
       passeDeRechercheAuMoinsValeurCible &
       (maxPourBestDef=valeurCible)
       then pourcentageAffiche := pourcentagePartielProf2;
  
    if (nro=1) & (total>1) & (indexDuCoupDansFntrReflexion>1) &
      not(FenetreLargePourRechercheScoreExact) then
      exit(afficheResultatsPremiersNiveaux);
    
    {
    if (ESprof<=gNbreVides_entreeCoupGagnant-2) &
       not(passeDeRechercheAuMoinsValeurCible) &
       (maxPourBestDef>noteDeTeteVisible+2) &
       (nro>1) & (total>1)
     then
       begin
         	EssaieSetPortWindowPlateau;
			    EcritPositionAt(plat,10,10);
			     WriteStringAndNumAt(' prof=',ESprof,10,130);
			     WriteStringAndNumAt(' gNbreVides_entreeCoupGagnant=',gNbreVides_entreeCoupGagnant,80,130);
			     if couleur = pionBlanc
			       then WriteStringAt('pionBlanc  ',210,130)
			       else WriteStringAt('pionNoir    ',210,130);
			     WriteStringAndNumAt('nro=',nro,10,140);
			     WriteStringAndNumAt('total=',total,70,140);
			     WriteStringAndNumAt('certitude=',pourcentageAffiche,150,140);
			     WriteStringAndNumAt('pourcentagePartiel=',pourcentagePartielProf2,240,140);
			     WriteStringAt('pere='+CoupEnStringEnMajuscules(pere),70,150);
			     WriteStringAndNumAt('note=',maxPourBestDef,200,150);
			     
			     WriteStringAt('meiDef='+CoupEnStringEnMajuscules(meiDef),70,160);
			     WriteStringAndNumAt('maxPourBestDef=',maxPourBestDef,200,160);
			     WriteStringAndNumAt('alpha=',alpha,10,170);
			     WriteStringAndNumAt('beta=',beta,90,170);
			     WriteStringAndNumAt('alphaInitial=',alphaInitial,10,180);
			     WriteStringAndNumAt('betaInitial=',betaInitial,90,180);
			     
			     WriteStringAndNumAt('coul=',couleurAffichee,150,170);
			     WriteStringAndNumAt('coulDef=',CoulDefense,220,170);
			     SysBeep(0);
			     AttendFrappeClavier;
       end;
    }
    
    if (ESprof<=gNbreVides_entreeCoupGagnant-2) & 
       passeDeRechercheAuMoinsValeurCible &
       (maxPourBestDef=valeurCible) &
       (nro<=1) & (total>1) then
       exit(afficheResultatsPremiersNiveaux); 
    
    {
    if (ESprof<=gNbreVides_entreeCoupGagnant-2) &
       not(passeDeRechercheAuMoinsValeurCible) &
       (indexDuCoupDansFntrReflexion<=1) then
       exit(afficheResultatsPremiersNiveaux); 
    }
       
    if (ESprof<=gNbreVides_entreeCoupGagnant-2) &
       (couleurAffichee=CoulDefense) then
       exit(afficheResultatsPremiersNiveaux);
       
    
    if (ESprof<=gNbreVides_entreeCoupGagnant-2) &
       not(passeDeRechercheAuMoinsValeurCible) &
       (maxPourBestDef>noteDeTeteVisible+2) &
       (indexDuCoupDansFntrReflexion>1) &
       (nro=1) & (total>1)
      then exit(afficheResultatsPremiersNiveaux);
    
    
    if (ESprof<=gNbreVides_entreeCoupGagnant-2) &
       (pourcentageDejaVisible>0) &
       (pourcentageDejaVisible<100) &
       (pourcentageAffiche<pourcentageDejaVisible) then
       exit(afficheResultatsPremiersNiveaux); 
  
    if not(bestMode) & not(bestmodeArriveeDansCoupGagnant)
      then 
        if analyseRetrograde.EnCours
          then typeAffichage := ReflRetrogradeGagnant
          else 
            if analyseIntegraleDeFinale
              then typeAffichage := ReflGagnantExhaustif
              else typeAffichage := ReflGagnant
      else
        if analyseRetrograde.EnCours
          then 
            if FenetreLargePourRechercheScoreExact 
              then typeAffichage := ReflRetrogradeParfaitPhaseRechScore
              else if (passeDeRechercheAuMoinsValeurCible & (valeurCible=0))
                     then typeAffichage := ReflRetrogradeParfaitPhaseGagnant
                     else typeAffichage := ReflRetrogradeParfait
          else 
            if FenetreLargePourRechercheScoreExact 
              then 
                if analyseIntegraleDeFinale
                  then typeAffichage := ReflParfaitExhaustif
                  else typeAffichage := ReflParfaitPhaseRechScore
              else if (passeDeRechercheAuMoinsValeurCible & (valeurCible=0))
                     then typeAffichage := ReflParfaitPhaseGagnant
                     else typeAffichage := ReflParfait;
                     
     noteAffichee := -maxPourBestDef;
     if (noteAffichee > valeurCible) & passeDeRechercheAuMoinsValeurCible then noteAffichee := valeurCible+1;
     if (noteAffichee = valeurCible) & passeDeRechercheAuMoinsValeurCible then noteAffichee := valeurCible;
     if (noteAffichee < valeurCible) & passeDeRechercheAuMoinsValeurCible then noteAffichee := valeurCible-1;
     if couleurAffichee<>CoulDefense then noteAffichee := -noteAffichee;
     
     if (ESprof<=gNbreVides_entreeCoupGagnant-2) & 
        (not(passeDeRechercheAuMoinsValeurCible) | (maxPourBestDef=valeurCible)) &
        ((maxPourBestDef>noteDeTeteVisible+2) | (indexDuCoupDansFntrReflexion=1))
      then pourcentageAffiche := pourcentagePartielProf2;
     
     ReflexData^.typeDonnees := typeAffichage;
     ReflexData^.compteur := indexDuCoupDansFntrReflexion;
     ReflexData^.IndexCoupEnCours := indexDuCoupDansFntrReflexion;
     with ReflexData^.class[indexDuCoupDansFntrReflexion] do
       begin
         note := noteAffichee;
         if (ESprof<=gNbreVides_entreeCoupGagnant-2)
           then theDefense := pere
           else theDefense := meiDef;
         pourcentageCertitude := pourcentageAffiche;
         delta := deltaFinaleCourant;
         temps := temps+(TickCount()-tickChrono);
         tickChrono := TickCount()
       end;
     if affichageReflexion.doitAfficher then 
       LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant));
     
   
   
     
     {
    EssaieSetPortWindowPlateau;
    EcritPositionAt(plat,10,10);
    EcritPositionAt(position,200,10);
     WriteStringAndNumAt(' prof=',ESprof,10,130);
     WriteStringAndNumAt(' gNbreVides_entreeCoupGagnant=',gNbreVides_entreeCoupGagnant,80,130);
     if couleur = pionBlanc
       then WriteStringAt('pionBlanc  ',210,130)
       else WriteStringAt('pionNoir    ',210,130);
     WriteStringAndNumAt('nro=',nro,10,140);
     WriteStringAndNumAt('total=',total,70,140);
     WriteStringAndNumAt('certitude=',RoundToL(0.4+100.0*nro/(1.0*total)),150,140);
     WriteStringAt('coup='+CoupEnStringEnMajuscules(coup),70,150);
     WriteStringAndNumAt('note=',note,200,150);
     WriteStringAt('meiDef='+CoupEnStringEnMajuscules(meiDef),70,160);
     WriteStringAndNumAt('maxPourBestDef=',maxPourBestDef,200,160);
     SysBeep(0);
     AttendFrappeClavier;
     }
  end;
  

procedure AjusteStatutsDeKnuthDuNoeud;
begin
  with quelleHashTableExacte^[clefHashExacte] do
    if (evaluationHeuristique <> kEvaluationNonFaite) then
      begin
        estPresqueSurementUneCoupureBeta  := (evaluationHeuristique >= (100*beta  + 800));
        estPresqueSurementUneCoupureAlpha := (evaluationHeuristique <= (100*alpha - 800));
      end;
end;

  
procedure EssaieCoupuresHeuristiques;
var estimationPessimiste,estimationOptimiste : SInt32;
    {tickArrivee,}nbEvaluationRecursives : SInt32;
    defense : SInt32;
    deltaMobilite : SInt32;
    deltaFinaleUtiliseDansCeNoueud : SInt32;
    deltaFinaleMaximum : SInt32;
    k : SInt32;
    lower,upper : SInt32;
    coupureHeuristiqueAlpha : boolean;
    coupureHeuristiqueBeta : boolean;
    {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
    microSecondesCurrent,microSecondesDepart:UnsignedWide;
    {$ENDC}
begin

  if not(utiliseMilieuDePartie) then exit(EssaieCoupuresHeuristiques);

  {tickArrivee := TickCount();}
  nbEvaluationRecursives := 0;
  
  
  with InfosMilieuDePartie do
    begin
      deltaMobilite := CalculeMobilite(couleur,plat,jouable) - CalculeMobilite(-couleur,plat,jouable);
      deltaFinaleUtiliseDansCeNoueud := deltaFinaleCourant + 10*deltaMobilite;
      
      
      if (ESprof = profFinaleHeuristique - 1)
        then deltaFinaleUtiliseDansCeNoueud := deltaFinaleUtiliseDansCeNoueud + 75;
      
      deltaFinaleMaximum := deltaSuccessifs[nbreDeltaSuccessifs-1]+ 10*deltaMobilite + 50;
    end;

   
  if (deltaFinaleCourant < kDeltaFinaleInfini) then
	  with quelleHashTableExacte^[clefHashExacte] do
	    begin
	      if (evaluationHeuristique = kEvaluationNonFaite) then
	        with InfosMilieuDePartie do
	          begin
	          
	            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
	            Microseconds(microSecondesDepart);
	            {$ENDC}
	            
	            if profEvaluationHeuristique[ESprof] < 0 
	              then 
	                begin
	                  lower := Max(-30000, alpha*100 - deltaFinaleMaximum);
	                  upper := Min( 30000, beta*100  + deltaFinaleMaximum);
	                  evaluationHeuristique := Evaluation(plat,couleur,nbBlancs,nbNoirs,jouable,frontiere,false,lower,upper,nbEvaluationRecursives);
	                  
	                  defense := 0;
	                  
	                  
	                  {$IFC USE_DEBUG_STEP_BY_STEP}
	                  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
                      then
                        begin
                          WritelnDansRapport('');
                          WritelnDansRapport('vient juste de calculer valeur heuristique par Evaluation :');
                          WritelnStringAndCoupDansRapport('oldMeiDef := ',meiDef);
                          WritelnStringAndCoupDansRapport('meiDef := ',0);
                          WritelnDansRapport('');
                        end;
                    {$ENDC}
	                  
	                  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
	                  Microseconds(microSecondesCurrent);
						        AjouterTempsDansMiniProfiler(0,-2,microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
						        {$ENDC}
						        
						        meiDef := 0;
	                end
	              else
	                begin
	                  lower := Max(-30000, alpha*100 - deltaFinaleMaximum);
                    upper := Min( 30000, beta*100  + deltaFinaleMaximum);
                    evaluationHeuristique := AB_simple(plat,jouable,defense,couleur,profEvaluationHeuristique[ESprof],lower,upper,nbBlancs,nbNoirs,frontiere,true);
	                  
	                  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
	                  Microseconds(microSecondesCurrent);
						        AjouterTempsDansMiniProfiler(0,profEvaluationHeuristique[ESprof],microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
						        {$ENDC}
	                  
	                  {$IFC USE_DEBUG_STEP_BY_STEP}
	                  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
                      then
                        begin
                          WritelnDansRapport(''); 
                          WritelnDansRapport('vient juste de calculer valeur heuristique par AB_simple :');
                          WritelnStringAndCoupDansRapport('oldMeiDef := ',meiDef);
                          WritelnStringAndCoupDansRapport('meiDef := ',defense);
                          WritelnDansRapport('');
                        end;
                    {$ENDC}
                    
                    meiDef := defense;
	                end;
	            
	            {if nbEvaluationRecursives > maxEvalsRecursives then
							  begin
							    WritelnStringAndNumDansRapport('nbEvaluationRecursives=',nbEvaluationRecursives);
							    WritelnStringAndNumDansRapport('temps en ticks=',TickCount()-tickArrivee);
							    WritelnPositionEtTraitDansRapport(plat,couleur);
							    WritelnDansRapport('');
							    maxEvalsRecursives := nbEvaluationRecursives;
							  end;}
							
							evaluationHeuristique := MyTrunc(dilatationEvalEnFinale*evaluationHeuristique);
							
		        end;
		      
	      
	      {soyons pessimiste de deltaFinaleCourant…}
	      estimationPessimiste := 2*(NoteCassioEnScoreFinal(evaluationHeuristique-deltaFinaleUtiliseDansCeNoueud)-32);
	      
	      
	      for k := indexDeltaFinaleCourant to nbreDeltaSuccessifs do
	        begin
			      if (estimationPessimiste > bornes.valMax[k]) & (bornes.nbArbresCoupesValMax[k]=0)
			        then estimationPessimiste := Max(-64,bornes.valMax[k]);
			      
			      if (estimationPessimiste > bornes.valMax[k]) 
		          then estimationPessimiste := bornes.valMax[k];
		         
		        if (estimationPessimiste < bornes.valMin[k]) 
		          then estimationPessimiste := bornes.valMin[k];
          end;
	        
	        
	      { coupure beta heuristique ? }
	      coupureHeuristiqueBeta := (estimationPessimiste >= beta);
	      
	      if coupureHeuristiqueBeta then 
	        begin
	          
            AugmentationMinorant(estimationPessimiste,deltaFinaleCourant,meiDef,couleur,bornes,plat,'coupures heuristiques (1)');
            SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
            CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
            
            {$IFC USE_DEBUG_STEP_BY_STEP}
            if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
               then
                  begin
                    WritelnDansRapport('');
                    WritelnDansRapport('appel de CompresserBornes(1)');
                    WritelnPositionEtTraitDansRapport(plat,couleur);
                    WritelnStringAndNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
                    WritelnStringAndNumDansRapport('bornes.valMax[nbreDeltaSuccessifs] = ',bornes.valMax[nbreDeltaSuccessifs]);
                    WritelnStringAndNumDansRapport('ESProf = ',ESProf);
                    WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
                    WritelnDansRapport('');
                  end;
            {$ENDC}
            	          
	          inc(NbNoeudsCoupesParHeuristique);
	          meilleureSuite[ESprof,ESprof] := meiDef;
	          meilleureSuite[ESprof,profMoins1] := 0;
	          ABFin := estimationPessimiste;
            gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
            exit(ABFin);
	          
	          {WritelnStringAndNumDansRapport('coup. beta heuristique, delta=',deltaFinaleCourant);
				    WritelnPositionEtTraitDansRapport(plat,couleur);
				    WriteStringAndNumDansRapport('beta=',beta);
				    WritelnStringAndNumDansRapport(' et heuristique pess.=',finaleEstimee);
				    SysBeep(0);
				    AttendFrappeClavier;}
				    
	        end;
	      
	      {soyons optimiste de deltaFinaleCourant…}
	      estimationOptimiste := 2*(NoteCassioEnScoreFinal(evaluationHeuristique+deltaFinaleUtiliseDansCeNoueud)-32);
	      
	      for k := indexDeltaFinaleCourant to nbreDeltaSuccessifs do
	        begin
			      if (estimationOptimiste < bornes.valMin[k]) & (bornes.nbArbresCoupesValMin[k]=0)
			        then estimationOptimiste := Min(64,bornes.valMin[k]);
			      
			      if (estimationOptimiste < bornes.valMin[k]) 
			        then estimationOptimiste := bornes.valMin[k];
			      
			      if (estimationOptimiste > bornes.valMax[k]) 
		          then estimationOptimiste := bornes.valMax[k];
		      end;
	         
	         
	         
	      { coupure alpha heuristique ? }
	      coupureHeuristiqueAlpha := (estimationOptimiste <= alpha);
	          
	      
	      
	      if coupureHeuristiqueAlpha then 
	        begin
            
            DiminutionMajorant(estimationOptimiste,deltaFinaleCourant,couleur,bornes,plat,'coupures heuristiques (3)');
            SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
            CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
            
            {$IFC USE_DEBUG_STEP_BY_STEP}
            if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
               then
                    begin
                      WritelnDansRapport('');
                      WritelnDansRapport('appel de CompresserBornes(2)');
                      WritelnPositionEtTraitDansRapport(plat,couleur);
                      WritelnStringAndNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
                      WritelnStringAndNumDansRapport('bornes.valMax[nbreDeltaSuccessifs] = ',bornes.valMax[nbreDeltaSuccessifs]);
                      WritelnStringAndNumDansRapport('ESProf = ',ESProf);
                      WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
                      WritelnDansRapport('');
                    end;
            {$ENDC}
                        
	          inc(NbNoeudsCoupesParHeuristique);
	          meilleureSuite[ESprof,ESprof] := meiDef;
	          meilleureSuite[ESprof,profMoins1] := 0;
	          ABFin := estimationOptimiste;
            gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
            exit(ABFin);
	          
	          {WritelnStringAndNumDansRapport('coup. alpha heuristique, delta=',deltaFinaleCourant);
				    WritelnPositionEtTraitDansRapport(plat,couleur);
				    WriteStringAndNumDansRapport('alpha=',alpha);
				    WritelnStringAndNumDansRapport(' et heuristique opt.=',finaleEstimee);
				    SysBeep(0);
				    AttendFrappeClavier;}
				    
	        end;
	      
	    end;
	
	
end;




function PeutFaireCoupureRapide(alphaRapide,betaRapide : SInt32; var newAlpha,newBeta : SInt32) : boolean;
var t : SInt32;
begin
  if (alphaRapide < betaRapide) then 
  if (alphaRapide <> alpha) | (betaRapide <> beta) then
    begin
	  {WritelnStringDansRapport(s);
	   WritelnStringAndNumDansRapport('alphaInitial=',alphaInitial);
	   WritelnStringAndNumDansRapport('betaInitial=',betaInitial);
	   WritelnStringAndNumDansRapport('alpha=',alpha);
	   WritelnStringAndNumDansRapport('beta=',beta);
	   WritelnStringAndNumDansRapport('alphaRapide=',alphaRapide);
	   WritelnStringAndNumDansRapport('betaRapide=',betaRapide);
	   WritelnPositionEtTraitDansRapport(plat,couleur);}
	   	   
	  if ESprof>=ProfUtilisationHash then
          gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
          
	   t := ABFin(plat,meiDef,pere,couleur,ESprof,alphaRapide,betaRapide,diffPions,IndiceHashTableExacteRetour,
	              vientDePasser,InfosMilieuDePartie,NbNoeudsCoupesParHeuristique,false,false);
       
     if ESprof>=ProfUtilisationHash then
          gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
             
       if t>=betaRapide then
         begin
           {WritelnStringAndNumDansRapport('t>=betaRapide: t=',t);}
           if t>=beta then
             begin
               {WritelnStringAndNumDansRapport('coupure beta ! car beta=',beta);}
               {PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);}
               
               
               ABFin := t;
               if ESprof>=ProfUtilisationHash then
                 gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
               exit(ABFin);
               
             end;
           
           if t>alpha+1 then
             begin
               {WritelnStringAndNumDansRapport('alpha augmente ! car alpha=',alpha);}
               newAlpha := t-1;
               newBeta := Max(beta,newalpha+1);
               PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);
             end;
           
           if t<=alpha then
             begin
               WritelnStringAndNumDansRapport('should never happen (t<=alpha) ! ',0);
               SysBeep(0);
               AttendFrappeClavier;
             end;
         end else
       if t<=alphaRapide then
         begin
           {WritelnStringAndNumDansRapport('t<=alphaRapide: t=',t);}
           if t<=alpha then
             begin
               {WritelnStringAndNumDansRapport('coupure alpha ! car alpha=',alpha);}
               {PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);}
               
               ABFin := t;
               if ESprof>=ProfUtilisationHash then
                 gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
               exit(ABFin);
               
               
             end;
           
           if t<beta-1 then
             begin
               {WritelnStringAndNumDansRapport('beta diminue ! car beta=',beta);}
               newBeta := t+1;
               newAlpha := Min(alpha,newBeta-1);
               PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);
             end;
             
           if t>=beta then
             begin
               WritelnStringAndNumDansRapport('should never happen (t>=beta) ! ',0);
               SysBeep(0);
               AttendFrappeClavier;
             end;
         end else
         begin
           WritelnStringAndNumDansRapport('alphaRapide<t<betaRapide: t=',t);
           if (t>alpha) & (t<beta) then
             begin
               WritelnStringDansRapport('valeur exacte !');
               newAlpha := t-1;
               newBeta := t+1;
               PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);
             end;
           WritelnStringAndNumDansRapport('should never happen (not((t>alpha) & (t<beta))) ! ',0);
           SysBeep(0);
           AttendFrappeClavier;
         end;
     
	 end;
	PeutFaireCoupureRapide := false;
end;


procedure EssaieApproximationsMoinsPrecises;
var tempDeltaFinaleCourant,k : SInt32;
    dernierDeltaDeCettePosition : SInt32;
    valeur,meiDefBid,indiceBid,nbNoeudsBid : SInt32;
begin
  if (deltaFinaleCourant>deltaSuccessifs[1]) then
    begin
    
      (* on trouve le dernier degre d'approximation applique a ce noeud *)
      
      dernierDeltaDeCettePosition := -100000;
      with bornes do
	      for k := 1 to nbreDeltaSuccessifs do
	        if (bornes.valMin[k] > -64) | (bornes.valMax[k] < 64)         {pas juste developpe ?}
	          then dernierDeltaDeCettePosition := ThisDeltaFinal(k);
      	          
      if dernierDeltaDeCettePosition < deltaFinaleCourant then
        begin
      
		      for k := 1 to nbreDeltaSuccessifs do
		        if (deltaSuccessifs[k] > dernierDeltaDeCettePosition) & 
		           (deltaSuccessifs[k] < deltaFinaleCourant) then
		          begin
		            
		            tempDeltaFinaleCourant := deltaFinaleCourant; 
		            SetDeltaFinalCourant(deltaSuccessifs[k]);
		            
		            
		            if ESprof>=ProfUtilisationHash then
	                gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
	                
		            valeur := ABFin(plat,meiDefBid,pere,couleur,ESprof,alpha,beta,diffPions,indiceBid,
		                            vientDePasser,InfosMilieuDePartie,nbNoeudsBid,false,false);
	        
	              if ESprof>=ProfUtilisationHash then
	                gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
		            
		            
		            SetDeltaFinalCourant(tempDeltaFinaleCourant);
		          end;
		     end;
    end;
end;


procedure EssaieTrouverTranspositionUnCoupPlusLoin(alpha,beta : SInt32);
var noteTransposition : SInt32;
    nbMaxTranspositionsCherchees : SInt32;
    i,iCourant,constanteDePariteDeiCourant : SInt32;
    platTranspo:plOthEndgame;
    diffTranspo : SInt32;
    InfosMilieuTranspo:InfosMilieuRec;
    celluleDansListeChaineeCasesVides:celluleCaseVideDansListeChaineePtr;
    bestSuiteTranspo : SInt32;
    NbNoeudsHeuristiquesDansCeFilsTranspo : SInt32;
    indiceHashDummy : SInt32;
begin

  
  
  platTranspo := plat;
  diffTranspo := diffPions;
  if utiliseMilieuDePartie then InfosMilieuTranspo := InfosMilieuDePartie; 
  
  
  nbMaxTranspositionsCherchees := nbCoupsPourCoul;
  if nbMaxTranspositionsCherchees > 5 then nbMaxTranspositionsCherchees := 5;
  
  for i := 1 to nbMaxTranspositionsCherchees do
    BEGIN
      iCourant := listeFinale[i];
      constanteDePariteDeiCourant := constanteDeParite[iCourant];
         
      if utiliseMilieuDePartie
        then 
          begin
            with InfosMilieuTranspo do
              begin
                coupLegal := ModifPlatLongint(iCourant,couleur,platTranspo,jouable,nbBlancs,nbNoirs,frontiere);
                if coupLegal then
                  if couleur = pionNoir
                    then diffTranspo := nbNoirs-nbBlancs
                    else diffTranspo := nbBlancs-nbNoirs;
              end;
          end
        else 
          coupLegal := ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platTranspo,diffTranspo);
        
      if coupLegal then
        begin
        
        
          gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
          {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
          celluleDansListeChaineeCasesVides := gTableDesPointeurs[iCourant];
          with celluleDansListeChaineeCasesVides^ do
            begin
              previous^.next := next;
              next^.previous := previous;
            end;
          
          NbNoeudsHeuristiquesDansCeFilsTranspo := 0;
          noteTransposition := -ABFin(platTranspo,bestSuiteTranspo,iCourant,adversaire,profMoins1,
                                      -beta,-alpha,-diffTranspo,indiceHashDummy,false,
                                      InfosMilieuTranspo,NbNoeudsHeuristiquesDansCeFilsTranspo,false,true);
          
          gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
          {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
				  with celluleDansListeChaineeCasesVides^ do
						begin
						  previous^.next := celluleDansListeChaineeCasesVides;
						  next^.previous := celluleDansListeChaineeCasesVides;
						end;
						
						
					if not(EstUneNoteDeETCNonValide(noteTransposition)) then
					  begin
					    if noteTransposition >= beta then
					      begin
					        
					        {$IFC USE_DEBUG_STEP_BY_STEP}
					        if gDebuggageAlgoFinaleStepByStep.actif &
					           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
					           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
					          begin
					            WritelnDansRapport('');
							        WritelnDansRapport('sortie par coupure beta dans EssaieTrouverTranspositionUnCoupPlusLoin :');
		                  WritelnStringAndNumDansRapport('alpha = ',alpha);
		                  WritelnStringAndNumDansRapport('beta = ',beta);
		                  WritelnStringAndNumDansRapport('noteTransposition = ',noteTransposition);
		                  WritelnStringAndCoupDansRapport('bestSuiteTranspo = ',bestSuiteTranspo);
		                  WritelnStringAndNumDansRapport('ESprof = ',ESprof);
		                  WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
		                  WritelnStringAndNumDansRapport('i = ',i);
		                  WritelnPositionEtTraitDansRapport(plat,couleur);
		                  WritelnDansRapport('');
                    end;
                  {$ENDC}
                  
                  MetPosDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],codagePosition,valeurHeuristiqueDeLaPosition);
                  MetCoupEnTeteEtAttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,iCourant,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
                  
                  SetBestDefenseDansHashExacte(iCourant,quelleHashTableExacte^[clefHashExacte]);
                     
	               {l'ancienne borne superieure}
	                if bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant]=0
	                  then DiminutionMajorant(valeurExacteMax,kDeltaFinaleInfini,couleur,bornes,plat,'transpo (3)')  {borne sure à 100%}
	                  else DiminutionMajorant(valeurExacteMax,deltaFinaleCourant,couleur,bornes,plat,'transpo (4)'); {borne heuristique}
                       
                 {la nouvelle borne inferieure}
                  if NbNoeudsHeuristiquesDansCeFilsTranspo=0
                    then AugmentationMinorant(noteTransposition,kDeltaFinaleInfini,iCourant,couleur,bornes,plat,'transpo (1)')  {borne sure à 100%}
                    else AugmentationMinorant(noteTransposition,deltaFinaleCourant,iCourant,couleur,bornes,plat,'transpo (2)'); {borne heuristique}
                       
                  CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                  
                  {$IFC USE_DEBUG_STEP_BY_STEP}
                  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                    begin
                      WritelnDansRapport('');
                      WritelnDansRapport('appel de CompresserBornes(3)');
                      WritelnPositionEtTraitDansRapport(plat,couleur);
                      WritelnStringAndNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
                      WritelnStringAndNumDansRapport('bornes.valMax[nbreDeltaSuccessifs] = ',bornes.valMax[nbreDeltaSuccessifs]);
                      WritelnStringAndNumDansRapport('ESProf = ',ESProf);
                      WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
                      WritelnDansRapport('');
                    end;
                  {$ENDC}

	                ABFin := noteTransposition;
					        if ESprof>=profondeurRemplissageHash 
                    then HashTable^^[clefHashConseil] := iCourant;
                  gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
                  NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique+NbNoeudsHeuristiquesDansCeFilsTranspo;    
                  exit(ABFin);
					      end;
					      
					  end;
						
        
          platTranspo := plat;
				  diffTranspo := diffPions;
				  if utiliseMilieuDePartie then InfosMilieuTranspo := InfosMilieuDePartie; 

        end;
          
    END;

end;

  
begin
  
  {$IFC USE_DEBUG_STEP_BY_STEP}
  if gDebuggageAlgoFinaleStepByStep.actif &
	   (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
		 MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	  begin
		  WritelnDansRapport('');
		  WriteStringDansRapport('entrée dans ABFin, interruption = ');
		  EcritTypeInterruptionDansRapport(interruptionReflexion);
		  {WritelnStringAndNumDansRapport('dans ABFin, TickCount()-dernierTick = ',TickCount()-dernierTick);
		  WritelnStringAndNumDansRapport('dans ABFin, nbreNoeudsGeneresFinale = ',nbreNoeudsGeneresFinale);
		  WritelnStringAndNumDansRapport('dans ABFin, ProfUtilisationHash = ',ProfUtilisationHash);
		  WritelnStringAndNumDansRapport('dans ABFin, ProfPourHashExacte = ',ProfPourHashExacte);}
		  WritelnDansRapport('dans ABFin, plat = ');
		  WritelnPositionEtTraitDansRapport(plat,couleur);
		  {WritelnStringAndCoupDansRapport('dans ABFin, meiDef = ',meiDef);}
		  WritelnStringAndCoupDansRapport('dans ABFin, pere = ',pere);
		  {WritelnStringAndNumDansRapport('dans ABFin, couleur = ',couleur);}
		  WritelnStringAndNumDansRapport('dans ABFin, ESprof = ',ESprof);
		  WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
		  WritelnStringAndNumDansRapport('dans ABFin, alpha = ',alpha);
		  WritelnStringAndNumDansRapport('dans ABFin, beta = ',beta);
		  {WritelnStringAndNumDansRapport('dans ABFin, diffPions = ',diffPions);
		  WritelnStringAndNumDansRapport('dans ABFin, IndiceHashTableExacteRetour = ',IndiceHashTableExacteRetour);
		  WritelnStringAndBoolDansRapport('dans ABFin, vientDePasser = ',vientDePasser);}
		  WritelnStringAndNumDansRapport('dans ABFin, NbNoeudsCoupesParHeuristique = ',NbNoeudsCoupesParHeuristique);
		  WritelnStringAndBoolDansRapport('dans ABFin, essayerMoinsPrecis = ',essayerMoinsPrecis);
		  WritelnStringAndBoolDansRapport('dans ABFin, seulementChercherDansHash = ',seulementChercherDansHash);
		  WritelnDansRapport('');
    end;
 {$ENDC}
   
 if (interruptionReflexion = pasdinterruption) then   
 begin
 
   if TickCount()-dernierTick >= delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
   inc(nbreNoeudsGeneresFinale);
   
   if ESprof>=ProfUtilisationHash then 
     gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
     
   {$IFC USE_DEBUG_HASH_VALUES}
   if (ESprof >= gNbreVides_entreeCoupGagnant-1) then
     begin
       if not(MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),hashStockeeDansSet,positionsDejaAffichees))
		     then
		       begin
		         WritelnDansRapport('');
		         WritelnDansRapport('Ajout de la position suivante : ');
		         WritelnPositionEtTraitDansRapport(plat,couleur);
		         WritelnStringAndNumDansRapport('gClefHashage = ',gClefHashage);
		         WritelnStringAndNumDansRapport('hachage(position) = ',GenericHash(@plat,sizeof(plat)));
		         AddPositionEtTraitToSet(MakePositionEtTrait(plat,couleur),gClefHashage,positionsDejaAffichees);
		       end
		     else
		       begin
		         if (hashStockeeDansSet <> gClefHashage) then
		           begin
		             SysBeep(0);
		             WritelnDansRapport('');
		             WritelnDansRapport('ERREUR : mismatch de hashStockeeDansSet et gClefHashage : ');
		             WritelnPositionEtTraitDansRapport(plat,couleur);
		             WritelnStringAndNumDansRapport('gClefHashage = ',gClefHashage);
		             WritelnStringAndNumDansRapport('hashStockeeDansSet = ',hashStockeeDansSet);
		           end;
		       end
		 end;
	{$ENDC}
   
entree_ABFin : 

   meiDef := 0;
   meiDefenseSansHeuristique := 0;
   conseilHash := 0;
   listeFinaleFromScratch := true;
   switchToBitboardAlphaBeta := false;
   estPresqueSurementUneCoupureBeta  := false;
   estPresqueSurementUneCoupureAlpha := false;
   maxPourBestDef := -noteMax;
   ordreDuMeilleur := -1;
   if seulementChercherDansHash then ABFin := kNoteBidonPositionNonTrouveeDansHash;
   
   utiliseMilieuDePartie := (ESprof >= profMinimalePourClassementParMilieu) 
                                  {& (alpha < 40) & (beta > -40)}
                                  & (alpha < 60) & (beta > -60);
                                  
   NbNoeudsHeuristiquesDansTousLesFils := 0;
   adversaire := -couleur;
   profMoins1 := pred(ESprof);   


   alphaInitial := alpha;
   betaInitial := beta;
   NbNoeudsHeuristiquesPourAjusterAlpha := 0;
   NbNoeudsHeuristiquesPourAjusterBeta  := 0;
   
   valeurExacteMax := noteMax;
   valeurExacteMin := -noteMax;
   if ESprof>=ProfUtilisationHash
     then 
       begin
         if ESprof>=profondeurRemplissageHash 
           then 
             begin
               clefHashConseil := BAND(gClefHashage,32767);
               conseilHash := HashTable^^[clefHashConseil];
             end
           else conseilHash := 0;
         
         if ESprof>=ProfPourHashExacte then 
           begin
           
             nroTableExacte := BAND(gClefHashage div 1024,nbTablesHashExactesMoins1);
             clefHashExacte := BAND(gClefHashage,1023);
             quelleHashTableExacte := HashTableExacte[nroTableExacte];
             quelleHashTableCoupsLegaux := CoupsLegauxHash[nroTableExacte];

             {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
	           Microseconds(microSecondesDepartInfos);
	           {$ENDC}
	           
             CreeCodagePosition(plat,couleur,ESprof,codagePosition);
             dansHashExacte := InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,gClefHashage,clefHashExacte);
             
             {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
	           Microseconds(microSecondesCurrentInfos);
	           AjouterTempsDansMiniProfiler(0,-3,microSecondesCurrentInfos.lo-microSecondesDepartInfos.lo,kpourcentage);
	           {$ENDC}
						                        
             if dansHashExacte
               then 
                 begin
                 
                   DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                   meiDef := GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]);
                   meiDefenseSansHeuristique := bornes.coupDeCetteValMin[nbreDeltaSuccessifs];
                   
                   {$IFC USE_DEBUG_STEP_BY_STEP}
                   if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                      begin
                        WritelnDansRapport('');
                        WritelnDansRapport('Dans hash exacte :');
                        WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                        WritelnStringAndCoupDansRapport('meiDefenseSansHeuristique = ',meiDefenseSansHeuristique);
                        WritelnDansRapport('');
                      end;
                   {$ENDC}
                   
                   {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
                   CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                   {$ENDC}
                   
                   with bornes do
                   if (nbArbresCoupesValMin[nbreDeltaSuccessifs] = 0) &
                      (valMin[nbreDeltaSuccessifs] = valMax[nbreDeltaSuccessifs]) &
		                  (coupDeCetteValMin[nbreDeltaSuccessifs] <> 0) & (coupDeCetteValMin[nbreDeltaSuccessifs] <> meiDef) then
                     begin
                       Sysbeep(0);
                       WritelnDansRapport('');
                       WritelnDansRapport('Vous avez probablement trouvé un bug : ');
                       WritelnDansRapport('Ne faudrait-il pas changer meiDef parce que l''on connait le meilleur coup ?');
                       WritelnPositionEtTraitDansRapport(plat,couleur);
                       WritelnStringAndNumDansRapport('valMin['+NumEnString(ThisDeltaFinal(nbreDeltaSuccessifs))+'] = ',valMin[nbreDeltaSuccessifs]);
                       WritelnStringAndNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(nbreDeltaSuccessifs))+'] = ',valMax[nbreDeltaSuccessifs]);
                       WritelnStringAndCoupDansRapport('coupDeCetteValMin[nbreDeltaSuccessifs] = ',coupDeCetteValMin[nbreDeltaSuccessifs]);
                       WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                       WritelnDansRapport('');
                     end;
                   
                   with bornes do
                   for k := nbreDeltaSuccessifs downto indexDeltaFinaleCourant do
                     begin
                        
                        {$IFC USE_DEBUG_STEP_BY_STEP}
                        if gDebuggageAlgoFinaleStepByStep.actif &
                           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
					                 MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                          begin
                            WritelnStringAndNumDansRapport('valMin['+NumEnString(ThisDeltaFinal(k))+'] = ',valMin[k]);
                            WritelnStringAndNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(k))+'] = ',valMax[k]);
                            WritelnStringAndCoupDansRapport('coupDeCetteValMin['+NumEnString(ThisDeltaFinal(k))+'] = ',coupDeCetteValMin[k]);
                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                          end;
                        {$ENDC}
                         
                       {Ajustement de la fenetre alpha-beta}
                       if (valMin[k] > alpha) then
                         begin
	                         if bestMode & (deltaFinaleCourant=kDeltaFinaleInfini)
		                         then alpha := pred(valMin[k])
		                         else alpha := valMin[k];
		                       NbNoeudsHeuristiquesPourAjusterAlpha := NbNoeudsHeuristiquesPourAjusterAlpha + nbArbresCoupesValMin[k];
		                       
		                       if false & (nbArbresCoupesValMin[k] = 0) & (k = nbreDeltaSuccessifs) &
		                          (coupDeCetteValMin[k] <> 0) & (coupDeCetteValMin[k] <> meiDef) then
		                           begin
		                             Sysbeep(0);
		                             WritelnDansRapport('');
		                             WritelnDansRapport('Ne faudrait-il pas changer meiDef en meme temps que alpha ?');
		                             WritelnPositionEtTraitDansRapport(plat,couleur);
		                             WritelnStringAndNumDansRapport('valMin['+NumEnString(ThisDeltaFinal(k))+'] = ',valMin[k]);
                                 WritelnStringAndNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(k))+'] = ',valMax[k]);
                                 WritelnStringAndCoupDansRapport('coupDeCetteValMin[k] = ',coupDeCetteValMin[k]);
                                 WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
		                           end;
		                       
		                       {$IFC USE_DEBUG_STEP_BY_STEP}
		                       if gDebuggageAlgoFinaleStepByStep.actif &
			                        (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
			                        ((alpha <> alphaInitial) | (beta <> betaInitial)) &
							                MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
			                       begin
			                         WritelnDansRapport('');
			                         WritelnDansRapport('ajustement de la fenetre alpha-beta : ');
			                         WritelnStringAndNumDansRapport('alphaInitial = ',alphaInitial);
			                         WritelnStringAndNumDansRapport('betaInitial = ',betaInitial);
			                         WritelnStringAndNumDansRapport('alpha = ',alpha);
			                         WritelnStringAndNumDansRapport('beta = ',beta);
			                         WritelnStringAndNumDansRapport('NbNoeudsHeuristiquesPourAjusterAlpha = ',NbNoeudsHeuristiquesPourAjusterAlpha);
			                       end;
		                       {$ENDC}
		                       
	                       end;
	                       
	                     if (valMax[k] < beta) then
                         begin
                           if bestMode & (deltaFinaleCourant=kDeltaFinaleInfini)
                             then beta := succ(valMax[k])
                             else beta := valMax[k];
                           NbNoeudsHeuristiquesPourAjusterBeta := NbNoeudsHeuristiquesPourAjusterBeta + nbArbresCoupesValMax[k];
                           
                           {$IFC USE_DEBUG_STEP_BY_STEP}
                           if gDebuggageAlgoFinaleStepByStep.actif &
			                        (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
			                        ((alpha <> alphaInitial) | (beta <> betaInitial)) &
							                MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
			                       begin
			                         WritelnDansRapport('');
			                         WritelnDansRapport('ajustement de la fenetre alpha-beta : ');
			                         WritelnStringAndNumDansRapport('alphaInitial = ',alphaInitial);
			                         WritelnStringAndNumDansRapport('betaInitial = ',betaInitial);
			                         WritelnStringAndNumDansRapport('alpha = ',alpha);
			                         WritelnStringAndNumDansRapport('beta = ',beta);
			                         WritelnStringAndNumDansRapport('NbNoeudsHeuristiquesPourAjusterBeta = ',NbNoeudsHeuristiquesPourAjusterBeta);
			                         WritelnDansRapport('');
			                       end;
			                     {$ENDC}
	                         
                         end;
                       
                   
                       {
                       if (ValMin[k] > valMax[k]) & (deltaFinaleCourant=kDeltaFinaleInfini)
                          & (interruptionReflexion = pasdinterruption)  then 
                         begin
                           SysBeep(0);
                           WritelnDansRapport('ERROR dans les tests initiaux : (ValeurMin>ValeurMax) & ValeurMinEstAcceptable & ValeurMaxEstAcceptable');
                           WritelnStringAndNumDansRapport('gClefHashage=',gClefHashage);
	                         WritelnStringAndNumDansRapport('ValMin['+NumEnString(ThisDeltaFinal(k))+']=',ValMin[k]);
                           WritelnStringAndNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(k))+']=',valMax[k]);
                           WritelnStringAndNumDansRapport('ESprof=',ESprof);
                           WritelnPositionEtTraitDansRapport(plat,couleur);
                           WritelnDansRapport('');
                         end;
                       }
                       
                       {coupures dues aux valeurs stockees dans la table par interversion ?}
                       if (valMin[k] >= valMax[k])
                         then      
                           begin      
                           
                             {$IFC USE_DEBUG_STEP_BY_STEP}
                             if gDebuggageAlgoFinaleStepByStep.actif &
	                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
	                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	                              begin
	                                WritelnDansRapport('');
			                            WritelnDansRapport('dans ABFin, on a (valMin[k] >= valMax[k]) :');
			                            WritelnStringAndNumDansRapport('valMin[k] = ',valMin[k]);
			                            WritelnStringAndNumDansRapport('valMax[k] = ',valMax[k]);
                                  WritelnStringAndCoupDansRapport('coupDeCetteValMin[k] = ',coupDeCetteValMin[k]);
                                  WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
			                            WritelnDansRapport('');
			                          end;
			                       {$ENDC}
                           
                           
                                      
                             if bestMode & 
                                (alpha <= valMax[k]) & 
                                (valMin[k] <= beta) & 
                                (deltaFinaleCourant=kDeltaFinaleInfini)
                               then
                                 begin
                                 
                                   if (meiDef <> 0) & (meidef = coupDeCetteValMin[k]) then
                                     begin
		                                   {on connait le score, mais on ne sort pas tout de suite 
		                                    de la fonction, on se contente de dire qu'il n'y a qu'un 
		                                    coup legal : cela permet de ramener la suite complete}   
		                                   ABFin := valMin[k];               
		                                   quelleHashTableCoupsLegaux^[clefHashExacte,0] := 1;
		                                   quelleHashTableCoupsLegaux^[clefHashExacte,1] := meiDef;
		                                   NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];
		                                   NbNoeudsHeuristiquesDansTousLesFils := NbNoeudsHeuristiquesDansTousLesFils + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];
		                                 end;
		                                 
                                   {$IFC USE_DEBUG_STEP_BY_STEP}
                                   if (meiDef <> 0) & (meidef = coupDeCetteValMin[k]) &
                                       gDebuggageAlgoFinaleStepByStep.actif &
				                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
				                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
				                              begin
				                                WritelnDansRapport('');
						                            WritelnDansRapport('(valMin[k] = valMax[k]) & (meiDef <> 0), donc je mets un seul coup legal dans ABFin :');
						                            WritelnPositionEtTraitDansRapport(plat,couleur);
						                            WritelnStringAndNumDansRapport('ESProf = ',ESProf);
						                            WritelnStringAndNumDansRapport('alpha = ',alpha);
						                            WritelnStringAndNumDansRapport('beta = ',beta);
						                            WritelnStringAndNumDansRapport('valMin[k] = ',valMin[k]);
						                            WritelnStringAndNumDansRapport('valMax[k] = ',valMax[k]);
						                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
						                            WritelnDansRapport('');
						                          end;
						                       {$ENDC}
                                   
                                 
                                 end
                               else
                                 begin
                                   ABFin := valMin[k];
                                   if ESprof>=profondeurRemplissageHash then
                                     HashTable^^[clefHashConseil] := meiDef;
                                   meilleureSuite[ESprof,ESprof] := meiDef;
                                   
                                   gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
                                   IndiceHashTableExacteRetour := clefHashExacte+1024*nroTableExacte;
                                   NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];
                                   
                                   {$IFC USE_DEBUG_STEP_BY_STEP}
                                   if gDebuggageAlgoFinaleStepByStep.actif &
				                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
				                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
				                              begin
				                                WritelnDansRapport('');
						                            WritelnDansRapport('sortie par (valMin[k] >= valMax[k]) dans ABFin :');
						                            WritelnPositionEtTraitDansRapport(plat,couleur);
						                            WritelnStringAndNumDansRapport('ESProf = ',ESProf);
						                            WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
						                            WritelnStringAndNumDansRapport('alpha = ',alpha);
						                            WritelnStringAndNumDansRapport('beta = ',beta);
						                            WritelnStringAndNumDansRapport('valMin[k] = ',valMin[k]);
						                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
						                            WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
						                            WritelnDansRapport('');
						                          end;
                                   {$ENDC}
                                   
                                   exit(ABFin);
                                 end;
                           end
                         else
                           begin
                             if (valMin[k] >= beta) then
                               begin
                                 ABFin := valMin[k];
                                 if ESprof>=profondeurRemplissageHash then
                                   HashTable^^[clefHashConseil] := meiDef;
                                 meilleureSuite[ESprof,ESprof] := meiDef;
                                 
                                 gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
                                 IndiceHashTableExacteRetour := clefHashExacte+1024*nroTableExacte;
                                 NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + nbArbresCoupesValMin[k];
                                 
                                 {$IFC USE_DEBUG_STEP_BY_STEP}
                                 if gDebuggageAlgoFinaleStepByStep.actif &
				                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
				                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
				                              begin
				                                WritelnDansRapport('');
						                            WritelnDansRapport('sortie par (valMin[k] >= beta) dans ABFin :');
						                            WritelnPositionEtTraitDansRapport(plat,couleur);
						                            WritelnStringAndNumDansRapport('ESProf = ',ESProf);
						                            WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
						                            WritelnStringAndNumDansRapport('alpha = ',alpha);
						                            WritelnStringAndNumDansRapport('beta = ',beta);
						                            WritelnStringAndNumDansRapport('valMin[k] = ',valMin[k]);
						                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
						                            WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
						                            WritelnDansRapport('');
						                          end;
						                      {$ENDC}
						                          
                                 exit(ABFin);
                               end;
                               
                             if (valMax[k] <= alpha) then
                               begin
                                 ABFin := valMax[k];
                                 if ESprof>=profondeurRemplissageHash then
                                   HashTable^^[clefHashConseil] := meiDef;
                                 meilleureSuite[ESprof,ESprof] := meiDef;
                                 gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
                                 IndiceHashTableExacteRetour := clefHashExacte+1024*nroTableExacte;
                                 NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + nbArbresCoupesValMax[k];
                                 
                                 {$IFC USE_DEBUG_STEP_BY_STEP}
                                 if gDebuggageAlgoFinaleStepByStep.actif &
				                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
				                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
				                              begin
				                                WritelnDansRapport('');
						                            WritelnDansRapport('sortie par (valMax[k] <= alpha) dans ABFin :');
						                            WritelnPositionEtTraitDansRapport(plat,couleur);
						                            WritelnStringAndNumDansRapport('ESProf = ',ESProf);
						                            WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
						                            WritelnStringAndNumDansRapport('alpha = ',alpha);
						                            WritelnStringAndNumDansRapport('beta = ',beta);
						                            WritelnStringAndNumDansRapport('valMax[k] = ',valMax[k]);
						                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
						                            WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
						                            WritelnDansRapport('');
						                          end;
						                     {$ENDC}
						                          
                                 exit(ABFin);
                               end;
                           end;
                     end;
                     
		               listeFinaleFromScratch := PasListeFinaleStockeeDansHash(ESprof,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale,nbCoupsPourCoul);
                 end
               else 
                 begin
                   ExpandHashTableExacte(quelleHashTableExacte^[clefHashExacte],quelleHashTableCoupsLegaux,codagePosition,clefHashExacte);
		               
		               DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
		               
		               {if essayerMoinsPrecis & (ESprof > profFinaleHeuristique - 1) & utiliseMilieuDePartie then
		                 begin
		                   EssaieApproximationsMoinsPrecises;
		                   DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
		                 end;
		               }
                 end;
               
             valeurExacteMin := bornes.valMin[indexDeltaFinaleCourant];
             valeurExacteMax := bornes.valMax[indexDeltaFinaleCourant];
             
             {$IFC USE_DEBUG_STEP_BY_STEP}
             if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
               begin
                 WritelnDansRapport('');
                 WritelnStringAndNumDansRapport('affectation (1) valeurExacteMin := ',valeurExacteMin);
                 WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                 WritelnStringAndNumDansRapport('et d''ailleurs, bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] = ',bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant]);
                 WritelnBornesDansRapport(bornes);
                 WritelnDansRapport('');
               end;
             {$ENDC}
             
               
             IndiceHashTableExacteRetour := clefHashExacte+1024*nroTableExacte;
             
             if (ESprof >= profFinaleHeuristique - 1) & (ESprof <= profFinaleHeuristique + 1)
               then EssaieCoupuresHeuristiques;
             
             valeurHeuristiqueDeLaPosition  := quelleHashTableExacte^[clefHashExacte].evaluationHeuristique;
               
             AjusteStatutsDeKnuthDuNoeud;
             
           end;
       end
     else 
       conseilHash := 0;
     
   
   {pour les gros scores, utiliser les pions definitifs pour reduire 
    les valeurs possibles de la position : cela permet des elagages
    a priori}
   if (alpha >= 40) then 
     begin
       if alpha>=50
         then valeurMaxParPionsDefinitifs := 64-2*nbPionsDefinitifsAvecInterieursEndgame(adversaire,plat)
         else valeurMaxParPionsDefinitifs := 64-2*nbPionsDefinitifsEndgame(adversaire,plat);
       if valeurMaxParPionsDefinitifs < beta then beta := succ(valeurMaxParPionsDefinitifs);
       if valeurMaxParPionsDefinitifs <= alpha then 
         begin
           meilleureSuite[ESprof,ESprof] := meiDef;
           meilleureSuite[ESprof,profMoins1] := 0;
           ABFin := valeurMaxParPionsDefinitifs;
           if ESprof>=ProfUtilisationHash then
             begin
               if ESprof>=profondeurRemplissageHash 
                 then HashTable^^[clefHashConseil] := meiDef;
               gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
             end;
           exit(ABFin);
         end;
     end;
   if (beta <= -40) & (profMoins1 <= profForceBrute) then 
     begin
       if beta <= -50
         then valeurMinParPionsDefinitifs := -64+2*nbPionsDefinitifsAvecInterieursEndgame(couleur,plat)
         else valeurMinParPionsDefinitifs := -64+2*nbPionsDefinitifsEndgame(couleur,plat);
       if valeurMinParPionsDefinitifs > alpha then alpha := pred(valeurMinParPionsDefinitifs);
       if valeurMinParPionsDefinitifs >= beta then 
         begin
           meilleureSuite[ESprof,ESprof] := meiDef;
           meilleureSuite[ESprof,profMoins1] := 0;
           ABFin := valeurMinParPionsDefinitifs;
           if ESprof>=ProfUtilisationHash then
             begin
               if ESprof>=profondeurRemplissageHash 
                 then HashTable^^[clefHashConseil] := meiDef;
               gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
             end;
           exit(ABFin);
         end;
     end;
   
   
   
   if seulementChercherDansHash then
     begin
     
       if ESprof>=ProfUtilisationHash then
         gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
       
       {$IFC USE_DEBUG_STEP_BY_STEP}
       if gDebuggageAlgoFinaleStepByStep.actif &
          (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
          MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
         begin
           WritelnDansRapport('');
           WritelnDansRapport('sortie par seulementChercherDansHash : ');
           WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
           WritelnStringAndNumDansRapport('je renvoie kNoteBidonPositionNonTrouveeDansHash, ABFin = ',kNoteBidonPositionNonTrouveeDansHash);
           WritelnDansRapport('');
         end;
       {$ENDC}
         
       exit(ABFin);
     end;
   
   if listeFinaleFromScratch 
     then 
	     begin
	     
	       EtablitListeCasesVidesParListeChainee;
	       nbCoupsPourCoul := nbVidesTrouvees;
	       TrierCasesVidesIsolees;
	       
	       {$IFC USE_DEBUG_STEP_BY_STEP}
	       if gDebuggageAlgoFinaleStepByStep.actif &
           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('Après TrierCasesVidesIsolees dans ABFin :');
            for i := 1 to nbCoupsPourCoul do
              WriteStringAndCoupDansRapport('>',listeFinale[i]);
            WritelnDansRapport('');
          end;
	       {$ENDC}
	       
	       if ESprof >= profPourTriSelonDivergence then
	          nbCoupsPourCoul := TrierSelonDivergenceAvecMilieu(plat,couleur,nbCoupsPourCoul,conseilHash,listeFinale,listeFinale,InfosMilieuDePartie,
      	                                                      100*alpha,100*beta,estPresqueSurementUneCoupureAlpha,estPresqueSurementUneCoupureBeta,
      	                                                      utiliseMilieuDePartie & not(estPresqueSurementUneCoupureAlpha));
	         
	       {if (ESprof>=ProfPourHashExacte) then
	           AttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);}
	       
	       {$IFC USE_DEBUG_STEP_BY_STEP}
	       if gDebuggageAlgoFinaleStepByStep.actif &
           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
          begin
            WritelnStringAndNumDansRapport('ESprof = ',ESprof);
            WritelnStringAndNumDansRapport('profPourTriSelonDivergence = ',profPourTriSelonDivergence);
            WritelnStringAndNumDansRapport('profMinimalePourClassementParMilieu = ',profMinimalePourClassementParMilieu);
            WritelnStringAndBoolDansRapport('utiliseMilieuDePartie = ',utiliseMilieuDePartie);
            if (ESprof >= profPourTriSelonDivergence) then
              begin
                WritelnDansRapport('Après TrierSelonDivergenceAvecMilieu :');
                for i := 1 to nbCoupsPourCoul do
                  WriteStringAndCoupDansRapport('>',listeFinale[i]);
                WritelnDansRapport('');
                WritelnDansRapport('');
              end;
          end;
        {$ENDC}
	         
	     end
     else
       begin
       
         {$IFC USE_DEBUG_STEP_BY_STEP}
         if gDebuggageAlgoFinaleStepByStep.actif &
           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('Liste déjà dans la table de hachage dans ABFin :');
            for i := 1 to nbCoupsPourCoul do
              WriteStringAndCoupDansRapport('>',listeFinale[i]);
            WritelnDansRapport('');
            WritelnDansRapport('');
          end;
          {$ENDC}
          
         if (ESprof > ProfPourHashExacte) & 
			      (alpha <= 50) & (beta >= -50) then 
			     EssaieTrouverTranspositionUnCoupPlusLoin(alpha,beta);
       end;
     
     
   
   
         
   aJoue := false;
   nbEvalue := 0;
   ameliorationsAlpha.cardinal := 0;
   
   platEssai := plat;
   diffEssai := diffPions;
   if utiliseMilieuDePartie then InfosMilieuEssai := InfosMilieuDePartie; 
   
   
   nbCoupsEnvisages := nbCoupsPourCoul;
   
   {
   if not(effetspecial_blah_blah)
     then nbCoupsEnvisages := nbCoupsPourCoul
     else nbCoupsEnvisages := Min(nbCoupsPourCoul,restrictionLargeurSousArbreCeDelta[indexDeltaFinaleCourant,ESProf]);
   }
   
   if (nbCoupsEnvisages = 1) then
     begin
       meiDefenseSansHeuristique := listeFinale[1];
       meiDef := meiDefenseSansHeuristique;
     end;
   
   
   for i := 1 to nbCoupsEnvisages do
    begin
     indiceHashDesFils[i] := -3000;
     
     if (maxPourBestDef<valeurExacteMax)
       then 
         BEGIN
          iCourant := listeFinale[i];
          constanteDePariteDeiCourant := constanteDeParite[iCourant];
         
          {if (deltaFinaleCourant=kDeltaFinaleInfini) & (NbNoeudsHeuristiquesDansTousLesFils <> 0) & (interruptionReflexion = pasdinterruption)  then
            begin
              SysBeep(0);
              WritelnStringAndNumDansRapport('ERROR au début de la boucle des coups légaux : deltaFinaleCourant=infini mais NbNoeudsHeuristiquesDansTousLesFils=',NbNoeudsHeuristiquesDansTousLesFils);
              WritelnStringAndNumDansRapport('gClefHashage=',gClefHashage);
	          WritelnDansRapport('');
            end;
            }
          
          (*** pour debugage seulement ***)
          {if iCourant<11 then AlerteSimple('Debugger : iCourant='+NumEnString(iCourant)+' dans ABFin') else
          if iCourant>88 then AlerteSimple('Debugger : iCourant='+NumEnString(iCourant)+' dans ABFin') else
          if platEssai[iCourant] <> pionVide then AlerteSimple('Debugger : platEssai['+NumEnString(iCourant)+'] <> 0 dans ABFin');
          }
          
          
          if utiliseMilieuDePartie
            then 
              begin
                with InfosMilieuEssai do
                  begin
                    coupLegal := ModifPlatLongint(iCourant,couleur,platEssai,jouable,nbBlancs,nbNoirs,frontiere);
                    if coupLegal then
                      if couleur = pionNoir
                        then diffEssai := nbNoirs-nbBlancs
                        else diffEssai := nbBlancs-nbNoirs;
                  end;
              end
            else 
              coupLegal := ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platEssai,diffEssai);
          
          if coupLegal then 
            begin
             aJoue := true;
             NbNoeudsHeuristiquesDansCeFils := 0;
             (*tickPourEstimerTempsPris := TickCount();*)
             
             gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
             {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
             celluleDansListeChaineeCasesVides := gTableDesPointeurs[iCourant];
             with celluleDansListeChaineeCasesVides^ do
	            begin
	              previous^.next := next;
	              next^.previous := previous;
	            end;
             
             if ESprof>=gNbreVides_entreeCoupGagnant-2 then
               begin
                  with InfosPourcentagesCertitudesAffiches[gNbreVides_entreeCoupGagnant-ESprof] do
					          begin
					            mobiliteCetteProf := nbCoupsPourCoul;
					            indexDuCoupCetteProf := i;
				            end;
               end;
             
            {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
		         tempoNbNoeudsDansABFinPetite[profMoins1] := nbreNoeudsGeneresFinale;
		         {$ENDC}
             
             {if estPresqueSurementUneCoupureBeta & (profMoins1 <= profForceBrute + 2) & (i <= 1)
                then switchToBitboardAlphaBeta := true;}
             
             if (profMoins1 <= profForceBrute) | switchToBitboardAlphaBeta
               then  
                 begin
                   
                   {$IFC USING_BITBOARD}
                      noteCourante := -LanceurBitboardAlphaBeta(platEssai,adversaire,profMoins1,-beta,-alpha,-diffEssai);
			                   
                      {$IFC NOT(NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME) }
                      { Attention !!  110 est une bonne valeur moyenne pour profForceBrute = 8 }
                      { Recalculer la bonne valeur (avec ABFinPetite) quand profForceBrute change ! }
                       nbreNoeudsGeneresFinale := nbreNoeudsGeneresFinale + nbNoeudsEstimes[profMoins1];
                      {$ENDC}
                      
                   {$ELSEC}
                   
		                  noteCourante := -ABFinPetite(platEssai,adversaire,profMoins1,-beta,-alpha,-diffEssai,false);
		                  
                   {$ENDC}
                   inc(nbEvalue);
                 end
               else 
                 begin
                   
                   
                   
                  if (nbEvalue <= 0)
                    then 
                      begin
                        noteCourante := -ABFin(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                               -beta,-alpha,-diffEssai,indiceHashDesFils[i],false,
                                               InfosMilieuEssai,NbNoeudsHeuristiquesDansCeFils,essayerMoinsPrecis,false);
                        
                      end
                    else
                     begin
                       noteCourante := -ABFin(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                              pred(-alpha),-alpha,-diffEssai,indiceHashDesFils[i],false,
                                              InfosMilieuEssai,NbNoeudsHeuristiquesDansCeFils,essayerMoinsPrecis,false);
                       if (alpha < noteCourante) & (noteCourante < beta) then
                         if bestMode
                           then
                             begin
                              {largeur_fenetre := 8;}
                               largeur_fenetre := 2;
	                             repeat
	                               bas_fenetre := pred(noteCourante);
      	                         haut_fenetre := bas_fenetre+largeur_fenetre;
      	                         if (bas_fenetre < alpha) then bas_fenetre  := alpha;
      	                         if (haut_fenetre > beta) then haut_fenetre := beta;
      	                             
	                               noteCourante := -ABFin(platEssai,bestSuite,iCourant,adversaire,profMoins1,
	                                                      -haut_fenetre,-bas_fenetre,-diffEssai,indiceHashDesFils[i],false,
	                                                      InfosMilieuEssai,NbNoeudsHeuristiquesDansCeFils,essayerMoinsPrecis,false);
	                               largeur_fenetre := 2*largeur_fenetre;
	                               if largeur_fenetre>16 then largeur_fenetre := 16;
	                             until ((bas_fenetre < noteCourante) & (noteCourante < haut_fenetre)) | 
	                                   (noteCourante >= beta) | (noteCourante <= alpha) | ValeurDeFinaleInexploitable(noteCourante);
	                          end
                           else 
                             noteCourante := -ABFin(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                                    -beta,-noteCourante,-diffEssai,indiceHashDesFils[i],false,
                                                    InfosMilieuEssai,NbNoeudsHeuristiquesDansCeFils,essayerMoinsPrecis,false);
                     end;
                   NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique+NbNoeudsHeuristiquesDansCeFils;
                   NbNoeudsHeuristiquesDansTousLesFils := NbNoeudsHeuristiquesDansTousLesFils+NbNoeudsHeuristiquesDansCeFils;
                   inc(nbEvalue);
                 end;
           
           if (noteCourante >= beta) & (noteCourante < betaInitial) then
             NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + NbNoeudsHeuristiquesPourAjusterBeta;
           if (noteCourante <= alpha) & (noteCourante > alphaInitial) then
             NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + NbNoeudsHeuristiquesPourAjusterAlpha;
            
           {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
            if (nbreNoeudsGeneresFinale > tempoNbNoeudsDansABFinPetite[profMoins1]) then  {pas de gag d'overflow!}
              begin
                inc(nbAppelsABFinPetite[profMoins1]);
		            tempoNbNoeudsDansABFinPetite[profMoins1] := nbreNoeudsGeneresFinale - tempoNbNoeudsDansABFinPetite[profMoins1];
		            nbNoeudsDansABFinPetite[profMoins1] := nbNoeudsDansABFinPetite[profMoins1] + tempoNbNoeudsDansABFinPetite[profMoins1];
		          end;
		       {$ENDC}
		       
		       {$IFC USE_DEBUG_STEP_BY_STEP}
		       if gDebuggageAlgoFinaleStepByStep.actif &
	           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
	           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	          begin
	            WritelnDansRapport('');
			        WritelnStringAndNumDansRapport('apres calcul de noteCourante dans ABFin '+NumEnString(i)+'/',nbCoupsEnvisages);
              WritelnStringAndNumDansRapport('alpha = ',alpha);
              WritelnStringAndNumDansRapport('beta = ',beta);
              WritelnStringAndNumDansRapport('nbCoupsPourCoul = ',nbCoupsPourCoul);
              WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
              WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
              WritelnStringAndNumDansRapport('maxPourBestDef = ',maxPourBestDef);
              WritelnStringAndNumDansRapport('noteCourante = ',noteCourante);
              WritelnStringAndNumDansRapport('NbNoeudsHeuristiquesDansCeFils = ',NbNoeudsHeuristiquesDansCeFils);
              WritelnStringAndNumDansRapport('NbNoeudsCoupesParHeuristique = ',NbNoeudsCoupesParHeuristique);
              WritelnStringAndNumDansRapport('NbNoeudsHeuristiquesDansTousLesFils = ',NbNoeudsHeuristiquesDansTousLesFils);
              WritelnStringAndNumDansRapport('ESprof = ',ESprof);
              WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
              WritelnDansRapport('');
            end;
            {$ENDC}
            
            gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
            {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
					   with celluleDansListeChaineeCasesVides^ do
							 begin
							   previous^.next := celluleDansListeChaineeCasesVides;
							   next^.previous := celluleDansListeChaineeCasesVides;
							 end;
               
              if (noteCourante>maxPourBestDef) then 
                 begin
                   
                   {$IFC USE_DEBUG_STEP_BY_STEP}
                   if gDebuggageAlgoFinaleStepByStep.actif &
					           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
					           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
					          begin
					            WritelnDansRapport('');
							        WritelnDansRapport('(noteCourante>maxPourBestDef) dans ABFin :');
		                  WritelnStringAndNumDansRapport('alpha = ',alpha);
		                  WritelnStringAndNumDansRapport('beta = ',beta);
		                  WritelnStringAndNumDansRapport('nbCoupsPourCoul = ',nbCoupsPourCoul);
		                  WritelnStringAndCoupDansRapport('oldMeiDef = ',meiDef);
		                  WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
		                  WritelnStringAndNumDansRapport('maxPourBestDef = ',maxPourBestDef);
		                  WritelnStringAndNumDansRapport('noteCourante = ',noteCourante);
		                  WritelnStringAndNumDansRapport('NbNoeudsHeuristiquesDansCeFils = ',NbNoeudsHeuristiquesDansCeFils);
		                  WritelnStringAndNumDansRapport('NbNoeudsCoupesParHeuristique = ',NbNoeudsCoupesParHeuristique);
		                  WritelnStringAndNumDansRapport('NbNoeudsHeuristiquesDansTousLesFils = ',NbNoeudsHeuristiquesDansTousLesFils);
		                  WritelnStringAndNumDansRapport('ESprof = ',ESprof);
		                  WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
		                  WritelnPositionEtTraitDansRapport(plat,couleur);
		                  WritelnDansRapport('');
                    end;
                   {$ENDC}
                 
                   maxPourBestDef := noteCourante;
                   meiDef := iCourant;
                   
                   if (ESprof>=ProfPourHashExacte) & 
                      (maxPourBestDef <= bornes.valMin[nbreDeltaSuccessifs]) {&
                      (bornes.coupDeCetteValMin[nbreDeltaSuccessifs] <> 0)} &
                      (maxPourBestDef <= alpha) &
                      (nbCoupsEnvisages > 1)
	                   then meiDef := bornes.coupDeCetteValMin[nbreDeltaSuccessifs];
                   
                   if (noteCourante>alpha) 
                     then 
	                     begin
	                       
	                       if (ESprof>=ProfPourHashExacte) &
					                  (noteCourante>valeurExacteMax) &
					                  (NbNoeudsHeuristiquesDansCeFils=0) &
					                  (bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant]>0) then
			                      begin
			                        ValeurExacteMax := noteCourante;
			                        bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] := bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant];
			                      end;
			                      
	                       if (ESprof>=ProfPourHashExacte) &
					                  (noteCourante>valeurExacteMax) &
					                  (bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant]>0) then
			                        begin
		                            ValeurExacteMax := noteCourante;
			                          bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] := bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant];
			                        end;
	                     
	                       if (ESprof>=ProfPourHashExacte) then
	                         with ameliorationsAlpha do
	                           begin
			                         inc(cardinal);
			                         with liste[cardinal] do
			                           begin
			                             coup := iCourant;
			                             val := noteCourante;
			                             alphaAvant := alpha;
			                           end;
			                       end; 
	                     
	                       
	                       alpha := noteCourante;
	                       ordreDuMeilleur := i;
	                       
	                       if (ESprof>=ProfPourHashExacte) then
	                         begin
	                           
	                           if (maxPourBestDef > valeurExacteMin)
	                             then bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] := NbNoeudsHeuristiquesDansCeFils
	                             else bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] := NbNoeudsHeuristiquesDansTousLesFils;   
	                           valeurExacteMin := maxPourBestDef;
	                           
	                           {$IFC USE_DEBUG_STEP_BY_STEP}
	                           if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	                             begin
	                               WritelnDansRapport('');
	                               WritelnStringAndNumDansRapport('affectation (2) valeurExacteMin := ',valeurExacteMin);
	                               WritelnStringAndCoupDansRapport('meidef = ',meiDef);
	                               WritelnDansRapport('');
	                             end;
	                           {$ENDC}
	                           
	                           {WritelnStringAndNumDansRapport('setting valeurExacteMin=',valeurExacteMin);
	                           WritelnStringAndNumDansRapport('setting ValeursArriveeHashExacte.nbSousArbresCoupesValeurMin=',ValeursArriveeHashExacte.nbSousArbresCoupesValeurMin);
	                           WritelnDansRapport('');
	                           }
	                           
	                           
	                           MetPosDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],codagePosition,valeurHeuristiqueDeLaPosition);
	                           
	                           {si les evaluations des coups precedents etaient sures,
	                            on peut liberer un peu de place dans la table de hashage}
	                           if (i > 1) & (ESprof > ProfPourHashExacte) & 
	                              ((ESprof < profFinaleHeuristique) |
	                              (({(deltaFinaleCourant=kDeltaFinaleInfini) &} (NbNoeudsHeuristiquesDansTousLesFils=0)))) then
	                              LiberePlacesHashTableExacte(1,pred(i));
	                              
	                           {si les evaluations des coups precedents etaient sures, 
	                            on peut elaguer ces coups; sinon on stocke tous les coups 
	                            legaux pour eviter d'avoir à les recalculer}
	                           if ((ESprof < profFinaleHeuristique) |
	                               ({(deltaFinaleCourant=kDeltaFinaleInfini) &} (NbNoeudsHeuristiquesDansTousLesFils=0)))
	                             then 
	                               begin
	                                 MetCoupEnTeteEtAttacheCoupsLegauxDansHash(i,nbCoupsPourCoul,meiDef,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
	                                 EnleverBornesMinPeuSuresDesAutresCoups(quelleHashTableCoupsLegaux,clefHashExacte,couleur,bornes,plat);
	                               end
	                             else 
	                               begin
	                                 if (ameliorationsAlpha.cardinal>=2)
	                                   then MetAmeliorationsAphaPuisCoupsLegauxDansHash(1,nbCoupsPourCoul,ameliorationsAlpha,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale)
	                                   else MetCoupEnTeteEtAttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,meiDef,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
	                               end;
	                           	                             
	                           {on vient de trouver un nouvelle borne inferieure}
	                           
	                           {if (NbNoeudsHeuristiquesDansTousLesFils=0) & (ValeursArriveeHashExacte.nbSousArbresCoupesValeurMax>0) then
	                                 begin
	                                   WritelnDansRapport('WARNING : aurais-je trouvé ???');
	                                   WritelnStringAndNumDansRapport('gClefHashage=',gClefHashage);
	                                   WritelnDansRapport('');
	                                 end;}
	                             
                             {l'ancienne borne superieure}
                             if bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant]=0
                               then DiminutionMajorant(valeurExacteMax,kDeltaFinaleInfini,couleur,bornes,plat,'amelioration alpha (3)')  {borne sure à 100%}
                               else DiminutionMajorant(valeurExacteMax,deltaFinaleCourant,couleur,bornes,plat,'amelioration alpha (4)'); {borne heuristique}
	                               
	                               
                             {la nouvelle borne inferieure}
                             if bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant]=0
                               then AugmentationMinorant(maxPourBestDef,kDeltaFinaleInfini,meiDef,couleur,bornes,plat,'amelioration alpha (1)') {borne sure à 100%}
                               else AugmentationMinorant(maxPourBestDef,deltaFinaleCourant,meiDef,couleur,bornes,plat,'amelioration alpha (2)');{borne heuristique}
                             
	                                                          
                             {le nouveau meilleur coup dans la position (parmi les fils explorés)}
                             SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
                             CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                             
                             {$IFC USE_DEBUG_STEP_BY_STEP}
                             if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
						                    begin
						                      WritelnDansRapport('');
						                      WritelnDansRapport('appel de CompresserBornes(4)');
						                      WritelnPositionEtTraitDansRapport(plat,couleur);
						                      WritelnStringAndNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
						                      WritelnStringAndNumDansRapport('ESProf = ',ESProf);
						                      WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
						                      WritelnDansRapport('');
						                    end;
                             {$ENDC}
                             
	                         end;

	                       
	                       if (alpha>=beta) then 
	                          begin
	                            ABFin := maxPourBestDef;
	                            
	                            {$IFC USE_DEBUG_STEP_BY_STEP}
	                            if gDebuggageAlgoFinaleStepByStep.actif &
	                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
	                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	                              begin
			                            WritelnDansRapport('sortie par (alpha>=beta) dans ABFin :');
			                            WritelnPositionEtTraitDansRapport(plat,couleur);
			                            WritelnStringAndNumDansRapport('ESProf = ',ESProf);
			                            WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
			                            WritelnStringAndNumDansRapport('alpha = ',alpha);
			                            WritelnStringAndNumDansRapport('beta = ',beta);
			                            WritelnStringAndNumDansRapport('maxPourBestDef = ',maxPourBestDef);
			                            WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
			                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
			                          end;
			                        {$ENDC}
	                            
	                            if noteCourante=64 then
	                              begin
	                                for k := profForceBrutePlusUn to profMoins1 do
	                                  meilleureSuite[ESprof,k] := meilleureSuite[profMoins1,k];
	                                meilleureSuite[ESprof,ESprof] := meiDef;
	                              end;                  
	                            if ESprof>=ProfUtilisationHash then
	                              begin
	                                if ESprof>=profondeurRemplissageHash 
	                                  then HashTable^^[clefHashConseil] := meiDef;
	                                gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
	                              end;                   
	                            exit(ABFin)
	                          end;
	                        
	                     end
                     else  {noteCourante <= alpha}
                       begin
                         
                       end;
                   
                   

                   for k := profForceBrutePlusUn to profMoins1 do
		                 meilleureSuite[ESprof,k] := meilleureSuite[profMoins1,k];
		               meilleureSuite[ESprof,ESprof] := iCourant;  {was := meiDef;}
		               
		               {$IFC USE_DEBUG_STEP_BY_STEP}
                   if gDebuggageAlgoFinaleStepByStep.actif &
	                    (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
	                    MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	                    begin
	                      WritelnDansRapport('');
	                      WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
	                      WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
	                      WritelnDansRapport('Je mets la meilleure suite suivante :');
	                      WriteCoupDansRapport(meilleureSuite[ESprof,ESprof]);
	                      for k := profMoins1 downto profForceBrutePlusUn do
		                      WriteStringAndCoupDansRapport(' ',meilleureSuite[ESprof,k]);
		                    WritelnDansRapport('');
	                    end;
                   {$ENDC}
                   
                   
                 end;  {if noteCourante>MaxPourBestDef}
              
             {if ESprof>=gNbreVides_entreeCoupGagnant-2 then
               AfficheResultatsPremiersNiveaux(couleur,i,nbCoupsPourCoul);}
                 
             platEssai := plat;
             diffEssai := diffPions;
             if utiliseMilieuDePartie then InfosMilieuEssai := InfosMilieuDePartie;
             
            end;
          END;
     end;
     
   {
   if effetspecial_blah_blah & (nbCoupsPourCoul > restrictionLargeurSousArbreCeDelta[indexDeltaFinaleCourant,ESProf]) then
     begin
       inc(NbNoeudsCoupesParHeuristique);
       inc(NbNoeudsHeuristiquesDansTousLesFils);
     end;
   }
   
   if Ajoue
    then 
      begin   
        {si ameliorationsAlpha.cardinal>0, on sait que alpha < maxPourBestDef=valeurExacteMin < beta}
      
        if ESprof>=ProfUtilisationHash then
          begin
            if ESprof>=profondeurRemplissageHash then
              HashTable^^[clefHashConseil] := meiDef;
            gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
            
            if (ESprof>=ProfPourHashExacte) then
                begin
                
                 if (valeurExacteMin>maxPourBestDef) &
                    (NbNoeudsHeuristiquesDansTousLesFils>0) &
                    (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant]=0) then 
                    begin
                      maxPourBestDef := valeurExacteMin;
                    end;
                 
                 if (valeurExacteMin>maxPourBestDef) &
                    (NbNoeudsHeuristiquesDansTousLesFils=0) &
                    (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant]>0) then 
                    begin
                      valeurExacteMin := maxPourBestDef;
                      
                      {$IFC USE_DEBUG_STEP_BY_STEP}
                      if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                        begin
                          WritelnDansRapport('');
                          WritelnStringAndNumDansRapport('affectation (3) valeurExacteMin := ',valeurExacteMin);
                          WritelnDansRapport('');
                        end;
                      {$ENDC}
                      
                    end;
                
                 if (valeurExacteMin>maxPourBestDef) &
                    (NbNoeudsHeuristiquesDansTousLesFils>0) &
                    (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant]>0) then 
                   begin
                     valeurExacteMin := maxPourBestDef;
                     
                     {$IFC USE_DEBUG_STEP_BY_STEP}
                     if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                       begin
                         WritelnDansRapport('');
                         WritelnStringAndNumDansRapport('affectation (4) valeurExacteMin := ',valeurExacteMin);
                         WritelnDansRapport('');
                       end;
                     {$ENDC}
                     
                   end;
                
                if (valeurExacteMin <> maxPourBestDef) &
                   (NbNoeudsHeuristiquesDansTousLesFils=0) &
                    (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant]=0) then 
                    begin
                      (*
                      WritelnDansRapport('WARNING cas non traité !!');
                      SysBeep(0);
                      *)
                    end;
                
                  MetPosDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],codagePosition,valeurHeuristiqueDeLaPosition);
                  
                  {si les evaluations de tous les fils etaient sures,
                   on peut elaguer tous les fils sauf le meilleur, 
                   et liberer les places correspondantes dans la table 
                   de hachage}
                  if (ordreDuMeilleur >= 1) & (meiDef <> 0) &
                     ((ESprof < profFinaleHeuristique) |
                     ({(deltaFinaleCourant=kDeltaFinaleInfini) & }
                       (NbNoeudsHeuristiquesDansTousLesFils = 0) & (bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] = 0) & 
                                                                   (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] = 0)))
                    then            { alpha < maxPourBestDef < beta }
                      begin
                        if (ESprof>ProfPourHashExacte) then 
                          begin
                            if ordreDuMeilleur>1 then 
                              LiberePlacesHashTableExacte(1,pred(ordreDuMeilleur));
                            if ordreDuMeilleur<nbCoupsPourCoul then 
                              LiberePlacesHashTableExacte(succ(ordreDuMeilleur),nbCoupsPourCoul);
                          end;
                        if (listeFinale[ordreDuMeilleur] <> meiDef) then 
                          begin
                            SysBeep(0);
                            WritelnStringAndNumDansRapport('ordreDuMeilleur = ',ordreDuMeilleur);
                            WritelnStringAndCoupDansRapport('listeFinale[ordreDuMeilleur] = ',listeFinale[ordreDuMeilleur]);
                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                          end;
                        AttacheCoupsLegauxDansHash(ordreDuMeilleur,ordreDuMeilleur,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
                        EnleverBornesMinPeuSuresDesAutresCoups(quelleHashTableCoupsLegaux,clefHashExacte,couleur,bornes,plat);
                      end
                    else            { maxPourBestDef <= alpha }
                  {sinon on est oblige de garder tous les fils, pour 
                  les retrouver lors des passes moins risquees}
                      begin
                        if (ameliorationsAlpha.cardinal>=1)
                          then MetAmeliorationsAphaPuisCoupsLegauxDansHash(1,nbCoupsPourCoul,ameliorationsAlpha,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale)
                          else MetCoupEnTeteEtAttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,meiDef,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
                      end;
                  
                  {on vient de trouver la vraie valeur de la position, 
                   qui est "exacte" quand alpha < maxPourBestDef=valeurExacteMin < beta }

                  {la nouvelle borne superieure}
                  if (maxPourBestDef >= valeurExacteMax)
                    then bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] := NbNoeudsHeuristiquesDansTousLesFils + bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant]
                    else bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] := NbNoeudsHeuristiquesDansTousLesFils;
                  if bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant]=0
                    then DiminutionMajorant(maxPourBestDef,kDeltaFinaleInfini,couleur,bornes,plat,'sortie normale (3)')  {valeur sure à 100%}
                    else DiminutionMajorant(maxPourBestDef,deltaFinaleCourant,couleur,bornes,plat,'sortie normale (4)'); {valeur heuristique}
                  
                  {l'ancienne borne inferieure}
                  if ((valeurExacteMin > alphaInitial) | ((valeurExacteMin = 64) & (alphaInitial = 64)) | 
                        ((maxPourBestDef = -64) & (valeurExacteMin = -64) & (bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant]=0))) &
                     ((valeurExacteMin < betaInitial) | ((valeurExacteMin = -64) & (betaInitial = -64))) & 
                     (valeurExacteMin = maxPourBestDef) & (meiDef <> 0) & (NbNoeudsHeuristiquesDansTousLesFils = 0)
                    then meiDefenseSansHeuristique := meiDef;
                  if bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant]=0
                    then AugmentationMinorant(valeurExacteMin,kDeltaFinaleInfini,meiDefenseSansHeuristique,couleur,bornes,plat,'sortie normale (1)')  {valeur sure à 100%}
                    else AugmentationMinorant(valeurExacteMin,deltaFinaleCourant,meiDef,couleur,bornes,plat,'sortie normale (2)'); {valeur heuristique}
                  
                    
                  {et on a determiné le meilleur coup de la position, en plus du score}
                  SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
                  CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                  
                  {$IFC USE_DEBUG_STEP_BY_STEP}
                  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                    begin
                      WritelnDansRapport('');
                      WritelnDansRapport('appel de CompresserBornes(5)');
                      WritelnPositionEtTraitDansRapport(plat,couleur);
                      WritelnStringAndNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
                      WritelnStringAndNumDansRapport('ESProf = ',ESProf);
                      WritelnStringAndNumDansRapport('alphaInitial = ',alphaInitial);
                      WritelnStringAndNumDansRapport('betaInitial = ',betaInitial);
                      WritelnStringAndNumDansRapport('alpha = ',alpha);
                      WritelnStringAndNumDansRapport('beta = ',beta);
                      WritelnStringAndNumDansRapport('ameliorationsAlpha.cardinal = ',ameliorationsAlpha.cardinal);
                      WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
                      WritelnDansRapport('');
                    end;
                  {$ENDC}
                  
                end;
          end;
          
          
          
        {$IFC USE_DEBUG_STEP_BY_STEP}
        if gDebuggageAlgoFinaleStepByStep.actif &
           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('sortie normale dans ABFin :');
            WritelnPositionEtTraitDansRapport(plat,couleur);
            WritelnStringAndNumDansRapport('ESProf = ',ESProf);
            WritelnStringAndNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
            WritelnStringAndNumDansRapport('alpha = ',alpha);
            WritelnStringAndNumDansRapport('beta = ',beta);
            WritelnStringAndNumDansRapport('maxPourBestDef = ',maxPourBestDef);
            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
            if (ESprof>=ProfPourHashExacte) then 
              WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
            WritelnDansRapport('');
          end;
        {$ENDC}
        
        ABFin := maxPourBestDef;
      end
    else 
      begin
        if ESprof>=ProfUtilisationHash then
          gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
          
        if vientDePasser
          then
            begin
              if diffPions>0 then ABFin := diffPions + ESprof else
              if diffPions<0 then ABFin := diffPions - ESprof else
                ABFin := 0;
              for k := profForceBrutePlusUn to ESprof do meilleureSuite[ESprof,k] := 0;
            end          
          else
            ABFin := -ABFin(plat,meiDef,pere,adversaire,ESprof,-beta,-alpha,-diffPions,IndiceHashTableExacteRetour,
                           true,InfosMilieuDePartie,NbNoeudsCoupesParHeuristique,essayerMoinsPrecis,false);
      end;
  end;
end;   { ABFin }





function LanceurABFin(var plat : plateauOthello; var meiDef : SInt32;pere,couleur,ESprof,alpha,beta,nbBlancs,nbNoirs : SInt32;
               var IndiceHashTableExacteRetour : SInt32; var InfosMilieuDePartie:InfosMilieuRec) : SInt32;
var platEndgame:plOthEndgame; 
    valeur,nbTickLanceur : SInt32;
begin  
  if debuggage.algoDeFinale then
    begin
		  FinRapport;
		  TextNormalDansRapport;
		  {if analyseRetrograde.EnCours then WritelnDansRapport('');}
		  WriteStringAndNumDansRapport('LanceurABFin( '+CoupEnString(pere,true)+' , ',-beta);
		  WriteStringAndNumDansRapport(' , ',-alpha);
		  WriteStringAndNumDansRapport(' , c=',valeurCible);
		  if deltaFinaleCourant = kDeltaFinaleInfini
		    then WriteDansRapport(' , µ=∞')
		    else WriteStringAndReelDansRapport(' , µ=',0.01*deltaFinaleCourant,2);
		  if passeEhancedTranspositionCutOffEstEnCours then
		    WriteStringAndBooleanDansRapport(' , ETC=',passeEhancedTranspositionCutOffEstEnCours);
		  WriteStringDansRapport('  )……');
		end;
		
  {$IFC USE_DEBUG_STEP_BY_STEP}
  with gDebuggageAlgoFinaleStepByStep do
    begin
      positionsCherchees := MakeEmptyPositionEtTraitSet();
      {actif := (pere = 22)} {& (deltaFinaleCourant >= 200) & (alpha = -64)};
      {actif := (pere = 78) & (ESProf = 19);}
      actif := true;
      profMin := 1;
      if actif then AjouterPositionsDevantEtreDebugueesPasAPas(positionsCherchees);
    end;
  {$ENDC}
    
  (*
  WritelnDansRapport('');
  WritelnStringAndCoupDansRapport('premier appel a ABFin, meiDef = ',meiDef);
  WritelnStringAndNumDansRapport('premier appel a ABFin, nbCoupuresHeuristiquesCettePasse = ',nbCoupuresHeuristiquesCettePasse);
  WritelnStringAndNumDansRapport('premier appel a ABFin, IndiceHashTableExacteRetour = ',IndiceHashTableExacteRetour);
  WritelnDansRapport('dans ABFin, plat = ');
  WritelnPositionEtTraitDansRapport(platEndgame,couleur);
  WritelnStringAndNumDansRapport('dans ABFin, meiDef = ',meiDef);
  WritelnStringAndNumDansRapport('dans ABFin, pere = ',pere);
  WritelnStringAndNumDansRapport('dans ABFin, couleur = ',couleur);
  WritelnStringAndNumDansRapport('dans ABFin, ESprof = ',ESprof);
  WritelnStringAndNumDansRapport('dans ABFin, alpha = ',alpha);
  WritelnStringAndNumDansRapport('dans ABFin, beta = ',beta);
  WritelnStringAndNumDansRapport('dans ABFin, nbNoirs = ',nbNoirs);
  WritelnStringAndNumDansRapport('dans ABFin, nbBlancs = ',nbBlancs);
  WritelnStringAndNumDansRapport('dans ABFin, IndiceHashTableExacteRetour = ',IndiceHashTableExacteRetour);
  WritelnStringAndNumDansRapport('dans ABFin, nbCoupuresHeuristiquesCettePasse = ',nbCoupuresHeuristiquesCettePasse);
  *)
  
  nbTickLanceur := TickCount();
  
  meiDef := 0;
  CopyEnPlOthEndgame(plat,platEndgame);
  if couleur = pionNoir
    then valeur := ABFin(platEndgame,meiDef,pere,couleur,ESprof,alpha,beta,nbNoirs-nbBlancs,IndiceHashTableExacteRetour,
                         false,InfosMilieuDePartie,nbCoupuresHeuristiquesCettePasse,true,passeEhancedTranspositionCutOffEstEnCours)
    else valeur := ABFin(platEndgame,meiDef,pere,couleur,ESprof,alpha,beta,nbBlancs-nbNoirs,IndiceHashTableExacteRetour,
                         false,InfosMilieuDePartie,nbCoupuresHeuristiquesCettePasse,true,passeEhancedTranspositionCutOffEstEnCours);
  LanceurABFin := valeur;

  nbTickLanceur := TickCount() - nbTickLanceur;
  
  if ((valeur < -64) | (valeur > 64)) & not(ValeurDeFinaleInexploitable(valeur))  then
    begin
      SysBeep(0);
      WritelnDansRapport('');
      WritelnDansRapport('ASSERT((valeur < -64) | (valeur > 64)) dans LanceurABFin!!!');
      WritelnPositionEtTraitDansRapport(platEndgame,couleur);
      WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
      WritelnStringAndCoupDansRapport('pere = ',pere);
      WritelnStringAndNumDansRapport('ESprof = ',ESprof);
      WritelnStringAndNumDansRapport('nbNoirs = ',nbNoirs);
      WritelnStringAndNumDansRapport('nbBlancs = ',nbBlancs);
      WritelnStringAndNumDansRapport('IndiceHashTableExacteRetour = ',IndiceHashTableExacteRetour);
      WritelnStringAndNumDansRapport('nbCoupuresHeuristiquesCettePasse = ',nbCoupuresHeuristiquesCettePasse);
      WritelnStringAndNumDansRapport('alpha = ',alpha);
      WritelnStringAndNumDansRapport('beta = ',beta);
      
      WriteDansRapport('interruption = ');
      EcritTypeInterruptionDansRapport(interruptionReflexion);
      
      LanceInterruption(interruptionSimple,'LanceurABFin');
    end;
  
  if debuggage.algoDeFinale then
    begin
      WriteStringAndNumDansRapport('  => ',-valeur);
      WriteStringAndNumDansRapport(' (',(nbTickLanceur+30) div 60);
      WritelnDansRapport(' s)');
    end;
    
  {$IFC USE_DEBUG_STEP_BY_STEP}
  with gDebuggageAlgoFinaleStepByStep do
    begin
      DisposePositionEtTraitSet(positionsCherchees);
    end;
  {$ENDC}
end;

function ABPreOrdre(var plat : plateauOthello; var InfosMilieuDePartie:InfosMilieuRec; var meiDef : SInt32;
                 pere,couleur,ESprof : SInt32;fenetre:SearchWindow;canDoProbCut : boolean):SearchResult;
var platEssai : plateauOthello;
    InfosMilieuEssai:InfosMilieuRec;
    {nbBlcEssai,nbNrEssai : SInt32;
    frontEssai : InfoFrontRec;
    }
    i : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante:SearchResult;
    nbCoupsPourCoul : SInt32;
    maxPourBestDef:SearchResult;
    aJoue : boolean; 
    coupLegal : boolean;
    nbEvalue : SInt32;
    iCourant : SInt32;
    clefHashConseil,conseilHash : SInt32;
    bestSuite,nbVidesTrouvees : SInt32;
    caseTestee : SInt32;
    nbEvalRecursives : SInt32;
    listeCasesVides,listeTemp:listeVides;
    listeFinale:listeVides;
    evaluerMaintenant : boolean;
    DoitRemplirTableHashSimple : boolean;
    utiliseMilieuDePartiePourTrier : boolean;
    suffisamentLoinDesFeuillesDeLArbre : boolean;
    listeFinaleFromScratch : boolean;
    distanceProfArret : SInt32;
    nroTableExacte : SInt32;
    clefHashExacte : SInt32;
    codagePosition:codePositionRec;
    quelleHashTableExacte:HashTableExactePtr;
    quelleHashTableCoupsLegaux:CoupsLegauxHashPtr;
    ameliorationsAlpha:AmeliorationsAlphaRec;
    bornes:DecompressionHashExacteRec;
    nouvelleFenetre:SearchWindow;
    alphaPourEval : SInt32;
    betaPourEval : SInt32;
    oldAlpha : SInt32;
    ameliorationMinimax : boolean;
    ameliorationProofNumber : boolean;
    evalDuCoup : SInt32;
    valeurDeLaPosition : SInt32;
    nbCasesVides : SInt32;
    distanceALaRacine : SInt32;
    typePropagation : SInt32;
    probableFailLow : boolean;
    probableFailHigh : boolean;
    
    function CaseVideIsolee(CaseVide : SInt32) : boolean;
	  var t : SInt32;
	  begin
	    for t := DirVoisineDeb[CaseVide] to DirVoisineFin[caseVide] do
	      if plat[CaseVide+DirVoisine[t]] = pionVide then 
	        begin
	          CaseVideIsolee := false;
	          exit(CaseVideIsolee);
	        end;
	    CaseVideIsolee := true;
	  end;
 	
		procedure EtablitListeCasesVidesPreordre;
		var i : SInt32;
    begin
      nbVidesTrouvees := 0;
      i := 0;
      repeat
        inc(i);
        caseTestee := gListeCasesVidesOrdreJCWCoupGagnant[i];   
        if plat[caseTestee] = pionVide then  
		      begin 
		        inc(nbVidesTrouvees);
		        listeCasesVides[nbVidesTrouvees] := caseTestee;
		      end;
		  until nbVidesTrouvees>=ESprof;
    end;
	
  
   {cases isolées d'abord}
   procedure TrierCasesVidesIsolees;
   var ii,j,k : SInt32;
   begin
     if plat[conseilHash] = pionVide 
       then 
         begin
           j := 1;
           k := 0;
           for ii := 1 to nbVidesTrouvees do
             begin
               caseTestee := listeCasesVides[ii];
               if caseTestee=conseilHash
                 then 
                   begin
                     listeFinale[1]           := listeCasesVides[ii];
                   end
                 else
                   if CaseVideIsolee(caseTestee)
                     then
                       begin
                         inc(j);
                         listeFinale[j]           := listeCasesVides[ii];
                       end
                     else
                       begin
                         inc(k);
                         listeTemp[k]           := listeCasesVides[ii];
                       end;
              end;
         end
       else 
         begin
           j := 0;
           k := 0;
           for ii := 1 to nbVidesTrouvees do
             if CaseVideIsolee(listeCasesVides[ii])
               then
                 begin
                   inc(j);
                   listeFinale[j]           := listeCasesVides[ii];
                 end
               else
                 begin
                   inc(k);
                   listeTemp[k]           := listeCasesVides[ii];
                 end;
          end;     
     for ii := 1 to k do
       begin
         listeFinale[j+ii]           := listeTemp[ii];
       end;
   end;
   
   
  procedure TryAlphaProbCut(profDepart,profArrivee,fenetre_alpha : SInt32);
  var SeuilProbCut:SearchWindow;
      t:SearchResult;
      tempoProfArret : SInt32;
  begin     {$UNUSED profDepart}
    tempoProfArret := profondeurArretPreordre;
    profondeurArretPreordre := ESprof - profArrivee;
    
    SeuilProbCut := MakeNullWindow(DecalerSearchResult(fenetre.alpha, -fenetre_alpha));
    t := ABPreOrdre(plat,InfosMilieuDePartie,meiDef,pere,couleur,ESprof,SeuilProbCut,false);        
    if FailSoltInWindow(t,SeuilProbCut) then 
      begin 
        profondeurArretPreordre := tempoProfArret;
        ABPreOrdre := fenetre.alpha;
        exit(ABPreOrdre); 
      end;
    
    profondeurArretPreordre := tempoProfArret;
  end;
  
  
  procedure TryBetaProbCut(profDepart,profArrivee,fenetre_beta : SInt32);
  var SeuilProbCut:SearchWindow;
      t:SearchResult;
      tempoProfArret : SInt32;
  begin     {$UNUSED profDepart}
    tempoProfArret := profondeurArretPreordre;
    profondeurArretPreordre := ESprof - profArrivee;
  
    SeuilProbCut := MakeNullWindow(DecalerSearchResult(fenetre.beta, fenetre_beta-1));
    t := ABPreOrdre(plat,InfosMilieuDePartie,meiDef,pere,couleur,ESprof,SeuilProbCut,false);
    if FailHighInWindow(t,SeuilProbCut) then 
      begin 
        profondeurArretPreordre := tempoProfArret;
        ABPreOrdre := fenetre.beta;
        exit(ABPreOrdre); 
      end;
    
    profondeurArretPreordre := tempoProfArret;
  end;
   
  procedure DoProbCutFinale(profDepart,profArrivee,fenetre_alpha,fenetre_beta : SInt32);
  var eval : SInt32;
      nbEvalRecursives : SInt32;
  begin     {$UNUSED profDepart}
  
    alphaPourEval := GetWindowAlphaEnMidgameEval(fenetre);
    betaPourEval := GetWindowBetaEnMidgameEval(fenetre);
          
    if (profArrivee>2) & (alphaPourEval > -20000) & (betaPourEval < 20000)
      then
        begin
          
          with InfosMilieuDePartie do
            eval := Evaluation(plat,couleur,nbBlancs,nbNoirs,jouable,frontiere,false,alphaPourEval,betaPourEval,nbEvalRecursives);
          
          if Abs(eval-alphaPourEval) < Abs(eval-betaPourEval)
            then
              begin
                TryAlphaProbCut(profDepart,profArrivee,fenetre_alpha);
                TryBetaProbCut(profDepart,profArrivee,fenetre_beta);
              end
            else
              begin
                TryBetaProbCut(profDepart,profArrivee,fenetre_alpha);
                TryAlphaProbCut(profDepart,profArrivee,fenetre_beta);
              end;
        end
      else
        begin
          if (alphaPourEval > -20000) then TryAlphaProbCut(profDepart,profArrivee,fenetre_alpha);
          if (betaPourEval  <  20000) then TryBetaProbCut(profDepart,profArrivee,fenetre_beta);
        end;
  end;

  
begin
 inc(nbreNoeudsGeneresFinale);
 if (interruptionReflexion = pasdinterruption) then
 begin
   if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
   
   
   
   nbCasesVides := (64 - InfosMilieuDePartie.nbBlancs - InfosMilieuDePartie.nbNoirs);
   distanceALaRacine := (gNbreVides_entreeCoupGagnant - nbCasesVides);
   if (distanceALaRacine <= gProfondeurCoucheProofNumberSearch)
     then typePropagation := kPropagationProofNumber
     else typePropagation := kPropagationMinimax;
     
  
     
   
   distanceProfArret := ESprof-profondeurArretPreordre;
   suffisamentLoinDesFeuillesDeLArbre := true;
   
   alphaPourEval := GetWindowAlphaEnMidgameEval(fenetre);
   betaPourEval := GetWindowBetaEnMidgameEval(fenetre);
   
   probableFailLow  := false;
   probableFailHigh := false;
	 utiliseMilieuDePartiePourTrier := suffisamentLoinDesFeuillesDeLArbre & 
		                                (ESprof >= profMinimalePourClassementParMilieu) 
		                                & (alphaPourEval < 6000) & (betaPourEval > -6000);
		  
   adversaire := -couleur;
   profMoins1 := pred(ESprof);
   maxPourBestDef := InitialiseSearchResult();
   listeFinaleFromScratch := true;
   
   (*
   WritelnDansRapport('');
   WritelnDansRapport('Entrée dans ABPreordre');
   WritelnPositionEtTraitDansRapport(plat,couleur);
   WritelnStringAndCoupDansRapport('pere = ',pere);
   WritelnStringAndNumDansRapport('ESprof = ',ESprof);
   WritelnStringAndNumDansRapport('nbCasesVides = ',nbCasesVides);
   WritelnStringAndNumDansRapport('distanceProfArret = ',distanceProfArret);
   WritelnStringAndNumDansRapport('distanceALaRacine = ',distanceALaRacine);
   if typePropagation = kPropagationMinimax
     then WritelnDansRapport('propagation minimax')
     else WritelnDansRapport('propagation proof number search');
   *)
   
   if (canDoProbCut & IsNullWindow(fenetre)) then
	   begin
	      {if beta>alpha+1 then
	        begin
	          EssaieSetPortWindowPlateau;
	          EcritPositionAt(pl,10,10);
	          WriteStringAndNumAt('alpha=',alpha,10,150);
	          WriteStringAndNumAt('beta=',beta,100,150);
	          WriteStringAndNumAt('prof=',prof,200,150);
	        end;}
	     
	     if (distanceProfArret= 3) then DoProbCutFinale( 3,1,largFenetreProbCut,largFenetreProbCut) else
	     if (distanceProfArret= 4) then DoProbCutFinale( 4,2,largFenetreProbCut,largFenetreProbCut) else
	     if (distanceProfArret= 5) then DoProbCutFinale( 5,1,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
	     if (distanceProfArret= 6) then DoProbCutFinale( 6,2,largFenetreProbCut,largFenetreProbCut) else
	     if (distanceProfArret= 7) then DoProbCutFinale( 7,3,largFenetreProbCut,largFenetreProbCut) else
	     if (distanceProfArret= 8) then DoProbCutFinale( 8,4,largFenetreProbCut,largFenetreProbCut) else
	     if (distanceProfArret= 9) then DoProbCutFinale( 9,3,largGrandeFenetreProbCut,largGrandeFenetreProbCut);
	     if (distanceProfArret= 9) then DoProbCutFinale( 9,5,largFenetreProbCut,largFenetreProbCut);
	     if (distanceProfArret=10) then DoProbCutFinale(10,4,largGrandeFenetreProbCut,largGrandeFenetreProbCut);
	     if (distanceProfArret=10) then DoProbCutFinale(10,6,largGrandeFenetreProbCut,largGrandeFenetreProbCut);
	     if (distanceProfArret=11) then DoProbCutFinale(11,3,largGrandeFenetreProbCut,largGrandeFenetreProbCut);
	     if (distanceProfArret=11) then DoProbCutFinale(11,5,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
	     if (distanceProfArret=12) then DoProbCutFinale(12,4,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
	     if (distanceProfArret=13) then DoProbCutFinale(13,5,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
	     if (distanceProfArret=14) then DoProbCutFinale(14,4,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
	     if (distanceProfArret=15) then DoProbCutFinale(15,5,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
	     if (distanceProfArret=16) then DoProbCutFinale(16,6,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
	     if (distanceProfArret=17) then DoProbCutFinale(17,5,largGrandeFenetreProbCut,largGrandeFenetreProbCut);
	               
	   end;  {if canDoProbCut}

   
   
   conseilHash := 0;
   DoitRemplirTableHashSimple := (ESprof >= profondeurRemplissageHash);
   {DoitRemplirTableHashSimple := false;}
   
   if ESprof >= ProfUtilisationHash
     then 
       begin
         gClefHashage := BXOR(gClefHashage , IndiceHash^^[couleur,pere]);
         if ESprof>=profondeurRemplissageHash then
           begin
             clefHashConseil := BAND(gClefHashage,32767);
             conseilHash := HashTable^^[clefHashConseil];
           end;
         
         if (ESprof >= ProfPourHashExacte) then 
           begin
           
             nroTableExacte := BAND(gClefHashage div 1024,nbTablesHashExactesMoins1);
             clefHashExacte := BAND(gClefHashage,1023);
             quelleHashTableExacte := HashTableExacte[nroTableExacte];
             quelleHashTableCoupsLegaux := CoupsLegauxHash[nroTableExacte];

             CreeCodagePosition(plat,couleur,ESprof,codagePosition);
             if InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,gClefHashage,clefHashExacte)
               then
                 begin
                   listeFinaleFromScratch := PasListeFinaleStockeeDansHash(ESprof,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale,nbCoupsPourCoul);
                   
                   DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                   meiDef := GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]);
                   {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
                   CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                   {$ENDC}
                   
                   if MeilleurCoupEstStockeDansLesBornes(bornes,meiDef,valeurDeLaPosition) then
                     begin
                       if ESprof>=ProfUtilisationHash then
                         begin
                           if DoitRemplirTableHashSimple then HashTable^^[clefHashConseil] := meiDef;
                           gClefHashage := BXOR(gClefHashage,IndiceHash^^[couleur,pere]);
                         end;
                       
                       ABPreOrdre := MakeSearchResultForSolvedPosition(bornes.valMin[nbreDeltaSuccessifs]);
                       exit(ABPreOrdre);
                     end;
                 end
               else
                 begin
                   ExpandHashTableExacte(quelleHashTableExacte^[clefHashExacte],quelleHashTableCoupsLegaux,codagePosition,clefHashExacte);
                 end;
           end;
        end;
             
   if listeFinaleFromScratch 
     then
	     begin             
	     
	       EtablitListeCasesVidesPreordre;
	       nbCoupsPourCoul := nbVidesTrouvees;
	       TrierCasesVidesIsolees;
	     
	       {$IFC USE_DEBUG_STEP_BY_STEP}
  	     if gDebuggageAlgoFinaleStepByStep.actif &
             (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
             MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('Après TrierCasesVidesIsolees dans ABPreOrdre :');
              for i := 1 to nbCoupsPourCoul do
                WriteStringAndCoupDansRapport('>',listeFinale[i]);
              WritelnDansRapport('');
            end;
         {$ENDC}
	       
	       if ESprof >= profPourTriSelonDivergence then
	         begin
	           alphaPourEval := GetWindowAlphaEnMidgameEval(fenetre);
             betaPourEval := GetWindowBetaEnMidgameEval(fenetre);
	           nbCoupsPourCoul := TrierSelonDivergenceAvecMilieu(plat,couleur,nbCoupsPourCoul,conseilHash,listeFinale,listeFinale,InfosMilieuDePartie,
	                                                             alphaPourEval,betaPourEval,probableFailLow,probableFailHigh,utiliseMilieuDePartiePourTrier);
	         end;
	       
	       {$IFC USE_DEBUG_STEP_BY_STEP}
	       if gDebuggageAlgoFinaleStepByStep.actif &
           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
          begin
            WritelnStringAndNumDansRapport('ESprof = ',ESprof);
            WritelnStringAndNumDansRapport('profPourTriSelonDivergence = ',profPourTriSelonDivergence);
            WritelnStringAndNumDansRapport('profMinimalePourClassementParMilieu = ',profMinimalePourClassementParMilieu);
            WritelnStringAndBoolDansRapport('utiliseMilieuDePartiePourTrier = ',utiliseMilieuDePartiePourTrier);
            if (ESprof >= profPourTriSelonDivergence) then
              begin
                WritelnDansRapport('Après TrierSelonDivergenceAvecMilieu :');
                for i := 1 to nbCoupsPourCoul do
                  WriteStringAndCoupDansRapport('>',listeFinale[i]);
                WritelnDansRapport('');
                WritelnDansRapport('');
              end;
          end;
	       {$ENDC}
	       
	     end
	   else
	     begin
	       (*
	        if (ESprof >= profPourTriSelonDivergence) & suffisamentLoinDesFeuillesDeLArbre &
	          (ESprof>=ProfPourHashExacte) & (BAND(quelleHashTableExacte^[clefHashExacte].flags,kMaskRecalculerCoupsLegaux) <> 0)
	         then TrierSelonDivergenceAvecMilieu(listeFinale,listeFinale); 
	       *)
	       
	       {$IFC USE_DEBUG_STEP_BY_STEP}
	       if gDebuggageAlgoFinaleStepByStep.actif &
             (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) &
             MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('Liste des coups stochee dans la table de hachage dans ABPreOrdre :');
              for i := 1 to nbCoupsPourCoul do
                WriteStringAndCoupDansRapport('>',listeFinale[i]);
              WritelnDansRapport('');
            end;
         {$ENDC}
	         
	     end;
   
   
   
   aJoue := false; 
   nbEvalue := 0;  
   meiDef := 0;
   ameliorationsAlpha.cardinal := 0;
   
   platEssai := plat;
   InfosMilieuEssai := InfosMilieuDePartie;
   
   
   for i := 1 to nbCoupsPourCoul do
       BEGIN
        iCourant := listeFinale[i];
        
        (*** pour debugage seulement ***)
        {if iCourant<11 then AlerteSimple('Debugger : iCourant='+NumEnString(iCourant)+' dans ABPreordre') else
        if iCourant>88 then AlerteSimple('Debugger : iCourant='+NumEnString(iCourant)+' dans ABPreordre') else
        if platEssai[iCourant] <> pionVide then AlerteSimple('Debugger : platEssai['+NumEnString(iCourant)+'] <> 0 dans ABPreordre');
        }
        
        with InfosMilieuEssai do
          coupLegal := (platEssai[iCourant] = pionVide) & ModifPlatLongint(iCourant,couleur,platEssai,jouable,nbBlancs,nbNoirs,frontiere);
        
        if coupLegal then
          begin
            aJoue := true;
            
            EnleverDeLaListeChaineeDesCasesVides(iCourant);
            
            if (profMoins1<=profondeurArretPreordre-2)
              then 
                begin
                  evaluerMaintenant := true;
                end
              else
                if (profMoins1>profondeurArretPreordre)
                  then evaluerMaintenant := false
                  else 
                    begin
                      evaluerMaintenant := true;                      
                      if evaluerMaintenant & not(utilisationNouvelleEval) then
                        evaluerMaintenant := PasDeBordDeCinqAttaque(adversaire,InfosMilieuEssai.frontiere,platessai);
                    end; 
             
            if evaluerMaintenant
              then 
                begin
                  with InfosMilieuEssai do
                    begin
                      alphaPourEval := GetWindowAlphaEnMidgameEval(fenetre);
                      betaPourEval := GetWindowBetaEnMidgameEval(fenetre);
                        
                      evalDuCoup := Evaluation(platEssai,adversaire,nbBlancs,nbNoirs,jouable,frontiere,false,-betaPourEval,-alphaPourEval,nbEvalRecursives);
                                            
                      noteCourante := ReverseResult(MakeSearchResultFromHeuristicValue(evalDuCoup));
                      
                    end;
                end
              else 
               begin
                if (nbEvalue<=0) | IsNullWindow(fenetre) 
                 then 
                   begin
                    noteCourante := ReverseResult(ABPreOrdre(platEssai,InfosMilieuEssai,bestSuite,iCourant,adversaire,profMoins1,
                                                  ReverseWindow(fenetre),canDoProbCut));
                    inc(nbEvalue);
                   end
                 else
                   begin
                      nouvelleFenetre := MakeNullWindow(fenetre.alpha);
                      noteCourante := ReverseResult(ABPreOrdre(platEssai,InfosMilieuEssai,bestSuite,iCourant,adversaire,profMoins1,
                                                    ReverseWindow(nouvelleFenetre),canDoProbCut));
                      if ResultInsideWindow(noteCourante,fenetre) then
                        begin
                          nouvelleFenetre := MakeSearchWindow(noteCourante,fenetre.beta);
                          noteCourante := ReverseResult(ABPreOrdre(platEssai,InfosMilieuEssai,bestSuite,iCourant,adversaire,profMoins1,
                                                        ReverseWindow(nouvelleFenetre),canDoProbCut));
                          
                          if IsNullWindow(MakeSearchWindow(fenetre.alpha,noteCourante))
                            then noteCourante := fenetre.alpha;
                        end;
                   end;
                end;
                
             RemettreDansLaListeChaineeDesCasesVides(iCourant);
             
             (*
             if (typePropagation = kPropagationProofNumber) then
               begin
                 WritelnDansRapport('');
                 WritelnDansRapport('avant UpdateSearchResult');
                 WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
                 WritelnStringAndReelDansRapport('noteCourante.PN = ',GetProofNumberOfResult(noteCourante),15);
                 WritelnStringAndReelDansRapport('noteCourante.DP = ',GetDisproofNumberOfResult(noteCourante),15);
                 WritelnStringAndReelDansRapport('maxPourBestDef.PN = ',GetProofNumberOfResult(maxPourBestDef),15);
                 WritelnStringAndReelDansRapport('maxPourBestDef.DP = ',GetDisproofNumberOfResult(maxPourBestDef),15);
               end;
             *)
             
             UpdateSearchResult(maxPourBestDef,noteCourante,ameliorationMinimax,ameliorationProofNumber);
             
             (*
             if (typePropagation = kPropagationProofNumber) then
               begin
                 WritelnDansRapport('après UpdateSearchResult');
                 WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
                 WritelnStringAndReelDansRapport('noteCourante.PN = ',GetProofNumberOfResult(noteCourante),15);
                 WritelnStringAndReelDansRapport('noteCourante.DP = ',GetDisproofNumberOfResult(noteCourante),15);
                 WritelnStringAndReelDansRapport('maxPourBestDef.PN = ',GetProofNumberOfResult(maxPourBestDef),15);
                 WritelnStringAndReelDansRapport('maxPourBestDef.DP = ',GetDisproofNumberOfResult(maxPourBestDef),15);
                 WritelnStringAndBoolDansRapport('ameliorationProofNumber = ',ameliorationProofNumber);
               end;
             *)
             
             if (ameliorationMinimax & (typePropagation = kPropagationMinimax)) |
                (ameliorationProofNumber & (typePropagation = kPropagationProofNumber)) then
                begin
                  
                  meiDef := iCourant;
                  
                  oldAlpha := GetWindowAlphaEnMidgameEval(fenetre);
                  if UpdateSearchWindow(maxPourBestDef,fenetre) |
                     (ameliorationProofNumber & (typePropagation = kPropagationProofNumber)) then 
                    begin
                     
                      with ameliorationsAlpha do
                        begin
		                      inc(cardinal);
		                      with liste[cardinal] do
		                        begin
		                          coup := iCourant;
		                          val := GetWindowAlphaEnMidgameEval(fenetre);
		                          alphaAvant := oldAlpha;
		                        end;
		                    end; 
                      
                      
                      if (ESprof>=ProfPourHashExacte) then
                        begin
                          MetPosDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],codagePosition,kEvaluationNonFaite);
                          if (ameliorationsAlpha.cardinal >= 2)
                            then MetAmeliorationsAphaPuisCoupsLegauxDansHash(1,nbCoupsPourCoul,ameliorationsAlpha,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale)
                            else MetCoupEnTeteEtAttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,iCourant,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
                          ValiderCetteEntreeCoupsLegauxHash(quelleHashTableExacte^[clefHashExacte],suffisamentLoinDesFeuillesDeLArbre);
                          SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
                        end;
                      
                      if (AlphaBetaCut(fenetre) & (typePropagation = kPropagationMinimax)) then 
                         begin
                           ABPreOrdre := maxPourBestDef;
                           if ESprof>=ProfUtilisationHash then
                             begin
                               if DoitRemplirTableHashSimple then 
                                 HashTable^^[clefHashConseil] := meiDef;
                               gClefHashage := BXOR(gClefHashage,IndiceHash^^[couleur,pere]);
                             end;
                           exit(ABPreOrdre)
                         end;
                    end;
                end;
             
             platEssai := plat;
             InfosMilieuEssai := InfosMilieuDePartie;              
         end;
     END;

   
  if Ajoue
    then 
      begin
        
        if ESprof>=ProfUtilisationHash then
          begin
            if DoitRemplirTableHashSimple then HashTable^^[clefHashConseil] := meiDef;
            gClefHashage := BXOR(gClefHashage,IndiceHash^^[couleur,pere]);
            
            if (ESprof>=ProfPourHashExacte) then
              begin
                (*if (ESprof=profFinaleHeuristique) & (distanceProfArret>=profEvaluationHeuristique[ESprof]) & (ameliorationsAlpha.cardinal>=1)
                  then
                    begin
                      {
                      WritelnStringAndNumDansRapport('ESprof=',ESprof);
                      WritelnStringAndNumDansRapport('profFinaleHeuristique=',profFinaleHeuristique);
                      WritelnStringAndNumDansRapport('distanceProfArret=',distanceProfArret);
                      WritelnStringAndNumDansRapport('profEvaluationHeuristique[ESprof]=',profEvaluationHeuristique[ESprof]);
                      WritelnStringAndNumDansRapport('ameliorationsAlpha.cardinal=',ameliorationsAlpha.cardinal);
                      WritelnStringAndNumDansRapport('ameliorationsAlpha.liste[1].alphaAvant=',ameliorationsAlpha.liste[1].alphaAvant);
                      WritelnStringAndNumDansRapport('maxPourBestDef=',maxPourBestDef);
                      WritelnDansRapport('');
                      AttendFrappeClavier;
                      }
                      MetPosDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],codagePosition,maxPourBestDef);
                    end
                  else *)
                    MetPosDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],codagePosition,kEvaluationNonFaite);
                    
                if (ameliorationsAlpha.cardinal>=1)
                  then MetAmeliorationsAphaPuisCoupsLegauxDansHash(1,nbCoupsPourCoul,ameliorationsAlpha,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale)
                  else AttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
                ValiderCetteEntreeCoupsLegauxHash(quelleHashTableExacte^[clefHashExacte],suffisamentLoinDesFeuillesDeLArbre);
                {SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);}
              end;
          end;
        
        ABPreOrdre := maxPourBestDef;
      end
    else
      begin
        if ESprof>=ProfUtilisationHash then
          gClefHashage := BXOR(gClefHashage,IndiceHash^^[couleur,pere]);
        if DoitPasserFin(adversaire,plat) 
          then
            if couleur = pionBlanc 
              then ABPreOrdre := MakeSearchResultForSolvedPosition(InfosMilieuDePartie.nbBlancs-InfosMilieuDePartie.nbNoirs)
              else ABPreOrdre := MakeSearchResultForSolvedPosition(InfosMilieuDePartie.nbNoirs-InfosMilieuDePartie.nbBlancs)
          else
            ABPreOrdre := ReverseResult(ABPreOrdre(plat,InfosMilieuDePartie,meiDef,pere,adversaire,ESprof,ReverseWindow(fenetre),canDoProbCut));    
      end;     
 end;    
end;   { ABPreOrdre }


function EndgameTreeEstValide(var numeroEndgameTreeActif : SInt32) : boolean;
var ok : boolean;
begin
  ok := coupGagnantUtiliseEndgameTrees &
        (numeroEndgameTreeActif >= 1) & 
        (numeroEndgameTreeActif <= NbMaxEndgameTrees()) &
        (magicCookieEndgameTree > 0) & 
        (GetMagicCookieInitialEndgameTree(numeroEndgameTreeActif) = magicCookieEndgameTree);
        
  if not(ok) then numeroEndgameTreeActif := -1;
  EndgameTreeEstValide := ok;
end;

procedure AjouteScoreToEndgameTree(positionEtTrait : PositionEtTraitRec;genreRefl,valeur : SInt32);
var scorePourNoir : SInt32;
    posArbre : PositionEtTraitRec;
    G : GameTree;
    OK,debugage : boolean;
begin
  debugage := false;
  
  if debugage then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('entrée dans AjouteScoreToEndgameTree : ');
    end;
  
  if not(ValeurDeFinaleInexploitable(valeur)) &
     (GetTraitOfPosition(positionEtTrait) <> pionVide) &
     EndgameTreeEstValide(numeroEndgameTreeActif) then
    begin
      G := GetActiveNodeOfEndgameTree(numeroEndgameTreeActif);
      
      if (G <> NIL) then
        begin
          OK := GetPositionEtTraitACeNoeud(G,posArbre);
          
          if GetTraitOfPosition(positionEtTrait) = pionNoir
            then scorePourNoir := valeur
            else scorePourNoir := -valeur;
          
          if debugage then
            begin
		          WritelnPositionEtTraitDansRapport(posArbre.position,GetTraitOfPosition(posArbre));
			      	WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
			      	WritelnStringAndBooleanDansRapport('meme positions et traits = ',SamePositionEtTrait(posArbre,positionEtTrait));
			      	WritelnStringAndNumDansRapport('scorePourNoir = ',scorePourNoir);
			      	if GenreDeReflexionInSet(genreRefl,[ReflGagnant,ReflRetrogradeGagnant])
			      	  then WritelnDansRapport('genreRefl = gagnant/perdant')
			      	  else WritelnDansRapport('genreRefl = score exact');
			      	WritelnStringAndBoolDansRapport('OK = ',OK);
			      	WritelnDansRapport('');
	      	  end;
	      	
	      	if OK & SamePositionEtTrait(posArbre,positionEtTrait)
	      	  then 
	      	    begin
	      	      AjoutePropertyValeurExacteCoupDansGameTree(genreRefl,scorePourNoir,G);
	      	      if EstVisibleDansFenetreArbreDeJeu(G) then
	      	        begin
	      	          EffaceNoeudDansFenetreArbreDeJeu;
	      	          EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
	      	        end;
	      	    end
	      	  else
	      	    begin
	      	      SysBeep(0);
	      	      WritelnDansRapport('ASSERT( OK & SamePositionEtTrait(posArbre,positionEtTrait)) dans AjouteScoreToEndgameTree');
	      	    end;
        end;
    end;
end;

procedure AnnonceRechercheDansRapport(bestmodeArriveeDansCoupGagnant : boolean;numeroCoup : SInt32);
var s,s1,s2 : str255;
begin
  if interruptionReflexion = pasdinterruption then
  if not(rechercheDejaAnnonceeDansRapport) & not(demo) then
    if (numeroCoup < (60-kNbCasesVidesPourAnnonceDansRapport)) | 
       GenreDeReflexionInSet(typeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif]) then
      begin
        NumToString(numeroCoup,s1);
        if couleurFinale = pionNoir
          then s2 := ReadStringFromRessource(TextesListeID,7)   {Noir}
          else s2 := ReadStringFromRessource(TextesListeID,8);  {Blanc}
        if bestmodeArriveeDansCoupGagnant 
          then s := ParamStr(ReadStringFromRessource(TextesRapportID,5),s1,s2,'','')   {'Recherche au coup ^0 : finale parfaite'}
          else s := ParamStr(ReadStringFromRessource(TextesRapportID,4),s1,s2,'','');  {'Recherche au coup ^0 : finale gagnante'}
        if GetEffetSpecial() then s := s + ' (effet special)';
        DisableKeyboardScriptSwitch;
        FinRapport;
        TextNormalDansRapport;
        WritelnDansRapport('');
        
        ChangeFontSizeDansRapport(gCassioRapportBoldSize);
        ChangeFontDansRapport(gCassioRapportBoldFont);
        
        ChangeFontFaceDansRapport(bold);
        WritelnStringDansRapportSansRepetition(s,chainesDejaEcrites);
        TextNormalDansRapport;
        EnableKeyboardScriptSwitch;
        rechercheDejaAnnonceeDansRapport := true;
      end;
end;

procedure MeilleureSuiteDansRapport(score : SInt32);
var s : str255;
begin
  if not(demo) then
    begin
      s := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,((deltaFinaleCourant<kDeltaFinaleInfini)|not(bestMode)),score);
      if deltaFinaleCourant<kDeltaFinaleInfini
        then s := s+'    '+DeltaFinaleEnChaine(deltaFinaleCourant);
      EnleveEspacesDeGaucheSurPlace(s);
      
      if affichageReflexion.afficherToutesLesPasses | debuggage.algoDeFinale |
        (deltaFinaleCourant=kDeltaFinaleInfini) then
        begin
          AnnonceRechercheDansRapport(bestmodeArriveeDansCoupGagnant,noCoupRecherche);
          DisableKeyboardScriptSwitch;
          FinRapport;
          TextNormalDansRapport;
          WritelnStringDansRapportSansRepetition('  '+s,chainesDejaEcrites);
          EnableKeyboardScriptSwitch;
        end;
    end;
end;

procedure MetInfosTechniquesDansRapport;
var s,s1,s2,s3 : str255;
    nbMinutes,aux : SInt32;
begin
  if rechercheDejaAnnonceeDansRapport then
   if (interruptionReflexion = pasdinterruption) then 
     if not(demo) then
     begin
       tempsGlobalDeLaFonction := TickCount()-tempsGlobalDeLaFonction;
       if tempsGlobalDeLaFonction=0 then tempsGlobalDeLaFonction := 1;
       nbMinutes := tempsGlobalDeLaFonction div 3600;
       if nbMinutes<=0 
         then
           begin
             GetIndString(s,TextesRapportID,15);
             s := ParamStr(s,ReelEnString(1.0*tempsGlobalDeLaFonction/60),'','','');
           end
         else
           if nbMinutes>=60
             then
               begin
                 GetIndString(s,TextesRapportID,13);
                 NumToString(nbMinutes div 60,s1);
                 NumToString(nbMinutes mod 60,s2);
                 NumToString((tempsGlobalDeLaFonction-nbMinutes*3600) div 60,s3);
                 s := ParamStr(s,ReelEnString(1.0*tempsGlobalDeLaFonction/60),s1,s2,s3);
               end
             else
               begin
                 GetIndString(s,TextesRapportID,14);
                 NumToString(nbMinutes,s2);
                 NumToString((tempsGlobalDeLaFonction-nbMinutes*3600) div 60,s3);
                 s := ParamStr(s,ReelEnString(1.0*tempsGlobalDeLaFonction/60),s2,s3,'');
               end;
       DisableKeyboardScriptSwitch;
       FinRapport;
       TextNormalDansRapport;
       WritelnDansRapport('  '+s);
       EnableKeyboardScriptSwitch;
     
       {
       s1 := '';
       if nbreToursNoeudsGeneresFinale>0 then
         begin
           if nbreToursNoeudsGeneresFinale>1 
             then
	             begin
	               NumToString(nbreToursNoeudsGeneresFinale,s1);
	               s1 := s1 + ' * ';
	               s1 := Stringof('( ') + s1 + '2 147 483 647 ) + ';
	             end
	           else
               s1 := '2 147 483 647 + '
         end;
       NumToString(nbreNoeudsGeneresFinale,s);
       }
       s := BigNumEnString(nbreToursNoeudsGeneresFinale,nbreNoeudsGeneresFinale);
       s := SeparerLesChiffresParTrois(s);
       s := ReadStringFromRessource(TextesRapportID,12)+StringOf(' ')+s;
       WritelnDansRapport('  '+s);
       
       if nbreToursNoeudsGeneresFinale=0 
         then 
           WritelnStringAndNumEnSeparantLesMilliersDansRapport('  nb nœuds/sec = ',60*(nbreNoeudsGeneresFinale div tempsGlobalDeLaFonction))
         else
           begin
             aux := nbreToursNoeudsGeneresFinale*(1000000000 div tempsGlobalDeLaFonction);
             aux := aux + (nbreNoeudsGeneresFinale div tempsGlobalDeLaFonction);
             WritelnStringAndNumEnSeparantLesMilliersDansRapport('  nb nœuds/sec = ',60*aux);
           end;  
     end;
end;


procedure RemplirMeilleureSuiteAvecHashTable(var whichPlat : plateauOthello;trait,scorePourNoir,premierCoupDeLaSuite,profondeur,genreRefl,deltaDeXCourant : SInt32);
var positionEtTrait : PositionEtTraitRec;
    coupLegal,trouve,confirmationScore,debugage : boolean;
    coup,nbCoupsDeLaSuite : SInt32;
    profondeurCourante,i : SInt32;
    minProfondeurRemplissage : SInt32;
    nroTableExacte,myClefExacte : SInt32;
    quelleHashTableExacte:HashTableExactePtr;
    codagePosition:codePositionRec;
    copieDeClefHashage : SInt32;
    valMinNoir,valMaxNoir : SInt32;
begin  {$UNUSED i}
  debugage := false;
  
  if (premierCoupDeLaSuite<11) | (premierCoupDeLaSuite>88) | (profondeur<=1)
    then exit(RemplirMeilleureSuiteAvecHashTable);
    
  {WritelnDansRapport('entrée dans RemplirMeilleureSuiteAvecHashTable');
   WritelnDansRapport('tapez une touche…');
   AttendFrappeClavier;
  }
    
  positionEtTrait := MakePositionEtTrait(whichPlat,trait);
  nbCoupsDeLaSuite := 0;
  profondeurCourante := profondeur;
  minProfondeurRemplissage := 0;
  coup := premierCoupDeLaSuite;
  
  copieDeClefHashage := SetClefHashageGlobale(gClefHashage);
  
  for i := 0 to profondeur do 
    begin
      {WritelnStringAndNumDansRapport('mise a zero : ',i);}
      meilleureSuite[profondeur,i] := 0;
    end;
	
  repeat
  
    gClefHashage := BXOR(gClefHashage , IndiceHash^^[GetTraitOfPosition(positionEtTrait),coup]);
    inc(nbCoupsDeLaSuite);
    
    {WritelnStringAndCoupDansRapport('coup = ',coup);
    WritelnStringAndNumDansRapport('nb vides = ',profondeurCourante);
    WritelnStringAndNumDansRapport('nbCoupsDeLaSuite = ',nbCoupsDeLaSuite);
    WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));}
    
    nroTableExacte := BAND(gClefHashage div 1024,nbTablesHashExactesMoins1);
    myClefExacte := BAND(gClefHashage,1023);
    quelleHashTableExacte := HashTableExacte[nroTableExacte];
    CreeCodagePosition(positionEtTrait.position,GetTraitOfPosition(positionEtTrait),profondeurCourante,codagePosition);
    trouve := InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,gClefHashage,myClefExacte);
    {WritelnStringAndBooleenDansRapport('trouvé = ',trouve);}
    
    if trouve then 
      begin
        
        GetEndgameValuesInHashTableElement(quelleHashTableExacte^[myClefExacte],deltaDeXCourant,valMinNoir,valMaxNoir);
        confirmationScore := ScoreFinalEstConfirmeParValeursHashExacte(genreRefl,scorePourNoir,valMinNoir,valMaxNoir);
        
        if debugage then 
          begin
            WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
		        WritelnStringAndNumDansRapport('valMinNoir = ',valMinNoir);
		        WritelnStringAndNumDansRapport('scorePourNoir = ',scorePourNoir);
		        WritelnStringAndNumDansRapport('valMaxNoir = ',valMaxNoir);
		        WritelnStringAndBoolDansRapport('  =>  confirmationScore = ',confirmationScore);
		        WritelnDansRapport('');
		      end;
        
        if not(confirmationScore) then
          begin
            meilleureSuite[profondeur,profondeurCourante+1] := 0;
            inc(minProfondeurRemplissage);
          end;
        
        coup := GetBestDefenseDansHashExacte(quelleHashTableExacte^[myClefExacte]);
        coupLegal := UpdatePositionEtTrait(positionEtTrait,coup);
        
        if coupLegal & confirmationScore then 
          begin
            {WriteStringAndNumDansRapport('remplissage : meilleureSuite[',profondeur);
            WriteStringAndNumDansRapport(',',profondeurCourante);
            WritelnStringAndCoupDansRapport('] = ',coup);}
            
            meilleureSuite[profondeur,profondeurCourante] := coup;
            minProfondeurRemplissage := profondeurCourante;
          end;
        
        {WritelnStringAndBooleenDansRapport('coup légal = ',coupLegal);}
      end;
    {WritelnDansRapport('');}
    {AttendFrappeClavier;}
    
    dec(profondeurCourante);
    
  until not(coupLegal) | not(confirmationScore) | not(trouve) | (coup<11) | (coup>88);
 
 {WritelnStringAndNumDansRapport('minProfondeurRemplissage=',minProfondeurRemplissage);}
 for i := 1 to minProfondeurRemplissage - 1 do 
   begin
     {WritelnStringAndNumDansRapport('mise a zero : ',i);}
     meilleureSuite[profondeur,i] := 0;
   end;
 
 gClefHashage := copieDeClefHashage;
 TesterClefHashage(copieDeClefHashage,'RemplirMeilleureSuiteAvecHashTable');
 
end;


function CompleteMeilleureSuite(miniprof : SInt32; var whichPlat : plateauOthello; coulDefense,WhichNbBlanc,WhichNbNoir,scorePourVerif : SInt32) : boolean;
var platCompl : PositionEtTraitRec;
    platComplEndgame:plOthEndgame;
    nBlaCompl,nNoiCompl : SInt32;
    scoreSuite,coup,p,i,pere,bidBestSuite : SInt32;
    valminPourNoir,valMaxPourNoir : SInt32;
    coupPossible,partieEstFinie,probleme : boolean;
    s,s1,s2 : str255;
    profondeurMinRelaisParBitboardHash : SInt32;
    profondeurMaxRelaisParBitboardHash : SInt32;
    essayerAvecBitboardHash : boolean;
label TRY_AGAIN;
begin

 essayerAvecBitboardHash := true;

 TRY_AGAIN :
 
    probleme := true;
     
    if (interruptionReflexion = pasdinterruption) then   
      begin   
        probleme := false;
        
        if miniprof >= (profForceBrute+1)
          then for i := 1 to profForceBrute do meilleureSuite[miniprof,i] := 0
          else for i := 1 to miniprof-1 do meilleureSuite[miniprof,i] := 0;

        platCompl := MakePositionEtTrait(whichPlat,coulDefense);
        nBlaCompl := WhichNbBlanc;
        nNoiCompl := WhichNbNoir;
        
        
        profondeurMinRelaisParBitboardHash :=  1000;
        profondeurMaxRelaisParBitboardHash := -1000;
        p := miniprof+1;
        
        repeat
          p := p-1;
          coup := meilleuresuite[miniprof,p];
          
          coupPossible := false;
          if (coup >= 11) & (coup <= 88) then
            if (platCompl.position[coup] = pionVide) then
              coupPossible := UpdatePositionEtTrait(platCompl,coup);
          
          
          if not(coupPossible) & essayerAvecBitboardHash then
            if GetEndgameValuesInBitboardHashTableForThisPosition(platCompl,valMinPourNoir,valMaxPourNoir,coup) then
              begin
                if (valMinPourNoir = valMaxPourNoir) & (valMinPourNoir = scorePourVerif) & 
                   (coup >= 11) & (coup <= 88) & (platCompl.position[coup] = pionVide) then
                    begin
                      coupPossible := UpdatePositionEtTrait(platCompl,coup);
                      if coupPossible then 
                        begin
                          meilleuresuite[miniprof,p] := coup;
                          
                          if (p >= profondeurMaxRelaisParBitboardHash) then profondeurMaxRelaisParBitboardHash := p;
                          if (p <= profondeurMinRelaisParBitboardHash) then profondeurMinRelaisParBitboardHash := p;
                          
                          {WritelnDansRapport('La table de hachage bitboard prend le relais... '+CoupEnString(coup,true)+'['+ NumEnString(valMinPourNoir)+','+NumEnString(valMaxPourNoir)+']');}
                        end;
                    end;
              end;
          
        until (p<=1) | (coup=0) | not(coupPossible);
        
        nBlaCompl := NbPionsDeCetteCouleurDansPosition(pionBlanc,platCompl.position);
        nNoiCompl := NbPionsDeCetteCouleurDansPosition(pionNoir,platCompl.position);
        
        partieEstFinie := (GetTraitOfPosition(platCompl) = pionVide);
            
        if not(partieEstFinie) then             
          if not(coupPossible) then
            begin
              if p > profForceBrute then 
                begin
                  probleme := true;
                  
                  WritelnPositionEtTraitDansRapport(whichPlat,coulDefense);
                  for i := miniprof downto p do
                    WritelnStringAndCoupDansRapport('meilleuresuite[miniprof,'+NumEnString(i)+'] = ',meilleuresuite[miniprof,i]);
                  
                  
                  WritelnPositionEtTraitDansRapport(platCompl.position,GetTraitOfPosition(platCompl));
                  GetIndString(s,TextesRapportID,21);    {"problème dans mon algorithme !!"}
                  NumToString(p,s1);
                  s := ParamStr(s,s1,'','','');
                  s := s+' coup impossible à profondeur '+NumEnString(p);
                  WritelnDansRapport(s);
                  AlerteSimple(s);
                end;
              pere := meilleuresuite[miniprof,p+1];
              
              
              (* on essaie de completer la suite en appelant un algo de finale lent,
                 mais qui remplit toujours correctement le tableau meilleureSuite[] *)
              CopyEnPlOthEndgame(platCompl.position,platComplEndgame);
              if GetTraitOfPosition(platCompl) = pionNoir
                then
                  if GetTraitOfPosition(platCompl)=coulDefense
                    then scoreSuite := -ABFinPetitePourSuite(platComplEndgame,bidBestSuite,GetTraitOfPosition(platCompl),p,
                                                           -noteMax,noteMax,nNoiCompl-nBlaCompl,false)
                    else scoreSuite := ABFinPetitePourSuite(platComplEndgame,bidBestSuite,GetTraitOfPosition(platCompl),p,
                                                           -noteMax,noteMax,nNoiCompl-nBlaCompl,false)
                else
                  if GetTraitOfPosition(platCompl)=coulDefense
                    then scoreSuite := -ABFinPetitePourSuite(platComplEndgame,bidBestSuite,GetTraitOfPosition(platCompl),p,
                                                           -noteMax,noteMax,nBlaCompl-nNoiCompl,false)
                    else scoreSuite := ABFinPetitePourSuite(platComplEndgame,bidBestSuite,GetTraitOfPosition(platCompl),p,
                                                           -noteMax,noteMax,nBlaCompl-nNoiCompl,false);
                                                          
              (* on verifie au passage le score de la suite donnee par les tables des hachages *)                                     
              if (Abs(scorePourVerif-scoreSuite) > 1) & (interruptionReflexion = pasdinterruption) then   
                begin
                  
                  if essayerAvecBitboardHash & (p = profondeurMinRelaisParBitboardHash-1) then
                    begin
                      {
                      if not(demo) then
                        WritelnDansRapport('WARNING : la table de hachage bitboard renvoie peut-être une ligne avec un score incorrect, je recalcule sans elle…');
                      WritelnStringAndNumDansRapport('p = ',p);
                      WritelnStringAndNumDansRapport('profondeurMinRelaisParBitboardHash = ',profondeurMinRelaisParBitboardHash);
                      }
                      essayerAvecBitboardHash := false;
                      goto TRY_AGAIN;
                    end;
                
                  probleme := true;
                  NumToString(scorePourVerif,s1);
                  NumToString(scoreSuite,s2);
                  GetIndString(s,TextesRapportID,22);  
                  s := ParamStr(s,s1,s2,'','');
                  WritelnDansRapport(s);
                  
                  AlerteSimple(s);
                  
                  NumToString(nBlaCompl,s);
                  NumToString(nNoiCompl,s1);
                  s := '(nBlaCompl='+s+'  et nNoiCompl='+s1+StringOf(')');
                  WritelnDansRapport(s);
                  if (pere >= 11) & (pere <= 88) 
                    then s := CoupEnString(pere,true)
                    else NumToString(pere,s);
                  if GetTraitOfPosition(platCompl) = pionNoir  then s1 := 'Noir' else
                  if GetTraitOfPosition(platCompl) = pionBlanc then s1 := 'Blanc' else
                    NumToString(GetTraitOfPosition(platCompl),s1);
                  s := '(pere='+s+'  et AquiCompl='+s1+StringOf(')');
                  WritelnDansRapport(s);
                  NumToString(p,s);
                  s := '(prof='+s+StringOf(')');
                  WritelnDansRapport(s);
                  WritelnPositionEtTraitDansRapport(platComplEndgame,GetTraitOfPosition(platCompl));
                end;
              
              (* tout a l'air bon, hein *)
              for i := p downto 1 do
                meilleureSuite[miniprof,i] := meilleureSuite[p,i];
            
            end;
        end;
  
  CompleteMeilleureSuite := not(probleme);
end;


procedure GestionMeilleureSuite(ProfRecherche : SInt32; var jeu : plateauOthello;couleur,nbBla,nbNoi,
                                valXY,XCourant,deltaDeXCourant,nroCoup,nbreCoupsLegaux : SInt32;xCourantEstLeMeilleurCoup : boolean);
var message,i,scoreOptimalPourNoir : SInt32;
    oldStatut,positionDuCoup : SInt32;
    suiteEstComplete,OK,suiteEstLegale : boolean;
    s : str255;
    P1,P2 : PositionEtTraitRec;
    G : GameTree;
    oldMeilleureSuiteInfos:MeilleureSuiteInfosRec;
    oldMeilleureSuite : str255;
begin
  {WritelnStringDansRapportSansRepetition('Entrée dans GestionMeilleureSuite, XCourant = '+CoupEnStringEnMajuscules(XCourant) + ', valXY = '+NumEnString(valXY),chainesDejaEcrites);}
  
  if ValeurDeFinaleInexploitable(valXY) then
    exit(GestionMeilleureSuite);
  
  if analyseRetrograde.EnCours & 
     {(analyseRetrograde.genreAnalyseEnCours=ReflRetrogradeParfait) &}
     (XCourant=coupDontLeScoreEstConnu) then
   exit(GestionMeilleureSuite);
   
  message := pasdemessage;
  if (valXY>0) & (valeurCible=0) & (not(bestMode) | passeDeRechercheAuMoinsValeurCible) then message := messageEstGagnant;
  if (valXY=0) & (valeurCible=0) & (not(bestMode) | passeDeRechercheAuMoinsValeurCible) then message := messageFaitNulle;
  if (valXY<0) & (valeurCible=0) & (not(bestMode) | passeDeRechercheAuMoinsValeurCible) then
    if (nroCoup < nbreCoupsLegaux) | (analyseIntegraleDeFinale {& (deltaDeXCourant<kDeltaFinaleInfini)})
      then message := messageEstPerdant
      else message := messageToutEstPerdant;
  
  
          
  if bestMode & not(passeDeRechercheAuMoinsValeurCible) & 
     (deltaFinaleCourant=kDeltaFinaleInfini) & not(ValeurDeFinaleInexploitable(valXY))
    then 
      begin
        {WritelnStringAndNumDansRapport('appel de CompleteMeilleureSuite, valXY = ',valXY);}
        suiteEstLegale := CompleteMeilleureSuite(ProfRecherche,jeu,couleur,nbBla,nbNoi,valXY);
        suiteEstComplete := true;
      end
    else 
      begin
        {WritelnDansRapport('appel de RemplirMeilleureSuiteAvecHashTable');}
        if CoulPourMeilleurFin = pionNoir
			    then scoreOptimalPourNoir := valXY
			    else scoreOptimalPourNoir := -valXY;
			  
			  if bestmode
          then RemplirMeilleureSuiteAvecHashTable(jeu,couleur,scoreOptimalPourNoir,XCourant,profRecherche,ReflParfait,deltaDeXCourant)
          else RemplirMeilleureSuiteAvecHashTable(jeu,couleur,scoreOptimalPourNoir,XCourant,profRecherche,ReflGagnant,deltaDeXCourant);
        suiteEstComplete := false;
        suiteEstLegale := true;
      end;
     
  for i := profRecherche downto 1 do 
    suiteJouee[i] := meilleureSuite[ProfRecherche,i];
    
  if (interruptionReflexion = pasdinterruption) then
    begin
    
      
      {on sauvegarde l'ancienne meilleure suite affichee, a tout hasard}
      GetMeilleureSuiteInfos(oldMeilleureSuiteInfos);
      oldMeilleureSuite := GetMeilleureSuite();
      
      
    
      FabriqueMeilleureSuiteInfos(XCourant,suiteJouee,@meilleureSuite,couleur,jeu,nbBla,nbNoi,message);
		  SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,not(suiteEstComplete),valXY));
		  if (deltaDeXCourant < kDeltaFinaleInfini)
		    then SetMeilleureSuite(GetMeilleureSuite() + '   ' + DeltaFinaleEnChaine(deltaDeXCourant));
		    
		  if afficheMeilleureSuite & not(analyseIntegraleDeFinale) & not(CassioEstEnModeAnalyse() & meilleureSuiteAEteCalculeeParOptimalite)
		    then EcritMeilleureSuite;
		  
		  if bestMode | (valXY>=0) | 
		    (message=messageToutEstPerdant) | 
		    (message=messageToutEstProbablementPerdant) |
		    ((typeCalculFinale = ReflGagnantExhaustif) & analyseIntegraleDeFinale) then 
		    if commentaireDansRapport then
		      begin
		        if analyseIntegraleDeFinale
		          then
		            begin
		              MeilleureSuiteDansRapport(valXY);
		            end
		          else
		            begin
		              if (ProfRecherche+1 > kNbCasesVidesPourAnnonceDansRapport)
		                then MeilleureSuiteDansRapport(valXY);
		            end;
		      end;
		      
		  if EndgameTreeEstValide(numeroEndgameTreeActif) &
		     (xCourantEstLeMeilleurCoup | GenreDeReflexionInSet(typeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif])) &
		     (deltaFinaleCourant = kDeltaFinaleInfini) &
		     (suiteEstComplete | not(bestmode)) & suiteEstLegale &
		     (interruptionReflexion = pasdinterruption) then
		    begin
		      G := GetActiveNodeOfEndgameTree(numeroEndgameTreeActif);
		    
		      if (G <> NIL) then
		        begin
			      
			      P1 := MakePositionEtTrait(jeu,couleur);
			      OK := GetPositionEtTraitACeNoeud(G,P2);
			      
			      if not(OK) then
			        begin
			          WritelnDansRapport('WARNING : NOT(GetPositionEtTraitACeNoeud(G,P2)) dans GestionMeilleureSuite');
			          SysBeep(0);
			        end;
			      
			      if GetTraitOfPosition(P2) = pionNoir
			        then scoreOptimalPourNoir := valXY
			        else scoreOptimalPourNoir := -valXY;
			      
			      
			      oldStatut := GetStatutMeilleureSuite();
		        if (oldStatut = ToutEstPerdant) | (oldStatut = ToutEstProbablementPerdant) then 
		          if scoreOptimalPourNoir > 0
		            then SetStatutMeilleureSuite(VictoireNoire)
		            else SetStatutMeilleureSuite(VictoireBlanche);
			      s := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0);
			      positionDuCoup := Pos(CoupEnString(XCourant,CassioUtiliseDesMajuscules),s);
			      s := TPCopy(s,positionDuCoup,255);
			      positionDuCoup := Pos(CoupEnString(XCourant,CassioUtiliseDesMajuscules),s);
			      SetStatutMeilleureSuite(oldStatut);
			      
			      (*
			      WritelnDansRapport('');
			      WritelnPositionEtTraitDansRapport(P1.position,P1.trait);
			      WritelnPositionEtTraitDansRapport(P2.position,P2.trait);
			      WritelnStringAndBooleanDansRapport('meme positions et traits = ',SamePositionEtTrait(P1,P2));
			      WritelnStringAndCoupDansRapport('XCourant = ',XCourant);
			      WritelnStringAndNumDansRapport('couleur = ',couleur);
			      WritelnStringAndNumDansRapport('valXY = ',valXY);
			      WritelnStringAndNumDansRapport('scoreOptimalPourNoir = ',scoreOptimalPourNoir);
			      WritelnDansRapport('j''essaie de mettre la meilleure suite suivante dans l''arbre :');
			      WritelnDansRapport(s);
			      WritelnStringAndNumDansRapport('positionDuCoup = ',positionDuCoup);
			      WritelnDansRapport('alors que la meilleure suite officielle est :');
			      MeilleureSuiteDansRapport(valXY);
			      WritelnDansRapport('');
			      *)
			      
			      if not(jeuInstantane) then
			        begin
			          if bestmode
			            then AjouteMeilleureSuiteDansGameTree(ReflParfait, s, scoreOptimalPourNoir, G, false, kNewMovesVirtual)
			            else AjouteMeilleureSuiteDansGameTree(ReflGagnant, s, scoreOptimalPourNoir, G, false, kNewMovesVirtual);
			        end;
			      if EstVisibleDansFenetreArbreDeJeu(G) then
			        begin
			          EffaceNoeudDansFenetreArbreDeJeu;
			          EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
			        end;
			        
			    end;
		    end;
		    
		  {si xCourantEstEnTete est faux, cela veut dire que l'on
       veut simplement afficher la suite du coup courant dans
       le rapport sans changer la 'vraie' meilleure suite : on
       encadre la gestion de la suite du coup courant}
		  if not(xCourantEstLeMeilleurCoup) | analyseIntegraleDeFinale then
        begin 
          SetMeilleureSuiteInfos(oldMeilleureSuiteInfos);
          SetMeilleureSuite(oldMeilleureSuite);
        end;
        
    end;
      
  
  
end;


function CalculMilieuDePartie(nbNiveauxMilieu,alpha,beta : SInt32;
                              var plat : plateauOthello; var jouableMilieu : plBool;
                              var defense : SInt32;coup,couleur : SInt32;
                              nbBlancMilieu,nbNoirMilieu : SInt32;
                              var frontMilieu : InfoFrontRec;
                              canDoProbCut : boolean) : SInt32;
var InfosMilieu:InfosMilieuRec;
    copieDeClefHashage : SInt32;
    fenetre:SearchWindow;
    result:SearchResult;
begin

  {$IFC USE_DEBUG_STEP_BY_STEP}
  with gDebuggageAlgoFinaleStepByStep do
    begin
      positionsCherchees := MakeEmptyPositionEtTraitSet();
      actif := true;
      profMin := 8;
      if actif then AjouterPositionsDevantEtreDebugueesPasAPas(positionsCherchees);
    end;
  {$ENDC}

  if (interruptionReflexion = pasdinterruption)
    then
      begin
        SetLargeurFenetreProbCut;
        
        copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);
        
        profondeurArretPreordre := MFniv-nbNiveauxMilieu;
        profondeurDepartPreordre := MFniv;
  
        with InfosMilieu do
			    begin
			      frontiere := frontMilieu;
			      jouable  := jouableMilieu;
			      nbBlancs := nbBlancMilieu;
			      nbNoirs  := nbNoirMilieu;
			    end;
			  
			  
			  fenetre := MakeSearchWindow(MakeSearchResultFromHeuristicValue(alpha),MakeSearchResultFromHeuristicValue(beta));
			  result := ABPreOrdre(plat,InfosMilieu,defense,coup,couleur,profondeurDepartPreordre,fenetre,canDoProbCut);
			  CalculMilieuDePartie := SearchResultEnMidgameEval(result);
			  
			  TesterClefHashage(copieDeClefHashage,'CalculMilieuDePartie');
			  
      end
    else
      CalculMilieuDePartie := -6400;
      
      
      
  {$IFC USE_DEBUG_STEP_BY_STEP}
  with gDebuggageAlgoFinaleStepByStep do
    DisposePositionEtTraitSet(positionsCherchees);
  {$ENDC}
      
end;

procedure AfficheClassementPreordre;
begin
  if (interruptionReflexion = pasdinterruption) then
    begin
		  if (coulPourMeilleurFin=aQuiDeJouer)
		    then EcritAnnonceFinaleDansMeilleureSuite(typeCalculFinale,noCoupRecherche,kDeltaFinaleInfini);
		  if doitEcrireReflexFinale then
		    case typeCalculFinale of
		       ReflGagnant,ReflRetrogradeGagnant,ReflGagnantExhaustif:
		         SetValReflex(classement,MFniv,nbCoup,nbCoup,ReflAnnonceGagnant,noCoupRecherche,MaxInt,couleurFinale);
		       ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif:
		         SetValReflex(classement,MFniv,nbCoup,nbCoup,ReflAnnonceParfait,noCoupRecherche,MaxInt,couleurFinale);
		       otherwise
		         SetValReflex(classement,MFniv,nbCoup,nbCoup,ReflAnnonceGagnant,noCoupRecherche,MaxInt,couleurFinale);
		     end;
		  if affichageReflexion.doitAfficher & doitEcrireReflexFinale then EcritReflexion;
		end;
end;

procedure AfficheClassementTriDesCoups(profondeurCettePasse,indexDuCoup : SInt32;affichageImmediat : boolean);
begin
  if (interruptionReflexion = pasdinterruption) then
    begin
		  if (coulPourMeilleurFin=aQuiDeJouer)
		    then EcritAnnonceFinaleDansMeilleureSuite(typeCalculFinale,noCoupRecherche,kDeltaFinaleInfini);
		  if doitEcrireReflexFinale then
		    case typeCalculFinale of
		       ReflGagnant,ReflRetrogradeGagnant,ReflGagnantExhaustif:
		         SetValReflex(classement,profondeurCettePasse,indexDuCoup,nbCoup,ReflTriGagnant,noCoupRecherche,MaxInt,couleurFinale);
		       ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif:
		         SetValReflex(classement,profondeurCettePasse,indexDuCoup,nbCoup,ReflTriParfait,noCoupRecherche,MaxInt,couleurFinale);
		       otherwise
		         SetValReflex(classement,profondeurCettePasse,indexDuCoup,nbCoup,ReflTriGagnant,noCoupRecherche,MaxInt,couleurFinale);
		     end;
		  if affichageReflexion.doitAfficher & doitEcrireReflexFinale then 
		    if affichageImmediat
		      then EcritReflexion
		      else LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant));
		  {SysBeep(0);
		  AttendFrappeClavier;}
		end;
end;

procedure TrierClassementAuTemps(var classement : ListOfMoveRecords;indexMin,indexMax : SInt32);
var k,t,maxClefDeTri,indexDuMaximum : SInt32;
    tempElement : MoveRecord;
begin
  if indexMin<indexMax then
    begin
      {tri par extraction suivant le notePourLeTri decroissant}
      for k := indexMin to indexMax do
        begin
          maxClefDeTri := classement[k].notePourLeTri;
          for t := k+1 to indexMax do
            if classement[t].notePourLeTri > maxClefDeTri then
              begin
                maxClefDeTri := classement[t].notePourLeTri;
                indexDuMaximum := t;
              end;
          if maxClefDeTri > classement[k].notePourLeTri then
            begin
              tempElement := classement[k];
              classement[k] := classement[indexDuMaximum];
              classement[indexDuMaximum] := tempElement;
            end;
        end;
    end;
end;


procedure TrierClassementSiMeilleureSuiteAEteCalculeeParOptimalite(var classement : ListOfMoveRecords;nbCoup : SInt32);
var coupAMettreEnTete : SInt32;
    i,k : SInt32;
    temp : MoveRecord;
begin
  if meilleureSuiteAEteCalculeeParOptimalite then
    begin
       coupAMettreEnTete := GetBestMoveAttenteAnalyseDeFinale();
       if (coupAMettreEnTete >= 11) & (coupAMettreEnTete <= 88) then
         begin
           for i := 1 to nbCoup do
             if (classement[i].x = coupAMettreEnTete) then
               begin
                 temp := classement[i];
                 for k := i downto 2 do classement[k] := classement[k-1];
                 classement[1] := temp;
                 exit(TrierClassementSiMeilleureSuiteAEteCalculeeParOptimalite);
               end;
         end;
     end;
end;


procedure PassePreordonnancementDesCoups(profondeurDeCettePasse : SInt32;canDoProbCut : boolean);
var i,iCourant,alpha,beta : SInt32;
    tickChronoPreordre,meilleurCoupDapresPreodre : SInt32;
    coupLegal : boolean;
begin
  AfficheClassementTriDesCoups(profondeurDeCettePasse,nbCoup,true);
  maxPourOrdonnancement := -320000;
  meilleurCoupDapresPreodre := 0;
  for i := 1 to nbCoup do
    if (interruptionReflexion = pasdinterruption) then   
      begin
         tickChronoPreordre := TickCount();
         iCourant := classement[i].x;

         platClass := jeu;
         jouableClass := empl;
         nbBlancClass := nbBl;
         nbNoirClass := nbNo;
         frontClass := frontiereFinale;
         coupLegal := ModifPlatLongint(iCourant,coulPourMeilleurFin,platClass,jouableClass,
                                       nbBlancClass,nbNoirClass,frontClass);
         
         EnleverDeLaListeChaineeDesCasesVides(iCourant);
         
         {
         noteClass := -Evaluation(platClass,Couldefense,nbBlancClass,nbNoirClass,
                             jouableClass,frontClass,false,-30000,30000,bdilong);            
         }
         if profondeurDeCettePasse <= 1
           then
             begin
               alpha := -6400;
               beta := 6400;
             end
           else
             begin
               alpha := Max(maxPourOrdonnancement,-6400);
               beta := 6400;
             end;
         if alpha <= -6400
           then
             begin
                noteclass := -CalculMilieuDePartie(profondeurDeCettePasse,-beta,-alpha,platClass,jouableClass,defense,
                                                 iCourant,coulDefense,nbBlancClass,nbNoirClass,frontClass,canDoProbCut);
             end
           else
             begin
                noteclass := -CalculMilieuDePartie(profondeurDeCettePasse,-alpha-1,-alpha,platClass,jouableClass,defense,
                                                 iCourant,coulDefense,nbBlancClass,nbNoirClass,frontClass,canDoProbCut);
                if (alpha<noteclass) & (noteclass<beta) & (interruptionReflexion = pasdinterruption) then 
                  begin
                    noteclass := -CalculMilieuDePartie(profondeurDeCettePasse,-beta,-noteclass,platClass,jouableClass,defense,
                                                     iCourant,coulDefense,nbBlancClass,nbNoirClass,frontClass,canDoProbCut);
                    if noteclass <= alpha+1 then noteclass := alpha;
                  end;
             end;          
         RemettreDansLaListeChaineeDesCasesVides(iCourant);
         
         
         
         if (BAND(gVecteurParite,constanteDeParite[iCourant]) <> 0) & not(utilisationNouvelleEval)
           then noteclass := noteclass + 400; 
           
         if (gNbreVidesCeQuadrantCoupGagnant[numeroQuadrant[iCourant]]=1) then
           if PeutJouerIci(coulDefense,iCourant,jeu) 
             then noteclass := noteclass + 4000;
           
         if utilisationNouvelleEval & (noteclass > 6400)
           then noteclass := 6400;
           
         classement[i].note              := noteclass;     
         classement[i].theDefense        := defense;
         classement[i].temps             := classement[i].temps + (TickCount()-tickChronoPreordre);
         if profondeurDeCettePasse<=2
           then
             begin
               classement[i].noteMilieuDePartie := classement[i].note;
               classement[i].notePourLeTri      := classement[i].noteMilieuDePartie;
             end
           else
             begin
               classement[i].notePourLeTri      := (classement[i].noteMilieuDePartie div 8)  + classement[i].temps;
             end;
         
         if noteclass > maxPourOrdonnancement then 
           begin
             maxPourOrdonnancement := noteclass;
             meilleurCoupDapresPreodre := iCourant;
           end;
         {tri par insertion de classement suivant le temps et la note de milieu de partie}
         TrierClassementAuTemps(classement,1,i);
         AfficheClassementTriDesCoups(profondeurDeCettePasse,i,true);             
      end;
  
  if (interruptionReflexion = pasdinterruption) then
    begin
      {on donne un bonus au meilleur coup pour le tri, pour etre sur qu'il sera en tete}
      for i := 1 to nbCoup do
        if classement[i].x = meilleurCoupDapresPreodre then
          classement[i].notePourLeTri := classement[i].notePourLeTri + 20000;  
      TrierClassementAuTemps(classement,1,nbCoup);
      AfficheClassementTriDesCoups(profondeurDeCettePasse,nbCoup,true);  
    end;
end;

procedure PreordonnancementDesCoups;
var i,ticks : SInt32;
begin
  estimationPositionDApresMilieu := 0;
  if (MFniv>8) then
    begin
      Calcule_Valeurs_Tactiques(jeu,false);
      LanceChrono;
      LanceChronoCetteProf;
      tempsAlloue := 1000000000;  {pour ne pas se faire interrompre pendant l'ordonnancement}
      
      for i := 1 to nbCoup do 
        begin
          classement[i].note := -3200000;
          classement[i].noteMilieuDePartie := -3200000;
          classement[i].notePourLeTri := -3200000;
          classement[i].delta := kTypeMilieuDePartie;
        end;      
        
        
      ticks:=TickCount();
      PassePreordonnancementDesCoups(1,false);
      PassePreordonnancementDesCoups(3,true);
      
      
      profondeurPreordre := Min(1 + (MFprof div 2),Min((MFprof div 3)+5,10));
     
      { ne pas faire une recherche preliminaire de milieu trop loin 
        dans les positions tres deséquilibrées : c'est inutile... }
      if ( classement[1].note < -5000) | 
         ( classement[1].note > 5000) 
        then profondeurPreordre := Min(profondeurPreordre,6);
        
      { ni si la suite est dans l'arbre ! }
      if not(seMefierDesScoresDeLArbre) & SuiteParfaiteEstConnueDansGameTree() & 
         GenreDeReflexionInSet(typeCalculFinale,[ReflGagnant,ReflParfait,ReflRetrogradeGagnant,ReflRetrogradeParfait])
        then profondeurPreordre := Min(profondeurPreordre,3);
      
      { s'il faut la faire, faut la faire... }
      if (profondeurPreordre > 3) then 
        PassePreordonnancementDesCoups(profondeurPreordre,true);
          
          
      estimationPositionDApresMilieu := 2*(NoteCassioEnScoreFinal(classement[1].note)-32);
      
      {
      if (MFprof >= 25) & utilisationNouvelleEval & InRange(estimationPositionDApresMilieu,-8,8) then
        begin
          profondeurPreordre := 12;
          PassePreordonnancementDesCoups(profondeurPreordre,true);
          estimationPositionDApresMilieu := 2*(NoteCassioEnScoreFinal(classement[1].note)-32);
        end;
      }
      
      if InfosTechniquesDansRapport & commentaireDansRapport & not(demo) & (interruptionReflexion = pasdinterruption) then
        begin
          AnnonceRechercheDansRapport(bestmodeArriveeDansCoupGagnant,noCoupRecherche);
          WriteDansRapport('Temps du tri (prof. '+NumEnString(profondeurPreordre+1) + ') par le milieu = ');
          WriteDansRapport(NumEnString((TickCount()-ticks+30) div 60)+' sec.');
          if utilisationNouvelleEval
            then WriteDansRapport(' Estimation de la position = '+NoteEnString(classement[1].note,true,0,2))
            else WriteStringAndNumDansRapport(' Estimation de la position = ',estimationPositionDApresMilieu);
          WritelnDansRapport(' pions');
        end;
      
        
    end;
  
 if meilleureSuiteAEteCalculeeParOptimalite then 
   TrierClassementSiMeilleureSuiteAEteCalculeeParOptimalite(classement,nbCoup);
  
  AfficheClassementPreordre;
  
end;

function NegaCStar(lower,upper : SInt32;couleur,ProfRecherche,nbBla,nbNoi,XCourant : SInt32;jeu : plateauOthello;
                      var meilleurCoup : SInt32; var InfosMilieuDePartie:InfosMilieuRec) : SInt32;
var v,t,indiceHashDummy : SInt32;
    SuiteOK : boolean;
begin

  FenetreLargePourRechercheScoreExact := false;
  SuiteOK := false;
  repeat
    v := 2*((lower+upper) div 4);
    t := -LanceurABFin(jeu,meilleurCoup,XCourant,couleur,ProfRecherche,
                      -v-1,-v+1,nbBla,nbNoi,indiceHashDummy,InfosMilieuDePartie);
    if t=v then SuiteOK := true;
    if t>=v then lower := t;
    if t<=v then upper := t;
    
    WriteStringAndNumAt('lower=',-upper,10,30);
    WriteStringAndNumAt('upper=',-lower,10,40);
    WriteStringAndNumAt('v=',-v,110,30);
    WriteStringAndNumAt('t=',-t,110,40);
    
  until SuiteOK | (lower>=upper) | ValeurDeFinaleInexploitable(t);
  
  NegaCStar := t;
end;


function Algo_SSSStar(lower,upper : SInt32;couleur,ProfRecherche,nbBla,nbNoi : SInt32;jeu : plateauOthello;
                      var meilleurCoup : SInt32; var InfosMilieuDePartie:InfosMilieuRec) : SInt32;
var v,t,indiceHashDummy : SInt32;
    copieDeClefHashage : SInt32;
begin

  bestMode := false;
  FenetreLargePourRechercheScoreExact := false;
  
  copieDeClefHashage := SetClefHashageGlobale(BXOR(clefHashageCoupGagnant , IndiceHash^^[couleur,dernierCoupJoue]));
  
  t := upper;
  repeat
    v := t;
    t := -LanceurABFin(jeu,meilleurCoup,dernierCoupJoue,couleur,ProfRecherche,-v,-v+1,nbBla,nbNoi,indiceHashDummy,InfosMilieuDePartie);
    EssaieSetPortWindowPlateau;
    WriteStringAndNumAt('SSS* score>=',-t,10,40);
  until (t=v) | (t<=lower) | ValeurDeFinaleInexploitable(t);
        
  TesterClefHashage(copieDeClefHashage,'Algo_SSStar');
        
  Algo_SSSStar := -t;    
end;

function Algo_AlphaBetaBrut(lower,upper : SInt32;couleur,ProfRecherche,nbBla,nbNoi : SInt32;jeu : plateauOthello;
                      var meilleurCoup : SInt32; var InfosMilieuDePartie:InfosMilieuRec) : SInt32;
var t,indiceHashDummy : SInt32;
    copieDeClefHashage : SInt32;
begin

  bestMode := false;
  FenetreLargePourRechercheScoreExact := true;
  
  copieDeClefHashage := SetClefHashageGlobale(BXOR(clefHashageCoupGagnant , IndiceHash^^[couleur,dernierCoupJoue]));
  
  t := -LanceurABFin(jeu,meilleurCoup,dernierCoupJoue,couleur,ProfRecherche,-upper,-lower,nbBla,nbNoi,indiceHashDummy,InfosMilieuDePartie);
  EssaieSetPortWindowPlateau;
  WriteStringAndNumAt('AlphaBeta score=',-t,10,30);
  FenetreLargePourRechercheScoreExact := false;
  
  TesterClefHashage(copieDeClefHashage,'Algo_AlphaBetaBrut');
  
  Algo_AlphaBetaBrut := -t;    
end;



function Algo_NegaCStar(lower,upper : SInt32;couleur,ProfRecherche,nbBla,nbNoi : SInt32;jeu : plateauOthello;
                      var meilleurCoup : SInt32; var InfosMilieuDePartie:InfosMilieuRec) : SInt32;
var t : SInt32;
    copieDeClefHashage : SInt32;
begin

  bestMode := false;
  
  copieDeClefHashage := SetClefHashageGlobale(BXOR(clefHashageCoupGagnant , IndiceHash^^[couleur,dernierCoupJoue]));
  
  t := NegaCStar(lower,upper,couleur,ProfRecherche,nbBla,nbNoi,dernierCoupJoue,jeu,meilleurCoup,InfosMilieuDePartie);
  
  TesterClefHashage(copieDeClefHashage,'Algo_NegaCStar');
        
  Algo_NegaCStar := -t;    
end;




function MinimaxFinale(quelleValeurCible,couleur,MiniProf,longClass,nbBla,nbNoi : SInt32; var jeu : plateauOthello;
                    var empl : plBool; var frontiereMinimax : InfoFrontRec;ClassementAuTempsSiTousMoinsBonsQueValeurCible : boolean;
                    var classementMinimax : ListOfMoveRecords) : SInt32;
var XCourant : SInt32;      
    valXY : SInt32;
    platMod : plateauOthello;
    jouableMod : plBool;
    nbBlancMod,nbNoirMod : SInt32;
    frontMod : InfoFrontRec;
    InfosMod:InfosMilieuRec;
    sortieDeBoucleAcceleree : boolean;
    toutesLesPassesTerminees : boolean;
    peutUtiliserDichotomie : boolean;
    classAux : ListOfMoveRecords;
    tempElementClass : MoveRecord;
    i,j,k,compteur : SInt32;
    indice_du_meilleur : SInt32;
    noteModif : SInt32;
    bestAB,betaAB : SInt32;
    maxConnuSiToutEstMoinsBonQueValeurCible : SInt32;
    TickChronoPourClassaux,TempsDeXCourant : SInt32;
    tempsPourTickChronoPourClassaux : SInt32;
    NoteMilieuDeXCourant,NotePourLeTriDeXCourant : SInt32;
    nbCoupuresHeuristiquesDeXCourant : SInt32;
    AEteEnTete:plOthLongint;
    nbCoupsAyantEteEnTete : SInt32;
    deltaDeXCourantDevientInfini : boolean;
    deltaDeXCourantAvantRecherche : SInt32;
    deltaDeXCourantApresRecherche : SInt32;
    doitAppelerGestionMeilleureSuite : boolean;
    noteAfficheeSurOthellier : SInt32;
    coupLegal : boolean;

label BoucleSurLesFils;


procedure ChangeBestAB(newBestAB : SInt32;fonctionAppelante : str255);
begin {$UNUSED fonctionAppelante}

  if debuggage.algoDeFinale then
    begin
      FinRapport;
		  TextNormalDansRapport;
		  if Pos('init',fonctionAppelante)>0
		    then
		      begin
		        WritelnDansRapport('');
		        WriteDansRapport('init BestAB ');
		      end
		    else 
		      WriteDansRapport('change BestAB ('+fonctionAppelante+') ');
		  if bestAB = -infini
		    then WriteDansRapport('(-∞')
		    else 
		      if (bestAB >= -64) & (bestAB <= 64)
		        then WriteStringAndNumDansRapport('(',bestAB)
		        else WriteDansRapport('(???-ASSERT-???');
		  if betaAB = +infini
		    then WriteDansRapport(', +∞')
		    else 
		      if (betaAB >= -64) & (betaAB <= 64)
		        then WriteStringAndNumDansRapport(', ',betaAB)
		        else WriteDansRapport(', ???-ASSERT-???');
		  WriteDansRapport(')');
		end;
  
  bestAB := newBestAB;
  
  if debuggage.algoDeFinale then
    begin
		  WriteDansRapport(' -> ');
		  if bestAB = -infini
		    then WriteDansRapport('(-∞')
		    else 
		      if (bestAB>=-64) & (bestAB<=64)
		        then WriteStringAndNumDansRapport('(',bestAB)
		        else WriteDansRapport('(???-ASSERT-???');
		  if betaAB = +infini
		    then WriteDansRapport(', +∞')
		    else 
		      if (betaAB>=-64) & (betaAB<=64)
		        then WriteStringAndNumDansRapport(', ',betaAB)
		        else WriteDansRapport(', ???-ASSERT-???');
		  WriteDansRapport(')');
		  WritelnDansRapport(' ['+DeltaFinaleEnChaine(deltaFinaleCourant)+']');
		end;
		
end;

procedure ChangeBetaAB(newBetaAB : SInt32;fonctionAppelante : str255);
begin {$UNUSED fonctionAppelante}

  if debuggage.algoDeFinale then
    begin
      FinRapport;
		  TextNormalDansRapport;
		  if Pos('init',fonctionAppelante)>0
		    then
		      begin
		        WriteDansRapport('init betaAB ');
		      end
		    else 
		      WriteDansRapport('change betaAB ('+fonctionAppelante+') ');
		  if bestAB = -infini
		    then WriteDansRapport('(-∞')
		    else 
		      if (bestAB>=-64) & (bestAB<=64)
		        then WriteStringAndNumDansRapport('(',bestAB)
		        else WriteDansRapport('(???-ASSERT-???');
		  if betaAB = +infini
		    then WriteDansRapport(', +∞')
		    else 
		      if (betaAB>=-64) & (betaAB<=64)
		        then WriteStringAndNumDansRapport(', ',betaAB)
		        else WriteDansRapport(', ???-ASSERT-???');
		  WriteDansRapport(')');
		end;  
  
  betaAB := newBetaAB;
  
  if debuggage.algoDeFinale then
    begin
		  WriteDansRapport(' -> ');
		  if bestAB = -infini
		    then WriteDansRapport('(-∞')
		    else 
		      if (bestAB>=-64) & (bestAB<=64)
		        then WriteStringAndNumDansRapport('(',bestAB)
		        else WriteDansRapport('(???-ASSERT-???');
		  if betaAB = +infini
		    then WriteDansRapport(', +∞')
		    else 
		      if (betaAB>=-64) & (betaAB<=64)
		        then WriteStringAndNumDansRapport(', ',betaAB)
		        else WriteDansRapport(', ???-ASSERT-???');
		  WriteDansRapport(')');
		  WritelnDansRapport(' ['+DeltaFinaleEnChaine(deltaFinaleCourant)+']');
    end;
  
end;

procedure SetNoteDansElementClassement(var classement : ListOfMoveRecords;index,valeur,deltaFinale : SInt32; var tickchrono : SInt32);
begin
  if not(EstLaListeDesCoupsDeFenetreReflexion(classement)) | doitEcrireReflexFinale then
    with classement[index] do
      begin
        note := valeur;
        delta := deltaFinale;
        if (@classement<>@classAux) then
          begin
            temps := temps+(TickCount()-tickchrono);
            tickchrono := TickCount();
          end;
      end;
  if affichageReflexion.doitAfficher & EstLaListeDesCoupsDeFenetreReflexion(classement) 
    then LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant));
end;


function CalculNormal() : SInt32;
var t,bas_fenetre,haut_fenetre,indiceHashDummy : SInt32;
    largeur_fenetre,n,ticks : SInt32;
    copieDeClefHashage : SInt32;
begin
  n := nbreNoeudsGeneresFinale;
  ticks := TickCount();
  
  passeDeRechercheAuMoinsValeurCible := false;
  valeurCible := 0;
  
  copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);
  
  if bestMode & (compteur>1)
    then
      begin
        FenetreLargePourRechercheScoreExact := false;
        t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                    Max(-bestAB-1,-64),Min(-bestAB,64),nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);
                    
        largeur_fenetre := 2;
         
        if not(ValeurDeFinaleInexploitable(t)) then
        if (bestAB<t) & (t<betaAB) then
           repeat
             FenetreLargePourRechercheScoreExact := false;
             SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
             
             FenetreLargePourRechercheScoreExact := true;
             bas_fenetre := t-1;
             haut_fenetre := Min(bas_fenetre+largeur_fenetre,betaAB);
             t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                         Max(-haut_fenetre,-64),Min(-bas_fenetre,64),nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);
             
             largeur_fenetre := 2*largeur_fenetre;
             if largeur_fenetre>16 then largeur_fenetre := 16;
             
           until ((bas_fenetre<t) & (t<haut_fenetre)) | (t>=betaAB) | ValeurDeFinaleInexploitable(t);
        
        {
          begin
            SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
            t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                        Max(-betaAB,-64),Min(-t+1,64),nbBlancMod,nbNoirMod,indiceHashDummy);
          end;
        }
      end
    else
      begin
        FenetreLargePourRechercheScoreExact := false;
        t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                  Max(-betaAB,-64),Min(-bestAB,64),nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod); 
      end;
  CalculNormal := t;
  
  TesterClefHashage(copieDeClefHashage,'CalculNormal(Finale)');
  
  {
  n := nbreNoeudsGeneresFinale-n;
  ticks := TickCount()-ticks;
  WriteStringAndNumAt('nb nœuds/sec=',(n*60) div ticks,30,80);
  }
end;

function SSS_Dual() : SInt32;
var t,bas_fenetre,haut_fenetre,lower,upper : SInt32;
    largeur_fenetre,n,ticks,indiceHashDummy : SInt32;
    copieDeClefHashage : SInt32;
begin
  n := nbreNoeudsGeneresFinale;
  ticks := TickCount();
  
  passeDeRechercheAuMoinsValeurCible := false;
  valeurCible := 0;
  
  copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);
  
  if not(bestMode)
    then
      begin
        FenetreLargePourRechercheScoreExact := false;
        t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
            Max(-betaAB,-64),Min(-bestAB,64),nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod); 
      end
    else
      if compteur=1 
        then 
          begin
            t := NegaCStar(-64,64,coulDefense,MiniProf,nbBlancMod,nbNoirMod,XCourant,platMod,defense,InfosMod);
            
            SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
          end
        else
          begin
            FenetreLargePourRechercheScoreExact := false;
            upper := betaAB;
            lower := Max(-64,bestAB);
            t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                        Max(-lower-1,-64),Min(-lower,64),nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);  
            
            largeur_fenetre := 2;
                                                        
            if not(ValeurDeFinaleInexploitable(t)) then
            if (lower<t) & (t<upper) then
               repeat
                 FenetreLargePourRechercheScoreExact := false;
                 SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
                 
                 FenetreLargePourRechercheScoreExact := true;
                 bas_fenetre := t-1;
                 haut_fenetre := Min(t+largeur_fenetre-1,upper);
                 t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                             Max(-haut_fenetre,-64),Min(-bas_fenetre,64),nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);
                 
                 largeur_fenetre := 2*largeur_fenetre;
                 if largeur_fenetre>16 then largeur_fenetre := 16;
                 
               until ((bas_fenetre<t) & (t<haut_fenetre)) | (t>=upper) | ValeurDeFinaleInexploitable(t);
           end;
  SSS_Dual := t;
      
  TesterClefHashage(copieDeClefHashage,'SSS_Dual');
  
  {
  n := nbreNoeudsGeneresFinale-n;
  ticks := TickCount()-ticks;
  WriteStringAndNumAt('nb nœuds/sec=',(n*60) div ticks,30,80);
  }
end;

function Dicho_first(quelleValeurCible : SInt32;forcerDichotomie : boolean) : SInt32;
var t,bas_fenetre,haut_fenetre,lower,upper : SInt32;
    largeur_fenetre,n,ticks,indiceHashDummy : SInt32;
    copieDeClefHashage : SInt32;
begin
  n := nbreNoeudsGeneresFinale;
  ticks := TickCount();
  
  valeurCible := quelleValeurCible;
  
  copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);
  
  if not(bestMode)
    then
      begin
        FenetreLargePourRechercheScoreExact := false;
        t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,-betaAB,-bestAB,nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod); 
      end
    else
      if passeDeRechercheAuMoinsValeurCible then
        begin
          FenetreLargePourRechercheScoreExact := false;
          lower := -64;
          upper := 64;
          
          t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,-valeurCible-1,-valeurCible+1,nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod); 
          
          if (t>valeurCible) & not(ValeurDeFinaleInexploitable(t)) then
             begin
                largeur_fenetre := 2;
                repeat
	              
  	              classAux[compteur].note := t;
  	              classAux[compteur].delta := deltaFinaleCourant;
  	              if doitEcrireReflexFinale then 
  	                if analyseRetrograde.EnCours
  	                  then 
  	                    SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflRetrogradeParfait,noCoupRecherche,compteur,couleurFinale)
  	                  else 
  	                    if analyseIntegraleDeFinale
  	                      then SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflParfaitExhaustif,noCoupRecherche,compteur,couleurFinale)
  	                      else SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflParfait,noCoupRecherche,compteur,couleurFinale);
  	              SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
  	              
  	              FenetreLargePourRechercheScoreExact := true;
  	              passeDeRechercheAuMoinsValeurCible := false;
  	              bas_fenetre := Max(t-1,lower);
  	              haut_fenetre := Min(bas_fenetre+largeur_fenetre,upper);
  	              
  	              
  	              
  	              
  	              if bas_fenetre>=haut_fenetre then
  	                begin
  	                  SysBeep(0);
  	                  WritelnDansRapport('Problème dans Dicho_first : bas_fenetre>=haut_fenetre (1)');
  	                  WritelnStringAndBoolDansRapport('FenetreLargePourRechercheScoreExact=',FenetreLargePourRechercheScoreExact);
  	                  WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible=',passeDeRechercheAuMoinsValeurCible);
  	                  WritelnStringAndNumDansRapport('valeurCible=',valeurCible);
  	                  WritelnStringAndNumDansRapport('bas_fenetre=',bas_fenetre);
  	                  WritelnStringAndNumDansRapport('haut_fenetre=',haut_fenetre);
  	                  WritelnStringAndNumDansRapport('t=',t);
  	                  WritelnStringAndNumDansRapport('largeur_fenetre=',largeur_fenetre);
  	                  WritelnStringAndNumDansRapport('lower=',lower);
  	                  WritelnStringAndNumDansRapport('upper=',upper);
  	                  WritelnStringAndNumDansRapport('bestAB=',bestAB);
  	                  WritelnStringAndNumDansRapport('betaAB=',betaAB);
  	                  WritelnDansRapport('');
  	                end;
  	              
  	              
  	              t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
  	                           -haut_fenetre,-bas_fenetre,nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);
  	              
  	              largeur_fenetre := 2*largeur_fenetre;
  	              if largeur_fenetre>16 then largeur_fenetre := 16;
  	              
  	           until ({(bas_fenetre<t) &} (t<haut_fenetre)) | (t>=upper) | ValeurDeFinaleInexploitable(t);
             end;
                   
          (* FIXME : je ne comprends pas pourquoi le test suivant fait crasher Cassio :-(  *)
           if not(ValeurDeFinaleInexploitable(t)) then 
          passeDeRechercheAuMoinsValeurCible := (t < valeurCible);
            
        end
        else  {passeDeRechercheAuMoinsValeurCible = false}
          if (compteur=1) | forcerDichotomie
            then 
              begin
                FenetreLargePourRechercheScoreExact := false;
                lower := Max(-64,bestAB);
                upper := Min(betaAB,64);
                
                t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,-valeurCible-1,-valeurCible+1,nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod); 
                
                if odd(t) then if t>valeurCible then t := t+1 else t := t-1;
                
                largeur_fenetre := 2;
                
                if (t>valeurCible) & (t<upper) & not(ValeurDeFinaleInexploitable(t)) then
                    repeat
                    
                    classAux[compteur].note := t;
                    classAux[compteur].delta := deltaFinaleCourant;
                    if doitEcrireReflexFinale then 
                      if analyseRetrograde.EnCours
                        then SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflRetrogradeParfait,noCoupRecherche,compteur,couleurFinale)
                        else 
                          if analyseIntegraleDeFinale
                            then SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflParfaitExhaustif,noCoupRecherche,compteur,couleurFinale)
                            else SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflParfait,noCoupRecherche,compteur,couleurFinale);
                    SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
                    
                    FenetreLargePourRechercheScoreExact := true;
                    bas_fenetre := Max(t-1,lower);
                    haut_fenetre := Min(bas_fenetre+largeur_fenetre,upper);
                    
                    
                    if bas_fenetre>=haut_fenetre then
	                begin
	                  SysBeep(0);
	                  WritelnDansRapport('Problème dans Dicho_first : bas_fenetre>=haut_fenetre (2)');
	                  WritelnStringAndBoolDansRapport('FenetreLargePourRechercheScoreExact=',FenetreLargePourRechercheScoreExact);
	                  WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible=',passeDeRechercheAuMoinsValeurCible);
	                  WritelnStringAndNumDansRapport('valeurCible=',valeurCible);
	                  WritelnStringAndNumDansRapport('bas_fenetre=',bas_fenetre);
	                  WritelnStringAndNumDansRapport('haut_fenetre=',haut_fenetre);
	                  WritelnStringAndNumDansRapport('t=',t);
	                  WritelnStringAndNumDansRapport('largeur_fenetre=',largeur_fenetre);
	                  WritelnStringAndNumDansRapport('lower=',lower);
	                  WritelnStringAndNumDansRapport('upper=',upper);
	                  WritelnStringAndNumDansRapport('bestAB=',bestAB);
	                  WritelnStringAndNumDansRapport('betaAB=',betaAB);
	                  WritelnDansRapport('');
	                end;
                    
                    
                    t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                                -haut_fenetre,-bas_fenetre,nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);
                    
                    largeur_fenetre := 2*largeur_fenetre;
                    if largeur_fenetre>16 then largeur_fenetre := 16;
                    
                  until ({(bas_fenetre<t) &} (t<haut_fenetre)) | (t>=upper) | ValeurDeFinaleInexploitable(t);
                         
                if (t<valeurCible) & (t>lower) & not(ValeurDeFinaleInexploitable(t)) then
                  repeat
                  
                    classAux[compteur].note := t;
                    classAux[compteur].delta := deltaFinaleCourant;
                    if doitEcrireReflexFinale then 
                      if analyseRetrograde.EnCours
                        then SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflRetrogradeParfait,noCoupRecherche,compteur,couleurFinale)
                        else 
                          if analyseIntegraleDeFinale
                            then SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflParfaitExhaustif,noCoupRecherche,compteur,couleurFinale)
                            else SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflParfait,noCoupRecherche,compteur,couleurFinale);
                    SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
                    
                    FenetreLargePourRechercheScoreExact := true;
                    
                    haut_fenetre := Min(t+1,upper);
                    bas_fenetre := Max(haut_fenetre-largeur_fenetre,lower);
                    
                    if bas_fenetre>=haut_fenetre then
	                begin
	                  SysBeep(0);
	                  WritelnDansRapport('Problème dans Dicho_first : bas_fenetre>=haut_fenetre (3)');
	                  WritelnStringAndBoolDansRapport('FenetreLargePourRechercheScoreExact=',FenetreLargePourRechercheScoreExact);
	                  WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible=',passeDeRechercheAuMoinsValeurCible);
	                  WritelnStringAndNumDansRapport('valeurCible=',valeurCible);
	                  WritelnStringAndNumDansRapport('bas_fenetre=',bas_fenetre);
	                  WritelnStringAndNumDansRapport('haut_fenetre=',haut_fenetre);
	                  WritelnStringAndNumDansRapport('t=',t);
	                  WritelnStringAndNumDansRapport('largeur_fenetre=',largeur_fenetre);
	                  WritelnStringAndNumDansRapport('lower=',lower);
	                  WritelnStringAndNumDansRapport('upper=',upper);
	                  WritelnStringAndNumDansRapport('bestAB=',bestAB);
	                  WritelnStringAndNumDansRapport('betaAB=',betaAB);
	                  WritelnDansRapport('');
	                end;
                    
                    
                    t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                                 -haut_fenetre,-bas_fenetre,nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);
                    
                    largeur_fenetre := 2*largeur_fenetre;
                    if largeur_fenetre>16 then largeur_fenetre := 16;
                    
                  until ((bas_fenetre<t) {& (t<haut_fenetre)}) | (t<=lower) | ValeurDeFinaleInexploitable(t);
                         
              end
            else
              begin
                lower := Max(-64,bestAB);
                upper := Min(betaAB,64);
                
                FenetreLargePourRechercheScoreExact := false;
                t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                            Max(-lower-1,-64),Min(-lower,64),nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);  
                 
                largeur_fenetre := 2;
                                                           
                if not(ValeurDeFinaleInexploitable(t)) then
                if (lower<t) & (t<upper) then
                   repeat
                     SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
                     
                     FenetreLargePourRechercheScoreExact := true;
                     bas_fenetre := Max(t-1,lower);
                     haut_fenetre := Min(bas_fenetre+largeur_fenetre,upper);
                     
                     
                     if bas_fenetre>=haut_fenetre then
		                begin
		                  SysBeep(0);
		                  WritelnDansRapport('Problème dans Dicho_first : bas_fenetre>=haut_fenetre (4)');
		                  WritelnStringAndBoolDansRapport('FenetreLargePourRechercheScoreExact=',FenetreLargePourRechercheScoreExact);
		                  WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible=',passeDeRechercheAuMoinsValeurCible);
		                  WritelnStringAndNumDansRapport('valeurCible=',valeurCible);
		                  WritelnStringAndNumDansRapport('bas_fenetre=',bas_fenetre);
		                  WritelnStringAndNumDansRapport('haut_fenetre=',haut_fenetre);
		                  WritelnStringAndNumDansRapport('t=',t);
		                  WritelnStringAndNumDansRapport('largeur_fenetre=',largeur_fenetre);
		                  WritelnStringAndNumDansRapport('lower=',lower);
		                  WritelnStringAndNumDansRapport('upper=',upper);
		                  WritelnStringAndNumDansRapport('bestAB=',bestAB);
		                  WritelnStringAndNumDansRapport('betaAB=',betaAB);
		                  WritelnDansRapport('');
		                end;
                     
                     
                     t := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
                                 -haut_fenetre,-bas_fenetre,nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);
                     
                     largeur_fenetre := 2*largeur_fenetre;
                     if largeur_fenetre>16 then largeur_fenetre := 16;
                     
                   until ({(bas_fenetre<t) &} (t<haut_fenetre)) | (t>=upper) | ValeurDeFinaleInexploitable(t);

               end;
  Dicho_first := t;
      
  TesterClefHashage(copieDeClefHashage,'Dicho_first');
  
  {
  n := nbreNoeudsGeneresFinale-n;
  ticks := TickCount()-ticks;
  WriteStringAndNumAt('nb nœuds/sec=',(n*60) div ticks,30,80);
  }
end;


function CalculParAnalyseDeFinale(alpha,beta : SInt32) : SInt32;
var aux : SInt32;
    indiceHashDummy : SInt32;
    copieDeClefHashage : SInt32;
begin
  passeDeRechercheAuMoinsValeurCible := false;
  valeurCible := 0;
  FenetreLargePourRechercheScoreExact := ((beta - alpha) > 2);
  
  copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);
  
  aux := -LanceurABFin(platMod,defense,XCourant,coulDefense,MiniProf,
              Max(-infini,-beta),Min(infini,-alpha),nbBlancMod,nbNoirMod,indiceHashDummy,InfosMod);
              
  CalculParAnalyseDeFinale := aux;
  
  TesterClefHashage(copieDeClefHashage,'CalculParAnalyseDeFinale');
  
end;


procedure UpdateBestABAvecLeScoreDuCoupConnu(messageHandle:MessageFinaleHdl; var bestAB : SInt32);
var scoreCoupRetrograde : SInt32;
begin
  if messageHandle <> NIL then
    begin
		  scoreCoupRetrograde := messageHandle^^.data[0];
		  if bestAB < scoreCoupRetrograde then
		    ChangeBestAB(scoreCoupRetrograde,'UpdateBestABAvecLeScoreDuCoupConnu');
		  if betaAB <= bestAB then 
		    ChangeBetaAB(succ(bestAB),'UpdateBestABAvecLeScoreDuCoupConnu');
		end;
end;

procedure GetCoupDontLeScoreEstConnu(messageHandle:MessageFinaleHdl; var coupDontLeScoreEstConnu,defenseDuCoupDontLeScoreEstConnu,scoreDuCoupDontLeScoreEstConnu : SInt32);
begin
  if messageHandle <> NIL then
    begin
      scoreDuCoupDontLeScoreEstConnu   := messageHandle^^.data[0]; 
		  coupDontLeScoreEstConnu          := messageHandle^^.data[1];
		  defenseDuCoupDontLeScoreEstConnu := messageHandle^^.data[2];
		  SetCoupEtScoreAnalyseRetrogradeDansReflex(coupDontLeScoreEstConnu,scoreDuCoupDontLeScoreEstConnu);
		end;
end;

procedure EcritClassement(whichClassement : ListOfMoveRecords);
var i : SInt32;
begin
  EssaieSetPortWindowPlateau;
  WriteStringAt('coup='+CoupEnString(coupDontLeScoreEstConnu,true),10,10);
  WriteStringAndNumAt('score connu=',scoreDuCoupDontLeScoreEstConnu,70,10);
  for i := 1 to longClass do
    begin
      WriteStringAndNumAt('i=',i,10,20+10*i);
      WriteStringAt('coup='+CoupEnString(whichClassement[i].x,true),30,20+10*i);
      WriteStringAndNumAt('score=',whichClassement[i].note,80,20+10*i);
      WriteStringAndNumAt('delta=',whichClassement[i].delta,80,20+10*i);
    end;
  for i := 1 to 10 do
    WriteStringAt('                                                 ',10,20+(longClass+i)*10);
end;


procedure EcritClassementDansRapport(whichClassement : ListOfMoveRecords; prompt : str255);
var i : SInt32;
begin
  WritelnDansRapport('');
  if prompt <> '' then WritelnDansRapport(prompt);
  for i := 1 to longClass do
    begin
      WriteStringAndNumDansRapport('i=',i);
      WriteStringAndCoupDansRapport('  coup=',whichClassement[i].x);
      WriteStringAndCoupDansRapport('  def=', whichClassement[i].theDefense);
      WriteStringAndNumDansRapport('  score=',whichClassement[i].note);
      WriteStringAndNumDansRapport('  delta=',whichClassement[i].delta);
      WriteStringAndNumDansRapport('  temps=',whichClassement[i].temps);
      WriteStringAndNumDansRapport('  notePourLeTri=',whichClassement[i].notePourLeTri);
      WritelnDansRapport('');
    end;
  WritelnDansRapport('');
end;

procedure MetCoupConnuEnTete(messageHandle:MessageFinaleHdl; var coupDontLeScoreEstConnu : SInt32; var classAux : ListOfMoveRecords);
var i,k,typeAffichage : SInt32;
    TempoMoveRec : MoveRecord;
begin
  if messageHandle <> NIL then
    begin
		  scoreDuCoupDontLeScoreEstConnu   := messageHandle^^.data[0]; 
		  coupDontLeScoreEstConnu          := messageHandle^^.data[1];
		  defenseDuCoupDontLeScoreEstConnu := messageHandle^^.data[2];
		  SetCoupEtScoreAnalyseRetrogradeDansReflex(coupDontLeScoreEstConnu,scoreDuCoupDontLeScoreEstConnu);
		  
		  k := MaxInt;
		  for i := 1 to longClass do
		    if classAux[i].x=coupDontLeScoreEstConnu then k := i;
		  if (k>1) & (k<=longClass) then
		    begin
		      TempoMoveRec := classAux[k];
		      for i := k downto 2 do classAux[i] := classAux[i-1];
		      classAux[1] := TempoMoveRec;
		    end;
		    
		  classAux[1].note               := scoreDuCoupDontLeScoreEstConnu;
		  classAux[1].theDefense         := defenseDuCoupDontLeScoreEstConnu;
		  classAux[1].delta              := kDeltaFinaleInfini;
		  classAux[1].temps              := 0;
		  classAux[1].notePourLeTri      := 30000000; {histoire qu'il reste en tete si tous les coups sont perdants}
		  classAux[1].noteMilieuDePartie := 30000000; {idem}
		  
		  
		  if (analyseRetrograde.genreAnalyseEnCours=ReflRetrogradeGagnant) | not(bestmodeArriveeDansCoupGagnant)
		    then typeAffichage := ReflRetrogradeGagnant
		    else
		      if bestMode
		        then typeAffichage := ReflRetrogradeParfait
		        else typeAffichage := ReflRetrogradeParfaitPhaseGagnant;
		  if doitEcrireReflexFinale then
		    begin
		      SetValReflexFinale(classAux,MFniv,longClass,longClass,typeAffichage,noCoupRecherche,MaxInt,couleurFinale);{pour copier classAux}
		      SetValReflexFinale(classAux,MFniv,1,longClass,typeAffichage,noCoupRecherche,MaxInt,couleurFinale);        {pour mettre LigneDuCoupAnanlyse à 1}
		    end;
		  if affichageReflexion.doitAfficher & doitEcrireReflexFinale then 
		    LanceDemandeAffichageReflexion(true);
		  
		  for i := 2 to longClass do classAux[i].note := -infini;
		end;
end;

procedure MetCetteNoteDansClassement(var classement : ListOfMoveRecords;note,indexMin,indexMax : SInt32);
var k,delta,bidTickChrono : SInt32;
    tempoAfficheReflexion : boolean;
begin
  if indexMin<1 then indexMin := 1;
  if indexMax>longClass then indexMax := longClass;

  tempoAfficheReflexion := affichageReflexion.doitAfficher;
  affichageReflexion.doitAfficher := false;
  for k := indexMin to indexMax do
    begin
      delta := classement[k].delta;
      bidTickChrono := TickCount();
      if delta<>kTypeMilieuDePartie then
        begin
		      if classement[k].x = coupDontLeScoreEstConnu
		        then 
		          begin
		            SetNoteDansElementClassement(classement,k,scoreDuCoupDontLeScoreEstConnu,kDeltaFinaleInfini,bidTickChrono);
		            note := scoreDuCoupDontLeScoreEstConnu;  {en dessous, on affichera cette note…}
		          end
		        else SetNoteDansElementClassement(classement,k,note,delta,bidTickChrono);
		    end;
    end;
  affichageReflexion.doitAfficher := tempoAfficheReflexion;
end;

procedure InstalleCoupAnalyseRetrogradeEnHautDuClassement(messageHandle:MessageFinaleHdl; var classAux : ListOfMoveRecords);
begin
  if messageHandle <> NIL then
    begin
      typeDataDansHandle := messageHandle^^.typeData;
      case typeDataDansHandle of
        ReflScoreDeCeCoupConnuFinale: MetCoupConnuEnTete(messageHandle,coupDontLeScoreEstConnu,classAux);
        otherwise                     AlerteSimple('typeDataDansHandle inconnu dans UnitFinaleFast !');
      end;      
    end;
end;

{Met les coups de esclaves dans le meme ordre que maitres}
procedure MetLesCoupsDansLeMemeOrdre(maitres : ListOfMoveRecords; var esclaves : ListOfMoveRecords);
var k,t,coup,indexDuCoupsChezLesEsclaves : SInt32;
    tempElement : MoveRecord;
begin
  for k := 1 to longClass do
    begin
      coup := maitres[k].x;
      indexDuCoupsChezLesEsclaves := -1;
      for t := k to longClass do
        if esclaves[t].x = coup then 
          indexDuCoupsChezLesEsclaves := t;
      if indexDuCoupsChezLesEsclaves = -1 
        then 
          begin
            AlerteSimple('ERREUR dans MetLesCoupsDansLeMemeOrdre (indexDuCoupsChezLesEsclaves = -1) !!');
          end
        else
		      if indexDuCoupsChezLesEsclaves<>k then
		        begin
		          tempElement := esclaves[k];
		          esclaves[k] := esclaves[indexDuCoupsChezLesEsclaves];
		          esclaves[indexDuCoupsChezLesEsclaves] := tempElement;
		        end;
    end;
end;


function Coup1EstPlusPrecisQueCoup2DansHashTableExacte(coup1,coup2 : SInt32) : boolean;
var platDepart : PositionEtTraitRec;
    bornes1, bornes2 : DecompressionHashExacteRec;
    infoExactePourCoup1, infoExactePourCoup2 : boolean;
begin
  Coup1EstPlusPrecisQueCoup2DansHashTableExacte := true;
  
  platDepart := positionEtTraitDeCoupGagnant;
  
  if GetEndgameBornesDansHashExacteAfterThisSon(coup1, platDepart, clefHashageCoupGagnant, bornes1) then;
  if GetEndgameBornesDansHashExacteAfterThisSon(coup2, platDepart, clefHashageCoupGagnant, bornes2) then;
  
  infoExactePourCoup1 := (bornes1.valMin[nbreDeltaSuccessifs] = bornes1.valMax[nbreDeltaSuccessifs]);
  infoExactePourCoup2 := (bornes2.valMin[nbreDeltaSuccessifs] = bornes2.valMax[nbreDeltaSuccessifs]);
  
  if (infoExactePourCoup1 | infoExactePourCoup2) then
    begin
      {WritelnStringAndCoupDansRapport(CoupEnString(coup1,true) + ' vs ' , coup2);
      WritelnStringAndCoupDansRapport(' Bornes de ',coup1);
      WritelnBornesDansRapport(bornes1);
      WritelnStringAndCoupDansRapport(' Bornes de ',coup2);
      WritelnBornesDansRapport(bornes2);}
      
      if infoExactePourCoup1 & infoExactePourCoup2 then
        begin
          Coup1EstPlusPrecisQueCoup2DansHashTableExacte := (bornes1.valMin[nbreDeltaSuccessifs] >= bornes2.valMin[nbreDeltaSuccessifs]);
          exit(Coup1EstPlusPrecisQueCoup2DansHashTableExacte);
        end;
      
      if infoExactePourCoup1 & not(infoExactePourCoup2) then
        begin
          Coup1EstPlusPrecisQueCoup2DansHashTableExacte := true;
          exit(Coup1EstPlusPrecisQueCoup2DansHashTableExacte);
        end;
      
      if not(infoExactePourCoup1) & infoExactePourCoup2 then
        begin
          Coup1EstPlusPrecisQueCoup2DansHashTableExacte := false;
          exit(Coup1EstPlusPrecisQueCoup2DansHashTableExacte);
        end;
      
    end;
    
  
end;


var gClassementPourTri : ListOfMoveRecords;
    gIndicesPourTri : array[1..64] of SInt32;
    
    
function LectureTriAuTemps(index : SInt32) : SInt32;
begin
  LectureTriAuTemps := gIndicesPourTri[index];
end;

procedure AffectationTriAuTemps(index,element : SInt32);
begin
  gIndicesPourTri[index] := element;
end;


function ComparaisonPourTriAuTemps(element1,element2 : SInt32) : boolean;
begin
  ComparaisonPourTriAuTemps := gClassementPourTri[element1].notePourLeTri <= gClassementPourTri[element2].notePourLeTri;
end;


(***  tri suivant le classement au temps (ie. milieu + 100*temps) si tous  ***)
(***  moins bons que valeurCible                                           ***)
procedure TrierLesCoupsPerdantsAuTemps(lo,up : SInt32);
var i,j,d,temp,compar : SInt32;
label 999;
begin

  (* copie locale du classement *)
  for i := lo to up do
    gClassementPourTri[i] := classAux[i];

  (* on fait un petit ShellSort sur la copie locale *)
  for i := lo to up do 
     AffectationTriAuTemps(i,i);
  d := up-lo+1;
  while d > 1 do
    begin
      if d < 5 
        then d := 1
        else d := MyTrunc(0.45454*d);
      for i := up-d downto lo do
        begin
          temp := LectureTriAuTemps(i);
          j := i+d;
          while j <= up do
            begin
              compar := LectureTriAuTemps(j);
              if ComparaisonPourTriAuTemps(temp,compar)
                then
                  begin
                    AffectationTriAuTemps(j-d,compar);
                    j := j+d;
                  end
              else
                goto 999;
            end;
          999:
          AffectationTriAuTemps(j-d,temp);
        end;
    end;

  (* on remet la copie locale dans le classement de depart *)
  for i := lo to up do
    classAux[i] := gClassementPourTri[LectureTriAuTemps(i)];
end;




begin {MinimaxFinale}

 if debuggage.algoDeFinale then SetEcritToutDansRapportLog(true);
  

 if (interruptionReflexion = pasdinterruption) then   
 begin
  MemoryFillChar(@meilleureSuite,sizeof(meilleureSuite),chr(0));
  indice_du_meilleur := longClass;
  maxConnuSiToutEstMoinsBonQueValeurCible := -infini;
  
  if bestMode
    then
      begin
        ChangeBestAB(-infini,'init(bestMode)');
        ChangeBetaAB( infini,'init(bestMode)');
        valeurCible := quelleValeurCible;
        
        if not(analyseIntegraleDeFinale)
          then
            begin
              passeDeRechercheAuMoinsValeurCible := (valeurCible=0);
              FenetreLargePourRechercheScoreExact := false;
            end
          else
            begin
              passeDeRechercheAuMoinsValeurCible := false;
              FenetreLargePourRechercheScoreExact := true;
            end;
      end
    else               {reduction de la fenetre}
      begin
        ChangeBestAB(quelleValeurCible-1,'init(not bestMode)');
        ChangeBetaAB(quelleValeurCible+1,'init(not bestMode)');
        valeurCible := quelleValeurCible;
        
        passeDeRechercheAuMoinsValeurCible := true;
        FenetreLargePourRechercheScoreExact := false;
      end;
  
  
  classAux := classementMinimax;  
  compteur := 0;  
  indexDuCoupDansFntrReflexion := compteur;
  for i := 0 to 99 do AEteEnTete[i] := -1;
  
  if analyseRetrograde.EnCours & (messageHandle <> NIL) then
    begin
      UpdateBestABAvecLeScoreDuCoupConnu(messageHandle,bestAB);
      GetCoupDontLeScoreEstConnu(messageHandle,coupDontLeScoreEstConnu,defenseDuCoupDontLeScoreEstConnu,scoreDuCoupDontLeScoreEstConnu);
      if (deltaFinaleCourant = deltaSuccessifs[1]) | (classementMinimax[1].note <= scoreDuCoupDontLeScoreEstConnu) then
        InstalleCoupAnalyseRetrogradeEnHautDuClassement(messageHandle,classAux);
      MetLesCoupsDansLeMemeOrdre(classAux,classementMinimax);
      if (analyseRetrograde.genreAnalyseEnCours=ReflRetrogradeParfait)
        then passeDeRechercheAuMoinsValeurCible := (valeurCible > scoreDuCoupDontLeScoreEstConnu + 2 );
    end;
    
  (*
  WritelnStringAndBoolDansRapport('bestMode=',bestMode);
  WritelnStringAndNumDansRapport('valeurCible=',valeurCible);
  WritelnStringAndNumDansRapport('bestAB=',bestAB);
  WritelnStringAndNumDansRapport('betaAB=',betaAB);
  WritelnStringAndNumDansRapport('scoreDuCoupDontLeScoreEstConnu=',scoreDuCoupDontLeScoreEstConnu);
  WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible=',passeDeRechercheAuMoinsValeurCible);
  WritelnDansRapport('');
  *)
    
  MetCetteNoteDansClassement(classAux,-infini,1,longClass);

      
  
  toutesLesPassesTerminees := false;
  
  passeEhancedTranspositionCutOffEstEnCours := (deltaFinaleCourant < kDeltaFinaleInfini) & (noCoupRecherche <= 58); 
  
BoucleSurLesFils :
  
    repeat
      SetMinimaxAEvalueAUMoinsUnCoupDansCettePasse(false);
      sortieDeBoucleAcceleree := false;
      compteur := 0;  
      
      if debuggage.algoDeFinale then 
        begin
          FinRapport;
          ChangeFontFaceDansRapport(bold);
          WriteDansRapport('Début d''une nouvelle passe');
          TextNormalDansRapport;
          WriteStringAndNumDansRapport('( c=', valeurCible);
          WriteStringAndNumDansRapport(' , BestAB=', BestAB);
          WriteStringAndNumDansRapport(' , betaAB=', betaAB);
          WriteStringAndNumDansRapport(' , µ=', deltaFinaleCourant);
          WriteStringAndBoolDansRapport(' , >c?=', passeDeRechercheAuMoinsValeurCible);
          WriteStringAndBoolDansRapport(' , bestMode=', bestMode);
          if passeEhancedTranspositionCutOffEstEnCours then
            WriteDansRapport(' , ETC');
          WritelnDansRapport(' )');
        end;
      
      
      repeat
        if TickCount()-dernierTick >= delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
        
        if (interruptionReflexion = pasdinterruption) then
          begin
            
            compteur := compteur+1;
            indexDuCoupDansFntrReflexion := compteur;
            XCourant := classAux[compteur].x;
            NoteMilieuDeXCourant := classAux[compteur].noteMilieuDePartie;
            NotePourLeTriDeXCourant := classAux[compteur].notePourLeTri;
            
            
            if not(RefleSurTempsJoueur) & (jeuCourant[XCourant] = pionVide) & PionClignotant then
              DessinePionMontreCoupLegal(XCourant);
            
            if (indexDuCoupDansFntrReflexion > 1) | (deltaFinaleCourant > deltaSuccessifs[1]) then
              begin
                {afficher que l'on cherche avec ce delta pour ce coup}
                if ReflexData^.class[compteur].delta<>kTypeMilieuDePartie then
                  ReflexData^.class[compteur].delta := Max(ReflexData^.class[compteur].delta,deltaFinaleCourant);
                {et si deltaFinaleCourant=kDeltaFinaleInfini, on affiche un joli point d'interrogation}
                if (deltaFinaleCourant=kDeltaFinaleInfini) & (XCourant<>coupDontLeScoreEstConnu) then
                  ReflexData^.class[compteur].pourcentageCertitude := kCertitudeSpecialPourPointInterrogation;
                {et afficher des 'pas mieux' en dessous}
                if not(analyseIntegraleDeFinale & (deltaFinaleCourant >= deltaSuccessifs[1])) then
  	              if analyseRetrograde.EnCours & (classAux[1].x=coupDontLeScoreEstConnu)
  	                then 
  	                  if (compteur=2)
  	                    then MetCetteNoteDansClassement(ReflexData^.class,classementMinimax[2].note,compteur,longClass) {note de l'iteration precedente}
  	                    else MetCetteNoteDansClassement(ReflexData^.class,ReflexData^.class[2].note,compteur,longClass)
  	                else 
  	                  if not(MinimaxAEvalueAUMoinsUnCoupDansCettePasse())
  	                    then MetCetteNoteDansClassement(ReflexData^.class,classementMinimax[compteur].note,compteur,longClass) {note de l'iteration precedente}
  	                    else MetCetteNoteDansClassement(ReflexData^.class,ReflexData^.class[compteur].note,compteur,longClass);
                SetNroLigneEnCoursDAnalyseDansReflex(compteur);
                LanceDemandeAffichageReflexion((indexDuCoupDansFntrReflexion <= 2) | (deltaFinaleCourant=kDeltaFinaleInfini));
              end;
             
            platMod := jeu;
            jouableMod := empl;
            nbBlancMod := nbBla;
            nbNoirMod := nbNoi;
            frontMod := frontiereMinimax;
            coupLegal := ModifPlatLongint(XCourant,couleur,platMod,jouableMod,nbBlancMod,nbNoirMod,frontMod);
            with InfosMod do
              begin
                jouable := jouableMod;
                nbBlancs := nbBlancMod;
                nbNoirs := nbNoirMod;
                frontiere := frontMod;
              end;
            
            EnleverDeLaListeChaineeDesCasesVides(XCourant);
            gVecteurParite := BXOR(gVecteurParite,constanteDeParite[XCourant]);
            if EndgameTreeEstValide(numeroEndgameTreeActif) then
              DoMoveEndgameTree(numeroEndgameTreeActif,XCourant,couleur);
            
            TickChrono := TickCount();
            TickChronoPourClassaux := TickCount();
            tempsPourTickChronoPourClassaux := classAux[compteur].temps;
            nbCoupuresHeuristiquesDeXCourant := nbCoupuresHeuristiquesCettePasse;
            deltaDeXCourantAvantRecherche := classAux[compteur].delta;
            
            if MiniProf<=0 then
              begin
                if Couldefense = pionBlanc 
                   then 
                     if nbBlancMod<nbNoirMod
                       then noteModif := nbBlancMod+nbBlancMod-64
                       else noteModif := 64 - nbNoirMod - nbNoirMod
                   else 
                     if nbBlancMod<nbNoirMod
                       then noteModif := 64 - nbBlancMod - nbBlancMod
                       else noteModif := nbNoirMod+nbNoirMod-64;
                if nbBlancMod=nbNoirMod then notemodif := 0;
                valXY := -noteModif;
              end
            else 
              begin
                if (XCourant = coupDontLeScoreEstConnu)
                  then 
                    begin
                      valXY := scoreDuCoupDontLeScoreEstConnu;
                      defense := defenseDuCoupDontLeScoreEstConnu;
                      AEteEnTete[XCourant] := deltaFinaleCourant;
                    end
                  else
                    begin                              
                      if analyseIntegraleDeFinale
                        then 
                          begin
                            if not(bestMode)
                              then valXY := CalculParAnalyseDeFinale(-1, +1)
                              else valXY := CalculParAnalyseDeFinale(-64, +64);
                            AEteEnTete[XCourant] := deltaFinaleCourant;
                          end
                        else 
                          begin
                            peutUtiliserDichotomie := not(MinimaxAEvalueAUMoinsUnCoupDansCettePasse()) | 
                                                      ((compteur = 2 ) & analyseRetrograde.EnCours & 
                                                       (classAux[1].x = coupDontLeScoreEstConnu) & 
                                                       (valeurCible > scoreDuCoupDontLeScoreEstConnu));
                            valXY := {SSS_Dual();}
                                     {CalculNormal();}
                                      Dicho_first(quelleValeurCible,peutUtiliserDichotomie);
                          end;
                    end;
              end;
            
            
            gVecteurParite := BXOR(gVecteurParite,constanteDeParite[XCourant]);
            RemettreDansLaListeChaineeDesCasesVides(XCourant);
            if EndgameTreeEstValide(numeroEndgameTreeActif) & (interruptionReflexion = pasdinterruption) then
              UndoMoveEndgameTree(numeroEndgameTreeActif);
              
            
            if not(ValeurDeFinaleInexploitable(valXY)) 
              then SetMinimaxAEvalueAUMoinsUnCoupDansCettePasse(true);
            
            if ValeurDeFinaleInexploitable(valXY) & (valXY > 0) then valXY := - valXY;
            
            if not(ValeurDeFinaleInexploitable(valXY)) then
              begin
            
  		          TempsDeXCourant := tempsPourTickChronoPourClassaux+(TickCount()-TickChronoPourClassaux);
  		          NotePourLeTriDeXCourant := (NoteMilieuDeXCourant div 8) + TempsDeXCourant;
  		          nbCoupuresHeuristiquesDeXCourant := nbCoupuresHeuristiquesCettePasse-nbCoupuresHeuristiquesDeXCourant;
  		          deltaDeXCourantDevientInfini := (nbCoupuresHeuristiquesDeXCourant=0) & (deltaDeXCourantAvantRecherche<>kDeltaFinaleInfini);
  		          if nbCoupuresHeuristiquesDeXCourant = 0
  		            then deltaDeXCourantApresRecherche := kDeltaFinaleInfini
  		            else deltaDeXCourantApresRecherche := deltaFinaleCourant;
  		          
  		          
  		          if not(bestMode) & (valeurCible=0) & (valXY<0) then valXY := -1;
  		          if not(bestMode) & (valeurCible=0) & (valXY>0) then valXY := +1;
  		          if bestMode & passeDeRechercheAuMoinsValeurCible & (valXY < valeurCible) then
  		            if not(analyseRetrograde.EnCours) | (XCourant <> coupDontLeScoreEstConnu)
  		              then 
  		                begin
  		                  if valXY > maxConnuSiToutEstMoinsBonQueValeurCible 
  		                    then maxConnuSiToutEstMoinsBonQueValeurCible := valXY;
  		                  if (Signe(valXY) = Signe(valeurCible-1))
  		                    then valXY := valeurCible-1;
  		                end;
  		          if bestMode & (valXY > valeurCible) & odd(valXY) then inc(valXY);
  		          if bestMode & not(analyseIntegraleDeFinale) & (valXY < bestAB) then valXY := bestAB;
  		          if (interruptionReflexion <> pasdinterruption) then valXY := -infini;
  		          
  		          doitAppelerGestionMeilleureSuite := false;
  		          if not(ValeurDeFinaleInexploitable(valXY)) then
  		            begin
  				          if (valXY > bestAB) |
  				             (not(bestMode) & (valXY = bestAB) & (valXY = (valeurCible-1))) |
  				             (analyseIntegraleDeFinale) then 
  				            begin
  				            
  				              if (valXY > bestAB) then ChangeBestAB(valXY,'valXY > bestAB');
  				              
    				            if analyseIntegraleDeFinale | not(bestMode & passeDeRechercheAuMoinsValeurCible & (valXY < valeurCible))
    				                then doitAppelerGestionMeilleureSuite := true;
  				            end;
  				        end;
  		          
  		          if not(ValeurDeFinaleInexploitable(valXY)) then
  		            begin
  		              if (valXY > classAux[1].note) then indice_du_meilleur := compteur;
  		              if (compteur = 1) | (valXY > classAux[1].note) then 
  		                AEteEnTete[XCourant] := deltaFinaleCourant;
  		            end;
  		          
  		          with analyseRetrograde do
  		            if EnCours & ((genreAnalyseEnCours=ReflRetrogradeParfait) | (genreAnalyseEnCours=ReflRetrogradeGagnant)) & 
  		               passeDeRechercheAuMoinsValeurCible & (compteur>=2) & (valXY<valeurCible) & (classAux[1].x=coupDontLeScoreEstConnu)
  		              then k := 2
  		              else k := 1;
  		              
  		          {classement au mérite}
  		          
  		          while (k < compteur) & 
  		                ((classAux[k].note > valxy) | ((classAux[k].note = valXY) & Coup1EstPlusPrecisQueCoup2DansHashTableExacte(classAux[k].x,XCourant)))  do 
  		            k := k+1;
  		          for j := compteur downto k+1 do 
  		            classAux[j] := classAux[j-1];
  		            
  		          classAux[k].x := XCourant;
  		          classAux[k].note := ValXY;
  		          classAux[k].theDefense := defense;
  		          classAux[k].temps := TempsDeXCourant;
  		          classAux[k].noteMilieuDePartie := NoteMilieuDeXCourant;
  		          classAux[k].notePourLeTri := NotePourLeTriDeXCourant;
  		          classAux[k].pourcentageCertitude := 100;
  		          classAux[k].delta := deltaDeXCourantApresRecherche;
  		          
  		          {EcritClassementDansRapport(classAux, 'Classement au mérite de ' + CoupEnString(XCourant,true) + ' : ');}
  		          
  		          {on affiche eventuellement les notes sur l'othellier}
  		          if not(ValeurDeFinaleInexploitable(valXY)) then
  		            begin
  				          if (CassioEstEnModeAnalyse() {| analyseRetrograde.enCours}) & (nbCoupuresHeuristiquesDeXCourant = 0) & 
  				             EstPositionEtTraitCourant(MakePositionEtTrait(jeu,couleur))
  				            then
  				              begin
  				                if not(bestMode)
  				                  then
  				                    begin
  				                                        
  				                      {if analyseRetrograde.enCours & (XCourant=coupDontLeScoreEstConnu) & not(odd(scoreDuCoupDontLeScoreEstConnu)) 
  				                        then 
  				                          noteAfficheeSurOthellier := 100*(scoreDuCoupDontLeScoreEstConnu)
  				                        else}
  						                      if classAux[k].note < 0 then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourPerte else
  						                      if classAux[k].note > 0 then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourGain  else
  						                      if classAux[k].note = 0 then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourNulle;
  				                      
  				                      if not((MFprof<= 8) & GenreDeReflexionInSet(typeCalculFinale,[ReflParfait,ReflParfaitExhaustif,ReflRetrogradeParfait])) then
  					                      if analyseIntegraleDeFinale | (classAux[k].note < 0) | (k = 1) then
  					                        if (k = 1)
  					                          then SetMeilleureNoteSurCase(kNotesDeCassio,classAux[k].x,noteAfficheeSurOthellier)
  					                          else SetNoteSurCase(kNotesDeCassio,classAux[k].x,noteAfficheeSurOthellier);
  				                    end
  				                  else
  				                    begin
  				                      noteAfficheeSurOthellier := 100*(classAux[k].note);
  				                      if odd(noteAfficheeSurOthellier div 100) & (noteAfficheeSurOthellier < 0) then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourPerte else
  				                      if odd(noteAfficheeSurOthellier div 100) & (noteAfficheeSurOthellier > 0) then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourGain;
  				                      
  				                      if analyseIntegraleDeFinale | (k = 1) then
  				                        if (k = 1)
  				                          then SetMeilleureNoteSurCase(kNotesDeCassio,classAux[k].x,noteAfficheeSurOthellier)
  				                          else SetNoteSurCase(kNotesDeCassio,classAux[k].x,noteAfficheeSurOthellier);
  				                    end;
  				              end;
  				        end;
  		          
  		          
  		          (***  tri suivant le classement au temps (ie. milieu + 100*temps) si tous  ***)
  		          (***  moins bons que valeurCible                                           ***)
  		          if ClassementAuTempsSiTousMoinsBonsQueValeurCible & not(passeEhancedTranspositionCutOffEstEnCours) then
  		            begin
  				          if (not(bestMode) | passeDeRechercheAuMoinsValeurCible) then
  				            if (valXY < valeurCible) & (bestAB < valeurCible) & (valXY >= bestAB) then 
  					            begin
  					              {
  					              if debuggage.algoDeFinale then
        		                begin
        		                  FinRapport;
        		                  WritelnDansRapport('classement au temps : ');
        		                  WritelnStringAndCoupDansRapport('XCourant = ',XCourant);
        		                  WritelnStringAndNumDansRapport('NotePourLeTriDeXCourant = ',NotePourLeTriDeXCourant);
        		                  WritelnStringAndNumDansRapport('compteur = ',compteur);
        		                  WritelnStringAndNumDansRapport('valXY = ',valXY);
        		                  WritelnStringAndNumDansRapport('valeurCible = ',valeurCible);
        		                  WritelnStringAndNumDansRapport('bestAB = ',bestAB);
        		                end;
        		              }
  					            
  					              with analyseRetrograde do
    						            if EnCours & 
    						              ((genreAnalyseEnCours=ReflRetrogradeParfait) | (genreAnalyseEnCours=ReflRetrogradeGagnant)) & 
    						               passeDeRechercheAuMoinsValeurCible & 
    						               (compteur>=2) & 
    						               (valXY<valeurCible) & 
    						               (classAux[1].x=coupDontLeScoreEstConnu)
    						              then k := 2
    						              else k := 1;
  					             
  					              {if debuggage.algoDeFinale then EcritClassementDansRapport(classAux, 'Avant classement au temps de ' + CoupEnString(XCourant,true) + ' : ');}
  					              
  					              TrierLesCoupsPerdantsAuTemps(k,compteur);
  				                
  				                {if debuggage.algoDeFinale then EcritClassementDansRapport(classAux, 'Apres classement au temps de ' + CoupEnString(XCourant,true) + ' : ');}
  					            end;
  		            end;
  		            
  		          
  		            
  		          AEteEnTete[classAux[1].x] := deltaFinaleCourant;
  		          
  		          if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
  		          
  		          if doitAppelerGestionMeilleureSuite then
  		            begin
  		              {on trouve la place de XCourant}
  		              j := -1; {not found}
  		              for k := 1 to longClass do
  		                if classAux[k].x = XCourant then j := k;
  		              GestionMeilleureSuite(miniprof,platmod,coulDefense,nbBlancMod,nbNoirMod,valXY,XCourant,deltaDeXCourantApresRecherche,
  		                                    compteur,longClass,(not(bestmode) & (bestAB < 0)) | ((valXY=bestAB) & (j=1)));
  		            end;
  		          
  		          if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
  		          
  		          if doitEcrireReflexFinale then
  		            begin
  		              if compteur<longClass then classAux[compteur+1].note := -noteMax;
  		              if analyseRetrograde.EnCours
  		                then
  		                  if bestmodeArriveeDansCoupGagnant
  		                    then
  		                      if bestMode
  		                        then SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflRetrogradeParfait,noCoupRecherche,compteur+1,couleurFinale)
  		                        else SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflRetrogradeParfaitPhaseGagnant,noCoupRecherche,compteur+1,couleurFinale)
  		                    else
  		                      SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflRetrogradeGagnant,noCoupRecherche,compteur+1,couleurFinale)
  		                else
  		                  if bestmodeArriveeDansCoupGagnant
  		                    then
  		                      if bestMode
  		                        then 
  		                          if analyseIntegraleDeFinale
  		                            then SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflParfaitExhaustif,noCoupRecherche,compteur+1,couleurFinale)
  		                            else SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflParfait,noCoupRecherche,compteur+1,couleurFinale)
  		                        else SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflParfaitPhaseGagnant,noCoupRecherche,compteur+1,couleurFinale)
  		                    else
  		                      if analyseIntegraleDeFinale
  		                        then SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflGagnantExhaustif,noCoupRecherche,compteur+1,couleurFinale)
  		                        else SetValReflexFinale(classAux,miniprof,compteur,longClass,ReflGagnant,noCoupRecherche,compteur+1,couleurFinale)
  		            end;
  		          
  		          
  		          if affichageReflexion.doitAfficher & doitEcrireReflexFinale then 
  		            LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant) | deltaDeXCourantDevientInfini);
  		          if not(RefleSurTempsJoueur) & (jeuCourant[XCourant] = pionVide) & PionClignotant then
  		            EffacePionMontreCoupLegal(XCourant);
  		            
  		         
  		          if not(ValeurDeFinaleInexploitable(valXY)) & avecRefutationsDansRapport & commentaireDansRapport &
  		            not(bestMode) & (compteur >= longClass) & (bestAB < 0) then 
  		              EcritRefutationsDansRapport(longClass,classAux);
  		          
  		          if (valxy >= 64) & (nbCoupuresHeuristiquesDeXCourant = 0) & not(analyseIntegraleDeFinale) then 
  		            begin
  		              CoupGagnant := true;
  		              meilleurScore := valXY;
  		              sortieDeBoucleAcceleree := true;
  		              toutesLesPassesTerminees := true;
  		            end;
  		            
  		          if not(ValeurDeFinaleInexploitable(valXY)) & 
  		             not(bestMode) & (valXY > quelleValeurCible) & not(analyseIntegraleDeFinale) then
  		            begin
  		              CoupGagnant := true;
  		              meilleurScore := valXY;
  		              {on trouve la place de XCourant}
  		              j := -1; {not found}
  		              for k := 1 to longClass do
  		                if classAux[k].x = XCourant then j := k;
  		              if (j <> -1) then {puis on le met en tete}
  		                begin
  		                  tempElementClass := classAux[1];
  				              classAux[1]      := classAux[j];
  				              classAux[j]      := tempElementClass;
  				              
  				              classAux[1].x := XCourant;
  				              classAux[1].note := ValXY;
  				              classAux[1].theDefense := defense;
  				              classAux[1].delta := deltaDeXCourantApresRecherche;
  				              if not(analyseIntegraleDeFinale) then sortieDeBoucleAcceleree := true;
  				            end;
  		            end;
  		          if not(ValeurDeFinaleInexploitable(valXY)) & bestMode & 
  		             (valXY = maxConnuSiToutEstMoinsBonQueValeurCible) & (betaAB = (maxConnuSiToutEstMoinsBonQueValeurCible+1)) then
  		            begin
  		              CoupGagnant := false;
  		              meilleurScore := valXY;
  		              sortieDeBoucleAcceleree := true;
  		            end;
  		        end;
  		        
         end;
    
      until sortieDeBoucleAcceleree | (compteur >= longClass) | (interruptionReflexion <> pasdinterruption);
      
      (*
      WritelnStringAndBooleanDansRapport('sortieDeBoucleAcceleree = ',sortieDeBoucleAcceleree);
      WritelnStringAndNumDansRapport('compteur = ',compteur);
      WritelnStringAndNumDansRapport('longClass = ',longClass);
      WritelnInterruptionDansRapport(interruptionReflexion);
      *)
      
      (* on met le score du noeud dans l'arbre de jeu *)
      if not(ValeurDeFinaleInexploitable(classAux[1].note)) & 
         ((compteur >= longClass) | sortieDeBoucleAcceleree) &
         (deltaFinaleCourant = kDeltaFinaleInfini) & 
         not(bestmode & passeDeRechercheAuMoinsValeurCible & (valeurCible <> 0) & (classAux[1].note <> valeurCible)) then
        begin
         {WritelnStringAndBoolDansRapport('bestMode = ',bestMode);
          WritelnStringAndBoolDansRapport('bestmodeArriveeDansCoupGagnant = ',bestmodeArriveeDansCoupGagnant);
          WritelnStringAndBoolDansRapport('sortieDeBoucleAcceleree = ',sortieDeBoucleAcceleree);
          WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible = ',passeDeRechercheAuMoinsValeurCible);
          WritelnStringAndNumDansRapport('valeurCible = ',valeurCible);}
          
          if bestMode & not(passeDeRechercheAuMoinsValeurCible)
            then AjouteScoreToEndgameTree(MakePositionEtTrait(jeu,couleur),ReflParfait,classAux[1].note)
            else AjouteScoreToEndgameTree(MakePositionEtTrait(jeu,couleur),ReflGagnant,classAux[1].note);
        end;
        
        
      if bestMode & passeDeRechercheAuMoinsValeurCible 
        then
          begin
          
            passeDeRechercheAuMoinsValeurCible := false;
          
            if MinimaxAEvalueAUMoinsUnCoupDansCettePasse() & (maxConnuSiToutEstMoinsBonQueValeurCible <> -infini) then
              begin
                if analyseRetrograde.EnCours
                  then ChangeBestAB(scoreDuCoupDontLeScoreEstConnu,'bestMode & passeDeRechercheAuMoinsValeurCible{1}')
                  else ChangeBestAB(-64,'bestMode & passeDeRechercheAuMoinsValeurCible{2}');
                {on sait que tous les coups sont < à valeurCible}
                ChangeBetaAB(succ(maxConnuSiToutEstMoinsBonQueValeurCible),'bestMode & passeDeRechercheAuMoinsValeurCible{3}'); 
              end;
              
          end
        else
          begin
            toutesLesPassesTerminees := true;
          end;
    
    until toutesLesPassesTerminees | (interruptionReflexion <> pasdinterruption);
  
  
  if passeEhancedTranspositionCutOffEstEnCours & (interruptionReflexion = pasdinterruption) then
    begin
      passeEhancedTranspositionCutOffEstEnCours := false;
      goto BoucleSurLesFils;
    end;
  
     
  if (interruptionReflexion = pasdinterruption) then
  begin
  
    if meilleureSuiteAEteCalculeeParOptimalite & afficheSuggestionDeCassio & SuggestionAnalyseDeFinaleEstDessinee() then 
      TrierClassementSiMeilleureSuiteAEteCalculeeParOptimalite(classAux,longClass);
  
    k := 0;
    for i := 1 to longClass do
      if AEteEnTete[classAux[i].x] >= 0 then
        begin
          inc(k);
          classementMinimax[k] := classAux[i];
        end;
    nbCoupsAyantEteEnTete := k;
    if k<=0 then 
      begin
        SysBeep(0);
        WritelnDansRapport('ERROR : Pas trouve de AEteEnTete[k] à la fin de MinimaxFinale');
      end;
   
    for i := 1 to longClass do
      if AEteEnTete[classAux[i].x] < 0 then
        begin
          inc(k);
          classementMinimax[k] := classAux[i];
          classementMinimax[k].note := classementMinimax[nbCoupsAyantEteEnTete].note;
        end;
    TrierClassementAuTemps(classementMinimax,nbCoupsAyantEteEnTete+1,longClass);
    if doitEcrireReflexFinale then
      begin
        SetValReflexFinale(classementMinimax,miniprof,nbcoup,nbcoup,ReflexData^.typeDonnees,noCoupRecherche,MaxInt,couleurFinale);
        if affichageReflexion.doitAfficher then 
          LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant));
      end;
    MinimaxFinale := classementMinimax[1].note;
    if commentaireDansRapport & not(GenreDeReflexionInSet(typeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif])) &
       ((miniprof+1) <= kNbCasesVidesPourAnnonceDansRapport) then
      MeilleureSuiteDansRapport(classementMinimax[1].note);
  end
  else  { ici (interruptionReflexion <> pasdinterruption) }
    begin
      if compteur <= 1 
       then
         begin
           for i := 1 to longClass do 
             classementMinimax[i] := classementMinimax[i]; {on ne fait rien : on utilise le milieu de partie}
           MinimaxFinale := classementMinimax[1].note;
         end
       else
         begin
           for i := 1 to compteur-1 do 
             classementMinimax[i] := classAux[i];
           for i := compteur to longClass do
             classementMinimax[i].note := classementMinimax[compteur-1].note-100;
           MinimaxFinale := classementMinimax[1].note;
           if commentaireDansRapport & not(GenreDeReflexionInSet(typeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif]))
              & ((miniprof+1) <= kNbCasesVidesPourAnnonceDansRapport) then
             MeilleureSuiteDansRapport(classementMinimax[1].note);
         end;
    end;
  end;
end;  {MinimaxFinale}


function Algo_Directionnel(quelleValeurCible,coulPourMeilleurFin,nbbl,nbno : SInt32;jeu : plateauOthello;trierAvecLeTemps : boolean; var meilleurX : SInt32) : SInt32;
begin
  if (interruptionReflexion = pasdinterruption) then   
    begin
      tempsAlloue := CalculeTempsAlloueEnFinale(CoulPourMeilleurFin);
      SetValeursGestionTemps(tempsAlloue,0,0,0.0,0,0);
      LanceChrono;
      LanceChronoCetteProf;
      if afficheGestionTemps & (interruptionReflexion = pasdinterruption) then EcritGestionTemps;
      meilleurScore := MinimaxFinale(quelleValeurCible,coulPourMeilleurFin,MFniv,nbCoup,nbbl,nbno,jeu,empl,frontiereFinale,trierAvecLeTemps,classement);  
      if afficheGestionTemps & (interruptionReflexion = pasdinterruption) then EcritGestionTemps;
      
      
      { on renvoie le premier du classement }
      meilleurX := classement[1].x;
      bstdef := classement[1].theDefense;
      Algo_Directionnel := classement[1].note;
  end;
end;


function PasseAlgoDirectionnel(quelleValeurCible,deltaFinaleVoulu : SInt32;trierAvecLeTemps : boolean; var termine : boolean) : SInt32;
var meilleurScore : SInt32;
begin
  if (deltaFinaleVoulu >= 0) & (interruptionReflexion = pasdinterruption) then
    begin
	  SetDeltaFinalCourant(deltaFinaleVoulu);
	  
	  {WritestringandnumDansRapport('avant delta=',deltaFinaleCourant);
	  WritelnDansRapport('…');
	  WritelnDansRapport('');}
	  
	  maxEvalsRecursives := 0;
	  
	  nbCoupuresHeuristiquesCettePasse := 0;
	  meilleurScore := Algo_Directionnel(quelleValeurCible,coulPourMeilleurFin,nbbl,nbno,jeu,trierAvecLeTemps,meilleurX);	  
	  termine := (nbCoupuresHeuristiquesCettePasse=0);
	  
	  {WritestringandnumDansRapport('apres delta=',deltaFinaleCourant);
	  WritelnstringandnumDansRapport('…   nbreNoeudsGeneresFinale=',nbreNoeudsGeneresFinale);
	  WritelnDansRapport('');}
	  
	  {WritelnDansRapport('');
	  WritelnstringandnumDansRapport('deltaFinaleCourant=',deltaFinaleCourant);
	  WritelnstringandnumDansRapport('nbCoupuresHeuristiquesCettePasse=',nbCoupuresHeuristiquesCettePasse);}
	  
	  
	  {On renvoie le score…}
	  PasseAlgoDirectionnel := meilleurScore;
	  
	  {… et on sauvegarde eventuellement le score et la suite parfaite}
	  if (deltaFinaleVoulu=kDeltaFinaleInfini) & (interruptionReflexion = pasdinterruption) then
	    begin
        if CoulPourMeilleurFin = pionNoir
          then scoreDeNoir :=  meilleurScore
          else scoreDeNoir := -meilleurScore;
        if bestMode
          then MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleParfaite,scoreDeNoir)
          else MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleWLD,scoreDeNoir);
        if bestMode then SauvegardeLigneOptimale(coulDefense);
      end;
	end;
end;


procedure EssaieCalculerFinaleOptimaleParOptimalite;
begin
 if bestMode & not(analyseRetrograde.EnCours) & not(GenreDeReflexionInSet(typeCalculFinale,[ReflGagnantExhaustif])) then
   if PeutCalculerFinaleOptimaleParOptimalite(jeu,nbNo,nbBl,meilleurX,bstdef,scoreDeNoir)
     then
       begin
         
         meilleureSuiteAEteCalculeeParOptimalite := true;
       
         if not(GenreDeReflexionInSet(typeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif])) 
           then
             begin
               resultatSansCalcul := true;
               CoupGagnant := ((scoreDeNoir>=0) & (coulPourMeilleurFin = pionNoir)) | 
                              ((scoreDeNoir<=0) & (coulPourMeilleurFin = pionBlanc));
               
               if coulPourMeilleurFin = pionNoir
                 then meilleurScore := scoreDeNoir
                 else meilleurScore := -scoreDeNoir;
               
               SetCassioEstEnTrainDeReflechir(CassioEtaitEnTrainDeReflechir,NIL);
               SetGenreDerniereReflexionDeCassio(typeCalculFinale,(nbBl + nbNo) - 4 +1);
               exit(CoupGagnant);
             end
           else
             begin
               if EstPositionEtTraitCourant(positionEtTraitDeCoupGagnant)
						     then ActiverSuggestionDeCassio(PositionEtTraitCourant(),meilleurX,bstdef,'EssaieCalculerFinaleOptimaleParOptimalite');
             end;
         
         if bestmode
           then MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleParfaite,scoreDeNoir)
           else MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleWLD,scoreDeNoir);
       end;
end;


procedure EssaieCalculerFinaleOptimaleParGameTree;
var suiteOptimale : PropertyList;
    {longueurListeDesCoups : SInt32;}
begin

  if (interruptionReflexion <> pasdinterruption) then
    exit(EssaieCalculerFinaleOptimaleParGameTree);
  
  if EndgameTreeEstValide(numeroEndgameTreeActif) then 
	  begin
	    suiteOptimale := NewPropertyList();
	    
	    if PeutCalculerFinaleParEndgameTree(numeroEndgameTreeActif,positionEtTraitDeCoupGagnant,
	                                        suiteOptimale,meilleurScore) then
        begin
       
          SetSuiteParfaiteEstConnueDansGameTree(true);
          
          {
          SysBeep(0);
          WritelnDansRapport('PeutCalculerFinaleParEndgameTree a reussi !');
          if coulPourMeilleurFin = pionNoir
            then WritelnDansRapport('coulPourMeilleurFin = pionNoir')
            else WritelnDansRapport('coulPourMeilleurFin = pionBlanc');
          WritelnStringAndPropertyListDansRapport('   =>  suiteOptimale = ',suiteOptimale);
          WritelnStringAndNumDansRapport('   =>  meilleurScore = ',meilleurScore);
          }
          
          (*
          longueurListeDesCoups := PropertyListLength(suiteOptimale);
          
          if (longueurListeDesCoups > 0) then
            begin
		          if (longueurListeDesCoups >= 1)
		            then meilleurX := GetOthelloSquareOfProperty(HeadOfPropertyList(suiteOptimale)^)
		            else meilleurX := 44;
		          if (longueurListeDesCoups >= 2) 
		            then bstdef := GetOthelloSquareOfProperty(HeadOfPropertyList(TailOfPropertyList(suiteOptimale))^)
		            else bstdef := 44;
		       
		          {resultatSansCalcul := true;}
		          CoupGagnant := (meilleurScore > 0);
		          if coulPourMeilleurFin = pionNoir
		            then scoreDeNoir :=  meilleurScore
		            else scoreDeNoir := -meilleurScore;
		          if bestMode
		            then MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleParfaite,scoreDeNoir)
		            else MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleWLD,scoreDeNoir);
		        end;
		        
		      *)
        end;
        
      DisposePropertyList(suiteOptimale);
    end;
end;


function InitToutPourRechercheDeFinaleEnProfondeur() : boolean;
var i : SInt32;
begin

  InitToutPourRechercheDeFinaleEnProfondeur := false;  {valeur par defaut si on detecte un probleme}
  
  listeChaineeEstDisponibleArrivee := ListeChaineeDesCasesVidesEstDisponible();
   if not(listeChaineeEstDisponibleArrivee) then
     begin
       SysBeep(0);
       WritelnDansRapport('ERREUR : listeChaineeEstDisponibleArrivee = false dans InitToutPourRechercheDeFinaleEnProfondeur !');
       exit(InitToutPourRechercheDeFinaleEnProfondeur);
     end;
  
  {if commentaireDansRapport & InfosTechniquesDansRapport & (noCoupRecherche<43) then
	           AnnonceRechercheDansRapport(bestmodeArriveeDansCoupGagnant,noCoupRecherche);}
	         
	 tempsGlobalDeLaFonction := TickCount();
   infini := 30000;    {pas noteMax pour eviter l'overflow dans derniercoup}
   
   
   MFniv := MFprof-1;
   MemoryFillChar(@suiteJouee,sizeof(suiteJouee),chr(0));
   MemoryFillChar(@meilleureSuite,sizeof(meilleureSuite),chr(0));
   MemoryFillChar(@classement,sizeof(classement),chr(0));
   SetDerniereAnnonceFinaleDansMeilleureSuite('');
   
   if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
   if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);
   
   MemoryFillChar(@gNonCoins_entreeCoupGagnant,sizeof(gNonCoins_entreeCoupGagnant),chr(0));
   MemoryFillChar(@gCasesVides_entreeCoupGagnant,sizeof(gCasesVides_entreeCoupGagnant),chr(0));
   MemoryFillChar(@gListeCasesVidesOrdreJCWCoupGagnant,sizeof(gListeCasesVidesOrdreJCWCoupGagnant),chr(0));
   MemoryFillChar(@gCoins_entreeCoupGagnant,sizeof(gCoins_entreeCoupGagnant),chr(0));
   gVecteurParite := 0;
   MemoryFillChar(@gNbreVidesCeQuadrantCoupGagnant,sizeof(gNbreVidesCeQuadrantCoupGagnant),chr(0));
   nbreToursNoeudsGeneresFinale := 0;
   nbreNoeudsGeneresFinale := 0;
   MemoryFillChar(@NbreDeNoeudsMoyensFinale,sizeof(NbreDeNoeudsMoyensFinale),chr(0));
   
   if TickCount()-dernierTick >= delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
   if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);
   
   {version de VideToutesLesHashTablesExactes ou on verifie les interruptions}
   if (MFniv >= 10) & not(analyseRetrograde.EnCours & (nbreCoup >= 40)) then 
     begin
	     for i := 0 to nbTablesHashExactes-1 do
			   begin
			     if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
			     if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);
			     
			     VideHashTableExacte(HashTableExacte[i]);
			       
			     if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
			     if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);
			     
			     VideHashTableCoupsLegaux(CoupsLegauxHash[i]);
			   end;
			 nbCollisionsHashTableExactes := 0;
			 nbNouvellesEntreesHashTableExactes := 0;
			 nbPositionsRetrouveesHashTableExactes := 0;
     end;
   
   if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
	 if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);
   
   VideHashTable(HashTable);
   
   if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
	 if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);
	 
	 if gIsRunningUnderMacOSX
     then BitboardHashAllocate(gBitboardHashTable,20)   {Attention : deja 40 megaoctets :-( }
     else BitboardHashAllocate(gBitboardHashTable,16);  {Attention : 2.5 megaoctets         }
	
   InitialiseConstantesCodagePosition;
   
   tempsAlloue := CalculeTempsAlloueEnFinale(CoulPourMeilleurFin);
   LanceChrono;
   
   if OthelloTorique 
     then CarteMoveTore(coulPourMeilleurFin,jeu,move,mob) 
     else CarteMove(coulPourMeilleurFin,jeu,move,mob);
     
   if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
   if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);
   
   
   
   
   CreeListeCasesVidesDeCettePosition(jeu,true);
   CreerListeChaineeDesCasesVides(gNbreVides_entreeCoupGagnant,
                                gTeteListeChaineeCasesVides,
                                gBufferCellulesListeChainee,
                                gTableDesPointeurs,
                                'InitToutPourRechercheDeFinaleEnProfondeur');
   SetListeChaineeDesCasesVidesEstDisponible(false);
   
   {$IFC USE_DEBUG_HASH_VALUES}
   positionsDejaAffichees := MakeOneElementPositionEtTraitSet(positionEtTraitDeCoupGagnant,clefHashageCoupGagnant);
   WritelnDansRapport('');
   WritelnDansRapport('••••••••• Creation de positionsDejaAffichees avec la position suivante : ••••••••••••••••••');
   WritelnPositionEtTraitDansRapport(jeu,coulPourMeilleurFin);
   WritelnStringAndNumDansRapport('clefHashageCoupGagnant = ',clefHashageCoupGagnant);
   WritelnStringAndNumDansRapport('hachage(position) = ',GenericHash(@jeu,sizeof(jeu)));
   {$ENDC}
   
   tempoUserCoeffDansNouvelleEval := withUserCoeffDansNouvelleEval;
   withUserCoeffDansNouvelleEval := false;
   
   InitToutPourRechercheDeFinaleEnProfondeur := true;
end;


procedure LibereToutPourRechercheDeFinaleEnProfondeur;
begin
  SetListeChaineeDesCasesVidesEstDisponible(listeChaineeEstDisponibleArrivee);

  if affichageReflexion.doitAfficher & not(analyseIntegraleDeFinale) & doitEcrireReflexFinale then 
    begin
      ReinitilaliseInfosAffichageReflexion;
      EffaceReflexion;
    end;
       
   if InfosTechniquesDansRapport & commentaireDansRapport & not(demo) then
     begin
       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
       AfficheMiniProfilerDansRapport(ktempsMoyen);
       {$ENDC}
       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
       AfficheMiniProfilerDansRapport(kpourcentage);
       {$ENDC}
       if (interruptionReflexion = pasdinterruption) then AnnonceRechercheDansRapport(bestmodeArriveeDansCoupGagnant,noCoupRecherche);
       MetInfosTechniquesDansRapport;
     end;
   EffaceAnnonceFinaleSiNecessaire;
   
   if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
     then TraiteEvenements
     else TraiteNullEvent(theEvent);
   
   {$IFC USE_DEBUG_HASH_VALUES}
   DisposePositionEtTraitSet(positionsDejaAffichees);
   {$ENDC}
   
  withUserCoeffDansNouvelleEval := tempoUserCoeffDansNouvelleEval;
  
  SetGenreDerniereReflexionDeCassio(typeCalculFinale,(nbBl + nbNo) - 4 +1);
end;


BEGIN          {CoupGagnant}


  {$IFC USE_PROFILER_FINALE_FAST}
  if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr 
    then ProfilerSetStatus(1);
  {$ENDC}
  
  SetCassioEstEnTrainDeReflechir(true,@CassioEtaitEnTrainDeReflechir);

  if (interruptionReflexion = pasdinterruption) & VerifieAssertionsDeFinale() & ListeChaineeDesCasesVidesEstDisponible() then
    begin
    
    chainesDejaEcrites := MakeEmptyStringSet();

	  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
	  analyseIntegraleDeFinale := false;
	  case typeCalculFinale of
	    ReflGagnant :
	       begin
	         bestMode := false;
	       end;
	    ReflGagnantExhaustif :
	       begin
	         bestMode := false;
	       end;
	    ReflParfait :
	       begin
	         bestMode := true;
	       end;
	    ReflParfaitExhaustif :
	       begin
	         bestMode := true;
	       end;
	    ReflRetrogradeParfait :
	       begin
	         bestMode := true;
	       end;
	    ReflRetrogradeGagnant :
	       begin
	         bestMode := false;
	       end;
	    otherwise
	      begin
	        bestMode := false;
	      end;
	  end;

    doitEcrireReflexFinale := true;
    
	  if not(ScriptDeFinaleEnCours())
	    then commentaireDansRapport := commentaireDansRapport & not(jeuInstantane);
	  if debuggage.algoDeFinale then 
	    begin
	      commentaireDansRapport := true;
	      SetAutoVidageDuRapport(true);
	      SetEcritToutDansRapportLog(true);
	      WritelnDansRapport('');
	      WritelnDansRapport('Appel à CoupGagnant pour la position suivante :');
	      WritelnPositionEtTraitDansRapport(jeu,couleurFinale);
	      WriteStringAndNumDansRapport('nb de noirs = ',nbNo);
	      WritelnStringAndNumDansRapport('   et nb de blancs = ',nbBl);
	      WriteStringAndNumDansRapport('coup ',nbBl+nbNo-4+1);
	      WriteStringAndNumDansRapport(', (donc nb de cases vides = ',MFprof);
	      WritelnDansRapport(')');
	      WritelnDansRapport('');
	    end;
	  
	  
	  rechercheDejaAnnonceeDansRapport := false;
	  meilleureSuiteAEteCalculeeParOptimalite := false;
	  SetSuiteParfaiteEstConnueDansGameTree(false);
	  bestmodeArriveeDansCoupGagnant := bestMode;
	  noCoupRecherche := nbBl+nbNo-4+1;
	  coulPourMeilleurFin := couleurFinale;
	  coulDefense := -coulPourMeilleurFin;
	  positionEtTraitDeCoupGagnant := MakePositionEtTrait(jeu,coulPourMeilleurFin);
	  
	  clefHashageCoupGagnant := CalculateHashIndexFromThisNode(positionEtTraitDeCoupGagnant,gameTreeNode,dernierCoupJoue);
	  case typeCalculFinale of
	    ReflParfaitExhaustif,ReflGagnantExhaustif : 
	       coupGagnantUtiliseEndgameTrees := usingEndgameTrees & (gameTreeNode <> NIL);
	    ReflParfait,ReflGagnant : 
	       coupGagnantUtiliseEndgameTrees := usingEndgameTrees & (gameTreeNode <> NIL) & 
	                                         EstPositionEtTraitCourant(positionEtTraitDeCoupGagnant);
	    ReflRetrogradeParfait, ReflRetrogradeGagnant:
	       coupGagnantUtiliseEndgameTrees := usingEndgameTrees & (gameTreeNode <> NIL) & 
	                                         EstPositionEtTraitCourant(positionEtTraitDeCoupGagnant);
	    otherwise 
	       coupGagnantUtiliseEndgameTrees := false;
	  end; {case}
	  coupDontLeScoreEstConnu := 0;
	  
	  
	  if EstPositionEtTraitCourant(positionEtTraitDeCoupGagnant) then 
	    ViderNotesSurCases(kNotesDeCassio,true,othellierToutEntier);
	   		   
	  resultatSansCalcul := false;
	  EssaieCalculerFinaleOptimaleParOptimalite;
	  
	   
	  (* WritelnDansRapport('appel potentiel de AllocateNewEndgameTree'); *)
	  if coupGagnantUtiliseEndgameTrees then
	     begin
	       SearchPositionFromThisNode(positionEtTraitDeCoupGagnant,gameTreeNode,endgameNode);
	       if AllocateNewEndgameTree(endgameNode,numeroEndgameTreeActif)
	         then magicCookieEndgameTree := GetMagicCookieInitialEndgameTree(numeroEndgameTreeActif)
	         else magicCookieEndgameTree := 0;
	     end;
	   
	  if coupGagnantUtiliseEndgameTrees & not(seMefierDesScoresDeLArbre) then 
       begin
         RetropropagerScoreDesFilsDansGameTree(gameTreeNode);
         EffaceNoeudDansFenetreArbreDeJeu;
	       EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
         EssaieCalculerFinaleOptimaleParGameTree;
       end;
	     
	         
	   if not(resultatSansCalcul) then
	     if InitToutPourRechercheDeFinaleEnProfondeur() then
	       begin
	         
	         if (mob>1) | doitAbsolumentRamenerLaSuite | GenreDeReflexionInSet(typeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif]) then   {**** au moins deux coups jouables ****}
				     BEGIN
				       if (coulPourMeilleurFin=aQuiDeJouer) 
				         then EcritAnnonceFinaleDansMeilleureSuite(typeCalculFinale,noCoupRecherche,kDeltaFinaleInfini);
				     
				       nbcoup := 0;
				       for i := 1 to gNbreCoins_entreeCoupGagnant do
				         if move[gCoins_entreeCoupGagnant[i]]  then
				           begin 
				             nbCoup := nbCoup+1;
				             classement[nbCoup].x := gCoins_entreeCoupGagnant[i];
				           end;
				       for i := 1 to gNbreNonCoins_entreeCoupGagnant do
				         if move[gNonCoins_entreeCoupGagnant[i]]  then
				           begin 
				             nbCoup := nbCoup+1;
				             classement[nbCoup].x := gNonCoins_entreeCoupGagnant[i];
				           end;
				   
				       tempsAlloue := CalculeTempsAlloueEnFinale(CoulPourMeilleurFin);
				       SetValeursGestionTemps(tempsAlloue,0,0,0.0,0,0);
				       if afficheGestionTemps & (interruptionReflexion = pasdinterruption) then EcritGestionTemps;

				         
				       profMinimalePourClassementParMilieu := 16;
				       
				       nbNiveauxRemplissageHash := 6;
				       nbNiveauxHashExacte := 15;
				       
				       profondeurRemplissageHash := MFprof-nbNiveauxRemplissageHash;
				       ProfPourHashExacte := MFprof-nbNiveauxHashExacte;
				       
				       
				       if ProfPourHashExacte < 10 then ProfPourHashExacte := 10;
				       if profondeurRemplissageHash < 7 then profondeurRemplissageHash := 7;
				       ProfUtilisationHash := Min(ProfPourHashExacte,profondeurRemplissageHash);
				       
				       { la ligne suivante est bien !!!!}
				       profFinaleHeuristique := Max(Max(MFprof-gProfondeurCoucheEvalsHeuristiques,profMinimalePourClassementParMilieu),ProfPourHashExacte+1);
				       
				       
				       
				       {$IFC USING_BITBOARD}
				       profForceBrute := ProfPourHashExacte - 1;
				       
				       if profForceBrute < 13
				         then profForceBrute := 13;
				       
				       if profForceBrute > profMinimalePourClassementParMilieu-1 
				         then profForceBrute := profMinimalePourClassementParMilieu-1;
				         
				       if profForceBrute > profFinaleHeuristique-2
				         then profForceBrute := profFinaleHeuristique-2;
				         
				       if profForceBrute < 5 then profForceBrute := 5; (* attention : profForceBrute doit etre >= 5, sinon Boum ! *)
				       profPourTriSelonDivergence := 0;  {toujours trier selon divergence tant qu'on est dans ABFin}
				       
				         {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
				           (*profForceBrute := 30;*)
				         {$ENDC}
				         
				       profForceBrute := profFinaleHeuristique - 2;
				       if (profForceBrute > 16) then profForceBrute := 16;
				       
				       {$ELSEC}
				       profForceBrute := 7;
				       profPourTriSelonDivergence := 9;
				       {$ENDC}
				       
				       
				       
				       
				       
				       profForceBrutePlusUn := profForceBrute+1;
				       ProfPourHashExacte := Max(ProfPourHashExacte,profForceBrute+1);
				       
				       
				       (* WritelnStringAndNumDansRapport('profForceBrute = ',profForceBrute);
				       WritelnStringAndNumDansRapport('profFinaleHeuristique = ',profFinaleHeuristique);
				       WritelnStringAndNumDansRapport('ProfPourHashExacte = ',ProfPourHashExacte);
				       WritelnStringAndNumDansRapport('profMinimalePourClassementParMilieu = ',profMinimalePourClassementParMilieu);
				       WritelnStringAndNumDansRapport('ProfUtilisationHash = ',ProfUtilisationHash);
				       *)
				       
				       tempsAlloue := CalculeTempsAlloueEnFinale(CoulPourMeilleurFin);

			         SetDeltaFinalCourant(deltaSuccessifs[1]);
			         termine := false;
			         
			         PreordonnancementDesCoups;
			         {DetruitEntreesIncorrectesHashTableCoupsLegaux;}
			         
			         
			         
			        {$IFC USE_PROFILER_FINALE_FAST}
						   nomFichierProfile := PrefixeFichierProfiler() + NumEnString((TickCount()-tempsGlobalDeLaFonction) div 60) + '.preordre';
						   WritelnDansRapport('nomFichierProfile = '+nomFichierProfile);
						   if ProfilerDump(nomFichierProfile) <> NoErr 
						     then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfile+') a échoué !')
						     else ProfilerSetStatus(0);
						   ProfilerTerm;
						   {on recommence un autre profile, pour le code de finale}
						   if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr 
	                         then ProfilerSetStatus(1);
					    {$ENDC}
					    
					     if VerifieAssertionsDeFinale() then; 
			          
			         if (interruptionReflexion = pasdinterruption) & not(seMefierDesScoresDeLArbre) then
			           begin
			             MetSousArbreDansHashTableExacte(gameTreeNode,ProfPourHashExacte);
			             MetSousArbreDansHashTableExacte(gameTreeNode,ProfPourHashExacte);  {on redouble pour avoir les valeurs actualisées}
			             TrierSelonHashTableExacte(positionEtTraitDeCoupGagnant,classement,nbCoup,clefHashageCoupGagnant);
			             EffaceNoeudDansFenetreArbreDeJeu;
	      	         EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
			           end;
			         
					     if bestMode & not(GenreDeReflexionInSet(typeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif]))  {l'algo standard}
				         then
					         begin
					           bestMode := false;
							       meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[1],true,termine);
							       for i := 2 to nbreDeltaSuccessifs do
							         if not(termine) then meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[i],true,termine);
						          
						         bestMode := true;
						         meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[1],true,termine);
						         for i := 2 to nbreDeltaSuccessifs-1 do
					             if not(termine) then meilleurScore := PasseAlgoDirectionnel(meilleurScore,deltaSuccessifs[i],false,termine);
						         meilleurScore := PasseAlgoDirectionnel(meilleurScore,kDeltaFinaleInfini,false,dernierePasseTerminee);
						       end
					       else
					     if bestMode & (typeCalculFinale=ReflParfaitExhaustif)  {l'algo pour tous les scores}
				         then
					         begin
			           
					           analyseIntegraleDeFinale := false;
					           bestMode := false;
					           meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[1],true,termine);
					           for i := 2 to nbreDeltaSuccessifs do
					             if not(termine) then meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[i],true,termine);
						          
						         analyseIntegraleDeFinale := false;
						         bestMode := true;
						         meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[1],true,termine);
						         for i := 2 to nbreDeltaSuccessifs-1 do
					             if not(termine) then meilleurScore := PasseAlgoDirectionnel(meilleurScore,deltaSuccessifs[i],false,termine);
						         meilleurScore := PasseAlgoDirectionnel(meilleurScore,kDeltaFinaleInfini,false,dernierePasseTerminee);
						         
						         {on connait le meilleur coup : on l'affiche eventuellement comme suggestion de Cassio}
						         if (interruptionReflexion = pasdinterruption) & 
						            EstPositionEtTraitCourant(positionEtTraitDeCoupGagnant)
						           then ActiverSuggestionDeCassio(PositionEtTraitCourant(),classement[1].x,classement[1].theDefense,'CoupGagnant {ReflParfaitExhaustif}');
						         
						         
						         analyseIntegraleDeFinale := true;
						         bestMode := true;
						         meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[1],true,termine);
						         for i := 2 to nbreDeltaSuccessifs-1 do
					             if not(termine) then meilleurScore := PasseAlgoDirectionnel(meilleurScore,deltaSuccessifs[i],false,termine);
						         meilleurScore := PasseAlgoDirectionnel(meilleurScore,kDeltaFinaleInfini,false,dernierePasseTerminee);
						       end
						     else  {l'algo gagnant/perdant exhaustif}
						   if not(bestMode) & (typeCalculFinale=ReflGagnantExhaustif)
						     then
				           begin
				             analyseIntegraleDeFinale := false;
				             meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[1],true,termine);
				             for i := 2 to nbreDeltaSuccessifs-1 do
					             if not(termine) then meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[i],true,termine);
						         meilleurScore := PasseAlgoDirectionnel(0,kDeltaFinaleInfini,false,dernierePasseTerminee);
						         
						         {on connait un coup gagnant : on l'affiche eventuellement comme suggestion de Cassio}
						         if (interruptionReflexion = pasdinterruption) & (classement[1].note >= 0) & 
						            EstPositionEtTraitCourant(positionEtTraitDeCoupGagnant) then
						           ActiverSuggestionDeCassio(PositionEtTraitCourant(),classement[1].x,classement[1].theDefense,'CoupGagnant {ReflGagnantExhaustif}');
						         
						         analyseIntegraleDeFinale := true;
				             meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[1],true,termine);
				             for i := 2 to nbreDeltaSuccessifs-1 do
					             if not(termine) then meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[i],true,termine);
						         meilleurScore := PasseAlgoDirectionnel(0,kDeltaFinaleInfini,false,dernierePasseTerminee);
				           end
						     else  {l'algo gagnant/perdant standard}
				           begin
				             meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[1],true,termine);
				             for i := 2 to nbreDeltaSuccessifs-1 do
					             if not(termine) then meilleurScore := PasseAlgoDirectionnel(0,deltaSuccessifs[i],not(bestMode),termine);
						         meilleurScore := PasseAlgoDirectionnel(0,kDeltaFinaleInfini,false,dernierePasseTerminee);
				           end;
				          
				       {meilleurScore := Algo_NegaCStar(-64,64,coulPourMeilleurFin,MFprof,nbbl,nbno,jeu,meilleurX);}
				       {meilleurScore := Algo_SSSStar(-64,64,coulPourMeilleurFin,MFprof,nbbl,nbno,jeu,meilleurX);}
				       {meilleurScore := Algo_AlphaBetaBrut(-64,64,coulPourMeilleurFin,MFprof,nbbl,nbno,jeu,meilleurX);}
				     
				 {      WritelnstringandnumDansRapport('score=',meilleurScore);
			          WritelnstringandnumDansRapport('meilleurCoup=',meilleurX);     }
				               
				        CoupGagnant := (meilleurScore>=0);     
			               
			        END
	          else             { sinon on cherche l'unique coup }
	            BEGIN
	              for i := 1 to 64 do
	               if move[othellier[i]] then
	                 begin
	                    meilleurX := othellier[i];
	                    bstdef := 44;
	                    CoupGagnant := true;
	                    Meilleurscore := ScorePourUnSeulCoupLegal;
	                 end; 
	               EcritMeilleureSuiteParOptimalite;
	               if analyseRetrograde.EnCours then
	                 if messageHandle <> NIL then
	                   begin
	                     typeDataDansHandle := messageHandle^^.typeData;
	                     case typeDataDansHandle of
	                       ReflScoreDejaConnuFinale,ReflScoreDeCeCoupConnuFinale :
	                         if CoulPourMeilleurFin = pionNoir
	                           then scoreDeNoir :=  messageHandle^^.data[0]
	                           else scoreDeNoir := -messageHandle^^.data[0];
	                       otherwise 
	                          AlerteSimple('typeDataDansHandle inconnu dans UnitFinaleFast !');
	                     end; {case}
	                     if bestMode
	                       then MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleParfaite,scoreDeNoir)
	                       else MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleWLD,scoreDeNoir);
	                   end;
	            END;
	            
	         LibereToutPourRechercheDeFinaleEnProfondeur;
	      end; 
	  
	  
	  if coupGagnantUtiliseEndgameTrees then 
	    begin
	      DetruitLesFilsVirtuelsInutilesDeCeNoeud(endgameNode);
	      DetruitLesFilsVirtuelsInutilesDeCeNoeud(gameTreeNode);
	      EffaceNoeudDansFenetreArbreDeJeu;
	      EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
	    end;
	  if EndgameTreeEstValide(numeroEndgameTreeActif) then 
	    LibereEndgameTree(numeroEndgameTreeActif);
	  (* EcritStatistiquesEndgameTrees; *)
	    
	  
	  DisposeStringSet(chainesDejaEcrites);
	  
    end;
    
  {if (interruptionReflexion <> pasdinterruption) then VideToutesLesHashTablesExactes;}
  
  {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
  for i := 0 to 64 do
    begin
      if nbAppelsABFinPetite[i] <> 0 then
        WritelnStringAndNumEnSeparantLesMilliersDansRapport('nb noeuds/appel de ABFinPetite['+NumEnString(i)+'] = ',nbNoeudsDansABFinPetite[i] div nbAppelsABFinPetite[i]);
    end;
  {$ENDC}
  
  {$IFC USE_PROFILER_FINALE_FAST}
   nomFichierProfile := PrefixeFichierProfiler() + NumEnString(tempsGlobalDeLaFonction div 60) + '.profile';
   WritelnDansRapport('nomFichierProfile = '+nomFichierProfile);
   if ProfilerDump(nomFichierProfile) <> NoErr 
     then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfile+') a échoué !')
     else ProfilerSetStatus(0);
   ProfilerTerm;
  {$ENDC}
  
  
  SetGenreDerniereReflexionDeCassio(typeCalculFinale,(nbBl + nbNo) - 4 +1);
  SetCassioEstEnTrainDeReflechir(CassioEtaitEnTrainDeReflechir,NIL);
END;  {CoupGagnant}


END.