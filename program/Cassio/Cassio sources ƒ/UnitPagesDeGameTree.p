UNIT UnitPagesDeGameTree;



INTERFACE







USES UnitProperties,MacTypes;


procedure InitUnitPagesDeGameTree;
procedure DisposeToutesLesPagesDeGameTree;


function PeutCreerNouvellePageGameTree() : boolean;
function TrouvePlaceDansPageDeGameTree(var nroPage,nroIndex : SInt32) : boolean;
procedure LocaliserGameTreeDansSaPage(G : GameTree; var NroDePage,NroIndex : SInt32);


function NewGameTreePaginee() : GameTree;
procedure DisposeGameTreePaginee(G : GameTree);



IMPLEMENTATION







USES UnitNewGeneral,UnitServicesDialogs;


const TailleGameTreeBuffer = 500;
type GameTreeArray = array[1..TailleGameTreeBuffer] of GameTreeRec;
     GameTreeBuffer = ^GameTreeArray;
     PageDeGameTree =  record
                         buffer : GameTreeBuffer;
                         libre  : {packed} array[0..TailleGameTreeBuffer] of boolean;
                         premierEmplacementVide : SInt16; 
                         dernierEmplacementVide : SInt16; 
                         nbEmplacementVides     : SInt16; 
                       end;
     PageDeGameTreePtr = ^PageDeGameTree;


const nbPagesDeGameTree = 10000;
var ReserveDeGameTree : array [1..nbPagesDeGameTree] of PageDeGameTreePtr;
    dernierePageGameTreeCree : SInt32;
    pageGameTreeRenvoyeeParDerniereLocalisation : SInt32;
    pageGameTreeRenvoyeeParDerniereCreation : SInt32;


procedure InitUnitPagesDeGameTree;
var i : SInt32;
begin
  for i := 1 to nbPagesDeGameTree do
	  begin
	    ReserveDeGameTree[i] := NIL;
	  end;
	dernierePageGameTreeCree := 0;
	pageGameTreeRenvoyeeParDerniereLocalisation := 1;
	pageGameTreeRenvoyeeParDerniereCreation := 1;
	if PeutCreerNouvellePageGameTree() then;
	if not(CassioEnEnvironnementMemoireLimite()) then
	  begin
			if PeutCreerNouvellePageGameTree() then;
			if PeutCreerNouvellePageGameTree() then;
			if PeutCreerNouvellePageGameTree() then;
	  end;
end;


procedure DisposeToutesLesPagesDeGameTree;
begin
  {
  for i := 1 to nbPagesDeGameTree do
	  if ReserveDeGameTree[i] <> NIL then
	    begin
	      DisposeMemoryPtr(Ptr(ReserveDeGameTree[i]^.buffer));
	      ReserveDeGameTree[i]^.buffer := NIL;
	      DisposeMemoryPtr(Ptr(ReserveDeGameTree[i]));
	      ReserveDeGameTree[i] := NIL;
	    end;
	dernierePageGameTreeCree := 0;
	pageGameTreeRenvoyeeParDerniereLocalisation := 1;
	pageGameTreeRenvoyeeParDerniereCreation := 1;
	}
end;



function PeutCreerNouvellePageGameTree() : boolean;
var i : SInt32;
begin
  
  if dernierePageGameTreeCree >= nbPagesDeGameTree then
    begin
      AlerteSimple('le nombre de pages de GameTree est trop petit dans PeutCreerNouvellePageGameTree!! Prévenez Stéphane');
      PeutCreerNouvellePageGameTree := false;
      exit(PeutCreerNouvellePageGameTree);
    end;
    
  
  inc(dernierePageGameTreeCree);
  ReserveDeGameTree[dernierePageGameTreeCree] := PageDeGameTreePtr(AllocateMemoryPtr(sizeof(PageDeGameTree)));
  
  if ReserveDeGameTree[dernierePageGameTreeCree] = NIL then
    begin
      AlerteSimple('plus de place en memoire pour creer une page de GameTree dans PeutCreerNouvellePageGameTree!! Prévenez Stéphane');
      PeutCreerNouvellePageGameTree := false;
      exit(PeutCreerNouvellePageGameTree);
    end;
  
  with ReserveDeGameTree[dernierePageGameTreeCree]^ do
    begin
      buffer := GameTreeBuffer(AllocateMemoryPtr(sizeof(GameTreeArray+20)));
      if buffer = NIL then
        begin
          AlerteSimple('plus de place en memoire pour creer un buffer de GameTree dans PeutCreerNouvellePageGameTree !! Prévenez Stéphane');
          PeutCreerNouvellePageGameTree := false;
          exit(PeutCreerNouvellePageGameTree);
        end;
        
        
      PeutCreerNouvellePageGameTree := true;
      
      for i := 1 to TailleGameTreeBuffer do
        libre[i] := true;  
      premierEmplacementVide := 1;
      dernierEmplacementVide := TailleGameTreeBuffer;
      nbEmplacementVides    := TailleGameTreeBuffer;
    end;
  
  {
  WritelnDansRapport('Création d''une nouvelle page de GameTree');
  WritelnStringAndNumDansRapport('soldeCreationGameTree=',soldeCreationGameTree);
  SysBeep(0);
  AttendFrappeClavier;
  }
  
end;


function TrouvePlaceDansPageDeGameTree(var nroPage,nroIndex : SInt32) : boolean;
var n,i,k : SInt32;
begin
  if dernierePageGameTreeCree <= 0 then
    begin
      TrouvePlaceDansPageDeGameTree := false;
      nroPage := -1;
      nroIndex := -1;
      exit(TrouvePlaceDansPageDeGameTree);
    end;
  
  {
  for n := 1 to dernierePageGameTreeCree do
    begin
    if ReserveDeGameTree[n] <> NIL then
      with ReserveDeGameTree[n]^ do
        begin
          WritelnDansRapport('Reserve['+NumEnString(n)+'] est OK');
          WritelnStringAndNumDansRapport('nbEmplacementVides=',nbEmplacementVides);
          WritelnStringAndNumDansRapport('premierEmplacementVide=',premierEmplacementVide);
          WritelnStringAndNumDansRapport('dernierEmplacementVide=',dernierEmplacementVide);
          WritelnStringAndNumDansRapport('soldeCreationGameTree=',soldeCreationGameTree);
         end;
     if dernierePageGameTreeCree>=2 then AttendFrappeClavier;
     end;
  }
  
  for k := 0 to (dernierePageGameTreeCree div 2) do
    begin
      {un coup en montant...}
      n := pageGameTreeRenvoyeeParDerniereCreation + k;
      if (n > dernierePageGameTreeCree) then n := n - dernierePageGameTreeCree else
      if (n < 1) then n := n + dernierePageGameTreeCree;
      if ReserveDeGameTree[n] <> NIL then
        with ReserveDeGameTree[n]^ do
          if (buffer <> NIL) & (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeGameTree := true;
                  nroPage := n;
                  nroIndex := i;
                  pageGameTreeRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeGameTree);
                end;
      
      {un coup en descendant...}
      n := pageGameTreeRenvoyeeParDerniereCreation - k - 1;
      if (n > dernierePageGameTreeCree) then n := n - dernierePageGameTreeCree else
      if (n < 1) then n := n + dernierePageGameTreeCree;
      if ReserveDeGameTree[n] <> NIL then
        with ReserveDeGameTree[n]^ do
          if (buffer <> NIL) & (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeGameTree := true;
                  nroPage := n;
                  nroIndex := i;
                  pageGameTreeRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeGameTree);
                end;
    end;
  
  {pas de place vide trouvee : on demande la creation d'une nouvelle page}
  if PeutCreerNouvellePageGameTree()
    then
	    begin
	      TrouvePlaceDansPageDeGameTree := true;
	      nroPage := dernierePageGameTreeCree;
	      nroIndex := 1;
	      pageGameTreeRenvoyeeParDerniereCreation := dernierePageGameTreeCree;
	    end
    else
      begin
	      TrouvePlaceDansPageDeGameTree := false;
	      nroPage := -1;
	      nroIndex := -1;
	    end
end;



procedure LocaliserGameTreeDansSaPage(G : GameTree; var NroDePage,NroIndex : SInt32);
var i,k : SInt32;
    baseAddress : SInt32;
begin
  if G = NIL then
    begin
      NroDePage := 0;
      NroIndex := 0;
      {WritelnDansRapport('appel de LocaliserGameTreeDansSaPage(NIL)');}
      exit(LocaliserGameTreeDansSaPage);
    end;
    
  for k := 0 to (dernierePageGameTreeCree div 2) do
    begin
      {un coup en montant...}
      i := pageGameTreeRenvoyeeParDerniereLocalisation + k;
      if (i > dernierePageGameTreeCree) then i := i - dernierePageGameTreeCree else
      if (i < 1) then i := i + dernierePageGameTreeCree;
      if ReserveDeGameTree[i] <> NIL then
	      with ReserveDeGameTree[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(G)>=baseAddress) & (SInt32(G)<=baseAddress+(TailleGameTreeBuffer-1)*sizeof(GameTreeRec))
	          then
	            begin
	              NroDePage := i;
	              NroIndex := 1 + (SInt32(G)-baseAddress) div sizeof(GameTreeRec);
	              pageGameTreeRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserGameTreeDansSaPage);
	            end;
	      end;
      
      {un coup en descendant...}
      i := pageGameTreeRenvoyeeParDerniereLocalisation - k - 1;
      if (i > dernierePageGameTreeCree) then i := i - dernierePageGameTreeCree else
      if (i < 1) then i := i + dernierePageGameTreeCree;
      if ReserveDeGameTree[i] <> NIL then
	      with ReserveDeGameTree[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(G)>=baseAddress) & (SInt32(G)<=baseAddress+(TailleGameTreeBuffer-1)*sizeof(GameTreeRec))
	          then
	            begin
	              NroDePage := i;
	              NroIndex := 1 + (SInt32(G)-baseAddress) div sizeof(GameTreeRec);
	              pageGameTreeRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserGameTreeDansSaPage);
	            end;
	      end;
	  end;
      
  {non trouve ! ce n'est pas normal !}
  NroDePage := -1;
  NroIndex := -1;
  AlerteSimple('Erreur dans LocaliserGameTreeDansSaPage !! Prévenez Stéphane');
end;


function NewGameTreePaginee() : GameTree;
var numeroDePage,IndexDansPage : SInt32;
begin
  if TrouvePlaceDansPageDeGameTree(numeroDePage,IndexDansPage)
    then
      begin
        {WritelnDansRapport('creation de GameTree('+NumEnString(numeroDePage)+','+NumEnString(IndexDansPage)+')');
        WritelnDansRapport('');}
        with ReserveDeGameTree[numeroDePage]^ do
          begin
            NewGameTreePaginee := GameTree(@buffer^[IndexDansPage]);
            libre[IndexDansPage] := false;  
            dec(nbEmplacementVides);
            if nbEmplacementVides<=0
              then
                begin
                  premierEmplacementVide := 0;
                  dernierEmplacementVide := 0;
                end
              else
                begin
                  if IndexDansPage=premierEmplacementVide then
			              repeat
			                inc(premierEmplacementVide);
			              until libre[premierEmplacementVide] | (premierEmplacementVide>=dernierEmplacementVide) | (premierEmplacementVide>TailleGameTreeBuffer);
                  if IndexDansPage=dernierEmplacementVide then
			              repeat
			                dec(dernierEmplacementVide);
			              until libre[dernierEmplacementVide] | (dernierEmplacementVide<=premierEmplacementVide) | (dernierEmplacementVide<1);
                end;
          end
      end
    else
      begin
        NewGameTreePaginee := NIL;
      end;
end;


procedure DisposeGameTreePaginee(G : GameTree);
var NroDePage,NroIndex : SInt32;
begin
  
  {WritelnStringAndNumDansRapport('appel de DisposeGameTreePaginee pour @',SInt32(G));}
  
  LocaliserGameTreeDansSaPage(G,NroDePage,NroIndex);
  
  if (NroDePage >= 1) & (NroDePage <= nbPagesDeGameTree) &
     (NroIndex  >= 1) & (NroIndex  <= TailleGameTreeBuffer) &
     (ReserveDeGameTree[NroDePage] <> NIL) then
    with ReserveDeGameTree[NroDePage]^ do
      begin
        
        {WritelnDansRapport('destruction de GameTree('+NumEnString(NroDePage)+','+NumEnString(NroIndex)+')');}
        
        libre[NroIndex] := true;  
        if nbEmplacementVides<=0
          then
            begin
              nbEmplacementVides := 1;
              premierEmplacementVide := NroIndex;
              dernierEmplacementVide := NroIndex;
            end
          else
            begin
              inc(nbEmplacementVides);
              if (NroIndex < premierEmplacementVide) then premierEmplacementVide := NroIndex;
              if (NroIndex > dernierEmplacementVide) then dernierEmplacementVide := NroIndex;
            end;
      end
end;


END.
