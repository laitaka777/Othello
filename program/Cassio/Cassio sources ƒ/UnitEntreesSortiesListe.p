UNIT UnitEntreesSortiesListe;



INTERFACE







USES UnitTriListe,UnitNouveauFormat,UnitListe;
 

TYPE ActionEcraserPartie = (ActionAnnuler,ActionRemplacer,ActionCreerAutrePartie);


{modification d'une partie en memoire}
function ChangerPartieRecDansListe(var partieRec:t_PartieRecNouveauFormat;anneePartie : SInt16; nroReferencePartieChangee : SInt32) : boolean;
function ChangerPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee : SInt32;infosDansRapport : boolean; var partieRec:t_PartieRecNouveauFormat;nroReferencePartieChangee : SInt32) : boolean;
function ChangerPartieAlphaDansLaListe(partieEnAlpha : str255;theorique,numeroNoir,numeroBlanc,numeroTournoi,annee : SInt32; var partieRec:t_PartieRecNouveauFormat;nroReferencePartieChangee : SInt32) : boolean;
function ConfirmationEcraserPartie(nroReference,nbCoupsIdentiques : SInt32):ActionEcraserPartie;


{ajout d'une partie en memoire}
function AjouterPartieRecDansListe(var partieRec:t_PartieRecNouveauFormat;anneePartie : SInt16; var nroReferencePartieAjoutee : SInt32) : boolean;
function AjouterPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee : SInt32;infosDansRapport : boolean; var partieRec:t_PartieRecNouveauFormat; var nroReferencePartieAjoutee : SInt32) : boolean;
function AjouterPartieAlphaDansLaListe(partieEnAlpha : str255;theorique,numeroNoir,numeroBlanc,numeroTournoi,annee : SInt32; var partieRec:t_PartieRecNouveauFormat; var nroReferencePartieAjoutee : SInt32) : boolean;
function AjouterPartieDansCetteDistribution(partieRec:t_PartieRecNouveauFormat;nroDistrib : SInt32;anneePartie : SInt32) : OSErr;


{un filtre de selection sur la liste}
function FiltrePartieEstActiveEtSelectionnee(numeroDansLaListe,numeroReference : SInt32; var result : SInt32) : boolean;


{export au format WTB}
function ConfirmationEcraserBase() : boolean;
function SauvegardeCesPartiesDeLaListe(filtreDesParties:FiltreNumRefProc;nroPartieMin,nroPartieMax : SInt32;anneeDesParties : SInt16; mySpec : FSSpec; var doitEcraserBase : boolean) : OSErr;
function SauvegardeListeCouranteAuNouveauFormat(filtreDesParties:FiltreNumRefProc) : OSErr;


{export au format TEXT}
procedure DoExporterListeDePartiesEnTexte;




IMPLEMENTATION







USES UnitPositionEtTrait,UnitFichiersTEXT,UnitAccesStructuresNouvFormat,UnitRapport,
     UnitUtilitaires,UnitOth1,UnitRapportImplementation,UnitFichiersTEXT,SNStrings,
     UnitMoulinette,UnitActions,MyFileSystemUtils,UnitListe,UnitCriteres,UnitDialog,
     UnitScannerOthellistique,UnitFenetres,UnitNormalisation,UnitPackedThorGame,UnitPackedThorGame;


function ConfirmationEcraserPartie(nroReference,nbCoupsIdentiques : SInt32):ActionEcraserPartie;
const DialogueRemplacerPartieID=162;
      remplacerBouton=1;
      nouvellePartieBouton=2;
      annulerBouton=5;
var dp : DialogPtr;
	itemHit : SInt16; 
	err : OSErr;
begin
  ConfirmationEcraserPartie := ActionRemplacer;
  BeginDialog;
  dp := MyGetNewDialog(DialogueRemplacerPartieID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      err := SetDialogTracksCursor(dp,true);
      ParamText(NumEnString(nbCoupsIdentiques),ConstruireChaineReferencesPartieParNroRefPartie(nroReference,true,-1),'','');
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit=remplacerBouton) | (itemHit=nouvellePartieBouton) | (itemHit=annulerBouton);
      
      case itemHit of
        remplacerBouton      : ConfirmationEcraserPartie := ActionRemplacer;
        nouvellePartieBouton : ConfirmationEcraserPartie := ActionCreerAutrePartie;
        annulerBouton        : ConfirmationEcraserPartie := ActionAnnuler;
      end; {case}
      
      MyDisposeDialog(dp);
      if windowPaletteOpen then DessinePalette;
      EssaieSetPortWindowPlateau;
    end;
  EndDialog;
end;


function ConfirmationEcraserBase() : boolean;
const DialogueRemplacerBaseID=151;
      annulerBouton=1;
      remplacerBouton=2;
var dp : DialogPtr;
	itemHit : SInt16; 
	err : OSErr;
begin
  ConfirmationEcraserBase := true;
  BeginDialog;
  dp := MyGetNewDialog(DialogueRemplacerBaseID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit=annulerBouton) | (itemHit=remplacerBouton);
      ConfirmationEcraserBase := (itemHit=remplacerBouton);
      MyDisposeDialog(dp);
      if windowPaletteOpen then DessinePalette;
      EssaieSetPortWindowPlateau;
    end;
  EndDialog;
end;
	

function SauvegardeCesPartiesDeLaListe(filtreDesParties:FiltreNumRefProc;nroPartieMin,nroPartieMax : SInt32;anneeDesParties : SInt16; fichier : FSSpec; var doitEcraserBase : boolean) : OSErr;
var enteteFichierPartie : t_EnTeteNouveauFormat;
    partieNF:t_PartieRecNouveauFormat;
    n,nroReference,bidon : SInt32;
    nbPartiesEcrites,nbPartiesRefusees : SInt32;
    codeErreur : OSErr;
    myDate : DateTimeRec;
    doitEcrireCettePartie : boolean;
    s60 : PackedThorGame;
    s255 : str255;
    nbNoirs,nbBlancs : SInt32;
    longueur : SInt16; 
    terminee : boolean;
    fic : FichierTEXT;
    fileName : str255;
begin
  SauvegardeCesPartiesDeLaListe := -2;
  
  if (nroPartieMax < nroPartieMin) then 
    exit(SauvegardeCesPartiesDeLaListe);

  fileName := fichier.name;
  if (fileName[Length(fileName)] <> ' ') & (fileName[Length(fileName)] <> '_') 
    then fileName := Concat(fileName,' ');
  fileName := fileName + NumEnString(anneeDesParties);
  fileName := fileName+'.wtb';
  
  codeErreur := FichierTexteExisteFSp(MyMakeFSSpec(fichier.vRefNum,fichier.parID,fileName),fic);
  if codeErreur = NoErr
    then
      begin
        if doitEcraserBase | ConfirmationEcraserBase()
		      then
		        begin
		          doitEcraserBase := true;
		          codeErreur := NoErr;
		        end
		      else
		        codeErreur := -1;
      end
    else
      if (codeErreur = fnfErr) {-43 => fichier non trouvé, on le crée}
        then codeErreur := CreeFichierTexteFSp(MyMakeFSSpec(fichier.vRefNum,fichier.parID,fileName),fic);
  
  if (codeErreur <> NoErr) then
    begin
      WritelnStringAndNumDansRapport('Erreur dans SauvegardeCesPartiesDeLaListe : ',codeErreur);
      SauvegardeCesPartiesDeLaListe := codeErreur;
      exit(SauvegardeCesPartiesDeLaListe);
    end;
  
  SetFileCreatorFichierTexte(fic,'SNX4');
  SetFileTypeFichierTexte(fic,'QWTB');

  
  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);

  codeErreur := OuvreFichierTexte(fic);
  if (codeErreur <> NoErr) then
    begin
      SauvegardeCesPartiesDeLaListe := codeErreur;
      exit(SauvegardeCesPartiesDeLaListe);
    end;
  
  codeErreur := VideFichierTexte(fic);
  if (codeErreur <> NoErr) then
    begin
      SauvegardeCesPartiesDeLaListe := codeErreur;
      exit(SauvegardeCesPartiesDeLaListe);
    end;
  
  WritelnDansRapport('');
  WriteDansRapport('Début de l''écriture sur le disque ');
  WriteDansRapport('(dans le fichier « '+fileName+' ») ');
  WritelnDansRapport('des parties de l''année '+NumEnString(anneeDesParties)+'…');
  {WritelnStringAndNumDansRapport('nroPartieMin = ',nroPartieMin);
  WritelnStringAndNumDansRapport('nroPartieMax = ',nroPartieMax);}
  
  nbPartiesEcrites := 0;
  nbPartiesRefusees := 0;
  for n := nroPartieMin to nroPartieMax do
    if codeErreur=NoErr then
      begin
        nroReference := tableNumeroReference^^[n];
        
        if filtreDesParties(n,nroReference,bidon) then
          begin
          
            partieNF := GetPartieRecordParNroRefPartie(nroReference);
            
            partieNF.nroJoueurNoir  := GetNroJoueurDansSonFichier(partieNF.nroJoueurNoir);
            partieNF.nroJoueurBlanc := GetNroJoueurDansSonFichier(partieNF.nroJoueurBlanc);
            partieNF.nroTournoi     := GetNroTournoiDansSonFichier(partieNF.nroTournoi);
            
            (* ici on modifie et on filtre les parties a écrire comme on veut... *)
            {partieNF.scoreTheorique := 255;}
            
            
            
            ExtraitPartieTableStockageParties(nroReference,s60);
            if PeutCalculerScoreFinalDeCettePartie(s60,nbNoirs,nbBlancs,terminee)
              then
                begin
                  if terminee 
                    then
                      begin
                        doitEcrireCettePartie := PartieEstActiveEtSelectionnee(nroReference);
                        {if partieNF.scoreReel <> nbNoirs then
                          begin
                            TraductionThorEnAlphanumerique(s60,s255);
                            WritelnDansRapport('partie avec un faux score : '+s255);
                            WritelnStringAndNumDansRapport('partieNF.scoreReel=',partieNF.scoreReel);
                            WritelnStringAndNumDansRapport('nbNoirs=',nbNoirs);
    	                      AttendFrappeClavier;
    	                    end;}
                        partieNF.scoreReel := nbNoirs;
                        if (partieNF.scoreTheorique < 0) | (partieNF.scoreTheorique > 64)
                          then partieNF.scoreTheorique := partieNF.scoreReel;
                      end
                    else
    	                begin
    	                  TraductionThorEnAlphanumerique(s60,s255);
    	                  longueur := length(s255) div 2;
    	                  doitEcrireCettePartie := (longueur > 20) & PartieEstActiveEtSelectionnee(nroReference);
    	                  {WritelnDansRapport('partie non terminée : '+s255);
    	                  WritelnStringAndNumDansRapport('longueur=',longueur);
    	                  WritelnStringAndNumDansRapport('partieNF.scoreReel=',partieNF.scoreReel);
    	                  WritelnStringAndNumDansRapport('partieNF.scoreTheorique=',partieNF.scoreTheorique);
    	                  WritelnStringAndNumDansRapport('nbNoirs=',nbNoirs);
    	                  AttendFrappeClavier;}
    	                end;
                end
              else
                begin
                  doitEcrireCettePartie := false;
                  TraductionThorEnAlphanumerique(s60,s255);
                  WritelnDansRapport('partie illégale : '+s255);
                  AttendFrappeClavier;
                end;
                
              
            if doitEcrireCettePartie 
              then
    	        begin
    	          inc(nbPartiesEcrites);
    	          SetPartieDansListeDoitEtreSauvegardee(nroReference,false);
    	          codeErreur := EcritPartieNouveauFormat(fic.refNum,nbPartiesEcrites,partieNF);
    	          if (nbPartiesEcrites mod 500) = 0 then
    	            begin
    	              WriteStringAndNumDansRapport('Ecrites = ',nbPartiesEcrites);
    	              WritelnStringAndNumDansRapport(' ,  refusées = ',nbPartiesRefusees);
    	            end;
    	        end
    	      else
    	        begin
    	          inc(nbPartiesRefusees);
    	        end;
          end; {if filtreDesParties(nroReference,bidon) then ...}
      end; {boucle for n := ...}
      
  WriteStringAndNumDansRapport('Pour l''année ',anneeDesParties);
  WriteStringAndNumDansRapport(', on a, au total, écrit ',nbPartiesEcrites);
  WriteStringAndNumDansRapport(' partie(s) et refusé ',nbPartiesRefusees);
  WritelnStringDansRapport(' partie(s)');
  
  GetTime(myDate);
  with enteteFichierPartie do
    begin
      SiecleCreation                         := myDate.year div 100;
      AnneeCreation                          := myDate.year mod 100;
      MoisCreation                           := myDate.month;
      JourCreation                           := myDate.day;
      NombreEnregistrementsParties           := nbPartiesEcrites;
      NombreEnregistrementsTournoisEtJoueurs := 0;
      AnneeParties                           := anneeDesParties;
      TailleDuPlateau                        := 8;   {taille du plateau de jeu}
      EstUnFichierSolitaire                  := 0;   {1 = solitaires, 0 = autres cas}
      ProfondeurCalculTheorique              := 24;  {profondeur de calcul du score theorique}
      reservedByte                           := 0;
    end;
  codeErreur := EcritEnteteNouveauFormat(fic.refNum,enteteFichierPartie);
            
            
  codeErreur := FermeFichierTexte(fic);
  SauvegardeCesPartiesDeLaListe := codeErreur;
end;


function FiltrePartieEstActiveEtSelectionnee(numeroDansLaListe,numeroReference : SInt32; var result : SInt32) : boolean;
begin {$unused numeroDansLaListe,result}
  FiltrePartieEstActiveEtSelectionnee := PartieEstActiveEtSelectionnee(numeroReference);
end;


function SauvegardeListeCouranteAuNouveauFormat(filtreDesParties:FiltreNumRefProc) : OSErr;
var codeErreur : OSErr;
    reply : SFReply;
    fichier : FSSpec;
    prompt,s : str255;
    nroPartieDansListe,nroReference : SInt32;
    nroPremierePartieDeLAnnee : SInt32;
    nroDernierePartieDeLAnnee : SInt32;
    anneeCourante,anneePartieSuivante : SInt16; 
    doitEcraserAncienneBase : boolean;
    sortieDeBoucle : boolean;
    compteurPartiesDansAnneeCourante : SInt32;
    bidon : SInt32;
begin
  if not(windowListeOpen) | (nbPartiesActives<=0) then
    begin
      SauvegardeListeCouranteAuNouveauFormat := NoErr;
      exit(SauvegardeListeCouranteAuNouveauFormat);
    end;
  
  BeginDialog;
  GetIndString(s,TextesDiversID,2);      {'sans titre'}
  reply.fname := s;
  GetIndString(prompt,TextesNouveauFormatID,3); {'nom de la base à créer ?'}
  if MakeFileName(reply,prompt,fichier) then;
  EndDialog;
  
  if not(reply.good) then  {annulation}
    begin
      SauvegardeListeCouranteAuNouveauFormat := NoErr;
      exit(SauvegardeListeCouranteAuNouveauFormat);
    end;
  
  SauvegardeListeCouranteAuNouveauFormat := -1;
  doitEcraserAncienneBase := false;
  DoTrierListe(TriParDate,kRadixSort);
  
  if reply.good then 
    begin
      codeErreur := 0;
      nroPartieDansListe := 1;
      nroDernierePartieDeLAnnee := 0;
      REPEAT
        watch := GetCursor(watchcursor);
        SafeSetCursor(watch);
        
        nroPremierePartieDeLannee := nroPartieDansListe;
        nroReference := tableNumeroReference^^[nroPremierePartieDeLannee];
        anneeCourante := GetAnneePartieParNroRefPartie(nroReference);
        
        {WritelnDansRapport('**********  entree dans SauvegardeListeCouranteAuNouveauFormat  *************');
        WritelnStringAndNumDansRapport('AVANT, nbPartiesActives = ',nbPartiesActives);
        WritelnStringAndNumDansRapport('AVANT, nroPremierePartieDeLannee = ',nroPremierePartieDeLannee);
        WritelnStringAndNumDansRapport('AVANT, nroDernierePartieDeLAnnee = ',nroDernierePartieDeLAnnee);
        WritelnStringAndNumDansRapport('AVANT, anneeCourante = ',anneeCourante);}
        
        compteurPartiesDansAnneeCourante := 0;
        sortieDeBoucle := false;
        repeat
          if (nroPartieDansListe <= nbPartiesActives) then
            begin
              nroReference := tableNumeroReference^^[nroPartieDansListe];
              if filtreDesParties(nroPartieDansListe,nroReference,bidon) then inc(compteurPartiesDansAnneeCourante);
            
              if (nroPartieDansListe >= nbPartiesActives) 
                then 
                  begin
                    sortieDeBoucle := true;
                    nroDernierePartieDeLAnnee := nbPartiesActives;
                  end
                else
                  begin
                    inc(nroPartieDansListe);
                    nroReference := tableNumeroReference^^[nroPartieDansListe];
                    anneePartieSuivante := GetAnneePartieParNroRefPartie(nroReference);
                    
                    if (anneePartieSuivante <> anneeCourante) then
                      begin
                        sortieDeBoucle := true;
                        nroDernierePartieDeLAnnee := nroPartieDansListe - 1;
                      end;
                  end;
            end;
        until sortieDeBoucle | (nbPartiesActives <= 0);
          
        if nroDernierePartieDeLAnnee < nroPremierePartieDeLannee then nroDernierePartieDeLAnnee := nroPremierePartieDeLannee;
        if nroDernierePartieDeLAnnee > nbPartiesActives          then nroDernierePartieDeLAnnee := nbPartiesActives;
        
        {WritelnStringAndNumDansRapport('apres, anneePartieSuivante = ',anneePartieSuivante);
        WritelnStringAndNumDansRapport('apres, compteurPartiesDansAnneeCourante = ',compteurPartiesDansAnneeCourante);
        WritelnStringAndNumDansRapport('apres, nroPremierePartieDeLannee = ',nroPremierePartieDeLannee);
        WritelnStringAndNumDansRapport('apres, nroDernierePartieDeLAnnee = ',nroDernierePartieDeLAnnee);}
        
        	       
        if (compteurPartiesDansAnneeCourante > 0)
          then codeErreur := SauvegardeCesPartiesDeLaListe(filtreDesParties,nroPremierePartieDeLAnnee,nroDernierePartieDeLAnnee,
                                                           anneeCourante,fichier,doitEcraserAncienneBase);	        
      
        {if codeErreur <> 0 then
          begin
		        WritelnDansRapport('WARNING (codeErreur <> 0) dans SauvegardeListeCouranteAuNouveauFormat…');
		        WritelnStringAndNumDansRapport('    anneeCourante = ',anneeCourante);
		        WritelnStringAndNumDansRapport('    codeErreur = ',codeErreur);
          end;}
        
      UNTIL (nbPartiesActives <= 0) | (nroDernierePartieDeLAnnee >= nbPartiesActives) | (codeErreur <> 0);
      
      if (codeErreur = -1)
        then SauvegardeListeCouranteAuNouveauFormat := NoErr      {cela voulait dire que l'utilisateur a refusé d'écraser une base déjà existante}
        else SauvegardeListeCouranteAuNouveauFormat := codeErreur;
        
    end;
  
  CalculsEtAffichagePourBase(true,true);
  AjusteCurseur; 
end;


function ChangerPartieRecDansListe(var partieRec:t_PartieRecNouveauFormat;anneePartie : SInt16; nroReferencePartieChangee : SInt32) : boolean;
var partie60 : PackedThorGame;
    partie255 : str255;
    partie120:str120;
    autreCoupDiag : boolean;
    i,t : SInt32;
    err : OSErr;
begin

  ChangerPartieRecDansListe := false;
  
  if (nroReferencePartieChangee < 0) | (nroReferencePartieChangee > nbrePartiesEnMemoire) then 
    begin
      Sysbeep(0);
      WritelnDansRapport('WARNING !!! (nroReferencePartieChangee < 0) | (nroReferencePartieChangee > nbrePartiesEnMemoire) dans ChangerPartieRecDansListe, prévenez Stéphane');
      exit(ChangerPartieRecDansListe);
    end;

  FILL_PACKED_GAME_WITH_ZEROS(partie60);
  for i := 1 to 60 do
    begin
      t := partieRec.listeCoups[i];
      if (t >= 11) & (t <= 88) then 
        ADD_MOVE_TO_PACKED_GAME(partie60, t);
    end;
  TraductionThorEnAlphanumerique(partie60,partie255);
  
  if not(EstUnePartieOthello(partie255,true)) then 
    begin
      WritelnDansRapport('partie illégale dans ChangerPartieRecDansListe !! '+partie255);
      exit(ChangerPartieRecDansListe);
    end;
  
  
  partie120 := partie255;
  Normalisation(partie120,autreCoupDiag,false);
  partie120 := NormaliserLaPartiePourInclusionDansLaBaseWThor(partie120);
  TraductionAlphanumeriqueEnThor(partie120,partie60);
  for i := 1 to GET_LENGTH_OF_PACKED_GAME(partie60) do
    partieRec.listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partie60, i,'ChangerPartieRecDansListe');
  for i := GET_LENGTH_OF_PACKED_GAME(partie60)+1 to 60 do 
    partieRec.listeCoups[i] := 0;
    
  if (InfosFichiersNouveauFormat.nbFichiers <= 0) then
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
      LecturePreparatoireDossierDatabase(volumeRefCassio);
      if not(problemeMemoireBase) & not(JoueursEtTournoisEnMemoire) then
        err := MetJoueursEtTournoisEnMemoire(false);
      AjusteCurseur;
    end;
  
  
  if (nroReferencePartieChangee >= 0) & (nroReferencePartieChangee <= nbrePartiesEnMemoire) then
    begin
      
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : nroReferencePartieChangee = ',nroReferencePartieChangee);AttendFrappeClavier;}
      
      SetAnneePartieParNroRefPartie(nroReferencePartieChangee,anneePartie);
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres SetAnneePartieParNroRefPartie ',0);
      AttendFrappeClavier;}
      
      SetPartieRecordParNroRefPartie(nroReferencePartieChangee,partieRec);
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres SetPartieRecordParNroRefPartie ',0);
      AttendFrappeClavier;}
      
      SetNroDistributionParNroRefPartie(nroReferencePartieChangee,0);
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres SetNroDistributionParNroRefPartie ',0);
      AttendFrappeClavier;}
      
      SetPartieActive(nroReferencePartieChangee,true);
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres SetPartieActive ',0);
      AttendFrappeClavier;}
      
      SetPartieDetruite(nroReferencePartieChangee,false);
      SetPartieDansListeDoitEtreSauvegardee(nroReferencePartieChangee,true);
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres SetPartieDetruite ',0);
      AttendFrappeClavier;}
      
      TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres TrierListePartie ',0);
      AttendFrappeClavier;}
      
      LaveTableCriteres;
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres LaveTableCriteres ',0);
      AttendFrappeClavier;}
      
      InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie ',0);
      AttendFrappeClavier;}
      
      if sousSelectionActive then DoChangeSousSelectionActive;
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres DoChangeSousSelectionActive ',0);
      AttendFrappeClavier;}
      
      if not(InclurePartiesAvecOrdinateursDansListe()) then SetInclurePartiesAvecOrdinateursDansListe(true);
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres DoChangeSousSelectionActive ',0);
      AttendFrappeClavier;}
      
      CalculsEtAffichagePourBase(false,false);
      {WritelnStringAndNumDansRapport('dans ChangerPartieRecDansListe : apres CalculsEtAffichagePourBase ',0);
      AttendFrappeClavier;}
      
      ChangerPartieRecDansListe := true;
    end;
end;


function ChangerPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee : SInt32;infosDansRapport : boolean; var partieRec:t_PartieRecNouveauFormat;nroReferencePartieChangee : SInt32) : boolean;
var partie60 : PackedThorGame;
    partie255,s : str255;
    autreCoupQuatreDiag : boolean;
    i,nbPionsNoirs : SInt32;
    result : boolean;
begin
  result := false;
  
  if (nroReferencePartieChangee < 0) | (nroReferencePartieChangee > nbrePartiesEnMemoire) then 
    begin
      Sysbeep(0);
      WritelnDansRapport('WARNING !!! (nroReferencePartieChangee < 0) | (nroReferencePartieChangee > nbrePartiesEnMemoire) dans ChangerPartieCouranteDansListe, prévenez Stéphane');
      exit(ChangerPartieCouranteDansListe);
    end;
  
  if gameOver then
    begin
      partie255 := PartieNormalisee(autreCoupQuatreDiag,false);
      TraductionAlphanumeriqueEnThor(partie255,partie60);
      
      if nbreDePions[pionNoir] > nbreDePions[pionBlanc] then nbPionsNoirs := 64 - nbreDePions[pionBlanc] else
			if nbreDePions[pionNoir] = nbreDePions[pionBlanc] then nbPionsNoirs := 32 else
			if nbreDePions[pionNoir] < nbreDePions[pionBlanc] then nbPionsNoirs := nbreDePions[pionNoir];
				  
      if infosDansRapport then
        begin
				  ConstruitTitrePartie(GetNomJoueur(nroNoir),GetNomJoueur(nroBlanc),false,nbPionsNoirs,s);
          WritelnDansRapport('');
          WritelnDansRapport(partie255);
          WriteDansRapport(s + ', ');
				  WritelnDansRapport(EnleveEspacesDeDroite(GetNomTournoi(nroDuTournoi))+' '+NumEnString(annee));
        end;
      
      with partieRec do
        begin
          nroTournoi     := nroDuTournoi;
          nroJoueurNoir  := nroNoir;
          nroJoueurBlanc := nroBlanc;
          scoreReel      := nbPionsNoirs;
          scoreTheorique := scoreReel;
          for i := 1 to GET_LENGTH_OF_PACKED_GAME(partie60) do 
            listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partie60, i,'ChangerPartieCouranteDansListe');
          for i := GET_LENGTH_OF_PACKED_GAME(partie60)+1 to 60 do 
            listeCoups[i] := 0;
        end;
	    
	    result := ChangerPartieRecDansListe(partieRec,annee,nroReferencePartieChangee);
    end;
  
  ChangerPartieCouranteDansListe := result;
end;


function ChangerPartieAlphaDansLaListe(partieEnAlpha : str255;theorique,numeroNoir,numeroBlanc,numeroTournoi,annee : SInt32; var partieRec:t_PartieRecNouveauFormat;nroReferencePartieChangee : SInt32) : boolean;
var partie120:str120;
    autreCoupQuatreDiag : boolean;
    partieEnThor : PackedThorGame;
    scoreNoir,scoreBlanc : SInt32;
    partieEstComplete : boolean;
    i,score : SInt32;
    result : boolean;
begin
  result := false;
  
  if (nroReferencePartieChangee < 0) | (nroReferencePartieChangee > nbrePartiesEnMemoire) then 
    begin
      Sysbeep(0);
      WritelnDansRapport('WARNING !!! (nroReferencePartieChangee < 0) | (nroReferencePartieChangee > nbrePartiesEnMemoire) dans ChangerPartieAlphaDansLaListe, prévenez Stéphane');
      exit(ChangerPartieAlphaDansLaListe);
    end;
  
  if EstUnePartieOthelloAvecMiroir(partieEnAlpha) then
    begin
    
      partie120 := partieEnAlpha;
      Normalisation(partie120,autreCoupQuatreDiag,false);
      partieEnAlpha := partie120;
      TraductionAlphanumeriqueEnThor(PartieEnAlpha,partieEnThor);
      
      if PeutCalculerScoreFinalDeCettePartie(partieEnThor,scoreNoir,scoreBlanc,partieEstComplete)
        then score := scoreNoir
        else score := 32;  {on force une nulle si la partie est illegale}
      
      
      partieRec.nroTournoi     := numeroTournoi;
      partieRec.nroJoueurNoir  := numeroNoir;
      partieRec.nroJoueurBlanc := numeroBlanc;
      partieRec.scoreReel      := score;
      
      if (theorique >= 0) & (theorique <= 64)
        then partieRec.scoreTheorique := theorique
        else partieRec.scoreTheorique := score;
        
        

      for i := 1 to GET_LENGTH_OF_PACKED_GAME(partieEnThor) do
        partieRec.listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partieEnThor, i,'ChangerPartieAlphaDansLaListe');
      for i := (GET_LENGTH_OF_PACKED_GAME(partieEnThor) + 1) to 60 do
        partieRec.listeCoups[i] := 0;
      
      result := ChangerPartieRecDansListe(partieRec,annee,nroReferencePartieChangee);
    end;
  
  ChangerPartieAlphaDansLaListe := result;
end; 



function AjouterPartieRecDansListe(var partieRec:t_PartieRecNouveauFormat;anneePartie : SInt16; var nroReferencePartieAjoutee : SInt32) : boolean;
begin
  if (nbPartiesChargees < nbrePartiesEnMemoire) 
    then
      begin
        inc(nbPartiesChargees);
        nroReferencePartieAjoutee   := nbPartiesChargees;
        AjouterPartieRecDansListe   := ChangerPartieRecDansListe(partieRec,anneePartie,nroReferencePartieAjoutee);
      end
    else
      begin
        nroReferencePartieAjoutee   := -1;
        AjouterPartieRecDansListe   := false;
      end;
end;


function AjouterPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee : SInt32;infosDansRapport : boolean; var partieRec:t_PartieRecNouveauFormat; var nroReferencePartieAjoutee : SInt32) : boolean;
begin
  if (nbPartiesChargees < nbrePartiesEnMemoire) 
    then
      begin
        inc(nbPartiesChargees);
        nroReferencePartieAjoutee      := nbPartiesChargees;
        AjouterPartieCouranteDansListe := ChangerPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee,infosDansRapport,partieRec,nroReferencePartieAjoutee);
      end
    else
      begin
        nroReferencePartieAjoutee      := -1;
        AjouterPartieCouranteDansListe := false;
      end;
end;


function AjouterPartieAlphaDansLaListe(partieEnAlpha : str255;theorique,numeroNoir,numeroBlanc,numeroTournoi,annee : SInt32; var partieRec:t_PartieRecNouveauFormat; var nroReferencePartieAjoutee : SInt32) : boolean;
begin
  if (nbPartiesChargees < nbrePartiesEnMemoire) 
    then
      begin
        inc(nbPartiesChargees);
        nroReferencePartieAjoutee      := nbPartiesChargees;
        AjouterPartieAlphaDansLaListe  := ChangerPartieAlphaDansLaListe(partieEnAlpha,theorique,numeroNoir,numeroBlanc,numeroTournoi,annee,partieRec,nroReferencePartieAjoutee);
      end
    else
      begin
        
        WritelnDansRapport('WARNING !!! Plus de mémoire dans ChangerPartieAlphaDansLaListe, prévenez Stéphane');
        
        nroReferencePartieAjoutee      := -1;
        AjouterPartieAlphaDansLaListe  := false;
      end;
end;


function AjouterPartieDansCetteDistribution(partieRec:t_PartieRecNouveauFormat;nroDistrib : SInt32;anneePartie : SInt32) : OSErr;
var numFichier,k : SInt32;
    enteteFichierPartie : t_EnTeteNouveauFormat;
    fic : FichierTEXT;
    codeErreur : OSErr;
    filename : str255;
    myDate : DateTimeRec;
begin
  
  codeErreur := -1;
  
  if (InfosFichiersNouveauFormat.nbFichiers <= 0) then
    LecturePreparatoireDossierDatabase(volumeRefCassio);
    
  {WritelnStringAndNumDansRapport('numero de distribution = ',nroDistrib);}
  
  if (nroDistrib >= 1) & (nroDistrib <= DistributionsNouveauFormat.nbDistributions) &
     EstUneDistributionDeParties(nroDistrib) then
    begin
    
      { Désormais on sait que nroDistrib est un numero de distribution valide }
      {WritelnStringAndNumDansRapport('numero de distribution valide = ',nroDistrib);}
  
		  { On cherche un fichier de la bonne distribution et de l'année voulue parmi tous les fichiers de la base}
		  numFichier := -1;
		  for k := 1 to InfosFichiersNouveauFormat.nbFichiers do
		    if (InfosFichiersNouveauFormat.fichiers[k].typeDonnees = kFicPartiesNouveauFormat) &
		       (InfosFichiersNouveauFormat.fichiers[k].nroDistribution = nroDistrib) &
		       (AnneePartiesFichierNouveauFormat(k) = anneePartie) then
		     numFichier := k; {trouvé}
		  
		  
		  if (numFichier <= 0) 
		    then { Si l'annee est non trouvee, on crée un nouveau fichier dans la distribution}
			    begin  
			    
			      GetTime(myDate);
					  with enteteFichierPartie do
					    begin
					      SiecleCreation                         := myDate.year div 100;
					      AnneeCreation                          := myDate.year mod 100;
					      MoisCreation                           := myDate.month;
					      JourCreation                           := myDate.day;
					      NombreEnregistrementsParties           := 0;
					      NombreEnregistrementsTournoisEtJoueurs := 0;
					      AnneeParties                           := anneePartie;
					      TailleDuPlateau                        := 8;  {taille du plateau de jeu}
					      EstUnFichierSolitaire                  := 0;  {1 = solitaires, 0 = autres cas}
					      ProfondeurCalculTheorique              := 24;  {profondeur de calcul du score theorique}
					      reservedByte                           := 0;
					    end;
			    
			      {WritelnDansRapport('Je dois creer un nouveau fichier dans la distribution !');}
			      
			      filename := ReplaceStringByStringInString('XXXX',NumEnString(anneePartie),GetNameOfDistribution(nroDistrib));
			      filename := GetPathOfDistribution(nroDistrib)+filename;
			      {WritelnDansRapport('filename = '+filename);}
			      
			      codeErreur := CreeFichierTexte(filename,0,fic);
			      {WritelnStringAndNumDansRapport('Après CreeFichierTexte(filename,0,fic), codeErreur = ',codeErreur);}
			      
			      if (codeErreur = NoErr) then codeErreur := OuvreFichierTexte(fic);
			      {WritelnStringAndNumDansRapport('Après OuvreFichierTexte, codeErreur = ',codeErreur);}
			      
			      if (codeErreur = NoErr) then codeErreur := EcritEnteteNouveauFormat(fic.refnum,enteteFichierPartie);
			      {WritelnStringAndNumDansRapport('Après EcritEnteteNouveauFormat, codeErreur = ',codeErreur);}
			      
			      if (codeErreur = NoErr) & AjouterFichierNouveauFormat(fic.theFSSpec,GetPathOfDistribution(nroDistrib),kFicPartiesNouveauFormat,enteteFichierPartie) 
			        then numFichier := InfosFichiersNouveauFormat.nbFichiers;
			      {WritelnStringAndNumDansRapport('Après AjouterFichierNouveauFormat, numFichier = ',numFichier);}
			      
			      if (codeErreur = NoErr) then codeErreur := FermeFichierTexte(fic);
			      {WritelnStringAndNumDansRapport('Après FermeFichierTexte, codeErreur = ',codeErreur);}
			      
			      SetFileCreatorFichierTexte(fic,'SNX4');
		        SetFileTypeFichierTexte(fic,'QWTB');
			      
			      
			    end
			  else { sinon on se contente de lire l'entete du fichier}
			    begin
			      enteteFichierPartie := InfosFichiersNouveauFormat.fichiers[numFichier].entete;
			      codeErreur := NoErr;
			    end;
			
			if (codeErreur = NoErr) & (numFichier >= 1) & (nroDistrib >= 1) then
			  begin
			  
			    {WritelnStringAndNumDansRapport('Tout a l''air bon, j''ajoute une partie au fichier numéro ',numFichier);}
			    
			    
			    GetTime(myDate);
				  with enteteFichierPartie do
				    begin
				      SiecleCreation                         := myDate.year div 100;
				      AnneeCreation                          := myDate.year mod 100;
				      MoisCreation                           := myDate.month;
				      JourCreation                           := myDate.day;
				      NombreEnregistrementsParties           := succ(NombreEnregistrementsParties);
				      NombreEnregistrementsTournoisEtJoueurs := 0;
				      AnneeParties                           := anneePartie;
				      TailleDuPlateau                        := 8;  {taille du plateau de jeu}
				      EstUnFichierSolitaire                  := 0;  {1 = solitaires, 0 = autres cas}
				      ProfondeurCalculTheorique              := 24;  {profondeur de calcul du score theorique}
				      reservedByte                           := 0;
				    end;
				    
				  codeErreur := OuvreFichierNouveauFormat(numFichier);
				  if (codeErreur = NoErr) then codeErreur := EcritPartieNouveauFormat(InfosFichiersNouveauFormat.fichiers[numFichier].refNum,enteteFichierPartie.nombreEnregistrementsParties,partieRec);
				  if (codeErreur = NoErr) then codeErreur := EcritEnteteNouveauFormat(InfosFichiersNouveauFormat.fichiers[numFichier].refNum,enteteFichierPartie);
		      if (codeErreur = NoErr) then codeErreur := FermeFichierNouveauFormat(numFichier);
		  
		      if (codeErreur = NoErr) then
		        begin
					    with InfosFichiersNouveauFormat.fichiers[numFichier] do
					      begin
					        Annee           := anneePartie;
					        NroDistribution := nroDistrib;
					        entete          := enteteFichierPartie;
					      end;
					  end;
			  end;
    end;
    
  AjouterPartieDansCetteDistribution := codeErreur;
end;




procedure DoExporterListeDePartiesEnTexte;
var descriptionLigne : str255;
    longueurSelection : SInt32;
    nbPartiesExportees : SInt32;
begin
  if FenetreRapportEstOuverte() & 
     FenetreRapportEstAuPremierPlan() & 
     SelectionRapportNonVide() 
     then
      begin
        if (LongueurSelectionRapport() < 255) then
          begin
            longueurSelection := 0;
            descriptionLigne := SelectionRapportEnString(longueurSelection);
            
            ExportListeAuFormatTexte(descriptionLigne,nbPartiesExportees);
            
            WritelnDansRapport('');
            WritelnDansRapport(' Export de la base : '+NumEnString(nbPartiesExportees)+' parties écrites dans le fichier');
          end;
      end
    else
      begin
        if not(FenetreRapportEstOuverte()) | not(FenetreRapportEstAuPremierPlan()) 
          then DoRapport;
        WritelnDansRapport('Pour exporter les parties de la liste dans un fichier texte, voici comment procéder :');
        WritelnDansRapport('  1) passer en mode "Traitement de texte" (pomme-option-T)');
        WritelnDansRapport('  2) définir la syntaxe de chaque ligne en la tapant dans le rapport');
        WritelnDansRapport('  3) sélectionner la syntaxe dans le rapport avec la souris');
        WritelnDansRapport('  4) choisir l''option "Enregistrer les parties de la liste -> format texte" dans le menu Base');
        WritelnDansRapport('');
        WritelnDansRapport('Utilisez les variables suivantes pour définir l''export : ');
        WritelnDansRapport('');
        WritelnDansRapport('   $CASSIO_GAME           :  coups de la partie');
        WritelnDansRapport('   $CASSIO_BASE           :  nom de la base');
        WritelnDansRapport('   $CASSIO_TOURN          :  nom du tournoi');
        WritelnDansRapport('   $CASSIO_TOURN_SHORT    :  nom court du tournoi');
        WritelnDansRapport('   $CASSIO_TOURN_JAPANESE :  nom du tournoi, en japonais si possible');
        WritelnDansRapport('   $CASSIO_TOURN_NUMBER   :  numéro du tournoi');
        WritelnDansRapport('   $CASSIO_YEAR           :  année'); 
        WritelnDansRapport('   $CASSIO_BLACK          :  nom du joueur Noir');    
        WritelnDansRapport('   $CASSIO_BLACK_SHORT    :  nom court du joueur Noir');
        WritelnDansRapport('   $CASSIO_BLACK_JAPANESE :  nom du joueur Noir, en japonais si possible');
        WritelnDansRapport('   $CASSIO_BLACK_NUMBER   :  numéro du joueur Noir');
        WritelnDansRapport('   $CASSIO_WHITE          :  nom du joueur Blanc');  
        WritelnDansRapport('   $CASSIO_WHITE_SHORT    :  nom court du joueur Blanc');   
        WritelnDansRapport('   $CASSIO_WHITE_JAPANESE :  nom du joueur Blanc, en japonais si possible');
        WritelnDansRapport('   $CASSIO_WHITE_NUMBER   :  numéro du joueur Blanc');
        WritelnDansRapport('   $CASSIO_SCORE_BLACK    :  score de Noir dans la partie'); 
        WritelnDansRapport('   $CASSIO_SCORE_WHITE    :  score de Blanc dans la partie');
        WritelnDansRapport('   $CASSIO_THEOR_BLACK    :  score théorique de Noir'); 
        WritelnDansRapport('   $CASSIO_THEOR_WHITE    :  score théorique de Blanc');
        WritelnDansRapport('   $CASSIO_THEOR_WINNER   :  gagnant théorique (N/B/E)');
        WritelnDansRapport('   $CASSIO_GAME_ID        :  un compteur de partie');
        WritelnDansRapport('   $CASSIO_THOR_MOVES     :  coups de la partie au format WThor');
        WritelnDansRapport('   $CASSIO_SWEDISH_MOVES  :  coups de la partie au format MySQL pour reversi.se');
        
        WritelnDansRapport('   On peut échapper le caractère $ avec \$, et \ avec \\');
        WritelnDansRapport('');
        WritelnDansRapport('Quelques exemples : ');
        WritelnDansRapport('');
        WritelnDansRapport(' $CASSIO_GAME ');
        WritelnDansRapport(' $CASSIO_GAME : ($CASSIO_TOURN $CASSIO_YEAR) ');
        WritelnDansRapport(' $CASSIO_GAME : ($CASSIO_TOURN $CASSIO_YEAR) $CASSIO_BLACK - $CASSIO_WHITE ');
        WritelnDansRapport(' $CASSIO_GAME : ($CASSIO_TOURN $CASSIO_YEAR) $CASSIO_BLACK $CASSIO_SCORE_BLACK-$CASSIO_SCORE_WHITE $CASSIO_WHITE ');
        WritelnDansRapport(' $CASSIO_GAME : ($CASSIO_TOURN $CASSIO_YEAR) $CASSIO_SCORE_BLACK-$CASSIO_SCORE_WHITE ');
        WritelnDansRapport(' $CASSIO_GAME : $CASSIO_BLACK - $CASSIO_WHITE ');
        WritelnDansRapport(' $CASSIO_GAME : $CASSIO_BLACK $CASSIO_SCORE_BLACK-$CASSIO_SCORE_WHITE $CASSIO_WHITE ');
        WritelnDansRapport(' INSERT INTO `thor_db` VALUES ($CASSIO_TOURN_NUMBER, $CASSIO_BLACK_NUMBER, $CASSIO_WHITE_NUMBER, $CASSIO_SCORE_BLACK, $CASSIO_THEOR_BLACK, ''$CASSIO_SWEDISH_MOVES'', $CASSIO_YEAR, $CASSIO_GAME_ID);'); 

        
      end;
end;

end.