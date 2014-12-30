UNIT UnitEndgameTree;



INTERFACE







USES UnitPositionEtTrait;



(* initialisation de l'unite *)
procedure InitUnitEndgameTree;


(* fonction pour parcourir localement l'arbre en finale *)
procedure SearchPositionFromThisNode(whichPosition : PositionEtTraitRec;whichNode : GameTree; var result : GameTree);
function AllocateNewEndgameTree(startingNode : GameTree; var numeroArbre : SInt32) : boolean;
procedure LibereEndgameTree(numeroArbre : SInt32);
procedure DoMoveEndgameTree(numeroArbre,coup,trait : SInt32);
procedure UndoMoveEndgameTree(numeroArbre : SInt32);
function GetActiveNodeOfEndgameTree(numeroArbre : SInt32) : GameTree;
function GetMagicCookieInitialEndgameTree(numeroArbre : SInt32) : SInt32;
function NbMaxEndgameTrees() : SInt32;
procedure EcritStatistiquesEndgameTrees;

(* fonction de minimax utilisant les GameTree *)
function TrouveMeilleurFilsNoir(G : GameTree; var bestScoreNoir : SInt32) : GameTree;
function TrouveMeilleurFilsBlanc(G : GameTree; var bestScoreBlanc : SInt32) : GameTree;
function SelectionneMeilleurCoupNoirDansListe(L : GameTreeList; var bestBlackScore : SInt32) : GameTree;
function SelectionneMeilleurCoupBlancDansListe(L : GameTreeList; var bestWhiteScore : SInt32) : GameTree;


(* recherche des valeurs minimales et maximales stockees dans les EndgameTree *)
function GetValeurMinimumParEndgameTree(numeroArbre,deltaFinale : SInt32) : SInt32;
function GetValeurMaximumParEndgameTree(numeroArbre,deltaFinale : SInt32) : SInt32;
function ConnaitValeurDuNoeudParEndgameTree(numeroArbre,deltaFinale : SInt32; var vmin,vmax : SInt32) : boolean;

(* finale par l'arbre *)
function PeutCalculerFinaleParEndgameTree(numeroArbre : SInt32; position : PositionEtTraitRec;
	                                        var listeDesCoups : PropertyList; var meilleurScore : SInt32) : boolean;
function SuiteParfaiteEstConnueDansGameTree() : boolean;
procedure SetSuiteParfaiteEstConnueDansGameTree(flag : boolean);

(* fonction calculant la clef de hashage initiale pour la finale *)
function CalculateHashIndexFromThisNode(var positionCherchee : PositionEtTraitRec;whichNode : GameTree; var dernierCoup : SInt32) : SInt32;

(* Transfert des infos de l'arbre Smart Game Board dans les hash table *)
procedure MetSousArbreDansHashTableExacte(G : GameTree;nbVidesMinimum : SInt32);


IMPLEMENTATION







USES UnitArbreDeJeuCourant,UnitVariablesGlobalesFinale,UnitHashTableExacte,UnitServicesDialogs,
     UnitFinaleFast,UnitRapport,UnitMacExtras,UnitGameTree,SNStrings;


const kNbMaxEndgameTrees = 5;  {suffisant pour 5 appels imbriques a CoupGagnant}
      kMaxDepthOfEachEndagmeTree = 3;
var gSuiteParfaiteEstConnueDansGameTree : boolean;
    endgameTrees:
      record 
        nbEndgameTreeUtilises : SInt32;
        theTree:
          array[1..kNbMaxEndgameTrees] of
		        record
		          initialCookie : SInt32;
		          activeNode : GameTree;
		          activeNodeCookie : SInt32;
		          pathNodes : array[0..kMaxDepthOfEachEndagmeTree] of GameTree;
		          pathNodesCookies : array[0..kMaxDepthOfEachEndagmeTree] of SInt32;
		          activeDepth : SInt32;
		          estLibre : boolean;
		        end;
	    end;


procedure SetActiveNodeEndgameTree(numeroEndgameTree : SInt32;G : GameTree);
begin
  if (numeroEndgameTree >= 1) & (numeroEndgameTree <= kNbMaxEndgameTrees) then
	  with endgameTrees.theTree[numeroEndgameTree] do
		  if G = NIL
		    then
		      begin
		        activeNode := NIL;
		        activeNodeCookie := 0;
		        {WritelnDansRapport('WARNING : G = NIL dans SetActiveNodeEndgameTree');}
		      end
		    else
		      begin
		        activeNode := G;
		        activeNodeCookie := GetGameNodeMagicCookie(G);
		      end;
end;

procedure SetPathNodeEndgameTree(numeroEndgameTree : SInt32;depth : SInt32;G : GameTree);
begin
  if (numeroEndgameTree >= 1) & (numeroEndgameTree <= kNbMaxEndgameTrees) then
	  with endgameTrees.theTree[numeroEndgameTree] do
		  if (depth >= 0) & (depth <= kMaxDepthOfEachEndagmeTree) 
		    then
		      begin
		        if G = NIL
		          then
		            begin
		              pathNodes[depth]        := NIL;
		              pathNodesCookies[depth] := 0;
		              {WritelnStringAndNumDansRapport('WARNING : G = NIL dans SetPathNodeEndgameTree, depth = ',depth);}
		            end
		          else
		            begin
		              pathNodes[depth]        := G;
		              pathNodesCookies[depth] := GetGameNodeMagicCookie(G);
		            end;
		      end
		    else
		      begin
		        WritelnDansRapport('ERREUR : depth = '+NumEnString(depth)+' dans SetPathNodeEndgameTree');
		      end;
end;


procedure InitUnitEndgameTree;
var i,d : SInt32;
begin

  usingEndgameTrees := true; 
  
  with endgameTrees do
    begin
      nbEndgameTreeUtilises := 0;
      for i := 1 to kNbMaxEndgameTrees do
        with theTree[i] do
	      begin
	        estLibre      := true;
	        activeDepth   := 0;
	        initialCookie := 0;
	        SetActiveNodeEndgameTree(i,NIL);
	        for d := 0 to kMaxDepthOfEachEndagmeTree  do
	          SetPathNodeEndgameTree(i,d,NIL);
	      end;
    end;
  
  SetSuiteParfaiteEstConnueDansGameTree(false);

end;



function ActiveNodeEstValideEndgameTree(numeroEndgameTree : SInt32) : boolean;
begin
  if (numeroEndgameTree < 1) & (numeroEndgameTree > kNbMaxEndgameTrees) 
    then 
      ActiveNodeEstValideEndgameTree := false
    else
      begin
        with endgameTrees.theTree[numeroEndgameTree] do
				  begin
				    ActiveNodeEstValideEndgameTree := (activeNode <> NIL) & 
				                                      (activeNodeCookie = GetGameNodeMagicCookie(activeNode));
				   {WritelnStringAndNumDansRapport('dans ActiveNodeEstValideEndgameTree(',numeroEndgameTree);
				    WritelnStringAndNumDansRapport('         activeNode = ',SInt32(activeNode));
				    WritelnStringAndNumDansRapport('         activeNodeCookie = ',activeNodeCookie);
				    WritelnStringAndNumDansRapport('         GetGameNodeMagicCookie(activeNode) = ',GetGameNodeMagicCookie(activeNode));
				   }
				  end;
		  end;
end;

function PathNodeEstValideEndgameTree(numeroEndgameTree : SInt32;depth : SInt32) : boolean;
begin
  if (numeroEndgameTree < 1) & (numeroEndgameTree > kNbMaxEndgameTrees) 
    then 
      PathNodeEstValideEndgameTree := false
    else
      begin
			  with endgameTrees.theTree[numeroEndgameTree] do
				  if (depth >= 0) & (depth <= kMaxDepthOfEachEndagmeTree) 
				    then
				      begin
				        PathNodeEstValideEndgameTree := (pathNodes[depth] <> NIL) & 
				                                        (pathNodesCookies[depth] = GetGameNodeMagicCookie(pathNodes[depth]))
				      end
				    else
				      begin
				        WritelnDansRapport('ERREUR : depth = '+NumEnString(depth)+' dans PathNodeEstValideEndgameTree');
				        PathNodeEstValideEndgameTree := false;
				      end;
			end;
end;






procedure MaximiseScoreNoir(var G, bestBlackNode : GameTree; var bestBlackScore : SInt32; var continuer : boolean);
var scoreMinCourant,scoreMaxCourant,couleur : SInt32;
    bonneCouleur : boolean;
begin
  couleur := pionNoir;
  case couleur of
    pionNoir  : bonneCouleur := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp],G) <> NIL;
    pionBlanc : bonneCouleur := SelectFirstPropertyOfTypesInGameTree([WhiteMoveProp],G) <> NIL;
    otherwise   bonneCouleur := false;
  end;
  
  if not(bonneCouleur) 
    then
      begin
	      SysBeep(0);
	      WritelnDansRapport('ERREUR : mauvaise couleur dans MaximiseScoreNoir, prevenez Stephane');
	      AlerteSimple('ERREUR : mauvaise couleur dans MaximiseScoreNoir, prevenez Stephane');
	    end
    else
	    begin
	      if GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,scoreMinCourant,scoreMaxCourant) then
		      if scoreMinCourant > bestBlackScore then
		        begin
		          bestBlackNode := G;
		          bestBlackScore := scoreMinCourant;
		        end;
	    end;
    
  continuer := bonneCouleur;
end;

procedure MaximiseScoreBlanc(var G, bestWhiteNode : GameTree; var bestWhiteScore : SInt32; var continuer : boolean);
var scoreMinCourant,scoreMaxCourant,couleur : SInt32;
    bonneCouleur : boolean;
begin
  couleur := pionBlanc;
  case couleur of
    pionNoir  : bonneCouleur := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp],G) <> NIL;
    pionBlanc : bonneCouleur := SelectFirstPropertyOfTypesInGameTree([WhiteMoveProp],G) <> NIL;
    otherwise   bonneCouleur := false;
  end;
  
  if not(bonneCouleur) 
    then
      begin
	      SysBeep(0);
	      WritelnDansRapport('ERREUR : mauvaise couleur dans MaximiseScoreBlanc, prevenez Stephane');
	      AlerteSimple('ERREUR : mauvaise couleur dans MaximiseScoreBlanc, prevenez Stephane');
	    end
    else
	    begin
	      if GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,scoreMinCourant,scoreMaxCourant) then
		      if scoreMinCourant > bestWhiteScore then
		        begin
		          bestWhiteNode := G;
		          bestWhiteScore := scoreMinCourant;
		        end;
	    end;
    
  continuer := bonneCouleur;
end;




function SelectionneMeilleurCoupNoirDansListe(L : GameTreeList; var bestBlackScore : SInt32) : GameTree;
var bestBlackNode : GameTree;
begin
  bestBlackScore := -1000;
  bestBlackNode := NIL;
  
  ForEachGameTreeInListDoAvecGameTreeEtResult(L,MaximiseScoreNoir,bestBlackNode,bestBlackScore);
  SelectionneMeilleurCoupNoirDansListe := bestBlackNode;
end;



function SelectionneMeilleurCoupBlancDansListe(L : GameTreeList; var bestWhiteScore : SInt32) : GameTree;
var bestWhiteNode : GameTree;
begin
  bestWhiteScore := -1000;
  bestWhiteNode := NIL;
  
  ForEachGameTreeInListDoAvecGameTreeEtResult(L,MaximiseScoreBlanc,bestWhiteNode,bestWhiteScore);
  SelectionneMeilleurCoupBlancDansListe := bestWhiteNode;
end;


function TrouveMeilleurFilsNoir(G : GameTree; var bestScoreNoir : SInt32) : GameTree;
begin
  TrouveMeilleurFilsNoir := SelectionneMeilleurCoupNoirDansListe(GetSons(G),bestScoreNoir);
end;

function TrouveMeilleurFilsBlanc(G : GameTree; var bestScoreBlanc : SInt32) : GameTree;
begin
  TrouveMeilleurFilsBlanc := SelectionneMeilleurCoupBlancDansListe(GetSons(G),bestScoreBlanc);
end;



procedure SearchPositionFromThisNode(whichPosition : PositionEtTraitRec;whichNode : GameTree; var result : GameTree);
var t,coup : SInt32;
    positionArbre,positionFils : PositionEtTraitRec;
    oldCurrentNode : GameTree;
    err : OSErr;
    isNew : boolean;
begin
  result := NIL;
  
  if GetPositionEtTraitACeNoeud(whichNode,positionArbre) then
    begin
    
		  (* whichNode est-il directement la position whichPosition ? *)
		  if SamePositionEtTrait(whichPosition,positionArbre)
		    then 
		      begin
		        (* WritelnDansRapport('CompareNodeAndPosition : mêmes positions'); *)
		        result := whichNode;
		      end
		    else
		      begin
		        (* sinon on cherche whichPosition parmi les fils de whichNode,
		          en creeant eventuellement ce fils *)
		        positionFils := positionArbre;
		        for t := 1 to 64 do
		          begin
		            coup := othellier[t];
		            if UpdatePositionEtTrait(positionFils,coup) then
		              begin
		                if SamePositionEtTrait(whichPosition,positionFils) then
		                  begin
		                  
		                    oldCurrentNode := GetCurrentNode();
		                    SetCurrentNode(whichNode);
		                    
		                    err := ChangeCurrentNodeAfterThisMove(coup,GetTraitOfPosition(positionArbre),'SearchPositionFromThisNode',isNew);
		                    if (err=0) then
		                      begin
		                        result := GetCurrentNode();
		                        if isNew then MarquerCeNoeudCommeVirtuel(result);
		                      end;
		                      
		                    SetCurrentNode(oldCurrentNode);
		                    
		                    (* WritelnDansRapport('CompareNodeAndPosition : position trouvée parmi les fils'); *)
		                    exit(SearchPositionFromThisNode);
		                  end;
		                positionFils := positionArbre;
		              end;
		          end;
		        (* meme pas trouve parmi les fils, on abandonne *)
		        WritelnDansRapport('SearchPositionFromThisNode : position non trouvee !!');
		        SysBeep(0);
		      end;
		end
  else
		begin
		  WritelnDansRapport('SearchPositionFromThisNode : not(GetPositionEtTraitACeNoeud) !!');
		  SysBeep(0);
		end;
end;

function AllocateNewEndgameTree(startingNode : GameTree; var numeroArbre : SInt32) : boolean;
var i,d : SInt32;
begin
  with endgameTrees do
    begin
      numeroArbre := -1;  {par defaut : allocation non reussie}
      AllocateNewEndgameTree := false;
  
      if (startingNode <> NIL) & (nbEndgameTreeUtilises < kNbMaxEndgameTrees) then
		      for i := 1 to kNbMaxEndgameTrees do
		        with theTree[i] do
		          if estLibre then
		            begin
		              inc(nbEndgameTreeUtilises);
		            
		              SetActiveNodeEndgameTree(i,startingNode);
		              SetPathNodeEndgameTree(i,0,startingNode);
		              for d := 1 to kMaxDepthOfEachEndagmeTree do
		                SetPathNodeEndgameTree(i,d,NIL);
		              
		              estLibre      := false;
		              activeDepth   := 0;
		              initialCookie := NewMagicCookie();
		                
		              (* WritelnDansRapport('trouvé ! => AllocateNewEndgameTree('+NumEnString(i)+')'); *)
		              
		              AllocateNewEndgameTree := true;
		              numeroArbre := i;
		              exit(AllocateNewEndgameTree);
		            end;
		end;
end;

procedure LibereEndgameTree(numeroArbre : SInt32);
var d : SInt32;
begin
  (* WritelnDansRapport('LibereEndgameTree('+NumEnString(numeroArbre)+')'); *)
  with endgameTrees do
    begin
      if (numeroArbre>=1) & (numeroArbre<=kNbMaxEndgameTrees) then
        begin
          if not(ActiveNodeEstValideEndgameTree(numeroArbre)) & 
             (interruptionReflexion = pasdinterruption) then
            begin
              SysBeep(0);
              WritelnDansRapport('WARNING : activeNode non valide dans LibereEndgameTree');
              exit(LibereEndgameTree);
            end;
        
	        dec(nbEndgameTreeUtilises);
	        with theTree[numeroArbre] do
	          begin
	            estLibre      := true;
	            activeDepth   := 0;
	            initialCookie := 0;
	            
	            SetActiveNodeEndgameTree(numeroArbre,NIL);
	            for d := 0 to kMaxDepthOfEachEndagmeTree  do
		            SetPathNodeEndgameTree(numeroArbre,d,NIL);
	          end;
	      end;
	  end;
end;




procedure DoMoveEndgameTree(numeroArbre,coup,trait : SInt32);
var oldCurrentNode : GameTree;
    err : OSErr;
    isNew : boolean;
begin
  if (numeroArbre >= 1) & (numeroArbre <= kNbMaxEndgameTrees) then
    with endgameTrees.theTree[numeroArbre] do
      if (activeDepth < kMaxDepthOfEachEndagmeTree) & 
         ActiveNodeEstValideEndgameTree(numeroArbre)
        then
	        begin
	          oldCurrentNode := GetCurrentNode();
	        
	          SetCurrentNode(activeNode);
	          err := ChangeCurrentNodeAfterThisMove(coup,trait,'DoMoveEndgameTree',isNew);
	          if err=NoErr 
	            then
	              begin
	                SetActiveNodeEndgameTree(numeroArbre,GetCurrentNode());
	                inc(activeDepth);
	                SetPathNodeEndgameTree(numeroArbre,activeDepth,activeNode);
	                if isNew then MarquerCurrentNodeCommeVirtuel;
	              end
	            else
	              begin
	                SetActiveNodeEndgameTree(numeroArbre,NIL);
	                SysBeep(0);
	                WritelnStringAndNumDansRapport('erreur 1 dans DoMoveEndgameTree : err = ',err);
	              end;
	        
	          SetCurrentNode(oldCurrentNode);
	        end
        else
          begin
            WritelnStringAndNumDansRapport('erreur 2 dans DoMoveEndgameTree : activeDepth = ',activeDepth);
            WritelnStringAndNumDansRapport('                            activeNode = ',SInt32(activeNode));
          end;
end;

procedure UndoMoveEndgameTree(numeroArbre : SInt32);
begin
  if (numeroArbre >= 1) & (numeroArbre <= kNbMaxEndgameTrees) then
    with endgameTrees.theTree[numeroArbre] do
      if (activeDepth>0) & 
         ActiveNodeEstValideEndgameTree(numeroArbre)
        then
	        begin
	          dec(activeDepth);
	          SetActiveNodeEndgameTree(numeroArbre,activeNode^.father);
	          if not(ActiveNodeEstValideEndgameTree(numeroArbre)) then
	            begin
	              WritelnDansRapport('ERREUR : activeNode invalide apres activeNode^.father dans UndoMoveEndgameTree');
	            end;
	        end
	      else
	        begin
	          WritelnStringAndNumDansRapport('erreur dans UndoMoveEndgameTree : activeDepth = ',activeDepth);
            WritelnStringAndNumDansRapport('                            activeNode = ',SInt32(activeNode));
	        end;
end;

function GetActiveNodeOfEndgameTree(numeroArbre : SInt32) : GameTree;
begin
  if (numeroArbre >= 1) & (numeroArbre <= kNbMaxEndgameTrees) &
     ActiveNodeEstValideEndgameTree(numeroArbre) 
    then GetActiveNodeOfEndgameTree := endgameTrees.theTree[numeroArbre].activeNode
    else GetActiveNodeOfEndgameTree := NIL;
end;

function GetMagicCookieInitialEndgameTree(numeroArbre : SInt32) : SInt32;
begin
  if (numeroArbre >= 1) & (numeroArbre <= kNbMaxEndgameTrees) 
    then GetMagicCookieInitialEndgameTree := endgameTrees.theTree[numeroArbre].initialCookie
    else GetMagicCookieInitialEndgameTree := 0;
end;

function NbMaxEndgameTrees() : SInt32;
begin
  NbMaxEndgameTrees := kNbMaxEndgameTrees;
end;

procedure EcritStatistiquesEndgameTrees;
begin
  WritelnStringAndNumDansRapport('nbEndgameTreeUtilises = ', endgameTrees.nbEndgameTreeUtilises);
end;

function GetValeurMinimumOfNode(G : GameTree;deltaFinale : SInt32) : SInt32;
var couleur,valeurMin,valeurMax : SInt32;
begin {$UNUSED deltaFinale}
  
  if (G <> NIL) then
    begin
		  couleur := GetCouleurOfMoveInNode(G);
		    
		  (* d'abord on cherche une info exacte (WLD ou score exact) dans le noeud *)
		  if ((couleur = pionNoir) | (couleur = pionBlanc)) &
		      GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,valeurMin,valeurMax) then
		    begin
		      GetValeurMinimumOfNode := valeurMin;
		      exit(GetValeurMinimumOfNode);
		    end;
		end;
  
  GetValeurMinimumOfNode := -64; {par defaut}
end;

function GetValeurMaximumOfNode(G : GameTree;deltaFinale : SInt32) : SInt32;
var couleur,valeurMin,valeurMax : SInt32;
begin {$UNUSED deltaFinale}
  
  if (G <> NIL) then
    begin
		  couleur := GetCouleurOfMoveInNode(G);
		    
		  (* d'abord on cherche une info exacte (WLD ou score exact) dans le noeud *)
		  if ((couleur = pionNoir) | (couleur = pionBlanc)) &
		      GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,valeurMin,valeurMax) then
		    begin
		      GetValeurMaximumOfNode := valeurMax;
		      exit(GetValeurMaximumOfNode);
		    end;
		end;
  
  GetValeurMaximumOfNode := +64;  {par defaut}
end;

function ConnaitValeurDuNoeud(G : GameTree;deltaFinale : SInt32; var vmin,vmax : SInt32) : boolean;
begin
  vmin := GetValeurMinimumOfNode(G,deltaFinale);
  vmax := GetValeurMaximumOfNode(G,deltaFinale);
  
  if vmin < vmax
    then ConnaitValeurDuNoeud := false
    else
      begin
        ConnaitValeurDuNoeud := true;
        if vmin > vmax then
          begin
		        SysBeep(0);
		        WritelnDansRapport('ERROR : vmin > vmax dans ConnaitValeurDuNoeud');
		        WritelnStringAndNumDansRapport('vmin = ',vmin);
		        WritelnStringAndNumDansRapport('vmax = ',vmax);
		      end;
      end;
end;


function GetValeurMinimumParEndgameTree(numeroArbre,deltaFinale : SInt32) : SInt32;
begin
  if (numeroArbre >= 1) & (numeroArbre <= kNbMaxEndgameTrees) & ActiveNodeEstValideEndgameTree(numeroArbre)
    then GetValeurMinimumParEndgameTree := GetValeurMinimumOfNode(GetActiveNodeOfEndgameTree(numeroArbre),deltaFinale)
    else GetValeurMinimumParEndgameTree := -64;
end;


function GetValeurMaximumParEndgameTree(numeroArbre,deltaFinale : SInt32) : SInt32;
begin
  if (numeroArbre >= 1) & (numeroArbre <= kNbMaxEndgameTrees) & ActiveNodeEstValideEndgameTree(numeroArbre)
    then GetValeurMaximumParEndgameTree := GetValeurMaximumOfNode(GetActiveNodeOfEndgameTree(numeroArbre),deltaFinale)
    else GetValeurMaximumParEndgameTree := +64;
end;


function ConnaitValeurDuNoeudParEndgameTree(numeroArbre,deltaFinale : SInt32; var vmin,vmax : SInt32) : boolean;
begin
  if (numeroArbre >= 1) & (numeroArbre <= kNbMaxEndgameTrees) & ActiveNodeEstValideEndgameTree(numeroArbre)
    then 
      ConnaitValeurDuNoeudParEndgameTree := ConnaitValeurDuNoeud(GetActiveNodeOfEndgameTree(numeroArbre),deltaFinale,vmin,vmax)
    else 
      begin
        ConnaitValeurDuNoeudParEndgameTree := false;
        vmin := -64;
        vmax := +64;
      end;
end;



function PeutCalculerFinaleParEndgameTree(numeroArbre : SInt32; position : PositionEtTraitRec;
	                                        var listeDesCoups : PropertyList; var meilleurScore : SInt32) : boolean;
var G : GameTree;
    vmin,vmax,temp : SInt32;
    scoreProp,moveProp : PropertyPtr;
    longueurListeDesCoups,nbCoupsAjoutes : SInt32;
    Liste2 : PropertyList;
    suiteLegale : boolean;
    position2 : PositionEtTraitRec;
begin
  PeutCalculerFinaleParEndgameTree := false;
  
(*WritelnDansRapport('avant ConnaitValeurDuNoeudParEndgameTree');
  AttendFrappeClavier;*)
  
  if (listeDesCoups = NIL) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT : listeDesCoups = NIL dans PeutCalculerFinaleParEndgameTree');
      exit(PeutCalculerFinaleParEndgameTree);
    end;
  
  if (GetTraitOfPosition(position) <> pionVide) &
     ConnaitValeurDuNoeudParEndgameTree(numeroArbre,kDeltaFinaleInfini,vmin,vmax) then
    begin
      
    (*WritelnStringAndNumDansRapport('deltaFinale = ',kDeltaFinaleInfini);
      WritelnStringAndNumDansRapport('vmin = ',vmin);
      WritelnStringAndNumDansRapport('vmax = ',vmin);
      WritelnDansRapport('avant GetActiveNodeOfEndgameTree');
      AttendFrappeClavier;*)
    
      G := GetActiveNodeOfEndgameTree(numeroArbre);
      
      if not(GetPositionEtTraitACeNoeud(G,position2)) |
         not(SamePositionEtTrait(position,position2)) then
        begin
          SysBeep(0);
          WritelnDansRapport('ASSERT : not(SamePositionEtTrait(position,PositionEtTraitACeNoeud(G))) dans PeutCalculerFinaleParEndgameTree');
          exit(PeutCalculerFinaleParEndgameTree);
        end;
      
      if GetTraitOfPosition(position) = -GetCouleurOfMoveInNode(G)
        then
          begin
            temp := vmin;
            vmin := -vmax;
            vmax := -temp;
          end;
      
      scoreProp := SelectScorePropertyOfNode(G);
      if (scoreProp = NIL) | (scoreProp^.genre <> NodeValueProp) then
        begin
          SysBeep(0);
          if (scoreProp = NIL)
            then WritelnDansRapport('ASSERT : (scoreProp = NIL) dans PeutCalculerFinaleParEndgameTree')
            else WritelnDansRapport('ASSERT : (scoreProp^.genre <> NodeValueProp) dans PeutCalculerFinaleParEndgameTree');
          exit(PeutCalculerFinaleParEndgameTree);
        end;
      
    (*WritelnDansRapport('avant NbCasesVidesDansPosition');
      AttendFrappeClavier;*)
      
      
      (* creation de la liste des coups *)
      
    (*WritelnDansRapport('avant NewPropertyList');
      AttendFrappeClavier;*)
      
    (*WritelnStringAndPropertyListDansRapport('apres NewPropertyList, listeDesCoups = ',listeDesCoups);*)
      nbCoupsAjoutes := 0;
      repeat
        G := SelectFirstSubtreeWithThisProperty(scoreProp^,G);
        
        (*
        if (G = NIL) then 
          begin
            WritelnDansRapport('G = NIL');
            AttendFrappeClavier;
          end; *)
        
        moveProp := SelectMovePropertyOfNode(G);
        if moveProp <> NIL then
          begin
            AddPropertyToList(moveProp^,listeDesCoups);
            inc(nbCoupsAjoutes);
          (*WritelnStringAndPropertyListDansRapport('apres AddPropertyToList, listeDesCoups = ',listeDesCoups);
            AttendFrappeClavier;*)
          end;
        
        (*
        if (moveProp = NIL) then 
          begin
            WritelnDansRapport('moveProp = NIL');
            AttendFrappeClavier;
          end; *)
        
      until (G = NIL) | (moveProp = NIL);
      
    (*WritelnDansRapport('avant PropertyListLength');
      AttendFrappeClavier;*)
      
      longueurListeDesCoups := PropertyListLength(listeDesCoups);
      
    (*WritelnStringAndNumDansRapport('longueurListeDesCoups = ',longueurListeDesCoups);
      AttendFrappeClavier;*)
      
      if (longueurListeDesCoups > 0) & (nbCoupsAjoutes > 0) then
        begin
          (* testons la legalite de la suite des coups *)
          suiteLegale := true;
				  Liste2 := ListeDesCoups;
				  
				(*WritelnStringAndPropertyListDansRapport('avant la boucle, Liste2 = ',Liste2);
          AttendFrappeClavier;*)
          
				  repeat
				  (*WritelnDansRapport('avant PlayMoveProperty :');
				    WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
				    AttendFrappeClavier;*)
				    
				    suiteLegale := suiteLegale & PlayMoveProperty(Liste2^.head,position);
				    Liste2 := Liste2^.tail;
				    
				  (*WritelnStringAndPropertyListDansRapport('dans la boucle, Liste2 = ',Liste2);
            AttendFrappeClavier;*)
				    
				  until (Liste2 = NIL);
				  
				(*WritelnDansRapport('apres la boucle :');
				  WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
				  AttendFrappeClavier;*)
				  
				  if not(suiteLegale) then
				    begin
				      SysBeep(0);
				      WritelnDansRapport('WARNING : not(suiteLegale) dans PeutCalculerFinaleParEndgameTree');
				    end;
          
          if suiteLegale & (GetTraitOfPosition(position) = pionVide) then
            begin
            
            (*WritelnDansRapport('je mets PeutCalculerFinaleParEndgameTree à true');
              AttendFrappeClavier;*)
              
              PeutCalculerFinaleParEndgameTree := true;
              
              (*WritelnStringAndNumDansRapport('dans PeutCalculerFinaleParEndgameTree, vmin = ',vmin);*)
              meilleurScore := vmin;
              
		        end;
        end;
      
    (*WritelnDansRapport('avant DisposePropertyList');
      AttendFrappeClavier;*)
      
    end;
end;


function SuiteParfaiteEstConnueDansGameTree() : boolean;
begin
  SuiteParfaiteEstConnueDansGameTree := gSuiteParfaiteEstConnueDansGameTree;
end;


procedure SetSuiteParfaiteEstConnueDansGameTree(flag : boolean);
begin
  gSuiteParfaiteEstConnueDansGameTree := flag;
end;



function CalculateHashIndexFromThisNode(var positionCherchee : PositionEtTraitRec;whichNode : GameTree; var dernierCoup : SInt32) : SInt32;
var gameTreeDeLaPosition : GameTree;
    hashValue : SInt32;
    prop : PropertyPtr;
    listeDesCoups,L : PropertyList;
    coup,pere,couleur,nbreFils : SInt16; 
begin
  hashValue := 0;
  dernierCoup := 0;

  if (whichNode <> NIL) then
    begin
      nbreFils := NumberOfSons(whichNode);
      SearchPositionFromThisNode(positionCherchee,whichNode,gameTreeDeLaPosition);
      coup := 0;
      pere := 0;
      
      if (gameTreeDeLaPosition <> NIL) then
        begin
          listeDesCoups := CreateListeDesCoupsJusqua(gameTreeDeLaPosition);
          
          if (listeDesCoups <> NIL) then
            begin
              L := listeDesCoups;
              while (L <> NIL) do
                begin
                  prop := HeadOfPropertyList(L);
                  if (prop <> NIL) then
                    begin
                      pere := coup;
                      coup := GetOthelloSquareOfProperty(prop^);
                      couleur := GetCouleurOfMoveProperty(prop^);
                      
                      if (pere >= 11) & (pere <= 88) then
                        hashValue := BXOR(hashValue , IndiceHash^^[couleur,pere]);
                      
                    end;
                  L := TailOfPropertyList(L);
                end;
              dernierCoup := coup;
            end;
          DisposePropertyList(listeDesCoups);
          
          if (NumberOfSons(whichNode) <> nbreFils) & 
             (GetFather(gameTreeDeLaPosition) = whichNode) & 
             not(HasSons(gameTreeDeLaPosition)) &
             IsAVirtualNode(gameTreeDeLaPosition)
            then DeleteThisSon(whichNode,gameTreeDeLaPosition);
           
        end;
        
      if (GetTraitOfPosition(positionCherchee) <> pionVide) & (dernierCoup >= 11) & (dernierCoup <= 88) then
        hashValue := BXOR(hashValue , IndiceHash^^[GetTraitOfPosition(positionCherchee),dernierCoup]);
        
    end;
  
  (*
  WritelnDansRapport('•••••••• résultat de CalculateHashIndexFromThisNode : ••••••••••••••');
  WritelnPositionEtTraitDansRapport(positionCherchee.position,positionCherchee.trait);
  WritelnStringAndNumDansRapport('hashValue = ',hashValue);
  WritelnStringAndCoupDansRapport('dernierCoup = ',dernierCoup);
  WritelnDansRapport('');
  *)
  
  
  if dernierCoup = 0 then dernierCoup := 44;
  CalculateHashIndexFromThisNode := hashValue;
  
end;



procedure MetValeursDansHashExacte(clefHash,nbVides : SInt32;jeu : PositionEtTraitRec;valMin,valMax,meilleurCoup,recursion : SInt32; const fonctionAppelante : str255);
var jeuEssai : PositionEtTraitRec;
    clefHashEssai,t,coup : SInt32;
begin {$UNUSED fonctionAppelante}
  if (GetTraitOfPosition(jeu) <> pionVide) &
     ((valMin > -64) | (valMax < 64) | (meilleurCoup <> 0)) then  {info interessante ?}
    begin
    
      (*
		  WritelnDansRapport('');
		  WritelnStringAndNumDansRapport('dans MetValeursDansHashExacte, recursion = ',recursion);
		  WritelnPositionEtTraitDansRapport(jeu.position,GetTraitOfPosition(jeu));
		  WritelnStringAndNumDansRapport('clefHash = ',clefHash);
		  WritelnStringAndNumDansRapport('valMin = ',valMin);
		  WritelnStringAndNumDansRapport('valMax = ',valMax);
		  WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
		  *)
		  
		  
		  {$IFC USE_DEBUG_STEP_BY_STEP}
      if MemberOfPositionEtTraitSet(jeu,dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
        then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('Avant appel de PutEndgameValuesInHashExacte dans MetValeursDansHashExacte :');
            WritelnPositionEtTraitDansRapport(jeu.position,GetTraitOfPosition(jeu));
            WritelnStringAndNumDansRapport('valMin = ',valMin);
            WritelnStringAndNumDansRapport('valMax = ',valMax);
            WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
            WritelnStringAndNumDansRapport('recursion = ',recursion);
            WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
            WritelnDansRapport('');
          end;
      {$ENDC}
      
		  PutEndgameValuesInHashExacte(clefHash,nbVides,jeu,valMin,valMax,meilleurCoup);
		  
		  if (recursion > 0) then
		    begin
		      jeuEssai := jeu;
		      for t := 1 to 64 do
		        begin
		          coup := othellier[t];
			        if UpdatePositionEtTrait(jeuEssai,coup) then
			          begin
			            clefHashEssai := BXOR(clefHash , IndiceHash^^[GetTraitOfPosition(jeuEssai),coup]);
			            
			            if (GetTraitOfPosition(jeuEssai) = -GetTraitOfPosition(jeu)) then
			              if (coup = meilleurCoup)
			                then MetValeursDansHashExacte(clefHashEssai,nbVides-1,jeuEssai,-valMax,-valMin,0,recursion-1,'MetValeursDansHashExacte {1}')
			                else MetValeursDansHashExacte(clefHashEssai,nbVides-1,jeuEssai,-valMax,     64,0,recursion-1,'MetValeursDansHashExacte {2}');
			            
			            if (GetTraitOfPosition(jeuEssai) =  GetTraitOfPosition(jeu)) then
			              if (coup = meilleurCoup)
			                then MetValeursDansHashExacte(clefHashEssai,nbVides-1,jeuEssai,valMin,valMax,0,recursion-1,'MetValeursDansHashExacte {3}')
			                else MetValeursDansHashExacte(clefHashEssai,nbVides-1,jeuEssai,-64   ,valMax,0,recursion-1,'MetValeursDansHashExacte {4}');
			            
			            jeuEssai := jeu;
			          end;
			      end;
		    end;
	  end;
end;



procedure MetSousArbreRecursivementDansHashTable(G : GameTree;plat : PositionEtTraitRec;hashValue,nbVides,nbVidesMinimum : SInt32);
var valeurMin,valeurMax,bestScore,meilleureDefense : SInt32;
    platEssai : PositionEtTraitRec;
    filsCourant,meilleurFils : GameTree;
    theSons,L : GameTreeList;
    square,hashValueEssai : SInt32;
    moveProperty : PropertyPtr;
begin
  
  (*
  WritelnStringAndNumDansRapport('---> Entrée dans MetSousArbreRecursivementDansHashTable, nbVides = ',nbVides);
  WritelnStringAndNumDansRapport('G = ',SInt32(G));
  WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
  WritelnStringAndNumDansRapport('hashValue = ',hashValue);
  *)
  
  if (G <> NIL) & (nbVides >= nbVidesMinimum) then
    begin
		  if (GetTraitOfPosition(plat) <> pionVide) & 
		     GetEndgameScoreDeCetteCouleurDansGameNode(G,GetTraitOfPosition(plat),valeurMin,valeurMax)
		    then 
		      begin
		      
		        (* a tout hasard, on remet la valeur de finale dans l'arbre, cela 
		           permet de preciser certains scores sur des arbres bizarres fabriques 
		           à la main par Marc Tastet, par exemple... *)
		        if NodeHasAPerfectScoreInformation(G) 
		          then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflParfait,valeurMin,GetTraitOfPosition(plat),G)
		          else 
		            begin
		              if valeurMin > 0 then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflGagnant,valeurMin,GetTraitOfPosition(plat),G) else
		              if valeurMax < 0 then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflGagnant,valeurMax,GetTraitOfPosition(plat),G) 
		              
		              (*
		              else
		              if (valeurMin = 0) then
		                begin
		                  SysBeep(0);
                      WritelnDansRapport('ASSERT(valeurMin = 0) dans MetSousArbreRecursivementDansHashTable !!');
		                end else
		              if (valeurMax = 0) then
		                begin
		                  SysBeep(0);
                      WritelnDansRapport('ASSERT(valeurMax = 0) dans MetSousArbreRecursivementDansHashTable !!');
		                end else
		              if (valeurMin < 0) then
		                begin
		                  SysBeep(0);
                      WritelnDansRapport('ASSERT(valeurMin < 0) dans MetSousArbreRecursivementDansHashTable !!');
		                end else
		              if (valeurMax > 0) then
		                begin
		                  SysBeep(0);
                      WritelnDansRapport('ASSERT(valeurMax > 0) dans MetSousArbreRecursivementDansHashTable !!');
		                end;
		              *)
		            end;
		        
		        meilleureDefense := 0;
		        if HasSons(G) then
		          begin
				        case GetTraitOfPosition(plat) of
				          pionBlanc : meilleurFils := TrouveMeilleurFilsBlanc(G,bestScore);
				          pionNoir  : meilleurFils := TrouveMeilleurFilsNoir(G,bestScore);
				        end;
				        {if (bestScore > -64) then}
				          if not(GetSquareOfMoveInNode(meilleurFils,meilleureDefense))
				            then meilleureDefense := 0;
				        (*
				        WritelnStringAndNumDansRapport('meilleurFils = ',SInt32(meilleurFils));
				        WritelnStringAndNumDansRapport(CoupEnString(meilleureDefense,true)+'  ==>  ',bestScore);
				        *)
				      end;
		      
		        if (nbVides > nbVidesMinimum)
		          then MetValeursDansHashExacte(hashValue,nbVides,plat,valeurMin,valeurMax,meilleureDefense,1,'MetSousArbreRecursivementDansHashTable {1}')
		          else MetValeursDansHashExacte(hashValue,nbVides,plat,valeurMin,valeurMax,meilleureDefense,0,'MetSousArbreRecursivementDansHashTable {2}');
		      end;
		    
		  if (nbVides > nbVidesMinimum) & (GetTraitOfPosition(plat) <> pionVide) & HasSons(G) then
		    begin
		      theSons := GetSons(G);
		      
		      (* itérer sur les fils dans l'arbre *)
		      L := theSons;
		      while (L <> NIL) do
		        begin
		          filsCourant := L^.head;
		          
		          moveProperty := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],filsCourant);
		          if (moveProperty <> NIL) then
		            begin
				          square := GetOthelloSquareOfProperty(moveProperty^);
				          platEssai := plat;
				          if PlayMoveProperty(moveProperty^,platEssai) then
				            begin
				              hashValueEssai := BXOR(hashValue , IndiceHash^^[GetTraitOfPosition(platEssai),square]);
				              (* appel récursif *)
				              MetSousArbreRecursivementDansHashTable(filsCourant,platEssai,hashValueEssai,nbVides-1,nbVidesMinimum);
				            end;
				        end;
		          
		          L := L^.tail;
		        end;
		    end;
		end;
end;


procedure MetSousArbreDansHashTableExacte(G : GameTree;nbVidesMinimum : SInt32);
var hashValue,dernierCoup,nbVides : SInt32;
    position : PositionEtTraitRec;
    ticks : SInt32;
begin

  {$IFC USE_DEBUG_STEP_BY_STEP}
  with gDebuggageAlgoFinaleStepByStep do
    begin
      positionsCherchees := MakeEmptyPositionEtTraitSet();
      actif := true;
      profMin := 8;
      if actif then AjouterPositionsDevantEtreDebugueesPasAPas(positionsCherchees);
    end;
  {$ENDC}


  if (G <> NIL) & GetPositionEtTraitACeNoeud(G,position) then
    begin
      ticks := TickCount();
      {WritelnDansRapport('Entrée dans MetSousArbreDansHashTableExacte');}
      
      hashValue := CalculateHashIndexFromThisNode(position,G,dernierCoup);
      nbVides := NbCasesVidesDansPosition(position.position);
      if (nbVides >= nbVidesMinimum) then
        MetSousArbreRecursivementDansHashTable(G,position,hashValue,nbVides,nbVidesMinimum);
        
      {WritelnStringAndNumDansRapport('Temps de MetSousArbreDansHashTableExacte en ticks = ',TickCount() - ticks);}
    end;
 
  {$IFC USE_DEBUG_STEP_BY_STEP}
  with gDebuggageAlgoFinaleStepByStep do
    begin
      DisposePositionEtTraitSet(positionsCherchees);
    end;
  {$ENDC}
end;





























END.