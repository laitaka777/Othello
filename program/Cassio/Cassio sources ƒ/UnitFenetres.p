UNIT UnitFenetres;



INTERFACE








USES MyTypes,StringTypes;


{ Ouverture des fenetres }
procedure OuvreFntrGestion(avecAnimationZoom : boolean);
procedure OuvreFntrReflex(avecAnimationZoom : boolean);
procedure OuvreFntrListe(avecAnimationZoom : boolean);
procedure OuvreFntrStat(avecAnimationZoom : boolean);
procedure OuvreFntrCommentaires(avecAnimationZoom : boolean);
procedure OuvreFntrPalette;
procedure OuvreFntrCourbe(avecAnimationZoom : boolean);
procedure OuvreFntrAide;
procedure OuvreFntrPlateau(avecAnimationZoom : boolean);
procedure OuvrirLesFenetresDansLOrdre;


{ Fermeture des fenetres }
procedure CloseProgramWindow;
procedure CloseCourbeWindow;
procedure CloseAideWindow;
procedure CloseGestionWindow;
procedure CloseReflexWindow;
procedure CloseListeWindow;
procedure CloseStatWindow;
procedure CloseCommentairesWindow;
procedure ClosePaletteWindow;
procedure MasquerToutesLesFenetres;
function VeutVraimentFermerFenetre() : boolean;


{ Empilement des fenetres }
procedure EmpileFenetresSousPalette;
procedure EmpileFenetres;
function FenetreFictiveAvantPlan() : WindowPtr;


{ Acces aux fenetres }
function WindowDeCassio(whichWindow : WindowPtr) : boolean;
function WindowPlateauSousDAutresFenetres() : boolean;
function FrontWindowSaufPalette() : WindowPtr;
function OrdreFenetre(whichWindow : WindowPtr) : SInt16; 
function GetArbreDeJeuWindow() : WindowPtr;
function PaletteEstSurCeDialogue(dp : DialogPtr) : boolean;
function GetOrdreEmpilementDesFenetresEnChaine():str10;


{ Activation/Desactivation d'une fenetre }
procedure SelectWindowSousPalette(whichWindow : WindowPtr);
procedure DeactivateFrontWindowSaufPalette();
procedure DoActivateWindow(whichWindow : WindowPtr;activation : boolean);


{ Procedure de dessin dans des fenetres }
procedure EssaieSetPortWindowPlateau;
procedure MetTitreFenetrePlateau;
procedure DessineBoiteDeTaille(whichWindow : WindowPtr);
procedure DessineBoiteAscenseurDroite(whichWindow : WindowPtr);
procedure DrawScrollBars(whichWindow : WindowPtr);
procedure InvalidateAllWindows;


{ Redimensionnement des fenetres }
procedure DoGrowWindow(thisWindow : WindowPtr;event : eventRecord);
procedure MyZoomInOut(window : WindowPtr;partcode : SInt16);


{ Mise a jour des contenus des fenetres }
procedure DrawContentsRapide(whichWindow : WindowPtr);
procedure DoUpdateWindowRapide(whichWindow : WindowPtr);
procedure NoUpdateThisWindow(whichWindow : WindowPtr);
procedure NoUpdateWindowPlateau;
procedure NoUpdateWindowListe;
procedure DoGlobalRefresh;


IMPLEMENTATION







USES UnitOth1,UnitAffichageReflexion,UnitCarbonisation,UnitJaponais,UnitOth2,UnitGestionDuTemps,
     UnitListe,UnitRapportImplementation,UnitServicesDialogs,SNStrings,UnitStatistiques,
     UnitTroisiemeDimension,Unit3DPovRayPicts,UnitEntreeTranscript,UnitDialog,UnitServicesRapport,
     UnitCourbe,UnitVieilOthelliste;




procedure DeactivateFrontWindowSaufPalette();
var whichWindow : WindowPtr;
begin
  whichWindow := FrontWindowSaufPalette();
  if whichWindow <> NIL then
    begin
      HiliteWindow(whichWindow,false);
      DoActivateWindow(whichWindow,false);
    end;
end;


procedure OuvreFntrGestion(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : str255;
begin
   GetIndString(titre,TitresFenetresTextID,8);
   if (wPalettePtr <> NIL) & windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan();
   wGestionPtr := NewCWindow(NIL,FntrGestionRect,titre,false,documentProc,behind,true,0);
   windowGestionOpen := ( wGestionPtr <> NIL );
   if windowGestionOpen then
     begin
        DeactivateFrontWindowSaufPalette();
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        rect2 := FntrGestionRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        if avecAnimationZoom & not(SupprimerLesEffetsDeZoom) then 
          ZoomRect(rect1,rect2,kZoomOut,6,true);
        ShowHide(wGestionPtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wGestionPtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wGestionPtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wGestionPtr));
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcOr);
        TextFace(normal); 
        TextFont(gCassioApplicationFont);
        EraseRect(GetWindowPortRect(wGestionPtr));
     end;
end;

procedure OuvreFntrReflex(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : str255;
begin
   GetIndString(titre,TitresFenetresTextID,7);
   if (wPalettePtr <> NIL) & windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan();
   wReflexPtr := NewCWindow(NIL,FntrReflexRect,titre,false,documentProc,behind,true,0);
   windowReflexOpen := ( wReflexPtr <> NIL );
   if windowReflexOpen then
     begin
        DeactivateFrontWindowSaufPalette();
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        if windowPaletteOpen & (wPalettePtr <> NIL) then 
          GetRectDansPalette(PaletteReflexion,rect1);
        rect2 := FntrReflexRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        if avecAnimationZoom & not(SupprimerLesEffetsDeZoom) then 
          ZoomRect(rect1,rect2,kZoomOut,6,true);
        ShowHide(wReflexPtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wReflexPtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wReflexPtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wReflexPtr));
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcBic);
        TextFace(normal); 
        TextFont(gCassioApplicationFont);
        EraseRect(GetWindowPortRect(wReflexPtr));
     end;
end;

procedure OuvreFntrListe(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : str255;
begin
   GetIndString(titre,TitresFenetresTextID,3);
   if (wPalettePtr <> NIL) & windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan();
   wListePtr := NewCWindow(NIL,FntrListeRect,titre,false,zoomDocProc,behind,true,0);
   windowListeOpen := ( wListePtr <> NIL );
   if windowListeOpen then
     begin
        DeactivateFrontWindowSaufPalette();
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        if windowPaletteOpen & (wPalettePtr <> NIL) then
          GetRectDansPalette(PaletteListe,rect1);
        rect2 := FntrListeRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        if avecAnimationZoom & not(SupprimerLesEffetsDeZoom) then 
          ZoomRect(rect1,rect2,kZoomOut,6,true);
        ShowHide(wListePtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wListePtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr));
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcOr);
        TextFace(normal); 
        TextFont(gCassioApplicationFont);
        EraseRect(GetWindowPortRect(wListePtr));
        OuvreControlesListe;
        DessineBoiteDeTaille(wListePtr);
     end;
end;

procedure OuvreFntrStat(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : str255;
begin
   GetIndString(titre,TitresFenetresTextID,4);
   if (wPalettePtr <> NIL) & windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan();
   wStatPtr := NewCWindow(NIL,FntrStatRect,titre,false,documentProc,behind,true,0);
   windowStatOpen := ( wStatPtr <> NIL );
   if windowStatOpen then
     begin
        DeactivateFrontWindowSaufPalette();
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        if windowPaletteOpen & (wPalettePtr <> NIL) then
          GetRectDansPalette(PaletteStatistique,rect1);
        rect2 := FntrStatRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        if avecAnimationZoom & not(SupprimerLesEffetsDeZoom) then 
          ZoomRect(rect1,rect2,kZoomOut,6,true);
        ShowHide(wStatPtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wStatPtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr));
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcBic);
        TextFace(normal); 
        TextFont(gCassioApplicationFont);
        EraseRect(GetWindowPortRect(wStatPtr));
        DessineBoiteDeTaille(wStatPtr);
     end;
end;

procedure OuvreFntrCommentaires(avecAnimationZoom : boolean);
const CommentairesID = 2000;
      CommentaireStaticTextID = 1;
var behind : WindowPtr;
    rect1,rect2 : rect;
begin
  with arbreDeJeu do
    begin
		  if (wPalettePtr <> NIL) & windowPaletteOpen
		     then behind := wPalettePtr
		     else behind := FenetreFictiveAvantPlan();
		   theDialog := GetNewDialog(CommentairesID,NIL,behind);
		   windowOpen := (arbreDeJeu.theDialog <> NIL);
		   if windowOpen then
		     begin
		       DeactivateFrontWindowSaufPalette();
		       SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
		       rect2 := FntrCommentairesRect;
		       rect2.top := rect2.top-18;
		       InsetRect(rect2,-1,-1);
		       if avecAnimationZoom & not(SupprimerLesEffetsDeZoom) then 
             ZoomRect(rect1,rect2,kZoomOut,6,true);
		       SetPortByDialog(theDialog);
		       if gCassioUseQuartzAntialiasing
             then EnableQuartzAntiAliasingThisPort(GetDialogPort(theDialog),true)
             else DisableQuartzAntiAliasingThisPort(GetDialogPort(theDialog));
		       BackPat(whitePattern);
		       TextSize(gCassioSmallFontSize);
		       TextMode(0);
		       TextFace(normal); 
		       TextFont(gCassioApplicationFont);
		       
		       with FntrCommentairesRect do
		         begin
		           MoveWindow(GetArbreDeJeuWindow(),left,top,false);
		           SizeWindow(GetArbreDeJeuWindow(),right-left,bottom-top,true);
		         end;
		       
		       ShowHide(GetArbreDeJeuWindow(),true);
		       
		       ChangeDelimitationEditionRectFenetreArbreDeJeu(positionLigneSeparation);
		       
		       EmpileFenetresSousPalette;
		       SetPortByDialog(arbreDeJeu.theDialog);
		     end;
		 end;
end;

procedure OuvreFntrPalette;
var behind : WindowPtr;
    titre : str255;
begin
   GetIndString(titre,TitresFenetresTextID,2);
   behind := FenetreFictiveAvantPlan();
   
   if false & gIsRunningUnderMacOSX then
     begin
       inc(FntrPaletteRect.right); 
       inc(FntrPaletteRect.bottom);
     end;
     
   wPalettePtr := NewCWindow(NIL,FntrPaletteRect,titre,false,kWindowFloatProc,behind,true,0);
   {wPalettePtr := NewCWindow(NIL,FntrPaletteRect,titre,false,PaletteDefID*16,behind,true,0);}
   windowPaletteOpen := ( wPalettePtr <> NIL );
   if windowPaletteOpen then
     begin
        ShowHide(wPalettePtr,true);
        ShowWindow(wPalettePtr);
        BringToFront(wPalettePtr);
        SelectWindow(wPalettePtr);
        
        
        SetPortByWindow(wPalettePtr);
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcBic);
        TextFace(normal); 
        TextFont(gCassioApplicationFont);
        EraseRect(GetWindowPortRect(wPalettePtr));
        DessinePalette;
        
        EmpileFenetresSousPalette;
     end;
end;


procedure OuvreFntrCourbe(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : str255;
begin
   GetIndString(titre,TitresFenetresTextID,6);
   if (wPalettePtr <> NIL) & windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan();
   wCourbePtr := NewCWindow(NIL,FntrCourbeRect,titre,false,zoomDocProc,behind,true,0);
   windowCourbeOpen := ( wCourbePtr <> NIL );
   if windowCourbeOpen then
     begin
        DeactivateFrontWindowSaufPalette();
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        if windowPaletteOpen & (wPalettePtr <> NIL) then
          GetRectDansPalette(PaletteCourbe,rect1);
        rect2 := FntrCourbeRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        if avecAnimationZoom & not(SupprimerLesEffetsDeZoom) then 
          ZoomRect(rect1,rect2,kZoomOut,6,true);
        ShowHide(wCourbePtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wCourbePtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr),true)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr));
        TextSize(gCassioSmallFontSize);
        TextMode(srcBic);
        TextFace(normal); 
        TextFont(gCassioApplicationFont);
     end;
end;


procedure OuvreFntrAide;
var behind : WindowPtr;
    titre : str255;
begin
   GetIndString(titre,TitresFenetresTextID,10);
   if (wPalettePtr <> NIL) & windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan();
     
   wAidePtr := NewCWindow(NIL,FntrAideRect,titre,false,zoomDocProc,behind,true,0);
   windowAideOpen := ( wAidePtr <> NIL );
   if windowAideOpen then
     begin
       DeactivateFrontWindowSaufPalette();
       ShowHide(wAidePtr,true);
       EmpileFenetresSousPalette;
       SetPortByWindow(wAidePtr);
       if gCassioUseQuartzAntialiasing
         then EnableQuartzAntiAliasingThisPort(GetWindowPort(wAidePtr),true)
         else DisableQuartzAntiAliasingThisPort(GetWindowPort(wAidePtr));
       TextSize(gCassioSmallFontSize);
       TextMode(srcBic);
       TextFace(normal);
       TextFont(gCassioApplicationFont);
     end;
end;

procedure OuvreFntrPlateau(avecAnimationZoom : boolean);
const FenetreOthellierID = 128;
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : str255;
begin
   
   GetIndString(titre,TitresFenetresTextID,1);
   behind := NIL;
   
   wPlateauPtr := NewCWindow(NIL,FntrPlatRect,titre,false,zoomDocProc,behind,false,0);
   windowPlateauOpen := ( wPlateauPtr <> NIL );
   if windowPlateauOpen then
     begin
    
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        rect2 := FntrPlatRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-2,-2);
          
        if avecAnimationZoom & not(SupprimerLesEffetsDeZoom) then 
          ZoomRect(rect1,rect2,kZoomOut,6,true);
        {ShowHide(wPlateauPtr,true);}
        
        EmpileFenetresSousPalette;
        SetPortByWindow(wPlateauPtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
          
        BackPat(fond);
        EraseRect(GetWindowPortRect(wPlateauPtr));
        
        PrepareTexteStatePourHeure;
        if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
          then 
            begin
              SetAffichageResserre(false);
            end
          else
            begin
              
              genreAffichageTextesDansFenetrePlateau := kAffichageAere;
              SetTailleCaseCourante(CalculeTailleCaseParPlateauRect(aireDeJeu));
              if GetTailleCaseCourante() <= 0 then SetTailleCaseCourante(TailleCaseIdeale());
              
              if avecSystemeCoordonnees 
                then SetPositionPlateau2D(8,GetTailleCaseCourante(),PositionCoinAvecCoordonnees,PositionCoinAvecCoordonnees,'OuvreFntrPlateau')
                else SetPositionPlateau2D(8,GetTailleCaseCourante(),PositionCoinSansCoordonnees,PositionCoinSansCoordonnees,'OuvreFntrPlateau');
              SetPositionsTextesWindowPlateau;
            end;
        MyEnableItem(PartieMenu,0);
        DrawMenuBar;
        
        if gCassioUseQuartzAntialiasing then
	        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
        
        doitAjusterCurseur := true;
        AjusteCurseur;
     end;
end;



procedure CloseProgramWindow;
var fermeture : boolean;
    oldPort : grafPtr;
  begin
    if windowPlateauOpen then
      begin
        fermeture := true;
        if not(Quitter) then fermeture := VeutVraimentFermerFenetre();
        if fermeture then
          begin
            GetPort(oldport);
            SetPortByWindow(wPlateauPtr);
            FntrPlatRect := GetWindowPortRect(wPlateauPtr);
            LocalToGlobal(FntrPlatRect.topleft);
            LocalToGlobal(FntrPlatRect.botright);
            SetPort(oldport);
            windowPlateauOpen := false;
            MyDisableItem(PartieMenu,0);
            DrawMenuBar;
            gameOver := true;
            LanceInterruption(interruptionSimple,'CloseProgramWindow');
            vaDepasserTemps := false;  
            AjusteCurseur;
            SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
            CloseZoomRectFrom := FntrPlatRect;
            CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
            InsetRect(CloseZoomRectFrom,-2,-2);
            if wPlateauPtr <> NIL then DisposeWindow(wPlateauPtr);
            wPlateauPtr := NIL;
            EssaieSetPortWindowPlateau;
            EmpileFenetresSousPalette;
          end;
      end;
  end;

procedure CloseCourbeWindow;
var oldPort : grafPtr;
  begin
    if windowCourbeOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wCourbePtr);
      FntrCourbeRect := GetWindowPortRect(wCourbePtr);
      LocalToGlobal(FntrCourbeRect.topleft);
      LocalToGlobal(FntrCourbeRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      if windowPaletteOpen & (wPalettePtr <> NIL) then
        GetRectDansPalette(PaletteCourbe,CloseZoomRectTo);
      CloseZoomRectFrom := FntrCourbeRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);
      windowCourbeOpen := false;  
      AjusteCurseur;
      if wCourbePtr <> NIL then DisposeWindow(wCourbePtr);
      wCourbePtr := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
    end;
  end;

procedure CloseAideWindow;
var oldPort : grafPtr;
  begin
    if windowAideOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wAidePtr);
      FntrAideRect := GetWindowPortRect(wAidePtr);
      LocalToGlobal(FntrAideRect.topleft);
      LocalToGlobal(FntrAideRect.botright);
      SetPort(oldport);
      windowAideOpen := false;  
      AjusteCurseur;
      if wAidePtr <> NIL then DisposeWindow(wAidePtr);
      wAidePtr := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
    end;
  end;
  
procedure CloseGestionWindow;
var oldPort : grafPtr;
  begin
    if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);
      FntrGestionRect := GetWindowPortRect(wGestionPtr);
      LocalToGlobal(FntrGestionRect.topleft);
      LocalToGlobal(FntrGestionRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      CloseZoomRectFrom := FntrGestionRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      windowGestionOpen := false;  
      afficheGestionTemps := false;
      InsetRect(CloseZoomRectFrom,-1,-1);
      AjusteCurseur;
      if wGestionPtr <> NIL then DisposeWindow(wGestionPtr);
      wGestionPtr := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
      if affichageReflexion.doitAfficher then EcritReflexion;
    end;
  end;

procedure CloseReflexWindow;
var oldPort : grafPtr;
  begin
    if windowReflexOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wReflexPtr);
      FntrReflexRect := GetWindowPortRect(wReflexPtr);
      LocalToGlobal(FntrReflexRect.topleft);
      LocalToGlobal(FntrReflexRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      if windowPaletteOpen & (wPalettePtr <> NIL) then
        GetRectDansPalette(PaletteReflexion,CloseZoomRectTo);
      CloseZoomRectFrom := FntrReflexRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);
      windowReflexOpen := false;  
      affichageReflexion.doitAfficher := false;
      AjusteCurseur;
      if wReflexPtr <> NIL then DisposeWindow(wReflexPtr);
      wReflexPtr := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
    end;
  end;
  
procedure CloseListeWindow;
var oldPort : grafPtr;
  begin
    if windowListeOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wListePtr);
      FntrListeRect := GetWindowPortRect(wListePtr);
      LocalToGlobal(FntrListeRect.topleft);
      LocalToGlobal(FntrListeRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      if windowPaletteOpen & (wPalettePtr <> NIL) then
        GetRectDansPalette(PaletteListe,CloseZoomRectTo);
      CloseZoomRectFrom := FntrListeRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);
      
      CloseControlesListe;
      if wListePtr <> NIL then DisposeWindow(wListePtr);
      wListePtr := NIL;
      windowListeOpen := false; 
      
      SaveInfosFermetureListePartie(infosListeParties,infosListePartiesDerniereFermeture);
      InvalidateJustificationPasDePartieDansListe;
      
      EmpileFenetresSousPalette;
      EssaieSetPortWindowPlateau;
      if not(Quitter) then
        if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) & not(windowListeOpen | windowStatOpen) 
          then
            begin
              AjusteAffichageFenetrePlatRapide;
              EcranStandard(NIL,false);
            end
          else
            begin
              SetAffichageVertical;
              DessineAffichageVertical;  
            end;  
      AjusteCurseur;
    end;
  end;

procedure CloseStatWindow;
var oldPort : grafPtr;
  begin
    if windowStatOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wStatPtr);
      FntrStatRect := GetWindowPortRect(wStatPtr);
      LocalToGlobal(FntrStatRect.topleft);
      LocalToGlobal(FntrStatRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      if windowPaletteOpen & (wPalettePtr <> NIL) then 
        GetRectDansPalette(PaletteStatistique,CloseZoomRectTo);
      CloseZoomRectFrom := FntrStatRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);
      windowStatOpen := false;  
      if wStatPtr <> NIL then DisposeWindow(wStatPtr);
      wStatPtr := NIL;
      EmpileFenetresSousPalette;
      EssaieSetPortWindowPlateau;
      if not(Quitter) then
        if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) & not(windowListeOpen | windowStatOpen) 
          then
            begin
              AjusteAffichageFenetrePlatRapide;
              EcranStandard(NIL,false);
            end
          else
            begin
              SetAffichageVertical;
              DessineAffichageVertical;  
            end;  
      AjusteCurseur;
    end;
  end;

procedure CloseCommentairesWindow;
var oldPort : grafPtr;
begin
  with arbreDeJeu do
  if windowOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(GetArbreDeJeuWindow());
      FntrCommentairesRect := GetWindowPortRect(GetArbreDeJeuWindow());
      LocalToGlobal(FntrCommentairesRect.topleft);
      LocalToGlobal(FntrCommentairesRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      CloseZoomRectFrom := FntrCommentairesRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);
      
      if enModeEdition then
        begin
          enModeEdition := false;
          doitResterEnModeEdition := false;
          GetCurrentScript(gLastScriptUsedInDialogs);
          SwitchToRomanScript;
        end;
      windowOpen := false;
      if theDialog <> NIL then DisposeDialog(theDialog);
      theDialog := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
    end;
end;


procedure ClosePaletteWindow;
var oldPort : grafPtr;
  begin
    if windowPaletteOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wPalettePtr);
      FntrPaletteRect := GetWindowPortRect(wPalettePtr);
      LocalToGlobal(FntrPaletteRect.topleft);
      LocalToGlobal(FntrPaletteRect.botright);
      
      if false & gIsRunningUnderMacOSX then
			   begin
			     dec(FntrPaletteRect.right);
			     dec(FntrPaletteRect.bottom);
			   end;
     
      SetPort(oldport);
      windowPaletteOpen := false;  
      AjusteCurseur;
      if wPalettePtr <> NIL then DisposeWindow(wPalettePtr);
      wPalettePtr := NIL;
      EssaieSetPortWindowPlateau;
    end;
  end;


procedure DrawScrollBars(whichWindow : WindowPtr);
  var vbarrect : rect;
      hbarrect : rect;
      gbrect : rect;
  begin
    DessineBoiteDeTaille(whichWindow);
    CalculateControlRects(whichWindow,hbarrect,vbarrect,gbrect);
    ValidRect(hbarrect);
    ValidRect(vbarrect);
    ValidRect(gbrect);
  end;


function GetArbreDeJeuWindow() : WindowPtr;
begin
  if arbreDeJeu.theDialog = NIL
    then GetArbreDeJeuWindow := NIL
    else GetArbreDeJeuWindow := GetDialogWindow(arbreDeJeu.theDialog);
end;


procedure OuvrirLesFenetresDansLOrdre;
var i : SInt16; 
begin

  with VisibiliteInitiale do
    begin
		  
		  FntrPaletteRect.right  := FntrPaletteRect.left + 9 * largeurCasePalette - 1;
			FntrPaletteRect.bottom := FntrPaletteRect.top  + 2 * hauteurcasepalette - 1;
		                
      for i := Length(ordreOuvertureDesFenetres) downto 1 do
        case ordreOuvertureDesFenetres[i] of
          'O' : begin
                  { normalement, la fenetre de l'othellier devrait deja etre ouverte, 
                    mais on verifie quand meme, a tout hasard… }
                  if not(windowPlateauOpen) then
                    OuvreFntrPlateau(false);
                  if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) then 
                    SetAffichageResserre(false);
                end;
          'R' : begin
		              if tempowindowRapportOpen then
		                begin
		                  if not(CreateRapport()) 
                        then AlerteSimple(ReadStringFromRessource(TextesErreursID,2))
                		    else EcritBienvenueDansRapport;
		                  OuvreFntrRapport(false,false);
		                end;
                end;
          'S' : begin
                  if tempowindowStatOpen then 
						        begin
						          SetStatistiquesSontEcritesDansLaFenetreNormale(true);
						          OuvreFntrStat(false);   
						          EcritRubanStatistiques;
						        end;
                end;
          'L' : begin
                  if tempowindowListeOpen then 
						        begin
						          OuvreFntrListe(false);  
						          EcritRubanListe(false);
						        end;
						    end;
          'K' : begin
                  if tempowindowCourbeOpen then 
                    OuvreFntrCourbe(false);  
                end;
          'A' : begin
                  if tempowindowAideOpen then
                    OuvreFntrAide;
                end;
          'P' : begin
                  if tempowindowReflexOpen then 
                    OuvreFntrReflex(false);  
                end;
          'G' : begin
                  if tempowindowGestionOpen then 
                    OuvreFntrGestion(false);  
                end;
          'C' : begin
                  if tempowindowCommentairesOpen then 
                    OuvreFntrCommentaires(false);
                end;
          'T' : begin
								  if tempowindowPaletteOpen 
								    then OuvreFntrPalette;  
								end;
        end; {case}
    end;
  
  if not(GetWindowRapportOpen()) then
    begin
      if not(CreateRapport()) 
        then AlerteSimple(ReadStringFromRessource(TextesErreursID,2))
        else EcritBienvenueDansRapport;
    end;
                		    
  EmpileFenetresSousPalette;
end;


procedure EmpileFenetresSousPalette;
var whichWindow : WindowPtr;
    n : SInt16; 
    ok : boolean;
begin
  if not(windowPaletteOpen) | (wPalettePtr = NIL) then 
    begin
      EmpileFenetres;
      exit(EmpileFenetresSousPalette);
    end;
    
  if FrontWindow()<>wPalettePtr then 
    begin
      BringToFront(wPalettePtr);
      DessinePalette;
    end;
  n := 0;
  whichWindow := wPalettePtr;
  repeat
    if whichWindow = NIL 
      then ok := false
      else
        begin
			    whichWindow := MyGetNextWindow(whichWindow);
			    ok := WindowDeCassio(whichWindow);
			    if ok then
			      if IsWindowVisible(whichWindow) then
			        begin
			          inc(n);
			          if (n=1) 
			            then
			              begin
			                if not(IsWindowHilited(whichWindow)) then
			                  begin
			                    HiliteWindow(whichWindow,true);
			                    DoActivateWindow(whichWindow,true);
			                  end
			              end
			            else
			              begin
			                if IsWindowHilited(whichWindow) then
			                  begin
			                    HiliteWindow(whichWindow,false);
			                    DoActivateWindow(whichWindow,false);
			                  end
			              end;
			         end;
			  end;
  until not(ok);
  MetTitreFenetrePlateau;
end;


procedure EmpileFenetres;
var whichWindow : WindowPtr;
    n : SInt16; 
    ok : boolean;
begin
  n := 0;
  whichWindow := FrontWindow();
  ok := WindowDeCassio(whichWindow);
  repeat
    if ok & (whichWindow <> NIL) then
      begin
        if IsWindowVisible(whichWindow) then
          begin
            inc(n);
            if (n=1) 
              then
                begin
                  if not(IsWindowHilited(whichWindow)) then
                    begin
                      HiliteWindow(whichWindow,true);
                    end;
                  DoActivateWindow(whichWindow,true);
                end
              else
                begin
                  if IsWindowHilited(whichWindow) then
                    HiliteWindow(whichWindow,false);
                  DoActivateWindow(whichWindow,false);
                end;
          end;
        whichWindow := MyGetNextWindow(whichWindow);
        ok := WindowDeCassio(whichWindow);
      end;
  until (whichWindow = NIL) | not(ok);
  MetTitreFenetrePlateau;
end;


function FenetreFictiveAvantPlan() : WindowPtr;
begin
  FenetreFictiveAvantPlan := MakeMemoryPointer(-1);
end;


procedure DoGrowWindow(thisWindow : WindowPtr;event : eventRecord);
const CommenentaireTitreStaticText=1;
var growSize : SInt32;
    toucheOption,fenetreRedimensionnee : boolean;
    limitRect,unRect : rect;
    oldSizeRect,newSizeRect : rect;
    outNewContentRect : rect;
    oldPort : grafPtr;
    effaceFenetre,infosChangent : boolean;
    tailleboite : SInt16; 
begin
  if thisWindow = NIL then exit(DoGrowWindow);
  
  if (thisWindow = wPlateauPtr) & CassioEstEn3D() 
    then 
      begin
        SetRect(limitrect,64,64,GetTailleImagesPovRay().h  ,GetTailleImagesPovRay().v  );
        {SetRect(limitrect,64,64,GetTailleImagesPovRay().h+1,GetTailleImagesPovRay().v+1);}
      end
    else 
  if (thisWindow = wListePtr) 
    then
      SetRect(limitRect,64,64,LargeurNormaleFenetreListe(nbColonnesFenetreListe),30000)
    else
      SetRect(limitRect,64,64,30000,30000);
    
  if (thisWindow=wPlateauPtr) 
    then tailleboite := 16
    else tailleboite := 15;
    
  toucheOption := BAND(theEvent.modifiers,optionKey) <> 0;
  
  GetPort(oldport);
  SetPortByWindow(thisWindow);
  oldSizeRect := QDGetPortBound(); 
  
  fenetreRedimensionnee := ResizeWindow(thisWindow,event.where,@limitrect,@outNewContentRect);
  with outNewContentRect do
    growsize := (right - left) + 65536*(bottom - top);
  
  if fenetreRedimensionnee then
    begin
      
      effaceFenetre := (thisWindow=wCourbePtr) |
                       (thisWindow=wListePtr) |
                       ((thisWindow=wPlateauPtr) & enRetour) |
                       ((thisWindow=wPlateauPtr) & enSetUp) |
                       (EstLaFenetreDuRapport(thisWindow)) |
                       (thisWindow=GetArbreDeJeuWindow());
                       
      with GetWindowPortRect(thisWindow) do
        if effaceFenetre 
          then 
            begin
              EraseRect(GetWindowPortRect(thisWindow));
		          if EstLaFenetreDuRapport(thisWindow)
		            then ChangeWindowRapportSize(LoWrd(growsize),HiWrd(growsize))
		            else SizeWindow(thisWindow,LoWrd(growsize),HiWrd(growsize),false);
		          InvalRect(GetWindowPortRect(thisWindow));
		        end
		      else
		        begin
		         SetRect(unRect,right-tailleboite,bottom-tailleboite,right,bottom);
		         EraseRect(unRect);
		         InvalRect(unRect);
		         SizeWindow(thisWindow,LoWrd(growsize),HiWrd(growsize),true);
		         SetRect(unRect,right-tailleboite,bottom-tailleboite,right,bottom);
		         InvalRect(unRect);
		        end;
		        
      newSizeRect := QDGetPortBound();
      if (thisWindow=wPlateauPtr) then 
        begin
          SetPortByWindow(wPlateauPtr);
          infosChangent := false;
          if not(toucheOption) then 
            begin
              if ((newSizeRect.bottom - newSizeRect.top) > (oldSizeRect.bottom - newSizeRect.top)) | 
                  ((newSizeRect.right - newSizeRect.left)> (oldSizeRect.right-oldSizeRect.left)) then 
                begin
                  DessineBordureDuPlateau2D(kBordureDuBas+kBordureDeDroite);
                  EffaceTouteLaFenetreSaufLOthellier;
                  if (QDIsPortBuffered(GetWindowPort(wPlateauPtr))) then QDFlushPortBuffer(GetWindowPort(wPlateauPtr), NIL);
                end;
              AjusteAffichageFenetrePlat(0,effaceFenetre,infosChangent);
            end;
          if infosChangent | effaceFenetre | not(CassioEstEn3D()) | enSetUp | enRetour | EnModeEntreeTranscript()
            then InvalRect(GetWindowPortRect(wPlateauPtr));
          if infosChangent & not(CassioEstEn3D()) then
            begin
              SetRect(unRect,aireDeJeu.right+1,0,GetWindowPortRect(wPlateauPtr).right,GetWindowPortRect(wPlateauPtr).bottom);
              InvalRect(unRect);
            end;
          MetTitreFenetrePlateau;
        end;
      if (thisWindow=wListePtr) & (wListePtr <> NIL)
        then 
          begin
            AjustePositionAscenseurListe;
            AjustePouceAscenseurListe(true);
          end;
      if (thisWindow=GetArbreDeJeuWindow()) & (GetArbreDeJeuWindow() <> NIL) then
        begin
          GetDialogItemRect(arbreDeJeu.theDialog,CommenentaireTitreStaticText,unRect);
          ChangeDelimitationEditionRectFenetreArbreDeJeu(unRect.top+6 + (newSizeRect.bottom - oldSizeRect.bottom));
        end;
    end;
  
  SetPort(oldport);
end;


procedure MyZoomInOut(window : WindowPtr;partcode : SInt16);
var oldport : grafPtr;
begin
  {if has128KROM then}
    begin
      GetPort(oldport);
      SetPortByWindow(window);
      {if (window=wPlateauPtr)
        then EraseRectDansWindowPlateau(GetWindowPortRect(window))
        else EraseRect(GetWindowPortRect(window));}
      ZoomWindow(window,partcode,false);
      if (window=wPlateauPtr) & (BAND(theEvent.modifiers,optionKey)=0)
        then 
          begin
            AjusteTailleFenetrePlateauPourLa3D;
            AjusteAffichageFenetrePlatRapide;
          end;
      if EstLaFenetreDuRapport(window) then ChangeWindowRapportSize( -1, -1);
      SetPort(oldport);
    end;
end;


function  PaletteEstSurCeDialogue(dp : DialogPtr) : boolean;
var dialogRect,PaletteRect,inter : rect;
    oldPort : grafPtr;
begin

  if (dp = NIL) | not(windowPaletteOpen) | (wPalettePtr = NIL) then
    begin
      PaletteEstSurCeDialogue := false;
      exit(PaletteEstSurCeDialogue);
    end;

  PaletteEstSurCeDialogue := false;
  
  GetPort(oldPort);
  SetPortByDialog(dp);
  dialogRect := QDGetPortBound();
  LocalToGlobal(dialogRect.topleft);
  LocalToGlobal(dialogRect.botright);
  if windowPaletteOpen & (wPalettePtr <> NIL) & IsWindowVisible(wPalettePtr) then
    begin
      SetPortByWindow(wPalettePtr);
      PaletteRect := QDGetPortBound();
      LocalToGlobal(PaletteRect.topleft);
      LocalToGlobal(PaletteRect.botright);
      
      PaletteEstSurCeDialogue := SectRect(PaletteRect,dialogRect,inter);
      
    end;
  SetPort(oldPort);
  
end;


function GetOrdreEmpilementDesFenetresEnChaine():str10;
var s:str10;
    whichWindow : WindowPtr;
begin
  s:= '';
  
  whichWindow := FrontWindow();
  repeat
    if (whichWindow <> NIL) & WindowDeCassio(whichWindow) & IsWindowVisible(whichWindow) then
      begin
        if (whichWindow = wPalettePtr)           then s := s + 'T' else
        if (whichWindow = wStatPtr)              then s := s + 'S' else
        if (whichWindow = wListePtr)             then s := s + 'L' else
        if (whichWindow = wReflexPtr)            then s := s + 'P' else
        if (whichWindow = wCourbePtr)            then s := s + 'K' else
        if (whichWindow = wAidePtr)              then s := s + 'A' else
        if (whichWindow = wPlateauPtr)           then s := s + 'O' else
        if (whichWindow = wGestionPtr)           then s := s + 'G' else
        if (whichWindow = GetArbreDeJeuWindow()) then s := s + 'C' else
        if (whichWindow = GetRapportWindow())    then s := s + 'R';
      end;
    whichWindow := MyGetNextWindow(whichWindow);
  until (whichWindow = NIL) | not(WindowDeCassio(whichWindow));
  
  GetOrdreEmpilementDesFenetresEnChaine := s;
end;


procedure MasquerToutesLesFenetres;
begin
  (* on sauvegarde l'ordre d'empilement des fenetres pour pouvoir l'ecrire dans les preferences *)
  VisibiliteInitiale.ordreOuvertureDesFenetres := GetOrdreEmpilementDesFenetresEnChaine();
  
  (* on masque toutes les fenetres *)
  if windowPlateauOpen then ShowHide(wPlateauPtr,false);
  if windowCourbeOpen then ShowHide(wCourbePtr,false);
  if windowAideOpen then ShowHide(wAidePtr,false);
  if windowGestionOpen then ShowHide(wGestionPtr,false);
  if windowReflexOpen then ShowHide(wReflexPtr,false);
  if windowListeOpen then ShowHide(wListePtr,false);
  if windowStatOpen then ShowHide(wStatPtr,false);
  if windowRapportOpen then ShowHide(GetRapportWindow(),false);
  if windowPaletteOpen then ShowHide(wPalettePtr,false);
  if arbreDeJeu.windowOpen then ShowHide(GetArbreDeJeuWindow(),false);
  
  {donnons une chance aux autres applications de se redessiner}
  ShareTimeWithOtherProcesses(5);
end;


procedure DoActivateWindow(whichWindow : WindowPtr;activation : boolean);
var growRect : rect;
begin
  if whichWindow = NIL then exit(DoActivateWindow);
  
  if EstLaFenetreDuRapport(whichWindow)
    then 
      begin
        if activation
          then DoActivateRapport
          else DoDeactivateRapport;
      end
    else
      begin
        if (whichWindow = wListeptr)
          then DoActivateFenetreListe(activation);
         
        if whichWindow=GetArbreDeJeuWindow() then
          with arbreDeJeu do
	          begin
	            if not(activation) then 
	              begin
	                if enModeEdition then
	                  begin
	                    enModeEdition := false;
	                    GetCurrentScript(gLastScriptUsedInDialogs);
                      SwitchToRomanScript;
                    end;
	              end;
	            if enModeEdition
	              then 
	                begin
	                  SwitchToScript(gLastScriptUsedInDialogs);
	                  TEActivate(GetDialogTextEditHandle(theDialog));
	                end
	              else 
	                begin
	                  TEDeactivate(GetDialogTextEditHandle(theDialog));
	                end;
	            DessineZoneDeTexteDansFenetreArbreDeJeu(false);
	          end;
	          
        if activation
          then 
            begin
              if (whichWindow<>wPalettePtr) & (whichWindow<>IconisationDeCassio.theWindow) then
                begin
                  SetPortByWindow(whichWindow);
                  growRect := GetWindowPortRect(whichWindow);
                  growRect.left := growRect.right-15;
                  growRect.top := growRect.bottom-15;
                  InvalRect(growrect);
                end;
            end
          else 
            begin
              SetPortByWindow(whichWindow);
              DessineBoiteDeTaille(whichWindow); 
            end;
      end; 
end;


function WindowDeCassio(whichWindow : WindowPtr) : boolean;
begin
  if whichWindow = NIL
    then WindowDeCassio := false
    else WindowDeCassio := (whichWindow=wPlateauPtr)                   |
                           (whichWindow=wCourbePtr)                    |
                           (whichWindow=wAidePtr)                      |
                           (whichWindow=wReflexPtr)                    |
                           (whichWindow=wGestionPtr)                   |
                           (whichWindow=wListePtr)                     |
                           (whichWindow=wStatPtr)                      |
                           (EstLaFenetreDuRapport(whichWindow))        |
                           (whichWindow=iconisationDeCassio.theWindow) |
                           (whichWindow=GetArbreDeJeuWindow())         |
                           (whichWindow=wPalettePtr);
end;

function WindowPlateauSousDAutresFenetres() : boolean;
var test : boolean;
    whichWindow : WindowPtr;
begin
  test := windowPlateauOpen & WindowDeCassio(FrontWindow());
  test := test & (FrontWindow()<>wPlateauPtr);
  if test then
    begin
      whichWindow := FrontWindow();
      repeat
        if (whichWindow <> NIL) then
          whichWindow := MyGetNextWindow(whichWindow);
      until (whichWindow = NIL) | (whichWindow=wPlateauPtr) | not(WindowDeCassio(whichWindow));
      test := (whichWindow=wPlateauPtr);
    end;  
  windowPlateauSousDAutresFenetres := test;
end;


function FrontWindowSaufPalette() : WindowPtr;
var whichWindow : WindowPtr;
begin
  if not(windowPaletteOpen) 
    then
      begin
        FrontWindowSaufPalette := FrontWindow();
      end
    else
      begin
        whichWindow := FrontWindow();
        if (whichWindow <> NIL) & (whichWindow=wPalettePtr)
          then whichWindow := MyGetNextWindow(whichWindow);
          
        while (whichWindow <> NIL) & not(IsWindowVisible(whichWindow)) do
          whichWindow := MyGetNextWindow(whichWindow);
          
        {if (whichWindow <> NIL) & (whichWindow=wPalettePtr)
          then whichWindow := MyGetNextWindow(whichWindow);}
          
        FrontWindowSaufPalette := whichWindow;
      end;
end;

function OrdreFenetre(whichWindow : WindowPtr) : SInt16; 
const kOrdreFenetreDansLeLointain = 10000;
var windowAux : WindowPtr;
    n : SInt16; 
begin
  if (whichWindow <> NIL) & WindowDeCassio(whichWindow) & 
      IsWindowVisible(whichWindow) then
    begin
      n := 0;
      windowAux := FrontWindow();
      while (windowAux <> NIL) do
        begin
          if (windowAux=whichWindow) then
            begin
              OrdreFenetre := n;
              exit(OrdreFenetre);
            end;
          if IsWindowVisible(windowAux) then
            inc(n);
          windowAux := MyGetNextWindow(windowAux)
        end;
    end;
  OrdreFenetre := kOrdreFenetreDansLeLointain;
end;

procedure SelectWindowSousPalette(whichWindow : WindowPtr);
var ancienneFenetreActive : WindowPtr;
begin
  if whichWindow = NIL then exit(SelectWindowSousPalette);
    
  if not(windowPaletteOpen) | (whichWindow=wPalettePtr)
    then
      begin
        SelectWindow(whichWindow);
        EmpileFenetresSousPalette;
      end
    else
      begin  {on doit selectionner la premiere fenetre sous la palette}
        if sousEmulatorSousPC | true
          then   {methode sale : selectionner la fenetre, puis peindre la palette dessus}
            begin
              SelectWindow(whichWindow);
              EmpileFenetresSousPalette;
            end
          else   {methode propre, mais ne marche pas sous MacEmulator 2.0 !}
            begin 
              ancienneFenetreActive := FrontWindowSaufPalette();
              if ancienneFenetreActive<>whichWindow then
                begin
                  HiliteWindow(ancienneFenetreActive,false);
                  DoActivateWindow(ancienneFenetreActive,false);
                  SendBehind(whichWindow,wPalettePtr);
                end;
              HiliteWindow(whichWindow,true);
              DoActivateWindow(whichWindow,true);
            end;
       end;
  MetTitreFenetrePlateau;
end;



procedure InvalidateAllWindows;
begin
  if windowRapportOpen then InvalidateWindow(GetRapportWindow());
  if windowPlateauOpen then InvalidateWindow(wPlateauPtr);
  if windowListeOpen then InvalidateWindow(wListePtr);
  if windowGestionOpen then InvalidateWindow(wGestionPtr);
  if windowPaletteOpen then InvalidateWindow(wPalettePtr);
  if windowStatOpen then InvalidateWindow(wStatPtr);
  if windowCourbeOpen then InvalidateWindow(wCourbePtr);
  if windowAideOpen then InvalidateWindow(wAidePtr);
  if windowReflexOpen then InvalidateWindow(wReflexPtr);
  if arbreDeJeu.windowOpen then InvalidateWindow(GetArbreDeJeuWindow());
end;


procedure EssaieSetPortWindowPlateau;
begin
  if windowPlateauOpen & (wPlateauPtr <> NIL) 
    then SetPortByWindow(wPlateauPtr)
    else 
      begin
        if FrontWindow() <> NIL then
          if WindowDeCassio(FrontWindow()) then
            SetPortByWindow(FrontWindow());
      end;
end;


procedure DessineBoiteDeTaille(whichWindow : WindowPtr);
var oldPort : grafPtr;
    unRect : rect;
    oldClipRgn : RgnHandle;
    toujoursActivee : boolean;
begin

  if (whichWindow=wPalettePtr) |
     (whichWindow=iconisationDeCassio.theWindow) |
     (whichWindow = NIL) |
     ((whichWindow=wPlateauPtr) & CassioEstEn3D())
     then exit(DessineBoiteDeTaille);
     
  if WindowDeCassio(whichWindow) then
    begin
      {sysbeep(0);sysbeep(0);}
      {attendfrappeclavier;}
      
      GetPort(oldPort);
      SetPortByWindow(whichWindow);
      with GetWindowPortRect(whichWindow) do
        SetRect(unRect,right-15,bottom-15,right+1,bottom+1);
      
      if (whichWindow=wPlateauPtr) & not(gIsRunningUnderMacOSX) & false
        then 
          begin
            toujoursActivee := true;
            PenPat(whitePattern);
            PenSize(1,1);
            if (whichWindow=FrontWindowSaufPalette()) | toujoursActivee
              then
                begin
                  if whichWindow=wPlateauPtr then OffsetRect(unRect,-1,-1);
                  FrameRect(unRect);
                  InsetRect(unRect,1,1);
                  EraseRect(unRect);
                  SetRect(unRect,unRect.right-10,unRect.bottom-10,unRect.right-1,unRect.bottom-1);
                  FrameRect(unRect);
                  SetRect(unRect,unRect.right-11,unRect.bottom-11,unRect.right-4,unRect.bottom-4);          
                  EraseRect(unRect);
                  FrameRect(unRect);
                end
              else
                begin
                  FrameRect(unRect);
                  InsetRect(unRect,1,1);
                  EraseRect(unRect);
                end;
              PenPat(blackPattern);
          end
        else
          begin
            oldclipRgn := NewRgn();
            GetClip(oldClipRgn);
            unRect.top := unRect.top +1;
            ClipRect(unRect);
            PenPat(blackPattern);
            EraseRect(unRect);
            DrawGrowIcon(whichWindow);
            SetClip(oldClipRgn);    
            DisposeRgn(oldclipRgn); 
          end;
      SetPort(oldPort);
      
      {sysbeep(0);
      attendfrappeclavier;}
    end;
end;

procedure DessineBoiteAscenseurDroite(whichWindow : WindowPtr);
var oldPort : grafPtr;
    unRect : rect;
    oldClipRgn : RgnHandle;
    toujoursActivee : boolean;
begin
  toujoursActivee := true;
  if whichWindow <> NIL then
    begin
      GetPort(oldPort);
      SetPortByWindow(whichWindow);
      with GetWindowPortRect(whichWindow) do
        SetRect(unRect,right-15,top-1+hauteurRubanListe,right+1,bottom-15);
      
      
      oldclipRgn := NewRgn();
      GetClip(oldClipRgn);
      ClipRect(unRect);
      PenSize(1,1);
      PenPat(blackPattern);
      DrawGrowIcon(whichWindow);
      Moveto(unRect.left,unRect.top);
      Lineto(unRect.right,unRect.top);
      
      
      SetClip(oldClipRgn);    
      DisposeRgn(oldclipRgn); 
      SetPort(oldPort);
    end;
end;


procedure MetTitreFenetrePlateau;
var s,currentTitle : str255;
    largEspace,largString,i,n : SInt16; 
    oldPort : grafPtr;
begin
  if windowPlateauOpen & not(Quitter) then
    begin
      GetWTitle(wPlateauPtr,currentTitle);
      if gameOver 
        then 
          begin
            s := NumEnString(nbreDePions[pionNoir])+StringOf('-')+NumEnString(nbreDePions[pionBlanc]);
            if not(IsWindowHilited(wPlateauPtr)) then
              if (windowListeOpen | windowStatOpen | windowRapportOpen | windowAideOpen | 
                  windowGestionOpen | windowCourbeOpen | windowReflexOpen) then
                if not(CassioEstEn3D()) then 
                  begin
                    GetPort(oldPort);
                    SetPortByWindow(wPlateauPtr);
                    TextFont(systemFont);
                    TextSize(0);
                    TextFace(normal);
                    largString := StringWidth(s);
                    largEspace := StringWidth(' ');
                    if gWindowsHaveThickBorders
                      then n := (GetWindowPortRect(wPlateauPtr).left+GetWindowPortRect(wPlateauPtr).right)-(aireDeJeu.left+aireDeJeu.right)
                      else n := (GetWindowPortRect(wPlateauPtr).left+GetWindowPortRect(wPlateauPtr).right)-(aireDeJeu.left+aireDeJeu.right) + (largString); 
		                {
		                WritelnStringAndNumDansRapport('n = ',n);
		                WritelnStringAndNumDansRapport('largEspace = ',largEspace);
		                }
		                for i := 1 to (n div largEspace) do s := s+StringOf(' ');
                    SetPort(oldPort);
                  end;
          end
        else 
          begin
            {GetIndString(s,TitresFenetresTextID,1);}  {'Othellier'}
            s := GetApplicationName('Cassio');
            if (s = 'Cassio') | (s = 'Cassio.app')
              then s := 'Cassio '+VersionDeCassioEnString();
          end;
      if (s <> currentTitle) then SetWTitle(wPlateauPtr,s);
    end;
end;


function FiltreConfirmationFermetureFenetre(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
begin
  FiltreConfirmationFermetureFenetre := false;
  if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(evt);
  with evt do
   if ((what = keyDown) | (what = autoKey)) &
      ((BAND(message,charcodemask)=EscapeKey) |
      ((BAND(message,charcodemask)=ord('.')) & (BAND(modifiers,cmdKey) <> 0)))
      then
        begin
          item := 1;
          FlashItem(dlog,item);
          FiltreConfirmationFermetureFenetre := true;
        end
      else
        FiltreConfirmationFermetureFenetre := FiltreClassique(dlog,evt,item);
end; 

function VeutVraimentFermerFenetre() : boolean;
const FermetureID=143;
      Annuler=1;
      Fermer=3;
var dp : DialogPtr;
    itemHit : SInt16; 
    FiltreConfirmationFermetureFenetreUPP : ModalFilterUPP;
    err : OSErr;
begin
  VeutVraimentFermerFenetre := true;
  BeginDialog;
  FiltreConfirmationFermetureFenetreUPP := NewModalFilterUPP(@FiltreConfirmationFermetureFenetre);
  dp := MyGetNewDialog(FermetureID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreConfirmationFermetureFenetreUPP,itemHit);
      until (itemHit=Annuler) | (itemHit=Fermer);
      MyDisposeDialog(dp);
      if (itemHit=Annuler) 
        then VeutVraimentFermerFenetre := false
        else VeutVraimentFermerFenetre := true;
    end;
  MyDisposeModalFilterUPP(FiltreConfirmationFermetureFenetreUPP);
  EndDialog;
end;


procedure DoUpdateWindowRapide(whichWindow : WindowPtr);
var oldport : grafPtr;
    visibleRgn : RgnHandle;
begin
  BeginUpdate(whichWindow);
  GetPort(oldport);
  SetPortByWindow(whichWindow);
  
  visibleRgn := NewRgn();
  if not(EmptyRgn(GetWindowVisibleRegion(whichWindow,visibleRgn))) 
    then DrawContentsRapide(whichWindow);
  DisposeRgn(visibleRgn);
  
  SetPort(oldport);
  EndUpdate(whichWindow);
end;


procedure NoUpdateThisWindow(whichWindow : WindowPtr);
begin
  if whichWindow <> NIL then
    begin
      BeginUpdate(whichWindow);
      EndUpdate(whichWindow);
    end;
end;

procedure NoUpdateWindowPlateau;
begin
  if windowPlateauOpen then
    NoUpdateThisWindow(wPlateauPtr);
end;

procedure NoUpdateWindowListe;
begin
  if windowListeOpen then
    NoUpdateThisWindow(wListePtr);
end;


procedure DoGlobalRefresh;
var oldport : grafPtr;
begin
  if globalRefreshNeeded then
    begin
      GetPort(oldport);
      if windowListeOpen then 
        begin
          SetPortByWindow(wListePtr);
          InvalRect(QDGetPortBound());
        end;
      if windowStatOpen then 
        begin
          SetPortByWindow(wStatPtr);
          InvalRect(QDGetPortBound());
        end;
      if FenetreRapportEstOuverte() then 
        begin
          SetPortByWindow(GetRapportWindow());
          InvalRect(QDGetPortBound());
        end;
      if arbreDeJeu.windowOpen then
        begin
          SetPortByWindow(GetArbreDeJeuWindow());
          InvalRect(QDGetPortBound());
        end;
      SetPort(oldport);
      globalRefreshNeeded := false;
    end;
end;


procedure DrawContentsRapide(whichWindow : WindowPtr);
var visibleRgn : RgnHandle;
begin
  if whichWindow=wPlateauPtr 
    then
      begin
        if enRetour 
          then 
            begin
              visibleRgn := NewRgn();
              DessineRetour(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),'DrawContentsRapide');
              DisposeRgn(visibleRgn);
            end
          else 
            if not(enSetUp) then 
              begin
                visibleRgn := NewRgn();
                EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),false);
                DisposeRgn(visibleRgn);
              end;
      end
    else
      if whichWindow=wCourbePtr 
        then 
          begin
            DessineCourbe(0,nbreCoup,kCourbeColoree,'DrawContentsRapide');
            DessineSliderFenetreCourbe;
          end
        else 
          if whichWindow=wGestionPtr 
          then EcritGestionTemps
          else
            if whichWindow=wReflexPtr 
            then EcritReflexion
            else
              if whichWindow=wListePtr 
              then 
                begin
                  EcritRubanListe(true);
                  if IsWindowHilited(wListePtr)
					          then MontrerAscenseurListe
					          else CacherAscenseurListe;
                  globalRefreshNeeded := true;
                end
              else
                if whichWindow=wStatPtr 
                  then 
                    begin
                      EcritRubanStatistiques;
                      globalRefreshNeeded := true;
                    end
                  else 
                    if EstLaFenetreDuRapport(whichWindow)
                      then 
                        begin
                          TEUpdate(GetWindowPortRect(GetRapportWindow()), GetTextEditRecordOfRapport());
                          DrawControls(GetRapportWindow());
                        end
                      else
                        if whichWindow=IconisationDeCassio.theWindow 
                          then 
                            begin
                              globalRefreshNeeded := true;
                            end
                          else
                            if whichWindow=GetArbreDeJeuWindow()
                              then
                                begin
                                  DessineZoneDeTexteDansFenetreArbreDeJeu(false);
                                  {globalRefreshNeeded := true;}
                                end
                              else
                                if whichWindow=wAidePtr
                                  then DessineAide(gAideCourante)
                                  else
                                    if whichWindow=wPalettePtr
                                      then DessinePalette;
  DessineBoiteDeTaille(whichWindow);
end;
  
  
  
END.









































































