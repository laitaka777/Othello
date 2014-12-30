UNIT UnitUtilitaires;





INTERFACE







USES UnitOth0,UnitMacExtras,UnitDefinitionsNouveauFormat,UnitSquareSet,UnitPositionEtTrait;




var MyFiltreClassiqueUPP : ModalFilterUPP;
    
                       

procedure InitUnitUtilitaires;
procedure LibereMemoireUnitUtilitaires;


function MyFiltreClassique(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;

function ComplementeJoueur(prefixe : str255;typeVoulu : SInt32) : str255;
function ComplementeTournoi(prefixe : str255;typeVoulu : SInt32) : str255;
function Complemente(typeVoulu : SInt32; var prefixe : str255; var longueurPrefixe : SInt16) : str255;
procedure CoupJoueDansRapport(numeroCoup,coup : SInt32);
procedure DoListerLesGroupes;
procedure DoAjouterGroupe;

function NomCourtDuTournoi(const nomOrigine:str30) : str255;
procedure TraduitNomTournoiEnMac(ancNom:str30; var nouveauNom:str30);
procedure TraduitNomJoueurEnMac(ancNom:str30; var nouveauNom:str30);
procedure EnlevePrenom(const nomOrigine:str19; var nomSansPrenom : str255);
function FabriqueNomEnMajusculesSansEspaceDunNomWThor(nom : str255) : str255;

function FabriqueNomJoueurPourBaseWThorOfficielle(var nom : str255) : t_JoueurRecNouveauFormat;
function FabriqueNomTournoiPourBaseWThorOfficielle(var nom : str255) : t_TournoiRecNouveauFormat;
function JoueurRecNouveauFormatToString(whichPlayer : t_JoueurRecNouveauFormat):str30;
function TournoiRecNouveauFormatToString(whichTourney : t_TournoiRecNouveauFormat):str30;

function ScoreFinalEnChaine(scorePourNoir : SInt16) : string;
procedure ConstruitTitrePartie(const nomNoir,nomBlanc : str255;enleverLesPrenoms : boolean;scoreNoir : SInt32; var titre : str255);
function EnleveAnneeADroiteDansChaine(var s : str255; var firstYear,lastYear : SInt16) : boolean;
procedure EchangeSurnoms(var nom:str19);
procedure EpureNomJoueur(var unNomDeJoueur:str19);
procedure TraiteJoueurEnMinuscules(nomBrut : str255; var nomJoueur:str19); 
procedure TraiteTournoiEnMinuscules(nom : str255; var nomTournoi:str29);
procedure TournoiEnMinuscules(var nomBrut:str29);
function PositionsSontEgales(var pos1,pos2 : plateauOthello) : boolean;
function CalculePositionApres(numero : SInt16; partie60 : PackedThorGame) : plateauOthello;
function CalculePositionEtTraitApres(var partie60 : PackedThorGame; numeroCoup : SInt16; var position : plateauOthello; var trait,nbBlanc,nbNoir : SInt32) : boolean;
function GetPositionInitialePartieEnCours() : PositionEtTraitRec;
function GetPositionEtTraitPartieEnCoursApresCeCoup(numeroCoup : SInt16; var typeErreur : SInt32) : PositionEtTraitRec;



function FiltreCoeffDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
function ClicSurCurseurCoeff(mouseLoc : Point; var hauteurExacte,nroCoeff : SInt16) : boolean;
procedure CalculEtAfficheCoeff(dp : DialogPtr;mouseX,item,hauteurExacte : SInt16);
procedure DessineEchellesCoeffs(dp : DialogPtr);
procedure DessineBord(xdeb,y : SInt32;indexBord : SInt32);
procedure DessineEchelleEtCurseur(dp : DialogPtr;xmin,xmax,y : SInt32;coeff : extended);
procedure EcritParametre(dp : DialogPtr;s : str255;parametre : SInt32;y : SInt32);
procedure EcritParametres(dp : DialogPtr;quelParametre : SInt16);
procedure EcritEtDessineBords;
procedure EcritValeursTablesPositionnelles(dp : DialogPtr);
procedure EffaceValeursTablesPositionnelles(dp : DialogPtr);


procedure DoInsererMarque;
procedure CopierPartieEnTEXT(enMajuscule,avecEspacesEntreCoups : boolean);
procedure CopierDiagrammePositionEnTEXT;
procedure CopierDiagrammePartieEnTEXT;
procedure CopierPositionPourEndgameScriptEnTEXT;
procedure CopierDiagrammePositionEnHTML;

function PeutCompleterPartieAvecSelectionRapport(var partieAlpha : str255) : boolean;
function PeutCompleterPartieAvecLigneOptimale(var partieEnAlpha : str255) : boolean;

procedure FabriqueMeilleureSuiteInfos(premierCoup : SInt16; 
                                   suiteJouee:t_suiteJouee;
                                   meilleureSuite:meilleureSuitePtr;
                                   coul : SInt16; plat : plateauOthello;nBla,nNoi : SInt32;
                                   message : SInt32);

procedure SauvegardeLigneOptimale(coul : SInt32);
procedure MetCoupEnTeteDansKiller(coup,KillerProf : SInt32);
procedure MeilleureSuiteDansKiller(profKiller : SInt32);
function SquareSetToPlatBool(theSet : SquareSet) : plBool;
procedure SetNbrePionsPerduParVariation(numeroDuCoup,deltaScore : SInt32);
function PrefixeFichierProfiler() : string;
procedure SetEffetSpecial(flag : boolean);
function  GetEffetSpecial() : boolean;
function SetClefHashageGlobale(whichValue : SInt32) : SInt32;
procedure TesterClefHashage(valeurCorrecte : SInt32;nomFonction : str255);

(* procedure apprendCoeffsPartiesDeLaListeAlaBill;*)
(* procedure apprendCoeffsLignesPartiesDeLaListe; *)
(* procedure apprendBlocsDeCoinPartiesDeLaListe; *)





IMPLEMENTATION







USES UnitListe,UnitJeu,UnitStrategie,UnitBibl,UnitPrefs,UnitApprentissageInterversion,UnitActions,
     UnitAffichageReflexion,UnitServicesRapport,UnitRapportImplementation,UnitAccesStructuresNouvFormat,
     UnitArbreDeJeuCourant,UnitOth1,UnitServicesDialogs,UnitMilieuDePartie,UnitHTML,UnitZoneMemoire,
     UnitJaponais,UnitSuperviseur,UnitOth2,UnitRapport,MyStrings,UnitDialog,UnitGestionDuTemps,UnitStringSet,
     UnitScannerOthellistique,SNStrings,UnitLiveUndo,UnitFenetres,UnitBlocsDeCoin,UnitFinalePourPositionEtTrait,
     UnitNormalisation,UnitPackedThorGame;


var gJoueursComplementes  : StringSet;
    gTournoisComplementes : StringSet;
    

function MyFiltreClassique(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
begin
  MyFiltreClassique := FiltreClassique(dlog,evt,item);
end;





(*
procedure apprendCoeffsPartiesDeLaListeAlaBill;
var i,j,n,nroReference : SInt32;
    s60 : PackedThorGame; 
    trait : SInt32;
    GainTheorique,GainReel:str7;
    ScoreReel : SInt16; 
    ok : boolean;
    platBill : plateauOthello;
    jouableBill : plBool;
    nbBlancBill,nbNoirBill : SInt32;
    frontBill : InfoFrontRec;
    traitDansPartie:Tableau60Longint;
    uneMatrice:MatriceCovariance;
    det,constanteGain,constantePerte : extended;
    v1,v2,v3:VecteurCoefficients;

  
  
begin

  metTableCoeffAZero(tableCoeffBords);
  metTableCoeffAZero(tableCoeffFrontiere);
  metTableCoeffAZero(tableCoeffEquivFrontiere);
  metTableCoeffAZero(tableCoeffCentre);
  metTableCoeffAZero(tableCoeffGrandCentre);
  metTableCoeffAZero(tableCoeffMinimisation);
  metTableCoeffAZero(tableCoeffCentralite);
  metTableCoeffAZero(tableCoeffBlocsDeCoin);
  MemoryFillChar(@Ng_et_Np,sizeof(Ng_et_Np),chr(0));
  for i := 0 to 50 do annuleMatriceCovariance(SigmaGagnantBill^[i]);
  for i := 0 to 50 do annuleMatriceCovariance(SigmaPerdantBill^[i]);
  


  WritelnDansRapport('Apprentissage des coeffs de la liste à la Bill…');
  n := 1;
  while (n<=nbPartiesActives) & not(Quitter) do
    begin
      nroReference := tableNumeroReference^^[n];
      GainTheorique := GetGainTheoriqueParNroRefPartie(nroReference);
      scoreReel := GetScoreReelParNroRefPartie(nroReference);
      if scoreReel>32 then GainReel := CaracterePourNoir else
      if scoreReel=32 then GainReel := CaracterePourEgalite else
      if scoreReel<32 then GainReel := CaracterePourBlanc;
        
      {WritelnDansRapport('apprentissage de la partie #'+NumEnString(nroReference));}
      ExtraitPartieTableStockageParties(nroreference,s60);
      CalculeLesTraitsDeCettePartie(s60,traitDansPartie);
          
      OthellierEtPionsDeDepart(platBill,nbNoirBill,nbBlancBill);
      MemoryFillChar(@JouableBill,sizeof(JouableBill),chr(0));
      InitialiseDirectionsJouables;
      CarteJouable(platBill,JouableBill);
      CarteFrontiere(platBill,frontBill);
      
      ok := true;
      for i := 1 to Min(Length(s60),45) do
        if ok then 
        begin
          trait := traitDansPartie[i];
          ok := ModifPlat(ord(s60[i]),trait,platBill,jouableBill,nbBlancBill,nbNoirBill,frontBill);
          trait := traitDansPartie[i+1];
          if ok then
            if ((GainTheorique=CaracterePourNoir) & (trait = pionNoir)) |
               ((GainTheorique=CaracterePourBlanc) & (trait = pionBlanc)) 
               then apprendCoeffsMoyensPositionBill(i,ClasseGagnantBill,platBill,trait,
                                                  nbBlancBill,nbNoirBill,jouableBill,frontBill);
          if ok then
            if ((GainTheorique=CaracterePourNoir) & (trait = pionBlanc)) |
               ((GainTheorique=CaracterePourBlanc) & (trait = pionNoir))
               then apprendCoeffsMoyensPositionBill(i,ClassePerdantBill,platBill,trait,
                                                  nbBlancBill,nbNoirBill,jouableBill,frontBill);
        end;
      
      if (n mod 40)=0 then WritelnDansRapport(NumEnString(n)+StringOf('…'));
      
      {
      if (n mod 100)=0 then EcritCoeffsMoyensBillDansRapport(35);
      }
      
      if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
      n := n+1;
    end;
 
  
  CalculeDifferenceEtDemiSomme(tableCoeffBords);
  CalculeDifferenceEtDemiSomme(tableCoeffFrontiere);
  CalculeDifferenceEtDemiSomme(tableCoeffEquivFrontiere);
  CalculeDifferenceEtDemiSomme(tableCoeffCentre);
  CalculeDifferenceEtDemiSomme(tableCoeffGrandCentre);
  CalculeDifferenceEtDemiSomme(tableCoeffMinimisation);
  CalculeDifferenceEtDemiSomme(tableCoeffCentralite);
  CalculeDifferenceEtDemiSomme(tableCoeffBlocsDeCoin);
 
  WritelnDansRapport('apprentissage des covariances…');
  n := 1;
  while (n<=nbPartiesActives) & not(Quitter) do
    begin
      nroReference := tableNumeroReference^^[n];
      GainTheorique := GetGainTheoriqueParNroRefPartie(nroReference);
      scoreReel := GetScoreReelParNroRefPartie(nroReference);
      if scoreReel>32 then GainReel := CaracterePourNoir else
      if scoreReel=32 then GainReel := CaracterePourEgalite else
      if scoreReel<32 then GainReel := CaracterePourBlanc;
      
        
      {WritelnDansRapport('apprentissage de la partie #'+NumEnString(nroReference));}
      ExtraitPartieTableStockageParties(nroreference,s60);
      CalculeLesTraitsDeCettePartie(s60,traitDansPartie);
          
      OthellierEtPionsDeDepart(platBill,nbNoirBill,nbBlancBill);
      MemoryFillChar(@JouableBill,sizeof(JouableBill),chr(0));
      InitialiseDirectionsJouables;
      CarteJouable(platBill,JouableBill);
      CarteFrontiere(platBill,frontBill);
      
      ok := true;
      for i := 1 to Min(Length(s60),45) do
        if ok then 
        begin
          trait := traitDansPartie[i];
          ok := ModifPlat(ord(s60[i]),trait,platBill,jouableBill,nbBlancBill,nbNoirBill,frontBill);
          trait := traitDansPartie[i+1];
          if ok then 
            if ((GainTheorique=CaracterePourNoir) & (trait = pionNoir)) |
               ((GainTheorique=CaracterePourBlanc) & (trait = pionBlanc)) 
               then apprendVariancesCoeffPositionBill(i,ClasseGagnantBill,platBill,trait,
                                                      nbBlancBill,nbNoirBill,jouableBill,frontBill);
          if ok then
            if ((GainTheorique=CaracterePourNoir) & (trait = pionBlanc)) |
               ((GainTheorique=CaracterePourBlanc) & (trait = pionNoir))
               then apprendVariancesCoeffPositionBill(i,ClassePerdantBill,platBill,trait,
                                                      nbBlancBill,nbNoirBill,jouableBill,frontBill);
        end;
      
      if (n mod 40)=0 then WritelnDansRapport(NumEnString(n)+StringOf('…'));
      
      {
      if (n mod 100)=0 then
        begin
          WritelnDansRapport('Sigma Gagnant=');
          EcritMatriceCovariancesBillDansRapport(35,SigmaGagnantBill^[35]);
          WritelnDansRapport('Sigma Perdant=');
          EcritMatriceCovariancesBillDansRapport(35,SigmaPerdantBill^[35]);
        end;
      }
      
      if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
      n := n+1;
    end;
 
 {
  WritelnDansRapport('avant lissage : ');
  for i := 27 to 32 do
    begin
      WriteDansRapport('Sigma Gagnant = ');
      EcritMatriceCovariancesBillDansRapport(i,SigmaGagnantBill^[i]);
      WriteDansRapport('Sigma Perdant = ');
      EcritMatriceCovariancesBillDansRapport(i,SigmaPerdantBill^[i]);
    end;
 }
 
 
  WritelnDansRapport('lissage des moyennes…');
  LisserMoyennesCoefficients(tableCoeffBords);
  LisserMoyennesCoefficients(tableCoeffFrontiere);
  LisserMoyennesCoefficients(tableCoeffEquivFrontiere);
  LisserMoyennesCoefficients(tableCoeffCentre);
  LisserMoyennesCoefficients(tableCoeffGrandCentre);
  LisserMoyennesCoefficients(tableCoeffMinimisation);
  LisserMoyennesCoefficients(tableCoeffCentralite);
  LisserMoyennesCoefficients(tableCoeffBlocsDeCoin);
  
  WritelnDansRapport('lissage des matrices de covariance…');
  lisserMatricesCovariance(SigmaGagnantBill);
  lisserMatricesCovariance(SigmaPerdantBill);
  
 {
  WritelnDansRapport('après lissage :');
  for i := 27 to 32 do
   begin
     WriteDansRapport('Sigma Gagnant = ');
     EcritMatriceCovariancesBillDansRapport(i,SigmaGagnantBill^[i]);
     WriteDansRapport('Sigma Perdant = ');
     EcritMatriceCovariancesBillDansRapport(i,SigmaPerdantBill^[i]);
   end;
 }
 
  WritelnDansRapport('calcul des matrices moyennes…');
  for i := 1 to 45 do
    begin
      SommeMatricesCovariance(SigmaGagnantBill^[i],SigmaPerdantBill^[i],uneMatrice);
      multMatriceCovarianceParReel(uneMatrice,0.5,uneMatrice);
      SigmaPerdantBill^[i] := uneMatrice;
      {
      if (i mod 10)=1 then EcritMatriceCovariancesBillDansRapport(i,uneMatrice);
      }
    end;
  
  
  WritelnDansRapport('calcul des matrices inverses…');
  for i := 1 to 45 do
    begin
      InverseMatriceCovariance(SigmaPerdantBill^[i],uneMatrice,det);
      SigmaGagnantBill^[i] := uneMatrice;
    end;
 
 
    
 {
  WritelnDansRapport('vérification des inversions : ');
  for i := 1 to 45 do
    begin
      if (i mod 10)=1 then
        begin
          produitMatricesCovariance(SigmaGagnantBill^[i],SigmaPerdantBill^[i],uneMatrice);
          WritelnDansRapport('matrice unité pour i='+NumEnString(i)+' : ');
          EcritMatriceCovariancesBillDansRapport(i,uneMatrice);
        end;
    end;
  }
  
  
  WritelnDansRapport('calcul des termes constants… ');
  for i := 1 to 45 do
    begin
      ConstruitVecteur(i,ClasseGagnantBill,v1);
      AppliqueMatriceCovariance(SigmaGagnantBill^[i],v1,v2);
      constanteGain := ProduitScalaireVecteursCoefficients(v1,v2);
      
      ConstruitVecteur(i,ClassePerdantBill,v1);
      AppliqueMatriceCovariance(SigmaGagnantBill^[i],v1,v2);
      constantePerte := ProduitScalaireVecteursCoefficients(v1,v2);
      
      CoefficientsDeFisher[i,0] := -0.5*(constanteGain-constantePerte);
      
      
    end;
 
 
  for i := 1 to 45 do
    begin
      ConstruitVecteur(i,DifferenceGagnantPerdant,v1);
      appliqueMatriceCovariance(SigmaGagnantBill^[i],v1,v2);
      for j := 1 to nbCoeffs do 
        CoefficientsDeFisher[i,j] := v2[j];
      
      if (i mod 3) = 1 then
        EcritCoeffsFisherDansRapport(i);
      
    end;
end;
*)

(*
procedure apprendCoeffsLignesPartiesDeLaListe;
var i,n,nroReference,Nbmin,Nbmax,longueur : SInt32;
    s60 : PackedThorGame; 
    plat : plateauOthello;
    trait : SInt32;
    GainTheorique,GainReel:str7;
    scoreReel : SInt16; 
    ok : boolean;
    code:t_codage;
    s : str255;
    fmin,fmax,fnote : extended;
    nbVides,nbAmis,nbEnnemis : SInt32;
    traitDansPartie:Tableau60Longint;

begin
  if valeurCentralite8 <> NIL then MemoryFillChar(valeurCentralite8,sizeof(valeurCentralite8^),chr(0));
  if valeurCentralite7 <> NIL then MemoryFillChar(valeurCentralite7,sizeof(valeurCentralite7^),chr(0));
  if valeurCentralite6 <> NIL then MemoryFillChar(valeurCentralite6,sizeof(valeurCentralite6^),chr(0));
  if valeurCentralite5 <> NIL then MemoryFillChar(valeurCentralite5,sizeof(valeurCentralite5^),chr(0));
  if valeurCentralite4 <> NIL then MemoryFillChar(valeurCentralite4,sizeof(valeurCentralite4^),chr(0));
  
  if nbOccurencesLigne8 <> NIL then MemoryFillChar(nbOccurencesLigne8,sizeof(nbOccurencesLigne8^),chr(0));
  if nbOccurencesLigne7 <> NIL then MemoryFillChar(nbOccurencesLigne7,sizeof(nbOccurencesLigne7^),chr(0));
  if nbOccurencesLigne6 <> NIL then MemoryFillChar(nbOccurencesLigne6,sizeof(nbOccurencesLigne6^),chr(0));
  if nbOccurencesLigne5 <> NIL then MemoryFillChar(nbOccurencesLigne5,sizeof(nbOccurencesLigne5^),chr(0));
  if nbOccurencesLigne4 <> NIL then MemoryFillChar(nbOccurencesLigne4,sizeof(nbOccurencesLigne4^),chr(0));

  WritelnDansRapport('Apprentissage des lignes de la liste…');

  n := 1;
  while (n<=nbPartiesActives) & not(Quitter) do
    begin
      nroReference := tableNumeroReference^^[n];
      GainTheorique := GetGainTheoriqueParNroRefPartie(nroReference);
      scoreReel := GetScoreReelParNroRefPartie(nroReference);
      if scoreReel>32 then GainReel := CaracterePourNoir else
      if scoreReel=32 then GainReel := CaracterePourEgalite else
      if scoreReel<32 then GainReel := CaracterePourBlanc;
      
        
      {WritelnDansRapport('apprentissage de la partie #'+NumEnString(nroReference));}
      ExtraitPartieTableStockageParties(nroreference,s60);
      CalculeLesTraitsDeCettePartie(s60,traitDansPartie);
          
      OthellierDeDepart(plat);
      ok := true;
      for i := 1 to Min(Length(s60),40) do
        if ok then 
        begin
          trait := traitDansPartie[i];
          ok := ModifPlatSeulement(ord(s60[i]),plat,trait);
          trait := traitDansPartie[i+1];
          if ok then apprendLignesPosition(plat,GainTheorique);
        end;
      
      if (n mod 40)=0 then WritelnDansRapport(NumEnString(n)+StringOf('…'));
      if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
      n := n+1;
    end;
 
  longueur := 8;
  fmin := 10000.0;
  fmax := -10000.0;
  Nbmin := 32000;
  Nbmax := -32000;
  for i := -3280 to 3280 do
    begin
      if nbOccurencesLigne8^[i]>30
        then fnote := 1.0*valeurCentralite8^[i]/nbOccurencesLigne8^[i]
        else 
          begin
            coder(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;
          
      valeurCentralite8^[i] := MyTrunc(fnote*100);
        
      if fnote>fmax then 
        begin
          fmax := fnote;
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  fmax='+ReelEnString(fnote));
          WriteDansRapport('  occ = '+NumEnString(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurCentralite8^[i]));
        end;
      if fnote<fmin then 
        begin
          fmin := fnote;
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  fmin='+ReelEnString(fnote));
          WriteDansRapport('  occ = '+NumEnString(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurCentralite8^[i]));
        end;
    
      if nbOccurencesLigne8^[i]>Nbmax then 
        begin
          Nbmax := nbOccurencesLigne8^[i];
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  Nbmax = '+NumEnString(Nbmax));
          WriteDansRapport('  fnote='+ReelEnString(fnote));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurCentralite8^[i]));
        end;
      if nbOccurencesLigne8^[i]<Nbmin then 
        begin
          Nbmin := nbOccurencesLigne8^[i];
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  Nbmin = '+NumEnString(Nbmin));
          WriteDansRapport('  fnote='+ReelEnString(fnote));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurCentralite8^[i]));
        end;
      
      if ((i+14) mod 50) =0 then
        begin
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  i='+NumEnString(i)+StringOf(' '));
          WriteDansRapport('  fnote='+ReelEnString(fnote));
          WriteDansRapport('  Occ = '+NumEnString(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurCentralite8^[i]));
        end;
    end;
    
    longueur := 7;
    for i := -1093 to 1093 do
    begin
      if nbOccurencesLigne7^[i]>30
        then fnote := 1.0*valeurCentralite7^[i]/nbOccurencesLigne7^[i]
        else 
          begin
            coder(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;
      valeurCentralite7^[i] := MyTrunc(fnote*100);
    end;
    
    longueur := 6;
    for i := -364 to 364 do
    begin
      if nbOccurencesLigne6^[i]>30
        then fnote := 1.0*valeurCentralite6^[i]/nbOccurencesLigne6^[i]
        else 
          begin
            coder(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;
      valeurCentralite6^[i] := MyTrunc(fnote*100);
    end;
    
    longueur := 5;
    for i := -121 to 121 do
    begin
      if nbOccurencesLigne5^[i]>30
        then fnote := 1.0*valeurCentralite5^[i]/nbOccurencesLigne5^[i]
        else 
          begin
            coder(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;
      valeurCentralite5^[i] := MyTrunc(fnote*100);
    end;
    
    longueur := 4;
    for i := -40 to 40 do
    begin
      if nbOccurencesLigne4^[i]>30
        then fnote := 1.0*valeurCentralite4^[i]/nbOccurencesLigne4^[i]
        else 
          begin
            coder(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;
      valeurCentralite4^[i] := MyTrunc(fnote*100);
    end;
end;
*)

(*
procedure apprendBlocsDeCoinPartiesDeLaListe;
var i,n,nroReference,Nbmin,Nbmax : SInt32;
    s60 : PackedThorGame; 
    plat : plateauOthello;
    trait : SInt32;
    GainTheorique,GainReel:str7;
    scoreReel : SInt16; 
    ok : boolean;
    code:t_codage;
    s : str255;
    fmin,fmax,fnote : extended;
    nbVides,nbAmis,nbEnnemis : SInt32;
    traitDansPartie:Tableau60Longint;
    
begin
  if valeurBlocsDeCoin <> NIL then MemoryFillChar(valeurBlocsDeCoin,sizeof(valeurBlocsDeCoin^),chr(0));
  if nbOccurencesLigne8 <> NIL then MemoryFillChar(nbOccurencesLigne8,sizeof(nbOccurencesLigne8^),chr(0));
  
  WritelnDansRapport('Apprentissage des blocs de coin de la liste…');
  n := 1;
  while (n<=nbPartiesActives) & not(Quitter) do
    begin
      nroReference := tableNumeroReference^^[n];
      GainTheorique := GetGainTheoriqueParNroRefPartie(nroReference);
      scoreReel := GetScoreReelParNroRefPartie(nroReference);
      if scoreReel>32 then GainReel := CaracterePourNoir else
      if scoreReel=32 then GainReel := CaracterePourEgalite else
      if scoreReel<32 then GainReel := CaracterePourBlanc;
      
        
      {WritelnDansRapport('apprentissage de la partie #'+NumEnString(nroReference));}
      ExtraitPartieTableStockageParties(nroreference,s60);
      CalculeLesTraitsDeCettePartie(s60,traitDansPartie);
          
      OthellierDeDepart(plat);
      ok := true;
      for i := 1 to Min(Length(s60),47) do
        if ok then 
        begin
          trait := traitDansPartie[i];
          ok := ModifPlatSeulement(ord(s60[i]),plat,trait);
          trait := traitDansPartie[i+1];
          if ok then apprendBlocsDeCoinPosition(plat,GainTheorique);
        end;
      
      if (n mod 40)=0 then WritelnDansRapport(NumEnString(n)+StringOf('…'));
      if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
      n := n+1;
    end;
 
 
  fmin := 10000.0;
  fmax := -10000.0;
  Nbmin := 32000;
  Nbmax := -32000;
  for i := -3280 to 3280 do
    begin
      if nbOccurencesLigne8^[i]>0
        then 
          begin
            fnote := 1.0*valeurBlocsDeCoin^[i]/nbOccurencesLigne8^[i];
            coder(i,8,code,nbVides,nbAmis,nbEnnemis);
            if (nbVides>=1) & ((i mod 30)=6) then
              begin
                WritelnDansRapport('');
                WritelnDansRapport(TPCopy(code,1,4));
                WriteDansRapport(TPCopy(code,5,4));
                WriteDansRapport('  i='+NumEnString(i)+StringOf(' '));
                WriteDansRapport('  fnote='+ReelEnString(fnote));
                WritelnDansRapport('  Occ = '+NumEnString(nbOccurencesLigne8^[i]));
              end;
            if nbOccurencesLigne8^[i]<=10 then fnote := 0.5*fnote;
            if nbOccurencesLigne8^[i]<=6 then fnote := 0.5*fnote;
          end
        else 
          begin
            fnote := 0.0;
          end;
          
      valeurBlocsDeCoin^[i] := MyTrunc(fnote*100);
        
      if fnote>fmax then 
        begin
          fmax := fnote;
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  fmax='+ReelEnString(fnote));
          WriteDansRapport('  occ = '+NumEnString(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurBlocsDeCoin^[i]));
        end;
      if fnote<fmin then 
        begin
          fmin := fnote;
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  fmin='+ReelEnString(fnote));
          WriteDansRapport('  occ = '+NumEnString(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurBlocsDeCoin^[i]));
        end;
    
      if nbOccurencesLigne8^[i]>Nbmax then 
        begin
          Nbmax := nbOccurencesLigne8^[i];
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  Nbmax = '+NumEnString(Nbmax));
          WriteDansRapport('  fnote='+ReelEnString(fnote));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurBlocsDeCoin^[i]));
        end;
      if nbOccurencesLigne8^[i]<Nbmin then 
        begin
          Nbmin := nbOccurencesLigne8^[i];
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  Nbmin = '+NumEnString(Nbmin));
          WriteDansRapport('  fnote='+ReelEnString(fnote));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurBlocsDeCoin^[i]));
        end;
      
      if (((i+14) mod 50) =0) & (fnote <> 0.0) then
        begin
          coder(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  i='+NumEnString(i)+StringOf(' '));
          WriteDansRapport('  fnote='+ReelEnString(fnote));
          WriteDansRapport('  Occ = '+NumEnString(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+NumEnString(valeurBlocsDeCoin^[i]));
        end;
    end;
    
end;
*)


function ComplementeJoueur(prefixe : str255;typeVoulu : SInt32) : str255;
var i,idepart,numeroDansSet : SInt32;
    trouve : boolean;
    joueurBase,prefixeMajus,derniereChaineMajus : str255;
begin
  ComplementeJoueur := prefixe;
  
  prefixeMajus := prefixe;
  UpperString(prefixeMajus,false);
  derniereChaineMajus := derniereChaineComplementation^^;
  UpperString(derniereChaineMajus,false);
  trouve := false;
  
  
  if (prefixe<>'') & (JoueursNouveauFormat.nbJoueursNouveauFormat > 0) then
    begin
      if (prefixeMajus<>derniereChaineMajus) | 
         (TypeDerniereComplementation<>typeVoulu)
        then 
          begin  {complementation avec un nouveau prefixe}
            iDepart := 0;
            DisposeStringSet(gJoueursComplementes);
          end
        else 
          begin  {on continue avec le meme prefixe }
            iDepart := numeroDerniereComplementationDansTable+1;
          end;
        
        
      if iDepart<0 then iDepart := 0;
      if iDepart>=JoueursNouveauFormat.nbJoueursNouveauFormat then iDepart := 0;
      
      i := iDepart;
      repeat
      
      
        {on essaie de voir si le prefixe est le debut du joueur numero "i" dans la liste des joueurs}
        joueurBase := GetNomJoueur(i);
        UpperString(joueurBase,false);
        if (Pos(prefixeMajus,joueurBase) = 1) then 
          begin
            joueurBase := GetNomJoueur(i);
            joueurBase := EnleveEspacesDeDroite(joueurBase);
            
            { a-t-on deja renvoyé ce joueur dans cette serie de complementations ? }
            if MemberOfStringSet(joueurBase,numeroDansSet,gJoueursComplementes)
              then
                begin
                  if (numeroDansSet = i) then  {on ne garde que la premiere occurence en cas de joueurs dupliqués}
                    begin
                      ComplementeJoueur := joueurBase;
                      numeroDerniereComplementationDansTable := i;
                      trouve := true;
                    end;
                end
              else
                begin  {c'est la premiere occurence de ce joueur avec le bon prefixe}
                  AddStringToSet(joueurBase,i,gJoueursComplementes);
                  ComplementeJoueur := joueurBase;
                  numeroDerniereComplementationDansTable := i;
                  trouve := true;
                end;
          end;
        
        {on fait la meme chose avec les noms japonais}
        if gVersionJaponaiseDeCassio & gHasJapaneseScript & not(trouve) & JoueurAUnNomJaponais(i) then
          begin
            joueurBase := GetNomJaponaisDuJoueur(i);
            UpperString(joueurBase,false);
            if (Pos(prefixeMajus,joueurBase)=1) then 
		          begin
		            joueurBase := GetNomJaponaisDuJoueur(i);
		            joueurBase := EnleveEspacesDeDroite(joueurBase);
		            
		            { a-t-on deja renvoyé ce joueur dans cette serie de complementations ? }
		            if MemberOfStringSet(joueurBase,numeroDansSet,gJoueursComplementes)
                  then
                    begin
                      if (numeroDansSet = i) then  {on ne garde que la premiere occurence en cas de joueurs dupliqués}
                        begin
                          ComplementeJoueur := joueurBase;
                          numeroDerniereComplementationDansTable := i;
                          trouve := true;
                        end;
                    end
                  else
                    begin {c'est la premiere occurence de ce joueur avec le bon prefixe}
                      AddStringToSet(joueurBase,i,gJoueursComplementes);
                      ComplementeJoueur := joueurBase;
                      numeroDerniereComplementationDansTable := i;
                      trouve := true;
                    end;
    		          end;
          end;
        
        i := i+1;
        if (i>=JoueursNouveauFormat.nbJoueursNouveauFormat) then i := 0;
      until trouve | (i=iDepart);
    end;
    
  TypeDerniereComplementation := typeVoulu;
  if trouve
    then derniereChaineComplementation^^ := TPCopy(joueurBase,1,Length(prefixe))
    else derniereChaineComplementation^^ := prefixe;
end;



function ComplementeTournoi(prefixe : str255;typeVoulu : SInt32) : str255;
var i,idepart,numeroDansSet : SInt32;
    trouve : boolean;
    tournoi,prefixeMaj,derniereChaineMaj : str255;
begin
  ComplementeTournoi := prefixe;
  
  prefixeMaj := prefixe;
  derniereChaineMaj := derniereChaineComplementation^^;
  UpperString(prefixeMaj,false);
  UpperString(derniereChaineMaj,false);
  
  if (prefixeMaj<>derniereChaineMaj) | (TypeDerniereComplementation<>typeVoulu)
    then 
      begin {complementation avec un nouveau prefixe}
        iDepart := TournoisNouveauFormat.nbTournoisNouveauFormat-1;
        DisposeStringSet(gTournoisComplementes);
      end
    else 
      begin {on continue avec le meme prefixe}
        iDepart := numeroDerniereComplementationDansTable-1;
      end;
    
  if iDepart<0 then iDepart := TournoisNouveauFormat.nbTournoisNouveauFormat-1;
  if iDepart>=TournoisNouveauFormat.nbTournoisNouveauFormat then iDepart := TournoisNouveauFormat.nbTournoisNouveauFormat-1;
  
  i := iDepart;
  trouve := false;
  if (TournoisNouveauFormat.nbTournoisNouveauFormat>0) then
  repeat
  
    {on essaie de voir si le prefixe est le debut du tournoi numero "i" dans la liste des tournois}
    tournoi := GetNomTournoi(i);
    UpperString(tournoi,false);
    if (Pos(prefixeMaj,tournoi)=1) then 
      begin
        tournoi := GetNomTournoi(i);
        tournoi := EnleveEspacesDeDroite(tournoi);
        
        { a-t-on deja renvoyé ce tournoi dans cette serie de complementations ? }
        if MemberOfStringSet(tournoi,numeroDansSet,gTournoisComplementes)
          then
            begin
              if (numeroDansSet = i) then  {on ne garde que la premiere occurence en cas de tournois dupliqués}
                begin
                  ComplementeTournoi := tournoi;
                  numeroDerniereComplementationDansTable := i;
                  trouve := true;
                end;
            end
          else
            begin  {c'est la premiere occurence de ce tournoi avec le bon prefixe}
              AddStringToSet(tournoi,i,gTournoisComplementes);
              ComplementeTournoi := tournoi;
              numeroDerniereComplementationDansTable := i;
              trouve := true;
            end;
      end;
      
    i := i-1;
    if (i<0) then i := TournoisNouveauFormat.nbTournoisNouveauFormat-1;
  until trouve | (i=iDepart);
  
  TypeDerniereComplementation := typeVoulu;
  if trouve
    then derniereChaineComplementation^^ := TPCopy(tournoi,1,Length(prefixe))
    else derniereChaineComplementation^^ := prefixe;
end;


function Complemente(typeVoulu : SInt32; var prefixe : str255; var longueurPrefixe : SInt16) : str255;
begin
  Complemente := prefixe;
  if joueursEtTournoisEnMemoire then
    case typeVoulu of
      complementationJoueurNoir  : Complemente := ComplementeJoueur(prefixe,typeVoulu);
      complementationJoueurBlanc : Complemente := ComplementeJoueur(prefixe,typeVoulu);
      complementationTournoi     : Complemente := ComplementeTournoi(prefixe,typeVoulu);
    end;
  longueurPrefixe := Length(prefixe);
end;


procedure CoupJoueDansRapport(numeroCoup,coup : SInt32);
var s{,s1} : str255;
    nomOuverture : str255;
    {oldScript : SInt32;}
    nomOuvertureProp : Property;
    s60 : PackedThorGame; 
    autreCoupQuatreDiagDansPartie : boolean;
    ouvertureDiagonale : boolean;
begin {$UNUSED numeroCoup,coup,s,s1,oldScript}

  if avecNomOuvertures then
    begin
		  if (SelectFirstPropertyOfTypesInGameTree([OpeningNameProp],GetCurrentNode()) = NIL) & 
		      NomOuvertureChange(nomOuverture) then 
		    begin
		      EnleveEspacesDeDroiteSurPlace(nomOuverture);
		      {
		      GetCurrentScript(oldScript);
		      NumToString(numeroCoup,s1);
		      s := '◊ '+s1+StringOf('.')+CoupEnString(coup,CassioUtiliseDesMajuscules)+' ◊';
		      s := s+'   «'+nomOuverture+StringOf('»');
		      DisableKeyboardScriptSwitch;
		      FinRapport;
		      TextNormalDansRapport;
		      WritelnDansRapport(s);
		      EnableKeyboardScriptSwitch;
		      SetCurrentScript(oldScript);
		      SwitchToRomanScript;
		      }
		      nomOuvertureProp := MakeStringProperty(OpeningNameProp,nomOuverture);
		      InsertPropInListAfter(nomOuvertureProp,GetCurrentNode()^.properties,SelectMovePropertyOfNode(GetCurrentNode()));
		      DisposePropertyStuff(nomOuvertureProp);
		    end;
		end;
  
  if avecInterversions then
    begin
		  s := PartieNormalisee(autreCoupQuatreDiagDansPartie,false);
		  {WritelnDansRapport('dans CoupJoueDansRapport, s = '+s);}
		  tableLignes^.cardinal := 0;
		  if InterversionDansLeGrapheApprentissage(s,false,tableLignes) then 
		    begin
		      s60 := tableLignes^.table[2];
		      ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		      TransposePartiePourOrientation(s60,autreCoupQuatreDiagDansPartie,1,60);
		      TraductionThorEnAlphanumerique(s60,s);
		      {WritelnDansRapport('dans CoupJoueDansRapport, interversion = '+s);}
		      AddTranspositionPropertyToGameTree(s,GetCurrentNode());
		    end;
		end;
  
end;


procedure DoListerLesGroupes;
var i : SInt32;
    s : str255;
    oldScript : SInt32;
begin
  GetCurrentScript(oldScript);
  if not(FenetreRapportEstOuverte())
    then 
      OuvreFntrRapport(false,true)
    else 
      if not(FenetreRapportEstAuPremierPlan()) then SelectWindowSousPalette(GetRapportWindow());
  WritelnDansRapport('');
  GetIndString(s,TextesGroupesID,1);
  ChangeFontSizeDansRapport(gCassioRapportBoldSize);
  ChangeFontDansRapport(gCassioRapportBoldFont);
  ChangeFontFaceDansRapport(bold);
  WritelnDansRapport(s);
  
  TextNormalDansRapport;
  for i := 1 to nbMaxGroupes do
    begin
      s := Groupes^^[i];
      if s<>'' then WritelnDansRapport(s);
    end;
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
end;

procedure DoAjouterGroupe;
const OuiNonAlerteID=1129;
      OuiBouton=1;
      DialogueSyntaxeGroupesID=1134;
var i : SInt32;
    ok,groupeUtilise : boolean;
    newGroupe,groupeExistant,nomDuGroupe,s : str255;
    caracteres : CharArrayHandle;
    posSigma,posEgal,posAcoladeOuvrante,posAcoladeFermante : SInt32;
    syntaxeCorrecte,groupeVide : boolean;
    
    
  function ConfirmationRemplacerGroupe : boolean;
  const DialogueRemplacerGroupeID=1133;
        annulerBouton=1;
        remplacerBouton=2;
	var dp : DialogPtr;
	    itemHit : SInt16; 
	    err : OSErr;
	begin
	  ConfirmationRemplacerGroupe := true;
	  BeginDialog;
	  dp := MyGetNewDialog(DialogueRemplacerGroupeID,FenetreFictiveAvantPlan());
	  if dp <> NIL then
	    begin
	      err := SetDialogTracksCursor(dp,true);
	      repeat
	        ModalDialog(FiltreClassiqueUPP,itemHit);
	      until (itemHit=annulerBouton) | (itemHit=remplacerBouton);
	      ConfirmationRemplacerGroupe := (itemHit=remplacerBouton);
	      MyDisposeDialog(dp);
	      if windowPaletteOpen then DessinePalette;
	      EssaieSetPortWindowPlateau;
	    end;
	  EndDialog;
	end;

    
    
begin
  ok := false;
  if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan() & SelectionRapportNonVide() then
    ok := true;
  if not(ok)
    then 
      begin
        DialogueSimple(DialogueSyntaxeGroupesID);
      end
    else
      begin
        if (LongueurSelectionRapport() > 255)
          then 
            begin
              GetIndString(s,TextesGroupesID,2);
              AlerteSimple(s);
            end
          else
            begin
              caracteres := GetRapportTextHandle();
              newGroupe := '';
              for i := GetDebutSelectionRapport() to GetFinSelectionRapport() - 1 do
                if caracteres^^[i]<>chr(13) then    {retour chariot}
                  newGroupe := newGroupe+caracteres^^[i];
              EnleveEspacesDeDroiteSurPlace(newGroupe);    
              EnleveEspacesDeGaucheSurPlace(newGroupe);    
                  
              posSigma := Pos('∑',newGroupe);
              posEgal := Pos('=',newgroupe);
              posAcoladeOuvrante := Pos('{',newgroupe);
              posAcoladeFermante := Pos('}',newgroupe);
              
              { On verifie que le nom du groupe est non vide, qu'il commence par ∑
                et que les acolades sont bien placees }
              syntaxeCorrecte := (posSigma = 1) & 
                                 (posEgal > 2) & 
                                 (posAcoladeOuvrante > posEgal) & 
                                 (posAcoladeFermante > posAcoladeOuvrante);
                                 
              { Et il ne doit y avoir que des espaces (eventuellement aucune)
                entre le signe egal et l'acolade ouvrante}           
              for i := posEgal+1 to posAcoladeOuvrante-1 do
                if newgroupe[i]<>' ' then syntaxeCorrecte := false;               
                       
              { L'utilisateur peut avoir défini un groupe vide pour supprimer
                un groupe existant. Est-ce la cas ? }        
              groupeVide := true;
              for i := posAcoladeOuvrante+1 to posAcoladeFermante-1 do
                if newgroupe[i]<>' ' then groupeVide := false;    
                
              
              if not(syntaxeCorrecte) 
                then 
                  begin
                    GetIndString(s,TextesGroupesID,3);
                    AlerteSimple(s);
                  end
                else
                  begin
                    groupeUtilise := false;
                    nomDuGroupe := TPCopy(newGroupe,1,posEgal-1);
                    EnleveEspacesDeDroiteSurPlace(nomDuGroupe);
                    for i := 1 to nbMaxGroupes do
                      if groupes^^[i]<>'' then
                        begin
                          groupeExistant := groupes^^[i];
                          posEgal := Pos('=',groupeExistant);
                          groupeExistant := TPCopy(groupeExistant,1,posEgal-1);
                          EnleveEspacesDeDroiteSurPlace(groupeExistant);
                          
                          if (groupeExistant=nomDuGroupe) & not(groupeUtilise) then
                            begin
                              groupeUtilise := true;
                              if groupeVide 
                                then
                                  begin
                                    GetIndString(s,TextesGroupesID,4);  {"supprimer groupe ?"}
                                    s := ParamStr(s,nomDuGroupe,'','','');
                                    ParamText(s,'','','');
                                    BeginDialog;
                                    if Alert(OuiNonAlerteID,FiltreClassiqueAlerteUPP)=1 then
                                      begin
                                        groupes^^[i] := '';
                                        ListeDesGroupesModifiee := true;
                                        DoListerLesGroupes;
                                      end;
                                    EndDialog;
                                  end
                                else
                                  begin
                                    if ConfirmationRemplacerGroupe then 
                                      begin
                                        groupes^^[i] := newgroupe;
                                        ListeDesGroupesModifiee := true;
                                        DoListerLesGroupes;
                                      end;
                                  end;
                            end;
                        end;
                    if not(groupeUtilise) then
                      for i := 1 to nbMaxGroupes do
                        if (groupes^^[i]='') & not(groupeUtilise) then
                          begin
                            groupes^^[i] := newGroupe;
                            ListeDesGroupesModifiee := true;
                            DoListerLesGroupes;
                            groupeUtilise := true;
                          end;
                     if not(groupeUtilise) then
                       begin
                         GetIndString(s,TextesGroupesID,6);
                         AlerteSimple(s);
                       end
                  end;
            end;
      end;
 if ListeDesGroupesModifiee then
   begin
     CreeFichierGroupes;
     ListeDesGroupesModifiee := false;
   end;
end;






procedure TraduitNomTournoiEnMac(ancNom:str30; var nouveauNom:str30);
var c,premierCaractere : char;
    i : SInt32;
    MoisEnChiffre : str2;
    MoisEnLettres : str3;
begin
  nouveauNom := '';
  for i := 1 to Length(ancNom) do
    begin
      c := ancNom[i];
      
      (*
      if effetspecial2 then
      if (c<>' ') & (c<>'.') & (c<>'-') then
      if not(((c>='a') & (c<='z')) | ((c>='A') & (c<='Z'))) then
        begin
          EssaieSetPortWindowPlateau;
          WriteStringAndNumAt(c+' soit ASCII #',ord(c),10,10);
          WriteStringAt(ancNom,10,20);
          AttendFrappeClavierOuSouris(effetspecial2);
        end;
      *)
      
      if ord(c)=233 then c := 'é' else
      if ord(c)=232 then c := 'è' else
      if c='Ç' then c := 'é' else
      if c='ä' then c := 'è';
      nouveauNom := Concat(nouveauNom,c);
    end;
    
  case traductionMoisTournoi of
    SucrerPurementEtSimplement:
      if nouveauNom[25]='/' then 
        begin
          nouveauNom[25] := ' ';
          nouveauNom[24] := ' ';
          if (nouveauNom[23]>='0') & (nouveauNom[23]<='9') then nouveauNom[23] := ' ';
        end;
    MoisEnToutesLettres:
      if nouveauNom[25]='/' then 
        begin
          MoisEnChiffre := Concat(nouveauNom[24],nouveauNom[25]);
          if MoisEnChiffre='01' then MoisEnLettres := 'jan' else
          if MoisEnChiffre='02' then MoisEnLettres := 'fev' else
          if MoisEnChiffre='03' then MoisEnLettres := 'mar' else
          if MoisEnChiffre='04' then MoisEnLettres := 'avr' else
          if MoisEnChiffre='05' then MoisEnLettres := 'mai' else
          if MoisEnChiffre='06' then MoisEnLettres := 'jun' else
          if MoisEnChiffre='07' then MoisEnLettres := 'jui' else
          if MoisEnChiffre='08' then MoisEnLettres := 'aou' else
          if MoisEnChiffre='09' then MoisEnLettres := 'sep' else
          if MoisEnChiffre='10' then MoisEnLettres := 'oct' else
          if MoisEnChiffre='11' then MoisEnLettres := 'nov' else
          if MoisEnChiffre='12' then MoisEnLettres := 'dec';
          nouveauNom[23] := MoisEnLettres[1];
          nouveauNom[24] := MoisEnLettres[2];
          nouveauNom[25] := MoisEnLettres[3];
        end;
  end; {case}
  
  premierCaractere := nouveauNom[1];
    
  {
  if premierCaractere='D' then 
    nouveauNom := ReplaceStringByStringInString('Divers avant et pendant',
                                                'Diverses parties avant',nouveauNom);
  }
end;

procedure TraduitNomJoueurEnMac(ancNom:str30; var nouveauNom:str30);
var c,premierCaractere : char;
    i : SInt32;
begin
  nouveauNom := '';
  for i := 1 to Length(ancNom) do
    begin
      c := ancNom[i];
      
      {
      if effetspecial2 then
      if (c<>' ') & (c<>'.') & (c<>'-') then
      if not(((c>='a') & (c<='z')) | ((c>='A') & (c<='Z'))) then
        begin
          EssaieSetPortWindowPlateau;
          WriteStringAndNumAt(c+' soit ASCII #',ord(c),10,10);
          WriteStringAt(ancNom,10,20);
          AttendFrappeClavierOuSouris(effetspecial2);
        end;
      }  
        
      if ord(c)=233 then c := 'é' else
      if ord(c)=232 then c := 'è' else
      if c='Ç' then c := 'é' else
      if c='ä' then c := 'è';
      nouveauNom := Concat(nouveauNom,c);
    end;
    
  premierCaractere := nouveauNom[1];
    
  if premierCaractere='C' then 
    nouveauNom := ReplaceStringByStringInString('Cassio (nicolet)','Cassio (coucou !)',nouveauNom);
  if premierCaractere='M' then 
    nouveauNom := ReplaceStringByStringInString('Modot (feinstein)','Modot (joel)',nouveauNom);
  if premierCaractere='T' then 
    nouveauNom := ReplaceStringByStringInString('Tom Pouce (andrian)','Tom Pouce (bintsa)',nouveauNom);
  if premierCaractere='5' then 
    nouveauNom := ReplaceStringByStringInString('5semaines (lanuit)','Cinq semaines ()',nouveauNom);
  if not(gVersionJaponaiseDeCassio & gHasJapaneseScript) then
    begin
		  if premierCaractere='B' then 
		    begin
		      nouveauNom := ReplaceStringByStringInString('Bracchi Andre','Bracchi André',nouveauNom);
		      nouveauNom := ReplaceStringByStringInString('Bernou Stephan','Bernou Stéphan',nouveauNom);
		      nouveauNom := ReplaceStringByStringInString('Betin','Bétin',nouveauNom);
		    end;
		  if premierCaractere='G' then 
		    nouveauNom := ReplaceStringByStringInString('Grison Remi','Grison Rémi',nouveauNom);
		  if premierCaractere='S' then 
		    nouveauNom := ReplaceStringByStringInString('Seknadje Jose','Seknadjé José',nouveauNom);
		  if premierCaractere='T' then 
		    nouveauNom := ReplaceStringByStringInString('Theole','Théole',nouveauNom);
		  if premierCaractere='L' then 
		    nouveauNom := ReplaceStringByStringInString('Lery Michele','Léry Michèle',nouveauNom);
		  if premierCaractere='P' then 
		    nouveauNom := ReplaceStringByStringInString('Puree','Purée',nouveauNom);
		    
		  nouveauNom := ReplaceStringByStringInString('Stephane','Stéphane',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Stephanie','Stéphanie',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Sebastien','Sébastien',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Angeliqu','Angéliqu',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Frederic','Frédéric',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Valerie','Valérie',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Beatrice','Béatrice',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Gerard','Gérard',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Jerome','Jérome',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Herve','Hervé',nouveauNom);
		  nouveauNom := ReplaceStringByStringInString('Francois','François',nouveauNom);
		end;

  {if Pos('<IOS>',nouveauNom)>0 then 
    nouveauNom := Concat(Concat('"',TPCopy(nouveauNom,6,Length(nouveauNom)-5)),'"');}
  if premierCaractere='<' then
    if Pos('<IOS>',nouveauNom)>0 then
      nouveauNom := Concat(Concat('<',TPCopy(nouveauNom,6,Length(nouveauNom)-5)),'>');
  
  if (premierCaractere='O') | (premierCaractere='0') |
     (((nouveauNom[2]='O') | (nouveauNom[2]='0')) & (premierCaractere='<')) then
    begin
      nouveauNom := ReplaceStringByStringInString('Oo7','007',nouveauNom);{on met des vrais zéros}
      nouveauNom := ReplaceStringByStringInString('OO7','007',nouveauNom);
      nouveauNom := ReplaceStringByStringInString('O07','007',nouveauNom);
      nouveauNom := ReplaceStringByStringInString('0O7','007',nouveauNom);
      nouveauNom := ReplaceStringByStringInString('0o7','007',nouveauNom);
    end;

end;


procedure EnlevePrenom(const nomOrigine:str19; var nomSansPrenom : str255);
var i,longueur : SInt32;
    c : char;
begin
  nomSansPrenom := '';
  longueur := Length(nomOrigine);
  i := 1;
  repeat
    c := nomOrigine[i];
    if (i=1) & (c>='a') & (c<='z') then c := chr(ord(c)-32);
    if ord(c) <> 0 then nomSansPrenom := Concat(nomSansPrenom,c);
    i := i+1;
  until ((c=' ') & 
        (nomSansPrenom<>'Le ')       & 
        (nomSansPrenom<>'Di ')       &
        (nomSansPrenom<>'De la ')    & 
        (nomSansPrenom<>'De ')       & 
        (nomSansPrenom<>'Den ')      & 
        (nomSansPrenom<>'Othel ')    & 
        (nomSansPrenom<>'Othel du ') & 
        (nomSansPrenom<>'Qvist ')    & 
        (nomSansPrenom<>'Peer ')     &
        (nomSansPrenom<>'Van ')      & 
        (nomSansPrenom<>'Van de ')   & 
        (nomSansPrenom<>'Van der ')  & 
        (nomSansPrenom<>'V/d ')      & 
        (nomSansPrenom<>'In het ')   & 
        (nomSansPrenom<>'Saint ')    & 
        ((nomSansPrenom<>'Gros ') | (nomOrigine <> 'Gros Thello (pinta)'))   & 
        (nomSansPrenom<>'Reversi ')  & 
        (nomSansPrenom<>'Pee ')      &
        (nomSansPrenom<>'Tom ')      &
        (nomSansPrenom<>'Von ')      &
        (nomSansPrenom<>'La ')       & 
        (nomSansPrenom<>'Du ')       & 
        (nomSansPrenom<>'El ')       & 
        (nomSansPrenom<>'The ')      & 
        (nomSansPrenom<>'Pc ')       & 
        (nomSansPrenom<>'Des '))
        | (i>longueur) | (ord(c)=0);
end;


function FabriqueNomEnMajusculesSansEspaceDunNomWThor(nom : str255) : str255;
var s : str255;
    k : SInt32;
    c : char;
begin
  UpperString(nom,false);
  s := '';
  for k := 1 to Length(nom) do
    begin
      c := nom[k];
      if (c <> ' ') & (c <> '-') & (c <> '–') & (c <> '_') & (c <> ' ') & (c <> '.') & (c <> '(') & (c <> ')') then
        s := s + c;
    end;
  FabriqueNomEnMajusculesSansEspaceDunNomWThor := s;
end;


function FabriqueNomJoueurPourBaseWThorOfficielle(var nom : str255):t_JoueurRecNouveauFormat;
var result:t_JoueurRecNouveauFormat;
    k : SInt32;
begin
  for k := 1 to TailleJoueurRecNouveauFormat do 
    result[k] := 0;
  
  nom := MyStripDiacritics(nom);
  EnleveEspacesDeDroiteSurPlace(nom);
  EnleveEspacesDeGaucheSurPlace(nom);
  nom := LeftOfString(nom,TailleJoueurRecNouveauFormat-1);
  
  for k := 1 to Length(nom) do
    result[k] := ord(nom[k]);
  
  FabriqueNomJoueurPourBaseWThorOfficielle := result;
end;


function FabriqueNomTournoiPourBaseWThorOfficielle(var nom : str255) : t_TournoiRecNouveauFormat;
var result : t_TournoiRecNouveauFormat;
    k : SInt32;
begin
  for k := 1 to TailleTournoiRecNouveauFormat do 
    result[k] := 0;
  
  nom := MyStripDiacritics(nom);
  EnleveEspacesDeDroiteSurPlace(nom);
  EnleveEspacesDeGaucheSurPlace(nom);
  nom := LeftOfString(nom,TailleTournoiRecNouveauFormat-1);
  
  for k := 1 to Length(nom) do
    result[k] := ord(nom[k]);
  
  FabriqueNomTournoiPourBaseWThorOfficielle := result;
end;


function JoueurRecNouveauFormatToString(whichPlayer:t_JoueurRecNouveauFormat):str30;
var result:str30;
    k : SInt32;
begin
  result := '';
  for k := 1 to TailleJoueurRecNouveauFormat do
    if (whichPlayer[k] <> 0) then result := result + chr(whichPlayer[k]);
  JoueurRecNouveauFormatToString := result;
end;


function TournoiRecNouveauFormatToString(whichTourney : t_TournoiRecNouveauFormat):str30;
var result:str30;
    k : SInt32;
begin
  result := '';
  for k := 1 to TailleTournoiRecNouveauFormat do
    if (whichTourney[k] <> 0) then result := result + chr(whichTourney[k]);
  TournoiRecNouveauFormatToString := result;
end;



function NomCourtDuTournoi(const nomOrigine:str30) : str255;
var longueur : SInt32;
    s : str255;
begin
  NomCourtDuTournoi := '';
  longueur := Length(nomOrigine);
  
  s := nomOrigine;
  
  
  s := ReplaceStringByStringInString('Divers avant et pendant','Avant',s);
  s := ReplaceStringByStringInString('Aas Open & Othello Cup','Aas',s);
  s := ReplaceStringByStringInString('Othello Cup','',s);
  
  
  s := ReplaceStringByStringInString('Torneo a','',s);
  s := ReplaceStringByStringInString('Torneo di','',s);
  s := ReplaceStringByStringInString('Torneo','',s);
  
  s := ReplaceStringByStringInString('Tournois de','',s);
  s := ReplaceStringByStringInString('Tournois','',s);
  s := ReplaceStringByStringInString('Tournoi de','',s);
  s := ReplaceStringByStringInString('Tournoi','',s);
  
  s := ReplaceStringByStringInString('Opens de','',s);
  s := ReplaceStringByStringInString('Open de','',s);
  s := ReplaceStringByStringInString('Opens','',s);
  s := ReplaceStringByStringInString('Open 1','',s);
  s := ReplaceStringByStringInString('Open 2','',s);
  s := ReplaceStringByStringInString('Open 3','',s);
  s := ReplaceStringByStringInString('Open 4','',s);
  s := ReplaceStringByStringInString('Open 5','',s);
  s := ReplaceStringByStringInString('Open 6','',s);
  s := ReplaceStringByStringInString('Open 7','',s);
  s := ReplaceStringByStringInString('Open 8','',s);
  s := ReplaceStringByStringInString('Open 9','',s);
  s := ReplaceStringByStringInString('Open','',s);
  
  s := ReplaceStringByStringInString('Sélections Champ. France','Selections',s);
  
  s := ReplaceStringByStringInString('Championnat du Monde','Mondial',s);
  s := ReplaceStringByStringInString('Championnat des','Ch.',s);
  s := ReplaceStringByStringInString('Championnat de','Ch.',s);
  s := ReplaceStringByStringInString('Championnat du','Ch.',s);
  s := ReplaceStringByStringInString('Championnats du','Ch.',s);
  s := ReplaceStringByStringInString('Championnats des','Ch.',s);
  s := ReplaceStringByStringInString('Championnats de','Ch.',s);
  s := ReplaceStringByStringInString('Championnat d''','Ch. ',s);
  s := ReplaceStringByStringInString('Championnats d''','Ch. ',s);
  s := ReplaceStringByStringInString('Champ.','Ch.',s);
  s := ReplaceStringByStringInString('Championnat','Ch.',s);
  s := ReplaceStringByStringInString('Ch. Clubs France','Ch. Clubs',s);
  
  
  s := ReplaceStringByStringInString('International de','',s);
  s := ReplaceStringByStringInString('International','',s);
  
  s := ReplaceStringByStringInString('EGP','',s);
  s := ReplaceStringByStringInString('GPE','',s);
  
  s := ReplaceStringByStringInString('Nationals','Nat.',s);
  s := ReplaceStringByStringInString('National','Nat.',s);
  
  s := ReplaceStringByStringInString('Sélection de','',s);
  s := ReplaceStringByStringInString('Sélection','',s);
  
  s := ReplaceStringByStringInString('Grand Prix de','G.P.',s);
  s := ReplaceStringByStringInString('Grand-Prix de','G.P.',s);
  s := ReplaceStringByStringInString('Grand Prix d''','G.P. ',s);
  s := ReplaceStringByStringInString('Grand-Prix d''','G.P. ',s);
  s := ReplaceStringByStringInString('Grand Prix','G.P.',s);
  s := ReplaceStringByStringInString('Grand-Prix','G.P.',s);
  s := ReplaceStringByStringInString('Stage de','',s);
  s := ReplaceStringByStringInString('Ladder','',s);
  s := ReplaceStringByStringInString('Christmas T.','Noel',s);
  s := ReplaceStringByStringInString('Christmas T','Noel',s);
  s := ReplaceStringByStringInString('Copenhagen Noel','Copenhagen Noel',s);
  s := ReplaceStringByStringInString('Mind Sports Olympiad','MSO',s);
  s := ReplaceStringByStringInString('Swedish League Online','Swedish League',s);
  s := ReplaceStringByStringInString('Hommes-Machines de Paris','Hommes-Machines',s);
  s := ReplaceStringByStringInString('Hommes-Machines','Hommes-Mach.',s);
  s := ReplaceStringByStringInString('Seaside','',s);
  
  
  
  s := ReplaceStringByStringInString('Russie 1','Russie',s);
  s := ReplaceStringByStringInString('Russie 2','Russie',s);
  s := ReplaceStringByStringInString('Russie 3&4','Russie',s);
  s := ReplaceStringByStringInString('Russie 3','Russie',s);
  s := ReplaceStringByStringInString('Russie 4','Russie',s);
  
  s := ReplaceStringByStringInString('Grande-Bretagne','G.B.',s);
  
  s := ReplaceStringByStringInString('Parties Internet (1-6)','Internet',s);
  s := ReplaceStringByStringInString('Parties Internet (7-12)','Internet',s);
  s := ReplaceStringByStringInString('Parties japonaises','Japon',s);
  s := ReplaceStringByStringInString('Parties hollandaises','Hollande',s);
  s := ReplaceStringByStringInString('Parties neerlandaises','Pays-Bas',s);
  s := ReplaceStringByStringInString('Parties anglaises','Angleterre',s);
  s := ReplaceStringByStringInString('Parties italiennes','Italie',s);
  s := ReplaceStringByStringInString('Parties tcheques','Tchéquie',s);
  {s := ReplaceStringByStringInString('Parties nordiques','Scandinavie',s);}
  s := ReplaceStringByStringInString('Parties nordiques','Nordiques',s);
  s := ReplaceStringByStringInString('Parties sur minitel','Minitel',s);
  s := ReplaceStringByStringInString('Parties argentines','Argentine',s);
  s := ReplaceStringByStringInString('Parties belges','Belgique',s);
  s := ReplaceStringByStringInString('Parties du','',s);
  s := ReplaceStringByStringInString('Parties de','',s);
  s := ReplaceStringByStringInString('Parties','',s);
  
  s := ReplaceStringByStringInString('Match','',s);
  s := ReplaceStringByStringInString('(prg)','',s);
  s := ReplaceStringByStringInString('(France)','',s);
  s := ReplaceStringByStringInString('Diverses parties','Diverses',s);
  s := ReplaceStringByStringInString('Othello','',s);
  s := ReplaceStringByStringInString('Cup','',s);
  s := ReplaceStringByStringInString('Blitz','',s);
  {s := ReplaceStringByStringInString('Villeneuve d''A','Villeneuve d''Ascq',s);}
  
  s := ReplaceStringByStringInString('Mariage de Brian Rose','Mariage',s);
  s := ReplaceStringByStringInString('Thématique semi-rapide','Semi-rapide',s);
  s := ReplaceStringByStringInString('Murakami-Logistello','Match',s);
  s := ReplaceStringByStringInString('Ch. France Junior','Ch. Juniors',s);
  s := ReplaceStringByStringInString('Ch. Tchèque','Ch. Tchéquie',s);
  s := ReplaceStringByStringInString('Kansai Senshuken','Kansai',s);
  
  
  s := ReplaceStringByStringInString('  ',' ',s);
  s := ReplaceStringByStringInString('  ',' ',s);
  s := ReplaceStringByStringInString('  ',' ',s);
  
  EnleveEspacesDeGaucheSurPlace(s);
  EnleveEspacesDeDroiteSurPlace(s);
  
  s[1] := UpCase(s[1]);
  
  NomCourtDuTournoi := s;
end;


function ScoreFinalEnChaine(scorePourNoir : SInt16) : string;
var s1,s2 : str255;
   aux : SInt16; 
begin
  aux := scorePourNoir;
  if odd(aux) then
    if aux>0 then inc(aux) else
    if aux<0 then dec(aux);
  NumToString(32+(aux div 2),s1);
  NumToString(32-(aux div 2),s2);
  ScoreFinalEnChaine := s1+StringOf('-')+s2;
end;


procedure ConstruitTitrePartie(const nomNoir,nomBlanc : str255;enleverLesPrenoms : boolean;scoreNoir : SInt32; var titre : str255);
var s,s2 : str255;
    nom : str255;
begin
  if enleverLesPrenoms & (nomNoir[length(nomNoir)] <> '.') 
    then EnlevePrenom(nomNoir,nom)
    else nom := nomNoir;
    
  if (Pos('Tastet M.',nom) = 1) then nom := 'Tastet';
  if (Pos('TASTET M.',nom) = 1) then nom := 'TASTET';
  if (Pos('tastet m.',nom) = 1) then nom := 'tastet';
  if (Pos('tastet M.',nom) = 1) then nom := 'tastet';
    
  s := nom;
  
  NumToString(scoreNoir,s2);
  if nom[Length(nom)]=' ' 
    then s := s+s2+StringOf('-')
    else s := s+StringOf(' ')+s2+StringOf('-');
  NumToString(64-scoreNoir,s2);
  s := s+s2+StringOf(' ');
  
  if enleverLesPrenoms & (nomBlanc[length(nomBlanc)] <> '.') 
    then EnlevePrenom(nomBlanc,nom)
    else nom := nomBlanc;
  if nom[Length(nom)]=' ' then nom := TPCopy(nom,1,pred(Length(nom)));
  
  if (Pos('Tastet M.',nom) = 1) then nom := 'Tastet';
  if (Pos('TASTET M.',nom) = 1) then nom := 'TASTET';
  if (Pos('tastet m.',nom) = 1) then nom := 'tastet';
  if (Pos('tastet M.',nom) = 1) then nom := 'tastet';
  
  s := s+nom;
  titre := s;
 
end;


function EnleveAnneeADroiteDansChaine(var s : str255; var firstYear,lastYear : SInt16) : boolean;
var k,annee : SInt16; 
    s1 : str255;
    aux : SInt32;
    trouve,diminish : boolean;
begin
	trouve := false;
	annee := 0;
	firstYear := 10000;
	lastYear := -10000;
	
	repeat
	  diminish := false;
		k := Length(s);
		if (k>=5) &
		   IsDigit(s[k]) &
			 IsDigit(s[k-1]) &
			 IsDigit(s[k-2]) &
			 IsDigit(s[k-3]) &
			 ((s[k-4]=' ') | (s[k-4]='-')) then
			    begin
			      trouve := true;
			      diminish := true;
			      StringToNum(TPCopy(s,k-3,4),aux);
			      annee := aux;
			      if annee<firstYear then firstYear := annee;
			      if annee>lastYear then lastYear := annee;
			      s1 := TPCopy(s,1,k-5);
			      s1 := EnleveEspacesDeDroite(s1);
			      s := s1;
			    end;
		k := Length(s);
		if (k>=3) &
		   IsDigit(s[k]) &
			 IsDigit(s[k-1]) & 
			 ((s[k-2]=' ') | (s[k-2]='-')) then
			    begin
			      trouve := true;
			      diminish := true;
			      if s[k-1]>='5'     {1950}
			        then StringToNum('19'+s[k-1]+s[k],aux)
			        else StringToNum('20'+s[k-1]+s[k],aux);
			      annee := aux;
			      if annee<firstYear then firstYear := annee;
			      if annee>lastYear then lastYear := annee;
			      s1 := TPCopy(s,1,k-3);
			      s1 := EnleveEspacesDeDroite(s1);
			      s := s1;
			    end;
		 k := Length(s);
		 if (k=4) &
		   IsDigit(s[k]) &
			 IsDigit(s[k-1]) &
			 IsDigit(s[k-2]) &
			 IsDigit(s[k-3]) then
			    begin
			      trouve := true;
			      diminish := true;
			      StringToNum(s,aux);
			      annee := aux;
			      if annee<firstYear then firstYear := annee;
			      if annee>lastYear then lastYear := annee;
			      s := '';
			    end;
	  k := Length(s);
		if (k=2) &
		   IsDigit(s[k]) &
			 IsDigit(s[k-1]) then
			    begin
			      trouve := true;
			      diminish := true;
			      if s[k-1]>='5'     {1950}
			        then StringToNum('19'+s[k-1]+s[k],aux)
			        else StringToNum('20'+s[k-1]+s[k],aux);
			      annee := aux;
			      if annee<firstYear then firstYear := annee;
			      if annee>lastYear then lastYear := annee;
			      s := '';
			    end;
	until not(diminish);
  if trouve & (firstYear<1950) then firstYear := 1950;
  if trouve & (firstYear>2049) then firstYear := 2049;
  if trouve & (lastYear<1950) then lastYear := 1950;
  if trouve & (lastYear>2049) then lastYear := 2049;
	EnleveAnneeADroiteDansChaine := trouve;
end;

procedure EchangeSurnoms(var nom:str19);
var s : str255;
begin
  s := nom;
  UpperString(s,false);
  if s='PROF' then nom := 'tastet marc' else
  if s='TATA' then nom := 'tamenori hideshi' else
  if s='BDLB' then nom := 'de la boisserie bru' else
  if s='VDLB' then nom := 'de la boisserie vin' else
  if s='DIP' then nom := 'piau didier' else
  if s='DOP' then nom := 'penloup dominique' else
  if s='OO7' then nom := '007 (buro)' else  {on met des vrais zéros}
  if s='O07' then nom := '007 (buro)' else
  if s='0O7' then nom := '007 (buro)' else
  if s='oo7' then nom := '007 (buro)' else
  if s='Oo7' then nom := '007 (buro)';
end;

procedure EpureNomJoueur(var unNomDeJoueur:str19);
var c : char;
    long,i : SInt16; 
    nomAux:str19;
begin
  long := Length(unNomDeJoueur);
  if long>19 then long := 19;
  nomAux := '';
  for i := 1 to long do
    begin
      c := unNomDeJoueur[i];
      if (c='é') | (c='è') then c := 'e';
      if (c>='A') & (c<='Z') then c := chr(ord(c)+32);
      nomAux := nomAux+c;
    end;
  EchangeSurnoms(nomAux);
  unNomDeJoueur := nomAux;
end;

procedure TraiteJoueurEnMinuscules(nomBrut : str255; var nomJoueur:str19); 
var c : char;
    long,i : SInt32;
begin
  long := Length(nomBrut);
  if long>19 then long := 19;
  nomJoueur := '';
  for i := 1 to long do
    begin
      c := nomBrut[i];
      if (c='é') | (c='è') then c := 'e';
      if (c>='A') & (c<='Z') then c := chr(ord(c)+32);
      nomJoueur := Concat(nomJoueur,c);
    end;
  EchangeSurnoms(nomJoueur);
end;


procedure TraiteTournoiEnMinuscules(nom : str255; var nomTournoi:str29);
var i,longueur : SInt32;
    c : char;
begin
  longueur := Length(nom);
  if longueur>29 then longueur := 29;
  nomTournoi := '';
  for i := 1 to longueur do
    begin
      c := nom[i];
      if (c>='A') & (c<='Z') then c := chr(ord(c)+32);
      nomTournoi := Concat(nomTournoi,c);
    end;
  
  nomTournoi := MyLowerString(nomTournoi,false);
end;

procedure TournoiEnMinuscules(var nomBrut:str29);
begin
  nomBrut := MyLowerString(nomBrut,false);
end;


function PositionsSontEgales(var pos1,pos2 : plateauOthello) : boolean;
var i : SInt16; 
begin
  for i := 11 to 88 do
    if pos1[i]<>pos2[i] then
      begin
        PositionsSontEgales := false;
        exit(PositionsSontEgales);
      end;
  PositionsSontEgales := true;
end;


function CalculePositionApres(numero : SInt16; partie60 : PackedThorGame) : plateauOthello;
var trait,i : SInt16; 
    plat : plateauOthello;
    foo : boolean;
begin
  OthellierDeDepart(plat);
  trait := pionNoir;
  for i := 1 to Min(GET_LENGTH_OF_PACKED_GAME(partie60),numero) do
    begin
      if ModifPlatSeulement(GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'CalculePositionApres(1)'),plat,trait)
        then trait := -trait
        else foo := ModifPlatSeulement(GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'CalculePositionApres(1)'),plat,-trait);
    end;
  CalculePositionApres := plat;
end;


function CalculePositionEtTraitApres(var partie60 : PackedThorGame; numeroCoup : SInt16; var position : plateauOthello; var trait,nbBlanc,nbNoir : SInt32) : boolean;
var i,coup : SInt16; 
begin
  CalculePositionEtTraitApres := false;
  if (GET_LENGTH_OF_PACKED_GAME(partie60) < numeroCoup)
    then exit(CalculePositionEtTraitApres);      {pas assez de coups}
  
  OthellierEtPionsDeDepart(position,nbNoir,nbBlanc);
  trait := pionNoir;
  for i := 1 to Min(GET_LENGTH_OF_PACKED_GAME(partie60),numeroCoup) do
    begin
      coup := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'CalculePositionEtTraitApres(1)');
      if (coup<11) | (coup>88) 
        then exit(CalculePositionEtTraitApres);  {coup impensable}
      if ModifPlatFin(coup,trait,position,nbBlanc,nbNoir) then trait := -trait else
      if not(ModifPlatFin(coup,-trait,position,nbBlanc,nbNoir)) 
        then exit(CalculePositionEtTraitApres);  {coup impossible ou game over}    
    end;
  if DoitPasserPlatSeulement(trait,position) then 
    begin
      trait := -trait;
      if DoitPasserPlatSeulement(trait,position)
        then exit(CalculePositionEtTraitApres);  {game over!}
     end;
  CalculePositionEtTraitApres := true;
end;


function GetPositionInitialePartieEnCours() : PositionEtTraitRec;
var numeroPremierCoup,trait,nbBlancsInitial,nbNoirsInitial : SInt32;
    jeu : plateauOthello;
begin
  GetPositionInitialeOfGameTree(jeu,numeroPremierCoup,trait,nbBlancsInitial,nbNoirsInitial);
  GetPositionInitialePartieEnCours := MakePositionEtTrait(jeu,trait);
end;


function GetPositionEtTraitPartieEnCoursApresCeCoup(numeroCoup : SInt16; var typeErreur : SInt32) : PositionEtTraitRec;
var s : str255;
    partie60 : PackedThorGame; 
begin
  s := PartiePourPressePapier(true,false,numeroCoup);
  TraductionAlphanumeriqueEnThor(s,partie60);
  GetPositionEtTraitPartieEnCoursApresCeCoup := PositionEtTraitAfterMoveNumber(partie60,numeroCoup,typeErreur);
end;


{$s Affichage}


const yCurseurPremierParametre   = 90;
      xminSlider                 = 200;
      xmaxSlider                 = 400;
      kInterligneEntreDeuxCoeffs = 22;
      kNombreDeCoefficients      = 4;
      


procedure CalculEtAfficheCoeff(dp : DialogPtr;mouseX,item,hauteurExacte : SInt16);
const ln4=1.386294;
var c : extended;
begin
  c := exp(ln4*(2*(mouseX-xmaxSlider)/(xmaxSlider-xminSlider)+1));
  if c<0.25 then c := 0.25;
  if c>4.0 then c := 4.0;
  DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,hauteurExacte,c);
  case item of
      1: Coefffrontiere := c;
      2: Coeffminimisation := c;
      3: CoeffMobiliteUnidirectionnelle := c;
      4: CoeffPenalite := c;
      
      {2: CoeffEquivalence := c;
      3: Coeffcentre := c;
      4: Coeffgrandcentre := c;
      5: Coeffbetonnage := c;}
      {7: CoeffpriseCoin := c;
      8: CoeffdefenseCoin := c;
      9: CoeffValeurCoin := c;
      10: CoeffValeurCaseX := c;}
      
    end;
end;

function ClicSurCurseurCoeff(mouseLoc : Point; var hauteurExacte,nroCoeff : SInt16) : boolean;
const ln4=1.386294;
var aux,haut : SInt16; 
    c : extended;
    test : boolean;
begin
   nroCoeff := 1 + (mouseLoc.v - yCurseurPremierParametre + (kInterligneEntreDeuxCoeffs div 2)) div kInterligneEntreDeuxCoeffs;
   hauteurExacte := yCurseurPremierParametre+(nroCoeff-1)*kInterligneEntreDeuxCoeffs;
   case nroCoeff of
      1: c := Coefffrontiere;
      2: c := Coeffminimisation;
      3: c := CoeffMobiliteUnidirectionnelle;
      4: c := CoeffPenalite;
      
      {
      2: c := CoeffEquivalence;
      3: c := Coeffcentre;
      4: c := Coeffgrandcentre;
      5: c := Coeffbetonnage;
      7: c := CoeffpriseCoin;
      8: c := CoeffdefenseCoin;
      9: c := CoeffValeurCoin;
      10: c := CoeffValeurCaseX;
      }
      
    end;
    aux := (xminSlider+xmaxSlider) div 2 +MyTrunc((xmaxSlider-xminSlider)*ln(c)/2/ln4);
    
    haut := (kInterligneEntreDeuxCoeffs div 2) - 2;
    test := (aux- haut <= mouseLoc.h) & (mouseLoc.h <= aux + haut);
    ClicSurCurseurCoeff := test;
    if not(test) then nroCoeff := 0;
end;



function FiltreCoeffDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
var mouseLoc : Point;
    hauteurExacte,MouseX : SInt16; 
    Ecriturerect,Dessinerect,sourisrect : rect;
    tirecurseur,bouge : boolean;
    oldPort : grafPtr;
begin
  FiltreCoeffDialog := false;
  if not(EvenementDuDialogue(dlog,evt))
    then FiltreCoeffDialog := MyFiltreClassique(dlog,evt,item)
    else
      case evt.what of
        mouseDown:
          begin
            IncrementeCompteurDeMouseEvents;
            GetPort(oldPort);
            SetPortByDialog(dlog);
            
            mouseLoc := evt.where;
            GlobalToLocal(mouseLoc);
            if PtInRect(mouseLoc,EchelleCoeffsRect) then
              begin
                if ClicSurCurseurCoeff(mouseLoc,hauteurExacte,item) then
                begin
                  SetRect(sourisrect,EchelleCoeffsRect.left-850,hauteurExacte-857,EchelleCoeffsRect.right+850,hauteurExacte+857);
                  SetRect(Dessinerect,EchelleCoeffsRect.left-5,hauteurExacte-(kInterligneEntreDeuxCoeffs div 2),EchelleCoeffsRect.right+60,hauteurExacte+(kInterligneEntreDeuxCoeffs div 2));
                  SetRect(Ecriturerect,0,hauteurExacte-7,EchelleCoeffsRect.left-5,hauteurExacte+7);
                  tirecurseur := true;
                  mouseX := 0;
                  while Button() & tirecurseur do
                    begin
                      GetMouse(mouseLoc);
                      tirecurseur := PtInRect(mouseLoc,sourisrect);
                      bouge := (mouseLoc.h <> mouseX) & 
                             (((mouseLoc.h >= EchelleCoeffsRect.left ) & (mouseLoc.h <= EchelleCoeffsRect.right)) |
                              ((mouseLoc.h <= EchelleCoeffsRect.left ) & (mouseX >= EchelleCoeffsRect.left)) |
                              ((mouseLoc.h >= EchelleCoeffsRect.right) & (mouseX <= EchelleCoeffsRect.right)));
                      if bouge & tirecurseur then
                        begin
                          EraseRect(Dessinerect);
                          CalculEtAfficheCoeff(dlog,mouseLoc.h,item,hauteurExacte);
                          Superviseur(nbreCoup);
                          EraseRect(Ecriturerect);
                          EcritParametres(dlog,item);
                          ShareTimeWithOtherProcesses(2);
                        end;
                      MouseX := mouseLoc.h;
                    end;
                  FiltreCoeffDialog := true;
                  item := 0;
                end;
              end
             else
              FiltreCoeffDialog := MyFiltreClassique(dlog,evt,item);
              
            SetPort(oldPort);
          end;
       updateEvt :
         begin
           item := VirtualUpdateItemInDialog;
           FiltreCoeffDialog := true;
         end;
       otherwise FiltreCoeffDialog := MyFiltreClassique(dlog,evt,item)
     end;  {case}
end;


procedure DessineEchellesCoeffs(dp : DialogPtr);
var y : SInt32;
begin
    y := yCurseurPremierParametre;
    DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,y,Coefffrontiere);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,y,Coeffminimisation);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,y,CoeffMobiliteUnidirectionnelle); 
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,y,CoeffPenalite); 
    
    {
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffEquivalence);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,Coeffcentre);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,Coeffgrandcentre);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,Coeffbetonnage);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffpriseCoin);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffdefenseCoin);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffValeurCoin);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffValeurCaseX);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,Coeffinfluence); 
    }
    SetRect(EchelleCoeffsRect,xminSlider-8,yCurseurPremierParametre - (kInterligneEntreDeuxCoeffs div 2),xmaxSlider+8,y+kInterligneEntreDeuxCoeffs);
end;



procedure DessineBord(xdeb,y : SInt32;indexBord : SInt32);
  const taille=12;
  var i,x,dx : SInt32;
      unRect : rect;
  begin
    PenSize(1,1);
    dx := dir[indexBord];
    x := casebord[indexBord]-dx;
    if (indexBord=4) | (indexBord=2) then 
      begin
        x := x+7*dx;
        dx := -dx;
      end;
    for i := 1 to 8 do
     BEGIN
       SetRect(unRect,xdeb+(i-1)*taille,y-taille-1,xdeb+i*taille+1,y);
       FrameRect(unRect);
       if jeuCourant[x] = pionBlanc then 
         begin
           InsetRect(unRect,2,2);
           FrameOval(unRect);
         end;
       if jeuCourant[x] = pionNoir then 
         begin
           InsetRect(unRect,2,2);
           FillOval(unRect,blackPattern);
         end;
       x := x+dx;
      END;  
  end;

procedure DessineEchelleEtCurseur(dp : DialogPtr;xmin,xmax,y : SInt32;coeff : extended);
const ln4=1.386294;
var s : str255;
    aux : SInt32;
    mil : SInt32;
    err : OSStatus;
    sliderRect : rect;
    theSlider:ControlHandle;
begin
  mil := (xmin+xmax) div 2;
  aux := mil + MyTrunc((xmax-xmin)*ln(coeff)/2/ln4);
  
  
  if true
    then
      begin
        if not(gIsRunningUnderMacOSX) 
          then sliderRect := MakeRect(xmin,y-8,xmax,y+9)
          else sliderRect := MakeRect(xmin,y-5,xmax,y+5);
        
        err := CreateSliderControl(GetDialogWindow(dp),sliderRect,aux,xmin,xmax,
                                   kControlSliderDoesNotPoint, 0, false, NIL, theSlider);
                                   
        if (err = NoErr) & (theSlider <> NIL) then
          begin
            Draw1Control(theSlider);
            ShowControl(theSlider);
            if SetControlVisibility(theSlider,false,false) = NoErr then;
            SizeControl(theSlider,0,0);
            DisposeControl(theSlider);
          end; 

      end
    else
      begin
        PenSize(1,1);
			  Moveto(xmin,y);
			  Lineto(xmax,y);
			  Moveto(xmin,y-2);
			  Lineto(xmin,y+2);
			  Moveto(xmax,y-2);
			  Lineto(xmax,y+2);
			  Moveto(mil,y-2);
			  Lineto(mil,y+2);
			  Moveto((xmin+mil) div 2,y-2);
			  Lineto((xmin+mil) div 2,y+2);
			  Moveto((xmax+mil) div 2,y-2);
			  Lineto((xmax+mil) div 2,y+2);
			  
			  PenSize(2,2);
			  Moveto(aux,y-4);
			  Lineto(aux,y+4);
			end;
  
  
  s := PourcentageReelEnString(coeff);
  if s='199%' then s := '200%';
  Moveto(xmax+10,y+3);
  TextFont(gCassioApplicationFont);
  TextSize(gCassioSmallFontSize);
  DrawString(s);
end;

procedure EcritParametre(dp : DialogPtr;s : str255;parametre : SInt32;y : SInt32);
var oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByDialog(dp);
   
  TextFont(systemFont);
  TextSize(0);
  Moveto(10,y);
  DrawString(s);
  
  if not(utilisationNouvelleEval) then
    begin
      NumToString(parametre,s);
      Moveto(160,y);
      DrawString(s);
    end;
  
  SetPort(oldPort);
end;

procedure EcritParametres(dp : DialogPtr;quelParametre : SInt16);
var y : SInt32;
    s : str255;
    oldPort : grafPtr;
begin
   GetPort(oldPort);
   SetPortByDialog(dp);
   
   TextFont(systemFont);
   TextSize(0);
   
   GetIndString(s,TextesCoeffsID,1);
   with QDGetPortBound() do
     Moveto((left+right-StringWidth(s)) div 2,35);
   if (quelParametre <= 0) then DrawString(s);
   
   y := yCurseurPremierParametre + 4;
   GetIndString(s,TextesCoeffsID,2);
   if (quelParametre = 1) | (quelParametre <= 0) then 
     EcritParametre(dp,s,-valFrontiere,y);
   
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,7);
   if (quelParametre = 2) | (quelParametre <= 0) then 
     EcritParametre(dp,s,-valMinimisationAvantCoins,y);   
     
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,19);
   if (quelParametre = 3) | (quelParametre <= 0) then 
     EcritParametre(dp,s,4*valMobiliteUnidirectionnelle,y);
     
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,12);
   if (quelParametre = 4) | (quelParametre <= 0) then 
     EcritParametre(dp,s,-penalitePourTraitAff,y);
     
   {
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,3);
   if (quelParametre = 2) | (quelParametre <= 0) then 
     EcritParametre(dp,s,-valEquivalentFrontiere,y);
     
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,4);
   if (quelParametre = 3) | (quelParametre <= 0) then 
     EcritParametre(dp,s,valPionCentre,y);   
     
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,5);
   if (quelParametre = 4) | (quelParametre <= 0) then 
     EcritParametre(dp,s,valPionPetitCentre,y);   
     
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,6);
   if (quelParametre = 5) | (quelParametre <= 0) then 
     EcritParametre(dp,s,valBetonnage,y);   
     
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,8);
   if (quelParametre = 7) | (quelParametre <= 0) then 
     EcritParametre(dp,s,valPriseCoin,y);  
     
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,9);
   if (quelParametre = 8) | (quelParametre <= 0) then 
     EcritParametre(dp,s,-valDefenseCoin,y);   
     
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,10);
   if (quelParametre = 9) | (quelParametre <= 0) then 
     EcritParametre(dp,s,valCoin,y);   
     
   y := y+kInterligneEntreDeuxCoeffs;
   GetIndString(s,TextesCoeffsID,11);
   if (quelParametre = 10) | (quelParametre <= 0) then 
     EcritParametre(dp,s,-valCaseX,y);   
     
  }
     
  SetPort(oldPort);
   
end;

procedure EcritEtDessineBords;
var y : SInt32;
    s : str255;
begin
     
   TextFont(systemFont);
   TextSize(0);
   
   y := yCurseurPremierParametre + kInterligneEntreDeuxCoeffs*kNombreDeCoefficients + 25;
   Moveto(10,y);
   GetIndString(s,TextesCoeffsID,13);
   DrawString(s);
   WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,17)+' : ',valeurBord^[-frontiereCourante.AdressePattern[kAdresseBordNord]],260,y);
   WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',valeurBord^[frontiereCourante.AdressePattern[kAdresseBordNord]],375,y);
   DessineBord(155,y+2,3);
   y := y+15;
   Moveto(10,y);
   GetIndString(s,TextesCoeffsID,14);
   DrawString(s);
   WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,17)+' : ',valeurBord^[-frontiereCourante.AdressePattern[kAdresseBordOuest]],260,y);
   WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',valeurBord^[frontiereCourante.AdressePattern[kAdresseBordOuest]],375,y);
   DessineBord(155,y+2,1);
   y := y+15;
   Moveto(10,y);
   GetIndString(s,TextesCoeffsID,15);
   DrawString(s);
   WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,17)+' : ',valeurBord^[-frontiereCourante.AdressePattern[kAdresseBordEst]],260,y);
   WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',valeurBord^[frontiereCourante.AdressePattern[kAdresseBordEst]],375,y);
   DessineBord(155,y+2,2);
   y := y+15;
   Moveto(10,y);
   GetIndString(s,TextesCoeffsID,16);
   DrawString(s);
   WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,17)+' : ',valeurBord^[-frontiereCourante.AdressePattern[kAdresseBordSud]],260,y);
   WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',valeurBord^[frontiereCourante.AdressePattern[kAdresseBordSud]],375,y);
   DessineBord(155,y+2,4);

end;

const TablesPositionnellesBox = 4;

procedure EcritValeursTablesPositionnelles(dp : DialogPtr);
var y : SInt32;
    unRect : rect;
begin
  
  GetDialogItemRect(dp,TablesPositionnellesBox,unRect);
  y := unRect.bottom-4;
  
  TextFont(systemFont);
  TextSize(0);
  WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,20)+' : ',(4+((nbreDePions[pionBlanc]+nbreDePions[pionNoir]) div 4))*ValeurBlocsDeCoinPourNoir(jeuCourant),220,y);
  WriteStringAndNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',(4+((nbreDePions[pionBlanc]+nbreDePions[pionNoir]) div 4))*ValeurBlocsDeCoinPourBlanc(jeuCourant),375,y);
end;

procedure EffaceValeursTablesPositionnelles(dp : DialogPtr);
var unRect : rect;
    y : SInt32;
begin
  GetDialogItemRect(dp,TablesPositionnellesBox,unRect);
  y := unRect.bottom-4;
  SetRect(unRect,220,y-15,1000,y+5);
  EraseRect(unRect);
end;



procedure DoInsererMarque;
var i : SInt32;
    peutMettreNouvelleMarque : boolean;
begin
  if (nbreCoup>0) & not(gameOver) then 
   if (marques[0]<10) then
    begin
      peutMettreNouvelleMarque := true;
      for i := 1 to marques[0] do
        if marques[i]=nbreCoup then peutMettreNouvelleMarque := false;
      if peutMettreNouvelleMarque then
         begin
           marques[0] := marques[0]+1;
           marques[marques[0]] := nbreCoup;
         end;
    end;
end;


procedure CopierPartieEnTEXT(enMajuscule,avecEspacesEntreCoups : boolean);
var s : str255;
    aux : SInt32;
begin
  s := PartiePourPressePapier(enMajuscule,avecEspacesEntreCoups,nbreCoup);
  
  aux := MyZeroScrap();
  if Length(s)>0 then aux := MyPutScrap(Length(s),'TEXT',@s[1]);
  aux := TEFromScrap();
end;

procedure CopierDiagrammePositionEnTEXT;
var s : str255;
    aux : SInt32;
begin
  s := PositionCouranteEnDiagrammeTEXTPourPressePapier();
  if Length(s)>0 then
    begin
      aux := MyZeroScrap();
      aux := MyPutScrap(Length(s),'TEXT',@s[1]);
      aux := TEFromScrap();
    end;
end;

procedure CopierDiagrammePartieEnTEXT;
var s : str255;
    aux : SInt32;
begin
  {s := DiagrammePartieEnTEXTPourPressePapier(true,'|','|');}  {pour diagrammes commme sur IOS}
  {s := DiagrammePartieEnTEXTPourPressePapier(false,'|',' ');} {pour diagrammes comme Lazard}
  s := DiagrammePartieEnTEXTPourPressePapier(false,'|','|');
  
  if Length(s)>0 then
    begin
      aux := MyZeroScrap();
      aux := MyPutScrap(Length(s),'TEXT',@s[1]);
      aux := TEFromScrap();
    end;
end;


procedure CopierPositionPourEndgameScriptEnTEXT;
var s : str255;
    aux : SInt32;
begin
  s := PositionEtTraitEnString(PositionEtTraitCourant());
  if Length(s)>0 then
    begin
      aux := MyZeroScrap();
      aux := MyPutScrap(Length(s),'TEXT',@s[1]);
      aux := TEFromScrap();
    end;
end;

procedure CopierDiagrammePositionEnHTML;
var err : OSErr;
    theZone : ZoneMemoire;
    fic : FichierTEXT;
    aux : SInt32;
begin
  FinRapport;
  aux := GetTailleRapport();
  
  (* Afficher le code HTML dans le rapport... *)
  err     := CreeSortieStandardEnFichierTexte(fic);  {en fait, dans le rapport}
  theZone := MakeZoneMemoireFichier(fic.nomFichier,0);
  if ZoneMemoireEstCorrecte(theZone)
    then
      begin
        err     := WritePositionEtTraitPageWebFFODansZoneMemoire(PositionEtTraitCourant(),'',theZone);
        DisposeZoneMemoire(theZone);
  
       (* ... et le copier dans le presse-papier *)
        SetDebutSelectionRapport(aux);
      	SetFinSelectionRapport(GetTailleRapport());				
        if CopierFromRapport() then;
      end;
end;


function PeutCompleterPartieAvecSelectionRapport(var partieAlpha : str255) : boolean;
var s,s1 : str255;
    longueur : SInt32;
    loc : SInt16; 
begin
  PeutCompleterPartieAvecSelectionRapport := false;
  partieAlpha := '';
  
  if SelectionRapportNonVide() then
    begin
      longueur := LongueurSelectionRapport();
      
      if (longueur < 2) | (longueur > 250)
        then exit(PeutCompleterPartieAvecSelectionRapport);
      
      s := SelectionRapportEnString(longueur);
      EnleveEspacesDeDroiteSurPlace(s);
      EnleveEspacesDeGaucheSurPlace(s);
      
      if ScannerStringPourTrouverCoup(1,s,loc) > 0 then
        begin
          s1 := PartiePourPressePapier(true,false,nbreCoup);
		      if (Length(s1) + Length(s)) <= 255 then
		        begin
		          s := s1 + s;
		          if EstUnePartieOthello(s,true) then
		            begin
		              partieAlpha := s;
		              PeutCompleterPartieAvecSelectionRapport := true;
		            end;
		        end;
		    end;
    end;
end;


function PeutCompleterPartieAvecLigneOptimale(var partieEnAlpha : str255) : boolean;
var positionACompleter : PositionEtTraitRec;
    scoreParfait : SInt32;
    erreur : SInt32;
    longueurPartie : SInt32;
    theGame : str255;
    completion : str255;
    nbNoirs,nbBlancs : SInt32;
begin
  PeutCompleterPartieAvecLigneOptimale := false;
  
  theGame := partieEnAlpha;
  { Compressons la partie }
  if EstUnePartieOthello(theGame,true) then
    begin
      { de maniere à pouvoir calculer son nombre de coup }
      longueurPartie := Length(theGame) div 2;
      
      { si c'est une partie non terminee... }
      if (longueurPartie < 60) & not(EstUnePartieOthelloTerminee(theGame,false,nbNoirs,nbBlancs)) then
        begin
          { ...on calcule la derniere position atteinte... }
          positionACompleter := PositionEtTraitAfterMoveNumberAlpha(theGame,longueurPartie,erreur);
          if (erreur = kPasErreur) then
            begin
              { ...et on essaye de calculer la meilleure suite depuis cette position intermediaire }
              completion := CalculeLigneOptimalePositionEtTrait(positionACompleter,kEndgameSolveToujoursRamenerLaSuite
                                                                                   {+ kEndgameSolveEcrirePositionDansRapport}
                                                                                   {+ kEndgameSolveEcrireInfosTechniquesDansRapport},
                                                                                   scoreParfait);
              if (completion <> '') then
                begin
                  theGame := theGame + completion;
                  if EstUnePartieOthelloTerminee(theGame,false,nbNoirs,nbBlancs) then
                    begin
                      PeutCompleterPartieAvecLigneOptimale := true;
                      partieEnAlpha := theGame;
                    end;
                end;
            end;
        end;
    end;
end;



procedure FabriqueMeilleureSuiteInfos(premierCoup : SInt16; 
                                   suiteJouee:t_suiteJouee;
                                   meilleureSuite:meilleureSuitePtr;
                                   coul : SInt16; plat : plateauOthello;nBla,nNoi : SInt32;
                                   message : SInt32);
var i,j,coup : SInt32;
    p : SInt32;
    eval : SInt32;
    AQui : SInt32;
    coupPossible : boolean;
    positionEtTrait : PositionEtTraitRec;
begin  
  VideMeilleureSuiteInfos;
  with meilleureSuiteInfos do
    begin
       numeroCoup := nNoi+nBla-4;
       statut := NeSaitPas;
       couleur := -coul;
       
       ligne[-1] := 44;
       if  RefleSurTempsJoueur then
       begin
         coup := meilleurCoupHum;
         if (coup<11) | (coup>88) then coup := 44;
         if PossibleMove[coup] & (coup<>premierCoup) then
           ligne[-1] := coup;
       end;
       
       ligne[0] := premierCoup;
       
       i := kNbMaxNiveaux+1;
       repeat
         i := i-1;
       until (i<0) | (suiteJouee[i] <> 0);
       for j := i downto 1 do
        begin
         coup := meilleureSuite^[i,j];
         if coup <> 0 then
           begin
             p := 1+(i-j);
             if (p>=1) & (p<=kNbMaxNiveaux) then
               ligne[p] := coup;
           end;
       end;
       
    if phaseDeLaPartie < phaseFinale 
     then
       begin
         positionEtTrait := MakePositionEtTrait(plat,coul);
         if (GetTraitOfPosition(positionEtTrait)<>coul) & not(DoitPasserPlatSeulement(coul,plat)) then
           begin
             SysBeep(0);
             WritelnDansRapport('erreur 1 dans FabriqueMeilleureSuiteInfos (milieu de partie) : GetTraitOfPosition(positionEtTrait)<>coul !!');
           end;
         i := 0;
         repeat
           inc(i);
           coup := ligne[i];
           coupPossible := (coup <> 0) & UpdatePositionEtTrait(positionEtTrait,coup);
         until not(coupPossible) | (i>=kNbMaxNiveaux);
         for j := i to kNbMaxNiveaux do ligne[j] := 0;
       end
     else
      if message=pasDeMessage
        then
          begin  
            aQui := coul;
            i := kNbMaxNiveaux+1;
            repeat
              i := i-1;
            until (i<0) | (suiteJouee[i] <> 0);
            for j := i downto 1 do
              begin
                coup := meilleureSuite^[i,j];
                if (coup <> 0) then
                  begin
                    coupPossible := ModifPlatFin(Coup,aQui,plat,nBla,nNoi);
                    if coupPossible 
                      then 
                        begin
                          aQui := -Aqui;
                        end
                      else 
                        coupPossible := ModifPlatFin(Coup,-aQui,plat,nBla,nNoi);
                  end;
              end;
            score.noir := nNoi;
            score.blanc := nBla;
            if InRange(numeroCoup,finDePartie,finDePartieOptimale) then
              begin
                eval := score.noir-score.blanc;
                if eval=0 then statut := nulle;
                if eval>0 then statut := victoireNoire;
                if eval<0 then statut := victoireBlanche;
                if message=messageToutEstPerdant then statut := toutEstPerdant;
                if message=messageToutEstProbablementPerdant then statut := toutEstProbablementPerdant;
              end;
          end
        else
          begin
            if message=messageToutEstPerdant then statut := toutEstPerdant;
            if message=messageToutEstProbablementPerdant then statut := toutEstProbablementPerdant;
            if message=messageFaitNulle then statut := nulle;
            if message=messageEstGagnant then
              if couleur = pionNoir 
                then statut := victoireNoire
                else statut := victoireBlanche;
            if message=messageEstPerdant then
              if couleur = pionNoir 
                then statut := victoireBlanche
                else statut := victoireNoire;
          end; 
   end;
end;



procedure SauvegardeLigneOptimale(coul : SInt32);
var i,coup : SInt32;
    ok : boolean;
begin
  
  if debuggage.calculFinaleOptimaleParOptimalite then
    begin
      WritelnDansRapport('');
      WritelnStringAndNumDansRapport('Entrée de SauvegardeLigneOptimale pour coul=',coul);
    end;

  with meilleureSuiteInfos do
  if phaseDeLaPartie>=phaseFinaleParfaite then
    if (coul=couleurMacintosh) | not(finaleEnModeSolitaire) then
     begin
       for i := 0 to nbreCoup do
         begin
           coup := GetNiemeCoupPartieCourante(i);
           if coup<>partie^^[i].coupParfait then
             begin
               partie^^[i].coupParfait := coup;
               partie^^[i].optimal := false;
             end;
         end;
       for i := nbreCoup+1 to numeroCoup-1 do
         begin
           coup := GetNiemeCoupPartieCourante(i);
           if (coup <> coupInconnu) & not(partie^^[i].optimal) then
             partie^^[i].coupParfait := coup;
         end;
         
       ok := true;
       coup := ligne[-1];
       if (coup<>44) & (coup>=11) & (coup<=88) then
         if partie^^[numeroCoup-1].optimal & (partie^^[numeroCoup-1].coupParfait<>coup)
           then ok := false
           else partie^^[numeroCoup-1].coupParfait := coup;
       
       if ok then
       for i := numeroCoup to 60 do
         begin
           coup := ligne[i-numeroCoup];
           partie^^[i].coupParfait := coup;
           if (i>nbreCoup) & ((i-numeroCoup)>=0) then 
             partie^^[i].optimal := true;
         end;
     end;
end;

procedure MetCoupEnTeteDansKiller(coup,KillerProf : SInt32);
  var k,kcoup : SInt32;
  begin
    if (killerProf>=profondeurMax) & (killerProf<=kNbMaxNiveaux) then
      if (coup>=11) & (coup<=88) then
          if not(interdit[coup]) then
            if not(estUnCoin[coup]) then
              begin 
                  if nbKillerGlb^[killerProf]=0 
                    then
                      begin
                        nbKillerGlb^[killerProf] := 1;
                        KillerGlb^[killerProf,1] := coup;
                      end
                    else
                      begin
                        kcoup := nbKillerGlb^[killerProf];
                        for k := 1 to nbKillerGlb^[killerProf] do 
                          if KillerGlb^[killerProf,k]=coup then kCoup := k;
                        if (KillerGlb^[killerProf,kcoup]<>coup) & (kcoup<nbCoupsMeurtriers) 
                          then kcoup := kcoup+1;
                        for k := kcoup downto 2 do
                          KillerGlb^[killerProf,k] := KillerGlb^[killerProf,k-1];
                        KillerGlb^[killerProf,1] := coup;
                      end;
              end;       
  end;


procedure MeilleureSuiteDansKiller(profKiller : SInt32);
  var p,i,coup : SInt32;
  begin  
    for i := 1 to kNbMaxNiveaux do
      begin
        coup := meilleureSuiteInfos.ligne[i];
        p := profKiller+1-i;
        MetCoupEnTeteDansKiller(coup,p);
      end;
  end;
  
function SquareSetToPlatBool(theSet : SquareSet) : plBool;
var result : plBool;
    i,j,aux : SInt16; 
begin
  for i := 0 to 99 do result[i] := false;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        aux := i*10+j;
        if aux in theSet then result[aux] := true;
      end;
  SquareSetToPlatBool := result;
end;



procedure SetNbrePionsPerduParVariation(numeroDuCoup,deltaScore : SInt32);
var i,somme : SInt16; 
begin
  if (numeroDuCoup>=0) & (numeroDuCoup<=64) then
  with gEntrainementOuvertures do
    begin
    
      {WritelnDansRapport('appel de SetNbrePionsPerduParVariation('+NumEnString(numeroDuCoup)+','+NumEnString(deltaScore)+')');}
    
      deltaNotePerduCeCoup[numeroDuCoup] := deltaScore;
      
      for i := numeroDuCoup+1 to 64 do
        deltaNotePerduCeCoup[i] := 0;
      
      somme := 0;
      for i := 0 to 64 do
        somme := somme + deltaNotePerduCeCoup[i];
      deltaNotePerduAuTotal := somme;
    end;
end;

function PrefixeFichierProfiler() : string;
begin
  if GetEffetSpecial()
    then PrefixeFichierProfiler := 'eff_'
    else PrefixeFichierProfiler := 'not(eff)_';
end;

procedure SetEffetSpecial(flag : boolean);
begin
  effetspecial := flag;
end;

function  GetEffetSpecial() : boolean;
begin
  GetEffetSpecial := effetspecial;
end;

function SetClefHashageGlobale(whichValue : SInt32) : SInt32;
begin
  gClefHashage := whichValue;
  SetClefHashageGlobale := whichValue;
end;

procedure TesterClefHashage(valeurCorrecte : SInt32;nomFonction : str255);
begin
  if (gClefHashage <> valeurCorrecte) then
    begin
      WritelnStringAndNumDansRapport('gClefHashage = ',gClefHashage);
      AlerteSimple('Erreur dans mon algorithme, gClefHashage='+NumEnString(gClefHashage)+ ' dans '+nomFonction+'!! Prévenez Stéphane');
    end;
end;


procedure InitUnitUtilitaires;
begin
  MyFiltreClassiqueUPP := NewModalFilterUPP(@MyFiltreClassique);
  SetReveillerRegulierementLeMac(false);
  
  gJoueursComplementes := MakeEmptyStringSet();
  gTournoisComplementes := MakeEmptyStringSet();
end;


procedure LibereMemoireUnitUtilitaires;
begin
  MyDisposeModalFilterUPP(MyFiltreClassiqueUPP);
  
  DisposeStringSet(gJoueursComplementes);
  DisposeStringSet(gTournoisComplementes);
end;
 
end.
