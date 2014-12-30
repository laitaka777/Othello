UNIT UnitLiveUndo;



INTERFACE








USES UnitSquareSet;


{ Initialisation et destruction de l'unité }
procedure InitUnitLiveUndo;
procedure LibereMemoireUnitLiveUndo;


{ Fonctions d'acces }
function LiveUndoEnCours() : boolean;


{ Fonction de gestion du live undo }
procedure BeginLiveUndo(coupsProteges : SquareSet;nbreDeTicksDeDelai : SInt32);
procedure GererLiveUndo;
procedure EndLiveUndo;




IMPLEMENTATION








USES UnitDialog,UnitRapport,UnitOth0,UnitOth1,UnitOth2,UnitJeu,UnitActions,UnitPositionEtTrait,
     UnitGameTree,UnitArbreDeJeuCourant,UnitGestionDuTemps,UnitFenetres;


var gLiveUndoData : record
                      enCours                         : boolean;
                      tickDuClic                      : SInt32;
                      delai                           : SInt32;
                      numeroClicCommencement          : SInt32;
                      numeroDuCoupAuCommencement      : SInt32;
                      caseSousLaSourisAuCommencement  : SInt32;
                      nbreNiveauxRecursion            : SInt32;
                      dernierTickVerificationLiveUndo : SInt32;
                      HumCtreHumEntreeLiveUndo        : boolean;
                      coupsAGarderDansLiveUndo        : SquareSet;
                      positionUnCoupAvantLeClic       : PositionEtTraitRec;
                      changementTemporaireDeHumCtreHum: boolean;
                    end;


procedure InitUnitLiveUndo;
begin
  with gLiveUndoData do
    begin
      enCours := false;
      numeroClicCommencement     := -1000;
      numeroDuCoupAuCommencement := -1000;
      nbreNiveauxRecursion       := 0;
    end;
end;


procedure LibereMemoireUnitLiveUndo;
begin
  with gLiveUndoData do
    begin
      enCours := false;
      numeroClicCommencement     := -1000;
      numeroDuCoupAuCommencement := -1000;
    end;
end;


function LiveUndoEnCours() : boolean;
begin
  with gLiveUndoData do
    LiveUndoEnCours := enCours;
end;


function SourisEstSurLePlateauDansLiveUndo(var whichSquare : SInt16) : boolean;
var mouseLoc : Point;
    oldPort : grafPtr;
begin
  GetPort(oldPort);
  EssaieSetPortWindowPlateau;
  GetMouse(mouseLoc);
  SourisEstSurLePlateauDansLiveUndo := PtInPlateau(mouseLoc,whichSquare);
  SetPort(oldPort);
end;


procedure SwitchHumainContreHumainDansLiveUndo;
begin
  DoDemandeChangerHumCtreHum;
  EffectueTacheInterrompante(interruptionReflexion);
  LanceInterruption(interruptionSimple,'SwitchHumainContreHumainDansLiveUndo');
  gLiveUndoData.changementTemporaireDeHumCtreHum := not(gLiveUndoData.changementTemporaireDeHumCtreHum);
end;


procedure EssayerJouerNouveauCoupDansLiveUndo(caseDeLaSouris : SInt16);
begin
  with gLiveUndoData do
    if enCours & (numeroClicCommencement = GetCompteurDeMouseEvents()) & 
       StillDown() & (nbreCoup = numeroDuCoupAuCommencement-1) & not(analyseRetrograde.enCours) &
       (caseDeLaSouris >= 11) & (caseDeLaSouris <= 88) & possibleMove[caseDeLaSouris] &
       EstPositionEtTraitCourant(positionUnCoupAvantLeClic) &
       (TickCount() > tickDuClic + delai) &
       (interruptionReflexion = pasdinterruption)
       then 
         begin
           { on joue le coup sous la souris }
           TraiteCoupImprevu(caseDeLaSouris);
           
           { on repasse eventuellement en mode Cassio contre Humain }
           if changementTemporaireDeHumCtreHum & (HumCtreHum <> HumCtreHumEntreeLiveUndo) & (aQuiDeJouer <> couleurMacintosh) 
             then SwitchHumainContreHumainDansLiveUndo;
           
           AccelereProchainDoSystemTask(2);
         end;
end;


procedure EssayerAnnulerCoupDansLiveUndo(caseDeLaSouris : SInt16);
var currentNodeEstUneFeuilleDeLArbre : boolean;
    tempoAfficheNumeroCoup : boolean;
    positionUnCoupAvant : PositionEtTraitRec;
    positionResultante : PositionEtTraitRec;
    devraRejouerSurLaNouvelleCase : boolean;
begin
  with gLiveUndoData do
    if enCours & (numeroClicCommencement = GetCompteurDeMouseEvents()) & 
       StillDown() & (nbreCoup = numeroDuCoupAuCommencement) & not(analyseRetrograde.enCours) &
       (caseDeLaSouris >= 11) & (caseDeLaSouris <= 88) & (caseDeLaSouris <> DerniereCaseJouee()) &
       GetPositionEtTraitACeNoeud(GetFather(GetCurrentNode()),positionUnCoupAvant) &
       SamePositionEtTrait(positionUnCoupAvant,positionUnCoupAvantLeClic) &
       (TickCount() > tickDuClic + delai) &
       (interruptionReflexion = pasdinterruption)
       then 
         begin
         
           currentNodeEstUneFeuilleDeLArbre := not(HasSons(GetCurrentNode()));
           
           {on essaie d'eviter le flickering sur le numéro du coup}
           tempoAfficheNumeroCoup := afficheNumeroCoup;
           if afficheNumeroCoup then DoChangeAfficheDernierCoup;
           
           
           devraRejouerSurLaNouvelleCase := PeutReculerUnCoupPuisJouerSurCetteCase(caseDeLaSouris,positionResultante);
           
           {on déjoue le dernier coup...}
           if currentNodeEstUneFeuilleDeLArbre & not(DerniereCaseJouee() in coupsAGarderDansLiveUndo)
             then DetruitSousArbreCourantEtBackMove
             else DoBackMove;
                 
           { on passe en Humain contre Humain pour eviter que Cassio ne rejoue immediatement }
           if not(HumCtreHum) & not(CassioEstEnModeAnalyse()) & (aQuiDeJouer = couleurMacintosh) & not(changementTemporaireDeHumCtreHum) 
             then SwitchHumainContreHumainDansLiveUndo;
                   
           { ...et on rejoue éventuellement le nouveau coup immédiatement}
           if devraRejouerSurLaNouvelleCase
             then EssayerJouerNouveauCoupDansLiveUndo(caseDeLaSouris);
           
           {on rétablit l'affichage du numéro du dernier coup}
           if tempoAfficheNumeroCoup & not(afficheNumeroCoup) then DoChangeAfficheDernierCoup;
           
           AccelereProchainDoSystemTask(2);
         end;
end;


procedure GererLiveUndo;
var whichSquare : SInt16; 
begin
  with gLiveUndoData do
    if enCours & 
      (nbreNiveauxRecursion <= 2) & (TickCount() <> dernierTickVerificationLiveUndo) &
      (numeroClicCommencement = GetCompteurDeMouseEvents()) & StillDown()
      then
        begin
          inc(nbreNiveauxRecursion);
          dernierTickVerificationLiveUndo := TickCount();
          
          if SourisEstSurLePlateauDansLiveUndo(whichSquare) then
            begin
              if (nbreCoup = numeroDuCoupAuCommencement)
                then EssayerAnnulerCoupDansLiveUndo(whichSquare)
                else EssayerJouerNouveauCoupDansLiveUndo(whichSquare);
            end;
            
          dec(nbreNiveauxRecursion);
        end;
end;


procedure BeginLiveUndo(coupsProteges : SquareSet;nbreDeTicksDeDelai : SInt32);
{var square : SInt16; }
begin
  if PeutReculerUnCoup() & not(analyseRetrograde.enCours) & StillDown() then
    begin
      {WritelnDansRapport('BeginLiveUndo');}
      with gLiveUndoData do
        begin
          tickDuClic                       := TickCount();
          enCours                          := true;
          delai                            := nbreDeTicksDeDelai;
          numeroClicCommencement           := GetCompteurDeMouseEvents();
          coupsAGarderDansLiveUndo         := coupsProteges;
          numeroDuCoupAuCommencement       := nbreCoup;
          caseSousLaSourisAuCommencement   := DerniereCaseJouee();
          HumCtreHumEntreeLiveUndo         := HumCtreHum;
          changementTemporaireDeHumCtreHum := false;
          
          {for square := 11 to 88 do
             if square in coupsAGarderDansLiveUndo then
               WritelnStringAndCoupDansRapport(' à garder : ',square);}
          
          if GetPositionEtTraitACeNoeud(GetFather(GetCurrentNode()),positionUnCoupAvantLeClic) 
            then     
              begin   { c'est parti ! }
                GererLiveUndo;  
              end
            else 
              begin   { y'a une erreur, on arrete tout }
                WritelnDansRapport('ERREUR dans BeginLiveUndo, prévenez Stéphane');
                EndLiveUndo;  
              end;
              
        end;
    end;
end;


procedure EndLiveUndo;
begin
  {WritelnDansRapport('EndLiveUndo');}
  with gLiveUndoData do
    if enCours then
      begin
        enCours := false;
        numeroClicCommencement := -1000;
        numeroDuCoupAuCommencement := -1000;
        if HumCtreHum <> HumCtreHumEntreeLiveUndo 
          then DoDemandeChangerHumCtreHum;
      end;
end;


END.






























