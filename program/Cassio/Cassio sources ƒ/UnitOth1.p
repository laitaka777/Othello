UNIT UnitOth1;



INTERFACE







USES MyTypes,UnitOth0,UnitSquareSet,UnitPositionEtTrait,UnitCalculCouleurCassio;
 

const BWPalettePictID=133;
      BWSablierDeboutPictID=134;
      BWSablierRenversePictID=135;
      BWSonPictID=136;
       
      CPalettePictID=138;
       
const kJusticationCentreVert     = 1;
      kJusticationBas            = 2;
      kJusticationHaut           = 4;
      kJusticationCentreHori     = 8;
      kJusticationGauche         = 16;
      kJusticationDroite         = 32;
      kJustificationInverseVideo = 64;

const kBordureDeDroite = 1;
      kBordureDeGauche = 2;
      kBordureDuHaut   = 4;
      kBordureDuBas    = 8;
      
var EssaieUpdateEventsWindowPlateauProc:ProcedureType;
    EssaieUpdateEventsWindowPlateauProcEstInitialise : boolean;
    othellierToutEntier : SquareSet;
    gHorlogeRect : rect;
    gHorlogeRectGlobal : rect;
    

procedure InitUnitOth1;
procedure InstalleEssaieUpdateEventsWindowPlateauProc(aRoutine:ProcedureType);
function DernierCoupEnString(enMajuscules : boolean) : string;
procedure WriteStringAndNumAt(s : str255;num : SInt32;h,v : SInt32);
procedure WriteStringAndNumEnSeparantLesMilliersAt(s : str255;num : SInt32;h,v : SInt32);
procedure WriteStringAndBigNumEnSeparantLesMilliersAt(s : str255;milliards,num : SInt32;h,v : SInt32);
procedure WriteStringAt(s : str255;h,v : SInt32);
procedure WriteStringAtWithoutErase(s : str255;h,v : SInt32);
procedure WriteReelAt(unreel : extended;h,v : SInt32);
procedure WriteStringAndReelAt(s : str255;unreel : extended;h,v : SInt32);
procedure WriteStringAndBoolAt(s : str255;bool : boolean;h,v : SInt32);

procedure FlashCasePalette(nroaction : SInt16);
procedure DessineCasePaletteCouleur(nroAction : SInt16; enfoncee : boolean);
procedure DessineIconesChangeantes;
procedure DessinePalette;
procedure DessineRubanDuCommentaireDansFenetreArbreDeJeu(forceModeEdition : boolean);
procedure DessineZoneDeTexteDansFenetreArbreDeJeu(forceModeEdition : boolean);
procedure CalculeEditionRectFenetreArbreDeJeu;
procedure ChangeDelimitationEditionRectFenetreArbreDeJeu(positionDelimitation : SInt16);
procedure ActiverModeEditionFenetreArbreDeJeu;
procedure DeactiverModeEditionFenetreArbreDeJeu;
procedure FaireClignoterFenetreArbreDeJeu;
procedure ClicDansTexteCommentaires(pt : Point;extend : boolean);
procedure ForconsLePlantageDeCassio;
function AuMoinsUneZoneDeTexteEnModeEntree() : boolean;
function CassioIsInBackground() : boolean;
function CassioEstEnModeSolitaire() : boolean;
function CassioEstEnModeAnalyse() : boolean;
procedure AjusteCurseur;
procedure BeginCurseurSpecial(whichCursor:CursHandle);
procedure EndCurseurSpecial;

function EpaisseurBordureOthellier() : SInt32;

procedure PrepareTexteStatePourTranscript;
procedure PrepareTexteStatePourHeure;
procedure PrepareTexteStatePourMeilleureSuite;
procedure PrepareTexteStatePourDemandeCoup;
procedure PrepareTexteStatePourCommentaireSolitaire;
procedure PrepareTexteStatePourSystemeCoordonnees;
procedure PrepareTexteStatePourCommentaireOuverture;
procedure PrepareTexteStatePourEcritCoupsBibl;
procedure SetPositionScore;
procedure SetPositionDemandeCoup(fonctionAppelante : str255);
procedure SetPositionMeilleureSuite;
procedure SetAffichageVertical;
procedure SetPositionsTextesWindowPlateau;
procedure DessineAffichageVertical;
function GetTailleCaseCourante() : SInt32;
procedure SetTailleCaseCourante(taille : SInt32);
function TailleCaseIdeale() : SInt16; 
procedure AjusteTailleFenetrePlateauPourLa3D;
procedure AjusteAffichageFenetrePlat(tailleCaseForcee : SInt16; var tailleCaseChange,positionscorechange : boolean);
procedure AjusteAffichageFenetrePlatRapide;
procedure AfficheScore;
procedure AfficheDemandeCoup;
procedure EcritJeReflechis(coulChoix : SInt16);
procedure EcritPromptFenetreReflexion;
procedure EffacePromptFenetreReflexion;
function GetRectOfSquare2DDansAireDeJeu(whichSquare,QuelGenreDeMarque : SInt16) : rect;
function GetBoundingRectOfSquare(whichSquare : SInt16) : rect;
function GetOthellier2DVistaBuffer() : rect;
function GetOthellierVistaBuffer() : rect;
procedure DessinePion2D(square,valeurPion : SInt16);
procedure DessinePion(square,valeurPion : SInt16);
procedure ApprendPolygonePionDelta(r : rect);
procedure ApprendPolygonePionLosange(r : rect);
procedure ApprendPolygonePionCarre(r : rect);
procedure DessinePionSpecial(rectangle2D,dest : rect;quelleCase,valeurPion : SInt16; use3D : boolean);
procedure DrawJustifiedStringInRectWithRGBColor(whichRect : rect; var s : str255;justification : SInt32;whichSquare : SInt16; color : RGBColor);
procedure DrawJustifiedStringInRect(whichRect : rect;couleurDesLettres : SInt16; var s : str255;justification : SInt32;whichSquare : SInt16);
procedure DrawClockBoundingRect(clockRect : rect;radius : SInt32);
procedure DrawInvertedClockBoundingRect(clockRect : rect;radius : SInt32);
procedure DessineStringInRect(whichRect : rect;couleurDesLettres : SInt16; var s : str255;whichSquare : SInt16);
procedure DessineStringOnSquare(whichSquare,couleurDesLettres : SInt16; var s : str255; var continuer : boolean);
procedure DessineLettreBlancheOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
procedure DessineLettreNoireOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
procedure DessineLettreOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
procedure DessineAnglesCarreCentral;
procedure DessineSystemeCoordonnees;
procedure EffacerSquare(var whichSquare : SInt16; var continuer : boolean);
procedure RedessinerRectDansSquare(whichSquare : SInt16; whichRect : rect);
procedure SetPositionPlateau2D(nbrecases,tailleCase : SInt16; HG_h,HG_v : SInt16; fonctionAppelante : str255);
procedure DessinePlateau(avecDessinFondNoir : boolean);
procedure DessinePlateau2D(cases,tailleCase : SInt16; HG_h,HG_v : SInt16; avecDessinFondNoir : boolean);
procedure DessinePosition(var position : plateauOthello);
procedure DessineDiagramme(tailleCaseDiagramme : SInt16; clipRegion : RgnHandle;fonctionAppelante : str255);
procedure DessineNumerosDeCoupsSurTousLesPionsSurDiagramme(jusquaQuelCoup : SInt16);
procedure Faitcalculs2DParDefaut;
function GetDernierCoup() : SInt16; 
procedure DessineNumeroCoup(square,n,couleurDesChiffres : SInt16; whichNode : GameTree);
procedure DessineNumeroDernierCoupSurOthellier(surQuellesCases : SquareSet;whichNode : GameTree);
procedure EffaceNumeroCoup(square,n : SInt16; whichNode : GameTree);
(*procedure DessineCoupEnTete;
procedure EffaceCoupEnTete;
procedure SetCoupEntete(square : SInt16);*)
procedure ParserCommentaireSolitaire(commentaire : str255; var promptGras,resteDuCommentaire : str255);
procedure EcritCommentaireSolitaire;
procedure DessineGarnitureAutourOthellierPourEcranStandard;
procedure EcranStandard(clipRegion : RgnHandle;forcedErase : boolean);
procedure DessineAutresInfosSurCasesAideDebutant(surQuellesCases : SquareSet);
procedure DessineAideDebutant(avecDessinAutresInfosSurLesCases : boolean;surQuellesCases : SquareSet);
procedure EffaceAideDebutant(avecDessinAutresInfosSurLesCases,effacageLarge : boolean;surQuellesCases : SquareSet);
procedure EffaceSuggestionDeCassio;
procedure ActiverSuggestionDeCassio(whichPos : PositionEtTraitRec;bestMove,bestDef : SInt32;fonctionAppelante : str255);
function GetBestSuggestionDeCassio() : SInt32;
procedure EraseRectDansWindowPlateau(whichRect : rect);
procedure DessineBordureDuPlateau2D(quellesBordures : SInt32);
procedure EffaceZoneADroiteDeLOthellier;
procedure EffaceZoneAuDessousDeLOthellier;
procedure EffaceZoneAGaucheDeLOthellier;
procedure EffaceZoneAuDessusDeLOthellier;
procedure EffaceTouteLaFenetreSaufLOthellier;
function  CalculateBordureRect(quelleBordure : SInt32;quelleTexture:CouleurOthellierRec) : rect;
function  PtInPlateau2D(loc : Point; var caseCliquee : SInt16) : boolean;
function  PtInPlateau(loc : Point; var caseCliquee : SInt16) : boolean;
procedure EffaceAnnonceFinaleSiNecessaire;
function  DetermineVolumeApplication() : SInt16; 
function  DeterminePathDossierFichiersAuxiliaires(volumeRefCassio : SInt16) : str255;
function  TrouveCoupDansPartieCourante(whichSquare : SInt16; var numeroDuCoup : SInt16) : boolean;

procedure SetOthellierEstSale(square : SInt16; flag : boolean);
function GetOthellierEstSale(square : SInt16) : boolean;
procedure SetOthellierToutEntierEstSale;

{fonctions de gestion du curseur Tete-de-Mort}
function CurseurEstEnTeteDeMort() : boolean;
procedure DecrementeNiveauCurseurTeteDeMort;
procedure SetNiveauTeteDeMort(niveau : SInt16);


procedure SelectCassioFonts(theme : SInt32);





IMPLEMENTATION







USES UnitBufferedPICT,UnitRapport,UnitPierresDelta,UnitAfficheArbreDeJeuCourant,UnitBibl,
     UnitEntreesSortiesGraphe,UnitApprentissageInterversion,UnitTroisiemeDimension,Unit3DPovRayPicts,
     UnitGestionDuTemps,UnitNotesSurCases,UnitRapportImplementation,UnitFenetres,UnitOth2,
     UnitMacExtras,UnitMoveRecords,UnitJaponais,MyFileSystemUtils,UnitServicesDialogs,UnitCourbe,
     UnitInterversions,UnitArbreDeJeuCourant,UnitEntreeTranscript,UnitSetUp,UnitAffichageReflexion,
     Zebra_to_Cassio,UnitDialog,UnitListe,UnitActions,UnitScannerOthellistique,SNStrings,UnitLiveUndo,
     UnitProblemeDePriseDeCoin,UnitPrefs,UnitCouleur,UnitJeu,UnitStrategie;



var LastMousePositionInAjusteCurseur : Point;
    gTailleCase:record 
                  private : SInt32;
                end;

function AttenteAnalyseDeFinaleDansPositionCourante() : boolean;external;  {definie dans UnitGestionDuTemps}
function GetBestMoveAttenteAnalyseDeFinale() : SInt32;external;   {definie dans UnitGestionDuTemps}
    
    
procedure BidProc;
begin
end;
    
procedure InitUnitOth1;
var i,j : SInt16; 
begin
  othellierToutEntier := [];
  for i := 1 to 8 do
    for j := 1 to 8 do
      othellierToutEntier := othellierToutEntier+[i*10+j];
  EssaieUpdateEventsWindowPlateauProcEstInitialise := false;
  EssaieUpdateEventsWindowPlateauProc := BidProc;
  gHorlogeRect       := MakeRect(0,0,0,0);
  gHorlogeRectGlobal := MakeRect(0,0,0,0);
  
  InvalidateAllCasesDessinEnTraceDeRayon;
end;

    
procedure InstalleEssaieUpdateEventsWindowPlateauProc(aRoutine:ProcedureType);
begin
  EssaieUpdateEventsWindowPlateauProcEstInitialise := true;
  EssaieUpdateEventsWindowPlateauProc := aRoutine;
end;


function DernierCoupEnString(enMajuscules : boolean) : string;
var coup : SInt16; 
begin
  if (nbreCoup > 0) 
    then
      begin
        coup := DerniereCaseJouee();
        if InRange(coup,11,88)
          then DernierCoupEnString := CoupEnString(coup,enMajuscules)
          else DernierCoupEnString := '';
      end
    else
      DernierCoupEnString := '';
end;




procedure WriteStringAndNumAt(s : str255;num : SInt32;h,v : SInt32);
var lignerect : rect;
    s1 : str255;
begin    
  NumToString(num,s1);
  s := s+s1+'   ';
  SetRect(lignerect,h,v-9,h+StringWidth(s),v+2);
  EraseRect(lignerect);
  Moveto(h,v);
  DrawString(s);
end;


procedure WriteStringAndNumEnSeparantLesMilliersAt(s : str255;num : SInt32;h,v : SInt32);
var lignerect : rect;
    s1 : str255;
begin    
  NumToString(num,s1);
  s := s + SeparerLesChiffresParTrois(s1) + '   ';
  SetRect(lignerect,h,v-9,h+StringWidth(s),v+2);
  EraseRect(lignerect);
  Moveto(h,v);
  DrawString(s);
end;  

procedure WriteStringAndBigNumEnSeparantLesMilliersAt(s : str255;milliards,num : SInt32;h,v : SInt32);
var lignerect : rect;
    s1 : str255;
begin
  s1 := BigNumEnString(milliards,num);
  s := s + SeparerLesChiffresParTrois(s1) + '   ';
  SetRect(lignerect,h,v-9,h+StringWidth(s),v+2);
  EraseRect(lignerect);
  Moveto(h,v);
  DrawString(s);
end;  


procedure WriteStringAt(s : str255;h,v : SInt32);
var lignerect : rect;
begin    
  s := s+StringOf(' ');
  SetRect(lignerect,h,v-9,h+StringWidth(s),v+2);
  EraseRect(lignerect);
  Moveto(h,v);
  DrawString(s);
end;


procedure WriteStringAtWithoutErase(s : str255;h,v : SInt32);
  var lignerect : rect;
  begin    
    s := s+StringOf(' ');
    SetRect(lignerect,h,v-9,h+StringWidth(s),v+2);
    Moveto(h,v);
    DrawString(s);
  end;

  
procedure WriteReelAt(unreel : extended;h,v : SInt32);
var lignerect : rect;
begin
  SetRect(ligneRect,h,v-9,h+30,v+2);
  EraseRect(lignerect);
  Moveto(h,v);
  DrawString(ReelEnString(unreel));
end;


procedure WriteStringAndReelAt(s : str255;unreel : extended;h,v : SInt32);
var lignerect : rect;
begin
  s := s+ReelEnString(unreel)+'   ';
  SetRect(lignerect,h,v-9,h+StringWidth(s),v+2);
  EraseRect(lignerect);
  Moveto(h,v);
  DrawString(s);
end;

procedure WriteStringAndBoolAt(s : str255;bool : boolean;h,v : SInt32);
var lignerect : rect;
begin
  if bool 
    then s := s+' TRUE   '
    else s := s+' FALSE  ';
  SetRect(lignerect,h,v-9,h+StringWidth(s),v+2);
  EraseRect(lignerect);
  Moveto(h,v);
  DrawString(s);
end;





function PictIDPalette(nroAction : SInt16; enfoncee : boolean) : SInt16; 
begin
  case nroAction of
    PaletteRetourDebut    : if enfoncee then PictIDPalette := 158 else PictIDPalette := 139;
    PaletteDoubleBack     : if enfoncee then PictIDPalette := 159 else PictIDPalette := 140;
    PaletteBack           : if enfoncee then PictIDPalette := 160 else PictIDPalette := 141;
    PaletteForward        : if enfoncee then PictIDPalette := 161 else PictIDPalette := 142;
    PaletteDoubleForward  : if enfoncee then PictIDPalette := 162 else PictIDPalette := 143;
    PaletteAllerFin       : if enfoncee then PictIDPalette := 163 else PictIDPalette := 144;
    PaletteCoupPartieSel  : if enfoncee then PictIDPalette := 164 else PictIDPalette := 145;
    PaletteCouleur        : {if HumCtreHum
                              then if enfoncee then PictIDPalette := 167 else PictIDPalette := 148
                              else }
                                if couleurMacintosh = pionBlanc
                                  then if enfoncee then PictIDPalette := 182 else PictIDPalette := 180
                                  else if enfoncee then PictIDPalette := 183 else PictIDPalette := 181;
    PaletteSablier        : if HumCtreHum
                              then if enfoncee then PictIDPalette := 169 else PictIDPalette := 150
                              else if enfoncee then PictIDPalette := 168 else PictIDPalette := 149;
    PaletteInterrogation  : if enfoncee then PictIDPalette := 170 else PictIDPalette := 151;
    PaletteHorloge        : if enfoncee then PictIDPalette := 171 else PictIDPalette := 152;
    PaletteDiagramme      : if enfoncee then PictIDPalette := 173 else PictIDPalette := 154;
    PaletteBase           : if enfoncee then PictIDPalette := 174 else PictIDPalette := 155;
    PaletteSon            : if avecSon
                              then if enfoncee then PictIDPalette := 179 else PictIDPalette := 178
                              else if enfoncee then PictIDPalette := 172 else PictIDPalette := 153;
    PaletteCourbe         : if enfoncee then PictIDPalette := 175 else PictIDPalette := 156;
    PaletteStatistique    : if enfoncee then PictIDPalette := 176 else PictIDPalette := 157;
    PaletteReflexion      : if enfoncee then PictIDPalette := 165 else PictIDPalette := 146;
    PaletteListe          : if enfoncee then PictIDPalette := 166 else PictIDPalette := 147;
    
  end;
end;








procedure FlashCasePalette(nroaction : SInt16);
  const attente=8;
  var tick : SInt32;
      unRect : rect;
      oldPort : grafPtr;
      CaseXPalette,CaseYPalette : SInt16; 
      UnePicture:picHandle;
  
begin
  GetPort(oldPort);
  SetPortByWindow(wPalettePtr);
  CaseXPalette := (nroaction-1) mod 9 + 1;
  CaseYPalette := (nroaction-1) div 9 + 1;
  if gBlackAndWhite
    then
      begin
        SetRect(unRect,(CaseXPalette-1)*largeurCasePalette,
                       (CaseYPalette-1)*hauteurCasePalette,
                        CaseXPalette*largeurCasePalette -1,
                        CaseYPalette*HauteurCasePalette -1);
        InvertRect(unRect);
        tick := TickCount();
        while TickCount()-tick<attente do;
        InvertRect(unRect);
      end
    else
      begin
        UnePicture := GetPicture(PictIDPalette(nroAction,true));
        unRect := UnePicture^^.picframe;
        OffsetRect(unRect,LargeurCasePalette*(CaseXPalette-1)-1,HauteurCasePalette*(CaseYPalette-1)-1);
        DrawPicture(UnePicture,unRect);
        ReleaseResource(Handle(UnePicture));
        tick := TickCount();
        while TickCount()-tick<attente do;
        UnePicture := GetPicture(PictIDPalette(nroAction,false));
        DrawPicture(UnePicture,unRect);
        ReleaseResource(Handle(UnePicture));
      end;
  SetPort(oldPort);
end;
     
procedure DessineCasePaletteCouleur(nroAction : SInt16; enfoncee : boolean);
var unRect : rect;
    oldPort : grafPtr;
    CaseXPalette,CaseYPalette : SInt16; 
    UnePicture:picHandle;
begin
  GetPort(oldPort);
  SetPortByWindow(wPalettePtr);
  CaseXPalette := (nroaction-1) mod 9 + 1;
  CaseYPalette := (nroaction-1) div 9 + 1;
  UnePicture := GetPicture(PictIDPalette(nroAction,enfoncee));
  unRect := UnePicture^^.picframe;
  OffsetRect(unRect,LargeurCasePalette*(CaseXPalette-1)-1,HauteurCasePalette*(CaseYPalette-1)-1);
  DrawPicture(UnePicture,unRect);
  ReleaseResource(Handle(UnePicture));
  SetPort(oldPort);
end;

procedure DrawColorPICT(pictID : SInt16; inRect : rect);
var UnePicture:picHandle;
begin
  UnePicture := GetPicture(pictID);
  DrawPicture(UnePicture,inRect);
  ReleaseResource(Handle(UnePicture));
end;

procedure DessineIconesChangeantes;
var unRect : rect;
    UnePicture:picHandle;
    oldPort : grafPtr;
    rayon,a,b : SInt16; 
begin
  if windowPaletteOpen & (wPalettePtr <> NIL) then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPalettePtr);
      rayon := 6;
      a := LargeurCasePalette div 2 ;
      b := HauteurCasePalette+HauteurCasePalette div 2;
      SetRect(unRect,a-rayon,b-rayon,a+rayon,b+rayon);
      if not(gBlackAndWhite)
        then 
          DessineCasePaletteCouleur(PaletteCouleur,false)
        else
            {if HumCtreHum 
            then EraseRect(unRect)
            else} if couleurMacintosh = pionNoir
                   then FillOval(unRect,blackPattern)
                   else 
                     begin
                       FrameOval(unRect);
                       InsetRect(unRect,1,1);
                       EraseOval(unRect);
                     end;
              
      if HumCtreHum 
       then
        begin
          SablierDessineEstRenverse := true;
          if gBlackAndWhite
            then
              begin
                UnePicture := GetPicture(BWSablierRenversePictID);
                unRect := UnePicture^^.picframe;
                OffsetRect(unRect,LargeurCasePalette,HauteurCasePalette);
                DrawPicture(UnePicture,unRect);
                ReleaseResource(Handle(UnePicture));
              end
            else
              DessineCasePaletteCouleur(PaletteSablier,false);
        end
       else
        begin
          if gBlackAndWhite
            then
              begin
                SablierDessineEstRenverse := false;
                UnePicture := GetPicture(BWSablierDeboutPictID);
                unRect := UnePicture^^.picframe;
                OffsetRect(unRect,LargeurCasePalette,HauteurCasePalette);
                DrawPicture(UnePicture,unRect);
                ReleaseResource(Handle(UnePicture));
              end
            else
              DessineCasePaletteCouleur(PaletteSablier,false);
        end;
      
      if not(gBlackAndWhite)
        then DessineCasePaletteCouleur(PaletteSon,false)
        else
         if avecSon 
          then
           begin
             UnePicture := GetPicture(BWSonPictID);
             unRect := UnePicture^^.picframe;
             OffsetRect(unRect,4*LargeurCasePalette+LargeurCasePalette div 2+1,HauteurCasePalette+2);
             DrawPicture(UnePicture,unRect);
             ReleaseResource(Handle(UnePicture));
           end
          else
           begin
             SetRect(unRect,4*LargeurCasePalette+LargeurCasePalette div 2+1,HauteurCasePalette+2,
                            5*LargeurCasePalette-2,HauteurCasePalette+16);
             EraseRect(unRect);
           end;
      
      SetPort(oldPort);
    end;
end;

procedure DessinePalette;
var oldPort : grafPtr;
    structRect : rect;
    palettePicture:picHandle;
begin
  if windowPaletteOpen & (wPalettePtr <> NIL) then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPalettePtr);
      
      if gBlackAndWhite
        then palettePicture := GetPicture(BWPalettePictID)
        else palettePicture := GetPicture(CPalettePictID);
      structRect := palettePicture^^.picframe;
      OffsetRect(structRect,-1,-1);
      DrawPicture(palettePicture,structRect);
      ReleaseResource(Handle(palettePicture));
      
      DessineIconesChangeantes;
      
      
      {bidbool := WaitNextEvent(EveryEvent,theEvent,2,NIL);
      if (QDIsPortBuffered(GetWindowPort(wPalettePtr))) then
        QDFlushPortBuffer(GetWindowPort(wPalettePtr), NIL);
      Sysbeep(0);
      Attendfrappeclavier;}
      
      ValidRect(GetWindowPortRect(wPalettePtr));
      SetPort(oldPort);
    end;
end;


procedure DessineRubanDuCommentaireDansFenetreArbreDeJeu(forceModeEdition : boolean);
const CommentaireTitreStaticText = 1;
var oldPort : grafPtr;
    unRect : rect;
    s : str255;
begin
  with arbreDeJeu do
  if windowOpen & (GetArbreDeJeuWindow() <> NIL) then
    begin
      {WritelnDansRapport('DessineZoneDeTexteDansFenetreArbreDeJeu');}
      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow());
      
      TextSize(gCassioSmallFontSize);
      TextFace(normal); 
      TextFont(gCassioApplicationFont);
      TextMode(srcOr); 
      
      GetDialogItemRect(theDialog,CommentaireTitreStaticText,unRect);
      Moveto(4,unRect.top+gCassioSmallFontSize+1);
      EraseRect(MakeRect(3,unrect.top,500,unRect.top+gCassioSmallFontSize+3));
      
      if (nbreCoup <= 0) | positionFeerique
        then 
          begin
            s := ReadStringFromRessource(10020,8);  {'Commentaires'}
            DrawString(s);  
          end
        else 
          begin
            s := ReadStringFromRessource(10020,9);  {'Commentaires de ^0'}
            DrawString(s);
            TextFace(bold); 
            DrawString(NumEnString(nbreCoup)+'.'+DernierCoupEnString(false));
          end;
      
      
      if forceModeEdition then enModeEdition := true;
      if not(forceModeEdition) & (GetArbreDeJeuWindow() <> FrontWindowSaufPalette())
        then enModeEdition := false;
        
      if forceModeEdition | (enModeEdition & (GetArbreDeJeuWindow() = FrontWindowSaufPalette())) | doitResterEnModeEdition
        then
          begin
            PenSize(2,2);
            PenPat(blackPattern);
            FrameRect(EditionRect);
            PenNormal;
          end
        else
          begin
            PenSize(2,2);
            PenPat(whitePattern);
            FrameRect(EditionRect);
            PenNormal;
          end;
      unRect := EditionRect;
      
      
      SetPort(oldPort);
    end;
end;




procedure DessineZoneDeTexteDansFenetreArbreDeJeu(forceModeEdition : boolean);
var oldPort : grafPtr;
begin
  with arbreDeJeu do
  if windowOpen & (GetArbreDeJeuWindow() <> NIL) then
    begin
      {WritelnDansRapport('DessineZoneDeTexteDansFenetreArbreDeJeu');}
      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow());
      MyDrawDialog(arbreDeJeu.theDialog);
      DessineRubanDuCommentaireDansFenetreArbreDeJeu(forceModeEdition);
      DessineBoiteDeTaille(GetArbreDeJeuWindow());
      SetPort(oldPort);
    end;
end;


procedure CalculeEditionRectFenetreArbreDeJeu;
const CommentairesEditableText=2;
var unRect : rect;
    oldPort : grafPtr;
    myText : TEHandle;
begin
  with arbreDeJeu do
    if windowOpen & (GetArbreDeJeuWindow() <> NIL) then
      begin
        GetPort(oldPort);
        SetPortByWindow(GetArbreDeJeuWindow());
        GetDialogItemRect(arbreDeJeu.theDialog,CommentairesEditableText,unRect);
        unRect.bottom := QDGetPortBound().bottom-7;
        unRect.right := QDGetPortBound().right-7;
        SetDialogItemRect(arbreDeJeu.theDialog,CommentairesEditableText,unRect);
        
        
        myText := GetDialogTextEditHandle(theDialog);
        if myText <> NIL then
          begin
            TESetViewRect(myText,unRect);
            TESetDestRect(myText,unRect);
            myText^^.txSize := 9;
            myText^^.lineHeight := 11;
            myText^^.fontAscent := 9;
            myText^^.txFont := gCassioApplicationFont;
            TECalText(myText);
          end;
        
        EditionRect := unRect;
        InsetRect(EditionRect,-6,-6);
        SetPort(oldPort);
      end;
end;

procedure ChangeDelimitationEditionRectFenetreArbreDeJeu(positionDelimitation : SInt16);
const CommentaireTitreStaticText=1;
      CommentairesEditableText=2;
var unRect : rect;
    oldPort : grafPtr;
begin
  with arbreDeJeu do
    if windowOpen & (theDialog <> NIL) then
      begin
        GetPort(oldPort);
        SetPortByDialog(arbreDeJeu.theDialog);
        
        if positionDelimitation>QDGetPortBound().bottom-29 then positionDelimitation := QDGetPortBound().bottom-29;
        if positionDelimitation<42 then positionDelimitation := 42;
        
        arbreDeJeu.positionLigneSeparation := positionDelimitation;
        
        GetDialogItemRect(theDialog,CommentaireTitreStaticText,unRect);
        OffsetRect(unRect,0,positionDelimitation-6 - unRect.top);
        SetDialogItemRect(theDialog,CommentaireTitreStaticText,unRect);
        GetDialogItemRect(theDialog,CommentairesEditableText,unRect);
        unRect.top := positionDelimitation+12;
        SetDialogItemRect(theDialog,CommentairesEditableText,unRect);
        CalculeEditionRectFenetreArbreDeJeu;
        SetPort(oldPort);
      end;
end;

procedure ActiverModeEditionFenetreArbreDeJeu;
var myText : TEHandle;
begin
  with arbreDeJeu do
    begin
      myText := GetDialogTextEditHandle(theDialog);
      if myText <> NIL then
        begin
          enModeEdition := true;
          doitResterEnModeEdition := EnTraitementDeTexte;
          SwitchToScript(gLastScriptUsedInDialogs);
          TEActivate(myText);
          DessineZoneDeTexteDansFenetreArbreDeJeu(enModeEdition);
        end;
    end;
end;

procedure DeactiverModeEditionFenetreArbreDeJeu;
begin
  ValideZoneCommentaireDansFenetreArbreDeJeu;
end;

procedure FaireClignoterFenetreArbreDeJeu;
var myText : TEHandle;
begin
  with arbreDeJeu do
    if {enModeEdition & }windowOpen & (GetArbreDeJeuWindow() <> NIL) then
      begin
        myText := GetDialogTextEditHandle(theDialog);
        if myText <> NIL then TEIdle(myText)
      end;
end;

procedure ClicDansTexteCommentaires(pt : Point;extend : boolean);
var myText : TEHandle;
begin
  with arbreDeJeu do
    if windowOpen & (GetArbreDeJeuWindow() <> NIL) then
      begin
        myText := GetDialogTextEditHandle(theDialog);
        if myText <> NIL then TEClick(pt,extend,myText);
      end;
end;



function AuMoinsUneZoneDeTexteEnModeEntree() : boolean;
var fenetrePremierPlan : WindowPtr;
begin
  fenetrePremierPlan := FrontWindowSaufPalette();
  if (EnTraitementDeTexte & FenetreRapportEstOuverte() & (EstLaFenetreDuRapport(fenetrePremierPlan))) |
     (arbreDeJeu.enModeEdition & arbreDeJeu.windowOpen & (fenetrePremierPlan=GetArbreDeJeuWindow())) |
     ((BoiteDeSousCritereActive <> 0) & windowListeOpen & (fenetrePremierPlan=wListePtr))
     then AuMoinsUneZoneDeTexteEnModeEntree := true
     else AuMoinsUneZoneDeTexteEnModeEntree := false;
end;

function CassioIsInBackground() : boolean;
begin
  CassioIsInBackground := inBackGround;
end;

function CassioEstEnModeSolitaire() : boolean;
begin
  CassioEstEnModeSolitaire := (CommentaireSolitaire^^ <> '');
end;

function CassioEstEnModeAnalyse() : boolean;
begin
  CassioEstEnModeAnalyse := (GetCadence() = minutes10000000) &
                            not(analyseRetrograde.enCours) & 
                            (CommentaireSolitaire^^ = '') & 
                            not(demo);
end;



procedure AjusteCurseur;
var mouseLoc : Point;
    unRect : rect;
    oldPort : grafPtr;
    whichSquare,numeroDuCoup : SInt16; 
    whichNode : GameTree;
    localFrontWindow : WindowPtr;
    localFrontWindowSaufPalette : WindowPtr;
label sortie;
begin {AjusteCurseur}
  
  if doitAjusterCurseur then
    begin {1}
      GetPort(oldPort);
      EssaieSetPortWindowPlateau;
      
		  GetMouse(mouseLoc);
		  if (LastMousePositionInAjusteCurseur.h <> mouseLoc.h) | 
		     (LastMousePositionInAjusteCurseur.v <> mouseLoc.v) then
		    begin {2}
		      LastMousePositionInAjusteCurseur := mouseLoc;
		      AccelereProchainDoSystemTask(60);
		      DiminueLatenceEntreDeuxDoSystemTask;
		    end; {2}
		    
		    
		  if not(inBackGround) then
		    begin {2}
		      localFrontWindow := FrontWindow();
		      
  		    if WindowDeCassio(localFrontWindow) | (localFrontWindow = NIL) 
  		      then
  		        begin {3}
  		        
  		          if Quitter then 
		              begin {4}
		                InitCursor;
		                goto sortie;
		              end; {4}
  		            
                if enSetUp & not(iconisationDeCassio.encours) then
                  begin {4}
                    case couleurEnCoursPourSetUp of
                      pionNoir  : SafeSetCursor(pionNoirCurseur);
                      pionBlanc : SafeSetCursor(pionBlancCurseur);
                      pionVide  : SafeSetCursor(gommeCurseur);
                      otherwise   InitCursor;
                    end; {case}
                    goto sortie;
                  end; {4}
  		                
                if CurseurEstEnTeteDeMort() then
                  begin {4}
                    teteDeMortCurseur := GetCursor(teteDeMortCursorID);
                    SafeSetCursor(teteDeMortCurseur);
                    goto sortie;
                  end; {4} 
                
                LocalToGlobal(mouseLoc);
                
                localFrontWindowSaufPalette := FrontWindowSaufPalette();
                
                if windowCourbeOpen & (wCourbePtr <> NIL) & (wCourbePtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wCourbePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        if TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe(mouseLoc)
                          then 
                          else
                            begin
                              if gameOver
                              then InitCursor
                              else 
                                if (aQuiDeJouer = pionBlanc)
                                  then SafeSetCursor(pionBlancCurseur)
                                  else SafeSetCursor(pionNoirCurseur);
                            end;
                        goto sortie;
                      end; {5}
                  end; {4}
  		                
                if enSetUp | iconisationDeCassio.encours | enRetour then 
                  begin {4}
                    InitCursor;
                    goto sortie;
                  end; {4}
                  
                if windowPaletteOpen & (wPalettePtr <> NIL) & (wPalettePtr = localFrontWindow) then
                  begin {4}
                    unRect := GetWindowStructRect(wPalettePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        InitCursor;
                        goto sortie;
                      end; {5}
                  end; {4}
                
                if windowListeOpen & (wListePtr <> NIL) & (wListePtr = localFrontWindowSaufPalette)  then
                  begin {4}
                    unRect := GetWindowContentRect(wListePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SetPortByWindow(wListePtr);
                        GlobalToLocal(mouseLoc);
                        
                        if {(nbPartiesChargees>0) &}
                           (((SousCriteresRuban[TournoiRubanBox]      <> NIL) & PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[TournoiRubanBox]))) |
                            ((SousCriteresRuban[JoueurNoirRubanBox]   <> NIL) & PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[JoueurNoirRubanBox]))) |
                            ((SousCriteresRuban[JoueurBlancRubanBox]  <> NIL) & PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[JoueurBlancRubanBox]))) |
                            ((SousCriteresRuban[DistributionRubanBox] <> NIL) & PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[DistributionRubanBox]))))
                           then 
                             begin {6}
                              iBeam := GetCursor(iBeamCursor);
                              SafeSetCursor(iBeam);
                             end {6}
                           else
                             if (mouseLoc.v <= hauteurRubanListe - 3)
                               then SafeSetCursor(GetCursor(DigitCurseurID))
                               else InitCursor;
                        goto sortie;
                      end; {5}
                  end; {4}
                
                      
                if windowStatOpen & (wStatPtr <> NIL) & (wStatPtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wStatPtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SetPortByWindow(wStatPtr);
                        GlobalToLocal(mouseLoc);
                        if (mouseLoc.v<hauteurRubanStatistiques) & (nbreCoup>0) 
                          then
                            begin {6}
                              backMoveCurseur := GetCursor(backMoveCurseurID);
                              SafeSetCursor(backMoveCurseur);
                            end {6}
                          else
                        if (nbPartiesActives>0) & not(gameOver) & (statistiques <> NIL) & 
                           (mouseLoc.v<=hauteurRubanStatistiques+hauteurChaqueLigneStatistique*statistiques^^.nbreponsesTrouvees + 3) &
                           (mouseLoc.v>=hauteurRubanStatistiques) 
                          then
                            begin {6}
                              avanceMoveCurseur := GetCursor(avanceMoveCurseurID);
                              SafeSetCursor(avanceMoveCurseur);
                            end {6}
                          else
                            InitCursor;
                        goto sortie;
                      end; {5}
                  end; {4}
		                    
                if windowAideOpen & (wAidePtr <> NIL) & (wAidePtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wAidePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                  end; {4}
                      
                if arbreDeJeu.windowOpen & (GetArbreDeJeuWindow() <> NIL) & (GetArbreDeJeuWindow() = localFrontWindowSaufPalette) then
                  with arbreDeJeu do
                  begin {4}
                    unRect := GetWindowContentRect(GetArbreDeJeuWindow());
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SetPortByDialog(arbreDeJeu.theDialog);
                        if (mouseLoc.h >= unRect.right - 15) & (mouseLoc.v >= unRect.bottom - 15)
                          then
                            begin {6}
                              InitCursor;
                              goto sortie;
                            end; {6}
                        GlobalToLocal(mouseLoc);
                        if enModeEdition & PtInRect(mouseLoc,editionRect)
                          then 
                            begin {6}
                              iBeam := GetCursor(iBeamCursor);
                              SafeSetCursor(iBeam);
                              goto sortie;
                            end {6}
                          else
                            begin {6}
                              if avecInterversions & 
                                 SurIconeInterversion(mouseLoc,whichNode) & not(Button()) then 
                                begin {7}
                                  EcrireInterversionsDuGrapheCeNoeudDansRapport(whichNode);
                                  if (whichNode=GetCurrentNode()) then
                                    begin {8}
                                      interversionCurseur := GetCursor(interversionCursorID);
                                      SafeSetCursor(interversionCurseur);
                                      goto sortie;
                                    end; {8}
                                end; {7}
                              if PtInRect(mouseLoc,backMoveRect) & (nbreCoup>0) & (not(enModeEdition) | doitResterEnModeEdition)
	                              then
	                                begin {7}
	                                  backMoveCurseur := GetCursor(backMoveCurseurID);
	                                  SafeSetCursor(backMoveCurseur);
	                                  goto sortie;
	                                end {7}
	                              else
	                            if (mouseLoc.v > EditionRect.top-12) & (mouseLoc.v < EditionRect.top) 
	                              then
                                  begin {7}
	                                  DragLineHorizontalCurseur := GetCursor(DragLineHorizontalCurseurID);
	                                  SafeSetCursor(DragLineHorizontalCurseur);
	                                  goto sortie;
	                                end {7}
	                              else
	                            if (mouseLoc.v >= backMoveRect.bottom) & (mouseLoc.v <= EditionRect.top-12) & 
	                               (NbDeFilsOfCurrentNode()>=1) &
	                               (((mouseLoc.v - 1) div InterligneArbreFenetreArbreDeJeu()) <= NbDeFilsOfCurrentNode()+1) & (not(enModeEdition) | doitResterEnModeEdition)
                                then
	                                begin {7}
	                                  if (DernierEvenement.shift)
	                                    then
	                                      begin {8}
	                                        DragLineHorizontalCurseur := GetCursor(DragLineHorizontalCurseurID);
	                                        SafeSetCursor(DragLineHorizontalCurseur);
	                                        goto sortie;
	                                      end {8}
	                                    else
	                                      begin {8}
	                                        avanceMoveCurseur := GetCursor(avanceMoveCurseurID);
	                                        SafeSetCursor(avanceMoveCurseur);
	                                        goto sortie;
	                                      end; {8}
	                                end {7}
	                              else
	                                InitCursor;
	                          end; {6}
                        goto sortie;
                      end; {5}
                  end; {4}
                      
                if FenetreRapportEstOuverte() & FenetreRapportEstAuPremierPlan() then
                  begin {4}
                    unRect := GetWindowContentRect(GetRapportWindow());
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        unRect.right := unRect.right-15;
                        unRect.bottom := unRect.bottom-15;
                        if EnTraitementDeTexte & PtInRect(mouseLoc,unRect) 
                          then
                            begin {6}
                              iBeam := GetCursor(iBeamCursor);
                              SafeSetCursor(iBeam);
                            end {6}
                          else InitCursor;
                        goto sortie;
                      end; {5}
                  end; {4}
                      
                      
                if windowPlateauOpen & (wPlateauPtr <> NIL) then
                  begin {4}
                    if PtInRect(mouseLoc,gHorlogeRectGlobal) & not(EnModeEntreeTranscript()) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                    if (DernierEvenement.control | DernierEvenement.option | (DernierEvenement.command & sousEmulatorSousPC)) then
                      begin {5}
                        unRect := GetWindowContentRect(wPlateauPtr);
                        if PtInRect(mouseLoc,unRect) then
                          begin {6}
                            SetPortByWindow(wPlateauPtr);
                            GlobalToLocal(mouseLoc);
                            if PtInPlateau(mouseLoc,whichSquare) then
                              begin {7}
                                if DernierEvenement.control | (DernierEvenement.command & sousEmulatorSousPC)  then 
                                  {on prepare pour le menu des pierres delta}
                                  begin {8}
                                    InitCursor;
                                    goto sortie;
                                  end; {8}
                                if DernierEvenement.option then 
                                  {on prepare pour avancer/reculer}
                                  if TrouveCoupDansPartieCourante(whichSquare,numeroDuCoup) then
                                    begin {8}
	                                    if numeroDuCoup < nbreCoup  then
                                        begin {9}
				                                  backMoveCurseur := GetCursor(backMoveCurseurID);
	                                        SafeSetCursor(backMoveCurseur);
				                                  goto sortie;
				                                end; {9}
				                              if numeroDuCoup+1 > nbreCoup then
                                        begin {9}
				                                  avanceMoveCurseur := GetCursor(avanceMoveCurseurID);
				                                  SafeSetCursor(avanceMoveCurseur);
				                                  goto sortie;
				                                end; {9}
	                                  end; {8}
                              end; {7}
                            LocalToGlobal(mouseLoc);
                          end; {6}
                      end; {5}
                  end; {4}
	                    
	                    
                if EnModeEntreeTranscript() & (NombreSuggestionsAffichees() >= 1) then
                  if windowPlateauOpen & (wPlateauPtr <> NIL) then
                    begin {4}
                      unRect := GetWindowContentRect(wPlateauPtr);
                      if PtInRect(mouseLoc,unRect) then
                        begin {5}
                          SetPortByWindow(wPlateauPtr);
                          GlobalToLocal(mouseLoc);
                          if (mouseLoc.v > (aireDeJeu.bottom + EpaisseurBordureOthellier() + 4)) then
                            begin {6}
                              InitCursor;
                              goto sortie;
		                        end; {6}
		                      LocalToGlobal(mouseLoc);
		                    end; {5}
                    end; {4}
                      
                if gameOver
                  then InitCursor
                  else 
                    if (aQuiDeJouer = pionBlanc)
                      then SafeSetCursor(pionBlancCurseur)
                      else SafeSetCursor(pionNoirCurseur);
                        
		          end; {3}
		          
		    end; {2}
		        
		 sortie :
		   SetPort(oldPort);
		         
	 end; {1}
	 
end; {AjusteCurseur}


procedure BeginCurseurSpecial(whichCursor:CursHandle);
begin
  SafeSetCursor(whichCursor);
  doitAjusterCurseur := false;
end;


procedure EndCurseurSpecial;
begin
  doitAjusterCurseur := true;
  AjusteCurseur;
end;


{$S UnitOth1_bis}

procedure PrepareTexteStatePourTranscript;
var oldPort : grafPtr;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourTranscript');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      TextFace(bold);
      TextFont(gCassioApplicationFont);
      
      
      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
	        {DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));}
	        EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);
	      end;
	      
      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourHeure;
var oldPort : grafPtr;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourHeure');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      if NePasUtiliserLeGrasFenetreOthellier
        then TextFace(normal)
        else TextFace(bold);
      TextFont(gCassioApplicationFont);
      
      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;
	      
      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourMeilleureSuite;
var oldPort : grafPtr;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourMeilleureSuite');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      
      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;
	      
      TextSize(gCassioSmallFontSize);
      if BordureOthellierEstUneTexture()
        then 
          begin
            TextFace(normal);
            TextMode(srcBic);
            if false & gCassioUseQuartzAntialiasing then
              begin
                if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
	              EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),false);
	            end;
	        
          end
        else 
          begin
            TextFace(normal); 
            TextMode(srcBic);
          end;
      TextFont(gCassioApplicationFont);
      
      
	      
      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourDemandeCoup;
var oldPort : grafPtr;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourDemandeCoup');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      if NePasUtiliserLeGrasFenetreOthellier | EnJolie3D()
        then TextFace(normal)
        else TextFace(bold);
      TextFont(gCassioApplicationFont);
      
      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;
	      
      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourCommentaireSolitaire;
var oldPort : grafPtr;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourCommentaireSolitaire');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      
      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;
	      
      if BordureOthellierEstUneTexture()
        then 
          begin
            TextFace(normal);
            TextMode(srcBic);
            {if gCassioUseQuartzAntialiasing then
              begin
                if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
                EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),false);
              end;}
          end
        else 
          begin
            TextFace(normal); 
            TextMode(srcBic);
          end;
      TextFont(gCassioApplicationFont);
	      
      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourSystemeCoordonnees;
var oldPort : grafPtr;
    couleurCoordonnees : RGBColor;
begin  {$UNUSED couleurCoordonnees}
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourSystemeCoordonnees');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize+1);
      
      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;
	      
      if BordureOthellierEstUneTexture() & not(FichierBordureEstIntrouvable())
        then 
          begin
            TextMode(srcOr);
            TextFace(normal); 
            {SetRGBColor(couleurCoordonnees,65535,60138,6168);  (* couleur du pion doré *)
            RGBForeColor(couleurCoordonnees);
            RGBBackColor(couleurCoordonnees);}
            couleurCoordonnees := CouleurCmdToRGBColor(MarronCmd);
            RGBForeColor(couleurCoordonnees);
            RGBBackColor(couleurCoordonnees);
            if gCassioUseQuartzAntialiasing then
              EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);
          end
        else 
          begin
            {utiliser les deux lignes ci-dessous pour un blanc tout simple et discret}
            (* TextMode(srcBic);
               TextFace(normal); *)
            
            
            TextMode(srcOr);
            TextFace(normal); 
            {SetRGBColor(couleurCoordonnees,65535,60138,6168);}        {* couleur du pion doré *}
            couleurCoordonnees := CouleurCmdToRGBColor(BlancCmd);  {* Blanc *}
            RGBForeColor(couleurCoordonnees);
            RGBBackColor(couleurCoordonnees);
            if false & gCassioUseQuartzAntialiasing then
              EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);
            
            
          end;
      
      TextFont(gCassioApplicationFont);
      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourCommentaireOuverture;
var oldPort : grafPtr;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourCommentaireOuverture');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      TextFace(normal); 
      TextFont(gCassioApplicationFont);
      
      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;
	      
      SetPort(oldPort);
    end;
end;


procedure PrepareTexteStatePourEcritCoupsBibl;
var oldPort : grafPtr;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourCommentaireOuverture');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      TextFace(normal); 
      TextFont(gCassioApplicationFont);
      
      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;
	      
      SetPort(oldPort);
    end;
end;


function EpaisseurBordureOthellier() : SInt32;
begin
  EpaisseurBordureOthellier := aireDeJeu.top;
end;


function CalculateHorlogeBoundingRect() : rect;
var positionNaturelleOfBoundingRect,delta : SInt32;
    limiteANePasDepasserVersLaGauche : SInt32;
begin
  if CassioEstEn3D()
    then CalculateHorlogeBoundingRect := MakeRect(posHNoirs-8,posVNoirs-15,posHBlancs+70,posVBlancs+18)
    else 
      begin
        positionNaturelleOfBoundingRect := posHNoirs-8;
        
        if garderPartieNoireADroiteOthellier | not(BordureOthellierEstUneTexture())
          then limiteANePasDepasserVersLaGauche := aireDeJeu.right + EpaisseurBordureOthellier() + 3
          else limiteANePasDepasserVersLaGauche := aireDeJeu.right;
          
        delta := limiteANePasDepasserVersLaGauche - positionNaturelleOfBoundingRect;
        
        if delta < 0
          then CalculateHorlogeBoundingRect := MakeRect(positionNaturelleOfBoundingRect,posVNoirs-15,posHBlancs+70,posVBlancs+18)
          else CalculateHorlogeBoundingRect := MakeRect(limiteANePasDepasserVersLaGauche,posVNoirs-15,posHBlancs+70-delta+2,posVBlancs+18);
      end;
end;


procedure DrawClockBoundingRect(clockRect : rect;radius : SInt32);
var couleurDuBois : RGBColor;
    tailleOmbrageDuBouton : SInt32;
begin
  if not(CassioEstEn3D() | EnModeEntreeTranscript() | enRetour | enSetUp) then
    begin
      SetRGBColor(couleurDuBois,30500,14000,2800);
      if BordureOthellierEstUneTexture() & not(garderPartieNoireADroiteOthellier)
        then tailleOmbrageDuBouton := 5
        else tailleOmbrageDuBouton := 2;
      DessineOmbreRoundRect(clockRect,radius,radius,couleurDuBois,tailleOmbrageDuBouton,2000,0,1);
    end;
end;


procedure DrawInvertedClockBoundingRect(clockRect : rect;radius : SInt32);
var couleurDuBois : RGBColor;
    tailleOmbrageDuBouton : SInt32;
begin
  if not(CassioEstEn3D()) then
    begin
      SetRGBColor(couleurDuBois,30500,14000,2800);
      if BordureOthellierEstUneTexture() & not(garderPartieNoireADroiteOthellier)
        then tailleOmbrageDuBouton := 5
        else tailleOmbrageDuBouton := 2;
      DessineOmbreRoundRect(clockRect,radius,radius,couleurDuBois,tailleOmbrageDuBouton,2500,2000,1);
    end;
end;


function RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(windowRect : rect;whichRect : rect) : boolean;
var oldPort : grafPtr;
begin
  RectangleDeFenetreCacheCeRectangleDansFenetrePlateau := false;
  
  if windowPlateauOpen & (wPlateauPtr <> NIL) then
    begin
      GetPort(oldPort);
      EssaieSetPortWindowPlateau;
      GlobalToLocalRect(windowRect);
      
      RectangleDeFenetreCacheCeRectangleDansFenetrePlateau := SectRect(whichRect,windowRect,windowRect);
      
      SetPort(oldPort);
    end;
end;


procedure SetPositionScore2D;
var limiteDroiteDeLaFenetre : SInt32;
    auxNoirs,auxBlancs : SInt32;
    decalageAuxiliaireVersLaDroite : SInt32;
begin
 if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) 
   then
     begin
      posHNoirs := 3;
      posVNoirs := aireDeJeu.bottom+24;
      posHBlancs := posHNoirs;
      posVBlancs := posVNoirs+25;
     end
   else
     begin
       limiteDroiteDeLaFenetre := GetWindowPortRect(wPlateauPtr).right;
       
       
       decalageAuxiliaireVersLaDroite := 0;
       if garderPartieNoireADroiteOthellier | not(BordureOthellierEstUneTexture()) then
        if avecSystemeCoordonnees  
          then decalageAuxiliaireVersLaDroite := EpaisseurBordureOthellier() + 4;
          
      
       posHNoirs := aireDeJeu.right+20;
       posVNoirs := 25;
       if (genreAffichageTextesDansFenetrePlateau = kAffichageTresSerre) | 
          (limiteDroiteDeLaFenetre-aireDeJeu.right < 156 + EpaisseurBordureOthellier() + decalageAuxiliaireVersLaDroite)
         then posHNoirs := aireDeJeu.right+3;
        
       
        
       posHBlancs := posHNoirs+80;
       posVBlancs := 25;
       if (genreAffichageTextesDansFenetrePlateau = kAffichageTresSerre)  | 
          (genreAffichageTextesDansFenetrePlateau = kAffichageUnPeuSerre) | 
          (limiteDroiteDeLaFenetre-aireDeJeu.right < 156 + EpaisseurBordureOthellier() + decalageAuxiliaireVersLaDroite)
        then
          begin
            if (genreAffichageTextesDansFenetrePlateau = kAffichageTresSerre) | 
               (limiteDroiteDeLaFenetre-aireDeJeu.right < 80 + EpaisseurBordureOthellier() + decalageAuxiliaireVersLaDroite)
              then posHNoirs := aireDeJeu.right+3
              else posHNoirs := aireDeJeu.right+20;
            posHBlancs := posHNoirs;
            if gVersionJaponaiseDeCassio & gHasJapaneseScript
              then posVBlancs := posVNoirs+33  {on met un peu plus de blanc car affichage en 12 points}
              else posVBlancs := posVNoirs+30;
          end;
      
       posHNoirs  := posHNoirs  + decalageAuxiliaireVersLaDroite;
       posHBlancs := posHBlancs + decalageAuxiliaireVersLaDroite;
       
       {on décale vers le bas parce que l'on affiche désormais un cadre autour de l'horloge}
       posVNoirs  := posVNoirs + 8;
       posVBlancs := posVBlancs + 8;
       
       
       {on met le bouton plutot en bas de l'othellier}
       if false then
         begin
           auxNoirs  := posVNoirs;
           auxBlancs := posVBlancs;
           posVBlancs := aireDeJeu.bottom - auxNoirs - 18;
           posVNoirs  := aireDeJeu.bottom - auxBlancs - 18;
         end;
         
     end;
end;


procedure SetPositionScore;
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    if CassioEstEn3D()
      then SetPositionScore3D
      else SetPositionScore2D;
      
      
  gHorlogeRect := CalculateHorlogeBoundingRect();
  
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      gHorlogeRectGlobal := gHorlogeRect;
      LocalToGlobalRect(gHorlogeRectGlobal);
      SetPort(oldPort);
    end;
end;




procedure SetPositionDemandeCoup2D;
var limiteDroiteDeLaFenetre : SInt16; 
begin
  {if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) 
     then
      begin
        posHDemande := 40;
        PosVDemande := aireDeJeu.bottom+50;
      end
     else}
      begin
        limiteDroiteDeLaFenetre := GetWindowPortRect(wPlateauPtr).right;
        posHDemande := aireDeJeu.right+20;
        
        
        if (limiteDroiteDeLaFenetre-aireDeJeu.right < 150 + EpaisseurBordureOthellier()) | 
           (genreAffichageTextesDansFenetrePlateau = kAffichageUnPeuSerre)
          then posHDemande := aireDeJeu.right+5;
          
          
        if (limiteDroiteDeLaFenetre-aireDeJeu.right < 130 + EpaisseurBordureOthellier()) | 
           (genreAffichageTextesDansFenetrePlateau = kAffichageTresSerre)
          then posHDemande := aireDeJeu.right+1;
        
        {on decale eventuellement a cause de la bordure}
        if garderPartieNoireADroiteOthellier | not(BordureOthellierEstUneTexture()) then
          if avecSystemeCoordonnees then  
            posHDemande := posHDemande + EpaisseurBordureOthellier() + 1;
            
        PosVDemande := aireDeJeu.bottom-9;
        
      end;
end;

procedure SetPositionDemandeCoup(fonctionAppelante : str255);
begin  {$UNUSED fonctionAppelante}
  if windowPlateauOpen then
	  if CassioEstEn3D()
	    then SetPositionDemandeCoup3D
	    else SetPositionDemandeCoup2D;
end;

procedure SetPositionMeilleureSuite2D;
begin
  posHMeilleureSuite := aireDeJeu.left   + 3;
  posVMeilleureSuite := aireDeJeu.bottom + 12;
end;


procedure SetPositionMeilleureSuite;
begin
  if windowPlateauOpen then
	  if CassioEstEn3D()
	    then SetPositionMeilleureSuite3D
	    else SetPositionMeilleureSuite2D;
end;



procedure SetAffichageVertical;
var doitredessiner : boolean;
    tempoGenreAffichage : SInt32;
begin
  doitredessiner := false;
  if windowPlateauOpen & not(CassioEstEn3D()) & (genreAffichageTextesDansFenetrePlateau <> kAffichageSousOthellier) then
    with VisibiliteInitiale do
      begin
        if (windowListeOpen | windowStatOpen) |
           (gPendantLesInitialisationsDeCassio & (tempowindowListeOpen | tempowindowStatOpen))
          then
            begin
              tempoGenreAffichage := genreAffichageTextesDansFenetrePlateau;
              
              { on essaie avec l'affichage aéré normal}
              genreAffichageTextesDansFenetrePlateau := kAffichageAere;
              SetPositionScore;
              SetPositionDemandeCoup('SetAffichageVertical {1}');
              SetPositionMeilleureSuite;
              
              if RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(GetWindowStructRect(wListePtr),gHorlogeRect) | 
                 RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(GetWindowStructRect(wStatPtr),gHorlogeRect) then
                begin
                  { on essaie avec l'affichage un peu serré près de l'othellier }
                  genreAffichageTextesDansFenetrePlateau := kAffichageUnPeuSerre;
                  SetPositionScore;
                  SetPositionDemandeCoup('SetAffichageVertical {2}');
                  SetPositionMeilleureSuite;
              
                  if RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(GetWindowStructRect(wListePtr),gHorlogeRect) | 
                     RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(GetWindowStructRect(wStatPtr),gHorlogeRect) then
                    begin
                      { on essaie avec l'affichage tres serré près de l'othellier }
                      genreAffichageTextesDansFenetrePlateau := kAffichageTresSerre;
                      SetPositionScore;
                      SetPositionDemandeCoup('SetAffichageVertical {3}');
                      SetPositionMeilleureSuite;
                    end;
                end;
              doitredessiner := true;
            end
          else
            begin
              { on met avec l'affichage aéré normal}
              if (genreAffichageTextesDansFenetrePlateau <> kAffichageAere) then
                begin
                  genreAffichageTextesDansFenetrePlateau := kAffichageAere;
                  SetPositionScore;
                  SetPositionDemandeCoup('SetAffichageVertical {4}');
                  SetPositionMeilleureSuite;
                  doitredessiner := true;
                end;
            end;
      end;
  if doitredessiner then 
    DessineAffichageVertical;
end;

procedure SetPositionsTextesWindowPlateau;
begin
  SetAffichageVertical;
  SetPositionScore;
  SetPositionDemandeCoup('SetPositionsTextesWindowPlateau');
  SetPositionMeilleureSuite;
end;


procedure DessineAffichageVertical;
var unRect : rect;
    oldPort : grafPtr;
begin
  if windowPlateauOpen & not(CassioEstEn3D()) & 
    (genreAffichageTextesDansFenetrePlateau <> kAffichageSousOthellier) & 
    not(EnModeEntreeTranscript()) then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      if not(enRetour | enSetUp) then
        begin
          DessineBordureDuPlateau2D(kBordureDeDroite);
          SetRect(unRect,aireDeJeu.right+EpaisseurBordureOthellier(),0,GetWindowPortRect(wPlateauPtr).right,aireDeJeu.bottom);
          EraseRectDansWindowPlateau(unRect);
          PrepareTexteStatePourHeure;
          AfficheScore;
          EcritPromptFenetreReflexion;
          if afficheMeilleureSuite & not(MeilleureSuiteEffacee) then EcritMeilleureSuite;
          DessineBoiteDeTaille(wPlateauPtr);
          dernierTick := TickCount();
          Heure(pionNoir);
          Heure(pionBlanc); 
          DrawClockBoundingRect(gHorlogeRect,10);
        end;
      
      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
        
      SetPort(oldPort);
    end;
end;

function GetTailleCaseCourante() : SInt32;
begin
  GetTailleCaseCourante := gTailleCase.private;
end;


procedure SetTailleCaseCourante(taille : SInt32);
begin
  gTailleCase.private := taille;
end;


function TailleCaseIdeale() : SInt16; 
var aux : SInt16; 
    unRect : rect;
    tailleIdealeHorizontale : SInt16; 
    tailleIdealeVerticale : SInt16; 
begin
  if not(windowPlateauOpen) 
    then TailleCaseIdeale := 37
    else 
      begin
        unRect := GetWindowPortRect(wPlateauPtr);
        
        
        aux := unRect.bottom-unRect.top;
        if avecSystemeCoordonnees
          then aux := aux-PositionCoinAvecCoordonnees
          else aux := aux-PositionCoinSansCoordonnees;
        aux := aux - 12;
        tailleIdealeVerticale := aux div 8;
        
        
        aux := unRect.right-unRect.left;
        if EnModeEntreeTranscript()
          then 
            begin
              aux := (aux - RoundToL(3.7*EpaisseurBordureOthellier())) div 2;
              tailleIdealeHorizontale := aux div 8;
            end
          else
            begin
              if avecSystemeCoordonnees
                then aux := aux-PositionCoinAvecCoordonnees-10
                else aux := aux-PositionCoinSansCoordonnees-1;
              tailleIdealeHorizontale := aux div 8;
            end;
        
        TailleCaseIdeale := Min(tailleIdealeVerticale,tailleIdealeHorizontale);
      end;
end;

procedure AjusteAffichageFenetrePlat(tailleCaseForcee : SInt16; var tailleCaseChange,positionscorechange : boolean);
var tailleCasePrec : SInt16; 
    genreAffichagePrec : SInt32;
    posHblancprec,posHNoirprec,posVblancprec,posVnoirprec : SInt16; 
begin
  tailleCasePrec := GetTailleCaseCourante();
  genreAffichagePrec := genreAffichageTextesDansFenetrePlateau;
  posHblancprec := posHBlancs;
  posHNoirprec := posHNoirs;
  posVblancprec := posVBlancs;
  posVnoirprec := posVNoirs;
  
  if (tailleCaseForcee > 0)
    then SetTailleCaseCourante(tailleCaseForcee)
    else SetTailleCaseCourante(TailleCaseIdeale());
  if avecSystemeCoordonnees
    then SetPositionPlateau2D(8,GetTailleCaseCourante(),PositionCoinAvecCoordonnees,PositionCoinAvecCoordonnees,'AjusteAffichageFenetrePlat')
    else SetPositionPlateau2D(8,GetTailleCaseCourante(),PositionCoinSansCoordonnees,PositionCoinSansCoordonnees,'AjusteAffichageFenetrePlat');
  SetPositionsTextesWindowPlateau;
  tailleCaseChange := (GetTailleCaseCourante()<>tailleCasePrec);
  positionscorechange := (genreAffichagePrec <> genreAffichageTextesDansFenetrePlateau) |
                      (posHBlancs<>posHblancprec) |
                      (posHNoirs<>posHNoirprec) |
                      (posVBlancs<>posVblancprec) |
                      (posVNoirs<>posVnoirprec);
end;

procedure AjusteAffichageFenetrePlatRapide;
var foo : boolean;
begin
  AjusteAffichageFenetrePlat(0,foo,foo);
end;


procedure AjusteTailleFenetrePlateauPourLa3D;
var tailleActuelle,tailleDesiree : Point;
    nouvelleTaille : Point;
    tailleCaseChange,infosChangent : boolean;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) & CassioEstEn3D() then
    begin
      tailleActuelle := GetWindowSize(wPlateauPtr);
      tailleDesiree := GetTailleImagesPovRay();
      
      if (tailleActuelle.h <> tailleDesiree.h) | (tailleActuelle.v <> tailleDesiree.v) then 
        begin
          nouvelleTaille := tailleDesiree;
          
          {nouvelleTaille.h := Min(tailleActuelle.h,tailleDesiree.h);
          nouvelleTaille.v := Min(tailleActuelle.v,tailleDesiree.v);}
          
          SizeWindow(wPlateauPtr,nouvelleTaille.h,nouvelleTaille.v,false);
          AjusteAffichageFenetrePlat(0,tailleCaseChange,infosChangent);
        end;
    end;
end;

procedure AfficheScore;
var s1,s2 : string;
    oldPort : grafPtr;
    ligneRect : rect;
begin
 if windowPlateauOpen & not(EnModeEntreeTranscript()) then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr); 
     GetIndString(s1,TextesPlateauID,1);
     s1 := s1+PourcentageEntierEnString(nbreDePions[pionNoir]);
     GetIndString(s2,TextesPlateauID,2);
     s2 := s2+PourcentageEntierEnString(nbreDePions[pionBlanc]);
     SetRect(lignerect,posHNoirs,posVNoirs-12,posHNoirs+67,posVNoirs);
     
     
     PrepareTexteStatePourHeure;
     if gVersionJaponaiseDeCassio & gHasJapaneseScript
       then TextSize(gCassioNormalFontSize);
       
     Moveto(posHNoirs,posVNoirs);
     
     EraseRectDansWindowPlateau(lignerect);
     DrawString(s1);
     SetRect(lignerect,posHBlancs,posVBlancs-12,posHBlancs+67,posVBlancs);
     Moveto(posHblancs,posVBlancs);
     
     EraseRectDansWindowPlateau(lignerect);
     DrawString(s2);   
     if gVersionJaponaiseDeCassio & gHasJapaneseScript
       then PrepareTexteStatePourHeure;
	   
	   if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
        
     SetPort(oldPort);
   end;
end;


function CalculateBordureRect(quelleBordure : SInt32;quelleTexture:CouleurOthellierRec) : rect;
var epaisseur,dx,dy : SInt32;
    unRect : rect;
begin

  epaisseur := EpaisseurBordureOthellier();
  
  if (quelleTexture.estUneTexture) & 
     (quelleTexture.nomFichierTexture = 'Photographique')
    then begin dx :=  0; dy := +1 end
    else begin dx :=  0; dy := 0  end;
    
  {bordure en haut}
  if BitAnd(quelleBordure,kBordureDuHaut) <> 0 then
    begin
      unRect := MakeRect(dx + aireDeJeu.left   - epaisseur, 
                         {dy + aireDeJeu.top    - epaisseur} 0,
                         dx + aireDeJeu.right  + epaisseur,
                         dy + aireDeJeu.top);
      CalculateBordureRect := unRect;
      exit(CalculateBordureRect);
    end;
  {bordure a gauche}
  if BitAnd(quelleBordure,kBordureDeGauche) <> 0 then
    begin
      unRect := MakeRect(dx + aireDeJeu.left   - epaisseur, 
                         dy + aireDeJeu.top    - epaisseur,
                         dx + aireDeJeu.left,
                         dy + aireDeJeu.bottom + 2 );
      CalculateBordureRect := unRect;
      exit(CalculateBordureRect);
    end;
  {bordure en bas}
  if BitAnd(quelleBordure,kBordureDuBas) <> 0 then
    begin
      unRect := MakeRect(dx + aireDeJeu.left   - epaisseur, 
                         dy + aireDeJeu.bottom - 1,
                         dx + aireDeJeu.right  + epaisseur,
                         dy + aireDeJeu.bottom + epaisseur + 2);
      CalculateBordureRect := unRect;
      exit(CalculateBordureRect);
    end;
  {bordure a droite}
  if BitAnd(quelleBordure,kBordureDeDroite) <> 0 then
    begin
      unRect := MakeRect(dx + aireDeJeu.right  - 1, 
                         dy + aireDeJeu.top    - epaisseur,
                         dx + aireDeJeu.right  + epaisseur ,
                         dy + aireDeJeu.bottom + epaisseur {- 1} + 2);
      CalculateBordureRect := unRect;
      exit(CalculateBordureRect);
    end;
  
  {default}
  CalculateBordureRect := MakeRect(0,0,0,0);
end;




procedure DessineBordureDuPlateau2D(quellesBordures : SInt32);
var couleurBordure : RGBColor;
    unRect : rect;
begin

  couleurBordure := NoircirCouleur(gCouleurOthellier.RGB);
  RGBForeColor(couleurBordure);
  
  {bordure en haut}
  if BitAnd(quellesBordures,kBordureDuHaut) <> 0 then
    begin
      if not(BordureOthellierEstUneTexture()) | (DrawBordureColorPict(kBordureDuHaut) <> NoErr) then
        FillRect(CalculateBordureRect(kBordureDuHaut,gCouleurOthellier),blackPattern);
    end;
    
  {bordure a gauche}
  if BitAnd(quellesBordures,kBordureDeGauche) <> 0 then
    begin
      if not(BordureOthellierEstUneTexture()) | (DrawBordureColorPict(kBordureDeGauche) <> NoErr) then
        FillRect(CalculateBordureRect(kBordureDeGauche,gCouleurOthellier),blackPattern);
    end;
    
  {bordure en bas}
  if BitAnd(quellesBordures,kBordureDuBas) <> 0 then
    begin
      if not(BordureOthellierEstUneTexture()) | (DrawBordureColorPict(kBordureDuBas) <> NoErr) then
        FillRect(CalculateBordureRect(kBordureDuBas,gCouleurOthellier),blackPattern);
    end;
    
  {bordure a droite}
  if BitAnd(quellesBordures,kBordureDeDroite) <> 0 then
    begin
      if not(BordureOthellierEstUneTexture()) | (DrawBordureColorPict(kBordureDeDroite) <> NoErr) then
        FillRect(CalculateBordureRect(kBordureDeDroite,gCouleurOthellier),blackPattern);
      DrawClockBoundingRect(gHorlogeRect,10);
    end;
    
  ForeColor(BlackColor);
  BackColor(WhiteColor);
  
  {trait noir autour de l'othellier}
  if not(gCouleurOthellier.estUneTexture) then 
    begin
      unRect := aireDeJeu;
      Pensize(1,1);
      FrameRect(unRect);
    end;
  
end;


procedure EffacePromptFenetreReflexion;
var oldPort : grafPtr;
    ligneRect : rect;
begin
  if windowPlateauOpen & not(EnModeEntreeTranscript()) then
	  begin
		  GetPort(oldPort);
		  SetPortByWindow(wPlateauPtr);
		  SetPositionDemandeCoup('EffacePromptFenetreReflexion');
		  if CassioEstEn3D()
		    then SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3)
		    else SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3);
		  EraseRectDansWindowPlateau(lignerect);
		  if PosVDemande>=GetWindowPortRect(wPlateauPtr).bottom-19 then DessineBoiteDeTaille(wPlateauPtr);
		  SetPort(oldPort);
		end;
end;

procedure AfficheDemandeCoup;
var oldPort : grafPtr;
    s : str255;
    ligneRect : rect;
begin
 if not(EnModeEntreeTranscript()) then
   begin
     if CassioEstEnModeAnalyse() & not(HumCtreHum) & (nbreCoup > 0)
       then
         EcritJeReflechis(aQuiDeJouer)
       else
    		 if windowPlateauOpen then
    		   begin
    		     GetPort(oldPort);
    		     SetPortByWindow(wPlateauPtr);
    		     SetPositionDemandeCoup('afficheDemandeCoup');
    		     PrepareTexteStatePourDemandeCoup;
    		     if CassioEstEn3D()
    		       then SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3)
    		       else SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3);
    		     EraseRectDansWindowPlateau(lignerect);
    		     Moveto(posHDemande,PosVDemande);
    		     case aQuiDeJouer of
    		       pionNoir:GetIndString(s,TextesPlateauID,3);   {Votre coup, Noir}
    		       pionBlanc:GetIndString(s,TextesPlateauID,4);  {Votre coup, Blanc}
    		       otherwise     s := '';
    		     end;
    		     DrawString(s);
    		     if PosVDemande>=GetWindowPortRect(wPlateauPtr).bottom-19 then DessineBoiteDeTaille(wPlateauPtr);
    		     
    		     
    		     if gCassioUseQuartzAntialiasing then
               if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
    	         
    		     SetPort(oldPort);
    		   end;
   end;
end;


procedure EcritJeReflechis(coulChoix : SInt16);
var oldPort : grafPtr;
    s : str255;
    ligneRect : rect;
begin
 if not(EnModeEntreeTranscript()) then
   begin
     if not(DoitPasser(coulChoix,jeuCourant,emplJouable)) then
       begin
        if windowPlateauOpen then
          begin
            GetPort(oldPort);
            SetPortByWindow(wPlateauPtr); 
            SetPositionDemandeCoup('EcritJeReflechis');
            PrepareTexteStatePourDemandeCoup;
            if CassioEstEn3D()
    		      then SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3)
    		      else SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3);
            EraseRectDansWindowPlateau(lignerect);
            Moveto(posHDemande,PosVDemande);
            s := '';
            case coulChoix of
                pionNoir    : 
    			         if CassioEstEnModeAnalyse() & not(analyseRetrograde.enCours) & not(CassioEstEnModeSolitaire())
    			           then GetIndString(s,TextesPlateauID,19)  {Analyse pour Noir}
    			           else GetIndString(s,TextesPlateauID,5);  {Je réflechis au choix des Noirs}
    		        pionBlanc   : 
    		           if CassioEstEnModeAnalyse() & not(analyseRetrograde.enCours) & not(CassioEstEnModeSolitaire())
    		             then GetIndString(s,TextesPlateauID,20)  {Analyse pour Blanc}
    		             else GetIndString(s,TextesPlateauID,6);  {Je réflechis au choix des Blancs}
            end;
            DrawString(s);
            if PosVDemande>=GetWindowPortRect(wPlateauPtr).bottom-19 then DessineBoiteDeTaille(wPlateauPtr);
            
            
            if gCassioUseQuartzAntialiasing then
              if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
    	        
            SetPort(oldPort);
          end;
       end;
   end;
end;

procedure EcritPromptFenetreReflexion;
begin
  if not(EnModeEntreeTranscript()) then
    begin
      if gameOver
        then
          EffacePromptFenetreReflexion
        else
    		  if not(HumCtreHum) & (aQuiDeJouer=couleurMacintosh)
    		    then EcritJeReflechis(aQuiDeJouer)
    		    else AfficheDemandeCoup;
    end;
end;


function GetRectOfSquare2DDansAireDeJeu(whichSquare,QuelGenreDeMarque : SInt16) : rect;
var x,y,a,b : SInt16; 
   result : rect;
begin
  {$UNUSED QuelGenreDeMarque}
  x := platmod10[whichSquare];
  y := platdiv10[whichSquare];
  a := aireDeJeu.left+2+GetTailleCaseCourante()*(x-1);
  b := aireDeJeu.top+2+GetTailleCaseCourante()*(y-1);
  SetRect(result,a,b,a+GetTailleCaseCourante()-3,b+GetTailleCaseCourante()-3);
  GetRectOfSquare2DDansAireDeJeu := result;
end;

function GetBoundingRectOfSquare(whichSquare : SInt16) : rect;
begin
  if CassioEstEn3D()
    then GetBoundingRectOfSquare := GetBoundingRect3D(whichSquare)
    else GetBoundingRectOfSquare := GetRectOfSquare2DDansAireDeJeu(whichSquare,0);
end;


function GetOthellier2DVistaBuffer() : rect;
begin
  GetOthellier2DVistaBuffer := aireDeJeu;
end;

function GetOthellierVistaBuffer() : rect;
begin
  if CassioEstEn3D() 
    then GetOthellierVistaBuffer := GetOthellier3DVistaBuffer()
    else GetOthellierVistaBuffer := GetOthellier2DVistaBuffer();
end;

procedure ChangeRectOfSquarePourPicture(var theRect : rect);
begin
  with theRect do
   begin
    top := top-2;
    left := left-2;
    inc(right);
    inc(bottom);
  end;
  if (gCouleurOthellier.nomFichierTexture = 'Photographique') then OffsetRect(theRect,0,1); 
end;

var dernierTickCopyBits : SInt32;


procedure DessineContourDeCase2D(whichRect : rect;square : SInt32);
var couleurOthellierClaire : RGBColor;
    couleurOthellierFoncee : RGBColor;
begin
  if retirerEffet3DSubtilOthellier2D & not(Pos('VOG',gCouleurOthellier.nomFichierTexture) > 0)
    then
      begin
        FrameRect(whichRect);
      end
    else
      begin
        couleurOthellierClaire := EclaircirCouleur(gCouleurOthellier.RGB);
			  couleurOthellierFoncee := NoircirCouleur(gCouleurOthellier.RGB);
			  
			  PenPat(blackPattern);
			  
			  {WritelnDansRapport('dans DessineContourDeCase2D…');}
			  with whichRect do
			    begin
			      {Dessin de l'éclairage :
	           on utilise la couleur de l'othellier, en plus clair }
			      RGBForeColor(couleurOthellierClaire);
	          Moveto(right-1,top+1);
	          Lineto(left+1,top+1);
	          
	          Moveto(left+1,top+1);
	          Lineto(left+1,bottom-1);
	          
	          {Dessin de l'ombrage :
	           sur la colonne H et la ligne 8, et si la bordure est dessinee,
	           il faut utiliser du noir a cause du cadre autour de l'othellier.
	           Sinon on utilise la couleur de l'othellier, en plus foncé }
	          if avecSystemeCoordonnees & (square div 10 = 8) & not(gCouleurOthellier.estUneTexture)
	            then ForeColor(BlackColor)
	            else RGBForeColor(couleurOthellierFoncee);
	          Moveto(left+1,bottom-1);
	          Lineto(right-1,bottom-1);
	          
	          if avecSystemeCoordonnees & (square mod 10 = 8) & not(gCouleurOthellier.estUneTexture)
	            then ForeColor(BlackColor)
	            else RGBForeColor(couleurOthellierFoncee);
	          Moveto(right-1,bottom-2);
	          Lineto(right-1,top+1);
	          
			    end;
			    
			  ForeColor(BlackColor);
			  
      end;
end;

procedure DessinerEventuellementContoursDesCasesTexturees(whichRect : rect;whichSquare : SInt16);
begin
  if ((Pos('VOG',gCouleurOthellier.nomFichierTexture) > 0) {| (Pos('Pions go',gCouleurOthellier.nomFichierTexture) > 0)})
    then 
    begin
      {if (Pos('Pions go',gCouleurOthellier.nomFichierTexture) > 0) then
        begin
          Dec(whichRect.top);
          Dec(whichRect.left);
        end;}
      DessineContourDeCase2D(whichRect,whichSquare);
    end;
end;

procedure DessinePion2D(square,valeurPion : SInt16);
var rectangle : rect;
    a : SInt16; 
begin
  rectangle := GetRectOfSquare2DDansAireDeJeu(square,0);
  
  case valeurPion of
    kCaseDevantEtreRedessinee :
       begin
         {if not(gCouleurOthellier.estUneTexture) then DessinePion2D(square,pionVide);}
         {TraceLog(Concat('DessinePion2D : kCaseDevantEtreRedessinee, case = ',NumEnString(square)));}
         
         SetOthellierEstSale(square,true);
         case jeuCourant[square] of
           pionBlanc,pionNoir: 
             begin
               DessinePion2D(square,jeuCourant[square]);
               if afficheNumeroCoup then DessineNumeroDernierCoupSurOthellier([square],GetCurrentNode());
               AfficheProprietesOfCurrentNode(false,[square],'DessinePion2D {1}');
             end;
           otherwise
             begin
               DessinePion2D(square,pionVide);
               if aideDebutant then DessineAideDebutant(false,[square]);
               {TraceLog('avant DessineAutresInfosSurCasesAideDebutant dans DessinePion2D');}
               DessineAutresInfosSurCasesAideDebutant([square]);
             end;
         end;
       end;
         
    pionBlanc:
         if gCouleurOthellier.estUneTexture
           then 
             begin
               if GetValeurDessinEnTraceDeRayon(square)<>pionBlanc then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(1+NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionBlanc);
                 end;
             end
           else
		         begin
		           {DessinePion2D(square,pionVide);}
		           PenSize(1,1);
		           
		           if not(retirerEffet3DSubtilOthellier2D) then
		             begin
		               rectangle.left := rectangle.left +1;
		               rectangle.top  := rectangle.top + 1;
		             end;
		           {FillOval(rectangle,whitePattern);
		           ForeColor(BlackColor);
		           FrameOval(rectangle);}
		             
		           {DessinePionsAntiAliase2D(rectangle,pionBlanc,80,1,GetWindowPort(wPlateauPtr));}
		           DrawBufferedColorPict(2,rectangle,gCouleurOthellier);
		           SetValeurDessinEnTraceDeRayon(square,pionBlanc);
		         end;
		         
    pionNoir:
        if gCouleurOthellier.estUneTexture
           then 
             begin
               if GetValeurDessinEnTraceDeRayon(square)<>pionNoir then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(2+NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionNoir);
                 end;
             end
           else
         begin
           {DessinePion2D(square,pionVide);}
           PenSize(1,1);
           if not(retirerEffet3DSubtilOthellier2D) then
             begin
               rectangle.left := rectangle.left +1;
               rectangle.top  := rectangle.top + 1;
             end;
           {FillOval(rectangle,blackPattern);}
           PenPat(blackPattern);
           {DessinePionsAntiAliase2D(rectangle,pionNoir,80,1,GetWindowPort(wPlateauPtr));}
           DrawBufferedColorPict(1,rectangle,gCouleurOthellier);
           SetValeurDessinEnTraceDeRayon(square,pionNoir);
         end;
      
    pionVide:
        if gCouleurOthellier.estUneTexture
           then 
             begin
               if GetValeurDessinEnTraceDeRayon(square) <> pionVide then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionVide);
                   SetOthellierEstSale(square,false);
                 end;
             end
           else
         begin
           InsetRect(rectangle,-1,-1);
           ForeColor(gCouleurOthellier.couleurFront);
           BackColor(gCouleurOthellier.couleurBack);
           RGBForeColor(gCouleurOthellier.RGB);
           if retirerEffet3DSubtilOthellier2D | enSetUp
             then
               begin
                 FillRect(rectangle,gCouleurOthellier.whichPattern);
               end
             else
               begin
                 rectangle.left := rectangle.left + 1;
                 rectangle.top  := rectangle.top + 1;
                 FillRect(rectangle,gCouleurOthellier.whichPattern);
                 rectangle.left := rectangle.left - 1;
                 rectangle.top  := rectangle.top - 1;
               end;
           ForeColor(BlackColor);
           BackColor(WhiteColor);
           InsetRect(rectangle,-1,-1);
           DessineContourDeCase2D(rectangle,square);
           if SquareInSquareSet(square,[22,23,32,33,26,27,36,37,62,63,72,73,66,67,76,77]) 
             then DessineAnglesCarreCentral;
           SetValeurDessinEnTraceDeRayon(square,pionVide);
           SetOthellierEstSale(square,false);
         end;
      
      pionEffaceCaseLarge:
        if gCouleurOthellier.estUneTexture
           then 
             begin
               if GetValeurDessinEnTraceDeRayon(square) <> pionVide then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionVide);
                   SetOthellierEstSale(square,false);
                 end;
             end
           else
         begin
           InsetRect(rectangle,-1,-1);
           ForeColor(gCouleurOthellier.couleurFront);
           BackColor(gCouleurOthellier.couleurBack);
           RGBForeColor(gCouleurOthellier.RGB);
           FillRect(rectangle,gCouleurOthellier.whichPattern);
           ForeColor(BlackColor);
           BackColor(WhiteColor);
           InsetRect(rectangle,-1,-1);
           DessineContourDeCase2D(rectangle,square);
           if SquareInSquareSet(square,[22,23,32,33,26,27,36,37,62,63,72,73,66,67,76,77]) 
             then DessineAnglesCarreCentral;
           SetValeurDessinEnTraceDeRayon(square,pionVide);
           SetOthellierEstSale(square,false);
         end;
      pionMontreCoupLegal:
         begin
           if gCouleurOthellier.estUneTexture
           then 
             begin
               if GetValeurDessinEnTraceDeRayon(square)<>pionMontreCoupLegal then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(3+NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionMontreCoupLegal);
                   SetOthellierEstSale(square,true);
                 end;
             end
           else
             begin
               if not(retirerEffet3DSubtilOthellier2D) then
		             begin
		               rectangle.left := rectangle.left +1;
		               rectangle.top  := rectangle.top + 1;
		             end;
		           if gEcranCouleur
		             then
		               begin
		                 DrawBufferedColorPict(3,rectangle,gCouleurOthellier);
		                 
		                 ForeColor(BlackColor);
		                 BackColor(WhiteColor);
		               end
		             else
		               begin
		                 InSetRect(rectangle,1,1);
		                 InsetRect(rectangle,1,1);
		                 InvertOval(rectangle);
		               end;
		           SetValeurDessinEnTraceDeRayon(square,pionMontreCoupLegal);
		         end;
           SetOthellierEstSale(square,true);
         end;
      pionSuggestionDeCassio:
        begin
         if gCouleurOthellier.estUneTexture
	         then 
	           begin
	             if GetValeurDessinEnTraceDeRayon(square)<>pionSuggestionDeCassio then
	               begin
	                 ChangeRectOfSquarePourPicture(rectangle);
	                 DrawBufferedColorPict(4+NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
	                 DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
	                 SetValeurDessinEnTraceDeRayon(square,pionSuggestionDeCassio);
	                 SetOthellierEstSale(square,true);
	               end;
	           end 
	         else
	           begin
	             if not(retirerEffet3DSubtilOthellier2D) then
		             begin
		               rectangle.left := rectangle.left +1;
		               rectangle.top  := rectangle.top + 1;
		             end;
		           if gEcranCouleur 
		             then 
		               begin
		                 DrawBufferedColorPict(4,rectangle,gCouleurOthellier);
		                 {
		                 ForeColor(gCouleurOthellier.couleurFront);
		                 if gCouleurOthellier.estTresClaire
			                 then BackColor(BlackColor)
			                 else
					               if (gCouleurOthellier.menuCmd = VertSapinCmd)     |
					                  (gCouleurOthellier.menuCmd = VertTurquoiseCmd)
					                  then BackColor(WhiteColor)
					                  else BackColor(gCouleurOthellier.couleurBack);}
		               end
		             else 
		               begin
		                 InsetRect(rectangle,1,1);
					           for a := 1 to (GetTailleCaseCourante() div 2) do
					             begin
					               if odd(a) 
					                 then PenPat(pionInversePat)
					                 else PenPat(InversePionInversePat);
					               FrameOval(rectangle);
					               InsetRect(rectangle,1,1);
					             end;
					         end;
		           ForeColor(BlackColor);
		           BackColor(WhiteColor);
		           PenPat(blackPattern);
		           SetValeurDessinEnTraceDeRayon(square,pionSuggestionDeCassio);
		         end;
          SetOthellierEstSale(square,true);
        end;
      petitpion:
        begin
          InsetRect(rectangle,8,8);
          InvertOval(rectangle);
          SetOthellierEstSale(square,true);
        end;
      (*
      pionEntoureCasePourMontrerCoupEnTete:
        begin       
	        InsetRect(rectangle,-1,-1);
	        PenPat(blackPattern);
	        PenSize(1,1);
	        ForeColor(BlackColor);
	        {FrameRect(rectangle);} {c'est l'ancienne methode}
	        with rectangle do       {c'est la nouvelle méthode}
	          begin
	            dec(right);
	            dec(bottom);
	            for j := 0 to 1 do
	              begin
	                i := (GetTailleCaseCourante() div 20);
	                if i>4 then i := 4;
	                if j=0 then a := 4+i else
	                if j=1 then a := i;
	                if a<1 then a := 1;
	                if (j=0) & (a>8) then a := 8;
	                if (j=1) & (a>4) then a := 4;
	                Moveto(left+j,top+a);
	                Lineto(left+j,top+j);
	                Lineto(left+a,top+j);
	                Moveto(right-j,top+a);
			            Lineto(right-j,top+j);
			            Lineto(right-a,top+j);
			            Moveto(left+j,bottom-a);
			            Lineto(left+j,bottom-j);
			            Lineto(left+a,bottom-j);
			            Moveto(right-j,bottom-a);
			            Lineto(right-j,bottom-j);
			            Lineto(right-a,bottom-j);
			          end;
	          end;
	        SetOthellierEstSale(square,true);
	      end;
	    pionEntoureCasePourEffacerCoupEnTete:
        begin       
          if gCouleurOthellier.estUneTexture
	          then 
	            begin
	              a := GetValeurDessinEnTraceDeRayon(square);
	              if a<>pionEntoureCasePourEffacerCoupEnTete then
	                begin
	                  InvalidateDessinEnTraceDeRayon(square);
	                  DessinePion2D(square,a);
	                end;
	            end 
	          else
	            begin
				        InsetRect(rectangle,-1,-1);
				        PenPat(gCouleurOthellier.whichPattern);
			          PenSize(1,1);
			          ForeColor(gCouleurOthellier.couleurFront);
			          BackColor(gCouleurOthellier.couleurBack);
			          RGBForeColor(gCouleurOthellier.RGB);
			          {FrameRect(rectangle);} {c'est ancienne methode}
			          with rectangle do       {c'est la nouvelle méthode}
				          begin
				            dec(right);
				            dec(bottom);
				            for j := 0 to 1 do
				              begin
				                i := (GetTailleCaseCourante() div 20);
				                if i>4 then i := 4;
				                if j=0 then a := 4+i else
				                if j=1 then a := i;
				                if a<1 then a := 1;
				                if (j=0) & (a>8) then a := 8;
				                if (j=1) & (a>4) then a := 4;
				                Moveto(left+j,top+a);
				                Lineto(left+j,top+j);
				                Lineto(left+a,top+j);
				                Moveto(right-j,top+a);
						            Lineto(right-j,top+j);
						            Lineto(right-a,top+j);
						            Moveto(left+j,bottom-a);
						            Lineto(left+j,bottom-j);
						            Lineto(left+a,bottom-j);
						            Moveto(right-j,bottom-a);
						            Lineto(right-j,bottom-j);
						            Lineto(right-a,bottom-j);
						          end;
						      end;
			          ForeColor(BlackColor);
			          BackColor(WhiteColor);
			          PenNormal;
			          PenPat(blackPattern);
				        SetOthellierEstSale(square,true);
				        DessineAnglesCarreCentral;
				      end;
	      end;*)
   end; 
   
end;



procedure ApprendPolygonePionDelta(r : rect);
var EchelleRect : rect;
    p1,p2,p3 : Point;
begin

  SetRect(EchelleRect,-11000,-11500,11000,10500);
  SetPt(p1,    0, -10000);   { p1 := (   0.0 ,  1.0 ) , et le signe est changé a cause de QuickDraw}
  SetPt(p2, 8660,   5000);   { p2 := (  √3/2 , -0.5 ) }
  SetPt(p3,-8600,   5000);   { p3 := ( -√3/2 , -0.5 ) }

  InsetRect(r,1,1);
  with r do
    begin
      right := right-1;
      bottom := bottom-1;
      
      MapPt(p1,EchelleRect,r);
      MapPt(p2,EchelleRect,r);
      MapPt(p3,EchelleRect,r);

      Moveto(p1.h,p1.v);
      Lineto(p2.h,p2.v);
      Lineto(p3.h,p3.v);
      Lineto(p1.h,p1.v);
      {
      Moveto((left+right) div 2,top);
      Lineto(right,bottom);
      Lineto(left,bottom);
      Lineto((left+right) div 2,top);
      }
    end;
end;

procedure ApprendPolygonePionLosange(r : rect);
begin
  InsetRect(r,1,1);
  with r do
    begin
      right := right-1;
      bottom := bottom-1;
      Moveto(left,(top+bottom) div 2);
      Lineto((left+right) div 2,top);
      Lineto(right,(top+bottom) div 2);
      Lineto((left+right) div 2,bottom);
      Lineto(left,(top+bottom) div 2);
    end;
end;

procedure ApprendPolygonePionCarre(r : rect);
var aux : SInt16; 
begin
  with r do
    begin
      right := right-1;
      bottom := bottom-1;
      aux := (right-left) div 4;
      InsetRect(r,aux,aux);
      Moveto(left,top);
      Lineto(right,top);
      Lineto(right,bottom);
      Lineto(left,bottom);
      Lineto(left,top);
    end;
end;

function CalculateRectOfPetitPion(r : rect) : rect;
var aux : SInt16; 
begin
  with r do
    begin
      aux := (right-left) div 3;
      InsetRect(r,aux,aux);
    end;
  CalculateRectOfPetitPion := r;
end;

function CalculateRectOfPionCroix(r : rect) : rect;
var aux : SInt16; 
begin
 with r do
    begin
      dec(right);
      dec(bottom);
      aux := (3*(right-left)) div 20;  {√2/2 = 0.707}
      InsetRect(r,aux+1,aux+1);
    end;
  CalculateRectOfPionCroix := r;
end;



procedure DessinePionSpecial(rectangle2D,dest : rect;quelleCase,valeurPion : SInt16; use3D : boolean);
var myPoly:polyHandle;
    myRect : rect;
    oldClipRgn,uneRgn : RgnHandle;
    s : str255;
    
    procedure ClipToViewArea(x : SInt16);
     {x est la case ou on veut Dessiner}
    var r : rect;
    begin
      oldclipRgn := NewRgn();
      uneRgn := NewRgn();
      GetClip(oldClipRgn);
      r := QDGetPortBound();
      OpenRgn;
      FrameRect(r);
      if (platdiv10[x] <= 7) then 
        if (jeuCourant[x+10] <> pionVide) then
          FrameOval(GetRect3DDessus(x+10));
      CloseRgn(uneRgn);
      SetClip(uneRgn);
    end;
  
  procedure DeClipToViewArea;
        (******  toujours faire aller avec ClipToViewArea   ****)
    begin
      SetClip(oldClipRgn);     
      DisposeRgn(oldclipRgn); 
      DisposeRgn(uneRgn);
    end;
    
begin
  myPoly := NIL;
  myPoly := OpenPoly;  
  case  valeurPion of
    PionDeltaTraitsBlancs,PionDeltaTraitsNoirs,
    PionDeltaNoir,PionDeltaBlanc                             : ApprendPolygonePionDelta(rectangle2D);
    PionLosangeTraitsBlancs,PionLosangeTraitsNoirs,
    PionLosangeNoir,PionLosangeBlanc                         : ApprendPolygonePionLosange(rectangle2D);
    PionCarreTraitsBlancs,PionCarreTraitsNoirs,
    PionCarreNoir,PionCarreBlanc                             : ApprendPolygonePionCarre(rectangle2D);
    PionPetitCercleTraitsBlancs,PionPetitCercleTraitsNoirs,
    PionPetitCercleNoir,PionPetitCercleBlanc                 : begin
                                                                 myRect := CalculateRectOfPetitPion(rectangle2D);
                                                                 MapRect(myRect,rectangle2D,dest);
                                                               end;
    PionEtoile                                               : begin
                                                                 myRect := rectangle2D;
                                                                 MapRect(myRect,rectangle2D,dest);
                                                               end;
    PionCroixTraitsBlancs,PionCroixTraitsNoirs               : begin
                                                                 myRect := CalculateRectOfPionCroix(rectangle2D);
                                                                 MapRect(myRect,rectangle2D,dest);    
                                                               end;
  end;
  ClosePoly;
  MapPoly(myPoly,rectangle2D,dest);
  
  
  PenNormal;
  PenSize(1,1);
  if use3D then ClipToViewArea(quelleCase);
  
  case valeurPion of
    PionDeltaBlanc   :
      begin
        FillPoly(myPoly,whitePattern);
        framePoly(myPoly);
      end;
    PionDeltaNoir    :
      begin
        FillPoly(myPoly,blackPattern);
        framePoly(myPoly);
      end;
    PionDeltaTraitsBlancs    :
      begin
        PenPat(whitePattern);
        framePoly(myPoly);
      end;
    PionDeltaTraitsNoirs    :
      begin
        PenPat(blackPattern);
        framePoly(myPoly);
      end;
    PionLosangeBlanc :
      begin
        FillPoly(myPoly,whitePattern);
        framePoly(myPoly);
      end;
    PionLosangeNoir  :
      begin
        FillPoly(myPoly,blackPattern);
        framePoly(myPoly);
      end;
    PionLosangeTraitsBlancs  :
      begin
        PenPat(whitePattern);
        framePoly(myPoly);
      end;
    PionLosangeTraitsNoirs  :
      begin
        PenPat(blackPattern);
        framePoly(myPoly);
      end;
    PionCarreBlanc   :
      begin
        FillPoly(myPoly,whitePattern);
        framePoly(myPoly);
      end;
    PionCarreNoir    :
      begin
        FillPoly(myPoly,blackPattern);
        framePoly(myPoly);
      end;
    PionCarreTraitsBlancs    :
      begin
        PenPat(whitePattern);
        framePoly(myPoly);
      end;
    PionCarreTraitsNoirs    :
      begin
        PenPat(blackPattern);
        framePoly(myPoly);
      end;
    PionEtoile       :
      with myRect do
        begin
          TextFace(bold);
          TextMode(3);
          s := '*';
          if JeuCourant[quelleCase] = pionNoir
            then DessineStringInRect(myRect,pionBlanc,s,quelleCase)
            else DessineStringInRect(myRect,pionNoir,s,quelleCase);
        end;
    PionCroixTraitsNoirs :
      with myRect do
        begin
          PenPat(blackPattern);
          Moveto(left,top);
          Lineto(right,bottom);
          Moveto(left,bottom);
          Lineto(right,top);
        end;
    PionCroixTraitsBlancs :
      with myRect do
        begin
          PenPat(whitePattern);
          Moveto(left,top);
          Lineto(right,bottom);
          Moveto(left,bottom);
          Lineto(right,top);
        end;
    PionPetitCercleBlanc :
      begin
        FillOval(myRect,whitePattern);
        FrameOval(myRect);
      end;
     PionPetitCercleNoir :
      begin
        FillOval(myRect,blackPattern);
        FrameOval(myRect);
      end;
    PionPetitCercleTraitsBlancs :
      begin
        PenPat(whitePattern);
        FrameOval(myRect);
      end;
    PionPetitCercleTraitsNoirs :
      begin
        PenPat(blackPattern);
        FrameOval(myRect);
      end;
  end;
  
  if use3D then DeClipToViewArea;
  
  KillPoly(myPoly);
  myPoly := NIL;
  
  PenNormal;
end;


procedure DrawJustifiedStringInRect(whichRect : rect;couleurDesLettres : SInt16; var s : str255;justification : SInt32;whichSquare : SInt16);
var a,b,haut,largeur : SInt16; 
    InfosPolice: fontinfo;
    smallRect : rect;
begin

  GetFontInfo(InfosPolice);
	with InfosPolice do
		haut := ascent + {descent +} leading;
		
  
  if couleurDesLettres = pionNoir  then TextMode(srcOr) else
	if couleurDesLettres = pionBlanc then TextMode(srcBic) 
		else TextMode(srcXor);
  
	 
	 with whichRect do
     begin
       
       largeur := StringWidth(s);
       
       {defaut = on centre}
       a := (left + right - largeur) div 2;
       b := (bottom + top + haut) div 2 ;
     
       {justification horizontale}
       if BitAnd(justification,kJusticationCentreHori) <> 0 then a := ((left + right - largeur) div 2) else
       if BitAnd(justification,kJusticationGauche) <> 0     then a := (left) else
       if BitAnd(justification,kJusticationDroite) <> 0     then a := (right - largeur);
       {justification verticale}
       if BitAnd(justification,kJusticationCentreVert) <> 0 then b := (-1 + (bottom + top + haut) div 2) else
       if BitAnd(justification,kJusticationBas) <> 0        then b := (bottom - 1) else
       if BitAnd(justification,kJusticationHaut) <> 0       then b := (top + haut + 1);
       
       smallRect := MakeRect(a, b - haut -1, a + largeur, b);
       
       if gCassioUseQuartzAntialiasing & doitEffacerSousLesTextesSurOthellier then
         RedessinerRectDansSquare(whichSquare,smallRect);
       
       if BitAnd(justification,kJustificationInverseVideo) <> 0 then
         begin
           OffSetRect(smallRect,0,(InfosPolice.descent+InfosPolice.leading) div 2);
           {InsetRect(smallRect,1,0);}
           InvertRect(smallRect);
         end;
       
       Moveto(a,b);
       DrawString(s);
       
     end;
end;

procedure DrawJustifiedStringInRectWithRGBColor(whichRect : rect; var s : str255;justification : SInt32;whichSquare : SInt16; color : RGBColor);
begin
  RGBForeColor(color);
  RGBBackColor(color);
  DrawJustifiedStringInRect(whichRect,pionNoir,s,justification,whichSquare);
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
end;

procedure DessineStringInRect(whichRect : rect;couleurDesLettres : SInt16; var s : str255;whichSquare : SInt16);
var haut : SInt32;
begin

  if ((whichRect.bottom - whichRect.top) <= 15)
     then 
       begin
         haut := 9;
         TextFont(MonacoID);
         TextSize(haut);
         TextFace(normal);
       end
     else
       begin
         if ((whichRect.bottom - whichRect.top) <= 25)
           then haut := gPoliceNumeroCoup.petiteTaille
           else haut := gPoliceNumeroCoup.grandeTaille;
         TextSize(haut);
         TextFont(gPoliceNumeroCoup.policeID);
         TextFace(gPoliceNumeroCoup.theStyle); 
       end;
    
	{
		  case quelleCouleur of
		    pionBlanc : WritelnDansRapport(' "'+s+'" blanc en'+CoupEnStringEnMajuscules(whichsquare))
		    pionNoir  : WritelnDansRapport(' "'+s+'" noir en'+CoupEnStringEnMajuscules(whichsquare))
		    otherwise   WritelnDansRapport(' "'+s+'" (couleur='+NumEnString(quellecouleur)+') en'+CoupEnStringEnMajuscules(whichsquare))
		  end;
	 }
	 
	 DrawJustifiedStringInRect(whichRect,couleurDesLettres,s,kJusticationCentreVert+kJusticationCentreHori,whichSquare);

end;

procedure DessineStringOnSquare(whichSquare,couleurDesLettres : SInt16; var s : str255; var continuer : boolean);
var myRect : rect;
    oldPort : grafPtr;
begin
  {$UNUSED continuer}
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      
		  if not(CassioEstEn3D())
		    then 
		      myRect := GetRectOfSquare2DDansAireDeJeu(whichSquare,0)
		    else
		      begin
		        if (jeuCourant[whichSquare] <> pionVide) 
		        
		           | (AttenteAnalyseDeFinaleDansPositionCourante() & (whichSquare = GetBestMoveAttenteAnalyseDeFinale()) &
		             (afficheSuggestionDeCassio | gDoitJouerMeilleureReponse | SuggestionAnalyseDeFinaleEstDessinee()))
		           
		           | (not(AttenteAnalyseDeFinaleDansPositionCourante() & (whichSquare <> GetBestMoveAttenteAnalyseDeFinale()))
		             & (gDoitJouerMeilleureReponse | afficheSuggestionDeCassio) & (whichSquare = meilleurCoupHum))
		            
		          then myRect := GetRectAreteVisiblePion3DPourPionDelta(whichSquare,0)
		          else myRect := GetRectPionDessous3DPourPionDelta(whichSquare,0);
		        OffSetRect(myRect,0,-1);
		      end;
		  
		  DessineStringInRect(myRect,couleurDesLettres,s,whichSquare);
		  InvalidateDessinEnTraceDeRayon(whichSquare);
		  SetOthellierEstSale(whichSquare,true);
		  
      SetPort(oldPort);
    end;
end;


procedure DessineLettreBlancheOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
var s : str255;
begin
  s := chr(codeAsciiDeLaLettre);
  DessineStringOnSquare(whichSquare,pionBlanc,s,continuer);
  codeAsciiDeLaLettre := succ(codeAsciiDeLaLettre);
end;

procedure DessineLettreNoireOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
var s : str255;
begin
  s := chr(codeAsciiDeLaLettre);
  DessineStringOnSquare(whichSquare,pionNoir,s,continuer);
  codeAsciiDeLaLettre := succ(codeAsciiDeLaLettre);
end;

procedure DessineLettreOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
begin
  DessineLettreNoireOnSquare(whichSquare,codeAsciiDeLaLettre,continuer);
end;


procedure DessinePion(square,valeurPion : SInt16);
begin
 if CassioEstEn3D()
   then
     begin
       if EnVieille3D()
         then WritelnDansRapport('pas d''appel à DessinePion3D dans DessinePion('+CoupEnString(square,true)+','+NumEnString(valeurPion)+')')
         else DessinePion3D(square,valeurPion);
     end
   else DessinePion2D(square,valeurPion); 
end;

procedure DessineAnglesCarreCentral;
var x,y : SInt16; 
    unRect : rect;
    oldPort : grafPtr;
begin
  if CassioEstEn3D() then 
    exit(DessineAnglesCarreCentral);
  
  if gCouleurOthellier.estUneTexture then
    exit(DessineAnglesCarreCentral);
  
  
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      
      if retirerEffet3DSubtilOthellier2D
        then ForeColor(BlackColor)
        else RGBForeColor(NoircirCouleur(gCouleurOthellier.RGB));
        
      x := aireDeJeu.left+2*GetTailleCaseCourante();
      y := aireDeJeu.top+2*GetTailleCaseCourante();
      SetRect(unRect,x-1,y-1,x+2,y+2);
      FillOval(unRect,blackPattern);
      x := x+4*GetTailleCaseCourante();
      SetRect(unRect,x-1,y-1,x+2,y+2);
      FillOval(unRect,blackPattern);
      y := y+4*GetTailleCaseCourante();
      SetRect(unRect,x-1,y-1,x+2,y+2);
      FillOval(unRect,blackPattern);
      x := x-4*GetTailleCaseCourante();
      SetRect(unRect,x-1,y-1,x+2,y+2);
      FillOval(unRect,blackPattern);
      
      ForeColor(BlackColor);
      SetPort(oldPort);
    end;
end;

procedure EffacerSquare(var whichSquare : SInt16; var continuer : boolean);
begin
  {$UNUSED continuer}
  if CassioEstEn3D() & not(enRetour)
    then DessinePion3D(whichSquare,effaceCase)
    else DessinePion2D(whichSquare,pionVide);
  {WritelnStringAndCoupDansRapport('EffacerSquare : ',whichsquare);}
end;


procedure RedessinerRectDansSquare(whichSquare : SInt16; whichRect : rect);
var valeurCase : SInt16; 
    oldClipRgn : RgnHandle;
    oldPort : grafPtr;
    tempoAffichageProprietesOfCurrentNode : SInt32;
    tempoAfficheNumeroCoup : boolean;
    valeurZebra : SInt32;
    oldTextFont,oldTextMode,oldTextSize : SInt16; 
    oldTextFace:ByteParameter;
begin
  if (whichSquare >= 11) & (whichSquare <= 88) then
    begin
		  GetPort(oldPort);
		  SetPortByWindow(wPlateauPtr);
		  
		  oldTextFont := GetPortTextFont(GetWindowPort(wPlateauPtr));
		  oldTextFace := GetPortTextFace(GetWindowPort(wPlateauPtr));
		  oldTextMode := GetPortTextMode(GetWindowPort(wPlateauPtr));
		  oldTextSize := GetPortTextSize(GetWindowPort(wPlateauPtr));
		  
		  
		  oldclipRgn := NewRgn();
		  GetClip(oldClipRgn);
		  ClipRect(whichRect);
		  
		  valeurCase := GetValeurDessinEnTraceDeRayon(whichSquare);
		  
		  tempoAffichageProprietesOfCurrentNode := GetAffichageProprietesOfCurrentNode();
		  tempoAfficheNumeroCoup := afficheNumeroCoup;
		  
		  SetAffichageProprietesOfCurrentNode(kAideDebutant + kPierresDeltas + kBibliotheque);
		  afficheNumeroCoup := false;
		  
		  DessinePion(whichSquare,valeurCase);
		  
		  if ZebraBookACetteOption(kAfficherCouleursZebraSurOthellier) then
		    begin
		      valeurZebra := GetNoteSurCase(kNotesDeZebra,whichSquare);
		      if EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(valeurZebra) then
		        DessineCouleurDeZebraBookDansRect(whichRect,aQuiDeJouer,valeurZebra);
		    end;
		  
		  
		  AfficheProprietesOfCurrentNode(false,[whichSquare],'RedessinerRectDansSquare');
		  
		  SetAffichageProprietesOfCurrentNode(tempoAffichageProprietesOfCurrentNode);
		  afficheNumeroCoup := tempoAfficheNumeroCoup;
		  
		  SetClip(oldClipRgn);    
		  DisposeRgn(oldclipRgn); 
		  
		  TextFont(oldTextFont);
		  TextMode(oldTextMode);
		  TextSize(oldTextSize);
		  TextFace(Style(oldTextFace));
		  
		  SetPort(oldPort);
		end;
end;


procedure SetPositionPlateau2D(nbrecases,tailleCase : SInt16; HG_h,HG_v : SInt16; fonctionAppelante : str255);
begin  {$UNUSED fonctionAppelante}
  SetRect(aireDeJeu,HG_h,HG_v,HG_h+1+nbrecases*tailleCase,HG_v+1+nbrecases*tailleCase);
end;



procedure DessineSystemeCoordonnees;
var d,a,HG_h,HG_v,i : SInt16; 
begin
  if enSetUp | not((genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) | CassioEstEn3D()) then
    begin
      
      DessineBordureDuPlateau2D(kBordureDeGauche + kBordureDeDroite + kBordureDuHaut + kBordureDuBas);
      d := -GetTailleCaseCourante() div 2;
      HG_h := aireDeJeu.left;
      HG_v := aireDeJeu.top-2;
      
      if BordureOthellierEstUneTexture()
        then a := HG_h - 11
        else a := HG_h - 10;
        
      if avecSystemeCoordonnees then
        begin
          PrepareTexteStatePourSystemeCoordonnees;
          FOR i := 1 TO 8 do
            begin
              d := d+GetTailleCaseCourante();
              
              Moveto(HG_h+d-2,HG_v-1);
              if CassioUtiliseDesMajuscules
                then DrawString(chr(64+i))
                else DrawString(chr(96+i));
                
              Moveto(a,HG_v+d+5);
              DrawString(chr(48+i));
            end;
        
          if gCassioUseQuartzAntialiasing then
            if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
        end;
      
      RGBForeColor(gPurNoir);
      RGBBackColor(gPurBlanc);
          
    end;
end;



procedure DessinePlateau2D(cases,tailleCase : SInt16; HG_h,HG_v : SInt16; avecDessinFondNoir : boolean);
var i,d : SInt16; 
    x,y : SInt16; 
    unRect : rect;
    couleurOthellierFoncee : RGBColor;
    couleurOthellierClaire : RGBColor;
begin
  if wPlateauPtr <> NIL then 
    begin
      PenPat(blackPattern);
      unRect := GetWindowPortRect(wPlateauPtr);
      
      x := HG_h+1+cases*tailleCase;
			y := HG_v+1+cases*tailleCase;
			SetPositionPlateau2D(cases,tailleCase,HG_h,HG_v,'DessinePlateau2D');
			      
      if avecDessinFondNoir then EffaceTouteLaFenetreSaufLOthellier;
      
      if gCouleurOthellier.estUneTexture then
        begin
          for x := 1 to 8 do
            for y := 1 to 8 do
              DessinePion2D(x*10+y,pionVide);
        end
        else
	        begin
			      
			      ForeColor(gCouleurOthellier.couleurFront);
			      BackColor(gCouleurOthellier.couleurBack);
			      RGBForeColor(gCouleurOthellier.RGB);
			      
			      couleurOthellierClaire := EclaircirCouleur(gCouleurOthellier.RGB);
			      couleurOthellierFoncee := NoircirCouleur(gCouleurOthellier.RGB);
			      
			      
			      DetermineOthellierPatSelonCouleur(gCouleurOthellier.menuCmd,gCouleurOthellier.whichPattern);
			      FillRect(aireDeJeu,gCouleurOthellier.whichPattern);
			      ForeColor(BlackColor);
			      BackColor(WhiteColor);
			      {ForeColor(WhiteColor);
			      BackColor(WhiteColor);}
			      FrameRect(aireDeJeu); 
			      
			      
			      if retirerEffet3DSubtilOthellier2D
			        then
			          begin
						      d := 0;
						      for i := 1 to cases do
						        begin
						          d := d+tailleCase;
						          Moveto(HG_h,HG_v+d);
						          Lineto(x-1,HG_v+d);
						          Moveto(HG_h+d,HG_v);
						          Lineto(HG_h+d,y-1);
						        end;
			          end
			        else
			          begin
			            {on dessine les ombrages}
			            
						      {horizontalement}
						      d := 0;
						      for i := 1 to cases do
						        begin
						          RGBForeColor(couleurOthellierClaire);
						          Moveto(HG_h+1,HG_v+d+1);
						          Lineto(x-1,HG_v+d+1);
						          d := d+tailleCase;
						        end;
						     
						      {verticalement}
						      d := 0;
						      for i := 1 to cases do
						        begin
						          RGBForeColor(couleurOthellierClaire);
						          Moveto(HG_h+d+1,HG_v+1);
						          Lineto(HG_h+d+1,y-1);
						          d := d+tailleCase;
						        end;
						      
						      {horizontalement}
						      d := 0;
						      for i := 1 to cases do
						        begin
						          d := d+tailleCase;
						          RGBForeColor(couleurOthellierFoncee);
						          Moveto(HG_h+1,HG_v+d);
						          Lineto(x-1,HG_v+d);
						        end;
						     
						      {verticalement}
						      d := 0;
						      for i := 1 to cases do
						        begin
						          d := d+tailleCase;
						          RGBForeColor(couleurOthellierFoncee);
						          Moveto(HG_h+d,HG_v+1);
						          Lineto(HG_h+d,y-1);
						        end;
						        
						    end;
						     
			       
			      ForeColor(BlackColor);
			      BackColor(WhiteColor);
			      Moveto(HG_h+1,y); 
			      Line(cases*tailleCase,0);
			      Line(0,-cases*tailleCase);
			    end;
      
      if avecSystemeCoordonnees then DessineSystemeCoordonnees;
      DessineAnglesCarreCentral;
   end;
end;


procedure DessinePlateau(avecDessinFondNoir : boolean);
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      if CassioEstEn3D()  
        then DessinePlateau3D(avecDessinFondNoir)
        else DessinePlateau2D(8,GetTailleCaseCourante(),aireDeJeu.left,aireDeJeu.top,avecDessinFondNoir);
      SetPort(oldPort);
    end;
end;

procedure DessinePosition(var position : plateauOthello);
var i,t : SInt16; 
begin
  for t := 64 downto 1 do
    begin
     i := othellier[t];
     if (position[i] <> pionVide) | gCouleurOthellier.estUneTexture then DessinePion(i,position[i]);
    end;
end;

procedure DessinePetitCentre;
var i,t : SInt16; 
begin
  for t := 1 to 64 do
    begin
     i := othellier[t];
     DessinePion(i,jeuCourant[i]);
    end;
  for t := 1 to 8 do 
    DessinePion(casepetitcentre[t],petitPion);
end;

procedure PrepareTextModeAndSizePourDessineDiagramme(couleurDesChiffres : SInt16; var hauteur,decalageHor,decalageVert : SInt16);
var currentPort : grafPtr;
    couleurNumeroCoup : RGBColor;
begin
  if (GetTailleCaseCourante()<=20) & not(CassioEstEn3D()) 
   then 
     begin
       hauteur := 9;
       TextSize(hauteur);
       TextFont(CourierID);
       TextFace(normal); 
       decalageHor := 1;
       decalageVert := 0;
     end
   else
     begin
       if GetTailleCaseCourante()<=25
         then 
           begin
             hauteur := gPoliceNumeroCoup.petiteTaille;
             decalageHor := 1;
             decalageVert := 0;
           end
         else 
           begin
             hauteur := gPoliceNumeroCoup.grandeTaille;
             decalageHor := 0;
             decalageVert := -1;
           end;
       TextSize(hauteur);
       TextFont(gPoliceNumeroCoup.policeID);
       TextFace(gPoliceNumeroCoup.theStyle); 
     end;
     
  if not(gIsRunningUnderMacOSX) | ((GetTailleCaseCourante()<=20) & not(CassioEstEn3D()))
    then
		  case couleurDesChiffres of
		    pionNoir  : TextMode(srcOr);
		    pionBlanc : TextMode(srcBic);
		    otherwise   TextMode(srcXor);
		  end {case}
		else
		  begin
		    if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
		    case couleurDesChiffres of
			    pionNoir  : couleurNumeroCoup := CouleurCmdToRGBColor(NoirCmd);
			    pionBlanc : couleurNumeroCoup := CouleurCmdToRGBColor(BlancCmd);
			    otherwise   couleurNumeroCoup := CouleurCmdToRGBColor(BlancCmd);
		    end; {case}
		    TextMode(srcOr);
		    RGBForeColor(couleurNumeroCoup);
        RGBBackColor(couleurNumeroCoup);
		    GetPort(currentPort);
		    EnableQuartzAntiAliasingThisPort(currentPort,true);
		  end;
end;


procedure GetPositionCorrecteNumeroDuCoup2D(square : SInt16; var result : Point);
var decalage : Point;
begin
  if (GetTailleCaseCourante()<=25)
    then SetPt(decalage,1,0)
	  else SetPt(decalage,0,-1);
	SetPt(result,aireDeJeu.left+GetTailleCaseCourante()*(platmod10[square]-1)+GetTailleCaseCourante() div 2+decalage.h,
	             aireDeJeu.top+ GetTailleCaseCourante()*(platdiv10[square]-1)+GetTailleCaseCourante() div 2+decalage.v);
	if not(retirerEffet3DSubtilOthellier2D | gCouleurOthellier.estUneTexture) then
	  begin
	    inc(result.h);
	    inc(result.v);
	  end;
end;
      
procedure GetPositionCorrecteNumeroDuCoup(square : SInt16; var result : Point);
begin
  if CassioEstEn3D() 
    then GetPositionCorrecteNumeroDuCoup3D(square,result)
    else GetPositionCorrecteNumeroDuCoup2D(square,result);
end;



procedure DessineNumeroCoupSurCetteCasePourDiagramme2D(whichSquare,whichNumber,couleurDesChiffres : SInt16);
var s : str255;
    haut,decalageHor,decalageVert : SInt16; 
    where : Point;
begin
  PrepareTextModeAndSizePourDessineDiagramme(couleurDesChiffres,haut,decalageHor,decalageVert);  
  GetPositionCorrecteNumeroDuCoup2D(whichSquare,where);
  NumToString(whichNumber,s);
  Moveto(where.h - StringWidth(s) div 2, where.v + haut div 2);
  DrawString(s);
  
  (* Restore the correct front and back color for Copybits *)
  ForeColor(BlackColor);
  BackColor(WhiteColor);
  
  InvalidateDessinEnTraceDeRayon(whichSquare);
end;

procedure DessineNumeroCoupSurCetteCasePourDiagramme(whichSquare,whichNumber,couleurDesChiffres : SInt16);
begin
  if CassioEstEn3D()
    then DessineNumeroCoup(whichSquare,whichNumber,couleurDesChiffres,NIL)
    else DessineNumeroCoupSurCetteCasePourDiagramme2D(whichSquare,whichNumber,couleurDesChiffres);
end;


procedure DessineNumerosDeCoupsSurTousLesPionsSurDiagramme(jusquaQuelCoup : SInt16);
var i,square : SInt16; 
    oldPort : grafPtr;
begin
 if windowPlateauOpen then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);  
     
     if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then;
        
     for i := 1 to jusquaQuelCoup do
	     begin
	       square := GetNiemeCoupPartieCourante(i);
	       if (square <> coupInconnu) & (square>=11) & (square<=88) & 
	          ((partie^^[i].trait) = GetValeurDessinEnTraceDeRayon(square)) then
				       begin
				         if partie^^[i].trait = pionNoir
				           then DessineNumeroCoupSurCetteCasePourDiagramme(square,i,pionBlanc)
				           else DessineNumeroCoupSurCetteCasePourDiagramme(square,i,pionNoir);
				       end;
	     end;   
     
     
     if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
	     
     SetPort(oldPort);
   end;
end;

procedure DessineDiagramme(tailleCaseDiagramme : SInt16; clipRegion : RgnHandle;fonctionAppelante : str255);
var i,j,square,aux : SInt16; 
    oldPort : grafPtr;
    positionInitiale : plateauOthello;
    theClipRect,unRect : rect;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
    visibleRgn : RgnHandle;
begin
 {$UNUSED fonctionAppelante}
 if windowPlateauOpen then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);
     
     if clipRegion <> NIL
       then theClipRect := MyGetRegionRect(clipRegion)
       else 
         begin
           visibleRgn := NewRgn();
           theClipRect := MyGetRegionRect(GetWindowVisibleRegion(wPlateauPtr,visibleRgn));
           DisposeRgn(visibleRgn);
         end;
     
     {WritelnDansRapport('appel de DessineDiagramme par '+fonctionAppelante);}
     
     if not(CassioEstEn3D()) then EffaceTouteLaFenetreSaufLOthellier;
     InvalidateDessinEnTraceDeRayon(DerniereCaseJouee());
     
     if CassioEstEn3D() then DessinePlateau3D(false);
     if not(gCouleurOthellier.estUneTexture)
       then 
         begin 
           DessinePlateau2D(8,tailleCaseDiagramme,aireDeJeu.left,aireDeJeu.top,true)
         end
       else 
         begin
           for i := 1 to 8 do
             for j := 1 to 8 do
               if jeuCourant[i*10+j] = pionVide then
               begin
                 square := 10*i+j;
                 unRect := GetBoundingRectOfSquare(square);
                 if not(CassioEstEn3D()) then ChangeRectOfSquarePourPicture(unRect);
                 if SectRect(unRect,theClipRect,bidRect) then
                   begin
                     if clipRegion <> NIL then InvalidateDessinEnTraceDeRayon(square);
                     DessinePion(square,jeuCourant[square]);
                   end;
               end;
           if avecSystemeCoordonnees then DessineSystemeCoordonnees; 
         end;
     
     
     
     GetPositionInitialeOfGameTree(positionInitiale,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
     for i := 64 downto 1 do
       begin
         square := othellier[i];
         aux := positionInitiale[square];
         if (aux <> pionVide) then
           begin
             unRect := GetBoundingRectOfSquare(square);
             if not(CassioEstEn3D()) then ChangeRectOfSquarePourPicture(unRect);
             if SectRect(unRect,theClipRect,bidRect) then
               begin
                 if clipRegion <> NIL then InvalidateDessinEnTraceDeRayon(square);
                 DessinePion(square,aux);
               end;
           end;
       end; 
     
     
     if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then;
        
     for i := 1 to nbreCoup do
     begin
       square := GetNiemeCoupPartieCourante(i);
       if square <> coupInconnu then
       if InRange(square,11,88) then
       begin
         unRect := GetBoundingRectOfSquare(square);
         if not(CassioEstEn3D()) then ChangeRectOfSquarePourPicture(unRect);
         if SectRect(unRect,theClipRect,bidRect) then
           begin
             if clipRegion <> NIL then InvalidateDessinEnTraceDeRayon(square);
             DessinePion(square,partie^^[i].trait);
             DessineNumeroCoupSurCetteCasePourDiagramme(square,i,-partie^^[i].trait);
		       end;
       end;
     end;   
     
     if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
        
     SetPort(oldPort);
   end;
end;    
    

procedure Faitcalculs2DParDefaut;
  var HG_h,HG_v,x,y,cases : SInt16; 
  begin
    HG_h := 20;
    HG_v := 16;
    cases := 8;
    x := HG_h+1+cases*GetTailleCaseCourante();
    y := HG_v+1+cases*GetTailleCaseCourante();
    SetRect(aireDeJeu,HG_h,HG_v,x,y);
  end;
  
function GetDernierCoup() : SInt16; 
begin
  if (nbreCoup>0)
    then GetDernierCoup := DerniereCaseJouee()
    else GetDernierCoup := coupInconnu;
end;



procedure DessineNumeroCoup(square,n,couleurDesChiffres : SInt16; whichNode : GameTree);
var s : string;
    oldPort : grafPtr;
    haut,decalageHor,decalageVert : SInt16; 
    position : Point;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      if InRange(square,11,88) then
       begin
         NumToString(n,s);
         
         if afficheSignesDiacritiques & (whichNode <> NIL) then
           s := s + GetSignesDiacritiques(whichNode);
         
         PrepareTextModeAndSizePourDessineDiagramme(couleurDesChiffres,haut,decalageHor,decalageVert);  
         GetPositionCorrecteNumeroDuCoup(square,position);
         Moveto(position.h-StringWidth(s) div 2,position.v+haut div 2);
         DrawString(s);
         
         (* Restore the correct front and back color for Copybits *)
         ForeColor(BlackColor);
         BackColor(WhiteColor);
         
         InvalidateDessinEnTraceDeRayon(square);
       end;
       
      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
        
      SetPort(oldPort);
    end;
end;

procedure EffaceNumeroCoup(square,n : SInt16; whichNode : GameTree);
var s : string;
    oldPort : grafPtr;
    haut : SInt16; 
    position : Point;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      
      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then;
        
      if InRange(square,11,88) then
       begin
         if not(EnVieille3D()) 
           then
             begin
               InvalidateDessinEnTraceDeRayon(square);
               DessinePion(square,jeuCourant[square]);
             end
           else
             begin
			         NumToString(n,s);
			         if afficheSignesDiacritiques & (whichNode <> NIL) then
			           s := s + GetSignesDiacritiques(whichNode);
			         if (GetTailleCaseCourante()<=20) & not(CassioEstEn3D()) 
			           then 
				           begin
				             haut := 9;
				             TextFont(CourierID);
				             TextSize(haut);
				             TextFace(normal); 
				           end
				         else
				           begin
				             if GetTailleCaseCourante()<=25
					             then haut := gPoliceNumeroCoup.petiteTaille
					             else haut := gPoliceNumeroCoup.grandeTaille;
					           TextSize(haut);
			               TextFont(gPoliceNumeroCoup.policeID);
			               TextFace(gPoliceNumeroCoup.theStyle); 
					         end;
			         SetPortByWindow(wPlateauPtr);
			         GetPositionCorrecteNumeroDuCoup(square,position);
			         Moveto(position.h-StringWidth(s) div 2,position.v+haut div 2);
			         if jeuCourant[square] = pionNoir  then TextMode(srcOr) else
			         if jeuCourant[square] = pionBlanc then TextMode(srcBic) 
			           else TextMode(srcXor);
			         DrawString(s);
			       end;
       end;
      
      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
        
      SetPort(oldPort);
    end;
end;

(*
procedure DessineCoupEnTete;
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
  if (coupEnTete>=11) & (coupEnTete<=88) then 
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
	    if CassioEstEn3D()
	      then DessinePion3D(coupEnTete,pionEntoureCasePourMontrerCoupEnTete)
	      else DessinePion2D(coupEnTete,pionEntoureCasePourMontrerCoupEnTete);
      SetPort(oldPort);
    end;
end;


procedure EffaceCoupEnTete;
var oldPort : grafPtr;
    tempoCoupEnTete : SInt16; 
begin
  if (coupEnTete>=11) & (coupEnTete<=88) then 
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      tempoCoupEnTete := coupEnTete;
      SetCoupEnTete(0);
      if not(CassioEstEn3D())
	      then DessinePion2D(tempoCoupEnTete,pionEntoureCasePourEffacerCoupEnTete)
	      else 
	        begin
	          DessinePion3D(tempoCoupEnTete,pionEntoureCasePourEffacerCoupEnTete);
	          if EnVieille3D() then
	            begin
			          if jeuCourant[tempoCoupEnTete] <> pionVide then
			            begin  {algo du peintre}
			              DessinePion3D(tempoCoupEnTete,jeuCourant[tempoCoupEnTete]);
			              if ((tempoCoupEnTete+10)<=88) & (jeuCourant[tempoCoupEnTete+10] <> pionVide) then
			                DessineDessusPion3D(tempoCoupEnTete+10,jeuCourant[tempoCoupEnTete+10]);
				          end;
				      end;
	        end;
	    SetCoupEnTete(tempoCoupEnTete);
      SetPort(oldPort);
    end;
end;


procedure SetCoupEntete(square : SInt16);
begin
  coupEnTete := square;
end;
*)



{ Dans certains contextes, on voudra parfois afficher en gras
  le prompt des solitaires ("Noir joue et gagne…", etc.). On parse
  donc la chaine CommentaireSolitaire pour en extraire le prompt }
procedure ParserCommentaireSolitaire(commentaire : str255; var promptGras,resteDuCommentaire : str255);
var s : str255;
begin
  s := commentaire;
  
  promptGras := '';
  if (Pos(ReadStringFromRessource(TextesSolitairesID,1),s) = 1) then  {Noir joue et gagne…}
    begin
      promptGras := ReadStringFromRessource(TextesSolitairesID,1);
      Delete(s,1,Length(promptGras));
    end 
  else if (Pos(ReadStringFromRessource(TextesSolitairesID,2),s) = 1) then {Blanc joue et gagne…}
    begin
      promptGras := ReadStringFromRessource(TextesSolitairesID,2);
      Delete(s,1,Length(promptGras));
    end 
  else if (Pos(ReadStringFromRessource(TextesSolitairesID,3),s) = 1) then {Noir joue et annule…}
    begin
      promptGras := ReadStringFromRessource(TextesSolitairesID,3);
      Delete(s,1,Length(promptGras));
    end 
  else if (Pos(ReadStringFromRessource(TextesSolitairesID,4),s) = 1) then {Noir joue et annule…}
    begin
      promptGras := ReadStringFromRessource(TextesSolitairesID,4);
      Delete(s,1,Length(promptGras));
    end;

  resteDuCommentaire := s;
end;



procedure EcritCommentaireSolitaire;
var s,promptGras : str255;
    lignerect : rect;
    oldPort : grafPtr;
begin
  s := CommentaireSolitaire^^;
  
  
  { Quand la bordure de l'othellier est texturée, on affichera en gras
    le prompt des solitaires ("Noir joue et gagne…", etc.). On parse
    donc la chaine CommentaireSolitaire pour en extraire le prompt }
  if BordureOthellierEstUneTexture() 
    then ParserCommentaireSolitaire(s,promptGras,s)
    else promptGras := '';
                           
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      PrepareTexteStatePourCommentaireSolitaire;
      
      if not(CassioEstEn3D())
        then 
          begin
            SetRect(lignerect,posHMeilleureSuite {aireDeJeu.left-5},aireDeJeu.bottom,aireDeJeu.right+400,posVMeilleureSuite);
            if (gCouleurOthellier.nomFichierTexture = 'Photographique') then OffsetRect(lignerect,0,1);
          end
        else 
          SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,299,posVMeilleureSuite+2);
      if not(EnModeEntreeTranscript()) then EraseRectDansWindowPlateau(lignerect);
      if avecSystemeCoordonnees & not(CassioEstEn3D()) then DessineBordureDuPlateau2D(kBordureDuBas);
       
      Moveto(lignerect.left+8,lignerect.bottom-2);
      
      if (promptGras <> '') then  {faut-il ecrire le prompt en gras ?}
        begin
	        TextMode(srcBic);
          TextFace(bold);
          DrawString(promptGras);
        end;
        
      TextFace(normal);
      DrawString(s);
      if lignerect.bottom>=GetWindowPortRect(wPlateauPtr).bottom-20 then DessineBoiteDeTaille(wPlateauPtr);
      
      
      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
      
      SetPort(oldPort);
    end;
end;

procedure DessineGarnitureAutourOthellierPourEcranStandard;
var oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(wPlateauPtr);
  AjusteCurseur;
  AfficheScore;
  EcritPromptFenetreReflexion;
  if afficheMeilleureSuite & not(MeilleureSuiteEffacee) then EcritMeilleureSuite;
  if CassioEstEnModeSolitaire() then EcritCommentaireSolitaire;
  SetPort(oldPort);
end;


procedure DessineNumeroDernierCoupSurOthellier(surQuellesCases : SquareSet;whichNode : GameTree);
var whichSquare : SInt16; 
begin
  if (nbreCoup>0) & (nbreCoup<=64) then
    begin
      whichSquare := DerniereCaseJouee();
      if (whichSquare <> coupInconnu) & (jeuCourant[whichSquare] <> pionVide) &
         (whichSquare>=11) & (whichSquare<=88) &
         (whichSquare in surQuellesCases) 
        then DessineNumeroCoup(whichSquare,nbreCoup,-jeuCourant[whichSquare],whichNode);
    end;
end;

procedure EcranStandard(clipRegion : RgnHandle;forcedErase : boolean);
var oldPort : grafPtr;
    unRect,VisRect,theClipRect : rect;
    positionEffacee : boolean;
    i,j,x,aux : SInt16; 
    visibleRgn : RgnHandle;
begin
 if windowPlateauOpen then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);
     PrepareTexteStatePourHeure;
     
     visibleRgn := NewRgn();
     visRect := MyGetRegionRect(GetWindowVisibleRegion(wPlateauPtr,visibleRgn));
     DisposeRgn(visibleRgn);
     
     if clipRegion <> NIL
       then theClipRect := MyGetRegionRect(clipRegion)
       else theClipRect := visRect;
     
     {if clipRegion = NIL
       then WritelnDansRapport('clipRegion = NIL dans EcranStandard')
       else 
         with theClipRect do
           WritelnDansRapport('clipRegion= '+
                              '(left='+NumEnString(left)+
                              ', top='+NumEnString(top)+
                              ', right='+NumEnString(right)+
                              ', bottom='+NumEnString(bottom)+')');}
                           
     
     if not(CassioEstEn3D())
       then 
         begin
           if forcedErase | not(gCouleurOthellier.estUneTexture)
             then EraseRectDansWindowPlateau(theClipRect)
             else EffaceTouteLaFenetreSaufLOthellier;
           unRect := aireDeJeu;
         end
       else 
         if Calculs3DMocheSontFaits()
           then 
             begin
               EraseRect(visrect);
               unRect := GetOthellier3DVistaBuffer();
             end
           else unRect := GetWindowPortRect(wPlateauPtr);
     positionEffacee := SectRect(unRect,visRect,unRect);
     
     
     if enSetUp 
       then EcranStandardSetUp 
       else
         begin
             if not(positionEffacee)
              then 
                DessineSystemeCoordonnees
              else
                if CassioEstEn3D() then 
                   begin
                     DessinePlateau3D(not(Calculs3DMocheSontFaits()));
                     Dessine3D(jeuCourant,false);
                   end
                  else
                   begin
                     if not(gCouleurOthellier.estUneTexture) 
                       then
                         begin
                           DessinePlateau2D(8,GetTailleCaseCourante(),aireDeJeu.left,aireDeJeu.top,false);
                           DessinePosition(jeuCourant);
                         end
                       else
                         begin
                           for i := 1 to 8 do
                             for j := 1 to 8 do
                               begin
                                 x := 10*i+j;
                                 unRect := GetRectOfSquare2DDansAireDeJeu(x,0);
                                 ChangeRectOfSquarePourPicture(unRect);
                                 if SectRect(unRect,theClipRect,bidRect) then
                                   begin
                                     aux := GetValeurDessinEnTraceDeRayon(x);
                                     if (jeuCourant[x] = pionVide) & (clipRegion <> NIL) & 
                                        ((aux=pionSuggestionDeCassio) | (aux=pionMontreCoupLegal))
                                          then
                                            begin  {pour ne pas couper le pion bariole ou les coups legaux}
                                              InvalidateDessinEnTraceDeRayon(x);
                                              DessinePion2D(x,aux);
                                            end
                                          else
                                            begin
                                              if clipRegion <> NIL then InvalidateDessinEnTraceDeRayon(x);
                                              DessinePion2D(x,jeuCourant[x]);
                                            end;
                                   end;
                               end;
                           if avecSystemeCoordonnees then DessineSystemeCoordonnees;
                         end;
                   end;
          
          { SetPositionsTextesWindowPlateau; }
          
          if positionEffacee & afficheNumeroCoup then DessineNumeroDernierCoupSurOthellier(othellierToutEntier,GetCurrentNode());
          DessineGarnitureAutourOthellierPourEcranStandard;
          
          if aideDebutant then DessineAideDebutant(false,othellierToutEntier);
          DessineAutresInfosSurCasesAideDebutant(othellierToutEntier); {ceci inclut AfficheProprietesOfCurrentNode(false)}

          DessineBoiteDeTaille(wPlateauPtr);
          dernierTick := TickCount();
          Heure(pionNoir);
          Heure(pionBlanc);  
          
          if EnModeEntreeTranscript() then EcranStandardTranscript;
        end;
      
      ValidRect(GetWindowPortRect(wPlateauPtr));
      
      
      if not(EnModeEntreeTranscript()) then
        if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then
          QDFlushPortBuffer(GetWindowPort(wPlateauPtr), clipRegion); 
          
        
      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
     
      SetPort(oldPort);
    end; 
end;

procedure DessineAutresInfosSurCasesAideDebutant(surQuellesCases : SquareSet);
var oldPort : grafPtr;
    coupSuggere : SInt32;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
			
			if (afficheSuggestionDeCassio | gDoitJouerMeilleureReponse) & 
			   (BAND(GetAffichageProprietesOfCurrentNode(),kSuggestionDeCassio) <> 0) then
		    begin
		      if AttenteAnalyseDeFinaleDansPositionCourante()
		        then coupSuggere := GetBestMoveAttenteAnalyseDeFinale()
		        else coupSuggere := meilleurCoupHum;
		      
		      if (coupSuggere in surQuellesCases) then
					  if (coupSuggere>=11) & (coupSuggere<=88) then
					    if possiblemove[coupSuggere] {& not(inverseVideo[coupSuggere])} then
					      if CassioEstEn3D()
					        then DessinePion3D(coupSuggere,pionSuggestionDeCassio)
					        else DessinePion2D(coupSuggere,pionSuggestionDeCassio);
				end;
				
		  AfficheProprietesOfCurrentNode(false,surQuellesCases,'DessineAutresInfosSurCasesAideDebutant');
			  
			(*if avecDessinCoupEnTete & not(HumCtreHum) then
			  if coupEnTete in surQuellesCases then
				  if (coupEnTete>=11) & (coupEnTete<=88) then 
				  begin
				    if ((aQuiDeJouer=couleurMacintosh) & possiblemove[coupEnTete]) then DessineCoupEnTete;
				    if ((aQuiDeJouer<>couleurMacintosh) & (jeuCourant[coupEnTete] = pionVide)) then DessineCoupEnTete;
				  end;*)
				  
		  if GetAvecAffichageNotesSurCases(kNotesDeCassio) & (BAND(GetAffichageProprietesOfCurrentNode(),kNotesCassioSurLesCases) <> 0)
		    then DessineNoteSurCases(kNotesDeCassio,surQuellesCases);
		    
		  if GetAvecAffichageNotesSurCases(kNotesDeZebra) & (BAND(GetAffichageProprietesOfCurrentNode(),kNotesZebraSurLesCases) <> 0)
		    then DessineNoteSurCases(kNotesDeZebra,surQuellesCases);
		  
			if afficheInfosApprentissage & (BAND(GetAffichageProprietesOfCurrentNode(),kInfosApprentissage) <> 0)
			  then EcritLesInfosDApprentissage;
			
			if DoitAfficherBibliotheque() then EcritCoupsBibliotheque(surQuellesCases);
	  end;
end;

procedure DessineAideDebutant(avecDessinAutresInfosSurLesCases : boolean;surQuellesCases : SquareSet);
var i,coupSuggere,whichSquare : SInt16; 
    oldPort : grafPtr;
    accumulateur : SquareSet;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
      
      coupSuggere := 0;
      if (afficheSuggestionDeCassio | gDoitJouerMeilleureReponse)  then
        if AttenteAnalyseDeFinaleDansPositionCourante()
          then coupSuggere := GetBestMoveAttenteAnalyseDeFinale()
          else coupSuggere := meilleurCoupHum;
		            
		  accumulateur := [];
		  
      for i := 1 to 64 do
        begin
          whichSquare := othellier[i];
          if (whichSquare in surQuellesCases) & possibleMove[whichSquare] then 
	          begin
	            if (whichSquare <> CoupSuggere) then
			          begin
			            if CassioEstEn3D() 
			              then DessinePion3D(whichSquare,pionMontreCoupLegal)
			              else DessinePion2D(whichSquare,pionMontreCoupLegal);
			            if (whichSquare = CoupSuggere) then 
			              gDoitJouerMeilleureReponse := false;
			          end;
		          inverseVideo[whichSquare] := true;
		          SetOthellierEstSale(whichSquare,true);
		          
		          accumulateur := accumulateur + [whichSquare];
	          end;
        end;
        
       
      
      if avecDessinAutresInfosSurLesCases & (surQuellesCases <> [])
        then DessineAutresInfosSurCasesAideDebutant(surQuellesCases);
      
      if (BAND(GetAffichageProprietesOfCurrentNode(),kAnglesCarreCentral) <> 0) 
        then DessineAnglesCarreCentral;
        
      aideDebutant := true;
      SetPort(oldPort);
    end;
end;

procedure EffaceAideDebutant(avecDessinAutresInfosSurLesCases,effacageLarge : boolean;surQuellesCases : SquareSet);
var i,pionDeffacement,whichSquare,coupSuggere : SInt16; 
    oldPort : grafPtr;
    accumulateur : SquareSet;
begin
 if windowPlateauOpen then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);
     
     effacageLarge := effacageLarge & (GetTailleCaseCourante()<25) & afficheBibl & 
                    (phaseDeLaPartie<=phaseMilieu) & (nbreCoup<=LongMaxBibl);
     if CassioEstEn3D() 
      then pionDeffacement := effaceCase
      else if effacageLarge
            then pionDeffacement := pionEffaceCaseLarge
            else pionDeffacement := pionVide;
            
            
     coupSuggere := 0;
     if (afficheSuggestionDeCassio | gDoitJouerMeilleureReponse) then
       if AttenteAnalyseDeFinaleDansPositionCourante()
         then coupSuggere := GetBestMoveAttenteAnalyseDeFinale()
         else coupSuggere := meilleurCoupHum;
            
     accumulateur := [];
     
     for i := 1 to 64 do
       begin
         whichSquare := othellier[i];
	       if (whichSquare in surQuellesCases) & possibleMove[whichSquare] & 
	          (jeuCourant[whichSquare] = pionVide) & GetOthellierEstSale(whichSquare) then 
	         begin
	         
	           if (whichSquare = CoupSuggere) & avecDessinAutresInfosSurLesCases
	             then
	               begin
	                 if CassioEstEn3D() 
				             then DessinePion3D(whichSquare,pionSuggestionDeCassio)
				             else DessinePion2D(whichSquare,pionSuggestionDeCassio);
				           gDoitJouerMeilleureReponse := true;
	               end
	             else
	               begin
	                 if CassioEstEn3D() 
				             then DessinePion3D(whichSquare,pionDeffacement)
				             else DessinePion2D(whichSquare,pionDeffacement);
	               end;
	           
	           accumulateur := accumulateur + [whichSquare];
	         end;
       end;
     
     MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
     aideDebutant := false;
     
     if avecDessinAutresInfosSurLesCases & (accumulateur<> [] ) then
       begin
         DessineAutresInfosSurCasesAideDebutant(accumulateur);
         DessineAnglesCarreCentral;
       end;
       
     SetPort(oldPort);
   end;
end;


procedure EffaceSuggestionDeCassio;
var tempoSuggestionDeCassio : boolean;
begin
  tempoSuggestionDeCassio := afficheSuggestionDeCassio;
  afficheSuggestionDeCassio := false;
  if aideDebutant
    then DessineAideDebutant(true,othellierToutEntier)
    else EffaceAideDebutant(true,false,othellierToutEntier);
  afficheSuggestionDeCassio := tempoSuggestionDeCassio;
end;


procedure ActiverSuggestionDeCassio(whichPos : PositionEtTraitRec;bestMove,bestDef : SInt32;fonctionAppelante : str255);
begin
  {WritelnDansRapport('dans ActiverSuggestionDeCassio, fonctionAppelante = '+fonctionAppelante);
  WritelnStringAndCoupDansRapport('dans ActiverSuggestionDeCassio, bestMove = ',bestMove);}
  
  if afficheSuggestionDeCassio & SuggestionAnalyseDeFinaleEstDessinee() & 
    (GetBestMoveAttenteAnalyseDeFinale() <> bestMove) & AttenteAnalyseDeFinaleDansPositionCourante() then
    begin
      WritelnDansRapport('ASSERT dans ActiverSuggestionDeCassio !! fonctionAppelante = '+fonctionAppelante);
      DoChangeAfficheSuggestionDeCassio;
      afficheSuggestionDeCassio := true;
    end;
  
  ActiverAttenteAnalyseDeFinale(whichPos,bestMove,bestDef,afficheSuggestionDeCassio);
  meilleurCoupHum := bestMove;
  DessineAutresInfosSurCasesAideDebutant([bestMove]);
  gDoitJouerMeilleureReponse := afficheSuggestionDeCassio;
end;


function GetBestSuggestionDeCassio() : SInt32;
begin
  if AttenteAnalyseDeFinaleDansPositionCourante() 
    then GetBestSuggestionDeCassio := GetBestMoveAttenteAnalyseDeFinale()
    else GetBestSuggestionDeCassio := meilleurCoupHum;
end;


procedure EraseRectDansWindowPlateau(whichRect : rect);
var oldPort : grafPtr;
    error : OSErr;
begin
  if windowPlateauOpen then
    begin
      if CassioEstEn3D() & EnJolie3D()
        then
          EraseRectPovRay3D(whichRect)
        else
          begin
			      GetPort(oldPort);
			      SetPortByWindow(wPlateauPtr);
			      
			      if garderPartieNoireADroiteOthellier | not(BordureOthellierEstUneTexture())
			        then EraseRect(whichRect)
			        else error := DrawBordureRectDansFenetre(whichRect,wPlateauPtr);
			        
			      SetPort(oldPort);
			    end;
    end;
end;


procedure EffaceZoneADroiteDeLOthellier;
var unRect : rect;
begin
  if not(CassioEstEn3D()) & not(EnModeEntreeTranscript()) {| enRetour} then
    with aireDeJeu do
    begin
      
      if avecSystemeCoordonnees
        then SetRect(unRect,CalculateBordureRect(kBordureDeDroite,gCouleurOthellier).right,0,3000,3000)
        else SetRect(unRect,aireDeJeu.right-1,0,3000,3000);
        
      EraseRectDansWindowPlateau(unRect);
      
      DrawClockBoundingRect(gHorlogeRect,10);
    end;
end;



procedure EffaceZoneAuDessousDeLOthellier;
var unRect : rect;
    oldPort : grafPtr;
begin
  if not(CassioEstEn3D()) {& not(EnModeEntreeTranscript())} {| enRetour} then
    with aireDeJeu do
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      
      if avecSystemeCoordonnees
        then SetRect(unRect,0,CalculateBordureRect(kBordureDuBas,gCouleurOthellier).bottom,3000,3000)
        else SetRect(unRect,0,aireDeJeu.bottom-1,3000,3000);
      
      if EnModeEntreeTranscript()
        then 
          begin
            (* EraseRectDansWindowPlateau(MakeRect(3000,3000,3001,3001)); *) {cette ligne pour charger la texture de bois}
            EraseRect(unRect);
          end
        else 
          EraseRectDansWindowPlateau(unRect);
      
      SetPort(oldPort);
    end;
end;

procedure EffaceZoneAGaucheDeLOthellier;
var unRect : rect;
begin
  if not(CassioEstEn3D()) & not(EnModeEntreeTranscript()) {| enRetour} then
    with aireDeJeu do
    begin
      SetRect(unRect,0,0,left,3000);
      EraseRectDansWindowPlateau(unRect);
    end;
end;

procedure EffaceZoneAuDessusDeLOthellier;
var unRect : rect;
begin
  if not(CassioEstEn3D()) & not(EnModeEntreeTranscript()) {| enRetour} then
    with aireDeJeu do
    begin
      SetRect(unRect,0,0,3000,top);
      if (gCouleurOthellier.nomFichierTexture = 'Photographique') then SetRect(unRect,0,0,3000,top+1);
      EraseRectDansWindowPlateau(unRect);
    end;
end;

procedure EffaceTouteLaFenetreSaufLOthellier;
begin
  EffaceZoneADroiteDeLOthellier;
  EffaceZoneAuDessousDeLOthellier;
  EffaceZoneAGaucheDeLOthellier;
  EffaceZoneAuDessusDeLOthellier;
end;


function  PtInPlateau2D(loc : Point; var caseCliquee : SInt16) : boolean;
var X,Y : SInt16; 
    test : boolean;
    tailleCaseCourante : SInt32;
begin
  test := PtInRect(loc,aireDeJeu);
  tailleCaseCourante := GetTailleCaseCourante();
  X := ((loc.h-aireDeJeu.left) div tailleCaseCourante)+1; 
  Y := ((loc.v-aireDeJeu.top) div tailleCaseCourante)+1;  
  PtInPlateau2D := test & InRange(X,1,8) & InRange(Y,1,8);
  caseCliquee := X+10*Y;  
end;


function  PtInPlateau(loc : Point; var caseCliquee : SInt16) : boolean;
begin
  if CassioEstEn3D()
    then PtInPlateau := PtInPlateau3D(loc,caseCliquee)
    else PtInPlateau := PtInPlateau2D(loc,caseCliquee);
end;


procedure EffaceAnnonceFinaleSiNecessaire;
begin
  if HumCtreHum then
    with meilleureSuiteInfos do
      if (statut=ReflAnnonceGagnant) | 
         (statut=ReflAnnonceParfait) |
         (statut=ReflTriGagnant) |
         (statut=ReflTriParfait) then
        DetruitMeilleureSuite;
end;


function DetermineVolumeApplication() : SInt16; 
var unStringPtr:StringPtr;
    refvol : SInt16; 
    codeErreur : OSErr;
    dirID : UInt32;
begin
   unstringPtr := stringPtr(AllocateMemoryPtr(256));
   codeErreur := HGetVol(unstringPtr,refvol,dirID);
   DisposeMemoryPtr(Ptr(unstringPtr));
   DetermineVolumeApplication := refvol;
end;


function DeterminePathDossierFichiersAuxiliaires(volumeRefCassio : SInt16) : str255;
var myFSSpec : FSSpec;
    err : OSErr;
    fullPath : str255;
begin
  err := MyFSMakeFSSpec(volumeRefCassio,0,'Fichiers auxiliaires',myFSSpec);
  if err <> 0 then err := MyFSMakeFSSpec(volumeRefCassio,0,'Fichiers auxiliaires Cassio',myFSSpec);
  if err <> 0 then err := MyFSMakeFSSpec(volumeRefCassio,0,'Auxilary files',myFSSpec);
  if err <> 0 then err := MyFSMakeFSSpec(volumeRefCassio,0,'Cassio files',myFSSpec);
  if err <> 0 then err := MyFSMakeFSSpec(volumeRefCassio,0,'Cassio auxilary files',myFSSpec);
  if err <> 0
    then
      begin
        err := MyFSMakeFSSpec(volumeRefCassio,0,'',myFSSpec);
        MyResolveAliasFile(myFSSpec);
        err := FSSpecToFullPath(myFSSpec,fullPath);
        DeterminePathDossierFichiersAuxiliaires := fullPath;
        {WritelnDansRapport('Branche 2 dans DeterminePathDossierFichiersAuxiliaires : '+fullPath);}
      end
    else
      begin
        MyResolveAliasFile(myFSSpec);
        err := FSSpecToFullPath(myFSSpec,fullPath);
        DeterminePathDossierFichiersAuxiliaires := fullPath;
        {WritelnDansRapport('Branche 2 dans DeterminePathDossierFichiersAuxiliaires : '+fullPath);}
      end;
end;


function TrouveCoupDansPartieCourante(whichSquare : SInt16; var numeroDuCoup : SInt16) : boolean;
var i : SInt16; 
begin
  for i := 1 to nroDernierCoupAtteint do
    if GetNiemeCoupPartieCourante(i)=whichSquare then 
      begin
        numeroDuCoup := i-1; 
        TrouveCoupDansPartieCourante := true;
        exit(TrouveCoupDansPartieCourante);
      end;
  numeroDuCoup := -1;
  TrouveCoupDansPartieCourante := false;
end;

procedure SetOthellierEstSale(square : SInt16; flag : boolean);
begin
  if (square >= 0) & (square <= 99) then othellierEstSale[square] := flag;
end;

function GetOthellierEstSale(square : SInt16) : boolean;
begin
  if (square >= 0) & (square <= 99)
    then GetOthellierEstSale := othellierEstSale[square]
    else GetOthellierEstSale := false;
    {
    GetOthellierEstSale := true;
    }
end;

procedure SetOthellierToutEntierEstSale;
var k : SInt16; 
begin
  for k := 11 to 88 do
    SetOthellierEstSale(k,true);
end;

function CurseurEstEnTeteDeMort() : boolean;
begin
  CurseurEstEnTeteDeMort := (enTeteDeMort>0);
end;

procedure DecrementeNiveauCurseurTeteDeMort;
begin
  enTeteDeMort := Max(0,enTeteDeMort-1);
end;

procedure SetNiveauTeteDeMort(niveau : SInt16);
begin
  enTeteDeMort := niveau;
end;


procedure SelectCassioFonts(theme : SInt32);
var aux : SInt32;
    err : OSErr;
begin
    
    
  
    if gVersionJaponaiseDeCassio & gHasJapaneseScript
      then
        begin
          gCassioSmallFontSize   := 9;
	        gCassioNormalFontSize  := 12;
	        gCassioBigFontSize     := 24;
	        gCassioApplicationFont := GetAppFont();
        
	        if FontToScript(gCassioApplicationFont) <> smJapanese then
	          begin
	            aux := GetScriptVariable(smJapanese,smScriptPrefFondSize);
	            gCassioApplicationFont := HiWord(aux);
	            gCassioNormalFontSize := LoWord(aux);
	          end;
          
          gCassioRapportNormalFont := gCassioApplicationFont;
          gCassioRapportBoldFont   := gCassioApplicationFont;
          gCassioRapportBoldSize   := gCassioNormalFontSize;
          gCassioRapportNormalSize := gCassioNormalFontSize;
          gCassioRapportSmallSize  := 9;
          
          gCassioUseQuartzAntialiasing := false;
          
        end
      else
        begin
          case theme of
            kThemeBaskerville : 
              begin
                gCassioUseQuartzAntialiasing := gIsRunningUnderMacOSX;
                
                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;
                
                if MyGetFontNum('Baskerville') > 0
                  then
		                begin
		                  gCassioRapportBoldSize   := 13;
		                  gCassioRapportNormalSize := 13;
		                  gCassioRapportSmallSize  := 13;
		                
		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := MyGetFontNum('Baskerville');
		                  gCassioRapportBoldFont   := MyGetFontNum('Baskerville');
		                end
		              else
		                begin
		                  gCassioRapportBoldSize   := 12;
		                  gCassioRapportNormalSize := 12;
		                  gCassioRapportSmallSize  := 12;
		                
		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := NewYorkID;
		                  gCassioRapportBoldFont   := NewYorkID;
		                end; 
              end;
            kThemeTimesNewRoman : 
              begin
                gCassioUseQuartzAntialiasing := gIsRunningUnderMacOSX;
                
                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;
                
                if MyGetFontNum('Times New Roman') > 0
                  then
		                begin
		                  gCassioRapportBoldSize   := 12;
		                  gCassioRapportNormalSize := 12;
		                  gCassioRapportSmallSize  := 12;
		                
		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := MyGetFontNum('Times New Roman');
		                  gCassioRapportBoldFont   := MyGetFontNum('Times New Roman');
		                end
		              else
		                begin
		                  gCassioRapportBoldSize   := 12;
		                  gCassioRapportNormalSize := 12;
		                  gCassioRapportSmallSize  := 12;
		                
		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := NewYorkID;
		                  gCassioRapportBoldFont   := NewYorkID;
		                end; 
              end;
            kThemeModerne :
              begin
                gCassioUseQuartzAntialiasing := gIsRunningUnderMacOSX;
                
                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;
                
                gCassioRapportBoldSize   := 11;
                gCassioRapportNormalSize := 10;
                gCassioRapportSmallSize  := 10;
                
                gCassioApplicationFont   := GenevaID;
                gCassioRapportNormalFont := GenevaID;
                gCassioRapportBoldFont   := HelveticaID;
                
              end;
            kThemeGillSans : 
              begin
                gCassioUseQuartzAntialiasing := gIsRunningUnderMacOSX;
                
                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;
                
                if MyGetFontNum('Gill Sans') > 0
                  then
		                begin
		                  gCassioRapportBoldSize   := 11;
		                  gCassioRapportNormalSize := 11;
		                  gCassioRapportSmallSize  := 11;
		                
		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := MyGetFontNum('Gill Sans');
		                  gCassioRapportBoldFont   := MyGetFontNum('Gill Sans');
		                end
		              else
		                begin
		                  gCassioRapportBoldSize   := 9;
		                  gCassioRapportNormalSize := 9;
		                  gCassioRapportSmallSize  := 9;
		                
		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := GenevaID;
		                  gCassioRapportBoldFont   := GenevaID;
		                end; 
              end;
            kThemeMacOS9 :
              begin
                gCassioUseQuartzAntialiasing := false;
                
                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;
                gCassioRapportBoldSize   := 9;
                gCassioRapportNormalSize := 9;
                gCassioRapportSmallSize  := 9;
                
                gCassioApplicationFont   := GenevaID;
                gCassioRapportNormalFont := GenevaID;
                gCassioRapportBoldFont   := GenevaID;
              end;
          end; {case}
        end;        
      
  if gCassioUseQuartzAntialiasing
    then
      begin
        err := SetAntiAliasedTextEnabled(true,9);
        EnableQuartzAntiAliasing(true);
        if windowListeOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false);
        if windowStatOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),true);
        if windowCourbeOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr),true);
        if windowAideOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wAidePtr),true);
        if windowGestionOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wGestionPtr),true);
      end
    else
      begin
        {err := SetAntiAliasedTextEnabled(gIsRunningUnderMacOSX,9);}
        err := SetAntiAliasedTextEnabled(false,9);
        DisableQuartzAntiAliasing;
        if windowListeOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr));
        if windowStatOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr));
        if windowCourbeOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr));
        if windowAideOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wAidePtr));
        if windowGestionOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wGestionPtr));
      end;
			  
end;


procedure ForconsLePlantageDeCassio;
begin
  IndexInfoDejaCalculeesCoupNro := IndexInfoDejaCalculeesCoupNroHdl(-23);
  IndexInfoDejaCalculeesCoupNro^^[-45] := 1000;
  MemoryFillChar(IndexInfoDejaCalculeesCoupNro^,sizeof(t_IndexInfoDejaCalculeesCoupNro),chr(0));
end;


END.