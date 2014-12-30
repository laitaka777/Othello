UNIT UnitStatistiqueDeSolitaire;



INTERFACE







USES UnitOth0,UnitFichiersTEXT;

procedure InitStatistiquesDeDifficultePourFforum;
procedure LibereMemoireStatistiquesDeDifficultePourFforum;
procedure ViderStatistiquesDeDifficultePourFforum;
procedure EcritureStatistiquesDeDifficultePourFforum(var fic : FichierTEXT);
procedure AjouterStatistiquesDeDifficultePourFforum(nroLigne,score : SInt32);
function DifficulteDuSolitaire() : extended;

IMPLEMENTATION







USES SNStrings,MyMathUtils,UnitServicesMemoire,TextUtils;



const kMAXTailleTableDesScores = 10000;
type tableDesScoresDansFforum = packed array[0..kMAXTailleTableDesScores] of signedByte;
     tableDesScoresDansFforumPtr = ^tableDesScoresDansFforum;
var scoresDansFforum : tableDesScoresDansFforumPtr;



procedure InitStatistiquesDeDifficultePourFforum;
begin
  scoresDansFforum := NIL;
  scoresDansFforum := tableDesScoresDansFforumPtr(AllocateMemoryPtr(sizeof(tableDesScoresDansFforum)));
  
  ViderStatistiquesDeDifficultePourFforum;
end;

procedure LibereMemoireStatistiquesDeDifficultePourFforum;
begin
  if (scoresDansFforum <> NIL) then DisposeMemoryPtr(Ptr(scoresDansFforum));
  scoresDansFforum := NIL;
end;

procedure ViderStatistiquesDeDifficultePourFforum;
var i : SInt32;
begin
  if (scoresDansFforum <> NIL) then
    for i := 0 to kMAXTailleTableDesScores do
      scoresDansFforum^[i] := -1;
end;

function DifficulteDuSolitaire() : extended;
var nbOccurencesDeCeScore : array[0..64] of SInt32;
    i,n,nbLignesTotal,nbPionsTotal,scoreDuSolitaire : SInt32;
    nbPionsLignesInteressantes,nbLignesIntegrees,nbLignesInteressantes : SInt32;
    difficulte : extended;
begin
  difficulte := 0.0;
  
  if (scoresDansFforum <> NIL) then
    begin

		  for i := 0 to 64 do 
		    nbOccurencesDeCeScore[i] := 0;
		  nbLignesTotal := 0;
		  nbPionsTotal := 0;
		  
		  for i := 0 to kMAXTailleTableDesScores do
		    if scoresDansFforum^[i] >= 0 then
		      begin
		        n := scoresDansFforum^[i];
		        inc(nbOccurencesDeCeScore[n]);
		        inc(nbLignesTotal);
		        nbPionsTotal := nbPionsTotal + n;
		      end;
		  
		  scoreDuSolitaire := 0;
		  for i := 64 downto 0 do
		    if (nbOccurencesDeCeScore[i] > 0) & (scoreDuSolitaire = 0) 
		      then scoreDuSolitaire := i;
		  
		  {on s'interesse aux meilleures lignes (les 25% meilleures)}
		  nbLignesInteressantes := Max(25,nbLignesTotal div 4);
		  nbPionsLignesInteressantes := 0;
		  nbLignesIntegrees := 0;
		  for n := 64 downto 0 do
		    if (nbOccurencesDeCeScore[n] > 0) & (n <> scoreDuSolitaire) then
		      if (nbLignesIntegrees < nbLignesInteressantes) then
		      begin
		        nbPionsLignesInteressantes := nbPionsLignesInteressantes + n*nbOccurencesDeCeScore[n];
		        nbLignesIntegrees := nbLignesIntegrees + nbOccurencesDeCeScore[n];
		      end;
		  
		  if (nbLignesIntegrees <> 0) & ((scoreDuSolitaire -1) <> 0) then
		    begin
				  difficulte := 1.0*nbPionsLignesInteressantes/(1.0*nbLignesIntegrees*(scoreDuSolitaire-1));
				  difficulte := difficulte + 0.08;
				  difficulte := difficulte*difficulte*difficulte;
				  if difficulte > 1.0 then difficulte := 1.0;
				end;
		      
		end;

  DifficulteDuSolitaire := 100.0*difficulte;
end;

procedure EcritureStatistiquesDeDifficultePourFforum(var fic : FichierTEXT);
var nbOccurencesDeCeScore : array[0..64] of SInt32;
    i,n,nbLignesTotal,nbPionsTotal,scoreDuSolitaire : SInt32;
    erreurES : OSErr;
    s : str255;
    difficulte : extended;
begin
  if (scoresDansFforum <> NIL) then
    begin

		  for i := 0 to 64 do 
		    nbOccurencesDeCeScore[i] := 0;
		  nbLignesTotal := 0;
		  nbPionsTotal := 0;
		  
		  for i := 0 to kMAXTailleTableDesScores do
		    if scoresDansFforum^[i] >= 0 then
		      begin
		        n := scoresDansFforum^[i];
		        inc(nbOccurencesDeCeScore[n]);
		        inc(nbLignesTotal);
		        nbPionsTotal := nbPionsTotal + n;
		      end;
		  
		  scoreDuSolitaire := 0;
		  for i := 64 downto 0 do
		    if (nbOccurencesDeCeScore[i] > 0) & (scoreDuSolitaire = 0) 
		      then scoreDuSolitaire := i;
		      
		  difficulte := DifficulteDuSolitaire();
		  
		  
		  erreurES := WritelnDansFichierTexte(fic,'');
		  (*
		  GetIndString(s,TextesSolitairesID,31); {Difficulté du solitaire : ^0 %}
			s := ParamStr(s,ReelEnStringAvecDecimales(difficulte,3),'','','');
			erreurES := WritelnDansFichierTexte(fic,s);
			*)
				
		  GetIndString(s,TextesSolitairesID,18); {Ce solitaire fait ^0 lignes, avec une difficulté de ^1 %.}
		  s := ParamStr(s,NumEnString(nbLignesTotal),ReelEnStringAvecDecimales(difficulte,3),'','');
		  erreurES := WritelnDansFichierTexte(fic,s);
		  
		  {s := 'scoreDuSolitaire = ^0';
		  s := ParamStr(s,NumEnString(scoreDuSolitaire),'','','');
		  erreurES := WritelnDansFichierTexte(fic,s);
		  
		  s := 'nbPionsTotal = ^0';
		  s := ParamStr(s,NumEnString(nbPionsTotal),'','','');
		  erreurES := WritelnDansFichierTexte(fic,s);}
		      
		  for i := 64 downto 0 do
		    if nbOccurencesDeCeScore[i] > 0 then
		      begin
		        if nbOccurencesDeCeScore[i] >= 2
		          then GetIndString(s,TextesSolitairesID,30) {Il y a ^0 façons de faire ^1 pions}
		          else GetIndString(s,TextesSolitairesID,29); {Il y a ^0 façon  de faire ^1 pions}
		        s := ParamStr(s,NumEnString(nbOccurencesDeCeScore[i]),NumEnString(i),'','');
		        erreurES := WritelnDansFichierTexte(fic,s);
		      end;
		end;
end;

procedure AjouterStatistiquesDeDifficultePourFforum(nroLigne,score : SInt32);
begin
  if (scoresDansFforum <> NIL) then
    if (nroLigne >= 1) & (nroLigne < kMAXTailleTableDesScores) then
      scoresDansFforum^[nroLigne] := score;
end;


END.