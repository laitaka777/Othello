UNIT UnitArbreDeJeuCourant;



{$DEFINEC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL   FALSE}


INTERFACE







USES 
{$IFC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL}
    Profiler,
{$ENDC}
    UnitOth0,UnitPositionEtTrait,UnitDefinitionsProperties,UnitPropertyList,UnitGameTree;
    


CONST 
  kDontChange = 0;
  kForceReel = 1;
  kForceVirtual = 2;
  kNewMovesReel = 3;
  kNewMovesVirtual = 4;


{Initialisation et destruction de l'unité}
procedure InitUnitArbreDeJeuCourant;
procedure LibereMemoireUnitArbreDeJeuCourant;


{fonctions d'acces de l'arbre et du noeud courant}
function GetCurrentNode() : GameTree;
function GetRacineDeLaPartie() : GameTree;
function EstLaRacineDeLaPartie(G : GameTree) : boolean;
function NbDeFilsOfCurrentNode() : SInt16; 
function GetCurrentSons() : GameTreeList;


{fonction d'initialisation de l'arbre de jeu courant}
procedure ReInitialiseGameRootGlobalDeLaPartie;
procedure SetCurrentNodeToGameRoot;


{fonctions de modification de l'arbre de jeu courant}
procedure SetSonsOfCurrentNode(theSons : GameTreeList);
procedure BringSonOfCurrentNodeToFront(whichSon : GameTree);
procedure BringSonOfCurrentNodeInPositionN(whichSon : GameTree;N : SInt16);
procedure JumpToPosition(var G : GameTree; var compteur : SInt32; var continuer : boolean);


{utilitaires sur les PositionsEtTraitRec}
function PlayMoveProperty(prop : Property; var positionEtTrait : PositionEtTraitRec) : boolean;


{fonctions de gestion des proprietes l'arbre de jeu}
procedure GetPropertyListOfCurrentNode(var L : PropertyList);
procedure SetPropertyListOfCurrentNode(L : PropertyList);
procedure AddPropertyToCurrentNode(prop : Property);
procedure AddPropertyToCurrentNodeSansDuplication(prop : Property);
procedure AddScorePropertyToCurrentNodeSansDuplication(prop : Property);
procedure DeletePropertyFromCurrentNode(prop : Property);
procedure DeletePropertiesOfTheseTypeFromCurrentNode(whichType : SInt16);
procedure DeletePropertiesOfTheseTypesFromCurrentNode(whichTypes : SetOfPropertyTypes);
function SelectFirstPropertyOfTypesInCurrentNode(whichTypes : SetOfPropertyTypes) : PropertyPtr;
function SelectPropertyInCurrentNode(choice:PropertyPredicate; var result : SInt32) : PropertyPtr;


{iterateur sur les proprietes d'un noeud ou du noeud courant}
procedure ForEachPropertyOfTheseTypesInCurrentNodeDo(whichTypes : SetOfPropertyTypes;DoWhat:PropertyProc);
procedure ForEachPositionOnPathToGameNodeDo(G : GameTree;DoWhat:GameTreeProcAvecResult);
procedure ForEachPositionOnPathToCurrentNodeDo(DoWhat:GameTreeProcAvecResult);


{fonction de navigation dans l'arbre de jeu courant}
function ChangeCurrentNodeAfterThisMove(square,couleur : SInt16; const fonctionAppelante : str255; var isNew : boolean) : OSErr;
function ChangeCurrentNodeAfterNewMove(square,couleur : SInt16; const fonctionAppelante : str255) : OSErr;
procedure ChangeCurrentNodeForBackMove;
procedure DoChangeCurrentNodeBackwardUntil(G : GameTree);
procedure SetCurrentNode(G : GameTree);


{fonction de symetrie}
procedure EffectueSymetrieArbreDeJeuGlobal(axeSymetrie : SInt32);


{fonctions de gestion des positions initiales}
procedure SetPositionInitialeOfGameTree(position : plateauOthello;trait,nbBlancs,nbNoirs : SInt16);
procedure SetPositionInitialeStandardDansGameTree;
procedure GetPositionInitialeOfGameTree(var position : plateauOthello; var numeroPremierCoup,trait,nbBlancs,nbNoirs : SInt32);
function GetPositionEtTraitInitiauxOfGameTree() : PositionEtTraitRec;
function GameTreeHasStandardInitialPosition() : boolean;
procedure CalculePositionInitialeFromThisRoot(whichRoot : GameTree);
function CalculeNouvellePositionInitialeFromThisList(L : PropertyList; var jeu : plateauOthello; var numeroPremierCoup,trait,nbBlancs,nbNoirs : SInt32) : boolean;
procedure AjouteDescriptionPositionEtTraitACeNoeud(description : PositionEtTraitRec; var G : GameTree);
procedure DeleteDescriptionPositionEtTraitDeCeNoeud(var G : GameTree);


{fonctions de gestions des infos standard dans les fichiers SGF}
procedure AddInfosStandardsFormatSGFDansArbre;
function GetApplicationNameDansArbre(var name : str255; var version : str255) : boolean;


{gestions des commentaires}
function NoeudHasCommentaire(G : GameTree) : boolean;
procedure DeleteCommentaireDeCeNoeud(var G : GameTree);
procedure GetCommentaireDeCeNoeud(G : GameTree; var texte : Ptr; var longueur : SInt32);
procedure SetCommentaireDeCeNoeud(var G : GameTree;texte : Ptr;longueur : SInt32);
procedure SetCommentaireDeCeNoeudFromString(var G : GameTree;s : str255);
function CurrentNodeHasCommentaire() : boolean;
procedure DeleteCommentaireCurrentNode;
procedure GetCommentaireCurrentNode(var texte : Ptr; var longueur : SInt32);
procedure SetCommentaireCurrentNode(texte : Ptr;longueur : SInt32);
procedure SetCommentaireCurrentNodeFromString(s : str255);
procedure SetCommentairesCurrentNodeFromFenetreArbreDeJeu;


{fonctions calculant une position dans l'arbre, le trait ou les pions retournes}
function CreateListeDesCoupsJusqua(G : GameTree) : PropertyList;
function CreatePartieEnAlphaJusqua(G : GameTree; var partieAlpha : str255; var positionTerminale : PositionEtTraitRec) : boolean;
function GetPositionEtTraitACeNoeud(G : GameTree; var position : PositionEtTraitRec) : boolean;
function GetCouleurOfCurrentNode() : SInt32;
(*function GetFlippedDiscsAtThisNode(G : GameTree) : SquareSet;*)


{fonctions pour rajouter un score ou une ligne parfaite}
procedure AjoutePropertyValeurExacteCoupDansCurrentNode(quelGenreDeReflexion,scorePourNoir : SInt32);
function SelectScorePropertyOfCurrentNode() : PropertyPtr;
procedure AjouteMeilleureSuiteDansGameTree(genreReflexion : SInt32;meilleureSuite : str255;scoreDeNoir : SInt32;G : GameTree;exclamation : boolean;virtualite : SInt16);
procedure AjouteMeilleureSuiteDansArbreDeJeuCourant(genreReflexion : SInt32;meilleureSuite : str255;scoreDeLaLignePourNoir : SInt32);
procedure MarquerCurrentNodeCommeVirtuel;
procedure MarquerCurrentNodeCommeReel(const fonctionAppelante : str255);


{recherche dans l'arbre de jeu}
procedure FindStringDansArbreDeJeuCourant(s : str255);
procedure ChercherLeProchainNoueudAvecBeaucoupDeFils(nbreDeFils : SInt32);



IMPLEMENTATION







USES UnitStrategie,UnitEndgameTree,UnitHashTableExacte,UnitFenetres,UnitGameTree,UnitInterversions,
     UnitServicesDialogs,UnitMiniProfiler,UnitRapport,MyStrings,UnitSetUp,UnitGestionDuTemps,SNStrings,
     UnitOth2,UnitScannerOthellistique,UnitCarbonisation;

     
var RacineDeLaPartie:
       record
         RacineArbre                : GameTree;
         InitialPosition            : plateauOthello;
         TraitInitial               : SInt16; 
         nbPionsBlancsInitial       : SInt16; 
         nbPionsNoirsInitial        : SInt16; 
         initialPositionIsStandard  : boolean;
       end;
    GameTreeCourant : GameTree;




procedure InitUnitArbreDeJeuCourant;
begin
  avecAlerteSoldeCreationDestructionNonNul := true;
  SoldeCreationProperties := 0;
  SoldeCreationPropertyList := 0;
  SoldeCreationGameTree := 0;
  SoldeCreationGameTreeList := 0;
  
  RacineDeLaPartie.RacineArbre := NewGameTree();
  GameTreeCourant              := RacineDeLaPartie.RacineArbre;
  
  
  CreeTableHachageInterversions;
  VideTableHashageInterversions;
  SetNbCollisionsInterversions(0);
  
end;

procedure LibereMemoireUnitArbreDeJeuCourant;
begin
  {if GameTreeCourant <> NIL              then DisposeGameTree(GameTreeCourant);}
  if RacineDeLaPartie.RacineArbre <> NIL then DisposeGameTree(RacineDeLaPartie.RacineArbre);
  DisposeTableHachageInterversions;
end;

procedure DisposeGameTreeGlobalDeLaPartie;
var grow,TaillePlusGrandBloc:Size;
{$IFC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL}
    nomFichierProfileDisposeGameTree : str255;
{$ENDC}
begin
  {WritelnSoldesCreationsPropertiesDansRapport('en entrant dans DisposeGameTreeGlobalDeLaPartie, ');
  WritelnStringAndNumDansRapport('avant MaxMem, FreeMem = ',FreeMem);}
  
  TaillePlusGrandBloc := MaxMem(grow);
  
  {
  WritelnStringAndNumDansRapport('apres MaxMem, FreeMem = ',FreeMem);
  WritelnStringAndNumDansRapport('apres MaxMem, grow = ',grow);
  WritelnStringAndNumDansRapport('apres MaxMem, TaillePlusGrandBloc = ',TaillePlusGrandBloc);
  }
  
  {if GameTreeCourant <> NIL              then DisposeGameTree(GameTreeCourant);}
  
  
{$IFC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL}
  if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr 
    then ProfilerSetStatus(1);
{$ENDC}
  
  if RacineDeLaPartie.RacineArbre <> NIL then DisposeGameTree(RacineDeLaPartie.RacineArbre);

{$IFC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL}
  nomFichierProfileDisposeGameTree := 'dispose_game_tree_' + NumEnString(Tickcount() div 60) + '.profile';
  WritelnDansRapport('nomFichierProfileDisposeGameTree = '+nomFichierProfileDisposeGameTree);
  if ProfilerDump(nomFichierProfileDisposeGameTree) <> NoErr 
    then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfileDisposeGameTree+') a échoué !')
    else ProfilerSetStatus(0);
  ProfilerTerm;
{$ENDC}
  
  if avecAlerteSoldeCreationDestructionNonNul &
     ((SoldeCreationProperties <> 0) | (SoldeCreationPropertyList <> 0) | 
      (SoldeCreationGameTree <> 0) | (SoldeCreationGameTreeList <> 0)) then
    begin
      AlerteSimple('Erreur dans le solde creations-destruction de memoire, voir le rapport !!! Prévénez Stéphane');
		  WritelnSoldesCreationsPropertiesDansRapport('Erreur : en sortant de DisposeGameTreeGlobalDeLaPartie, ');
    end;
  
  
  
  {
  WritelnStringAndNumDansRapport('avant MaxMem, FreeMem = ',FreeMem);
  }
  
  TaillePlusGrandBloc := MaxMem(grow);
  
  {WritelnStringAndNumDansRapport('apres MaxMem, FreeMem = ',FreeMem);
  WritelnStringAndNumDansRapport('apres MaxMem, grow = ',grow);}
  {WritelnStringAndNumDansRapport('apres MaxMem, mémoire disponible = ',TaillePlusGrandBloc);}
  {WritelnStringAndNumDansRapport('apres MaxMem, FreeMem = ',FreeMem);}
  
  
  
end;

procedure ReInitialiseGameRootGlobalDeLaPartie;
begin
  DisposeGameTreeGlobalDeLaPartie;
  RacineDeLaPartie.RacineArbre := NewGameTree();
  GameTreeCourant              := RacineDeLaPartie.RacineArbre;
  SetPositionInitialeStandardDansGameTree;
  VideTableHashageInterversions;
end;



function PlayMoveProperty(prop : Property; var positionEtTrait : PositionEtTraitRec) : boolean;
var traitProp,coup : SInt32;
    traitPosition : SInt32;
    ok : boolean;
begin
  PlayMoveProperty := true;
  
  if (prop.genre = BlackMoveProp) then traitProp := pionNoir else
  if (prop.genre = WhiteMoveProp) then traitProp := pionBlanc else
    begin
      PlayMoveProperty := false;
      exit(PlayMoveProperty);
    end;
    
  traitPosition := GetTraitOfPosition(positionEtTrait);
  
  if (traitProp <> traitPosition) then
    begin
      PlayMoveProperty := false;
      exit(PlayMoveProperty);
    end;
  
  coup := GetOthelloSquareOfProperty(prop);
  if (coup < 11) | (coup > 88) then
    begin
      PlayMoveProperty := false;
      exit(PlayMoveProperty);
    end;
  
  ok := (positionEtTrait.position[coup] = pionVide) & 
        UpdatePositionEtTrait(positionEtTrait,coup);
  if not(ok) then
    begin
      PlayMoveProperty := false;
      exit(PlayMoveProperty);
    end;  
end;




procedure GetPropertyListOfCurrentNode(var L : PropertyList);
begin
  if GameTreeCourant = NIL
    then L := NIL
    else L := GameTreeCourant^.properties;
end;


procedure SetPropertyListOfCurrentNode(L : PropertyList);
begin
  if GameTreeEstVide(GameTreeCourant)
    then GameTreeCourant := MakeGameTreeFromPropertyList(L)
    else GameTreeCourant^.properties := L;
end;


procedure AddPropertyToCurrentNode(prop : Property);
begin
  AddPropertyToGameTree(prop,GameTreeCourant);
end;

procedure AddPropertyToCurrentNodeSansDuplication(prop : Property);
begin
  AddPropertyToGameTreeSansDuplication(prop,GameTreeCourant);
end;

procedure AddScorePropertyToCurrentNodeSansDuplication(prop : Property);
begin
  AddScorePropertyToGameTreeSansDuplication(prop,GameTreeCourant);
end;


procedure DeletePropertyFromCurrentNode(prop : Property);
begin
  DeletePropertyFromGameNode(prop,GameTreeCourant);
end;

procedure DeletePropertiesOfTheseTypeFromCurrentNode(whichType : SInt16);
begin
  DeletePropertiesOfTheseTypeFromGameNode(whichType,GameTreeCourant);
end;

procedure DeletePropertiesOfTheseTypesFromCurrentNode(whichTypes : SetOfPropertyTypes);
begin
  DeletePropertiesOfTheseTypesFromGameNode(whichTypes,GameTreeCourant);
end;

function SelectFirstPropertyOfTypesInCurrentNode(whichTypes : SetOfPropertyTypes) : PropertyPtr;
var L : PropertyList;
begin
  GetPropertyListOfCurrentNode(L);
  SelectFirstPropertyOfTypesInCurrentNode := SelectFirstPropertyOfTypes(whichTypes,L);
end;

function SelectPropertyInCurrentNode(choice:PropertyPredicate; var result : SInt32) : PropertyPtr;
var L : PropertyList;
begin
  GetPropertyListOfCurrentNode(L);
  SelectPropertyInCurrentNode := SelectInPropertList(L,choice,result);
end;

procedure ForEachPropertyOfTheseTypesInCurrentNodeDo(whichTypes : SetOfPropertyTypes;DoWhat:PropertyProc);
var L,L2 : PropertyList;
begin
   GetPropertyListOfCurrentNode(L);
	 L2 := ExtractPropertiesOfTypes(whichTypes,L);
	 ForEachPropertyInListDo(L2,DoWhat);
	 DisposePropertyList(L2);
end;


function GetCurrentNode() : GameTree;
begin
  GetCurrentNode := GameTreeCourant;
end;


function GetRacineDeLaPartie() : GameTree;
begin
  GetRacineDeLaPartie := RacineDeLaPartie.RacineArbre;
end;

function EstLaRacineDeLaPartie(G : GameTree) : boolean;
begin
  EstLaRacineDeLaPartie := (G = RacineDeLaPartie.RacineArbre);  {egalité des pointeurs}
end;

function NbDeFilsOfCurrentNode() : SInt16; 
begin
  NbDeFilsOfCurrentNode := NumberOfSons(GetCurrentNode());
end;

function GetCurrentSons() : GameTreeList;
begin
  GetCurrentSons := GetSons(GetCurrentNode());
end;

procedure SetCurrentNodeToGameRoot;
begin
  GameTreeCourant := RacineDeLaPartie.RacineArbre;
end;

procedure SetSonsOfCurrentNode(theSons : GameTreeList);
begin
  SetSons(GameTreeCourant,theSons);
end;


procedure BringSonOfCurrentNodeToFront(whichSon : GameTree);
var theSons : GameTreeList;
begin
  theSons := GetSons(GetCurrentNode());
  BringToFrontInGameTreeList(whichSon,theSons);
  SetSonsOfCurrentNode(theSons);
end;


procedure BringSonOfCurrentNodeInPositionN(whichSon : GameTree;N : SInt16);
var theSons : GameTreeList;
begin
  theSons := GetSons(GetCurrentNode());
  BringToPositionNInGameTreeList(whichSon,N,theSons);
  SetSonsOfCurrentNode(theSons);
end;



function GetCouleurOfCurrentNode() : SInt32;
begin
  GetCouleurOfCurrentNode := GetCouleurOfMoveInNode(GetCurrentNode());
end;

function VerifieHomogeneiteDesCouleurs(G : GameTree;ProblemePourLesCoupsVides : boolean) : SInt16; 
var brothers,L,L1 : GameTreeList;
    firstColor,ColorOfThisBrother : SInt32;
    ErreurForceePourPhaseDeTest : boolean;
begin
  VerifieHomogeneiteDesCouleurs := 0;
  if (G = NIL) then exit(VerifieHomogeneiteDesCouleurs);
    
  brothers := GetBrothers(G);
  
  if (brothers = NIL) & (EstLaRacineDeLaPartie(G)) then
    exit(VerifieHomogeneiteDesCouleurs);  {c'est normal}
    
    
  if (brothers = NIL) then
    begin
      if debuggage.arbreDeJeu then
        begin
		      WritelnDansRapport('');
		      WritelnDansRapport('erreur dans VerifieHomogeneiteDesCouleurs : brothers = NIL !!');
		      WritelnStringAndNumDansRapport('adresse du noeud = ',SInt32(G));
		      WritelnStringAndNumDansRapport('adresse de la racine = ',SInt32(GetRacineDeLaPartie()));
		      WritelnDansRapport('');
		    end;
      VerifieHomogeneiteDesCouleurs := -1;
      exit(VerifieHomogeneiteDesCouleurs);
    end;
  
  
  ErreurForceePourPhaseDeTest := false;
  
  L := brothers;
  firstColor := GetCouleurOfMoveInNode(L^.head);
  while L <> NIL do
    begin
      L := L^.tail;
      if (L <> NIL) then
        begin
          ColorOfThisBrother := GetCouleurOfMoveInNode(L^.head);
          
         {ErreurForceePourPhaseDeTest := UnChanceSurN(100);}
          ErreurForceePourPhaseDeTest := false;
          if ErreurForceePourPhaseDeTest then WritelnDansRapport('Random() dans VerifieHomogeneiteDesCouleurs');
          
          if ErreurForceePourPhaseDeTest |
             ((ColorOfThisBrother<>FirstColor) & 
              (ProblemePourLesCoupsVides | ((firstColor <> pionVide) & (ColorOfThisBrother <> pionVide)))) then
	          begin
	            AlerteSimple('Deux couleurs différentes dans des noeuds freres dans VerifieHomogeneiteDesCouleurs!! Prévenez Stéphane');
		          {if debuggage.arbreDeJeu then}
		            begin
		              WritelnDansRapport('');
		              WritelnDansRapport('la liste des freres fautifs est :');
				          L1 := brothers;
				          while L1 <> NIL do
				            begin
				              WritelnPropertyListDansRapport(L1^.head^.properties);
				              L1 := L1^.tail;
				            end;
				          WritelnDansRapport('');
				        end;
				      
				      VerifieHomogeneiteDesCouleurs := -1;
              exit(VerifieHomogeneiteDesCouleurs);
				    end;
        end;
    end;
end;


function ChangeCurrentNodeAfterThisMove(square,couleur : SInt16; const fonctionAppelante : str255; var isNew : boolean) : OSErr;
var noeudsDejaGeneres : SquareSet;
    FreresDeLaMauvaiseCouleur : SquareSet;
    prop : Property;
    subtree : GameTree;
    ProblemeDeCouleursDansLArbre,ErreurForceePourPhaseDeTest : boolean;
    err : OSErr;
begin
  ChangeCurrentNodeAfterThisMove := 0;
  ProblemeDeCouleursDansLArbre := false;
  isNew := true;
  
  if (square<11) | (square>88) then
    begin
      WritelnDansRapport('erreur : case hors de l''intervale (11..88) dans ChangeCurrentNodeAfterMove !!!');
      ChangeCurrentNodeAfterThisMove := -1;
      exit(ChangeCurrentNodeAfterThisMove);
    end;
  
  if (couleur<>pionNoir) & (couleur<>pionBlanc) then
    begin
      WritelnDansRapport('erreur : couleur non legale dans ChangeCurrentNodeAfterMove !!!');
      ChangeCurrentNodeAfterThisMove := -1;
      exit(ChangeCurrentNodeAfterThisMove);
    end;
    
  if GameTreeCourant = NIL then
    begin
      WritelnDansRapport('erreur : GameTreeCourant = NIL dans ChangeCurrentNodeAfterMove !!!');
      ChangeCurrentNodeAfterThisMove := -1;
      exit(ChangeCurrentNodeAfterThisMove);
    end;
  
  if debuggage.arbreDeJeu then
    WritelnDansRapport('appel de ChangeCurrentNodeAfterThisMove('+
                       CoupEnStringEnMajuscules(square)+','+NumEnString(couleur)+
                       ') par '+fonctionAppelante);
  
  err := VerifieHomogeneiteDesCouleurs(GameTreeCourant,true);
  if err <> 0 then
    begin
      WritelnDansRapport('on a reporté un probleme dans ChangeCurrentNodeAfterMove avant la creation du nouveau nœud, fonctionAppelante='+fonctionAppelante);
      ProblemeDeCouleursDansLArbre := true;
      ChangeCurrentNodeAfterThisMove := err;
      exit(ChangeCurrentNodeAfterThisMove);
    end;
    
  noeudsDejaGeneres := GetEnsembleDesCoupsDesFils(couleur,GameTreeCourant);
  
 {ErreurForceePourPhaseDeTest := UneChanceSur(10) & (Pos('JoueEn',fonctionAppelante)>0);}
  ErreurForceePourPhaseDeTest := false;
  
  FreresDeLaMauvaiseCouleur := GetEnsembleDesCoupsDesFils(-couleur,GameTreeCourant);
  if (FreresDeLaMauvaiseCouleur <> []) | ErreurForceePourPhaseDeTest then
    begin
    
      if ErreurForceePourPhaseDeTest then
        WritelnDansRapport('ErreurForceePourPhaseDeTest dans FreresDeLaMauvaiseCouleur dans ChangeCurrentNodeAfterMove');
    
      AlerteSimple('Problème : on s''apprete à créer deux noeuds freres de couleurs différentes !! Sauvegardez le rapport et prévenez Stéphane');
      WritelnDansRapport('Probleme : FreresDeLaMauvaiseCouleur dans ChangeCurrentNodeAfterMove, fonctionAppelante='+fonctionAppelante);
      
      case couleur of 
          pionNoir    : prop := MakeOthelloSquareProperty(BlackMoveProp,square);
          pionBlanc   : prop := MakeOthelloSquareProperty(WhiteMoveProp,square);
          otherwise     prop := MakeEmptyProperty();
      end; {case}
      WritelnStringAndPropertyDansRapport('je dois créer le fils suivant : ',prop);
      DisposePropertyStuff(prop);
        
      case couleur of 
          pionNoir    : WritelnDansRapport('Les freres de la mauvaise couleur (ennemie) existant deja sont : W'+SquareSetEnString(FreresDeLaMauvaiseCouleur));
          pionBlanc   : WritelnDansRapport('Les freres de la mauvaise couleur (ennemie) existant deja sont : B'+SquareSetEnString(FreresDeLaMauvaiseCouleur));
          otherwise     WritelnDansRapport('Les freres de la mauvaise couleur (ennemie) existant deja sont : '+SquareSetEnString(FreresDeLaMauvaiseCouleur));
      end; {case}
      
      ProblemeDeCouleursDansLArbre := true;
      
      ChangeCurrentNodeAfterThisMove := -1;
      exit(ChangeCurrentNodeAfterThisMove);
    end;
  
  if debuggage.arbreDeJeu | ProblemeDeCouleursDansLArbre then
    begin
      if (noeudsDejaGeneres = [])
        then
          case couleur of
		        pionBlanc : WritelnDansRapport('pas de fils blancs du noeud courant ! ');
		        pionNoir  : WritelnDansRapport('pas de fils noirs du noeud courant ! ');
		      end
        else
		      case couleur of
		        pionBlanc : WritelnDansRapport('fils blancs du noeud courant = '+SquareSetEnString(noeudsDejaGeneres));
		        pionNoir  : WritelnDansRapport('fils noirs du noeud courant = '+SquareSetEnString(noeudsDejaGeneres));
		      end;
    end;
    
  if square in noeudsDejaGeneres
    then
      begin
        isNew := false;
        case couleur of 
          pionNoir    : prop := MakeOthelloSquareProperty(BlackMoveProp,square);
          pionBlanc   : prop := MakeOthelloSquareProperty(WhiteMoveProp,square);
          otherwise     prop := MakeEmptyProperty();
        end; {case}
        GameTreeCourant := SelectFirstSubtreeWithThisProperty(prop,GameTreeCourant);
        DisposePropertyStuff(prop);
      end
    else 
      begin
        isNew := true;
        case couleur of 
          pionNoir    : prop := MakeOthelloSquareProperty(BlackMoveProp,square);
          pionBlanc   : prop := MakeOthelloSquareProperty(WhiteMoveProp,square);
          otherwise     prop := MakeEmptyProperty();
        end; {case}
        
        if debuggage.arbreDeJeu | ProblemeDeCouleursDansLArbre then
           WritelnStringAndPropertyDansRapport(Concat(fonctionAppelante, ' : création de '),prop);
        
        subtree := MakeGameTreeFromProperty(prop);
        AddSonToGameTree(subtree,GameTreeCourant);
        GameTreeCourant := SelectFirstSubtreeWithThisProperty(prop,GameTreeCourant);
        DisposeGameTree(subtree);
        DisposePropertyStuff(prop);
      end;
    
  err := VerifieHomogeneiteDesCouleurs(GameTreeCourant,true);
  if err <> 0 then
    begin
      WritelnDansRapport('on a reporté un probleme dans ChangeCurrentNodeAfterMove apres la creation du nouveau nœud, fonctionAppelante='+fonctionAppelante);
      ProblemeDeCouleursDansLArbre := true;
      ChangeCurrentNodeAfterThisMove := err;
      exit(ChangeCurrentNodeAfterThisMove);
    end;
    
end;


function ChangeCurrentNodeAfterNewMove(square,couleur : SInt16; const fonctionAppelante : str255) : OSErr;
var isNew : boolean;
begin
  ChangeCurrentNodeAfterNewMove := ChangeCurrentNodeAfterThisMove(square,couleur,fonctionAppelante,isNew);
end;

procedure ChangeCurrentNodeForBackMove;
begin
  if not(GameTreeEstVide(GameTreeCourant)) & not(GameTreeEstVide(GameTreeCourant^.father)) then
    GameTreeCourant := GameTreeCourant^.father;
  
   if VerifieHomogeneiteDesCouleurs(GameTreeCourant,true) <> 0 then
     WritelnDansRapport('on a reporté un probleme dans ChangeCurrentNodeForBackMove');

end;

procedure DoChangeCurrentNodeBackwardUntil(G : GameTree);
begin
  if (G = NIL) | (GameTreeCourant = G) then 
    exit(DoChangeCurrentNodeBackwardUntil);
  
	while not(GameTreeEstVide(GameTreeCourant)) & not(GameTreeEstVide(GameTreeCourant^.father)) do
		begin
		  GameTreeCourant := GameTreeCourant^.father;
		  if (GameTreeCourant = G) then exit(DoChangeCurrentNodeBackwardUntil);
    end;
  
   if VerifieHomogeneiteDesCouleurs(GameTreeCourant,true) <> 0 then
     WritelnDansRapport('on a reporté un probleme dans DoChangeCurrentNodeBackwardUntil');

end;
 
procedure SetCurrentNode(G : GameTree);
begin
  if (G = NIL) | (GameTreeCourant = G) then 
    exit(SetCurrentNode);
  
  GameTreeCourant := G;
  
  if VerifieHomogeneiteDesCouleurs(GameTreeCourant,false) <> 0 then
    WritelnDansRapport('on a reporté un probleme dans SetCurrentNode');
end;

procedure EffectueSymetrieArbreDeJeuGlobal(axeSymetrie : SInt32);
begin
  EffectueSymetrieOnGameTree(GetRacineDeLaPartie(),axeSymetrie);
end;


procedure SetPositionInitialeOfGameTree(position : plateauOthello;trait,nbBlancs,nbNoirs : SInt16);
begin
  with RacineDeLaPartie do
    begin
      InitialPosition           := position;
      TraitInitial              := trait;
      nbPionsBlancsInitial      := nbBlancs;
      nbPionsNoirsInitial       := nbNoirs;
      initialPositionIsStandard := SamePositionEtTrait(MakePositionEtTrait(position,trait),PositionEtTraitInitiauxStandard());
    end;
    
  {
  with RacineDeLaPartie do
    begin
      WritelnPositionEtTraitDansRapport(position,traitInitial);
      WritelnStringAndNumDansRapport('traitInitial=',traitInitial);
      WritelnStringAndNumDansRapport('nbPionsBlancsInitial=',nbPionsBlancsInitial);
      WritelnStringAndNumDansRapport('nbPionsNoirsInitial=',nbPionsNoirsInitial);
    end;
  }
end;


procedure SetPositionInitialeStandardDansGameTree;
var jeu : plateauOthello;
    nBla,nNoi : SInt32;
begin
  OthellierEtPionsDeDepart(jeu,nBla,nNoi);
  SetPositionInitialeOfGameTree(jeu,pionNoir,nBla,nNoi);
end;


procedure GetPositionInitialeOfGameTree(var position : plateauOthello; var numeroPremierCoup,trait,nbBlancs,nbNoirs : SInt32);
begin
  with RacineDeLaPartie do
    begin
      position := InitialPosition;
      trait    := TraitInitial;
      nbBlancs := nbPionsBlancsInitial;
      nbNoirs  := nbPionsNoirsInitial;
      
      numeroPremierCoup := nbBlancs+nbNoirs-4+1;
    end;
end;

function GetPositionEtTraitInitiauxOfGameTree() : PositionEtTraitRec;
var plat : plateauOthello;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
begin
  GetPositionInitialeOfGameTree(plat,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
  GetPositionEtTraitInitiauxOfGameTree := MakePositionEtTrait(plat,traitInitial);
end;


function GameTreeHasStandardInitialPosition() : boolean;
begin
  GameTreeHasStandardInitialPosition := RacineDeLaPartie.initialPositionIsStandard;
end;

function CalculeNouvellePositionInitialeFromThisList(L : PropertyList; var jeu : plateauOthello; var numeroPremierCoup,trait,nbBlancs,nbNoirs : SInt32) : boolean;
var aux : PropertyPtr;
    theSquares : SquareSet;
    c : char;
    i : SInt16; 
begin
  
  CalculeNouvellePositionInitialeFromThisList := false;
  VideOthellier(jeu);
  
  nbNoirs := 0;
  aux := SelectFirstPropertyOfTypes([AddBlackStoneProp],L);
  if aux <> NIL then
    begin
      theSquares := GetSquareSetOfProperty(aux^);
      for i := 11 to 88 do
        if i in theSquares then
          begin
            inc(nbNoirs);
            jeu[i] := pionNoir;
            CalculeNouvellePositionInitialeFromThisList := true;
          end;
    end;
  
  nbBlancs := 0;
  aux := SelectFirstPropertyOfTypes([AddWhiteStoneProp],L);
  if aux <> NIL then
    begin
      theSquares := GetSquareSetOfProperty(aux^);
      for i := 11 to 88 do
        if i in theSquares then
          begin
            inc(nbBlancs);
            jeu[i] := pionBlanc;
            CalculeNouvellePositionInitialeFromThisList := true;
          end;
    end;
  
  numeroPremierCoup := nbNoirs+nbBlancs-4+1;
  
  if odd(nbNoirs+nbBlancs)  {parité naturelle par défaut}
    then trait := pionBlanc
    else trait := pionNoir;  
  aux := SelectFirstPropertyOfTypes([PlayerToPlayFirstProp],L);
  if aux <> NIL then 
    begin
      c := GetCharOfProperty(aux^);
      if (c='B') | (c='b') then trait := pionNoir else
      if (c='W') | (c='w') then trait := pionBlanc;
      CalculeNouvellePositionInitialeFromThisList := true;
    end;
end;



procedure CalculePositionInitialeFromThisRoot(whichRoot : GameTree);
var trait,nbNoirs,nbBlancs,numeroPremierCoup : SInt32;
    jeu : plateauOthello;
begin
  SetPositionInitialeStandardDansGameTree;  {par defaut}
  
  if (whichRoot <> NIL) then
    begin
      if CalculeNouvellePositionInitialeFromThisList(whichRoot^.properties,jeu,numeroPremierCoup,trait,nbBlancs,nbNoirs) then
        if (nbBlancs+nbNoirs>=3) then
          SetPositionInitialeOfGameTree(jeu,trait,nbBlancs,nbNoirs);
    end;
  
end;

procedure AjouteDescriptionPositionEtTraitACeNoeud(description : PositionEtTraitRec; var G : GameTree);
var prop : Property;
    squares : SquareSet;
    i : SInt16; 
begin
  if (G <> NIL) then
    begin
      {les pions noirs}
      squares := [];
      for i := 1 to 64 do
        if description.position[othellier[i]] = pionNoir then 
          squares := squares + [othellier[i]];
      prop := MakeSquareSetProperty(AddBlackStoneProp,squares);
      AddPropertyToList(prop,G^.properties);
      DisposePropertyStuff(prop);
      
      {les pions blancs}
      squares := [];
      for i := 1 to 64 do
        if description.position[othellier[i]] = pionBlanc then 
          squares := squares + [othellier[i]];
      prop := MakeSquareSetProperty(AddWhiteStoneProp,squares);
      AddPropertyToList(prop,G^.properties);
      DisposePropertyStuff(prop);
      
      if (GetTraitOfPosition(description) <> pionVide) then
        begin
          if (GetTraitOfPosition(description) = pionNoir)
            then prop := MakeCharProperty(PlayerToPlayFirstProp,'B')
            else prop := MakeCharProperty(PlayerToPlayFirstProp,'W');
          AddPropertyToList(prop,G^.properties);
          DisposePropertyStuff(prop);
        end;
      
    end;
end;


procedure DeleteDescriptionPositionEtTraitDeCeNoeud(var G : GameTree);
var aux : PropertyPtr;
begin
  if (G <> NIL) then
    begin
      aux := SelectFirstPropertyOfTypes([AddBlackStoneProp],G^.properties);
      if aux <> NIL then DeletePropertyFromList(aux^,G^.properties);
      
      aux := SelectFirstPropertyOfTypes([AddWhiteStoneProp],G^.properties);
      if aux <> NIL then DeletePropertyFromList(aux^,G^.properties);
      
      aux := SelectFirstPropertyOfTypes([PlayerToPlayFirstProp],G^.properties);
      if aux <> NIL then DeletePropertyFromList(aux^,G^.properties);
    end;
end;


procedure AddInfosStandardsFormatSGFDansArbre;
var prop : Property;
    myDate : DateTimeRec;
    changed : boolean;
begin
  
  {game ID}
  prop := MakeLongintProperty(GameNumberIDProp,2);    { 2 = Othello}
  OverWritePropertyToGameTree(prop,GetRacineDeLaPartie(),changed);
  DisposePropertyStuff(prop);
  
  {file format}
  prop := MakeLongintProperty(FileFormatProp,4);
  OverWritePropertyToGameTree(prop,GetRacineDeLaPartie(),changed);
  DisposePropertyStuff(prop);
  
  {creator application name}
  if SelectFirstPropertyOfTypesInGameTree([ApplicationProp],GetRacineDeLaPartie()) = NIL then
    begin
      prop := MakeStringProperty(ApplicationProp,'Cassio:'+VersionDeCassioEnString());
      AddPropertyToGameTree(prop,GetRacineDeLaPartie());
      DisposePropertyStuff(prop);
    end;
  
  {user}
  if SelectFirstPropertyOfTypesInGameTree([UserProp],GetRacineDeLaPartie()) = NIL then
    begin
      prop := MakeStringProperty(UserProp,'Stephane Nicolet');
      AddPropertyToGameTree(prop,GetRacineDeLaPartie());
      DisposePropertyStuff(prop);
    end;
    
  {date}
  if SelectFirstPropertyOfTypesInGameTree([DateProp],GetRacineDeLaPartie()) = NIL then
    begin
      GetTime(myDate);
      prop := MakeStringProperty(DateProp,NumEnString(myDate.year)+'-'+
                                        NumEnString(myDate.month)+'-'+
                                        NumEnString(myDate.day));
      AddPropertyToGameTree(prop,GetRacineDeLaPartie());
      DisposePropertyStuff(prop);
    end;
  
  {copyright}
  if SelectFirstPropertyOfTypesInGameTree([CopyrightProp],GetRacineDeLaPartie()) = NIL then
    begin
      GetTime(myDate);
      prop := MakeStringProperty(CopyrightProp,'Copyleft '+NumEnString(myDate.year)+', French Federation of Othello');
      AddPropertyToGameTree(prop,GetRacineDeLaPartie());
      DisposePropertyStuff(prop);
    end;
  
  {board size}
  if SelectFirstPropertyOfTypesInGameTree([BoardSizeProp],GetRacineDeLaPartie()) = NIL then
    begin
      prop := MakeLongintProperty(BoardSizeProp,8);
      AddPropertyToGameTree(prop,GetRacineDeLaPartie());
      DisposePropertyStuff(prop);
    end;
  
  {time limit}
  if SelectFirstPropertyOfTypesInGameTree([TimeLimitByPlayerProp],GetRacineDeLaPartie()) = NIL then
    begin
      if (GetCadence() = minutes10000000)
        then prop := MakeLongintProperty(TimeLimitByPlayerProp,1500)    {defaut=25 min.}
        else prop := MakeLongintProperty(TimeLimitByPlayerProp,GetCadence());
		  OverWritePropertyToGameTree(prop,GetRacineDeLaPartie(),changed);
		  DisposePropertyStuff(prop);
		end;
		
  {time for black}
  if SelectFirstPropertyOfTypesInGameTree([TimeLeftBlackProp],GetRacineDeLaPartie()) = NIL then
    begin
		  if (GetCadence() <> minutes10000000)
        then prop := MakeLongintProperty(TimeLeftBlackProp,GetCadence())
        else prop := MakeLongintProperty(TimeLeftBlackProp,1500); {defaut=25 min.}
		  OverWritePropertyToGameTree(prop,GetRacineDeLaPartie(),changed);
		  DisposePropertyStuff(prop);
		end;
  
  {time for white}
  if SelectFirstPropertyOfTypesInGameTree([TimeLeftWhiteProp],GetRacineDeLaPartie()) = NIL then
    begin
		  if (GetCadence() <> minutes10000000)
        then prop := MakeLongintProperty(TimeLeftWhiteProp,GetCadence())
        else prop := MakeLongintProperty(TimeLeftWhiteProp,1500); {defaut=25 min.}
		  OverWritePropertyToGameTree(prop,GetRacineDeLaPartie(),changed);
		  DisposePropertyStuff(prop);
		end;
	
	{result}
	(*
	s := CoupsOfMainLineInGameTreeEnString(GetRacineDeLaPartie());
	WritelnDansRapport('MainLine = '+s);
	*)
	(*
	prop := MakeLongintProperty(GameNumberIDProp,2);    { 2 = Othello}
  OverWritePropertyToGameTree(prop,GetRacineDeLaPartie(),changed);
  DisposePropertyStuff(prop);
  *)
    
end;


function GetApplicationNameDansArbre(var name : str255; var version : str255) : boolean;
var aux : PropertyPtr;
    s : str255;
    positionDeuxPoints : SInt16; 
begin
  aux := SelectFirstPropertyOfTypesInGameTree([ApplicationProp],GetRacineDeLaPartie());
  
  if (aux = NIL)
    then s := ''
    else s := GetStringInfoOfProperty(aux^);
  
  if (s = '')
    then
      begin
        name := '';
        version := '';
        GetApplicationNameDansArbre := false;
      end
    else 
      begin
        positionDeuxPoints := Pos(':',s);
        if positionDeuxPoints>0
          then
            begin
              name := TPCopy(s,1,positionDeuxPoints-1);
              version := TPCopy(s,positionDeuxPoints+1,Length(s)-positionDeuxPoints);
            end
          else
            begin
              name := s;
              version := '';
            end;
        GetApplicationNameDansArbre := true;
      end;
end;

procedure DeleteCommentaireDeCeNoeud(var G : GameTree);
var aux : PropertyPtr;
begin
  if (G <> NIL) then
    begin
      if EstLaRacineDeLaPartie(G)
        then aux := SelectFirstPropertyOfTypes([GameCommentProp],G^.properties)
        else aux := SelectFirstPropertyOfTypes([CommentProp],G^.properties);
      {if aux = NIL
        then WritelnDansRapport('aux = NIL')
        else WritelnStringAndPropertyDansRapport('aux = ',aux^);}
      if aux <> NIL then DeletePropertyFromList(aux^,G^.properties);
      {WritelnStringAndPropertyListDansRapport('G^.properties=',G^.properties);}
    end;
end;

function NoeudHasCommentaire(G : GameTree) : boolean;
var texte : Ptr;
    longueur : SInt32;
begin
  GetCommentaireDeCeNoeud(G,texte,longueur);
  NoeudHasCommentaire := (texte <> NIL) & (longueur > 0);
end;

function CurrentNodeHasCommentaire() : boolean;
begin
  CurrentNodeHasCommentaire := NoeudHasCommentaire(GetCurrentNode());
end;

procedure DeleteCommentaireCurrentNode;
var G : GameTree;
begin
  G := GetCurrentNode();
  DeleteCommentaireDeCeNoeud(G);
end;

procedure GetCommentaireDeCeNoeud(G : GameTree; var texte : Ptr; var longueur : SInt32);
var aux : PropertyPtr;
    s : str255;
begin
  texte := NIL;
  longueur := 0;
  if (G <> NIL) then
    begin
      if EstLaRacineDeLaPartie(G)  
        then aux := SelectFirstPropertyOfTypes([GameCommentProp],G^.properties)
        else aux := SelectFirstPropertyOfTypes([CommentProp],G^.properties);
      if aux <> NIL then 
        case aux^.stockage of
		      StockageEnStr255 : 
		        begin
		          s := GetStringInfoOfProperty(aux^);
		          if Length(s)=0
		            then 
		              begin
		                texte := NIL;
		                longueur := 0;
		              end
		            else
		              begin
		                texte := Ptr(SInt32(aux^.info)+1);
		                longueur := aux^.taille-1;
		              end;
		        end;
		      StockageEnTexte : 
		        begin
		          texte := aux^.info;
		          longueur := aux^.taille;
		        end;
		    end; {case}
    end;
end;


procedure SetCommentaireDeCeNoeud(var G : GameTree;texte : Ptr;longueur : SInt32);
var prop : Property;
begin
  if (G <> NIL) then
    begin
      DeleteCommentaireDeCeNoeud(G);
      if (texte <> NIL) & (longueur>0) then 
        begin
          if EstLaRacineDeLaPartie(G)  
            then prop := MakeTexteProperty(GameCommentProp,texte,longueur)
            else prop := MakeTexteProperty(CommentProp,texte,longueur);
          AddPropertyToList(prop,G^.properties);
          {WritelnStringAndPropertyListDansRapport('G^.properties=',G^.properties);}
          DisposePropertyStuff(prop);
        end;
    end;
end;


procedure SetCommentaireDeCeNoeudFromString(var G : GameTree;s : str255);
begin
  if (G <> NIL) then
    begin
      if s='' 
        then DeleteCommentaireDeCeNoeud(G)
        else SetCommentaireDeCeNoeud(G,@s[1],Length(s));
    end;
end;

procedure GetCommentaireCurrentNode(var texte : Ptr; var longueur : SInt32);
begin
  GetCommentaireDeCeNoeud(GetCurrentNode(),texte,longueur);
end;


procedure SetCommentaireCurrentNode(texte : Ptr;longueur : SInt32);
begin
  SetCommentaireDeCeNoeud(GetCurrentNode(),texte,longueur);
end;



procedure SetCommentaireCurrentNodeFromString(s : str255);
var G : GameTree;
begin
  G := GetCurrentNode();
  SetCommentaireDeCeNoeudFromString(G,s);
end;


procedure SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
var myText : TEHandle;
    longueur : SInt32;
    caracteres:CharsHandle;
    state : SignedByte;
begin
  with arbreDeJeu do
    if windowOpen & (GetArbreDeJeuWindow() <> NIL) then
      begin
        myText := GetDialogTextEditHandle(theDialog);
        if myText  <> NIL then
          begin
            longueur := TEGetTextLength(myText);
            caracteres := TEGetText(myText);
            state := HGetState(Handle(caracteres));
            HLock(Handle(caracteres));
            SetCommentaireCurrentNode(Ptr(caracteres^),longueur);
            HSetState(Handle(caracteres),state);
          end;
      end;
end;

{la fonction suivante est assez inefficace et pourrait etre acceleree}
function CreateListeDesCoupsJusqua(G : GameTree) : PropertyList;
var G1 : GameTree;
    CoupProp : PropertyPtr;
    ListeDesCoups : PropertyList;
begin
  if (G = NIL) | EstLaRacineDeLaPartie(G)
    then CreateListeDesCoupsJusqua := NIL
    else
      begin
			  ListeDesCoups := NIL;
			  G1 := G;
			  while (G1 <> NIL) & not(EstLaRacineDeLaPartie(G1)) do
			    begin
			      CoupProp := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],G1);
			      if coupProp <> NIL then 
			        AddPropertyInFrontOfList(coupProp^,ListeDesCoups);
			      if G1=G1^.father then
			        begin
			          AlerteSimple('Boucle infinie dans CreateListeDesCoupsJusqua !!! Prévenez Stéphane');
			          exit(CreateListeDesCoupsJusqua);
			        end;
			      G1 := G1^.father;
			    end;
			  CreateListeDesCoupsJusqua := DuplicatePropertyList(ListeDesCoups);
			  DisposePropertyList(ListeDesCoups);
			end;
end;


function CreatePartieEnAlphaJusqua(G : GameTree; var partieAlpha : str255; var positionTerminale : PositionEtTraitRec) : boolean;
var listeAReboursDesCoups : array[1..64] of PropertyPtr;
    nbCoupsDansListe,i : SInt32;
    G1 : GameTree;
    plat : plateauOthello;
    nbBlancs,nbNoirs : SInt32;
    numeroPremierCoup,trait : SInt32;
    coup : SInt16; 
    ok : boolean;
begin
  
  partieAlpha := '';
  CreatePartieEnAlphaJusqua := false;
  
  if (G = NIL) then
    begin
      positionTerminale := PositionEtTraitInitiauxStandard();
      exit(CreatePartieEnAlphaJusqua);
    end;
  
  if CalculeNouvellePositionInitialeFromThisList(GetRacineDeLaPartie()^.properties,plat,numeroPremierCoup,trait,nbBlancs,nbNoirs) 
    then positionTerminale := MakePositionEtTrait(plat,trait)
    else positionTerminale := PositionEtTraitInitiauxStandard();
    
  nbCoupsDansListe := 0;
  G1 := G;
  while not((G1 = NIL) | EstLaRacineDeLaPartie(G1)) do
    begin
      inc(nbCoupsDansListe);
      if (nbCoupsDansListe <= 64) then
        listeAReboursDesCoups[nbCoupsDansListe] := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],G1);
      
      if (G1 = G1^.father) then
        begin
          AlerteSimple('Boucle infinie dans CreatePartieEnAlphaJusqua !!! Prévenez Stéphane');
          positionTerminale := PositionEtTraitInitiauxStandard();
          CreatePartieEnAlphaJusqua := false;
          exit(CreatePartieEnAlphaJusqua);
        end;
        
      G1 := G1^.father;
    end;
  
  ok := false;
  if (nbCoupsDansListe > 0) then
    begin
      ok := true;
      for i := nbCoupsDansListe downto 1 do
        begin
          if (listeAReboursDesCoups[i] <> NIL)
            then coup := GetOthelloSquareOfProperty(listeAReboursDesCoups[i]^)
            else coup := 0;
          partieAlpha := Concat(partieAlpha,CoupEnStringEnMajuscules(coup));
          ok := ok & UpdatePositionEtTrait(positionTerminale,coup);
        end;
      
      if not(ok) then
        WritelnDansRapport('WARNING : CreatePartieEnAlphaJusqua = false');
    end;
  
  
  
  CreatePartieEnAlphaJusqua := ok;
end;


procedure ForEachPositionOnPathToGameNodeDo(G : GameTree;DoWhat:GameTreeProcAvecResult);
var numeroCoupTerminal : SInt32;
    position : PositionEtTraitRec;
    
  procedure ItererRecursivement(whichNode : GameTree;numeroCoup : SInt32);
  var continuer : boolean;
  begin
    if whichNode <> NIL then
      begin
        if whichNode=whichNode^.father then
          begin
            AlerteSimple('Boucle infinie dans ForEachPositionOnPathToCurrentNodeDo !!! Prévenez Stéphane');
            exit(ItererRecursivement);
          end;
        ItererRecursivement(whichNode^.father,numeroCoup-1);
        continuer := true;
        DoWhat(whichNode,numeroCoup,continuer);
      end;
  end;
  
begin  {ForEachPositionOnPathToGameNodeDo}
  if GetPositionEtTraitACeNoeud(G,position) then
    begin
      numeroCoupTerminal := 60 - NbCasesVidesDansPosition(position.position);
      ItererRecursivement(G,numeroCoupTerminal);
    end;
end;


procedure ForEachPositionOnPathToCurrentNodeDo(DoWhat:GameTreeProcAvecResult);
begin
  ForEachPositionOnPathToGameNodeDo(GetCurrentNode(),DoWhat);
end;



function GetPositionEtTraitACeNoeud(G : GameTree; var position : PositionEtTraitRec) : boolean;
var listeAReboursDesCoups : array[1..64] of PropertyPtr;
    nbCoupsDansListe,i : SInt32;
    G1 : GameTree;
    plat : plateauOthello;
    nbBlancs,nbNoirs : SInt32;
    numeroPremierCoup,trait : SInt32;
    ok : boolean;
    coup : SInt16; 
begin
  if (G = NIL) then 
    begin
      position := PositionEtTraitInitiauxStandard();
      GetPositionEtTraitACeNoeud := false;
      exit(GetPositionEtTraitACeNoeud);
    end;
  
  
  if CalculeNouvellePositionInitialeFromThisList(GetRacineDeLaPartie()^.properties,plat,numeroPremierCoup,trait,nbBlancs,nbNoirs)
    then position := MakePositionEtTrait(plat,trait)
    else position := PositionEtTraitInitiauxStandard();
    
  {
  WritelnDansRapport('apres CalculeNouvellePositionInitialeFromThisList dans GetPositionEtTraitACeNoeud :');
  WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
  }
  
  nbCoupsDansListe := 0;
  G1 := G;
  while not((G1 = NIL) | EstLaRacineDeLaPartie(G1)) do
    begin
      inc(nbCoupsDansListe);
      if (nbCoupsDansListe <= 64) then
        listeAReboursDesCoups[nbCoupsDansListe] := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],G1);
      
      if G1=G1^.father then
        begin
          AlerteSimple('Boucle infinie dans GetPositionEtTraitACeNoeud !!! Prévenez Stéphane');
          position := PositionEtTraitInitiauxStandard();
          GetPositionEtTraitACeNoeud := false;
          exit(GetPositionEtTraitACeNoeud);
        end;
        
      G1 := G1^.father;
    end;
    
  {
  WritelnStringAndNumDansRapport('nbCoupsDansListe = ',nbCoupsDansListe);
  WritelnDansRapport('');
  }
    
  ok := true;
  for i := nbCoupsDansListe downto 1 do
    begin
      if (listeAReboursDesCoups[i] <> NIL)
        then coup := GetOthelloSquareOfProperty(listeAReboursDesCoups[i]^)
        else coup := 0;
      ok := ok & UpdatePositionEtTrait(position,coup);
    end;
  
  if not(ok) then
    WritelnDansRapport('WARNING : GetPositionEtTraitACeNoeud = false');
    
  GetPositionEtTraitACeNoeud := ok;
end;


procedure AjouteMeilleureSuiteDansGameTree(genreReflexion : SInt32;meilleureSuite : str255;scoreDeNoir : SInt32;G : GameTree;exclamation : boolean;virtualite : SInt16);
 var scoreProperty,moveProperty,PointExclamationProp : Property;
     oldCurrentNode : GameTree;
     positionEtTrait : PositionEtTraitRec;
     whichSquare,vMinPourNoir,vMaxPourNoir : SInt32;
     positionDansChaine,positionParenthese : SInt16; 
     premierCoupDeLaSuite,ok,isNew,debugage : boolean;
     err : OSErr;
     estUnScoreDeFinale,confirmation : boolean;
begin
  debugage := false;
  
  if debugage then 
    begin
      WritelnStringAndNumDansRapport('entree de AjouteMeilleureSuiteDansGameTree : meilleureSuite = '+meilleureSuite+' et scoreDeNoir = ',scoreDeNoir);
    end;
    
  if (G = NIL) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT(G <> NIL) dans AjouteMeilleureSuiteDansGameTree !!');
      exit(AjouteMeilleureSuiteDansGameTree);
    end;

  if (G <> NIL) then
    begin
      estUnScoreDeFinale := GenreDeReflexionInSet(genreReflexion,
                                              [ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif,
                                               ReflGagnant,ReflRetrogradeGagnant,ReflParfaitExhaustPhaseGagnant,
                                               ReflGagnantExhaustif]);
    
      oldCurrentNode := GetCurrentNode();
		  SetCurrentNode(G);
		  ok := GetPositionEtTraitACeNoeud(G,positionEtTrait);
		   
	    if ok & (GetTraitOfPosition(positionEtTrait) <> pionVide) then
	      begin
	      
	        scoreProperty := MakeScoringProperty(genreReflexion,scoreDeNoir);
			    
			    if GenreDeReflexionInSet(genreReflexion,[ReflGagnant,ReflRetrogradeGagnant,ReflParfaitExhaustPhaseGagnant,ReflGagnantExhaustif]) then
			      begin
			        positionParenthese := Pos('(',meilleureSuite);
			        if positionParenthese > 0 then
			          meilleureSuite := TPCopy(meilleureSuite,positionParenthese,Length(meilleureSuite)-positionParenthese+1);
			      end;
			    meilleureSuite := EnleveEspacesDeDroite(meilleureSuite);
			    if debugage then WritelnDansRapport('voici les coups pour '+meilleureSuite);
			   
			    premierCoupDeLaSuite := true;
			    repeat
			      ok := false;
			      EnleveEspacesDeGaucheSurPlace(meilleureSuite);
			      whichSquare := ScannerStringPourTrouverCoup(1,meilleureSuite,positionDansChaine);
			      if (whichSquare <> -1) then
			        begin
			          meilleureSuite := TPCopy(meilleureSuite,positionDansChaine+2,Length(meilleureSuite)-positionDansChaine-1);
			          case GetTraitOfPosition(positionEtTrait) of
					        pionNoir  : moveProperty := MakeOthelloSquareProperty(BlackMoveProp,whichSquare);
					        pionBlanc : moveProperty := MakeOthelloSquareProperty(WhiteMoveProp,whichSquare);
					        otherwise   moveProperty := MakeEmptyProperty();
					      end;
					      ok := PlayMoveProperty(moveProperty,positionEtTrait);
					      if ok 
					        then
						        begin
						          if debugage then WritelnPropertyDansRapport(moveProperty);
								      err := ChangeCurrentNodeAfterThisMove(whichSquare,GetCouleurOfMoveProperty(moveProperty),'AjouteMeilleureSuiteDansGameTree',isNew);
						          
						          if estUnScoreDeFinale & GetEndgameValuesInHashTableFromThisNode(positionEtTrait,GetCurrentNode(),kDeltaFinaleInfini,vMinPourNoir,vMaxPourNoir) then
							          begin
							            confirmation := ScoreFinalEstConfirmeParValeursHashExacte(genreReflexion,scoreDeNoir,vMinPourNoir,vMaxPourNoir);
							            ok := ok & confirmation;
							            
							            if debugage then 
							              begin
									            WritelnStringAndNumDansRapport('vMinPourNoir = ',vMinPourNoir);
									            WritelnStringAndNumDansRapport('scoreDeNoir = ',scoreDeNoir);
									            WritelnStringAndNumDansRapport('vMaxPourNoir = ',vMaxPourNoir);
									            WritelnStringAndBoolDansRapport('  =>  confirmation = ',confirmation);
									            WritelnDansRapport('');
									          end;
							          end;
						          
						          
						          if ok then
						            begin
								          AddScorePropertyToCurrentNodeSansDuplication(scoreProperty);
								          
								          (* statut reel/virtuel des noueuds *)
								          if (virtualite = kForceReel)               then MarquerCurrentNodeCommeReel('AjouteMeilleureSuiteDansGameTree {1}') else
								          if (virtualite = kForceVirtual)            then MarquerCurrentNodeCommeVirtuel else
								          if isNew & (virtualite = kNewMovesReel)    then MarquerCurrentNodeCommeReel('AjouteMeilleureSuiteDansGameTree {2}') else
								          if isNew & (virtualite = kNewMovesVirtual) then MarquerCurrentNodeCommeVirtuel;
								          
								          
								          if premierCoupDeLaSuite 
								            then
									            begin
									              if exclamation then
									                begin
											              PointExclamationProp := MakeTripleProperty(TesujiProp,MakeTriple(1));
											              AddPropertyToCurrentNodeSansDuplication(PointExclamationProp);
											              DisposePropertyStuff(PointExclamationProp);
											            end;
											          premierCoupDeLaSuite := false;
									            end
									          else
									            begin
									              if GenreDeReflexionInSet(genreReflexion,[ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif]) then
									                if (virtualite = kForceReel) | (virtualite = kNewMovesReel) then 
									                  PromeutParmiSesFreres(GetCurrentNode());
									            end;
									      end;
							      end
							    else
							      begin
							        SysBeep(0);
							        WritelnDansRapport('ERROR : coup illegal dans AjouteMeilleureSuiteDansGameTree');
							        WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
							        WriteStringAndPropertyDansRapport('moveProperty = ',moveProperty);
							      end;
			          DisposePropertyStuff(moveProperty);
			        end;
			    until (whichSquare = -1) | not(ok) | (meilleureSuite='') | (GetTraitOfPosition(positionEtTrait) = pionVide);
			    
			    DisposePropertyStuff(scoreProperty);
	      end;
	    SetCurrentNode(oldCurrentNode);
	  end;
end;


procedure AjouteMeilleureSuiteDansArbreDeJeuCourant(genreReflexion : SInt32;meilleureSuite : str255;scoreDeLaLignePourNoir : SInt32);
var oldCurrentNode : GameTree;
begin
  oldCurrentNode := GetCurrentNode();
  AjouteMeilleureSuiteDansGameTree(genreReflexion,meilleureSuite,scoreDeLaLignePourNoir,GetCurrentNode(),true,kForceReel);
  SetCurrentNode(oldCurrentNode);
  MarquerCurrentNodeCommeReel('AjouteMeilleureSuiteDansArbreDeJeuCourant');
end;


procedure AjoutePropertyValeurExacteCoupDansCurrentNode(quelGenreDeReflexion,scorePourNoir : SInt32);
begin
  AjoutePropertyValeurExacteCoupDansGameTree(quelGenreDeReflexion,scorePourNoir,GetCurrentNode());
end;


function SelectScorePropertyOfCurrentNode() : PropertyPtr;
begin
  SelectScorePropertyOfCurrentNode := SelectScorePropertyOfNode(GetCurrentNode());
end;


procedure MarquerCurrentNodeCommeVirtuel;
begin
  MarquerCeNoeudCommeVirtuel(GameTreeCourant);
end;


procedure MarquerCurrentNodeCommeReel(const fonctionAppelante : str255);
(* var partieAlpha : str255;
    positionTerminale : PositionEtTraitRec; *)
begin {$UNUSED fonctionAppelante}

  (*
  if IsAVirtualNode(GameTreeCourant) &
     CreatePartieEnAlphaJusqua(GameTreeCourant,partieAlpha,positionTerminale) then
    begin
      WritelnDansRapport('MarquerCurrentNodeCommeReel '+partieAlpha+' : fonctionAppelante = '+fonctionAppelante);
    end;
  *)
  MarquerCeNoeudCommeReel(GameTreeCourant);
end;



procedure JumpToPosition(var G : GameTree; var compteur : SInt32; var continuer : boolean);
var bidbool : boolean;
    ligne : str255;
    positionCourante : PositionEtTraitRec;
begin
  inc(compteur);
  
  bidbool := CreatePartieEnAlphaJusqua(G,ligne,positionCourante);
  PlaquerPositionEtPartie(GetPositionEtTraitInitiauxOfGameTree(),ligne,kNePasRejouerLesCoupsEnDirect);
  
  
  continuer := true;
end;


function FindStringInNode(var G : GameTree; var compteur : SInt32) : boolean;
var continuer : boolean;
begin
  JumpToPosition(G,compteur,continuer);
  FindStringInNode := not(continuer);
end;


procedure FindStringDansArbreDeJeuCourant(s : str255);
var G,noeudDepart : GameTree;
    bidbool : boolean;
    compteur : SInt32;
    ligne : str255;
    position : PositionEtTraitRec;
begin  {$UNUSED s,bidbool,ligne,position}
  G := GetCurrentNode();
  
  
  noeudDepart := G;
  compteur := 0;
  
  G := FindNodeInGameTree(G,FindStringInNode,compteur);
  WritelnStringAndNumDansRapport('sortie de FindStringDansArbreDeJeuCourant : compteur = ',compteur);
  WritelnDansRapport('');
  
  (*
  repeat
    bidbool := CreatePartieEnAlphaJusqua(G,ligne,position);
    WritelnDansRapport('ligne = '+ligne);
    G := NextNodePourParcoursEnProfondeurArbre(G);
  until (G = noeudDepart);
  *)

end;





procedure ChercherLeProchainNoueudAvecBeaucoupDeFils(nbreDeFils : SInt32);
var G,noeudDepart : GameTree;
    bidlong : SInt32;
    bidbool : boolean;
begin
  G := GetCurrentNode();
  
  
  noeudDepart := NextNodePourParcoursEnProfondeurArbre(G);
  
  G := FindNodeInGameTree(noeudDepart,GameNodeHasTooManySons,nbreDeFils);
  
  if (G <> GetCurrentNode()) then JumpToPosition(G,bidlong,bidbool);
end;









































END.