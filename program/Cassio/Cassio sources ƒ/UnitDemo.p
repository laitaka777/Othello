UNIT UnitDemo;


INTERFACE







uses MacTypes;


procedure InitUnitDemo;
procedure LibereMemoireUnitDemo;

procedure AlignerTestsFinales(NumeroDeb,numeroFin : SInt16; TypeFinaleAlgoReference,typeFinaleAlgoFast : SInt16);
procedure DoDemo(niveau1,niveau2 : SInt32;avecAttente,avecSauvegardePartieDansListe : boolean);



IMPLEMENTATION








USES UnitActions,UnitOth1,UnitFenetres,UnitMilieuDePartie,UnitNouvelleEval,UnitUtilitaires,UnitGestionDuTemps,
     UnitBibl,UnitServicesMemoire,UnitSuperviseur,UnitJeu,UnitPotentiels,UnitBords,UnitEntreesSortiesGraphe,
     UnitListe,UnitEntreesSortiesListe,UnitTroisiemeDimension,UnitApprentissagePartie,UnitRapport,
     UnitUtilitairesFinale,UnitPhasesPartie,UnitAffichageReflexion,UnitFinaleFast,UnitArbreDeJeuCourant,
     UnitBitboardAlphaBeta,SNStrings,UnitNormalisation,UnitPackedThorGame;


const kNombrePartiesParMatchDansDemo = 12;
      kNombreDePartiesParMatchDuTournoi = 12;
      kNombreMaxDeviationsTesteesParPasse = 625;
      kFaireCetteDeviation = 1;
      kIndexJoueurSansDeviation = 312;

(* dans chaque passe *)
const kNombreDeviationTesteesSurPourcentage = 15;
      kNombreDeviationTesteesSurPions       = 0;
      kNombreViellesDeviationTestees        = 0;
      kNombreDeviationsDansLeTournoi        = 15;

type DeviationRecord = record
                         nombreParties : SInt32;
                         pions : SInt32;
                         nbreGains : SInt32;
                         flags : SInt32;
                       end;
     DeviationArray = array[-2..2,-2..2,-2..2,-2..2] of DeviationRecord;
     DeviationArrayPtr = ^DeviationArray;
     
var deviations : DeviationArrayPtr;
    table_de_tri_des_deviations : array[0..624] of SInt32;
    deviations_a_tester : 
      record
        numeros : array[1..kNombreMaxDeviationsTesteesParPasse] of SInt32;
        cardinal : SInt32;
      end;
    deja_au_moins_un_match_en_memoire : boolean;
    
    tournoiDeviations : record
                          nbParticipants : SInt32;
                          indexParticipant : array[0..kNombreDeviationsDansLeTournoi] of SInt32;
                          scoreParticipant : array[0..kNombreDeviationsDansLeTournoi] of extended;
                          numeroRonde : SInt32;
                          tableauTouteRonde : array[0..kNombreDeviationsDansLeTournoi] of SInt32;
                       end;


procedure InitUnitDemo;
begin
  deviations := NIL;
  deja_au_moins_un_match_en_memoire := false;
end;


procedure LibereMemoireUnitDemo;
begin
  if (deviations <> NIL) then DisposeMemoryPtr(Ptr(deviations));
end;



procedure AlignerTestsFinales(numeroDeb,numeroFin : SInt16; TypeFinaleAlgoReference,typeFinaleAlgoFast : SInt16);
label sortie;
const nbDiagrammes = 100;
      decalageVertAffichage = 120;
      nbAlgos = 20;
      faireAlgoStandard = true;
      noMinLigneAff = 1;   {cette ligne et la suivante : nb d'algos testés en plus du normal}
      noMaxLigneAff = 0;   {mettre à 0 pour ne calculer que l'algo normal}
var numeroTest,increment : SInt16; 
    s,nomFichier : str255;
    tempsCumules : array[0..nbAlgos] of SInt32;
    StatDiagramme : array[1..nbDiagrammes] of record
	                                              meilleurTemps : SInt32;
	                                              meilleurNbGeneres : SInt32;
	                                              deltaNoeudsReference : SInt32;
	                                              NbNoeudsReference : SInt32;
	                                              ref : SInt16; 
	                                              valeur : SInt16; 
                                              end;
    tick : SInt32;
    choixX,meiDef,score : SInt32;
    prof,nbBlanc,nbNoir : SInt32;
    noLigneAff : SInt16; 
    nbreNoeudsAlgoNormal : SInt32; 
    nbDiagDejaAffiches : SInt16; 
    HumCtreHumArrivee : boolean;
    erreurES : OSErr;
    oldInterruption : SInt16; 
    i : SInt16; 
    positionGagnante : boolean;
    
 procedure GetStringDeLigneAff(noLigneAff : SInt16; var s : str255);
 var i,k : SInt16; 
 begin {$unused i}
   NumToString(noLigneAff,s);
   
   
   effetspecial := true;
      
   case noLigneAff of
     1: begin
          nroEffetspecial := 1;
          
        end;
     2: begin
          nroEffetspecial := 2;
          
        end;
     3: begin
          nroEffetspecial := 3;
          
        end;
     4: begin
          nroEffetspecial := 4;
            
        end;
     5: begin
          nroEffetspecial := 5;
            
        end;
     6: begin
          nroEffetspecial := 6;
          
          for k := 0 to 64 do
            EvaluationSuffisantePourFastestFirst[k] := 4500;
            
        end;
     7: begin
          nroEffetspecial := 7;
          
          for k := 0 to 64 do
            EvaluationSuffisantePourFastestFirst[k] := 4200;
            
        end;
     8: begin
          nroEffetspecial := 8;
          
          for k := 0 to 64 do
            EvaluationSuffisantePourFastestFirst[k] := 3900;
            
        end;
     9: begin
          nroEffetspecial := 9;
          
          for k := 0 to 64 do
            EvaluationSuffisantePourFastestFirst[k] := 3600;
            
        end;
     10: begin
          nroEffetspecial := 10;
          
          for k := 0 to 64 do
            EvaluationSuffisantePourFastestFirst[k] := 3300;
            
        end;
     11: begin
          nroEffetspecial := 11;
          
          for k := 0 to 64 do
            EvaluationSuffisantePourFastestFirst[k] := 3100;
            
        end;
     12: begin
          nroEffetspecial := 12;
          
          for k := 0 to 64 do
            EvaluationSuffisantePourFastestFirst[k] := 2800;
            
        end;
     13: begin
          nroEffetspecial := 13;
          
          for k := 0 to 64 do
            EvaluationSuffisantePourFastestFirst[k] := 2500;
            
        end;
   end;
   s := '[s='+NumEnString(nroEffetspecial)+'] :';
   
   if VerifieAssertionsDeFinale() then;
   
   
   {s := 'alg='+s+' :';}
 end;
 
 procedure AfficheResultats;
   const interligne=10;
   var i,y : SInt16; 
   begin
      PrepareTexteStatePourHeure;
      nbDiagDejaAffiches := 0;
      for i := 1 to nbDiagrammes do
        with StatDiagramme[i] do
        if ref<>-1 then
        begin
          inc(nbDiagDejaAffiches);
          y := decalageVertAffichage+nbDiagDejaAffiches*interligne;
          WriteStringAndNumAt('dia=',i,2,y);
          WriteStringAndNumAt('v=',valeur,40,y);
          WriteStringAndReelAt('sec=',1.0*meilleurTemps/60,80,y);
          WriteStringAndNumAt('algo=',ref,155,y);
          WriteStringAndNumEnSeparantLesMilliersAt('norm=',NbNoeudsReference,210,y);
          WriteStringAndNumEnSeparantLesMilliersAt('nœuds=',meilleurNbGeneres,325,y);
          WriteStringAndNumEnSeparantLesMilliersAt('∆=',deltaNoeudsReference,440,y);
        end;
    end;
 
 function NombreKilosNoeudsGeneres() : SInt32;
 begin     
   NombreKilosNoeudsGeneres := nbreToursNoeudsGeneresFinale*1000000 + 
                               ((nbreNoeudsGeneresFinale + 499) div 1000);
 end;
 
begin
  SetAutoVidageDuRapport(true);
  SetEcritToutDansRapportLog(true);
  
  oldInterruption := GetCurrentInterruption();
  EnleveCetteInterruption(oldInterruption);
  HumCtreHumArrivee := HumCtreHum;
  
  MemoryFillChar(@tempsCumules,sizeof(tempsCumules),chr(0));
  for i := 1 to nbDiagrammes do
    begin
      StatDiagramme[i].meilleurTemps := 1000000000;
      StatDiagramme[i].meilleurNbGeneres := 1000000000;
      StatDiagramme[i].ref := -1;
    end;
  
  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
  ResetStatistiquesOrdreOptimumDesCases;
  {$ENDC}
  
  if NumeroDeb=numeroFin then increment := 0;
  if NumeroDeb<numeroFin then increment := 1;
  if NumeroDeb>numeroFin then increment := -1;
  numeroTest := NumeroDeb-increment;
  repeat
   numeroTest := numeroTest+increment;
   if (interruptionReflexion = pasdinterruption) & not(Quitter) then
    begin
      NumToString(numeroTest,s);
      if numeroTest<10 
        then nomFichier := GetWDName(volumeRefCassio)+'Tests finale:TestFinale  '+s
        else nomFichier := GetWDName(volumeRefCassio)+'Tests finale:TestFinale '+s;
      erreurES := OuvrirFichierPartieFormatCassio(nomFichier,false);
      if erreurES<>NoErr 
        then goto sortie;
      
        
      if HumCtreHum then DoChangeHumCtreHum;
      InfosTechniquesDansRapport := true;
      couleurMacintosh := aQuiDeJouer;
      nbBlanc := nbreDePions[pionBlanc];
      nbNoir := nbreDePions[pionNoir];
      prof := 64 - nbBlanc - nbNoir;
      EnleveCetteInterruption(GetCurrentInterruption());      
      
      derniertick := TickCount()-tempsDesJoueurs[aQuiDeJouer].tick;
      LanceChrono;
      tempsPrevu := 10;
      tempsAlloue := TempsPourCeCoup(nbreCoup,couleurMacintosh);
      if not(RefleSurTempsJoueur) & (aQuiDeJouer=couleurMacintosh)
        then EcritJeReflechis(aQuiDeJouer);
      ReinitilaliseInfosAffichageReflexion;
      EffaceReflexion;
      
      case TypeFinaleAlgoReference of
        ReflGagnant          : DoFinaleGagnante(false);
        ReflGagnantExhaustif : DoFinaleGagnante(false);
        ReflParfait          : DoFinaleOptimale(false);
        ReflParfaitExhaustif : DoFinaleOptimale(false);
        otherwise              DoFinaleGagnante(false);
      end;
      vaDepasserTemps := false;
      phaseDeLaPartie := CalculePhasePartie(nbreCoup);
      Superviseur(nbBlanc+pionNoir-4);
      if not(calculPrepHeurisFait) then
        Initialise_table_heuristique(jeuCourant);
      noLigneAff := 0;
      EnleveCetteInterruption(GetCurrentInterruption());
            
      EssaieSetPortWindowPlateau;
      PrepareTexteStatePourHeure;
      WriteStringAndReelAt('cumulé normal=',1.0*tempsCumules[0]/60,250,10);
      for noLigneAff := noMinLigneAff to noMaxLigneAff do
        begin
          GetStringDeLigneAff(noLigneAff,s);
          WriteStringAndNumAt('a=',noLigneAff,225,10+noLigneAff*10);
          WriteStringAndReelAt('cumulé '+s,1.0*tempsCumules[noLigneAff]/60,250,
                                    10+noLigneAff*10);
        end;
        
      
      AfficheResultats;
      PrepareTexteStatePourHeure;
      WriteStringAndNumAt('dia=',numeroTest,2,decalageVertAffichage+(nbDiagDejaAffiches+1)*10);
      
      
      if (interruptionReflexion = pasdinterruption) then
        begin
          EssaieSetPortWindowPlateau;
          WriteStringAt('temps normal=                     ',0,10);
        end;
      
      
      
      Superviseur(nbNoir+nbBlanc-4);
      SetUtilisationNouvelleEval(true);
      EnleveCetteInterruption(GetCurrentInterruption());
      
      tick := TickCount();      
      
      if faireAlgoStandard then
        begin
		      SetEffetSpecial(false);
		      discretisationEvaluationEstOK := false;
		      InitValeursStandardAlgoFinale;
		      positionGagnante := CoupGagnant(choixX,meiDef,aQuiDeJouer,prof,nbblanc,nbnoir,GetCurrentNode(),jeuCourant,emplJouable,
		                              frontiereCourante,NIL,score,true,false,TypeFinaleAlgoReference);
		    end;      
      
      if (interruptionReflexion = pasdinterruption) then
        begin
          tick := TickCount()-tick;
          
          EssaieSetPortWindowPlateau;
          PrepareTexteStatePourHeure;
          WriteStringAndReelAt('temps normal=',1.0*tick/60,0,10);
          WriteStringAndNumEnSeparantLesMilliersAt('nb=',NombreKilosNoeudsGeneres(),130,10);
          
          nbreNoeudsAlgoNormal := NombreKilosNoeudsGeneres();
          
          StatDiagramme[numeroTest].deltaNoeudsReference := 0;
          if noMaxLigneAff>=noMinLigneAff
            then StatDiagramme[numeroTest].meilleurNbGeneres := MaxLongint
            else StatDiagramme[numeroTest].meilleurNbGeneres := 0;
          StatDiagramme[numeroTest].NbNoeudsReference := NombreKilosNoeudsGeneres();
          StatDiagramme[numeroTest].valeur := score;
          if tick<StatDiagramme[numeroTest].meilleurTemps then
                begin
                  StatDiagramme[numeroTest].meilleurTemps := tick;
                  StatDiagramme[numeroTest].ref := 0;
                end;
          tempsCumules[0] := tempsCumules[0]+tick;
          
          
         {for i := 0 to nbTablesHashExactes-1 do}
         {for i := 0 to 0 do
             WritelnStringAndReelDansRapport('taux_remplissage['+NumEnString(i)+']=',TauxDeRemplissageHashExacte(i,false),5);
          EcritStatistiquesCollisionsHashTableDansRapport;
          }
        end;
      
      {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
      EcritStatistiquesOrdreOptimumDesCasesDansRapport;
      {$ENDC}
      
      for noLigneAff := noMinLigneAff to noMaxLigneAff do
        begin
          
          discretisationEvaluationEstOK := false;
          InitValeursStandardAlgoFinale;
          GetStringDeLigneAff(noLigneAff,s);
          
          if (interruptionReflexion = pasdinterruption) then
            begin
              EssaieSetPortWindowPlateau;
              WriteStringAt('temps '+s+'                      ',0,10+noLigneAff*10);
            end;
          Superviseur(nbNoir+nbBlanc-4);
          SetUtilisationNouvelleEval(true);
          tick := TickCount();
          
          
          
          
          if (interruptionReflexion = pasdinterruption) then
          positionGagnante := CoupGagnant(choixX,meiDef,aQuiDeJouer,prof,nbblanc,nbnoir,GetCurrentNode(),jeuCourant,emplJouable,
                                   frontiereCourante,NIL,score,true,false,TypeFinaleAlgoFast);
                              
          if (interruptionReflexion = pasdinterruption) then
            begin
              tick := TickCount()-tick;
              
              EssaieSetPortWindowPlateau;
              PrepareTexteStatePourHeure;
              WriteStringAndReelAt('temps '+s,1.0*tick/60,0,10+noLigneAff*10);
              WriteStringAndNumEnSeparantLesMilliersAt('nb=',NombreKilosNoeudsGeneres(),130,10+noLigneAff*10);
              
              with StatDiagramme[numeroTest] do
                begin
                  if tick<meilleurTemps then 
                     begin
                       meilleurTemps := tick;
                       ref := noLigneAff;
                     end;
                  if (NombreKilosNoeudsGeneres() < meilleurNbGeneres) then
                    begin
                      meilleurNbGeneres := NombreKilosNoeudsGeneres();
                      deltaNoeudsReference := NombreKilosNoeudsGeneres()-nbreNoeudsAlgoNormal;
                    end;
                  valeur := score;
                end;
             
              
              tempsCumules[noLigneAff] := tempsCumules[noLigneAff]+tick;
              
              
             {for i := 0 to nbTablesHashExactes-1 do}
             {for i := 0 to 0 do
                WritelnStringAndReelDansRapport('taux_remplissage['+NumEnString(i)+']=',TauxDeRemplissageHashExacte(i,false),5);
              EcritStatistiquesCollisionsHashTableDansRapport;
              }
              
            end;
          
          {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
          EcritStatistiquesOrdreOptimumDesCasesDansRapport;
          {$ENDC}
        end;
        
     
      
      EssaieSetPortWindowPlateau;
      PrepareTexteStatePourHeure;
      WriteStringAndNumAt('                                                 ',
                           0,0,10);
      for noLigneAff := noMinLigneAff to noMaxLigneAff do
        WriteStringAndNumAt('                                                  ',
                           0,0,10+noLigneAff*10);
                         
      WriteStringAndReelAt('cumulé normal=',1.0*tempsCumules[0]/60,250,10);
      for noLigneAff := noMinLigneAff to noMaxLigneAff do
        begin
          GetStringDeLigneAff(noLigneAff,s);
          WriteStringAndNumAt('a=',noLigneAff,225,10+noLigneAff*10);
          WriteStringAndReelAt('cumulé : '+s,1.0*tempsCumules[noLigneAff]/60,250,
                                    10+noLigneAff*10);
        end;
        
      AfficheResultats;
                         
     end; 
   until (numeroTest=numeroFin) | (interruptionReflexion <> pasdinterruption) | Quitter;
   
   {if not(Quitter) then
     begin
       AttendFrappeClavier;
     end;}
sortie:

   SetEffetSpecial(false);
   InitValeursStandardAlgoFinale;
   
   SetEcritToutDansRapportLog(false);
   if HumCtreHum<>HumCtreHumArrivee then DoChangeHumCtreHum;
   LanceInterruption(oldInterruption,'AlignerTestsFinales');
   Quitter := false;
     
end;




(* renvoie un entier entre 0 et 624 *)
function IndexTriTableauDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  
  case dev_frontiere of
     -2 : aux := aux + 0;
     -1 : aux := aux + 125;
     0  : aux := aux + 250;
     1  : aux := aux + 375;
     2  : aux := aux + 500;
  end;
  
  case dev_minimisation of
     -2 : aux := aux + 0;
     -1 : aux := aux + 25;
     0  : aux := aux + 50;
     1  : aux := aux + 75;
     2  : aux := aux + 100;
  end;
  
  case dev_mobilite of
     -2 : aux := aux + 0;
     -1 : aux := aux + 5;
     0  : aux := aux + 10;
     1  : aux := aux + 15;
     2  : aux := aux + 20;
  end;
  
  case dev_penalitetrait of
     -2 : aux := aux + 0;
     -1 : aux := aux + 1;
     0  : aux := aux + 2;
     1  : aux := aux + 3;
     2  : aux := aux + 4;
  end;
  
  IndexTriTableauDeviation := aux;
end;


(* A partir d'un entier entre 0 et 624, renvoie le quadruplet des chiffres en base 5 *)
procedure IndexTriEnQuadrupletDeviations(index : SInt32; var dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32);
var aux : SInt32;
begin
  dev_frontiere := 0;
  dev_minimisation := 0;
  dev_mobilite := 0;
  dev_penalitetrait := 0;
  
  if (index >= 0) & (index <= 624) then
    begin
      aux := index mod 5;
      dev_penalitetrait := aux - 2;
      
      index := index div 5;
      aux := index mod 5;
      dev_mobilite := aux - 2;
      
      index := index div 5;
      aux := index mod 5;
      dev_minimisation := aux - 2;
      
      index := index div 5;
      aux := index mod 5;
      dev_frontiere := aux - 2;
      
    end;
end;


procedure VideTableauDeviations;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  if (deviations <> NIL) then
    begin
      for deviation_frontiere := -2 to 2 do
        for deviation_minimisation := -2 to 2 do
          for deviation_mobilite := -2 to 2 do
            for deviation_penalitetrait := -2 to 2 do
              with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
                begin
                  nombreParties := 0;
                  pions := 0;
                  nbreGains := 0;
                  flags := 0;
                end;
      deja_au_moins_un_match_en_memoire := false;
    end;
end;


function PeutAllouerTableauDeviations() : boolean;
begin
  if (deviations = NIL) then
    begin
      deviations := DeviationArrayPtr(AllocateMemoryPtr(SizeOf(DeviationArray)));
      VideTableauDeviations;
    end;
  PeutAllouerTableauDeviations := (deviations <> NIL);
end;


procedure DesallouerMemoireTableauDeviations;
begin
  if (deviations <> NIL) then DisposeMemoryPtr(Ptr(deviations));
  deviations := NIL;
end;


function GetBoolean(flagBits : SInt32;mask : SInt32) : boolean;
begin
  GetBoolean := (BitAnd(flagBits,mask) <> 0);
end;

procedure SetBoolean(var flagBits : SInt32;mask : SInt32;whichBoolean : boolean);
begin
  if whichBoolean
    then flagBits := BitOr(flagBits,mask)
    else flagBits := BitOr(flagBits,mask) - mask;
end;


function GetDoitFaireCetteDeviation(deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait : SInt32) : boolean;
begin
  if deviations <> NIL
    then GetDoitFaireCetteDeviation := GetBoolean(deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait].flags, kFaireCetteDeviation)
    else GetDoitFaireCetteDeviation := false;
end;


procedure SetDoitFaireCetteDeviation(flag : boolean;deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait : SInt32);
begin
  if deviations <> NIL then
    begin
      SetBoolean(deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait].flags, kFaireCetteDeviation, flag);
    end;
end;


procedure AjouterResultatMatchPourCetteDeviation(index : SInt32;delta_nombreParties,delta_pions,delta_nbreGains : SInt32);
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          nombreParties := nombreParties + delta_nombreParties;
          pions         := pions         + delta_pions;
          nbreGains     := nbreGains     + delta_nbreGains;
        end;
      deja_au_moins_un_match_en_memoire := true;
    end;
end;


function PourcentageDeCetteDeviation(index : SInt32) : extended;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  PourcentageDeCetteDeviation := 0.0;
  
  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          if (nombreParties <> 0) then
            PourcentageDeCetteDeviation := 100.0 * (nbreGains / nombreParties);
        end;
    end;
end;

function NombrePionsDeCetteDeviation(index : SInt32) : SInt32;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  NombrePionsDeCetteDeviation := 0;
  
  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          NombrePionsDeCetteDeviation := pions;
        end;
    end;
end;

function NombrePartiesDeCetteDeviation(index : SInt32) : SInt32;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  NombrePartiesDeCetteDeviation := 0;
  
  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          NombrePartiesDeCetteDeviation := nombreParties;
        end;
    end;
end;

function NombrePionsMoyenDeCetteDeviation(index : SInt32) : extended;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  NombrePionsMoyenDeCetteDeviation := 0.0;
  
  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          if (nombreParties <> 0) then
            NombrePionsMoyenDeCetteDeviation := (pions / nombreParties);
        end;
    end;
end;


function LecturePourTriDeviations(index : SInt32) : SInt32;
begin
  LecturePourTriDeviations := table_de_tri_des_deviations[index];
end;

procedure AffectionPourTriDeviations(index,element : SInt32);
begin
  table_de_tri_des_deviations[index] := element;
end;

function OrdrePourcentageGlobalPourTriDeviation(element1,element2 : SInt32) : boolean;
var v1,v2 : extended;
begin
  v1 := PourcentageDeCetteDeviation(element1) - 0.00*NombrePartiesDeCetteDeviation(element1);
  v2 := PourcentageDeCetteDeviation(element2) - 0.00*NombrePartiesDeCetteDeviation(element2);
  
  if (abs(v1 - v2) > 0.001) 
    then OrdrePourcentageGlobalPourTriDeviation := (v1 < v2)
    else OrdrePourcentageGlobalPourTriDeviation := (NombrePionsMoyenDeCetteDeviation(element1) <= NombrePionsMoyenDeCetteDeviation(element2));
end;

function OrdreNombreMoyenDePionsPourTriDeviation(element1,element2 : SInt32) : boolean;
var v1,v2 : extended;
begin
  v1 := NombrePionsMoyenDeCetteDeviation(element1);
  v2 := NombrePionsMoyenDeCetteDeviation(element2);
  
  if (abs(v1 - v2) > 0.001) 
    then OrdreNombreMoyenDePionsPourTriDeviation := (v1 < v2)
    else OrdreNombreMoyenDePionsPourTriDeviation := (PourcentageDeCetteDeviation(element1) <= PourcentageDeCetteDeviation(element2));
end;


function OrdrePlusVieuxPourTriDeviation(element1,element2 : SInt32) : boolean;
var v1,v2 : SInt32;
begin
  v1 := NombrePartiesDeCetteDeviation(element1);
  v2 := NombrePartiesDeCetteDeviation(element2);
  
  if (v1 <> v2) 
    then OrdrePlusVieuxPourTriDeviation := (v1 > v2)
    else OrdrePlusVieuxPourTriDeviation := OrdrePourcentageGlobalPourTriDeviation(element1,element2);
end;


procedure AfficherDeviationDansRapport(rang,index : SInt32);
var dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32;
    s1 : str255;
begin
  IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
      
  WriteStringAndNumDansRapport('#',rang);
  WriteStringAndNumDansRapport(' • ',index);
  WriteStringAndNumDansRapport('•(',dev_frontiere);
  WriteStringAndNumDansRapport(',',dev_minimisation);
  WriteStringAndNumDansRapport(',',dev_mobilite);
  WriteStringAndNumDansRapport(',',dev_penalitetrait);
  WriteDansRapport(') => ');
  
  
  s1 := ' (->'+ReelEnString(PourcentageDeCetteDeviation(index)) + '%';
  s1 := s1+'•'+ReelEnString(NombrePionsMoyenDeCetteDeviation(index));
  s1 := s1+'•'+NumEnString(NombrePartiesDeCetteDeviation(index)) + ')';
  WriteDansRapport(s1);
  
  WritelnDansRapport('');

end;


procedure SelectionnerUnChampion;
var t,index : SInt32;
    dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32;
    compteur : SInt32;
begin

(* Initialisation d'une passe : on ne garde aucune deviation *)
  for dev_frontiere := -2 to 2 do
    for dev_minimisation := -2 to 2 do
      for dev_mobilite := -2 to 2 do
        for dev_penalitetrait := -2 to 2 do
          SetDoitFaireCetteDeviation(false,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
  deviations_a_tester.cardinal := 0;
  for t := 1 to kNombreMaxDeviationsTesteesParPasse do
    deviations_a_tester.numeros[t] := -1;
  
  
  WritelnDansRapport('#Selection du champion…');
  
  index := 289;  (* Le champion ! *)
  index := kIndexJoueurSansDeviation;
  IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
  
  if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
    begin
      inc(compteur);
      SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
      AfficherDeviationDansRapport(0,index);
      
      if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
        begin
          inc(deviations_a_tester.cardinal);
          deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
        end;
    end;
end;


procedure TrierMeilleuresDeviations;
var t,index : SInt32;
    dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32;
    compteur : SInt32;
begin

  (* on teste d'abord si on est tout au debut... *)
  if not(deja_au_moins_un_match_en_memoire) then
    begin
      (* a la premiere passe, on essaye toutes les deviations *)
      for dev_frontiere := -2 to 2 do
        for dev_minimisation := -2 to 2 do
          for dev_mobilite := -2 to 2 do
            for dev_penalitetrait := -2 to 2 do
              SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
      deviations_a_tester.cardinal := kNombreMaxDeviationsTesteesParPasse;
      for t := 1 to kNombreMaxDeviationsTesteesParPasse do
        deviations_a_tester.numeros[t] := t-1;
      exit(TrierMeilleuresDeviations);
    end;


  (* Initialisation d'une passe : on ne garde aucune deviation *)
  for dev_frontiere := -2 to 2 do
    for dev_minimisation := -2 to 2 do
      for dev_mobilite := -2 to 2 do
        for dev_penalitetrait := -2 to 2 do
          SetDoitFaireCetteDeviation(false,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
  deviations_a_tester.cardinal := 0;
  for t := 1 to kNombreMaxDeviationsTesteesParPasse do
    deviations_a_tester.numeros[t] := -1;
          
          
  (* Selection éventuelle des déviations n'ayant jamais été testées *)
  compteur := 0;
  for t := 0 to 624 do
    begin
      index := t;
      IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
      
      if (NombrePartiesDeCetteDeviation(index) = 0) then
        if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
          begin
            if (compteur <= 0) then WritelnDansRapport('#Selection des deviations non encore testées…');
          
            inc(compteur);
            SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
            AfficherDeviationDansRapport(t,index);
            
            if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
              begin
                inc(deviations_a_tester.cardinal);
                deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
              end;
              
          end;
    end;
          
  (* A chaque passe, garder les 15 meilleures deviations... *)
  GeneralQuickSort(0,624,LecturePourTriDeviations,AffectionPourTriDeviations,OrdrePourcentageGlobalPourTriDeviation);
  
  WritelnDansRapport('#Selection des meilleurs pourcentages…');
  compteur := 0;
  for t := 0 to 624 do
    if (compteur < kNombreDeviationTesteesSurPourcentage) then
      begin
        index := LecturePourTriDeviations(t);
        IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
        
        if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
          begin
            inc(compteur);
            SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
            AfficherDeviationDansRapport(t,index);
            
            if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
              begin
                inc(deviations_a_tester.cardinal);
                deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
              end;
          end;
      end;
  
  (* ...et les 5 meilleurs totaux de pions... *)
  GeneralQuickSort(0,624,LecturePourTriDeviations,AffectionPourTriDeviations,OrdreNombreMoyenDePionsPourTriDeviation);
  
  WritelnDansRapport('#Selection des meilleures moyennes de pions…');
  compteur := 0;
  for t := 0 to 624 do
    if (compteur < kNombreDeviationTesteesSurPions) then
      begin
        index := LecturePourTriDeviations(t);
        IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
        
        if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
          begin
            inc(compteur);
            SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
            AfficherDeviationDansRapport(t,index);
          
            if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
              begin
                inc(deviations_a_tester.cardinal);
                deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
              end;
              
          end;
      end;
   
  (* ...et 5 deviations parmis les plus vieilles *)
  GeneralQuickSort(0,624,LecturePourTriDeviations,AffectionPourTriDeviations,OrdrePlusVieuxPourTriDeviation);
  
  WritelnDansRapport('#Selection de quelques vieilles deviations…');
  compteur := 0;
  for t := 0 to 624 do
    if (compteur < kNombreViellesDeviationTestees) then
      begin
        index := LecturePourTriDeviations(t);
        IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
        
        if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
          begin
            inc(compteur);
            SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
            AfficherDeviationDansRapport(t,index);
            
            if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
              begin
                inc(deviations_a_tester.cardinal);
                deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
              end;
          
          end;
      end;
               
end;


function PeutParserFichierRapportLog() : boolean;
var fichierRapport : FichierTEXT;
    filename : str255;
    s : str255;
    erreurES : SInt16; 
    longueur,gains,index,pions : SInt32;
    s1,s2,s3,s4,s5,s6,reste : str255;
    i1,i2,i3,i4 : str255;
    oldParsingSet : SetOfChar;
    dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32;
begin

  WritelnDansRapport('# Entree dans PeutParserFichierRapportLog'); 

  PeutParserFichierRapportLog := false;
  filename := 'Rapport.log';
  erreurES := FichierTexteDeCassioExiste(filename,fichierRapport);
  if erreurES<>NoErr then exit(PeutParserFichierRapportLog);
  erreurES := OuvreFichierTexte(fichierRapport);
  if erreurES<>NoErr then exit(PeutParserFichierRapportLog);
  
  repeat
    erreurES := ReadlnDansFichierTexte(fichierRapport,s);
    if (s<>'') & (erreurES=NoErr) then
      if (s[1]<>'#') & (Pos('(front,min,mob,pen)',s) = 1) then
        begin
          longueur := Length(s);
          
          
          Parser6(s,s1,s2,s3,s4,s5,s6,reste);
          
          (* calcul de l'index dans le tableau des deviations *)
          oldParsingSet := GetParsingCaracterSet();
        	SetParsingCaracterSet(['(',',',')']);
        	Parser4(s3,i1,i2,i3,i4,reste);
        	SetParsingCaracterSet(oldParsingSet);
        	ChaineToLongint(i1,dev_frontiere);
        	ChaineToLongint(i2,dev_minimisation);
        	ChaineToLongint(i3,dev_mobilite);
        	ChaineToLongint(i4,dev_penalitetrait);
        	index := IndexTriTableauDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
          
          (* calcul du nombre de parties gagnees sur les kNombrePartiesParMatchDansDemo du match *)
          if (s5 = '0')   then gains := 0 else
          if (s5 = '0.5') then gains := 1 else
          if (s5 = '1')   then gains := 2 else
          if (s5 = '1.5') then gains := 3 else
          if (s5 = '2')   then gains := 4 else
          if (s5 = '2.5') then gains := 5 else
          if (s5 = '3')   then gains := 6 else
          if (s5 = '3.5') then gains := 7 else
          if (s5 = '4')   then gains := 8 else
          if (s5 = '4.5') then gains := 9 else
          if (s5 = '5')   then gains := 10 else
          if (s5 = '5.5') then gains := 11 else
          if (s5 = '6')   then gains := 12;
          
          (* calcul du nombre de pions recoltes dans le match *)
          ChaineToLongint(s6,pions);
          
          AjouterResultatMatchPourCetteDeviation(index,kNombrePartiesParMatchDansDemo,pions,gains);
          
          (* on ecrit quelques lignes au hasard pour verifier que l'on parse bien... *)
          if false & (index >= 168) & (index <= 168) then
            begin
              WritelnDansRapport(s);
              WriteStringAndNumDansRapport('••••••••• ',index);
              WriteStringAndNumDansRapport('•(',dev_frontiere);
              WriteStringAndNumDansRapport(',',dev_minimisation);
              WriteStringAndNumDansRapport(',',dev_mobilite);
              WriteStringAndNumDansRapport(',',dev_penalitetrait);
              WriteDansRapport(') => ');
              
              NumToString(gains div 2,s1);
              if odd(gains) then s1 := s1+'.5';
              NumToString(pions,s2);
              WriteDansRapport(s1+'  '+s2+ '  ');
              if (kNombrePartiesParMatchDansDemo) <> 0 then
                begin
                  s1 := ReelEnString(100.0*gains/(1.0*(kNombrePartiesParMatchDansDemo)));
                  WriteDansRapport(s1+' %');
                end;
              
              s1 := ' (->'+ReelEnString(PourcentageDeCetteDeviation(index)) + '%';
              s1 := s1+'•'+ReelEnString(NombrePionsMoyenDeCetteDeviation(index));
              s1 := s1+'•'+NumEnString(NombrePartiesDeCetteDeviation(index)) + ')';
              WriteDansRapport(s1);
              
              WritelnDansRapport('');
    
            end;
          
        end;
  until (erreurES<>NoErr) | EOFFichierTexte(fichierRapport,erreurES);
  erreurES := FermeFichierTexte(fichierRapport);
  
  WritelnStringAndNumDansRapport('#sortie de PeutParserFichierRapportLog, erreurES = ',erreurES);

  PeutParserFichierRapportLog := (erreurES = NoErr);
end;


procedure FaireTournerParticipantsTournoiToutesRondes(nroRonde : SInt32);
var k,r,temp : SInt32;
begin
  with tournoiDeviations do
    begin
      (* recopier la liste des partipants *)
      for k := 0 to nbParticipants-1 do
        tableauTouteRonde[k] := k;
        
      (* faire tourner tout le monde, sauf le pivot *)
      for r := 1 to nroRonde-1 do
        begin
          temp := tableauTouteRonde[nbParticipants-1];
          for k := nbParticipants-1 downto 2 do
            tableauTouteRonde[k] := tableauTouteRonde[k-1];
          tableauTouteRonde[1] := temp;
        end;
          
    end;
end;



procedure DoDemo(niveau1,niveau2 : SInt32;avecAttente,avecSauvegardePartieDansListe : boolean);
var fanny : array[1..2] of SInt32;
    scoreCumule : array[1..2] of SInt32;
    scoreSurDeuxParties : array[1..2] of SInt32;
    nbreDePionsPartiePrecedente : array[pionNoir..pionBlanc] of SInt32;
    compteurPartie,local1,local2 : SInt32;
    s1,s2 : string;
    quitterDemo,tempo3D : boolean;
    localMin : SInt32;
    UnContreDeux,premierAppele : boolean;
    nbCoupsImposes : SInt32;
    nbCoupsIdentiques : SInt32;
    LongueurOuvertureAleatoire : SInt32;
    foobool : boolean;
    
    Coeffinfluence1 : extended;
    Coefffrontiere1 : extended;
    CoeffEquivalence1 : extended;
    Coeffcentre1 : extended;
    Coeffgrandcentre1 : extended;
    Coeffdispersion1 : extended;
    Coeffminimisation1 : extended;
    CoeffpriseCoin1 : extended;
    CoeffdefenseCoin1 : extended;
    CoeffValeurCoin1 : extended;
    CoeffValeurCaseX1 : extended;
    CoeffPenalite1 : extended;
    CoeffMobiliteUnidirectionnelle1 : extended;
    avecEvaluationTablesDeCoins1 : boolean;  
    
    Coeffinfluence2 : extended;
    Coefffrontiere2 : extended;
    CoeffEquivalence2 : extended;
    Coeffcentre2 : extended;
    Coeffgrandcentre2 : extended;
    Coeffdispersion2 : extended;
    Coeffminimisation2 : extended;
    CoeffpriseCoin2 : extended;
    CoeffdefenseCoin2 : extended;
    CoeffValeurCoin2 : extended;
    CoeffValeurCaseX2 : extended;
    CoeffPenalite2 : extended;
    CoeffMobiliteUnidirectionnelle2 : extended;
    avecEvaluationTablesDeCoins2 : boolean;
    
    finDePartieVitesseMactemp : SInt32;
    finDePartieOptimaleVitesseMactemp : SInt32;

    PremiersCoups : array[0..65] of SInt32;
    i : SInt32;
    GainTheorique:str7;
    ChainePartie:str120;
    PremiersCoupsOk : boolean;
    utiliseGrapheApprentissageTemp : boolean;
    ecritureDansRapportTemp : boolean;
    avecBiblTemp : boolean;
    utilisateurVeutDiscretiserEvaluationTemp : boolean;
    OuverturesAleatoires : boolean;
    ouvertureEquilibree : PackedThorGame;
    oldInterruption : SInt16; 
    tempoCassioVarieSesCoups : boolean;
    partieRec:t_PartieRecNouveauFormat;
    nroReference : SInt32;
    diagonaleInversee : boolean;
    
    nroPasse : SInt32;
    deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
    index_deviation_courante : SInt32;
    scoreDuJoueur2 : extended;

 procedure EcritScoreMatch(ScoreUnAGauche : boolean);
 var oldport : grafPtr;
     posV : SInt32;
     ligneRect : rect;
   begin
     if windowPlateauOpen then
       begin
         GetPort(oldPort);
         SetPortByWindow(wPlateauPtr);
         
         PrepareTexteStatePourHeure;
         
         if ScoreUnAGauche
            then 
              begin
                local1 := aireDeJeu.right+30;
                local2 := aireDeJeu.right+130;
              end
            else
              begin
                local1 := aireDeJeu.right+130;
                local2 := aireDeJeu.right+30;
              end;  
          localMin := local1;
          if local2<localMin then localMin := local2;
          
          
          posV := 75;
          SetRect(ligneRect,localMin,posV-12,512,posV+10);
          EraseRect(ligneRect);
          
          
          Moveto(local2,posV);
          NumToString(niveau2,s1);
          s1 := 'prof '+s1+' (n°2)';
          DrawString(s1);
          Moveto(local2,posV+10);
          NumToString(fanny[2] div 2,s1);
          if odd(fanny[2]) then s1 := s1+'.5';
          NumToString(scorecumule[2],s2);
          DrawString(s1+'   '+s2);
          if (fanny[2]+fanny[1]) <> 0 then
            begin
              Moveto(local2,posV+20);
              s1 := ReelEnString(100.0*fanny[2]/(1.0*(fanny[2]+fanny[1])));
              DrawString(s1+' %');
            end;
          
          Moveto(local1,posV);
          NumToString(niveau1,s1);
          s1 := 'prof '+s1+' (n°1)';
          DrawString(s1);
          Moveto(local1,posV+10);
          NumToString(fanny[1] div 2,s1);
          if odd(fanny[1]) then s1 := s1+'.5';
          NumToString(scorecumule[1],s2);
          DrawString(s1+'   '+s2);
          if (fanny[2]+fanny[1]) <> 0 then
            begin
              Moveto(local1,posV+20);
              s1 := ReelEnString(100.0*fanny[1]/(1.0*(fanny[2]+fanny[1])));
              DrawString(s1+' %');
            end;
            
          {si c'est la seconde partie d'un match synchro, on ecrit le score de la premiere}
          if (nbreDePionsPartiePrecedente[pionNoir] + nbreDePionsPartiePrecedente[pionBlanc] <> 0) then
            begin
              Moveto(Min(local1,local2),posV+40);
              DrawString('prec : '+NumEnString(nbreDePionsPartiePrecedente[pionNoir]));
              
              Moveto(Max(local1,local2),posV+40);
              DrawString('prec : '+NumEnString(nbreDePionsPartiePrecedente[pionBlanc]));
            end;
          
          SetPort(oldport);
        end;
   end;
 
 
 procedure ResetStatistiquesDuMatch;
  begin
    fanny[1] := 0;fanny[2] := 0;
    scoreCumule[1] := 0;scoreCumule[2] := 0;
    nbreDePionsPartiePrecedente[pionNoir] := 0;
    nbreDePionsPartiePrecedente[pionBlanc] := 0;
  end;
 
 
 procedure ChangeCoefficientDansDemo(var whichCoeff : extended; amplitudeDeviation : SInt32);
 begin
   case amplitudeDeviation of 
      -2 : whichCoeff := 0.66 * whichCoeff;
      -1 : whichCoeff := 0.80 * whichCoeff;
      0  : whichCoeff := 1.0  * whichCoeff;
      1  : whichCoeff := 1.15 * whichCoeff;
      2  : whichCoeff := 1.30 * whichCoeff;
   end;
 end;
 
 
 procedure ChoisitCoefficientsDuMatch(indexJoueur1,indexJoueur2 : SInt32);
 var deviation_frontiere : SInt32;
     deviation_minimisation : SInt32;
     deviation_mobilite : SInt32;
     deviation_penalitetrait : SInt32;
  begin
  
    (* joueur 1 *)
    
    {DoCoefficientsEvaluation;}
    CoefficientsStandard;
    
    IndexTriEnQuadrupletDeviations(indexJoueur1,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
    ChangeCoefficientDansDemo(Coefffrontiere,                 deviation_frontiere);
    ChangeCoefficientDansDemo(Coeffminimisation,              deviation_minimisation);
    ChangeCoefficientDansDemo(CoeffMobiliteUnidirectionnelle, deviation_mobilite);
    ChangeCoefficientDansDemo(CoeffPenalite,                  deviation_penalitetrait);
    
    Coeffinfluence1 := CoeffInfluence; 
    Coefffrontiere1 := Coefffrontiere;
    CoeffEquivalence1 := CoeffEquivalence;
    Coeffcentre1 := Coeffcentre;
    Coeffgrandcentre1 := Coeffgrandcentre;
    Coeffdispersion1 := Coeffbetonnage;
    Coeffminimisation1 := Coeffminimisation;
    CoeffpriseCoin1 := CoeffpriseCoin;
    CoeffdefenseCoin1 := CoeffdefenseCoin;
    CoeffValeurCoin1 := CoeffValeurCoin;
    CoeffValeurCaseX1 := CoeffValeurCaseX;
    CoeffPenalite1 := CoeffPenalite; 
    CoeffMobiliteUnidirectionnelle1 := CoeffMobiliteUnidirectionnelle;
    avecEvaluationTablesDeCoins1 := avecEvaluationTablesDeCoins;
    
    
    
    (* joueur 2 *)
    
    {DoCoefficientsEvaluation;}
    CoefficientsStandard;
    
    
    IndexTriEnQuadrupletDeviations(indexJoueur2,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
    ChangeCoefficientDansDemo(Coefffrontiere,                 deviation_frontiere);
    ChangeCoefficientDansDemo(Coeffminimisation,              deviation_minimisation);
    ChangeCoefficientDansDemo(CoeffMobiliteUnidirectionnelle, deviation_mobilite);
    ChangeCoefficientDansDemo(CoeffPenalite,                  deviation_penalitetrait);
   
    
    Coeffinfluence2 := CoeffInfluence;
    Coefffrontiere2 := Coefffrontiere;
    CoeffEquivalence2 := CoeffEquivalence;
    Coeffcentre2 := Coeffcentre;
    Coeffgrandcentre2 := Coeffgrandcentre;
    Coeffdispersion2 := Coeffbetonnage;
    Coeffminimisation2 := Coeffminimisation;
    CoeffpriseCoin2 := CoeffpriseCoin;
    CoeffdefenseCoin2 := CoeffdefenseCoin;
    CoeffValeurCoin2 := CoeffValeurCoin;
    CoeffValeurCaseX2 := CoeffValeurCaseX;
    Coeffpenalite2 := CoeffPenalite; 
    CoeffMobiliteUnidirectionnelle2 := CoeffMobiliteUnidirectionnelle;
    avecEvaluationTablesDeCoins2 := avecEvaluationTablesDeCoins;
    
  end;
  
  
  
 procedure EcritStatistiquesDuMatchDansRapport;
  var s1,s2 : str255;
  begin
  
    WriteDansRapport('(front,min,mob,pen) = ');
    WriteStringAndNumDansRapport('(',deviation_frontiere);
    WriteStringAndNumDansRapport(',',deviation_minimisation);
    WriteStringAndNumDansRapport(',',deviation_mobilite);
    WriteStringAndNumDansRapport(',',deviation_penalitetrait);
    WriteDansRapport(') => ');
  
    (*
    NumToString(niveau2,s1);
    s1 := 'prof '+s1+' (n°2)';
    WriteDansRapport(s1+'••••');
    *)
    
    NumToString(fanny[2] div 2,s1);
    if odd(fanny[2]) then s1 := s1+'.5';
    NumToString(scorecumule[2],s2);
    WriteDansRapport(s1+'  '+s2+ '  ');
    if (fanny[2]+fanny[1]) <> 0 then
      begin
        s1 := ReelEnString(100.0*fanny[2]/(1.0*(fanny[2]+fanny[1])));
        WriteDansRapport(s1+' %');
      end;
    
    s1 := ' (->'+ReelEnString(PourcentageDeCetteDeviation(index_deviation_courante)) + '%';
    s1 := s1+'•'+ReelEnString(NombrePionsMoyenDeCetteDeviation(index_deviation_courante));
    s1 := s1+'•'+NumEnString(NombrePartiesDeCetteDeviation(index_deviation_courante)) + ')';
    WriteDansRapport(s1);
    
    WritelnDansRapport('');
  end;
  

(* Renvoie le pourcentage du joueur 2 contre 1 *)
function FaireUnMatch(indexJoueur1,indexJoueur2 : SInt32; nbPartiesDansLeMatch : SInt32) : extended;
var i : SInt32;
    lesCasesCEtlesCasesX : SquareSet;
begin

  ChoisitCoefficientsDuMatch(indexJoueur1,indexJoueur2); 
  
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
  FlushEvents(everyEvent,0);
    
  ResetStatistiquesDuMatch;
  
  oldInterruption := GetCurrentInterruption();
  EnleveCetteInterruption(oldInterruption);
  
  {
  VideStatistiquesDeBordsABLocal(essai_bord_AB_local);
  VideStatistiquesDeBordsABLocal(coupure_bord_AB_local);
  }
  
  SetPotentielsOptimums(PositionEtTraitInitiauxStandard());
  {AffichePotentiels;}
  
  compteurPartie := 0;
  while not(quitterDemo | Quitter) & (compteurPartie < nbPartiesDansLeMatch) do
    begin
      
      {EcritStatistiquesDeBordsABLocal;}
      
      compteurPartie := compteurPartie+1; 
      PrepareNouvellePartie(false);
      EnleveCetteInterruption(interruptionSimple);
      
      {if (compteurPartie mod 20=0) then AffichePotentiels;}
      
      if OuverturesAleatoires & odd(compteurPartie) then
        begin
          nbCoupsImposes := 0;
          lesCasesCEtlesCasesX := [12,21,22,17,27,28,71,72,82,77,78,87];
          
          GenereOuvertureAleatoireEquilibree(LongueurOuvertureAleatoire,-400,400,lesCasesCEtlesCasesX,ouvertureEquilibree);
          for i := 1 to LongueurOuvertureAleatoire do 
            premiersCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(ouvertureEquilibree, i, 'FaireUnMatch(1)');
          for i := LongueurOuvertureAleatoire+1 to 60 do 
            premiersCoups[i] := 0;
        end;
      
      while not(gameOver | quitterDemo | Quitter) do 
         begin
            UnContreDeux := (compteurPartie mod 4=1) | (compteurPartie mod 4=0);
            
            
            {UpdatePotentiels(jeuCourant,aQuiDeJouer);}
            
            EcritScoreMatch(UnContreDeux);
            if (UnContreDeux & (aQuiDeJouer = pionNoir)) |
               (not(UnContreDeux) & (aQuiDeJouer = pionBlanc)) 
             then premierAppele := true
             else premierAppele := false;
            
            if premierAppele {n°1}
              then
                begin
                  level := niveau1;
                  if niveau1 >= 0
                    then SetProfImposee(true,'niveau 1 dans DoDemo')
                    else SetProfImposee(false,'niveau 1 dans DoDemo');
                  {SetUtilisationNouvelleEval(false);}
                  
                  {
                  if LitVecteurEvaluationIntegerSurLeDisque('Evaluation de Cassio',vecteurEvaluationInteger)<>NoErr then SysBeep(0);
                  }
                  
                  SetUtilisationNouvelleEval(true);
                  if (indexJoueur1 = kIndexJoueurSansDeviation)
                    then SetEffetSpecial(false)
                    else SetEffetSpecial(true);
                  avecSelectivite                      := false;
                  utilisateurVeutDiscretiserEvaluation := true;
                  if avecEvaluationTablesDeCoins <> avecEvaluationTablesDeCoins1
                    then DoChangeEvaluationTablesDeCoins;
                  CoeffInfluence := Coeffinfluence1;
                  Coefffrontiere := Coefffrontiere1;
                  CoeffEquivalence := CoeffEquivalence1;
                  Coeffcentre := Coeffcentre1;
                  Coeffgrandcentre := Coeffgrandcentre1;
                  Coeffbetonnage := Coeffdispersion1;
                  Coeffminimisation := Coeffminimisation1;
                  CoeffpriseCoin := CoeffpriseCoin1;
                  CoeffdefenseCoin := CoeffdefenseCoin1;
                  CoeffValeurCoin := CoeffValeurCoin1;
                  CoeffValeurCaseX := CoeffValeurCaseX1;
                  CoeffPenalite := CoeffPenalite1;
                  CoeffMobiliteUnidirectionnelle := CoeffMobiliteUnidirectionnelle1;
                  UtiliseGrapheApprentissage := FALSE;
                  avecBibl := not(OuverturesAleatoires);
                  Superviseur(nbreCoup);
                  Initialise_valeurs_bords(-0.5);
                  Initialise_turbulence_bords(true); 
                end
              else           {n°2}
                begin
                  level := niveau2;
                  if niveau2 >= 0
                    then SetProfImposee(true,'niveau 2 dans DoDemo')
                    else SetProfImposee(false,'niveau 2 dans DoDemo');
                    
                  {
                  if LitVecteurEvaluationIntegerSurLeDisque('Evaluation de Cassio',vecteurEvaluationInteger)<>NoErr then SysBeep(0);
                  }
                  
                  SetUtilisationNouvelleEval(true);
                  if (indexJoueur2 = kIndexJoueurSansDeviation) & (indexJoueur1 <> indexJoueur2)
                    then SetEffetSpecial(false)
                    else SetEffetSpecial(true);
                  avecSelectivite                      := false;
                  utilisateurVeutDiscretiserEvaluation := true;
                  if avecEvaluationTablesDeCoins <> avecEvaluationTablesDeCoins2
                    then DoChangeEvaluationTablesDeCoins;
                  CoeffInfluence := Coeffinfluence2;
                  Coefffrontiere := Coefffrontiere2;
                  CoeffEquivalence := CoeffEquivalence2;
                  Coeffcentre := Coeffcentre2;
                  Coeffgrandcentre := Coeffgrandcentre2;
                  Coeffbetonnage := Coeffdispersion2;
                  Coeffminimisation := Coeffminimisation2;
                  CoeffpriseCoin := CoeffpriseCoin2;
                  CoeffdefenseCoin := CoeffdefenseCoin2;
                  CoeffValeurCoin := CoeffValeurCoin2;
                  CoeffValeurCaseX := CoeffValeurCaseX2;
                  CoeffPenalite := CoeffPenalite2;
                  CoeffMobiliteUnidirectionnelle := CoeffMobiliteUnidirectionnelle2;
                  UtiliseGrapheApprentissage := FALSE;
                  avecBibl := not(OuverturesAleatoires);
                  Superviseur(nbreCoup);
                  Initialise_valeurs_bords(-0.5);
                  Initialise_turbulence_bords(true);
                end; 
              
            
            EcritScoreMatch(UnContreDeux);
            if nbreCoup=40 then 
              for i := 1 to 40 do PremiersCoups[i] := GetNiemeCoupPartieCourante(i);
            couleurMacintosh := aQuiDeJouer;
            
            PremiersCoupsOk := true;
            for i := 1 to nbreCoup do
              PremiersCoupsOk := PremiersCoupsOk & (GetNiemeCoupPartieCourante(i)=PremiersCoups[i]);
            PremiersCoupsOk := PremiersCoupsOk & possibleMove[PremiersCoups[nbreCoup+1]];
              
            
            if not(Quitter | quitterDemo) then
              if OuverturesAleatoires & (nbreCoup<LongueurOuvertureAleatoire)
                then DealWithEssai(PremiersCoups[nbreCoup+1],'DoDemo(1)')
                else
		              if premiersCoupsOK & ((nbCoupsImposes>0) & (nbreCoup<nbCoupsImposes))
		                then
		                  DealWithEssai(PremiersCoups[nbreCoup+1],'DoDemo(2)')
		                else
		                  begin
		                    if premiersCoupsOk & 
		                       not(odd(compteurPartie)) &
		                       ((nbreCoup<nbCoupsIdentiques) | PositionCouranteEstDansLaBibliotheque())
		                      then 
		                        DealWithEssai(PremiersCoups[nbreCoup+1],'DoDemo(3)')
		                      else 
		                        begin
		                          if (nbreCoup = 0) | true
		                            then gEntrainementOuvertures.CassioVarieSesCoups := false
		                            else gEntrainementOuvertures.CassioVarieSesCoups := PositionCouranteEstDansGrapheApprentissage();
		                          {JeuMac(level,'DoDemo(3)');}
		                          
		                          {if premierAppele
		                            then
		                              begin
		                                SetPotentielsOptimums(PositionEtTraitCourant());
		                                DealWithEssai(ChoixDeVincenz(PositionEtTraitCourant(),1,false).bestMove,'DoDemo(4)');
		                              end
		                            else
		                              begin
		                                SetPotentielsOptimums(PositionEtTraitCourant());
		                                DealWithEssai(ChoixDeVincenz(PositionEtTraitCourant(),1,false).bestMove,'DoDemo(5)');
		                              end;
		                              }
		                          
		                          
		                          if premierAppele 
		                            then 
		                              begin
		                              
		                                SetUtilisationNouvelleEval(true);
		                                {NiveauJeuInstantane := NiveauClubs;}
		                                
		                                JeuMac(level,'DoDemo(4)');
		                              end
		                            else 
		                              begin
		                                {if UneChanceSur(2)
		                                  then NiveauJeuInstantane := NiveauClubs
		                                  else NiveauJeuInstantane := NiveauExperts;}
		                                  
		                                SetUtilisationNouvelleEval(true);
		                                {NiveauJeuInstantane := NiveauClubs;}
		                                
		                                JeuMac(level,'DoDemo(5)');
		                              end;
		                          
		                          
		                          if HasGotEvent(everyEvent,theEvent,0,NIL) 
														    then TraiteEvenements
														    else TraiteNullEvent(theEvent);
    
		                        end;
		                   end;
         end;
         
      quitterDemo := quitterDemo | Quitter;
      
      
      if avecSauvegardePartieDansListe & gameOver & not(quitterDemo) then 
        foobool := AjouterPartieCouranteDansListe(kNroJoueurCassio,kNroJoueurCassio,kNroTournoiDiversesParties,2001,false,partieRec,nroReference);
        
      
      if avecAttente & not(quitterDemo) then
        begin
          AttendFrappeClavier;
          tempo3D := EnVieille3D();
          SetEnVieille3D(false);
          SetPositionsTextesWindowPlateau;
          DessineDiagramme(GetTailleCaseCourante(),NIL,'DoDemo');
          AfficheScore;
          dernierTick := TickCount();
          Heure(pionNoir);
          Heure(pionBlanc);
          AttendFrappeClavier;
          SetEnVieille3D(tempo3D);
          SetPositionsTextesWindowPlateau;
        end;
      
      {Les cases vides vont au vainqueur}
      if gameOver & not(quitterDemo) then
        begin 
          if (nbredepions[pionNoir ] > nbredepions[pionBlanc]) then nbredepions[pionNoir ] := 64 - nbredepions[pionBlanc] else
          if (nbredepions[pionBlanc] > nbredepions[pionNoir ]) then nbredepions[pionBlanc] := 64 - nbredepions[pionNoir ] else
          if (nbredepions[pionBlanc] = nbredepions[pionNoir ]) then 
            begin
              nbredepions[pionBlanc] := 32;
              nbredepions[pionNoir]  := 32;
            end;
        end;
      
      {calcul du score, à la mode "synchro-games" de GGS : on regarde un match de
       deux parties sur une position donnee (une fois Noir, une fois Blanc), celui 
       qui en moyenne s'en est le mieux tiré, empoche le point}
      if (compteurPartie mod 2) = 0 
        then
	        begin
			      if UnContreDeux
			        then 
			          begin
			            scoreSurDeuxParties[1] := nbredepions[pionNoir]  + nbreDePionsPartiePrecedente[pionBlanc];
			            scoreSurDeuxParties[2] := nbredepions[pionBlanc] + nbreDePionsPartiePrecedente[pionNoir];
			          end
			        else
			          begin
			            scoreSurDeuxParties[1] := nbredepions[pionBlanc] + nbreDePionsPartiePrecedente[pionNoir];
			            scoreSurDeuxParties[2] := nbredepions[pionNoir]  + nbreDePionsPartiePrecedente[pionBlanc];
			          end;  
			      
			      scoreCumule[1] := scoreCumule[1] + scoreSurDeuxParties[1];
			      scoreCumule[2] := scoreCumule[2] + scoreSurDeuxParties[2];
			            
			      if scoreSurDeuxParties[1] > scoreSurDeuxParties[2] then fanny[1] := fanny[1] + 2 else
			      if scoreSurDeuxParties[1] < scoreSurDeuxParties[2] then fanny[2] := fanny[2] + 2 else
			      if scoreSurDeuxParties[1] = scoreSurDeuxParties[2] then
			        begin
			          fanny[2] := fanny[2]+1;
			          fanny[1] := fanny[1]+1;
			        end;    
			        
			      NumToString(fanny[2] div 2,s1);
			      if odd(fanny[2]) then s1 := s1+'.5';
			      s1 := s1 + '/' + NumEnString(compteurPartie div 2);
			      if (scoreSurDeuxParties[2] >= scoreSurDeuxParties[1])
			        then s1 := s1 + '  (+' + NumEnString((scoreSurDeuxParties[2] - scoreSurDeuxParties[1]) div 2) + ')'
			        else s1 := s1 + '  ('  + NumEnString((scoreSurDeuxParties[2] - scoreSurDeuxParties[1]) div 2) + ')';
			      (* WritelnDansRapport('[2] : '+s1); *)
			      
			      nbreDePionsPartiePrecedente[pionNoir]  := 0;
			      nbreDePionsPartiePrecedente[pionBlanc] := 0;
	        end
	      else
	        begin
			      nbreDePionsPartiePrecedente[pionNoir]  := nbredepions[pionNoir];
			      nbreDePionsPartiePrecedente[pionBlanc] := nbredepions[pionBlanc];
			    end;
      
      
      {on met les parties du match dans la liste}
      if LaDemoApprend & not(Quitter) & not(quitterdemo) & gameOver then
        if not(jeuInstantane) then
        begin
          if nbredepions[pionNoir]>nbredepions[pionBlanc] then GainTheorique := CaracterePourNoir;
          if nbredepions[pionNoir]=nbredepions[pionBlanc] then GainTheorique := CaracterePourEgalite;
          if nbredepions[pionNoir]<nbredepions[pionBlanc] then GainTheorique := CaracterePourBlanc;
          ChainePartie := PartieNormalisee(diagonaleInversee,true);
          ApprendPartieIsolee(ChainePartie,GainTheorique,finDePartie);
        end;

      if TickCount()-dernierTick>=delaiAvantDoSystemTask then DoSystemTask(aQuiDeJouer);
    end;

  
  if (fanny[2]+fanny[1]) <> 0 
    then FaireUnMatch := 100.0*fanny[2]/(1.0*(fanny[2]+fanny[1]))
    else FaireUnMatch := 0;
    
end;


procedure FaireUnePasseDeMatchsContreLeChampion;
var rang_deviation_a_tester : SInt32;
    i,j,k,l : SInt32;
begin
  
  for rang_deviation_a_tester := 1 to deviations_a_tester.cardinal do
    for i := -2 to 2 do
      for j := -2 to 2 do
        for k := -2 to 2 do
          for l := -2 to 2 do
            if not(quitterDemo | Quitter) then
              BEGIN
                
                deviation_frontiere := i;
                deviation_minimisation := j;
                deviation_mobilite := k;
                deviation_penalitetrait := l;
                
                if GetDoitFaireCetteDeviation(deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait) then
                  begin
                  
                    index_deviation_courante := IndexTriTableauDeviation(deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
          
                    if (index_deviation_courante = deviations_a_tester.numeros[rang_deviation_a_tester]) then
                      begin
                        (* Faire le match *)
                        scoreDuJoueur2 := FaireUnMatch(kIndexJoueurSansDeviation,index_deviation_courante,kNombrePartiesParMatchDansDemo);
                          
                        (* Mettre a jour les pourcentages des deviations *)
                        if not(quitterDemo|Quitter) then
                          begin
                            AjouterResultatMatchPourCetteDeviation(index_deviation_courante,fanny[1]+fanny[2],scorecumule[2],fanny[2]);
                            EcritStatistiquesDuMatchDansRapport;
                            (* on ne conserve une combinaison de deviations que si elle a fait au moins 33 % *)
                            if (PourcentageDeCetteDeviation(index_deviation_courante) < 33.0) then 
                              SetDoitFaireCetteDeviation(false,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
                          end;
                      end;
                      
                  end;
                  
              END;
end;





procedure FaireUnTournoiToutesRondesDesMeilleursDeviations;
var index,t,r,n1,n2 : SInt32;
    indexJoueur1,indexJoueur2 : SInt32;
    scoreDuJoueur2 : extended;
begin
  
  if not(quitterDemo | Quitter) then
    with tournoiDeviations do
      begin
      
        WritelnDansRapport('## DEBUT DU TOURNOI');
        
        (* On selectionne les 15 meilleures deviations pour jouer dans le tournoi... *)
        GeneralQuickSort(0,624,LecturePourTriDeviations,AffectionPourTriDeviations,OrdrePourcentageGlobalPourTriDeviation);
        
        
        
        (* Selection des meilleurs *)
        WritelnDansRapport('#Selection des meilleurs pourcentages pour le tournoi…');
        for t := 0 to kNombreDeviationsDansLeTournoi-1 do
          begin
            index := LecturePourTriDeviations(t);
            indexParticipant[t] := index;
          end;
        
        (* Le champion local joue aussi (100% sur tous les coeffs) *)
        indexParticipant[kNombreDeviationsDansLeTournoi] := kIndexJoueurSansDeviation;  (* Le champion ! *)
        
        
        (* Afficher les participants *)
        
        WritelnDansRapport('#Participants au tournoi : ');
        nbParticipants := kNombreDeviationsDansLeTournoi + 1;
        for t := 0 to nbParticipants - 1 do
          begin
            scoreParticipant[t] := 0.0;
            AfficherDeviationDansRapport(t,indexParticipant[t]);
          end;
        
        
        if not(quitterDemo | Quitter) then
          for r := 1 to kNombreDeviationsDansLeTournoi do
            begin
              numeroRonde := r;
              
              WritelnStringAndNumDansRapport('#RONDE ',numeroRonde);
              
              FaireTournerParticipantsTournoiToutesRondes(numeroRonde);
              
              for t := 0 to (kNombreDeviationsDansLeTournoi div 2) do
                if not(quitterDemo | Quitter) then
                  begin
                    n1 := tableauTouteRonde[t];
                    n2 := tableauTouteRonde[kNombreDeviationsDansLeTournoi - t];
                  
                    indexJoueur1 := indexParticipant[n1];
                    indexJoueur2 := indexParticipant[n2];
                    
                    
                    (* Faire le match *)
                    WriteDansRapport('match '+NumEnString(indexJoueur1)+'-'+NumEnString(indexJoueur2)+'… ');
                    
                    scoreDuJoueur2 := FaireUnMatch(indexJoueur1,indexJoueur2,kNombreDePartiesParMatchDuTournoi)/100.0;
                    
                    WriteStringAndReelDansRapport(' ',(1.0 - scoreDuJoueur2),3);
                    WritelnStringAndReelDansRapport('-',scoreDuJoueur2,3);
                    
                    (* mettre a jour les scores des joueurs dans le tournoi *)
                    scoreParticipant[n1] := scoreParticipant[n1] + (1.0 - scoreDuJoueur2);
                    scoreParticipant[n2] := scoreParticipant[n2] + scoreDuJoueur2;
                    
                    
                    (* Mettre a jour les pourcentages des deviations *)
                    AjouterResultatMatchPourCetteDeviation(indexJoueur1,fanny[1]+fanny[2],scorecumule[1],fanny[1]);
                    AjouterResultatMatchPourCetteDeviation(indexJoueur2,fanny[1]+fanny[2],scorecumule[2],fanny[2]);
                              
                  end;
              
              if not(quitterDemo | Quitter) then
                begin
                  WritelnStringAndNumDansRapport('Classement après la ronde ',numeroRonde);
                  for t := 0 to nbParticipants - 1 do
                    begin
                      WriteStringAndReelDansRapport(NumEnString(indexParticipant[t])+'   =>   s = ',scoreParticipant[t],3);
                      WriteStringAndReelDansRapport(' (',100*scoreParticipant[t]/numeroRonde,4);
                      WritelnDansRapport('%)');
                    end;
                end;
            end;
      end;
    
end;


 
begin {DoDemo} {$UNUSED avecSauvegardePartieDansListe}
  if not(windowPlateauOpen) then OuvreFntrPlateau(false);
  finDePartieVitesseMactemp := finDePartieVitesseMac;
  finDePartieOptimaleVitesseMactemp := finDePartieOptimaleVitesseMac;
  finDePartieVitesseMac := 42;
  finDePartieOptimaleVitesseMac := 41;
  UtiliseGrapheApprentissageTemp := UtiliseGrapheApprentissage;
  ecritureDansRapportTemp := GetEcritToutDansRapportLog();
  SetEcritToutDansRapportLog(true);
  utilisateurVeutDiscretiserEvaluationTemp := utilisateurVeutDiscretiserEvaluation;
  avecBiblTemp := avecBibl;
  demo := true;
  with gEntrainementOuvertures do
    begin
      tempoCassioVarieSesCoups := CassioVarieSesCoups;
      CassioVarieSesCoups := FALSE;
      CassioSeContenteDeLaNulle := FALSE;
      for i := 0 to 64 do
        deltaNotePerduCeCoup[i] := 0;
      deltaNoteAutoriseParCoup := 0;
      deltaNotePerduAuTotal := 0;
    end;
  OuverturesAleatoires := true;
  quitterDemo := false;
  HumCtreHum := false;
  AjusteSleep;
  DessineIconesChangeantes;
  
  
  nbCoupsImposes := nbreCoup;
  LongueurOuvertureAleatoire := 8;
  nbCoupsIdentiques := Max(nbCoupsImposes,LongueurOuvertureAleatoire);
  
  for i := 1 to nbCoupsImposes do
    premiersCoups[i] := GetNiemeCoupPartieCourante(i);
  for i := nbCoupsImposes+1 to 60 do 
    premiersCoups[i] := 0;
    
   WritelnDansRapport('# avant PeutAllouerTableauDeviations dans DoDemo'); 
    
   if PeutAllouerTableauDeviations() & PeutParserFichierRapportLog()  then 
     begin   
       for nroPasse := 1 to 10000 do
         if not(quitterDemo | Quitter) then
           begin
           
             WritelnStringAndNumDansRapport('## DEBUT DE LA PASSE ',nroPasse);
             
             {if ((nroPasse mod 5) = 0) then }
              {FaireUnTournoiToutesRondesDesMeilleursDeviations;}
            
             (* Selectionner les meilleures deviations potentielles à developper *)
             {TrierMeilleuresDeviations;}
            
             (* Selectionner une seule deviation *)
             SelectionnerUnChampion;
  
             FaireUnePasseDeMatchsContreLeChampion;
             
             
           end;
     end;   
          
          
          
   Quitter := false;
   demo := false;
   gEntrainementOuvertures.CassioVarieSesCoups := tempoCassioVarieSesCoups;
   gEntrainementOuvertures.CassioSeContenteDeLaNulle := true;
   UtiliseGrapheApprentissage := UtiliseGrapheApprentissageTemp;
   avecBibl := avecBiblTemp;
   utilisateurVeutDiscretiserEvaluation := utilisateurVeutDiscretiserEvaluationTemp;
   SetProfImposee(false,'fin de DoDemo');
   finDePartieVitesseMac := finDePartieVitesseMactemp;
   finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMactemp;
   SetEcritToutDansRapportLog(ecritureDansRapportTemp);

   Initialise_valeurs_bords(-0.5);
   Initialise_turbulence_bords(true);
   
   LanceInterruption(oldInterruption,'DoDemo');
   
   
   DesallouerMemoireTableauDeviations;               
end;















END.























