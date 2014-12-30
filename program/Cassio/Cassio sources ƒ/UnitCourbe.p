UNIT UnitCourbe;



INTERFACE







USES MyTypes,UnitOth0;


TYPE
   typeColorationCourbe = (kCourbeNoirEtBlanc,kCourbeColoree,kCourbePastel,kEffacerCourbe,kEffacerCourbeSansDessinerLeRepere);
   typeLateralisationContinuite = (kAGauche,kADroite,kGlobalement);
   typeGenreDeReflexion = (kNonPrecisee,kMilieuDePartie,kFinaleParfaite,kFinaleWLD);
   SetOfGenreDeReflexion = set of typeGenreDeReflexion;

CONST 
   kTouteLaCourbe = -1000;

CONST 
   kCoeffMultiplicateurPourCourbeEnFinale = 85;
   

{ Initialisation de l'unite }
procedure InitUnitCourbe;
procedure LibereMemoireUnitCourbe;


{ fonctions elementaires de dessin pour la courbe }
procedure BeginDrawingCourbe;
procedure EndDrawingCourbe;
procedure DetermineRectanglesActifsFenetreCourbe;
function HauteurCourbe() : SInt32;
function LargeurCourbe() : SInt32;
procedure EraseRectDansCourbe(myRect : rect);
procedure EraseZoneGriseDansCourbe;
procedure DessineRepereCourbe(theClipRect : rect;fonctionAppelante : str255);
procedure DessineTrapezeCouleurDansCourbe(x1,x2 : Point; mil : SInt32;coloration:typeColorationCourbe);


{ Effacage de la courbe }
procedure EffaceCourbe(n,nfin : SInt32;coloration:typeColorationCourbe;fonctionAppelante : str255);
procedure EffacerTouteLaCourbe(fonctionAppelante : str255);
procedure EffacerLaFinDeLaCourbe(apresCeNroDeCoup : SInt32;fonctionAppelante : str255);


{ Dessin de la courbe }
procedure TraceSegmentCourbeSansDessinerLeRepere(numeroDuCoup : SInt32;coloration:typeColorationCourbe;fonctionAppelante : str255; var regionEffacee : rect);
procedure TraceSegmentCourbe(numeroDuCoup : SInt32;coloration:typeColorationCourbe;fonctionAppelante : str255);
procedure DessineCourbe(n,nfin : SInt32;coloration:typeColorationCourbe;fonctionAppelante : str255);


{ procedures de gestions des valeurs de la courbe }
procedure ViderValeursDeLaCourbe;
procedure InvalidateEvaluationPourCourbe(nroCoupMin,nroCoupMax : SInt32);
procedure SetEvaluationPourCourbeProvientDeLaFinale(nroDuCoup : SInt32;flag : boolean);
procedure SetEvaluationPourCourbeDejaConnue(nroDuCoup : SInt32;flag : boolean);
procedure SetEvaluationPourNoirDansCourbe(nroDuCoup,evaluationPourNoir : SInt32;origine:typeGenreDeReflexion);
procedure SetCourbeEstContinueEnCePoint(nroDuCoup : SInt32;quelCote:typeLateralisationContinuite;flag : boolean);
procedure MetScorePrevuParFinaleDansCourbe(nroCoupDeb,nroCoupFin : SInt32;origine:typeGenreDeReflexion;scorePourNoir : SInt32);
procedure EssaieMettreEvaluationDeMilieuDansCourbe(square,couleur,numeroDuCoup : SInt32; var position : plateauOthello;
                                                   nbreBlancs,nbreNoirs : SInt32; var jouables : plBool; var frontiere : InfoFrontRec);
function PeutCopierEndgameScoreFromGameTreeDansCourbe(G : GameTree;nroDuCoup : SInt32;origineCherchees:SetOfGenreDeReflexion) : boolean;


{ Fonctions d'acces aux valeurs de la courbe }
function GetEvaluationPourNoirDansCourbe(nroDuCoup : SInt32) : SInt32;
function GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup(nroDuCoup : SInt32) : SInt32;
function EvaluationPourCourbeProvientDeLaFinale(nroDuCoup : SInt32) : boolean;
function EvaluationPourCourbeDejaConnue(nroDuCoup : SInt32) : boolean;
function GetOrigineEvaluationDansCourbe(nroDuCoup : SInt32):typeGenreDeReflexion;
function CourbeEstContinueEnCePoint(nroDuCoup : SInt32;quelCote:typeLateralisationContinuite) : boolean;


{ Gestion des evenements dans la fenetre de la courbe }
procedure TraiteSourisCourbe(evt : eventRecord);
procedure TraiteClicSurSliderCourbe(mouseLoc : Point);
function TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe(mouseGlobalLoc : Point) : boolean;
function EstUnClicSurSliderCourbe(mouseLoc : Point) : boolean;


{ Gestion de la barre horizontale }
procedure DessineSliderFenetreCourbe;
function NroDeCoupEnPositionSurCourbe(nro : SInt32) : SInt32;
function NroDeCoupEnPositionDeSliderCourbe(nro : SInt32) : SInt32;
function PositionSourisEnNumeroDeCoupSurCourbe(positionX : SInt32) : SInt32;
function PositionSourisEnNumeroDeCoupSurSlider(positionX : SInt32) : SInt32;


{ Gestion des commentaires sur la premiere ligne }
procedure EffaceCommentaireCourbe;
procedure EcritCommentaireCourbe(nroCoup : SInt32);
procedure SetDoitEcrireCommentaireCourbe(flag : boolean);
function DoitEcrireCommentaireCourbe() : boolean;



IMPLEMENTATION







USES UnitOth0,UnitCarbonisation,UnitMacExtras,UnitRapport,SNStrings,UnitOth1,UnitOth2,UnitGameTree,
     UnitCouleur,UnitGeometrie,UnitActions,UnitScannerOthellistique,UnitEvaluation,UnitSuperviseur,
     UnitFenetres,UnitJeu;




TYPE      
   t_listeEval = array[0..65] of 
                   record
                     evalNoir             : SInt32;
                     origineEval          : typeGenreDeReflexion;
                     evalCourbeDejaConnue : boolean;
                     evalDonneeParFinale  : boolean;
                     continueADroite      : boolean;
                     continueAGauche      : boolean;
                   end;

VAR 
   gCourbeData : record
                   premierSegmentDessine     : SInt32;
                   dernierSegmentDessine     : SInt32;
                   niveauxRecursionDrawing   : SInt32;
                   dernierCommentaireAffiche : SInt32;
                   premierCoupSansEvaluation : SInt32;
                   windowPortBound           : rect;
                   courbeRect                : rect;
                   sliderRect                : rect;
                   zoneSensibleSlider        : rect;
                   zoneGriseRect             : rect;
                   commentaireRect           : rect;
                   lastMouseLocUtilisee      : Point;
                   ecrireCommentaire         : boolean;
                   dernierTickCommentaire    : SInt32;
                   listeEvaluations          : t_listeEval;
                 end;

CONST 
  kMargeDeplacementZoneGriseCourbe = 20;
  kPetiteMargeDansZoneGrise = 3;

procedure InitUnitCourbe;
begin
  with gCourbeData do
    begin
      premierSegmentDessine     := 0;
      dernierSegmentDessine     := 0;
      niveauxRecursionDrawing   := 0;
      premierCoupSansEvaluation := 0;
      windowPortBound           := MakeRect(0,0,0,0);
      courbeRect                := MakeRect(0,0,0,0);
      sliderRect                := MakeRect(0,0,0,0);
      zoneSensibleSlider        := MakeRect(0,0,0,0);
      zoneGriseRect             := MakeRect(0,0,0,0);
    end;
  SetDoitEcrireCommentaireCourbe(true);
end;


procedure LibereMemoireUnitCourbe;
begin
end;


procedure ViderValeursDeLaCourbe;
begin
  with gCourbeData do
    begin
      MemoryFillChar(@listeEvaluations,sizeof(listeEvaluations),chr(0));
      premierCoupSansEvaluation := 0;
      {WritelnStringAndNumDansRapport('ViderValeursDeLaCourbe : premierCoupSansEvaluation = ',premierCoupSansEvaluation);}
    end;
end;


function HauteurCourbe() : SInt32;
begin
  with gCourbeData.courbeRect do
    HauteurCourbe := bottom - top;
end;


function LargeurCourbe() : SInt32;
begin
  with gCourbeData.courbeRect do
    LargeurCourbe := right - left;
end;


procedure DetermineRectanglesActifsFenetreCourbe;
var marge : SInt32;
begin
  marge := kMargeDeplacementZoneGriseCourbe;
  with gCourbeData do
    begin
      windowPortBound := QDGetPortBound();
      courbeRect      := MakeRect(windowPortBound.left + marge,
                                  windowPortBound.top + marge,
                                  windowPortBound.right - marge,
                                  windowPortBound.bottom - 40);
      sliderRect      := MakeRect(windowPortBound.left + marge - 6,
                                  courbeRect.bottom + 14,
                                  windowPortBound.right - marge + 8,
                                  courbeRect.bottom + 20);
      zoneGriseRect   := MakeRect(kPetiteMargeDansZoneGrise + marge,0+marge,LargeurCourbe()+marge,HauteurCourbe()+marge);
      commentaireRect := MakeRect(marge - 10 , 5 , windowPortBound.right ,18);
      
      zoneSensibleSlider := sliderRect;
      InSetRect(zoneSensibleSlider, -20, -20);
    end;
end;


procedure EraseRectDansCourbe(myRect : rect);
begin
  {EraseRect(myRect);}
  
	RGBForeColor(gPurGrisClair);
	FillRect(myRect, blackPattern);
	RGBForeColor(gPurNoir);
end;


procedure EraseZoneGriseDansCourbe;
var myRect : rect;
    oldPort : grafPtr;
begin
  myRect := gCourbeData.zoneGriseRect;
  inc(myRect.right);
  
  GetPort(oldPort);
  SetPortByWindow(wCourbePtr);
  EraseRectDansCourbe(myRect);
  SetPort(oldPort);
end;


procedure BeginDrawingCourbe;
begin
  with gCourbeData do
    begin
      inc(niveauxRecursionDrawing);
    end;
end;


procedure EndDrawingCourbe;
begin
  with gCourbeData do
    begin
      dec(niveauxRecursionDrawing);
    end;
end;



procedure WriteDebugageCourbe(s : str255);
begin  {$UNUSED s}
  {WritelnDansRapport(s);}
end;


procedure DessineRepereCourbe(theClipRect : rect;fonctionAppelante : str255);
var x,largeur,haut,mil : SInt32;
    oldport : grafPtr;
    marge,i,n : SInt32;
    s : string;
begin
  if windowCourbeOpen then
    with gCourbeData do
    begin
      GetPort(oldport);
      SetPortByWindow(wCourbePtr);
      
      if gCassioUseQuartzAntialiasing then 
        EnableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr),true);
      
      WriteDebugageCourbe(NumEnString(nbreCoup)+' : DessineRepereCourbe(), fonction appelante = '+fonctionAppelante);
      
      DetermineRectanglesActifsFenetreCourbe;
      BeginDrawingCourbe;
      
      
      marge := kPetiteMargeDansZoneGrise;
      haut := HauteurCourbe();
      mil := kMargeDeplacementZoneGriseCourbe + haut div 2 - 1;
      largeur := LargeurCourbe() - marge;
      PenSize(1,1);
      PenPat(blackPattern);
      
      ClipRect(theClipRect);
      
      { dessin de l'axe horizontal et de la fleche de droite}
      Moveto(kMargeDeplacementZoneGriseCourbe + marge,mil);
      Lineto(kMargeDeplacementZoneGriseCourbe + largeur + marge,mil);
      Lineto(kMargeDeplacementZoneGriseCourbe + largeur + marge - 3,mil+3);
      Moveto(kMargeDeplacementZoneGriseCourbe + largeur + marge ,mil);
      Lineto(kMargeDeplacementZoneGriseCourbe + largeur + marge - 3,mil-3);
      
      { dessine de l'axe vertical et des deux fleches }
      Moveto(kMargeDeplacementZoneGriseCourbe + marge-3,kMargeDeplacementZoneGriseCourbe + haut-5);
      Lineto(kMargeDeplacementZoneGriseCourbe + marge,kMargeDeplacementZoneGriseCourbe + haut-2);
      Moveto(kMargeDeplacementZoneGriseCourbe + marge+3,kMargeDeplacementZoneGriseCourbe + haut-5);
      Lineto(kMargeDeplacementZoneGriseCourbe + marge,kMargeDeplacementZoneGriseCourbe + haut-2);
      Lineto(kMargeDeplacementZoneGriseCourbe + marge,kMargeDeplacementZoneGriseCourbe + 2);
      Lineto(kMargeDeplacementZoneGriseCourbe + marge+3,kMargeDeplacementZoneGriseCourbe + 5);
      Moveto(kMargeDeplacementZoneGriseCourbe + marge,kMargeDeplacementZoneGriseCourbe + 2);
      Lineto(kMargeDeplacementZoneGriseCourbe + marge-3,kMargeDeplacementZoneGriseCourbe + 5);
      
      TextMode(1);
      TextFont(gCassioApplicationFont);
      TextSize(gCassioSmallFontSize);
      GetIndString(s,TextesCourbeID,1);
      Moveto(kMargeDeplacementZoneGriseCourbe + marge+14,kMargeDeplacementZoneGriseCourbe + 29);
      if s = 'bon pour Noir'
        then
          begin
            TextFace(normal);
            DrawString('bon pour ');
            TextFace(bold);
            DrawString('Noir');
          end
        else
          DrawString(s);
      GetIndString(s,TextesCourbeID,2);
      Moveto(kMargeDeplacementZoneGriseCourbe + marge+14,kMargeDeplacementZoneGriseCourbe + haut-22);
      if s = 'bon pour Blanc'
        then
          begin
            TextFace(normal);
            DrawString('bon pour ');
            TextFace(bold);
            DrawString('Blanc');
          end
        else
          DrawString(s);
      
      
      { dessin des graduations de l'axe horizontal }
      
      TextFont(gCassioApplicationFont);
      TextFace(normal);
      GetIndString(s,TextesCourbeID,3);  {'coup'}
      Moveto(kMargeDeplacementZoneGriseCourbe + marge + largeur - StringWidth(s), mil + 9);
      if (58 > nroDernierCoupAtteint)
        then RGBForeColor(gPurGris)
        else RGBForeColor(gPurNoir);
      DrawString(s);
      
      for i := 1 to 5 do
        begin
          n := 10*i;
          s := NumEnString(n);
          x := kMargeDeplacementZoneGriseCourbe + marge + ((n*largeur) div 60);
          
          if (n > nroDernierCoupAtteint)
             then RGBForeColor(gPurGris)
             else RGBForeColor(gPurNoir);
          Moveto(x,mil-2);
          Lineto(x,mil+2);
          Moveto(x-6,mil+11);
          DrawString(s);
        end;
      RGBForeColor(gPurNoir);
      
      EndDrawingCourbe;
      ClipRect(windowPortBound);
      
      { effacer a droite de la zone grise }
	    EraseRect(MakeRect(zoneGriseRect.right+1,zoneGriseRect.top,zoneGriseRect.right + 10, zoneGriseRect.bottom));
      
      
      SetPort(oldport);
    end;
end;


{passer n = kEffacerTouteLaCourbe pour effacer toute la courbe}
procedure EffaceCourbe(n,nfin : SInt32;coloration:typeColorationCourbe;fonctionAppelante : str255);
var largeur,haut,mil : SInt32;
    oldport : grafPtr;
    unRect : rect;
    marge,i : SInt32;
    effRect,accu : rect;
begin  
  if windowCourbeOpen then
    with gCourbeData do
    begin
      GetPort(oldport);
      SetPortByWindow(wCourbePtr);
      
      WriteDebugageCourbe(NumEnString(nbreCoup)+' : EffaceCourbe['+NumEnString(n)+','+NumEnString(nfin)+'], fonction appelante = '+fonctionAppelante);
      
      DetermineRectanglesActifsFenetreCourbe;
      BeginDrawingCourbe;
      
      
      if (n = kTouteLaCourbe)
        then 
          begin
            DessineBoiteDeTaille(wCourbePtr);
            EraseZoneGriseDansCourbe;
            DessineRepereCourbe(windowPortBound,fonctionAppelante+'->EffaceCourbe{1}->');
          end
        else
         begin
           marge := kPetiteMargeDansZoneGrise;
           haut := HauteurCourbe();
           mil := kMargeDeplacementZoneGriseCourbe + haut div 2 - 1;
           largeur := LargeurCourbe() - marge;
           SetRect(unRect,kMargeDeplacementZoneGriseCourbe + marge + ((n*largeur) div 60) + 1,
                          kMargeDeplacementZoneGriseCourbe,
                          kMargeDeplacementZoneGriseCourbe + marge + ((Min(60,nfin)*largeur) div 60) + 1,
                          kMargeDeplacementZoneGriseCourbe + haut);
           {if (nfin >= 60) then inc(unRect.right);}
           EraseRectDansCourbe(unRect);
           ClipRect(unRect);
           
           case coloration of
             kEffacerCourbe : 
               begin
                 DessineRepereCourbe(unRect,fonctionAppelante+'->EffaceCourbe{2}->');
               end;
             kEffacerCourbeSansDessinerLeRepere :
               begin
                 { do nothing... }
               end;
             kCourbePastel :
               begin
                 accu := MakeRect(0,0,0,0);
                 
                 {for i := n to nroDernierCoupAtteint do
                   WritelnStringAndBoolDansRapport(NumEnString(nbreCoup)+' (pre) : continue['+NumEnString(i)+'] = ',CourbeEstContinueEnCePoint(i,kGlobalement));}
                 
                 i := n+1;
                 repeat
                   if (i <= nroDernierCoupAtteint) then 
                     begin
                       TraceSegmentCourbeSansDessinerLeRepere(i,kCourbePastel,fonctionAppelante+'->EffaceCourbe{3}->',effRect);
                       UnionRect(accu,effRect,accu);
                     end;
                   i := i+1;
                 until (i > nroDernierCoupAtteint) |
                       ((i > nfin + 2) & CourbeEstContinueEnCePoint(i,kGlobalement));
                 
                 {for i := n to nroDernierCoupAtteint do
                   WritelnStringAndBoolDansRapport(NumEnString(nbreCoup)+' (post) : continue['+NumEnString(i)+'] = ',CourbeEstContinueEnCePoint(i,kGlobalement));}
                 
                 DessineRepereCourbe(accu,fonctionAppelante+'->EffaceCourbe{3}->')
               end;
           end; {case}
               
           
           if unRect.right >= windowPortBound.right-15 then DessineBoiteDeTaille(wCourbePtr);
           ClipRect(windowPortBound);
         end;
      
      EndDrawingCourbe;
      SetPort(oldport);
    end;
end;


procedure EffacerTouteLaCourbe(fonctionAppelante : str255);
begin
  WriteDebugageCourbe(NumEnString(nbreCoup)+' : EffacerTouteLaCourbe, fonction appelante = '+fonctionAppelante);
  if windowCourbeOpen then 
    EffaceCourbe(kTouteLaCourbe,kTouteLaCourbe,kEffacerCourbe,fonctionAppelante+'->EffacerTouteLaCourbe');
    
  with gCourbeData do
    begin
      premierSegmentDessine := 0;
      dernierSegmentDessine := 0;
    end;
end;


procedure EffacerLaFinDeLaCourbe(apresCeNroDeCoup : SInt32;fonctionAppelante : str255);
begin
  with gCourbeData do
    begin
      WriteDebugageCourbe(NumEnString(nbreCoup)+' : EffacerLaFinDeLaCourbe, fonction appelante = '+fonctionAppelante);
  
      if windowCourbeOpen & (dernierSegmentDessine >= apresCeNroDeCoup) then
        begin
           EffaceCourbe(apresCeNroDeCoup,61,kEffacerCourbe,fonctionAppelante+'->EffacerLaFinDeLaCourbe');
           if dernierSegmentDessine >= apresCeNroDeCoup then dernierSegmentDessine := apresCeNroDeCoup - 1;
        end;
      if (dernierCommentaireAffiche >= apresCeNroDeCoup) then EffaceCommentaireCourbe;
    end;
end;


procedure DessineTrapezeCouleurDansCourbe(x1,x2 : Point; mil : SInt32;coloration:typeColorationCourbe);
const kLargeurMinimalePourRecursion = 2;
var x0,x3,pointDichotomie : Point;
    a,b : SInt32;
    myPoly:polyHandle;
    oldport : grafPtr;
    myRGBColor : RGBColor;
    note : SInt32;
    echelle : extended;
begin
  {WriteDebugageCourbe(NumEnString(nbreCoup)+' : DessineTrapezeCouleurDansCourbe()');}
  
  if windowCourbeOpen then
    BEGIN
        if ((x1.v <= mil) & (x2.v <= mil)) | ((x1.v >= mil) & (x2.v >= mil))  
          then  {les deux points sont du meme cote de l'axe}
            begin
              
              
              if ((x2.h - x1.h) >= kLargeurMinimalePourRecursion) & (x1.v <> x2.v) & (coloration <> kCourbePastel) 
                then { on coupe le trapeze en 2 pour avoir un joli dŽgradŽ }
                  begin
                    SetPt(pointDichotomie, (x1.h + x2.h) div 2, (x1.v + x2.v + 1) div 2);
                    DessineTrapezeCouleurDansCourbe(x1,pointDichotomie,mil,coloration);
                    DessineTrapezeCouleurDansCourbe(pointDichotomie,x2,mil,coloration);
                  end
                else
                  begin
                    GetPort(oldport);
          		      SetPortByWindow(wCourbePtr);
          		      
          		      SetPt(x0,x1.h,mil);
          		      SetPt(x3,x2.h,mil);
          		      
          		      if (coloration = kCourbePastel) 
          		        then note := 0
          		        else
          		          begin
                		      echelle := (1.0*(mil-kMargeDeplacementZoneGriseCourbe)/4000.0)/4.5;
                		      note := Abs(x1.v - mil) + Abs(x2.v - mil);
                		      note := MyTrunc(note/echelle) div kCoeffMultiplicateurPourCourbeEnFinale;
                		    end;
          		      
          		      
                    if  (x2.v > mil) |
          		         ((x2.v = mil) & (x1.v > mil)) 
          		         then myRGBColor := GetCouleurAffichageValeurZebraBook(pionBlanc,note)
          		         else myRGBColor := GetCouleurAffichageValeurZebraBook(pionNoir,note);
          		      
          		      if (coloration = kCourbePastel) 
          		        then myRGBColor := EclaircirCouleurDeCetteQuantite(myRGBColor,40000);
          		      
          		      { creation du trapeze }
          		      myPoly := OpenPoly();  
          		      Moveto(x0.h + 1, x0.v);
          		      Lineto(x1.h + 1, x1.v);
          		      Lineto(x2.h + 1, x2.v);
          		      Lineto(x3.h + 1, x3.v);
          		      ClosePoly;
          		      
          		      { coloriage du trapeze }
          		      RGBForeColor(myRGBColor);
          		      FillPoly(myPoly,blackPattern);
          		      ForeColor(BlackColor);
          		      KillPoly(myPoly);
          		  
          		      SetPort(oldport);
          		    end;
             end
           else  {les deux points sont de cotes differents de l'axe : dichotomie }
             begin 
               Intersection(x1.h,x1.v,x2.h,x2.v,-1000,mil,1000,mil,a,b);
               SetPt(pointDichotomie,a,mil);
               DessineTrapezeCouleurDansCourbe(x1,pointDichotomie,mil,coloration);
               DessineTrapezeCouleurDansCourbe(pointDichotomie,x2,mil,coloration);
             end;
    END;
end;



procedure TraceQuelquesSegmentsDeLaCourbe(n : SInt32;coloration:typeColorationCourbe; var regionEffacee : rect);
var x,y : SInt32;
    largeur,haut,mil : SInt32;
    note : SInt32;
    oldport : grafPtr;
    echelle : extended;
    marge : SInt32;
    x1,x2 : Point;
    unRect : rect;
begin
  if windowCourbeOpen & (n >= 1) & (n <= 60) & (n <= nroDernierCoupAtteint) then
    with gCourbeData do
      begin
        GetPort(oldport);
        SetPortByWindow(wCourbePtr);
        
        {WriteDebugageCourbe(NumEnString(nbreCoup)+' : TraceQuelquesSegmentsDeLaCourbe('+NumEnString(n)+')');}
        
        DetermineRectanglesActifsFenetreCourbe;
        BeginDrawingCourbe;
        
        marge := kPetiteMargeDansZoneGrise;
        haut := HauteurCourbe();
        mil := kMargeDeplacementZoneGriseCourbe + haut div 2 - 1;
        echelle := 1.0*(mil-kMargeDeplacementZoneGriseCourbe)/4000.0;
        largeur := LargeurCourbe() - marge;
        
        if (n = 1)
          then 
            begin
              SetPt(x1,kMargeDeplacementZoneGriseCourbe + marge,mil);
            end
          else
            begin
              if not(EvaluationPourCourbeProvientDeLaFinale(n-1))
                then note := (GetEvaluationPourNoirDansCourbe(n-2)+GetEvaluationPourNoirDansCourbe(n-1)) div 2
                else note := GetEvaluationPourNoirDansCourbe(n-1);
              x := kMargeDeplacementZoneGriseCourbe + (((n-1)*largeur) div 60);
              y := MyTrunc(mil-note*echelle);
              if y < kMargeDeplacementZoneGriseCourbe + 2      then y := kMargeDeplacementZoneGriseCourbe + 2;
              if y > kMargeDeplacementZoneGriseCourbe + haut-3 then y := kMargeDeplacementZoneGriseCourbe + haut-3;
              SetPt(x1,marge+x,y);
             end;
             
        if not(EvaluationPourCourbeProvientDeLaFinale(n))
          then note := (GetEvaluationPourNoirDansCourbe(n-1)+GetEvaluationPourNoirDansCourbe(n)) div 2
          else note := GetEvaluationPourNoirDansCourbe(n);
        x := kMargeDeplacementZoneGriseCourbe + ((n*largeur) div 60);
        y := MyTrunc(mil-note*echelle);
        if y < kMargeDeplacementZoneGriseCourbe + 2      then y := kMargeDeplacementZoneGriseCourbe + 2;
        if y > kMargeDeplacementZoneGriseCourbe + haut-3 then y := kMargeDeplacementZoneGriseCourbe + haut-3;
        SetPt(x2,marge+x,y);
        
        
        SetRect(unRect,kMargeDeplacementZoneGriseCourbe + marge + (((n-1)*largeur) div 60) + 1,
                       kMargeDeplacementZoneGriseCourbe + 0,
                       kMargeDeplacementZoneGriseCourbe + marge + ((n*largeur) div 60) + 1,
                       kMargeDeplacementZoneGriseCourbe + haut);
        {if (n >= 60) then inc(unRect.right);}
        EraseRectDansCourbe(unRect);
        
        ClipRect(unRect);
        
        if (n <= nbreCoup)
          then DessineTrapezeCouleurDansCourbe(x1,x2,mil,kCourbeColoree)
          else DessineTrapezeCouleurDansCourbe(x1,x2,mil,kCourbePastel);
        
        UnionRect(regionEffacee,unRect,regionEffacee);
        ClipRect(windowPortBound);
        
        
        if (n > dernierSegmentDessine) then dernierSegmentDessine := n;
        if (n < premierSegmentDessine) then premierSegmentDessine := n;
        
        SetCourbeEstContinueEnCePoint(n-1,kADroite,true);
        SetCourbeEstContinueEnCePoint(n  ,kAGauche,true);
        
        
        if (n+1 <= nroDernierCoupAtteint) & not(CourbeEstContinueEnCePoint(n+1,kGlobalement)) 
          then TraceQuelquesSegmentsDeLaCourbe(n+1,coloration,regionEffacee);
        
        if (n-1 >= 1) & not(CourbeEstContinueEnCePoint(n-1,kGlobalement)) 
          then TraceQuelquesSegmentsDeLaCourbe(n-1,coloration,regionEffacee);
        
        if (n = nroDernierCoupAtteint) then 
          EffacerLaFinDeLaCourbe(nroDernierCoupAtteint,'TraceQuelquesSegmentsDeLaCourbe');
          
        
        PenSize(2,2);
        PenPat(blackPattern);
        Moveto(x1.h,x1.v);
        Lineto(x2.h,x2.v);
        
        EndDrawingCourbe;
        SetPort(oldport);
      end;
end;


procedure TraceSegmentCourbe(numeroDuCoup : SInt32;coloration:typeColorationCourbe;fonctionAppelante : str255);
var regionEffacee : rect;
begin 
  WriteDebugageCourbe(NumEnString(nbreCoup)+' : TraceSegmentCourbe('+NumEnString(numeroDuCoup)+'), fonction appelante = '+fonctionAppelante);
  
  if windowCourbeOpen & (numeroDuCoup >= 1) & (numeroDuCoup <= 60) & (numeroDuCoup <= nroDernierCoupAtteint) then
    begin
      regionEffacee := MakeRect(0,0,0,0);
      TraceQuelquesSegmentsDeLaCourbe(numeroDuCoup,coloration,regionEffacee);
      DessineRepereCourbe(regionEffacee,fonctionAppelante+'->TraceSegmentCourbe->');
    end;
end;


procedure TraceSegmentCourbeSansDessinerLeRepere(numeroDuCoup : SInt32;coloration:typeColorationCourbe;fonctionAppelante : str255; var regionEffacee : rect);
begin 
  WriteDebugageCourbe(NumEnString(nbreCoup)+' : TraceSegmentCourbeSansDessinerLeRepere('+NumEnString(numeroDuCoup)+'), fonction appelante = '+fonctionAppelante);
  
  regionEffacee := MakeRect(0,0,0,0);
  
  if windowCourbeOpen & (numeroDuCoup >= 1) & (numeroDuCoup <= 60) & (numeroDuCoup <= nroDernierCoupAtteint) then
    TraceQuelquesSegmentsDeLaCourbe(numeroDuCoup,coloration,regionEffacee);
end;


procedure DessineCourbe(n,nfin : SInt32;coloration:typeColorationCourbe;fonctionAppelante : str255);
var x,y : SInt32;
    largeur,haut,mil : SInt32;
    i,note : SInt32;
    oldport : grafPtr;
    echelle : extended;
    marge : SInt32;
    x1,x2,oldx1 : Point;
begin
  if windowCourbeOpen then
    with gCourbeData do
      begin
        GetPort(oldport);
        SetPortByWindow(wCourbePtr);
        
        WriteDebugageCourbe(NumEnString(nbreCoup)+' : DessineCourbe['+NumEnString(n)+','+NumEnString(nfin)+'], fonction appelante = '+fonctionAppelante);
        
        DetermineRectanglesActifsFenetreCourbe;
        BeginDrawingCourbe;
        
        marge := kPetiteMargeDansZoneGrise;
        haut := HauteurCourbe();
        mil := kMargeDeplacementZoneGriseCourbe + haut div 2 - 1;
        echelle := 1.0*(mil-kMargeDeplacementZoneGriseCourbe)/4000.0;
        largeur := LargeurCourbe() - marge;
        
        EraseZoneGriseDansCourbe;
        
        PenSize(2,2);
        PenPat(blackPattern);
        SetPt(x1,kMargeDeplacementZoneGriseCourbe + marge,mil);
        oldx1 := x1;
        for i := 1 to nroDernierCoupAtteint do
          begin
            if not(EvaluationPourCourbeProvientDeLaFinale(i))
              then note := (GetEvaluationPourNoirDansCourbe(i-1)+GetEvaluationPourNoirDansCourbe(i)) div 2
              else note := GetEvaluationPourNoirDansCourbe(i);
            x := kMargeDeplacementZoneGriseCourbe + ((i*largeur) div 60);
            y := MyTrunc(mil-note*echelle);
            if y < kMargeDeplacementZoneGriseCourbe + 2      then y := kMargeDeplacementZoneGriseCourbe + 2;
            if y > kMargeDeplacementZoneGriseCourbe + haut-3 then y := kMargeDeplacementZoneGriseCourbe + haut-3;
            SetPt(x2,marge+x,y);
            
            if (i <= nbreCoup)
              then DessineTrapezeCouleurDansCourbe(x1,x2,mil,coloration)
              else DessineTrapezeCouleurDansCourbe(x1,x2,mil,kCourbePastel);
              
            
            Moveto(oldx1.h,oldx1.v);
            Lineto(x1.h,x1.v);
            Lineto(x2.h,x2.v);
            
            
            oldx1 := x1;
            x1 := x2;
          end;
        
        if (nroDernierCoupAtteint > dernierSegmentDessine) then dernierSegmentDessine := nroDernierCoupAtteint;
        if (1 < premierSegmentDessine)                     then premierSegmentDessine := 1;
        
        EndDrawingCourbe;
        DessineRepereCourbe(windowPortBound,fonctionAppelante+'->DessineCourbe');
        ValidRect(GetWindowPortRect(wCourbePtr));
        SetPort(oldport);
      end;
end;


function EvaluationPourCourbeProvientDeLaFinale(nroDuCoup : SInt32) : boolean;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) & (nroDuCoup <= 65)
      then EvaluationPourCourbeProvientDeLaFinale := listeEvaluations[nroDuCoup].evalDonneeParFinale
      else EvaluationPourCourbeProvientDeLaFinale := false;
end;


function EvaluationPourCourbeDejaConnue(nroDuCoup : SInt32) : boolean;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) & (nroDuCoup <= 65)
      then EvaluationPourCourbeDejaConnue := listeEvaluations[nroDuCoup].evalCourbeDejaConnue
      else EvaluationPourCourbeDejaConnue := false;
end;


procedure SetEvaluationPourCourbeProvientDeLaFinale(nroDuCoup : SInt32;flag : boolean);
begin
  with gCourbeData do
    if (nroDuCoup >= 0) & (nroDuCoup <= 65) then
      begin
        if (listeEvaluations[nroDuCoup].evalDonneeParFinale <> flag) then
          begin
            SetCourbeEstContinueEnCePoint(nroDuCoup,kGlobalement,false);
            listeEvaluations[nroDuCoup].evalDonneeParFinale := flag;
          end;
      end;
end;


procedure SetEvaluationPourCourbeDejaConnue(nroDuCoup : SInt32;flag : boolean);
begin
  with gCourbeData do
    if (nroDuCoup >= 1) & (nroDuCoup <= 65) then
      begin
        listeEvaluations[nroDuCoup].evalCourbeDejaConnue := flag;
        
        
        { mise a jour (partielle) de premierCoupSansEvaluation }
        if flag & (nroDuCoup >= premierCoupSansEvaluation) 
          then premierCoupSansEvaluation := nroDuCoup + 1;
          
        if not(flag) & (premierCoupSansEvaluation = nroDuCoup+1)
          then premierCoupSansEvaluation := nroDuCoup;
          
        {WritelnStringAndNumDansRapport('SetConnue['+NumEnString(nroDuCoup)+','+BoolEnString(flag)+'] : premierCoupSansEvaluation = ',premierCoupSansEvaluation);}
      end;
end;


procedure InvalidateEvaluationPourCourbe(nroCoupMin,nroCoupMax : SInt32);
var n : SInt32;
    doitExecuterLaBoucle : boolean;
begin
  with gCourbeData do 
    begin
      doitExecuterLaBoucle := true;
      if (premierCoupSansEvaluation <= nroCoupMin) then doitExecuterLaBoucle := false;
      
      {WritelnStringAndBoolDansRapport('Invalidate['+NumEnString(nroCoupMin)+','+NumEnString(nroCoupMax)+'] : doitExecuterLaBoucle = ',doitExecuterLaBoucle);}
      
      if doitExecuterLaBoucle then
        for n := nroCoupMax downto nroCoupMin do
          begin
            SetEvaluationPourCourbeDejaConnue(n,false);
            SetEvaluationPourCourbeProvientDeLaFinale(n,false);
            SetEvaluationPourNoirDansCourbe(n,0,kNonPrecisee);
          end;
      
      
      if (nroCoupMax >= 60) & (premierCoupSansEvaluation > nroCoupMin) then
        premierCoupSansEvaluation := nroCoupMin;
        
      {WritelnStringAndNumDansRapport('Invalidate : premierCoupSansEvaluation = ',premierCoupSansEvaluation);}
    end;
end;


function GetEvaluationPourNoirDansCourbe(nroDuCoup : SInt32) : SInt32;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) & (nroDuCoup <= 65)
      then GetEvaluationPourNoirDansCourbe := listeEvaluations[nroDuCoup].evalNoir
      else GetEvaluationPourNoirDansCourbe := 0;
end;


function GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup(nroDuCoup : SInt32) : SInt32;
var k : SInt32;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) & (nroDuCoup <= 65) then
      for k := nroDuCoup downto 0 do
        if (listeEvaluations[k].origineEval = kMilieuDePartie) then
          begin
            GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup := listeEvaluations[k].evalNoir;
            exit(GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup);
          end;
          
  GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup := 0;
end;

function GetOrigineEvaluationDansCourbe(nroDuCoup : SInt32):typeGenreDeReflexion;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) & (nroDuCoup <= 60)
      then GetOrigineEvaluationDansCourbe := listeEvaluations[nroDuCoup].origineEval
      else GetOrigineEvaluationDansCourbe := kNonPrecisee;
end;


procedure SetEvaluationPourNoirDansCourbe(nroDuCoup,evaluationPourNoir : SInt32;origine:typeGenreDeReflexion);
var oldEvaluation : SInt32;
    oldOrigine:typeGenreDeReflexion;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) & (nroDuCoup <= 65) then
      begin
        oldEvaluation := listeEvaluations[nroDuCoup].evalNoir;
        oldOrigine    := listeEvaluations[nroDuCoup].origineEval;
        
        if (evaluationPourNoir <> oldEvaluation) | (oldOrigine <> origine) then 
          begin
            SetCourbeEstContinueEnCePoint(nroDuCoup,kGlobalement,false);
            
            {WritelnStringAndNumDansRapport('Courbe['+NumEnString(nroDuCoup)+'] = ',evaluationPourNoir div kCoeffMultiplicateurPourCourbeEnFinale);}
            
            if (evaluationPourNoir >  64*kCoeffMultiplicateurPourCourbeEnFinale) then evaluationPourNoir :=  64*kCoeffMultiplicateurPourCourbeEnFinale else
            if (evaluationPourNoir < -64*kCoeffMultiplicateurPourCourbeEnFinale) then evaluationPourNoir := -64*kCoeffMultiplicateurPourCourbeEnFinale;
            
            listeEvaluations[nroDuCoup].evalNoir    := evaluationPourNoir;
            listeEvaluations[nroDuCoup].origineEval := origine;
          end;
      end;
end;


function CourbeEstContinueEnCePoint(nroDuCoup : SInt32;quelCote:typeLateralisationContinuite) : boolean;
begin
  if (nroDuCoup >= 0) & (nroDuCoup <= 65) 
    then
      begin
        with gCourbeData.listeEvaluations[nroDuCoup] do
          case quelCote of
            kAGauche :
              begin
                CourbeEstContinueEnCePoint := continueAGauche;
              end;
            kADroite :
              begin
                CourbeEstContinueEnCePoint := continueADroite;
              end;
            kGlobalement :
              begin
                CourbeEstContinueEnCePoint := continueAGauche & continueADroite;
              end;
        end; {case}
      end
    else
      CourbeEstContinueEnCePoint := false;
end;


procedure SetCourbeEstContinueEnCePoint(nroDuCoup : SInt32;quelCote:typeLateralisationContinuite;flag : boolean);
begin
  if (nroDuCoup >= 0) & (nroDuCoup <= 65) 
    then
      begin
        with gCourbeData.listeEvaluations[nroDuCoup] do
          case quelCote of
            kAGauche :
              begin
                continueAGauche := flag;
              end;
            kADroite :
              begin
                continueADroite := flag;
              end;
            kGlobalement :
              begin
                continueAGauche := flag;
                continueADroite := flag;
              end;
        end; {case}
      end;
end;


procedure MetScorePrevuParFinaleDansCourbe(nroCoupDeb,nroCoupFin : SInt32;origine:typeGenreDeReflexion;scorePourNoir : SInt32);
var i,note,noteCoupPrec : SInt32;
begin

  if (origine = kFinaleParfaite)
    then
      begin
        note := scorePourNoir*kCoeffMultiplicateurPourCourbeEnFinale;
        
        for i := nroCoupDeb to nroCoupFin do
          begin
            SetEvaluationPourCourbeDejaConnue(i-1,true);
            SetEvaluationPourCourbeProvientDeLaFinale(i-1,true);
            SetEvaluationPourNoirDansCourbe(i-1,note,kFinaleParfaite);
          end;
          
      end
    else
      begin
        if EvaluationPourCourbeProvientDeLaFinale(nroCoupDeb - 1)
          then noteCoupPrec := GetEvaluationPourNoirDansCourbe(nroCoupDeb - 1)
          else noteCoupPrec := GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup(nroCoupDeb - 2);
        
        if ((noteCoupPrec > 0) & (scorePourNoir > 0)) | ((noteCoupPrec < 0) & (scorePourNoir < 0))
          then 
            begin
              note := noteCoupPrec div kCoeffMultiplicateurPourCourbeEnFinale;
              if not(odd(note)) then 
                if (note > 0) 
                  then note := note+1 
                  else note := note-1;
              note := note*kCoeffMultiplicateurPourCourbeEnFinale;
            end
          else 
            if scorePourNoir = 0 then note :=  0 else
            if scorePourNoir > 0 then note :=  2*kCoeffMultiplicateurPourCourbeEnFinale else
            if scorePourNoir < 0 then note := -2*kCoeffMultiplicateurPourCourbeEnFinale;
            
        for i := nroCoupDeb to nroCoupFin do
          begin
            SetEvaluationPourCourbeDejaConnue(i-1,true);
            SetEvaluationPourCourbeProvientDeLaFinale(i-1,true);
            SetEvaluationPourNoirDansCourbe(i-1,note,kFinaleWLD);
          end;
      end;
  
  for i := nroCoupDeb-1 to nroCoupFin+2 do
    TraceSegmentCourbe(i-1,kCourbeColoree,'MetScorePrevuParFinaleDansCourbe');
    
  { Remarque : lors d'une analyse retrograde, on n'affiche le nouveau score que
               si on a eu une periode d'inactivite de 30 secondes au moins }
  if not(analyseRetrograde.enCours) | (((TickCount() - gCourbeData.dernierTickCommentaire) div 60) > 30)
    then EcritCommentaireCourbe(nbreCoup);
end;


procedure EssaieMettreEvaluationDeMilieuDansCourbe(square,couleur,numeroDuCoup : SInt32; var position : plateauOthello;
                                                   nbreBlancs,nbreNoirs : SInt32; var jouables : plBool; var frontiere : InfoFrontRec);
var uneNote : SInt32;
    nbEvalRecursives : SInt32;
begin
  if HumCtreHum | (numeroDuCoup < finDePartie) | not(EvaluationPourCourbeDejaConnue(numeroDuCoup)) then
    begin
    
      {WritelnStringAndNumDansRapport('numeroDuCoup = ',numeroDuCoup);
      WritelnStringAndNumDansRapport('couleur = ',couleur);
      WritelnStringAndNumDansRapport('square = ',square);
      WritelnStringAndNumDansRapport('i.nroDuCoup = ',InfosDerniereReflexionMac.nroDuCoup);
      WritelnStringAndNumDansRapport('i.coup = ',InfosDerniereReflexionMac.coup);
      WritelnStringAndNumDansRapport('i.coul = ',InfosDerniereReflexionMac.coul);
      WritelnStringAndNumDansRapport('i.valeurCoup = ',InfosDerniereReflexionMac.valeurCoup);}
    
      if not(HumCtreHum) & 
         (InfosDerniereReflexionMac.nroDuCoup = numeroDuCoup) & 
         (InfosDerniereReflexionMac.coup = square) & 
         (InfosDerniereReflexionMac.coul = couleur) &
         (InfosDerniereReflexionMac.valeurCoup <> -noteMax)
        then
          begin
            if InfosDerniereReflexionMac.coul = pionNoir
              then SetEvaluationPourNoirDansCourbe(numeroDuCoup,  InfosDerniereReflexionMac.valeurCoup, kMilieuDePartie)
              else SetEvaluationPourNoirDansCourbe(numeroDuCoup, -InfosDerniereReflexionMac.valeurCoup, kMilieuDePartie);
          end
        else
          begin
            if ((numeroDuCoup mod 8) = 0) | ((numeroDuCoup mod 8) = 1) then Superviseur(numeroDuCoup);
            
            uneNote := penalitePourTraitAff - Evaluation(position,-couleur,nbreBlancs,nbreNoirs,
                                                         jouables,frontiere,false,
                                                         -30000,30000,nbEvalRecursives);
            if numeroDuCoup <= 4 then uneNote := uneNote div 2;
            if couleur = pionBlanc 
              then SetEvaluationPourNoirDansCourbe(numeroDuCoup , -uneNote, kMilieuDePartie)
              else SetEvaluationPourNoirDansCourbe(numeroDuCoup ,  uneNote, kMilieuDePartie);
          end;
          
      SetEvaluationPourCourbeDejaConnue(numeroDuCoup ,true);
      SetEvaluationPourCourbeProvientDeLaFinale(numeroDuCoup ,false);
      
      if not(HumCtreHum | EvaluationPourCourbeDejaConnue(numeroDuCoup + 1))
        then 
          begin
            SetEvaluationPourNoirDansCourbe(numeroDuCoup + 1, GetEvaluationPourNoirDansCourbe(numeroDuCoup), kMilieuDePartie);
            SetEvaluationPourCourbeProvientDeLaFinale(numeroDuCoup + 1, false);
          end;
    end;
end;



function PeutCopierEndgameScoreFromGameTreeDansCourbe(G : GameTree;nroDuCoup : SInt32;origineCherchees:SetOfGenreDeReflexion) : boolean;
var scoreMinPourNoir,scoreMaxPourNoir : SInt32;
    note : SInt32;
begin
  
  
  if GetEndgameScoreDeCetteCouleurDansGameNode(G,pionNoir,scoreMinPourNoir,scoreMaxPourNoir) then
    begin
    
      { Est-ce un score parfait ? }
      if (kFinaleParfaite in origineCherchees) & (scoreMinPourNoir = scoreMaxPourNoir) & (scoreMinPourNoir >= -64) & (scoreMinPourNoir <= 64) then
        begin
          note := scoreMinPourNoir*kCoeffMultiplicateurPourCourbeEnFinale;
          {WritelnStringAndNumDansRapport('Chouette, un score parfait@'+ NumEnString(nroDuCoup)+' : ',scoreMinPourNoir);}
          
          SetEvaluationPourNoirDansCourbe(nroDuCoup,note,kFinaleParfaite);
          SetEvaluationPourCourbeProvientDeLaFinale(nroDuCoup,true);
          SetEvaluationPourCourbeDejaConnue(nroDuCoup,true);
          
          PeutCopierEndgameScoreFromGameTreeDansCourbe := true;
          exit(PeutCopierEndgameScoreFromGameTreeDansCourbe);
        end;
        
      { Est-ce un score WLD gagnant ? }
      if (kFinaleWLD in origineCherchees) & (scoreMinPourNoir > 0) & (scoreMinPourNoir <= 64) then
        begin
        
          MetScorePrevuParFinaleDansCourbe(nroDuCoup+1,nroDuCoup+1,kFinaleWLD,2);
        
          {WritelnStringAndNumDansRapport('Chouette, un score gagnant WLD@'+ NumEnString(nroDuCoup)+' : ',2);}
          
          PeutCopierEndgameScoreFromGameTreeDansCourbe := true;
          exit(PeutCopierEndgameScoreFromGameTreeDansCourbe);
        end;
      
      { Est-ce un score WLD perdant ? }
      if (kFinaleWLD in origineCherchees) & (scoreMaxPourNoir < 0) & (scoreMaxPourNoir >= -64) then
        begin
        
          MetScorePrevuParFinaleDansCourbe(nroDuCoup+1,nroDuCoup+1,kFinaleWLD,-2);
         
          {WritelnStringAndNumDansRapport('Chouette, un score perdant WLD@'+ NumEnString(nroDuCoup)+' : ',-2);}
          
          PeutCopierEndgameScoreFromGameTreeDansCourbe := true;
          exit(PeutCopierEndgameScoreFromGameTreeDansCourbe);
        end;
        
    end;
 
  PeutCopierEndgameScoreFromGameTreeDansCourbe := false;
  
end;


function NroDeCoupEnPositionSurCourbe(nro : SInt32) : SInt32;
var x : SInt32;
begin
  x := kMargeDeplacementZoneGriseCourbe + ((nro*(LargeurCourbe() - kPetiteMargeDansZoneGrise)) div 60);
  
  NroDeCoupEnPositionSurCourbe := x;
end;




function NroDeCoupEnPositionDeSliderCourbe(nro : SInt32) : SInt32;
begin
  NroDeCoupEnPositionDeSliderCourbe := NroDeCoupEnPositionSurCourbe(nro);
end;


function PositionSourisEnNumeroDeCoupSurCourbe(positionX : SInt32) : SInt32;
var marge,largeur : SInt32;
begin
  marge := 3;
  largeur := LargeurCourbe() - marge;
  PositionSourisEnNumeroDeCoupSurCourbe := (60*(positionX - marge - kMargeDeplacementZoneGriseCourbe)) div largeur + 1;
end;


function PositionSourisEnNumeroDeCoupSurSlider(positionX : SInt32) : SInt32;
var largeur,result : SInt32;
    marge : SInt32;
begin
  marge := 3;
  largeur := LargeurCourbe() - 3;
  result := (60*(positionX - marge - kMargeDeplacementZoneGriseCourbe)) div largeur + 1;
  
  if result < 0 then result := 0;
  if result > 60 then result := 60;
  
  PositionSourisEnNumeroDeCoupSurSlider := result;
end;


procedure DessineSliderFenetreCourbe;
var s : str255;
    err : OSStatus;
    theSlider:ControlHandle;
    oldPort : grafPtr;
    ligneRect : rect;
    myRect : rect;
    x : SInt32;
    deltaADroite : SInt32;
begin
  if windowCourbeOpen then
    with gCourbeData do
      begin
        GetPort(oldPort);
        SetPortByWindow(wCourbePtr);
        
        
        if (nroDernierCoupAtteint > 0) 
          then
            begin
              
              myRect := sliderRect;
              
              (*
              EraseRect(sliderRect);
              err := CreateSliderControl(wCourbePtr,myRect,nbreCoup,0,60,
                                         {kControlSliderPointsUpOrLeft}kControlSliderDoesNotPoint, 0, false, NIL, theSlider);
              *)
          
              deltaADroite := sliderRect.right - NroDeCoupEnPositionDeSliderCourbe(60);
              myRect.right := NroDeCoupEnPositionDeSliderCourbe(nroDernierCoupAtteint) + deltaADroite + 3;
              
            
          
              err := CreateSliderControl(wCourbePtr,myRect,nbreCoup,0,nroDernierCoupAtteint,
                                         {kControlSliderPointsUpOrLeft}kControlSliderDoesNotPoint, 0, false, NIL, theSlider);
              
              
              // on efface l'ancien slider et la zone a droite du nouveau
              EraseRect(sliderRect);
              EraseRect(MakeRect(myRect.right,myRect.top-10,sliderRect.right+10,myRect.bottom+10));
                                         
              if (err = NoErr) & (theSlider <> NIL) then
                begin
                  Draw1Control(theSlider);
                  ShowControl(theSlider);
                  if SetControlVisibility(theSlider,false,false) = NoErr then;
                  SizeControl(theSlider,0,0);
                  DisposeControl(theSlider);
                end; 
              
              if (nbreCoup > 0) & (nbreCoup <= 60) & (DerniereCaseJouee() <> coupInconnu)
                then 
                  begin
                    s := NumEnString(nbreCoup)+'.'+CoupEnString(DerniereCaseJouee(),CassioUtiliseDesMajuscules);
                    if nbreCoup < 10 then s := 'Ê' + s;
                  end
                else s := '';
              
              
              {ligneRect := MakeRect(sliderRect.left - 20,sliderRect.top - 20, sliderRect.right + 20,sliderRect.top - 4);}
              ligneRect := MakeRect(sliderRect.left - 20,sliderRect.bottom + 7, sliderRect.right + 20,sliderRect.bottom + 17);
              EraseRect(ligneRect);
              DessineBoiteDeTaille(wCourbePtr);
              
              if (s <> '') then
                begin
                  TextFont(gCassioApplicationFont);
                  TextSize(gCassioSmallFontSize);
                  x := NroDeCoupEnPositionDeSliderCourbe(nbreCoup) - (StringWidth(s) div 2) + 3;
                  if (x >= windowPortBound.right - 43) then x := windowPortBound.right - 43;
                  Moveto(x,ligneRect.bottom - 2);
                  DrawString(s);
                end;
              
              EcritCommentaireCourbe(nbreCoup);
            
            end
          else
            begin
              { Quand nroDernierCoupAtteint = 0 , il faut effacer plus largement puisque l'on ne va pas redessiner le slider juste apres }
              myRect := sliderRect;
              InSetRect(myRect, -10, -10);
              EraseRect(myRect);
            end;
        
        SetPort(oldPort);
      end;
end;


function EstUnClicSurSliderCourbe(mouseLoc : Point) : boolean;
var aux : SInt32;
    test : boolean;
begin
  aux := NroDeCoupEnPositionDeSliderCourbe(nbreCoup) + 6;
  test := (Abs(mouseLoc.h - aux) <= 13);
  EstUnClicSurSliderCourbe := test;
end;


procedure TraiteClicSurSliderCourbe(mouseLoc : Point);
var oldPort : grafPtr;
    numeroDuCoupDemande : SInt32;
    tireCurseur,bouge : boolean;
    enRetourArrivee : boolean;
    HumCtreHumArrivee : boolean;
    sourisRect : rect;
    mouseX : SInt32;
begin
  if windowCourbeOpen then
    with gCourbeData do
      begin
        GetPort(oldPort);
        SetPortByWindow(wCourbePtr);
        
        if PtInRect(mouseLoc,zoneSensibleSlider) & EstUnClicSurSliderCourbe(mouseLoc) & (nroDernierCoupAtteint > 0) then
          begin
          
            enRetourArrivee := enRetour;
            HumCtreHumArrivee := HumCtreHum;
          
            sourisRect := SliderRect;
            InSetRect(sourisRect,-200,-700);
            
            tireCurseur := true;
            mouseX := 0;
            while Button() & tireCurseur & windowCourbeOpen do
              begin
                InitCursor;
                doitAjusterCurseur := false;
                
                SetPortByWindow(wCourbePtr);
                
                GetMouse(mouseLoc);
                tirecurseur := PtInRect(mouseLoc,sourisRect);
                
                
                bouge := (mouseLoc.h <> mouseX) & 
                         (((mouseLoc.h >= sliderRect.left ) & (mouseLoc.h <= sliderRect.right)) |
                          ((mouseLoc.h <= sliderRect.left ) & (mouseX >= sliderRect.left)) |
                          ((mouseLoc.h >= sliderRect.right) & (mouseX <= sliderRect.right)));
                
                if bouge & tireCurseur then 
                  begin
                    numeroDuCoupDemande := PositionSourisEnNumeroDeCoupSurSlider(mouseLoc.h - (LargeurCourbe() div 120));
                    
                    if (numeroDuCoupDemande < 0) then numeroDuCoupDemande := 0;
                    if (numeroDuCoupDemande > nroDernierCoupAtteint) then numeroDuCoupDemande := nroDernierCoupAtteint;
                    
                    if (numeroDuCoupDemande <> nbreCoup) & 
                       (numeroDuCoupDemande >= 0) & 
                       (numeroDuCoupDemande <= nroDernierCoupAtteint) then
                     begin
                       
                       if (numeroDuCoupDemande < nbreCoup) & (numeroDuCoupDemande >= 0) then
                         begin
                           if (GetNiemeCoupPartieCourante(numeroDuCoupDemande+1) > 0) & PeutArreterAnalyseRetrograde() then 
                             begin
                               if (numeroDuCoupDemande = nbreCoup - 1) then DoBackMove else
                               if (numeroDuCoupDemande = nbreCoup - 2) then DoDoubleBackMove else
                                 DoRetourAuCoupNro(numeroDuCoupDemande,not(enRetourArrivee),true);
                             end;
                         end;
                         
                       if (numeroDuCoupDemande > nbreCoup) & (numeroDuCoupDemande <= 60) then
                         begin
                           if (GetNiemeCoupPartieCourante(numeroDuCoupDemande) > 0) & PeutArreterAnalyseRetrograde() then 
                             begin
                               if (numeroDuCoupDemande = nbreCoup + 1) then DoAvanceMove else
                               if (numeroDuCoupDemande = nbreCoup + 2) then DoDoubleAvanceMove else
                                 DoAvanceAuCoupNro(numeroDuCoupDemande,not(enRetourArrivee));
                             end;
                         end;
                       
                       EcritCommentaireCourbe(numeroDuCoupDemande);
                     end;
                  end;
                    
                ShareTimeWithOtherProcesses(2);
                mouseX := mouseLoc.h;
              end;
          end;
        
        doitAjusterCurseur := true;
        AjusteCurseur;
        SetPort(oldPort);
      end;
      
end; 

{ TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe doit renvoyer true si elle change le curseur }
function TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe(mouseGlobalLoc : Point) : boolean;
var numeroPointe : SInt32;
    oldPort : grafPtr;
    mouseLoc : Point;
begin
  TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe := false;
  
  if windowCourbeOpen then
    with gCourbeData do
      begin
        GetPort(oldPort);
        SetPortByWindow(wCourbePtr);
        
        mouseLoc := mouseGlobalLoc;
        
        GlobalToLocal(mouseLoc);
        
        if PtInRect(mouseLoc,zoneGriseRect) 
          then
            begin
              {InitCursor;}
              if (mouseLoc.h <> lastMouseLocUtilisee.h) then
                begin
                  lastMouseLocUtilisee := mouseLoc;
                  numeroPointe := PositionSourisEnNumeroDeCoupSurCourbe(mouseLoc.h - (LargeurCourbe() div 120));
                  
                  if (numeroPointe <= 1) then numeroPointe := 1;
                  if (numeroPointe >= nroDernierCoupAtteint) then numeroPointe := nroDernierCoupAtteint;
                  
                  if numeroPointe <> dernierCommentaireAffiche then
                    begin
                      dernierCommentaireAffiche := numeroPointe;
                      EcritCommentaireCourbe(numeroPointe);
                    end;
                end;
              {TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe := true;}
              exit(TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe);
            end;
            
        if PtInRect(mouseLoc,zoneSensibleSlider) & EstUnClicSurSliderCourbe(mouseLoc) & (nroDernierCoupAtteint > 0) & not(enSetUp)
          then
            begin
              InitCursor;
              TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe := true;
            end;
        
        SetPort(oldPort);
      end;
end;


procedure TraiteSourisCourbe(evt : eventRecord);
var mouseLoc : Point;
    oldport : grafPtr;
    numeroCoup : SInt32;
begin
  if windowCourbeOpen then
    with gCourbeData do
      begin
        GetPort(oldport);
        SetPortByWindow(wCourbePtr);
        
        mouseLoc := evt.where;
        GlobalToLocal(mouseLoc);
            
        if PtInRect(mouseLoc,zoneGriseRect) 
          then
            begin
              numeroCoup := PositionSourisEnNumeroDeCoupSurCourbe(mouseLoc.h);
              if EstUnDoubleClic(theEvent,false) then 
                begin
                  if numeroCoup < nbreCoup 
                    then 
                      begin
                        if (GetNiemeCoupPartieCourante(numeroCoup+1) > 0) & PeutArreterAnalyseRetrograde() then 
                          DoRetourAuCoupNro(numeroCoup,true,not(CassioEstEnModeAnalyse()));
                      end
                    else
                  if numeroCoup > nbreCoup
                    then
                      begin
                        if (GetNiemeCoupPartieCourante(numeroCoup+1) > 0) & PeutArreterAnalyseRetrograde() then 
                          DoAvanceAuCoupNro(numeroCoup,true);
                      end;
                end;
            end
          else
           if PtInRect(mouseLoc,zoneSensibleSlider) then
             begin
               if EstUnClicSurSliderCourbe(mouseLoc) & not(enSetUp) then TraiteClicSurSliderCourbe(mouseLoc);
             end;
          
          
        SetPort(oldport);
      end; 
end;

procedure EffaceCommentaireCourbe;
var oldPort : grafPtr;
begin
  if windowCourbeOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wCourbePtr);
      EraseRect(gCourbeData.commentaireRect);
      SetPort(oldPort);
    end;
end;

procedure EcritCommentaireCourbe(nroCoup : SInt32);
var s,s1,coupEnChaine : str255;
    note : SInt32;
    nbDeChiffres : SInt32;
    origineNote:typeGenreDeReflexion;
    noteEnReel : extended;
    x,largeurString,largeurCoup : SInt32;
    oldPort : grafPtr;
begin
  
  gCourbeData.dernierTickCommentaire := TickCount();
  
  if windowCourbeOpen & DoitEcrireCommentaireCourbe() then 
  with gCourbeData do
    begin
      GetPort(oldport);
      SetPortByWindow(wCourbePtr);
      
      EraseRect(commentaireRect);
      
      if (nroCoup >= 1) & (nroCoup <= nroDernierCoupAtteint) & (GetNiemeCoupPartieCourante(nroCoup) > 0) then
        begin
          dernierCommentaireAffiche := nroCoup;
          
          coupEnChaine := NumEnString(nroCoup)+'.'+CoupEnString(GetNiemeCoupPartieCourante(nroCoup),CassioUtiliseDesMajuscules);
          
          
          if EvaluationPourCourbeProvientDeLaFinale(nroCoup) 
            then
              begin
                origineNote := GetOrigineEvaluationDansCourbe(nroCoup);
                note := GetEvaluationPourNoirDansCourbe(nroCoup) div kCoeffMultiplicateurPourCourbeEnFinale;
                
                s := '';
                if note = 0 
                  then s := s + '  ' + ReadStringFromRessource(TextesRetrogradeID,20)  {'  fait nulle'}
                  else
                    case origineNote of
                      kFinaleParfaite :
                        begin
                          s1 := '  ' + ReadStringFromRessource(TextesRetrogradeID,21);  {'  fait ^0}
                          s1 := ParamStr(s1,NumEnString(32 + note div 2)+'-'+NumEnString(32 - note div 2),'','','');
                          s := s + {' :' +} s1;
                        end;
                      kFinaleWLD :
                        if (note > 0) then s := s + {' : '} '  ' + ReadStringFromRessource(TextesRetrogradeID,25)  {'  Noir est gagnant'}
                                      else s := s + {' : '} '  ' + ReadStringFromRessource(TextesRetrogradeID,26); {'  Blanc est gagnant'}
                                      
        
                    end; {case}
              end
            else
              begin
                note := (GetEvaluationPourNoirDansCourbe(nroCoup - 1) + GetEvaluationPourNoirDansCourbe(nroCoup)) div 2;
                noteEnReel := 1.0*note/kCoeffMultiplicateurPourCourbeEnFinale;
                
                if Abs(noteEnReel) >= 10.0
                  then nbDeChiffres := 4
                  else nbDeChiffres := 3;
                  
                s := ' : ';
                if (noteEnReel > 0.0) 
                  then s := s + 'N+'+ReelEnStringAvecDecimales( noteEnReel,nbDeChiffres)
                  else s := s + 'B+'+ReelEnStringAvecDecimales(-noteEnReel,nbDeChiffres);
              end;
          
          TextFont(gCassioApplicationFont);
          TextSize(gCassioSmallFontSize);
          TextFace(normal);
          largeurCoup := StringWidth(coupEnChaine) - 5 ;
          largeurString := StringWidth(coupEnChaine + s) ;
          
          x := NroDeCoupEnPositionSurCourbe(nroCoup) - largeurCoup;
          if (x > zoneGriseRect.right - largeurString) then x := zoneGriseRect.right - largeurString;
          if (x < zoneGriseRect.left) then x := zoneGriseRect.left;
          
          Moveto(x,commentaireRect.bottom - 4);
          TextFace(bold);
          DrawString(coupEnChaine);
          TextFace(normal);
          DrawString(s);
        end;
      
      SetPort(oldPort);
    end;
end;

procedure SetDoitEcrireCommentaireCourbe(flag : boolean);
begin
  gCourbeData.ecrireCommentaire := flag;
end;


function DoitEcrireCommentaireCourbe() : boolean;
begin
  DoitEcrireCommentaireCourbe := gCourbeData.ecrireCommentaire;
end;


END.

































