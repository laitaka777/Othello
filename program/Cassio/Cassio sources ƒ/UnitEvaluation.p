UNIT UnitEvaluation;

INTERFACE







USES UnitOth0,UnitPositionEtTrait;



function Evaluation(var position : plateauOthello;
                    CoulEvaluation,nbBlancs,nbNoirs : SInt32;
                    var jouable : plBool;
                    var front : InfoFrontRec;
                    AfraidOfWipeOut : boolean;
                    alpha,beta : SInt32;
                    var nbEvaluationsRecursives : SInt32) : SInt32;
function CreeEvaluationCassioRec(var position : plateauOthello;
                                 CoulEvaluation,nbBlancs,nbNoirs : SInt32;
                                 var jouable : plBool;
                                 var front : InfoFrontRec) : EvaluationCassioRec;                    
     
function EvaluationMaximisation(var position : plateauOthello;CoulEvaluation,nbBlancs,nbNoirs : SInt32) : SInt32;
function EvaluationDesBords(var position : plateauOthello;CoulEvaluation : SInt32; var front : InfoFrontRec) : SInt32;


function EvaluationHorsContexte(var whichPos : PositionEtTraitRec) : SInt32;


var avecRecursiviteDansEval : boolean;
    peutDebrancherRecursiviteDansEval : boolean;


IMPLEMENTATION







USES UnitNouvelleEval,UnitStrategie,UnitBlocsDeCoin,UnitBords,UnitRapport;






function EstLaPositionBizarreDansEvaluation(var position : plateauOthello;CoulEvaluation : SInt32) : boolean;
var chainePositionBizarre : str255;
    positionEvalueeBizarrement : PositionEtTraitRec;
begin
	chainePositionBizarre := '--XO-X-X---OOXXXXXXOXOX-XXOOXXOOXXXOXOOOXXXXOOOOX-XXOOOO--XXXXXX';
  positionEvalueeBizarrement := PositionRapportEnPositionEtTrait(chainePositionBizarre,pionBlanc);
  if SamePositionEtTrait(MakePositionEtTrait(position,CoulEvaluation), positionEvalueeBizarrement) 
    then
      begin
        EstLaPositionBizarreDansEvaluation := true;
        WritelnDansRapport('Je suis arrivé à la position bizarre');
      end
    else
      EstLaPositionBizarreDansEvaluation := false;
end;



function AlphaBetaLocalDansEvaluation(var position : plateauOthello;CoulEvaluation,nbBlancs,nbNoirs : SInt32; var jouable : plBool; var front : InfoFrontRec;AfraidOfWipeOut : boolean; var alpha,beta : SInt32; var dejaEssayes : plBool) : SInt32;
var platRecur : plateauOthello;
    jouableRecur : plBool;
    frontRecur : InfoFrontRec;
    nbBlancsRecur,nbNoirsRecur : SInt32;
    evalApresCoupCritique,MaxApresTousLesCoupsCritiques : SInt32;
    k,nbAppelsRecursifs : SInt32;
    (* ecrireCoupsCritiques : boolean; *)
    
  procedure EvalueCoupCritique(caseCritique : SInt32);
  begin
  
    {
     if (indexDansTableABLocal<0) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : indexDansTableABLocal<0 !!');
	      WritelnStringAndNumDansRapport('indexDansTableABLocal=',indexDansTableABLocal);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (indexDansTableABLocal>kTaille_Max_Index_Bords_AB_Local) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : indexDansTableABLocal>kTaille_Max_Index_Bords_AB_Local !!');
	      WritelnStringAndNumDansRapport('indexDansTableABLocal=',indexDansTableABLocal);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	  
	 if (table_index_bords_AB_local[indexDansTableABLocal]<1) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : table_index_bords_AB_local[indexDansTableABLocal]<1 !!');
	      WritelnStringAndNumDansRapport('table_index_bords_AB_local[indexDansTableABLocal]=',table_index_bords_AB_local[indexDansTableABLocal]);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (table_index_bords_AB_local[indexDansTableABLocal]>8) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : table_index_bords_AB_local[indexDansTableABLocal]>8 !!');
	      WritelnStringAndNumDansRapport('table_index_bords_AB_local[indexDansTableABLocal]=',table_index_bords_AB_local[indexDansTableABLocal]);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (caseCritique<=10) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : caseCritique<11 !!');
	      WritelnStringAndNumDansRapport('caseCritique=',caseCritique);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (caseCritique>=89) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : caseCritique>88 !!');
	      WritelnStringAndNumDansRapport('caseCritique=',caseCritique);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
   }
   
    (*
     if ecrireCoupsCritiques | EstLaPositionBizarreDansEvaluation(position,CoulEvaluation) then
        begin
          WritelnDansRapport('   ………position bizarre dans EvalueCoupCritique');
          WritelnStringAndCoupDansRapport('   caseCritique = ',caseCritique);
        end;
     *)
     
       
     if not(dejaEssayes[caseCritique]) then
       begin
         dejaEssayes[caseCritique] := true;
         
         platRecur := position;
         jouableRecur := jouable;
         nbBlancsRecur := nbBlancs;
         nbNoirsRecur := nbNoirs;
         frontRecur := front;
         if ModifPlat(caseCritique,coulEvaluation,platRecur,jouableRecur,nbBlancsRecur,nbNoirsRecur,frontRecur) 
          then
            begin
              {AjouteDansStatistiquesDeBordsABLocal(essai_bord_AB_local,bord,indexDansTable);}
              evalApresCoupCritique := -Evaluation(platRecur,-CoulEvaluation,nbBlancsRecur,nbNoirsRecur,jouableRecur,frontRecur,
                                                   AfraidOfWipeOut,-beta,-alpha,nbAppelsRecursifs);
              
              if evalApresCoupCritique>MaxApresTousLesCoupsCritiques then 
                begin
                  MaxApresTousLesCoupsCritiques := evalApresCoupCritique;
                  
                  if (MaxApresTousLesCoupsCritiques >= beta) then 
                    begin
                      {AjouteDansStatistiquesDeBordsABLocal(coupure_bord_AB_local,bord,indexDansTable);}
                      AlphaBetaLocalDansEvaluation := MaxApresTousLesCoupsCritiques;
                      exit(AlphaBetaLocalDansEvaluation);
                    end;
                    
                  if (MaxApresTousLesCoupsCritiques > alpha) then alpha := MaxApresTousLesCoupsCritiques;
                end;
            end;
       end;
   end;

   
begin
  MaxApresTousLesCoupsCritiques := -30000;
  
  (* ecrireCoupsCritiques := false;
  if EstLaPositionBizarreDansEvaluation(position,CoulEvaluation) then
    begin
      WritelnDansRapport('   ………position bizarre dans AlphaBetaLocalDansEvaluation');
      WritelnStringAndNumDansRapport('   alpha = ',alpha);
      WritelnStringAndNumDansRapport('   beta = ',beta);
      ecrireCoupsCritiques := true;
    end; *)
  
  with front do
	  if CoulEvaluation = pionBlanc
	     then
	       begin
	         for k := table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordNord]-1] to table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordNord]]-1 do
	           EvalueCoupCritique(caseBordNord[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordOuest]-1] to table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordOuest]]-1 do
	           EvalueCoupCritique(caseBordOuest[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordEst]-1] to table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordEst]]-1 do
	           EvalueCoupCritique(caseBordEst[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordSud]-1] to table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordSud]]-1 do
	           EvalueCoupCritique(caseBordSud[table_index_bords_AB_local[k]]);
	       end
	     else
	       begin
	         for k := table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordNord]-1] to table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordNord]]-1 do
	           EvalueCoupCritique(caseBordNord[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordOuest]-1] to table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordOuest]]-1 do
	           EvalueCoupCritique(caseBordOuest[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordEst]-1] to table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordEst]]-1 do
	           EvalueCoupCritique(caseBordEst[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordSud]-1] to table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordSud]]-1 do
	           EvalueCoupCritique(caseBordSud[table_index_bords_AB_local[k]]);
	       end;
	 
   AlphaBetaLocalDansEvaluation := MaxApresTousLesCoupsCritiques;
end;


function AlphaBetaCoupsTranquillesDansEvaluation(var position : plateauOthello;CoulEvaluation,nbBlancs,nbNoirs : SInt32; var jouable : plBool; var front : InfoFrontRec;AfraidOfWipeOut : boolean; var alpha,beta : SInt32; var listeDesCoupsTranquilles : ListeDeCases; var dejaEssayes : plBool) : SInt32;
var platRecur : plateauOthello;
    jouableRecur : plBool;
    frontRecur : InfoFrontRec;
    nbBlancsRecur,nbNoirsRecur : SInt32;
    evalApresCoupTranquille,MaxApresTousLesCoupsTranquilles : SInt32;
    k,nbAppelsRecursifs : SInt32;
    
  procedure EvalueCoupTranquille(coupTranquille : SInt32);
  begin
  
  {	  
	 if (coupTranquille<=10) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : coupTranquille<11 !!');
	      WritelnStringAndNumDansRapport('coupTranquille=',coupTranquille);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (coupTranquille>=89) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : coupTranquille>88 !!');
	      WritelnStringAndNumDansRapport('coupTranquille=',coupTranquille);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
    }
    
    
     if not(dejaEssayes[coupTranquille]) then
       begin
  
         dejaEssayes[coupTranquille] := true;
         
         platRecur := position;
         jouableRecur := jouable;
         nbBlancsRecur := nbBlancs;
         nbNoirsRecur := nbNoirs;
         frontRecur := front;
         if ModifPlat(coupTranquille,coulEvaluation,platRecur,jouableRecur,nbBlancsRecur,nbNoirsRecur,frontRecur) 
          then
            begin
              evalApresCoupTranquille := -Evaluation(platRecur,-CoulEvaluation,nbBlancsRecur,nbNoirsRecur,jouableRecur,frontRecur,
                                                     AfraidOfWipeOut,-beta,-alpha,nbAppelsRecursifs);
              
              if evalApresCoupTranquille>MaxApresTousLesCoupsTranquilles then 
                begin
                  MaxApresTousLesCoupsTranquilles := evalApresCoupTranquille;
                  
                  if (MaxApresTousLesCoupsTranquilles >= beta) then 
                    begin
                      {if utilisationNouvelleEval then
                        begin
    			                SysBeep(0);
    		  	              WritelnStringDansRapport('coupTranquille='+CoupEnStringEnMajuscules(coupTranquille));
    			                WritelnPositionEtTraitDansRapport(position,coulEvaluation);
    			                AttendFrappeClavier;
    			              end;}
    	                AlphaBetaCoupsTranquillesDansEvaluation := MaxApresTousLesCoupsTranquilles;
                      exit(AlphaBetaCoupsTranquillesDansEvaluation);
                    end;
                    
                  if (MaxApresTousLesCoupsTranquilles > alpha) then alpha := MaxApresTousLesCoupsTranquilles;
                end;
            end;
        end;
   end;

   
begin
  MaxApresTousLesCoupsTranquilles := -30000;
  
  
  for k := 1 to listeDesCoupsTranquilles.cardinal do {tout l'othellier, sauf les bords, les cases X et le carre E4-E5-D4-D5}
    EvalueCoupTranquille(listeDesCoupsTranquilles.liste[k]);
  
  
  AlphaBetaCoupsTranquillesDansEvaluation := MaxApresTousLesCoupsTranquilles;
end;



function Evaluation(var position : plateauOthello;CoulEvaluation,nbBlancs,nbNoirs : SInt32;
                    var jouable : plBool; var front : InfoFrontRec;AfraidOfWipeOut : boolean;
                    alpha,beta : SInt32; var nbEvaluationsRecursives : SInt32) : SInt32;
const MoinsInfini = -30000;
var t,x,evalPartielle,adversaire,coins,centre,petitcentre : SInt32;
    evalFrontiere,evalMobilite,mobiliteCoulEvaluation,mobiliteAdversaire : SInt32;
    platRecur : plateauOthello;
    jouableRecur : plBool;
    frontRecur : InfoFrontRec;
    dejaEssayes : plBool;
    nbBlancsRecur,nbNoirsRecur : SInt32;
    evalApresPriseCoin,MaxApresPriseCoin : SInt32;
    valeurAlphaBetaCoins,valeurAlphaBetaBordsCritiques : SInt32;
    evalFrontiereNonLineaire{,evalRendementDeLaFrontriere} : SInt32;
    listeDesCoupsTranquilles,listeDesCoupsTranquillesAdversaire : ListeDeCases;
    valeurAlphaBetaCoupsTranquilles : SInt32;
    nbAppelsRecursifs : SInt32;
    legal : boolean;
    
begin   

  {
  if avecEvaluationDeFisher & ((nbBlancs+nbNoirs-4)<=45) then 
	  begin
		  Evaluation := EvaluationDeFisher(position,CoulEvaluation,nbBlancs,nbNoirs,jouable,front,alpha,beta);
		  nbEvaluationsRecursives := 1;
		  exit(Evaluation);
		end;
	 }
	
	(*
  if EstLaPositionBizarreDansEvaluation(position,CoulEvaluation) then
    begin
      WritelnDansRapport('   ………position bizarre dans Evaluation');
      WritelnStringAndBooleenDansRapport('   avecRecursiviteDansEval = ',avecRecursiviteDansEval);
      WritelnStringAndNumDansRapport('   alpha = ',alpha);
      WritelnStringAndNumDansRapport('   beta = ',beta);
    end;
  *)
	
  if (nbBlancs = 0) then 
		begin
		  if utilisationNouvelleEval
		    then
		      if CoulEvaluation = pionBlanc
			      then Evaluation := {-100*nbNoirs} -6400
			      else Evaluation := {100*nbNoirs }  6400
		    else
		      if CoulEvaluation = pionBlanc
			      then Evaluation := {-500*nbNoirs} 32000
			      else Evaluation := {500*nbNoirs} -32000;
		  exit(Evaluation);
		end;
  if (nbNoirs = 0) then 
    begin
      if utilisationNouvelleEval
        then
          if CoulEvaluation = pionBlanc
			      then Evaluation := {100*nbBlancs}   6400
			      else Evaluation := {-100*nbBlancs} -6400
        else
			    if CoulEvaluation = pionBlanc
			      then Evaluation := {500*nbBlancs} 32000
			      else Evaluation := {-500*nbBlancs} -32000;
	    exit(Evaluation);
	  end;

  nbEvaluationsRecursives := nbreFeuillesMilieu;  {par definition nbEvaluationsRecursives = delta(nbreFeuillesMilieu)}
  inc(nbreFeuillesMilieu);
  adversaire := -CoulEvaluation;
  listeDesCoupsTranquilles.cardinal := 0;
  valeurAlphaBetaCoins := -32000;
  
  MemoryFillChar(@dejaEssayes,sizeof(dejaEssayes),chr(0));
  
  if utilisationNouvelleEval
    then
      begin
        evalPartielle := 0;
      
        {prises de coin}
			  MaxApresPriseCoin := MoinsInfini;
			  if avecRecursiviteDansEval then
			  for t := 1 to 4 do   
					begin
					  x := othellier[t];
					  if Jouable[x] then 
					    begin 
					      if PeutJouerIci(coulEvaluation,x,position) then   {minimax local}
					        begin
					            
					          platRecur := position;
					          jouableRecur := jouable;
					          nbBlancsRecur := nbBlancs;
					          nbNoirsRecur := nbNoirs;
					          frontRecur := front;
					          legal := ModifPlat(x,coulEvaluation,platRecur,jouableRecur,nbBlancsRecur,nbNoirsRecur,frontRecur);
					          evalApresPriseCoin := -Evaluation(platRecur,adversaire,nbBlancsRecur,nbNoirsRecur,jouableRecur,frontRecur,
					                                            AfraidOfWipeOut,-beta,-alpha,nbAppelsRecursifs);
					          if evalApresPriseCoin>MaxApresPriseCoin then MaxApresPriseCoin := evalApresPriseCoin;
					            
					          if (MaxApresPriseCoin >= beta) then 
					            begin
					              Evaluation := MaxApresPriseCoin;
					              nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
					              exit(Evaluation);
					            end;
					            
					          if (MaxApresPriseCoin > alpha) then alpha := MaxApresPriseCoin;
					        end;
					    end;
					  dejaEssayes[x] := true;
					end;
			  valeurAlphaBetaCoins := MaxApresPriseCoin;
      
        {appel de la nouvelle evaluation}
        
        (*
        if CoulEvaluation = pionNoir
          then evalPartielle := NewEvalEnInteger(position,jouable,front,nbNoirs,nbBlancs,CoulEvaluation,vecteurEvaluation,listeDesCoupsTranquilles,listeDesCoupsTranquillesAdversaire)
          else evalPartielle := NewEvalEnInteger(position,jouable,front,nbNoirs,nbBlancs,CoulEvaluation,vecteurEvaluation,listeDesCoupsTranquillesAdversaire,listeDesCoupsTranquilles);
        *)
        if CoulEvaluation = pionNoir
          then evalPartielle := NewEvalDeCassio(position,jouable,front,nbNoirs,nbBlancs,CoulEvaluation,vecteurEvaluationInteger,listeDesCoupsTranquilles,listeDesCoupsTranquillesAdversaire,alpha,beta)
          else evalPartielle := NewEvalDeCassio(position,jouable,front,nbNoirs,nbBlancs,CoulEvaluation,vecteurEvaluationInteger,listeDesCoupsTranquillesAdversaire,listeDesCoupsTranquilles,alpha,beta);

      end
    else
      begin
			  if evaluationAleatoire
				  then evalPartielle := -penalitePourLeTrait+ (Random() mod 200)
				  else evalPartielle := -penalitePourLeTrait;
				  
			  if (nbBlancs<=3) & (nbNoirs>13) & AfraidOfWipeOut then
			    if (CoulEvaluation = pionBlanc) 
				  then evalPartielle := evalPartielle-5000
				  else evalPartielle := evalPartielle+5000;
			  if (nbNoirs<=3) & (nbBlancs>13) & AfraidOfWipeOut then
				if (CoulEvaluation = pionNoir) 
				  then evalPartielle := evalPartielle-5000
				  else evalPartielle := evalPartielle+5000;

			 {prises et sacrifices de coin}
			  MaxApresPriseCoin := MoinsInfini;
			  for t := 1 to 4 do   
				begin
				  x := othellier[t];
				  if Jouable[x] then 
				    begin 
				      if PeutJouerIci(adversaire,x,position) then evalPartielle := evalPartielle-valDefenseCoin;
				      if PeutJouerIci(coulEvaluation,x,position) then   {minimax local}
				        begin
				          evalPartielle := evalPartielle+valPriseCoin;
				            
				          platRecur := position;
				          jouableRecur := jouable;
				          nbBlancsRecur := nbBlancs;
				          nbNoirsRecur := nbNoirs;
				          frontRecur := front;
				          legal := ModifPlat(x,coulEvaluation,platRecur,jouableRecur,nbBlancsRecur,nbNoirsRecur,frontRecur);
				          evalApresPriseCoin := -Evaluation(platRecur,adversaire,nbBlancsRecur,nbNoirsRecur,jouableRecur,frontRecur,
				                                            AfraidOfWipeOut,-beta,-alpha,nbAppelsRecursifs);
				          if evalApresPriseCoin>MaxApresPriseCoin then MaxApresPriseCoin := evalApresPriseCoin;
				            
				          if (MaxApresPriseCoin >= beta) then 
				            begin
				              Evaluation := MaxApresPriseCoin;
				              nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
				              exit(Evaluation);
				            end;
				            
				          if (MaxApresPriseCoin > alpha) then alpha := MaxApresPriseCoin;
				        end;
				      dejaEssayes[x] := true;
				    end;
				end;
			  valeurAlphaBetaCoins := MaxApresPriseCoin;
			    
			  
			  
			    
			  petitcentre := valPionpetitcentre*(position[casepetitcentre1]+position[casepetitcentre2]+
			                                   position[casepetitcentre3]+position[casepetitcentre4]+
			                                   position[casepetitcentre5]+position[casepetitcentre6]+
			                                   position[casepetitcentre7]+position[casepetitcentre8]);
			  centre := valPionCentre*(position[Casecentre1]+position[Casecentre2]+
			                         position[Casecentre3]+position[Casecentre4]);
			  coins := valCoin*(position[88]+position[11]+position[18]+position[81]);
			    
			  with front do
			   begin
			    if CoulEvaluation = pionBlanc   {evaluation pour Blanc}
			      then
			        begin
			        
			          evalPartielle := evalPartielle+NoteJeuCasesXPourBlanc(position,nbNoirs,nbBlancs);
			        
			          if (position[11] = pionVide) & (position[18] = pionVide) & (position[81] = pionVide) & (position[88] = pionVide)
			            then evalPartielle := evalPartielle+valMinimisationAvantCoins*(nbBlancs-nbNoirs);
			            {else evalPartielle := evalPartielle+valMinimisationApresCoins*(nbBlancs-nbNoirs);}
			          evalPartielle := evalPartielle+centre;
			          evalPartielle := evalPartielle+petitcentre;
			          evalPartielle := evalPartielle+coins;
			          
			          evalPartielle := evalPartielle-occupationTactique;
			          evalPartielle := evalPartielle+valeurBord^[AdressePattern[kAdresseBordSud]]+valeurBord^[AdressePattern[kAdresseBordOuest]]+valeurBord^[AdressePattern[kAdresseBordEst]]+valeurBord^[AdressePattern[kAdresseBordNord]];
			          
			          
			          evalPartielle := evalPartielle+TrousDeTroisNoirsHorribles(position);
			          evalPartielle := evalPartielle-TrousDeTroisBlancsHorribles(position);
			          evalPartielle := evalPartielle+LibertesBlanchesSurCasesA(position,front);
			          evalPartielle := evalPartielle-LibertesNoiresSurCasesA(position,front);
			          evalPartielle := evalPartielle+LibertesBlanchesSurCasesB(position);
			          evalPartielle := evalPartielle-LibertesNoiresSurCasesB(position);
			          
			          
			          
			          evalPartielle := evalPartielle-BordDeSixNoirAvecPrebordHomogene(position,front);
			          evalPartielle := evalPartielle+BordDeSixBlancAvecPrebordHomogene(position,front);
			          evalPartielle := evalPartielle+ArnaqueSurBordDeCinqBlanc(position,front);
			          evalPartielle := evalPartielle-ArnaqueSurBordDeCinqNoir(position,front);
			            
			          
			          evalPartielle := evalPartielle+(4+((nbBlancs+nbNoirs) div 4))*ValeurBlocsDeCoinPourBlanc(position);  
			        
			          
			          {evalPartielle := evalPartielle-NoteCasesCoinsCarreCentralPourNoir(position);}
			          
			          {
			          evalPartielle := evalPartielle+TrousNoirsDeDeuxPerdantLaParite(position);
			          evalPartielle := evalPartielle-TrousBlancsDeDeuxPerdantLaParite(position);
			          }
			          
			          {
			            begin
			              evalPartielle := evalPartielle+BonsBordsDeCinqBlancs(position,front);
			              evalPartielle := evalPartielle-BonsBordsDeCinqNoirs(position,front);
			              evalPartielle := evalPartielle+TrousNoirsDeDeuxPerdantLaParite(position);
			              evalPartielle := evalPartielle-TrousBlancsDeDeuxPerdantLaParite(position);
			              evalPartielle := evalPartielle+ValeurBlocsDeCoinPourBlanc(position);
			              evalPartielle := evalPartielle-NotationBordsOpposesPourNoir(position);
			            end;
			          }
			          
			          
			          {
			          if avecselectivite then 
			            evalPartielle := evalPartielle + valBordDeCinqTransformable*nbBordDeCinqTransformablesPourBlanc(position,front);
			          }
			          
			        end
			      else     
			        begin       {evaluation pour Noir}
			        
			          evalPartielle := evalPartielle+NoteJeuCasesXPourNoir(position,nbNoirs,nbBlancs);
			        
			          if (position[11] = pionVide) & (position[18] = pionVide) & (position[81] = pionVide) & (position[88] = pionVide)
			            then evalPartielle := evalPartielle+valMinimisationAvantCoins*(nbNoirs-nbBlancs);
			            {else evalPartielle := evalPartielle+valMinimisationApresCoins*(nbNoirs-nbBlancs);}
			          evalPartielle := evalPartielle-centre;
			          evalPartielle := evalPartielle-petitcentre;
			          evalPartielle := evalPartielle-coins;
			         
			          evalPartielle := evalPartielle+occupationTactique;
			          evalPartielle := evalPartielle+valeurBord^[-AdressePattern[kAdresseBordSud]]+valeurBord^[-AdressePattern[kAdresseBordOuest]]+valeurBord^[-AdressePattern[kAdresseBordEst]]+valeurBord^[-AdressePattern[kAdresseBordNord]];
			          
			          
			          evalPartielle := evalPartielle-TrousDeTroisNoirsHorribles(position);
			          evalPartielle := evalPartielle+TrousDeTroisBlancsHorribles(position);
			          evalPartielle := evalPartielle-LibertesBlanchesSurCasesA(position,front);
			          evalPartielle := evalPartielle+LibertesNoiresSurCasesA(position,front);
			          evalPartielle := evalPartielle-LibertesBlanchesSurCasesB(position);
			          evalPartielle := evalPartielle+LibertesNoiresSurCasesB(position);
			          
			          
			          
			          evalPartielle := evalPartielle+BordDeSixNoirAvecPrebordHomogene(position,front);
			          evalPartielle := evalPartielle-BordDeSixBlancAvecPrebordHomogene(position,front);
			          evalPartielle := evalPartielle-ArnaqueSurBordDeCinqBlanc(position,front);
			          evalPartielle := evalPartielle+ArnaqueSurBordDeCinqNoir(position,front);
			          
			          evalPartielle := evalPartielle+(4+((nbBlancs+nbNoirs) div 4))*ValeurBlocsDeCoinPourNoir(position);            
			          
			            
			          {evalPartielle := evalPartielle+NoteCasesCoinsCarreCentralPourNoir(position);}
			         
			         {
			          evalPartielle := evalPartielle-TrousNoirsDeDeuxPerdantLaParite(position);
			          evalPartielle := evalPartielle+TrousBlancsDeDeuxPerdantLaParite(position);
			          }
			          
			          {
			            begin
			             evalPartielle := evalPartielle-BonsBordsDeCinqBlancs(position,front);
			             evalPartielle := evalPartielle+BonsBordsDeCinqNoirs(position,front);
			             evalPartielle := evalPartielle-TrousNoirsDeDeuxPerdantLaParite(position);
			             evalPartielle := evalPartielle+TrousBlancsDeDeuxPerdantLaParite(position);
			             evalPartielle := evalPartielle+ValeurBlocsDeCoinPourNoir(position);
			             evalPartielle := evalPartielle+NotationBordsOpposesPourNoir(position);
			             evalPartielle := evalPartielle+NoteCasesCoinsCarreCentralPourNoir(position);
			            end;
			          }
			          
			          {
			          if avecselectivite then 
			            evalPartielle := evalPartielle - valBordDeCinqTransformable*nbBordDeCinqTransformablesPourBlanc(position,front);
			          }
			        end;
			        
			     
			     
			     evalFrontiere  := valFrontiere*(nbadjacent[adversaire]-nbadjacent[CoulEvaluation]) +
			                         valEquivalentFrontiere*(nbfront[adversaire]-nbfront[CoulEvaluation]);    
			     evalPartielle := evalPartielle + evalFrontiere;
			     
			     
			     
			     
			     mobiliteCoulEvaluation := MobiliteSemiTranquilleAvecCasesC(CoulEvaluation,position,jouable,front,listeDesCoupsTranquilles,100000);
			     mobiliteAdversaire     := MobiliteSemiTranquilleAvecCasesC(adversaire,position,jouable,front,listeDesCoupsTranquillesAdversaire,100000);
			     evalMobilite           := valMobiliteUnidirectionnelle*(mobiliteCoulEvaluation-mobiliteAdversaire);
			     evalPartielle          := evalPartielle + evalMobilite;

			       
			     {grosse masse}
			     if (mobiliteCoulEvaluation <= seuilMobilitePourGrosseMasse) & (evalFrontiere>=0) then
			       if CalculeMobilite(CoulEvaluation,position,jouable) <= 5 then
			       begin
			         {EssaieSetPortWindowPlateau;
			         if (CoulEvaluation = pionNoir)
			           then WriteStringAt('grosse masse de O (ennemie) ',10,125)
			           else WriteStringAt('grosse masse de X (ennemie) ',10,125);
			         WriteStringAndNumAt('evalPartielle avant=',evalPartielle,10,135);}
			         evalPartielle := evalPartielle-valGrosseMasse;
			        {ecritPositionAt(position,10,10);
			         WriteStringAndNumAt('evalPartielle apres=',evalPartielle,10,145);
			         AttendFrappeClavier;}
			       end;      
			    
			     evalFrontiereNonLineaire := 3*(nbadjacent[adversaire]*nbfront[adversaire] - 
			                                   nbadjacent[CoulEvaluation]*nbfront[CoulEvaluation]);
			     if evalFrontiereNonLineaire >  700 then evalFrontiereNonLineaire := 700;
			     if evalFrontiereNonLineaire < -700 then evalFrontiereNonLineaire := -700;
			     evalPartielle := evalPartielle + evalFrontiereNonLineaire;
			           
			     (*
			     if (nbfront[adversaire] <> 0) & (nbfront[CoulEvaluation] <> 0) {& (nbfront[adversaire] >= nbfront[CoulEvaluation])} then
			     begin
			       evalRendementDeLaFrontriere := (valRendementDeLaFrontiere*mobiliteCoulEvaluation) div Min(20,6+nbfront[adversaire])
			                                      - (valRendementDeLaFrontiere*mobiliteAdversaire)     div Min(20,6+nbfront[CoulEvaluation]);
			       if evalRendementDeLaFrontriere >  600 then evalRendementDeLaFrontriere := 600;
			       if evalRendementDeLaFrontriere < -600 then evalRendementDeLaFrontriere := -600;
			       evalPartielle := evalPartielle + evalRendementDeLaFrontriere;
			     end;
			     
			     evalPartielle := evalPartielle + Min(600,(nbadjacent[adversaire]*nbfront[adversaire]))
			                                         - Min(600,(nbadjacent[CoulEvaluation]*nbfront[CoulEvaluation]));}
			     if (nbfront[adversaire] <> 0) & (nbfront[CoulEvaluation] <> 0) & (nbfront[adversaire] >= nbfront[CoulEvaluation]) then
				 evalPartielle := evalPartielle + ((valRendementDeLaFrontiere*mobiliteCoulEvaluation) div (Min(20,6+nbfront[adversaire]))) 
				                               - ((valRendementDeLaFrontiere*mobiliteAdversaire) div (Min(20,6+nbfront[CoulEvaluation])));
			     *)
			          
			     { evalPartielle := evalPartielle+
			                      +50*( nbLibertes(CoulEvaluation,position,jouable)
			                            -nbLibertes(adversaire,position,jouable)); }      
			     
			    end;  { with front do }      
      end;

  if valeurAlphaBetaCoins > evalPartielle then evalPartielle := valeurAlphaBetaCoins;
  
  {
  if (MaxApresPriseCoin <> MoinsInfini) & 
     (MaxApresPriseCoin < evalPartielle) then
    begin
      if MaxApresPriseCoin > (evalPartielle - valPriseCoin)
        then evalPartielle := MaxApresPriseCoin
        else evalPartielle := evalPartielle - valPriseCoin;
    end;
  }
  
  if (evalPartielle >= beta) then 
    begin
      Evaluation := evalPartielle;
      nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
      exit(Evaluation);
    end;
  if (evalPartielle > alpha) then alpha := evalPartielle;

  if avecRecursiviteDansEval then
    begin
    
		  if (listeDesCoupsTranquilles.cardinal>0) then
		    begin
				  valeurAlphaBetaCoupsTranquilles := AlphaBetaCoupsTranquillesDansEvaluation(position,CoulEvaluation,nbBlancs,nbNoirs,jouable,front,AfraidOfWipeOut,alpha,beta,listeDesCoupsTranquilles,dejaEssayes);
				  
				  if (valeurAlphaBetaCoupsTranquilles >= beta) then 
				    begin
				      Evaluation := valeurAlphaBetaCoupsTranquilles;
				      nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
				      exit(Evaluation);
				    end;
				  if (valeurAlphaBetaCoupsTranquilles > evalPartielle) 
				    then evalPartielle := valeurAlphaBetaCoupsTranquilles;
		    end;

		  valeurAlphaBetaBordsCritiques := AlphaBetaLocalDansEvaluation(position,CoulEvaluation,nbBlancs,nbNoirs,jouable,front,AfraidOfWipeOut,alpha,beta,dejaEssayes);
		  if (valeurAlphaBetaBordsCritiques >= beta) then 
		    begin
		      Evaluation := valeurAlphaBetaBordsCritiques;
		      nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
		      exit(Evaluation);
		    end;
		  if valeurAlphaBetaBordsCritiques > evalPartielle 
		    then evalPartielle := valeurAlphaBetaBordsCritiques;
		
		end;

  
  {fin normale}
  Evaluation := evalPartielle; 
  nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;

end;  
      
      
      
       
function CreeEvaluationCassioRec(var position : plateauOthello;CoulEvaluation,nbBlancs,nbNoirs : SInt32;
                               var jouable : plBool; var front : InfoFrontRec) : EvaluationCassioRec;
var t,x,adversaire,coins,centre,petitcentre,aux,mobiliteAmie,mobiliteEnnemie : SInt32;
    result : EvaluationCassioRec;
    listeDesCoupsTranquilles,listeDesCoupsTranquillesAdversaire : ListeDeCases;
begin   


 with result do
   begin
     notePenalite := 0;
     noteBord := 0;
     noteCoin := 0;
     notePriseCoin := 0;
     noteDefenseCoin := 0;
     noteMinimisationAvant := 0;
     noteMinimisationApres := 0;
     noteCentre := 0;
     noteGrandCentre := 0;
     noteFrontiere := 0;
     noteEquivalentFrontiere := 0;
     noteMobilite := 0;
     noteCaseX := 0;
     noteCaseXEntreCasesC := 0;
     noteCaseXPlusCoin := 0;
     noteTrouCaseC := 0;
     noteOccupationTactique := 0;
     noteWipeOut := 0;
     noteAleatoire := 0;
     noteTrousDeTroisHorrible := 0;
     noteLiberteSurCaseA := 0;
     noteLiberteSurCaseB := 0;
     noteBonsBordsDeCinq := 0;
     noteTrousDeDeuxPerdantLaParite := 0;
     noteArnaqueSurBordDeCinq := 0;
     noteValeurBlocsDeCoin := 0;
     noteBordsOpposes := 0;
     noteBordDeCinqTransformable := 0;
     noteGameOver := 0;
     noteBordDeSixPlusQuatre := 0;
     noteGrosseMasse := 0;
     noteCaseXConsolidantBordDeSix := 0;
   end;
 

with result do
  begin
    if (nbBlancs=0) then 
			begin
			  if utilisationNouvelleEval
			    then
			      if CoulEvaluation = pionBlanc
				      then noteGameOver := -100*nbNoirs
				      else noteGameOver := 100*nbNoirs
			    else
			      if CoulEvaluation = pionBlanc
				      then noteGameOver := -500*nbNoirs
				      else noteGameOver := 500*nbNoirs;
			end else
    if (nbNoirs=0) then 
	    begin
	      if utilisationNouvelleEval
	        then
	          if CoulEvaluation = pionBlanc
				      then noteGameOver := 100*nbBlancs
				      else noteGameOver := -100*nbBlancs
	        else
				    if CoulEvaluation = pionBlanc
				      then noteGameOver := 500*nbBlancs
				      else noteGameOver := -500*nbBlancs;
			end 
		 else
		  begin
        adversaire := -CoulEvaluation; 
		  
		    notePenalite := -penalitePourLeTrait;
			  noteAleatoire := (Random() mod 200);
			    
			  if (nbBlancs<=3) & (nbNoirs>13) then
			    if (CoulEvaluation = pionBlanc) 
			      then noteWipeOut := -5000
			      else noteWipeOut := +5000;
			  if (nbNoirs<=3) & (nbBlancs>13) then
			    if (CoulEvaluation = pionNoir) 
			      then noteWipeOut := -5000
			      else noteWipeOut := +5000;

			  for t := 1 to 4 do   
			    begin
			      x := othellier[t];
			      if Jouable[x] then 
			        begin 
			          {prises et sacrifices de coin}
			          if PeutJouerIci(coulEvaluation,x,position) then 
			              notePriseCoin := notePriseCoin+valPriseCoin;
			          if PeutJouerIci(adversaire,x,position) then 
			              noteDefenseCoin := noteDefenseCoin-valDefenseCoin;
			        end;
			    end;
			    
			  petitcentre := valPionpetitcentre*(position[casepetitcentre1]+position[casepetitcentre2]+
			                                   position[casepetitcentre3]+position[casepetitcentre4]+
			                                   position[casepetitcentre5]+position[casepetitcentre6]+
			                                   position[casepetitcentre7]+position[casepetitcentre8]);
			                                     
			                                      
			  centre := valPionCentre*(position[Casecentre1]+position[Casecentre2]+
			                         position[Casecentre3]+position[Casecentre4]);
			  coins := valCoin*(position[88]+position[11]+position[18]+position[81]);
			    
			  with front do
			   begin
			    if CoulEvaluation = pionBlanc 
			      then
			        begin    {evaluation pour Blanc}
			          {cases X}
			          if (position[22] = pionNoir) then
			            case position[11] of 
			              pionVide: if (position[12] <> pionVide) & (position[21] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC 
			                                                                               else noteCaseX := noteCaseX+valCaseX;
			              pionNoir,pionBlanc: 
			                begin
			                  aux := 0;
			                  if (position[12] <> pionVide) & (position[21] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[12]= pionVide) & (position[13]= pionNoir) & (position[23]= pionNoir) then aux := aux+valTrouCaseC;
			                  if (position[21]= pionVide) & (position[31]= pionNoir) & (position[32]= pionNoir) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[22] = pionBlanc) then
			            case position[11] of 
			              pionVide: if (position[12] <> pionVide) & (position[21] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC 
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionNoir,pionBlanc: 
			                begin
			                  aux := 0;
			                  if (position[12] <> pionVide) & (position[21] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[12]= pionVide) & (position[13]= pionBlanc) & (position[23]= pionBlanc) then aux := aux-valTrouCaseC;
			                  if (position[21]= pionVide) & (position[31]= pionBlanc) & (position[32]= pionBlanc) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[27] = pionNoir)  then
			            case position[18] of 
			              pionVide: if (position[17] <> pionVide) & (position[28] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionNoir,pionBlanc: 
			                begin
			                  aux := 0;
			                  if (position[17] <> pionVide) & (position[28] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[17]= pionVide) & (position[16]= pionNoir) & (position[26]= pionNoir) then aux := aux+valTrouCaseC;
			                  if (position[28]= pionVide) & (position[38]= pionNoir) & (position[37]= pionNoir) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[27] = pionBlanc) then
			            case position[18] of 
			              pionVide: if (position[17] <> pionVide) & (position[28] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionNoir,pionBlanc: 
			                begin
			                  aux := 0;
			                  if (position[17] <> pionVide) & (position[28] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[17]= pionVide) & (position[16]= pionBlanc) & (position[26]= pionBlanc) then aux := aux-valTrouCaseC;
			                  if (position[28]= pionVide) & (position[38]= pionBlanc) & (position[37]= pionBlanc) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[72] = pionNoir)  then
			            case position[81] of 
			              pionVide: if (position[71] <> pionVide) & (position[82] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																															   else noteCaseX := noteCaseX+valCaseX;
			              pionNoir,pionBlanc: 
			                begin
			                  aux := 0;
			                  if (position[71] <> pionVide) & (position[82] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[71]= pionVide) & (position[61]= pionNoir) & (position[62]= pionNoir) then aux := aux+valTrouCaseC;
			                  if (position[82]= pionVide) & (position[83]= pionNoir) & (position[73]= pionNoir) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[72] = pionBlanc) then
			            case position[81] of 
			              pionVide: if (position[71] <> pionVide) & (position[82] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionNoir,pionBlanc: 
			                begin
			                  aux := 0;
			                  if (position[71] <> pionVide) & (position[82] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[71]= pionVide) & (position[61]= pionBlanc) & (position[62]= pionBlanc) then aux := aux-valTrouCaseC;
			                  if (position[82]= pionVide) & (position[83]= pionBlanc) & (position[73]= pionBlanc) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[77] = pionNoir) then
			            case position[88] of 
			              pionVide: if (position[78] <> pionVide) & (position[87] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionNoir,pionBlanc: 
			                begin
			                  aux := 0;
			                  if (position[78] <> pionVide) & (position[87] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[78]= pionVide) & (position[68]= pionNoir) & (position[67]= pionNoir) then aux := aux+valTrouCaseC;
			                  if (position[87]= pionVide) & (position[86]= pionNoir) & (position[76]= pionNoir) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[77] = pionBlanc) then
			            case position[88] of 
			              pionVide: if (position[78] <> pionVide) & (position[87] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionNoir,pionBlanc: 
			                begin
			                  aux := 0;
			                  if (position[78] <> pionVide) & (position[87] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[78]= pionVide) & (position[68]= pionBlanc) & (position[67]= pionBlanc) then aux := aux-valTrouCaseC;
			                  if (position[87]= pionVide) & (position[86]= pionBlanc) & (position[76]= pionBlanc) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			        
			          if (position[11] = pionVide) & (position[18] = pionVide) & (position[81] = pionVide) & (position[88] = pionVide)
			            then noteMinimisationAvant  := valMinimisationAvantCoins*(nbBlancs-nbNoirs)
			            else noteMinimisationApres  := valMinimisationApresCoins*(nbBlancs-nbNoirs);
			          noteCentre                    := centre;
			          noteGrandCentre               := petitcentre;
			          noteCoin                      := coins;
			          noteOccupationTactique        := -occupationTactique;
			          noteBord                      := valeurBord^[AdressePattern[kAdresseBordSud]]+valeurBord^[AdressePattern[kAdresseBordOuest]]+valeurBord^[AdressePattern[kAdresseBordEst]]+valeurBord^[AdressePattern[kAdresseBordNord]];
			          noteTrousDeTroisHorrible      := TrousDeTroisNoirsHorribles(position) - TrousDeTroisBlancsHorribles(position);
			          noteLiberteSurCaseA           := LibertesBlanchesSurCasesA(position,front) - LibertesNoiresSurCasesA(position,front);
			          noteLiberteSurCaseB           := LibertesBlanchesSurCasesB(position) - LibertesNoiresSurCasesB(position);
			          noteBonsBordsDeCinq           := BonsBordsDeCinqBlancs(position,front) - BonsBordsDeCinqNoirs(position,front);
			          noteTrousDeDeuxPerdantLaParite := TrousNoirsDeDeuxPerdantLaParite(position) - TrousBlancsDeDeuxPerdantLaParite(position);
			          noteArnaqueSurBordDeCinq      := ArnaqueSurBordDeCinqBlanc(position,front) - ArnaqueSurBordDeCinqNoir(position,front);
			          noteValeurBlocsDeCoin         := ValeurBlocsDeCoinPourBlanc(position);
			          noteBordsOpposes              := -NotationBordsOpposesPourNoir(position);
                noteBordDeCinqTransformable   := valBordDeCinqTransformable*nbBordDeCinqTransformablesPourBlanc(position,front);
			          noteBordDeSixPlusQuatre       := -BordDeSixNoirAvecPrebordHomogene(position,front)+BordDeSixBlancAvecPrebordHomogene(position,front);
			        end
			      else
			        begin     {evaluation pour Noir}
			          {cases X}
			          if (position[22] = pionBlanc) then
			            case position[11] of 
			              pionVide: if (position[12] <> pionVide) & (position[21] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionBlanc,pionNoir: 
			                begin
			                  aux := 0;
			                  if (position[12] <> pionVide) & (position[21] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[12]= pionVide) & (position[13]= pionBlanc) & (position[23]= pionBlanc) then aux := aux+valTrouCaseC;
			                  if (position[21]= pionVide) & (position[31]= pionBlanc) & (position[32]= pionBlanc) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[22] = pionNoir) then
			            case position[11] of 
			              pionVide: if (position[12] <> pionVide) & (position[21] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionBlanc,pionNoir: 
			                begin
			                  aux := 0;
			                  if (position[12] <> pionVide) & (position[21] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[12]= pionVide) & (position[13]= pionNoir) & (position[23]= pionNoir) then aux := aux-valTrouCaseC;
			                  if (position[21]= pionVide) & (position[31]= pionNoir) & (position[32]= pionNoir) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[27] = pionBlanc)  then
			            case position[18] of 
			              pionVide: if (position[17] <> pionVide) & (position[28] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionBlanc,pionNoir: 
			                begin
			                  aux := 0;
			                  if (position[17] <> pionVide) & (position[28] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[17]= pionVide) & (position[16]= pionBlanc) & (position[26]= pionBlanc) then aux := aux+valTrouCaseC;
			                  if (position[28]= pionVide) & (position[38]= pionBlanc) & (position[37]= pionBlanc) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[27] = pionNoir) then
			            case position[18] of 
			              pionVide: if (position[17] <> pionVide) & (position[28] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionBlanc,pionNoir: 
			                begin
			                  aux := 0;
			                  if (position[17] <> pionVide) & (position[28] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[17]= pionVide) & (position[16]= pionNoir) & (position[26]= pionNoir) then aux := aux-valTrouCaseC;
			                  if (position[28]= pionVide) & (position[38]= pionNoir) & (position[37]= pionNoir) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[72] = pionBlanc)  then
			            case position[81] of 
			              pionVide: if (position[71] <> pionVide) & (position[82] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionBlanc,pionNoir: 
			                begin
			                  aux := 0;
			                  if (position[71] <> pionVide) & (position[82] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[71]= pionVide) & (position[61]= pionBlanc) & (position[62]= pionBlanc) then aux := aux+valTrouCaseC;
			                  if (position[82]= pionVide) & (position[83]= pionBlanc) & (position[73]= pionBlanc) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[72] = pionNoir) then
			            case position[81] of 
			              pionVide: if (position[71] <> pionVide) & (position[82] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionBlanc,pionNoir: 
			                begin
			                  aux := 0;
			                  if (position[71] <> pionVide) & (position[82] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[71]= pionVide) & (position[61]= pionNoir) & (position[62]= pionNoir) then aux := aux-valTrouCaseC;
			                  if (position[82]= pionVide) & (position[83]= pionNoir) & (position[73]= pionNoir) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[77] = pionBlanc) then
			            case position[88] of 
			              pionVide: if (position[78] <> pionVide) & (position[87] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionBlanc,pionNoir: 
			                begin
			                  aux := 0;
			                  if (position[78] <> pionVide) & (position[87] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[78]= pionVide) & (position[68]= pionBlanc) & (position[67]= pionBlanc) then aux := aux+valTrouCaseC;
			                  if (position[87]= pionVide) & (position[86]= pionBlanc) & (position[76]= pionBlanc) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) 
			                                  then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                  else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[77] = pionNoir) then
			            case position[88] of 
			              pionVide: if (position[78] <> pionVide) & (position[87] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionBlanc,pionNoir: 
			                begin
			                  aux := 0;
			                  if (position[78] <> pionVide) & (position[87] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[78]= pionVide) & (position[68]= pionNoir) & (position[67]= pionNoir) then aux := aux-valTrouCaseC;
			                  if (position[87]= pionVide) & (position[86]= pionNoir) & (position[76]= pionNoir) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then 
			                              begin
			                                if (aux=valCaseXPlusCoin) | (aux=-valCaseXPlusCoin) 
			                                  then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                  else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			        
			          if (position[11] = pionVide) & (position[18] = pionVide) & (position[81] = pionVide) & (position[88] = pionVide)
			            then noteMinimisationAvant  := valMinimisationAvantCoins*(nbNoirs-nbBlancs)
			            else noteMinimisationApres  := valMinimisationApresCoins*(nbNoirs-nbBlancs);
			          noteCentre                    := -centre;
			          noteGrandCentre               := -petitcentre;
			          noteCoin                      := -coins;
			          noteOccupationTactique        := occupationTactique;
			          noteBord                      := valeurBord^[-AdressePattern[kAdresseBordSud]]+valeurBord^[-AdressePattern[kAdresseBordOuest]]+valeurBord^[-AdressePattern[kAdresseBordEst]]+valeurBord^[-AdressePattern[kAdresseBordNord]];
			          noteTrousDeTroisHorrible      := -TrousDeTroisNoirsHorribles(position) + TrousDeTroisBlancsHorribles(position);
			          noteLiberteSurCaseA           := -LibertesBlanchesSurCasesA(position,front) + LibertesNoiresSurCasesA(position,front);
			          noteLiberteSurCaseB           := -LibertesBlanchesSurCasesB(position) + LibertesNoiresSurCasesB(position);
			          noteBonsBordsDeCinq           := -BonsBordsDeCinqBlancs(position,front) + BonsBordsDeCinqNoirs(position,front);
			          noteTrousDeDeuxPerdantLaParite := -TrousNoirsDeDeuxPerdantLaParite(position) + TrousBlancsDeDeuxPerdantLaParite(position);
			          noteArnaqueSurBordDeCinq      := -ArnaqueSurBordDeCinqBlanc(position,front) + ArnaqueSurBordDeCinqNoir(position,front);
			          noteValeurBlocsDeCoin         := ValeurBlocsDeCoinPourNoir(position);
			          noteBordsOpposes              := NotationBordsOpposesPourNoir(position);
			          noteBordDeCinqTransformable   := -valBordDeCinqTransformable*nbBordDeCinqTransformablesPourBlanc(position,front);
			          noteBordDeSixPlusQuatre       := BordDeSixNoirAvecPrebordHomogene(position,front)-BordDeSixBlancAvecPrebordHomogene(position,front);
			          
			        end;
			        
			     
			     
			     noteFrontiere := valFrontiere*(nbadjacent[adversaire]-nbadjacent[CoulEvaluation]);
			     noteEquivalentFrontiere := valEquivalentFrontiere*(nbfront[adversaire]-nbfront[CoulEvaluation]);    
			     
			     mobiliteAmie    := MobiliteSemiTranquilleAvecCasesC(CoulEvaluation,position,jouable,front,listeDesCoupsTranquilles,100000);
           mobiliteEnnemie := MobiliteSemiTranquilleAvecCasesC(adversaire,position,jouable,front,listeDesCoupsTranquillesAdversaire,100000);
           
			     noteMobilite := valMobiliteUnidirectionnelle*(mobiliteAmie-mobiliteEnnemie);
			             
			     
			      if (mobiliteAmie<=seuilMobilitePourGrosseMasse) & ((noteFrontiere+noteEquivalentFrontiere)>=0) then
				       if CalculeMobilite(CoulEvaluation,position,jouable) <= 5 then
				         noteGrosseMasse := -valGrosseMasse;
			    end;  { with front do }
		  end;
  end;  {with result do}
  
  CreeEvaluationCassioRec := result;
end;  
 
 
 
 
 
 
 
function EvaluationMaximisation(var position : plateauOthello;CoulEvaluation,nbBlancs,nbNoirs : SInt32) : SInt32;
var aux : SInt32;
begin   
  {$UNUSED position}
  aux := 0;
  if CoulEvaluation = pionBlanc 
    then aux := aux + 50*(nbBlancs-nbNoirs)
    else aux := aux + 50*(nbNoirs-nbBlancs);
  EvaluationMaximisation := aux; 
end;


function EvaluationDesBords(var position : plateauOthello;CoulEvaluation : SInt32; var front : InfoFrontRec) : SInt32;
var Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32;
    numeroDuCoup,theStage,aux : SInt32;
begin {$UNUSED position,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst,numeroDuCoup,theStage}
  aux := 0;
  with front do
  if CoulEvaluation = pionBlanc 
    then aux := aux + valeurBord^[AdressePattern[kAdresseBordSud]]+valeurBord^[AdressePattern[kAdresseBordOuest]]+valeurBord^[AdressePattern[kAdresseBordEst]]+valeurBord^[AdressePattern[kAdresseBordNord]]
    else aux := aux + valeurBord^[-AdressePattern[kAdresseBordSud]]+valeurBord^[-AdressePattern[kAdresseBordOuest]]+valeurBord^[-AdressePattern[kAdresseBordEst]]+valeurBord^[-AdressePattern[kAdresseBordNord]];
  EvaluationDesBords := aux;
end;
 
                    

function EvaluationHorsContexte(var whichPos : PositionEtTraitRec) : SInt32;
var nbBlancs,nbNoirs : SInt32;
    jouables : plBool;
    frontiere : InfoFrontRec;
    nbRecursives : SInt32;
begin
  with whichPos do
    begin
      nbBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,position);
      nbNoirs := NbPionsDeCetteCouleurDansPosition(pionNoir,position);
      CarteJouable(position,jouables);
      CarteFrontiere(position,frontiere);
      EvaluationHorsContexte := Evaluation(position,GetTraitOfPosition(whichPos),nbBlancs,nbNoirs,jouables,frontiere,false,-30000,30000,nbRecursives);
    end;
end;




END.