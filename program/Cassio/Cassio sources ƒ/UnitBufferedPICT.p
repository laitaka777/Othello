UNIT UnitBufferedPICT;


INTERFACE






  
{Une unit� pour afficher des PICT stockees en ressource. On utilise un
 buffer offscreen pour accelerer le processus}  
  

USES  UnitOffScreenGraphics,UnitOth0,UnitCalculCouleurCassio;
  
  
  
CONST kNbPictDansUneSerie=5;
      kCaseDevantEtreRedessinee=-53;  {ou n'importe quelle valeur aberrante}
  
  
procedure InitUnitBufferedPICT;
procedure LibereMemoireUnitBufferedPICT;
procedure InvalidateAllOffScreenPICTs;


{affichage des pions textures}
function NroPremierePictDeLaSerie(CouleurDemandeeParUtilisateur : SInt16) : SInt16; 
procedure DrawBufferedColorPict(thePictID : SInt16; inrect : rect; var whichTexture:CouleurOthellierRec); 


{affichage de la bordure texturee de l'othellier}
function FichierBordureEstIntrouvable() : boolean;
function BordureOthellierEstUneTexture() : boolean;
function DrawBordureColorPict(quellesBordures : SInt32) : OSErr;
function DrawBordureRectDansFenetre(whichRect : rect;whichWindow : WindowPtr) : OSErr;


{fonctions de gestion pour l'affichage des Bitmap sur les cases}
procedure SetValeurDessinEnTraceDeRayon(square,valeur : SInt16);
function GetValeurDessinEnTraceDeRayon(square : SInt16) : SInt16; 
procedure InvalidateDessinEnTraceDeRayon(square : SInt16);
procedure InvalidateAllCasesDessinEnTraceDeRayon;


{fonction de gestion des tailles des images}
function GetCurrentSizeOfBufferedPicts() : SInt32;
function GetCurrentTailleOfBordurePicts() : SInt32;
procedure SetCurrentTailleOfBordurePicts(taille : SInt32);

  
IMPLEMENTATION







USES UnitRapport,UnitCouleur,UnitOth1,UnitTroisiemeDimension,UnitOth2,UnitFenetres,UnitCouleur,UnitFichierPhotos;
 

const kBordureDeDroiteRectID = 0;
      kBordureDeGaucheRectID = 1;
      kBordureDuBasRectID    = 2;
      kBordureDuHautRectID   = 3;

type RectPtr = ^Rect;
var  gOffScreenDiscs : CGrafPtr;
     gOffScreenDiscsRectangles : array[0..(kNbPictDansUneSerie-1)] of rect;
     
     gOffScreenBordure : CGrafPtr;
     gOffScreenBordureRectangles : array[kBordureDeDroiteRectID..kBordureDuHautRectID] of rect;
     gOffScreenBordureBoundingBox : rect;
     gOffScreenBordureSize : SInt32;
     gFichierBordureIntrouvable : boolean;
     
     SerieDePictCouramentAffichee:
       record
         whichMenuID : SInt16; 
         whichMenuItem : SInt16; 
       end;
     DessinEnTraceDeRayon : plateauOthello;

 
 
function NroPremierePictDeLaSerie(CouleurDemandeeParUtilisateur : SInt16) : SInt16; 
begin {$UNUSED CouleurDemandeeParUtilisateur}

  NroPremierePictDeLaSerie := 2300;
  
  (*
  case CouleurDemandeeParUtilisateur of
    RayTracingRealisteCmd  : NroPremierePictDeLaSerie := 2000;
    CeramiqueCmd           : NroPremierePictDeLaSerie := 2100;
    PsychedeliqueCmd       : NroPremierePictDeLaSerie := 2200;
    PhotographiqueCmd      : NroPremierePictDeLaSerie := 2300;  
    FantaisieLapinCmd      : NroPremierePictDeLaSerie := 2400;
    FantaisieLuneCmd       : NroPremierePictDeLaSerie := 2500;
    otherwise NroPremierePictDeLaSerie := 2000;
  end {case}
  *)
  
end;
 
 
 
procedure InvalidateAllOffScreenPICTs;
 var i : SInt32;
 begin
   for i := 0 to kNbPictDansUneSerie-1 do
     SetRect(gOffScreenDiscsRectangles[i],0,0,0,0);
 end;

function GetCurrentSizeOfBufferedPicts() : SInt32;
begin
  with gOffScreenDiscsRectangles[0] do
    GetCurrentSizeOfBufferedPicts := right-left;
end;
 
 
function GetCurrentTailleOfBordurePicts() : SInt32;
begin
  GetCurrentTailleOfBordurePicts := gOffScreenBordureSize;
end;


procedure SetCurrentTailleOfBordurePicts(taille : SInt32);
begin
  gOffScreenBordureSize := taille;
end;


function FichierBordureEstIntrouvable() : boolean;
begin
  FichierBordureEstIntrouvable := gFichierBordureIntrouvable;
end;


procedure SetFichierBordureEstIntrouvable(flag : boolean);
begin
  gFichierBordureIntrouvable := flag;
end;


procedure RaiseErrorFichierBordureEstIntrouvable;
begin
  SetFichierBordureEstIntrouvable(true);
end;

 
procedure LoadColorPICT(thepictID : SInt16; inRect:rectPtr; var bounds : rect);
var thePicture : PicHandle;
begin
  {WritelnDansRapport('dans LoadColorPICT�');}
	thePicture := GetPicture(thePictID);			{ Load graphic from resource fork.}
	if (thePicture = NIL)	then                    { Check to see if NIL (did it load?) }
	  begin	  
	    WritelnDansRapport('thePicture = NIL dans LoadColorPICT !');
	    {AttendFrappeClavier;}
	    exit(LoadColorPICT);
	  end;
	HLock(Handle(thePicture));					      { If we made it this far, lock handle.}
	bounds := thePicture^^.picFrame;			      { Get a copy of the picture's bounds.}
	HUnlock(Handle(thePicture));				      { We can unlock the picture now.}
	if (inRect <> NIL)
	  then DrawPicture(thePicture, inRect^)         { Draw picture to current port.}
	  else DrawPicture(thePicture, bounds);
	ReleaseResource(Handle(thePicture));		    { Dispose of picture from heap.}
end;


procedure DessinePionDansBufferAvantAntiAliasage(thePictID : SInt16; whichTexture:CouleurOthellierRec; var boundsRect : rect);
var pourcentage,largeur : SInt32;
    largeurReduite,delta : SInt32;
    discRect : rect;
    couleurMontreCoupLegal : RGBColor;
    couleurPionDore : RGBColor;
    
    
  procedure DessineOmbreDuPion(discRect : rect);
  const kTailleOmbre = 10;
        kForceDuGradient = 2000;
        kOmbrageMinimum  = 00000;
  var ombre : rect;
      i,force : SInt32;
  begin
  
    PenMode(patCopy);
  
    for i := kTailleOmbre downto 2 do
      begin
        
        with discRect do
          ombre := MakeRect(left + 4*(i div 4) ,top + 4*(i div 4) , right+i, bottom+i);
    
          case thePictID of
            1 {pion noir } : force := (kTailleOmbre-i)*kForceDuGradient div 4;
            2 {pion blanc} : force := kOmbrageMinimum + (kTailleOmbre-i)*kForceDuGradient;
            3 {coup legal} : force := (kOmbrageMinimum div 4 + (kTailleOmbre-i)*kForceDuGradient) div 4;
            4 {suggestion} : force := (kTailleOmbre-i)*kForceDuGradient div 4;
          end;
          
          if thePictID = 1 {legerement en creux}
            then
              begin
                RGBForeColor(EclaircirCouleurDeCetteQuantite(whichTexture.RGB,force));
                RGBBackColor(EclaircirCouleurDeCetteQuantite(whichTexture.RGB,force));
              end
            else
              begin
                RGBForeColor(NoircirCouleurDeCetteQuantite(whichTexture.RGB,force));
                RGBBackColor(NoircirCouleurDeCetteQuantite(whichTexture.RGB,force));
              end;
                 
          PaintOval(ombre);
      end;
  end;  
    
    
begin

  {SetPortByWindow(wPlateauPtr);  pour debuguer}
  
  boundsRect := MakeRect(1,1,300,300);
  
  pourcentage := gPourcentageTailleDesPions;
  
  with boundsRect do
    begin
      largeur := right - left;
      largeurReduite := (largeur * pourcentage) div 100;
      
      delta := (largeur - largeurReduite) div 2;
      discRect := MakeRect(left+delta,top+delta,right-delta,bottom-delta);
    end;
  
  PenMode(srcCopy+ditherCopy);
  
  case thePictID of
  
    0 : begin  {case vide }
	         ForeColor(whichTexture.couleurFront);
	         BackColor(whichTexture.couleurBack);
	         RGBForeColor(whichTexture.RGB);
	         FillRect(boundsRect,blackPattern);
	       end;
	       
    1 : begin {pion noir}
           ForeColor(whichTexture.couleurFront);
           BackColor(whichTexture.couleurBack);
           RGBForeColor(whichTexture.RGB);
           FillRect(boundsRect,blackPattern);
           
           if avecOmbrageDesPions
             then DessineOmbreDuPion(discRect);
           
           PenMode(patCopy);
           RGBForeColor(gPurNoir);
           RGBBackColor(gPurNoir);
           {BackColor(BlackColor);
           ForeColor(BlackColor);}
           PaintOval(discRect);
         end;
         
    2 : begin {pion blanc}
          ForeColor(whichTexture.couleurFront);
          BackColor(whichTexture.couleurBack);
          RGBForeColor(whichTexture.RGB);
          FillRect(boundsRect,blackPattern);
          
          if avecOmbrageDesPions
            then DessineOmbreDuPion(discRect);
          
          PenMode(patCopy);
          RGBForeColor(gPurBlanc);
          RGBBackColor(gPurBlanc);
          {BackColor(WhiteColor);
          ForeColor(WhiteColor);}
          PaintOval(discRect);
          if avecLisereNoirSurPionsBlancs then
            begin
              ForeColor(BlackColor);
              PenSize(2,2);
              FrameOval(discRect);
            end;
        end;
        
    3 : begin  {pion surlign� pour montrer le coup legal}
         ForeColor(whichTexture.couleurFront);
         BackColor(whichTexture.couleurBack);
         RGBForeColor(whichTexture.RGB);
         FillRect(boundsRect,blackPattern);
         
         
         if avecOmbrageDesPions & false
	          then DessineOmbreDuPion(discRect);
	          
         if RGBColorEstClaire(whichTexture.RGB,21500) 
            then couleurMontreCoupLegal := NoircirCouleurDeCetteQuantite(whichTexture.RGB,17000)
            else 
              if not(whichTexture.EstTresClaire) |
                 ((whichTexture.menuCmd<>BlancCmd) &
                 (whichTexture.menuCmd<>JauneCmd) & 
                 (whichTexture.menuCmd<>BleuPaleCmd) &
                 (whichTexture.menuCmd<>JaunePaleCmd))
                 then couleurMontreCoupLegal := EclaircirCouleur(whichTexture.RGB)
                 else couleurMontreCoupLegal := NoircirCouleurDeCetteQuantite(whichTexture.RGB,22000);
                 
          PenMode(patCopy);
          RGBForeColor(couleurMontreCoupLegal);
          RGBBackColor(couleurMontreCoupLegal);
          {InSetRect(discRect,2,2);}
          PaintOval(discRect);
       end;
       
    4 : begin  {pion dor� pour montrer le meilleur coup }
	         ForeColor(whichTexture.couleurFront);
	         BackColor(whichTexture.couleurBack);
	         RGBForeColor(whichTexture.RGB);
	         FillRect(boundsRect,blackPattern);
	         
	         InSetRect(discRect,2,2);
	         
	         if avecOmbrageDesPions & false
	          then DessineOmbreDuPion(discRect);
	         
	         SetRGBColor(couleurPionDore,65535,60138,6168);
	         PenMode(patCopy);
	         RGBForeColor(couleurPionDore);
	         RGBBackColor(couleurPionDore);
	         PaintOval(discRect);
	       end;
	       
  end; {case}
  
  {AttendFrappeClavier;     pour debugguer}
end;


procedure KillOffScreenWorldOfDiscs;
begin
  if gOffScreenDiscs <> NIL then 
    begin
      InvalidateAllOffScreenPICTs;
      KillOffscreenPixMap(gOffScreenDiscs,true);
      gOffScreenDiscs := NIL;
    end;
end;

procedure KillOffScreenWorldBordure;
begin
  if gOffScreenBordure <> NIL then 
    begin
      KillTempOffscreenWorld(gOffScreenBordure);
      gOffScreenBordure := NIL;
    end;
end;



procedure CreateOffScreenWorldOfDiscs(tailleCase,FirstPictID : SInt16; var whichTexture:CouleurOthellierRec);
var theRect,boundsRect : rect;
    thePictID,marge,x : SInt32;
    oldport : grafPtr;
    err : OSErr;
    oldResourceFile : SInt16; 
    fichierDesPhotos : FichierTEXT;
    doitFermerFichierPhotos : boolean;
begin

  {WritelnDansRapport('Entree dans CreateOffScreenWorldOfDiscs');}

  {on se garde un carre marge*marge en haut a gauche pour mettre l'original des PICT}
  marge := tailleCase+2;
  if marge < 305 then marge := 305;  
  
  SetRect(theRect,0,0,marge+kNbPictDansUneSerie*(tailleCase+2),marge);
  CreateOffScreenPixMap(theRect,gOffScreenDiscs);
  if gOffScreenDiscs <> NIL then
    begin
      GetPort(oldPort);
      SetPort(GrafPtr(gOffScreenDiscs));
      
      if not(gPendantLesInitialisationsDeCassio) then
        begin
          watch := GetCursor(watchcursor);
	        SafeSetCursor(watch);
	      end;
      
      doitFermerFichierPhotos := false;
      {on prend les PICT dans le fichier de "picture" qui va bien }
      if whichTexture.estUneTexture & 
        (FichierPhotosExisteSurLeDisque(GetPathCompletFichierPionsPourCetteTexture(whichTexture),fichierDesPhotos)) then
	        begin
	          oldResourceFile := CurResFile();
	          err := OuvreRessourceForkFichierTEXT(fichierDesPhotos);
	          {doitFermerFichierPhotos := (err=NoErr);}
	          doitFermerFichierPhotos := true;
	        end;
      
      for thePictID := FirstPictID to FirstPictID+kNbPictDansUneSerie-1 do
        begin
          x := marge+(thePictID-FirstPictID)*(tailleCase+1);
          SetRect(gOffScreenDiscsRectangles[thePictID-FirstPictID],x,0,x+tailleCase,tailleCase);
          
          {on fait du joli dithering}
          if whichTexture.estUneTexture
            then LoadColorPICT(thePictID,NIL,boundsRect)
            else DessinePionDansBufferAvantAntiAliasage(thePictID-FirstPictID,whichTexture,boundsRect);
   
           ForeColor(BlackColor);
           BackColor(WhiteColor);
           CopyBits(GetPortBitMapForCopyBits(gOffScreenDiscs)^ ,
                    GetPortBitMapForCopyBits(gOffScreenDiscs)^ , 
			             boundsRect, gOffScreenDiscsRectangles[thePictID-FirstPictID], ditherCopy + srcCopy, NIL);
			             
          {version sans dithering}
          {LoadColorPICT(thePictID,@gOffScreenDiscsRectangles[thePictID-FirstPictID],boundsRect);}
        end;
      
      
      {faut-il refermer le fichier "Photos Cassio" ?}
      if doitFermerFichierPhotos then
        begin
          err := FermeRessourceForkFichierTEXT(fichierDesPhotos);
          UseResFile(oldResourceFile);
        end;
      
      SerieDePictCouramentAffichee.whichMenuID   := whichTexture.menuID;
      SerieDePictCouramentAffichee.whichMenuItem := whichTexture.menuCmd;
      SetPort(OldPort);
    end;
end;


function CreateOffScreenWorldBordure(tailleCase : SInt16; var whichTexture:CouleurOthellierRec) : OSErr;
var theRect,boundsRect,destRect,myRect : rect;
    i,j : SInt32;
    thePictID : SInt32;
    oldport : grafPtr;
    err : OSErr;
    oldResourceFile : SInt16; 
    fichierDesPhotos : FichierTEXT;
    doitFermerFichierPhotos : boolean;
    windowRect : rect;
begin

  {WritelnDansRapport('Entree dans CreateOffScreenWorldBordure');}
                     
  {SetPositionPlateau2D(8,tailleCase,PositionCoinAvecCoordonnees,PositionCoinAvecCoordonnees);}
  
  if avecSystemeCoordonnees 
    then SetPositionPlateau2D(8,tailleCase,PositionCoinAvecCoordonnees,PositionCoinAvecCoordonnees,'CreateOffScreenWorldBordure')
    else SetPositionPlateau2D(8,tailleCase,PositionCoinSansCoordonnees,PositionCoinSansCoordonnees,'CreateOffScreenWorldBordure');
  
  SetCurrentTailleOfBordurePicts(tailleCase);
  
  gOffScreenBordureRectangles[kBordureDuHautRectID]   := CalculateBordureRect(kBordureDuHaut,whichTexture);
  gOffScreenBordureRectangles[kBordureDeGaucheRectID] := CalculateBordureRect(kBordureDeGauche,whichTexture);
  gOffScreenBordureRectangles[kBordureDuBasRectID]    := CalculateBordureRect(kBordureDuBas,whichTexture);
  gOffScreenBordureRectangles[kBordureDeDroiteRectID] := CalculateBordureRect(kBordureDeDroite,whichTexture);
  
  theRect := MakeRect(gOffScreenBordureRectangles[kBordureDeGaucheRectID].left,
                      gOffScreenBordureRectangles[kBordureDuHautRectID].top,
                      gOffScreenBordureRectangles[kBordureDeDroiteRectID].right,
                      gOffScreenBordureRectangles[kBordureDuBasRectID].bottom);
  
  GetPort(oldport);
  SetPortByWindow(wPlateauPtr);
  windowRect := QDGetPortBound();
  windowRect.right := windowRect.right + 200;
  windowRect.bottom := windowRect.bottom + 200;
	SetPort(oldport);
	
	theRect.right := Max(theRect.right,windowRect.right);
	theRect.bottom := Max(theRect.right,windowRect.bottom);
  
  err := CreateTempOffScreenWorld(theRect,gOffScreenBordure);
  
  if (err = NoErr) & (gOffScreenBordure <> NIL) then
    begin
      gOffScreenBordureBoundingBox := theRect;
      
      GetPort(oldPort);
      SetPort(GrafPtr(gOffScreenBordure));
      
      doitFermerFichierPhotos := false;
      
      {on prend la PICT dans le fichier de bordure qui va bien }
      if FichierPhotosExisteSurLeDisque(GetPathCompletFichierBordurePourCetteTexture(whichTexture),fichierDesPhotos) 
        then
	        begin
	          SetFichierBordureEstIntrouvable(false);
	          
	          oldResourceFile := CurResFile();
	          err := OuvreRessourceForkFichierTEXT(fichierDesPhotos);
	          doitFermerFichierPhotos := true;
	          
	          {PenMode(srcCopy+ditherCopy);}
	          thePictID := 3000;
			      LoadColorPICT(thePictID,NIL,boundsRect);
			      
			      {on peint le rectangle theRect avec l'image que l'on vient de charger en memoire}
			      for i := 0 to 100 do
			        for j := 0 to 100 do
			          begin
			            destRect := boundsRect;
			            OffSetRect(destRect, i * (boundsRect.right - boundsRect.left), j * (boundsRect.bottom - boundsRect.top));
			            
			            if SectRect(theRect,destRect,myRect) then
						        CopyBits(GetPortBitMapForCopyBits(gOffScreenBordure)^ ,
						                 GetPortBitMapForCopyBits(gOffScreenBordure)^ , 
									           boundsRect, destRect, ditherCopy + srcCopy, NIL);
						    end;
						        
			      {faut-il refermer le fichier "Bordures" ?}
			      if doitFermerFichierPhotos then
			        begin
			          err := FermeRessourceForkFichierTEXT(fichierDesPhotos);
			          UseResFile(oldResourceFile);
			        end;
			      
			      {pour le debuggage}
			      if false & windowPlateauOpen  & (wPlateauPtr <> NIL) & IsWindowVisible(wPlateauPtr) then
			        begin
			          EssaieSetPortWindowPlateau;
			          DumpWorkToScreen(theRect,theRect,gOffScreenBordure,GetWindowPort(wPlateauPtr));
			          AttendFrappeClavier;
			        end;
        
	        end
	      else
	        begin
	          
	          {Le fichier "Bordure n'existe pas, ou n'a pas �t� trouv�...}
	          KillOffScreenWorldBordure;
	          RaiseErrorFichierBordureEstIntrouvable;
	        end;
      
      
      SetPort(oldPort);
    end;
  
  CreateOffScreenWorldBordure := err;
end;



procedure InitUnitBufferedPICT;
 begin
   gOffScreenDiscs := NIL;
   gOffScreenBordure := NIL;
   InvalidateAllOffScreenPICTs;
   SerieDePictCouramentAffichee.whichMenuID   := 0;
   SerieDePictCouramentAffichee.whichMenuItem := 0;
   SetCurrentTailleOfBordurePicts(-1);
   gFichierBordureIntrouvable := false;
 end;
 

procedure LibereMemoireUnitBufferedPICT;
begin
  KillOffScreenWorldOfDiscs;
  KillOffScreenWorldBordure;
end;



 
procedure DrawBufferedColorPict(thePictID : SInt16; inRect : rect; var whichTexture:CouleurOthellierRec);
var tailleCase,PremierePictDeLaSerieID : SInt16; 
    oldPort : grafPtr;
    bidRect : rect;
    err : OSErr;
begin
  
  PremierePictDeLaSerieID := (thePictID - (thePictID mod 100));
  
  if (wPlateauPtr = NIL) | not(windowPlateauOpen) then 
    exit(DrawBufferedColorPict);
    
  if (thePictID<PremierePictDeLaSerieID) | (thePictID>PremierePictDeLaSerieID+kNbPictDansUneSerie-1) then
    begin
      SysBeep(0);
      WritelnDansRapport('thePictID n''est pas dans l''intervale minimumPictID-maximumPictID !');
      LoadColorPICT(thePictID,@inrect,bidRect);
      exit(DrawBufferedColorPict);
    end;
    
    
  tailleCase := inRect.right-inRect.left;
  if (tailleCase <> GetCurrentSizeOfBufferedPicts()) |
     (SerieDePictCouramentAffichee.whichMenuID<>whichTexture.menuID) | 
     (SerieDePictCouramentAffichee.whichMenuItem<>whichTexture.menuCmd) then
    begin  
      GetPort(oldPort);
      InvalidateAllOffScreenPICTs;
      
      { Il faut cr�er un nouveau buffer offScreen pour les pions }
      KillOffScreenWorldOfDiscs;
      CreateOffScreenWorldOfDiscs(tailleCase,PremierePictDeLaSerieID,whichTexture);
      if gOffScreenDiscs = NIL then
        begin {rat� !}
          WritelnDansRapport('gOffScreenDiscs = NIL dans DrawBufferedColorPict !!');
          LoadColorPICT(thePictID,@inrect,bidRect);
          SetPort(oldPort);
          exit(DrawBufferedColorPict);
        end;
      
      {et, si c'est la premiere fois que l'on dessine un pion apres les initialisations,
       egalement un nouveau buffer offScreen pour les bordures }
      if (GetCurrentTailleOfBordurePicts() <= 0) then
        begin
          KillOffScreenWorldBordure;
          err := CreateOffScreenWorldBordure(GetTailleCaseCourante(),gCouleurOthellier);
        end;
      
      SetPort(oldPort);
    end;
  
  if (gOffScreenDiscsRectangles[thePictID-PremierePictDeLaSerieID].right-gOffScreenDiscsRectangles[thePictID-PremierePictDeLaSerieID].left)<>(inrect.right-inrect.left)
    then 
      begin
        SysBeep(0);
        WritelnDansRapport('les rectangles n''ont pas la meme largeur !');
        AttendFrappeClavier;
      end;
  
  if (gOffScreenDiscsRectangles[thePictID-PremierePictDeLaSerieID].bottom-gOffScreenDiscsRectangles[thePictID-PremierePictDeLaSerieID].top)<>(inrect.bottom-inrect.top)
    then 
      begin
        SysBeep(0);
        WritelnDansRapport('les rectangles n''ont pas la meme hauteur !');
        AttendFrappeClavier;
      end;
  
  GetPort(oldPort);

  DumpWorkToScreen(gOffScreenDiscsRectangles[thePictID-PremierePictDeLaSerieID],inrect,gOffScreenDiscs,GetWindowPort(wPlateauPtr));
  SetPort(oldPort);
end;


function BordureOthellierEstUneTexture() : boolean;
begin
  (* BordureOthellierEstUneTexture := avecSystemeCoordonnees & not(CassioEstEn3D()) & 
                                   gCouleurOthellier.estUneTexture; *)
  BordureOthellierEstUneTexture := true;
end;



function DrawBordureColorPict(quellesBordures : SInt32) : OSErr;
var oldPort : grafPtr;
    err : OSErr;
begin

  if (wPlateauPtr = NIL) | not(windowPlateauOpen) then
    begin
      DrawBordureColorPict := -1;
      exit(DrawBordureColorPict);
    end;

  if (gOffScreenBordure = NIL) | (GetCurrentTailleOfBordurePicts() <> GetTailleCaseCourante()) then
    begin
      KillOffScreenWorldBordure;
      err := CreateOffScreenWorldBordure(GetTailleCaseCourante(),gCouleurOthellier);
    end;

  if (gOffScreenBordure = NIL) then
    begin
      DrawBordureColorPict := -1;
      exit(DrawBordureColorPict);
    end;
    
  
  GetPort(oldPort);
  SetPortByWindow(wPlateauPtr);
  
  ForeColor(blackColor);
  BackColor(whiteColor);
    
  {bordure en haut}
  if BitAnd(quellesBordures,kBordureDuHaut) <> 0 then
    DumpWorkToScreen(gOffScreenBordureRectangles[kBordureDuHautRectID],gOffScreenBordureRectangles[kBordureDuHautRectID],
                     gOffScreenBordure,GetWindowPort(wPlateauPtr));
    
  {bordure a gauche}
  if BitAnd(quellesBordures,kBordureDeGauche) <> 0 then
    DumpWorkToScreen(gOffScreenBordureRectangles[kBordureDeGaucheRectID],gOffScreenBordureRectangles[kBordureDeGaucheRectID],
                     gOffScreenBordure,GetWindowPort(wPlateauPtr));
    
  {bordure en bas}
  if BitAnd(quellesBordures,kBordureDuBas) <> 0 then
    DumpWorkToScreen(gOffScreenBordureRectangles[kBordureDuBasRectID],gOffScreenBordureRectangles[kBordureDuBasRectID],
                     gOffScreenBordure,GetWindowPort(wPlateauPtr));
    
  {bordure a droite}
  if BitAnd(quellesBordures,kBordureDeDroite) <> 0 then
    DumpWorkToScreen(gOffScreenBordureRectangles[kBordureDeDroiteRectID],gOffScreenBordureRectangles[kBordureDeDroiteRectID],
                     gOffScreenBordure,GetWindowPort(wPlateauPtr));
                   
  SetPort(oldPort);
  DrawBordureColorPict := NoErr;
end;


function DrawBordureRectDansFenetre(whichRect : rect;whichWindow : WindowPtr) : OSErr;
var oldPort : grafPtr;
    windowRect : rect;
begin
  if (whichWindow = NIL) then
    begin
      DrawBordureRectDansFenetre := -1;
      exit(DrawBordureRectDansFenetre);
    end;
  
  GetPort(oldPort);
  SetPortByWindow(whichWindow);
  windowRect := QDGetPortBound();
  
  if (whichRect.right > windowRect.right)   then whichRect.right  := windowRect.right;
  if (whichRect.bottom > windowRect.bottom) then whichRect.bottom := windowRect.bottom;
  
  if not(PtInRect(whichRect.topLeft,gOffScreenBordureBoundingBox) & 
         PtInRect(whichRect.botRight,gOffScreenBordureBoundingBox)) then 
     begin
       KillOffScreenWorldBordure;
       if CreateOffScreenWorldBordure(GetTailleCaseCourante(),gCouleurOthellier) = NoErr then;
     end;
  
  DumpWorkToScreen(whichRect,whichRect,gOffScreenBordure,GetWindowPort(whichWindow));
  SetPort(oldPort);
  
  DrawBordureRectDansFenetre := NoErr;
end;


procedure SetValeurDessinEnTraceDeRayon(square,valeur : SInt16);
begin
  if (square>=11) & (square<=88) then
    DessinEnTraceDeRayon[square] := valeur;
end;

function GetValeurDessinEnTraceDeRayon(square : SInt16) : SInt16; 
begin
  if (square>=11) & (square<=88)
    then GetValeurDessinEnTraceDeRayon := DessinEnTraceDeRayon[square]
    else GetValeurDessinEnTraceDeRayon := kCaseDevantEtreRedessinee;
end;

procedure InvalidateDessinEnTraceDeRayon(square : SInt16);
begin
  SetValeurDessinEnTraceDeRayon(square,kCaseDevantEtreRedessinee);
end;

procedure InvalidateAllCasesDessinEnTraceDeRayon;
var i : SInt16; 
begin
  for i := 11 to 88 do InvalidateDessinEnTraceDeRayon(i);
end;



END.