UNIT UnitTriListe;




INTERFACE







uses MacTypes;


procedure TrierListePartie(critereDeTri,algorithmeDeTri : SInt32);
procedure DoTrierListe(critereDeTri,algorithmeDeTri : SInt32);
function AlgoDeTriOptimum(critereDeTri : SInt32) : SInt32;


IMPLEMENTATION







USES UnitNouveauFormat,UnitListe,UnitCriteres,UnitMacExtras,UnitAccesStructuresNouvFormat,
     UnitJaponais,UnitServicesDialogs,UnitOth1,UnitOth2,UnitRapport,UnitPackedThorGame;

var gDernierAlgoDeTriUtilise : SInt32;

procedure TrierListePartie(critereDeTri,algorithmeDeTri : SInt32);
var s1,s2 : PackedThorGame;
    n1,n2 : SInt32;
    c1,c2:str7;
    tick : SInt32;
    nbTests : SInt32;
    comparaison : SInt32;
    err : OSErr;
    
  function PlusGrand(a,b : SInt32) : boolean;
  begin
     inc(nbTests);
     PlusGrand := false;
     case critereDeTri of
       TriParDate           : 
         begin
           n1 := GetAnneePartieParNroRefPartie(a);
           n2 := GetAnneePartieParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 < n2 then PlusGrand := false else
             begin  {meme annee : on classe par tournoi}
               n1 := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(a);
               n2 := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(b);
               if n1>n2 then PlusGrand := true else
               if n1<n2 then PlusGrand := false else
                 begin  
                   if DernierCritereDeTriListeParJoueur=TriParJoueurNoir {on simule un tri stable}
                     then
                       begin
                         {meme tournoi : on classe par joueur noir}
		                  n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
		                  n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
		                  if n1 > n2 then PlusGrand := true else
		                  if n1 < n2 then PlusGrand := false else
		                    begin  {meme joueur noir : on classe par joueur blanc}
		                      n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
		                      n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
		                      if n1 > n2 then PlusGrand := true else
		                      if n1 = n2 then PlusGrand := a > b;
		                    end;
                       end
                     else
                       begin
                         {meme tournoi : on classe par joueur Blanc}
		                  n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
		                  n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
		                  if n1 > n2 then PlusGrand := true else
		                  if n1 < n2 then PlusGrand := false else
		                    begin  {meme joueur Blanc : on classe par joueur noir}
		                      n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
		                      n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
		                      if n1 > n2 then PlusGrand := true else
		                      if n1 = n2 then PlusGrand := a > b;
		                    end;
                       end;
                 end;
             end;
         end;
       TriParAntiDate           : 
         begin
           n1 := GetAnneePartieParNroRefPartie(a);
           n2 := GetAnneePartieParNroRefPartie(b);
           if n1 < n2 then PlusGrand := true else
           if n1 > n2 then PlusGrand := false else
             begin  {meme annee : on classe par tournoi}
               n1 := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(a);
               n2 := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(b);
               if n1 < n2 then PlusGrand := true else
               if n1 > n2 then PlusGrand := false else
                 begin  {meme tournoi : on classe par joueur noir}
                   if DernierCritereDeTriListeParJoueur=TriParJoueurNoir {on simule un tri stable}
                     then
                       begin
                         {meme tournoi : on classe par joueur noir}
		                  n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
		                  n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
		                  if n1 > n2 then PlusGrand := true else
		                  if n1 < n2 then PlusGrand := false else
		                    begin  {meme joueur noir : on classe par joueur blanc}
		                      n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
		                      n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
		                      if n1 > n2 then PlusGrand := true else
		                      if n1 = n2 then PlusGrand := a > b;
		                    end;
                       end
                     else
                       begin
                         {meme tournoi : on classe par joueur Blanc}
		                  n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
		                  n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
		                  if n1 > n2 then PlusGrand := true else
		                  if n1 < n2 then PlusGrand := false else
		                    begin  {meme joueur Blanc : on classe par joueur noir}
		                      n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
		                      n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
		                      if n1 > n2 then PlusGrand := true else
		                      if n1 = n2 then PlusGrand := a > b;
		                    end;
                       end;
                 end;
             end;
         end;
       TriParJoueurNoir     :
         begin
           n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
           n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParJoueurBlanc    :
         begin
           n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
           n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParNroJoueurNoir     : 
         begin
           n1 := GetNroJoueurNoirParNroRefPartie(a);
           n2 := GetNroJoueurNoirParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParNroJoueurBlanc    :
         begin
           n1 := GetNroJoueurBlancParNroRefPartie(a);
           n2 := GetNroJoueurBlancParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParOuverture      : 
          begin
            ExtraitPartieTableStockageParties(a,s1);
            ExtraitPartieTableStockageParties(b,s2);
            comparaison := COMPARE_PACKED_GAMES(s1, s2);
            if (comparaison > 0) then PlusGrand := true else  (** s1 > s2 **)
            if (comparaison = 0) then PlusGrand := a > b;     (** s1 = s2 **)
          end;
       TriParScoreTheorique : 
         begin
           c1 := GetGainTheoriqueParNroRefPartie(a);
           c2 := GetGainTheoriqueParNroRefPartie(b);
           if c1 < c2 then PlusGrand := true else
           if c1 = c2 then PlusGrand := a > b;
         end;
       TriParScoreReel      : 
         begin
           n1 := GetScoreReelParNroRefPartie(a);
           n2 := GetScoreReelParNroRefPartie(b);
           if n1 < n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParDistribution   :
         begin
           n1 := GetNroDistributionParNroRefPartie(a);
           n2 := GetNroDistributionParNroRefPartie(b);
           if n1 < n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
     end;
  end;
  
  (** tri par dénombrement, voir Cormen-Leiserson-Rivest p.172  **)
  procedure EnumerationSort(lo,up : SInt32;CritereDeTri : SInt16);
  type CountingTable = array[-10..-10] of SInt32;
       CountingTablePtr = ^CountingTable;
  var valeur,i,j,kmin,kmax : SInt32;
      c:CountingTablePtr;
  begin
    c := CountingTablePtr(AllocateMemoryPtr((20+Max(Max(3000,nbMaxJoueursEnMemoire),nbMaxTournoisEnMemoire))*sizeof(SInt32)));
    
    if (c <> NIL) then
      begin
	    for i := lo to up do TableTriListeAux^^[i] := tableTriListe^^[i];
	    case CritereDeTri of
	      TriParDate           : 
	        begin
	          kmin := 1900; kmax := 3000;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[GetAnneePartieParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := GetAnneePartieParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	      TriParAntiDate       :
	        begin
	          kmin := 0; kmax := 3000;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[kmax-GetAnneePartieParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := kmax-GetAnneePartieParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	      TriParTournoi        : 
	        begin
	          kmin := -1; kmax := TournoisNouveauFormat.nbTournoisNouveauFormat+10;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	      TriParJoueurNoir     : 
	        begin
	          kmin := -1; kmax := JoueursNouveauFormat.nbJoueursNouveauFormat+10;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	      TriParJoueurBlanc    : 
	        begin
	          kmin := -1; kmax := JoueursNouveauFormat.nbJoueursNouveauFormat+10;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	      TriParNroJoueurNoir     : 
	        begin
	          kmin := -1; kmax := JoueursNouveauFormat.nbJoueursNouveauFormat+10;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[GetNroJoueurNoirParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := GetNroJoueurNoirParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	      TriParNroJoueurBlanc    : 
	        begin
	          kmin := -1; kmax := JoueursNouveauFormat.nbJoueursNouveauFormat+10;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[GetNroJoueurBlancParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := GetNroJoueurBlancParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	      TriParScoreTheorique :
	        begin
	          kmin := 0; kmax := 64;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[GetScoreTheoriqueParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := GetScoreTheoriqueParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	      TriParScoreReel      : 
	        begin
	          kmin := 0; kmax := 64;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[GetScoreReelParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := GetScoreReelParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	      TriParDistribution      : 
	        begin
	          kmin := 0; kmax := nbMaxDistributions+10;
	          for i := kmin to kmax do c^[i] := 0;
	          for j := lo to up do inc(c^[GetNroDistributionParNroRefPartie(TableTriListeAux^^[j])]);
	          for i := kmin+1 to kmax do c^[i] := c^[i]+c^[i-1];
	          for j := up downto lo do 
	            begin
	              valeur := GetNroDistributionParNroRefPartie(TableTriListeAux^^[j]);
	              tableTriListe^^[c^[valeur]] := TableTriListeAux^^[j];
	              dec(c^[valeur]);
	            end;
	        end;
	    end;
	  end;
	if c <> NIL then DisposeMemoryPtr(Ptr(c));
  end;
  
  procedure RadixSort(lo,up : SInt32);
  var i : SInt32;
  begin
    for i := lo to up do tableTriListe^^[i] := i;
    case critereDeTri of
      TriParDate           :
        begin
          EnumerationSort(lo,up,TriParTournoi);
          EnumerationSort(lo,up,TriParDate);
        end;
      TriParAntiDate       : 
        begin
          EnumerationSort(lo,up,TriParTournoi);
          EnumerationSort(lo,up,TriParAntiDate);
        end;
      TriParJoueurNoir     : 
        begin
          EnumerationSort(lo,up,TriParJoueurNoir);
        end;
      TriParJoueurBlanc    : 
        begin
          EnumerationSort(lo,up,TriParJoueurBlanc);
        end;
      TriParScoreTheorique : 
        begin
          EnumerationSort(lo,up,TriParScoreReel);
          EnumerationSort(lo,up,TriParScoreTheorique);
        end;
      TriParScoreReel      : 
        begin
          EnumerationSort(lo,up,TriParScoreReel);
        end;
      TriParDistribution      : 
        begin
          EnumerationSort(lo,up,TriParDistribution);
        end;
    end;
  end;
  
  procedure ShellSort(lo,up : SInt32);
  var i,d,j,temp : SInt32;
  begin
    for i := lo to up do tableTriListe^^[i] := i;
    if up-lo>0 then
      begin
        d := up-lo+1;
        while d>1 do
          begin
            if d<5 
              then d := 1
              else d := MyTrunc(0.45454*d);
            for i := up-d downto lo do
              begin
                temp := tableTriListe^^[i];
                j := i+d;
                while (j<=up) & PlusGrand(temp,tableTriListe^^[j]) do
                  begin
                    tableTriListe^^[j-d] := tableTriListe^^[j];
                    j := j+d;
                  end;
                tableTriListe^^[j-d] := temp;
              end;
          end;
      end;
  end; {shellSort}
  
  procedure ShellSortWithFixIncrements(lo,up : SInt32);
  var i,d,j,k,temp : SInt32;
      increments : array[1..20] of SInt32;
  begin
    increments[1] := 34807;
    increments[2] := 15823;
    increments[3] := 7193;
    increments[4] := 3271;
    increments[5] := 1489;
    increments[6] := 677;
    increments[7] := 307;
    increments[8] := 137;
    increments[9] := 61;
    increments[10] := 29;
    increments[11] := 13;
    increments[12] := 5;
    increments[13] := 2;
    increments[14] := 1;
    increments[15] := 0;
    for i := lo to up do tableTriListe^^[i] := i;
    if up-lo>0 then
      begin
        for k := 1 to 14 do
          begin
            d := increments[k];
            for i := up-d downto lo do
              begin
                temp := tableTriListe^^[i];
                j := i+d;
                while (j<=up) & PlusGrand(temp,tableTriListe^^[j]) do
                  begin
                    tableTriListe^^[j-d] := tableTriListe^^[j];
                    j := j+d;
                  end;
                tableTriListe^^[j-d] := temp;
              end;
          end;
      end;
  end; {shellSortWithFixIncrements}

  procedure QuickSort(lo,up : SInt32);
  const nstack=100;
        m=7;
  var i,j,k,l,ir,jstack : SInt32;
      a,temp : SInt32;
      istack : array[1..nstack] of SInt32;
  label 10,20,99;
  begin
    for i := lo to up do tableTriListe^^[i] := i;
    if up-lo>0 then
      begin
        jstack := 0;
        l := lo;
        ir := up;
        while true do begin
          if ir-l<m then begin
            for j := l+1 to ir do
              begin
                temp := tableTriListe^^[j];
                for i := j-1 downto l do 
                  begin
                    if PlusGrand(temp,tableTriListe^^[i]) then goto 10;
                    tableTriListe^^[i+1] := tableTriListe^^[i];
                  end;
                i := l-1;
                10:
                tableTriListe^^[i+1] := temp;
              end;
            
            if jstack=0 then exit(QuickSort);
            ir := istack[jstack];
            l := istack[jstack-1];
            jstack := jstack-2;
          end
          else begin
            k := (l+ir) div 2;
            temp := tableTriListe^^[k];
            tableTriListe^^[k] := tableTriListe^^[l+1];
            tableTriListe^^[l+1] := temp;
            if PlusGrand(tableTriListe^^[l+1],tableTriListe^^[ir]) then begin
              temp := tableTriListe^^[l+1];
              tableTriListe^^[l+1] := tableTriListe^^[ir];
              tableTriListe^^[ir] := temp;
            end;
            if PlusGrand(tableTriListe^^[l],tableTriListe^^[ir]) then begin
              temp := tableTriListe^^[l];
              tableTriListe^^[l] := tableTriListe^^[ir];
              tableTriListe^^[ir] := temp;
            end;
            if PlusGrand(tableTriListe^^[l+1],tableTriListe^^[l]) then begin
              temp := tableTriListe^^[l+1];
              tableTriListe^^[l+1] := tableTriListe^^[l];
              tableTriListe^^[l] := temp;
            end;
            i := l+1;
            j := ir;
            a := tableTriListe^^[l];
            while true do begin
              repeat inc(i) until PlusGrand(tableTriListe^^[i],a);
              repeat dec(j) until PlusGrand(a,tableTriListe^^[j]);
              if j<i then goto 20; {break}
              temp := tableTriListe^^[i];
              tableTriListe^^[i] := tableTriListe^^[j];
              tableTriListe^^[j] := temp;
            end;
    20:     tableTriListe^^[l] := tableTriListe^^[j];
            tableTriListe^^[j] := a;
            jstack := jstack+2;
            if jstack>nstack then AlerteSimple('Erreur dans QuickSort : nstack est trop petit');
            if ir-i+1>=j-l then begin
              istack[jstack] := ir;
              istack[jstack-1] := i;
              ir := j-1;
            end
            else begin
              istack[jstack] := j-1;
              istack[jstack-1] := l;
              l := i;
            end;
          end;
        end;
     99 :
     end;
   end;

begin  {TrierListePartie}

  if not(AutorisationCalculsLongsSurListe()) 
    then exit(TrierListePartie);
    
  if problemeMemoireBase 
     then exit(TrierListePartie);

  if ((critereDeTri=TriParJoueurBlanc) | (critereDeTri=TriParJoueurNoir)) & not(JoueursEtTournoisEnMemoire)
     then exit(TrierListePartie);
   
  if (critereDeTri=TriParDate) & LectureAntichronologique then critereDeTri := TriParAntiDate;
  if (critereDeTri=TriParAntiDate) & not(LectureAntichronologique) then critereDeTri := TriParDate;
  
  if ((critereDeTri=TriParJoueurBlanc) | 
      (critereDeTri=TriParJoueurNoir) |
      (critereDeTri=TriParDate) | 
      (critereDeTri=TriParAntiDate)) then
        begin
          if not(JoueursNouveauFormat.dejaTriesAlphabetiquement) then
            begin
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant TrierAlphabetiquementJoueursNouveauFormat dans TrierListePartie',true);
              TrierAlphabetiquementJoueursNouveauFormat;
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Apres TrierAlphabetiquementJoueursNouveauFormat dans TrierListePartie',true);
              if gVersionJaponaiseDeCassio & gHasJapaneseScript
                then err := LitNomsDesJoueursEnJaponais();
            end;
          if not(TournoisNouveauFormat.dejaTriesAlphabetiquement) then
            begin
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant TrierAlphabetiquementTournoisNouveauFormat dans TrierListePartie',true);
              TrierAlphabetiquementTournoisNouveauFormat;
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Apres TrierAlphabetiquementTournoisNouveauFormat dans TrierListePartie',true);
              if gVersionJaponaiseDeCassio & gHasJapaneseScript
                then err := LitNomsDesTournoisEnJaponais();
            end;
        end;
    
  {
  if BAND(theEvent.modifiers,optionKey) <> 0 then algorithmeDeTri := kShellSort;
  if BAND(theEvent.modifiers,controlKey) <> 0 then algorithmeDeTri := kRadixSort;
  if BAND(theEvent.modifiers,shiftKey) <> 0 then algorithmeDeTri := kEnumerationSort;
  }
  
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant le tri des parties proprement dit dans TrierListePartie',true);
    
  nbTests := 0;
  tick := TickCount();
  case algorithmeDeTri of
    kShellSort                  : ShellSort(1,nbPartiesChargees);
    kShellsortWithFixIncrements : ShellSortWithFixIncrements(1,nbPartiesChargees);
    kQuickSort                  : QuickSort(1,nbPartiesChargees);
    kRadixSort                  : RadixSort(1,nbPartiesChargees);
    kEnumerationSort            : EnumerationSort(1,nbPartiesChargees,critereDeTri);
  end;
  tick := TickCount()-tick;   
  
  {
  case critereDeTri of
   TriParDate           : WriteDansRapport('TriParDate : ');
   TriParAntiDate       : WriteDansRapport('TriParAntiDate : ');
   TriParJoueurNoir     : WriteDansRapport('TriParJoueurNoir : ');
   TriParJoueurBlanc    : WriteDansRapport('TriParJoueurBlanc : ');
   TriParNroJoueurNoir  : WriteDansRapport('TriParNroJoueurNoir : ');
   TriParNroJoueurBlanc : WriteDansRapport('TriParNroJoueurBlanc : ');
   TriParOuverture      : WriteDansRapport('TriParOuverture : ');
   TriParScoreTheorique : WriteDansRapport('TriParScoreTheorique : ');
   TriParScoreReel      : WriteDansRapport('TriParScoreReel : ');
   TriParDistribution   : WriteDansRapport('TriParDistribution : ');
  end;
  case algorithmeDeTri of
    kShellSort                  : WriteDansRapport('ShellSort');
    kShellsortWithFixIncrements : WriteDansRapport('ShellSortWithFixIncrements');
    kQuickSort                  : WriteDansRapport('QuickSort');
    kRadixSort                  : WriteDansRapport('RadixSort');
    kEnumerationSort            : WriteDansRapport('EnumerationSort');
  end;
  WriteStringandnumDansRapport(', nb de tests  =',nbTests);
  WritelnStringandnumDansRapport(',  temps =',tick);
  }
  
  
  if critereDeTri=TriParAntiDate then critereDeTri := TriParDate;
  if critereDeTri=TriParJoueurNoir then DernierCritereDeTriListeParJoueur := TriParJoueurNoir;
  if critereDeTri=TriParJoueurBlanc then DernierCritereDeTriListeParJoueur := TriParJoueurBlanc;
  
  gDernierAlgoDeTriUtilise := algorithmeDeTri;
end;




procedure DoTrierListe(critereDeTri,algorithmeDeTri : SInt32);
var i,etat : SInt32;
    ancienCritereDeTri,ancienAlgoDeTri : SInt32;
    unRect : rect;
    oldport : grafPtr;
begin        
  {if (nbPartiesActives>0) then}
    begin
      GetPort(oldport);  
      ancienCritereDeTri := gGenreDeTriListe;
      ancienAlgoDeTri := gDernierAlgoDeTriUtilise;
      if (ancienCritereDeTri <> critereDeTri) | (ancienAlgoDeTri <> algorithmeDeTri) then
        begin
          AnnulerSousCriteresRuban;
          if windowListeOpen then 
            begin
              SetPortByWindow(wListePtr);
              case critereDeTri of
                TriParDistribution    : unRect := RubanDistributionRect;
                TriParDate            : unRect := RubanTournoiRect;
                TriParJoueurNoir      : unRect := RubanNoirsRect;
                TriParJoueurBlanc     : unRect := RubanBlancsRect;
                TriParOuverture       : unRect := RubanCoupRect;
                TriParScoreTheorique  : unRect := RubanTheoriqueRect;
                TriParScoreReel       : unRect := RubanReelRect
              end;
              InvertRect(unRect);
            end;
            
          if not(gPendantLesInitialisationsDeCassio) then
            begin
              watch := GetCursor(watchcursor);
              SafeSetCursor(watch);
            end;
          OrdreDuTriRenverse := false;
          gGenreDeTriListe := critereDeTri;
          for i := 0 to 65 do 
            begin
              etat := GetNombreDePartiesActivesDansLeCachePourCeCoup(i);
              if (etat <> PasDePartieActive) and (etat <> 1) then
                if ListePartiesEstGardeeDansLeCache(i,etat) then
                  InvalidateNombrePartiesActivesDansLeCache(i);
            end;
          TrierListePartie(critereDeTri,algorithmeDeTri);  
          if windowListeOpen then 
            begin
              SetPortByWindow(wListePtr);
              InvertRect(unRect);
            end;
          EcritRubanListe(false);
          CalculEmplacementCriteresListe;
          LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
          AjusteCurseur;
        end;
      SetPort(oldport);
    end;
end;


function AlgoDeTriOptimum(critereDeTri : SInt32) : SInt32;
begin
  if critereDeTri=TriParOuverture
    then AlgoDeTriOptimum := kQuickSort
    else AlgoDeTriOptimum := kRadixSort;
end;



end.