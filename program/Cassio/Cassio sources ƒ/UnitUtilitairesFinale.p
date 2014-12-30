UNIT UnitUtilitairesFinale;



INTERFACE







USES UnitPositionEtTrait,UnitVariablesGlobalesFinale;


VAR EvaluationSuffisantePourFastestFirst : array[0..64] of SInt32;

    
(* initialisation de l'unite *)
procedure InitUnitUtilitairesFinale;
procedure InitValeursDeltasSuccessifsFinale;
procedure InitValeursRestrictionsLargeurSousArbres(profondeurMinimalePourRestriction : SInt32);
procedure InitValeursStandardAlgoFinale;
function VerifieAssertionsDeFinale() : boolean;


(* utilitaire pour retrouver la ligne parfaite si elle est stockee en memoire *)
function PeutCalculerFinaleOptimaleParOptimalite(var PlatAcomparer : plateauOthello;nbNoirCompare,nbBlancCompare : SInt32;
                                                 var ChoixX,MeilleurDef,scorePourNoir : SInt32) : boolean;


(* affichages *)
procedure EcritRefutationsDansRapport(longClass : SInt32; var classAux : ListOfMoveRecords);
procedure EcritAnnonceFinaleDansMeilleureSuite(typeCalculFinale,nroCoup,deltaFinale : SInt32);
procedure SetDerniereAnnonceFinaleDansMeilleureSuite(s : str255);
function GetDerniereAnnonceFinaleDansMeilleureSuite() : str255;


(* conversions *)
procedure CopyEnPlOthEndgame(var source : plateauOthello; var dest:plOthEndgame);
function EtablitListeCasesVides(var plat : plateauOthello; var listeCasesVides:listeVides) : SInt32;


(* idee de base de Fastest First *)
function TrierSelonDivergenceSansMilieu(var plat : plateauOthello;couleur,nbCasesVides : SInt32; var source,dest:listeVides) : SInt32;
function TrierSelonDivergenceAvecMilieu(var plat : plateauOthello;couleur,nbCasesVides,conseilHash : SInt32; var source,dest:listeVides; var InfosMilieuDePartie:InfosMilieuRec;
                                        alpha,beta : SInt32; var coupureAlphaProbable,coupureBetaProbable : boolean;utiliserMilieu : boolean) : SInt32;


(* tri stable selon les valeurs min de la table de hashage *)
procedure TrierSelonHashTableExacte(platDepart : PositionEtTraitRec; var classement : ListOfMoveRecords;longClass,clefHashage : SInt32);


(* divers *)
procedure SetMinimaxAEvalueAUMoinsUnCoupDansCettePasse(flag : boolean);
function MinimaxAEvalueAUMoinsUnCoupDansCettePasse() : boolean;



IMPLEMENTATION







USES UnitMacExtras,UnitScannerOthellistique,UnitStrategie,UnitEvaluation,Unit_AB_Simple,UnitHashTableExacte,
     UnitRapportImplementation,UnitNouvelleEval,UnitArbreDeJeuCourant,UnitJaponais,UnitStrategie,
     UnitAffichageReflexion,UnitSuperviseur,UnitMiniProfiler,UnitRapport,UnitOth1,UnitListeChaineeCasesVides;



var gDerniereAnnonceFinaleDansMeilleureSuite : str255;
    gMinimaxAEvalueAUMoinsUnCoupDansCettePasse : boolean;


procedure InitUnitUtilitairesFinale;
begin
  InitValeursStandardAlgoFinale;
end;



procedure InitValeursDeltasSuccessifsFinale;
var k : SInt32;
begin

  for k := 1 to kNbreMaxDeltasSuccessifs do 
    deltaSuccessifs[k] := -1;
  
  deltaSuccessifs[1] := 0;
  deltaSuccessifs[2] := 100;
  deltaSuccessifs[3] := 200;
  deltaSuccessifs[4] := 400;
  deltaSuccessifs[5] := 1100;
  deltaSuccessifs[6] := 1600;
  deltaSuccessifs[7] := kDeltaFinaleInfini;
  nbreDeltaSuccessifs := 7;
  
end;

procedure InitValeursRestrictionsLargeurSousArbres(profondeurMinimalePourRestriction : SInt32);
var k,p : SInt32;
begin {$UNUSED profondeurMinimalePourRestriction}

  
  for k := 1 to kNbreMaxDeltasSuccessifs do 
    for p := 0 to 64 do
      restrictionLargeurSousArbreCeDelta[k,p] := 1000;  {par defaut : pas de restriction}
  
  (*
  if effetspecial_blah_blah then
    begin
		  {for p := profondeurMinimalePourRestriction to 64 do
		    for k := 1 to nbreDeltaSuccessifs-1 do
		      restrictionLargeurSousArbreCeDelta[k,p] := k;}
		  
		  for p := profondeurMinimalePourRestriction to 64 do
		      restrictionLargeurSousArbreCeDelta[5,p] := 5;
		  for p := profondeurMinimalePourRestriction to 64 do
		      restrictionLargeurSousArbreCeDelta[7,p] := 5;
		end;
  *)
      
  {
  WritelnDansRapport('table des restrictionLargeurSousArbreCeDelta : ');
  for p := 0 to 64 do
    if restrictionLargeurSousArbreCeDelta[1,p] <> 1000 then
    begin
      WriteStringAndNumDansRapport('p=',p);
      for k := 1 to nbreDeltaSuccessifs do
        WriteStringAndNumDansRapport(' ',restrictionLargeurSousArbreCeDelta[k,p]);
      WritelnDansRapport('');
    end;
  }
  
end;




(* on verifie que les delta successifs sont bien croissants,
   qu'il n'y en a pas trop et qu'ils se terminent bien par
   kDeltaFinaleInfini, etc. *)
function VerifieAssertionsDeFinale() : boolean;
var erreur,i : SInt32;
begin
  erreur := 0;
  
  {croissance}
  for i := 2 to nbreDeltaSuccessifs do
    if (deltaSuccessifs[i] <= deltaSuccessifs[i-1])
      then erreur := 1;
  
  {ni trop, ni trop peu}
  if (nbreDeltaSuccessifs < 1) | 
     (nbreDeltaSuccessifs > kNbreMaxDeltasSuccessifs) |
     (nbreDeltaSuccessifs > kNbreMaxDeltasSuccessifsDansHashExacte)
     then erreur := 2;
  
  {terminaison}
  if (deltaSuccessifs[nbreDeltaSuccessifs] <> kDeltaFinaleInfini)
    then erreur := 3;
    
  {intervalle de dernierIndexDeltaRenvoye}
  if (dernierIndexDeltaRenvoye < 1) | 
     (dernierIndexDeltaRenvoye > nbreDeltaSuccessifs)
    then erreur := 4;
    
    
  if (erreur <> 0) then 
    begin
      SysBeep(0);
      WriteDansRapport('ASSERT failed dans VerifieAssertionsDeFinale !!');
      WritelnStringAndNumDansRapport('erreur = ',erreur);
    end;
    
  VerifieAssertionsDeFinale := (erreur = 0);
end;




procedure InitValeursStandardAlgoFinale;
var i : SInt32;
begin

  InitialiseEndgameSquareOrder(ordreDesCasesDeCassio);

  for i := 0 to 17 do  profTriInterneEnFinale[i] := -2;
  for i := 18 to 19 do profTriInterneEnFinale[i] := 0;
  for i := 20 to 21 do profTriInterneEnFinale[i] := 1;
  for i := 22 to 23 do profTriInterneEnFinale[i] := 2;
  for i := 24 to 64 do profTriInterneEnFinale[i] := 3;

  
  for i := 0  to 16 do profEvaluationHeuristique[i] := 1;
  for i := 17 to 17 do profEvaluationHeuristique[i] := 2;
  for i := 18 to 23 do profEvaluationHeuristique[i] := 3;
  for i := 24 to 64 do profEvaluationHeuristique[i] := 4;
  
  for i := 0 to 64 do
    EvaluationSuffisantePourFastestFirst[i] := 100000;
  
  
  for i := 0 to 4 do
    stability_alpha[i] := 49;
  stability_alpha[5]  := 49;
  stability_alpha[6]  := 42;
  stability_alpha[7]  := 35;
  stability_alpha[8]  := 28;
  stability_alpha[9]  := 21;
  stability_alpha[10] := 14;
  stability_alpha[11] := 7;
  stability_alpha[12] := 0;
  for i := 13 to 64 do
    stability_alpha[i] := 0;

  
  InitValeursDeltasSuccessifsFinale;
  
  InitValeursRestrictionsLargeurSousArbres(1000);
  

  for i := 0 to 64 do 
    valeur_seuil_fastest_first[i] := Max(200,Min(1000,(i-14)*100));
  valeur_seuil_super_fastest := 800;
  
  
  seuil_pour_alpha_fastest := 800;
  seuil_pour_beta_fastest := 1800;
  
  dilatationEvalEnFinale := 1.1;  {1.0 voudrait dire pas de dilatation}
    
  dernierIndexDeltaRenvoye := 1;
  
  gProfondeurCoucheEvalsHeuristiques := 8;
  gProfondeurCoucheProofNumberSearch := -400; {négatif et grand : c'est-à-dire jamais de proof-number}
  
  SetPenalitesPourLeTraitStandards;
  
  
  
  if VerifieAssertionsDeFinale() then;
    
end;




function PeutCalculerFinaleOptimaleParOptimalite(var PlatAcomparer : plateauOthello;nbNoirCompare,nbBlancCompare : SInt32;
                                                 var ChoixX,MeilleurDef,scorePourNoir : SInt32) : boolean;
var i,coup,aux,t : SInt32;
    ok,ligneOptimaleJusquaLaFin : boolean;
    plat : plateauOthello;
    nBla,nNoi,aqui : SInt32;
    coupPossible : boolean;
    nroCoupAtteint,coultrait : SInt32;
    ChoixXTemp,MeilleurDefTemp : SInt32;
begin
  
  if debuggage.calculFinaleOptimaleParOptimalite & (nbreCoup > 40) then
   begin
     WritelnDansRapport('');
     WritelnDansRapport('Entrée dans PeutCalculerFinaleOptimaleParOptimalite…');
     for i := 42 to 60 do
       begin
         WriteStringAndNumDansRapport('coup ',i);
         aux := partie^^[i].coupParfait;
         WriteStringAndNumDansRapport(' : '+CHR(64+platmod10[aux]),platdiv10[aux]);
         if partie^^[i].optimal
           then WritelnDansRapport(' optimal  ')
           else WritelnDansRapport(' non optimal ');
       end;
   end;
  
  nroCoupAtteint := nbNoirCompare+nbBlancCompare-4;
  ligneOptimaleJusquaLaFin := false;
  
  ChoixX := 44; 
  MeilleurDef := 44;
  ok := not(gameOver) and (nroCoupAtteint<60) and (phaseDeLaPartie>=phaseFinale) and 
       (interruptionReflexion = pasdinterruption);
                   
  if ok then
    begin              
      MemoryFillChar(@plat,sizeof(plat),chr(0));
      for t := 0 to 99 do
        if interdit[t] then plat[t] := PionInterdit;
      plat[44] := pionBlanc;
      plat[55] := pionBlanc;
      plat[45] := pionNoir;
      plat[54] := pionNoir;
      coultrait := pionNoir;
      for t := 1 to nroCoupAtteint do
        begin
          coup := partie^^[t].coupParfait;
          if (coup<11) | (coup>88) | (plat[coup] <> pionVide) then ok := false;
          if ok then
            if ModifPlatSeulement(coup,plat,coultrait)
              then coultrait := -coultrait
              else ok := ModifPlatSeulement(coup,plat,-coultrait);
        end;
      if ok then
        for t := 11 to 88 do 
          ok := ok and (plat[t]=PlatAcomparer[t]);
    end;
  
  
  if debuggage.calculFinaleOptimaleParOptimalite then
    if ok 
      then WritelnDansRapport('meme position : ok    ')
      else WritelnDansRapport('meme position : faux  ');
  

  if ok then ok := (ok and partie^^[nroCoupAtteint+1].optimal);
  
  
  if debuggage.calculFinaleOptimaleParOptimalite then
    if ok 
      then WritelnDansRapport('coup optimal : ok    ')
      else WritelnDansRapport('coup optimal : faux  ');
  
  
  if ok then
    begin
      coup := partie^^[nroCoupAtteint+1].coupParfait;
      aux := partie^^[nroCoupAtteint+2].coupParfait;
      if (coup<11) or (coup>88) then ok := false;
      if ok then
        begin
          ChoixXTemp := coup;
          if partie^^[nroCoupAtteint+2].optimal then
            if (aux>=11) and (aux<=88) then 
              MeilleurDefTemp := aux;
        end;
    end;    
  
  
  if debuggage.calculFinaleOptimaleParOptimalite then
    if ok 
      then WritelnDansRapport('coup legal : ok    ')
      else WritelnDansRapport('coup legal : faux    ');
 
 
 if ok then
   begin
     ligneOptimaleJusquaLaFin := true;
     for i := nroCoupAtteint+1 to 60 do
       begin
         coup := partie^^[i].coupParfait;
         if (coup<11) or (coup>88) then ligneOptimaleJusquaLaFin := false;
         ligneOptimaleJusquaLaFin := ligneOptimaleJusquaLaFin and partie^^[i].optimal;
       end;
     if ligneOptimaleJusquaLaFin then
       begin
         VideMeilleureSuiteInfos;
         with meilleureSuiteInfos do
           begin
             for i := nbreCoup+1 to 60 do
               ligne[i-(nbreCoup+1)] := partie^^[i].coupParfait;
             numeroCoup := nbreCoup;
             couleur := aQuiDeJouer;
             
             {determination du score}
             plat := PlatAcomparer;
             nBla := nbBlancCompare;
             nNoi := nbNoirCompare; 
             Aqui := CoulTrait;
             for i := nroCoupAtteint+1 to 60 do
               begin
                 coup := partie^^[i].coupParfait;
                 if (coup>=11) and (coup<=88) then
                   begin
                     
                     coupPossible := ModifPlatFin(Coup,aQui,plat,nBla,nNoi);
                     if coupPossible 
                       then aQui := -Aqui
                       else coupPossible := ModifPlatFin(Coup,-aQui,plat,nBla,nNoi);
                   end;
               end;
             statut := NeSaitPas;
             score.Noir := nNoi;
             score.Blanc := nBla;
           end;  {with meilleureSuiteInfos}
         
         ChoixX := ChoixXtemp;               {resultats de la fonction}
         MeilleurDef := MeilleurDefTemp;
         ScorePourNoir := nNoi-nBla;
         
         SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0));
         if afficheMeilleureSuite then EcritMeilleureSuite;
       end;
   end;
  
  
  if debuggage.calculFinaleOptimaleParOptimalite then
    if ligneOptimaleJusquaLaFin 
      then WritelnStringAndNumDansRapport('ligne optimale : ok    ',nroCoupAtteint)
      else WritelnStringAndNumDansRapport('ligne optimale : faux  ',nroCoupAtteint);
  
  
  
  if debuggage.calculFinaleOptimaleParOptimalite and not(ligneOptimaleJusquaLaFin) then
    begin
     SysBeep(0);
     WritelnStringAndBoolDansRapport('PeutCalculerFinaleOptimaleParOptimalite := ',ligneOptimaleJusquaLaFin);
     WritelnStringAndNumDansRapport('Sortie de PeutCalculerFinaleOptimaleParOptimalite, coup=',nroCoupAtteint);
     WritelnDansRapport('');
    end;

   PeutCalculerFinaleOptimaleParOptimalite := ligneOptimaleJusquaLaFin;
end;


procedure EcritRefutationsDansRapport(longClass : SInt32; var classAux : ListOfMoveRecords);
var i,coup,refutation : SInt32;
    s,s1 : str255;
begin
  s := '(';
  for i := 1 to longClass do
    begin
      coup := classAux[i].x;
      refutation := classAux[i].theDefense;
      if i=1 
        then s1 := Concat('sur ',CoupEnString(coup,CassioUtiliseDesMajuscules),', ',CoupEnString(refutation,CassioUtiliseDesMajuscules),'!')
        else s1 := Concat(CoupEnString(coup,CassioUtiliseDesMajuscules),' ',CoupEnString(refutation,CassioUtiliseDesMajuscules),'!');
      if i<longClass then s1 := s1+' ; ';
      s := s+s1;
    end;
  s := s+')';
  DisableKeyboardScriptSwitch;
  FinRapport;
  TextNormalDansRapport;
  WritelnDansRapport('  '+s);
  EnableKeyboardScriptSwitch;
end;

procedure EcritAnnonceFinaleDansMeilleureSuite(typeCalculFinale,nroCoup,deltaFinale : SInt32);
begin
  if not(CassioEstEnModeAnalyse() & meilleureSuiteAEteCalculeeParOptimalite) then
    begin
      with meilleureSuiteInfos do   
        begin
          case TypeCalculFinale of
            ReflGagnant           : statut := ReflAnnonceGagnant;
            ReflGagnantExhaustif  : statut := ReflAnnonceGagnant;
            ReflParfait           : statut := ReflAnnonceParfait;
            ReflParfaitExhaustif  : statut := ReflAnnonceParfait;
            ReflRetrogradeParfait : statut := ReflAnnonceParfait;
            ReflRetrogradeGagnant : statut := ReflAnnonceGagnant;
            otherwise               statut := NeSaitPas;
          end;
          meilleureSuiteInfos.numeroCoup := nroCoup;
        end;
      SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,(deltaFinale<kDeltaFinaleInfini),0));
      if afficheMeilleureSuite & (GetMeilleureSuite() <> GetDerniereAnnonceFinaleDansMeilleureSuite()) then 
        begin
          EcritMeilleureSuite;
          SetDerniereAnnonceFinaleDansMeilleureSuite(GetMeilleureSuite());
        end;
    end;
end;


procedure SetDerniereAnnonceFinaleDansMeilleureSuite(s : str255);
begin
  gDerniereAnnonceFinaleDansMeilleureSuite := s;
end;


function GetDerniereAnnonceFinaleDansMeilleureSuite() : str255;
begin
  GetDerniereAnnonceFinaleDansMeilleureSuite := gDerniereAnnonceFinaleDansMeilleureSuite;
end;


procedure CopyEnPlOthEndgame(var source : plateauOthello; var dest:plOthEndgame);
var i : SInt32;
begin
  for i := 0 to 99 do
    dest[i] := source[i];
end;


function EtablitListeCasesVides(var plat : plateauOthello; var listeCasesVides:listeVides) : SInt32;
var nbVidesTrouvees,i,caseTestee : SInt32;
begin
  nbVidesTrouvees := 0;
  i := 0;
  repeat
    inc(i);
    caseTestee := othellier[i];   
    if plat[caseTestee] = pionVide then  
      begin 
        inc(nbVidesTrouvees);
        listeCasesVides[nbVidesTrouvees] := caseTestee;
      end;
  until i>=64;
  EtablitListeCasesVides := nbVidesTrouvees;
end;

{faible mobilite adverse d'abord}
{attention ! les cases vides de source doivent etre *exactement* les cases vides de la position}
function TrierSelonDivergenceSansMilieu(var plat : plateauOthello;couleur,nbCasesVides : SInt32; var source,dest:listeVides) : SInt32;
label finBoucleFor;
var i,j,k,nbCoups,mobAdverse,coupTest,coupdiv : SInt32;
    x,dx,t,couleurAdversaire : SInt32;
    classementDivergence:listeVidesAvecValeur;
    platDiv:plOthEndgame;
    coupLegal : boolean;
 begin
   platDiv := plat;
   couleurAdversaire := -couleur;
   
   nbCoups := 0;
   for i := 1 to nbCasesVides do
     begin
       coupTest := source[i];
       
       if platDiv[coupTest] <> pionVide then 
         begin
           WritelnDansRapport('Probleme dans TrierSelonDivergenceSansMilieu: platDiv[coupTest] <> pionVide');
           SysBeep(0);
           AttendFrappeClavier;
         end;
       
       coupLegal := ModifPlatSeulementLongint(coupTest,couleur,couleurAdversaire,platDiv);
       if coupLegal
         then
           begin
             inc(nbCoups);
             mobAdverse := 0;
             for j := 1 to nbCasesVides do
               if j<>i then
                 begin
                   coupDiv := source[j];
                   
                   if platDiv[coupDiv] <> pionVide then 
						         begin
						           WritelnDansRapport('Probleme : platDiv[coupDiv] <> pionVide');
						           SysBeep(0);
						           AttendFrappeClavier;
						         end;
                   
                   
                   for t := dirPriseDeb[coupDiv] to dirPriseFin[coupDiv] do
                     begin
                       dx := dirPrise[t];
                       x := coupDiv+dx;
                       if platDiv[x]=couleur then
                         begin
                           repeat
                             x := x+dx;
                           until platDiv[x]<>couleur;
                           if (platDiv[x] = couleurAdversaire) then
                             begin
                               inc(mobAdverse);
                               if estUnCoin[coupDiv] then inc(mobAdverse); {les coins comptent pour deux}
                               goto finBoucleFor;
                             end;
                         end;
                     end;
                   finBoucleFor:
                 end;
                 
             {la phase d'insertion du tri par insertion selon la mobilite adverse decroissante}
             k := 1;
             while (classementDivergence[k].theVal <= mobAdverse) & (k<nbCoups) do inc(k);
             for j := nbCoups downto succ(k) do classementDivergence[j] := classementDivergence[j-1];
             classementDivergence[k].coup   := coupTest;
             classementDivergence[k].theVal := mobAdverse;

             platDiv := plat;
           end;
     end;
   for i := 1 to nbCoups do
     dest[i] := classementDivergence[i].coup;
   TrierSelonDivergenceSansMilieu := nbCoups;
 end;
 
 
    
{faible mobilite adverse d'abord}
{attention ! les cases vides de source doivent etre *exactement* les cases vides de la position}
function TrierSelonDivergenceAvecMilieu(var plat : plateauOthello;couleur,nbCasesVides,conseilHash : SInt32; var source,dest:listeVides; var InfosMilieuDePartie:InfosMilieuRec;
                                        alpha,beta : SInt32; var coupureAlphaProbable,coupureBetaProbable : boolean;utiliserMilieu : boolean) : SInt32;
label finBoucleFor;
var i,j,k,nbCoups,mobAdverse,coupTest,coupdiv : SInt32;
   x,dx,t,evalCouleur,evalAdverse,couleurAdversaire,uneDefense : SInt32;
   profondeurPourLeTri : SInt32;
   nbEvalRecursives : SInt32;
   seuil_fastest,seuil_super_fastest : SInt32;
   platDiv:plOthEndgame;
   InfosMilieuDiv:InfosMilieuRec;
   classementDivergence:listeVidesAvecValeur;
   coupLegal : boolean;
   {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
   microSecondesCurrent,microSecondesDepart:UnsignedWide;
   {$ENDC}
   tempUsingRecursiveEval : boolean;
begin  {$UNUSED conseilHash}
	 platDiv := plat;
	 
	 
	 if ((64 - InfosMilieuDePartie.nbBlancs - InfosMilieuDePartie.nbNoirs) <= 15) then
	   begin
	     tempUsingRecursiveEval := avecRecursiviteDansEval;
       avecRecursiviteDansEval := false;
	   end;
	 
	 if utiliserMilieu then 
	   with InfosMilieuDePartie do
	     begin
	       evalCouleur := Evaluation(plat,couleur,nbBlancs,nbNoirs,jouable,frontiere,false,
      	                                (alpha - seuil_pour_alpha_fastest),(beta + seuil_pour_beta_fastest),nbEvalRecursives);
      	       
	       coupureAlphaProbable := coupureAlphaProbable | (evalCouleur <= alpha - 800);
	       coupureBetaProbable  := coupureBetaProbable  | (evalCouleur >= beta  + 800);
	       
	       if ((evalCouleur <= alpha - seuil_pour_alpha_fastest) |
          	 ((evalCouleur >= beta + seuil_pour_beta_fastest) & ((64 - nbBlancs - nbNoirs) <= 16)))
          	then utiliserMilieu := false
            else InfosMilieuDiv := InfosMilieuDePartie;
         
         
	     end;
	   
	 {$IFC USE_DEBUG_STEP_BY_STEP}
	 if gDebuggageAlgoFinaleStepByStep.actif &
       (nbCasesVides >= gDebuggageAlgoFinaleStepByStep.profMin) &
       MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
      begin
        WritelnDansRapport('Entree dans TrierSelonDivergenceAvecMilieu');
        WritelnStringAndNumDansRapport('alpha = ',alpha);
        WritelnStringAndNumDansRapport('beta = ',beta);
        if utiliserMilieu then WritelnStringAndNumDansRapport('evalCouleur = ',evalCouleur);
        WritelnStringAndBoolDansRapport('utiliserMilieu = ',utiliserMilieu);
      end;
	 {$ENDC}
	 
	 couleurAdversaire := -couleur;
	 
	 nbCoups := 0;
	 for i := 1 to nbCasesVides do
	   begin
	     coupTest := source[i];
         
	     if utiliserMilieu 
	       then with InfosMilieuDiv do
	              coupLegal := ModifPlatLongint(coupTest,couleur,platDiv,jouable,nbBlancs,nbNoirs,frontiere)
	       else   coupLegal := ModifPlatSeulementLongint(coupTest,couleur,couleurAdversaire,platDiv);
	     if coupLegal
	       then
	         begin
	           inc(nbCoups);
	           { if (coupTest = conseilHash) & (conseilHash > 0)
	             then
	               mobAdverse := -2000000  (* comme ca on est sur de le mettre en tete :-) *)
	             else }
	               begin
	                 mobAdverse := 0;
	                 for j := 1 to nbCasesVides do
	                   if j<>i then
	                     begin
	                       coupDiv := source[j];
	                       for t := dirPriseDeb[coupDiv] to dirPriseFin[coupDiv] do
	                         begin
	                           dx := dirPrise[t];
	                           x := coupDiv+dx;
	                           if platDiv[x]=couleur then
	                             begin
	                               repeat
	                                 x := x+dx;
	                               until platDiv[x]<>couleur;
	                               if (platDiv[x] = couleurAdversaire) then
	                                 begin
	                                   inc(mobAdverse);
	                                   if estUnCoin[coupDiv] then inc(mobAdverse); {les coins comptent pour deux}
	                                   goto finBoucleFor;
	                                 end;
	                             end;
	                         end;
	                       finBoucleFor:
	                     end;
	                 
	                 if utiliserMilieu then
	                   with InfosMilieuDiv do
	                     begin
	                           
	                       
	                       
	                       {if effetspecial & (nroEffetspecial >= 2)
	                         then profondeurPourLeTri := profTriInterneEnFinale[64-nbBlancs-nbNoirs] + 1
	                         else }profondeurPourLeTri := profTriInterneEnFinale[64-nbBlancs-nbNoirs];
	                       
	                       
	                       seuil_super_fastest := valeur_seuil_fastest_first[64-nbBlancs-nbNoirs] + valeur_seuil_super_fastest;
	                       
	                       seuil_fastest := valeur_seuil_fastest_first[64 - nbBlancs - nbNoirs];
	                       
	                       
	                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
	                       Microseconds(microSecondesDepart);
	                       {$ENDC}
	                       evalAdverse := Evaluation(platDiv,couleurAdversaire,nbBlancs,
	                                                        nbNoirs,jouable,frontiere,false,
	                                                        -30000,30000,nbEvalRecursives);
	                                                       
	                       if (profondeurPourLeTri >= 0) & 
	                          not(evalAdverse <= (-beta - seuil_super_fastest)) &
	                          not(evalAdverse >= (-alpha + seuil_super_fastest))
	                            then
	                              begin
	                              
	                                {if effetspecial & 
	                                   ((nroEffetspecial = 1) | (nroEffetspecial = 2) | (nroEffetspecial = 5))
	                                 then
	                                   evalAdverse := AB_simple(platDiv,jouable,uneDefense,
		                                                 couleurAdversaire,profondeurPourLeTri,
		                                                 (-beta - seuil_super_fastest),(-alpha + seuil_super_fastest),nbBlancs,nbNoirs,frontiere,true)
	                                 else 
	                                   }evalAdverse := AB_simple(platDiv,jouable,uneDefense,
		                                                 couleurAdversaire,profondeurPourLeTri,
		                                                 -30000,30000,nbBlancs,nbNoirs,frontiere,true);
		                                                 
					                        {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}                         
					                        Microseconds(microSecondesCurrent);
					                        AjouterTempsDansMiniProfiler(64-nbBlancs-nbNoirs,profondeurPourLeTri,microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
					                        {$ENDC}
					                      end
					                    else
					                      begin
					                        {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
					                        Microseconds(microSecondesCurrent);
					                        AjouterTempsDansMiniProfiler(64-nbBlancs-nbNoirs,-2,microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
					                        {$ENDC}
					                      end;
	                                                     
	                       
	                       
	                       if utilisationNouvelleEval
	                         then 
	                           begin
	                             
	                             if evalAdverse <= (-beta - seuil_fastest)
	                               then
	                                 begin
	                                   {WritelnPositionEtTraitDansRapport(plat,couleur);
	                                   WritelnStringDansRapport('coup critique='+CoupEnString(coupTest,true));
	                                   WritelnStringAndNumDansRapport('evalAdverse=',evalAdverse);
	                                   WritelnStringAndNumDansRapport('avant, mobAdverse=',mobAdverse);}
	                                   
	                                   mobAdverse := mobAdverse*1200;  {chaque coup adverse en moins vaut 6 pions}
	                                   mobAdverse := mobAdverse+evalAdverse;
	                                   mobAdverse := mobAdverse-1000000;
	                                   
	                                   {WritelnStringAndNumDansRapport('après, mobAdverse=',mobAdverse);
	                                   WritelnDansRapport('');
	                                   AttendFrappeClavier;}
	                                 end
	                               else
	                                 begin
	                                   mobAdverse := mobAdverse + (evalAdverse div 200);
	                                 end;
	                           end
	                         else mobAdverse := mobAdverse + (evalAdverse div 1000);
	                     end;
	               end;
	               
	           {la phase d'insertion du tri par insertion selon la mobilite adverse decroissante}
	           k := 1;
	           while (classementDivergence[k].theVal <= mobAdverse) & (k<nbCoups) do inc(k);
	           for j := nbCoups downto succ(k) do classementDivergence[j] := classementDivergence[j-1];
	           classementDivergence[k].coup   := coupTest;
	           classementDivergence[k].theVal := mobAdverse;

	           platDiv := plat;
	           if utiliserMilieu then InfosMilieuDiv := InfosMilieuDePartie;
	         end;
	   end;
	 for i := 1 to nbCoups do
	   dest[i] := classementDivergence[i].coup;
	 TrierSelonDivergenceAvecMilieu := nbCoups;
	 
	 
	 
	 if ((64 - InfosMilieuDePartie.nbBlancs - InfosMilieuDePartie.nbNoirs) <= 15) then
	   begin
	     avecRecursiviteDansEval := tempUsingRecursiveEval;
	   end;
end;
  
  
procedure TrierSelonHashTableExacte(platDepart : PositionEtTraitRec; var classement : ListOfMoveRecords;longClass,clefHashage : SInt32);
var i,k,coup,hashKeyAfterCoup : SInt32;
    platAux : PositionEtTraitRec;
    valMinDuCoup,valMinPourNoir,valMaxPourNoir : SInt32;
    table_tri : ListOfMoveRecords;
    temp : MoveRecord;
begin 

  (* WritelnDansRapport('');
     WritelnDansRapport('Entrée dans TrierSelonHashTableExacte'); *)
  
  
  for i := 1 to longClass do
    begin
      table_tri[i] := classement[i];
      table_tri[i].notePourLeTri := -64;
    end;
  
  for i := 1 to longClass do
    begin
      coup := table_tri[i].x;
      platAux := platDepart;
      
      if UpdatePositionEtTrait(platAux,coup) 
        then
	        begin
			      hashKeyAfterCoup := BXOR(clefHashage, IndiceHash^^[GetTraitOfPosition(platAux),coup]);
			      
			      if GetEndgameValuesInHashTableAtThisHashKey(platAux,hashKeyAfterCoup,kDeltaFinaleInfini,valMinPourNoir,valMaxPourNoir)
			        then
			          begin
			            if GetTraitOfPosition(platDepart) = pionNoir
			              then valMinDuCoup :=  valMinPourNoir
			              else valMinDuCoup := -valMaxPourNoir;
			            (* WritelnStringAndNumDansRapport('trouvé '+CoupEnString(coup,true)+' => ',valMinDuCoup); *)
			          end
			        else
			          begin
			            valMinDuCoup := -64;
			            (* WritelnDansRapport('non trouvé '+ CoupEnString(coup,true)); *)
			          end;
			      table_tri[i].notePourLeTri := valMinDuCoup;    
			      
			      
			      {tri par insertion}
			      for k := i downto 2 do
			        if (table_tri[k].notePourLeTri > table_tri[k-1].notePourLeTri) then
			          begin
			            temp := table_tri[k-1];
			            table_tri[k-1] := table_tri[k];
			            table_tri[k] := temp;
			            
			            {on fait les mouvements miroirs sur le vrai classement}
			            temp := classement[k-1];
			            classement[k-1] := classement[k];
			            classement[k] := temp;
			          end;
			    end
			  else
			    begin
			      WritelnDansRapport('HORREUR ! not(UpdatePositionEtTrait(platAux,coup) dans TrierSelonHashTableExacte !!!');
			    end;
    end;
    
(*WritelnDansRapport('apres tri :');
  for i := 1 to longClass do
    WritelnStringAndNumDansRapport(CoupEnString(table_tri[i].x,true)+' => ',table_tri[i].notePourLeTri);
  WritelnDansRapport('');
  for i := 1 to longClass do
    WritelnStringAndNumDansRapport(CoupEnString(classement[i].x,true)+' => ',classement[i].notePourLeTri);
  WritelnDansRapport('Sortie de TrierSelonHashTableExacte');
  WritelnDansRapport(''); *)
end;


procedure SetMinimaxAEvalueAUMoinsUnCoupDansCettePasse(flag : boolean);
begin
  gMinimaxAEvalueAUMoinsUnCoupDansCettePasse := flag;
  {WritelnStringAndBooleanDansRapport('SetMinimaxAEvalueAUMoinsUnCoupDansCettePasse <- ', flag);}
end;

function MinimaxAEvalueAUMoinsUnCoupDansCettePasse() : boolean;
begin
  MinimaxAEvalueAUMoinsUnCoupDansCettePasse := gMinimaxAEvalueAUMoinsUnCoupDansCettePasse;
  {WritelnStringAndBooleanDansRapport('MinimaxAEvalueAUMoinsUnCoupDansCettePasse -> ', gMinimaxAEvalueAUMoinsUnCoupDansCettePasse);}
end;





END.






















