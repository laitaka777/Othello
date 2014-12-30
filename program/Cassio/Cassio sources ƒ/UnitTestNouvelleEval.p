UNIT UnitTestNouvelleEval;


INTERFACE











procedure TestNouvelleEval;

IMPLEMENTATION







USES UnitNouvelleEval,UnitChi2NouvelleEval,UnitMinimisationNouvelleEval,UnitRapport,SNStrings;


procedure EcritPointeursOccurencesDansRapport;
var n,k,stage,adresse : SInt32;
begin
  for stage := 0 to kNbMaxGameStage do
    begin
      adresse := SInt32(occurences.Edges2X[stage]);
      if adresse=0
        then WritelnDansRapport('occurencesEdges2X['+NumEnString(stage)+'] = NIL')
        else 
          begin
            n := DimensionDuPointMultidimensionnel(occurences.Edges2X[stage]);
            WriteStringAndNumDansRapport('occurencesEdges2X['+NumEnString(stage)+']=',adresse);
            WritelnStringAndNumDansRapport('   taille=',n);
          end;
          
      for k := 1 to kNbPatternsDansEval do
        begin
          adresse := SInt32(occurences.Pattern[k,stage]);
          if adresse=0
            then WritelnDansRapport('occurencesPattern['+NumEnString(k)+','+NumEnString(stage)+'] = NIL')
            else 
              begin
                n := DimensionDuPointMultidimensionnel(occurences.Pattern[k,stage]);
                WriteStringAndNumDansRapport('occurencesPattern['+NumEnString(k)+','+NumEnString(stage)+']=',adresse);
                WritelnStringAndNumDansRapport('   taille=',n);
              end;
        end;
    end;
end;





procedure TestNouvelleEval;
var i,k,n,long,nroPattern,stage : SInt32;
    debutScan,scan,count : SInt32;
    chi2,tolerance : TypeReel;
    err : OSErr;
    s : str255;
begin {$UNUSED i,k,n,long,nroPattern,stage,debutScan,scan,count,chi2,tolerance,s}
  
  {
  chi2 := CalculeChi2EtGradient(vecteurEvaluation,gradientEvaluation);
  WritelnStringAndReelDansRapport('chi^2=',chi2,10);
  }
  
  {
  SetAutoVidageDuRapport(true);
  SetEcritToutDansRapportLog(true);
  WritelnDansRapport('');
  WritelnDansRapport('');
  }
  
  
  err := LitVecteurEvaluationSurLeDisque('Occurences(166415)',occurences);
  WritelnStringAndNumDansRapport('LitVecteurOccurencesSurLeDisque = ',err);
  
  
  
  (*
  SetAutoVidageDuRapport(true);
  SetEcritToutDansRapportLog(true);
  CollecteOccurencesPatternDApresListe;
  s := 'Occurences('+NumEnString(nbPartiesDansOccurences)+')';
  err := EcritVecteurEvaluationSurLeDisque(s,0,occurences);
  WritelnStringAndNumDansRapport('EcritVecteurEvaluationSurLeDisque(occurences) = ',err);
  *)
  
  
  s := 'BestEvaluation';
  err := LitVecteurEvaluationSurLeDisque(s,vecteurEvaluation);
  WritelnStringAndNumDansRapport('LitVecteurEvaluationSurLeDisque("'+s+'") = ',err);
  {if err=0 then
    begin
      SetUtilisationNouvelleEval(true);
    end;
  }
  
  
  
  (*
  WritelnDansRapport('Tri occurences :');
  TrieEvalEtEcritDansRapport(occurences);
  WritelnDansRapport('Tri vecteurEvaluation :');
  TrieEvalEtEcritDansRapport(vecteurEvaluation);
  DivisionVecteurEval(vecteurEvaluation,occurences,vecteurTriEval.rapportOccurence);
  WritelnDansRapport('Tri vecteurTriEval.rapportOccurence :');
  TrieEvalEtEcritDansRapport(vecteurTriEval.rapportOccurence);
  ValeurAbsolueVecteurEval(vecteurTriEval.rapportOccurence,vecteurTriEval.rapportOccurence);
  WritelnDansRapport('Tri valeur absolue de vecteurTriEval.rapportOccurence :');
  TrieEvalEtEcritDansRapport(vecteurTriEval.rapportOccurence);
  *)
  
  
  {
  VecteurEvalIntegerToVecteurEval(vecteurEvaluationInteger,vecteurEvaluation);
  EcritVecteurMobiliteDansRapport(vecteurEvaluation);
  }
  
  
  (*
  SmoothThisEvaluation(vecteurEvaluation,occurences);
  CalculeEvalPatternsInexistantParEchangeCouleur(vecteurEvaluation,occurences);
  AbaisseEvalPatternsRares(vecteurEvaluation,occurences,10.0,8.0);
  
  s := 'BestEvaluation(smoothed)';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnStringAndNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,robuste,smoothed) = ',err);
  *)
  
  
  {
  err := LitVecteurEvaluationIntegerSurLeDisque('Evaluation de Cassio',vecteurEvaluationInteger);
  WritelnStringAndNumDansRapport('LitVecteurEvaluationSurLeDisque(''Evaluation de Cassio'') = ',err);
  if err=0 then
    begin
      SetUtilisationNouvelleEval(true);
    end;
  }
  
  
  
  
  
  VecteurEvalToVecteurEvalInteger(vecteurEvaluation,vecteurEvaluationInteger);
  
  
  s := 'Fichiers auxiliaires:Evaluation de Cassio';
  err := EcritVecteurEvaluationIntegerSurLeDisque(s,volumeRefCassio,vecteurEvaluationInteger);
  WritelnStringAndNumDansRapport('EcritVecteurEvaluationSurLeDisque(''Evaluation de Cassio'') = ',err);
  
  
  
  
(*  
  s := 'BestEvalRobuste(smoothed)';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnStringAndNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,robuste,smoothed) = ',err);
  EcritVecteurMobiliteDansRapport(vecteurEvaluation);
*)
  
  
  
  
  
  SetAutoVidageDuRapport(true);
  SetEcritToutDansRapportLog(true);
 
 {evaluation par le chi2, non robuste}
  (*
  estimationRobuste := false;
  tolerance := 0.0001;
  MetCoeffsMobiliteEtFrontiereConstantsDansEvaluation(vecteurEvaluation);
  ConjugateGradientChi2(vecteurEvaluation,tolerance,count,chi2,true);
  WritelnStringAndNumDansRapport('sortie de ConjugateGradientChi2, nbiter=',count);
  WritelnDansRapport('minimum='+ReelEnStringAvecDecimales(chi2,10));
  
  
  s := 'BestEval(non rob,chi2='+ReelEnStringAvecDecimales(chi2,5)+')';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnStringAndNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,non robuste) = ',err);
  
  
  SmoothThisEvaluation(vecteurEvaluation,occurences);
  CalculeEvalPatternsInexistantParEchangeCouleur(vecteurEvaluation,occurences);
  AbaisseEvalPatternsRares(vecteurEvaluation,occurences,10.0,8.0);
  s := 'BestEvalNonRobuste(smoothed)';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnStringAndNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,non robuste,smoothed) = ',err);
  *)
  
  
 {evaluation par la somme des valeurs absolues des deviation, robuste}
  (*
  estimationRobuste := true;
  tolerance := 0.0001;
  MetCoeffsMobiliteEtFrontiereConstantsDansEvaluation(vecteurEvaluation);
  ConjugateGradientChi2(vecteurEvaluation,tolerance,count,chi2,true);
  WritelnStringAndNumDansRapport('sortie de ConjugateGradientChi2, nbiter=',count);
  WritelnDansRapport('minimum='+ReelEnStringAvecDecimales(chi2,10));
  s := 'BestEval(robuste,chi2='+ReelEnStringAvecDecimales(chi2,5)+')';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnStringAndNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,robuste) = ',err);
  
  
  SmoothThisEvaluation(vecteurEvaluation,occurences);
  CalculeEvalPatternsInexistantParEchangeCouleur(vecteurEvaluation,occurences);
  AbaisseEvalPatternsRares(vecteurEvaluation,occurences,10.0,8.0);
  s := 'BestEvalRobuste(smoothed)';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnStringAndNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,robuste,smoothed) = ',err);
  *)
 
  
  
  
  
  
  (*
  CollecteStatistiquesOccurencesPatternDApresListe;
  RandomizeTimer;
  stage := 0;
  nroPattern := kAdresseBlocCoinH8;
  long := DimensionDuPointMultidimensionnel(occurences.Pattern[nroPattern,stage]);
  for i := 1 to 50 do
    begin
      debutScan := RandomLongintEntreBornes(1,long);
      count := 0;
      for k := 0 to long do
        begin
          scan := debutScan+k;
          if scan>long then scan := scan-long;
          
          n := RoundToL(occurences.Pattern[nroPattern,stage]^[scan]+0.25);
          if n=i then
            begin
              inc(count);
              Writeln13SquareCornerAndStringDansRapport(scan-decalagePourPattern[nroPattern],NumEnString(n)+' occurences');
              WritelnDansRapport('');
              if count=3 then leave;
            end;
        end;
    end;
  *)
  
  
  
  {
  for i := 1 to 34 do
    WritelnNumDansRapport(decalagePourPattern[i]);}
  
  
  SetAutoVidageDuRapport(false);
  SetEcritToutDansRapportLog(false);
end;



END.