UNIT UnitPagesATR;



INTERFACE







USES MacTypes;

TYPE 
    ATRRec = record
                splitChar : char;
                filsMoins,filsEgal,filsPlus : ATR;
              end;
    ATR = ^ATRRec;


procedure InitUnitPagesDeATR;
procedure DisposeToutesLesPagesDeATR;


function PeutCreerNouvellePageATR() : boolean;
function TrouvePlaceDansPageDeATR(var nroPage,nroIndex : SInt32) : boolean;
procedure LocaliserATRDansSaPage(G : ATR; var NroDePage,NroIndex : SInt32);


function NewATRPaginee() : ATR;
procedure DisposeATRPaginee(x : ATR);



IMPLEMENTATION







USES UnitOth1,UnitServicesDialogs,UnitServicesMemoire,UnitRapport;


const TailleATRBuffer=500;
type ATRArray = array[1..TailleATRBuffer] of ATRRec;
     ATRBuffer = ^ATRArray;
     PageDeATR =  record
                         buffer : ATRBuffer;
                         libre  : {packed} array[0..TailleATRBuffer] of boolean;
                         premierEmplacementVide : SInt16; 
                         dernierEmplacementVide : SInt16; 
                         nbEmplacementVides     : SInt16; 
                       end;
     PageDeATRPtr = ^PageDeATR;
     
const nbPagesDeATR=1000;
var ReserveDeATR : array [1..nbPagesDeATR] of PageDeATRPtr;
    dernierePageATRCree : SInt32;
    pageATRRenvoyeeParDerniereLocalisation : SInt32;
    pageATRRenvoyeeParDerniereCreation : SInt32;


procedure InitUnitPagesDeATR;
var i : SInt32;
begin
  for i := 1 to nbPagesDeATR do
	  begin
	    ReserveDeATR[i] := NIL;
	  end;
	dernierePageATRCree := 0;
	pageATRRenvoyeeParDerniereLocalisation := 1;
	pageATRRenvoyeeParDerniereCreation := 1;
	if PeutCreerNouvellePageATR() then;
end;


procedure DisposeToutesLesPagesDeATR;
begin
  {
  for i := 1 to nbPagesDeATR do
	  if ReserveDeATR[i] <> NIL then
	    begin
	      DisposeMemoryPtr(Ptr(ReserveDeATR[i]^.buffer));
	      ReserveDeATR[i]^.buffer := NIL;
	      DisposeMemoryPtr(Ptr(ReserveDeATR[i]));
	      ReserveDeATR[i] := NIL;
	    end;
	dernierePageATRCree := 0;
	pageATRRenvoyeeParDerniereLocalisation := 1;
	pageATRRenvoyeeParDerniereCreation := 1;
	}
end;



function PeutCreerNouvellePageATR() : boolean;
var i : SInt32;
begin
  
  if dernierePageATRCree>=nbPagesDeATR then
    begin
      AlerteSimple('le nombre de pages de ATR est trop petit dans PeutCreerNouvellePageATR!! Pr�venez St�phane');
      PeutCreerNouvellePageATR := false;
      exit(PeutCreerNouvellePageATR);
    end;
    
  
  inc(dernierePageATRCree);
  ReserveDeATR[dernierePageATRCree] := PageDeATRPtr(AllocateMemoryPtr(sizeof(PageDeATR)));
  
  if ReserveDeATR[dernierePageATRCree] = NIL then
    begin
      AlerteSimple('plus de place en memoire pour creer une page de ATR dans PeutCreerNouvellePageATR!! Pr�venez St�phane');
      PeutCreerNouvellePageATR := false;
      exit(PeutCreerNouvellePageATR);
    end;
  
  with ReserveDeATR[dernierePageATRCree]^ do
    begin
      buffer := ATRBuffer(AllocateMemoryPtr(sizeof(ATRArray+20)));
      if buffer = NIL then
        begin
          AlerteSimple('plus de place en memoire pour creer un buffer de ATR dans PeutCreerNouvellePageATR !! Pr�venez St�phane');
          PeutCreerNouvellePageATR := false;
          exit(PeutCreerNouvellePageATR);
        end;
        
        
      PeutCreerNouvellePageATR := true;
      
      for i := 1 to TailleATRBuffer do
        libre[i] := true;  
      premierEmplacementVide := 1;
      dernierEmplacementVide := TailleATRBuffer;
      nbEmplacementVides    := TailleATRBuffer;
    end;
  
  {
  WritelnDansRapport('Cr�ation d''une nouvelle page de ATR');
  WritelnStringAndNumDansRapport('soldeCreationATR=',soldeCreationATR);
  SysBeep(0);
  AttendFrappeClavier;
  }
  
end;


function TrouvePlaceDansPageDeATR(var nroPage,nroIndex : SInt32) : boolean;
var n,i,k : SInt32;
begin
  if dernierePageATRCree<=0 then
    begin
      TrouvePlaceDansPageDeATR := false;
      nroPage := -1;
      nroIndex := -1;
      exit(TrouvePlaceDansPageDeATR);
    end;
  
  {
  for n := 1 to dernierePageATRCree do
    begin
    if ReserveDeATR[n] <> NIL then
      with ReserveDeATR[n]^ do
        begin
          WritelnDansRapport('Reserve['+NumEnString(n)+'] est OK');
          WritelnStringAndNumDansRapport('nbEmplacementVides=',nbEmplacementVides);
          WritelnStringAndNumDansRapport('premierEmplacementVide=',premierEmplacementVide);
          WritelnStringAndNumDansRapport('dernierEmplacementVide=',dernierEmplacementVide);
          WritelnStringAndNumDansRapport('soldeCreationATR=',soldeCreationATR);
         end;
     if dernierePageATRCree>=2 then AttendFrappeClavier;
     end;
  }
  
  for k := 0 to (dernierePageATRCree div 2) do
    begin
      {un coup en montant...}
      n := pageATRRenvoyeeParDerniereCreation + k;
      if (n > dernierePageATRCree) then n := n - dernierePageATRCree else
      if (n < 1) then n := n + dernierePageATRCree;
  
      if ReserveDeATR[n] <> NIL then
        with ReserveDeATR[n]^ do
          if (buffer <> NIL) & (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeATR := true;
                  nroPage := n;
                  nroIndex := i;
                  pageATRRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeATR);
                end;

      {un coup en descendant...}
      n := pageATRRenvoyeeParDerniereCreation - k - 1;
      if (n > dernierePageATRCree) then n := n - dernierePageATRCree else
      if (n < 1) then n := n + dernierePageATRCree;
      if ReserveDeATR[n] <> NIL then
        with ReserveDeATR[n]^ do
          if (buffer <> NIL) & (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeATR := true;
                  nroPage := n;
                  nroIndex := i;
                  pageATRRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeATR);
                end;
    end;
    
  
  {pas de place vide trouvee : on demande la creation d'une nouvelle page}
  if PeutCreerNouvellePageATR()
    then
	    begin
	      TrouvePlaceDansPageDeATR := true;
	      nroPage := dernierePageATRCree;
	      nroIndex := 1;
	      pageATRRenvoyeeParDerniereCreation := dernierePageATRCree;
	    end
    else
      begin
	      TrouvePlaceDansPageDeATR := false;
	      nroPage := -1;
	      nroIndex := -1;
	    end
end;



procedure LocaliserATRDansSaPage(G : ATR; var NroDePage,NroIndex : SInt32);
var i,k : SInt32;
    baseAddress : SInt32;
begin
  if G = NIL then
    begin
      NroDePage := 0;
      NroIndex := 0;
      {WritelnDansRapport('appel de LocaliserATRDansSaPage(NIL)');}
      exit(LocaliserATRDansSaPage);
    end;
  
  for k := 0 to (dernierePageATRCree div 2) do
    begin
      {un coup en montant...}
      i := pageATRRenvoyeeParDerniereLocalisation + k;
      if (i > dernierePageATRCree) then i := i - dernierePageATRCree else
      if (i < 1) then i := i + dernierePageATRCree;
      
	    if ReserveDeATR[i] <> NIL then
	      with ReserveDeATR[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(G)>=baseAddress) & (SInt32(G)<=baseAddress+(TailleATRBuffer-1)*sizeof(ATRRec))
	          then
	            begin
	              NroDePage := i;
	              NroIndex := 1 + (SInt32(G)-baseAddress) div sizeof(ATRRec);
	              pageATRRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserATRDansSaPage);
	            end;
	      end;
	    
	    {un coup en descendant...}
      i := pageATRRenvoyeeParDerniereLocalisation - k - 1;
      if (i > dernierePageATRCree) then i := i - dernierePageATRCree else
      if (i < 1) then i := i + dernierePageATRCree;
      
	    if ReserveDeATR[i] <> NIL then
	      with ReserveDeATR[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(G)>=baseAddress) & (SInt32(G)<=baseAddress+(TailleATRBuffer-1)*sizeof(ATRRec))
	          then
	            begin
	              NroDePage := i;
	              NroIndex := 1 + (SInt32(G)-baseAddress) div sizeof(ATRRec);
	              pageATRRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserATRDansSaPage);
	            end;
	      end;
	  end;
    
  {non trouve ! ce n'est pas normal !}
  NroDePage := -1;
  NroIndex := -1;
  AlerteSimple('Erreur dans LocaliserATRDansSaPage !! Pr�venez St�phane');
end;


function NewATRPaginee() : ATR;
var numeroDePage,IndexDansPage : SInt32;
begin
  if TrouvePlaceDansPageDeATR(numeroDePage,IndexDansPage)
    then
      begin
        {WritelnDansRapport('creation de ATR('+NumEnString(numeroDePage)+','+NumEnString(IndexDansPage)+')');
        WritelnDansRapport('');}
        with ReserveDeATR[numeroDePage]^ do
          begin
            NewATRPaginee := ATR(@buffer^[IndexDansPage]);
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
			              until libre[premierEmplacementVide] | (premierEmplacementVide>=dernierEmplacementVide) | (premierEmplacementVide>TailleATRBuffer);
                  if IndexDansPage=dernierEmplacementVide then
			              repeat
			                dec(dernierEmplacementVide);
			              until libre[dernierEmplacementVide] | (dernierEmplacementVide<=premierEmplacementVide) | (dernierEmplacementVide<1);
                end;
          end
      end
    else
      begin
        NewATRPaginee := NIL;
      end;
end;


procedure DisposeATRPaginee(x : ATR);
var NroDePage,NroIndex : SInt32;
begin
  
  
  {WritelnStringAndNumDansRapport('appel de DisposeATRPaginee pour @',SInt32(G));}
  
  
  LocaliserATRDansSaPage(x,NroDePage,NroIndex);
  
  
  if (NroDePage >= 1) & (NroDePage <= nbPagesDeATR) &
     (NroIndex  >= 1) & (NroIndex  <= TailleATRBuffer) &
     (ReserveDeATR[NroDePage] <> NIL) then
    with ReserveDeATR[NroDePage]^ do
      begin
        
        
        {WritelnDansRapport('destruction de ATR('+NumEnString(NroDePage)+','+NumEnString(NroIndex)+')');}
        
        
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
