UNIT UnitBaseOfficielle;



INTERFACE


USES UnitDefinitionsNouveauFormat,UnitListe;


const kWTHOR_JOU = kFicJoueursNouveauFormat;
      kWTHOR_TRN = kFicTournoisNouveauFormat;


{Interface de commande}
function DoActionGestionBaseOfficielle(commande : str255) : OSErr;
procedure CreerOuRenommerMachinDansLaBaseOfficielle;
procedure CreerPlusieursJoueursDansBaseOfficielle;


{Fonction d'acces en lecture aux listes de joueurs et de tournois}
function FindPlayerDansBaseOfficielle(joueur : str255) : OSErr;
function FindTournamentDansBaseOfficielle(tournoi : str255) : OSErr;
function ListerDerniersJoueursBaseOfficielleDansRapport(nbreJoueurs : SInt32) : OSErr;
function ListerDerniersTournoisBaseOfficielleDansRapport(nbreTournois : SInt32) : OSErr; 
function JoueurEstDonneParSonNumero(joueur : str255; var outNumber : SInt32) : boolean;
function TournoiEstDonneParSonNumero(tournoi : str255; var outNumber : SInt32) : boolean;


{Les actions de creation/renommage de joueurs et de tournois}
function RenommerJoueurDansFichierWThorOfficiel(oldName,newName : str255) : OSErr;
function RenommerTournoiDansFichierWThorOfficiel(oldName,newName : str255) : OSErr;
procedure ChangeBlackPlayer(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var numeroNoir : SInt32);
procedure ChangeWhitePlayer(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var numeroBlanc : SInt32);
procedure ChangeTournament(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var numeroTournoi : SInt32);
procedure ChangeYear(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var anneePartie : SInt32);
procedure CalculeScoreTheorique(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var scoreTheoriquePourNoir : SInt32);


{Modifications des infos dans les parties de la liste}
function ChangeNumerosJoueursEtTournoisDansListe(noir,blanc,tournoi : str255;surQuellesParties:FiltreNumRefProc) : OSErr;
function ChangeAnneeDansListe(annee : SInt32;surQuellesParties:FiltreNumRefProc) : OSErr;
function CalculerScoresTheoriquesPartiesDansListe(apresQuelCoup : SInt32;surQuellesParties:FiltreNumRefProc) : OSErr;


{Gestion du fichier "Database/Gestion base Wthor/WThor.log"}
function OuvreFichierTraceWThor() : OSErr;
function FermeFichierTraceWThor() : OSErr;
procedure WriteInTraceWThorLog(s : str255);


IMPLEMENTATION

USES UnitRapport,UnitRapportImplementation,UnitNouveauFormat,UnitServicesDialogs,UnitUtilitaires,MyStrings,
     UnitAccesStructuresNouvFormat,UnitEntreesSortiesListe,UnitListe,MyTypes,UnitFinalePourPositionEtTrait,
     SNStrings,UnitPhasesPartie;


var FichierWThorLog : FichierTEXT;
    gInfosCalculScoresTheoriques : record
                                     apresQuelCoup                : SInt32;
                                     tickDepart                   : SInt32;  {en ticks}
                                     nbCalculsAFaire              : SInt32;
                                     nbPartiesCalculees           : SInt32;
                                     nbPartiesImpossibles         : SInt32;
                                     numeroReferencePartieEnCours : SInt32;
                                     tempsMoyenParPartie          : extended;  {en secondes}
                                     tempsRestantEstime           : extended;  {en secondes}
                                   end;


function OuvreFichierTraceWThor() : OSErr;
var erreurES : OSErr;
begin
  erreurES := FichierTexteExiste(PathDuDossierDatabase() + ':Gestion Base WThor:WThor.log',0,FichierWThorLog);
  if erreurES=fnfErr then {-43 => fichier non trouvé, on le crée}
    begin
      erreurES := CreeFichierTexte(PathDuDossierDatabase() + ':Gestion Base WThor:WThor.log',0,FichierWThorLog);
      SetFileCreatorFichierTexte(FichierWThorLog,'R*ch');  {BBEdit}
      SetFileTypeFichierTexte(FichierWThorLog,'TEXT');
    end;
  if erreurES=NoErr then
    erreurES := OuvreFichierTexte(FichierWThorLog);
  OuvreFichierTraceWThor := erreurES;
end;

function FermeFichierTraceWThor() : OSErr;
begin
  FermeFichierTraceWThor := FermeFichierTexte(FichierWThorLog);
end;


procedure WriteInTraceWThorLog(s : str255);
var erreurES : OSErr;
    oldEcritureDansLog : boolean;
    oldDebuggageUnitFichierTexte : boolean;
begin
  oldDebuggageUnitFichierTexte := GetDebuggageUnitFichiersTexte();
  oldEcritureDansLog := GetEcritToutDansRapportLog();
  
  SetDebuggageUnitFichiersTexte(false);
  SetEcritToutDansRapportLog(false);
  
  s := '     ' + s;
  
  erreurES := OuvreFichierTraceWThor();
  if (erreurES = NoErr) then erreurES := SetPositionTeteLectureFinFichierTexte(FichierWThorLog);
  if (erreurES = NoErr) then erreurES := WritelnDansFichierTexte(FichierWThorLog,s);
  WritelnDansRapport(s);
  if (erreurES = NoErr) then erreurES := FermeFichierTraceWThor();
  
  SetDebuggageUnitFichiersTexte(oldDebuggageUnitFichierTexte);
  SetEcritToutDansRapportLog(oldEcritureDansLog);
end;



function JoueurEstDonneParSonNumero(joueur : str255; var outNumber : SInt32) : boolean;
begin
  if (Length(joueur) >= 2) & (joueur[1] = '#')
    then
      begin
        JoueurEstDonneParSonNumero := true;
        ChaineToLongint(RightOfString(joueur,Length(joueur) - 1),outNumber);
      end
    else
      JoueurEstDonneParSonNumero := false;
end;


function TournoiEstDonneParSonNumero(tournoi : str255; var outNumber : SInt32) : boolean;
begin
  if (Length(tournoi) >= 2) & (tournoi[1] = '#')
    then
      begin
        TournoiEstDonneParSonNumero := true;
        ChaineToLongint(RightOfString(tournoi,Length(tournoi) - 1),outNumber);
      end
    else
      TournoiEstDonneParSonNumero := false;
end;


function RenommerJoueurDansFichierWThorOfficiel(oldName,newName : str255) : OSErr;
label sortie;
var err : OSErr;
    entete : t_EnTeteNouveauFormat;
    joueur:t_JoueurRecNouveauFormat;
    fic : FichierTEXT;
    typeFichier : SInt16; 
    pathFichier,message : str255;
    numeroJoueur : SInt32;
begin
  message := '## WARNING ## : this is not a message';
  
  if (GetNiemeCaractereDuRapport(GetTailleRapport()-1) <> cr) 
    then WritelnDansRapport('');

  pathFichier := PathDuDossierDatabase() + ':Gestion Base WThor:WTHOR.JOU';
  
  err := FichierTexteExiste(pathFichier,0,fic);
  
  if (err = NoErr) & 
     EstUnFichierNouveauFormat(fic.theFSSpec,typeFichier,entete) &
     (typeFichier = kFicJoueursNouveauFormat) then
     begin
     
       if (entete.NombreEnregistrementsTournoisEtJoueurs >= 65535)
         then
           begin
             AlerteSimple('Le fichier WTHOR.JOU officiel est plein !');
             WriteInTraceWThorLog('');
             WriteInTraceWThorLog('## WARNING ## : Le fichier WTHOR.JOU officiel est plein !');
             err := -1;
             goto sortie;
           end
         else
           begin
             EnleveEspacesDeGaucheSurPlace(oldName);
             if (oldName <> '') 
               then  {renommage : on essaye de remplacer un vieux nom}
                 begin
                   if (JoueurEstDonneParSonNumero(oldname,numeroJoueur) | TrouveNumeroDuJoueur(oldname,numeroJoueur,0,kChercherSeulementDansBaseOfficielle)) &
                      (numeroJoueur = GetNroJoueurDansSonFichier(numeroJoueur))
                     then
                       begin
                         joueur := FabriqueNomJoueurPourBaseWThorOfficielle(newName);
                         message := 'Player "'+GetNomJoueur(numeroJoueur)+'" renamed to "'+newName+'" (#'+NumEnString(numeroJoueur)+')';
                       end
                     else
                       begin
                         WriteInTraceWThorLog('');
                         WriteInTraceWThorLog('## WARNING ## : Player "'+oldname+'" not found');
                         err := -2;
                         goto sortie;
                       end;
                 end
               else  {creation : on cree un nouveau joueur}
                 begin
                   numeroJoueur := entete.NombreEnregistrementsTournoisEtJoueurs;
                   
                   inc(entete.NombreEnregistrementsTournoisEtJoueurs);
                   joueur := FabriqueNomJoueurPourBaseWThorOfficielle(newName);
                   
                   message := 'Player "'+newName+'" added (#'+NumEnString(numeroJoueur)+')';
                 end;
           end;
				  
			 (* Ecriture du joueur dans le fichier WTHOR.JOU officiel *)
			 
       err := OuvreFichierTexte(fic);
       if (err = NoErr) then err := EcritJoueurNouveauFormat(fic.refNum,numeroJoueur,joueur);
       if (err = NoErr) then err := EcritEnteteNouveauFormat(fic.refNum,entete);
       err := FermeFichierTexte(fic);
       
       
       (* ... et on essaie aussi de changer le joueur en mémoire *)
       
       AjouterJoueurEnMemoire(JoueurRecNouveauFormatToString(joueur),numeroJoueur,numeroJoueur);
       if ((numeroJoueur + 1) > NombreJoueursDansBaseOfficielle()) then SetNombreJoueursDansBaseOfficielle(numeroJoueur+1);
     end;
  
  sortie :
  
  WriteInTraceWThorLog('');
  if (err = NoErr)
    then WriteInTraceWThorLog(message)
    else WriteInTraceWThorLog('## WARNING ## : Failure in RenommerJoueurDansFichierWThorOfficiel, err = '+NumENString(err));
  
  RenommerJoueurDansFichierWThorOfficiel := err;
end;



function RenommerTournoiDansFichierWThorOfficiel(oldName,newName : str255) : OSErr;
label sortie;
var err : OSErr;
    entete : t_EnTeteNouveauFormat;
    tournoi : t_TournoiRecNouveauFormat;
    fic : FichierTEXT;
    typeFichier : SInt16; 
    pathFichier,message : str255;
    numeroTournoi : SInt32;
begin
  message := '## WARNING ## : this is not a message';
  if (GetNiemeCaractereDuRapport(GetTailleRapport()-1) <> cr) 
    then WritelnDansRapport('');

  pathFichier := PathDuDossierDatabase() + ':Gestion Base WThor:WTHOR.TRN';
  
  err := FichierTexteExiste(pathFichier,0,fic);
  
  if (err = NoErr) & 
     EstUnFichierNouveauFormat(fic.theFSSpec,typeFichier,entete) &
     (typeFichier = kFicTournoisNouveauFormat) then
     begin
     
       if (entete.NombreEnregistrementsTournoisEtJoueurs >= 65535)
         then
           begin
             AlerteSimple('Le fichier WTHOR.TRN officiel est plein !');
             WriteInTraceWThorLog('');
             WriteInTraceWThorLog('## WARNING ## : Le fichier WTHOR.TRN officiel est plein !');
             err := -1;
             goto sortie;
           end
         else
           begin
             EnleveEspacesDeGaucheSurPlace(oldName);
             if (oldName <> '') 
               then  {renommage : on essaye de remplacer un vieux nom}
                 begin
                   if (TournoiEstDonneParSonNumero(oldname,numeroTournoi) | TrouveNumeroDuTournoi(oldname,numeroTournoi,0)) &
                      (numeroTournoi = GetNroTournoiDansSonFichier(numeroTournoi))
                     then
                       begin
                         tournoi := FabriqueNomTournoiPourBaseWThorOfficielle(newName);
                         message := 'Tourney "'+GetNomTournoi(numeroTournoi)+'" renamed to "'+newName+'" (#'+NumEnString(numeroTournoi)+')';
                       end
                     else
                       begin
                         WriteInTraceWThorLog('');
                         WriteInTraceWThorLog('## WARNING ## : Tourney "'+oldname+'" not found');
                         err := -2;
                         goto sortie;
                       end;
                 end
               else  {creation : on cree un nouveau tournoi}
                 begin
                   numeroTournoi := entete.NombreEnregistrementsTournoisEtJoueurs;
                   
                   inc(entete.NombreEnregistrementsTournoisEtJoueurs);
                   tournoi := FabriqueNomTournoiPourBaseWThorOfficielle(newName);
                   
                   
                   message := 'Tourney "'+newName+'" added (#'+NumEnString(numeroTournoi)+')';
                 end;
           end;
				  
			 (* Ecriture du tournoi dans le fichier WTHOR.TRN officiel *)
			 
       err := OuvreFichierTexte(fic);
       if (err = NoErr) then err := EcritTournoiNouveauFormat(fic.refNum,numeroTournoi,tournoi);
       if (err = NoErr) then err := EcritEnteteNouveauFormat(fic.refNum,entete);
       err := FermeFichierTexte(fic);
       
       (* ... et on essaie aussi de changer le tournoi en mémoire *)
       
       AjouterTournoiEnMemoire(TournoiRecNouveauFormatToString(tournoi),numeroTournoi,numeroTournoi);
       if ((numeroTournoi + 1) > NombreTournoisDansBaseOfficielle()) then SetNombreTournoisDansBaseOfficielle(numeroTournoi+1);
     end;
  
  sortie :
  
  WriteInTraceWThorLog('');
  if (err = NoErr)
    then WriteInTraceWThorLog(message)
    else WriteInTraceWThorLog('## WARNING ## : Failure in RenommerTournoiDansFichierWThorOfficiel, err = '+NumENString(err));
  
  RenommerTournoiDansFichierWThorOfficiel := err;
end;



function FindPlayerDansBaseOfficielle(joueur : str255) : OSErr;
var numeroJoueur : SInt32;
begin
  if (GetNiemeCaractereDuRapport(GetTailleRapport()-1) <> cr) 
    then WritelnDansRapport('');
  
  EnleveEspacesDeGaucheSurPlace(joueur);
  
  if (JoueurEstDonneParSonNumero(joueur,numeroJoueur) | TrouveNumeroDuJoueur(joueur,numeroJoueur,0,kChercherSeulementDansBaseOfficielle)) &
     (numeroJoueur = GetNroJoueurDansSonFichier(numeroJoueur))
     then
       begin
         WriteInTraceWThorLog('');
         WriteInTraceWThorLog('Player found : "'+GetNomJoueur(numeroJoueur)+'" (#'+NumEnString(numeroJoueur)+')');
         FindPlayerDansBaseOfficielle := NoErr;
       end
     else
       begin
         WriteInTraceWThorLog('');
         WriteInTraceWThorLog('Player "'+joueur+'" not found');
         FindPlayerDansBaseOfficielle := -1;
       end;
end;


function FindTournamentDansBaseOfficielle(tournoi : str255) : OSErr;
var numeroTournoi : SInt32;
begin
  if (GetNiemeCaractereDuRapport(GetTailleRapport()-1) <> cr) 
    then WritelnDansRapport('');
  
  EnleveEspacesDeGaucheSurPlace(tournoi);
  
  if (TournoiEstDonneParSonNumero(tournoi,numeroTournoi) | TrouveNumeroDuTournoi(tournoi,numeroTournoi,0)) &
     (numeroTournoi = GetNroTournoiDansSonFichier(numeroTournoi))
     then
       begin
         WriteInTraceWThorLog('');
         WriteInTraceWThorLog('Tourney found : "'+GetNomTournoi(numeroTournoi)+'" (#'+NumEnString(numeroTournoi)+')');
         FindTournamentDansBaseOfficielle := NoErr;
       end
     else
       begin
         WriteInTraceWThorLog('');
         WriteInTraceWThorLog('Tourney "'+tournoi+'" not found');
         FindTournamentDansBaseOfficielle := -1;
       end;
end;


procedure ChangeBlackPlayer(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var numeroNoir : SInt32);
begin {$UNUSED partie60}
  SetNroJoueurNoirParNroRefPartie(numeroReferencePartie,numeroNoir);
end;


procedure ChangeWhitePlayer(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var numeroBlanc : SInt32);
begin {$UNUSED partie60}
  SetNroJoueurBlancParNroRefPartie(numeroReferencePartie,numeroBlanc);
end;


procedure ChangeTournament(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var numeroTournoi : SInt32);
begin {$UNUSED partie60}
  SetNroTournoiParNroRefPartie(numeroReferencePartie,numeroTournoi);
end;


procedure ChangeYear(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var anneePartie : SInt32);
begin {$UNUSED partie60}
  SetAnneePartieParNroRefPartie(numeroReferencePartie,anneePartie);
end;


function ChangeNumerosJoueursEtTournoisDansListe(noir,blanc,tournoi : str255;surQuellesParties:FiltreNumRefProc) : OSErr;
var numeroJoueur,numeroTournoi : SInt32;
    nbPartiesAChanger,bidon : SInt32;
    s : str255;
begin
  if (GetNiemeCaractereDuRapport(GetTailleRapport()-1) <> cr) 
    then WritelnDansRapport('');
    
  nbPartiesAChanger := NumberOfGamesWithThisReferenceFilter(surQuellesParties,bidon);
  
  EnleveEspacesDeGaucheSurPlace(noir);
  if (noir <> '') & 
     (JoueurEstDonneParSonNumero(noir,numeroJoueur) | TrouveNumeroDuJoueur(noir,numeroJoueur,0,kChercherSeulementDansBaseOfficielle)) &
     (numeroJoueur = GetNroJoueurDansSonFichier(numeroJoueur)) then
    begin
      ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,ChangeBlackPlayer,numeroJoueur);
      s := 'Black player changed to "^0" (#^1) in ^2 games';
      s := ParamStr(s,GetNomJoueur(numeroJoueur),NumEnString(numeroJoueur),NumEnString(nbPartiesAChanger),'');
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog(s);
    end;
  
  
  EnleveEspacesDeGaucheSurPlace(blanc);
  if (blanc <> '') & 
     (JoueurEstDonneParSonNumero(blanc,numeroJoueur) | TrouveNumeroDuJoueur(blanc,numeroJoueur,0,kChercherSeulementDansBaseOfficielle)) &
     (numeroJoueur = GetNroJoueurDansSonFichier(numeroJoueur)) then
    begin
      ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,ChangeWhitePlayer,numeroJoueur);
      s := 'White player changed to "^0" (#^1) in ^2 games';
      s := ParamStr(s,GetNomJoueur(numeroJoueur),NumEnString(numeroJoueur),NumEnString(nbPartiesAChanger),'');
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog(s);
    end;
    
  
  EnleveEspacesDeGaucheSurPlace(tournoi);
  if (tournoi <> '') & 
     (TournoiEstDonneParSonNumero(tournoi,numeroTournoi) | TrouveNumeroDuTournoi(tournoi,numeroTournoi,0)) &
     (numeroTournoi = GetNroTournoiDansSonFichier(numeroTournoi)) then
    begin
      ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,ChangeTournament,numeroTournoi);
      s := 'Tourney changed to "^0" (#^1) in ^2 games';
      s := ParamStr(s,GetNomTournoi(numeroTournoi),NumEnString(numeroTournoi),NumEnString(nbPartiesAChanger),'');
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog(s);
    end;
    
  CalculsEtAffichagePourBase(false,true);
  ChangeNumerosJoueursEtTournoisDansListe := NoErr;
end;


function ChangeAnneeDansListe(annee : SInt32;surQuellesParties:FiltreNumRefProc) : OSErr;
var nbPartiesAChanger,bidon : SInt32;
    s : str255;
begin
  if (GetNiemeCaractereDuRapport(GetTailleRapport()-1) <> cr) 
    then WritelnDansRapport('');
  
  nbPartiesAChanger := NumberOfGamesWithThisReferenceFilter(surQuellesParties,bidon);
  
  if (annee >= 1980) then
    begin
      ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,ChangeYear,annee);
      s := 'Year changed to "^0" in ^1 games';
      s := ParamStr(s,NumEnString(annee),NumEnString(nbPartiesAChanger),'','');
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog(s);
    end;
  
  CalculsEtAffichagePourBase(false,true);
  ChangeAnneeDansListe := NoErr;
end;


procedure CalculeScoreTheorique(var partie60 : PackedThorGame;numeroReferencePartie : SInt32; var scoreTheoriquePourNoir : SInt32);
var position : PositionEtTraitRec;
    typeErreur : SInt32;
    nbPartiesRestantes : SInt32;
    score : SInt32;
begin
  if (interruptionReflexion = pasdinterruption) then
    with gInfosCalculScoresTheoriques do
      begin
        numeroReferencePartieEnCours := numeroReferencePartie;
        position := PositionEtTraitAfterMoveNumber(partie60,apresQuelCoup,typeErreur);
        if (typeErreur = kPartieOK) 
          then
            begin
              {on essaye de calculer le score parfait}
              WritelnDansRapport(ConstruireChaineReferencesPartieParNroRefPartie(numeroReferencePartie,true,apresQuelCoup+1));
              WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
              
              score := DoEndgameSolve(position,kEndgameSolveToujoursRamenerLaSuite);
              
              if (interruptionReflexion = pasdinterruption) &
                 (score >= -64) & (score <= 64) then
                 begin
                   inc(nbPartiesCalculees);
                   
                   WritelnStringAndNumDansRapport('score = ',score);
                   
                   if GetTraitOfPosition(position) = pionNoir
                     then scoreTheoriquePourNoir := 32 + (score div 2)
                     else scoreTheoriquePourNoir := 32 - (score div 2);
                   
                   {on met le score theorique dans la liste}
                   if (scoreTheoriquePourNoir >= 0) & (scoreTheoriquePourNoir <= 64)
                     then SetScoreTheoriqueParNroRefPartie(numeroReferencePartie,scoreTheoriquePourNoir)
                     else WritelnStringAndNumDansRapport('ERREUR !! scoreTheoriquePourNoir = ',scoreTheoriquePourNoir);
                   
                   {affichage de quelques statistiques}
                   if (nbPartiesCalculees <> 0) then
                     begin
                       tempsMoyenParPartie := ((TickCount() - tickDepart + 30.0) / 60.0) / nbPartiesCalculees;
                       nbPartiesRestantes  := nbCalculsAFaire - (nbPartiesCalculees + nbPartiesImpossibles);
                       tempsRestantEstime  := tempsMoyenParPartie * nbPartiesRestantes;
                       WritelnDansRapport('temps moyen par partie ('+NumEnString(nbPartiesCalculees)+' parties) : '+SecondesEnJoursHeuresSecondes(MyTrunc(tempsMoyenParPartie)));
                       WritelnDansRapport('temps restant estimé pour les '+NumEnString(nbPartiesRestantes)+' dernières parties : '+SecondesEnJoursHeuresSecondes(MyTrunc(tempsRestantEstime)));
                     end;
                 end
                 else
                   begin
                     EcritTypeInterruptionDansRapport(interruptionReflexion);
                     WritelnStringAndNumDansRapport('score = ',score);
                   end;
               
               WritelnDansRapport('');
            end
          else
            begin
              inc(nbPartiesImpossibles);
            end;
      end;
end;


function CalculerScoresTheoriquesPartiesDansListe(apresQuelCoup : SInt32;surQuellesParties:FiltreNumRefProc) : OSErr;
var scoreTheoriquePourNoir : SInt32;
    bidon : SInt32;
begin

  gInfosCalculScoresTheoriques.apresQuelCoup                := apresQuelCoup;
  gInfosCalculScoresTheoriques.tickDepart                   := TickCount();
  gInfosCalculScoresTheoriques.nbCalculsAFaire              := NumberOfGamesWithThisReferenceFilter(surQuellesParties,bidon);
  gInfosCalculScoresTheoriques.nbPartiesCalculees           := 0;
  gInfosCalculScoresTheoriques.nbPartiesImpossibles         := 0;
  gInfosCalculScoresTheoriques.numeroReferencePartieEnCours := 0;
  gInfosCalculScoresTheoriques.tempsMoyenParPartie          := 0.0;
  gInfosCalculScoresTheoriques.tempsRestantEstime           := 0.0;

  if (interruptionReflexion = pasdinterruption) then
    with gInfosCalculScoresTheoriques do
      begin
        if (GetNiemeCaractereDuRapport(GetTailleRapport()-1) <> cr) 
          then WritelnDansRapport('');
    
        WritelnDansRapport('');
        ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,CalculeScoreTheorique,scoreTheoriquePourNoir);
        WritelnDansRapport('temps total de calcul des scores theoriques : '+SecondesEnJoursHeuresSecondes((TickCount() - tickDepart + 30) div 60));
        WritelnDansRapport('');
      end;
  
  if (interruptionReflexion = pasdinterruption)
    then CalculerScoresTheoriquesPartiesDansListe := NoErr
    else CalculerScoresTheoriquesPartiesDansListe := -20;
  
  if not(analyseRetrograde.enCours) & not(HumCtreHum) then DoChangeHumCtreHum;
end;


function ListerDerniersJoueursBaseOfficielleDansRapport(nbreJoueurs : SInt32) : OSErr;
var k,indexMax : SInt32;
begin
  indexMax := NombreJoueursDansBaseOfficielle();
  
  WriteInTraceWThorLog('');
  for k := indexMax downto indexMax - nbreJoueurs + 1 do
    WriteInTraceWThorLog(GetNomJoueur(k)+' (#'+NumEnString(k)+')');
    
  ListerDerniersJoueursBaseOfficielleDansRapport := NoErr;
end;


function ListerDerniersTournoisBaseOfficielleDansRapport(nbreTournois : SInt32) : OSErr;
var k,indexMax : SInt32;
begin
  indexMax := NombreTournoisDansBaseOfficielle();
  
  WriteInTraceWThorLog('');
  for k := indexMax downto indexMax - nbreTournois + 1 do
    WriteInTraceWThorLog(GetNomTournoi(k)+' (#'+NumEnString(k)+')');
  
  ListerDerniersTournoisBaseOfficielleDansRapport := NoErr;
end;

    
function DoActionGestionBaseOfficielle(commande : str255) : OSErr;
var oldParsingProtectionWithQuote : boolean;
    s1,s2,s3,s4,s5,s6,reste : str255;
    err : OSErr;
begin
  
  
  {WritelnDansRapport('commande dans DoActionGestionBaseOfficielle = '+commande);}
  
  if not(problemeMemoireBase) & not(JoueursEtTournoisEnMemoire) then
    err := MetJoueursEtTournoisEnMemoire(false);
  
  oldParsingProtectionWithQuote := GetParsingProtectionWithQuotes();
  SetParsingProtectionWithQuotes(true);
  
  Parser6(commande,s1,s2,s3,s4,s5,s6,reste);
  
  err := -10000;
  
  {add player "newname"}
  if (s1 = 'add') & (s2 = 'player') & (s3 <> '')
    then err := RenommerJoueurDansFichierWThorOfficiel('',s3);
  
  {create player "newname"}
  if (s1 = 'create') & (s2 = 'player') & (s3 <> '')
    then err := RenommerJoueurDansFichierWThorOfficiel('',s3);
  
  {rename player "oldname" to "newname"}
  if (s1 = 'rename') & (s2 = 'player') & (s3 <> '') & (s4 = 'to') & (s5 <> '')
    then err := RenommerJoueurDansFichierWThorOfficiel(s3,s5);
  
  {find player "name"}
  if (s1 = 'find') & (s2 = 'player') & (s3 <> '') 
    then err := FindPlayerDansBaseOfficielle(s3);
    
    
  
  {add tourney "newname"}
  if (s1 = 'add') & (s2 = 'tourney') & (s3 <> '')
    then err := RenommerTournoiDansFichierWThorOfficiel('',s3);
  
  {create tourney "newname"}
  if (s1 = 'create') & (s2 = 'tourney') & (s3 <> '')
    then err := RenommerTournoiDansFichierWThorOfficiel('',s3);
  
  {rename tourney "oldname" to "newname"}
  if (s1 = 'rename') & (s2 = 'tourney') & (s3 <> '') & (s4 = 'to') & (s5 <> '')
    then err := RenommerTournoiDansFichierWThorOfficiel(s3,s5);
   
  {find tourney "name"}
  if (s1 = 'find') & (s2 = 'tourney') & (s3 <> '')
    then err := FindTournamentDansBaseOfficielle(s3);
    
  
  {change black player to "newname"}
  if (s1 = 'change') & (s2 = 'black') & (s3 = 'player') & (s4 = 'to') & (s5 <> '')
    then err := ChangeNumerosJoueursEtTournoisDansListe(s5,'','',FiltrePartieEstActiveEtSelectionnee);
  
  {change white player to "newname"}
  if (s1 = 'change') & (s2 = 'white') & (s3 = 'player') & (s4 = 'to') & (s5 <> '')
    then err := ChangeNumerosJoueursEtTournoisDansListe('',s5,'',FiltrePartieEstActiveEtSelectionnee);
  
  {change tourney to "newname"}
  if (s1 = 'change') & (s2 = 'tourney') & (s3 = 'to') & (s4 <> '')
    then err := ChangeNumerosJoueursEtTournoisDansListe('','',s4,FiltrePartieEstActiveEtSelectionnee);
  
  {change year to "NNNN"}
  if (s1 = 'change') & (s2 = 'year') & (s3 = 'to') & (s4 <> '')
    then err := ChangeAnneeDansListe(ChaineEnLongint(s4),FiltrePartieEstActiveEtSelectionnee);
  
  
  {show last players}
  if (s1 = 'show') & (s2 = 'last') & (s3 = 'players')
    then err := ListerDerniersJoueursBaseOfficielleDansRapport(30);
  
  {show last tourneys}
  if (s1 = 'show') & (s2 = 'last') & (s3 = 'tourneys')
    then err := ListerDerniersTournoisBaseOfficielleDansRapport(30);
    
    
  {show all players}
  if (s1 = 'show') & (s2 = 'all') & (s3 = 'players')
    then err := ListerDerniersJoueursBaseOfficielleDansRapport(NombreJoueursDansBaseOfficielle());
  
  {show all tourneys}
  if (s1 = 'show') & (s2 = 'all') & (s3 = 'tourneys')
    then err := ListerDerniersTournoisBaseOfficielleDansRapport(NombreTournoisDansBaseOfficielle());
    
  
  {recalculate}
  if (s1 = 'recalculate')
    then err := CalculerScoresTheoriquesPartiesDansListe(36,FiltrePartieEstActiveEtSelectionnee);
  
  
  {wthor help, help, ?}
  if (s1 = '?') | (s1 = 'help') | ((s1 = 'wthor') & (s2 = 'help'))
    then 
      begin
        WritelnDansRapport('');
        WritelnDansRapport('Select or enter one of the following commands in the rapport :');
        WritelnDansRapport('   add player "newname"');
        WritelnDansRapport('   add tourney "newname"');
        WritelnDansRapport('   create player "newname"');
        WritelnDansRapport('   create tourney "newname"');
        WritelnDansRapport('   rename player "oldname" to "newname"');
        WritelnDansRapport('   rename tourney "oldname" to "newname"');
        WritelnDansRapport('   find player "name"');
        WritelnDansRapport('   find tourney "name"');
        WritelnDansRapport('   change black player to "newname"');
        WritelnDansRapport('   change white player to "newname"');
        WritelnDansRapport('   change tourney to "newname"');
        WritelnDansRapport('   change year to "NNNN"');
        WritelnDansRapport('   show last players');
        WritelnDansRapport('   show last tourneys');
        WritelnDansRapport('   show all players');
        WritelnDansRapport('   show all tourneys');
        WritelnDansRapport('   recalculate');
        WritelnDansRapport('   wthor help');
        WritelnDansRapport('   help');
        WritelnDansRapport('   ?');
        WritelnDansRapport('');
        err := NoErr;
      end;
  
  SetParsingProtectionWithQuotes(oldParsingProtectionWithQuote);
  
  DoActionGestionBaseOfficielle := err;
end;


procedure TransformerLigneRapportEnCommandeBaseOfficielle(var ligne : str255);
var myError : OSErr;
begin
  if (ligne <> '') then
    begin
      myError := DoActionGestionBaseOfficielle(ligne);
      
      if myError <> NoErr then
        begin
          myError := DoActionGestionBaseOfficielle('add player "' + ligne + '"');
        end;
    end;
end;


procedure CreerOuRenommerMachinDansLaBaseOfficielle;
var longueurSelection : SInt32;
    nbreLignesSelection : SInt32;
    myError : OSErr;
begin
  myError := -10000;
  
  nbreLignesSelection := NombreDeLignesDansSelectionRapport();
  
  if FenetreRapportEstOuverte() & 
           FenetreRapportEstAuPremierPlan() & 
           SelectionRapportNonVide() &
           (LongueurSelectionRapport() < 255) 
          then myError := DoActionGestionBaseOfficielle(SelectionRapportEnString(longueurSelection));
  
  if (myError = -10000) then 
    myError := DoActionGestionBaseOfficielle('wthor help');
    
end;


procedure CreerPlusieursJoueursDansBaseOfficielle;
begin
  ForEachLineSelectedInRapportDo(TransformerLigneRapportEnCommandeBaseOfficielle);
end;



END.



















































