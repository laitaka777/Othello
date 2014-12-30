UNIT UnitHashTableExacte;


{$DEFINEC USE_DEBUG_STEP_BY_STEP    FALSE}
{$DEFINEC USE_VERIFICATION_ASSERTIONS_BORNES    FALSE}


INTERFACE







USES UnitOth0,UnitPositionEtTrait,UnitPositionEtTraitSet;


type  DecompressionHashExacteRec = 
             record
               valMin               : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
               valMax               : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
               nbArbresCoupesValMin : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
               nbArbresCoupesValMax : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
               coupDeCetteValMin    : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
             end;

type codePositionRec =
                 record
                   platLigne1,platLigne2,platLigne3,platLigne4 : SInt32;
                   platLigne5,platLigne6,platLigne7,platLigne8 : SInt32;
                   couleurCodage : SInt32;
                   nbreVidesCodage : SInt32;
                 end;

{initialisation et destruction de l'unite}
procedure InitUnitHashTableExacte;
procedure LibereMemoireUnitHashTableExacte;


{vidage}
procedure VideHashTableExacte(whichHashTableExacte:HashTableExactePtr);
procedure VideHashTableCoupsLegaux(whichHashTableCoupsLegaux:CoupsLegauxHashPtr);
procedure VideToutesLesHashTablesExactes;
procedure VideToutesLesHashTablesCoupsLegaux;
{procedure DetruitEntreesIncorrectesHashTableCoupsLegaux;}


{fonctions d'acces a la table de hachage exacte}
procedure SetTraitDansHashExacte(trait : SInt32; var cellule:HashTableExacteElement);
procedure SetBestDefenseDansHashExacte(bestDefense : SInt32; var cellule:HashTableExacteElement);
function GetTraitDansHashExacte(var cellule:HashTableExacteElement) : SInt32;
function GetBestDefenseDansHashExacte(var cellule:HashTableExacteElement) : SInt32;
procedure GetEndgameValuesInHashTableElement(var cellule:HashTableExacteElement;whichDeltaFinal : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32);


{utilisation en milieu de partie}
procedure SetValMinEtMaxDeMilieu(whichValeurMin,whichValeurMax : SInt16; var cellule:HashTableExacteElement);
procedure GetValMinEtMaxDeMilieu(var whichValeurMin,whichValeurMax : SInt16; var cellule:HashTableExacteElement);


{utilisation en finale}
procedure CreeCodagePosition(var plat:plOthEndgame;couleur,prof : SInt32; var codagePosition:codePositionRec);
procedure WritelnCodagePositionDansRapport(codagePosition:codePositionRec);
procedure ExpandHashTableExacte(var whichElement:HashTableExacteElement;
                                var whichLegalMoves:CoupsLegauxHashPtr;
                                var codagePosition:codePositionRec;
                                clefHashExacte : SInt32);
function InfoTrouveeDansHashTableExacte(var codagePosition:codePositionRec; var quelleHashTableExacte:HashTableExactePtr;clefHashage : SInt32; var whichClefExacte : SInt32) : boolean;
function MeilleurCoupEstStockeDansLesBornes(const bornes:DecompressionHashExacteRec; var meilleurCoup,valeurDeLaPosition : SInt32) : boolean;


procedure AugmentationMinorant(newValeurMin,newDeltaMin,coup,couleur : SInt32; var bornes:DecompressionHashExacteRec; var plat : plateauOthello;fonctionAppelante : str255);
procedure DiminutionMajorant(newValeurMax,newDeltaMax,couleur : SInt32; var bornes:DecompressionHashExacteRec; var plat : plateauOthello;fonctionAppelante : str255);
procedure EnleverBornesMinPeuSuresDesAutresCoups(whichLegalMoves:CoupsLegauxHashPtr;clefHashExacte,couleur : SInt32; var bornes:DecompressionHashExacteRec; var plat : plateauOthello);
procedure DecompresserBornesHashTableExacte(var whichElement:HashTableExacteElement; var bornes:DecompressionHashExacteRec);
procedure CompresserBornesDansHashTableExacte(var whichElement:HashTableExacteElement; var bornes:DecompressionHashExacteRec);
procedure WritelnBornesDansRapport(var bornes:DecompressionHashExacteRec);
procedure PutEndgameValuesInHashExacte(clefHash,nbVides : SInt32;jeu : PositionEtTraitRec;valMin,valMax,meilleurCoup : SInt32);



function GetEndgameValuesInHashTableAtThisHashKey(plat : PositionEtTraitRec; hashKey,deltaFinale : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32) : boolean;
function GetEndgameValuesInHashTableFromThisNode(plat : PositionEtTraitRec;G : GameTree; deltaFinale : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32) : boolean;
function GetEndgameBornesInHashTableAtThisHashKey(plat : PositionEtTraitRec; hashKey : SInt32; var bornes : DecompressionHashExacteRec) : boolean;
function GetEndgameBornesDansHashExacteAfterThisSon(coup : SInt32; platDepart : PositionEtTraitRec; clefHashage : SInt32; var bornes : DecompressionHashExacteRec) : boolean;
function ScoreFinalEstConfirmeParValeursHashExacte(genreReflexion,scoreDeNoir,vMinPourNoir,vMaxPourNoir : SInt32) : boolean;



{statistiques}
function TauxDeRemplissageHashExacte(nroTable : SInt32;ecritStatsDetaillees : boolean) : extended;


{$IFC USE_DEBUG_STEP_BY_STEP}
procedure AjouterPositionsDevantEtreDebugueesPasAPas(var positionsCherchees:PositionEtTraitSet);
{$ENDC}                 


{$IFC USE_DEBUG_STEP_BY_STEP}
var gDebuggageAlgoFinaleStepByStep :
       record
         actif : boolean;
         profMin : SInt32;
         positionsCherchees:PositionEtTraitSet;
       end;
    dummyLong : SInt32;
{$ENDC}


IMPLEMENTATION







USES UnitRapport,UnitNewGeneral,UnitVariablesGlobalesFinale,UnitEndgameTree,UnitSquareSet,UnitGestionDuTemps,SNStrings;




procedure InitUnitHashTableExacte;
begin
  if CassioEnEnvironnementMemoireLimite()
    then
      begin
        nbTablesHashExactes := 2;  { doit etre une puissance de 2 }
		    nbTablesHashExactesMoins1 := 1;
      end
    else
      begin
		    nbTablesHashExactes := 64;  { doit etre une puissance de 2 }
		    nbTablesHashExactesMoins1 := 63;
	  end
end;

procedure LibereMemoireUnitHashTableExacte;
begin
end;

procedure VideHashTableExacte(whichHashTableExacte:HashTableExactePtr);
var i,count : SInt32;
begin
  if whichHashTableExacte <> NIL 
    then
  	  begin
        count := sizeof(whichHashTableExacte^[1]);
        for i := 0 to 1023 do
          MemoryFillChar(@whichHashTableExacte^[i],count,chr(0));
	    end
    else
	    begin
		    SysBeep(0);
		    WritelnDansRapport('ERREUR : whichHashTableExacte = NIL dans VideHashTableExacte !');
      end;
end;

procedure VideHashTableCoupsLegaux(whichHashTableCoupsLegaux:CoupsLegauxHashPtr);
begin
  if whichHashTableCoupsLegaux <> NIL
    then
      MemoryFillChar(whichHashTableCoupsLegaux,sizeof(whichHashTableCoupsLegaux^),chr(0))
    else
		  begin
		    SysBeep(0);
		    WritelnDansRapport('ERREUR : whichHashTableCoupsLegaux = NIL dans VideHashTableCoupsLegaux !');
		  end;
end;

procedure VideToutesLesHashTablesExactes;
var i : SInt32;
begin
  if not(Quitter) then
    begin
      {WritelnDansRapport('je suis dans VideToutesLesHashTablesExactes…');}
		  for i := 0 to nbTablesHashExactes-1 do
		    VideHashTableExacte(HashTableExacte[i]);
		  VideToutesLesHashTablesCoupsLegaux;
		  nbCollisionsHashTableExactes := 0;
		  nbNouvellesEntreesHashTableExactes := 0;
		  nbPositionsRetrouveesHashTableExactes := 0;
		end;
end;


procedure VideToutesLesHashTablesCoupsLegaux;
var i : SInt32;
begin
  if not(Quitter) then
    for i := 0 to nbTablesHashExactes-1 do
      VideHashTableCoupsLegaux(CoupsLegauxHash[i]);
end;

(*
procedure DetruitEntreesIncorrectesHashTableCoupsLegaux;
var i,k : SInt32;
    whichHashTableCoupsLegaux:CoupsLegauxHashPtr;
    whichHashTableExacte:HashTableExactePtr;
begin
  for i := 0 to nbTablesHashExactes-1 do
    begin
      whichHashTableExacte := HashTableExacte[i];
      whichHashTableCoupsLegaux := CoupsLegauxHash[i];
      if (whichHashTableExacte <> NIL) & (whichHashTableCoupsLegaux <> NIL) then
        begin
          for k := 0 to 1023 do
            begin
              with whichHashTableExacte^[k] do
              if BAND(flags,kMaskRecalculerCoupsLegaux) <> 0 then
                begin
                  whichHashTableCoupsLegaux^[k,0] := 0;    {on fait comme si on n'avait pas calcule les coups legaux de cette position}
                  flags := BAND(flags,BNOT(kMaskRecalculerCoupsLegaux));
                end;
            end;
        end;
    end;
end;
*)

procedure SetTraitDansHashExacte(trait : SInt32; var cellule:HashTableExacteElement);
begin
  case trait of
    pionNoir  : cellule.traitEtBestDefense[0] := 1;
    pionBlanc : cellule.traitEtBestDefense[0] := 2;
    otherwise   cellule.traitEtBestDefense[0] := 0;
  end;
end;


function GetTraitDansHashExacte(var cellule:HashTableExacteElement) : SInt32;
begin
  case cellule.traitEtBestDefense[0] of
    1 :        GetTraitDansHashExacte := pionNoir;
    2 :        GetTraitDansHashExacte := pionBlanc;
    otherwise  GetTraitDansHashExacte := pionVide;
  end;
end;

procedure SetBestDefenseDansHashExacte(bestDefense : SInt32; var cellule:HashTableExacteElement);
begin
  cellule.traitEtBestDefense[1] := bestDefense;
end;


function GetBestDefenseDansHashExacte(var cellule:HashTableExacteElement) : SInt32;
begin
  GetBestDefenseDansHashExacte := cellule.traitEtBestDefense[1];
end;



procedure GetEndgameValuesInHashTableElement(var cellule:HashTableExacteElement;whichDeltaFinal : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32);
var bornes:DecompressionHashExacteRec;
    k,vMin,vMax : SInt32;
begin
  DecompresserBornesHashTableExacte(cellule,bornes);
  k := IndexOfThisDelta(whichDeltaFinal);
  vMin := bornes.valMin[k];
  vMax := bornes.valMax[k];
  if GetTraitDansHashExacte(cellule) = pionNoir
    then
      begin
        valMinPourNoir := vMin;
        valMaxPourNoir := vMax;
      end
    else
      begin
        valMinPourNoir := -vMax;
        valMaxPourNoir := -vMin;
      end;
end;



procedure SetValMinEtMaxDeMilieu(whichValeurMin,whichValeurMax : SInt16; var cellule:HashTableExacteElement);
begin
  with cellule do
    begin
      {ValeurMin := whichValeurMin;
      ValeurMax := whichValeurMax;}
      
      MoveMemory(@whichValeurMin,@cellule.bornesMin[1],sizeof(whichValeurMin));
      MoveMemory(@whichValeurMax,@cellule.bornesMax[1],sizeof(whichValeurMax));
      
    end;
end;

procedure GetValMinEtMaxDeMilieu(var whichValeurMin,whichValeurMax : SInt16; var cellule:HashTableExacteElement);
begin
  with cellule do
    begin
      {whichValeurMin := ValeurMin;
      whichValeurMax := ValeurMax;}
      
      MoveMemory(@cellule.bornesMin[1],@whichValeurMin,sizeof(whichValeurMin));
      MoveMemory(@cellule.bornesMax[1],@whichValeurMax,sizeof(whichValeurMax));
      
    end;
end;

procedure WritelnCodagePositionDansRapport(codagePosition:codePositionRec);
begin
  with codagePosition do
    begin
		  WritelnStringAndNumDansRapport('l1 = ',platLigne1);
		  WritelnStringAndNumDansRapport('l2 = ',platLigne2);
		  WritelnStringAndNumDansRapport('l3 = ',platLigne3);
		  WritelnStringAndNumDansRapport('l4 = ',platLigne4);
		  WritelnStringAndNumDansRapport('l5 = ',platLigne5);
		  WritelnStringAndNumDansRapport('l6 = ',platLigne6);
		  WritelnStringAndNumDansRapport('l7 = ',platLigne7);
		  WritelnStringAndNumDansRapport('l8 = ',platLigne8);
		  WritelnStringAndNumDansRapport('couleurCodage = ',couleurCodage);
		  WritelnStringAndNumDansRapport('nbreVidesCodage = ',nbreVidesCodage);
		end;
end;


procedure CreeCodagePosition(var plat:plOthEndgame;couleur,prof : SInt32; var codagePosition:codePositionRec);
  begin
    with codagePosition do
      begin
        platLigne1 := codage_c1[plat[11]]+codage_c2[plat[12]]+codage_c3[plat[13]]+codage_c4[plat[14]]+
                      codage_c5[plat[15]]+codage_c6[plat[16]]+codage_c7[plat[17]]+codage_c8[plat[18]];
        platLigne2 := codage_c1[plat[21]]+codage_c2[plat[22]]+codage_c3[plat[23]]+codage_c4[plat[24]]+
                      codage_c5[plat[25]]+codage_c6[plat[26]]+codage_c7[plat[27]]+codage_c8[plat[28]];      
        platLigne3 := codage_c1[plat[31]]+codage_c2[plat[32]]+codage_c3[plat[33]]+codage_c4[plat[34]]+
                      codage_c5[plat[35]]+codage_c6[plat[36]]+codage_c7[plat[37]]+codage_c8[plat[38]];
        platLigne4 := codage_c1[plat[41]]+codage_c2[plat[42]]+codage_c3[plat[43]]+codage_c4[plat[44]]+
                      codage_c5[plat[45]]+codage_c6[plat[46]]+codage_c7[plat[47]]+codage_c8[plat[48]];
        platLigne5 := codage_c1[plat[51]]+codage_c2[plat[52]]+codage_c3[plat[53]]+codage_c4[plat[54]]+
                      codage_c5[plat[55]]+codage_c6[plat[56]]+codage_c7[plat[57]]+codage_c8[plat[58]];
        platLigne6 := codage_c1[plat[61]]+codage_c2[plat[62]]+codage_c3[plat[63]]+codage_c4[plat[64]]+
                      codage_c5[plat[65]]+codage_c6[plat[66]]+codage_c7[plat[67]]+codage_c8[plat[68]];
        platLigne7 := codage_c1[plat[71]]+codage_c2[plat[72]]+codage_c3[plat[73]]+codage_c4[plat[74]]+
                      codage_c5[plat[75]]+codage_c6[plat[76]]+codage_c7[plat[77]]+codage_c8[plat[78]];
        platLigne8 := codage_c1[plat[81]]+codage_c2[plat[82]]+codage_c3[plat[83]]+codage_c4[plat[84]]+
                      codage_c5[plat[85]]+codage_c6[plat[86]]+codage_c7[plat[87]]+codage_c8[plat[88]];
        couleurCodage := couleur;
        nbreVidesCodage := prof;
      end;
  end;

procedure ExpandHashTableExacte(var whichElement:HashTableExacteElement;
                                var whichLegalMoves:CoupsLegauxHashPtr;
                                var codagePosition:codePositionRec;
                                clefHashExacte : SInt32);
  var i : SInt32;
  begin
    with whichElement,codagePosition do
      begin
        ligne1 := platLigne1;
        ligne2 := platLigne2;
        ligne3 := platLigne3;
        ligne4 := platLigne4;
        ligne5 := platLigne5;
        ligne6 := platLigne6;
        ligne7 := platLigne7;
        ligne8 := platLigne8;
        SetTraitDansHashExacte(couleurCodage,whichElement);
        SetBestDefenseDansHashExacte(0,whichElement);
        profondeur := nbreVidesCodage;
        flags := 0;
        evaluationHeuristique := kEvaluationNonFaite;
        
        for i := 1 to kNbreMaxDeltasSuccessifsDansHashExacte do
          begin
            bornesMin[i]         := -64;
            bornesMax[i]         := 64;
            coupsDesBornesMin[i] := 0;
          end;
        
        whichLegalMoves^[clefHashExacte,0] := 0;
      end;
  end;


function InfoTrouveeDansHashTableExacte(var codagePosition:codePositionRec; var quelleHashTableExacte:HashTableExactePtr;clefHashage : SInt32; var whichClefExacte : SInt32) : boolean;
  var increment1,increment2,longueurCollisionPath : SInt32;
      clefHashExacteInitiale,clefAEcraser,minProf : SInt32;
      
  begin        
    SetQDGlobalsRandomSeed(clefHashage+codagePosition.platLigne1+codagePosition.platLigne8+codagePosition.platLigne2+codagePosition.platLigne7);    
    increment1 := BAND(Random(),1023);
    if BAND(increment1,1)=0 then inc(increment1);{pour avoir un nombre premier avec 1024}
    whichClefExacte := BAND((whichClefExacte+increment1),1023);
    clefHashExacteInitiale := whichClefExacte;
    
    (** on cherche si la position apparait dans la HashTable  dans la suite clefHashExacteInitiale, 
    clefHashExacteInitiale + increment1, clefHashExacteInitiale + 2*increment1, ...  **)
    longueurCollisionPath := 0;
    repeat
      with quelleHashTableExacte^[whichClefExacte],codagePosition do
        begin
          if GetTraitDansHashExacte(quelleHashTableExacte^[whichClefExacte])=0 then 
            begin
              (** une place vide : on peut stopper la recherche **)
              InfoTrouveeDansHashTableExacte := false;
              inc(nbNouvellesEntreesHashTableExactes);
              exit(InfoTrouveeDansHashTableExacte);
            end;
          if ligne1=platLigne1 then
          if ligne2=platLigne2 then
          if ligne3=platLigne3 then
          if ligne4=platLigne4 then
          if ligne5=platLigne5 then
          if ligne6=platLigne6 then
          if ligne7=platLigne7 then
          if ligne8=platLigne8 then
          if GetTraitDansHashExacte(quelleHashTableExacte^[whichClefExacte])=couleurCodage then
            begin
              (** on a trouve la position dans la table **)
              InfoTrouveeDansHashTableExacte := true;
              flags := BAND(flags,BNOT(kMaskLiberee));  {elle n'est plus liberee}
              inc(nbPositionsRetrouveesHashTableExactes);
              exit(InfoTrouveeDansHashTableExacte);
            end;
          whichClefExacte := BAND((whichClefExacte+increment1),1023);
          inc(longueurCollisionPath);
        end;
     until (longueurCollisionPath > 12);
    
    SetQDGlobalsRandomSeed(clefHashExacteInitiale+codagePosition.platLigne2+codagePosition.platLigne7);
    increment2 := BAND(Random(),1023);
    if BAND(increment2,1)=0 then inc(increment2); {pour avoir un nb premier avec 1024}
    
    (** on cherche si la position apparait dans la HashTable avec le cycle d'increment2 **)
    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      with quelleHashTableExacte^[whichClefExacte],codagePosition do
        begin
          if GetTraitDansHashExacte(quelleHashTableExacte^[whichClefExacte])=0 then 
            begin
              (** une place vide : on peut stopper la recherche **)
              InfoTrouveeDansHashTableExacte := false;
              inc(nbNouvellesEntreesHashTableExactes);
              exit(InfoTrouveeDansHashTableExacte);
            end;
          if ligne1=platLigne1 then
          if ligne2=platLigne2 then
          if ligne3=platLigne3 then
          if ligne4=platLigne4 then
          if ligne5=platLigne5 then
          if ligne6=platLigne6 then
          if ligne7=platLigne7 then
          if ligne8=platLigne8 then
          if GetTraitDansHashExacte(quelleHashTableExacte^[whichClefExacte])=couleurCodage then
            begin
              (** on a trouve la position dans la table **)
              InfoTrouveeDansHashTableExacte := true;
              flags := BAND(flags,BNOT(kMaskLiberee));  {elle n'est plus liberee}
              inc(nbPositionsRetrouveesHashTableExactes);
              exit(InfoTrouveeDansHashTableExacte);
            end;
          whichClefExacte := BAND((whichClefExacte+increment2),1023);
          inc(longueurCollisionPath);
        end;
    until (longueurCollisionPath > 12);
    
    InfoTrouveeDansHashTableExacte := false;
    
    
    (** on cherche une place liberee dans la HashTable **)
    
    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      if BAND(quelleHashTableExacte^[whichClefExacte].flags,kMaskLiberee) <> 0 then 
        begin
          inc(nbNouvellesEntreesHashTableExactes);
          exit(InfoTrouveeDansHashTableExacte);  (** trouvé une place liberee **)
        end;
      whichClefExacte := BAND((whichClefExacte+increment1),1023);
      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);
    
    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      if BAND(quelleHashTableExacte^[whichClefExacte].flags,kMaskLiberee) <> 0 then 
        begin
          inc(nbNouvellesEntreesHashTableExactes);
          exit(InfoTrouveeDansHashTableExacte);  (** trouvé une place liberee  **)
        end;
      whichClefExacte := BAND((whichClefExacte+increment2),1023);
      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);
    
    (** collision : on ecrase une place le plus bas possible dans l'arbre  **)
    
    inc(nbCollisionsHashTableExactes);
    minProf := 100000;
    
    
    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      with quelleHashTableExacte^[whichClefExacte] do
        begin
          if profondeur < minProf then 
		        begin
              clefAEcraser := whichClefExacte;
              minProf := profondeur;
            end;
        end;
      whichClefExacte := BAND((whichClefExacte+increment1),1023);
      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);
    
    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      with quelleHashTableExacte^[whichClefExacte] do
        begin
          if profondeur < minProf then 
		        begin
              clefAEcraser := whichClefExacte;
              minProf := profondeur;
            end;
        end;
      whichClefExacte := BAND((whichClefExacte+increment2),1023);
      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);
    
    {
    WriteStringAndNumAt('minProf=',minProf,10,40);
    WriteStringAndNumAt('clefAEcraser=',clefAEcraser,10,50);
    SysBeep(0);
    AttendFrappeClavier;
    }
    
    whichClefExacte := clefAEcraser;  (** on ecrase cette position **)
  end;
  


procedure WritelnBornesDansRapport(var bornes:DecompressionHashExacteRec);
var k : SInt32;
begin
  with bornes do 
    begin
      for k := 1 to nbreDeltaSuccessifs do
        begin
          WriteStringAndNumDansRapport('delta = ',ThisDeltaFinal(k));
          WriteStringAndNumDansRapport(' :   valMin[',k);
          WriteStringAndNumDansRapport('] = ',valMin[k]);
          WriteStringAndNumDansRapport(',  coupesMin[',k);
          WriteStringAndNumDansRapport('] = ',nbArbresCoupesValMin[k]);
          WriteStringAndNumDansRapport(',  moveMin[',k);
          WriteStringAndCoupDansRapport('] = ',coupDeCetteValMin[k]);
          WriteStringAndNumDansRapport(',  valMax[',k);
          WriteStringAndNumDansRapport('] = ',valMax[k]);
          WriteStringAndNumDansRapport(',  coupesMax[',k);
          WritelnStringAndNumDansRapport('] = ',nbArbresCoupesValMax[k]);
        end;
    end;
end;


function MeilleurCoupEstStockeDansLesBornes(const bornes:DecompressionHashExacteRec; var meilleurCoup,valeurDeLaPosition : SInt32) : boolean;
var coup : SInt32;
begin
   with bornes do
    begin
      coup := coupDeCetteValMin[nbreDeltaSuccessifs];
      
      if (coup = 0) | (valMin[nbreDeltaSuccessifs] <> valMax[nbreDeltaSuccessifs])
      then 
        MeilleurCoupEstStockeDansLesBornes := false
      else 
        begin
          MeilleurCoupEstStockeDansLesBornes := true;
          meilleurCoup := coup;
          valeurDeLaPosition := valMin[nbreDeltaSuccessifs];
        end
    end;
end;


function VerificationAssertionsSurLeMeilleurCoup(meilleurCoup : SInt32; var bornes:DecompressionHashExacteRec;fonctionAppelante : str255) : OSErr;
var meilleurCoupParBornes : SInt16; 
    erreur : OSErr;
begin
  erreur := 0;
  
  with bornes do
    if (valMin[nbreDeltaSuccessifs] = valMax[nbreDeltaSuccessifs])
      then
        begin
          meilleurCoupParBornes := coupDeCetteValMin[nbreDeltaSuccessifs];
          
          if (meilleurCoupParBornes <> 0) & 
             (meilleurCoupParBornes <> meilleurCoup) then
            begin  
              WritelnDansRapport('');
              WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante = '+fonctionAppelante);
              WritelnStringAndCoupDansRapport('meilleurCoupParBornes = ',meilleurCoupParBornes);
              WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
              WritelnDansRapport('ASSERT (meilleurCoupParBornes <> meilleurCoup) !!');
              erreur := 1;
            end;
        end;
  
  if (erreur <> 0) then
    begin
      SysBeep(0);
      WritelnBornesDansRapport(bornes);
      AttendFrappeClavier;
      LanceInterruption(interruptionSimple,'VerificationAssertionsSurLeMeilleurCoup');
    end;
    
  VerificationAssertionsSurLeMeilleurCoup := erreur;
end;



function VerificationAssertionsSurLesBornes(var bornes:DecompressionHashExacteRec;fonctionAppelante : str255) : OSErr;
var k : SInt32;
    erreur : OSErr;
begin
  erreur := 0;
  VerificationAssertionsSurLesBornes := 0;
  
  with bornes do
    begin
        
      {verification de la parite des bornes}
      for k := 1 to nbreDeltaSuccessifs do
        if (BAND(valMin[k],$01) <> 0) & (erreur=0) then 
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT : valMin[k] impair !!');
            erreur := 1;
          end;
      
      for k := 1 to nbreDeltaSuccessifs do
        if (BAND(valMax[k],$01) <> 0) & (erreur=0) then 
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT : valMax[k] impair !!');
            erreur := 2;
          end;
      
      {verification de la coherence}
      for k := 1 to nbreDeltaSuccessifs do
        if (valMin[k] > valMax[k]) & (erreur=0) then 
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT (valMin[k] > valMax[k]) !!');
            erreur := 3;
          end;
      
      {verification des sens de variation}
      (*
      for k := 2 to nbreDeltaSuccessifs do
        if (valMin[k] > valMin[k-1]) & (erreur=0)  then 
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT : sens de variation des valMin[k] !!');
            erreur := 4;
          end;
      
      for k := 2 to nbreDeltaSuccessifs do
        if (valMax[k] < valMax[k-1]) & (erreur=0)  then 
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT : sens de variation des valMax[k] !!');
            erreur := 5;
          end;
      *)
      
      {verification des intervales}
      for k := 1 to nbreDeltaSuccessifs do
        if ((valMin[k] < -64) | (valMin[k] > 64)) & (erreur=0) then 
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT valMin[k] hors de l''intervale !!');
            erreur := 6;
          end;
      
      for k := 1 to nbreDeltaSuccessifs do
        if ((valMax[k] < -64) | (valMax[k] > 64)) & (erreur=0) then 
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT valMax[k] hors de l''intervale !!');
            erreur := 7;
          end;
        
    end;
      
  if (erreur <> 0) then
    begin
      SysBeep(0);
      WritelnBornesDansRapport(bornes);
      AttendFrappeClavier;
      LanceInterruption(interruptionSimple,'VerificationAssertionsSurLesBornes');
    end;
  
  VerificationAssertionsSurLesBornes := erreur;
end;

procedure PutGarbageInBornes(var bornes:DecompressionHashExacteRec);
var k : SInt32;
begin
  with bornes do
	  for k := 1 to nbreDeltaSuccessifs do
	    begin
	      valMin[k]               := 1355 + k;
	      nbArbresCoupesValMin[k] := -14;
	      
	      valMax[k]               := -101 - k;
	      nbArbresCoupesValMax[k] := -37;
	    end;
end;



procedure DecompresserBornesHashTableExacte(var whichElement:HashTableExacteElement; var bornes:DecompressionHashExacteRec);
var k : SInt32;
    aux,aux2 : SignedByte;
begin
  with whichElement, bornes do
    begin
      
      for k := 1 to nbreDeltaSuccessifs do
        begin
          aux := bornesMin[k];
          aux2 := BAND(aux,$FE);
          valMin[k]               := aux2;
          nbArbresCoupesValMin[k] := BAND(aux,$01);
          {
          WritelnStringAndNumDansRapport('aux(min) = ',aux);
          WritelnStringAndNumDansRapport('aux2(min) = ',aux2);
          }
          aux := bornesMax[k];
          aux2 := BAND(aux,$FE);
          valMax[k]               := aux2;
          nbArbresCoupesValMax[k] := BAND(aux,$01);
          {
          WritelnStringAndNumDansRapport('aux(max) = ',aux);
          WritelnStringAndNumDansRapport('aux2(max) = ',aux2);
          }
          coupDeCetteValMin[k] := coupsDesBornesMin[k];
        end;
                    
    end;
  
  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'DecompresserBornesHashTableExacte') <> NoErr then 
    begin
      WritelnDansRapport('Erreur dans DecompresserBornesHashTableExacte');
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure CompresserBornesDansHashTableExacte(var whichElement:HashTableExacteElement; var bornes : DecompressionHashExacteRec);
var k : SInt32;
begin
  
  with whichElement, bornes do
    begin
      for k := 1 to nbreDeltaSuccessifs do
        begin
        
          bornesMin[k] := valMin[k];
          {if BAND(bornesMin[k],$01) <> 0 then 
            begin
              SysBeep(0);
              WritelnDansRapport('ASSERT : bornesMin[k] impair dans CompresserBornesDansHashTableExacte');
              AttendFrappeClavier;
            end;}
          if (nbArbresCoupesValMin[k] > 0)
            then bornesMin[k] := BOR(bornesMin[k],$01);
        
          bornesMax[k] := valMax[k];
          {if BAND(bornesMax[k],$01) <> 0 then 
            begin
              SysBeep(0);
              WritelnDansRapport('ASSERT : bornesMax[k] impair dans CompresserBornesDansHashTableExacte');
              AttendFrappeClavier;
            end;}
          if (nbArbresCoupesValMax[k] > 0)
            then bornesMax[k] := BOR(bornesMax[k],$01);
          
          coupsDesBornesMin[k] := coupDeCetteValMin[k];
        end;
    end;
    
  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'CompresserBornesDansHashTableExacte') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans CompresserBornesDansHashTableExacte');
      WritelnDansRapport('');
    end;
  
  if VerificationAssertionsSurLeMeilleurCoup(GetBestDefenseDansHashExacte(whichElement),bornes,'CompresserBornesDansHashTableExacte') <> NoErr then 
    begin
      WritelnDansRapport('Erreur dans CompresserBornesDansHashTableExacte');
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure AugmentationMinorant(newValeurMin,newDeltaMin,coup,couleur : SInt32; var bornes:DecompressionHashExacteRec; var plat : plateauOthello;fonctionAppelante : str255);
var k,index,aux,coupAux : SInt32; {$UNUSED fonctionAppelante,couleur,plat}
    {$IFC USE_DEBUG_STEP_BY_STEP}
    dummyLong : SInt32;
    {$ENDC}
begin

  {$IFC USE_DEBUG_STEP_BY_STEP}
  if (coup = 0) & (newValeurMin > -64) & (bornes.valMax[IndexOfThisDelta(newDeltaMin)] <= newValeurMin) then
    begin
      SysBeep(0);
      WritelnStringDansRapport('Vous avez sans doute trouvé un bug, coup = 0 dans AugmentationMinorant! fonctionAppelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WritelnStringAndNumDansRapport('newValeurMin = ',newValeurMin);
      WritelnStringAndNumDansRapport('bornes.valMin[IndexOfThisDelta(newDeltaMin)] = ',bornes.valMin[IndexOfThisDelta(newDeltaMin)]);
      WritelnStringAndNumDansRapport('bornes.valMax[IndexOfThisDelta(newDeltaMin)] = ',bornes.valMax[IndexOfThisDelta(newDeltaMin)]);
      WritelnStringAndNumDansRapport('newDeltaMin = ',newDeltaMin);
      WritelnDansRapport('');
    end;
  {$ENDC}

  if (newValeurMin >= -64) & (newValeurMin <= 64) then 
	  with bornes do
    begin
      index := IndexOfThisDelta(newDeltaMin);
      
      for k := 1 to index do
        begin
          if (valMin[k] = newValeurMin) & (nbArbresCoupesValMin[k] > 0) then
            begin
              valMin[k]            := newValeurMin;
	            coupDeCetteValMin[k] := coup;
	            if (newDeltaMin = kDeltaFinaleInfini)
	              then nbArbresCoupesValMin[k] := 0
	              else nbArbresCoupesValMin[k] := 1;
            end else
          if (valMin[k] < newValeurMin) then 
	          begin
	            valMin[k]            := newValeurMin;
	            coupDeCetteValMin[k] := coup;
	            if (newDeltaMin = kDeltaFinaleInfini)
	              then nbArbresCoupesValMin[k] := 0 
	              else nbArbresCoupesValMin[k] := 1;
	          end else
	        if (valMin[k] = newValeurMin) & (nbArbresCoupesValMin[k] = 0) & 
	           (coupDeCetteValMin[k] = 0) & (newDeltaMin = kDeltaFinaleInfini) then
            begin
              valMin[k]            := newValeurMin;
	            coupDeCetteValMin[k] := coup;
	            if (newDeltaMin = kDeltaFinaleInfini)
	              then nbArbresCoupesValMin[k] := 0
	              else nbArbresCoupesValMin[k] := 1;
            end  
	        
        end;
       
      for k := 1 to index do
		    if (newValeurMin > valMax[k]) & (nbArbresCoupesValMax[k] <> 0) 
		      then valMax[k] := newValeurMin;
		   
		  {quand meme, on prefere l'information sure a 100%}
		  if (newDeltaMin <> kDeltaFinaleInfini) then
		    begin
		      aux     := valMin[nbreDeltaSuccessifs];
		      coupAux := coupDeCetteValMin[nbreDeltaSuccessifs];
		      for k := 1 to index do
		        if (valMin[k] <= aux) then 
		          begin
		            valMin[k] := aux;
		            if coupAux <> 0 then coupDeCetteValMin[k] := coupAux;
		            nbArbresCoupesValMin[k] := 0;
		          end;
		    end;
    end;
	
	{$IFC USE_DEBUG_STEP_BY_STEP}
	if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,
	                              gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	  begin
	    WritelnDansRapport('');
			WriteDansRapport('AugmentationMinorant : ');
		  WriteStringAndNumDansRapport('newValeurMin = ',newValeurMin);
		  WriteStringAndNumDansRapport(',   newDeltaMin = ',newDeltaMin);
		  WriteStringAndCoupDansRapport(',   coup = ',coup);
		  WritelnDansRapport(',   fonctionAppelante = '+fonctionAppelante);
		  
		  index := IndexOfThisDelta(newDeltaMin);
		  WritelnStringAndNumDansRapport('index = ',index);
		  WritelnStringAndNumDansRapport('valMin['+NumEnString(newDeltaMin)+'] = ',bornes.valMin[index]);
		  WritelnStringAndNumDansRapport('valMax['+NumEnString(newDeltaMin)+'] = ',bornes.valMax[index]);
		  WritelnStringAndCoupDansRapport('coupDeCetteValMin['+NumEnString(newDeltaMin)+'] = ',bornes.coupDeCetteValMin[index]);
		  WritelnStringAndNumDansRapport('en SInt16 : coupDeCetteValMin['+NumEnString(newDeltaMin)+'] = ',bornes.coupDeCetteValMin[index]);
		  WritelnStringAndNumDansRapport('nbArbresCoupesValMin['+NumEnString(newDeltaMin)+'] = ',bornes.nbArbresCoupesValMin[index]);
		  WritelnDansRapport('');
		end;
  {$ENDC}
  
  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'AugmentationMinorant') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans AugmentationMinorant,   fonctionAppelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WriteStringAndNumDansRapport('newValeurMin = ',newValeurMin);
		  WriteStringAndNumDansRapport(',   newDeltaMin = ',newDeltaMin);
		  WriteStringAndCoupDansRapport(',   coup = ',coup);
      WritelnDansRapport('');
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure DiminutionMajorant(newValeurMax,newDeltaMax,couleur : SInt32; var bornes:DecompressionHashExacteRec; var plat : plateauOthello;fonctionAppelante : str255);
var k,index,aux : SInt32;  {$UNUSED fonctionAppelante,couleur,plat}
begin

  if (newValeurMax >= -64) & (newValeurMax <= 64) then
  with bornes do
    begin
      index := IndexOfThisDelta(newDeltaMax);
      
      for k := 1 to index do
        begin
          if (valMax[k] = newValeurMax) & (nbArbresCoupesValMax[k] > 0) then
            begin
              valMax[k] := newValeurMax;
	            if (newDeltaMax = kDeltaFinaleInfini)
	              then nbArbresCoupesValMax[k] := 0
	              else nbArbresCoupesValMax[k] := 1;
            end else
	        if (valMax[k] > newValeurMax) then 
	          begin
	            valMax[k] := newValeurMax;
	            if (newDeltaMax = kDeltaFinaleInfini)
	              then nbArbresCoupesValMax[k] := 0
	              else nbArbresCoupesValMax[k] := 1;
	          end;
        end;
       
      for k := 1 to index do
		    if (valMin[k] > newValeurMax ) & (nbArbresCoupesValMin[k] <> 0) 
		      then valMin[k] := newValeurMax;
		   
		  {quand meme, on prefere l'information sure a 100%}
			if (newDeltaMax <> kDeltaFinaleInfini) then
			  begin
			    aux := valMax[nbreDeltaSuccessifs];
			    for k := 1 to index do
			      if (valMax[k] >= aux) then 
			        begin
			          valMax[k] := aux;
			          nbArbresCoupesValMax[k] := 0;
			        end;
			  end;
    end;
    
  {$IFC USE_DEBUG_STEP_BY_STEP}
  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,
                                gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	  begin
	    WritelnDansRapport('');
      WriteDansRapport('DiminutionMajorant : ');
      WriteStringAndNumDansRapport('newValeurMax = ',newValeurMax);
      WriteStringAndNumDansRapport(',   newDeltaMax = ',newDeltaMax);
      WritelnDansRapport(',   fonctionAppelante = '+fonctionAppelante);
      WritelnDansRapport('');
    end;
  {$ENDC}
  
  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'DiminutionMajorant') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans DiminutionMajorant,   fonctionAppelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WriteStringAndNumDansRapport('newValeurMax = ',newValeurMax);
      WriteStringAndNumDansRapport(',   newDeltaMax = ',newDeltaMax);
      WritelnDansRapport('');
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure EnleverBornesMinPeuSuresDesAutresCoups(whichLegalMoves:CoupsLegauxHashPtr;clefHashExacte,couleur : SInt32; var bornes:DecompressionHashExacteRec; var plat : plateauOthello);
var n,k,square : SInt32; {$UNUSED couleur,plat}
    coupsLegaux : SquareSet;
begin
  n := whichLegalMoves^[clefHashExacte,0];
  if (n > 0) then
    begin
      coupsLegaux := [];
      for k := 1 to n do
        begin
          square := whichLegalMoves^[clefHashExacte,k];
          if (square <> 0) then 
            coupsLegaux := coupsLegaux + [square];
        end;
      
      with bornes do
	      for k := 1 to nbreDeltaSuccessifs - 1 do
	        begin
	          square := coupDeCetteValMin[k];
	          if (square <> 0) & not(square in coupsLegaux) then
	            begin
	              valMin[k]               := valMin[nbreDeltaSuccessifs];
	              coupDeCetteValMin[k]    := coupDeCetteValMin[nbreDeltaSuccessifs];
	              nbArbresCoupesValMin[k] := 0;
	            end;
	        end;
    end;
  
  {$IFC USE_DEBUG_STEP_BY_STEP}
  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,
                                gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	  begin
	    WritelnDansRapport('');
      WriteDansRapport('EnleverBornesMinPeuSuresDesAutresCoups : ');
      WritelnStringAndNumDansRapport('nouveaux nbre de coups legaux  = ',n);
      WritelnBornesDansRapport(bornes);
      WritelnDansRapport('');
      WritelnDansRapport('');
    end;
  {$ENDC}
  
  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'EnleverBornesMinPeuSuresDesAutresCoups') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans EnleverBornesMinPeuSuresDesAutresCoups !!');
      WritelnDansRapport('');
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure PutEndgameValuesInHashExacte(clefHash,nbVides : SInt32;jeu : PositionEtTraitRec;valMin,valMax,meilleurCoup : SInt32);
var nroTableExacte,laClefExacte,bestDefDansHash : SInt32;
    valeurDeLaPositionDansHash : SInt32;
    quelleHashTableExacte:HashTableExactePtr;
    quelleHashTableCoupsLegaux:CoupsLegauxHashPtr;
    codagePosition:codePositionRec;
    bornes:DecompressionHashExacteRec;
    dejaDansHash : boolean;
begin 
  
  
  {$IFC USE_DEBUG_STEP_BY_STEP}
  if MemberOfPositionEtTraitSet(jeu,dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
    then
      begin
        WritelnDansRapport('');
        WritelnDansRapport('Entrée dans PutEndgameValuesInHashExacte :');
        WritelnPositionEtTraitDansRapport(jeu.position,GetTraitOfPosition(jeu));
        WritelnStringAndNumDansRapport('valMin = ',valMin);
        WritelnStringAndNumDansRapport('valMax = ',valMax);
        WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
        WritelnDansRapport('');
      end;
  {$ENDC}
  
  
  
  if (odd(valMin) | odd(valMax)) then
    begin
      WritelnDansRapport('Erreur : valMin ou valMax est impair dans PutEndgameValuesInHashExacte!! Prévenez Stéphane');
      WritelnStringAndNumDansRapport('valMin = ',valMin);
      WritelnStringAndNumDansRapport('valMax = ',valMax);
      exit(PutEndgameValuesInHashExacte);
    end;
  
  if (valMin > valMax) then
    begin
      WritelnDansRapport('Erreur : valMin > valMax dans PutEndgameValuesInHashExacte!! Prévenez Stéphane');
      WritelnStringAndNumDansRapport('valMin = ',valMin);
      WritelnStringAndNumDansRapport('valMax = ',valMax);
      exit(PutEndgameValuesInHashExacte);
    end;

  nroTableExacte := BAND(clefHash div 1024,nbTablesHashExactesMoins1);
  laClefExacte := BAND(clefHash,1023);
  
  quelleHashTableExacte := HashTableExacte[nroTableExacte];
  quelleHashTableCoupsLegaux := CoupsLegauxHash[nroTableExacte];
  CreeCodagePosition(jeu.position,GetTraitOfPosition(jeu),nbVides,codagePosition);
  
  dejaDansHash := InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,clefHash,laClefExacte);
  
  if dejaDansHash
    then
      begin
        if (valMin <= -64) & (meilleurCoup <> 0) then
          begin
            (*
            bestDefDansHash := GetBestDefenseDansHashExacte(quelleHashTableExacte^[laClefExacte]);
            WritelnStringAndCoupDansRapport(CoupEnStringEnMajuscules(meilleurCoup)+ ' vs ',bestDefDansHash);
            if (bestDefDansHash <> meilleurCoup) & (bestDefDansHash <> 0)
              then 
                begin
                  meilleurCoup := 0;
                  SetBestDefenseDansHashExacte(0,quelleHashTableExacte^[laClefExacte]);
                end;
            *)
          end;
        DecompresserBornesHashTableExacte(quelleHashTableExacte^[laClefExacte],bornes);
        if MeilleurCoupEstStockeDansLesBornes(bornes,bestDefDansHash,valeurDeLaPositionDansHash)
          then meilleurCoup := bestDefDansHash;
        
        SetBestDefenseDansHashExacte(meilleurCoup,quelleHashTableExacte^[laClefExacte]);
      end
    else
      begin
        ExpandHashTableExacte(quelleHashTableExacte^[laClefExacte],quelleHashTableCoupsLegaux,codagePosition,laClefExacte);
        if (meilleurCoup <> 0)
          then SetBestDefenseDansHashExacte(meilleurCoup,quelleHashTableExacte^[laClefExacte]);
      end;
      
  DecompresserBornesHashTableExacte(quelleHashTableExacte^[laClefExacte],bornes);
  AugmentationMinorant(valMin,kDeltaFinaleInfini,meilleurCoup,GetTraitOfPosition(jeu),bornes,jeu.position,'PutEndgameValuesInHashExacte');
  DiminutionMajorant(valMax,kDeltaFinaleInfini,GetTraitOfPosition(jeu),bornes,jeu.position,'PutEndgameValuesInHashExacte');
  CompresserBornesDansHashTableExacte(quelleHashTableExacte^[laClefExacte],bornes);
  
  {$IFC USE_DEBUG_STEP_BY_STEP}
  if MemberOfPositionEtTraitSet(jeu,dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
    then
      begin
        WritelnDansRapport('');
        WritelnDansRapport('Sortie de PutEndgameValuesInHashExacte :');
        WritelnStringAndNumDansRapport('valMin = ',valMin);
        WritelnStringAndNumDansRapport('valMax = ',valMax);
        WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
        WritelnDansRapport('');
      end;
  {$ENDC}
    
end;


function GetEndgameBornesInHashTableAtThisHashKey(plat : PositionEtTraitRec; hashKey : SInt32; var bornes : DecompressionHashExacteRec) : boolean;
var nbVides : SInt32;
    laClefExacte,nroTableExacte : SInt32;
    quelleHashTableExacte:HashTableExactePtr;
    codagePosition:codePositionRec;
begin

  nbVides := NbCasesVidesDansPosition(plat.position);
	nroTableExacte := BAND(hashKey div 1024,nbTablesHashExactesMoins1);
	laClefExacte := BAND(hashKey,1023);
  quelleHashTableExacte := HashTableExacte[nroTableExacte];
  CreeCodagePosition(plat.position,GetTraitOfPosition(plat),nbVides,codagePosition);
  
  if InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,hashKey,laClefExacte)
    then
      begin
        DecompresserBornesHashTableExacte(quelleHashTableExacte^[laClefExacte],bornes);
        GetEndgameBornesInHashTableAtThisHashKey := true;
        
        (*
        WritelnDansRapport('OK : position trouvee (1)');
        WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
        {WritelnBornesDansRapport(bornes);}
        WritelnStringAndNumDansRapport('valMinPourNoir = ',valMinPourNoir);
        WritelnStringAndNumDansRapport('valMaxPourNoir = ',valMaxPourNoir);
        WritelnDansRapport('');
        *)
      end
    else
      begin
        GetEndgameBornesInHashTableAtThisHashKey := false;
        
        (*
        WritelnDansRapport('BIZARRE : non trouvee dans hash dans GetEndgameValuesInHashTableAtThisHashKey (1)');
        WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
        WritelnDansRapport('');
        *)
      end;
end;

function GetEndgameValuesInHashTableAtThisHashKey(plat : PositionEtTraitRec;hashKey,deltaFinale : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32) : boolean;
var nbVides : SInt32;
    laClefExacte,nroTableExacte : SInt32;
    quelleHashTableExacte:HashTableExactePtr;
    codagePosition:codePositionRec;
begin

  nbVides := NbCasesVidesDansPosition(plat.position);
	nroTableExacte := BAND(hashKey div 1024,nbTablesHashExactesMoins1);
	laClefExacte := BAND(hashKey,1023);
  quelleHashTableExacte := HashTableExacte[nroTableExacte];
  CreeCodagePosition(plat.position,GetTraitOfPosition(plat),nbVides,codagePosition);
  
  if InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,hashKey,laClefExacte)
    then
      begin
        GetEndgameValuesInHashTableElement(quelleHashTableExacte^[laClefExacte],deltaFinale,valMinPourNoir,valMaxPourNoir);
        GetEndgameValuesInHashTableAtThisHashKey := true;
        
        (*
        WritelnDansRapport('OK : position trouvee (1)');
        WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
        {WritelnBornesDansRapport(bornes);}
        WritelnStringAndNumDansRapport('valMinPourNoir = ',valMinPourNoir);
        WritelnStringAndNumDansRapport('valMaxPourNoir = ',valMaxPourNoir);
        WritelnDansRapport('');
        *)
      end
    else
      begin
        GetEndgameValuesInHashTableAtThisHashKey := false;
        valMinPourNoir := -64;
        valMaxPourNoir :=  64;
        
        (*
        WritelnDansRapport('BIZARRE : non trouvee dans hash dans GetEndgameValuesInHashTableAtThisHashKey (1)');
        WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
        WritelnDansRapport('');
        *)
      end;
end;



function GetEndgameValuesInHashTableFromThisNode(plat : PositionEtTraitRec;G : GameTree;deltaFinale : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32) : boolean;
var myHashIndex,lastPlayedMove : SInt32;
begin
	myHashIndex := CalculateHashIndexFromThisNode(plat,G,lastPlayedMove);
	
	GetEndgameValuesInHashTableFromThisNode := GetEndgameValuesInHashTableAtThisHashKey(plat,myHashIndex,deltaFinale,valMinPourNoir,valMaxPourNoir);
end;


function GetEndgameBornesDansHashExacteAfterThisSon(coup : SInt32; platDepart : PositionEtTraitRec; clefHashage : SInt32; var bornes : DecompressionHashExacteRec) : boolean;
var k,hashKeyAfterCoup : SInt32;
    platAux : PositionEtTraitRec;
    aux : SInt32;
begin 

  GetEndgameBornesDansHashExacteAfterThisSon := false;
  
  with bornes do
    for k := 1 to kNbreMaxDeltasSuccessifsDansHashExacte do
      begin
        valMin[k]               := -64;
        valMax[k]               := 64;
        nbArbresCoupesValMin[k] := 0;
        nbArbresCoupesValMax[k] := 0;
        coupDeCetteValMin[k]    := 0;              
      end;
  
  (* WritelnDansRapport('');
     WritelnDansRapport('Entrée dans GetEndgameBornesDansHashExacteAfterThisSon'); *)
  
  platAux := platDepart;
  
  if UpdatePositionEtTrait(platAux,coup) 
    then
      begin
	      hashKeyAfterCoup := BXOR(clefHashage, IndiceHash^^[GetTraitOfPosition(platAux),coup]);
	      
	      if GetEndgameBornesInHashTableAtThisHashKey(platAux,hashKeyAfterCoup,bornes)
	        then
	          begin
	            GetEndgameBornesDansHashExacteAfterThisSon := true;
	            
	            if GetTraitOfPosition(platDepart) <> GetTraitOfPosition(platAux) then
	              begin
	                with bornes do
  	                for k := 1 to nbreDeltaSuccessifs do
  	                  begin
  	                    aux       := valMin[k];
  	                    valMin[k] := -valMax[k];
  	                    valMax[k] := -aux;
  	                    aux                     := nbArbresCoupesValMin[k];
  	                    nbArbresCoupesValMin[k] := nbArbresCoupesValMax[k];
  	                    nbArbresCoupesValMax[k] := aux;
  	                  end;
	              end;
	            
	            
	            
	            (* WritelnStringAndNumDansRapport('trouvé '+CoupEnString(coup,true)+' => ',valMin[nbreDeltaSuccessifs]); *)
	          end
	        else
	          begin 
	            (* WritelnDansRapport('non trouvé '+ CoupEnString(coup,true)); *)
	          end; 
	    end
	  else
	    begin
	      WritelnDansRapport('HORREUR ! not(UpdatePositionEtTrait(platAux,coup) dans GetEndgameBornesDansHashExacteAfterThisSon !!!');
	    end;

end;



function ScoreFinalEstConfirmeParValeursHashExacte(genreReflexion,scoreDeNoir,vMinPourNoir,vMaxPourNoir : SInt32) : boolean;
var result : boolean;
begin
  result := false;
  case genreReflexion of
    ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif :
      begin
        result := (scoreDeNoir = vMinPourNoir) & (scoreDeNoir = vMaxPourNoir);
      end;
    ReflGagnant,ReflRetrogradeGagnant,ReflParfaitExhaustPhaseGagnant, ReflGagnantExhaustif:
      begin
        if (scoreDeNoir > 0) then result := (vMinPourNoir > 0) else
        if (scoreDeNoir < 0) then result := (vMaxPourNoir < 0) else
        if (scoreDeNoir = 0) then result := (vMinPourNoir = 0) & (vMaxPourNoir = 0);
      end;
  end; {case}
  ScoreFinalEstConfirmeParValeursHashExacte := result;
end;



function TauxDeRemplissageHashExacte(nroTable : SInt32;ecritStatsDetaillees : boolean) : extended;
var vides,liberees,utilisees,k : SInt32;
    whichTableExacte : HashTableExactePtr;
    whichTableCoupsLegaux : CoupsLegauxHashPtr;
begin
  if (nroTable<0) | (nroTable>nbMaxTablesHashExactes) then
    begin
      TauxDeRemplissageHashExacte := -1.0;
      exit(TauxDeRemplissageHashExacte);
    end;
  
  if ((HashTableExacte[nroTable] =  NIL) & (CoupsLegauxHash[nroTable] <> NIL)) |
     ((HashTableExacte[nroTable] <> NIL) & (CoupsLegauxHash[nroTable] =  NIL)) then
    begin
      SysBeep(0);
      WritelnStringAndNumDansRapport('ERROR : (HashTableExacte[i] = NIL) XOR (CoupsLegauxHash[i] = NIL) pour i=',nroTable);
      TauxDeRemplissageHashExacte := -1.0;
      exit(TauxDeRemplissageHashExacte);
    end;
  
  if (HashTableExacte[nroTable] =  NIL) | (CoupsLegauxHash[nroTable] = NIL) then
    begin
      TauxDeRemplissageHashExacte := -1.0;
      exit(TauxDeRemplissageHashExacte);
    end;
  
  whichTableExacte := HashTableExacte[nroTable];
  whichTableCoupsLegaux := CoupsLegauxHash[nroTable];
  
  vides := 0;
  liberees := 0;
  utilisees := 0;
  for k := 0 to 1023 do
    begin
      if GetTraitDansHashExacte(whichTableExacte^[k]) = pionVide 
        then 
          inc(vides)
        else
          begin
            inc(utilisees);
            if BAND(whichTableExacte^[k].flags,kMaskLiberee) <> 0 then 
              inc(liberees);
          end;
    end;
  
  if ecritStatsDetaillees then
    begin
      WriteDansRapport('HashTableExacte['+NumEnString(nroTable)+']:');
      WriteStringAndReelDansRapport(' remplissage=', (1.0*utilisees/1024),5);
      WriteStringAndReelDansRapport(' vides=', (1.0*vides/1024),5);
      WriteStringAndReelDansRapport(' liberees=', (1.0*liberees/1024),5);
      WritelnDansRapport('');
    end;
    
  TauxDeRemplissageHashExacte := (1.0*(utilisees-liberees)/1024);
  
end;


{$IFC USE_DEBUG_STEP_BY_STEP}
procedure AjouterPositionsDevantEtreDebugueesPasAPas(var positionsCherchees:PositionEtTraitSet);
var aPosition : PositionEtTraitRec;
    typeErreur : SInt16; 
    s : str255;
begin
  
  s := 'F5D6C3D3C4F4E6G6C7C5B4E7E3C6D7B5A6D8B6C8F7E8F6G5F3F2F8G8G3E2H5D2D1B3C1A4A5A3A2F1C2E1B2A1B1H3B7H6G2H4G4H2H7H8G7A7G1H1';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,Length(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
  
  
  (*
  s := 'C4E3F6E6F5C5F4G6F7D3G5C3B6D6E7B5A5D7C6C7C8G3D8H6H4G4H3A4A3F8E8B8F3F2E2A6H5A2D2C1D1E1H7G2B4B3';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,Length(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
  *)
  
  (*
  s := 'F5F6E6F4G5E7F7C5F3G4E3H5D6D3C6D7G6H6H3F8C8D8C7B5C2B6C3E2H4C4F2H2D1B3D2B1E8E1F1B8C1G1B7G3G2';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,Length(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
  
  s := 'F5F6E6F4G5E7F7C5F3G4E3H5D6D3C6D7G6H6H3F8C8D8C7B5C2B6C3E2H4C4F2H2D1B3D2B1E8E1F1B8C1G1B7G3H7';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,Length(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
  *)
  
  {aPosition := MakePositionEtTrait(plat,couleur);}
  {
  dummy := UpdatePositionEtTrait(aPosition,11);
  dummy := UpdatePositionEtTrait(aPosition,73);
  dummy := UpdatePositionEtTrait(aPosition,84);
  
  dummy := UpdatePositionEtTrait(aPosition,16);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
  
  dummy := UpdatePositionEtTrait(aPosition,21);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
  }
  
  {dummy := UpdatePositionEtTrait(aPosition,12);}
end;


{$ENDC}


END.