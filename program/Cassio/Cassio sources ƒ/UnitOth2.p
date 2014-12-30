UNIT UnitOth2;




INTERFACE







USES UnitOth0,UnitFichiersTEXT,UnitPositionEtTrait;




procedure InitUnitOth2;
procedure LibereMemoireUnitOth2;


procedure BeginRetournementSpecial(positionAAtteindre : PositionEtTraitRec);
procedure EndRetournementSpecial;
function RetournementSpecialEnCours() : boolean;
function ValeurFutureDeCetteCaseDansRetournementSpecial(whichSquare : SInt32) : SInt32;




procedure EcritCommentaireOuverture(commentaire : str255);
procedure EffaceCommentaireOuverture;
procedure AffichePourDebugage(chaine : str255);
procedure StoppeEtAffichePourDebugage(chaine : str255);
procedure StoppeEtAfficheAireDeJeuPourDebugage(chaine : str255);
procedure GetRectDansPalette(action : SInt16; var RectAction : rect);
function EstUnDoubleClic(myEvent : eventRecord;AttendClicSuivant : boolean) : boolean;
function PeutReculerUnCoup() : boolean;
function PeutReculerDeuxCoups() : boolean;
function PeutAvancerUnCoup() : boolean;
function PeutAvancerDeuxCoups() : boolean;
function PeutAvancerPartieSelectionnee() : boolean;
function PeutReculerUnCoupPuisJouerSurCetteCase(whichSquare : SInt32; var positionResultante : PositionEtTraitRec) : boolean;
procedure Bip(duree : SInt16);
function UpdateRgnTouchePlateau() : boolean;
procedure DessinePourcentage(square,n : SInt16);
procedure DessinePionMontreCoupLegal(x : SInt16);
procedure EffacePionMontreCoupLegal(x : SInt16);
procedure DialogueVousPassez;
procedure AlerteMicMacIndex(nbrePartiesIndex,nbrePartiesBase : SInt32);
function ConfirmationQuitter() : boolean;
function PeutArreterAnalyseRetrograde() : boolean;
function CalculeTailleCaseParPlateauRect(thePlateauRect : rect) : SInt16; 
procedure SetAffichageResserre(forceUpdate : boolean);
procedure EcritPositionAt(var plat : plateauOthello;hpos,vpos : SInt16);
procedure EcritPlatBoolAt(var plat : plBool;hpos,vpos : SInt16);
procedure StoppeEtAfficheMessageAt(message : str255;x,y : SInt16);
procedure DessineRetour(ClipRegion : RgnHandle;fonctionAppelante : str255);
procedure VideHashTable(whichHashTable:HashTableHdl);
procedure EcritStatistiquesCollisionsHashTableDansRapport;
procedure AfficheHashTable(minimum,maximum : SInt32);
procedure EcritEspaceDansPile;
procedure DialogueMemoireBase;
procedure DialoguePartieIncomplete;
procedure AlerteErreurCollagePartie;
procedure AlerteFormatNonReconnuFichierPartie(nomFichier : str255);
procedure AlerteDoitInterompreReflexionPourFaireScript;
procedure DialogueSimple(DialogueID : SInt16{;s1,s2,s3,s4 : str255});
function MyFiltreClassiqueRapide(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
procedure AjoutePion(x,coul : SInt16; var platJeu : plateauOthello; var Jouable : plBool);
procedure PosePion(x,couleur : SInt16);
function FichierTexteDeCassioExiste(nom : str255; var fic : FichierTEXT) : OSErr; 
function CreeFichierTexteDeCassio(nom : str255; var fic : FichierTEXT) : OSErr;
procedure AlerteSimpleFichierTexte(nomFichier : string;erreurES : SInt32);
function VersionDeCassioEnString() : str255;
procedure SetAfficheInfosApprentissage(flag : boolean);
function GetAfficheInfosApprentissage() : boolean;



IMPLEMENTATION







USES UnitAfficheArbreDeJeuCourant,UnitRapport,UnitAffichageReflexion,UnitBufferedPICT,
     UnitTroisiemeDimension,UnitGeometrie,UnitPressePapier,UnitRapportImplementation,
     UnitCarbonisation,UnitFenetres,UnitOth1,UnitServicesDialogs,UnitEntreeTranscript,
     UnitStatistiques,MyStrings,UnitMacExtras,UnitDialog,UnitGestionDuTemps,UnitListe,
     UnitVieilOthelliste,SNStrings,UnitCourbe,UnitCouleur,UnitJeu;

var gRetournementSpecial : record
                             enCours        : boolean;
                             positionFuture : PositionEtTraitRec;
                           end;


function VersionDeCassioEnString() : str255;
begin
  VersionDeCassioEnString := '6.0b4';
end;



procedure BeginRetournementSpecial(positionAAtteindre : PositionEtTraitRec);
begin
  gRetournementSpecial.enCours        := true;
  gRetournementSpecial.positionFuture := positionAAtteindre;
end;


function ValeurFutureDeCetteCaseDansRetournementSpecial(whichSquare : SInt32) : SInt32;
begin
  with gRetournementSpecial do
    if enCours & (whichSquare >= 11) & (whichSquare <= 88)
      then ValeurFutureDeCetteCaseDansRetournementSpecial := positionFuture.position[whichSquare]
      else ValeurFutureDeCetteCaseDansRetournementSpecial := 0;
end;

procedure EndRetournementSpecial;
begin
  gRetournementSpecial.enCours := false;
end;

function RetournementSpecialEnCours() : boolean;
begin
  RetournementSpecialEnCours := gRetournementSpecial.enCours;
end;


procedure InitUnitOth2;
begin
  gRetournementSpecial.enCours        := false;
end;


procedure LibereMemoireUnitOth2;
begin
end;



procedure EcritCommentaireOuverture(commentaire : str255);
var unRect : rect;
    oldport : grafPtr;
begin
  if windowPlateauOpen & not(EnModeEntreeTranscript()) then
    begin
      GetPort(oldport);
      SetPortByWindow(wPlateauPtr);
      SetRect(unRect,posHdemande,posVdemande-26,posHdemande+300,posVdemande-14);
      EraseRectDansWindowPlateau(unRect);
      Moveto(posHdemande,posVdemande-16);
      DrawString('Ç '+commentaire+' È');
      SetPort(oldport);
    end;
end;

procedure EffaceCommentaireOuverture;
var unRect : rect;
    oldport : grafPtr;
begin
  if windowPlateauOpen & not(EnModeEntreeTranscript()) then
    begin
      GetPort(oldport);
      SetPortByWindow(wPlateauPtr);
      SetRect(unRect,posHdemande,posVdemande-26,posHdemande+300,posVdemande-14);
      EraseRectDansWindowPlateau(unRect);
      SetPort(oldport);
    end;
end;

procedure AffichePourDebugage(chaine : str255);
var yposition : SInt16; 
    oldport : grafPtr;
    effaceRect : rect;
begin
  if windowCourbeOpen  then
    begin
      GetPort(oldport);
      SetPortByWindow(wCourbePtr);
    end;
  nbreDebugage := nbreDebugage+1;
  yposition := 10+(nbreDebugage mod 30)*10;
  SetRect(effaceRect,5,yposition,500,yposition+12);
  EraseRect(effacerect);
  Moveto(10,yposition);
  DrawString(Concat(chaine,'   '));
  if windowCourbeOpen then SetPort(oldport);
  
  {Writeln(chaine);}
end;

procedure StoppeEtAffichePourDebugage(chaine : str255);
begin
  AffichePourDebugage(chaine);
  SysBeep(0);
  AttendFrappeClavier;
end;

procedure StoppeEtAfficheAireDeJeuPourDebugage(chaine : str255);
var s : str255;
begin
  s := chaine + ' : aireDeJeu.left = '+NumEnString(aireDeJeu.left);
  AffichePourDebugage(s);
  TraceLog(s);
  SysBeep(0);
  {AttendFrappeClavier;}
end;

procedure GetRectDansPalette(action : SInt16; var RectAction : rect);
var oldport : grafPtr;
    i,j : SInt16; 
begin
  if windowPaletteOpen & (wPalettePtr <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(wPalettePtr);
      i := ((action-1) mod 9)+1;
      j := ((action-1) div 9)+1;
      SetRect(RectAction,(i-1)*largeurCasePalette,
                         (j-1)*hauteurCasePalette,
                         i*largeurCasePalette -1,
                         j*HauteurCasePalette -1);
      LocalToGlobal(RectAction.topleft);
      LocalToGlobal(RectAction.botright);
      SetPort(oldport);
    end;
end;

function EstUnDoubleClic(myEvent : eventRecord;AttendClicSuivant : boolean) : boolean;
var test : boolean;
    NextEvent : eventRecord;
    arretAttente : SInt32;
begin
  with myEvent do
    begin
      test := (Abs(EmplacementDernierClic.h-where.h)<=3) &
            (Abs(EmplacementDernierClic.v-where.v)<=3) &
            ((when-instantDernierClic) <= GetDblTime());
      EstUnDoubleClic := test;
    end;
  if not(test) then
     begin
       EmplacementDernierClic := myEvent.where;
       instantDernierClic := myEvent.when;
       if AttendClicSuivant then
         begin
           arretAttente := instantDernierClic + GetDblTime();
           repeat
             MySystemTask;
           until (TickCount()>=arretAttente) | EventAvail(mDownMask,NextEvent);
         end;
       MySystemTask;
       if EventAvail(mDownMask,NextEvent) then
         begin
           test := (Abs(EmplacementDernierClic.h-NextEvent.where.h)<=2) &
                 (Abs(EmplacementDernierClic.v-NextEvent.where.v)<=2) &
                 ((NextEvent.when-instantDernierClic) <= GetDblTime());
           if test then 
             begin
               if GetNextEvent(mDownMask,NextEvent) then;
               EstUnDoubleClic := true;
             end;
         end;
     end;
end;

function PeutReculerUnCoup() : boolean;
var test : boolean;
begin
  test := false;
  if (nbreCoup>0) then 
    if (DerniereCaseJouee() <> coupInconnu) then test := true;
  PeutReculerUnCoup := test;
end;

function PeutReculerDeuxCoups() : boolean;
var test : boolean;
begin
  test := false;
  if (nbreCoup>1) then 
    if (DerniereCaseJouee() <> coupInconnu) then test := true;
  PeutReculerDeuxCoups := test;
end;


function PeutReculerUnCoupPuisJouerSurCetteCase(whichSquare : SInt32; var positionResultante : PositionEtTraitRec) : boolean;
var result : boolean;
    i : SInt32;
    plateauResultant : plateauOthello;
begin
  result := false;
  if (nbreCoup>0) then 
    with partie^^[nbreCoup] do
      if (DerniereCaseJouee() <> coupInconnu) then 
        begin
          
          plateauResultant := jeuCourant;
          
          plateauResultant[DerniereCaseJouee()] := pionVide;
          
          for i := 1 to nbRetourne do
            plateauResultant[retournes[i]] := -plateauResultant[retournes[i]];  
                         
          positionResultante := MakePositionEtTrait(plateauResultant,partie^^[nbreCoup].trait);  
          
          result := UpdatePositionEtTrait(positionResultante,whichSquare);
        end;
        
  PeutReculerUnCoupPuisJouerSurCetteCase := result;
end;


function PeutAvancerUnCoup() : boolean;
begin
  PeutAvancerUnCoup := (nbreCoup < nroDernierCoupAtteint);
end;

function PeutAvancerDeuxCoups() : boolean;
begin
  PeutAvancerDeuxCoups := ((nbreCoup+1) < nroDernierCoupAtteint);
end;

function PeutAvancerPartieSelectionnee() : boolean;
var test : boolean;
begin
  test := not(gameOver) & (nbPartiesActives>0) & windowListeOpen;
  PeutAvancerPartieSelectionnee := test;
end;


procedure Bip(duree : SInt16);
begin
   if avecSon then SysBeep(duree);
end;

function UpdateRgnTouchePlateau() : boolean;
var visRect,unRect : rect;
    visibleRgn : RgnHandle;
begin
  
  visibleRgn := NewRgn();
  visRect := MyGetRegionRect(GetWindowVisibleRegion(wPlateauPtr,visibleRgn));
  DisposeRgn(visibleRgn);
  
  unRect := GetOthellierVistaBuffer();
  UpdateRgnTouchePlateau := SectRect(visRect,unRect,visRect);
end;

procedure DessinePourcentage(square,n : SInt16);
var s : string;
    unRect : rect;
    x,y,a,b : SInt16; 
    oldPort : grafPtr;
    larg : SInt16; 
begin
 if windowPlateauOpen then
 begin
  GetPort(oldPort);
  SetPortByWindow(wPlateauPtr);
  TextFont(MonacoID);
  if (GetTailleCaseCourante() < 28) then TextFont(CourierID);
  TextSize(9);
  TextMode(1);
  s := PourcentageEntierEnString(n)+StringOf('%');
  larg := StringWidth(s);
  if CassioEstEn3D() 
   then
     begin
       unRect := GetRect3DDessous(square);
       with unRect do
        begin
         if right-left>27 then 
           begin
             x := (right+left) div 2;
             left := x-13;
             right := x+14;
           end;
         if bottom-top>14 then 
           begin
             x := (top+bottom) div 2;
             top := x-7;
             bottom := x+7;
           end;
       end;
     end
   else
     begin
      x := platmod10[square];
      y := platdiv10[square];
      a := aireDeJeu.left + 1 + GetTailleCaseCourante()*(x-1);
      b := aireDeJeu.top + GetTailleCaseCourante()*y- (GetTailleCaseCourante() div 2);
      SetRect(unRect,a+3,b-7,a+GetTailleCaseCourante()-4,b+7);
      if not(retirerEffet3DSubtilOthellier2D) then
        begin
          unRect.left := unRect.left + 1;
        end;
     end;
  while (unRect.right-unRect.left) < larg+1  do InsetRect(unRect,-1,0);
  while (unRect.right-unRect.left) > larg+10 do InsetRect(unRect,1,0);
  if GetTailleCaseCourante() > 15 then
    begin
      FillRect(unRect,whitePattern);
      RGBForeColor(NoircirCouleurDeCetteQuantite(gCouleurOthellier.RGB,10000));
      RGBBackColor(NoircirCouleurDeCetteQuantite(gCouleurOthellier.RGB,10000));
      FrameRect(unRect);
      ForeColor(blackColor);
      BackColor(whiteColor);
    end;
  Moveto((unRect.left+unRect.right-larg) div 2+1,unRect.bottom-3);
  DrawString(s);
  SetOthellierEstSale(square,true);
  InvalidateDessinEnTraceDeRayon(square);
  SetPort(oldPort);
 end;
end;

procedure DessinePionMontreCoupLegal(x : SInt16);
var oldport : grafPtr;
begin
  if windowPlateauOpen then
     begin
        GetPort(oldport);
        SetPortByWindow(wPlateauPtr);
        if inverseVideo[x]
          then
            begin
              if CassioEstEn3D()
                then DessinePion3D(x,pionVide)
                else DessinePion2D(x,pionVide);
              inverseVideo[x] := false;
            end
          else
            begin
              if CassioEstEn3D()
                then DessinePion3D(x,pionMontreCoupLegal)
                else DessinePion2D(x,pionMontreCoupLegal);
              inverseVideo[x] := true;
            end;
        SetPort(oldport);
     end;
end;

procedure EffacePionMontreCoupLegal(x : SInt16);
var oldport : grafPtr;
begin
    if windowPlateauOpen then
     begin
       GetPort(oldport);
       SetPortByWindow(wPlateauPtr);
       if aidedebutant then
         begin
           if not(inverseVideo[x]) then
            begin
              if CassioEstEn3D() 
                then DessinePion3D(x,pionMontreCoupLegal)
                else DessinePion2D(x,pionMontreCoupLegal);
              inverseVideo[x] := true;
              SetOthellierEstSale(x,true);
            end;
         end
         else
         begin
           if inverseVideo[x] then
            begin
              if CassioEstEn3D() 
                then DessinePion3D(x,effaceCase)
                else DessinePion2D(x,pionVide);
              inverseVideo[x] := false;
            end;
         end;
       SetPort(oldport);
     end;
end;




procedure DialogueVousPassez;
const VousPassezID=131;
      OK=1;
var dp : DialogPtr;
    itemHit : SInt16; 
    err : OSErr;
begin
  BeginDialog;
  dp := MyGetNewDialog(VousPassezID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit=OK);
      MyDisposeDialog(dp);
      PassesDejaExpliques := PassesDejaExpliques+1;
    end;
  EndDialog;
end;

procedure AlerteMicMacIndex(nbrePartiesIndex,nbrePartiesBase : SInt32);
const MicMacIndexID=1132;
      ok=1;
var s1,s2 : str255;
begin
  BeginDialog;
  NumToString(nbrePartiesIndex,s1);
  NumToString(nbrePartiesBase,s2);
  ParamText(s1,s2,'','');
  if MyAlert(MicMacIndexID,FiltreClassiqueAlerteUPP,[ok])=ok then;
  EndDialog;
end;

function ConfirmationQuitter() : boolean;
const QuitterID=128;
      Annuler=2;
      Quitter=1;
var dp : DialogPtr;
    itemHit : SInt16; 
    err : OSErr;
begin
  ConfirmationQuitter := true;
  if doitConfirmerQuitter & not(demo) then
    begin
      BeginDialog;
      dp := MyGetNewDialog(QuitterID,FenetreFictiveAvantPlan());
      if dp <> NIL then
        begin
          err := SetDialogTracksCursor(dp,true);
          repeat
            ModalDialog(FiltreClassiqueUPP,itemHit);
          until (itemHit=Annuler) | (itemHit=Quitter);
          MyDisposeDialog(dp);
          if (itemHit=Annuler) 
            then ConfirmationQuitter := false
            else ConfirmationQuitter := true;
        end;
      EndDialog;
    end;
end;

function PeutArreterAnalyseRetrograde() : boolean;
const ConfirmationArretRetroID=150;
      Annuler=2;
      Interrompre=1;
var dp : DialogPtr;
    itemHit : SInt16; 
    FiltreArretAnalyseRetrogradeUPP : ModalFilterUPP;
    err : OSErr;
begin
  PeutArreterAnalyseRetrograde := true;
  with analyseRetrograde do
  if enCours & doitConfirmerArret & peutDemanderConfirmerArret & not(Quitter) then
    if ((TickCount()-tickDebutAnalyse) div 3600) >= nbMinPourConfirmationArret then
        begin
          BeginDialog;
          FiltreArretAnalyseRetrogradeUPP := NewModalFilterUPP(@MyFiltreClassiqueRapide);
          dp := MyGetNewDialog(ConfirmationArretRetroID,FenetreFictiveAvantPlan());
          if dp <> NIL then
            begin
              err := SetDialogTracksCursor(dp,true);
              repeat
                ModalDialog(FiltreArretAnalyseRetrogradeUPP,itemHit);
              until (itemHit=Annuler) | (itemHit=Interrompre);
              MyDisposeDialog(dp);
              if (itemHit=Annuler) 
                then 
                  PeutArreterAnalyseRetrograde := false
                else 
                  begin
                    PeutArreterAnalyseRetrograde := true;
                    analyseRetrograde.peutDemanderConfirmerArret := false;
                  end;
            end;
          MyDisposeModalFilterUPP(FiltreArretAnalyseRetrogradeUPP);
          EndDialog;
        end;
end;





function CalculeTailleCaseParPlateauRect(thePlateauRect : rect) : SInt16; 
var tailleTemp : SInt16; 
begin
  if not(windowPlateauOpen) 
    then tailleTemp := 37
    else 
      begin
        tailleTemp := (thePlateauRect.bottom-thePlateauRect.top) div 8;
        if (thePlateauRect.right-thePlateauRect.left) div 8 < tailleTemp then 
          tailleTemp := (thePlateauRect.right-thePlateauRect.left) div 8;
      end;
   CalculeTailleCaseParPlateauRect := TailleTemp;
end;



procedure SetAffichageResserre(forceUpdate : boolean);
var rectVoulu,CurrentRect : rect;
begin
 if windowPlateauOpen then
  begin
    SetPortByWindow(wPlateauPtr);
    genreAffichageTextesDansFenetrePlateau := kAffichageSousOthellier;
    {AvecSystemeCoordonnees := false;}
    SetTailleCaseCourante(30);
    
    SetRect(rectVoulu,-2,39,510,340);
    currentRect := GetWindowPortRect(wPlateauPtr);
    LocalToGlobalRect(currentRect);
    if not(EqualRect(currentRect,rectVoulu)) then
      with rectVoulu do
        begin
          ShowHide(wPlateauPtr,false);
          MoveWindow(wPlateauPtr,left,top,false);
          SizeWindow(wPlateauPtr,right-left,bottom-top,false);
          ShowHide(wPlateauPtr,true);
        end;
    SetPositionPlateau2D(8,GetTailleCaseCourante(),0,-1,'SetAffichageResserre');
    SetPositionsTextesWindowPlateau;
    if forceUpdate then 
      begin
        NoUpdateWindowPlateau;
        InvalidateAllCasesDessinEnTraceDeRayon;
        EcranStandard(NIL,true);
      end;
  end;
end;

procedure EcritPositionAt(var plat : plateauOthello;hpos,vpos : SInt16);
var i,j,a,b : SInt16; 
begin
 PrepareTexteStatePourMeilleureSuite;
 for j := 1 to 8 do
   for i := 1 to 8 do
     begin
       a := hPos+i*12;
       b := vPos+j*12;
       if plat[i+10*j] = pionNoir then WriteStringAt('X ',a,b) else
       if plat[i+10*j] = pionBlanc then WriteStringAt('O ',a,b) else
       if plat[i+10*j] = pionVide then WriteStringAt(' . ',a,b) else
       WriteStringAt(' ? ',a,b)
     end;
end;


procedure EcritPlatBoolAt(var plat : plBool;hpos,vpos : SInt16);
var i,j,a,b : SInt16; 
begin
 PrepareTexteStatePourMeilleureSuite;
 for j := 1 to 8 do
   for i := 1 to 8 do
     begin
       a := hPos+i*12;
       b := vPos+j*12;
       if plat[i+10*j] 
         then WriteStringAt('1 ',a,b) 
         else WriteStringAt('0 ',a,b);
     end;
end;


procedure StoppeEtAfficheMessageAt(message : str255;x,y : SInt16);
begin
  WriteStringAt(message,x,y);
  SysBeep(0);
  AttendFrappeClavier;
end;

procedure DessineRetour(ClipRegion : RgnHandle;fonctionAppelante : str255);
var s : string;
    oldport : grafPtr;
    promptEnDessous : boolean;
    posH,posV,larg : SInt16; 
    theRect : rect;
begin
  {$UNUSED fonctionAppelante}
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      {WritelnDansRapport('appel de DessineRetour par '+fonctionAppelante);}
      
      DessineDiagramme(GetTailleCaseCourante(),ClipRegion,'DessineRetour');  
      
      
      EffaceZoneADroiteDeLOthellier;
      EffaceZoneAuDessousDeLOthellier;
      if avecSystemeCoordonnees then DessineSystemeCoordonnees;
      
      if (TrebuchetMSID <> 0) & gIsRunningUnderMacOSX
        then 
          begin
            TextFont(TrebuchetMSID);
            TextFace(bold);
          end
        else 
          begin
            TextFont(systemFont);
            TextFace(normal);
          end;
      TextSize(12);
      TextMode(srcBic);
      
      promptEnDessous := ((GetWindowPortRect(wPlateauPtr).right-aireDeJeu.right - EpaisseurBordureOthellier())<100) | 
                         (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) | CassioEstEn3D() | EnModeEntreeTranscript();
      if promptEnDessous 
        then
          begin
            if not(CassioEstEn3D())
              then theRect := MakeRect(aireDeJeu.left,aireDeJeu.bottom+1,aireDeJeu.right,aireDeJeu.bottom+12)
              else theRect := MakeRect(GetBoundingRect3D(81).left,PosVDemande-1,GetBoundingRect3D(88).right,PosVDemande);
            with theRect do
              begin
                GetIndString(s,TextesSetUpID,4);
                Moveto(Max(left,(left+right-StringWidth(s)) div 2),bottom);
                DrawString(s);
                GetIndString(s,TextesSetUpID,5);
                DessineBoutonParControlManager(kThemeStateActive,Max(left,(left+right-StringWidth(s)-30) div 2),bottom+4,bottom+24,30,s,annulerRetourRect);
                EffaceZoneADroiteDeLOthellier;
               end;
          end
        else
          begin
             PosH := 15;
             PosV := 16;
             GetIndString(s,TextesSetUpID,1);
             larg := StringWidth(s);
             if aireDeJeu.right+EpaisseurBordureOthellier()+larg>GetWindowPortRect(wPlateauPtr).right-10 then
               posH := GetWindowPortRect(wPlateauPtr).right-larg-(aireDeJeu.right+EpaisseurBordureOthellier())-10;
             if posH<5 then posH := 5;
             Moveto(aireDeJeu.right+EpaisseurBordureOthellier()+PosH,PosV+12);
             DrawString(s);
             GetIndString(s,TextesSetUpID,2);
             Moveto(aireDeJeu.right+EpaisseurBordureOthellier()+PosH,PosV+24);
             DrawString(s);
             GetIndString(s,TextesSetUpID,3);
             Moveto(aireDeJeu.right+EpaisseurBordureOthellier()+PosH,PosV+36);
             DrawString(s);
             GetIndString(s,TextesSetUpID,5);
             DessineBoutonParControlManager(kThemeStateActive,aireDeJeu.right+EpaisseurBordureOthellier()+PosH+15,PosV+45,PosV+65,30,s,annulerRetourRect);
             EffaceZoneAuDessousDeLOthellier;
          end;
      
      if EnModeEntreeTranscript() then EcranStandardTranscript;
      DessineBoiteDeTaille(wPlateauPtr);
      SetPort(oldPort);
    end;
end;

procedure VideHashTable(whichHashTable:HashTableHdl);
var t : SInt32;
begin
  if whichHashTable <> NIL then
    for t := 0 to kTailleHashTable do
      begin
        whichHashTable^^[t] := 0;
      end;
end;



procedure AfficheHashTable(minimum,maximum : SInt32);
var t,aux : SInt32;
begin
  for t := minimum to maximum do
    begin
    WriteStringAndNumAt('hash[',t,10,11*(t mod 20)+10);
    aux := HashTable^^[t];
    WriteStringAndNumAt(']=',aux,70,11*(t mod 20)+10);
    end;
end;

procedure EcritStatistiquesCollisionsHashTableDansRapport;
var nbCellulesDansHashExactes : SInt32;
begin 
  nbCellulesDansHashExactes := nbTablesHashExactes;
  nbCellulesDansHashExactes := nbCellulesDansHashExactes*1024;
  WritelnStringAndNumDansRapport('nbTablesHashExactes = ',nbTablesHashExactes);
  WriteStringAndNumDansRapport('nbCollisionsHashTableExactes = ',nbCollisionsHashTableExactes);
  WritelnStringAndNumDansRapport(' / ',nbCellulesDansHashExactes);
  WriteStringAndNumDansRapport('nbNouvellesEntreesHashTableExactes = ',nbNouvellesEntreesHashTableExactes);
  WritelnStringAndNumDansRapport(' / ',nbCellulesDansHashExactes);
  WriteStringAndNumDansRapport('nbPositionsRetrouveesHashTableExactes = ',nbPositionsRetrouveesHashTableExactes);
  WritelnStringAndNumDansRapport(' / ',nbCellulesDansHashExactes);
  WritelnDansRapport('');
end;



procedure EcritEspaceDansPile;
var a : SInt32;
begin
  a := StackSpace();
  if a>0 
    then WriteStringAndNumAt('espace entre le bas de la pile et le haut du tas : ',a,30,30)
    else 
      begin
        SysBeep(30);
        SysBeep(30);
        SysBeep(30);
        WriteStringAndNumAt('stackspace < ',0,30,30)
      end;
  AttendFrappeClavier;
end;

procedure DialogueMemoireBase;
const problemeMemoireID=141;
      OK=1;
var dp : DialogPtr;
    itemHit : SInt16; 
    err : OSErr;
begin
  BeginDialog;
  dp := MyGetNewDialog(problemeMemoireID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit=OK);
      MyDisposeDialog(dp);
    end;
  EndDialog;
  problemeMemoireBase := true;
end;


procedure DialoguePartieIncomplete;
const PartieImcompleteID=142;
      OK=1;
var dp : DialogPtr;
    itemHit : SInt16; 
    err : OSErr;
begin
  if (nbAlertesPositionFeerique<1) then
    begin
      BeginDialog;
      dp := MyGetNewDialog(PartieImcompleteID,FenetreFictiveAvantPlan());
      if dp <> NIL then
        begin
          err := SetDialogTracksCursor(dp,true);
          repeat
            ModalDialog(FiltreClassiqueUPP,itemHit);
          until (itemHit=OK);
          MyDisposeDialog(dp);
          if windowPaletteOpen then DessinePalette;
          EssaieSetPortWindowPlateau;
          nbAlertesPositionFeerique := nbAlertesPositionFeerique+1;
        end;
      EndDialog;
    end;
end;

procedure AlerteErreurCollagePartie;
var s : str255;
begin
  GetIndString(s,TextesErreursID,3);  {'Le format du presse-papier est inconnu'}
  AlerteSimple(s);
end;
 
procedure AlerteFormatNonReconnuFichierPartie(nomFichier : str255);
var s : str255;
begin
  if EstUnNomDeFichierTemporaireDePressePapier(nomFichier)
    then 
      AlerteErreurCollagePartie
    else 
      begin
        GetIndString(s,TextesErreursID,4);  {'Le format du fichier ^0 me semble incorrect !!'}
	      AlerteSimple(ParamStr(s,nomFichier,'','',''));
      end;
end;


procedure AlerteDoitInterompreReflexionPourFaireScript;
var s : str255;
begin
  GetIndString(s,TextesErreursID,6);  {'Pas possible de fair script !!'}
	AlerteSimple(ParamStr(s,'','','',''));
end;


procedure DialogueSimple(DialogueID : SInt16{;s1,s2,s3,s4 : str255});
const OK=1;
var dp : DialogPtr;
    itemHit : SInt16; 
    err : OSErr;
begin
  BeginDialog;
  dp := MyGetNewDialog(DialogueID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      {ParamText(s1,s2,s3,s4);}
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit=OK);
      MyDisposeDialog(dp);
      if windowPaletteOpen then DessinePalette;
      EssaieSetPortWindowPlateau;
    end;
  EndDialog;
end;



function MyFiltreClassiqueRapide(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
begin
  MyFiltreClassiqueRapide := false;
  if not(EvenementDuDialogue(dlog,evt))
    then
      begin
        if evt.what=UpdateEvt then
          begin
            if FiltreClassique(dlog,evt,item) 
              then MyFiltreClassiqueRapide := true
              else DoUpdateWindowRapide(WindowPtr(evt.message));
          end;
      end
    else
      begin
        MyFiltreClassiqueRapide := FiltreClassique(dlog,evt,item);
      end;
end;



procedure AjoutePion(x,coul : SInt16; var platJeu : plateauOthello; var Jouable : plBool);
var i,t : SInt16; 
begin
   case coul of
   pionNoir,pionBlanc:
      begin
         platJeu[x] := coul;
         jouable[x] := false;
         for t := dirJouableDeb[x] to dirJouableFin[x] do
         begin
           i := x+dirJouable[t];
           Jouable[i] := (platJeu[i]=0);
         end;
      end;
   end;  {case of }
end;  

procedure PosePion(x,couleur : SInt16);
begin
   AjoutePion(x,couleur,jeuCourant,emplJouable);
   DessinePion(x,couleur);
end;


function FichierTexteDeCassioExiste(nom : str255; var fic : FichierTEXT) : OSErr;
const tailleMaxNom=31;
var err : OSErr;
    len,posLastDeuxPoints : SInt16; 
    erreurEstFicNonTrouve : boolean;
begin

  err := -2;
  erreurEstFicNonTrouve := false;
  
  
  if err<>noErr then
    begin
      err := FichierTexteExiste(nom,0,fic);
      erreurEstFicNonTrouve := erreurEstFicNonTrouve | (err=fnfErr);
    end;
  
  posLastDeuxPoints := LastPos(':',nom);
  nom := TPCopy(nom, posLastDeuxPoints+1, 255);
  
  len := Length(nom)-posLastDeuxPoints;
  if len<=tailleMaxNom then
    begin
		  if err<>noErr then
		    begin
		      err := FichierTexteExiste(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve | (err=fnfErr);
		    end;
		end;
		
  nom := nom+' ';
  len := Length(nom)-posLastDeuxPoints;
  if len<=tailleMaxNom then
    begin
		  if (err<>NoErr) then
		    begin
		      err := FichierTexteExiste(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve | (err=fnfErr);
		    end;
		end;
		
  nom := nom+'(alias)';
  len := Length(nom)-posLastDeuxPoints;
  if len<=tailleMaxNom then
    begin
		  if (err<>NoErr) then
		    begin
		      err := FichierTexteExiste(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve | (err=fnfErr);
		    end;
		end;
		
  if (err <> 0) & erreurEstFicNonTrouve
    then FichierTexteDeCassioExiste := fnfErr
    else FichierTexteDeCassioExiste := err;
end;


function CreeFichierTexteDeCassio(nom : str255; var fic : FichierTEXT) : OSErr;
const tailleMaxNom=31;
var err : OSErr;
    len,posLastDeuxPoints : SInt16; 
begin
  err := -1;
  posLastDeuxPoints := LastPos(':',nom);
  len := Length(nom)-posLastDeuxPoints;
  if len<=tailleMaxNom then
    begin
      err := CreeFichierTexte(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
    end;
  nom := nom+' (1)';
  len := Length(nom)-posLastDeuxPoints;
  if len<=tailleMaxNom then
    begin
      if (err<>NoErr)
        then err := CreeFichierTexte(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
    end;
  nom := nom+'(2)';
  len := Length(nom)-posLastDeuxPoints;
  if len<=tailleMaxNom then
    begin
      if (err<>NoErr)
        then err := CreeFichierTexte(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
    end;
  CreeFichierTexteDeCassio := err;
end;

procedure AlerteSimpleFichierTexte(nomFichier : string;erreurES : SInt32);
CONST TextesErreursID       = 10016;
var s : str255;
begin
  GetIndString(s,TextesErreursID,5);  {'erreur I/O sur fichier Ç^0È ! code erreur= ^1'}
  s := ParamStr(s,nomFichier,NumEnString(erreurES),'','');
  AlerteSimple(s);
end;




procedure SetAfficheInfosApprentissage(flag : boolean);
begin
  afficheInfosApprentissage := flag;
end;

function GetAfficheInfosApprentissage() : boolean;
begin
  GetAfficheInfosApprentissage := afficheInfosApprentissage;
end;


end.
