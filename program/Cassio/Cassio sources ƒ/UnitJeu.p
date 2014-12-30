UNIT UnitJeu;


INTERFACE







USES UnitOth0,UnitSquareSet,UnitDefinitionsPackedThorGame;


const 
  kNoFlag                 = 0;
  kPeutDetruireArbreDeJeu = 1;
  

procedure InitUnitJeu;
procedure SupprimeDansHeuris(coup : SInt16);
procedure TachesUsuellesPourGameOver;
procedure TachesUsuellesPourAffichageCourant;
procedure JoueSonPourGameOver;


function GetNiemeCoupPartieCourante(numeroDuCoup : SInt32) : SInt32;
function DerniereCaseJouee() : SInt32;
procedure SetNiemeCoup(numeroDuCoup : SInt32;square : SInt32);


function JoueEn(a : SInt16; var trait : SInt16; var couplegal : boolean;avecNomOuverture,prendreMainVariationFromArbre : boolean) : boolean;
function JoueEnFictif(a,couleur : SInt16; 
                      JeuCourantFictif : plateauOthello;
                      EmplJouableFictif : plBool;
                      FrontiereCouranteFictive : InfoFrontRec;
                      nbBlancFictif,nbNoirFictif : SInt16; 
                      nbreCoupFictif : SInt16; 
                      doitAvancerDansArbreDeJeu : boolean;
                      prendreMainVariationFromArbre : boolean;
                      const fonctionAppelante : str255) : OSErr;
procedure TraiteInterruptionBrutale(var coup,reponse : SInt32;fonctionAppelante : str255);
procedure DeuxiemeCoupMac(var x,note : SInt32);
function ReponseInstantanee(var bestDef : SInt32;NiveauJeuIntantaneVoulu : SInt16) : SInt32;
function ReponseInstantaneeTore(var bestDef : SInt32) : SInt32;
procedure GenereOuvertureAleatoireEquilibree(nbDeCoupsDemandes,borneMin,borneMax : SInt16; casesInterdites : SquareSet; var s : PackedThorGame);
procedure ChoixMac(var ChoixX,whichNote,meiDef : SInt32;CoulChoix,niveau,nbblanc,nbNoir : SInt32; var plat : plateauOthello; var jouable : plBool; var fro : InfoFrontRec; const fonctionAppelante : str255);
function  ConnaitSuiteParfaite(var ChoixX,MeilleurDef : SInt32;autorisationTemporisation : boolean) : boolean;
procedure ChoixMacStandard(var ChoixX,note,MeilleurDef : SInt32;CoulChoix,niveau : SInt16; const fonctionAppelante : str255);
procedure DealWithEssai(whichSquare : SInt16; const fonctionAppelante : str255);
procedure Jouer(var aQuiDeJouer : SInt16; whichSquare : SInt16; const fonctionAppelante : str255);
procedure JeuMac(niveau : SInt32; const fonctionAppelante : str255);
procedure PremierCoupMac;
procedure DoForcerMacAJouerMaintenant;
procedure TraiteCoupImprevu(caseX : SInt32);
procedure JoueCoupPartieSelectionnee(nroHilite : SInt32);
procedure JoueCoupMajoritaireStat;
procedure JoueCoupQueMacAttendait;


procedure MiseAJourDeLaPartie(s : str255;
                              jeuDepart : plateauOthello;
                              jouableDepart : plBool;
                              frontiereDepart : InfoFrontRec;
                              nbBlancsDepart,nbNoirsDepart : SInt32;
                              traitDepart : SInt16; 
                              nbreCoupDepart : SInt16; 
                              depuisPositionInitiale : boolean;
                              coupFinal : SInt16; 
                              var gameNodeLePlusProfondGenere : GameTree);
procedure UpdateGameByMainBranchFromCurrentNode(nroDernierCoupAtteintMAJ : SInt16; 
																								jeuMAJ : plateauOthello;
																								jouableMAJ : plBool;
																								frontMAJ : InfoFrontRec;
																								nbBlancsMAJ,nbNoirsMAJ : SInt32;
																								traitMAJ,nbreCoupMAJ : SInt16);
                              
procedure RejouePartieOthello(s : str255;coupMax : SInt16; 
                              positionDepartStandart : boolean;
                              platImpose : plateauOthello;traitImpose : SInt16; 
                              var gameNodeLePlusProfondGenere : GameTree;
                              peutDetruireArbreDeJeu : boolean;
                              avecNomsOuvertureDansArbre : boolean);
                              
procedure RejouePartieOthelloFictive(s : str255;coupMax : SInt16; 
                                     positionDepartStandart : boolean;
                                     platImpose : plateauOthello;traitImpose : SInt16; 
                                     var gameNodeLePlusProfondGenere : GameTree;
                                     flags : SInt32);
function ResynchronisePartieEtCurrentNode(ApresQuelCoup : SInt16) : OSErr;






IMPLEMENTATION







USES UnitPotentiels,UnitEvaluation,UnitActions,UnitEntreesSortiesGraphe,UnitBibl,
     UnitNotesSurCases,UnitRapportImplementation,UnitCarbonisation,UnitUtilitaires,
     UnitOth1,UnitAccesStructuresNouvFormat,UnitFenetres,UnitNouvelleEval,Unit_AB_simple,
     UnitAfficheArbreDeJeuCourant,UnitPropertyList,UnitPotentiels,UnitMacExtras,UnitCourbe,
     UnitGestionDuTemps,UnitMilieuDePartie,UnitFinaleFast,UnitSolitaire,UnitTore,
     UnitArbreDeJeuCourant,UnitPhasesPartie,UnitPierresDelta,UnitServicesDialogs,
     UnitAffichageReflexion,UnitStrategie,UnitEntreeTranscript,UnitJaponais,UnitTroisiemeDimension,
     UnitCassioSounds,UnitInterversions,Zebra_to_Cassio,UnitRapport,UnitMenus,UnitStatistiques,
     UnitSuperviseur,UnitListe,UnitGestionDuTemps,UnitScannerOthellistique,SNStrings,
     UnitLongintScrollerPourListe,UnitCouleur,UnitNormalisation,UnitPackedThorGame;




procedure InitUnitJeu;
var i : SInt32;
begin
  InvalidateAnalyseDeFinale;
  SetDelaiDeRetournementDesPions(10);
  for i := 0 to 60 do
    SetDateEnTickDuCoupNumero(i,0);
end;



procedure SupprimeDansHeuris(coup : SInt16);
var i,j,longueur,t : SInt16; 
begin
  for t := 1 to 64 do
    begin
      i := othellier[t];
      if jeuCourant[i] = pionVide then
        begin
          longueur := tableHeurisNoir[i,0];
          j := 0;
          repeat
            j := j+1;
          until (tableHeurisNoir[i,j]=coup) | (j>=longueur);
          if (tableHeurisNoir[i,j]=coup) & (j<=longueur) then
            begin
              Moveleft(tableHeurisNoir[i,j+1],tableHeurisNoir[i,j],longueur-j);
             {******** taille de tableHeurisNoir[i,j]=1 octet *******}
              tableHeurisNoir[i,0] := longueur-1;
            end;
          longueur := tableHeurisBlanc[i,0];
          j := 0;
          repeat
            j := j+1;
          until (tableHeurisBlanc[i,j]=coup) | (j>=longueur);
          if (tableHeurisBlanc[i,j]=coup) & (j<=longueur) then
            begin
              Moveleft(tableHeurisBlanc[i,j+1],tableHeurisBlanc[i,j],longueur-j);
              tableHeurisBlanc[i,0] := longueur-1;
            end;
        end;
    end;
end;


procedure AjustementAutomatiqueDuNiveauDeJeuInstantane;
var s : str255;
    oldScript : SInt32;
    
  procedure SwitchToRed;
    begin
      GetCurrentScript(oldScript);
      DisableKeyboardScriptSwitch;
      FinRapport;
      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
      ChangeFontColorDansRapport(RougeCmd);
      ChangeFontFaceDansRapport(bold);
    end;
  
  procedure SwitchToBlue;
    begin
      GetCurrentScript(oldScript);
      DisableKeyboardScriptSwitch;
      FinRapport;
      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
      ChangeFontColorDansRapport(MarineCmd);
      ChangeFontFaceDansRapport(bold);
    end;
    
  procedure BackToNormal;
    begin
      EnableKeyboardScriptSwitch;
      SetCurrentScript(oldScript);
      SwitchToRomanScript;
      TextNormalDansRapport;
    end;
    
begin

  { Ajustement du niveau de jeu instantane suivant le nombre de victoires successives }
  
  if PartieContreMacDeBoutEnBout & not(CassioEstEnModeSolitaire()) & not(HumCtreHum) & not(demo) then
    begin
      if (nbreDePions[couleurMacintosh] <= nbreDePions[-couleurMacintosh]) 
        then 
          begin
            humanWinningStreak := Max(+1,humanWinningStreak+1);
            humanScoreLastLevel := humanScoreLastLevel + 1;
          end
        else 
          begin
            humanWinningStreak := Min(-1,humanWinningStreak-1);
            humanScoreLastLevel := humanScoreLastLevel -1;
          end;
        
        
      if jeuInstantane & (humanWinningStreak >= 2) & (NiveauJeuInstantane = NiveauChampions) then
        begin 
        
          {affichage du streak au niveau Champion}
          
          EffaceDernierCaractereDuRapport;
          SwitchToRed;
          
          s := ParamStr(ReadStringFromRessource(TextesRapportID,32),NumEnString(humanWinningStreak),'','','');
          WritelnDansRapport('   '+s);  {Vous avez gagné ^0 parties d'affilée au niveau Champion.}
          {WritelnDansRapport('');}
          
          BackToNormal;
        end else
        
      if avecAjustementAutomatiqueDuNiveau & jeuInstantane then
        if ((humanWinningStreak >= 1) & (NiveauJeuInstantane < NiveauChampions))  then
        begin 
          NiveauJeuInstantane := NiveauJeuInstantane + 1;  {ajustement positif}
          humanWinningStreak := 0;
          humanScoreLastLevel := 0;
          
          EffaceDernierCaractereDuRapport;
          SwitchToRed;
          
          s := ReadStringFromRessource(TextesRapportID,33);  {OK, voyons si vous serez aussi fort au niveau suivant :-)}
          WritelnDansRapport('   '+s);
          s := ReadStringFromRessource(TextesRapportID,33+NiveauJeuInstantane); {Je passe au niveau Debutant, Amateur, etc.}
          WritelnDansRapport('   '+s);
          {WritelnDansRapport('');}
          
          BackToNormal;
        end else
        
      if avecAjustementAutomatiqueDuNiveau & jeuInstantane & (humanScoreLastLevel <= -2) &  
         (NiveauJeuInstantane > NiveauDebutants) then
        begin 
          NiveauJeuInstantane := NiveauJeuInstantane - 1;  {ajustement negatif}
          humanWinningStreak := 0;
          humanScoreLastLevel := 0;
          
          EffaceDernierCaractereDuRapport;
          SwitchToBlue;
          
          s := ReadStringFromRessource(TextesRapportID,33+NiveauJeuInstantane); {Je passe au niveau Debutant, Amateur, etc.}
          WritelnDansRapport('   '+s);
          {WritelnDansRapport('');}
          
          BackToNormal;
        end;
      
    end;
end;

procedure TachesUsuellesPourGameOver;
var scoreFinalPourNoir : SInt16; 
    prop : Property;
    s : str255;
begin
  gameOver := true;
  aQuiDeJouer := pionVide;
  EffacePromptFenetreReflexion;
  DetruitMeilleureSuite;
  if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
  if ((nbreDePions[pionNoir]+nbreDePions[pionBlanc])=64) | 
     (nbreDePions[pionNoir]=nbreDePions[pionBlanc])
    then scoreFinalPourNoir := nbreDePions[pionNoir]-nbreDePions[pionBlanc]
    else if nbreDePions[pionNoir]>nbreDePions[pionBlanc]
           then scoreFinalPourNoir := 64-2*nbreDePions[pionBlanc]
           else scoreFinalPourNoir := 2*nbreDePions[pionNoir]-64;
  MetScorePrevuParFinaleDansCourbe(nbreCoup,61,kFinaleParfaite,scoreFinalPourNoir);
  MetTitreFenetrePlateau;
  if not(Quitter) & CassioEstEnModeSolitaire() then EssaieAfficherFelicitation;
  
  if (scoreFinalPourNoir >= 0)
	  then prop := MakeValeurOthelloProperty(NodeValueProp,pionNoir, +1, scoreFinalPourNoir,0)
	  else prop := MakeValeurOthelloProperty(NodeValueProp,pionBlanc,+1,-scoreFinalPourNoir,0);
  AddScorePropertyToCurrentNodeSansDuplication(prop);
  if (nbreCoup = 60) & (GetCurrentNode()^.father <> NIL) then
    AddScorePropertyToGameTreeSansDuplication(prop,GetCurrentNode()^.father);
  DisposePropertyStuff(prop);
  EcritCurrentNodeDansFenetreArbreDeJeu(false,true);
  
  if not(CurrentNodeHasCommentaire()) &
    (nbPartiesActives=1) & JoueursEtTournoisEnMemoire & 
    (windowListeOpen | windowStatOpen) then
    begin  
      s := ConstruireChaineReferencesPartieDapresListe(1,false);
      if (s <> '') then 
        SetCommentaireCurrentNodeFromString(s);
      EcritCommentairesOfCurrentNode;
      EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
    end;
  
  InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);
  
end;

procedure JoueSonPourGameOver;
const AnnonceVictoireHumID=10001;
      AnnonceVictoireMacID=10000;
      BugleVictoirMac=128;
      PouetPouetPouetPouetID=203;
      TriangleIntersideralID=204;
      GameOverManID=1412;
      WhatAreWeGottoDoNowID=1414;
      ThisIsNothingSeriousID=1002;
var scoreFinalPourNoir : SInt16; 
begin
  if not(CassioEstEnModeSolitaire()) then
    if avecSon & avecSonPourGameOver & not(HumCtreHum) & not(demo) then 
      if PartieContreMacDeBoutEnBout then
      begin
        if ((nbreDePions[pionNoir]+nbreDePions[pionBlanc])=64) | 
           (nbreDePions[pionNoir]=nbreDePions[pionBlanc])
          then scoreFinalPourNoir := nbreDePions[pionNoir]-nbreDePions[pionBlanc]
          else if nbreDePions[pionNoir]>nbreDePions[pionBlanc]
                 then scoreFinalPourNoir := 64-2*nbreDePions[pionBlanc]
                 else scoreFinalPourNoir := 2*nbreDePions[pionNoir]-64;
        if ((scoreFinalPourNoir>=0) & (couleurMacintosh = pionBlanc)) |
           ((scoreFinalPourNoir<=0) & (couleurMacintosh = pionNoir))
          then 
            begin  {victoire de l'humain}
              case RandomEntreBornes(1,4) of
                1 : PlaySoundSynchrone(AnnonceVictoireHumID);
                2 : PlaySoundSynchrone(PouetPouetPouetPouetID);
                3 : PlaySoundSynchrone(WhatAreWeGottoDoNowID);
                4 : PlaySoundSynchrone(ThisIsNothingSeriousID);
              end;
            end
          else  {victoire de l'ordinateur}
            begin
              case RandomEntreBornes(1,4) of
                1 : PlaySoundSynchrone(AnnonceVictoireMacID);
                2 : PlaySoundSynchrone(BugleVictoirMac);
                3 : PlaySoundSynchrone(GameOverManID);
                4 : PlaySoundSynchrone(TriangleIntersideralID);
              end;
            end;
      end;
end;

procedure GenereInfosIOSDansPressePapier(numeroDuCoup,couleur,coup : SInt32;tickPourCalculTemps : SInt32);
var probaDeGain : extended;
    note : SInt32;
    tempsEnSecondes,aux : SInt32;
begin
  if not(EvaluationPourCourbeProvientDeLaFinale(numeroDuCoup))
    then 
      begin
        if not(HumCtreHum) & 
           (InfosDerniereReflexionMac.nroDuCoup = numeroDuCoup) & 
           (InfosDerniereReflexionMac.coup = coup) & 
           (InfosDerniereReflexionMac.coul = couleur) &
           (InfosDerniereReflexionMac.valeurCoup <> -noteMax)
          then 
            begin
              note := InfosDerniereReflexionMac.valeurCoup;
            end
          else 
            begin
              note := (GetEvaluationPourNoirDansCourbe(numeroDuCoup-1)+GetEvaluationPourNoirDansCourbe(numeroDuCoup)) div 2;
              if (couleur = pionBlanc) then note := -note;
            end;
        {on ramene entre -1.0 et 1.0}
        probaDeGain := note/2500.0;
        if probaDeGain<-0.98 then probaDeGain := -0.98;
        if probaDeGain>0.98 then probaDeGain := 0.98;
        
        {on ramene entre 0.0 et 1.0}
        probaDeGain := 0.5*(probaDeGain+1.0);
        if probaDeGain<0.02 then probaDeGain := 0.02;
        if probaDeGain>0.98 then probaDeGain := 0.98;
        
      end
    else 
      begin
        note := GetEvaluationPourNoirDansCourbe(numeroDuCoup) div kCoeffMultiplicateurPourCourbeEnFinale;
        
        if odd(note) then 
          if note > 0 then note := 2 
                      else note := -2;
                      
        if couleur = pionBlanc 
          then probaDeGain := -1.0*note
          else probaDeGain := 1.0*note;
      end;
  
  if numeroDuCoup < 7 
    then tempsEnSecondes := 0
    else
      begin
        tempsEnSecondes := (TickCount()-tickPourCalculTemps) div 60;
        if tempsEnSecondes<0 then tempsEnSecondes := 0;
        if tempsEnSecondes>10000 then tempsEnSecondes := 10000;
      end;
  
  chainePourIOS := Concat(CoupEnStringEnMajuscules(coup),' ',
                        ReelEnStringAvecDecimales(probaDeGain,6),' ',
                        NumEnString(tempsEnSecondes));
  aux := MyZeroScrap();
  aux := MyPutScrap(Length(chainePourIOS),'TEXT',@chainePourIOS[1]);
  aux := TEFromScrap();
end;



function GetNiemeCoupPartieCourante(numeroDuCoup : SInt32) : SInt32;
begin
  GetNiemeCoupPartieCourante := partie^^[numeroDuCoup].theSquare;
end;


function DerniereCaseJouee() : SInt32;
begin
  DerniereCaseJouee := partie^^[nbreCoup].theSquare;
end;

procedure SetNiemeCoup(numeroDuCoup : SInt32;square : SInt32);
begin
  partie^^[numeroDuCoup].theSquare := square;
end;




{ JoueEn pose un pion sur la case a, qui doit etre vide,
   retourne les pions qui doivent l'etre, met a jour les compteurs, etc. ;
   elle affecte le plateau courant; c'est la procedure finale }   
   
function JoueEn(a : SInt16; var trait : SInt16; 
                 var couplegal : boolean;
                 avecNomOuverture : boolean;
                 prendreMainVariationFromArbre : boolean) : boolean;
var x,dx,i,t : SInt16; 
    pionEnnemi,compteur,compteurPrise : SInt16; 
    bidon,nouvellevariante : boolean;
    correctionsTemp : boolean;
    nbBlaDummy,nbNoiDummy : SInt32;
    erreurES : OSErr;
    couleurDeCeCoup : SInt32;
begin
 JoueEn := false;
 couleurDeCeCoup := trait;
 
 couplegal := (jeuCourant[a] = pionVide) & windowPlateauOpen;
 if couplegal then couplegal := PeutJouerIci(couleurDeCeCoup,a,jeuCourant);
 if not(couplegal) 
  then 
    begin
      {for i := 1 to 10 do SysBeep(0);}
      if not(windowPlateauOpen) then OuvreFntrPlateau(false);
    end
  else
    begin
      SetPortByWindow(wPlateauPtr);
      
      if avecSon & avecSonPourPosePion & not(EnVieille3D()) then PlayPosePionSound; {PlaySoundSynchrone(sonPourPosePion);}
      EffaceAideDebutant(false,true,othellierToutEntier);
      ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet());
      EffaceProprietesOfCurrentNode;
      
      if afficheNumeroCoup then
        if (nbreCoup > 0) then 
          begin
            x := DerniereCaseJouee();
            if InRange(x,11,88) then 
              EffaceNumeroCoup(x,nbreCoup,GetCurrentNode());
          end;
      nbreCoup := nbreCoup+1; 
      DessinePion(a,couleurDeCeCoup);  
      
      
      erreurES := ChangeCurrentNodeAfterNewMove(a,couleurDeCeCoup,'JoueEn {1}');
      if (erreurES <> 0) & (ResynchronisePartieEtCurrentNode(nbreCoup-1)=0)
        then erreurES := ChangeCurrentNodeAfterNewMove(a,couleurDeCeCoup,'JoueEn {2}');
      MarquerCurrentNodeCommeReel('JoueEn');
      
      if afficheNumeroCoup & not(EnVieille3D()) then DessineNumeroCoup(a,nbreCoup,-couleurDeCeCoup,GetCurrentNode());
      
      IndexProchainFilsDansGraphe := -1;
      nouvellevariante := false;
      if (nbreCoup > nroDernierCoupAtteint) | (DerniereCaseJouee() <> a) then 
        begin
           nouvellevariante := true;
           nroDernierCoupAtteint := nbreCoup;
           if (a<>partie^^[nbreCoup].coupParfait) then
             begin
               partie^^[nbreCoup].coupParfait := a;
               partie^^[nbreCoup].optimal := (nbreCoup>=60);  {=false sauf pour le dernier coup }
               for i := nbreCoup+1 to 60 do
                 begin
                   partie^^[nbreCoup].coupParfait := 0;
                   partie^^[i].optimal := false;
                 end;
             end;
           InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
        end;
      if nroDernierCoupAtteint <= nbreCoup then MyDisableItem(PartieMenu,ForwardCmd);
      partie^^[nbreCoup+1].tempsUtilise.tempsNoir := 60*tempsDesJoueurs[pionNoir].minimum+tempsDesJoueurs[pionNoir].sec;
      partie^^[nbreCoup+1].tempsUtilise.tempsBlanc := 60*tempsDesJoueurs[pionBlanc].minimum+tempsDesJoueurs[pionBlanc].sec;
      SetNiemeCoup(nbreCoup,a);
      partie^^[nbreCoup].trait := couleurDeCeCoup;
      partie^^[nbreCoup].nbretourne := 0;
      if (nbreCoup = 1) then SetPremierCoupParDefaut(a);
      if not(OthelloTorique) then
        begin
         compteurPrise := 0;
         pionEnnemi := -couleurDeCeCoup;
         nbreDePions[couleurDeCeCoup] := nbreDePions[couleurDeCeCoup]+1;
         for t := dirPriseDeb[a] to dirPriseFin[a] do
            begin
               dx := dirPrise[t];
               compteur := 0;
               x := a+dx;
               while jeuCourant[x]=pionEnnemi do
                  begin
                     inc(compteur);
                     x := x+dx;            
                  end;
               if (jeuCourant[x]=couleurDeCeCoup) & (compteur <> 0) then
                  begin
                     nbreDePions[couleurDeCeCoup] := nbreDePions[couleurDeCeCoup]+compteur;
                     nbreDePions[pionEnnemi] := nbreDePions[pionEnnemi]-compteur;           
                     x := a;    
                     for i := 1 to compteur do
                       begin
                        compteurPrise := compteurPrise+1;
                        x := x+dx;
                        if avecSon & avecSonPourRetournePion & not(EnVieille3D()) & (compteurPrise=1)
                          then PlayRetournementDePionSound; {PlaySoundSynchrone(sonPourRetournePion);}
                        TemporisationRetournementDesPions;
                        DessinePion(x,couleurDeCeCoup); 
                        partie^^[nbreCoup].nbRetourne := partie^^[nbreCoup].nbRetourne+1;
                        partie^^[nbreCoup].retournes[partie^^[nbreCoup].nbRetourne] := x;                 
                       end; 
                  end;
            end;  
          end;
      if OthelloTorique then
        begin
          nbBlaDummy := 0;
          nbNoiDummy := 0;
          bidon := ModifPlatTore(a,couleurDeCeCoup,jeuCourant,nbBlaDummy,nbNoiDummy); 
          if not(EnVieille3D()) then DessinePosition(jeuCourant);
        end
      else 
        begin
          nbBlaDummy := 0;
          nbNoiDummy := 0;
          bidon := ModifPlat(a,couleurDeCeCoup,jeuCourant,emplJouable,nbBlaDummy,nbNoiDummy,frontiereCourante); 
        end;
      if EnVieille3D() then Dessine3D(jeuCourant,avecSon);
      if afficheNumeroCoup & EnVieille3D() then DessineNumeroCoup(a,nbreCoup,-jeuCourant[a],GetCurrentNode());
      if avecNomOuverture & not(CassioEstEnModeSolitaire())
        then CoupJoueDansRapport(nbreCoup,a);
      
      if afficheInfosApprentissage then EcritLesInfosDApprentissage;
      AfficheScore;
      if EnModeEntreeTranscript() then 
        begin
          if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
            QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
          SetTranscriptChercheDesCorrections(prendreMainVariationFromArbre,correctionsTemp);
          EntrerPartieDansCurrentTranscript(nbreCoup);
          SetTranscriptChercheDesCorrections(correctionsTemp,bidon);
        end;
        
      {la}
      SupprimeDansHeuris(a);
      gDoitJouerMeilleureReponse := false;
      FixeMarqueSurMenuMode(nbreCoup);
	    
	    aQuiDeJouer := -aQuiDeJouer;
	    ZebraBookDansArbreDeJeuCourant;
	    
	    if nouvellevariante then 
        begin
          InvalidateEvaluationPourCourbe(nbreCoup,60);
          
          if not(PeutCopierEndgameScoreFromGameTreeDansCourbe(GetCurrentNode(),nbreCoup,[kFinaleParfaite,kFinaleWLD])) then
            EssaieMettreEvaluationDeMilieuDansCourbe(a,couleurDeCeCoup,nbreCoup ,jeuCourant,
                                                          nbreDePions[pionBlanc],nbreDePions[pionNoir],emplJouable,frontiereCourante);
	        SetNbrePionsPerduParVariation(nbreCoup+1,0);
	      end;
	    
      TraceSegmentCourbe(nbreCoup,kCourbeColoree,'JoueEn');
      DessineSliderFenetreCourbe;
      
      AddRandomDeltaStoneToCurrentNode;
      AfficheProprietesOfCurrentNode(false,othellierToutEntier,'JoueEn');
      if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
      
      if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
        QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
       
      if enModeIOS then
        GenereInfosIOSDansPressePapier(nbreCoup - 1,couleurDeCeCoup,a,tickPourCalculTempsIOS);
      tickPourCalculTempsIOS := TickCount();
         
      if nouvellevariante & prendreMainVariationFromArbre 
        then UpdateGameByMainBranchFromCurrentNode(nroDernierCoupAtteint,jeuCourant,emplJouable,frontiereCourante,
                                                   nbreDePions[pionBlanc],nbreDePions[pionNoir],0,nbreCoup);
      
      SetDateEnTickDuCoupNumero(nbreCoup,TickCount());
      
    end;  {coup legal}
  InvalidateAnalyseDeFinaleSiNecessaire(kNormal);
  
  JoueEn := couplegal;
end;


{ fait la meme chose que JoueEn, mais n'affiche pas les mises à jour }
function JoueEnFictif(a,couleur : SInt16; 
                      JeuCourantFictif : plateauOthello;
                      EmplJouableFictif : plBool;
                      FrontiereCouranteFictive : InfoFrontRec;
                      nbBlancFictif,nbNoirFictif : SInt16; 
                      nbreCoupFictif : SInt16; 
                      doitAvancerDansArbreDeJeu : boolean;
                      prendreMainVariationFromArbre : boolean;
                      const fonctionAppelante : str255) : OSErr;
var x,dx,i,t : SInt16; 
    pionEnnemi,compteur,compteurPrise : SInt16; 
    bidon,nouvellevariante : boolean;
    nbBlaDummy,nbNoiDummy : SInt32;
    erreurES : OSErr;
    nbreDePionsFictif : array[pionNoir..pionBlanc] of SInt16;
    result : OSErr;
    doitEssayerNotesMilieuDePartie : boolean;
begin  
  nbreDePionsFictif[pionNoir] := nbNoirFictif;
  nbreDePionsFictif[pionBlanc] := nbBlancFictif;
  nbreCoupFictif := nbreCoupFictif+1;
  
  result := NoErr;
  if doitAvancerDansArbreDeJeu then 
    begin
      erreurES := ChangeCurrentNodeAfterNewMove(a,couleur,'JoueCoupFictif {1}');
      
      result := erreurES;
      
      if erreurES <> NoErr then
        begin
          WriteStringAndNumDansRapport('ErreurES = ',ErreurES);
          WritelnDansRapport('  dans JoueEnFictif {1}, fonction appelante = '+fonctionAppelante);
        end;
      
      if (erreurES <> NoErr) then
        begin
          erreurES := ResynchronisePartieEtCurrentNode(nbreCoupFictif-1);
          if erreurES = NoErr
            then
              begin
                erreurES := ChangeCurrentNodeAfterNewMove(a,couleur,'JoueCoupFictif {2}');
                if erreurES <> NoErr
                  then WritelnDansRapport('Pas de resynchronisation par JoueCoupFictif {2} !')
                  else WritelnDansRapport('J''ai reussi a me resynchroniser temporairement dans JoueCoupFictif {2}');
              end
            else
              begin
                WritelnStringAndNumDansRapport('Ca a l''air grave, parce que, dans JoueCoupFictif {2}, ResynchronisePartieEtCurrentNode = ',erreurES);
              end;
        end;
      MarquerCurrentNodeCommeReel('JoueEnFictif');
      {WritelnDansRapport('JoueEnFictif : fonctionAppelante = '+fonctionAppelante);}
    end;
  
  nouvellevariante := false;
  if (nbreCoupFictif > nroDernierCoupAtteint) | (GetNiemeCoupPartieCourante(nbreCoupFictif) <> a) then 
    begin
       nouvellevariante := true;
       nroDernierCoupAtteint := nbreCoupFictif;
       if (a<>partie^^[nbreCoupFictif].coupParfait) then
          begin
            partie^^[nbreCoupFictif].coupParfait := a;
            partie^^[nbreCoupFictif].optimal := (nbreCoupFictif>=60);
            for i := nbreCoupFictif+1 to 60 do
              begin
                partie^^[nbreCoupFictif].coupParfait := 0;
                partie^^[i].optimal := false;
              end;
          end;
       InvalidateNombrePartiesActivesDansLeCache(nbreCoupFictif);
    end;
  partie^^[nbreCoupFictif+1].tempsUtilise.tempsNoir := 60*tempsDesJoueurs[pionNoir].minimum+tempsDesJoueurs[pionNoir].sec;
  partie^^[nbreCoupFictif+1].tempsUtilise.tempsBlanc := 60*tempsDesJoueurs[pionBlanc].minimum+tempsDesJoueurs[pionBlanc].sec;
  SetNiemeCoup(nbreCoupFictif,a);
  partie^^[nbreCoupFictif].trait := couleur;
  partie^^[nbreCoupFictif].nbretourne := 0;
  if (nbreCoupFictif = 1) then SetPremierCoupParDefaut(a);
  if not(OthelloTorique) then
    begin
     compteurPrise := 0;
     pionEnnemi := -couleur;
     nbreDePionsFictif[couleur] := nbreDePionsFictif[couleur]+1;
     for t := dirPriseDeb[a] to dirPriseFin[a] do
        begin
           dx := dirPrise[t];
           compteur := 0;
           x := a+dx;
           while JeuCourantFictif[x]=pionEnnemi do
              begin
                 inc(compteur);
                 x := x+dx;            
              end;
           if (JeuCourantFictif[x]=couleur) & (compteur <> 0) then
              begin
                 nbreDePionsFictif[couleur] := nbreDePionsFictif[couleur]+compteur;
                 nbreDePionsFictif[pionEnnemi] := nbreDePionsFictif[pionEnnemi]-compteur;               
                 for i := 1 to compteur do
                   begin
                    compteurPrise := compteurPrise+1;
                    x := x-dx;
                    partie^^[nbreCoupFictif].nbRetourne := partie^^[nbreCoupFictif].nbRetourne+1;
                    partie^^[nbreCoupFictif].retournes[partie^^[nbreCoupFictif].nbRetourne] := x;                 
                   end; 
              end;
        end;  
      end;
  if OthelloTorique then
    begin
      nbBlaDummy := 0;
      nbNoiDummy := 0;
      bidon := ModifPlatTore(a,couleur,JeuCourantFictif,nbBlaDummy,nbNoiDummy); 
    end
  else 
    begin
      nbBlaDummy := 0;
      nbNoiDummy := 0;
      bidon := ModifPlat(a,couleur,JeuCourantFictif,EmplJouableFictif,nbBlaDummy,nbNoiDummy,FrontiereCouranteFictive);
    end;
  if EnModeEntreeTranscript() then EntrerPartieDansCurrentTranscript(nbreCoupFictif);
  if nouvellevariante then 
    begin
      
      InvalidateEvaluationPourCourbe(nbreCoupFictif,60);
      
      doitEssayerNotesMilieuDePartie := true;
      if doitAvancerDansArbreDeJeu then
        doitEssayerNotesMilieuDePartie := doitEssayerNotesMilieuDePartie & not(PeutCopierEndgameScoreFromGameTreeDansCourbe(GetCurrentNode(),nbreCoupFictif,[kFinaleParfaite,kFinaleWLD]));
      
      
      if doitEssayerNotesMilieuDePartie then 
        EssaieMettreEvaluationDeMilieuDansCourbe(a,couleur,nbreCoupFictif ,JeuCourantFictif,
                                                 nbreDePionsFictif[pionBlanc],nbreDePionsFictif[pionNoir],EmplJouableFictif,FrontiereCouranteFictive);
	    SetNbrePionsPerduParVariation(nbreCoupFictif+1,0);
	  end;
  if nouvellevariante & doitAvancerDansArbreDeJeu & prendreMainVariationFromArbre then 
    UpdateGameByMainBranchFromCurrentNode(nroDernierCoupAtteint,JeuCourantFictif,EmplJouableFictif,FrontiereCouranteFictive,
                                               nbreDePionsFictif[pionBlanc],nbreDePionsFictif[pionNoir],0,nbreCoupFictif);
  
  SetDateEnTickDuCoupNumero(nbreCoupFictif,TickCount());
  
  JoueEnFictif := result;
end;



procedure TraiteInterruptionBrutale(var coup,reponse : SInt32;fonctionAppelante : str255);
begin
  if not((BAND(interruptionReflexion,interruptionDepassementTemps) <> 0) & vaDepasserTemps) then
    begin  
      if debuggage.gestionDuTemps then 
        WritelnDansRapport('dans TraiteInterruptionBrutale, fonctionAppelante='+fonctionAppelante);
      coup := 44;
      reponse := 44;                  
      reponsePrete := false;
      meilleureReponsePrete := 44;
      MeilleurCoupHumPret := 44;
      meilleurCoupHum := 44;
    end;
end;



procedure GenereOuvertureAleatoireEquilibree(nbDeCoupsDemandes,borneMin,borneMax : SInt16; casesInterdites : SquareSet; var s : PackedThorGame);
var coup,i,nbEssai,ecart : SInt16; 
    nbBlancsTest,nbNoirsTest : SInt32;
    EvalTest : SInt16; 
    meilleurePartie,partieTestee : PackedThorGame; 
    platTest : PositionEtTraitRec;
    jouableTest : plBool;
    FrontTest : InfoFrontRec;
    bestDef : SInt32;
    oldInterruption : SInt16; 
    legal : boolean;
begin

  FILL_PACKED_GAME_WITH_ZEROS(s);
  FILL_PACKED_GAME_WITH_ZEROS(meilleurePartie);
  
  nbEssai := 0;
  ecart := 30000;
  Superviseur(nbDeCoupsDemandes);
  repeat
    inc(nbEssai);
    
    FILL_PACKED_GAME_WITH_ZEROS(partieTestee);
    
    
    platTest := PositionEtTraitInitiauxStandard();
    for i := 1 to nbDeCoupsDemandes do
      begin
        coup := CoupAleatoire(GetTraitOfPosition(platTest),platTest.position,casesInterdites);
        
        if (coup >= 11) & (coup <= 88) then
          begin
            ADD_MOVE_TO_PACKED_GAME(partieTestee, coup);
            legal := UpdatePositionEtTrait(platTest,coup);
          end;
      end;
      
    CarteJouable(platTest.position,jouableTest);
    CarteFrontiere(platTest.position,frontTest);
    nbBlancsTest := NbPionsDeCetteCouleurDansPosition(pionBlanc,platTest.position);
    nbNoirsTest  := NbPionsDeCetteCouleurDansPosition(pionNoir,platTest.position);
    
    oldInterruption := GetCurrentInterruption();
    EnleveCetteInterruption(oldInterruption);
    
    
    evalTest := -AB_simple(platTest.position,jouableTest,bestDef,GetTraitOfPosition(platTest),1,
              -30000,30000,nbBlancsTest,nbNoirsTest,frontTest,false);
    
    LanceInterruption(oldInterruption,'GenereOuvertureAleatoireEquilibree');
              
    {
    evalTest := -Evaluation(platTest,traitTest,nbBlancsTest,nbNoirsTest,
	                    jouableTest,frontTest,false,-30000,30000,nbEvalRecursives);
    }
    
    {
    EssaieSetPortWindowPlateau;
    WriteStringAndNumAt('nbEssai=',nbEssai,10,10);
    Ecritpositionat(platTest,10,20);
    WriteStringAndNumAt('evalTest=',evalTest,10,140);
    WriteStringAndNumAt('traitTest=',traitTest,10,150);     
    WriteStringAndNumAt('nbBlancsTest=',nbBlancsTest,100,150);     
    WriteStringAndNumAt('nbNoirsTest=',nbNoirsTest,200,150);       
    SysBeep(0);
    AttendFrappeClavier;}
    
    if (evalTest >= borneMin) & (evalTest <= borneMax) then 
      begin
        ecart := 0;
        meilleurePartie := partieTestee;
      end;
    if (evalTest < borneMin) & (Abs(borneMin-evalTest) < ecart) then
      begin
        ecart := Abs(borneMin-evalTest);
        meilleurePartie := partieTestee;
      end;
    if (evalTest > borneMax) & (Abs(borneMax-evalTest) < ecart) then
      begin
        ecart := Abs(borneMax-evalTest);
        meilleurePartie := partieTestee;
      end;
      
  until (nbEssai > 40) | ((evalTest >= borneMin) & (evalTest <= borneMax));
  
  {WritelnStringAndNumDansRapport('dans GenereOuvertureAleatoireEquilibree, nbEssai = ',nbEssai);}
  
  s := meilleurePartie;
end;


procedure DeuxiemeCoupMac(var x,note : SInt32);
var a,b,i,j : SInt16; 
    test : boolean;
begin
  for a := 3 to 7 do
  begin
   case a of
    3:b := 4;
    4:b := 3;
    5:b := 6;
    6:b := 5;
   end;
   if jeuCourant[a+10*b] = pionNoir then
     begin
       i := a;    {Coup du joueur adverse}
       j := b;
     end;
  end;
  test := odd(TickCount());
  if test then
    case i of
      3:begin a := 3;b := 3;end;
      4:begin a := 3;b := 5;end;
      5:begin a := 6;b := 4;end;
      6:begin a := 6;b := 6;end;
    end
    else
    case i of
      3:begin a := 5;b := 3;end;
      4:begin a := 3;b := 3;end;
      5:begin a := 6;b := 6;end;
      6:begin a := 4;b := 6;end;
    end; 
  x := a+10*b;  
  note := 0;
end;


function ReponseInstantanee(var bestDef : SInt32; NiveauJeuIntantaneVoulu : SInt16) : SInt32;
var platInst : plateauOthello;
    JouablInst : plBool;
    frontInst : InfoFrontRec;
    VincenzChoice:VincenzMoveRec;
    coupPossible : plBool;
    mobiliteCourante : SInt32;
    nbNoirInst,nbBlancInst : SInt32;
    bestSuite : SInt32;
    yaffiche,iCourant : SInt32;
    eval,maxCourant,infini : SInt32;
    bidonBool : boolean;
    nbEvalsRecursives : SInt32;
    oldInterruption : SInt16; 
begin
  bestDef := 0;

  if aQuiDeJouer = couleurMacintosh then EcritJeReflechis(couleurMacintosh);
  frontiereCourante.occupationTactique := 0;
  SetPotentielsOptimums(PositionEtTraitCourant());
  CarteMove(aQuiDeJouer,jeuCourant,coupPossible,mobiliteCourante);
  discretisationEvaluationEstOK := false;
  
  if (nbreCoup = 1) & not(positionFeerique) & (RandomEntreBornes(1,100) <= 66) then
    begin
      DeuxiemeCoupMac(iCourant,eval);
      if coupPossible[iCourant] then
        begin
          ReponseInstantanee := iCourant;
          exit(ReponseInstantanee);
        end;
    end;
    
  if mobiliteCourante=1 
    then 
      begin
        for iCourant := 11 to 88 do 
          if coupPossible[iCourant] then ReponseInstantanee := iCourant;
      end
    else 
  if (NiveauJeuIntantaneVoulu=NiveauClubs)
    then
      begin
        VincenzChoice := ChoixDeVincenz(PositionEtTraitCourant(),1,true);
        ReponseInstantanee := VincenzChoice.bestMove;
        bestDef := VincenzChoice.bestDefense;
      end
    else
      begin
        yaffiche := 50;
        infini := noteMax;
        Superviseur(nbreCoup);
        calcul_position_centre(jeuCourant);
        maxCourant := -30000;
        
        for iCourant := 11 to 88 do
          if coupPossible[iCourant] then
            begin
              platInst := jeuCourant;
              JouablInst := emplJouable;
              frontInst := frontiereCourante;
              nbNoirInst := nbreDePions[pionNoir];
              nbBlancInst := nbreDePions[pionBlanc];
              bidonBool := ModifPlat(iCourant,aQuiDeJouer,platInst,JouablInst,
                                    nbBlancInst,nbNoirInst,frontInst);
                  
              case NiveauJeuIntantaneVoulu of
                NiveauDebutants :
                    begin
	                    eval := -EvaluationMaximisation(platInst,-aQuiDeJouer,nbBlancInst,nbNoirInst);
	                    if estUneCaseX(iCourant)
	                      then eval := eval+Random() mod 300
	                      else eval := eval+Random() mod 500;
	                  end;
                NiveauAmateurs :
                    begin
	                    eval := -EvaluationDesBords(platInst,-aQuiDeJouer,frontInst);
	                    if estUneCaseX(iCourant)
	                      then eval := eval - 500 - (Abs(Random()) mod 500)
	                      else eval := eval+Random() mod 100;
	                  end;
	              NiveauForts :
	                  begin
	                    eval := MyTrunc(105.0*EffectueMoveEtCalculePotentielVincenz(PositionEtTraitCourant(),iCourant,1));
	                    VincenzChoice := ChoixDeVincenz(MakePositionEtTrait(platInst,-aQuiDeJouer),1,false);
	                    eval := eval+MyTrunc(-10*VincenzChoice.sommePotentiels);
	                    eval := eval-(Evaluation(platInst,-aQuiDeJouer,nbBlancInst,nbNoirInst,JouablInst,frontInst,true,-30000,30000,nbEvalsRecursives) div 3);
	                    eval := eval+Random() mod 40;
	                    if eval> 6400 then eval := 6400;
	                    if eval<-6400 then eval := -6400;
	                    bestSuite := VincenzChoice.bestMove;
	                  end;
                NiveauExperts :
                    begin
	                    eval := -Evaluation(platInst,-aQuiDeJouer,nbBlancInst,nbNoirInst,
	                                                JouablInst,frontInst,true,-30000,-maxCourant,nbEvalsRecursives);
	                    if estUneCaseX(iCourant)
	                      then eval := eval - 500 + Random() mod 100
	                      else eval := eval + Random() mod 100;
	                  end;
	              NiveauGrandMaitres :
                    begin
                      oldInterruption := GetCurrentInterruption();
                      EnleveCetteInterruption(oldInterruption);
                      eval := -AB_simple(platInst,JouablInst,bestSuite,-aQuiDeJouer,0,
                                         -30000,-maxCourant,nbBlancInst,nbNoirInst,frontInst,false);
                      eval := eval + Random() mod 25;
                      LanceInterruption(oldInterruption,'ReponseInstantanee (1)');   
                    end;
                NiveauChampions :
                    begin
                      oldInterruption := GetCurrentInterruption();
                      EnleveCetteInterruption(oldInterruption);
                      eval := -AB_simple(platInst,JouablInst,bestSuite,-aQuiDeJouer,2,
                                         -30000,-maxCourant,nbBlancInst,nbNoirInst,frontInst,false);
                                         
                                         
                      if (interruptionReflexion <> pasdinterruption) then eval := -32000;               
                                         
                      LanceInterruption(oldInterruption,'ReponseInstantanee (2)');
                      
                      {WritelnPositionDansRapport(platInst);
                      WritelnStringAndNumDansRapport(CoupEnStringEnMajuscules(iCourant) + ' => ',eval);}
                    end;
              end; {case}
               
              if eval > maxCourant then
                begin
                  bestDef := bestSuite;
                  maxCourant := eval;
                  ReponseInstantanee := iCourant;
                end;
            end;
      end;
  
  {WritelnStringAndNumDansRapport('Resultat de ReponseInstantanee : ' + CoupEnStringEnMajuscules(bestSuite) + ' => ',maxCourant);}
  
  discretisationEvaluationEstOK := true;
end;


function ReponseInstantaneeTore(var bestDef : SInt32) : SInt32;
var platInst : plateauOthello;
    nbNoirInst,nbBlancInst : SInt32;
    platEssai : plateauOthello;
    nbNrEssai,nbBlcEssai : SInt32;
    coupPossible : plBool;
    yaffiche : SInt16; 
    mob : SInt32;
    i,iCourant,icourantEssai,meilDefEssai : SInt16; 
    eval,maxCourant,noteCourante,maxPourBestDef,infini : SInt16; 
    bidonBool : boolean;
begin
  if aQuiDeJouer=couleurMacintosh then EcritJeReflechis(couleurMacintosh);
  frontiereCourante.occupationTactique := 0;
  CarteMoveTore(aQuiDeJouer,jeuCourant,coupPossible,mob);
  if mob=1 
    then 
      begin
        for iCourant := 11 to 88 do 
          if coupPossible[iCourant] then ReponseInstantaneeTore := iCourant;
      end
    else 
      begin
        yaffiche := 50;
        infini := noteMax;
        Superviseur(nbreCoup);
        calcul_position_centre(jeuCourant);
        maxCourant := -noteMax;
        for iCourant := 11 to 88 do
          if coupPossible[iCourant] then
            begin
              platInst := jeuCourant;
              nbNoirInst := nbreDePions[pionNoir];
              nbBlancInst := nbreDePions[pionBlanc];
              bidonBool := ModifPlatTore(iCourant,aQuiDeJouer,platInst,nbBlancInst,nbNoirInst);
              
              {eval := -Evaluation(platInst,-aQuiDeJouer,nbBlancInst,nbNoirInst,JouablInst,frontInst,true,-30000,30000,nbEvalRecursives);}
              
              maxPourBestDef := -noteMax;
              platEssai := platInst;
              nbBlcEssai := nbBlancInst;
              nbNrEssai := nbNoirInst;
              i := 0;
              repeat
                i := i+1;
                icourantEssai := othellier[i];
                if platEssai[icourantEssai] = pionVide then 
                 begin
                   if ModifPlatTore(icourantEssai,-aQuiDeJouer,platEssai,
                                 nbBlcEssai,nbNrEssai)
                     then begin
                       if ((aQuiDeJouer = pionBlanc) & (nbBlcEssai<2)) |
                          ((aQuiDeJouer = pionNoir) & (nbNrEssai<2)) then
                            noteCourante := infini-1000
                       else
                          noteCourante := -EvaluationTore({platEssai,}aQuiDeJouer,nbBlcEssai,nbNrEssai);
                       if (noteCourante>maxPourBestDef) then 
                         begin
                           maxPourBestDef := noteCourante;
                           meilDefEssai := icourantEssai;
                         end;
                       platEssai := platInst;
                       nbBlcEssai := nbBlancInst;
                       nbNrEssai := nbNoirInst;
                     end;        
                  end;            
               until (i>=64) | (maxPourBestDef>-maxCourant);
               Eval := -maxPourBestDef;  
               if estUneCaseX(iCourant) then eval := eval-200;      
               
               
               
              if eval>maxCourant then
                begin
                  bestDef := meilDefEssai;
                  maxCourant := eval;
                  ReponseInstantaneeTore := iCourant;
                end;
            end;
      end;
end;


procedure ChoixMac(var ChoixX,whichNote,meiDef : SInt32;CoulChoix,niveau,nbblanc,nbNoir : SInt32; var plat : plateauOthello; var jouable : plBool; var fro : InfoFrontRec; const fonctionAppelante : str255);
var prof,typeFinaleDemande : SInt16; 
    numberCoup,nbremeilleur,causerejet : SInt32;
    scoreaatteindre : SInt16; 
    s255 : str255;
    ToujoursRamenerLaSuite,annonceDansRapport : boolean;
    resultatCalculMilieu : MoveRecord;
    bidbool : boolean;
    
    procedure CheckParameters(s : str255);
    begin
      WritelnDansRapport(s);
      WritelnStringAndNumDansRapport('  CoulChoix = ',CoulChoix);
      WritelnStringAndNumDansRapport('  niveau = ',niveau);
      WritelnStringAndNumDansRapport('  nbblanc = ',nbblanc);
      WritelnStringAndNumDansRapport('  nbNoir = ',nbNoir);
      WritelnDansRapport('  plat et CoulChoix = ');
      WritelnPositionEtTraitDansRapport(plat,CoulChoix);
      WritelnDansRapport('');
    end;
    
begin
   
  if not((CoulChoix = pionNoir) | (CoulChoix = pionBlanc)) |
     ((nbblanc < 0) | (nbblanc > 64)) |
     ((nbNoir < 0) | (nbNoir > 64)) |
     ((niveau < -1) | (niveau > 64)) then
    begin
      CheckParameters('ASSERT dans ChoixMac !');
      AlerteSimple('ASSERT dans ChoixMac!! Merci de prévenir Stéphane');
      exit(ChoixMac);
    end;
   
  if debuggage.gestionDuTemps then 
    CheckParameters('Entree dans ChoixMac , fonction appelante = ' + fonctionAppelante);

  ChoixX := 0;
  whichNote := -noteMax;
  meiDef := 0;

  {CheckParameters('après ChoixX := 0');}

  numberCoup := nbblanc+nbNoir-4;
  derniertick := TickCount()-tempsDesJoueurs[CoulChoix].tick;
  LanceChrono;
  tempsPrevu := 10;
  tempsAlloue := TempsPourCeCoup(nbreCoup,couleurMacintosh);
  if not(RefleSurTempsJoueur) & (aQuiDeJouer=couleurMacintosh) then
    begin
      EcritJeReflechis(coulChoix);
    end;
  ReinitilaliseInfosAffichageReflexion;
  EffaceReflexion;
  with InfosDerniereReflexionMac do
    begin
      nroDuCoup  := -1;
      coup       := 0;
      def        := 0;
      valeurCoup := -noteMax;
      coul       := pionVide;
      prof       := 0;
    end;
   
 {CheckParameters('apres ReinitilaliseInfosAffichageReflexion');}
 
 
 {
 if phaseDeLaPartie<=phaseMilieu then
      whichNote := -penalitePourTraitAff+Evaluation(plat,CoulChoix,nbBlanc,nbNoir,jouable,fro,true,-30000,30000,nbEvalRecursives);
 GOTOXY(5,24);
 Write('note de ce plat :',whichNote,'    ');
 }
 
 
 phaseDeLaPartie := CalculePhasePartie(numberCoup);
 Superviseur(numberCoup);
 if not(calculPrepHeurisFait) then
   Initialise_table_heuristique(jeuCourant);
 {afficheplat(fro.nbvide);}
 
 {CheckParameters('apres Initialise_table_heuristique');}

 if (nbreCoup=0) 
  then 
    begin
      CoupAuHazard(CoulChoix,plat,jouable,ChoixX,whichNote);
      {CheckParameters('apres CoupAuHazard');}
    end
  else
   begin
    {if (demo & (numberCoup<7) & not(avecBibl))
     then CoupAuHazard(CoulChoix,plat,jouable,ChoixX,whichNote)
     else}
     begin
       {CheckParameters('avant if (numberCoup=1) & not(positionFeerique)');}
       if (numberCoup=1) & not(positionFeerique) & not(CassioEstEnModeAnalyse())
        then 
          begin
            if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
              then TraiteEvenements
              else TraiteNullEvent(theEvent);
            if (interruptionReflexion = pasdinterruption) then 
              DeuxiemeCoupMac(choixX,whichNote);
          end
        else 
          begin
           IF (phaseDeLaPartie>=phaseFinale) then 
            begin
             prof := 60-numberCoup;
             typeFinaleDemande := ReflGagnant;
             if prof<=(60-finDePartie) then
               if CassioEstEnModeAnalyse() & not(CassioEstEnModeSolitaire())
                 then typeFinaleDemande := ReflGagnantExhaustif
                 else typeFinaleDemande := ReflGagnant;
             if prof<=(60-finDePartieOptimale) then 
               if CassioEstEnModeAnalyse() & not(CassioEstEnModeSolitaire())
                 then typeFinaleDemande := ReflParfaitExhaustif
                 else typeFinaleDemande := ReflParfait;
             
             if afficheMeilleureSuite then DetruitMeilleureSuite;
             if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
             if finaleEnModeSolitaire & (typeFinaleDemande=ReflParfait)
               then
                 begin
                   scoreaatteindre := 64;
                   if CassioEstEnModeSolitaire() then
                     if positionfeerique & (DerniereCaseJouee() = coupInconnu) then
                       begin
                         s255 := CommentaireSolitaire^^;
                         if ((Pos(ReadStringFromRessource(TextesSolitairesID,19),s255)>0) & (CoulChoix = pionNoir)) |
                            ((Pos(ReadStringFromRessource(TextesSolitairesID,20),s255)>0) & (CoulChoix = pionBlanc)) then
                              begin
                                (* reduire la fenetre pour le premier coup du solitaire  *)
                                if Pos(ReadStringFromRessource(TextesSolitairesID,5),s255) > 0  {'gagne'}
                                then scoreaatteindre := +1
                                else scoreaatteindre := 0 ;
                              end;
                       end;
                    bidbool := EstUnSolitaire(choixX,meiDef,CoulChoix,prof,nbblanc,nbnoir,plat,jouable,
                                            fro,whichNote,nbremeilleur,true,causerejet,kJeuNormal,scoreaatteindre);
                 end                                          
               else
                 begin
                   ToujoursRamenerLaSuite := false;
                   annonceDansRapport := true;
                   
                   bidbool := CoupGagnant(choixX,meiDef,CoulChoix,prof,nbblanc,nbnoir,GetCurrentNode(),plat,jouable,fro,NIL,
                                                 whichNote,annonceDansRapport,ToujoursRamenerLaSuite,typeFinaleDemande)
                   
                 end;
            end
          else
            begin
             {CheckParameters('avant Calcule_Valeurs_Tactiques');}   
              Calcule_Valeurs_Tactiques(plat,true);
             {CheckParameters('avant CalculeMeilleurCoupMilieuDePartie');}  
              resultatCalculMilieu := CalculeMeilleurCoupMilieuDePartie(plat,jouable,fro,CoulChoix,niveau,nbblanc,nbnoir);
             {CheckParameters('apres CalculeMeilleurCoupMilieuDePartie');
              WritelnStringAndNumDansRapport('resultatCalculMilieu.theDefense = ',resultatCalculMilieu.theDefense);}
              choixX      := resultatCalculMilieu.x;
              whichNote   := resultatCalculMilieu.note;
              meiDef      := resultatCalculMilieu.theDefense;
            end;
         end; 
      end;
   end;
   
 {CheckParameters('avant ChoixMac(1)');} 
  if (interruptionReflexion <> pasdinterruption) & not(vaDepasserTemps) then   {si interruption brutale...}
    TraiteInterruptionBrutale(choixX,meiDef,'ChoixMac(1)');
 {CheckParameters('avant HasGotEvent');}  
  if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
    then TraiteEvenements
    else TraiteNullEvent(theEvent);
 {CheckParameters('avant ChoixMac(2)');}
  if (interruptionReflexion <> pasdinterruption) & not(vaDepasserTemps) then    {si interruption brutale...}
    TraiteInterruptionBrutale(choixX,meiDef,'ChoixMac(2)');
 {CheckParameters('avant DerniereHeure');}
  DerniereHeure(CoulChoix);
 {CheckParameters('sortie de ChoixMac');}
 if debuggage.gestionDuTemps then
    WritelnDansRapport('Sortie de ChoixMac , fonction appelante = ' + fonctionAppelante);
      
end;  

function ConnaitSuiteParfaite(var ChoixX,MeilleurDef : SInt32;autorisationTemporisation : boolean) : boolean;
var i,coup,aux : SInt16; 
    ok : boolean;
begin
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
 
  if debuggage.calculFinaleOptimaleParOptimalite & (nbreCoup>30) then
   begin
     WritelnDansRapport('');
     WritelnDansRapport('Entrée dans ConnaitSuiteParfaite :');
     for i := 32 to 60 do
       begin
         WriteStringAndNumDansRapport('coup ',i);
         aux := partie^^[i].coupParfait;
         WriteStringDansRapport(' : '+CoupEnStringEnMajuscules(aux));
         if partie^^[i].optimal
           then WritelnStringDansRapport(' optimal  ')
           else WritelnStringDansRapport(' non optimal ');
       end;
   end;
 

  ConnaitSuiteParfaite := false;
  ChoixX := 44; 
  MeilleurDef := 44;
  ok := not(gameOver) & (nbreCoup<60) & (interruptionReflexion = pasdinterruption);
  ok := ok & (not(CassioEstEnModeSolitaire()) | (aQuiDeJouer=-couleurMacintosh));
  if ok then for i := 1 to nbreCoup do
                 ok := (ok & (GetNiemeCoupPartieCourante(i)=partie^^[i].coupParfait));
  if ok then ok := (ok & partie^^[nbreCoup+1].optimal);
  if ok then
    begin
      coup := partie^^[nbreCoup+1].coupParfait;
      aux := partie^^[nbreCoup+2].coupParfait;
      if (coup<11) | (coup>88) then ok := false;
      if ok & possibleMove[coup] 
         then
           begin
             ConnaitSuiteParfaite := true;
             ChoixX := coup;
             if partie^^[nbreCoup+2].optimal then
               if (aux>=11) & (aux<=88) then 
                 MeilleurDef := aux;
             if CassioEstEnModeSolitaire() & (aQuiDeJouer=couleurMacintosh) & autorisationTemporisation
               then TemporisationSolitaire;
           end
         else
           ok := false;
    end;    
 
 if ok & ((interruptionReflexion = pasdinterruption) | vaDepasserTemps)
    then EcritMeilleureSuiteParOptimalite;
 
 
 if (interruptionReflexion <> pasdinterruption) & not(vaDepasserTemps)    {si interruption brutale...}
    then 
      TraiteInterruptionBrutale(choixX,MeilleurDef,'ConnaitSuiteParfaite');
end;


procedure ChoixMacStandard(var choixX,note,meilleurDef : SInt32;CoulChoix,niveau : SInt16; const fonctionAppelante : str255);  
const 
  kGrapheDonneCoupIllegalID = 23;
  kBibliothequeDonneCoupIllegalID = 28;
  kConnaitSuiteParfaiteDonneCoupIllegalID = 29;
  kReponseInstantaneeDonneCoupIllegalID = 30;
  kChoixMacDonneCoupIllegalID = 31;
var nbBlanc,nbNoir : SInt32;
    doitRechercherEnProf : boolean;
    doitChercherDansBibl : boolean;
    the_best_move,the_best_defense : SInt32;
    nbReponsesEnBibliotheque : SInt32;
    laBibliothequeEstCapableDeFournirUnCoup : boolean;
    
  procedure ValiderLegaliteDuCoupCalcule(coupPropose,defenseProposee : SInt16; messageErreurID : SInt16);
  begin
    if debuggage.gestionDuTemps then
      begin
        WriteStringAndNumDansRapport('   …dans ValiderLegaliteDuCoupCalcule, coupPropose = '+CoupEnString(coupPropose,true)+'<->',coupPropose);
        WritelnStringAndNumDansRapport('   …dans ValiderLegaliteDuCoupCalcule, defenseProposee = '+CoupEnString(defenseProposee,true)+'<->',defenseProposee);
      end;
    if (coupPropose>=11) & (coupPropose<=88) & possibleMove[coupPropose] 
      then
        begin
          choixX := coupPropose;
          if (defenseProposee>=11) & (defenseProposee<=88) 
            then meilleurDef := defenseProposee
            else meilleurDef := 44;
        end
      else
        begin
          if (interruptionReflexion = pasdinterruption) then
            begin
              {'LE GRAPHE D''APPRENTISSAGE PROPOSE UN COUP ILLEGAL !!!!' ou la bibliotheque, reponseInstantanee, etc.}
              WritelnDansRapport(ReadStringFromRessource(TextesRapportID,messageErreurID));
              AlerteSimple(ReadStringFromRessource(TextesRapportID,messageErreurID));
            end;
          choixX := 44;
          meilleurDef := 44;
          doitRechercherEnProf := true;
        end;
  end;
    
begin
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
  doitRechercherEnProf := true;
  
  if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('Entrée dans ChoixMacStandard (fonction appelante = '+fonctionAppelante+') avec la position courante suivante :');
      WritelnPositionEtTraitDansRapport(PositionEtTraitCourant().position,GetTraitOfPosition(PositionEtTraitCourant()));
      WritelnStringAndNumDansRapport('interruptionReflexion=',interruptionReflexion);
      WritelnDansRapport('');
    end;
  
  if doitRechercherEnProf & UtiliseGrapheApprentissage & not(positionFeerique) & (nbreCoup>=5) & 
     not(CassioEstEnModeAnalyse() & not(HumCtreHum)) then
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de PeutChoisirDansGrapheApprentissage par ChoixMacStandard');
    
      doitRechercherEnProf := not(PeutChoisirDansGrapheApprentissage(the_best_move,the_best_defense));  
      if not(doitRechercherEnProf) then 
        ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kGrapheDonneCoupIllegalID);
    end;
  
  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après PeutChoisirDansGrapheApprentissage, doitRechercherEnProf=',doitRechercherEnProf);
      WritelnStringAndNumDansRapport(', interruptionReflexion=',interruptionReflexion);
    end;
  
  with gEntrainementOuvertures do
    begin
      if positionFeerique | (CassioEstEnModeAnalyse() & not(HumCtreHum) {& (CoulChoix = couleurMacintosh)})
        then doitChercherDansBibl := false
        else doitChercherDansBibl := true;
      
      {quatre chance sur cinq d'utiliser la bibliotheque plutot que les variations du milieu}
		  if CassioVarieSesCoups & (modeVariation=kVarierEnUtilisantMilieu) & 
		     avecBibl & (nbreCoup <= LongMaxBibl) & (CoulChoix=couleurMacintosh)
		    then doitChercherDansBibl := doitChercherDansBibl & PChancesSurN(4,5);
		  
		  
			if doitRechercherEnProf & doitChercherDansBibl & (phaseDeLaPartie<=phaseMilieu) & (nbreCoup<=LongMaxBibl) then 
		    begin
		      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de PeutChoisirEnBibl par ChoixMacStandard');
		    
		      if avecBibl | (jeuInstantane & (NiveauJeuInstantane <= NiveauChampions))
            then 
              begin
                if CassioVarieSesCoups |
		               (jeuInstantane & (NiveauJeuInstantane <= NiveauForts))  {on sort parfois de la bibl expres}
		              then laBibliothequeEstCapableDeFournirUnCoup := PeutChoisirEnBibl(the_best_move,the_best_defense,true,nbReponsesEnBibliotheque)
		              else laBibliothequeEstCapableDeFournirUnCoup := PeutChoisirEnBibl(the_best_move,the_best_defense,false,nbReponsesEnBibliotheque);
		              
		            if laBibliothequeEstCapableDeFournirUnCoup & (nbReponsesEnBibliotheque = 1) & CassioVarieSesCoups & PChancesSurN(1,5)
                  then laBibliothequeEstCapableDeFournirUnCoup := false;
		                              
                if debuggage.gestionDuTemps then
                  begin
                    WritelnStringAndBoolDansRapport('laBibliothequeEstCapableDeFournirUnCoup = ',laBibliothequeEstCapableDeFournirUnCoup);
                    WritelnStringAndNumDansRapport('nbReponsesEnBibliotheque = ',nbReponsesEnBibliotheque);
                    WritelnStringAndCoupDansRapport('the_best_move = ',the_best_move);
                    WritelnStringAndCoupDansRapport('the_best_defense = ',the_best_defense);
                  end;
                
              end
            else 
              begin
                laBibliothequeEstCapableDeFournirUnCoup := false;
                nbReponsesEnBibliotheque := 0;
              end;
                
	        doitRechercherEnProf := not(laBibliothequeEstCapableDeFournirUnCoup);
		       
		      if not(doitRechercherEnProf) then 
		        ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kBibliothequeDonneCoupIllegalID);
		    end;
    end;
  
  
  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après PeutChoisirEnBibl, doitRechercherEnProf=',doitRechercherEnProf);
      WritelnStringAndNumDansRapport(', interruptionReflexion=',interruptionReflexion);
    end;
    
  if doitRechercherEnProf & (phaseDeLaPartie>=phaseFinale) & not(CassioEstEnModeAnalyse()) then
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de ConnaitSuiteParfaite par ChoixMacStandard');
      
      doitRechercherEnProf := not(ConnaitSuiteParfaite(the_best_move,the_best_defense,true));
      if not(doitRechercherEnProf) then 
        ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kConnaitSuiteParfaiteDonneCoupIllegalID);
    end;
     
  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après ConnaitSuiteParfaite, doitRechercherEnProf=',doitRechercherEnProf);
      WritelnStringAndNumDansRapport(', interruptionReflexion=',interruptionReflexion);
    end;
  
  if doitRechercherEnProf & jeuInstantane & (phaseDeLaPartie<=phaseMilieu) & (aQuiDeJouer=couleurMacintosh) then
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de ReponseInstantanee par ChoixMacStandard');
      
      if OthelloTorique 
        then the_best_move := ReponseInstantaneeTore(the_best_defense)
        else the_best_move := ReponseInstantanee(the_best_defense,NiveauJeuInstantane);
      if (the_best_move>=0) & (the_best_move<=99) & possibleMove[the_best_move] then
          doitRechercherEnProf := false;
      if not(doitRechercherEnProf) then 
        ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kReponseInstantaneeDonneCoupIllegalID);
    end;
  
      
  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après ReponseInstantanee, doitRechercherEnProf=',doitRechercherEnProf);
      WritelnStringAndNumDansRapport(', interruptionReflexion=',interruptionReflexion);
    end; 
    
  if doitRechercherEnProf then
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de ChoixMac par ChoixMacStandard');
      
      nbBlanc := nbreDePions[pionBlanc];
      nbNoir := nbreDePions[pionNoir];
      ChoixMac(the_best_move,note,the_best_defense,CoulChoix,niveau,nbblanc,nbNoir,jeuCourant,emplJouable,frontiereCourante,'ChoixMacStandard');
      ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kChoixMacDonneCoupIllegalID);
    end;
  
         
  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après ChoixMac, doitRechercherEnProf=',doitRechercherEnProf);
      WritelnStringAndNumDansRapport(', interruptionReflexion=',interruptionReflexion);
    end;  
     
  if (interruptionReflexion <> pasdinterruption) & not(vaDepasserTemps) then   {si interruption brutale...}
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de TraiteInterruptionBrutale(choixX,meilleurDef) à la fin de ChoixMacStandard');
      TraiteInterruptionBrutale(choixX,meilleurDef,'ChoixMacStandard');
    end;
  
  if debuggage.gestionDuTemps then 
    begin
      WritelnDansRapport('Sortie de ChoixMacStandard (fonction appelante = '+fonctionAppelante+') avec la position courante suivante :');
      WritelnPositionEtTraitDansRapport(PositionEtTraitCourant().position,GetTraitOfPosition(PositionEtTraitCourant()));
    end;
end;

procedure DealWithEssai(whichSquare : SInt16; const fonctionAppelante : str255);
const SonDePasseID=131;
var mobilite,tempoAquiDeJouer : SInt32;
    oldport : grafPtr;
    coupEstLegal : boolean;
    s : str255;
begin
 {
 if not(HumCtreHum) & (interruptionReflexion <> pasdinterruption) & not(vaDepasserTemps) 
  then
    begin
      (** on ne fait rien.                           **)
      (** note: enlever les commentaires ci-dessus    **)
      (** pour être très rigoureux; mais on rate     **)
      (** alors parfois des clics.                    **)      
    end
  else
  }
  
 {WritelnDansRapport('Dans DealWithEssai(), fonctionAppelante = '+fonctionAppelante);}
  
    begin
      if (whichSquare < 11) | (whichSquare > 88) then
        begin
          AlerteSimple('ASSERT : (whichSquare < 11) | (whichSquare > 88) dans DealWithEssai!! Merci de prévenir Stéphane');
          WritelnDansRapport('ASSERT : (whichSquare < 11) | (whichSquare > 88) dans DealWithEssai !!');
          WritelnStringAndNumDansRapport('  pour infos : whichSquare = ',whichSquare);
          WritelnDansRapport('  fonction appelante = '+fonctionAppelante);
          SysBeep(0);
          exit(DealWithEssai);
        end;
        
      if not(possibleMove[whichSquare]) then 
        begin
          if debuggage.general then
            if windowPlateauOpen then
            begin           
              GetPort(oldport);
              SetPortByWindow(wPlateauPtr);
              case aQuiDeJouer of 
                 pionBlanc:s := 'Probleme : Blanc';
                 pionNoir:s := 'Probleme : Noir';
              end;
              s := s+' veut jouer en '+CHR(64+whichSquare mod 10);
              WriteStringAndNumAt(s,whichSquare div 10,10,100);
              SetPort(oldport);
            end;
        end
      else
        begin
         if not(HumCtreHum) & (aQuiDeJouer=couleurMacintosh) & CassioEstEnModeSolitaire() then
           if (partie^^[nbreCoup].trait=aQuiDeJouer)
              then TemporisationArnaqueFinale;
      
         {$UNUSED tempoAquiDeJouer}
         (** enlever les commentaires suivant pour changer la couleur du curseur AVANT de retourner les pions… **)
         tempoAquiDeJouer := aQuiDeJouer;
         aQuiDeJouer := -tempoAquiDeJouer;
         AjusteCurseur;
         aQuiDeJouer := tempoAquiDeJouer;
         
         if JoueEn(whichSquare,aQuiDeJouer,coupEstLegal,not(demo),true) then
           begin
             AjusteCurseur;
             if OthelloTorique 
               then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
               else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
             if mobilite=0 then
               begin
                 aQuiDeJouer := -aQuiDeJouer;
                 if OthelloTorique
                   then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
                   else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
                 if mobilite=0 
                   then 
                     begin
                       TachesUsuellesPourGameOver;
                       VideMeilleureSuiteInfos;
                       AnnonceScoreFinalDansRapport;
                       JoueSonPourGameOver;
                       AjustementAutomatiqueDuNiveauDeJeuInstantane;
                       FixeMarqueSurMenuMode(nbreCoup);
                     end
                   else
                     begin
                       if avecSon {& not(CassioEstEnModeSolitaire())} then 
                         PlaySoundSynchrone(SonDePasseID);
                       if (jeuInstantane | enModeIOS | (nbExplicationsPasses >= 10000)) & 
                          (PassesDejaExpliques<nbExplicationsPasses) &
                          not(HumCtreHum) & (aQuiDeJouer=couleurMacintosh) & not(demo) then
                           begin
                             if not(avecSon) then PlaySoundSynchrone(SonDePasseID); {si avecSon on a deja sonné : cf plus haut}
                             DialogueVousPassez; 
                           end;
                     end;
               end;
            end;
         AjusteCurseur;
         if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
           then LanceCalculsRapidesPourBaseOuNouvelleDemande(nroDernierCoupAtteint > nbreCoup,true);
         if (HumCtreHum | (aQuiDeJouer <> couleurMacintosh)) & not(demo) then
	         begin
	           MyDisableItem(PartieMenu,Forcecmd);
	           AfficheDemandeCoup;
	         end;
	       
	       if avecInterversions & (nbreCoup >= 1) & (nbreCoup <= numeroCoupMaxPourRechercheIntervesionDansArbre) 
	         then GererInterversionDeCeNoeud(GetCurrentNode(),PositionEtTraitCourant());
      end;  
  end;         
end;


procedure Jouer(var aQuiDeJouer : SInt16; whichSquare : SInt16; const fonctionAppelante : str255);
var caseCritiqueTurbulence,a : SInt32;
    {Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32;}
begin

 if (whichSquare < 11) | (whichSquare > 88) then
   begin
     AlerteSimple('ASSERT : (whichSquare < 11) | (whichSquare > 88) dans Jouer() !! Merci de prévenir Stéphane');
     WritelnDansRapport('ASSERT : (whichSquare < 11) | (whichSquare > 88) dans Jeu !');
     WritelnStringAndNumDansRapport('  pour infos : whichSquare = ',whichSquare);
     WritelnDansRapport('  fonction appelante = '+fonctionAppelante);
     SysBeep(0);
     exit(Jouer);
   end;

 {WritelnDansRapport('Dans Jouer(), fonction appelante = '+fonctionAppelante);}

 { Ces lignes (if...) font des problemes de recurrences non voulues dans TraiteCoupImprevu :-( }
 if (aQuiDeJouer=couleurMacintosh) & not(HumCtreHum) then
   begin
      if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
		    then TraiteEvenements
		    else TraiteNullEvent(theEvent);
       
     if aQuiDeJouer=couleurMacintosh then 
       begin
         DealWithEssai(whichSquare,'Jouer(1)');
       end;
   end
  else
   begin
     DealWithEssai(whichSquare,'Jouer(2)');
   end;
 
 
 if debuggage.elementsStrategiques then
   if EstTurbulent(jeuCourant,aQuiDeJouer,nbreDePions[pionNoir],nbreDePions[pionBlanc],frontiereCourante,caseCritiqueTurbulence) 
     then WriteStringAt('position turbulente : il faut jouer '+CoupEnStringEnMajuscules(caseCritiqueTurbulence)+' !',500,100)
     else WriteStringAt('position non turbulente                  ',500,100);
 
 
 if debuggage.elementsStrategiques then
   if not(PasDeBordDeCinqAttaque(aQuiDeJouer,frontiereCourante,jeuCourant))
     then WriteStringAndNumAt('bord de cinq attaqué ',0,100,110)
     else WriteStringAndNumAt('                        ',0,100,110);
 
 if debuggage.elementsStrategiques then
   begin
     a := nbBordDeCinqTransformablesPourBlanc(jeuCourant,frontiereCourante);
     if a <> 0
       then WriteStringAndNumAt('nb bord de cinq transformable pour Blanc',a,100,110)
       else WriteStringAndNumAt('                                                 ',0,100,110);
   end;
 
if debuggage.elementsStrategiques then
   begin
     a := TrousDeTroisNoirsHorribles(jeuCourant);
     WriteStringAndNumAt('trous noirs ',a,100,110);
     a := TrousDeTroisBlancsHorribles(jeuCourant);
     WriteStringAndNumAt('trous blancs ',a,100,120);
   end;  
 
 if debuggage.elementsStrategiques then
   begin
     a := LibertesNoiresSurCasesA(jeuCourant,frontiereCourante);
     WriteStringAndNumAt('lib noires sur case A ',a,100,110);
     a := LibertesBlanchesSurCasesA(jeuCourant,frontiereCourante);
     WriteStringAndNumAt('lib blanches sur case A  ',a,100,120);
   end;  
 
 
 if debuggage.elementsStrategiques then
   begin
     a := ArnaqueSurBordDeCinqNoir(jeuCourant,frontiereCourante);
     WriteStringAndNumAt('arnaque noire sur bord de 5 ',a,100,110);
     a := ArnaqueSurBordDeCinqBlanc(jeuCourant,frontiereCourante);
     WriteStringAndNumAt('arnaque blanche sur bord de 5 ',a,100,120);
   end;  
  
 (*
 with frontiereCourante do
   begin
     WritelnStringAndNumDansRapport('bord nord nouveau =',AdressePattern[kAdresseBordNord]);     
     WritelnStringAndNumDansRapport('bord sud nouveau =',AdressePattern[kAdresseBordSud]);     
     WritelnStringAndNumDansRapport('bord ouest nouveau =',AdressePattern[kAdresseBordOuest]);     
     WritelnStringAndNumDansRapport('bord est nouveau =',AdressePattern[kAdresseBordEst]);     
     WritelnDansRapport('');
   end;
 *)
 
 (*
 with frontiereCourante do
   begin
     Writeln13SquareCornerAndStringDansRapport(AdressePattern[kAdresseBlocCoinA1],'kAdresseBlocCoinA1');     
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(SymmetricalMapping13SquaresCorner(AdressePattern[kAdresseBlocCoinA1]),'kAdresseBlocCoinA1 (symetrique)');   
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(AdressePattern[kAdresseBlocCoinH1],'kAdresseBlocCoinH1');     
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(SymmetricalMapping13SquaresCorner(AdressePattern[kAdresseBlocCoinH1]),'kAdresseBlocCoinH1 (symetrique)');     
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(AdressePattern[kAdresseBlocCoinA8],'kAdresseBlocCoinA8');     
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(SymmetricalMapping13SquaresCorner(AdressePattern[kAdresseBlocCoinA8]),'kAdresseBlocCoinA8 (symetrique)');     
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(AdressePattern[kAdresseBlocCoinH8],'kAdresseBlocCoinH8');     
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(SymmetricalMapping13SquaresCorner(AdressePattern[kAdresseBlocCoinH8]),'kAdresseBlocCoinH8 (symetrique)');     
     WritelnDansRapport('');
   end;
 *)
 
 (*
 CalculeIndexesEdges2X(jeuCourant,frontiereCourante,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst);
 WritelnEdge2XAndStringDansRapport(Edge2XNord,'edge2X nord');
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(SymmetricalMappingEdge2X(Edge2XNord),'edge2X nord (symetrique)');   
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(Edge2XOuest,'edge2X ouest');  
 WritelnDansRapport('');   
 WritelnEdge2XAndStringDansRapport(SymmetricalMappingEdge2X(Edge2XOuest),'edge2X ouest (symetrique)');   
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(Edge2XEst,'edge2X est');  
 WritelnDansRapport('');   
 WritelnEdge2XAndStringDansRapport(SymmetricalMappingEdge2X(Edge2XEst),'edge2X est (symetrique)');   
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(Edge2XSud,'edge2X sud');     
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(SymmetricalMappingEdge2X(Edge2XSud),'edge2X sud (symetrique)');   
 WritelnDansRapport('');
 

 with frontiereCourante do
   begin
     WritelnLinePatternAndStringDansRapport(AdressePattern[kAdresseDiagonaleA3F8],6,'kAdresseDiagonaleA3F8');     
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(SymmetricalMapping6SquaresLine(AdressePattern[kAdresseDiagonaleA3F8]),6,'kAdresseDiagonaleA3F8 (symetrique)');   
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(AdressePattern[kAdresseDiagonaleC1H6],6,'kAdresseDiagonaleC1H6');     
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(SymmetricalMapping6SquaresLine(AdressePattern[kAdresseDiagonaleC1H6]),6,'kAdresseDiagonaleC1H6 (symetrique)');     
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(AdressePattern[kAdresseDiagonaleA6F1],6,'kAdresseDiagonaleA6F1');     
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(SymmetricalMapping6SquaresLine(AdressePattern[kAdresseDiagonaleA6F1]),6,'kAdresseDiagonaleA6F1 (symetrique)');     
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(AdressePattern[kAdresseDiagonaleC8H3],6,'kAdresseDiagonaleC8H3');     
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(SymmetricalMapping6SquaresLine(AdressePattern[kAdresseDiagonaleC8H3]),6,'kAdresseDiagonaleC8H3 (symetrique)');     
     WritelnDansRapport('');
   end;
   *)
   
end;


procedure EcritStructureDesCalculsDansJeuMac(const message : str255);
begin {$UNUSED message}
  {WritelnDansRapport(message);}
end;


procedure AfficheDebugageEntreeDansJeuMac(const fonctionAppelante : str255; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
begin
  if debuggage.gestionDuTemps then 
    begin
      WritelnDansRapport('');
      WritelnDansRapport('entrée dans JeuMac, fonction appelante = '+fonctionAppelante);
      WritelnDansRapport('à l''entrée dans JeuMac : position et trait courant =');
      WritelnPositionEtTraitDansRapport(positionEtTraitDeLAppelReflexionDeMac.position,GetTraitOfPosition(positionEtTraitDeLAppelReflexionDeMac));
      EcritTypeInterruptionDansRapport(interruptionReflexion);
      WritelnStringAndBoolDansRapport('vaDepasserTemps = ',vaDepasserTemps);
      WritelnStringAndBoolDansRapport('reponsePrete = ',reponsePrete);
      WritelnStringAndCoupDansRapport('meilleureReponsePrete = ',meilleureReponsePrete);
      WritelnStringAndCoupDansRapport('MeilleurCoupHumPret = ',MeilleurCoupHumPret);
      WritelnStringAndBoolDansRapport('RefleSurTempsJoueur = ',RefleSurTempsJoueur);
      WritelnDansRapport('');
    end;
end;


procedure AfficheDebuggageSortieDeJeuMac;
begin
  if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('sortie de JeuMac :');
      EcritTypeInterruptionDansRapport(interruptionReflexion);
      WritelnStringAndBoolDansRapport('vaDepasserTemps = ',vaDepasserTemps);
      WritelnStringAndBoolDansRapport('reponsePrete = ',reponsePrete);
      WritelnStringAndBoolDansRapport('RefleSurTempsJoueur = ',RefleSurTempsJoueur);
    end;
end;


function InterruptionReflexionDansJeuMac() : boolean;
begin
  if (interruptionReflexion = pasdinterruption) 
    then InterruptionReflexionDansJeuMac := false
    else
      begin
        if vaDepasserTemps & (interruptionReflexion = interruptionDepassementTemps)
          then InterruptionReflexionDansJeuMac := false
          else InterruptionReflexionDansJeuMac := true;
      end;
end;

 
procedure ReflexionInitialeDuMacintoshDansJeuMac(var coupMac : SInt32;niveau : SInt32; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
var oldInterruption : SInt16; 
    note : SInt32;
begin
  EcritStructureDesCalculsDansJeuMac('entrée dans ReflexionInitialeDuMacintoshDansJeuMac');
  
  coupMac := 0;
  
  if (aQuiDeJouer = couleurMacintosh) & not(Quitter) then
	  begin
	    if (meilleureReponsePrete < 11) | (meilleureReponsePrete > 88) 
	      then meilleureReponsePrete := 44;
	      
		  reponsePrete := reponsePrete & (jeuCourant[meilleureReponsePrete] = pionVide) & possibleMove[meilleureReponsePrete];
		  if not(reponsePrete) 
		    then
			    begin
			      RefleSurTempsJoueur := false;
			      vaDepasserTemps := false;
			      EnableItemPourCassio(PartieMenu,ForceCmd);
			      oldInterruption := GetCurrentInterruption();
			      EnleveCetteInterruption(oldInterruption);
			      if debuggage.gestionDuTemps then
              begin
                WritelnStringAndNumDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (aQuiDeJouer=couleurMacintosh) : oldInterruption=',oldInterruption);
                WritelnStringDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (aQuiDeJouer=couleurMacintosh) : appel de ChoixMacStandard');
              end;
			      ChoixMacStandard(coupMac,note,meilleurCoupHum,aQuiDeJouer,niveau,'ReflexionInitialeDuMacintoshDansJeuMac');
			      LanceInterruption(oldInterruption,'ReflexionInitialeDuMacintoshDansJeuMac');
			      if debuggage.gestionDuTemps then
              begin
                WritelnStringAndCoupDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (aQuiDeJouer=couleurMacintosh) : après ChoixMacStandard, coupMac=',coupMac);
                WritelnStringAndNumDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (aQuiDeJouer=couleurMacintosh) : après ChoixMacStandard, GetCurrentInterruption()=',GetCurrentInterruption());
                WritelnStringAndBoolDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (aQuiDeJouer=couleurMacintosh) : après ChoixMacStandard, vaDepasserTemps=',vaDepasserTemps);
              end;
			    end 
		    else
			    begin
			      coupMac := meilleureReponsePrete;
			      meilleurCoupHum := MeilleurCoupHumPret;
			      if CassioEstEnModeSolitaire() then TemporisationSolitaire;
			      if debuggage.gestionDuTemps then
              WritelnStringDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac, j''essaie d''utiliser la reponse prete…');
			    end;
			
			if not(CassioEstEnModeSolitaire()) & (aQuiDeJouer=couleurMacintosh) & (interruptionReflexion = pasdinterruption) &
			   CassioEstEnModeAnalyse() & not(HumCtreHum)
			  then
			    begin
			      ActiverSuggestionDeCassio(positionEtTraitDeLAppelReflexionDeMac,coupMac,meilleurCoupHum,'ReflexionInitialeDuMacintoshDansJeuMac');
			    end;
	  end;
	EcritStructureDesCalculsDansJeuMac('sortie de ReflexionInitialeDuMacintoshDansJeuMac');
end;


procedure CheckEventsDansJeuMac(const whereAmI : str255);
begin
  if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
    then 
      begin
        if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('dans JeuMac, appel de TraiteEvement pour ' + whereAmI);
        TraiteEvenements;
        if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('dans JeuMac, fin de l''appel de TraiteEvement pour ' + whereAmI);
      end
    else 
      begin
        if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('dans JeuMac, appel de TraiteNullEvent pour ' + whereAmI);
        TraiteNullEvent(theEvent);
        if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('dans JeuMac, fin de l''appel de TraiteNullEvent pour ' + whereAmI);
      end;
end;


procedure AfficheInfosDebugage1DansJeuMac(var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
begin
  if debuggage.gestionDuTemps then
    begin
      WritelnStringAndNumDansRapport('dans JeuMac  : avant REPEAT, GetCurrentInterruption()=',GetCurrentInterruption());
      WritelnStringAndBoolDansRapport('dans JeuMac  : avant REPEAT, vaDepasserTemps=',vaDepasserTemps);
      WritelnDansRapport('dans JeuMac  : avant REPEAT, position et trait courants =');
      WritelnPositionEtTraitDansRapport(PositionEtTraitCourant().position,GetTraitOfPosition(PositionEtTraitCourant()));
    end;
		  
  if debuggage.gestionDuTemps &
     (interruptionReflexion = pasdinterruption) & (aQuiDeJouer=couleurMacintosh) &
     not(SamePositionEtTrait(positionEtTraitDeLAppelReflexionDeMac,PositionEtTraitCourant())) then
    begin
      WritelnDansRapport('AHAH ! positionEtTraitDeLAppelReflexionDeMac <> PositionEtTraitCourant() dans AfficheInfosDebugage1DansJeuMac!');
      SysBeep(0);
    end;
end;


procedure AfficheInfosDebugage2DansJeuMac(coupMac,auxCoupHum : SInt32);
begin
  if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('dans AfficheInfosDebugage2DansJeuMac, voici la situation :');
      WritelnStringAndCoupDansRapport('coupMac = ',coupMac);
      WritelnStringAndCoupDansRapport('auxCoupHum = ',auxCoupHum);
      EcritTypeInterruptionDansRapport(interruptionReflexion);
      WritelnStringAndBoolDansRapport('vaDepasserTemps = ',vaDepasserTemps);
      WritelnStringAndBoolDansRapport('RefleSurTempsJoueur = ',RefleSurTempsJoueur);
      WritelnDansRapport('');
    end;
end;


procedure JouerUnCoupDuMacintoshDansJeuMac(var coupMac : SInt32; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec; const fonctionAppelante : str255);
var conditionsCorrectesPourJouerLeCoup : boolean;
    tickPourJouerLeCoup : SInt32;
    dateDuDernierCoup : SInt32;
begin
  EcritStructureDesCalculsDansJeuMac('entrée dans JouerUnCoupDuMacintoshDansJeuMac');
  
  if (TickCount() > DateOfLastKeyboardOperation() + 15) 
    then tickPourJouerLeCoup := -1000                    (* c'est-à-dire que l'on peut le jouer immediatement *)
    else
      { attendre un peu si l'utilisateur vient de taper une touche }
      if NoDelayAfterKeyboardOperation() 
        then tickPourJouerLeCoup := TickCount() + 5
        else tickPourJouerLeCoup := DateOfLastKeyboardOperation() + 15;
  
  { si on est dans un niveau de jeu instantané, il y a un petit delai avant d'afficher le coup }
  if (DoitTemporiserPourRetournerLesPions() & (GetDelaiDeRetournementDesPions() > 0)) then
    begin
      dateDuDernierCoup := GetDateEnTickDuCoupNumero(nbreCoup);
      if (tickPourJouerLeCoup < dateDuDernierCoup + 30) then
        tickPourJouerLeCoup := dateDuDernierCoup + 30;
    end;
  
  { on verifie que tout est toujours bon pour jouer le coup }
  conditionsCorrectesPourJouerLeCoup := true;
  while conditionsCorrectesPourJouerLeCoup & (TickCount() < tickPourJouerLeCoup) do
    begin
    
      if HasGotEvent(everyEvent,theEvent,1,NIL) then TraiteEvenements;
      
      conditionsCorrectesPourJouerLeCoup := conditionsCorrectesPourJouerLeCoup & 
                                            (aQuiDeJouer = couleurMacintosh) & 
                                            not(InterruptionReflexionDansJeuMac()) & 
                                            SamePositionEtTrait(positionEtTraitDeLAppelReflexionDeMac,PositionEtTraitCourant()) &
                                            not(Quitter);
    end;
  
  { à la fin du delai, on essaie de jouer le coup }
  if conditionsCorrectesPourJouerLeCoup then Jouer(aQuiDeJouer,coupMac,fonctionAppelante);
  
  EcritStructureDesCalculsDansJeuMac('sortie de JouerUnCoupDuMacintoshDansJeuMac');
end;


procedure EssaieJouerCoupCalculePourLOrdinateurDansJeuMac(var coupMac : SInt32; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
begin
  EcritStructureDesCalculsDansJeuMac('entrée dans EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');
  
  if (aQuiDeJouer=couleurMacintosh) then
    begin
      if SamePositionEtTrait(positionEtTraitDeLAppelReflexionDeMac,PositionEtTraitCourant()) &
	       not(InterruptionReflexionDansJeuMac())
	      then
			    begin
			      if debuggage.gestionDuTemps then WritelnDansRapport('appel de Jouer('+CoupEnString(coupMac,true)+') par EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');
			      
			      JouerUnCoupDuMacintoshDansJeuMac(coupMac,positionEtTraitDeLAppelReflexionDeMac,'EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');
			      
			      EnleveCetteInterruption(interruptionDepassementTemps);
			      
			      if InterruptionReflexionDansJeuMac() then 
			        TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');
			    end
			  else
			    begin
			      if not(reponsePrete & (phaseDeLaPartie >= phaseFinale)) then
			        begin
					      if debuggage.gestionDuTemps then WritelnDansRapport('J''invalide les calculs precedents dans EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');
					      TraiteInterruptionBrutale(coupMac,meilleurCoupHum,'EssaieJouerCoupCalculePourLOrdinateurDansJeuMac(bis)');
					    end;
			    end;
    end;
  EcritStructureDesCalculsDansJeuMac('sortie de EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');
end;




procedure ContinuerAJouerTantQueLHumainPasseDansJeuMac(var coupMac : SInt32;niveau : SInt32; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
var oldInterruption : SInt16; 
    compteurIterationsBoucle : SInt32;
    note : SInt32;
begin
  EcritStructureDesCalculsDansJeuMac('entrée ContinuerAJouerTantQueLHumainPasseDansJeuMac');
  
  compteurIterationsBoucle := 0;
  
  WHILE (aQuiDeJouer=couleurMacintosh) & not(gameOver) & not(Quitter) & not(HumCtreHum) &
        not(InterruptionReflexionDansJeuMac()) & (compteurIterationsBoucle <= 500) DO
      begin     
      
        EcritStructureDesCalculsDansJeuMac('début de la boucle WHILE de ContinuerAJouerTantQueLHumainPasseDansJeuMac');
        
        inc(compteurIterationsBoucle);
         
        if (meilleurCoupHum<11) | (meilleurCoupHum>88) then meilleurCoupHum := 44;
        
        
        if (jeuCourant[meilleurCoupHum] = pionVide) & possibleMove[meilleurCoupHum]
          then              
            begin           
              if debuggage.gestionDuTemps then 
                begin
                  EcritStructureDesCalculsDansJeuMac('Je mets coupMac := meilleurCoupHum ('+CoupEnString(meilleurCoupHum,true)+') dans ContinuerAJouerTantQueLHumainPasseDansJeuMac');
                  EcritStructureDesCalculsDansJeuMac('Je mets meilleurCoupHum := 44 ('+CoupEnString(44,true)+') dans ContinuerAJouerTantQueLHumainPasseDansJeuMac');
                end;
              coupMac := meilleurCoupHum;
              meilleurCoupHum := 44;
            end
          else
            begin
              oldInterruption := GetCurrentInterruption();
              EnleveCetteInterruption(oldInterruption);
              vaDepasserTemps := false;
              EnableItemPourCassio(PartieMenu,ForceCmd);
              positionEtTraitDeLAppelReflexionDeMac := PositionEtTraitCourant();
              ChoixMacStandard(coupMac,note,meilleurCoupHum,aQuiDeJouer,niveau,'ContinuerAJouerTantQueLHumainPasseDansJeuMac'); 
              LanceInterruption(oldInterruption,'ContinuerAJouerTantQueLHumainPasseDansJeuMac');
            end;  
        if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL) 
          then TraiteEvenements
          else TraiteNullEvent(theEvent);
          
        if debuggage.gestionDuTemps &
           not(InterruptionReflexionDansJeuMac()) & (aQuiDeJouer=couleurMacintosh) &
           not(SamePositionEtTrait(positionEtTraitDeLAppelReflexionDeMac,PositionEtTraitCourant())) then
			    begin
			      WritelnDansRapport('AHAH !  positionEtTraitDeLAppelReflexionDeMac <> PositionEtTraitCourant() dans ContinuerAJouerTantQueLHumainPasseDansJeuMac !');
			      SysBeep(0);
			    end;  
			    
			  if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('appel de Jouer('+CoupEnString(coupMac,true)+') par ContinuerAJouerTantQueLHumainPasseDansJeuMac(2)');
          
        JouerUnCoupDuMacintoshDansJeuMac(coupMac,positionEtTraitDeLAppelReflexionDeMac,'ContinuerAJouerTantQueLHumainPasseDansJeuMac(2)');
        
        EcritStructureDesCalculsDansJeuMac('fin de la boucle WHILE de ContinuerAJouerTantQueLHumainPasseDansJeuMac'); 
      end; 
  
  if (compteurIterationsBoucle >= 500) then WritelnDansRapport('ERREUR !!! boucle infinie dans ContinuerAJouerTantQueLHumainPasseDansJeuMac, prévenez Stéphane');
  
  EcritStructureDesCalculsDansJeuMac('sortie ContinuerAJouerTantQueLHumainPasseDansJeuMac');
end;


procedure CalculerBonneReponsePourLeJoueurHumainDansJeuMac;
var oldInterruption : SInt16; 
    auxCoupHum : SInt32;
    auxColorMac : SInt32;
    tempoProfImposee : boolean;
    note : SInt32;
    uneDefense : SInt32;
begin

  EcritStructureDesCalculsDansJeuMac('entrée dans CalculerBonneReponsePourLeJoueurHumainDansJeuMac');

  reponsePrete := false;
  RefleSurTempsJoueur := true;
  
  oldInterruption := GetCurrentInterruption();
  EnleveCetteInterruption(oldInterruption);
  vaDepasserTemps := false;
  
  if nbreCoup >= finDePartieOptimale then
    if ConnaitSuiteParfaite(auxCoupHum,auxColorMac,false) then
        meilleurCoupHum := auxCoupHum;
    
  if (meilleurCoupHum < 11) | (meilleurCoupHum > 88) then meilleurCoupHum := 44;
  
  if (jeuCourant[meilleurCoupHum] <> pionVide) | not(possibleMove[meilleurCoupHum]) 
    then
      begin
      
        EcritStructureDesCalculsDansJeuMac('Je dois calculer un nouveau coup');
        
        MyDisableItem(PartieMenu,ForceCmd);
        meilleurCoupHum := 44;
        tempoProfImposee := ProfondeurMilieuEstImposee();
        SetProfImposee(true,'cas 1 dans CalculerBonneReponsePourLeJoueurHumainDansJeuMac');
        if not(jeuInstantane) | CassioEstEnModeSolitaire()
          then ChoixMacStandard(meilleurCoupHum,note,uneDefense,aQuiDeJouer,4,'CalculerBonneReponsePourLeJoueurHumainDansJeuMac(1)')
          else 
            if (NiveauJeuInstantane < NiveauChampions) & (phaseDeLaPartie <= phaseMilieu)
              then meilleurCoupHum := ReponseInstantanee(uneDefense,NiveauJeuInstantane)
              else ChoixMacStandard(meilleurCoupHum,note,uneDefense,aQuiDeJouer,3,'CalculerBonneReponsePourLeJoueurHumainDansJeuMac(2)');
        SetProfImposee(tempoProfImposee,'cas 1 dans CalculerBonneReponsePourLeJoueurHumainDansJeuMac (tempoProfImposee)');
        if (interruptionReflexion <> pasdinterruption) then 
          TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'CalculerBonneReponsePourLeJoueurHumainDansJeuMac(3)');
      end
    else
      EcritStructureDesCalculsDansJeuMac('Je peux reutiliser le coup ' + CoupEnString(meilleurCoupHum,true) + ' déja calculé');
    
  LanceInterruption(oldInterruption,'CalculerBonneReponsePourLeJoueurHumainDansJeuMac');
		        
  EcritStructureDesCalculsDansJeuMac('sortie de CalculerBonneReponsePourLeJoueurHumainDansJeuMac');
end;



procedure AfficherSuggestionDeCassioDansJeuMac;
var oldport : grafPtr;
begin
  EcritStructureDesCalculsDansJeuMac('entrée dans AfficherSuggestionDeCassioDansJeuMac');
  
  if afficheSuggestionDeCassio then
    begin
     if windowPlateauOpen then
       begin
        GetPort(oldport);
        SetPortByWindow(wPlateauPtr);
        if CassioEstEn3D() 
          then DessinePion3D(meilleurCoupHum,effaceCase)
          else DessinePion2D(meilleurCoupHum,pionVide);
        DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
        SetPort(oldport);
        if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
        if afficheInfosApprentissage then EcritLesInfosDApprentissage;
       end;
    end;
  
  EcritStructureDesCalculsDansJeuMac('sortie de AfficherSuggestionDeCassioDansJeuMac');
end;


procedure LanceReflexionSurLeTempsAdverseDansJeuMac(var coupMac : SInt32; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
var oldInterruption : SInt16; 
    platSup : plateauOthello;
    jouablesup : plBool;
    nbblancsup : SInt32;
    nbNoirsup : SInt32;
    frontsup : InfoFrontRec;
    auxColorMac : SInt32;
    coupLegal : boolean;
    tempoProfImposee : boolean;
    auxCoupHum : SInt32;
    auxNote : SInt32;
begin
  
  EcritStructureDesCalculsDansJeuMac('entrée dans LanceReflexionSurLeTempsAdverseDansJeuMac');
  
  nbblancsup := nbreDePions[pionBlanc];
  nbNoirsup := nbreDePions[pionNoir];
  platsup := jeuCourant;
  jouablesup := emplJouable;
  frontsup := frontiereCourante;
  auxColorMac := couleurMacintosh;
  coupLegal := ModifPlat(meilleurCoupHum,-auxColorMac,platsup,jouablesup,nbBlancsup,nbNoirsup,frontsup);
		          
  {if phaseDeLaPartie < phaseFinaleParfaite then
    AnnonceSupposeSuitConseilMac(nbreCoup+1,meilleurCoupHum);}
  
  MyDisableItem(PartieMenu,ForceCmd);
  
  oldInterruption := GetCurrentInterruption();
  EnleveCetteInterruption(oldInterruption);
  
  vaDepasserTemps := false;
  tempoProfImposee := ProfondeurMilieuEstImposee();
  SetProfImposee(false,'cas 2 dans LanceReflexionSurLeTempsAdverseDansJeuMac');
  auxCoupHum := 44;
  
  
  if (((nbreCoup+1) >= 60) | DoitPasser(auxColorMac,platsup,jouablesup))
    then
      begin
        reponsePrete := true;
        MeilleurCoupHumPret := auxCoupHum;
        meilleureReponsePrete := 44;
      end
    else
      begin
        if (nbblancsup>0) & (nbNoirsup>0) then
          begin
            
            positionEtTraitDeLAppelReflexionDeMac := MakePositionEtTrait(platSup,auxColorMac);
            
            ChoixMac(coupMac,auxNote,auxCoupHum,auxColorMac,level,nbblancsup,nbNoirsup,platsup,jouablesup,frontsup,'LanceReflexionSurLeTempsAdverseDansJeuMac');
            
            AfficheInfosDebugage2DansJeuMac(coupMac,auxCoupHum);
        
	          if RefleSurTempsJoueur & (PhasePartieDerniereReflexion() >= phaseMilieu)
	            then 
		            begin
		              if not(InterruptionReflexionDansJeuMac()) then
		               begin
		                reponsePrete := true;
		                meilleureReponsePrete := coupMac;
		                MeilleurCoupHumPret := auxCoupHum;
		               end;
		            end
	            else
		            begin
		              if not(InterruptionReflexionDansJeuMac()) then
		                meilleurCoupHum := auxCoupHum;
		            end;
	        end;
      end;
  
  
  SetProfImposee(tempoProfImposee,'cas 2 dans LanceReflexionSurLeTempsAdverseDansJeuMac (tempoProfImposee)');
  EnableItemPourCassio(PartieMenu,ForceCmd);
{ DessinePosition(jeuCourant);}
{ DessinePetitCentre;}
  
  LanceInterruption(oldInterruption,'LanceReflexionSurLeTempsAdverseDansJeuMac');
  EnleveCetteInterruption(interruptionDepassementTemps);
		          
	EcritStructureDesCalculsDansJeuMac('sortie LanceReflexionSurLeTempsAdverseDansJeuMac');
end;


procedure JeuMac(niveau : SInt32; const fonctionAppelante : str255);
var coupMac : SInt32;
    compteurIterationsBoucle : SInt32;
    positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec;
begin 
  if not(Quitter) then
    begin
    
      { Ceci est la position de reflexion de Cassio }
		  positionEtTraitDeLAppelReflexionDeMac := PositionEtTraitCourant();
		  
		  { Des infos de debugage }
		  AfficheDebugageEntreeDansJeuMac(fonctionAppelante,positionEtTraitDeLAppelReflexionDeMac);
		  InvalidateAnalyseDeFinaleSiNecessaire(kNormal);
		  
		  { On donne moins de temps aux autre applications puisque Cassio reflechit }
		  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
		  
		  { On calcule le coup que Cassio va jouer }
		  ReflexionInitialeDuMacintoshDansJeuMac(coupMac,niveau,positionEtTraitDeLAppelReflexionDeMac);
		  
		  { Verifions les evenements a tout hasard }
		  CheckEventsDansJeuMac(' CheckEventsDansJeuMac(1)');
		  AfficheInfosDebugage1DansJeuMac(positionEtTraitDeLAppelReflexionDeMac);
		  
		  
		  
		  { Si c'est vraiement a Cassio de jouer, on boucle ainsi : }
		  
		  compteurIterationsBoucle := 0;
		  if not(InterruptionReflexionDansJeuMac()) & not(Quitter) & not(HumCtreHum) &
		     not(AttenteAnalyseDeFinaleDansPositionCourante()) & 
		     SamePositionEtTrait(positionEtTraitDeLAppelReflexionDeMac,PositionEtTraitCourant()) 
		    then
    		  REPEAT    
    		    inc(compteurIterationsBoucle);
    		    EcritStructureDesCalculsDansJeuMac('au début de la boucle REPEAT dans JeuMac{1}');
    		   
    		    { On essaie de jouer le coup du Mac }
    		    EssaieJouerCoupCalculePourLOrdinateurDansJeuMac(coupMac,positionEtTraitDeLAppelReflexionDeMac);
    		     
    		    { Si l'humain passe alors la "defense" precedente est le meilleur coup de Mac }
    		    ContinuerAJouerTantQueLHumainPasseDansJeuMac(coupMac,niveau,positionEtTraitDeLAppelReflexionDeMac);
    		    
    		    
    		    { Gestion de la reflexion sur le temps adverse }
    		    if not(sansReflexionSurTempsAdverse | CassioEstEnModeAnalyse()) then
    		      if not(InterruptionReflexionDansJeuMac()) & not(HumCtreHum) & not(demo) & not(gameOver) then
    		        begin
    		      
    		          { D'abord on cherche une bonne reponse pour le joueur humain, la "suggestion de Cassio" }
    		          CalculerBonneReponsePourLeJoueurHumainDansJeuMac;
    		        
    		          if not(InterruptionReflexionDansJeuMac()) & not(HumCtreHum) &
                     (meilleurCoupHum >= 11) & (meilleurCoupHum <= 88) &
                     (jeuCourant[meilleurCoupHum] = pionVide) & possibleMove[meilleurCoupHum] then
                    begin
          
    		              { On essaie de l'affiche comme suggestion de Cassio (pion jaune) }
    		              AfficherSuggestionDeCassioDansJeuMac;
    		          
    		              { Puis on lance la reflexion de Cassio en supposant que l'humain a joué la suggestion }
    		              LanceReflexionSurLeTempsAdverseDansJeuMac(coupMac,positionEtTraitDeLAppelReflexionDeMac);
    		          
    		            end;
    		        end;
    		     
    		     EcritStructureDesCalculsDansJeuMac('à la fin de la boucle REPEAT dans JeuMac(1)');
    		     
    		  UNTIL Quitter | gameOver | HumCtreHum | InterruptionReflexionDansJeuMac() | demo | (compteurIterationsBoucle >= 500) |
    		        RefleSurTempsJoueur | (aQuiDeJouer<>couleurMacintosh) | AttenteAnalyseDeFinaleDansPositionCourante(); 
		        
		  if (compteurIterationsBoucle >= 500) then WritelnDansRapport('ERREUR !!!! boucle infinie dans JeuMac, prévenez Stéphane');
		  
		  AfficheDebuggageSortieDeJeuMac;
		  
		  
	 end;
end;


procedure PremierCoupMac;
var a,b : SInt16; 
begin  
  if nroDernierCoupAtteint <= 1
    then
      begin
        a := (Abs(TickCount()) mod 4)+3;
        case a of
          3:b := 4;
          4:b := 3;
          5:b := 6;
          6:b := 5;
        end;
        a := a+10*b;
      end
    else
      begin
        a := GetNiemeCoupPartieCourante(1);
      end;
  if aQuiDeJouer=couleurMacintosh then
     begin
       Jouer(aQuiDeJouer,a,'PremierCoupMac'); 
     end;
end;

procedure DoForcerMacAJouerMaintenant;
  begin
    if not(HumCtreHum) then
      begin
        if debuggage.gestionDuTemps then
          WritelnDansRapport('je suis dans DoForcerMacAJouerMaintenant');
        LanceInterruption(interruptionDepassementTemps,'DoForcerMacAJouerMaintenant');
        vaDepasserTemps := true;
      end;
  end;


procedure TraiteCoupImprevu(caseX : SInt32);
var caseY : SInt32;
    CassioReflechissaitSurLeTempsHumain : boolean;
    coupDejaTrouveDansBibl : boolean;
    couplegal : boolean;
    laBibliothequeEstCapableDeFournirUnCoup : boolean;
    nbReponsesEnBibliotheque : SInt32;
begin

  if debuggage.gestionDuTemps then
    WritelnDansRapport('entrée dans TraiteCoupImprevu('+CoupEnStringEnMajuscules(caseX)+')');

  if (caseX<11) | (caseX>88) then
    begin
      WritelnDansRapport('ASSERT((caseX<11) | (caseX>88)) dans TraiteCoupImprevu!! Merci de prévenir Stéphane');
      AlerteSimple('ASSERT((caseX<11) | (caseX>88)) dans TraiteCoupImprevu');
      exit(TraiteCoupImprevu);
    end;

 avecCalculPartiesActives := true;
 if HumCtreHum then
     begin
       Jouer(aQuiDeJouer,caseX,'TraiteCoupImprevu(1)');
     end
   else
    if (aQuiDeJouer = -couleurMacintosh) then
     begin
       if debuggage.gestionDuTemps
         then WritelnDansRapport('dans TraiteCoupImprevu, (aQuiDeJouer = -couleurMacintosh)');
       CassioReflechissaitSurLeTempsHumain := false;
       couplegal := possibleMove[caseX];
       Jouer(aQuiDeJouer,caseX,'TraiteCoupImprevu(2)');
       if couplegal & RefleSurTempsJoueur then
         begin
           if debuggage.gestionDuTemps then
             begin
               WritelnDansRapport('dans TraiteCoupImprevu, couplegal & RefleSurTempsJoueur');
               WritelnStringAndCoupDansRapport('dans TraiteCoupImprevu, meilleurCoupHum=',meilleurCoupHum);
             end;
           reponsePrete := reponsePrete & (caseX=meilleurCoupHum);
           CassioReflechissaitSurLeTempsHumain := true;
           RefleSurTempsJoueur := false;
           if (caseX <> meilleurCoupHum) then 
             begin
               LanceInterruption(interruptionSimple,'TraiteCoupImprevu (1)');
               vaDepasserTemps := false;
               meilleurCoupHum := 44;
              (* if avecDessinCoupEnTete then EffaceCoupEnTete; 
               SetCoupEnTete(0); *)
             end
           else
             if ((tempsPrevu div 60) > tempsAlloue) & (tempsAlloue < kUnMoisDeTemps) &
                 (phaseDeLaPartie <= phaseMilieu) & not(CassioEstEnModeAnalyse()) then 
               DoForcerMacAJouerMaintenant;
           LanceChrono;
           EnableItemPourCassio(PartieMenu,ForceCmd);
         end;
       if CassioReflechissaitSurLeTempsHumain & not(HumCtreHum) & (caseX=meilleurCoupHum)
         then 
           begin
             EcritJeReflechis(couleurMacintosh);
           end;
       if (aQuiDeJouer=couleurMacintosh) & not(CassioEstEnModeAnalyse()) then
         begin
          coupDejaTrouveDansBibl := false;
          if UtiliseGrapheApprentissage then
            if PeutChoisirDansGrapheApprentissage(CaseY,MeilleurCoupHumPret) then
              begin
                if (caseY>0) & (caseY<99) then
                if possibleMove[caseY] then
                  begin
                    vaDepasserTemps := false;
                    reponsePrete := true;
                    meilleureReponsePrete := caseY;
                    MeilleurCoupHumPret := MeilleurCoupHumPret;
                    LanceInterruption(interruptionSimple,'TraiteCoupImprevu (2)');
                    coupDejaTrouveDansBibl := true;
                  end;
              end;
          if (nbreCoup<=LongMaxBibl) & not(coupDejaTrouveDansBibl) then 
            begin
              if avecBibl | (jeuInstantane & (NiveauJeuInstantane <= NiveauChampions))
                then 
                  begin
                    laBibliothequeEstCapableDeFournirUnCoup := PeutChoisirEnBibl(CaseY,MeilleurCoupHumPret,false,nbReponsesEnBibliotheque);
                    {WritelnStringAndBoolDansRapport('laBibliothequeEstCapableDeFournirUnCoup = ',laBibliothequeEstCapableDeFournirUnCoup);
                    WritelnStringAndNumDansRapport('nbReponsesEnBibliotheque = ',nbReponsesEnBibliotheque);
                    WritelnStringAndCoupDansRapport('CaseY = ',CaseY);
                    WritelnStringAndCoupDansRapport('MeilleurCoupHumPret = ',MeilleurCoupHumPret);
                    WritelnDansRapport('');}
                    if not(avecBibl) then
                      laBibliothequeEstCapableDeFournirUnCoup := laBibliothequeEstCapableDeFournirUnCoup & 
                                                                 (nbReponsesEnBibliotheque > 1);
                  end
                else 
                  begin
                    laBibliothequeEstCapableDeFournirUnCoup := false;
                    nbReponsesEnBibliotheque := 0;
                  end;
                
	            if laBibliothequeEstCapableDeFournirUnCoup then
	              begin
	                if (caseY>0) & (caseY<99) then
	                if possibleMove[caseY] then
	                  begin
	                    vaDepasserTemps := false;
	                    reponsePrete := true;
	                    meilleureReponsePrete := caseY;
	                    MeilleurCoupHumPret := MeilleurCoupHumPret;
	                    LanceInterruption(interruptionSimple,'TraiteCoupImprevu (3)');
	                    coupDejaTrouveDansBibl := true;
	                  end;
	              end;
	          end;
          if (phaseDeLaPartie >= phaseFinale) & not(coupDejaTrouveDansBibl) then
           if ConnaitSuiteParfaite(CaseY,MeilleurCoupHumPret,true) then
             begin
               if (caseY>0) & (caseY<99) then
                if possibleMove[caseY] then
                  begin
                    vaDepasserTemps := false;
                    reponsePrete := true;
                    meilleureReponsePrete := caseY;
                    MeilleurCoupHumPret := MeilleurCoupHumPret;
                    LanceInterruption(interruptionSimple,'TraiteCoupImprevu (4)');
                    coupDejaTrouveDansBibl := true;
                  end;
             end;
          if jeuInstantane & (phaseDeLaPartie <= phaseMilieu) & not(coupDejaTrouveDansBibl) then
            with gEntrainementOuvertures do
	            begin
	             if CassioReflechissaitSurLeTempsHumain & not(HumCtreHum) & (caseX=meilleurCoupHum) &
	                (((NiveauJeuInstantane = NiveauChampions) & profSupUn) |
	                 (CassioVarieSesCoups & (derniereProfCompleteMilieuDePartie >= profondeurRechercheVariations)))
	              then
	                DoForcerMacAJouerMaintenant
	              else
	                begin
	                  if debuggage.gestionDuTemps
                      then WritelnDansRapport('appel à ReponseInstantanee dans TraiteCoupImprevu('+CoupEnStringEnMajuscules(caseX)+') !!');
	                  SetCassioChecksEvents(false);
	                  caseY := ReponseInstantanee(MeilleurCoupHumPret,NiveauJeuInstantane);
	                  SetCassioChecksEvents(true);
	                  if (caseY>0) & (caseY<99) then
	                  if possibleMove[caseY] 
	                    then
	                      begin
	                        vaDepasserTemps := false;
	                        reponsePrete := true;
	                        meilleureReponsePrete := caseY;
	                        LanceInterruption(interruptionSimple,'TraiteCoupImprevu (5)');
	                      end
	                    else  {normalement on ne devrait jamais passer ici, mais sait-on jamais…}
	                      begin
	                        WritelnDansRapport('Should never happen dans TraiteCoupImprevu('+CoupEnStringEnMajuscules(caseX)+') !!');
	                        
	                        LanceInterruption(interruptionSimple,'TraiteCoupImprevu (SHOULD NEVER HAPPEN)');
	                        vaDepasserTemps := false;
	                        reponsePrete := false;
	                      end;
	                end;
	            end;
         end;
     end
    else  { si on veut jouer a la place de Mac... }
	     begin
	       if debuggage.gestionDuTemps
            then WritelnDansRapport('On veut jouer a la place de Mac dans TraiteCoupImprevu…');
            
	       if possibleMove[caseX] then
	         if PeutArreterAnalyseRetrograde() then
	           begin
	             (*if avecDessinCoupEnTete then EffaceCoupEnTete;
	             SetCoupEnTete(0); *)
	             SetCassioChecksEvents(false);
	             Jouer(aQuiDeJouer,caseX,'TraiteCoupImprevu(3)');
	             SetCassioChecksEvents(true);
	             LanceInterruption(interruptionSimple,'TraiteCoupImprevu (6)');
	             vaDepasserTemps := false;
	           end;
	     end;
	
	if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('sortie de TraiteCoupImprevu('+CoupEnStringEnMajuscules(caseX)+')');
      WritelnDansRapport('a la sortie de TraiteCoupImprevu, voici la position courante :');
      WritelnPositionEtTraitDansRapport(jeuCourant,aQuiDeJouer);
    end;
end;


procedure JoueCoupPartieSelectionnee(nroHilite : SInt32);
var nroreference : SInt32;
    premierNumero,dernierNumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    CaseX,premierCoup : SInt16; 
    temposon : boolean;
    coupEnByte : byte;
    theGame : PackedThorGame;
    s60 : str60;
    partieEnClair : str255;
    debuguerCetteFonction : boolean;
begin
  
  debuguerCetteFonction := false;

  if (nbreCoup<60) & debuguerCetteFonction then WritelnDansRapport('(nbreCoup<60) : OK');
  if windowListeOpen & debuguerCetteFonction then WritelnDansRapport('windowListeOpen : OK');
  if not(enRetour | enSetUp) & debuguerCetteFonction then WritelnDansRapport('not(enRetour | enSetUp) : OK');
  if (infosListeParties.ascenseurListe <> NIL) & debuguerCetteFonction then WritelnDansRapport('infosListeParties.ascenseurListe <> NIL : OK');
  
  if (nbreCoup<60) & windowListeOpen & not(enRetour | enSetUp) & not(gameOver) then
    if infosListeParties.ascenseurListe <> NIL then
    begin
    
    
      if debuguerCetteFonction then WritelnDansRapport('avant GetNumerosPremiereEtDernierePartiesAffichees : OK');
    
      GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);
      
      if debuguerCetteFonction then 
        begin
          WritelnDansRapport('apres GetNumerosPremiereEtDernierePartiesAffichees : OK');
          WritelnStringAndNumDansRapport('premierNumero=',premierNumero);
          WritelnStringAndNumDansRapport('dernierNumero=',dernierNumero);
        end;
      
      {if (nroHilite>=premierNumero) & (nroHilite<=dernierNumero)
        then}
      if (nroHilite>=1) & (nroHilite<=nbPartiesActives) then
          begin
            {nroReference := tableNumeroReference^^[nroHilite];
            if nroReference<>infosListeParties.dernierNroReferenceHilitee then SysBeep(0);}
            nroReference := infosListeParties.dernierNroReferenceHilitee;
            
            if debuguerCetteFonction then 
            WritelnStringAndNumDansRapport('nroReference=',nroReference);
            
            
            ExtraitPartieTableStockageParties(nroReference,theGame);
            
            ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(theGame);
            
            if debuguerCetteFonction then 
              begin
                COPY_PACKED_GAME_TO_STR60(theGame, s60);
                WritelnDansRapport('theGame=' + s60);
              end;
            
            if debuguerCetteFonction then 
            TraductionThorEnAlphanumerique(theGame,partieEnClair);
            
            if debuguerCetteFonction then 
            WritelnDansRapport('partieEnClair='+partieEnClair);
            
		        ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
		        
		        if debuguerCetteFonction then 
		        WritelnStringAndNumDansRapport('premierCoup=',premierCoup);
            
            
		        TransposePartiePourOrientation(theGame,autreCoupQuatreDansPartie & (nbreCoup>=4),1,60);
            
            if debuguerCetteFonction then 
            TraductionThorEnAlphanumerique(theGame,partieEnClair);
            
            if debuguerCetteFonction then 
            WritelnDansRapport('partieEnClair='+partieEnClair);
           
            
            if not(PositionsSontEgales(jeuCourant,CalculePositionApres(nbreCoup,theGame))) then 
			        begin
			          if debuguerCetteFonction then WritelnDansRapport('WARNING : not(positionsSontEgales(…) dans JoueCoupPartieSelectionnee');
			          with DemandeCalculsPourBase do
	              if (EtatDesCalculs<>kCalculsEnCours) | (NumeroDuCoupDeLaDemande<>nbreCoup) | bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	              InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
			          exit(JoueCoupPartieSelectionnee);
			        end;
			      
			        
			      if debuguerCetteFonction then 
			      WritelnDansRapport('avant extraitCoupTablestockagePartie : OK');
            
            ExtraitCoupTableStockagePartie(nroReference,nbreCoup+1,coupEnByte);
            caseX := coupEnByte;
            
            if debuguerCetteFonction then 
            WritelnDansRapport('apres extraitCoupTablestockagePartie : OK');
            if debuguerCetteFonction then 
            WritelnStringAndNumDansRapport('caseX = ',caseX);
            
           
            temposon := avecSon;
            avecSon := false;
            if (caseX>=11) & (caseX<=88) then
              begin
                autreCoupQuatreDansPartie := false;
                if nbreCoup>=3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
                
                if debuguerCetteFonction then 
                WritelnDansRapport('avant TransposeCoupPourOrientation : OK');
                
                TransposeCoupPourOrientation(caseX,autreCoupQuatreDansPartie);
                
                if debuguerCetteFonction then 
                WritelnDansRapport('apres TransposeCoupPourOrientation : OK');
                
                TraiteCoupImprevu(caseX);
              end;
            avecSon := temposon;
            PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
          end;
    end;
end;


procedure JoueCoupMajoritaireStat;
var caseX : SInt16; 
    autreCoupQuatreDansPartie : boolean;
    premierCoup : SInt16; 
    temposon : boolean;
begin
  if not(gameOver) & (nbreCoup<60) & not(problemeMemoireBase) then
    begin
		  if windowStatOpen & not(enRetour | enSetUp) & (statistiques <> NIL) & StatistiquesCalculsFaitsAuMoinsUneFois()
		    then
		      begin
			      if statistiques^^.nbTotalParties > 0 then
			        begin
			           temposon := avecSon;
			           avecSon := false;
			           autreCoupQuatreDansPartie := false;
			           if nbreCoup >= 3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
			           caseX := ord(statistiques^^.table[1].coup);
			           TransposeCoupPourOrientation(caseX,autreCoupQuatreDansPartie);
			           TraiteCoupImprevu(caseX);
			           avecSon := temposon;
			        end;  
		     end
		    else  {if windowStatOpen}
		      if windowListeOpen & (nbPartiesActives=1) then
		        JoueCoupPartieSelectionnee(infosListeParties.partieHilitee);
    end;
end;

procedure JoueCoupQueMacAttendait;
var oldPort : grafPtr;
    joueCoupQueMacAttendaitOK : boolean;
    reponseOrdi,note : SInt32;
    
    
  function DessineOuJoueCoupQueMacAttendait(theMove : SInt32) : boolean;
  var coupTraite : boolean;
  begin
    coupTraite := false;
    if (theMove>=11) & (theMove<=88) then
    if possibleMove[theMove] then
      begin
        if afficheSuggestionDeCassio | gDoitJouerMeilleureReponse 
          then
            begin
              coupTraite := true;
              TraiteCoupImprevu(theMove);
              gDoitJouerMeilleureReponse := false;
            end
          else
            begin
              coupTraite := true;
              gDoitJouerMeilleureReponse := true;
              SetSuggestionDeFinaleEstDessinee(true);
              DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
            end;
      end;
    DessineOuJoueCoupQueMacAttendait := coupTraite;
  end;
    
    
    
begin
  if windowPlateauOpen & not(gameOver) & (interruptionReflexion = pasdinterruption) then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      
      if (aQuiDeJouer = -couleurMacintosh) then
        begin
		      
		      {afficher ou jouer le coup attendu}
		      joueCoupQueMacAttendaitOK := DessineOuJoueCoupQueMacAttendait(meilleurCoupHum);
		      
		      {si le meilleur coup humain n'était pas precalculé, on le calcule et on l'affiche}
		      if not(joueCoupQueMacAttendaitOK) & not(gameOver) & not(RefleSurTempsJoueur) &
		         not(HumCtreHum) & (aQuiDeJouer = -couleurMacintosh) & (phaseDeLaPartie>=phaseFinale) &
		         (interruptionReflexion = pasdinterruption) then 
		          begin
		            reponsePrete := false;
		            RefleSurTempsJoueur := true;
		            vaDepasserTemps := false;
		        
		            MyDisableItem(PartieMenu,ForceCmd);
		            meilleurCoupHum := 44;
		            ChoixMacStandard(meilleurCoupHum,note,reponseOrdi,aQuiDeJouer,3,'JoueCoupQueMacAttendait{2}');
		            if (interruptionReflexion <> pasdinterruption) 
		              then 
		                TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'JoueCoupQueMacAttendait(2)')
		              else 
		                begin
		                  joueCoupQueMacAttendaitOK := true;
		                  gDoitJouerMeilleureReponse := true;
		                  SetSuggestionDeFinaleEstDessinee(true);
		                  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
		                end;
		          end;
		      end
		    else
		      begin
		        {si on est en mode analyse de finale, on affiche le meilleur coup de la position}
		        if AttenteAnalyseDeFinaleDansPositionCourante() then
		          begin
		            if DessineOuJoueCoupQueMacAttendait(GetBestMoveAttenteAnalyseDeFinale()) then;
		          end;
		      end;
      SetPort(oldPort);
    end;
end;



procedure MiseAJourDeLaPartie(s : str255;
                              jeuDepart : plateauOthello;
                              jouableDepart : plBool;
                              frontiereDepart : InfoFrontRec;
                              nbBlancsDepart,nbNoirsDepart : SInt32;
                              traitDepart : SInt16; 
                              nbreCoupDepart : SInt16; 
                              depuisPositionInitiale : boolean;
                              coupFinal : SInt16; 
                              var gameNodeLePlusProfondGenere : GameTree);
{ remet à jour les retournements, les notes, etc, }
{ à partir de la position initiale (depuisDebut=true) }
{ ou de la position courante (depuisdebut=false) }
var jeu : plateauOthello;
    jouable : plBool;
    front : InfoFrontRec;
    numFirst,nbBlanc,nbNoir : SInt32;
    i,len,index,x,coul,nbreCoupsDejaEffectues : SInt16; 
    encorePossible,bidbool : boolean;
    GameNodeAAtteindre : GameTree;
    positionInitiale : plateauOthello;
    numeroPremierCoupJoue,traitInitial : SInt32;
    nbBlancsInitial,nbNoirsInitial : SInt32;
    numeroDuPlusGrandCoupLegal : SInt32;
    transcriptAccepteLesDonneesTemp : boolean;
begin
  CompacterPartieAlphanumerique(s,kCompacterTelQuel);
  
  GetPositionInitialeOfGameTree(positionInitiale,numeroPremierCoupJoue,traitInitial,nbBlancsInitial,nbNoirsInitial);
  if not(depuisPositionInitiale) 
    then
      begin
        jeu := jeuDepart;
        jouable := jouableDepart;
        front := frontiereDepart;
        nbBlanc := nbBlancsDepart;
        nbNoir := nbNoirsDepart;  
        coul := traitDepart;
        nbreCoupsDejaEffectues := nbreCoupDepart;
      end
    else
      begin
        SetCurrentNodeToGameRoot;
        MarquerCurrentNodeCommeReel('MiseAJourDeLaPartie');
        GetPositionInitialeOfGameTree(jeu,numFirst,traitInitial,nbBlanc,nbNoir);
        
        coul := 0;
        i := 0;
        repeat
          inc(i);
          if GetNiemeCoupPartieCourante(i) <> 0 then coul := partie^^[i].trait;
        until (coul <> 0) | (i>=64);
        nbreCoupsDejaEffectues := i-1;
        InitialiseDirectionsJouables;
        CarteJouable(jeu,jouable);
        CarteFrontiere(jeu,front); 
      end;
  {if (Length(s) div 2)<coupFinal then coupfinal := Length(s) div 2;}
  
  GameNodeAAtteindre := GetCurrentNode();
  
  len := Length(s);
  encorePossible := (len>=2);
  numeroDuPlusGrandCoupLegal := nbreCoupsDejaEffectues;
  
  if debuggage.arbreDeJeu then
       begin
		     WritelnDansRapport('avant la boucle dans MiseAJourDeLaPartie :');
		     WritelnStringAndNumDansRapport('   s = '+s+' et lenght(s) = ',len);
		     WritelnStringAndNumDansRapport('   nbreCoupsDejaEffectues = ',nbreCoupsDejaEffectues);
		     WritelnStringAndNumDansRapport('   CoupFinal = ',CoupFinal);
		     WritelnStringAndNumDansRapport('   numeroPremierCoupJoue = ',numeroPremierCoupJoue);
		   end;
  
  for i := nbreCoupsDejaEffectues+1 to 65 do
    InvalidateNombrePartiesActivesDansLeCache(i);
    
 if EnModeEntreeTranscript() then SetTranscriptAccepteLesDonnees(false,transcriptAccepteLesDonneesTemp);
    
  for i := nbreCoupsDejaEffectues+1 to CoupFinal do
   begin
     
     if debuggage.arbreDeJeu then
       begin
		     WriteDansRapport('i='+NumEnString(i)+'  => ');
		     if encorepossible
		       then WritelnDansRapport('encorepossible = true')
		       else WritelnDansRapport('encorepossible = false');
		   end;
		   
    if encorepossible then
     begin
       index := (i-numeroPremierCoupJoue+1);
       if 2*index>len then encorePossible := false;  {on est arrive a la fin de la chaine}
       
       if debuggage.arbreDeJeu then
         WritelnStringAndNumDansRapport('i='+NumEnString(i)+'  => index=',index);
       
       if debuggage.arbreDeJeu then
       begin
		     WriteDansRapport('i='+NumEnString(i)+'  => ');
		     if encorepossible
		       then WritelnDansRapport('encorepossible = true')
		       else WritelnDansRapport('encorepossible = false (car 2*index>len)');
		   end;
         
       if encorePossible then
         begin
           x := PositionDansStringAlphaEnCoup(s,2*index-1);
		       
		       if debuggage.arbreDeJeu then
			       begin
					     WritelnStringAndNumDansRapport('i='+NumEnString(i)+'  => coup = '+CoupEnStringEnMajuscules(x)+ ' car x = ',x);
					   end;
		       
		       if PeutJouerIci(coul,x,Jeu) 
		         then
		           begin
		             if JoueEnFictif(x,coul,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=CoupFinal),'MiseAJourDeLaPartie(1)') = NoErr then;
		             bidbool := ModifPlat(x,coul,jeu,jouable,nbblanc,nbNoir,front);
		             numeroDuPlusGrandCoupLegal := i;
		             coul := -coul;
		           end
		         else
		           begin
		             if PeutJouerIci(-coul,x,jeu)  
		              then
		               begin
		                 coul := -coul;
		                 if JoueEnFictif(x,coul,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=CoupFinal),'MiseAJourDeLaPartie(2)') = NoErr then;
		                 bidbool := ModifPlat(x,coul,jeu,jouable,nbblanc,nbNoir,front);
		                 coul := -coul;
		                 numeroDuPlusGrandCoupLegal := i;
		               end
		              else
		               begin
		                 encorePossible := false;
		               end;
		           end;
		      end;
     end;
   end;
  
  if EnModeEntreeTranscript() then
    begin
      SetTranscriptAccepteLesDonnees(transcriptAccepteLesDonneesTemp,bidbool);
      EntrerPartieDansCurrentTranscript(numeroDuPlusGrandCoupLegal);
    end;
  
  gameNodeLePlusProfondGenere := GetCurrentNode();
  DoChangeCurrentNodeBackwardUntil(GameNodeAAtteindre);
  MarquerCurrentNodeCommeReel('MiseAJourDeLaPartie');
  
  DessineCourbe(0,numeroDuPlusGrandCoupLegal,kCourbeColoree,'MiseAJourDeLaPartie');
	DessineSliderFenetreCourbe;
  
  EnableItemPourCassio(PartieMenu,ForwardCmd);
end;


procedure UpdateGameByMainBranchFromCurrentNode(nroDernierCoupAtteintMAJ : SInt16; 
																								jeuMAJ : plateauOthello;
																								jouableMAJ : plBool;
																								frontMAJ : InfoFrontRec;
																								nbBlancsMAJ,nbNoirsMAJ : SInt32;
																								traitMAJ,nbreCoupMAJ : SInt16);
var noeudActuel,GameNodeTerminal : GameTree;
    partieCompleteVoulue : str255;
    lignePrincipaleFromNow : str255;
    PartieJusquAPresent : str255;
    numeroCoupAAtteindre,numeroPremierCoupJoue : SInt32;
    positionInitiale : plateauOthello;
    nbBlancsInitial,nbNoirsInitial : SInt32;
    traitInitial : SInt32;
    transcriptAccepteLesDonneesTemp : boolean;
    bidbool : boolean;
begin
  noeudActuel := GetCurrentNode();
  if HasSons(noeudActuel) then
    begin
      lignePrincipaleFromNow := CoupsOfMainLineInGameTreeEnString(GetOlderSon(noeudActuel));
      if lignePrincipaleFromNow<>'' then
        begin
          PartieJusquAPresent := CoupsDuCheminJusquauNoeudEnString(noeudActuel);
          partieCompleteVoulue := PartieJusquAPresent+lignePrincipaleFromNow;
          numeroCoupAAtteindre := nroDernierCoupAtteintMAJ + (Length(lignePrincipaleFromNow) div 2);
          if traitMAJ = pionVide then
            begin
              GetPositionInitialeOfGameTree(positionInitiale,numeroPremierCoupJoue,traitInitial,nbBlancsInitial,nbNoirsInitial);
              traitMAJ := CalculeLeTraitApresTelCoup(nroDernierCoupAtteintMAJ-numeroPremierCoupJoue+1,partieCompleteVoulue,positionInitiale,traitInitial);
              
              if debuggage.arbreDeJeu then
                begin
		              EssaieSetPortWindowPlateau;
		              EcritPositionAt(positionInitiale,10,10);
		              EcritPositionAt(jeuMAJ,200,10);
		              WriteStringAt('partie jusqu''a présent = '+ PartieJusquAPresent+'      ',10,120);
		              WriteStringAt('partieCompleteVoulue = '+ partieCompleteVoulue+'       ',10,130);
		              WriteStringAndNumAt('nroDernierCoupAtteintMAJ = ',nroDernierCoupAtteintMAJ,10,140);
		              WriteStringAndNumAt('numeroCoupAAtteindre = ',numeroCoupAAtteindre,10,150);
		              WriteStringAndNumAt('numeroPremierCoupJoue = ',numeroPremierCoupJoue,10,160);
		              case TraitInitial of
		                pionBlanc : WriteStringAt('trait initial= pionBlanc  ',10,170);
		                pionNoir  : WriteStringAt('trait initial= pionNoir   ',10,170);
		                otherwise   WriteStringAt('trait initial inconnu !!  ',10,170);
		              end;
		              case traitMAJ of
		                pionBlanc : WriteStringAt('traitMAJ= pionBlanc  ',10,180);
		                pionNoir  : WriteStringAt('traitMAJ= pionNoir   ',10,180);
		                otherwise   WriteStringAt('traitMAJ inconnu !!  ',10,180);
		              end;
		              WriteStringAndNumAt('nbreCoupMAJ=',nbreCoupMAJ,10,190);
		            end;
              
            end;
          
          if EnModeEntreeTranscript() then SetTranscriptAccepteLesDonnees(false,transcriptAccepteLesDonneesTemp);
          MiseAJourDeLaPartie(partieCompleteVoulue,jeuMAJ,jouableMAJ,frontMAJ,
                             nbBlancsMAJ,nbNoirsMAJ,traitMAJ,nbreCoupMAJ,false,
                             numeroCoupAAtteindre,GameNodeTerminal);
          if EnModeEntreeTranscript() then SetTranscriptAccepteLesDonnees(transcriptAccepteLesDonneesTemp,bidbool);
        end;
    end;
end;


procedure TachesUsuellesPourAffichageCourant;
var square : SInt32;
begin
  if afficheNumeroCoup & (nbreCoup>0) then
    begin
      square := DerniereCaseJouee();
      if InRange(square,11,88) then 
        DessineNumeroCoup(square,nbreCoup,-jeuCourant[square],GetCurrentNode());
    end;
     
  SetEffacageProprietesOfCurrentNode(kToutesLesProprietes);
  SetAffichageProprietesOfCurrentNode(kToutesLesProprietes);
  ZebraBookDansArbreDeJeuCourant;
  AfficheProprietesOfCurrentNode(false,othellierToutEntier,'RejouePartieOthello');
  EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
      
  AjusteCurseur;
  MetTitreFenetrePlateau;
   
  if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
  if (HumCtreHum | (aQuiDeJouer<>couleurMacintosh)) & not(demo) then
    begin
      MyDisableItem(PartieMenu,ForceCmd);
      AfficheDemandeCoup;
    end;
      
  if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(othellierToutEntier);
  if afficheInfosApprentissage then EcritLesInfosDApprentissage;
  
  phaseDeLaPartie := CalculePhasePartie(nbreCoup);
  FixeMarqueSurMenuMode(nbreCoup);
   
  if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
    then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
end;


procedure RejouePartieOthello(s : str255;coupMax : SInt16; 
                              positionDepartStandart : boolean;
                              platImpose : plateauOthello;traitImpose : SInt16; 
                              var gameNodeLePlusProfondGenere : GameTree;
                              peutDetruireArbreDeJeu : boolean;
                              avecNomsOuvertureDansArbre : boolean);
var i,x,t,mobilite,aux : SInt32;
    oldPort : grafPtr;
    temposon,tempoAfficheBibl : boolean;
    tempoCalculsActives : boolean;
    tempoAfficheNumeroCoup : boolean;
    tempoAfficheInfosApprentissage : boolean;
    tempoAlerteNouvelleInterversion : boolean;
    nbreCoupsRepris : SInt16; 
    oldPositionFeerique : boolean;
    doitDetruireAncienArbreDeJeu : boolean;
    estLegal : boolean;
    tempoAvecDelaiDeRetournementDesPions : boolean;
    tickFinal : UInt32;
begin

   (*
   WritelnDansRapport('paramêtres d''entrée dans RejouePartieOthello :');
   WritelnDansRapport('s='+s);
   WritelnStringAndNumDansRapport('coupMax=',coupMax);
   WritelnStringAndBoolDansRapport('positionDepartStandart=',positionDepartStandart);
   WritelnDansRapport('platImpose, traitImpose :');
   WritelnPositionEtTraitDansRapport(platImpose,traitImpose);
   WritelnStringAndBoolDansRapport('peutDetruireArbreDeJeu=',peutDetruireArbreDeJeu);
   WritelnStringAndBoolDansRapport('avecNomsOuvertureDansArbre=',avecNomsOuvertureDansArbre);
   *)

   CompacterPartieAlphanumerique(s,kCompacterTelQuel);
   
   temposon := avecSon;
   tempoAfficheBibl := afficheBibl;
   tempoCalculsActives := false;
   tempoAfficheNumeroCoup := afficheNumeroCoup;
   tempoAfficheInfosApprentissage := afficheInfosApprentissage;
   tempoAlerteNouvelleInterversion := avecAlerteNouvInterversion;
   tempoAvecDelaiDeRetournementDesPions := avecDelaiDeRetournementDesPions;
   avecSon := false;
   afficheBibl := false;
   avecCalculPartiesActives := false;
   afficheNumeroCoup := false;
   afficheInfosApprentissage := false;
   avecAlerteNouvInterversion := false;
   avecDelaiDeRetournementDesPions := false;
   
   EffaceProprietesOfCurrentNode;
   ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),othellierToutEntier);
   SetEffacageProprietesOfCurrentNode(kAucunePropriete);
   SetAffichageProprietesOfCurrentNode(kAucunePropriete);
   
   oldPositionFeerique := positionFeerique;
   positionFeerique := not(positionDepartStandart); 
   peutfeliciter := true;
 (*if avecDessinCoupEnTete then EffaceCoupEnTete;
   SetCoupEntete(0);*)
   PartieContreMacDeBoutEnBout := false;
   gameOver := false;
   enSetUp := false;
   enRetour := false;
   DetermineMomentFinDePartie;
   phaseDeLaPartie := CalculePhasePartie(0);
   humainVeutAnnuler := false;
   RefleSurTempsJoueur := false;
   
   
   LanceInterruption(interruptionSimple,'RejouePartieOthello');
   vaDepasserTemps := false;
   reponsePrete := false;  
   ViderValeursDeLaCourbe;
   MemoryFillChar(@emplJouable,sizeof(emplJouable),chr(0));
   MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
   MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
   MemoryFillChar(@tableHeurisNoir,sizeof(tableHeurisNoir),chr(0));
   MemoryFillChar(@tableHeurisBlanc,sizeof(tableHeurisBlanc),chr(0));
   
   doitDetruireAncienArbreDeJeu := peutDetruireArbreDeJeu & (positionFeerique | oldPositionFeerique);
   ReInitialisePartieHdlPourNouvellePartie(doitDetruireAncienArbreDeJeu);
   
   VideMeilleureSuiteInfos;
   MyDisableItem(PartieMenu,ForwardCmd);
   Superviseur(nbreCoup);
   FixeMarqueSurMenuMode(nbreCoup);
   EssaieDisableForceCmd;
   if avecInterversions then PreouvrirGraphesUsuels;
   
   EffacerTouteLaCourbe('RejouePartieOthello');
   DessineSliderFenetreCourbe;
   
   if not(windowPlateauOpen) then OuvreFntrPlateau(false);
   GetPort(oldPort);
   SetPortByWindow(wPlateauPtr);
   
   DessinePlateau(true);
   if positionDepartStandart 
     then
       begin
         SetCurrentNodeToGameRoot;
         MarquerCurrentNodeCommeReel('RejouePartieOthello {1}');
         
         MemoryFillChar(@jeuCourant,sizeof(jeuCourant),chr(0));
         for i := 0 to 99 do
           if interdit[i] then jeuCourant[i] := PionInterdit;
         PosePion(54,pionNoir);
         PosePion(45,pionNoir);
         PosePion(55,pionBlanc);
         PosePion(44,pionBlanc); 
         InitialiseDirectionsJouables;
         CarteJouable(jeuCourant,emplJouable);
         aQuiDeJouer := pionNoir; 
         nbreDePions[pionNoir] := 2;
         nbreDePions[pionBlanc] := 2;
         
         SetPositionInitialeStandardDansGameTree;
         AddInfosStandardsFormatSGFDansArbre;
         if doitDetruireAncienArbreDeJeu then
            AjouteDescriptionPositionEtTraitACeNoeud(PositionEtTraitCourant(),GetRacineDeLaPartie());
         
         
         nbreCoup := 0;
         nroDernierCoupAtteint := 0;
         IndexProchainFilsDansGraphe := -1;
       end
     else
       begin
         SetCurrentNodeToGameRoot;
         MarquerCurrentNodeCommeReel('RejouePartieOthello {2}');
         
         MemoryFillChar(@jeuCourant,sizeof(jeuCourant),chr(0));
         for i := 0 to 99 do
           if interdit[i] then jeuCourant[i] := PionInterdit;
         nbreDePions[pionNoir] := 0;
         nbreDePions[pionBlanc] := 0;
         for t := 1 to 64 do
           begin
             x := othellier[t];
             aux := platImpose[x];
             jeuCourant[x] := aux;
             if (aux = pionNoir) | (aux = pionBlanc) 
               then 
                 begin
                   PosePion(x,aux);
                   nbreDePions[aux] := nbreDePions[aux]+1;
                 end;
           end;
         if odd(nbreDePions[pionNoir]+nbreDePions[pionBlanc])
           then aQuiDeJouer := pionBlanc
           else aQuiDeJouer := pionNoir;
         if (traitImpose = pionNoir) | (traitImpose = pionBlanc) then aQuiDeJouer := traitImpose; 
         
         SetPositionInitialeOfGameTree(jeuCourant,aQuiDeJouer,nbreDePions[pionBlanc],nbreDePions[pionNoir]);
         AddInfosStandardsFormatSGFDansArbre;
         if doitDetruireAncienArbreDeJeu then
            AjouteDescriptionPositionEtTraitACeNoeud(PositionEtTraitCourant(),GetRacineDeLaPartie());
         
         InitialiseDirectionsJouables;
         CarteJouable(jeuCourant,emplJouable);
         
         nbreCoup := nbreDePions[pionNoir]+nbreDePions[pionBlanc]-4;
         nroDernierCoupAtteint := nbreCoup;
         IndexProchainFilsDansGraphe := -1;
       end;
       
   if EnVieille3D() then Dessine3D(jeuCourant,false);
   aideDebutant := false;
   Calcule_Valeurs_Tactiques(jeuCourant,true);   
   MemoryFillChar(@possibleMove,sizeof(possibleMove),chr(0));
   CarteFrontiere(jeuCourant,frontiereCourante);
   AfficheScore;
   MyDisableItem(PartieMenu,Forcecmd);
   if avecAleatoire then RandomizeTimer;
   AjusteCadenceMin(GetCadence());
   DessineBoiteDeTaille(wPlateauPtr);
   dernierTick := TickCount();
   Heure(pionNoir);
   Heure(pionBlanc);
   InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);
   
   
   nbreCoupsRepris := Length(s) div 2;
   if nbreCoupsRepris > coupMax then nbreCoupsRepris := coupMax;
   
   tickFinal := TickCount();
   for i := 1 to nbreCoupsRepris do
     begin
       x := PositionDansStringAlphaEnCoup(s,2*i-1);
       if (nbreCoup < coupMax) & (x >= 11) & (x <= 88) then
         begin
           if EstEnTrainDeRejouerUneInterversion() then 
             begin
               if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
                  QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
               if LongueurInterversionEnTrainDEtreRejouee() <= 20
                 then Delay(7, tickFinal)
                 else Delay(1, tickFinal);
             end;
             
           if PeutJouerIci(aQuiDeJouer,x,jeuCourant) 
             then
               begin
                 if JoueEn(x,aQuiDeJouer,estLegal,avecNomsOuvertureDansArbre,(nbreCoup = nbreCoupsRepris - 1)) then;
               end
             else
               begin
                 if PeutJouerIci(-aQuiDeJouer,x,jeuCourant)  
                   then
                     begin
                       aQuiDeJouer := -aQuiDeJouer;
                       if JoueEn(x,aQuiDeJouer,estLegal,avecNomsOuvertureDansArbre,(nbreCoup = nbreCoupsRepris - 1)) then;
                     end
                   else
                     TachesUsuellesPourGameOver;
               end;
           if avecInterversions & (nbreCoup >= 1) & (nbreCoup <= numeroCoupMaxPourRechercheIntervesionDansArbre) 
	            then GererInterversionDeCeNoeud(GetCurrentNode(),PositionEtTraitCourant());
         end;
     end;
   
   gameNodeLePlusProfondGenere := GetCurrentNode();
   
     
   afficheNumeroCoup := tempoAfficheNumeroCoup;
   
   
   if OthelloTorique 
     then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
     else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
   if mobilite=0 then
    begin
      aQuiDeJouer := -aQuiDeJouer;
      if OthelloTorique 
        then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
        else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
      if mobilite=0 then TachesUsuellesPourGameOver;
    end;
   
   Initialise_table_heuristique(jeuCourant);
   
   avecSon := temposon;
   afficheBibl := tempoAfficheBibl;
   afficheInfosApprentissage := tempoAfficheInfosApprentissage;
   avecAlerteNouvInterversion := tempoAlerteNouvelleInterversion;
   avecDelaiDeRetournementDesPions := tempoAvecDelaiDeRetournementDesPions;
   
   avecCalculPartiesActives := true;
   gDoitJouerMeilleureReponse := false;
   
   TachesUsuellesPourAffichageCourant;
   if avecInterversions then FermerGraphesUsuels;
   
   SetPort(oldPort);
end;


procedure RejouePartieOthelloFictive(s : str255;coupMax : SInt16; 
                                     positionDepartStandart : boolean;
                                     platImpose : plateauOthello;traitImpose : SInt16; 
                                     var gameNodeLePlusProfondGenere : GameTree;
                                     flags : SInt32);
var jeu : plateauOthello;
    jouable : plBool;
    front : InfoFrontRec;
    nbBlanc,nbNoir,coul : SInt32;
    i,x,t,mobilite,aux : SInt32;
    nbreCoupsRepris : SInt16; 
    oldPositionFeerique : boolean;
    doitDetruireAncienArbreDeJeu : boolean;
    coupLegal : boolean;
begin
   CompacterPartieAlphanumerique(s,kCompacterTelQuel);
   
   oldPositionFeerique := positionFeerique;
   positionFeerique := not(positionDepartStandart); 
   peutfeliciter := true;
   (*SetCoupEntete(0);*)
   gameOver := false;
   PartieContreMacDeBoutEnBout := false;
   DetermineMomentFinDePartie;
   phaseDeLaPartie := CalculePhasePartie(0);
   humainVeutAnnuler := false;
   RefleSurTempsJoueur := false;
   LanceInterruption(interruptionSimple,'RejouePartieOthelloFictive');
   vaDepasserTemps := false;
   reponsePrete := false;
   ViderValeursDeLaCourbe;
   MemoryFillChar(@jouable,sizeof(jouable),chr(0));
   MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
   MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
   MemoryFillChar(@tableHeurisNoir,sizeof(tableHeurisNoir),chr(0));
   MemoryFillChar(@tableHeurisBlanc,sizeof(tableHeurisBlanc),chr(0));
   
   doitDetruireAncienArbreDeJeu := (BitAnd(flags,kPeutDetruireArbreDeJeu) <> 0) & (positionFeerique | oldPositionFeerique);
   ReInitialisePartieHdlPourNouvellePartie(doitDetruireAncienArbreDeJeu);
   
   VideMeilleureSuiteInfos;
   MyDisableItem(PartieMenu,ForwardCmd);
   Superviseur(nbreCoup);
   FixeMarqueSurMenuMode(nbreCoup);
   EssaieDisableForceCmd;
   
   if positionDepartStandart 
     then
       begin
         SetCurrentNodeToGameRoot;
         MarquerCurrentNodeCommeReel('RejouePartieOthelloFictive {1}');
         
         MemoryFillChar(@jeu,sizeof(jeu),chr(0));
         for i := 0 to 99 do
           if interdit[i] then jeu[i] := PionInterdit;
         jeu[54] := pionNoir;
         jeu[45] := pionNoir;
         jeu[55] := pionBlanc;
         jeu[44] := pionBlanc;
         InitialiseDirectionsJouables;
         CarteJouable(jeu,jouable);
         coul := pionNoir;
         nbNoir := 2;
         nbBlanc := 2;
         
         SetPositionInitialeStandardDansGameTree;
         AddInfosStandardsFormatSGFDansArbre;
         if doitDetruireAncienArbreDeJeu then
            AjouteDescriptionPositionEtTraitACeNoeud(MakePositionEtTrait(jeu,coul),GetRacineDeLaPartie());
         
         nbreCoup := 0;
         nroDernierCoupAtteint := 0;
         IndexProchainFilsDansGraphe := -1;
       end
     else
       begin
         SetCurrentNodeToGameRoot;
         MarquerCurrentNodeCommeReel('RejouePartieOthelloFictive {2}');
         
         MemoryFillChar(@jeu,sizeof(jeu),chr(0));
         for i := 0 to 99 do
           if interdit[i] then jeu[i] := PionInterdit;
         nbNoir := 0;
         nbBlanc := 0;
         for t := 1 to 64 do
           begin
             x := othellier[t];
             aux := platImpose[x];
             jeu[x] := aux;
             if (aux = pionNoir) then inc(nbNoir);
             if (aux = pionBlanc) then inc(nbBlanc);
           end;
         if odd(nbNoir+nbBlanc)
           then coul := pionBlanc
           else coul := pionNoir;
         if traitImpose <> 0 then coul := traitImpose; 
         
         SetPositionInitialeOfGameTree(jeu,coul,nbBlanc,nbNoir);
         AddInfosStandardsFormatSGFDansArbre;
         if doitDetruireAncienArbreDeJeu then
           AjouteDescriptionPositionEtTraitACeNoeud(MakePositionEtTrait(jeu,coul),GetRacineDeLaPartie());
         
         InitialiseDirectionsJouables;
         CarteJouable(jeu,jouable);
         
         nbreCoup := nbNoir+nbBlanc-4;
         nroDernierCoupAtteint := nbreCoup;
         IndexProchainFilsDansGraphe := -1;
       end;
       
   Calcule_Valeurs_Tactiques(jeu,true);   
   MemoryFillChar(@possibleMove,sizeof(possibleMove),chr(0));
   CarteFrontiere(jeu,front);
   MyDisableItem(PartieMenu,Forcecmd);
   if avecAleatoire then RandomizeTimer;
   AjusteCadenceMin(GetCadence());
   dernierTick := TickCount();
   
   nbreCoupsRepris := Length(s) div 2;
   if nbreCoupsRepris>coupMax then nbreCoupsRepris := coupMax;
   for i := 1 to nbreCoupsRepris do
     begin
       x := PositionDansStringAlphaEnCoup(s,2*i-1);
       if (x>=11) & (x<=88) then
         begin
          if PeutJouerIci(coul,x,jeu) 
            then
              begin
                if JoueEnFictif(x,coul,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=nbreCoupsRepris),'RejouePartieOthelloFictive(1)') = NoErr then;
                coupLegal := ModifPlat(x,coul,jeu,jouable,nbblanc,nbNoir,front);
                coul := -coul;
              end
            else
              begin
                if PeutJouerIci(-coul,x,jeu)  
                 then
                   begin
                     coul := -coul;
                     if JoueEnFictif(x,coul,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i=nbreCoupsRepris),'RejouePartieOthelloFictive(2)') = NoErr then;
                     coupLegal := ModifPlat(x,coul,jeu,jouable,nbblanc,nbNoir,front);
                     coul := -coul;
                   end
                 else
                   TachesUsuellesPourGameOver;
              end;
          end;
     end;
   
   gameNodeLePlusProfondGenere := GetCurrentNode();
     
   MetTitreFenetrePlateau;
   nbreCoup := nbreCoupsRepris;
   IndexProchainFilsDansGraphe := -1;
   jeuCourant := jeu;
   emplJouable := jouable;
   frontiereCourante := front;
   nbreDePions[pionNoir] := nbNoir;
   nbreDePions[pionBlanc] := nbBlanc;
   aQuiDeJouer := coul;
     
   if OthelloTorique 
     then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
     else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
   if mobilite=0 then
    begin
      aQuiDeJouer := -aQuiDeJouer;
      if OthelloTorique 
        then CarteMoveTore(aQuiDeJouer,jeuCourant,possibleMove,mobilite)
        else CarteMove(aQuiDeJouer,jeuCourant,possibleMove,mobilite);
      if mobilite=0 then TachesUsuellesPourGameOver;
    end;
  
   MetTitreFenetrePlateau;
    
   DessineCourbe(0,coupMax,kCourbeColoree,'RejouePartieOthelloFictive');
	 DessineSliderFenetreCourbe;
   
   
   Initialise_table_heuristique(jeuCourant);
   if (HumCtreHum | (aQuiDeJouer<>couleurMacintosh)) & not(demo) then MyDisableItem(PartieMenu,Forcecmd);
   avecCalculPartiesActives := true;
   gDoitJouerMeilleureReponse := false;
   if afficheInfosApprentissage then EcritLesInfosDApprentissage;
   if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
     then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
end;



function ResynchronisePartieEtCurrentNode(ApresQuelCoup : SInt16) : OSErr;
var position : plateauOthello;
    OldCurrentNode : GameTree;
    trait,coup,numeroPremierCoup,nbBlancs,nbNoirs,i,nbFilsDetruits,TraitCourant : SInt32;
    erreurES : OSErr;
    ok : boolean;
begin
  erreurES := 0;
  ResynchronisePartieEtCurrentNode := 0;
  
  oldCurrentNode := GetCurrentNode();
  SetCurrentNodeToGameRoot;
  GetPositionInitialeOfGameTree(position,numeroPremierCoup,trait,nbBlancs,nbNoirs);
  
  TraitCourant := 0;
  ok := true;
  i := numeroPremierCoup;
  repeat
    ok := (trait=partie^^[i].trait);
    coup := GetNiemeCoupPartieCourante(i);
    ok := ok & (position[coup] = pionVide);
    if ok then
      begin
		    if not(ModifPlatSeulement(coup,position,trait))
		      then ok := false
		      else
		        begin
		          ok := true;
		          if not(DoitPasserPlatSeulement(-trait,Position))
		            then trait := -trait
		            else if DoitPasserPlatSeulement(trait,position)
		                   then trait := pionVide;  {partie finie !}
		        end;
		    if (i=ApresQuelCoup) then TraitCourant := trait;
		  end;
		(* WritelnStringAndboolDansRapport('coup n°'+NumEnString(i)+' : '+CoupEnString(coup,true)+' ==> ',ok); *)
    i := succ(i);
  until not(ok) | (i>ApresQuelCoup);
  
  if not(ok) then 
    begin
      SetCurrentNode(oldCurrentNode);
      ResynchronisePartieEtCurrentNode := -1;
      exit(ResynchronisePartieEtCurrentNode);
    end;
  
  
  
  for i := numeroPremierCoup to ApresQuelCoup do
    begin
      coup := GetNiemeCoupPartieCourante(i);
      trait := partie^^[i].trait;
      
      nbFilsDetruits := DeleteSonsOfThatColor(GetCurrentNode(),-trait);
      
      erreurES := ChangeCurrentNodeAfterNewMove(coup,trait,'ResynchronisePartieEtPositionCourante');
      (* WritelnStringAndNumDansRapport('coup n°'+NumEnString(i)+' : '+CoupEnString(coup,true)+' ==> ',erreurES);
      *)
      if erreurES <> 0 then
        begin
          SetCurrentNode(oldCurrentNode);
          ResynchronisePartieEtCurrentNode := erreurES;
          exit(ResynchronisePartieEtCurrentNode);
        end;
    end;
  
  nbFilsDetruits := DeleteSonsOfThatColor(GetCurrentNode(),-TraitCourant);
end;


{$R-}

END.
