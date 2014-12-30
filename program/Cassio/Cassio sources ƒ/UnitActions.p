UNIT UnitActions;

INTERFACE







(*
{$DEFINEC USE_PROFILER_OUVERTURE_FICHIERS (OPTION(PROF))}
*)
{$DEFINEC USE_PROFILER_OUVERTURE_FICHIERS FALSE}



USES 
{$IFC USE_PROFILER_OUVERTURE_FICHIERS}
     Profiler
{$ENDC}
     MacTypes,MyTypes;



procedure InitUnitActions;
procedure LibereMemoireUnitActions;
                                     
function ComprendPositionEtPartieDuFichier(nomFichier : str255;positionEtpartie : str255;mergeWithCurrentTree : boolean) : OSErr;
function OuvrirFichierPartieFormatCassio(nomFichier : str255;mergeWithCurrentTree : boolean) : OSErr;
function OuvrirFichierPartieFormatGGF(nomFichier : str255;mergeWithCurrentTree : boolean) : OSErr;
function OuvrirFichierPartieFormatSmartGameBoard(nomCompletFichier : str255;mergeWithCurrentTree : boolean) : OSErr;
function OuvrirFichierPartieFSp(fichier : FSSpec;mergeWithCurrentTree : boolean) : OSErr; 
procedure DoOuvrir;
procedure DoEnregistrerSousFormatCassio(modifiers : SInt16);
procedure DoEnregistrerSousFormatSmartGameBoard;
procedure DoEnregistrerSous(useSmartGameBoardFormat : boolean);
procedure DoOuvrirBibliotheque;
procedure DoEcritureSolutionSolitaire;
procedure PrepareNouvellePartie(ForceHumCtreHum : boolean);
procedure DoChangeAlerteInterversion;
{procedure DoChangeEvaluationAleatoire;}
procedure DoChangeEvaluationTablesDeCoins;
procedure DoChangeEvaluationDeFisher;
procedure DoChangeRefutationsDansRapport;
{procedure DoChangePionClignotant;}
{procedure DoChangeTorique;}
procedure DoNouvellePartie(ForceHumCtreHum : boolean);
procedure DoClose(whichWindow : WindowPtr;avecAnimationZoom : boolean);
procedure DoAjouteTemps(aQui : SInt16);
procedure DoSon;
procedure DoAvanceMove;   
procedure DoDoubleAvanceMove;
procedure DoDemandeChangeCouleur;
procedure DoDemandeJouerSolitaires;
procedure DoDemandeChangerHumCtreHum;
procedure DoDemandeChangerHumCtreHumEtCouleur;
procedure DoBackMove;  
procedure DoDoubleBackMove;
procedure DoBackMovePartieSelectionnee(nroHilite : SInt32);
procedure DoDoubleBackMovePartieSelectionnee(nroHilite : SInt32);
procedure DoDoubleAvanceMovePartieSelectionnee(nroHilite : SInt32);
procedure DoRetourAuCoupNro(numeroCoup : SInt32;NeDessinerQueLesNouveauxPions,ForceHumCtreHum : boolean);
procedure DoAvanceAuCoupNro(numeroCoup : SInt16; NeDessinerQueLesNouveauxPions : boolean); 
procedure DoRetourDerniereMarque;
procedure DoAvanceProchaineMarque;
procedure DoRetourDernierEmbranchement;
procedure DoAvanceProchainEmbranchement;
procedure DetruitSousArbreCourantEtBackMove;
procedure DoDialogueDetruitSousArbreCourant;
procedure DoTraiteBaseDeDonnee;
procedure DoChargerLaBase;
procedure DoDemandeAnalyseRetrograde(sansDialogueRetrograde : boolean);
procedure DoParametrerAnalyseRetrograde;
procedure ToggleAideDebutant;
procedure DoChangeAfficheDernierCoup;
procedure DoChangeAfficheReflexion;
procedure DoChangeAfficheBibliotheque;
procedure DoChangeAfficheGestionTemps;    
procedure DoChangeAfficheSuggestionDeCassio;
procedure DoChangeAfficheMeilleureSuite;
procedure DoChangeAffichePierresDelta;
procedure DoChangeAfficheProchainsCoups;
procedure DoChangeAfficheSignesDiacritiques;
procedure DoChangeAfficheNotesSurCases(origine : SInt32);
procedure DoChangeEn3D(avecAlerte : boolean);
procedure DoRevenir;
procedure DoDebut(ForceHumCtreHum : boolean);
procedure DoCoefficientsEvaluation;
procedure DoMakeMainBranch;
procedure DoCourbe;
procedure DoRapport;
{procedure DoChangeSensLargeSolitaire;}
procedure DoChangeReferencesCompletes;
{procedure DoChangeFinaleEnSolitaire;}
procedure DoChangePalette;
procedure DoStatistiques;
procedure DoListeDeParties;
procedure DoChangeDessineAide;
procedure DoChangeAfficheInfosApprentissage;
procedure DoChangeUtiliseGrapheApprentissage;
procedure DoChangeLaDemoApprend;
procedure DoChangeEffetSpecial1;
procedure DoChangeEffetSpecial2;
procedure DoChangeEffetSpecial3;
{procedure DoChangeEffetSpecial4;
procedure DoChangeEffetSpecial5;
procedure DoChangeEffetSpecial6;
procedure DoChangeSelectivite;}
procedure DoChangeNomOuverture;
{procedure DoChangeEcran512;
procedure DoChangeToujoursIndexer;}
procedure DoChangeAvecSystemeCoordonnees;
procedure DoChangeGarderPartieNoireADroiteOthellier;
procedure DoChangeAvecReflexionTempsAdverse;
procedure DoChangeAvecBibl;
procedure DoChangeVarierOuvertures;
procedure DoChangeJoueBonsCoupsBibl;
procedure DoChangeEnModeIOS;
procedure DoChangeSousEmulatorSousPC;
procedure DoChangeInfosTechniques;
procedure DoChangeEcrireDansRapportLog;
procedure DoChangeUtilisationNouvelleEval;
procedure DoChangeEnTraitementDeTexte;
procedure DoChangePostscriptCompatibleXPress;
procedure DoChangeArrondirEvaluations;
procedure DoChangeFaireConfianceScoresArbre;
(*procedure DoChangeAfficheCoupTete;*)
procedure DoChangeInterversions;
procedure DoChoisitDemo;
{procedure DoChangeAnalyse;}
procedure DoChangeProfImposee;
procedure DoSetUp;
procedure FermeToutEtQuitte;
procedure FermeToutesLesFenetresAuxiliaires;
procedure DoCloseCmd(modifiers : SInt16);
procedure DoQuit; {utilisee dans UnitAppleEventsCassio.p}
procedure DoMaster;
procedure DoSymetrie(axe : SInt32);
procedure OuvrePartieSelectionnee(nroHilite : SInt32);
procedure DoProgrammation;
procedure DoPommeMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoFileMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoEditionMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoCopierSpecialMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoNMeilleursCoupsMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoPartieMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoModeMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoJoueursMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoAffichageMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoSolitairesMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoBaseMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoProgrammationMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoCouleurMenuCommands(menuID,cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoPicture2DMenuCommands(menuID,cmdNumber : SInt16; var peutRepeter : boolean;avecAlerte : boolean);
procedure DoPicture3DMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean;avecAlerte : boolean);
procedure DoTriMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoFormatBaseMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoReouvrirMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoGestionBaseWThorMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoMenuCommand(command : SInt32; var peutRepeter : boolean);
procedure DoKeyPress(ch : char; var peutRepeter : boolean);
function ToucheCommandeInterceptee(ch : char;evt : eventRecord; var peutRepeter : boolean) : boolean;
procedure TraiteSourisStandard(mouseLoc : Point;modifiers : SInt16);
procedure TraiteSourisRetour(mouseLoc : Point;modifiers : SInt16);
procedure TraiteSourisFntrPlateau(evt : eventRecord);
procedure TraiteSourisPalette(evt : eventRecord);
procedure TraiteSourisAide(evt : eventRecord);
procedure TraiteSourisStatistiques(evt : eventRecord);
procedure TraiteSourisCommentaires(evt : eventRecord;fenetreActiveeParCeClic : boolean);
{procedure TraiteSourisGestion(evt : eventRecord);}
procedure TraiteSourisRapport(evt : eventRecord);

(*********************** displayHandlers ***************************)

procedure DrawContents(whichWindow : WindowPtr);
procedure DoUpdateWindow(whichWindow : WindowPtr);
procedure EssaieUpdateEventsWindowPlateau;  

(*********************** Key down and up utilities *****************)

procedure StoreKeyDownEvent(var whichEvent : eventRecord);
procedure SetRepetitionDeToucheEnCours(flag : boolean);
function RepetitionDeToucheEnCours() : boolean;
function DateOfLastKeyDownEvent() : SInt32;
function DateOfLastKeyboardOperation() : SInt32;
function NoDelayAfterKeyboardOperation() : boolean;
procedure RemoveDelayAfterKeyboardOperation;

(*********************** event handlers ****************************)

procedure KeyUpEvents;
procedure KeyDownEvents;
procedure MouseDownEvents;
procedure MouseUpEvents;
procedure UpdateEvents;
procedure MultiFinderEvents;
procedure ActivateEvents;
procedure DiskEvents;
procedure DoAppleEvents;
procedure TraiteNullEvent(var whichEvent : eventRecord); 
procedure TraiteOneEvenement; 
procedure TraiteEvenements;  
function HasGotEvent(myEventMask:EventMask; var whichEvent : eventRecord;sleep : UInt32;mouseRgn : RgnHandle) : boolean; 
procedure HandleEvent(var whichEvent : eventRecord);


IMPLEMENTATION







USES UnitNotesSurCases,UnitSelectionRapideListe,UnitServicesRapport,UnitRapportImplementation,UnitCarbonisation,UnitTraceLog,
     UnitClassement,UnitAccesStructuresNouvFormat,UnitUtilitaires,UnitFenetres,UnitNouvelleEval,UnitBibl,
     UnitCalculCouleurCassio,UnitAfficheArbreDeJeuCourant,UnitAffichageReflexion,UnitMilieuDePartie,UnitOth1,
     UnitArbreDeJeuCourant,UnitMoveRecords,UnitPierresDelta,UnitServicesDialogs,UnitOth1,UnitDemo,UnitEntreeTranscript,
     UnitStrategie,UnitSetUp,MyFileSystemUtils,UnitJeu,UnitPhasesPartie,UnitFinaleFast,UnitBaseNouveauFormat,UnitInitValeursBlocs,
     UnitBords,UnitVieilOthelliste,UnitPrefs,UnitCriteres,UnitInterversions,UnitSetUp,UnitRetrograde,
     UnitSolitaire,UnitRechercheSolit,UnitPrint,UnitIconisation,UnitTestNouveauFormat,UnitTriListe,
     UnitEntreesSortiesListe,UnitRegressionLineaire,UnitGameTree,UnitDebuggage,UnitSmartGameBoard,
     UnitFichierPhotos,UnitJaponais,UnitScripts,UnitTestNouvelleEval,UnitRapport,MyStrings,UnitMiniProfiler,
     UnitEntreesSortiesGraphe,UnitApprentissagePartie,UnitApprentissageInterversion,UnitScannerOthellistique,
     UnitPotentiels,UnitBitboardAlphaBeta,UnitSauvegardeRapport,UnitSolitairesNouveauFormat,UnitCouleur,
     UnitRechSolitNouveauFormat,UnitMoulinette,UnitTHOR_PAR,Unit3DPovRayPicts,UnitFichiersPICT,
     UnitCassioSounds,UnitTroisiemeDimension,UnitBufferedPICT,UnitMacExtras,UnitGenericGameFormat,
     UnitSaisiePartie,UnitGestionDuTemps,UnitBitboardMobilite,UnitPressePapier,UnitFormatsFichiers,
     UnitSymetrieDuRapport,Zebra_to_Cassio,UnitMenus,UnitStatistiques,UnitBaseOfficielle,UnitSuperviseur,
     UnitStrategie,UnitTore,UnitDialog,SNStrings,UnitLiveUndo,UnitProblemeDePriseDeCoin,UnitCourbe,
     UnitLongintScrollerPourListe,UnitNormalisation,UnitPackedThorGame;



var lastSleepUsed : SInt32;
    gKeyDownEventsData : record
                           lastEvent : eventRecord;
                           theKeys:myKeyMap;
                           keyCode : SInt16; 
                           theChar : char;
                           tickcountMinimalPourNouvelleRepetitionDeTouche : SInt32;
                           tickFrappeTouche : SInt32;
                           tickChangementClavier : SInt32;
                           delaiAvantDebutRepetition : SInt32;
                           niveauxDeRecursionDansDoKeyPress : SInt32;
                           repetitionEnCours : boolean;
                           noDelay : boolean;
                         end;

procedure InitUnitActions;
begin
  lastSleepUsed := -5273; {ou n'importe quelle valeur aberrante}
  
  with gKeyDownEventsData do
    begin
      niveauxDeRecursionDansDoKeyPress               := 0;
      repetitionEnCours                              := false;
      noDelay                                        := false;
      delaiAvantDebutRepetition                      := 15;
      tickFrappeTouche                               := 0;
      tickChangementClavier                          := 0;
      theChar                                        := chr(0);
      keyCode                                        := 0;
      tickcountMinimalPourNouvelleRepetitionDeTouche := 0;
    end;
end;
      

procedure LibereMemoireUnitActions;
begin
end;


function ComprendPositionEtPartieDuFichier(nomFichier : str255;positionEtpartie : str255;mergeWithCurrentTree : boolean) : OSErr;
var platAux : plateauOthello;
    i,j,x,t,compt,mobilite,nombreCoupsRepris : SInt32;
    s : str255;
    c : char;
    oldPort : grafPtr;
    temposon,tempobibl : boolean;
    tempoAfficheNumeroCoup : boolean;
    tempoCalculsActives : boolean;
    tempoAfficheInfosApprentissage : boolean;
    err : OSErr;
    legal : boolean;
    oldPositionFeerique : boolean;
    doitDetruireAncienArbreDeJeu : boolean;
    tempoAvecDelaiDeRetournementDesPions : boolean;
begin
  err := 0;
  
  if Length(positionEtpartie) < 64 then
    begin
      AlerteFormatNonReconnuFichierPartie(nomFichier);
      ComprendPositionEtPartieDuFichier := -1;  {on rapporte l'erreur}
      exit(ComprendPositionEtPartieDuFichier);
    end;
    
  temposon := avecSon;
  tempoBibl := afficheBibl;
  tempoCalculsActives := avecCalculPartiesActives;
  tempoAfficheNumeroCoup := afficheNumeroCoup;
  tempoAfficheInfosApprentissage := afficheInfosApprentissage;
  tempoAvecDelaiDeRetournementDesPions := avecDelaiDeRetournementDesPions;
  
  ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),othellierToutEntier);
  EffaceProprietesOfCurrentNode;
  SetEffacageProprietesOfCurrentNode(kAucunePropriete);
  SetAffichageProprietesOfCurrentNode(kAucunePropriete);
  
  avecSon := false;
  afficheBibl := false;
  avecCalculPartiesActives := false;
  afficheNumeroCoup := false;
  afficheInfosApprentissage := false;
  avecDelaiDeRetournementDesPions := false;
  
  EffacerTouteLaCourbe('ComprendPositionEtPartieDuFichier');
  DessineSliderFenetreCourbe;
  if not(windowPlateauOpen) then OuvreFntrPlateau(false);
  MemoryFillChar(@platAux,sizeof(plataux),chr(0));
  s := TPCopy(positionEtpartie,1,64);
  Delete(positionEtpartie,1,64);
  compt := 0;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        compt := compt+1;
        x := 10*i+j;
        c := s[compt];
        if (c='o') | (c='O') | (c='0') then plataux[x] := pionBlanc;
        if (c='x') | (c='X') | (c='#') | (c='*') then plataux[x] := pionNoir;
      end;
  
     
     ViderValeursDeLaCourbe;
     
     jeuCourant := platAux;
     for i := 0 to 99 do
         if interdit[i] then jeuCourant[i] := PionInterdit;
     nbreDePions[pionNoir] := 0;
     nbreDePions[pionBlanc] := 0;
     for i := 1 to 64 do
       begin
         t := othellier[i];
         if jeuCourant[t] <> pionVide then
           nbreDePions[jeuCourant[t]] := nbreDePions[jeuCourant[t]]+1;
       end;
     nbreCoup := nbreDePions[pionNoir]+nbreDePions[pionBlanc]-4;
     nroDernierCoupAtteint := nbreCoup;
     IndexProchainFilsDansGraphe := -1;
     MyDisableItem(PartieMenu,ForwardCmd);
     FixeMarqueSurMenuMode(nbreCoup);
     if avecInterversions then PreouvrirGraphesUsuels;
     
     oldPositionFeerique := positionFeerique;
     positionFeerique := not(EstLaPositionStandardDeDepart(jeuCourant));  
     if positionFeerique then nbPartiesActives := 0;
     
     doitDetruireAncienArbreDeJeu := not(mergeWithCurrentTree) | positionFeerique | oldPositionFeerique;
     ReInitialisePartieHdlPourNouvellePartie(doitDetruireAncienArbreDeJeu);
     SetCurrentNodeToGameRoot;
     MarquerCurrentNodeCommeReel('ComprendPositionEtPartieDuFichier');
     
     InitialiseDirectionsJouables;
     CarteJouable(jeuCourant,emplJouable);
     if odd(nbreCoup) 
       then aQuiDeJouer := pionBlanc 
       else aQuiDeJouer := pionNoir;
    (* if avecDessinCoupEnTete then EffaceCoupEnTete;
     SetCoupEntete(0);*)
     gameOver := false;
     PartieContreMacDeBoutEnBout := false;
     peutfeliciter := true;
     if DoitPasser(aQuiDeJouer,jeuCourant,emplJouable) then
       if DoitPasser(-aQuiDeJouer,jeuCourant,emplJouable) 
         then TachesUsuellesPourGameOver
         else aQuiDeJouer := -aQuiDeJouer;
         
         
     SetPositionInitialeOfGameTree(jeuCourant,aQuiDeJouer,nbreDePions[pionBlanc],nbreDePions[pionNoir]);
     AddInfosStandardsFormatSGFDansArbre;
     if doitDetruireAncienArbreDeJeu then
       AjouteDescriptionPositionEtTraitACeNoeud(PositionEtTraitCourant(),GetRacineDeLaPartie());
     
     
     
     CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
     CarteFrontiere(jeuCourant,frontiereCourante);
     meilleurCoupHum := 0;
     RefleSurTempsJoueur := false;
     LanceInterruption(interruptionSimple,'ComprendPositionEtPartieDuFichier');
     vaDepasserTemps := false;
     reponsePrete := false;  
     MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
     MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0)); 
     VideMeilleureSuiteInfos;
     MemoryFillChar(@tableHeurisNoir,sizeof(tableHeurisNoir),chr(0));
     MemoryFillChar(@tableHeurisBlanc,sizeof(tableHeurisBlanc),chr(0));
     aideDebutant := false;  
     dernierTick := TickCount();  
     EssaieDisableForceCmd;     
     
     
     if not(windowPlateauOpen) then OuvreFntrPlateau(false);
     MetTitreFenetrePlateau;
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);
     DessinePlateau(true);
     for i := 1 to 8 do
       for j := 1 to 8 do
         begin
           x := 10*i+j;
           if (jeuCourant[x] = pionNoir) | (jeuCourant[x] = pionBlanc)
             then PosePion(x,jeuCourant[x]);
         end;
     
    
    
     MemoryFillChar(@possibleMove,sizeof(possibleMove),chr(0));  { pour l'affichage }
     
     
     CompacterPartieAlphanumerique(positionEtpartie,kCompacterTelQuel);
     nombreCoupsRepris := Length(positionEtpartie) div 2;
     for i := 1 to nombreCoupsRepris do
     begin
       x := PositionDansStringAlphaEnCoup(positionEtpartie,2*i-1);
       if PeutJouerIci(aQuiDeJouer,x,jeuCourant) 
         then
           begin
             if JoueEn(x,aQuiDeJouer,legal,true,(i=nombreCoupsRepris)) then;
           end
         else
           begin
             if PeutJouerIci(-aQuiDeJouer,x,jeuCourant)  
              then
                begin
                  aQuiDeJouer := -aQuiDeJouer;
                  if JoueEn(x,aQuiDeJouer,legal,true,(i=nombreCoupsRepris)) then;
                end
              else
                TachesUsuellesPourGameOver;
           end;
     end;
   
   afficheNumeroCoup := tempoAfficheNumeroCoup;
   if afficheNumeroCoup & (nbreCoup>0) then
      begin
        x := DerniereCaseJouee();
        if InRange(x,11,88) then 
            DessineNumeroCoup(x,nbreCoup,-jeuCourant[x],GetCurrentNode());
      end;
   
   SetEffacageProprietesOfCurrentNode(kToutesLesProprietes);
   SetAffichageProprietesOfCurrentNode(kToutesLesProprietes);
   AfficheProprietesOfCurrentNode(false,othellierToutEntier,'ComprendPositionEtPartieDuBuffer');
   
   CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
   if mobilite=0 then
    begin
      aQuiDeJouer := -aQuiDeJouer;
      CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
      if mobilite=0 then TachesUsuellesPourGameOver;
    end;
   
   dernierTick := TickCount();
   Heure(pionNoir);
   Heure(pionBlanc);
   AfficheScore;
   ReinitilaliseInfosAffichageReflexion;      
   if affichageReflexion.doitAfficher then EffaceReflexion;
   SetValeursGestionTemps(0,0,0,0.0,0,0);
   MyDisableItem(PartieMenu,Forcecmd);
   AfficheDemandeCoup;
   avecSon := temposon;
   afficheBibl := tempobibl;
   afficheInfosApprentissage := tempoAfficheInfosApprentissage;
   avecDelaiDeRetournementDesPions := tempoAvecDelaiDeRetournementDesPions;
   avecCalculPartiesActives := true;
   {la}
   phaseDeLaPartie := CalculePhasePartie(nbreCoup);
   gDoitJouerMeilleureReponse := false;
   Initialise_table_heuristique(jeuCourant);
   DessineBoiteDeTaille(wPlateauPtr);
   InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);
   NoUpdateWindowPlateau;
   if avecInterversions then FermerGraphesUsuels;
   SetPort(oldPort);
   AjusteCurseur;
   
   if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
        QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
        
   MetTitreFenetrePlateau;
   if afficheInfosApprentissage then EcritLesInfosDApprentissage;
   if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
     then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
   
   ComprendPositionEtPartieDuFichier := err;
end;


function OuvrirFichierPartieFormatCassio(nomFichier : str255;mergeWithCurrentTree : boolean) : OSErr;
{ attention! On doit être dans le bon repertoire, ou nomFichier doit etre un path complet }
var chainePartie,s : str255;
    erreurES : SInt16; 
    nomLongDuFichier : str255;
    ficPartie : FichierTEXT;
    texteDuFichierMisDansRapport : boolean;
    debutSelection,finSelection : SInt32;
    infos:FormatFichierRec;
begin
  OuvrirFichierPartieFormatCassio := -1;
  
  if not(PeutArreterAnalyseRetrograde()) then
    exit(OuvrirFichierPartieFormatCassio);
  
  if nomFichier='' then 
    begin
      AlerteSimpleFichierTexte(nomFichier,0);
      exit(OuvrirFichierPartieFormatCassio);
    end;
    
  {SetDebuggageUnitFichiersTexte(false);}

  erreurES := FichierTexteExiste(nomFichier,0,ficPartie);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomFichier,erreurES);
      OuvrirFichierPartieFormatCassio := erreurES;
      exit(OuvrirFichierPartieFormatCassio);
    end;
  
  
  if TypeDeFichierEstConnu(ficPartie,infos,erreurES) 
     & ((infos.format = kTypeFichierCassio) | 
        (infos.format = kTypeFichierHTMLOthelloBrowser) |
        (infos.format = kTypeFichierTranscript) |
        (infos.format = kTypeFichierZebra) |
        (infos.format = kTypeFichierExportTexteDeZebra) |
        (infos.format = kTypeFichierSimplementDesCoups) |
        (infos.format = kTypeFichierLigneAvecJoueurEtPartie)) 
     & (infos.tailleOthellier = 8)
    then
      begin
        chainePartie := infos.positionEtPartie;
      end
    else
      begin
        erreurES := PathCompletToLongName(nomFichier,nomLongDuFichier);
        AlerteFormatNonReconnuFichierPartie(nomLongDuFichier);
        exit(OuvrirFichierPartieFormatCassio);
      end;
     
  erreurES := OuvreFichierTexte(ficPartie);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomFichier,erreurES);
      OuvrirFichierPartieFormatCassio := erreurES;
      exit(OuvrirFichierPartieFormatCassio);
    end;
   
  while Pos(':',nomFichier) <> 0 do
     nomFichier := TPCopy(nomFichier,Pos(':',nomFichier)+1,Length(nomFichier)-Pos(':',nomFichier));
  titrePartie^^ := nomFichier;
  ParamDiagCourant.titreFFORUM^^ := '';
  ParamDiagCourant.commentPositionFFORUM^^ := '';
  ParamDiagPositionFFORUM.titreFFORUM^^ := '';
  ParamDiagPositionFFORUM.commentPositionFFORUM^^ := nomFichier;
  ParamDiagPartieFFORUM.titreFFORUM^^ := nomFichier;
  ParamDiagPartieFFORUM.commentPositionFFORUM^^ := '';
  CommentaireSolitaire^^ := '';
  SetMeilleureSuite('');
  finaleEnModeSolitaire := false;
  
  erreurES := FSSpecToLongName(ficPartie.theFSSpec,nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
  
  erreurES := ComprendPositionEtPartieDuFichier(nomFichier,chainePartie,mergeWithCurrentTree);
  
  
  texteDuFichierMisDansRapport := false;
  FinRapport;
  TextNormalDansRapport;
  debutSelection := GetPositionPointDinsertion();
  finSelection := debutSelection;
  
  if (erreurES<>NoErr) then
    begin
      OuvrirFichierPartieFormatCassio := erreurES;
      erreurES := FermeFichierTexte(ficPartie);
      exit(OuvrirFichierPartieFormatCassio);
    end
  else
    if not(EOFFichierTexte(ficPartie,erreurES)) then
    begin
      while not(EOFFichierTexte(ficPartie,erreurES)) do
        begin
          erreurES := ReadlnDansFichierTexte(ficPartie,s);
          if Pos('¬R¬',s)=1 then  {rapport}
            begin
              texteDuFichierMisDansRapport := true;
              s := TPCopy(s,4,Length(s)-3);
              if s[Length(s)]='¶' 
                then
                  begin
                    s := TPCopy(s,1,Length(s)-1);
                    WritelnDansRapportSync(s,false);
                  end
                else
                  WriteDansRapportSync(s,false);
            end;
          if s[1]='%' then   {commentaire}
            begin
              {nothing}
            end;
        end;
      if texteDuFichierMisDansRapport then
        begin
          WritelnDansRapportSync('',false);
          finSelection := GetPositionPointDinsertion();
          WritelnDansRapportSync('',false);
        end;
    end;
  UpdateScrollersRapport;
    
  if FenetreRapportEstOuverte() then InvalidateWindow(GetRapportWindow());
  if not(CassioEstEnModeAnalyse()) & not(HumCtreHum) 
    then DoChangeHumCtreHum;
      
  erreurES := FermeFichierTexte(ficPartie);
  
  if texteDuFichierMisDansRapport then
    begin
      AppliquerStyleDuFichierAuRapport(ficPartie,debutSelection,finSelection);
      FinRapport;
      TextNormalDansRapport;
    end;
  
  OuvrirFichierPartieFormatCassio := NoErr;
end;




function OuvrirFichierPartieFormatGGF(nomFichier : str255;mergeWithCurrentTree : boolean) : OSErr;
{ attention! On doit être dans le bon repertoire, ou nomFichier doit etre un path complet }
var partieEnAlpha : str255;
    erreurES : SInt16; 
    nomLongDuFichier : str255;
    ficPartie : FichierTEXT;
    infos:FormatFichierRec;
    posInitialeDansFichier : PositionEtTraitRec;
begin  {$UNUSED mergeWithCurrentTree}
  OuvrirFichierPartieFormatGGF := -1;
  
  if not(PeutArreterAnalyseRetrograde()) then
    exit(OuvrirFichierPartieFormatGGF);
  
  if nomFichier='' then 
    begin
      AlerteSimpleFichierTexte(nomFichier,0);
      exit(OuvrirFichierPartieFormatGGF);
    end;
    
  {SetDebuggageUnitFichiersTexte(false);}

  erreurES := FichierTexteExiste(nomFichier,0,ficPartie);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomFichier,erreurES);
      OuvrirFichierPartieFormatGGF := erreurES;
      exit(OuvrirFichierPartieFormatGGF);
    end;
  
  if TypeDeFichierEstConnu(ficPartie,infos,erreurES) & 
     (infos.format = kTypeFichierGGF) & (infos.tailleOthellier = 8)
    then
      begin
        erreurES := GetPositionInitialeEtPartieDansFichierSGF_ou_GGF_8x8(ficPartie,kTypeFichierGGF,posInitialeDansFichier,partieEnAlpha);
        if (erreurES <> 0)
          then
            begin
              SysBeep(0);
              WritelnStringAndNumDansRapport('ERREUR !!! Dans OuvrirFichierPartieFormatGGF, erreurES = ',erreurES);
              OuvrirFichierPartieFormatGGF := erreurES;
              exit(OuvrirFichierPartieFormatGGF);
            end
          else
            begin
              PlaquerPositionEtPartie(posInitialeDansFichier,partieEnAlpha,kRejouerLesCoupsEnDirect);
              erreurES := FSSpecToLongName(ficPartie.theFSSpec,nomLongDuFichier);
              AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
            end;
      end
    else
      begin
        AlerteFormatNonReconnuFichierPartie(nomFichier);
        exit(OuvrirFichierPartieFormatGGF);
      end;
   
  while Pos(':',nomFichier) <> 0 do
     nomFichier := TPCopy(nomFichier,Pos(':',nomFichier)+1,Length(nomFichier)-Pos(':',nomFichier));
  titrePartie^^ := nomFichier;
  ParamDiagCourant.titreFFORUM^^ := '';
  ParamDiagCourant.commentPositionFFORUM^^ := '';
  ParamDiagPositionFFORUM.titreFFORUM^^ := '';
  ParamDiagPositionFFORUM.commentPositionFFORUM^^ := nomFichier;
  ParamDiagPartieFFORUM.titreFFORUM^^ := nomFichier;
  ParamDiagPartieFFORUM.commentPositionFFORUM^^ := '';
  
  
  if not(CassioEstEnModeAnalyse()) & not(HumCtreHum) 
    then DoChangeHumCtreHum;
      
  OuvrirFichierPartieFormatGGF := NoErr;
end;


function OuvrirFichierPartieFormatSmartGameBoard(nomCompletFichier : str255;mergeWithCurrentTree : boolean) : OSErr;
var theZone : ZoneMemoire;
    ficPartie : FichierTEXT;
    erreurES : SInt16; 
    tick : SInt32;
    theDate : DateTimeRec;
    nomLongDuFichier : str255;
    nomCourt,dateModifFichier : str255;
    dateDansDatabase : str255;
begin
  
  OuvrirFichierPartieFormatSmartGameBoard := -1;

  if not(PeutArreterAnalyseRetrograde()) then
    exit(OuvrirFichierPartieFormatSmartGameBoard);

  if (nomCompletFichier='') then 
    begin
      AlerteSimpleFichierTexte(nomCompletFichier,0);
      exit(OuvrirFichierPartieFormatSmartGameBoard);
    end;

  erreurES := FichierTexteExiste(nomCompletFichier,0,ficPartie);
  if erreurES <> NoErr then 
    begin
      OuvrirFichierPartieFormatSmartGameBoard := erreurES;
      AlerteSimpleFichierTexte(nomCompletFichier, erreurES);
      exit(OuvrirFichierPartieFormatSmartGameBoard);
    end;
  
  nomCourt := ExtraitNomDirectoryOuFichier(nomCompletFichier);
  erreurES := FSSpecToLongName(ficPartie.theFSSpec,nomLongDuFichier);
  if not(EstUnNomDeFichierTemporaireDePressePapier(nomCompletFichier)) &
     (GetModificationDateFichierTexte(ficPartie,theDate) = NoErr) then
    begin
      dateModifFichier := DateEnString(theDate);
      if FichierExisteDansDatabaseOfRecentSGFFiles(nomCourt,dateDansDatabase) & (dateDansDatabase = dateModifFichier)
        then SetToujoursAjouterInterversionDansGrapheInterversions(false)
        else SetToujoursAjouterInterversionDansGrapheInterversions(true);
      AjouterNomDansDatabaseOfRecentSGFFiles(dateModifFichier,nomCourt);
    end;
 
  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  tick := TickCount();
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
  
  
  theZone := MakeZoneMemoireFichier(nomCompletFichier,0);
  
  if ZoneMemoireEstCorrecte(theZone) then
    begin
      if PositionFeerique 
         then DoNouvellePartie(true)
         else DoDebut(not(CassioEstEnModeAnalyse()));
      
      if mergeWithCurrentTree
        then SetCurrentNodeToGameRoot
        else ReInitialiseGameRootGlobalDeLaPartie;
      MarquerCurrentNodeCommeReel('OuvrirFichierPartieFormatSmartGameBoard');
        
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
      
      titrePartie^^ := nomCourt;
      AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
        
      LitFormatSmartGameBoard(GetCurrentNode(),theZone);
      DisposeZoneMemoire(theZone);
      
      SetToujoursAjouterInterversionDansGrapheInterversions(true);
      {WritelnStringAndNumDansRapport('temps de lecture = ',TickCount()-tick);}
      
      UpdateGameByMainBranchFromCurrentNode(nbreCoup,jeuCourant,emplJouable,frontiereCourante,
                                                       nbreDePions[pionBlanc],nbreDePions[pionNoir],aQuiDeJouer,nbreCoup);
      
      EffaceProprietesOfCurrentNode;
      AfficheProprietesOfCurrentNode(false,othellierToutEntier,'OuvrirFichierPartieFormatSmartGameBoard');
      
      if not(CassioEstEnModeAnalyse()) & not(HumCtreHum) 
        then DoChangeHumCtreHum;
        
      if not(AfficheProchainsCoups) then DoChangeAfficheProchainsCoups;
    end;
    
  AjusteCurseur;
  FinRapport;
  TextNormalDansRapport;
  
  OuvrirFichierPartieFormatSmartGameBoard := NoErr;
end;


function OuvrirFichierParNomComplet(nomCompletFichier : str255;mergeWithCurrentTree : boolean) : OSErr;
var fic : FichierTEXT;
    infos:FormatFichierRec;
    err : OSErr;
    temp : boolean;
{$IFC USE_PROFILER_OUVERTURE_FICHIERS}
    nomFichierProfileOuvrirFichier : str255;
{$ENDC}
label clean_up;
    
  procedure NotRecognised;
  begin
    AlerteFormatNonReconnuFichierPartie(fic.theFSSpec.name);
  end;
  
begin
  temp := gEnEntreeSortieLongueSurLeDisque;
  gEnEntreeSortieLongueSurLeDisque := true;
  AjusteSleep;
  
{$IFC USE_PROFILER_OUVERTURE_FICHIERS}
  if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr 
    then ProfilerSetStatus(1);
{$ENDC}

  if not(PeutArreterAnalyseRetrograde()) then
    begin
      OuvrirFichierParNomComplet := -1;
      goto clean_up;
    end;
  
  
  err := FichierTexteExiste(nomCompletFichier,0,fic);
  
  if (err = NoErr) then
    if TypeDeFichierEstConnu(fic,infos,err) 
      then
				begin
				  err := 1000;
				  
				  {WritelnStringAndNumDansRapport('infos.format = ',SInt32(infos.format));
				  WritelnStringAndNumDansRapport('infos.tailleOthellier = ',infos.tailleOthellier);}
				  
				  if (infos.format = kTypeFichierScriptFinale) then
					  if Pos('problemes_stepanov',nomCompletFichier) > 0
					    then 
					      begin
					        dernierProblemeStepnanovAffiche := 0;
					        err := ProcessProblemesStepanov(nomCompletFichier,dernierProblemeStepnanovAffiche + 1);
					      end
					    else 
					      err := OuvrirEndgameScript(nomCompletFichier);
					
					if (infos.format = kTypeFichierPGN) then
					  err := AjouterPartiesFichierPGNDansListe('name_mapping_VOG_to_WThor.txt',fic);
					
					if (infos.format = kTypeFichierGGFMultiple)                        |
					   (infos.format = kTypeFichierSuiteDePartiePuisJoueurs)           | 
					   (infos.format = kTypeFichierSuiteDeJoueursPuisPartie)           |
					   (infos.format = kTypeFichierMultiplesLignesAvecJoueursEtPartie) |
					   (infos.format = kTypeFichierSimplementDesCoupsMultiple)  then
  					err := AjouterPartiesFichierDestructureDansListe(infos.format,fic);
					
					if (infos.format = kTypeFichierTHOR_PAR) & (infos.tailleOthellier = 8) then
					  err := AjouterPartiesFichierTHOR_PARDansListe(fic);
					  
			    if (infos.format = kTypeFichierCassio) & (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);
					
					if (infos.format = kTypeFichierHTMLOthelloBrowser) & (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);
					
					if (infos.format = kTypeFichierTranscript) & (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);
					  
					if (infos.format = kTypeFichierZebra) & (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);
					  
					if (infos.format = kTypeFichierExportTexteDeZebra) & (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);
					
					if (infos.format = kTypeFichierSimplementDesCoups) & (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);
					  
					if (infos.format = kTypeFichierLigneAvecJoueurEtPartie) & (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);
					
					if (infos.format = kTypeFichierGGF) & (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatGGF(nomCompletFichier,mergeWithCurrentTree);
					
			    if (infos.format = kTypeFichierSGF) & (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatSmartGameBoard(nomCompletFichier,mergeWithCurrentTree);
					
					if (infos.format = kTypeFichierBibliotheque) then
					  err := LitBibliotheque(nomCompletFichier,BAND(theEvent.modifiers,optionKey) <> 0);
					
					if (infos.format = kTypeFichierPreferences) then
					  err := NoErr; {FIXME : do nothing, maybe we should try to open the preference file}
			    
			    if err = 1000 
			      then NotRecognised;
	       end
	     else
	       NotRecognised;
  
  {WritelnStringAndNumDansRapport('dans OuvrirFichierParNomComplet, err = ',err);}
  OuvrirFichierParNomComplet := err;
  
{$IFC USE_PROFILER_OUVERTURE_FICHIERS}
  nomFichierProfileOuvrirFichier := 'ouvrir_fichier_' + NumEnString(Tickcount() div 60) + '.profile';
  WritelnDansRapport('nomFichierProfileOuvrirFichier = '+nomFichierProfileOuvrirFichier);
  if ProfilerDump(nomFichierProfileOuvrirFichier) <> NoErr 
    then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfileOuvrirFichier+') a échoué !')
    else ProfilerSetStatus(0);
  ProfilerTerm;
{$ENDC}
  
 clean_up:
  gEnEntreeSortieLongueSurLeDisque := temp;
end;


function OuvrirFichierPartieFSp(fichier : FSSpec;mergeWithCurrentTree : boolean) : OSErr;
var nomComplet : str255;
begin
  OuvrirFichierPartieFSp := -1;
  MyResolveAliasFile(fichier);
  if FSSpecToFullPath(fichier,nomComplet) = NoErr then
    begin 
      AjoutePartieDansMenuReouvrir(nomComplet);
	    OuvrirFichierPartieFSp := OuvrirFichierParNomComplet(nomComplet,mergeWithCurrentTree);
    end;
end;


function OuvrirFichierPressePapier() : OSErr;
var fic : FichierTEXT;
    myError : OSErr;
begin
  myError := DumpPressePapierToFile(fic);
  if (myError = NoErr) then
    begin
      myError := OuvrirFichierPartieFSp(fic.theFSSpec,true);
      myError := EffaceFichierTexte(fic);
    end;
  OuvrirFichierPressePapier := myError;
end;


procedure DoOuvrir;
  var reply : SFReply;
      ok : boolean;
      nomComplet : str255;
      err : OSErr;
      mySpec : FSSpec;
begin
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
  BeginDialog;
  ok := GetFileName(reply,'????','????','????','????',mySpec);
  EndDialog;
  if ok then
    begin
      nomComplet := GetFullPathOfFSSpec(mySpec);
      AjoutePartieDansMenuReouvrir(nomComplet);
      err := OuvrirFichierParNomComplet(nomComplet,true);
    end;
end;

procedure DoEnregistrerSousFormatCassio(modifiers : SInt16);
  var reply : SFReply;
      posEtPartie,s : str255;
      mySpec : FSSpec;
      ficPartie : FichierTEXT;
      texteRapportHdl : CharArrayHandle;
      i,count,fin : SInt32;
      c : char;
      erreurES : OSErr;
      bidon : boolean;
begin
  reply.fname := titrePartie^^;
  BeginDialog;
  bidon := MakeFileName(reply,ReadStringFromRessource(TextesDiversID,1),mySpec);  {'Donnez un nom à la partie'}
  EndDialog;
  if reply.good then
   begin
   
     if (BAND(modifiers,optionKey) <> 0)
       then posEtPartie := PositionInitialeEnLignePourPressePapier()+PartiePourPressePapier(false,true,nbreCoup)
       else posEtPartie := PositionInitialeEnLignePourPressePapier()+PartiePourPressePapier(false,true,60);
     
     erreurES := FichierTexteExisteFSp(mySpec,ficPartie);
     if erreurES=fnfErr {-43 => fichier non trouvé, on le crée}
       then erreurES := CreeFichierTexteFSp(mySpec,ficPartie);
     if erreurES=NoErr then
       begin
         erreurES := OuvreFichierTexte(ficPartie);
         erreurES := VideFichierTexte(ficPartie);
       end;
     if ErreurES<>NoErr then
       begin
         AlerteSimpleFichierTexte(reply.fName,ErreurES);
         erreurES := FermeFichierTexte(ficPartie);
         exit(DoEnregistrerSousFormatCassio);
       end;
       
     erreurES := WritelnDansFichierTexte(ficPartie,posEtpartie);
     
     {on ecrit le nom du fichier comme commentaire a l'intérieur}
     {les lignes de commentaire commancent par %}
     s := Concat('%filename = ',reply.fName);
     erreurES := WritelnDansFichierTexte(ficPartie,s);
          
     {on ecrit la selection du rapport dans le fichier}
     {chaque ligne coommence par '¬R¬' et finit par '¶'}
     if SelectionRapportNonVide() then
       begin
         texteRapportHdl := GetRapportTextHandle();
         i := GetDebutSelectionRapport();
         fin := GetFinSelectionRapport();
         s := '';count := 0;
         repeat
           c := texteRapportHdl^^[i];
           if c=chr(13) then c := '¶';
           s := s+c;
           i := i+1;
           count := count+1;
           if (c='¶') | (count>=230) then 
             begin
               erreurES := WritelnDansFichierTexte(ficPartie,'¬R¬'+s);
               s := '';count := 0;
             end;
         until (i >= fin) | (erreurES<>NoErr);
         if (s <> '') then 
           erreurES := WritelnDansFichierTexte(ficPartie,'¬R¬'+s);
       end;
   
     erreurES := FermeFichierTexte(ficPartie);
     SetFileTypeFichierTexte(ficPartie,'TSNX');
     SetFileCreatorFichierTexte(ficPartie,'SNX4');
     
     if SelectionRapportNonVide() then 
       SauverStyleDuRapport(ficPartie);

     titrePartie^^ := reply.fName;
     AjoutePartieDansMenuReouvrir(GetFullPathOfFSSpec(mySpec));
   end;
end;


procedure DoEnregistrerSousFormatSmartGameBoard;
var theZone : ZoneMemoire;
    nomComplet,s : str255;
    mySpec : FSSpec;
    reply : SFReply;
    err : OSErr;
    texteRapportHdl : CharArrayHandle;
    debut,count : SInt32;
    state : SignedByte;
    prop : Property;
    fichier : FichierTEXT;
    theDate : DateTimeRec;
    bidon : boolean;
begin
  s := titrePartie^^;
  if not(EndsWith(s,'.sof') | EndsWith(s,'.SOF') | EndsWith(s,'.sgf') | EndsWith(s,'.SGF')) then 
    begin
      if EndsWith(s,'.')
        then s := s + 'sof'
        else s := s + '.sof';
    end;
    
  reply.fname := s;
  BeginDialog;
  bidon := MakeFileName(reply,ReadStringFromRessource(TextesDiversID,4),mySpec);  {'Donnez un nom à l'arbre de jeu'}
  EndDialog;
  
  if reply.good then
    begin
      titrePartie^^ := reply.fName;
      nomComplet := GetFullPathOfFSSpec(mySpec);
      
      theZone := MakeZoneMemoireFichier(nomComplet,0);
      
      if ZoneMemoireEstCorrecte(theZone) then
        begin
          
          AjoutePartieDansMenuReouvrir(nomComplet);
          err := ViderZoneMemoire(theZone);
          watch := GetCursor(watchcursor);
          SafeSetCursor(watch);
          
          {fabrication d'une property d'ecriture dans le rapport, à interpreter quand on rouvrira le fichier}
          if SelectionRapportNonVide() then  
             begin
               texteRapportHdl := GetRapportTextHandle();
               debut := GetDebutSelectionRapport();
               count := LongueurSelectionRapport();
               
               state := HGetState(Handle(texteRapportHdl));
               HLock(Handle(texteRapportHdl));
               prop := MakeTexteProperty(GameCommentProp,Ptr(SInt32(texteRapportHdl^)+debut),count);
               HSetState(Handle(texteRapportHdl),state);
               DeletePropertiesOfTheseTypesInList([GameCommentProp],GetRacineDeLaPartie()^.properties);
               AddPropertyToGameTree(prop,GetRacineDeLaPartie());
               DisposePropertyStuff(prop);
             end;
          EcritFormatSmartGameBoard(GetRacineDeLaPartie(),theZone);
          if SelectionRapportNonVide() then
            begin
              DeletePropertiesOfTheseTypesInList([GameCommentProp],GetRacineDeLaPartie()^.properties);
              if GetFichierTEXTOfZoneMemoirePtr(@theZone,fichier) = NoErr then
                SauverStyleDuRapport(fichier);
            end;
          SetZoneType(theZone,'TEXT');
          SetZoneCreator(theZone,'SNX4');
          
          if (GetFichierTEXTOfZoneMemoirePtr(@theZone,fichier) = NoErr) then
            begin
              err := GetModificationDateFichierTexte(fichier,theDate);
              AjouterNomDansDatabaseOfRecentSGFFiles(DateEnString(theDate),reply.fName);
            end;
          DisposeZoneMemoire(theZone);
        end;
        
      AjusteCurseur;
    end;
end;



procedure DoEnregistrerSous(useSmartGameBoardFormat : boolean);
begin
  if useSmartGameBoardFormat
    then DoEnregistrerSousFormatSmartGameBoard
    else DoEnregistrerSousFormatCassio(theEvent.modifiers);
end;

procedure DoOuvrirBibliotheque;
var reply : SFReply;
    mySpec : FSSpec;
begin
  if GetFileName(reply,'TEXT','BIBL','????','????',mySpec) then
    begin
      if LitBibliotheque(reply.fName,BAND(theEvent.modifiers,optionKey) <> 0) = NoErr then;
      EnableItemTousMenus;
    end;
end;

procedure DoEcritureSolutionSolitaire;
var bidbool : boolean;
    seulCoup,seuleDef,couleur,prof,score : SInt32;
    nbBlanc,nbNoir : SInt32;
    tempoSensLarge : boolean;
    nbremeill,causerejet : SInt32;
    oldInterruption : SInt16; 
begin
  tempoSensLarge := senslargeSolitaire;
  couleur := aQuiDeJouer;
  nbBlanc := nbreDePions[pionBlanc];
  nbNoir := nbreDePions[pionNoir];  
  prof := 64 - nbBlanc - nbNoir;
  if prof <= 20 then
    begin
     senslargeSolitaire := true;
     oldInterruption := GetCurrentInterruption();
     EnleveCetteInterruption(oldInterruption);
     bidbool := EstUnSolitaire(seulCoup,seuleDef,couleur,prof,nbblanc,nbnoir,jeuCourant,
                    emplJouable,frontiereCourante,score,nbremeill,true,causerejet,kSortiePapier,65);
     LanceInterruption(oldInterruption,'DoEcritureSolutionSolitaire');
    end; 
  senslargeSolitaire := tempoSensLarge;
end;




procedure PrepareNouvellePartie(ForceHumCtreHum : boolean);
var i : SInt16; 
    oldPort : grafPtr;
    s : str255;
    mobilite : SInt32;
    commentaireChange : boolean;
begin
   
   ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
   positionFeerique := false; 
   peutfeliciter := true;
   PartieContreMacDeBoutEnBout := true;
   gGongDejaSonneDansCettePartie := false;
  (* if avecDessinCoupEnTete then EffaceCoupEnTete; 
   SetCoupEntete(0);*)
   gameOver := false;
   MetTitreFenetrePlateau;
   enSetUp := false;
   enRetour := false;
   aQuiDeJouer := pionNoir; 
   nbreCoup := 0;
   CommentaireSolitaire^^ := '';
   DetermineMomentFinDePartie;
   phaseDeLaPartie := CalculePhasePartie(0);
   humainVeutAnnuler := false;
   RefleSurTempsJoueur := false;
   LanceInterruption(interruptionSimple,'PrepareNouvellePartie');
   vaDepasserTemps := false;
   reponsePrete := false;
   gDoitJouerMeilleureReponse := false;
   SetSuggestionDeFinaleEstDessinee(false);
   VideMeilleureSuiteInfos;
   ViderValeursDeLaCourbe;
   MemoryFillChar(@jeuCourant,sizeof(jeuCourant),chr(0));
   MemoryFillChar(@emplJouable,sizeof(emplJouable),chr(0));
   MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
   MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
   MemoryFillChar(@marques,sizeof(marques),chr(0));
   with gEntrainementOuvertures do
     begin
       for i := 0 to 64 do
         deltaNotePerduCeCoup[i] := 0;
       deltaNotePerduAuTotal := 0;
       ViderListOfMoveRecords(classementVariations);
       derniereProfCompleteMilieuDePartie := 0;
     end;
   for i := 0 to 99 do
       if interdit[i] then jeuCourant[i] := PionInterdit;
   ParamDiagCourant.titreFFORUM^^ := '';
   ParamDiagCourant.commentPositionFFORUM^^ := '';
   ParamDiagPositionFFORUM.titreFFORUM^^ := '';
   ParamDiagPositionFFORUM.commentPositionFFORUM^^ := '';
   ParamDiagPartieFFORUM.titreFFORUM^^ := '';
   ParamDiagPartieFFORUM.commentPositionFFORUM^^ := '';
   GetIndString(s,TextesDiversID,2);     {'sans titre'}
   titrePartie^^ := s;
   CommentaireSolitaire^^ := '';
   SetMeilleureSuite('');
   chainePourIOS := '';
   finaleEnModeSolitaire := false;
   


   EffaceProprietesOfCurrentNode;
   ReInitialisePartieHdlPourNouvellePartie(true);
   SetTexteFenetreArbreDeJeuFromArbreDeJeu(GetRacineDeLaPartie(),true,commentaireChange);

   
   VideMeilleureSuiteInfos;
   nbreCoup := 0;
   nroDernierCoupAtteint := 0;
   IndexProchainFilsDansGraphe := -1;
   nbreToursFeuillesMilieu := 0;
   nbreFeuillesMilieu := 0;
   SommeNbEvaluationsRecursives := 0;
   nbreToursNoeudsGeneresMilieu := 0;
   nbreNoeudsGeneresMilieu := 0;
   MyDisableItem(PartieMenu,ForwardCmd);
   Superviseur(nbreCoup);
   FixeMarqueSurMenuMode(nbreCoup);
   if not(HumCtreHum) & ForceHumCtreHum then DoChangeHumCtreHum;
   EssaieDisableForceCmd;
   
   EffacerTouteLaCourbe('PrepareNouvellePartie');
   DessineSliderFenetreCourbe;
   if not(windowPlateauOpen) then OuvreFntrPlateau(false);
   GetPort(oldPort);
   SetPortByWindow(wPlateauPtr);
   if IsWindowVisible(wPlateauPtr) then DessinePlateau(true);
   SetPositionsTextesWindowPlateau;
   PosePion(54,pionNoir);
   PosePion(45,pionNoir);
   PosePion(55,pionBlanc);
   PosePion(44,pionBlanc); 
   aideDebutant := false;
   InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);
   
   SetPositionInitialeStandardDansGameTree;
   AddInfosStandardsFormatSGFDansArbre;
   AjouteDescriptionPositionEtTraitACeNoeud(MakePositionEtTrait(jeuCourant,pionNoir),GetRacineDeLaPartie());
   AfficheProprietesOfCurrentNode(false,othellierToutEntier,'PrepareNouvellePartie');
   
   FlushEvents(updateEvt,0);
   
   InitialiseDirectionsJouables;
   CarteJouable(jeuCourant,emplJouable);
   Calcule_Valeurs_Tactiques(jeuCourant,true);   
   if OthelloTorique 
     then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
     else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
   CarteFrontiere(jeuCourant,frontiereCourante);
   nbreDePions[pionNoir] := 2;
   nbreDePions[pionBlanc] := 2;
   
   AfficheScore;
   
   Initialise_table_heuristique(jeuCourant);
   aQuiDeJouer := pionNoir; 
   MyDisableItem(PartieMenu,Forcecmd);
   
   AfficheDemandeCoup;
   if afficheInfosApprentissage then EcritLesInfosDApprentissage;
   if avecAleatoire then RandomizeTimer;
   {la}
   AjusteCadenceMin(GetCadence());
   
   DessineBoiteDeTaille(wPlateauPtr);
   dernierTick := TickCount();
   Heure(pionNoir); 
   Heure(pionBlanc);
   aQuiDeJouer := pionNoir;
   
   if not(IsWindowVisible(wPlateauPtr)) then
     begin
       InvalidateAllCasesDessinEnTraceDeRayon;
       ShowHide(wPlateauPtr,true);
       EcranStandard(NIL,false);
     end;
   
   {AttendFrappeClavier;}
   
   SetPort(oldPort);
   AjusteCurseur;
   DetruitMeilleureSuite;
   if avecCalculPartiesActives & (windowListeOpen | windowStatOpen) 
     then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
   
end;



procedure DoChangeAlerteInterversion;
begin
  avecAlerteNouvInterversion := not(avecAlerteNouvInterversion);
end;

{
procedure DoChangeEvaluationAleatoire;
begin
  EvaluationAleatoire := not(EvaluationAleatoire);
end;
}

procedure DoChangeEvaluationTablesDeCoins;
  begin
    avecEvaluationTablesDeCoins := not(avecEvaluationTablesDeCoins);
  end;

procedure DoChangeEvaluationDeFisher;
  begin
    avecEvaluationDeFisher := not(avecEvaluationDeFisher);
  end;

procedure DoChangeRefutationsDansRapport;
  begin
    avecRefutationsDansRapport := not(avecRefutationsDansRapport);
  end;
{
procedure DoChangePionClignotant;
  begin
    PionClignotant := not(PionClignotant);
  end;  
}
{
procedure DoChangeTorique;
  begin
    OthelloTorique := not(OthelloTorique);
  end;
}

procedure DoNouvellePartie(ForceHumCtreHum : boolean);
var commentaireChange : boolean;
begin
  if not(gPendantLesInitialisationsDeCassio) then
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
    end;
  PrepareNouvellePartie(ForceHumCtreHum);
  SetTexteFenetreArbreDeJeuFromArbreDeJeu(GetRacineDeLaPartie(),true,commentaireChange);
  EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
  if not(HumCtreHum) then
    begin
      reponsePrete := false;
      RefleSurTempsJoueur := false;
      LanceInterruption(interruptionSimple,'DoNouvellePartie');
      vaDepasserTemps := false;
    end;   
  AjusteCurseur;
  VideMeilleureSuiteInfos;
  InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);
end; 




procedure DoClose(whichWindow : WindowPtr;avecAnimationZoom : boolean);
begin
  if whichWindow = NIL then exit(DoClose);
  if whichWindow=wPlateauPtr
    then CloseProgramWindow
    else 
      if whichWindow=wCourbePtr
       then CloseCourbeWindow
       else 
         if whichWindow=wGestionPtr
         then CloseGestionWindow
         else
           if whichWindow=wReflexPtr
             then CloseReflexWindow
             else 
               if whichWindow=wListePtr
               then 
                 begin
                   CloseListeWindow;
                   if afficheInfosApprentissage then EcritLesInfosDApprentissage;
                 end
               else
                 if whichWindow=wStatPtr
                   then 
                     begin
                       CloseStatWindow;
                       if afficheInfosApprentissage then EcritLesInfosDApprentissage;
                     end
                   else 
                     if whichWindow=wPalettePtr
                       then ClosePaletteWindow
                       else 
                         if EstLaFenetreDuRapport(whichWindow)
                           then CloseRapportWindow
                           else
                             if whichWindow=iconisationDeCassio.theWindow
                               then CloseIconisationWindow
                               else
                                 if whichWindow=GetArbreDeJeuWindow()
                                   then CloseCommentairesWindow
                                   else
                                     if whichWindow=wAidePtr
                                       then CloseAideWindow
                                       else
    				                             begin
    				                               CloseDAWindow;
    				                               if (FrontWindow() <> NIL) then
    				                                  if WindowDeCassio(FrontWindow()) then SetPortByWindow(FrontWindow());
    				                             end;
		                             
  if not(Quitter) then
    begin
      if HasGotEvent(activMask,theEvent,0,NIL) then 
        TraiteOneEvenement;
      if HasGotEvent(activMask,theEvent,0,NIL) then 
        TraiteOneEvenement;  
      if HasGotEvent(activMask,theEvent,0,NIL) then 
        TraiteOneEvenement;
      EssaieUpdateEventsWindowPlateau;  
      EssaieUpdateEventsWindowPlateau;  
      if CloseZoomRectFrom.left<>-13333 then
        begin
          {InsetRect(CloseZoomRectTo,1,1);}
          if avecAnimationZoom & not(SupprimerLesEffetsDeZoom) then 
            ZoomRect(CloseZoomRectFrom,CloseZoomRectTo,kZoomIn,6,true);
          SetRect(CloseZoomRectFrom,-13333,-13333,-13333,-13333);
        end;
    end;
    
  if (FrontWindow() = NIL) | (enSetUp | enRetour)
      then MyDisableItem(GetFileMenu(),CloseCmd)
      else EnableItemPourCassio(GetFileMenu(),closecmd);
  FixeMarqueSurMenuBase;
end;

procedure DoCloseCmd(modifiers : SInt16);
var shift,command,option,control : boolean;
  begin
    shift := BAND(modifiers,shiftKey) <> 0;
    command := BAND(modifiers,cmdKey) <> 0;
    option := BAND(modifiers,optionKey) <> 0;
    control := BAND(modifiers,controlKey) <> 0;
    
	  if (FrontWindowSaufPalette() = NIL)
	     then 
	       begin
	         if windowPaletteOpen & (wPalettePtr <> NIL) then DoClose(wPalettePtr,true)
	       end 
	     else 
	       if windowPaletteOpen & (FrontWindowSaufPalette()=wPlateauPtr) 
	         then DoClose(wPalettePtr,true)
	         else 
	           begin
	             DoClose(FrontWindowSaufPalette(),not(option));
	             if option then FermeToutesLesFenetresAuxiliaires;
	           end
  end;


procedure DoAjouteTemps(aQui : SInt16);
var i : SInt16; 
    tempsAjouteMin,tempsAjouteSec : SInt16; 
    retireDuTemps : boolean;
begin
   tempsAjouteMin := 1;
   tempsAjouteSec := 60;
   retireDuTemps := BAND(theEvent.modifiers,optionKey) <> 0;
   if retireDuTemps then 
     begin
       tempsAjouteMin := -tempsAjouteMin;
       tempsAjouteSec := -tempsAjouteSec;
     end;
   tempsDesJoueurs[aQui].minimum := tempsDesJoueurs[aQui].minimum-tempsAjouteMin;
   if aqui = pionNoir 
     then
       for i := 0 to nbreCoup+1 do
           partie^^[i].tempsUtilise.tempsNoir := partie^^[i].tempsUtilise.tempsNoir-tempsAjouteSec
     else
       for i := 0 to nbreCoup+1 do
         partie^^[i].tempsUtilise.tempsBlanc := partie^^[i].tempsUtilise.tempsBlanc-tempsAjouteSec;     
   Heure(aQui)
end;

procedure DoSon;
  begin
    avecSon := not(avecSon);
    DessineIconesChangeantes;
  end;


procedure DoAvanceMove;
var coup,couleur : SInt16; 
    tempoSon : boolean;
begin
 if windowPlateauOpen & not(enRetour | enSetUp) then
   if nroDernierCoupAtteint > nbreCoup then     
    if GetNiemeCoupPartieCourante(nbreCoup+1) <> coupInconnu then
     begin
       EffaceAideDebutant(false,true,othellierToutEntier);
       ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
       coup := GetNiemeCoupPartieCourante(nbreCoup+1);
       couleur := partie^^[nbreCoup+1].trait;
       if couleur=aQuiDeJouer then
         begin
           tempoSon := avecSon;
           avecSon := false;
           DealWithEssai(coup,'DoAvanceMove');
           avecSon := tempoSon;
         end
         else 
          Bip(3);
       if afficheMeilleureSuite then EffaceMeilleureSuite;
       if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
       meilleurCoupHum := 44;
       meilleureReponsePrete := 44;
       gDoitJouerMeilleureReponse := false;
       PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
       RefleSurTempsJoueur := false;
       LanceInterruption(interruptionSimple,'DoAvanceMove');
       vaDepasserTemps := false;
       reponsePrete := false;
       phaseDeLaPartie := CalculePhasePartie(nbreCoup);
       FixeMarqueSurMenuMode(nbreCoup);
       EssaieDisableForceCmd;
       dernierTick := TickCount();
       Heure(-aQuiDeJouer);
       Heure(aQuiDeJouer);
       
       if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
         QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
                 
       AjusteCurseur;
     end;
end;

procedure DoDoubleAvanceMove;
var coup,couleur,i,mobilite : SInt32;
    oldport : grafPtr;
    err : OSErr;
begin
  if windowPlateauOpen & not(enRetour | enSetUp) then
  if (nroDernierCoupAtteint > nbreCoup) then     
    begin
      if nroDernierCoupAtteint = nbreCoup+1
        then DoAvanceMove
        else
          if nroDernierCoupAtteint = nbreCoup+2
            then 
              begin
                DoAvanceMove;
                DoAvanceMove;
              end
            else
              begin
                GetPort(OldPort);
                SetPortByWindow(wPlateauPtr);
                
                EffaceAideDebutant(false,true,othellierToutEntier);
                ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
                EffaceProprietesOfCurrentNode;
                if afficheNumeroCoup & (nbreCoup>0) then
                  begin
                    coup := DerniereCaseJouee();
                    if InRange(coup,11,88) then 
                      EffaceNumeroCoup(coup,nbreCoup,GetCurrentNode());
                  end;
                
                IndexProchainFilsDansGraphe := -1;
                nbreCoup := nbreCoup+1;
                coup := DerniereCaseJouee();
                couleur := partie^^[nbreCoup].trait;
                with partie^^[nbreCoup] do
                begin
                  DessinePion(coup,couleur);
                  
                  err := ChangeCurrentNodeAfterNewMove(coup,couleur,'DoDoubleAvanceMove {1}');
                  MarquerCurrentNodeCommeReel('DoDoubleAvanceMove  {1}');
                  
                  jeuCourant[DerniereCaseJouee()] := couleur;
                  for i := 1 to nbRetourne do
                    begin
                      jeuCourant[retournes[i]] := -jeuCourant[retournes[i]];
                      DessinePion(retournes[i],jeuCourant[retournes[i]]);
                    end;
                  nbreDePions[trait] := nbreDePions[trait]+nbretourne+1;
                  nbreDePions[-trait] := nbreDePions[-trait]-nbretourne;
                end;
                
                TraceSegmentCourbe(nbreCoup,kCourbeColoree,'DoDoubleAvanceMove {1}');
                DessineSliderFenetreCourbe;
                
                partie^^[nbreCoup+1].tempsUtilise.tempsNoir := 60*tempsDesJoueurs[pionNoir].minimum+tempsDesJoueurs[pionNoir].sec;
                partie^^[nbreCoup+1].tempsUtilise.tempsBlanc := 60*tempsDesJoueurs[pionBlanc].minimum+tempsDesJoueurs[pionBlanc].sec;
                nbreCoup := nbreCoup+1;
                coup := DerniereCaseJouee();
                couleur := partie^^[nbreCoup].trait;
                with partie^^[nbreCoup] do
                  begin
                    DessinePion(coup,couleur);
                    
                    err := ChangeCurrentNodeAfterNewMove(coup,couleur,'DoDoubleAvanceMove {2}');
                    MarquerCurrentNodeCommeReel('DoDoubleAvanceMove {2}');
                    
                    jeuCourant[DerniereCaseJouee()] := couleur;
                    for i := 1 to nbRetourne do
                      begin
                        jeuCourant[retournes[i]] := -jeuCourant[retournes[i]];
                        DessinePion(retournes[i],jeuCourant[retournes[i]]);
                      end;
                    nbreDePions[trait] := nbreDePions[trait]+nbretourne+1;
                    nbreDePions[-trait] := nbreDePions[-trait]-nbretourne;
                  end;
                  
                TraceSegmentCourbe(nbreCoup,kCourbeColoree,'DoDoubleAvanceMove {2}');
                DessineSliderFenetreCourbe;
                
                partie^^[nbreCoup+1].tempsUtilise.tempsNoir := 60*tempsDesJoueurs[pionNoir].minimum+tempsDesJoueurs[pionNoir].sec;
                partie^^[nbreCoup+1].tempsUtilise.tempsBlanc := 60*tempsDesJoueurs[pionBlanc].minimum+tempsDesJoueurs[pionBlanc].sec;
                IndexProchainFilsDansGraphe := -1;
                
                InitialiseDirectionsJouables;
                CarteJouable(jeuCourant,emplJouable);
                if (nroDernierCoupAtteint > nbreCoup)
                  then aQuiDeJouer := partie^^[nbreCoup+1].trait
                  else
                    begin
                      aQuiDeJouer := -partie^^[nbreCoup].trait;
                      if DoitPasser(aQuiDeJouer,jeuCourant,emplJouable) then
                        if DoitPasser(-aQuiDeJouer,jeuCourant,emplJouable) 
                          then TachesUsuellesPourGameOver
                          else aQuiDeJouer := -aQuiDeJouer;
                    end;
                    
               MetTitreFenetrePlateau;
               AjusteCurseur;
               if EnVieille3D() then Dessine3D(jeuCourant,false);
               if afficheNumeroCoup & (nbreCoup>0) then
                 if (DerniereCaseJouee() <> coupInconnu) & InRange(DerniereCaseJouee(),11,88)
                    then DessineNumeroCoup(DerniereCaseJouee(),nbreCoup,-jeuCourant[DerniereCaseJouee()],GetCurrentNode());
               {la}
               if EnModeEntreeTranscript() then EntrerPartieDansCurrentTranscript(nbreCoup);
               ZebraBookDansArbreDeJeuCourant;
               if afficheInfosApprentissage then EcritLesInfosDApprentissage;
               EnableItemPourCassio(PartieMenu,ForwardCmd);
               CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
               CarteFrontiere(jeuCourant,frontiereCourante);   
               {Initialise_table_heuristique(jeuCourant);}
               calculPrepHeurisFait := false;  
               AfficheScore;
               if (HumCtreHum | (aQuiDeJouer<>couleurMacintosh)) & not(demo) then
                  begin
                    MyDisableItem(PartieMenu,Forcecmd);
                    AfficheDemandeCoup;
                  end;
               if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
               meilleurCoupHum := 44;
               meilleureReponsePrete := 44;
               gDoitJouerMeilleureReponse := false;
               RefleSurTempsJoueur := false;
               LanceInterruption(interruptionSimple,'DoDoubleAvanceMove');
               vaDepasserTemps := false;
               reponsePrete := false;
               {peutfeliciter := true;}
               TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'DoDoubleAvanceMove');
             (*  if avecDessinCoupEnTete then EffaceCoupEnTete;
               SetCoupEntete(0);*)
               PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
               phaseDeLaPartie := CalculePhasePartie(nbreCoup);
               FixeMarqueSurMenuMode(nbreCoup);
               EssaieDisableForceCmd;
               dernierTick := TickCount();
               Heure(-aQuiDeJouer);
               Heure(aQuiDeJouer);
               
               
                 
               AjusteCurseur;
               AddRandomDeltaStoneToCurrentNode;
               AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoDoubleAvanceMove');
               if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
               
               if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
                 QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
                 
               if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
                 then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,true);
               SetPort(OldPort);
             end;
    end;
end;

procedure DoDemandeChangeCouleur;
  begin
    {EffaceAideDebutant(true,true,othellierToutEntier);}
    LanceInterruption(kHumainVeutChangerCouleur,'DoDemandeChangeCouleur');
    if not(HumCtreHum) then
      begin
        reponsePrete := false;
        RefleSurTempsJoueur := false;
        vaDepasserTemps := false;
      end;   
  end;
  
  
procedure DoDemandeJouerSolitaires;
  begin
    {EffaceAideDebutant(true,true,othellierToutEntier);}
    LanceInterruption(kHumainVeutJouerSolitaires,'DoDemandeJouerSolitaires');
    if not(HumCtreHum) then
      begin
        reponsePrete := false;
        RefleSurTempsJoueur := false;
        vaDepasserTemps := false;
      end;   
  end;


procedure DoDemandeChangerHumCtreHum;
var tempoHumCtreHum : boolean;
  begin
    if HumCtreHum
      then 
        DoChangeHumCtreHum
      else
        begin
          if PeutArreterAnalyseRetrograde() then
            begin
              tempoHumCtreHum := HumCtreHum;
              HumCtreHum := true;
              DessineIconesChangeantes;
              if afficheSuggestionDeCassio & HumCtreHum then EffaceSuggestionDeCassio;
              HumCtreHum := tempoHumCtreHum;
              LanceInterruption(kHumainVeutChangerHumCtreHum,'DoDemandeChangerHumCtreHum');         
              reponsePrete := false;
              RefleSurTempsJoueur := false;
              vaDepasserTemps := false;
            end;
        end;
  end;
  

procedure DoDemandeChangerHumCtreHumEtCouleur;
begin
  if (aQuiDeJouer=-couleurMacintosh) & HumCtreHum
    then
      begin
        LanceInterruption(kHumainVeutChangerCoulEtHumCtreHum,'DoDemandeChangerHumCtreHumEtCouleur');
        reponsePrete := false;
        RefleSurTempsJoueur := false;
        vaDepasserTemps := false;
      end
    else
      begin
        if (aQuiDeJouer=-couleurMacintosh) then DoDemandeChangeCouleur else
        if HumCtreHum then DoDemandeChangerHumCtreHum;
      end;
end;


procedure DoBackMove;
var i,mobilite : SInt32;
    oldport : grafPtr;
begin
  if windowPlateauOpen & not(enRetour | enSetUp) then
  begin
    GetPort(oldport);
    SetPortByWindow(wPlateauPtr);
    if nbreCoup >= 1 then
    if DerniereCaseJouee() <> coupInconnu then
     begin
       PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
       if not(HumCtreHum) & (jeuInstantane | CassioEstEnModeSolitaire()) & PartieContreMacDeBoutEnBout & (nbreCoup>=20) 
         then PlayZamfirSound('DoBackMove');
       if analyseRetrograde.enCours {& (nbPartiesActives>0)} & (analyseRetrograde.tempsDernierCoupAnalyse<300) & (nbreCoup>40)
         then avecCalculPartiesActives := false
         else avecCalculPartiesActives := true;
       
       EffaceAideDebutant(false,true,othellierToutEntier);
       ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
       EffaceProprietesOfCurrentNode;
       
       with partie^^[nbreCoup] do
       begin
         DessinePion(DerniereCaseJouee(),pionVide);
         jeuCourant[DerniereCaseJouee()] := pionVide;
         for i := 1 to nbRetourne do
           begin
             jeuCourant[retournes[i]] := -jeuCourant[retournes[i]];
             if RetournementSpecialEnCours()
               then DessinePion(retournes[i],ValeurFutureDeCetteCaseDansRetournementSpecial(retournes[i]))
               else DessinePion(retournes[i],jeuCourant[retournes[i]]);
           end;
         nbreDePions[trait] := nbreDePions[trait]-nbretourne-1;
         nbreDePions[-trait] := nbreDePions[-trait]+nbretourne;               
         aQuiDeJouer := trait;  
       end;
       tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup].tempsUtilise.tempsNoir div 60;
       tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup].tempsUtilise.tempsNoir mod 60;
       tempsDesJoueurs[pionNoir].tick := 0;
       tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup].tempsUtilise.tempsBlanc div 60;
       tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup].tempsUtilise.tempsBlanc mod 60;
       tempsDesJoueurs[pionBlanc].tick := 0;
       AjusteCurseur;
       if EnVieille3D() then Dessine3D(jeuCourant,false);
       
       ChangeCurrentNodeForBackMove;
       MarquerCurrentNodeCommeReel('DoBackMove');
       
       
       {
       with partie^^[nbreCoup] do
       begin
         trait := 0;
         x := coupInconnu;
         nbretourne := 0;
       end;
       }
       IndexProchainFilsDansGraphe := -1;
       nbreCoup := nbreCoup-1;
       if afficheNumeroCoup & (nbreCoup>0) then
         if (DerniereCaseJouee() <> coupInconnu) & InRange(DerniereCaseJouee(),11,88)
               then DessineNumeroCoup(DerniereCaseJouee(),nbreCoup,-jeuCourant[DerniereCaseJouee()],GetCurrentNode());
       EffaceCourbe(nbreCoup,nbreCoup+1,kCourbePastel,'DoBackMove');
       DessineSliderFenetreCourbe;
       {la}
       if afficheInfosApprentissage then EcritLesInfosDApprentissage;
       EnableItemPourCassio(PartieMenu,ForwardCmd);
       InitialiseDirectionsJouables;
       CarteJouable(jeuCourant,emplJouable);
       CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
       CarteFrontiere(jeuCourant,frontiereCourante);   
       {Initialise_table_heuristique(jeuCourant);}
       calculPrepHeurisFait := false;
       AfficheScore;
       if (HumCtreHum | (aQuiDeJouer<>couleurMacintosh)) & not(demo) then
          begin
            MyDisableItem(PartieMenu,Forcecmd);
            AfficheDemandeCoup;
          end;
       if afficheMeilleureSuite then EffaceMeilleureSuite;
       if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
       ZebraBookDansArbreDeJeuCourant;
       meilleurCoupHum := 44;
       meilleureReponsePrete := 44;
       gDoitJouerMeilleureReponse := false;
       RefleSurTempsJoueur := false;
       LanceInterruption(interruptionSimple,'DoBackMove');
       vaDepasserTemps := false;
       reponsePrete := false;
       PartieContreMacDeBoutEnBout := false;
       TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'DoBackMove');
       {peutfeliciter := true;}
      (* if avecDessinCoupEnTete then EffaceCoupEnTete;
       SetCoupEntete(0);*)
       gameOver := false;
       MetTitreFenetrePlateau;
       phaseDeLaPartie := CalculePhasePartie(nbreCoup);
       FixeMarqueSurMenuMode(nbreCoup);
       EssaieDisableForceCmd;
       dernierTick := TickCount();
       Heure(-aQuiDeJouer);
       Heure(aQuiDeJouer);
       
        
       AjusteCurseur;
       AddRandomDeltaStoneToCurrentNode;
       AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoBackMove');
       if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
       
       if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
         QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
                 
       if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
         then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,true);
       avecCalculPartiesActives := true;
     end;
     SetPort(oldport);
  end;
end;

procedure DoDoubleBackMove;
var i,mobilite : SInt32;
    oldport : grafPtr;
    limiteInfNbreCoup : SInt16; 
    peutPlusReculer : boolean;
begin
  if windowPlateauOpen & not(enRetour | enSetUp) then
  begin
    GetPort(oldport);
    SetPortByWindow(wPlateauPtr);
    if nbreCoup>=1 then
    if DerniereCaseJouee() <> coupInconnu then
     begin
       if not(HumCtreHum) & (jeuInstantane | CassioEstEnModeSolitaire()) & PartieContreMacDeBoutEnBout & (nbreCoup>=20) 
         then PlayZamfirSound('DoDoubleBackMove');
       if HumCtreHum | (not(CassioEstEnModeSolitaire()) & (aQuiDeJouer=couleurMacintosh))
         then 
           limiteInfNbreCoup := nbreCoup-2
         else
           begin
             i := nbreCoup;
             while (i>0) & (partie^^[i].trait=couleurMacintosh) do i := i-1;
             limiteInfNbreCoup := i-1;
           end;
       if limiteInfNbreCoup<0 then limiteInfNbreCoup := 0;
       repeat
         peutPlusReculer := true;
         if nbreCoup>=1 then
         if DerniereCaseJouee() <> coupInconnu then
           begin
            avecCalculPartiesActives := true;
            
            EffaceAideDebutant(false,true,othellierToutEntier);
            ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
            EffaceProprietesOfCurrentNode;
            with partie^^[nbreCoup] do
            begin
              DessinePion(DerniereCaseJouee(),pionVide);
              jeuCourant[DerniereCaseJouee()] := pionVide;
              for i := 1 to nbRetourne do
                begin
                  jeuCourant[retournes[i]] := -jeuCourant[retournes[i]];
                  DessinePion(retournes[i],jeuCourant[retournes[i]]);
                end;
              nbreDePions[trait] := nbreDePions[trait]-nbretourne-1;
              nbreDePions[-trait] := nbreDePions[-trait]+nbretourne;               
              aQuiDeJouer := trait;  
            end;
            tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup].tempsUtilise.tempsNoir div 60;
            tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup].tempsUtilise.tempsNoir mod 60;
            tempsDesJoueurs[pionNoir].tick := 0;
            tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup].tempsUtilise.tempsBlanc div 60;
            tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup].tempsUtilise.tempsBlanc mod 60;
            tempsDesJoueurs[pionBlanc].tick := 0;
            AjusteCurseur;
            
            ChangeCurrentNodeForBackMove;
            MarquerCurrentNodeCommeReel('DoDoubleBackMove');
            
            
            {
            with partie^^[nbreCoup] do
            begin
              trait := 0;
              x := coupInconnu;
              nbretourne := 0;
            end;
            }
            IndexProchainFilsDansGraphe := -1;
            nbreCoup := nbreCoup-1;
            if nbreCoup>=1 
              then peutPlusReculer := (DerniereCaseJouee() = coupInconnu)
              else peutPlusReculer := true;
            
            EffaceCourbe(nbreCoup,nbreCoup+1,kCourbePastel,'DoDoubleBackMove');
            DessineSliderFenetreCourbe;
          end;
       until (nbreCoup<=limiteInfNbreCoup) | peutPlusReculer;
       
       
       
       if EnVieille3D() then Dessine3D(jeuCourant,false);
       if afficheNumeroCoup & (nbreCoup>0) then
         if (DerniereCaseJouee() <> coupInconnu) & InRange(DerniereCaseJouee(),11,88)
           then DessineNumeroCoup(DerniereCaseJouee(),nbreCoup,-jeuCourant[DerniereCaseJouee()],GetCurrentNode());
       {la}
       if afficheInfosApprentissage then EcritLesInfosDApprentissage;
       EnableItemPourCassio(PartieMenu,ForwardCmd);
       InitialiseDirectionsJouables;
       CarteJouable(jeuCourant,emplJouable);
       CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
       CarteFrontiere(jeuCourant,frontiereCourante);   
       {Initialise_table_heuristique(jeuCourant);}
       calculPrepHeurisFait := false;
       AfficheScore;
       if (HumCtreHum | (aQuiDeJouer<>couleurMacintosh)) & not(demo) then
          begin
            MyDisableItem(PartieMenu,Forcecmd);
            AfficheDemandeCoup;
          end;
       if afficheMeilleureSuite then EffaceMeilleureSuite;
       if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
       ZebraBookDansArbreDeJeuCourant;
       meilleurCoupHum := 44;
       meilleureReponsePrete := 44;
       gDoitJouerMeilleureReponse := false;
       RefleSurTempsJoueur := false;
       LanceInterruption(interruptionSimple,'DoDoubleBackMove');
       vaDepasserTemps := false;
       reponsePrete := false;
       {peutfeliciter := true;}
       TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'DoDoubleBackMove');
      (* if avecDessinCoupEnTete then EffaceCoupEnTete;
       SetCoupEntete(0);*)
       PartieContreMacDeBoutEnBout := false;
       gameOver := false;
       MetTitreFenetrePlateau;
       phaseDeLaPartie := CalculePhasePartie(nbreCoup);
       FixeMarqueSurMenuMode(nbreCoup);
       EssaieDisableForceCmd;
       dernierTick := TickCount();
       Heure(-aQuiDeJouer);
       Heure(aQuiDeJouer);
       
        
       AjusteCurseur;
       AddRandomDeltaStoneToCurrentNode;
       AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoDoubleBackMove');
       if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
       
       if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
         QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
                 
       if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
         then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,true);
     end;
     SetPort(oldport);
  end;
end;

procedure DoBackMovePartieSelectionnee(nroHilite : SInt32);
var s60,anciennePartie : PackedThorGame;
    couleurs : str60; 
    nroreference : SInt32;
    coup,i,t,longueur : SInt32;
    premierNumero,derniernumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    premierCoup : SInt16; 
    test,good,bidbool : boolean;
    jeu,anciennePositionCourante : plateauOthello;
    jouable : plBool;
    front : InfoFrontRec;
    nbBlanc,nbNoir : SInt32;
    CoulTrait,mobilite : SInt32;
    oldNode : GameTree;
    GameNodeAAtteindre : GameTree;
begin
 if windowPlateauOpen & not(enRetour | enSetUp) then
 if windowListeOpen & not(Positionfeerique) & (nbreCoup>0) then
   with infosListeParties do
     begin
       GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);
		   {if (nroHilite>=premierNumero) & (nroHilite<=dernierNumero)
		    then}
		   if (nroHilite>=1) & (nroHilite<=nbPartiesActives) then
		     begin
		      nroReference := infosListeParties.dernierNroReferenceHilitee;
		      
		      ExtraitPartieTableStockageParties(nroReference,s60);
		      ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		      ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
		      TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie & ouvertureDiagonale & (nbreCoup>=4),1,60);
		      
		      if not(PositionsSontEgales(jeuCourant,CalculePositionApres(nbreCoup,s60))) then 
	          begin
	            WritelnDansRapport('WARNING : not(PositionsSontEgales(…) dans DoBackMovePartieSelectionnee');
	            with DemandeCalculsPourBase do
	              if (EtatDesCalculs<>kCalculsEnCours) | (NumeroDuCoupDeLaDemande<>nbreCoup) | bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	            InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
	            exit(DoBackMovePartieSelectionnee);
	          end;
		       
          test := true;
		      for i := 1 to nbreCoup do
		        begin
		          coup := GetNiemeCoupPartieCourante(i);
		          {patch pour les diagonales avec l'autre coup 4}
		          if autreCoupQuatreDansPartie & ((i=1) | (i=3))
		            then test := test & ((coup = GET_NTH_MOVE_OF_PACKED_GAME(s60, i,'DoBackMovePartieSelectionnee(1)')) | (coup = CaseSymetrique(GET_NTH_MOVE_OF_PACKED_GAME(s60, i,'DoBackMovePartieSelectionnee(2)'),axeSE_NW)))
		            else test := test & (coup = GET_NTH_MOVE_OF_PACKED_GAME(s60, i,'DoBackMovePartieSelectionnee(3)'));
		        end;
		      if test 
		        then 
		          begin
		            PartieContreMacDeBoutEnBout := false;
		            DoBackMove;
		          end
		        else
		          begin
		            anciennePositionCourante := jeuCourant;
		            couleurs := '';
		            
		            longueur := nroDernierCoupAtteint;
		            if longueur < 0  then longueur := 0;
		            if longueur > 60 then longueur := 60;
		            
		            FILL_PACKED_GAME_WITH_ZEROS(anciennePartie);
		            for i := 1 to longueur do
		              begin
		                SET_NTH_MOVE_OF_PACKED_GAME(anciennePartie, i, GetNiemeCoupPartieCourante(i));
		                if partie^^[i].trait = pionNoir 
		                  then couleurs := couleurs+StringOf('N') 
		                  else couleurs := couleurs+StringOf('B');
		              end;
		            SET_LENGTH_OF_PACKED_GAME(anciennePartie,longueur);
		            
		                 
		            MemoryFillChar(@Jeu,sizeof(jeu),chr(0));
		            for i := 0 to 99 do
		              if interdit[i] then jeu[i] := PionInterdit;
		            jeu[54] := pionNoir;
		            jeu[45] := pionNoir;
		            jeu[44] := pionBlanc;
		            jeu[55] := pionBlanc;
		            Coultrait := pionNoir; 
		            nbBlanc := 2;
		            nbNoir := 2;
		            
		            SetPositionInitialeStandardDansGameTree;
		            
		            InitialiseDirectionsJouables;
		            CarteJouable(jeu,jouable);
		            CarteFrontiere(Jeu,front); 
		            good := true;
		            
		            oldNode := GetCurrentNode();
		            SetCurrentNodeToGameRoot;
		            MarquerCurrentNodeCommeReel('DoBackMovePartieSelectionnee');
		            
		            for i := 1 to nbreCoup-1 do
		             begin
		              InvalidateNombrePartiesActivesDansLeCache(i);
		              coup := GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoBackMovePartieSelectionnee(4)');
		              good := good & (coup>=11) & (coup<=88);
		              if good then
		               if PeutJouerIci(Coultrait,coup,jeu)
		                then
		                 begin
		                  if JoueEnFictif(coup,Coultrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=nbreCoup-1),'DoBackMovePartieSelectionnee(5)') = NoErr then;
		                  good := ModifPlat(coup,Coultrait,jeu,jouable,nbblanc,nbNoir,front);
		                  coulTrait := -Coultrait;
		                 end
		                else
		                 begin
		                  if PeutJouerIci(-CoulTrait,coup,jeu)
		                    then
		                     begin
		                       Coultrait := -Coultrait;
		                       if JoueEnFictif(coup,Coultrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=nbreCoup-1),'DoBackMovePartieSelectionnee(6)') = NoErr then;
		                       good := ModifPlat(coup,Coultrait,jeu,jouable,nbblanc,nbNoir,front);
		                       Coultrait := -Coultrait;
		                     end
		                    else
		                     good := false;
		                 end;
		              end;       
		             if good then
		               begin
		                 SetPortByWindow(wPlateauPtr);
		                 jeuCourant := jeu;
		                 emplJouable := jouable;
		                 frontiereCourante := front;
		                 nbreDePions[pionBlanc] := nbBlanc;
		                 nbreDePions[pionNoir] := nbNoir;
		                 tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup].tempsUtilise.tempsNoir div 60;
		                 tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup].tempsUtilise.tempsNoir mod 60;
		                 tempsDesJoueurs[pionNoir].tick := 0;
		                 tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup].tempsUtilise.tempsBlanc div 60;
		                 tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup].tempsUtilise.tempsBlanc mod 60;
		                 tempsDesJoueurs[pionBlanc].tick := 0;
		                 IndexProchainFilsDansGraphe := -1;
		                 nbreCoup := nbreCoup-1;
		                 phaseDeLaPartie := CalculePhasePartie(nbreCoup);
		                 FixeMarqueSurMenuMode(nbreCoup);
		                 peutfeliciter := true;
		                (* if avecDessinCoupEnTete then EffaceCoupEnTete; 
		                 SetCoupEntete(0);*)
		                 
		                 
		                 EffaceAideDebutant(false,true,othellierToutEntier);
		                 ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
		                 EffaceProprietes(oldNode);
		                 if afficheNumeroCoup
		                   then EffaceNumeroCoup(GET_NTH_MOVE_OF_PACKED_GAME(anciennePartie, (nbreCoup+1),'DoBackMovePartieSelectionnee(7)'), nbreCoup+1, oldNode);
		                 DessinePion(GET_NTH_MOVE_OF_PACKED_GAME(s60, (nbreCoup+1),'DoBackMovePartieSelectionnee(8)'),pionVide);
		                 for i := 1 to 64 do
		                   begin
		                     t := othellier[i];
		                     if jeuCourant[t] <> pionVide then
		                       if jeuCourant[t]<>anciennePositionCourante[t] then
		                         DessinePion(t,jeuCourant[t]);
		                   end;
		                 if EnVieille3D() then Dessine3D(jeuCourant,false);
		                 if afficheNumeroCoup & (nbreCoup>0)
		                   then DessineNumeroCoup(DerniereCaseJouee(),nbreCoup,-jeuCourant[DerniereCaseJouee()],GetCurrentNode());
		                 
		                 gameOver := false;
		                 aQuiDeJouer := Coultrait;
		                 if (OthelloTorique & DoitPasserTore(aQuiDeJouer,jeuCourant)) |
		                    (not(OthelloTorique) & DoitPasser(aQuiDeJouer,jeuCourant,emplJouable)) then
		                   begin
		                     if (OthelloTorique & DoitPasserTore(-aQuiDeJouer,jeuCourant)) |
		                         (not(OthelloTorique) & DoitPasser(-aQuiDeJouer,jeuCourant,emplJouable))
		                       then TachesUsuellesPourGameOver
		                       else aQuiDeJouer := -aQuiDeJouer;
		                   end;
		                 AjusteCurseur;
		                 if OthelloTorique 
		                   then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
		                   else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
		                   
		                 PartieContreMacDeBoutEnBout := false;
		                 MetTitreFenetrePlateau;
		                 Initialise_table_heuristique(jeuCourant);
		                 meilleurCoupHum := 0;
		                 MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0)); 
		                 aideDebutant := false;  
		                 dernierTick := TickCount();  
		                 EssaieDisableForceCmd; 
		                 
		                 if EnModeEntreeTranscript() then EntrerPartieDansCurrentTranscript(nbreCoup);
		                 if afficheInfosApprentissage then EcritLesInfosDApprentissage;
		                 {la}
		                 
		                 EffacerTouteLaCourbe('DoBackMovePartieSelectionnee');
		                 DessineCourbe(0,nbreCoup,kCourbeColoree,'DoBackMovePartieSelectionnee');
		                 DessineSliderFenetreCourbe;
		                   
		                 AfficheScore;
		                 if (HumCtreHum | (aQuiDeJouer<>couleurMacintosh)) & not(demo) then
		                    begin
		                      MyDisableItem(PartieMenu,Forcecmd);
		                      AfficheDemandeCoup;
		                    end;
		                 if afficheMeilleureSuite then EffaceMeilleureSuite;
		                 if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
		                 
		                 jeu := jeuCourant;
		                 jouable := emplJouable;
		                 front := frontiereCourante;
		                 nbBlanc := nbreDePions[pionBlanc];
		                 nbNoir := nbreDePions[pionNoir];
		                 coultrait := aQuiDeJouer;
		                 
		                 
		                 GameNodeAAtteindre := GetCurrentNode();
		                 
		                 coup := GET_NTH_MOVE_OF_PACKED_GAME(s60, (nbreCoup+1),'DoBackMovePartieSelectionnee(10)');
		                 if JoueEnFictif(coup,coultrait,jeu,jouable,front,nbblanc,nbNoir,nbreCoup,true,true,'DoBackMovePartieSelectionnee(3)') = NoErr then;
		                 bidbool := ModifPlat(coup,coultrait,jeu,jouable,nbblanc,nbNoir,front);
		                 for i := nbreCoup+2 to GET_LENGTH_OF_PACKED_GAME(anciennePartie) do
		                   begin
		                     coup := GET_NTH_MOVE_OF_PACKED_GAME(anciennePartie, i,'DoBackMovePartieSelectionnee(11)');
		                     if couleurs[i]='B'
		                       then coultrait := pionBlanc
		                       else coultrait := pionNoir;
		                     if JoueEnFictif(coup,coultrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,true,'DoBackMovePartieSelectionnee(4)') = NoErr then;
		                     bidbool := ModifPlat(coup,coultrait,jeu,jouable,nbblanc,nbNoir,front);
		                   end;
		                 nroDernierCoupAtteint := GET_LENGTH_OF_PACKED_GAME(anciennePartie);
		                 FixeMarqueSurMenuMode(nbreCoup);
		                 DessineBoiteDeTaille(wPlateauPtr);
		                 gDoitJouerMeilleureReponse := false;
		                 if not(HumCtreHum) then
		                   begin
		                     reponsePrete := false;
		                     RefleSurTempsJoueur := false;
		                     LanceInterruption(interruptionSimple,'DoBackMovePartieSelectionnee');
		                     vaDepasserTemps := false;
		                   end;   
		                 
        
		                 AjusteCurseur;
		                 if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
		                    then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
		                
		                 DoChangeCurrentNodeBackwardUntil(GameNodeAAtteindre);
		                 MarquerCurrentNodeCommeReel('');
		                 AddRandomDeltaStoneToCurrentNode;
		                 ZebraBookDansArbreDeJeuCourant;
		                 AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoBackMovePartieSelectionnee');
		                 if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
		                 
		                 if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
                       QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
		           end;
		        end;
		     end;
		  end;
end;

procedure DoDoubleBackMovePartieSelectionnee(nroHilite : SInt32);
var s60,anciennePartie : PackedThorGame;
    couleurs : str60; 
    nroreference : SInt32;
    coup,i,t,longueur : SInt32;
    premierNumero,derniernumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    premierCoup,ancienNbreCoup : SInt16; 
    test,good,bidbool : boolean;
    jeu,anciennePositionCourante : plateauOthello;
    jouable : plBool;
    front : InfoFrontRec;
    nbBlanc,nbNoir : SInt32;
    CoulTrait,mobilite : SInt32;
    oldNode : GameTree;
    GameNodeAAtteindre : GameTree;
begin
 if windowPlateauOpen & not(enRetour | enSetUp) & windowListeOpen & not(Positionfeerique) & (nbreCoup>0) then
 if (nbreCoup=1) 
  then 
    DoBackMovePartieSelectionnee(nroHilite) 
  else
    with infosListeParties do
		  begin
		   GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);
		   {if (nroHilite>=premierNumero) & (nroHilite<=dernierNumero)
		    then}
		   if (nroHilite>=1) & (nroHilite<=nbPartiesActives) then
		     begin
		      nroReference := infosListeParties.dernierNroReferenceHilitee;
		      
		      ExtraitPartieTableStockageParties(nroReference,s60);
		      ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		      ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
		      TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie & ouvertureDiagonale & (nbreCoup>=4),1,60);
		      
		      if not(PositionsSontEgales(jeuCourant,CalculePositionApres(nbreCoup,s60))) then 
		        begin
		          WritelnDansRapport('WARNING : not(PositionsSontEgales(…) dans DoDoubleBackMovePartieSelectionnee');
		          with DemandeCalculsPourBase do
	              if (EtatDesCalculs<>kCalculsEnCours) | (NumeroDuCoupDeLaDemande<>nbreCoup) | bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	            InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
		          exit(DoDoubleBackMovePartieSelectionnee);
		        end;
		      
		      test := true;
		      for i := 1 to nbreCoup do
		        begin
		          coup := GetNiemeCoupPartieCourante(i);
		          {patch pour les diagonales avec l'autre coup 4}
		          if autreCoupQuatreDansPartie & ((i=1) | (i=3))
		            then test := test & ((coup = GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(1)')) | 
		                                 (coup = CaseSymetrique(GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(2)'),axeSE_NW)))
		            else test := test & (coup = GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(3)'));
		        end;
		      if test
		        then 
		          begin
		            PartieContreMacDeBoutEnBout := false;
		            DoDoubleBackMove;
		          end
		        else
		          begin
		            anciennePositionCourante := jeuCourant;
		            couleurs := '';
		            
		            longueur := nroDernierCoupAtteint;
		            if longueur < 0  then longueur := 0;
		            if longueur > 60 then longueur := 60;
		            
		            FILL_PACKED_GAME_WITH_ZEROS(anciennePartie);
		            for i := 1 to longueur do
		              begin
		                SET_NTH_MOVE_OF_PACKED_GAME(anciennePartie, i, GetNiemeCoupPartieCourante(i));
		                if partie^^[i].trait = pionNoir 
		                  then couleurs := couleurs+StringOf('N') 
		                  else couleurs := couleurs+StringOf('B');
		              end;
		            SET_LENGTH_OF_PACKED_GAME(anciennePartie,longueur);
		            
		            oldNode := GetCurrentNode();
		            SetCurrentNodeToGameRoot;
		            MarquerCurrentNodeCommeReel('');
		                 
		            MemoryFillChar(@Jeu,sizeof(jeu),chr(0));
		            for i := 0 to 99 do
		              if interdit[i] then jeu[i] := PionInterdit;
		            jeu[54] := pionNoir;
		            jeu[45] := pionNoir;
		            jeu[44] := pionBlanc;
		            jeu[55] := pionBlanc;
		            Coultrait := pionNoir; 
		            nbBlanc := 2;
		            nbNoir := 2;
		            SetPositionInitialeStandardDansGameTree;
		            InitialiseDirectionsJouables;
		            CarteJouable(jeu,jouable);
		            CarteFrontiere(Jeu,front); 
		            good := true;
		         
		            for i := 1 to nbreCoup-2 do
		             begin
		              InvalidateNombrePartiesActivesDansLeCache(i);
		              coup := GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(4)');
		              good := good & (coup>=11) & (coup<=88);
		              if good then
		               if PeutJouerIci(Coultrait,coup,jeu)
		                then
		                 begin
		                  if JoueEnFictif(coup,Coultrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=nbreCoup-2),'DoDoubleBackMovePartieSelectionnee(1)') = NoErr then;
		                  good := ModifPlat(coup,Coultrait,jeu,jouable,nbblanc,nbNoir,front);
		                  coulTrait := -Coultrait;
		                 end
		                else
		                 begin
		                  if PeutJouerIci(-CoulTrait,coup,jeu)
		                    then
		                     begin
		                       Coultrait := -Coultrait;
		                       if JoueEnFictif(coup,Coultrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=nbreCoup-2),'DoDoubleBackMovePartieSelectionnee(2)') = NoErr then;
		                       good := ModifPlat(coup,Coultrait,jeu,jouable,nbblanc,nbNoir,front);
		                       Coultrait := -Coultrait;
		                     end
		                    else
		                     good := false;
		                 end;
		              end;       
		             if good then
		               begin
		                 SetPortByWindow(wPlateauPtr);
		                 jeuCourant := jeu;
		                 emplJouable := jouable;
		                 frontiereCourante := front;
		                 nbreDePions[pionBlanc] := nbBlanc;
		                 nbreDePions[pionNoir] := nbNoir;
		                 ancienNbreCoup := nbreCoup;
		                 nbreCoup := nbreCoup-2;
		                 tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup+1].tempsUtilise.tempsNoir div 60;
		                 tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup+1].tempsUtilise.tempsNoir mod 60;
		                 tempsDesJoueurs[pionNoir].tick := 0;
		                 tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup+1].tempsUtilise.tempsBlanc div 60;
		                 tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup+1].tempsUtilise.tempsBlanc mod 60;
		                 tempsDesJoueurs[pionBlanc].tick := 0;
		                 IndexProchainFilsDansGraphe := -1;
		                 phaseDeLaPartie := CalculePhasePartie(nbreCoup);
		                 FixeMarqueSurMenuMode(nbreCoup);
		                 peutfeliciter := true;
		                (* if avecDessinCoupEnTete then EffaceCoupEnTete;
		                 SetCoupEntete(0);*)
		                 
		                 
		                 EffaceAideDebutant(false,true,othellierToutEntier);
		                 ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
		                 EffaceProprietes(oldNode);
		                 if afficheNumeroCoup
		                   then EffaceNumeroCoup(GET_NTH_MOVE_OF_PACKED_GAME(anciennePartie,ancienNbreCoup,'DoDoubleBackMovePartieSelectionnee(5)'),ancienNbreCoup,oldNode);
		                 for i := nbreCoup+1 to ancienNbreCoup do
		                   DessinePion(GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(6)'),pionVide);
		                 for i := 1 to 64 do
		                   begin
		                     t := othellier[i];
		                     if jeuCourant[t] <> pionVide then
		                       if jeuCourant[t]<>anciennePositionCourante[t] then
		                         DessinePion(t,jeuCourant[t]);
		                   end;
		                 if EnVieille3D() then Dessine3D(jeuCourant,false);
		                 if afficheNumeroCoup & (nbreCoup>0)
		                   then DessineNumeroCoup(DerniereCaseJouee(),nbreCoup,-jeuCourant[DerniereCaseJouee()],GetCurrentNode());
		                 
		                 gameOver := false;
		                 aQuiDeJouer := Coultrait;
		                 if (OthelloTorique & DoitPasserTore(aQuiDeJouer,jeuCourant)) |
		                    (not(OthelloTorique) & DoitPasser(aQuiDeJouer,jeuCourant,emplJouable)) then
		                   begin
		                     if (OthelloTorique & DoitPasserTore(-aQuiDeJouer,jeuCourant)) |
		                         (not(OthelloTorique) & DoitPasser(-aQuiDeJouer,jeuCourant,emplJouable))
		                       then TachesUsuellesPourGameOver
		                       else aQuiDeJouer := -aQuiDeJouer;
		                   end;
		                 AjusteCurseur;
		                 if OthelloTorique 
		                   then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
		                   else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
		                   
		                 PartieContreMacDeBoutEnBout := false;
		                 MetTitreFenetrePlateau;
		                 Initialise_table_heuristique(jeuCourant);
		                 meilleurCoupHum := 0;
		                 MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0)); 
		                 aideDebutant := false;  
		                 dernierTick := TickCount();  
		                 EssaieDisableForceCmd; 
		                 
		                 if EnModeEntreeTranscript() then EntrerPartieDansCurrentTranscript(nbreCoup);
		                 if afficheInfosApprentissage then EcritLesInfosDApprentissage;
		                 {la}
		                 
		                 EffacerTouteLaCourbe('DoDoubleBackMovePartieSelectionnee');
		                 DessineCourbe(0,nbreCoup,kCourbeColoree,'DoDoubleBackMovePartieSelectionnee');
		                 DessineSliderFenetreCourbe;
		                 
		                 AfficheScore;
		                 if (HumCtreHum | (aQuiDeJouer<>couleurMacintosh)) & not(demo) then
		                    begin
		                      MyDisableItem(PartieMenu,Forcecmd);
		                      AfficheDemandeCoup;
		                    end;
		                 if afficheMeilleureSuite then EffaceMeilleureSuite;
		                 if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
		                 
		                 GameNodeAAtteindre := GetCurrentNode();
		                 
		                 jeu := jeuCourant;
		                 jouable := emplJouable;
		                 front := frontiereCourante;
		                 nbBlanc := nbreDePions[pionBlanc];
		                 nbNoir := nbreDePions[pionNoir];
		                 coultrait := aQuiDeJouer;
		                 
		                 
		                 for i := nbreCoup+1 to ancienNbreCoup do
		                   begin
		                     coup := GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(7)');
		                     if couleurs[i]='B'
		                       then coultrait := pionBlanc
		                       else coultrait := pionNoir;
		                     if JoueEnFictif(coup,coultrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=ancienNbreCoup),'DoDoubleBackMovePartieSelectionnee(3)') = NoErr then;
		                     bidbool := ModifPlat(coup,coultrait,jeu,jouable,nbblanc,nbNoir,front);
		                   end;
		                 for i := ancienNbreCoup+1 to GET_LENGTH_OF_PACKED_GAME(anciennePartie) do
		                   begin
		                     coup := GET_NTH_MOVE_OF_PACKED_GAME(anciennePartie,i,'DoDoubleBackMovePartieSelectionnee(8)');
		                     if couleurs[i]='B'
		                       then coultrait := pionBlanc
		                       else coultrait := pionNoir;
		                     if JoueEnFictif(coup,coultrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=GET_LENGTH_OF_PACKED_GAME(anciennePartie)),'DoDoubleBackMovePartieSelectionnee(4)') = NoErr then;
		                     bidbool := ModifPlat(coup,coultrait,jeu,jouable,nbblanc,nbNoir,front);
		                   end;
		                 nroDernierCoupAtteint := GET_LENGTH_OF_PACKED_GAME(anciennePartie);
		                 FixeMarqueSurMenuMode(nbreCoup);
		                 DessineBoiteDeTaille(wPlateauPtr);
		                 gDoitJouerMeilleureReponse := false;
		                 if not(HumCtreHum) then
		                   begin
		                     reponsePrete := false;
		                     RefleSurTempsJoueur := false;
		                     LanceInterruption(interruptionSimple,'DoDoubleBackMovePartieSelectionnee');
		                     vaDepasserTemps := false;
		                   end;   
		                 
        
		                 AjusteCurseur;
		                 
		                 if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
		                   then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
		                 
		                 
		                 DoChangeCurrentNodeBackwardUntil(GameNodeAAtteindre);
		                 MarquerCurrentNodeCommeReel('');
		                 AddRandomDeltaStoneToCurrentNode;
		                 ZebraBookDansArbreDeJeuCourant;
		                 AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoDoubleBackMovePartieSelectionnee');
		                 if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
		                 
		                 if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
                       QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
		           end;
		        end;
		     end;
     end;
end;

procedure DoDoubleAvanceMovePartieSelectionnee(nroHilite : SInt32);
var s60 : PackedThorGame;
    nroreference,i : SInt32;
    premierNumero,derniernumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    premierCoup,coup : SInt16; 
    test : boolean;
begin
 if windowPlateauOpen & not(enRetour | enSetUp) then
 if windowListeOpen & not(Positionfeerique) then
   with infosListeParties do
	   begin
	     GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,DernierNumero);
	     {if (nroHilite>=premierNumero) & (nroHilite<=dernierNumero) then}
	     if (nroHilite>=1) & (nroHilite<=nbPartiesActives) then
	       begin
	         nroReference := infosListeParties.dernierNroReferenceHilitee;
		      
		       ExtraitPartieTableStockageParties(nroReference,s60);
		       ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		       ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
		       TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie & ouvertureDiagonale & (nbreCoup>=4),1,60);
		      
		       if not(PositionsSontEgales(jeuCourant,CalculePositionApres(nbreCoup,s60))) then 
		        begin
		          WritelnDansRapport('WARNING : not(PositionsSontEgales(…) dans DoDoubleAvanceMovePartieSelectionnee');
		          with DemandeCalculsPourBase do
	              if (EtatDesCalculs<>kCalculsEnCours) | (NumeroDuCoupDeLaDemande<>nbreCoup) | bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	            InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
		          exit(DoDoubleAvanceMovePartieSelectionnee);
		        end;
		         
	         test := (nroDernierCoupAtteint >= (nbreCoup+2)); 
	         for i := nbreCoup+1 to nbreCoup+2 do
	           begin
	             coup := GetNiemeCoupPartieCourante(i);
		           {patch pour les diagonales avec l'autre coup 4}
		           if autreCoupQuatreDansPartie & ((i=1) | (i=3))
		             then test := test & ((coup=GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleAvanceMovePartieSelectionnee(1)')) | (coup=CaseSymetrique(GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleAvanceMovePartieSelectionnee(2)'),axeSE_NW)))
		             else test := test & (coup=GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleAvanceMovePartieSelectionnee(3)'));
		         end;
	         if test
	           then 
	             DoDoubleAvanceMove
	           else
	             begin
	               JoueCoupPartieSelectionnee(nroHilite);
	               JoueCoupPartieSelectionnee(nroHilite);
	             end;
	        end;
	   end;
end;


procedure DoRetourAuCoupNro(numeroCoup : SInt32;NeDessinerQueLesNouveauxPions,ForceHumCtreHum : boolean);
var i,j : SInt32;
    mobilite : SInt32;
    oldport : grafPtr;
    AnciensPionsDessines : plateauOthello;
begin
  if windowPlateauOpen then
  begin
    GetPort(oldport);
    SetPortByWindow(wPlateauPtr);
    if nbreCoup > numeroCoup then
     begin
      EffaceAideDebutant(false,true,othellierToutEntier);
      ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
      EffaceProprietesOfCurrentNode;
      
      AnciensPionsDessines := jeuCourant;
      repeat
        if DerniereCaseJouee() <> coupInconnu then
         begin
           with partie^^[nbreCoup] do
           begin
             jeuCourant[DerniereCaseJouee()] := pionVide;
             for i := 1 to nbRetourne do
               begin
                 jeuCourant[retournes[i]] := -jeuCourant[retournes[i]];
               end;
             nbreDePions[trait] := nbreDePions[trait]-nbretourne-1;
             nbreDePions[-trait] := nbreDePions[-trait]+nbretourne;               
             aQuiDeJouer := trait;  
           end;
           {
           with partie^^[nbreCoup] do
           begin
             trait := 0;
             x := coupInconnu;
             nbretourne := 0;
           end;
           }
           IndexProchainFilsDansGraphe := -1;
           nbreCoup := nbreCoup-1;
           
           ChangeCurrentNodeForBackMove;
           MarquerCurrentNodeCommeReel('');
           
         end;
       until (nbreCoup=numeroCoup) | (DerniereCaseJouee() = coupInconnu);
       tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup+1].tempsUtilise.tempsNoir div 60;
       tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup+1].tempsUtilise.tempsNoir mod 60;
       tempsDesJoueurs[pionNoir].tick := 0;
       tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup+1].tempsUtilise.tempsBlanc div 60;
       tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup+1].tempsUtilise.tempsBlanc mod 60;
       tempsDesJoueurs[pionBlanc].tick := 0;
       AjusteCurseur;
       EnableItemPourCassio(PartieMenu,ForwardCmd);
       meilleurCoupHum := 44;
       meilleureReponsePrete := 44;
       gDoitJouerMeilleureReponse := false;
       if windowPlateauOpen then
         begin
           if NeDessinerQueLesNouveauxPions & not(CassioEstEn3D())
             then
               begin
                 SetPortByWindow(wPlateauPtr);
                 for i := 1 to 8 do
                   for j := 1 to 8 do
                     if AnciensPionsDessines[10*i+j]<>jeuCourant[10*i+j] then
                       DessinePion(10*i+j,jeuCourant[10*i+j]);
                 DessineGarnitureAutourOthellierPourEcranStandard;
                 if afficheNumeroCoup then
                   begin
                     if (nbreCoup>0) & (DerniereCaseJouee() <> coupInconnu) & InRange(DerniereCaseJouee(),11,88)
                       then DessineNumeroCoup(DerniereCaseJouee(),nbreCoup,-jeuCourant[DerniereCaseJouee()],GetCurrentNode());
                   end;
               end
             else
               begin
                 EcranStandard(NIL,CassioEstEn3D())
               end; 
         end;
       if afficheInfosApprentissage then EcritLesInfosDApprentissage;
       
       
       {la}
       if not(HumCtreHum) & not(CassioEstEnModeSolitaire()) & ForceHumCtreHum
         then DoChangeHumCtreHum;
       EffaceCourbe(nbreCoup,61,kCourbePastel,'DoRetourAuCoupNro');
       DessineSliderFenetreCourbe;
       if afficheMeilleureSuite then EffaceMeilleureSuite;
       if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
       InitialiseDirectionsJouables;
       CarteJouable(jeuCourant,emplJouable);
       CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
       CarteFrontiere(jeuCourant,frontiereCourante);   
       Initialise_table_heuristique(jeuCourant); 
       RefleSurTempsJoueur := false;
       LanceInterruption(interruptionSimple,'DoRetourAuCoupNro');
       vaDepasserTemps := false;
       reponsePrete := false;
       peutfeliciter := true;
       TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'DoRetourAuCoupNro');
      (* if avecDessinCoupEnTete then EffaceCoupEnTete;
       SetCoupEntete(0);*)
       PartieContreMacDeBoutEnBout := (numeroCoup <= 2);
       gameOver := false;
       MetTitreFenetrePlateau;
       phaseDeLaPartie := CalculePhasePartie(nbreCoup);
       FixeMarqueSurMenuMode(nbreCoup);
       EssaieDisableForceCmd;
       enRetour := false;
       dernierTick := TickCount();
       Heure(-aQuiDeJouer);
       Heure(aQuiDeJouer);
       
        
       AjusteCurseur;
       AddRandomDeltaStoneToCurrentNode;
       ZebraBookDansArbreDeJeuCourant;
       AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoRetourAuCoupNro');
       if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
       
       if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
         then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
       
       if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
         QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
                 
    end;
   SetPort(oldport);
  end;
end;

procedure DoAvanceAuCoupNro(numeroCoup : SInt16; neDessinerQueLesNouveauxPions : boolean);
var i,j,coup,Coultrait : SInt16; 
    anciensPionsDessines : plateauOthello;
    ancienNbreCoup : SInt16; 
    oldport : grafPtr;
    jeu : plateauOthello;
    jouable : plBool;
    front : InfoFrontRec;
    nbBlanc,nbNoir : SInt32;
    good : boolean;
    mobilite : SInt32;
    oldCurrentNodeInGameTree : GameTree;
begin

  if (numeroCoup <= 0)
    then WritelnStringAndNumDansRapport('ASSERT : (numeroCoup <= 0) in DoAvanceAuCoupNro, value is ', numeroCoup);


  if (numeroCoup >= nbreCoup) & (numeroCoup <= nroDernierCoupAtteint) then
    begin
     anciensPionsDessines := jeuCourant;
     ancienNbreCoup := nbreCoup;
     jeu := jeuCourant;
     jouable := emplJouable;
     front := frontiereCourante;
     nbBlanc := nbreDePions[pionBlanc];
     nbNoir := nbreDePions[pionNoir];
     good := true;
     
     oldCurrentNodeInGameTree := GetCurrentNode();
     
     for i := nbreCoup+1 to numeroCoup do
       begin
        coup := GetNiemeCoupPartieCourante(i);
        Coultrait := partie^^[i].trait;
        if good then
          if PeutJouerIci(Coultrait,coup,jeu)
            then
              begin
                if JoueEnFictif(coup,Coultrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=numeroCoup),'DoAvanceAuCoupNro') = NoErr then;
                good := ModifPlat(coup,Coultrait,jeu,jouable,nbblanc,nbNoir,front);
              end
            else
              begin
                good := false;
              end;
       end;
       
       
     if good then
       begin
         EffaceAideDebutant(false,true,othellierToutEntier);
         ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
         
         jeuCourant := jeu;
         emplJouable := jouable;
         frontiereCourante := front;
         nbreDePions[pionBlanc] := nbBlanc;
         nbreDePions[pionNoir] := nbNoir;
         nbreCoup := numeroCoup;
         IndexProchainFilsDansGraphe := -1;
         phaseDeLaPartie := CalculePhasePartie(nbreCoup);
         FixeMarqueSurMenuMode(nbreCoup);
         peutfeliciter := true;
        (* if avecDessinCoupEnTete then EffaceCoupEnTete;
         SetCoupEntete(0);*)
         
         gameOver := false;
         aQuiDeJouer := -partie^^[nbreCoup].trait;
         if (OthelloTorique & DoitPasserTore(aQuiDeJouer,jeuCourant)) |
            (not(OthelloTorique) & DoitPasser(aQuiDeJouer,jeuCourant,emplJouable)) then
           begin
             if (OthelloTorique & DoitPasserTore(-aQuiDeJouer,jeuCourant)) |
                 (not(OthelloTorique) & DoitPasser(-aQuiDeJouer,jeuCourant,emplJouable))
               then TachesUsuellesPourGameOver
               else aQuiDeJouer := -aQuiDeJouer;
           end;
         if OthelloTorique 
           then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
           else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
         MetTitreFenetrePlateau;
         
         Initialise_table_heuristique(jeuCourant);
         meilleurCoupHum := 0;
         MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0)); 
         aideDebutant := false;  
         dernierTick := TickCount();  
         EssaieDisableForceCmd; 
         if windowPlateauOpen then
           begin
             EffaceProprietes(oldCurrentNodeInGameTree);
             if NeDessinerQueLesNouveauxPions & not(EnVieille3D())
               then
                 begin
                   GetPort(oldport);
                   SetPortByWindow(wPlateauPtr);
                   if afficheNumeroCoup  & (ancienNbreCoup>0) & 
                      (GetNiemeCoupPartieCourante(ancienNbreCoup) <> coupInconnu) & 
                      InRange(GetNiemeCoupPartieCourante(ancienNbreCoup),11,88) then 
                      EffaceNumeroCoup(GetNiemeCoupPartieCourante(ancienNbreCoup),ancienNbreCoup,oldCurrentNodeInGameTree);
                   for i := 1 to 8 do
                     for j := 1 to 8 do
                       if AnciensPionsDessines[10*i+j]<>jeuCourant[10*i+j] then
                         DessinePion(10*i+j,jeuCourant[10*i+j]);
                   DessineGarnitureAutourOthellierPourEcranStandard;
                   if afficheNumeroCoup  & (nbreCoup>0) & 
                      (DerniereCaseJouee() <> coupInconnu) & 
                      InRange(DerniereCaseJouee(),11,88) then 
                      DessineNumeroCoup(DerniereCaseJouee(),nbreCoup,-jeuCourant[DerniereCaseJouee()],GetCurrentNode());
                   SetPort(oldPort);
                 end
               else
                 begin
                   EcranStandard(NIL,EnVieille3D());
                   NoUpdateWindowPlateau;
                 end;
           end;
         if afficheInfosApprentissage then EcritLesInfosDApprentissage;
         {la}
         
         EffacerTouteLaCourbe('DoAvanceAuCoupNro');
         DessineCourbe(ancienNbreCoup,nbreCoup,kCourbeColoree,'DoAvanceAuCoupNro');
         DessineSliderFenetreCourbe;
         
         DessineBoiteDeTaille(wPlateauPtr);
         AjusteCurseur;
         gDoitJouerMeilleureReponse := false;
         PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
         if (numeroCoup < nroDernierCoupAtteint)
           then EnableItemPourCassio(PartieMenu,ForwardCmd)
           else MyDisableItem(PartieMenu,ForwardCmd);
         EnableItemPourCassio(PartieMenu,BackCmd);
         if not(HumCtreHum) then
           begin
             reponsePrete := false;
             RefleSurTempsJoueur := false;
             LanceInterruption(interruptionSimple,'DoAvanceAuCoupNro');
             vaDepasserTemps := false;
           end;   
         enRetour := false;
         
         AddRandomDeltaStoneToCurrentNode;
         ZebraBookDansArbreDeJeuCourant;
         AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoAvanceAuCoupNro');
         if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
         
         if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
           QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
                 
         if (windowListeOpen | windowStatOpen)
           then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
      end;
   end;
end;

procedure DoRetourDerniereMarque;
var i,maximum : SInt16; 
begin
 if windowPlateauOpen & not(enRetour | enSetUp) then
  if (nbreCoup>0) then
   begin
    maximum := -100;
    for i := 1 to marques[0] do
      if (marques[i]>maximum) & (marques[i]<nbreCoup) then 
        maximum := marques[i];
    if (NbreCoupsApresLecture>0) & not(positionfeerique) then
      if (NbreCoupsApresLecture>maximum) & (NbreCoupsApresLecture<nbreCoup) then
        maximum := NbreCoupsApresLecture;
    if (maximum<=0)
      then DoDebut(false)
      else
        if (maximum<nbreCoup)
         then DoRetourAuCoupNro(maximum,true,true)
         else DoDebut(false);
   end;
end;

procedure DoAvanceProchaineMarque;
var i,maximum : SInt32;
begin
 if windowPlateauOpen & not(enRetour | enSetUp) then
  if (nbreCoup < nroDernierCoupAtteint) then
   begin
    maximum := 1000;
    for i := 1 to marques[0] do
      if (marques[i] < maximum) & (marques[i] > nbreCoup) then 
        maximum := marques[i];
    if (NbreCoupsApresLecture > 0) & not(positionfeerique) then
      if (NbreCoupsApresLecture < maximum) & (NbreCoupsApresLecture > nbreCoup) then
        maximum := NbreCoupsApresLecture;
    if maximum > nroDernierCoupAtteint then maximum := nroDernierCoupAtteint;
    if (maximum > nbreCoup)
      then DoAvanceAuCoupNro(maximum,true)
   end;
end;


procedure DoAvanceProchainEmbranchement;
var i,k,nroCoupEmbranchement : SInt32;
    EmbranchementTrouve : boolean;
    nbrePartiesSuivies : SInt32;
begin
  if windowPlateauOpen & not(enRetour | enSetUp) then
    if not(gameOver) then
      with infosListeParties do
      begin
        EmbranchementTrouve := false;
        nroCoupEmbranchement := -1;
        if windowListeOpen | windowListeOpen then
          if (nbPartiesChargees>0) & (nbPartiesActives>=1) then
            if CoupSuivantPartieSelectionnee(partieHilitee)=GetNiemeCoupPartieCourante(nbreCoup+1) then
              begin
                i := nbreCoup+1;
                nbrePartiesSuivies := GetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup);
                
                if debuggage.general then
                  begin
                    EssaieSetPortWindowPlateau;
                    WriteStringAndNumAt('nbreCoup=',nbreCoup,200,10);
                    WriteStringAndNumAt('nbrePartiesSuivies=',nbrePartiesSuivies,200,20);
                    for k := 0 to 60 do
                    begin
                      EssaieSetPortWindowPlateau;
                      WriteStringAndNumAt('k=',k,10,10+10*k);
                      WriteStringAndNumAt('n[k]=',GetNombreDePartiesActivesDansLeCachePourCeCoup(k),50,10+10*k);
                    end;
                    AttendFrappeClavier;
                  end;
                
                if (nbrePartiesSuivies <> NeSaitPasNbrePartiesActives) then
                  repeat
                    if GetNombreDePartiesActivesDansLeCachePourCeCoup(i) <> nbrePartiesSuivies then
                      begin
                        EmbranchementTrouve := true;
                        nroCoupEmbranchement := i-1;
                      end;
                    i := i+1;
                  until EmbranchementTrouve | (i > nroDernierCoupAtteint);
                if (i > nroDernierCoupAtteint) & not(EmbranchementTrouve) then
                  begin
                    EmbranchementTrouve := true;
                    nroCoupEmbranchement := nroDernierCoupAtteint;
                  end;
                  
              end;
        if not(EmbranchementTrouve) | (nroCoupEmbranchement<=nbreCoup+1) | (nroCoupEmbranchement=2)
          then 
            if windowlisteOpen & (nbPartiesActives >= 1)
              then JoueCoupPartieSelectionnee(partieHilitee)
              else DoAvanceMove
          else 
            if nroCoupEmbranchement=nbreCoup-2
              then DoDoubleAvanceMove
              else DoAvanceAuCoupNro(nroCoupEmbranchement,true);
      end;
end;


procedure DoRetourDernierEmbranchement;
var i,k,nroCoupEmbranchement : SInt32;
    EmbranchementTrouve : boolean;
    nbrePartiesSuivies : SInt32;
begin
  if windowPlateauOpen & not(enRetour | enSetUp) then
    if (nbreCoup>0) then
      begin
        EmbranchementTrouve := false;
        nroCoupEmbranchement := -1;
        if windowListeOpen | windowListeOpen then
          if (nbPartiesChargees>0) then
            begin
            
              i := nbreCoup-1;
              nbrePartiesSuivies := GetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup);
            
              if debuggage.general then
                  begin
                    EssaieSetPortWindowPlateau;
                    WriteStringAndNumAt('nbreCoup=',nbreCoup,200,10);
                    WriteStringAndNumAt('nbrePartiesSuivies=',nbrePartiesSuivies,200,20);
                    for k := 0 to 60 do
                    begin
                      EssaieSetPortWindowPlateau;
                      WriteStringAndNumAt('k=',k,10,10+10*k);
                      WriteStringAndNumAt('n[k]=',GetNombreDePartiesActivesDansLeCachePourCeCoup(k),50,10+10*k);
                    end;
                    AttendFrappeClavier;
                  end;
            
              
              if (nbrePartiesSuivies <> NeSaitPasNbrePartiesActives) then
                repeat
                  if (GetNombreDePartiesActivesDansLeCachePourCeCoup(i) <> nbrePartiesSuivies) then
                    begin
                      EmbranchementTrouve := true;
                      nroCoupEmbranchement := i;
                    end;
                  i := i-1;
                until EmbranchementTrouve | (i<0);
              if (i<0) & not(EmbranchementTrouve) then
                  begin
                    EmbranchementTrouve := true;
                    nroCoupEmbranchement := 0;
                  end;
            end;
        if not(EmbranchementTrouve) | (nroCoupEmbranchement = nbreCoup-1) 
          then DoBackMove
          else if nroCoupEmbranchement = nbreCoup-2
	              then DoDoubleBackMove
	              else DoRetourAuCoupNro(nroCoupEmbranchement,true,true);
      end;
end;


procedure DetruitSousArbreCourantEtBackMove;
var whichSon : GameTree;
begin
  whichSon := GetCurrentNode();
  DoBackMove;
  EffaceProprietesOfCurrentNode;
  DeleteThisSon(GetCurrentNode(),whichSon);
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
  AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DetruitDernierCoupEtBackMove');
  GarbageCollectionDansTableHashageInterversions;
end;


procedure DoDialogueDetruitSousArbreCourant;
const DestructionDialogueID=155;
      OK=1;
      Annuler=2;
var dp : DialogPtr;
    itemHit : SInt16; 
    destructionRadios : RadioRec;
    whichSon : GameTree;
    err : OSErr;
begin
  destructionRadios := NewRadios(kDetruireCeNoeudEtFils,kDetruireLesFils,TypeDerniereDestructionDemandee);
  itemHit := Annuler;
  BeginDialog;
  dp := MyGetNewDialog(DestructionDialogueID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      MyDrawDialog(dp);            
      InitRadios(dp,destructionRadios);
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
        if InRange(ItemHit,destructionRadios.firstButton,destructionRadios.lastButton) then 
          PushRadio(dp,destructionRadios,ItemHit);
      until (itemHit=OK) | (itemHit=Annuler);
      MyDisposeDialog(dp);
    end;
  EndDialog;
  
  TypeDerniereDestructionDemandee := destructionRadios.selection;
  if (itemHit=OK) then
    begin
      EffaceProprietesOfCurrentNode;
      case TypeDerniereDestructionDemandee of
        kDetruireCeNoeudEtFils: 
          if PeutReculerUnCoup() & PeutArreterAnalyseRetrograde()
            then
              begin
                whichSon := GetCurrentNode();
                DoBackMove;
                EffaceProprietesOfCurrentNode;
                DeleteThisSon(GetCurrentNode(),whichSon);
              end
            else
              DeleteAllSons(GetCurrentNode());
        kDetruireLesFils:
          DeleteAllSons(GetCurrentNode());
      end; {case}
      
      DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
      AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DoDialogueDetruitSousArbreCourant');
      
      if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
        QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
                 
      GarbageCollectionDansTableHashageInterversions;
    end;
  SetNiveauTeteDeMort(0);
end;



procedure DoTraiteBaseDeDonnee;
var bidbool,doitRejouerLaPartie,test : boolean;
    s : str255;
    platAux : plateauOthello;
    trait : SInt16; 
    coup,i,k,nbPartiesDansListe,indexDepart : SInt32;
    gameNodeLePlusProfond : GameTree;
begin  

  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('entree dans DoTraiteBaseDeDonnee',true); 

 if avecGestionBase then
  begin
    if problemeMemoireBase
      then 
        DialogueMemoireBase
      else
        begin
        
          if (InfosFichiersNouveauFormat.nbFichiers <= 0) then
            begin
              watch := GetCursor(watchcursor);
              SafeSetCursor(watch);
              LecturePreparatoireDossierDatabase(volumeRefCassio);
              DoLectureJoueursEtTournoi(false);
              AjusteCurseur;
            end;
        
          DerniereChaineComplementation^^ := '@&µôπ¶«Ç‘';
          if ActionBaseDeDonnee(BaseLectureCriteres,s) then
            begin
              
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('apres ActionBaseDeDonnee dans DoTraiteBaseDeDonnee',true);

              
              InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
              nbreCoupsApresLecture := Length(s) div 2;
              EnableItemPourCassio(BaseMenu,CriteresCmd);
              EnableItemPourCassio(BaseMenu,SousSelectionActiveCmd);
              
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('apres EnableItemPourCassio dans DoTraiteBaseDeDonnee',true);
              
              if not(positionLectureModifiee)
                then 
                   begin
                     if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
                        then 
                          begin
                            EcritRubanListe(false);
                            LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);  
                          end;
                     if not(HumCtreHum) & (nbreCoup<=0) & not(CassioEstEnModeAnalyse()) then DoChangeHumCtreHum;
                   end
                 else
                   begin
                     if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant DetruitMeilleureSuite dans DoTraiteBaseDeDonnee',true);
                     
                     DetruitMeilleureSuite;
                     EffaceMeilleureSuite;
                     CommentaireSolitaire^^ := '';
                     finaleEnModeSolitaire := false;
                     doitRejouerLaPartie := true;
                     if not(positionfeerique) & (nbreCoupsApresLecture<=nbreCoup) then
                       begin
                         test := true;
                         for i := 1 to nbreCoupsApresLecture do
                           begin
                             coup := PositionDansStringAlphaEnCoup(s,2*i-1);
                             test := test & (coup=GetNiemeCoupPartieCourante(i));
                           end;
                         doitRejouerLaPartie := not(test);
                       end;
                    if positionfeerique 
                      then
                        begin
                          NoUpdateWindowPlateau;
                          trait := pionNoir;
                          RejouePartieOthello(s,nbreCoupsApresLecture,true,platAux,trait,gameNodeLePlusProfond,true,true);
                        end
                      else
                        begin
                         if doitRejouerLaPartie & (nbreCoupsApresLecture > 0)
                           then
                             begin
                               if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant NoUpdateWindowPlateau dans DoTraiteBaseDeDonnee',true);
                               
                               NoUpdateWindowPlateau;
                               if odd(nbreCoupsApresLecture) 
                                 then trait := pionBlanc
                                 else trait := pionNoir;
                               
                               if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant RejouePartieOthello dans DoTraiteBaseDeDonnee',true);
                      
                                 
                               RejouePartieOthello(s,nbreCoupsApresLecture,true,platAux,trait,gameNodeLePlusProfond,false,true);
                             end
                           else
                             begin
                               if nbreCoupsApresLecture<nbreCoup then NoUpdateWindowPlateau;
                               
                               if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant DoRetourAuCoupNro dans DoTraiteBaseDeDonnee',true);
                               
                               DoRetourAuCoupNro(nbreCoupsApresLecture,false,not(CassioEstEnModeAnalyse()));
                             end;
                        end;
                     
                     if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant DoChangeHumCtreHum dans DoTraiteBaseDeDonnee',true);
                     
                     if not(HumCtreHum) & not(CassioEstEnModeAnalyse()) then DoChangeHumCtreHum;
                   end;
                         
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant "on sait sans avoir à les compter…" dans DoTraiteBaseDeDonnee',true); 
              
              {on sait sans avoir besoin de les calculer les parties compatibles des coups précédents}
              if avecCalculPartiesActives & (windowListeOpen | windowStatOpen) then 
                begin
                  nbPartiesDansListe := GetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup);
                  if (nbPartiesDansListe <> PasDePartieActive) & 
                     (nbPartiesDansListe <> NeSaitPasNbrePartiesActives) then
                    for i := 0 to nbreCoup-1 do
                      begin
                        SetNombreDePartiesActivesDansLeCachePourCeCoup(i,nbPartiesDansListe);
                        if ListePartiesEstGardeeDansLeCache(i,nbPartiesDansListe) then
                          begin
                            indexDepart := IndexInfoDejaCalculeesCoupNro^^[i-1];
                            for k := 1 to nbPartiesDansListe do
                              TableInfoDejaCalculee^^[indexDepart+k] := tableNumeroReference^^[k];
                          end;
                      end;
                 end;
              
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant derniereChaineComplementation dans DoTraiteBaseDeDonnee',true); 
              
              DerniereChaineComplementation^^ := '@&µôπ¶«Ç‘';
            end;
          
          
          if not(problemeMemoireBase) & not(JoueursEtTournoisEnMemoire)
            then 
              begin
                if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant if not(enSetUp) dans DoTraiteBaseDeDonnee',true); 

                if not(enSetUp) then
                   begin
                     if HasGotEvent(updateMask,theEvent,0,NIL) then 
                        TraiteOneEvenement;
                   end;
                
                if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant bidbool := ActionBaseDeDonnee(BaseLectureJoueursEtTournois,s); dans DoTraiteBaseDeDonnee',true); 

                bidbool := ActionBaseDeDonnee(BaseLectureJoueursEtTournois,s);
                if windowListeOpen & (nbPartiesChargees>0) & JoueursEtTournoisEnMemoire then
                  begin
                    EcritRubanListe(true);
                    WritelnDansRapport('qu''est-ce que ca change ?');
                    EcritListeParties(false,'DoTraiteBaseDeDonnees');
                  end;
              end;
          
          if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant DessineBoiteDeTaille dans DoTraiteBaseDeDonnee',true); 

          if windowListeOpen then DessineBoiteDeTaille(wListePtr);
          
        end;
   end;
 
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('sortie de DoTraiteBaseDeDonnee',true); 

end;


procedure DoChargerLaBase;
  begin
    DoTraiteBaseDeDonnee;
  end;

procedure DoDemandeAnalyseRetrograde(sansDialogueRetrograde : boolean);
begin
  if not(analyseRetrograde.enCours) & (nroDernierCoupAtteint >= 20) then
    if sansDialogueRetrograde | DoDialogueRetrograde(false) then
      begin
        LanceInterruption(kHumainVeutAnalyserFinale,'DoDemandeAnalyseRetrograde');
        if not(HumCtreHum) then
          begin
            reponsePrete := false;
            RefleSurTempsJoueur := false;
            vaDepasserTemps := false;
          end;   
      end;
end;

procedure DoParametrerAnalyseRetrograde;
var bidon : boolean;
begin
  if not(analyseRetrograde.enCours) then
    begin
      if (nroDernierCoupAtteint >= 20)
        then DoDemandeAnalyseRetrograde(false)
        else bidon := DoDialogueRetrograde(true);
    end;
end;

procedure DoChangeAfficheDernierCoup;
var oldport : grafPtr;
    a : SInt16; 
begin
  afficheNumeroCoup := not(afficheNumeroCoup);
  if windowPlateauOpen & (nbreCoup>0) then
     begin
       GetPort(oldport);
       SetPortByWindow(wPlateauPtr);
       a := DerniereCaseJouee();
       if (a <> coupInconnu) & InRange(a,11,88) then 
         if afficheNumeroCoup
           then DessineNumeroCoup(a,nbreCoup,-jeuCourant[a],GetCurrentNode())
           else 
             begin
               if affichePierresDelta then EffacePierresDelta(GetCurrentNode());
               EffaceNumeroCoup(a,nbreCoup,GetCurrentNode());
               if affichePierresDelta then AfficheProprietesOfCurrentNode(true,{[a]}othellierToutEntier,'DoChangeAfficheDernierCoup');
             end;
       if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
         QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
       SetPort(oldport);
     end;
end;


procedure DoChangeAfficheReflexion;
begin
  with affichageReflexion do
    begin
	    if not(windowReflexOpen)
	      then
	        begin
	          doitAfficher := true;
	          OuvreFntrReflex(not(SupprimerLesEffetsDeZoom));
	          EcritReflexion;
	        end
	      else
	        begin
	          if (wReflexPtr<>FrontWindowSaufPalette())
	            then 
	              SelectWindowSousPalette(wReflexPtr)
	            else 
	              begin
	                doitAfficher := false;
	                DoClose(wReflexPtr,true);
	              end;
	        end;
    end;
end;

procedure DoChangeAfficheBibliotheque;
  begin
    afficheBibl := not(afficheBibl);
    if not(afficheBibl) 
      then 
        begin
          if (nbreCoup<=LongMaxBibl) then EffaceCoupsBibliotheque;
        end
      else 
        begin
          if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
        end;
     DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
  end;

procedure DoChangeAfficheGestionTemps;    
  begin
    if not(afficheGestionTemps) | not(windowGestionOpen)
      then 
        begin 
          afficheGestionTemps := true;
          if not(windowGestionOpen) then OuvreFntrGestion(not(SupprimerLesEffetsDeZoom));
          EcritGestionTemps;
          if affichageReflexion.doitAfficher then EcritReflexion;
        end
      else 
        begin
          if (wGestionPtr<>FrontWindowSaufPalette())
            then SelectWindowSousPalette(wGestionPtr)
            else 
              begin
                afficheGestionTemps := false;
                DoClose(wGestionPtr,true);
              end;
        end;    
  end; 

procedure DoChangeAfficheSuggestionDeCassio;
begin
  afficheSuggestionDeCassio := not(afficheSuggestionDeCassio);
  if not(afficheSuggestionDeCassio) then 
    begin
      gDoitJouerMeilleureReponse := false;
      SetSuggestionDeFinaleEstDessinee(false);
    end;
  if aideDebutant
    then DessineAideDebutant(true,othellierToutEntier)
    else EffaceAideDebutant(true,false,othellierToutEntier);
end;  
  
procedure DoChangeAffichePierresDelta;
begin
  affichePierresDelta := not(affichePierresDelta);
  if affichePierresDelta
    then DesssinePierresDeltaCourantes
    else 
      begin
        EffacePierresDeltaCourantes;
        AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoChangeAffichePierresDelta');
      end;
  if aideDebutant then DessineAideDebutant(false,othellierToutEntier);
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
  if afficheNumeroCoup & (nbreCoup>0)
    then DessineNumeroCoup(GetDernierCoup(),nbreCoup,-jeuCourant[GetDernierCoup()],GetCurrentNode());
end;

procedure DoChangeAfficheProchainsCoups;
begin
  EffaceProprietesOfCurrentNode;
  afficheProchainsCoups := not(afficheProchainsCoups);
  if aideDebutant then DessineAideDebutant(false,othellierToutEntier);
  AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoChangeAfficheProchainsCoups');
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
end;

procedure DoChangeAfficheSignesDiacritiques;
begin
  EffaceProprietesOfCurrentNode;
  if afficheNumeroCoup & (nbreCoup>0)
    then EffaceNumeroCoup(GetDernierCoup(),nbreCoup,GetCurrentNode());
  afficheSignesDiacritiques := not(afficheSignesDiacritiques);
  AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoChangeAfficheSignesDiacritiques');
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
  if afficheNumeroCoup & (nbreCoup>0)
    then DessineNumeroCoup(GetDernierCoup(),nbreCoup,-jeuCourant[GetDernierCoup()],GetCurrentNode());
end;

procedure DoChangeAfficheNotesSurCases(origine : SInt32);
begin
  if GetAvecAffichageNotesSurCases(origine) then EffaceNoteSurCases(origine,othellierToutEntier);
  SetAvecAffichageNotesSurCases(origine,not(GetAvecAffichageNotesSurCases(origine)));
  
  if (origine = kNotesDeCassio) then
    begin
      if GetAvecAffichageNotesSurCases(kNotesDeCassio) & (BAND(GetAffichageProprietesOfCurrentNode(),kNotesCassioSurLesCases) = 0)
        then SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode() + kNotesCassioSurLesCases);
      
      if not(GetAvecAffichageNotesSurCases(kNotesDeCassio)) & (BAND(GetAffichageProprietesOfCurrentNode(),kNotesCassioSurLesCases) <> 0)
        then SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode() - kNotesCassioSurLesCases);
    end;
  
  if GetAvecAffichageNotesSurCases(origine) then DessineNoteSurCases(origine,othellierToutEntier);
end;

procedure DoChangeAfficheMeilleureSuite;
begin
  if afficheMeilleureSuite & MeilleureSuiteEffacee
    then 
      begin
        EcritMeilleureSuite;
        meilleureSuiteEffacee := false;
      end
    else
      begin
	    afficheMeilleureSuite := not(afficheMeilleureSuite);
	    if afficheMeilleureSuite
	      then EcritMeilleureSuite
	      else 
	        begin
	          EffaceMeilleureSuite;
	          if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
	        end;
       end;
end;


procedure SauvegarderDerniereDimensionFenetre2D;
var tailleFenetreActuelle : Point;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    if not(CassioEstEn3D()) then
	    begin
	      tailleFenetreActuelle := GetWindowSize(wPlateauPtr);
	      tailleFenetrePlateauAvantPassageEn3D := tailleFenetreActuelle.h +  65536*tailleFenetreActuelle.v ;
	      tailleCaseAvantPassageEn3D := GetTailleCaseCourante();
	    end;
end;


procedure RestaurerDerniereDimensionFenetre2D;
var ignored : boolean;
begin
  if (tailleFenetrePlateauAvantPassageEn3D > 0) & windowPlateauOpen & (wPlateauPtr <> NIL) then
    if CassioEstEn3D() then
	    begin 
	      SizeWindow(wPlateauPtr,LoWrd(tailleFenetrePlateauAvantPassageEn3D),HiWrd(tailleFenetrePlateauAvantPassageEn3D),true);
	      AjusteAffichageFenetrePlat(tailleCaseAvantPassageEn3D,ignored,ignored);
	      MetTitreFenetrePlateau;
	    end;
end;


procedure DoChangeEn3D(avecAlerte : boolean);
var ignored : boolean;
begin
  if not(EnModeEntreeTranscript()) then
    begin
      if CassioEstEn3D()
        then
          begin
            RestaurerDerniereDimensionFenetre2D;
            case gLastTexture2D.theMenu of
              CouleurID   : DoCouleurMenuCommands(CouleurID,gLastTexture2D.theCmd,ignored);
              Picture2DID : DoPicture2DMenuCommands(Picture2DID,gLastTexture2D.theCmd,ignored,avecAlerte);
            end; {case}
          end
        else
          begin
            SauvegarderDerniereDimensionFenetre2D;
            DoPicture3DMenuCommands(gLastTexture3D.theCmd,ignored,avecAlerte);
          end;
    end;
  MetTitreFenetrePlateau;
end;


procedure RepasserEn2D(avecAlerte : boolean);
begin
  {on repasse en 2D}
  SetEnVieille3D(true);
  DoChangeEn3D(avecAlerte);
end;
  
  
procedure DoChangeDisplayJapaneseNamesInJapanese;
begin
  if gVersionJaponaiseDeCassio & gHasTextServices then
    begin
      gDisplayJapaneseNamesInJapanese := not(gDisplayJapaneseNamesInJapanese);
      InvalidateJustificationPasDePartieDansListe;
      if windowListeOpen then EcritListeParties(false,'DoChangeDisplayJapaneseNamesInJapanese');
    end;
end;

procedure DoChangeAvecGagnantEnGrasDansListe;
begin
  avecGagnantEnGrasDansListe := not(avecGagnantEnGrasDansListe);
  if windowListeOpen then EcritListeParties(false,'DoChangeAvecGagnantEnGrasDansListe');
end;

procedure TesterAffichageNomsDesGagnantsEnGras(modifiers : SInt16);
var verouillage,shift,option,control,command : boolean;
begin
  option      := BAND(modifiers,optionKey)  <> 0;
  shift       := BAND(modifiers,shiftKey)   <> 0;
  verouillage := BAND(modifiers,alphaLock)  <> 0;
  control     := BAND(modifiers,controlKey) <> 0;
  command     := BAND(modifiers,cmdKey)     <> 0;
  if (control & shift) | (command & shift) then DoChangeAvecGagnantEnGrasDansListe;
end;

procedure TesterAffichageNomsJaponaisEnRoman(modifiers : SInt16);
var verouillage,shift,option : boolean;
begin
  option := BAND(modifiers,optionKey) <> 0;
  {if (option <> avecGagnantEnGrasDansListe) then
    DoChangeAvecGagnantEnGrasDansListe;}
  if gVersionJaponaiseDeCassio then
    begin
      shift := BAND(modifiers,shiftKey) <> 0;
      verouillage := BAND(modifiers,alphaLock) <> 0;
      if verouillage <> not(gDisplayJapaneseNamesInJapanese) then
        DoChangeDisplayJapaneseNamesInJapanese;
    end;
end;
  
procedure DoRevenir;
var oldTextureSelection:MenuCmdRec;
begin
  if not windowPlateauOpen then DoNouvellePartie(false);
  avecCalculPartiesActives := true;
  enRetour := true;
  humainVeutAnnuler := false;
  
  oldTextureSelection.theMenu := gCouleurOthellier.menuID;
  oldTextureSelection.theCmd := gCouleurOthellier.menuCmd;
  if EnVieille3D() then
     gCouleurOthellier := CalculeCouleurRecord(gLastTexture2D.theMenu,gLastTexture2D.theCmd);
  ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),othellierToutEntier);
  DessineRetour(NIL,'DoRevenir');  
  AjusteCurseur;
  AjusteSleep;
  DisableItemTousMenus;
  DisableTitlesOfMenusForRetour;
  repeat
    if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
      then TraiteEvenements
      else TraiteNullEvent(theEvent);
    AjusteCurseur;
  until not(enRetour) | Quitter | humainVeutAnnuler | not(windowPlateauOpen);
  if humainVeutAnnuler then
    begin
      enRetour := false;
      humainVeutAnnuler := false;
      AjusteSleep;
      dernierTick := TickCount();
      if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
         then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,false);
    end;
  if (gCouleurOthellier.menuID <> oldTextureSelection.theMenu) | (gCouleurOthellier.menuCmd <> oldTextureSelection.theCmd) 
    then
	    begin
	      gCouleurOthellier := CalculeCouleurRecord(oldTextureSelection.theMenu,oldTextureSelection.theCmd);
	      EcranStandard(NIL,false);
	    end
	  else
	    begin
	      if gCouleurOthellier.estUneTexture {& not(CassioEstEn3D())} & not(Quitter) then 
	        DessineNumerosDeCoupsSurTousLesPionsSurDiagramme(nbreCoup); {effacement des numeros fantomes}
	      EcranStandard(NIL,false);
	    end;
	TachesUsuellesPourAffichageCourant;
	AjusteSleep;
  EnableItemTousMenus;
  EnableAllTitlesOfMenus;
end;


procedure DoDebut(ForceHumCtreHum : boolean);
var i,numeroDuCoupInitial : SInt16; 
begin
  if not(windowPlateauOpen) then DoNouvellePartie(ForceHumCtreHum);
  
  if not(HumCtreHum) & not(CassioEstEnModeSolitaire()) & ForceHumCtreHum 
    then DoChangeHumCtreHum;
  numeroDuCoupInitial := nbreCoup+1;
  for i := nbreCoup downto 1 do 
    if (GetNiemeCoupPartieCourante(i) <> 0) then numeroDuCoupInitial := i;
  if nbreCoup>numeroDuCoupInitial-1 then 
    begin
      if nbreCoup=numeroDuCoupInitial+1 then DoDoubleBackMove else
      if nbreCoup=numeroDuCoupInitial then DoBackMove else
        DoRetourAuCoupNro(numeroDuCoupInitial-1,true,ForceHumCtreHum);
    end;
  dernierTick := TickCount();
  PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
  gGongDejaSonneDansCettePartie := false;
  InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);
end;




procedure DoCoefficientsEvaluation;
const 
    CoefficientsID=133;
    OK=1;
    Annuler=2;
    ValeursStandard=3;
    TablesPositionnellesBox=4;
var dp : DialogPtr;
    itemHit : SInt16; 
    unRect : rect;
    FiltreCoeffDialogUPP : ModalFilterUPP;
    err : OSErr;
    CoeffinfluenceArrivee : extended;
    CoefffrontiereArrivee : extended;
    CoeffEquivalenceArrivee : extended;
    CoeffcentreArrivee : extended;
    CoeffgrandcentreArrivee : extended;
    CoeffdispersionArrivee : extended;
    CoeffminimisationArrivee : extended;
    CoeffpriseCoinArrivee : extended;
    CoeffdefenseCoinArrivee : extended;
    CoeffValeurCoinArrivee : extended;
    CoeffValeurCaseXArrivee : extended;
    CoeffPenaliteArrivee : extended;    
    CoeffMobiliteUnidirectionnelleArrivee : extended;
    EvalueTablesDeCoinsArrivee : boolean;

procedure SauveValeursArrivee;
begin
    CoeffinfluenceArrivee := CoeffInfluence;
    CoefffrontiereArrivee := Coefffrontiere;
    CoeffEquivalenceArrivee := CoeffEquivalence;
    CoeffcentreArrivee := Coeffcentre;
    CoeffgrandcentreArrivee := Coeffgrandcentre;
    CoeffdispersionArrivee := Coeffbetonnage;
    CoeffminimisationArrivee := Coeffminimisation;
    CoeffpriseCoinArrivee := CoeffpriseCoin;
    CoeffdefenseCoinArrivee := CoeffdefenseCoin;
    CoeffValeurCoinArrivee := CoeffValeurCoin;
    CoeffValeurCaseXArrivee := CoeffValeurCaseX;
    CoeffPenaliteArrivee := CoeffPenalite; 
    CoeffMobiliteUnidirectionnelleArrivee := CoeffMobiliteUnidirectionnelle;
    EvalueTablesDeCoinsArrivee := avecEvaluationTablesDeCoins;
end;


procedure RemetValeursArrivee;
begin
    CoeffInfluence := CoeffinfluenceArrivee;
    Coefffrontiere := CoefffrontiereArrivee;
    CoeffEquivalence := CoeffEquivalenceArrivee;
    Coeffcentre := CoeffcentreArrivee;
    Coeffgrandcentre := CoeffgrandcentreArrivee;
    Coeffbetonnage := CoeffdispersionArrivee;
    Coeffminimisation := CoeffminimisationArrivee;
    CoeffpriseCoin := CoeffpriseCoinArrivee;
    CoeffdefenseCoin := CoeffdefenseCoinArrivee;
    CoeffValeurCoin := CoeffValeurCoinArrivee;
    CoeffValeurCaseX := CoeffValeurCaseXArrivee;
    CoeffPenalite := CoeffPenaliteArrivee; 
    CoeffMobiliteUnidirectionnelle := CoeffMobiliteUnidirectionnelleArrivee;
    avecEvaluationTablesDeCoins := EvalueTablesDeCoinsArrivee;
end;


begin
  BeginDialog;
  FiltreCoeffDialogUPP := NewModalFilterUPP(@FiltreCoeffDialog);
  dp := MyGetNewDialog(CoefficientsID,FenetreFictiveAvantPlan());
  if dp <> NIL then
  begin
    Superviseur(nbreCoup);
    EcritParametres(dp,0);
    DessineEchellesCoeffs(dp);
    EcritEtDessineBords;
    SetBoolCheckBox(dp,TablesPositionnellesBox,avecEvaluationTablesDeCoins);
    if avecEvaluationTablesDeCoins 
      then EcritValeursTablesPositionnelles(dp)
      else EffaceValeursTablesPositionnelles(dp);
    SauveValeursArrivee;
    err := SetDialogTracksCursor(dp,true);
    repeat
      ModalDialog(FiltreCoeffDialogUPP,itemHit);
      case itemHit of
        VirtualUpdateItemInDialog:
          begin
            BeginUpdate(GetDialogWindow(dp));
            SetPortByDialog(dp);
            if gCassioUseQuartzAntialiasing then EraseRect(GetWindowPortRect(GetDialogWindow(dp)));
            OutlineOK(dp);
            MyDrawDialog(dp);
            EcritParametres(dp,0);
            DessineEchellesCoeffs(dp);
            EcritEtDessineBords;
            if avecEvaluationTablesDeCoins 
				      then EcritValeursTablesPositionnelles(dp)
				      else EffaceValeursTablesPositionnelles(dp);
            EndUpdate(GetDialogWindow(dp));
          end;
        OK:;
        Annuler:
           begin
             RemetValeursArrivee;
             Superviseur(nbreCoup);
           end;
        ValeursStandard:
           begin
             CoefficientsStandard;
             Superviseur(nbreCoup);
             if gCassioUseQuartzAntialiasing then EraseRect(GetWindowPortRect(GetDialogWindow(dp)));
             with EchelleCoeffsRect do
               SetRect(unRect,220,top-2,right+60,EchelleCoeffsRect.bottom+2);
             EraseRect(unRect);
             EcritParametres(dp,0);
             DessineEchellesCoeffs(dp);
             EcritEtDessineBords;
             if avecEvaluationTablesDeCoins 
					      then EcritValeursTablesPositionnelles(dp)
					      else EffaceValeursTablesPositionnelles(dp);
					   MyDrawDialog(dp);
           end;
         TablesPositionnellesBox:
           begin
             DoChangeEvaluationTablesDeCoins;
             SetBoolCheckBox(dp,TablesPositionnellesBox,avecEvaluationTablesDeCoins);
             if avecEvaluationTablesDeCoins 
					      then EcritValeursTablesPositionnelles(dp)
					      else EffaceValeursTablesPositionnelles(dp);
           end;
      end; {case}
    until (itemHit=OK) | (itemHit=Annuler);
    MyDisposeDialog(dp);
    AjusteSleep;
    if not(enSetUp) then 
      if HasGotEvent(updateMask,theEvent,0,NIL) then
        TraiteOneEvenement;
  end; 
  MyDisposeModalFilterUPP(FiltreCoeffDialogUPP);
  EndDialog;
  AjusteSleep;
end;



{$S Actions2}

procedure DoMakeMainBranch;
const MakeMainBranchID=157;
      Annuler=2;
      OK=1;
var dp : DialogPtr;
    itemHit : SInt16; 
    err : OSErr;
    ConfirmationMakeMainBranch : boolean;
begin
  ConfirmationMakeMainBranch := true;
  BeginDialog;
  dp := MyGetNewDialog(MakeMainBranchID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit=Annuler) | (itemHit=OK);
      MyDisposeDialog(dp);
      if (itemHit=Annuler) 
        then ConfirmationMakeMainBranch := false
        else ConfirmationMakeMainBranch := true;
    end;
  EndDialog;
  if ConfirmationMakeMainBranch then 
    begin
      EffaceProprietesOfCurrentNode;
      MakeMainLineInGameTree(GetCurrentNode());
      AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DoMakeMainBranch');
    end;
end;
 

procedure DoCourbe;
  begin
    if windowCourbeOpen
      then 
        begin
          if (wCourbePtr<>FrontWindowSaufPalette())
            then SelectWindowSousPalette(wCourbePtr)
            else DoClose(wCourbePtr,true);
        end
      else 
        OuvreFntrCourbe(not(SupprimerLesEffetsDeZoom));
  end;

procedure DoRapport;
  begin
    if FenetreRapportEstOuverte()
      then 
        begin
          if not(FenetreRapportEstAuPremierPlan())
            then SelectWindowSousPalette(GetRapportWindow())
            else DoClose(GetRapportWindow(),true);
        end
      else OuvreFntrRapport(not(SupprimerLesEffetsDeZoom),true);
  end;


{
procedure DoChangeSensLargeSolitaire;
  begin
    SensLargeSolitaire := not(SensLargeSolitaire);
  end;
}

procedure DoChangeReferencesCompletes;
  begin
    referencesCompletes := not(referencesCompletes);
  end;
  
{
procedure DoChangeFinaleEnSolitaire;
  begin
    finaleEnModeSolitaire := not(finaleEnModeSolitaire);
  end;
}

procedure DoChangeSensLectureBase;
  begin
    LectureAntichronologique := not(LectureAntichronologique);
  end;
  
procedure DoChangePalette;
begin
  if windowPaletteOpen & (wPalettePtr <> NIL)
    then DoClose(wPalettePtr,true)
    else OuvreFntrPalette;
end;
  
procedure DoStatistiques;
 begin
   if avecGestionBase then
      if windowStatOpen 
        then 
          begin
            if (wStatPtr<>FrontWindowSaufPalette())
              then SelectWindowSousPalette(wstatptr)
              else DoClose(wStatPtr,true);
          end
        else 
          begin
            OuvreFntrStat(not(SupprimerLesEffetsDeZoom));
            if windowStatOpen then
              begin
                if Ecrande512 & (genreAffichageTextesDansFenetrePlateau <> kAffichageSousOthellier) 
                  then SetAffichageResserre(true)
                  else SetPositionsTextesWindowPlateau;
                if afficheInfosApprentissage then EcritLesInfosDApprentissage;
              end;
            if not(windowListeOpen) then
              begin
                IncrementeMagicCookieDemandeCalculsBase;
                ConstruitTablePartiesActives(false,false);
                ConstruitTableNumeroReference(false,false);
                EssayerConstruireTitrePartie;
              end;
            if windowStatOpen then
              begin
                ConstruitStatistiques(false);
                EcritRubanStatistiques;
                EcritStatistiques(false);
              end;
          end;
   FixeMarqueSurMenuBase;
 end;


procedure DoListeDeParties;
 begin
  if avecGestionBase then
    if windowListeOpen 
      then 
        begin
          if (wListePtr<>FrontWindowSaufPalette())
            then SelectWindowSousPalette(wListePtr)
            else DoClose(wListePtr,true);
        end
      else 
        begin
          
          OuvreFntrListe(not(SupprimerLesEffetsDeZoom));
          if windowListeOpen then
            begin
              
              if Ecrande512 & (genreAffichageTextesDansFenetrePlateau <> kAffichageSousOthellier) 
                then SetAffichageResserre(true)
                else SetPositionsTextesWindowPlateau;
              
              if afficheInfosApprentissage then EcritLesInfosDApprentissage;
              
              if not(windowStatOpen) then
                begin
                  IncrementeMagicCookieDemandeCalculsBase;
                  ConstruitTablePartiesActives(false,false);
                  ConstruitTableNumeroReference(false,false);
                  EssayerConstruireTitrePartie;
                end;
              
              with infosListePartiesDerniereFermeture do
                if (nombrePartiesActives  = nbPartiesActives) &
                   (nombrePartiesChargees = nbPartiesChargees) &
                   (nbreLignesFntreListe  = CalculeNbreLignesVisiblesFntreListe()) &
                   (partieHilitee >= 1) &
                   (partieHilitee <= nbPartiesActives) &
                   (tableNumeroReference^^[partieHilitee]=dernierNroReferenceHilitee)
                 then 
                   begin
                     {ce qui suit est mieux que SetPartieHiliteeEtAjusteAscenseurListe(partieHilitee) car on conserve la position de l'ascenseur}
                     SetControlLongintMinimum(longintMinimum);
                     SetControlLongintMaximum(longintMaximum);
                     SetValeurAscenseurListe(positionPouceAscenseurListe);
                     SetPartieHilitee(partieHilitee);
                     AjustePouceAscenseurListe(false);
                   end
                 else
                   begin
                     AjustePouceAscenseurListe(false);
                     NroReference2NroHilite(dernierNroReferenceHilitee,infosListeParties.partieHilitee);
                     SetPartieHiliteeEtAjusteAscenseurListe(infosListeParties.partieHilitee);
                   end;
              
              EcritListeParties(false,'DoListeDeParties');
              
            end;
        end;
   FixeMarqueSurMenuBase;
 end;
 
procedure DoCommentaires;
var commentaireChange : boolean;
begin
  with arbreDeJeu do
    begin
		  if windowOpen
		    then
		      begin
		        if (GetArbreDeJeuWindow() <> FrontWindowSaufPalette())
		          then SelectWindowSousPalette(GetArbreDeJeuWindow())
		          else DoClose(GetArbreDeJeuWindow(),true);
		      end
		    else
		      begin
		        OuvreFntrCommentaires(not(SupprimerLesEffetsDeZoom));
		        SetTexteFenetreArbreDeJeuFromArbreDeJeu(GetCurrentNode(),false,commentaireChange);
		      end;
		  ValideZoneCommentaireDansFenetreArbreDeJeu;
    end;
end;

procedure DoChangeDessineAide;
begin
  if windowAideOpen
    then CloseAideWindow
    else
      begin
        OuvreFntrAide;
        DessineAide(gAideCourante);
      end;
end;
 
procedure DoChangeAfficheInfosApprentissage;
var oldport : grafPtr;
  begin
    afficheInfosApprentissage := not(afficheInfosApprentissage);
    GetPort(oldPort);
    EssaieSetPortWindowPlateau;
    InvalRect(QDGetPortBound());
    SetPort(oldport);
  end;
 
procedure DoChangeUtiliseGrapheApprentissage;
  begin
    UtiliseGrapheApprentissage := not(UtiliseGrapheApprentissage);
  end;
  
procedure DoChangeLaDemoApprend;
  begin
    LaDemoApprend := not(LaDemoApprend);
  end;
  
procedure DoChangeEffetSpecial1;
  begin
    SetEffetSpecial(not(GetEffetSpecial()));
  end;

procedure DoChangeEffetSpecial2;
  begin
    effetspecial2 := not(effetspecial2);
  end;

procedure DoChangeEffetSpecial3;
  begin
    effetspecial3 := not(effetspecial3);
  end;
{
procedure DoChangeEffetSpecial4;
  begin
    effetspecial4 := not(effetspecial4);
  end;

procedure DoChangeEffetSpecial5;
  begin
    effetspecial5 := not(effetspecial5);
  end;

procedure DoChangeEffetSpecial6;
  begin
    effetspecial6 := not(effetspecial6);
  end;
  
}
{
procedure DoChangeSelectivite;
  begin
    avecSelectivite := not(avecSelectivite);
  end;
}

procedure DoChangeNomOuverture;
  begin
    avecNomOuvertures := not(avecNomOuvertures);
    if not(affichebibl) then DoChangeAfficheBibliotheque;    
  end;

{
procedure DoChangeEcran512;
  var Ecranrect : rect;
  begin
    Ecranrect := GetScreenBounds();
    if ((Ecranrect.right-Ecranrect.left)<>512)
      then ecranDe512 := not(ecrande512)
      else ecranDe512 := true;
  end;
}
{
procedure DoChangeToujoursIndexer;
  begin
    ToujoursIndexerBase := not(ToujoursIndexerBase);
  end;
}

procedure DoChangeAvecSystemeCoordonnees;
begin
  avecSystemeCoordonnees := not(avecSystemeCoordonnees);
  AjusteAffichageFenetrePlatRapide;
  
  if not(EnVieille3D()) then 
    begin
      InvalidateAllCasesDessinEnTraceDeRayon;
      EcranStandard(NIL,true);
    end;
end;

procedure DoChangeGarderPartieNoireADroiteOthellier;
begin
  garderPartieNoireADroiteOthellier := not(garderPartieNoireADroiteOthellier);
  AjusteAffichageFenetrePlatRapide;
  
  if not(EnVieille3D()) then 
    begin
      InvalidateAllCasesDessinEnTraceDeRayon;
      EcranStandard(NIL,true);
    end;
end;


procedure DoChangeAvecReflexionTempsAdverse;
  begin
    sansReflexionSurTempsAdverse := not(sansReflexionSurTempsAdverse);
    if sansReflexionSurTempsAdverse & not(HumCtreHum) & (aQuiDeJouer = -couleurMacintosh) then
      LanceInterruption(interruptionSimple,'DoChangeAvecReflexionTempsAdverse');
  end;

procedure DoChangeAvecBibl;
  begin
    avecBibl := not(avecBibl);
  end;

procedure DoChangeVarierOuvertures;
  begin
    with gEntrainementOuvertures do
      begin
        CassioVarieSesCoups := not(CassioVarieSesCoups);
        if CassioVarieSesCoups then modeVariation := kVarierEnUtilisantMilieu;
      end;
  end;

procedure DoChangeJoueBonsCoupsBibl;
  begin
    JoueBonsCoupsBibl := not(JoueBonsCoupsBibl);
  end;

procedure DoChangeEnModeIOS;
  begin
    enModeIOS := not(enModeIOS);
  end;

procedure DoChangeSousEmulatorSousPC;
  begin
    sousEmulatorSousPC := not(sousEmulatorSousPC);
  end;
  
procedure DoChangeInfosTechniques;
  begin
    InfosTechniquesDansRapport := not(InfosTechniquesDansRapport);
  end;

procedure DoChangeEcrireDansRapportLog;
  begin
    ecrireDansRapportLog := GetEcritToutDansRapportLog();
    ecrireDansRapportLog := not(ecrireDansRapportLog);
    SetEcritToutDansRapportLog(ecrireDansRapportLog);
    SetAutoVidageDuRapport(ecrireDansRapportLog);
  end;

procedure DoChangeUtilisationNouvelleEval;
  begin
    if utilisationNouvelleEval
      then utilisationNouvelleEval := false
      else
        if not(VecteurEvalIntegerEstVide(vecteurEvaluationInteger)) & FichierEvaluationDeCassioTrouvable('Evaluation de Cassio')
          then utilisationNouvelleEval := true;
  end;

procedure DoChangeEnTraitementDeTexte;
const MachineAEcrireID=10129;
  begin
    EnTraitementDeTexte := not(EnTraitementDeTexte);
    if EnTraitementDeTexte 
      then 
        begin
          PlaySoundSynchrone(MachineAEcrireID);
          EnableKeyboardScriptSwitch;
          arbreDeJeu.doitResterEnModeEdition := arbreDeJeu.enModeEdition;
        end
      else
        begin
          arbreDeJeu.doitResterEnModeEdition := false;
        end;
  end;

procedure DoChangePostscriptCompatibleXPress;
  begin
    PostscriptCompatibleXPress := not(PostscriptCompatibleXPress);
  end;

procedure DoChangeArrondirEvaluations;
  begin
    utilisateurVeutDiscretiserEvaluation := not(utilisateurVeutDiscretiserEvaluation); 
  end;

procedure DoChangeFaireConfianceScoresArbre;
  begin
    seMefierDesScoresDeLArbre := not(seMefierDesScoresDeLArbre);
  end;

(*
procedure DoChangeAfficheCoupTete;
  begin
    avecDessinCoupEnTete := not(avecDessinCoupEnTete);
    if not(avecDessinCoupEnTete) 
      then EffaceCoupEnTete
      else 
        begin
          if not(afficheSuggestionDeCassio) then DoChangeAfficheSuggestionDeCassio;
          if not(HumCtreHum) then
            if (coupEnTete>=11) & (coupEnTete<=88) then 
            begin
              if ((aQuiDeJouer=couleurMacintosh) & possiblemove[coupEnTete])then DessineCoupEnTete;
              if ((aQuiDeJouer<>couleurMacintosh) & (jeuCourant[coupEnTete] = pionVide))then DessineCoupEnTete;
            end;
        end;
  end;
*)

procedure DoChangeInterversions;
begin
  avecInterversions := not(avecInterversions);
  InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
  if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
      then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
end;




procedure DoChoisitDemo;
  begin
    if demo then
      begin
        Quitter := true;
        LanceInterruption(interruptionSimple,'DoChoisitDemo');
        vaDepasserTemps := false;
        demo := false;
      end
    else
      begin
        demo := true;
        if BAND(theEvent.modifiers,optionKey) <> 0
          then DoDemo(-1,-1,false,true)
          else DoDemo(7,7,false,true);
        PrepareNouvellePartie(false);
      end;
  end;
  
{
procedure DoChangeAnalyse;
  begin
    analyse := not(analyse);
    if analyse then 
     begin
       cadence := minutes10000000;
       if not(affichageReflexion.doitAfficher) then DoChangeAffichereflexion; 
       if not(afficheGestionTemps) then DoChangeAfficheGestionTemps;
       if not(afficheMeilleureSuite) then DochangeafficheMeilleureSuite;
       if not(afficheSuggestionDeCassio) then DochangeafficheSuggestionDeCassio;
       if not(afficheNumeroCoup) then DoChangeAfficheDernierCoup;
       AjusteCadenceMin(cadence);
       dernierTick := TickCount();
       Heure(pionNoir);
       Heure(pionBlanc);  
     end
     else
     begin
       cadence := minutes3;
       if affichageReflexion.doitAfficher then DoChangeAffichereflexion; 
       if afficheGestionTemps then DoChangeAfficheGestionTemps;
       if afficheMeilleureSuite then DochangeafficheMeilleureSuite;
       if afficheSuggestionDeCassio then DochangeafficheSuggestionDeCassio;
       if afficheNumeroCoup then DoChangeAfficheDernierCoup;
       AjusteCadenceMin(cadence);
       dernierTick := TickCount();
       Heure(pionNoir);
       Heure(pionBlanc);  
       EcranStandard;
     end;      
  end;
}
  

procedure DoChangeProfImposee;
begin
  SetProfImposee(not(ProfondeurMilieuEstImposee()),'DoChangeProfImposee')
end;



procedure DoSetUp;
  begin
    enSetUp := true;
    
    DisableItemTousMenus;
    MyDisableItem(PartieMenu,0);
    MyDisableItem(ModeMenu,0);
    MyDisableItem(JoueursMenu,0);
    MyDisableItem(BaseMenu,0);
    MyDisableItem(SolitairesMenu,0);
    MyDisableItem(AffichageMenu,0);
    if avecProgrammation then MyDisableItem(ProgrammationMenu,0);
    DrawMenuBar;
    if not windowPlateauOpen then DoNouvellePartie(true);
    if windowCourbeOpen then ShowHide(wCourbePtr,false);
    if windowAideOpen then ShowHide(wAidePtr,false);
    if windowGestionOpen then ShowHide(wGestionPtr,false);
    if windowReflexOpen then ShowHide(wReflexPtr,false);
    if windowListeOpen then ShowHide(wListePtr,false);
    if windowStatOpen then ShowHide(wStatPtr,false);
    if windowRapportOpen then ShowHide(GetRapportWindow(),false);
    if windowPaletteOpen then ShowHide(wPalettePtr,false);
    if arbreDeJeu.windowOpen then ShowHide(GetArbreDeJeuWindow(),false);
    NoUpdateWindowPlateau;
    AjusteSleep;
    
    SetUp;
    
    enSetUp := false;
    if windowCourbeOpen then ShowHide(wCourbePtr,true);
    if windowAideOpen then ShowHide(wAidePtr,true);
    if windowGestionOpen then ShowHide(wGestionPtr,true);
    if windowReflexOpen then ShowHide(wReflexPtr,true);
    if windowListeOpen then ShowHide(wListePtr,true);
    if windowStatOpen then ShowHide(wStatPtr,true);
    if windowRapportOpen then ShowHide(GetRapportWindow(),true);
    if windowPaletteOpen then ShowHide(wPalettePtr,true);
    if arbreDeJeu.windowOpen then ShowHide(GetArbreDeJeuWindow(),true);
    if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) then SetAffichageResserre(true);
    EnableItemTousMenus;
    MyEnableItem(PartieMenu,0);
    MyEnableItem(ModeMenu,0);
    MyEnableItem(JoueursMenu,0);
    MyEnableItem(BaseMenu,0);
    MyEnableItem(SolitairesMenu,0);
    MyEnableItem(AffichageMenu,0);
    if avecProgrammation then MyEnableItem(ProgrammationMenu,0);
    DrawMenuBar;
    AjusteSleep;
  end;

 

 
procedure FermeToutEtQuitte;
var tick : SInt32;
  begin
    gameOver := true;
    Quitter := true;
    while (FrontWindow() <> NIL) & ((TickCount()-tick)<500) do
        DoClose(FrontWindow(),false);
    LanceInterruption(interruptionSimple,'FermeToutEtQuitte');
    vaDepasserTemps := false;   
    FlushEvents(everyEvent-DiskEvt,0);
    tick := TickCount();
    while (FrontWindow() <> NIL) & ((TickCount()-tick)<500) do
        DoClose(FrontWindow(),false);
    {donnons une chance aux autres applications de se redessiner}
    ShareTimeWithOtherProcesses(10);
  end;
  
procedure FermeToutesLesFenetresAuxiliaires;
var tick : SInt32;
    whichWindow,windowAux : WindowPtr;
  begin
    tick := TickCount();
    whichWindow := FrontWindowSaufPalette();
    while (whichWindow <> NIL) & ((TickCount()-tick)<500) do
      begin
        windowAux := MyGetNextWindow(whichWindow);
        if IsWindowVisible(whichWindow) then
          if (whichWindow<>wPlateauPtr) & (whichWindow<>wPalettePtr) & (whichWindow<>iconisationDeCassio.theWindow) then
            DoClose(whichWindow,false);
        whichWindow := windowAux;
      end;
  end;


procedure DoQuit; {utilisee dans UnitAppleEventsCassio.p}
begin
  if ConfirmationQuitter() then
    if doitConfirmerQuitter | PeutArreterAnalyseRetrograde() then
    begin
      {gameOver := true;}
      Quitter := true;
      LanceInterruption(interruptionSimple,'DoQuit');
      vaDepasserTemps := false;
      if EnModeEntreeTranscript() then DoChangeEnModeEntreeTranscript;
      doitEcrireInterversions := BAND(theEvent.modifiers,optionKey) <> 0;
    end;
end;

procedure DoMaster;
  begin
    DerouleMaster;
    DrawMenuBar;
  end;



procedure DoSymetrie(axe : SInt32);
var s,s1 : str255;
    i,coup,t,x : SInt16; 
    tempoAideDebutant : boolean;
    platAux,positionInitialeCourante : plateauOthello;
    gameNodeLePlusProfond : GameTree;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
begin
 {if nbreCoup>0 then}
   begin
     
    tempoAideDebutant := aideDebutant;
   
    if (nbreCoup > 0) & EnModeEntreeTranscript() &
       ((NombreCasesVidesTranscriptCourant() > 0) | not(TranscriptCourantEstUnePartieLegaleEtComplete())) &
       PlusLonguePartieLegaleDuTranscriptEstDansOthellierDeGauche() 
      then ViderTranscriptCourant;
     
    if not(enRetour) then EffaceProprietesOfCurrentNode;
    EffectueSymetrieArbreDeJeuGlobal(axe);
    
    
    if debuggage.arbreDeJeu & not(enRetour) then
      begin
        AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoSymetrie {1}');
        WritelnStringAndNumDansRapport('Adresse de la racine = ',SInt32(GetRacineDeLaPartie()));
        WritelnStringAndNumDansRapport('Adresse du noeud courant = ',SInt32(GetCurrentNode()));
        SysBeep(0);
        AttendFrappeClavier;
      end;
     
    s := '';
    if (nroDernierCoupAtteint > 0) then
      for i := 1 to nroDernierCoupAtteint do
        begin
          coup := GetNiemeCoupPartieCourante(i);
          if coup>0 then s := s+CoupEnStringEnMajuscules(CaseSymetrique(coup,axe));
        end;
    s1 := s;
    if positionFeerique then
      for i := 1 to nbreCoup do
        if (GetNiemeCoupPartieCourante(i)=0) then s := '  '+s;   {double espace}
    
    GetPositionInitialeOfGameTree(positionInitialeCourante,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
    for t := 1 to 64 do
      begin
        x := othellier[t];
        plataux[CaseSymetrique(x,axe)] := positionInitialeCourante[x];
      end;
    SetPositionInitialeOfGameTree(platAux,traitInitial,nbBlancsInitial,nbNoirsInitial);
    
    
    if (Length(s)>0) | positionFeerique then
      begin
        
        if debuggage.arbreDeJeu then
          begin
		        AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoSymetrie {2}');
		        WritelnStringAndNumDansRapport('Adresse de la racine = ',SInt32(GetRacineDeLaPartie()));
		        WritelnStringAndNumDansRapport('Adresse du noeud courant = ',SInt32(GetCurrentNode()));
		        SysBeep(0);
		        AttendFrappeClavier;
          end;
        
        if not(enRetour) 
          then 
            begin
              RejouePartieOthello(s,nbreCoup,not(positionFeerique),platAux,partie^^[nbreCoup+1].trait,gameNodeLePlusProfond,false,false);
              
              if debuggage.arbreDeJeu then
                begin
		              AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoSymetrie {3}');
		              WritelnStringAndNumDansRapport('Adresse de la racine = ',SInt32(GetRacineDeLaPartie()));
		              WritelnStringAndNumDansRapport('Adresse du noeud courant = ',SInt32(GetCurrentNode()));
					        SysBeep(0);
					        AttendFrappeClavier;
                end;
            end
          else 
            begin
              RejouePartieOthelloFictive(s,nbreCoup,not(positionFeerique),platAux,partie^^[nbreCoup+1].trait,gameNodeLePlusProfond,kNoFlag);
              DessineRetour(NIL,'DoSymetrie');  
            end;
            
        if (nbreCoup < (Length(s) div 2)) then
          MiseAJourDeLaPartie(s1,jeuCourant,emplJouable,frontiereCourante,
                              nbreDePions[pionBlanc],nbreDePions[pionNoir],aQuiDeJouer,nbreCoup,false,Length(s) div 2,gameNodeLePlusProfond);
      end;
      
    if not(enRetour) then 
      begin
        aideDebutant := tempoAideDebutant;
        AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DoSymetrie {4}');
      end;
    
    positionFeerique := not(GameTreeHasStandardInitialPosition());
    
    if SelectionRapportNonVide() then
      DoSymetrieSelectionDuRapport(axe);
  end;
end;



procedure OuvrePartieSelectionnee(nroHilite : SInt32);
var s255 : str255;
    s60 : PackedThorGame;
    nomNoir,nomBlanc : str255;
    scoreNoir : SInt16; 
    titre : str255;
    nroreference : SInt32;
    premierNumero,derniernumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    premierCoup : SInt16; 
    gameNodeLePlusProfond : GameTree;
begin
  if windowListeOpen then
    begin
      GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);
      if (nroHilite>=premierNumero) & (nroHilite<=dernierNumero) then
        if (nroHilite>=1) & (nroHilite<=nbPartiesActives) then
          begin
            {nroReference := tableNumeroReference^^[nroHilite];
            if nroReference<>infosListeParties.dernierNroReferenceHilitee then SysBeep(0);}
            nroReference := infosListeParties.dernierNroReferenceHilitee;
		      
		        ExtraitPartieTableStockageParties(nroReference,s60);
		        ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		        ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
		        TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie & ouvertureDiagonale,4,60);
		        TraductionThorEnAlphanumerique(s60,s255);
		        
		        if not(EstUnePartieOthello(s255,false)) then
		          begin
		            Sysbeep(0);
		            WritelnDansRapport('ERREUR : partie illégale dans la base !');
		            WritelnDansRapport(s255);
		            exit(OuvrePartieSelectionnee);
		          end;
		                
		        if not(PositionsSontEgales(jeuCourant,CalculePositionApres(nbreCoup,s60))) then 
			        begin
			          with DemandeCalculsPourBase do
	              if (EtatDesCalculs<>kCalculsEnCours) | (NumeroDuCoupDeLaDemande<>nbreCoup) | bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	              InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
			          exit(OuvrePartieSelectionnee);
			        end;
		          
            CommentaireSolitaire^^ := '';
            finaleEnModeSolitaire := false;
            NoUpdateWindowPlateau;
            RejouePartieOthello(s255,Length(s255) div 2,true,bidplat,0,gameNodeLePlusProfond,false,true);
            
            nomNoir := GetNomJoueurNoirSansPrenomParNroRefPartie(nroreference);
            nomBlanc := GetNomJoueurBlancSansPrenomParNroRefPartie(nroreference);
            scoreNoir := GetScoreReelParNroRefPartie(nroreference);
            
            ConstruitTitrePartie(nomNoir,nomBlanc,true,scoreNoir,titre);
            titrePartie^^ := titre;
            ParamDiagCourant.titreFFORUM^^ := titre;
						ParamDiagCourant.commentPositionFFORUM^^ := '';
						ParamDiagPositionFFORUM.titreFFORUM^^ := '';
						ParamDiagPositionFFORUM.commentPositionFFORUM^^ := '';
						ParamDiagPartieFFORUM.titreFFORUM^^ := titre;
            ParamDiagPartieFFORUM.commentPositionFFORUM^^ := '';
          end;
     end;
end;



procedure DoProgrammation;
begin
  if avecProgrammation
    then
      begin
        avecProgrammation := false;
        DeleteMenu(programmationID);
        TerminateMenu(ProgrammationMenu,true);
        DrawMenuBar;
      end
    else
      begin
        avecProgrammation := true;
        ProgrammationMenu := MyGetMenu(programmationID);
        MyLockMenu(ProgrammationMenu);
        InsertMenu(ProgrammationMenu,0);
        DrawMenuBar;
      end;
end;

{$S Gestion_Evenements}


procedure OuvreAccessoireDeBureau(cmdNumber : SInt16);
var DAName  : str255;
    result  : SInt16;    {ignore}
    oldport : grafPtr;
begin  {$UNUSED result}   
  if (FrontWindow() = NIL) & not(iconisationDeCassio.enCours) then 
     EnableMenu(EditionMenu,[AnnulerCmd,CouperCmd,CopierCmd,CopierSpecialCmd,CollerCmd,EffacerCmd]);
   GetMenuItemText(GetAppleMenu(),cmdNumber,DAName);
   GetPort(oldport);
   {$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
   result := OpenDeskAcc(DAname);
   if not(WindowDeCassio(FrontWindow())) then InitCursor;
   {$ENDC}
   SetPort(oldport);
end;


procedure DoPommeMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin {$UNUSED peutRepeter}   
    case cmdNumber of
      AboutCmd                : DisplayCassioAboutBox;
      FFOCmd                  : DerouleMaster;
      PreferencesDansPommeCmd : if gIsRunningUnderMacOSX
                                  then DoDialoguePreferences
                                  else OuvreAccessoireDeBureau(cmdNumber);
      otherwise                 OuvreAccessoireDeBureau(cmdNumber);
		end; {case}
  end;


procedure DoFileMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
var shift,command,option,control : boolean;
  begin
    {$UNUSED peutRepeter}
    shift := BAND(theEvent.modifiers,shiftKey) <> 0;
    command := BAND(theEvent.modifiers,cmdKey) <> 0;
    option := BAND(theEvent.modifiers,optionKey) <> 0;
    control := BAND(theEvent.modifiers,controlKey) <> 0;
    
    case cmdNumber of
      NouvellePartieCmd         :  if PeutArreterAnalyseRetrograde() then 
                                     if PositionFeerique {| not(HumCtreHum)} | (nbreCoup=0)
                                       then DoNouvellePartie(false)
                                       else DoDebut(false);
      OuvrirCmd                 :  DoOuvrir;
      ReouvrirCmd               :  {desormais géré par le sous-menu};
      CloseCmd                  :  DoCloseCmd(theEvent.modifiers);
      ImporterUnRepertoireCmd   :  ImporterToutesPartiesRepertoire;
      EnregistrerPartieCmd      :  DoEnregistrerSous(false);
      EnregistrerArbreCmd       :  DoEnregistrerSous(true);
      FormatImpressionCmd       :  DoDialogueFormatImpression;
      ApercuAvantImpressionCmd  :  DoDialogueApercuAvantImpression;
      ImprimerCmd               :  DoProcessPrinting(true);    
      PreferencesCmd            :  DoDialoguePreferences;  
      IconisationCmd            :  If not(iconisationDeCassio.enCours)
                                     then 
                                       begin
                                         if not(windowPlateauOpen) then DoNouvellePartie(false);
                                         IconiserCassio;
                                       end
                                     else DeiconiserCassio;
      QuitCmd                   :  DoQuit;
    end;
  end;

procedure DoEditionMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
var PositionEtCoupStr:str185;
    chainePositionInitiale,chainePosition,chaineCoups : str255;
    s : str255;
    positionNormale : boolean;
begin
  {$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
  if not(SystemEdit(cmdNumber-1)) then
  {$ENDC }
  begin
    case cmdNumber of
      AnnulerCmd    : if enRetour | enSetUp
                        then humainVeutAnnuler := true
                        else 
                          if PeutArreterAnalyseRetrograde() then 
                            begin
                              if theEvent.what=autoKey
                                then DoDoubleBackMove
                                else DoBackMove;
                              peutrepeter := (nbreCoup>0);
                            end;
      CouperCmd     : if not(CouperFromRapport()) then
                        if FenetreListeEnModeEntree() 
                          then
                            begin
                              TECut(SousCriteresRuban[BoiteDeSousCritereActive]);
                              {if (MyZeroScrap() = noErr) then if (TEToScrap() = noErr) then;}
                              CriteresRubanModifies := true;
                              EcritRubanListe(true);
                            end
                          else
                        if arbreDeJeu.windowOpen & arbreDeJeu.enModeEdition
                          then
                            begin
                              TECut(GetDialogTextEditHandle(arbreDeJeu.theDialog));
                              {if (MyZeroScrap() = noErr) then if (TEToScrap() = noErr) then;}
                              SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
                            end
                          else
                            if BAND(theEvent.modifiers,optionKey) <> 0
                              then CopierPartieEnTEXT(true,false)
                              else 
                                begin
                                  if enRetour
                                    then SetParamDiag(ParamDiagPartieFFORUM)
                                    else SetParamDiag(ParamDiagPositionFFORUM);
                                  CopierEnMacDraw;
                                end;
      CopierCmd      : if not(CopierFromRapport()) then
                        begin
                          if FenetreListeEnModeEntree() 
                           then
                            begin
                              TECopy(SousCriteresRuban[BoiteDeSousCritereActive]);
                              {if (MyZeroScrap() = noErr) then if (TEToScrap() = noErr) then;}
                            end
                          else
                        if arbreDeJeu.windowOpen & arbreDeJeu.enModeEdition
                          then
                            begin
                              TECopy(GetDialogTextEditHandle(arbreDeJeu.theDialog));
                              {if (MyZeroScrap() = noErr) then if (TEToScrap() = noErr) then;}
                              SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
                            end
                          else
                            begin
                              if enRetour
                                then SetParamDiag(ParamDiagPartieFFORUM)
                                else SetParamDiag(ParamDiagPositionFFORUM);
                              CopierEnMacDraw;
                            end;
                        end;
      CollerCmd     : if not(CollerDansRapport()) then
                        begin
	                        if FenetreListeEnModeEntree()  
	                          then 
	                            begin
	                              TEPaste(SousCriteresRuban[BoiteDeSousCritereActive]);
	                              CriteresRubanModifies := true;
	                              EcritRubanListe(true);
	                            end
	                          else 
	                        if arbreDeJeu.windowOpen & arbreDeJeu.enModeEdition
                            then 
                              begin
                                TEPaste(GetDialogTextEditHandle(arbreDeJeu.theDialog));
                                SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
                              end
                            else 
                              begin
                                if not(PeutCollerPartie(positionNormale,s)) then
                                  if (OuvrirFichierPressePapier() <> NoErr) then
                                    AlerteErreurCollagePartie;
                              end;
	                      end;
      EffacerCmd     : if windowListeOpen & (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow())) & not(FenetreListeEnModeEntree()) & (nbPartiesActives > 0)
                         then
                           DoSupprimerPartiesDansListe
                         else
                           if not(EffacerDansRapport()) then
			                        begin
			                          if FenetreListeEnModeEntree() then
			                            begin
			                              TEDelete(SousCriteresRuban[BoiteDeSousCritereActive]);
			                              CriteresRubanModifies := true;
			                              EcritRubanListe(true);
			                            end else
			                          if arbreDeJeu.windowOpen & arbreDeJeu.enModeEdition then
			                            begin
			                              TEDelete(GetDialogTextEditHandle(arbreDeJeu.theDialog));
			                              SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
			                            end;
			                        end;
      ToutSelectionnerCmd :  begin
                               if windowListeOpen & (nbPartiesActives > 0) 
                                  & not(arbreDeJeu.windowOpen & arbreDeJeu.enModeEdition & (OrdreFenetre(wListePtr) > OrdreFenetre(GetArbreDeJeuWindow())))
                                  & not(FenetreListeEnModeEntree())
                                  & not(OrdreFenetre(GetRapportWindow()) < OrdreFenetre(wListePtr))
                                 then
                                   begin
                                     SelectionnerToutesLesPartiesActivesDansLaListe;
                                     EcritListeParties(false,'ToutSelectionnerCmd');
                                   end
                                 else
                                   begin
			                               if not(FenetreListeEnModeEntree()) & not(arbreDeJeu.windowOpen & arbreDeJeu.enModeEdition) &
			                                  FenetreRapportEstOuverte() & not(FenetreRapportEstAuPremierPlan()) 
			                                  then SelectWindowSousPalette(GetRapportWindow());
			                               if not(SelectionneToutDansRapport()) then
				                               begin
				                                 if FenetreListeEnModeEntree() then
				                                   TESetSelect(0,MaxInt,SousCriteresRuban[BoiteDeSousCritereActive]);
				                                 if arbreDeJeu.windowOpen & arbreDeJeu.enModeEdition then
				                                   TESetSelect(0,MaxInt,GetDialogTextEditHandle(arbreDeJeu.theDialog));
				                               end;
				                           end;
                             end;
      ParamPressePapierCmd : begin 
                               if enRetour
                                 then SetParamDiag(ParamDiagPartieFFORUM)
                                 else SetParamDiag(ParamDiagPositionFFORUM);
                               ConstruitPositionEtCoupDapresPartie(PositionEtCoupStr);
                               
                               ParserPositionEtCoupsOthello8x8(positionEtCoupStr,chainePositionInitiale,chaineCoups);
		                       chainePosition := ConstruitChainePosition8x8(jeuCourant);
		
                               GetIndString(s,TextesImpressionID,1);
                               if DoDiagrammeFFORUM(s,chainePositionInitiale,chainePosition,chaineCoups) then;
                               if enRetour
                                 then GetParamDiag(ParamDiagPartieFFORUM)
                                 else GetParamDiag(ParamDiagPositionFFORUM);
                             end;
       RaccourcisCmd : DoChangeDessineAide;
    end;
  end;
end;


procedure DoCopierSpecialMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}
    case cmdNumber of
      CopierSequenceCoupsEnTEXTCmd       : CopierPartieEnTEXT(true,false);
      CopierDiagrammePartieEnTEXTCmd     : CopierDiagrammePartieEnTEXT;
      CopierPositionCouranteEnTEXTCmd    : CopierDiagrammePositionEnTEXT;
      CopierPositionCouranteEnHTMLCmd    : CopierDiagrammePositionEnHTML;
      CopierPositionPourEndgameScriptCmd : CopierPositionPourEndgameScriptEnTEXT;
      CopierDiagramme10x10Cmd            : DoDiagramme10x10;              
    end;
  end;

procedure DoNMeilleursCoupsMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
var n : SInt16; 
  begin
    {$UNUSED peutRepeter}
    n := cmdNumber+1;
    SetMenuItemText(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd,ParamStr(ReadStringFromRessource(MenusChangeantsID,17),NumEnString(n),'','',''));
    DoMilieuDeJeuNormal(n,true);
  end;
  

procedure DoPartieMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    case cmdNumber of
     RevenirCmd             : begin
                                if windowPaletteOpen then FlashCasePalette(PaletteDiagramme);
                                DoRevenir;
                              end;
     DebutCmd               : DoDebut(false);
     BackCmd                : if PeutArreterAnalyseRetrograde() then
                                begin
                                  AccelereProchainDoSystemTask(2);
                                  gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
                                  if theEvent.what=autoKey
                                    then DoDoubleBackMove
                                    else DoBackMove;
                                  peutRepeter := (nbreCoup>0);
                                end;
     ForwardCmd             : if PeutArreterAnalyseRetrograde() then
                                begin
                                  AccelereProchainDoSystemTask(2);
                                  gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
                                  if theEvent.what=autoKey
                                    then DoDoubleAvanceMove
                                    else DoAvanceMove;
                                  AccelereProchainDoSystemTask(2);
                                  peutRepeter := not(gameOver);
                                end;
     DoubleBackCmd          : if PeutArreterAnalyseRetrograde() then 
                                begin
                                  AccelereProchainDoSystemTask(2);
                                  gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
                                  DoDoubleBackMove;
                                  AccelereProchainDoSystemTask(2);
                                  peutRepeter := (nbreCoup>0);
                                end;
     DoubleForwardCmd       : if PeutArreterAnalyseRetrograde() then 
                                begin
                                  AccelereProchainDoSystemTask(2);
                                  gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
                                  DoDoubleAvanceMove;
                                  AccelereProchainDoSystemTask(2);
                                  peutRepeter := not(gameOver);
                                end;
     DiagrameCmd            : begin
                                if windowPaletteOpen then FlashCasePalette(PaletteDiagramme);
                                DoRevenir;
                              end;
     TaperUnDiagrammeCmd   : DoChangeEnModeEntreeTranscript;
     MakeMainBranchCmd      : DoMakeMainBranch;
     DeleteMoveCmd          : if CurseurEstEnTeteDeMort()
                                then SetNiveauTeteDeMort(0)
                                else SetNiveauTeteDeMort(2);
     SetUpCmd               : DoSetUp;
     ForceCmd               : if PeutArreterAnalyseRetrograde() then
                                begin
                                  RemoveDelayAfterKeyboardOperation;
                                  DoForcerMacAJouerMaintenant;
                                  AccelereProchainDoSystemTask(1);
                                end;
     PoserMarqueCmd         : DoInsererMarque;
     AvanceMarqueCmd        : begin
                                if windowPaletteOpen then FlashCasePalette(PaletteAllerFin);
                                if PeutArreterAnalyseRetrograde() then
                                  DoAvanceProchaineMarque;
                              end;
     ReculeMarqueCmd        : begin
                                if windowPaletteOpen then FlashCasePalette(PaletteRetourDebut);
                                if PeutArreterAnalyseRetrograde() then 
                                  DoRetourDerniereMarque;
                              end;
    end;
  end;

procedure DoModeMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}
    
    case cmdNumber of
     CadenceCmd                    : begin
                                       if windowPaletteOpen then FlashCasePalette(PaletteHorloge);
                                       DoCadence;
                                     end;
     ReflSurTempsAdverseCmd        : DoChangeAvecReflexionTempsAdverse;
     BiblActiveCmd                 : DoChangeAvecBibl;
     VarierOuverturesCmd           : DoChangeVarierOuvertures;
     MilieuDeJeuNormalCmd          : begin
                                       SetMenuItemText(ModeMenu,MilieuDeJeuNMeilleursCoupscmd,ReadStringFromRessource(MenusChangeantsID,18));
                                       DoMilieuDeJeuNormal(1,true);
                                     end;
     MilieuDeJeuNMeilleursCoupsCmd : DoMilieuDeJeuNormal(nbCoupsEnTete,true);
     MilieuDeJeuAnalyseCmd         : DoMilieuDeJeuAnalyse(true);
     FinaleGagnanteCmd             : DoFinaleGagnante(true);
     FinaleOptimaleCmd             : DoFinaleOptimale(true);
     CoeffEvalCmd                  : DoCoefficientsEvaluation;
     ParametrerAnalyseRetrogradeCmd: DoParametrerAnalyseRetrograde;
     AnalyseRetrogradeCmd          : DoDemandeAnalyseRetrograde(analyseRetrograde.nbPresentationsDialogue>=1);
    end;
  end;
   
procedure DoJoueursMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}
    
    case cmdNumber of
      HumCreHumCmd   :   DoDemandeChangerHumCtreHum;
      MacBlancsCmd   :   if (couleurMacintosh <> pionBlanc) then 
                           if PeutArreterAnalyseRetrograde() then DoDemandeChangeCouleur;
      MacNoirsCmd    :   if (couleurMacintosh <> pionNoir) then 
                           if PeutArreterAnalyseRetrograde() then DoDemandeChangeCouleur;
      MinuteBlancCmd :   DoAjouteTemps(pionBlanc);
      MinuteNoirCmd  :   DoAjouteTemps(pionNoir);
    end;
  end;
   
procedure DoAffichageMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}
  
    case cmdNumber of
     ChangerEn3DCmd         : DoChangeEn3D(true);
     Symetrie_A1_H8Cmd      : if PeutArreterAnalyseRetrograde() then
                                DoSymetrie(axeSW_NE);
     Symetrie_A8_H1Cmd      : if PeutArreterAnalyseRetrograde() then
                                DoSymetrie(axeSE_NW);
     DemiTourCmd            : if PeutArreterAnalyseRetrograde() then
                                DoSymetrie(central);
                                
     ConfigurerAffichageCmd : DoDialoguePreferencesAffichage;
     ReflexionsCmd          : begin
                                {if windowPaletteOpen then FlashCasePalette(PaletteReflexion);}
                                DoChangeAfficheReflexion;
                              end;
     RapportCmd             : DoRapport;
     CourbeCmd              : begin
                                {if windowPaletteOpen then FlashCasePalette(PaletteCourbe);}
                                DoCourbe;
                              end;
     GestionTempsCmd        : DoChangeAfficheGestionTemps;
     CommentairesCmd        : DoCommentaires;
     PaletteFlottanteCmd    : DoChangePalette;
     SonCmd                 : DoSon;
    end;
  end;
  
procedure DoSolitairesMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}
    
    case cmdNumber of
      JouerNouveauSolitaireCmd           : {ProcessEachSolitaireOnDisc(0,10000000);}
                                           if PeutArreterAnalyseRetrograde() then DoDemandeJouerSolitaires;
      ConfigurationSolitaireCmd          : DoDialogueConfigurationSolitaires;
      EcrireSolutionSolitaireCmd         : DoEcritureSolutionSolitaire;
      EstSolitaireCmd                    : DoEstUnSolitaire;
      ChercherNouveauProblemeDeCoinCmd   : if PeutArreterAnalyseRetrograde() then ChercherUnProblemeDePriseDeCoinAleatoire(20,35);
      ChercherProblemeDeCoinDansListeCmd : if PeutArreterAnalyseRetrograde() then ChercherUnProblemeDePriseDeCoinDansListe(20,40);
      EstProblemeDeCoinCmd               : ChercherUnProblemeDePriseDeCoinDansPositionCourante;
    end;
  end;
  
procedure DoBaseMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}
    
    case cmdNumber of
     ChargerDesPartiesCmd          : begin
                                       if windowPaletteOpen then FlashCasePalette(PaletteBase);
                                       DoChargerLaBase;
                                     end;
     EnregistrerPartiesBaseCmd     : ; { Desormais géré par un sous-menu}
     AjouterPartieDansListeCmd     : DialogueSaisiePartie;
     ChangerOrdreCmd               : DoChangerOrdreListe;
     OuvrirSelectionneeCmd         : OuvrePartieSelectionnee(infosListeParties.partieHilitee);
     JouerSelectionneCmd           : if windowListeOpen & (nbPartiesActives>0) then
                                      if PeutArreterAnalyseRetrograde() then
                                        begin
                                          AccelereProchainDoSystemTask(2);
                                          gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
	                                        if BAND(theEvent.modifiers,shiftKey)=0
	                                          then if theEvent.what=autoKey
	                                                 then DoDoubleAvanceMovePartieSelectionnee(infosListeParties.partieHilitee)
	                                                 else JoueCoupPartieSelectionnee(infosListeParties.partieHilitee)
	                                          else if theEvent.what=autoKey
	                                                 then DoDoubleBackMovePartieSelectionnee(infosListeParties.partieHilitee)
	                                                 else DoBackMovePartieSelectionnee(infosListeParties.partieHilitee);
	                                      end;
     JouerMajoritaireCmd           : begin
                                       AccelereProchainDoSystemTask(2);
                                       gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
                                       JoueCoupMajoritaireStat;
                                     end;
     StatistiqueCmd                : begin
                                       {if windowPaletteOpen then FlashCasePalette(PaletteStatistique);}
                                       DoStatistiques;
                                     end;
     ListePartiesCmd               : begin
                                       {if windowPaletteOpen then FlashCasePalette(PaletteListe);}
                                       DoListeDeParties;
                                     end;
     SousSelectionActiveCmd        : DoChangeSousSelectionActive;
     CriteresCmd                   : DoCriteres;
     AjouterGroupeCmd              : DoAjouterGroupe;
     ListerGroupesCmd              : DoListerLesGroupes;
     InterversionCmd               : DoChangeInterversions;
     AlerteInterversionCmd         : DoChangeAlerteInterversion;
    end;
  end;

  
procedure DoProgrammationMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  var nbreParties : SInt32;
  begin
    {$UNUSED peutRepeter}
    
    case cmdNumber of
     AjusterModeleLineaireCmd  : {Afficher_ZebraBook;}
                                 {ImportBaseAllDrawLinesDeBougeard;}
                                 EpoquesDesJoueursDeLaListe;
                                 {AjusteModeleLineaireFinale;}
     ChercherSolitairesListeCmd  : ChercheSolitairesDansListe(1,nbPartiesActives,1,60);
                                   {ChercheSolitairesDansListe(1,nbPartiesActives,60-nbCasesVidesMaxSolitaire+1,60-nbCasesVidesMinSolitaire+1);}
                                   {ChercheSolitairesDansListe(1,nbPartiesActives,50,55);}
                                 {TestNouvelleEval;}
                                 {ApprendToutesLesPartiesActives;}
                                 {ApprendCoeffsLignesPartiesDeLaListe;}
                                 {ApprendCoeffsPartiesDeLaListeAlaBill;}
                                 {ApprendBlocsDeCoinPartiesDeLaListe;}
                                 
                                 {
                                 if BAND(theEvent.modifiers,optionKey) <> 0
                                   then
                                     begin
                                       profMinimalePourTriDesCoupsParAlphaBeta := profMinimalePourTriDesCoupsParAlphaBeta-1;
                                       WriteDansRapport('profMinimalePourTriDesCoupsParAlphaBeta=');
                                       WritelnDansRapport(NumEnString(profMinimalePourTriDesCoupsParAlphaBeta));
                                     end
                                   else
                                     begin
                                       profMinimalePourTriDesCoupsParAlphaBeta := profMinimalePourTriDesCoupsParAlphaBeta+1;
                                       WriteDansRapport('profMinimalePourTriDesCoupsParAlphaBeta=');
                                       WritelnDansRapport(NumEnString(profMinimalePourTriDesCoupsParAlphaBeta));
                                     end;
                                  }
                                  
     VariablesSpecialesCmd           : DoDialoguePreferencesSpeciales;  
     OuvrirBiblCmd                   : DoOuvrirBibliotheque;
     effetspecial1Cmd                : DoChangeEffetSpecial1;
     effetspecial2Cmd                : DoChangeEffetSpecial2;
     NettoyerGrapheCmd               : NettoyerGrapheApprentissage(nomGrapheInterversions);
     CompterPartiesGrapheCmd         : CompterLesPartiesDansGrapheApprentissage(40,nbreParties);
     AffCelluleApprentissaCmd        : VoirLesInfosDApprentissageDansRapport;
     DemoCmd                         : DoChoisitDemo;
     EcrireDansRapportLogCmd         : DoChangeEcrireDansRapportLog;
     UtiliserNouvelleEvalCmd         : DoChangeUtilisationNouvelleEval;
     TraitementDeTexteCmd            : DoChangeEnTraitementDeTexte;
     ArrondirEvaluationsCmd          : DoChangeArrondirEvaluations;
     UtiliserScoresArbreCmd          : DoChangeFaireConfianceScoresArbre;  
     GestionBaseWThorCmd             : ;
     Unused2Cmd                      : ;
                                       {TestMobiliteBitbooard(PositionEtTraitCourant());}
                                       {if DernierEvenement.option
                                         then EcritListeJoueursBlancsNonJaponaisPourTraduction
                                         else EcritListeJoueursNoirsNonJaponaisPourTraduction;}
     Unused3Cmd                      : EcritListeTournoisPourTraductionJaponais;
     Unused4Cmd                      : ;
     Unused5Cmd                      : ;
    end;
  end;


procedure DoCouleurMenuCommands(menuID,cmdNumber : SInt16; var peutRepeter : boolean);
var gBlackAndWhiteArrivee : boolean;
    visibleRgn : RgnHandle;
begin
  {$UNUSED peutRepeter}
  
  if (menuID = Picture2DID) then
    begin
      DoPicture2DMenuCommands(menuID,cmdNumber,peutRepeter,false);
      exit(DoCouleurMenuCommands);
    end;
  
  if (menuID = CouleurID) then
    begin
		  
		  gBlackAndWhiteArrivee := gBlackAndWhite;
		  gCouleurOthellier := CalculeCouleurRecord(CouleurID,cmdNumber);
		  
				   
		  gEcranCouleur                := true;
		  gBlackAndWhite               := not(gEcranCouleur);
		  
		  SetEnVieille3D(false);
		  KillPovOffScreenWorld;
		  if windowPaletteOpen & BooleanXor(gBlackAndWhite,gBlackAndWhiteArrivee) then DessinePalette;
		  SetPositionsTextesWindowPlateau;
		  
		  visibleRgn := NewRgn();
		  EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),true);
		  DisposeRgn(visibleRgn);
		  
		  {sauvegarde de la derniere texture 2D utilisee}
		  gLastTexture2D.theMenu  := CouleurID;
		  gLastTexture2D.theCmd := cmdNumber;
		end;
end;


procedure DoPicture2DMenuCommands(menuID,cmdNumber : SInt16; var peutRepeter : boolean;avecAlerte : boolean);
var fic : FichierTEXT;
    gBlackAndWhiteArrivee : boolean;
    s : str255;
    visibleRgn : RgnHandle;
begin
  
  if (menuID = CouleurID) then
    begin
      DoCouleurMenuCommands(menuID,cmdNumber,peutRepeter);
      exit(DoPicture2DMenuCommands);
    end;
    
  if (menuID = Picture2DID) then
    begin
		  gBlackAndWhiteArrivee := gBlackAndWhite;
		  gCouleurOthellier := CalculeCouleurRecord(Picture2DID,cmdNumber);
		  
		  if not(FichierPhotosExisteSurLeDisque(GetPathCompletFichierPionsPourCetteTexture(gCouleurOthellier),fic))
		    then 
		      begin
		        s := GetNomDansMenuPourCetteTexture(gCouleurOthellier);
		        gCouleurOthellier := CalculeCouleurRecord(CouleurID,VertPaleCmd);
		        if avecAlerte then AlerteFichierPhotosNonTrouve(s);
		        DoCouleurMenuCommands(CouleurID,VertPaleCmd,peutRepeter);
		      end
		    else
		      begin
		        if not(gPendantLesInitialisationsDeCassio) then
		          begin
		            watch := GetCursor(watchcursor);
		            SafeSetCursor(watch);
		          end;
		        
		        SetEnVieille3D(false);
		        KillPovOffScreenWorld;
		        SetPositionsTextesWindowPlateau;
		        
		        visibleRgn := NewRgn();
		        EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),true);
		        DisposeRgn(visibleRgn);
		        
		        {sauvegarde de la derniere texture 2D utilisee}
		        gLastTexture2D.theMenu  := Picture2DID;
		        gLastTexture2D.theCmd := cmdNumber;
		      end;
		  AjusteCurseur;
		end;
end;

procedure DoPicture3DMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean;avecAlerte : boolean);
const AlertePbMemoire3DID = 258;
var fic : FichierTEXT;
    error : OSErr;
    nomDansMenu,path,s : str255;
    item : SInt16; 
    visibleRgn : RgnHandle;
begin
  
  gCouleurOthellier := CalculeCouleurRecord(Picture3DID,cmdNumber);
  
  nomDansMenu := GetNomDansMenuPourCetteTexture(gCouleurOthellier);
  path := PathFichierPicture3DDeCetteFamille(nomDansMenu,pionNoir);
  
  if not(FichierPhotosExisteSurLeDisque(path,fic))
    then
      begin
        s := GetNomDansMenuPourCetteTexture(gCouleurOthellier);
        
        gCouleurOthellier := CalculeCouleurRecord(gLastTexture2D.theMenu,gLastTexture2D.theCmd);
        if avecAlerte then AlerteFichierPhotosNonTrouve(s);
        DoPicture2DMenuCommands(gLastTexture2D.theMenu,gLastTexture2D.theCmd,peutRepeter,false);
      end
    else
      begin
        if not(gPendantLesInitialisationsDeCassio) then
          begin
            watch := GetCursor(watchcursor);
            SafeSetCursor(watch);
          end;
        
        error := LitFichierCoordoneesImages3D(gCouleurOthellier);
        
        if error <> NoErr then
          begin
            WritelnStringAndNumDansRapport(' error <> NoErr (1) dans DoPicture3DMenuCommands, error =',error);
            KillPovOffScreenWorld;
            RepasserEn2D(false);
            exit(DoPicture3DMenuCommands);
          end;
  
        error := CreatePovOffScreenWorld(gCouleurOthellier);
        
        if error <> NoErr then
          begin
            if avecAlerte & ((error = opWrErr) | (error = memFullErr) | (error = cTempMemErr) | (error = cNoMemErr))
              then item := MySimpleAlerte(AlertePbMemoire3DID,'')
              else WritelnStringAndNumDansRapport(' error <> NoErr (2) dans DoPicture3DMenuCommands, error =',error);
            KillPovOffScreenWorld;
            RepasserEn2D(false);
            exit(DoPicture3DMenuCommands);
          end;
        
        SetEnVieille3D(false);
        SetCalculs3DMocheSontFaits(false);
        AjusteTailleFenetrePlateauPourLa3D;
        SetPositionsTextesWindowPlateau;
        
        visibleRgn := NewRgn();
        EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),true);     
        DisposeRgn(visibleRgn);
        
        {sauvegarde de la derniere texture 3D utilisee}
        gLastTexture3D.theMenu  := Picture3DID;
        gLastTexture3D.theCmd   := cmdNumber;
      end;
  AjusteCurseur;
end;

procedure DoTriMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}
    
    case cmdNumber of
      TriParDatabaseCmd    : DoTrierListe(TriParDistribution,kRadixSort);
      TriParDateCmd        : DoTrierListe(TriParDate,kRadixSort);
      TriParJoueurNoirCmd  : DoTrierListe(TriParJoueurNoir,kRadixSort);
      TriParJoueurBlancCmd : DoTrierListe(TriParJoueurBlanc,kRadixSort);
      TriParOuvertureCmd   : DoTrierListe(TriParOuverture,kQuickSort);
      TriParTheoriqueCmd   : DoTrierListe(TriParScoreTheorique,kRadixSort);
      TriParReelCmd        : DoTrierListe(TriParScoreReel,kRadixSort);
    end;
  end;
  
procedure DoFormatBaseMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}
    
    case cmdNumber of
      FormatWTBCmd   : if (SauvegardeListeCouranteAuNouveauFormat(FiltrePartieEstActiveEtSelectionnee) <> NoErr) 
                         then AlerteSimple('L''enregistrement a échoué, désolé');
      FormatPARCmd   : if SauvegardeListeCouranteEnTHOR_PAR() <> NoErr
                         then AlerteSimple('L''enregistrement a échoué, désolé');
      FormatTexteCmd : DoExporterListeDePartiesEnTexte;
      FormatHTMLCmd  : ExportListeAuFormatHTML;
      FormatPGNCmd   : ExportListeAuFormatPGN;
      FormatXOFCmd   : ExportListeAuFormatXOF;
    end;
  end;

procedure DoReouvrirMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
var nomComplet : str255;
    ficPartie : FichierTEXT;
    erreurES : SInt16; 
  begin
    {$UNUSED peutRepeter}
    
    nomComplet := GetNomCompletFichierDansMenuReouvrir(cmdNumber);
    
    if (nomComplet <> '') then
      begin
        erreurES := FichierTexteExiste(nomComplet,0,ficPartie);
		    if erreurES<>NoErr then
		      begin
            AlerteSimpleFichierTexte(nomComplet,erreurES);
            SetReouvrirItem('',cmdNumber);
            CleanReouvrirMenu;
            exit(DoReouvrirMenuCommands);
          end;
			  
        AjoutePartieDansMenuReouvrir(nomComplet);
        erreurES := OuvrirFichierParNomComplet(nomComplet,true);
      end;
  end;

procedure DoGestionBaseWThorMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
var err : OSErr;
begin
  {$UNUSED peutRepeter}
  case cmdNumber of
     ChangerTournoiCmd                : CreerOuRenommerMachinDansLaBaseOfficielle;
     ChangerJoueurNoirCmd             : CreerOuRenommerMachinDansLaBaseOfficielle;
     ChangerJoueurBlancCmd            : CreerOuRenommerMachinDansLaBaseOfficielle;
     SelectionnerTheoriqueEgalReelCmd : SelectionnerPartiesOuScoreTheoriqueEgalScoreReel;
     CalculerScoreTheoriqueCmd        : err := DoActionGestionBaseOfficielle('recalculate');
     CreerTournoiCmd                  : CreerOuRenommerMachinDansLaBaseOfficielle;
     CreerJoueurCmd                   : if (NombreDeLignesDansSelectionRapport() >= 2)
                                          then CreerPlusieursJoueursDansBaseOfficielle
                                          else CreerOuRenommerMachinDansLaBaseOfficielle;
  end;
end;

procedure DoMenuCommand(command : SInt32; var peutRepeter : boolean);
  var whichMenu : SInt16; 
      whichItem : SInt16; 
      err : OSErr;
  begin
    whichMenu := HiWrd(command);
    whichItem := LoWrd(command);
    
    if (whichMenu=0) then exit(DoMenuCommand);
    { no real menu command, so we don't want to confirm inline input text }
    
    
    if (whichMenu<>EditionID) | (whichItem<Coupercmd) | (whichItem>toutSelectionnercmd) then
      AnnulerSousCriteresRuban;
    
    if FenetreRapportEstAuPremierPlan() &
       (GetTSMDocOfRapport() <> NIL)
			then err := FixTSMDocument(GetTSMDocOfRapport());
      
    peutRepeter := false;
    case whichMenu of
      appleID            : DoPommeMenuCommands(whichItem,peutRepeter);
      FileID             : DoFileMenuCommands(whichItem,peutRepeter);
      EditionID          : DoEditionMenuCommands(whichItem,peutRepeter);
      PartieID           : DoPartieMenuCommands(whichItem,peutRepeter);
      ModeID             : DoModeMenuCommands(whichItem,peutRepeter);
      JoueursID          : DoJoueursMenuCommands(whichItem,peutRepeter);
      AffichageID        : DoAffichageMenuCommands(whichItem,peutRepeter);
      CouleurID          : begin
                             if whichItem=AutreCouleurCmd then 
                               begin
                                 if ChoisirCouleurOthellierAvecPicker(gCouleurSupplementaire)
                                   then InvalidateAllOffScreenPICTs
                                   else exit(DoMenuCommand);
                               end;
                             RestaurerDerniereDimensionFenetre2D;
                             DoCouleurMenuCommands(CouleurID,whichItem,peutRepeter);
                           end;
      Picture2DID        : begin
                             RestaurerDerniereDimensionFenetre2D;
                             DoPicture2DMenuCommands(Picture2DID,whichItem,peutRepeter,true);
                           end;
      Picture3DID        : begin
                             SauvegarderDerniereDimensionFenetre2D;
                             DoPicture3DMenuCommands(whichItem,peutRepeter,true);
                           end;
      SolitairesID       : DoSolitairesMenuCommands(whichItem,peutRepeter);
      BaseID             : DoBaseMenuCommands(whichItem,peutRepeter);
      TriID              : DoTriMenuCommands(whichItem,peutRepeter);
      FormatBaseID       : DoFormatBaseMenuCommands(whichItem,peutRepeter);
      CopierSpecialID    : DoCopierSpecialMenuCommands(whichItem,peutRepeter);
      NMeilleursCoupID   : DoNMeilleursCoupsMenuCommands(whichItem,peutRepeter);
      ReouvrirID         : DoReouvrirMenuCommands(whichItem,peutRepeter);
      GestionBaseWThorID : DoGestionBaseWThorMenuCommands(whichItem,peutRepeter);
      ProgrammationID    : DoProgrammationMenuCommands(whichItem,peutRepeter);
    end;
    EndHiliteMenu(theEvent.when,10,peutRepeter);
    EssaieUpdateEventsWindowPlateau;
  end;


procedure DoKeyPress(ch : char; var peutRepeter : boolean);
const MachineAEcrireID=10129;
var shift,command,option,control : boolean;
    long,i : SInt16; 
    ancPosPouce : SInt32;
    numeroFilsCherche,square : SInt32;
    temposon : boolean;
    s : str255;
    caract:charsHandle;
   {tempoSon : boolean;
    FilsConnus:listeDeCoups;}
begin
  shift := BAND(theEvent.modifiers,shiftKey) <> 0;
  command := BAND(theEvent.modifiers,cmdKey) <> 0;
  option := BAND(theEvent.modifiers,optionKey) <> 0;
  control := BAND(theEvent.modifiers,controlKey) <> 0;
 
  {if ch='∆' then Debugger;}
    
  {WriteStringAndNumAt('code du caractere :',ord(ch),100,100);}
  MySystemTask;
  
  
  {WritelnStringAndBoolDansRapport('EnModeEntreeTranscript() = ',EnModeEntreeTranscript());}
    
  if EnTraitementDeTexte & FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan()
    then
      begin
        if (ord(ch)=EscapeKey)
          then DoChangeEnTraitementDeTexte
          else
            begin
              FrappeClavierDansRapport(ch);
              UpdateScrollersRapport;
              PlaySoundSynchrone(MachineAEcrireID);
              if (ch = cr) then 
                begin
                  s := GetAvantDerniereLigneCouranteDuRapport();
                  if DoActionGestionBaseOfficielle(s) = NoErr then;
                end;
            end
      end
    else
      if FenetreListeEnModeEntree()
        then
          begin
            if (ord(ch)=ReturnKey) then 
              begin
                ValiderSousCritereRuban;
                exit(DoKeyPress);
              end;
            if (ord(ch)=TabulationKey) | (ord(ch)=EntreeKey) then 
              begin
                { Deplacement dans les champs de criteres actifs :
                    tabulation    => on circule en sens positif
                    majuscule-tab => on circule en sens negatif.
                  Le logique est compliquee par le fait que certains 
                  champs peuvent etre caches si la fenetre est reduite }
                if shift 
                  then  
		                case nbColonnesFenetreListe of
		                  kAvecAffichageDistribution :
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := DistributionRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := TournoiRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                  kAvecAffichageTournois :
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := TournoiRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                  otherwise
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                end {case}
		              else
		                case nbColonnesFenetreListe of
		                  kAvecAffichageDistribution :
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := DistributionRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := TournoiRubanBox;
		                    end;
		                  kAvecAffichageTournois :
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := TournoiRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                  otherwise
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                end; {case}
                
                  if BoiteDeSousCritereActive <= 0 then BoiteDeSousCritereActive := DistributionRubanBox;
                  PasseListeEnModeEntree(BoiteDeSousCritereActive);
                  exit(DoKeyPress);
              end;
            if (ord(ch)=EscapeKey)
              then AnnulerSousCriteresRuban
              else 
                begin
                  TEKey(ch,SousCriteresRuban[BoiteDeSousCritereActive]);
                  CriteresRubanModifies := true;
                   
                  long := TEGetTextLength(SousCriteresRuban[BoiteDeSousCritereActive]);
                  if long>245 then long := 245;
                  caract := TEGetText(SousCriteresRuban[BoiteDeSousCritereActive]);
                  s := '';for i := 1 to long do s := s+caract^^[i-1];
                  if s[long]='=' then
                    begin
                      if not(JoueursEtTournoisEnMemoire) &
                         avecGestionBase & not(problemeMemoireBase) then
                        DoLectureJoueursEtTournoi(false);
                      s := TPCopy(s,1,long-1);
                      case BoiteDeSousCritereActive of
                        JoueurNoirRubanBox   : s := Complemente(complementationJoueurNoir,s,i);
                        JoueurBlancRubanBox  : s := Complemente(complementationJoueurBlanc,s,i);
                        TournoiRubanBox      : s := Complemente(complementationTournoi,s,i);
                        DistributionRubanBox : s := s;
                      end;
                      TESetText(@s[1],Length(s),SousCriteresRuban[BoiteDeSousCritereActive]);
                      TESetSelect(i,MaxInt,SousCriteresRuban[BoiteDeSousCritereActive]);  
                      SetPortByWindow(wListePtr);
                      InvalRect(TEGetViewRect(SousCriteresRuban[BoiteDeSousCritereActive]));
                    end;
                  
                  EcritRubanListe(true);
                       
                end;
          end
        else
          begin
            if EnModeEntreeTranscript() then
              begin
                if TraiteKeyboardEventDansTranscript(ch,peutRepeter)
                  then exit(DoKeyPress);
              end;
    
		        if enRetour 
		          then
		            begin
		              if (ord(ch)=ReturnKey) | (ord(ch)=EntreeKey) | (ord(ch)=RetourArriereKey) | (ord(ch)=EscapeKey)
		                then humainVeutAnnuler := true;
		            end
		          else
		            begin
		              if (ord(ch)=ReturnKey) then {return}
		                begin
		                  if FenetreRapportEstOuverte() & 
		                     SelectionRapportNonVide() & 
		                     FenetreRapportEstAuPremierPlan()
		                    then
		                      begin
		                        if PeutCompleterPartieAvecSelectionRapport(s) & PeutArreterAnalyseRetrograde() then
		                          begin
		                            PlaquerPartieLegale(s,kNePasRejouerLesCoupsEnDirect);
		                            if not(HumCtreHum) & not(CassioEstEnModeAnalyse()) then DoChangeHumCtreHum;
		                          end;
		                      end
		                    else
		                      begin
		                        if windowlisteOpen & (nbPartiesActives >= 1) & PeutArreterAnalyseRetrograde() then 
		                          OuvrePartieSelectionnee(infosListeParties.partieHilitee);
		                      end;
		                end;
		                 
		              if (ord(ch)=EntreeKey) then  {entree}
		                if windowListeOpen & (nbPartiesChargees > 0) then
		                  begin
		                    if wListePtr<>FrontWindowSaufPalette() then DoListeDeParties;
		                    if not(sousSelectionActive) then DoChangeSousSelectionActive;
		                    case nbColonnesFenetreListe of
				                  kAvecAffichageDistribution        : BoiteDeSousCritereActive := DistributionRubanBox;
				                  kAvecAffichageTournois            : BoiteDeSousCritereActive := TournoiRubanBox;
				                  kAvecAffichageSeulementDesJoueurs : BoiteDeSousCritereActive := JoueurNoirRubanBox;
				                end; {case}
		                    PasseListeEnModeEntree(BoiteDeSousCritereActive);
		                    CriteresRubanModifies := false;
		                    exit(DoKeyPress);
		                  end;
		                  
		              if (ord(ch)=TabulationKey) & windowListeOpen then
		                if not(shift) 
		                  then
			                  case nbColonnesFenetreListe of
					                kAvecAffichageDistribution        : DoChangeEcritTournoi(kAvecAffichageSeulementDesJoueurs);
					                kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageDistribution);
					                kAvecAffichageSeulementDesJoueurs : DoChangeEcritTournoi(kAvecAffichageTournois);
					              end {case}
					            else
					              begin
  					             (* case nbColonnesFenetreListe of
  					                kAvecAffichageDistribution        : DoChangeEcritTournoi(kAvecAffichageTournois);
  					                kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageSeulementDesJoueurs);
  					                kAvecAffichageSeulementDesJoueurs : DoChangeEcritTournoi(kAvecAffichageDistribution);
  					              end; {case} *)
  					              listeEtroiteEtNomsCourts := not(listeEtroiteEtNomsCourts);
  					              DoChangeEcritTournoi(nbColonnesFenetreListe);
  					            end;
		            end;
		            
		        if not(enSetUp) then
		          begin
		            EnregisterToucheClavier(ch,theEvent.when);
		            if not(EstEnAttenteSelectionRapideDeListe()) then
			            begin
			              case ch of
				              '$':EcritNewEvalIntegerDansRapport(jeuCourant,emplJouable,frontiereCourante,nbreDePions[pionNoir],nbreDePions[pionBlanc],aQuiDeJouer,vecteurEvaluationInteger);
				              {'*':EcritNewEvalDansRapport(jeuCourant,emplJouable,frontiereCourante,nbreDePions[pionNoir],nbreDePions[pionBlanc],aQuiDeJouer,vecteurEvaluation);}   
				              '*':WritelnZebraValuesDansRapport(PositionEtTraitCourant());
				              
				              '©','¢':if not(enModeIOS) & not(CassioEstEnModeAnalyse()) &  {option-c}
				                         PeutArreterAnalyseRetrograde() 
				                        then DoDemandeChangeCouleur;
				              'π','∏':DoProgrammation;
				              'Æ'    :TestRegressionLineaire;                              {option-maj-A}
				              'Ω'    :DessineNuageDePointsRegression;						           {option-maj-Q}
				              '‡'    :HistogrammeDesMoyennesParScoreTheoriqueDansRapport;  {option-Q}
				              '®','€','Â','Å':  {option-r, option-z}
				                         begin
				                           if windowPaletteOpen then FlashCasePalette(PaletteRetourDebut);
				                           if PeutArreterAnalyseRetrograde() then
				                             begin
				                               DoRetourDerniereMarque;  
				                               peutRepeter := (nbreCoup>0);
				                             end;
				                         end;    
				              'ê','Ê':    {option-e}
				                         begin    
				                           if windowPaletteOpen then FlashCasePalette(PaletteAllerFin);
				                           if PeutArreterAnalyseRetrograde() then
				                             begin
				                               DoAvanceProchaineMarque;
				                               peutRepeter := not(gameOver);
				                             end;
				                         end;
				              ' ',' ':if not(enModeIOS) then
				                         begin
				                           AccelereProchainDoSystemTask(2);
				                           gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
				                           JoueCoupMajoritaireStat;
				                           peutRepeter := not(gameOver);
				                         end;
				              'e','E':if not(enModeIOS) & PeutArreterAnalyseRetrograde() then 
				                           begin
				                             AccelereProchainDoSystemTask(2);
				                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
				                             if (theEvent.what=autoKey) | shift
				                               then DoDoubleAvanceMove
				                               else DoAvanceMove;
				                             peutRepeter := not(gameOver);
				                           end;
				              'r','R','z','Z':if not(enModeIOS) & PeutArreterAnalyseRetrograde() then 
				                           begin
				                             AccelereProchainDoSystemTask(2);
				                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
				                             if (theEvent.what=autoKey) | shift
				                               then DoDoubleBackMove
				                               else DoBackMove;
				                             peutRepeter := (nbreCoup>0);
				                           end;
				              'p','P':if not(enModeIOS) & PeutArreterAnalyseRetrograde() then 
				                           begin
				                             AccelereProchainDoSystemTask(2);
				                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
				                             DoDoubleAvanceMove;
				                             if shift then DoDoubleAvanceMove;
				                             peutRepeter := not(gameOver);
				                           end;
				              'o','O':if not(enModeIOS) & PeutArreterAnalyseRetrograde() then 
				                           begin
				                             AccelereProchainDoSystemTask(2);
				                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
				                             DoDoubleBackMove;
				                             if shift then DoDoubleBackMove;
				                             peutRepeter := (nbreCoup>0);
				                           end;
				              'l','L':begin
				                        {if windowPaletteOpen then FlashCasePalette(PaletteListe);}
				                        DoListeDeParties;
				                      end;
				              's','S':begin
				                        {if windowPaletteOpen then FlashCasePalette(PaletteStatistique);}
				                        DoStatistiques;
				                      end;
				              'k','K':begin
				                        {if windowPaletteOpen then FlashCasePalette(PaletteCourbe);}
				                        DoCourbe;
				                      end;
				              '"','3':if not(enRetour | enSetUp) then DoChangeEn3D(true);
				              '''','4',
				              '‘','’':ChercherLeProchainNoueudAvecBeaucoupDeFils(4);
				              
				              'È','Ë':ChercherUnProblemeDePriseDeCoinDansPositionCourante;  {option-k}
				             
				              '≈','⁄':if not(gameOver) then                       {option-x}
				                           DoDemandeChangerHumCtreHumEtCouleur;
				              'ƒ','·':if not(gameOver) then                       {option-f}
				                           begin                  
				                             DoFinaleOptimale(true);
				                             DoDemandeChangerHumCtreHumEtCouleur;
				                           end;
				              'ﬁ','ﬂ':if not(gameOver) then                       {option-g}
				                           begin                  
				                             DoFinaleGagnante(true);
				                             DoDemandeChangerHumCtreHumEtCouleur;
				                           end;
				              '•','Ÿ': begin                                       {option-@}
				                         CopierPucesNumerotees;    
				                         peutRepeter := true;
				                       end;
				               '='   : DoChangePalette;
				               '+'   : if not(command) then DoChangePalette;
				               
				               '{','[': AfficheProchainProblemeStepanov;   {option-5}
				                
				               (*
				               'h','H','Ì','Î':                     {h, option h}
				                      begin
				                        if IsMenuItemEnabled(JoueursMenu,HumCreHumCmd) then
				                          DoDemandeChangerHumCtreHum;
				                      end;
				                *)
				               
				               otherwise {sinon, on cherche a avancer dans l'arbre}
				                 if afficheProchainsCoups & IsAlpha(ch) then
						               begin
						                 if IsLower(ch)
						                   then numeroFilsCherche := ord(ch) - ord('a') + 1
						                   else numeroFilsCherche := ord(ch) - ord('A') + 1;
						                 if (numeroFilsCherche <= NumberOfRealSons(GetCurrentNode())) &
						                    GetSquareOfMoveInNode(SelectNthRealSon(numeroFilsCherche,GetCurrentNode()),square) &
						                    PeutArreterAnalyseRetrograde() then
						                      begin
						                        temposon := avecSon;
					                          avecSon := false;
						                        TraiteCoupImprevu(square);
						                        avecSon := tempoSon;
						                        peutRepeter := not(gameOver);
						                      end;
						               end;
				             end;                      {case ch}
				             
				             
				           end;
	                
	                if not(enRetour | enSetUp) then
	                  begin
	                  
	                   if ch=chr(FlecheHautKey) then           {fleche en haut}
	                     begin
	                       if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan() & command
	                         then TrackScrollingRapport(GetVerticalScrollerOfRapport(),kControlUpButtonPart)
	                         else 
	                           begin
	                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+1;
	                             MontePartieHilitee(shift | option); 
	                           end;
	                       peutRepeter := true;
	                     end;
	                     
		                 if ch=chr(FlecheBasKey) then            {fleche en bas}  
		                   begin
		                     if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan() & command
		                       then TrackScrollingRapport(GetVerticalScrollerOfRapport(),kControlDownButtonPart)
		                       else 
		                         begin
		                           gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+1;
		                           DescendPartieHilitee(shift | option);  
		                         end;
		                     peutRepeter := true;
		                   end;
		                   
		                 if ch=chr(FlecheGaucheKey) then        {fleche a gauche}
		                   begin
		                     if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan() & command
		                     then TrackScrollingRapport(GetHorizontalScrollerOfRapport(),kControlUpButtonPart)
		                     else 
		                       if (nbreCoup>0) & PeutArreterAnalyseRetrograde() then    
		                         if option then DoRetourDernierEmbranchement else 
		                           begin
		                             AccelereProchainDoSystemTask(2);
		                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
		                             if windowListeOpen & (nbPartiesActives>0)
		                               then if (theEvent.what=autoKey) | shift
		                                    then DoDoubleBackMovePartieSelectionnee(infosListeParties.partieHilitee)
		                                    else DoBackMovePartieSelectionnee(infosListeParties.partieHilitee)
		                               else if (theEvent.what=autoKey) | shift
		                                    then DoDoubleBackMove
		                                    else DoBackMove;
		                             
		                           end;
		                     peutRepeter := (nbreCoup>0);
		                   end;
		                   
		                 if ch=chr(FlecheDroiteKey) then        {fleche a droite}
		                   begin
		                     if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan() & command
		                     then TrackScrollingRapport(GetHorizontalScrollerOfRapport(),kControlDownButtonPart)
		                     else 
		                       if PeutArreterAnalyseRetrograde() then         
		                         if option then DoAvanceProchainEmbranchement else    
		                           begin 
		                             AccelereProchainDoSystemTask(2);
		                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount()+4;
		                             if windowListeOpen & (nbPartiesActives>0)
		                               then if (theEvent.what=autoKey) | shift
		                                    then DoDoubleAvanceMovePartieSelectionnee(infosListeParties.partieHilitee)
		                                    else JoueCoupPartieSelectionnee(infosListeParties.partieHilitee)
		                               else if (theEvent.what=autoKey) | shift
		                                    then DoDoubleAvanceMove
		                                    else DoAvanceMove;
		                           end;
		                     peutRepeter := not(gameOver);
		                   end;
		                   
		                 if ch=chr(TopDocumentKey) then       {document top}
		                   if windowListeOpen & (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow())) then
			                     with infosListeParties do
				                     begin
				                       ancPosPouce := positionPouceAscenseurListe;
				                       positionPouceAscenseurListe := 1;
					                     SetValeurAscenseurListe(positionPouceAscenseurListe);
					                     if ancPosPouce<>positionPouceAscenseurListe then 
					                       EcritListeParties(false,'TopDocumentKey');
				                     end else
			                 if FenetreRapportEstOuverte() & (OrdreFenetre(GetRapportWindow())<OrdreFenetre(wListePtr)) then
			                     VoirLeDebutDuRapport;
			                     
		                 if ch=chr(BottomDocumentKey) then    {document bottom}
		                   if windowListeOpen & (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow())) then
		                     with infosListeParties do
				                   begin
				                     ancPosPouce := positionPouceAscenseurListe;
				                     positionPouceAscenseurListe := nbPartiesActives-nbreLignesFntreListe+1;
				                     SetValeurAscenseurListe(positionPouceAscenseurListe);
				                     if ancPosPouce<>positionPouceAscenseurListe then 
				                       EcritListeParties(false,'BottomDocumentKey');
				                   end else
			                 if FenetreRapportEstOuverte() & (OrdreFenetre(GetRapportWindow()) < OrdreFenetre(wListePtr)) then
			                     VoirLaFinDuRapport;
			                     
		                 if ch=chr(PageUpKey) then            {page up}
		                   if windowListeOpen & (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow())) then
		                     with infosListeParties do
			                     begin
			                       ancPosPouce := positionPouceAscenseurListe;
			                       positionPouceAscenseurListe := positionPouceAscenseurListe-nbreLignesFntreListe+1;
				                     SetValeurAscenseurListe(positionPouceAscenseurListe);
				                     if ancPosPouce<>positionPouceAscenseurListe then 
				                       EcritListeParties(false,'PageUpKey');
			                     end else
			                 if FenetreRapportEstOuverte() & (OrdreFenetre(GetRapportWindow()) < OrdreFenetre(wListePtr)) then
			                     TrackScrollingRapport(GetVerticalScrollerOfRapport(),kControlPageUpPart);
			                     
		                 if ch=chr(PageDownKey) then          {page down}
		                   if windowListeOpen & (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow())) then
		                     with infosListeParties do
			                     begin
			                       ancPosPouce := positionPouceAscenseurListe;
			                       positionPouceAscenseurListe := positionPouceAscenseurListe+nbreLignesFntreListe-1;
				                     SetValeurAscenseurListe(positionPouceAscenseurListe);
				                     if ancPosPouce<>positionPouceAscenseurListe then 
				                       EcritListeParties(false,'PageDownKey');
			                     end else
			                 if FenetreRapportEstOuverte() & (OrdreFenetre(GetRapportWindow()) < OrdreFenetre(wListePtr)) then
			                     TrackScrollingRapport(GetVerticalScrollerOfRapport(),kControlPageDownPart);
		                 
		                 
		                 if ch=chr(RetourArriereKey) then   {retour arriere}
		                   begin
		                     if option & gDoitJouerMeilleureReponse
		                       then
		                         begin
		                           DoChangeAfficheSuggestionDeCassio;
		                         end
		                       else
		                         begin
        		                   if not(EffacerDansRapport()) & PeutArreterAnalyseRetrograde() then 
        		                     begin
        		                       RemoveDelayAfterKeyboardOperation;
        		                       AccelereProchainDoSystemTask(2);
        		                       JoueCoupQueMacAttendait;
        		                       if not(afficheSuggestionDeCassio) & CassioEstEnModeAnalyse()
        		                         then DoChangeAfficheSuggestionDeCassio;
        		                     end;
        		                 end;
		                   end;
		                     
		                 if ch=chr(HelpAndInsertKey) then   {touche aide}
		                   DoChangeDessineAide;
		                   
		                 if (ch=chr(EscapeKey)) & analyseRetrograde.enCours then {escape}
		                   DoDemandeChangerHumCtreHum;
	                   
	               (*
	               if afficheInfosApprentissage & avecFlecheProchainCoupDansGraphe then
	                 begin
	                   GetFilsDeLaPositionCouranteDansLeGraphe([kGainDansT,kNulleDansT,kPerteDansT,kPasDansT,kPropositionHeuristique,
	                                                            kGainAbsolu,kNulleAbsolue,kPerteAbsolue],
	                   true,FilsConnus);
	                   if filsConnus.cardinal<=0
	                     then 
	                       begin
	                         if PeutArreterAnalyseRetrograde() then
	                           begin
	                             if theEvent.what=autoKey
	                               then DoDoubleAvanceMove
	                               else DoAvanceMove;
	                             peutRepeter := not(gameOver);
	                           end;
	                       end
	                     else 
	                       if (IndexProchainFilsDansGraphe>=1) &
	                          (IndexProchainFilsDansGraphe<=FilsConnus.cardinal) then
	                            begin
	                              tempoSon := avecSon;
	                              avecSon := false;
	                              TraiteCoupImprevu(FilsConnus.liste[IndexProchainFilsDansGraphe].coup);
	                              avecSon := tempoSon;
	                              peutRepeter := not(gameOver);
	                            end;
	                   end;
	                 *)
	                 (*
	                 if afficheInfosApprentissage & avecFlecheProchainCoupDansGraphe then
	                   begin
	                     if (ch=chr(FlecheHautKey)) & (IndexProchainFilsDansGraphe>1) then {fleche en haut}
	                       begin
	                         IndexProchainFilsDansGraphe := IndexProchainFilsDansGraphe-1;
	                         EcritLesInfosDApprentissage;
	                       end;  
	                     if ch=chr(FlecheBasKey) then                                         {fleche en bas}
	                       begin
	                         GetFilsDeLaPositionCouranteDansLeGraphe([kGainDansT,kNulleDansT,kPerteDansT,kPasDansT,kPropositionHeuristique,
	                                                                  kGainAbsolu,kNulleAbsolue,kPerteAbsolue],true,FilsConnus);
	                         if IndexProchainFilsDansGraphe<FilsConnus.cardinal then
	                           begin
	                             IndexProchainFilsDansGraphe := IndexProchainFilsDansGraphe+1;
	                             EcritLesInfosDApprentissage;
	                           end;
	                       end;
	                   end;
	                  *)
	                 
	                  end; {if not(enRetour | enSetUp) then}
                               
             {WriteStringAndNumAt('ascii n°',ord(ch),20,40);}
          end;
      end;
end;

function ToucheCommandeInterceptee(ch : char;evt : eventRecord; var peutRepeter : boolean) : boolean;
var shift,command,option,control : boolean;
begin
  {$UNUSED peutRepeter}
  
  ToucheCommandeInterceptee := false;
  peutRepeter := false;
  
  if EnModeEntreeTranscript() then
    begin
      if TraiteKeyboardEventDansTranscript(ch,peutRepeter) then
        begin
          ToucheCommandeInterceptee := true;
          exit(ToucheCommandeInterceptee);
        end;
    end;
    
  if not(iconisationDeCassio.enCours) then
    begin
      shift := BAND(evt.modifiers,shiftKey) <> 0;
      command := BAND(evt.modifiers,cmdKey) <> 0;
      option := BAND(evt.modifiers,optionKey) <> 0;
      control := BAND(evt.modifiers,controlKey) <> 0;
      
      if command then
        begin
          case ch of 
            'K':   {pomme-majuscules-K}
              begin
                if shift & PeutArreterAnalyseRetrograde() then
                  begin
                    BeginHiliteMenu(SolitairesID);
                    ChercherUnProblemeDePriseDeCoinDansListe(20,40);
                    EndHiliteMenu(evt.when,8,false);
                    ToucheCommandeInterceptee := true;
                  end;
              end;
            'È','Ë':   {pomme-option-K}
              begin
                if option & PeutArreterAnalyseRetrograde() then
                  begin
                    BeginHiliteMenu(SolitairesID);
                    RevenirAuProblemeDePriseDeCoinPrecedent;
                    EndHiliteMenu(evt.when,8,false);
                    ToucheCommandeInterceptee := true;
                  end;
              end;
            'l','L':   {pomme-L}
              begin
                BeginHiliteMenu(AffichageID);
                DoChangeAfficheDernierCoup;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'm','M':   {pomme-M}
              begin
                BeginHiliteMenu(AffichageID);
                if windowPaletteOpen then FlashCasePalette(PaletteInterrogation);
                DoChangeAfficheMeilleureSuite;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            chr(25):   {pomme-control-y}
              begin
                BeginHiliteMenu(BaseID);
                DoNegationnerLesSousCriteres;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'Ú','Ÿ':   {pomme-option-y}
              begin
                BeginHiliteMenu(BaseID);
                DoSwaperLesSousCriteres;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            '†','™':   {pomme-option-t}
              begin
                if avecProgrammation then BeginHiliteMenu(ProgrammationID);
                DoChangeEnTraitementDeTexte;
                if avecProgrammation then EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'Ò':       {pomme-option-s}
              begin
                BeginHiliteMenu(FileID);
                DoEnregistrerSousFormatCassio(evt.modifiers);
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            '+':   {pomme-plus}
              begin
                if not(EnModeEntreeTranscript()) & not(analyseRetrograde.enCours) then
                  begin
                    if avecProgrammation then BeginHiliteMenu(ProgrammationID);
                    DoChangeEnModeEntreeTranscript;
                    if avecProgrammation then EndHiliteMenu(evt.when,8,false);
                    ToucheCommandeInterceptee := true;
                  end;
              end;
            '‹','›':   {pomme-option-w}
              begin
                BeginHiliteMenu(FileID);
                FermeToutesLesFenetresAuxiliaires;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;        
              end;
            'Ï','Í':   {pomme-option-j}
              begin
                BeginHiliteMenu(SolitairesID);
                DoDemandeJouerSolitaires;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'œ','Œ':   {pomme-option-o}
              begin
                FindStringDansArbreDeJeuCourant('toto');
              end;
          end;
      
	      if (ch=chr(FlecheGaucheKey)) then           {pomme-fleche a gauche}
	        begin
	          if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan() then
	            begin
	              TrackScrollingRapport(GetHorizontalScrollerOfRapport(),kControlUpButtonPart);
	              ToucheCommandeInterceptee := true;
	              peutRepeter := true;
		            exit(ToucheCommandeInterceptee);
		          end;
		        if windowListeOpen then      
		          begin
		            case nbColonnesFenetreListe of
	                kAvecAffichageDistribution        : ;
	                kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageDistribution);
	                kAvecAffichageSeulementDesJoueurs : DoChangeEcritTournoi(kAvecAffichageTournois);
	              end; {case}
		            ToucheCommandeInterceptee := true;
		            peutRepeter := true;
		            exit(ToucheCommandeInterceptee);
		          end;
	        end;
	      if (ch=chr(FlecheDroiteKey)) then           {pomme-fleche a droite}
	        begin
	          if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan() then
	            begin
	              TrackScrollingRapport(GetHorizontalScrollerOfRapport(),kControlDownButtonPart);
	              ToucheCommandeInterceptee := true;
	              peutRepeter := true;
		            exit(ToucheCommandeInterceptee);
		          end;
		        if windowListeOpen then      
		          begin
		            case nbColonnesFenetreListe of
	                kAvecAffichageDistribution        : DoChangeEcritTournoi(kAvecAffichageTournois);
	                kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageSeulementDesJoueurs);
	                kAvecAffichageSeulementDesJoueurs : ;
	              end; {case}
		            ToucheCommandeInterceptee := true;
		            exit(ToucheCommandeInterceptee);
		          end;
	        end;
	      if (ch=chr(FlecheHautKey)) then             {pomme-fleche en haut}
	        begin
	          if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan() 
	            then
		            begin
		              TrackScrollingRapport(GetVerticalScrollerOfRapport(),kControlUpButtonPart);
		              ToucheCommandeInterceptee := true;
		              peutRepeter := true;
			            exit(ToucheCommandeInterceptee);
			          end
			        else
			          begin
	                MontePartieHilitee(command); 
	                ToucheCommandeInterceptee := true;
	                exit(ToucheCommandeInterceptee);
	              end;     
	        end;
	      if (ch=chr(FlecheBasKey)) then              {pomme-fleche en bas}
	        begin
	          if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan()
	            then
	              begin
		              TrackScrollingRapport(GetVerticalScrollerOfRapport(),kControlDownButtonPart);
		              ToucheCommandeInterceptee := true;
		              peutRepeter := true;
			            exit(ToucheCommandeInterceptee);
			          end
			        else
		            begin
	                DescendPartieHilitee(command); 
	                ToucheCommandeInterceptee := true;
	                exit(ToucheCommandeInterceptee);
	              end;     
	        end;
	      if (ch = chr(RetourArriereKey)) then   {pomme-delete}
	        begin
	          if gDoitJouerMeilleureReponse then
              begin
                DoChangeAfficheSuggestionDeCassio;
                peutRepeter := false;
  		          exit(ToucheCommandeInterceptee);
              end;
	          if option & gDoitJouerMeilleureReponse then
              begin
                DoChangeAfficheSuggestionDeCassio;
                peutRepeter := false;
  		          exit(ToucheCommandeInterceptee);
              end;
            if option & not(afficheSuggestionDeCassio) & CassioEstEnModeAnalyse() then
        		  begin
        		    DoChangeAfficheSuggestionDeCassio;
        		    peutRepeter := false;
  		          exit(ToucheCommandeInterceptee);
        		  end;
	          if windowListeOpen & not(FenetreListeEnModeEntree()) & (nbPartiesActives > 0) 
	            then
  	            begin
  	              DoSupprimerPartiesDansListe;
  	              peutRepeter := false;
  		            exit(ToucheCommandeInterceptee);
  	            end 
	            else
	              if EffacerDansRapport() then;
	        end;
	    end;
	  end;
end;


procedure ToggleAideDebutant;
  begin 
    if not(enSetUp | enRetour) then
      begin
	      aideDebutant := not(aideDebutant);
	      if aideDebutant
	        then DessineAideDebutant(true,othellierToutEntier)
          else EffaceAideDebutant(true,true,othellierToutEntier);
        
        if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
          QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
	    end;
  end;
  


procedure TraiteSourisStandard(mouseLoc : Point;modifiers : SInt16);
var whichSquare,numeroCoup : SInt16; 
    nbreCoupAvantLeClic : SInt16; 
    shift,command,option,control : boolean;
    whichSon : GameTree;
    coupsDejaGeneres : SquareSet;
    myRect : rect;
begin

 shift := BAND(modifiers,shiftKey) <> 0;
 command := BAND(modifiers,cmdKey) <> 0;
 option := BAND(modifiers,optionKey) <> 0;
 control := BAND(modifiers,controlKey) <> 0;


 if control | (command & sousEmulatorSousPC) then 
   begin
     ChangePierresDeltaApresCommandClicSurOthellier(mouseLoc,jeuCourant,true);
     AfficheProprietesOfCurrentNode(true,othellierToutEntier,'TraiteSourisStandard {1}');
     exit(traiteSourisStandard);
   end;
   
   
 if not(PtInPlateau(mouseLoc,whichSquare)) 
   then
     begin
       if PtInRect(mouseLoc,gHorlogeRect) & not(EnModeEntreeTranscript())
         then 
           begin
             myRect := gHorlogeRect;
             if AppuieBouton(myRect,10,mouseLoc,DrawInvertedClockBoundingRect,DrawClockBoundingRect) then DoCadence;
           end
         else ToggleAideDebutant;
     end
   else
     begin
      if not(option) 
        then 
          begin
            if not(possibleMove[whichSquare])
              then 
                begin
                  if PeutReculerUnCoup() & CurseurEstEnTeteDeMort() & (whichSquare = DerniereCaseJouee()) & PeutArreterAnalyseRetrograde()
								    then 
								      begin
								        DetruitSousArbreCourantEtBackMove;
				              end
								    else 
								      begin
								        ToggleAideDebutant;
								        
								        if PeutReculerUnCoup() & not(CurseurEstEnTeteDeMort()) & (whichSquare = DerniereCaseJouee()) & not(analyseRetrograde.enCours) then
								          BeginLiveUndo(GetEnsembleDesCoupsDesFreres(0,GetCurrentNode()),0);
								      end;
                end
              else
                if not(gameOver) then 
                  begin
                    if not(CurseurEstEnTeteDeMort())
                      then 
                        begin
                          nbreCoupAvantLeClic := nbreCoup;
                          coupsDejaGeneres := GetEnsembleDesCoupsDesFils(0,GetCurrentNode());
                          
                          TraiteCoupImprevu(whichSquare);
                          
                          if (nbreCoup = nbreCoupAvantLeClic + 1) then
                            BeginLiveUndo(coupsDejaGeneres,15);
                        end
                      else
                        begin
                          whichSon := SelectTheSonAfterThisMove(GetCurrentNode(),whichSquare,aQuiDeJouer);
                          if whichSon <> NIL then DetruireCeFilsOfCurrentNode(whichSon);
                        end;
                  end;
          end
        else 
          begin
            if TrouveCoupDansPartieCourante(whichSquare,numeroCoup) then
              if PeutArreterAnalyseRetrograde() then
                begin
                  if numeroCoup<nbreCoup 
                    then 
                      begin
                        if numeroCoup<=0
                          then DoDebut(false)
                          else
                            if numeroCoup=nbreCoup-1
                              then DoBackMove
                              else DoRetourAuCoupNro(numeroCoup,true,true);
                        {if not(CassioEstEnModeSolitaire()) then DoInsererMarque;}
                      end
                    else 
                      if numeroCoup+1>nbreCoup then 
                        begin
                          if numeroCoup+1=nbreCoup+1
                            then 
                              begin
                                DoAvanceMove;
                                BeginLiveUndo(GetEnsembleDesCoupsDesFreres(0,GetCurrentNode()),15);
                              end
                            else DoAvanceAuCoupNro(numeroCoup+1,true);
                          {if not(CassioEstEnModeSolitaire()) then DoInsererMarque;}
                        end;
                end;
          end;
    end;
end;

procedure TraiteSourisRetour(mouseLoc : Point;modifiers : SInt16);
var numeroDuCoupTrouve,i,whichSquare : SInt16; 
    trouve : boolean;
    shift,command,option,control : boolean;
begin
  shift := BAND(modifiers,shiftKey) <> 0;
  command := BAND(modifiers,cmdKey) <> 0;
  option := BAND(modifiers,optionKey) <> 0;
  control := BAND(modifiers,controlKey) <> 0;

  {
  if command then 
    begin
      if not(windowPlateauOpen) then DoNouvellePartie;
      IconiserCassio;
      exit(traiteSourisRetour);
    end;
   }
   
  if PtInPlateau(mouseLoc,whichSquare) then 
    begin
      trouve := false;
      for i := 1 to nbreCoup do
        if GetNiemeCoupPartieCourante(i)=whichSquare then 
          begin
            numeroDuCoupTrouve := i-1; 
            trouve := true;
          end;
      if trouve & (numeroDuCoupTrouve<nbreCoup) 
        then
          begin
            if PeutArreterAnalyseRetrograde() then
              begin
                EffaceZoneADroiteDeLOthellier;
                EffaceZoneAuDessousDeLOthellier;
                if gCouleurOthellier.estUneTexture & not(Quitter) then 
                  DessineNumerosDeCoupsSurTousLesPionsSurDiagramme(numeroDuCoupTrouve); {effacement des numeros fantomes}
                DoRetourAuCoupNro(numeroDuCoupTrouve,false,not(CassioEstEnModeAnalyse()));
                {if not(CassioEstEnModeSolitaire()) then DoInsererMarque;}
                enRetour := false;
              end
          end
        else
          begin
            enRetour := false;
            humainVeutAnnuler := true;
            dernierTick := TickCount();
          end;
    end
   else
    begin
     if PtInRect(mouseLoc,annulerRetourRect) then 
       if AppuieBoutonParControlManager(ReadStringFromRessource(TextesSetUpID,5),annulerRetourRect,30,mouseLoc) then
         begin
           enRetour := false;
           humainVeutAnnuler := true;
           dernierTick := TickCount();
           FlushEvents(MDownmask+MUpMask,0); {pour supprimer les double-clics}
         end;
    end;
end;

procedure TraiteSourisFntrPlateau(evt : eventRecord);
var mouseLoc : Point;
    oldport : grafPtr;
begin
  if windowPlateauOpen then
    begin
      AnnulerSousCriteresRuban;
      GetPort(oldport);
      SetPortByWindow(wPlateauPtr);
      mouseLoc := evt.where;
      GlobalToLocal(mouseLoc);
      if (mouseLoc.h >= GetWindowPortRect(wPlateauPtr).right-16) & 
         (mouseLoc.v >= GetWindowPortRect(wPlateauPtr).bottom-16) 
        then 
          begin
            DoGrowWindow(wPlateauPtr,evt);
          end
        else
          begin
            if not(EnModeEntreeTranscript() & TraiteMouseEventDansTranscript(evt)) then
              if enRetour 
                then TraiteSourisRetour(mouseLoc,evt.modifiers)
                else TraiteSourisStandard(mouseLoc,evt.modifiers);
          end;
      SetPort(oldport);
    end;
  if windowPaletteOpen then
    if BooleanXor(HumCtreHum,SablierDessineEstRenverse) then 
      DessineIconesChangeantes;
end;





procedure TraiteSourisPalette(evt : eventRecord);
var limiteRect : rect;
    oldport : grafPtr;
    mouseLoc : Point;
    CaseXPalette,CaseYPalette,nroAction : SInt16; 
    ok : boolean;
    tick : SInt32;
     
   procedure FlashCase(nroAction : SInt16; rectangle : rect);
   var tick : SInt32;
     begin
       SetPortByWindow(wPalettePtr);
       tick := TickCount();
       if gBlackAndWhite
         then InvertRect(rectangle)
         else DessineCasePaletteCouleur(nroAction,true);
       while TickCount()-tick<6 do;
       if gBlackAndWhite
         then InvertRect(rectangle)
         else DessineCasePaletteCouleur(nroAction,false);
     end;
   
   procedure PresseCase(nroAction : SInt16; rectangle : rect);
   var tick : SInt32;
     begin
       SetPortByWindow(wPalettePtr);
       tick := TickCount();
       if gBlackAndWhite
         then InvertRect(rectangle)
         else DessineCasePaletteCouleur(nroAction,true);
       while TickCount()-tick<6 do;
       if not(StillDown()) then
         if gBlackAndWhite
           then InvertRect(rectangle)
           else DessineCasePaletteCouleur(nroAction,false);
     end;
   
   function ActionVoulue(nroAction : SInt16; rectangle : rect) : boolean;
   var tick : SInt32;
       caseEnfoncee,dedans : boolean;
   begin
     SetPortByWindow(wPalettePtr);
     tick := TickCount();
     if gBlackAndWhite
       then InvertRect(rectangle)
       else DessineCasePaletteCouleur(nroAction,true);
     caseEnfoncee := true;
     
     while TickCount()-tick<6 do;
     
     repeat
       GetMouse(mouseLoc);
       dedans := PtInRect(mouseLoc,rectangle);
       if dedans & not(caseEnfoncee) then
         begin
           if gBlackAndWhite
             then InvertRect(rectangle)
             else DessineCasePaletteCouleur(nroAction,true);
           caseEnfoncee := true;
         end;
       if not(dedans) & caseEnfoncee then
         begin
           if gBlackAndWhite
             then InvertRect(rectangle)
             else DessineCasePaletteCouleur(nroAction,false);
           caseEnfoncee := false;
         end;
     until not(StillDown());
     
     ActionVoulue := dedans;
     if not(gBlackAndWhite)
       then DessineCasePaletteCouleur(nroAction,false)
       else if caseEnfoncee then InvertRect(rectangle);
      
   end;

begin
  {$UNUSED evt}

  AjusteCurseur;
  GetPort(oldport);
  SetPortByWindow(wPalettePtr);
  mouseLoc := theEvent.where;
  GlobalToLocal(mouseLoc);
  CaseXPalette := mouseLoc.h div LargeurCasePalette +1;
  CaseYPalette := mouseLoc.v div HauteurCasePalette +1;
  if CaseXPalette>9 then CaseXPalette := 9;
  if CaseYPalette>2 then CaseYPalette := 2;
  nroaction := CaseXPalette+9*(CaseYPalette-1);
  SetRect(limiterect,(CaseXPalette-1)*largeurCasePalette,
                     (CaseYPalette-1)*hauteurCasePalette,
                     CaseXPalette*largeurCasePalette -1,
                     CaseYPalette*HauteurCasePalette -1);
  ok := true;
  if enSetUp then ok := false;
  if enRetour & (NroAction<>PaletteDiagramme) then ok := false;            
   
  if ok then
    begin
      case NroAction of
        PaletteRetourDebut    : begin
                                  if ActionVoulue(PaletteRetourDebut,limiteRect) then
                                    if PeutArreterAnalyseRetrograde() then
                                      DoRetourDerniereMarque;
                                end;
        PaletteDoubleBack     : if PeutArreterAnalyseRetrograde() then
                                begin
                                  tick := TickCount();
                                  PresseCase(PaletteDoubleBack,limiteRect);
                                  DoDoubleBackMove;
                                  repeat
                                  until not(BoutonAppuye(wPalettePtr,limiterect)) | (TickCount()-tick>15);
                                  while BoutonAppuye(wPalettePtr,limiterect) & PeutReculerUnCoup() do 
                                    begin
                                      repeat until TickCount()>tick+2;
			                                tick := TickCount();
                                      DoDoubleBackMove;
                                    end;
                                  if gBlackAndWhite 
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteDoubleBack,false);
                                end;
        PaletteBack           : if PeutArreterAnalyseRetrograde() then
                                begin
                                  tick := TickCount();
                                  PresseCase(PaletteBack,limiteRect);
                                  DoBackMove;
                                  repeat
                                  until not(BoutonAppuye(wPalettePtr,limiterect)) | (TickCount()-tick>15);
                                  while BoutonAppuye(wPalettePtr,limiterect) & PeutReculerUnCoup() do 
                                    begin
                                      repeat until TickCount()>tick+2;
			                                tick := TickCount();
			                                DoBackMove;
			                              end;
                                  if gBlackAndWhite 
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteBack,false);
                                end;
        PaletteForward        : if PeutArreterAnalyseRetrograde() then
                                begin
                                  tick := TickCount();
                                  PresseCase(PaletteForward,limiteRect);
                                  DoAvanceMove;
                                  repeat
                                  until not(BoutonAppuye(wPalettePtr,limiterect)) | (TickCount()-tick>15);
                                  while BoutonAppuye(wPalettePtr,limiterect) & PeutAvancerUnCoup() do 
                                    begin
                                      repeat until TickCount()>tick+2;
			                                tick := TickCount();
                                      DoAvanceMove;
                                    end;
                                  if gBlackAndWhite 
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteForward,false);
                                end;
        PaletteDoubleForward  : if PeutArreterAnalyseRetrograde() then
                                begin
                                  tick := TickCount();
                                  PresseCase(PaletteDoubleForward,limiteRect);
                                  DoDoubleAvanceMove;
                                  repeat
                                  until not(BoutonAppuye(wPalettePtr,limiterect)) | (TickCount()-tick>15);
                                  while BoutonAppuye(wPalettePtr,limiterect) & PeutAvancerUnCoup() do 
                                    begin
                                      repeat until TickCount()>tick+2;
			                                tick := TickCount();
                                      DoDoubleAvanceMove;
                                    end;
                                  if gBlackAndWhite 
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteDoubleForward,false);
                                end;
        PaletteAllerFin       : begin
                                  if ActionVoulue(PaletteAllerFin,limiteRect) then
                                    if PeutArreterAnalyseRetrograde() then
                                      DoAvanceProchaineMarque;
                                end;
        PaletteCoupPartieSel  : begin
                                  tick := TickCount();
                                  PresseCase(PaletteCoupPartieSel,limiteRect);
                                  if BAND(theEvent.modifiers,shiftKey) <> 0
                                    then 
                                      begin
                                        if windowListeOpen & (nbPartiesActives>0) then
                                          if PeutArreterAnalyseRetrograde() then
                                            begin
                                              DoBackMovePartieSelectionnee(infosListeParties.partieHilitee);
                                              repeat
                                              until not(BoutonAppuye(wPalettePtr,limiterect)) | (TickCount()-tick>15);
                                              while BoutonAppuye(wPalettePtr,limiterect) & PeutReculerUnCoup() do
                                                begin
                                                  repeat until TickCount()>tick+2;
			                                            tick := TickCount();
			                                            DoBackMovePartieSelectionnee(infosListeParties.partieHilitee);
			                                          end;
                                            end;
                                      end
                                    else 
                                      begin
                                        JoueCoupPartieSelectionnee(infosListeParties.partieHilitee);  
                                        repeat
                                        until not(BoutonAppuye(wPalettePtr,limiterect)) | (TickCount()-tick>15);
                                        while BoutonAppuye(wPalettePtr,limiterect) & PeutAvancerPartieSelectionnee() do
                                          begin
                                            repeat until TickCount()>tick+2;
			                                      tick := TickCount();
			                                      JoueCoupPartieSelectionnee(infosListeParties.partieHilitee);  
			                                    end;
                                      end; 
                                   if gBlackAndWhite 
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteCoupPartieSel,false);
                                end;
        PaletteCouleur        : begin
                                 {if not(HumCtreHum) then}
                                   if not(CassioEstEnModeAnalyse()) & ActionVoulue(PaletteCouleur,limiteRect) then
                                     if PeutArreterAnalyseRetrograde() then DoDemandeChangeCouleur;
                                end;
        PaletteSablier        : begin
                                  if ActionVoulue(PaletteSablier,limiteRect) then
                                    DoDemandeChangerHumCtreHum;
                                end;
        PaletteInterrogation  : begin
                                  if ActionVoulue(PaletteInterrogation,limiteRect) then
                                    DoChangeAfficheMeilleureSuite;
                                end;
        PaletteHorloge        : begin
                                  if ActionVoulue(PaletteHorloge,limiteRect) then
                                    DoCadence;
                                end;
        PaletteBase           : begin
                                  if ActionVoulue(PaletteBase,limiteRect) then
                                    DoChargerLaBase;
                                end;
        PaletteDiagramme      : begin
                                  if ActionVoulue(PaletteDiagramme,limiteRect) then
                                    if enRetour 
                                      then humainVeutAnnuler := true
                                      else DoRevenir;
                                end;
        PaletteSon            : begin
                                  if ActionVoulue(PaletteSon,limiteRect) then
                                    begin
                                      DoSon;
                                      {if avecSon then PlaySoundSynchrone(kSonTockID);}
                                      if avecSon then PlayPosePionSound;
                                    end;
                                end;
        PaletteStatistique    : begin
                                  if ActionVoulue(PaletteStatistique,limiteRect) then
                                    DoStatistiques;
                                end;
        PaletteListe          : begin
                                  if ActionVoulue(PaletteListe,limiteRect) then
                                    DoListeDeParties;
                                end;
        PaletteReflexion      : begin
                                  if ActionVoulue(PaletteReflexion,limiteRect) then
                                    DoChangeAfficheReflexion;
                                end;
        PaletteCourbe         : begin
                                  if ActionVoulue(PaletteCourbe,limiteRect) then
                                    DoCourbe;
                                end;
      end;  {case}
    end;
    
  SetPort(oldport);
end;


procedure TraiteSourisAide(evt : eventRecord);
begin {$UNUSED evt}
  gAideCourante := NextPageDansAide(gAideCourante);
  DessineAide(gAideCourante);
end;




procedure TraiteSourisStatistiques(evt : eventRecord);
var coup,premierCoup,numLigne : SInt16; 
    autreCoupQuatreDansPartie,tempoSon : boolean;
    mouseLoc : Point;
    oldport : grafPtr;
    rubanRect : rect;
    tick : SInt32;
begin
  if windowStatOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wStatPtr);
      mouseLoc := evt.where;
      GlobalToLocal(mouseLoc);
      if mouseLoc.v<hauteurRubanStatistiques
        then 
          begin
            tick := TickCount();
            SetRect(rubanRect,0,0,QDGetPortBound().right,hauteurRubanStatistiques);
            if PtInRect(mouseLoc,rubanRect) & PeutArreterAnalyseRetrograde() then
	            begin
	              DoBackMove;
				        repeat until not(BoutonAppuye(wStatPtr,rubanRect)) | (TickCount()-tick>15);
			          while BoutonAppuye(wStatPtr,rubanRect) & PeutReculerUnCoup() do 
			            begin
			              repeat until TickCount()>tick+2;
			              tick := TickCount();
			              DoBackMove;
			            end;
			        end;
          end
        else 
          if (nbPartiesChargees > 0) & (nbPartiesActives > 0) & 
             (statistiques <> NIL) & StatistiquesCalculsFaitsAuMoinsUneFois() then
          begin
            numLigne := 1+((mouseLoc.v-hauteurRubanStatistiques-2) div hauteurChaqueLigneStatistique);
            if numLigne<=statistiques^^.nbreponsesTrouvees then
              begin
                autreCoupQuatreDansPartie := false;
                if nbreCoup >= 3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
                coup := ord(statistiques^^.table[numLigne].coup);
                if (coup >= 11) & (coup <= 88) then
                  begin
		                TransposeCoupPourOrientation(coup,autreCoupQuatreDansPartie);
		                tempoSon := avecSon;
		                avecSon := false;
		                TraiteCoupImprevu(coup);
		                avecSon := tempoSon;
		              end;
              end;
          end;
      SetPort(oldport);
    end;
end;

procedure TraiteSourisCommentaires(evt : eventRecord;fenetreActiveeParCeClic : boolean);
var mouseLoc : Point;
    lesFilsRect : rect;
    oldport : grafPtr;
    shift,verouillage : boolean;
    myText : TEHandle;
    enModeEditionArrivee,tempoSon : boolean;
    clicDansLaZoneDesCommentaires : boolean;
    positionSouris,dummy : SInt32;
    minimum,maximum : SInt16; 
    tick : SInt32;
    gameNodeAvantInterversion : GameTree;
    
  procedure JoueLeFilsSousLeCurseurDeLaSouris;
  var whichSon : GameTree;
      move : PropertyPtr;
      numeroDuFils : SInt32;
  begin
    numeroDuFils := (mouseLoc.v - 1) div InterligneArbreFenetreArbreDeJeu();
    if (numeroDuFils = NbDeFilsOfCurrentNode()+1) then numeroDuFils := NbDeFilsOfCurrentNode();
	  whichSon := SelectNthSon(numeroDuFils,GetCurrentNode());
	  if whichSon <> NIL then
	    if CurseurEstEnTeteDeMort()
	      then 
	        DetruireCeFilsOfCurrentNode(whichSon)
	      else
	        begin
	          move := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],whichSon);
	          if (move <> NIL) then
	            begin
	              tempoSon := avecSon;
	              avecSon := false;
	              TraiteCoupImprevu(GetOthelloSquareOfProperty(move^));
	              avecSon := tempoSon;
	            end;
	        end;
	end;
	
	procedure DeplaceLeFilsSousLeCurseurDeLaSouris;
  var whichSon : GameTree;
      numeroDuFils : SInt32;
      index : SInt32;
  begin
    numeroDuFils := (mouseLoc.v - 1) div InterligneArbreFenetreArbreDeJeu();
    if (numeroDuFils>=1) & (numeroDuFils <= NbDeFilsOfCurrentNode()) then
      with arbreDeJeu do
      begin
        InverserLeNiemeFilsDansFenetreArbreDeJeu(numeroDuFils);
        positionSouris := mouseLoc.v;
		    minimum := backMoveRect.bottom-1;
		    maximum := Min(minimum+espaceEntreLignesProperties*NbDeFilsOfCurrentNode()+1,EditionRect.top-10);
		    DragLine(GetArbreDeJeuWindow(), kDragHorizontalLine,false,minimum,maximum,espaceEntreLignesProperties,positionSouris,index,IdentiteSurN);
		    InverserLeNiemeFilsDansFenetreArbreDeJeu(numeroDuFils);
		    EffaceProprietesOfCurrentNode;
		    whichSon := SelectNthSon(numeroDuFils,GetCurrentNode());
		    if index>numeroDuFils then BringSonOfCurrentNodeInPositionN(whichSon,index) else
		    if index<numeroDuFils then BringSonOfCurrentNodeInPositionN(whichSon,index+1);		    
		    AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DeplaceLeFilsSousLeCurseurDeLaSouris');
      end;
  end;
	
begin  {TraiteSourisCommentaires}
  with arbreDeJeu do
    if windowOpen & (GetArbreDeJeuWindow() <> NIL) then
      begin
        enModeEditionArrivee := enModeEdition;
        
        shift := BAND(evt.modifiers,shiftKey) <> 0;
        verouillage := BAND(evt.modifiers,alphaLock) <> 0;
        GetPort(oldport);
        SetPortByWindow(GetArbreDeJeuWindow());
        mouseLoc := evt.where;
        GlobalToLocal(mouseLoc);
        
        clicDansLaZoneDesCommentaires := PtInRect(mouseLoc,EditionRect);
        myText := GetDialogTextEditHandle(theDialog);
        if myText <> NIL then
	        if clicDansLaZoneDesCommentaires 
	          then 
	            begin
	              enModeEdition := true;
	              ActiverModeEditionFenetreArbreDeJeu;
	              ClicDansTexteCommentaires(mouseLoc,shift);
	              doitResterEnModeEdition := EnTraitementDeTexte;
	            end
	          else
	            begin
	              if enModeEditionArrivee then 
	                begin
	                  enModeEdition := false;
	                  GetCurrentScript(gLastScriptUsedInDialogs);
	                  SwitchToRomanScript;
	                  DeactiverModeEditionFenetreArbreDeJeu;
	                end;
	            end;
	      
	      if not(fenetreActiveeParCeClic) & (GetArbreDeJeuWindow()=FrontWindowSaufPalette()) then
	        begin
	          tick := TickCount();
	          
	          if avecInterversions & not(CurseurEstEnTeteDeMort()) & 
	             SurIconeInterversion(mouseLoc,gameNodeAvantInterversion) &
	             (gameNodeAvantInterversion = GetCurrentNode()) then 
	            begin
	              if PeutArreterAnalyseRetrograde() then
	                CyclerDansOrbiteInterversionDuGraphe(gameNodeAvantInterversion,not(shift));
	              SetPort(oldPort);
	              exit(TraiteSourisCommentaires);
	            end;
	          
	          if PtInRect(mouseLoc,backMoveRect) & (not(enModeEditionArrivee) | doitResterEnModeEdition) then
	            begin
	              if PeutArreterAnalyseRetrograde() then
	                begin
					          if CurseurEstEnTeteDeMort()
					            then 
					              DoDialogueDetruitSousArbreCourant
					            else
					              begin
											    DoBackMove;
											    repeat until not(BoutonAppuye(GetArbreDeJeuWindow(),backMoveRect)) | (TickCount()-tick>15);
										      while BoutonAppuye(GetArbreDeJeuWindow(),backMoveRect) & PeutReculerUnCoup() do 
										        begin
										          repeat until TickCount()>tick+2;
										          tick := TickCount();
										          DoBackMove;
										        end;
										    end;
					        end;
	              SetPort(oldPort);
	              exit(TraiteSourisCommentaires);
	            end;
	            
	          
	          if (mouseLoc.v >= backMoveRect.bottom) & (mouseLoc.v<=EditionRect.top-12) & (not(enModeEditionArrivee) | doitResterEnModeEdition) then
	            begin
	              lesFilsRect := MakeRect(-1,backMoveRect.bottom,10000,backMoveRect.bottom + 5 + NbDeFilsOfCurrentNode()*InterligneArbreFenetreArbreDeJeu());
	              if not(PtInRect(mouseLoc,lesFilsRect)) & enModeEditionArrivee & doitResterEnModeEdition then
	                begin
	                  doitResterEnModeEdition := false;
	                  ValideZoneCommentaireDansFenetreArbreDeJeu;
	                end;
	                  
	              if not(shift) 
	                then
                    begin
							        lesFilsRect := MakeRect(-1,backMoveRect.bottom,1000,EditionRect.top-12);
							        JoueLeFilsSousLeCurseurDeLaSouris;
							        repeat
			                until not(BoutonAppuye(GetArbreDeJeuWindow(),lesFilsRect)) | (TickCount()-tick>15);
		                  while BoutonAppuye(GetArbreDeJeuWindow(),lesFilsRect) & PeutAvancerUnCoup() do 
			                  begin
			                    repeat until TickCount()>tick+2;
			                    tick := TickCount();
			                    JoueLeFilsSousLeCurseurDeLaSouris;
			                  end;
		                end
		              else
		                DeplaceLeFilsSousLeCurseurDeLaSouris;
	              SetPort(oldPort);
	              exit(TraiteSourisCommentaires);
	            end;
	            
	          if (mouseLoc.v > EditionRect.top-12) & (mouseLoc.v < EditionRect.top) then
	            begin
	              positionSouris := mouseLoc.v;
	              
	              DragLine(GetArbreDeJeuWindow(), kDragHorizontalLine,false,45,QDGetPortBound().bottom-29,2,positionSouris,dummy,IdentiteSurN);
	              AjusteCurseur;
	              ChangeDelimitationEditionRectFenetreArbreDeJeu(positionSouris);
	              EraseRect(QDGetPortBound());
	              DrawContents(GetArbreDeJeuWindow());

	              SetPort(oldPort);
	              exit(TraiteSourisCommentaires);
	            end;
	        end;
        
        {WritelnDansRapport('tapez une touche');
        AttendFrappeClavier;}
        
        SetPort(oldPort);
      end;
end;


{
procedure TraiteSourisGestion(evt : eventRecord);
begin
end;
}

procedure TraiteSourisRapport(evt : eventRecord);
begin
  ClicInRapport(evt);
end;

(*********************** displayHandlers **************************)

procedure DrawContents(whichWindow : WindowPtr);
var oldClipRgn : RgnHandle;
    visibleRgn : RgnHandle;
  
  procedure ClipToViewArea;
    var r : rect;
    begin
      oldclipRgn := NewRgn();
      GetClip(oldClipRgn);
      r := GetWindowPortRect(whichWindow);
      with r do
      begin
        right := right-scbarWidth;
        bottom := bottom-scbarWidth;
      end;
      ClipRect(r);
    end;
    
  begin
    
    {DrawScrollBars(whichWindow);}
    {ClipToViewArea;}        (***** cf + bas *****)
    
    
    if whichWindow=wPlateauPtr 
      then
        begin
          if enRetour 
            then 
              begin
                visibleRgn := NewRgn();
                DessineRetour(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),'DrawContents');
                DisposeRgn(visibleRgn);
              end
            else 
              begin
                visibleRgn := NewRgn();
                EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),enSetUp | EnModeEntreeTranscript());
                if not(enSetUp) & afficheInfosApprentissage then EcritLesInfosDApprentissage;
                DisposeRgn(visibleRgn);
              end;
        end
      else
        if whichWindow=wCourbePtr 
          then 
            begin
              DessineCourbe(0,nbreCoup,kCourbeColoree,'DrawContents');
              DessineSliderFenetreCourbe;
            end
          else 
            if whichWindow=wGestionPtr 
            then EcritGestionTemps
            else
              if whichWindow=wReflexPtr 
              then EcritReflexion
              else
                if whichWindow=wListePtr 
                then 
                  begin
                    
                    EcritRubanListe(true);
                    EcritListeParties(false,'DrawContents');
                    if gIsRunningUnderMacOSX then
                      if IsWindowHilited(wListePtr)
							          then MontrerAscenseurListe
							          else CacherAscenseurListe;
                  end
                else
                  if whichWindow=wStatPtr 
                    then 
                      begin
                        EcritRubanStatistiques;
                        EcritStatistiques(false);
                      end
                    else 
                      if EstLaFenetreDuRapport(whichWindow)
                        then RedrawFenetreRapport
                        else
                          if whichWindow=IconisationDeCassio.theWindow
                            then DessinePictureIconisation
                            else
                              if whichWindow=GetArbreDeJeuWindow()
                                then 
                                  begin
                                    DessineZoneDeTexteDansFenetreArbreDeJeu(false);
                                    EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
                                  end
                                else
                                  if whichWindow=wAidePtr
                                    then DessineAide(gAideCourante)
                                    else
                                      if whichWindow=wPalettePtr
                                      then DessinePalette;
    
    DessineBoiteDeTaille(whichWindow);
      
      
    {  
    SetClip(oldClipRgn);     (******  toujours faire aller ces 2 lignes ****)
    DisposeRgn(oldclipRgn);  (******  avec ClipToViewArea               ****)
    }
  end;
  
procedure DoUpdateWindow(whichWindow : WindowPtr);
var oldPort : grafPtr;
    visibleRgn : RgnHandle;
begin
  GetPort(oldPort);
  CheckScreenDepth;
  if whichWindow = NIL
    then
      begin
        SysBeep(0);
        WritelnDansRapport('ERROR : (whichWindow = NIL) dans DoUpdateWindow');
      end
    else
      begin
			  BeginUpdate(whichWindow);
			  
			  visibleRgn := NewRgn();
			  if not(RegionEstVide(GetWindowVisibleRegion(whichWindow,visibleRgn))) then
			    begin
			      SetPortByWindow(whichWindow);
			      
			      if gIsRunningUnderMacOSX & WindowDeCassio(whichWindow) then
			        if (whichWindow = wPlateauPtr)
			          then EraseRectDansWindowPlateau(GetWindowPortRect(whichWindow))
			          else EraseRect(GetWindowPortRect(whichWindow));
			        
			      if (whichWindow = wListePtr) then InvalidateJustificationPasDePartieDansListe;
			      DrawContents(whichWindow);
			    end;
			  DisposeRgn(visibleRgn);
			  
			  EndUpdate(whichWindow);
			end;
    
  SetPort(oldPort);
end;

procedure EssaieUpdateEventsWindowPlateau;
begin
 if not(Quitter) then
 if not(enSetUp) then
   begin
     if windowPaletteOpen & (wPalettePtr <> NIL) then
       if IsWindowUpdatePending(wPalettePtr) then 
         begin
           DoUpdateWindow(wPalettePtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     
     if windowPlateauOpen & (wPlateauPtr <> NIL) then
       if IsWindowUpdatePending(wPlateauPtr) then 
         begin
           DoUpdateWindow(wPlateauPtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     
     if windowListeOpen & (wListePtr <> NIL) then
       if IsWindowUpdatePending(wListePtr) then 
         begin
           DoUpdateWindow(wListePtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if FenetreRapportEstOuverte() then
       if IsWindowUpdatePending(GetRapportWindow()) then 
         begin
           DoUpdateWindow(GetRapportWindow());
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowStatOpen & (wStatPtr <> NIL) then
       if IsWindowUpdatePending(wStatPtr) then 
         begin
           DoUpdateWindow(wStatPtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if arbreDeJeu.windowOpen & (GetArbreDeJeuWindow() <> NIL) then
       if IsWindowUpdatePending(GetArbreDeJeuWindow()) then 
         begin
           DoUpdateWindow(GetArbreDeJeuWindow());
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowGestionOpen & (wGestionPtr <> NIL) then
       if IsWindowUpdatePending(wGestionPtr) then 
         begin
           DoUpdateWindow(wGestionPtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowCourbeOpen & (wCourbePtr <> NIL) then
       if IsWindowUpdatePending(wCourbePtr) then 
         begin
           DoUpdateWindow(wCourbePtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowAideOpen & (wAidePtr <> NIL) then
       if IsWindowUpdatePending(wAidePtr) then 
         begin
           DoUpdateWindow(wAidePtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowReflexOpen & (wReflexPtr <> NIL) then
       if IsWindowUpdatePending(wReflexPtr) then 
         begin
           DoUpdateWindow(wReflexPtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
   end;
end;


(*********************** event handlers ****************************)



procedure StoreKeyDownEvent(var whichEvent : eventRecord);
begin
  with gKeyDownEventsData do
    begin
      
      delaiAvantDebutRepetition := 15;  {1/4eme de seconde}
    
      if (whichEvent.message <> lastEvent.message) |
         (TickCount() >= tickFrappeTouche + 15)
        then
          begin
            tickFrappeTouche                               := TickCount();
            tickChangementClavier                          := tickFrappeTouche;
            tickcountMinimalPourNouvelleRepetitionDeTouche := 0;
            noDelay                                        := false;
          end;
      
      lastEvent       := whichEvent;
      lastEvent.what  := keyDown;
      whichEvent.what := keyDown;
      
      MySystemTask;
      MyGetKeys(theKeys);
      theChar := chr(BAND(whichEvent.message,charCodemask));
      keyCode := BSR(BAND(whichEvent.message,keyCodeMask),8);
            
    end;
end;


procedure SetRepetitionDeToucheEnCours(flag : boolean);
begin
  gKeyDownEventsData.repetitionEnCours := flag;
end;


function RepetitionDeToucheEnCours() : boolean;
begin
  RepetitionDeToucheEnCours := gKeyDownEventsData.repetitionEnCours;
end;


function DateOfLastKeyDownEvent() : SInt32;
begin
  DateOfLastKeyDownEvent := gKeyDownEventsData.tickFrappeTouche;
end;


function DateOfLastKeyboardOperation() : SInt32;
begin
  DateOfLastKeyboardOperation := gKeyDownEventsData.tickChangementClavier;
end;


function NoDelayAfterKeyboardOperation() : boolean;
begin
  NoDelayAfterKeyboardOperation := gKeyDownEventsData.noDelay;
end;


procedure RemoveDelayAfterKeyboardOperation;
begin
  gKeyDownEventsData.noDelay := true;
end;


procedure AttendrePendantRepetitionOfKeyDownEvent(var repetitionDetectee : boolean);
var doitAttendreRepetition : boolean;
    myLocalEvent : eventRecord;
    localSleep : SInt32;
    theKeysPourRepetition:myKeyMap;
begin
  doitAttendreRepetition := true;
  
  with gKeyDownEventsData do
    repeat
      {WritelnStringAndBoolDansRapport('1.doitAttendre = ',doitAttendreRepetition);}
      
      MyGetKeys(theKeysPourRepetition);
      if not(MemesTouchesAppuyees(theKeys,theKeysPourRepetition)) |
         not(ToucheAppuyee(keyCode)) then
        begin
          doitAttendreRepetition := false;
          repetitionDetectee := false;
        end;
      
      if TickCount() < tickcountMinimalPourNouvelleRepetitionDeTouche
        then 
          begin
            localSleep := 1;
            if doitAttendreRepetition & WaitNextEvent(autoKeyMask,myLocalEvent,localSleep,NIL) then
              begin
                {WritelnDansRapport('autoKeyDetecte');}
                doitAttendreRepetition := false;
                repetitionDetectee := true;
              end;
          end
        else
          begin
            if doitAttendreRepetition & EventAvail(autoKeyMask,myLocalEvent) then
              begin
                {WritelnDansRapport('autoKeyDetecte');}
                doitAttendreRepetition := false;
                repetitionDetectee := true;
              end;
          end;
      
      if doitAttendreRepetition & EventAvail(KeyDownMask,myLocalEvent) then
        begin
          {WritelnDansRapport('KeyDownDetecte');}
          doitAttendreRepetition := false;
          repetitionDetectee := false;
        end;
         
      if tickcountMinimalPourNouvelleRepetitionDeTouche < tickFrappeTouche + delaiAvantDebutRepetition
        then tickcountMinimalPourNouvelleRepetitionDeTouche := tickFrappeTouche + delaiAvantDebutRepetition;
      
      {WritelnStringAndBoolDansRapport('2.doitAttendre = ',doitAttendreRepetition);}
      
      SetRepetitionDeToucheEnCours(repetitionDetectee);
        
    until (TickCount() >= tickcountMinimalPourNouvelleRepetitionDeTouche) | not(doitAttendreRepetition);
end;


procedure KeyDownEvents;
  var nbRepetitions : SInt32;
      theMenuKeyCmd : SInt32;
      peutRepeter : boolean;
      tickEntree : SInt32;
  begin
    with gKeyDownEventsData do
      begin
        inc(niveauxDeRecursionDansDoKeyPress);
        if (niveauxDeRecursionDansDoKeyPress <= 1) | (enRetour | enSetUp | EnModeEntreeTranscript() | gPendantLesInitialisationsDeCassio) then
          begin
            SetRepetitionDeToucheEnCours(true);
            
            StoreKeyDownEvent(theEvent);
            nbRepetitions := 0;
            
            if debuggage.evenementsDansRapport then EcritKeyDownEventDansRapport(lastEvent);
            
            
            
            tickEntree := TickCount();
            
            repeat
              nbRepetitions := nbRepetitions+1;
              if nbRepetitions >= 4 then 
                begin
                  lastEvent.what := autoKey;
                  theEvent.what  := autoKey;
                end;
            
              if not((lastEvent.what = autoKey) & (TickCount() < tickcountMinimalPourNouvelleRepetitionDeTouche)) then
                begin
                  if BAND(lastEvent.modifiers,cmdKey)=0
                    then 
                      begin
                        if not(iconisationDeCassio.enCours) then
                          DoKeyPress(theChar,peutRepeter);
                      end
                    else
                      if not(ToucheCommandeInterceptee(theChar,lastEvent,peutRepeter)) then
                        begin
                          FixeMarquesSurMenus;
                          {SetMenusChangeant(theEvent.modifiers);}
                          if sousEmulatorSousPC
                            then theMenuKeyCmd := MyMenuKey(theChar)
                            else theMenuKeyCmd := MenuKey(theChar);
                          DoMenuCommand(theMenuKeyCmd,peutRepeter);
                        end;
                end;
              if peutRepeter then AttendrePendantRepetitionOfKeyDownEvent(peutRepeter);
                
            until not(peutRepeter);
            
            DecrementeNiveauCurseurTeteDeMort;
            SetRepetitionDeToucheEnCours(false);
            
            {WritelnStringAndNumDansRapport('temps passé dans KeyDownEvents = ',TickCount()-tickEntree);}
          end;
        dec(niveauxDeRecursionDansDoKeyPress);
    end;
  end;


procedure KeyUpEvents;
begin
  {WritelnDansRapport('KeyUp event détecté');}
  SetRepetitionDeToucheEnCours(false);
  gKeyDownEventsData.lastEvent.message     := 0;
  gKeyDownEventsData.tickChangementClavier := TickCount();
end;


procedure MouseDownEvents;
var codeEvt : SInt16; 
    LimiteRect : rect;
    ActiveeParDrag : boolean;
    whichWindow : WindowPtr;
    ResumeEventClic : boolean;
    shift,command,option,control : boolean;
    menuResult : SInt32;
    peutRepeter : boolean;
begin
   IncrementeCompteurDeMouseEvents;
   begin  
     shift := BAND(theEvent.modifiers,shiftKey) <> 0;
     command := BAND(theEvent.modifiers,cmdKey) <> 0;
     option := BAND(theEvent.modifiers,optionKey) <> 0;
     control := BAND(theEvent.modifiers,controlKey) <> 0;
     
     ResumeEventClic := BAND(theEvent.modifiers,activeflag) <> 0;
     codeEvt := FindWindow(theEvent.where,whichWindow);
     if ResumeEventClic | inBackGround then   {reactivation de l'application ?}
       begin
         if whichWindow <> NIL then
           DoActivateWindow(whichWindow,true);
         if inBackGround then
           if whichWindow <> NIL then
             if WindowDeCassio(whichWindow) then
               if (whichWindow<>wPlateauPtr) & (whichWindow<>wPalettePtr)
                 then HiliteWindow(whichWindow,true)
                 else 
                   begin
                     if FrontWindowSaufPalette() <> NIL 
                      then HiliteWindow(FrontWindowSaufPalette(),true)
                      else if wPalettePtr<> NIL then
                              HiliteWindow(wPalettePtr,true);
                   end;
         if windowPaletteOpen then
           if not(IsWindowVisible(wPalettePtr)) & not(enSetUp | iconisationDeCassio.enCours) then
             begin
               ShowHide(wPalettePtr,true);
               DessinePalette;
             end;
         if (TEFromScrap() = noErr) then;
         inBackGround := false;
         ResumeEventClic := true;
       end;
        
            
      if not(ResumeEventClic) then
        CASE codeEvt of
         InMenuBar   : begin
                         FixeMarquesSurMenus;
                         SetMenusChangeant(theEvent.modifiers);
                         menuResult := MenuSelect(theEvent.where);
                         
                         {$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
                         DoMenuCommand(menuResult,peutRepeter);
                         {$ELSEC }
					               if gHasTextServices & TSMMenuSelect(menuResult)
					                 then EndHiliteMenu(theEvent.when,10,false) { needed even if TSM or Script Manager handle the menu }
					                 else DoMenuCommand(menuResult,peutRepeter);
					               {$ENDC }
                       end;
         InContent   : if (whichWindow=iconisationDeCassio.theWindow) & iconisationDeCassio.encours
                        then 
                          begin
                            {if EstUnDoubleClic(theEvent,true) then}
                              DeiconiserCassio;
                          end
                        else
                          begin
                            if whichWindow=wPlateauPtr
			                         then
			                           begin
			                             if (wPlateauPtr=FrontWindowSaufPalette()) | WindowPlateauSousDAutresFenetres()
			                               then 
			                                 begin
			                                   EssaieUpdateEventsWindowPlateau;
			                                   TraiteSourisFntrPlateau(theEvent);
			                                 end
			                               else 
			                                 begin
			                                   SelectWindowSousPalette(wPlateauPtr);
			                                   if windowCourbeOpen then SelectWindowSousPalette(wCourbePtr);
			                                   if windowAideOpen then SelectWindowSousPalette(wAidePtr);
			                                   if windowGestionOpen then SelectWindowSousPalette(wGestionPtr);
			                                   if windowReflexOpen then SelectWindowSousPalette(wReflexPtr);
			                                   if windowListeOpen then SelectWindowSousPalette(wListePtr);
			                                   if windowStatOpen then SelectWindowSousPalette(wStatPtr);
			                                   if arbreDeJeu.windowOpen then SelectWindowSousPalette(GetArbreDeJeuWindow());
			                                 end;
			                             if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
			                           end
			                         else
			                           begin
			                             if (whichWindow<>FrontWindowSaufPalette()) & (whichWindow<>wPalettePtr)
			                               then 
			                                 begin
			                                   if (whichWindow<>GetArbreDeJeuWindow()) & arbreDeJeu.enModeEdition
			                                     then DeactiverModeEditionFenetreArbreDeJeu;
			                                   SelectWindowSousPalette(whichWindow);
			                                   if (whichWindow=wListePtr) & (wListePtr <> NIL)
			                                     then ShowControl(MyGetRootControl(wListePtr));
			                                   if not(WindowDeCassio(FrontWindow())) 
			                                     then InitCursor;
			                                   AnnulerSousCriteresRuban;
			                                   if whichWindow=GetArbreDeJeuWindow() then
			                                     TraiteSourisCommentaires(theEvent,true);
			                                 end
			                               else 
			                                 if not(ResumeEventClic) then
			                                 begin  
			                                   if whichWindow<>GetArbreDeJeuWindow() then 
			                                     if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
			                                   if whichWindow=wListePtr then TraiteSourisListe(theEvent);
			                                   if whichWindow=wCourbePtr then TraiteSourisCourbe(theEvent);
			                                   if whichWindow=wAidePtr then TraiteSourisAide(theEvent);
			                                   if whichWindow=wPalettePtr then TraiteSourisPalette(theEvent);
			                                   {if whichWindow=wGestionPtr then TraiteSourisGestion(theEvent);}
			                                   if whichWindow=wStatPtr then TraiteSourisStatistiques(theEvent);
			                                   if EstLaFenetreDuRapport(whichWindow) then TraiteSourisRapport(theEvent);
			                                   if whichWindow=GetArbreDeJeuWindow() then TraiteSourisCommentaires(theEvent,false);
			                                 end;   
			                            end;
			                        end;
         InGoAway    : IF TrackGoAway(whichWindow,theEvent.where) 
                         then 
                           begin
                             if whichWindow<>GetArbreDeJeuWindow() then 
                               if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
                             AnnulerSousCriteresRuban;
                             DoClose(whichWindow,not(option));
                             if option then FermeToutesLesFenetresAuxiliaires;
                           end;
         InSysWindow : begin
                         if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
                         AnnulerSousCriteresRuban;
                         {$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
                         Systemclick(theEvent,whichWindow);
                         {$ENDC }
                       end;
         inDrag      : begin
                         {if whichWindow<>GetArbreDeJeuWindow() then 
                           if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;}
                         AnnulerSousCriteresRuban;
                         ActiveeParDrag := false;
                         if (whichWindow<>FrontWindowSaufPalette()) & (whichWindow<>wPalettePtr) then
                           begin
                             ActiveeParDrag := true;
                             if BAND(theEvent.modifiers,cmdKey)=0 then 
                               begin
                                 DoActivateWindow(FrontWindowSaufPalette(),false);
                                 SelectWindowSousPalette(whichWindow);
                                 DoUpdateWindow(whichWindow);
                                 DoActivateWindow(whichWindow,true);
                               end;
                           end;
                         SetRect(limiteRect,-20000,20,20000,20000);
                         {if windowPaletteOpen then ClipWindowStructFromWMPort(wPalettePtr);}
                         if StillDown() then 
                           begin
                             DragWindow(whichWindow,theEvent.where,@limiteRect);
                             if (whichWindow = wPlateauPtr) | (whichWindow = wListePtr) | (whichWindow = wStatPtr)
                               then SetPositionsTextesWindowPlateau;
                           end;
                         EmpileFenetresSousPalette;
                         ActiveeParDrag := ActiveeParDrag & (whichWindow=FrontWindowSaufPalette());
                         if ActiveeParDrag then
                           if (whichWindow=wListePtr) & (wListePtr <> NIL)
                             then ShowControl(MyGetRootControl(wListePtr));
                       end;
         inGrow      : begin
                         if whichWindow<>GetArbreDeJeuWindow() then 
                           if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
                         AnnulerSousCriteresRuban;
                         if (whichWindow=FrontWindowSaufPalette()) | (whichWindow=wPlateauPtr)
                           then 
                             begin
                               DoGrowWindow(whichWindow,theEvent);
                               if not(enSetUp) then DoUpdateWindow(whichWindow);
                             end
                           else
                             begin
                               SelectWindowSousPalette(whichWindow);
                             end;
                        end;
                           
         inZoomIn,inZoomOut
                   :if TrackBox(whichWindow,theEvent.where,codeEvt)
                         then 
                           begin
                             if whichWindow<>GetArbreDeJeuWindow() then 
                               if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
                             AnnulerSousCriteresRuban;
                             if whichWindow=wListePtr 
                               then 
                                 begin
                                   (*
                                   case nbColonnesFenetreListe of
										                 kAvecAffichageDistribution        : DoChangeEcritTournoi(kAvecAffichageSeulementDesJoueurs);
										                 kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageDistribution);
										                 kAvecAffichageSeulementDesJoueurs : DoChangeEcritTournoi(kAvecAffichageTournois);
										               end; {case}
										               *)
										               
										               listeEtroiteEtNomsCourts := not(listeEtroiteEtNomsCourts);
  					                       DoChangeEcritTournoi(nbColonnesFenetreListe);
										             end
                               else
                                 if (whichWindow=iconisationDeCassio.theWindow) & iconisationDeCassio.encours
                                 then DeiconiserCassio
                                 else MyZoomInOut(whichWindow,codeEvt);
                           end;
                         
       END;   {case codeEvt}
    if EstUnDoubleClic(theEvent,false) then;
    DecrementeNiveauCurseurTeteDeMort;
  end;
end;


procedure MouseUpEvents;
begin
  EndLiveUndo;
end;


procedure UpdateEvents;
var whichWindow : WindowPtr;
begin
  whichWindow := WindowPtr(theEvent.message);
  if windowPaletteOpen then
    if IsWindowUpdatePending(wPalettePtr)
     then DoUpdateWindow(wPalettePtr);
  if windowPlateauOpen then
    if whichWindow<>wPlateauPtr then
      if IsWindowUpdatePending(wPlateauPtr)
        then DoUpdateWindow(wPlateauPtr);
  DoUpdateWindow(whichWindow);
end;
  



procedure MultiFinderEvents;
const suspend_resume_bit=$0001;
      resuming=1;
var theFrontWindow : WindowPtr;
    bidEvent : eventRecord;
    process:ProcessSerialNumber;
    err : OSErr;
begin
  theFrontWindow := FrontWindowSaufPalette();
  if (BAND(theEvent.message,suspend_resume_bit)=resuming)
    then      {resumeEvent}
      begin
      
        { Make us the front process : this brings all the windows to the front }
        if (GetCurrentProcess(process) = NoErr) then
          err := SetFrontProcess(process);
        
        GetCurrentScript(gLastScriptUsedOutsideCassio);
        if windowPaletteOpen then
          if not(IsWindowVisible(wPalettePtr)) & not(enSetUp | iconisationDeCassio.enCours) then
            begin
              ShowHide(wPalettePtr,true);
              DessinePalette;
            end;
        if (theFrontWindow <> NIL) then
          if WindowDeCassio(theFrontWindow) then
            begin
              HiliteWindow(theFrontWindow,true);
              DoActivateWindow(theFrontWindow,true);
            end;
        inBackGround := false;
        if (TEFromScrap() = noErr) then;
        if GetNextEvent(MDownMask,bidEvent) then;
           { à la place de FlushEvents(MDownmask,0); }
      end
    else      {suspend event}
      begin
        if windowPaletteOpen & not(gIsRunningUnderMacOSX) then
          if IsWindowVisible(wPalettePtr) then
             ShowHide(wPalettePtr,false);
        if theFrontWindow <> NIL then
          if WindowDeCassio(theFrontWindow) then
            begin
              HiliteWindow(theFrontWindow,false);
              DoActivateWindow(theFrontWindow,false);
            end;
        EnableKeyboardScriptSwitch;
        SwitchToScript(gLastScriptUsedOutsideCassio);
        inBackGround := true;
        if enModeIOS & (MyZeroScrap()=NoErr) & (MyPutScrap(Length(chainePourIOS),'TEXT',@chainePourIOS[1])=NoErr) then;
        AnnulerSousCriteresRuban;
      end;
end;


procedure ActivateEvents;
var activate : boolean;
    whichWindow : WindowPtr;
begin
  with theEvent do
  begin
    whichWindow := WindowPtr(message);
    activate := BAND(modifiers,activeflag) <> 0;
    if whichWindow <> NIL then
      if WindowDeCassio(whichWindow) then
        begin
          DoActivateWindow(whichWindow,activate);
        end;
  end;
end;

procedure DiskEvents;
var diskInitPt : Point;
begin {$unused diskInitPt}
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
{$ELSEC }
  if (HiWrd(theEvent.message) <> noErr) then
    begin
      DILoad;
      diskInitPt.v := 120;
      diskInitPt.h := 100;
      if DIBadMount(diskInitPt, theEvent.message) <> noErr then;
      DIUnload;
    end;
{$ENDC }
end;

procedure DoAppleEvents;
var Err : OSErr;
begin
  {TraceLog('DoAppleEvents');}
  Err := AEProcessAppleEvent(theEvent);
  {TraceLog('AEProcessAppleEvent : err = '+NumEnString(Err));}
end;


function EvenementTraiteParFenetreArbreDeJeu(evt : eventRecord) : boolean;
const MachineAEcrireID=10129;
var shift,command,option,control : boolean;
    ch : char;
    myText : TEHandle;
begin
  
  shift := BAND(evt.modifiers,shiftKey) <> 0;
  command := BAND(evt.modifiers,cmdKey) <> 0;
  option := BAND(evt.modifiers,optionKey) <> 0;
  control := BAND(evt.modifiers,controlKey) <> 0;
  
  with arbreDeJeu do
   begin
     
     ch := chr(BAND(evt.message,charCodemask));
     
     {les evenements de menu, ou ceux qui ne sont pas des evenemnts claviers, 
      ne concerent certainement pas la zone commentaire de la fenetre Arbre de Jeu}
     if command | not(windowOpen) | not((evt.what = keyDown) | (evt.what = autoKey)) then
	     begin
	       EvenementTraiteParFenetreArbreDeJeu := false;
	       exit(EvenementTraiteParFenetreArbreDeJeu);
	     end;
	     
	   { Si c'est un evenement clavier, on regarde si la fenetre est au premier plan}
	   if ((evt.what = keyDown) | (evt.what = autoKey)) then
	     if EnTraitementDeTexte
	       then
	         begin
	           if ((FrontWindowSaufPalette() = GetRapportWindow()) & FenetreRapportEstOuverte()) |
	              ((FrontWindowSaufPalette() = wListePtr) & FenetreListeEnModeEntree()) |
	              (IsAnArrowKey(ch) & not(option) & windowListeOpen) then
	             begin
	               EvenementTraiteParFenetreArbreDeJeu := false;
	               exit(EvenementTraiteParFenetreArbreDeJeu);
	             end;
	         end
	       else
	         begin
	           if (GetArbreDeJeuWindow() <> FrontWindowSaufPalette()) then
	             begin
	               EvenementTraiteParFenetreArbreDeJeu := false;
	               exit(EvenementTraiteParFenetreArbreDeJeu);
	             end;
	         end;
	     
	   
	   myText := GetDialogTextEditHandle(theDialog);
	   
	   if enModeEdition & ((ord(ch) = TabulationKey) | 
	                       (ord(ch) = EscapeKey) | 
	                       ((ord(ch)= ReturnKey) & shift) |
	                       (ord(ch) = EntreeKey)) then
	     begin     {desactivation}
	       arbreDeJeu.doitResterEnModeEdition := false;
	       ValideZoneCommentaireDansFenetreArbreDeJeu;
	       DecrementeNiveauCurseurTeteDeMort;
	       EvenementTraiteParFenetreArbreDeJeu := true;
	       
	       if (ord(ch) = EntreeKey) then AfficheCommentairePartieDansRapport;
	       
		     exit(EvenementTraiteParFenetreArbreDeJeu);
	     end;
		 
		 if not(enModeEdition) & (GetArbreDeJeuWindow()=FrontWindowSaufPalette()) & 
		                     ((ord(ch) = EntreeKey) |
		                      (ord(ch) = TabulationKey)) then
		   begin     {activation}
		     ActiverModeEditionFenetreArbreDeJeu;
		     DecrementeNiveauCurseurTeteDeMort;
		     EvenementTraiteParFenetreArbreDeJeu := true;
	       exit(EvenementTraiteParFenetreArbreDeJeu);
		   end;
		 
		 if (myText <> NIL) & enModeEdition then 
		   begin
		     TEKey(ch,myText);
		     {if EnTraitementDeTexte & avecSon then PlaySoundSynchrone(MachineAEcrireID);}
		     SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
		     EvenementTraiteParFenetreArbreDeJeu := true;
		     DecrementeNiveauCurseurTeteDeMort;
		     exit(EvenementTraiteParFenetreArbreDeJeu);
		   end;
		 
		 EvenementTraiteParFenetreArbreDeJeu := false;
	   exit(EvenementTraiteParFenetreArbreDeJeu);
	end;  
end;

procedure MetFlagsModifiersDernierEvenement(var whichEvent : eventRecord; var modifiersChanged : boolean);
var oldShift,oldCommand,oldOption,oldControl,oldVerouillage : boolean;
begin
  modifiersChanged := false;
  with DernierEvenement do
    begin
      oldShift        := shift;
      oldCommand      := command;
      oldOption       := option;
      oldControl      := control;
      oldVerouillage  := verouillage;
      
      with whichEvent do
      begin
        shift := BAND(modifiers,shiftKey) <> 0;
        command := BAND(modifiers,cmdKey) <> 0;
        option := BAND(modifiers,optionKey) <> 0;
        control := BAND(modifiers,controlKey) <> 0;
        verouillage := BAND(modifiers,alphaLock) <> 0;
      end;
      
      if (oldShift<>shift)       |
         (oldCommand<>command)   |
         (oldOption<>option)     |
         (oldControl<>control)   |
         (oldVerouillage<>verouillage) then
       begin
         modifiersChanged := true;
         AjusteCurseur;
         DiminueLatenceEntreDeuxDoSystemTask;
         AccelereProchainDoSystemTask(60);
       end;
    end;
end;

procedure TraiteNullEvent(var whichEvent : eventRecord);
var modifiersChanged : boolean;
begin
  if debuggage.evenementsDansRapport then
	  CASE whichEvent.what of
	      mouseDown       :  WritelnDansRapport('TraiteNullEvent : MouseDownEvents ');
	      mouseUp         :  WritelnDansRapport('TraiteNullEvent : MouseUpEvents ');
	      keyUp           :  WritelnDansRapport('TraiteNullEvent : KeyUpEvents ');
	      keyDown         :  WritelnDansRapport('TraiteNullEvent : KeyDownEvents   ');
	      autoKey         :  WritelnDansRapport('TraiteNullEvent : KeyDownEvents   ');
	      updateEvt       :  WritelnDansRapport('TraiteNullEvent : UpdateEvents;   ');
	      activateEvt     :  WritelnDansRapport('TraiteNullEvent : ActivateEvents; ');
	      osEvt           :  WritelnDansRapport('TraiteNullEvent : MultiFinderEvents; ');
	      diskEvt         :  WritelnDansRapport('TraiteNullEvent : DiskEvents');
	      kHighLevelEvent :  WritelnDansRapport('TraiteNullEvent : AppleEvents');
	      nullEvent       :  WritelnDansRapport('TraiteNullEvent : nullEvent');
	  END;    {case}
  if (whichEvent.what = nullEvent) then
    begin
      MetFlagsModifiersDernierEvenement(whichEvent,modifiersChanged);
      if modifiersChanged then 
        begin
          TesterAffichageNomsDesGagnantsEnGras(whichEvent.modifiers);
          TesterAffichageNomsJaponaisEnRoman(whichEvent.modifiers);
        end;
    end;
  SwitchToRomanScript;
end;



procedure TraiteOneEvenement;
var doitTraiterEvenement : boolean;
    modifiersChanged : boolean;
    tickCountDepart : SInt32;
begin

  tickCountDepart := TickCount();
  
  {
  WriteStringAndNumDansRapport('Debut de TraiteOneEvenement(), kWNESleep = ',kWNESleep);
  WriteStringAndNumDansRapport('  latenceEntreDeuxDoSystemTask = ',latenceEntreDeuxDoSystemTask);
  WriteStringAndNumDansRapport('  tickCountDepart = ',tickCountDepart);
  WritelnStringAndNumDansRapport('  delta = ',TickCount() - tickCountDepart);
  }

  MetFlagsModifiersDernierEvenement(theEvent,modifiersChanged);
  FaireClignoterFenetreArbreDeJeu;
  if modifiersChanged then 
    begin
      TesterAffichageNomsDesGagnantsEnGras(theEvent.modifiers);
      TesterAffichageNomsJaponaisEnRoman(theEvent.modifiers);
    end;
  
  doitTraiterEvenement := not(EvenementTraiteParFenetreArbreDeJeu(theEvent));
  
  if doitTraiterEvenement then
    begin
		  if debuggage.evenementsDansRapport then
			  CASE theEvent.what of
			      mouseDown       :  WritelnDansRapport('TraiteOneEvenement : MouseDownEvents ');
			      keyUp           :  WritelnDansRapport('TraiteOneEvenement : KeyUpEvents ');
			      keyDown         :  WritelnDansRapport('TraiteOneEvenement : KeyDownEvents   ');
			      autoKey         :  WritelnDansRapport('TraiteOneEvenement : KeyDownEvents   ');
			      updateEvt       :  WritelnDansRapport('TraiteOneEvenement : UpdateEvents;   ');
			      activateEvt     :  WritelnDansRapport('TraiteOneEvenement : ActivateEvents; ');
			      osEvt           :  WritelnDansRapport('TraiteOneEvenement : MultiFinderEvents; ');
			      diskEvt         :  WritelnDansRapport('TraiteOneEvenement : DiskEvents');
			      kHighLevelEvent :  WritelnDansRapport('TraiteOneEvenement : AppleEvents');
			      nullEvent       :  WritelnDansRapport('TraiteOneEvenement : nullEvent');
			      otherwise          WritelnDansRapport('TraiteOneEvenement : evenement inconnu !!!!');
			  END;    {case}  
			if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(theEvent);
		  CASE theEvent.what of
		      mouseDown       : MouseDownEvents;
		      mouseUp         : MouseUpEvents;
		      keyUp           : KeyUpEvents;
		      keyDown         : KeyDownEvents;
		      autoKey         : KeyDownEvents;
		      updateEvt       : UpdateEvents;
		      activateEvt     : ActivateEvents;
		      osEvt           : MultiFinderEvents;
		      diskEvt         : DiskEvents; 
		      kHighLevelEvent : DoAppleEvents;
		  END;   {case}
    end;
  DiminueLatenceEntreDeuxDoSystemTask;
  AccelereProchainDoSystemTask(60);
  
  if arbreDeJeu.doitResterEnModeEdition then ActiverModeEditionFenetreArbreDeJeu;
    
  
  
  AjusteCurseur;
  SwitchToRomanScript;
  
  {
  WriteStringAndNumDansRapport('Fin de TraiteOneEvenement(), kWNESleep = ',kWNESleep);
  WriteStringAndNumDansRapport('  latenceEntreDeuxDoSystemTask = ',latenceEntreDeuxDoSystemTask);
  WriteStringAndNumDansRapport('  tickCountDepart = ',tickCountDepart);
  WriteStringAndNumDansRapport('  delta = ',TickCount() - tickCountDepart);
  WritelnStringAndNumDansRapport('  delaiAvantDoSystemTask = ',delaiAvantDoSystemTask);
  }
  
end;


procedure TraiteEvenements;
var nbreAttentes : SInt32;
    precedente : str255;
begin 
  nbreAttentes := 0;
  precedente := '';
  repeat
    {WritelnStringAndNumDansRapport('nbreCoup = ',nbreCoup);}
    PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
    EssaieUpdateEventsWindowPlateau;
    TraiteOneEvenement;
    if EstEnAttenteSelectionRapideDeListe() then
      inc(nbreAttentes);
    EssaieUpdateEventsWindowPlateau;
    if enSetUp 
      then FixeMarquesSurMenus
      else 
         while HasGotEvent(updateMask,theEvent,0,NIL) do
           begin
             if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(theEvent);
             UpdateEvents;
           end;
    PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
    if globalRefreshNeeded then DoGlobalRefresh;
    
    {si la vitesse du Mac est assez grande, on peut essayer la selection rapide
     dans la liste a la volee}
    if (indiceVitesseMac > 250) & (nbreAttentes > 0) & (GetDerniereChaineSelectionRapide() <> precedente) then
      begin
        TraiteSelectionRapideDeListe(GetDernierGenreSelectionRapide(),GetDerniereChaineSelectionRapide());
        precedente := GetDerniereChaineSelectionRapide();
      end;
    
  until not(HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)) & 
        not(EstEnAttenteSelectionRapideDeListe());
  
  if (nbreAttentes > 0) & (GetDerniereChaineSelectionRapide() <> precedente) then
    begin
      TraiteSelectionRapideDeListe(GetDernierGenreSelectionRapide(),GetDerniereChaineSelectionRapide());
      precedente := GetDerniereChaineSelectionRapide();
    end;
      
  AjusteSleep;
  AjusteCurseur;
end;


{remplacement de WaitNextEvent qui prend en compte le systeme japonais}
function HasGotEvent(myEventMask:EventMask; var whichEvent : eventRecord;sleep : UInt32;mouseRgn : RgnHandle) : boolean;
var gotEvent : boolean;
    (* OSErreur : OSErr; *)
    localEventMask:EventMask;
begin
  
  GererLiveUndo;
  
  { if the global variable gCassioChecksEvents is false, 
    then we only want minimalist event checking, so we filter the eventMask}
  if not(gCassioChecksEvents) 
    then localEventMask := BitAnd(mDownMask + highLevelEventMask + osMask, myEventMask)
    else localEventMask := myEventMask;
    
  (*
  if sleep <> lastSleepUsed then
    begin
      WritelnStringAndNumDansRapport('sleep = ',sleep);
      lastSleepUsed := sleep;
    end;
  *)
  
  
  gotEvent := WaitNextEvent(localEventMask,whichEvent,sleep,mouseRgn);
  
  
  (*
  OSErreur := SetScriptManagerVariable(smFontForce,gSavedFontForce);
  gotEvent := WaitNextEvent(localEventMask,whichEvent,sleep,mouseRgn);
  
  { clear fontForce again so it doesn't upset our operations }
  gSavedFontForce := GetScriptManagerVariable(smFontForce);
  OSErreur := SetScriptManagerVariable(smFontForce, 0);
  *)
  
  
{$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
  if gHasTextServices & (gotEvent | (whichEvent.what=nullEvent)) then
    if IntlTSMEvent(whichEvent) then 
      gotEvent := false;
{$ENDC}

  
  {if gotEvent then WritelnStringAndNumDansRapport('nbreCoup = ',nbreCoup);}
	HasGotEvent := gotEvent;
end;

procedure HandleEvent(var whichEvent : eventRecord);
begin
  theEvent := whichEvent;
  TraiteOneEvenement;
end;

END.