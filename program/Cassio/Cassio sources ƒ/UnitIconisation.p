UNIT UnitIconisation;






INTERFACE







 
 

function InitUnitIconisationOK() : boolean;
function LibereMemoireIconisation() : boolean;

procedure CloseIconisationWindow;
procedure FabriquePictureIconisation;
procedure DessinePictureIconisation;
procedure DetruitPictureIconisation;
procedure RefletePositionCouranteDansPictureIconisation;
procedure DoUpdateIconisation;

procedure IconiserCassio;
procedure DeiconiserCassio;



IMPLEMENTATION







USES UnitRapportImplementation,UnitCarbonisation,UnitFenetres,UnitOth1,UnitMacExtras,
     UnitMenus,UnitNewGeneral,UnitDiagramFforum,UnitGestionDuTemps,SNStrings,UnitCouleur;


procedure SetValeursParDefautDiagIconisation(var ParamDiag:ParamDiagRec;typeDiagramme : SInt16);
begin
  begin
  with ParamDiag do
    begin
      TypeDiagrammeFFORUM := typeDiagramme;
      DecalageHorFFORUM := 0;
      DecalageVertFFORUM := 0;
      tailleCaseFFORUM := 11;
      if gWindowsHaveThickBorders | gIsRunningUnderMacOSX
        then  {Kaleidoscope s'occupe deja d'aŽrer le diagramme => pas de marge}
          begin
            epaisseurCadreFFORUM := 0.0;
            distanceCadreFFORUM := 0;
          end
        else
          begin
            epaisseurCadreFFORUM := 1.0;
            distanceCadreFFORUM := 1;
          end;
      if typeDiagramme=DiagrammePosition
       then
         begin
           PionsEnDedansFFORUM := true;
           nbPixelDedansFFORUM := 2;
         end
       else
         begin
           PionsEnDedansFFORUM := false;
           nbPixelDedansFFORUM := 0;
         end;
         
      if gEcranCouleur & ((gCouleurOthellier.menuID<>CouleurID) | true)
       then
         begin
           FondOthellierPatternFFORUM := kDarkGrayPattern;
           couleurOthellierFFORUM := QuickdrawColorToDiagramFforumColor(gCouleurOthellier.plusProcheCouleurDeBaseSansBlanc);
         end
       else
         begin
           FondOthellierPatternFFORUM := kDarkGrayPattern;
           couleurOthellierFFORUM := kCouleurDiagramBlanc;
         end;
         
      DessineCoinsDuCarreFFORUM := false;
      DessinePierresDeltaFFORUM := affichePierresDelta;
      EcritApres37c7FFORUM := false;
      EcritNomTournoiFFORUM := false;
      EcritNomsJoueursFFORUM := false;
      PoliceFFORUMID := CourierID; 
      CoordonneesFFORUM := false;
      NumerosSeulementFFORUM := false;
      TraitsFinsFFORUM := false;
    end;
end;

end;

function InitUnitIconisationOK() : boolean;
var s : str255;
begin
  with iconisationDeCassio do
    begin
      enCours := false;
      s := 'Cassio';
      {s := getApplicationName('Cassio');}
      
      
      if gIsRunningUnderMacOSX
        then theWindow := NewCWindow(NIL, IconisationRect, s, False, kWindowMovableModalDialogProc, FenetreFictiveAvantPlan(), false, 1)
        else theWindow := NewCWindow(NIL, IconisationRect, s, False, noGrowDocProc, FenetreFictiveAvantPlan(), false, 1);
      
      possible := (theWindow <> NIL);
      NewParamDiag(ParametresIconeOthellier);
      SetValeursParDefautDiagIconisation(ParametresIconeOthellier,DiagrammePosition);
      OthellierPicture := NIL;
    end;
  InitUnitIconisationOK := iconisationDeCassio.possible;
end;

function LibereMemoireIconisation() : boolean;
begin
  with iconisationDeCassio do
	 begin
	   DisposeWindow(theWindow);
	   theWindow := NIL;
	   enCours := false;
	   possible := false;
	   DisposeParamDiag(ParametresIconeOthellier);
	   DetruitPictureIconisation;
	 end;
  LibereMemoireIconisation := true;
end;

procedure CloseIconisationWindow;
begin
  with iconisationDeCassio do
    begin
	  SetPortByWindow(theWindow);
	  iconisationRect := GetWindowPortRect(iconisationDeCassio.theWindow);
	  LocalToGlobal(IconisationRect.topleft);
	  LocalToGlobal(IconisationRect.botright);
	  ShowHide(theWindow,false);
    end;
end;

procedure FabriquePictureIconisation;
var oldport : grafPtr;
    unrectDiag : rect;
    oldClipRgn : RgnHandle;
    chainePositionInitiale,chaineCoups : str255;
begin
  with IconisationDeCassio do
    begin
      GetPort(oldport);
      SetPortByWindow(theWindow);
      
      if enRetour
        then SetValeursParDefautDiagIconisation(ParametresIconeOthellier,DiagrammePartie)
        else SetValeursParDefautDiagIconisation(ParametresIconeOthellier,DiagrammePosition);
      SetParamDiag(ParametresIconeOthellier);
      
      oldClipRgn := NewRgn();
      Getclip(oldClipRgn);
      ClipRect(QDGetPortBound());
      SetRect(unrectDiag,0,0,LargeurDiagrammeFFORUM(), HauteurDiagrammeFFORUM());
      OthellierPicture := OpenPicture(unrectDiag);
      
      ParserPositionEtCoupsOthello8x8(PositionEtCoupIconeStr,chainePositionInitiale,chaineCoups);
      
      if enRetour
        then ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups)
        else 
          begin
            ConstruitPositionPicture(ConstruitChainePosition8x8(jeuCourant),chaineCoups);
            if ParametresIconeOthellier.DessinePierresDeltaFFORUM 
              then ConstruitPicturePionsDeltaCourants;
          end;
      ClosePicture;
      SetClip(oldclipRgn);
      DisposeRgn(oldclipRgn);
    
      SetPort(oldPort);
    end;
end;

procedure DetruitPictureIconisation;
begin
  with IconisationDeCassio do
    if OthellierPicture <> NIL then
      begin
        KillPicture(OthellierPicture);
        OthellierPicture := NIL;
      end;
end;

procedure DessinePictureIconisation;
var oldport : grafPtr;
begin
   with IconisationDeCassio do
     if OthellierPicture <> NIL then
	   begin
	     GetPort(oldport);
	     SetPortByWindow(theWindow);
	     DrawPicture(OthellierPicture,OthellierPicture^^.picframe);   
	     ValidRect(QDGetPortBound());
	     SetPort(oldport);
	   end;
end;

procedure RefletePositionCouranteDansPictureIconisation;
begin
  if IconisationDeCassio.encours then
    begin
  	  DetruitPictureIconisation;
  	  ConstruitPositionEtCoupDapresPartie(IconisationDeCassio.PositionEtCoupIconeStr);
  	  FabriquePictureIconisation;
  	  DessinePictureIconisation;
  	end;
end;

procedure DoUpdateIconisation;
var oldport: GrafPtr;
begin
  with IconisationDeCassio do
    begin
      GetPort(oldport);
      SetPortByWindow(theWindow);
      BeginUpdate(theWindow);
      DessinePictureIconisation;
      EndUpdate(theWindow);
      SetPort(oldport);
    end;
end;

procedure IconiserCassio;
var thePlateauRect,IconeRect : rect;
begin
  with iconisationDeCassio do
  if possible then
	 begin
	
	  enCours := true;
	  	  
	  thePlateauRect := GetWindowStructRect(wPlateauPtr);
	  IconeRect := GetWindowStructRect(theWindow);
	  HiliteWindow(theWindow,true);
	  if windowCourbeOpen then ShowHide(wCourbePtr,false);
	  if windowAideOpen then ShowHide(wAidePtr,false);
    if windowGestionOpen then ShowHide(wGestionPtr,false);
    if windowReflexOpen then ShowHide(wReflexPtr,false);
    if windowListeOpen then ShowHide(wListePtr,false);
    if windowStatOpen then ShowHide(wStatPtr,false);
    if windowRapportOpen then ShowHide(GetRapportWindow(),false);
    if windowPaletteOpen then ShowHide(wPalettePtr,false);
    if windowPlateauOpen then ShowHide(wPlateauPtr,false);
    if arbreDeJeu.windowOpen then ShowHide(GetArbreDeJeuWindow(),false);
    if not(SupprimerLesEffetsDeZoom) then
      ZoomRect(thePlateauRect,IconeRect,kzoomIn,6,true);
    ShowHide(iconisationDeCassio.theWindow,true);  
    SetPortByWindow(theWindow);    
    
    if enRetour then
      begin
        ConstruitPositionEtCoupPositionInitiale(PositionEtCoupIconeStr);
        FabriquePictureIconisation;
        DessinePictureIconisation;
        DetruitPictureIconisation;
      end;
    
    ConstruitPositionEtCoupDapresPartie(PositionEtCoupIconeStr);
    FabriquePictureIconisation;
    DessinePictureIconisation;
    
    DisableItemTousMenus;
    MyDisableItem(EditionMenu,0);
    MyDisableItem(PartieMenu,0);
    MyDisableItem(ModeMenu,0);
    MyDisableItem(JoueursMenu,0);
    MyDisableItem(BaseMenu,0);
    MyDisableItem(SolitairesMenu,0);
    MyDisableItem(AffichageMenu,0);
    if avecProgrammation then MyDisableItem(ProgrammationMenu,0);
    SetMenuItemText(GetFileMenu(),IconisationCmd,ReadStringFromRessource(MenusChangeantsID,16));{'Deiconiser'}
    DrawMenuBar;
    AjusteSleep;
    InitCursor;
	end;
end;


procedure DeiconiserCassio;
var thePlateauRect,IconeRect : rect;
begin
  with iconisationDeCassio do
    if possible then 
	begin
	  enCours := false;
	  
	  DetruitPictureIconisation;
	  
	  thePlateauRect := GetWindowStructRect(wPlateauPtr);
	  IconeRect := GetWindowStructRect(iconisationDeCassio.theWindow);
	  {CloseIconisationWindow;}
	  if not(SupprimerLesEffetsDeZoom) then
	    ZoomRect(IconeRect,thePlateauRect,kzoomOut,6,true);
	  CloseIconisationWindow;
	  if windowPlateauOpen then ShowHide(wPlateauPtr,true);
	  if EssaieUpdateEventsWindowPlateauProcEstInitialise 
	     then EssaieUpdateEventsWindowPlateauProc;
	  if windowCourbeOpen then ShowHide(wCourbePtr,true);
	  if windowAideOpen then ShowHide(wAidePtr,true);
    if windowGestionOpen then ShowHide(wGestionPtr,true);
    if windowReflexOpen then ShowHide(wReflexPtr,true);
    if windowListeOpen then ShowHide(wListePtr,true);
    if windowStatOpen then ShowHide(wStatPtr,true);
    if windowRapportOpen then ShowHide(GetRapportWindow(),true);
    if windowPaletteOpen then ShowHide(wPalettePtr,true);
    if arbreDeJeu.windowOpen then ShowHide(GetArbreDeJeuWindow(),true);
    if EssaieUpdateEventsWindowPlateauProcEstInitialise 
     then EssaieUpdateEventsWindowPlateauProc;
     
    EmpileFenetresSousPalette;
          
    MyEnableItem(EditionMenu,0);
    MyEnableItem(PartieMenu,0);
    MyEnableItem(ModeMenu,0);
    MyEnableItem(JoueursMenu,0);
    MyEnableItem(BaseMenu,0);
    MyEnableItem(SolitairesMenu,0);
    MyEnableItem(AffichageMenu,0);
    if avecProgrammation then MyEnableItem(ProgrammationMenu,0);
    SetMenuItemText(GetFileMenu(),IconisationCmd,ReadStringFromRessource(MenusChangeantsID,15));{'Iconiser'}
    if not(enSetUp) then
      begin
      EnableItemTousMenus;
      FixeMarquesSurMenus;
      FixeMarqueSurMenuBase;
      FixeMarqueSurMenuMode(nbreCoup);
      if enRetour then 
        begin
          DisableItemTousMenus;
          DisableTitlesOfMenusForRetour;
        end;
      end;
    DrawMenuBar;
    AjusteSleep;
    AjusteCurseur;
	end;
end;

end.