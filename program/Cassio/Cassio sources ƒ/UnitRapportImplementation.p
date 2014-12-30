UNIT UnitRapportImplementation;


INTERFACE







USES ControlDefinitions,Controls,Events,UnitOth0,UnitOthelloGeneralise,
     TextServices,TSMTE;



procedure InitUnitRapport;
function CreateRapport() : boolean;
function DetruitRapport() : boolean;

{fonctions d'acces aux champs du RapportRec}
function GetWindowRapportOpen() : boolean;
function GetRapportWindow() : WindowPtr;
function GetTextEditRecordOfRapport() : TEHandle;
function GetTSMDocOfRapport():TSMDocumentID;
function GetTSMTERecHandleOfRapport():TSMTERecHandle;
function GetVerticalScrollerOfRapport():ControlHandle;
function GetHorizontalScrollerOfRapport():ControlHandle;
function GetTailleMaximumOfRapport() : SInt32;
function GetProchaineAlerteRemplissageRapport() : SInt32;
procedure SetProchaineAlerteRemplissageRapport(tailleCritique : SInt32);

{fonctions de tests}
function EstLaFenetreDuRapport(whichWindow : WindowPtr) : boolean;
function FenetreRapportEstAuPremierPlan() : boolean;



procedure OuvreFntrRapport(avecAnimationZoom,forceSelectWindow : boolean);
procedure CloseRapportWindow;
procedure UpdateScrollersRapport;
procedure InvalScrollersRapport;
procedure CalculateViewAndDestRapport;
procedure TrackScrollingRapport(ch: ControlHandle; part: SInt16);
function MyTrackControlIndicatorPartRapport(theControl: ControlHandle) : SInt16; 
function MyClikLoopRapport() : boolean;
procedure ChangeWindowRapportSize(hSize,vSize : SInt16);
procedure DoUpdateRapport;
procedure DoActivateRapport;
procedure DoDeactivateRapport;
procedure ClicInRapport(evt : eventRecord);
procedure RedrawFenetreRapport;
procedure EcritBienvenueDansRapport;
function GetLongueurMessageBienvenueDansCassio() : SInt16; 
procedure DetruireSelectionDansRapport;
procedure SetDebutSelectionRapport(debut : SInt32);
procedure SetFinSelectionRapport(fin : SInt32);
procedure FrappeClavierDansRapport(whichChar : char);



{quelques fonction d'acces}
function CollerDansRapport() : boolean;
function CopierFromRapport() : boolean;
function CouperFromRapport() : boolean;
function EffacerDansRapport() : boolean;
function SelectionneToutDansRapport() : boolean;
procedure EffaceDernierCaractereDuRapportSync(scrollerSynchronisation : boolean);
procedure EffaceDernierCaractereDuRapport;
procedure PositionnePointDinsertion(index : SInt32);
function GetPositionPointDinsertion() : SInt32;
procedure SetDeroulementAutomatiqueDuRapport(flag : boolean);
function GetDeroulementAutomatiqueDuRapport() : boolean;
function FindStringInRapport(s : str255;from,direction : SInt32; var result : SInt32) : boolean;


procedure FinRapport;
procedure VoirLeDebutDuRapport;
procedure VoirLaFinDuRapport;
procedure ChangeFontFaceDansRapport(whichStyle : Style);
procedure ChangeFontSizeDansRapport(whichSize : SInt16);
procedure ChangeFontColorDansRapport(whichColor : SInt16);
procedure ChangeFontColorRGBDansRapport(whichColor : RGBColor);
procedure ChangeFontDansRapport(whichFont : SInt16);
procedure TextNormalDansRapport;
procedure ViewRectAGaucheRapport;
procedure AnnonceScoreFinalDansRapport;
procedure AnnonceOuvertureFichierEnRougeDansRapport(nomFichier : str255);
procedure AnnonceSupposeSuitConseilMac(numeroCoup,conseil : SInt16);
function NbLignesVisiblesDansRapport() : SInt16; 
function NbColonnesVisiblesDansRapport() : SInt16; 
procedure EcritKeyDownEventDansRapport(evt : eventRecord);


{Autovidage}
procedure SetAutoVidageDuRapportDansImplementation(flag : boolean);
function GetAutoVidageDuRapportDansImplementation() : boolean;

{Gestion du fichier "Rapport.log"}
procedure SetEcritToutDansRapportLogDansImplementation(flag : boolean);
function GetEcritToutDansRapportLogDansImplementation() : boolean;




IMPLEMENTATION







USES UnitOth2,UnitMacExtras,UnitFichiersTEXT,SmartScrollAPI,UnitJaponais,
     UnitOthelloGeneralise, UnitFenetres,UnitRetrograde,UnitPressePapier,
     UnitCarbonisation,Controls,UnitOth1,UnitServicesDialogs,UnitServicesRapport,
     UnitRapport,UnitDialog,UnitScannerOthellistique,SNStrings,UnitCouleur;


const  maxTextEditSize = MaxInt;     { taille maxi d'un enregistrement d'édition }
       hUnit = 7;                    { unité de défilement horizontal (colonne) du texte }
       vUnit = 12;
       TEdecalage=1;
       kControlSpecialDocumentTopPart    = -12437;
       kControlSpecialDocumentBottomPart = -12438;

type RapportRec = 
				record                       { un document }
					theWindow                  : WindowPtr;      { sa fenêtre }
					hScroller                  : ControlHandle;  { ascenseur horizontal }
					vScroller                  : ControlHandle;  { ascenseur vertical }
					theText                    : TEHandle;       { texte édité }
					changed                    : Boolean;        { vrai si texte modifié }
					fileName                   : STRING;         { nom du fichier }
					docTSMTERecHandle          : TSMTERecHandle; { pour rentrer du japonais avec le Text service Manager }
					docTSMDoc                  : TSMDocumentID;  { numero du document géré par le TSM }
					prochaineAlerteRemplissage : SInt32;        { taille max du texte de rapport avant l'alerte de remplissage}
					autoVidageDuRapport        : boolean;        { est a true si le rapport doit se vider sans alerte prealable}
					deroulementAutomatique     : boolean;        { est a true si on change l'affichage pour suivre le point d'insertion}
					ecritToutDansRapportLog    : boolean;        { a true, on ecrit aussi dans le fichier "rapport.log"}
				end;



var rapport:RapportRec;
    {myClickLoopRapportUPP:TEClickLoopUPP;}
    longueurMessageBienvenueDansCassio : SInt16; 


procedure InitUnitRapport;
begin
  rapport.theWindow := NIL;
  rapport.theText := NIL;
  rapport.docTSMTERecHandle := NIL;
  rapport.docTSMDoc := NIL;
  
  SetAutoVidageDuRapportDansImplementation(false);
  SetEcritToutDansRapportLogDansImplementation(false);
  
  longueurMessageBienvenueDansCassio := 0;
  
end;


function CreateRapport() : boolean;
var r: Rect;
    titre : str255;
    err : OSErr;
begin
  CreateRapport := false;
  rapport.theWindow := NIL;
  rapport.prochaineAlerteRemplissage := maxTextEditSize-2000;
  with rapport do
    begin
      GetIndString(titre,TitresFenetresTextID,5);
      theWindow := NewCWindow(NIL, FntrRapportRect, titre, False, zoomDocProc, FenetreFictiveAvantPlan(), True, 1);
      if theWindow <> NIL then
        begin
          SetPortByWindow(theWindow);
          TextFont(gCassioApplicationFont);
              
          if gIsRunningUnderMacOSX
            then TextSize(12)
            else TextSize(9);
          {TextSize(GetDefFontSize());}
              
          r := GetWindowPortRect(rapport.theWindow);
          InsetRect(r, TEdecalage, TEdecalage);
          theText := TEStyleNew(r, r);
          if theText <> NIL then
            begin
              { Adaptation de la taille standard de la fenêtre de telle façon que }
              { les lignes du texte ne soient jamais coupées en bas par l'ascenseur. }
              r := GetWindowPortRect(rapport.theWindow);
              while ((r.bottom - 15) - (r.top + TEdecalage)) MOD vUnit <> 0 do
                 dec(r.bottom);
              while ((r.right - 15) - (r.left + TEdecalage)) MOD hUnit <> 0 do
                 dec(r.right);
              SizeWindow(theWindow, r.right - r.left, r.bottom - r.top, False);
              CalculateViewAndDestRapport;
              SetDeroulementAutomatiqueDuRapport(true);
              
              {$IFC NOT GENERATINGPOWERPC}
              TESetClickLoop(@MyClikLoopRapport, theText);
              {$ENDC}

              { Création des deux ascenseurs }
              r := GetWindowPortRect(rapport.theWindow);
              InsetRect(r, -1, -1);
              r.top := r.bottom - 16;
              r.right := r.right - 15;
              hScroller := NewControl(theWindow, r, '', True, 1, 1, 210, scrollBarProc, 0);
              r := GetWindowPortRect(rapport.theWindow);
              InsetRect(r, -1, -1);
              r.left := r.right - 16;
              r.bottom := r.bottom - 15;
              vScroller := NewControl(theWindow, r, '', True, 1, 1, 1, scrollBarProc, 0);
              
              TextNormalDansRapport;
              
              err := AddTSMTESupport(theWindow,theText,GetTSMDocOfRapport,docTSMTERecHandle);
              
              SwitchToRomanScript;
              
              changed := False;
              fileName := '';
              CreateRapport := true;
            end;
        end;
   end;
end;


function DetruitRapport() : boolean;
begin
    DetruitRapport := True;
    with rapport do
       begin
         RemoveTSMTESupport(docTSMDoc);
         if (theText <> NIL) then
           begin
             TEDispose(theText);
             theText := NIL;
           end;
         if (theWindow <> NIL) then
           begin
             DisposeWindow(theWindow);
             theWindow := NIL;
           end;
         windowRapportOpen := false;
       end;
end;

function GetWindowRapportOpen() : boolean;
begin
  GetWindowRapportOpen := (windowRapportOpen & (rapport.theWindow <> NIL));
end;

function GetRapportWindow() : WindowPtr;
begin
  GetRapportWindow := rapport.theWindow;
end;

function GetTextEditRecordOfRapport() : TEHandle;
begin
  GetTextEditRecordOfRapport := rapport.theText;
end;

function GetTSMDocOfRapport():TSMDocumentID;
begin
  GetTSMDocOfRapport := rapport.docTSMDoc;
end;

function GetTSMTERecHandleOfRapport():TSMTERecHandle;
begin
  GetTSMTERecHandleOfRapport := rapport.docTSMTERecHandle;
end;

function GetVerticalScrollerOfRapport():ControlHandle;
begin
  GetVerticalScrollerOfRapport := rapport.vScroller;
end;

function GetHorizontalScrollerOfRapport():ControlHandle;
begin
  GetHorizontalScrollerOfRapport := rapport.hScroller;
end;

function GetTailleMaximumOfRapport() : SInt32;
begin
  GetTailleMaximumOfRapport := maxTextEditSize;
end;

function GetProchaineAlerteRemplissageRapport() : SInt32;
begin
  GetProchaineAlerteRemplissageRapport := rapport.prochaineAlerteRemplissage;
end;

procedure SetProchaineAlerteRemplissageRapport(tailleCritique : SInt32);
begin
  rapport.prochaineAlerteRemplissage := tailleCritique;
end;

function EstLaFenetreDuRapport(whichWindow : WindowPtr) : boolean;
begin
  EstLaFenetreDuRapport := (whichWindow <> NIL) & (whichWindow = rapport.theWindow);
end;


function FenetreRapportEstAuPremierPlan() : boolean;
begin
  FenetreRapportEstAuPremierPlan := (rapport.theWindow = FrontWindowSaufPalette());
end;


procedure OuvreFntrRapport(avecAnimationZoom,forceSelectWindow : boolean);
var rect1,rect2 : rect;
begin
  DeactivateFrontWindowSaufPalette();
  SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
  rect2 := FntrRapportRect;
  rect2.top := rect2.top-18;
  InsetRect(rect2,-2,-2);
  if avecAnimationZoom & not(SupprimerLesEffetsDeZoom) then 
    ZoomRect(rect1,rect2,kZoomOut,6,true); 
  
  ShowHide(rapport.theWindow,true);
  DoActivateRapport;
    
  windowRapportOpen := true;
  if windowPaletteOpen & (wPalettePtr <> NIL)
    then 
      begin
        SendBehind(Rapport.theWindow,wPalettePtr);
        EmpileFenetresSousPalette;
      end
    else 
      begin
        if forceSelectWindow then SelectWindow(Rapport.theWindow);
        EmpileFenetres;
        if forceSelectWindow then SelectWindow(Rapport.theWindow);
      end;
  
  UpdateScrollersRapport;
end;

procedure CloseRapportWindow;
begin
  SetPortByWindow(rapport.theWindow);
  FntrRapportRect := GetWindowPortRect(rapport.theWindow);
  LocalToGlobal(FntrRapportRect.topleft);
  LocalToGlobal(FntrRapportRect.botright);
  DoDeactivateRapport;
  HideWindow(rapport.theWindow);
  SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
  CloseZoomRectFrom := FntrRapportRect;
  CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
  InsetRect(CloseZoomRectFrom,-2,-2);
  windowRapportOpen := false;
  EssaieSetPortWindowPlateau;
  EmpileFenetresSousPalette;
end;



procedure UpdateScrollersRapport ;
var firstLine, firstCol: SInt16; 
    nbDeLignesVisibles,nbTotalDeLignes : SInt32;
begin
  with rapport do
   if (theText <> NIL) & (vScroller <> NIL) & (hScroller <> NIL) then
    begin
      nbTotalDeLignes := succ(TEGetHeight(0,32000,theText) div vUnit);
      nbDeLignesVisibles := NbLignesVisiblesDansRapport();
      firstLine := succ((TEdecalage - theText^^.destRect.top) div vUnit);
       
      if (nbTotalDeLignes<=nbDeLignesVisibles) & (firstLine=1)
        then 
          begin
            SetControlValue(vScroller, 1);
            SetControlMaximum(vScroller, 1);
          end
        else
          begin
            SetControlMaximum(vScroller,Max(nbTotalDeLignes-nbDeLignesVisibles+1,firstLine));
            SetControlValue(vScroller, firstLine);
            {$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
            SetSmartScrollInfo(vScroller,nbDeLignesVisibles,Max(nbDeLignesVisibles+0,nbTotalDeLignes+(nbDeLignesVisibles div 1000)));
            {$ENDC}
          end;
    
      firstCol := succ((TEdecalage - TEGetDestRect(theText).left+hUnit-1) div hUnit);
      SetControlValue(hScroller, firstCol);
      
      {$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
      SetSmartScrollInfo(hScroller,NbColonnesVisiblesDansRapport(),GetControlMaximum(hScroller));
      {$ENDC}
      
   end;
 InvalScrollersRapport;
end;

procedure CalculateViewAndDestRapport;
var height, width: SInt16; 
    viewRect,destRect : rect;
begin
    with rapport do
      if (theWindow <> NIL) & (theText <> NIL) then
      begin
         with GetWindowPortRect(rapport.theWindow) do
           begin
              height := (bottom - 15) - (top + TEdecalage) ;
              width := (right - 15) - (left + TEdecalage) ;
           end;
           
         viewRect := TEGetViewRect(theText);
         viewRect.bottom := viewRect.top + height ;
         viewRect.right := viewRect.left + width ;
         TESetViewRect(theText,viewRect);
         
         destRect := TEGetDestRect(theText);
         destRect.bottom := destRect.top + height;
         destRect.right := MaxInt-100;
         TESetDestRect(theText,destRect);
      end;
end;

  { Défilement du texte par l'ascenseur ch }
procedure TrackScrollingRapport(ch: ControlHandle; part: SInt16);
var oldValue, newValue: SInt16; 
begin
  with rapport do
    if (theText <> NIL) & (ch <> NIL) then
      begin
  	    oldValue := GetControlValue(ch);
  	    newvalue := oldvalue;
  	    case part OF
  	      kControlDownButtonPart: if ch = hScroller
  	                      then newValue := oldValue + 2
  	                      else newValue := oldValue + 1;
  	      kControlUpButtonPart:   if ch = hScroller
  	                      then newValue := oldValue - 2
  	                      else newValue := oldValue - 1;
  	      kControlPageDownPart:    if ch = hScroller
  	                      then newValue := oldValue + 10
  	                      else newValue := oldValue + Max(NbLignesVisiblesDansRapport()-1,10);
  	      kControlPageUpPart:      if ch = hScroller
  	                      then newValue := oldValue - 10
  	                      else newValue := oldValue - Max(NbLignesVisiblesDansRapport()-1,10);
  	      kControlSpecialDocumentTopPart :
  	                           newValue := 0;
  	      kControlSpecialDocumentBottomPart :
  	                           newValue := MaxInt;
  	    end;
  	    SetControlValue(ch, newValue);
  	    newValue := GetControlValue(ch);
  	    {if newValue <> oldValue then}
  	    if ch=vScroller then TEPinScroll(0, (oldValue - GetControlValue(ch)) * vUnit, theText) else
  	    if ch=hScroller then TEPinScroll((oldValue - GetControlValue(ch)) * hUnit, 0, theText);
      end;
end;

{fonction remplacant TrackControl pour les clics dans le pouce : mise a jour
  simultanee de l'ascenseur et de l'affichage du texte }
function MyTrackControlIndicatorPartRapport(theControl: ControlHandle) : SInt16; 
var oldValue, newValue: SInt32;
    horizontal,avecDoubleScroll : boolean;
    minimum,maximum : SInt32;
    ascenseurRect,barreGrisee : rect;
    mouseLoc,oldMouseLoc : Point;
    SourisADejaBouje : boolean;
    tailleDuPouce : SInt32;
    proportion:fixed;
begin

  MyTrackControlIndicatorPartRapport := 0;
  
  if (theControl <> NIL) & (rapport.theText <> NIL) then
    begin
      SetPortByWindow(GetControlOwner(theControl));
      GetMouse(oldMouseLoc);
      SourisADejaBouje := false;
      HiliteControl(theControl,kControlIndicatorPart);
      
      
      avecDoubleScroll := EstUnAscenseurAvecDoubleScroll(theControl,ascenseurRect,barreGrisee,horizontal);
      if horizontal
        then
          begin
            InsetRect(ascenseurRect,-30,-20);
            if SmartScrollEstInstalle(theControl,proportion)
              then TailleDuPouce := Max(16,fixround(fixmul(proportion,fixRatio(barreGrisee.right-barreGrisee.left,1))))
              else TailleDuPouce := 16;
            InsetRect(barreGrisee,tailleDuPouce div 2,0);
          end
        else
          begin
            InsetRect(ascenseurRect,-20,-30);
            if SmartScrollEstInstalle(theControl,proportion)
              then TailleDuPouce := Max(16,fixround(fixmul(proportion,fixRatio(barreGrisee.bottom-barreGrisee.top,1))))
              else TailleDuPouce := 16;
            InsetRect(barreGrisee,0,tailleDuPouce div 2);
          end;
      while StillDown() do
        begin
          SetPortByWindow(GetControlOwner(theControl));
          GetMouse(mouseLoc);
          SourisADejaBouje := SourisADejaBouje | (SInt32(mouseLoc)<>SInt32(oldMouseLoc));
          if SourisADejaBouje & (SInt32(mouseLoc)<>SInt32(oldMouseLoc)) then
            begin
	          oldValue := GetControlValue(theControl);
	          minimum := GetControlMinimum(theControl);
	          maximum := GetControlMaximum(theControl);
	          if PtInRect(mouseLoc,ascenseurRect) then
	            begin
	              with barreGrisee do
	                if horizontal 
	                  then newValue := minimum+ ((maximum-minimum+1)*(mouseLoc.h-left)) div (right-left)
	                  else newValue := minimum+ ((maximum-minimum+1)*(mouseLoc.v-top)) div (bottom-top);
	              if newValue>maximum then newValue := maximum;
	              if newValue<minimum then newValue := minimum;
	              if newValue<>oldValue then
	                begin
	                  SetControlValue(theControl,newValue);
	                  with rapport do
	                    if horizontal
	                      then TEPinScroll((oldValue - GetControlValue(theControl)) * hUnit, 0, theText)
	                      else TEPinScroll(0, (oldValue - GetControlValue(theControl)) * vUnit, theText);
	                  MyTrackControlIndicatorPartRapport := kControlIndicatorPart;
	                end;
	            end;
            end;
          oldMouseLoc := mouseLoc;
        end;
      HiliteControl(theControl,0);
    end;
  end;


{ Fonction personnelle d'auto-défilement. Identique à celle standard }
{ mais avec mise à jour simultanée des ascenseurs }
function MyClikLoopRapport() : boolean;
var where: Point;
       r: Rect;
       clip: RgnHandle;
begin
    GetMouse(where);
    with rapport do
      if (theText <> NIL) then
       if not(PtInRect(where, TEGetViewRect(theText))) then
         begin
            clip := NewRgn();
            GetClip(clip);
            { On annule toute région de limitation, sinon la mise à }
            { jour des ascenseurs est impossible (note technique 82) }
            SetRect(r, -MaxInt, -MaxInt, MaxInt, MaxInt);
            ClipRect(r);
            if where.v < TEGetViewRect(theText).top then TrackScrollingRapport(vScroller, kControlUpButtonPart) else
            if where.v > TEGetViewRect(theText).bottom then TrackScrollingRapport(vScroller, kControlDownButtonPart);
            if where.h < TEGetViewRect(theText).left then TrackScrollingRapport(hScroller, kControlUpButtonPart) else
            if where.h > TEGetViewRect(theText).right then TrackScrollingRapport(hScroller, kControlDownButtonPart);
            SetClip(clip);
            DisposeRgn(clip);
         end;
    MyClikLoopRapport := True;  { Toujours renvoyer une valeur vraie }
end;


{ Accumule la région correspondant à l'emplacement des ascenseurs plus celui }
{ de la boîte de taille dans la région de mise à jour de la fenêtre }
procedure InvalScrollersRapport;
var r : rect;
    oldport : grafPtr;
begin
  GetPort(oldport);
  SetPortByWindow(rapport.theWindow);
  r := GetWindowPortRect(rapport.theWindow);
  r.left := r.right - 15;
  InvalRect(r);
  r := GetWindowPortRect(rapport.theWindow);
  r.top := r.bottom - 15;
  InvalRect(r);
  SetPort(oldport);
end;


  { Change la taille de la fenêtre Rapport. Si hSize < 0, cela signifie que }
  { la fenêtre est déjà dans sa nouvelle taille. On ne s'occupe alors que des }
  { problèmes de mise à jour de son contenu }
procedure ChangeWindowRapportSize(hSize,vSize : SInt16);
var r: Rect;
begin
    SetPortByWindow(rapport.theWindow);
    InvalScrollersRapport;
    with rapport do
      begin
          if hSize > 0 then
            begin
              { La taille doit être changée. On s'assure qu'elle sera bien }
              { multiple des lignes et colonnes (voir hUnit) de texte }
              while (vSize - 15 - TEdecalage) MOD vUnit <> 0 do dec(vSize);
              while (hSize - 15 - TEdecalage) MOD hUnit <> 0 do dec(hSize);
              SizeWindow(Rapport.theWindow, hSize, vSize, True);
            end;
            
          CalculateViewAndDestRapport;
          UpdateScrollersRapport;
          
          r := GetWindowPortRect(rapport.theWindow);
          InsetRect(r, -1, -1);
          { On déplace les deux ascenseurs à leur nouvel emplacement en }
          { adaptant leur taille. Ils sont redessinés immédiatement }
          MoveControl(vScroller, r.right - 16, r.top);
          SizeControl(vScroller, 16, r.bottom - r.top - 15);
          MoveControl(hScroller, r.left, r.bottom - 16);
          SizeControl(hScroller, r.right - r.left - 15, 16);
          { On accumule uniquement la boîte de taille dans la région de mise }
          { à jour puisque les ascenseurs sont déjà redessinés }
          r.left := r.right - 16;
          r.top := r.bottom - 16;
          InvalRect(r);
          
      end;
end;



procedure RedrawFenetreRapport;
var oldport: GrafPtr;
begin
  with rapport do
    if (theText <> NIL) & (theWindow <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(theWindow);
      EraseRect(TEGetViewRect(theText));
      TEUpdate(GetWindowPortRect(rapport.theWindow), theText);
      DrawControls(theWindow);
      DrawGrowIcon(theWindow);
      SetPort(oldport);
    end;
end;


procedure DoUpdateRapport;
var oldport: GrafPtr;
begin
  with rapport do
    if (theText <> NIL) & (theWindow <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(theWindow);
      BeginUpdate(theWindow);
      EraseRect(TEGetViewRect(theText));
      TEUpdate(GetWindowPortRect(rapport.theWindow), theText);
      DrawControls(theWindow);
      DrawGrowIcon(theWindow);
      EndUpdate(theWindow);
      SetPort(oldport);
    end;
end;

procedure DoActivateRapport;
var err : OSErr;
begin
  with rapport do
    if IsWindowHilited(theWindow) then
       begin
          if (theText <> NIL) then TEActivate(theText);
          HiliteControl(vScroller, 0);
          HiliteControl(hScroller, 0);
          ShowControl(vScroller);
          ShowControl(hScroller);
          DrawGrowIcon(theWindow);
          
          {activation de la zone d'entree du japonais}
          if docTSMDoc <> NIL then
			      err := ActivateTSMDocument(docTSMDoc);
       end;
end;

procedure DoDeactivateRapport;
var err : OSErr;
begin
  with rapport do
    if not(IsWindowHilited(theWindow)) then
       begin
          {desactivation de la zone d'entree du japonais}
          if docTSMDoc <> NIL then
			      err := DeactivateTSMDocument(docTSMDoc);
			
          if (theText <> NIL) then TEDeactivate(theText);
          HiliteControl(vScroller, 255);
          HiliteControl(hScroller, 255);
          HideControl(vScroller);
          HideControl(hScroller);
          DrawGrowIcon(theWindow);
       end;
end;


procedure ClicInRapport(evt : eventRecord);
var ch: ControlHandle;
    trackScrollingRapportUPP:ControlActionUPP;
    part : SInt16; 
    oldport : grafPtr;
   {oldValue : SInt16} 
    oldScript,posMilieuMot : SInt32;
    modifiers : SInt16; 
    where : Point;
begin
  modifiers := evt.modifiers;
  where := evt.where;
  
  GetPort(oldport);
  with rapport do
    if (theWindow <> NIL) & (theText <> NIL) then
     begin
        SetPortByWindow(theWindow);
        GlobalToLocal(where);
        part := FindControl(where, theWindow, ch);
        case part OF
        kControlDownButtonPart, kControlPageDownPart, kControlUpButtonPart, kControlPageUpPart:
          begin
            if GetControlMaximum(ch)>1 then
              begin
                trackScrollingRapportUPP := NewControlActionUPP(@TrackScrollingRapport);
                if TrackControl(ch, where, trackScrollingRapportUPP) = part then;
                MyDisposeControlActionUPP(trackScrollingRapportUPP);
              end;
          end;
        kControlIndicatorPart:
            begin
              if MyTrackControlIndicatorPartRapport(ch) = kControlIndicatorPart then;
              
           {
           oldValue := GetControlValue(ch);
           if TrackControl(ch, where, NIL) = kControlIndicatorPart then
             begin
                    if ch=vScroller then TEScroll(0, (oldValue - GetControlValue(ch)) * vUnit, theText) else
                    if ch=hScroller then TEScroll((oldValue - GetControlValue(ch)) * hUnit, 0, theText);
             end;
           }
             end;
          otherwise
            begin
             if (where.h < GetWindowPortRect(rapport.theWindow).right-15) & 
                (where.v < GetWindowPortRect(rapport.theWindow).bottom-15) 
               then 
                 begin
                   GetCurrentScript(oldScript);
                   DisableKeyboardScriptSwitch;
                   TEClick(where, BAND(modifiers, shiftKey) <> 0, rapport.theText);
                   
                   posMilieuMot := GetMilieuSelectionRapport();
                   if EstUnDoubleClic(evt,false) & EstDansBanniereAnalyseRetrograde(posMilieuMot)
                     then SelectionneAnalyseRetrograde(posMilieuMot);
                   EnableKeyboardScriptSwitch;
                   SetCurrentScript(oldScript);
                   SwitchToRomanScript;
                 end;
            end;
         end; {case}
        UpdateScrollersRapport;
     end;
  SetPort(oldport);
end;

procedure EcritBienvenueDansRapport;
var oldscript : SInt32;
    oldEcritureDansRapportLog : boolean;
    policeMise : boolean;
    niceJapaneseFont : SInt16; 
    niceRomanFont : SInt16; 
    s : str255;
begin
  oldEcritureDansRapportLog := GetEcritToutDansRapportLogDansImplementation();
  SetEcritToutDansRapportLogDansImplementation(false);
  GetCurrentScript(oldScript);
  DisableKeyboardScriptSwitch;
  FinRapport;
  TextNormalDansRapport;
  WritelnDansRapport('');
  EnableKeyboardScriptSwitch;
  FinRapport;
  if gEcranCouleur then    
     ChangeFontColorDansRapport(VertCmd);
  ChangeFontFaceDansRapport(bold);
  ChangeFontSizeDansRapport(24);
  policeMise := false;
  if not(gVersionJaponaiseDeCassio) & not(policeMise) then
    begin
      GetFNum('Bookman',niceRomanFont);
      if niceRomanFont>0 then
        begin
          ChangeFontDansRapport(niceRomanFont);
          policeMise := true;
        end;
    end;
  if not(gVersionJaponaiseDeCassio) & not(policeMise) then
    begin
      GetFNum('Comic Sans MS',niceRomanFont);
      if niceRomanFont>0 then
        begin
          ChangeFontDansRapport(niceRomanFont);
          policeMise := true;
        end;
    end;
  if not(gVersionJaponaiseDeCassio) & not(policeMise) then
    begin
      GetFNum('Times',niceRomanFont);
      if niceRomanFont>0 then
        begin
          ChangeFontDansRapport(niceRomanFont);
          policeMise := true;
        end;
    end;
  if gVersionJaponaiseDeCassio & not(policeMise) then
    begin
      GetFNum('ñ{ñæí©Å|Çl',niceJapaneseFont);
      if niceJapaneseFont>0 then
        begin
          ChangeFontDansRapport(niceJapaneseFont);
          policeMise := true;
        end;
    end;
  if gVersionJaponaiseDeCassio & not(policeMise) then
    begin
      GetFNum('ä€ÉSÉVÉbÉNÅ|Çl',niceJapaneseFont);
      if niceJapaneseFont>0 then
        begin
          ChangeFontDansRapport(niceJapaneseFont);
          policeMise := true;
        end;
    end;
  if not(policeMise) then ChangeFontDansRapport(gCassioApplicationFont);
  s := ReadStringFromRessource(TextesRapportID,1);
  longueurMessageBienvenueDansCassio := Length(s);
  WritelnDansRapport(s);  {'Bienvenue…'}
  
  SelectionnerTexteDansRapport(0,1);
  ChangeFontSizeDansRapport(9);
  
  FinRapport;
  TextNormalDansRapport;
  ChangeFontSizeDansRapport(9);
  WritelnDansRapport('');
  WritelnDansRapport('');
  TextNormalDansRapport;
  EnableKeyboardScriptSwitch;
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
  SetEcritToutDansRapportLogDansImplementation(oldEcritureDansRapportLog);
end;

function GetLongueurMessageBienvenueDansCassio() : SInt16; 
begin
  GetLongueurMessageBienvenueDansCassio := longueurMessageBienvenueDansCassio;
end;


procedure FinRapport;
begin
  PositionnePointDinsertion(GetTailleRapport());
  {PositionnePointDinsertion(MaxInt);}
end;

procedure VoirLeDebutDuRapport;
begin
 {SetDeroulementAutomatiqueDuRapport(true);
  PositionnePointDinsertion(0);
  UpdateScrollersRapport;
  if analyseRetrograde.encours then 
    SetDeroulementAutomatiqueDuRapport(false);}
    
  TrackScrollingRapport(rapport.vscroller,kControlSpecialDocumentTopPart);
end;

procedure VoirLaFinDuRapport;
begin
 {SetDeroulementAutomatiqueDuRapport(true);
  PositionnePointDinsertion(MaxLongint);
  UpdateScrollersRapport;
  if analyseRetrograde.encours then 
    SetDeroulementAutomatiqueDuRapport(false);}
    
  TrackScrollingRapport(rapport.vscroller,kControlSpecialDocumentBottomPart);
end;


procedure MyTESetStyle(mode: SInt16; {CONST}var newStyle: TextStyle; fRedraw: boolean; hTE: TEHandle);
var trick : boolean;
    selectionInvisible : boolean;
begin

  trick := false;
  if gIsRunningUnderMacOSX & SelectionRapportEstVide() then
    begin
      trick := true;
      {InsereStringDansRapportSync(' ',false);}
      SelectionnerTexteDansRapport(GetDebutSelectionRapport()-1,GetFinSelectionRapport());
    end;
  
  selectionInvisible := (LongueurSelectionRapport() <= 4);
  
  TESetStyle(mode, newStyle, (fRedraw) , hTE);
  
  if trick then
    begin
      SelectionnerTexteDansRapport(GetFinSelectionRapport(),GetFinSelectionRapport());
      
    end;
  
end;

procedure ChangeFontFaceDansRapport(whichStyle : Style);
var newStyle : TextStyle;
begin
  if not(sousEmulatorSousPC) & (rapport.theText <> NIL) then
    begin
      newStyle.tsFace := whichStyle;
      MyTESetStyle(doFace,newStyle,true,rapport.theText);
      UpdateScrollersRapport;
    end;
end;

procedure ChangeFontSizeDansRapport(whichSize : SInt16);
var newStyle : TextStyle;
begin
  if not(sousEmulatorSousPC) & (rapport.theText <> NIL) then
    begin
      newStyle.tsSize := whichSize;
      MyTESetStyle(doSize,newStyle,true,rapport.theText);
      UpdateScrollersRapport;
    end;
end;

procedure ChangeFontColorDansRapport(whichColor : SInt16);
var theRGBColor : RGBColor;
begin
  if not(sousEmulatorSousPC) then
    begin
      theRGBColor := CouleurCmdToRGBColor(whichColor);
      ChangeFontColorRGBDansRapport(theRGBColor);
    end;
end;

procedure ChangeFontColorRGBDansRapport(whichColor : RGBColor);
var newStyle : TextStyle;
begin
  if not(sousEmulatorSousPC) & (rapport.theText <> NIL) then
    begin
      newStyle.tsColor := whichColor;
      MyTESetStyle(doColor,newStyle,true,rapport.theText);
      {TEUpdate(GetWindowPortRect(rapport.theWindow), rapport.theText);}
      UpdateScrollersRapport;
    end;
end;

procedure ChangeFontDansRapport(whichFont : SInt16);
var newStyle : TextStyle;
begin
  if not(sousEmulatorSousPC) & (rapport.theText <> NIL) then
    begin
      newStyle.tsFont := whichFont;
      MyTESetStyle(doFont,newStyle,true,rapport.theText);
      UpdateScrollersRapport;
    end;
end;

procedure TextNormalDansRapport;
begin
  ChangeFontFaceDansRapport(normal);
  ChangeFontColorDansRapport(NoirCmd);
  ChangeFontDansRapport(gCassioRapportNormalFont);
  ChangeFontSizeDansRapport(gCassioRapportNormalSize);
end;


procedure ViewRectAGaucheRapport;
var offset : SInt16; 
begin
  with rapport do
    if (theText <> NIL) then
    begin
      offset := TEdecalage - TEGetDestRect(theText).left;
      if offSet <> 0 then
        begin
          TEScroll(-offset, 0, theText);
          UpdateScrollersRapport;
        end;
    end;
end;


procedure AnnonceScoreFinalDansRapport;
var s,s1 : str255;
    oldScript : SInt32;
begin
  if gameOver & not(HumCtreHum) & not(demo) then
    if not(CassioEstEnModeSolitaire()) then 
      begin
        NumToString(nbreDePions[pionNoir],s);
        NumToString(nbreDePions[pionBlanc],s1);
        s1 := s+StringOf('-')+s1;
        s := ParamStr(ReadStringFromRessource(TextesRapportID,7),s1,'','','')+'. ';  {'score final ^0'}
        if not(HumCtreHum) then
          if ((nbreDePions[pionNoir]>32) & (couleurMacintosh = pionBlanc)) |
             ((nbreDePions[pionBlanc]>32) & (couleurMacintosh = pionNoir)) 
             then s := s+ReadStringFromRessource(TextesRapportID,8)    {'Félicitations !'}
             else s := s+ReadStringFromRessource(TextesRapportID,9);   {'Voulez-vous en faire une autre ?'}
        GetCurrentScript(oldScript);
        DisableKeyboardScriptSwitch;
        FinRapport;
        TextNormalDansRapport;
        WritelnDansRapport('');
        
        ChangeFontSizeDansRapport(gCassioRapportBoldSize);
        ChangeFontDansRapport(gCassioRapportBoldFont);
        
        ChangeFontFaceDansRapport(bold);
        ChangeFontColorDansRapport(VertCmd);
        WritelnDansRapport(s);
        WritelnDansRapport('');
        EnableKeyboardScriptSwitch;
        SetCurrentScript(oldScript);
        SwitchToRomanScript;
        TextNormalDansRapport;
      end;
end;

procedure AnnonceOuvertureFichierEnRougeDansRapport(nomFichier : str255);
begin
  if not(EstUnNomDeFichierTemporaireDePressePapier(nomFichier)) then
    begin
		  FinRapport;
		  TextNormalDansRapport;
		  
      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
        
		  ChangeFontFaceDansRapport(bold);
		  ChangeFontColorDansRapport(RougeCmd);
		  WritelnDansRapportSync('',false);
		  WritelnDansRapportSync('### '+nomfichier+' ###',false);
		  WritelnDansRapportSync('',false);
		  TextNormalDansRapport;
		end;
end;


procedure AnnonceSupposeSuitConseilMac(numeroCoup,conseil : SInt16);
var s,s1 : str255;
    oldScript : SInt32;
begin
  if not(CassioEstEnModeSolitaire()) & not(jeuInstantane) then
    begin
      NumToString(numeroCoup,s1);
      GetIndString(s,TextesRapportID,10);   {'conseil'}
      s := '   '+ParamStr(s,s1+StringOf('.')+CoupEnString(conseil,CassioUtiliseDesMajuscules),'','','');
      {FrappeClavierDansRapport(chr(RetourArriereKey));}
      GetCurrentScript(oldScript);
      DisableKeyboardScriptSwitch;
      FinRapport;
      TextNormalDansRapport;
      WritelnDansRapport(s);
      TextNormalDansRapport;
      EnableKeyboardScriptSwitch;
      SetCurrentScript(oldScript);
      SwitchToRomanScript;
    end;
end;


function NbLignesVisiblesDansRapport() : SInt16; 
begin
    with GetWindowPortRect(rapport.theWindow) do
      NbLignesVisiblesDansRapport := ((bottom - 15) - (top + TEdecalage)) div vUnit;
end;


function NbColonnesVisiblesDansRapport() : SInt16; 
begin
    with GetWindowPortRect(rapport.theWindow) do
      NbColonnesVisiblesDansRapport := ((right - 15) - (left + TEdecalage)) div hUnit;
end;


procedure EcritKeyDownEventDansRapport(evt : eventRecord);
var ch,ch2 : char;
    option,command,shift,control,verouillage : boolean;
    keyCode : SInt16; 
    s : str255;
begin
  shift := BAND(evt.modifiers,shiftKey) <> 0;
  verouillage := BAND(evt.modifiers,alphaLock) <> 0;
  command := BAND(evt.modifiers,cmdKey) <> 0;
  option := BAND(evt.modifiers,optionKey) <> 0;
  control := BAND(evt.modifiers,controlKey) <> 0;
  
  ch := chr(BAND(evt.message,charCodemask));
  keyCode := BSR(BAND(theEvent.message,keyCodeMask),8);
  
  s := '';
  if theEvent.what = keyDown then s := s+'keyDown';
  if theEvent.what = autoKey then s := s+'autoKey';
  
  s := s+' caractère="'+ch+'"';
  s := s+' ord='+NumEnString(ord(ch));
  s := s+'  keycode='+NumEnString(keycode);
  if shift        then s := s+'  shift=true'        else s := s+'  shift=false';
  if command      then s := s+'  command=true'      else s := s+'  command=false';
  if option       then s := s+'  option=true'       else s := s+'  option=false';
  if control      then s := s+'  control=true'      else s := s+'  control=false';
  if verouillage  then s := s+'  verrouillage=true' else s := s+'  verrouillage=false';
  WritelnDansRapport('');
  WritelnDansRapport(s);
  
  if control then 
    begin
      ch2 := QuelCaractereDeControle(ch,shift|verouillage);
      s := 'touche controle appuyée,  ';
      s := s+'caractère= ^'+ch2;
      WritelnDansRapport(s);
    end;
end;

function CollerDansRapport() : boolean;
begin
  collerDansRapport := false;
  with rapport do
  if windowRapportOpen & (theText <> NIL) then
   if theWindow=FrontWindowSaufPalette() then
     if TEGetScrapLength() < (maxTextEditSize - GetTailleRapport())
       then
         begin
           TEStylePaste(theText);
           UpdateScrollersRapport;
           collerDansRapport := true;
         end
       else
         begin
           AlerteSimple(ReadStringFromRessource(TextesRapportID,27));
         end;
end;

function CouperFromRapport() : boolean;
begin
  couperFromRapport := false;
  with rapport do
  if windowRapportOpen & (theText <> NIL) then
    if SelectionRapportNonVide()  then
      if theWindow=FrontWindowSaufPalette() then     
        begin
         TECut(theText);
         UpdateScrollersRapport;
         {if (ZeroScrap() = noErr) then
           if (TEToScrap() = noErr) then;}
         couperFromRapport := true;
        end;
end;

function CopierFromRapport() : boolean;
begin
  copierFromRapport := false;
  with rapport do
  if windowRapportOpen & (theText <> NIL) then
    if SelectionRapportNonVide()  then
      if theWindow=FrontWindowSaufPalette() then     
        begin
          TECopy(theText);
         {if (ZeroScrap() = noErr) then
          if (TEToScrap() = noErr) then;}
         copierFromRapport := true;
       end;
end;

function EffacerDansRapport() : boolean;
begin
  effacerDansRapport := false;
  with rapport do
  if windowRapportOpen & (theText <> NIL) then
    if SelectionRapportNonVide()  then
      if theWindow=FrontWindowSaufPalette() then 
        begin
          TEDelete(theText);
          UpdateScrollersRapport;
          effacerDansRapport := true;
          if GetTailleRapport() < maxTextEditSize      then prochaineAlerteRemplissage := maxTextEditSize;
          if GetTailleRapport() < maxTextEditSize-1000 then prochaineAlerteRemplissage := maxTextEditSize-1000;
          if GetTailleRapport() < maxTextEditSize-2000 then prochaineAlerteRemplissage := maxTextEditSize-2000;
          if GetTailleRapport() <= 1 then EcritBienvenueDansRapport;
        end;
end;

function SelectionneToutDansRapport() : boolean;
begin
  SelectionneToutDansRapport := false;
  with rapport do
    if windowRapportOpen & (theText <> NIL) then
      if theWindow=FrontWindowSaufPalette() then
        begin
          TESetSelect(0,MaxLongint-1,theText);
          UpdateScrollersRapport;
          SelectionneToutDansRapport := true;
        end;
end;

procedure DetruireSelectionDansRapport;
begin
  if (rapport.theText <> NIL) then
    TEDelete(rapport.theText);
end;

procedure SetDebutSelectionRapport(debut : SInt32);
begin
  if (rapport.theText <> NIL) then
    rapport.theText^^.selStart := debut;
end;

procedure SetFinSelectionRapport(fin : SInt32);
begin
  if (rapport.theText <> NIL) then
    rapport.theText^^.selEnd := fin;
end;

procedure FrappeClavierDansRapport(whichChar : char);
begin
  if (rapport.theText <> NIL) then
    TEKey(whichChar,rapport.theText);
end;


procedure EffaceDernierCaractereDuRapportSync(scrollerSynchronisation : boolean);
begin
  if (rapport.theText <> NIL) then
    begin
      PositionnePointDinsertion(GetTailleRapport());
      TEKey(chr(8),rapport.theText);
      if scrollerSynchronisation then UpdateScrollersRapport;
    end;
end;

procedure EffaceDernierCaractereDuRapport;
begin
  EffaceDernierCaractereDuRapportSync(true);
end;

procedure PositionnePointDinsertion(index : SInt32);
begin
  if (rapport.theText <> NIL) then
    begin
      TESetSelect(index,index,rapport.theText);
      UpdateScrollersRapport;
    end;
end;

function GetPositionPointDinsertion() : SInt32;
begin
  if SelectionRapportNonVide() & (rapport.theText <> NIL) 
    then GetPositionPointDinsertion := MaxLongint-1
    else GetPositionPointDinsertion := GetDebutSelectionRapport();
end;


procedure SetDeroulementAutomatiqueDuRapport(flag : boolean);
begin
  if (rapport.theText <> NIL) then
    begin
      TEAutoView(flag, rapport.theText);
      rapport.deroulementAutomatique := flag;
    end;
end;

function GetDeroulementAutomatiqueDuRapport() : boolean;
begin
  GetDeroulementAutomatiqueDuRapport := rapport.deroulementAutomatique;
end;

function FindStringInRapport(s : str255;from,direction : SInt32; var positionTrouvee : SInt32) : boolean;
var len,depart,k,tailleRapport : SInt32;
    texteRapportHdl : CharArrayHandle;
begin

  FindStringInRapport := false;
  positionTrouvee := 0;
  
  with rapport do
    if (theText <> NIL) then
	    begin
			  len := Length(s);
			  if (len > 0) then
			    begin
					  texteRapportHdl := GetRapportTextHandle();
					  tailleRapport := GetTailleRapport();
					  
					  if (from < 0) then from := 0;
					  if (from > tailleRapport) then from := tailleRapport;
					  if (direction <  0) then direction := -1;
					  if (direction >= 0) then direction := +1;
					  
					  depart := from;
					  
					  while (depart >= 0) & ((depart + len - 1) <= tailleRapport) do
					    begin
							  k := 0;
							  while (k < len) & (texteRapportHdl^^[depart+k] = s[k+1]) do
							    inc(k);
							  
							  if (k = len) then
							    begin
							      FindStringInRapport := true;
							      positionTrouvee := depart;
							      
							      {TESetSelect(depart,depart+len,rapport.theText);
							      AttendFrappeClavier;}
							      exit(FindStringInRapport);
							      
							    end;
							  
							  depart := depart + direction;
							end;
					end; 
		  end;
end;


procedure SetAutoVidageDuRapportDansImplementation(flag : boolean);
begin
  rapport.autoVidageDuRapport := flag;
end;

function GetAutoVidageDuRapportDansImplementation() : boolean;
begin
  GetAutoVidageDuRapportDansImplementation := rapport.autoVidageDuRapport;
end;

procedure SetEcritToutDansRapportLogDansImplementation(flag : boolean);
begin
  rapport.ecritToutDansRapportLog := flag;
end;

function GetEcritToutDansRapportLogDansImplementation() : boolean;
begin
  GetEcritToutDansRapportLogDansImplementation := rapport.ecritToutDansRapportLog;
end;




END.