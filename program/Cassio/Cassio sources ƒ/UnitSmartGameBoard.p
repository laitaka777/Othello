UNIT UnitSmartGameBoard;


{$DEFINEC USE_PROFILER_SMART_GAME_BOARD   FALSE}

INTERFACE







USES 
{$IFC USE_PROFILER_SMART_GAME_BOARD}
    Profiler,
{$ENDC}
    UnitOth0,UnitZoneMemoire,UnitPositionEtTrait;
    

{initialisation de l'unité}
procedure InitUnitSmartGameBoard;
procedure LibereMemoireUnitSmartGameBoard;

{lecture et ecriture du format Smart Game Board (SGF)}
procedure LitFormatSmartGameBoard(G : GameTree;whichZoneMemoire : ZoneMemoire);
procedure EcritFormatSmartGameBoard(G : GameTree; var whichZoneMemoire : ZoneMemoire);

{tests de reconnaissance format SGF}
function EstUneZoneMemoireAuFormatSmartGameBoard(whichZoneMemoire : ZoneMemoire) : boolean;
function EstUnFichierAuFormatSmartGameBoard(nomFichier : str255;vRefNum : SInt16) : boolean;

{lecture simplifiee : position initiale et ligne principale}
function GetPositionInitialeEtPartieDansFichierSmartGameBoard(var fic : FichierTEXT; var posInitiale : PositionEtTraitRec; var coups : str255) : OSErr;

{on gere une petite base de donnees des derniers fichiers SGF lus/ecrits}
procedure SauvegarderDatabaseOfRecentSGFFiles;
procedure LireDatabaseOfRecentSGFFiles;
procedure AjouterNomDansDatabaseOfRecentSGFFiles(const whichDate,whichName : str255);
function FichierExisteDansDatabaseOfRecentSGFFiles(whichName : str255; var modificationDate : str255) : boolean;


IMPLEMENTATION







USES UnitSetUp,UnitRapportImplementation,UnitDefinitionsSmartGameBoard,UnitGameTree,UnitArbreDeJeuCourant,
     UnitInterversions,UnitPierresDelta,UnitSauvegardeRapport,MyMathUtils,MyStrings,UnitRapport,SNStrings,
     UnitServicesDialogs,UnitMiniProfiler,UnitOth2,UnitPressePapier,UnitScannerOthellistique,UnitMacExtras,
     UnitGenericGameFormat;


{$IFC USE_PROFILER_SMART_GAME_BOARD}
var nomFichierProfileSmartGameBoard : str255;
{$ENDC}


const kMaxRecentSGFFiles = 10;
var   gDatabaseRecentSGFFiles : array[1..kMaxRecentSGFFiles] of 
                                  record
                                    date,name : str255;
                                  end;

procedure InitUnitSmartGameBoard;
begin
end;

procedure LibereMemoireUnitSmartGameBoard;
begin
end;

function GetNextChar(SauterLesCaracteresDeControle : boolean) : char;
var err : OSErr;
    c : char;
    codeAsciiCaractere : SInt16; 
    EstUnCaractereDeControle : boolean;
    oldPositionDansZoneMemoire,count,nouvellePositionPourBuffer : SInt32;
begin
  with LectureSmartGameBoard do
    begin
		    repeat
		  
		  
		    with TheZoneMemoire do
		      begin
		        if (position < premierOctetDansBuffer) | (position > dernierOctetDansBuffer) then
		          begin  {defaut de page : on lit un nouveau buffer}
		          
		            {WritelnStringAndNumDansRapport('defaut de page : position = ',theZoneMemoire.position);}
		            oldPositionDansZoneMemoire := position;
		            nouvellePositionPourBuffer := Max(0,oldPositionDansZoneMemoire-10);
		            count := sizeof(buffer);
		            
		            err := ReadFromZoneMemoire(theZoneMemoire,nouvellePositionPourBuffer,count,@buffer);
		            
		            premierOctetDansBuffer := nouvellePositionPourBuffer;
		            dernierOctetDansBuffer := nouvellePositionPourBuffer + count - 1;
		            
		            err := SetPositionMarqueurZoneMemoire(theZoneMemoire,oldPositionDansZoneMemoire);
		            
		            {WritelnStringAndNumDansRapport('premierOctetDansBuffer = ',premierOctetDansBuffer);
		            WritelnStringAndNumDansRapport('dernierOctetDansBuffer = ',dernierOctetDansBuffer);
		            WritelnStringAndNumDansRapport('count = ',count);
		            WritelnStringAndNumDansRapport('apres la lecture du buffer : position = ',theZoneMemoire.position);}
		          end;
		        
		        if (position>=premierOctetDansBuffer) & (position<=dernierOctetDansBuffer)
		          then
		            begin
		              c := buffer[position-premierOctetDansBuffer];
		              position := position+1;
		              err := NoErr;
		              inc(compteurCaracteres);
		            end
		          else
		            begin
		              err := SetPositionMarqueurZoneMemoire(theZoneMemoire,position);
		              err := GetNextCharOfZoneMemoire(TheZoneMemoire,c);
		              inc(compteurCaracteres);
		            end;
		      end;
		  
		    
		    QuitterLecture := QuitterLecture | 
		                      (err <> NoErr)   |
		                      (compteurCaracteres > TheZoneMemoire.nbOctetsOccupes);
		    
		    GetNextChar := c;
		    
		    
		    
		    codeAsciiCaractere := ord(c);
		    EstUnCaractereDeControle := (c = ' ') | (codeAsciiCaractere <= 32);
		    
		  until not(EstUnCaractereDeControle & SauterLesCaracteresDeControle) | QuitterLecture;
		  
		  avantDernierCaractereLu := dernierCaractereLu;
		  dernierCaractereLu := c;
    end;
end;


procedure RevientEnArriereDansFichier(nbCaracteres : SInt32);
var err : OSErr;
    nouvellePositionVoulue : SInt32;
begin
  with LectureSmartGameBoard do
    with TheZoneMemoire do
	    begin
	      nouvellePositionVoulue := Max(position-nbCaracteres,0);
	      
	      if (nouvellePositionVoulue>=premierOctetDansBuffer) & 
	         (nouvellePositionVoulue<=dernierOctetDansBuffer)
          then
            begin
              position := nouvellePositionVoulue;
              compteurCaracteres := position;
              err := NoErr;
            end
          else
            begin
              err := RevientEnArriereDansZoneMemoire(TheZoneMemoire,nbCaracteres);
	            compteurCaracteres := position;
            end;
	      
	      if (nbCaracteres = 1)
	        then dernierCaractereLu := avantDernierCaractereLu
	        else dernierCaractereLu := chr(0);
	      avantDernierCaractereLu := chr(0);
	      
	      QuitterLecture := QuitterLecture | (err<>NoErr);
	    end;
end;



function LitArgumentOfPropertyEnChaine(SauterLesCaracteresDeControle : boolean) : str255;
var s : str255;
    c : char;
    longueur : SInt16; 
begin
  with LectureSmartGameBoard do
    begin
		  s := '';
		  longueur := 0;
		  c := GetNextChar(SauterLesCaracteresDeControle);
		  {WritelnDansRapport('LitArgumentOfPropertyEnChaine : lecture de '+c+' (code ascii = '+NumEnString(ord(c))+')');
		  }
		  while not((c = ']') & (avantDernierCaractereLu <> '\')) & 
		       (longueur<255) & not(QuitterLecture) do
		    begin
		      if not((c = '\') & (avantDernierCaractereLu <> '\')) then
		        begin
		          s := Concat(s,c);
		          inc(longueur);
		          
		          {ne pas lire deux \ dans les sequences du genre \\\[ }
		          if (c = '\') & (avantDernierCaractereLu = '\') then
		            begin
		              dernierCaractereLu := chr(0);
		              avantDernierCaractereLu := chr(0);
		            end;
		            
		        end;
		      c := GetNextChar(SauterLesCaracteresDeControle);
		      {WritelnDansRapport('LitArgumentOfPropertyEnChaine : lecture de '+c+' (code ascii = '+NumEnString(ord(c))+')');
		      }
		    end;
		  {WritelnDansRapport('LitArgumentOfPropertyEnChaine ='+s);}
		  LitArgumentOfPropertyEnChaine := s;
    end;
end;

function LitArgumentOfPropertyEnCoup() : SInt16; 
var s : str255;
    square : SInt16;
    colonne,ligne : SInt16;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  if s='tt'
    then LitArgumentOfPropertyEnCoup := CoupSpecialPourPasse
    else 
      begin
        square := StringEnCoup(s);
        if (square = -1) & (Length(s) >= 2) then
          begin
            {not found, cela pourrait etre un coup au format aa, ab, etc... (c'est-a-dire comme au go, deux coordonees en chiffres)}
            if StringSGFEnCoup(s, colonne, ligne) then
              square := 10*ligne + colonne;
          end;
        LitArgumentOfPropertyEnCoup := square;
      end;
end;

function LitArgumentOfPropertyEnLongint() : SInt32;
var s : str255;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  LitArgumentOfPropertyEnLongint := ChaineEnLongint(s);
end;


function LitArgumentOfPropertyEnTriple():Triple;
var s : str255;
    aux:Triple;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  aux.nbTriples := ChaineEnLongint(s);
  LitArgumentOfPropertyEnTriple := aux;
end;

function LitArgumentOfPropertyEnReel() : extended;
var s : str255;
    r : extended;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  r := StringSimpleEnReel(s);
  LitArgumentOfPropertyEnReel := r;
end;

function LitArgumentOfPropertyEnSquareSet() : SquareSet;
var result : SquareSet;
    s : str255;
    c : char;
    compteur,aux : SInt32;
begin
  result := [];
  
  compteur := 0;
  repeat
    s := LitArgumentOfPropertyEnChaine(true);
    if s<>'' then
      begin
        aux := StringEnCoup(s);
        if (aux>=11) & (aux<=88) then result := result+[aux];
      end;
    c := GetNextChar(true);
    inc(compteur);
  until (c<>'[') | (compteur>=1000);
  RevientEnArriereDansFichier(1);
  
  LitArgumentOfPropertyEnSquareSet := result;
end;

function LitArgumentOfPropertyEnChar() : char;
var s : str255;
begin
  s := LitArgumentOfPropertyEnChaine(false);
  LitArgumentOfPropertyEnChar := s[1];
end;

function LitArgumentVideOfProperty() : boolean;
var s : str255;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  LitArgumentVideOfProperty := (s='');
end;


function LitArgumentOfPropertyEnBooleen() : boolean;
var s : str255;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  LitArgumentOfPropertyEnBooleen := (s='true');
end;


function ReadLongintProperty(genre : SInt16) : Property;
begin
  ReadLongintProperty := MakeLongintProperty(genre,LitArgumentOfPropertyEnLongint);
end;


function ReadOthelloValueProperty(genre : SInt16; avecRedressement : boolean) : Property;
var s,s1,appName,version : str255;
    couleur,signe : SInt16; 
    integerValue,centiemes : SInt32;
    realValue : extended;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  s1 := s;
  
  {Cas particuliers : gain noir et gain blanc}
  if (s = 'B+') | ((genre = NodeValueProp) & (s = 'B+1')) then
    begin
      ReadOthelloValueProperty := MakeValeurOthelloProperty(genre, pionNoir, +1, 1, 0);
      exit(ReadOthelloValueProperty);
    end;
  if (s = 'W+') | ((genre = NodeValueProp) & (s = 'W+1')) then
    begin
      ReadOthelloValueProperty := MakeValeurOthelloProperty(genre, pionBlanc, +1, 1, 0);
      exit(ReadOthelloValueProperty);
    end;
  
  {WriteDansRapport('s = '+s);}
  
  {valeurs par defaut}
  couleur := pionNoir;  {conforme à la thèse de Kierulf}
  signe := +1;
  integerValue := 0;
  centiemes := 0;
  
  if (s[1]='B') | (s[1]='b') then 
    begin
      couleur := pionNoir;
      s := TPCopy(s,2,Length(s)-1);
    end else
  if (s[1]='W') | (s[1]='w') then 
    begin
      couleur := pionBlanc;
      s := TPCopy(s,2,Length(s)-1);
    end else
  if (s[1]='D') | (s[1]='d') then 
    begin
      couleur := pionVide;
      s := TPCopy(s,2,Length(s)-1);
    end;
  
  if (s[1] = '-') then 
    begin
      signe := -1;
      s := TPCopy(s,2,Length(s)-1);
    end else
  if (s[1] = '+') then 
    begin
      signe := +1;
      s := TPCopy(s,2,Length(s)-1);
    end;
  
  
  realValue := StringSimpleEnReel(s);
  
  {WritelnStringAndReelDansRapport('s = '+s+' =>  realValue = ',realValue,5);}
  
  integerValue := MyTrunc(realValue);
  centiemes := MyTrunc(100*(realValue-1.0*integerValue )+0.499);
 
  {cas particulier : les EL[valeur] de Cassio étaient auparavant 
   stockees comme des entiers, on divise par 100}
  if (genre = ComputerEvaluationProp) & 
     (Pos('.',s) = 0) & (centiemes = 0) &
     GetApplicationNameDansArbre(appName,version) &
     (Pos('Cassio',appName) > 0) then
    begin
      centiemes := integerValue mod 100;
      integerValue := integerValue div 100;
    end;
  
  if (genre = NodeValueProp) & odd(integerValue) then
    begin
      WritelnDansRapport('Warning : note impaire dans V['+s1+'], je corrige');
      if integerValue > 0 
        then inc(integerValue)
        else dec(integerValue);
    end;
      
  if avecRedressement & (signe < 0)
    then ReadOthelloValueProperty := MakeValeurOthelloProperty(genre,-couleur,-signe,integerValue,centiemes)
    else ReadOthelloValueProperty := MakeValeurOthelloProperty(genre, couleur, signe,integerValue,centiemes);
end;


function ReadRealProperty(genre : SInt16) : Property;
begin
  ReadRealProperty := MakeRealProperty(genre,LitArgumentOfPropertyEnReel());
end;


function ReadStringProperty(genre : SInt16) : Property;
begin
  ReadStringProperty := MakeStringProperty(genre,LitArgumentOfPropertyEnChaine(false));
end;


function ReadSquareProperty(genre : SInt16) : Property;
var whichSquare : SInt16; 
begin
  whichSquare := LitArgumentOfPropertyEnCoup();
  if (genre=BlackMoveProp) & (whichSquare=CoupSpecialPourPasse) then ReadSquareProperty := MakeArgumentVideProperty(BlackPassProp) else
  if (genre=WhiteMoveProp) & (whichSquare=CoupSpecialPourPasse) then ReadSquareProperty := MakeArgumentVideProperty(WhitePassProp) else
  ReadSquareProperty := MakeOthelloSquareProperty(genre,whichSquare)
end;


function ReadArgumentVideProperty(genre : SInt16) : Property;
begin
  if LitArgumentVideOfProperty() then;
  ReadArgumentVideProperty := MakeArgumentVideProperty(genre);
end;


function ReadSquareSetProperty(genre : SInt16) : Property;
begin
  ReadSquareSetProperty := MakeSquareSetProperty(genre,LitArgumentOfPropertyEnSquareSet);
end;


function ReadSquareCoupleProperty(genre : SInt16) : Property;
var whichSquare1,whichSquare2 : SInt16; 
    s,s1,s2 : str255;
    oldParsingSet : SetOfChar;
begin
	s := LitArgumentOfPropertyEnChaine(true);
	
	oldParsingSet := GetParsingCaracterSet();
	SetParsingCaracterSet([':']);
	Parser(s,s1,s2);
	SetParsingCaracterSet(oldParsingSet);
	
	whichSquare1 := StringEnCoup(s1);
	whichSquare2 := StringEnCoup(s2);
	
  ReadSquareCoupleProperty := MakeSquareCoupleProperty(genre,whichSquare1,whichSquare2);
end;


function ReadTripleProperty(genre : SInt16) : Property;
begin
  ReadTripleProperty := MakeTripleProperty(genre,LitArgumentOfPropertyEnTriple);
end;


function ReadBooleanProperty(genre : SInt16) : Property;
begin
  ReadBooleanProperty := MakeBooleanProperty(genre,LitArgumentOfPropertyEnBooleen);
end;
  
function ReadCharProperty(genre : SInt16) : Property;
begin
  ReadCharProperty := MakeCharProperty(genre,LitArgumentOfPropertyEnChar);
end;


procedure ReadArgumentOfTexteProperty(var prop : Property;TailleMaximumDuTexte : SInt32);
var c : char;
    s : str255;
    compteur,longueurTotaleDuTexte : SInt32;
begin
  with LectureSmartGameBoard do
    begin
		  longueurTotaleDuTexte := prop.taille;
		  
		  repeat
		    s := '';
		    c := GetNextChar(false);
		    compteur := 1;
		    inc(longueurTotaleDuTexte);
		    
		    while not((c = ']') & (avantDernierCaractereLu <> '\')) & 
		          (longueurTotaleDuTexte<TailleMaximumDuTexte) & 
		          (compteur<200) & not(QuitterLecture) do
		    begin
		      if not((c = '\') & (avantDernierCaractereLu <> '\')) then
				    begin
				      s := Concat(s,c);
				      inc(longueurTotaleDuTexte);
				      inc(compteur);
				      
				      {ne pas lire deux \ dans les sequences du genre \\\[ }
		          if (c = '\') & (avantDernierCaractereLu = '\') then
		            begin
		              dernierCaractereLu := chr(0);
		              avantDernierCaractereLu := chr(0);
		            end;
				    end;
		      
		      c := GetNextChar(false);
		    end;
		    
		    if (c=']') & (avantDernierCaractereLu <> '\')
		      then AddStringToTexteProperty(prop,s)
		      else AddStringToTexteProperty(prop,Concat(s,c));
		    
		  until ((c=']') & (avantDernierCaractereLu <> '\')) | 
		        (longueurTotaleDuTexte>=TailleMaximumDuTexte) | 
		        QuitterLecture;
		  
		  if (c<>']') & (avantDernierCaractereLu <> '\') then
		    repeat
		      c := GetNextChar(false);
		    until (c=']') | LectureSmartGameBoard.QuitterLecture;
		end;
  
end;


function ReadTexteProperty(genre : SInt16; TailleMaximumDuTexte : SInt32) : Property;
var aux : Property;
begin
  aux := MakeTexteProperty(genre,NIL,0);
  ReadArgumentOfTexteProperty(aux,TailleMaximumDuTexte);
  ReadTexteProperty := aux;
end;

function ReadRapportProperty(genre : SInt16) : Property;
var aux : Property;
    textePtr : Ptr;
    longueurTexte,ancienPointDInsertion : SInt32;
    fichier : FichierTEXT;
begin
  aux := MakeTexteProperty(RapportProp,NIL,0);
  ReadArgumentOfTexteProperty(aux,32500);
  GetTexteOfProperty(aux,textePtr,longueurTexte);
  ancienPointDInsertion := GetPositionPointDinsertion();
  InsereTexteDansRapport(textePtr,longueurTexte);
  if GetFichierTEXTOfZoneMemoirePtr(@LectureSmartGameBoard.TheZoneMemoire,fichier) = NoErr then
    begin
      AppliquerStyleDuFichierAuRapport(fichier,ancienPointDInsertion,GetPositionPointDinsertion());
      WritelnDansRapport('');
    end;
  if (genre = GameCommentProp) & (longueurTexte > 0) & (longueurTexte < 500) 
    then ReadRapportProperty := MakeTexteProperty(GameCommentProp,textePtr,longueurTexte)
    else ReadRapportProperty := MakeEmptyProperty();
  
  DisposePropertyStuff(aux);
end;

function ReadUnknownProperty(propertyName : string) : Property;
var prop : Property;
    c : char;
begin
  prop := MakeTexteProperty(VerbatimProp,NIL,0);
  AddStringToTexteProperty(prop,concat(propertyName,'['));
  repeat
    ReadArgumentOfTexteProperty(prop,32050);
    c := GetNextChar(true);
    RevientEnArriereDansFichier(1);
    if c='[' then AddStringToTexteProperty(prop,']');
  until (c<>'[') | (prop.Taille>=32000);
  AddStringToTexteProperty(prop,']');
  ReadUnknownProperty := prop;
end;
  

function LitProperty() : Property;
var prop : Property;
    compteur : SInt16; 
    nomProperty : str255;    
    PropertyGenre : SInt16; 
    textePropertyNonReconnue : Ptr;
    longueurPropertyNonReconnue : SInt32;
    c : char;
begin
  nomProperty := '';
  compteur := 0;
  repeat
    c := GetNextChar(true);
    {WritelnDansRapport('LitProperty : lecture de '+c+ ' ( code ascii = '+NumEnString(ord(c))+')');
    }
    if (c <> '[') then 
      begin
        nomProperty := nomProperty+c;
        inc(compteur);
      end;
  until (c = '[') | (c = ']') | (compteur>=10);
  
  {WritelnDansRapport('LitProperty : nomProperty='+nomProperty);}

  
  if (compteur >= 10) | (c = ']') then
    begin
      if debuggage.lectureSmartGameBoard then
        AlerteSimple('erreur dans la reconnaissance du nom de la propriété : '+nomProperty);
      LitProperty := MakeEmptyProperty();
      exit(LitProperty);
    end;
  
  PropertyGenre := StringToPropertyGenre(nomProperty);
  
  if (PropertyGenre = UnknowProp) 
    then PropertyGenre := StringToPropertyGenre(UpCaseStr(nomProperty));
  
  case PropertyGenre of
    BlackMoveProp              : prop := ReadSquareProperty(PropertyGenre);
    WhiteMoveProp              : prop := ReadSquareProperty(PropertyGenre);
    CommentProp                : prop := ReadTexteProperty(PropertyGenre,10000);
    NodeNameProp               : prop := ReadStringProperty(PropertyGenre);
    NodeValueProp              : prop := ReadOthelloValueProperty(PropertyGenre,true);
    CheckMarkProp              : prop := ReadTripleProperty(PropertyGenre);
    GoodForBlackProp           : prop := ReadTripleProperty(PropertyGenre);
    GoodForWhiteProp 	         : prop := ReadTripleProperty(PropertyGenre);
    TesujiProp                 : prop := ReadTripleProperty(PropertyGenre);
    BadMoveProp                : prop := ReadTripleProperty(PropertyGenre);
    TimeLeftBlackProp          : prop := ReadRealProperty(PropertyGenre);
    TimeLeftWhiteProp          : prop := ReadRealProperty(PropertyGenre);
    FigureProp                 : prop := ReadArgumentVideProperty(PropertyGenre);
    AddBlackStoneProp          : prop := ReadSquareSetProperty(PropertyGenre);
    AddWhiteStoneProp          : prop := ReadSquareSetProperty(PropertyGenre);
    RemoveStoneProp            : prop := ReadSquareSetProperty(PropertyGenre);
    PlayerToPlayFirstProp      : prop := ReadCharProperty(PropertyGenre);
    
    GameNameProp               : prop := ReadStringProperty(PropertyGenre);
   {GameCommentProp            : prop := ReadTexteProperty(PropertyGenre,10000);}
    GameCommentProp            : prop := ReadRapportProperty(PropertyGenre);
    EventProp                  : prop := ReadStringProperty(PropertyGenre);
    RoundProp                  : prop := ReadStringProperty(PropertyGenre);
    DateProp                   : prop := ReadStringProperty(PropertyGenre);
    PlaceProp                  : prop := ReadStringProperty(PropertyGenre);
    BlackPlayerNameProp        : prop := ReadStringProperty(PropertyGenre);
    WhitePlayerNameProp        : prop := ReadStringProperty(PropertyGenre);
    ResultProp                 : prop := ReadStringProperty(PropertyGenre);
    UserProp                   : prop := ReadStringProperty(PropertyGenre);
    TimeLimitByPlayerProp      : prop := ReadStringProperty(PropertyGenre);
    SourceProp                 : prop := ReadStringProperty(PropertyGenre);
    
    GameNumberIDProp           : prop := ReadLongintProperty(PropertyGenre);
    BoardSizeProp              : prop := ReadLongintProperty(PropertyGenre);
    PartialViewProp            : prop := ReadSquareSetProperty(PropertyGenre);
    BlackSpeciesProp           : prop := ReadLongintProperty(PropertyGenre);
    WhiteSpeciesProp           : prop := ReadLongintProperty(PropertyGenre);
    ComputerEvaluationProp     : prop := ReadOthelloValueProperty(PropertyGenre,false);
    ZebraBookProp              : prop := ReadOthelloValueProperty(PropertyGenre,false);
    ExpectedNextMoveProp       : prop := ReadSquareProperty(PropertyGenre);

    SelectedPointsProp         : prop := ReadSquareSetProperty(PropertyGenre);
    MarkedPointsProp           : prop := ReadSquareSetProperty(PropertyGenre);
    LabelOnPointsProp          : prop := ReadSquareSetProperty(PropertyGenre);
    
    BlackRankProp              : prop := ReadStringProperty(PropertyGenre);
    WhiteRankProp              : prop := ReadStringProperty(PropertyGenre);
    HandicapProp               : prop := ReadLongintProperty(PropertyGenre);
    KomiProp                   : prop := ReadRealProperty(PropertyGenre);
    
    BlackTerritoryProp         : prop := ReadSquareSetProperty(PropertyGenre);
    WhiteTerritoryProp         : prop := ReadSquareSetProperty(PropertyGenre);
    SecureStonesProp           : prop := ReadSquareSetProperty(PropertyGenre);
    RegionOfTheBoardProp       : prop := ReadSquareSetProperty(PropertyGenre);
    
    PerfectScoreProp           : prop := ReadOthelloValueProperty(PropertyGenre,true);
    OptimalScoreProp           : prop := ReadOthelloValueProperty(PropertyGenre,true);
    EmptiesForOptimalScoreProp : prop := ReadLongintProperty(PropertyGenre);
    
    DeltaWhiteProp             : prop := ReadSquareSetProperty(PropertyGenre);
    DeltaBlackProp             : prop := ReadSquareSetProperty(PropertyGenre);
    DeltaProp                  : prop := ReadSquareSetProperty(PropertyGenre);
    LosangeWhiteProp           : prop := ReadSquareSetProperty(PropertyGenre);
    LosangeBlackProp           : prop := ReadSquareSetProperty(PropertyGenre);
   {LosangeProp                : prop := ReadSquareSetProperty(PropertyGenre);
    CarreWhiteProp             : prop := ReadSquareSetProperty(PropertyGenre);
    CarreBlackProp             : prop := ReadSquareSetProperty(PropertyGenre);}
    CarreProp                  : prop := ReadSquareSetProperty(PropertyGenre);
    EtoileProp                 : prop := ReadSquareSetProperty(PropertyGenre);
    PetitCercleWhiteProp       : prop := ReadSquareSetProperty(PropertyGenre);
    PetitCercleBlackProp       : prop := ReadSquareSetProperty(PropertyGenre);
    PetitCercleProp            : prop := ReadSquareSetProperty(PropertyGenre);
    TranspositionProp          : prop := ReadStringProperty(PropertyGenre);
    RapportProp                : prop := ReadRapportProperty(PropertyGenre);
    BlackPassProp              : prop := ReadArgumentVideProperty(PropertyGenre);
    WhitePassProp              : prop := ReadArgumentVideProperty(PropertyGenre);
    ValueMinProp               : prop := ReadLongintProperty(PropertyGenre);
    ValueMaxProp               : prop := ReadLongintProperty(PropertyGenre);
    SigmaProp                  : prop := ReadTripleProperty(PropertyGenre);
    TimeTakenProp              : prop := ReadRealProperty(PropertyGenre);
    
    WhiteTeamProp              : prop := ReadStringProperty(PropertyGenre);
    BlackTeamProp              : prop := ReadStringProperty(PropertyGenre);
    OpeningNameProp            : prop := ReadStringProperty(PropertyGenre);
    FileFormatProp             : prop := ReadLongintProperty(PropertyGenre);
    FlippedProp                : prop := ReadSquareSetProperty(PropertyGenre);
    DrawMarkProp               : prop := ReadTripleProperty(PropertyGenre);
    InterestingMoveProp        : prop := ReadArgumentVideProperty(PropertyGenre);
    DubiousMoveProp            : prop := ReadArgumentVideProperty(PropertyGenre);
    ExoticMoveProp             : prop := ReadArgumentVideProperty(PropertyGenre);
    UnclearPositionProp        : prop := ReadTripleProperty(PropertyGenre);
    DepthProp                  : prop := ReadLongintProperty(PropertyGenre);
    
    {propriétés définies dans SGF FF[4]}
    HotSpotProp                : prop := ReadLongintProperty(PropertyGenre);
    PDProp                     : prop := ReadLongintProperty(PropertyGenre);
    ApplicationProp            : prop := ReadStringProperty(PropertyGenre);
    CharSetProp                : prop := ReadStringProperty(PropertyGenre);
    StyleOfDisplayProp         : prop := ReadLongintProperty(PropertyGenre);
    DimPointsProp              : prop := ReadSquareSetProperty(PropertyGenre);
    CopyrightProp              : prop := ReadStringProperty(PropertyGenre);
    AnnotatorProp              : prop := ReadStringProperty(PropertyGenre);
    ArrowProp                  : prop := ReadSquareCoupleProperty(PropertyGenre);
    LineProp                   : prop := ReadSquareCoupleProperty(PropertyGenre);
    
    otherwise  
      begin
       {prop := MakeEmptyProperty();
        argumentPropertyNonReconnue := LitArgumentOfPropertyEnChaine(false);}
        
        prop := ReadUnknownProperty(nomProperty);
        
        WritelnDansRapport('erreur : lecture d''une propriété inconnue !!');
        WritelnDansRapport('nomProperty = '+nomProperty);
        GetTexteOfProperty(prop,textePropertyNonReconnue,longueurPropertyNonReconnue);
        InsereTexteDansRapport(textePropertyNonReconnue,longueurPropertyNonReconnue);
        WritelnDansRapport('');
      end;
  end;   {case}
  
  if debuggage.lectureSmartGameBoard then
    WritelnStringAndPropertyDansRapport('prop=',prop);

  {on saute les proprietes Sigma[3] qui denotent des noeuds "virtuels"}
  (* if (prop.genre = SigmaProp) & (GetTripleOfProperty(prop).nbTriples >= 3)
    then 
      begin
        DisposePropertyStuff(prop);
        LitProperty := MakeEmptyProperty();
      end
    else *)
      LitProperty := prop; 
end;


procedure LitEtAjoutePropertyListACeNoeud(var G : GameTree);
var prop : Property;
    c : char;
    separateurDeNoeuds : boolean;
    separateurDeGameTree : boolean;
begin
  repeat
    c := GetNextChar(true);
    separateurDeNoeuds := (c=';');
    separateurDeGameTree := (c='(') | (c=')');
    RevientEnArriereDansFichier(1);
    if not(separateurDeNoeuds | separateurDeGameTree) then
      begin
        prop := LitProperty();
        if not(PropertyEstVide(prop)) then AddPropertyToGameTree(prop,G);
        DisposePropertyStuff(prop);
      end;
  until separateurDeNoeuds | separateurDeGameTree | LectureSmartGameBoard.QuitterLecture;
end;


function LitPropertyList() : PropertyList;
var result : PropertyList;
    prop : Property;
    c : char;
    separateurDeNoeuds : boolean;
    separateurDeGameTree : boolean;
begin
  result := NIL;
  
  repeat
    
    c := GetNextChar(true);
    separateurDeNoeuds := (c=';');
    separateurDeGameTree := (c='(') | (c=')');
    
    RevientEnArriereDansFichier(1);
    
    if not(separateurDeNoeuds | separateurDeGameTree) then
      begin
        
        prop := LitProperty();
        
        if not(PropertyEstVide(prop)) then 
          begin
            if result = NIL then result := NewPropertyList();
            AddPropertyToList(prop,result);
          end;
        
        DisposePropertyStuff(prop);
      end;
  until separateurDeNoeuds | separateurDeGameTree | LectureSmartGameBoard.QuitterLecture;
  
  
  CompacterPropertyList(result);
  
  
  LitPropertyList := result;
end;

procedure LectureRecursiveArbre(ArbreDerniereParenthese : GameTree;peutCreerLesSousArbres : boolean);
var c : char;
    propSpeciale : Property;
    G,subtree : GameTree;
    propertiesLues : PropertyList;
    coup : PropertyPtr;
    fils : GameTree;
    positionEtTraitDerniereParenthese : PositionEtTraitRec;
    profondeurDerniereParenthese : SInt32;
    oldPositionInitiale,newPositionInitiale : PositionEtTraitRec;
    jeu : plateauOthello;
    trait,whichSquare : SInt32;
    numeroPremierCoup,nbBlancsInitial,nbNoirsInitial : SInt32;
begin
  
  with LectureSmartGameBoard do
    begin
      if debuggage.lectureSmartGameBoard then
		     WritelnDansRapport('entree dans LectureRecursiveArbre');
		  
		  positionEtTraitDerniereParenthese := thePosition;
		  profondeurDerniereParenthese := profondeur;
		  
		  if not(QuitterLecture) then
		    repeat
		      c := GetNextChar(true);
		      
		      if debuggage.lectureSmartGameBoard then
		        begin
		         {WriteDansRapport('LectureRecursiveArbre : ');}
		          WriteDansRapport('analyse de '+c);
		         {WriteDansRapport(' (code ascii = '+NumEnString(ord(c))+')');}
		          WriteDansRapport(' : ');
		        end;
		      case c of
		        '(' : begin
		                inc(EmboitementParentheses);
		                if debuggage.lectureSmartGameBoard then
		                  WritelnDansRapport('appel résursif de LectureRecursiveArbre');
		                LectureRecursiveArbre(GetCurrentNode(),peutCreerLesSousArbres);
		              end;
		        ';' : begin {A}
		                if not(peutCreerLesSousArbres)
		                  then
		                    begin {B}
		                      PropertiesLues := LitPropertyList();
		                      WritelnStringAndPropertyListDansRapport('Proprietes sautées = ',PropertiesLues);
		                      DisposePropertyList(propertiesLues);  
		                    end   {B}
		                  else
		                    begin {B}
					                G := GetCurrentNode();
					                if EstLaRacineDeLaPartie(G) & not(ProprietesDeLaRacinesDejaLues)
					                  then
					                    begin {C}
					                      if debuggage.lectureSmartGameBoard then
					                        WritelnDansRapport('lecture des propriétés de la racine');
					                        
					                  {   WritelnDansRapport('•••••••••• DEBUT DE LA LECTURE DES PROPS DE LA RACINE •••••••••••');  }
					                        
					                      PropertiesLues := LitPropertyList();
					                      
					                  {    WritelnDansRapport('•••••••••• FIN DE LA LECTURE DES PROPS DE LA RACINE •••••••••••');  }
					                      
					                      GetPositionInitialeOfGameTree(jeu,numeroPremierCoup,trait,nbBlancsInitial,nbNoirsInitial);
					                      oldPositionInitiale := MakePositionEtTrait(jeu,trait);
					                      
					                      if CalculeNouvellePositionInitialeFromThisList(PropertiesLues,jeu,numeroPremierCoup,trait,nbBlancsInitial,nbNoirsInitial)
					                        then
					                          begin {D}
					                            newPositionInitiale := MakePositionEtTrait(jeu,trait);
					                            if not(SamePositionEtTrait(newPositionInitiale,oldPositionInitiale))
					                              then
					                                begin {E}
					                                  if debuggage.lectureSmartGameBoard then
					                                    WritelnDansRapport('positions initiales differentes : destruction de l''ancien arbre de jeu');
					                                  DeleteAllSons(G);
					                                  DisposePropertyList(G^.properties);
					                                  VideTableHashageInterversions;
					                                  avecAlerteSoldeCreationDestructionNonNul := false;
					                                  PlaquerPosition(jeu,trait,kRedessineEcran);
					                                  avecAlerteSoldeCreationDestructionNonNul := true;
					                                end {E}
					                              else
					                                begin {E}
					                                  if debuggage.lectureSmartGameBoard then
					                                    WritelnDansRapport('les positions initiales sont les memes');
					                                end; {E}
					                          end  {D}
					                        else
					                          begin {D}
					                            newPositionInitiale := oldPositionInitiale;
					                          end;  {D}
					                      thePosition := newPositionInitiale;
					                      
					                      
					                      ConcatPropertyLists(G^.properties,propertiesLues,AllPropertyTypes() - TypesPierresDelta(),[]);
					                      CalculePositionInitialeFromThisRoot(G);
					                      ProprietesDeLaRacinesDejaLues := true;
					                      
					                      DisposePropertyList(propertiesLues);  
					                      
					                   {   WritelnDansRapport('•••••••••• FIN DE L''UTILISATION DES PROPS DE LA RACINE •••••••••••');  }
					                      
					                    end  {C}
					                  else
					                    begin  {C}
					                    
					                      if debuggage.lectureSmartGameBoard then
						                      WritelnDansRapport('lecture des propriétés du prochain noeud');
					                      
					                      inc(profondeur);
					                      
					                   {  WritelnDansRapport('•••••••••• DEBUT DE LA LECTURE D''UNE NOUVELLE LISTE DE PROPS •••••••••••');  }
					                      
					                      propertiesLues := LitPropertyList();
					                   
					                   {  WritelnStringAndPropertyListDansRapport('•••••••••• FIN DE LA LECTURE D''UNE NOUVELLE LISTE DE PROPS ••••••••••• = ',propertiesLues);  }	
					                      
					                      coup := SelectFirstPropertyOfTypes([BlackMoveProp,WhiteMoveProp],propertiesLues);
					                      
					                      if (coup = NIL)
					                        then
					                          begin  {nouveau fils sans coup !} {D}
					                            if PropertyListEstVide(propertiesLues) |
					                               (PropertyListLength(propertiesLues)=1) & InPropertyTypes(propertiesLues^.head.genre,[BlackPassProp,WhitePassProp])
					                              then
					                                begin  {E}
					                                  (*
					                                  AlerteSimple('Il y a des passes ou des noeuds vides dans ce fichier, je les ignore… (et je modifie donc la structure de l''arbre de Smart Othello Board, mais c''est pas grave)');
					                                  *)
					                                  DisposePropertyList(propertiesLues);  
					                                end  {E}
					                              else
					                                begin {E}
								                            if debuggage.lectureSmartGameBoard then
								                              WritelnDansRapport('création d''un nouveau sous-arbre sans coup');
								                            
								                            WritelnDansRapport('erreur : lecture d''un noeud sans coup dans le fichier !!');
								                            WritelnStringAndPropertyListDansRapport('La liste des proprietes du noeud en question est : ',propertiesLues);
								                            
								                            propSpeciale := MakeArgumentVideProperty(MarquageProp);
								                            AddPropertyToList(propSpeciale,propertiesLues);
								                            subTree := MakeGameTreeFromPropertyList(propertiesLues);
								                            AddSonToGameTree(subTree,G);
								                            SetCurrentNode(SelectFirstSubtreeWithThisProperty(propSpeciale,G));
								                            DeletePropertyFromGameNode(propSpeciale,GetCurrentNode());
								                            DisposePropertyStuff(propSpeciale);
								                            DisposeGameTree(subTree);
								                            DisposePropertyList(propertiesLues);  

					                                end; {E}
					                          end {D}
					                        else
					                          begin  {D}
					                            whichSquare := GetOthelloSquareOfProperty(coup^);
					                            if (whichSquare = CoupSpecialPourPasse)
					                              then
					                                begin  {E}
					                                  (*
					                                  AlerteSimple('Il y a des passes dans ce fichier, je les ignore… (et je modifie donc la structure de l''arbre de Smart Othello Board, mais c''est pas grave)')}
					                                  *)
					                                end  {E}
					                              else
					                                begin {E}
					                                
								                            if not(PlayMoveProperty(coup^,thePosition)) then
								                              begin  {F}
								                                AlerteSimple('Coup illégal dans le fichier !! Je saute le sous-arbre correspondant !! Voyez la ligne fautive dans rapport si vous voulez corriger le fichier avec Smart Othello Board.');
								                                WritelnDansRapport('Erreur : coup illégal dans le fichier !!');
								                                WritelnStringAndPropertyListDansRapport('La liste des proprietes du noeud avec le coup illegal est : ',propertiesLues);
								                                WritelnDansRapport('chemin courant menant au coup illégal = '+CoupsDuCheminJusquauNoeudEnString(GetCurrentNode()));
								                                DisposePropertyList(propertiesLues);
								                                
								                                peutCreerLesSousArbres := false;
								                              end;  {F}
								                              
								                            if peutCreerLesSousArbres then
								                              begin  {F}
								                              
								                                fils := SelectFirstSubtreeWithThisProperty(coup^,G);
										                            
										                            if fils = NIL
										                              then  {nouveau coup : on crée un nouveau fils}
										                                begin  {G}
										                                  
										                                  if debuggage.lectureSmartGameBoard then
										                                    WritelnDansRapport('création d''un nouveau sous-arbre pour le coup '+PropertyToString(coup^));
										                                    
										                                  {CompacterPropertyList(propertiesLues);}
													                            
													                            subTree := MakeGameTreeFromPropertyListSansDupliquer(propertiesLues);
													                            AddSonToGameTreeSansDupliquer(subTree,G);
													                            SetCurrentNode(subTree);
													                            
													                            if avecInterversions & (profondeur >= 1) &
														                             (profondeur <= numeroCoupMaxPourRechercheIntervesionDansArbre) then
														                            GererInterversionDeCeNoeud(GetCurrentNode(),thePosition);
													                            
										                                end  {G}
										                              else
										                                begin  {coup deja existant}  {G}
										                                  
										                                  if debuggage.lectureSmartGameBoard then
										                                    WritelnDansRapport('ajouts des propriétés au sous-arbre du coup '+PropertyToString(coup^));
										                                  ConcatPropertyLists(fils^.properties,propertiesLues,[],[NodeValueProp,GoodForBlackProp,GoodForWhiteProp]);
										                                  SetCurrentNode(fils);
										                                  DisposePropertyList(propertiesLues); 
										                                  
										                                end;  {G}
										                          end; {F}
								                          end; {E}
					                          end; {D}
					                          
					                   {  WritelnStringAndPropertyListDansRapport('•••••••••• FIN DE L''UTILISATION DE LA LISTE DU COUP •••••••••••',PropertiesLues);  }
					                      
					                      
					                    end;  {C}
					             end; {B}
					        end;  {A}
		        ')' : begin
		                if debuggage.lectureSmartGameBoard then
		                  WritelnDansRapport('retour a ArbreDerniereParenthese');
		                  
		                dec(EmboitementParentheses);
		                SetCurrentNode(ArbreDerniereParenthese);
		                thePosition := positionEtTraitDerniereParenthese;
		                profondeur := profondeurDerniereParenthese;
		                
		                if debuggage.lectureSmartGameBoard then
		                  WritelnDansRapport('sortie de LectureRecursiveArbre');
		                exit(LectureRecursiveArbre);
		              end;
		         otherwise 
		               WritelnDansRapport('erreur : caractere non traité = '+c+ ' (code ascii='+NumEnString(ord(c))+')');
		      end; {case}
		      
		    until (EmboitementParentheses <= 0) | QuitterLecture;
	  end;
end;


procedure LitFormatSmartGameBoard(G : GameTree;whichZoneMemoire : ZoneMemoire);
var TaillePlusGrandBloc,grow:Size;
    temp : boolean;
    tickDepart : SInt32;
begin {$UNUSED tickDepart}

  temp := gEnEntreeSortieLongueSurLeDisque;
  gEnEntreeSortieLongueSurLeDisque := true;
  
  {on compacte la memoire}
  TaillePlusGrandBloc := MaxMem(grow);
  
  {$IFC USE_PROFILER_SMART_GAME_BOARD}
  if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr 
    then ProfilerSetStatus(1);
  {$ENDC}
  
  {$IFC UTILISE_MINIPROFILER_LECTURE_SMART_GAME_BOARD}
  tickDepart := TickCount();
  InitMiniProfiler;
  {$ENDC}

  with LectureSmartGameBoard do
    begin
      TheZoneMemoire                 := whichZoneMemoire;
      QuitterLecture                 := false;
      dernierCaractereLu             := chr(0);
      avantDernierCaractereLu        := chr(0);
      compteurCaracteres             := 0;
      EmboitementParentheses         := 0;
      profondeur                     := 0;
      thePosition                    := MakeEmptyPositionEtTrait();
      ProprietesDeLaRacinesDejaLues  := false;
      MemoryFillChar(@buffer,sizeof(buffer),chr(0));
      premierOctetDansBuffer         := -1;
      dernierOctetDansBuffer         := -1;
    end;
  
  
  LectureRecursiveArbre(G,true);
  
  LectureSmartGameBoard.compteurCaracteres := 0;
  

  {$IFC UTILISE_MINIPROFILER_LECTURE_SMART_GAME_BOARD}
  AfficheMiniProfilerDansRapport(kpourcentage+ktempsMoyen);
  WritelnSoldesCreationsPropertiesDansRapport('');
  WritelnStringAndNumDansRapport('temps de lecture Smart Game Board en ticks = ',TickCount()-tickDepart);
  {$ENDC}
  
  {$IFC USE_PROFILER_SMART_GAME_BOARD}
  nomFichierProfileSmartGameBoard := 'lecture_smart_' + NumEnString(Tickcount() div 60) + '.profile';
  WritelnDansRapport('nomFichierProfileSmartGameBoard = '+nomFichierProfileSmartGameBoard);
  if ProfilerDump(nomFichierProfileSmartGameBoard) <> NoErr 
    then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfileSmartGameBoard+') a échoué !')
    else ProfilerSetStatus(0);
  ProfilerTerm;
  {$ENDC}
 
  gEnEntreeSortieLongueSurLeDisque := temp;
end;




function EstUneZoneMemoireAuFormatSmartGameBoard(whichZoneMemoire : ZoneMemoire) : boolean;
var c1,c2 : char;
    oldPosition : SInt32;
begin
  
  if not(ZoneMemoireEstCorrecte(whichZoneMemoire)) then
    begin
      EstUneZoneMemoireAuFormatSmartGameBoard := false;
      exit(EstUneZoneMemoireAuFormatSmartGameBoard);
    end;

  with LectureSmartGameBoard do
    begin
      TheZoneMemoire                 := whichZoneMemoire;
      QuitterLecture                 := false;
      dernierCaractereLu             := chr(0);
      avantDernierCaractereLu        := chr(0);
      CompteurCaracteres             := 0;
      EmboitementParentheses         := 0;
      profondeur                     := 0;
      ProprietesDeLaRacinesDejaLues  := false;
      MemoryFillChar(@buffer,sizeof(buffer),chr(0));
      premierOctetDansBuffer         := -1;
      dernierOctetDansBuffer         := -1;
    end;
    
    
  oldPosition := whichZoneMemoire.position;
  c1 := GetNextChar(true);
  c2 := GetNextChar(true);
  if SetPositionMarqueurZoneMemoire(whichZoneMemoire,oldPosition)=NoErr then;
  
  EstUneZoneMemoireAuFormatSmartGameBoard := (c1='(') & (c2=';');
end;


function EstUnFichierAuFormatSmartGameBoard(nomFichier : str255;vRefNum : SInt16) : boolean;
var theZone : ZoneMemoire;
begin
  theZone := MakeZoneMemoireFichier(nomFichier,vRefNum);
  EstUnFichierAuFormatSmartGameBoard := EstUneZoneMemoireAuFormatSmartGameBoard(theZone);
  if ZoneMemoireEstCorrecte(theZone) then DisposeZoneMemoire(theZone);
end;


{Ecriture au format SmartGameBoard}

function EcrireAvecProtectionCaracteresStructureSGF(text : Ptr; var nbOctets : SInt32) : OSErr;
var i : SInt32;
    c : char;
    table : PackedArrayOfCharPtr;
    err : OSErr;
    s : str255;
    longueur : SInt32;
begin
  
  with EcritureSmartGameBoard do
    begin
      {InsereTexteDansRapport(text,nbOctets);}
      table := PackedArrayOfCharPtr(text);
		  for i := 0 to nbOctets-1 do
		    begin
		      c := table^[i];
		      case c of
		        '[',']',';','(',')','\'  :
		           begin
		             s := Concat('\',c);
		             longueur := 2;
		             {WriteDansRapport(s);}
		             err := EcrireZoneMemoire(TheZoneMemoire,-1,@s[1],longueur);
		           end;
		         otherwise  
		           begin
		             (* attention ! A cause d'un bug dans la library Pascal de CodeWarrior,
		                l'affectation s := StringOf(c)  ne marche pas si "c" est le 
		                caractere nul, il faut donc fabriquer la chaine a la main   *)
		             
		             s[0] := chr(1);
		             s[1] := c;
		             
		             longueur := 1;
		             {WriteDansRapport(s);}
		             err := EcrireZoneMemoire(TheZoneMemoire,-1,@s[1],longueur);
		           end;
		      end; {case}
		    end;
		  {WritelnDansRapport('');}
		end;
  
  EcrireAvecProtectionCaracteresStructureSGF := err;
  
end;

procedure EcritProperty(var prop : Property; var positionCurseurEcriture : SInt32; var continuer : boolean);
var propName : str255;
    propValue : str255;
    err : OSErr;
    textePtr : Ptr;
    longueurTexte : SInt32;
begin
  if not(PropertyEstVide(prop)) then
    with EcritureSmartGameBoard do
      begin
        if prop.genre=VerbatimProp then
          begin
            GetTexteOfProperty(prop,textePtr,longueurTexte);
            err := EcrireZoneMemoire(TheZoneMemoire,-1,textePtr,longueurTexte);
            
            
            positionCurseurEcriture := TheZoneMemoire.position;
            continuer := (err=NoErr);
            exit(EcritProperty);
          end;
          
	      if prop.stockage=stockageEnTexte
	        then
	          begin
	            propName := PropertyTypeToString(prop.genre);
	            GetTexteOfProperty(prop,textePtr,longueurTexte);
	            
				      err := WriteDansZoneMemoire(TheZoneMemoire,propName+'[');
				      err := EcrireAvecProtectionCaracteresStructureSGF(textePtr,longueurTexte);
				      err := WriteDansZoneMemoire(TheZoneMemoire,']');
				      
				      positionCurseurEcriture := TheZoneMemoire.position;
				      continuer := (err=NoErr);
	          end
	        else
	          begin
	            propName := PropertyTypeToString(prop.genre);
				      propValue := PropertyValueToString(prop);
				      
				      err := WriteDansZoneMemoire(TheZoneMemoire,propName);
				      
				      if (prop.stockage = StockageEnStr255) 
				        then
				          begin
				            longueurTexte := Length(propValue) - 2;
				            err := WriteDansZoneMemoire(TheZoneMemoire,'[');
				            err := EcrireAvecProtectionCaracteresStructureSGF(@propValue[2],longueurTexte);
				            err := WriteDansZoneMemoire(TheZoneMemoire,']');
				          end
				        else
				          begin
				            err := WriteDansZoneMemoire(TheZoneMemoire,propValue);
				          end;
				      
				      
				      positionCurseurEcriture := TheZoneMemoire.position;
				      continuer := (err=NoErr);
	          end;
      end;
end;

procedure EcritPropertyList(L : PropertyList);
begin
  if (L <> NIL) then
    with EcritureSmartGameBoard do
      ForEachPropertyOfTheseTypesDoAvecResult(L,typesDePropertyAEcrire,EcritProperty,compteurCaracteres);
end;


procedure EcritureRecursiveParenthesesEtArbre(var G : GameTree);forward; {pour gerer les fonctions mutuellement recursives}


procedure EcritureRecursiveArbre(var G : GameTree);
var err : OSErr;
    i : SInt16; 
begin
  if (G <> NIL) then
    with EcritureSmartGameBoard do
    begin
    
      (* un petit peu de formatage : on rajoute des espaces et 
         et sauts de ligne pour faciliter l'edition du fichier *)
      if AvecPrettyPrinter then
	      if (GetCouleurOfMoveInNode(G) = pionNoir) then
	        begin
	          inc(CompteurDeCoupsNoirsEcrits);
	          if CompteurDeCoupsNoirsEcrits >= 3 then
	            begin
	              err := WritelnDansZoneMemoire(TheZoneMemoire,'');
	              inc(CompteurCaracteres);
	              
	              for i := 1 to EmboitementParentheses do
	                begin
	                  err := WriteDansZoneMemoire(TheZoneMemoire,' ');
	                  inc(CompteurCaracteres);
	                end;
	              
	              CompteurDeCoupsNoirsEcrits := 0;
	            end;
	        end;
        
      (* et maintenant la vraie ecriture au format SGF *)
      err := WriteDansZoneMemoire(TheZoneMemoire,';');
      inc(CompteurCaracteres);
      
      EcritPropertyList(G^.properties);
      if NumberOfSons(G) <= 1
        then
          begin
            ForEachGameTreeInListDo(G^.sons,EcritureRecursiveArbre);
          end
        else
          begin
            ForEachGameTreeInListDo(G^.sons,EcritureRecursiveParenthesesEtArbre);
          end;
    end;
end;


procedure EcritureRecursiveParenthesesEtArbre(var G : GameTree);
var err : OSErr;
    i : SInt32;
begin
  with EcritureSmartGameBoard do
    begin
      CompteurDeCoupsNoirsEcrits := 0;
      
		  err := WritelnDansZoneMemoire(TheZoneMemoire,'');
		  inc(CompteurCaracteres);
		  
		  (* formatage *)
		  if AvecPrettyPrinter then
			  for i := 1 to EmboitementParentheses do
	        begin
	          err := WriteDansZoneMemoire(TheZoneMemoire,' ');
	          inc(CompteurCaracteres);
	        end;
		  
		  err := WriteDansZoneMemoire(TheZoneMemoire,'(');
		  inc(CompteurCaracteres);
		  
		  inc(EmboitementParentheses);
		  EcritureRecursiveArbre(G);
		  dec(EmboitementParentheses);
		  
		  err := WriteDansZoneMemoire(TheZoneMemoire,')');
		  inc(CompteurCaracteres);
		end;
end;



procedure EcritFormatSmartGameBoard(G : GameTree; var whichZoneMemoire : ZoneMemoire);
begin
  with EcritureSmartGameBoard do
    begin
      TheZoneMemoire                   := whichZoneMemoire;
      QuitterEcriture                  := false;
      DernierCaractereEcrit            := chr(0);
      compteurCaracteres               := 0;
      EmboitementParentheses           := 0;
      profondeur                       := 0;
      ProprietesDeLaRacinesDejaEcrites := false;
      AvecPrettyPrinter                := false;
      typesDePropertyAEcrire           := AllPropertyTypes() - [MarquageProp,PointeurPropertyProp,FinVarianteProp,EmbranchementProp,TranspositionRangeProp,ZebraBookProp(*,SigmaProp*)];
    end;
  EcritureRecursiveParenthesesEtArbre(G);
  
  EcritureSmartGameBoard.compteurCaracteres := 0;
end;


function GetPositionInitialeEtPartieDansFichierSmartGameBoard(var fic : FichierTEXT; var posInitiale : PositionEtTraitRec; var coups : str255) : OSErr;
begin
  GetPositionInitialeEtPartieDansFichierSmartGameBoard := GetPositionInitialeEtPartieDansFichierSGF_ou_GGF_8x8(fic,kTypeFichierSGF,posInitiale,coups);
end;


procedure SauvegarderDatabaseOfRecentSGFFiles;
var filename : str255;
    erreurES : OSErr;
    fic : FichierTEXT;
    s : str255;
    i : SInt32;
begin
  filename := 'RecentSGFFilesList.txt';    
  erreurES := FichierTexteDeCassioExiste(filename,fic);
  if erreurES=fnfErr  {-43 => File not found}
    then erreurES := CreeFichierTexteDeCassio(fileName,fic);
  if erreurES=NoErr {le fichier de la liste des fichiers preference existe : on l'ouvre et on le vide}
    then 
      begin
        erreurES := OuvreFichierTexte(fic);
        erreurES := VideFichierTexte(fic);
      end;
  if erreurES <> 0 then exit(SauvegarderDatabaseOfRecentSGFFiles);
  
  for i := 1 to kMaxRecentSGFFiles do
    if (gDatabaseRecentSGFFiles[i].date <> '') & 
       (gDatabaseRecentSGFFiles[i].name <> '') then
      begin
        s := gDatabaseRecentSGFFiles[i].date + ' ' + gDatabaseRecentSGFFiles[i].name;
        erreurES := WritelnDansFichierTexte(fic,s);
      end;
  
  erreurES := FermeFichierTexte(fic);
end;


procedure LireDatabaseOfRecentSGFFiles;
var filename : str255;
    erreurES : OSErr;
    fic : FichierTEXT;
    s : str255;
    i,nbPrefFiles : SInt32;
begin

  for i := 1 to kMaxRecentSGFFiles do
    begin
      gDatabaseRecentSGFFiles[i].date := '';
      gDatabaseRecentSGFFiles[i].name := '';
    end;
      
  filename := 'RecentSGFFilesList.txt';    
  erreurES := FichierTexteDeCassioExiste(filename,fic);
  if erreurES=NoErr 
    then erreurES := OuvreFichierTexte(fic);
  if erreurES <> 0 then exit(LireDatabaseOfRecentSGFFiles);
  

  nbPrefFiles := 0;
  repeat
    erreurES := ReadlnDansFichierTexte(fic,s);
    if (s <> '') & (erreurES=NoErr) then
      begin
        inc(nbPrefFiles);
        Parser(s,gDatabaseRecentSGFFiles[nbPrefFiles].date,gDatabaseRecentSGFFiles[nbPrefFiles].name);
      end;
  until (nbPrefFiles >= kMaxRecentSGFFiles) | (erreurES<>NoErr) | EOFFichierTexte(fic,erreurES);
  
  erreurES := FermeFichierTexte(fic);
end;


procedure AjouterNomDansDatabaseOfRecentSGFFiles(const whichDate,whichName : str255);
var i,indexCourant : SInt32;
begin

  if not(EstUnNomDeFichierTemporaireDePressePapier(whichName)) then
    begin
    
      LireDatabaseOfRecentSGFFiles;

      {chercher quel enregistrement ecraser}
      indexCourant := kMaxRecentSGFFiles;
      for i := kMaxRecentSGFFiles downto 1 do
        if gDatabaseRecentSGFFiles[i].name = whichName then
          indexCourant := i;
      
      {placer le nom courant en tete}
      for i := indexCourant downto 2 do
        begin
          gDatabaseRecentSGFFiles[i].date := gDatabaseRecentSGFFiles[i-1].date;
          gDatabaseRecentSGFFiles[i].name := gDatabaseRecentSGFFiles[i-1].name;
        end;
      gDatabaseRecentSGFFiles[1].date := whichDate;
      gDatabaseRecentSGFFiles[1].name := whichName;
      
      SauvegarderDatabaseOfRecentSGFFiles;
    end;
end;


function FichierExisteDansDatabaseOfRecentSGFFiles(whichName : str255; var modificationDate : str255) : boolean;
var i : SInt32;
begin

  if (whichName <> '') & not(EstUnNomDeFichierTemporaireDePressePapier(whichName)) then
    begin
      LireDatabaseOfRecentSGFFiles;
      for i := 1 to kMaxRecentSGFFiles do
        if (gDatabaseRecentSGFFiles[i].name = whichName) then
          begin
            FichierExisteDansDatabaseOfRecentSGFFiles := true;
            modificationDate := gDatabaseRecentSGFFiles[i].date;
            exit(FichierExisteDansDatabaseOfRecentSGFFiles);
          end;
    end;
  
  FichierExisteDansDatabaseOfRecentSGFFiles := false;
  modificationDate := '';
end;


end.























