UNIT UnitNouveauFormat;



INTERFACE







USES UnitDefinitionsNouveauFormat;
      
      
     
      
{Initialisation et destruction}
procedure InitUnitNouveauFormat;
procedure LibereMemoireUnitNouveauFormat;
function PathDuDossierDatabase() : str255;

{Lecture des donnees sur le disque}
function OuvreFichierNouveauFormat(numFichier : SInt16) : OSErr;
function LitPartieNouveauFormat(numFichier : SInt16; nroPartie : SInt32;enAvancant : boolean; var theGame:t_PartieRecNouveauFormat) : OSErr;
function LitJoueurNouveauFormat(numFichier : SInt16; nroJoueur : SInt32; var joueur:str30) : OSErr;
function LitTournoiNouveauFormat(numFichier : SInt16; nroTournoi : SInt32; var tournoi:str30) : OSErr;
function LitEnteteNouveauFormat(refnum : SInt16; var entete : t_EnTeteNouveauFormat) : OSErr;
function FermeFichierNouveauFormat(numFichier : SInt16) : OSErr;

{Ecriture des donnees sur disque}
function EcritEnteteNouveauFormat(refnum : SInt16; entete : t_EnTeteNouveauFormat) : OSErr;
function EcritPartieNouveauFormat(refnum : SInt16; nroPartie : SInt32;theGame : t_PartieRecNouveauFormat) : OSErr;
function EcritJoueurNouveauFormat(refnum : SInt16; nroJoueur : SInt32;thePlayer : t_JoueurRecNouveauFormat) : OSErr;
function EcritTournoiNouveauFormat(refnum : SInt16; nroTournoi : SInt32;theTourney : t_TournoiRecNouveauFormat) : OSErr;

{Gestion de la memoire}
function AllocateMemoireIndexNouveauFormat(var nbParties : SInt32) : OSErr;
function AllocateMemoireListePartieNouveauFormat(var nbParties : SInt32) : OSErr; 
function AllocateMemoireJoueursNouveauFormat(var nbJoueurs : SInt32) : OSErr;
function AllocateMemoireTournoisNouveauFormat(var nbTournois : SInt32) : OSErr;
procedure DisposeIndexNouveauFormat;
procedure DisposeListePartiesNouveauFormat; 
procedure DisposeJoueursNouveauFormat;
procedure DisposeTournoisNouveauFormat;


{Fonctions de comptage} 
function NbPartiesFichierNouveauFormat(numFichier : SInt16) : SInt32;
function AnneePartiesFichierNouveauFormat(numFichier : SInt16) : SInt16; 
function NbJoueursDansFichierJoueursNouveauFormat(numFichier : SInt16) : SInt32;
function NbTotalDeJoueursDansFichiersNouveauFormat(typeVoulu : SInt16; var nbFichiersJoueurs,placeMemoireNecessaire : SInt32) : SInt32;
function NbTournoisDansFichierTournoisNouveauFormat(numFichier : SInt16) : SInt32;
function NbTotalDeTournoisDansFichiersNouveauFormat(typeVoulu : SInt16; var nbFichiersTournois,placeMemoireNecessaire : SInt32) : SInt32;
function NbTotalPartiesDansDistributionSet(ensemble:DistributionSet) : SInt32;

{Fonctions de lecture recursive du dossier Database}
procedure LecturePreparatoireDossierDatabase(vRefNum : SInt16);
procedure ChercheFichiersNouveauFormatDansDossier(vRefNum : SInt16; NomDossier : str255; var dossierTrouve : boolean);
function AjouterFichierNouveauFormat(fic : FSSpec;path : str255;typeDonneesDuFichier : SInt16; EnteteFichier : t_EnTeteNouveauFormat) : boolean;
function CalculePathFichierNouveauFormat(nroFichier : SInt16) : str255;
function CalculeNomFichierNouveauFormat(nroFichier : SInt16) : str255;
function GetNroPremierFichierAvecCeTypeDeDonnees(CeTypeDeDonnees : SInt16) : SInt16; 


{Fonctions de test}
function EstUnFichierNouveauFormat(fic : FSSpec; var typeDonnees : SInt16; var entete : t_EnTeteNouveauFormat) : boolean;
function EntetesEgauxNouveauFormat(entete1,entete2 : t_EnTeteNouveauFormat) : boolean;
function EntetePlusRecentNouveauFormat(entete1,entete2 : t_EnTeteNouveauFormat) : boolean;


{Gestion des distributions}
function EstUneDistributionConnue(nomTest,pathTest : str255; var nroDistrib : SInt16) : boolean;
function NomDistributionAssocieeNouveauFormat(ficName : str255; var anneeDansDistrib : SInt16) : str255;
function TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat(nroFichier : SInt16):DistributionSet;
procedure AjouterDistributionNouveauFormat(nom,path : str255;typeDonnees : SInt16);
function EcourteNomDistributionNouveauFormat(nomLong : str255) : str255;
procedure SetDecalageNrosJoueursOfDistribution(nroDistrib : SInt16; decalage : SInt32);
function  GetDecalageNrosJoueursOfDistribution(nroDistrib : SInt16) : SInt32;
procedure SetDecalageNrosTournoisOfDistribution(nroDistrib : SInt16; decalage : SInt32);
function  GetDecalageNrosTournoisOfDistribution(nroDistrib : SInt16) : SInt32;

{types des distributions}
procedure SetTypeDonneesDistribution(nroDistrib,typeDonnees : SInt16);
function GetTypeDonneesDistribution(nroDistrib : SInt16) : SInt16; 
function EstUneDistributionDeParties(nroDistrib : SInt16) : boolean;
function EstUneDistributionDeSolitaires(nroDistrib : SInt16) : boolean;


{Tris divers}
procedure TrierListeFichiersNouveauFormat;
procedure TrierAlphabetiquementJoueursNouveauFormat;
procedure TrierAlphabetiquementTournoisNouveauFormat;


{Ajout d'un nom de joueur ou de tournoi daans la liste en memoire}
procedure AjouterJoueurEnMemoire(joueur:str30;numeroEnMemoire,numeroDansDonsFichier : SInt32);
procedure AjouterTournoiEnMemoire(tournoi:str30;numeroEnMemoire,numeroDansDonsFichier : SInt32);


{Lecture et gestion des fichiers de joueurs}
function MetJoueursNouveauFormatEnMemoire(nomsAbreges : boolean) : OSErr;
function LitNomsDesJoueursEnJaponais() : OSErr;
function CreeEnteteFichierIndexJoueursNouveauFormat(typeVoulu : SInt16) : t_EnTeteNouveauFormat;
function EcritFichierIndexDesJoueursTries(nomsAbreges : boolean) : OSErr;
function LitFichierIndexDesJoueursTries(nomsAbreges : boolean) : OSErr;
procedure EffaceTousLesNomsCourtsDesJoueurs;


{Lecture et gestion des fichiers de tournois}
function MetJoueursEtTournoisEnMemoire(nomsAbreges : boolean) : OSErr;
function MetTournoisNouveauFormatEnMemoire(nomsAbreges : boolean) : OSErr;
function LitNomsDesTournoisEnJaponais() : OSErr;
function CreeEnteteFichierIndexTournoisNouveauFormat(typeVoulu : SInt16) : t_EnTeteNouveauFormat;
function EcritFichierIndexDesTournoisTries(nomsAbreges : boolean) : OSErr;
function LitFichierIndexDesTournoisTries(nomsAbreges : boolean) : OSErr;



{Fichiers d'index de parties}
function IndexerFichierPartiesEnMemoireNouveauFormat(numFichierParties : SInt16) : OSErr;
function EcritFichierIndexNouveauFormat(numFichierParties : SInt16) : OSErr;
function LitFichierIndexNouveauFormat(numFichierIndex : SInt16) : OSErr;
function NomFichierIndexAssocieNouveauFormat(ficName : str255) : str255;
procedure EtablitLiaisonEntrePartiesEtIndexNouveauFormat;
procedure IndexerLesFichiersNouveauFormat;




IMPLEMENTATION







USES UnitSolitairesNouveauFormat,UnitFichiersTEXT,UnitUtilitaires,UnitAccesStructuresNouvFormat,
     UnitServicesDialogs,UnitOth1,UnitArbresTernairesRecherche,UnitSound,Aliases,UnitMacExtras,
     UnitGeneralSort,MyFileSystemUtils,MyStrings,UnitPrefs,UnitStringSet,UnitTestNouveauFormat,
     UnitOth2,UnitRapport,SNStrings,UnitNormalisation;

const CapaciteBufferParties=2000;
      CapaciteBufferJoueurs=1000;
      CapaciteBufferTournois=1000;
            
      
var pathToDataBase : str255;
    nroDernierFichierOuvertNF : SInt16; 

    bufferLecturePartiesNF : array[0..CapaciteBufferParties] of t_PartieRecNouveauFormat;
    nroDernierFichierPartiesLuNF : SInt16; 
    nroDernierePartieLueNF : SInt32;
    premierePartieDansBufferNF : SInt32;
    dernierePartieDansBufferNF : SInt32;
    
    bufferLectureJoueursNF : array[0..CapaciteBufferJoueurs] of t_JoueurRecNouveauFormat;
    nroDernierFichierJoueursLuNF : SInt16; 
    nroDernierJoueurLuNF : SInt32;
    premierJoueurDansBufferNF : SInt32;
    dernierJoueurDansBufferNF : SInt32;
    
    bufferLectureTournoisNF : array[0..CapaciteBufferTournois] of t_TournoiRecNouveauFormat;
    nroDernierFichierTournoisLuNF : SInt16; 
    nroDernierTournoiLuNF : SInt32;
    premierTournoiDansBufferNF : SInt32;
    dernierTournoiDansBufferNF : SInt32;


procedure InitUnitNouveauFormat;
var i : SInt32;
begin

  DistributionsNouveauFormat.nbDistributions := 0;
  for i := 1 to nbMaxDistributions do
    with DistributionsNouveauFormat.Distribution[i] do
    begin
       name                           := NIL;
       path                           := NIL;
       nomUsuel                       := NIL;
       typeDonneesDansDistribution    := kUnknownDataNouveauFormat;
       decalageNrosJoueurs            := 0;
       decalageNrosTournois           := 0;
    end;
    
  InfosFichiersNouveauFormat.nbFichiers := 0;
  for i := 1 to nbMaxFichiersNouveauFormat do
    with InfosFichiersNouveauFormat.fichiers[i] do
      begin
        open            := false;
        nomFichier      := NIL;
        pathFichier     := NIL;
        refNum          := 0;
        vRefNum         := 0;
        parID           := 0;
        NroDistribution := 0;
        Annee           := 0;
        typeDonnees     := kUnknownDataNouveauFormat;
        NroFichierDual  := 0;
        MemoryFillChar(@entete,TailleEnTeteNouveauFormat,chr(0));
      end;
   
  with IndexNouveauFormat do
    begin
      tailleIndex := 0;
      indexNoir := NIL;
      indexBlanc := NIL;
      indexOuverture := NIL;
      indexTournoi := NIL;
    end;
  
  with PartiesNouveauFormat do
    begin
      nbPartiesEnMemoire := 0;
      listeParties := NIL;
    end;
  
  with JoueursNouveauFormat do
    begin
      nbJoueursNouveauFormat := 0;
      plusLongNomDeJoueur := 0;
      nombreJoueursDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      listeJoueurs := NIL;
    end;
  
  with TournoisNouveauFormat do
    begin
      nbTournoisNouveauFormat := 0;
      nombreTournoisDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      listeTournois := NIL;
    end;

  nroDernierFichierOuvertNF := 0;
  
  nroDernierFichierPartiesLuNF := 0;
  nroDernierePartieLueNF := -1;
  premierePartieDansBufferNF := -1;
  dernierePartieDansBufferNF := -1;
  
  nroDernierFichierJoueursLuNF := 0;
  nroDernierJoueurLuNF := -1;
  premierJoueurDansBufferNF := -1;
  dernierJoueurDansBufferNF := -1;
  
  nroDernierFichierTournoisLuNF := 0;
  nroDernierTournoiLuNF := -1;
  premierTournoiDansBufferNF := -1;
  dernierTournoiDansBufferNF := -1;
   
  ChoixDistributions.genre := kToutesLesDistributions;
  ChoixDistributions.DistributionsALire := [];
 
  pathToDataBase := '';
end;



function AllocateMemoireIndexNouveauFormat(var nbParties : SInt32) : OSErr;
begin
  AllocateMemoireIndexNouveauFormat := NoErr;
  DisposeIndexNouveauFormat;
  with IndexNouveauFormat do
    begin
      tailleIndex := 0;
      indexNoir     := indexArrayPtr(AllocateMemoryPtr(nbParties+20));  {+20 = pied de pilote :-) }
      indexBlanc    := indexArrayPtr(AllocateMemoryPtr(nbParties+20));
      indexOuverture := indexArrayPtr(AllocateMemoryPtr(nbParties+20));
      indexTournoi  := indexArrayPtr(AllocateMemoryPtr(nbParties+20));
      if (indexNoir <> NIL) & (indexBlanc <> NIL) & (indexOuverture <> NIL) & (indexTournoi <> NIL)
        then tailleIndex := nbParties
        else 
          begin
            nbParties := 0;
            AllocateMemoireIndexNouveauFormat := -1;
          end;
    end;
end;

function AllocateMemoireListePartieNouveauFormat(var nbParties : SInt32) : OSErr;
begin
  AllocateMemoireListePartieNouveauFormat := NoErr;
  DisposeListePartiesNouveauFormat;
  with PartiesNouveauFormat do
    begin
      nbPartiesEnMemoire := 0;
      listeParties := tablePartiesNouveauFormatPtr(AllocateMemoryPtr((nbParties+2)*TaillePartieRecNouveauFormat));
      if listeParties <> NIL 
        then nbPartiesEnMemoire := nbParties
        else 
          begin
            nbParties := 0;
            AllocateMemoireListePartieNouveauFormat := -1;
          end;
    end;
end;

function AllocateMemoireJoueursNouveauFormat(var nbJoueurs : SInt32) : OSErr;
var i,count : SInt32;
    JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Entrée dans AllocateMemoireJoueursNouveauFormat',true);

  AllocateMemoireJoueursNouveauFormat := NoErr;
  DisposeJoueursNouveauFormat;
  with JoueursNouveauFormat do
    begin
      nbJoueursNouveauFormat := 0;
      plusLongNomDeJoueur := 0;
      nombreJoueursDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      count := sizeof(JoueursNouveauFormatRec);
      count := count*(nbJoueurs+2);
      listeJoueurs := tableJoueursNouveauFormatPtr(AllocateMemoryPtr(count));
      if listeJoueurs <> NIL
        then 
          begin
            nbJoueursNouveauFormat := nbJoueurs;
            for i := 0 to nbJoueursNouveauFormat-1 do
              begin
                JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+i*sizeof(JoueursNouveauFormatRec));
                JoueurArrow^.nomJaponais := NIL;
                JoueurArrow^.numeroDansFichierJoueurs := -1;
                JoueurArrow^.anneePremierePartie := -1;
                JoueurArrow^.anneeDernierePartie := -1;
                JoueurArrow^.classementData := -1;
              end;
          end
        else 
          begin
            nbJoueurs := 0;
            AllocateMemoireJoueursNouveauFormat := -1;
          end;
    end;
end;

function AllocateMemoireTournoisNouveauFormat(var nbTournois : SInt32) : OSErr;
var i : SInt32;
begin
  AllocateMemoireTournoisNouveauFormat := NoErr;
  DisposeTournoisNouveauFormat;
  with TournoisNouveauFormat do
    begin
      nbTournoisNouveauFormat := 0;
      nombreTournoisDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      listeTournois := tableTournoisNouveauFormatPtr(AllocateMemoryPtr((nbTournois+2)*sizeof(TournoisNouveauFormatRec)));
      if listeTournois <> NIL
        then 
          begin
            nbTournoisNouveauFormat := nbTournois;
            for i := 0 to nbTournoisNouveauFormat-1 do
              begin
                listeTournois^[i].nomJaponais := NIL;
                listeTournois^[i].numeroDansFichierTournois := -1;
              end;
          end
        else 
          begin
            nbTournois := 0;
            AllocateMemoireTournoisNouveauFormat := -1;
          end;
    end;
end;

procedure DisposeIndexNouveauFormat;
begin
  with IndexNouveauFormat do
    begin
      tailleIndex := 0;
      if indexNoir <> NIL then DisposeMemoryPtr(ptr(indexNoir));
      if indexBlanc <> NIL then DisposeMemoryPtr(ptr(indexBlanc));
      if indexOuverture <> NIL then DisposeMemoryPtr(ptr(indexOuverture));
      if indexTournoi <> NIL then DisposeMemoryPtr(ptr(indexTournoi));
      indexNoir := NIL;
      indexBlanc := NIL;
      indexOuverture := NIL;
      indexTournoi := NIL;
    end;
end;

procedure DisposeListePartiesNouveauFormat;
begin
  with PartiesNouveauFormat do
    begin
      nbPartiesEnMemoire := 0;
      if listeParties <> NIL then DisposeMemoryPtr(Ptr(listeParties));
      listeParties := NIL;
    end;
end;


procedure DisposeJoueursNouveauFormat;
var i : SInt32;
    JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
	  begin
      if listeJoueurs <> NIL then
	      for i := 0 to nbJoueursNouveauFormat-1 do
	        begin
	          JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+i*sizeof(JoueursNouveauFormatRec));
	          if JoueurArrow^.nomJaponais <> NIL then
	            begin
	              DisposeMemoryHdl(Handle(JoueurArrow^.nomJaponais));
	              JoueurArrow^.nomJaponais := NIL;
	            end;
	        end;
      nbJoueursNouveauFormat := 0;
      plusLongNomDeJoueur := 0;
      nombreJoueursDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      if listeJoueurs <> NIL then DisposeMemoryPtr(Ptr(listeJoueurs));
      listeJoueurs := NIL;
	  end;
end;


procedure DisposeTournoisNouveauFormat;
var i : SInt32;
begin
  with TournoisNouveauFormat do
    begin
      if listeTournois <> NIL then
	      for i := 0 to nbTournoisNouveauFormat-1 do
	        if listeTournois^[i].nomJaponais <> NIL then 
	          begin
	            DisposeMemoryHdl(Handle(listeTournois^[i].nomJaponais));
	            listeTournois^[i].nomJaponais := NIL;
	          end;
      nbTournoisNouveauFormat := 0;
      nombreTournoisDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      if listeTournois <> NIL then DisposeMemoryPtr(Ptr(listeTournois));
      listeTournois := NIL;
    end;
end;



procedure LibereMemoireUnitNouveauFormat;
var i : SInt32;
begin

  for i := 1 to nbMaxDistributions do
    with DistributionsNouveauFormat.Distribution[i] do
    begin
       if name     <> NIL then DisposeMemoryPtr(Ptr(name));
       if path     <> NIL then DisposeMemoryPtr(Ptr(path));
       if nomUsuel <> NIL then DisposeMemoryPtr(Ptr(nomUsuel));
       name     := NIL;
       path     := NIL;
       nomUsuel := NIL;
    end;
    
  for i := 1 to nbMaxFichiersNouveauFormat do
    with InfosFichiersNouveauFormat.fichiers[i] do
      begin
        if nomFichier <> NIL then DisposeMemoryPtr(Ptr(nomFichier));
        if pathFichier <> NIL then DisposeMemoryPtr(Ptr(pathFichier));
        nomfichier := NIL;
        pathFichier := NIL;
      end;
  
  DisposeIndexNouveauFormat;
  DisposeListePartiesNouveauFormat;
  DisposeJoueursNouveauFormat;
  DisposeTournoisNouveauFormat;
  
end;

function PathDuDossierDatabase() : str255;
begin
  PathDuDossierDatabase := pathToDataBase;
end;

function CalculePathFichierNouveauFormat(nroFichier : SInt16) : str255;
var s : str255;
begin
  s := '';
  with InfosFichiersNouveauFormat,DistributionsNouveauFormat do
    if (nroFichier>0) & (nroFichier<=nbFichiers) then
      begin
        with fichiers[nroFichier] do
          if (typeDonnees=kFicPartiesNouveauFormat) |
             (typeDonnees=kFicIndexPartiesNouveauFormat)
            then 
              begin
                if distribution[nroDistribution].path <> NIL then 
                  s := distribution[nroDistribution].path^
              end
            else 
              begin
                if pathFichier <> NIL then 
                  s := pathFichier^;
              end;
      end;
  CalculePathFichierNouveauFormat := s;
end;


function CalculeNomFichierNouveauFormat(nroFichier : SInt16) : str255;
var posXXXX : SInt16; 
    s : str255;
begin
  s := '';
  with InfosFichiersNouveauFormat,DistributionsNouveauFormat do
    if (nroFichier>0) & (nroFichier<=nbFichiers) then
      begin
        with fichiers[nroFichier] do
          if (typeDonnees=kFicPartiesNouveauFormat) |
             (typeDonnees=kFicIndexPartiesNouveauFormat)
            then
              begin
                s := distribution[nroDistribution].name^;
                posXXXX := Pos('XXXX',s);
                if posXXXX>0 then
                  begin
                    Delete(s,posXXXX,4);
                    insert(NumEnString(annee),s,posXXXX);
                  end;
                if typeDonnees=kFicIndexPartiesNouveauFormat then s := NomFichierIndexAssocieNouveauFormat(s);
              end
            else
              begin
                if nomFichier <> NIL then
                  s := nomFichier^;
              end;
      end;
  CalculeNomFichierNouveauFormat := s;
end;

function NomDistributionAssocieeNouveauFormat(ficName : str255; var anneeDansDistrib : SInt16) : str255;
var nom,upCaseName : str255;
    positionPoint,i : SInt16; 
    anneeLong : SInt32;
    c : char;
begin
  nom := ficName;
  upCaseName := UpCaseStr(nom);
  anneeDansDistrib := 0;
  
  positionPoint := Pos('.INDEX',upCaseName);
  if positionPoint>0 then 
    begin
      upCaseName := LeftOfString(upcaseName,positionPoint-1)+'.WTB';
      nom := LeftOfString(nom,positionPoint-1)+'.WTB';
    end;
  
  positionPoint := Pos('.PZZ',upCaseName);
  if positionPoint>0 then 
    begin
      
      { Les lignes suivantes exhibent un BUG de CodeWarrior !!!! }
      {
      if (nom[positionPoint-1] >= '0') & (nom[positionPoint-1] <= '9') then positionPoint := positionPoint-1;
      if (nom[positionPoint-1] >= '0') & (nom[positionPoint-1] <= '9') then positionPoint := positionPoint-1;
      if (nom[positionPoint-1] >= '0') & (nom[positionPoint-1] <= '9') then positionPoint := positionPoint-1;
      }
      
      c := nom[positionPoint-1];
      if IsDigit(c) then positionPoint := positionPoint-1;
      c := nom[positionPoint-1];
      if IsDigit(c) then positionPoint := positionPoint-1;
      c := nom[positionPoint-1];
      if IsDigit(c) then positionPoint := positionPoint-1;
      c := nom[positionPoint-1];
      if IsDigit(c) then positionPoint := positionPoint-1;
      
      nom := LeftOfString(nom,positionPoint-1)+'.pzz';
    end;
  
  positionPoint := Pos('.WTB',upCaseName);
	if (positionPoint>0)      &
		 IsDigit(nom[positionPoint-4]) &
     IsDigit(nom[positionPoint-3]) &
     IsDigit(nom[positionPoint-2]) &
     IsDigit(nom[positionPoint-1]) then
       begin
		     StringToNum(TPCopy(nom,positionPoint-4,4),anneeLong);
		     anneeDansDistrib := anneelong;
		     for i := positionPoint-4 to positionPoint-1 do nom[i] := 'X';
		     if nom[positionPoint+1]='W' then nom[positionPoint+1] := 'w';
		     if nom[positionPoint+2]='T' then nom[positionPoint+2] := 't';
		     if nom[positionPoint+3]='B' then nom[positionPoint+3] := 'b';
		   end;
		   
  NomDistributionAssocieeNouveauFormat := nom;
  
end;


function TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat(nroFichier : SInt16):DistributionSet;
var pathOfFile,nameOfFile,bidstr : str255;
    numDistrib : SInt16; 
    result:DistributionSet;
begin
  TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat := [];
  result := [];
  
  with InfosFichiersNouveauFormat , DistributionsNouveauFormat do
    if (nroFichier>=1) & (nroFichier<=nbFichiers) then
      begin
        if fichiers[nroFichier].nroDistribution>0
          then TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat := [fichiers[nroFichier].nroDistribution]
          else
            begin
              nameOfFile := CalculeNomFichierNouveauFormat(nroFichier);
              SplitBy(nameOfFile,'.',nameOfFile,bidstr);
              EnleveEspacesDeGaucheSurPlace(nameOfFile);
              EnleveEspacesDeDroiteSurPlace(nameOfFile);
              pathOfFile := CalculePathFichierNouveauFormat(nroFichier);
              
              {d'abord on cherche une distribution dont le nom correspondant exactement, dans le meme dossier}
              for numDistrib := 1 to nbDistributions do
					      if (distribution[numDistrib].name <> NIL) & (Pos(nameOfFile,distribution[numDistrib].name^)>0) &
					         (distribution[numDistrib].path <> NIL) & (pathOfFile=distribution[numDistrib].path^) then
					        result := result+[numDistrib];
					      
					    {si pas trouve, on cherche une distribution dans le meme dossier}
					    for numDistrib := 1 to nbDistributions do
					      if (distribution[numDistrib].path <> NIL) & (pathOfFile=distribution[numDistrib].path^) then
					        result := result+[numDistrib];
					    
					    {si toujours pas trouve, on cherche une distribution dont le nom est proche}
					    for numDistrib := 1 to nbDistributions do
					      if (distribution[numDistrib].name <> NIL) & (Pos(nameOfFile,distribution[numDistrib].name^)>0) then
					        result := result+[numDistrib];
					    
					    TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat := result;
            end;
      end;
end;


function NomFichierIndexAssocieNouveauFormat(ficname : str255) : str255;
var upCaseName : str255;
    positionPoint : SInt16; 
begin
  upCaseName := UpCaseStr(ficname);
  positionPoint := Pos('.WTB',upCaseName);
  if positionPoint > 0
    then NomFichierIndexAssocieNouveauFormat := LeftOfString(ficname,positionPoint-1)+'.index'
    else NomFichierIndexAssocieNouveauFormat := ficname+'.index';
end;


function LitEnteteNouveauFormat(refnum : SInt16; var entete : t_EnTeteNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  MemoryFillChar(@entete,TailleEnTeteNouveauFormat,char(0));
  codeErreur := MyFSReadAt(refnum,0,TailleEnTeteNouveauFormat,@entete);
  if codeErreur = 0 then
    with entete do
      begin
        NombreEnregistrementsParties           := MySwapLongint(NombreEnregistrementsParties);
        NombreEnregistrementsTournoisEtJoueurs := MySwapInteger(NombreEnregistrementsTournoisEtJoueurs);
        AnneeParties                           := MySwapInteger(AnneeParties);
      end;
  LitEnteteNouveauFormat := codeErreur;
end;


function EcritEnteteNouveauFormat(refnum : SInt16; entete : t_EnTeteNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  with entete do
    begin
      NombreEnregistrementsParties           := MySwapLongint(NombreEnregistrementsParties);
      NombreEnregistrementsTournoisEtJoueurs := MySwapInteger(NombreEnregistrementsTournoisEtJoueurs);
      AnneeParties                           := MySwapInteger(AnneeParties);
    end;
  codeErreur := MyFSWriteAt(refnum,FSFromStart,0,TailleEnTeteNouveauFormat,@entete);
  EcritEnteteNouveauFormat := codeErreur;
end;


function EcritPartieNouveauFormat(refnum : SInt16; nroPartie : SInt32;theGame:t_PartieRecNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  with theGame do
		begin
		  nroTournoi      := MySwapInteger(nroTournoi);
		  nroJoueurNoir   := MySwapInteger(nroJoueurNoir);
		  nroJoueurBlanc  := MySwapInteger(nroJoueurBlanc);
		end;
  codeErreur := MyFSWriteAt(refnum,FSFromStart,TailleEnTeteNouveauFormat+pred(nroPartie)*TaillePartieRecNouveauFormat,TaillePartieRecNouveauFormat,@theGame);
  EcritPartieNouveauFormat := codeErreur;
end;


function EcritJoueurNouveauFormat(refnum : SInt16; nroJoueur : SInt32;thePlayer:t_JoueurRecNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  codeErreur := MyFSWriteAt(refnum,FSFromStart,TailleEnTeteNouveauFormat+nroJoueur*TailleJoueurRecNouveauFormat,TailleJoueurRecNouveauFormat,@thePlayer);
  EcritJoueurNouveauFormat := codeErreur;
end;


function EcritTournoiNouveauFormat(refnum : SInt16; nroTournoi : SInt32;theTourney : t_TournoiRecNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  codeErreur := MyFSWriteAt(refnum,FSFromStart,TailleEnTeteNouveauFormat+nroTournoi*TailleTournoiRecNouveauFormat,TailleTournoiRecNouveauFormat,@theTourney);
  EcritTournoiNouveauFormat := codeErreur;
end;


function EstUneDistributionConnue(nomTest,pathTest : str255; var nroDistrib : SInt16) : boolean;
var i : SInt16; 
begin
  EstUneDistributionConnue := false;
  nroDistrib := 0;
  
  nomTest  := UpCaseStr(nomTest);
  pathTest := UpCaseStr(pathTest);
  
  with DistributionsNouveauFormat do
    for i := 1 to nbDistributions do
      if (UpCaseStr(Distribution[i].name^) = nomTest) &
         (UpCaseStr(Distribution[i].path^) = pathTest) then
        begin
          EstUneDistributionConnue := true;
          nroDistrib := i;
          exit(EstUneDistributionConnue);
        end;
end;


procedure SetTypeDonneesDistribution(nroDistrib,typeDonnees : SInt16);
begin
  with DistributionsNouveauFormat do
    if (nroDistrib >= 1) & (nroDistrib <= nbDistributions) then
      Distribution[nroDistrib].typeDonneesDansDistribution := typeDonnees;
end;

function GetTypeDonneesDistribution(nroDistrib : SInt16) : SInt16; 
begin
  GetTypeDonneesDistribution := kUnknownDataNouveauFormat;
  with DistributionsNouveauFormat do
    if (nroDistrib >= 1) & (nroDistrib <= nbDistributions) then
      GetTypeDonneesDistribution := Distribution[nroDistrib].typeDonneesDansDistribution;
end;

function EstUneDistributionDeParties(nroDistrib : SInt16) : boolean;
begin
  EstUneDistributionDeParties := GetTypeDonneesDistribution(nroDistrib) = kFicPartiesNouveauFormat;
end;

function EstUneDistributionDeSolitaires(nroDistrib : SInt16) : boolean;
begin
  EstUneDistributionDeSolitaires := GetTypeDonneesDistribution(nroDistrib) = kFicSolitairesNouveauFormat;
end;

procedure AjouterDistributionNouveauFormat(nomDistr,pathDistr : str255;typeDistribution : SInt16);
var bidon,nbUnderscoreEnleves : SInt16; 
    s : str255;
begin
  
  if not(EstUneDistributionConnue(nomDistr,pathDistr,bidon)) then
	 with DistributionsNouveauFormat do
	  if nbDistributions < nbMaxDistributions then
	    begin
	      nbDistributions := succ(nbDistributions);
	      
	      {
	      WritelnDansRapport('Dans AjouterDistributionNouveauFormat :');
	      WritelnDansRapport('  nomDistr = '+nomDistr);
        WritelnDansRapport('  pathDistr = '+pathDistr);
        WritelnDansRapport('');
        }
	      
	      { fabriquons le nom "usuel" de la distribution (celui que l'on affichera) }
        s := nomDistr;
        s := EcourteNomDistributionNouveauFormat(s);
        s := EnleveEspacesDeDroite(s);
        EnleveEtCompteCeCaractereADroite(s,'_',nbUnderscoreEnleves);
        if UpCaseStr(s) = 'WTH' then 
          begin
            s := 'WThor';
            nroDistributionWThor := nbDistributions;
          end;
	          
	      { stocker les infos }
	      with Distribution[nbDistributions] do
	        begin
	          name      := stringPtr(AllocateMemoryPtr(sizeof(str255)));
	          path      := stringPtr(AllocateMemoryPtr(sizeof(str255)));
	          nomUsuel  := stringPtr(AllocateMemoryPtr(sizeof(str255)));
	          name^     := nomDistr;
	          path^     := pathDistr;
	          nomUsuel^ := s;
	          typeDonneesDansDistribution := typeDistribution;
	          decalageNrosJoueurs := 0;
	          decalageNrosTournois := 0;
	        end;
	    end;
end;

function AjouterFichierNouveauFormat(fic : FSSpec;path : str255;typeDonneesDuFichier : SInt16; EnteteFichier : t_EnTeteNouveauFormat) : boolean;
var nomDistrib : str255;
    ok : boolean;
begin
  {WritelnDansRapport('path = '+path);}
  with InfosFichiersNouveauFormat do
   if (nbFichiers < nbMaxFichiersNouveauFormat) then
    begin
      nbFichiers := succ(nbFichiers);
      with fichiers[nbFichiers] do
        begin
          open           := false;
          refNum         := 0;
          vRefNum        := fic.vrefnum;
          parID          := fic.parID;
          typeDonnees    := typeDonneesDuFichier;
          entete         := EnteteFichier;
          NroFichierDual := 0;
          
          if (typeDonneesDuFichier=kFicPartiesNouveauFormat) |
             (typeDonneesDuFichier=kFicIndexPartiesNouveauFormat)
            then
              begin
                nomDistrib     := NomDistributionAssocieeNouveauFormat(fic.name,annee);
                ok             := EstUneDistributionConnue(nomDistrib,path,nroDistribution);
                nomFichier     := NIL;
                pathFichier    := NIL;
              end
            else
              begin
                nomFichier      := stringPtr(AllocateMemoryPtr(sizeof(str255)));
                pathFichier     := stringPtr(AllocateMemoryPtr(sizeof(str255)));
                nomfichier^     := fic.name;
                pathFichier^    := path;
                nroDistribution := 0;
                annee           := 0;
                ok := true;
              end;
         end;
     end;
  AjouterFichierNouveauFormat := ok;
end;


function EstUnFichierNouveauFormat(fic : FSSpec; var typeDonnees : SInt16; var entete : t_EnTeteNouveauFormat) : boolean;
var refnum : SInt16; 
    anneeTitre : SInt16; 
    codeErreur : OSErr;
    nomDuFichier : str255;
    nomDistribution : str255;
    formatReconnu : boolean;
begin
  EstUnFichierNouveauFormat := false;
  typeDonnees := kUnknownDataNouveauFormat;
  
  codeErreur := FSpOpenDF(fic,fsCurPerm,refnum);
  if codeErreur <> 0 then 
    begin
      codeErreur := FSClose(refnum);
      exit(EstUnFichierNouveauFormat);
    end;
  
  codeErreur := LitEnteteNouveauFormat(refnum,entete);
  if codeErreur <> 0 then 
    begin
      codeErreur := FSClose(refnum);
      exit(EstUnFichierNouveauFormat);
    end;
  
  codeErreur := FSClose(refnum);
  refnum := 0;
   
  nomDuFichier := UpCaseStr(fic.name);
  with entete do
    begin
      formatReconnu := (siecleCreation >= 19) & (siecleCreation <= 21) &
                       (anneeCreation >= 0) & (anneeCreation <= 99) &
                       (moisCreation >= 1) & (moisCreation <= 12) &
                       (JourCreation >= 1) & (JourCreation <= 31) &
                       ((NombreEnregistrementsParties > 0) | (NombreEnregistrementsTournoisEtJoueurs > 0));
                      
      {
      WritelnDansRapport('format interne du fichier «'+fic.name+'»');
      with entete do
		    begin 
				  WritelnStringAndNumDansRapport('entete.siecleCreation=',siecleCreation);
				  WritelnStringAndNumDansRapport('entete.annneCreation=',anneeCreation);
				  WritelnStringAndNumDansRapport('entete.MoisCreation=',MoisCreation);
				  WritelnStringAndNumDansRapport('entete.JourCreation=',JourCreation);
				  WritelnStringAndNumDansRapport('entete.NombreEnregistrementsParties=',NombreEnregistrementsParties);
				  WritelnStringAndNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs=',NombreEnregistrementsTournoisEtJoueurs);
				  WritelnStringAndNumDansRapport('entete.AnneeParties=',AnneeParties);
				  WritelnStringAndNumDansRapport('entete.parametreP1=',TailleDuPlateau);
				  WritelnStringAndNumDansRapport('entete.parametreP2=',EstUnFichierSolitaire);
				  WritelnStringAndNumDansRapport('entete.parametreP3=',ProfondeurCalculTheorique);
				  WritelnStringAndNumDansRapport('entete.reservedByte=',reservedByte);
				  WritelnDansRapport('');
		    end;}
		  
      
      if formatReconnu
        then
          begin
            if (Pos('WTHOR.TRN.INDEX',nomDuFichier) > 0) & 
               (PlaceMemoireIndex > 0) then
					    typeDonnees := kFicIndexTournoisNouveauFormat else
					    
					  if (Pos('WTHOR.JOU.INDEX',nomDuFichier) > 0) & 
					     (PlaceMemoireIndex > 0) then
					    typeDonnees := kFicIndexJoueursNouveauFormat else
					  
					  if (Pos('WTHOR.TRN(SHORT)',nomDuFichier) > 0) & EndsWith(nomDuFichier,'.TRN(SHORT)') & 
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicTournoisCourtsNouveauFormat else
					    
					  if (Pos('WTHOR.JOU(SHORT)',nomDuFichier) > 0) & EndsWith(nomDuFichier,'.JOU(SHORT)') & 
					    (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicJoueursCourtsNouveauFormat else
					    
					  if (Pos('WTHOR.TRN',nomDuFichier) = 1) & EndsWith(nomDuFichier,'.TRN') & 
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicTournoisNouveauFormat else
					    
					  if EndsWith(nomDuFichier,'.TRN') & (Pos('WTHOR.TRN',nomDuFichier) <= 0) &
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicTournoisNouveauFormat else
					    
					  if (Pos('WTHOR.JOU',nomDuFichier) = 1) & EndsWith(nomDuFichier,'.JOU') & 
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicJoueursNouveauFormat else
					    
					  if EndsWith(nomDuFichier,'.JOU') & (Pos('WTHOR.JOU',nomDuFichier) <= 0) &
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicJoueursNouveauFormat else
					  
					  if EndsWith(nomDuFichier,'.PZZ') & 
					     (NombreEnregistrementsTournoisEtJoueurs>0) then {surcharge de NombreEnregistrementsTournoisEtJoueurs pour stocker le nb de cases vides}
					    begin
					      typeDonnees := kFicSolitairesNouveauFormat;
					    end else
					    
					  if Pos('.INDEX',nomDuFichier)>0 then
					    begin
					      nomDistribution := NomDistributionAssocieeNouveauFormat(nomDuFichier,anneeTitre);
					      if (anneeTitre=entete.AnneeParties) & (Pos('XXXX.wtb',nomDistribution)>0)
					       then typeDonnees := kFicIndexPartiesNouveauFormat;
					    end;
					    
					  if (Pos('.WTB',nomDuFichier)>0) & EndsWith(nomDuFichier,'.WTB') then
					    begin
					      nomDistribution := NomDistributionAssocieeNouveauFormat(nomDuFichier,anneeTitre);
					      if (anneeTitre=entete.AnneeParties) & (Pos('XXXX.wtb',nomDistribution)>0)
					        then typeDonnees := kFicPartiesNouveauFormat
					        else
					          begin
					            WritelnDansRapport('#### Erreur!! Le nom du fichier «'+fic.name+'» ne contient pas d''année,');
					            WritelnDansRapport('#### ou l''année ne coïncide pas avec la date dans le fichier !!');
					          end;
					    end;
		      end
		    else
		      begin
		        if ((Pos('.WTB',nomDuFichier)>0) & EndsWith(nomDuFichier,'.WTB')) |
		           ((Pos('.PZZ',nomDuFichier)>0) & EndsWith(nomDuFichier,'.PZZ')) then
		          begin
		            SysBeep(0);
		            WritelnDansRapport('#### Erreur!! Le format interne du fichier «'+fic.name+'» me parait douteux');
		            with entete do
							    begin
									  WritelnStringAndNumDansRapport('entete.siecleCreation=',siecleCreation);
									  WritelnStringAndNumDansRapport('entete.annneCreation=',anneeCreation);
									  WritelnStringAndNumDansRapport('entete.MoisCreation=',MoisCreation);
									  WritelnStringAndNumDansRapport('entete.JourCreation=',JourCreation);
									  WritelnStringAndNumDansRapport('entete.NombreEnregistrementsParties=',NombreEnregistrementsParties);
									  WritelnStringAndNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs=',NombreEnregistrementsTournoisEtJoueurs);
									  WritelnStringAndNumDansRapport('entete.AnneeParties=',AnneeParties);
									  WritelnStringAndNumDansRapport('entete.TailleDuPlateau=',TailleDuPlateau);
									  WritelnStringAndNumDansRapport('entete.EstUnFichierSolitaire=',EstUnFichierSolitaire);
									  WritelnStringAndNumDansRapport('entete.ProfondeurCalculTheorique=',ProfondeurCalculTheorique);
									  WritelnStringAndNumDansRapport('entete.reservedByte=',reservedByte);
									  WritelnDansRapport('');
							    end;
		          end;
		      end;
    end; {with}
  EstUnFichierNouveauFormat := formatReconnu & (typeDonnees <> kUnknownDataNouveauFormat);
end;


function EntetesEgauxNouveauFormat(entete1,entete2 : t_EnTeteNouveauFormat) : boolean;
begin
  EntetesEgauxNouveauFormat := 
    (entete1.NombreEnregistrementsTournoisEtJoueurs = entete2.NombreEnregistrementsTournoisEtJoueurs) &
    (entete1.NombreEnregistrementsParties           = entete2.NombreEnregistrementsParties) &
    (entete1.AnneeCreation                          = entete2.AnneeCreation) &
    (entete1.MoisCreation                           = entete2.MoisCreation) &
    (entete1.JourCreation                           = entete2.JourCreation) &
    (entete1.AnneeParties                           = entete2.AnneeParties);
    {(entete1.reserved                               = entete2.reserved)}
end;


function EntetePlusRecentNouveauFormat(entete1,entete2 : t_EnTeteNouveauFormat) : boolean;
var plusRecent : boolean;
begin
  plusRecent := false;
  if entete1.siecleCreation>entete2.siecleCreation then plusRecent := true else
  if entete1.siecleCreation=entete2.siecleCreation then
    if entete1.anneeCreation>entete2.anneeCreation then plusRecent := true else
    if entete1.anneeCreation=entete2.anneeCreation then
      if entete1.MoisCreation>entete2.MoisCreation then plusRecent := true else
      if entete1.MoisCreation=entete2.MoisCreation then
        if entete1.JourCreation>entete2.JourCreation then plusRecent := true;
  EntetePlusRecentNouveauFormat := plusRecent;
end;

function OrdreSurFichiers(var f1,f2:FichierNouveauFormatRec) : boolean;
begin
  OrdreSurFichiers := false;
  
  if f1.typeDonnees<>f2.typeDonnees then OrdreSurFichiers := (f1.typeDonnees > f2.typeDonnees) else
  if (f1.typeDonnees=kFicJoueursNouveauFormat) & 
     (f1.nomFichier <> NIL) & (UpCaseStr(f1.nomFichier^) ='WTHOR.JOU') & 
     (f2.nomFichier <> NIL) & (UpCaseStr(f2.nomFichier^)<>'WTHOR.JOU') then OrdreSurFichiers := false else
  if (f1.typeDonnees=kFicJoueursNouveauFormat) & 
     (f1.nomFichier <> NIL) & (UpCaseStr(f1.nomFichier^)<>'WTHOR.JOU') & 
     (f2.nomFichier <> NIL) & (UpCaseStr(f2.nomFichier^) ='WTHOR.JOU') then OrdreSurFichiers := true else
  if (f1.typeDonnees=kFicTournoisNouveauFormat) & 
     (f1.nomFichier <> NIL) & (UpCaseStr(f1.nomFichier^) ='WTHOR.TRN') & 
     (f2.nomFichier <> NIL) & (UpCaseStr(f2.nomFichier^)<>'WTHOR.TRN') then OrdreSurFichiers := false else
  if (f1.typeDonnees=kFicTournoisNouveauFormat) & 
     (f1.nomFichier <> NIL) & (UpCaseStr(f1.nomFichier^)<>'WTHOR.TRN') & 
     (f2.nomFichier <> NIL) & (UpCaseStr(f2.nomFichier^) ='WTHOR.TRN') then OrdreSurFichiers := true else
  if f1.annee<>f2.annee                                 then OrdreSurFichiers := (f1.annee                  > f2.annee) else
  if f1.entete.siecleCreation<>f2.entete.siecleCreation then OrdreSurFichiers := (f1.entete.siecleCreation  > f2.entete.siecleCreation) else
  if f1.entete.anneeCreation<>f2.entete.anneeCreation   then OrdreSurFichiers := (f1.entete.anneeCreation   > f2.entete.anneeCreation) else
  if f1.entete.moisCreation<>f2.entete.moisCreation     then OrdreSurFichiers := (f1.entete.moisCreation    > f2.entete.jourCreation) else
  if f1.entete.jourCreation<>f2.entete.jourCreation     then OrdreSurFichiers := (f1.entete.jourCreation    > f2.entete.jourCreation) else
  if f1.nroDistribution<>f2.nroDistribution             then OrdreSurFichiers := (f1.nroDistribution        > f2.nroDistribution) else
  if f1.parID<>f2.parID                                 then OrdreSurFichiers := (f1.parID                  > f2.parID);
  
end;

procedure TrierListeFichiersNouveauFormat;
{var k : SInt16; }

  procedure Shellsort(lo,up : SInt16);
  var i,d,j : SInt16; 
      temp:FichierNouveauFormatRec;
  label 999;
  begin
    if up-lo>0 then
      begin
        d := up-lo+1;
        while d>1 do
          begin
            if d<5 
              then d := 1
              else d := MyTrunc(0.45454*d);
            for i := up-d downto lo do
              begin
                temp := InfosFichiersNouveauFormat.fichiers[i];
                j := i+d;
                while j<=up do
                  if OrdreSurFichiers(temp,InfosFichiersNouveauFormat.fichiers[j])
                    then
                      begin
                        InfosFichiersNouveauFormat.fichiers[j-d] := InfosFichiersNouveauFormat.fichiers[j];
                        j := j+d;
                      end
                    else
                      goto 999;
                999:
                InfosFichiersNouveauFormat.fichiers[j-d] := temp;
              end;
          end;
      end;
  end; {shellsort}
  
begin  {trierListeFichiersNouveauFormat}
  with InfosFichiersNouveauFormat do
    if nbFichiers > 0 then
      ShellSort(1,nbFichiers);
  
 {
 for k := 1 to InfosFichiersNouveauFormat.nbFichiers do
   begin
     WritelnDansRapport(CalculeNomFichierNouveauFormat(k));
   end;
 }
 
end;


function GetNroPremierFichierAvecCeTypeDeDonnees(ceTypeDeDonnees : SInt16) : SInt16; 
var i : SInt16; 
begin
  GetNroPremierFichierAvecCeTypeDeDonnees := -1;
  with InfosFichiersNouveauFormat do
    if nbFichiers > 0 then
      for i := 1 to nbFichiers do
        if (fichiers[i].typeDonnees = ceTypeDeDonnees) then
          begin
            GetNroPremierFichierAvecCeTypeDeDonnees := i;
            exit(GetNroPremierFichierAvecCeTypeDeDonnees);
          end;
end;


function LitPartieNouveauFormat(numFichier : SInt16; nroPartie : SInt32;enAvancant : boolean; var theGame:t_PartieRecNouveauFormat) : OSErr;
var count : SInt32;
    codeErreur : OSErr;
begin

  if (numFichier < 1) | (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnStringAndNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans LitPartieNouveauFormat : numFichier = ',numFichier);
      LitPartieNouveauFormat := -1;
      exit(LitPartieNouveauFormat);
    end;


  codeErreur := NoErr;
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    begin
		  if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		  if (codeErreur<>NoErr) then 
		    begin
		      LitPartieNouveauFormat := codeErreur;
		      exit(LitPartieNouveauFormat);
		    end;
		  
		  if (numFichier=nroDernierFichierPartiesLuNF) &
		     (nroPartie>=premierePartieDansBufferNF) &
		     (nroPartie<=dernierePartieDansBufferNF) 
		     then  {la partie est dans le buffer de lecture}
		       begin  
		         {defautDePage := false;}
		         MoveMemory(@bufferLecturePartiesNF[nroPartie-premierePartieDansBufferNF],@theGame,TaillePartieRecNouveauFormat);
		       end
		     else
		       begin
		         {defautDePage := true;}
		         if enAvancant 
		           then
		             begin
		               premierePartieDansBufferNF := nroPartie;
		               dernierePartieDansBufferNF := nroPartie+CapaciteBufferParties;
		             end
		           else
		             begin
		               premierePartieDansBufferNF := nroPartie-CapaciteBufferParties;
		               dernierePartieDansBufferNF := nroPartie;
		             end;
		         
		         if premierePartieDansBufferNF < 1 then premierePartieDansBufferNF := 1;
		         if dernierePartieDansBufferNF > entete.NombreEnregistrementsParties then dernierePartieDansBufferNF := entete.NombreEnregistrementsParties;
		          
		         codeErreur := SetFPos(refnum,1,TailleEnTeteNouveauFormat+pred(premierePartieDansBufferNF)*TaillePartieRecNouveauFormat);
		         count := (dernierePartieDansBufferNF-premierePartieDansBufferNF+1)*TaillePartieRecNouveauFormat;
		         codeErreur := FSread(refnum,count,@bufferLecturePartiesNF);
		         MoveMemory(@bufferLecturePartiesNF[nroPartie-premierePartieDansBufferNF],@theGame,TaillePartieRecNouveauFormat);
		         
		         nroDernierePartieLueNF := nroPartie;
		         nroDernierFichierPartiesLuNF := numFichier;
		         
		         
		       end;
		   with theGame do
		     begin
		     
		       { Change byte order from Intel to Motorola/IBM }
		       nroTournoi := MySwapInteger(nroTournoi);
		       nroJoueurNoir := MySwapInteger(nroJoueurNoir);
		       nroJoueurBlanc := MySwapInteger(nroJoueurBlanc);
		       
		       if (scoreReel<0) then scoreReel := 0;
		       if (ScoreReel>64) then scoreReel := 64;
		       if (scoreTheorique<0) | (scoreTheorique>64) then scoreTheorique := scoreReel;
		     end;
     end;
   LitPartieNouveauFormat := codeErreur;
end;


function LitJoueurNouveauFormat(numFichier : SInt16; nroJoueur : SInt32; var joueur:str30) : OSErr;
var count : SInt32;
    codeErreur : OSErr;
    JoueurRec:t_JoueurRecNouveauFormat;
    k : SInt16; 
begin
  
  if (numFichier < 1) | (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnStringAndNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans LitJoueurNouveauFormat : numFichier = ',numFichier);
      LitJoueurNouveauFormat := -1;
      exit(LitJoueurNouveauFormat);
    end;

  codeErreur := NoErr;
  joueur := '';
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    if (nroJoueur >= 1) & (nroJoueur <= entete.NombreEnregistrementsTournoisEtJoueurs) then
    begin
		  if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		  if (codeErreur<>NoErr) then 
		    begin
		      LitJoueurNouveauFormat := codeErreur;
		      exit(LitJoueurNouveauFormat);
		    end;
		  
		  if (numFichier=nroDernierFichierJoueursLuNF) &
		     (nroJoueur>=premierJoueurDansBufferNF) &
		     (nroJoueur<=dernierJoueurDansBufferNF) 
		     then
		       begin
		         MoveMemory(@bufferLectureJoueursNF[nroJoueur-premierJoueurDansBufferNF],@joueurRec,TailleJoueurRecNouveauFormat);
		       end
		     else
		       begin
		         premierJoueurDansBufferNF := nroJoueur;
		         dernierJoueurDansBufferNF := nroJoueur+CapaciteBufferJoueurs;
		         if premierJoueurDansBufferNF < 1 then
		            premierJoueurDansBufferNF := 1;
		         if dernierJoueurDansBufferNF > entete.NombreEnregistrementsTournoisEtJoueurs then 
		            dernierJoueurDansBufferNF := entete.NombreEnregistrementsTournoisEtJoueurs;
		          
		         codeErreur := SetFPos(refnum,1,TailleEnTeteNouveauFormat+pred(premierJoueurDansBufferNF)*TailleJoueurRecNouveauFormat);
		         if codeErreur<>NoErr then 
		           begin
		             LitJoueurNouveauFormat := codeErreur;
		             exit(LitJoueurNouveauFormat);
		           end;
		         
		         count := (dernierJoueurDansBufferNF-premierJoueurDansBufferNF+1)*TailleJoueurRecNouveauFormat;
		         if count>0 then
		           begin
		             codeErreur := FSread(refnum,count,@bufferLectureJoueursNF);
		             MoveMemory(@bufferLectureJoueursNF[nroJoueur-premierJoueurDansBufferNF],@JoueurRec,TailleJoueurRecNouveauFormat);
		           end;
		         nroDernierJoueurLuNF := nroJoueur;
		         nroDernierFichierJoueursLuNF := numFichier;
		       end;
		       
		    for k := 1 to TailleJoueurRecNouveauFormat do
		      if (JoueurRec[k] <> 0) then joueur := Concat(joueur,chr(joueurRec[k]));
     end;
  LitJoueurNouveauFormat := codeErreur;
end;


function LitTournoiNouveauFormat(numFichier : SInt16; nroTournoi : SInt32; var Tournoi:str30) : OSErr;
var count : SInt32;
    codeErreur : OSErr;
    TournoiRec : t_TournoiRecNouveauFormat;
    k : SInt16; 
begin

  if (numFichier < 1) | (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnStringAndNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans LitTournoiNouveauFormat : numFichier = ',numFichier);
      LitTournoiNouveauFormat := -1;
      exit(LitTournoiNouveauFormat);
    end;

  codeErreur := NoErr;
  Tournoi := '';
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    if (nroTournoi>=1) & (nroTournoi<=entete.NombreEnregistrementsTournoisEtJoueurs) then
    begin
		  if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		  if (codeErreur<>NoErr) then 
		    begin
		      LitTournoiNouveauFormat := codeErreur;
		      exit(LitTournoiNouveauFormat);
		    end;
		  
		  if (numFichier=nroDernierFichierTournoisLuNF) &
		     (nroTournoi>=premierTournoiDansBufferNF) &
		     (nroTournoi<=dernierTournoiDansBufferNF) 
		     then
		       begin
		         MoveMemory(@bufferLectureTournoisNF[nroTournoi-premierTournoiDansBufferNF],@TournoiRec,TailleTournoiRecNouveauFormat);
		       end
		     else
		       begin
		         premierTournoiDansBufferNF := nroTournoi;
		         dernierTournoiDansBufferNF := nroTournoi+CapaciteBufferTournois;
		         if premierTournoiDansBufferNF < 1 then
		            premierTournoiDansBufferNF := 1;
		         if dernierTournoiDansBufferNF > entete.NombreEnregistrementsTournoisEtJoueurs then 
		            dernierTournoiDansBufferNF := entete.NombreEnregistrementsTournoisEtJoueurs;
		          
		         codeErreur := SetFPos(refnum,1,TailleEnTeteNouveauFormat+pred(premierTournoiDansBufferNF)*TailleTournoiRecNouveauFormat);
		         if codeErreur<>NoErr then 
		           begin
		             LitTournoiNouveauFormat := codeErreur;
		             exit(LitTournoiNouveauFormat);
		           end;
		         
		         count := (dernierTournoiDansBufferNF-premierTournoiDansBufferNF+1)*TailleTournoiRecNouveauFormat;
		         if count>0 then
		           begin
		             codeErreur := FSread(refnum,count,@bufferLectureTournoisNF);
		             MoveMemory(@bufferLectureTournoisNF[nroTournoi-premierTournoiDansBufferNF],@TournoiRec,TailleTournoiRecNouveauFormat);
		           end;
		         nroDernierTournoiLuNF := nroTournoi;
		         nroDernierFichierTournoisLuNF := numFichier;
		       end;
		       
		    for k := 1 to TailleTournoiRecNouveauFormat do
		      if (TournoiRec[k] <> 0) then Tournoi := Concat(Tournoi,chr(TournoiRec[k]));
     end;
   LitTournoiNouveauFormat := codeErreur;
end;


function OuvreFichierNouveauFormat(numFichier : SInt16) : OSErr;
var codeErreur : OSErr;
    nomFichierComplet : str255;
begin

  if (numFichier < 1) | (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnStringAndNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans OuvreFichierNouveauFormat : numFichier = ',numFichier);
      OuvreFichierNouveauFormat := -1;
      exit(OuvreFichierNouveauFormat);
    end;

  codeErreur := NoErr;
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    if not(open) then
      begin
        nomFichierComplet := CalculePathFichierNouveauFormat(numFichier)+CalculeNomFichierNouveauFormat(numFichier);
                
        codeErreur := FichierTexteExiste(nomFichierComplet,0,theFichierTEXT);
                
        if codeErreur = NoErr then codeErreur := OuvreFichierTexte(theFichierTEXT);
                
        open := (codeErreur=NoErr);
        
        if open 
          then 
            begin
              nroDernierFichierOuvertNF := numFichier;
              refnum := theFichierTEXT.refNum;
            end
          else
            begin
              nroDernierFichierOuvertNF := 0;
              refnum := 0;
            end;
      end; 
    
  OuvreFichierNouveauFormat := codeErreur;
end;




function FermeFichierNouveauFormat(numFichier : SInt16) : OSErr;
var codeErreur : OSErr;
begin

  if (numFichier < 1) | (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnStringAndNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans FermeFichierNouveauFormat : numFichier = ',numFichier);
      FermeFichierNouveauFormat := -1;
      exit(FermeFichierNouveauFormat);
    end;
    
  codeErreur := NoErr;
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    if open then
      begin
        codeErreur := FermeFichierTexte(theFichierTEXT);
        refnum := 0;
        open := false;
      end;
  FermeFichierNouveauFormat := codeErreur;
end;


function OuvreFichierDesJoueursJaponais(var FichierJoueursJaponais : FichierTEXT) : OSErr;
var codeErreur : OSErr;
begin
  codeErreur := -1;
  if codeErreur<>NoErr then codeErreur := FichierTexteDeCassioExiste('players.jap',FichierJoueursJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteExiste('database:players.jap',VolumeRefCassio,FichierJoueursJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteExiste('database:players.jap ',VolumeRefCassio,FichierJoueursJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteExiste('database:players.jap (alias)',VolumeRefCassio,FichierJoueursJaponais);
  if codeErreur=NoErr 
    then codeErreur := OuvreFichierTexte(FichierJoueursJaponais)
    else codeErreur := -43; {file not found}
    
  OuvreFichierDesJoueursJaponais := codeErreur;
end;


function LitNomsDesJoueursEnJaponais() : OSErr;
var codeErreur : OSErr;
    fic : FichierTEXT;
    s,nomLatin,nomJaponais,nomDuMilieuDansListe : str255;
    permutation : LongintArrayPtr; 
    k,low,up,middle : SInt32;
    found,memeNom : boolean;
begin
  permutation := LongintArrayPtr(AllocateMemoryPtr((nbMaxJoueursEnMemoire+2)*sizeof(SInt32)));
  if permutation = NIL then 
    begin
      SysBeep(0);
      LitNomsDesJoueursEnJaponais := -1;
      exit(LitNomsDesJoueursEnJaponais);
    end;
  
  with JoueursNouveauFormat do
    begin
      if (nbJoueursNouveauFormat<=0) | not(dejaTriesAlphabetiquement) then
		    begin
		      LitNomsDesJoueursEnJaponais := -1;
		      exit(LitNomsDesJoueursEnJaponais);
		    end;
  
      codeErreur := OuvreFichierDesJoueursJaponais(fic);
      if codeErreur=NoErr then
        begin
		      for k := 0 to nbJoueursNouveauFormat-1 do    {on inverse la permutation}
		        permutation^[GetNroOrdreAlphabetiqueJoueur(k)] := k;
    
          while (codeErreur=NoErr) & not(EOFFichierTexte(fic,codeErreur)) do
            begin
              codeErreur := ReadlnDansFichierTexte(fic,s);
              if (codeErreur=NoErr) & (s[1]<>'%') & (s<>'') &
                 SplitAt(s,'=',nomLatin,nomJaponais) then
		            begin
		              EnleveEspacesDeGaucheSurPlace(nomLatin);
		              EnleveEspacesDeDroiteSurPlace(nomLatin);
		              UpperString(nomLatin,false);
		              EnleveEspacesDeGaucheSurPlace(nomJaponais);
		              EnleveEspacesDeDroiteSurPlace(nomJaponais);
		              
		             { We only compare the first 19 letters of the roman name }
		             { because of some limitation in the WTHOR.JOU format }
		              if Length(nomLatin) > 19 then
		                nomLatin := TPCopy(nomLatin,1,19);
                 
                 {binary search dans la liste des noms de joueurs triee}
                  low := 0;
                  up := nbJoueursNouveauFormat-1;
                  found := false;
                  while (low<=up) & not(found) do
		                begin
			                middle := (low+up) div 2;
			                nomDuMilieuDansListe := GetNomJoueur(permutation^[middle]);
			                UpperString(nomDuMilieuDansListe,false);
			                    
			                if Pos(nomLatin,nomDuMilieuDansListe)>0 then found := true else
			                if nomLatin<nomDuMilieuDansListe then up := middle-1 else
			                if nomLatin>nomDuMilieuDansListe then low := middle+1 
			                  else found := true;
			              end;
	                if found then 
                    begin
                      SetNomJaponaisDuJoueur(permutation^[middle],nomJaponais);
                      {on cherche aussi en arriere dans la liste des joueurs, pour les noms dupliques}
                      k := middle-1;
                      if (k >= 0) & (k <= nbJoueursNouveauFormat-1) then
                        repeat
                          nomDuMilieuDansListe := GetNomJoueur(permutation^[k]);
                          UpperString(nomDuMilieuDansListe,false);
                          memeNom := (Pos(nomLatin,nomDuMilieuDansListe) > 0);
                          if memeNom then SetNomJaponaisDuJoueur(permutation^[k],nomJaponais);
                          k := k-1;
                        until not(memeNom) | (k < 0);
                      {puis en avant}
                      k := middle+1;
                      if (k >= 0) & (k <= nbJoueursNouveauFormat-1) then
                        repeat
                          nomDuMilieuDansListe := GetNomJoueur(permutation^[k]);
                          UpperString(nomDuMilieuDansListe,false);
                          memeNom := (Pos(nomLatin,nomDuMilieuDansListe) > 0);
                          if memeNom then SetNomJaponaisDuJoueur(permutation^[k],nomJaponais);
                          k := k+1;
                        until not(memeNom) | (k > nbJoueursNouveauFormat-1);
                    end;
	              end;
            end;
          codeErreur := FermeFichierTexte(fic);
        end;
    end;
  if permutation <> NIL then DisposeMemoryPtr(Ptr(permutation));
  LitNomsDesJoueursEnJaponais := codeErreur;
end;


procedure AjouterJoueurEnMemoire(joueur:str30;numeroEnMemoire,numeroDansDonsFichier : SInt32);
begin
  SetNomJoueur(numeroEnMemoire,joueur);
  SetNomCourtJoueur(numeroEnMemoire,'');
  SetNroOrdreAlphabetiqueJoueur(numeroEnMemoire,-1); { -1 = non encore calculé}
  SetNroDansFichierJoueur(numeroEnMemoire,numeroDansDonsFichier);
  JoueursNouveauFormat.dejaTriesAlphabetiquement := false;
end;


procedure AjouterTournoiEnMemoire(tournoi:str30;numeroEnMemoire,numeroDansDonsFichier : SInt32);
begin
  SetNomTournoi(numeroEnMemoire,tournoi);
  SetNomCourtTournoi(numeroEnMemoire,'');
  SetNroOrdreAlphabetiqueTournoi(numeroEnMemoire,-1); { -1 = non encore calculé}
  SetNroDansFichierTournoi(numeroEnMemoire,numeroDansDonsFichier);
  TournoisNouveauFormat.dejaTriesAlphabetiquement := false;
end;


function MetJoueursNouveauFormatEnMemoire(nomsAbreges : boolean) : OSErr;
var numFichier,numDistrib,typeVoulu : SInt16; 
    nroJoueur,placeMemoireDemandee,nbJoueursFictifs : SInt32;
    nbExactsDeJoueurs,nbFichiersJoueurs,nbJoueursDansCeFichier : SInt32;
    decalageDansCeFichierDeJoueurs,decalageProchainFichier : SInt32;
    codeErreur : OSErr;
    s,joueurFictif:str30;
    FichierWTHOR_JOUDejaTrouve : boolean;
    DistributionsAyantLeurPropreFichierDeJoueurs,distribProches:DistributionSet;
    numeroEnMemoire,numeroDansSonFichier : SInt32;
begin
  codeErreur := -1;
  FichierWTHOR_JOUDejaTrouve := false;
  DistributionsAyantLeurPropreFichierDeJoueurs := [];
  nbJoueursFictifs := 0;
  
  DisposeJoueursNouveauFormat;
  
  if nomsAbreges
    then typeVoulu := kFicJoueursCourtsNouveauFormat
    else typeVoulu := kFicJoueursNouveauFormat;
  
  nbExactsDeJoueurs := NbTotalDeJoueursDansFichiersNouveauFormat(typeVoulu,nbFichiersJoueurs,placeMemoireDemandee);
  placeMemoireDemandee := Min(placeMemoireDemandee,nbMaxJoueursEnMemoire-10);
  
  codeErreur := AllocateMemoireJoueursNouveauFormat(placeMemoireDemandee);
  if (codeErreur<>NoErr) then
    begin
      MetJoueursNouveauFormatEnMemoire := codeErreur;
      exit(MetJoueursNouveauFormatEnMemoire);
    end;
    
  if (JoueursNouveauFormat.nbJoueursNouveauFormat <> placeMemoireDemandee) then
    begin
      codeErreur := -1;
      MetJoueursNouveauFormatEnMemoire := codeErreur;
      exit(MetJoueursNouveauFormatEnMemoire);
    end;
  
  
  decalageProchainFichier := 0;
  
  for numFichier := 1 to InfosFichiersNouveauFormat.nbFichiers do
    with InfosFichiersNouveauFormat.fichiers[numFichier] , JoueursNouveauFormat do
      if (nomsAbreges & (typeDonnees = kFicJoueursCourtsNouveauFormat)) |
         (not(nomsAbreges) & (typeDonnees = kFicJoueursNouveauFormat)) then
        begin
          
          
          nbJoueursDansCeFichier := NbJoueursDansFichierJoueursNouveauFormat(numFichier);
          if nbJoueursDansCeFichier>0 then
            begin
          
		          decalageDansCeFichierDeJoueurs := decalageProchainFichier;
		          decalageProchainFichier := decalageProchainFichier+(((nbJoueursDansCeFichier-1) div 256)+1)*256 + 512;
		          
		          if not(FichierWTHOR_JOUDejaTrouve) & (UpCaseStr(CalculeNomFichierNouveauFormat(numFichier))='WTHOR.JOU') 
		            then
			            begin
			              FichierWTHOR_JOUDejaTrouve := true;
			              for numDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
			                if not(numDistrib in distributionsAyantLeurPropreFichierDeJoueurs) then
			                  SetDecalageNrosJoueursOfDistribution(numDistrib,decalageDansCeFichierDeJoueurs);
			            end
			          else
			            begin
			              distribProches := TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat(numFichier);
			              if distribProches<>[] then
			                begin
			                  distributionsAyantLeurPropreFichierDeJoueurs := distributionsAyantLeurPropreFichierDeJoueurs+distribProches;
			                  for numDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
			                    if numDistrib in distribProches then
			                      SetDecalageNrosJoueursOfDistribution(numDistrib,decalageDansCeFichierDeJoueurs);
			                end;
			            end;
		            
		          if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		          if codeErreur<>NoErr then 
		            begin
		              MetJoueursNouveauFormatEnMemoire := codeErreur;
		              exit(MetJoueursNouveauFormatEnMemoire);
		            end;
		          
		          for nroJoueur := 1 to nbJoueursDansCeFichier do
		            if CodeErreur=NoErr then
		              begin
		                codeErreur := LitJoueurNouveauFormat(numFichier,nroJoueur,s);
		                TraduitNomJoueurEnMac(s,s);
		                
		                numeroEnMemoire := decalageDansCeFichierDeJoueurs+nroJoueur-1;
		                numeroDansSonFichier := nroJoueur-1;
		                
		                AjouterJoueurEnMemoire(s,numeroEnMemoire,numeroDansSonFichier);
		              end;
		           
		          if CodeErreur=NoErr then
		            for nroJoueur := decalageDansCeFichierDeJoueurs+nbJoueursDansCeFichier to decalageProchainFichier-1 do
		              begin
		                inc(nbJoueursFictifs);
		                joueurFictif := '•• Fictif n°'+NumEnString(nbJoueursFictifs);
		                
		                AjouterJoueurEnMemoire(joueurFictif,nroJoueur,0);
		              end;
		          
		          if (UpCaseStr(CalculeNomFichierNouveauFormat(numFichier))='WTHOR.JOU') then
		            begin
		              SetNombreJoueursDansBaseOfficielle(decalageDansCeFichierDeJoueurs+nbJoueursDansCeFichier);
		            end;
		          
		          if codeErreur<>NoErr then 
		            begin
		              MetJoueursNouveauFormatEnMemoire := codeErreur;
		              exit(MetJoueursNouveauFormatEnMemoire);
		            end;
		            
		          codeErreur := FermeFichierNouveauFormat(numFichier);
		          if codeErreur<>NoErr then 
		            begin
		              MetJoueursNouveauFormatEnMemoire := codeErreur;
		              exit(MetJoueursNouveauFormatEnMemoire);
		            end;
		        end;  
        end;
  
  MetJoueursNouveauFormatEnMemoire := codeErreur;
end;


procedure EffaceTousLesNomsCourtsDesJoueurs;
var k : SInt32;
begin
  for k := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
    SetNomCourtJoueur(k,'');
end;


function MetPseudosDeLaBaseWThor(nomDictionnaireDesPseudos : str255) : OSErr;
const kNbMaxNomsWThorConvertis = 30;
var erreurES : OSErr;
    ligne,s,s1,s2,reste : str255;
    dictionnairePseudosWThor : FichierTEXT;
    nom_dictionnaire : str255;
    position,nbPseudos,k,t : SInt32;
    association : array[1..kNbMaxNomsWThorConvertis] of
                  record 
                    oldName : str255;
                    newName : str255;
                  end;
    nomBase,nouveauNom:str30;
    arbreDesPseudos : ATR;
    modificationsAffichees : StringSet;
begin

  nom_dictionnaire := nomDictionnaireDesPseudos;
  
  erreurES := FichierTexteDeCassioExiste(nom_dictionnaire,dictionnairePseudosWThor);
  if (erreurES = fnfErr) then exit(MetPseudosDeLaBaseWThor);
  if (erreurES <> NoErr) then 
    begin
      AlerteSimpleFichierTexte(nom_dictionnaire,erreurES);
      exit(MetPseudosDeLaBaseWThor);
    end;
  
  
  erreurES := OuvreFichierTexte(dictionnairePseudosWThor);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nom_dictionnaire,erreurES);
      exit(MetPseudosDeLaBaseWThor);
    end;
    
  erreurES := NoErr;
  ligne := '';
  nbPseudos := 0;
  arbreDesPseudos := MakeEmptyATR();
  modificationsAffichees := MakeEmptyStringSet();
  
  while not(EOFFichierTexte(dictionnairePseudosWThor,erreurES)) do
    begin
      erreurES := ReadlnDansFichierTexte(dictionnairePseudosWThor,s);
      ligne := s;
      EnleveEspacesDeGaucheSurPlace(ligne);
      if (ligne='') | (ligne[1]='%') 
        then
          begin
            {erreurES := WritelnDansFichierTexte(outputBaseThor,s);}
          end
        else
          begin
          
            position := Pos('=',ligne);
            
            if position > 0 then
              begin
                s1    := TPCopy(ligne, 1, position - 1);
                s2    := '=';
                reste := TPCopy(ligne, position + 1, 255);
              
                EnleveEspacesDeGaucheSurPlace(s1);
                EnleveEspacesDeDroiteSurPlace(s1);
                EnleveEspacesDeGaucheSurPlace(reste);
                EnleveEspacesDeDroiteSurPlace(reste);
                
                if (s1 <> '') & (s2 = '=') & (reste <> '') then
                  begin
                    inc(nbPseudos);
                    
                    association[nbPseudos].oldName := s1;
                    association[nbPseudos].newName := reste;
                    
                    {WritelnDansRapport(s1 + ' ==> ' + reste);}
                    
                    s1 := MyUpperString(s1,false);
                    InsererDansATR(arbreDesPseudos,s1);
                    
                  end;
              end;
          end;
    end;
  erreurES := FermeFichierTexte(dictionnairePseudosWThor);
  
  if (nbPseudos > 0) & not(ATRIsEmpty(arbreDesPseudos)) then
    begin
    
      WritelnDansRapport('Trying to translate names using "'+nomDictionnaireDesPseudos+'"...');
      WritelnDansRapport('');
      {WritelnStringAndNumDansRapport('nbPseudos = ',nbPseudos);
      WritelnStringAndNumDansRapport('JoueursNouveauFormat.nbJoueursNouveauFormat = ',JoueursNouveauFormat.nbJoueursNouveauFormat);}
    
      for k := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
        begin
          nomBase := GetNomJoueur(k);
          nomBase := MyUpperString(nomBase,false);
          if ChaineEstPrefixeDansATR(arbreDesPseudos,nomBase) then
            begin
              for t := 1 to nbPseudos do
                if (Pos(MyUpperString(association[t].oldName,false),nomBase) > 0) then
                  begin
                    nouveauNom := association[t].newName;
                    TraduitNomJoueurEnMac(nouveauNom,nouveauNom);
                    
                    s := 'PLAYER #' + NumEnString(GetNroJoueurDansSonFichier(k)) + ' TRANSLATED : '+GetNomJoueur(k) + ' ==> ' + nouveauNom;
                    if not(MemberOfStringSet(s,position,modificationsAffichees)) then
                      begin
                        WritelnDansRapport(s);
                        AddStringToSet(s,GetNroJoueurDansSonFichier(k),modificationsAffichees);
                      end;
                    SetNomJoueur(k,nouveauNom);
                  end;
            end;
        end;
    end;
  
  DisposeStringSet(modificationsAffichees);
  DisposeATR(arbreDesPseudos);
  
  MetPseudosDeLaBaseWThor := erreurES;
end;



function MetTournoisNouveauFormatEnMemoire(nomsAbreges : boolean) : OSErr;
var numFichier,numDistrib,typeVoulu : SInt16; 
    nroTournoi,placeMemoireDemandee,nbTournoisFictifs : SInt32;
    nbExactsDeTournois,nbFichiersTournois,nbTournoisDansCeFichier : SInt32;
    decalageDansCeFichierDeTournois,decalageProchainFichier : SInt32;
    codeErreur : OSErr;
    s,tournoiFictif:str30;
    FichierWTHOR_TRNDejaTrouve : boolean;
    DistributionsAyantLeurPropreFichierDeTournois,distribProches:DistributionSet;
    numeroEnMemoire,numeroDansSonFichier : SInt32;
begin
  codeErreur := -1;
  FichierWTHOR_TRNDejaTrouve := false;
  DistributionsAyantLeurPropreFichierDeTournois := [];
  nbTournoisFictifs := 0;
  
  DisposeTournoisNouveauFormat;
  
  if nomsAbreges
    then typeVoulu := kFicTournoisCourtsNouveauFormat
    else typeVoulu := kFicTournoisNouveauFormat;
  
  nbExactsDeTournois := NbTotalDeTournoisDansFichiersNouveauFormat(typeVoulu,nbFichiersTournois,placeMemoireDemandee);
  placeMemoireDemandee := Min(placeMemoireDemandee,nbMaxTournoisEnMemoire-10);
  
  codeErreur := AllocateMemoireTournoisNouveauFormat(placeMemoireDemandee);
  if (codeErreur<>NoErr) then
    begin
      MetTournoisNouveauFormatEnMemoire := codeErreur;
      exit(MetTournoisNouveauFormatEnMemoire);
    end;
    
  if (TournoisNouveauFormat.nbTournoisNouveauFormat<>placeMemoireDemandee) then
    begin
      codeErreur := -1;
      MetTournoisNouveauFormatEnMemoire := codeErreur;
      exit(MetTournoisNouveauFormatEnMemoire);
    end;
  
  
  decalageProchainFichier := 0;
  
  for numFichier := 1 to InfosFichiersNouveauFormat.nbFichiers do
    with InfosFichiersNouveauFormat.fichiers[numFichier] , TournoisNouveauFormat do
      if (nomsAbreges & (typeDonnees = kFicTournoisCourtsNouveauFormat)) |
         (not(nomsAbreges) & (typeDonnees = kFicTournoisNouveauFormat)) then
        begin
          
          
          nbTournoisDansCeFichier := NbTournoisDansFichierTournoisNouveauFormat(numFichier);
          if nbTournoisDansCeFichier>0 then
            begin
          
		          decalageDansCeFichierDeTournois := decalageProchainFichier;
		          decalageProchainFichier := decalageProchainFichier+(((nbTournoisDansCeFichier-1) div 256)+1)*256 + 512;
		          
		          if not(FichierWTHOR_TRNDejaTrouve) & (UpCaseStr(CalculeNomFichierNouveauFormat(numFichier))='WTHOR.TRN') 
		            then
			            begin
			              FichierWTHOR_TRNDejaTrouve := true;
			              for numDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
			                if not(numDistrib in distributionsAyantLeurPropreFichierDeTournois) then
			                  SetDecalageNrosTournoisOfDistribution(numDistrib,decalageDansCeFichierDeTournois);
			            end
			          else
			            begin
			              distribProches := TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat(numFichier);
			              if distribProches<>[] then
			                begin
			                  distributionsAyantLeurPropreFichierDeTournois := distributionsAyantLeurPropreFichierDeTournois+distribProches;
			                  for numDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
			                    if numDistrib in distribProches then
			                      SetDecalageNrosTournoisOfDistribution(numDistrib,decalageDansCeFichierDeTournois);
			                end;
			            end;
		          		            
		          if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		          if codeErreur<>NoErr then 
		            begin
		              MetTournoisNouveauFormatEnMemoire := codeErreur;
		              exit(MetTournoisNouveauFormatEnMemoire);
		            end;
		          
		          for nroTournoi := 1 to nbTournoisDansCeFichier do
		            if CodeErreur=NoErr then
		              begin
		                codeErreur := LitTournoiNouveauFormat(numFichier,nroTournoi,s);
		                TraduitNomTournoiEnMac(s,s);
		                
		                numeroEnMemoire := decalageDansCeFichierDeTournois+nroTournoi-1;
		                numeroDansSonFichier := nroTournoi-1;
		                
		                AjouterTournoiEnMemoire(s,numeroEnMemoire,numeroDansSonFichier);
		              end;
		           
		          if CodeErreur=NoErr then
		            for nroTournoi := decalageDansCeFichierDeTournois+nbTournoisDansCeFichier to decalageProchainFichier-1 do
		              begin
		                inc(nbTournoisFictifs);
		                tournoiFictif := '•• Fictif n°'+NumEnString(nbTournoisFictifs);
		                
		                AjouterTournoiEnMemoire(tournoiFictif,nroTournoi,0);
		              end;
		          
		          if (UpCaseStr(CalculeNomFichierNouveauFormat(numFichier))='WTHOR.TRN') then
		            begin
		              SetNombreTournoisDansBaseOfficielle(decalageDansCeFichierDeTournois+nbTournoisDansCeFichier);
		            end;
		          
		          if codeErreur<>NoErr then 
		            begin
		              MetTournoisNouveauFormatEnMemoire := codeErreur;
		              exit(MetTournoisNouveauFormatEnMemoire);
		            end;
		            
		          codeErreur := FermeFichierNouveauFormat(numFichier);
		          if codeErreur<>NoErr then 
		            begin
		              MetTournoisNouveauFormatEnMemoire := codeErreur;
		              exit(MetTournoisNouveauFormatEnMemoire);
		            end;
		        end;  
        end;
  MetTournoisNouveauFormatEnMemoire := codeErreur;
end;

function OuvreFichierDesTournoisJaponais(var FichierTournoisJaponais : FichierTEXT) : OSErr;
var codeErreur : OSErr;
begin
  codeErreur := -1;
  if codeErreur<>NoErr then codeErreur := FichierTexteDeCassioExiste('tournaments.jap',FichierTournoisJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteDeCassioExiste('tournements.jap',FichierTournoisJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteExiste('database:tournaments.jap',VolumeRefCassio,FichierTournoisJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteExiste('database:tournaments.jap ',VolumeRefCassio,FichierTournoisJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteExiste('database:tournaments.jap (alias)',VolumeRefCassio,FichierTournoisJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteExiste('database:tournements.jap',VolumeRefCassio,FichierTournoisJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteExiste('database:tournements.jap ',VolumeRefCassio,FichierTournoisJaponais);
  if codeErreur<>NoErr then codeErreur := FichierTexteExiste('database:tournements.jap (alias)',VolumeRefCassio,FichierTournoisJaponais);
  if codeErreur=NoErr 
    then codeErreur := OuvreFichierTexte(FichierTournoisJaponais)
    else codeErreur := -43; {file not found}
    
  OuvreFichierDesTournoisJaponais := codeErreur;
end;


function LitNomsDesTournoisEnJaponais() : OSErr;
var codeErreur : OSErr;
    fic : FichierTEXT;
    s,nomLatin,nomJaponais,nomDuMilieuDansListe : str255;
    permutation : LongintArrayPtr;
    k,low,up,middle : SInt32;
    found,memeNom : boolean;
begin
  permutation := LongintArrayPtr(AllocateMemoryPtr((nbMaxTournoisEnMemoire+2)*sizeof(SInt32)));
  if permutation = NIL then SysBeep(0);
  with TournoisNouveauFormat do
    begin
      if (nbTournoisNouveauFormat<=0) | not(dejaTriesAlphabetiquement) then
		    begin
		      LitNomsDesTournoisEnJaponais := -1;
		      exit(LitNomsDesTournoisEnJaponais);
		    end;
  
      codeErreur := OuvreFichierDesTournoisJaponais(fic);
      if codeErreur=NoErr then
        begin
		      for k := 0 to nbTournoisNouveauFormat-1 do    {on inverse la permutation}
		        permutation^[GetNroOrdreAlphabetiqueTournoi(k)] := k;
    
          while (codeErreur=NoErr) & not(EOFFichierTexte(fic,codeErreur)) do
            begin
              codeErreur := ReadlnDansFichierTexte(fic,s);
              if (codeErreur=NoErr) & (s[1]<>'%') & (s<>'') & 
                 SplitAt(s,'=',nomLatin,nomJaponais) then
		            begin
		              EnleveEspacesDeGaucheSurPlace(nomLatin);
		              EnleveEspacesDeDroiteSurPlace(nomLatin);
		              UpperString(nomLatin,false);
		              EnleveEspacesDeGaucheSurPlace(nomJaponais);
		              EnleveEspacesDeDroiteSurPlace(nomJaponais);
                 
                 {binary search dans la liste des noms de tournois triee}
                  low := 0;
                  up := nbTournoisNouveauFormat-1;
                  found := false;
                  while (low<=up) & not(found) do
		                begin
			                middle := (low+up) div 2;
			                nomDuMilieuDansListe := GetNomTournoi(permutation^[middle]);
			                UpperString(nomDuMilieuDansListe,false);
			                    
			                if Pos(nomLatin,nomDuMilieuDansListe)>0 then found := true else
			                if nomLatin<nomDuMilieuDansListe then up := middle-1 else
			                if nomLatin>nomDuMilieuDansListe then low := middle+1 
			                  else found := true;
			              end;
	                if found then 
	                  begin
	                    SetNomJaponaisDuTournoi(permutation^[middle],nomJaponais);
                      {on cherche aussi en arriere dans la liste des tournois, pour les noms dupliques}
                      k := middle-1;
                      if (k >= 0) & (k <= nbTournoisNouveauFormat-1) then
                        repeat
                          nomDuMilieuDansListe := GetNomTournoi(permutation^[k]);
                          UpperString(nomDuMilieuDansListe,false);
                          memeNom := (Pos(nomLatin,nomDuMilieuDansListe) > 0);
                          if memeNom then SetNomJaponaisDuTournoi(permutation^[k],nomJaponais);
                          k := k-1;
                        until not(memeNom) | (k < 0);
                      {puis en avant}
                      k := middle+1;
                      if (k >= 0) & (k <= nbTournoisNouveauFormat-1) then
                        repeat
                          nomDuMilieuDansListe := GetNomTournoi(permutation^[k]);
                          UpperString(nomDuMilieuDansListe,false);
                          memeNom := (Pos(nomLatin,nomDuMilieuDansListe) > 0);
                          if memeNom then SetNomJaponaisDuTournoi(permutation^[k],nomJaponais);
                          k := k+1;
                        until not(memeNom) | (k > nbTournoisNouveauFormat-1);
                    end;
	              end;
            end;
          codeErreur := FermeFichierTexte(fic);
        end;
    end;
  if permutation <> NIL then DisposeMemoryPtr(Ptr(permutation));
  LitNomsDesTournoisEnJaponais := codeErreur;
end;



function EcritFichierIndexDesJoueursTries(nomsAbreges : boolean) : OSErr;
type myBufferTypePtr = ^array[0..0] of SInt32;
var numeroFichierDesJoueurs,typeVoulu : SInt16; 
    entete  : t_EnTeteNouveauFormat;
    buffer : myBufferTypePtr;
    k,count : SInt32;
    codeErreur : OSErr;
    path,nomCompletDuFichierIndex : str255;
    fic : FichierTEXT;
begin
  codeErreur := -1;
  EcritFichierIndexDesJoueursTries := -1;
  
  with InfosFichiersNouveauFormat,JoueursNouveauFormat do
    if (nbJoueursNouveauFormat > 0) & dejaTriesAlphabetiquement then
    begin
      if nomsAbreges
        then typeVoulu := kFicJoueursCourtsNouveauFormat
        else typeVoulu := kFicJoueursNouveauFormat;
      numeroFichierDesJoueurs := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);
      if (numeroFichierDesJoueurs>0) &
         (numeroFichierDesJoueurs<=nbFichiers) then
         begin
           entete := CreeEnteteFichierIndexJoueursNouveauFormat(typeVoulu);
           if (entete.PlaceMemoireIndex = nbJoueursNouveauFormat) then
             begin
               buffer := myBufferTypePtr(AllocateMemoryPtr(4*nbJoueursNouveauFormat));
               if buffer <> NIL then
                 begin
                   for k := 0 to nbJoueursNouveauFormat-1 do
                     buffer^[k] := GetNroOrdreAlphabetiqueJoueur(k);
                   
	                 path := CalculePathFichierNouveauFormat(numeroFichierDesJoueurs);
	                 nomCompletDuFichierIndex := path+CalculeNomFichierNouveauFormat(numeroFichierDesJoueurs)+'.index';
	       
	                 if FichierTexteExiste(nomCompletDuFichierIndex,0,fic) = NoErr
	                   then codeErreur := EffaceFichierTexte(fic);
	                 codeErreur := CreeFichierTexte(nomCompletDuFichierIndex,0,fic);
	                 SetFileCreatorFichierTexte(fic,'SNX4');
	                 SetFileTypeFichierTexte(fic,'INDX');
	       
	               
	                 codeErreur := OuvreFichierTexte(fic);
						       if codeErreur=0 then
						         begin
						           codeErreur := EcritEnteteNouveauFormat(fic.refNum,entete);
						           
						           count := 4;
						           codeErreur := FSWrite(fic.refNum,count,@nbJoueursNouveauFormat);
						           
						           count := 4*nbJoueursNouveauFormat;
						           codeErreur := FSWrite(fic.refNum,count,buffer);
						           
						           codeErreur := FermeFichierTexte(fic);
						         end;
						       
						     end;
               if buffer <> NIL then DisposeMemoryPtr(Ptr(buffer));
             end;
         end;
    end;
  EcritFichierIndexDesJoueursTries := codeErreur;
end;


function LitFichierIndexDesJoueursTries(nomsAbreges : boolean) : OSErr;
type myBufferTypePtr= ^array[0..0] of SInt32;
var numeroFichierIndex,numeroFichierJoueurs,typeVoulu : SInt16; 
    enteteIndex,enteteDesJoueurs : t_EnTeteNouveauFormat;
    buffer:myBufferTypePtr;
    k,count,nbNomsDansFichierIndex : SInt32;
    nbExactsDeJoueurs,nbFicJoueurs,placeMemoirePrise : SInt32;
    codeErreur : OSErr;
begin
  codeErreur := -1;
  LitFichierIndexDesJoueursTries := -1;
  
  with InfosFichiersNouveauFormat,JoueursNouveauFormat do
    if (nbJoueursNouveauFormat > 0) then
    begin
    
      if nomsAbreges
        then typeVoulu := kFicIndexJoueursCourtsNouveauFormat
        else typeVoulu := kFicIndexJoueursNouveauFormat;
      numeroFichierIndex := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);
      
      if nomsAbreges
        then typeVoulu := kFicJoueursCourtsNouveauFormat
        else typeVoulu := kFicJoueursNouveauFormat;
      numeroFichierJoueurs := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);           
      
      nbExactsDeJoueurs := NbTotalDeJoueursDansFichiersNouveauFormat(typeVoulu,nbFicJoueurs,placeMemoirePrise);
      
      if (numeroFichierIndex>0) & (numeroFichierIndex<=nbFichiers) &
         (numeroFichierJoueurs>0) & (numeroFichierJoueurs<=nbFichiers) then
         begin
           enteteIndex := fichiers[numeroFichierIndex].entete;
           enteteDesJoueurs := CreeEnteteFichierIndexJoueursNouveauFormat(typeVoulu);
           
           if EntetesEgauxNouveauFormat(enteteIndex,enteteDesJoueurs) & 
              (enteteIndex.NombreEnregistrementsParties = nbExactsDeJoueurs) &
              (enteteIndex.PlaceMemoireIndex = placeMemoirePrise) &
              (nbJoueursNouveauFormat = placeMemoirePrise) then
             begin
               buffer := myBufferTypePtr(AllocateMemoryPtr(4*nbJoueursNouveauFormat));
               if buffer <> NIL then
                 with fichiers[numeroFichierIndex] do
                 begin
                   if not(open) then 
                     begin
                       codeErreur := OuvreFichierNouveauFormat(numeroFichierIndex);
                       if codeErreur<>NoErr then exit(LitFichierIndexDesJoueursTries);
                     end;
                     
                   codeErreur := LitEnteteNouveauFormat(refnum,enteteIndex);
	                 if codeErreur<>NoErr then exit(LitFichierIndexDesJoueursTries);
	                 
                   codeErreur := MyFSRead(refnum,4,@nbNomsDansFichierIndex);
	                 if codeErreur<>NoErr then exit(LitFichierIndexDesJoueursTries);
                   
                   if (nbJoueursNouveauFormat<>enteteIndex.PlaceMemoireIndex) |
	                    (nbNomsDansFichierIndex<>nbJoueursNouveauFormat)
	                    then exit(LitFichierIndexDesJoueursTries);
                   
                   count := 4*nbJoueursNouveauFormat;
						       codeErreur := FSRead(refnum,count,buffer);
						       if codeErreur<>NoErr then exit(LitFichierIndexDesJoueursTries);
						       
						       for k := 0 to nbJoueursNouveauFormat-1 do
                     SetNroOrdreAlphabetiqueJoueur(k,buffer^[k]);
                   
                   codeErreur := FermeFichierNouveauFormat(numeroFichierIndex);
                 end;
               if buffer <> NIL then DisposeMemoryPtr(Ptr(buffer));
             end;
         end;
    end;
  LitFichierIndexDesJoueursTries := codeErreur;
end;


function EcritFichierIndexDesTournoisTries(nomsAbreges : boolean) : OSErr;
type myBufferTypePtr= ^array[0..0] of SInt32;
var numeroFichierDesTournois,typeVoulu : SInt16; 
    entete : t_EnTeteNouveauFormat;
    buffer : myBufferTypePtr;
    k,count : SInt32;
    codeErreur : OSErr;
    path,nomCompletDuFichierIndex : str255;
    fic : FichierTEXT;
begin
  codeErreur := -1;
  EcritFichierIndexDesTournoisTries := -1;
  
  with InfosFichiersNouveauFormat,TournoisNouveauFormat do
    if (nbTournoisNouveauFormat>0) & dejaTriesAlphabetiquement then
    begin
      if nomsAbreges
        then typeVoulu := kFicTournoisCourtsNouveauFormat
        else typeVoulu := kFicTournoisNouveauFormat;
      numeroFichierDesTournois := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);
      if (numeroFichierDesTournois>0) &
         (numeroFichierDesTournois<=nbFichiers) then
         begin
           entete := CreeEnteteFichierIndexTournoisNouveauFormat(typeVoulu);
           if (entete.PlaceMemoireIndex = nbTournoisNouveauFormat) then
             begin
               buffer := myBufferTypePtr(AllocateMemoryPtr(4*nbTournoisNouveauFormat));
               if buffer <> NIL then
                 begin
                   for k := 0 to nbTournoisNouveauFormat-1 do
                     buffer^[k] := GetNroOrdreAlphabetiqueTournoi(k);
                   
	                 path := CalculePathFichierNouveauFormat(numeroFichierDesTournois);
	                 nomCompletDuFichierIndex := path+CalculeNomFichierNouveauFormat(numeroFichierDesTournois)+'.index';
	                 
	                 if FichierTexteExiste(nomCompletDuFichierIndex,0,fic) = NoErr
	                   then codeErreur := EffaceFichierTexte(fic);
	                 codeErreur := CreeFichierTexte(nomCompletDuFichierIndex,0,fic);
	                 SetFileCreatorFichierTexte(fic,'SNX4');
	                 SetFileTypeFichierTexte(fic,'INDX');
	                 
	                 
	                 codeErreur := OuvreFichierTexte(fic);
						       if codeErreur=0 then
						         begin
						           codeErreur := EcritEnteteNouveauFormat(fic.refNum,entete);
						           
						           count := 4;
						           codeErreur := FSWrite(fic.refNum,count,@nbTournoisNouveauFormat);
						           
						           count := 4*nbTournoisNouveauFormat;
						           codeErreur := FSWrite(fic.refNum,count,buffer);
						           
						           codeErreur := FermeFichierTexte(fic);
						         end;
						       
						     end;
               if buffer <> NIL then DisposeMemoryPtr(Ptr(buffer));
             end;
         end;
    end;
  EcritFichierIndexDesTournoisTries := codeErreur;
end;


function LitFichierIndexDesTournoisTries(nomsAbreges : boolean) : OSErr;
type myBufferTypePtr= ^array[0..0] of SInt32;
var numeroFichierIndex,numeroFichierTournois,typeVoulu : SInt16; 
    enteteIndex,enteteDesTournois : t_EnTeteNouveauFormat;
    buffer:myBufferTypePtr;
    k,count,nbNomsDansFichierIndex : SInt32;
    nbExactsDeTournois,nbFicTournois,placeMemoirePrise : SInt32;
    codeErreur : OSErr;
begin
  codeErreur := -1;
  LitFichierIndexDesTournoisTries := -1;
  
  with InfosFichiersNouveauFormat,TournoisNouveauFormat do
    if (nbTournoisNouveauFormat>0) then
    begin
    
      if nomsAbreges
        then typeVoulu := kFicIndexTournoisCourtsNouveauFormat
        else typeVoulu := kFicIndexTournoisNouveauFormat;
      numeroFichierIndex := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);
      
      if nomsAbreges
        then typeVoulu := kFicTournoisCourtsNouveauFormat
        else typeVoulu := kFicTournoisNouveauFormat;
      numeroFichierTournois := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);
      
      nbExactsDeTournois := NbTotalDeTournoisDansFichiersNouveauFormat(typeVoulu,nbFicTournois,placeMemoirePrise);
      
      if (numeroFichierIndex>0) & (numeroFichierIndex<=nbFichiers) &
         (numeroFichierTournois>0) & (numeroFichierTournois<=nbFichiers) then
         begin
           enteteIndex := fichiers[numeroFichierIndex].entete;
           enteteDesTournois := CreeEnteteFichierIndexTournoisNouveauFormat(typeVoulu);
           
           if EntetesEgauxNouveauFormat(enteteIndex,enteteDesTournois) & 
              (enteteIndex.NombreEnregistrementsParties = nbExactsDeTournois) &
              (enteteIndex.PlaceMemoireIndex = placeMemoirePrise) &
              (nbTournoisNouveauFormat = placeMemoirePrise) then
             begin
               buffer := myBufferTypePtr(AllocateMemoryPtr(4*nbTournoisNouveauFormat));
               if buffer <> NIL then
                 with fichiers[numeroFichierIndex] do
                 begin
                   if not(open) then 
                     begin
                       codeErreur := OuvreFichierNouveauFormat(numeroFichierIndex);
                       if codeErreur<>NoErr then exit(LitFichierIndexDesTournoisTries);
                     end;
                     
                   codeErreur := LitEnteteNouveauFormat(refnum,enteteIndex);
	                 if codeErreur<>NoErr then exit(LitFichierIndexDesTournoisTries);
	                 
                   codeErreur := MyFSRead(refnum,4,@nbNomsDansFichierIndex);
	                 if codeErreur<>NoErr then exit(LitFichierIndexDesTournoisTries);
                   
                   if (nbTournoisNouveauFormat<>enteteIndex.PlaceMemoireIndex) |
	                    (nbNomsDansFichierIndex<>nbTournoisNouveauFormat)
	                    then exit(LitFichierIndexDesTournoisTries);
                   
                   count := 4*nbTournoisNouveauFormat;
						       codeErreur := FSRead(refnum,count,buffer);
						       if codeErreur<>NoErr then exit(LitFichierIndexDesTournoisTries);
						       
						       for k := 0 to nbTournoisNouveauFormat-1 do
                     SetNroOrdreAlphabetiqueTournoi(k,buffer^[k]);
                   
                   codeErreur := FermeFichierNouveauFormat(numeroFichierIndex);
                 end;
               if buffer <> NIL then DisposeMemoryPtr(Ptr(buffer));
             end;
         end;
    end;
  LitFichierIndexDesTournoisTries := codeErreur;
end;



function MetJoueursEtTournoisEnMemoire(nomsAbreges : boolean) : OSErr;
var codeErreur : OSErr;
    s : str255;
    joueursEnMemoire,tournoisEnMemoire : boolean;
begin
  if (InfosFichiersNouveauFormat.nbFichiers<=0) then
    LecturePreparatoireDossierDatabase(volumeRefCassio);
    
  codeErreur := MetJoueursNouveauFormatEnMemoire(nomsAbreges);
  joueursEnMemoire := (codeErreur=NoErr);
  if (codeErreur <> NoErr) then
    begin
      GetIndString(s,TextesNouveauFormatID,1);
      AlerteSimple(ParamStr(s,NumEnString(codeErreur),'','',''));
      MetJoueursEtTournoisEnMemoire := codeErreur;
    end;
  
  codeErreur := MetPseudosDeLaBaseWThor('name_mapping_WThor_to_WThor.txt');
    
  codeErreur := MetTournoisNouveauFormatEnMemoire(nomsAbreges);
  tournoisEnMemoire := (codeErreur=NoErr);
  if (codeErreur <> NoErr) then
    begin
      GetIndString(s,TextesNouveauFormatID,2);
      AlerteSimple(ParamStr(s,NumEnString(codeErreur),'','',''));
      MetJoueursEtTournoisEnMemoire := codeErreur;
    end;
  JoueursEtTournoisEnMemoire := joueursEnMemoire & tournoisEnMemoire;
end;



procedure InitialiseJoueursBidonsNouveauFormat;
var n : SInt32;
    s30:str30;
begin
  with JoueursNouveauFormat do
    begin
      if (nbJoueursNouveauFormat > 0) & (listeJoueurs <> NIL) then
        begin
          for n := 0 to nbJoueursNouveauFormat-1 do
            begin
              s30 := 'joueur #'+NumEnString(n);
              SetNomJoueur(n,s30);
            end;
        end;
    end;
end;




procedure InitialiseTournoisBidonsNouveauFormat;
var n : SInt32;
    s30:str30;
begin
  with TournoisNouveauFormat do
    begin
      if (nbTournoisNouveauFormat>0) & (listeTournois <> NIL) then
        begin
          for n := 0 to nbTournoisNouveauFormat-1 do
            begin
              s30 := 'Tournoi #'+NumEnString(n);
              SetNomTournoi(n,s30);
            end;
        end;
    end;
end;


function TraiteNouveauFormatEtRecursion(var fs : FSSpec; isFolder : boolean; path : str255; var pb:CInfoPBRec) : boolean;
var entete : t_EnTeteNouveauFormat;
    typeDonnees : SInt16; 
    nomDistrib : str255;
    anneeDansDistrib : SInt16; 
    bidon : boolean;
    bidint : SInt16; 
begin
 {$UNUSED pb}
  if not(isFolder) & (Pos('Gestion Base WThor',path) <= 0) & 
     (fs.name[1] <> '.') & EstUnFichierNouveauFormat(fs,typeDonnees,entete) then
    begin
      if (typeDonnees=kFicPartiesNouveauFormat) then
        begin
          nomDistrib := NomDistributionAssocieeNouveauFormat(fs.name,anneeDansDistrib);
          AjouterDistributionNouveauFormat(nomDistrib,GetPathOfScannedDirectory()+path,kFicPartiesNouveauFormat);
          {SetFileCreator(GetPathOfScannedDirectory()+path+fs.name,'SNX4');
          SetFileType(GetPathOfScannedDirectory()+path+fs.name,'QWTB');}
          SetFileCreator(fs,'SNX4');
          SetFileType(fs,'QWTB');
        end;
      if (typeDonnees=kFicIndexPartiesNouveauFormat) then
        begin
          nomDistrib := NomDistributionAssocieeNouveauFormat(fs.name,anneeDansDistrib);
          AjouterDistributionNouveauFormat(nomDistrib,GetPathOfScannedDirectory()+path,kFicPartiesNouveauFormat);
        end;
      if (typeDonnees=kFicSolitairesNouveauFormat) then
        begin
          nomDistrib := NomDistributionAssocieeNouveauFormat(fs.name,bidint);
          AjouterDistributionNouveauFormat(nomDistrib,GetPathOfScannedDirectory()+path,kFicSolitairesNouveauFormat);
        end;
      if (typeDonnees=kFicJoueursNouveauFormat) |
         (typeDonnees=kFicTournoisNouveauFormat) |
         (typeDonnees=kFicJoueursCourtsNouveauFormat) |
         (typeDonnees=kFicTournoisCourtsNouveauFormat) then
        begin
          {SetFileCreator(GetPathOfScannedDirectory()+path+fs.name,'SNX4');
          SetFileType(GetPathOfScannedDirectory()+path+fs.name,'QWTB');}
          SetFileCreator(fs,'SNX4');
          SetFileType(fs,'QWTB');
        end;
      if (typeDonnees=kFicSolitairesNouveauFormat) then
        begin
          {SetFileCreator(GetPathOfScannedDirectory()+path+fs.name,'SNX4');
          SetFileType(GetPathOfScannedDirectory()+path+fs.name,'PZZL');}
          SetFileCreator(fs,'SNX4');
          SetFileType(fs,'PZZL');
        end;
      bidon := AjouterFichierNouveauFormat(fs,GetPathOfScannedDirectory()+path,typeDonnees,entete);
    end;
  TraiteNouveauFormatEtRecursion := isFolder; {on cherche recursivement}
end;


procedure ChercheFichiersNouveauFormatDansDossier(vRefNum : SInt16; NomDossier : str255; var dossierTrouve : boolean);
var directoryDepart : FSSpec;
    codeErreur : OSErr;
    cheminDirectoryDepartRecursion : str255;
begin
  cheminDirectoryDepartRecursion := GetWDName(vRefNum)+NomDossier+':';
    
  codeErreur := MyFSMakeFSSpec(vRefNum,vRefNum,cheminDirectoryDepartRecursion,directoryDepart);
  
  codeErreur := SetPathOfScannedDirectory(directoryDepart);
  
  if codeErreur=0 then
    codeErreur := ScanDirectory(directoryDepart,TraiteNouveauFormatEtRecursion);
  
  if (codeErreur = 0)
    then
      begin
        dossierTrouve := true;
        volumeRefDossierDatabase := directoryDepart.vRefNum;
        pathToDataBase := GetPathOfScannedDirectory();
        {WritelnDansRapport('pathToDataBase = '+pathToDataBase);}
      end
    else
      dossierTrouve := false;
end;


function EcourteNomDistributionNouveauFormat(nomLong : str255) : str255;
var s : str255;
    posXXXX : SInt16; 
begin
  s := UpCaseStr(nomLong);
  posXXXX := Pos('XXXX',s);
  if posXXXX > 0
    then ecourteNomDistributionNouveauFormat := LeftOfString(nomLong,posXXXX-1)
    else ecourteNomDistributionNouveauFormat := nomLong;
end;

function NbTotalPartiesDansDistributionSet(ensemble:DistributionSet) : SInt32;
var somme : SInt32;
    k : SInt16; 
begin
  somme := 0;
  with InfosFichiersNouveauFormat do
    for k := 1 to nbFichiers do
      if (fichiers[k].typeDonnees = kFicPartiesNouveauFormat) &
         (fichiers[k].nroDistribution in ensemble) then
        begin
          somme := somme + fichiers[k].entete.NombreEnregistrementsParties;
        end;
  NbTotalPartiesDansDistributionSet := somme;
end;

procedure SetDecalageNrosJoueursOfDistribution(nroDistrib : SInt16; decalage : SInt32);
begin
  with DistributionsNouveauFormat do
    if (nroDistrib >= 1) & (nroDistrib <= nbDistributions) then
      Distribution[nroDistrib].decalageNrosJoueurs := decalage;
  {WritelnStringAndNumDansRapport('decalage distrib n°'+NumEnString(nroDistrib)+' = ',decalage);}
end;

function  GetDecalageNrosJoueursOfDistribution(nroDistrib : SInt16) : SInt32;
begin
  with DistributionsNouveauFormat do
    if (nroDistrib>=1) & (nroDistrib<=nbDistributions) 
      then GetDecalageNrosJoueursOfDistribution := Distribution[nroDistrib].decalageNrosJoueurs
      else GetDecalageNrosJoueursOfDistribution := 0;
end;

procedure SetDecalageNrosTournoisOfDistribution(nroDistrib : SInt16; decalage : SInt32);
begin
  with DistributionsNouveauFormat do
    if (nroDistrib>=1) & (nroDistrib<=nbDistributions) then
      Distribution[nroDistrib].decalageNrosTournois := decalage;
end;

function  GetDecalageNrosTournoisOfDistribution(nroDistrib : SInt16) : SInt32;
begin
  with DistributionsNouveauFormat do
    if (nroDistrib>=1) & (nroDistrib<=nbDistributions) 
      then GetDecalageNrosTournoisOfDistribution := Distribution[nroDistrib].decalageNrosTournois
      else GetDecalageNrosTournoisOfDistribution := 0;
end;


function IndexerFichierPartiesEnMemoireNouveauFormat(numFichierParties : SInt16) : OSErr;
var nroPartie,nbParties : SInt32;
    theGame:t_PartieRecNouveauFormat;
    codeErreur : OSErr;
    bufferOuverture:packed7;
begin
  IndexerFichierPartiesEnMemoireNouveauFormat := -1;
  with InfosFichiersNouveauFormat,IndexNouveauFormat do
    begin
      if (numFichierParties>0) & (numFichierParties<=nbFichiers) &
         (fichiers[numFichierParties].typeDonnees=kFicPartiesNouveauFormat) then
         begin
           nbParties := fichiers[numFichierParties].entete.NombreEnregistrementsParties;
           codeErreur := AllocateMemoireIndexNouveauFormat(nbParties);
           if codeErreur<>NoErr then exit(IndexerFichierPartiesEnMemoireNouveauFormat);
           codeErreur := OuvreFichierNouveauFormat(numFichierParties);
           if codeErreur<>NoErr then exit(IndexerFichierPartiesEnMemoireNouveauFormat);
           for nroPartie := 1 to nbParties do
             begin
               codeErreur := LitPartieNouveauFormat(numFichierParties,nroPartie,true,theGame);
               
               indexNoir^[nroPartie] := BitAnd(theGame.nroJoueurNoir,$FF);
               indexBlanc^[nroPartie] := BitAnd(theGame.nroJoueurBlanc,$FF);
               indexTournoi^[nroPartie] := BitAnd(theGame.nroTournoi,$FF);
               
               MoveMemory(@theGame.listeCoups,@bufferOuverture,nbOctetsOuvertures);
               indexOuverture^[nroPartie] := NroOuverture(bufferOuverture);
               
             end;
           codeErreur := FermeFichierNouveauFormat(numFichierParties);
           IndexerFichierPartiesEnMemoireNouveauFormat := codeErreur;
         end;
    end;
end;



function EcritFichierIndexNouveauFormat(numFichierParties : SInt16) : OSErr;
var codeErreur : OSErr;
    nomCompletDuFichierIndex,path : str255;
    enteteIndex : t_EnTeteNouveauFormat;
    fic : FichierTEXT;
    count : SInt32;
begin
  EcritFichierIndexNouveauFormat := -1;
  with InfosFichiersNouveauFormat,IndexNouveauFormat do
    if (numFichierParties>0) & (numFichierParties<=nbFichiers) &
       (fichiers[numFichierParties].typeDonnees=kFicPartiesNouveauFormat) &
       (fichiers[numFichierParties].entete.NombreEnregistrementsParties=tailleIndex) then
	     begin
	       {path := DistributionsNouveauFormat.Distribution[fichiers[numFichierParties].nroDistribution].path^;}
	       path := CalculePathFichierNouveauFormat(numFichierParties);
	       nomCompletDuFichierIndex := path+NomFichierIndexAssocieNouveauFormat(CalculeNomFichierNouveauFormat(numFichierParties));
	       
	       if FichierTexteExiste(nomCompletDuFichierIndex,0,fic) = NoErr
           then codeErreur := EffaceFichierTexte(fic);
         codeErreur := CreeFichierTexte(nomCompletDuFichierIndex,0,fic);
         SetFileCreatorFichierTexte(fic,'SNX4');
         SetFileTypeFichierTexte(fic,'INDX');
	       
	       codeErreur := OuvreFichierTexte(fic);
	       if codeErreur=0 then
	         begin
	           enteteIndex := fichiers[numFichierParties].entete;
	           codeErreur := EcritEnteteNouveauFormat(fic.refNum,enteteIndex);
	           
	           count := 4;
	           codeErreur := FSWrite(fic.refNum,count,@tailleIndex);
	           
	           count := tailleIndex;
	           codeErreur := FSWrite(fic.refNum,count,@indexNoir^[1]);
	           count := tailleIndex;
	           codeErreur := FSWrite(fic.refNum,count,@indexBlanc^[1]);
	           count := tailleIndex;
	           codeErreur := FSWrite(fic.refNum,count,@indexTournoi^[1]);
	           count := tailleIndex;
	           codeErreur := FSWrite(fic.refNum,count,@indexOuverture^[1]);
	           
	           codeErreur := FermeFichierTexte(fic);
	         end;
	       
	       EcritFichierIndexNouveauFormat := codeErreur;
	     end;
end;


function LitFichierIndexNouveauFormat(numFichierIndex : SInt16) : OSErr;
var codeErreur : OSErr;
    nbrePartiesDansFicIndex : SInt32;
    s : str255;
label cleanUp;
begin
  LitFichierIndexNouveauFormat := -1;
  codeErreur := NoErr;
  
  with InfosFichiersNouveauFormat do
    if (numFichierIndex>0) & (numFichierIndex<=nbFichiers) &
       (fichiers[numFichierIndex].typeDonnees=kFicIndexPartiesNouveauFormat) then
      with fichiers[numFichierIndex] do
	      begin
	        if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichierIndex);
	        if codeErreur<>NoErr then goto cleanUp;
	        
	        codeErreur := LitEnteteNouveauFormat(refnum,entete);
	        if codeErreur<>NoErr then goto cleanUp;
	        
	        codeErreur := MyFSRead(refnum,4,@nbrePartiesDansFicIndex);
	        if codeErreur<>NoErr then goto cleanUp;
	        
	        if nbrePartiesDansFicIndex<>entete.NombreEnregistrementsParties then 
	          begin
	            codeErreur := -2;
	            goto cleanUp;
	          end;
	      
	        codeErreur := AllocateMemoireIndexNouveauFormat(nbrePartiesDansFicIndex);
          if codeErreur<>NoErr then goto cleanUp;
	        
	        with IndexNouveauFormat do
	          begin
	            tailleindex := 0;
	            
	            codeErreur := myFSRead(refnum,nbrePartiesDansFicIndex,@indexNoir^[1]);
	            if codeErreur<>NoErr then goto cleanUp;
	            
	            codeErreur := myFSRead(refnum,nbrePartiesDansFicIndex,@indexBlanc^[1]);
	            if codeErreur<>NoErr then goto cleanUp;
	            
	            codeErreur := myFSRead(refnum,nbrePartiesDansFicIndex,@indexTournoi^[1]);
	            if codeErreur<>NoErr then goto cleanUp;
	            
	            codeErreur := myFSRead(refnum,nbrePartiesDansFicIndex,@indexOuverture^[1]);
	            if codeErreur<>NoErr then goto cleanUp;
	            
	            tailleindex := nbrePartiesDansFicIndex;
	          end;
	        
	        codeErreur := FermeFichierNouveauFormat(numFichierIndex);
	        
	        
	        cleanUp :
	        
	        if codeErreur <> NoErr 
	          then 
	            begin
	              s := Concat('WARNING : LitFichierIndexNouveauFormat : erreur ' , NumEnString(codeErreur));
	              TraceLog(s);
	            end;
	          
	        LitFichierIndexNouveauFormat := codeErreur;
	      end;
end;

procedure IndexerLesFichiersNouveauFormat;
var err : OSErr;
    numFichier : SInt16; 
begin
  numFichier := 1;
  with InfosFichiersNouveauFormat do
    repeat
      if (numFichier<=nbFichiers) & 
         (fichiers[numFichier].typeDonnees = kFicPartiesNouveauFormat) then
        begin
          err := IndexerFichierPartiesEnMemoireNouveauFormat(numFichier);
          err := EcritFichierIndexNouveauFormat(numFichier);
        end;
      numFichier := succ(numFichier);
    until (numFichier>nbFichiers) | EscapeDansQueue();
end;


function NbPartiesFichierNouveauFormat(numFichier : SInt16) : SInt32;
begin
  NbPartiesFichierNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numFichier>0) & (numFichier<=nbFichiers) &
     (fichiers[numFichier].typeDonnees=kFicPartiesNouveauFormat) then
       NbPartiesFichierNouveauFormat := fichiers[numFichier].entete.NombreEnregistrementsParties;
end;

function AnneePartiesFichierNouveauFormat(numFichier : SInt16) : SInt16; 
begin
  AnneePartiesFichierNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numFichier>0) & (numFichier<=nbFichiers) &
     (fichiers[numFichier].typeDonnees=kFicPartiesNouveauFormat) then
       AnneePartiesFichierNouveauFormat := fichiers[numFichier].annee;
end;

function NbJoueursDansFichierJoueursNouveauFormat(numFichier : SInt16) : SInt32;
begin
  NbJoueursDansFichierJoueursNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numFichier>0) & (numFichier<=nbFichiers) &
     ((fichiers[numFichier].typeDonnees=kFicJoueursNouveauFormat) |
      (fichiers[numFichier].typeDonnees=kFicJoueursCourtsNouveauFormat)) then
       NbJoueursDansFichierJoueursNouveauFormat := fichiers[numFichier].entete.NombreEnregistrementsTournoisEtJoueurs;
end;

function NbTournoisDansFichierTournoisNouveauFormat(numFichier : SInt16) : SInt32;
begin
  NbTournoisDansFichierTournoisNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numFichier>0) & (numFichier<=nbFichiers) &
     ((fichiers[numFichier].typeDonnees=kFicTournoisNouveauFormat) |
      (fichiers[numFichier].typeDonnees=kFicTournoisCourtsNouveauFormat)) then
       NbTournoisDansFichierTournoisNouveauFormat := fichiers[numFichier].entete.NombreEnregistrementsTournoisEtJoueurs;
end;

function NbTotalDeJoueursDansFichiersNouveauFormat(typeVoulu : SInt16; var nbFichiersJoueurs,placeMemoireNecessaire : SInt32) : SInt32;
var i,aux,somme : SInt32;
begin
  nbFichiersJoueurs := 0;
  placeMemoireNecessaire := 0;
  
  somme := 0;
  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      if ((fichiers[i].typeDonnees=kFicJoueursNouveauFormat) | (fichiers[i].typeDonnees=kFicJoueursCourtsNouveauFormat)) &
         (fichiers[i].typeDonnees=typeVoulu) then
        begin
          aux := NbJoueursDansFichierJoueursNouveauFormat(i);
          if aux>0 then
            begin
              nbFichiersJoueurs := nbFichiersJoueurs+1;
              somme := somme+aux;
              placeMemoireNecessaire := placeMemoireNecessaire + (((aux-1) div 256)+1)*256 + 512;
            end;
        end;
  NbTotalDeJoueursDansFichiersNouveauFormat := somme;
end;


function CreeEnteteFichierIndexJoueursNouveauFormat(typeVoulu : SInt16) : t_EnTeteNouveauFormat;
var i,aux,nbTotalDeJoueurs,placeMemoireNecessaire,nbFichiersJoueurs : SInt32;
    result : t_EnTeteNouveauFormat;
begin
  with result do
    begin
      siecleCreation := 0;
      anneeCreation := 0;
      MoisCreation := 0;
      JourCreation := 0;
      NombreEnregistrementsParties := 0;
      NombreEnregistrementsTournoisEtJoueurs := 0;
      AnneeParties := 0;
      PlaceMemoireIndex := 0;
    end;
    
  nbFichiersJoueurs := 0;
  placeMemoireNecessaire := 0;
  nbTotalDeJoueurs := 0;
  
  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      if ((fichiers[i].typeDonnees=kFicJoueursNouveauFormat) | (fichiers[i].typeDonnees=kFicJoueursCourtsNouveauFormat)) &
         (fichiers[i].typeDonnees=typeVoulu) then
        begin
          aux := NbJoueursDansFichierJoueursNouveauFormat(i);
          if aux>0 then
            begin
              nbFichiersJoueurs := nbFichiersJoueurs+1;
              nbTotalDeJoueurs := nbTotalDeJoueurs+aux;
              placeMemoireNecessaire := placeMemoireNecessaire + (((aux-1) div 256)+1)*256 + 512;
              
              if EntetePlusRecentNouveauFormat(fichiers[i].entete,result) then
		            begin
		              result.siecleCreation := fichiers[i].entete.siecleCreation;
		              result.anneeCreation := fichiers[i].entete.anneeCreation;
		              result.MoisCreation  := fichiers[i].entete.MoisCreation;
		              result.JourCreation  := fichiers[i].entete.JourCreation;
		            end;
            end;
        end;
  
  result.NombreEnregistrementsParties := nbTotalDeJoueurs;
  result.PlaceMemoireIndex := placeMemoireNecessaire;
  
  CreeEnteteFichierIndexJoueursNouveauFormat := result;
end;

function NbTotalDeTournoisDansFichiersNouveauFormat(typeVoulu : SInt16; var nbFichiersTournois,placeMemoireNecessaire : SInt32) : SInt32;
var i,aux,somme : SInt32;
begin
  nbFichiersTournois := 0;
  placeMemoireNecessaire := 0;
  
  somme := 0;
  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      if ((fichiers[i].typeDonnees=kFicTournoisNouveauFormat) | (fichiers[i].typeDonnees=kFicTournoisCourtsNouveauFormat)) &
         (fichiers[i].typeDonnees=typeVoulu) then
        begin
          aux := NbTournoisDansFichierTournoisNouveauFormat(i);
          if aux>0 then
            begin
              nbFichiersTournois := nbFichiersTournois+1;
              somme := somme+aux;
              placeMemoireNecessaire := placeMemoireNecessaire + (((aux-1) div 256)+1)*256 + 512;
            end;
        end;
  NbTotalDeTournoisDansFichiersNouveauFormat := somme;
end;


function CreeEnteteFichierIndexTournoisNouveauFormat(typeVoulu : SInt16) : t_EnTeteNouveauFormat;
var i,aux,nbTotalDeTournois,placeMemoireNecessaire,nbFichiersTournois : SInt32;
    result : t_EnTeteNouveauFormat;
begin
  with result do
    begin
      siecleCreation := 0;
      anneeCreation := 0;
      MoisCreation := 0;
      JourCreation := 0;
      NombreEnregistrementsParties := 0;
      NombreEnregistrementsTournoisEtJoueurs := 0;
      AnneeParties := 0;
      PlaceMemoireIndex := 0;
    end;
    
  nbFichiersTournois := 0;
  placeMemoireNecessaire := 0;
  nbTotalDeTournois := 0;
  
  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      if ((fichiers[i].typeDonnees=kFicTournoisNouveauFormat) | (fichiers[i].typeDonnees=kFicTournoisCourtsNouveauFormat)) &
         (fichiers[i].typeDonnees=typeVoulu) then
        begin
          aux := NbTournoisDansFichierTournoisNouveauFormat(i);
          if aux>0 then
            begin
              nbFichiersTournois := nbFichiersTournois+1;
              nbTotalDeTournois := nbTotalDeTournois+aux;
              placeMemoireNecessaire := placeMemoireNecessaire + (((aux-1) div 256)+1)*256 + 512;
              
              if EntetePlusRecentNouveauFormat(fichiers[i].entete,result) then
		            begin
		              result.siecleCreation := fichiers[i].entete.siecleCreation;
		              result.anneeCreation  := fichiers[i].entete.anneeCreation;
		              result.MoisCreation   := fichiers[i].entete.MoisCreation;
		              result.JourCreation   := fichiers[i].entete.JourCreation;
		            end;
            end;
        end;
  
  result.NombreEnregistrementsParties := nbTotalDeTournois;
  result.PlaceMemoireIndex := placeMemoireNecessaire;
  
  CreeEnteteFichierIndexTournoisNouveauFormat := result;
end;

procedure EtablitLiaisonEntrePartiesEtIndexNouveauFormat;
var numFichier,k : SInt16; 
    found : boolean;
begin
  with InfosFichiersNouveauFormat do
    for k := 1 to nbFichiers do
      if fichiers[k].typeDonnees=kFicIndexPartiesNouveauFormat then
        begin  {on cherche le fichier de parties correspondant a cet index}
          found := false;
          numFichier := 1;
          repeat
            if (numFichier <= nbFichiers) & (numFichier <> k) &
               (fichiers[numFichier].typeDonnees = kFicPartiesNouveauFormat) &
               (fichiers[numFichier].parID       = fichiers[k].parID) &
               (fichiers[numFichier].vRefNum     = fichiers[k].vRefNum) &
               (fichiers[numFichier].annee       = fichiers[k].annee) &
               (EntetesEgauxNouveauFormat(fichiers[k].entete,fichiers[numFichier].entete)) then
                 begin
		               found := true;
		               fichiers[numFichier].NroFichierDual := k;
		               fichiers[k         ].NroFichierDual := numFichier;
		             end;
		        numFichier := succ(numFichier);
          until found | (numFichier>nbFichiers);
        end;
end;


function OrdreAlphabetiqueSurJoueurs(n1,n2 : SInt32) : boolean;
var s1,s2 : str255;
begin
  s1 := GetNomJoueur(n1);
  s2 := GetNomJoueur(n2);
  UpperString(s1,false);
  UpperString(s2,false);
  OrdreAlphabetiqueSurJoueurs := s1>=s2 ;
end;


procedure TrierAlphabetiquementJoueursNouveauFormat;
var k : SInt32;
    permutation : LongintArrayPtr;  
begin 
  with JoueursNouveauFormat do
    if nbJoueursNouveauFormat > 0 then
      begin
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant "if LitFichierIndexDesJoueursTries(false)=NoErr…" dans TrierAlphabetiquementJoueursNouveauFormat',true);
        if LitFichierIndexDesJoueursTries(false)=NoErr 
          then
            begin
              dejaTriesAlphabetiquement := true;
            end
          else
            begin
              permutation := LongintArrayPtr(AllocateMemoryPtr((nbMaxJoueursEnMemoire+2)*sizeof(SInt32)));
			        if permutation = NIL
			          then SysBeep(0)
			          else
			            begin
			              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant GeneralQuickSort dans TrierAlphabetiquementJoueursNouveauFormat',true);
			              GeneralQuickSort(0,nbJoueursNouveauFormat-1,GetNroOrdreAlphabetiqueJoueur,SetNroOrdreAlphabetiqueJoueur,OrdreAlphabetiqueSurJoueurs); 
                    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Apres GeneralQuickSort dans TrierAlphabetiquementJoueursNouveauFormat',true);
                    {on inverse la permutation}
			              for k := 0 to nbJoueursNouveauFormat-1 do permutation^[GetNroOrdreAlphabetiqueJoueur(k)] := k;
			              for k := 0 to nbJoueursNouveauFormat-1 do SetNroOrdreAlphabetiqueJoueur(k,permutation^[k]);
			              dejaTriesAlphabetiquement := true;
			              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant "if EcritFichierIndexDesJoueursTries(false)=NoErr" dans TrierAlphabetiquementJoueursNouveauFormat',true);
			              if EcritFichierIndexDesJoueursTries(false)=NoErr then;
			            end;
			        if permutation <> NIL then DisposeMemoryPtr(Ptr(permutation));
            end;
      end;
end;



function OrdreAlphabetiqueSurTournois(n1,n2 : SInt32) : boolean;
var s1,s2 : str255;
begin
  s1 := GetNomTournoi(n1);
  s2 := GetNomTournoi(n2);
  UpperString(s1,false);
  UpperString(s2,false);
  OrdreAlphabetiqueSurTournois := s1>=s2 ;
end;
  

procedure TrierAlphabetiquementTournoisNouveauFormat;
var k : SInt32;
    permutation : LongintArrayPtr;  
begin 
  with TournoisNouveauFormat do
    if nbTournoisNouveauFormat>0 then
      begin
        if (LitFichierIndexDesTournoisTries(false)=NoErr) 
          then
            begin
              dejaTriesAlphabetiquement := true;
            end
          else
            begin
              permutation := LongintArrayPtr(AllocateMemoryPtr((nbMaxTournoisEnMemoire+2)*sizeof(SInt32)));
			        if permutation = NIL
			          then SysBeep(0)
			          else
			            begin
                    GeneralQuickSort(0,nbTournoisNouveauFormat-1,GetNroOrdreAlphabetiqueTournoi,SetNroOrdreAlphabetiqueTournoi,OrdreAlphabetiqueSurTournois);
                    {on inverse la permutation}
			              for k := 0 to nbTournoisNouveauFormat-1 do permutation^[GetNroOrdreAlphabetiqueTournoi(k)] := k;
			              for k := 0 to nbTournoisNouveauFormat-1 do SetNroOrdreAlphabetiqueTournoi(k,permutation^[k]);
			              dejaTriesAlphabetiquement := true;
			              if EcritFichierIndexDesTournoisTries(false)=NoErr then;
			            end;
			        if permutation <> NIL then DisposeMemoryPtr(Ptr(permutation));
            end;
      end;
end;
  
  
procedure GetDistributionsALireFromPrefsFile;
var err : OSErr;
    s,motClef,bidStr,chainePref : str255;
    k : SInt16; 
begin
  with ChoixDistributions,DistributionsNouveauFormat do
    if OpenPrefsFileForSequentialReading() = NoErr then    
	    begin
	      genre := kToutesLesDistributions;
	      DistributionsALire := [];
	      
	      while not(EOFInPrefsFile()) do
	        begin
	          err := GetNextLineInPrefsFile(s);
	          if err = NoErr then
	            begin
	              Parser2(s,motClef,bidStr,chainePref);
	              if motClef='%quellesBasesLire' then
	                begin
	                  if chainePref='ToutesLesDistributions' then genre := kToutesLesDistributions else
	                  if chainePref='QuelquesDistributions'  then genre := kQuelquesDistributions else
	                  if chainePref='AucuneDistribution'     then genre := kAucuneDistribution;
	                end;
	              if motClef='%baseActive' then
	                begin
	                  chainePref := ReplaceStringByStringInString('$CASSIO_FOLDER:',pathCassioFolder,chainePref);
	                  for k := 1 to nbDistributions do
	                    if (Distribution[k].path <> NIL) & (Distribution[k].name <> NIL) & 
	                       (chainePref = Distribution[k].path^+Distribution[k].name^) then
	                       DistributionsALire := DistributionsALire+[k];
	                  end;
	            end;
	        end;
	      err := ClosePrefsFile();
	    end;
end;

procedure LecturePreparatoireDossierDatabase(vRefNum : SInt16);
var trouve : boolean;
    k : SInt16; 
begin {$UNUSED k}
  if not(Quitter | gPendantLesInitialisationsDeCassio) then
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
    end;
  
  ChercheFichiersNouveauFormatDansDossier(vRefNum,'Database',trouve);
  if not(trouve) then ChercheFichiersNouveauFormatDansDossier(vRefNum,'Database ',trouve);
  if not(trouve) then ChercheFichiersNouveauFormatDansDossier(vRefNum,'Database (alias)',trouve);
  TrierListeFichiersNouveauFormat;
  EtablitLiaisonEntrePartiesEtIndexNouveauFormat;
  GetDistributionsALireFromPrefsFile;
  ReparerFichiersSolitaires;
  
  AjusteCurseur;
  {WritelnStringAndNumDansRapport('nb distrib =',DistributionsNouveauFormat.nbDistributions);
  for k := 1 to DistributionsNouveauFormat.nbDistributions do
    WritelnDansRapport('nomUsuel = '+DistributionsNouveauFormat.distribution[k].nomUsuel^);}
end;


end.