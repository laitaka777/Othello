UNIT UnitFormatsFichiers;



INTERFACE







USES UnitFichiersTEXT;


type formats_connus = 
      ( kTypeFichierInconnu,
        kTypeFichierCassio,
        kTypeFichierScriptFinale,
        kTypeFichierSGF,
        kTypeFichierPGN,
        kTypeFichierGGF,
        kTypeFichierGGFMultiple,
        kTypeFichierXOF,
        kTypeFichierZebra,
        kTypeFichierExportTexteDeZebra,
        kTypeFichierHTMLOthelloBrowser,
        kTypeFichierTranscript,
        kTypeFichierPreferences,
        kTypeFichierBibliotheque,
        kTypeFichierGraphe,
        kTypeFichierTHOR_PAR,
        kTypeFichierSuiteDePartiePuisJoueurs,
        kTypeFichierSuiteDeJoueursPuisPartie,
        kTypeFichierLigneAvecJoueurEtPartie,
        kTypeFichierMultiplesLignesAvecJoueursEtPartie, 
        kTypeFichierSimplementDesCoups,
        kTypeFichierSimplementDesCoupsMultiple
        );


type FormatFichierRec = 
       record
         format            : formats_connus;
         tailleOthellier   : SInt16; 
         version           : SInt16; 
         positionEtPartie  : str255;  { valable dans le cas où format = kTypeFichierCassio }
                                      {                     et format = kTypeFichierSGF  (ligne principale) }
                                      {                     et format = kTypeFichierGGF  (ligne principale) }
                                      {                     et format = kTypeFichierHTMLOthelloBrowser }
                                      {                     et format = kTypeFichierTranscript }
                                      {                     et format = kTypeFichierZebra }
                                      {                     et format = kTypeFichierExportTexteDeZebra }
                                      {                     et format = kTypeFichierSimplementDesCoups }
                                      {                     et format = kTypeFichierLigneAvecJoueurEtPartie }
         joueurs           : str255;  { valable dans le cas où format = kTypeFichierLigneAvecJoueurEtPartie 
                                                            et format = kTypeFichierGGF}
       end;


procedure InitUnitFormatsFichiers;
procedure LibereMemoireFormatsFichiers;


{ « fic » doit etre un fichier fermé, il est rendu fermé}
function TypeDeFichierEstConnu(const fic : FichierTEXT; var infos:FormatFichierRec; var err : OSErr) : boolean;




IMPLEMENTATION







USES UnitRapport,MyStrings,SNStrings,UnitEntreeTranscript,UnitTHOR_PAR,UnitAccesStructuresNouvFormat,
     UnitZoneMemoire,UnitImportDesNoms,UnitScannerOthellistique,UnitServicesMemoire,UnitUtilitaires,
     UnitSmartGameBoard, UnitGenericGameFormat;




const kTailleBufferArriere = 100; 

var gLectureFichier : 
      record
        whichZoneMemoire : ZoneMemoire;
        bufferCaracteres : array[-kTailleBufferArriere..0] of char;
        caracteresASauter : SetOfChar;
      end;


procedure InitUnitFormatsFichiers;
begin
end;

procedure LibereMemoireFormatsFichiers;
begin
end;


procedure SetCaracteresASauter(theChars : SetOfChar);
begin
  gLectureFichier.caracteresASauter := theChars;
end;

function GetCaracteresASauter() : SetOfChar;
begin
  GetCaracteresASauter := gLectureFichier.caracteresASauter;
end;

procedure VideBufferCaracteres;
var i : SInt16; 
begin
  for i := -kTailleBufferArriere to 0 do
    gLectureFichier.bufferCaracteres[i] := chr(0);
end;

procedure ResetLectureFichier;
var err : OSErr;
begin
  err := SetPositionMarqueurZoneMemoire(gLectureFichier.whichZoneMemoire,0);
  VideBufferCaracteres;
end;


function NombreCaracteresLusDansFichier() : SInt32;
begin
  NombreCaracteresLusDansFichier := gLectureFichier.whichZoneMemoire.position;
end;


function AvanceDansFichier(sauterLesCaracteresDeControle : boolean) : OSErr;
var err : OSErr;
    c : char;
    i,codeAsciiCaractere : SInt16; 
    estUnCaractereDeControle : boolean;
begin
  err := GetNextCharOfZoneMemoire(gLectureFichier.whichZoneMemoire,c);
  while (err = NoErr) do
    begin
    
      codeAsciiCaractere := ord(c);
      estUnCaractereDeControle := (c in gLectureFichier.caracteresASauter);
    
      if not(estUnCaractereDeControle) |
         not(sauterLesCaracteresDeControle) then
         begin
		       for i := -kTailleBufferArriere to -1 do
		         gLectureFichier.bufferCaracteres[i] := gLectureFichier.bufferCaracteres[i+1];
		       gLectureFichier.bufferCaracteres[0] := c;
		       
		       AvanceDansFichier := NoErr;
		       exit(AvanceDansFichier);
		     end;
		   
		  err := GetNextCharOfZoneMemoire(gLectureFichier.whichZoneMemoire,c);
    end;
  AvanceDansFichier := err;
end;


function GetPreviousCharFichier(negOffset : SInt16) : char;
begin
  if (negOffset >= -kTailleBufferArriere) & (negOffset <= 0)
    then GetPreviousCharFichier := gLectureFichier.bufferCaracteres[negOffset]
    else GetPreviousCharFichier := chr(0);
end;


function GetNextCharFichier(sauterLesCaracteresDeControle : boolean; var c : char) : OSErr;
var err : OSErr;
begin
  err := AvanceDansFichier(sauterLesCaracteresDeControle);
  if err = NoErr then c := GetPreviousCharFichier(0);
  GetNextCharFichier := err;
end;


function GetNextLineDansFichier(var ligne : str255) : OSErr;
begin
  GetNextLineDansFichier := ReadlnDansZoneMemoire(gLectureFichier.whichZoneMemoire,ligne);
end;
  

function GetNextLongintDansFichier(var num : SInt32) : OSErr;
var err : OSErr;
    c : char;
    s : str255;
    longueur : SInt32;
begin

  { Sauter tous les caracteres qui ne sont pas des chiffres }
  err := GetNextCharFichier(false,c);
  while (err = NoErr) & not(IsDigit(c)) do
    err := GetNextCharFichier(false,c);
  
  { Lire le nombre }
  s := '';
  longueur := 0;
  while (err = NoErr) & IsDigit(c) & (longueur <= 10) do
    begin
      s := s + StringOf(c);
      inc(longueur);
      err := GetNextCharFichier(false,c);
    end;
  
  num := ChaineEnLongint(s);
  GetNextLongintDansFichier := err;
end;


function VientDeLireCetteChaine(s : str255) : boolean;
var k,longueur : SInt16; 
begin
  VientDeLireCetteChaine := false;
  
  longueur := Length(s);
  if (longueur > 0) then
    begin
      for k := longueur downto 1 do
        if not(GetPreviousCharFichier(k-longueur) = s[k]) 
          then exit(VientDeLireCetteChaine);
      VientDeLireCetteChaine := true;
    end;
end;


function ScanChaineValeurProperty(caractereOuvrant,caractereFermant : char) : str255;
var s : str255;
    c : char;
    err : OSErr;
    longueur : SInt16; 
begin
  err := NoErr;
  
  c := GetPreviousCharFichier(0);
  if c <> caractereOuvrant then err := GetNextCharFichier(true,c);
  
  if (c <> caractereOuvrant) | (err <> NoErr) then
    begin
      ScanChaineValeurProperty := '';
      exit(ScanChaineValeurProperty);
    end;
  
  s := '';
  longueur := 0;
  repeat
    inc(longueur);
    err := GetNextCharFichier(true,c);
    if (err = NoErr) & (c <> caractereFermant) 
      then s := s + c;
  until (err <> NoErr) | (longueur > 240) | (c = caractereFermant);
  
  ScanChaineValeurProperty := s;
end;


function ParserFormatWZebra(var chaineDesCoups : str255) : boolean;
const WZEBRA_START_OFFSET = 1356;
      WZEBRA_RECORD_LENGTH = 233;
type WZebraRec = packed array[0..232] of char;
var err : OSErr;
    index,count : SInt32;
    taille_zone_memoire,compteurCoup,coup : SInt32;
    myWZebraRec : WZebraRec;
begin
  chaineDesCoups := '';
  ParserFormatWZebra := false;
  
  err := SetPositionMarqueurZoneMemoire(gLectureFichier.whichZoneMemoire,WZEBRA_START_OFFSET);
  
  index               := WZEBRA_START_OFFSET;
  taille_zone_memoire := gLectureFichier.whichZoneMemoire.nbOctetsOccupes;
  compteurCoup        := 0;
  count               := WZEBRA_RECORD_LENGTH;
  err                 := NoErr;
  
  while (err = NoErr) & (compteurCoup < 200) & (Length(chaineDesCoups) < (2 * 64)) &
        (count = WZEBRA_RECORD_LENGTH) &
        (index + WZEBRA_RECORD_LENGTH <= taille_zone_memoire) do
    begin
      inc(compteurCoup);
      
      err := ReadFromZoneMemoire(gLectureFichier.whichZoneMemoire,index,count,@myWZebraRec);
      index := index + WZEBRA_RECORD_LENGTH;
      
      coup := ord(myWZebraRec[4]);
      if (coup <> 0) 
        then chaineDesCoups := chaineDesCoups + CoupEnStringEnMinuscules(coup);
      
    end;
    
  ParserFormatWZebra := (chaineDesCoups <> '');
end;



function TypeDeFichierEstConnu(const fic : FichierTEXT; var infos:FormatFichierRec; var err : OSErr) : boolean;
const WZEBRA_HEADER = 'WZebra Revision 1.5';
var myFic : FichierTEXT;
    compteurCaracteres : SInt32;
    compteurLignes : SInt32;
    parenthese_initiale_trouvee : boolean;
    GM_trouve : boolean;
    FF_trouvee : boolean;
    SZ_trouvee : boolean;
    browser_trouvee : boolean;
    applet_trouvee : boolean;
    header_trouvee : boolean;
    position_initiale_trouvee : boolean;
    partie_trouvee : boolean;
    que_points_ou_x_ou_o : boolean;
    que_des_coordonnees : boolean;
    sortieDeBoucle : boolean;
    c : char;
    caracteresDeControle : SetOfChar;
    s : str255;
    coupsPourLeTranscript : platValeur;
    theTranscript : Transcript;
    analyse : AnalyseDeTranscriptPtr;
    enregistrementGGF : PartieFormatGGFRec;
    
    square,numero : SInt32;



procedure EssaieReconnaitreFormatWZebra;
begin
  {
  WritelnDansRapport('recherche des caracteristiques du format WZebra…');
  }
  
  caracteresDeControle := [];
  SetCaracteresASauter(caracteresDeControle);
  
  ResetLectureFichier;
  compteurCaracteres := 0;
  header_trouvee := false;
  partie_trouvee := false;
  repeat
    inc(compteurCaracteres);
    err := GetNextCharFichier(true,c);
    
    if VientDeLireCetteChaine(WZEBRA_HEADER)  then
      begin
        header_trouvee := true;
        if ParserFormatWZebra(s) & EstUnePartieOthelloAvecMiroir(s) then
          begin
            partie_trouvee := true;
            infos.tailleOthellier  := 8;
            infos.positionEtPartie := '...........................ox......xo...........................' + s;
            infos.format           := kTypeFichierZebra;
          end;
       end;
      
  until (err <> NoErr) | 
        (compteurCaracteres > 30) |
        (header_trouvee & header_trouvee);
end;


procedure EssaieReconnaitreFormatExportTexteDeZebra;
var compteurLignesNonVides : SInt32;
    promptWZebraTrouve : boolean;
begin
  {WritelnDansRapport('recherche des caracteristiques de l'export .txt de WZebra…');}
  
  ResetLectureFichier;
  
  compteurLignes := 0;
  compteurLignesNonVides := 0;
  promptWZebraTrouve := false;
  
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
    if (s <> '') then inc(compteurLignesNonVides);
    
    if (compteurLignesNonVides >= 1) & (compteurLignesNonVides <= 2) then
      if (Pos('WZebra',s) > 0) | (Pos('Zebra',s) > 0) then promptWZebraTrouve := true;
    
    if (compteurLignesNonVides >= 3) & not(promptWZebraTrouve)
      then exit(EssaieReconnaitreFormatExportTexteDeZebra);
    
    if promptWZebraTrouve & EstUnePartieOthelloAvecMiroir(s) then
      begin
        infos.tailleOthellier  := 8;
        infos.positionEtPartie := '...........................ox......xo...........................' + s;
        infos.format           := kTypeFichierExportTexteDeZebra;
        exit(EssaieReconnaitreFormatExportTexteDeZebra);
      end;
    
  until (compteurLignes > 15) | (compteurLignesNonVides >= 7) | (err <> NoErr);
      
end;


procedure EssaieReconnaitreFormatSimplementDesCoups;
var compteurLignesNonVides : SInt32;
    compteurPartiesTrouvees : SInt32;
    joueur1,joueur2 : SInt32;
    confiance : extended;
    moves,s,s1: str255;
    partieLegale,joueursTrouves : boolean;
begin
  {WritelnDansRapport('recherche dans le fichier pour voir s'il y a une seule ligne, avec des coups…');}
  
  ResetLectureFichier;
  
  compteurLignes := 0;
  compteurLignesNonVides := 0;
  compteurPartiesTrouvees := 0;
  moves := '';
  
  
  { on n'accepte ce format que si le fichier contient une seule ligne,
    qui ne contient qu'une partie 'brute', et rien d'autre             }
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
    if (err = NoErr) & (s <> '') then 
      begin
        inc(compteurLignesNonVides);
        
        s1 := s;
        partieLegale := EstUnePartieOthelloAvecMiroir(s1);
        
        joueursTrouves := TrouverPartieEtJoueursDansChaine(s,moves,joueur1,joueur2,confiance);
        
        if partieLegale & not(joueursTrouves) then
          begin
            inc(compteurPartiesTrouvees);
            moves := s;
            partieLegale := EstUnePartieOthelloAvecMiroir(moves);  {symetrisons, eventuellement}
          end;
        
      end;
  until (compteurLignes > 6) | (compteurLignesNonVides >= 2) | (err <> NoErr);
  
  if (compteurPartiesTrouvees >= 1) & 
     (compteurLignesNonVides = compteurPartiesTrouvees) & 
     (moves <> '')  then
    begin
      {WritelnStringAndNumDansRapport('TROUVE (kTypeFichierSimplementDesCoups), compteurPartiesTrouvees = '+compteurPartiesTrouvees);}
      if (compteurPartiesTrouvees >= 2)
        then
          begin
            infos.tailleOthellier  := 8;
            infos.format           := kTypeFichierSimplementDesCoupsMultiple;
          end
        else
          begin
            infos.tailleOthellier  := 8;
            infos.positionEtPartie := '...........................ox......xo...........................' + moves;
            infos.format           := kTypeFichierSimplementDesCoups;
          end;
    end;
      
end;


procedure EssaieReconnaitreFormatLigneAvecJoueurEtPartie;
var compteurLignesNonVides : SInt32;
    compteurPartiesTrouvees : SInt32;
    joueur1,joueur2 : SInt32;
    nbPionsNoirs,nbPionsBlancs : SInt32;
    confiance : extended;
    partieTrouvee : boolean;
    s,moves: str255;
begin
  {WritelnDansRapport('recherche dans le fichier pour voir s''il y a des lignes avec une partie et des noms de joueurs…');}
  
  ResetLectureFichier;
  
  compteurLignes := 0;
  compteurLignesNonVides := 0;
  compteurPartiesTrouvees := 0;
  partieTrouvee := false;
  moves := '';
  
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
    if (err = NoErr) & (s <> '') then 
      begin
        inc(compteurLignesNonVides);
        
        partieTrouvee := TrouverPartieEtJoueursDansChaine(s,moves,joueur1,joueur2,confiance);
        partieTrouvee := partieTrouvee & EstUnePartieOthelloAvecMiroir(moves);  {symetrisons, eventuellement}
        
        if partieTrouvee then inc(compteurPartiesTrouvees);
      end;
  until (compteurLignes > 10) | (compteurPartiesTrouvees >= 2) | (err <> NoErr);
  
  if (compteurPartiesTrouvees >= 1) then
    begin
      
      if (compteurPartiesTrouvees >= 2)
        then 
          begin
            infos.format          := kTypeFichierMultiplesLignesAvecJoueursEtPartie;
            infos.tailleOthellier := 8;
          end
        else 
          begin
            infos.format           := kTypeFichierLigneAvecJoueurEtPartie;
            infos.tailleOthellier  := 8;
            infos.positionEtPartie := '...........................ox......xo...........................' + moves;
            
            if (joueur1 <> kNroJoueurInconnu) & (joueur2 <> kNroJoueurInconnu) then
              if EstUnePartieOthelloTerminee(moves,false,nbPionsNoirs,nbPionsBlancs)
                then infos.joueurs := GetNomJoueur(joueur1) + ' '+ScoreFinalEnChaine(nbPionsNoirs-nbPionsBlancs)+' ' + GetNomJoueur(joueur2)
                else infos.joueurs := GetNomJoueur(joueur1) + ' 0-0 ' + GetNomJoueur(joueur2);
            
          end;
    end;
      
end;


procedure EssaieReconnaitreFormatPGN;
begin
  {if NoCasePos('.pgn',myFic.nomFichier) > 0 then}
  begin
    {WritelnDansRapport('recherche des caracteristiques du format PGN…');}
    
    ResetLectureFichier;
    
    compteurLignes := 0;
    repeat
      inc(compteurLignes);
      err := GetNextLineDansFichier(s);
      EnleveEspacesDeGaucheSurPlace(s);
    until (compteurLignes > 15) | (err <> NoErr) | (Pos('[Event',s) > 0);
    
    if Pos('[Event',s) > 0 then
      infos.format := kTypeFichierPGN;
  end;
end;

procedure EssaieReconnaitreFormatPreferencesCassio;
begin
  ResetLectureFichier;
  
  compteurLignes := 0;
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
  until (compteurLignes > 3) | (err <> NoErr) | (Pos('%versionOfPrefsFile',s) = 1);
  
  if (Pos('%versionOfPrefsFile',s) = 1) then
    infos.format := kTypeFichierPreferences;
end;

procedure EssaieReconnaitreFormatBibliothequeCassio;
begin
  ResetLectureFichier;
  
  compteurLignes := 0;
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
  until (compteurLignes > 3) | (err <> NoErr) | (Pos('% Format_Cassio = [bibliotheque]',s) = 1);
  
  if (Pos('% Format_Cassio = [bibliotheque]',s) = 1) then
    infos.format := kTypeFichierBibliotheque;
end;


procedure EssaieReconnaitreFormatCassio;
var c : char;
begin
              
  { WritelnDansRapport('recherche des caracteristiques du format Cassio…'); }
  
  caracteresDeControle := [];
  for c := chr(0) to chr(255) do
    if (ord(c) <= 32) | (c = ' ') | (c = chr(202)) | (c = ' ') then 
      caracteresDeControle := caracteresDeControle + [c];
  SetCaracteresASauter(caracteresDeControle);
  
  ResetLectureFichier;
  compteurCaracteres := 0;
  position_initiale_trouvee := false;
  partie_trouvee := false;
    
  que_points_ou_x_ou_o := true;
  que_des_coordonnees := true;
  s := '';
  sortieDeBoucle := false;
  repeat
    inc(compteurCaracteres);
    err := GetNextCharFichier(true,c);
    
    {
    WriteDansRapport(c);
    WriteStringAndNumDansRapport(' ' + Concat(c,' '),ord(c));
    WritelnStringAndNumDansRapport(' ',compteurCaracteres);
    }
    
    if (compteurCaracteres <= 64) then
      begin
        s := s + c;
	      que_points_ou_x_ou_o := que_points_ou_x_ou_o & 
	                              CharInSet(c,['.','-',',','#','x','X','*','o','O','0']); 
      end;
      
    if compteurCaracteres = 64 then
      position_initiale_trouvee := que_points_ou_x_ou_o;
    
    if (compteurCaracteres > 64) & (compteurCaracteres < 250) &
       (c<>'¬') & (c<>'%') & (err=NoErr) then
      begin
        s := s + c;
        que_des_coordonnees := que_des_coordonnees & 
                               (CharInRange(c,'a','h') | CharInRange(c,'A','H') | CharInRange(c,'1','8'));
      end;
    
    if (c='%') | (c = '¬') | (err <> NoErr) then
      begin
        sortieDeBoucle := true;
        partie_trouvee := que_des_coordonnees & (compteurCaracteres < 250);
      end;
    
  until (err <> NoErr) | sortieDeBoucle |
        (compteurCaracteres > 250) |
        (position_initiale_trouvee & partie_trouvee) |
        ((compteurCaracteres > 64) & not(position_initiale_trouvee));
  
  if (position_initiale_trouvee & partie_trouvee) then
    begin
      infos.format           := kTypeFichierCassio;
      infos.tailleOthellier  := 8;
      infos.positionEtPartie := s;
      {WritelnDansRapport(s);}
    end;
end;

procedure EssaieReconnaitreFormatSGF;
var c : char;
begin
  
  {
  WritelnDansRapport('recherche des caracteristiques du format SGF…');
  }
  
  caracteresDeControle := [];
  for c := chr(0) to chr(255) do
    if (ord(c) <= 32) | (c = ' ') then 
      caracteresDeControle := caracteresDeControle + [c];
  SetCaracteresASauter(caracteresDeControle);
  
  ResetLectureFichier;
  compteurCaracteres := 0;
  parenthese_initiale_trouvee := false;
  GM_trouve := false;
  FF_trouvee := false;
  SZ_trouvee := false;
  repeat
    inc(compteurCaracteres);
    err := GetNextCharFichier(true,c);
   
    {WriteDansRapport(c);}
    
    if (GetPreviousCharFichier(-1) = '(') &
       (GetPreviousCharFichier(0) = ';') 
      then parenthese_initiale_trouvee := true;
    
    if (GetPreviousCharFichier(-2) = 'G') &
       (GetPreviousCharFichier(-1) = 'M') &
       (GetPreviousCharFichier(0) = '[') 
      then GM_trouve := true;
    
    if (GetPreviousCharFichier(-2) = 'F') &
       (GetPreviousCharFichier(-1) = 'F') &
       (GetPreviousCharFichier(0) = '[') 
      then FF_trouvee := true;
    
    if (GetPreviousCharFichier(-2) = 'S') &
       (GetPreviousCharFichier(-1) = 'Z') &
       (GetPreviousCharFichier(0) = '[') then 
      begin
        s := ScanChaineValeurProperty('[',']');
        
        {WritelnDansRapport('');
        WritelnDansRapport('s = '+s);}
        
        if s = '6' then 
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 6;
          end;
          
        if s = '8' then 
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 8;
          end;
        
        if s = '9' then 
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 9;
          end;
        
        if s = '10' then 
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 10;
          end;
        
        if s = '11' then 
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 11;
          end;
        
        if s = '12' then 
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 12;
          end;
      end;
    
  until (err <> NoErr) | 
        (compteurCaracteres > 20000) |
        (parenthese_initiale_trouvee {& GM_trouve} & FF_trouvee & SZ_trouvee);
  
  {
  WritelnDansRapport('');
  WritelnStringAndBooleanDansRapport('parenthese_initiale_trouvee = ',parenthese_initiale_trouvee);
  WritelnStringAndBooleanDansRapport('GM_trouve = ',GM_trouve);
  WritelnStringAndBooleanDansRapport('FF_trouvee = ',FF_trouvee);
  WritelnStringAndBooleanDansRapport('SZ_trouvee = ',SZ_trouvee);
  }
  
  if (parenthese_initiale_trouvee {& GM_trouve} & FF_trouvee & SZ_trouvee) then
    begin
      infos.format := kTypeFichierSGF;
    end;
end;

procedure EssaieReconnaitreFormatGGF;
var c : char;
    nbBoardPropertiesTrouvees : SInt32;
    nbGamePropertiesTrouvees : SInt32;
begin
  {
  WritelnDansRapport('recherche des caracteristiques du format GGF…');
  }
  
  caracteresDeControle := [];
  for c := chr(0) to chr(255) do
    if (ord(c) <= 32) | (c = ' ') then 
      caracteresDeControle := caracteresDeControle + [c];
  SetCaracteresASauter(caracteresDeControle);
  
  ResetLectureFichier;
  compteurCaracteres := 0;
  
  nbGamePropertiesTrouvees := 0;
  nbBoardPropertiesTrouvees := 0;
  
  
  repeat
    inc(compteurCaracteres);
    err := GetNextCharFichier(true,c);
    
    {
    WriteDansRapport(c);
    }
    
    if (GetPreviousCharFichier(-4) = '(') &
       (GetPreviousCharFichier(-3) = ';') &
       (GetPreviousCharFichier(-2) = 'G') &
       (GetPreviousCharFichier(-1) = 'M') &
       (GetPreviousCharFichier(0) = '[') then
       begin
         s := ScanChaineValeurProperty('[',']');
         if (s = 'Reversi') | (s = 'Othello')
           then inc(nbGamePropertiesTrouvees);
       end;
        
    
    if (GetPreviousCharFichier(-4) = 'B') &
       (GetPreviousCharFichier(-3) = 'O') &
       (GetPreviousCharFichier(-2) = '[') &
       (GetPreviousCharFichier(-1) = '1') &
       (GetPreviousCharFichier(0) = '2') then 
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 12;
       end;
    
    if (GetPreviousCharFichier(-4) = 'B') &
       (GetPreviousCharFichier(-3) = 'O') &
       (GetPreviousCharFichier(-2) = '[') &
       (GetPreviousCharFichier(-1) = '1') &
       (GetPreviousCharFichier(0) = '1') then 
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 11;
       end;
    
    if (GetPreviousCharFichier(-4) = 'B') &
       (GetPreviousCharFichier(-3) = 'O') &
       (GetPreviousCharFichier(-2) = '[') &
       (GetPreviousCharFichier(-1) = '1') &
       (GetPreviousCharFichier(0) = '0') then 
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 10;
       end;
    
    if (GetPreviousCharFichier(-3) = 'B') &
       (GetPreviousCharFichier(-2) = 'O') &
       (GetPreviousCharFichier(-1) = '[') &
       (GetPreviousCharFichier(0) = '9') then 
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 9;
       end;
       
    if (GetPreviousCharFichier(-3) = 'B') &
       (GetPreviousCharFichier(-2) = 'O') &
       (GetPreviousCharFichier(-1) = '[') &
       (GetPreviousCharFichier(0) = '8') then 
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 8;
       end;
     
     if (GetPreviousCharFichier(-3) = 'B') &
       (GetPreviousCharFichier(-2) = 'O') &
       (GetPreviousCharFichier(-1) = '[') &
       (GetPreviousCharFichier(0) = '7') then 
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 7;
       end;
       
     if (GetPreviousCharFichier(-3) = 'B') &
       (GetPreviousCharFichier(-2) = 'O') &
       (GetPreviousCharFichier(-1) = '[') &
       (GetPreviousCharFichier(0) = '6') then 
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 6;
       end;
      
  until (err <> NoErr) | 
        (compteurCaracteres > 4000) |
        ((nbGamePropertiesTrouvees >= 2) & (nbBoardPropertiesTrouvees >= 1));
 
  {
  WritelnDansRapport('');
  WritelnStringAndBooleanDansRapport('GM_trouve = ',GM_trouve);
  WritelnStringAndBooleanDansRapport('BO_trouvee = ',BO_trouvee);
  }
  
  if (nbGamePropertiesTrouvees >= 1) & (nbBoardPropertiesTrouvees >= 1) then
    begin
      if (nbGamePropertiesTrouvees >= 2)
        then infos.format := kTypeFichierGGFMultiple
        else infos.format := kTypeFichierGGF;
    end;
end;

procedure EssaieReconnaitreFormatXOF;
begin
end;


procedure EssaieReconnaitreFormatSuiteDeParties;
var s1,s2,s3 : str255;
    somme : str255;
    moves,noms : str255;
    nbNoirs,nbBlancs : SInt32;
    n1,n2 : SInt32;
    erreurES : OSErr;
    confiance : extended;
begin

  { FIXME : la lecture des joueurs et des tournois peut etre assez longue :-(   }
  if not(problemeMemoireBase) & not(JoueursEtTournoisEnMemoire)
    then erreurES := MetJoueursEtTournoisEnMemoire(false);
        
  ResetLectureFichier;
  
  s1 := '';
  s2 := '';
  s3 := '';
  
  compteurLignes := 0;
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s1);
    EnleveEspacesDeGaucheSurPlace(s1);
  until (compteurLignes > 3) | (err <> NoErr) | (s1 <> '');
  
  if (err = NoErr) then
    begin
      compteurLignes := 0;
      repeat
        inc(compteurLignes);
        err := GetNextLineDansFichier(s2);
        EnleveEspacesDeGaucheSurPlace(s2);
      until (compteurLignes > 3) | (err <> NoErr) | (s2 <> '');
    end;
  
  if (err = NoErr) then
    begin
      compteurLignes := 0;
      repeat
        inc(compteurLignes);
        err := GetNextLineDansFichier(s3);
        EnleveEspacesDeGaucheSurPlace(s3);
      until (compteurLignes > 3) | (err <> NoErr) | (s3 <> '');
    end;
  
  
  moves := s1;
  noms  := s2;
  somme := moves + noms;
  if (infos.format = kTypeFichierInconnu) & (moves <> '') & 
     EstUnePartieOthelloAvecMiroir(moves) &
     (not(EstUnePartieOthello(somme,false)) | EstUnePartieOthelloTerminee(moves,false,nbNoirs,nbBlancs)) & 
     TrouverNomsDesJoueursDansNomDeFichier(noms,n1,n2,0,confiance)
    then infos.format := kTypeFichierSuiteDePartiePuisJoueurs;
  
  moves := s2;
  noms  := s1;
  somme := moves + noms;
  if (infos.format = kTypeFichierInconnu) & (moves <> '') & 
     EstUnePartieOthelloAvecMiroir(moves) &
     (not(EstUnePartieOthello(somme,false)) | EstUnePartieOthelloTerminee(moves,false,nbNoirs,nbBlancs)) & 
     TrouverNomsDesJoueursDansNomDeFichier(noms,n1,n2,0,confiance)
    then infos.format := kTypeFichierSuiteDeJoueursPuisPartie;
        
    
  moves := s1 + s2;
  noms  := s3;
  somme := moves + noms;
  if (infos.format = kTypeFichierInconnu) & (moves <> '') & 
     EstUnePartieOthelloAvecMiroir(moves) & 
     (not(EstUnePartieOthello(somme,false)) | EstUnePartieOthelloTerminee(moves,false,nbNoirs,nbBlancs)) & 
     TrouverNomsDesJoueursDansNomDeFichier(noms,n1,n2,0,confiance)
    then infos.format := kTypeFichierSuiteDePartiePuisJoueurs;
    
end;


procedure EssaieReconnaitreFormatHTMLOthelloBrowser;
var c : char;
begin
  {
  WritelnDansRapport('recherche des caracteristiques du format HTML avec l'applet OthelloBrowser ou OthelloViewer…');
  }
  
  caracteresDeControle := [];
  for c := chr(0) to chr(255) do
    if (ord(c) <= 32) | (c = ' ') then 
      caracteresDeControle := caracteresDeControle + [c];
  SetCaracteresASauter(caracteresDeControle);
  
  ResetLectureFichier;
  compteurCaracteres := 0;
  browser_trouvee := false;
  applet_trouvee := false;
  partie_trouvee := false;
  repeat
    inc(compteurCaracteres);
    err := GetNextCharFichier(true,c);
    
    {
    WriteDansRapport(c);
    }
    if VientDeLireCetteChaine('OthelloBrowser') |
       VientDeLireCetteChaine('othellobrowser') |
       VientDeLireCetteChaine('OTHELLOBROWSER') |
       VientDeLireCetteChaine('OthelloViewer')  |
       VientDeLireCetteChaine('othelloviewer')  |
       VientDeLireCetteChaine('OTHELLOVIEWER')  then
      begin
        browser_trouvee := true;
        infos.tailleOthellier := 8;
      end;
    
    if VientDeLireCetteChaine('applet') |
       VientDeLireCetteChaine('Applet') |
       VientDeLireCetteChaine('APPLET') then
      begin
        applet_trouvee := true;
      end;
    
    if VientDeLireCetteChaine('value="') |
       VientDeLireCetteChaine('Value="') |
       VientDeLireCetteChaine('VALUE="') then
     begin
       s := ScanChaineValeurProperty('"','"');
       if EstUnePartieOthelloAvecMiroir(s) then
         begin
           partie_trouvee := true;
           infos.positionEtPartie := '...........................ox......xo...........................' + s;
         end;
     end;
      
  until (err <> NoErr) | 
        (compteurCaracteres > 20000) |
        (browser_trouvee & applet_trouvee & partie_trouvee);
 
  {
  WritelnDansRapport('');
  WritelnStringAndBooleanDansRapport('browser_trouvee = ',browser_trouvee);
  WritelnStringAndBooleanDansRapport('applet_trouvee = ',applet_trouvee);
  WritelnStringAndBooleanDansRapport('partie_trouvee = ',partie_trouvee);
  WritelnDansRapport('infos.positionEtPartie = '+infos.positionEtPartie);
  }
  
  
  if browser_trouvee & applet_trouvee & partie_trouvee then
    begin
      infos.format := kTypeFichierHTMLOthelloBrowser;
    end;
end;


procedure EssaieReconnaitreFormatTranscript;
var coordonnees_a_gauche : boolean;
    coordonnees_a_droite : boolean;
begin
  caracteresDeControle := [];
  SetCaracteresASauter(caracteresDeControle);
  
  analyse := AnalyseDeTranscriptPtr(AllocateMemoryPtrClear(SizeOf(AnalyseDeTranscript)));
  
  for coordonnees_a_gauche := false to true do
    for coordonnees_a_droite := false to true do
      if (infos.format = kTypeFichierInconnu) & (analyse <> NIL) then
        begin
          ResetLectureFichier;
          MemoryFillChar(@coupsPourLeTranscript,SizeOf(platValeur),chr(0));
          
          err := NoErr;
          square := 10;
          repeat
            if ((square mod 10) = 0) & not(coordonnees_a_gauche) then inc(square) else
            if ((square mod 10) = 9) & not(coordonnees_a_droite) then inc(square) 
              else
                begin
                  err := GetNextLongintDansFichier(numero);
                  
                  { sauter les cases centrales, sauf si on a l'impression 
                    qu''elles sont numerotes par zero dans le transcript }
                    
                  if ((square = 44) | (square = 45) | (square = 54) | (square = 55)) & (numero <> 0) then
                    while (square = 44) | (square = 45) | (square = 54) | (square = 55) do 
                      inc(square);
                  
                  if (numero >= 0) & (numero <= 99) then
                    begin
                      coupsPourLeTranscript[square] := numero;
                      inc(square);
                    end;
                end;
                
          until (err <> NoErr) | (square > 88) |
                (NombreCaracteresLusDansFichier() >= 2000);
          
          if (square > 88) then
            begin
              theTranscript := MakeTranscriptFromPlateauOthello(coupsPourLeTranscript);
              ChercherLesErreursDansCeTranscript(theTranscript,analyse^);
              if analyse^.tousLesCoupsSontLegaux then
                begin
                  s := analyse^.plusLonguePartieLegale;
                  if EstUnePartieOthelloAvecMiroir(s) then {symetrisons, eventuellement}
						        begin
						          infos.format           := kTypeFichierTranscript;
						          infos.tailleOthellier  := 8;
						          infos.positionEtPartie := '...........................ox......xo...........................' + s;
						        end;
                end;
            end;
        end;
   
   DisposeMemoryPtr(Ptr(analyse));
end;


procedure EssaieReconnaitreFormatScriptFinales;
var c : char;
begin
  if NoCasePos('.script',myFic.nomFichier) > 0 then 
    begin
      
      {
      WritelnDansRapport('recherche des caracteristiques du format Script de finales…');
      }
      
      caracteresDeControle := [];
      for c := chr(0) to chr(255) do
        if (ord(c) <= 32) | (c = ' ') then 
          caracteresDeControle := caracteresDeControle + [c];
      SetCaracteresASauter(caracteresDeControle);
    
      ResetLectureFichier;
      err := GetNextCharFichier(true,c);
      
      if CharInSet(c,['%','-','X','x','0','O','o']) then
        begin
          infos.format := kTypeFichierScriptFinale;
        end;
    end;
end;

procedure EssaieReconnaitreFormatTHOR_PAR;
begin
  if (NoCasePos('.PAR',myFic.nomFichier) > 0) &
     (gLectureFichier.whichZoneMemoire.nbOctetsOccupes = TailleDuFichierTHOR_PAR()) then
    begin
      infos.format           := kTypeFichierTHOR_PAR;
      infos.tailleOthellier  := 8;
    end;
end;


procedure DumpFirstCaracteresOfFileDansRapport(nbDeCaracteres : SInt32);
var err : OSErr;
    c : char;
    compteur : SInt32;
begin
  ResetLectureFichier;
  compteur := 0;
  repeat
    inc(compteur);
    err := GetNextCharFichier(true,c);
    WritelnStringAndNumDansRapport(NumEnString(compteur-compteur) + ' : '+StringOf(c)+'=',ord(c));
  until EscapeDansQueue() | (compteur >= nbDeCaracteres);
end;


procedure EssaieReconnaitreFormatGraphe;
begin
end;


begin  { TypeDeFichierEstConnu }
  
  infos.format           := kTypeFichierInconnu;
  infos.tailleOthellier  := 0;
  infos.version          := 0;
  infos.positionEtPartie := '';
  infos.joueurs          := '';
  
  err := -1;
  
  {
  WritelnDansRapport('entree dans TypeDeFichierEstConnu');
  WritelnDansRapport('   dans TypeDeFichierEstConnu, fic.nomFichier = '+fic.nomFichier);
  WritelnStringAndNumDansRapport('   dans TypeDeFichierEstConnu, fic.vRefNum = ',fic.vRefNum);
  WritelnDansRapport('   dans TypeDeFichierEstConnu, fic.theFSSpec.name = '+fic.theFSSpec.name);
  WritelnStringAndNumDansRapport('   dans TypeDeFichierEstConnu, fic.theFSSpec.vRefNum = ',fic.theFSSpec.vRefNum);  
  }
  
  
  if (FichierTexteExiste(fic.nomFichier,0,myFic) = NoErr) &
     (myFic.theFSSpec.name[1] <> '.') {on ne veut pas les fichiers dont le nom commence par un point}
     then
    with gLectureFichier do
      begin
       
        {
        WritelnDansRapport('OK, FichierTexteExiste dans TypeDeFichierEstConnu');
        }
        
        whichZoneMemoire := MakeZoneMemoireFichier(myFic.nomFichier,0);
        if ZoneMemoireEstCorrecte(whichZoneMemoire) then
          begin
            
            {
            WritelnDansRapport('OK, ZoneMemoireEstCorrecte(whichZoneMemoire) dans TypeDeFichierEstConnu');
            }
            
            
            {on cherche les caracteres caracteristiques du format WZebra}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatWZebra;
            
            
            {on cherche les lignes caracteristiques du format export texte de WZebra}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatExportTexteDeZebra;
							
            
            {on cherche a savoir si c'est un fichier PGN (VOG ou Kurnik)}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatPGN;
              
            
            {on cherche a savoir si c'est un fichier de script de finale}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatScriptFinales;
            
            
            {on cherche a savoir si c'est un fichier au format Cassio}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatCassio;
              
					  
					  {on cherche à savoir si c'est un fichier THOR.PAR}
					  if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatTHOR_PAR;
					  
              
            {on cherche à savoir si c'est un fichier de preferences de Cassio}
					  if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatPreferencesCassio;
            
            
            {on cherche les caracteres caracteristiques du format SGF}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatSGF;
            
            
            {on cherche à savoir si c'est un fichier de bibliotheque de Cassio}
					  if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatBibliothequeCassio;
              
            
            {on cherche les caracteres caracteristiques du format GGF}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatGGF;
            
            
            {on cherche à savoir si c'est une fichier contenant simplement une suite de coups}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatSimplementDesCoups;
							
							
						{on cherche les caracteres caracteristiques du format HTML avec applet OthelloBrowser ou OthelloViewer}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatHTMLOthelloBrowser;
            
            
            {on cherche a trouver un transcript legal}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatTranscript;
            
            
            {on cherche a trouver un transcript legal}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatLigneAvecJoueurEtPartie;
            
            
            {on cherche les lignes caracteristiques du format SuiteDeParties}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatSuiteDeParties;
              
            
            { FIXME : on essaie de comprendre le format .wzg pour les positions…  
            if (infos.format = kTypeFichierInconnu) & (NoCasePos('problema 10 Negras.wzg',myFic.nomFichier) > 0) then
              DumpFirstCaracteresOfFileDansRapport(1376);
            }
            
            DisposeZoneMemoire(whichZoneMemoire);
          end;
          
        
        if (infos.format = kTypeFichierSGF) | (infos.format = kTypeFichierGGF) then
          begin
            err := ReadEnregistrementDansFichierSGF_ou_GGF_8x8(myFic,infos.format,enregistrementGGF);
            with enregistrementGGF do
              if EstUnePartieOthelloAvecMiroir(coupsEnAlpha) then
                begin
                  infos.positionEtPartie := '...........................ox......xo...........................' + coupsEnAlpha;
                  infos.joueurs          := joueurNoir + ' - ' + joueurBlanc;
                end;
          end;
        
      end;
  
  TypeDeFichierEstConnu := (infos.format <> kTypeFichierInconnu);
end;



(*
   A  B  C  D  E  F  G  H
1 |51|39|36|34|33|37|56|57|
2 |52|50|16|25|11|14|58|31|
3 |26|35|22| 5| 6|15|17|30|
4 |43|21|10|()|##| 4| 7|29|
5 |45|12| 3|##|()| 1| 8|28|
6 |46|40|23| 2| 9|18|32|19|
7 |47|49|20|13|27|24|54|60|
8 |48|53|42|41|44|38|59|55|


   A  B  C  D  E  F  G  H
1  00  00  00  00  00  00  00  00 
2  00  00  00  00  00  00  00  00 
3  00  00  00  00  00  00  00  00 
4  00  00  00  X  () 00  00  00 
5  00  00  00  ()  X  1  00  00 
6  00  00  00  00  00  00  00  00 
7  00  00  00  00  00  00  00  00 
8  00  00  00  00  00  00  00  00 


 54 53 27 34 29 25 44 43
 50 52 26 33 24 28 36 30
 46 23 18 09 07 08 11 42
 47 45 35 00 00 04 14 15Å@N Murakami
 48 37 16 00 00 01 05 20Å@B Goto Hiroshi
 55 38 12 13 03 02 17 10
 51 56 49 31 06 19 60 21
 57 58 39 40 32 22 41 59

*)


END.





















