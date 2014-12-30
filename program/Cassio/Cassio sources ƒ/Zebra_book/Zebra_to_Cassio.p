Unit Zebra_to_Cassio;

INTERFACE

USES UnitOth0, MyTypes, UnitPositionEtTrait;


const
(* Flags pour interpreter les valeurs de la bibliotheque de zebra *)
    NONE                  =    -1 ;
    NO_MOVE               =    -1 ;
    POSITION_EXHAUSTED    =    -2 ;
    NO_SCORE              =    9999 ;
    CONFIRMED_WIN         =    30000 ;
    UNWANTED_DRAW         =    (CONFIRMED_WIN - 1) ;
    INFINITE_WIN          =    32000 ;
    INFINITE_SPREAD       =    (1000 * 128) ;

(* Flag bits and shifts*)
    NULL_MOVE             =    0 ;
    BLACK_TO_MOVE         =    1 ;
    WHITE_TO_MOVE         =    2 ;
    WLD_SOLVED            =    4 ;
    NOT_TRAVERSED         =    8 ;
    FULL_SOLVED           =    16 ;
    
(* Flags pour selectionner les options d'affichage *)
    kUtiliserZebraBook                   = 1;
    kAfficherNotesZebraSurOthellier      = 2;
    kAfficherCouleursZebraSurOthellier   = 4;
    kAfficherNotesZebraDansArbre         = 8;
    kAfficherCouleursZebraDansArbre      = 16;
    kAfficherNotesZebraDansReflexion     = 32;
    kAfficherCouleurZebraDansReflexion   = 64;
    kAfficherNotesZebraDansFenetreZebra  = 128;
    AfficherCouleurZebraDansFenetreZebra = 256;
    kAllZebraOptions                     = $FFFFFFFF;
    

{ Traduction en Pascal des typages des fonctions C de Zebra}
procedure Afficher_ZebraBook;external;
procedure ExtraireVals(index : SInt32; SN,SB,AM,AS : integerP; F : integerP);external;
function Trouver_Position_in_ZebraBook(Pos : longintP; orientation : longintP; file_name : charP) : SInt32;external;
function SymetriseCoup(orientation : SInt32; move : SInt32) : SInt32;external;
function NumberOfPositionsInZebraBook() : SInt32;external;


{ Les fonctions d'interface avec Cassio}
function Get_ZebraBook_Name() : str255;
function Get_ZebraBook_Values(const plat : plateauOthello; var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16; var Flags : SInt16) : boolean;
procedure ZebraBookDansArbreDeJeuCourant;
procedure WritelnZebraValuesDansRapport(var pos : PositionEtTraitRec);
function ZebraBookEstIntrouvable() : boolean;
procedure SetZebraBookEstIntrouvable(flag : boolean);


{ Selections des options}
function GetZebraBookOptions() : SInt32;
procedure SetZebraBookOptions(options : SInt32);
function ZebraBookACetteOption(mask : SInt32) : boolean;
procedure AjouterZebraBookOption(mask : SInt32);
procedure RetirerZebraBookOption(mask : SInt32);
procedure ToggleZebraOption(mask : SInt32);


{ Initialisation de l'unité}
procedure InitUnitZebraBook;
procedure LibereMemoireUnitZebraBook;
procedure LoadZebraBook(withCheckEvents : boolean);



{ Gestion des evenements pendant la lecture du fichier bibliotheque de Zebra }
function Lecture_ZebraBook_Interrompue_Par_Evenement() : SInt32;


IMPLEMENTATION


USES UnitRapport,UnitMacExtras,UnitArbreDeJeuCourant,UnitAfficheArbreDeJeuCourant,UnitNotesSurCases,
     UnitOth1,UnitOth2,SNStrings,MyFileSystemUtils,UnitActions,UnitGestionDuTemps;


var ZebraBookOptions : SInt32;
    ZebraInfosRec : record
                      theCurrentNode : GameTree;
                      thePositionEtTrait : PositionEtTraitRec;
                    end;

const gZebraBookNameInitialised : boolean = false;

var  gLectureZebraBook : record
                           lectureEnCours                     : boolean;
                           bookNameInitialised                : boolean;
                           introuvable                        : boolean;
                           verifierEvenementsPendantLaLecture : boolean;
                           nbreAppelsHasGotEvents             : SInt32;
                           bookName                           : str255;
                         end;


function Get_ZebraBook_Name() : str255;
var nom : str255;
    theFic : FichierTEXT;
begin
  with gLectureZebraBook do
    begin
      if bookNameInitialised
        then 
          Get_ZebraBook_Name := bookName
        else 
          begin
            if FichierTexteDeCassioExiste('Zebra-book.data',theFic) = NoErr
              then nom := GetFullPathOfFSSpec(theFic.theFSSpec)
              else nom := 'Zebra-book.data';
            
            bookName            := nom;
            bookNameInitialised := true;
            
            Get_ZebraBook_Name := nom;
          end;
    end;
end;


function Get_ZebraBook_Values(const plat : plateauOthello; var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16; var Flags : SInt16) : boolean;
var pos:plOthLongint;
    i,j,t : SInt16; 
    index,orientation : SInt32;
    ZebraBookPath : str255;
begin

  {creer la position}
  for i := 0 to 100 do pos[i] := 0;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        t := i + j*10;
        case plat[t] of
          pionNoir  : pos[t] := 1;
          pionBlanc : pos[t] := 2;
          otherwise   pos[t] := 0;
        end; {case}
      end;
  
  {on fabrique une chaine au format C}
  ZebraBookPath := Get_ZebraBook_Name() + chr(0);
  
  {chercher si la position est dans la bibliotheque de Zebra}
  index := Trouver_Position_in_ZebraBook(@pos[0], @orientation, @ZebraBookPath[1]);
  if (index < 0) then
    begin
      Get_ZebraBook_Values := false;
      exit(Get_ZebraBook_Values);
    end;
  
  ExtraireVals(index, @Score_Noir, @Score_Blanc, @Alt_Move, @Alt_Score, @Flags);
  if (Alt_Move > 0)  then
    Alt_Move := SymetriseCoup(orientation, Alt_Move);
  
  Get_ZebraBook_Values := true;
end;


procedure WritelnZebraValuesDansRapport(var pos : PositionEtTraitRec);
var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16; 
    Flags : SInt16; 
begin
  if gLectureZebraBook.lectureEnCours 
    then exit(WritelnZebraValuesDansRapport);
    
  if Get_ZebraBook_Values(pos.position,Score_Noir,Score_Blanc,Alt_Move,Alt_Score,Flags) then
    begin
    
      WritelnPositionEtTraitDansRapport(pos.position,GetTraitOfPosition(pos));
    
      if (Flags AND FULL_SOLVED) <> 0 
        then
          begin (* Finale parfaite *)
            if (Score_Noir = 0) 
              then 
                WritelnDansRapport(' Score : Nulle') 
              else 
               if (Score_Noir > CONFIRMED_WIN) 
                 then 
                   begin
                     if (Flags AND BLACK_TO_MOVE) <> 0 
                       then WritelnStringAndNumDansRapport('  Gain pour Noir ' , Score_Noir - CONFIRMED_WIN) 
                       else WritelnStringAndNumDansRapport('  Gain pour Noir ' , Score_Noir - CONFIRMED_WIN) ;
                   end 
                 else 
                   begin
                     if (Flags AND BLACK_TO_MOVE) <> 0 
                       then WritelnStringAndNumDansRapport('  Gain pour Blanc ', -(Score_Noir + CONFIRMED_WIN)) 
                       else WritelnStringAndNumDansRapport('  Gain pour Blanc  ', -(Score_Noir + CONFIRMED_WIN)) ;
                   end
            end  (* Finale parfaite *)
        else
          if (Flags AND WLD_SOLVED) <> 0 then 
            begin (* Finale WLD *)
              if (Score_Noir = 0) 
                then 
                  WritelnDansRapport('  Score : Nulle') 
                else 
                  begin
                    if (Score_Noir > CONFIRMED_WIN) then begin
                    if (Flags AND BLACK_TO_MOVE) <> 0 then
                      WritelnDansRapport('  Score : gain Noir') 
                    else
                      WritelnDansRapport('  Score : perdant pour Blanc') ;
                  end else begin
                    if (Flags AND BLACK_TO_MOVE) <> 0 then 
                      WritelnDansRapport('  Score : perdant pour Noir') 
                    else
                      WritelnDansRapport('  Score : gain Blanc') ;
                  end
            end
            end (* Finale WLD *)
       else
        begin  (* Milieu de partie *)
            if (Score_Noir = NO_SCORE) 
            then
            WritelnDansRapport('  Pas de score' )
            else
            if (Flags AND BLACK_TO_MOVE) <> 0
              then WritelnStringAndReelDansRapport('  Score pour noir  : ',  1.0*Score_Noir/128.0 , 4) 
              else WritelnStringAndReelDansRapport('  Score pour blanc : ', -1.0*Score_Noir/128.0 , 4);
          
          if (Alt_Move < 0) 
            then
            WritelnDansRapport('  Pas de deviation') 
            else 
              begin
                WriteStringAndCoupDansRapport('  Deviation : ', Alt_Move);
                if (Flags AND BLACK_TO_MOVE) <> 0
                then WritelnStringAndReelDansRapport(' score pour noir : ',  1.0*Alt_Score/128.0 , 4) 
                else WritelnStringAndReelDansRapport(' score pour blanc : ',  -1.0*Alt_Score/128.0 , 4);
              end;
          end;  (* Milieu de partie *)
          
    end;
end;


procedure AjouterFilsEtValuationDeZebra(fils : SInt32;pos : PositionEtTraitRec;scorePourNoir : SInt32;genreDeNote : SInt32);
var err : OSErr;
    pos2 : PositionEtTraitRec;
    isNew : boolean;
begin

  if gLectureZebraBook.lectureEnCours 
    then exit(AjouterFilsEtValuationDeZebra);
  
  SetCurrentNode(ZebraInfosRec.theCurrentNode);
  pos2 := ZebraInfosRec.thePositionEtTrait;
  err := NoErr;
  
  
  {jouer eventuellement le coup dans l'arbre}
  if (fils > 0) then 
    begin
      if (genreDeNote <> ReflZebraBookEval) | ZebraBookACetteOption(kAfficherNotesZebraDansArbre + kAfficherCouleursZebraDansArbre)
        then err := ChangeCurrentNodeAfterThisMove(fils,GetTraitOfPosition(ZebraInfosRec.thePositionEtTrait),'AjouterFilsEtValuationDeZebra',isNew);
        
      if not(UpdatePositionEtTrait(pos2,fils)) then err := -1;
      
      if isNew & (err = NoErr) then 
        begin
          {WritelnDansRapport('virtual : '+ CoupEnStringEnMajuscules(fils));}
          {MarquerCurrentNodeCommeVirtuel;}
        end;
    end;
    
  
  {on vérifie encore une fois que la position dans l'arbre de jeu
  ou on va ajouter de l'info correspond bien à la position trouvee
  dans la biblio de Zebra}
  if (err = NoErr) & not(SamePositionEtTrait(pos,pos2)) then 
    begin
      Sysbeep(0);
      WritelnDansRapport('Desynchronisation dans AjouterFilsEtValuationDeZebra !!');
      {
      WritelnPositionEtTraitDansRapport(pos.position,GetTraitOfPosition(pos));
      WritelnPositionEtTraitDansRapport(pos2.position,GetTraitOfPosition(pos2));
      }
      err := -1;
    end;
  
  {ajouter l'info}
  if (err = NoErr) then
    begin
      if (genreDeNote <> ReflZebraBookEval) | ZebraBookACetteOption(kAfficherNotesZebraDansArbre + kAfficherCouleursZebraDansArbre)
        then AjoutePropertyValeurExacteCoupDansCurrentNode(genreDeNote,scorePourNoir);
      
      if (genreDeNote = ReflZebraBookEval) then
        begin
          if GetTraitOfPosition(ZebraInfosRec.thePositionEtTrait) = pionNoir
            then SetNoteMilieuSurCase(kNotesDeZebra,fils,  scorePourNoir)
            else SetNoteMilieuSurCase(kNotesDeZebra,fils, -scorePourNoir);
        end 
      else if (genreDeNote = ReflGagnant) then
        begin
          if (GetTraitOfPosition(ZebraInfosRec.thePositionEtTrait) = pionNoir)
            then 
              begin
                if (scorePourNoir > 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourGain) else
                if (scorePourNoir = 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourNulle) else
                if (scorePourNoir < 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourPerte)
              end
            else 
              begin
                if (scorePourNoir < 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourGain) else
                if (scorePourNoir = 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourNulle) else
                if (scorePourNoir > 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourPerte)
              end
        end
      else if (genreDeNote = ReflParfait) then
        begin
          if (GetTraitOfPosition(ZebraInfosRec.thePositionEtTrait) = pionNoir)
            then SetNoteSurCase(kNotesDeZebra, fils,  100*scorePourNoir) 
            else SetNoteSurCase(kNotesDeZebra, fils, -100*scorePourNoir);
        end; 
    end;
  
  
end;



procedure AjouterZebraValuesDansCassio(fils : SInt32; var pos : PositionEtTraitRec; niveauRecursion : SInt32);
var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16; 
    Flags : SInt16; 
    i,square : SInt32;
    pos2 : PositionEtTraitRec;
begin
  if gLectureZebraBook.lectureEnCours 
    then exit(AjouterZebraValuesDansCassio);

  if (NumberOfPositionsInZebraBook() <= 0) then 
    begin
      if ZebraBookEstIntrouvable() | gLectureZebraBook.lectureEnCours
        then exit(AjouterZebraValuesDansCassio)
        else
          begin
            LoadZebraBook(false);
            if (NumberOfPositionsInZebraBook() <= 0) then 
              exit(AjouterZebraValuesDansCassio);
          end;
    end;

  (* On essaie de mettre tous les fils connus *)
    if (niveauRecursion > 0) then
      begin
        pos2 := pos;
        for i := 1 to 64 do
          begin
            square := othellier[i];
            if UpdatePositionEtTrait(pos2,square) then
              begin
                AjouterZebraValuesDansCassio(square,pos2,niveauRecursion-1);
                pos2 := pos;
              end;
          end;
      end;


  if Get_ZebraBook_Values(pos.position,Score_Noir,Score_Blanc,Alt_Move,Alt_Score,Flags) then
    begin
    
      if (Flags AND FULL_SOLVED) <> 0 
        then
          begin (* Finale parfaite *)
            if (Score_Noir = 0) | (Score_Noir = UNWANTED_DRAW)
              then 
                AjouterFilsEtValuationDeZebra(fils, pos, 0, ReflParfait)    {nulle}
              else 
               if (Score_Noir > CONFIRMED_WIN)
                 then AjouterFilsEtValuationDeZebra(fils, pos,   Score_Noir - CONFIRMED_WIN  , ReflParfait)  {gagne pour Noir}
                 else AjouterFilsEtValuationDeZebra(fils, pos,   Score_Noir + CONFIRMED_WIN  , ReflParfait); {gagne pour Blanc}
          end  (* Finale parfaite *)
        else
          if (Flags AND WLD_SOLVED) <> 0 then 
            begin (* Finale WLD *)
              if (Score_Noir = 0) | (Score_Noir = UNWANTED_DRAW)
                then 
                  AjouterFilsEtValuationDeZebra(fils, pos, 0, ReflParfait)    {nulle}
                else 
                  begin
                    if (Score_Noir > CONFIRMED_WIN) 
                      then AjouterFilsEtValuationDeZebra(fils, pos, +1 ,ReflGagnant)       {gagne pour Noir}
                      else AjouterFilsEtValuationDeZebra(fils, pos, -1 ,ReflGagnant);      {gagne pour Blanc}
                  end
            end (* Finale WLD *)
        else
          begin  (* Milieu de partie *)
            if (Score_Noir = NO_SCORE) 
              then
                {WritelnDansRapport('  Pas de score' )}
              else
                AjouterFilsEtValuationDeZebra(fils, pos, MyTrunc(0.4999 + 100.0*Score_Noir/128.0) , ReflZebraBookEval);
      
      
            if (niveauRecursion > 0) then
              begin
                if (Alt_Move < 0) 
                  then
                    {WritelnDansRapport('  Pas de deviation') }
                  else 
                    begin
                      {WriteStringAndCoupDansRapport('  Deviation : ', Alt_Move);}
                      pos2 := pos;
                      if UpdatePositionEtTrait(pos2,Alt_Move) then
                        AjouterFilsEtValuationDeZebra(Alt_Move, pos2, MyTrunc(0.4999 + 100.0*Alt_Score/128.0) , ReflZebraBookEval);
                    end;
              end;
          end;  (* Milieu de partie *)
    end;
    
end;



procedure ZebraBookDansArbreDeJeuCourant;
begin
  if ZebraBookACetteOption(kUtiliserZebraBook) & not(CassioEstEnModeSolitaire()) & not(gLectureZebraBook.lectureEnCours) then
    with ZebraInfosRec do
      begin
      
        (* les scores de Zebra sur l'othellier *)
        theCurrentNode := GetCurrentNode();
        if (nbreCoup > 0) & GetPositionEtTraitACeNoeud(theCurrentNode,thePositionEtTrait) then
          AjouterZebraValuesDansCassio(NO_MOVE,thePositionEtTrait,1);
        SetCurrentNode(theCurrentNode);
        
        
        if EstVisibleDansFenetreArbreDeJeu(theCurrentNode) then
          begin
            EffaceNoeudDansFenetreArbreDeJeu;
            EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
          end;
        
      end;
end;


function GetZebraBookOptions() : SInt32;
begin
  GetZebraBookOptions := ZebraBookOptions;
end;


procedure SetZebraBookOptions(options : SInt32);
begin
  ZebraBookOptions := options;
end;


function ZebraBookACetteOption(mask : SInt32) : boolean;
begin
  ZebraBookACetteOption := (BitAnd(ZebraBookOptions,mask) <> 0)
end;


procedure AjouterZebraBookOption(mask : SInt32);
begin
  SetZebraBookOptions(GetZebraBookOptions() OR mask);
end;


procedure RetirerZebraBookOption(mask : SInt32);
begin
  SetZebraBookOptions(GetZebraBookOptions() AND (kAllZebraOptions - mask));
end;


procedure ToggleZebraOption(mask : SInt32);
begin
  if ZebraBookACetteOption(mask) 
    then RetirerZebraBookOption(mask)
    else AjouterZebraBookOption(mask);
end;


procedure InitUnitZebraBook;
begin
  SetZebraBookOptions(kUtiliserZebraBook + 
                      kAfficherNotesZebraSurOthellier +
                      kAfficherCouleursZebraSurOthellier +
                      kAfficherNotesZebraDansArbre +
                      kAfficherCouleursZebraDansArbre);
  SetZebraBookEstIntrouvable(false);
  gLectureZebraBook.lectureEnCours := false;
end;


function ZebraBookEstIntrouvable() : boolean;
begin
  ZebraBookEstIntrouvable := gLectureZebraBook.introuvable;
end;


procedure SetZebraBookEstIntrouvable(flag : boolean);
begin
  gLectureZebraBook.introuvable := flag;
end;


procedure LoadZebraBook(withCheckEvents : boolean);
var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16; 
    Flags : SInt16; 
    memoire : SInt32;
    ticks : SInt32;
    bidon : boolean;
    {s : str255;}
begin
  with gLectureZebraBook do
    if not(lectureEnCours) then
    begin
      lectureEnCours := true;
      
      ticks := TickCount();
      
      {on compacte la memoire}
      if not(gIsRunningUnderMacOSX) then memoire := FreeMem();

      {et on force le chargement de la bibliotheque de Zebra en memoire}
      nbreAppelsHasGotEvents := 0;
      
      
      verifierEvenementsPendantLaLecture := withCheckEvents;
      bidon := Get_ZebraBook_Values(jeuCourant,Score_Noir,Score_Blanc,Alt_Move,Alt_Score,Flags);
      verifierEvenementsPendantLaLecture := false;
     
      if (NumberOfPositionsInZebraBook() <= 0) & not(withCheckEvents) then
        SetZebraBookEstIntrouvable(true);
      
     
      if ((TickCount() - ticks) > 1) then
        begin
          { s := 'Nb de positions dans la bibliothèque de Zebra : ^0'}
          {s := ParamStr(ReadStringFromRessource(TextesDiversID,12),NumEnString(NumberOfPositionsInZebraBook()),'','','');
          WritelnDansRapport(s);
          WritelnStringAndNumDansRapport('temps en ticks = ',TickCount() - ticks);
          WritelnDansRapport('');
          WritelnStringAndNumDansRapport('nbreAppelsHasGotEvents = ',nbreAppelsHasGotEvents);}
        end;
      
      
      lectureEnCours := false;
    end;
end;


procedure LibereMemoireUnitZebraBook;
begin
end;



function Lecture_ZebraBook_Interrompue_Par_Evenement() : SInt32;
begin
  Lecture_ZebraBook_Interrompue_Par_Evenement := 0;
  
  with gLectureZebraBook do
    if verifierEvenementsPendantLaLecture then
      begin
        inc(nbreAppelsHasGotEvents);
        gCassioChecksEvents := true;
        if HasGotEvent(everyEvent,theEvent,0,NIL) then 
          begin
  			  
            TraiteOneEvenement;
            AccelereProchainDoSystemTask(2);
            
            if Quitter
              then Lecture_ZebraBook_Interrompue_Par_Evenement := 1;
          end;
      end;
end;




END.















