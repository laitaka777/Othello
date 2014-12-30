UNIT UnitMilieuDePartie;


{$DEFINEC USE_PROFILER_MILIEU_DE_PARTIE   FALSE}

INTERFACE







USES  
{$IFC USE_PROFILER_MILIEU_DE_PARTIE}
      Profiler,
{$ENDC}
      UnitOth0,UnitSquareSet;
      


CONST 
  kProfMinimalePourSuiteDansRapport = 11;

procedure CalculeClassementMilieuDePartie(var classement : ListOfMoveRecords;
                                          var indexDuCoupConseille : SInt32;
                                          MC_coul,MC_prof,MC_nbBl,MC_nbNo : SInt32;
                                          var MC_jeu : plateauOthello; var MC_empl : plBool; var MC_frontiere : InfoFrontRec;
                                          calculerMemeSiUnSeulCoupLegal : boolean;
                                          casesExclues : SquareSet);
function CalculeMeilleurCoupMilieuDePartie(var jeu : plateauOthello; var emplBool : plBool; var frontiere : InfoFrontRec;
                                            couleur,profondeur,nbBlancs,nbNoirs : SInt32) : MoveRecord;


procedure SetProfImposee(flag : boolean; const fonctionAppelante : str255);
function ProfondeurMilieuEstImposee() : boolean;


IMPLEMENTATION







USES UnitEvaluation,UnitSuperviseur,UnitActions,UnitEntreesSortiesGraphe,UnitJeu,
     UnitNotesSurCases,UnitStringSet,UnitRapportImplementation,UnitUtilitaires,
     Unit_AB_scout,Unit_AB_simple,UnitTore,MyMathUtils, UnitDefinitionsApprentissage,
     UnitAffichageReflexion,UnitMacExtras,UnitOth1,UnitMoveRecords,UnitServicesDialogs,
     UnitStrategie,UnitMiniProfiler,UnitJaponais,UnitOth2,UnitCalculsApprentissage,
     UnitMacExtras,UnitListe,UnitHashTableExacte,UnitRapport,UnitBufferedPICT,
     UnitGestionDuTemps,UnitPhasesPartie,SNStrings,UnitScannerOthellistique,UnitFenetres,
     UnitProblemeDePriseDeCoin;


var profondeurDerniereLigneEcriteDansRapport : SInt32;


procedure VerifieAssertionsSurClassementDeMilieu(var classement : ListOfMoveRecords; longClass : SInt32; var position : plateauOthello; const fonctionAppelante : str255);
var i,t : SInt32;
begin
  if (longClass >= 2) then
    begin
      for i := 2 to longClass do
        if (classement[i].x = classement[i - 1].x) then
          begin
            Sysbeep(0);
            WritelnDansRapport('WARNING : deux coups identiques dans VerifieAssertionsSurClassementDeMilieu !');
            WritelnDansRapport('fonction appelante = ' + fonctionAppelante);
            WritelnPositionDansRapport(position);
            for t := 1 to longClass do
              begin
                WriteStringAndCoupDansRapport('coup class = ',classement[t].x);
	              WritelnStringAndNumDansRapport(' => ',classement[t].note);
              end;
          end;
    end;
end;


procedure CalculeClassementMilieuDePartie(var classement : ListOfMoveRecords;
                                          var indexDuCoupConseille : SInt32;
                                          MC_coul,MC_prof,MC_nbBl,MC_nbNo : SInt32;
                                          var MC_jeu : plateauOthello; var MC_empl : plBool; var MC_frontiere : InfoFrontRec;
                                          calculerMemeSiUnSeulCoupLegal : boolean;
                                          casesExclues : SquareSet);
var coulPourMeilleurMilieu,coulDefense:-1..1;     
    nbCasesVidesMilieu : SInt32;
    casesVidesMilieu : array[1..64] of 0..99;   
    moves : plBool;
    mob : SInt32;
    iCourant,nbCoup : SInt32;
    i : SInt32; 
    tempoPhase : SInt32;
    profondeurDemandee : SInt32;
    profReelle,profsuivante : SInt32;
    tempseffectif : SInt32;
    diffDeTemps : SInt32;
    diffprecedent : SInt32;
    tempsAlloueAuDebutDeLaReflexion : SInt32;
    doitSeDepecher : boolean;
    defense : SInt32;
    MFniv : SInt32;
    rapidite,divergence : extended;
    coeffMultiplicateur : extended;
    hesitationSurLeBonCoup,vraimentTresFacile : boolean;
    nbFeuillesCetteProf : SInt32;
    sortieBoucleProfIterative : boolean;
    StatistiquesSurLesCoups : array[0..kNbMaxNiveaux] of 
                                     record
                                       teteDeListe : SInt32;  {coup en tete à ce niveau}
                                       nbfeuillesTeteDeListe : SInt32;
                                       nbFeuillesTotalCetteProf : SInt32;
                                       tempsCetteProf : SInt32;
                                     end;
    rechercheDejaAnnoncee : boolean;
    nbCoupRecherche : SInt32;
    MeilleureNoteProfInterativePrecedente : SInt32;
    oldInterruption : SInt32;
    numeroCellule : SInt32;
    varierLesCoups : boolean;
    lignesEcritesDansRapport : StringSet;
    
{$IFC USE_PROFILER_MILIEU_DE_PARTIE}
    nomFichierProfile : str255;
    tempsGlobalDeLaFonction : SInt32;
{$ENDC}

procedure AnnonceRechercheMilieuDePartieDansRapport;
var s,s1,s2 : str255;
begin
  if not(demo) & (not(jeuInstantane) | analyseRetrograde.enCours) then
    begin
      NumToString((MC_nbBl+MC_nbNo-4)+1,s1);
      if MC_coul = pionNoir
        then s2 := ReadStringFromRessource(TextesListeID,7)   {Noir}
        else s2 := ReadStringFromRessource(TextesListeID,8);  {Blanc}
      GetIndString(s,TextesRapportID,2); {Recherche au coup ^0 pour ^1 : milieu de partie}
      s := ParamStr(s,s1,s2,'','');
      if GetEffetSpecial() then s := s + ' (effet special)';
      DisableKeyboardScriptSwitch;
      FinRapport;
      TextNormalDansRapport;
      WritelnDansRapport('');
      
      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
      
      ChangeFontFaceDansRapport(bold);
      WritelnDansRapport(s);
      ChangeFontFaceDansRapport(normal);
      EnableKeyboardScriptSwitch;
      rechercheDejaAnnoncee := true;
      profondeurDerniereLigneEcriteDansRapport := -1000;
    end;
end;


procedure MeilleureSuiteEtNoteDansRapport(coul,note,profondeur : SInt16; chaineGauche : str255; var chainesDejaEcrites : StringSet);
var s : str255;
    oldScript : SInt32;
    data : SInt32;
begin
  if not(jeuInstantane) | analyseRetrograde.enCours then
    begin
		  s := chaineGauche + MeilleureSuiteEtNoteEnChaine(coul,note,profondeur);
		  if not(MemberOfStringSet(s,data,chainesDejaEcrites))
		    then
		      begin
		        
					  GetCurrentScript(oldScript);
					  DisableKeyboardScriptSwitch;
					  FinRapport;
			      TextNormalDansRapport;
			      
			      if (profondeur <> profondeurDerniereLigneEcriteDansRapport) &
			         (profondeurDerniereLigneEcriteDansRapport > 0) &
			         (avecEvaluationTotale | (nbCoupsEnTete > 1))
			        then WritelnDansRapport('');
			        
			      WritelnDansRapport(s);
			      EnableKeyboardScriptSwitch;
			      SetCurrentScript(oldScript);
			      SwitchToRomanScript;
			      AddStringToSet(s,0,chainesDejaEcrites);
			      profondeurDerniereLigneEcriteDansRapport := profondeur;
			    end;
    end;
end;


procedure AnnonceMeilleureSuiteEtNoteDansRapport(couleur,note,profondeur : SInt32);
begin
  if not(demo) & (not(jeuInstantane) | analyseRetrograde.enCours) then
    begin
      if not(rechercheDejaAnnoncee) then
        if not(HumCtreHum) & (MC_Coul=couleurMacintosh) then  
          AnnonceRechercheMilieuDePartieDansRapport;
      MeilleureSuiteEtNoteDansRapport(couleur,note,profondeur,'  ',lignesEcritesDansRapport);
    end;
end;


procedure CollecteStatistiques(prof : SInt32; var classement : ListOfMoveRecords;nbFeuillesCetteProf,tempsDeCetteProf : SInt32);
begin
  if (prof < 0) | (prof > kNbMaxNiveaux) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT : (prof < 0) | (prof > kNbMaxNiveaux) dans CollecteStatistiques');
      WritelnStringAndNumDansRapport('prof = ',prof);
      exit(CollecteStatistiques);
    end;
    
  StatistiquesSurLesCoups[prof].teteDeListe := classement[1].x;
  StatistiquesSurLesCoups[prof].nbfeuillesTeteDeListe := classement[1].nbfeuilles;
  StatistiquesSurLesCoups[prof].nbFeuillesTotalCetteProf := nbFeuillesCetteProf;
  StatistiquesSurLesCoups[prof].tempsCetteProf := tempsDeCetteProf;
  
  if InfosTechniquesDansRapport 
     & (prof >= 10) 
     & not(demo) 
     & not(RechercheDeProblemeDePriseDeCoinEnCours()) 
     & (not(jeuInstantane) | analyseRetrograde.enCours)
    then
      begin
        WriteStringAndNumDansRapport('prof = ',prof+1);
        WriteStringAndNumEnSeparantLesMilliersDansRapport('  feuilles = ',nbFeuillesCetteProf);
        WriteStringAndNumEnSeparantLesMilliersDansRapport('  temps = ',tempsDeCetteProf);
        if (interruptionReflexion <> pasdinterruption)
          then WritelnDansRapport('  (interruption !)')
          else WritelnDansRapport('');
      end;
end;



function CoupFacile(var classement : ListOfMoveRecords;longClass : SInt32; var vraimentFacile : boolean) : boolean;
var i,nbNiveauxTermines,CoupEnTeteDernierNiveau : SInt32;
    MemeCoupEnTeteDernierNiveauEtPrec,testCoupFacile : boolean;
    rapportDeuxiemeSurTete : SInt32;
    nbFeuillesDeuxieme : SInt32;
    profmax : SInt32;
begin
  testCoupFacile := false;  
  vraimentFacile := false;
  nbNiveauxTermines := 0;
  for i := 0 to kNbMaxNiveaux do
    if StatistiquesSurLesCoups[i].teteDeListe <> 0 then 
      begin
        nbNiveauxTermines := nbNiveauxTermines+1;
        profMax := i;
      end;
  if (nbNiveauxTermines>=3) then
    begin
      CoupEnTeteDernierNiveau := StatistiquesSurLesCoups[profmax].teteDeListe;
      MemeCoupEnTeteDernierNiveauEtPrec := false;
      for i := 0 to kNbMaxNiveaux do
        if (i<>profmax) & (StatistiquesSurLesCoups[i].teteDeListe <> 0) then
          MemeCoupEnTeteDernierNiveauEtPrec := (StatistiquesSurLesCoups[i].teteDeListe=CoupEnTeteDernierNiveau);
      nbFeuillesDeuxieme := -20000;
      with StatistiquesSurLesCoups[profmax] do
        begin
         for i := 1 to longClass do
           if classement[i].x<>teteDeListe then
             if classement[i].nbfeuilles>nbFeuillesDeuxieme then
               nbFeuillesDeuxieme := classement[i].nbfeuilles;
        end;
      if nbFeuillesDeuxieme>0 
        then rapportDeuxiemeSurTete := (100*nbFeuillesDeuxieme) div StatistiquesSurLesCoups[profmax].nbfeuillesTeteDeListe
        else rapportDeuxiemeSurTete := 500;      
         
      with StatistiquesSurLesCoups[profmax] do
      if ((rapportDeuxiemeSurTete <= 30) & (profmax+1 >= 9)) |
         (((nbfeuillesTeteDeListe/nbFeuillesTotalCetteProf) > 0.90) & (profmax+1 >= 7)) then
        if MemeCoupEnTeteDernierNiveauEtPrec then
            begin
              testCoupFacile := true;
              vraimentFacile := ((nbfeuillesTeteDeListe/nbFeuillesTotalCetteProf) > 0.90);
            end;              
            
       
      if debuggage.gestionDuTemps then
        begin
          InvalidateAllCasesDessinEnTraceDeRayon;
          EcranStandard(NIL,true);
          EssaieSetPortWindowPlateau;
          for i := 0 to 20 do
           if StatistiquesSurLesCoups[i].teteDeListe <> 0 then
             with StatistiquesSurLesCoups[i] do
             begin
               WriteStringAndNumAt('p=',i+1,10,10+i*12);
               WriteStringAndNumAt('AdressePattern[kAdresseBordEst]=',teteDeListe,50,10+i*12);
               WriteStringAndReelAt('% feuilles du meilleur sur cette prof=',
                                   100.0*nbfeuillesTeteDeListe/nbFeuillesTotalCetteProf,120,10+i*12);
             end;
          WriteStringAndNumAt('% nb feuilles du 2ème/1er =',rapportDeuxiemeSurTete,350,10+12*profmax);
          WriteStringAndBoolAt('coup facile =',testCoupFacile,10,30+12*profmax);       
        end;
            
    end;  
  Coupfacile := testCoupFacile;
end;


procedure MiniMax(couleur,MiniProf,longClass,nbBla,nbNoi : SInt32;jeu : plateauOthello;empl : plBool;
                  var class : ListOfMoveRecords; var front : InfoFrontRec; var hesitation : boolean);
var Xcourant : SInt32;      
    valXY : SInt32;
    platMod : plateauOthello;
    jouablMod : plBool;
    nbBlancMod,nbNoirMod : SInt32;
    frontMod : InfoFrontRec;
    sortieDeBoucle : boolean;
    classAux : ListOfMoveRecords;
    i,j,k,compteur,aux : SInt32;
    indice_du_meilleur : SInt32;
    longueurDuClassement : SInt32;
    betaAB,bestAB : SInt32;
    DefCoup : SInt32;
    TickChrono,TempsDeXCourant : SInt32;
    nbreFeuillesDeXCourant : SInt32;
    SauvegardeValeursNoir,SauvegardeValeursBlanc : platValeur;
    ValeurDeGauche : SInt32;
    oldMeilleureSuiteInfos:meilleureSuiteInfosRec;
    suiteEstInteressante : boolean;
    nbEvalRecursives : SInt32;
    coupLegal : boolean;
    
function NoteDeCeCoupIterationPrecedente(whichSquare : SInt32) : SInt32;
var i : SInt32;
begin
  
  aux := -notemax;
  
  for i := 1 to longClass do
    if (class[i].x = whichSquare) then
      aux := class[i].note;
      
  {WritelnStringAndNumDansRapport('NoteDeCeCoupIterationPrecedente('+CoupEnString(whichSquare,true)+') = ',aux);}
            
  NoteDeCeCoupIterationPrecedente := aux;
end;
    
function CalculParIncrement(estimationDeDepart,largeurFenetre,increment : SInt32;alpha,beta : SInt32; var derniereEvalRenvoyee : SInt32) : SInt32;
var aux,bas_Fenetre,haut_Fenetre : SInt32;
    conseilTurbulence : SInt32;
    copieDeClefHashage : SInt32;
begin

  conseilTurbulence := -1;
  
  copieDeClefHashage := SetClefHashageGlobale(gClefHashage);
  
  if (alpha >= beta) then
    begin
      SysBeep(0);
      WritelnStringDansRapport('la fenêtre (alpha,beta) n''est pas dans le bon sens dans CalculParIncrement : ');
      WritelnStringAndNumDansRapport('alpha = ',alpha);
      WritelnStringAndNumDansRapport('beta = ',beta);
      WritelnDansRapport('j''utilise (-notemax,+notemax) à la place...');
      alpha := -30000;
      beta  := +30000;
    end;
  
  if (estimationDeDepart >= 25000) | (estimationDeDepart <= -25000) then
    begin
      SysBeep(0);
      WritelnStringAndNumDansRapport('estimationDeDepart semble trop grand ou trop petit : ',estimationDeDepart);
      WritelnDansRapport('j''utilise 0 à la place...');
      estimationDeDepart := 0;
    end;
  
  if estimationDeDepart - largeurFenetre >= beta   then estimationDeDepart := beta  + largeurFenetre - 1;
  if estimationDeDepart + largeurFenetre <= alpha  then estimationDeDepart := alpha - largeurFenetre + 1;
  
  if (estimationDeDepart + largeurFenetre <= alpha) | (estimationDeDepart - largeurFenetre >= beta) then
    begin
      SysBeep(0);
      WritelnStringDansRapport('estimationDeDepart n''est pas dans la fenetre (alpha,beta) : ');
      WritelnStringAndNumDansRapport('alpha = ',alpha);
      WritelnStringAndNumDansRapport('beta = ',beta);
      WritelnStringAndNumDansRapport('estimationDeDepart = ',estimationDeDepart);
      WritelnDansRapport('j''utilise (alpha+beta)/2 à la place...');
      
      estimationDeDepart := (alpha + beta) div 2;
    end;
  
  
  
  bas_Fenetre  := Max(estimationDeDepart - largeurFenetre,alpha);
  haut_Fenetre := Min(estimationDeDepart + largeurFenetre,beta);
  
  if (bas_Fenetre >= haut_Fenetre) then
    begin
      SysBeep(0);
      WritelnStringDansRapport('problème dans CalculParIncrement : (bas_Fenetre >= haut_Fenetre)');
      WritelnStringAndNumDansRapport('bas_Fenetre = ',bas_Fenetre);
      WritelnStringAndNumDansRapport('haut_Fenetre = ',haut_Fenetre);
    end;
  
  
  {
  WriteDansRapport('dans CalculParIncrement('+CoupEnString(XCourant,true)+') : ');
  WriteStringAndNumDansRapport(' estim = ',estimationDeDepart);
  WritelnStringAndNumDansRapport('  hist = ',NoteDeCeCoupIterationPrecedente(XCourant));
  WriteStringAndNumDansRapport('  bas_Fenetre = ',bas_Fenetre);
  WritelnStringAndNumDansRapport('  haut_Fenetre = ',haut_Fenetre);}
  
  
  aux := -ABScout(platMod,jouablMod,defense,XCourant,coulDefense,
                  MiniProf,MiniProf,0,0,coulPourMeilleurMilieu,
                  -haut_Fenetre,-bas_Fenetre,nbBlancMod,nbNoirMod,frontMod,conseilTurbulence,true);
  
  {WritelnStringAndNumDansRapport('  => ',aux);}
  
  if (aux>=haut_Fenetre) 
    then
      {on monte jusqu'a trouver la bonne valeur}
      while (aux>=haut_Fenetre) & (aux < beta) & (interruptionReflexion = pasdinterruption) do
        begin
        
          bas_Fenetre  := aux;
          haut_Fenetre := Min(aux+increment,beta);
          
          aux := -ABScout(platMod,jouablMod,defense,XCourant,coulDefense,
                          MiniProf,MiniProf,0,0,coulPourMeilleurMilieu,
                         -haut_Fenetre,-bas_Fenetre,nbBlancMod,nbNoirMod,frontMod,conseilTurbulence,true);
                         
          {WritelnStringAndNumDansRapport(' up  => ',aux);}
          
        end 
    else
  if (aux<=bas_fenetre) 
    then
      {on descend jusqu'a trouver la bonne valeur}
      while (aux<=bas_fenetre) & (aux > alpha) & (interruptionReflexion = pasdinterruption) do
        begin
        
          bas_Fenetre  := Max(aux-increment,alpha);
          haut_Fenetre := aux;
          
          aux := -ABScout(platMod,jouablMod,defense,XCourant,coulDefense,
                          MiniProf,MiniProf,0,0,coulPourMeilleurMilieu,
                         -haut_Fenetre,-bas_Fenetre,nbBlancMod,nbNoirMod,frontMod,conseilTurbulence,true);
          
          {WritelnStringAndNumDansRapport(' down  => ',aux);}
                       
        end;
  
  derniereEvalRenvoyee := aux;
  
  if (interruptionReflexion = pasdinterruption) 
    then CalculParIncrement := aux
    else CalculParIncrement := -noteMax;
  
  TesterClefHashage(copieDeClefHashage,'CalculParIncrement');
          
end;
    
function CalculNormal(nMeilleursCoups : SInt32; var suiteInteressante : boolean) : SInt32;
var aux,bas_Fenetre,haut_Fenetre,NoteMinimumAffichee,v : SInt32;
    conseilTurbulence,i : SInt32;
    copieDeClefHashage : SInt32;
begin

  Calcule_Valeurs_Tactiques(platMod,false);
  
  copieDeClefHashage := SetClefHashageGlobale(0);
  
  conseilTurbulence := -1;
  if (compteur=1)
    then
      begin
        suiteInteressante := true;
        if (MiniProf>=4)
          then aux := CalculParIncrement(MeilleureNoteProfInterativePrecedente,300,500,-20000,20000,v)
          else aux := -ABScout(platMod,jouablMod,defense,XCourant,coulDefense,
                               MiniProf,MiniProf,0,0,coulPourMeilleurMilieu,
                               -20000,20000,nbBlancMod,nbNoirMod,frontMod,conseilTurbulence,true);
            
        if (interruptionReflexion <> pasdinterruption) then 
          begin
            aux := -noteMax;
            suiteInteressante := false;
          end;
      end
    else
      begin {compteur >= 2}
        suiteInteressante := false;
        if not(varierLesCoups)
          then
            begin
              if compteur <= nMeilleursCoups
                 then
                   begin
                     bas_Fenetre  := -32000;
                     haut_Fenetre := bestAB+1;
                   end
                 else
                   begin
                     bas_Fenetre  := classAux[nMeilleursCoups].note;
                     haut_Fenetre := bestAB+1;
                   end;
            end
          else
            begin
              bas_Fenetre  := bestAB - gEntrainementOuvertures.deltaNoteAutoriseParCoup;
              haut_Fenetre := bestAB+1;
            end;
        
        NoteMinimumAffichee := noteMax;
        for i := 1 to compteur-1 do
          if (classAux[i].note < NoteMinimumAffichee) & (classAux[i].note > -30000) then
            NoteMinimumAffichee := classAux[i].note;
        
        
        if (MiniProf>=4)
          then aux := CalculParIncrement(NoteDeCeCoupIterationPrecedente(XCourant),300,500,bas_Fenetre,haut_Fenetre,v)
          else aux := -ABScout(platMod,jouablMod,defense,XCourant,coulDefense,
                               MiniProf,MiniProf,0,compteur-1,coulPourMeilleurMilieu,
                              -haut_Fenetre,-bas_Fenetre,nbBlancMod,nbNoirMod,frontMod,conseilTurbulence,true);
                      
        if (interruptionReflexion <> pasdinterruption)
          then 
            begin
              aux := -noteMax;
              suiteInteressante := false;
            end
          else
            if (aux >= haut_Fenetre) & (aux < betaAB) then
              begin
              
                ReflexData^.class[compteur].note := aux+(ReflexData^.class[1].note-bestAB);  {penalite affichee}
                ReflexData^.class[compteur].temps := TickCount()-tickChrono;
                if affichageReflexion.doitAfficher then EcritReflexion;
                
                aux := -ABScout(platMod,jouablMod,defense,XCourant,coulDefense,
                                      MiniProf,MiniProf,0,0,coulPourMeilleurMilieu,
                                      -betaAB,-aux,nbBlancMod,nbNoirMod,frontMod,conseilTurbulence,true);
                
                if interruptionReflexion <> pasdinterruption
                  then 
                    begin
                      defense := 44;
                      if aux <= haut_Fenetre+3 
                        then aux := bas_Fenetre
                        else aux := haut_Fenetre+10;
                    end
                  else 
                    if aux<=haut_Fenetre+3 then aux := bas_Fenetre;
              end;
        if not(varierLesCoups)
          then
            begin
              if aux<=bas_Fenetre 
                then 
                  begin
                    aux := NoteMinimumAffichee;
                    suiteInteressante := false;
                  end
                else
                  suiteInteressante := true;
            end
          else
            begin
              if aux<=bas_Fenetre 
                then
                  begin
                    aux := valeurDeGauche - gEntrainementOuvertures.deltaNoteAutoriseParCoup;  
                    suiteInteressante := false;
                  end
                else
                  suiteInteressante := aux>=bestAB;
            end;   
      end;  
  CalculNormal := aux;
  
  TesterClefHashage(copieDeClefHashage,'CalculNormal(UnitMilieuDePartie)');
end;   

    
function CalculParEvaluationTotale(var suiteInteressante : boolean) : SInt32;
var aux,estimationDeDepart,v : SInt32;
    conseilTurbulence : SInt32;
    copieDeClefHashage : SInt32;
begin
  suiteInteressante := true;
  Calcule_Valeurs_Tactiques(platMod,false);
  
  copieDeClefHashage := SetClefHashageGlobale(0);
  
  conseilTurbulence := -1;
   
  if (MiniProf >= 4)
    then
      begin
        estimationDeDepart := NoteDeCeCoupIterationPrecedente(XCourant);
        aux := CalculParIncrement(estimationDeDepart,300,500,-20000,20000,v);
      end
    else
      begin
			   aux := -ABScout(platMod,jouablMod,defense,XCourant,coulDefense,MiniProf,MiniProf,0,compteur-1,coulPourMeilleurMilieu,
			                    -notemax,notemax,nbBlancMod,nbNoirMod,frontMod,conseilTurbulence,true); 
			end;
			
			
  if (interruptionReflexion <> pasdinterruption) then 
    begin
      aux := -noteMax;
      suiteInteressante := false;
    end;
    
  TesterClefHashage(copieDeClefHashage,'CalculParEvaluationTotale(UnitMilieuDePartie)');
  
  CalculParEvaluationTotale := aux;
end;   


function CalculParTore() : SInt32;
var aux : SInt32;
    defenseTore : SInt32;
begin
  aux := -AB_tore(platMod,defenseTore,coulDefense,MiniProf,-betaAB,-bestAB,nbBlancMod,nbNoirMod); 
  defense := defenseTore;
  CalculParTore := aux;
end;   
    
    
begin  {MiniMax}
  if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
    then TraiteEvenements
    else TraiteNullEvent(theEvent);
   
  if (interruptionReflexion <> pasdinterruption) 
    then exit(MiniMax);
    
  
  Initialise_table_heuristique(jeuCourant);
 
  SetLargeurFenetreProbCut;
	  
	profMinimalePourTriDesCoups := 3;

  nbNiveauxRemplissageHash := 10;
  {nbNiveauxHashExacte := 15}  {est pas mal, surtout en fin de milieu de partie}
  nbNiveauxHashExacte := miniprof - 3;  {pour obtenir ProfPourHashExacte = 4, qui est optimal}
	nbNiveauxUtilisationHash := Max(nbNiveauxHashExacte,nbNiveauxRemplissageHash);

	profondeurRemplissageHash := miniprof-nbNiveauxRemplissageHash+1;
	ProfPourHashExacte := miniprof-nbNiveauxHashExacte+1;
	ProfUtilisationHash := miniprof-nbNiveauxUtilisationHash+1;
	
	{WritelnStringAndNumDansRapport('ProfPourHashExacte = ',ProfPourHashExacte);}
  {WritelnStringAndNumDansRapport('profondeurRemplissageHash = ',profondeurRemplissageHash);
	WritelnStringAndNumDansRapport('ProfUtilisationHash = ',ProfUtilisationHash);}

	Calcule_Valeurs_Tactiques(jeu,false);
	SauvegardeValeursNoir := valeurTactNoir;
	SauvegardeValeursBlanc := valeurTactBlanc;

	MemoryFillChar(meilleureSuiteGlb,sizeof(meilleureSuiteGlb^),chr(0));
	indice_du_meilleur := longClass;
	hesitation := false;
	ViderListOfMoveRecords(classAux);
	CopyListOMoveRecords(class,classAux);
	longueurDuClassement := longClass;

	bestAB := -30000;
	betaAB := +30000;



	for i := 1 to longueurDuClassement+1 do 
	  classAux[i].note := -32000;
	  
	VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {1}');

	compteur := 0;  
	sortieDeBoucle := false;
	repeat
	  if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
	  compteur := compteur+1;
	  
	  MemoryFillChar(KillerGlb,sizeof(KillerGlb^),chr(0));
	  MemoryFillChar(nbKillerGlb,sizeof(nbKillerGlb^),chr(0));
	  
	  if (compteur=1) then MeilleureSuiteDansKiller(miniprof);
	  
	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {2}');
	  
	  Xcourant := classAux[compteur].x;
	  DefCoup := classAux[compteur].theDefense;
	  
	  if KillerGlb^[miniprof,1]<>defcoup then
	  if (DefCoup>=11) & (DefCoup<=88) then
	    if not(interdit[defCoup]) then
	      if not(estUnCoin[defcoup]) then
	          begin
	            nbKillerGlb^[miniprof] := 1;
	            KillerGlb^[miniprof,1] := defcoup;
	          end;
	  
	  
	  
	  if not(RefleSurTempsJoueur) & (jeuCourant[Xcourant] = pionVide) & pionclignotant
	    then DessinePionMontreCoupLegal(xcourant);
	   
	  platMod := jeu;
	  jouablMod := empl;
	  nbBlancMod := nbBla;
	  nbNoirMod := nbNoi;
	  frontMod := front;
	  TickChrono := TickCount();
	  nbreFeuillesDeXCourant := nbreFeuillesMilieu;
	  valeurTactNoir := SauvegardeValeursNoir;
	  valeurTactBlanc := SauvegardeValeursBlanc;
	  coupLegal := ModifPlat(XCourant,couleur,platMod,jouablMod,nbBlancMod,nbNoirMod,frontMod);
	  if MiniProf<=0 then
	      begin
	        valXY := -Evaluation(platMod,Couldefense,nbBlancMod,nbNoirMod,jouablMod,frontMod,true,-30000,30000,nbEvalRecursives);
	      end
	    else 
	      begin
	       if OthelloTorique
	         then valXY := CalculParTore()
	         else
	           begin
	             if avecEvaluationTotale | (miniprof+1<=2)
	               then valXY := CalculParEvaluationTotale(suiteEstInteressante)
	               else valXY := CalculNormal(Min(nbCoupsEnTete,longueurDuClassement),suiteEstInteressante);
	           end;
	      end;
	  
	  
	  TempsDeXCourant := TickCount()-tickChrono-2*compteur;  {pour favoriser ceux en tete de liste}
	  nbreFeuillesDeXCourant := nbreFeuillesMilieu-nbreFeuillesDeXCourant;
	  if compteur=1 
	    then ValeurDeGauche := valXY
	    else hesitation := hesitation | (valXY>bestAB);
	    
	  if suiteEstInteressante & (valXY<=bestAB) then
	    begin
	      GetMeilleureSuiteInfos(oldMeilleureSuiteInfos);
	      FabriqueMeilleureSuiteInfos(Xcourant,suiteJoueeGlb^,meilleureSuiteGlb,
	                                 coulDefense,platMod,nbBlancMod,nbNoirMod,PasDeMessage);
	      if not(HumCtreHum) & (coulPourMeilleurMilieu=couleurMacintosh) then
	        if (MiniProf+1>=kProfMinimalePourSuiteDansRapport) then
	          if (not(jeuInstantane) | analyseRetrograde.enCours) then 
	            AnnonceMeilleureSuiteEtNoteDansRapport(coulPourMeilleurMilieu,valXY,miniprof+1);
	      SetMeilleureSuiteInfos(oldMeilleureSuiteInfos);
	    end;
	  
	  if (valXY>bestAB) & (interruptionReflexion = pasdinterruption) then 
	    begin
	    
	      if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
	        then TraiteEvenements
	        else TraiteNullEvent(theEvent);
	      FabriqueMeilleureSuiteInfos(Xcourant,suiteJoueeGlb^,meilleureSuiteGlb,
	                               coulDefense,platMod,nbBlancMod,nbNoirMod,PasDeMessage);
	      SetMeilleureSuite(MeilleureSuiteEtNoteEnChaine(coulPourMeilleurMilieu,valXY,miniprof+1));
	      if afficheMeilleureSuite then EcritMeilleureSuite;             
	         
	      if not(HumCtreHum) & (coulPourMeilleurMilieu=couleurMacintosh) then
	        if (MiniProf+1>=kProfMinimalePourSuiteDansRapport) then 
	          if (not(jeuInstantane) | analyseRetrograde.enCours) then 
	          begin
	            AnnonceMeilleureSuiteEtNoteDansRapport(coulPourMeilleurMilieu,valXY,miniprof+1);
	            (*
	            if InfosTechniquesDansRapport & not(demo) then
	              begin
	                DisableKeyboardScriptSwitch;
	                FinRapport;
	                TextNormalDansRapport;
	                WritelnDansRapport('  '+ReadStringFromRessource(TextesRapportID,11)+NumEnString(nbreFeuillesDeXCourant)); {'nb feuilles générées = '}
	                EnableKeyboardScriptSwitch;
	              end;
	            *)
	          end;
	     (* if avecDessinCoupEnTete & (jeuCourant[Xcourant] = pionVide) then 
	        if not(RefleSurTempsJoueur) | afficheSuggestionDeCassio then
	          begin
	            if (compteur>1) then EffaceCoupEnTete;
	            SetCoupEntete(Xcourant);
	            DessineCoupEnTete;
	          end;
	      SetCoupEntete(Xcourant); *)
	      bestAB := valXY; 
	    end;

	  
	  if valxy>classAux[1].note then indice_du_meilleur := compteur;
	  
	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {3}');
	  
	  k := 1;
	  while ((classAux[k].note>=valxy))
	         & (k<compteur) do k := k+1;
	  for j := compteur downto k+1 do classAux[j] := classAux[j-1];
	  classAux[k].x := xcourant;
	  classAux[k].note := ValXY;
	  classAux[k].theDefense := defense;
	  classAux[k].temps := TempsDeXCourant;
	  classAux[k].nbfeuilles := nbreFeuillesDeXCourant;
	  classAux[k].pourcentageCertitude := 100;
	  classAux[k].delta := kTypeMilieuDePartie;
	  
	  
	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {4}');
	  
	  (***  classement au temps si pas meilleur  ***)
	  if (compteur>=2) & (k=compteur) & (valXY=valeurDeGauche) & 
	     not(avecEvaluationTotale | (miniprof+1<=2)) then
	    begin
	      k := 1;
	      while ((classAux[k].note>valxy))
	         & (k<compteur) do k := k+1;
	      if (k<compteur) & (classAux[k].note=valxy) then k := k+1;
	      while (classAux[k].temps>=TempsDeXCourant) & (classAux[k].note=valxy) 
	         & (k<compteur) do k := k+1;
	      for j := compteur downto k+1 do classAux[j] := classAux[j-1];
	      classAux[k].x := xcourant;
	      classAux[k].note := ValXY;
	      classAux[k].theDefense := defense;
	      classAux[k].temps := TempsDeXCourant;
	      classAux[k].nbfeuilles := nbreFeuillesDeXCourant;
	      classAux[k].pourcentageCertitude := 100;
	      classAux[k].delta := kTypeMilieuDePartie;
	    end; 
	  
	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {5}');
	 
	  if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
	  if compteur+1<=longueurDuClassement then classAux[compteur+1].note := -32000;
	  
	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {6}');
	  
	  if (interruptionReflexion = pasdinterruption) then
	    begin
			  if avecEvaluationTotale
			    then 
			      begin
			        SetValReflex(classAux,MiniProf,compteur,longueurDuClassement,ReflMilieuExhaustif,nbCoupRecherche,compteur+1,coulPourMeilleurMilieu);
			        SetNbLignesScoresCompletsCetteProf(ReflexData^,1000);
			      end
			    else 
			      begin
			        SetValReflex(classAux,MiniProf,compteur,longueurDuClassement,ReflMilieu,nbCoupRecherche,compteur+1,coulPourMeilleurMilieu);
			        {on cherche combien de notes differentes il faut afficher dans la fenetre de Reflexion}
			        j := 1;
			        for aux := 2 to compteur do 
			          if classAux[aux].note <> classAux[aux-1].note then j := aux;
			        SetNbLignesScoresCompletsCetteProf(ReflexData^,Max(nbCoupsEnTete,j));
			      end;
			  if affichageReflexion.doitAfficher then EcritReflexion;
			  
			  if (CassioEstEnModeAnalyse() {| analyseRetrograde.enCours}) & EstPositionEtTraitCourant(MakePositionEtTrait(MC_jeu,MC_coul)) then
			    begin
			      aux := GetNbLignesScoresCompletsCetteProf(ReflexData^);
			      for j := 1 to Min(aux,longueurDuClassement) do
			        SetNoteMilieuSurCase(kNotesDeCassio,classAux[j].x,classAux[j].note);
			      for j := (1 + Min(aux,longueurDuClassement)) to longueurDuClassement do
			        SetNoteMilieuSurCase(kNotesDeCassio,classAux[j].x,kNoteSurCaseNonDisponible);
			      SetMeilleureNoteMilieuSurCase(kNotesDeCassio,classAux[1].x,classAux[1].note);
			    end;
            
	   end;

	if not(RefleSurTempsJoueur) & (jeuCourant[Xcourant] = pionVide) & pionclignotant then
		EffacePionMontreCoupLegal(xcourant);
	  
	        
	until sortieDeBoucle | (compteur>=longueurDuClassement) | ((interruptionReflexion <> pasdinterruption));



	if (interruptionReflexion = pasdinterruption) 
	  then
			begin
			  if avecEvaluationTotale | (miniprof+1<=2)
			    then
			      begin
			        class := classAux;
			        VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {7}');
			        VerifieAssertionsSurClassementDeMilieu(class, longClass, MC_jeu, 'Minimax class {7}');
			      end
			    else
			      begin
			        k := 1;
			        class[1] := classAux[1];
			        { on rejette a la fin les coups affiches comme "pas mieux" }
			        { 1) d'abord on prend les autres }
			        for i := 2 to longClass do
			          if (classAux[i].note<>classAux[i-1].note) | (i <= nbCoupsEnTete) then
			            begin
			              k := k+1;
			              class[k] := classAux[i];
			            end;
			        { 2) puis les pas mieux }
			        for i := 2 to longClass do
			          if not((classAux[i].note<>classAux[i-1].note) | (i <= nbCoupsEnTete)) then
			            begin
			              k := k+1;
			              class[k] := classAux[i];
			            end;

              VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {8}');
              VerifieAssertionsSurClassementDeMilieu(class, longClass, MC_jeu, 'Minimax class {8}');
			      end;
			  {CopyClassementDansTableOfMoveRecordsLists(class,MiniProf,compteur);}
			end
	  else  { si (interruptionReflexion <> pasdinterruption) }
	    begin
	     {WritelnStringAndNumDansRapport('dans Minimax (interruptionReflexion <> pasdinterruption), compteur=',compteur);
	      WritelnStringAndNumDansRapport('dans Minimax (interruptionReflexion <> pasdinterruption), longClass=',longClass);}
	    
	      if compteur <= 1 
	        then
	          begin
	            for i := 1 to longClass do 
	              class[i] := class[i]; {on ne change pas le classement}
	            
	            VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {9}');
	            VerifieAssertionsSurClassementDeMilieu(class, longClass, MC_jeu, 'Minimax class {9}');
	          end
	        else
	          begin
	            for i := 1 to longClass do 
	              class[i] := classAux[i];
	            for i := compteur to longClass do
	              class[i].note := -32000;
	            
	            VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {10}');
	            VerifieAssertionsSurClassementDeMilieu(class, longClass, MC_jeu, 'Minimax class {10}');
	          end;
	      {CopyClassementDansTableOfMoveRecordsLists(class,MiniProf,compteur-1);}
	    end;
	    
	if interruptionReflexion = pasdinterruption then
	  begin
			if avecEvaluationTotale
			  then 
			    begin
			      SetValReflex(class,MiniProf,longClass,longClass,ReflMilieuExhaustif,nbCoupRecherche,MaxInt,coulPourMeilleurMilieu);
			      SetNbLignesScoresCompletsCetteProf(ReflexData^,1000);
			    end
			  else 
			    begin
			      SetValReflex(class,MiniProf,longClass,longClass,ReflMilieu,nbCoupRecherche,MaxInt,coulPourMeilleurMilieu);
			      {on cherche combien de notes differentes il faut afficher dans la fenetre de Reflexion}
			      j := 1;
			      for k := 2 to compteur do 
			        if class[k].note <> class[k-1].note then j := k;
			      SetNbLignesScoresCompletsCetteProf(ReflexData^,Max(nbCoupsEnTete,j));
			    end;
			if affichageReflexion.doitAfficher then EcritReflexion;
		end;
	    
	    
	MeilleureNoteProfInterativePrecedente := classAux[1].note;
	
	
	with InfosDerniereReflexionMac do
    begin
      nroDuCoup  := MC_nbBl + MC_nbNo - 4 + 1;
      coup       := class[1].x;
      def        := class[1].theDefense;
      valeurCoup := class[1].note + penalitePourTraitAff;
      coul       := MC_coul;
      prof       := profondeurDemandee+1;
    end;
	
end;   {MiniMax}

function CalculeVariationAvecGraphe(classement : ListOfMoveRecords;longueurClassement : SInt32) : SInt32;
 var nbCoupsEnvisageables,i : SInt32;
     CoupsEnvisageables : ListOfMoveRecords;
     FilsDejaJoues:listeDeCellulesEtDeCoups;
     variationJamaisJoueeDansGraphe : boolean;
     nbreHit,alea : SInt32;
 begin
 
   ViderListOfMoveRecords(CoupsEnvisageables);
 
	 nbCoupsEnvisageables := 1;
	 CoupsEnvisageables[1] := classement[1];
	 for i := 2 to longueurClassement do
	   if (classement[i].note>classement[1].note - gEntrainementOuvertures.deltaNoteAutoriseParCoup) &
	      (classement[i].note<>classement[i-1].note) then
	     begin
	       nbCoupsEnvisageables := nbCoupsEnvisageables+1;
	       CoupsEnvisageables[nbCoupsEnvisageables] := classement[i];
	     end;

	 GetFilsDeLaPositionCouranteDansLeGraphe([kGainDansT,kGainAbsolu,kNulleDansT,kNulleAbsolue,kPerteDansT,kPerteAbsolue],false,FilsDejaJoues);
	 variationJamaisJoueeDansGraphe := false;
	 nbreHit := 1;
	 repeat
	   CalculeVariationAvecGraphe := nbreHit;
	   variationJamaisJoueeDansGraphe := not(CoupEstDansListeDeCellulesEtDeCoups(classement[indexDuCoupConseille].x,FilsDejaJoues,numeroCellule));
	   nbreHit := nbreHit+1;
	 until (nbreHit>nbCoupsEnvisageables) | variationJamaisJoueeDansGraphe;

   RandomizeTimer;
	 if not(variationJamaisJoueeDansGraphe) then  {tous les coups envisageables sont deja connus}
	   begin
	     alea := 1+(Abs(Random()) mod nbCoupsEnvisageables);
	     CalculeVariationAvecGraphe := alea;
	   end;
 end;

function CalculeVariationAvecMilieu(classement : ListOfMoveRecords;longueurClassement : SInt32) : SInt32;
 var nbCoupsEnvisageables,i,j : SInt32;
     CoupsEnvisageables : ListOfMoveRecords;
     alea,probaDeCeCoup,sommeDesProba : SInt32;
     exposant:real;
     found : boolean;
     coupChoisi : SInt32;
 begin
 
   ViderListOfMoveRecords(CoupsEnvisageables);
 
   {if (longueurClassement >= 2) & (classement[1].x = classement[2].x) then 
     begin
       Sysbeep(0);
       WritelnDansRapport('WARNING : deux coups identiques dans CalculeVariationAvecMilieu !');
     end;
   WritelnDansRapport('entrée dans CalculeVariationAvecMilieu');
   WritelnStringAndNumDansRapport('longueurClassement = ',longueurClassement);}
   
 
	 nbCoupsEnvisageables := 1;
	 CoupsEnvisageables[1] := classement[1];
	 
	 {WriteStringAndCoupDansRapport('coup class = ',classement[1].x);
	  WritelnStringAndNumDansRapport(' => ',classement[1].note);}
	 
	 for i := 2 to longueurClassement do
	   begin
	     {WriteStringAndCoupDansRapport('coup class = ',classement[i].x);
	     WritelnStringAndNumDansRapport(' => ',classement[i].note);}
  	   if (classement[i].note > classement[1].note - gEntrainementOuvertures.deltaNoteAutoriseParCoup) &
  	      (classement[i].note <> classement[i-1].note) then
  	     begin
  	       nbCoupsEnvisageables := nbCoupsEnvisageables + 1;
  	       CoupsEnvisageables[nbCoupsEnvisageables] := classement[i];
  	     end;
  	 end;

   exposant := 1.5;
   if classement[1].note < 0  {si on est mal, on sert le jeu un peu : on augmente exposant}
     then exposant := exposant - (0.0005*classement[1].note);
   
   sommeDesProba := 0;
   for i := 1 to nbCoupsEnvisageables do
     with CoupsEnvisageables[i] do
       begin
         {WriteStringAndCoupDansRapport('coup = ',CoupsEnvisageables[i].x);
         WriteStringAndNumDansRapport('  note = ',CoupsEnvisageables[i].note);}
         
         
         note := classement[1].note - note - 50;
         if note < 0 then note := 0;
         
         {WriteStringAndNumDansRapport('  delta = ',CoupsEnvisageables[i].note);}
         
         probaDeCeCoup := MyTrunc(1000.0*PuissanceReelle(100.0/(100.0+note),exposant));
         
         CoupsEnvisageables[i].note := probaDeCeCoup;
         
         {WritelnStringAndNumDansRapport('  proba = ',CoupsEnvisageables[i].note);}
         
         
         sommeDesProba := sommeDesProba + probaDeCeCoup;
       end;
    
   {WritelnStringAndNumDansRapport('somme des probas = ',sommeDesProba);}
   
   {on tire au hazard un nombre entre 1 et sommeDesProba}
   {et on regarde a quel coup il correspond}
   RandomizeTimer;
   alea := RandomLongintEntreBornes(1, sommeDesProba);
   
   {WritelnStringAndNumDansRapport('alea = ',alea);}
   
   
   sommeDesProba := 0;
   found := false;
   for i := 1 to nbCoupsEnvisageables do
     if not(found) then
       begin
         sommeDesProba := sommeDesProba + CoupsEnvisageables[i].note;
         if sommeDesProba >= alea then
           begin
             coupChoisi := CoupsEnvisageables[i].x;
             for j := 1 to longueurClassement do
               if classement[j].x = coupChoisi then
                 begin
                   found := true;
                   CalculeVariationAvecMilieu := j;
                   {WritelnStringAndCoupDansRapport('OK, found pour ',CoupsEnvisageables[i].x);}
                 end;
           end;
       end;
	 
	 if not(found) 
	   then
		   begin
		     WritelnDansRapport('ERREUR dans CalculeVariationAvecMilieu : not(found)');
		     SysBeep(0);
		     CalculeVariationAvecMilieu := 1;
		   end;
	 
 end;



begin          {CalculeClassementMilieuDePartie}


  {$IFC USE_PROFILER_MILIEU_DE_PARTIE}
  if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr 
    then ProfilerSetStatus(1);
  tempsGlobalDeLaFonction := TickCount();
  {$ENDC}

  oldInterruption := GetCurrentInterruption();
  EnleveCetteInterruption(oldInterruption);
  
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
  
  profSupUn := false;
  ReinitilaliseInfosAffichageReflexion;
  nbCoupRecherche := MC_nbBl+MC_nbNo-4+1;
  rechercheDejaAnnoncee := false;
  InitialiseDirectionsJouables;
  CarteJouable(MC_jeu,MC_empl);
  with InfosDerniereReflexionMac do
    begin
      nroDuCoup  := -1;
      coup       := 0;
      def        := 0;
      valeurCoup := -noteMax;
      coul       := pionVide;
      prof       := 0;
    end;
  indexDuCoupConseille := 0;
  ViderListOfMoveRecords(classement);
  lignesEcritesDansRapport := MakeEmptyStringSet();
  
  with gEntrainementOuvertures do
    begin
      varierLesCoups := CassioVarieSesCoups &
                        (MC_coul = couleurMacintosh) &
                        (nbreCoup <= varierJusquaCeNumeroDeCoup) & 
                        (GetCadence() <= varierJusquaCetteCadence) &
                        not(analyseRetrograde.enCours) &
                        not(positionFeerique);
      ViderListOfMoveRecords(classementVariations);
      derniereProfCompleteMilieuDePartie := 0;
    end;
  
  discretisationEvaluationEstOK := not(analyseRetrograde.enCours) & not(varierLesCoups);
  
  LanceDecompteDesNoeuds;
  compteurNoeuds := 0;
  nbreToursFeuillesMilieu := 0;
  nbreFeuillesMilieu := 0;
  SommeNbEvaluationsRecursives := 0;
  nbreToursNoeudsGeneresMilieu := 0;
  nbreNoeudsGeneresMilieu := 0;
  lastNbreNoeudsGeneres := 0;
  nbreToursNoeudsGeneresFinale := 0;
  nbreNoeudsGeneresFinale := 0;
  MemoryFillChar(@NbreDeNoeudsMoyensFinale,sizeof(NbreDeNoeudsMoyensFinale),chr(0));
  tickNoeuds := TickCount();
  MemoryFillChar(KillerGlb,sizeof(KillerGlb^),chr(0));
  MemoryFillChar(nbKillerGlb,sizeof(nbKillerGlb^),chr(0));
  MemoryFillChar(suiteJoueeGlb,sizeof(suiteJoueeGlb^),chr(0));
  MemoryFillChar(meilleureSuiteGlb,sizeof(meilleureSuiteGlb^),chr(0));
  MemoryFillChar(@StatistiquesSurLesCoups,sizeof(StatistiquesSurLesCoups),chr(0));
  VideHashTable(HashTable);
  if EstPositionEtTraitCourant(MakePositionEtTrait(MC_jeu,MC_coul)) then 
    ViderNotesSurCases(kNotesDeCassio,true,othellierToutEntier);
  InitialiseConstantesCodagePosition;
  InvalidateAllProfsDansDansTableOfMoveRecordsLists;
  
  {version de VideToutesLesHashTablesExactes ou on verifie les interruptions}
  for i := 0 to nbTablesHashExactes-1 do
    if (interruptionReflexion = pasdinterruption) then
	   begin
	     if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
	     
	     VideHashTableExacte(HashTableExacte[i]);
	       
	     if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
	     
	     VideHashTableCoupsLegaux(CoupsLegauxHash[i]);
	   end;
	nbCollisionsHashTableExactes := 0;
	nbNouvellesEntreesHashTableExactes := 0;
	nbPositionsRetrouveesHashTableExactes := 0;
  
    
  MFniv := MC_prof-1;
  coulPourMeilleurMilieu := MC_coul;
  coulDefense := -coulPourMeilleurMilieu; 
  MemoryFillChar(@casesVidesMilieu,sizeof(casesVidesMilieu),chr(0));
  nbCasesVidesMilieu := 0;
   
  if RefleSurTempsJoueur
    then tempsAlloue := TempsPourCeCoup(nbreCoup,couleurMacintosh)
    else tempsAlloue := TempsPourCeCoup(nbreCoup,coulPourMeilleurMilieu);
  tempsAlloueAuDebutDeLaReflexion := tempsAlloue;
  LanceChrono;
  LanceChronoCetteProf;
   
  
   
  for i := 1 to 64 do
    begin
      iCourant := othellier[i];
      if MC_jeu[iCourant] = pionVide then
        begin
          nbCasesVidesMilieu := nbCasesVidesMilieu+1;
          casesVidesMilieu[nbCasesVidesMilieu] := iCourant;
        end;
    end;
  if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
   
  
  if (interruptionReflexion = pasdinterruption) then
    begin
		  if OthelloTorique 
		    then CarteMoveTore(coulPourMeilleurMilieu,MC_jeu,moves,mob)
		    else CarteMove(coulPourMeilleurMilieu,MC_jeu,moves,mob);
		    
		  for i := 1 to nbCasesVidesMilieu do
		    if moves[casesVidesMilieu[i]] & (casesVidesMilieu[i] in casesExclues) then
		      begin
		        dec(mob);
		        moves[casesVidesMilieu[i]] := false;
		      end;
		     
		     
		  if (mob>1) | calculerMemeSiUnSeulCoupLegal | ((analyseRetrograde.enCours) & ((MC_nbBl+MC_nbNo) >= 44))
		    then
		     begin
		       nbCoup := 0;
		       for i := 1 to nbCasesVidesMilieu do
		         if moves[casesVidesMilieu[i]] & not(casesVidesMilieu[i] in casesExclues) then
		           begin 
		             nbCoup := nbCoup+1;
		             classement[nbCoup].x := casesVidesMilieu[i];
		             classement[nbCoup].theDefense := 44;
		             classement[nbCoup].note := -noteMax;
		           end;
		       MC_frontiere.occupationTactique := 0;
		       
		       
				   if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
				     then TraiteEvenements
				     else TraiteNullEvent(theEvent);
		                
		       if (interruptionReflexion = pasdinterruption) then
		         begin
		           
		           if avecSelectivite
		             then SelectivitePourCetteRecherche := -2
		             else SelectivitePourCetteRecherche := -2;
		              
		              
		           diffprecedent := 50;
		           tempseffectif := 50;
		           tempsPrevu := 0;
		           profondeurDemandee := -1;
		              
				       REPEAT 
						     tempoPhase := phaseDeLaPartie;
						     phaseDeLaPartie := phaseMilieu;
						     if (profondeurDemandee = 1) | (ProfondeurMilieuEstImposee() & (profondeurDemandee = MFniv-1))
						       then profondeurDemandee := profondeurDemandee + 1
						       else profondeurDemandee := profondeurDemandee + valeurApprondissementIteratif;
						     if (profondeurDemandee < 1) then profondeurDemandee := 1;
						     
						     (*
						     WritelnStringAndBoolDansRapport('ProfondeurMilieuEstImposee() = ', ProfondeurMilieuEstImposee());
						     WritelnStringAndNumDansRapport('profondeurDemandee = ', profondeurDemandee);
						     WritelnStringAndBoolDansRapport('not(odd(profondeurDemandee)) = ', not(odd(profondeurDemandee)));
						     WritelnStringAndNumDansRapport('coulPourMeilleurMilieu = ', coulPourMeilleurMilieu);
						     WritelnStringAndNumDansRapport('PionNoir = ', PionNoir);
						     WritelnStringAndNumDansRapport('PionBlanc = ', PionBlanc);
						     *)
						     
						     {on fait les profondeurs paires}
								 if not(ProfondeurMilieuEstImposee()) & not(odd(profondeurDemandee)) then
									 inc(profondeurDemandee);
									 
						     (*
						     WritelnStringAndNumDansRapport('profondeurDemandee = ', profondeurDemandee);
						     WritelnDansRapport('');
						     *)
						     
						     
						     SetNbLignesScoresCompletsProfPrecedente(ReflexData^,GetNbLignesScoresCompletsCetteProf(ReflexData^));
						     
						     Superviseur(nbreCoup+profondeurDemandee);
						       
						     LanceChronoCetteProf;
						     nbFeuillesCetteProf := nbreFeuillesMilieu;
						     
						     MiniMax(coulPourMeilleurMilieu,profondeurDemandee,nbCoup,MC_nbBl,MC_nbNo,MC_jeu,MC_empl,
						             classement,MC_frontiere,hesitationSurLeBonCoup);
						     
						     nbFeuillesCetteProf := nbreFeuillesMilieu-nbFeuillesCetteProf;
						     CollecteStatistiques(profondeurDemandee,classement,nbFeuillesCetteProf,tempsReflexionCetteProf div 60);
						     
						     
						     if interruptionReflexion <> pasdinterruption 
						       then
						         begin
						           sortieBoucleProfIterative := true;
						         end
						       else
							       begin
							     
									     profSupUn := (interruptionReflexion = pasdinterruption) & 
									                  (profondeurDemandee > 0);
									             
									     phaseDeLaPartie := tempoPhase;
									     diffprecedent := tempseffectif;
									     tempseffectif := tempsReflexionCetteProf;
									     diffDeTemps := tempseffectif;
									     if diffprecedent<120 then diffprecedent := 120;
									     if phaseDeLaPartie <= phaseDebut 
									        then rapidite := -0.8   { plus c'est negatif, plus on peut reflechir }
									        else 
									          begin
									            rapidite := -1.0;
									            if hesitationSurLeBonCoup then rapidite := -2.5;
									          end;
									     coeffMultiplicateur := rapidite+diffDeTemps*1.0/diffprecedent;
									     if coeffMultiplicateur<1.6 then coeffMultiplicateur := 1.6;
									     if coeffMultiplicateur>10.0 then coeffMultiplicateur := 10.0;
									     tempsPrevu := MyTrunc(tempseffectif*coeffMultiplicateur);
									     if tempsPrevu < 200 then tempsPrevu := 200;
									     if tempsPrevu < tempseffectif then tempsPrevu := tempseffectif;
									     
									     if (interruptionReflexion = pasdinterruption) & not(CassioEstEnModeAnalyse()) then
									       begin
									         vraimentTresFacile := false;
									         {if CoupFacile(classement,nbCoup,vraimentTresFacile) & (tempsAlloue<>minutes10000000) then 
									           if vraimentTresFacile
									             then tempsPrevu := tempsPrevu*500
									             else tempsPrevu := tempsPrevu*4;}
									         if hesitationSurLeBonCoup & (profondeurDemandee>=6) & (classement[1].note <= 10) &
									            (tempsAlloue <> minutes10000000) & not(analyseRetrograde.EnCours)
									           then tempsAlloue := Min(MyTrunc(1.35*tempsAlloue),MyTrunc(4.0*tempsAlloueAuDebutDeLaReflexion));
									       end;
									     
									     LanceChronoCetteProf;
									     
									     if (interruptionReflexion = pasdinterruption) then 
									       begin
									         profReelle := profondeurDemandee+1;
									         if nbFeuillesCetteProf>0 
									           then divergence := exp(ln(nbFeuillesCetteProf)/(profReelle))
									           else divergence := 0.0;
									         if ProfondeurMilieuEstImposee() 
									           then profsuivante := Min(profReelle+2,MFniv)
									           else profsuivante := profReelle+2;
									         SetValeursGestionTemps(tempsAlloue,tempseffectif,tempsPrevu,
									                                divergence,profReelle,profsuivante);
									       
									       end;
									     if afficheGestionTemps & (interruptionReflexion = pasdinterruption) 
									       then EcritGestionTemps;
									     
									     if (interruptionReflexion = pasdinterruption) & varierLesCoups then
									       with gEntrainementOuvertures do
									       begin
									         derniereProfCompleteMilieuDePartie := profondeurDemandee+1;
									         CopyListOMoveRecords(classement,classementVariations);
									       end;
									     
									     doitSeDepecher := (profondeurDemandee >= 2) & not(analyseRetrograde.EnCours) &
									                       (( 0.333*((tempsReflexionMac+tempsPrevu) div 60) > tempsAlloue) |
									                       (varierLesCoups & not(RefleSurTempsJoueur) & (profondeurDemandee+1 >= gEntrainementOuvertures.profondeurRechercheVariations))); 
									     if (tempsAlloue >= kUnMoisDeTemps) | (tempsAlloueAuDebutDeLaReflexion >= kUnMoisDeTemps) then
									       doitSeDepecher := false; 
									     
									     if ProfondeurMilieuEstImposee() 
									       then sortieBoucleProfIterative := (profondeurDemandee >= MFniv) 
									       else sortieBoucleProfIterative := (doitSeDepecher & not(RefleSurTempsJoueur & (aQuiDeJouer<>couleurMacintosh)));
									     
									     sortieBoucleProfIterative := sortieBoucleProfIterative | 
									                                  (profondeurDemandee >= kNbMaxNiveaux - 3) | 
									                                  (profondeurDemandee >= nbCasesVidesMilieu + PlusGrandeProfondeurAvecProbCut()) |
									                                  (interruptionReflexion <> pasdinterruption);
									     
									  end;
									  
						       
						   UNTIL sortieBoucleProfIterative | (interruptionReflexion <> pasdinterruption);
		    
						   if not(varierLesCoups) 
						     then
						       begin     { on renvoie le premier du classement }
						         indexDuCoupConseille := 1;
						       end
						     else
						       begin
						         with gEntrainementOuvertures do
							         case modeVariation of
							           kVarierEnUtilisantMilieu : 
							             begin
							               if derniereProfCompleteMilieuDePartie >= profondeurRechercheVariations
							                 then indexDuCoupConseille := CalculeVariationAvecMilieu(classementVariations,nbCoup)
							                 else indexDuCoupConseille := CalculeVariationAvecMilieu(classement,nbCoup);
							             end;
							           kVarierEnUtilisantGraphe : 
							             begin
							               indexDuCoupConseille := CalculeVariationAvecGraphe(classement,nbCoup);
							             end;
							         end; {case}
						       end;
		           
		           {
						   if (interruptionReflexion = pasdinterruption) | doitSeDepecher then
						     if not(HumCtreHum) & (coulPourMeilleurMilieu=couleurMacintosh) then
						       if (profondeurDemandee+1)>kProfMinimalePourSuiteDansRapport then
						         if not(jeuInstantane) | analyseRetrograde.enCours then 
						         AnnonceMeilleureSuiteEtNoteDansRapport(coulPourMeilleurMilieu,classement[1].note,profondeurDemandee+1);     
		           }
		           
		         end
		     end
		   else 
		     begin            
		       if (mob <= 0)  {si on passe, quelque chose d'anormal s'est passe : on renvoie un coup fictif}
		         then
		           begin
		             indexDuCoupConseille := 0;
		             with InfosDerniereReflexionMac do
		               begin
		                 nroDuCoup  := -1;
		                 coup       := 0;
		                 def        := 0;
		                 valeurCoup := -noteMax;
		                 coul       := pionVide;
		                 prof       := 0;
		               end;
		           end
		         else
		           begin  { sinon on cherche l'unique coup }
		             indexDuCoupConseille := 0;
					       for i := 1 to 64 do
					         if moves[othellier[i]] then
							       begin
							         indexDuCoupConseille := 1;
							         classement[1].x   := othellier[i];
							         classement[1].note := -10000;
							         classement[1].theDefense := 44;
							       end;
							   if indexDuCoupConseille=0 then {non trouvé}
			             with InfosDerniereReflexionMac do
			               begin
			                 nroDuCoup  := -1;
			                 coup       := 0;
		                   def        := 0;
		                   valeurCoup := -noteMax;
		                   coul       := pionVide;
		                   prof       := 0;
			               end;
							 end;
				 end;
				 
	  end;
   		         
  ReinitilaliseInfosAffichageReflexion;
 (* if avecDessinCoupEnTete then EffaceCoupEnTete; *)
  if affichageReflexion.doitAfficher then EffaceReflexion; 
  
  
  if (indexDuCoupConseille < 1) | (indexDuCoupConseille > 64)
    then
      begin
        if (interruptionReflexion = pasdinterruption) then
          AlerteSimple('Erreur :  indexDuCoupConseille='+NumEnString(indexDuCoupConseille)+' dans CalculeClassementMilieuDePartie !!')
      end
    else
      begin
			  with InfosDerniereReflexionMac do
			    begin
			      nroDuCoup  := MC_nbBl + MC_nbNo - 4 + 1;
			      coup       := classement[indexDuCoupConseille].x;
			      def        := classement[indexDuCoupConseille].theDefense;
			      valeurCoup := classement[indexDuCoupConseille].note + penalitePourTraitAff;
			      coul       := MC_coul;
			      prof       := profondeurDemandee+1;
			    end;
			end;
			 
  if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
    then TraiteEvenements
    else TraiteNullEvent(theEvent);
    
    
  
  
    
  LanceInterruption(oldInterruption,'CalculeClassementMilieuDePartie');
  discretisationEvaluationEstOK := false;
  DisposeStringSet(lignesEcritesDansRapport);
  
  
  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
  AfficheMiniProfilerDansRapport(ktempsmoyen);
  {$ENDC}
  
  {$IFC USE_PROFILER_MILIEU_DE_PARTIE}
   nomFichierProfile := PrefixeFichierProfiler() + NumEnString((TickCount() - tempsGlobalDeLaFonction) div 60) + '.midgame';
   WritelnDansRapport('nomFichierProfile = '+nomFichierProfile);
   if ProfilerDump(nomFichierProfile) <> NoErr 
     then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfile+') a échoué !')
     else ProfilerSetStatus(0);
   ProfilerTerm;
  {$ENDC}
  
end;         {CalculeClassementMilieuDePartie}


function CalculeMeilleurCoupMilieuDePartie(var jeu : plateauOthello; var emplBool : plBool; var frontiere : InfoFrontRec;
                                            couleur,profondeur,nbBlancs,nbNoirs : SInt32) : MoveRecord;
var result : MoveRecord;
    casesExclues : SquareSet;
    liste : ListOfMoveRecords;
    numCoupConseille : SInt32;
    tempoProfImposee : boolean;
    tempoCassioEnTrainDeReflechir : boolean;
begin
  SetCassioEstEnTrainDeReflechir(true,@tempoCassioEnTrainDeReflechir);
  
	tempoProfImposee := ProfondeurMilieuEstImposee();
	
	
  with gEntrainementOuvertures do
	  if CassioVarieSesCoups & 
	     not(analyseRetrograde.enCours) &
	     (couleur=couleurMacintosh) &
	     ((nbBlancs+nbNoirs-4) <= varierJusquaCeNumeroDeCoup) &
	     not(RefleSurTempsJoueur) &
	     not(positionFeerique) & 
	     (GetCadence() <= varierJusquaCetteCadence) 
	     then
	       begin
	         SetProfImposee(true,'CalculeMeilleurCoupMilieuDePartie car CassioVarieSesCoups');
	         profondeur := profondeurRechercheVariations;
	       end;
  
  ViderMoveRecord(result);
  
  casesExclues := [];
  CalculeClassementMilieuDePartie(liste,numCoupConseille,couleur,profondeur,nbBlancs,nbNoirs,jeu,emplBool,frontiere,analyseRetrograde.enCours,casesExclues);
  
  {
  WritelnStringAndNumDansRapport('dans CalculeMeilleurCoupMilieuDePartie, numCoupConseille=',numCoupConseille);
  WritelnDansRapport('');
  }
  
  if (numCoupConseille >= 1) & (numCoupConseille <= 64) 
    then
      begin        
        result.x := liste[numCoupConseille].x;
        result.note := liste[numCoupConseille].note;
        result.theDefense := liste[numCoupConseille].theDefense;
			end
	  else
	    begin
	      with result do
	        begin
	          note := -noteMax;
	          LanceInterruption(interruptionSimple,'CalculeMeilleurCoupMilieuDePartie');
	          TraiteInterruptionBrutale(x,theDefense,'CalculeMeilleurCoupMilieuDePartie');
	        end;
	    end;
	
	SetProfImposee(tempoProfImposee,'fin de CalculeMeilleurCoupMilieuDePartie');
	SetCassioEstEnTrainDeReflechir(tempoCassioEnTrainDeReflechir,NIL);
	if analyseRetrograde.enCours
	  then SetGenreDerniereReflexionDeCassio(ReflRetrogradeMilieu,(nbBlancs + nbNoirs) - 4 +1)
	  else SetGenreDerniereReflexionDeCassio(ReflMilieu,(nbBlancs + nbNoirs) - 4 +1);
	
	CalculeMeilleurCoupMilieuDePartie := result;
end;



procedure SetProfImposee(flag : boolean; const fonctionAppelante : str255);
begin  {$UNUSED fonctionAppelante}
  
  {
  if flag
    then WritelnDansRapport('je met profImposee := true dans SetProfImposee, fonctionAppelante = '+fonctionAppelante)
    else WritelnDansRapport('je met profImposee := false dans SetProfImposee, fonctionAppelante = '+fonctionAppelante);
  }
  
  profimposee := flag;
end;

function ProfondeurMilieuEstImposee() : boolean;
begin
  ProfondeurMilieuEstImposee := profimposee;
end;



END.