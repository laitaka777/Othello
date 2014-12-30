UNIT UnitPierresDelta;



INTERFACE







  USES  UnitPropertyList;
  
  

type CalculeRect2DFunc = function (whichSquare,QuelGenreDeMarque : SInt16) : rect;
     CalculeRect3DFunc = function (whichSquare,QuelGenreDeMarque : SInt16) : rect;
  
  

procedure DessinerUnePierreDelta(var plat : plateauOthello;quelleCase,quelGenre : SInt16; 
                                 GetRectForSquare2D:CalculeRect2DFunc;
                                 use3D : boolean;
                                 GetRectDessusForSquare3D :CalculeRect3DFunc;   {appelée si use3D=true}
                                 GetRectDessousForSquare3D:CalculeRect3DFunc);  {appelée si use3D=true}
procedure DessinerUnePierreDeltaDouble(var plat : plateauOthello;quelleCase1,quelleCase2,quelGenre : SInt16; 
                                 GetRectForSquare2D:CalculeRect2DFunc;
                                 use3D : boolean;
                                 GetRectDessusForSquare3D :CalculeRect3DFunc;   {appelée si use3D=true}
                                 GetRectDessousForSquare3D:CalculeRect3DFunc);  {appelée si use3D=true}


{iterateurs}
procedure ItereSurPierresDelta(G : GameTree;DoWhat:PropertyProc);
procedure ItereSurPierresDeltaCourantes(DoWhat:PropertyProc);
procedure ItereSurPierresDeltaAvecResult(G : GameTree;DoWhat:PropertyProcAvecResult; var result : SInt32);
procedure ItereSurPierresDeltaCourantesAvecResult(DoWhat:PropertyProcAvecResult; var result : SInt32);

{autres}
procedure DesssinePierresDelta(G : GameTree;surQuellesCases : SquareSet);
procedure DesssinePierresDeltaCourantes; 
procedure EffacePierresDelta(G : GameTree);
procedure EffacePierresDeltaCourantes;
procedure AddRandomDeltaStoneToCurrentNode;
procedure ChangePierresDeltaApresCommandClicSurOthellier(mouseLoc : Point;jeu : plateauOthello;forceAfficheMarquesSpeciales : boolean);
function TypesPierresDelta() : SetOfPropertyTypes;




  
IMPLEMENTATION







USES UnitActions,UnitGeometrie,UnitCarbonisation,UnitArbreDeJeuCourant,
     UnitBufferedPICT,UnitOth1,UnitServicesDialogs,UnitStrategie,
     UnitTroisiemeDimension,UnitCouleur;





procedure DessinerUnePierreDelta(var plat : plateauOthello;quelleCase,quelGenre : SInt16; 
                                 GetRectForSquare2D:CalculeRect2DFunc;
                                 use3D : boolean;
                                 GetRectDessusForSquare3D :CalculeRect3DFunc;
                                 GetRectDessousForSquare3D:CalculeRect3DFunc);
var caseRect,destRect : rect;
begin
  caseRect := GetRectForSquare2D(quelleCase,quelGenre);
  if not(use3D) 
    then destRect := caseRect
    else
      begin
        if plat[QuelleCase] = pionVide
          then 
            begin
              destRect := GetRectDessousForSquare3D(quelleCase,quelGenre);
              if (quelGenre=DeltaProp) |
                 (quelGenre=DeltaWhiteProp)     | (quelGenre=DeltaBlackProp)     
                 then OffsetRect(destRect,0,2);  {sinon le delta sur la vcase vide se retrouve trop haut}
            end
          else destRect := GetRectDessusForSquare3D(QuelleCase,quelGenre);
      end;
  
  case quelGenre of
    MarkedPointsProp         : if plat[QuelleCase] = pionNoir
                                 then DessinePionSpecial(caseRect,destRect,QuelleCase,PionCroixTraitsBlancs,use3D)
                                 else DessinePionSpecial(caseRect,destRect,QuelleCase,PionCroixTraitsNoirs,use3D);
    {SelectedPointsProp   }  
    DeltaWhiteProp           : DessinePionSpecial(caseRect,destRect,QuelleCase,PionDeltaBlanc,use3D);
    DeltaBlackProp           : if plat[QuelleCase] = pionNoir  
                                  then 
                                    begin
                                      DessinePionSpecial(caseRect,destRect,QuelleCase,PionDeltaNoir,use3D);
                                      DessinePionSpecial(caseRect,destRect,QuelleCase,PionDeltaTraitsBlancs,use3D)
                                    end
                                  else DessinePionSpecial(caseRect,destRect,QuelleCase,PionDeltaNoir,use3D);
    DeltaProp                : if plat[QuelleCase] = pionVide  then DessinePionSpecial(caseRect,destRect,QuelleCase,PionDeltaTraitsNoirs,use3D) else
                               if plat[QuelleCase] = pionNoir  then DessinePionSpecial(caseRect,destRect,QuelleCase,PionDeltaTraitsBlancs,use3D) else
                               if plat[QuelleCase] = pionBlanc then DessinePionSpecial(caseRect,destRect,QuelleCase,PionDeltaTraitsNoirs,use3D);
    LosangeWhiteProp         : DessinePionSpecial(caseRect,destRect,QuelleCase,PionLosangeBlanc,use3D);
    LosangeBlackProp         : if plat[QuelleCase] = pionNoir  
                                  then 
                                    begin
                                      DessinePionSpecial(caseRect,destRect,QuelleCase,PionLosangeNoir,use3D);
                                      DessinePionSpecial(caseRect,destRect,QuelleCase,PionLosangeTraitsBlancs,use3D);
                                    end
                                  else DessinePionSpecial(caseRect,destRect,QuelleCase,PionLosangeNoir,use3D);
    LosangeProp              : if plat[QuelleCase] = pionVide  then DessinePionSpecial(caseRect,destRect,QuelleCase,PionLosangeTraitsNoirs,use3D) else
                               if plat[QuelleCase] = pionNoir  then DessinePionSpecial(caseRect,destRect,QuelleCase,PionLosangeTraitsBlancs,use3D) else
                               if plat[QuelleCase] = pionBlanc then DessinePionSpecial(caseRect,destRect,QuelleCase,PionLosangeTraitsNoirs,use3D);
    CarreWhiteProp           : DessinePionSpecial(caseRect,destRect,QuelleCase,PionCarreBlanc,use3D);
    CarreBlackProp           : if plat[QuelleCase] = pionNoir  
                                  then 
                                    begin
                                      DessinePionSpecial(caseRect,destRect,QuelleCase,PionCarreNoir,use3D);
                                      DessinePionSpecial(caseRect,destRect,QuelleCase,PionCarreTraitsBlancs,use3D);
                                    end
                                  else DessinePionSpecial(caseRect,destRect,QuelleCase,PionCarreNoir,use3D);
    CarreProp                : if plat[QuelleCase] = pionVide  then DessinePionSpecial(caseRect,destRect,QuelleCase,PionCarreTraitsNoirs,use3D) else
                               if plat[QuelleCase] = pionNoir  then DessinePionSpecial(caseRect,destRect,QuelleCase,PionCarreTraitsBlancs,use3D) else
                               if plat[QuelleCase] = pionBlanc then DessinePionSpecial(caseRect,destRect,QuelleCase,PionCarreTraitsNoirs,use3D);
    EtoileProp               : DessinePionSpecial(caseRect,destRect,QuelleCase,PionEtoile,use3D);
    PetitCercleWhiteProp     : DessinePionSpecial(caseRect,destRect,QuelleCase,PionPetitCercleBlanc,use3D);
    PetitCercleBlackProp     : if plat[QuelleCase] = pionNoir  
                                  then 
                                    begin
                                      DessinePionSpecial(caseRect,destRect,QuelleCase,PionPetitCercleNoir,use3D);
                                      DessinePionSpecial(caseRect,destRect,QuelleCase,PionPetitCercleTraitsBlancs,use3D);
                                    end
                                  else DessinePionSpecial(caseRect,destRect,QuelleCase,PionPetitCercleNoir,use3D);
    PetitCercleProp          : if plat[QuelleCase] = pionVide  then DessinePionSpecial(caseRect,destRect,QuelleCase,PionPetitCercleTraitsNoirs,use3D) else
                               if plat[QuelleCase] = pionNoir  then DessinePionSpecial(caseRect,destRect,QuelleCase,PionPetitCercleTraitsBlancs,use3D) else
                               if plat[QuelleCase] = pionBlanc then DessinePionSpecial(caseRect,destRect,QuelleCase,PionPetitCercleTraitsNoirs,use3D);
    otherwise     AlerteSimple('Je ne sais pas Dessiner ce type de pierres marquees dans DessinerUnePierreDelta!!');
  end; {case}
end;




procedure DessinerUnePierreDeltaDouble(var plat : plateauOthello;quelleCase1,quelleCase2,quelGenre : SInt16; 
                                 GetRectForSquare2D:CalculeRect2DFunc;
                                 use3D : boolean;
                                 GetRectDessusForSquare3D :CalculeRect3DFunc;
                                 GetRectDessousForSquare3D:CalculeRect3DFunc);
var CaseRect1,destRect1 : rect;
    CaseRect2,destRect2 : rect;
    thePenState:PenState;
    hautCase,epaisseur : SInt16; 
    
   function CalculeDestRect(quelleCase,quelGenre : SInt16) : rect;
   begin
     if not(use3D)
       then
       	 CalculeDestRect := GetRectForSquare2D(quelleCase,quelGenre)
       else
         begin
           if plat[quelleCase] = pionVide
             then CalculeDestRect := GetRectDessousForSquare3D(quelleCase,quelGenre)
             else CalculeDestRect := GetRectDessusForSquare3D(quelleCase,quelGenre);
         end;
   end;
    
begin
  caseRect1 := GetRectForSquare2D(quelleCase1,quelGenre);
  caseRect2 := GetRectForSquare2D(quelleCase2,quelGenre);
  destRect1 := CalculeDestRect(quelleCase1,quelGenre);
  destRect2 := CalculeDestRect(quelleCase2,quelGenre);
  
  case quelGenre of
    ArrowProp :  
      if quelleCase1 <> quelleCase2 then
	      begin
	        hautCase := CalculeDestRect(88,quelGenre).bottom - CalculeDestRect(88,quelGenre).top;
	        epaisseur := 2;
	        if hautCase > 20 then inc(epaisseur);
	        if hautCase > 30 then inc(epaisseur);
	        GetPenState(thePenState);
	        PenSize(epaisseur,epaisseur);
	        ForeColor(RedColor);
	        DessineFleche(CentreDuRectangle(destRect1),CentreDuRectangle(destRect2),(destRect2.bottom-destRect2.top)*0.47);
	        ForeColor(BlackColor);
	        SetPenState(thePenState);
	      end;
    LineProp  :  
      if quelleCase1 <> quelleCase2 then
	      begin
	        hautCase := CalculeDestRect(88,quelGenre).bottom - CalculeDestRect(88,quelGenre).top;
	        epaisseur := 2;
	        if hautCase > 20 then inc(epaisseur);
	        if hautCase > 30 then inc(epaisseur);
	        GetPenState(thePenState);
	        PenSize(epaisseur,epaisseur);
	        ForeColor(RedColor);
	        DessineLigne(CentreDuRectangle(destRect1),CentreDuRectangle(destRect2));
	        ForeColor(BlackColor);
	        SetPenState(thePenState);
	      end;
    otherwise     AlerteSimple('Je ne sais pas Dessiner ce type de pierres marquees dans DessinerUnePierreDeltaDouble!!');
  end; {case}
  
  
end;


procedure DessinerPierresDeltaOfProperty(var prop : Property);
var whichSquare,i,j : SInt16; 
    RegionMarquee : PackedSquareSet;
    whichSquare1,whichSquare2 : SInt16; 
begin
  with prop do
  case stockage of
    StockageEnEnsembleDeCases : 
      begin
        RegionMarquee := GetPackedSquareSetOfProperty(prop);
        for i := 1 to 8 do
          for j := 1 to 8 do
            begin
              whichSquare := i*10+j;
              if SquareInPackedSquareSet(whichSquare,RegionMarquee) then
                begin
                  DessinerUnePierreDelta(jeuCourant,whichSquare,genre,GetRectOfSquare2DDansAireDeJeu,CassioEstEn3D(),GetRectAreteVisiblePion3DPourPionDelta,GetRectPionDessous3DPourPionDelta);
                  InvalidateDessinEnTraceDeRayon(whichSquare);
                  SetOthellierEstSale(whichSquare,true);
                end;
            end;
      end;
    StockageEnCaseOthello :
      begin
        whichSquare := GetOthelloSquareOfProperty(prop);
        DessinerUnePierreDelta(jeuCourant,whichSquare,genre,GetRectOfSquare2DDansAireDeJeu,CassioEstEn3D(),GetRectAreteVisiblePion3DPourPionDelta,GetRectPionDessous3DPourPionDelta);
        InvalidateDessinEnTraceDeRayon(whichSquare);
        SetOthellierEstSale(whichSquare,true);
      end;
    StockageEnCaseOthelloAlpha :
      begin
        whichSquare := GetOthelloSquareOfPropertyAlpha(prop);
        DessinerUnePierreDelta(jeuCourant,whichSquare,genre,GetRectOfSquare2DDansAireDeJeu,CassioEstEn3D(),GetRectAreteVisiblePion3DPourPionDelta,GetRectPionDessous3DPourPionDelta);
        InvalidateDessinEnTraceDeRayon(whichSquare);
        SetOthellierEstSale(whichSquare,true);
      end;
    StockageEnCoupleCases:
			begin
				GetSquareCoupleOfProperty(prop,whichSquare1,whichSquare2);
				DessinerUnePierreDeltaDouble(jeuCourant,whichSquare1,whichSquare2,genre,
                                     GetRectOfSquare2DDansAireDeJeu,
                                     CassioEstEn3D(),
                                     GetRectAreteVisiblePion3DPourPionDelta,
                                     GetRectPionDessous3DPourPionDelta);
				InvalidateDessinEnTraceDeRayon(whichSquare1);
				InvalidateDessinEnTraceDeRayon(whichSquare2);
				SetOthellierEstSale(whichSquare1,true);
				SetOthellierEstSale(whichSquare1,true);
			end;
  end; {case}
end;

function TypesPierresDelta() : SetOfPropertyTypes;
begin
	TypesPierresDelta :=  [MarkedPointsProp     ,
		                    SelectedPointsProp    ,
		                    DeltaWhiteProp        ,
		                    DeltaBlackProp        ,
		                    DeltaProp             ,
		                    LosangeWhiteProp      ,
		                    LosangeBlackProp      ,
		                    LosangeProp           ,
		                    CarreWhiteProp        ,
		                    CarreBlackProp        ,
		                    CarreProp             ,
		                    EtoileProp            ,
		                    PetitCercleWhiteProp  ,
		                    PetitCercleBlackProp  ,
		                    PetitCercleProp       , 
		                    LineProp              ,
		                    ArrowProp] ;
end;

procedure ItereSurPierresDelta(G : GameTree;DoWhat:PropertyProc);
begin
	ForEachPropertyOfTheseTypesInNodeDo(G,TypesPierresDelta(),DoWhat);
end;

procedure ItereSurPierresDeltaCourantes(DoWhat:PropertyProc);
var G : GameTree;
begin
  G := GetCurrentNode();
  ItereSurPierresDelta(G,DoWhat);
end;

procedure ItereSurPierresDeltaAvecResult(G : GameTree;DoWhat:PropertyProcAvecResult; var result : SInt32);
begin
	ForEachPropertyOfTheseTypesInNodeDoAvecResult(G,TypesPierresDelta(),DoWhat,result);
end;

procedure ItereSurPierresDeltaCourantesAvecResult(DoWhat:PropertyProcAvecResult; var result : SInt32);
var G : GameTree;
begin
  G := GetCurrentNode();
  ItereSurPierresDeltaAvecResult(G,DoWhat,result);
end;

procedure DesssinePierresDeltaCourantes;
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      ItereSurPierresDeltaCourantes(DessinerPierresDeltaOfProperty);
      SetPort(oldPort);
    end;
end;

procedure DesssinePierresDelta(G : GameTree;surQuellesCases : SquareSet);
var oldPort : grafPtr;
begin  {$UNUSED surQuellesCases}
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      ItereSurPierresDelta(G,DessinerPierresDeltaOfProperty);
      SetPort(oldPort);
    end;
end;


procedure EffacerUnePierreDelta(var quelleCase : SInt16; var continuer : boolean);
begin
  continuer := true;
  if (quelleCase>=11) & (quelleCase<=88) then
    case jeuCourant[quelleCase] of
      pionVide  : if CassioEstEn3D() 
                    then 
                      begin
                        DessinePion3D(quelleCase,effaceCase);
                        {DessinePion3D(quelleCase,pionEntoureCasePourEffacerCoupEnTete);}
                      end
                    else DessinePion2D(quelleCase,pionVide);
      pionNoir  : if CassioEstEn3D()
                    then DessineDessusPion3D(quelleCase,pionNoir)
                    else 
                      begin
                        if not(gCouleurOthellier.estUneTexture) then 
                          DessinePion2D(quelleCase,pionEffaceCaseLarge);
                        DessinePion2D(quelleCase,pionNoir);
                      end;
      pionBlanc : if CassioEstEn3D()
                    then DessineDessusPion3D(quelleCase,pionBlanc)
                    else 
                      begin
                        if not(gCouleurOthellier.estUneTexture) then 
                          DessinePion2D(quelleCase,pionEffaceCaseLarge);
                        DessinePion2D(quelleCase,pionBlanc);
                      end;
    end;  {case}
end;

procedure EffacerPierresDeltaOfProperty(var prop : Property);
var whichSquare,whichSquare1,whichSquare2 : SInt16; 
    continuer : boolean;
begin
  {TraceLog('EffacerPierresDeltaOfProperty : entree');}
  case prop.stockage of
    StockageEnEnsembleDeCases : 
      begin
        ForEachSquareInPackedSetDo(GetPackedSquareSetOfProperty(prop),EffacerUnePierreDelta);
      end;
    StockageEnCaseOthello :
      begin
        whichSquare := GetOthelloSquareOfProperty(prop);
        EffacerUnePierreDelta(whichSquare,continuer);
      end;
    StockageEnCaseOthelloAlpha :
      begin
        whichSquare := GetOthelloSquareOfPropertyAlpha(prop);
        EffacerUnePierreDelta(whichSquare,continuer);
      end;
    StockageEnCoupleCases :
			begin
				GetSquareCoupleOfProperty(prop,whichSquare1,whichSquare2);
				{TraceLog('Effacage de la fleche : '+CoupEnString(whichSquare1,true)+'-'+CoupEnString(whichSquare2,true));}
				for whichSquare := 11 to 88 do
          if SegmentIntersecteRect(CentreDuRectangle(GetBoundingRectOfSquare(whichSquare1)),
                                    CentreDuRectangle(GetBoundingRectOfSquare(whichSquare2)),
                                    GetBoundingRectOfSquare(whichSquare))
            then 
              begin
                InvalidateDessinEnTraceDeRayon(whichSquare);
                EffacerUnePierreDelta(whichSquare,continuer);
                {TraceLog(Concat('la case ',CoupEnString(whichSquare,true),' est touchee'));}
              end;
			end;
  end; {case}
  {TraceLog('EffacerPierresDeltaOfProperty : sortie');}
end;

procedure EffacePierresDeltaCourantes;
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      ItereSurPierresDeltaCourantes(EffacerPierresDeltaOfProperty);
      SetPort(oldPort);
    end;
end;

procedure EffacePierresDelta(G : GameTree);
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      ItereSurPierresDelta(G,EffacerPierresDeltaOfProperty);
      SetPort(oldPort);
    end;
end;



procedure AddRandomDeltaStoneToCurrentNode;
var prop : Property;
    genre,coup,col,lig : SInt16; 
begin
  if false then
    begin
		  genre := RandomEntreBornes(DeltaWhiteProp,PetitCercleProp);
		  col  := RandomEntreBornes(1,8);
		  lig  := RandomEntreBornes(1,8);
		  coup := 10*lig+col;
		  prop := MakeSquareSetProperty(genre,[coup]);
		  AddPropertyToCurrentNode(prop);
		  DisposePropertyStuff(prop);
		end;
end;


const MenuFlottantDeltaID = 3005;
                          
var   menuFlottantDelta : MenuFlottantRec;


function MenuDeltaItemToPropertyType(item : SInt16) : SInt16; 
begin
  case item of
    1 :  MenuDeltaItemToPropertyType := InterestingMoveProp;
    2 :  MenuDeltaItemToPropertyType := DubiousMoveProp;
    3 :  MenuDeltaItemToPropertyType := ExoticMoveProp;
    {}
    5 :  MenuDeltaItemToPropertyType := DeltaBlackProp;
    6 :  MenuDeltaItemToPropertyType := DeltaWhiteProp;
    7 :  MenuDeltaItemToPropertyType := DeltaProp;
    {}
    9 :  MenuDeltaItemToPropertyType := LosangeBlackProp;
    10 :  MenuDeltaItemToPropertyType := LosangeWhiteProp;
    11 :  MenuDeltaItemToPropertyType := LosangeProp;
    {}
    13 :  MenuDeltaItemToPropertyType := CarreBlackProp;
    14 : MenuDeltaItemToPropertyType := CarreWhiteProp;
    15 : MenuDeltaItemToPropertyType := CarreProp;
    {}
    17 : MenuDeltaItemToPropertyType := PetitCercleBlackProp;
    18 : MenuDeltaItemToPropertyType := PetitCercleWhiteProp;
    19 : MenuDeltaItemToPropertyType := PetitCercleProp;
    {}
    21 : MenuDeltaItemToPropertyType := MarkedPointsProp;
    22 : MenuDeltaItemToPropertyType := EtoileProp;
    {}
    24 : MenuDeltaItemToPropertyType := ArrowProp;
    25 : MenuDeltaItemToPropertyType := LineProp;
    otherwise MenuDeltaItemToPropertyType := 0;
  end;
end;


procedure ChangePierresDeltaApresCommandClicSurOthellier(mouseLoc : Point;jeu : plateauOthello;forceAfficheMarquesSpeciales : boolean);
var whichSquare,destSquare,genre,genreVoulu,premiereMarqueDansMenu : SInt16; 
    typesPropertiesOnTheSquare : SetOfPropertyTypes;
    typesPropertiesDansLeFils : SetOfPropertyTypes;
    myMenuFlottantDelta:MenuFlottantRec;
    {myProp,}nouvelleProp : Property;
    thePenState:PenState;
    oldMouseLoc,clicLoc : Point;
    dessinee : boolean;
    taille_pointe_fleche : double_t;
    proprietesCourantes : PropertyList;
    proprietesDuFils : PropertyList;
    isNew : boolean;
    oldCurrentNode,fils : GameTree;
    err : OSErr;
    item : SInt16; 
    
    
    procedure MofifiePropertyListSiNecessaire(var L : PropertyList);
    var bidon : boolean;
    begin
      if (item in myMenuFlottantDelta.checkedItems) 
        then
          begin
            if not(ExistsInPropertyList(nouvelleProp,L)) then 
              AddPropertyToList(nouvelleProp,L);
          end
        else
          begin
            if ExistsInPropertyList(nouvelleProp,L) 
              then
                begin
                  DeletePropertyFromList(nouvelleProp,L);
                  EffacerPierresDeltaOfProperty(nouvelleProp);
                  if InPropertyTypes(genreVoulu,[InterestingMoveProp,DubiousMoveProp,ExoticMoveProp]) & (fils <> NIL) then
                    EffacerUnePierreDelta(whichSquare,bidon);
                end
              else
                begin
                  AddPropertyToList(nouvelleProp,L);
                end;
          end;
    end;
    
    
begin {ChangePierresDeltaApresCommandClicSurOthellier}
  {$UNUSED jeu}
  clicLoc := mouseLoc;
  if PtInPlateau(clicLoc,whichSquare) then
    begin
    
    
      myMenuFlottantDelta := NewMenuFlottant(MenuFlottantDeltaID,MakeRect(clicLoc.h-30,clicLoc.v-5,clicLoc.h-30,clicLoc.v+15),0);
      InstalleMenuFlottant(myMenuFlottantDelta,NIL);
      
      
    
      GetPropertyListOfCurrentNode(proprietesCourantes);
      typesPropertiesOnTheSquare := GetTypesOfPropertyOnthatSquare(whichSquare,proprietesCourantes);
      {WritelnStringAndPropertyListDansRapport('sur la case '+CoupEnStringEnMajuscules(whichSquare)+', liste de proprietés = ',propertiesOnTheSquare);
      }
      
      fils := NIL;
      proprietesDuFils := NIL;
      
      if PeutJouerIci(aQuiDeJouer,whichSquare,jeu) then
        begin
          oldCurrentNode := GetCurrentNode();
          err := ChangeCurrentNodeAfterThisMove(whichSquare,aQuiDeJouer,'ChangePierresDeltaApresCommandClicSurOthellier',isNew);
          if (err=0) then
            begin
              fils := GetCurrentNode();
              {if isNew then MarquerCeNoeudCommeVirtuel(fils);}
              if (fils <> NIL) then proprietesDuFils := fils^.properties;
            end;
          SetCurrentNode(oldCurrentNode);
        end;
      typesPropertiesDansLeFils := CalculatePropertyTypes(proprietesDuFils);
      
      
      
      premiereMarqueDansMenu := 0;
      with myMenuFlottantDelta do
      for item := 1 to MyCountMenuItems(theMenu) do
        begin
          genre := MenuDeltaItemToPropertyType(item);
          if (genre <> 0) then
            begin
              if InPropertyTypes(genre,[InterestingMoveProp,DubiousMoveProp,ExoticMoveProp])
                then
                  begin
                    if (fils = NIL) 
                      then MyDisableItem(theMenu,item)
                      else
                        if genre in typesPropertiesDansLeFils then
                          begin
                            checkedItems := checkedItems + [item];
                            MyCheckItem(theMenu, item, true);
                            if premiereMarqueDansMenu=0 then premiereMarqueDansMenu := item;
                          end;
                  end
                else
                  begin
                    if genre in typesPropertiesOnTheSquare then
                      begin
                        checkedItems := checkedItems + [item];
                        MyCheckItem(theMenu, item, true);
                        if premiereMarqueDansMenu=0 then premiereMarqueDansMenu := item;
                      end;
                  end;
            end;
        end;
      if premiereMarqueDansMenu <> 0 
        then myMenuFlottantDelta.theItem := premiereMarqueDansMenu {ouvrir le menu sur cette ligne}
        else myMenuFlottantDelta.theItem := derniereLigneUtiliseeMenuFlottantDelta;  
        
        
      if forceAfficheMarquesSpeciales & not(affichePierresDelta)
        then DoChangeAffichePierresDelta;
      if not(affichePierresDelta) then MyDisableItem(myMenuFlottantDelta.theMenu,0);
      
      InitCursor;
      if not(EventPopUpItemMenuFlottant(myMenuFlottantDelta,false,false,true)) then
        myMenuFlottantDelta.theItem := 0;
      AjusteCurseur;
      
      if MenuDeltaItemToPropertyType(myMenuFlottantDelta.theItem) <> 0 then
        derniereLigneUtiliseeMenuFlottantDelta := myMenuFlottantDelta.theItem;
        
      genreVoulu := MenuDeltaItemToPropertyType(myMenuFlottantDelta.theItem);
      
      if (genreVoulu = 0) & (fils <> NIL) & isNew then
        DeleteThisSon(GetCurrentNode(),fils);
      
      if InPropertyTypes(genreVoulu,[ArrowProp,LineProp])
        then
	        begin
			      dessinee := false;
			      GetPenState(thePenState);
	          Pensize(3,3);
	          PenMode(patXor);
			      while not(Button()) do
			        begin
			          oldMouseLoc := mouseLoc;
			          GetMouse(mouseLoc);
			          if not(dessinee) | not(EqualPt(mouseLoc,oldMouseLoc)) then
			            begin
					          if dessinee then
					            begin
					              if genreVoulu = LineProp
					                then DessineLigne(clicLoc,oldMouseLoc)
					                else DessineFleche(clicLoc,oldMouseLoc,taille_pointe_fleche);
					              dessinee := false;
					            end;
					          if PtInPlateau(mouseLoc,destSquare) then
					            begin
					              with GetBoundingRectOfSquare(destSquare) do
					                taille_pointe_fleche := (bottom - top)*0.4;
					              if genreVoulu = LineProp
					                then DessineLigne(clicLoc,mouseLoc)
					                else DessineFleche(clicLoc,mouseLoc,taille_pointe_fleche);
					              dessinee := true;
					            end;
					        end;
					      oldMouseLoc := mouseLoc;
					      ShareTimeWithOtherProcesses(2);
			        end;
			      if dessinee then
	            begin
	              if genreVoulu = LineProp
	                then DessineLigne(clicLoc,oldMouseLoc)
	                else DessineFleche(clicLoc,oldMouseLoc,taille_pointe_fleche);
	            end;
	          SetPenState(thePenState);
	          ShareTimeWithOtherProcesses(2);
	          FlushEvents(MDownmask+MupMask,0); {pour supprimer les clics intempestifs}
			      if dessinee & (destSquare <> whichSquare)
			        then nouvelleProp := MakeSquareCoupleProperty(genreVoulu,whichSquare,destSquare)
			        else nouvelleProp := MakeEmptyProperty();
			    end
			  else
			    begin
			      if genreVoulu = 0
			        then nouvelleProp := MakeEmptyProperty()
			        else
			          if InPropertyTypes(genreVoulu,[InterestingMoveProp,DubiousMoveProp,ExoticMoveProp])
                  then nouvelleProp := MakeArgumentVideProperty(genreVoulu)
                  else nouvelleProp := MakeSquareSetProperty(genreVoulu,[whichSquare]);
			    end;
      
      
      with myMenuFlottantDelta do
      for item := 1 to MyCountMenuItems(theMenu) do
        begin
          genre := MenuDeltaItemToPropertyType(item);
          if (genre <> 0) & (genre = genreVoulu) then
            begin
              if InPropertyTypes(genreVoulu,[InterestingMoveProp,DubiousMoveProp,ExoticMoveProp])
                then MofifiePropertyListSiNecessaire(proprietesDuFils)
                else MofifiePropertyListSiNecessaire(proprietesCourantes);
            end;
        end;
      
      DesinstalleMenuFlottant(myMenuFlottantDelta);
      DisposePropertyStuff(nouvelleProp);
      
      SetPropertyListOfCurrentNode(proprietesCourantes);
      if (fils <> NIL) then fils^.properties := proprietesDuFils;
      
    end;
end;




end.