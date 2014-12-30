UNIT UnitTestNouveauFormat;



INTERFACE







USES MacTypes;

procedure TestNouveauFormat;
procedure DebuguerNouveauFormat(fonctionAppelante : str255);
procedure EcritListeTournoisPourTraductionJaponais;
procedure EcritListeJoueursNoirsNonJaponaisPourTraduction;
procedure EcritListeJoueursBlancsNonJaponaisPourTraduction;

procedure AfficheFichierNouveauFormatDansRapport(numFic : SInt16);


IMPLEMENTATION







USES UnitAccesStructuresNouvFormat,UnitDefinitionsNouveauFormat,UnitNouveauFormat,UnitRapport,
     MyFileSystemUtils,UnitPrefs,UnitZoneMemoire,UnitServicesMemoire,MyMathUtils,
     UnitMacExtras,UnitScannerOthellistique,SNStrings,UnitPackedThorGame;
     

procedure AfficheFichierNouveauFormatDansRapport(numFic : SInt16);
var s1,s2 : str255;
begin
  
  with InfosFichiersNouveauFormat.fichiers[numFic] do
    begin
      WritelnStringandnumdansrapport('fichier nouveau format #',numFic);
      
      s1 := calculePathFichierNouveauFormat(numFic);
      s2 := calculeNomFichierNouveauFormat(numFic);
      
      WritelnDansRapport('path du fichier =   '+s1);
      WritelnDansRapport('nom du fichier  =   '+s2);
      
      with InfosFichiersNouveauFormat.fichiers[numFic].entete do
		    begin
				  WritelnStringAndNumDansRapport('entete.siecleCreation = ',siecleCreation);
				  WritelnStringAndNumDansRapport('entete.annneCreation = ',anneeCreation);
				  WritelnStringAndNumDansRapport('entete.MoisCreation = ',MoisCreation);
				  WritelnStringAndNumDansRapport('entete.JourCreation = ',JourCreation);
				  WritelnStringAndNumDansRapport('entete.NombreEnregistrementsParties (N1) =',NombreEnregistrementsParties);
				  WritelnStringAndNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs (N2) =',NombreEnregistrementsTournoisEtJoueurs);
				  WritelnStringAndNumDansRapport('entete.AnneeParties = ',AnneeParties);
				  WritelnStringAndNumDansRapport('entete.TailleDuPlateau = ',TailleDuPlateau);
				  WritelnStringAndNumDansRapport('entete.EstUnFichierSolitaire = ',EstUnFichierSolitaire);
				  WritelnStringAndNumDansRapport('entete.ProfondeurCalculTheorique = ',ProfondeurCalculTheorique);
				  WritelnStringAndNumDansRapport('entete.reservedByte = ',reservedByte);
		    end;
	   if open 
        then WritelnDansRapport('open = true')
        else WritelnDansRapport('open = false');
      WritelnStringandnumdansrapport('refNum = ',refNum);
      WritelnStringandnumdansrapport('vRefNum = ',vRefNum);
      WritelnStringandnumdansrapport('parID = ',parID);
      WritelnStringandnumdansrapport('NroFichierDual = ',NroFichierDual);
      WritelnStringandnumdansrapport('annee = ',annee);
      WritelnStringandnumdansrapport('NroDistribution = ',NroDistribution);
      
      
      
      
      case typeDonnees of
        kUnknownDataNouveauFormat      : WritelnDansRapport('format inconnu !   '+CalculeNomFichierNouveauFormat(numFic));
        kFicJoueursNouveauFormat       : WritelnDansRapport('fichier de joueurs   '+CalculeNomFichierNouveauFormat(numFic));
        kFicTournoisNouveauFormat      : WritelnDansRapport('fichier de tournois   '+CalculeNomFichierNouveauFormat(numFic));
        kFicIndexJoueursNouveauFormat  : WritelnDansRapport('fichier de numeros (d''index) de joueurs   '+CalculeNomFichierNouveauFormat(numFic));
        kFicIndexTournoisNouveauFormat : WritelnDansRapport('fichier de numeros (d''index) de tournois   '+CalculeNomFichierNouveauFormat(numFic));
        kFicPartiesNouveauFormat       : WritelnDansRapport('fichier de parties   '+CalculeNomFichierNouveauFormat(numFic));
        kFicIndexPartiesNouveauFormat  : WritelnDansRapport('fichier d''index de parties  '+CalculeNomFichierNouveauFormat(numFic));
        kFicTournoisCourtsNouveauFormat: WritelnDansRapport('fichier de tournois (noms courts)   '+CalculeNomFichierNouveauFormat(numFic));
        kFicJoueursCourtsNouveauFormat : WritelnDansRapport('fichier de joueurs (noms courts)    '+CalculeNomFichierNouveauFormat(numFic));
        kFicSolitairesNouveauFormat    : WritelnDansRapport('fichier de solitaires    '+CalculeNomFichierNouveauFormat(numFic));
      end;
      WritelnDansRapport('');
    end;
end;






procedure AfficheQuelquesParties;
var numPartie : SInt32;
    numFichier : SInt16; 
    theGame:t_PartieRecNouveauFormat;
    err : OSErr;
    s60 : PackedThorGame; 
    s255 : str255;
begin
  
  numFichier := 1;
  with InfosFichiersNouveauFormat do
    repeat
      if (numFichier <= nbFichiers) & 
         (fichiers[numFichier].typeDonnees=kFicPartiesNouveauFormat) then
        begin
          WritelnStringAndNumDansrapport('ficher numŽro : ',numFichier);
          err := OuvreFichierNouveauFormat(numFichier);
          for numPartie := Min(1,fichiers[numFichier].entete.NombreEnregistrementsParties) downto 1 do
            begin
              err := LitPartieNouveauFormat(numFichier,numPartie,false,theGame);
              if ((numPartie-1) mod 53) = 0 then
                begin
                  SET_LENGTH_OF_PACKED_GAME(s60, 60);
                  MoveMemory(@theGame.listeCoups[1], GET_ADRESS_OF_FIRST_MOVE(s60),60);
                  TraductionThorEnAlphanumerique(s60,s255);
                  WritelnDansRapport(s255);
                end;
            end;
          err := FermeFichierNouveauFormat(numFichier);
        end;
      numFichier := succ(numFichier);
    until (numFichier>nbFichiers) | EscapeDansQueue();
end;



procedure LitTousLesIndexALaSuiteNouveauFormat;
var err : OSErr;
    k : SInt16; 
    tick,ticktotal : SInt32;
begin
  {$unused tick}
  WritelnDansRapport('');
  ticktotal := TickCount();
  
  with InfosFichiersNouveauFormat do
    for k := 1 to nbFichiers do
      if fichiers[k].typeDonnees=kFicIndexPartiesNouveauFormat then
        begin
          {WritelnStringAndNumDansrapport('lecture du ficher index numŽro : ',k);
          tick := TickCount();}
          err := LitFichierIndexNouveauFormat(k);
          {WriteStringAndNumDansRapport('err=',err);
          WritelnStringAndnumDansRapport('    temps=',TickCount()-tick);}
        end;
  
  WritelnDansRapport('temps total lecture des index de toute la base = '+NumEnString(TickCount()-ticktotal)+' soixantiemes de seconde');
  WritelnDansRapport('');
  
end;

procedure EcritListeTournoisPourTraductionJaponais;
var err : OSErr;
    fic : ZoneMemoire;
    i : SInt32;
    s : str255;
begin
  with TournoisNouveauFormat do
    if nbTournoisNouveauFormat>0 then
      begin
			  fic := MakeZoneMemoireFichier('liste pour Abe',0);
			  if ZoneMemoireEstCorrecte(fic) then
			    begin
			      err := ViderZoneMemoire(fic);
			  
    			  for i := 0 to nbTournoisNouveauFormat-1 do
    			    begin
    			      s := GetNomTournoi(i);
    			      err := WritelnDansZoneMemoire(fic,s+' = ');
    			    end;
    			  
    			  DisposeZoneMemoire(fic);
    			end;
			end;
end;

procedure EcritListeJoueursNoirsNonJaponaisPourTraduction;
var err : OSErr;
    fic : ZoneMemoire;
    i,nroPartie : SInt32;
    nroJoueurNoir,nroJoueurNoirPrecedant : SInt32;
    s : str255;
begin
  if (nbPartiesActives > 0) then
    begin
      fic := MakeZoneMemoireFichier('myUnknowBlackPlayers.jap',0);
      
      if not(ZoneMemoireEstCorrecte(fic)) 
        then exit(EcritListeJoueursNoirsNonJaponaisPourTraduction);
        
      err := ViderZoneMemoire(fic);
    
      nroJoueurNoirPrecedant := -1000;  {ou n'importe quelle valeur abherante}
      for i := 1 to nbPartiesActives do
		    begin
		      nroPartie := tableNumeroReference^^[i];
		      nroJoueurNoir := GetNroJoueurNoirParNroRefPartie(nroPartie);
		      
		      if not(JoueurAUnNomJaponais(nroJoueurNoir)) & 
		         ((i=1) | (nroJoueurNoir<>nroJoueurNoirPrecedant)) then
		        begin
					    s := GetNomJoueur(nroJoueurNoir);
					    err := WritelnDansZoneMemoire(fic,s+' = ');
					  end;
					  
					nroJoueurNoirPrecedant := nroJoueurNoir;
			  end;
		  DisposeZoneMemoire(fic);
		end;
end;

procedure EcritListeJoueursBlancsNonJaponaisPourTraduction;
var err : OSErr;
    fic : ZoneMemoire;
    i,nroPartie : SInt32;
    nroJoueurBlanc,nroJoueurBlancPrecedant : SInt32;
    s : str255;
begin
  if nbPartiesActives>0 then
    begin
      fic := MakeZoneMemoireFichier('myUnknowWhitePlayers.jap',0);
      
      if not(ZoneMemoireEstCorrecte(fic)) 
        then exit(EcritListeJoueursBlancsNonJaponaisPourTraduction);
      
      err := ViderZoneMemoire(fic);

      nroJoueurBlancPrecedant := -1000;  {ou n'importe quelle valeur abherante}
      for i := 1 to nbPartiesActives do
		    begin
		      nroPartie := tableNumeroReference^^[i];
		      nroJoueurBlanc := GetNroJoueurBlancParNroRefPartie(nroPartie);
		      
		      if not(JoueurAUnNomJaponais(nroJoueurBlanc)) & 
		         ((i=1) | (nroJoueurBlanc<>nroJoueurBlancPrecedant)) then
		        begin
					    s := GetNomJoueur(nroJoueurBlanc);
					    err := WritelnDansZoneMemoire(fic,s+' = ');
					  end;
					  
					nroJoueurBlancPrecedant := nroJoueurBlanc;
					end;
		  DisposeZoneMemoire(fic);
		end;
end;


procedure DebuguerNouveauFormat(fonctionAppelante : str255);
var k,somme : SInt32;
begin
  somme := 0;
  with InfosFichiersNouveauFormat do
    begin
      k := 2;
      
      somme := somme + fichiers[k].entete.NombreEnregistrementsParties;
      
      {WritelnStringAndNumDansRapport('fichier '+NumEnString(k)+' = ',fichiers[k].entete.NombreEnregistrementsParties);}
    end;
  WritelnStringAndNumDansRapport('sizeof(FichierNouveauFormatRec) = ',sizeof(FichierNouveauFormatRec));
  WritelnStringAndNumDansRapport('sizeof(InfosFichiersNouveauFormat) = ',sizeof(InfosFichiersNouveauFormat));
  WritelnStringAndNumDansRapport('fonction appelante = '+fonctionAppelante+' => somme = ',somme); 
end;


procedure TestNouveauFormat;
var k{,numeroAlpha} : SInt32;
    {err : OSErr;
    s : str255;}
begin
  
  
  SetEcritToutDansRapportLog(true);
  SetAutoVidageDuRapport(true);


  {
  WritelnStringandNumDansRapport('sizeof(EnTeteNouveauFormat)=',sizeof(EnTeteNouveauFormat));
  WritelnStringandNumDansRapport('sizeof(t_JoueurRecNouveauFormat)=',sizeof(t_JoueurRecNouveauFormat));
  WritelnStringandNumDansRapport('sizeof(t_TournoiRecNouveauFormat)=',sizeof(t_TournoiRecNouveauFormat));
  WritelnStringandNumDansRapport('sizeof(t_PartieRecNouveauFormat)=',sizeof(t_PartieRecNouveauFormat));
  WritelnDansRapport('');
  }
  
  
  LecturePreparatoireDossierDatabase(volumeRefCassio);
  
  
  
  
  WritelnDansRapport('');
  WritelnStringAndNumDansRapport('nb distributions du nouveau format=',DistributionsNouveauFormat.nbDistributions);
  for k := 1 to DistributionsNouveauFormat.nbDistributions do
    begin
      WritelnDansRapport('path = '+DistributionsNouveauFormat.Distribution[k].path^);
      WriteDansRapport('nom = '+DistributionsNouveauFormat.Distribution[k].name^);
      WriteDansRapport('nomUsuel = '+DistributionsNouveauFormat.Distribution[k].nomUsuel^);
      WritelnDansRapport('    =>    '+NumEnString(NbTotalPartiesDansDistributionSet([k]))+' parties');
    end;
  WritelnDansRapport('');
  
  
  {
  if OpenPrefsFileForSequentialReading() = 0 then
    begin
      while not(EOFInPrefsFile()) do
        begin
          err := GetNextLineInPrefsFile(s);
          if err <> 0
            then WritelnStringandnumdansrapport('erreur fichier = ',err)
            else WritelnDansRapport(s);
        end;
      err := ClosePrefsFile();
    end;
  }
  
  
  
  WritelnDansRapport('');
  WritelnStringAndNumDansRapport('nb fichiers=',InfosFichiersNouveauFormat.nbFichiers);
  for k := 1 to InfosFichiersNouveauFormat.nbFichiers do
    AfficheFichierNouveauFormatDansRapport(k);  
  
  
  AfficheQuelquesParties;
  
  {WritelnStringAndNumDansrapport('nb joueurs en memoire =',JoueursNouveauFormat.nbJoueursNouveauFormat);
   WritelnStringAndNumDansrapport('nb tournois en memoire =',tournoisNouveauFormat.nbTournoisNouveauFormat);  
  }
  
  (*
  IndexerLesFichiersNouveauFormat;
  LitTousLesIndexALaSuiteNouveauFormat;
  *)
  
  {
  err := MetJoueursNouveauFormatEnMemoire(false);
  TrierAlphabetiquementJoueursNouveauFormat;
  for k := 0 to 20 do
    begin
      WritelnDansRapport('joueur #'+NumEnString(k)+ ' = '+GetNomJoueur(k));
      numeroAlpha := JoueursNouveauFormat.ListeJoueurs^[k].numeroDansOrdreAlphabetique;
      WritelnDansRapport('  num dans ordre alphabetique = '+NumEnString(numeroAlpha));
      WritelnDansRapport('  nom = '+GetNomJoueur(numeroAlpha));
    end;
  }
  {
  err := MetJoueursNouveauFormatEnMemoire(false);
  TrierAlphabetiquementJoueursNouveauFormat;
  }
  
  {
  err := MetTournoisNouveauFormatEnMemoire(false);
  TrierAlphabetiquementTournoisNouveauFormat;
  }
 
  {
  for k := 0 to 20 do
    begin
      WritelnDansRapport('tournoi #'+NumEnString(k)+ ' = '+GetNomTournoi(k));
      numeroAlpha := TournoisNouveauFormat.ListeTournois^[k].numeroDansOrdreAlphabetique;
      WritelnDansRapport('  num dans ordre alphabetique = '+NumEnString(numeroAlpha));
      WritelnDansRapport('  nom = '+GetNomTournoi(numeroAlpha));
    end;
  }
  
  {SetDebuggageUnitFichiersTexte(true);}
  {err := myLitNomsDesJoueursEnJaponais();}
  {SetDebuggageUnitFichiersTexte(false);}
  
  SetEcritToutDansRapportLog(false);
  SetAutoVidageDuRapport(false);
  
end;

end.