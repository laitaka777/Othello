UNIT UnitNormalisation;





INTERFACE







USES UnitOth0, UnitDefinitionsPackedThorGame; 



{ Orientation d'un coup ou d'une suite de coups suivant le coup 1 courant}
procedure TransposeCoupPourOrientation(var whichSquare : SInt16; autreCoupQuatreDiagonal : boolean);  
procedure TransposePartiePourOrientation(var partie60 : PackedThorGame; autreCoupQuatreDiagonal : boolean;minCoupTrampose,maxCoupTrampose : SInt32);


{ Normalisations diverses, en particulier pour la base WThor }
function PartieNormalisee(var autreCoupQuatreDiag : boolean;interversions : boolean):str120;
procedure Normalisation(var partie120:str120; var autreCoupQuatreDiag : boolean;interversions : boolean);
function NormaliserLaPartiePourInclusionDansLaBaseWThor(const partieEnAlpha:str120):str120;
procedure ExtraitPremierCoup(var premierCoup : SInt16; var autreCoupQuatreDiag : boolean);
function PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6() : boolean;


{ Gestion du premier coup affiche dans la liste de parties }
function GetPremierCoupParDefaut() : SInt32;
procedure SetPremierCoupParDefaut(coup : SInt32);


{ Fonctions de symetries }
procedure EffectueSymetrieAxeNW_SE(var plat : plateauOthello);
procedure EffectueSymetrieAxeNE_SW(var plat : plateauOthello);
function CaseSymetrique(whichSquare : SInt16; axeSymetrie : SInt32) : SInt16; 
procedure SymetriserPartieFormatThor(var s60 : PackedThorGame; axeSymetrie : SInt32; debut,fin : SInt32);
procedure SymetriserPartieFormatAlphanumerique(var s : str255;axeSymetrie : SInt32; debut,fin : SInt32);
procedure EffectueSymetrieOnSquare(var whichSquare : SInt16; var axeSymetrie : SInt32; var continuer : boolean);


{ Extractions pour le presse-papier }
function PartiePourPressePapier(enMajuscules,avecEspaceEntreCoups : boolean;nbreCoupsAExporter : SInt16) : str255;
function PositionInitialeEnLignePourPressePapier() : str255;
function PositionCouranteEnDiagrammeTEXTPourPressePapier() : str255;
function DiagrammePartieEnTEXTPourPressePapier(avecCoordonnees : boolean;DelimiteurVertical,SeparateurDeCoups : str255) : str255;


{ Une petite gestion de numeros d'ouvertures (tres basique) }
function NroOuverture(var s:packed7) : byte;
procedure IntervaleOuverture_6(var s:packed7; var minimum,maximum : byte);
procedure IntervaleOuverture_5(var s:packed7; var minimum,maximum : byte);
procedure IntervaleOuverture_4(var s:packed7; var minimum,maximum : byte);
procedure IntervaleOuverture_3(var s:packed7; var minimum,maximum : byte);
procedure IntervaleOuverture_2(var s:packed7; var minimum,maximum : byte);
procedure DetermineIntervaleOuverture(var ouv:packed7;longueur : SInt16; var minimum,maximum : byte);
function EstDansTableOuverture(nom : str255; var nroDansTable : SInt16) : boolean;



IMPLEMENTATION







USES MyStrings,UnitOth1,UnitStrategie,UnitAfficheArbreDeJeuCourant,UnitPositionEtTrait,MyMathUtils,
     UnitRapport,UnitInterversions,UnitArbreDeJeuCourant,UnitScannerOthellistique,SNStrings,
     UnitServicesMemoire,TextUtils,UnitJeu,UnitPackedThorGame;
     

var premierCoupParDefautDansListe : SInt32;




procedure TransposeCoupPourOrientation(var whichSquare : SInt16; autreCoupQuatreDiagonal : boolean);
var premierCoupParDefaut : SInt32;
  begin
    premierCoupParDefaut := GetPremierCoupParDefaut();
    if (GetNiemeCoupPartieCourante(1)=65) | (premierCoupParDefaut = 65) then whichSquare := 10*platMod10[whichSquare]+platDiv10[whichSquare] else 
    if (GetNiemeCoupPartieCourante(1)=43) | (premierCoupParDefaut = 43) then whichSquare := 10*(9-platDiv10[whichSquare])+9-platMod10[whichSquare] else 
    if (GetNiemeCoupPartieCourante(1)=34) | (premierCoupParDefaut = 34) then whichSquare := 10*(9-platMod10[whichSquare])+9-platDiv10[whichSquare];
    if autreCoupQuatreDiagonal then whichSquare := 10*platMod10[whichSquare]+platDiv10[whichSquare];
  end;


procedure TransposePartiePourOrientation(var partie60 : PackedThorGame; autreCoupQuatreDiagonal : boolean; minCoupTranspose,maxCoupTranspose : SInt32);
var i,whichSquare,longueur : SInt16; 
    premierCoupParDefaut : SInt32;
  begin
    longueur := GET_LENGTH_OF_PACKED_GAME(partie60);
    premierCoupParDefaut := GetPremierCoupParDefaut();
    if (GetNiemeCoupPartieCourante(1)=65) | (premierCoupParDefaut = 65)
      then 
        for i := 1 to longueur do
          begin
            whichSquare := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'TransposePartiePourOrientation(1)');
            whichSquare := 10*platMod10[whichSquare]+platDiv10[whichSquare];
            SET_NTH_MOVE_OF_PACKED_GAME(partie60, i, whichSquare);
          end
      else 
        if (GetNiemeCoupPartieCourante(1)=43) | (premierCoupParDefaut = 43)
          then 
            for i := 1 to longueur do
              begin
                whichSquare := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'TransposePartiePourOrientation(2)');
                whichSquare := 10*(9-platDiv10[whichSquare])+9-platMod10[whichSquare];
                SET_NTH_MOVE_OF_PACKED_GAME(partie60, i, whichSquare);
              end
             else 
               if (GetNiemeCoupPartieCourante(1)=34) | (premierCoupParDefaut = 34)
                 then 
                  for i := 1 to longueur do
                    begin
                      whichSquare := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'TransposePartiePourOrientation(3)');
                      whichSquare := 10*(9-platMod10[whichSquare])+9-platDiv10[whichSquare];
                      SET_NTH_MOVE_OF_PACKED_GAME(partie60, i, whichSquare);
                    end;
    if autreCoupQuatreDiagonal & 
       (minCoupTranspose >= 1) & (minCoupTranspose <= 60) &
       (maxCoupTranspose >= 1) & (maxCoupTranspose <= 60) then
        begin
          for i := Min(minCoupTranspose,longueur) to Min(maxCoupTranspose,longueur) do
            begin
              whichSquare := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'TransposePartiePourOrientation(4)');
              whichSquare := 10*platMod10[whichSquare]+platDiv10[whichSquare];
              SET_NTH_MOVE_OF_PACKED_GAME(partie60 , i, whichSquare);
            end;
        end;
  end;



function PartieNormalisee(var autreCoupQuatreDiag : boolean;interversions : boolean):str120;
var s:str120;
    i,coup : SInt16; 
    charAux : char;
    premierCoupParDefaut : SInt32;
begin
  s := '';
  premierCoupParDefaut := GetPremierCoupParDefaut();
  autreCoupQuatreDiag := false;
  if nbreCoup>0 then
    begin
      if (GetNiemeCoupPartieCourante(1)=56) | (premierCoupParDefaut = 56) then
       for i := 1 to nbreCoup do
         begin       
           coup := GetNiemeCoupPartieCourante(i);
           s := s+CoupEnStringEnMajuscules(coup);
         end
       else
        if (GetNiemeCoupPartieCourante(1)=65) | (premierCoupParDefaut = 65) then
          for i := 1 to nbreCoup do
           begin
             coup := GetNiemeCoupPartieCourante(i);
             s := s+CHR(64+platDiv10[coup])+CHR(48+platmod10[coup]);
           end
          else
           if (GetNiemeCoupPartieCourante(1)=43) | (premierCoupParDefaut = 43) then
             for i := 1 to nbreCoup do
             begin
               coup := GetNiemeCoupPartieCourante(i);
               s := s+CHR(73-(platmod10[coup]))+CHR(57-(platDiv10[coup]));
             end
            else
             if (GetNiemeCoupPartieCourante(1)=34) | (premierCoupParDefaut = 34) then
              for i := 1 to nbreCoup do
                begin
                 coup := GetNiemeCoupPartieCourante(i);
                 s := s+CHR(73-(platDiv10[coup]))+CHR(57-(platmod10[coup]));
                end;
       if nbreCoup>=4 then
         begin
           if Pos('F5F6E6D6',s)=1 then
             begin
               autreCoupQuatreDiag := true;
               for i := 4 to nbreCoup do
                 begin
                   charAux := chr(ord(s[2*i-1])-16);
                   s[2*i-1] := chr(ord(s[2*i])+16);
                   s[2*i] := charAux;
                 end;
             end;
         end 
    end;
    if interversions 
      then 
        begin
          TraiteIntervertionsCoups(s);
          if nbreCoup>=4 then
               begin
                 if Pos('F5F6E6D6',s)=1 then
                   begin
                     autreCoupQuatreDiag := not(autreCoupQuatreDiag);
                     for i := 4 to nbreCoup do
                       begin
                         charAux := chr(ord(s[2*i-1])-16);
                         s[2*i-1] := chr(ord(s[2*i])+16);
                         s[2*i] := charAux;
                       end;
                   end;
               end;
        end;
    PartieNormalisee := s;
end;

procedure ExtraitPremierCoup(var premierCoup : SInt16; var autreCoupQuatreDiag : boolean);
var premierCoupParDefaut : SInt32;
begin
  premierCoup := 0;
  autreCoupQuatreDiag := false;
  premierCoupParDefaut := GetPremierCoupParDefaut();
  if nbreCoup > 0 then
    begin
      if (GetNiemeCoupPartieCourante(1)=56) | (premierCoupParDefaut = 56)
        then begin
          premierCoup := 56;
          autreCoupQuatreDiag := (GetNiemeCoupPartieCourante(2)=66) & (GetNiemeCoupPartieCourante(3)=65) & (GetNiemeCoupPartieCourante(4)=64);
        end else
      if (GetNiemeCoupPartieCourante(1)=65) | (premierCoupParDefaut = 65)
        then begin
          premierCoup := 65;
          autreCoupQuatreDiag := (GetNiemeCoupPartieCourante(2)=66) & (GetNiemeCoupPartieCourante(3)=56) & (GetNiemeCoupPartieCourante(4)=46);
        end else
      if (GetNiemeCoupPartieCourante(1)=43) | (premierCoupParDefaut = 43)
        then begin
          premierCoup := 43;
          autreCoupQuatreDiag := (GetNiemeCoupPartieCourante(2)=33) & (GetNiemeCoupPartieCourante(3)=34) & (GetNiemeCoupPartieCourante(4)=35);
        end else
      if (GetNiemeCoupPartieCourante(1)=34) | (premierCoupParDefaut = 34)
        then begin
          premierCoup := 34;
          autreCoupQuatreDiag := (GetNiemeCoupPartieCourante(2)=33) & (GetNiemeCoupPartieCourante(3)=43) & (GetNiemeCoupPartieCourante(4)=53);
        end;
    end; 
end;

function PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6() : boolean;
var premierCoup : SInt16; 
    autreCoupDiagonale : boolean;
begin
  ExtraitPremierCoup(premierCoup,autreCoupDiagonale);
  PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6 := autreCoupDiagonale;
end;

procedure Normalisation(var partie120:str120; var autreCoupQuatreDiag : boolean;interversions : boolean);
var s:str120;
    i,coup : SInt16; 
    charAux : char;
    longueurPartie : SInt16; 
begin
  s := '';
  longueurPartie := Length(partie120) div 2;
  autreCoupQuatreDiag := false;
  if longueurPartie>0 then
    begin
      if  (partie120[1]='F') & (partie120[2]='5') then
        begin
          s := partie120;
        end
       else
        if (partie120[1]='E') & (partie120[2]='6') then
          for i := 1 to longueurPartie do
           begin
             coup := ord(partie120[2*i-1])-64 + 10*(ord(partie120[2*i])-48);
             s := s+CHR(64+platdiv10[coup])+CHR(48+platmod10[coup]);
           end
          else
           if (partie120[1]='C') & (partie120[2]='4') then
             for i := 1 to longueurPartie do
             begin
               coup := ord(partie120[2*i-1])-64 + 10*(ord(partie120[2*i])-48);
               s := s+CHR(73-(platmod10[coup]))+CHR(57-(platdiv10[coup]));
             end
            else
             if (partie120[1]='D') & (partie120[2]='3') then
              for i := 1 to longueurPartie do
                begin
                 coup := ord(partie120[2*i-1])-64 + 10*(ord(partie120[2*i])-48);
                 s := s+CHR(73-(platdiv10[coup]))+CHR(57-(platmod10[coup]));
                end;
       if longueurPartie>=4 then
         begin
           if Pos('F5F6E6D6',s)=1 then
             begin
               autreCoupQuatreDiag := true;
               for i := 4 to longueurPartie do
                 begin
                   charAux := chr(ord(s[2*i-1])-16);
                   s[2*i-1] := chr(ord(s[2*i])+16);
                   s[2*i] := charAux;
                 end;
             end;
         end 
    end;
    if interversions 
      then 
        begin
          TraiteIntervertionsCoups(s);
          if (longueurPartie >= 4) & (Pos('F5F6E6D6',s) = 1) then
            begin
               autreCoupQuatreDiag := true;
               for i := 4 to longueurPartie do
                 begin
                   charAux := chr(ord(s[2*i-1])-16);
                   s[2*i-1] := chr(ord(s[2*i])+16);
                   s[2*i] := charAux;
                 end;
             end;
        end;
    partie120 := s;
end;


{ NormaliserLaPartiePourInclusionDansLaBaseWThor suppose que la partie 
  commence en F5 (c'est le cas par exemple si on a appelle la procedure 
  "Normalisation" ci-dessus avant d'appeler cette fonction) }
function NormaliserLaPartiePourInclusionDansLaBaseWThor(const partieEnAlpha:str120):str120;
var s : str255;
    longueurPartie : SInt32;
begin
  s := partieEnAlpha;
  longueurPartie := Length(s) div 2;
  
  { Diagonale }
  if (longueurPartie >= 4) & (Pos('F5F6E6D6',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,4,longueurPartie);
  
  { Heath Cheminee Diagonale }
  if (longueurPartie >= 8) & (Pos('F5F6E6F4G5D6E7F7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,8,longueurPartie);
  
  { Coup 6 bizarre sur la Rose }
  if (longueurPartie >= 8) & (Pos('F5D6C5F4E3C3E6F2',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,8,longueurPartie);
  
  if (longueurPartie >= 8) & (Pos('F5D6C5F4E3C3E6D2',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,8,longueurPartie);
  
  { Coup 6 bizarre sur la Rose, un coup plus loin }
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C3E6F6C4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C3E6F6D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C3E6F6E7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C3E6F6F7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);
  
  { Inoue }
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3C4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3B7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3C7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3E7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);
  
  { Ball }
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6C3',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6B4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6B5',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6C6',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);
  
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);
    
  { Position de Cedric }
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B3',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B5',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B6',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6C7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
    
  { Position de Cedric, par interversion }
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B3',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B5',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B6',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6C7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);
  
  NormaliserLaPartiePourInclusionDansLaBaseWThor := s;
end;


function PartiePourPressePapier(enMajuscules,avecEspaceEntreCoups : boolean;nbreCoupsAExporter : SInt16) : str255;
var s : str255;
    i,coup : SInt16; 
begin
  s := '';
  if (nroDernierCoupAtteint > 0) then
   for i := 1 to Min(nbreCoupsAExporter,nroDernierCoupAtteint) do
     begin
       coup := GetNiemeCoupPartieCourante(i);
       if coup>0 then 
         begin
           if enMajuscules
             then s := s+CHR(64+coup mod 10)+CHR(48+coup div 10)
             else s := s+CHR(96+coup mod 10)+CHR(48+coup div 10);
           if avecEspaceEntreCoups then s := s+StringOf(' ');
         end;
     end;
    PartiePourPressePapier := s;
end;

function PositionInitialeEnLignePourPressePapier() : str255;
var i,j,x : SInt16; 
    s : str255;
    plat : plateauOthello;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
begin
  s := '';
  GetPositionInitialeOfGameTree(plat,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        x := plat[10*i+j];
        if x = pionBlanc 
          then s := s+StringOf('o')
          else if x = pionNoir 
                 then s := s + StringOf('x')
                 else s := s + StringOf('.');
      end;
    PositionInitialeEnLignePourPressePapier := s;
end;


function PositionCouranteEnDiagrammeTEXTPourPressePapier() : str255;
var s : str255;
    i,j,x : SInt16; 
begin
  s := '  A B C D E F G H  ';
  s := s+chr(13);
  for j := 1 to 8 do
    begin
      s := s+NumEnString(j)+' ';
      for i := 1 to 8 do
        begin       
	        x := jeuCourant[10*j+i];
	        if x = pionNoir then s := s+'* ' else
	        if x = pionBlanc then s := s+'O ' else
	        if x = pionVide then s := s+'- ';
	      end;
	    s := s+NumEnString(j)+' '+chr(13);
    end;
  s := s+'  A B C D E F G H  ';
  s := s+chr(13); 
  PositionCouranteEnDiagrammeTEXTPourPressePapier := s;
end;


function DiagrammePartieEnTEXTPourPressePapier(avecCoordonnees : boolean;DelimiteurVertical,SeparateurDeCoups : str255) : str255;
var i,j,t,x : SInt16; 
    s,s1,s2 : str255;
    positionInitiale : plateauOthello;
    coups : plateauOthello;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
begin
  
  GetPositionInitialeOfGameTree(positionInitiale,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
  
  MemoryFillChar(@coups,sizeof(coups),chr(0));
  for t := 1 to nbreCoup do
    begin
      x := GetNiemeCoupPartieCourante(t);
      if x>0 then coups[x] := t;
    end;
  
  s := '';
  if avecCoordonnees 
    then s := s+'   A  B  C  D  E  F  G  H'+chr(13);
  for j := 1 to 8 do
    begin
      if avecCoordonnees then s := s+NumEnString(j)+' ';
      s := s+DelimiteurVertical;
      for i := 1 to 8 do
	      begin
	        t := 10*j+i;
	        if positionInitiale[t] <> pionVide 
	          then
	            begin
	              if positionInitiale[t] = pionBlanc then s := s+'()' else
	              if positionInitiale[t] = pionNoir  then s := s+'##'
	                else s := s+'  ';
	            end
	          else
	            begin
	              x := coups[t];
	              if x<=0 then s := s+'  ' else
	              if x<10 then s := s+' '+NumEnString(x) else
	              if x<=99 then s := s+NumEnString(x)
	                else s := s+'  ';
	            end;
	        if (i<=7) then s := s+SeparateurDeCoups;
	      end;
	    s := s+DelimiteurVertical;
	    s := s+chr(13);
    end;
    
  {titre : soit les joueurs si on les connait, sinon le score seul}
  with ParamDiagPartieFFORUM do
    if gameOver & (titreFForum <> NIL) & (titreFForum^^<>'')
      then
        begin
          s1 := titreFForum^^;
        end
      else 
        begin
          NumToString(nbreDePions[pionNoir],s1);
          NumToString(nbreDePions[pionBlanc],s2);
          s1 := s1+StringOf('-')+s2;
        end;
  for t := 1 to ((25-Length(s1)) div 2) do s1 := Concat(' ',s1);  {pour centrer}
  s := s+s1+chr(13);
  
  DiagrammePartieEnTEXTPourPressePapier := s;
end;



 { donne un numero au debut de partie dans s.
   Le premier coup est suppos� etre en F5}
function NroOuverture(var s:packed7) : byte;
begin
  if s[2]=66 then begin                           {diagonale}
    if s[3]=65 then begin  
      if s[4]=46 then begin  
        if s[5]=35 then begin
          if s[6]=53 then begin
            if s[7]=43 then NroOuverture := 1 else
            if s[7]=57 then NroOuverture := 2 else
            NroOuverture := 3 end else
          if s[6]=64 then begin
            if s[7]=43 then NroOuverture := 4 else
            NroOuverture := 5 end else
          NroOuverture := 6 end else
        if s[5]=57 then begin
          if s[6]=75 then begin
            if s[7]=76 then NroOuverture := 7 else
            if s[7]=35 then NroOuverture := 8 else
            NroOuverture := 9 end else 
          if s[6]=64 then begin
            if s[7]=75 then NroOuverture := 10 else
            NroOuverture := 11 end else
          NroOuverture := 12 end else
        if s[5]=33 then begin
          if s[6]=64 then begin
            if s[7]=36 then NroOuverture := 13 else
            NroOuverture := 14 end else
          if s[6]=74 then begin
            if s[7]=36 then NroOuverture := 15 else
            NroOuverture := 16 end else
          NroOuverture := 17 end else
        if s[5]=67 then begin
          if s[6]=64 then begin
            if s[7]=47 then NroOuverture := 18 else
            NroOuverture := 19 end else
          if s[6]=53 then begin
            if s[7]=47 then NroOuverture := 20 else
            NroOuverture := 21 end else
          NroOuverture := 22 end else
        if s[5]=77 then NroOuverture := 23 else  
        if s[5]=34 then NroOuverture := 24 else   
        if s[5]=36 then NroOuverture := 25 else
        if s[5]=37 then NroOuverture := 26 else
        NroOuverture := 27 end else 
      NroOuverture := 28 end else 
    NroOuverture := 29 end else
  if s[2]=64 then begin                         {perpendiculaire}
    if s[3]=53 then begin
      if s[4]=46 then begin
        if s[5]=35 then begin
          if s[6]=63 then begin
            if s[7]=34 then NroOuverture := 30 else
            if s[7]=36 then NroOuverture := 31 else
            if s[7]=65 then NroOuverture := 32 else
            if s[7]=74 then NroOuverture := 33 else
            NroOuverture := 34 end else
          if s[6]=66 then begin
            if s[7]=36 then NroOuverture := 35 else
            NroOuverture := 36 end else
          NroOuverture := 37 end else
        if s[5]=34 then begin
          if s[6]=35 then NroOuverture := 38 else
          if s[6]=43 then NroOuverture := 39 else
          NroOuverture := 40 end else
        if s[5]=74 then NroOuverture := 41 else
        NroOuverture := 42 end else
      NroOuverture := 43 end else
    if s[3]=33 then begin
      if s[4]=34 then begin
        if s[5]=43 then begin
          if s[6]=46 then begin
            if s[7]=66 then NroOuverture := 44 else
            if s[7]=53 then NroOuverture := 45 else
            if s[7]=35 then NroOuverture := 46 else
            if s[7]=65 then NroOuverture := 47 else
            NroOuverture := 48 end else
          if s[6]=32 then NroOuverture := 49 else
          NroOuverture := 50 end else
        NroOuverture := 51 end else
      if s[4]=46 then begin
        if s[5]=66 then NroOuverture := 52 else
        if s[5]=65 then NroOuverture := 53 else
        NroOuverture := 54 end else
      if s[4]=57 then begin
        if s[5]=63 then NroOuverture := 55 else
        if s[5]=66 then NroOuverture := 56 else
        if s[5]=67 then NroOuverture := 57 else
        NroOuverture := 58 end else
      NroOuverture := 59 end else
    if s[3]=43 then begin
      if s[4]=34 then begin
        if s[5]=53 then begin
          if s[6]=56 then NroOuverture := 60 else
          if s[6]=42 then NroOuverture := 61 else
          NroOuverture := 62 end else
        if s[5]=65 then NroOuverture := 63 else
        if s[5]=33 then NroOuverture := 64 else
        NroOuverture := 65 end else
      if s[4]=57 then begin
        if s[5]=63 then NroOuverture := 66 else
        if s[5]=66 then NroOuverture := 67 else
        if s[5]=67 then NroOuverture := 68 else
        NroOuverture := 69 end else
      if s[4]=46 then begin
        if s[5]=53 then NroOuverture := 70 else
        NroOuverture := 71 end else
      NroOuverture := 72 end else
    NroOuverture := 73 end else
  if s[2]=46 then begin                           {parallele}
    if s[3]=35 then begin
      if s[4]=66 then begin
        if s[5]=65 then NroOuverture := 74 else
        if s[5]=34 then NroOuverture := 75 else
        NroOuverture := 76 end else
      if s[4]=64 then begin
        if s[5]=65 then NroOuverture := 77 else
        if s[5]=36 then NroOuverture := 78 else
        NroOuverture := 79 end else
      if s[4]=24 then begin
        if s[5]=25 then NroOuverture := 80 else
        if s[5]=65 then NroOuverture := 81 else
        NroOuverture := 82 end else
      if s[4]=26 then begin
        if s[5]=25 then NroOuverture := 83 else
        if s[5]=65 then NroOuverture := 84 else
        NroOuverture := 85 end else
      NroOuverture := 86 end else
    NroOuverture := 87 end else
  NroOuverture := 0;
end;

procedure IntervaleOuverture_6(var s:packed7; var minimum,maximum : byte);
var NroOuverture : SInt16; 
begin
  NroOuverture := -1;
  if s[2]=66 then begin                           {diagonale}
    if s[3]=65 then begin  
      if s[4]=46 then begin  
        if s[5]=35 then begin
          if s[6]=53 then begin
            minimum := 1;
            maximum := 3;
            end else
          if s[6]=64 then begin
            minimum := 4;
            maximum := 5;
            end else
          NroOuverture := 6 end else
        if s[5]=57 then begin
          if s[6]=75 then begin
            minimum := 7;
            maximum := 9;
            end else 
          if s[6]=64 then begin
            minimum := 10;
            maximum := 11;
            end else
          NroOuverture := 12 end else
        if s[5]=33 then begin
          if s[6]=64 then begin
            minimum := 13;
            maximum := 14;
            end else
          if s[6]=74 then begin
            minimum := 15;
            maximum := 16;
            end else
          NroOuverture := 17 end else
        if s[5]=67 then begin
          if s[6]=64 then begin
            minimum := 18;
            maximum := 19;
            end else
          if s[6]=53 then begin
            minimum := 20;
            maximum := 21;
            end else
          NroOuverture := 22 end else
        if s[5]=77 then NroOuverture := 23 else  
        if s[5]=34 then NroOuverture := 24 else   
        if s[5]=36 then NroOuverture := 25 else
        if s[5]=37 then NroOuverture := 26 else
        NroOuverture := 27 end else 
      NroOuverture := 28 end else 
    NroOuverture := 29 end else
  if s[2]=64 then begin                         {perpendiculaire}
    if s[3]=53 then begin
      if s[4]=46 then begin
        if s[5]=35 then begin
          if s[6]=63 then begin
            minimum := 30;
            maximum := 34;
            end else
          if s[6]=66 then begin
            minimum := 35;
            maximum := 36;
            end else
          NroOuverture := 37 end else
        if s[5]=34 then begin
            minimum := 38;
            maximum := 40;
            end else
        if s[5]=74 then NroOuverture := 41 else
        NroOuverture := 42 end else
      NroOuverture := 43 end else
    if s[3]=33 then begin
      if s[4]=34 then begin
        if s[5]=43 then begin
          if s[6]=46 then begin
            minimum := 44;
            maximum := 48;
            end else
          if s[6]=32 then NroOuverture := 49 else
          NroOuverture := 50 end else
        NroOuverture := 51 end else
      if s[4]=46 then begin
        if s[5]=66 then NroOuverture := 52 else
        if s[5]=65 then NroOuverture := 53 else
        NroOuverture := 54 end else
      if s[4]=57 then begin
        if s[5]=63 then NroOuverture := 55 else
        if s[5]=66 then NroOuverture := 56 else
        if s[5]=67 then NroOuverture := 57 else
        NroOuverture := 58 end else
      NroOuverture := 59 end else
    if s[3]=43 then begin
      if s[4]=34 then begin
        if s[5]=53 then begin
          if s[6]=56 then NroOuverture := 60 else
          if s[6]=42 then NroOuverture := 61 else
          NroOuverture := 62 end else
        if s[5]=65 then NroOuverture := 63 else
        if s[5]=33 then NroOuverture := 64 else
        NroOuverture := 65 end else
      if s[4]=57 then begin
        if s[5]=63 then NroOuverture := 66 else
        if s[5]=66 then NroOuverture := 67 else
        if s[5]=67 then NroOuverture := 68 else
        NroOuverture := 69 end else
      if s[4]=46 then begin
        if s[5]=53 then NroOuverture := 70 else
        NroOuverture := 71 end else
      NroOuverture := 72 end else
    NroOuverture := 73 end else
  if s[2]=46 then begin                           {parallele}
    if s[3]=35 then begin
      if s[4]=66 then begin
        if s[5]=65 then NroOuverture := 74 else
        if s[5]=34 then NroOuverture := 75 else
        NroOuverture := 76 end else
      if s[4]=64 then begin
        if s[5]=65 then NroOuverture := 77 else
        if s[5]=36 then NroOuverture := 78 else
        NroOuverture := 79 end else
      if s[4]=24 then begin
        if s[5]=25 then NroOuverture := 80 else
        if s[5]=65 then NroOuverture := 81 else
        NroOuverture := 82 end else
      if s[4]=26 then begin
        if s[5]=25 then NroOuverture := 83 else
        if s[5]=65 then NroOuverture := 84 else
        NroOuverture := 85 end else
      NroOuverture := 86 end else
    NroOuverture := 87 end else
  NroOuverture := 0;
  
  if NroOuverture<>-1 then
    begin
      minimum := NroOuverture;
      maximum := NroOuverture;
    end;
end;

procedure IntervaleOuverture_5(var s:packed7; var minimum,maximum : byte);
var NroOuverture : SInt16; 
begin
  NroOuverture := -1;
  if s[2]=66 then begin                           {diagonale}
    if s[3]=65 then begin  
      if s[4]=46 then begin  
        if s[5]=35 then begin
            minimum := 1;
            maximum := 6;
            end else
        if s[5]=57 then begin
            minimum := 7;
            maximum := 12;
            end else 
        if s[5]=33 then begin
            minimum := 13;
            maximum := 17;
            end else
        if s[5]=67 then begin
            minimum := 18;
            maximum := 22;
            end else
        if s[5]=77 then NroOuverture := 23 else  
        if s[5]=34 then NroOuverture := 24 else   
        if s[5]=36 then NroOuverture := 25 else
        if s[5]=37 then NroOuverture := 26 else
        NroOuverture := 27 end else 
      NroOuverture := 28 end else 
    NroOuverture := 29 end else
  if s[2]=64 then begin                         {perpendiculaire}
    if s[3]=53 then begin
      if s[4]=46 then begin
        if s[5]=35 then begin
            minimum := 30;
            maximum := 37;
            end else
        if s[5]=34 then begin
            minimum := 38;
            maximum := 40;
            end else
        if s[5]=74 then NroOuverture := 41 else
        NroOuverture := 42 end else
      NroOuverture := 43 end else
    if s[3]=33 then begin
      if s[4]=34 then begin
        if s[5]=43 then begin
            minimum := 44;
            maximum := 50;
            end else
        NroOuverture := 51 end else
      if s[4]=46 then begin
        if s[5]=66 then NroOuverture := 52 else
        if s[5]=65 then NroOuverture := 53 else
        NroOuverture := 54 end else
      if s[4]=57 then begin
        if s[5]=63 then NroOuverture := 55 else
        if s[5]=66 then NroOuverture := 56 else
        if s[5]=67 then NroOuverture := 57 else
        NroOuverture := 58 end else
      NroOuverture := 59 end else
    if s[3]=43 then begin
      if s[4]=34 then begin
        if s[5]=53 then begin
          minimum := 60;
          maximum := 62;
          end else
        if s[5]=65 then NroOuverture := 63 else
        if s[5]=33 then NroOuverture := 64 else
        NroOuverture := 65 end else
      if s[4]=57 then begin
        if s[5]=63 then NroOuverture := 66 else
        if s[5]=66 then NroOuverture := 67 else
        if s[5]=67 then NroOuverture := 68 else
        NroOuverture := 69 end else
      if s[4]=46 then begin
        if s[5]=53 then NroOuverture := 70 else
        NroOuverture := 71 end else
      NroOuverture := 72 end else
    NroOuverture := 73 end else
  if s[2]=46 then begin                           {parallele}
    if s[3]=35 then begin
      if s[4]=66 then begin
        if s[5]=65 then NroOuverture := 74 else
        if s[5]=34 then NroOuverture := 75 else
        NroOuverture := 76 end else
      if s[4]=64 then begin
        if s[5]=65 then NroOuverture := 77 else
        if s[5]=36 then NroOuverture := 78 else
        NroOuverture := 79 end else
      if s[4]=24 then begin
        if s[5]=25 then NroOuverture := 80 else
        if s[5]=65 then NroOuverture := 81 else
        NroOuverture := 82 end else
      if s[4]=26 then begin
        if s[5]=25 then NroOuverture := 83 else
        if s[5]=65 then NroOuverture := 84 else
        NroOuverture := 85 end else
      NroOuverture := 86 end else
    NroOuverture := 87 end else
  NroOuverture := 0;
  
  if NroOuverture<>-1 then
    begin
      minimum := NroOuverture;
      maximum := NroOuverture;
    end;
end;

procedure IntervaleOuverture_4(var s:packed7; var minimum,maximum : byte);
var NroOuverture : SInt16; 
begin
  NroOuverture := -1;
  if s[2]=66 then begin                           {diagonale}
    if s[3]=65 then begin  
      if s[4]=46 then begin  
            minimum := 1;
            maximum := 27;
            end else
      NroOuverture := 28 end else 
    NroOuverture := 29 end else
  if s[2]=64 then begin                         {perpendiculaire}
    if s[3]=53 then begin
      if s[4]=46 then begin
            minimum := 30;
            maximum := 42;
            end else
      NroOuverture := 43 end else
    if s[3]=33 then begin
      if s[4]=34 then begin
            minimum := 44;
            maximum := 51;
            end else
      if s[4]=46 then begin
            minimum := 52;
            maximum := 54;
            end else
      if s[4]=57 then begin
            minimum := 55;
            maximum := 58;
            end else
      NroOuverture := 59 end else
    if s[3]=43 then begin
      if s[4]=34 then begin
          minimum := 60;
          maximum := 65;
          end else
      if s[4]=57 then begin
          minimum := 66;
          maximum := 69;
          end else
      if s[4]=46 then begin
          minimum := 70;
          maximum := 71;
          end else
      NroOuverture := 72 end else
    NroOuverture := 73 end else
  if s[2]=46 then begin                           {parallele}
    if s[3]=35 then begin
      if s[4]=66 then begin
        minimum := 74;
        maximum := 76;
        end else
      if s[4]=64 then begin
        minimum := 77;
        maximum := 79;
        end else
      if s[4]=24 then begin
        minimum := 80;
        maximum := 82;
        end else
      if s[4]=26 then begin
        minimum := 83;
        maximum := 85;
        end else
      NroOuverture := 86 end else
    NroOuverture := 87 end else
  NroOuverture := 0;
  
  if NroOuverture<>-1 then
    begin
      minimum := NroOuverture;
      maximum := NroOuverture;
    end;
end;

procedure IntervaleOuverture_3(var s:packed7; var minimum,maximum : byte);
var NroOuverture : SInt16; 
begin
  NroOuverture := -1;
  if s[2]=66 then begin                           {diagonale}
    if s[3]=65 then begin   
            minimum := 1;
            maximum := 28;
            end else
    NroOuverture := 29 end else
  if s[2]=64 then begin                         {perpendiculaire}
    if s[3]=53 then begin
            minimum := 30;
            maximum := 43;
            end else
    if s[3]=33 then begin
            minimum := 44;
            maximum := 59;
            end else
    if s[3]=43 then begin
          minimum := 60;
          maximum := 72;
          end else
    NroOuverture := 73 end else
  if s[2]=46 then begin                           {parallele}
    if s[3]=35 then begin
        minimum := 74;
        maximum := 86;
        end else
    NroOuverture := 87 end else
  NroOuverture := 0;
  
  if NroOuverture<>-1 then
    begin
      minimum := NroOuverture;
      maximum := NroOuverture;
    end;
end;


procedure IntervaleOuverture_2(var s:packed7; var minimum,maximum : byte);
 { donne un l'intervale des debuts de partie dans s apres 2 coups.
   Le premier coup est suppos� etre en F5}
begin
  if s[2]=66 
    then 
      begin  
        minimum := 1;
        maximum := 29;
      end 
    else
  if s[2]=64 
    then 
      begin
        minimum := 30;
        maximum := 73;
      end
    else
  if s[2]=46 
    then 
      begin
        minimum := 74;
        maximum := 87;
      end
    else
      begin
        minimum := 0;
        maximum := 0;
      end;
end;

procedure DetermineIntervaleOuverture(var ouv:packed7;longueur : SInt16; var minimum,maximum : byte);
begin
  case longueur of
    0:begin
        minimum := 1;
        maximum := 87;
      end;
    1:begin
        minimum := 1;
        maximum := 87;
      end;
    2:IntervaleOuverture_2(ouv,minimum,maximum);
    3:IntervaleOuverture_3(ouv,minimum,maximum);
    4:IntervaleOuverture_4(ouv,minimum,maximum);
    5:IntervaleOuverture_5(ouv,minimum,maximum);
    6:IntervaleOuverture_6(ouv,minimum,maximum);
    7:begin
        minimum := NroOuverture(ouv);
        maximum := minimum;
      end;
   end;  {case}
end;




function EstDansTableOuverture(nom : str255; var nroDansTable : SInt16) : boolean;
var comment : str255;
    t,i,indexCommentaireFin,indexCommentaireDeb : SInt16; 
begin
  nroDansTable := -1;
  estDansTableOuverture := false;
  if bibliothequeLisible then
    for t := 1 to nbreLignesEnBibl do
      begin
        indexCommentaireDeb := indexCommentaireBibl^^[t-1]+1;
        indexCommentaireFin := indexCommentaireBibl^^[t];
        if (indexCommentaireFin>indexCommentaireDeb)
          then 
            begin
              comment := '';
              for i := indexCommentaireDeb to indexCommentaireFin do
                comment := comment+commentaireBiblEnTas^^[i];
              if comment=nom then 
                begin
                  estDansTableOuverture := true;
                  nroDansTable := t;
                  exit(estDansTableOuverture);
                end;
            end;
      end;
end;


function GetPremierCoupParDefaut() : SInt32;
begin
  GetPremierCoupParDefaut := premierCoupParDefautDansListe;
end;


procedure SetPremierCoupParDefaut(coup : SInt32);
begin
  if (coup=34) | (coup=43) | (coup=56) | (coup=65)
    then premierCoupParDefautDansListe := coup;
end;


procedure EffectueSymetrieAxeNW_SE(var plat : plateauOthello);
var i,j : SInt16; 
    platAux : plateauOthello;
begin
  platAux := plat;
  for i := 1 to 8 do
    for j := 1 to 8 do
      plat[i+10*j] := platAux[j+10*i];
end;


procedure EffectueSymetrieAxeNE_SW(var plat : plateauOthello);
var i,j : SInt16; 
    platAux : plateauOthello;
begin
  platAux := plat;
  for i := 1 to 8 do
    for j := 1 to 8 do
      plat[i+10*j] := platAux[(9-j)+10*(9-i)];
end;


function CaseSymetrique(whichSquare : SInt16; axeSymetrie : SInt32) : SInt16; 
begin
  case axeSymetrie of
    central              : CaseSymetrique := 99 - whichSquare;
    axeSE_NW             : CaseSymetrique := platDiv10[whichSquare]+10*platMod10[whichSquare];
    axeSW_NE             : CaseSymetrique := 99 - (platDiv10[whichSquare]+10*platMod10[whichSquare]);
    axeVertical          : CaseSymetrique := 10*platDiv10[whichSquare]+(9-platMod10[whichSquare]);
    axeHorizontal        : CaseSymetrique := 10*(9-platDiv10[whichSquare])+platMod10[whichSquare];
    quartDeTourTrigo     : CaseSymetrique := 10*(9-platMod10[whichSquare])+platDiv10[whichSquare];
    quartDeTourAntiTrigo : CaseSymetrique := 10*platMod10[whichSquare]+(9-platDiv10[whichSquare]);
    otherwise  CaseSymetrique := whichSquare;
  end;
end;


procedure SymetriserPartieFormatThor(var s60 : PackedThorGame; axeSymetrie : SInt32; debut,fin : SInt32);
var i : SInt16; 
begin
  if (debut >= 1) & (debut <= 60) & (fin >= 1) & (fin <= 60) then
	  for i := debut to fin do
	    SET_NTH_MOVE_OF_PACKED_GAME(s60, i, CaseSymetrique(GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'SymetriserPartieFormatThor'), axeSymetrie));
end;


procedure SymetriserPartieFormatAlphanumerique(var s : str255;axeSymetrie : SInt32; debut,fin : SInt32);
var i,coup : SInt16; 
    s1 : str255;
begin
  if (debut >= 1) & (debut <= 60) & (fin >= 1) & (fin <= 60) then
	  for i := debut to fin do
	    begin
	      coup := PositionDansStringAlphaEnCoup(s,2*i-1);
	      coup := CaseSymetrique(coup,axeSymetrie);
	      s1 := CoupEnString(coup,CharInRange(s[2*i-1],'A','H'));
	      s[2*i-1] := s1[1];
	      s[2*i]   := s1[2];
	    end;
	      
end;


procedure EffectueSymetrieOnSquare(var whichSquare : SInt16; var axeSymetrie : SInt32; var continuer : boolean);
begin
  {$UNUSED continuer}
  whichSquare := CaseSymetrique(whichSquare,axeSymetrie);
end;


end.





























