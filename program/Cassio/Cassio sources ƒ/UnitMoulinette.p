UNIT UnitMoulinette;


INTERFACE







  
USES MyTypes,UnitFichiersTEXT,StringTypes,UnitFormatsFichiers,UnitDefinitionsPackedThorGame;


{ Utilitaires pour parser des proprietes (entre guillemets) de fichiers PGN ou XOF }
procedure ParserScoreTheoriqueDansFichierPGN(const ligne : str255; var theorique : SInt32);
procedure ParserJoueurDansFichierPNG(const nomDictionnaireDesPseudos,ligne : str255; var pseudo,nomDansThor : str255; var numero : SInt32);
procedure ParserTournoiDansFichierPNG(const nomDictionnaireDesPseudos,ligne : str255;numeroTournoiParDefaut : SInt32; var pseudo,nomDansThor : str255; var numero : SInt32);


{ Moulinettes d'import }
procedure ImportBaseAllDrawLinesDeBougeard;
function  ImporterFichierPartieDansListe(var fs : FSSpec; isFolder : boolean; path : str255; var pb:CInfoPBRec) : boolean;
function  AjouterPartiesFichierPGNDansListe(nomDictionnaireDesPseudos : str255;fichierPGN : FichierTEXT) : OSErr;
function  AjouterPartiesFichierDestructureDansListe(format:formats_connus;fic : FichierTEXT) : OSErr;
procedure BaseLogKittyEnFormatThor(nomBaseLogKitty,NomBaseFormatThor : str255);
procedure ImporterToutesPartiesRepertoire;


{ Moulinettes d'export }
procedure ExportListeAuFormatTexte(descriptionLigne : str255; var nbPartiesExportees : SInt32);
procedure ExportListeAuFormatPGN;
procedure ExportListeAuFormatHTML;
procedure ExportListeAuFormatXOF;


{ Export d'une partie individuelle }
procedure ExporterPartieDansFichierHTML(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
procedure ExporterPartieDansFichierTexte(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
procedure ExporterPartieDansFichierPGN(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
procedure ExporterPartieDansFichierXOF(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);



IMPLEMENTATION







USES UnitNouveauFormat,UnitBaseNouveauFormat,UnitAccesStructuresNouvFormat,UnitStringSet,UnitRapport,
     UnitRapportImplementation,UnitOth1,UnitUtilitaires,UnitOth2,UnitListe,UnitJeu,SNSTrings,
     UnitEntreesSortiesListe,UnitGameTree,UnitArbreDeJeuCourant,UnitImportDesNoms,MyFileSystemUtils,
     UnitFormatsFichiers,UnitMiniprofiler,UnitDialog,UnitPressePapier,MyStrings,UnitTHOR_PAR,
     UnitScannerOthellistique,UnitGenericGameFormat,UnitFenetres,UnitGestionDuTemps,UnitNormalisation,
     UnitCouleur,UnitPackedThorGame;


      
var gOptionsExportBase : record
                           patternLigne : str255;
                           fic : FichierTEXT;
                           nomsFichiersUtilises : StringSet;
                         end;
    gTablePartiesJoueursImprobables : StringSet;
    

procedure ParserJoueurDansFichierPNG(const nomDictionnaireDesPseudos,ligne : str255; var pseudo,nomDansThor : str255; var numero : SInt32);
var oldParsingProtection : boolean;
    s1,reste : str255;
begin
  oldParsingProtection := GetParsingProtectionWithQuotes();
  SetParsingProtectionWithQuotes(true);
  
  Parser2(ligne,s1,pseudo,reste);
  pseudo := DeleteSubstringBeforeThisChar('"',pseudo,false);
  pseudo := DeleteSubstringAfterThisChar('"',pseudo,false);
  
  SetParsingProtectionWithQuotes(oldParsingProtection);
  
  if not(PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudo,nomDansThor,numero))
    then AjoutePseudoInconnu('pseudo inconnu : ',pseudo,nomDansThor);
end;


procedure ParserTournoiDansFichierPNG(const nomDictionnaireDesPseudos,ligne : str255;numeroTournoiParDefaut : SInt32; var pseudo,nomDansThor : str255; var numero : SInt32);
var oldParsingProtection : boolean;
    s1,reste : str255;
begin
  oldParsingProtection := GetParsingProtectionWithQuotes();
  SetParsingProtectionWithQuotes(true);
  
  Parser2(ligne,s1,pseudo,reste);
  pseudo := DeleteSubstringBeforeThisChar('"',pseudo,false);
  pseudo := DeleteSubstringAfterThisChar('"',pseudo,false);
    
  SetParsingProtectionWithQuotes(oldParsingProtection);
  
  if not(PeutImporterNomTournoiFormatPGN(nomDictionnaireDesPseudos,pseudo,nomDansThor,numero)) then
    begin
      AjoutePseudoInconnu('tournoi inconnu : ',pseudo,nomDansThor);
      numero := numeroTournoiParDefaut;
    end;
end;


procedure ParserDateDansFichierPGN(const ligne : str255; var annee,mois,jour : SInt32);
var date,f1,f2,f3,s1,reste : str255;
    oldParsingSet : SetOfChar;
    oldParsingProtection : boolean;
begin
  oldParsingProtection := GetParsingProtectionWithQuotes();
  SetParsingProtectionWithQuotes(true);
  
  Parser2(ligne,s1,date,reste);
  date := DeleteSubstringBeforeThisChar('"',date,false);
  date := DeleteSubstringAfterThisChar('"',date,false);
  
  SetParsingProtectionWithQuotes(oldParsingProtection);
  
  oldParsingSet := GetParsingCaracterSet();
  SetParsingCaracterSet(['.','-']);
  
  Parser3(date,f1,f2,f3,reste);
  annee := ChaineEnLongint(f1);
  mois  := ChaineEnLongint(f2);
  jour  := ChaineEnLongint(f3);
  
  SetParsingCaracterSet(oldParsingSet);
end;


procedure ParserScoreTheoriqueDansFichierPGN(const ligne : str255; var theorique : SInt32);
var score : str255;
    oldParsingProtection : boolean;
begin
  oldParsingProtection := GetParsingProtectionWithQuotes();
  SetParsingProtectionWithQuotes(true);
  
  score := DeleteSubstringBeforeThisChar('"',ligne,false);
  score := DeleteSubstringAfterThisChar('"',score,false);
  score := DeleteSubstringAfterThisChar('-',score,false);
  
  theorique := ChaineEnLongint(score);
  
  SetParsingProtectionWithQuotes(oldParsingProtection);
end;


procedure EssayerInterpreterJoueursPGNCommeNomDeFichier(pseudoNoir,pseudoBlanc : str255; var numeroNoir,numeroBlanc : SInt32; var confiance : extended);
var chaineJoueurs : str255;
    partieJoueursImprobables : str255;
    aux : SInt32;
begin

  (* on crée un nom de fichier fictif le plus ressemblant possible *)
  if (numeroNoir <> kNroJoueurInconnu) & 
    (numeroBlanc <> kNroJoueurInconnu) 
    then chaineJoueurs := GetNomJoueurEnMajusculesSansEspace(numeroNoir) + ' 32 - 32 ' + GetNomJoueurEnMajusculesSansEspace(numeroBlanc) else
  if (numeroNoir <> kNroJoueurInconnu) 
    then chaineJoueurs := GetNomJoueurEnMajusculesSansEspace(numeroNoir) + ' 32 - 32 ' + pseudoBlanc else
  if (numeroBlanc <> kNroJoueurInconnu)
    then chaineJoueurs := pseudoNoir + ' 32 - 32 ' + GetNomJoueurEnMajusculesSansEspace(numeroBlanc) 
    else chaineJoueurs := pseudoNoir + ' 32 - 32 ' + pseudoBlanc;
    
  (* et on essaye de l'interpreter *)
  if TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,6,confiance) then
    if (confiance < 0.80) then
      begin
        partieJoueursImprobables := pseudoNoir + ' - ' + pseudoBlanc;
        if not(MemberOfStringSet(partieJoueursImprobables,aux,gTablePartiesJoueursImprobables)) then
          begin 
            AddStringToSet(partieJoueursImprobables,0,gTablePartiesJoueursImprobables);
            ChangeFontColorDansRapport(RougeCmd);
            WritelnDansRapport(partieJoueursImprobables + ' --> '+GetNomJoueur(numeroNoir) + ' - ' + GetNomJoueur(numeroBlanc));
            TextNormalDansRapport;
          end;
      end;
end;



function AjouterPartiesFichierPGNDansListe(nomDictionnaireDesPseudos : str255;fichierPGN : FichierTEXT) : OSErr;
var ligne,s,coupsPotentiels : str255;
    nroReferencePartieAjoutee : SInt32;
    partieEnAlpha : str255;
    partieLegale : boolean;
    nbPartiesDansFichierPGN : SInt32;
    erreurES : OSErr;
    partieNF:t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
    numeroTournoiParDefaut : SInt32;
    nbCoupsRecus : SInt16; 
    nbPionsNoirs,nbPionsBlancs : SInt32;
    numeroNoir,numeroBlanc,numeroTournoi : SInt32;
    pseudoNoir,pseudoBlanc,pseudoTournoi : str255;
    annee,tickDepart : SInt32;
    anneeDansRecord,moisDansRecord,jourDansRecord : SInt32;
    nomNoir,nomBlanc,nomTournoi : str255;
    compteurDoublons,aux : SInt32;
    nomFichierPGN : str255;
    nomLongDuFichier : str255;
    tableDoublons : StringSet;
    autoVidage : boolean;
    ecritLog : boolean;
    partieComplete : boolean;
    partieInternet : boolean;
    utilisateurVeutSortir : boolean;
    theorique : SInt32;
    confiance : extended;
label sauter_cette_partie;

  
begin {AjouterPartiesFichierPGNDansListe}

  if not(FenetreRapportEstOuverte()) then OuvreFntrRapport(false,true) else
  if not(FenetreRapportEstAuPremierPlan()) then SelectWindowSousPalette(GetRapportWindow());
  
  autoVidage := GetAutoVidageDuRapport();
  ecritLog := GetEcritToutDansRapportLog();
  SetEcritToutDansRapportLog(false);
  SetAutoVidageDuRapport(true);

  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  tickDepart := TickCount();
  GetTime(myDate);
  
  
  nomFichierPGN := ExtraitNomDirectoryOuFichier(fichierPGN.theFSSpec.name);
  erreurES := FSSpecToLongName(fichierPGN.theFSSpec,nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
  nomFichierPGN := DeleteSubstringAfterThisChar('.',nomFichierPGN,false);
  
  if not(JoueursEtTournoisEnMemoire) then
    begin
      WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
      WritelnDansRapport('');
      DoLectureJoueursEtTournoi(false);
    end;
  
  numeroTournoi := -1;
  if (myDate.month <= 6) & TrouveNumeroDuTournoi('parties internet (1-6)',numeroTournoiParDefaut,0) then;
  if (myDate.month >  6) & TrouveNumeroDuTournoi('parties internet (7-12)',numeroTournoiParDefaut,0) then;
  if numeroTournoi < 0 then numeroTournoiParDefaut := kNroTournoiDiversesParties;
  annee := myDate.year;
     
     
  erreurES := OuvreFichierTexte(fichierPGN);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomFichierPGN,erreurES);
      AjouterPartiesFichierPGNDansListe := erreurES;
      exit(AjouterPartiesFichierPGNDansListe);
    end;
  
 
  compteurDoublons := 0;
   
  nbPartiesDansFichierPGN := 0;
  erreurES := NoErr;
  utilisateurVeutSortir := false;
  ligne := '';
  tableDoublons := MakeEmptyStringSet();
  gTablePartiesJoueursImprobables := MakeEmptyStringSet();
  
  (* on efface les caches des pseudos car l'utilisateur peut avoir changé le
     dictionnaire "name_mapping_VOG_to_WThor.txt" depuis la derniere fois   *)
  with gImportDesNoms do
    begin
      DisposeStringSet(pseudosInconnus);
      DisposeStringSet(pseudosNomsDejaVus);
      DisposeStringSet(pseudosTournoisDejaVus);
      DisposeStringSet(nomsReelsARajouterDansBase);
      DisposeStringSet(pseudosAyantUnNomReel);
    end;
  
  while not(EOFFichierTexte(fichierPGN,erreurES)) & not(utilisateurVeutSortir) do
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
  
      if (Pos('[Event',ligne) = 0) then
        begin
          erreurES := ReadlnDansFichierTexte(fichierPGN,s);
          ligne := s;
        end;
      
      {WritelnDansRapport(ligne);}
        
      EnleveEspacesDeGaucheSurPlace(ligne);
      if (ligne='') | (ligne[1]='%') 
        then
          begin
          end
        else
          begin
          
            if Pos('[Event',ligne) > 0 then
              begin  {lire une partie}
                
                {WritelnDansRapport('');}
                {WritelnDansRapport(ligne);}
                
                partieComplete := false;
                partieLegale := true;
                partieInternet := false;
                partieEnAlpha := '';
                nbCoupsRecus := 0;
                pseudoNoir := '';
                pseudoBlanc := '';
                pseudoTournoi := '';
                anneeDansRecord := -1;
                moisDansRecord := -1;
                jourDansRecord := -1;
                theorique := -1;
                
                ParserTournoiDansFichierPNG(nomDictionnaireDesPseudos,ligne,numeroTournoiParDefaut,pseudoTournoi,nomTournoi,numeroTournoi);
              
                repeat
                  erreurES := ReadlnDansFichierTexte(fichierPGN,s);
      			      ligne := s;
      			      EnleveEspacesDeGaucheSurPlace(ligne);
      			      
      			      {WritelnDansRapport(ligne);}
      			      {Sysbeep(0);
      			      AttendFrappeClavier;}
      			      
      			      if (Pos('[White ',ligne) > 0) | (Pos('[White"',ligne) > 0) 
      			        then ParserJoueurDansFichierPNG(nomDictionnaireDesPseudos,ligne,pseudoBlanc,nomBlanc,numeroBlanc) else
      			      
      			      if (Pos('[Black ',ligne) > 0) | (Pos('[Black"',ligne) > 0) 
      			        then ParserJoueurDansFichierPNG(nomDictionnaireDesPseudos,ligne,pseudoNoir,nomNoir,numeroNoir) else
      			        
      			      if (Pos('[Site "kurnik',ligne) > 0) | (Pos('[Site "www.kurnik',ligne) > 0) | 
      			         (Pos('[Site "VOG',ligne) > 0)
      			        then partieInternet := true else
      			        
      			      if (Pos('[Date "',ligne) > 0)
      			        then ParserDateDansFichierPGN(ligne,anneeDansRecord,moisDansRecord,jourDansRecord) else
      			      
      			      if (Pos('[TheoricalScore "',ligne) > 0) | (Pos('[TheoreticalScore "',ligne) > 0)
      			        then ParserScoreTheoriqueDansFichierPGN(ligne,theorique) else
      			        
      			      if (Pos('.',ligne) > 0) & (Pos('[',ligne) = 0) then
      			        begin  {coup(s)}
      			        
      			          coupsPotentiels := ligne;
      			          CompacterPartieAlphanumerique(coupsPotentiels,kCompacterEnMajuscules);
      			          
      			          if (coupsPotentiels <> '') then
      			            begin
      			              partieEnAlpha := partieEnAlpha + coupsPotentiels;
      			              nbCoupsRecus := nbCoupsRecus + (Length(coupsPotentiels) div 2);
      			            end;
      			        end;
      			      
      			      
      			      partieComplete := EstUnePartieOthelloTerminee(partieEnAlpha,true,nbPionsNoirs,nbPionsBlancs);
			      
			          utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue();
			      
                until partieComplete | 
                      InRange(Pos('0-1',ligne),1,2) | 
                      InRange(Pos('1/2-1/2',ligne),1,2) | 
                      InRange(Pos('1-0',ligne),1,2) |
                      (Pos('[Event',ligne) > 0) |
                      EOFFichierTexte(fichierPGN,erreurES) |
                      utilisateurVeutSortir;
                
                if Pos('[Event',ligne) = 0 then ligne := '';
                
                
                (*
                WritelnDansRapport(partieEnAlpha);
                WritelnDansRapport(pseudoNoir);
                WritelnDansRapport(pseudoBlanc);
                *)
                
                partieLegale := (nbCoupsRecus > 10) & EstUnePartieOthelloAvecMiroir(partieEnAlpha);
                
                {on cherche si on a deja mis la partie}
                if MemberOfStringSet(partieEnAlpha,aux,tableDoublons) &
                   MemberOfStringSet(Concat(partieEnAlpha,' '),aux,tableDoublons) then
                   begin
                     partieLegale := false;
                     WritelnDansRapport('doublon : ' + LeftOfString(partieEnAlpha,60));
                     compteurDoublons := compteurDoublons + 1;
                   end;
                
                if partieLegale then
                  begin
                    inc(nbPartiesDansFichierPGN);
                    
                    AddStringToSet(partieEnAlpha,0,tableDoublons);
                    AddStringToSet(Concat(partieEnAlpha,' '),0,tableDoublons);
                    
                    if (anneeDansRecord > 0) then annee := anneeDansRecord;
                    
                    if partieInternet & (numeroTournoi = numeroTournoiParDefaut) then
                      begin
                        if (moisDansRecord >= 1) & (moisDansRecord <= 6)  then numeroTournoi := kNroTournoiPartiesInternet_1_6 else
                        if (moisDansRecord >= 7) & (moisDansRecord <= 12) then numeroTournoi := kNroTournoiPartiesInternet_7_12
                          else numeroTournoi := kNroTournoiPartiesInternet;
                      end;
                    
                    
                    if not(partieComplete) then 
                      begin
                        if partieInternet & (nbCoupsRecus >= 40) & PeutCompleterPartieAvecLigneOptimale(partieEnAlpha) 
                          then
                            begin
                              ChangeFontColorDansRapport(VertCmd);
                              WritelnDansRapport('partie complétée :-)');
                              TextNormalDansRapport;
                            end
                          else
                            begin
                              ChangeFontColorDansRapport(RougeCmd);
                              WritelnDansRapport('incomplete : '+LeftOfString(partieEnAlpha,60));
                              TextNormalDansRapport;
                              if partieInternet then goto sauter_cette_partie;
                            end;
                      end;
                    
                   
                    (* Si on a eu du mal a reconnaitre l'un des joueurs, on fait appel 
                       a une routine  plus sophistiquee, mais plus lente... 
                     *)
                    if (numeroNoir = kNroJoueurInconnu) | (numeroBlanc = kNroJoueurInconnu) then
                      EssayerInterpreterJoueursPGNCommeNomDeFichier(pseudoNoir,pseudoBlanc,numeroNoir,numeroBlanc,confiance);
                      
                    
                    SetAutorisationCalculsLongsSurListe(false);
                    if AjouterPartieAlphaDansLaListe(partieEnAlpha,theorique,numeroNoir,numeroBlanc,numeroTournoi,annee,partieNF,nroReferencePartieAjoutee) then;
                    SetAutorisationCalculsLongsSurListe(true);
                    
                    
                  sauter_cette_partie:
                    
                    
                    
                    if (nbPartiesDansFichierPGN mod 50 = 0) then
                      begin
                        WritelnStringAndNumDansRapport('',nbPartiesDansFichierPGN);
                        TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
                        CalculsEtAffichagePourBase(false,false);
                      end;
                  end;
                
                PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
                if TickCount()-dernierTick >= delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer); 
                  
              end;
            
          
          end;
    end;
  
  DisposeStringSet(tableDoublons);
  DisposeStringSet(gTablePartiesJoueursImprobables);
  
  erreurES := FermeFichierTexte(fichierPGN);

  WritelnDansRapport('');
  if EstUnNomDeFichierTemporaireDePressePapier(fichierPGN.theFSSpec.name)
    then
      if (nbPartiesDansFichierPGN > 1)
        then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,44),NumEnString(nbPartiesDansFichierPGN),'','',''))  {J'ai réussi à importer ^0 parties depuis le presse-papier}
        else WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,45),NumEnString(nbPartiesDansFichierPGN),'','',''))  {J'ai réussi à importer ^0 partie depuis le presse-papier}
    else
      if (nbPartiesDansFichierPGN > 1)
        then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,42),NumEnString(nbPartiesDansFichierPGN),nomLongDuFichier,'',''))   {J'ai réussi à importer ^0 parties dans le fichier « ^1 »}
        else WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,43),NumEnString(nbPartiesDansFichierPGN),nomLongDuFichier,'',''));  {J'ai réussi à importer ^0 partie dans le fichier « ^1 »}
  {WritelnStringAndNumDansRapport('temps de lecture en ticks = ',TickCount() - tickDepart);}
  WritelnDansRapport('');
  AjusteCurseur;
  
  SetAutorisationCalculsLongsSurListe(true);
  TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
  CalculsEtAffichagePourBase(false,false);
  
  SetAutoVidageDuRapport(autoVidage);
  SetEcritToutDansRapportLog(ecritLog);
  
  AjouterPartiesFichierPGNDansListe := erreurES;
end;




function AjouterPartiesFichierDestructureDansListe(format:formats_connus;fichier : FichierTEXT) : OSErr;
var nroReferencePartieAjoutee : SInt32;
    partieEnAlpha : str255;
    chaineJoueurs : str255;
    nomsDesJoueursParDefaut : str255;
    partieLegale : boolean;
    nbPartiesDansFic : SInt32;
    erreurES : OSErr;
    partieNF:t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
    nbCoupsRecus : SInt16; 
    nbPionsNoirs,nbPionsBlancs : SInt32;
    numeroNoir,numeroBlanc,numeroTournoi : SInt32;
    annee,tickDepart : SInt32;
    compteurDoublons,aux : SInt32;
    nomFic : str255;
    nomLongDuFichier : str255;
    tableDoublons : StringSet;
    autoVidage : boolean;
    ecritLog : boolean;
    partieComplete : boolean;
    joueursTrouves : boolean;
    utilisateurVeutSortir : boolean;
    theorique : SInt32;
    dernierLigneLue : str255;
    nombreDeLignesLues : SInt32;
    confianceDansLesJoueurs : extended;
    bidReal : extended;
    myZone : ZoneMemoire;
  
  
  function GetNextLineDansFichierDestructure(var s : str255) : OSErr;
  begin
    GetNextLineDansFichierDestructure := ReadlnDansZoneMemoire(myZone,s);
    EnleveEspacesDeGaucheSurPlace(s);
    dernierLigneLue := s;
    inc(nombreDeLignesLues);
  end;
  
  
  function TrouveJoueurs() : str255;
  var s,result : str255;
  begin
    result := dernierLigneLue;
    
    while (result = '') & not(utilisateurVeutSortir) & (erreurES = NoErr) & not(EOFZoneMemoire(myZone,erreurES)) do
      begin
        erreurES := GetNextLineDansFichierDestructure(s);
        result := result + s;
        utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue();
      end;
    
    TrouveJoueurs := result;
    dernierLigneLue := '';
  end;
  
  function TrouvePartie() : str255;
  var s,result : str255;
      partieComplete : boolean;
      partieIllegale : boolean;
      nbCoups,dernierNbCoups : SInt32;
  begin
    partieComplete := false;
    partieIllegale := false;
    result := '';
    dernierNbCoups := -1000;
    nbCoups := -500;
    
    repeat
      erreurES := GetNextLineDansFichierDestructure(s);
      
      if (s <> '') then
        begin
          result := result + s;
          
          if EstUnePartieOthelloAvecMiroir(result) then
            partieComplete := EstUnePartieOthelloTerminee(result,false,nbPionsNoirs,nbPionsBlancs);
            
          partieIllegale := (result = '') | not(EstUnePartieOthello(result,false));
          
          {
          WritelnDansRapport('s = '+s);
          WritelnDansRapport('result = '+result);
          WritelnStringAndBooleenDansRapport('partieIllegale = ',partieIllegale);
          WritelnDansRapport('');}
          
          dernierNbCoups := nbCoups;
          nbCoups := Length(result) div 2;
        end;
        
      utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue();
      
    until (nbCoups = dernierNbCoups) | partieComplete | partieIllegale | utilisateurVeutSortir | (erreurES <> NoErr) | EOFZoneMemoire(myZone,erreurES);
    
    TrouvePartie := result;
    if partieComplete | partieIllegale then dernierLigneLue := '';
  end;

  procedure LitProchainePartieFormatGGF(var chaineJoueurs,partieEnAlpha : str255);
  var theGame:PartieFormatGGFRec;
  begin
    partieEnAlpha := '';
    chaineJoueurs := '';
    
    erreurES := ReadEnregistrementDansZoneMemoireSGF_ou_GGF(myZone,kTypeFichierGGF,theGame);
    
    partieEnAlpha := theGame.coupsEnAlpha;
    
    if (theGame.joueurNoir = '') | (theGame.joueurBlanc = '')
      then chaineJoueurs := nomsDesJoueursParDefaut
      else
        if EstUnePartieOthelloAvecMiroir(partieEnAlpha) & 
           EstUnePartieOthelloTerminee(partieEnAlpha,true,nbPionsNoirs,nbPionsBlancs)
          then chaineJoueurs := theGame.joueurNoir + ' '+ScoreFinalEnChaine(nbPionsNoirs-nbPionsBlancs)+' ' + theGame.joueurBlanc
          else chaineJoueurs := theGame.joueurNoir + ' 0-0 ' + theGame.joueurBlanc;
    
    utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue();
  end;
  
  procedure LitProchaineLigneAvecJoueursEtPartie(var chaineJoueurs,partieEnAlpha : str255; var confianceDansLesJoueurs : extended);
  var s,moves : str255;
      partieTrouvee : boolean;
      nbPionsNoirs,nbPionsBlancs : SInt32;
  begin
    partieTrouvee := false;
    s := '';
    partieEnAlpha := '';
    chaineJoueurs := '';
    
    repeat
      erreurES := GetNextLineDansFichierDestructure(s);
      EnleveEspacesDeGaucheSurPlace(s);
      
      if (s <> '') then
        begin
          partieTrouvee := TrouverPartieEtJoueursDansChaine(s,moves,numeroNoir,numeroBlanc,confianceDansLesJoueurs);
          if partieTrouvee 
            then 
              begin {on symetrie la partie trouvee, eventuellement}
                partieTrouvee := partieTrouvee & EstUnePartieOthelloAvecMiroir(moves); 
              end
            else
              begin {on n'a pas trouvee des joueurs, mais peut-etre y a-t-il au moins une partie ?}
                partieTrouvee := EstUnePartieOthelloAvecMiroir(s);
                if partieTrouvee then
                  begin
                    moves       := s;
                    numeroNoir  := kNroJoueurInconnu;
                    numeroBlanc := kNroJoueurInconnu;
                  end;
              end;
           
        end;
        
      utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue();
      
    until partieTrouvee | utilisateurVeutSortir | (erreurES <> NoErr) | EOFZoneMemoire(myZone,erreurES);
    
    if partieTrouvee then
      begin
        partieEnAlpha := moves;
        if EstUnePartieOthelloTerminee(moves,false,nbPionsNoirs,nbPionsBlancs)
          then chaineJoueurs := GetNomJoueur(numeroNoir) + ' '+ScoreFinalEnChaine(nbPionsNoirs-nbPionsBlancs)+' ' + GetNomJoueur(numeroBlanc)
          else chaineJoueurs := GetNomJoueur(numeroNoir) + ' 0-0 ' + GetNomJoueur(numeroBlanc);
      end;
    
  end;
  
  
  procedure LitProchaineLigneAvecPartie(var chaineJoueurs,partieEnAlpha : str255);
  var s : str255;
      partieTrouvee : boolean;
  begin
    partieTrouvee := false;
    s := '';
    chaineJoueurs := '';
    partieEnAlpha := '';
    
    repeat
      erreurES := GetNextLineDansFichierDestructure(s);
      EnleveEspacesDeGaucheSurPlace(s);
      
      if (s <> '') then
        begin
          partieTrouvee := EstUnePartieOthelloAvecMiroir(s); 
          if partieTrouvee 
            then 
              begin 
                partieEnAlpha := s;
                chaineJoueurs := nomsDesJoueursParDefaut;
              end;
           
        end;
        
      utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue();
      
    until partieTrouvee | utilisateurVeutSortir | (erreurES <> NoErr) | EOFZoneMemoire(myZone,erreurES);
    
  end;
  
  
begin {AjouterPartiesFichierDestructureDansListe}

  if not(FenetreRapportEstOuverte()) then OuvreFntrRapport(false,true) else
  if not(FenetreRapportEstAuPremierPlan()) then SelectWindowSousPalette(GetRapportWindow());
  
  autoVidage := GetAutoVidageDuRapport();
  ecritLog := GetEcritToutDansRapportLog();
  SetEcritToutDansRapportLog(false);
  SetAutoVidageDuRapport(true);

  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  tickDepart := TickCount();
  GetTime(myDate);
  
  
  nomFic := ExtraitNomDirectoryOuFichier(fichier.theFSSpec.name);
  erreurES := FSSpecToLongName(fichier.theFSSpec,nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
  nomFic := DeleteSubstringAfterThisChar('.',nomFic,false);
  nomsDesJoueursParDefaut := nomLongDuFichier;
  
  
  if not(JoueursEtTournoisEnMemoire) then
    begin
      WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
      WritelnDansRapport('');
      DoLectureJoueursEtTournoi(false);
    end;
  
     
  erreurES := OuvreFichierTexte(fichier);
  if (erreurES <> NoErr) then 
    begin
      AlerteSimpleFichierTexte(nomLongDuFichier,erreurES);
      AjouterPartiesFichierDestructureDansListe := erreurES;
      exit(AjouterPartiesFichierDestructureDansListe);
    end;
  FermerFichierEtFabriquerZoneMemoire(fichier,myZone);
  
  annee := myDate.year;
  if not(TrouverNomDeTournoiDansPath(fichier.nomFichier,numeroTournoi,annee,'name_mapping_VOG_to_WThor.txt'))
    then numeroTournoi := kNroTournoiDiversesParties;
 
 
  nombreDeLignesLues := 0;
  nbPartiesDansFic := 0;
  erreurES := NoErr;
  utilisateurVeutSortir := false;
  dernierLigneLue := '';
  
  compteurDoublons := 0;
  tableDoublons := MakeEmptyStringSet();
  
  (* on efface les caches des pseudos car l'utilisateur peut avoir changé le
     dictionnaire "name_mapping_VOG_to_WThor.txt" depuis la derniere fois   *)
  with gImportDesNoms do
    begin
      DisposeStringSet(pseudosInconnus);
      DisposeStringSet(pseudosNomsDejaVus);
      DisposeStringSet(pseudosTournoisDejaVus);
      DisposeStringSet(nomsReelsARajouterDansBase);
      DisposeStringSet(pseudosAyantUnNomReel);
    end;
  
  while not(EOFZoneMemoire(myZone,erreurES)) & not(utilisateurVeutSortir) & (erreurES = NoErr) do
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
  
      
      {lire une partie}
            
      joueursTrouves := false;
      partieLegale := false;
      nbCoupsRecus := 0;
      numeroNoir := kNroJoueurInconnu;
      numeroBlanc := kNroJoueurInconnu;
      theorique := -1;
      
      case format of
        kTypeFichierSuiteDePartiePuisJoueurs :
          begin
            partieEnAlpha := TrouvePartie();
            chaineJoueurs := TrouveJoueurs();
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs);
          end;
        kTypeFichierSuiteDeJoueursPuisPartie :
          begin
            chaineJoueurs := TrouveJoueurs();
            partieEnAlpha := TrouvePartie();
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs);
          end;
        kTypeFichierGGFMultiple :
          begin
            LitProchainePartieFormatGGF(chaineJoueurs,partieEnAlpha);
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs);
          end;
        kTypeFichierMultiplesLignesAvecJoueursEtPartie :
          begin
            LitProchaineLigneAvecJoueursEtPartie(chaineJoueurs,partieEnAlpha,confianceDansLesJoueurs);
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,bidReal);
          end;
        kTypeFichierSimplementDesCoupsMultiple :
          begin
            LitProchaineLigneAvecPartie(chaineJoueurs,partieEnAlpha);
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs);
          end;
        otherwise
          begin
            WritelnDansRapport('ERROR !! format impossible dans AjouterPartiesFichierDestructureDansListe, prévenez Stéphane !');
            partieEnAlpha := '';
            chaineJoueurs := '';
            erreurES := -1;
            utilisateurVeutSortir := true;
          end;
            
      end; {case}
        
      {WritelnDansRapport(partieEnAlpha);
      WritelnDansRapport(chaineJoueurs);}
    
      nbCoupsRecus := Length(partieEnAlpha) div 2;
    
      
      
	    partieComplete := EstUnePartieOthelloTerminee(partieEnAlpha,true,nbPionsNoirs,nbPionsBlancs);
      
      partieLegale := (nbCoupsRecus > 10) & EstUnePartieOthelloAvecMiroir(partieEnAlpha);
      
      {on cherche si on a deja mis la partie}
      if MemberOfStringSet(partieEnAlpha,aux,tableDoublons) &
         MemberOfStringSet(Concat(partieEnAlpha,' '),aux,tableDoublons) then
         begin
           partieLegale := false;
           WritelnDansRapport('doublon : '+partieEnAlpha);
           compteurDoublons := compteurDoublons + 1;
         end;
      
      if partieLegale then
        begin
          inc(nbPartiesDansFic);
          
          AddStringToSet(partieEnAlpha,0,tableDoublons);
          AddStringToSet(Concat(partieEnAlpha,' '),0,tableDoublons);
          
         
          
          {WritelnStringAndReelDansRapport('conf = ',confianceDansLesJoueurs,3);}
          if joueursTrouves
            then 
              begin
                if (confianceDansLesJoueurs < 0.80) then ChangeFontColorDansRapport(RougeCmd);
                WritelnDansRapport(chaineJoueurs);
                TextNormalDansRapport;
              end
            else
              begin
                ChangeFontColorDansRapport(RougeCmd);
                if not((format = kTypeFichierSimplementDesCoupsMultiple) & (chaineJoueurs = nomLongDuFichier))
                  then WritelnDansRapport(chaineJoueurs);
                TextNormalDansRapport;
              end;
          
          if partieComplete
            then 
              WritelnDansRapport(partieEnAlpha)
            else
              begin
                ChangeFontColorDansRapport(RougeCmd);
                WritelnDansRapport({'incomplete : '+}partieEnAlpha);
                TextNormalDansRapport;
              end;
              
          WritelnDansRapport('');
          
          SetAutorisationCalculsLongsSurListe(false);
          if AjouterPartieAlphaDansLaListe(partieEnAlpha,theorique,numeroNoir,numeroBlanc,numeroTournoi,annee,partieNF,nroReferencePartieAjoutee) then;
          SetAutorisationCalculsLongsSurListe(true);
          
          if (nbPartiesDansFic mod 50 = 0) then
            begin
              {WritelnStringAndNumDansRapport('',nbPartiesDansFic);}
              TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
              CalculsEtAffichagePourBase(false,false);
            end;
        end;
      
      PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
      if TickCount()-dernierTick >= delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer); 
                  
    end;
  
  DisposeStringSet(tableDoublons);
  
  DisposeZoneMemoireEtOuvrirFichier(fichier,myZone);
  erreurES := FermeFichierTexte(fichier);

  WritelnDansRapport('');
  if EstUnNomDeFichierTemporaireDePressePapier(fichier.theFSSpec.name)
    then
      if (nbPartiesDansFic > 1)
        then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,44),NumEnString(nbPartiesDansFic),'','',''))  {J'ai réussi à importer ^0 parties depuis le presse-papier}
        else WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,45),NumEnString(nbPartiesDansFic),'','',''))  {J'ai réussi à importer ^0 partie depuis le presse-papier}
    else
      if (nbPartiesDansFic > 1)
        then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,42),NumEnString(nbPartiesDansFic),nomLongDuFichier,'',''))   {J'ai réussi à importer ^0 parties dans le fichier « ^1 »}
        else WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,43),NumEnString(nbPartiesDansFic),nomLongDuFichier,'',''));  {J'ai réussi à importer ^0 partie dans le fichier « ^1 »}
  
  if (nbPartiesDansFic < nombreDeLignesLues)
    then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,46),NumEnString(nombreDeLignesLues),'','',''));   {Pour info, ce fichier contenait ^0 lignes}
  {WritelnStringAndNumDansRapport('temps de lecture en ticks = ',TickCount() - tickDepart);}
  
  WritelnDansRapport('');
  AjusteCurseur;
  
  SetAutorisationCalculsLongsSurListe(true);
  TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
  CalculsEtAffichagePourBase(false,false);
  
  SetAutoVidageDuRapport(autoVidage);
  SetEcritToutDansRapportLog(ecritLog);
  
  AjouterPartiesFichierDestructureDansListe := erreurES;
end;





procedure BaseLogKittyEnFormatThor(nomBaseLogKitty,NomBaseFormatThor : str255);
{ attention! On doit être dans le bon repertoire, ou nomfichier doit etre un path complet }
var ligne,s,partieEnAlpha,scoreEnChaine,numeroLigneEnChaine,reste : str255;
    partieEnThor : PackedThorGame; 
    partie120:str120;
    autreCoupQuatreDiag : boolean;
    score,nbPartiesDansBaseLogKitty,i : SInt32;
    erreurES : OSErr;
    inputBaseLogKitty,outputBaseThor : FichierTEXT;
    enteteFichierPartie : t_EnTeteNouveauFormat;
    partieNF:t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
begin

  WritelnDansRapport('entrée dans BaseLogKittyEnFormatThor…');


  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  
  if nomBaseLogKitty='' then 
    begin
      AlerteSimpleFichierTexte(nomBaseLogKitty,0);
      exit(BaseLogKittyEnFormatThor);
    end;
  {SetDebuggageUnitFichiersTexte(false);}
  

  erreurES := FichierTexteDeCassioExiste(nomBaseLogKitty,inputBaseLogKitty);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomBaseLogKitty,erreurES);
      exit(BaseLogKittyEnFormatThor);
    end;
     
  erreurES := OuvreFichierTexte(inputBaseLogKitty);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomBaseLogKitty,erreurES);
      exit(BaseLogKittyEnFormatThor);
    end;
  
  erreurES := FichierTexteDeCassioExiste(NomBaseFormatThor,outputBaseThor);
  if erreurES=fnfErr then erreurES := CreeFichierTexteDeCassio(NomBaseFormatThor,outputBaseThor);
  if erreurES=0 then
    begin
      erreurES := OuvreFichierTexte(outputBaseThor);
      erreurES := VideFichierTexte(outputBaseThor);
    end;
  if erreurES <> 0 then
    begin
      AlerteSimpleFichierTexte(NomBaseFormatThor,erreurES);
      erreurES := FermeFichierTexte(outputBaseThor);
      exit(BaseLogKittyEnFormatThor);
    end;
		          
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(NomBaseFormatThor,erreurES);
      exit(BaseLogKittyEnFormatThor);
    end;
   
  nbPartiesDansBaseLogKitty := 0;
  erreurES := NoErr;
  ligne := '';
  while not(EOFFichierTexte(inputBaseLogKitty,erreurES)) do
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
  
      erreurES := ReadlnDansFichierTexte(inputBaseLogKitty,s);
      ligne := s;
      EnleveEspacesDeGaucheSurPlace(ligne);
      if (ligne='') | (ligne[1]='%') 
        then
          begin
            {erreurES := WritelnDansFichierTexte(outputBaseThor,s);}
          end
        else
          begin
            Parser3(ligne,PartieEnAlpha,scoreEnChaine,numeroLigneEnChaine,reste);
            
            
            if (PartieEnAlpha <> '') & (scoreEnChaine <> '') then
              begin
                inc(nbPartiesDansBaseLogKitty);
                
                
                partie120 := partieEnAlpha;
                Normalisation(partie120,autreCoupQuatreDiag,false);
                partieEnAlpha := partie120;

                TraductionAlphanumeriqueEnThor(PartieEnAlpha,partieEnThor);
                if (GET_LENGTH_OF_PACKED_GAME(partieEnThor) <= 10) | (GET_LENGTH_OF_PACKED_GAME(partieEnThor) > 60) then 
                  begin
                    WritelnDansRapport('problème sur la longueur de la partie : '+partieEnAlpha);
                    SysBeep(0);
                  end;
                
                ChaineToLongint(scoreEnChaine,score);
                if odd(score) then
                  if score>0 then inc(score) else dec(score);
                score := (score+64) div 2;
                if score<0 then SysBeep(0);
                if score>64 then SysBeep(0);
                
                {
                WritelnStringAndNumDansRapport(PartieEnAlpha+'  => ',score);
                }
                if (nbPartiesDansBaseLogKitty mod 1000)=0 then
                  WritelnStringAndNumDansRapport('…',nbPartiesDansBaseLogKitty);
                
                
                partieNF.scoreTheorique := score;
                partieNF.scoreReel := score;
                partieNF.nroTournoi := kNroTournoiDiversesParties;
                partieNF.nroJoueurNoir := kNroJoueurLogistello;
                partieNF.nroJoueurBlanc := kNroJoueurLogistello;
                for i := 1 to GET_LENGTH_OF_PACKED_GAME(partieEnThor) do
                  partieNF.listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partieEnThor,i,'BaseLogKittyEnFormatThor');
                for i := (GET_LENGTH_OF_PACKED_GAME(partieEnThor) + 1) to 60 do
                  partieNF.listeCoups[i] := 0;
                
                
                
                erreurES := EcritPartieNouveauFormat(outputBaseThor.refNum,nbPartiesDansBaseLogKitty,partieNF);
                
                
              end;
          
          end;
    end;
  
  
  GetTime(myDate);
  with enteteFichierPartie do
    begin
      SiecleCreation                         := myDate.year div 100;
      AnneeCreation                          := myDate.year mod 100;
      MoisCreation                           := myDate.month;
      JourCreation                           := myDate.day;
      NombreEnregistrementsParties           := nbPartiesDansBaseLogKitty;
      NombreEnregistrementsTournoisEtJoueurs := 0;
      AnneeParties                           := 1999;
      TailleDuPlateau                        := 8;  {taille du plateau de jeu}
      EstUnFichierSolitaire                  := 0;  {1 = solitaires, 0 = autres cas}
      ProfondeurCalculTheorique              := 24;  {profondeur de calcul du score theorique}
      reservedByte                           := 0;
    end;
  erreurES := EcritEnteteNouveauFormat(outputBaseThor.refNum,enteteFichierPartie);
  
  erreurES := FermeFichierTexte(inputBaseLogKitty);
  erreurES := FermeFichierTexte(outputBaseThor);
  SetFileCreatorFichierTexte(outputBaseThor,'SNX4');
  SetFileTypeFichierTexte(outputBaseThor,'QWTB');

  
  AjusteCurseur;
end;





procedure ExporterPartieDansFichierTexte(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
var erreurES : OSErr;
    partieEnAlpha : str255;
    ligne : str255;
    partieEnSuedois : str60; 
    partie60 : str60;
begin
  with gOptionsExportBase do
    begin
      
      ligne := patternLigne;
      
      (* echappement *)
      while (Pos('\\',ligne) > 0) do
        ligne := ReplaceStringByStringInString('\\','‰Ω',ligne);
      while (Pos('\$',ligne) > 0) do
        ligne := ReplaceStringByStringInString('\$','◊√',ligne);
        
      TraductionThorEnAlphanumerique(theGame,partieEnAlpha);
      TraductionThorEnSuedois(theGame,partieEnSuedois);
      COPY_PACKED_GAME_TO_STR60(theGame,partie60);
      
      (* un numero (non fixe entre les sessions de Cassio) pour la partie *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_GAME_ID'        ,NumEnString(numeroReference)                                                   ,ligne);
      
      (* les coups de la partie *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_THOR_MOVES'     ,partie60                                                                       ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_SWEDISH_MOVES'  ,partieEnSuedois                                                                ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_GAME'           ,partieEnAlpha                                                                  ,ligne);
      
      (* Les tournois *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_TOURN_SHORT'    ,MyStripDiacritics(GetNomCourtTournoiParNroRefPartie(numeroReference))          ,ligne);
      if EstUnePartieAvecTournoiJaponais(numeroReference)
        then ligne := ReplaceVariableByStringInString('$CASSIO_TOURN_JAPANESE' ,GetNomJaponaisDuTournoiParNroRefPartie(numeroReference)                        ,ligne)
        else ligne := ReplaceVariableByStringInString('$CASSIO_TOURN_JAPANESE' ,MyStripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))               ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_TOURN_NUMBER'   ,NumEnString(GetNroTournoiParNroRefPartie(numeroReference))                     ,ligne);
      
      { bien penser a mettre toutes les variables qui commencent par $CASSIO_TOURN avant la ligne suivante }
      ligne := ReplaceVariableByStringInString(       '$CASSIO_TOURN'          ,MyStripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))               ,ligne);
      
      (* les joueurs *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_BLACK_SHORT'    ,MyStripDiacritics(GetNomJoueurNoirSansPrenomParNroRefPartie(numeroReference))  ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_WHITE_SHORT'    ,MyStripDiacritics(GetNomJoueurBlancSansPrenomParNroRefPartie(numeroReference)) ,ligne);
      if EstUnePartieAvecJoueurNoirJaponais(numeroReference)
        then ligne := ReplaceVariableByStringInString('$CASSIO_BLACK_JAPANESE' ,GetNomJaponaisDuJoueurNoirParNroRefPartie(numeroReference)                     ,ligne)
        else ligne := ReplaceVariableByStringInString('$CASSIO_BLACK_JAPANESE' ,GetNomJoueurNoirCommeDansPappParNroRefPartie(numeroReference)                  ,ligne);
      if EstUnePartieAvecJoueurBlancJaponais(numeroReference)
        then ligne := ReplaceVariableByStringInString('$CASSIO_WHITE_JAPANESE' ,GetNomJaponaisDuJoueurBlancParNroRefPartie(numeroReference)                    ,ligne)
        else ligne := ReplaceVariableByStringInString('$CASSIO_WHITE_JAPANESE' ,GetNomJoueurBlancCommeDansPappParNroRefPartie(numeroReference)                 ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_BLACK_NUMBER'   ,NumEnString(GetNroJoueurNoirParNroRefPartie(numeroReference))                  ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_WHITE_NUMBER'   ,NumEnString(GetNroJoueurBlancParNroRefPartie(numeroReference))                 ,ligne);
      
      { bien pensser a mettre toutes les variables qui commencent par $CASSIO_BLACK et $CASSIO_WHITE avant les deux lignes suivantes }
      ligne := ReplaceVariableByStringInString(       '$CASSIO_BLACK'          ,GetNomJoueurNoirCommeDansPappParNroRefPartie(numeroReference)                  ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_WHITE'          ,GetNomJoueurBlancCommeDansPappParNroRefPartie(numeroReference)                 ,ligne);
      
      (* les scores reels et theoriques *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_SCORE_BLACK'    ,NumEnString(GetScoreReelParNroRefPartie(numeroReference))                      ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_SCORE_WHITE'    ,NumEnString(64-GetScoreReelParNroRefPartie(numeroReference))                   ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_THEOR_BLACK'    ,NumEnString(GetScoreTheoriqueParNroRefPartie(numeroReference))                 ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_THEOR_WHITE'    ,NumEnString(64-GetScoreTheoriqueParNroRefPartie(numeroReference))              ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_THEOR_WINNER'   ,GetGainTheoriqueParNroRefPartie(numeroReference)                               ,ligne);
      
      (* le nom de la base et l'annee *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_BASE'           ,GetNomDistributionParNroRefPartie(numeroReference)                             ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_YEAR'           ,NumEnString(GetAnneePartieParNroRefPartie(numeroReference))                    ,ligne);
      
      
      (* echappement *)
      while (Pos('◊√',ligne) > 0) do
        ligne := ReplaceStringByStringInString('◊√','$',ligne);
      while (Pos('‰Ω',ligne) > 0) do
        ligne := ReplaceStringByStringInString('‰Ω','\',ligne);

      erreurES := WritelnDansFichierTexte(fic,ligne);
      inc(compteur);
      
      if (compteur mod 1000) = 0 then
        WritelnDansRapport('Export : '+NumEnString(compteur)+' parties…');
        
    end;
end;


procedure ExporterPartieDansFichierPGN(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
var erreurES : OSErr;
    s,s1,s2,ligne : str255;
    k : SInt32;
begin
  with gOptionsExportBase do
    begin
      
      ligne := '[Event "'+MyStripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne := '[Date "'+NumEnString(GetAnneePartieParNroRefPartie(numeroReference))+'.01.01"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne := '[Round "-"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne := '[Database "'+MyStripDiacritics(GetNomDistributionParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne := '[Black "'+MyStripDiacritics(GetNomJoueurNoirParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne := '[White "'+MyStripDiacritics(GetNomJoueurBlancParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne := '[Result "'+NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                           NumEnString(64-GetScoreReelParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne := '[TheoreticalScore "'+NumEnString(GetScoreTheoriqueParNroRefPartie(numeroReference)) + '-' +
                                     NumEnString(64-GetScoreTheoriqueParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      erreurES := WritelnDansFichierTexte(fic,'');
                           
      TraductionThorEnAlphanumerique(theGame,s);
      for k := 1 to 59 do
        begin
          s1 := TPCopy(s,k*2 - 1,2);
          if s1 = '' then s1 := '--';
          s2 := TPCopy(s,k*2 + 1,2);
          if s2 = '' then s2 := '--';
          if odd(k) then 
            begin
              ligne := NumEnString(1 + (k div 2)) + '. '+s1+' '+s2+' ';
              erreurES := WritelnDansFichierTexte(fic,ligne);
            end;
        end;
      
      ligne := NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' + NumEnString(64-GetScoreReelParNroRefPartie(numeroReference));
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      erreurES := WritelnDansFichierTexte(fic,'');
      erreurES := WritelnDansFichierTexte(fic,'');
      
      inc(compteur);
      
      if (compteur mod 1000) = 0 then
        WritelnDansRapport('Export : '+NumEnString(compteur)+' parties…');
        
    end;
end;


procedure ExporterPartieDansFichierXOF(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
var erreurES : OSErr;
    moves,ligne : str255;
begin
  with gOptionsExportBase do
    begin
      
      
      ligne :=  '  <game>';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne :=  '   <event'+
                ' date="'+NumEnString(GetAnneePartieParNroRefPartie(numeroReference))+'"' +
                ' name="'+MyStripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))+'"' +
                ' />';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      if GetScoreReelParNroRefPartie(numeroReference) > 32 then
        begin
          ligne :=  '   <result'+
                    ' winner="black"' +
                    ' type="normal">' +
                     NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                     NumEnString(64-GetScoreReelParNroRefPartie(numeroReference)) +
                    '</result>';
          erreurES := WritelnDansFichierTexte(fic,ligne);
        end;
      
      if GetScoreReelParNroRefPartie(numeroReference) = 32 then
        begin
          ligne :=  '   <result'+
                    ' winner="draw"' +
                    ' type="normal">' +
                     NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                     NumEnString(64-GetScoreReelParNroRefPartie(numeroReference)) +
                    '</result>';
          erreurES := WritelnDansFichierTexte(fic,ligne);
        end;
      
      if GetScoreReelParNroRefPartie(numeroReference) < 32 then
        begin
          ligne :=  '   <result'+
                    ' winner="white"' +
                    ' type="normal">' +
                     NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                     NumEnString(64-GetScoreReelParNroRefPartie(numeroReference)) +
                    '</result>';
          erreurES := WritelnDansFichierTexte(fic,ligne);
        end;
        
      ligne :=  '   <player'+
                ' color="black"' +
                ' name="'+MyStripDiacritics(GetNomJoueurNoirParNroRefPartie(numeroReference))+'"' +
                ' />';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne :=  '   <player'+
                ' color="white"' +
                ' name="'+MyStripDiacritics(GetNomJoueurBlancParNroRefPartie(numeroReference))+'"' +
                ' />';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      TraductionThorEnAlphanumerique(theGame,moves);
      ligne :=  '   <moves game="othello-8x8" type="flat">' + 
                moves +
                '</moves>';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      ligne :=  '  </game>';
      erreurES := WritelnDansFichierTexte(fic,ligne);
      
      inc(compteur);
      
      if (compteur mod 1000) = 0 then
        WritelnDansRapport('Export : '+NumEnString(compteur)+' parties…');
        
    end;
end;



procedure ExportListeAuFormatTexte(descriptionLigne : str255; var nbPartiesExportees : SInt32);
var reply : SFReply;
    prompt : str255;
    whichSpec : FSSpec;
    erreurES : OSErr;
    exportTexte : FichierTEXT;
    compteur : SInt32;
begin

  nbPartiesExportees := 0;
  
  GetIndString(prompt,TextesDiversID,11); {'Nom du fichier d''export ? '}
  reply.fname := 'Export.txt';
  if MakeFileName(reply,prompt,whichSpec) then
    begin
    
      erreurES := FichierTexteExisteFSp(whichSpec,exportTexte);
      if erreurES=fnfErr {-43 => fichier non trouvé, on le crée}
        then erreurES := CreeFichierTexteFSp(whichSpec,exportTexte);
      if erreurES=NoErr then
        begin
          erreurES := OuvreFichierTexte(exportTexte);
          erreurES := VideFichierTexte(exportTexte);
        end;
      if erreurES<>NoErr then
        begin
          AlerteSimpleFichierTexte(reply.fName,erreurES);
          erreurES := FermeFichierTexte(exportTexte);
          exit(ExportListeAuFormatTexte);
        end;
        
      gOptionsExportBase.patternLigne    := descriptionLigne;
      gOptionsExportBase.fic             := exportTexte;
        
      (* WritelnDansRapport('descriptionLigne = '+ descriptionLigne); *)
      
      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierTexte,compteur);
      
      erreurES := FermeFichierTexte(exportTexte);
      
      WritelnDansRapport('Export : '+NumEnString(compteur)+' parties…');
      nbPartiesExportees := compteur;
    end;
end;


procedure ExportListeAuFormatPGN;
var reply : SFReply;
    prompt : str255;
    whichSpec : FSSpec;
    erreurES : OSErr;
    exportFichier : FichierTEXT;
    compteur,nbPartiesExportees : SInt32;
begin

  nbPartiesExportees := 0;
  
  GetIndString(prompt,TextesDiversID,11); {'Nom du fichier d''export ? ';}
  reply.fname := 'Export.pgn';
  if MakeFileName(reply,prompt,whichSpec) then
    begin
    
      erreurES := FichierTexteExisteFSp(whichSpec,exportFichier);
      if erreurES=fnfErr {-43 => fichier non trouvé, on le crée}
        then erreurES := CreeFichierTexteFSp(whichSpec,exportFichier);
      if erreurES=NoErr then
        begin
          erreurES := OuvreFichierTexte(exportFichier);
          erreurES := VideFichierTexte(exportFichier);
        end;
      if erreurES<>NoErr then
        begin
          AlerteSimpleFichierTexte(reply.fName,erreurES);
          erreurES := FermeFichierTexte(exportFichier);
          exit(ExportListeAuFormatPGN);
        end;
        
      gOptionsExportBase.fic             := exportFichier;
      
      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierPGN,compteur);
      
      erreurES := FermeFichierTexte(exportFichier);
      
      WritelnDansRapport('Export : '+NumEnString(compteur)+' parties…');
      nbPartiesExportees := compteur;
    end;
end;





procedure ExportListeAuFormatXOF;
var reply : SFReply;
    prompt,ligne : str255;
    whichSpec : FSSpec;
    erreurES : OSErr;
    exportFichier : FichierTEXT;
    compteur,nbPartiesExportees : SInt32;
    myDate : DateTimeRec;
begin

  nbPartiesExportees := 0;
  
  GetIndString(prompt,TextesDiversID,11); {'Nom du fichier d''export ? '}
  reply.fname := 'Export.xml';
  if MakeFileName(reply,prompt,whichSpec) then
    begin
      GetTime(myDate);
    
      erreurES := FichierTexteExisteFSp(whichSpec,exportFichier);
      if erreurES=fnfErr {-43 => fichier non trouvé, on le crée}
        then erreurES := CreeFichierTexteFSp(whichSpec,exportFichier);
      if erreurES=NoErr then
        begin
          erreurES := OuvreFichierTexte(exportFichier);
          erreurES := VideFichierTexte(exportFichier);
        end;
      if erreurES<>NoErr then
        begin
          AlerteSimpleFichierTexte(reply.fName,erreurES);
          erreurES := FermeFichierTexte(exportFichier);
          exit(ExportListeAuFormatXOF);
        end;
        
      gOptionsExportBase.fic             := exportFichier;
      
      
      ligne :=  '<?xml version="1.0" encoding="UTF-8"?>';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);
      
      ligne :=  '<!DOCTYPE database SYSTEM "xof.dtd">';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);
      
      WritelnDansRapport('');
      
      ligne :=  '<database xmlns="http://www.othbase.net/xof">';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);
      
      ligne :=  ' <info version="1.1"'+
                   ' date="'+NumEnStringAvecFormat(myDate.year,4)+'-'+
                             NumEnStringAvecFormat(myDate.month,2)+'-'+
                             NumEnStringAvecFormat(myDate.day,2)+'"'+
                   ' author="'+'Cassio '+VersionDeCassioEnString+'" />';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);
      
      ligne :=  ' <game-collection>';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);
      
      
 
 
 
      
      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierXOF,compteur);
      
      
      
      ligne :=  ' </game-collection>';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);
      
      ligne :=  '</database>';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);
       


 
 
      erreurES := FermeFichierTexte(exportFichier);
      
      WritelnDansRapport('Export : '+NumEnString(compteur)+' parties…');
      nbPartiesExportees := compteur;
    end;
end;


procedure ExporterPartieDansFichierHTML(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
const kLongueurNomsDansURL=13;
var erreurES : OSErr;
    s,ligne,ligneSansEspace : str255;
    nom1,nom2 : str255;
    nomFichierOutput : str255;
    fichierHTMLOutput : FichierTEXT;
    fichierModeleHTML : FichierTEXT;
    compteurLignes,data : SInt32;
begin

  if PartieEstActiveEtSelectionnee(numeroReference) then
    begin
  
      fichierModeleHTML := gOptionsExportBase.fic;
      erreurES := SetPositionTeteLectureFichierTexte(fichierModeleHTML,0);
      
      if (erreurES = NoErr) then
        begin
          inc(compteur);
          
          gOptionsExportBase.fic := fichierHTMLOutput;
          compteurLignes := 0;
          
          
          nom1 := GetNomJoueurNoirCommeDansPappParNroRefPartie(numeroReference);
          nom2 := GetNomJoueurBlancCommeDansPappParNroRefPartie(numeroReference);
          (*if nom1 > nom2 then
            begin
              s := nom1;
              nom1 := nom2;
              nom2 := s;
            end;
            *)
          {nom1 := ReplaceStringByStringInString(' ','_',nom1);
          nom2 := ReplaceStringByStringInString(' ','_',nom2);}
          (*
          for i := 1 to kLongueurNomsDansURL do 
            begin
              nom1 := nom1 + ' ';
              nom2 := nom2 + ' ';
            end;*)
          nomFichierOutput := ExtraitCheminDAcces(fichierModeleHTML.nomFichier) + 
                              LeftOfString(nom1,kLongueurNomsDansURL)+'-'+
                              LeftOfString(nom2,kLongueurNomsDansURL)+'.htm';
          
          WritelnDansRapport(nomFichierOutput+'...');
          
          erreurES := FichierTexteExiste(nomFichierOutput,0,fichierHTMLOutput);
          if erreurES=fnfErr 
            then 
              begin
                {-43 => fichier non trouvé, on le crée}
                erreurES := CreeFichierTexte(nomFichierOutput,0,fichierHTMLOutput);
                {WritelnDansRapport('Le fichier '+nomFichierOutput+' n''existe pas, on le crée');}
              end
            else
              begin
                if not(MemberOfStringSet(nomFichierOutput,data,gOptionsExportBase.nomsFichiersUtilises)) then
                  begin
                    {WritelnDansRapport('Le fichier '+nomFichierOutput+' existe deja, on l''efface');}
                    erreurES := OuvreFichierTexte(fichierHTMLOutput);
                    erreurES := VideFichierTexte(fichierHTMLOutput);
                    erreurES := FermeFichierTexte(fichierHTMLOutput);
                  end;
              end;
          AddStringToSet(nomFichierOutput,0,gOptionsExportBase.nomsFichiersUtilises);
          
          erreurES := OuvreFichierTexte(fichierHTMLOutput);
          erreurES := SetPositionTeteLectureFinFichierTexte(fichierHTMLOutput);
          gOptionsExportBase.fic := fichierHTMLOutput;
      
          while (erreurES = NoErr) & not(EOFFichierTexte(fichierModeleHTML,erreurES)) do
            begin
              erreurES := ReadlnDansFichierTexte(fichierModeleHTML,s);
              ligne := s;
              ligneSansEspace := EnleveEspacesDeGauche(ligne);
              if (ligneSansEspace[1]='%') 
                then
                  begin
                    {erreurES := WritelnDansFichierTexte(outputBaseThor,s);}
                  end
                else
                  begin
                    {WritelnDansRapport(ligne);}
                    gOptionsExportBase.patternLigne   := ligne;
                    ExporterPartieDansFichierTexte(theGame,numeroReference,compteurLignes);
                  end;
            end;
            
          erreurES := FermeFichierTexte(fichierHTMLOutput);
        end;
      
      gOptionsExportBase.fic := fichierModeleHTML;
  
  end;
end;


procedure ExportListeAuFormatHTML;
var erreurES : OSErr;
    modeleHTML : FichierTEXT;
    compteur : SInt32;
begin
  
  BeginDialog;
  erreurES := GetFichierTexte('????','????','????','????',modeleHTML);
  EndDialog;
 
  if (erreurES = NoErr) then
    begin
      
      erreurES := OuvreFichierTexte(modeleHTML);
        
      gOptionsExportBase.patternLigne            := '';
      gOptionsExportBase.fic                     := modeleHTML;
      gOptionsExportBase.nomsFichiersUtilises    := MakeEmptyStringSet();
        
      (* WritelnDansRapport('descriptionLigne = '+ descriptionLigne); *)
      
      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierHTML,compteur);
      
      DisposeStringSet(gOptionsExportBase.nomsFichiersUtilises);
      
      erreurES := FermeFichierTexte(modeleHTML);
      
    end;
end;





procedure ImporterLigneNulleBougeard(var ligne : str255; var compteur : SInt32);
var gameNodeLePlusProfond : GameTree;
    partieRec:t_PartieRecNouveauFormat;
    partieEnThor : PackedThorGame; 
    nroReferencePartieAjoutee : SInt32;
    i : SInt32;
begin

  
  if (ligne <> '') & (ligne[1] <> '%') then
    begin
     if EstUnePartieOthello(ligne,true) 
       then
         begin
         
         
           TraductionAlphanumeriqueEnThor(ligne,partieEnThor);
           if (GET_LENGTH_OF_PACKED_GAME(partieEnThor) <= 10) | (GET_LENGTH_OF_PACKED_GAME(partieEnThor) > 60) 
             then
               begin
                WritelnDansRapport('problème sur la longueur de la partie : '+ligne);
                SysBeep(0);
              end
            else
              begin
              
                 inc(compteur);
                 if (compteur mod 100) = 0 then WritelnStringAndNumDansRapport('…',compteur);
                    
                 {on rejoue la partie dans l'arbre, et on indique que le score est nul}
                 RejouePartieOthello(ligne,length(ligne) div 2,true,bidplat,pionNoir,gameNodeLePlusProfond,false,false);
                 AjoutePropertyValeurExacteCoupDansCurrentNode(ReflParfait,0);
                 
                 
                 {maintenant on ajoute la partie dans la liste}
                 partieRec.scoreTheorique := 32;  {ce sont des nulles…}
                 partieRec.scoreReel := 32;       {ce sont des nulles…}
                 partieRec.nroTournoi := kNroTournoiDiversesParties;
                 partieRec.nroJoueurNoir := 1948;  {c'est le numéro d'Emmanuel Bougeard}
                 partieRec.nroJoueurBlanc := 1948;
                 for i := 1 to GET_LENGTH_OF_PACKED_GAME(partieEnThor) do
                   partieRec.listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partieEnThor,i,'ImporterLigneNulleBougeard');
                 for i := (GET_LENGTH_OF_PACKED_GAME(partieEnThor) + 1) to 60 do
                   partieRec.listeCoups[i] := 0;
                       
                 if (nbPartiesChargees < nbrePartiesEnMemoire) then
      	           if AjouterPartieRecDansListe(partieRec,2004,nroReferencePartieAjoutee) then;
      	      
           end;
           
         end
       else
         begin
           WritelnDansRapport('## ligne impossible : '+ligne);
         end;
    end;
end;


procedure ImportBaseAllDrawLinesDeBougeard;
var compteurParties : SInt32;
    erreurES : OSErr;
    fichierBougeard : FichierTEXT;
begin
  BeginDialog;
  erreurES := GetFichierTexte('????','????','????','????',fichierBougeard);
  EndDialog;
  
  compteurParties := 0;
  ForEachLineInFileDo(fichierBougeard.theFSSpec,ImporterLigneNulleBougeard,compteurParties);
end;


procedure EcritNomFichierNonReconnuDansRapport(var fic : FichierTEXT);
var err : OSErr;
    nomLongDuFichier : str255;
begin
  err := FSSpecToLongName(fic.theFSSpec,nomLongDuFichier);
  if err = NoErr then 
    begin
      WritelnDansRapport('');
      ChangeFontFaceDansRapport(bold);
      WriteDansRapport('Format non reconnu : ');
      TextNormalDansRapport;
      WritelnDansRapport(nomLongDuFichier);
      TextNormalDansRapport;
    end;
end;


function ImporterFichierPartieDansListe(var fs : FSSpec; isFolder : boolean; path : str255; var pb:CInfoPBRec) : boolean;
var err : OSErr;
    fic : FichierTEXT;
    nomComplet : str255;
    numeroNoir,numeroBlanc : SInt32;
    numeroTournoi,anneeTournoi : SInt32;
    infos:FormatFichierRec;
    partieEnAlpha : str255;
    nomLongDuFichier : str255;
    partieRec:t_PartieRecNouveauFormat;
    nroReferencePartieAjoutee : SInt32;
    myDate : DateTimeRec;
    partieLegale,partieComplete : boolean;
    nbNoirs,nbBlancs : SInt32;
    confianceDansLesJoueurs : extended;
    nomLongDuFichierDejaEcrit : boolean;
    recognized : boolean;
begin
  {$UNUSED pb}

  if not(isFolder) then
    begin
      err := FSSpecToFullPath(fs,nomComplet);
      
      err := FichierTexteExiste(nomComplet,0,fic);
      
      recognized := false;
      
      if (err = NoErr) & TypeDeFichierEstConnu(fic,infos,err) 
        then
  				begin
  				  recognized := true;
  				  
  				  WritelnDansRapport('');
  				  
  				  {
  				  WritelnStringAndNumDansRapport('infos.format = ',SInt32(infos.format));
  				  WritelnStringAndNumDansRapport('infos.tailleOthellier = ',infos.tailleOthellier);
  				  WritelnStringDansRapport('infos.positionEtPartie = '+infos.positionEtPartie);
  				  }
  					
  					if (infos.format = kTypeFichierPGN)
  					  then err := AjouterPartiesFichierPGNDansListe('name_mapping_VOG_to_WThor.txt',fic)
  					  
  					else 
  					  if (infos.format = kTypeFichierSuiteDePartiePuisJoueurs) | 
  					     (infos.format = kTypeFichierSuiteDeJoueursPuisPartie) |
  					     (infos.format = kTypeFichierGGFMultiple) 
  					    then err := AjouterPartiesFichierDestructureDansListe(infos.format,fic)
  					
  					else 
  					  if (infos.format = kTypeFichierTHOR_PAR) & (infos.tailleOthellier = 8)
					      then err := AjouterPartiesFichierTHOR_PARDansListe(fic)
  					
  					else
  					  if ((infos.format = kTypeFichierCassio)                | 
  					    (infos.format = kTypeFichierSGF)                   |
  					    (infos.format = kTypeFichierGGF)                   |
                (infos.format = kTypeFichierHTMLOthelloBrowser)    |
                (infos.format = kTypeFichierTranscript)            |
                (infos.format = kTypeFichierZebra)                 |
                (infos.format = kTypeFichierExportTexteDeZebra)    |
                (infos.format = kTypeFichierSimplementDesCoups)    |
                (infos.format = kTypeFichierLigneAvecJoueurEtPartie)) 
                & (infos.tailleOthellier = 8)
                  then
                    begin
                      partieEnAlpha := infos.positionEtPartie;
                      err := FSSpecToLongName(fic.theFSSpec,nomLongDuFichier);
                      
                      partieLegale := EstUnePartieOthelloAvecMiroir(partieEnAlpha); {on sait qu'elle est legale, c'est juste pour compacter et reorienter la partie}
                      partieComplete := EstUnePartieOthelloTerminee(partieEnAlpha,false,nbNoirs,nbBlancs);
                      
                      GetTime(myDate);
                      anneeTournoi := myDate.year;
                      
                      if not(TrouverNomDeTournoiDansPath(GetPathOfScannedDirectory()+path,numeroTournoi,anneeTournoi,'name_mapping_VOG_to_WThor.txt'))
                        then numeroTournoi := kNroTournoiDiversesParties;
                      
                      nomLongDuFichierDejaEcrit := false;
                      if TrouverNomsDesJoueursDansNomDeFichier(infos.joueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs)
                        then
                          begin
                            if (confianceDansLesJoueurs < 0.80) then ChangeFontColorDansRapport(RougeCmd);
                            WriteDansRapport(nomLongDuFichier + '  : ');
                            if (confianceDansLesJoueurs < 0.80) then WriteDansRapport('joueurs dans le fichier =  ');
                            WritelnDansRapport(infos.joueurs);
                            TextNormalDansRapport;
                            nomLongDuFichierDejaEcrit := true;
                          end;
                       
                       if confianceDansLesJoueurs < 0.80 then
                         begin
                          if TrouverNomsDesJoueursDansNomDeFichier(nomLongDuFichier,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs)
                            then
                              begin
                                if (confianceDansLesJoueurs < 0.80) then ChangeFontColorDansRapport(RougeCmd);
                                if not(nomLongDuFichierDejaEcrit) then WritelnDansRapport(nomLongDuFichier);
                                TextNormalDansRapport;
                              end
                            else
                              begin
                                numeroNoir  := kNroJoueurInconnu;
                                numeroBlanc := kNroJoueurInconnu;
                                ChangeFontColorDansRapport(RougeCmd);
                                if not(nomLongDuFichierDejaEcrit) then WritelnDansRapport(nomLongDuFichier);
                                TextNormalDansRapport;
                              end;
                         end;
                           
                      if partieComplete 
                        then 
                          WritelnDansRapport(partieEnAlpha)
                        else
                          begin
                            ChangeFontColorDansRapport(RougeCmd);
                            WritelnDansRapport(partieEnAlpha);
                            TextNormalDansRapport;
                          end;
                      
                      (* maintenant, ajouter la partie dans la liste *)
                      if AjouterPartieAlphaDansLaListe(partieEnAlpha,-1,numeroNoir,numeroBlanc,numeroTournoi,anneeTournoi,partieRec,nroReferencePartieAjoutee) then;
                      
                    end
                 else
                   recognized := false;
             
            if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
  			  end;
  			  
  			  
  		if not(recognized) & (fic.theFSSpec.name[1] <> '.') then {on ne veut pas les fichiers dont le nom commence par un point} 
  		  EcritNomFichierNonReconnuDansRapport(fic);
  		  
   end;

  ImporterFichierPartieDansListe := isFolder; {on cherche recursivement}
end;


procedure ImporterToutesPartiesRepertoire;
var prompt : str255;
    whichDirectory : FSSpec;
    erreurES : OSErr;
    tick : SInt32;
begin
  GetIndString(prompt,TextesDiversID,10); {'Choisissez un répertoire avec des parties'}
  if ChooseFolder(prompt,whichDirectory) then
    begin
      {WritelnDansRapport('*************  Entrée dans ImporterToutesPartiesRepertoire…  ******************');}
      tick := Tickcount();
      
      if not(problemeMemoireBase) & not(JoueursEtTournoisEnMemoire) then
        erreurES := MetJoueursEtTournoisEnMemoire(false);
      
      (* on efface les caches des pseudos car l'utilisateur peut avoir changé le
         dictionnaire "name_mapping_VOG_to_WThor.txt" depuis la derniere fois   *)
      with gImportDesNoms do
        begin
          DisposeStringSet(pseudosInconnus);
          DisposeStringSet(pseudosNomsDejaVus);
          DisposeStringSet(pseudosTournoisDejaVus);
          DisposeStringSet(nomsReelsARajouterDansBase);
          DisposeStringSet(pseudosAyantUnNomReel);
        end;
      
      erreurES := SetPathOfScannedDirectory(whichDirectory);
      erreurES := ScanDirectory(whichDirectory,ImporterFichierPartieDansListe);
      
      
      {WritelnDansRapport('');
      WritelnDansRapport('*************  Sortie de ImporterToutesPartiesRepertoire  ******************');}
      {WritelnStringAndNumDansRapport('temps en ticks = ',TickCount()-tick);}
      WritelnDansRapport('');
    end;
end;


end.
