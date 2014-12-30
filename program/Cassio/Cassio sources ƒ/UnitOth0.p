UNIT UnitOth0;




INTERFACE







USES UnitTraceLog,MacTypes,Quickdraw,Controls,StringTypes,UnitDefinitionsPackedThorGame;
 
 
 
 
 CONST 
  finDuDebut=15;   { apres ce coup }
  
  
  pasdinterruption=0;
  interruptionSimple=1;
  kHumainVeutChangerCouleur=2;
  kHumainVeutChargerBase=4;
  kHumainVeutAnalyserFinale=8;
  kHumainVeutJouerSolitaires=16;
  kHumainVeutChangerHumCtreHum=32;
  kHumainVeutChangerCoulEtHumCtreHum=64;
  interruptionDepassementTemps=128;

  pionBlanc=1;
  pionNoir=-1;
  pionVide=0;
  PionInterdit=-7;
  pionSuggestionDeCassio=5; 
  petitpion=6;  
  effaceCase=7;
  pionMontreCoupLegal=8;
  pionEffaceCaseLarge=9;
(*pionEntoureCasePourMontrerCoupEnTete=10;
  pionEntoureCasePourEffacerCoupEnTete=11; *)
  PionDeltaBlanc=12;
  PionDeltaNoir=13;
  PionDeltaTraitsBlancs=14;
  PionDeltaTraitsNoirs=15;
  PionLosangeBlanc=16;
  PionLosangeNoir=17;
  PionLosangeTraitsBlancs=18;
  PionLosangeTraitsNoirs=19;
  PionCarreBlanc=20;
  PionCarreNoir=21;
  PionCarreTraitsBlancs=22;
  PionCarreTraitsNoirs=23;
  PionEtoile=24;
  PionPetitCercleNoir=25;
  PionPetitCercleBlanc=26;
  PionPetitCercleTraitsBlancs=27;
  PionPetitCercleTraitsNoirs=28;
  PionCroixTraitsBlancs=29;
  PionCroixTraitsNoirs=30;
  
  
  AffichageDifferentiel=1;
  AffichageAbsolu=2;
  
  coupInconnu=0;
  ScorePourUnSeulCoupLegal=-213;  {ou n'importe quoi d'aberrant}
  
  profondeurMax=-10;
  selectiviteMaximale=5;
  kNbMaxNiveaux=61;
  nbCoupsMeurtriers=9;  {9 est bien}
  noteMax=32767; 
  
  minutes10000000=600000001;  {temps infini}
  minutes48000=2880001;  {un mois}
  minutes10000=600001;
  minutes1440=86401;  {24 heures}
  minutes25=1501;  {1500=60*25   25 minutes}
  minutes10=601;  {10 minutes}
  minutes5=280;   {5 minutes}
  minutes4=220;   {4 minutes}
  minutes3=150;   {3 minutes}
  
  kUnMoisDeTemps = minutes48000;
  kInfiniteDetemps = minutes10000000;
  
  NiveauDebutants=1;
  NiveauAmateurs=2;
  NiveauClubs=3;
  NiveauForts=4;
  NiveauExperts=5;
  NiveauGrandMaitres=6;
  NiveauChampions=7;

  
  LargeurCasePalette=19;
  HauteurCasePalette=16;
  hauteurRubanListe=15;
  hauteurRubanStatistiques=23;
  hauteurChaqueLigneStatistique=10;
  
  NeSaitPas=0;
  VictoireNoire=1;
  VictoireBlanche=2;
  Nulle=3;
  ToutEstPerdant=4;  
  ToutEstProbablementPerdant=5;
  ReflPasDeDonnees                     = 0;
  PasAnalyseRetrograde                 = 0;      {synonyme}
  TypePasDeDonnees                     = 0;
  ReflGagnant                          = 1001;
  ReflGagnantExhaustif                 = 1002;
  ReflParfait                          = 1003;
  ReflParfaitExhaustif                 = 1004;
  ReflAnnonceGagnant                   = 1005;
  ReflAnnonceParfait                   = 1006;
  ReflMilieu                           = 1007;
  ReflRetrogradeParfait                = 1008;
  ReflRetrogradeGagnant                = 1009;
  ReflRetrogradeMilieu                 = 1010;
  ReflMilieuExhaustif                  = 1011;
  ReflTriGagnant                       = 1012;
  ReflTriParfait                       = 1013;
  ReflParfaitPhaseGagnant              = 1014;
  ReflParfaitExhaustPhaseGagnant       = 1015;
  ReflParfaitPhaseRechScore            = 1016;
  ReflRetrogradeParfaitPhaseGagnant    = 1017;
  ReflRetrogradeGagnantPhaseGagnant    = 1018;
  ReflRetrogradeParfaitPhaseRechScore  = 1019;
  ReflScoreDejaConnuFinale             = 1020;
  ReflScoreDeCeCoupConnuFinale         = 1021;    
  ReflZebraBookEval                    = 1022;
  {attention : changer le type ReflexionTypesSet ci-dessous quand on
               rajoute un genre de reflexion nouveau ! }
  
TYPE 
  ReflexionTypesSet = set of ReflGagnant..ReflZebraBookEval;

CONST
    
  pasdemessage=0;
  messageToutEstPerdant=1;
  messageEstGagnant=2;
  messageEstPerdant=3;
  messageFaitNulle=4;
  messageToutEstProbablementPerdant=5;


  kSortiePapier=1;
  kJeuNormal=2;
  kSortiePapierCourte=3;
  kSortiePapierLongue=4;
  kRechercheSolitairesDansBase=5;
  
  BaseLectureCriteres=1;
  BaseLectureJoueursEtTournois=2;
  testEgalite=1;
  testSuperieur=2;
  testInferieur=3;
  testSuperieurStrict=4;
  testInferieurStrict=5;      
  
  MoisEnToutesLettres=1;
  MoisEnChiffre=2;
  SucrerPurementEtSimplement=3;
              
  LongMaxBibl=41;           {bibliothque jusqu'au coup 41}
  tailleMaxTasBibl=32000;
  maxNbreLignesEnBibl=3200;
  SolitairesEnMemoire=10;
  nbMaxPartChargeables=2000000;
  nbMaxJoueursEnMemoire=40000;
  nbMaxTournoisEnMemoire=4000;
  taillecaselecture=16;
  nbMaxStatistiques=20;
  nbMaxInterversions=900;
  nbMaxCoupsLegauxDansHash=19;
  NbMaxItemsReouvrirMenu=20;
      
  PasDePartieActive       = -1;
  NeSaitPasNbrePartiesActives = 0;

  PositionCoinAvecCoordonnees=16;
  PositionCoinSansCoordonnees=0;
  
  DiagrammePartie=1;
  DiagrammePosition=2;
  DiagrammePourListe=3;
  
  axeSW_NE             = 1000;
  axeSE_NW             = 1001;
  central              = 1002;
  axeVertical          = 1003;
  axeHorizontal        = 1004;
  quartDeTourTrigo     = 1005;
  quartDeTourAntiTrigo = 1006;
  
  kSonTickID=5018;
  kSonTockID=5001;
  kSonEvolveID=3212;
  kSonGongID=3333;
  kSonAfricanDrumID=12129;

  windowID=1;
  PaletteDefID=34;
  CadenceDialogID=129;
  backMoveCurseurID=138;
  avanceMoveCurseurID=141;
  gommeCurseurID=143;
  pionBlancCurseurID=302;
  pionNoirCurseurID=303;
  
  
  ImprimerPosition=5;
  ImprimerDiagramme=6;
  ImprimerStatistiques=7;
  ImprimerListe=8;
  ImprimerBibliotheque=9;
  ImprimerNotation=10;
  
  PaletteRetourDebut     =1;
  PaletteDoubleBack      =2;
  PaletteBack            =3;
  PaletteForward         =4;
  PaletteDoubleForward   =5;
  PaletteAllerFin        =6;
  PaletteCoupPartieSel   =7;
  PaletteReflexion       =8;
  PaletteListe           =9;
  PaletteCouleur         =10;
  PaletteSablier         =11;
  PaletteInterrogation   =12;
  PaletteHorloge         =13;
  PaletteSon             =14;
  PaletteDiagramme       =15;
  PaletteBase            =16;
  PaletteCourbe          =17;
  PaletteStatistique     =18;
  
  
   
  TriParDate=1;
  TriParJoueurNoir=2;
  TriParJoueurBlanc=3;
  TriParOuverture=4;
  TriParScoreTheorique=5;
  TriParScoreReel=6;
  TriParNroJoueurNoir=7;
  TriParNroJoueurBlanc=8;
  TriParAntiDate=9;
  TriParTournoi=10;
  TriParDistribution=11;
     
  kQuickSort=1;
  kShellSort=2;
  kShellsortWithFixIncrements=3;
  kRadixSort=4;
  kEnumerationSort=5;
  
    
  phaseDebut=1;
  phaseMilieu=2;
  phaseFinale=3;
  phaseFinaleParfaite=4;
  
  complementationJoueurNoir=1;
  complementationJoueurBlanc=2;
  complementationTournoi=3;
   
  IndexationParOuvertures=1;
  IndexationParJoueursNoirs=2;
  IndexationParJoueursBlancs=3;
  
  MenusChangeantsID     = 2000;
  TitresFenetresTextID  = 10000;
  TextesCourbeID        = 10001;
  TextesStatistiquesID  = 10002;
  TextesListeID         = 10003;
  TextesGestionID       = 10004;
  TextesReflexionID     = 10005;
  TextesPlateauID       = 10006;
  TextesGroupesID       = 10007;
  TextesSolitairesID    = 10008;
  TextesRetrogradeID    = 10009;
  TextesSetUpID         = 10010;
  TextesCoeffsID        = 10011;
  TextesBibliothequeID  = 10012;
  TextesRapportID       = 10013;
  TextesAboutCassioID   = 10014;
  TextesFederationID    = 10015;
  TextesErreursID       = 10016;
  TextesBaseID          = 10017;
  TextesImpressionID    = 10019;
  TextesDiversID        = 10020;
  TextesNouveauFormatID = 10021;
  
  
  
  kTranslucidPattern   = 0;
  kWhitePattern        = 2;
  kLightGrayPattern    = 3;       { 25% }
  kGrayPattern         = 4;       { 50% }
  kDarkGrayPattern     = 5;       { 75% }
  kBlackPattern        = 6;       { 100% }
  
  kCouleurDiagramTransparent = 1;
  kCouleurDiagramBlanc       = 3;
  kCouleurDiagramVert        = 4;
  kCouleurDiagramBleu        = 5;
  kCouleurDiagramCyan        = 6;
  kCouleurDiagramMagenta     = 7;
  kCouleurDiagramRouge       = 8;
  kCouleurDiagramJaune       = 9;
  kCouleurDiagramNoir        = 10;
  
  parcheminCursorID  = 137;
  teteDeMortCursorID = 142;
  interversionCursorID = 146;  {ou 144}

  kDetruireCeNoeudEtFils=3;  {cf Dialogue d'ID 155 dans les ressources}
  kDetruireLesFils=4;
  
  

     kAdresseColonne1=1;     
     kAdresseColonne2=2;
     kAdresseColonne3=3;
     kAdresseColonne4=4;
     kAdresseColonne5=5;
     kAdresseColonne6=6;
     kAdresseColonne7=7;
     kAdresseColonne8=8;
     kAdresseLigne1=9;     
     kAdresseLigne2=10;
     kAdresseLigne3=11;
     kAdresseLigne4=12;
     kAdresseLigne5=13;
     kAdresseLigne6=14;
     kAdresseLigne7=15;
     kAdresseLigne8=16;
     kAdresseDiagonaleA4E8=17;
     kAdresseDiagonaleA3F8=18;
     kAdresseDiagonaleA2G8=19;
     kAdresseDiagonaleA1H8=20;
     kAdresseDiagonaleB1H7=21;
     kAdresseDiagonaleC1H6=22;
     kAdresseDiagonaleD1H5=23;
     kAdresseDiagonaleA5E1=24;
     kAdresseDiagonaleA6F1=25;
     kAdresseDiagonaleA7G1=26;
     kAdresseDiagonaleA8H1=27;
     kAdresseDiagonaleB8H2=28;
     kAdresseDiagonaleC8H3=29;
     kAdresseDiagonaleD8H4=30;
     kAdresseBlocCoinA1=31;
     kAdresseBlocCoinH1=32;
     kAdresseBlocCoinA8=33;
     kAdresseBlocCoinH8=34;
  {quelsques synonymes}
     kAdresseBordOuest=1;     {bords}
     kAdresseBordEst=8;  
     kAdresseBordNord=9;    
     kAdresseBordSud=16;
     kAdressePrebordOuest=2;  {prebords}
     kAdressePrebordEst=7;
     kAdressePrebordNord=10;
     kAdressePrebordSud=15;
  {le nombre de patterns dans l'eval : penser a changer cela si on en rajoute !!}
     kNbPatternsDansEval=34;

  
const TroisPuiss8=6561;
      TroisPuiss10=59049;
      TroisPuiss13=1594323;     
     

type
     
     plBool          = {Packed} Array[0..99] of boolean;
     plOthSignedByte = Packed Array[0..99] of SignedByte;
     plOtInteger     = Array[0..99] of SInt16;
     plOthLongint    = Array[0..99] of SInt32;
     
     plateauOthello        = plOthSignedByte;
     platValeur   = plOtInteger;
     plOthEndgame = plateauOthello;
     
     
     plateauRect=Rect;
     
     MoveRecord = 
          record
            x : SInt32;
            theDefense : SInt32;
            note : SInt32;
            pourcentageCertitude : SInt32;
            temps : SInt32;
            nbfeuilles : SInt32;
            notePourLeTri : SInt32;
            noteMilieuDePartie : SInt32;
            delta : SInt32;   {attention : ne jamais acceder a ce champ en lecture, sauf dans EcritReflexion !!}
          end;
     ListOfMoveRecords = array[1..64] of MoveRecord;
     
     MinSec = record
              minimum : SInt32;
              sec : SInt32;
              tick : SInt32;
            end;
     t_Octet=0..255;
     DeuxOctets = packed array[0..1] of t_Octet;
     
     
     PropertyPtr = ^Property;
     Property = record
                  taille   : size;      { attention : ne pas modifier l'ordre et la }
                  info     : Ptr;       { taille des quatre premiers champs  !!     }
                  genre    : SInt16;   { c'est-ˆ-dire jusque et y compris ce champ-ci}
                  stockage : SInt16;   { et ce champ-lˆ... }
                end;
     
     PropertyList = ^PropertyListRec;
     PropertyListRec = record
                         head : Property;
                         tail : PropertyList;
                       end;
     
     GameTreeList = ^GameTreeListRec;
     GameTreeListRec = record
                         head : GameTree;
                         tail : GameTreeList;
                       end;
     
     GameTree = ^GameTreeRec;
     GameTreeRec = record
                     properties : PropertyList;
                     father : GameTree;
                     sons : GameTreeList;
                     transpositionOrbite : GameTree; {liste circulaire pour l'orbite des memes positions}
                     nodeMagicCookie : SInt32;
                   end;
     
     
     t_partie = array[0..65] of record
                    theSquare : SInt32;
                    nbRetourne : SInt32;
                    retournes : packed array[1..20] of byte;
                    trait : SInt32;
                    tempsUtilise:record
                                   tempsNoir,tempsBlanc : SInt32;
                                 end;
                    nombrePartiesActives : SInt32;
                    coupParfait : SInt32;   {t_partie[0].coupParfait comprendra le n¡ du premier coup parfait}
                    optimal : boolean;
                end;
     partiePtr= ^t_partie;
     partieHdl= ^partiePtr;
     
     listeVides = array[0..64] of SInt32;
     
     listeVidesAvecValeur = array[0..64] of 
		                      record
		                        coup : SInt32;
		                        theVal : SInt32;
		                      end;
		                                              
		 
		 ListeDeCases = record
                      cardinal : SInt32;
                      liste : array[0..64] of SInt32;
                    end;
     
     t_partieDansThorDBA = record
                           numeroTournoi : SInt16; 
                           ScoreEtTheorik : deuxOctets;
                           numeroNoir,numeroBlanc : SInt16; 
                           coups : packed array[1..60] of t_octet;
                         end;
     PartieDansThorDBAPtr= ^t_partieDansThorDBA;
     
     
     InfoFrontRec = record
		                nbfront,nbadjacent : array[pionNoir..pionBlanc] of SInt16;
		                nbvide : plateauOthello;
		                occupationTactique : SInt16; 
		                AdressePattern : array[0..kNbPatternsDansEval] of SInt32;  
		            end;
     
     InfosMilieuRec = record
	                    frontiere : InfoFrontRec;
	                    jouable : plBool;
	                    nbBlancs,nbNoirs : SInt32;
	                  end;

                 
     tabl_heuristique = packed array[11..88,0..61] of SignedByte;
     {listePions = record
                  coup : SignedByte;
                  nbPrise,nbVarJouable : SignedByte;
                  deltaplat : array[1..18] of SignedByte;
                  deltaJouable : array[1..8] of SignedByte;
                end;}
     meilleureSuiteInfosRec=
                       record
                         ligne : array[profondeurMax..kNbMaxNiveaux] of SignedByte;
                         score:record
                                 noir,blanc : SInt16; 
                               end;
                         statut,couleur : SInt16; 
                         numeroCoup : SInt16; 
                       end;
     {on veut des tables de bords de 6560=3^8 elements
      pour cela on code les bords de -3280 ˆ 3280, mais
      on depasse un peu sur les bornes ci-dessous pour 
      pouvoir utiliser des sentinelles}
     t_table_Byte={packed} array[-3285..3285] of Byte;
     table_BytePtr= ^t_table_Byte;
     t_table_SignedByte={packed} array[-3285..3285] of SignedByte;
     table_SignedBytePtr= ^t_table_SignedByte;
     t_tableBords = array[-3285..3285] of SInt16;  
     tableBordsPtr= ^t_tableBords;
     
     
     

                   
     t_suiteJouee = array[profondeurMax..kNbMaxNiveaux] of SInt16;
     t_meilleureSuite = array[profondeurMax..kNbMaxNiveaux,profondeurMax..kNbMaxNiveaux] of SInt16;
     t_nbkiller = packed array[profondeurMax..kNbMaxNiveaux] of 0..nbCoupsMeurtriers;
     t_killer = packed array[profondeurMax..kNbMaxNiveaux,1..nbCoupsMeurtriers] of 0..99;   
      
     suiteJoueePtr= ^t_suiteJouee;
     meilleureSuitePtr= ^t_meilleureSuite;  
     nbKillerPtr= ^t_nbkiller;
     KillerPtr= ^t_killer; 
     str255Ptr= ^str255;
     str255Hdl= ^str255Ptr;
     ReflexRec = record
                 class : ListOfMoveRecords;
                 prof,compteur,longClass : SInt16; 
                 typeDonnees,NumeroduCoup,couleur : SInt16; 
                 IndexCoupEnCours : SInt32;
                 nbLignesScoresCompletsCetteProf : SInt16; 
                 nbLignesScoresCompletsProfPrecedente : SInt16; 
                 coupAnalyseRetrograde : SInt32;
                 scoreAnalyseRetrograde : SInt32;
               end;      
     ReflexRecPtr= ^ReflexRec;
     t_IndexInfoDejaCalculeesCoupNro = array[-1..64] of SInt32;
     IndexInfoDejaCalculeesCoupNroPtr= ^t_IndexInfoDejaCalculeesCoupNro;
     IndexInfoDejaCalculeesCoupNroHdl= ^IndexInfoDejaCalculeesCoupNroPtr;


     BibliothequeEnTasRec = packed array[0..tailleMaxTasBibl] of byte;
     BibliothequeEnTasPtr= ^BibliothequeEnTasRec;
     BibliothequeEnTasHdl= ^BibliothequeEnTasPtr;
     BibliothequeIndexRec = array[0..maxNbreLignesEnBibl] of SInt16;
     BibliothequeIndexPtr= ^BibliothequeIndexRec;
     BibliothequeIndexHdl= ^BibliothequeIndexPtr;
     BibliothequeNbReponseRec = packed array[1..maxNbreLignesEnBibl] of SignedByte;
     BibliothequeNbReponsePtr= ^BibliothequeNbReponseRec;
     BibliothequeNbReponseHdl= ^BibliothequeNbReponsePtr;
     BibliothequeReponsesRec = packed array[1..maxNbreLignesEnBibl,1..10] of
               record
                   borneSup,x : SignedByte;
                end;
     BibliothequeReponsesPtr= ^BibliothequeReponsesRec;
     BibliothequeReponsesHdl= ^BibliothequeReponsesPtr;
     tableauStr255 = array[1..5] of str255;
     tableauStr255Ptr= ^tableauStr255;
     tableauStr255Hdl= ^tableauStr255Ptr;
     CriteresRec = record
                   CriteresNoir : str255;
                   CriteresBlanc : str255;
                   CriteresTournoi : str255;
                   CriteresDistribution : str255;
                 end;
     CriteresPtr= ^CriteresRec;
     CriteresHdl= ^CriteresPtr;
     tableSolitairesString= record
                               nbCasesVidesMin : SInt16; 
                               nbCasesVidesMax : SInt16; 
                               chaines : array[1..SolitairesEnMemoire] of str255;
                            end;
     tableSolitairesPtr= ^tableSolitairesString;
     tableSolitairesHdl= ^tableSolitairesPtr;
     nomJoueurStr=str19;
     nomTournoiStr=str29;
     tableJoueursStr = array[-1..1] of nomJoueurStr;
     tableJoueursPtr= ^tableJoueursStr;
     tableJoueursHdl= ^tableJoueursPtr;
     tabletournoisStr = array[-1..1] of nomTournoiStr;
     tabletournoisPtr= ^tabletournoisStr;
     tabletournoisHdl= ^tabletournoisPtr;
    {tableNbrePartiesTournoiRec = array[0..400] of SInt32;
     tableNbrePartiesTournoiPtr= ^tableNbrePartiesTournoiRec;
     tableNbrePartiesTournoiHdl= ^tableNbrePartiesTournoiPtr;}
                      
    tableBaseBool           = {packed} array [0..100000] of boolean;
    t_tableBaseByte         = packed array[0..100000] of unsignedbyte; {1 octet}
    t_tablestockagePartie   = array[0..501]    of str60;
    t_tableReferencesPartie = array[0..100000] of SInt16;
    t_tableNumero           = array[0..100000] of SInt32;
    t_ScoreEtTheorique      = array[0..100000] of DeuxOctets;
    
    tablestockagePartiePtr= ^t_tablestockagePartie;
    tablestockagePartieHdl= ^tablestockagePartiePtr;
    tableReferencesPartiePtr= ^t_tableReferencesPartie; 
    tableReferencesPartieHdl= ^tableReferencesPartiePtr;   {joueurs et tournois}
    tableNumeroPtr= ^t_tableNumero; 
    tableNumeroHdl= ^tableNumeroPtr;                       {pointeurs sur d'autres parties}
    ScoreEtTheoriquePtr= ^t_ScoreEtTheorique;
    ScoreEtTheoriqueHdl= ^ScoreEtTheoriquePtr;             {score et theorique}
    tableBaseBytePtr= ^t_tableBaseByte;
    tableBaseByteHdl= ^tableBaseBytePtr;
    tableBaseBoolPtr= ^tableBaseBool;
    tableBaseBoolHdl= ^tableBaseBoolPtr;

    t_TableInfoDejaCalculee = array[0..23000] of SInt32;
    TableInfoDejaCalculeePtr= ^t_TableInfoDejaCalculee;
    TableInfoDejaCalculeeHdl= ^TableInfoDejaCalculeePtr;

    t_statistique = record
                     nbTotalParties,nbreponsesTrouvees : SInt32;
                     gainNoirTotalReel,gainNoirTotalTheorique : extended;
                     scoreNoirtotal,tempsdeCalcul : SInt32;
                     flags : SInt32;
                     table : array[0..nbMaxStatistiques] of record
                                                   coup : byte;
                                                   nbpartiessurcecoup : SInt32;
                                                   joueurmajoritaire : SInt32;
                                                   gainNoirReel,gainNoirTheorique : SInt32;
                                                     {2 pour une victoire
                                                      1 pour une nulle
                                                      0 pour une defaite}
                                                 end;
                  end;
    statistiquePtr= ^t_statistique;
    statistiqueHdl= ^statistiquePtr;
    t_interversion  = array[1..nbMaxInterversions] of str60;                
    interversionPtr = ^t_interversion;
    interversionHdl = ^interversionPtr;
     
    TableParties60Rec = 
        record
          cardinal : SInt32;
          table : array[1..100] of PackedThorGame;
          ref : array[1..100] of SInt32;
        end;
    TableParties60Ptr = ^TableParties60Rec;


    t_TournoiCompatibleArray        = array[0..nbMaxTournoisEnMemoire] of boolean;
    t_JoueurCompatibleArray         = array[0..nbMaxJoueursEnMemoire] of boolean;
    t_ScoreCompatibleArray          = array[0..255] of boolean;
    t_DistributionCompatibleArray   = array[0..255] of boolean;
    
    t_TournoiCompatible      = ^t_TournoiCompatibleArray;
    t_JoueurCompatible       = ^t_JoueurCompatibleArray;
    t_ScoreCompatible        = ^t_ScoreCompatibleArray;
    t_DistributionCompatible = ^t_DistributionCompatibleArray;
    
    ParamDiagRec = record
                     DecalageHorFFORUM,DecalageVertFFORUM : SInt16; 
                     tailleCaseFFORUM : SInt32;   
                     epaisseurCadreFFORUM : extended;
                     distanceCadreFFORUM : SInt32;
                     nbPixelDedansFFORUM : SInt32;
                     CoordonneesFFORUM : boolean;
                     PionsEnDedansFFORUM : boolean;
                     DessineCoinsDuCarreFFORUM : boolean;
                     DessinePierresDeltaFFORUM : boolean;
                     TraitsFinsFFORUM : boolean;
                     EcritApres37c7FFORUM : boolean;
                     EcritNomsJoueursFFORUM : boolean;
                     EcritNomTournoiFFORUM : boolean;
                     PoliceFFORUMID : SInt16; 
                     NumerosSeulementFFORUM : boolean;
                     CommentPositionFFORUM:str120Hdl;
                     TitreFFORUM:str120Hdl;
                     TypeDiagrammeFFORUM : byte;
                     GainTheoriqueFFORUM:str7;
                     FondOthellierPatternFFORUM : SInt16; 
                     CouleurOthellierFFORUM : SInt16; 
                   end;
                    
   

                    
   ListePartiesRec = record
                       ascenseurListe: ControlHandle;       {ascenseur}
                       
                       longintValue : SInt32;
                       longintMaximum : SInt32;
                       longintMinimum : SInt32;
                       
                       nbreLignesFntreListe : SInt32;        {nb de parties visibles dans la fenetre}
                       positionPouceAscenseurListe : SInt32; {position du pouce}
                       partieHilitee : SInt32;               {numero de la parties selectionnee}
                       dernierNroReferenceHilitee : SInt32;  {numero de reference correspondant}
                       clicHilite : SInt32;                  {date du dernier click dans la liste}
                       justificationPasDePartie : SInt32;    {dernier texte 'Pas de partie' affiche}
                       inclureOrdinateurRect : rect;
                     end;
   
   InfosFermetureFenetreListeRec = 
                     record
							         longintValue : SInt32;                {valeurs de l'ascenseur}
							         longintMaximum : SInt32;
							         longintMinimum : SInt32;
							                       
							         nbreLignesFntreListe : SInt32;        {nb de parties visibles dans la fenetre}
							         positionPouceAscenseurListe : SInt32; {position du pouce}
							         partieHilitee : SInt32;               {numero de la parties selectionnee}
							         dernierNroReferenceHilitee : SInt32;  {numero de reference correspondant}
                       justificationPasDePartie : SInt32;    {dernier texte 'Pas de partie' affiche}
                       nombrePartiesActives  : SInt32;
                       nombrePartiesChargees : SInt32;
							       end;         
   
   IconisationDeCassioRec = record
                           enCours : boolean;
                           possible : boolean;
                           theWindow : WindowPtr;
                           IconisationRect : rect;
                           LargeurFenetreIconisation : SInt16; 
                           OthellierPicture:PicHandle;
                           ParametresIconeOthellier:ParamDiagRec;
                           PositionEtCoupIconeStr:str185;
                         end;
   
   MessageFinaleHdl= ^MessageFinalePtr;
   MessageFinalePtr= ^MessageFinaleRec;
   MessageFinaleRec = record
                      typeData : SInt16; 
                      longueurData : SInt16; 
                      data : array[0..0] of SInt16;
                    end;


const nbMaxDePassesAnalyseRetrograde = 3;
      nbMaxDeStagesAnalyseRetrograde = 3;
type 
  typeMenuDialogueRetrograde = (kMenuGenre,kMenuProf,kMenuDuree,kMenuNotes);
  t_AnalyseRetrogradeInfos = 
      record
        nbMinPourConfirmationArret : SInt32;
        tickDebutAnalyse : SInt32;
        tickDebutCettePasseAnalyse : SInt32;
        tickDebutCeStageAnalyse : SInt32;
        tempsDernierCoupAnalyse : SInt32;
        genreAnalyseEnCours : SInt32;
        genreDerniereAmeliorationCherchee : SInt32;
        numeroPasse : SInt32;
        numeroStage : SInt32;
        tempsMaximumCettePasse : SInt32;
        tempsMaximumCeStage : SInt32;
        enCours : boolean;
        dejaAnnoncee : boolean;
        doitConfirmerArret : boolean;
        peutDemanderConfirmerArret : boolean;
        nbPresentationsDialogue : SInt16; 
        demande : array[0..64,1..nbMaxDePassesAnalyseRetrograde] of
                  record
                    genre : SInt32;        {ReflRetrogradeMilieu,ReflRetrogradeGagnant,ReflRetrogradeParfait}
                    tempsAlloueParCoup : SInt32;  {en secondes}
                    profondeur : SInt32;
                  end;
        menuItems : array[1..nbMaxDePassesAnalyseRetrograde,1..nbMaxDeStagesAnalyseRetrograde,typeMenuDialogueRetrograde] of SInt16;
      end;


const  nbOctetsOuvertures=7;
type  packed7 = packed array[1..nbOctetsOuvertures] of byte;

    
const PasDeCommentaire=0;
      tailleMaxCommentairesOuvertures=15000;
      
type tableCommentaireOuv = packed array[0..tailleMaxCommentairesOuvertures] of char;
     tableCommentaireOuvPtr= ^tableCommentaireOuv;
     tableCommentaireOuvHdl= ^tableCommentaireOuvPtr;
     tableIndexCommentaireOuv = array[0..maxNbreLignesEnBibl] of SInt16;
     tableIndexCommentaireOuvPtr= ^tableIndexCommentaireOuv;
     tableIndexCommentaireOuvHdl= ^tableIndexCommentaireOuvPtr;    
var indexCommentaireBibl:tableIndexCommentaireOuvHdl;
    commentaireBiblEnTas:tableCommentaireOuvHdl;
    avecNomOuvertures : boolean;

var  valFrontiere : SInt16; 
     valPriseCoin : SInt16; 
     valDefenseCoin : SInt16; 
     valCoin : SInt16; 
     valCaseX : SInt16; 
     valCaseXEntreCasesC : SInt16; 
     valCaseXPlusCoin : SInt16; 
     valCaseXDonnantBordDeSix : SInt16; 
     valCaseXDonnantBordDeCinq : SInt16; 
     valCaseXConsolidantBordDeSix : SInt16; 
     valTrouCaseC : SInt16; 
     valLiberteSurCaseB : SInt16; 
     valLiberteSurCaseA : SInt16; 
     valLiberteSurCaseAApresMarconisation : SInt16; 
     valBonBordDeCinq : SInt16; 
     valTrouDeTroisHorrible : SInt16; 
     valTrouDeDeuxPerdantLaParite : SInt16; 
     valArnaqueSurBordDeCinq : SInt16; 
     valPairePionBordOpposes : SInt16; 
     valBordDeSixPlusQuatre : SInt16; 
     valPionsIsoleSurCaseThill : SInt16; 
     valCasesCoinsCarreCentral : SInt16; 
     valBordDeCinqTransformable : SInt16; 
     valBetonnage : SInt16; 
     valMinimisationAvantCoins : SInt16; 
     valMinimisationApresCoins : SInt16; 
     valPionCentre : SInt16; 
     valPionPetitCentre : SInt16; 
     valEquivalentFrontiere : SInt16; 
     valMobiliteUnidirectionnelle : SInt16; 
     valRendementDeLaFrontiere : SInt16; 
     valGrosseMasse : SInt16; 
     seuilMobilitePourGrosseMasse : SInt16; 
     penalitePourLeTrait : SInt32;
     penalitePourTraitAff : SInt32;
     
type EvaluationCassioRec = record
                             notePenalite : SInt16; 
                             noteBord : SInt16; 
                             noteCoin : SInt16; 
                             notePriseCoin : SInt16; 
                             noteDefenseCoin : SInt16; 
                             noteMinimisationAvant : SInt16; 
                             noteMinimisationApres : SInt16; 
                             noteCentre : SInt16; 
                             noteGrandCentre : SInt16; 
                             noteFrontiere : SInt16; 
                             noteEquivalentFrontiere : SInt16; 
                             noteMobilite : SInt16; 
                             noteCaseX : SInt16; 
                             noteCaseXPlusCoin : SInt16; 
                             noteCaseXEntreCasesC : SInt16; 
                             noteTrouCaseC : SInt16; 
                             noteOccupationTactique : SInt16; 
                             noteWipeOut : SInt16; 
                             noteAleatoire : SInt16; 
                             noteTrousDeTroisHorrible : SInt16; 
                             noteLiberteSurCaseA : SInt16; 
                             noteLiberteSurCaseB : SInt16; 
                             noteBonsBordsDeCinq : SInt16; 
                             noteTrousDeDeuxPerdantLaParite : SInt16; 
                             noteArnaqueSurBordDeCinq : SInt16; 
                             noteValeurBlocsDeCoin : SInt16; 
                             noteBordsOpposes : SInt16; 
                             noteBordDeCinqTransformable : SInt16; 
                             noteGameOver : SInt16; 
                             noteBordDeSixPlusQuatre : SInt16; 
                             noteGrosseMasse : SInt16; 
                             noteCaseXConsolidantBordDeSix : SInt16; 
                           end;
{attention : changer kLongueurEvaluationCassioRec quand on rajoute des champs a EvaluationCassioRec} 
     
const kNotePenalite                  = 1;
      kNoteBord                      = 2;
      kNoteCoin                      = 3;
      kNotePriseCoin                 = 4;
      kNoteDefenseCoin               = 5;
      kNoteMinimisationAvant         = 6;
      kNoteMinimisationApres         = 7;
      kNoteCentre                    = 8;
      kNoteGrandCentre               = 9;
      kNoteFrontiere                 = 10;
      kNoteEquivalentFrontiere       = 11;
      kNoteMobilite                  = 12;
      kNoteCaseX                     = 13;
      kNoteCaseXPlusCoin             = 14;
      kNoteCaseXEntreCasesC          = 15;
      kNoteTrouCaseC                 = 16;
      kNoteOccupationTactique        = 17;
      kNoteWipeOut                   = 18;
      kNoteAleatoire                 = 19;
      kNoteTrousDeTroisHorrible      = 20;
      kNoteLiberteSurCaseA           = 21;
      kNoteLiberteSurCaseB           = 22;
      kNoteBonsBordsDeCinq           = 23;
      kNoteTrousDeDeuxPerdantLaParite= 24;
      kNoteArnaqueSurBordDeCinq      = 25;
      kNoteValeurBlocsDeCoin         = 26;
      kNoteBordsOpposes              = 27;
      kNoteBordDeCinqTransformable   = 28;
      kNoteGameOver                  = 29;
      kNoteBordDeSixPlusQuatre       = 30;
      kNoteGrosseMasse               = 31;
      kNoteCaseXConsolidantBordDeSix = 32;
      kLongueurEvaluationCassioRec   = 32;  {attention : changer cela quand on rajoute 
                                                         des champs a EvaluationCassioRec}
                                                         


     

const kNbMaxGameStage=5;   {gameStage de 0 ˆ 5  coups 0..9 => 0  , coups 10.19 => 1 , etc}
      kNbMaxPatternsParCase=6; 
      kTailleMaximumPattern=20; 
      kDecalagePourEdge2X=29525;  { = 1 + (puiss3[11] div 2)  }
                                    
     
var nbPatternsImpliques : array[0..99] of SInt16;
    nroPattern : array[0..99,1..kNbMaxPatternsParCase] of SInt32;
    deltaAdresse,doubleDeltaAdresse : array[0..99,1..kNbMaxPatternsParCase] of SInt32;
    descriptionParCases : array[0..kNbPatternsDansEval,-1..kTailleMaximumPattern+3] of SInt32;
    taillePattern : array[0..kNbPatternsDansEval] of SInt32;
    decalagePourPattern : array[0..kNbPatternsDansEval] of SInt32;
    gameStage : array[-5..64] of SInt32;  {gameStage[n] ou n est le numero du coup}
    puiss3,doublePuiss3 : array[0..kTailleMaximumPattern+1] of SInt32;
    puiss3Coul,doublePuiss3Coul : array[0..kTailleMaximumPattern+1,pionNoir..pionBlanc] of SInt32;
    gameOver : boolean;    
    HumCtreHum : boolean;
    afficheNumeroCoup : boolean;
    affichageReflexion:
      record
        doitAfficher : boolean;
        demandeEnSuspend : boolean;
        tickDernierAffichageReflexion : SInt32;
        afficherToutesLesPasses : boolean;
      end;
    afficheMeilleureSuite : boolean;
    afficheprocedures : boolean;
    debuggage : record
                  general : boolean;
                  entreesSortiesUnitFichiersTEXT : boolean;
                  pendantLectureBase : boolean;
                  afficheSuiteInitialisations : boolean;
                  evenementsDansRapport : boolean;
                  elementsStrategiques : boolean;
                  gestionDuTemps : boolean;
                  calculFinaleOptimaleParOptimalite : boolean;
                  arbreDeJeu : boolean;
                  lectureSmartGameBoard : boolean;
                  apprentissage : boolean;
                  algoDeFinale : boolean;
                  MacOSX : boolean;
                end;
    afficheSuggestionDeCassio : boolean;
    affichePierresDelta : boolean;
    afficheProchainsCoups : boolean;
    afficheSignesDiacritiques : boolean;
    afficheGestionTemps : boolean;
    avecAleatoire : boolean;
    avecCoinsDabord : boolean;
    sansReflexionSurTempsAdverse : boolean;
    avecKiller : boolean;
    avecProgrammation : boolean;
    avecEvaluationTotale : boolean;
    nbCoupsEnTete : SInt16; 
    enSetUp : boolean;
    enRetour : boolean;
    analyseRetrograde:t_AnalyseRetrogradeInfos;
    jeuInstantane : boolean;
    profimposee : boolean;
    valeurApprondissementIteratif : SInt16; 
    aideDebutant : boolean;
    othellierEstSale : plBool;
    CassioUtiliseDesMajuscules : boolean;
    differencierLesFreres : boolean;
    demo : boolean;
    avecTests : boolean;
    effetspecial : boolean;
    effetspecial2 : boolean;
    effetspecial3 : boolean;
    effetspecial4 : boolean;
    effetspecial5 : boolean;
    effetspecial6 : boolean;
    nroEffetspecial : SInt32;
    humainVeutAnnuler : boolean;
    
    annulerRetourRect : rect;
    aireDeJeu:plateauRect;
    inverseVideo : plBool;
    
    RefleSurTempsJoueur : boolean;
    interruptionReflexion : SInt16; 
    vaDepasserTemps : boolean;
    reponsePrete : boolean;
    meilleureReponsePrete : SInt32;
    MeilleurCoupHumPret : SInt32;
    meilleurCoupHum : SInt32;
    PartieContreMacDeBoutEnBout : boolean;
    WaitNextEventImplemented : boolean;
    GestaltImplemented : boolean;
    gIsRunningUnderMacOSX : boolean;
    gCassioChecksEvents : boolean;
    doitEffacerSousLesTextesSurOthellier : boolean;
    profOuBiboardEstMieuxPourCeNbreVides : array[-10..74] of SInt32;
    
    gAppleEventsInitialized : boolean;
    avecNomsAbreges : boolean;
    largFenetreProbCut : SInt16; 
    largGrandeFenetreProbCut : SInt16; 
    largHyperGrandeFenetreProbCut : SInt16; 
    
    table_FenetreProbCut : array[-4..69] of SInt32;
    table_GrandeFenetreProbCut : array[-4..69] of SInt32;
    table_HyperGrandeFenetreProbCut : array[-4..69] of SInt32;
    
    gPourcentageTailleDesPions : SInt32;
    avecLisereNoirSurPionsBlancs : boolean;
    avecOmbrageDesPions : boolean;
    avecSystemeCoordonnees : boolean;
    garderPartieNoireADroiteOthellier : boolean;
    
    tailleFenetrePlateauAvantPassageEn3D : SInt32;
    tailleCaseAvantPassageEn3D : SInt16; 
    PionInversePat : pattern;
    InversePionInversePat : pattern;
    darkGrayPattern : pattern;
    lightGrayPattern : pattern;
    grayPattern : pattern;
    blackPattern : pattern;
    whitePattern : pattern;
    PostscriptCompatibleXPress : boolean;
    utilisationNouvelleEval : boolean;
    versionEvaluationDeCassio : SignedByte;  {attention : augmenter cela quand on recalcule une nouvelle evaluation ! }
    
    
    avecAjustementAutomatiqueDuNiveau : boolean;
    humanWinningStreak : SInt32;
    humanScoreLastLevel : SInt32;
    couleurMacintosh : SInt16; 
    aQuiDeJouer : SInt16; 
    level : SInt16; 
    finDePartie : SInt16;           {depart de la recherche systematique}
    finDePartieOptimale : SInt16;   {depart de la recherche de la meilleure fin}
    
    positionFeerique : boolean;
    nbreCoup : SInt16; 
    nbreCoupsApresLecture : SInt16; 
    nroDernierCoupAtteint : SInt16; 
    partie:partieHdl;
    
    phaseDeLaPartie : SInt16; 
    
    
    nbreDePions : array[pionNoir..pionBlanc] of SInt32;
    
    jeuCourant : plateauOthello;
    frontiereCourante : InfoFrontRec;
    possibleMove : plBool;
    emplJouable : plBool;
    interdit : plBool;
    estUnCoin : plBool;
    estUneCaseC : plBool;
    estUneCaseDeBord : plBool;
    estCaseBordNord,estCaseBordSud,estCaseBordOuest,estCaseBordEst : plBool;
    
const kTaille_Max_Index_Bords_AB_Local = 2000;

var
    valeurTactAbsolue,valeurTactNoir,valeurTactBlanc : platValeur;
    table_Turbulence_mono:table_SignedBytePtr;
    table_Turbulence_bi:table_SignedBytePtr;
    table_Turbulence_alpha_beta_local:tableBordsPtr;
    table_index_bords_AB_local : array[-1..kTaille_Max_Index_Bords_AB_Local] of SInt16;
    valeurBord:tableBordsPtr;
    dir : array[1..8] of SInt16;
    dirJouable : array[1..8] of SInt16;
    dirJouableDeb,dirJouableFin : plateauOthello;
    dirPrise : array[1..16] of SInt16;
    dirPriseDeb,dirPriseFin : plateauOthello;
    dirVoisine : array[1..16] of SInt16;
    dirVoisineDeb,dirVoisineFin : plateauOthello;
    { fixed square ordering : jcw 's order, which is the best of 4 tried: }
    worst2bestOrder: ARRAY[0..64] OF SInt16;
                      
    caseBord : array[1..4] of SInt16;
    {caseBordNord[i] decrit les coordonnees de la ieme case du bord nord}
    {caseBordNord[-1]=0,caseBordNord[0]=0,caseBordNord[1]=11,caseBordNord[2]=12...}
    {...caseBordNord[8]=18,caseBordNord[9]=0,caseBordNord[10]=0}
    caseBordNord,caseBordOuest,caseBordEst,caseBordSud : array[-1..10] of SInt16;              
    othellier : array[0..64] of SInt32;
    caseCentre : array[1..4] of SInt16;
    casepetitCentre : array[1..8] of SInt16;   
    caseCentre1,caseCentre2,caseCentre3,caseCentre4 : SInt16;   
    casepetitCentre1,casepetitCentre2,casepetitCentre3,casepetitCentre4 : SInt16; 
    casepetitCentre5,casepetitCentre6,casepetitCentre7,casepetitCentre8 : SInt16; 
    constanteDeParite : array[0..99] of SInt32;
    masque_voisinage : array[0..99] of record 
                                        low  : UInt32;
                                        high : UInt32;
                                      end;
    numeroQuadrant : array[0..99] of SInt32;
    gVecteurParite : SInt32;       
    
    

    
   
    dernierTick : SInt32;
    dernierTickPourCheckEventDansCalculsBase : SInt32;
    delaiAvantDoSystemTask : SInt32;
    latenceEntreDeuxDoSystemTask : SInt32;
    tempsReflexionMac : SInt32;
    tempsReflexionCetteProf : SInt32;
    tempsAlloue : SInt32;
    tempsPrevu : SInt32;
    tempsDesJoueurs : array[pionNoir..pionBlanc] of MinSec;
    cadencePersoAffichee : SInt32;
    cadenceHeure,cadenceMin,cadenceSec : SInt32;
    decrementetemps : boolean;
    
    compteurNoeuds : SInt32;
    NbNoeudsInter : SInt32;
    tickNoeuds : SInt32;
    
    Yannonc : SInt32;
    
    watch,iBeam:CursHandle;
    interversionCurseur:CursHandle;
    parcheminCurseur:CursHandle;
    teteDeMortCurseur:CursHandle;
    pionNoirCurseur,pionBlancCurseur:CursHandle;
    gommeCurseur:CursHandle;
    backMoveCurseur:CursHandle;
    avanceMoveCurseur:CursHandle;
    DragLineVerticalCurseur:CursHandle;
    DragLineHorizontalCurseur:CursHandle;
    doitAjusterCurseur : boolean;
    
    meilleureSuiteInfos:meilleureSuiteInfosRec;
    tableHeurisNoir,tableHeurisBlanc:tabl_heuristique;
    
    avecSon : boolean;
    avecSonPourPosePion : boolean;
    avecSonPourRetournePion : boolean;
    avecSonPourGameOver: boolean;
    sonPourPosePion : SInt16; 
    sonPourRetournePion : SInt16; 
    evaluationAleatoire : boolean;
    avecEvaluationDeFisher : boolean;
    avecRefutationsDansRapport : boolean;
    profMinimalePourTriDesCoups : SInt16; 
    profMinimalePourTriDesCoupsParAlphaBeta : SInt16; 
    profMinimalePourClassementParMilieu : SInt32;


const kAffichageAere = 1;
      kAffichageUnPeuSerre = 2;
      kAffichageTresSerre = 3;
      kAffichageSousOthellier = 4;


var genreAffichageTextesDansFenetrePlateau : SInt32;
    
    EcranDe512 : boolean;


    wPlateauPtr : WindowPtr;
    windowPlateauOpen : boolean;
    
    wCourbePtr : WindowPtr;
    windowCourbeOpen : boolean;
    
    wAidePtr : WindowPtr;
    windowAideOpen : boolean;
    
    wGestionPtr : WindowPtr;
    windowGestionOpen : boolean;
    
    wReflexPtr : WindowPtr;
    windowReflexOpen : boolean;
    
    wListePtr : WindowPtr;
    windowListeOpen : boolean;
    
    wStatPtr : WindowPtr;
    windowStatOpen : boolean;
    
    wPalettePtr : WindowPtr;
    windowPaletteOpen : boolean;

    windowRapportOpen : boolean;
    
    arbreDeJeu :
      record
        theDialog                  : DialogPtr;
        windowOpen                 : boolean;
        enModeEdition              : boolean;
        doitResterEnModeEdition    : boolean;
        EditionRect                : rect;
        backMoveRect               : rect;
        positionLigneSeparation    : SInt16; 
        hauteurRuban               : SInt16; 
      end;
    
    iconisationDeCassio:IconisationDeCassioRec;
    
    infosListeParties : ListePartiesRec;
    infosListePartiesDerniereFermeture : InfosFermetureFenetreListeRec;
    
    gestionRec:record
                 alloue : SInt32;
                 prevu : SInt32;
                 effectif : SInt32;
                 divergence : extended;
                 prof,profSuivante : SInt16; 
               end;
    
   EnTraitementDeTexte : boolean;
   ReflexData:ReflexRecPtr;       
   suiteJoueeGlb:suiteJoueePtr;
   meilleureSuiteGlb:meilleureSuitePtr;  
   nbKillerGlb:nbKillerPtr;
   KillerGlb:KillerPtr;
   tableLignes : TableParties60Ptr;
   
   posHNoirs,posVNoirs,posHBlancs,posVBlancs,posHDemande,PosVDemande : SInt16; 
   posHMeilleureSuite,posVMeilleureSuite : SInt16; 
   titrePartie:str255Hdl;
   meilleureSuiteStr:str255Hdl;
   MeilleureSuiteEffacee : boolean;
   CommentaireSolitaire:str255Hdl;
   CaracterePourNoir:str7;
   CaracterePourBlanc:str7;
   CaracterePourEgalite:str7;
   
var bibliothequeEnTas:bibliothequeEnTasHdl;
    bibliothequeIndex:bibliothequeIndexHdl;
    BibliothequeNbReponse:BibliothequeNbReponseHdl;
    bibliothequeReponses:BibliothequeReponsesHdl;
    nbreLignesEnBibl : SInt32;
    bibliothequeLisible : boolean;
    avecBibl : boolean;
    JoueBonsCoupsBibl : boolean;
    interversionFautive : interversionHdl;
    interversionCanonique : interversionHdl;
    numeroInterversion : array[0..33] of SInt32;    
       {numeroInterversion[i] est le numero de la derniere 
        interversion concernant une chaine de longueur i}    
    interversionsCompatibles : array[1..nbMaxInterversions] of SInt32;
    NbinterversionsCompatibles : SInt32;
    avecInterversions : boolean;
    genreDeTestPourAnnee : SInt16; 

var EditionMenu : MenuRef;
    PartieMenu : MenuRef;
    ModeMenu : MenuRef;
    JoueursMenu : MenuRef;
    AffichageMenu : MenuRef;
    SolitairesMenu : MenuRef;
    BaseMenu : MenuRef;
    ProgrammationMenu : MenuRef;
    CouleurMenu : MenuRef;
    TriMenu : MenuRef;
    FormatBaseMenu : MenuRef;
    Picture2DMenu : MenuRef;
    Picture3DMenu : MenuRef;
    CopierSpecialMenu : MenuRef;
    GestionBaseWThorMenu : MenuRef;
    NMeilleursCoupsMenu : MenuRef;
    OuvertureMenu : MenuRef;
    ReouvrirMenu : MenuRef;


var fond : pattern;    
    Quitter : boolean;
    avecAB_Constr : boolean;
    FntrPlatRect : rect;
    FntrCourbeRect : rect;
    FntrAideRect : rect;
    FntrGestionRect : rect;
    FntrReflexRect : rect;
    FntrListeRect : rect;
    FntrStatRect : rect;
    FntrPaletteRect : rect;
    FntrRapportRect : rect;  
    FntrCommentairesRect : rect;
    FntrFelicitationTopLeft : Point;
    CloseZoomRectFrom,CloseZoomRectTo : rect;
    Ecranrect : rect;
    enFenetreMinimale : boolean;
    AuMoinsUneFelicitation : boolean;
    gPendantLesInitialisationsDeCassio : boolean;
    listeEtroiteEtNomsCourts : boolean;
    
    nbreDebugage : SInt32;
    calculPrepHeurisFait : boolean;
    nbreToursFeuillesMilieu : SInt32;
    nbreFeuillesMilieu : SInt32;
    SommeNbEvaluationsRecursives : SInt32;
    nbreToursNoeudsGeneresMilieu : SInt32;
    nbreNoeudsGeneresMilieu : SInt32;
    nbreToursNoeudsGeneresFinale : SInt32;
    nbreNoeudsGeneresFinale : SInt32;
    lastNbreNoeudsGeneres : SInt32;
    NbreDeNoeudsMoyensFinale :
      record
        nbreNoeudsCetteSeconde : array[0..9] of SInt32;
        nbreTicksCetteSeconde : array[0..9] of SInt32;
        lastNbreNoeudsFinale : SInt32;
        lastNbreTicksFinale : SInt32;
        index : SInt16; 
      end;
    DebutComptageFeuilles : SInt32;
   (* avecDessinCoupEnTete : boolean; *)
    NePasUtiliserLeGrasFenetreOthellier : boolean;
 (*   coupEnTete : SInt16; *)
    afficheBibl : boolean;
    estUneCaseA : plBool;
    
    
    ParamDiagPositionFFORUM:ParamDiagRec;
    ParamDiagPartieFFORUM:ParamDiagRec;
    ParamDiagCourant:ParamDiagRec;
    numeroPuce : SInt16; 
    
    TableSolitaire:tableSolitairesHdl;
    indexSolitaire : SInt16; 
    SolitairesDemandes : array[1..64] of boolean;
    eviterSolitairesOrdinateursSVP : boolean;
    ParametresOuvrirThor:tableauStr255Hdl;
    ParametreGenreTestThor : SInt16; 
    DerniereActionBaseEffectuee : SInt16; 
    
    volumeRefCassio : SInt16; 
    pathCassioFolder : str255;
    pathDossierFichiersAuxiliaires : str255;
    volumeRefDossierDatabase : SInt16; 
    CheminAccesThorDBA:str255Hdl;
    VolumeRefThorDBA : SInt16; 
    ThorDbaOuvrableSolitaire : boolean;
    CheminAccesThorDBASolitaire:str255Hdl;
    VolumeRefThorDBASolitaire : SInt16; 
    CheminAccesSolitaireCassio:str255Hdl;
    nomDuFichierAReouvrir : array[1..NbMaxItemsReouvrirMenu] of str255Hdl;
    nomLongDuFichierAReouvrir : array[1..NbMaxItemsReouvrirMenu] of str255Hdl;
    VolRefPourReouvrir : SInt16; 

    SolitairesRefVol : SInt16; 
    dernierePartieExtraiteThor : SInt32;
    dernierePartieExtraiteWThor:record
                                 numFichier : SInt16; 
                                 numPartie : SInt32;
                               end;
    SensLargeSolitaire : boolean;
    finaleEnModeSolitaire : boolean;
    ecrireDansRapportLog : boolean;
    
    CoeffInfluence : extended;
    Coefffrontiere : extended;
    CoeffEquivalence : extended;
    Coeffcentre : extended;
    Coeffgrandcentre : extended;
    Coeffbetonnage : extended;
    Coeffminimisation : extended;
    CoeffpriseCoin : extended;
    CoeffdefenseCoin : extended;
    CoeffValeurCoin : extended;
    CoeffValeurCaseX : extended;
    CoeffPenalite : extended;    
    CoeffMobiliteUnidirectionnelle : extended;
    EchelleCoeffsRect : rect;
    
    CoeffPenalitePourNouvelleEval : extended;
    CoeffFrontierePourNouvelleEval : extended;
    CoeffMinimisationPourNouvelleEval : extended;
    CoeffMobiliteUnidirectionnellePourNouvelleEval : extended;
    
    withUserCoeffDansNouvelleEval : boolean;
    
    referencesCompletes : boolean;
    nbCasesVidesMinSolitaire : SInt16; 
    nbCasesVidesMaxSolitaire : SInt16; 
    peutfeliciter : boolean;
    OthelloTorique : boolean;
    PionClignotant : boolean;
    retirerEffet3DSubtilOthellier2D : boolean;
    avecTestBibliotheque : boolean;
    bidrect : rect;
    bidplat : plateauOthello;
    
    platMod10,platDiv10 : platValeur;
    puiss3Mod10,puiss3Div10,doublePuiss3Mod10,doublePuiss3Div10 : platValeur;
    JoueursEtTournoisEnMemoire : boolean;
    CriteresSuplementaires:CriteresHdl;
    statistiques:statistiqueHdl;
    derniereChaineComplementation:str255Hdl;
    TypeDerniereComplementation : SInt16; 
    numeroDerniereComplementationDansTable : SInt32;
    CriteresRubanModifies : boolean;
    InfosTechniquesDansRapport : boolean;
    nbAlertesPositionFeerique : SInt16; 
    tableAnneeParties:tableReferencesPartieHdl;
    tableTriListe:tableNumeroHdl;
    tableTriListeAux:tableNumeroHdl;
    tableNumeroReference:tableNumeroHdl;
    tableBooleensDeLaListe:tableBaseBytePtr;
    tableDistributionDeLaPartie:tableBaseBytePtr;

    gNbreMegaoctetsPourLaBase : SInt32;
    nbrePartiesEnMemoire : SInt32;
    nbPartiesActives,nbPartiesChargees : SInt32;
    problemeMemoireBase : boolean;
    avecGestionBase : boolean;
    IndexInfoDejaCalculeesCoupNro:IndexInfoDejaCalculeesCoupNroHdl;
    TableInfoDejaCalculee:TableInfoDejaCalculeeHdl;
    
    HauteurChaqueLigneDansListe : SInt16; 
    
    ChainePartieLecture:PackedThorGame;
    OthellierLectureRect : rect;
    PlatLecture : plateauOthello;
    positionLectureModifiee : boolean;
    LectureAntichronologique : boolean;
    sousSelectionActive : boolean;
    avecCalculPartiesActives : boolean;
    avecGagnantEnGrasDansListe : boolean;
    gDoitJouerMeilleureReponse : boolean;
    
    SupprimerLesEffetsDeZoom : boolean;
    OptimisePourKaleidoscope : boolean;
    gCassioUseQuartzAntialiasing : boolean;
    traductionMoisTournoi : SInt16; 
    
    gCassioSmallFontSize : SInt16; 
    gCassioNormalFontSize : SInt16; 
    gCassioBigFontSize : SInt16; 
    gCassioRapportBoldSize : SInt16; 
    gCassioRapportNormalSize : SInt16; 
    gCassioRapportSmallSize : SInt16; 
    
    gCassioApplicationFont : SInt16; 
    gCassioRapportNormalFont : SInt16; 
    gCassioRapportBoldFont : SInt16; 
    
    gPoliceNumeroCoup : record
                          petiteTaille : SInt16; 
                          grandeTaille : SInt16; 
                          policeID : SInt16; 
                          theStyle : Style;
                        end;

    themeCourantDeCassio : SInt32;
     
const kThemeBaskerville = 1;
      kThemeTimesNewRoman = 2;
      kThemeModerne = 3;
      kThemeGillSans = 4;
      kThemeMacOS9 = 5;
    
type PageImprRec = record
                   TitreImpression:str255Hdl;
                   FontSizeTitre : SInt16; 
                   MargeTitre : SInt16; 
                   NumeroterPagesImpr : boolean;
                   QuoiImprimer : SInt16; 
                 end;
     RectPtr= ^Rect;
   
type bytePtr= ^byte;
     LongintArrayPtr= ^LongintArray;
     LongintArray = array[0..0] of SInt32;

var bytearrow : bytePtr;

    
    ParamDiagImpr :ParamDiagRec;
    PageImpr:PageImprRec;
    DejaFormatImpression : boolean;
    CassioResFile : SInt16; 
    analyseIntegraleDeFinale : boolean;
    doitEcrireReflexFinale : boolean;
    profSupUn : boolean;
    NiveauJeuInstantane : SInt16; 
    finDePartieVitesseMac : SInt16; 
    finDePartieOptimaleVitesseMac : SInt16; 
    UneSeuleBase : boolean;
    marques : packed array[0..10] of byte;
    OrdreDuTriRenverse : boolean;
    avecSauvegardePref : boolean;
    avecSauvegardePrefArrivee : boolean;
    indiceVitesseMac : SInt32;
    nbreInterAlaVolee : SInt16; 
    gInterVarianteAlaVolee : SInt32;
    avecAlerteNouvInterversion : boolean;
    DoitEcrireInterversions : boolean;
    numeroCoupMaxPourRechercheIntervesionDansArbre : SInt32;
    
    ToujoursIndexerBase : boolean;
    inBackGround,fntrPlateauOuverteUneFois : boolean;
    PassesDejaExpliques : SInt16; 
    nbExplicationsPasses : SInt16; 
    avecSelectivite : boolean;
    avecEvaluationTablesDeCoins : boolean;
    SelectivitePourCetteRecherche : SInt16; 
    neJamaisTomber : boolean;
    doitConfirmerQuitter : boolean;
    menuouverturerect : rect;
    itemmenuouverture : SInt16; 
    DernierCoupPourMenuAff : SInt16; 
    SablierDessineEstRenverse : boolean;
    nbInformationMemoire : SInt32;
    instantDernierClic : SInt32;
    EmplacementDernierClic : Point;
    sousEmulatorSousPC : boolean;
    kWNESleep : SInt16; 
    gEnRechercheSolitaire : boolean;
    gEnEntreeSortieLongueSurLeDisque : boolean;

const
    kTailleHashTable    = 32767;  {doit etre une puissance de 2 -1}
    kEvaluationNonFaite = -31999;
    kDeltaFinaleInfini  = 100000;
    kTypeMilieuDePartie = -100000;
    
    kMaskLiberee = 1;
    kMaskRecalculerCoupsLegaux = 2;
    kMaskSuivants = 4;  { puis 8,16,32,etc.}
    
    kNbreMaxDeltasSuccessifsDansHashExacte = 10;
    
type 
    HashTableArray = packed array[0..kTailleHashTable] of byte;
    HashTablePtr= ^HashTableArray;
    HashTableHdl= ^HashTablePtr;
    IndiceHashArray = array[-1..1,11..88] of SInt32;
    IndiceHashPtr= ^IndiceHashArray;
    IndiceHashHdl= ^IndiceHashPtr;
    
	HashTableExacteElement = record
	                         ligne1,ligne2,ligne3,ligne4,ligne5,ligne6,ligne7,ligne8 : SInt16; 
	                         bornesMin : packed array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of signedByte;
	                         bornesMax : packed array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of signedByte;
	                         coupsDesBornesMin : packed array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of byte;
	                         traitEtBestDefense : packed array[0..1] of byte;
	                         profondeur : SInt16; 
	                         evaluationHeuristique : SInt16; 
	                         flags : SInt16; 
	                       end;
    HashTableExacteRec = array[0..1023] of HashTableExacteElement;
    HashTableExactePtr= ^HashTableExacteRec;
    CoupsLegauxHashArray = packed array[0..1023,0..nbMaxCoupsLegauxDansHash] of byte;
    CoupsLegauxHashPtr= ^CoupsLegauxHashArray;
    
const TournoiRubanBox=1;
      JoueurNoirRubanBox=2;
      JoueurBlancRubanBox=3;
      DistributionRubanBox=4;
      

var VisibiliteInitiale:record
                         tempowindowPaletteOpen : boolean;
                         tempowindowCourbeOpen : boolean;
                         tempowindowAideOpen : boolean;
                         tempowindowGestionOpen : boolean;
                         tempowindowReflexOpen : boolean;
                         tempowindowListeOpen : boolean;
                         tempowindowStatOpen : boolean;
                         tempowindowRapportOpen : boolean;
                         tempowindowCommentairesOpen : boolean;
                         ordreOuvertureDesFenetres:str10;
                       end;
    globalRefreshNeeded : boolean;
    
    gGenreDeTriListe : SInt16; 
    DernierCritereDeTriListeParJoueur : SInt16; 
    RubanTournoiRect,RubanNoirsRect,RubanBlancsRect,RubanDistributionRect : rect;
    RubanCoupRect,RubanTheoriqueRect,RubanReelRect,RubanSousCritActifs : rect;
    positionDistribution,positionTournoi,positionNoir,positionBlanc,positionCoup,positionScoreReel : SInt16; 
    SousCriteresRuban : array[TournoiRubanBox..DistributionRubanBox] of TEHandle;
    BoiteDeSousCritereActive : SInt16; 
    nbColonnesFenetreListe : SInt16; 
    
const kAvecAffichageDistribution        = 1;
      kAvecAffichageTournois            = 2;
      kAvecAffichageSeulementDesJoueurs = 3;

const nbMaxTablesHashExactes = 256;

var   nbTablesHashExactes : SInt32;
      nbTablesHashExactesMoins1 : SInt32;
   
var codage_c1,codage_c2,codage_c3,codage_c4,codage_c5,codage_c6,codage_c7,codage_c8 : array[-1..1] of SInt32;
    HashTable:HashTableHdl;
    IndiceHash:IndiceHashHdl;
    gClefHashage : SInt32;
    HashTableExacte : array[0..nbMaxTablesHashExactes] of HashTableExactePtr;
    CoupsLegauxHash : array [0..nbMaxTablesHashExactes] of CoupsLegauxHashPtr;
    nbCollisionsHashTableExactes : SInt32;
    nbNouvellesEntreesHashTableExactes : SInt32;
    nbPositionsRetrouveesHashTableExactes : SInt32;
    nbNiveauxRemplissageHash : SInt16; 
    profondeurRemplissageHash : SInt16; 
    profondeurPreordre : SInt16; 
    nbNiveauxHashExacte : SInt16; 
    ProfPourHashExacte : SInt16; 
    ProfUtilisationHash,nbNiveauxUtilisationHash : SInt16; 
    seMefierDesScoresDeLArbre : boolean;
    utilisateurVeutDiscretiserEvaluation : boolean;
    discretisationEvaluationEstOK : boolean;
    

const 
  kVarierEnUtilisantMilieu = 1;
  kVarierEnUtilisantGraphe = 2;
var 
  gEntrainementOuvertures:
      record
        CassioVarieSesCoups : boolean;
        CassioSeContenteDeLaNulle : boolean;
        modeVariation : SInt16; 
        varierJusquaCeNumeroDeCoup : SInt16; 
        varierJusquaCetteCadence : SInt32;
        profondeurRechercheVariations : SInt16; 
        derniereProfCompleteMilieuDePartie : SInt16; 
        deltaNoteAutoriseParCoup : SInt32;
        deltaNotePerduCeCoup : array[0..64] of SInt32;
        deltaNotePerduAuTotal : SInt32;   { = sigma( deltaNotePerduCeCoup[i], 0<i<nbreCoup ) }
        classementVariations : ListOfMoveRecords;
      end;



const nbMaxGroupes=25;
type GroupesRec = array[1..nbMaxGroupes] of str255;
     GroupesPtr= ^GroupesRec;
     GroupesHdl= ^GroupesPtr;
var Groupes:GroupesHdl;
    ListeDesGroupesModifiee : boolean;
    UtiliseGrapheApprentissage : boolean;    
    afficheInfosApprentissage : boolean;
    LaDemoApprend : boolean;
    IndexProchainFilsDansGraphe : SInt32;
    avecFlecheProchainCoupDansGraphe : boolean;
    enModeIOS : boolean;
    tickPourCalculTempsIOS : SInt32;
    chainePourIOS : str255;
    InfosDerniereReflexionMac: record
                                  nroDuCoup : SInt32;
                                  coup : SInt32;
                                  def : SInt32;
                                  valeurCoup : SInt32;
                                  coul : SInt32;
                                  prof : SInt32;
                               end;
    TypeDerniereDestructionDemandee : SInt16; 
    derniereLigneUtiliseeMenuFlottantDelta : SInt16; 
    enTeteDeMort : SInt16; 
    couleurEnCoursPourSetUp : SInt16; 
    prefVersion40b11Enregistrees : boolean;
   
const kCalculsTermines = 0;
      kCalculsDemandes = 1;
      kCalculsEnCours  = 2;
var   DemandeCalculsPourBase :  record
	                                magicCookie : SInt32;
	                                NumeroDuCoupDeLaDemande : SInt16; 
	                                EtatDesCalculs : SInt16; 
	                                NiveauRecursionCalculsEtAffichagePourBase : SInt16; 
	                                PhaseDecroissanceRecursion : boolean;
	                                bInfosDejaCalcules : boolean;
	                                bWithCheckEvent : boolean;
	                              end;
   
   
  DernierEvenement :     record
                           shift : boolean;
                           command : boolean;
                           option : boolean;
                           control : boolean;
                           verouillage : boolean;
                         end;

 


IMPLEMENTATION







   

end.
