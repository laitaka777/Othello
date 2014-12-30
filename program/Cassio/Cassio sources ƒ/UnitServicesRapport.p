UNIT UnitServicesRapport;



INTERFACE







{sur Macintosh, on utilise TextEdit d'Apple}
{USES TextEdit;}
USES UnitServicesTypes,MacTypes;


TYPE StringProc = procedure(var s : str255);

{Fonctions de manipulation de la fenetre du rapport}
function FenetreRapportEstOuverte() : boolean;


{Diverses fonctions d'acces les caracteres du texte du rapport}
function GetRapportTextHandle() : CharArrayHandle;
function GetTailleRapport() : SInt32;
function GetNiemeCaractereDuRapport(n : SInt32) : char;
function GetDebutLigneDuRapport(fromWhere : SInt32) : str255;
function GetLignePrecedenteDuRapport(fromWhere : SInt32) : str255;
function GetAvantDerniereLigneCouranteDuRapport() : str255;
function GetLigneCouranteDuRapport() : str255;
function GetDerniereLigneDuRapport() : str255;
function GetAvantDerniereLigneDuRapport() : str255;


{Fonctions de gestion de la selection du rapport}
function GetDebutSelectionRapport() : SInt32;
function GetFinSelectionRapport() : SInt32;
function GetMilieuSelectionRapport() : SInt32;
function SelectionRapportNonVide() : boolean;
function SelectionRapportEstVide() : boolean;
function LongueurSelectionRapport() : SInt32;
function SelectionRapportEnString(var count : SInt32) : str255;
procedure SelectionnerTexteDansRapport(posDebut,posFin : SInt32);


{Fonction d'acces a la selection du rapport ligne par ligne}
function NombreDeLignesDansSelectionRapport() : SInt32;
procedure ForEachLineSelectedInRapportDo(doWhat:StringProc);


{Fonction d'insertion d'un texte dans le rapport}
{si scrollerSynchronisation est vrai, on demande que les}
{eventuels ascenseurs du rapport soient mis a jours automatiquement}
procedure InsereTexteDansRapportSync(text : Ptr;length : SInt32;scrollerSynchronisation : boolean);


{remplacement des caracteres de l'intervale positionDebut..positionFin par la chaine newString}
procedure RemplacerTexteDansRapport(positionDebut,positionFin : SInt32;newString : str255;scrollerSynchronisation : boolean);

{gestion de la place disponible dans le rapport}
procedure FaireDeLaPlaceAuDebutDuRapport(placeVoulue : SInt32);
function GetPlaceDisponibleDansRapport() : SInt32;

{effacement des caracteres de l'intervale positionDebut..positionFin}
procedure DetruireTexteDansRapport(posDebut,posFin : SInt32;scrollerSynchronisation : boolean);



{Autovidage : si le rapport devient trop gros pour la memoire
 de la machine, on autorise la machine a le vider sans interrompre
 l'utilisateur avec une alerte}
procedure SetAutoVidageDuRapport(flag : boolean);
function GetAutoVidageDuRapport() : boolean;


{Gestion du fichier "Rapport.log"}
procedure SetEcritToutDansRapportLog(flag : boolean);
function GetEcritToutDansRapportLog() : boolean;
procedure WriteTexteDansFichierLog(text : Ptr;length : SInt32);



IMPLEMENTATION







USES TextEdit,UnitOth0,UnitRapportImplementation,UnitServicesDialogs,SNStrings,UnitOth2,
     UnitDialog,MyTypes;


var FichierRapportLog : FichierTEXT;


function FenetreRapportEstOuverte() : boolean;
begin
  FenetreRapportEstOuverte := GetWindowRapportOpen();
end;

function GetRapportTextHandle() : CharArrayHandle;
begin
  if GetTextEditRecordOfRapport() = NIL
    then GetRapportTextHandle := NIL
    else GetRapportTextHandle := CharArrayHandle(TEGetText(GetTextEditRecordOfRapport()));
end;

function GetTailleRapport() : SInt32;
begin
  GetTailleRapport := TEGetTextLength(GetTextEditRecordOfRapport());
end;

function GetNiemeCaractereDuRapport(n : SInt32) : char;
begin
  if (n >= 0) & (n <= GetTailleRapport())
    then GetNiemeCaractereDuRapport := GetRapportTextHandle()^^[n]
    else GetNiemeCaractereDuRapport := chr(0);
end;


function GetDebutLigneDuRapport(fromWhere : SInt32) : str255;
var s : str255;
    i,count : SInt32;
    c,nextChar : char;
    TexteRapportHdl : CharArrayHandle;
begin
  s := '';
  
  TexteRapportHdl := GetRapportTextHandle();
  if (TexteRapportHdl <> NIL) then
    begin
    	i := Min(fromWhere,GetTailleRapport());
    	count := 0;
      if (i > 0) then nextChar := TexteRapportHdl^^[i-1];
  	  while (i > 0) & (nextChar <> cr) & (count < 255) do
      	begin
      	  c := nextChar;
      	  s := c+s;
      	  i := i-1;
      	  count := count+1;
      	  nextChar := TexteRapportHdl^^[i-1];
      	end;
    end;
	
	GetDebutLigneDuRapport := s;
end;


function GetLignePrecedenteDuRapport(fromWhere : SInt32) : str255;
var s : str255;
begin
  s := GetDebutLigneDuRapport(fromWhere);
  GetLignePrecedenteDuRapport := GetDebutLigneDuRapport(fromWhere - Length(s) - 1);
end;


function GetLigneCouranteDuRapport() : str255;
begin
  GetLigneCouranteDuRapport := GetDebutLigneDuRapport(GetDebutSelectionRapport());
end;


function GetAvantDerniereLigneCouranteDuRapport() : str255;
var s : str255;
begin
  s := GetLigneCouranteDuRapport();
  GetAvantDerniereLigneCouranteDuRapport := GetDebutLigneDuRapport(GetDebutSelectionRapport() - Length(s) - 1);
end;


function GetDerniereLigneDuRapport() : str255;
begin
  GetDerniereLigneDuRapport := GetDebutLigneDuRapport(GetTailleRapport());
end;


function GetAvantDerniereLigneDuRapport() : str255;
var s : str255;
begin
  s := GetDerniereLigneDuRapport();
  GetAvantDerniereLigneDuRapport := GetDebutLigneDuRapport(GetTailleRapport() - Length(s) - 1);
end;


function GetDebutSelectionRapport() : SInt32;
var theText : TEHandle;
begin
  theText := GetTextEditRecordOfRapport();
  if (theText <> NIL)
    then GetDebutSelectionRapport := theText^^.selStart
    else GetDebutSelectionRapport := 0;
end;


function GetFinSelectionRapport() : SInt32;
var theText : TEHandle;
begin
  theText := GetTextEditRecordOfRapport();
  if (theText <> NIL)
    then GetFinSelectionRapport := theText^^.selEnd
    else GetFinSelectionRapport := 0;
end;


function GetMilieuSelectionRapport() : SInt32;
begin
  GetMilieuSelectionRapport := (GetDebutSelectionRapport() + GetFinSelectionRapport()) div 2;
end;

function SelectionRapportNonVide() : boolean;
begin
  if (GetTextEditRecordOfRapport() = NIL) 
     then SelectionRapportNonVide := false
     else SelectionRapportNonVide := (GetFinSelectionRapport() > GetDebutSelectionRapport());
end;

function SelectionRapportEstVide() : boolean;
begin
  if (GetTextEditRecordOfRapport() = NIL) 
     then SelectionRapportEstVide := true
     else SelectionRapportEstVide := (GetFinSelectionRapport() = GetDebutSelectionRapport());
end;

function LongueurSelectionRapport() : SInt32;
begin
  if (GetTextEditRecordOfRapport() = NIL) 
     then LongueurSelectionRapport := 0
     else LongueurSelectionRapport := (GetFinSelectionRapport() - GetDebutSelectionRapport());
end;

function SelectionRapportEnString(var count : SInt32) : str255;
var s : str255;
    i,fin : SInt32;
    c : char;
    TexteRapportHdl : CharArrayHandle;
begin
  if SelectionRapportEstVide() 
    then
      begin
        SelectionRapportEnString := '';
        count := 0;
      end
    else
      begin
        TexteRapportHdl := GetRapportTextHandle();
				i := GetDebutSelectionRapport();
				fin := GetFinSelectionRapport();
				s := '';count := 0;
				if (TexteRapportHdl <> NIL) then
  				repeat
  				  c := TexteRapportHdl^^[i];
  				  s := s+c;
  				  i := i+1;
  				  count := count+1;
  				until (i >= fin) | (count >= 253);
				
				SelectionRapportEnString := s;
      end;
end;

procedure SelectionnerTexteDansRapport(posDebut,posFin : SInt32);
begin
  if (posDebut <= posFin) & (GetTextEditRecordOfRapport() <> NIL) then
    TESetSelect(posDebut,posFin,GetTextEditRecordOfRapport());
end;


function NombreDeLignesDansSelectionRapport() : SInt32;
var compteurLignes : SInt32;
    texteRapportHdl : CharArrayHandle;
    i,longueurLigne,fin : SInt32;
    c : char;
    ligne : str255;
begin
  compteurLignes := 0;
  
  if SelectionRapportNonVide() then
     begin
       texteRapportHdl := GetRapportTextHandle();
       i := GetDebutSelectionRapport();
       fin := GetFinSelectionRapport();
       ligne := '';
       longueurLigne := 0;
       repeat
         c := texteRapportHdl^^[i];
         if c=chr(13) 
           then c := '¶'
           else ligne := ligne+c;
         i := i+1;
         longueurLigne := longueurLigne+1;
         if (c='¶') | (longueurLigne >= 240) then 
           begin
             inc(compteurLignes);
             ligne := '';
             longueurLigne := 0;
           end;
       until (i >= fin);
       
       if (ligne <> '') then inc(compteurLignes);
     end;

  NombreDeLignesDansSelectionRapport := compteurLignes;
end;


procedure ForEachLineSelectedInRapportDo(doWhat:StringProc);
var compteurLignes : SInt32;
    texteRapportHdl : CharArrayHandle;
    i,longueurLigne,fin : SInt32;
    c : char;
    ligne : str255;
begin
  compteurLignes := 0;
  
  if SelectionRapportNonVide() then
     begin
       texteRapportHdl := GetRapportTextHandle();
       i := GetDebutSelectionRapport();
       fin := GetFinSelectionRapport();
       ligne := '';
       longueurLigne := 0;
       repeat
         c := texteRapportHdl^^[i];
         if (c = chr(13))
           then c := '¶'
           else ligne := ligne+c;
         i := i+1;
         longueurLigne := longueurLigne+1;
         if (c = '¶') | (longueurLigne >= 240) then 
           begin
             inc(compteurLignes);
             doWhat(ligne);
             ligne := '';
             longueurLigne := 0;
           end;
       until (i >= fin);
       
       if (ligne <> '') then 
         begin
           inc(compteurLignes);
           DoWhat(ligne);
         end;
     end;
end;




procedure DetruireTexteDansRapport(posDebut,posFin : SInt32;scrollerSynchronisation : boolean);
var oldDebutSel,oldFinSel : SInt32;
    tailleDestruction : SInt32;
    temp : boolean;
begin
  temp := GetDeroulementAutomatiqueDuRapport();
  SetDeroulementAutomatiqueDuRapport(false);
  
  {sauvegarder l'ancienne selection}
  oldDebutSel := GetDebutSelectionRapport();
  oldFinSel   := GetFinSelectionRapport();

  {selectionner le texte à effacer, puis l'effacer}
  SelectionnerTexteDansRapport(posDebut,posFin);
  tailleDestruction := LongueurSelectionRapport();
  FrappeClavierDansRapport(chr(RetourArriereKey));
  
  {retablir l'ancienne selection}
  oldDebutSel := oldDebutSel - tailleDestruction;
  oldFinSel   := oldFinSel   - tailleDestruction;
  SelectionnerTexteDansRapport(oldDebutSel, oldFinSel);
  
  if scrollerSynchronisation then UpdateScrollersRapport;
  SetDeroulementAutomatiqueDuRapport(temp);
end;

procedure FaireDeLaPlaceAuDebutDuRapport(placeVoulue : SInt32);
begin
  DetruireTexteDansRapport(GetLongueurMessageBienvenueDansCassio()+3,
	                         GetLongueurMessageBienvenueDansCassio()+placeVoulue+3,false);
	UpdateScrollersRapport;
end;

function GetPlaceDisponibleDansRapport() : SInt32;
begin
  GetPlaceDisponibleDansRapport := GetProchaineAlerteRemplissageRapport() - GetTailleRapport();
end;


procedure InsereTexteDansRapportSync(text : Ptr;length : SInt32;scrollerSynchronisation : boolean);
const HumainVeutEffacerToutRapportBouton=2;
      RapportBienRempliID=200;
      RapportRempliRasBordID=201;
      
   procedure VideToutLeRapport;
     begin
       TESetSelect(0,MaxLongint-1,GetTextEditRecordOfRapport());
	     TEDelete(GetTextEditRecordOfRapport());
	     if scrollerSynchronisation then UpdateScrollersRapport;
	     EcritBienvenueDansRapport;
	     SetProchaineAlerteRemplissageRapport(GetTailleMaximumOfRapport()-2000);
     end;
     
var oldport : grafPtr;
begin
  GetPort(oldport);
  if (GetTextEditRecordOfRapport() <> NIL) then
    begin
    
	   if (GetProchaineAlerteRemplissageRapport() = (GetTailleMaximumOfRapport()-2000)) &
	      (GetTailleRapport() >= GetTailleMaximumOfRapport()-length-2000) then 
	     begin
	       {
	       SetProchaineAlerteRemplissageRapport(GetTailleMaximumOfRapport()-1000);
	       if not(demo | enModeIOS | inBackGround | GetAutoVidageDuRapport()) then
	         if MySimpleAlerte(RapportBienRempliID,'')=HumainVeutEffacerToutRapportBouton 
	           then VideToutLeRapport; 
	       }   
	       
	       DetruireTexteDansRapport(GetLongueurMessageBienvenueDansCassio()+3,
	                                GetLongueurMessageBienvenueDansCassio()+length+3000,false);
	       UpdateScrollersRapport;
	     end;
	     
	   if (GetProchaineAlerteRemplissageRapport() = (GetTailleMaximumOfRapport()-1000)) &
	      (GetTailleRapport() >= GetTailleMaximumOfRapport()-length-1000) then 
	     begin
	       {
	       SetProchaineAlerteRemplissageRapport(GetTailleMaximumOfRapport());
	       if not(demo | enModeIOS | inBackGround | GetAutoVidageDuRapport()) then
	         if MySimpleAlerte(RapportRempliRasBordID,'')=HumainVeutEffacerToutRapportBouton 
	           then VideToutLeRapport;  
	       }
	     end;
	     
	   if (GetTailleRapport() >= (GetTailleMaximumOfRapport()-length)) then 
	     begin
	       SetProchaineAlerteRemplissageRapport(GetTailleMaximumOfRapport()-2000);
	       VideToutLeRapport;
	       if not(demo | enModeIOS | inBackGround | GetAutoVidageDuRapport()) then
	         AlerteSimple(ReadStringFromRessource(TextesRapportID,26));  {Le rapport a été vidé}
	     end;
	     
	   if (GetTailleRapport() < (GetTailleMaximumOfRapport()-length))
	     then
	       begin
	         TEInsert(text,length,GetTextEditRecordOfRapport());
	         TESelView(GetTextEditRecordOfRapport());
	         if scrollerSynchronisation then UpdateScrollersRapport;
	         if GetEcritToutDansRapportLog() then WriteTexteDansFichierLog(text,length);
	       end;
    end;
  SetPort(oldport);
end;


procedure RemplacerTexteDansRapport(positionDebut,positionFin : SInt32;newString : str255;scrollerSynchronisation : boolean);
var k,longueurTexteDetruit : SInt32;
begin
  if (positionDebut >= 0) & 
     (positionDebut <= positionFin) then
    begin
      {on se place a positionFin pour garder le meme style}
      SelectionnerTexteDansRapport(positionFin,positionFin);
      InsereTexteDansRapportSync(@newString[1],length(newString),scrollerSynchronisation);
      
      {on se place a positionFin pour effacer le texte entre positionDebut,positionFin}
      SelectionnerTexteDansRapport(positionFin,positionFin);
      longueurTexteDetruit := positionFin - positionDebut;
      
      {effacer les caracteres}
      for k := 1 to longueurTexteDetruit do 
         FrappeClavierDansRapport(chr(RetourArriereKey));
      
    end;
end;



procedure OuvreFichierLog;
var erreurES : OSErr;
begin
  erreurES := FichierTexteDeCassioExiste('Rapport.log',FichierRapportLog);
  if erreurES=fnfErr then {-43 => fichier non trouvé, on le crée}
    begin
      erreurES := CreeFichierTexteDeCassio('Rapport.log',FichierRapportLog);
      SetFileCreatorFichierTexte(FichierRapportLog,'CWIE');
      SetFileTypeFichierTexte(FichierRapportLog,'TEXT');
    end;
  if erreurES=NoErr then
    erreurES := OuvreFichierTexte(FichierRapportLog);
end;

procedure FermeFichierLog;
var erreurES : OSErr;
begin
  erreurES := FermeFichierTexte(FichierRapportLog);
end;


procedure WriteTexteDansFichierLog(text : Ptr;length : SInt32);
var erreurES : OSErr;
    oldEcritureDansLog : boolean;
begin
  oldEcritureDansLog := GetEcritToutDansRapportLog();
  SetEcritToutDansRapportLog(false);
  OuvreFichierLog;
  erreurES := SetPositionTeteLectureFinFichierTexte(FichierRapportLog);
  erreurES := WriteBufferDansFichierTexte(FichierRapportLog,text,length);
  FermeFichierLog;
  SetEcritToutDansRapportLog(oldEcritureDansLog);
end;


procedure SetAutoVidageDuRapport(flag : boolean);
begin
  SetAutoVidageDuRapportDansImplementation(flag);
end;

function GetAutoVidageDuRapport() : boolean;
begin
  GetAutoVidageDuRapport := GetAutoVidageDuRapportDansImplementation();
end;

procedure SetEcritToutDansRapportLog(flag : boolean);
begin
  SetEcritToutDansRapportLogDansImplementation(flag);
end;

function GetEcritToutDansRapportLog() : boolean;
begin
  GetEcritToutDansRapportLog := GetEcritToutDansRapportLogDansImplementation();
end;



END.


