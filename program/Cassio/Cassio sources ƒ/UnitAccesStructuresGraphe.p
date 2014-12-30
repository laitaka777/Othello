UNIT UnitAccesStructuresGraphe;


INTERFACE







USES UnitDefinitionsApprentissage,UnitFichiersTEXT;

type GrapheRec =
       record
         nbCellules : SInt32;
         fic : FichierTEXT;
       end;
     Graphe = ^GrapheRec;
     
var  nomGrapheApprentissage : str255;
     nomGrapheInterversions : str255;
     

{Initialisation de l'unité}
procedure InitUnitAccesGrapheApprentissage;
procedure LibereMemoireUnitAccesGrapheApprentissage;
procedure VideBufferGrapheApprentissage;

{Lecture et ecriture sur le disque}
function GrapheApprentissageExiste(var nomDuGraphe : str255; var fichier : Graphe; var grapheEtaitDejaOuvert : boolean) : boolean;
procedure CreeGrapheApprentissage(var nomDuGraphe : str255; var fichier : Graphe);
function OuvreGrapheApprentissage(var fichier : Graphe) : boolean;
function FermeGrapheApprentissage(var fichier : Graphe) : boolean;
procedure PreouvrirGraphesUsuels;
procedure FermerGraphesUsuels;

{Acces aux infos d'un graphe}
function NbrePositionsDansGrapheApprentissage(var fichier : Graphe) : SInt32;
procedure RecalculerNbrePositionsDansGrapheApprentissage(var fichier : Graphe);
procedure VideGrapheApprentissage(var fichier : Graphe);
procedure LitCellule(var fichier : Graphe;numCellule : SInt32; var cellule : CelluleRec);
procedure EcritCellule(var fichier : Graphe;numCellule : SInt32; var cellule : CelluleRec);
procedure AfficheCelluleDansRapport(var fichier : Graphe;num : SInt32; var cellule : CelluleRec);
procedure InitialiseCellule(var cellule : CelluleRec;numCellule : SInt32);
procedure IsoleCellule(var fichier : Graphe;numCellule : SInt32);

function GetNbreEcrituresDansGraphe() : SInt32;
function GetNbreLecturesDansGraphe() : SInt32;

{Acces et modification des champs des cellules du graphe d'apprentissage}
function GetPere(var cellule : CelluleRec) : SInt32;
function GetFils(var cellule : CelluleRec) : SInt32;
function GetFrere(var cellule : CelluleRec) : SInt32;
function GetMemePosition(var cellule : CelluleRec) : SInt32;
function GetCoup(var cellule : CelluleRec) : byte;
function GetCouleur(var cellule : CelluleRec) : SignedByte;
function GetTrait(var cellule : CelluleRec) : SignedByte;
function GetNumeroCoup(var cellule : CelluleRec) : byte;

procedure SetPere(thePere : SInt32; var cellule : CelluleRec);
procedure SetFils(theFils : SInt32; var cellule : CelluleRec);
procedure SetFrere(theFrere : SInt32; var cellule : CelluleRec);
procedure SetMemePosition(theMemePosition : SInt32; var cellule : CelluleRec);
procedure SetCoup(coup : byte; var cellule : CelluleRec);
procedure SetCouleur(couleur : SignedByte; var cellule : CelluleRec);
procedure SetTrait(trait : SignedByte; var cellule : CelluleRec);
procedure SetNumeroCoup(numero : byte; var cellule : CelluleRec);

function GetCoupOfCelluleNumero(var fichier : Graphe;numeroCellule : SInt32) : byte;
function GetNiemeCoupDansListe(var fichier : Graphe; var L : ListeDeCellules;n : SInt16) : byte;

{Les flags}
function GetFlags(var cellule : CelluleRec) : SInt16; 
function HasFlagAttribute(var cellule : CelluleRec;flagMask : SInt16) : boolean;
procedure SetFlags(var cellule : CelluleRec;theFlags : SInt16);
procedure AddFlagAttribute(var cellule : CelluleRec;flagMask : SInt16);
procedure RemoveFlagAttribute(var cellule : CelluleRec;flagMask : SInt16);



{Set}
procedure SetValeurMinimax(var cellule : CelluleRec;val : byte);
procedure SetValeurDeviantePourNoir(var cellule : CelluleRec;val : SInt16);
procedure SetValeurDeviantePourBlanc(var cellule : CelluleRec;val : SInt16);
procedure SetProofNumberPourNoir(var cellule : CelluleRec;val : SInt16);
procedure SetProofNumberPourBlanc(var cellule : CelluleRec;val : SInt16);
procedure SetDisproofNumberPourNoir(var cellule : CelluleRec;val : SInt16);
procedure SetDisproofNumberPourBlanc(var cellule : CelluleRec;val : SInt16);
procedure SetEsperanceDeGainPourNoir(var cellule : CelluleRec;val : extended);
procedure SetEsperanceDeGainPourBlanc(var cellule : CelluleRec;val : extended);
procedure SetValeurHeuristiquePourNoir(var cellule : CelluleRec;val : SInt16);
procedure SetProfondeur(prof : byte; var cellule : CelluleRec);
procedure SetVersion(version : byte; var cellule : CelluleRec);
{ …les memes, avec un selecteur de couleur}
procedure SetProofNumber(var cellule : CelluleRec;couleur : SInt16; val : SInt16);
procedure SetDisproofNumber(var cellule : CelluleRec;couleur : SInt16; val : SInt16);
procedure SetValeurDeviante(var cellule : CelluleRec;couleur : SInt16; val : SInt16);
procedure SetEsperanceDeGain(var cellule : CelluleRec;couleur : SInt16; val : extended);

{Get}
function GetValeurMinimax(var cellule : CelluleRec) : byte;
function GetValeurDeviantePourNoir(var cellule : CelluleRec) : SInt16; 
function GetValeurDeviantePourBlanc(var cellule : CelluleRec) : SInt16; 
function GetProofNumberPourNoir(var cellule : CelluleRec) : SInt16; 
function GetProofNumberPourBlanc(var cellule : CelluleRec) : SInt16; 
function GetDisproofNumberPourNoir(var cellule : CelluleRec) : SInt16; 
function GetDisproofNumberPourBlanc(var cellule : CelluleRec) : SInt16; 
function GetEsperanceDeGainPourNoir(var cellule : CelluleRec) : extended;
function GetEsperanceDeGainPourBlanc(var cellule : CelluleRec) : extended;
function GetValeurHeuristiquePourNoir(var cellule : CelluleRec) : SInt16; 
function GetProfondeur(var cellule : CelluleRec) : byte;
function GetVersion(var cellule : CelluleRec) : byte;
{ …les memes, avec un selecteur de couleur}
function GetProofNumber(var cellule : CelluleRec;couleur : SInt16) : SInt16; 
function GetDisproofNumber(var cellule : CelluleRec;couleur : SInt16) : SInt16; 
function GetValeurDeviante(var cellule : CelluleRec;couleur : SInt16) : SInt16; 
function GetEsperanceDeGain(var cellule : CelluleRec;couleur : SInt16) : extended;


{Tests divers}
function MemesCellules(const cellule1,cellule2 : CelluleRec) : boolean;
function IsPublic(var cellule : CelluleRec) : boolean;
function IsPrivate(var cellule : CelluleRec) : boolean;
function EstDansT(var cellule : CelluleRec) : boolean;
function EstUnePropositionHeuristique(var cellule : CelluleRec) : boolean;
function AuMoinsUnFils(var fichier : Graphe;numCellule : SInt32) : boolean;
function HasPere(var cellule : CelluleRec) : boolean;
function HasFrere(var cellule : CelluleRec) : boolean;
function HasFils(var cellule : CelluleRec) : boolean;

{Gestion de l'arbre d'ouvertures}
procedure SetPublic(var cellule : CelluleRec);
procedure SetPrivate(var cellule : CelluleRec);

{Utilitaires divers}
procedure RaiseError(message : string);
function LongueurPartieDuGraphe(const whichGame : typePartiePourGraphe) : SignedByte;
function NiemeCoupDansPartieDuGraphe(const whichGame : typePartiePourGraphe;n : SInt16) : SignedByte;
function CouleurDuNiemeCoupDansPartieDuGraphe(const whichGame : typePartiePourGraphe;n : SInt16) : SignedByte;
function NumeroDerniereCellule(var maListe : ListeDeCellules) : SInt32;



IMPLEMENTATION 







 


USES UnitScannerOthellistique,UnitOth2,UnitRapport,UnitMacExtras,UnitStrategie,UnitStringSet,
     UnitServicesDialogs,SNStrings;

                    
    
const tailleBufferCellules = 512;  {doit etre un nombre pair}

var bufferCellules :
      record
        indexDerniereCelluleAjoutee : SInt16; 
        indexDerniereCelluleTrouvee : SInt16; 
        RefFichier : array[0..tailleBufferCellules] of SInt32;
        LesNumCellules : array[0..tailleBufferCellules] of SInt32;
        LesCellules : array[0..tailleBufferCellules] of CelluleRec;
      end;
    nbreEcrituresDansGraphe : SInt32; 
    nbreLecturesDansGraphe : SInt32;


const tailleBufferGraphesOuverts = 5;

var bufferGraphesOuverts:
      record
        noms : StringSet;
        graphes : array[1..tailleBufferGraphesOuverts] of GrapheRec;
        slotEstDisponible : array[0..tailleBufferGraphesOuverts] of boolean;
      end;

var graphesExemptes : StringSet;

procedure VideBufferGrapheApprentissage;
var i : SInt16; 
begin
  with bufferCellules do
    begin
      indexDerniereCelluleAjoutee := 0;
      indexDerniereCelluleTrouvee := 0;
      for i := 0 to tailleBufferCellules do
        begin
          RefFichier[i] := 0;
          LesNumCellules[i] := 0;
          bufferCellules.LesCellules[i].memePosition := 0;
        end;
    end;
end;

procedure InitUnitAccesGrapheApprentissage;
var i : SInt32;
begin
  VideBufferGrapheApprentissage;
  nbreLecturesDansGraphe := 0;
  nbreEcrituresDansGraphe := 0;
  nomGrapheApprentissage := 'Graphe d''apprentissage';
  nomGrapheInterversions := 'Graphe d''interversions';
  
  with bufferGraphesOuverts do
    begin
      noms := MakeEmptyStringSet();
      for i := 1 to tailleBufferGraphesOuverts do
        slotEstDisponible[i] := true;
    end;
    
  graphesExemptes := MakeEmptyStringSet();
end;

procedure LibereMemoireUnitAccesGrapheApprentissage;
begin
  DisposeStringSet(bufferGraphesOuverts.noms);
  DisposeStringSet(graphesExemptes);
end;

function GetCelluleDansBuffer(numeroDansBuffer : SInt16) : CelluleRec;
begin
  GetCelluleDansBuffer := bufferCellules.LesCellules[numeroDansBuffer];
end;

procedure PutCelluleDansBuffer(numeroDansBuffer : SInt16; var fichier : Graphe;numeroDansFichier : SInt32; var cellule : CelluleRec);
begin
  with bufferCellules do
  if (numeroDansBuffer>=0) & (numeroDansBuffer<=tailleBufferCellules) then
    begin
      RefFichier[numeroDansBuffer] := GetUniqueIDFichierTexte(fichier^.fic);
      LesNumCellules[numeroDansBuffer] := numeroDansFichier;
      LesCellules[numeroDansBuffer] := cellule;
    end;
end;

function CelluleEstDansBuffer(var fichier : Graphe;numCellule : SInt32; var numeroDansBuffer : SInt16) : boolean;
var uniqueIDDuFichier : SInt32;
    i,k : SInt16; 
begin
  uniqueIDDuFichier := GetUniqueIDFichierTexte(fichier^.fic);
  
  {on recherche la cellule en commencant par les plus recentes trouvees}
  with bufferCellules do
  for i := 0 to tailleBufferCellules div 2 do
    begin
      k := indexDerniereCelluleTrouvee-i;
      if k<0 then k := k+(tailleBufferCellules+1) else
      if k>tailleBufferCellules then k := k-(tailleBufferCellules+1);
      if (LesNumCellules[k]=numCellule) & (RefFichier[k] = uniqueIDDuFichier) then
         begin
           indexDerniereCelluleTrouvee := k;
           numeroDansBuffer := k;
           CelluleEstDansBuffer := true;
           {WriteStringAndNumDansRapport('dist=',i);}
           exit(CelluleEstDansBuffer);
         end;
      
      k := indexDerniereCelluleTrouvee+i;
      if k<0 then k := k+(tailleBufferCellules+1) else
      if k>tailleBufferCellules then k := k-(tailleBufferCellules+1);
      if (LesNumCellules[k]=numCellule) & (RefFichier[k] = uniqueIDDuFichier) then
         begin
           indexDerniereCelluleTrouvee := k;
           numeroDansBuffer := k;
           CelluleEstDansBuffer := true;
           {WriteStringAndNumDansRapport('dist=',i);}
           exit(CelluleEstDansBuffer);
         end;
    end;
  {dommage !}
  numeroDansBuffer := -1;
  CelluleEstDansBuffer := false;
end;

procedure AddCelluleDansBuffer(var fichier : Graphe;numCellule : SInt32; var cellule : CelluleRec);
begin
  with bufferCellules do
    begin
      indexDerniereCelluleAjoutee := (indexDerniereCelluleAjoutee+1);
      if indexDerniereCelluleAjoutee<0 then indexDerniereCelluleAjoutee := 0;
      if indexDerniereCelluleAjoutee>tailleBufferCellules then indexDerniereCelluleAjoutee := 0;
      indexDerniereCelluleTrouvee := indexDerniereCelluleAjoutee;
      PutCelluleDansBuffer(indexDerniereCelluleAjoutee,fichier,numCellule,cellule);
    end;
end;      

      
procedure RaiseError(message : string);
begin
  AlerteSimple(message);
end;


function NbreSlotsDisponiblesDansBufferGraphesOuverts(var unSlotVide : SInt32) : SInt32;
var sum,k : SInt32;
begin
  sum := 0;
  unSlotVide := -1;
  
  for k := 1 to tailleBufferGraphesOuverts do
    if bufferGraphesOuverts.slotEstDisponible[k] then 
      begin
        inc(sum);
        unSlotVide := k;
      end;
  
  
  
  NbreSlotsDisponiblesDansBufferGraphesOuverts := sum;
end;

procedure AddGrapheDansBufferGraphesOuverts(fichier : Graphe);
var slot,numeroSlotVide : SInt32;
begin
  with bufferGraphesOuverts do
    if (fichier <> NIL) then
    begin
		  if MemberOfStringSet(fichier^.fic.theFSSpec.name,slot,noms) &
		     (slot >= 1) & (slot <= tailleBufferGraphesOuverts)
		    then
		      begin
		        graphes[slot]           := fichier^;
		        slotEstDisponible[slot] := false;
		      end
		    else
		      begin
		        if (NbreSlotsDisponiblesDansBufferGraphesOuverts(numeroSlotVide) > 0) & 
		           (numeroSlotVide >= 1) & (numeroSlotVide <= tailleBufferGraphesOuverts) &
		           (slotEstDisponible[numeroSlotVide])
		          then
		            begin
		              graphes[numeroSlotVide]           := fichier^;
		              slotEstDisponible[numeroSlotVide] := false;
		              AddStringToSet(fichier^.fic.theFSSpec.name,numeroSlotVide,noms);
		              
		              {WritelnDansRapport('ajout de «'+fichier^.fic.theFSSpec.name+'» dans noms');}
		            end
		          else
		            begin
					        WritelnDansRapport('ERREUR : plus de place dans AddGrapheDansBufferGraphesOuverts !! Prevenez Stéphane');
					        WritelnStringAndNumDansRapport('NbreSlotsDisponiblesDansBufferGraphesOuverts = ',NbreSlotsDisponiblesDansBufferGraphesOuverts(numeroSlotVide));
					        WritelnStringAndNumDansRapport('numeroSlotVide = ',numeroSlotVide);
					        AlerteSimple('ERREUR : plus de place dans AddGrapheDansBufferGraphesOuverts !! Prevenez Stéphane');
					      end;
		      end;
		end;
end;

procedure EnleverGrapheDuBufferGraphesOuverts(fichier : Graphe);
var slot : SInt32;
begin
  with bufferGraphesOuverts do
    if (fichier <> NIL) then
      begin
        if MemberOfStringSet(fichier^.fic.theFSSpec.name,slot,noms) &
		       (slot >= 1) & (slot <= tailleBufferGraphesOuverts) then
		      begin
		        RemoveStringFromSet(fichier^.fic.theFSSpec.name,noms);
		        {WritelnDansRapport('retrait de «'+fichier^.fic.theFSSpec.name+'» de noms');}
		        
		        slotEstDisponible[slot] := true;
		      end;
      end;
end;

function TrouveGrapheDansBufferGraphesOuverts(nomDuGraphe : str255; var fichier : Graphe) : boolean;
var slot : SInt32;
begin
  if MemberOfStringSet(nomDuGraphe,slot,bufferGraphesOuverts.noms) &
     (slot >= 1) & (slot <= tailleBufferGraphesOuverts) &
     not(bufferGraphesOuverts.slotEstDisponible[slot])
    then
      begin
        TrouveGrapheDansBufferGraphesOuverts := true;
        fichier := @bufferGraphesOuverts.graphes[slot];
      end
    else
      begin
        TrouveGrapheDansBufferGraphesOuverts := false;
      end;
end;


procedure PreouvrirGraphesUsuels;
var fichier : Graphe;
    dejaOuvert : boolean;
begin
  {WritelnDansRapport('entree dans PreouvrirGraphesUsuels');}
  
  if not(GrapheApprentissageExiste(nomGrapheApprentissage,fichier,dejaOuvert))
    then AddStringToSet(nomGrapheApprentissage,0,graphesExemptes)
    else {ce graphe est desormais ouvert};
  
  if not(GrapheApprentissageExiste(nomGrapheInterversions,fichier,dejaOuvert))
    then AddStringToSet(nomGrapheInterversions,0,graphesExemptes)
    else {ce graphe est desormais ouvert};
    
  {WritelnDansRapport('sortie dans PreouvrirGraphesUsuels');}
  
end;

procedure FermerGraphesUsuels;
var fichier : Graphe;
    dejaOuvert : boolean;
begin
  {WritelnDansRapport('entree dans FermerGraphesUsuels');}
  
  RemoveStringFromSet(nomGrapheApprentissage,graphesExemptes);
  RemoveStringFromSet(nomGrapheInterversions,graphesExemptes);

  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,dejaOuvert) then
    if FermeGrapheApprentissage(fichier) then;
  
  if GrapheApprentissageExiste(nomGrapheInterversions,fichier,dejaOuvert) then
    if FermeGrapheApprentissage(fichier) then;
  
  {WritelnDansRapport('sortie dans FermerGraphesUsuels');}
  
end;

function GrapheApprentissageExiste(var nomDuGraphe : str255; var fichier : Graphe; var grapheEtaitDejaOuvert : boolean) : boolean;
var erreurES : OSErr;
    numeroSlotVide,bidLong : SInt32;
begin
  erreurES := -1;
  grapheEtaitDejaOuvert := false;
  
  {WritelnDansRapport('appel de GrapheApprentissageExiste pour le graphe : '+nomDuGraphe);}
  
  
  if MemberOfStringSet(nomDuGraphe,bidLong,graphesExemptes) then
    begin
      {WritelnDansRapport('exempté : '+nomDuGraphe);}
      GrapheApprentissageExiste := false;
      fichier := NIL;
      grapheEtaitDejaOuvert := false;
      exit(GrapheApprentissageExiste);
    end;
  
  if TrouveGrapheDansBufferGraphesOuverts(nomDuGraphe,fichier)
    then
      begin
        if FichierTexteEstOuvert(fichier^.fic)
          then 
            begin
              {WritelnDansRapport('deja ouvert : '+nomDuGraphe);}
              erreurES := 0;
              grapheEtaitDejaOuvert := true;
            end
          else 
            begin
              WritelnDansRapport('ERREUR (-2) dans GrapheApprentissageExiste !! Prevenez Stéphane');
              erreurES := -2;
              grapheEtaitDejaOuvert := false;
            end;
      end
    else
      begin
        if (NbreSlotsDisponiblesDansBufferGraphesOuverts(numeroSlotVide) > 0) &
           (numeroSlotVide >= 1) & (numeroSlotVide <= tailleBufferGraphesOuverts)
          then
	          begin
	            fichier := @bufferGraphesOuverts.graphes[numeroSlotVide];
	            
	            {WritelnDansRapport('appel de FichierTexteDeCassioExiste pour le graphe : '+nomDuGraphe);}
	            erreurES := FichierTexteDeCassioExiste(nomDuGraphe,fichier^.fic);
	            
						  if (erreurES = NoErr) then
						    begin
						      grapheEtaitDejaOuvert := FichierTexteEstOuvert(fichier^.fic);
						      
						      if grapheEtaitDejaOuvert
						        then
						          begin
						            WritelnDansRapport('BIZARRE : (grapheEtaitDejaOuvert=true) dans GrapheApprentissageExiste !! Prevenez Stéphane');
						            with bufferGraphesOuverts do
						              begin
								            graphes[numeroSlotVide]           := fichier^;
							              slotEstDisponible[numeroSlotVide] := false;
							              AddStringToSet(fichier^.fic.theFSSpec.name,numeroSlotVide,noms);
							            end;
						          end
						        else
						          begin
						            if not(OuvreGrapheApprentissage(fichier)) then erreurES := -3;
						          end;
						        
						    end;
						    
						end
				  else
				    begin
				      fichier := NIL;
				      erreurES := -4;
				      AlerteSimple('ERREUR (-4) dans GrapheApprentissageExiste : trop de graphes ouverts simultanement !!');
				    end; 
			end;
  
  GrapheApprentissageExiste := (erreurES = NoErr);
end;

procedure CreeGrapheApprentissage(var nomDuGraphe : str255; var fichier : Graphe);
var erreurES : OSErr;
begin
  erreurES := CreeFichierTexteDeCassio(nomDuGraphe,fichier^.fic);
  fichier^.nbCellules := -1;
end;

function OuvreGrapheApprentissage(var fichier : Graphe) : boolean;
var erreurES : OSErr;
begin
  fichier^.nbCellules := -1;
  erreurES := OuvreFichierTexte(fichier^.fic);
  
  if (erreurES=NoErr) then 
    begin
      RecalculerNbrePositionsDansGrapheApprentissage(fichier);
      AddGrapheDansBufferGraphesOuverts(fichier);
		end;
						        
  OuvreGrapheApprentissage := (erreurES=NoErr);
end;

function FermeGrapheApprentissage(var fichier : Graphe) : boolean;
var erreurES : OSErr;
begin
  erreurES := FermeFichierTexte(fichier^.fic);
  FermeGrapheApprentissage := (erreurES=NoErr);
  
  EnleverGrapheDuBufferGraphesOuverts(fichier);
  
  SetFileCreatorFichierTexte(fichier^.fic,'SNX4');
  SetFileTypeFichierTexte(fichier^.fic,'GRAP');
  fichier^.nbCellules := -1;
end;

function NbrePositionsDansGrapheApprentissage(var fichier : Graphe) : SInt32;
var long,erreurES : SInt32;
begin
  with fichier^ do
    begin
      if nbCellules<=0 then {recalculer le nombre de positions du graphe d'apres la taille du fichier}
        begin
          erreurES := GetTailleFichierTexte(fic,long);
          if long<=TailleHeaderGraphe
            then nbCellules := 0
            else nbCellules := (long-TailleHeaderGraphe) div sizeof(CelluleRec);
          {WritelnStringAndNumDansRapport('Disk -> nbCellules=',nbCellules);}
        end;
        {else WritelnDansRapport('No disk');}
        
      NbrePositionsDansGrapheApprentissage := nbCellules;
    end;
end;

procedure RecalculerNbrePositionsDansGrapheApprentissage(var fichier : Graphe);
var nbrePositions : SInt32;
begin
  fichier^.nbCellules := -1;  {pour forcer le recalcul lors de l'appel a NbrePositionsDansGrapheApprentissage}
  nbrePositions := NbrePositionsDansGrapheApprentissage(fichier);
end;

procedure VideGrapheApprentissage(var fichier : Graphe);
var erreurES : SInt32;
begin
  erreurES := SetEOFFichierTexte(fichier^.fic,TailleHeaderGraphe);
  fichier^.nbCellules := 0;
  VideBufferGrapheApprentissage;
end;

procedure LitCellule(var fichier : Graphe;numCellule : SInt32; var cellule : CelluleRec);
var position,count : SInt32;
    erreurES : OSErr;
    EmplacementDansBuffer : SInt16; 
begin
  if (1<=numCellule) & (numCellule<=NbrePositionsDansGrapheApprentissage(fichier)) then
    begin
      
      if CelluleEstDansBuffer(fichier,numCellule,EmplacementDansBuffer)
        then 
          begin
            cellule := GetCelluleDansBuffer(EmplacementDansBuffer);
            {WriteStringAndNumDansRapport(' no disk=',EmplacementDansBuffer);
            WritelnStringAndNumDansRapport('  rec=',buffercellules.indexDerniereCelluleAjoutee);}
          end
        else
          begin      
			      position := TailleHeaderGraphe+(numCellule-1)*sizeof(CelluleRec);
			      erreurES := SetPositionTeteLectureFichierTexte(fichier^.fic,position);
			      if (erreurES<>NoErr) then 
			        begin
			          WritelnDansRapport('erreurES <> 0 dans LitCellule (1) !!');
			          exit(LitCellule);
			        end;
			        
			      count := sizeof(CelluleRec);
			      erreurES := ReadBufferDansFichierTexte(fichier^.fic,@cellule,count);
			      
			      if (erreurES<>NoErr) then 
			        begin
			          WritelnDansRapport('erreurES <> 0 dans LitCellule (2) !!');
			          exit(LitCellule);
			        end;
			      
			      nbreLecturesDansGraphe := nbreLecturesDansGraphe+1;
			      AddCelluleDansBuffer(fichier,numCellule,cellule);
			      {WritelnStringAndNumDansRapport('disk #',numCellule);}
			    end;
    end;
end;

procedure EcritCellule(var fichier : Graphe;numCellule : SInt32; var cellule : CelluleRec);
var position,count,nbCellulesDansGraphe : SInt32;
    erreurES : OSErr;
    EmplacementDansBuffer : SInt16; 
    dejaDansBuffer,nouvelleCellule : boolean;
begin
  nbCellulesDansGraphe := NbrePositionsDansGrapheApprentissage(fichier);
  if (1<=numCellule) & (numCellule<=nbCellulesDansGraphe+1) then
    begin
      nouvelleCellule := (numCellule=(nbCellulesDansGraphe+1));
      dejaDansBuffer := not(nouvelleCellule) & CelluleEstDansBuffer(fichier,numCellule,EmplacementDansBuffer);
      
      if not(dejaDansBuffer) | not(MemesCellules(cellule,GetCelluleDansBuffer(EmplacementDansBuffer))) then
        begin
          position := TailleHeaderGraphe+(numCellule-1)*sizeof(CelluleRec);
          erreurES := SetPositionTeteLectureFichierTexte(fichier^.fic,position);
          
          if (erreurES<>NoErr) then 
			      begin
			        WritelnDansRapport('erreurES <> 0 dans EcritCellule (1) !!');
			        exit(EcritCellule);
			      end;
			        
          count := sizeof(CelluleRec);
          erreurES := WriteBufferDansFichierTexte(fichier^.fic,@cellule,count);
          
          if (erreurES<>NoErr) then 
			      begin
			        WritelnDansRapport('erreurES <> 0 dans EcritCellule (2) !!');
			        exit(EcritCellule);
			      end;
			      
          nbreEcrituresDansGraphe := nbreEcrituresDansGraphe+1;
          if nouvelleCellule 
            then 
              begin
                fichier^.nbCellules := numCellule;
                {WritelnDansRapport('## Ajout d''une cellule dans le graphe (#'+NumEnString(numCellule)+') ##');}
              end
            else 
              begin
                {WritelnDansRapport('## Ecriture simple d''une cellule dans le graphe ##');}
              end;
      
          if dejaDansBuffer
            then PutCelluleDansBuffer(EmplacementDansBuffer,fichier,numCellule,cellule)
            else AddCelluleDansBuffer(fichier,numCellule,cellule);
        end
        else
          {WritelnDansRapport('Deja dans buffer dans EcritCellule !!')};
    end;
end;


procedure AfficheCelluleDansRapport(var fichier : Graphe;num : SInt32; var cellule : CelluleRec);
var couleur,trait : SignedByte;
    celluleAux : CelluleRec;
begin
  with cellule do
    begin
      WritelnDansRapport('-------------- #'+NumEnString(num)+'# -----------------');
      WriteDansRapport('   '+NumEnString(GetNumeroCoup(cellule))+StringOf('.')+CoupEnStringEnMajuscules(GetCoup(cellule)));
      couleur := GetCouleur(cellule);
      case couleur of
        Noir :WriteDansRapport('    couleur=Noir');
        Blanc:WriteDansRapport('    couleur=Blanc');
        otherwise WriteDansRapport('    couleur inderterminée !!!!');
      end; {case}
      trait := GetTrait(cellule);
      case trait of
        Noir :WritelnDansRapport('    trait après=Noir');
        Blanc:WritelnDansRapport('    trait après=Blanc');
        otherwise WritelnDansRapport('    trait après inderterminé !!!!');
      end; {case}
      
      {on affiche le pere}
      WriteDansRapport('   pere='+NumEnString(pere));
      if (pere <> 0) & (pere <> PasDePere) then 
        begin
          LitCellule(fichier,pere,celluleAux);
          WriteDansRapport('               ('+NumEnString(GetNumeroCoup(celluleAux))+StringOf('.')+
                                 CoupEnStringEnMajuscules(GetCoup(celluleAux))+')');
        end;
      WritelnDansRapport('');
      
      {on affiche le frere}
      WriteDansRapport('   frere='+NumEnString(frere));
      if (frere <> 0) & (frere <> num) then 
        begin
          LitCellule(fichier,frere,celluleAux);
          WriteDansRapport('             ('+NumEnString(GetNumeroCoup(celluleAux))+StringOf('.')+
                                 CoupEnStringEnMajuscules(GetCoup(celluleAux))+')');
        end;
      WritelnDansRapport('');
        
      {on affiche le fils}
      WriteDansRapport('   fils='+NumEnString(fils));
      if (fils <> 0) & (fils <> PasDeFils) then 
        begin
          LitCellule(fichier,fils,celluleAux);
          WriteDansRapport('                 ('+NumEnString(GetNumeroCoup(celluleAux))+StringOf('.')+
                                 CoupEnStringEnMajuscules(GetCoup(celluleAux))+')');
        end;
      WritelnDansRapport('');
      
      {on affiche le memePosition}
      WriteDansRapport('   memePosition='+NumEnString(memePosition));
      if (memePosition <> 0) & (memePosition <> num) then 
        begin
          LitCellule(fichier,memePosition,celluleAux);
          WriteDansRapport('     ('+NumEnString(GetNumeroCoup(celluleAux))+StringOf('.')+
                                 CoupEnStringEnMajuscules(GetCoup(celluleAux))+')');
        end;
      WritelnDansRapport('');
          
      case GetValeurMinimax(cellule) of
        kGainDansT                : if couleur=Noir
                                     then WritelnDansRapport('   Noir est gagnant')
                                     else WritelnDansRapport('   Blanc est gagnant');
        kGainAbsolu               : if couleur=Noir
                                     then WritelnDansRapport('   Noir est gagnant (prouvé)')
                                     else WritelnDansRapport('   Blanc est gagnant (prouvé)');
        kNulleDansT               : WritelnDansRapport('   Nulle');
        kNulleAbsolue             : WritelnDansRapport('   Nulle (prouvée)');
        kPerteDansT               : if couleur=Noir
                                     then WritelnDansRapport('   Noir est perdant')
                                     else WritelnDansRapport('   Blanc est perdant');
        kPerteAbsolue             : if couleur=Noir
                                     then WritelnDansRapport('   Noir est perdant (prouvé)')
                                     else WritelnDansRapport('   Blanc est perdant (prouvé)');
        kPropositionHeuristique   : WritelnDansRapport('   c''est une proposition heuristique');
        kPasDansT: WritelnDansRapport('   pas dans l''arbre');
      end; {case}
      
      WritelnStringAndNumDansRapport('   valeurMinimax=',GetValeurMinimax(cellule));
      WritelnStringAndNumDansRapport('   valeurDeviantePourNoir=',GetValeurDeviantePourNoir(cellule));
      WritelnStringAndNumDansRapport('   valeurDeviantePourBlanc=',GetValeurDeviantePourBlanc(cellule));
      WritelnStringAndNumDansRapport('   proofNumberPourNoir=',GetProofNumberPourNoir(cellule));
      WritelnStringAndNumDansRapport('   proofNumberPourBlanc=',GetProofNumberPourBlanc(cellule));
      WritelnStringAndNumDansRapport('   disproofNumberPourNoir=',GetDisproofNumberPourNoir(cellule));
      WritelnStringAndNumDansRapport('   disproofNumberPourBlanc=',GetDisproofNumberPourBlanc(cellule));
      WritelnStringAndReelDansRapport('   esperanceDeGainPourNoir=',GetEsperanceDeGainPourNoir(cellule),5);
      WritelnStringAndReelDansRapport('   esperanceDeGainPourBlanc=',GetEsperanceDeGainPourBlanc(cellule),5);
      WritelnStringAndNumDansRapport('   valeurHeuristiquePourNoir=',GetValeurHeuristiquePourNoir(cellule));

      
      WritelnDansRapport('   profondeur='+NumEnString(GetProfondeur(cellule)));
      WritelnDansRapport('   version='+NumEnString(GetVersion(cellule)));
      
    end;
end;

procedure InitialiseCellule(var cellule : CelluleRec;numCellule : SInt32);
begin
  with cellule do
    begin
      pere := PasDePere;
      fils := PasDeFils;
      frere := numCellule;
      memePosition := numCellule;
      CoupEtCouleurs := 0;
      numeroDuCoup := 0;
      valeurMinimax := kPasDansT;
      VersionEtprofondeur := kVersionEtProfondeurIndeterminee;
      
      ProofNumberPourNoir     := ValeurIndeterminee;
      DisproofNumberPourNoir  := ValeurIndeterminee;
      ProofNumberPourBlanc    := ValeurIndeterminee;
      DisProofNumberPourBlanc := ValeurIndeterminee;
      ValeurDeviantePourNoir  := ValeurIndeterminee;
      ValeurDeviantePourBlanc := ValeurIndeterminee;
      EsperanceDeGainPourNoir := ValeurIndeterminee;
      EsperanceDeGainPourBlanc := ValeurIndeterminee;
      ValeurHeuristiquePourNoir := ValeurIndeterminee;
      flags                   := 0;  

    end;
end;

procedure IsoleCellule(var fichier : Graphe;numCellule : SInt32);
var cellule : CelluleRec;
begin
  LitCellule(fichier,numCellule,cellule);
  with cellule do
    begin
      numeroDuCoup := 0;
      CoupEtCouleurs := 0;
      pere := PasDePere;
      frere := PasDeFrere;
      fils := PasDeFils;
    end;
  EcritCellule(fichier,numCellule,cellule);
end;


function GetNbreEcrituresDansGraphe() : SInt32;
begin
  GetNbreEcrituresDansGraphe := nbreEcrituresDansGraphe;
end;

function GetNbreLecturesDansGraphe() : SInt32;
begin
  GetNbreLecturesDansGraphe := nbreLecturesDansGraphe;
end;

function GetCoupOfCelluleNumero(var fichier : Graphe;numeroCellule : SInt32);
var CellAux : CelluleRec;
begin
  LitCellule(fichier,numeroCellule,CellAux);
  GetCoupOfCelluleNumero := GetCoup(CellAux);
end;      

function GetNiemeCoupDansListe(var fichier : Graphe; var L : ListeDeCellules;n : SInt16) : byte;
begin
  GetNiemeCoupDansListe := GetCoupOfCelluleNumero(fichier,L.liste[n].numeroCellule);
end;

function GetPere(var cellule : CelluleRec) : SInt32;
begin
  GetPere := cellule.pere;
end;

function GetFils(var cellule : CelluleRec) : SInt32;
begin
  GetFils := cellule.fils;
end;

function GetFrere(var cellule : CelluleRec) : SInt32;
begin
  GetFrere := cellule.frere;
end;

function GetMemePosition(var cellule : CelluleRec) : SInt32;
begin
  GetMemePosition := cellule.memePosition;
end;

procedure SetPere(thePere : SInt32; var cellule : CelluleRec);
begin
  cellule.pere := thePere;
end;

procedure SetFils(theFils : SInt32; var cellule : CelluleRec);
begin
  cellule.fils := theFils;
end;

procedure SetFrere(theFrere : SInt32; var cellule : CelluleRec);
begin
  cellule.frere := theFrere;
end;

procedure SetMemePosition(theMemePosition : SInt32; var cellule : CelluleRec);
begin
  cellule.memePosition := theMemePosition;
end;
                    
function GetCoup(var cellule : CelluleRec) : byte;
var aux : byte;
begin
  aux := BSR(BAND(cellule.CoupEtCouleurs,$FC),2);
  GetCoup := (aux div 8)*10+(aux mod 8) +11;
end;    

procedure SetCoup(coup : byte; var cellule : CelluleRec);
var aux : byte;
begin
  aux := BSL((((coup div 10)-1)*8 + (coup mod 10) - 1),2);
  cellule.CoupEtCouleurs := aux + BAND(cellule.CoupEtCouleurs,$03);
end;                                    

function GetCouleur(var cellule : CelluleRec) : SignedByte;
begin
  if BAND(cellule.CoupEtCouleurs,$02) <> 0
    then GetCouleur := Noir
    else GetCouleur := Blanc;
end;    

procedure SetCouleur(couleur : SignedByte; var cellule : CelluleRec);
begin
  if couleur=Noir
    then cellule.CoupEtCouleurs := $02+BAND(cellule.CoupEtCouleurs,$FD)
    else cellule.CoupEtCouleurs :=     BAND(cellule.CoupEtCouleurs,$FD);
end;                                    
      
function GetTrait(var cellule : CelluleRec) : SignedByte;
begin
  if BAND(cellule.CoupEtCouleurs,$01) <> 0
    then GetTrait := Noir
    else GetTrait := Blanc;
end;    

procedure SetTrait(trait : SignedByte; var cellule : CelluleRec);
begin
  if trait=Noir
    then cellule.CoupEtCouleurs := $01+BAND(cellule.CoupEtCouleurs,$FE)
    else cellule.CoupEtCouleurs :=     BAND(cellule.CoupEtCouleurs,$FE);
end;    

function GetNumeroCoup(var cellule : CelluleRec) : byte;
begin
  GetNumeroCoup := cellule.numeroDuCoup;
end;

procedure SetNumeroCoup(numero : byte; var cellule : CelluleRec);
begin
  cellule.numeroDuCoup := numero;
end;
                            

function GetProfondeur(var cellule : CelluleRec) : byte;
var aux : byte;
begin
  aux := BSR(BAND(cellule.VersionEtProfondeur,$F8),3);
  GetProfondeur := aux;
end;        

procedure SetProfondeur(prof : byte; var cellule : CelluleRec);
var aux : byte;
begin
  if (prof>=0) & (prof<=31) then
    begin
      aux := BSL(prof,3);
      cellule.VersionEtProfondeur := aux + BAND(cellule.VersionEtProfondeur,$07);
    end;
end; 

function GetVersion(var cellule : CelluleRec) : byte;
var aux : byte;
begin
  aux := BAND(cellule.VersionEtProfondeur,$07);
  GetVersion := aux;
end;        

procedure SetVersion(version : byte; var cellule : CelluleRec);
begin
  if (version>=0) & (version<=7) then
    cellule.VersionEtProfondeur := version + BAND(cellule.VersionEtProfondeur,$F8);
end; 


function GetValeurMinimax(var cellule : CelluleRec) : byte;
begin
  GetValeurMinimax := cellule.valeurMinimax;
end;

function GetProofNumberPourNoir(var cellule : CelluleRec) : SInt16; 
begin
  GetProofNumberPourNoir := cellule.ProofNumberPourNoir;
end;

function GetProofNumberPourBlanc(var cellule : CelluleRec) : SInt16; 
begin
  GetProofNumberPourBlanc := cellule.ProofNumberPourBlanc;
end;

function GetDisproofNumberPourNoir(var cellule : CelluleRec) : SInt16; 
begin
  GetDisproofNumberPourNoir := cellule.DisproofNumberPourNoir;
end;

function GetDisproofNumberPourBlanc(var cellule : CelluleRec) : SInt16; 
begin
  GetDisproofNumberPourBlanc := cellule.DisproofNumberPourBlanc;
end;

function GetValeurDeviantePourNoir(var cellule : CelluleRec) : SInt16; 
begin
  GetValeurDeviantePourNoir := cellule.ValeurDeviantePourNoir;
end;

function GetValeurDeviantePourBlanc(var cellule : CelluleRec) : SInt16; 
begin
  GetValeurDeviantePourBlanc := cellule.ValeurDeviantePourBlanc;
end;

function GetValeurHeuristiquePourNoir(var cellule : CelluleRec) : SInt16; 
begin
  if cellule.VersionEtProfondeur=kVersionEtProfondeurIndeterminee
    then GetValeurHeuristiquePourNoir := valeurIndeterminee
    else GetValeurHeuristiquePourNoir := cellule.ValeurHeuristiquePourNoir;
end;

function GetEsperanceDeGainPourNoir(var cellule : CelluleRec) : extended;
var aux : SInt16; 
    res : extended;
begin
  aux := cellule.EsperanceDeGainPourNoir;
  if aux=valeurIndeterminee
    then GetEsperanceDeGainPourNoir := esperanceIndeterminee
    else
      begin
			  if aux<-10000 then aux := -10000;
			  if aux>10000 then aux := 10000;
			  res := (0.5 + aux*0.00005);
			  if res<0.0 then res := 0.0;
			  if res>1.0 then res := 1.0;
			  GetEsperanceDeGainPourNoir := (0.5 + aux*0.00005);
			end;
end;

function GetEsperanceDeGainPourBlanc(var cellule : CelluleRec) : extended;
var aux : SInt16; 
    res : extended;
begin
  aux := cellule.EsperanceDeGainPourBlanc;
  if aux=valeurIndeterminee
    then GetEsperanceDeGainPourBlanc := esperanceIndeterminee
    else
      begin
			  aux := cellule.EsperanceDeGainPourBlanc;
			  if aux<-10000 then aux := -10000;
			  if aux>10000 then aux := 10000;
			  res := (0.5 + aux*0.00005);
			  if res<0.0 then res := 0.0;
			  if res>1.0 then res := 1.0;
			  GetEsperanceDeGainPourBlanc := res;
			end;
end;

function GetProofNumber(var cellule : CelluleRec;couleur : SInt16) : SInt16; 
begin
  case couleur of
    Noir      : GetProofNumber := GetProofNumberPourNoir(cellule);
    Blanc     : GetProofNumber := GetProofNumberPourBlanc(cellule);
    otherwise   WritelnDansRapport(' ERROR : couleur inderterminée dans GetProofNumber !!!!');
  end; {case}
end;

function GetDisproofNumber(var cellule : CelluleRec;couleur : SInt16) : SInt16; 
begin
  case couleur of
    Noir      : GetDisproofNumber := GetDisProofNumberPourNoir(cellule);
    Blanc     : GetDisproofNumber := GetDisProofNumberPourBlanc(cellule);
    otherwise   WritelnDansRapport(' ERROR : couleur inderterminée dans GetDisProofNumber !!!!');
  end; {case}
end;

function GetValeurDeviante(var cellule : CelluleRec;couleur : SInt16) : SInt16; 
begin
  case couleur of
    Noir      : GetValeurDeviante := GetValeurDeviantePourNoir(cellule);
    Blanc     : GetValeurDeviante := GetValeurDeviantePourBlanc(cellule);
    otherwise   WritelnDansRapport(' ERROR : couleur inderterminée dans GetValeurDeviante !!!!');
  end; {case}
end;

function GetEsperanceDeGain(var cellule : CelluleRec;couleur : SInt16) : extended;
begin
  case couleur of
    Noir      : GetEsperanceDeGain := GetEsperanceDeGainPourNoir(cellule);
    Blanc     : GetEsperanceDeGain := GetEsperanceDeGainPourBlanc(cellule);
    otherwise   WritelnDansRapport(' ERROR : couleur inderterminée dans GetEsperanceDeGain !!!!');
  end; {case}
end;

function GetFlags(var cellule : CelluleRec) : SInt16; 
begin
  GetFlags := cellule.flags;
end;

function HasFlagAttribute(var cellule : CelluleRec;flagMask : SInt16) : boolean;
begin
  HasFlagAttribute := BAND(cellule.flags,flagMask) <> 0;
end;

procedure SetValeurMinimax(var cellule : CelluleRec;val : byte);
begin
  cellule.valeurMinimax := val;
end;

procedure SetProofNumberPourNoir(var cellule : CelluleRec;val : SInt16);
begin
  cellule.ProofNumberPourNoir := val;
end;

procedure SetProofNumberPourBlanc(var cellule : CelluleRec;val : SInt16);
begin
  cellule.ProofNumberPourBlanc := val;
end;

procedure SetDisproofNumberPourNoir(var cellule : CelluleRec;val : SInt16);
begin
  cellule.DisproofNumberPourNoir := val;
end;

procedure SetDisproofNumberPourBlanc(var cellule : CelluleRec;val : SInt16);
begin
  cellule.DisproofNumberPourBlanc := val;
end;

procedure SetValeurDeviantePourNoir(var cellule : CelluleRec;val : SInt16);
begin
  cellule.ValeurDeviantePourNoir := val;
end;

procedure SetValeurDeviantePourBlanc(var cellule : CelluleRec;val : SInt16);
begin
  cellule.ValeurDeviantePourBlanc := val;
end;

procedure SetEsperanceDeGainPourNoir(var cellule : CelluleRec;val : extended);
var aux : SInt16; 
begin
  aux := MyTrunc((val-0.5)*10000.0);
  if aux<-10000 then aux := -10000;
  if aux>10000 then aux := 10000;
  cellule.EsperanceDeGainPourNoir := aux;
end;

procedure SetEsperanceDeGainPourBlanc(var cellule : CelluleRec;val : extended);
var aux : SInt16; 
begin
  aux := MyTrunc((val-0.5)*10000.0);
  if aux<-10000 then aux := -10000;
  if aux>10000 then aux := 10000;
  cellule.EsperanceDeGainPourBlanc := aux;
end;

procedure SetValeurHeuristiquePourNoir(var cellule : CelluleRec;val : SInt16);
begin
  cellule.ValeurHeuristiquePourNoir := val;
end;

procedure SetProofNumber(var cellule : CelluleRec;couleur : SInt16; val : SInt16);
begin
  case couleur of
    Noir      : SetProofNumberPourNoir(cellule,val);
    Blanc     : SetProofNumberPourBlanc(cellule,val);
    otherwise   WritelnDansRapport(' ERROR : couleur inderterminée dans SetProofNumber !!!!');
  end; {case}
end;

procedure SetDisproofNumber(var cellule : CelluleRec;couleur : SInt16; val : SInt16);
begin
  case couleur of
    Noir      : SetDisproofNumberPourNoir(cellule,val);
    Blanc     : SetDisproofNumberPourBlanc(cellule,val);
    otherwise   WritelnDansRapport(' ERROR : couleur inderterminée dans SetDisproofNumber !!!!');
  end; {case}
end;

procedure SetValeurDeviante(var cellule : CelluleRec;couleur : SInt16; val : SInt16);
begin
  case couleur of
    Noir      : SetValeurDeviantePourNoir(cellule,val);
    Blanc     : SetValeurDeviantePourBlanc(cellule,val);
    otherwise   WritelnDansRapport(' ERROR : couleur inderterminée dans SetValeurDeviante !!!!');
  end; {case}
end;

procedure SetEsperanceDeGain(var cellule : CelluleRec;couleur : SInt16; val : extended);
begin
  case couleur of
    Noir      : SetEsperanceDeGainPourNoir(cellule,val);
    Blanc     : SetEsperanceDeGainPourBlanc(cellule,val);
    otherwise   WritelnDansRapport(' ERROR : couleur inderterminée dans SetEsperanceDeGain !!!!');
  end; {case}
end;

procedure SetFlags(var cellule : CelluleRec;theFlags : SInt16);
begin
  cellule.flags := theFlags;
end;

procedure AddFlagAttribute(var cellule : CelluleRec;flagMask : SInt16);
begin
  cellule.flags := BOR(cellule.flags,flagMask);
end;

procedure RemoveFlagAttribute(var cellule : CelluleRec;flagMask : SInt16);
begin
  if BAND(cellule.flags,flagMask) <> 0 then
    cellule.flags := BXOR(cellule.flags,flagMask); 
end;

function MemesCellules(const cellule1,cellule2 : CelluleRec) : boolean;
begin
  MemesCellules := (cellule1.pere                      = cellule2.pere) &
                  (cellule1.fils										  = cellule2.fils) &
                  (cellule1.frere                     = cellule2.frere) &
                  (cellule1.memePosition						  = cellule2.memePosition) &
                  (cellule1.CoupEtCouleurs						= cellule2.CoupEtCouleurs) &
                  (cellule1.valeurMinimax						  = cellule2.valeurMinimax) &
                  (cellule1.numeroDuCoup						  = cellule2.numeroDuCoup) &
                  (cellule1.VersionEtProfondeur			  = cellule2.VersionEtProfondeur) &
                  (cellule1.ProofNumberPourNoir			  = cellule2.ProofNumberPourNoir) &
                  (cellule1.DisproofNumberPourNoir    = cellule2.DisproofNumberPourNoir) &
                  (cellule1.ProofNumberPourBlanc			= cellule2.ProofNumberPourBlanc) &
                  (cellule1.DisProofNumberPourBlanc	  = cellule2.DisProofNumberPourBlanc) &
                  (cellule1.ValeurDeviantePourNoir		= cellule2.ValeurDeviantePourNoir) &
                  (cellule1.ValeurDeviantePourBlanc	  = cellule2.ValeurDeviantePourBlanc) &
                  (cellule1.EsperanceDeGainPourNoir	  = cellule2.EsperanceDeGainPourNoir) &
                  (cellule1.EsperanceDeGainPourBlanc	= cellule2.EsperanceDeGainPourBlanc) &
                  (cellule1.ValeurHeuristiquePourNoir = cellule2.ValeurHeuristiquePourNoir) &
                  (cellule1.flags										  = cellule2.flags);
end;

function IsPublic(var cellule : CelluleRec) : boolean;
begin
  IsPublic := not(HasFlagAttribute(cellule,kPrivateMask));
end;

function IsPrivate(var cellule : CelluleRec) : boolean;
begin
  IsPrivate := HasFlagAttribute(cellule,kPrivateMask);
end;


function EstDansT(var cellule : CelluleRec) : boolean;
begin
  EstDansT := (cellule.valeurMinimax = kGainDansT)    |
              (cellule.valeurMinimax = kGainAbsolu)   |
              (cellule.valeurMinimax = kNulleDansT)   |
              (cellule.valeurMinimax = kNulleAbsolue) |
              (cellule.valeurMinimax = kPerteDansT)   |
              (cellule.valeurMinimax = kPerteAbsolue);
end;

function EstUnePropositionHeuristique(var cellule : CelluleRec) : boolean;
begin
  EstUnePropositionHeuristique := (cellule.valeurMinimax=kPropositionHeuristique);
end;

function AuMoinsUnFils(var fichier : Graphe;numCellule : SInt32) : boolean;
var cellule : CelluleRec;
begin
  LitCellule(fichier,numCellule,cellule);
  AuMoinsUnFils := HasFils(cellule);
end;

function HasPere(var cellule : CelluleRec) : boolean;
begin
  HasPere := GetPere(cellule)<>pasDePere;
end;

function HasFrere(var cellule : CelluleRec) : boolean;
begin
  HasFrere := GetFrere(cellule)<>pasDeFrere;
end;

function HasFils(var cellule : CelluleRec) : boolean;
begin
  HasFils := GetFils(cellule)<>pasDeFils;
end;

procedure SetPublic(var cellule : CelluleRec);
begin
  RemoveFlagAttribute(cellule,kPrivateMask);
end;

procedure SetPrivate(var cellule : CelluleRec);
begin
  AddFlagAttribute(cellule,kPrivateMask);
end;


function LongueurPartieDuGraphe(const whichGame : typePartiePourGraphe) : SignedByte;
begin
  LongueurPartieDuGraphe := Length(whichGame);
end;

function NiemeCoupDansPartieDuGraphe(const whichGame : typePartiePourGraphe; n : SInt16) : SignedByte;
begin
  if (n>0) & (n<=60) & (n<=LongueurPartieDuGraphe(whichGame))
    then NiemeCoupDansPartieDuGraphe := ord(whichGame[n])
    else NiemeCoupDansPartieDuGraphe := 0;
end;

function CouleurDuNiemeCoupDansPartieDuGraphe(const whichGame : typePartiePourGraphe; n : SInt16) : SignedByte;
var plat : plateauOthello;
    trait,i : SInt16; 
    bidon : boolean;
begin
  CouleurDuNiemeCoupDansPartieDuGraphe := 0;
  OthellierDeDepart(plat);
  trait := Noir;
  for i := 1 to Min(Length(whichGame),60) do
    begin
      if (i=n) then 
        begin
          if ModifPlatSeulement(ord(whichGame[i]),plat,trait) then CouleurDuNiemeCoupDansPartieDuGraphe := trait else
          if ModifPlatSeulement(ord(whichGame[i]),plat,-trait) then CouleurDuNiemeCoupDansPartieDuGraphe := -trait else
            CouleurDuNiemeCoupDansPartieDuGraphe := pionVide;
          exit(CouleurDuNiemeCoupDansPartieDuGraphe);
        end;
      if ModifPlatSeulement(ord(whichGame[i]),plat,trait)
        then trait := -trait
        else bidon := ModifPlatSeulement(ord(whichGame[i]),plat,-trait);
    end;
end;


function NumeroDerniereCellule(var maListe : ListeDeCellules) : SInt32;
begin
  if (maListe.cardinal<1) | (maListe.cardinal > TaileMaxListeDeCoups)
    then 
      begin
        NumeroDerniereCellule := -1;
        WritelnDansRapport('## WARNING Je renvoie -1 dans NumeroDerniereCellule…');
      end
    else NumeroDerniereCellule := maListe.liste[maListe.cardinal].numeroCellule;
end;



END.