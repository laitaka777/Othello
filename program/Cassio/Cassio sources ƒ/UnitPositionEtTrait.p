UNIT UnitPositionEtTrait;



INTERFACE







USES UnitOth0, UnitDefinitionsPackedThorGame;


type  PositionEtTraitRec = 
        record
          position : plateauOthello;
          lazyTrait : record
                        leTrait : SInt32;
                        traitNaturel : SInt32;
                      end;
        end;


const kPartieOK=0;
      kPasErreur=0;  {synomyme}
      kPartieTropCourte=1;
      kPartieIllegale=2;


{ Fonctions de creation }
function MakePositionEtTrait(var position : plateauOthello;trait : SInt32) : PositionEtTraitRec;
function MakeEmptyPositionEtTrait() : PositionEtTraitRec;
function PositionEtTraitCourant() : PositionEtTraitRec;
function PositionEtTraitInitiauxStandard() : PositionEtTraitRec;
procedure SetTraitOfPosition(var position : PositionEtTraitRec;trait : SInt32);


{ Fonctions d'acces }
function SamePositionEtTrait(var pos1,pos2 : PositionEtTraitRec) : boolean;
function EstPositionEtTraitCourant(var position : PositionEtTraitRec) : boolean;
function NbPionsDeCetteCouleurDansPosition(couleur : SInt32; var position : plateauOthello) : SInt32;
function NbCasesVidesDansPosition(var position : plateauOthello) : SInt32;
function GetTraitOfPosition(var position : PositionEtTraitRec) : SInt32;
procedure AssertParamsOfPositionEtTrait(var position : PositionEtTraitRec;fonctionAppelante : str255);


{ Modifications de PositionEtTraitRec }
function UpdatePositionEtTrait(var positionEtTrait : PositionEtTraitRec;whichMove : SInt32) : boolean;
function RetournePionsPositionEtTrait(var positionEtTrait : PositionEtTraitRec;whichMove : SInt32) : SInt32;
function InverserCouleurPionsDansPositionEtTrait(const position : PositionEtTraitRec) : PositionEtTraitRec;


{ Traductions chaines <-> PositionEtTraitRec }
function PositionEtTraitEnString(var position : PositionEtTraitRec) : str255;
function ParsePositionEtTrait(s : str255; var positionEtTrait : PositionEtTraitRec) : boolean;
function PositionRapportEnPositionEtTrait(s : str255;couleur : SInt32) : PositionEtTraitRec;


{ Jouer une partie pour obtenir un PositionEtTraitRec }
function PositionEtTraitAfterMoveNumberAlpha(game : str255;numeroCoup : SInt32; var typeErreur : SInt32) : PositionEtTraitRec;
function PositionEtTraitAfterMoveNumber(var game : PackedThorGame; numeroCoup : SInt32; var typeErreur : SInt32) : PositionEtTraitRec;
function PositionEtTraitAfterMoveEnString(var game : PackedThorGame; numeroCoup : SInt32; var typeErreur : SInt32) : str255;



IMPLEMENTATION







USES UnitStrategie,UnitScannerOthellistique,UnitRapport,SNStrings,MyStrings,
     UnitNormalisation,UnitOth2,UnitMiniProfiler,UnitPackedThorGame;


const kTraitNonEncoreCalcule = -1256;


procedure AssertParamsOfPositionEtTrait(var position : PositionEtTraitRec;fonctionAppelante : str255);
begin
  if (position.lazyTrait.traitNaturel <> pionNoir) & 
     (position.lazyTrait.traitNaturel <> pionVide) &
     (position.lazyTrait.traitNaturel <> pionBlanc) &
     (position.lazyTrait.traitNaturel <> kTraitNonEncoreCalcule) then
    begin
      WritelnDansRapport('ASSERT ! traitNaturel dans AssertParamsOfPositionEtTrait, fonction appelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(position.position,position.lazyTrait.traitNaturel);
    end;
  
  if (position.lazyTrait.leTrait <> pionNoir) & 
     (position.lazyTrait.leTrait <> pionVide) &
     (position.lazyTrait.leTrait <> pionBlanc) &
     (position.lazyTrait.leTrait <> kTraitNonEncoreCalcule) then
    begin
      WritelnDansRapport('ASSERT! leTrait dans AssertParamsOfPositionEtTrait, fonction appelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(position.position,position.lazyTrait.leTrait);
    end;
end;


procedure ForceLazyCalculationOfTrait(var position : PositionEtTraitRec);
begin

  with position.lazyTrait do
    if (leTrait = kTraitNonEncoreCalcule) then
      begin
        if traitNaturel = pionVide then 
          begin
            WritelnDansRapport('WARNING : (traitNaturel = pionVide) dans ForceLazyCalculationOfTrait !');
            traitNaturel := pionNoir;
          end;
          
        if not(DoitPasserPlatSeulement(traitNaturel,position.position))
          then 
            begin
              leTrait := traitNaturel;
            end
          else
            if not(DoitPasserPlatSeulement(-traitNaturel,position.position))
              then leTrait := -traitNaturel
              else 
                begin
                  leTrait      := pionVide;  {game over}
                  traitNaturel := pionVide;
                end;
      end;
      
end;


function MakePositionEtTrait(var plat : plateauOthello;trait : SInt32) : PositionEtTraitRec;
var aux : PositionEtTraitRec;
begin
  aux.position               := plat;
  aux.lazyTrait.leTrait      := kTraitNonEncoreCalcule;
  aux.lazyTrait.traitNaturel := trait;
  
  if trait = pionVide then WritelnDansRapport('WARNING : (trait = pionVide) dans MakePositionEtTrait !');
  
  MakePositionEtTrait := aux;
end;


function MakeEmptyPositionEtTrait() : PositionEtTraitRec;
var aux : PositionEtTraitRec;
begin
  OthellierDeDepart(aux.position);
  aux.position[44] := pionVide;
  aux.position[45] := pionVide;
  aux.position[54] := pionVide;
  aux.position[55] := pionVide;
  aux.lazyTrait.leTrait      := pionVide;
  aux.lazyTrait.traitNaturel := pionVide;
  
  MakeEmptyPositionEtTrait := aux;
end;


function PositionEtTraitInitiauxStandard() : PositionEtTraitRec;
var aux : PositionEtTraitRec;
begin
  OthellierDeDepart(aux.position);
  aux.lazyTrait.leTrait      := pionNoir;
  aux.lazyTrait.traitNaturel := pionNoir;
  
  PositionEtTraitInitiauxStandard := aux;
end;


function PositionEtTraitCourant() : PositionEtTraitRec;
var aux : PositionEtTraitRec;
begin
  (*
  if (aQuiDeJouer = pionVide) then
    WritelnDansRapport('WARNING : (aQuiDeJouer = pionVide) dans PositionEtTraitCourant, fonction appelante = '+fonctionAppelante);
  *)
  
  if aQuiDeJouer = pionVide
    then
      begin
         aux.position               := jeuCourant;
         aux.lazyTrait.leTrait      := aQuiDeJouer;
         aux.lazyTrait.traitNaturel := aQuiDeJouer;
         
         PositionEtTraitCourant := aux;
      end
    else
      PositionEtTraitCourant := MakePositionEtTrait(jeuCourant,aQuiDeJouer);
end;


function SamePositionEtTrait(var pos1,pos2 : PositionEtTraitRec) : boolean;
var i : SInt32;
begin
  SamePositionEtTrait := false;
  
  for i := 0 to 99 do
    if (pos1.position[i] <> pos2.position[i]) then exit(SamePositionEtTrait);
  
  ForceLazyCalculationOfTrait(pos1);
  ForceLazyCalculationOfTrait(pos2);
  
  if (pos1.lazyTrait.leTrait <> pos2.lazyTrait.leTrait) then exit(SamePositionEtTrait);
  
  SamePositionEtTrait := true;
end;


function EstPositionEtTraitCourant(var position : PositionEtTraitRec) : boolean;
begin
  EstPositionEtTraitCourant := SamePositionEtTrait(position,PositionEtTraitCourant());
end;


function NbPionsDeCetteCouleurDansPosition(couleur : SInt32; var position : plateauOthello) : SInt32;
var aux,i,j : SInt32;
begin
  aux := 0;
  for i := 1 to 8 do
    for j := 1 to 8 do
      if position[i*10+j]=couleur then inc(aux);
  NbPionsDeCetteCouleurDansPosition := aux;
end;


function NbCasesVidesDansPosition(var position : plateauOthello) : SInt32;
var aux,i,j : SInt32;
begin
  aux := 0;
  for i := 1 to 8 do
    for j := 1 to 8 do
      if position[i*10+j] = pionVide then inc(aux);
  NbCasesVidesDansPosition := aux;
end;


function GetTraitOfPosition(var position : PositionEtTraitRec) : SInt32;
begin
  if (position.lazyTrait.leTrait = kTraitNonEncoreCalcule) then
    ForceLazyCalculationOfTrait(position);
  
  GetTraitOfPosition := position.lazyTrait.leTrait;
end;


procedure SetTraitOfPosition(var position : PositionEtTraitRec;trait : SInt32);
begin
  with position.lazyTrait do
    begin
      leTrait      := trait;
      traitNaturel := trait;
    end;
end;


function UpdatePositionEtTrait(var positionEtTrait : PositionEtTraitRec;whichMove : SInt32) : boolean;
var coupLegal : boolean;
begin
  if (whichMove < 11) | (whichMove > 88) | (positionEtTrait.lazyTrait.leTrait = pionVide) then
    begin
      UpdatePositionEtTrait := false;
      exit(UpdatePositionEtTrait);
    end;
  
  with positionEtTrait do
    begin
    
      if (position[whichMove] <> pionVide) then
        begin
          UpdatePositionEtTrait := false;
          exit(UpdatePositionEtTrait);
        end;
        
      if (lazyTrait.leTrait <> kTraitNonEncoreCalcule)
        then
          coupLegal := ModifPlatSeulement(whichMove,position,lazyTrait.leTrait)
        else
          begin
            (* Calcul lazy *)
            coupLegal := ModifPlatSeulement(whichMove,position,lazyTrait.traitNaturel);
            if coupLegal 
              then 
                lazyTrait.leTrait := lazyTrait.traitNaturel  {le trait naturel propose Žtait en fait le bon}
              else
                begin
                  ForceLazyCalculationOfTrait(positionEtTrait);
                  
                  if (lazyTrait.leTrait <> pionVide) then
                    coupLegal := ModifPlatSeulement(whichMove,position,lazyTrait.leTrait);
                end;
          end;
      
      if not(coupLegal) then
        begin
          UpdatePositionEtTrait := false;
          exit(UpdatePositionEtTrait);  
        end;
      
      {on met a jour le trait, en suspendant le glacon de l'evaluation lazy }
      lazyTrait.traitNaturel := -lazyTrait.leTrait;
      lazyTrait.leTrait      := kTraitNonEncoreCalcule;
        
    end;  {with positionEtTrait}
  
  UpdatePositionEtTrait := true;
end;


function RetournePionsPositionEtTrait(var positionEtTrait : PositionEtTraitRec;whichMove : SInt32) : SInt32;
var coupLegal : boolean;
    nbPionsRetournes : SInt32;
begin
  RetournePionsPositionEtTrait := 0;
  
  if (whichMove < 11) | (whichMove > 88) then
    begin
      RetournePionsPositionEtTrait := 0;
      exit(RetournePionsPositionEtTrait);
    end;
  
  ForceLazyCalculationOfTrait(positionEtTrait);
  
  if (positionEtTrait.lazyTrait.leTrait <> pionVide) then
    begin
    
      coupLegal := (positionEtTrait.position[whichMove] = pionVide) & 
                  ModifPlatPrise(whichMove,positionEtTrait.position,positionEtTrait.lazyTrait.leTrait,nbPionsRetournes);
                  
      if not(coupLegal) then
        begin
          RetournePionsPositionEtTrait := 0;
          exit(RetournePionsPositionEtTrait);
        end;
      
      with positionEtTrait do
        begin
          lazyTrait.traitNaturel := -lazyTrait.leTrait;
          lazyTrait.leTrait      := kTraitNonEncoreCalcule;
        end;
        
    end;
  
  RetournePionsPositionEtTrait := nbPionsRetournes;
end;


function PositionEtTraitEnString(var positionEtTrait : PositionEtTraitRec) : str255;
var i,j : SInt32;
    s : str255;
begin
  s := '';
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        case positionEtTrait.position[i*10+j] of
          pionNoir : s := s+'X';
          pionBlanc : s := s+'O';
          pionVide : s := s+'-';
          otherwise s := s+'-';
        end;
      end;
  s := s+'   ';
  case GetTraitOfPosition(positionEtTrait) of
    pionNoir : s := s+'X';
    pionBlanc : s := s+'O';
    pionVide : s := s+'-';
    otherwise s := s+'-';
  end;
  PositionEtTraitEnString := s;
end;


function ParsePositionEtTrait(s : str255; var positionEtTrait : PositionEtTraitRec) : boolean;
var i,j,aux : SInt32;
    s1,s2,s3,reste : str255;
begin
  ParsePositionEtTrait := false;
  
  EnleveEspacesDeGaucheSurPlace(s);
  Parser3(s,s1,s2,s3,reste);
  
  {WritelnDansRapport('s='+s);
  WritelnDansRapport('s1='+s1);
  WritelnDansRapport('s2='+s2);
  WritelnDansRapport('s3='+s3);}
  
  if Length(s1)<>64 then 
    begin
      WritelnDansRapport('parse error 1 in ParsePositionEtTrait !');
      exit(ParsePositionEtTrait);
    end;
  positionEtTrait := PositionEtTraitInitiauxStandard();
  aux := 1;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        case s1[aux] of
          'X','*','x','¥','b'       : positionEtTrait.position[i*10+j] := pionNoir;
          'O','0','o','w'           : positionEtTrait.position[i*10+j] := pionBlanc;
          '-','.','_','Ð','Ñ','e'   : positionEtTrait.position[i*10+j] := pionVide;
          otherwise
            begin
              WritelnDansRapport('parse error 2 in ParsePositionEtTrait !');
              exit(ParsePositionEtTrait);
            end;
        end;
        inc(aux);
      end;
  
  if Length(s2)<=0 then 
    begin
      WritelnDansRapport('parse error 3 in ParsePositionEtTrait !');
      exit(ParsePositionEtTrait);
    end;
    
  positionEtTrait.lazyTrait.leTrait := kTraitNonEncoreCalcule;
  case s2[1] of
    'X','*','x','¥','b'       : positionEtTrait.lazyTrait.traitNaturel := pionNoir;
    'O','0','o','w'           : positionEtTrait.lazyTrait.traitNaturel := pionBlanc;
    '-','.','_','Ð','Ñ','e'   : positionEtTrait.lazyTrait.traitNaturel := pionVide;
    otherwise
      begin
        WritelnDansRapport('parse error 4 in ParsePositionEtTrait !');
        exit(ParsePositionEtTrait);
      end;
  end;
  
  ParsePositionEtTrait := true;
end;


function InverserCouleurPionsDansPositionEtTrait(const position : PositionEtTraitRec) : PositionEtTraitRec;
var result : PositionEtTraitRec;
    t : SInt32;
begin
  result := position;
  
  for t := 11 to 88 do
    begin
      if result.position[t] = pionNoir then result.position[t]  := pionBlanc else
      if result.position[t] = pionBlanc then result.position[t] := pionNoir;
    end;
    
  InverserCouleurPionsDansPositionEtTrait := result;
end;


function PositionRapportEnPositionEtTrait(s : str255;couleur : SInt32) : PositionEtTraitRec;
var c : char;
    result : PositionEtTraitRec;
    k,i,j,longueur,compteur : SInt32;
begin
  
  result := PositionEtTraitInitiauxStandard();
  

  longueur := Length(s);
  i := 1; 
  j := 1;
  compteur := 0;
  for k := 1 to longueur do
    begin
      c := s[k];
      if (compteur < 64) then
	      case c of
	        'X','*','x','#','¥' : 
	          begin
	            result.position[10*j+i] := pionNoir;
	            inc(i);
	            inc(compteur);
	          end;
	        '0','O','o' : 
	          begin
	            result.position[10*j+i] := pionBlanc;
	            inc(i);
	            inc(compteur);
	          end;
	        '-','.','_','Ð','Ñ' : 
	          begin
	            result.position[10*j+i] := pionVide;
	            inc(i);
	            inc(compteur);
	          end;
	      end; {case}
      if (i>8) then
        begin
          i := 1;
          inc(j);
        end;
    end;
  
  
  if (compteur >= 64)
    then 
      begin
        result.lazyTrait.leTrait      := pionVide;
        result.lazyTrait.traitNaturel := pionVide;
      end
    else
      begin
        result.lazyTrait.leTrait := kTraitNonEncoreCalcule;
        case couleur of
          pionNoir,pionVide,pionBlanc :  
            result.lazyTrait.traitNaturel := couleur;
          otherwise      
            result.lazyTrait.traitNaturel := pionVide;
        end; {case}
      end;
  
  PositionRapportEnPositionEtTrait := result;
end;


function PositionEtTraitAfterMoveNumber(var game : PackedThorGame; numeroCoup : SInt32; var typeErreur : SInt32) : PositionEtTraitRec;
var s255 : str255;
    result : PositionEtTraitRec;
    i : SInt32;
begin
  typeErreur := kPartieOK;
  PositionEtTraitAfterMoveNumber := PositionEtTraitInitiauxStandard();
  
  TraductionThorEnAlphanumerique(game,s255);
  if (Length(s255) < numeroCoup*2) then
    begin
      typeErreur := kPartieTropCourte;
      exit(PositionEtTraitAfterMoveNumber);
    end;
  if not(EstUnePartieOthello(s255,true)) then
    begin
      typeErreur := kPartieIllegale;
      exit(PositionEtTraitAfterMoveNumber);
    end;
  result := PositionEtTraitInitiauxStandard();
  for i := 1 to numeroCoup do
    if not(UpdatePositionEtTrait(result,GET_NTH_MOVE_OF_PACKED_GAME(game,i,'PositionEtTraitAfterMoveNumber'))) then
      begin
        typeErreur := kPartieIllegale;
        exit(PositionEtTraitAfterMoveNumber);
      end;
  PositionEtTraitAfterMoveNumber := result;
end;


function PositionEtTraitAfterMoveNumberAlpha(game : str255;numeroCoup : SInt32; var typeErreur : SInt32) : PositionEtTraitRec;
var s60 : PackedThorGame; 
begin
  if EstUnePartieOthello(game,true) 
    then
      begin
        TraductionAlphanumeriqueEnThor(game,s60);
        PositionEtTraitAfterMoveNumberAlpha := PositionEtTraitAfterMoveNumber(s60,numeroCoup,typeErreur);
      end
    else
      begin
        typeErreur := kPartieIllegale;
        PositionEtTraitAfterMoveNumberAlpha := PositionEtTraitInitiauxStandard();
      end;
end;


function PositionEtTraitAfterMoveEnString(var game : PackedThorGame; numeroCoup : SInt32; var typeErreur : SInt32) : str255;
var positionEtTrait : PositionEtTraitRec;
begin
  positionEtTrait := PositionEtTraitAfterMoveNumber(game,numeroCoup,typeErreur);
  
  if typeErreur=kPasErreur 
    then PositionEtTraitAfterMoveEnString := PositionEtTraitEnString(positionEtTrait)
    else PositionEtTraitAfterMoveEnString := '';
end;







END.

































