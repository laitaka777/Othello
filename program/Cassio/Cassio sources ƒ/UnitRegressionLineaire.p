UNIT UnitRegressionLineaire;


INTERFACE







USES UnitOth0;


const kModeleNonAjustePourCeScore = -100000;


{fonctions pour Ajuster l'evaluation de transformer une evaluation 
 de milieu de partie en estimation du score finale. Il faut appeler
 une des trois fonctions d'initialisation suivantes avant d'utiliser 
 la derniere, bien sur... La premiere est appelee automatiquement au
 demarrage de Cassio et met des valeurs par defaut QUI NE CORRESPONDENT
 PAS FORCEMENT AUX VALEURS DES COEFFICIENTS STOCKEES DANS LES PREFERENCES :-( }
procedure InitialiseModeleLineaireValeursPotables;
procedure AjusteModeleLineaireFinaleAvecStat(var TotalNbPartiesOK,TotalSommeDesEcarts : SInt32);
procedure AjusteModeleLineaireFinale;
function  NoteCassioEnScoreFinal(note : SInt32) : SInt32;

{diverses fonctions}
procedure TestRegressionLineaire;
procedure HistogrammeValeursTheoriquesDansRapport;
procedure DessineNuageDePointsRegression;
function ValeurEvaluationDeCassioPourNoirDeLaPartie(nroRefPartie : SInt32;nroDuCoup : SInt16; var ok : boolean; var position : plateauOthello) : SInt32;
function MoyenneDesEvaluationsDesPartiesAScoreTheorique(quelScoreTheorique : SInt16; 
                                                        var nbPartiesFoireuses,nbPartiesOK : SInt32;
                                                        var valMin,valMax : SInt32;
                                                        var positionMin,positionMax : plateauOthello;
                                                        var nroRefMin,nroRefMax : SInt32;
                                                        var SommeDesEcarts,SommeDesCarres : SInt32;
                                                        var mediane : SInt32) : SInt32;
procedure MoyenneDeTelScoreTheoriqueDansRapport(quelScoreTheorique : SInt32;PositionsExtremesDansRapport : boolean);
procedure HistogrammeDesMoyennesParScoreTheoriqueDansRapport;


IMPLEMENTATION







USES UnitEvaluation,UnitAccesStructuresNouvFormat,UnitUtilitaires,UnitNouvelleEval,
     UnitRapport,UnitNouveauFormat,UnitSuperviseur,UnitMoindresCarres,UnitMacExtras,
     UnitServicesDialogs,UnitStrategie,SNStrings;




const noteImpossible = -32000;
const minValMediane = -7500;
      maxValMediane = 7500;
type TableDistribution = array[minValMediane..maxValMediane] of SInt16;


var moyenneDesValeursPourCeScore: array[0..64] of SInt32;
    medianeDesValeursPourCeScore: array[0..64] of SInt32;





procedure InitialiseModeleLineaireValeursPotables;
var i : SInt32;
begin
  for i := 0 to 64 do
    begin
      moyenneDesValeursPourCeScore[i] := kModeleNonAjustePourCeScore;
      medianeDesValeursPourCeScore[i] := kModeleNonAjustePourCeScore;
    end;
  moyenneDesValeursPourCeScore[14] := -5700;
  moyenneDesValeursPourCeScore[32] := 0;
  moyenneDesValeursPourCeScore[50] := 4816;
  medianeDesValeursPourCeScore[14] := -5392;
  medianeDesValeursPourCeScore[32] := 0;
  medianeDesValeursPourCeScore[50] := 4816;
end;


procedure plotRepereRegression;
const maxvaleur=8000;
var oldport : grafPtr;
    a,b,haut,larg : SInt32;
    s : str255;
    i : SInt16; 
begin
  if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);
      
      larg := QDGetPortBound().right div 2;
      haut := QDGetPortBound().bottom div 2;
      
      {axe horizontal en bas}
      Moveto(0,haut+32*7);
      Lineto(larg*2,haut+32*7);
      
      {axe horizontal en haut}
      Moveto(0,haut-32*7);
      Lineto(larg*2,haut-32*7);
      
      {axe vertical au milieu}
      Moveto(larg,haut-32*7);
      Lineto(larg,haut+32*7);
      
      {axe vertical a gauche}
      Moveto(0,haut-32*7);
      Lineto(0,haut+32*7);
      
      {axe vertical a droite}
      Moveto(2*larg,haut-32*7);
      Lineto(2*larg,haut+32*7);
      
      for i := -8 to 8 do
        begin
          s := NumEnString(i*1000);
          
          a := larg + ((i*1000*larg) div maxValeur);
          b := haut + 32*7;
          Moveto(a,b-2);
          Line(0,5);
          Moveto(a-(StringWidth(s) div 2),b+12);
          DrawString(s);
          
          a := larg + ((i*1000*larg) div maxValeur);
          b := haut - 32*7;
          Moveto(a,b-2);
          Line(0,5);
          Moveto(a-(StringWidth(s) div 2),b-4);
          DrawString(s);
        end;
      
      for i := 2 to 62 do
        if not(odd(i)) then
        begin
          s := NumEnString(i);
          b := haut + (32-i)*7;
          
          Moveto(-2,b);
          Line(5,0);
          Moveto(5,b+5);
          DrawString(s);
          
          
          Moveto(2*larg-2,b);
          Line(5,0);
          Moveto(2*larg-15,b+5);
          DrawString(s);
        end;
      
      SetPort(oldport);
    end;
end;

procedure plotPointRegression(scoreTheorique,valeur : SInt32);
const maxValeur=8000;
var oldport : grafPtr;
    a,b,haut,larg : SInt32;
    
begin
  if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);
      
      larg := QDGetPortBound().right div 2;
      haut := QDGetPortBound().bottom div 2;
      
      a := larg + ((valeur*larg) div maxValeur);
      b := haut - (scoreTheorique -32)*7 + (Random() mod 3);
      
      
      {
      Moveto(a-1,b-1);
      Lineto(a+1,b+1);
      Moveto(a-1,b+1);
      Lineto(a+1,b-1);
      }
      Moveto(a,b);
      Line(0,0);
      
      SetPort(oldport);
    end;
end;

procedure DessineCarreBlancCeScoreTheorique(scoreTheorique,valeur : SInt32);
const maxValeur=8000;
var oldport : grafPtr;
    a,b,haut,larg : SInt32;
    myRect : rect;
begin
  if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);
      
      larg := QDGetPortBound().right div 2;
      haut := QDGetPortBound().bottom div 2;
      
      a := larg + ((valeur*larg) div maxValeur);
      b := haut - (scoreTheorique -32)*7;
      
      
      SetRect(myRect,a-3,b-3,a+3,b+3);
      EraseRect(myRect);
      FillRect(myrect,whitePattern);
      FrameRect(myrect);
      
      SetPort(oldport);
    end;
end;


procedure DessineCourbeDistibution(quelScoreTheorique : SInt16; var c:TableDistribution);
const maxValeur=8000;
var oldport : grafPtr;
    a,b,haut,larg,basCourbe,j : SInt32;
    myRect : rect;
    s : str255;
    tableEcran:TableDistribution;
begin
  if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);
      
      
      
      larg := QDGetPortBound().right div 2;
      haut := QDGetPortBound().bottom div 2;
      basCourbe := QDGetPortBound().bottom;
      
      SetRect(myRect,0,haut+32*7+12,2*larg,basCourbe);
      FillRect(myRect,whitePattern);
      
      s := NumEnString(quelScoreTheorique);
      Moveto(2,basCourbe);
      DrawString(s);
      
      for j := minValMediane to maxValMediane do tableEcran[j] := 0;
      for j := minValMediane to maxValMediane do 
        begin
          a := (j*larg) div maxValeur;
          if a<minValMediane then a := minValMediane;
          if a>maxValMediane then a := maxValMediane;
          tableEcran[a] := tableEcran[a]+c[j];
        end;
      
      for j := minValMediane+4 to maxValMediane-4 do 
          begin
            a := larg + j;
            b := basCourbe - (tableEcran[j-4]+
                            tableEcran[j-3]+
                            tableEcran[j-2]+
                            tableEcran[j-1]+
                            tableEcran[j]+
                            tableEcran[j+1]+
                            tableEcran[j+2]+
                            tableEcran[j+3]+
                            tableEcran[j+4]) ;
            Moveto(a,b);
            Line(1,0);
            Line(0,-1);
            Line(-1,0);
          end;
      
      SetPort(oldport);
    end;
end;


procedure DessinePointsRegressionCeScoreTheorique(quelScoreTheorique : SInt16; var mediane : SInt32;avecDessinCourbeDistribution : boolean);
var j,valeur : SInt32;
    ok : boolean;
    c:TableDistribution;
    nbPartiesOK,quantileMedian : SInt32;
    position : plateauOthello;
begin
  for j := minValMediane to maxValMediane do c[j] := 0;
  nbPartiesOK := 0;
  
  for j := 1 to nbPartiesActives do
    if GetScoreTheoriqueParNroRefPartie(j)=quelScoreTheorique then
      begin
        valeur := ValeurEvaluationDeCassioPourNoirDeLaPartie(j,40,ok,position);
        if ok then 
          begin
            plotPointRegression(quelScoreTheorique,valeur);
            
            inc(nbPartiesOK);
            if valeur<minValMediane then valeur := minValMediane;
            if valeur>maxValMediane then valeur := maxValMediane;
            inc(c[valeur]);
          end;
      end;
  
  
  if avecDessinCourbeDistribution then DessineCourbeDistibution(quelScoreTheorique,c);
  
  {calcul de la mediane}
  mediane := noteImpossible;
  quantileMedian := nbPartiesOK div 2;
  for j := minValMediane+1 to maxValMediane do c[j] := c[j-1]+c[j];
  for j := minValMediane to maxValMediane do
    if c[j]>quantileMedian then
      begin
        mediane := j;
        leave;
      end;
end;

procedure DessineMedianeCeScoreTheorique(quelScoreTheorique,mediane : SInt32);
begin
  if mediane<>noteImpossible then
    DessineCarreBlancCeScoreTheorique(quelScoreTheorique,mediane);
end;



procedure HistogrammeValeursTheoriquesDansRapport;
var kmin,kmax : SInt32;
    i,j : SInt32;
    c : array[-1000..1000] of SInt32;
begin
  kmin := 0; kmax := 64;
  for i := kmin to kmax do c[i] := 0;
  for j := 1 to nbPartiesActives do 
    inc(c[GetScoreTheoriqueParNroRefPartie(j)]);
  for i := 0 to 64 do
     WriteLnstringandnumDansRapport('theorique['+NumEnString(i)+']=',c[i]);
end;




function ValeurEvaluationDeCassioPourNoirDeLaPartie(nroRefPartie : SInt32;ApresQuelCoup : SInt16; var ok : boolean; var position : plateauOthello) : SInt32;
var s60 : PackedThorGame; 
    trait : SInt32;
    nbNoir,nbBlanc : SInt32;
    jouables : plBool;
    frontiere : InfoFrontRec;
    note,nbEvalsRecursives : SInt32;
begin
  ok := false;
  note := noteImpossible;
  
  ValeurEvaluationDeCassioPourNoirDeLaPartie := 0;
  if (nroRefPartie>=1) & (nroRefPartie<=nbPartiesActives) then
    begin
      ExtraitPartieTableStockageParties(nroRefPartie,s60);
      
      if CalculePositionEtTraitApres(s60,ApresQuelCoup,position,trait,nbBlanc,nbNoir) then
        begin
          Calcule_Valeurs_Tactiques(position,true);
          CarteFrontiere(position,frontiere);
          CarteJouable(position,jouables);
          if trait = pionNoir
            then note := Evaluation(position,trait,nbBlanc,nbNoir,jouables,frontiere,true,-30000,30000,nbEvalsRecursives)
            else note := -Evaluation(position,trait,nbBlanc,nbNoir,jouables,frontiere,true,-30000,30000,nbEvalsRecursives);
          
          ok := true;
          ValeurEvaluationDeCassioPourNoirDeLaPartie := note;
        end;
    end;
end;


function MoyenneDesEvaluationsDesPartiesAScoreTheorique(quelScoreTheorique : SInt16; 
                                                        var nbPartiesFoireuses,nbPartiesOK : SInt32;
                                                        var valMin,valMax : SInt32;
                                                        var positionMin,positionMax : plateauOthello;
                                                        var nroRefMin,nroRefMax : SInt32;
                                                        var sommeDesEcarts,sommeDesCarres : SInt32;
                                                        var mediane : SInt32) : SInt32;
var somme,valeur,j : SInt32;
    ecart,quantileMedian : SInt32;
    c:TableDistribution;
    ok : boolean;
    position : plateauOthello;
begin
  somme := 0;
  sommeDesEcarts := 0;
  sommeDesCarres := 0;
  nbPartiesFoireuses := 0;
  nbPartiesOK := 0;
  valMin := 1000000;
  valMax := -1000000;
  nroRefMin := 0;
  nroRefMax := 0;
  mediane := noteImpossible;
  for j := minValMediane to maxValMediane do c[j] := 0;
  
  for j := 1 to nbPartiesActives do
    if GetScoreTheoriqueParNroRefPartie(j)=quelScoreTheorique then
      begin
        valeur := ValeurEvaluationDeCassioPourNoirDeLaPartie(j,40,ok,position);
        if not(ok)
          then 
            begin
              inc(nbPartiesFoireuses);
            end
          else
            begin
              inc(nbPartiesOK);
              somme := somme+valeur;
              if valeur<valMin then 
                begin
                  valMin := valeur;
                  positionMin := position;
                  nroRefMin := j;
                end;
              if valeur>valMax then 
                begin
                  valMax := valeur;
                  positionMax := position;
                  nroRefMax := j;
                end;
              
              ecart := Abs(quelScoreTheorique-NoteCassioEnScoreFinal(valeur));
              if ecart>20 then ecart := 20;
              
              sommeDesEcarts := sommeDesEcarts+ecart;
              sommeDesCarres := sommeDesCarres+ecart*ecart;
              
              if valeur<minValMediane then inc(c[minValMediane]) else
              if valeur>maxValMediane then inc(c[maxValMediane]) else
                inc(c[valeur]);
            end;
      end;
  if (nbPartiesOk > 0) 
    then
      begin
        MoyenneDesEvaluationsDesPartiesAScoreTheorique := (somme div nbPartiesOk);
        
        {calcul de la mediane}
			  quantileMedian := nbPartiesOK div 2;
			  for j := minValMediane+1 to maxValMediane do c[j] := c[j-1]+c[j];
			  for j := minValMediane to maxValMediane do
			    if c[j]>quantileMedian then
			      begin
			        mediane := j;
			        leave;
			      end;

      end
    else
      begin
        MoyenneDesEvaluationsDesPartiesAScoreTheorique := noteImpossible;
      end;
end;


procedure MoyenneDeTelScoreTheoriqueDansRapport(quelScoreTheorique : SInt32;PositionsExtremesDansRapport : boolean);
var moyenne,valMin,valMax : SInt32;
    nbPartiesOk,nbPartiesFoireuses : SInt32;
    sommeDesEcarts,sommeDesCarres : SInt32;
    mediane : SInt32;
    positionMin,positionMax : plateauOthello;
    nroPartieMaximun,nroPartieMinimum : SInt32;
    s : str255;
begin
  Superviseur(40);
  InitialiseModeleLineaireValeursPotables;
  
  moyenne := MoyenneDesEvaluationsDesPartiesAScoreTheorique(quelScoreTheorique,nbPartiesFoireuses,nbPartiesOK,valMin,valMax,positionMin,positionMax,nroPartieMinimum,nroPartieMaximun,sommeDesEcarts,sommeDesCarres,mediane);
  if nbPartiesOK <> 0 then
    begin
      WritelnDansRapport('th='          + NumEnString(quelScoreTheorique)+
                   { '  Foir='      + NumEnString(nbPartiesFoireuses)+ }
                     '  N='         + NumEnString(nbPartiesOK)+  
                   {'  tot='        + NumEnString(nbPartiesFoireuses+nbPartiesOK)+}
                     '  moy='       + NumEnString(moyenne)+
                     '  med='       + NumEnString(mediane)+
                     '  min='       + NumEnString(valMin)+
                     '  max='       + NumEnString(valMax)+
                     '  ·Ecarts='   + NumEnString(sommeDesEcarts)+
                     '  ·Ecarts/N=' + NumEnString(((100*sommeDesEcarts) div nbPartiesOK) div 100)+'.'+NumEnString((100*sommeDesEcarts div nbPartiesOK) mod 100)+
                     '  ·Carres='   + NumEnString(sommeDesCarres) );
      if PositionsExtremesDansRapport then
        begin
          if (quelScoreTheorique <= 32) & (valMax>=0) then
            begin
              WritelnStringAndNumDansRapport('score='+NumEnString(quelScoreTheorique)+' mais eval=',valMax);
              WritelnPositionDansRapport(positionMax);
              
              s := GetNomTournoiAvecAnneeParNroRefPartie(nroPartieMaximun,29);
              WriteDansRapport(s+'  ');
	            s := GetNomJoueurNoirParNroRefPartie(nroPartieMaximun);
	            WriteDansRapport(s+'  ');
	            s := GetNomJoueurBlancParNroRefPartie(nroPartieMaximun);
	            WritelnDansRapport(s);
            end;
          if (quelScoreTheorique >= 32) & (valMin<=0) then
            begin
              WritelnStringAndNumDansRapport('score='+NumEnString(quelScoreTheorique)+' mais eval=',valMin);
              WritelnPositionDansRapport(positionMin);
              s := GetNomTournoiAvecAnneeParNroRefPartie(nroPartieMinimum,29);
              WriteDansRapport(s+'  ');
	            s := GetNomJoueurNoirParNroRefPartie(nroPartieMinimum);
	            WriteDansRapport(s+'  ');
	            s := GetNomJoueurBlancParNroRefPartie(nroPartieMinimum);
	            WritelnDansRapport(s);
            end;
        end;
    end;
                     
end;


function NoteCassioEnScoreFinal(note : SInt32) : SInt32;
var aux,valeurEn14,valeurEn50 : SInt32;
begin
  if utilisationNouvelleEval 
    then
      begin
        (*
        aux := RoundToL(note*0.01);
        if aux<-64 then aux := -64;
        if aux>64 then aux := 64;
        NoteCassioEnScoreFinal := 32+ (aux div 2)
        *)
        aux := 32+RoundToL(note*0.005);
        if aux<0 then aux := 0;
        if aux>64 then aux := 64;
        NoteCassioEnScoreFinal := aux;
      end
    else
      begin    
			  if note>0 
			    then
			      begin
			        {valeurEn50 := (moyenneDesValeursPourCeScore[50]+medianeDesValeursPourCeScore[50]) div 2;}
			        valeurEn50 := medianeDesValeursPourCeScore[50];
			        if note < valeurEn50
			          then
			            begin
			              aux := (valeurEn50 div 36);
			              NoteCassioEnScoreFinal := 32+ (((note+aux)*18) div valeurEn50);
			            end
			          else
			            begin
			              aux := 50 + ((note-valeurEn50+175) div 350);
			              if aux>64 then aux := 64;
			              NoteCassioEnScoreFinal := aux;
			            end;
			      end
			    else
			      begin
			        {valeurEn14 := (moyenneDesValeursPourCeScore[14]+medianeDesValeursPourCeScore[14]) div 2;}
			        valeurEn14 := medianeDesValeursPourCeScore[14];
			        if note > valeurEn14 
			          then
			            begin
			              aux := ((-valeurEn14) div 36);
			              NoteCassioEnScoreFinal := 32 - (((aux-note)*18) div (-valeurEn14));
			            end
			          else
			            begin
			              aux := 14 - ((valeurEn14-note+175) div 350);
			              if aux<0 then aux := 0;
			              NoteCassioEnScoreFinal := aux;
			            end;
			      end;
		  end;
end;


procedure DessineNuageDePointsRegression;
var score,mediane : SInt32;
begin
  plotRepereRegression;
  Superviseur(40);
  for score := 0 to 64 do
    begin
      DessinePointsRegressionCeScoreTheorique(score,mediane,true);
      DessineMedianeCeScoreTheorique(score,mediane);
      WritelnDansRapport('mediane['+NumEnString(score)+']='+NumEnString(mediane));
    end;
end;


procedure HistogrammeDesMoyennesParScoreTheoriqueDansRapport;
var score : SInt32;
begin
  for score := 0 to 64 do
    MoyenneDeTelScoreTheoriqueDansRapport(score,true);
end;


procedure AjusteModeleLineaireFinaleAvecStat(var TotalNbPartiesOK,TotalSommeDesEcarts : SInt32);
var nbAjustementsMoyenne : SInt16; 
    valMin,valMax : SInt32;
    nbPartiesOk,nbPartiesFoireuses : SInt32;
    sommeDesEcarts,sommeDesCarres : SInt32;
    positionMin,positionMax : plateauOthello;
    numeroMin,numeroMax : SInt32;
  
  
  procedure AjusterModeleDeCeScore(score : SInt16);
  var moyenne,mediane : SInt32;
  begin
    moyenne := MoyenneDesEvaluationsDesPartiesAScoreTheorique(score,nbPartiesFoireuses,nbPartiesOK,valMin,valMax,positionMin,positionMax,numeroMin,numeroMax,sommeDesEcarts,sommeDesCarres,mediane);
    moyenneDesValeursPourCeScore[score] := moyenne;
    medianeDesValeursPourCeScore[score] := mediane;
    if nbPartiesOK <> 0 then
		  WritelnDansRapport('th='           + NumEnString(score)+
		                   { '  Foir='       + NumEnString(nbPartiesFoireuses)+ }
		                     '  N='          + NumEnString(nbPartiesOK)+  
		                   {'  tot='         + NumEnString(nbPartiesFoireuses+nbPartiesOK)+}
		                     '  moy='        + NumEnString(moyenne)+
		                     '  med='        + NumEnString(mediane)+
		                     '  min='        + NumEnString(valMin)+
		                     '  max='        + NumEnString(valMax){+
		                     '  ·Ecarts='    + NumEnString(sommeDesEcarts)+
		                     '  ·Ecarts/N='  + NumEnString(((100*sommeDesEcarts) div nbPartiesOK) div 100)+'.'+NumEnString((100*sommeDesEcarts div nbPartiesOK) mod 100)+
		                     '  ·Carres='    + NumEnString(sommeDesCarres)});
		TotalNbPartiesOK := TotalNbPartiesOK+nbPartiesOK;                  
    TotalSommeDesEcarts := TotalSommeDesEcarts+sommeDesEcarts;
  end;
  
begin
  TotalNbPartiesOK := 0;
  TotalSommeDesEcarts := 0;
  
  if (nbPartiesActives<=0) then
    begin
      AlerteSimple('Vous devez charger des parties de la base pour Ajuster le modle linŽaire de Cassio ! (note : si vous ne savez pas ce qu''est la base Wthor, laissez tomber :-) )');
      exit(AjusteModeleLineaireFinaleAvecStat);
    end;

  Superviseur(40);
  InitialiseModeleLineaireValeursPotables;
  
  WritelnDansRapport('Ajustement du modle linŽaire de finaleÉ');
  
  WritelnDansRapport('Calcul du terme constant ˆ l''aide des parties au score thŽorique 32É');
  
  nbAjustementsMoyenne := 0;
  repeat
    inc(nbAjustementsMoyenne);
    {WritelnStringAndNumDansRapport('penalitePourLeTrait=',penalitePourLeTrait);}
    AjusterModeleDeCeScore(32);
    {penalitePourLeTrait := penalitePourLeTrait+MyTrunc(1.0*moyenneDesValeursPourCeScore[32]);}
    penalitePourLeTrait := penalitePourLeTrait+MyTrunc(1.0*medianeDesValeursPourCeScore[32]);
  until (nbAjustementsMoyenne>=7) | 
        {(Abs(moyenneDesValeursPour32)<=1)}
        (Abs(medianeDesValeursPourCeScore[32])<=1);
              
  {WritelnStringAndNumDansRapport('penalitePourLeTrait=',penalitePourLeTrait);}
            
  WritelnDansRapport('Calcul de la pente ˆ l''aide des parties aux scores thŽoriques 14 et 50É');
  
  AjusterModeleDeCeScore(14);
  AjusterModeleDeCeScore(50);
  
  WritelnDansRapport('');
  WritelnDansRapport('Apres Ajustement, voici quelques statistiquesÉ');
  
  
  TotalNbPartiesOK := 0;
  TotalSommeDesEcarts := 0;
  
  AjusterModeleDeCeScore(14);
  AjusterModeleDeCeScore(19);
  AjusterModeleDeCeScore(21);
  AjusterModeleDeCeScore(24);
  AjusterModeleDeCeScore(29);
  AjusterModeleDeCeScore(32);
  AjusterModeleDeCeScore(35);
  AjusterModeleDeCeScore(40);
  AjusterModeleDeCeScore(43);
  AjusterModeleDeCeScore(45);
  AjusterModeleDeCeScore(50);
  
  
end;

procedure AjusteModeleLineaireFinale;
var N,SigmaEcart : SInt32;
begin
   WritelnDansRapport('');
   AjusteModeleLineaireFinaleAvecStat(N,SigmaEcart);
   if N <> 0 then 
      WritelnDansRapport('  Nombres parties prises en compte='          + NumEnString(N)+  
                         '  ·Ecarts='    + NumEnString(SigmaEcart)+
                         '  ·Ecarts/N='  + NumEnString(((100*SigmaEcart) div N) div 100)+'.'+NumEnString((100*SigmaEcart div N) mod 100));
   WritelnDansRapport('');
end;


procedure TestRegressionLineaire;
begin
  {HistogrammeValeursTheoriquesDansRapport;}
  {HistogrammeDesMoyennesParScoreTheoriqueDansRapport;}
  
  {DessineNuageDePointsRegression;}
  
  DoRegressionLineaireCoeffsCassio(40);
  
end;




end.
