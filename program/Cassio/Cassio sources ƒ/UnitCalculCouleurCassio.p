UNIT UnitCalculCouleurCassio;


INTERFACE 








USES MacTypes,QuickDraw;

type CouleurOthellierRec = record
                             menuID : SInt16; 
                             menuCmd : SInt16; 
                             estTresClaire : boolean;
                             estComposee : boolean;
                             estUneTexture : boolean;
                             estPovRayEn3D : boolean;
                             couleurFront : SInt16; 
                             couleurBack : SInt16; 
                             RGB : RGBColor;
                             whichPattern : pattern;
                             plusProcheCouleurDeBase : SInt16; 
                             plusProcheCouleurDeBaseSansBlanc : SInt16; 
                             nomFichierTexture : str255;
                           end;


function CalculeCouleurRecord(whichMenuID,whichMenuCmd : SInt16):CouleurOthellierRec;
procedure CheckScreenDepth;
procedure CheckValidityOfCouleurRecord(var whichColor:CouleurOthellierRec; var colorChanged : boolean);

function PlusProcheCouleurRGBOfTexture(var whichColor:CouleurOthellierRec; var textureInconnue : boolean) : RGBColor;




IMPLEMENTATION







USES UnitRapport,UnitOth1,UnitFichierPhotos,UnitMenus,UnitFenetres,UnitCouleur,UnitMacExtras;


function CalculeCouleurRecord(whichMenuID,whichMenuCmd : SInt16):CouleurOthellierRec;
var aux:CouleurOthellierRec;
    textureInconnue : boolean;
begin
  with aux do
    begin
      menuID                          := whichMenuID;
      menuCmd                         := whichMenuCmd;
	    
	    DetermineFrontAndBackColor(menuCmd,couleurFront,couleurBack);
	    DetermineOthellierPatSelonCouleur(menuCmd,whichPattern);
	  
	  if (whichMenuID = 100)   { CouleurID = 100 est defini dans UnitMenu.p}
	    then 
	      begin
	        nomFichierTexture := 'kSimplementUneCouleur';
	        estUneTexture := false;
	        estPovRayEn3D := false;
	        
	        RGB                             := CouleurCmdToRGBColor(menuCmd);
			    estTresClaire                   := EstUneCouleurTresClaire(menuCmd);
		      estComposee                     := EstUneCouleurComposee(menuCmd);
		      plusProcheCouleurDeBase         := CalculePlusProcheCouleurDeBase(menuCmd,true);
		      if whichMenuCmd<>BlancCmd
		        then plusProcheCouleurDeBaseSansBlanc := CalculePlusProcheCouleurDeBase(menuCmd,false)
		        else plusProcheCouleurDeBaseSansBlanc := BlancCmd;  {on force ça}
        
	      end
	    else 
	      begin
	        estUneTexture := true;
	        nomFichierTexture := GetNomDansMenuPourCetteTexture(aux);
	        estPovRayEn3D := (whichMenuID = 110);  { Picture3DID = 110 est defini dans UnitMenu.p}
	      
	        RGB                              := PlusProcheCouleurRGBOfTexture(aux,textureInconnue);
			    estTresClaire                    := RGBColorEstClaire(RGB,40000);
		      estComposee                      := true;
		      plusProcheCouleurDeBase          := CalculePlusProcheCouleurDeBase(VertCmd,true);
		      plusProcheCouleurDeBaseSansBlanc := CalculePlusProcheCouleurDeBase(VertCmd,false);
	      end;
	    
	    
	    
	    {
	    WritelnStringAndNumDansRapport('menuCmd = ',menuCmd);
	    if EsttResClaire 
	      then WritelnStringAndNumDansRapport('est tres claire = ',1)
	      else WritelnStringAndNumDansRapport('est tres claire = ',0);
	    if estComposee 
	      then WritelnStringAndNumDansRapport('est composee = ',1)
	      else WritelnStringAndNumDansRapport('est composee = ',0);
	    WritelnStringAndNumDansRapport('plusProcheCouleurDeBase = ',plusProcheCouleurDeBase);
	    WritelnStringAndNumDansRapport('plusProcheCouleurDeBaseSansBlanc = ',plusProcheCouleurDeBaseSansBlanc);
	    WritelnStringAndNumDansRapport('couleurFront = ',couleurFront);
	    WritelnStringAndNumDansRapport('couleurBack = ',couleurBack);
	    }
	    
	  end;
  CalculeCouleurRecord := aux;
end; 


procedure CheckScreenDepth;
var oldEcranCouleur,nouvelEcranEstEnCouleur : boolean;
begin
  oldEcranCouleur := gEcranCouleur;
  if gHasColorQuickDraw
    then nouvelEcranEstEnCouleur := (ProfondeurMainDevice()>2)
    else nouvelEcranEstEnCouleur := false;
  if oldEcranCouleur<>nouvelEcranEstEnCouleur then
    if nouvelEcranEstEnCouleur
      then   {l'utilisateur a augmenté le nbre de couleurs  }
        begin
          gEcranCouleur := true;
          gBlackAndWhite := not(gEcranCouleur);
          gCouleurOthellier := CalculeCouleurRecord(gCouleurOthellier.menuID,gCouleurOthellier.menuCmd);	        
	        InvalidateAllWindows;
        end
      else   {l'utilisateur a baissé le nbre de couleurs }
	      begin
	        gEcranCouleur := false;
	        gBlackAndWhite := not(gEcranCouleur);
	        gCouleurOthellier.couleurFront := blackColor;
	        gCouleurOthellier.couleurBack := whiteColor;
	        DetermineOthellierPatSelonCouleur(gCouleurOthellier.menuCmd,gCouleurOthellier.whichPattern);
	        InvalidateAllWindows;
	      end;
end;



procedure CheckValidityOfCouleurRecord(var whichColor:CouleurOthellierRec; var colorChanged : boolean);
var numero,nbCouleursDansMenu : SInt16; 
    fic : FichierTEXT;
    probleme : boolean;
begin
  probleme := false;
  
  with whichColor do
    if (nomFichierTexture = '') | (nomFichierTexture = 'kSimplementUneCouleur')
      then
        begin
          nbCouleursDansMenu := AutreCouleurCmd; {CountMItem(CouleurMenu) - 3}
          if menuCmd <= nbCouleursDansMenu
            then whichColor := CalculeCouleurRecord(CouleurID,menuCmd)
            else probleme := true;
        end
      else
        begin
          if not(FichierPhotosExisteDansMenu(nomFichierTexture,numero))
            then 
              probleme := true
            else
              with gFichiersPicture.fic[numero] do
                if not(FichierPhotosExisteSurLeDisque(nomComplet^,fic))
                  then probleme := true
                  else whichColor := CalculeCouleurRecord(whichMenuID,whichMenuItem);
        end;
        
  if probleme then
    begin
      whichColor := CalculeCouleurRecord(CouleurID,VertPaleCmd);
    end;
  
  colorChanged := probleme;
end;


function PlusProcheCouleurRGBOfTexture(var whichColor:CouleurOthellierRec; var textureInconnue : boolean) : RGBColor;
var result : RGBColor;

  procedure SetResult(red,green,blue  : SInt32);
    begin
      SetRGBColor(result,red,green,blue);
      textureInconnue := false;
    end;
  
begin
  result := gPurVert; {defaut}
  textureInconnue := true;
  
  with whichColor do
    begin
      if estPovRayEn3D                               then SetResult(2600, 31300,11100) else
      if nomFichierTexture = 'Photographique'        then SetResult(15000,31000,26000) else
      if nomFichierTexture = 'Pions go'              then SetResult(45400,34000,23000) else
      if (Pos('Realiste',nomFichierTexture) > 0) |
         (Pos('Réaliste',nomFichierTexture) > 0) |
         (Pos('Fantaisie',nomFichierTexture) > 0)    then SetResult(11000,26000,6100) else
      if (Pos('Metal',nomFichierTexture) > 0) |
         (Pos('Métal',nomFichierTexture) > 0) |
         (Pos('Vert &',nomFichierTexture) > 0)       then SetResult(18500,23500,31000) else   
      if (Pos('VOG',nomFichierTexture) > 0)          then SetResult(8400, 36000,21000) else
      if (Pos('Zebra',nomFichierTexture) > 0)        then SetResult(14800,32300,17520) else
      if (Pos('Alveole',nomFichierTexture) > 0)      then SetResult(15350,31900,17800) else
      if nomFichierTexture = 'kSimplementUneCouleur' then SetResult(RGB.red, RGB.green, RGB.blue) else
      if nomFichierTexture = 'Boules'                then SetResult(0,0,0);
    end;
    
  PlusProcheCouleurRGBOfTexture := result;
end;

END.