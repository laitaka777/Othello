PROGRAM Cassio_4_5;



USES
{$IFC OPTION(PROF)}
       Profiler,
{$ENDC}
       UnitMacExtras,UnitActions,UnitTestNouveauFormat,UnitTestProperties,UnitTestZoneMemoire,UnitEvaluation,
       UnitFichierPhotos,UnitBufferedPICT,UnitJaponais,UnitAppleEventsCassio,UnitTestMinimisation,
       UnitTestNouvelleEval,UnitCampFire,UnitProbCutValues,UnitAccesStructuresGraphe,UnitEntreesSortiesGraphe,
       UnitCalculsApprentissage,UnitApprentissageInterversion,UnitApprentissagePartie,UnitTestGrapheApprentissage,
       UnitPileEtFile,UnitSortedSet,UnitWeightedSet,UnitArbresBinairesRecherche,UnitHashing,UnitPositionEtTraitSet,
       CommandLine,UnitAffichageReflexion,UnitCreateBitboardEndgameCode,UnitBitboardStabilite,UnitGeometrie,
       UnitEndgameTree,UnitGenericGameFormat,UnitProgressBar,UnitHashTableExacte,UnitNewGeneral,UnitJeu,
       UnitGestionDuTemps,UnitStringSet,UnitNotesSurCases,UnitArbresTernairesRecherche,UnitMiniProfiler,
       UnitBitboard64bitsModifPlat,UnitSelectionRapideListe,UnitRapportImplementation,UnitCarbonisation,
       UnitTraceLog,UnitUtilitaires,UnitNouvelleEval,UnitChi2NouvelleEval,UnitVecteursEval,UnitBibl,UnitCouleur,
       UnitCalculCouleurCassio,UnitOth1,UnitMoveRecords,UnitPostScript,UnitArbreDeJeuCourant,Unit_AB_Scout,
       UnitAfficheArbreDeJeuCourant,UnitServicesDialogs,UnitDemo,UnitEntreeTranscript,UnitBitboardHash,UnitImagettesMeteo,
       UnitImportDesNoms,UnitDiagramFforum,UnitTroisiemeDimension,UnitPrefs,UnitPotentiels,Unit3DPovRayPicts,
       Zebra_to_Cassio,UnitRetrograde,UnitSolitairesNouveauFormat,UnitFormatsFichiers,UnitCassioSounds,UnitInterversions,
       UnitSmartGameBoard,UnitScripts,UnitPrint,UnitIconisation,UnitInitValeursBlocs,UnitBords,UnitSaisiePartie,UnitMenus,
       UnitStatistiques,UnitRapport,UnitNouveauFormat,UnitRegressionLineaire,UnitDialog,UnitDefinitionsSmartGameBoard,
       UnitFenetres,UnitVieilOthelliste,UnitFinalePourPositionEtTrait,UnitUtilitairesFinale,SNStrings,UnitCourbe,
       UnitScannerOthellistique,UnitBaseNouveauFormat,UnitOthelloGeneralise,UnitLiveUndo,UnitProblemeDePriseDeCoin,
       UnitNormalisation,MyUtils,UnitAlgebreLineaire,UnitCampFire,UnitClassement,UnitCourbe,UnitFinaleFast,
       UnitTHOR_PAR,UnitSearchValues,UnitSymmetricalMapping,UnitDefinitionsPackedThorGame;
 


{ TailleReserveePourLesSegments et TailleReserveePourLaPile sont definis dans UnitNewGeneral }
    
{ Petites choses utiles pour construire Cassio :

  a) Attention, quand on fait une sauvegarde des sources, il faut reconstruire
     le menu rapide de Resedit.

  b) Pour changer la ressource plist :
     - Ouvrir Resedit et l'application Console
     - Créer un fichier Cassio.info.plist
     - L'editer dans TextEdit, le sauvegarder en UTF-8
     - Le vérifier dans le Terminal :
         plutil Cassio.info.plist
     - Fermer le fichier Cassio.info.plist
     - L'ouvrir dans Tex-Edit Plus, de Trans-Tex Software
     - Tout selectionner, puis Edition->Couper&Coller spécial->Copier sans style 
     - Coller le presse-papier dans la ressource plst 0 dans Resedit, sauvegarder
     - Construire Cassio dans CodeWarrior
     - Lancer Cassio depuis le Finder
     - Vérifier dans la Console que les accents sont bien passés
       (pas de message : "This is not proper Unicode...")
     - ouf !

  c) Si on change les icônes, penser à reconstruire la base de donnees de 
     LaunchServices pour faire apparaitre les icônes, en utilisant la 
     commande suivante dans le Terminal :
     
    /System/Library/Frameworks/ApplicationServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

       
    

{$S Initialisations}

{*********************** initialisations ****************************}




procedure SetUpMenuBar;
  var preferenceItemText : str255;
      cmdChar : CharParameter;
  begin
    SetAppleMenu(MyGetMenu(AppleID));
    SetFileMenu(MyGetMenu(fileID));    
    EditionMenu := MyGetMenu(editionID);
    PartieMenu := MyGetMenu(partieID);
    ModeMenu := MyGetMenu(modeID);
    JoueursMenu := MyGetMenu(joueursID);
    BaseMenu := MyGetMenu(baseID);
    TriMenu := MyGetMenu(triID);
    FormatBaseMenu := MyGetMenu(FormatBaseID);
    Picture2DMenu := MyGetMenu(Picture2DID);
    Picture3DMenu := MyGetMenu(Picture3DID);
    CopierSpecialMenu := MyGetMenu(CopierSpecialID);
    GestionBaseWThorMenu := MyGetMenu(GestionBaseWThorID);
    AffichageMenu := MyGetMenu(affichageID);
    SolitairesMenu := MyGetMenu(solitairesID);
    CouleurMenu := MyGetMenu(couleurID);
    if avecProgrammation then 
      ProgrammationMenu := MyGetMenu(programmationID);
{$IFC NOT(CARBONISATION_DE_CASSIO) }
    AppendResMenu(GetAppleMenu(),'DRVR');
{$ENDC }
    OuvertureMenu := MyGetMenu(OuvertureID);
    ReouvrirMenu := MyGetMenu(ReouvrirID);
    NMeilleursCoupsMenu := MyGetMenu(NMeilleursCoupID);
    
    if gIsRunningUnderMacOSX then
      begin
        DeleteMenuItem(GetFileMenu(),QuitCmd);
        DeleteMenuItem(GetFileMenu(),QuitCmd-1);
        GetMenuItemText(GetFileMenu(),PreferencesCmd,preferenceItemText);
        if InsertMenuItemText(GetAppleMenu(),preferenceItemText,FFOCmd+1) = NoErr then
          begin
            GetItemCmd(GetFileMenu(),PreferencesCmd,cmdChar);
            SetItemCmd(GetAppleMenu(),PreferencesDansPommeCmd,cmdChar);
            DeleteMenuItem(GetFileMenu(),PreferencesCmd);
          end;
      end;
    
    InsertMenu(GetAppleMenu(),0);
    InsertMenu(GetFileMenu(),0);
    InsertMenu(EditionMenu,0);
    InsertMenu(PartieMenu,0);
    InsertMenu(ModeMenu,0);
    InsertMenu(JoueursMenu,0);
    InsertMenu(AffichageMenu,0);
    InsertMenu(CouleurMenu,-1);
    InsertMenu(SolitairesMenu,0);
    InsertMenu(BaseMenu,0);
    InsertMenu(TriMenu,-1);
    InsertMenu(FormatBaseMenu,-1);
    InsertMenu(Picture2DMenu,-1);
    InsertMenu(Picture3DMenu,-1);
    InsertMenu(CopierSpecialMenu,-1);
    InsertMenu(GestionBaseWThorMenu,-1);
    if avecProgrammation then InsertMenu(ProgrammationMenu,0);
    InsertMenu(ReouvrirMenu,-1);
    InsertMenu(NMeilleursCoupsMenu,-1);
    DrawMenuBar;
  end;
  
procedure DescendLimiteStack;
var zonelimite : SInt32;
begin {$UNUSED zonelimite}
{$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
    zonelimite := SInt32(GetApplLimit());
    zonelimite := zonelimite-TailleReserveePourLaPile;
    SetApplLimit(MakeMemoryPointer(zonelimite));
{$ENDC}
end;




procedure RemonteLimiteStack;
var zonelimite : SInt32;
begin {$UNUSED zonelimite}
{$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
    zonelimite := SInt32(GetApplLimit());
    zonelimite := zonelimite+TailleReserveePourLaPile;
    SetApplLimit(MakeMemoryPointer(zonelimite));
{$ENDC}
end;


procedure AfficheMemoire;
begin
  EcritEtatMemoire;
end;


procedure InitTablesHashageOthello;
var j,m : SInt32;
begin
  VideHashTable(HashTable);
  HashTable^^[0] := 1;
  for j := 11 to 88 do
    begin
      m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      IndiceHash^^[pionNoir,j] := m;
      HashTable^^[m mod 32768] := 1;
    end;
  for j := 11 to 88 do
    begin
      m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      IndiceHash^^[pionBlanc,j] := m;
      HashTable^^[m mod 32768] := 1;
    end;
  for j := 11 to 88 do
    begin
      m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(RandomLongint());
      IndiceHash^^[pionVide,j] := m;
      HashTable^^[m mod 32768] := 1;
    end;
  VideHashTable(HashTable);
end;


procedure VerifierLaTailleDeCeType(nom : str255;tailleReelle,tailleTheorique : SInt32);
begin
  if (tailleReelle <> tailleTheorique) then
    begin
      WritelnDansRapport('  VerifierLaTailleDeCeType('''+nom+''',Sizeof('+nom+'),'+NumEnString(tailleReelle)+');');
    end;
end;

procedure VerifierLeCompilateur;
var aux : SInt32;
begin
  { Attention ! La liste suivante n'est pas exhaustive, mais devrait donner une bonne idee 
   des problemes liés à la taille des enregistrements sur le compilateur utilisé }
   

  VerifierLaTailleDeCeType('SInt32',Sizeof(SInt32),4);
  VerifierLaTailleDeCeType('SInt16',Sizeof(SInt16),2);
  VerifierLaTailleDeCeType('UInt32',Sizeof(UInt32),4);
  VerifierLaTailleDeCeType('unsignedword',Sizeof(unsignedword),2);
  VerifierLaTailleDeCeType('longint',Sizeof(longint),4);
  VerifierLaTailleDeCeType('integer',Sizeof(integer),2);
  VerifierLaTailleDeCeType('unsignedlong',Sizeof(unsignedlong),4);
  VerifierLaTailleDeCeType('char',Sizeof(char),2);
  VerifierLaTailleDeCeType('byte',Sizeof(byte),2);
  VerifierLaTailleDeCeType('unsignedByte',Sizeof(unsignedByte),1);
  VerifierLaTailleDeCeType('signedByte',Sizeof(signedByte),1);
  VerifierLaTailleDeCeType('integerP',Sizeof(integerP),4);
  VerifierLaTailleDeCeType('ptrint',Sizeof(ptrint),4);
  VerifierLaTailleDeCeType('buf255',Sizeof(buf255),256);
  VerifierLaTailleDeCeType('str255',Sizeof(str255),256);
  VerifierLaTailleDeCeType('str30',Sizeof(str30),32);
  VerifierLaTailleDeCeType('short',Sizeof(short),2);
  VerifierLaTailleDeCeType('long',Sizeof(long),4);
  VerifierLaTailleDeCeType('CharSet',Sizeof(CharSet),32);
  VerifierLaTailleDeCeType('SavedWindowInfo',Sizeof(SavedWindowInfo),16);
  VerifierLaTailleDeCeType('SetOfChar',Sizeof(SetOfChar),32);
  VerifierLaTailleDeCeType('str7',Sizeof(str7),8);
  VerifierLaTailleDeCeType('str41',Sizeof(str41),42);
  VerifierLaTailleDeCeType('str60',Sizeof(str60),62);
  VerifierLaTailleDeCeType('str120',Sizeof(str120),122);
  VerifierLaTailleDeCeType('str185',Sizeof(str185),186);
  VerifierLaTailleDeCeType('PackedThorGame',Sizeof(PackedThorGame),62);
  VerifierLaTailleDeCeType('str120Hdl',Sizeof(str120Hdl),4);
  VerifierLaTailleDeCeType('GrapheRec',Sizeof(GrapheRec),356);
  VerifierLaTailleDeCeType('RealType',Sizeof(RealType),8);
  VerifierLaTailleDeCeType('VecteurBooleens',Sizeof(VecteurBooleens),48);
  VerifierLaTailleDeCeType('MatriceReels',Sizeof(MatriceReels),12808);
  VerifierLaTailleDeCeType('VecteurReels',Sizeof(VecteurReels),324);
  VerifierLaTailleDeCeType('VecteurLongint',Sizeof(VecteurLongint),164);
  VerifierLaTailleDeCeType('menuFlottantBasesRec',Sizeof(menuFlottantBasesRec),124);
  VerifierLaTailleDeCeType('stringBibl',Sizeof(stringBibl),42);
  VerifierLaTailleDeCeType('TypeIntegerArray',Sizeof(TypeIntegerArray),2);
  VerifierLaTailleDeCeType('PointMultidimensionnelInteger',Sizeof(PointMultidimensionnelInteger),12);
  VerifierLaTailleDeCeType('signedByte',Sizeof(signedByte),1);
  VerifierLaTailleDeCeType('BitboardHashRec',Sizeof(BitboardHashRec),20);
  VerifierLaTailleDeCeType('BitboardHash',Sizeof(BitboardHash),4);
  VerifierLaTailleDeCeType('BitboardHashTableRec',Sizeof(BitboardHashTableRec),44);
  VerifierLaTailleDeCeType('BitboardHashEntryRec',Sizeof(BitboardHashEntryRec),40);
  VerifierLaTailleDeCeType('bitboard',Sizeof(bitboard),16);
  VerifierLaTailleDeCeType('t_othellierBitboard_descr',Sizeof(t_othellierBitboard_descr),800);
  VerifierLaTailleDeCeType('listeCoupsAvecBitboard',Sizeof(listeCoupsAvecBitboard),2800);
  VerifierLaTailleDeCeType('t_table_BlocsDeCoin',Sizeof(t_table_BlocsDeCoin),13122);
  VerifierLaTailleDeCeType('t_liste_assoc_bord',Sizeof(t_liste_assoc_bord),16008);
  VerifierLaTailleDeCeType('t_code_bord',Sizeof(t_code_bord),10);
  VerifierLaTailleDeCeType('CouleurOthellierRec',Sizeof(CouleurOthellierRec),286);
  VerifierLaTailleDeCeType('plateauOthello',Sizeof(plateauOthello),100);
  VerifierLaTailleDeCeType('typeColorationCourbe',Sizeof(typeColorationCourbe),1);
  VerifierLaTailleDeCeType('SetOfGenreDeReflexion',Sizeof(SetOfGenreDeReflexion),1);
  VerifierLaTailleDeCeType('CelluleRec',Sizeof(CelluleRec),44);
  VerifierLaTailleDeCeType('CelluleListeHeuristiqueRec',Sizeof(CelluleListeHeuristiqueRec),44);
  VerifierLaTailleDeCeType('EnsembleDeTypes',Sizeof(EnsembleDeTypes),4);
  VerifierLaTailleDeCeType('typePartiePourGraphe',Sizeof(typePartiePourGraphe),256);
  VerifierLaTailleDeCeType('ListeDeCellules',Sizeof(ListeDeCellules),1608);
  VerifierLaTailleDeCeType('t_EnTeteNouveauFormat',Sizeof(t_EnTeteNouveauFormat),16);
  VerifierLaTailleDeCeType('t_JoueurRecNouveauFormat',Sizeof(t_JoueurRecNouveauFormat),20);
  VerifierLaTailleDeCeType('t_TournoiRecNouveauFormat',Sizeof(t_TournoiRecNouveauFormat),26);
  VerifierLaTailleDeCeType('t_PartieRecNouveauFormat',Sizeof(t_PartieRecNouveauFormat),68);
  VerifierLaTailleDeCeType('t_SolitaireRecNouveauFormat',Sizeof(t_SolitaireRecNouveauFormat),36);
  VerifierLaTailleDeCeType('indexArray',Sizeof(indexArray),1);
  VerifierLaTailleDeCeType('DistributionRec',Sizeof(DistributionRec),24);
  VerifierLaTailleDeCeType('FichierNouveauFormatRec',Sizeof(FichierNouveauFormatRec),396);
  VerifierLaTailleDeCeType('JoueursNouveauFormatRec',Sizeof(JoueursNouveauFormatRec),116);
  VerifierLaTailleDeCeType('TournoisNouveauFormatRec',Sizeof(TournoisNouveauFormatRec),76);
  VerifierLaTailleDeCeType('tableJoueursNouveauFormat',Sizeof(tableJoueursNouveauFormat),116);
  VerifierLaTailleDeCeType('SetOfPropertyTypes',Sizeof(SetOfPropertyTypes),14);
  VerifierLaTailleDeCeType('Triple',Sizeof(Triple),4);
  VerifierLaTailleDeCeType('PartieFormatGGFRec',Sizeof(PartieFormatGGFRec),1596);
  VerifierLaTailleDeCeType('ChecksRecord',Sizeof(ChecksRecord),36);
  VerifierLaTailleDeCeType('SetOfItemNumber',Sizeof(SetOfItemNumber),32);
  VerifierLaTailleDeCeType('Transcript',Sizeof(Transcript),204);
  VerifierLaTailleDeCeType('FichierPictureRec',Sizeof(FichierPictureRec),16);
  VerifierLaTailleDeCeType('FichierTEXT',Sizeof(FichierTEXT),352);
  VerifierLaTailleDeCeType('AmeliorationsAlphaRec',Sizeof(AmeliorationsAlphaRec),772);
  VerifierLaTailleDeCeType('FormatFichierRec',Sizeof(FormatFichierRec),518);
  VerifierLaTailleDeCeType('InterversionHashIndexRec',Sizeof(InterversionHashIndexRec),8);
  VerifierLaTailleDeCeType('DecompressionHashExacteRec',Sizeof(DecompressionHashExacteRec),200);
  VerifierLaTailleDeCeType('codePositionRec',Sizeof(codePositionRec),40);
  VerifierLaTailleDeCeType('bitboard',Sizeof(bitboard),16);
  VerifierLaTailleDeCeType('celluleCaseVideDansListeChainee',Sizeof(celluleCaseVideDansListeChainee),16);
  VerifierLaTailleDeCeType('t_bufferCellulesListeChainee',Sizeof(t_bufferCellulesListeChainee),1056);
  VerifierLaTailleDeCeType('tableDePointeurs',Sizeof(tableDePointeurs),400);
  VerifierLaTailleDeCeType('celluleCaseVideDansListeChaineePtr',Sizeof(celluleCaseVideDansListeChaineePtr),4);
  VerifierLaTailleDeCeType('myKeyMap',Sizeof(myKeyMap),16);
  VerifierLaTailleDeCeType('MenuCmdRec',Sizeof(MenuCmdRec),4);
  VerifierLaTailleDeCeType('ReflexionTypesSet',Sizeof(ReflexionTypesSet),128);
  VerifierLaTailleDeCeType('plBool',Sizeof(plBool),100);
  VerifierLaTailleDeCeType('plOthSignedByte',Sizeof(plOthSignedByte),100);
  VerifierLaTailleDeCeType('plOtInteger',Sizeof(plOtInteger),200);
  VerifierLaTailleDeCeType('plOthLongint',Sizeof(plOthLongint),400);
  VerifierLaTailleDeCeType('plOthEndgame',Sizeof(plOthEndgame),100);
  VerifierLaTailleDeCeType('ListOfMoveRecords',Sizeof(ListOfMoveRecords),2304);
  VerifierLaTailleDeCeType('MinSec',Sizeof(MinSec),12);
  VerifierLaTailleDeCeType('t_Octet',Sizeof(t_Octet),2);
  VerifierLaTailleDeCeType('DeuxOctets',Sizeof(DeuxOctets),2);
  VerifierLaTailleDeCeType('Property',Sizeof(Property),12);
  VerifierLaTailleDeCeType('PropertyListRec',Sizeof(PropertyListRec),16);
  VerifierLaTailleDeCeType('GameTreeListRec',Sizeof(GameTreeListRec),8);
  VerifierLaTailleDeCeType('GameTreeRec',Sizeof(GameTreeRec),20);
  VerifierLaTailleDeCeType('t_partie',Sizeof(t_partie),3432);
  VerifierLaTailleDeCeType('t_partieDansThorDBA',Sizeof(t_partieDansThorDBA),68);
  VerifierLaTailleDeCeType('InfoFrontRec',Sizeof(InfoFrontRec),256);
  VerifierLaTailleDeCeType('InfosMilieuRec',Sizeof(InfosMilieuRec),364);
  VerifierLaTailleDeCeType('tabl_heuristique',Sizeof(tabl_heuristique),4836);
  VerifierLaTailleDeCeType('meilleureSuiteInfosRec',Sizeof(meilleureSuiteInfosRec),82);
  VerifierLaTailleDeCeType('t_AnalyseRetrogradeInfos',Sizeof(t_AnalyseRetrogradeInfos),2464);
  VerifierLaTailleDeCeType('packed7',Sizeof(packed7),8);
  VerifierLaTailleDeCeType('tableCommentaireOuv',Sizeof(tableCommentaireOuv),15002);
  VerifierLaTailleDeCeType('EvaluationCassioRec',Sizeof(EvaluationCassioRec),64);
  VerifierLaTailleDeCeType('PageImprRec',Sizeof(PageImprRec),12);
  VerifierLaTailleDeCeType('BigOthellier',Sizeof(BigOthellier),968);
  VerifierLaTailleDeCeType('Point',Sizeof(Point),4);
  VerifierLaTailleDeCeType('PackedOthelloPosition',Sizeof(PackedOthelloPosition),16);
  VerifierLaTailleDeCeType('ABRRec',Sizeof(ABRRec),20);
  VerifierLaTailleDeCeType('ATRRec',Sizeof(ATRRec),16);
  VerifierLaTailleDeCeType('PositionEtTraitRec',Sizeof(PositionEtTraitRec),108);
  VerifierLaTailleDeCeType('double_t',Sizeof(double_t),8);
  VerifierLaTailleDeCeType('VincenzMoveRec',Sizeof(VincenzMoveRec),20);
  VerifierLaTailleDeCeType('ProbCutRecord',Sizeof(ProbCutRecord),24);
  VerifierLaTailleDeCeType('ProblemePriseDeCoin',Sizeof(ProblemePriseDeCoin),184);
  VerifierLaTailleDeCeType('PropertyLocalisation',Sizeof(PropertyLocalisation),16);
  VerifierLaTailleDeCeType('InfoQuintuplet',Sizeof(InfoQuintuplet),8);
  VerifierLaTailleDeCeType('PackedSquareSet',Sizeof(PackedSquareSet),8);
  VerifierLaTailleDeCeType('str7',Sizeof(str7),8);
  VerifierLaTailleDeCeType('string',Sizeof(string),256);
  VerifierLaTailleDeCeType('SearchResult',Sizeof(SearchResult),20);
  VerifierLaTailleDeCeType('SearchWindow',Sizeof(SearchWindow),40);
  VerifierLaTailleDeCeType('CharArray',Sizeof(CharArray),32002);
  VerifierLaTailleDeCeType('SortedSet',Sizeof(SortedSet),8);
  VerifierLaTailleDeCeType('SquareSet',Sizeof(SquareSet),16);
  VerifierLaTailleDeCeType('PackedSquareSet',Sizeof(PackedSquareSet),8);
  VerifierLaTailleDeCeType('ThorParRec',Sizeof(ThorParRec),112);
  VerifierLaTailleDeCeType('Tableau60Longint',Sizeof(Tableau60Longint),244);
  VerifierLaTailleDeCeType('DoubleArray',Sizeof(DoubleArray),8);
  VerifierLaTailleDeCeType('LongintArray',Sizeof(LongintArray),4);
  VerifierLaTailleDeCeType('VecteurNouvelleEval',Sizeof(VecteurNouvelleEval),880);
  VerifierLaTailleDeCeType('VecteurNouvelleEvalInteger',Sizeof(VecteurNouvelleEvalInteger),2640);
  VerifierLaTailleDeCeType('WeightedSet',Sizeof(WeightedSet),12);
  VerifierLaTailleDeCeType('ZoneMemoirePtr',Sizeof(ZoneMemoirePtr),4);
  VerifierLaTailleDeCeType('ZoneMemoire',Sizeof(ZoneMemoire),48);

  WritelnDansRapport('Vérifions que les types enumerés commencent bien à zéro...');
  WritelnStringAndNumDansRapport('SInt32(kNonPrecisee) = ',SInt32(kNonPrecisee));
  
  {verification de BTst et de BSet et de BClr}
  aux := 0;
  BSet(aux, 14);
  WritelnDansRapport('apres BSET(aux, 14), aux = ' + Hexa(aux));
  WritelnDansRapport('Hexa(BNOT(aux)) = '+Hexa(BNOT(aux)));
  
  aux := 0;
  BSet(aux, 13);
  WritelnDansRapport('apres BSET(aux, 13), aux = ' + Hexa(aux));
  WritelnDansRapport('Hexa(BNOT(aux)) = '+Hexa(BNOT(aux)));
  
  aux := 0;
  BSet(aux, 4);
  WritelnDansRapport('apres BSET(aux, 4), aux = ' + Hexa(aux));
  WritelnDansRapport('Hexa(BNOT(aux)) = '+Hexa(BNOT(aux)));
  
  aux := 0;
  BSet(aux, 3);
  WritelnDansRapport('apres BSET(aux, 3), aux = ' + Hexa(aux));
  WritelnDansRapport('Hexa(BNOT(aux)) = '+Hexa(BNOT(aux)));
  
end;


{**********************************************************************************************}
{************************************** initialisation ****************************************}
{**********************************************************************************************}

procedure Initialisation;
var i,j : SInt16; 
    s : str255;
    a,b : SInt16; 
    textureAChange : boolean;
    err : OSErr;
    ignorePattern : PatternPtr;
begin

  SetCassioChecksEvents(true);
  
  windowPlateauOpen := false;
  windowCourbeOpen := false;
  windowAideOpen := false;
  windowGestionOpen := false;
  windowReflexOpen := false;
  windowListeOpen := false;
  windowStatOpen := false;
  windowPaletteOpen := true;
  windowRapportOpen := false;
  arbreDeJeu.windowOpen := false;
  wPlateauPtr := NIL;
  wCourbePtr := NIL;
  wAidePtr := NIL;
  wGestionPtr := NIL;
  wReflexPtr := NIL;
  wListePtr := NIL;
  wStatPtr := NIL;
  wPalettePtr := NIL;
  arbreDeJeu.theDialog := NIL;
  with VisibiliteInitiale do
    begin
      ordreOuvertureDesFenetres := 'ORSLKPGCT';
      tempowindowPaletteOpen := windowPaletteOpen;
      tempowindowCourbeOpen := windowCourbeOpen;
      tempowindowAideOpen := windowAideOpen;
      tempowindowGestionOpen := windowGestionOpen;
      tempowindowReflexOpen := windowReflexOpen;
      tempowindowListeOpen := windowListeOpen;
      tempowindowStatOpen := windowStatOpen;
      tempowindowRapportOpen := windowRapportOpen;
      tempowindowCommentairesOpen := arbreDeJeu.windowOpen;
    end;
  

  
   
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Entrée initialisation');

 
  
  with gPoliceNumeroCoup do
    begin
      if (EpsiSansID <> 0) then
        begin
          policeID     := EpsiSansID;
          petiteTaille := 10;
          grandeTaille := 12;
          theStyle     := bold;
        end else
      if (TimesID <> 0) then
        begin
          policeID     := TimesID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end else
      if (SymbolID <> 0) then
        begin
          policeID     := SymbolID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end else
      if (TrebuchetMSID <> 0) then
        begin
          policeID     := TrebuchetMSID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end else
      if (NewYorkID <> 0) then
        begin
          policeID     := NewYorkID;
          petiteTaille := 10;
          grandeTaille := 12;
          theStyle     := bold;
        end else
      if (TimesNewRomanID <> 0) then
        begin
          policeID     := TimesNewRomanID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end else
     {if (PalatinoID <> 0) then}
        begin
          policeID     := PalatinoID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end;
    end;
    
  err := InitialiseQuartzAntiAliasing();
    
  if gIsRunningUnderMacOSX
    then themeCourantDeCassio := kThemeBaskerville
    else themeCourantDeCassio := kThemeMacOS9;

  DoitEcrireInterversions := false;
  avecProgrammation := false;
  UneSeuleBase := true;
  inBackGround := false;
   
  
  
  SetCassioChecksEvents(true);
  SetNiveauTeteDeMort(0);
  SetCassioEstEnTrainDeReflechir(false,NIL);
  SetGenreDerniereReflexionDeCassio(ReflPasDeDonnees,0);
  
  
  fntrPlateauOuverteUneFois := false;
  CriteresRubanModifies := false;
  DejaFormatImpression := false;
  avecNomOuvertures := true;
  neJamaisTomber := false;
  LaDemoApprend := false;
  SetAvecAffichageNotesSurCases(kNotesDeCassio,true);
  SetAvecAffichageNotesSurCases(kNotesDeZebra,true);
  doitEffacerSousLesTextesSurOthellier := false;
  
  
  with gEntrainementOuvertures do
    begin
      CassioVarieSesCoups := false;
      CassioSeContenteDeLaNulle := false;
      modeVariation := kVarierEnUtilisantMilieu;
      varierJusquaCeNumeroDeCoup := 20;
      varierJusquaCetteCadence := minutes3;
      for i := 0 to 64 do
        deltaNotePerduCeCoup[i] := 0;
      deltaNoteAutoriseParCoup := 300;  {4 pions}
      deltaNotePerduAuTotal := 0;
      profondeurRechercheVariations := 11;
      ViderListOfMoveRecords(classementVariations);
      derniereProfCompleteMilieuDePartie := 0;
    end;
    
    
  avecFlecheProchainCoupDansGraphe := true;
  SupprimerLesEffetsDeZoom := true;
  OptimisePourKaleidoscope := true;
  NePasUtiliserLeGrasFenetreOthellier := false;
  doitAjusterCurseur := true;
  gEnRechercheSolitaire := false;
  gEnEntreeSortieLongueSurLeDisque := false;
  
  
  
  SousCriteresRuban[TournoiRubanBox] := NIL;
  SousCriteresRuban[JoueurNoirRubanBox] := NIL;
  SousCriteresRuban[JoueurBlancRubanBox] := NIL;
  SousCriteresRuban[DistributionRubanBox] := NIL;
  
  arbreDeJeu.enModeEdition           := false;
  arbreDeJeu.doitResterEnModeEdition := false;
  arbreDeJeu.EditionRect             := MakeRect(0,0,0,0);
  arbreDeJeu.backMoveRect            := MakeRect(-1,-1,536,16);
  arbreDeJeu.positionLigneSeparation := 100;
  arbreDeJeu.hauteurRuban            := 0;
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant TrapExists');

  
  gAppleEventsInitialized := false;
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
  
  
  
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant DetermineVolumeApplication');
  
  SolitairesRefVol := volumeRefCassio;
  VolumeRefThorDBA := volumeRefCassio;
  VolumeRefThorDBASolitaire := volumeRefCassio;
  dernierePartieExtraiteThor := 1;
  dernierePartieExtraiteWThor.numFichier := 1;
  dernierePartieExtraiteWThor.numPartie := 1;
  indexSolitaire := -57;  {ou n'importe quel nombre <=-1}
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant GetWDName(VolumeRefThorDBASolitaire)');
  
  s := GetWDName(VolumeRefThorDBASolitaire);
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant CheminAccesThorDBASolitaire^^ := …');
  
  CheminAccesThorDBASolitaire^^ := s+'Solitaires.dba';
  CheminAccesSolitaireCassio^^ := s+'Solitaires Cassio';
  CheminAccesThorDBA^^ := s+'Thor.dba';
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant GetIndString(s,TextesListeID,12)');
  
  GetIndString(s,TextesListeID,12);
  CaracterePourNoir := s;
  GetIndString(s,TextesListeID,13);
  CaracterePourBlanc := s;
  GetIndString(s,TextesListeID,14);
  CaracterePourEgalite := s;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant WindowsHaveThickBorders');
  
  gWindowsHaveThickBorders := WindowsHaveThickBorders(gEpaisseurBorduresFenetres);
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant ProfondeurMainDevice');
  
  if gHasColorQuickDraw
    then gEcranCouleur := (ProfondeurMainDevice()>2)
    else gEcranCouleur := false;
  gBlackAndWhite := not(gEcranCouleur);
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant CalculeCouleurRecord');
  
  gCouleurOthellier := CalculeCouleurRecord(CouleurID,VertPaleCmd);
    
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant Picture3DID');
  
  gLastTexture3D.theMenu  := Picture3DID;
  gLastTexture3D.theCmd := 1;
  gLastTexture2D.theMenu  := gCouleurOthellier.menuID;
  gLastTexture2D.theCmd := gCouleurOthellier.menuCmd;
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant PionInversePat');
  
  ignorePattern := GetQDGlobalsDarkGray(darkGrayPattern);
  ignorePattern := GetQDGlobalsLightGray(lightGrayPattern);
  ignorePattern := GetQDGlobalsGray(grayPattern);
  ignorePattern := GetQDGlobalsBlack(blackPattern);
  ignorePattern := GetQDGlobalsWhite(whitePattern);
  
  PionInversePat := grayPattern;
  for i := 0 to 7 do InversePionInversePat.pat[i] := 255-PionInversePat.pat[i];
  
  watch := GetCursor(watchcursor);
  iBeam := GetCursor(iBeamCursor);
  interversionCurseur := GetCursor(interversionCursorID);
  parcheminCurseur := GetCursor(parcheminCursorID);
  teteDeMortCurseur := GetCursor(teteDeMortCursorID);
  pionNoirCurseur := GetCursor(pionNoirCurseurID);
  pionBlancCurseur := GetCursor(pionBlancCurseurID);
  gommeCurseur := GetCursor(gommeCurseurID);
  backMoveCurseur := GetCursor(backMoveCurseurID);
  avanceMoveCurseur := GetCursor(avanceMoveCurseurID);
  DragLineVerticalCurseur := GetCursor(DragLineVerticalCurseurID);
  DragLineHorizontalCurseur := GetCursor(DragLineHorizontalCurseurID);
  
  
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant Ecranrect');
  
  tailleFenetrePlateauAvantPassageEn3D := 0;
  Ecranrect := GetScreenBounds();
  {Ecranrect.right := 512;
  Ecranrect.bottom := 342;}
  EcranDe512 := ((Ecranrect.right-Ecranrect.left)=512);
  genreAffichageTextesDansFenetrePlateau := kAffichageAere;
  nbColonnesFenetreListe := kAvecAffichageTournois;
  SetValeursStandardRubanListe(nbColonnesFenetreListe);
  aQuiDeJouer := pionNoir;
  gameOver := false;
  avecAleatoire := true;  
  fond := blackPattern;
  FntrFelicitationTopLeft.h := 300;
  FntrFelicitationTopLeft.v := 100;
  AuMoinsUneFelicitation := false;
  gNbreMegaoctetsPourLaBase := 20;
  
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant SetValeursParDefautDiagFFORUM');
  
  SetValeursParDefautDiagFFORUM(ParamDiagCourant,DiagrammePosition);
  SetValeursParDefautDiagFFORUM(ParamDiagPositionFFORUM,DiagrammePosition);
  SetValeursParDefautDiagFFORUM(ParamDiagPartieFFORUM,DiagrammePartie);
  SetValeursParDefautDiagFFORUM(ParamDiagImpr,DiagrammePourListe);
  TypeDerniereDestructionDemandee := kDetruireCeNoeudEtFils;
  derniereLigneUtiliseeMenuFlottantDelta := 12;  {une ligne vide vers le milieu du menu}
  SetCalculs3DMocheSontFaits(false);
  profSupUn := false;
  nbAlertesPositionFeerique := 0;
  nbInformationMemoire := 0;
  numeroPuce := 0;
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant HauteurChaqueLigneDansListe');
  
  if gVersionJaponaiseDeCassio & gHasJapaneseScript
    then HauteurChaqueLigneDansListe := 14
    else HauteurChaqueLigneDansListe := 12;
  
  derniertick := TickCount();
  delaiAvantDoSystemTask := 60;
  latenceEntreDeuxDoSystemTask := 2;
  profMinimalePourTriDesCoups := 3;
  profMinimalePourTriDesCoupsParAlphaBeta := 7;
  SommeNbEvaluationsRecursives := 0;
  MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
  ReInitialisePartieHdlPourNouvellePartie(true);
  SetRect(aireDeJeu,0,0,0,0);
  if EcranDe512
    then SetRect(FntrPlatRect,4,41,510,340)
    else SetRect(FntrPlatRect,4,41,580,433);
  if EcranDe512
    then SetRect(FntrCourbeRect,110,110,403,260)
    else SetRect(FntrCourbeRect,340,120,630,270);
  if EcranDe512
    then SetRect(FntrReflexRect,385,108,510,236)
    else SetRect(FntrReflexRect,395,108,545,236);
  SetRect(FntrAideRect,100,100,634,476);
  SetRect(FntrGestionRect,330,248,508,328);
  a := Ecranrect.right;
  b := Ecranrect.bottom;
  if a>637 then a := 637;
  if b>405 then b := 405;
  SetRect(FntrListeRect,a-LargeurNormaleFenetreListe(nbColonnesFenetreListe)+1,45,a,b-145);
  
  with FntrListeRect do
    bottom := bottom - (bottom-top) mod 12 +2;
  SetRect(FntrStatRect,a-251,b-121,a,b-1);
  if EcranDe512
    then SetRect(FntrPaletteRect,380,305,380+9*largeurCasePalette,305+2*hauteurCasePalette)
    else SetRect(FntrPaletteRect,395,362,395+9*largeurCasePalette,362+2*hauteurCasePalette);
  if EcranDe512
    then SetRect(FntrRapportRect,252,130,495,310)
    else SetRect(FntrRapportRect,252,122,595,342);
  if EcranDe512
    then SetRect(FntrCommentairesRect,300,100,500,300)
    else SetRect(FntrCommentairesRect,385,130,585,330);
  SetRect(FntrCadenceRect,0,0,0,0);
  with IconisationDeCassio do
    begin
      if gIsRunningUnderMacOSX | gWindowsHaveThickBorders
        then LargeurFenetreIconisation := 89
        else LargeurFenetreIconisation := 93;
      SetRect(IconisationDeCassio.IconisationRect,10,50,10+LargeurFenetreIconisation,50+LargeurFenetreIconisation);
    end;
  SetRect(CloseZoomRectFrom,-13333,-13333,-13333,-13333);
  SetRect(CloseZoomRectTo,-13333,-13333,-13333,-13333);
  globalRefreshNeeded := false;
  gPourcentageTailleDesPions := 92;
  avecLisereNoirSurPionsBlancs := false;
  avecOmbrageDesPions := true;
  
  
  ViderNotesSurCases(kNotesDeCassioEtZebra,false,othellierToutEntier);
  derniertick := TickCount();
  SetValeursGestionTemps(0,0,0,0.0,0,0);
  ReinitilaliseInfosAffichageReflexion;
  SetPotentielsOptimums(PositionEtTraitInitiauxStandard());
  if avecAleatoire 
    then RandomizeTimer
    else SetQDGlobalsRandomSeed(1000);
  JoueursEtTournoisEnMemoire := false;
  ToujoursIndexerBase := true;
  nbPartiesActives := 0;
  nbPartiesChargees := 0;
  NbreCoupsApresLecture := 0;
  with infosListeParties do
    begin
      partieHilitee := 1;
      dernierNroReferenceHilitee := 0;
      clicHilite := 0;
      justificationPasDePartie := -1;
    end;
  InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
  InitInfosFermetureListePartie(infosListePartiesDerniereFermeture);
  avecInterversions := true;
  OrdreDuTriRenverse := false;
  genreDeTestPourAnnee := testEgalite;
  gGenreDeTriListe := TriParDate;
  DernierCritereDeTriListeParJoueur := TriParJoueurNoir;
  sousEmulatorSousPC := false;
  avecAlerteNouvInterversion := true;
  numeroCoupMaxPourRechercheIntervesionDansArbre := 40;
  PassesDejaExpliques := 0;
  nbExplicationsPasses := 3;
  ListeDesGroupesModifiee := false;
  listeEtroiteEtNomsCourts := false;
  SetPremierCoupParDefaut(43);
  
  Yannonc := 1;
  Quitter := false;
  enSetUp := false;
  enRetour := false;
  analyseRetrograde.enCours := false;
  analyseRetrograde.genreAnalyseEnCours := PasAnalyseRetrograde;
  analyseRetrograde.genreDerniereAmeliorationCherchee := PasAnalyseRetrograde;
  analyseRetrograde.tempsDernierCoupAnalyse := 0;
  couleurMacintosh := pionBlanc;
  aQuiDeJouer := pionNoir;
  MemoryFillChar(@jeuCourant,sizeof(jeuCourant),chr(0));
  CoefficientsStandard;
  withUserCoeffDansNouvelleEval := true;
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant avecSon');
    
  avecSon := true;
  avecSonPourPosePion := true;
  avecSonPourRetournePion := true;
  avecSonPourGameOver := true;
  sonPourPosePion := kSonTickID;
  sonPourRetournePion := kSonTockID;
  SetEnVieille3D(false);
  HumCtreHum := false;
  afficheBibl := false;
  with debuggage do
    begin
      general := false;
      entreesSortiesUnitFichiersTEXT := false;
      pendantLectureBase := false;
      {afficheSuiteInitialisations := true;}  {valeur deja mise au tout debut! }
      evenementsDansRapport := false;
      elementsStrategiques := false;
      gestionDuTemps := false;
      calculFinaleOptimaleParOptimalite := false;
      arbreDeJeu := false;
      lectureSmartGameBoard := false;
      apprentissage := false;
      algoDeFinale := false;
      MacOSX := false;
    end;
  with affichageReflexion do
    begin
      doitAfficher := false; 
      demandeEnSuspend := false;
      tickDernierAffichageReflexion := 0;
      afficherToutesLesPasses := false;
      SetDemandeAffichageReflexionEnSuspend(false);
    end;
  afficheNumeroCoup := true;
  afficheSuggestionDeCassio := false;
  afficheGestionTemps := false;
  afficheMeilleureSuite := false; 
  affichePierresDelta := false;
  afficheProchainsCoups := false;
  afficheSignesDiacritiques := false;
  avecGagnantEnGrasDansListe := true;
  avecEvaluationTotale := false;
  evaluationAleatoire := false;
  avecEvaluationDeFisher := false;
  avecEvaluationTablesDeCoins := true;
  EnTraitementDeTexte := false;
  analyseIntegraleDeFinale := false;
  doitEcrireReflexFinale := true;
  BoiteDeSousCritereActive := 0;
  PostscriptCompatibleXPress := true;
  avecAB_Constr := false;
  SetEffetSpecial(false);
  effetspecial2 := false;
  effetspecial3 := false; 
  effetspecial4 := false;
  effetspecial5 := false;
  effetspecial6 := false;
  afficheInfosApprentissage := false;
  UtiliseGrapheApprentissage := false;
  enModeIOS := false;
  chainePourIOS := '';
  avecBibl := true;
  avecTestBibliotheque := false;
  JoueBonsCoupsBibl := false;
  jeuInstantane := true;
  sansReflexionSurTempsAdverse := false;
 (* avecDessinCoupEnTete := false; *)
  SensLargeSolitaire := true;
  finaleEnModeSolitaire := false;
  ecrireDansRapportLog := false;
  InfosTechniquesDansRapport := false;
  referencesCompletes := true;
  nbCasesVidesMinSolitaire := 2;
  nbCasesVidesMaxSolitaire := 64;
  for i := 1 to 64 do SolitairesDemandes[i] := false;
  for i := 6 to 18 do SolitairesDemandes[i] := true;
  eviterSolitairesOrdinateursSVP := false;
  OthelloTorique := false;
  PionClignotant := false;
  retirerEffet3DSubtilOthellier2D := false;
  avecSystemeCoordonnees := true;
  garderPartieNoireADroiteOthellier := true;
  avecGestionBase := true;
  LectureAntichronologique := false;
  sousSelectionActive := false;
  avecCalculPartiesActives := true;
  avecSauvegardePref := true;
  traductionMoisTournoi := MoisEnToutesLettres;
  CassioUtiliseDesMajuscules := true;
  differencierLesFreres := false;
  avecSelectivite := false;
  discretisationEvaluationEstOK := false;
  utilisateurVeutDiscretiserEvaluation := true;
  seMefierDesScoresDeLArbre := false;
  avecRecursiviteDansEval := true;
  peutDebrancherRecursiviteDansEval := true;
  doitConfirmerQuitter := true;
  analyseRetrograde.doitConfirmerArret := true;
  analyseRetrograde.nbMinPourConfirmationArret := 10;
  analyseRetrograde.nbPresentationsDialogue := 0;
  prefVersion40b11Enregistrees := false;
  nbCoupsEnTete := 1;
  valeurApprondissementIteratif := 2;
  SetTailleOthelloPourDiagrammeFForum(8,8); {par defaut les diagrammes pour Fforum seront en 8x8 }
  
  
  demo                 := false;           { à true, organise un match en demo }  
  SetProfImposee(false,'initialisation');
  level                := 5;               { utile seulement si profimposee = true}
  decrementetemps      := true;
  SetCadence(minutes3);
  cadencePersoAffichee := GetCadence();
  NiveauJeuInstantane  := NiveauGrandMaitres;
  avecAjustementAutomatiqueDuNiveau := true;   
  humanWinningStreak   := 0;
  humanScoreLastLevel  := 0;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant LitFichierPreferences');
  
  (********************************************************************************************)
  (********************************************************************************************)
  
  LitFichierPreferences;
  avecSauvegardePrefArrivee := avecSauvegardePref;
 
  (********************************************************************************************)
  (********************************************************************************************)
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant VisibiliteInitiale');
  
  with VisibiliteInitiale do
    begin
      tempowindowPaletteOpen := windowPaletteOpen;
      tempowindowCourbeOpen := windowCourbeOpen;
      tempowindowAideOpen := windowAideOpen;
      tempowindowGestionOpen := windowGestionOpen;
      tempowindowReflexOpen := windowReflexOpen;
      tempowindowListeOpen := windowListeOpen;
      tempowindowStatOpen := windowStatOpen;
      tempowindowRapportOpen := windowRapportOpen;
      tempowindowCommentairesOpen := arbreDeJeu.windowOpen;
    end;
  windowPaletteOpen := false;
  windowCourbeOpen := false;
  windowAideOpen := false;
  windowGestionOpen := false;
  windowReflexOpen := false;
  windowListeOpen := false;
  windowStatOpen := false;
  windowRapportOpen := false;
  arbreDeJeu.windowOpen := false;
 
 
  SetUpMenuBar;
  
  SelectCassioFonts(themeCourantDeCassio);
  
  LecturePreparatoireDossierOthelliers(volumeRefCassio);
  DernierCoupPourMenuAff := 56;
  if nbCoupsEnTete>1 
    then SetMenuItemText(ModeMenu,MilieuDeJeuNMeilleursCoupscmd,ParamStr(ReadStringFromRessource(MenusChangeantsID,17),NumEnString(nbCoupsEnTete),'','',''))
    else SetMenuItemText(ModeMenu,MilieuDeJeuNMeilleursCoupscmd,ReadStringFromRessource(MenusChangeantsID,18));
  if gVersionJaponaiseDeCassio & gHasJapaneseScript then
    NePasUtiliserLeGrasFenetreOthellier := true;  {on forcer cela}
  
  AjusteCadenceMin(GetCadence());
 (*SetCoupEntete(-100);*)
  gBlackAndWhite := not(gEcranCouleur);
  
  CheckValidityOfCouleurRecord(gCouleurOthellier,textureAChange);
  gCouleurOthellier := CalculeCouleurRecord(gCouleurOthellier.menuID,gCouleurOthellier.menuCmd);
  if EnJolie3D() then
    begin
      err := LitFichierCoordoneesImages3D(gCouleurOthellier);
      if err = NoErr then err := CreatePovOffScreenWorld(gCouleurOthellier);
      if err <> NoErr then
        begin
          KillPovOffScreenWorld;
          gCouleurOthellier := CalculeCouleurRecord(gLastTexture2D.theMenu,gLastTexture2D.theCmd);
        end;
    end;
	
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant VideHashTable');
  
  InitTablesHashageOthello;
  
  
  
  paramDiagCourant.titreFFORUM^^ := '';
  paramDiagCourant.CommentPositionFFORUM^^ := '';
  paramDiagPositionFFORUM.titreFFORUM^^ := '';
  paramDiagPositionFFORUM.CommentPositionFFORUM^^ := '';
  paramDiagPartieFFORUM.titreFFORUM^^ := '';
  paramDiagPartieFFORUM.CommentPositionFFORUM^^ := '';
  paramDiagImpr.titreFFORUM^^ := '';
  paramDiagImpr.CommentPositionFFORUM^^ := '';
  PageImpr.TitreImpression^^ := '';
  PageImpr.QuoiImprimer := ImprimerPosition;
  PageImpr.FontSizeTitre := 14;
  PageImpr.MargeTitre := 20;
  PageImpr.NumeroterPagesImpr := true;
  titrePartie^^ := '';
  for j := 1 to NbMaxItemsReouvrirMenu do 
    if (nomLongDuFichierAReouvrir[j] <> NIL) then nomDuFichierAReouvrir[j]^^ := '';
  VolRefPourReouvrir := 0;
  CommentaireSolitaire^^ := '';
  SetMeilleureSuite('');
  MeilleureSuiteEffacee := true;
  DerniereChaineComplementation^^ := '@&µôπ¶«Ç‘';
  TypeDerniereComplementation := 0;
  
  
  with DemandeCalculsPourBase do
    begin
      magicCookie := 0;
      NumeroDuCoupDeLaDemande := 0;
      EtatDesCalculs := kCalculsTermines;
      NiveauRecursionCalculsEtAffichagePourBase := 0;
      PhaseDecroissanceRecursion := false;
    end;
  
  
  interruptionReflexion := pasdinterruption;
  gDoitJouerMeilleureReponse := false;
  DerniereActionBaseEffectuee := 0;
  Superviseur(0);
  with InfosDerniereReflexionMac do
    begin
      nroDuCoup  := -1;
      coup       := 0;
      def        := 0;
      coul       := pionVide;
      valeurCoup := -noteMax;
      prof       := 0;
    end;
  
  if debuggage.afficheSuiteInitialisations then 
    StoppeEtAffichePourDebugage('  initialisation : avant Initialise_IndexInfoDejaCalculees');
  
  Initialise_IndexInfoDejaCalculees;
  
  
  
  
  if debuggage.afficheSuiteInitialisations then 
    StoppeEtAffichePourDebugage('  initialisation : avant WaitNextEvent');
  
  
  {on donne une chance aux autres applications de faire des update events}
  {FlushEvents(everyEvent-DiskEvt,0);}
  ShareTimeWithOtherProcesses(1);
  ShareTimeWithOtherProcesses(1);
  ShareTimeWithOtherProcesses(1);
  ShareTimeWithOtherProcesses(1);
  
  
  
  if debuggage.afficheSuiteInitialisations then 
    StoppeEtAffichePourDebugage('  initialisation : avant Initialise_valeurs_tactiques');
    
  Initialise_valeurs_tactiques;
  derniertick := TickCount();
  MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
  nbreDePions[pionBlanc] := 0;
  nbreDePions[pionNoir] := 0;
  
  
  
  if debuggage.afficheSuiteInitialisations then 
    StoppeEtAffichePourDebugage('  initialisation : avant OuvreFntrPlateau');
    
  
  OuvreFntrPlateau(false);
  
  if debuggage.afficheSuiteInitialisations then 
    StoppeEtAffichePourDebugage('  initialisation : avant PrepareNouvellePartie');
    
  
  PrepareNouvellePartie(false);
  
  
  if debuggage.afficheSuiteInitialisations then 
    StoppeEtAffichePourDebugage('  initialisation : avant Ouverture des fenetres');
    
  
  OuvrirLesFenetresDansLOrdre;
  
  
  
  NoUpdateWindowPlateau;
  PrepareNouvellePartie(false);
  if (traductionMoisTournoi<1) | (traductionMoisTournoi>3)
    then traductionMoisTournoi := SucrerPurementEtSimplement;
  derniertick := TickCount();
  
  
  
  EssaieUpdateEventsWindowPlateau;
  
  if WaitNextEvent(0,theEvent,2,NIL) then TraiteOneEvenement;
  
  
  {sur Mac Classic, on borne le nombre de parties chargeables par la mémoire donnée 
   par le Finder (et ce nombre a deja ete calcule dans UnitNewGeneral) }
  
  if gNbreMegaoctetsPourLaBase <= 0 then gNbreMegaoctetsPourLaBase := 1;
  if gIsRunningUnderMacOSX 
    then ChangeNbPartiesChargeablesPourBase(CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024))
    else ChangeNbPartiesChargeablesPourBase(Min(nbrePartiesEnMemoire,CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024)));
  
  
  if debuggage.afficheSuiteInitialisations then 
    StoppeEtAffichePourDebugage('  initialisation : avant LitBibliotheque');
  
  bibliothequeLisible := false;
  if LitBibliotheque('bibliothèque Cassio',avecTestBibliotheque) <> NoErr then;
  
  EssaieUpdateEventsWindowPlateau;
  
  
  
  aQuiDeJouer := pionNoir;
  doitAjusterCurseur := true;
  AjusteCurseur;
  if HasGotEvent(everyEvent,theEvent,0,NIL) then 
     TraiteOneEvenement;
  
  
  
  EnableItemTousMenus;
  EssaieDisableForceCmd;
  MyDisableItem(BaseMenu,OuvrirSelectionneeCmd);
  MyDisableItem(BaseMenu,JouerSelectionneCmd);
  MyDisableItem(BaseMenu,JouerMajoritaireCmd);
  
  
  
  
  if GetAvecAffichageNotesSurCases(kNotesDeCassio) & (BAND(GetAffichageProprietesOfCurrentNode(),kNotesCassioSurLesCases) = 0)
     then SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode() + kNotesCassioSurLesCases);
      
  if not(GetAvecAffichageNotesSurCases(kNotesDeCassio)) & (BAND(GetAffichageProprietesOfCurrentNode(),kNotesCassioSurLesCases) <> 0)
    then SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode() - kNotesCassioSurLesCases);
  
  finDePartieVitesseMac := 41;           {valeur par defaut}
  finDePartieOptimaleVitesseMac := 43;   {valeur par defaut}
  indiceVitesseMac := CalculVitesseMac(false);
  EtalonnageVitesseMac(false);
  DetermineMomentFinDePartie;
  
  AjusteCurseur;
  
  FixeMarquesSurMenus;
  SetStatistiquesSontEcritesDansLaFenetreNormale(true);
  
  DisableKeyboardScriptSwitch;
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant litFichierGroupes');
  GetPartiesAReouvrirFromPrefsFile;
  if InitUnitIconisationOK()
    then 
      begin
        if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant MyEnableItem');
        MyEnableItem(GetFileMenu(),IconisationCmd)
      end
    else
      begin
        if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant MyDisableItem');
        MyDisableItem(GetFileMenu(),IconisationCmd);
        if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant AlerteSimple');
        AlerteSimple('Iconisation impossible !!');
      end;
  
  EnableItemTousMenus;
  FixeMarquesSurMenus;
  FixeMarqueSurMenuBase;
  FixeMarqueSurMenuMode(nbreCoup);
  SetMenusChangeant(0);
  
  LitFichierGroupes;
  
  LoadZebraBook(true);
  
end;  {Initialisation}




{$s SegUnload}

(****************  UnLoad tous les segments  ********)


procedure UnLoadTousSegments;
begin

  {$IFC NOT GENERATINGPOWERPC}

  UnloadSeg(@InitValeursBlocsDeCoin_1);
  UnloadSeg(@InitValeursBlocsDeCoin_2);
  UnloadSeg(@InitValeursBlocsDeCoin_3);
  UnloadSeg(@InitValeursBlocsDeCoin_4);
  UnloadSeg(@InitValeursBlocsDeCoin_5);
  UnloadSeg(@InitValeursBlocsDeCoin);
  UnloadSeg(@AjouteInterversions_5_14);
  UnloadSeg(@AjouteInterversions_15_33);
  UnloadSeg(@Initialise_interversions);
  UnloadSeg(@Initialise_valeurs_bords);               {bords}
  UnloadSeg(@Initialisation);                         {Initialisation}
  UnloadSeg(@NewGeneral);                             {NewGeneral}
  UnloadSeg(@Normalisation);
  UnloadSeg(@LitBibliotheque);
  UnloadSeg(@OuvreFntrPlateau);                       {Fenetres}
  UnloadSeg(@CouleurCmdToRGBColor);                   {Couleur}
  UnloadSeg(@CalculeCouleurRecord);                   {CalculCouleurCassio}
  
  
  UnloadSeg(@SymmetricalMappingLongSquaresLine);      {SymmetricalMapping}
  UnloadSeg(@InitUnitVecteurEval);                    {VecteurEval}
  UnloadSeg(@InitUnitNouvelleEval);                   {NouvelleEval}
  UnloadSeg(@MinimumBracketting);                     {Minimisation}
  
  UnloadSeg(@InitUnitAccesGrapheApprentissage);       {AccesGrapheApprentissage}
  UnloadSeg(@PositionEstDansLeGraphe);                {EntreesSortiesGraphe}
  UnloadSeg(@PropageToutesLesValeursDansLeGraphe);    {CalculsApprentissage}
  UnloadSeg(@ApprendInterversionAlaVoleeDansGraphe);  {ApprentissageInterversion}
  UnloadSeg(@ApprendPartieIsolee);                    {ApprentissagePartie}
  UnloadSeg(@TestApprentissage);                      {TestApprentissage}
  UnloadSeg(@AllocatePile);                           {PileEtFile}
  UnloadSeg(@MakeEmptySortedSet);                     {SortedSet}
  UnloadSeg(@MakeEmptyWeightedSet);                   {WeightedSet}
  UnloadSeg(@MakeEmptyABR);                           {ArbreBinaireDeRecherche}
  {UnloadSeg(@MakeEmptyATR);}                         {ArbreTernaireDeRecherche}
  UnloadSeg(@InitUnitHashing);                        {Hashing}
  UnloadSeg(@Intersection);                           {Geometrie}
  UnloadSeg(@GeneralShellSort);						            {GeneralSort}
  
  UnloadSeg(@DoGrowWindow);
  UnloadSeg(@OuvreFntrRapport);                       {UnitRapportImplementation}
  UnloadSeg(@ActivateAscenseurListe);                 {LongintScrollerPourListe}
  UnloadSeg(@EcritListeParties);                      {Liste}
  UnloadSeg(@DoTrierListe);                           {TriListe}
  UnloadSeg(@SauvegardeListeCouranteAuNouveauFormat); {SauvegardeListeCouranteAuNouveauFormat}
  UnloadSeg(@DerouleMaster);
  UnloadSeg(@SetUp);                                  {SetUp}
  UnloadSeg(@LitFichierPreferences);
  UnloadSeg(@DoProcessPrinting);                      {Print}
  UnloadSeg(@DrawProgressBar);                        {ProgressBar}
  UnloadSeg(@DoCriteres);                             
  UnloadSeg(@DoDiagrammeFFORUM);
  UnloadSeg(@InitUnitNouveauFormat);                  {NouveauFormat}
  UnloadSeg(@SetPartieRecordParNroRefPartie);         {AccesStructuresNouvFormat}
  UnloadSeg(@TestNouveauFormat);                      {TestNouveauFormat}
  UnloadSeg(@IconiserCassio);                         {Iconisation}
  UnloadSeg(@EvaluationTore);
  UnloadSeg(@EstUnSolitaire);                         {UnitSolitaire}
  UnloadSeg(@DoJoueAuxSolitaires);                    {THOR_SOLITAIRES}
  UnloadSeg(@DoRechercheSolitaires);                  {UnitRechercheSolit}
  UnloadSeg(@MakeSolitaireRecNouveauFormat);          {UnitSolitairesNouveauFormat}
  UnloadSeg(@ClicDansOthellierLecture);               {Base}
  UnloadSeg(@ActionBaseDeDonnee);                     {Base2}
  UnloadSeg(@DoBackMove);                             {Actions}
  UnloadSeg(@DoDemo);                                 {Actions2}
  UnloadSeg(@DoPommeMenuCommands);                    {Gestion_Evenements}
  UnloadSeg(@DoSystemTask);
  UnloadSeg(@FixeMarquesSurMenus);                    {Menus}
  UnloadSeg(@JoueEn);                                 {Jeu}
  UnloadSeg(@MultiFinderEvents);
  UnloadSeg(@DessineIconesChangeantes);               {UnitOth1}
  UnloadSeg(@PrepareTexteStatePourHeure);             {UnitOth1_bis}
  UnloadSeg(@LanceDecompteDesNoeuds);                 {UnitOth2}
  UnloadSeg(@CalculeLesTraitsDeCettePartie);          {Utilitaires}
  UnloadSeg(@ConstruitTableNumeroReference);          {Utilitaires2}
  UnloadSeg(@DessineStatistiques);                    {Affichage}
  UnloadSeg(@EcritReflexion);                         {AffichageReflexion}
  UnloadSeg(@MakeBigOthelloRec);                      {OthelloGeneralise}
  UnloadSeg(@DoDiagramme10x10);                       {Diagrammes10Par10}
  
  UnloadSeg(@ABScout);
  UnloadSeg(@AB_simple);
  UnloadSeg(@ValeurBlocsDeCoinPourNoir);
  UnloadSeg(@PasDeControleDeDiagonaleEnCours);        {Strategie}
  UnloadSeg(@Superviseur);                            {Superviseur}
  UnloadSeg(@Evaluation);                             {Evaluation}
  UnloadSeg(@CalculeMeilleurCoupMilieuDePartie);      {MilieuDePartie}
  UnloadSeg(@CoupGagnant);                            {FinaleFast}
  UnloadSeg(@PeutCalculerFinaleOptimaleParOptimalite);{UtilitairesFinale}
  UnloadSeg(@InitUnitEndgameTree);                    {EndgameTree}
  UnloadSeg(@ScoreWLDPositionEtTrait);                {FinalePourPositionEtTrait}
{$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
  UnloadSeg(@SetSmartScrollInfo);                     {SmartScrollLib}
{$ENDC}
  UnloadSeg(@Parser6);                                {SNStrings}
  UnloadSeg(@SplitRightAtStr);                        {PNL Libraries}
  UnloadSeg(@InitMacintoshManagers);                  {UnitMacExtras}
  UnloadSeg(@CreeFichierTexte);                       {FichierTEXT}
  UnloadSeg(@NewEmptyZoneMemoire);                    {ZoneMemoire}
  UnloadSeg(@TesteZoneMemoire);                       {TestZoneMemoire}
  UnloadSeg(@InitUnitFormatsFichiers);                {FormatsFichiers}
  
  UnloadSeg(@ForEachSquareInSetDo);                   {SquareSet}
  UnloadSeg(@DesssinePierresDeltaCourantes);          {PierresDelta}
  UnloadSeg(@NewPropertyPtr);                         {Properties}
  UnloadSeg(@InitUnitPropertyList);                   {PropertyList}
  UnloadSeg(@TesterProperties);                       {TestProperties}
  UnloadSeg(@InitUnitGameTree);                       {GameTree}
  UnloadSeg(@InitUnitArbreDeJeuCourant);              {ArbreDeJeuCourant}
  UnloadSeg(@AfficheProprietesOfCurrentNode);         {AfficheArbreDeJeuCourant}
  UnloadSeg(@LitFormatSmartGameBoard);                {UnitSmartGameBoard}
  UnloadSeg(@DoAnalyseRetrograde);                    {Retrograde}
  UnloadSeg(@InterruptionCarPhasePartieChange);       {PhasesDeJeu}
  UnloadSeg(@TestUnitFichierPhotos);                  {FichiersPhotos}
  UnloadSeg(@InitUnit3DPovRayPict);                   {3DPovRayPicts}
  UnloadSeg(@ReadPictFile);							  {FichiersPICT}
  UnloadSeg(@InitUnitTroisiemeDimension);             {TroisiemeDimension}
  UnloadSeg(@InitUnitCassioSounds);                   {CassioSounds}
  UnloadSeg(@InitUnitMiniProfiler);                   {MiniProfiler}
  
  
  
  (*UnloadSeg(@apprendCoeffBill);     *)              {UnitBill}
  
  {$ENDC}
  
  InstalleEventHandler(TraiteOneEvenement);
  InstalleEssaieUpdateEventsWindowPlateauProc(EssaieUpdateEventsWindowPlateau);
end;


{$S BouclePrinc}

  (************ boucle principale **************)
  


procedure BouclePrincipale;
begin

  {FlushEvents(everyEvent-DiskEvt,0);}
  REPEAT    
    SetCassioChecksEvents(true);
    if globalRefreshNeeded then DoGlobalRefresh;
    if not(Quitter) then AjusteCurseur;
  
    AjusteSleep;
    if not(gameOver) & not(Quitter) then
      if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
      
    if not(Quitter | enSetUp | enRetour) then
      if (FrontWindow() = NIL) then
          begin
            DisableMenu(EditionMenu,[AnnulerCmd,CouperCmd,CopierCmd,CopierSpecialCmd,CollerCmd,EffacerCmd]);
            EnableItemPourCassio(GetFileMenu(),nouvellePartiecmd);
            MyDisableItem(GetFileMenu(),closecmd);
          end 
        else
          begin
            if not(enSetUp)
              then EnableItemPourCassio(GetFileMenu(),closecmd)
              else MyDisableItem(GetFileMenu(),closecmd);
            if not(iconisationDeCassio.Encours) then 
              EnableMenu(EditionMenu,[CouperCmd,CopierCmd,CopierSpecialCmd,CollerCmd,EffacerCmd]);
          end;
    if not(Quitter) then UnLoadTousSegments;
    SetCassioChecksEvents(true);
    if not(Quitter) then
      if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
        then TraiteEvenements
        else TraiteNullEvent(theEvent);
  
    if not(Quitter) then UnLoadTousSegments;
    if not(Quitter) then
      if interruptionReflexion <> pasdinterruption then
         EffectueTacheInterrompante(interruptionReflexion);

    if (DemandeCalculsPourBase.EtatDesCalculs=kCalculsDemandes) & not(CassioVaJouerInstantanement()) 
      then TraiteDemandeCalculsPourBase('BouclePrincipale (1)');
    
    if CassioEstEnModeAnalyse() & (aQuiDeJouer <> couleurMacintosh) & 
       not(gameOver | Quitter) & (nbreCoup>0) {& (CalculePhasePartie(nbreCoup)<=phaseMilieu)} then
      begin
        DoDemandeChangeCouleur;
        EffectueTacheInterrompante(interruptionReflexion);
      end; 
      
    {WritelnDansRapport('dans Boucle principale');}
     
    InvalidateAnalyseDeFinaleSiNecessaire(kNormal);
    
    if (interruptionReflexion <> pasdinterruption) then
      EffectueTacheInterrompante(interruptionReflexion);
    
    if interruptionReflexion = pasdinterruption then
      if not(gameOver) & not(HumCtreHum) & not(Quitter) &
         not((nbreCoup=0) & CassioEstEnModeAnalyse() & not(positionFeerique)) then
        begin
          if (aQuiDeJouer=couleurMacintosh)
            then
              begin
                if not(AttenteAnalyseDeFinaleEstActive()) then
                  begin
	                if (nbreCoup=0) & not(positionFeerique)
	                  then PremierCoupMac
	                  else JeuMac(level,'BouclePrincipale (1)');
	              end;
                {if not(Quitter) then UnLoadTousSegments;}
                if (interruptionReflexion <> pasdinterruption) & not(Quitter) then
                  EffectueTacheInterrompante(interruptionReflexion);
                vaDepasserTemps := false;
              end
            else
              begin
                if not(sansReflexionSurTempsAdverse | CassioEstEnModeAnalyse()) then
                  if not(reponsePrete) & (nbreCoup>=1)
                    then
                      begin
                       JeuMac(level,'BouclePrincipale(2)');
                       {if not(Quitter) then UnLoadTousSegments;}
                       if (interruptionReflexion <> pasdinterruption) & not(Quitter) then
                         EffectueTacheInterrompante(interruptionReflexion);
                       vaDepasserTemps := false;
                      end;
                 {if not(Quitter) then UnLoadTousSegments;}
                 if (interruptionReflexion <> pasdinterruption) & not(Quitter) then
                   EffectueTacheInterrompante(interruptionReflexion);
              end;
        end;  
    
    if (interruptionReflexion <> pasdinterruption) & not(Quitter) then
      EffectueTacheInterrompante(interruptionReflexion);
     
  UNTIL Quitter;  
  SetCassioChecksEvents(true);
end;


{$IFC NOT GENERATINGPOWERPC}
procedure ExecuteOrdresFinder;
var message,count : SInt16; 
    theFile:AppFile;
    erreur : OSErr;
begin
  CountAppFiles(message,count);
  if count>0 then
    begin
      GetAppFiles(1,theFile);
      if message=appOpen then
        begin
          erreur := SetVol(NIL,theFile.vRefNum);
          erreur := OuvrirFichierPartieFormatCassio(theFile.fname,false);
        end;
      clrAppFiles(1);
    end;
end;
{$ENDC}

{$IFC GENERATINGPOWERPC}
procedure ExecuteOrdresFinder;
begin
end;
{$ENDC}


procedure Ecrit_taille_structures;
type t_buffer = packed array[1..260] of t_Octet;
begin
  EssaieSetPortWindowPlateau;
  WriteStringAndNumAt('sizeof(t_octet)=',sizeof(t_octet),10,10);
  WriteStringAndNumAt('sizeof(DeuxOctets)=',sizeof(DeuxOctets),10,20);
  WriteStringAndNumAt('sizeof(t_buffer)=',sizeof(t_buffer),10,30);
  WriteStringAndNumAt('sizeof(t_partieDansThorDBA)=',sizeof(t_partieDansThorDBA),10,40);
  
  AttendFrappeClavier;
end;

procedure DessinePaletteDeCouleurs;
var i,j : SInt16; 
    coul : array[1..8] of SInt16;
begin
  EssaieSetPortWindowPlateau;
  
  gCouleurOthellier.whichPattern := grayPattern;
  coul[1] := MagentaColor;
  coul[2] := RedColor;
  coul[3] := YellowColor;
  coul[4] := GreenColor;
  coul[5] := CyanColor;
  coul[6] := BlueColor;
  coul[7] := blackColor;
  coul[8] := WhiteColor;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        gCouleurOthellier.couleurFront := coul[i];
        gCouleurOthellier.couleurBack := coul[j];
        DessinePion2D(10*i+j,pionVide);
      end;
  DetermineFrontAndBackColor(gCouleurOthellier.menuCmd,gCouleurOthellier.couleurFront,gCouleurOthellier.couleurBack);
end;
 
 
 procedure TesterConvergenceDesFlottants;
 var u : extended;
     n : SInt32;
 begin
   n := 0;

   u := 3.0;
   for n := 0 to 100 do
     begin
       WritelnStringAndReelDansRapport('u'+NumEnString(n)+' = ',u, 14);
       u := -3.0*u*u/8.0 + 9.0*u/4.0 - 3.0/8.0;
     end;

   u := 1.0/3.0;
   for n := 0 to 100 do
     begin
       WritelnStringAndReelDansRapport('u'+NumEnString(n)+' = ',u, 14);
       u := -3.0*u*u/8.0 + 9.0*u/4.0 - 3.0/8.0;
     end;
  
  u := 3.0;
   for n := 0 to 100 do
     begin
       WritelnStringAndReelDansRapport('u'+NumEnString(n)+' = ',u, 14);
       u := -4.0*u*u/9.0 + 26.0*u/9.0 - 4.0/9.0;
     end;

   u := 1.0/3.1;
   for n := 0 to 100 do
     begin
       WritelnStringAndReelDansRapport('u'+NumEnString(n)+' = ',u, 14);
       u := -4.0*u*u/9.0 + 26.0*u/9.0 - 4.0/9.0;
     end;

 end;



var i_main,gestalt_aux : SInt32;
    erreurES_main : OSErr;
    OSStatus_main : OSStatus;
    {i_main2 : SInt32;
    confiance : extended;
    s : str255;
    s_main : str255;}
    {packedPosMain:PackedOthelloPosition;
    plMain : plateauOthello;}
begin 

  SetTracingLog(true);

  debuggage.general := false;
  debuggage.afficheSuiteInitialisations := false;
  nbreDebugage := 0;
  gPendantLesInitialisationsDeCassio := true;
  
  {$IFC CARBONISATION_DE_CASSIO}
  WaitNextEventImplemented := true;
  GestaltImplemented       := true;
{$ELSEC}
  WaitNextEventImplemented := TrapExists(_WaitNextEvent);
  GestaltImplemented       := TrapExists(_Gestalt);
{$ENDC}

  if not(GestaltImplemented)
    then gIsRunningUnderMacOSX := false
    else gIsRunningUnderMacOSX := (Gestalt(gestaltMenuMgrAttr,gestalt_aux) = NoErr) &
                                  (BitAnd(gestalt_aux,gestaltMenuMgrAquaLayoutMask) <> 0); 


if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant DescendLimiteStack');

 {$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
  DescendLimiteStack;
  MaxApplZone;
 {$ENDC}

if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitMacintoshManagers');

  InitMacintoshManagers;
  GetClassicalFontsID;
  OSStatus_main := RegisterAppearanceClient; 
 

if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant WaitNextEvent');

  ShareTimeWithOtherProcesses(1);
  
if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitMacExtras');

  InitUnitMacExtras(false);
  InitUnitAppleEventsCassio;
  InitUnitOth2;
  
  InitUnitNewGeneral;
  InitUnitCreateBitboardCode;
  InitUnitHashTableExacte;
  InitUnitHashing;
  InitSNStrings;
  InitUnitPostscript;
  InitUnitJaponais;
  InitUnitFormatsFichiers;
  
  

if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitTroisiemeDimension');

  InitUnitGestionDuTemps;
  InitUnitTroisiemeDimension;
  InitUnitMoveRecords;
  InitUnitSuperviseur;
  InitUnitCouleur;
  InitUnitProgressBar;
  InitUnitOth1;
  InitUnitCassioSounds;
  InitUnitRetrograde;
  InitUnitProblemeDePriseDeCoin;
  
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitJeu');
  
  InitUnitJeu;
  InitUnitNouvelleEval;
  InitUnitChi2NouvelleEval;
  InitUnitVecteurEval;
  InitUnitVecteurEvalInteger;
  InitUnitSymmetricalMapping;
  InitUnitProbCutValues;
  InitUnitPotentiels;
  
  
  
  InitUnitPagesDeABR;
  InitUnitPagesDeATR;
  InitUnitInterversions;
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant CurResFile()');
  
  CassioResFile := CurResFile();
  volumeRefCassio := DetermineVolumeApplication();
  pathCassioFolder := GetWDName(volumeRefCassio);
  pathDossierFichiersAuxiliaires := DeterminePathDossierFichiersAuxiliaires(volumeRefCassio);
  
  
(* initialisation de l'unite UnitFichiersTEXT et des handlers associes *)
  InitUnitFichierTexte;
  InstalleMessageDisplayerFichierTexte(WritelnDansRapportOuvert);
  InstalleMessageAndNumDisplayerFichierTexte(WritelnStringAndNumDansRapportOuvert);
  InstalleAlerteFichierTexte(AlerteSimpleFichierTexte);
  
  {TraceLog('*****************************');}
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitProperties');
  
  InitUnitProperties;
  InitUnitPropertyList;
  InitUnitGameTree;
  InitUnitArbreDeJeuCourant;
  InitUnitAfficheArbreJeuCourant;
  InitUnitDefinitionsSmartGameBoard;
  InitUnitSmartGameBoard;
  
  InitUnitRapport;
  InitUnitBufferedPICT;
  InitUnitLiveUndo;
  
  InitUnitAccesGrapheApprentissage;
  InitUnitCalculsApprentissage;
  InitUnitUtilitairesFinale;
  InitUnitEndgameTree;
  InitUnitApprentissageInterversion;
  InitUnitVariablesGlobalesFinale;
  InitUnitFichierPhotos;
  InitUnit3DPovRayPict;
  InitUnitGenericGameFormat;
  InitUnitSaisiePartie;
  InitUnitNotesSurCases;
  InitUnitMiniProfiler;
  InitUnitListeChaineeCasesVides;
  InitUnitSelectionRapideListe;
  InitUnitListe;
  InitUnit_AB_Scout;
  InitUnitScripts;
  InitUnitDemo;
  InitUnitEntreeTranscript;
  InitUnitBitboardHash;
  InitUnitZebraBook;
  InitUnitImportDesNoms;
  InitUnitVieilOthelliste;
  InitUnitCourbe;
  
  UnLoadTousSegments;
  
  
  
  {This next bit of code waits until MultiFinder brings our application
		to the front. This gives us a better effect if we open a window at
		startup.}
{ for i_main := 1 to 4 do bidbool := EventAvail(everyEvent, theEvent);  }
  UnLoadTousSegments;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitDialogUnit');
  InitDialogUnit;
  UnLoadTousSegments;
  
  
  
  UnLoadTousSegments;
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitUtilitaires');
  InitUnitUtilitaires;
  UnLoadTousSegments;


  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant moremasters');
  UnLoadTousSegments;
  For i_main := 1 to 21 do MoreMasterPointers(64);
  UnLoadTousSegments;
  (* AlloueMemoireBill; *)
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant AlloueMemoireImpression()');
  erreurES_main := AlloueMemoireImpression();
  UnLoadTousSegments;
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitNouveauFormat()');
  InitUnitNouveauFormat;
  UnLoadTousSegments;
  
  
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant AlloueMemoireNouvelleEvaluation');
  
  
  
 {si l'on veut calculer une nouvelle eval}
 {AlloueMemoireNouvelleEvaluation(true,true,false,true,true,false);
  AlloueMemoireSymmetricalMapping;}
    
 {si l'on veut calculer une nouvelle eval,avec les tris}
 {AlloueMemoireNouvelleEvaluation(true,true,false,true,true,true);
  AlloueMemoireSymmetricalMapping;}
  
  
 {si l'on veut seulement jouer,sans les flottants}
 if FichierEvaluationDeCassioTrouvable('Evaluation de Cassio')
    then AlloueMemoireNouvelleEvaluation(false,false,true,false,false,false);
  
 
  
 {si l'on veut seulement jouer, avec les flottants}
 {AlloueMemoireNouvelleEvaluation(false,true,true,false,false,false);}
 
 {si l'on veut seulement jouer, avec les flottants et les occurences}
 {AlloueMemoireNouvelleEvaluation(true,true,true,false,false,false);}
  
 {si l'on veut seulement jouer, avec les flottants et les occurences et les stats}
 {AlloueMemoireNouvelleEvaluation(true,true,true,false,false,true);}
  
  UnLoadTousSegments;
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant NewGeneral');
  NewGeneral;
  UnLoadTousSegments;
  
  
 
  erreurES_main := AllocateMemoireListePartieNouveauFormat(nbrePartiesEnMemoire);
  
  
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('erreurES_main='+NumEnString(erreurES_main));
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('nbrePartiesEnMemoire='+NumEnString(nbrePartiesEnMemoire));
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('PartiesNouveauFormat.nbPartiesEnMemoire='+NumEnString(PartiesNouveauFormat.nbPartiesEnMemoire));

  UnLoadTousSegments;
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant verificationNewGeneral');
  VerificationNewGeneral;
  UnLoadTousSegments;
  

  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant initialisation');
 (********************* initialisation est ici **************)
  Initialisation; 
 (********************* initialisation est ici **************)
 

  
  debuggage.afficheSuiteInitialisations := false;
   
  
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant UnLoadTousSegments');
  
  
  UnLoadTousSegments;
  InitValeursBlocsDeCoin;
  UnLoadTousSegments;
  InitialiseModeleLineaireValeursPotables;
  Initialise_valeurs_bords(-0.5); 
  Initialise_turbulence_bords(true);
  VideStatistiquesDeBordsABLocal(essai_bord_AB_local);
  VideStatistiquesDeBordsABLocal(coupure_bord_AB_local);
  UnLoadTousSegments;
  
  
  UnLoadTousSegments;
  
  
  Initialise_interversions;
  UnLoadTousSegments;
  
  
 {DoRechercheSolitaires(0,3248);}
 
  
 
  UnLoadTousSegments;
  AjusteCurseur;
  UnLoadTousSegments;
  
  
  EnableItemTousMenus;
  FixeMarquesSurMenus;
  FixeMarqueSurMenuBase;
  FixeMarqueSurMenuMode(nbreCoup);
  SetMenusChangeant(0);
  
  UnLoadTousSegments;
  EnableKeyboardScriptSwitch;
  
  UnLoadTousSegments;
  
  if not(GetNouvelleEvalDejaChargee()) then
    EssayerLireFichiersEvaluationDeCassio;
  
  ExecuteOrdresFinder;
  
  {if (ProfondeurMainDevice() >= 8) then
    DoCampFire;}
  
  {DoDemo(6,6,false,false);}
  {TestMyEndGame;}
  {DessinePaletteDeCouleurs;
   AttendFrappeClavier;}
  {TestNouveauFormat;}
  {TesterProperties;}
  {TesteZoneMemoire;}
  {TestUnitFichierPhotos;}
  {TestMinimisation;}
  {TestNouvelleEval;}
  {for i_main := 1 to 10 do
    TestStraightLineFitting;}
  {TestApprentissage;}
  {TestPilesEtFiles;}
  {TestWeightedSet;}
  
  
  {
  s := 'F5D6C3D3C4';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  
  s := 'F5 D6 C3 D3 C4';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  
  s := '  • F5 d6•6 c3 D3 t4 c4 ';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  
  s := ' F5 2d6 3c3 4D3 5c4 ';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  }
  
  {
  s := ' 1.f4 D3 3.c4   ';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthelloAvecMiroir(s));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthelloAvecMiroir(s));
  }
  
  
  {TestUnitABR;}
  {TestPositionEtTraitSet;}
  {BibliothequeDansRapport;}
  {RejoueToutesLignesBibliothequeAvecCommentaire;}
  {TestUnitInterversions;}
  {TestUnitHashing;}
  {TestStringSet;}
  
  {TestUnitInterversions;}
  
  
  {
  i_main := Command_line_param_count();
  WritelnStringAndNumDansRapport('Command_line_param_count() = ',i_main);
  s_main := Get_command_line(Get_program_name());
  WritelnDansRapport('Get_command_line() = '+s_main);
  for i_main := 0 to Command_line_param_count() do
    begin
      s_main := Get_command_line_parameter(i_main);
      WritelnStringAndNumDansRapport(s_main+'    <== ',i_main);
    end;
  }
  
 (*
 for i_main := 1 to 60 do
   begin
     erreurES_main := CreerFichierSolitaireVideNouveauFormat(i_main);
     WritelnStringAndNumDansRapport('erreurES['+NumEnString(i_main)+']=',erreurES_main);
   end;
 *) 
 
 (*
 WritelnStringAndNumDansRapport('sizeof(PackedOthelloPosition)=',sizeof(PackedOthelloPosition));
 packedPosMain := PlOthToPackedOthelloPosition(jeuCourant);
 plMain := PackedOthelloPositionToPlOth(packedPosMain);
 WritelnPositionEtTraitDansRapport(plMain,pionNoir);
 *)
  
 {SetEcritToutDansRapportLog(true);}
 {SetAutoVidageDuRapport(true);}
 {EtalonnageVitesseMac(true);}
 {TestNouvelleEval;} 
 {CreateJansEndgameCode(false);}
 {TestUnitATR;}
  
 {WritelnDansRapport('Hexa(nbElementsTableHashageInterversions-1) = '+Hexa(65536-1));}
 {WritelnDansRapport('Hexa(BNOT($00000007)) = '+Hexa(BNOT($00000007)));}
 {TestStabiliteBitboard;}
 {WritelnStringAndNumDansRapport('sizeof( : t_EnTeteNouveauFormat) = ',sizeof( : t_EnTeteNouveauFormat));}
 
 {
 DoLectureJoueursEtTournoi(false);
 if TrouverNomsDesJoueursDansNomDeFichier('Murakami 32-32 Tamenori.wzg',i_main,i_main2,0,confiance) then
   begin
     WriteStringAndReelDansRapport('TROUVE NOMS, confiance = ',confiance,5);
     WritelnDansRapport('');
   end;
 if TrouverNomsDesJoueursDansNomDeFichier('06-Hubbard36-28Cordy.wzg',i_main,i_main2,0,confiance) then
   begin
     WriteStringAndReelDansRapport('TROUVE NOMS, confiance = ',confiance,5);
     WritelnDansRapport('');
   end;
 if TrouverNomsDesJoueursDansNomDeFichier('Edax (Delorme) 30-34 Cassio (coucou)',i_main,i_main2,0,confiance) then
   begin
     WriteStringAndReelDansRapport('TROUVE NOMS, confiance = ',confiance,5);
     WritelnDansRapport('');
   end;
 if TrouverNomsDesJoueursDansNomDeFichier('Cassio (Nicolet) 30-34 ???',i_main,i_main2,0,confiance) then
   begin
     WriteStringAndReelDansRapport('TROUVE NOMS, confiance = ',confiance,5);
     WritelnDansRapport('');
   end;
 s := '06-Hubbard39-W[C5];B[E6];F5C4D3-25Cordy.wzg';
 if TrouverPartieEtJoueursDansChaine(s,s_main,i_main,i_main2,confiance) then
   begin
     WriteStringAndReelDansRapport('TROUVE PARTIE ET NOMS, confiance = ',confiance,5);
     WritelnDansRapport('');
   end;
 }
 
 {ImporterToutesPartiesRepertoire;}
   
 {ComparerFormatThorEtFormatSuedois('8.#BAJ/"$%9&CDKTL?UVSR5I+@:0M !4*=)3>GNXWQH',
                                   'ongZflephcvamksuw2x5idqVjrXPUWTYQb43yKSMCLFDEJRBNG67zt01HOAI');}
 {LecturePreparatoireDossierDatabase(volumeRefCassio);}
 {ProcessEachSolitaireOnDisc(0,100);}
 
  
 {AlignerTestsFinales(61,68,ReflGagnant,ReflGagnant);}
 {AlignerTestsFinales(60,60,ReflParfait,ReflParfait);}
 {AlignerTestsFinales(15,15,ReflGagnantExhaustif,ReflGagnantExhaustif);}
 {AlignerTestsFinales(60,68,ReflParfaitExhaustif,ReflParfaitExhaustif);}
 {AlignerTestsFinales(40,60,ReflGagnantExhaustif,ReflGagnantExhaustif);}
 {AlignerTestsFinales(10,68,ReflParfaitExhaustif,ReflParfaitExhaustif);}
 
 {WritelnStringAndNumDansRapport('GetEspaceDisponibleLancementCassio = ',GetEspaceDisponibleLancementCassio());}
 if CassioEnEnvironnementMemoireLimite() then
   begin
     WritelnDansRapport('Pas beaucoup de mémoire : je passe en mode "light"');
     WritelnDansRapport('');
   end;
 
 {$IFC GENERATINGPOWERPC}
 {TestRapiditeBitboard64Bits;}
 {WritelnStringAndNumDansRapport('__cntlzw(5) = ',__cntlzw(5));}
 {$ENDC}
  
 gPendantLesInitialisationsDeCassio := false;
 
 {if not(gIsRunningUnderMacOSX) then AfficheMemoire;}
 
 {DrawImagetteMeteoOnSquare(kAlertBig,23);}
 {VerifierLeCompilateur;}
 
 {TesterConvergenceDesFlottants;}
 
 
     
(************************************************************)
(************************************************************)

  BouclePrincipale;

(************************************************************)
(************************************************************)
  
  Quitter := true;
  
  watch := GetCursor(watchcursor);
  InitCursor;
  
  
  MasquerToutesLesFenetres;
  InitCursor;
  
  UnLoadTousSegments;
  if ListeDesGroupesModifiee then CreeFichierGroupes;
  if (ChoixDistributions.genre <> kToutesLesDistributions) &
     (InfosFichiersNouveauFormat.nbFichiers <= 0) then
    LecturePreparatoireDossierDatabase(volumeRefCassio);
  InitCursor;
  GereSauvegardePreferences;
  if DoitEcrireInterversions then EcritInterversionsSurDisque;
  
  {EcritCalculBlocsDeCoinSurDisque;}
  {EcritTablesBlocsDeCoinSurDisque('blocs');}
  
  InitCursor;
  FermeToutEtQuitte;
  InitCursor;
  UnLoadTousSegments;
  
  if DetruitRapport() then;
  if LibereMemoireIconisation() then;
  DisposeGeneral;
  LibereMemoireUnitCourbe;
  LibereMemoireUnitMiniProfiler;
  LibereMemoireUnitNotesSurCases;
  LibereMemoireUnitTroisiemeDimension;
  LibereMemoireUnitApprentissageInterversion;
  LibereMemoireUnitProbCutValues;
  LibereMemoireNouvelleEvaluation;
  LibereMemoireDialogUnit;
  LibereMemoireUnitUtilitaires;
  LibereMemoireUnitNouveauFormat;
  LibereMemoireUnitProperties;
  LibereMemoireUnitPropertyList;
  LibereMemoireUnitGameTree;
  LibereMemoireUnitArbreDeJeuCourant;
  LibereMemoireUnitAfficheArbreJeuCourant;
  LibereMemoireUnitDefinitionsSmartGameBoard;
  LibereMemoireUnitSmartGameBoard;
  LibereMemoireUnitBufferedPICT;
  LibereMemoireUnitLiveUndo;
  LibereMemoireUnitJaponais;
  LibereMemoireUnitMoveRecords;
  LibereMemoireUnitProblemeDePriseDeCoin;
  LibereMemoireUnitFichierPhotos;
  LibereMemoireUnit2DPovRayPicts;
  LibereMemoireUnitCassioSounds;
  LibereMemoireFormatsFichiers;
  LibereMemoireUnitSaisiePartie;
  LibereMemoireUnitHashTableExacte;
  LibereMemoireUnitNewGeneral;
  LibereMemoireUnitAccesGrapheApprentissage;
  LibereMemoireUnitSelectionRapideListe;
  LibereMemoireUnitListe;
  LibereMemoireUnit_AB_SCout;
  LibereMemoireUnitPrint;
  LibereMemoireUnitScripts;
  LibereMemoireUnitDemo;
  LibereMemoireUnitEntreeTranscript;
  LibereMemoireUnitBitboardHash;
  LibereMemoireImportDesNoms;
  LibereMemoireVieilOthelliste;
  LibereMemoireGestionDuTemps;
  
  
  (* LibereMemoireBill; *)
  RemonteLimiteStack;
  UnLoadTousSegments;
  FlushEvents(everyEvent-DiskEvt,0);
  SwitchToScript(gLastScriptUsedOutsideCassio);
  

 
  ExitToShell;
end.

{ TODO & FIXME :

  0) aucun pour le moment...
}


{ BUGS a verifier avant de complier avec CodeWarrior 8 Pascal:
 
 1) packed array of boolean
 2) valeur in set (pour des valeurs immediates seulement ?)
 3) reconstruire la librairie Pascal avec alignement PowerPC ?
 4) autres ?
}
