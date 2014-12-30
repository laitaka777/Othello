UNIT UnitGestionDuTemps;


INTERFACE








USES UnitPositionEtTrait;


TYPE
		InvalidateMode = (kForceInvalidate, kNormal);
    booleanPtr = ^boolean;

VAR 
  gGongDejaSonneDansCettePartie : boolean;
  FntrCadenceRect : rect;

CONST 
  avecDelaiDeRetournementDesPions : boolean = true;
  kCassioGetsAll = 0;


{Initialisation de l'unite}
procedure InitUnitGestionDuTemps;
procedure LibereMemoireGestionDuTemps;


{ Temps alloue pour un coup, en fonction du temps restant a la pendule}
function TempsRestantPendule(couleur : SInt16) : SInt32;
function TempsPourCeCoup(n,couleur : SInt16) : SInt32;
function CalculeTempsAlloueEnFinale(CoulPourMeilleurFin : SInt16) : SInt32;
procedure TestDepassementTemps;
procedure EcritOopsMaPenduleDansRapport;
procedure DerniereHeure(couleur : SInt32);
procedure SetDateEnTickDuCoupNumero(numero,date : SInt32);
function GetDateEnTickDuCoupNumero(numero : SInt32) : SInt32;


{ Cadence de la partie}
procedure SetCadence(cadence : SInt32);
function GetCadence() : SInt32;
procedure AjusteCadenceMin(cadence : SInt32);
procedure Heure(couleur : SInt16);


{ Changements d'etats }
procedure InvalidateAnalyseDeFinale;
procedure InvalidateAnalyseDeFinaleSiNecessaire(mode:InvalidateMode);
procedure ActiverAttenteAnalyseDeFinale(whichPos : PositionEtTraitRec;bestMove,bestDef : SInt32;dessinee : boolean);
procedure SetSuggestionDeFinaleEstDessinee(flag : boolean);


{ Pour savoir si Cassio a terminé l'analyse de la position }
function AttenteAnalyseDeFinaleDansPositionCourante() : boolean;
function AttenteAnalyseDeFinaleEstActive() : boolean;
function SuggestionAnalyseDeFinaleEstDessinee() : boolean;
function GetBestMoveAttenteAnalyseDeFinale() : SInt32;


{ Un drapeau simple que Cassio levera quand il sera en train de calculer }
procedure SetCassioEstEnTrainDeReflechir(newvalue : boolean;oldValue:booleanPtr);
function CassioEstEnTrainDeReflechir() : boolean;
procedure SetReveillerRegulierementLeMac(flag : boolean);
function GetReveillerRegulierementLeMac() : boolean;


{ Temps donné au système d'exploitation }
procedure AjusteSleep;
function CassioVaJouerInstantanement() : boolean;
procedure DiminueLatenceEntreDeuxDoSystemTask;
procedure AccelereProchainDoSystemTask(nbTicksMax : SInt32);
procedure DoSystemTask(couleur : SInt32);
procedure PartagerLeTempsMachineAvecLesAutresProcess(WNESleep : SInt32);


{ Temporisations avant de jouer }
function DoitTemporiserPourRetournerLesPions() : boolean;
procedure SetDelaiDeRetournementDesPions(nouveauDelai : SInt32);
function GetDelaiDeRetournementDesPions() : SInt32;
procedure TemporisationSolitaire;
procedure TemporisationArnaqueFinale;
procedure TemporisationRetournementDesPions;


{ Gestion des interruptions }
procedure LanceInterruption(typeInterruption : SInt16; const fonctionAppelante : str255);
procedure EnleveCetteInterruption(typeInterruption : SInt16);
function GetCurrentInterruption() : SInt16; 
procedure EffectueTacheInterrompante(var interruptionEnCours : SInt16);


{ Cassio doit-il tester tous les evenements classiques ? }
procedure SetCassioChecksEvents(flag : boolean);
function GetCassioChecksEvents() : boolean;


{ Etalonnage de la vitesse du Mac }
function CalculVitesseMac(afficherDansRapport : boolean) : SInt32;
procedure EtalonnageVitesseMac(afficheDansRapport : boolean);


{ Dialogue du choix de la cadence pour la partie }
function FiltreCadenceDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
procedure DoCadence;




IMPLEMENTATION







USES UnitAffichageReflexion,UnitRapport,UnitOth1,UnitJeu,UnitEntreeTranscript,UnitSound,
     UnitLiveUndo,UnitDialog,UnitUtilitaires,MyStrings,UnitPhasesPartie,UnitOth2,UnitActions,
     UnitRetrograde,UnitSolitairesNouveauFormat,UnitMilieuDePartie,UnitPrefs,UnitListe,
     UnitJaponais,UnitRapportImplementation,SNStrings,UnitCouleur,UnitScripts,
     UnitProblemeDePriseDeCoin,UnitFenetres,UnitInterversions;


var 
  attenteAnalyseDeFinale : record
                             activee            : boolean;
                             suggestionDessinee : boolean;
                             position           : PositionEtTraitRec;
                             bestMove           : SInt32;
                             bestDefense        : SInt32;
                           end;

  gCassioEstEnTrainDeReflechir : boolean;
  gMouseRegionForWaitNextEvent : RgnHandle;
  
  gCadence : SInt32;
  gCadencesRadios : RadioRec;
  
  reveilRegulierDuMac:record
                          necessaire : boolean;
                          tickDerniereFois : SInt32;
                        end;

  delaiDeRetournementDesPions : SInt32;
  gDateDesCoups : array[0..60] of SInt32;
  
  
  
procedure InitUnitGestionDuTemps;
var myTinyRect : rect;
begin
  gMouseRegionForWaitNextEvent := NIL;
  
  gMouseRegionForWaitNextEvent := NewRgn();
  SetRect(myTinyRect, 10, 10, 20, 20);
	RectRgn (gMouseRegionForWaitNextEvent, myTinyRect);
end;


procedure LibereMemoireGestionDuTemps;
begin
  if gMouseRegionForWaitNextEvent <> NIL then
    begin
      DisposeRgn(gMouseRegionForWaitNextEvent);
      gMouseRegionForWaitNextEvent := NIL;
    end;
end;


procedure SetCadence(cadence : SInt32);
begin
  gCadence := cadence;
end;


function GetCadence() : SInt32;
begin
  GetCadence := gCadence;
end;


procedure AjusteCadenceMin(cadence : SInt32);
begin
  case cadence of
    minutes3        : cadenceMin := 3;
    minutes5        : cadenceMin := 5;
    minutes10       : cadenceMin := 10;
    minutes25       : cadenceMin := 25;
    minutes1440     : cadenceMin := 1440;
    minutes48000    : cadenceMin := 48000;
    minutes10000000 : cadenceMin := 10000000;
    otherwise         cadenceMin := cadence div 60;
  end;
end;

  
{temps alloue, en secondes}
function CalculeTempsAlloueEnFinale(CoulPourMeilleurFin : SInt16) : SInt32;
var allocationTemps : SInt32;
begin
  if analyseRetrograde.enCours
	  then allocationTemps := analyseRetrograde.demande[nbreCoup,analyseRetrograde.numeroPasse].tempsAlloueParCoup
	  else
	    if not(neJamaisTomber) 
	      then allocationTemps := 1000000000
	      else
	       if RefleSurTempsJoueur 
	         then allocationTemps := RoundToL(0.6*TempsRestantPendule(couleurMacintosh))
	         else allocationTemps := RoundToL(0.6*TempsRestantPendule(CoulPourMeilleurFin));
  CalculeTempsAlloueEnFinale := allocationTemps;
end;


{ renvoie (en secondes) le temps alloue pour le coup n }
function TempsPourCeCoup(n,couleur : SInt16) : SInt32;
var nbCoupRestant : SInt32;
    tempsEcoule : SInt32;
    aux : SInt32;
begin
  if analyseRetrograde.enCours & (n>=0) & (n<=60)
    then
      begin
        TempsPourCeCoup := analyseRetrograde.demande[n,analyseRetrograde.numeroPasse].tempsAlloueParCoup
      end
    else
      begin
        if GetCadence() = minutes10000000
          then TempsPourCeCoup := minutes10000000  {temps infini}
          else
            begin
			        tempsEcoule := tempsDesJoueurs[couleur].minimum*60+tempsDesJoueurs[couleur].sec;
						  nbCoupRestant := (55-n) div 2;
						  if nbCoupRestant <> 0
						    then aux := (GetCadence()-tempsEcoule) div nbCoupRestant
						    else aux := 10;
						  if aux<=0 then aux := 5;
						  TempsPourCeCoup := aux;
						end;
			end;
end;

{ renvoie (en secondes) le temps restant}
function TempsRestantPendule(couleur : SInt16) : SInt32;
var tempsEcoule : SInt32;
    aux : SInt32;
begin
  tempsEcoule := tempsDesJoueurs[couleur].minimum*60+tempsDesJoueurs[couleur].sec;
  aux := 60*cadenceMin-tempsEcoule;
  if aux<=0 then aux := 0;
  TempsRestantPendule := aux;
end;


procedure InvalidateAnalyseDeFinale;
begin
  attenteAnalyseDeFinale.activee            := false;
  attenteAnalyseDeFinale.position           := MakeEmptyPositionEtTrait();
  attenteAnalyseDeFinale.bestMove           := 0;
	attenteAnalyseDeFinale.bestDefense        := 0;
	SetSuggestionDeFinaleEstDessinee(false);
end;


procedure ActiverAttenteAnalyseDeFinale(whichPos : PositionEtTraitRec;bestMove,bestDef : SInt32;dessinee : boolean);
begin
  attenteAnalyseDeFinale.activee            := true;
  attenteAnalyseDeFinale.position           := whichPos;
  attenteAnalyseDeFinale.bestMove           := bestMove;
	attenteAnalyseDeFinale.bestDefense        := bestDef;
	SetSuggestionDeFinaleEstDessinee(dessinee);
end;


procedure SetSuggestionDeFinaleEstDessinee(flag : boolean);
begin
  attenteAnalyseDeFinale.suggestionDessinee := flag;
end;


procedure InvalidateAnalyseDeFinaleSiNecessaire(mode:InvalidateMode);
begin
  if attenteAnalyseDeFinale.activee | (mode = kForceInvalidate) then
    begin
      if (mode = kForceInvalidate) | HumCtreHum | (aQuiDeJouer<>couleurMacintosh) | 
         not(CassioEstEnModeAnalyse()) | not(AttenteAnalyseDeFinaleDansPositionCourante()) then
        begin
          InvalidateAnalyseDeFinale;
          ReinitilaliseInfosAffichageReflexion;
          EffaceReflexion;
        end;
    end;
end;


function AttenteAnalyseDeFinaleEstActive() : boolean;
begin
  AttenteAnalyseDeFinaleEstActive := attenteAnalyseDeFinale.activee;
end;


function SuggestionAnalyseDeFinaleEstDessinee() : boolean;
begin
  SuggestionAnalyseDeFinaleEstDessinee := attenteAnalyseDeFinale.suggestionDessinee;
end;


function AttenteAnalyseDeFinaleDansPositionCourante() : boolean;
begin
  AttenteAnalyseDeFinaleDansPositionCourante := 
      attenteAnalyseDeFinale.activee &
      SamePositionEtTrait(attenteAnalyseDeFinale.position,PositionEtTraitCourant());
end;


function GetBestMoveAttenteAnalyseDeFinale() : SInt32;
begin
  GetBestMoveAttenteAnalyseDeFinale := attenteAnalyseDeFinale.bestMove;
end;


procedure SetCassioEstEnTrainDeReflechir(newvalue : boolean;oldValue:booleanPtr);
begin
  if (oldValue <> NIL) then
    oldValue^ := gCassioEstEnTrainDeReflechir;
  gCassioEstEnTrainDeReflechir := newValue;
end;


function CassioEstEnTrainDeReflechir() : boolean;
begin
  CassioEstEnTrainDeReflechir := gCassioEstEnTrainDeReflechir;
end;


procedure SetCassioChecksEvents(flag : boolean);
begin
  gCassioChecksEvents := flag;
end;

function GetCassioChecksEvents() : boolean;
begin
  GetCassioChecksEvents := gCassioChecksEvents;
end;


function CalculVitesseMac(afficheDansRapport : boolean) : SInt32;
var tickDepart,lastTick,newTick : SInt32;
    compteur,resultat,nbToursCompteur : SInt32;
    a,b : SInt32;
begin
   (**    indice de vitesse      
          <10   : MacClassic     
          =13   : Powerbook 100
          =30   : IIci
          =51   : PowerBook 150
          =100  : Quadra         
          =2700 : PowerMac 6400 a 200 MgH
          =7700 : PowerMac 6400 a 200 MgH, avec carte Sonnet G3/L2 a 400 MgH
          
   Note : les variables a,b et le test  < Abs(a-b)<0) > 
          sont la pour etre des opérations realistes 
          typiques de Cassio. Si on les change, verifier
          que l'optimisateur du compilateur ne supprime *pas*
          ce code inutile **)

  compteur := 0;
  nbToursCompteur := 0;
  a := 0;
  b := 5000;
  lastTick := TickCount();
  tickDepart := lastTick;
  
  {attendre un nouveau tick}
  repeat until (TickCount() <> lastTick);
  
  {puis faire la boucle de test pendant 30 ticks (0.5 seconde)}
  repeat
    inc(compteur);
    {on essaie d'eviter les gags d'overflow sur compteur}
    if (compteur > 1000000) then 
      begin
        inc(nbToursCompteur);
        compteur := 0;
      end;
    (* code typique *)
    if (compteur>b) | ((BAND((compteur - 30) , 1023) <> 0))
       then a := 2*compteur;
       
    {autre code typique : gestion du temps }
    newTick := TickCount();
    if (newTick <> lastTick) then
      begin
        lastTick := newTick;
        if HasGotEvent(everyEvent,theEvent,0,NIL) then 
          begin
            TraiteOneEvenement;
            AccelereProchainDoSystemTask(1);
          end;
      end;
      
  until ((TickCount()-tickDepart) > 30) | (Abs(a-b) < 0);
  
  resultat := 1000*nbToursCompteur + ((compteur + 500) div 1000);
  
  if afficheDansRapport then
    begin
      WritelnDansRapport('CalculVitesseMac :');
      WritelnStringAndNumDansRapport('   compteur = ',compteur);
      WritelnStringAndNumDansRapport('   nbToursCompteur = ',nbToursCompteur);
      WritelnStringAndNumDansRapport('   resultat = ',resultat);
    end;
  
  CalculVitesseMac := resultat;
end;


{ Calcul du coup declanchement de la finale en fonction de la vitesse du Mac.
  Cette routine est basee sur une hypothese de divergence 3 pour les finales }
procedure EtalonnageVitesseMac(afficheDansRapport : boolean);
var vitesse : SInt32;
begin
  vitesse := indiceVitesseMac;
  
  finDePartieVitesseMac := 41;           {apres ce coup}
  finDePartieOptimaleVitesseMac := 43;   {apres ce coup}
  
  if vitesse>=13 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-2;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-2;
    end;
  if vitesse>=32 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=90 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=270 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=810 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=2430 then  {note : vitesse=2800 environ sur PowerMac 6400 @ 200MgH }
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=7290 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=21870 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=65610 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=196830 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=590490 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=1771470 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse>=5314410 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  
  if debuggage.general & windowPlateauOpen then
    begin
      SetPortByWindow(wPlateauPtr);
      WriteStringAndNumAt('EtalonnageVitesseMac :  indiceVitesseMac = ',vitesse,100,100);
      WriteStringAndNumAt('finale gagnante au coup ',finDePartieVitesseMac+1,100,120);
      WriteStringAndNumAt('finale parfaite au coup ',finDePartieOptimaleVitesseMac+1,100,132);
      WriteStringAt('tapez une touche, svp ',100,144);
      SysBeep(0);
      AttendFrappeClavier;
    end;
  
  if afficheDansRapport then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('EtalonnageVitesseMac  :');
      WritelnStringAndNumDansRapport('    indiceVitesseMac = ',vitesse);
      WritelnStringAndNumDansRapport('    finale gagnante au coup ',finDePartieVitesseMac+1);
      WritelnStringAndNumDansRapport('    finale parfaite au coup ',finDePartieOptimaleVitesseMac+1);
      WritelnDansRapport('');
    end;
end;


procedure TemporisationSolitaire;
var temporisation,nbCasesVidesRestantes : SInt32;
    hazard,tick : SInt32;
begin   
  nbCasesVidesRestantes := 60-nbreCoup;
  if nbCasesVidesRestantes>10 then temporisation := 250;
  if nbCasesVidesRestantes=10 then temporisation := 130;
  if nbCasesVidesRestantes=9 then temporisation := 65;
  if nbCasesVidesRestantes=8 then temporisation := 40;
  if nbCasesVidesRestantes=7 then temporisation := 20;
  if nbCasesVidesRestantes<7 then temporisation := 10;
  if nbCasesVidesRestantes<5 then temporisation := 2;
  hazard := temporisation div 2;
  if hazard>0 then
    temporisation := temporisation + (Abs(Random()) mod MyTrunc(1.4*hazard)) - (hazard div 3);   
  temporisation := MyTrunc((70.0*temporisation)/indiceVitesseMac);  
  if temporisation>240 then temporisation := 240;  {4 sec.}
  tick := TickCount();
  repeat
    MySystemTask;
    if EventAvail(everyEvent,theEvent) then;
  until TickCount()-tick>temporisation;
end;


procedure TemporisationArnaqueFinale;
var temporisation : SInt16; 
    tick : SInt32;
begin   
  temporisation := 22;
  tick := TickCount();
  repeat
    MySystemTask;
    if EventAvail(everyEvent,theEvent) then;
  until TickCount()-tick>temporisation;
end;


function DoitTemporiserPourRetournerLesPions() : boolean;
begin
  if (avecDelaiDeRetournementDesPions & 
     ((TickCount() - DateOfLastKeyDownEvent()) >= 60) & 
     not(RepetitionDeToucheEnCours()) &
     (aQuiDeJouer = couleurMacintosh) & 
     (GetCadence() < minutes5) & 
     not(HumCtreHum) & 
     jeuInstantane & 
     not(demo) & 
     not(Quitter))
   then DoitTemporiserPourRetournerLesPions := true
       else DoitTemporiserPourRetournerLesPions := false;
   
end;


procedure TemporisationRetournementDesPions;
var temporisation : SInt16; 
    tick : SInt32;
begin

  if not(DoitTemporiserPourRetournerLesPions())
    then exit(TemporisationRetournementDesPions);

  SetDelaiDeRetournementDesPions(7);
  temporisation := GetDelaiDeRetournementDesPions();
  if (temporisation > 0) then
    begin
      tick := TickCount();
      repeat
        MySystemTask;
        if EventAvail(everyEvent,theEvent) then;
      until TickCount()-tick>temporisation;
    end;
end;



procedure SetDelaiDeRetournementDesPions(nouveauDelai : SInt32);
begin
  delaiDeRetournementDesPions := nouveauDelai;
end;


function GetDelaiDeRetournementDesPions() : SInt32;
begin
  GetDelaiDeRetournementDesPions := delaiDeRetournementDesPions;
end;


procedure AjusteSleep;
var CassioReflechitIntensement : boolean;
begin
  if Quitter | humainVeutAnnuler | (interruptionReflexion <> pasdinterruption) | 
     gEnRechercheSolitaire | gEnEntreeSortieLongueSurLeDisque | RechercheDeProblemeDePriseDeCoinEnCours() | CassioEstEnTrainDeCalculerLaListe()
    then 
      kWNESleep := 0   { Cassio gets 100% CPU }
    else  
      begin
        CassioReflechitIntensement := CassioEstEnTrainDeReflechir();
        if LiveUndoEnCours()
          then
            begin
              if CassioReflechitIntensement
                then kWNESleep := 0
                else kWNESleep := 1
            end
          else
            begin
              if gameOver | enSetUp | enRetour | 
                 ((aQuiDeJouer <> couleurMacintosh) & sansReflexionSurTempsAdverse & not(CassioEstEnModeAnalyse()) & not(CassioReflechitIntensement)) |
                 (not(CassioReflechitIntensement) & AttenteAnalyseDeFinaleDansPositionCourante())
                then 
                  begin
                    kWNESleep := 15;
                  end
                else
                  if HumCtreHum | 
                     ((aQuiDeJouer <> couleurMacintosh) & (reponsePrete | (nbreCoup <= 0)) & not(CassioReflechitIntensement))
                    then kWNESleep := 15
                    else 
                      {if inBackGround
                         then kWNESleep := 2
                         else }kWNESleep := 0;  { Cassio gets 100% CPU }
            end; 
      end;
  {WritelnStringAndNumDansRapport('kWNESleep = ',kWNESleep);}
end;


function CassioVaJouerInstantanement() : boolean;
var choice,bestDef : SInt32;
begin
  if not(HumCtreHum) & not(CassioEstEnModeAnalyse()) &
     (aQuiDeJouer=couleurMacintosh) & not(demo) & not(Quitter) & not(gameOver) then
    begin
      if reponsePrete & (phaseDeLaPartie>=phaseFinale) & not(CassioEstEnModeSolitaire()) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car reponsePrete)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;
      
      if jeuInstantane & (phaseDeLaPartie<=phaseMilieu) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car jeuInstantane)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;
      
      if (nbreCoup>=45) & (phaseDeLaPartie>=phaseFinale) & (phaseDeLaPartie<phaseFinale) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car nbreCoup>=50)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;
      
      if (nbreCoup>=50) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car nbreCoup>=50)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;
      
      if (phaseDeLaPartie>=phaseFinale) & ConnaitSuiteParfaite(choice,bestDef,false) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car ConnaitSuiteParfaite)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;
      
      if vaDepasserTemps then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car vaDepasserTemps)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;
    end;
  
  {WritelnDansRapport('CassioVaJouerInstantanement := false');}
  CassioVaJouerInstantanement := false;
end;

procedure EnleveCetteInterruption(typeInterruption : SInt16);
begin
  if BAND(interruptionReflexion,typeInterruption) <> 0 then
    begin
      if debuggage.gestionDuTemps then
        begin
          WritelnDansRapport('');
          WriteDansRapport('EnleveCetteInterruption : type');
          EcritTypeInterruptionDansRapport(typeInterruption);
        end;
        
      interruptionReflexion := BXOR(interruptionReflexion,typeInterruption);
      if BAND(typeInterruption,interruptionDepassementTemps) <> 0
        then vaDepasserTemps := false;
        
    end;
end;


procedure LanceInterruption(typeInterruption : SInt16; const fonctionAppelante : str255);
begin

  interruptionReflexion := BOR(interruptionReflexion,typeInterruption);
  
  if BAND(typeInterruption,interruptionDepassementTemps) <> 0
    then vaDepasserTemps := true;
  
  if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('LanceInterruption (fonction appelante = ' + fonctionAppelante + ')');
      WriteDansRapport('   => type ');
      EcritTypeInterruptionDansRapport(typeInterruption);
    end;
end;


function GetCurrentInterruption() : SInt16; 
begin
  GetCurrentInterruption := interruptionReflexion;
end;


procedure DiminueLatenceEntreDeuxDoSystemTask;
begin
  latenceEntreDeuxDoSystemTask := 2;
end;

procedure AccelereProchainDoSystemTask(nbTicksMax : SInt32);
var avantProchaineSeconde : SInt32;
begin
  {avantProchaineSeconde := 60- ((TickCount() - dernierTick) + 1);}
  
  avantProchaineSeconde := ((TickCount() - dernierTick) + 1);
  
  if delaiAvantDoSystemTask > avantProchaineSeconde then delaiAvantDoSystemTask := avantProchaineSeconde;

   {delaiAvantDoSystemTask := 2;  est bien aussi, sauf pour l'analyse retrograde}
  
  if (delaiAvantDoSystemTask > nbTicksMax) then delaiAvantDoSystemTask := nbTicksMax;
end;

procedure Heure(couleur : SInt16);
var aux,seco : SInt32;
    s,s1,s2 : string;
    oldPort : grafPtr;
    heuresAffichees : boolean;
    ligneRect : rect;
    
  procedure TraduitMinEnFormat_hhmm(nbmin : SInt32; var chaine : string);
  var nbheures : SInt32;
      s2 : string;
  begin
    if (nbmin>=60) & not((GetCadence() = minutes10000000) & decrementetemps)
      then
        begin
          heuresAffichees := true;
          nbheures := nbmin div 60;
          NumToString(nbheures,s2);
          nbmin := nbmin mod 60;
          NumToString(nbmin,chaine);
          if nbmin<10 then chaine := StringOf('0')+chaine;
          chaine := s2+': '+chaine;
        end
      else
        begin
          heuresAffichees := false;
          NumToString(nbmin,chaine);
        end;
  end;

begin
  if windowPlateauOpen then
    begin
      aux := TickCount()-dernierTick;
      dernierTick := TickCount()-(aux mod 60);
      AccelereProchainDoSystemTask(60);
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr); 
      with tempsDesJoueurs[couleur] do
        begin
          if aux<200 then
            begin
              seco := sec+ (aux div 60);
              sec := seco mod 60;
              minimum := minimum+ (seco div 60);
              tempsReflexionMac := tempsReflexionMac+60;
              tempsReflexionCetteProf := tempsReflexionCetteProf+60;
            end;
          if sec<0 then 
             repeat
               minimum := minimum-1;
               sec := sec+60;
             until (sec>=0);
          if decrementetemps then
          begin
            if cadenceMin-1-minimum<0 then
              begin
                TraduitMinEnFormat_hhmm(minimum-cadenceMin,s1);
                NumToString(sec,S2);
                if sec<10 then s2 := StringOf('0')+s2;
                s := StringOf('-')+s1+': '+s2; 
              end
              else
              if sec=0 
                then 
                  begin
                    TraduitMinEnFormat_hhmm(cadenceMin-minimum,s1);
                    s := s1+': 00'
                  end
                else 
                  begin   
                    TraduitMinEnFormat_hhmm(cadenceMin-minimum-1,s1);
                    NumToString(60-sec,s2);
                    if 60-sec<10 then s2 := StringOf('0')+s2;
                    s := s1+': '+s2; 
                  end;
            end
          else  {if decrementetemps then...}
            begin
              TraduitMinEnFormat_hhmm(minimum,s1);
              NumToString(sec,S2);
              if sec<10 then s2 := StringOf('0')+s2;
              s := s1+': '+s2; 
            end;
        end;
        
      if not(EnModeEntreeTranscript()) then
        begin
          PrepareTexteStatePourHeure;
          case couleur of
              pionBlanc : 
                begin
                  if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
                    then SetRect(lignerect,posHblancs,posVblancs+1,posHblancs+67,posVblancs+10)
                    else SetRect(lignerect,posHblancs,posVblancs+1,posHblancs+67,posVblancs+12);
                  EraseRectDansWindowPlateau(lignerect);
                  if (GetCadence() <> minutes10000000) & not(heuresAffichees) then 
                    OffsetRect(lignerect,5,0);
                  Moveto(lignerect.left,lignerect.bottom);
                  if (GetCadence() = minutes10000000) & decrementetemps 
                    then 
                      begin
                        TextFace(normal);
                        DrawString(s);
                        if NePasUtiliserLeGrasFenetreOthellier
    							        then TextFace(normal)
    							        else TextFace(bold);
                      end
                    else
                      DrawString(s);
                end;
              pionNoir  : 
                begin
                  if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
                    then SetRect(lignerect,posHNoirs,posVNoirs+1,posHNoirs+67,posVNoirs+10)
                    else SetRect(lignerect,posHNoirs,posVNoirs+1,posHNoirs+67,posVNoirs+12);
                  EraseRectDansWindowPlateau(lignerect);
                  if (GetCadence() <> minutes10000000) & not(heuresAffichees) then 
                    OffsetRect(lignerect,5,0);
                  Moveto(lignerect.left,lignerect.bottom);
                  if (GetCadence() = minutes10000000) & decrementetemps 
                    then 
                      begin
                        TextFace(normal);
                        DrawString(s);
                        if NePasUtiliserLeGrasFenetreOthellier
                          then TextFace(normal)
                          else TextFace(bold);
                      end
                    else
                      DrawString(s);
                end;
          end; {case...}
          
          if gCassioUseQuartzAntialiasing then
            if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
        end;
        
      with tempsDesJoueurs[couleur] do
        if sec=0 then
          if cadenceMin-minimum=0 then
            if not(HumCtreHum) & (couleur = -couleurMacintosh) & avecSon then
              if not(analyseRetrograde.enCours | demo | gGongDejaSonneDansCettePartie) then
              begin
                PlaySoundSynchrone(kSonGongID);             
                dernierTick := TickCount();
                gGongDejaSonneDansCettePartie := true;
              end;  
	      
      SetPort(oldPort);
    end;
end;



function FiltreCadenceDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
const     
    BoutonDebutant=4;
    BoutonAmateur=5;
    BoutonClub=6;
    BoutonFort=7;
    BoutonExpert=8;
    BoutonGrandMaitre=9;
    BoutonChampion=10;
    Bouton3minutes=11;
    Bouton5minutes=12;
    Bouton10minutes=13;
    Bouton25minutes=14;
    BoutonUnMois=15;
    BoutonInfini=16;
    BoutonAutre=17;
    TextHeures=18;
    StaticHeures=19;
    TextMinutes=20;
begin
  FiltreCadenceDialog := false;
  if not(EvenementDuDialogue(dlog,evt))
    then FiltreCadenceDialog := MyFiltreClassique(dlog,evt,item)
    else
      case evt.what of
        keyDown,autoKey :
         begin
          if (BAND(evt.message,charcodemask)=FlecheHautKey) then  {fleche en haut}
            begin
              case gCadencesRadios.selection of 
                 BoutonDebutant    : item := BoutonDebutant;
                 BoutonAmateur     : item := BoutonDebutant;
                 BoutonClub        : item := BoutonAmateur;
                 BoutonFort        : item := BoutonClub;
                 BoutonExpert      : item := BoutonFort;
                 BoutonGrandMaitre : item := BoutonExpert;
                 BoutonChampion    : item := BoutonGrandMaitre;
                 Bouton3minutes    : item := BoutonChampion;
                 Bouton5minutes    : item := Bouton3minutes;
                 Bouton10minutes   : item := Bouton5minutes;
                 Bouton25minutes   : item := Bouton10minutes;
                 BoutonUnMois      : item := Bouton25minutes
                 BoutonInfini      : item := BoutonUnMois;
                 BoutonAutre       : item := BoutonInfini;
              end;      
              FiltreCadenceDialog := true;
            end 
            else 
            if (BAND(evt.message,charcodemask)=FlecheBasKey) then  {fleche en bas}
              begin
                case gCadencesRadios.selection of 
                   BoutonDebutant    : item := BoutonAmateur;
                   BoutonAmateur     : item := BoutonClub;
                   BoutonClub        : item := BoutonFort;
                   BoutonFort        : item := BoutonExpert;
                   BoutonExpert      : item := BoutonGrandMaitre;
                   BoutonGrandMaitre : item := BoutonChampion;
                   BoutonChampion    : item := Bouton3minutes;
                   Bouton3minutes    : item := Bouton5minutes;
                   Bouton5minutes    : item := Bouton10minutes;
                   Bouton10minutes   : item := Bouton25minutes;
                   Bouton25minutes   : item := BoutonUnMois;
                   BoutonUnMois      : item := BoutonInfini;
                   BoutonInfini      : item := BoutonAutre;
                   BoutonAutre       : item := BoutonAutre;
                end;     
                FiltreCadenceDialog := true;
              end
              else FiltreCadenceDialog := MyFiltreClassique(dlog,evt,item);
             end
          otherwise FiltreCadenceDialog := MyFiltreClassique(dlog,evt,item)
     end;   {case}
end;


procedure DoCadence;
  const 
    OK=1;
    Annuler=2;
    BoutonDebutant=4;
    BoutonAmateur=5;
    BoutonClub=6;
    BoutonFort=7;
    BoutonExpert=8;
    BoutonGrandMaitre=9;
    BoutonChampion=10;
    Bouton3minutes=11;
    Bouton5minutes=12;
    Bouton10minutes=13;
    Bouton25minutes=14;
    BoutonUnMois=15;
    BoutonInfini=16;
    BoutonAutre=17;
    TextHeures=18;
    StaticHeures=19;
    TextMinutes=20;
    StaticMinutes=21;
    CompteAReboursBox=22;
    NeJamaisTomberBox=23;
  var dp : DialogPtr;
      itemHit : SInt16; 
      FiltreCadenceDialogUPP : ModalFilterUPP;
      err : OSErr;
      SelectionInitiale:record
                          BoutonRadioCadence : SInt16; 
                          CompteRebours : boolean;
                          JamaisTomberAuTemps : boolean;
                        end;
      s,s1 : str255;
      i : SInt16; 
      unlong : SInt32;
  
  
  procedure ChangeCadence(Radios : RadioRec);
    var aux : SInt32;
    begin
      GetItemTextInDialog(dp,TextHeures,s);
      StringToNum(s,aux);
      cadencePersoAffichee := 3600*aux;
      GetItemTextInDialog(dp,TextMinutes,s);
      StringToNum(s,aux);
      cadencePersoAffichee := cadencePersoAffichee+60*aux;
      case Radios.selection of 
         BoutonDebutant    : SetCadence(minutes3);
         BoutonAmateur     : SetCadence(minutes3);
         BoutonClub        : SetCadence(minutes3);
         BoutonFort        : SetCadence(minutes3);
         BoutonExpert      : SetCadence(minutes3);
         BoutonGrandMaitre : SetCadence(minutes3);
         BoutonChampion    : SetCadence(minutes3);
         Bouton3minutes    : SetCadence(minutes3);
         Bouton5minutes    : SetCadence(minutes5);
         Bouton10minutes   : SetCadence(minutes10);
         Bouton25minutes   : SetCadence(minutes25);
         BoutonUnMois      : SetCadence(minutes48000);
         BoutonInfini      : SetCadence(minutes10000000);  
         BoutonAutre       : SetCadence(cadencePersoAffichee);
       end;
    end;
      
  
  begin
    with gCadencesRadios do
      begin
        firstButton := BoutonDebutant;
        lastButton := BoutonAutre;
        if jeuInstantane 
          then 
            case NiveauJeuInstantane of
              NiveauDebutants    : selection := BoutonDebutant;
              NiveauAmateurs     : selection := BoutonAmateur;
              NiveauClubs        : selection := BoutonClub;
              NiveauForts        : selection := BoutonFort;
              NiveauExperts      : selection := BoutonExpert;
              NiveauGrandMaitres : selection := BoutonGrandMaitre;
              NiveauChampions    : selection := BoutonChampion;
            end
          else
            case GetCadence() of
              minutes3          : selection := Bouton3minutes;
              minutes5          : selection := Bouton5minutes;
              minutes10         : selection := Bouton10minutes;
              minutes25         : selection := Bouton25minutes;
              minutes48000      : selection := BoutonUnMois;
              minutes10000000   : selection := BoutonInfini;  
              otherWise           selection := BoutonAutre;
            end;
      end;
    SelectionInitiale.BoutonRadioCadence  := gCadencesRadios.selection;
    SelectionInitiale.CompteRebours       := decrementetemps;
    SelectionInitiale.JamaisTomberAuTemps := neJamaisTomber;
    
    BeginDialog;
    FiltreCadenceDialogUPP := NewModalFilterUPP(@FiltreCadenceDialog);
    dp := MyGetNewDialog(CadenceDialogID,FenetreFictiveAvantPlan());
    if dp <> NIL then
    begin
      NumToString((cadencePersoAffichee+31) div 3600,s);
      SetItemTextInDialog(dp,TextHeures,s);
      NumToString(((cadencePersoAffichee+31) mod 3600) div 60,s);
      SetItemTextInDialog(dp,TextMinutes,s);                        
      InitRadios(dp,gCadencesRadios);
      ChangeCadence(gCadencesRadios);
      SetBoolCheckBox(dp,NeJamaisTomberBox,SelectionInitiale.JamaisTomberAuTemps);
      SetBoolCheckBox(dp,CompteAReboursBox,SelectionInitiale.CompteRebours);
      
      
      if (FntrCadenceRect.right - FntrCadenceRect.left > 0) then MoveWindow(GetDialogWindow(dp),FntrCadenceRect.left,FntrCadenceRect.top,false);
      ShowWindow(GetDialogWindow(dp));
      MyDrawDialog(dp);
      OutlineOK(dp);
      
      err := SetDialogTracksCursor(dp,true);
      
      repeat
        ModalDialog(FiltreCadenceDialogUPP,itemHit);
        if (itemHit<>OK) & (itemHit<>Annuler) then
          begin
          
            if (itemHit >= gCadencesRadios.firstButton) & (itemHit <= gCadencesRadios.lastButton) 
             then PushRadio(dp,gCadencesRadios,itemHit);
            
            if (itemHit>=BoutonAutre) & (itemHit<=StaticMinutes) then
              begin
                PushRadio(dp,gCadencesRadios,BoutonAutre);
                if (itemHit=TextHeures) | (itemHit=TextMinutes) then
                  begin
                    GetItemTextInDialog(dp,itemHit,s);
                    s1 := '';
                    for i := 1 to Length(s) do
                      if (s[i]>='0') & (s[i]<='9') then s1 := s1+s[i];
                    if Length(s1)>0 then
                      begin
                        StringToNum(s1,unlong);
                        NumToString(unlong,s1);
                        if (unlong=0) & (Length(s1)=0) then s1 := '';
                      end;
                    if Length(s1)>4 then s1 := TPCopy(s1,1,4);
                    if itemHit=TextMinutes then
                      begin
                        StringToNum(s1,unlong);
                        if unlong>59 then
                          begin
                            SysBeep(0);
                            s1 := '';
                          end;
                      end;
                    if s1<>s then SetItemTextInDialog(dp,itemHit,s1);
                  end;
              end;
              
            if itemHit=CompteAReboursBox then
              ToggleCheckBox(dp,CompteAReboursBox);
            
            if itemHit=NeJamaisTomberBox then
              ToggleCheckBox(dp,NeJamaisTomberBox);
              
          end;
      until (itemHit=OK) | (itemHit=Annuler);
      
      if itemHit=Annuler 
        then 
          begin
            PushRadio(dp,gCadencesRadios,SelectionInitiale.BoutonRadioCadence);
            SetBoolCheckBox(dp,NeJamaisTomberBox,SelectionInitiale.JamaisTomberAuTemps);
            SetBoolCheckBox(dp,CompteAReboursBox,SelectionInitiale.CompteRebours);
          end
        else 
          begin
            ChangeCadence(gCadencesRadios);
            if GetCadence() < minutes3 then 
              begin
                SysBeep(0);
                SetCadence(3*60);
                cadencePersoAffichee := GetCadence();
              end;
          end;
      decrementetemps := IsCheckBoxOn(dp,CompteAReboursBox);
      neJamaisTomber := IsCheckBoxOn(dp,NeJamaisTomberBox);
      
      FntrCadenceRect := GetWindowPortRect(GetDialogWindow(dp));
      LocalToGlobalRect(FntrCadenceRect);
      
      MyDisposeDialog(dp);
      
      AjusteCadenceMin(GetCadence());
      jeuInstantane := (gCadencesRadios.selection >= BoutonDebutant) &
                       (gCadencesRadios.selection <= BoutonChampion);
      if jeuInstantane then 
        case gCadencesRadios.selection of
          BoutonDebutant     : NiveauJeuInstantane := NiveauDebutants;
          BoutonAmateur      : NiveauJeuInstantane := NiveauAmateurs;
          BoutonClub         : NiveauJeuInstantane := NiveauClubs;
          BoutonFort         : NiveauJeuInstantane := NiveauForts;
          BoutonExpert       : NiveauJeuInstantane := NiveauExperts;
          BoutonGrandMaitre  : NiveauJeuInstantane := NiveauGrandMaitres;
          BoutonChampion     : NiveauJeuInstantane := NiveauChampions;
        end;
      dernierTick := TickCount();
      Heure(pionNoir);
      Heure(pionBlanc);  
      if (gCadencesRadios.selection<>SelectionInitiale.BoutonRadioCadence) then
        begin
          DetermineMomentFinDePartie;
          tempsAlloue := TempsPourCeCoup(nbreCoup,couleurMacintosh);
          humanWinningStreak  := 0;
          humanScoreLastLevel := 0;
          
          
          {si Cassio reflechissait sur son temps, peut-etre faut-il l'accélérer}
          if not(HumCtreHum) & (aQuiDeJouer = couleurMacintosh) then
            begin
              if (phaseDeLaPartie <= phaseMilieu) & (((tempsPrevu div 60)>tempsAlloue) | jeuInstantane) then
                if PeutArreterAnalyseRetrograde() then 
                  DoForcerMacAJouerMaintenant;
            end;
            
          {si Cassio reflechissait sur le temps adverse et que l'on passe en analyse, on l'arrete}
          if not(HumCtreHum) & (aQuiDeJouer <> couleurMacintosh) & 
             (gCadencesRadios.selection = BoutonInfini) then
            begin
              if PeutArreterAnalyseRetrograde() then 
                LanceInterruption(InterruptionSimple,'DoCadence');
            end;
                
          EcritPromptFenetreReflexion;
        end;
      if not(enSetUp) then
        if HasGotEvent(updateMask,theEvent,0,NIL) then 
          TraiteOneEvenement;
    end;
    MyDisposeModalFilterUPP(FiltreCadenceDialogUPP);
    EndDialog;
 end;



procedure EffectueTacheInterrompante(var interruptionEnCours : SInt16);
var compteurBoucle : SInt16; 
begin
  compteurBoucle := 0;
  repeat
    {$IFC NOT GENERATINGPOWERPC}
      UnLoadTousSegments;
    {$ENDC}
    
    {EcritTypeInterruptionDansRapport(interruptionEnCours);}
    
    if BAND(interruptionEnCours,interruptionSimple) <> 0 then
      begin
        interruptionEnCours := BXOR(interruptionEnCours , interruptionSimple);
        TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'EffectueTacheInterrompante(interruptionSimple)');
      end;
    if BAND(interruptionEnCours,kHumainVeutChangerCouleur) <> 0 then
      begin
        interruptionEnCours := BXOR(interruptionEnCours , kHumainVeutChangerCouleur);
        DoChangeCouleur;
      end;
    if BAND(interruptionEnCours,kHumainVeutChargerBase) <> 0 then                               
      begin
        interruptionEnCours := BXOR(interruptionEnCours , kHumainVeutChargerBase);
        DoTraiteBaseDeDonnee;
      end;
    if BAND(interruptionEnCours,kHumainVeutAnalyserFinale) <> 0 then                      
      begin
        interruptionEnCours := BXOR(interruptionEnCours , kHumainVeutAnalyserFinale);
        DoAnalyseRetrograde(0);
      end;
    if BAND(interruptionEnCours,kHumainVeutJouerSolitaires) <> 0 then                               
      begin
        interruptionEnCours := BXOR(interruptionEnCours , kHumainVeutJouerSolitaires);
        {DoJoueAuxSolitaires;}
        DoJoueAuxSolitairesNouveauFormat(2,64);
      end;
    if BAND(interruptionEnCours,kHumainVeutChangerHumCtreHum) <> 0 then                                
      begin
        interruptionEnCours := BXOR(interruptionEnCours , kHumainVeutChangerHumCtreHum);
        DoChangeHumCtreHum;
      end;
    if BAND(interruptionEnCours,kHumainVeutChangerCoulEtHumCtreHum) <> 0 then                                 
      begin
        interruptionEnCours := BXOR(interruptionEnCours , kHumainVeutChangerCoulEtHumCtreHum);
        DoChangeHumCtreHum;
        DoChangeCouleur;
      end;
    if BAND(interruptionEnCours,interruptionDepassementTemps) <> 0 then                                 
      begin
        interruptionEnCours := BXOR(interruptionEnCours , interruptionDepassementTemps);
      end;
     inc(compteurBoucle);
   until (interruptionEnCours = pasdinterruption) | 
         (compteurBoucle > 15);  
         
   if (interruptionEnCours <> pasdinterruption) then
     begin
       SysBeep(0);
       WritelnStringAndNumDansRapport('interruption inconnue dans EffectueTacheInterrompante !!!!!!!!!!!!!!',interruptionEnCours);
       EcritTypeInterruptionDansRapport(interruptionEnCours);
       interruptionEnCours := pasdinterruption;
     end;
end;



procedure TestDepassementTemps;
begin
  if analyseRetrograde.enCours &
     ((((tickCount()-analyseRetrograde.tickDebutCeStageAnalyse) div 60) > analyseRetrograde.tempsMaximumCeStage) |
      (((tickCount()-analyseRetrograde.tickDebutCettePasseAnalyse) div 60) > analyseRetrograde.tempsMaximumCettePasse)) then
    begin
      if debuggage.gestionDuTemps then
        WritelnDansRapport('appel 1 a DoForcerMacAJouerMaintenant dans TestDepassementTemps');
      DoForcerMacAJouerMaintenant;
      exit(TestDepassementTemps);
    end;
      
  if (interruptionReflexion = pasdinterruption) then
  if not(HumCtreHum) & (aQuiDeJouer=couleurMacintosh) then
  if not(RefleSurTempsJoueur) then
  if not(ProfondeurMilieuEstImposee()) then
    begin
      if (phaseDeLaPartie >= phaseFinale)
	      then  
	        begin
	          if (neJamaisTomber | analyseRetrograde.enCours) & not(ScriptDeFinaleEnCours()) then
  	          if (tempsReflexionMac div 60) >= (tempsAlloue-1) then
  	            begin
  	            	if debuggage.gestionDuTemps then
  	                WritelnDansRapport('appel 2 a DoForcerMacAJouerMaintenant dans TestDepassementTemps');
  	              DoForcerMacAJouerMaintenant;
  	              if not(analyseRetrograde.enCours) then 
  	                EcritOopsMaPenduleDansRapport;
  	              exit(TestDepassementTemps);
  	            end;
	        end
	      else   
	        begin
	          if ((tempsReflexionMac div 65) > tempsAlloue) &
	              (tempsAlloue < kUnMoisDeTemps) & not(ScriptDeFinaleEnCours()) then
	            begin
	            	if debuggage.gestionDuTemps then
	                WritelnDansRapport('appel 3 a DoForcerMacAJouerMaintenant dans TestDepassementTemps');
	              DoForcerMacAJouerMaintenant;
	              exit(TestDepassementTemps);
	            end;
	        end;
	  end;
end;

procedure DerniereHeure(couleur : SInt32);
var aux : SInt32;
begin
   aux := TickCount()-derniertick;
   {DoSystemTask(couleur);}
   tempsDesJoueurs[couleur].tick := aux mod 60;
   derniertick := TickCount()-(aux mod 60);  
   if not(enSetUp) then
    if HasGotEvent(updateMask,theEvent,0,NIL) 
      then TraiteEvenements;
end;


procedure SetDateEnTickDuCoupNumero(numero,date : SInt32);
begin
  if (numero >= 0) & (numero <= 60) then
    gDateDesCoups[numero] := date;
end;


function GetDateEnTickDuCoupNumero(numero : SInt32) : SInt32;
begin
  if (numero >= 0) & (numero <= 60) then
    GetDateEnTickDuCoupNumero := gDateDesCoups[numero];
end;

procedure SetReveillerRegulierementLeMac(flag : boolean);
begin
  reveilRegulierDuMac.necessaire := flag;
  reveilRegulierDuMac.tickDerniereFois := TickCount();
end;

function GetReveillerRegulierementLeMac() : boolean;
begin
  GetReveillerRegulierementLeMac := reveilRegulierDuMac.necessaire;
end;

procedure DoReveilDuMac;
var erreurES : OSErr;
    bidString : str255;
begin
  erreurES := OpenPrefsFileForSequentialReading();
  if erreurES = NoErr then erreurES := GetNextLineInPrefsFile(bidString);
  if erreurES = NoErr then erreurES := ClosePrefsFile();
  reveilRegulierDuMac.tickDerniereFois := TickCount();
end;

procedure DoSystemTask(couleur : SInt32);
var gotEvent : boolean;
begin
  
  GererLiveUndo;
  
  FaireClignoterFenetreArbreDeJeu;
  
  
  {gotEvent := HasGotEvent(EveryEvent,theEvent,kWNESleep,gMouseRegionForWaitNextEvent);}
  gotEvent := HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL);
  
  
  if gotEvent
    then 
      begin
        TraiteEvenements;
      end
    else 
      begin
        TraiteNullEvent(theEvent);
        AjusteCurseur;
      end;
     
  with reveilRegulierDuMac do
    if necessaire & ((TickCount()-tickDerniereFois) >= 3600) {plus d'une minute ?}
      then DoReveilDuMac;
  if (nbreCoup>=1) & ((TickCount()-dernierTick)>=60) 
    then 
	    begin
	      latenceEntreDeuxDoSystemTask := latenceEntreDeuxDoSystemTask + 1;
	      if latenceEntreDeuxDoSystemTask > 30 then latenceEntreDeuxDoSystemTask := 30;
	      Heure(couleur);
	      
	      if phaseDeLaPartie>=phaseFinale then
	        while (nbreNoeudsGeneresFinale > 1000000000) do
	          begin
	            nbreNoeudsGeneresFinale := nbreNoeudsGeneresFinale - 1000000000;
	            inc(nbreToursNoeudsGeneresFinale);
	          end;
    
	      while (nbreNoeudsGeneresMilieu > 1000000000) do
          begin
            nbreNoeudsGeneresMilieu := nbreNoeudsGeneresMilieu - 1000000000;
            inc(nbreToursNoeudsGeneresMilieu);
          end;
	      
	      while (nbreFeuillesMilieu > 1000000000) do
          begin
            nbreFeuillesMilieu := nbreFeuillesMilieu - 1000000000;
            inc(nbreToursFeuillesMilieu);
          end;
	          
	      if afficheGestionTemps then AffichageNbreNoeuds;
	      TestDepassementTemps;
	    end
	  else
	    begin
	      if (nbreCoup <= 0) & (gEnRechercheSolitaire | gEnEntreeSortieLongueSurLeDisque)
	        then dernierTick := TickCount();
	    end;
  
  with affichageReflexion do
    if doitAfficher & demandeEnSuspend & 
       ((Tickcount() - tickDernierAffichageReflexion) >= 25) {toutes les demi secondes environ}
       then EcritReflexion;
  
  delaiAvantDoSystemTask := delaiAvantDoSystemTask + latenceEntreDeuxDoSystemTask;
  if delaiAvantDoSystemTask > 60 
    then delaiAvantDoSystemTask := 60;
  
  GererLiveUndo;
    
  if (DemandeCalculsPourBase.EtatDesCalculs=kCalculsDemandes) & not(CassioVaJouerInstantanement())
    then TraiteDemandeCalculsPourBase('DoSystemTask');
  
end;


procedure PartagerLeTempsMachineAvecLesAutresProcess(WNESleep : SInt32);
begin
  kWNESleep := WNESleep;
end;



procedure EcritOopsMaPenduleDansRapport;
var oldScript : SInt32;
begin
  GetCurrentScript(oldScript);
  DisableKeyboardScriptSwitch;
  FinRapport;
  TextNormalDansRapport;
  ChangeFontColorDansRapport(RougeCmd);
  ChangeFontDansRapport(gCassioRapportBoldFont);
  ChangeFontSizeDansRapport(gCassioRapportBoldSize);
  ChangeFontFaceDansRapport(bold);
  WritelnDansRapport(ReadStringFromRessource(TextesRapportID,6));  {' oops !!! ma pendule'}
  TextNormalDansRapport;
  EnableKeyboardScriptSwitch;
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
end;


END.











































