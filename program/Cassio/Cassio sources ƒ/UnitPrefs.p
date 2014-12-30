UNIT UnitPrefs;






INTERFACE







 USES MacTypes,QuickDraw;





procedure NumEnStringFormatee(num : SInt32;formatage : SInt16; var s : str255);
function StringFormateeEnNumFromPos(formatage : SInt16; s : str255;index : SInt16) : SInt32;
function StringFormateeEnNum(formatage : SInt16; var s : str255) : SInt32;
function FenetreEnChaine(ouverte : boolean;theWindow : WindowPtr;unRect : rect) : str255;
procedure ChaineEnFenetre(s : str255; var ouverte : boolean; var RectangleFenetre : rect);
procedure ChaineEnRect(s : str255; var UnBool : boolean; var Rectangle : rect);


procedure CreeFichierPreferences;
procedure LitFichierPreferences;
procedure GetPartiesAReouvrirFromPrefsFile;
procedure GereSauvegardePreferences;


function NameOfPrefsFile() : str255;
procedure SauvegarderListeOfPrefsFiles;
procedure LireListeOfPrefsFiles;
procedure AjouterNomDansListOfPrefsFiles(whichName : str255);


procedure DoDialoguePreferences;
procedure DoDialoguePreferencesAffichage;
procedure DoDialoguePreferencesSpeciales;

procedure CreeFichierGroupes;
procedure LitFichierGroupes;


function OpenPrefsFileForSequentialReading() : OSErr; 
function GetNextLineInPrefsFile(var s : str255) : OSErr; 
function EOFInPrefsFile() : boolean;
function ClosePrefsFile() : OSErr; 


IMPLEMENTATION







USES UnitUtilitaires,UnitRapport,UnitTroisiemeDimension,UnitNotesSurCases,UnitRapportImplementation,UnitBufferedPICT,
     UnitFenetres,UnitScannerOthellistique,Zebra_to_Cassio,UnitActions,UnitAfficheArbreDeJeuCourant,UnitArbreDeJeuCourant,UnitNewGeneral,
     UnitJaponais,UnitOth0,UnitGestionDuTemps,SNStrings,UnitDefinitionsNouveauFormat,UnitFichiersTEXT,UnitMenus,
     UnitFichierPhotos,UnitMacExtras,UnitSaisiePartie,MyStrings,UnitEntreeTranscript,UnitDialog,UnitNouveauFormat,
     UnitVieilOthelliste,UnitOth1,UnitNormalisation,UnitCouleur,UnitListe,UnitJeu,UnitProblemeDePriseDeCoin;



const kMaxPrefFiles = 10;
const kNomParDefauFichierPreferences = 'Préférences Cassio';

var gPrefsFileInfos : record
                       filePtr : FichierTEXT;
                       nbOfLastLineRead : SInt16; 
                       lastLineRead : str255;
                      end;
    
    gListeOfPrefFiles : array[1..kMaxPrefFiles] of 
                          record
                            date,name : str255;
                          end;

procedure NumEnStringFormatee(num : SInt32;formatage : SInt16; var s : str255);
var s1 : str255;
    longueur,i : SInt16; 
    aux : SInt32;
begin
  s1 := '';
  aux := num;
  NumToString(aux,s1);
  longueur := Length(s1);
  if longueur>formatage then {erreur de formatage ! On n'a pas prevu assez de place pour cette valeur…}
    begin
      s1 := '';
      longueur := 0;
    end;
  for i := 1 to formatage-longueur do s1 := StringOf('0')+s1;
  s := Concat(s,s1);
end;


function StringFormateeEnNumFromPos(formatage : SInt16; s : str255;index : SInt16) : SInt32;
var s1 : str255;
    i : SInt16; 
    aux : SInt32;
begin
  s1 := '';
  for i := index to index+formatage-1 do s1 := s1+s[i];
  for i := 1 to Length(s1)-1 do
    if s1[1]='0' then s1 := TPCopy(s1,2,Length(s1)-1);
  StringToNum(s1,aux);
  StringFormateeEnNumFromPos := aux;
end;


function StringFormateeEnNum(formatage : SInt16; var s : str255) : SInt32;
begin
  StringFormateeEnNum := StringFormateeEnNumFromPos(formatage,s,1);
  s := TPCopy(s,formatage+1,Length(s)-formatage);
end;



function FenetreEnChaine(ouverte : boolean;theWindow : WindowPtr;unRect : rect) : str255;
var s1 : str255;
    oldPort : grafPtr;
begin
  s1 := '';
  if ouverte then s1 := s1+StringOf('Y') else s1 := s1+StringOf('N');
  if ouverte and (theWindow <> NIL) then   {si la fenetre est ouverte,mettre à jour son rectangle }
    begin
      GetPort(oldPort);
      SetPortByWindow(theWindow);
      unRect := GetWindowPortRect(theWindow);
      LocalToGlobal(unRect.topleft);
      LocalToGlobal(unRect.botright);
      SetPort(oldPort);
    end;
  NumEnStringFormatee(unRect.left,4,s1);
  NumEnStringFormatee(unRect.top,4,s1);
  NumEnStringFormatee(unRect.right,4,s1);
  NumEnStringFormatee(unRect.bottom,4,s1);
  FenetreEnChaine := s1;
end;


procedure ChaineEnFenetre(s : str255; var ouverte : boolean; var RectangleFenetre : rect);
var unRect : rect;
    rectangleOK : boolean;
begin
  ouverte := s[1]='Y';
  unRect.left := StringFormateeEnNumFromPos(4,s,2);
  unRect.top := StringFormateeEnNumFromPos(4,s,6);
  unRect.right := StringFormateeEnNumFromPos(4,s,10);
  unRect.bottom := StringFormateeEnNumFromPos(4,s,14);
  if unRect.right<unRect.left then unRect.right := unRect.left+40;
  if unRect.bottom<unRect.top then unRect.bottom := unRect.top+40;
  {if debuggage.general then
   with unRect do
    begin
      Writestringandbooleanat('ouverte : ', (s[1]='Y'),10,10);
      WriteStringAndNumAt('top=',top,10,30);
      WriteStringAndNumAt('left=',left,10,20);
      WriteStringAndNumAt('bottom=',bottom,10,50);
      WriteStringAndNumAt('right=',right,10,40);
      WriteStringAndNumAt('marge haut=',top-GetScreenBounds().top,10,100);
      WriteStringAndNumAt('marge gauche=',left-GetScreenBounds().left,10,90);
      WriteStringAndNumAt('marge bas=',GetScreenBounds().bottom-top,10,120);
      WriteStringAndNumAt('marge droite=',GetScreenBounds().right-left,10,110);
      SysBeep(0);
      AttendFrappeClavier;
    end;
  }
  rectangleOK := unRect.top>21;
  rectangleOK := rectangleOK and (unRect.right-unRect.left>=20) and (unRect.bottom-unRect.top>=20);
  with GetScreenBounds() do
    begin
      rectangleOK := rectangleOK and (unRect.left <= right-15) and (unRect.top <= bottom-15);
      rectangleOK := rectangleOK and (unRect.right > 0) and (unRect.bottom > 20);
    end;
  if rectangleOK then RectangleFenetre := unRect;
end;


procedure ChaineEnRect(s : str255; var UnBool : boolean; var Rectangle : rect);
var unRect : rect;
begin
  UnBool := s[1]='Y';
  unRect.left := StringFormateeEnNumFromPos(4,s,2);
  unRect.top := StringFormateeEnNumFromPos(4,s,6);
  unRect.right := StringFormateeEnNumFromPos(4,s,10);
  unRect.bottom := StringFormateeEnNumFromPos(4,s,14);
  if unRect.right<unRect.left then unRect.right := unRect.left+40;
  if unRect.bottom<unRect.top then unRect.bottom := unRect.top+40;
  {if debuggage.general then
   with unRect do
    begin
      Writestringandbooleanat('ouverte : ', (s[1]='Y'),10,10);
      WriteStringAndNumAt('top=',top,10,30);
      WriteStringAndNumAt('left=',left,10,20);
      WriteStringAndNumAt('bottom=',bottom,10,50);
      WriteStringAndNumAt('right=',right,10,40);
      WriteStringAndNumAt('marge haut=',top-GetScreenBounds().top,10,100);
      WriteStringAndNumAt('marge gauche=',left-GetScreenBounds().left,10,90);
      WriteStringAndNumAt('marge bas=',GetScreenBounds().bottom-top,10,120);
      WriteStringAndNumAt('marge droite=',GetScreenBounds().right-left,10,110);
      SysBeep(0);
      AttendFrappeClavier;
    end;
  }
  Rectangle := unRect;
end;


procedure ParamDiagRecEnChaine(paramDiag:ParamDiagRec; var s : str255);
var aux : SInt16; 
begin
  s := '';
  with paramDiag do
    begin
      if CoordonneesFFORUM          then s := Concat(s,'Y') else s := Concat(s,'N');
      if PionsEnDedansFFORUM        then s := Concat(s,'Y') else s := Concat(s,'N');
      if DessineCoinsDuCarreFFORUM  then s := Concat(s,'Y') else s := Concat(s,'N');
      if TraitsFinsFFORUM           then s := Concat(s,'Y') else s := Concat(s,'N');
      if EcritApres37c7FFORUM       then s := Concat(s,'Y') else s := Concat(s,'N');
      if EcritNomsJoueursFFORUM     then s := Concat(s,'Y') else s := Concat(s,'N');
      if EcritNomTournoiFFORUM      then s := Concat(s,'Y') else s := Concat(s,'N');
      if NumerosSeulementFFORUM     then s := Concat(s,'Y') else s := Concat(s,'N');
      s := Concat(s,'&');   {ou n'importe quoi, unused }
      NumEnStringFormatee(DecalageHorFFORUM,5,s);
      NumEnStringFormatee(DecalageVertFFORUM,5,s);
      NumEnStringFormatee(tailleCaseFFORUM,5,s);
      NumEnStringFormatee(RoundToL(epaisseurCadreFFORUM*100),5,s);
      NumEnStringFormatee(distanceCadreFFORUM,5,s);
      NumEnStringFormatee(nbPixelDedansFFORUM,5,s);
      NumEnStringFormatee(PoliceFFORUMID,5,s);
      NumEnStringFormatee(TypeDiagrammeFFORUM,5,s);
      NumEnStringFormatee(FondOthellierPatternFFORUM,5,s);
      NumEnStringFormatee(CouleurOthellierFFORUM,5,s);
      if DessinePierresDeltaFFORUM then s := Concat(s,'Y') else s := Concat(s,'N');
      for aux := 0 to 7 do
        s := Concat(s,GainTheoriqueFFORUM[aux]);
    end;
end;


procedure ChaineEnParamDiagRec(s : str255; var paramDiag:ParamDiagRec);
var aux : SInt32;
begin
  with paramDiag do
    begin
      CoordonneesFFORUM         := s[1]='Y';
      PionsEnDedansFFORUM       := s[2]='Y';
      DessineCoinsDuCarreFFORUM := s[3]='Y';
      TraitsFinsFFORUM          := s[4]='Y';
      EcritApres37c7FFORUM      := s[5]='Y';
      EcritNomsJoueursFFORUM    := s[6]='Y';
      EcritNomTournoiFFORUM     := s[7]='Y';
      NumerosSeulementFFORUM    := s[8]='Y';
      {GainTheoriqueFFORUM       := s[9];}    {deprecated, see below}
      DecalageHorFFORUM          := StringFormateeEnNumFromPos(5,s,10);
      DecalageVertFFORUM         := StringFormateeEnNumFromPos(5,s,15);
      tailleCaseFFORUM           := StringFormateeEnNumFromPos(5,s,20);
      aux := StringFormateeEnNumFromPos(5,s,25);
      if aux<=5  
        then epaisseurCadreFFORUM := (aux*1.0)  {ca vient sans doute d'un ancien format des préférences}
        else epaisseurCadreFFORUM := (aux/100.0);
      distanceCadreFFORUM        := StringFormateeEnNumFromPos(5,s,30);
      nbPixelDedansFFORUM        := StringFormateeEnNumFromPos(5,s,35);
      PoliceFFORUMID             := StringFormateeEnNumFromPos(5,s,40);
      TypeDiagrammeFFORUM        := StringFormateeEnNumFromPos(5,s,45);
      FondOthellierPatternFFORUM := StringFormateeEnNumFromPos(5,s,50);
      CouleurOthellierFFORUM     := StringFormateeEnNumFromPos(5,s,55);
      DessinePierresDeltaFFORUM  := s[60]='Y';
      for aux := 0 to 7 do
        GainTheoriqueFFORUM[aux] := s[61+aux];
    end;
end;


procedure DecodeChaineSolitairesDemandes(s1 : str255);
var i,len : SInt32;
begin
  len := Length(s1);
  for i := 1 to 64 do
    if len >= i then SolitairesDemandes[i] :=   (s1[i]='Y');
end;

function CodeChaineSolitairesDemandes() : str255;
var s : str255;
    i : SInt32;
begin
  s:= '';
  for i := 1 to 64 do
    if SolitairesDemandes[i] 
      then s := s + 'Y'  
      else s := s + 'N';
  CodeChaineSolitairesDemandes := s;
end;




procedure CodeChainePref(var s1,s2 : str255);
var bidbool : boolean;
begin
    begin
      s1 := '';
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if EnVieille3D()                                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if OthelloTorique                                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecSon                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecProgrammation                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if gEcranCouleur                                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if OrdreDuTriRenverse                             then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheBibl                                    then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.general                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheNumeroCoup                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheSuggestionDeCassio                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheMeilleureSuite                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecEvaluationTotale                           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool(*avecDessinCoupEnTete*)                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if referencesCompletes                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if PionClignotant                                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if LectureAntichronologique                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if decrementetemps                                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if SupprimerLesEffetsDeZoom                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if OptimisePourKaleidoscope                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if affichageReflexion.doitAfficher                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheGestionTemps                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if jeuInstantane                                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecSauvegardePref                             then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecAlerteNouvInterversion                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecSystemeCoordonnees                         then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if ToujoursIndexerBase                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecSelectivite                                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecNomOuvertures                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if neJamaisTomber                                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if doitConfirmerQuitter                           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecTestBibliotheque                           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if InfosTechniquesDansRapport                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheInfosApprentissage                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if UtiliseGrapheApprentissage                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if LaDemoApprend                                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      with gEntrainementOuvertures do begin
      if CassioVarieSesCoups                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if CassioSeContenteDeLaNulle                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N'); 
      end; {with gEntrainementOuvertures}
      if analyseRetrograde.doitConfirmerArret           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if AuMoinsUneFelicitation                         then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecRefutationsDansRapport                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if enModeIOS                                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if sousEmulatorSousPC                             then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if affichePierresDelta                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecEvaluationTablesDeCoins                    then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetDebuggageUnitFichiersTexte()                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      with debuggage do begin
      if entreesSortiesUnitFichiersTEXT                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if pendantLectureBase                             then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheSuiteInitialisations                    then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if evenementsDansRapport                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if elementsStrategiques                           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if gestionDuTemps                                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if calculFinaleOptimaleParOptimalite              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if arbreDeJeu                                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if lectureSmartGameBoard                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      end; {with debuggage do}
      if afficheProchainsCoups                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheSignesDiacritiques                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if NePasUtiliserLeGrasFenetreOthellier            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if prefVersion40b11Enregistrees                   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.apprentissage                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if PostscriptCompatibleXPress                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if HumCtreHum                                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetReveillerRegulierementLeMac()               then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if affichageReflexion.afficherToutesLesPasses     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.algoDeFinale                         then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetEcritToutDansRapportLog()                   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecBibl                                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if CassioUtiliseDesMajuscules                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if differencierLesFreres                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecInterversions                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetAvecAffichageNotesSurCases(kNotesDeCassio)  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if utilisateurVeutDiscretiserEvaluation           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if sansReflexionSurTempsAdverse                   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if seMefierDesScoresDeLArbre                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if retirerEffet3DSubtilOthellier2D                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.MacOSX                               then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecGagnantEnGrasDansListe                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if gInfosSaisiePartie.enregistrementAutomatique   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecLisereNoirSurPionsBlancs                   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecAjustementAutomatiqueDuNiveau              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if eviterSolitairesOrdinateursSVP                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if listeEtroiteEtNomsCourts                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecOmbrageDesPions                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetAvecAffichageNotesSurCases(kNotesDeZebra)   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if garderPartieNoireADroiteOthellier              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if gAideTranscriptsDejaPresentee                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if InclurePartiesAvecOrdinateursDansListe()       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      
      
      s2 := '';
      NumEnStringFormatee(gCouleurOthellier.couleurFront,4,s2);
      NumEnStringFormatee(gCouleurOthellier.couleurBack,4,s2);
      NumEnStringFormatee(GetCadence(),12,s2);
      NumEnStringFormatee(traductionMoisTournoi,2,s2);
      NumEnStringFormatee(FntrFelicitationTopLeft.h,5,s2);
      NumEnStringFormatee(FntrFelicitationTopLeft.v,5,s2);
      NumEnStringFormatee(cadencePersoAffichee,15,s2);
      NumEnStringFormatee(NiveauJeuInstantane,4,s2);
      NumEnStringFormatee(gCouleurOthellier.menuCmd,3,s2);
      NumEnStringFormatee(genreAffichageTextesDansFenetrePlateau,4,s2);
    end;
end;


procedure DecodeChainePrefBooleens(s1 : str255);
var len : SInt16; 
    bidbool : boolean;
begin
  len := Length(s1);
 {if len>=1  then bidbool                                         := s1[1]='Y';}
  if len>=2  then SetEnVieille3D                                    (s1[2]='Y');
 {if len>=3  then OthelloTorique                                  := s1[3]='Y';}
  if len>=4  then avecSon                                         := s1[4]='Y';
  if len>=5  then avecProgrammation                               := s1[5]='Y';
 {if len>=6  then gEcranCouleur                                   := s1[6]='Y';}
 {if len>=7  then bidbool                                         := s1[7]='Y';}
  if len>=8  then OrdreDuTriRenverse                              := s1[8]='Y';
  if len>=9  then afficheBibl                                     := s1[9]='Y';
  if len>=10 then debuggage.general                               := s1[10]='Y';
  if len>=11 then afficheNumeroCoup                               := s1[11]='Y';
  if len>=12 then afficheSuggestionDeCassio                       := s1[12]='Y';
  if len>=13 then afficheMeilleureSuite                           := s1[13]='Y';
  if len>=14 then avecEvaluationTotale                            := s1[14]='Y';
 {if len>=15 then avecDessinCoupEnTete                            := s1[15]='Y';}
  if len>=16 then referencesCompletes                             := s1[16]='Y';
 {if len>=17 then PionClignotant                                  := s1[17]='Y';}
  if len>=18 then LectureAntichronologique                        := s1[18]='Y';
  if len>=19 then decrementetemps                                 := s1[19]='Y';
 {if len>=20 then SupprimerLesEffetsDeZoom                        := s1[20]='Y';}
 {if len>=21 then OptimisePourKaleidoscope                        := s1[21]='Y';}
  if len>=22 then bidbool                                         := s1[22]='Y';
  if len>=23 then bidbool                                         := s1[23]='Y';
  if len>=24 then bidbool                                         := s1[24]='Y';
  if len>=25 then bidbool                                         := s1[25]='Y';
  if len>=26 then bidbool                                         := s1[26]='Y';
  if len>=27 then affichageReflexion.doitAfficher                 := s1[27]='Y';
  if len>=28 then afficheGestionTemps                             := s1[28]='Y';
  if len>=29 then jeuInstantane                                   := s1[29]='Y';
  if len>=30 then avecSauvegardePref                              := s1[30]='Y';
  if len>=31 then avecAlerteNouvInterversion                      := s1[31]='Y';
 {if len>=32 then avecSystemeCoordonnees                          := s1[32]='Y';}
 {if len>=33 then toujoursIndexerBase                             := s1[33]='Y';}
 {if len>=34 then avecSelectivite                                 := s1[34]='Y';}
 {if len>=35 then avecNomOuvertures                               := s1[35]='Y';}
  if len>=36 then neJamaisTomber                                  := s1[36]='Y';
  if len>=37 then doitConfirmerQuitter                            := s1[37]='Y';
 {if len>=38 then bidbool                                         := s1[38]='Y';}
  if len>=39 then avecTestBibliotheque                            := s1[39]='Y';
 {if len>=40 then BeeperAuxCoupsillegaux                          := s1[40]='Y';}
  if len>=41 then InfosTechniquesDansRapport                      := s1[41]='Y';
  if len>=42 then afficheInfosApprentissage                       := s1[42]='Y';
  if len>=43 then UtiliseGrapheApprentissage                      := s1[43]='Y';
  if len>=44 then LaDemoApprend                                   := s1[44]='Y';
  with gEntrainementOuvertures do begin
  if len>=45 then CassioVarieSesCoups                             := s1[45]='Y';
  if len>=46 then CassioSeContenteDeLaNulle                       := s1[46]='Y';
  end; {with gEntrainementOuvertures}
  if len>=47 then analyseRetrograde.doitConfirmerArret            := s1[47]='Y';
  if len>=48 then AuMoinsUneFelicitation                          := s1[48]='Y';
 {if len>=49 then bidbool                                         := s1[49]='Y';}
 {if len>=50 then bidbool                                         := s1[50]='Y';}
  if len>=51 then avecRefutationsDansRapport                      := s1[51]='Y';
  if len>=52 then enModeIOS                                       := s1[52]='Y';
 {if len>=53 then sousEmulatorSousPC                              := s1[53]='Y';}
  if len>=54 then affichePierresDelta                             := s1[54]='Y';
  if len>=55 then avecEvaluationTablesDeCoins                     := s1[55]='Y';
  if len>=56 then SetDebuggageUnitFichiersTexte                     (s1[56]='Y');
  with debuggage do begin
  if len>=57 then entreesSortiesUnitFichiersTEXT                  := s1[57]='Y';
  if len>=58 then pendantLectureBase                              := s1[58]='Y';
  {if len>=59 then afficheSuiteInitialisations                     := s1[59]='Y';}
  if len>=60 then evenementsDansRapport                           := s1[60]='Y';
  if len>=61 then elementsStrategiques                            := s1[61]='Y';
  if len>=62 then gestionDuTemps                                  := s1[62]='Y';
  if len>=63 then calculFinaleOptimaleParOptimalite               := s1[63]='Y';
  if len>=64 then arbreDeJeu                                      := s1[64]='Y';
  if len>=65 then lectureSmartGameBoard                           := s1[65]='Y';
  end; {with debuggage do}
  if len>=66 then afficheProchainsCoups                           := s1[66]='Y';
  if len>=67 then afficheSignesDiacritiques                       := s1[67]='Y';
  if len>=68 then NePasUtiliserLeGrasFenetreOthellier             := s1[68]='Y';
  if len>=69 then prefVersion40b11Enregistrees                    := s1[69]='Y';
  if len>=70 then debuggage.apprentissage                         := s1[70]='Y';
  {if len>=71 then PostscriptCompatibleXPress                     := s1[71]='Y';}
  if len>=72 then HumCtreHum                                      := s1[72]='Y';
 {if len>=73 then bidbool                                         := s1[73]='Y';}
  if len>=74 then SetReveillerRegulierementLeMac                    (s1[74]='Y');
  if len>=75 then affichageReflexion.afficherToutesLesPasses      := s1[75]='Y';
  if len>=76 then debuggage.algoDeFinale                          := s1[76]='Y';
 {if len>=77 then ecrireDansRapportLog                            := s1[77]='Y';}
  if len>=78 then avecBibl                                        := s1[78]='Y';
  if len>=79 then CassioUtiliseDesMajuscules                      := s1[79]='Y';
  if len>=80 then differencierLesFreres                           := s1[80]='Y';
  if len>=81 then avecInterversions                               := s1[81]='Y';
  if len>=82 then SetAvecAffichageNotesSurCases      (kNotesDeCassio,s1[82]='Y');
  if len>=83 then utilisateurVeutDiscretiserEvaluation            := s1[83]='Y';
  if len>=84 then sansReflexionSurTempsAdverse                    := s1[84]='Y';
  if len>=85 then seMefierDesScoresDeLArbre                       := s1[85]='Y';
  if len>=86 then retirerEffet3DSubtilOthellier2D                 := s1[86]='Y';
  if len>=87 then debuggage.MacOSX                                := s1[87]='Y';
  if len>=88 then avecGagnantEnGrasDansListe                      := s1[88]='Y';
  if len>=89 then gInfosSaisiePartie.enregistrementAutomatique    := s1[89]='Y';
  if len>=90 then avecLisereNoirSurPionsBlancs                    := s1[90]='Y';
  if len>=91 then avecAjustementAutomatiqueDuNiveau               := s1[91]='Y';
  if len>=92 then eviterSolitairesOrdinateursSVP                  := s1[92]='Y';
  if len>=93 then listeEtroiteEtNomsCourts                        := s1[93]='Y';
  if len>=94 then avecOmbrageDesPions                             := s1[94]='Y';
  {if len>=95 then SetAvecAffichageNotesSurCases       (kNotesDeZebra,s1[95]='Y');}
  if len>=96 then garderPartieNoireADroiteOthellier               := s1[96]='Y';
  {if len>= 97 then gAideTranscriptsDejaPresentee                 := s1[97]='Y';}
  if len>= 98 then SetInclurePartiesAvecOrdinateursDansListe        (s1[98]='Y');
  
end;


procedure DecodeChainePrefNumeriques(s2 : str255);
begin
    gCouleurOthellier.couleurFront         := StringFormateeEnNum(4,s2);
    gCouleurOthellier.couleurBack          := StringFormateeEnNum(4,s2);
    SetCadence                               (StringFormateeEnNum(12,s2));
    traductionMoisTournoi                  := StringFormateeEnNum(2,s2);
    FntrFelicitationTopLeft.h              := StringFormateeEnNum(5,s2);
    FntrFelicitationTopLeft.v              := StringFormateeEnNum(5,s2);
    cadencePersoAffichee                   := StringFormateeEnNum(15,s2);
    NiveauJeuInstantane                    := StringFormateeEnNum(4,s2);
    gCouleurOthellier.menuCmd              := StringFormateeEnNum(3,s2);
    genreAffichageTextesDansFenetrePlateau := StringFormateeEnNum(4,s2);
    
    if (GetCadence() <= 0)
      then SetCadence(minutes5);
    if cadencePersoAffichee<=0 
      then cadencePersoAffichee := GetCadence();
 
    if (NiveauJeuInstantane < NiveauDebutants) | 
       (NiveauJeuInstantane > NiveauChampions)
      then  NiveauJeuInstantane := NiveauDebutants;
    
    if (gCouleurOthellier.menuCmd<=0) | 
       (gCouleurOthellier.menuCmd > AutreCouleurCmd)
      then gCouleurOthellier.menuCmd := VertPaleCmd;
end;

procedure DecodeChainePasseAnalyseRetrograde(s : str255);
var s1,s2,s3,s4,reste : str255;
    nroPasse,nroStage : SInt16; 
begin
  Parser2(s,s1,s2,reste);  { '\nroPasse'  '->' }
  nroPasse := ChaineEnLongint(s1);
  if (nroPasse>=1) & (nroPasse<=nbMaxDePassesAnalyseRetrograde) then
    begin
      nroStage := 0;
      while (reste<>'') & (nroStage<nbMaxDeStagesAnalyseRetrograde) do
        begin
          inc(nroStage);
          Parser4(reste,s1,s2,s3,s4,reste);
          analyseRetrograde.menuItems[nroPasse,nroStage,kMenuGenre] := ChaineEnLongint(s1);
          analyseRetrograde.menuItems[nroPasse,nroStage,kMenuProf]  := ChaineEnLongint(s2);
          analyseRetrograde.menuItems[nroPasse,nroStage,kMenuDuree] := ChaineEnLongint(s3);
          analyseRetrograde.menuItems[nroPasse,nroStage,kMenuNotes] := ChaineEnLongint(s4);
        end;
    end;
end;

procedure LitPrefDerniersJoueursSaisie(chainePref : str255);
var N,numero : SInt32;
    s : str255;
begin
  for N := 1 to kNbJoueursMenuSaisie do
    begin
      s := TPCopy(chainePref,1+ (N-1)*6,6);
      {WritelnDansRapport('LitPrefDerniersJoueursSaisie : '+ s);}
      if s = ''
        then numero := -1
        else numero := ChaineEnLongint(s);
      {WritelnStringAndNumDansRapport('numero = ',numero);}
      SetNiemeJoueurTableSaisiePartie(N,numero);
    end;
end;

procedure LitPrefDerniersTournoisSaisie(chainePref : str255);
var N,numero : SInt32;
    s : str255;
begin
  for N := 1 to kNbTournoisMenuSaisie do
    begin
      s := TPCopy(chainePref,1+ (N-1)*6,6);
      {WritelnDansRapport('LitPrefDerniersTournoisSaisie : '+ s);}
      if s = ''
        then numero := -1
        else numero := ChaineEnLongint(s);
      {WritelnStringAndNumDansRapport('numero = ',numero);}
      SetNiemeTournoiTableSaisiePartie(N,numero);
    end;
end;

function FabriquePrefDerniersJoueursSaisie() : str255;
var N,k,numero : SInt32;
    s,s1 : str255;
begin
  s := '';
  for N := 1 to kNbJoueursMenuSaisie do
    begin
      numero := GetNiemeJoueurTableSaisiePartie(N);
      s1 := NumEnString(numero);
      for k := 1 to 6 - Length(s1) do
        s1 := s1 + ' ';
      {WritelnStringAndNumDansRapport('numero = ',numero);
      WritelnDansRapport('FabriquePrefDerniersJoueursSaisie : '+ s1);}
      s := s + s1;
    end;
  FabriquePrefDerniersJoueursSaisie := s;
  {WritelnDansRapport('FabriquePrefDerniersJoueursSaisie (totale) : '+ s);}
end;

function FabriquePrefDerniersTournoisSaisie() : str255;
var N,k,numero : SInt32;
    s,s1 : str255;
begin
  s := '';
  for N := 1 to kNbTournoisMenuSaisie do
    begin
      numero := GetNiemeTournoiTableSaisiePartie(N);
      s1 := NumEnString(numero);
      for k := 1 to 6 - Length(s1) do
        s1 := s1 + ' ';
      {WritelnStringAndNumDansRapport('numero = ',numero);
      WritelnDansRapport('FabriquePrefDerniersTournoisSaisie : '+ s1);}
      s := s + s1;
    end;
  FabriquePrefDerniersTournoisSaisie := s;
  {WritelnDansRapport('FabriquePrefDerniersTournoisSaisie (totale) : '+ s);}
end;


function FichierPreferencesDeCassioExiste(nom : str255; var fic : FichierTEXT) : OSErr;
var s : str255;
    erreurES : OSErr;
begin

  erreurES := -1;

  s := nom;
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);
  
  s := ReplaceStringByStringInString('Préférences','Preferences',nom);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);
  
  s := ReplaceStringByStringInString('Préférences','PreÃÅfeÃÅrences',nom);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);
  
  s := ReplaceStringByStringInString('Preferences','Préférences',nom);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);
  
  s := ReplaceStringByStringInString('Preferences','PreÃÅfeÃÅrences',nom);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);
  
  FichierPreferencesDeCassioExiste := erreurES;
   
end;



procedure CreeFichierPreferences;
var fichierPref : FichierTEXT;
    filename : str255;
    version : str255;
    chainePref : str255;
    chainePrefBooleens : str255;
    chainePrefNumeriques : str255;
    erreurES,k,j : SInt32;
begin
  filename := NameOfPrefsFile();
  
  {SetDebuggageUnitFichiersTexte(false);}
  
  erreurES := FichierPreferencesDeCassioExiste(fileName,fichierPref);
  if (erreurES = fnfErr) {-43 = file not found  ==> on crée le fichier}
    then erreurES := CreeFichierTexteDeCassio(fileName,fichierPref);
  
  if (erreurES = NoErr)
    then {le fichier préférences existe : on l'ouvre et on le vide}
      begin
        erreurES := OuvreFichierTexte(fichierPref);
        erreurES := VideFichierTexte(fichierPref);
      end;
  
  if (erreurES <> NoErr) then
    begin
      { Si il y a une erreur à ce niveau, c'est probablement que l'on n'a
        pas les droits d'ecriture sur le repertoire (archive web, CD, etc).
        L'utilisateur ne peut sans doute rien faire, et ça ne sert à rien 
        de l'embeter avec une alerte }
        
      {AlerteSimpleFichierTexte(fileName,erreurES);}
      
      erreurES := FermeFichierTexte(fichierPref);
      exit(CreeFichierPreferences);
    end;
    
  prefVersion40b11Enregistrees := true;
      
  version := '%versionOfPrefsFile = 11';
  erreurES := WritelnDansFichierTexte(fichierPref,version);
  CodeChainePref(chainePrefBooleens,chainePrefNumeriques);
  erreurES := WritelnDansFichierTexte(fichierPref,'%booleens = '+chainePrefBooleens);
  erreurES := WritelnDansFichierTexte(fichierPref,'%numeriques = '+chainePrefNumeriques);
  erreurES := WritelnDansFichierTexte(fichierPref,'%SolitairesDemandes = '+CodeChaineSolitairesDemandes());
  
  ParamDiagRecEnChaine(ParamDiagPositionFFORUM,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%paramDiagPositionFFORUM = '+chainePref);
  ParamDiagRecEnChaine(ParamDiagPartieFFORUM,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%paramDiagPartieFFORUM = '+chainePref);
  ParamDiagRecEnChaine(ParamDiagCourant,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%paramDiagCourant = '+chainePref);
  ParamDiagRecEnChaine(ParamDiagImpr,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%paramDiagImpr = '+chainePref);
  
  chainePref := FenetreEnChaine(windowPlateauOpen,wPlateauPtr,FntrPlatRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowPlateau = '+chainePref);
  chainePref := FenetreEnChaine(windowCourbeOpen,wCourbePtr,FntrCourbeRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowCourbe = '+chainePref);
  chainePref := FenetreEnChaine(windowAideOpen,wAidePtr,FntrAideRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowAide = '+chainePref);
  chainePref := FenetreEnChaine(windowGestionOpen,wGestionPtr,FntrGestionRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowGestion = '+chainePref);
  chainePref := FenetreEnChaine(windowReflexOpen,wReflexPtr,FntrReflexRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowReflexion = '+chainePref);
  chainePref := FenetreEnChaine(windowListeOpen,wListePtr,FntrListeRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowListe = '+chainePref);
  chainePref := FenetreEnChaine(windowStatOpen,wStatPtr,FntrStatRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowStat = '+chainePref);
  chainePref := FenetreEnChaine(windowPaletteOpen,wPalettePtr,FntrPaletteRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowPalette = '+chainePref);
  chainePref := FenetreEnChaine(windowRapportOpen,GetRapportWindow(),FntrRapportRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowRapport = '+chainePref);
  chainePref := FenetreEnChaine(IconisationDeCassio.encours,IconisationDeCassio.theWindow,IconisationDeCassio.IconisationRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowIconisation = '+chainePref);
  chainePref := FenetreEnChaine(arbreDeJeu.windowOpen,GetArbreDeJeuWindow(),FntrCommentairesRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowCommentaires = '+chainePref);
  chainePref := FenetreEnChaine(false,NIL,FntrCadenceRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowCadence = '+chainePref);
  chainePref := FenetreEnChaine(false,NIL,aireDeJeu);
  erreurES := WritelnDansFichierTexte(fichierPref,'%aireDeJeu = '+chainePref);
  
  chainePref := CheminAccesThorDBA^^;
  erreurES := WritelnDansFichierTexte(fichierPref,'%accesThorDBA = '+chainePref);
  chainePref := CheminAccesThorDBASolitaire^^;
  erreurES := WritelnDansFichierTexte(fichierPref,'%accesSolitaires = '+chainePref);
  NumToString(VolumeRefThorDBA,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%volumeRefThorDBA = '+chainePref);
  NumToString(VolumeRefThorDBASolitaire,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%volumeRefSolitaires = '+chainePref);
  NumToString(nbExplicationsPasses,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbExplicationsPasses = '+chainePref);
  {NumToString(gGenreDeTriListe,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gGenreDeTriListe = '+chainePref);}
  NumToString(analyseRetrograde.nbMinPourConfirmationArret,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%confirmationArretRetro = '+chainePref);
  NumToString(arbreDeJeu.positionLigneSeparation,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%LigneSeparationCommentaires = '+chainePref);
  
  NumToString(MyTrunc(Coeffinfluence*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffInfluence = '+chainePref);
  NumToString(MyTrunc(Coefffrontiere*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffFrontiere = '+chainePref);
  NumToString(MyTrunc(CoeffEquivalence*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffEquivalence = '+chainePref);
  NumToString(MyTrunc(Coeffcentre*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffCentre = '+chainePref);
  NumToString(MyTrunc(Coeffgrandcentre*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffGrandCentre = '+chainePref);
  NumToString(MyTrunc(Coeffbetonnage*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffBetonnage = '+chainePref);
  NumToString(MyTrunc(Coeffminimisation*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffMinimisation = '+chainePref);
  NumToString(MyTrunc(CoeffpriseCoin*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffPriseCoin = '+chainePref);
  NumToString(MyTrunc(CoeffdefenseCoin*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffDefenseCoin = '+chainePref);
  NumToString(MyTrunc(CoeffValeurCoin*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffValeurCoin = '+chainePref);
  NumToString(MyTrunc(CoeffValeurCaseX*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffValeurCaseX = '+chainePref);
  NumToString(MyTrunc(CoeffPenalite*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffPenalite = '+chainePref);
  NumToString(MyTrunc(CoeffMobiliteUnidirectionnelle*100+0.5),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffMobiliteUnidirectionnelle = '+chainePref);   
  NumToString(gPourcentageTailleDesPions,chainePRef);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gPourcentageTailleDesPions = '+chainePref);     
  NumToString(gCouleurSupplementaire.red,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurSupplementaire.red = '+chainePref);     
  NumToString(gCouleurSupplementaire.green,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurSupplementaire.green = '+chainePref);     
  NumToString(gCouleurSupplementaire.blue,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurSupplementaire.blue = '+chainePref);
  NumToString(gCouleurOthellier.menuID,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurOthellier.menuID = '+chainePref);
  chainePref := gCouleurOthellier.nomFichierTexture;
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurOthellier.nomFichierTexture = '+chainePref);
  NumToString(gLastTexture3D.theMenu,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gLastTexture3D.theMenu = '+chainePref);
  NumToString(gLastTexture3D.theCmd,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gLastTexture3D.theCmd = '+chainePref);
  NumToString(gLastTexture2D.theMenu,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gLastTexture2D.theMenu = '+chainePref);
  NumToString(gLastTexture2D.theCmd,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gLastTexture2D.theCmd = '+chainePref);
  chainePref := CoupEnStringEnMinuscules(GetPremierCoupParDefaut());
  erreurES := WritelnDansFichierTexte(fichierPref,'%PremierCoupParDefaut = '+chainePref);
  NumToString(nbCasesVidesMinSolitaire,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbCasesVidesMinSolitaire = '+chainePref);
  NumToString(nbCasesVidesMaxSolitaire,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbCasesVidesMaxSolitaire = '+chainePref);
  chainePref := Concat(GetPoliceNameNotesSurCases(kNotesDeCassio), ' ', NumEnString(GetTailleNotesSurCases(kNotesDeCassio)));
  erreurES := WritelnDansFichierTexte(fichierPref,'%PoliceNotesSurLesCases = '+chainePref);
  chainePref := Concat(GetPoliceNameNotesSurCases(kNotesDeZebra), ' ', NumEnString(GetTailleNotesSurCases(kNotesDeZebra)));
  erreurES := WritelnDansFichierTexte(fichierPref,'%PoliceBiblioZebraSurLesCases = '+chainePref);
  NumToString(GetZebraBookOptions(),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%ZebraBookOptions = '+chainePref);
  NumToString(ord(gAideCourante),chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gAideCourante = '+chainePref);
  NumToString(humanWinningStreak,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%humanWinningStreak = '+chainePref);
  NumToString(humanScoreLastLevel,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%humanScoreLastLevel = '+chainePref);
  NumToString(themeCourantDeCassio,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%themeCourantDeCassio = '+chainePref);
  NumToString(gNbreMegaoctetsPourLaBase,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gNbreMegaoctetsPourLaBase = '+chainePref);
  
  erreurES := WritelnDansFichierTexte(fichierPref,'%JoueursSaisie = '+FabriquePrefDerniersJoueursSaisie());
  erreurES := WritelnDansFichierTexte(fichierPref,'%TournoisSaisie = '+FabriquePrefDerniersTournoisSaisie());
  erreurES := WritelnDansFichierTexte(fichierPref,'%AnneeSaisie = '+NumEnString(gInfosSaisiePartie.derniereAnnee));
  erreurES := WritelnDansFichierTexte(fichierPref,'%JoueurNoirSaisie = '+NumEnString(gInfosSaisiePartie.dernierJoueurNoir));
  erreurES := WritelnDansFichierTexte(fichierPref,'%JoueurBlancSaisie = '+NumEnString(gInfosSaisiePartie.dernierJoueurBlanc));
  erreurES := WritelnDansFichierTexte(fichierPref,'%TournoiSaisie = '+NumEnString(gInfosSaisiePartie.dernierTournoi));
  erreurES := WritelnDansFichierTexte(fichierPref,'%DistributionSaisie = '+NumEnString(Max(1,gInfosSaisiePartie.derniereDistribution)));
  erreurES := WritelnDansFichierTexte(fichierPref,'%tailleFenetrePlateauAvantPassageEn3D = '+NumEnString(tailleFenetrePlateauAvantPassageEn3D));
  erreurES := WritelnDansFichierTexte(fichierPref,'%tailleCaseAvantPassageEn3D = '+NumEnString(tailleCaseAvantPassageEn3D));
  erreurES := WritelnDansFichierTexte(fichierPref,'%empilementFenetres = '+VisibiliteInitiale.ordreOuvertureDesFenetres);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbColonnesFenetreListe = '+NumEnString(nbColonnesFenetreListe));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionDistribution = '+NumEnString(positionDistribution));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionTournoi = '+NumEnString(positionTournoi));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionNoir = '+NumEnString(positionNoir));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionBlanc = '+NumEnString(positionBlanc));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionCoup = '+NumEnString(positionCoup));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionScoreReel = '+NumEnString(positionScoreReel));
  
  GetIntervaleDeDifficultePourProblemeDePriseDeCoin(j,k);
  erreurES := WritelnDansFichierTexte(fichierPref,'%IntervaleProblemesDeCoinDansListe = '+NumEnString(j*10 + k));

  NumToString(nbCoupsEnTete,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbMeilleursCoupsAffiches = '+chainePref);
  for k := 1 to nbMaxDePassesAnalyseRetrograde do
    begin
      chainePref := '%PasseAnalyseRetrograde = '+NumEnString(k)+' ->';
      for j := 1 to nbMaxDeStagesAnalyseRetrograde do
        begin
          chainePref := chainePref+' '+NumEnString(analyseRetrograde.menuItems[k,j,kMenuGenre])+
                                   ' '+NumEnString(analyseRetrograde.menuItems[k,j,kMenuProf])+
                                   ' '+NumEnString(analyseRetrograde.menuItems[k,j,kMenuDuree])+
                                   ' '+NumEnString(analyseRetrograde.menuItems[k,j,kMenuNotes]);                               
        end;
      erreurES := WritelnDansFichierTexte(fichierPref,chainePref);
    end;
  
  for k := NbMaxItemsReouvrirMenu downto 1 do
    if (nomDuFichierAReouvrir[k] <> NIL) & (nomDuFichierAReouvrir[k]^^<>'') then
      begin
        chainePref := nomDuFichierAReouvrir[k]^^;
        erreurES := WritelnDansFichierTexte(fichierPref,'%partieAReouvrir = '+chainePref);
      end;
  
  with DistributionsNouveauFormat do
    begin
      case ChoixDistributions.genre of
        kToutesLesDistributions : chainePref := '%quellesBasesLire = ToutesLesDistributions';
        kQuelquesDistributions  : chainePref := '%quellesBasesLire = QuelquesDistributions';
        kAucuneDistribution     : chainePref := '%quellesBasesLire = AucuneDistribution';
      end;
      erreurES := WritelnDansFichierTexte(fichierPref,chainePref);
      for k := 1 to nbDistributions do
        begin
        
         {
          TraceLog('k = '+NumEnString(k));
          if (Distribution[k].path <> NIL) & (Distribution[k].name <> NIL)
            then TraceLog('   '+Distribution[k].path^ + Distribution[k].name^)
            else TraceLog('   NIL ou NIL !');
          if (k in ChoixDistributions.distributionsALire)
            then TraceLog('   k in ChoixDistributions.distributionsALire => TRUE')
            else TraceLog('   k in ChoixDistributions.distributionsALire => false');
         }
          
          if (k in ChoixDistributions.distributionsALire) & 
           (Distribution[k].path <> NIL) & (Distribution[k].name <> NIL) then
          begin
            chainePref := Distribution[k].path^ + Distribution[k].name^;
            chainePref := ReplaceStringByStringInString(pathCassioFolder,'$CASSIO_FOLDER:',chainePref);
            erreurES := WritelnDansFichierTexte(fichierPref,'%baseActive = '+chainePref);
          end;
        end;
    end;
    
  erreurES := FermeFichierTexte(fichierPref);
  SetFileCreatorFichierTexte(fichierPref,'SNX4');
  SetFileTypeFichierTexte(fichierPref,'PREF');
  
  AjouterNomDansListOfPrefsFiles(filename);
  
end;




procedure LitFichierPreferences;
var fichierPref : FichierTEXT;
    filename : str255;
    LigneFichierPref : str255;
    motClef : str255;
    auxStr : str255;
    chainePref : str255;
    erreurES : SInt16; 
    bidon : boolean;
    Item : SInt16; 
    i : SInt32;
    autreFichierPreferencesSuggere : str255;
const AlerteSimpleID=1131;
begin
 
 if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : avant NameOfPrefsFile');
 
 filename := NameOfPrefsFile();
 
 {SetDebuggageUnitFichiersTexte(false);}
 
 erreurES := FichierPreferencesDeCassioExiste(fileName,fichierPref); 
 
 if erreurES=fnfErr then 
   begin
     {fichier préférences non trouvé = > on essaie de lire les vieux fichiers de preferences}
     
     LireListeOfPrefsFiles;
     for i := 1 to kMaxPrefFiles do
       begin
         autreFichierPreferencesSuggere := gListeOfPrefFiles[i].name;
         if (erreurES=fnfErr) & (autreFichierPreferencesSuggere <> '') then
           begin
             erreurES := FichierPreferencesDeCassioExiste(autreFichierPreferencesSuggere,fichierPref);
             if erreurES = NoErr then 
               begin
                 filename := autreFichierPreferencesSuggere;
                 if (i > 1) then AjouterNomDansListOfPrefsFiles(filename);
               end;
           end;
       end;
   
     { desespoir, on n'a trouve aucun vieux fichier de preferences : 
       on quitte et on prendra les prefs par défauts}
     if erreurES = fnfErr then exit(LitFichierPreferences);
   end;
   
 if erreurES<>NoErr then 
   begin
     AlerteSimpleFichierTexte(fileName,erreurES);
     exit(LitFichierPreferences);
   end;
 
 erreurES := OuvreFichierTexte(fichierPref); 
 if erreurES<>NoErr then 
   begin
     AlerteSimpleFichierTexte(fileName,erreurES);
     exit(LitFichierPreferences);
   end;
 
 erreurES := ReadlnDansFichierTexte(fichierPref,chainePref);
 if erreurES<>NoErr then 
   begin
     AlerteSimpleFichierTexte(fileName,erreurES);
     erreurES := FermeFichierTexte(fichierPref);
     exit(LitFichierPreferences);
   end;
   
 if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : avant if (chainePref <> ''%versionOfPrefsFile = 11'')');
 
 if (chainePref <> '%versionOfPrefsFile = 11')           {mauvaise version du fichier preference}
  then
   begin
    {BeginDialog;}
    if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : avant GetIndString');
    GetIndString(chainePref,TextesErreursID,1);
    ParamText(chainepref,'','','');
    item := StopAlert(AlerteSimpleID,NIL);
    {EndDialog;}
   end
  else
   begin
    while (erreurES=NoErr) & not(EOFFichierTexte(fichierPref,erreurES)) do
     begin
     
     
      erreurES := ReadlnDansFichierTexte(fichierPref,LigneFichierPref);
      
      if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : LigneFichierPref = '+LigneFichierPref);
      
      Parser2(LigneFichierPref,motClef,auxStr,chainePref);
             
      
      if chainePref<>'' then
       begin
        if motClef='%booleens'                            then DecodeChainePrefBooleens(chainePref) else
        if motClef='%numeriques'                          then DecodeChainePrefNumeriques(chainePref) else
        if motClef='%SolitairesDemandes'                  then DecodeChaineSolitairesDemandes(chainePref) else
        if motClef='%paramDiagPositionFFORUM'             then ChaineEnParamDiagRec(chainePref,ParamDiagPositionFFORUM) else
        if motClef='%paramDiagPartieFFORUM'               then ChaineEnParamDiagRec(chainePref,ParamDiagPartieFFORUM) else
        if motClef='%paramDiagCourant'                    then ChaineEnParamDiagRec(chainePref,ParamDiagCourant) else
        if motClef='%paramDiagImpr'                       then ChaineEnParamDiagRec(chainePref,ParamDiagImpr) else
        if motClef='%windowPlateau'                       then ChaineEnFenetre(chainePref,windowPlateauOpen,FntrPlatRect) else
        if motClef='%windowCourbe'                        then ChaineEnFenetre(chainePref,windowCourbeOpen,FntrCourbeRect) else
        if motClef='%windowAide'                          then ChaineEnFenetre(chainePref,windowAideOpen,FntrAideRect) else
        if motClef='%windowGestion'                       then ChaineEnFenetre(chainePref,windowGestionOpen,FntrGestionRect) else
        if motClef='%windowReflexion'                     then ChaineEnFenetre(chainePref,windowReflexOpen,FntrReflexRect) else
        if motClef='%windowListe'                         then ChaineEnFenetre(chainePref,windowListeOpen,FntrListeRect) else
        if motClef='%windowStat'                          then ChaineEnFenetre(chainePref,windowStatOpen,FntrStatRect) else
        if motClef='%windowPalette'                       then ChaineEnFenetre(chainePref,windowPaletteOpen,FntrPaletteRect) else
        if motClef='%windowRapport'                       then ChaineEnFenetre(chainePref,windowRapportOpen,FntrRapportRect) else          
        if motClef='%windowCommentaires'                  then ChaineEnFenetre(chainePref,arbreDeJeu.windowOpen,FntrCommentairesRect) else  
        if motClef='%windowCadence'                       then ChaineEnFenetre(chainePref,bidon,FntrCadenceRect) else
        if motClef='%aireDeJeu'                           then ChaineEnRect(chainePref,bidon,aireDeJeu) else
        if motClef='%accesThorDBA'                        then CheminAccesThorDBA^^ := chainePref else
        if motClef='%accesSolitaires'                     then CheminAccesThorDBASolitaire^^ := chainePref else
        if motClef='%volumeRefThorDBA'                    then ChaineToInteger(chainePref,VolumeRefThorDBA) else
        if motClef='%volumeRefSolitaires'                 then ChaineToInteger(chainePref,VolumeRefThorDBASolitaire) else
        if motClef='%nbExplicationsPasses'                then ChaineToInteger(chainePref,nbExplicationsPasses) else
       {if motClef='%gGenreDeTriListe'                    then ChaineToInteger(chainePref,gGenreDeTriListe) else}
        if motClef='%confirmationArretRetro'              then ChaineToLongint(chainePref,analyseRetrograde.nbMinPourConfirmationArret) else
        if motClef='%CoeffInfluence'                      then Coeffinfluence := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffFrontiere'                      then Coefffrontiere := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffEquivalence'                    then CoeffEquivalence := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffCentre'                         then Coeffcentre := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffGrandCentre'                    then Coeffgrandcentre := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffBetonnage'                      then Coeffbetonnage := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffMinimisation'                   then Coeffminimisation := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffPriseCoin'                      then CoeffpriseCoin := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffDefenseCoin'                    then CoeffdefenseCoin := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffValeurCoin'                     then CoeffValeurCoin := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffValeurCaseX'                    then CoeffValeurCaseX := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffPenalite'                       then CoeffPenalite := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%CoeffMobiliteUnidirectionnelle'      then CoeffMobiliteUnidirectionnelle := ChaineEnLongint(chainePref)/100.0 else
        if motClef='%LigneSeparationCommentaires'         then arbreDeJeu.positionLigneSeparation := ChaineEnLongint(chainePref) else
        if motClef='%gPourcentageTailleDesPions'          then gPourcentageTailleDesPions := ChaineEnLongint(chainePref) else
        if motClef='%gCouleurSupplementaire.red'          then SetRGBColor(gCouleurSupplementaire,ChaineEnLongint(chainePref),gCouleurSupplementaire.green,gCouleurSupplementaire.blue) else
        if motClef='%gCouleurSupplementaire.green'        then SetRGBColor(gCouleurSupplementaire,gCouleurSupplementaire.red,ChaineEnLongint(chainePref),gCouleurSupplementaire.blue) else
        if motClef='%gCouleurSupplementaire.blue'         then SetRGBColor(gCouleurSupplementaire,gCouleurSupplementaire.red,gCouleurSupplementaire.green,ChaineEnLongint(chainePref)) else
        if motClef='%gCouleurOthellier.menuID'            then gCouleurOthellier.menuID := ChaineEnLongint(chainePref) else
        if motClef='%gCouleurOthellier.nomFichierTexture' then gCouleurOthellier.nomFichierTexture := chainePref else  
        if motClef='%gLastTexture3D.theMenu'              then gLastTexture3D.theMenu := ChaineEnLongint(chainePref) else
        if motClef='%gLastTexture3D.theCmd'               then gLastTexture3D.theCmd := ChaineEnLongint(chainePref) else
        if motClef='%gLastTexture2D.theMenu'              then gLastTexture2D.theMenu := ChaineEnLongint(chainePref) else
        if motClef='%gLastTexture2D.theCmd'               then gLastTexture2D.theCmd := ChaineEnLongint(chainePref) else
        if motClef='%nbMeilleursCoupsAffiches'            then ChaineToInteger(chainePref,nbCoupsEnTete) else
        if motClef='%PasseAnalyseRetrograde'              then DecodeChainePasseAnalyseRetrograde(chainePref) else
        if motClef='%PremierCoupParDefaut'                then SetPremierCoupParDefaut(StringEnCoup(chainePref)) else
        if motClef='%nbCasesVidesMinSolitaire'            then nbCasesVidesMinSolitaire := ChaineEnLongint(chainePref) else
        if motClef='%nbCasesVidesMaxSolitaire'            then nbCasesVidesMaxSolitaire := ChaineEnLongint(chainePref) else
        if motClef='%JoueursSaisie'                       then LitPrefDerniersJoueursSaisie(chainePref) else
        if motClef='%TournoisSaisie'                      then LitPrefDerniersTournoisSaisie(chainePref) else
        if motClef='%AnneeSaisie'                         then gInfosSaisiePartie.derniereAnnee := ChaineEnLongint(chainePref) else
        if motClef='%JoueurNoirSaisie'                    then gInfosSaisiePartie.dernierJoueurNoir := ChaineEnLongint(chainePref) else
        if motClef='%JoueurBlancSaisie'                   then gInfosSaisiePartie.dernierJoueurBlanc := ChaineEnLongint(chainePref) else
        if motClef='%TournoiSaisie'                       then gInfosSaisiePartie.dernierTournoi := ChaineEnLongint(chainePref) else  
        if motClef='%DistributionSaisie'                  then gInfosSaisiePartie.derniereDistribution := Max(1,ChaineEnLongint(chainePref)) else    
        if motClef='%nbColonnesFenetreListe'              then nbColonnesFenetreListe := ChaineEnLongint(chainePref) else
        if motClef='%positionDistribution'                then positionDistribution := ChaineEnLongint(chainePref) else
        if motClef='%positionTournoi'                     then positionTournoi := ChaineEnLongint(chainePref) else
        if motClef='%positionNoir'                        then positionNoir := ChaineEnLongint(chainePref) else
        if motClef='%positionBlanc'                       then positionBlanc := ChaineEnLongint(chainePref) else
        if motClef='%positionCoup'                        then positionCoup := ChaineEnLongint(chainePref) else
        if motClef='%positionScoreReel'                   then positionScoreReel := ChaineEnLongint(chainePref) else
        if motClef='%humanWinningStreak'                  then humanWinningStreak := ChaineEnLongint(chainePref) else
        if motClef='%humanScoreLastLevel'                 then humanScoreLastLevel := ChaineEnLongint(chainePref) else
        if motClef='%themeCourantDeCassio'                then themeCourantDeCassio := ChaineEnLongint(chainePref) else
        if motClef='%gNbreMegaoctetsPourLaBase'           then gNbreMegaoctetsPourLaBase := ChaineEnLongint(chainePref) else
        if motClef='%tailleFenetrePlateauAvantPassageEn3D'then tailleFenetrePlateauAvantPassageEn3D := ChaineEnLongint(chainePref) else
        if motClef='%tailleCaseAvantPassageEn3D'          then tailleCaseAvantPassageEn3D := ChaineEnLongint(chainePref) else
        if motClef='%empilementFenetres'                  then VisibiliteInitiale.ordreOuvertureDesFenetres := chainePref else
        if motClef='%ZebraBookOptions'                    then SetZebraBookOptions(ChaineEnLongint(chainePref)) else
        if motClef='%gAideCourante'                       then gAideCourante := PagesAide(ChaineEnLongint(chainePref)) else
        if motClef='%IntervaleProblemesDeCoinDansListe'   then SetIntervaleDeDifficultePourProblemeDePriseDeCoin(ChaineEnLongint(chainePref) div 10,ChaineEnLongint(chainePref) mod 10) else
        if motClef='%PoliceNotesSurLesCases'              then 
           begin
             Parser(chainePref,chainePref,auxStr);
             SetPoliceNameNotesSurCases(kNotesDeCassio,chainePref);
             SetTailleNotesSurCases(kNotesDeCassio,ChaineEnLongint(auxStr));
           end else      
        if motClef='%PoliceBiblioZebraSurLesCases'              then 
           begin
             Parser(chainePref,chainePref,auxStr);
             SetPoliceNameNotesSurCases(kNotesDeZebra,chainePref);
             SetTailleNotesSurCases(kNotesDeZebra,ChaineEnLongint(auxStr));
           end else      
        if motClef='%windowIconisation'                   then 
           begin
             ChaineEnFenetre(chainePref,bidon,IconisationDeCassio.IconisationRect);
             with IconisationDeCassio.IconisationRect , IconisationDeCassio  do
               begin
                 if (right-left)<>LargeurFenetreIconisation then right := left+LargeurFenetreIconisation;
                 if (bottom-top)<>LargeurFenetreIconisation then bottom := top+LargeurFenetreIconisation;
               end;
           end else
	      if motClef='%quellesBasesLire' then
	        with ChoixDistributions do
	         begin
             if chainePref='ToutesLesDistributions' then genre := kToutesLesDistributions else
             if chainePref='QuelquesDistributions'  then genre := kQuelquesDistributions else
             if chainePref='AucuneDistribution'     then genre := kAucuneDistribution;
           end;
       end; 
     end;
    if not(prefVersion40b11Enregistrees) then
      gCouleurOthellier.menuCmd := VertPaleCmd;
   end;
 erreurES := FermeFichierTexte(fichierPref);
 
 if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : sortie');
end;


procedure GetPartiesAReouvrirFromPrefsFile;
var err : OSErr;
    s,motClef,bidStr,chainePref : str255;
begin
 if OpenPrefsFileForSequentialReading() = NoErr then    
	  begin
      while not(EOFInPrefsFile()) do
        begin
          err := GetNextLineInPrefsFile(s);
          if err = NoErr then
            begin
              Parser2(s,motClef,bidStr,chainePref);
              if motClef='%partieAReouvrir'then AjoutePartieDansMenuReouvrir(chainePref);
            end;
        end;
      err := ClosePrefsFile();
    end;
end;

procedure DoDialoguePreferences;
  const 
    PreferencesDialogueID=130;
    OK=1;
    Annuler=2;
    BoutonToujours=7;
    BoutonParfois=8;
    BoutonJamais=9;
    TextNbExplications=10;
    StaticPremiereFois=11;
    VerifierBiblBox=12;
    EnregistrerPrefsBox=13;
    ConfirmationQuitterBox=14;
    ConfirmationArretRetroBox=15;
    TextNbMin=16;
    StaticMin=17;
    NbreMegasBaseText=18;
    NbrePartiesStaticText=20;
    {KaleidoscopeBox=18;
    ZoomRapideBox=19;
    EmulationPCBox=20;}
    SubtilsEffets3DBox=21;
    TaillePionsText=23;
    LisereBox=25;
    PoliceRapportStatic=26;
    PoliceRapportUserItemPopUp=27;
    OmbrageBox=28;
    MenuFlottantPoliceRapportID=3011;
    
  var dp : DialogPtr;
      itemHit : SInt16; 
      PrefsRadios : RadioRec;
      FiltreDialoguePrefsUPP : ModalFilterUPP;
      err : OSErr;
      doitRedessinerOthellier : boolean;
      retirerEffet3DSubtilOthellier2DArrivee : boolean;
      avecLisereNoirSurPionsBlancsArrivee : boolean;
      avecOmbrageDesPionsArrivee : boolean;
      gPourcentageTailleDesPionsArrivee : SInt32;
      gNbreMegaoctetsPourLaBaseArrivee : SInt32;
      themeCourantDeCassioArrivee : SInt32;
      aux : SInt32;
      menuPoliceRapportRect : rect;
      itemMenuPoliceRapport : SInt16; 
      MenuFlottantPoliceRapport : MenuRef;
      nombrePartiesStr,s : str255;
      
  procedure InstalleMenuFlottantPoliceRapport;
  begin
    MenuFlottantPoliceRapport := MyGetMenu(MenuFlottantPoliceRapportID);
	InsertMenu(MenuFlottantPoliceRapport, -1);
  end;
  
  procedure DesinstalleMenuFlottantPoliceRapport;
	begin
	  DeleteMenu(MenuFlottantPoliceRapportID);
	  TerminateMenu(MenuFlottantPoliceRapport,true);
	end; 
  
  procedure InitDialoguePref(Radios : RadioRec);
    begin
      SetIntegerEditableText(dp,TextNbMin,analyseRetrograde.nbMinPourConfirmationArret);
      SetBoolCheckBox(dp,VerifierBiblBox,avecTestBibliotheque);
      SetBoolCheckBox(dp,EnregistrerPrefsBox,avecSauvegardePref);
      SetBoolCheckBox(dp,ConfirmationQuitterBox,doitConfirmerQuitter);
      SetBoolCheckBox(dp,ConfirmationArretRetroBox,analyseRetrograde.doitConfirmerArret);
      {SetBoolCheckBox(dp,ZoomRapideBox,SupprimerLesEffetsDeZoom);
      SetBoolCheckBox(dp,KaleidoscopeBox,OptimisePourKaleidoscope);
      SetBoolCheckBox(dp,EmulationPCBox,sousEmulatorSousPC);}
      SetBoolCheckBox(dp,SubtilsEffets3DBox,retirerEffet3DSubtilOthellier2D);
      SetBoolCheckBox(dp,LisereBox,avecLisereNoirSurPionsBlancs);
      SetBoolCheckBox(dp,OmbrageBox,avecOmbrageDesPions);
      SetIntegerEditableText(dp,TaillePionsText,gPourcentageTailleDesPions);
      SetIntegerEditableText(dp,NbreMegasBaseText,gNbreMegaoctetsPourLaBase);
      
      if (Radios.selection=BoutonJamais) | (Radios.selection=BoutonToujours)
        then SetIntegerEditableText(dp,TextNbExplications,2)
        else SetIntegerEditableText(dp,TextNbExplications,nbExplicationsPasses);
      
      retirerEffet3DSubtilOthellier2DArrivee := retirerEffet3DSubtilOthellier2D;
      gPourcentageTailleDesPionsArrivee := gPourcentageTailleDesPions;
      avecLisereNoirSurPionsBlancsArrivee := avecLisereNoirSurPionsBlancs;
      avecOmbrageDesPionsArrivee := avecOmbrageDesPions;
      gNbreMegaoctetsPourLaBaseArrivee := gNbreMegaoctetsPourLaBase;
      themeCourantDeCassioArrivee := themeCourantDeCassio;
      
      GetDialogItemRect(dp, PoliceRapportUserItemPopUp, menuPoliceRapportRect);
			itemMenuPoliceRapport := themeCourantDeCassio;
    end;
  
  procedure ChangePreferences(Radios : RadioRec);
    begin
      GetLongintEditableText(dp,TextNbMin,analyseRetrograde.nbMinPourConfirmationArret);
      GetBoolCheckBox(dp,VerifierBiblBox,avecTestBibliotheque);
      GetBoolCheckBox(dp,EnregistrerPrefsBox,avecSauvegardePref);
      GetBoolCheckBox(dp,ConfirmationQuitterBox,doitConfirmerQuitter);
      GetBoolCheckBox(dp,ConfirmationArretRetroBox,analyseRetrograde.doitConfirmerArret);
      {GetBoolCheckBox(dp,ZoomRapideBox,SupprimerLesEffetsDeZoom);
      GetBoolCheckBox(dp,KaleidoscopeBox,OptimisePourKaleidoscope);
      GetBoolCheckBox(dp,EmulationPCBox,sousEmulatorSousPC);}
      GetBoolCheckBox(dp,SubtilsEffets3DBox,retirerEffet3DSubtilOthellier2D);
      GetBoolCheckBox(dp,LisereBox,avecLisereNoirSurPionsBlancs);
      GetBoolCheckBox(dp,OmbrageBox,avecOmbrageDesPions);
      GetLongintEditableText(dp,TaillePionsText,gPourcentageTailleDesPions);
      GetLongintEditableText(dp,NbreMegasBaseText,gNbreMegaoctetsPourLaBase);
      
      case Radios.selection of 
         BoutonJamais    : nbExplicationsPasses := 0;
         BoutonToujours  : nbExplicationsPasses := 10000;
         BoutonParfois   : GetIntegerEditableText(dp,TextNbExplications,nbExplicationsPasses);
      end;
      
      if gNbreMegaoctetsPourLaBase <= 0 then gNbreMegaoctetsPourLaBase := 1;
      
      if gIsRunningUnderMacOSX & (gNbreMegaoctetsPourLaBase <> gNbreMegaoctetsPourLaBaseArrivee)
		then ChangeNbPartiesChargeablesPourBase(CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024));
		    
      themeCourantDeCassio := itemMenuPoliceRapport;
    end;
  
  begin
    with PrefsRadios do
      begin
        firstButton := BoutonToujours;
        lastButton := BoutonJamais;
        case nbExplicationsPasses of
              0         : selection := BoutonJamais;
              10000     : selection := BoutonToujours;
              otherWise   selection := BoutonParfois;
            end;
      end;
    BeginDialog;
    FiltreDialoguePrefsUPP := NewModalFilterUPP(@MyFiltreClassiqueRapide);
    dp := MyGetNewDialog(PreferencesDialogueID,FenetreFictiveAvantPlan());
    if dp <> NIL then
    begin
      doitRedessinerOthellier := false;
      
      GetItemTextInDialog(dp,NbrePartiesStaticText,nombrePartiesStr);
      
      s := NumEnString(CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024));
      s := SeparerLesChiffresParTrois(s);
      s := ParamStr(nombrePartiesStr,s,'','','');
      SetItemTextInDialog(dp,NbrePartiesStaticText,s);
      MyDrawDialog(dp);     
           
      InitRadios(dp,PrefsRadios);
      InitDialoguePref(PrefsRadios);
      InstalleMenuFlottantPoliceRapport;
      
      DrawPUItem(MenuFlottantPoliceRapport, itemMenuPoliceRapport, menuPoliceRapportRect, true);  
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreDialoguePrefsUPP,itemHit);
        if (itemHit<>OK) and (itemHit<>Annuler) then
          begin
            case itemHit of
              VirtualUpdateItemInDialog : begin
																						BeginUpdate(GetDialogWindow(dp));
																						SetPortByDialog(dp);
																						MyDrawDialog(dp);
																						DrawPUItem(MenuFlottantPoliceRapport, itemMenuPoliceRapport, menuPoliceRapportRect, true);  
																						OutlineOK(dp);
																						EndUpdate(GetDialogWindow(dp));
																					end;
              BoutonToujours            : PushRadio(dp,PrefsRadios,BoutonToujours);
              BoutonParfois             : PushRadio(dp,PrefsRadios,BoutonParfois);
              BoutonJamais              : PushRadio(dp,PrefsRadios,BoutonJamais);
              TextNbExplications        : begin
                                            PushRadio(dp,PrefsRadios,BoutonParfois);
                                            FiltrerChiffreInEditText(dp,TextNbExplications);
                                          end;
              NbreMegasBaseText         : begin
                                            FiltrerChiffreInEditText(dp,NbreMegasBaseText);
                                            GetLongintEditableText(dp,NbreMegasBaseText,gNbreMegaoctetsPourLaBase);
                                            
                                            s := NumEnString(CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024));
                                            s := SeparerLesChiffresParTrois(s);
                                            s := ParamStr(nombrePartiesStr,s,'','','');
                                            SetItemTextInDialog(dp,NbrePartiesStaticText,s);
                                          end;
              StaticPremiereFois        : PushRadio(dp,PrefsRadios,BoutonParfois);
              VerifierBiblBox           : ToggleCheckBox(dp,VerifierBiblBox);
              EnregistrerPrefsBox       : ToggleCheckBox(dp,EnregistrerPrefsBox);
              ConfirmationQuitterBox    : ToggleCheckBox(dp,ConfirmationQuitterBox);
              ConfirmationArretRetroBox : ToggleCheckBox(dp,ConfirmationArretRetroBox);
              TextNbMin                 : begin
                                            if not(isCheckBoxOn(dp,ConfirmationArretRetroBox)) then
                                              ToggleCheckBox(dp,ConfirmationArretRetroBox);
                                            FiltrerChiffreInEditText(dp,TextNbMin);
                                          end;
              StaticMin                 : ToggleCheckBox(dp,ConfirmationArretRetroBox);
              {ZoomRapideBox             : ToggleCheckBox(dp,ZoomRapideBox);
              KaleidoscopeBox           : ToggleCheckBox(dp,KaleidoscopeBox);
              EmulationPCBox            : ToggleCheckBox(dp,EmulationPCBox);}
              SubtilsEffets3DBox        : begin
                                            ToggleCheckBox(dp,SubtilsEffets3DBox);
                                            if not(gCouleurOthellier.estUneTexture) then
                                              begin
                                                doitRedessinerOthellier := true;
                                                retirerEffet3DSubtilOthellier2D := not(retirerEffet3DSubtilOthellier2D);
                                                InvalidateAllCasesDessinEnTraceDeRayon;
                                                InvalidateAllOffScreenPICTs;
                                                EcranStandard(NIL,true);
                                              end;
                                          end;
              TaillePionsText           : begin
                                            FiltrerChiffreInEditText(dp,TaillePionsText);
                                            GetLongintEditableText(dp,TaillePionsText,aux);
                                            if (aux > 10) & not(gCouleurOthellier.estUneTexture) then
                                              begin
                                                doitRedessinerOthellier := true;
                                                gPourcentageTailleDesPions := aux;
                                                InvalidateAllOffScreenPICTs;
                                                InvalidateAllCasesDessinEnTraceDeRayon;
                                                EcranStandard(NIL,true);
                                              end;
                                          end;
              LisereBox                 : begin
                                            ToggleCheckBox(dp,LisereBox);
                                            if not(gCouleurOthellier.estUneTexture) then
                                              begin
                                                doitRedessinerOthellier := true;
                                                avecLisereNoirSurPionsBlancs := not(avecLisereNoirSurPionsBlancs);
                                                InvalidateAllOffScreenPICTs;
                                                InvalidateAllCasesDessinEnTraceDeRayon;
                                                EcranStandard(NIL,true);
                                              end;
                                          end;
              OmbrageBox                 : begin
                                            ToggleCheckBox(dp,OmbrageBox);
                                            if not(gCouleurOthellier.estUneTexture) then
                                              begin
                                                doitRedessinerOthellier := true;
                                                avecOmbrageDesPions := not(avecOmbrageDesPions);
                                                InvalidateAllOffScreenPICTs;
                                                InvalidateAllCasesDessinEnTraceDeRayon;
                                                EcranStandard(NIL,true);
                                              end;
                                          end;                            
              PoliceRapportUserItemPopUp: begin
                                            if EventPopUpItemInDialog(dp, PoliceRapportStatic, MenuFlottantPoliceRapport, itemMenuPoliceRapport, menuPoliceRapportRect, true, true)
										                          then SelectCassioFonts(itemMenuPoliceRapport);
										                        InvalidateAllWindows;
                                          end;
              
            end;
          end;
      until (itemHit=OK) or (itemHit=Annuler);
      
      {on se prepare pour Annuler, au cas ou}
      retirerEffet3DSubtilOthellier2D := retirerEffet3DSubtilOthellier2DArrivee;
      gPourcentageTailleDesPions      := gPourcentageTailleDesPionsArrivee;
      avecLisereNoirSurPionsBlancs    := avecLisereNoirSurPionsBlancsArrivee;
      avecOmbrageDesPions             := avecOmbrageDesPionsArrivee;
      gNbreMegaoctetsPourLaBase       := gNbreMegaoctetsPourLaBaseArrivee;
      themeCourantDeCassio            := themeCourantDeCassioArrivee;
      
      {mais si on a clique sur OK, il faut vraiment changer}
      if (itemHit=OK) then ChangePreferences(PrefsRadios);
      
      SelectCassioFonts(themeCourantDeCassio);
      if themeCourantDeCassio <> themeCourantDeCassioArrivee 
        then InvalidateAllWindows;
        
      if doitRedessinerOthellier then 
        begin
          InvalidateAllOffScreenPICTs;
          InvalidateAllCasesDessinEnTraceDeRayon;
          EcranStandard(NIL,true);
        end;
      DesinstalleMenuFlottantPoliceRapport;
      MyDisposeDialog(dp);
    end;
    MyDisposeModalFilterUPP(FiltreDialoguePrefsUPP);
    EndDialog;
 end;
 
 
procedure DoDialoguePreferencesAffichage;
  const 
    PreferencesAffichageID = 161;
    OK = 1;
    Annuler = 2;
    
    
    CacherFondBoisADroiteBox = 10;
    AfficheMeilleureSuiteBox = 11;
    AfficheNumeroDernierCoupBox = 12;
    AfficheProchainsCoupsBox = 13;
    
    AfficheSuggestionBox = 14;
    AfficheSignesDiacritiquesBox = 15;
    AffichePierresDeltaBox = 16;
    
    AfficheBibliothequeBox = 17;
    AfficheNotesCassioSurCasesBox = 18;
    
    AfficheCoupsZebraDansArbreBox = 19;
    AfficheNotesZebraSurCasesBox = 20;
    AfficheCouleursZebraDansArbreBox = 21;
    AfficheCouleursZebraSurCasesBox = 22;
    {attention, penser à changer DerniereCheckBox ci-dessous si
     on rajoute des boite a cliquer dans le dialogue}
    
    PremiereCheckBox = 10;
    DerniereCheckBox = 22;
    
    
  var dp : DialogPtr;
      itemHit : SInt16; 
      err : OSErr;
      FiltreDialogueUPP : ModalFilterUPP;

  procedure SetPreferencesAffichageInDialogue;
  begin
    SetBoolCheckBox(dp,CacherFondBoisADroiteBox, garderPartieNoireADroiteOthellier);
    SetBoolCheckBox(dp,AfficheMeilleureSuiteBox, afficheMeilleureSuite);
    SetBoolCheckBox(dp,AfficheNumeroDernierCoupBox, afficheNumeroCoup);
    SetBoolCheckBox(dp,AfficheProchainsCoupsBox, afficheProchainsCoups);
    
    SetBoolCheckBox(dp,AfficheSuggestionBox, afficheSuggestionDeCassio);
    SetBoolCheckBox(dp,AffichePierresDeltaBox, affichePierresDelta);
    SetBoolCheckBox(dp,AfficheSignesDiacritiquesBox, afficheSignesDiacritiques);
    
    SetBoolCheckBox(dp,AfficheBibliothequeBox, afficheBibl);
    SetBoolCheckBox(dp,AfficheNotesCassioSurCasesBox, GetAvecAffichageNotesSurCases(kNotesDeCassio));
    
    SetBoolCheckBox(dp,AfficheCoupsZebraDansArbreBox,    ZebraBookACetteOption(kAfficherNotesZebraDansArbre));
    SetBoolCheckBox(dp,AfficheNotesZebraSurCasesBox,     ZebraBookACetteOption(kAfficherNotesZebraSurOthellier));
    SetBoolCheckBox(dp,AfficheCouleursZebraDansArbreBox, ZebraBookACetteOption(kAfficherCouleursZebraDansArbre));
    SetBoolCheckBox(dp,AfficheCouleursZebraSurCasesBox,  ZebraBookACetteOption(kAfficherCouleursZebraSurOthellier));
  end;
  
  procedure GetPreferencesAffichageFromDialogue;
  var tempoZebraOptions : SInt32;
  begin
  
    if (GetCheckBoxValue(dp,CacherFondBoisADroiteBox) <> garderPartieNoireADroiteOthellier) then DoChangeGarderPartieNoireADroiteOthellier;
      
    if GetCheckBoxValue(dp,AfficheMeilleureSuiteBox) <> afficheMeilleureSuite then DoChangeAfficheMeilleureSuite;
    if GetCheckBoxValue(dp,AfficheNumeroDernierCoupBox) <> afficheNumeroCoup then DoChangeAfficheDernierCoup;
    if GetCheckBoxValue(dp,AfficheProchainsCoupsBox) <> afficheProchainsCoups then DoChangeAfficheProchainsCoups;
    
    if GetCheckBoxValue(dp,AfficheSuggestionBox) <> afficheSuggestionDeCassio then DoChangeAfficheSuggestionDeCassio;
    if GetCheckBoxValue(dp,AffichePierresDeltaBox) <> affichePierresDelta then DoChangeAffichePierresDelta;
    if GetCheckBoxValue(dp,AfficheSignesDiacritiquesBox) <> afficheSignesDiacritiques then DoChangeAfficheSignesDiacritiques;
    
    if GetCheckBoxValue(dp,AfficheBibliothequeBox) <> afficheBibl then DoChangeAfficheBibliotheque;
    if GetCheckBoxValue(dp,AfficheNotesCassioSurCasesBox) <> GetAvecAffichageNotesSurCases(kNotesDeCassio) then DoChangeAfficheNotesSurCases(kNotesDeCassio);
    
    
    tempoZebraOptions := GetZebraBookOptions();
    if GetCheckBoxValue(dp,AfficheCoupsZebraDansArbreBox) <> ZebraBookACetteOption(kAfficherNotesZebraDansArbre) 
      then ToggleZebraOption(kAfficherNotesZebraDansArbre);
    if GetCheckBoxValue(dp,AfficheNotesZebraSurCasesBox) <> ZebraBookACetteOption(kAfficherNotesZebraSurOthellier) 
      then ToggleZebraOption(kAfficherNotesZebraSurOthellier);
    if GetCheckBoxValue(dp,AfficheCouleursZebraDansArbreBox) <> ZebraBookACetteOption(kAfficherCouleursZebraDansArbre) 
      then ToggleZebraOption(kAfficherCouleursZebraDansArbre);
    if GetCheckBoxValue(dp,AfficheCouleursZebraSurCasesBox) <> ZebraBookACetteOption(kAfficherCouleursZebraSurOthellier) 
      then ToggleZebraOption(kAfficherCouleursZebraSurOthellier);
    
    if (tempoZebraOptions <> GetZebraBookOptions()) then
      begin
        LoadZebraBook(false);
        ZebraBookDansArbreDeJeuCourant;  
      
        EffaceNoteSurCases(kNotesDeCassio,othellierToutEntier);
        EffaceNoteSurCases(kNotesDeZebra,othellierToutEntier);
      
        if GetAvecAffichageNotesSurCases(kNotesDeCassio) & (BAND(GetAffichageProprietesOfCurrentNode(),kNotesCassioSurLesCases) <> 0)
		      then DessineNoteSurCases(kNotesDeCassio,othellierToutEntier);
		    
		    if GetAvecAffichageNotesSurCases(kNotesDeZebra) & (BAND(GetAffichageProprietesOfCurrentNode(),kNotesZebraSurLesCases) <> 0)
		      then DessineNoteSurCases(kNotesDeZebra,othellierToutEntier);
		    
		    AfficheProprietesOfCurrentNode(true,othellierToutEntier,'GetPreferencesAffichageFromDialogue');
		    
		    if EstVisibleDansFenetreArbreDeJeu(GetCurrentNode()) then
          begin
            EffaceNoeudDansFenetreArbreDeJeu;
            EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
          end;
            
      end;
    
  end;
  
begin
  BeginDialog;
  FiltreDialogueUPP := NewModalFilterUPP(@MyFiltreClassiqueRapide);
  dp := MyGetNewDialog(PreferencesAffichageID,FenetreFictiveAvantPlan());
  if (dp <> NIL) then
    begin
      SetPreferencesAffichageInDialogue;
      MyDrawDialog(dp);
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreDialogueUPP,itemHit);
        if (itemHit <> OK) & (itemHit <> Annuler) &
           (itemHit >= PremiereCheckBox) & (itemHit <= DerniereCheckBox)
          then 
            begin
              ToggleCheckBox(dp,itemHit);
              GetPreferencesAffichageFromDialogue;
            end;
      until (itemHit=OK) | (itemHit=Annuler);
      if (itemHit=OK) then 
        GetPreferencesAffichageFromDialogue;
      MyDisposeDialog(dp);
    end;
  MyDisposeModalFilterUPP(FiltreDialogueUPP);
  EndDialog;
end;


procedure DoDialoguePreferencesSpeciales;
const DialogueDebugageID=153;
      OK=1;
      Annuler=2;
      PremiereCheckBox=5;
      DerniereCheckBox=40;
var dp : DialogPtr;
    itemHit : SInt16; 
    FiltreDialogueDebuggageUPP : ModalFilterUPP;
    differencierLesFreresArrivee : boolean;
    err : OSErr;
    
  procedure SetVariablesSpecialInDialogue;
  begin
    SetBoolCheckBox(dp,5,debuggage.general);
    {SetBoolCheckBox(dp,6,debuggage.entreesSortiesUnitFichiersTEXT);}
    SetBoolCheckBox(dp,6,GetDebuggageUnitFichiersTexte());
    SetBoolCheckBox(dp,7,debuggage.pendantLectureBase);
    SetBoolCheckBox(dp,8,debuggage.afficheSuiteInitialisations);
    SetBoolCheckBox(dp,9,debuggage.evenementsDansRapport);
    SetBoolCheckBox(dp,10,debuggage.elementsStrategiques);
    SetBoolCheckBox(dp,11,debuggage.gestionDuTemps);
    SetBoolCheckBox(dp,12,debuggage.calculFinaleOptimaleParOptimalite);
    SetBoolCheckBox(dp,13,debuggage.arbreDeJeu);
    SetBoolCheckBox(dp,14,debuggage.lectureSmartGameBoard);
    SetBoolCheckBox(dp,15,debuggage.apprentissage);
    SetBoolCheckBox(dp,16,debuggage.algoDeFinale);
    SetBoolCheckBox(dp,17,debuggage.MacOSX);
    SetBoolCheckBox(dp,28,listeEtroiteEtNomsCourts);
    SetBoolCheckBox(dp,29,InfosTechniquesDansRapport);
    SetBoolCheckBox(dp,30,avecNomOuvertures);
    SetBoolCheckBox(dp,31,enModeIOS);
    SetBoolCheckBox(dp,32,LaDemoApprend);
    SetBoolCheckBox(dp,33,UtiliseGrapheApprentissage);
    SetBoolCheckBox(dp,34,afficheInfosApprentissage);
    SetBoolCheckBox(dp,35,avecRefutationsDansRapport);
    SetBoolCheckBox(dp,36,NePasUtiliserLeGrasFenetreOthellier);
    SetBoolCheckBox(dp,37,GetReveillerRegulierementLeMac());
    SetBoolCheckBox(dp,38,affichageReflexion.afficherToutesLesPasses);
    SetBoolCheckBox(dp,39,CassioUtiliseDesMajuscules);
    SetBoolCheckBox(dp,40,differencierLesFreres);
    
    differencierLesFreresArrivee := differencierLesFreres;
  end;
  
  procedure GetVariablesSpecialesFromDialogue;
  var aux : boolean;
  begin
    GetBoolCheckBox(dp,5,debuggage.general);
    GetBoolCheckBox(dp,6,debuggage.entreesSortiesUnitFichiersTEXT);
    SetDebuggageUnitFichiersTexte(debuggage.entreesSortiesUnitFichiersTEXT);
    GetBoolCheckBox(dp,7,debuggage.pendantLectureBase);
    GetBoolCheckBox(dp,8,debuggage.afficheSuiteInitialisations);
    GetBoolCheckBox(dp,9,debuggage.evenementsDansRapport);
    GetBoolCheckBox(dp,10,debuggage.elementsStrategiques);
    GetBoolCheckBox(dp,11,debuggage.gestionDuTemps);
    GetBoolCheckBox(dp,12,debuggage.calculFinaleOptimaleParOptimalite);
    GetBoolCheckBox(dp,13,debuggage.arbreDeJeu);
    GetBoolCheckBox(dp,14,debuggage.lectureSmartGameBoard);
    GetBoolCheckBox(dp,15,debuggage.apprentissage);
    GetBoolCheckBox(dp,16,debuggage.algoDeFinale);
    GetBoolCheckBox(dp,17,debuggage.MacOSX);
    GetBoolCheckBox(dp,28,listeEtroiteEtNomsCourts);
    GetBoolCheckBox(dp,29,InfosTechniquesDansRapport);
    GetBoolCheckBox(dp,30,avecNomOuvertures);
    GetBoolCheckBox(dp,31,enModeIOS);
    GetBoolCheckBox(dp,32,LaDemoApprend);
    GetBoolCheckBox(dp,33,UtiliseGrapheApprentissage);
    GetBoolCheckBox(dp,34,afficheInfosApprentissage);
    GetBoolCheckBox(dp,35,avecRefutationsDansRapport);
    GetBoolCheckBox(dp,36,NePasUtiliserLeGrasFenetreOthellier);
    GetBoolCheckBox(dp,37,aux);
    SetReveillerRegulierementLeMac(aux);
    GetBoolCheckBox(dp,38,affichageReflexion.afficherToutesLesPasses);
    GetBoolCheckBox(dp,39,CassioUtiliseDesMajuscules);
    GetBoolCheckBox(dp,40,differencierLesFreres);
    
    if (differencierLesFreres <> differencierLesFreresArrivee) then EffaceTousLesNomsCourtsDesJoueurs;
  end;
  
begin
  BeginDialog;
  FiltreDialogueDebuggageUPP := NewModalFilterUPP(@MyFiltreClassiqueRapide);
  dp := MyGetNewDialog(DialogueDebugageID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      SetVariablesSpecialInDialogue;
      MyDrawDialog(dp);
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreDialogueDebuggageUPP,itemHit);
        if (itemHit<>OK) & (itemHit<>Annuler) &
           (itemHit>=PremiereCheckBox) & (itemHit<=DerniereCheckBox)
          then ToggleCheckBox(dp,itemHit);
      until (itemHit=OK) | (itemHit=Annuler);
      if (itemHit=OK) then 
        GetVariablesSpecialesFromDialogue;
      MyDisposeDialog(dp);
    end;
  MyDisposeModalFilterUPP(FiltreDialogueDebuggageUPP);
  EndDialog;
end;
 
 
procedure LitFichierGroupes;
var fichierGroupes : FichierTEXT;
    filename : str255;
    s : str255;
    erreurES : SInt16; 
    nbGroupes,longueur : SInt16; 
begin
  filename := 'groupes Cassio';
  erreurES := FichierTexteDeCassioExiste(filename,fichierGroupes);
  if erreurES<>NoErr then exit(litFichierGroupes);
  erreurES := OuvreFichierTexte(fichierGroupes);
  if erreurES<>NoErr then exit(litFichierGroupes);
  
  nbGroupes := 0;
  repeat
    erreurES := ReadlnDansFichierTexte(fichierGroupes,s);
    if (s<>'') & (erreurES=NoErr) then
      if s[1]='∑' then
        begin
          longueur := Length(s);
          if s[longueur]<>'}' then 
            if longueur=255 
              then s[longueur] := '}'
              else s := s+StringOf('}');
          nbGroupes := nbGroupes+1;
          if nbGroupes<=nbMaxGroupes then
            groupes^^[nbGroupes] := s;
        end;
  until (nbGroupes>=nbMaxGroupes) | (erreurES<>NoErr) | EOFFichierTexte(fichiergroupes,erreurES);
  erreurES := FermeFichierTexte(fichierGroupes);
end;


procedure CreeFichierGroupes;
var fichierGroupes : FichierTEXT;
    filename,s : str255;
    erreurES : SInt16; 
    i : SInt16; 
    
 function ListeDesGroupesEstVide() : boolean;
   var i : SInt16; 
   begin
     ListeDesGroupesEstVide := true;
     for i := 1 to nbMaxGroupes do
       if groupes^^[i]<>'' then
         begin
           ListeDesGroupesEstVide := false;
           exit(ListeDesGroupesEstVide);
         end;
   end;  
   
begin
  if not(ListeDesGroupesEstVide()) then
    begin
      filename := 'groupes Cassio';    
      erreurES := FichierTexteDeCassioExiste(filename,fichierGroupes);
      if erreurES=fnfErr  {-43 => File not found}
        then erreurES := CreeFichierTexteDeCassio(fileName,fichierGroupes);
      if erreurES=NoErr {le fichier groupes existe : on l'ouvre et on le vide}
		    then 
		      begin
		        erreurES := OuvreFichierTexte(fichierGroupes);
		        erreurES := VideFichierTexte(fichierGroupes);
		      end;
      if erreurES <> 0 then exit(CreeFichierGroupes);
      
      for i := 1 to nbMaxGroupes do
        begin
          s := groupes^^[i];
          if s<>'' then
            erreurES := WritelnDansFichierTexte(fichierGroupes,s);
        end;
        
      erreurES := FermeFichierTexte(fichierGroupes);
      SetFileCreatorFichierTexte(fichierGroupes,'SNX4'); 
      SetFileTypeFichierTexte(fichierGroupes,'sgma');
    end;
end;


procedure GereSauvegardePreferences;
var cheminThorDBA,cheminThorDBASol : str255;
    volRefThorDBA,volRefThorDBASol : SInt16; 
begin
  if avecSauvegardePref 
    then CreeFichierPreferences
    else
      begin
        cheminThorDBA := CheminAccesThorDBA^^;
	      cheminThorDBASol := CheminAccesThorDBASolitaire^^;
	      volRefThorDBA := VolumeRefThorDBA;
	      volRefThorDBASol := VolumeRefThorDBASolitaire;
			  LitFichierPreferences;
			      
	      CheminAccesThorDBA^^ := cheminThorDBA;
	      CheminAccesThorDBASolitaire^^ := cheminThorDBASol;
	      VolumeRefThorDBA := volRefThorDBA;
	      VolumeRefThorDBASolitaire := volRefThorDBASol;
	      avecSauvegardePref := false;
			  CreeFichierPreferences;
      end;
end;


procedure SauvegarderListeOfPrefsFiles;
var filename : str255;
    erreurES : OSErr;
    fic : FichierTEXT;
    s : str255;
    i : SInt32;
begin
  filename := 'PrefCassioFileList.txt';    
  erreurES := FichierTexteDeCassioExiste(filename,fic);
  if erreurES=fnfErr  {-43 => File not found}
    then erreurES := CreeFichierTexteDeCassio(fileName,fic);
  if erreurES=NoErr {le fichier de la liste des fichiers preference existe : on l'ouvre et on le vide}
    then 
      begin
        erreurES := OuvreFichierTexte(fic);
        erreurES := VideFichierTexte(fic);
      end;
  if erreurES <> 0 then exit(SauvegarderListeOfPrefsFiles);
  
  for i := 1 to kMaxPrefFiles do
    if (gListeOfPrefFiles[i].date <> '') & 
       (gListeOfPrefFiles[i].name <> '') then
      begin
        s := gListeOfPrefFiles[i].date + ' ' + gListeOfPrefFiles[i].name;
        erreurES := WritelnDansFichierTexte(fic,s);
      end;
  
  erreurES := FermeFichierTexte(fic);
end;


procedure LireListeOfPrefsFiles;
var filename : str255;
    erreurES : OSErr;
    fic : FichierTEXT;
    s : str255;
    i,nbPrefFiles : SInt32;
begin

  for i := 1 to kMaxPrefFiles do
    begin
      gListeOfPrefFiles[i].date := '';
      gListeOfPrefFiles[i].name := '';
    end;
      
  filename := 'PrefCassioFileList.txt';    
  erreurES := FichierTexteDeCassioExiste(filename,fic);
  if erreurES=NoErr 
    then erreurES := OuvreFichierTexte(fic);
  if erreurES <> 0 then exit(LireListeOfPrefsFiles);
  

  nbPrefFiles := 0;
  repeat
    erreurES := ReadlnDansFichierTexte(fic,s);
    if (s <> '') & (erreurES=NoErr) then
      begin
        inc(nbPrefFiles);
        Parser(s,gListeOfPrefFiles[nbPrefFiles].date,gListeOfPrefFiles[nbPrefFiles].name);
      end;
  until (nbPrefFiles >= kMaxPrefFiles) | (erreurES<>NoErr) | EOFFichierTexte(fic,erreurES);
  
  erreurES := FermeFichierTexte(fic);
end;


procedure AjouterNomDansListOfPrefsFiles(whichName : str255);
var i,indexCourant : SInt32;
begin

  if (whichName <> kNomParDefauFichierPreferences) then
    begin
    
      LireListeOfPrefsFiles;

      {chercher quel enregistrement ecraser}
      indexCourant := kMaxPrefFiles;
      for i := kMaxPrefFiles downto 1 do
        if gListeOfPrefFiles[i].name = whichName then
          indexCourant := i;
      
      {placer le nom courant en tete}
      for i := indexCourant downto 2 do
        begin
          gListeOfPrefFiles[i].date := gListeOfPrefFiles[i-1].date;
          gListeOfPrefFiles[i].name := gListeOfPrefFiles[i-1].name;
        end;
      gListeOfPrefFiles[1].date := DateCouranteEnString();
      gListeOfPrefFiles[1].name := whichName;
      
      SauvegarderListeOfPrefsFiles;
    end;
end;


function NameOfPrefsFile() : str255;
var s,s1 : str255;
    nomDeLApplication : str255;
begin
  s := ReadStringFromRessource(TextesDiversID,3);
  
  nomDeLApplication := GetApplicationName('Cassio');
  if (nomDeLApplication = 'Cassio') | (nomDeLApplication = 'Cassio.app')
    then nomDeLApplication := 'Cassio ' + VersionDeCassioEnString();
  
  if Pos("^0",s)>0
    then s1 := ParamStr(s,nomDeLApplication,"","","")
    else s1 := s; 
    
 if Length(s1) <= 31
   then NameOfPrefsFile := s1
   else NameOfPrefsFile := kNomParDefauFichierPreferences;
end;



function OpenPrefsFileForSequentialReading() : OSErr;
var filename : str255;
    autreFichierPreferencesSuggere : str255;
    erreurES : SInt16; 
    i : SInt32;
begin
  filename := NameOfPrefsFile();
  
  erreurES := FichierPreferencesDeCassioExiste(fileName,gPrefsFileInfos.filePtr); 
  
  
  if erreurES=fnfErr then 
   begin
     {fichier préférences non trouvé = > on essaie de lire les vieux fichiers de preferences}
     
     LireListeOfPrefsFiles;
     for i := 1 to kMaxPrefFiles do
       begin
         autreFichierPreferencesSuggere := gListeOfPrefFiles[i].name;
         if (erreurES = fnfErr) & (autreFichierPreferencesSuggere <> '') then
           begin
             erreurES := FichierPreferencesDeCassioExiste(autreFichierPreferencesSuggere,gPrefsFileInfos.filePtr);
             if erreurES = NoErr then 
               begin
                 filename := autreFichierPreferencesSuggere;
                 if (i > 1) then AjouterNomDansListOfPrefsFiles(filename);
               end;
           end;
       end;
   end;
  
  if (erreurES <> NoErr) then 
    begin
      OpenPrefsFileForSequentialReading := erreurES;
      exit(OpenPrefsFileForSequentialReading);
    end;
   
   erreurES := OuvreFichierTexte(gPrefsFileInfos.filePtr);
   if erreurES <> 0 then
     begin
       OpenPrefsFileForSequentialReading := erreurES;
       exit(OpenPrefsFileForSequentialReading);
     end;
    
  gPrefsFileInfos.nbOfLastLineRead := 0;
  gPrefsFileInfos.lastLineRead := '';
  OpenPrefsFileForSequentialReading := erreurES;
end;



function GetNextLineInPrefsFile(var s : str255) : OSErr;
var erreurES : OSErr;
begin
  erreurES := ReadlnDansFichierTexte(gPrefsFileInfos.filePtr,s);
  if erreurES <> 0 then
     begin
       GetNextLineInPrefsFile := erreurES;
       exit(GetNextLineInPrefsFile);
     end;
  
  gPrefsFileInfos.nbOfLastLineRead := gPrefsFileInfos.nbOfLastLineRead+1;
  gPrefsFileInfos.lastLineRead := s;
  GetNextLineInPrefsFile := erreurES;
end;



function EOFInPrefsFile() : boolean;
var erreurES : OSErr;
begin
  EOFInPrefsFile := EOFFichierTexte(gPrefsFileInfos.filePtr,erreurES)
end;



function ClosePrefsFile() : OSErr;
begin
  ClosePrefsFile := FermeFichierTexte(gPrefsFileInfos.filePtr);
end;


end.