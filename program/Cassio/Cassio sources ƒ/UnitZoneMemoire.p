UNIT UnitZoneMemoire;




INTERFACE







USES UnitFichiersTEXT;


const BadZoneMemoire=0;
      ZoneMemoireEstFichier=1;
      ZoneMemoireEstPointeur=2;




type ZoneMemoirePtr = Ptr;

     EntreesSortieZoneMemoireProc = function(theZonePtr:ZoneMemoirePtr;text : Ptr;fromPos : SInt32; var nbOctets : SInt32) : OSErr;
     ZoneMemoireProc              = function(theZonePtr:ZoneMemoirePtr) : OSErr;
     ZoneMemoireLongintProc       = function(theZonePtr:ZoneMemoirePtr; var param : SInt32) : OSErr;
     
     
    
     ZoneMemoire = 
      record
        infos                  : Ptr;      {pointeur sur un fichier ou un adresse memoire (privé)}
        tailleMaximalePossible : SInt32;   {taille maximale possible}
        nbOctetsOccupes        : SInt32;   {taille occupee dans la zone }
        position               : SInt32;   {position du pointeur d'ecriture dans la zone}
        genre                  : SInt16;   {kZoneMemoireEstFichier ou kZoneMoireEstPointeur}
        zoneType               : OSType;
        zoneCreator            : OSType;
        Ecrire                 : EntreesSortieZoneMemoireProc; {fonction d'ecriture (privée) }
        Lire                   : EntreesSortieZoneMemoireProc; {fonction de lecture (privee)}
        Clear                  : ZoneMemoireProc;              {effacement de la zone (privée) }
        Fermer                 : ZoneMemoireProc;              {fonction de fermeture (privée) }
        SetPosition            : ZoneMemoireLongintProc;       {deplacement du marqueur}
      end;




{fonctions de creation et de destruction}
function NewEmptyZoneMemoire() : ZoneMemoire;
function MakeZoneMemoireFichier(nomFichier : str255;vrefNum : SInt16) : ZoneMemoire;
function MakeZoneMemoireEnMemoire(taille : SInt32) : ZoneMemoire;
function ZoneMemoireEstCorrecte(const theZone : ZoneMemoire) : boolean;
procedure DisposeZoneMemoire(var theZone : ZoneMemoire);


{fonctions d'ecriture}
{note : passer une valeur négative dans fromPos pour écrire à la fin de la zone mémoire}
function EcrireZoneMemoire(var theZone : ZoneMemoire;fromPos : SInt32;text : Ptr; var nbOctets : SInt32) : OSErr;
function WriteDansZoneMemoire(var theZone : ZoneMemoire;s : str255) : OSErr;
function WritelnDansZoneMemoire(var theZone : ZoneMemoire;s : str255) : OSErr;
function ViderZoneMemoire(var theZone : ZoneMemoire) : OSErr;


{fonctions de lecture}
{note : passer fromPos < 0 pour lire après les derniers octets lus/écrits}
function ReadFromZoneMemoire(var theZone : ZoneMemoire;FromPos : SInt32; var count : SInt32;buffer : Ptr) : OSErr;
function GetNextCharOfZoneMemoire(var theZone : ZoneMemoire; var c : char) : OSErr;
function ReadlnDansZoneMemoire(var theZone : ZoneMemoire; var s : str255) : OSErr;
function EOFZoneMemoire(var theZone : ZoneMemoire; var erreurES : OSErr) : boolean;


{gestion du marqueur}
function GetPositionMarqueurZoneMemoire(var theZone : ZoneMemoire) : SInt32;
function SetPositionMarqueurZoneMemoire(var theZone : ZoneMemoire;whichPosition : SInt32) : OSErr;
function RevientEnArriereDansZoneMemoire(var theZone : ZoneMemoire;nbOctets : SInt32) : OSErr;


{gestion du type et du createur}
function GetZoneType(var theZone : ZoneMemoire) : OSType;
function GetZoneCreator(var theZone : ZoneMemoire) : OSType;
procedure SetZoneType(var theZone : ZoneMemoire;whichType : OSType);
procedure SetZoneCreator(var theZone : ZoneMemoire;whichCreator : OSType);


{gestion d'acces au fichier si la zone memoire est un fichier}
function GetFichierTEXTOfZoneMemoirePtr(theZonePtr:ZoneMemoirePtr; var fic : FichierTEXT) : OSErr;
procedure FermerFichierEtFabriquerZoneMemoire(var fic : FichierTEXT; var theZone : ZoneMemoire);
procedure DisposeZoneMemoireEtOuvrirFichier(var fic : FichierTEXT; var theZone : ZoneMemoire);



IMPLEMENTATION







USES UnitServicesMemoire,MacErrors,MyTypes,MyMathUtils,UnitRapport;
 

function FonctionZoneMemoireBidon(theZonePtr:ZoneMemoirePtr) : OSErr;
begin
  {$UNUSED theZonePtr}
  FonctionZoneMemoireBidon := 0;
end;

function FonctionZoneMemoireLongintBidon(theZonePtr:ZoneMemoirePtr; var param : SInt32) : OSErr;
begin
  {$UNUSED theZonePtr,Param}
  FonctionZoneMemoireLongintBidon := 0;
end;

function FonctionEcritureBidon(theZonePtr:ZoneMemoirePtr;text : Ptr;fromPos : SInt32; var nbOctets : SInt32) : OSErr;
begin
  {$UNUSED theZonePtr,text,fromPos,nbOctets}
  FonctionEcritureBidon := 0;
end;


function GetZoneMemoireOfZoneMemoirePtr(theZonePtr:ZoneMemoirePtr; var theZone : ZoneMemoire) : OSErr;
begin
  if (theZonePtr = NIL)  then
    begin
      GetZoneMemoireOfZoneMemoirePtr := -1;
      exit(GetZoneMemoireOfZoneMemoirePtr);
    end;
  MoveMemory(theZonePtr,@theZone,sizeof(ZoneMemoire));
  GetZoneMemoireOfZoneMemoirePtr := NoErr;
end;



function GetFichierTEXTOfZoneMemoirePtr(theZonePtr:ZoneMemoirePtr; var fic : FichierTEXT) : OSErr;
var theZone : ZoneMemoire;
begin
  if GetZoneMemoireOfZoneMemoirePtr(theZonePtr,theZone)<>NoErr  then
    begin
      GetFichierTEXTOfZoneMemoirePtr := -1;
      exit(GetFichierTEXTOfZoneMemoirePtr);
    end;
  if (theZone.genre <> ZoneMemoireEstFichier) | (theZone.infos = NIL) then 
     begin
      GetFichierTEXTOfZoneMemoirePtr := -2;
      exit(GetFichierTEXTOfZoneMemoirePtr);
    end;
  MoveMemory(theZone.infos,@fic,sizeof(FichierTEXT));
  GetFichierTEXTOfZoneMemoirePtr := NoErr;
end;



function EcrireDansZoneMemoireFichier(theZonePtr:ZoneMemoirePtr;text : Ptr;fromPos : SInt32; var nbOctets : SInt32) : OSErr;
var Err : OSErr;
    fic : FichierTEXT;
begin
  Err := GetFichierTEXTOfZoneMemoirePtr(theZonePtr,fic);
  if Err<>NoErr then
    begin
      EcrireDansZoneMemoireFichier := Err;
      Exit(EcrireDansZoneMemoireFichier);
    end;
  if (fromPos >= 0)
    then Err := SetPositionTeteLectureFichierTexte(fic,fromPos)
    else Err := SetPositionTeteLectureFinFichierTexte(fic);
  if Err<>NoErr then
    begin
      EcrireDansZoneMemoireFichier := Err;
      Exit(EcrireDansZoneMemoireFichier);
    end;
  Err := WriteBufferDansFichierTexte(fic,text,nbOctets);
  EcrireDansZoneMemoireFichier := Err;
end;



function LireFromZoneMemoireFichier(theZonePtr:ZoneMemoirePtr;text : Ptr;fromPos : SInt32; var nbOctets : SInt32) : OSErr;
var Err : OSErr;
    fic : FichierTEXT;
    theZone : ZoneMemoire;
begin
  if GetZoneMemoireOfZoneMemoirePtr(theZonePtr,theZone)<>NoErr  then
    begin
      LireFromZoneMemoireFichier := -1;
      exit(LireFromZoneMemoireFichier);
    end;
  Err := GetFichierTEXTOfZoneMemoirePtr(theZonePtr,fic);
  if Err<>NoErr then
    begin
      LireFromZoneMemoireFichier := Err;
      Exit(LireFromZoneMemoireFichier);
    end;
  if (fromPos >= 0)
    then Err := SetPositionTeteLectureFichierTexte(fic,fromPos)
    else Err := SetPositionTeteLectureFichierTexte(fic,theZone.position);
  if Err<>NoErr then
    begin
      LireFromZoneMemoireFichier := Err;
      Exit(LireFromZoneMemoireFichier);
    end;
  Err := ReadBufferDansFichierTexte(fic,text,nbOctets);
  LireFromZoneMemoireFichier := Err;
end;

function SetPositionZoneMemoireFichier(theZonePtr:ZoneMemoirePtr; var whichPosition : SInt32) : OSErr;
var Err : OSErr;
    fic : FichierTEXT;
    theZone : ZoneMemoire;
begin
  Err := GetZoneMemoireOfZoneMemoirePtr(theZonePtr,theZone);
  if Err<>NoErr then
    begin
      SetPositionZoneMemoireFichier := Err;
      Exit(SetPositionZoneMemoireFichier);
    end;
    
  if whichPosition>theZone.nbOctetsOccupes
    then whichPosition := theZone.nbOctetsOccupes;
  
  Err := GetFichierTEXTOfZoneMemoirePtr(theZonePtr,fic);
  if Err<>NoErr then
    begin
      SetPositionZoneMemoireFichier := Err;
      Exit(SetPositionZoneMemoireFichier);
    end;
  Err := SetPositionTeteLectureFichierTexte(fic,whichPosition);
  SetPositionZoneMemoireFichier := Err;
end;


function FermerFichierZoneMemoire(theZonePtr:ZoneMemoirePtr) : OSErr;
var Err : OSErr;
    fic : FichierTEXT;
begin
  Err := GetFichierTEXTOfZoneMemoirePtr(theZonePtr,fic);
  if Err<>NoErr then
    begin
      FermerFichierZoneMemoire := Err;
      Exit(FermerFichierZoneMemoire);
    end;
  Err := FermeFichierTexte(fic);
  FermerFichierZoneMemoire := Err;
end;

function ViderFichierZoneMemoire(theZonePtr:ZoneMemoirePtr) : OSErr;
var Err : OSErr;
    fic : FichierTEXT;
begin
  Err := GetFichierTEXTOfZoneMemoirePtr(theZonePtr,fic);
  if Err<>NoErr then
    begin
      ViderFichierZoneMemoire := Err;
      Exit(ViderFichierZoneMemoire);
    end;
  Err := VideFichierTexte(fic);
  ViderFichierZoneMemoire := Err;
end;




function EcrireDansZoneMemoirePointeur(theZonePtr:ZoneMemoirePtr;buffer : Ptr;fromPos : SInt32; var nbOctets : SInt32) : OSErr;
var theZone : ZoneMemoire;
begin
  if (GetZoneMemoireOfZoneMemoirePtr(theZonePtr,theZone)<>NoErr) |
     (theZone.infos = NIL)  then
    begin
      EcrireDansZoneMemoirePointeur := -1;
      exit(EcrireDansZoneMemoirePointeur);
    end;
  if (fromPos >= 0)
    then MoveMemory(buffer,Ptr(SInt32(theZone.infos)+fromPos),nbOctets)
    else MoveMemory(buffer,Ptr(SInt32(theZone.infos)+theZone.nbOctetsOccupes),nbOctets);
  EcrireDansZoneMemoirePointeur := NoErr;
end;


function LireFromZoneMemoirePointeur(theZonePtr:ZoneMemoirePtr;buffer : Ptr;fromPos : SInt32; var nbOctets : SInt32) : OSErr;
var theZone : ZoneMemoire;
begin
  if (GetZoneMemoireOfZoneMemoirePtr(theZonePtr,theZone)<>NoErr) |
     (theZone.infos = NIL)  then
    begin
      LireFromZoneMemoirePointeur := -1;
      exit(LireFromZoneMemoirePointeur);
    end;
  if (fromPos >= 0)
    then MoveMemory(Ptr(SInt32(theZone.infos)+fromPos),buffer,nbOctets)
    else MoveMemory(Ptr(SInt32(theZone.infos)+theZone.position),buffer,nbOctets);
  LireFromZoneMemoirePointeur := NoErr;
end;


function ClearZoneMemoireEnMemoire(theZonePtr:ZoneMemoirePtr) : OSErr;
var theZone : ZoneMemoire;
    count : SInt32;
begin
  if (GetZoneMemoireOfZoneMemoirePtr(theZonePtr,theZone)<>NoErr) |
     (theZone.infos = NIL)  then
    begin
      ClearZoneMemoireEnMemoire := -1;
      exit(ClearZoneMemoireEnMemoire);
    end;
  with theZone do
    begin
      count := nbOctetsOccupes;
      if count > tailleMaximalePossible then count := tailleMaximalePossible;
      MemoryFillChar(infos,count,chr(0));
    end;
  ClearZoneMemoireEnMemoire := NoErr;
end;


function NewEmptyZoneMemoire() : ZoneMemoire;
var aux : ZoneMemoire;
begin
  with aux do
    begin
      infos := NIL;
      tailleMaximalePossible := 0;
      nbOctetsOccupes        := 0;
      position               := 0;
      genre                  := BadZoneMemoire;
      zoneType               := '????';
      zoneCreator            := '????';
      Ecrire                 := FonctionEcritureBidon;
      Lire                   := FonctionEcritureBidon;
      Fermer                 := FonctionZoneMemoireBidon;
      Clear                  := FonctionZoneMemoireBidon;
      SetPosition            := FonctionZoneMemoireLongintBidon;
    end;
  NewEmptyZoneMemoire := aux;
end;

function MakeZoneMemoireFichier(nomFichier : str255;vrefNum : SInt16) : ZoneMemoire;
var aux : ZoneMemoire;
    fic : FichierTEXT;
    err : OSErr;
begin
  aux := NewEmptyZoneMemoire();
  MakeZoneMemoireFichier := aux;
  
  with aux do
    begin
      infos := AllocateMemoryPtrClear(sizeof(FichierTEXT));
      if infos = NIL then exit(MakeZoneMemoireFichier);
        
      err := FichierTexteExiste(nomFichier,vRefNum,fic);
      if (err=fnfErr) then {file not found, on crée le fichier}
        err := CreeFichierTexte(nomFichier,vRefNum,fic);
      if (err=NoErr) then
        err := OuvreFichierTexte(fic);
            
	    if err=NoErr then 
        begin
          MoveMemory(@fic, aux.infos, sizeof(FichierTEXT));
          
          Ecrire      := EcrireDansZoneMemoireFichier;
          Lire        := LireFromZoneMemoireFichier;
          Clear       := ViderFichierZoneMemoire;
          Fermer      := FermerFichierZoneMemoire;
          SetPosition := SetPositionZoneMemoireFichier;
          
          zoneType    := GetFileTypeFichierTexte(fic);
          zoneCreator := GetFileCreatorFichierTexte(fic);

          err := GetTailleFichierTexte(fic,nbOctetsOccupes);
          tailleMaximalePossible := MaxLongint;
          genre := ZoneMemoireEstFichier;
        end;
    end;
  MakeZoneMemoireFichier := aux;
end;


function MakeZoneMemoireEnMemoire(taille : SInt32) : ZoneMemoire;
var aux : ZoneMemoire;
begin
  aux := NewEmptyZoneMemoire();
  MakeZoneMemoireEnMemoire := aux;
  
  with aux do
    begin
      if taille < 256 then taille := 256;
      infos := AllocateMemoryPtrClear(taille);
      if infos = NIL 
        then exit(MakeZoneMemoireEnMemoire)
        else
          begin
          
            Ecrire := EcrireDansZoneMemoirePointeur;
            Lire   := LireFromZoneMemoirePointeur;
            Clear  := ClearZoneMemoireEnMemoire;
            
            tailleMaximalePossible := taille;
            genre  := ZoneMemoireEstPointeur;
          end;
    end;
    
  MakeZoneMemoireEnMemoire := aux;
end;


function ZoneMemoireEstCorrecte(const theZone : ZoneMemoire) : boolean;
begin
  ZoneMemoireEstCorrecte := (theZone.genre = ZoneMemoireEstPointeur) |
                            (theZone.genre = ZoneMemoireEstFichier);
end;


procedure DisposeZoneMemoire(var theZone : ZoneMemoire);
var err : OSErr;
begin
  if not(ZoneMemoireEstCorrecte(theZone)) then
    begin
      DisplayMessageInConsole('### ASSERT FAILED ### '+'(theZone.genre = BadZoneMemoire) in DisposeZoneMemoire');
      exit(DisposeZoneMemoire);
    end;
  
  with theZone do
    begin
      err := Fermer(@theZone);
      if infos <> NIL then 
        begin
          DisposeMemoryPtr(Ptr(infos));
          infos := NIL;
        end;
      tailleMaximalePossible := 0;
      nbOctetsOccupes := 0;
      position := 0;
      genre := BadZoneMemoire;
      Ecrire := FonctionEcritureBidon;
      Fermer := FonctionZoneMemoireBidon;
    end;
end;


{note : passer une valeur négative dans fromPos pour écrire à la fin de la zone mémoire}
function EcrireZoneMemoire(var theZone : ZoneMemoire;fromPos : SInt32;text : Ptr; var nbOctets : SInt32) : OSErr;
var err : OSErr;
begin
  err := 0;
  with theZone do
    begin
      if (fromPos>=0) & (nbOctets > tailleMaximalePossible - fromPos)
		    then nbOctets := tailleMaximalePossible - fromPos;
		  if (fromPos<0)  & (nbOctets > tailleMaximalePossible - nbOctetsOccupes)
		    then nbOctets := tailleMaximalePossible - nbOctetsOccupes;
		  err := Ecrire(@theZone,text,fromPos,nbOctets);
		  if err<>NoErr then 
		    begin
		      EcrireZoneMemoire := err;
		      exit(EcrireZoneMemoire);
		    end;
		  if FromPos >= 0
				then position := fromPos+nbOctets
			  else position := nbOctetsOccupes+nbOctets;
			if position>nbOctetsOccupes then nbOctetsOccupes := position;   
	  end;
  EcrireZoneMemoire := err;
end;

function WriteDansZoneMemoire(var theZone : ZoneMemoire;s : str255) : OSErr;
var len : SInt32;
begin
  len := Length(s);
  WriteDansZoneMemoire := EcrireZoneMemoire(theZone,-1,@s[1],len);
end;

function WritelnDansZoneMemoire(var theZone : ZoneMemoire;s : str255) : OSErr;
begin
  WritelnDansZoneMemoire := WriteDansZoneMemoire(theZone,s+chr(13));
end;


function ViderZoneMemoire(var theZone : ZoneMemoire) : OSErr;
var err : OSErr;
begin
  err := 0;
  with theZone do
    begin
      nbOctetsOccupes := 0;
      position := 0;
      err := Clear(@theZone);
    end;
  ViderZoneMemoire := err;
end;



function MySetPositionMarqueurZoneMemoire(var theZone : ZoneMemoire; var whichPosition : SInt32) : OSErr;
var err : OSErr;
begin
  err := 0;
  with theZone do
    begin
      position := whichPosition;
      if position<0 then position := 0;
      if position>TailleMaximalePossible then position := TailleMaximalePossible;
      
      err := SetPosition(@theZone,position);
    end;
  MySetPositionMarqueurZoneMemoire := err;
end;


function GetPositionMarqueurZoneMemoire(var theZone : ZoneMemoire) : SInt32;
begin
  GetPositionMarqueurZoneMemoire := theZone.position;
end;


function SetPositionMarqueurZoneMemoire(var theZone : ZoneMemoire;whichPosition : SInt32) : OSErr;
begin
  SetPositionMarqueurZoneMemoire := MySetPositionMarqueurZoneMemoire(theZone,whichPosition);
end;


function RevientEnArriereDansZoneMemoire(var theZone : ZoneMemoire;nbOctets : SInt32) : OSErr;
var oldPosition,newPosition : SInt32;
begin
  oldPosition := theZone.position;
  newPosition := oldPosition-nbOctets;
  if newPosition<0 then newPosition := 0;
  RevientEnArriereDansZoneMemoire := SetPositionMarqueurZoneMemoire(theZone,newPosition);
end;



function ReadFromZoneMemoire(var theZone : ZoneMemoire;FromPos : SInt32; var count : SInt32;buffer : Ptr) : OSErr;
var err : OSErr;
begin
  err := 0;
  with theZone do
    begin
		  if (fromPos>=0) & (count > nbOctetsOccupes - fromPos)
		    then count := nbOctetsOccupes - fromPos;
		  if (fromPos<0)  & (count > nbOctetsOccupes - position)
		    then count := nbOctetsOccupes - position;
		  err := Lire(@theZone,buffer,fromPos,count);
		  if err<>NoErr then 
		    begin
		      ReadFromZoneMemoire := err;
		      exit(ReadFromZoneMemoire);
		    end;
		  if FromPos >= 0
				then position := fromPos+count
			  else position := position+count;
			if position>nbOctetsOccupes then nbOctetsOccupes := position;   
	  end;
  ReadFromZoneMemoire := err;
end;



function GetNextCharOfZoneMemoire(var theZone : ZoneMemoire; var c : char) : OSErr;
type str7 = string[7];
var err : OSErr;
    nbOctets : SInt32;
    s:str7;
begin
  c := chr(0);
  with theZone do
    begin
      if position>=nbOctetsOccupes then
        begin
          GetNextCharOfZoneMemoire := -1;
          exit(GetNextCharOfZoneMemoire);
        end;
      nbOctets := 1;
      err := ReadFromZoneMemoire(theZone,-1,nbOctets,@s[1]);
      
      if nbOctets <= 0
        then
          GetNextCharOfZoneMemoire := -1
        else 
          begin
            if (err = NoErr) then c := s[1];
            GetNextCharOfZoneMemoire := err;
          end;
    end;
end;


function ReadlnDansZoneMemoire(var theZone : ZoneMemoire; var s : str255) : OSErr;
var err : OSErr;
    i,len,n : SInt32;
    oldPosition,newPosition : SInt32;
begin
  s := '';
  oldPosition := theZone.position;
  
  n := 255;
  err := ReadFromZoneMemoire(theZone,-1,n,@s[1]);
  
  if (err <> NoErr) then
    begin
      ReadlnDansZoneMemoire := err;
      exit(ReadlnDansZoneMemoire);
    end;
  
  if (n <= 0) then
    begin
      ReadlnDansZoneMemoire := -1;
      exit(ReadlnDansZoneMemoire);
    end;
  
  len := 0;
  i := 1;
  while (i<n) & (s[i] <> cr) & (s[i] <> lf) do inc(i); {line feed or carriage return}
  if (s[i] = cr)
    then
      begin
        len := i-1;
        if (i < 255) & (s[i+1] = lf)
          then newPosition := oldPosition+len+2  {+2 car on veut sauter le CR-LF}
          else newPosition := oldPosition+len+1; {+1 car on veut sauter le CR}
      end
    else
  if (s[i] = lf)
    then 
      begin
        len := i-1;
        if (i < 255) & (s[i+1] = cr)
          then newPosition := oldPosition+len+2  {+2 car on veut sauter le CR-LF}
          else newPosition := oldPosition+len+1; {+1 car on veut sauter le LF}
      end
    else 
      begin
        i := Min(255,i);
        len := i;                      {on a lus n caracteres sans rencontrer de CR ni de LF}
        newPosition := oldPosition+len;
      end;
  s[0] := chr(len);
  for i := len+1 to 255 do s[i] := chr(0);
  
  
  
  err := MySetPositionMarqueurZoneMemoire(theZone,newPosition);
  ReadlnDansZoneMemoire := err;
end;


function EOFZoneMemoire(var theZone : ZoneMemoire; var erreurES : OSErr) : boolean;
var fic : FichierTEXT;
begin
  if (theZone.genre = ZoneMemoireEstFichier) & 
     (GetFichierTEXTOfZoneMemoirePtr(@theZone,fic)=NoErr) 
    then
      EOFZoneMemoire := EOFFichierTexte(fic,erreurES)
    else
      begin
        EOFZoneMemoire := (theZone.position >= theZone.nbOctetsOccupes);
        erreurES       := NoErr;
      end;
end;


function GetZoneType(var theZone : ZoneMemoire) : OSType;
begin
  GetZoneType := theZone.zoneType;
end;


function GetZoneCreator(var theZone : ZoneMemoire) : OSType;
begin
  GetZoneCreator := theZone.zoneCreator;
end;


procedure SetZoneType(var theZone : ZoneMemoire;whichType : OSType);
var fic : FichierTEXT;
begin
   theZone.zoneType := whichType;
   if (theZone.genre = ZoneMemoireEstFichier) & 
     (GetFichierTEXTOfZoneMemoirePtr(@theZone,fic)=NoErr) 
    then SetFileTypeFichierTexte(fic,whichType);
end;

procedure SetZoneCreator(var theZone : ZoneMemoire;whichCreator : OSType);
var fic : FichierTEXT;
begin
  theZone.zoneCreator := whichCreator;
  if (theZone.genre = ZoneMemoireEstFichier) & 
     (GetFichierTEXTOfZoneMemoirePtr(@theZone,fic)=NoErr) 
    then SetFileCreatorFichierTexte(fic,whichCreator);
end;

procedure FermerFichierEtFabriquerZoneMemoire(var fic : FichierTEXT; var theZone : ZoneMemoire);
var name : str255;
    erreur : OSErr;
    num : SInt32;
begin
  name := fic.nomFichier;
  num  := fic.vRefNum;
  erreur := FermeFichierTexte(fic);
  theZone := MakeZoneMemoireFichier(name,num);
end;

procedure DisposeZoneMemoireEtOuvrirFichier(var fic : FichierTEXT; var theZone : ZoneMemoire);
var erreur : OSErr;
    ficZoneMemoire : FichierTEXT;
    name : str255;
    num : SInt32;
    positionMarqueur : SInt32;
begin
  if GetFichierTEXTOfZoneMemoirePtr(@theZone,ficZoneMemoire) = NoErr 
    then
      begin
        name             := ficZoneMemoire.nomFichier;
        num              := ficZoneMemoire.vRefNum;
        positionMarqueur := theZone.position;
        DisposeZoneMemoire(theZone);
        erreur := CreeFichierTexte(name,num,fic);
        erreur := OuvreFichierTexte(fic);
        if (positionMarqueur >= 0)
          then erreur := SetPositionTeteLectureFichierTexte(fic,positionMarqueur)
          else erreur := SetPositionTeteLectureFinFichierTexte(fic);
      end
    else
      begin
        DisposeZoneMemoire(theZone);
        erreur := OuvreFichierTexte(fic);
      end;
end;

end.
