UNIT UnitRechSolitNouveauFormat;


{$DEFINEC USE_PROFILER_RECHHERCHE_SOLITAIRES   FALSE}

INTERFACE







uses MacTypes;


procedure ChercheSolitairesDansListe(nroPartiemin,nroPartiemax : SInt32;premierCoup,dernierCoup : SInt16);
procedure ProcessEachSolitaireOnDisc(debut,fin : SInt32);


IMPLEMENTATION







USES 
{$IFC USE_PROFILER_RECHHERCHE_SOLITAIRES}
    Profiler,
{$ENDC}
    UnitSolitaire,UnitDistribOfficielleSolit,UnitAccesStructuresNouvFormat,UnitListe,
    UnitOth1,UnitActions,UnitRapport,SNStrings,UnitFenetres,UnitMacExtras;



var gPremierCoupRechercheSol,gDernierCoupRechercheSol : SInt16; 
    gNroPartieMinRechercheSol,gNroPartieMaxRechercheSol : SInt32;
    nbreSolitairesTotal : SInt32;
    gTempsRestantEstime : SInt32;
    gNbresCasesVidesCouranteRechSolitaires : SInt32;
    nbreSolitaires : array[1..64] of SInt32;
    gCaseVideDemandeeRechercheSolitaires : array[1..64] of boolean;


function DoitChercherCelleLa(numeroDansLaListe,numeroPartie : SInt32; var result : SInt32) : boolean;
begin  {$UNUSED numeroDansLaListe,result}
  DoitChercherCelleLa := (interruptionReflexion = pasdinterruption) &
                         (numeroPartie >= gNroPartieMinRechercheSol) & 
                         (numeroPartie <= gNroPartieMaxRechercheSol);
                         
end;

function DoitChercherCeCoupLa(numeroCoup : SInt16) : boolean;
var nbreDeCasesVides : SInt16; 
begin  
  nbreDeCasesVides := 60 - numeroCoup + 1;
  DoitChercherCeCoupLa := (interruptionReflexion = pasdinterruption) & 
                          (numeroCoup >= gPremierCoupRechercheSol) & 
                          (numeroCoup <= gDernierCoupRechercheSol) &
                          gCaseVideDemandeeRechercheSolitaires[nbreDeCasesVides];
end;
 

procedure ChercherSolitaireCettePosition(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFrontRec;nbNoir,nbBlanc,trait : SInt16; var nroPartie : SInt32);
var numeroCoup,profondeur : SInt16; 
    meilleurCoup,meilleurDef : SInt32;
    score,nbreCoupsOptimaux : SInt32;
    causeRejet : SInt32;
    nouveauSolitaire : boolean;
    theSolitaire:t_SolitaireRecNouveauFormat;
    annee : SInt16; 
    nroTournoi : SInt16; 
    nroJoueurNoir : SInt32;          
	  nroJoueurBlanc : SInt32;
	  scoreTheorique,scoreReelPartie : SInt16; 
	  coup25deLaPartie : byte;
	  erreurES : OSErr;
	  oldPort : grafPtr;
begin
  numeroCoup := nbNoir + nbBlanc - 4 + 1;
  
  if DoitChercherCeCoupLa(numeroCoup) then
    begin
      profondeur := 64 - nbNoir - nbBlanc;
      
      
      GetPort(oldPort);
      EssaieSetPortWindowPlateau;
      PrepareTexteStatePourMeilleureSuite;
		  WriteStringAndNumAt('nroPartie = ',nroPartie,2,380);
		  WriteStringAndNumAt('nbreTotalSolitaires = ',nbreSolitairesTotal,2,395);
		  WriteStringAt('temps restant estimé pour '+NumEnString(gNbresCasesVidesCouranteRechSolitaires) + ' cases vides = '+SecondesEnJoursHeuresSecondes(gTempsRestantEstime)+'                  ',2,410);
      SetPort(oldPort);
      
      nouveauSolitaire := EstUnSolitaire(meilleurCoup,meilleurDef,trait,profondeur,nbBlanc,nbNoir,
                                        position,jouable,frontiere,score,nbreCoupsOptimaux,false,causeRejet,kRechercheSolitairesDansBase,64);
      
      if nouveauSolitaire then
        begin
          annee := GetAnneePartieParNroRefPartie(nroPartie);
          nroTournoi := GetNumeroTournoiDansFichierParNroRefPartie(nroPartie);
          nroJoueurNoir := GetNumeroJoueurNoirDansFichierParNroRefPartie(nroPartie);
          nroJoueurBlanc := GetNumeroJoueurBlancDansFichierParNroRefPartie(nroPartie);
          GetScoresTheoriqueEtReelParNroRefPartie(nroPartie,scoreTheorique,scoreReelPartie);
          ExtraitCoupTableStockagePartie(nroPartie,25,coup25deLaPartie);
          
          theSolitaire := MakeSolitaireRecNouveauFormat(annee,nroTournoi,nroJoueurNoir,nroJoueurBlanc,position,trait,score,meilleurCoup,scoreReelPartie,coup25deLaPartie);
          
          WritelnDansRapport(FabriqueCommentaireSolitaireNouveauFormat(theSolitaire));
          
          erreurES := AjouterSolitaireNouveauFormatSurDisque(profondeur,theSolitaire);
          if erreurES<>NoErr 
            then
	            begin
	              WritelnStringAndNumDansRapport('erreurES = ',erreurES);
	              WritelnStringAndNumDansRapport('nroPartie = ',nroPartie);
	              WritelnStringAndNumDansRapport('numeroCoup = ',numeroCoup);
	            end
	          else
	            begin
	              nbreSolitairesTotal := nbreSolitairesTotal+1;
                nbreSolitaires[numeroCoup] := nbreSolitaires[numeroCoup]+1;
                
                GetPort(oldPort);
                EssaieSetPortWindowPlateau;
                PrepareTexteStatePourMeilleureSuite;
                WriteStringAndNumAt('nb sol['+NumEnString(numeroCoup)+'] = ',nbreSolitaires[numeroCoup],2,42+12*(nbreSolitairesTotal mod 25));
                SetPort(oldPort);
                                      
	            end;
          
        end;
                              
    end;
end;

procedure ChercherSolitaires(var partie60 : PackedThorGame;nroPartie : SInt32; var tickDepartRechercheSolitaires : SInt32);
var tempsUtilise,tempsTotalEstime,tempsRestantEstime : SInt32;  
    x,n : SInt32;
    oldPort : grafPtr;
begin  
  ForEachPositionInGameDo(partie60,ChercherSolitaireCettePosition,nroPartie);
  
  x := nroPartie - gNroPartieMinRechercheSol;
  n := gNroPartieMaxRechercheSol - gNroPartieMinRechercheSol;
  
  tempsUtilise := (TickCount() - tickDepartRechercheSolitaires) div 60;  {en secondes}
  if (tempsUtilise <= 0) | (x <= 0) | (n <= 0)
    then 
      begin
        tempsTotalEstime := 0;
        tempsRestantEstime := 0;
      end
    else
      begin
        tempsTotalEstime := (n * tempsUtilise) div x;
        tempsRestantEstime := tempsTotalEstime - tempsUtilise;
      end;
  gTempsRestantEstime := tempsRestantEstime;
  
  GetPort(oldPort);
  EssaieSetPortWindowPlateau;
  PrepareTexteStatePourMeilleureSuite;
  WriteStringAndNumAt('nroPartie = ',nroPartie,2,380);
  WriteStringAndNumAt('nbreSolitairesTotal = ',nbreSolitairesTotal,2,395);
  WriteStringAt('temps restant estimé pour '+NumEnString(gNbresCasesVidesCouranteRechSolitaires) + ' cases vides = '+SecondesEnJoursHeuresSecondes(tempsRestantEstime),2,410);
  SetPort(oldPort);
end;


procedure ChercheSolitairesDansListe(nroPartiemin,nroPartiemax : SInt32;premierCoup,dernierCoup : SInt16);
var tickDepartRechercheSolitaires : SInt32;
    i : SInt16; 
    tempoEcritToutDansRapport : boolean;
    tempoAutoVidageDuRapport : boolean;
    coup,k : SInt16; 
    
    
    {$IFC USE_PROFILER_RECHHERCHE_SOLITAIRES}
    nomFichierProfile : str255;
    {$ENDC}
begin

  tempoEcritToutDansRapport := GetEcritToutDansRapportLog();
  tempoAutoVidageDuRapport := GetAutoVidageDuRapport();
  SetEcritToutDansRapportLog(true);
  SetAutoVidageDuRapport(true);
 
  gPremierCoupRechercheSol := premierCoup;
  gDernierCoupRechercheSol := dernierCoup;
  if gPremierCoupRechercheSol < 1  then gPremierCoupRechercheSol := 1;
  if gDernierCoupRechercheSol > 60 then gDernierCoupRechercheSol := 60;
  
  gNroPartieMinRechercheSol := nroPartiemin;
  gNroPartieMaxRechercheSol := nroPartiemax;
  
  SensLargeSolitaire := true;
  nbreSolitairesTotal := 0;
  for i := 1 to 64 do
    nbreSolitaires[i] := 0;
    
  referencesCompletes := true;
   
   
  {$IFC USE_PROFILER_RECHHERCHE_SOLITAIRES}
  if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr 
    then ProfilerSetStatus(1);
  {$ENDC}
   
   
  {on fait chaque nombre de cases vide dans l'ordre, et donc plusieurs passes sur la liste des parties}
  for coup := dernierCoup downto premierCoup do
    begin
    
      gNbresCasesVidesCouranteRechSolitaires := 60 - coup + 1;
      
      for k := 1 to 64 do 
        gCaseVideDemandeeRechercheSolitaires[k] := false;
      gCaseVideDemandeeRechercheSolitaires[gNbresCasesVidesCouranteRechSolitaires] := SolitairesDemandes[gNbresCasesVidesCouranteRechSolitaires];
    
		  tickDepartRechercheSolitaires := TickCount();
		  
		  if SolitairesDemandes[gNbresCasesVidesCouranteRechSolitaires] then
		    begin
		      WritelnDansRapport('Calcul des solitaires à '+NumEnString(gNbresCasesVidesCouranteRechSolitaires) + ' cases vides…');
		      ForEachGameInListDo(DoitChercherCelleLa,bidFiltreGameProc,ChercherSolitaires,tickDepartRechercheSolitaires);
		    end;
		  
      
    end;
  
  WritelnDansRapport('Terminé !');
  
  {$IFC USE_PROFILER_RECHHERCHE_SOLITAIRES}
   nomFichierProfile := 'solitaires.profile';
   WritelnDansRapport('nomFichierProfile = '+nomFichierProfile);
   if ProfilerDump(nomFichierProfile) <> NoErr 
     then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfile+') a échoué !')
     else ProfilerSetStatus(0);
   ProfilerTerm;
  {$ENDC}
  
  SetEcritToutDansRapportLog(tempoEcritToutDansRapport);
  SetAutoVidageDuRapport(tempoAutoVidageDuRapport);
end;


function TrouveSolitaireDansListe(whichSolitaire:t_SolitaireRecNouveauFormat; var numPartie : SInt32) : boolean;
var nroRefPartie : SInt32;
    positionEtTraitPartie : PositionEtTraitRec;
    positionEtTraitSolitaire : PositionEtTraitRec;
    partie60 : PackedThorGame; 
    numeroCoup,erreur : SInt32;
begin
  TrouveSolitaireDansListe := false;
  numPartie := -1;
  
  with whichSolitaire do
    begin
      case traitSolitaire of
        1 : positionEtTraitSolitaire := MakePositionEtTrait(PackedOthelloPositionToPlOth(position),pionNoir);
        2 : positionEtTraitSolitaire := MakePositionEtTrait(PackedOthelloPositionToPlOth(position),pionBlanc);
        otherwise 
          begin
            SysBeep(0);
            WritelnDansRapport('traitSolitaire solitaire inconnu dans TrouveSolitaireDansListe !!');
            positionEtTraitSolitaire := PositionEtTraitInitiauxStandard();
          end;
      end; {case}
      (*
      WritelnDansRapport('position solitaire :');
      WritelnPositionEtTraitDansRapport(positionEtTraitSolitaire.position,positionEtTraitSolitaire.trait);
      *)
                 
      for nroRefPartie := 1 to nbPartiesActives do
        begin
          if (GetNumeroTournoiDansFichierParNroRefPartie(nroRefPartie) = nroTournoi) &
             (GetAnneePartieParNroRefPartie(nroRefPartie) = annee) &
             (GetNumeroJoueurNoirDansFichierParNroRefPartie(nroRefPartie) = nroJoueurNoir) &
             (GetNumeroJoueurBlancDansFichierParNroRefPartie(nroRefPartie) = nroJoueurBlanc)
             then
               begin
                 ExtraitPartieTableStockageParties(nroRefPartie,partie60);
                 
                 numeroCoup := 60 - nbVides;
                 
                 positionEtTraitPartie := PositionEtTraitAfterMoveNumber(partie60,numeroCoup,erreur);
                 (*
                 WritelnStringAndNumDansRapport('position dans liste : ',nroRefPartie);
                 WritelnPositionEtTraitDansRapport(positionEtTraitPartie.position,positionEtTraitPartie.trait);
                 *)
                 
                 if SamePositionEtTrait(positionEtTraitSolitaire,positionEtTraitPartie)
                   then
                     begin
                       numPartie := nroRefPartie;
                       TrouveSolitaireDansListe := true;
                       exit(TrouveSolitaireDansListe);
                     end;
               end;
             
        end;
    end;
end;


procedure ProcessEachSolitaireOnDisc(debut,fin : SInt32);
var error : OSErr;
    nbSolDansFichier,numPartieDansListe : SInt32;
    k,t,compteur,lastProcessedSolitaire,firstProcessedSolitaire : SInt32;
    numFichier : SInt16; 
    theSolitaire:t_SolitaireRecNouveauFormat;
    myCoup25 : byte;
begin
  
  compteur := 0;
  lastProcessedSolitaire := -1;
  firstProcessedSolitaire := -1;
  
  for k := 1 to 64 do
    if not(Quitter) then
    begin
      error := OuvreFichierSolitaireNouveauFormat(k);
      
      if error <> NoErr 
        then
          begin
          	WritelnStringAndNumDansRapport('erreur d''ouverture du '+NumEnString(k)+'ieme fic solitaire, error = ',error);
          end
        else
          begin
		        if GetNumeroFichierSolitaireNouveauFormat(k,numFichier) then
		          with InfosFichiersNouveauFormat.fichiers[numFichier] do
		          begin
				        nbSolDansFichier := NbSolitairesDansFichierSolitairesNouveauFormat(numFichier);
				        {WritelnStringAndNumDansRapport('nb sol a prof '+NumEnString(k)+' = ',nbSolDansFichier);}
				        for t := 1 to nbSolDansFichier do
					        begin
					          inc(compteur);
					          {if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;}
					          
					          if not(Quitter) & (compteur >= debut) & (compteur <= fin) then
					            begin 
		                    error := LitSolitaireNouveauFormat(refNum,t,theSolitaire);
		                    if error <> NoErr
		                      then WritelnStringAndNumDansRapport('erreur de lecture, compteur = ',compteur)
		                      else
		                        begin
		                          {faire qq chose avec le t-ieme solitaire du fichier numFichier}
		                          
		                          
		                          
		                          
		                          if TrouveSolitaireDansListe(theSolitaire,numPartieDansListe) 
		                            then 
		                              begin
		                                ExtraitCoupTableStockagePartie(numPartieDansListe,25,myCoup25);
		                                theSolitaire.coup25 := myCoup25;
		                                theSolitaire.scoreReel := GetScoreReelParNroRefPartie(numPartieDansListe);
		                                {WritelnStringAndNumDansRapport('trouve['+NumEnString(compteur)+'] : ',numPartieDansListe)}
		                              end
		                            else 
		                              begin
		                                WritelnStringAndNumDansRapport('non trouve['+NumEnString(compteur)+'] : ',numPartieDansListe);
		                                WritelnDansRapport(FabriqueCommentaireSolitaireNouveauFormat(theSolitaire));
		                                with theSolitaire do
					                            begin
					                              nroJoueurNoir := nroJoueurNoir + 6 * 256;
																	      nroJoueurBlanc := nroJoueurBlanc + 6 * 256;
																	      nroTournoi := nroTournoi + 256;
					                            end;
		                                if TrouveSolitaireDansListe(theSolitaire,numPartieDansListe) 
		                                  then
		                                    begin
		                                      ExtraitCoupTableStockagePartie(numPartieDansListe,25,myCoup25);
					                                theSolitaire.coup25 := myCoup25;
					                                theSolitaire.scoreReel := GetScoreReelParNroRefPartie(numPartieDansListe);
		                                      WritelnDansRapport('problème corrigé !');
		                                      WritelnDansRapport(FabriqueCommentaireSolitaireNouveauFormat(theSolitaire));
		                                    end
		                                  else
		                                    with theSolitaire do
							                            begin
							                              nroJoueurNoir := nroJoueurNoir - 6 * 256;
																			      nroJoueurBlanc := nroJoueurBlanc - 6 * 256;
																			      nroTournoi := nroTournoi - 256;
							                            end;
		                                {Quitter := true;}
		                              end;
		                              
		                          error := EcritSolitaireNouveauFormat(refNum,t,theSolitaire);
		                          if error <> NoErr
		                            then WritelnStringAndNumDansRapport('erreur d''ecriture, compteur = ',compteur)
		                            else 
		                              begin
		                                if firstProcessedSolitaire = -1
		                                  then firstProcessedSolitaire := compteur;
		                                lastProcessedSolitaire := compteur;
		                              end;
		                        end;
					              if t mod 500 = 0 then 
					                WritelnDansRapport(NumEnString(t)+'…');
					            end;
					        end;
					    end;
					end;
		    
      error := FermeFichierSolitaireNouveauFormat(k);
      WritelnStringAndNumDansRapport('après la fermeture du '+NumEnString(k)+'ieme fic solitaire, lastProcessedSolitaire = ',lastProcessedSolitaire);
    end;
  Quitter := false;

  WritelnStringAndNumDansRapport('Premier solitaire traité dans ProcessEachSolitaireOnDisc = ',firstProcessedSolitaire);
  WritelnStringAndNumDansRapport('Dernier solitaire traité dans ProcessEachSolitaireOnDisc = ',lastProcessedSolitaire);
  WritelnDansRapport('Tapez une touche…');
  SysBeep(0);
  AttendFrappeClavier;
end;

END.