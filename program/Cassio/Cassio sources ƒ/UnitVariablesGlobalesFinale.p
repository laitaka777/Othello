UNIT UnitVariablesGlobalesFinale;


INTERFACE







{$DEFINEC NBRE_NOEUDS_EXACT_DANS_ENDGAME   true }

{$DEFINEC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME   FALSE}
(*
{$SETC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME  := (NBRE_NOEUDS_EXACT_DANS_ENDGAME & false) }
*)


USES UnitOth0,UnitBitboardTypes;



type DoubleArray = array[0..0] of Double;  {pour pouvoir copier 8 octets ˆ la fois}
     DoubleArrayPtr = ^DoubleArray;
     LongintArray = array[0..0] of SInt32; {pour pouvoir copier 4 octets ˆ la fois}
     LongintArrayPtr = ^LongintArray;



const kNbreMaxDeltasSuccessifs = kNbreMaxDeltasSuccessifsDansHashExacte;  { = 10 }
      


var 
    { stability_alpha[n] says for which value of alpha 
      we should begin to try an stability cut-off at n empties }
    stability_alpha : array[0..64] of SInt32;  


    (* degre d'approximations successifs *)
    nbreDeltaSuccessifs : SInt32;
    deltaSuccessifs : array[1..kNbreMaxDeltasSuccessifs] of SInt32;
    
    (* profEvaluationHeuristique[d] est la taille du sous-arbre local 
       utilise pour l'evaluation heuristique quand il reste d cases vides *)
    profEvaluationHeuristique : array[0..64] of SInt32;


    deltaFinaleCourant : SInt32;
    indexDeltaFinaleCourant : SInt32;
    profFinaleHeuristique : SInt32;
    nbCoupuresHeuristiquesCettePasse : SInt32;
    maxEvalsRecursives : SInt32;
    dernierIndexDeltaRenvoye : SInt32;
    meilleureSuiteAEteCalculeeParOptimalite : boolean;
        
    {
    distanceFrontiereHeuristique : SInt32;
    profMinimalePourClassementParMilieuForcee : SInt32;
    }

    {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
    nbAppelsABFinPetite : array[0..64] of UInt32;
    nbNoeudsDansABFinPetite : array[0..64] of UInt32;
    tempoNbNoeudsDansABFinPetite : array[0..64] of UInt32;
    {$ENDC}
    
    nbNoeudsEstimes : array[0..64] of SInt32;

    
    usingEndgameTrees : boolean;
   
    profTriInterneEnFinale : array[0..64] of SInt32;
    (* profTriInterneEnFinale[i] dit a quelle profondeur de milieu de partie 
       on doit aller pour trier des coups en finale ˆ i cases vides *)
       
    restrictionLargeurSousArbreCeDelta : array[1..kNbreMaxDeltasSuccessifs,0..64] of SInt32;
    (* restrictionLargeurSousArbreCeDelta[i,p] dit le degre de branchement
       de l'arbre que l'on examine pour l'index de deltaFinal i, a la 
       profondeur p *)


    valeur_seuil_fastest_first : array[0..64] of SInt32;
    (* valeur_seuil_fastest_first[i] dit pour chaque profondeur 
       a partir de combien au dessus de beta on fait du fastest-first *)


    dilatationEvalEnFinale : extended;
    valeur_seuil_super_fastest : SInt32;
    seuil_pour_alpha_fastest : SInt32;
    seuil_pour_beta_fastest : SInt32;

var gNbreNonCoins_entreeCoupGagnant : SInt32;    { sans les coins }
    gNbreVides_entreeCoupGagnant : SInt32;         
    gNbreCoins_entreeCoupGagnant : SInt32;
    gNbreCoinsPlus1_entreeCoupGagnant : SInt32;
    gNbreCoinsPlus2_entreeCoupGagnant : SInt32;
    gCoins_entreeCoupGagnant : array[1..4] of SInt32;
    gNonCoins_entreeCoupGagnant : array[1..64] of SInt32;
    gCasesVides_entreeCoupGagnant : array[1..64] of SInt32;
    gNbreVidesCeQuadrantCoupGagnant : array[0..3] of SInt32;
    gListeCasesVidesOrdreJCWCoupGagnant : array[1..64] of SInt32;       


var

  triParDenombrementMobilite : array[0..63,0..63] of SInt32;
  denombrementPourCetteMobilite : array[0..63] of SInt32;
  gProfondeurCoucheProofNumberSearch : SInt32; 

  gProfondeurCoucheEvalsHeuristiques : SInt32;
  
  
type ModifPlatBitboardProcType =
  function (vecteurParite : SInt32;my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32; var resultat:bitboard; var diffPions : SInt32) : SInt32;


var ModifPlatBitboardFunction : array[0..99] of ModifPlatBitboardProcType;


procedure InitUnitVariablesGlobalesFinale;

{$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
procedure ResetCollecteStatsNbreNoeudsEndgame;
{$ENDC}


(* gestion du deltaFinaleCourant *)
function DeltaAAfficherImmediatement(whichDeltaFinal : SInt32) : boolean;
function IndexOfThisDelta(whichDeltaFinale : SInt32) : SInt32;
function ThisDeltaFinal(index : SInt32) : SInt32;
procedure SetDeltaFinalCourant(delta : SInt32);





IMPLEMENTATION







USES UnitRapport,Sound,UnitBitboardModifPlat;



{$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
procedure ResetCollecteStatsNbreNoeudsEndgame;
var i : SInt16; 
begin
  for i := 0 to 64 do
    begin
      nbAppelsABFinPetite[i] := 0;
      nbNoeudsDansABFinPetite[i] := 0;
      tempoNbNoeudsDansABFinPetite[i] := 0;
    end;
end;
{$ENDC}

procedure InitUnitVariablesGlobalesFinale;
var i : SInt16; 
begin
  {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
  ResetCollecteStatsNbreNoeudsEndgame;
  {$ENDC}
  
  nbNoeudsEstimes[0] := 2;
  nbNoeudsEstimes[1] := 3;
  nbNoeudsEstimes[2] := 5;
  nbNoeudsEstimes[3] := 8;
  nbNoeudsEstimes[4] := 10;
  nbNoeudsEstimes[5] := 13;
  nbNoeudsEstimes[6] := 30;
  nbNoeudsEstimes[7] := 50;
  nbNoeudsEstimes[8] := 80;
  nbNoeudsEstimes[9] := 130;
  nbNoeudsEstimes[10] := 220;
  nbNoeudsEstimes[11] := 400;
  nbNoeudsEstimes[12] := 800;
  nbNoeudsEstimes[13] := 1500;
  nbNoeudsEstimes[14] := 2800;
  nbNoeudsEstimes[15] := 3500;
  nbNoeudsEstimes[16] := 6000;
  nbNoeudsEstimes[17] := 11800;
  nbNoeudsEstimes[18] := 65000;
  nbNoeudsEstimes[19] := 150000;
  nbNoeudsEstimes[20] := 300000;
  nbNoeudsEstimes[21] := 600000;
  nbNoeudsEstimes[22] := 600000;
  nbNoeudsEstimes[23] := 600000;
  nbNoeudsEstimes[24] := 600000;
  nbNoeudsEstimes[25] := 600000;
  nbNoeudsEstimes[26] := 600000;
  nbNoeudsEstimes[27] := 600000;
  nbNoeudsEstimes[28] := 600000;
  nbNoeudsEstimes[29] := 600000;
  for i := 30 to 64 do
    nbNoeudsEstimes[i] := nbNoeudsEstimes[29];
  
  
  ModifPlatBitboardFunction[11] := ModifPlatBitboard_a1;
  ModifPlatBitboardFunction[12] := ModifPlatBitboard_b1;
  ModifPlatBitboardFunction[13] := ModifPlatBitboard_c1;
  ModifPlatBitboardFunction[14] := ModifPlatBitboard_d1;
  ModifPlatBitboardFunction[15] := ModifPlatBitboard_e1;
  ModifPlatBitboardFunction[16] := ModifPlatBitboard_f1;
  ModifPlatBitboardFunction[17] := ModifPlatBitboard_g1;
  ModifPlatBitboardFunction[18] := ModifPlatBitboard_h1;
  
  ModifPlatBitboardFunction[21] := ModifPlatBitboard_a2;
  ModifPlatBitboardFunction[22] := ModifPlatBitboard_b2;
  ModifPlatBitboardFunction[23] := ModifPlatBitboard_c2;
  ModifPlatBitboardFunction[24] := ModifPlatBitboard_d2;
  ModifPlatBitboardFunction[25] := ModifPlatBitboard_e2;
  ModifPlatBitboardFunction[26] := ModifPlatBitboard_f2;
  ModifPlatBitboardFunction[27] := ModifPlatBitboard_g2;
  ModifPlatBitboardFunction[28] := ModifPlatBitboard_h2;
  
  ModifPlatBitboardFunction[31] := ModifPlatBitboard_a3;
  ModifPlatBitboardFunction[32] := ModifPlatBitboard_b3;
  ModifPlatBitboardFunction[33] := ModifPlatBitboard_c3;
  ModifPlatBitboardFunction[34] := ModifPlatBitboard_d3;
  ModifPlatBitboardFunction[35] := ModifPlatBitboard_e3;
  ModifPlatBitboardFunction[36] := ModifPlatBitboard_f3;
  ModifPlatBitboardFunction[37] := ModifPlatBitboard_g3;
  ModifPlatBitboardFunction[38] := ModifPlatBitboard_h3;
  
  ModifPlatBitboardFunction[41] := ModifPlatBitboard_a4;
  ModifPlatBitboardFunction[42] := ModifPlatBitboard_b4;
  ModifPlatBitboardFunction[43] := ModifPlatBitboard_c4;
  ModifPlatBitboardFunction[44] := ModifPlatBitboard_d4;
  ModifPlatBitboardFunction[45] := ModifPlatBitboard_e4;
  ModifPlatBitboardFunction[46] := ModifPlatBitboard_f4;
  ModifPlatBitboardFunction[47] := ModifPlatBitboard_g4;
  ModifPlatBitboardFunction[48] := ModifPlatBitboard_h4;
  
  ModifPlatBitboardFunction[51] := ModifPlatBitboard_a5;
  ModifPlatBitboardFunction[52] := ModifPlatBitboard_b5;
  ModifPlatBitboardFunction[53] := ModifPlatBitboard_c5;
  ModifPlatBitboardFunction[54] := ModifPlatBitboard_d5;
  ModifPlatBitboardFunction[55] := ModifPlatBitboard_e5;
  ModifPlatBitboardFunction[56] := ModifPlatBitboard_f5;
  ModifPlatBitboardFunction[57] := ModifPlatBitboard_g5;
  ModifPlatBitboardFunction[58] := ModifPlatBitboard_h5;
  
  ModifPlatBitboardFunction[61] := ModifPlatBitboard_a6;
  ModifPlatBitboardFunction[62] := ModifPlatBitboard_b6;
  ModifPlatBitboardFunction[63] := ModifPlatBitboard_c6;
  ModifPlatBitboardFunction[64] := ModifPlatBitboard_d6;
  ModifPlatBitboardFunction[65] := ModifPlatBitboard_e6;
  ModifPlatBitboardFunction[66] := ModifPlatBitboard_f6;
  ModifPlatBitboardFunction[67] := ModifPlatBitboard_g6;
  ModifPlatBitboardFunction[68] := ModifPlatBitboard_h6;
  
  ModifPlatBitboardFunction[71] := ModifPlatBitboard_a7;
  ModifPlatBitboardFunction[72] := ModifPlatBitboard_b7;
  ModifPlatBitboardFunction[73] := ModifPlatBitboard_c7;
  ModifPlatBitboardFunction[74] := ModifPlatBitboard_d7;
  ModifPlatBitboardFunction[75] := ModifPlatBitboard_e7;
  ModifPlatBitboardFunction[76] := ModifPlatBitboard_f7;
  ModifPlatBitboardFunction[77] := ModifPlatBitboard_g7;
  ModifPlatBitboardFunction[78] := ModifPlatBitboard_h7;
  
  ModifPlatBitboardFunction[81] := ModifPlatBitboard_a8;
  ModifPlatBitboardFunction[82] := ModifPlatBitboard_b8;
  ModifPlatBitboardFunction[83] := ModifPlatBitboard_c8;
  ModifPlatBitboardFunction[84] := ModifPlatBitboard_d8;
  ModifPlatBitboardFunction[85] := ModifPlatBitboard_e8;
  ModifPlatBitboardFunction[86] := ModifPlatBitboard_f8;
  ModifPlatBitboardFunction[87] := ModifPlatBitboard_g8;
  ModifPlatBitboardFunction[88] := ModifPlatBitboard_h8;
  
end;


function DeltaAAfficherImmediatement(whichDeltaFinal : SInt32) : boolean;
var aux : SInt32;
begin
  if whichDeltaFinal=kDeltaFinaleInfini 
    then 
      DeltaAAfficherImmediatement := true
    else
      if ((whichDeltaFinal mod 100)=0)   {deltaFinale entier ?}
        then 
          begin
            aux := whichDeltaFinal div 100;
            DeltaAAfficherImmediatement := {(aux=0)  |} (aux=1) | 
                                            (aux=2)  | (aux=4)  | 
                                            (aux=8)  | (aux=14) |
                                            (aux=16) | (aux=24);
          end
        else
          DeltaAAfficherImmediatement := false;
end;




function IndexOfThisDelta(whichDeltaFinale : SInt32) : SInt32;
var i : SInt32;
begin
  if deltaSuccessifs[dernierIndexDeltaRenvoye] = whichDeltaFinale
    then 
      begin
        IndexOfThisDelta := dernierIndexDeltaRenvoye;
        exit(IndexOfThisDelta);
      end
    else
      begin
        for i := nbreDeltaSuccessifs downto 1 do
          if deltaSuccessifs[i] = whichDeltaFinale then
            begin
              IndexOfThisDelta := i;
              dernierIndexDeltaRenvoye := i;
              exit(IndexOfThisDelta);
            end;
      end;
  SysBeep(0);
  WritelnStringAndNumDansRapport('ERREUR dans IndexOfThisDelta : whichDeltaFinale = ',whichDeltaFinale);
  IndexOfThisDelta := 0;
end;

function ThisDeltaFinal(index : SInt32) : SInt32;
begin
  if (index < 1) | (index > nbreDeltaSuccessifs) then
    begin
      SysBeep(0);
      WritelnStringAndNumDansRapport('ERREUR dans ThisDeltaFinal : index = ',index);
      ThisDeltaFinal := 0;
      exit(ThisDeltaFinal);
    end;
  ThisDeltaFinal := deltaSuccessifs[index];
end;

procedure SetDeltaFinalCourant(delta : SInt32);
begin
  deltaFinaleCourant := delta;
  indexDeltaFinaleCourant := IndexOfThisDelta(deltaFinaleCourant);
end;


END.


