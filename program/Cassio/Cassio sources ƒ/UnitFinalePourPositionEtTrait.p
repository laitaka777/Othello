UNIT UnitFinalePourPositionEtTrait;



INTERFACE







USES UnitPositionEtTrait;


const kEndgameSolveOnlyWLD                          = 1;
      kEndgameSolveToujoursRamenerLaSuite           = 2;
      kEndgameSolveEcrirePositionDansRapport        = 4;
      kEndgameSolveEcrireInfosTechniquesDansRapport = 8;
      

function ScoreWLDPositionEtTrait(whichPosition : PositionEtTraitRec) : SInt32;
function NbCoupsGagnantsOuNuls(whichPosition : PositionEtTraitRec; var valeurOptimale : SInt32;borneNbCoupsGagnants : SInt32) : SInt32;
function CalculeLigneOptimalePositionEtTrait(whichPosition : PositionEtTraitRec;endgameSolveFlags : SInt32; var score : SInt32) : str255;
function DoEndgameSolve(var positionEtTrait : PositionEtTraitRec;endgameSolveFlags : SInt32) : SInt32;




IMPLEMENTATION




 


USES UnitGestionDuTemps,UnitStrategie,UnitRapport,UnitSuperviseur,UnitUtilitairesFinale,UnitSetUp,UnitFinaleFast,
     UnitPhasesPartie,UnitAffichageReflexion,UnitOth1,UnitUtilitaires,UnitArbreDeJeuCourant;


{renvoie -1 si la position est perdante, 0 si nulle et +1 si gagnante}
function ScoreWLDPositionEtTrait(whichPosition : PositionEtTraitRec) : SInt32;
var nbBlanc,nbNoir,prof : SInt32;
    meiDef,numeroDuCoup : SInt32;
    choixX,scoreParfait : SInt32;
    oldInterruption : SInt16; 
    jouables : plBool;
    frontiere : InfoFrontRec;
    gagnant : boolean;
begin  

  if GetTraitOfPosition(whichPosition) = pionVide then
    begin
      SysBeep(0);
      WritelnDansRapport('ERREUR : GetTraitOfPosition(whichPosition) = pionVide dans ScoreWLDPositionEtTrait !!');
      exit(ScoreWLDPositionEtTrait);
    end;
    
  oldInterruption := GetCurrentInterruption();
  EnleveCetteInterruption(oldInterruption);

  couleurMacintosh := GetTraitOfPosition(whichPosition);
  HumCtreHum := false;
  nbBlanc := NbPionsDeCetteCouleurDansPosition(pionBlanc,whichPosition.position);
  nbNoir  := NbPionsDeCetteCouleurDansPosition(pionNoir,whichPosition.position);
  prof := 64 - nbBlanc - nbNoir;
  numeroDuCoup := nbNoir+nbBlanc-4;
  vaDepasserTemps := false;
  RefleSurTempsJoueur := false;
  Superviseur(numeroDuCoup);
  
  CarteJouable(whichPosition.position,jouables);
  CarteFrontiere(whichPosition.position,frontiere);
  if not(calculPrepHeurisFait) then Initialise_table_heuristique(whichPosition.position);
  
  EnleveCetteInterruption(GetCurrentInterruption());  
  gagnant := CoupGagnant(choixX,meiDef,GetTraitOfPosition(whichPosition),prof,nbBlanc,nbNoir,NIL,whichPosition.position,jouables,
                        frontiere,NIL,scoreParfait,false,true,ReflGagnant);
  LanceInterruption(oldInterruption,'ScoreWLDPositionEtTrait');
  
  ScoreWLDPositionEtTrait := Signe(scoreParfait);
end;


{renvoie 0 (si la position est perdante) ou le nombre de coups optimaux si la
 position est nulle ou gagnante, ainsi que la valeur de la position (0 ou +1)}
function NbCoupsGagnantsOuNuls(whichPosition : PositionEtTraitRec; var valeurOptimale : SInt32;borneNbCoupsGagnants : SInt32) : SInt32;
var compteurCoupsOptimaux : SInt32;
    listeCasesVides:listeVides;
    nbVides,nbCoups,i : SInt32;
    positionFils : PositionEtTraitRec;
    bestScoreSoFar,scoreWLD : SInt32;
begin
  compteurCoupsOptimaux := 0;
  bestScoreSoFar := -1;
  valeurOptimale := -1;
  
  if GetTraitOfPosition(whichPosition) <> pionVide then
    begin
		  nbVides := EtablitListeCasesVides(whichPosition.position,listeCasesVides);
		  nbCoups := TrierSelonDivergenceSansMilieu(whichPosition.position,GetTraitOfPosition(whichPosition),nbVides,listeCasesVides,listeCasesVides);
		  		  
		  for i := 1 to nbCoups do
		    begin
		      positionFils := whichPosition;
		      
		      if UpdatePositionEtTrait(positionFils,listeCasesVides[i]) then
		        begin
		          if GetTraitOfPosition(positionFils) = pionVide
				        then
				          begin
				            scoreWLD := Signe(NbPionsDeCetteCouleurDansPosition(GetTraitOfPosition(whichPosition),positionFils.position) - NbPionsDeCetteCouleurDansPosition(-GetTraitOfPosition(whichPosition),positionFils.position));
				          end
				        else
				          begin
				            if GetTraitOfPosition(whichPosition) <> GetTraitOfPosition(positionFils)
				              then scoreWLD := -ScoreWLDPositionEtTrait(positionFils)
				              else scoreWLD :=  ScoreWLDPositionEtTrait(positionFils);
				          end;
				          
				      if scoreWLD > bestScoreSoFar then 
		            begin
		              bestScoreSoFar := scoreWLD;
		              compteurCoupsOptimaux := 0;
		            end;
		          if scoreWLD = bestScoreSoFar then inc(compteurCoupsOptimaux);
		          
		          if (bestScoreSoFar = +1) & (compteurCoupsOptimaux >= borneNbCoupsGagnants) then Leave;
		        end;
        end;
        
    end;
    
  valeurOptimale := bestScoreSoFar;
  if valeurOptimale < 0
    then NbCoupsGagnantsOuNuls := 0
    else NbCoupsGagnantsOuNuls := compteurCoupsOptimaux;
end;



function DoEndgameSolve(var positionEtTrait : PositionEtTraitRec;endgameSolveFlags : SInt32) : SInt32;
var nbNoirs,nbBlancs,empties,score,bestMove,bestDefense : SInt32;
    frontiere : InfoFrontRec;
    casesJouables : plBool;
    typeFinaleDemandee : SInt16; 
    oldInterruption : SInt16; 
    gagnant : boolean;
    onlyWLD : boolean;
    ecrireInfosTechniquesDansRapport : boolean;
    toujoursRamenerLaSuite : boolean;
    ecrirePositionDansRapport : boolean;
begin 

  with positionEtTrait do
    begin
      oldInterruption := GetCurrentInterruption();
		  EnleveCetteInterruption(oldInterruption);
		  
      score := -1000;
      
      if CassioEstEnTrainDeReflechir()
        then
          begin
            WritelnDansRapport('ERREUR : (CassioEstEnTrainDeReflechir() = true)  dans DoEndgameSolve !!');
          end
        else
          begin
      
            onlyWLD                          := BitAnd(endgameSolveFlags,kEndgameSolveOnlyWLD) <> 0;
            ecrireInfosTechniquesDansRapport := BitAnd(endgameSolveFlags,kEndgameSolveEcrireInfosTechniquesDansRapport) <> 0;
            toujoursRamenerLaSuite           := BitAnd(endgameSolveFlags,kEndgameSolveToujoursRamenerLaSuite) <> 0;
            ecrirePositionDansRapport        := BitAnd(endgameSolveFlags,kEndgameSolveEcrirePositionDansRapport) <> 0;
            
            nbNoirs := NbPionsDeCetteCouleurDansPosition(pionNoir,position);
      		  nbBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,position);
      		  CarteFrontiere(position,frontiere);
      		  CarteJouable(position,casesJouables);
      		  PlaquerPosition(position,GetTraitOfPosition(positionEtTrait),kRedessineEcran);
      		  if HumCtreHum then DoChangeHumCtreHum;
      		  RefleSurTempsJoueur := false;
      		  couleurMacintosh := GetTraitOfPosition(positionEtTrait);
      		  DoFinaleOptimale(false);
      		  vaDepasserTemps := false;
      		  
      		  InfosTechniquesDansRapport := ecrireInfosTechniquesDansRapport;
      		  
      		  if ecrirePositionDansRapport then
      		    begin
      		      WritelnDansRapport('');
      		      WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
      		    end;
      		  
      		  if onlyWLD
      		    then typeFinaleDemandee := ReflGagnant
      		    else typeFinaleDemandee := ReflParfait;
      		    
      		  SetGameMode(typeFinaleDemandee);
      		  EnleveCetteInterruption(GetCurrentInterruption());
      		  ReinitilaliseInfosAffichageReflexion;
      		  EffaceReflexion;
      		  derniertick := TickCount()-tempsDesJoueurs[aQuiDeJouer].tick;
      		  LanceChrono;
      		  tempsPrevu := 10;
      		  tempsAlloue := minutes10000000;
      		  if not(RefleSurTempsJoueur) & (aQuiDeJouer=couleurMacintosh) then EcritJeReflechis(aQuiDeJouer);
      		  Superviseur(nbNoirs+nbBlancs-4);
      		  empties := 64 - nbBlancs - nbNoirs;
      		  Initialise_table_heuristique(position);
      		  if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
      		  
      		  gagnant := CoupGagnant(bestMove,bestDefense,GetTraitOfPosition(positionEtTrait),empties,nbBlancs,nbNoirs,GetCurrentNode(),
      		                         position,casesJouables,frontiere,NIL,score,ecrireInfosTechniquesDansRapport,toujoursRamenerLaSuite,typeFinaleDemandee);

          
            if (interruptionReflexion <> pasdinterruption) then score := -1000;
          
          end;
          
      LanceInterruption(oldInterruption,'DoEndgameSolve');
    end;
  
  DoEndgameSolve := score;
end;



function CalculeLigneOptimalePositionEtTrait(whichPosition : PositionEtTraitRec;endgameSolveFlags : SInt32; var score : SInt32) : str255;
var ligneOptimale : str255;
    valeurDeLaPosition : SInt32;
begin
  ligneOptimale := '';
  
  if CassioEstEnTrainDeReflechir()
    then
      begin
        WritelnDansRapport('ERREUR : (CassioEstEnTrainDeReflechir() = true)  dans CalculeLigneOptimalePositionEtTrait !!');
      end
    else
      begin

        { On force le calcul en mode finale parfaite }
        if BitAnd(endgameSolveFlags,kEndgameSolveOnlyWLD) <> 0 then
          endgameSolveFlags := endgameSolveFlags - kEndgameSolveOnlyWLD;
        
        { Lancer la finale ! }
        valeurDeLaPosition := DoEndgameSolve(whichPosition,endgameSolveFlags);
        
        { Si tout est bon, on retourne le rŽsultat }
        if (valeurDeLaPosition >= -64) & (valeurDeLaPosition <= 64) & (interruptionReflexion = pasdinterruption) then
          begin
            score := valeurDeLaPosition;
            ligneOptimale := MeilleureSuiteInfosEnChaine(0,false,false,true,false,0);
          end;
      
      end;
  
  
  CalculeLigneOptimalePositionEtTrait := ligneOptimale;
end;




END.






































