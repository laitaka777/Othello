UNIT UnitMoveRecords;



INTERFACE







USES UnitOth0;


const ProfMaxDansTableOfMoveRecordsLists=50;

type ListOfMoveRecordsPtr = ^ListOfMoveRecords;
     ListOfMoveRecordsHdl = ^ListOfMoveRecordsPtr;


var tableOfMoveRecordsLists : 
       array[0..ProfMaxDansTableOfMoveRecordsLists] of 
         record
           list:ListOfMoveRecordsHdl;
           cardinal : SInt16; 
           utilisee : boolean;
         end;

procedure InitUnitMoveRecords;
procedure LibereMemoireUnitMoveRecords;

{procedures de manipulation de MoveRecord}
procedure ViderMoveRecord(var whichMoveRecord : MoveRecord);

{procedures de creation et de copies de ListOfMoveRecords}
function AllocateListOfMoveRecordsHandle(var liste:ListOfMoveRecordsHdl) : boolean;
procedure CopyListOMoveRecords(var source,dest : ListOfMoveRecords);
procedure DisposeListOfMoveRecordsHandle(var liste:ListOfMoveRecordsHdl);
procedure ViderListOfMoveRecords(var liste : ListOfMoveRecords);


{procedure d'acces ˆ la liste des coups de la fenetre "Reflexion"}
procedure SetValReflex(var classAux : ListOfMoveRecords;profondeur,compt,longueurclass,genre,numero,IndexEnCours,couleur : SInt16);
procedure SetValReflexFinale(var classAux : ListOfMoveRecords;profondeur,compt,longueurclass,genre,numero,IndexEnCours,couleur : SInt16);
procedure SetNroLigneEnCoursDAnalyseDansReflex(nroLigne : SInt32);
procedure SetCoupEtScoreAnalyseRetrogradeDansReflex(coup,score : SInt32);
function EstLaListeDesCoupsDeFenetreReflexion(var whichList : ListOfMoveRecords) : boolean;

{procedure d'acces et d'ecriture dans la tableOfMoveRecordsLists}
procedure CopyClassementDansTableOfMoveRecordsLists(var classement : ListOfMoveRecords;quelleProf,longClass : SInt16);
procedure InvalidateCetteProfDansTableOfMoveRecordsLists(quelleProf : SInt16);
procedure InvalidateAllProfsDansDansTableOfMoveRecordsLists;
procedure HLockAllProfsDansDansTableOfMoveRecordsLists;
procedure HUnlockAllProfsDansDansTableOfMoveRecordsLists;



IMPLEMENTATION







USES UnitRapport,UnitOth1,UnitServicesMemoire;





procedure InitUnitMoveRecords;
var i : SInt16; 
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    begin
      tableOfMoveRecordsLists[i].list := NIL;
      tableOfMoveRecordsLists[i].cardinal := 0;
      tableOfMoveRecordsLists[i].utilisee := false;
    end;
end;

procedure LibereMemoireUnitMoveRecords;
var i : SInt16; 
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    begin
      DisposeListOfMoveRecordsHandle(tableOfMoveRecordsLists[i].list);
      tableOfMoveRecordsLists[i].cardinal := 0;
      tableOfMoveRecordsLists[i].utilisee := false;
    end;
end;

procedure ViderMoveRecord(var whichMoveRecord : MoveRecord);
begin
  with whichMoveRecord do
    begin
      x := 0;
      theDefense := 0;
      note := 0;
      pourcentageCertitude := 0;
      temps := 0;
      nbfeuilles := 0;
      notePourLeTri := 0;
      noteMilieuDePartie := 0;
      delta := 0;
    end;
end;

function AllocateListOfMoveRecordsHandle(var liste:ListOfMoveRecordsHdl) : boolean;
begin
  liste := NIL;
  liste := ListOfMoveRecordsHdl(AllocateMemoryHdl(20+Sizeof(ListOfMoveRecords)));
  AllocateListOfMoveRecordsHandle := (liste <> NIL);
end;

procedure CopyListOMoveRecords(var source,dest : ListOfMoveRecords);
var i : SInt16; 
begin
  for i := 1 to 64 do
    dest[i] := source[i];
end;


procedure DisposeListOfMoveRecordsHandle(var liste:ListOfMoveRecordsHdl);
begin
  if liste <> NIL then
    begin
      DisposeMemoryHdl(Handle(liste));
      liste := NIL;
    end;
end;

procedure ViderListOfMoveRecords(var liste : ListOfMoveRecords);
var i : SInt16; 
begin
  for i := 1 to 64 do
    ViderMoveRecord(liste[i]);
end;

procedure SetCoupEtScoreAnalyseRetrogradeDansReflex(coup,score : SInt32);
begin
  ReflexData^.coupAnalyseRetrograde := coup;
  ReflexData^.scoreAnalyseRetrograde := score;
end;

procedure SetValReflex(var classAux : ListOfMoveRecords;profondeur,compt,longueurclass,genre,numero,IndexEnCours,couleur : SInt16);
var i,penaliteAjoutee : SInt16; 
begin
  if odd(profondeur+1)
    then penaliteAjoutee := penalitePourTraitAff
    else penaliteAjoutee := -penalitePourTraitAff;
  for i := 1 to compt do ReflexData^.class[i] := classAux[i];
  for i := 1 to compt do 
    begin
      ReflexData^.class[i].note := ReflexData^.class[i].note+penaliteAjoutee;
      if ReflexData^.class[i].note = -1
        then ReflexData^.class[i].note := -2;
      ReflexData^.class[i].pourcentageCertitude := 100;
      ReflexData^.class[i].delta := kTypeMilieuDePartie;
    end;
  ReflexData^.prof := profondeur;
  ReflexData^.compteur := compt;
  ReflexData^.longClass := longueurclass;
  ReflexData^.typeDonnees := genre;
  ReflexData^.numeroDuCoup := numero;
  ReflexData^.couleur := couleur;
  ReflexData^.IndexCoupEnCours := IndexEnCours;
  if (IndexEnCours>=1) & (IndexEnCours<=longueurclass) then 
    begin
      ReflexData^.class[IndexEnCours] := classAux[IndexEnCours];
      ReflexData^.class[IndexEnCours].note := ReflexData^.class[IndexEnCours].note+penaliteAjoutee;
      if ReflexData^.class[IndexEnCours].note = -1
        then ReflexData^.class[IndexEnCours].note := -2;
    end;
  SetCoupEtScoreAnalyseRetrogradeDansReflex(0,0);
end;

procedure SetValReflexFinale(var classAux : ListOfMoveRecords;profondeur,compt,longueurclass,genre,numero,IndexEnCours,couleur : SInt16);
var i : SInt16; 
begin
  for i := 1 to compt do ReflexData^.class[i] := classAux[i];
  ReflexData^.prof := profondeur;
  ReflexData^.compteur := compt;
  ReflexData^.longClass := longueurclass;
  ReflexData^.typeDonnees := genre;
  ReflexData^.numeroDuCoup := numero;
  ReflexData^.couleur := couleur;
  ReflexData^.IndexCoupEnCours := IndexEnCours;
  if (IndexEnCours>=1) & (IndexEnCours<=longueurclass) then
    ReflexData^.class[IndexEnCours] := classAux[IndexEnCours];
end;


procedure SetNroLigneEnCoursDAnalyseDansReflex(nroLigne : SInt32);
begin
  if (nroLigne >= 1) & (nroLigne <= ReflexData^.longClass) then
    ReflexData^.IndexCoupEnCours := nroLigne;
end;

function EstLaListeDesCoupsDeFenetreReflexion(var whichList : ListOfMoveRecords) : boolean;
begin
  EstLaListeDesCoupsDeFenetreReflexion := (@whichList = @ReflexData^.class);
end;


procedure CopyClassementDansTableOfMoveRecordsLists(var classement : ListOfMoveRecords;quelleProf,longClass : SInt16);
begin

  {
  WritelnStringAndNumDansRapport('dans CopyClassementDansTableOfMoveRecordsLists : quelleProf=',quelleProf);
  WritelnStringAndNumDansRapport('dans CopyClassementDansTableOfMoveRecordsLists : longClass=',longClass);
  }

  if (quelleProf>=0) & (quelleProf<=ProfMaxDansTableOfMoveRecordsLists) then
    begin
      if tableOfMoveRecordsLists[quelleProf].list = NIL then
        begin
          if AllocateListOfMoveRecordsHandle(tableOfMoveRecordsLists[quelleProf].list) &
             (tableOfMoveRecordsLists[quelleProf].list <> NIL) then
            begin
              HLock(Handle(tableOfMoveRecordsLists[quelleProf].list));
              ViderListOfMoveRecords(tableOfMoveRecordsLists[quelleProf].list^^);
              HUnlock(Handle(tableOfMoveRecordsLists[quelleProf].list));
            end;
        end;
        
      if (tableOfMoveRecordsLists[quelleProf].list <> NIL) & (longClass>0)
        then
	      begin
	        HLock(Handle(tableOfMoveRecordsLists[quelleProf].list));
	        CopyListOMoveRecords(classement,tableOfMoveRecordsLists[quelleProf].list^^);
	        
	        
	        tableOfMoveRecordsLists[quelleProf].utilisee := true;
	        tableOfMoveRecordsLists[quelleProf].cardinal := longClass;
		        
		    {
            WritelnStringAndNumDansRapport('tableOfMoveRecordsLists pour la prof : ',quelleProf);
            WritelnStringAndNumDansRapport('cardinal= ',longClass);
            for i := 1 to longClass do
              with tableOfMoveRecordsLists[quelleProf].list^^[i] do
                begin
                  WritelnStringAndNumDansRapport(CoupEnStringEnMajuscules(x)+'==>',note);
                end;
            WritelnDansRapport('');
            }
		        
	        HUnlock(Handle(tableOfMoveRecordsLists[quelleProf].list));
	      end
	    else
	      begin
	        tableOfMoveRecordsLists[quelleProf].utilisee := false;
	        tableOfMoveRecordsLists[quelleProf].cardinal := 0;
	      end;
    end;
end;


procedure InvalidateCetteProfDansTableOfMoveRecordsLists(quelleProf : SInt16);
begin
  if (quelleProf>=0) & (quelleProf<=ProfMaxDansTableOfMoveRecordsLists) then
    begin
      tableOfMoveRecordsLists[quelleProf].utilisee := false;
	  tableOfMoveRecordsLists[quelleProf].cardinal := 0;
    end;
end;

procedure InvalidateAllProfsDansDansTableOfMoveRecordsLists;
var i : SInt16; 
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    InvalidateCetteProfDansTableOfMoveRecordsLists(i);
end;

procedure HLockAllProfsDansDansTableOfMoveRecordsLists;
var i : SInt16; 
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    if tableOfMoveRecordsLists[i].list <> NIL then
      HLock(Handle(tableOfMoveRecordsLists[i].list));
end;


procedure HUnlockAllProfsDansDansTableOfMoveRecordsLists;
var i : SInt16; 
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    if tableOfMoveRecordsLists[i].list <> NIL then
      HUnlock(Handle(tableOfMoveRecordsLists[i].list));
end;





END.