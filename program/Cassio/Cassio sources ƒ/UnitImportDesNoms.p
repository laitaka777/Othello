UNIT UnitImportDesNoms;


INTERFACE


USES MacTypes,UnitStringSet;

var gImportDesNoms :
      record
        pseudosInconnus            : StringSet;
        pseudosNomsDejaVus         : StringSet;
        pseudosTournoisDejaVus     : StringSet;
        pseudosAyantUnNomReel      : StringSet;
        nomsReelsARajouterDansBase : StringSet;
      end;

{Initialisation et liberation de l'unité}
procedure InitUnitImportDesNoms;
procedure LibereMemoireImportDesNoms;

{imports des noms}
function PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos,pseudoPGN : str255) : str255;
function PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudo : str255; var nomDansThor : str255; var numeroDansThor : SInt32) : boolean;
function PeutImporterNomTournoiFormatPGN(nomDictionnaireDesPseudos,pseudo : str255; var nomDansThor : str255; var numeroDansThor : SInt32) : boolean;
function TrouverNomsDesJoueursDansNomDeFichier(s : str255; var numeroJoueur1,numeroJoueur2 : SInt32;longueurMinimaleUnPseudo : SInt32; var qualiteSolution : extended) : boolean;
function TrouverNomDeTournoiDansPath(path : str255; var numeroTournoi,annee : SInt32;nomDictionnaireDesPseudos : str255) : boolean;

{gestion des erreurs}
procedure AjoutePseudoInconnu(const message_erreur,pseudo,nom : str255);
procedure AnnonceNomAAjouterDansThor(const pseudo,nom : str255);



IMPLEMENTATION

USES MyStrings,UnitFichiersTEXT,UnitOth2,UnitAccesStructuresNouvFormat,UnitMiniProfiler,SNStrings,UnitRapport,UnitBaseNouveauFormat;


function PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos,pseudoPGN : str255) : str255;
var ligne,s,s1,s2,reste : str255;
    dictionnairePseudosPGN : FichierTEXT;
    doitMettreAJourLesPseudosAyantUnNomReel : boolean;
    pseudoAvecUnNomReel : str255;
    nom_dictionnaire : str255;
    erreurES : OSErr;
    trouve : boolean;
    t,numero,posEgal : SInt32;
begin
  PseudoPGNEnNomDansBaseThor := '???';
  
  
  (* on normalise le pseudo cherché en enlevant 
     les chiffres terminaux, parce que sur Internet
     les gens rajoutent souvent des chiffres à leur 
     pseudo                  
   *)
  t := Length(pseudoPGN);
  while (t > 1) & IsDigit(pseudoPGN[t]) do dec(t);
  pseudoPGN[0] := chr(t);
  pseudoPGN[1] := LowerCase(pseudoPGN[1]);
  
  
  doitMettreAJourLesPseudosAyantUnNomReel := StringSetEstVide(gImportDesNoms.pseudosAyantUnNomReel);
  if not(doitMettreAJourLesPseudosAyantUnNomReel) then
    begin
      if not(MemberOfStringSet(pseudoPGN,numero,gImportDesNoms.pseudosAyantUnNomReel))
        then exit(PseudoPGNEnNomDansBaseThor);
    end;
      
  if (nomDictionnaireDesPseudos <> '') then
    begin
      nom_dictionnaire := nomDictionnaireDesPseudos;
      
      erreurES := FichierTexteDeCassioExiste(nom_dictionnaire,dictionnairePseudosPGN);
      if erreurES<>NoErr then 
        begin
          AlerteSimpleFichierTexte(nom_dictionnaire,erreurES);
          exit(PseudoPGNEnNomDansBaseThor);
        end;
      
      erreurES := OuvreFichierTexte(dictionnairePseudosPGN);
      if erreurES<>NoErr then 
        begin
          AlerteSimpleFichierTexte(nom_dictionnaire,erreurES);
          exit(PseudoPGNEnNomDansBaseThor);
        end;
        
      erreurES := NoErr;
      ligne := '';
      trouve := false;
      
      while not(EOFFichierTexte(dictionnairePseudosPGN,erreurES)) & not(trouve) do
        begin
          erreurES := ReadlnDansFichierTexte(dictionnairePseudosPGN,s);
          ligne := s;
          EnleveEspacesDeGaucheSurPlace(ligne);
          if (ligne='') | (ligne[1]='%') 
            then
              begin
                {erreurES := WritelnDansFichierTexte(outputBaseThor,s);}
              end
            else
              begin
                posEgal := Pos('=',ligne);
                if (posEgal > 0)
                  then
                    begin
                      s1 := LeftOfString(ligne,posEgal-1);
                      EnleveEspacesDeDroiteSurPlace(s1);
                      Parser(RightOfString(ligne, 1 + Length(ligne) - posEgal),s2,reste);
                    end
                  else
                    begin
                      s2 := '';
                    end;
                
                {WritelnDansRapport('reste = '+reste);}
                if (s2 = '=') then
                  begin
                    s1[1] := LowerCase(s1[1]);
                    
                    if doitMettreAJourLesPseudosAyantUnNomReel & (s1 <> '') & (reste <> '') then
                      begin
                        pseudoAvecUnNomReel := s1;
                        t := Length(pseudoAvecUnNomReel);
                        while (t > 1) & IsDigit(pseudoAvecUnNomReel[t]) do dec(t);
                        pseudoAvecUnNomReel[0] := chr(t);
                        
                        AddStringToSet(pseudoAvecUnNomReel,-1,gImportDesNoms.pseudosAyantUnNomReel);
                        {WritelnDansRapport(pseudoAvecUnNomReel + ' => ' + reste);}
                      end;
                    
                    if (Pos(pseudoPGN,s1) = 1) then   {was :  if (Pos(pseudoPGN,s1) > 0) then ... }
                      begin
                        EnleveEspacesDeGaucheSurPlace(reste);
                        EnleveEspacesDeDroiteSurPlace(reste);
                        if (reste <> '')
                          then PseudoPGNEnNomDansBaseThor := reste;
                        trouve := true;
                      end;
                  end;
              end;
        end;
      erreurES := FermeFichierTexte(dictionnairePseudosPGN);
      
      (* si on a trouve le pseudo, la liste des pseudos ayant un
         nom reel est incomplete car on a shinté la fin du fichier :
         on préfere donc l'effacer  *)
      if doitMettreAJourLesPseudosAyantUnNomReel & trouve
        then DisposeStringSet(gImportDesNoms.pseudosAyantUnNomReel);
  
  end;
  
end;



procedure AjoutePseudoInconnu(const message_erreur,pseudo,nom : str255);
  var aux,i : SInt32;
  begin
    if not(MemberOfStringSet(pseudo,aux,gImportDesNoms.pseudosInconnus)) then
      begin
        
        if (nom = '???') | (nom = '') then
          begin
            WriteDansRapport(message_erreur + pseudo);
            for i := 1 to (16 - Length(pseudo)) do
              WriteDansRapport(' ');
            WritelnDansRapport(' = ');
          end;
        
        AddStringToSet(pseudo,kNroJoueurInconnu,gImportDesNoms.pseudosInconnus);
      end;
  end;
    

procedure AnnonceNomAAjouterDansThor(const pseudo,nom : str255);
  var aux : SInt32;
  begin
    if (nom <> '???') & (nom <> '') & 
       not(MemberOfStringSet(nom,aux,gImportDesNoms.nomsReelsARajouterDansBase)) then
      begin
        WritelnDansRapport('nom à rajouter dans Wthor : '+ nom + '  (' + pseudo +')');
        AddStringToSet(nom,kNroJoueurInconnu,gImportDesNoms.nomsReelsARajouterDansBase);
      end;
  end;


function PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudo : str255; var nomDansThor : str255; var numeroDansThor : SInt32) : boolean;
var numeroDirect : SInt32;
    pseudoArrivee : str255;
begin
  
  PeutImporterNomJoueurFormatPGN := false;
  nomDansThor := '';
  
  if not(MemberOfStringSet(pseudo,numeroDansThor,gImportDesNoms.pseudosNomsDejaVus)) then
    begin
      
      pseudoArrivee := pseudo;
      
      nomDansThor := PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos,pseudo);
      
      if not(TrouveNumeroDuJoueurDansBaseThor(LeftOfString(nomDansThor,LongueurPlusLongNomDeJoueurDansBase()),numeroDansThor)) then
        begin
          numeroDansThor := kNroJoueurInconnu;
          AnnonceNomAAjouterDansThor(pseudo,nomDansThor);
        end;
      
      { à tout hasard, on essaie de voir si le pseudo ne serait pas 
        directement un nom de joueur dans la base WThor :-)        }
      if (numeroDansThor = kNroJoueurInconnu) & TrouveNumeroDuJoueurDansBaseThor(pseudo,numeroDirect)
        then 
          begin
            numeroDansThor := numeroDirect;
            nomDansThor := GetNomJoueur(numeroDirect);
          end;
      
      AddStringToSet(pseudoArrivee,numeroDansThor,gImportDesNoms.pseudosNomsDejaVus);
      
    end;
  
  if (nomDansThor = '') & (numeroDansThor <> kNroJoueurInconnu) then
    nomDansThor := GetNomJoueur(numeroDansThor);
    
  PeutImporterNomJoueurFormatPGN := (numeroDansThor <> kNroJoueurInconnu);
end;


function PeutImporterNomTournoiFormatPGN(nomDictionnaireDesPseudos,pseudo : str255; var nomDansThor : str255; var numeroDansThor : SInt32) : boolean;
var numeroDirect : SInt32;
begin
  PeutImporterNomTournoiFormatPGN := false;
  nomDansThor := ''; 
  
  if not(MemberOfStringSet(pseudo,numeroDansThor,gImportDesNoms.pseudosTournoisDejaVus)) then
    begin
      nomDansThor := PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos,pseudo);
      
      if not(TrouveNumeroDuTournoi(nomDansThor,numeroDansThor,0)) then
        begin
          numeroDansThor := kNroTournoiDiversesParties;
          AnnonceNomAAjouterDansThor(pseudo,nomDansThor);
        end;
      
      { à tout hasard, on essaie de voir si le pseudo ne serait pas 
        directement un nom de tournoi dans la base WThor :-)       }
      if (numeroDansThor = kNroTournoiDiversesParties) & TrouveNumeroDuTournoi(pseudo,numeroDirect,0) 
        then
          begin
            numeroDansThor := numeroDirect;
            nomDansThor := GetNomTournoi(numeroDirect);
          end;
      
      AddStringToSet(pseudo,numeroDansThor,gImportDesNoms.pseudosTournoisDejaVus);
    end;
  
  PeutImporterNomTournoiFormatPGN := (numeroDansThor <> kNroTournoiDiversesParties);
end;


function TrouverNomDeTournoiDansPath(path : str255; var numeroTournoi,annee : SInt32;nomDictionnaireDesPseudos : str255) : boolean;
var oldParsingSet : SetOfChar;
    s,reste : str255;
    numero,essaiAnnee : SInt32;
    nomDansThor : str255;
    currentDate : DateTimeRec;
begin
  TrouverNomDeTournoiDansPath := false;
  
  GetTime(currentDate);
  for essaiAnnee := 1980 to currentDate.year+2 do
    begin
      s := NumEnString(essaiAnnee);
      if Pos(s,path) > 0 then
        annee := essaiAnnee;
    end;
  
  oldParsingSet := GetParsingCaracterSet();
	SetParsingCaracterSet([':','0','1','2','3','4','5','6','7','8','9']);
	
	reste := path;
	while (reste <> '') do
	  begin
	    Parser(reste,s,reste);
	    EnleveEspacesDeGaucheSurPlace(s);
	    EnleveEspacesDeDroiteSurPlace(s);
	    if PeutImporterNomTournoiFormatPGN(nomDictionnaireDesPseudos,s,nomDansThor,numero) then
	      begin
	        numeroTournoi := numero;
	        TrouverNomDeTournoiDansPath := true;
	        SetParsingCaracterSet(oldParsingSet);
	        exit(TrouverNomDeTournoiDansPath);
	      end;
	  end;
	
	SetParsingCaracterSet(oldParsingSet);
end;


function TrouverNomsDesJoueursDansNomDeFichier(s : str255; var numeroJoueur1,numeroJoueur2 : SInt32;longueurMinimaleUnPseudo : SInt32; var qualiteSolution : extended) : boolean;
const kNbMaxChaines = 30;
      kSegmentNonCherche = -2;
      nomDictionnaireDesPseudos = 'name_mapping_VOG_to_WThor.txt';
var nbJoueursTrouves : SInt32;
    nbSousChaines : SInt32;
    chunkNumber : SInt32;
    longueurBestSolution : SInt32;
    longueurTotale : SInt32;
    oldQuoteProtection : boolean;
    oldParsingSet : SetOfChar;
    chaines : array[1..kNbMaxChaines] of str255;
    chunk : array[1..kNbMaxChaines] of SInt32;
    reste,separateurs : str255;
    partieDigeree,partieNonDigeree : str255;
    positionUtile : SInt32;
    nomNoir,nomBlanc : str255;
    numeroNoir,numeroBlanc : SInt32;
    termine,bidon : boolean;
    memoisation : array[0..kNbMaxChaines,0..kNbMaxChaines] of SInt32;
    theParsingCaracters : SetOfChar;
    confiance : extended;
    numeroNoirBestSolution : SInt32;
    numeroBlancBestSolution : SInt32;
    
  
  procedure PublishSolution(pseudoNoir,pseudoBlanc : str255);
  var longueurDeCetteSolution : SInt32;
  begin
    longueurDeCetteSolution := Length(pseudoNoir) + Length(pseudoBlanc);
    
    {WritelnDansRapport(pseudoNoir+ ' , ' + pseudoBlanc);}
    
    if (longueurDeCetteSolution > longueurBestSolution) then
      begin
        numeroNoirBestSolution  := numeroNoir;
        numeroBlancBestSolution := numeroBlanc;
        longueurBestSolution    := longueurDeCetteSolution;
      end;
  end;
  
  function PeutTrouverNomDeJoueurDansWThor(var pseudo : str255; var numero : SInt32) : boolean;
  var nom : str255;
  begin
    EnleveEspacesDeGaucheSurPlace(pseudo);
	  EnleveEspacesDeDroiteSurPlace(pseudo);
	  if (pseudo = '')
	    then PeutTrouverNomDeJoueurDansWThor := false
	    else PeutTrouverNomDeJoueurDansWThor := PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudo,nom,numero)
  end;
  
  
  function PeutTrouverDeuxNomsDeJoueursDansWThor(pseudoNoir,pseudoBlanc : str255) : boolean;
  var ok : boolean;
  begin
    EnleveEspacesDeGaucheSurPlace(pseudoNoir);
	  EnleveEspacesDeDroiteSurPlace(pseudoNoir);
	  EnleveEspacesDeGaucheSurPlace(pseudoBlanc);
	  EnleveEspacesDeDroiteSurPlace(pseudoBlanc);
	  
	  if (pseudoNoir = '') | (pseudoBlanc = '')
	    then PeutTrouverDeuxNomsDeJoueursDansWThor := false
	    else 
	      begin
	        ok := (Length(pseudoNoir) + Length(pseudoBlanc) > longueurBestSolution) &
	              PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudoNoir,nomNoir,numeroNoir) &
	              PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudoBlanc,nomBlanc,numeroBlanc);
	              
	        if ok then PublishSolution(pseudoNoir,pseudoBlanc);
	        
	        PeutTrouverDeuxNomsDeJoueursDansWThor := ok;
	      end;
  end;
    
  
  function MakePseudo(imin,imax : SInt32;coupurePrenoms : SInt16) : str255;
    var result : str255;
        t : SInt32;
    begin
      result := '';
      
      for t := imin + coupurePrenoms to imax do 
        result := result + chaines[t] + ' ';
      for t := imin to imin + coupurePrenoms - 1 do
        result := result + chaines[t] + ' ';
        
      MakePseudo := result;
    end;
    
    
  function CherchePseudoEtNumeroJoueurDansMorceau(imin,imax : SInt32; var numero : SInt32) : str255;
  var permutation : str255;
      coupurePrenom : SInt32;
      chunkCherche,n : SInt32;
  begin
  
  
    { On teste si toutes les chaines du morceau ont le meme degre de chunk.
      Si ce n'est pas le cas, on refuse de chercher }
    chunkCherche := chunk[imin];
    for n := imin+1 to imax do
      if chunk[n] <> chunkCherche then
        begin
          CherchePseudoEtNumeroJoueurDansMorceau := '';
          exit(CherchePseudoEtNumeroJoueurDansMorceau);
        end;
    
    
    { On teste si toutes les chaines entre imin et imax ont une 
      longueur de 1, ou si le morceau est trop court : dans ce cas, 
      on choisit de ne meme pas chercher }
    permutation := MakePseudo(imin,imax,0);
    if (Length(permutation) <= 2*(imax - imin + 1)) |
       (Length(permutation) < longueurMinimaleUnPseudo) then
      begin
        CherchePseudoEtNumeroJoueurDansMorceau := '';
        exit(CherchePseudoEtNumeroJoueurDansMorceau);
      end;
      
      
    { Maintenant on peut chercher }
    if (imax >= imin) & (numero <> kNroJoueurInconnu) then
      for coupurePrenom := 0 to (imax - imin) do
        begin
          permutation := MakePseudo(imin,imax,coupurePrenom);
          
          if (Length(permutation) > LongueurPlusLongNomDeJoueurDansBase())
            then permutation := LeftOfString(permutation,LongueurPlusLongNomDeJoueurDansBase());
          
          if PeutTrouverNomDeJoueurDansWThor(permutation,numero) then
            begin
              CherchePseudoEtNumeroJoueurDansMorceau := permutation;
              exit(CherchePseudoEtNumeroJoueurDansMorceau);
            end;
        end;
          
    CherchePseudoEtNumeroJoueurDansMorceau := '';
  end;
  
  
    
  procedure SplitTableByThree(i,j,k : SInt32);
  var nom1,nom2,nom3 : str255;
      numero1,numero2,numero3 : SInt32;
      imin1,imin2,imin3 : SInt32;
      imax1,imax2,imax3 : SInt32;
      nbMorceauxImpossibles : SInt32;
  begin
  
    imin1 := i;
    imax1 := j-1;
    imin2 := j;
    imax2 := k-1;
    imin3 := k;
    imax3 := nbSousChaines;
    
    numero1 := memoisation[imin1,imax1];
    numero2 := memoisation[imin2,imax2];
    numero3 := memoisation[imin3,imax3];
    
    nbMorceauxImpossibles := 0;
    if (numero1 = kNroJoueurInconnu) then inc(nbMorceauxImpossibles);
    if (numero2 = kNroJoueurInconnu) then inc(nbMorceauxImpossibles);
    if (numero3 = kNroJoueurInconnu) then inc(nbMorceauxImpossibles);
    if (nbMorceauxImpossibles >= 2) then 
      exit(SplitTableByThree);
  
    nom1 := CherchePseudoEtNumeroJoueurDansMorceau(imin1,imax1,numero1);
    nom2 := CherchePseudoEtNumeroJoueurDansMorceau(imin2,imax2,numero2);
    nom3 := CherchePseudoEtNumeroJoueurDansMorceau(imin3,imax3,numero3);
    
    memoisation[imin1,imax1] := numero1;
    memoisation[imin2,imax2] := numero2;
    memoisation[imin3,imax3] := numero3;
    
    {
    WritelnStringAndNumDansRapport('Memoisation['+NumEnString(imin1)+','+NumEnString(imax1)+'] = ',memoisation[imin1,imax1]);
    WritelnStringAndNumDansRapport('Memoisation['+NumEnString(imin2)+','+NumEnString(imax2)+'] = ',memoisation[imin2,imax2]);
    WritelnStringAndNumDansRapport('Memoisation['+NumEnString(imin3)+','+NumEnString(imax3)+'] = ',memoisation[imin3,imax3]);
    }
    

	  if (numero1 > 0) & (numero2 > 0) then bidon := PeutTrouverDeuxNomsDeJoueursDansWThor(nom1,nom2);
	  if (numero2 > 0) & (numero3 > 0) then bidon := PeutTrouverDeuxNomsDeJoueursDansWThor(nom2,nom3);
	  if (numero1 > 0) & (numero3 > 0) then bidon := PeutTrouverDeuxNomsDeJoueursDansWThor(nom1,nom3);
	  
	  {WritelnDansRapport('');}
	  {Attendfrappeclavier;}
	  
  end;
  
  
  function TrouverNomsAvecCeParsingSet(parsingCaracters : SetOfChar; var confiance : extended) : boolean;
  var i,j,k : SInt32;
  begin  

    TrouverNomsAvecCeParsingSet := false;
    confiance := 0.0;
    
    if (s <> '') then
      begin
      
        if not(JoueursEtTournoisEnMemoire) then
          begin
            WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
            WritelnDansRapport('');
            DoLectureJoueursEtTournoi(false);
          end;
        
        nbJoueursTrouves := 0;
        confiance := 0.0;
        longueurBestSolution    := -1000;
        numeroNoirBestSolution  := kNroJoueurInconnu;
        numeroBlancBestSolution := kNroJoueurInconnu;
        
        oldQuoteProtection := GetParsingProtectionWithQuotes();
        SetParsingProtectionWithQuotes(true);
        
        
        oldParsingSet := GetParsingCaracterSet();
        SetParsingCaracterSet(parsingCaracters);
        
      	
      	reste := s;
      	i := 0;
      	chunkNumber := 1;
      	
      	separateurs      := '';
      	partieDigeree    := '';
      	partieNonDigeree := s;  
      	
      	while (reste <> '') & (i < kNbMaxChaines) do
      	  begin
      	    inc(i);
      	    Parser(reste,chaines[i],reste);
      	    
      	    if (chaines[i] <> '') then
      	      begin
      	        positionUtile := Pos(chaines[i],partieNonDigeree);
      	        
      	        {separateurs est la chaine des caracteres sautes lors 
      	         du dernier appel a Parser(reste,chaines[i],reste)  }
      	        separateurs := TPCopy(partieNonDigeree,1,positionUtile - 1);
      	        
      	        {on garde l'invariant   "partieDigeree + partieNonDigeree = s"  }
      	        partieDigeree := partieDigeree + separateurs + chaines[i];
      	        partieNonDigeree := TPCopy(partieNonDigeree,positionUtile + Length(chaines[i]), 255);
      	      end;
      	    
      	    
      	    
      	    while (Length(chaines[i]) > 0) & ( chaines[i][1] = '-') do
      	      chaines[i] := TPCopy(chaines[i],2,Length(chaines[i])-1);
      	      
      	    (* optimisation : on enlève les extensions de fichier *)
      	    if (chaines[i] = 'txt') then chaines[i] := '';
      	    if (chaines[i] = 'TXT') then chaines[i] := '';
      	    if (chaines[i] = 'wzg') then chaines[i] := '';
      	    if (chaines[i] = 'WZG') then chaines[i] := '';
      	    if (chaines[i] = 'pgn') then chaines[i] := '';
      	    if (chaines[i] = 'PGN') then chaines[i] := '';
      	    if (chaines[i] = 'sof') then chaines[i] := '';
      	    if (chaines[i] = 'SOF') then chaines[i] := '';
      	    if (chaines[i] = 'sgf') then chaines[i] := '';
      	    if (chaines[i] = 'SGF') then chaines[i] := '';
      	    if (chaines[i] = 'ggf') then chaines[i] := '';
      	    if (chaines[i] = 'GGF') then chaines[i] := '';
      	    
      	    
      	    {les lexemes composes seulement de chiffres sont probablement
      	     des scores, on les utilise comme separateurs de chunks }
      	    if (chaines[i] = SeulementLesChiffres(chaines[i]))  
      	       | not(ContientUneLettre(chaines[i])) 
      	       | (ChaineEnLongint(SeulementLesChiffres(separateurs)) <> 0)
      	      then inc(chunkNumber);
      	      
      	      
      	      
      	    chaines[i] := MyStripDiacritics(chaines[i]);
      	    chunk[i]   := chunkNumber;
      	    
      	    EnleveEspacesDeGaucheSurPlace(chaines[i]);
      	    EnleveEspacesDeDroiteSurPlace(chaines[i]);
      	    if (chaines[i] = '') |
      	       (chaines[i] = '-') |
      	       (chaines[i] = '_') |
      	       (chaines[i] = '–') |
      	       (chaines[i] = '—') |
      	       (chaines[i] = '--') |
      	       (chaines[i] = '__') |
      	       (chaines[i] = '——') |
      	       (chaines[i] = '––') |
      	       (chaines[i] = SeulementLesChiffres(chaines[i])) |
      	       ((chaines[i] = 'r') & (i = 1) & (s[2] <> ' ')) |
      	       ((chaines[i] = 'R') & (i = 1) & (s[2] <> ' ')) |
      	       ((chaines[i] = 'round') & (i = 1)) |
      	       ((chaines[i] = 'Round') & (i = 1))
      	      then dec(i);
      	  end;
      	nbSousChaines := i;
      	
      	{for i := 1 to nbSousChaines do
      	  WritelnStringAndNumDansRapport(chaines[i]+ '  : chunk = ',chunk[i]);}
      	
      	for i := 0 to nbSousChaines do
      	  for j := 0 to nbSousChaines do
      	    if (j < i)
      	      then memoisation[i,j] := kNroJoueurInconnu
      	      else memoisation[i,j] := kSegmentNonCherche;
      	
      	(* La recherche propremement dite *)
      	termine := false;
      	for i := 1 to nbSousChaines do
      	  for j := i to nbSousChaines do
      	    for k := j to nbSousChaines do
      	      if not(termine) then SplitTableByThree(i,j,k);
      	      
      	  
      	SetParsingCaracterSet(oldParsingSet);
        SetParsingProtectionWithQuotes(oldQuoteProtection);
        
        longueurTotale := 0;
        for i := 1 to nbSousChaines do
          longueurTotale := longueurTotale + Length(chaines[i]) + 1;
          
        if (longueurTotale > 0) & (longueurBestSolution > 0)
          then confiance := 1.0*longueurBestSolution/longueurTotale;
        
        TrouverNomsAvecCeParsingSet := (longueurBestSolution > 0);
    
    end;
  end;


  procedure ComparerCetteSolutionALaMeilleure(confianceCetteSolution : extended;nroNoirCetteSolution,nroBlancCetteSolution : SInt32);
  begin
    if (confianceCetteSolution > qualiteSolution) then
      begin
        TrouverNomsDesJoueursDansNomDeFichier := true;
        qualiteSolution := confianceCetteSolution;
        numeroJoueur1   := nroNoirCetteSolution;
        numeroJoueur2   := nroBlancCetteSolution;
      end;
  end;


begin  {TrouverNomsDesJoueursDansNomDeFichier}
      
  TrouverNomsDesJoueursDansNomDeFichier := false;
  qualiteSolution := 0.0;
    
  
  theParsingCaracters := ['-','–','.',',',';',':','?','¿','/','\','|','~','≠','±','÷','@','#','•',' ',' ','(',')','0','1','2','3','4','5','6','7','8','9'];
  if TrouverNomsAvecCeParsingSet(theParsingCaracters,confiance) then
    ComparerCetteSolutionALaMeilleure(confiance,numeroNoirBestSolution,numeroBlancBestSolution);
    
    
  { Si la chaine contient des underscores, il se peut qu'ils soient utilisés comme séparateurs }
  if (Pos('_',s) > 0) | (Pos('_',s) > 0) then
    begin
      theParsingCaracters := ['-','–','.',',',';',':','?','¿','/','\','|','~','≠','±','÷','@','#','•',' ',' ','(',')','0','1','2','3','4','5','6','7','8','9','_','_'];
      if TrouverNomsAvecCeParsingSet(theParsingCaracters,confiance) then
        ComparerCetteSolutionALaMeilleure(confiance,numeroNoirBestSolution,numeroBlancBestSolution);
    end;
  
  
  {WritelnStringDansRapport(GetNomJoueur(numeroJoueur1) + '  vs  '+GetNomJoueur(numeroJoueur2));}
  
end;  {TrouverNomsDesJoueursDansNomDeFichier}




procedure InitUnitImportDesNoms;
begin
  with gImportDesNoms do
    begin
      pseudosInconnus            := MakeEmptyStringSet();
      pseudosNomsDejaVus         := MakeEmptyStringSet();
      pseudosTournoisDejaVus     := MakeEmptyStringSet();
      pseudosAyantUnNomReel      := MakeEmptyStringSet();
      nomsReelsARajouterDansBase := MakeEmptyStringSet();
    end;
end;


procedure LibereMemoireImportDesNoms;
begin
  with gImportDesNoms do
    begin
      DisposeStringSet(pseudosInconnus);
      DisposeStringSet(pseudosNomsDejaVus);
      DisposeStringSet(pseudosTournoisDejaVus);
      DisposeStringSet(pseudosAyantUnNomReel);
      DisposeStringSet(nomsReelsARajouterDansBase);
    end;
end;






END.



































