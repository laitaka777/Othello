UNIT UnitBaseNouveauFormat;

INTERFACE







USES UnitOth0,UnitDefinitionsNouveauFormat,UnitDefinitionsPackedThorGame;


const kFinDuMondeOthellistique=3971;
      kDebutDuMondeOthellistique=1971;
      kChangementDeSiecleOthellistique=71;

procedure DessineOthellierLecture(whichWindow : WindowRef);
procedure DessineOthellierLectureHistorique(whichWindow : WindowRef);
procedure AffichePositionLecture(Position : plateauOthello;whichWindow : WindowRef);
procedure AfficheHistoriqueLecture(position : plateauOthello;whichWindow : WindowRef);
procedure EcritMessageLectureBase(s : str255;posH,posV : SInt16);
procedure InitialisePlateauLecture(whichWindow : WindowRef);
procedure JoueOuverturePlateauLecture(ligne : PackedThorGame;whichWindow : WindowRef);
procedure DejoueUnCoupPlateauLecture(whichWindow : WindowRef);
procedure DejoueNCoupsPlateauLecture(coup : SInt16; whichWindow : WindowRef);
function ClicDansOthellierLecture(mouseLoc : Point;whichWindow : WindowRef) : boolean;
procedure ClicDansHistoriqueLecture(mouseLoc : Point;whichWindow : WindowRef);
function FiltreRechercheDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
function FiltreLectureDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
function AnneeIsCompatible(anneeDeLaPartie,anneeDeRecherche,testInegalite : SInt16) : boolean;
procedure DoLectureJoueursEtTournoi(nomsCourts : boolean);
function StringEnAnneeSansBugAn2000(s : string) : SInt32;

function ActionBaseDeDonnee(actionDemandee : SInt16; var partieEnChaine : str255) : boolean;




{gestion d'un menu flottant des bases}
type menuFlottantBasesRec = record
                              theMenuID : SInt16; 
                              menuFlottantBases : MenuRef;
                              menuBasesRect : rect;
                              itemCourantMenuBases : SInt16; 
                              nbreItemsAvantListeDesBases : SInt16; 
                              tableLiaisonEntreMenuBasesEtNumerosDistrib : array[0..nbMaxDistributions] of SInt16;
                            end;
     filtreDistributionProc = function(numeroDistribution : SInt16) : boolean;
                            
procedure InstalleMenuFlottantBases(var popUpBases : menuFlottantBasesRec;whichMenuID : SInt16; filtre:filtreDistributionProc);
procedure DesinstalleMenuFlottantBases(var popUpBases : menuFlottantBasesRec);
function NroDistribToItemNumber(popUpBases : menuFlottantBasesRec;nroDistribCherchee : SInt32) : SInt32;
function ItemNumberToNroDistrib(popUpBases : menuFlottantBasesRec;itemNumberCherche : SInt32) : SInt32;


IMPLEMENTATION    







USES UnitStrategie,UnitActions,UnitCriteres,UnitRapportImplementation,UnitCarbonisation,
     UnitUtilitaires,UnitProgressBar,UnitAccesStructuresNouvFormat,UnitDiagramFforum,
     UnitTriListe,UnitListe,UnitNouveauFormat,UnitMacExtras,UnitCalculCouleurCassio,
     UnitOth1,UnitInterversions,UnitJaponais,UnitOth2,UnitMenus,UnitRapport,MyStrings,
     UnitDialog,UnitScannerOthellistique,SNStrings,UnitNormalisation,UnitCouleur,UnitJeu,
     UnitFenetres,UnitPackedThorGame;



const kYpositionMessageBase = 189;
      kYpositionNbPartiesDansBase = 202;
      kYpositionNbPartiesPotentiellementLues = 213;


function StringEnAnneeSansBugAn2000(s : string) : SInt32;
var result : SInt32;
begin
  s := SeulementLesChiffres(s);
  if s=''
    then
      result := -1
    else
      begin
        if length(s)=4 
          then
            begin
              StringToNum(s,result);
              if result<kDebutDuMondeOthellistique then result := -1;
              if result>kFinDuMondeOthellistique then result := -1;
            end
          else
        if length(s)=2 
          then
            begin
              StringToNum(s,result);
              if (result<>19) & (result<>20) then
                begin
                  if (0<=result) & (result<kChangementDeSiecleOthellistique) then result := 2000+result;
                  if (kChangementDeSiecleOthellistique<=result) & (result<=99) then result := 1900+result;
                end;
            end
          else
            begin
			        StringToNum(s,result);
			      end;
  end;
  
  StringEnAnneeSansBugAn2000 := result;
end;


function CouleurDesPetitsOthelliers() : RGBColor;
var couleurDesCases : RGBColor;
    textureInconnue : boolean;
begin


  if gCouleurOthellier.estUneTexture
    then 
      begin
        couleurDesCases := PlusProcheCouleurRGBOfTexture(gCouleurOthellier,textureInconnue);
        couleurDesCases := EclaircirCouleurDeCetteQuantite(couleurDesCases,5000);
        
        if textureInconnue | RGBColorEstFoncee(couleurDesCases,10000) 
          then couleurDesCases := EclaircirCouleurDeCetteQuantite(couleurDesCases,40000);
        
      end
    else 
      begin
        couleurDesCases := gCouleurOthellier.RGB;
        couleurDesCases := EclaircirCouleurDeCetteQuantite(couleurDesCases,5000);
        
        if RGBColorEstFoncee(couleurDesCases,20000)
          then couleurDesCases := EclaircirCouleurDeCetteQuantite(couleurDesCases,40000);
      end;
  
  CouleurDesPetitsOthelliers := couleurDesCases;
end;


procedure EffaceCasePetitOthellier(whichRect : rect);
var couleurDesCases : RGBColor;
begin
  couleurDesCases := CouleurDesPetitsOthelliers();
  RGBForeColor(couleurDesCases);
  RGBBackColor(couleurDesCases);
  FillRect(whichRect,blackPattern);
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
end;


procedure DessineOthellierLecture(whichWindow : WindowRef);
const a=235;
      b=184;
var i : SInt16; 
begin
  SetPortByWindow(whichWindow);
  PenSize(1,1);
  RGBForeColor(NoircirCouleurDeCetteQuantite(CouleurDesPetitsOthelliers(),25000));
  SetRect(OthellierLectureRect,a,b,a+8*taillecaselecture,b+8*taillecaselecture);
  for i := 0 to 8 do
    begin
      Moveto(a,b+i*taillecaselecture);
      Lineto(a+8*taillecaselecture,b+i*taillecaselecture);
      Moveto(a+i*taillecaselecture,b);
      Lineto(a+i*taillecaselecture,b+8*taillecaselecture);
    end;
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
end;

procedure DessineOthellierLectureHistorique(whichWindow : WindowRef);
var a,b,i : SInt16; 
begin
  SetPortByWindow(whichWindow);
  PenSize(1,1);
  RGBForeColor(NoircirCouleurDeCetteQuantite(CouleurDesPetitsOthelliers(),25000));
  a := OthellierLectureRect.left+9*taillecaselecture;
  b := OthellierLectureRect.top;
  for i := 0 to 8 do
    begin
      Moveto(a,b+i*taillecaselecture);
      Lineto(a+8*taillecaselecture,b+i*taillecaselecture);
      Moveto(a+i*taillecaselecture,b);
      Lineto(a+i*taillecaselecture,b+8*taillecaselecture);
    end;
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
end;


procedure AffichePositionLecture(Position : plateauOthello;whichWindow : WindowRef);
var i,j : SInt16; 
    unRect : rect;
    x,y : SInt16; 
    oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(whichWindow);
  PenSize(1,1);
  x := OthellierLectureRect.left;
  y := OthellierLectureRect.top;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                       x+i*taillecaselecture,y+j*taillecaselecture);
                       
        EffaceCasePetitOthellier(unRect);
        
        case position[j*10+i] of
          pionVide: {EraseRect(unRect)};
          pionNoir: FillOval(unRect,blackPattern);
          pionBlanc: begin
                      FrameOval(unRect);
                      InsetRect(unRect,1,1);
                      EraseOval(unRect);
                     end;
        end;
      end;
  SetPort(oldPort);
end;

procedure AfficheHistoriqueLecture(position : plateauOthello;whichWindow : WindowRef);
var i,j,t,coup : SInt16; 
    unRect : rect;
    x,y,larg : SInt16; 
    s : str255;
    oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(whichWindow);
 
  if SetAntiAliasedTextEnabled(false,9) = NoErr then;
  DisableQuartzAntiAliasingThisPort(GetWindowPort(whichWindow));
  
  PenSize(1,1);
  x := OthellierLectureRect.left+9*taillecaselecture;
  y := OthellierLectureRect.top;
  MemoryFillChar(@position,sizeof(position),chr(0));
  position[45] := pionNoir;position[54] := pionNoir;
  position[44] := pionBlanc;position[55] := pionBlanc;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                       x+i*taillecaselecture,y+j*taillecaselecture);
                       
                       
        EffaceCasePetitOthellier(unRect);           
                       
        case position[j*10+i] of
          pionVide: {EraseRect(unRect)};
          pionNoir: FillOval(unRect,blackPattern);
          pionBlanc: begin
                      FrameOval(unRect);
                      InsetRect(unRect,1,1);
                      EraseOval(unRect);
                     end;
        end;
      end;
  TextSize(9);
  TextFont(MonacoID);
  for t := 1 to GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture) do
    begin
      coup := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, t, 'AfficheHistoriqueLecture');
      i := coup mod 10;
      j := coup div 10;
      SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                       x+i*taillecaselecture,y+j*taillecaselecture);
      NumToString(t,s);
      larg := StringWidth(s);
      if (t>=10) & (t<=19)
        then Moveto((unRect.left+unRect.right-larg) div 2,unRect.bottom-4)
        else Moveto((unRect.left+unRect.right-larg) div 2+1,unRect.bottom-4);
      DrawString(s);
    end;
   TextSize(0);
   TextFont(systemFont);
   
   if gCassioUseQuartzAntialiasing then
	   begin
			 if SetAntiAliasedTextEnabled(true,9) = NoErr then;
			 EnableQuartzAntiAliasingThisPort(GetWindowPort(whichWindow),true);
		end;
  SetPort(oldPort);
end;

procedure EcritMessageLectureBase(s : str255;posH,posV : SInt16);
var rectEffacement : rect;
begin
  TextFont(gCassioApplicationFont);
  TextSize(gCassioSmallFontSize);
  SetRect(rectEffacement,10,posV-9,OthellierLectureRect.left,posV+3);
  EraseRect(rectEffacement);
  Moveto(posH,posV);
  DrawString(s);
  TextSize(0);
  TextFont(systemFont);
end;


procedure VerifiePositionLectureModifiee(var positionLectureModifiee : boolean);
var i,coup : SInt16; 
    concordance : boolean;
begin
  if positionLectureModifiee then
    if not(positionfeerique) then
      if GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture)=nbreCoup then
        begin
          concordance := true;
          for i := 1 to GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture) do
            begin
              coup := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, i, 'VerifiePositionLectureModifiee');
              concordance := concordance & (coup=GetNiemeCoupPartieCourante(i));
            end;
          positionLectureModifiee := not(concordance);
          {if not(positionLectureModifiee) then SysBeep(0);}
        end;
end;


procedure InitialisePlateauLecture(whichWindow : WindowRef);
var i,coup : SInt16; 
begin
  positionLectureModifiee := false;
  DessineOthellierLecture(whichWindow);
  DessineOthellierLectureHistorique(whichWindow);
  if positionfeerique | gameOver
    then 
      begin
        OthellierDeDepart(PlatLecture);
        positionLectureModifiee := true;
      end
    else PlatLecture := jeuCourant;
  AffichePositionLecture(PlatLecture,whichWindow);
  FILL_PACKED_GAME_WITH_ZEROS(ChainePartieLecture);
  if not(positionLectureModifiee) then
  for i := 1 to nbreCoup do
    begin
      coup := GetNiemeCoupPartieCourante(i);
      if (coup >= 11) & (coup <= 88) then
        ADD_MOVE_TO_PACKED_GAME(ChainePartieLecture, coup);
    end;
  AfficheHistoriqueLecture(PlatLecture,whichWindow);
end;

procedure JoueOuverturePlateauLecture(ligne : PackedThorGame;whichWindow : WindowRef);
var k,x,longueur,trait : SInt16; 
    test : boolean;
    nbla,nnoi : SInt32;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(ligne);
  OthellierEtPionsDeDepart(platlecture,nBla,nNoi);
  if longueur>=1 then
    begin
     trait := pionNoir;
     test := true;
     k := 0;
     repeat
       k := k+1;
       x := GET_NTH_MOVE_OF_PACKED_GAME(ligne, k, 'JoueOuverturePlateauLecture');
       if platlecture[x] = pionVide then 
       begin
         test := ModifPlatFin(x,trait,platlecture,nBla,nNoi);
         if test 
           then
             trait := -trait
           else 
             test := ModifPlatFin(x,-trait,platlecture,nBla,nNoi);
       end
       else test := false;
     until (k>=longueur) | not(test);
    end;
    ChainePartieLecture := ligne;
    AffichePositionLecture(PlatLecture,whichWindow);
    AfficheHistoriqueLecture(PlatLecture,whichWindow);
    positionLectureModifiee := true;
    VerifiePositionLectureModifiee(positionLectureModifiee);
end;



procedure DejoueUnCoupPlateauLecture(whichWindow : WindowRef);
var i,j,k,x,y,longueur,trait : SInt16; 
    test : boolean;
    nbla,nnoi : SInt32;
    unRect : rect;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture);
  OthellierEtPionsDeDepart(platlecture,nBla,nNoi);
  if longueur>1 then
    begin
     trait := pionNoir;
     test := true;
     k := 0;
     repeat
       k := k+1;
       x := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, k, 'DejoueUnCoupPlateauLecture(1)');
       if platlecture[x] = pionVide then 
       begin
         test := ModifPlatFin(x,trait,platlecture,nBla,nNoi);
         if test 
           then
             trait := -trait
           else 
             test := ModifPlatFin(x,-trait,platlecture,nBla,nNoi);
       end
       else test := false;
     until (k>=longueur-1) | not(test);
    end;
  AffichePositionLecture(PlatLecture,whichWindow);
  if longueur>=1 then
    begin
      x := OthellierLectureRect.left+9*taillecaselecture;
      y := OthellierLectureRect.top;
      i := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, longueur, 'DejoueUnCoupPlateauLecture(1)') mod 10;
      j := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, longueur, 'DejoueUnCoupPlateauLecture(1)') div 10;
      SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                           x+i*taillecaselecture,y+j*taillecaselecture);
      EffaceCasePetitOthellier(unRect);
      {EraseRect(unRect);}
    end;
  if (longueur > 1)
    then DESTROY_LAST_MOVE_OF_PACKED_GAME(ChainePartieLecture)
    else FILL_PACKED_GAME_WITH_ZEROS(ChainePartieLecture);
  positionLectureModifiee := true;
  VerifiePositionLectureModifiee(positionLectureModifiee);
  itemmenuouverture := 1;
  DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
end;

procedure DejoueNCoupsPlateauLecture(coup : SInt16; whichWindow : WindowRef);
var i,j,k,t,x,y,longueur,trait : SInt16; 
    test : boolean;
    nbla,nnoi : SInt32;
    unRect : rect;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture);
  if (coup-1<longueur) & (coup>=1) then
    begin
      longueur := coup;
      OthellierEtPionsDeDepart(platlecture,nBla,nNoi);
      if longueur>1 then
        begin
         trait := pionNoir;
         test := true;
         k := 0;
         repeat
           k := k+1;
           x := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, k, 'DejoueNCoupsPlateauLecture(1)');
           if platlecture[x] = pionVide then 
           begin
             test := ModifPlatFin(x,trait,platlecture,nBla,nNoi);
             if test 
               then
                 trait := -trait
               else 
                 test := ModifPlatFin(x,-trait,platlecture,nBla,nNoi);
           end
           else test := false;
         until (k>=longueur-1) | not(test);
        end;
      AffichePositionLecture(PlatLecture,whichWindow);
      if longueur>=1 then
        for t := longueur to GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture) do
        begin
          x := OthellierLectureRect.left+9*taillecaselecture;
          y := OthellierLectureRect.top;
          i := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, t, 'DejoueNCoupsPlateauLecture(2)') mod 10;
          j := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, t, 'DejoueNCoupsPlateauLecture(3)') div 10;
          SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                               x+i*taillecaselecture,y+j*taillecaselecture);
          EffaceCasePetitOthellier(unRect);
          {EraseRect(unRect);}
        end;
      if (longueur > 1)
        then DESTROY_LAST_MOVE_OF_PACKED_GAME(ChainePartieLecture)
        else FILL_PACKED_GAME_WITH_ZEROS(ChainePartieLecture);
      positionLectureModifiee := true;
      VerifiePositionLectureModifiee(positionLectureModifiee);
   end;
  itemmenuouverture := 1;
  DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
end;

function ClicDansOthellierLecture(mouseLoc : Point;whichWindow : WindowRef) : boolean;
var a,b,xcourant,xtest : SInt16; 
    nbBlanc,nbNoir : SInt32;
    couleurtrait,t,jeudet : SInt16; 
    trouve : boolean;
    x,y,larg : SInt16; 
    unRect : rect;
    s : str255;
begin   
  TextSize(9);
  TextFont(MonacoID);
  x := OthellierLectureRect.left+9*taillecaselecture;
  y := OthellierLectureRect.top;
  a := (mouseLoc.h-OthellierLectureRect.left) div taillecaselecture +1;
  b := (mouseLoc.v-OthellierLectureRect.top) div taillecaselecture +1;
  xcourant := a+10*b;
  nbBlanc := 0;nbnoir := 0;
  for t := 1 to 64 do
    begin
      jeudet := PlatLecture[othellier[t]];
      if jeudet = pionBlanc then nbBlanc := nbBlanc+1;
      if jeudet = pionNoir then nbnoir := nbNoir+1;
    end;
  if odd(nbBlanc+nbnoir) 
    then couleurtrait := pionBlanc
    else couleurtrait := pionNoir;
  if platlecture[xcourant] = pionVide then
    if PeutJouerIci(couleurtrait,xcourant,PlatLecture) 
     then
      begin
        ClicDansOthellierLecture := ModifPlatFin(xcourant,couleurtrait,PlatLecture,nbBlanc,nbnoir);
        ADD_MOVE_TO_PACKED_GAME(ChainePartieLecture, xcourant);
        AffichePositionLecture(PlatLecture,whichWindow);
        SetRect(unRect,x+1+(a-1)*taillecaselecture,y+1+(b-1)*taillecaselecture,
               x+a*taillecaselecture,y+b*taillecaselecture);
        NumToString(nbBlanc+nbNoir-4,s);
        larg := StringWidth(s);
        if (nbBlanc+nbNoir-4>=10) & (nbBlanc+nbNoir-4<=19)
          then Moveto((unRect.left+unRect.right-larg) div 2,unRect.bottom-4)
          else Moveto((unRect.left+unRect.right-larg) div 2+1,unRect.bottom-4);
        DrawString(s);
        positionLectureModifiee := true;
        VerifiePositionLectureModifiee(positionLectureModifiee);
        itemmenuouverture := 1;
        DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
      end
     else
      begin
        trouve := false;
        t := 0;
        repeat
          t := t+1;
          xtest := othellier[t];
          if PlatLecture[xtest] = pionVide then
            trouve := PeutJouerIci(couleurtrait,xtest,PlatLecture) 
        until trouve | (t >= 64);
        if not(trouve) then 
          if PeutJouerIci(-couleurtrait,xcourant,PlatLecture) 
            then
              begin
                ClicDansOthellierLecture := ModifPlatFin(xcourant,-couleurtrait,PlatLecture,nbBlanc,nbnoir);
                ADD_MOVE_TO_PACKED_GAME(ChainePartieLecture, xcourant);
                AffichePositionLecture(PlatLecture,whichWindow);
                SetRect(unRect,x+1+(a-1)*taillecaselecture,y+1+(b-1)*taillecaselecture,
                               x+a*taillecaselecture,y+b*taillecaselecture);
                NumToString(nbBlanc+nbNoir-4,s);
                larg := StringWidth(s);
                if (nbBlanc+nbNoir-4>=10) & (nbBlanc+nbNoir-4<=19)
                  then Moveto((unRect.left+unRect.right-larg) div 2,unRect.bottom-4)
                  else Moveto((unRect.left+unRect.right-larg) div 2+1,unRect.bottom-4);
                DrawString(s);
                positionLectureModifiee := true;
                VerifiePositionLectureModifiee(positionLectureModifiee);
                itemmenuouverture := 1;
                DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
              end;
      end;
    TextSize(0);
    TextFont(systemFont);
end;

procedure ClicDansHistoriqueLecture(mouseLoc : Point;whichWindow : WindowRef);
var a,b,xcourant : SInt16; 
    trouve,bidbool : boolean;
    x,y,t,longueur : SInt16; 
begin   
  x := OthellierLectureRect.left+9*taillecaselecture;
  y := OthellierLectureRect.top;
  a := (mouseLoc.h-x) div taillecaselecture +1;
  b := (mouseLoc.v-y) div taillecaselecture +1;
  xcourant := a+10*b;
  trouve := false;
  longueur := GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture);
  if platlecture[xcourant] <> pionVide 
   then
     begin
      for t := 1 to longueur do
        if (GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, t, 'ClicDansHistoriqueLecture(1)')=xcourant) & not(trouve)
          then
            begin
              trouve := true;
              DejoueNCoupsPlateauLecture(t,whichWindow);
            end;
     end
   else
     begin
       mouseLoc.h := mouseLoc.h-9*taillecaselecture;
       bidbool := ClicDansOthellierLecture(mouseLoc,whichWindow);
     end;
end;


function FiltreRechercheDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
const JoueurNoirText=6;
      JoueurBlancText=7;
var ch : char;
    s1,s2 : str255;
begin
  FiltreRechercheDialog := false;
  if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(evt);
  if not(EvenementDuDialogue(dlog,evt)) 
    then FiltreRechercheDialog := MyFiltreClassique(dlog,evt,item)
    else
      case evt.what of
        keyDown,autoKey :
          begin
            if (BAND(evt.message,charcodemask)=EntreeKey) then {entrОe}
              begin
                item := 4;
                FlashItem(dlog,item);
                FiltreRechercheDialog := true;
                exit(FiltreRechercheDialog);
              end;
            if (BAND(evt.modifiers,cmdKey) <> 0) then
              begin
                ch := chr(BAND(evt.message,charCodemask));
                if (ch='Є') | (ch='┘') then  {pomme-option-y}
                  begin
                    GetItemTextInDialog(dlog,JoueurNoirText,s1);
                    GetItemTextInDialog(dlog,JoueurBlancText,s2);
                    SetItemTextInDialog(dlog,JoueurNoirText,s2);
                    SetItemTextInDialog(dlog,JoueurBlancText,s1);
                    SelectDialogItemText(dlog,JoueurNoirText,0,MaxInt);
                    FiltreRechercheDialog := true;
                    exit(FiltreRechercheDialog);
                  end;
                FiltreRechercheDialog := MyFiltreClassique(dlog,evt,item);
              end;
            FiltreRechercheDialog := MyFiltreClassique(dlog,evt,item);
          end;    {keyDown,autoKey}
        updateEvt:
          begin
            item := VirtualUpdateItemInDialog;
            FiltreRechercheDialog := true;
          end;
            otherwise FiltreRechercheDialog := MyFiltreClassique(dlog,evt,item);
        end;   {case}
end;




function FiltreLectureDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
const     LectureBouton=1;
          AnnulerBouton=2;
          JoueurNoirText=6;
          JoueurBlancText=7;
          CoupPrecedentBouton=10;
          OuvertureStaticText=17;
          GenreTestTextLectureBase=18;
          OuvertureUserItemPopUp=19;
var mouseLoc : Point;
    unRect : rect;
    a,b : SInt32;
    s1,s2 : str255;
    ch : char;
    oldPort : grafPtr;
begin
  FiltreLectureDialog := false;
  if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(evt);
  if not(EvenementDuDialogue(dlog,evt)) 
    then FiltreLectureDialog := MyFiltreClassique(dlog,evt,item)
    else
      case evt.what of
       mouseDown:
          begin
            IncrementeCompteurDeMouseEvents;
            GetPort(oldPort);
            SetPortByDialog(dlog);
            mouseLoc := evt.where;
            GlobalToLocal(mouseLoc);
            if PtInRect(mouseLoc,OthellierLectureRect) 
             then
               begin
                 FiltreLectureDialog := ClicDansOthellierLecture(mouseLoc,GetDialogWindow(dlog));
                 item := 0;
               end
             else
               begin
                 a := OthellierLectureRect.left+9*taillecaselecture;
                 b := OthellierLectureRect.top;
                 SetRect(unRect,a,b,a+8*taillecaselecture,b+8*taillecaselecture);
                 if PtInRect(mouseLoc,unRect) 
                   then
                     begin
                       ClicDansHistoriqueLecture(mouseLoc,GetDialogWindow(dlog));
                       FiltreLectureDialog := true;
                       item := 0;
                     end
                   else
                     FiltreLectureDialog := MyFiltreClassique(dlog,evt,item);
               end;
             SetPort(oldPort);
           end;
        keyDown,autoKey :
         if (BAND(evt.modifiers,cmdKey) <> 0)
           then
             begin
               ch := chr(BAND(evt.message,charCodemask));
               if (ch='z') | (ch='Z') then     {pomme-z}
                 begin
                   item := CoupPrecedentBouton;
                   FiltreLectureDialog := true;
                   exit(FiltreLectureDialog);
                 end;
               if (ch='и') | (ch='█') | (ch='n') | (ch='N') then  {pomme-n}
                 begin
                   DejoueNCoupsPlateauLecture(1,GetDialogWindow(dlog));
                   item := 0;
                   FiltreLectureDialog := true;
                   exit(FiltreLectureDialog);
                 end;
               if (ch='Є') | (ch='┘') then  {pomme-option-y}
                 begin
                   GetItemTextInDialog(dlog,JoueurNoirText,s1);
                   GetItemTextInDialog(dlog,JoueurBlancText,s2);
                   SetItemTextInDialog(dlog,JoueurNoirText,s2);
                   SetItemTextInDialog(dlog,JoueurBlancText,s1);
                   SelectDialogItemText(dlog,JoueurNoirText,0,MaxInt);
                   FiltreLectureDialog := true;
                   exit(FiltreLectureDialog);
                 end;
             FiltreLectureDialog := MyFiltreClassique(dlog,evt,item);
             end
         else FiltreLectureDialog := MyFiltreClassique(dlog,evt,item);
      updateEvt : 
        begin
          item := VirtualUpdateItemInDialog;
          FiltreLectureDialog := true;
        end;
      otherwise FiltreLectureDialog := MyFiltreClassique(dlog,evt,item)
    end;   {case}
end;


function AnneeIsCompatible(anneeDeLaPartie,anneeDeRecherche,testInegalite : SInt16) : boolean;
begin
  AnneeIsCompatible := true;
  if (anneeDeRecherche>=1970) & (anneeDeRecherche<=kFinDuMondeOthellistique) then
	  case testInegalite of
	    testEgalite  :        AnneeIsCompatible := (anneeDeLaPartie=anneeDeRecherche);
	    testSuperieur:        AnneeIsCompatible := (anneeDeLaPartie>=anneeDeRecherche);
	    testInferieur:        AnneeIsCompatible := (anneeDeLaPartie<=anneeDeRecherche);
	    testSuperieurStrict : AnneeIsCompatible := (anneeDeLaPartie>anneeDeRecherche);
	    testInferieurStrict : AnneeIsCompatible := (anneeDeLaPartie<anneeDeRecherche);
	  end;
end;



{$S Base2}



procedure InstalleMenuFlottantBases(var popUpBases : menuFlottantBasesRec;whichMenuID : SInt16; filtre:filtreDistributionProc);
var nroDistrib,k,compteur : SInt16; 
    s : str255;
begin
  with popUpBases do
    begin
      MenuFlottantBases := MyGetMenu(whichMenuID);
      theMenuID := whichMenuID;
		  EnleveEspacesDeDroiteItemsMenu(popUpBases.MenuFlottantBases);
		  InsertMenu(MenuFlottantBases,-1);
		  
		  nbreItemsAvantListeDesBases := MyCountMenuItems(MenuFlottantBases);
		  
		  {
		  WritelnDansRapport('');
		  WritelnStringAndNumDansRapport('nb distributions du nouveau format=',DistributionsNouveauFormat.nbDistributions);
		  for k := 1 to DistributionsNouveauFormat.nbDistributions do
		    begin
		      WritelnDansRapport('path = '+DistributionsNouveauFormat.Distribution[k].path^);
		      WritelnDansRapport('nom = '+DistributionsNouveauFormat.Distribution[k].name^);
		      WritelnDansRapport('nomUsuel = '+DistributionsNouveauFormat.Distribution[k].nomUsuel^);
		      WritelnDansRapport('type = '+NumEnString(GetTypeDonneesDistribution(k)));
		      WritelnDansRapport('    =>    '+NumEnString(NbTotalPartiesDansDistributionSet([k]))+' parties');
		      
		    end;
		  WritelnDansRapport('');
		  }
		  
		  for k := 0 to nbMaxDistributions do
		    tableLiaisonEntreMenuBasesEtNumerosDistrib[k] := -1;
		    
		  
		  compteur := nbreItemsAvantListeDesBases;
		  for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
		    if filtre(nroDistrib) then
			    begin
			      s := DistributionsNouveauFormat.Distribution[nroDistrib].nomUsuel^;
			      {s := s+' ('+NumEnString(NbTotalPartiesDansDistributionSet([nroDistrib]))+')';}
			      s := Concat(' ',s);
			      s := EnleveEspacesDeDroite(s);
			      InsertMenuItem(MenuFlottantBases,s,1000);
			      
			      inc(compteur);
			      tableLiaisonEntreMenuBasesEtNumerosDistrib[compteur] := nroDistrib;
			    end;
		  for k := 1 to MyCountMenuItems(MenuFlottantBases) do
		    MyEnableItem(MenuFlottantBases,k);
		end;
end;

procedure DesinstalleMenuFlottantBases(var popUpBases : menuFlottantBasesRec);
var k : SInt32;
begin
  with popUpBases do
    begin
      DeleteMenu(theMenuID);
      TerminateMenu(popUpBases.MenuFlottantBases,true);
      for k := 0 to nbMaxDistributions do
        tableLiaisonEntreMenuBasesEtNumerosDistrib[k] := -1;
    end;
end;


function NroDistribToItemNumber(popUpBases : menuFlottantBasesRec;nroDistribCherchee : SInt32) : SInt32;
var k : SInt32;
begin
  with popUpBases do 
    begin
      if (nroDistribCherchee >= 1) & (nroDistribCherchee <= DistributionsNouveauFormat.nbDistributions) then
	       for k := 0 to nbMaxDistributions do
	          if (tableLiaisonEntreMenuBasesEtNumerosDistrib[k] = nroDistribCherchee) then
	            begin
	              NroDistribToItemNumber := k;
	              exit(NroDistribToItemNumber);
	            end;
	  end;
	NroDistribToItemNumber := 0;
end;

function ItemNumberToNroDistrib(popUpBases : menuFlottantBasesRec;itemNumberCherche : SInt32) : SInt32;
begin
  with popUpBases do
    if (itemNumberCherche > nbreItemsAvantListeDesBases) & (itemNumberCherche <= MyCountMenuItems(MenuFlottantBases)) &
       (itemNumberCherche >= 0) & (itemNumberCherche <= nbMaxDistributions) 
      then ItemNumberToNroDistrib := tableLiaisonEntreMenuBasesEtNumerosDistrib[itemNumberCherche]
      else ItemNumberToNroDistrib := 0;
end;


function ActionBaseDeDonnee(actionDemandee : SInt16; var partieEnChaine : str255) : boolean;
const 
    OuvrirThorID=136;
    LectureBaseID=140;
    menuFlottantBasesID=3004;
const
    RechercherBouton=1;
    PrecedenteBouton=3;
    Ouvrir=4;
    Annuler=2;
    ScoreNoirText=5;
    JoueurNoirText=6;
    JoueurBlancText=7;
    TournoiText=8;
    AnneeText=9;
    nroText=10;
    LectureBouton=1;
    LectureAntichronologiqueBox=3;
    BasesStaticText=4;
    CoupPrecedentBouton=10;
    OuvertureStaticText=17;
    GenreTestTextLectureBase=18;
    OuvertureUserItemPopUp=19;
    
    BasesUserItemPopUp=20;
    
    ToutesLesBasesCmd = 1;
    CertainesBasesCmd = 2;
    AucuneBaseCmd = 3;
    
    partieImpossible=-537;
    
var dp : DialogPtr;
    itemHit : SInt16; 
    codeErreur : OSErr;

var s,s1 : str255;
    aux : SInt32;
    ScoreNoirRecherche,anneeRecherche : SInt32;
    numeroPartieMin,numeroPartieMax : SInt32;
    JoueurNoirRecherche,JoueurBlancRecherche,TournoiRecherche : str255;
    TournoiCompatible:t_TournoiCompatible;
    JoueurNoirCompatible,JoueurBlancCompatible:t_JoueurCompatible;
    ScoreCompatible:t_ScoreCompatible;
    OuvertureCompatible:{packed} array[0..255] of boolean;
    NoirsCompatibleParIndex:{packed} array[0..255] of boolean;
    BlancsCompatibleParIndex:{packed} array[0..255] of boolean;
    TournoisCompatibleParIndex:{packed} array[0..255] of boolean;
    passeLeFiltreDesIndex : boolean;
    partieBuff:t_PartieRecNouveauFormat;
    tousParametresvides : boolean;
    auMoinsUnePartieDansBuffer : boolean;
    DejaAuMoinsUneRecherche : boolean;
    DernierFichierAffiche : SInt16; 
    dernierePartieAffichee : SInt32;
    NbPartiesPotentiellementLues : SInt32;
    ChaineNoir,ChaineBlanc,ChaineScoreNoir : str255;
    ChaineTournoi,ChaineAnnee,ChaineNroPart : str255;
    ChaineGenreTest : str255;
    itemPourLeTest : SInt16; 
    interversionlecturebase : boolean;
    annulationPendantLecture : boolean;
    result : boolean;
    myEvent : eventRecord;
    
    popUpBases : menuFlottantBasesRec;
    
    

    
procedure CalculeNbTotalPartiesDansDistributionsALire;
begin
  with ChoixDistributions do
    NbTotalPartiesDansDistributionsALire := NbTotalPartiesDansDistributionSet(distributionsALire);
end;

procedure CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee : SInt16);
var somme : SInt32;
    numFichier : SInt16; 
    anneeFichier : SInt16; 
begin
  somme := 0;
  for numFichier := 1 to InfosFichiersNouveauFormat.nbFichiers do
    if (InfosFichiersNouveauFormat.fichiers[numFichier].typeDonnees=kFicPartiesNouveauFormat) &
       (InfosFichiersNouveauFormat.fichiers[numFichier].nroDistribution in ChoixDistributions.distributionsALire) then
       begin
         anneeFichier := AnneePartiesFichierNouveauFormat(numFichier);
         if (AnneeIsCompatible(anneeFichier,anneeRecherche,genreDeTestPourAnnee)) then
           somme := somme+NbPartiesFichierNouveauFormat(numFichier);
       end;
  NbPartiesPotentiellementLues := somme;
end;

procedure EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee : SInt16);
var s : str255;
    anneeRechercheArrivee : SInt16; 
begin
  anneeRechercheArrivee := anneeRecherche;
  CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
  if {(NbPartiesPotentiellementLues=ChoixDistributions.NbTotalPartiesDansDistributionsALire) |}
     (anneeRechercheArrivee<0) | (anneeRecherche>kFinDuMondeOthellistique) | (anneeRecherche<kDebutDuMondeOthellistique) |
     ((NbPartiesPotentiellementLues=0) & ((anneeRechercheArrivee=19)|(anneeRechercheArrivee<10)))
    then 
      begin
         EcritMessageLectureBase('                            ',25,kYpositionNbPartiesPotentiellementLues);
      end
    else
      begin
			  NumToString(NbPartiesPotentiellementLues,s);
			  case genreDeTestPourAnnee of
			    testEgalite  :        EcritMessageLectureBase(ParamStr(ReadStringFromRessource(TextesBaseID,13),s,NumEnString(anneeRecherche),'',''),25,kYpositionNbPartiesPotentiellementLues);
				  testSuperieur:        EcritMessageLectureBase(ParamStr(ReadStringFromRessource(TextesBaseID,14),s,NumEnString(anneeRecherche-1),'',''),25,kYpositionNbPartiesPotentiellementLues);
				  testInferieur:        EcritMessageLectureBase(ParamStr(ReadStringFromRessource(TextesBaseID,15),s,NumEnString(anneeRecherche+1),'',''),25,kYpositionNbPartiesPotentiellementLues);
				  testSuperieurStrict : EcritMessageLectureBase(ParamStr(ReadStringFromRessource(TextesBaseID,14),s,NumEnString(anneeRecherche),'',''),25,kYpositionNbPartiesPotentiellementLues);
				  testInferieurStrict : EcritMessageLectureBase(ParamStr(ReadStringFromRessource(TextesBaseID,15),s,NumEnString(anneeRecherche),'',''),25,kYpositionNbPartiesPotentiellementLues);
				end;
		  end;
end;
    
procedure EcritNbPartiesBase;
var s : str255;
begin      
  CalculeNbTotalPartiesDansDistributionsALire;
  NumToString(ChoixDistributions.NbTotalPartiesDansDistributionsALire,s);
  EcritMessageLectureBase(ParamStr(ReadStringFromRessource(TextesBaseID,1),s,'','',''),20,kYpositionNbPartiesDansBase);
end;

procedure RedessineDialogue(dp : DialogPtr);
begin
  SetPortByDialog(dp);
  MyDrawDialog(dp);
  OutlineOK(dp);
  DessineOthellierLecture(GetDialogWindow(dp));
  DessineOthellierLectureHistorique(GetDialogWindow(dp));
  AffichePositionLecture(PlatLecture,GetDialogWindow(dp));
  AfficheHistoriqueLecture(PlatLecture,GetDialogWindow(dp));
  EcritNbPartiesBase;
  EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
end;

procedure InstalleMenuFlottantOuverture;
begin
  EnleveEspacesDeDroiteItemsMenu(OuvertureMenu);
  InsertMenu(OuvertureMenu,-1);
end;


procedure DesinstalleMenuFlottantOuverture;
begin
  DeleteMenu(OuvertureID);
end;



function MenuItemToOuverture(item : SInt16; var ligneOuverture : PackedThorGame) : boolean;
var s : str255;
    octetdebut,octetfin,j : SInt32;
    whichSquare,indexTableOuv : SInt16; 
begin
  MenuItemToOuverture := false;
  FILL_PACKED_GAME_WITH_ZEROS(ligneOuverture);
  if (item > 2) & (bibliothequeIndex <> NIL) & (bibliothequeEnTas <> NIL) then
    begin
      GetMenuItemText(OuvertureMenu,item,s);
      s := EnleveEspacesDeDroite(s);
      if EstDansTableOuverture(s,indexTableOuv) then
        begin
          MenuItemToOuverture := true;
          ADD_MOVE_TO_PACKED_GAME(ligneOuverture, 56);  { coup 1 en F5 }
          OctetDebut := bibliothequeIndex^^[indexTableOuv-1]+1;
          OctetFin := bibliothequeIndex^^[indexTableOuv];
          for j := OctetDebut to OctetFin do
            begin
              whichSquare := bibliothequeEnTas^^[j];
              if (whichSquare >= 11) & (whichSquare <= 88) then
                ADD_MOVE_TO_PACKED_GAME(ligneOuverture, whichSquare);
            end;
        end;
    end;
end;



procedure CheckItemMarksOnMenuBases(var item : SInt16);
var nroDistrib : SInt16; 
    compteur : SInt32;
begin
  with popUpBases do
    begin
		  if ChoixDistributions.genre=kToutesLesDistributions then
		    begin
		      ChoixDistributions.distributionsALire := [];
		      for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
		        if EstUneDistributionDeParties(nroDistrib) then
		          ChoixDistributions.distributionsALire := ChoixDistributions.distributionsALire+[nroDistrib];
		    end;
		  if ChoixDistributions.genre=kAucuneDistribution
		    then SetItemMark(MenuFlottantBases,AucuneBaseCmd,chr(checkMark))
		    else SetItemMark(MenuFlottantBases,AucuneBaseCmd,chr(noMark));
		  if ChoixDistributions.genre=kToutesLesDistributions
		    then SetItemMark(MenuFlottantBases,ToutesLesBasesCmd,chr(checkMark))
		    else SetItemMark(MenuFlottantBases,ToutesLesBasesCmd,chr(noMark));
		  if ChoixDistributions.genre=kQuelquesDistributions
		    then SetItemMark(MenuFlottantBases,CertainesBasesCmd,chr(checkMark))
		    else SetItemMark(MenuFlottantBases,CertainesBasesCmd,chr(noMark));
		    
		  compteur := 0;
		  for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
		    if EstUneDistributionDeParties(nroDistrib) then
			    if nroDistrib in ChoixDistributions.distributionsALire
			      then 
			        begin
			          inc(compteur);
			          SetItemMark(MenuFlottantBases,NroDistribToItemNumber(popUpBases,nroDistrib),chr(diamondMark))
			        end
			      else 
			        SetItemMark(MenuFlottantBases,NroDistribToItemNumber(popUpBases,nroDistrib),chr(noMark));
			
			if (compteur = 1) then
			  for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
		      if EstUneDistributionDeParties(nroDistrib) then
			      if nroDistrib in ChoixDistributions.distributionsALire then
			        item := NroDistribToItemNumber(popUpBases,nroDistrib);
	end;
end;


function MenuItemToBases(var item : SInt16) : boolean;
var nroDistrib : SInt16; 
    nbDistributionsDansEnsemble : SInt16; 
    distributionsAccessiblesSet:DistributionSet;
begin
  MenuItemToBases := true;
  
  distributionsAccessiblesSet := [];
  for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
    if EstUneDistributionDeParties(nroDistrib) then
      distributionsAccessiblesSet := distributionsAccessiblesSet+[nroDistrib];
  
  if item=ToutesLesBasesCmd then
    begin
      ChoixDistributions.genre := kToutesLesDistributions;
      ChoixDistributions.distributionsALire := distributionsAccessiblesSet;
     end;
  if item=AucuneBaseCmd then
    begin
      ChoixDistributions.genre := kAucuneDistribution;
      ChoixDistributions.distributionsALire := [];
    end;
  if item=CertainesBasesCmd then
    begin
      ChoixDistributions.genre := kQuelquesDistributions;
    end;
  if item > popUpBases.nbreItemsAvantListeDesBases then
    begin
      ChoixDistributions.genre := kQuelquesDistributions;
      
      nbDistributionsDansEnsemble := 0;
      for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
        begin
          if EstUneDistributionDeParties(nroDistrib) then
            if nroDistrib in ChoixDistributions.distributionsALire then inc(nbDistributionsDansEnsemble);
        end;
      
      nroDistrib := ItemNumberToNroDistrib(popUpBases,item);
      if (nroDistrib in ChoixDistributions.distributionsALire) & (nbDistributionsDansEnsemble >= 2)
        then ChoixDistributions.distributionsALire := (ChoixDistributions.distributionsALire - [nroDistrib])
        else ChoixDistributions.distributionsALire := (ChoixDistributions.distributionsALire + [nroDistrib]);
        
      nbDistributionsDansEnsemble := 0;
      for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
        begin
          if EstUneDistributionDeParties(nroDistrib) then
            if nroDistrib in ChoixDistributions.distributionsALire then inc(nbDistributionsDansEnsemble);
        end;
        
      if (nbDistributionsDansEnsemble > 1)
        then item := CertainesBasesCmd;
      if nbDistributionsDansEnsemble = 0 then 
        begin
          ChoixDistributions.genre := kAucuneDistribution;
          item := AucuneBaseCmd;
        end;
      if (ChoixDistributions.distributionsALire = distributionsAccessiblesSet) & 
         (nbDistributionsDansEnsemble > 1) then 
        begin
          ChoixDistributions.genre := kToutesLesDistributions;
          item := ToutesLesBasesCmd;
        end;
    end;
  CheckItemMarksOnMenuBases(item);
  CalculeNbTotalPartiesDansDistributionsALire;
end;

procedure GetMenuOuvertureItemAndRect;
begin
  GetDialogItemRect(dp,OuvertureUserItemPopUp,menuouverturerect);
  itemMenuOuverture := 1;
end;

procedure GetMenuBasesItemAndRect;
begin
  with popUpBases do
    begin
		  GetDialogItemRect(dp,BasesUserItemPopUp,menuBasesRect);
		  itemCourantMenuBases := ToutesLesBasesCmd;
		  if ChoixDistributions.genre=kAucuneDistribution then itemCourantMenuBases := AucuneBaseCmd else
		  if ChoixDistributions.genre=kQuelquesDistributions then itemCourantMenuBases := CertainesBasesCmd;
		end;
end;

procedure LitPartieNro(numFichierDeParties : SInt16; numeroPartie : SInt32;enAvancant : boolean);
var codeErreur : OSErr;
begin
  codeErreur := LitPartieNouveauFormat(numFichierDeParties,numeroPartie,enAvancant,partieBuff);
  with partieBuff,DistributionsNouveauFormat.distribution[InfosFichiersNouveauFormat.fichiers[numFichierDeParties].nroDistribution] do
    begin
      nroTournoi := nroTournoi+decalageNrosTournois;
		  nroJoueurNoir := nroJoueurNoir+decalageNrosJoueurs;
		  nroJoueurBlanc := nroJoueurBlanc+decalageNrosJoueurs;
    end;
end;



procedure ChercheNumerosJoueursCompatibles(nomNoir,nomBlanc : str255);
var traiteNoir,traiteBlanc : boolean;
begin
  traiteNoir := nomNoir<>'';
  traiteBlanc := nomBlanc<>'';
  if traiteNoir | traiteBlanc then
    begin
      if traiteNoir then RemplitTableCompatibleJoueurAvecCeBooleen(JoueurNoirCompatible,false);
      if traiteBlanc then RemplitTableCompatibleJoueurAvecCeBooleen(JoueurBlancCompatible,false);
      if traiteNoir then CalculeTableJoueursCompatibles(nomNoir,JoueurNoirCompatible,0);
      if traiteBlanc then CalculeTableJoueursCompatibles(nomBlanc,JoueurBlancCompatible,0);
    end;
end;   


procedure ChercheOuverturesCompatibles(var ouvertureEnCours : PackedThorGame);
var longueur,i,t : SInt16; 
    UnPacked7:packed7;
    minimum,maximum : byte;
    uneStr33:str33;
begin
  for i := 1 to 255 do 
    OuvertureCompatible[i] := false;
  OuvertureCompatible[0] := true;

  longueur := GET_LENGTH_OF_PACKED_GAME(ouvertureEnCours);
  if longueur>nbOctetsOuvertures then longueur := nbOctetsOuvertures;
  for t := 1 to longueur do 
    UnPacked7[t] := GET_NTH_MOVE_OF_PACKED_GAME(ouvertureEnCours,t, 'ChercheOuverturesCompatibles(1)');
  DetermineIntervaleOuverture(UnPacked7,longueur,minimum,maximum);
  for t := minimum to maximum do
    OuvertureCompatible[t] := true;
    
  if (NbinterversionsCompatibles>0) then
    for i := 1 to NbinterversionsCompatibles do
      begin
        uneStr33 := interversionFautive^^[interversionsCompatibles[i]];
        longueur := Length(uneStr33);
        if longueur>nbOctetsOuvertures then longueur := nbOctetsOuvertures;
        for t := 1 to longueur do UnPacked7[t] := ord(uneStr33[t]);
        DetermineIntervaleOuverture(UnPacked7,longueur,minimum,maximum);
        for t := minimum to maximum do
          OuvertureCompatible[t] := true;
      end;
end;




procedure ChargeIndexFichierCourant(numFichierCourant : SInt16);
var nroFichierIndex : SInt16; 
    err : OSErr;
begin
  with InfosFichiersNouveauFormat do
    if fichiers[numFichierCourant].typeDonnees=kFicPartiesNouveauFormat then
      begin
        nroFichierIndex := fichiers[numFichierCourant].NroFichierDual;
        if nroFichierIndex <> 0
          then  {le fichier d'index existe deja sur le disque : on le lit}
            begin
              err := LitFichierIndexNouveauFormat(nroFichierIndex);
            end
          else  {le fichier d'index est introuvable : on le fabrique}
            begin
              err := IndexerFichierPartiesEnMemoireNouveauFormat(numFichierCourant);
              err := EcritFichierIndexNouveauFormat(numFichierCourant);
            end;
      end;
end;

procedure ChercheJoueursCompatiblesPourIndex(numFichierCourant : SInt16);
var i : SInt32;
begin
  if (indexNouveauFormat.tailleIndex=NbPartiesFichierNouveauFormat(numFichierCourant))
    then
      begin
        for i := 0 to 255 do
          NoirsCompatibleParIndex[i] := false;
        for i := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
          if JoueurNoirCompatible^[i] then
            NoirsCompatibleParIndex[BAND(i,255)] := true;
      end
    else
      for i := 0 to 255 do
        NoirsCompatibleParIndex[i] := true;
   
  if (indexNouveauFormat.tailleIndex=NbPartiesFichierNouveauFormat(numFichierCourant))
    then 
      begin
        for i := 0 to 255 do
          BlancsCompatibleParIndex[i] := false;
        for i := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
          if JoueurBlancCompatible^[i] then
            BlancsCompatibleParIndex[BAND(i,255)] := true;
      end
    else
      for i := 0 to 255 do
        BlancsCompatibleParIndex[i] := true;
      
end;

procedure ChercheTournoisCompatiblesPourIndex(numFichierCourant : SInt16);
var i : SInt32;
begin
  if (indexNouveauFormat.tailleIndex=NbPartiesFichierNouveauFormat(numFichierCourant))
    then
      begin
        for i := 0 to 255 do
          TournoisCompatibleParIndex[i] := false;
          
        for i := 0 to TournoisNouveauFormat.nbTournoisNouveauFormat-1 do
          if TournoiCompatible^[i] then
              TournoisCompatibleParIndex[BAND(i,255)] := true;
              
      end
    else
       for i := 0 to 255 do
          TournoisCompatibleParIndex[i] := true;
end;

procedure ChercheOuverturesCompatiblesPourIndex(numFichierCourant : SInt16; ouverture : PackedThorGame);
var i : SInt32;
begin
  OuvertureCompatible[0] := true;
  if (indexNouveauFormat.tailleIndex=NbPartiesFichierNouveauFormat(numFichierCourant))
    then ChercheOuverturesCompatibles(ouverture)
    else 
      for i := 0 to 255 do
        OuvertureCompatible[i] := true;
end;



procedure ChercheNumerosTournoisCompatibles(nom : str255);
var i : SInt32;
    c : char;
    nomTournoi : str255;
begin
  if Length(nom)>0 then
    begin
      RemplitTableCompatibleTournoiAvecCeBooleen(TournoiCompatible,false);
      if JoueursEtTournoisEnMemoire
        then
          nomTournoi := nom
        else
          begin
            nomtournoi := '';
            for i := 1 to Length(nom) do
              begin
                c := nom[i];
                if c='О' then c := 'В';
                if c='П' then c := 'К';
                if (c>='A') & (c<='Z') then c := chr(ord(c)+32);
                nomtournoi := nomtournoi+c;
              end;
          end;
      CalculeTableTournoisCompatibles(nomTournoi,TournoiCompatible,0);
   end;
end;   





 {  teste si la partie du buffer est la meme que ouverture   }
function MemesCoupsPartie(ouverture : PackedThorGame) : boolean;
var i,longueur : SInt16; 
    test : boolean;
begin
  test := true;
  longueur := GET_LENGTH_OF_PACKED_GAME(ouverture);
  i := longueur+1;
  with Partiebuff do
  repeat
    i := i-1;
    test := GET_NTH_MOVE_OF_PACKED_GAME(ouverture,i, 'MemesCoupsPartie(1)') = listeCoups[i];
  until not(test) | (i<=1);
  MemesCoupsPartie := test;
end;


procedure AffichePartie(numeroFichier,anneePartie : SInt16; numeroPartie : SInt32);
var nomjoueur:str19;
    nomtournoi:str30;
    chaine : str255;
    unRect : rect;
    i : SInt16; 
begin
   chaine := '';
   nomJoueur := GetNomJoueur(Partiebuff.nroJoueurNoir);
   nomJoueur := DeleteSpacesBefore(nomJoueur,Length(nomJoueur));
   {while nomjoueur[Length(nomjoueur)]=' ' do Delete(nomjoueur,Length(nomjoueur),1);}
   chaine := chaine+nomjoueur;
   NumToString(Partiebuff.scoreReel,s);
   chaine := chaine+StringOf(' ')+s+'  ';
   nomJoueur := GetNomJoueur(Partiebuff.nroJoueurBlanc);
   nomJoueur := DeleteSpacesBefore(nomJoueur,Length(nomJoueur));
   {while nomjoueur[Length(nomjoueur)]=' ' do Delete(nomjoueur,Length(nomjoueur),1);}
   chaine := chaine+nomjoueur;
   NumToString(64-Partiebuff.scoreReel,s);
   chaine := chaine+StringOf(' ')+s+'   ';
   
   nomTournoi := GetNomTournoi(Partiebuff.nroTournoi);
   TraduitNomTournoiEnMac(nomtournoi,nomtournoi);
   for i := 1 to Length(nomtournoi) do
     chaine := chaine+nomtournoi[i];
   chaine := chaine+' '+NumEnString(anneePartie);
   SetPortByDialog(dp);
   TextSize(gCassioSmallFontSize);
   TextFont(gCassioApplicationFont);
   SetRect(unRect,0,148,500,172);
   EraseRect(unRect);
   NumToString(numeroPartie,s);
   chaine := chaine+'        '+ParamStr(ReadStringFromRessource(TextesBaseID,2),s,'','','');  {Partie nб ^0}
   WriteStringAt(chaine,10,168);
   TextSize(0);
   TextFont(systemFont);
   DernierFichierAffiche := numeroFichier;
   dernierePartieAffichee := numeroPartie;
   dernierePartieExtraiteWThor.numFichier := numeroFichier;
   dernierePartieExtraiteWThor.numPartie := numeroPartie;
end;

procedure TraductionPartie(var s : str255);
var i,coup : SInt16; 
    premierCoupPartie : SInt16; 
    autreCoupQuatreDansPartie : boolean;
begin
  ExtraitPremierCoup(premierCoupPartie,autreCoupQuatreDansPartie);
  s := '';
  for i := 1 to 60 do
    begin
      coup := Partiebuff.listeCoups[i];
      if coup>0 then 
        begin
          TransposeCoupPourOrientation(coup,autreCoupQuatreDansPartie);
          s := Concat(s,CoupEnStringEnMajuscules(coup));
        end;
    end;
end;

procedure TraductionPremiersCoups(var s:str120;nbCoup : SInt16);
var i,coup : SInt16; 
begin
  s := '';
  for i := 1 to nbCoup do
    begin
      coup := Partiebuff.listeCoups[i];
      if coup>0 then s := Concat(s,CoupEnStringEnMajuscules(coup));
    end;
end;


procedure EcritParametresDuDialogueDansRapport(fonctionAppelante : str255);
begin
  WritelnDansRapport(fonctionAppelante);
  WritelnDansRapport('   tournoi = '+ChaineTournoi);
  WritelnDansRapport('   joueur blanc = '+ChaineBlanc);
  WritelnDansRapport('   joueur noir = '+ChaineNoir);
end;

procedure SauveToutAvantAnnuler(tientCompteDeNro : boolean);
var NewNoir,NewBlanc,NewScoreNoir : str255;
    NewTournoi,NewAnnee,NewGenreTest : str255;
begin
  ChaineNroPart := '';
  if tientCompteDeNro 
    then GetItemTextInDialog(dp,NroText,ChaineNroPart);
  if (ChaineNroPart='') | not(tientCompteDeNro) then
    begin
      GetItemTextInDialog(dp,ScoreNoirText,NewScoreNoir);
      GetItemTextInDialog(dp,AnneeText,NewAnnee);
      GetItemTextInDialog(dp,JoueurNoirText,NewNoir);
      GetItemTextInDialog(dp,JoueurBlancText,NewBlanc);
      GetItemTextInDialog(dp,tournoiText,NewTournoi);
      itemPourLeTest := GenreTestTextLectureBase;
      GetItemTextInDialog(dp,itemPourLeTest,NewGenreTest);
        
      ChaineTournoi := NewTournoi;
      ChaineBlanc := NewBlanc;
      ChaineNoir := NewNoir;
      ChaineAnnee := NewAnnee;
      ChaineScoreNoir := NewScoreNoir;
      ChaineGenreTest := NewGenreTest;
    end;

end;



procedure SetNumerosDePartieMinEtMaxPourCeFichier(numeroFichier : SInt16; var numeroPartieMin,numeroPartieMax : SInt32);
begin
  numeroPartieMin := 1;
  numeroPartieMax := NbPartiesFichierNouveauFormat(numeroFichier);
end;




procedure ChargePartie(nroChargement : SInt32;nroDistribution,anneePartie : SInt16);
begin
  
  if (nroChargement>=1) & (nroChargement <= PartiesNouveauFormat.nbPartiesEnMemoire) then
    begin
     SetPartieActive(nroChargement,true);
     SetAnneePartieParNroRefPartie(nroChargement,anneePartie);
     SetPartieRecordParNroRefPartie(nroChargement,partieBuff);
     SetNroDistributionParNroRefPartie(nroChargement,nroDistribution);
     
     {
     partie60 := '';
     for k := 1 to 60 do
       partie60 := partie60+chr(partieBuff.listeCoups[k]);
     MetPartieDansTableStockageParties(nroChargement,partie60);
     SetNroJoueurNoirParNroRefPartie(nroChargement,partieBuff.nroJoueurNoir);
     SetNroJoueurBlancParNroRefPartie(nroChargement,partieBuff.nroJoueurBlanc);
     SetNroTournoiParNroRefPartie(nroChargement,partieBuff.nroTournoi);
     SetScoreReelParNroRefPartie(nroChargement,partieBuff.scoreReel);
     SetScoreTheoriqueParNroRefPartie(nroChargement,partieBuff.scoreTheorique);
     }
     
   end;
  
end;




procedure OuvrePartieNro(numeroFichier : SInt16; numeroPartieDansFichier : SInt32;enAvancant : boolean);
var titre : str255;
    sNoir,sBlanc : str255;
begin
  LitPartieNro(numeroFichier,numeroPartieDansFichier,enAvancant);
  TraductionPartie(partieEnChaine);
  sNoir := GetNomJoueurSansPrenom(Partiebuff.nroJoueurNoir);
  sBlanc := GetNomJoueurSansPrenom(Partiebuff.nroJoueurBlanc);
  ConstruitTitrePartie(sNoir,sBlanc,true,Partiebuff.scoreReel,titre);
  titrePartie^^ := titre;
  ParamDiagCourant.titreFFORUM^^ := titre;
  ParamDiagCourant.commentPositionFFORUM^^ := '';
	ParamDiagPositionFFORUM.titreFFORUM^^ := titre;
	ParamDiagPositionFFORUM.commentPositionFFORUM^^ := '';
  ParamDiagPartieFFORUM.titreFFORUM^^ := titre;
  ParamDiagPartieFFORUM.commentPositionFFORUM^^ := '';
end;

procedure MetAnciensParametres;
var s : str255;
begin
  s := ParametresOuvrirThor^^[1];
  if s<>'Gogol' then SetItemTextInDialog(dp,TournoiText,s);
  s := ParametresOuvrirThor^^[2];
  if s<>'Gogol' then SetItemTextInDialog(dp,JoueurBlancText,s);
  s := ParametresOuvrirThor^^[3];
  if s<>'Gogol' then SetItemTextInDialog(dp,JoueurNoirText,s);
  s := ParametresOuvrirThor^^[4];
  if s<>'Gogol' then SetItemTextInDialog(dp,AnneeText,s);
	anneeRecherche := StringEnAnneeSansBugAn2000(s);
  s := ParametresOuvrirThor^^[5];
  if s<>'Gogol' then SetItemTextInDialog(dp,ScoreNoirText,s);
  ChaineTournoi := ParametresOuvrirThor^^[1];
  ChaineBlanc := ParametresOuvrirThor^^[2];
  ChaineNoir := ParametresOuvrirThor^^[3];
  ChaineAnnee := ParametresOuvrirThor^^[4];
  ChaineScoreNoir := ParametresOuvrirThor^^[5];
  case ParametreGenreTestThor of
    testEgalite  :        ChaineGenreTest := '=';
    testSuperieur:        ChaineGenreTest := '>=';
    testInferieur:        ChaineGenreTest := '<=';
    testSuperieurStrict : ChaineGenreTest := '>';
    testInferieurStrict : ChaineGenreTest := '<';
  end;
end;

procedure DeplaceAnneeDuTournoi;
var s,s1 : str255;
    i : SInt16; 
begin
  GetItemTextInDialog(dp,TournoiText,s);
  if s<>'' then
    begin  
      i := Length(s);
      if i>=5 then
        if IsDigit(s[i]) & 
           IsDigit(s[i-1]) & 
           IsDigit(s[i-2]) & 
           IsDigit(s[i-3]) &
           (s[i-4]=' ')  then
             begin
               s1 := TPCopy(s,i-3,4);
               s := TPCopy(s,1,i-5);
               s := EnleveEspacesDeDroite(s);
               SetItemTextInDialog(dp,TournoiText,s);
               SetItemTextInDialog(dp,AnneeText,s1);
               anneeRecherche := StringEnAnneeSansBugAn2000(s1);
               SetItemTextInDialog(dp,GenreTestTextLectureBase,'');
               genreDeTestPourAnnee := testEgalite;
               exit(DeplaceAnneeDuTournoi);
             end;
      if i>=3 then
        if IsDigit(s[i]) & 
           IsDigit(s[i-1]) & 
           (s[i-2]=' ')  then
             begin
               s1 := TPCopy(s,i-1,2);
               if ChaineEnLongint(s1)>kChangementDeSiecleOthellistique
                 then s1 := '19'+s1
                 else s1 := '20'+s1;
               s := TPCopy(s,1,i-3);
               s := EnleveEspacesDeDroite(s);
               SetItemTextInDialog(dp,TournoiText,s);
               SetItemTextInDialog(dp,AnneeText,s1);
               anneeRecherche := StringEnAnneeSansBugAn2000(s1);
               SetItemTextInDialog(dp,GenreTestTextLectureBase,'');
               genreDeTestPourAnnee := testEgalite;
               exit(DeplaceAnneeDuTournoi);
             end;
    end;
end;

procedure MetParametresSpeciauxLecture;
var s : str255;
begin
  case genreDeTestPourAnnee of
    testEgalite  :        s := '=';
    testSuperieur:        s := '>=';
    testInferieur:        s := '<=';
    testSuperieurStrict : s := '>';
    testInferieurStrict : s := '<';
  end;
  if s<>'' then SetItemTextInDialog(dp,GenreTestTextLectureBase,s);
end;


procedure SauveAnciensParametres;
begin
  ParametresOuvrirThor^^[1] := ChaineTournoi;
  ParametresOuvrirThor^^[2] := ChaineBlanc;
  ParametresOuvrirThor^^[3] := ChaineNoir;
  ParametresOuvrirThor^^[4] := ChaineAnnee;
  ParametresOuvrirThor^^[5] := ChaineScoreNoir;
  ParametreGenreTestThor := genreDeTestPourAnnee;
end;

procedure VideNroPartieText;
begin
  SetItemTextInDialog(dp,NroText,'');
end;

procedure VideTousParametres;
begin
  SetItemTextInDialog(dp,TournoiText,'');
  SetItemTextInDialog(dp,JoueurBlancText,'');
  SetItemTextInDialog(dp,JoueurNoirText,'');
  SetItemTextInDialog(dp,AnneeText,'');
  anneeRecherche := StringEnAnneeSansBugAn2000('');
  SetItemTextInDialog(dp,ScoreNoirText,'');
  tousParametresvides := true;
end;

procedure RemetTousParametres;
begin
  s := ChaineTournoi;
  if s<>'Gogol' then SetItemTextInDialog(dp,TournoiText,s);
  s := ChaineBlanc;
  if s<>'Gogol' then SetItemTextInDialog(dp,JoueurBlancText,s);
  s := ChaineNoir;
  if s<>'Gogol' then SetItemTextInDialog(dp,JoueurNoirText,s);
  s := ChaineAnnee;
  if s<>'Gogol' then SetItemTextInDialog(dp,AnneeText,s);
  anneeRecherche := StringEnAnneeSansBugAn2000(s);
  s := ChaineScoreNoir;
  if s<>'Gogol' then SetItemTextInDialog(dp,ScoreNoirText,s);
  tousParametresvides := false;
end;

{partie faisant un bug apres chargement de la liste : 
   F5D6C3D3C4F4F6G5E3F3G6E2G3G4H5E6F2H6H4 
   F5F6E6F4E3D3C3D6F7C5F3C4C6}


procedure ChargerLaBase;
var NewNoir,NewBlanc,NewScoreNoir : str255;
    NewTournoi,NewAnnee,NewGenreTest,s : str255;
    
    limiteCompteur,dernierCompteurAffiche,larg : SInt32;
    CompteurPartiesExaminees : SInt32;
    compatibiliteTournoi : boolean;
    compatibiliteJoueurs,ANDentreJoueurs : boolean;
    nbChargees,intervalleLecture,pourcentage : SInt32;
    
    dernierPourcentagePourTestSouris : SInt32;
    pourcentageRect : rect;
    pourcentageCouleurRGB : RGBColor;
    intervallePourcentage : SInt32;
    ouvertureactive60 : PackedThorGame;
    ouvertureactive120:str120;
    ouvertureActive255 : str255;
    partie60 : PackedThorGame;
   {TestTigre:str33; }  { utile pour l'optimisation de l'interversion F5D6C3D3C4=F5D6C4D3C3 }
    autreCoupDiag : boolean;
    i,longueurOuverture : SInt32;
    longueurPlus1,nbreCoupsRestant : byte;
    tickchrono : SInt32;
    doitTraiterInterversions : boolean;
    annulerRect,lignerect : rect;
    mouseLoc : Point;
    enAvancant,depassementLimite : boolean;
    numeroFichierCourant : SInt16; 
    anneeFichierCourant : SInt16; 
    nroDistributionFichierCourant : SInt16; 
    compteurPartieDansFichierCourant : SInt32;
    incrementCompteurPartie : SInt32;
    codeErreur : OSErr;
label try_again;

function TesteAnnulationPendantLecture() : boolean;
var myEvent : eventRecord;
    oldPort : grafPtr;
begin
  TesteAnnulationPendantLecture := false;
  if HasGotEvent(mDownMask+KeyDownMask+AutoKeyMask,myEvent,0,NIL)
    then
      begin
        if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(myEvent);
	      case myEvent.what of
	        mouseDown:
	          begin
	            IncrementeCompteurDeMouseEvents;
	            GetPort(oldPort);
	            mouseLoc := myEvent.where;
	            SetPortByDialog(dp);
	            GlobalToLocal(mouseLoc);
	            TesteAnnulationPendantLecture := PtInRect(mouseLoc,annulerrect);
	            SetPort(oldPort);
	          end;
	        keyDown,autoKey:
	          TesteAnnulationPendantLecture := (BAND(myEvent.message,charcodemask)=EscapeKey);
	      end; {case}
      end;
end;


begin  {ChargerLaBase}
  enAvancant := not(LectureAntichronologique);

  FlushEvents(everyEvent,0);
  annulationPendantLecture := false;
  GetDialogItemRect(dp,Annuler,annulerRect);
  
  GetItemTextInDialog(dp,ScoreNoirText,NewScoreNoir);
  GetItemTextInDialog(dp,AnneeText,NewAnnee);
  GetItemTextInDialog(dp,JoueurNoirText,NewNoir);
  GetItemTextInDialog(dp,JoueurBlancText,NewBlanc);
  GetItemTextInDialog(dp,tournoiText,NewTournoi);
  anneeRecherche := StringEnAnneeSansBugAn2000(NewAnnee);
  ANDentreJoueurs := not(NewNoir=NewBlanc);
  itemPourLeTest := GenreTestTextLectureBase;
  GetItemTextInDialog(dp,itemPourLeTest,NewGenreTest);

  ChaineTournoi := NewTournoi;
  ChaineBlanc := NewBlanc;
  ChaineNoir := NewNoir;
  ChaineAnnee := NewAnnee;
  ChaineScoreNoir := NewScoreNoir;
  ChaineGenreTest := NewGenreTest;
                        
  FILL_PACKED_GAME_WITH_ZEROS(ouvertureactive60);          
  ouvertureactive120 := '';
  avecInterversions := interversionlecturebase;
  if GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture) > 0 then
    begin
      ouvertureactive60 := ChainePartieLecture;
      TraductionThorEnAlphanumerique(ouvertureactive60,ouvertureactive255);
      ouvertureActive120 := ouvertureactive255;
      Normalisation(ouvertureactive120,autreCoupDiag,false);
      TraductionAlphanumeriqueEnThor(ouvertureactive120,ouvertureactive60);
      longueurOuverture := GET_LENGTH_OF_PACKED_GAME(ouvertureactive60);
      longueurPlus1 := longueurOuverture+1;
      nbreCoupsRestant := 60-longueurOuverture;
      if interversionlecturebase then 
        begin
          (* WritelnDansRapport('Appel de PrecompileInterversions dans ChargerLaBase'); *)
          if longueurOuverture <= 33 
            then PrecompileInterversions(ouvertureactive60,longueurOuverture)
            else PrecompileInterversions(ouvertureactive60,33);
          (*
          if (NbinterversionsCompatibles>0) then
            begin
              TestTigre := interversionFautive^^[interversionsCompatibles[NbinterversionsCompatibles]];
              if Length(TestTigre)=5 then                                   {F5D6C3D3C4=F5D6C4C3D3}
                if (TestTigre[2]=chr(64)) & (TestTigre[3]=chr(43)) &    {interversion de la Tigre}
                   (TestTigre[4]=chr(34)) & (TestTigre[5]=chr(33)) then   {dОjИ dans la base de thor}
                     NbinterversionsCompatibles := NbinterversionsCompatibles-1;
            end;
          *)
        end;
      doitTraiterInterversions := interversionlecturebase & (NbinterversionsCompatibles > 0);
      SET_NTH_MOVE_OF_PACKED_GAME(ouvertureactive60, 1, 197);   { sentinelle И la place de F5 }
    end
    else
      begin
        longueurOuverture := 0;
        longueurPlus1 := 1;
        nbreCoupsRestant := 60;
      end;
    
    
    
  
  RemplitTableCompatibleTournoiAvecCeBooleen(TournoiCompatible,true);
  RemplitTableCompatibleJoueurAvecCeBooleen(JoueurBlancCompatible,true);
  RemplitTableCompatibleJoueurAvecCeBooleen(JoueurNoirCompatible,true);
  RemplitTableCompatibleScoreAvecCeBooleen(ScoreCompatible,true);
  
  
  ScoreNoirRecherche := -1;
  GetItemTextInDialog(dp,ScoreNoirText,s);
  if s<>'' then
    begin
      RemplitTableCompatibleScoreAvecCeBooleen(ScoreCompatible,false);
      StringToNum(s,ScoreNoirRecherche);
      ScoreCompatible^[ScoreNoirRecherche] := true;
    end;
  GetItemTextInDialog(dp,AnneeText,s);
  anneeRecherche := StringEnAnneeSansBugAn2000(s);
  GetItemTextInDialog(dp,JoueurNoirText,JoueurNoirRecherche);
  GetItemTextInDialog(dp,JoueurBlancText,JoueurBlancRecherche);
  ANDentreJoueurs := not(JoueurBlancRecherche=JoueurNoirRecherche);
  GetItemTextInDialog(dp,tournoiText,tournoiRecherche);
  if not(JoueursEtTournoisEnMemoire) then 
    {if (JoueurNoirRecherche<>'') | (JoueurBlancRecherche<>'') | (tournoiRecherche<>'') then}  
      begin
        EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,3),20,kYpositionMessageBase);
        codeErreur := MetJoueursEtTournoisEnMemoire(false);
      end;
  if (JoueurNoirRecherche<>'') | (JoueurBlancRecherche<>'') then 
    begin
      EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,4),20,kYpositionMessageBase);
      ChercheNumerosJoueursCompatibles(JoueurNoirRecherche,JoueurBlancRecherche);
    end;
  if tournoiRecherche<>'' then 
    begin
      EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,5),20,kYpositionMessageBase);
      ChercheNumerosTournoisCompatibles(tournoiRecherche);
    end;
    
  
  
  InitCursor;
  TextFont(gCassioApplicationFont);
  TextSize(gCassioSmallFontSize);
  s := ReadStringFromRessource(TextesBaseID,10)+StringOf(' ');  {'lecture :'}
  larg := StringWidth(s)+20;
  EcritMessageLectureBase(s,20,kYpositionMessageBase);
  SetRect(pourcentageRect,larg,kYpositionMessageBase-7,larg+100,kYpositionMessageBase+1);
  FrameRect(pourcentageRect);  
  pourcentageCouleurRGB := NoircirCouleurDeCetteQuantite(kSteelBlueRGB,10000);
  dernierPourcentagePourTestSouris := 0;
  pourcentage := 0;
  tickchrono := TickCount();
     
  nbChargees := 0;
  CompteurPartiesExaminees := 0;
  dernierCompteurAffiche := 0;
  CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
  intervalleLecture := NbPartiesPotentiellementLues;
  intervallePourcentage := MyTrunc(1.0*intervalleLecture/100 +0.5);
  
  {WritelnStringAndNumDansRapport('sizeof(indexOuverture^[0]) = ', sizeof(IndexNouveauFormat.indexOuverture^[0]));
  WritelnStringAndNumDansRapport('sizeof(byte) = ', sizeof(byte));
  }
  
  if enAvancant
    then numeroFichierCourant := 1
    else numeroFichierCourant := InfosFichiersNouveauFormat.nbFichiers;
  REPEAT
  
  
  anneeFichierCourant := AnneePartiesFichierNouveauFormat(numeroFichierCourant);
  nroDistributionFichierCourant := InfosFichiersNouveauFormat.fichiers[numeroFichierCourant].nroDistribution;
  
  {
  EcritMessageLectureBase('annee fichier = '+NumEnString(anneeFichierCourant),20,kYpositionMessageBase);
  AttendFrappeClavierOuSouris(effetspecial2);
  EcritMessageLectureBase('annee recherche = '+NumEnString(anneeRecherche),20,kYpositionMessageBase);
	AttendFrappeClavierOuSouris(effetspecial2);
	}
	  
  if (numeroFichierCourant>=1) & (numeroFichierCourant <= InfosFichiersNouveauFormat.nbFichiers) &
     (InfosFichiersNouveauFormat.fichiers[numeroFichierCourant].typeDonnees=kFicPartiesNouveauFormat) &
     (InfosFichiersNouveauFormat.fichiers[numeroFichierCourant].nroDistribution in ChoixDistributions.distributionsALire) &
     (AnneeIsCompatible(anneeFichierCourant,anneeRecherche,genreDeTestPourAnnee)) then
     begin


  
      if (JoueurNoirRecherche<>'') | (JoueurBlancRecherche<>'') | (tournoiRecherche<>'') | (longueurOuverture>0)
        then ChargeIndexFichierCourant(numeroFichierCourant)
        else IndexNouveauFormat.tailleIndex := 0;
        
		  ChercheJoueursCompatiblesPourIndex(numeroFichierCourant);
		  ChercheTournoisCompatiblesPourIndex(numeroFichierCourant);
		  ChercheOuverturesCompatiblesPourIndex(numeroFichierCourant,ouvertureActive60);
		  
		  codeErreur := OuvreFichierNouveauFormat(numeroFichierCourant);
		  		  
		  SetNumerosDePartieMinEtMaxPourCeFichier(numeroFichierCourant,numeroPartieMin,numeroPartieMax);
		  
		  
		  
		  
		  
		  if EnAvancant 
		    then limiteCompteur := numeroPartieMax
		    else limiteCompteur := numeroPartiemin;
		  if EnAvancant 
		    then compteurPartieDansFichierCourant := numeroPartieMin-1
		    else compteurPartieDansFichierCourant := numeroPartieMax+1;
		  if EnAvancant 
		    then incrementCompteurPartie := +1
		    else incrementCompteurPartie := -1;
		  
		  
		  if compteurPartieDansFichierCourant<>limiteCompteur then
		  repeat
		    DejaAuMoinsUneRecherche := true;
		    compteurPartieDansFichierCourant := compteurPartieDansFichierCourant+incrementCompteurPartie;
		    inc(CompteurPartiesExaminees);
		    
		    
		    with IndexNouveauFormat do
		      if (tailleIndex <= 0)
		        then passeLeFiltreDesIndex := true
		        else
				      begin
				        passeLeFiltreDesIndex := OuvertureCompatible[indexOuverture^[compteurPartieDansFichierCourant]];
				        if passeLeFiltreDesIndex then
				          passeLeFiltreDesIndex := (TournoisCompatibleParIndex[indexTournoi^[compteurPartieDansFichierCourant]]);
				        if passeLeFiltreDesIndex then
				          if ANDentreJoueurs
				            then passeLeFiltreDesIndex := (NoirsCompatibleParIndex[indexNoir^[compteurPartieDansFichierCourant]] &
				                                        BlancsCompatibleParIndex[indexBlanc^[compteurPartieDansFichierCourant]])
				            else passeLeFiltreDesIndex := (NoirsCompatibleParIndex[indexNoir^[compteurPartieDansFichierCourant]] |
				                                        BlancsCompatibleParIndex[indexBlanc^[compteurPartieDansFichierCourant]]);    
				      end;
		    
		    
		    if passeLeFiltreDesIndex then
		      begin
		        LitPartieNro(numeroFichierCourant,compteurPartieDansFichierCourant,enAvancant);
		        
		        (*
		        if effetspecial2 then
		           begin
		             EcritMessageLectureBase('partie #'+NumEnString(compteurPartieDansFichierCourant)+' : lecture OK',20,kYpositionMessageBase);
		             AttendFrappeClavierOuSouris(effetspecial2);
		           end;
		        *)
		        
		        
		        with Partiebuff do
		          begin
		          
		          (*
		          if effetspecial2 then
		          begin
		            EcritMessageLectureBase('nro Noir = '+NumEnString(nroJoueurNoir)+ ', soit '+GetNomJoueur(nroJoueurNoir),20,kYpositionMessageBase);
		            AttendFrappeClavierOuSouris(effetspecial2);
		            EcritMessageLectureBase('nro Noir = '+NumEnString(nroJoueurBlanc)+ ', soit '+GetNomJoueur(nroJoueurBlanc),20,kYpositionMessageBase);
		            AttendFrappeClavierOuSouris(effetspecial2);
		            EcritMessageLectureBase('nro Noir = '+NumEnString(nroTournoi)+ ', soit '+GetNomTournoi(nroTournoi),20,kYpositionMessageBase);
		            AttendFrappeClavierOuSouris(effetspecial2);
		          end;
		          *)
		          
		          
		          
		          
		          
		          
		            compatibiliteTournoi := TournoiCompatible^[nroTournoi];
		            
		            
		            (*
		            if effetspecial2 then
		              begin
		                if compatibiliteTournoi
		                  then EcritMessageLectureBase('partie #'+NumEnString(compteurPartieDansFichierCourant)+' : compatibilite tournoi =true',20,kYpositionMessageBase)
		                  else EcritMessageLectureBase('partie #'+NumEnString(compteurPartieDansFichierCourant)+' : compatibilite tournoi =false',20,kYpositionMessageBase);
		                AttendFrappeClavierOuSouris(effetspecial2);
		              end;
		            *)
		            
		            if compatibiliteTournoi then
		               begin  
		                 if ANDentreJoueurs
		                  then compatibiliteJoueurs := JoueurNoirCompatible^[nroJoueurNoir] & 
		                                             JoueurBlancCompatible^[nroJoueurBlanc]
		                  else compatibiliteJoueurs := JoueurNoirCompatible^[nroJoueurNoir] | 
		                                             JoueurBlancCompatible^[nroJoueurBlanc];
		                
		                                             
		                 (*
		                 if effetspecial2 then
		                   begin
		                     if compatibiliteJoueurs 
		                       then EcritMessageLectureBase('partie #'+NumEnString(compteurPartieDansFichierCourant)+' : compatibilite Joueurs =true',20,kYpositionMessageBase)
		                       else EcritMessageLectureBase('partie #'+NumEnString(compteurPartieDansFichierCourant)+' : compatibilite Joueurs =false',20,kYpositionMessageBase);
		                     AttendFrappeClavierOuSouris(effetspecial2);
		                   end;
		                 *)                 
		                                             
		                 if compatibiliteJoueurs & ScoreCompatible^[scoreReel] then
		                    begin
		                      if (longueurOuverture <= 1) 
		                        then
		                          begin
		                            inc(nbChargees);
		                            ChargePartie(nbChargees,nroDistributionFichierCourant,anneeFichierCourant);
		                          end
		                        else
		                          begin
		                            if (listeCoups[longueurOuverture] <> 0) then
		                              begin
    		                            if doitTraiterInterversions 
      		                            then
      		                              begin
      		                                MoveMemory(@listeCoups[1], GET_ADRESS_OF_FIRST_MOVE(partie60), longueurOuverture);
      		                                SET_LENGTH_OF_PACKED_GAME(partie60, longueurOuverture);
      		                                TraiteInterversionFormatThorCompile(partie60);
      		                                
      		                                i := longueurOuverture;
      		                                while GET_NTH_MOVE_OF_PACKED_GAME(partie60,i, 'ChargerLaBase(1)') = 
      		                                      GET_NTH_MOVE_OF_PACKED_GAME(ouvertureactive60,i, 'ChargerLaBase(2)') do dec(i);
      		                                
      		                                if i=1 then
      		                                  begin
      		                                    inc(nbChargees);
      		                                    ChargePartie(nbChargees,nroDistributionFichierCourant,anneeFichierCourant);
      		                                  end;
      		                              end
      		                            else
      		                              begin
      		                                MoveMemory(@listeCoups[1], GET_ADRESS_OF_FIRST_MOVE(partie60), longueurOuverture);
      		                                SET_LENGTH_OF_PACKED_GAME(partie60, longueurOuverture);
      		                                
      		                                i := longueurOuverture;
      		                                while GET_NTH_MOVE_OF_PACKED_GAME(partie60,i, 'ChargerLaBase(3)') = 
      		                                      GET_NTH_MOVE_OF_PACKED_GAME(ouvertureactive60,i, 'ChargerLaBase(4)') do dec(i);
      		                                
      		                                if i=1 then
      		                                 begin
      		                                   inc(nbChargees);
      		                                   ChargePartie(nbChargees,nroDistributionFichierCourant,anneeFichierCourant);
      		                                 end;
      		                              end;
      		                        end;
  		                        end;
		                      end;
		                 end;
		         end; {with}
		      end;
		     
		    if not(enAvancant)
		      then
		        begin
		          depassementLimite := (compteurPartieDansFichierCourant<=limiteCompteur);
		          if (compteurPartiesExaminees-dernierCompteurAffiche)>=intervallePourcentage then
		            begin
		              dernierCompteurAffiche := compteurPartiesExaminees;
		              pourcentage := MyTrunc((compteurPartiesExaminees)*(100.0/intervalleLecture)+0.5);
		              if pourcentage>=99 then pourcentage := 100;
		              SetRect(pourcentageRect,larg+100+1-pourcentage,kYpositionMessageBase-6,larg+100-1,kYpositionMessageBase);
		              RGBForeColor(pourcentageCouleurRGB);
		              FillRect(pourcentagerect,blackPattern);
		              ForeColor(blackColor);
		              if pourcentage-dernierPourcentagePourTestSouris>=1 then
		                begin
		                  dernierPourcentagePourTestSouris := pourcentage;
		                  annulationPendantLecture := TesteAnnulationPendantLecture();
		                end;
		            end;
		        end 
		      else
		        begin
		          depassementLimite := (compteurPartieDansFichierCourant>=limiteCompteur);
		          if (compteurPartiesExaminees-dernierCompteurAffiche)>=intervallePourcentage then
		            begin
		              dernierCompteurAffiche := compteurPartiesExaminees;
		              pourcentage := MyTrunc((compteurPartiesExaminees)*(100.0/intervalleLecture)+0.5);
		              if pourcentage>=99 then pourcentage := 100;
		              SetRect(pourcentageRect,larg+1,kYpositionMessageBase-6,larg+pourcentage-1,kYpositionMessageBase);
		              RGBForeColor(pourcentageCouleurRGB);
		              FillRect(pourcentagerect,blackPattern);
		              ForeColor(blackColor);
		              if pourcentage-dernierPourcentagePourTestSouris>=1 then
		                begin
		                  dernierPourcentagePourTestSouris := pourcentage;
		                  annulationPendantLecture := TesteAnnulationPendantLecture();
		                end;
		            end;
		        end;
		        
		  until (nbChargees>=nbrePartiesEnMemoire) | depassementLimite | annulationPendantLecture;
  
      
      codeErreur := FermeFichierNouveauFormat(numeroFichierCourant);
  
  
    end;
  
  
    
  if enAvancant 
    then numeroFichierCourant := succ(numeroFichierCourant)
    else numeroFichierCourant := pred(numeroFichierCourant);
    
  UNTIL (numeroFichierCourant > InfosFichiersNouveauFormat.nbFichiers) | 
        (numeroFichierCourant < 0) |
        (nbChargees >= nbrePartiesEnMemoire) |
        annulationPendantLecture;
  
  
  auMoinsUnePartieDansBuffer := (nbChargees>0);
  if (nbChargees>=nbrePartiesEnMemoire) & not(depassementLimite) & (nbInformationMemoire<1) then
    begin
      nbInformationMemoire := nbInformationMemoire+1;
      SysBeep(0);
      DisableKeyboardScriptSwitch;
      FinRapport;
      TextNormalDansRapport;
      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
      ChangeFontFaceDansRapport(bold);
      WritelnDansRapport('еееееееееееееееееееееееееееееееееее');
      WritelnDansRapport(ReadStringFromRessource(TextesRapportID,16));
      WritelnDansRapport(ReadStringFromRessource(TextesRapportID,17));
      WritelnDansRapport(ReadStringFromRessource(TextesRapportID,18));
      if gIsRunningUnderMacOSX
        then WritelnDansRapport(ReadStringFromRessource(TextesRapportID,41))  {'dans les prОfОrences'}
        else WritelnDansRapport(ReadStringFromRessource(TextesRapportID,19)); {'dans la fenetres d'infos du Finder'}
      WritelnDansRapport(ReadStringFromRessource(TextesRapportID,20));
      WritelnDansRapport('ееееееееееееееееееееееееееееееееееее');
      TextNormalDansRapport;    
      EnableKeyboardScriptSwitch; 
    end;
  
  
  if debuggage.pendantLectureBase then
    begin
      TextFont(gCassioApplicationFont);
      TextSize(gCassioSmallFontSize);
      SetRect(lignerect,0,140,larg+35,155);
      EraseRect(lignerect);
      pourcentage := MyTrunc((compteurPartieDansFichierCourant-numeroPartieMin)*100.0/intervalleLecture+0.5);
      if pourcentage>100 then pourcentage := 100;
      WriteStringAndNumAt('temps en ticks : ',(TickCount()-tickchrono),20,150);
      WriteStringAndNumAt('nb parties trouvОes : ',nbChargees,20,162);
      WritelnDansRapportEtAttendFrappeClavier('apres affichage temps en ticks dans ChargerLaBase',true);
    end;
  
try_again :

  if not(annulationPendantLecture) 
    then
      begin
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant OrdreDuTriRenverse := false dans ChargerLaBase',true);
        
        OrdreDuTriRenverse := false;
        {sousSelectionActive := false;}
        
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant CalculTableCriteres dans ChargerLaBase',true);
        
        nbPartiesChargees := nbchargees;
        CalculTableCriteres;
        AucunePartieDetruiteDansLaListe;
        AucunePartieDeLaListeNeDoitEtreSauvegardee;
        RecopierPartiesCompatiblesCommePartiesActives;  
        
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant GetCursor dans ChargerLaBase',true);

        
        watch := GetCursor(watchcursor);
        SafeSetCursor(watch);
        
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant EcritMessageLectureBase dans ChargerLaBase',true);
        
        EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,6),20,kYpositionMessageBase);
        
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant TrierListePartie dans ChargerLaBase',true);

        
        TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
        
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant AjusteCurseur dans ChargerLaBase',true);
        
        AjusteCurseur;
        
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant IncrementeMagicCookieDemandeCalculsBase dans ChargerLaBase',true);
        
        IncrementeMagicCookieDemandeCalculsBase;
        
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant ConstruitTableNumeroReference dans ChargerLaBase',true);
        
        
        ConstruitTableNumeroReference(false,false);
        
        
        {Si on n'a aucune partie active, on essaye de desactiver la boite "enlever les parties d'ordinateurs"}
        if (nbPartiesChargees > 0) & (nbPartiesActives <= 0) & not(InclurePartiesAvecOrdinateursDansListe()) then
          begin
            SetInclurePartiesAvecOrdinateursDansListe(true);
            goto try_again;
          end;
        
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant EssayerConstruireTitrePartie dans ChargerLaBase',true);
        
        EssayerConstruireTitrePartie;
        
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant SetPartieHiliteeEtAjusteAscenseurListe dans ChargerLaBase',true);
        
        InitSelectionDeLaListe;
        SetPartieHiliteeEtAjusteAscenseurListe(1);
        
        ouvertureactive60 := ChainePartieLecture;
        TraductionThorEnAlphanumerique(ouvertureactive60,ouvertureactive255);
        partieEnChaine := ouvertureactive255;
      end
    else
      begin
        SetRect(lignerect,0,kYpositionMessageBase-15,larg+105,kYpositionMessageBase+3);
        EraseRect(lignerect);
      end;
   TextSize(0);
   TextFont(systemFont);
   TextFace(normal);

 
  ChaineTournoi := NewTournoi;
  ChaineBlanc := NewBlanc;
  ChaineNoir := NewNoir;
  ChaineAnnee := NewAnnee;
  ChaineScoreNoir := NewScoreNoir;
  ChaineGenreTest := NewGenreTest;
  
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Sortie de ChargerLaBase',true);
  
end;

procedure DoAbandon;
var i,coup : SInt32;
begin
  nbPartiesChargees := 0;
  nbPartiesActives := 0;
  IncrementeMagicCookieDemandeCalculsBase;
  ConstruitTableNumeroReference(false,false);
  SetPartieHiliteeEtAjusteAscenseurListe(1);
  positionLectureModifiee := false;
  FILL_PACKED_GAME_WITH_ZEROS(ChainePartieLecture);
  if not(positionfeerique) then
    for i := 1 to nbreCoup do
      begin
        coup := GetNiemeCoupPartieCourante(i);
        if (coup >= 11) & (coup <= 88) then
          ADD_MOVE_TO_PACKED_GAME(ChainePartieLecture, coup);
      end;
  TraductionThorEnAlphanumerique(ChainePartieLecture, partieEnChaine);
end;

procedure LectureSurCriteres;
var i : SInt16; 
    FiltreLectureDialogUPP : ModalFilterUPP;
    err : OSErr;
    PeutAbandonner,ouvertureDiagonale : boolean;
    autreCoupQuatreDansPartie : boolean;
    s60 : PackedThorGame;
    s120:str120;
    codeErreur : OSErr;
    bidon : boolean;
begin
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('EntrОe dans LectureSurCriteres',true);
   
  itemHit := -1;
  interversionlecturebase := true;
  s120 := PartieNormalisee(autreCoupQuatreDansPartie,false);
  
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant BeginDialog dans LectureSurCriteres',true);
    
  switchToScript(gLastScriptUsedInDialogs);
  BeginDialog;
  FiltreLectureDialogUPP := NewModalFilterUPP(@FiltreLectureDialog);
  dp := MyGetNewDialog(LectureBaseID,FenetreFictiveAvantPlan());
  if dp <> NIL then
  begin
    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant MetAnciensParametres dans LectureSurCriteres',true);

    JoueurBlancCompatible  := NewTableJoueurCompatiblePtr();
    JoueurNoirCompatible   := NewTableJoueurCompatiblePtr();
    TournoiCompatible      := NewTableTournoiCompatiblePtr();
    ScoreCompatible        := NewTableScoreCompatiblePtr();

    MetAnciensParametres;
    MetParametresSpeciauxLecture;
    tousParametresvides := false;
    SelectDialogItemText(dp,JoueurNoirText,0,MaxInt);
    SetBoolCheckBox(dp,LectureAntichronologiqueBox,LectureAntichronologique);
    GetItemTextInDialog(dp,AnneeText,s);
    anneeRecherche := StringEnAnneeSansBugAn2000(s);
    
    InitialisePlateauLecture(GetDialogWindow(dp));
    InstalleMenuFlottantOuverture;
    InstalleMenuFlottantBases(popUpBases,MenuFlottantBasesID,EstUneDistributionDeParties);
    GetMenuOuvertureItemAndRect;
    GetMenuBasesItemAndRect;
    CalculeNbTotalPartiesDansDistributionsALire;
    CheckItemMarksOnMenuBases(popUpBases.itemCourantMenuBases);
    DrawPUItem(popUpBases.MenuFlottantBases,popUpBases.itemCourantMenuBases,popUpBases.menuBasesRect,false);
    DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
    MyDrawDialog(dp);
    EcritNbPartiesBase;
    EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
    
    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant ModalDialog dans LectureSurCriteres',true);
    
    DejaAuMoinsUneRecherche := false;
    PeutAbandonner := false;
    InitCursor;
    err := SetDialogTracksCursor(dp,true);
    repeat
      ModalDialog(FiltreLectureDialogUPP,itemHit);
      case itemHit of
        VirtualUpdateItemInDialog:
          begin
            with popUpBases do
              begin
		            BeginUpdate(GetDialogWindow(dp));
		            RedessineDialogue(dp);
		            CheckItemMarksOnMenuBases(itemCourantMenuBases);
		            DrawPUItem(MenuFlottantBases,itemCourantMenuBases,menuBasesRect,false);
		            DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
		            EndUpdate(GetDialogWindow(dp));
		          end;
          end;
        Annuler:
          begin
            SauveToutAvantAnnuler(false);
            if PeutAbandonner then DoAbandon;
            positionLectureModifiee := false;
          end;
        ScoreNoirText:
          begin
            GetItemTextInDialog(dp,itemHit,s1);
            s := SeulementLesChiffres(s1);
            SetItemTextInDialog(dp,itemHit,s);
            StringToNum(s,aux);
            if (Length(s)>2) | (aux>64) then SysBeep(0);
          end;
        AnneeText:
          begin
            GetItemTextInDialog(dp,itemHit,s1);
            s := SeulementLesChiffres(s1);
            SetItemTextInDialog(dp,itemHit,s);
            anneeRecherche := StringEnAnneeSansBugAn2000(s);
            if (Length(s)>4) | ((Length(s)=4) & (AnneeRecherche<1970))
              then SysBeep(0);
            CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
            EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
          end;
        TournoiText,JoueurNoirText,JoueurBlancText:
          begin
            GetItemTextInDialog(dp,itemHit,s);
            if (s[Length(s)]='=') then
              begin
                if not(JoueursEtTournoisEnMemoire) then 
                  begin
                    EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,3),20,kYpositionMessageBase);
                    codeErreur := MetJoueursEtTournoisEnMemoire(false);
                    EcritMessageLectureBase('                                                             ',20,kYpositionMessageBase);
                  end;
                s := TPCopy(s,1,Length(s)-1);
                case itemHit of
                  JoueurNoirText : s := Complemente(complementationJoueurNoir,s,i);
                  JoueurBlancText: s := Complemente(complementationJoueurBlanc,s,i);
                  TournoiText    : s := Complemente(complementationTournoi,s,i);
                end;
                SetItemTextInDialog(dp,itemHit,s);
                SelectDialogItemText(dp,itemHit,i,MaxInt);  
              end;
          end;
        LectureBouton: 
           begin
             if positionLectureModifiee & analyseRetrograde.enCours then
               begin
                 with popUpBases do
                   begin
                     if not(PeutArreterAnalyseRetrograde()) then itemHit := -1;
                     RedessineDialogue(dp);
                     CheckItemMarksOnMenuBases(itemCourantMenuBases);
                     DrawPUItem(MenuFlottantBases,itemCourantMenuBases,menuBasesRect,false);
                     DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
                   end;
               end;
             if (itemHit=LectureBouton) then
               begin
		             DeplaceAnneeDuTournoi;
		             GetIndString(s,TextesBaseID,11);    {'Stop'}
		             SetControlTitleInDialog(dp,Annuler,s);
		             
		             
		             HiliteControlInDialog(dp,Annuler,0);
		             HiliteControlInDialog(dp,LectureBouton,1);
		             MetParametresSpeciauxLecture;
		             EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
		             
		             if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant ChargerLaBase dans LectureSurCriteres',true);
                 
		             ChargerLaBase;
		             		             
		             if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Apres ChargerLaBase dans LectureSurCriteres',true);

		             HiliteControlInDialog(dp,LectureBouton,0);
		             if annulationPendantLecture then 
		               begin
		                 itemHit := -1;
		                 EcritNbPartiesBase;
		                 FlashItem(dp,Annuler);
		                 GetIndString(s,TextesBaseID,12);    {'Abandon'}
		                 SetControlTitleInDialog(dp,Annuler,s);
		                 PeutAbandonner := true;
		               end;
		           end;
           end;
        CoupPrecedentBouton:
           begin
             DejoueUnCoupPlateauLecture(GetDialogWindow(dp));
           end;
        OuvertureUserItemPopUp : 
           begin
             bidon := EventPopUpItemInDialog(dp,OuverturestaticText,OuvertureMenu,itemmenuouverture,menuouverturerect,true,true);
             if MenuItemToOuverture(itemmenuouverture,s60) then
               begin
                 ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
                 TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie & ouvertureDiagonale,4,60);
                 JoueOuverturePlateauLecture(s60,GetDialogWindow(dp));
                 RedessineDialogue(dp);
               end;
           end;
        BasesUserItemPopUp : 
           begin
             with popUpBases do
               begin
		             bidon := EventPopUpItemInDialog(dp,BasesStaticText,menuFlottantBases,itemCourantMenuBases,menuBasesRect,false,false);
		             if MenuItemToBases(itemCourantMenuBases) then
		               begin
		                 DrawPUItem(menuFlottantBases, itemCourantMenuBases, menuBasesRect,false);
		                 EcritNbPartiesBase;
		                 EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
		               end;
		           end;
           end;
        GenreTestTextLectureBase:
          begin
            GetItemTextInDialog(dp,itemHit,s);
            if s='=>' then s := '>=';
            if s='=<' then s := '<=';
            if (s<>'=') & (s<>'>=') & (s<>'<=') & (s<>'>') & (s<>'<') 
              then
                begin
                  if s<>'' then SysBeep(0);
                  genreDeTestPourAnnee := testEgalite;
                  s := '';
                end
              else
                begin
                    if s='='  then genreDeTestPourAnnee := testEgalite;
                    if s='>=' then genreDeTestPourAnnee := testSuperieur;
                    if s='<=' then genreDeTestPourAnnee := testInferieur;
                    if s='>'  then genreDeTestPourAnnee := testSuperieurStrict;
                    if s='<'  then genreDeTestPourAnnee := testInferieurStrict;
                end; 
            SetItemTextInDialog(dp,itemHit,s);
            CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
            EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
          end;
        LectureAntichronologiqueBox :
          begin
            ToggleCheckBox(dp,LectureAntichronologiqueBox);
            LectureAntichronologique := not(LectureAntichronologique);
          end;
      end; {case}
    until (itemHit=LectureBouton) | (itemHit=Annuler);
    SauveAnciensParametres;
    
    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant DesinstalleMenuFlottantOuverture dans LectureSurCriteres',true);

    DesinstalleMenuFlottantOuverture;
    
    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant DesinstalleMenuFlottantBases dans LectureSurCriteres',true);

    DesinstalleMenuFlottantBases(popUpBases);
    
    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant MyDisposeDialog dans LectureSurCriteres',true);

    MyDisposeDialog(dp);
    
    DisposeTableJoueurCompatible(JoueurBlancCompatible);
    DisposeTableJoueurCompatible(JoueurNoirCompatible);
    DisposeTableTournoiCompatible(TournoiCompatible);
    DisposeTableScoreCompatible(ScoreCompatible);
    
  end;
  
  if windowListeOpen then 
    begin
      SetPortByWindow(wListePtr);
      
      if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant InvalRect(QDGetPortBound()) (wlistePtr) dans LectureSurCriteres',true);
      
      InvalRect(QDGetPortBound());
    end;
  if windowStatOpen then 
    begin
      SetPortByWindow(wStatPtr);
      
      if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant InvalRect(QDGetPortBound()) (wStatPtr) dans LectureSurCriteres',true);

      InvalRect(QDGetPortBound());
    end;
  
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant MyDisposeModalFilterUPP dans LectureSurCriteres',true);

  MyDisposeModalFilterUPP(FiltreLectureDialogUPP);
  
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant EndDialog dans LectureSurCriteres',true);

  EndDialog;
  GetCurrentScript(gLastScriptUsedInDialogs);
  SwitchToRomanScript;
  
  if not(windowListeOpen | windowStatOpen) & ((itemHit=LectureBouton) & (nbPartiesChargees > 0)) then
    begin
      DoStatistiques;
      DoListeDeParties;
    end;
  
  if (itemHit=LectureBouton) | ((itemHit=annuler) & PeutAbandonner)
    then result := true
    else result := false;
  
   if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('sortie de LectureSurCriteres',true);

end;



begin {Action base de donnees}
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Entree dans ActionBaseDeDonnee',true);

  result := false;
  auMoinsUnePartieDansBuffer := false;
  (* A FAIRE : tests d'ouverture de fichier *)
  if true then
	 begin
	   result := true;
	   
	   case actiondemandee of
	     BaseLectureJoueursEtTournois   :codeErreur := MetJoueursEtTournoisEnMemoire(false);
	     BaseLectureCriteres            :begin
	                                       if positionfeerique 
	                                         then 
	                                           begin
	                                             DialoguePartieIncomplete;
	                                             result := false;
	                                           end;
	                                        LectureSurCriteres;
	                                     end;
	   end  {case};
	   DerniereActionBaseEffectuee := actiondemandee;
	 end;
 
 
  if not(actiondemandee=BaseLectureJoueursEtTournois) then
  if not((actiondemandee=BaseLectureCriteres) & positionLectureModifiee) then
  if not(enSetUp) then
    begin
      if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant HasGotEvent dans ActionBaseDeDonnee',true);

      if HasGotEvent(updateMask,myEvent,0,NIL) then 
        begin
          theEvent := myEvent;
          
          if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant TraiteEvenements dans ActionBaseDeDonnee',true);
          
          TraiteEvenements;
        end;
    end;
   ActionBaseDeDonnee := result;
   
   if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('sortie de ActionBaseDeDonnee',true);
end;


procedure DoLectureJoueursEtTournoi(nomsCourts : boolean);
var OSErreur : OSErr;
    (* i : SInt32;
    nomTournoi:str30; *)
begin
  if not(problemeMemoireBase) & not(JoueursEtTournoisEnMemoire) then
    begin
      OSErreur := MetJoueursEtTournoisEnMemoire(nomsCourts);
      
      (*
      for i := 0 to TournoisNouveauFormat.nbTournoisNouveauFormat do
        begin
          nomTournoi := GetNomTournoi(i);
          
          if Pos('ictif',nomTournoi) = 0 then
            WritelnDansRapport(NomCourtDuTournoi(nomTournoi){ + ' ['+nomTournoi+']'});
        end;
      *)
    end;
end;



END.