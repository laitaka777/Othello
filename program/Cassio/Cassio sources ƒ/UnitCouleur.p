UNIT UnitCouleur;


INTERFACE







USES UnitOth0,UnitCalculCouleurCassio;



const   
  Picture2DCmd = 1;     {items du menu Couleur}
  Picture3DCmd = 2;
  {----------}
  VertCmd = 4;
  VertPaleCmd = 5;
  VertSapinCmd = 6;
  VertPommeCmd = 7;
  VertTurquoiseCmd = 8;
  VertKakiCmd = 9;
  BleuCmd = 10;
  BleuPaleCmd = 11;
  MarronCmd = 12;
  RougePaleCmd = 13;
  OrangeCmd = 14;
  JauneCmd = 15;
  JaunePaleCmd = 16;
  MarineCmd = 17;
  MarinePaleCmd = 18;
  VioletCmd = 19;
  MagentaCmd = 20;
  MagentaPaleCmd = 21;
  {-------------}
  AutreCouleurCmd = 23;
  {-------------}
  NoirCmd  = -1;    {valeur speciale : item impossible}
  BlancCmd = -2;
  RougeCmd = 1000; {valeur speciale : item impossible pour pouvoir avoir le rouge en RGB}



var gHasColorQuickDraw : boolean;
    
    gCouleurSupplementaire : RGBColor;
    gEcranCouleur : boolean;
    gBlackAndWhite : boolean;
    gCouleurOthellier : CouleurOthellierRec;

    gPurVert : RGBColor;
    gPurRouge : RGBColor;
    gPurMagenta : RGBColor;
    gPurBlanc : RGBColor;
    gPurNoir : RGBColor;
    gPurBleu : RGBColor;
    gPurJaune : RGBColor;
    gPurCyan : RGBColor;
    gPurGris : RGBColor;
    gPurGrisClair : RGBColor;
    
   
procedure InitUnitCouleur;
procedure SetRGBColor (var theColor: RGBColor; redValue, greenValue, blueValue: SInt32);
function IsSameRGBColor(c1,c2 : RGBColor) : boolean;

function CouleurCmdToRGBColor(couleurCmd : SInt16) : RGBColor;
procedure DetermineFrontAndBackColor(CouleurDemandeeParUtilisateur : SInt16; var couleurFront,couleurBack : SInt16);
procedure DetermineOthellierPatSelonCouleur(CouleurDemandeeParUtilisateur : SInt16; var othellierPat : pattern);
function ChoisirCouleurOthellierAvecPicker(var theColor : RGBColor) : boolean;

function RGBColorEstClaire(color : RGBColor;seuilLuminosite : SInt32) : boolean;
function RGBColorEstFoncee(color : RGBColor;seuilLuminosite : SInt32) : boolean;
function EstUneCouleurTresClaire(CouleurCmd : SInt16) : boolean;
function EstUneCouleurClaire(CouleurCmd : SInt16) : boolean;
function EstUneCouleurComposee(CouleurCmd : SInt16) : boolean;
function DistanceDesCouleurs(c1,c2 : RGBColor) : SInt32;
function CalculePlusProcheCouleurDeBase(couleurOthellier : SInt16; BlancCompris : boolean) : SInt16; 
function GetCouleurAffichageValeurZebraBook(trait : SInt32;whichNote : SInt32) : RGBColor;
procedure DessineCouleurDeZebraBookDansRect(whichRect : rect;trait,valeur : SInt32);

function EclaircirCouleur(theColor : RGBColor) : RGBColor;
function NoircirCouleur(theColor : RGBColor) : RGBColor;
function EclaircirCouleurDeCetteQuantite(theColor : RGBColor; quantite : SInt32) : RGBColor;
function NoircirCouleurDeCetteQuantite(theColor : RGBColor;quantite : SInt32) : RGBColor;



IMPLEMENTATION







USES UnitOth1,UnitDialog,UnitRapport,UnitTroisiemeDimension,ColorPicker,UnitMacExtras;






procedure InitUnitCouleur;
begin
  {$IFC CARBONISATION_DE_CASSIO }
  gHasColorQuickDraw := true;
  {$ELSEC}
  gHasColorQuickDraw := true;
  (* gHasColorQuickDraw := NGetTrapAddress($AA1E, toolTrap) <> NGetTrapAddress($A89F, toolTrap);{_Unimplemented} *)
  {$ENDC}
  
  gCouleurSupplementaire := CouleurCmdToRGBColor(VertPaleCmd); {vert par défaut}
  
  SetRGBColor(gPurRouge,65535,0,0);
  SetRGBColor(gPurVert,0,65535,0);
  SetRGBColor(gPurBleu,0,0,65535);
  SetRGBColor(gPurMagenta,65535,0,65535);
  SetRGBColor(gPurBlanc,65535,65535,65535);
  SetRGBColor(gPurNoir,0,0,0);
  SetRGBColor(gPurGris,32767,32767,32767);
  SetRGBColor(gPurJaune,65535,65535,0);
  SetRGBColor(gPurCyan,0,65535,65535);
  SetRGBColor(gPurGrisClair,55000,55000,55000);
end;


procedure SetRGBColor (var theColor: RGBColor; redValue, greenValue, blueValue: SInt32);
begin
  {$PUSH}
  {$R-}
	with theColor do
		begin
			red := redValue;
			green := greenValue;
			blue := blueValue;
		end;
  {$POP}
end;

function IsSameRGBColor(c1,c2 : RGBColor) : boolean;
begin
  IsSameRGBColor := (c1.red   = c2.red) &
                    (c1.green = c2.green) &
                    (c1.blue  = c2.blue);
end;


function CouleurCmdToRGBColor(couleurCmd : SInt16) : RGBColor;
var theColor : RGBColor;
begin
  case couleurCmd of
	   {NoirEtBlancCmd        : SetRGBColor(theColor,30000,30000,30000);}
	   VertCmd                : SetRGBColor(theColor,0,33410,0);
	   VertPaleCmd            : SetRGBColor(theColor,33608,46267,29753);
	   VertSapinCmd           : SetRGBColor(theColor,14135,29850,12593);
	   VertPommeCmd           : SetRGBColor(theColor,22102,41120,257);
	   VertTurquoiseCmd       : SetRGBColor(theColor,21074,45232,36751);
	   VertKakiCmd            : SetRGBColor(theColor,35503,49018,14482);
	   BleuCmd                : SetRGBColor(theColor,0,39321,65535);
	   BleuPaleCmd            : SetRGBColor(theColor,10000,65535,65335);
	   MarronCmd              : SetRGBColor(theColor,50243,30317,11788);
	   RougeCmd               : SetRGBColor(theColor,65535,0,0);
	   RougePaleCmd           : SetRGBColor(theColor,65535,26193,27446);
	   OrangeCmd              : SetRGBColor(theColor,65535,27783,3318);
	   JauneCmd               : SetRGBColor(theColor,65535,65535,0);
	   JaunePaleCmd           : SetRGBColor(theColor,65535,63776,22812);
	   MarineCmd              : SetRGBColor(theColor,0,0,65535);
	   MarinePaleCmd          : SetRGBColor(theColor,16500,15200,40000);
	   VioletCmd              : SetRGBColor(theColor,27897,6383,38362);
	   MagentaCmd             : SetRGBColor(theColor,50709,19521,65535);
	   MagentaPaleCmd         : SetRGBColor(theColor,65535,23003,62920);
	   AutreCouleurCmd        : theColor := gCouleurSupplementaire;
	   BlancCmd               : SetRGBColor(theColor,65535,65535,65535);
	   NoirCmd                : SetRGBColor(theColor,0,0,0); 
	 otherwise 
	   theColor := CouleurCmdToRGBColor(VertPaleCmd);  {appel récursif pour avoir du vert par défaut}
	end;
	CouleurCmdToRGBColor := theColor;
end;


procedure DetermineFrontAndBackColor(CouleurDemandeeParUtilisateur : SInt16; var couleurFront,couleurBack : SInt16);
begin
  couleurBack := whiteColor;
  case CouleurDemandeeParUtilisateur of
	   {NoirEtBlancCmd          : couleurFront := blackColor;}
	   VertCmd                 : couleurFront := greenColor;
	   VertPaleCmd             : couleurFront := greenColor;
	   VertSapinCmd            : begin
	                               couleurFront := greenColor;
	                               couleurBack := BlackColor;
	                             end;
	   VertPommeCmd            : begin
	                               couleurFront := greenColor;
	                               couleurBack := yellowColor;
	                             end;
	   VertTurquoiseCmd        : begin
	                               couleurFront := greenColor;
	                               couleurBack := cyanColor;
	                             end;
	   VertKakiCmd             : begin
	                               couleurFront := yellowColor;
	                               couleurBack := blackColor;
	                             end;
	   BleuCmd                 : couleurFront := cyanColor;
	   BleuPaleCmd             : couleurFront := cyanColor;
	   MarronCmd               : couleurFront := redColor;
	   RougePaleCmd            : couleurFront := redColor;
	   OrangeCmd               : begin
	                               couleurFront := RedColor;
	                               couleurBack := yellowColor;
	                             end;
	   JauneCmd                : couleurFront := yellowColor;
	   JaunePaleCmd            : couleurFront := yellowColor;
	   MarineCmd               : couleurFront := blueColor;
	   MarinePaleCmd           : couleurFront := blueColor;
	   VioletCmd               : begin
	                               couleurFront := magentaColor;
	                               couleurBack := cyanColor;
	                             end;
	   MagentaCmd              : couleurFront := magentaColor;
	   MagentaPaleCmd          : couleurFront := magentaColor;
	   BlancCmd                : couleurFront := whiteColor;
     
     AutreCouleurCmd         : begin  {qu'est-ce qu'on met ??}
                                 couleurFront := CalculePlusProcheCouleurDeBase(AutreCouleurCmd,false);
                                 couleurBack := BlackColor;
                               end;
     otherwise                 couleurFront := greenColor;
	end;
end;


{ Une couleur RGB est claire si sa luminosité totale 
  est strictement superieure à seuilLuminosite }
function RGBColorEstClaire(color : RGBColor;seuilLuminosite : SInt32) : boolean;
var luminosite : SInt32;
    myHSLColor:HSLColor;
begin
  RGB2HSL(color,myHSLColor);
  luminosite := myHSLColor.lightness;
  if luminosite < 0 then luminosite := luminosite+65535;
  {WritelnStringAndNumDansRapport('luminosite = ',luminosite);}
  RGBColorEstClaire := (luminosite > seuilLuminosite);
end;


{ Une couleur RGB est foncée si sa luminosité totale 
  est inférieure ou égale à seuilLuminosite }
function RGBColorEstFoncee(color : RGBColor;seuilLuminosite : SInt32) : boolean;
begin
  RGBColorEstFoncee := not(RGBColorEstClaire(color,seuilLuminosite));
end;


function EstUneCouleurTresClaire(CouleurCmd : SInt16) : boolean;
begin
  if CouleurCmd = AutreCouleurCmd
    then EstUneCouleurTresClaire := RGBColorEstClaire(gCouleurSupplementaire,40000)
    else EstUneCouleurTresClaire := (CouleurCmd = BlancCmd)       |
                                    (CouleurCmd = JauneCmd)       |
                                    (CouleurCmd = JaunePaleCmd)   |
                                    (CouleurCmd = VertKakiCmd)    |
                                    (CouleurCmd = BleuPaleCmd);
end;

function EstUneCouleurClaire(CouleurCmd : SInt16) : boolean;
begin
  if CouleurCmd = AutreCouleurCmd
    then EstUneCouleurClaire := RGBColorEstClaire(gCouleurSupplementaire,20000)
    else EstUneCouleurClaire :=  (CouleurCmd = BlancCmd)       |
                                 (CouleurCmd = JauneCmd)       |
                                 (CouleurCmd = JaunePaleCmd)   |
                                 (CouleurCmd = VertKakiCmd)    |
                                 (CouleurCmd = BleuPaleCmd);
end;


function EstUneCouleurComposee(CouleurCmd : SInt16) : boolean;
begin
  EstUneCouleurComposee := not((CouleurCmd = VertCmd)   |
                               (CouleurCmd = BleuCmd)   |
                               (CouleurCmd = JauneCmd)  |
                               (CouleurCmd = MarineCmd) |
                               (CouleurCmd = MagentaCmd)|
                               (CouleurCmd = BlancCmd));
end;


function DistanceDesCouleurs(c1,c2 : RGBColor) : SInt32;
var aux1,aux2,sum : SInt32;
begin
  sum := 0;
  aux1 := c1.red;
  if aux1<0 then aux1 := aux1+65535;
  aux2 := c2.red;
  if aux2<0 then aux2 := aux2+65535;
  sum := sum+Abs(aux1-aux2);
  aux1 := c1.green;
  if aux1<0 then aux1 := aux1+65535;
  aux2 := c2.green;
  if aux2<0 then aux2 := aux2+65535;
  sum := sum+Abs(aux1-aux2);
  aux1 := c1.blue;
  if aux1<0 then aux1 := aux1+65535;
  aux2 := c2.blue;
  if aux2<0 then aux2 := aux2+65535;
  sum := sum+Abs(aux1-aux2);
  DistanceDesCouleurs := sum;
end;



function CalculePlusProcheCouleurDeBase(couleurOthellier : SInt16; BlancCompris : boolean) : SInt16; 
var minDist : SInt32;
  
  procedure TestDistanceCetteCouleur(couleur : RGBColor;couleurDeBase : SInt16);
  var dist : SInt32;
  begin
    dist := DistanceDesCouleurs(gCouleurSupplementaire,couleur);
    if dist<minDist then 
      begin
        minDist := dist;
        CalculePlusProcheCouleurDeBase := couleurDeBase;
      end;
  end;
  
begin
  CalculePlusProcheCouleurDeBase := greenColor;  {par defaut}
  case couleurOthellier of
	   {NoirEtBlancCmd         : CalculePlusProcheCouleurDeBase := whiteColor;}
	   VertCmd                : CalculePlusProcheCouleurDeBase := greenColor;
	   VertPaleCmd            : CalculePlusProcheCouleurDeBase := greenColor;
	   VertSapinCmd           : CalculePlusProcheCouleurDeBase := greenColor;
	   VertPommeCmd           : CalculePlusProcheCouleurDeBase := greenColor;
	   VertTurquoiseCmd       : CalculePlusProcheCouleurDeBase := greenColor;
	   VertKakiCmd            : CalculePlusProcheCouleurDeBase := yellowColor;
	   BleuCmd                : CalculePlusProcheCouleurDeBase := cyanColor;
	   BleuPaleCmd            : CalculePlusProcheCouleurDeBase := cyanColor;
	   MarronCmd              : CalculePlusProcheCouleurDeBase := redColor;
	   RougePaleCmd           : CalculePlusProcheCouleurDeBase := redColor;
	   OrangeCmd              : CalculePlusProcheCouleurDeBase := yellowColor;
	   JauneCmd               : CalculePlusProcheCouleurDeBase := yellowColor;
	   JaunePaleCmd           : CalculePlusProcheCouleurDeBase := yellowColor;
	   MarineCmd              : CalculePlusProcheCouleurDeBase := blueColor;
	   MarinePaleCmd          : CalculePlusProcheCouleurDeBase := blueColor;
	   VioletCmd              : CalculePlusProcheCouleurDeBase := magentaColor;
	   MagentaCmd             : CalculePlusProcheCouleurDeBase := magentaColor;
	   MagentaPaleCmd         : CalculePlusProcheCouleurDeBase := magentaColor;
	   BlancCmd               : CalculePlusProcheCouleurDeBase := whiteColor;
	   AutreCouleurCmd        : 
	      begin
		      if (gCouleurSupplementaire.green=gPurVert.green) &
		         (gCouleurSupplementaire.red<>gPurRouge.red) & 
		         (gCouleurSupplementaire.blue<>gPurBleu.blue)
		        then
		          CalculePlusProcheCouleurDeBase := greenColor
		        else
		          begin
					      minDist := 1000000000;
					      TestDistanceCetteCouleur(gPurVert   , greenColor);
					      TestDistanceCetteCouleur(gPurCyan   , cyanColor);
					      TestDistanceCetteCouleur(gPurRouge  , redColor);
					      TestDistanceCetteCouleur(gPurJaune  , yellowColor);
					      TestDistanceCetteCouleur(gPurBleu   , blueColor);
					      TestDistanceCetteCouleur(gPurMagenta, magentaColor);
					      TestDistanceCetteCouleur(gPurNoir   , greenColor);
					      if BlancCompris then TestDistanceCetteCouleur(gPurBlanc  , whiteColor);
					    end;
				end;
  end;  {case}
end;




procedure DetermineOthellierPatSelonCouleur(CouleurDemandeeParUtilisateur : SInt16; var othellierPat : pattern);
var i : SInt16; 
begin  {$UNUSED CouleurDemandeeParUtilisateur}
  if not(gEcranCouleur) 
    then
      begin
        if not(CassioEstEn3D()) & (GetTailleCaseCourante()<=12) 
          then
             othellierPat := whitePattern
          else
            for i := 0 to 7 do othellierPat.pat[i] := 255-grayPattern.pat[i];
      end
    else
      othellierPat := blackPattern;
end;


function ChoisirCouleurOthellierAvecPicker(var theColor : RGBColor) : boolean;
const TextesDiversID=10020;
var prompt : str255;
    where : Point;
    newColor : RGBColor;
begin
  where.h := -1;
  where.v := -1;  {valeur spéciale pour avoir le dialogue centré sur l'écran avec le plus de couleurs}
  GetIndString(prompt,TextesDiversID,5);  {'Choisissez la couleur de l'othellier'}
  newColor := theColor;
  BeginDialog;
  if GetColor(where,prompt,theColor,newColor) 
    then
      begin
        theColor := newColor;
        ChoisirCouleurOthellierAvecPicker := true;
      end
    else
      begin
        ChoisirCouleurOthellierAvecPicker := false;
      end;
  EndDialog;
end;


function EclaircirCouleurDeCetteQuantite(theColor : RGBColor; quantite : SInt32) : RGBColor;
var redValue,greenValue,blueValue : SInt32;
    result : RGBColor;
    eclaircicement : SInt32;
begin
  redValue   := theColor.red;
  greenValue := theColor.green;
  blueValue  := theColor.blue;
  
  if redValue   < 0 then redValue   := redValue   + 65535;
  if greenValue < 0 then greenValue := greenValue + 65535;
  if blueValue  < 0 then blueValue  := blueValue  + 65535;
  
  eclaircicement := quantite;
  
  redValue   := Min(65535,eclaircicement + redValue);
  greenValue := Min(65535,eclaircicement + greenValue);
  blueValue  := Min(65535,eclaircicement + blueValue);
  
  redValue   := Max(0, redValue);
  greenValue := Max(0, greenValue);
  blueValue  := Max(0, blueValue);
  
  SetRGBColor(result,redValue,greenValue,blueValue);
  EclaircirCouleurDeCetteQuantite := result;
end;


function NoircirCouleurDeCetteQuantite(theColor : RGBColor;quantite : SInt32) : RGBColor;
var redValue,greenValue,blueValue : SInt32;
    result : RGBColor;
    noircissement : SInt32;
begin
  
  redValue   := theColor.red;
  greenValue := theColor.green;
  blueValue  := theColor.blue;
  
  if redValue   < 0 then redValue   := redValue   + 65535;
  if greenValue < 0 then greenValue := greenValue + 65535;
  if blueValue  < 0 then blueValue  := blueValue  + 65535;
  
  noircissement := -quantite;

  redValue   := Max(0,noircissement + redValue);
  greenValue := Max(0,noircissement + greenValue);
  blueValue  := Max(0,noircissement + blueValue);
  
  redValue   := Min(65535, redValue);
  greenValue := Min(65535, greenValue);
  blueValue  := Min(65535, blueValue);
  
  SetRGBColor(result,redValue,greenValue,blueValue);
  NoircirCouleurDeCetteQuantite := result;
end;


function NoircirCouleur(theColor : RGBColor) : RGBColor;
begin
  NoircirCouleur := NoircirCouleurDeCetteQuantite(theColor, 22000);
end;

function EclaircirCouleur(theColor : RGBColor) : RGBColor;
begin
  EclaircirCouleur := EclaircirCouleurDeCetteQuantite(theColor, 12000);
end;


function GetCouleurAffichageValeurZebraBook(trait : SInt32;whichNote : SInt32) : RGBColor;
var theColor : RGBColor;
    interet : SInt32;
begin
  case trait of
    pionNoir : begin
                 theColor := CouleurCmdToRGBColor(OrangeCmd);
                 theColor := NoircirCouleurDeCetteQuantite(theColor,10000);
               end;
    pionBlanc : begin
                  (* theColor := NoircirCouleurDeCetteQuantite(gPurVert,3000);
                  theColor := gCouleurOthellier.RGB; *)
                  SetRGBColor(theColor,20560,47800,14135);
                  theColor := NoircirCouleurDeCetteQuantite(theColor,10000);
                end;
  end;
  
  interet := whichNote;
  if (interet > 600) then interet := 600;
  if (interet < -700) then interet := -700;
  interet := 60*interet;
  
  GetCouleurAffichageValeurZebraBook := NoircirCouleurDeCetteQuantite(theColor,interet);
end;


procedure DessineCouleurDeZebraBookDansRect(whichRect : rect;trait,valeur : SInt32);
var theColor : RGBColor;
begin
  theColor := GetCouleurAffichageValeurZebraBook(trait,valeur);
    				            
  RGBForeColor(theColor);
  RGBBackColor(theColor);
  
  FillRect(whichRect,blackPattern);
  
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
end;




END.



