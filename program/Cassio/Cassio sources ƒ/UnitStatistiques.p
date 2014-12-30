UNIT UnitStatistiques;




INTERFACE









USES MacTypes;

procedure ConstruitStatistiques(withCheckEvent : boolean);
procedure DessineStatistiques(avecEffacement : boolean;decH,decV : SInt32;withCheckEvent : boolean);
procedure EcritStatistiques(withCheckEvent : boolean);
procedure CheckEventPendantCalculsBase;


function StatistiquesSontEcritesDansLaFenetreNormale() : boolean;
procedure SetStatistiquesSontEcritesDansLaFenetreNormale(flag : boolean);

function StatistiquesCalculsFaitsAuMoinsUneFois() : boolean;
procedure SetStatistiquesCalculsFaitsAuMoinsUneFois(flag : boolean);

procedure DessineRubanStatistiques(decH,decV : SInt16);
procedure EcritRubanStatistiques;



IMPLEMENTATION







USES UnitActions,UnitRapport,UnitAccesStructuresNouvFormat,UnitNormalisation,UnitScannerOthellistique,
     UnitOth1,SNStrings,UnitFenetres,UnitServicesMemoire,UnitCarbonisation,UnitMacExtras,MyMathUtils,
     UnitListe;



const kCalculsFaitsAuMoinsUneFois   = 1; 
      kEcritureDansLaFenetreNormale = 2;  {puis 4, 8, etc}
      kAllFlags = $FFFFFFFF;

function StatistiquesSontEcritesDansLaFenetreNormale() : boolean;
var result : boolean;
begin
  if (statistiques <> NIL) 
    then 
      begin
        result := (BAND(statistiques^^.flags, kEcritureDansLaFenetreNormale) <> 0);
        (* WritelnStringAndBoolDansRapport('         StatistiquesSontEcritesDansLaFenetreNormale : cas 1 => ',result); *)
        StatistiquesSontEcritesDansLaFenetreNormale := result;
      end
    else 
      begin
        (* WritelnStringAndBoolDansRapport('         StatistiquesSontEcritesDansLaFenetreNormale : cas 2 (statistiques = NIL) => ',false); *)
        StatistiquesSontEcritesDansLaFenetreNormale := false;
      end;
end;

procedure SetStatistiquesSontEcritesDansLaFenetreNormale(flag : boolean);
begin
  (* if flag
    then WritelnDansRapport('SetStatistiquesSontEcritesDansLaFenetreNormale(true)')
    else WritelnDansRapport('SetStatistiquesSontEcritesDansLaFenetreNormale(false)'); *)
    
  if (statistiques <> NIL) 
    then 
      begin
        if flag 
          then statistiques^^.flags := (statistiques^^.flags OR kEcritureDansLaFenetreNormale)
          else statistiques^^.flags := (statistiques^^.flags AND (kAllFlags - kEcritureDansLaFenetreNormale));
      end
    else WritelnDansRapport('WARNING : statistiques = NIL dans SetStatistiquesSontEcritesDansLaFenetreNormale !!');
end;


function StatistiquesCalculsFaitsAuMoinsUneFois() : boolean;
var result : boolean;
begin
  if (statistiques <> NIL) 
    then 
      begin
        result := (BAND(statistiques^^.flags, kCalculsFaitsAuMoinsUneFois) <> 0);
        
        (* WritelnStringAndBoolDansRapport('          StatistiquesCalculsFaitsAuMoinsUneFois : cas 1 => ',result); *)
        StatistiquesCalculsFaitsAuMoinsUneFois := result;
      end
    else  
      begin
        (* WritelnStringAndBoolDansRapport('          StatistiquesCalculsFaitsAuMoinsUneFois : cas 2 (statistiques = NIL) => ',false); *)
        StatistiquesCalculsFaitsAuMoinsUneFois := false;
      end;
end;


procedure SetStatistiquesCalculsFaitsAuMoinsUneFois(flag : boolean);
begin
  (* if flag
    then WritelnDansRapport('SetStatistiquesCalculsFaitsAuMoinsUneFois(true)')
    else WritelnDansRapport('SetStatistiquesCalculsFaitsAuMoinsUneFois(false)'); *)
    
  if (statistiques <> NIL) 
    then 
      begin
        if flag 
          then statistiques^^.flags := (statistiques^^.flags OR kCalculsFaitsAuMoinsUneFois)
          else statistiques^^.flags := (statistiques^^.flags AND (kAllFlags - kCalculsFaitsAuMoinsUneFois));
      end
    else WritelnDansRapport('WARNING : statistiques = NIL dans SetStatistiquesCalculsFaitsAuMoinsUneFois !!');
end;



procedure ConstruitStatistiques(withCheckEvent : boolean);
var nroreference : SInt32;
    reponse : byte;
    gainNoirR,gainNoirT : SInt32;
    flag : boolean;
    index : SInt32;
    StatistiquesTemporaires : t_statistique;
    nbrecoupPlus1 : SInt32;
    temps : SInt32;
    up,lo,i,j : SInt32;
    tableNumerotationReponses : plateauOthello;
    oldMagicCookie : SInt32;
label sortie;
begin
  oldMagicCookie := DemandeCalculsPourBase.magicCookie;
  {WritelnStringAndNumDansRapport('--> ConstruitStatistiques : ',oldMagicCookie);}
  
  if not(problemeMemoireBase) & (statistiques <> NIL) then
    BEGIN
		  with DemandeCalculsPourBase do
		    begin
			  if not(problemeMemoireBase) then
			    begin
			      temps := TickCount();
			      nbrecoupPlus1 := nbreCoup+1;
			      with StatistiquesTemporaires do
			        begin
			          nbreponsesTrouvees := 0;
			          nbTotalParties := 0;
			          GainNoirTotalReel := 0;
			          GainNoirTotalTheorique := 0;
			          flags := statistiques^^.flags;
			          if nbreCoup <= 60 then
			            begin
			              if nbPartiesActives<>tableNumeroReference^^[0]
			                then
			                  begin
			                    SysBeep(0);
			                    WriteStringAndNumAt('nbPartiesActives = ',nbPartiesActives,10,10);
			                    WriteStringAndNumAt('tableNumeroReference^^[0] = ',tableNumeroReference^^[0],10,22);
			                  end
			                else
			                  begin
			                  MemoryFillChar(@tableNumerotationReponses,sizeof(tableNumerotationReponses),chr(0));
			                  for i := 1 to nbPartiesActives do  {nbPartiesActives}
			                    begin
			                      if magicCookie<>oldMagicCookie then goto sortie;
			                      if (TickCount()<>dernierTickPourCheckEventDansCalculsBase) & withCheckEvent then CheckEventPendantCalculsBase;
				                  if magicCookie<>oldMagicCookie then goto sortie;
			                      
			                      nroreference := tableNumeroReference^^[i];
			                      
			                      GetGainsTheoriqueEtReelParNroRefPartie(nroReference,gainNoirT,gainNoirR);
			                      
			                      if (nbreCoup=0)
			                        then reponse := 56 {F5}
			                        else
			                          if gameOver
			                            then reponse := 99
			                            else ExtraitCoupTableStockagePartie(nroreference,nbrecoupPlus1,reponse);
			                            
			                      index := tableNumerotationReponses[reponse];
			                      if index>0 
			                        then
			                          begin
			                            with table[index] do
			                              begin
			                                 inc(nbpartiessurcecoup);
			                                 GainNoirReel := GainNoirReel+gainNoirR;
			                                 GainNoirTheorique := GainNoirTheorique+gainNoirT;
			                              end;
			                          end
			                        else
			                          begin
			                            if (nbreponsesTrouvees<nbMaxStatistiques) & (reponse>0) then
			                              begin
			                                nbreponsesTrouvees := nbreponsesTrouvees+1;
			                                tableNumerotationReponses[reponse] := nbreponsesTrouvees;
			                                with table[nbreponsesTrouvees] do
			                                  begin
			                                    coup := reponse;
			                                    nbpartiessurcecoup := 1;
			                                    GainNoirReel := gainNoirR;
			                                    GainNoirTheorique := gainNoirT;
			                                  end;
			                              end;
			                          end;
			                    end;
			                    for i := 1 to nbreponsesTrouvees do
			                      begin
			                        nbTotalParties := nbTotalParties+table[i].nbpartiessurcecoup;
			                        GainNoirTotalReel := GainNoirTotalReel+table[i].GainNoirReel;
			                        GainNoirTotalTheorique := GainNoirTotalTheorique+table[i].GainNoirTheorique;
			                      end;
			                end;
			               tempsdeCalcul := TickCount()-temps;
			              end;  
			         end;{with}     
			         
			       if magicCookie<>oldMagicCookie then goto sortie;
			       if (TickCount()<>dernierTickPourCheckEventDansCalculsBase) & withCheckEvent then CheckEventPendantCalculsBase;
				   if magicCookie<>oldMagicCookie then goto sortie;
				   
			       with StatistiquesTemporaires do
			         begin
			           up := nbreponsesTrouvees;
			           lo := 1;
			           for i := up-1 downto lo do
			             begin
			               table[0] := table[i];
			               j := i+1;
			               flag := true;
			               while (j <= up) & flag do
			                 if table[0].nbpartiessurcecoup<table[j].nbpartiessurcecoup 
			                   then
			                     begin
			                       table[j-1] := table[j];
			                       j := j+1;
			                     end
			                   else 
			                     flag := false;
			               table[j-1] := table[0];
			             end;
			         end;
			      statistiques^^ := StatistiquesTemporaires;
			      SetStatistiquesCalculsFaitsAuMoinsUneFois(true);
			  end;
		    end; {with DemandeCalculsPourBase do}
		    
		  sortie :
		     {WritelnStringAndNumDansRapport('<-- ConstruitStatistiques : ',oldMagicCookie);}
    END;
end;


procedure DessineStatistiques(avecEffacement : boolean;decH,decV : SInt32;withCheckEvent : boolean);
var yPosition,compteur : SInt32;
    s : string;
    nbPartiestotal : SInt32;
    coup : SInt16; 
    pourcentage : extended;
    nbpartiessurcecoup : SInt32;
    premiercoup : SInt16; 
    autreCoupQuatreDansPartie : boolean;
    xPositionCoup,xPositionNombreParties,xPositionPourcentageNoirR : SInt32;
    xPositionPourcentageBlancR,xPositionPourcentageNoirT,xPositionPourcentageBlancT : SInt32;
    largeurTotalString : SInt32;
    oldMagicCookie : SInt32;
    oldport : grafPtr;
    ligneRect : rect;
label sortie;
begin
  oldMagicCookie := DemandeCalculsPourBase.magicCookie;
  {WritelnStringAndNumDansRapport('--> DessineStatistiques : ',oldMagicCookie);}
    
  if not(problemeMemoireBase) & (statistiques <> NIL) then
    BEGIN
		  if StatistiquesSontEcritesDansLaFenetreNormale()
		    then GetPort(oldport);
		  
		  
		  with DemandeCalculsPourBase do
		    if windowStatOpen then
		      begin
			    xPositionCoup := DecH+10;
			    xPositionNombreParties := DecH+40;
			    xPositionPourcentageNoirR := DecH+100;
			    xPositionPourcentageBlancR := DecH+134;
			    xPositionPourcentageNoirT := DecH+183;
			    xPositionPourcentageBlancT := DecH+217;

			    TextMode(1);
			    TextFont(gCassioApplicationFont);
			    TextFace(normal); 
			    TextSize(gCassioSmallFontSize);
			    yposition := DecV+hauteurRubanStatistiques+1;
			    
			    nbPartiestotal := statistiques^^.nbTotalParties;
			    if (nbPartiestotal<=0) | (nbPartiesChargees<=0) | (nbPartiesActives<=0) | not(StatistiquesCalculsFaitsAuMoinsUneFois()) then
			        begin
			          
			          if StatistiquesSontEcritesDansLaFenetreNormale() then 
			            begin
			              SetPortByWindow(wStatPtr);
			              if gCassioUseQuartzAntialiasing then EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),true);
			            end;
			            
			          if avecEffacement & StatistiquesSontEcritesDansLaFenetreNormale() then 
			             begin
			               with QDGetPortBound() do
					             begin
					               SetRect(lignerect,DecH,yposition+1,right,bottom-15);
					               EraseRect(lignerect);
					               SetRect(lignerect,DecH,Max(bottom-15,yposition+1),right-15,bottom);
					               EraseRect(lignerect);
					             end;
					         end;
			          if nbPartiesChargees<=0 then 
			            begin
			              Moveto(DecH+30,DecV+50);
			              GetIndString(s,TextesStatistiquesID,8);
			              DrawString(s);
			            end
			           else
			          if (nbPartiestotal<=0) & (nbPartiesActives>0) then
			            begin
			              Moveto(DecH+50,DecV+50);
			              if gameOver 
			                then GetIndString(s,TextesStatistiquesID,12)
			                else GetIndString(s,TextesStatistiquesID,13);
			              DrawString(s);
			            end
			           else
			            begin
			              Moveto(DecH+30,DecV+50);
			              GetIndString(s,TextesStatistiquesID,10);
			              DrawString(s);
			              if positionfeerique then
			                begin
			                  Moveto(DecH+30,DecV+62);
			                  GetIndString(s,TextesStatistiquesID,14);
			                  DrawString(s);
			                end else
			              if sousSelectionActive then
			                begin
			                  Moveto(DecH+30,DecV+62);
			                  GetIndString(s,TextesStatistiquesID,11);
			                  DrawString(s);
			                end;
			            end;
			        end
			      else
			        begin
			          if (magicCookie<>oldMagicCookie) | not(windowStatOpen) then goto sortie;
			          if (TickCount()<>dernierTickPourCheckEventDansCalculsBase) & withCheckEvent then CheckEventPendantCalculsBase;
				        if (magicCookie<>oldMagicCookie) | not(windowStatOpen) then goto sortie;
			          
			          if StatistiquesSontEcritesDansLaFenetreNormale() then 
		               begin
		                 SetPortByWindow(wStatPtr);
		                 if gCassioUseQuartzAntialiasing then EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),true);
		               end;
		               
		            NumToString(nbPartiestotal,s);
			          s := SeparerLesChiffresParTrois(s);
			          largeurTotalString := Max(StringWidth(s),22);
			          
			          autreCoupQuatreDansPartie := false;
			          if nbreCoup>=3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
			          for compteur := 1 to statistiques^^.nbreponsesTrouvees do
			           begin       
			             if (magicCookie<>oldMagicCookie) | not(windowStatOpen) then goto sortie;
			             if (TickCount()<>dernierTickPourCheckEventDansCalculsBase) & withCheckEvent then CheckEventPendantCalculsBase;
				           if (magicCookie<>oldMagicCookie) | not(windowStatOpen) then goto sortie;
			             
			             if StatistiquesSontEcritesDansLaFenetreNormale() then 
			               begin
			                 SetPortByWindow(wStatPtr);
			                 if gCassioUseQuartzAntialiasing then EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),false);
			               end;
			               
			             yposition := yposition+hauteurChaqueLigneStatistique;
			             SetRect(lignerect,DecH,yposition-8,QDGetPortBound().right,yposition+2);
			             
			             coup := ord(statistiques^^.table[compteur].coup);
			             TransposeCoupPourOrientation(coup,autreCoupQuatreDansPartie);
			             s := CoupEnString(coup,CassioUtiliseDesMajuscules);
			             
			             if avecEffacement then EraseRect(lignerect);
			             if not(gameOver) then
			               begin
			                 Moveto(xPositionCoup,yposition);
			                 DrawString(s);
			               end;
			             
			             
			             nbpartiessurcecoup := statistiques^^.table[compteur].nbpartiessurcecoup;
			             NumToString(nbpartiessurcecoup,s);
			             s := SeparerLesChiffresParTrois(s);
			             Moveto(xPositionNombreParties + largeurTotalString - StringWidth(s),yposition);
			             DrawString(s);
			             
			             
			             pourcentage := 50*(statistiques^^.table[compteur].gainNoirReel/nbpartiessurcecoup);
			             s := ReelEnStringRapide(pourcentage);
			             if pourcentage>50.0 
			               then 
			                 begin
			                   Moveto(xPositionPourcentageNoirR-3,yposition);
			                   TextFace(bold) 
			                 end
			               else 
			                 begin
			                   Moveto(xPositionPourcentageNoirR,yposition);
			                   TextFace(normal);
			                 end;
			             DrawString(s);
			             
			             pourcentage := 100-pourcentage;
			             s := ReelEnStringRapide(pourcentage);
			             if pourcentage>50.0 
			               then 
			                 begin
			                   Moveto(xPositionPourcentageBlancR-3,yposition);
			                   TextFace(bold) 
			                 end
			               else 
			                 begin
			                   Moveto(xPositionPourcentageBlancR,yposition);
			                   TextFace(normal);
			                 end;
			             DrawString(s);
			             
			             pourcentage := 50*(statistiques^^.table[compteur].gainNoirTheorique/nbpartiessurcecoup);
			             s := ReelEnStringRapide(pourcentage);
			             if pourcentage>50.0 
			               then 
			                 begin
			                   Moveto(xPositionPourcentageNoirT-3,yposition);
			                   TextFace(bold) 
			                 end
			               else 
			                 begin
			                   Moveto(xPositionPourcentageNoirT,yposition);
			                   TextFace(normal);
			                 end;
			             DrawString(s);
			             
			             pourcentage := 100-pourcentage;
			             s := ReelEnStringRapide(pourcentage);
			             if pourcentage>50.0 
			               then 
			                 begin
			                   Moveto(xPositionPourcentageBlancT-3,yposition);
			                   TextFace(bold) 
			                 end
			               else 
			                 begin
			                   Moveto(xPositionPourcentageBlancT,yposition);
			                   TextFace(normal);
			                 end;
			             DrawString(s);

			             TextFace(normal);
			           end; 
			           
			         if avecEffacement then 
			           with QDGetPortBound() do
			           begin
			             SetRect(lignerect,DecH,yposition+2,right,bottom-15);
			             EraseRect(lignerect);
			             SetRect(lignerect,DecH,Max(bottom-15,yposition+2),right-15,bottom);
			             EraseRect(lignerect);
			           end;
			                  
			         PenPat(grayPattern);
			         Moveto(DecH,yposition+3);
			         Lineto(500,yposition+3);
			         
			         yposition := yposition+14;
			         Moveto(xPositionCoup,yposition);
			         GetIndString(s,TextesStatistiquesID,9);
			         DrawString(s);
			         NumToString(nbPartiestotal,s);
			         s := SeparerLesChiffresParTrois(s);
			         Moveto(xPositionNombreParties + largeurTotalString - StringWidth(s),yposition);
			         DrawString(s);
			         
			         pourcentage := 50*(statistiques^^.GainNoirTotalReel/nbPartiestotal);
			         s := ReelEnStringRapide(pourcentage);
			         if pourcentage>50.0 
	               then 
	                 begin
	                   Moveto(xPositionPourcentageNoirR-3,yposition);
	                   TextFace(bold) 
	                 end
	               else 
	                 begin
	                   Moveto(xPositionPourcentageNoirR,yposition);
	                   TextFace(normal);
	                 end;
			         DrawString(s);
			         
			         pourcentage := 100-pourcentage;
			         s := ReelEnStringRapide(pourcentage);
			         if pourcentage>50.0 
	               then 
	                 begin
	                   Moveto(xPositionPourcentageBlancR-3,yposition);
	                   TextFace(bold) 
	                 end
	               else 
	                 begin
	                   Moveto(xPositionPourcentageBlancR,yposition);
	                   TextFace(normal);
	                 end;
			         DrawString(s);
			         
			         pourcentage := 50*(statistiques^^.GainNoirTotalTheorique/nbPartiestotal);
			         s := ReelEnStringRapide(pourcentage);
			         if pourcentage>50.0 
	               then 
	                 begin
	                   Moveto(xPositionPourcentageNoirT-3,yposition);
	                   TextFace(bold) 
	                 end
	               else 
	                 begin
	                   Moveto(xPositionPourcentageNoirT,yposition);
	                   TextFace(normal);
	                 end;
			         DrawString(s);
			         
			         pourcentage := 100-pourcentage;
			         s := ReelEnStringRapide(pourcentage);
			         if pourcentage>50.0 
	               then 
	                 begin
	                   Moveto(xPositionPourcentageBlancT-3,yposition);
	                   TextFace(bold) 
	                 end
	               else 
	                 begin
	                   Moveto(xPositionPourcentageBlancT,yposition);
	                   TextFace(normal);
	                 end;
			         DrawString(s);
			         if StatistiquesSontEcritesDansLaFenetreNormale() &
			            avecEffacement & (yposition >= QDGetPortBound().bottom-15)
			           then DessineBoiteDeTaille(wStatPtr);
			         
			         
			         {
			         Moveto(100,yposition+12);
			         temps := statistiques^^.tempsdeCalcul;
			         NumToString(temps,s);
			         DrawString('temps : '+s);
			         }
			       end;
		    end; {with DemandeCalculsPourBase do}
		    
		    
		  
		  
		  sortie :
		    {WritelnStringAndNumDansRapport('<-- DessineStatistiques : ',oldMagicCookie);}
		    
		  if StatistiquesSontEcritesDansLaFenetreNormale() 
		    then SetPort(oldport);
	  END;
end;

procedure EcritStatistiques(withCheckEvent : boolean);
var oldport : grafPtr;
    unRect : rect;
begin
 if windowStatOpen then
  begin
    GetPort(oldport);
    SetPortByWindow(wStatPtr);
    DessineStatistiques(true,0,0,withCheckEvent);
    unRect := GetWindowPortRect(wStatPtr);
    unRect.top := unRect.top+hauteurRubanStatistiques+1;
    ValidRect(unRect);
    SetPort(oldport);
  end;
end;

procedure CheckEventPendantCalculsBase;
var myEvent : eventRecord;
begin
  if not(debuggage.MacOSX) then
    begin
		  dernierTickPourCheckEventDansCalculsBase := TickCount();
		  if HasGotEvent(mDownMask+KeyDownMask+AutoKeyMask,myEvent,0,NIL) then
		    begin
		      theEvent := myEvent;
		      TraiteEvenements;
		    end;
		  dernierTickPourCheckEventDansCalculsBase := TickCount();
	  end;
end;




procedure DessineRubanStatistiques(decH,decV : SInt16);
var yPosition : SInt16; 
    xPositionCoup,xPositionNombreParties,xPositionPourcentageNoirR : SInt16; 
    xPositionPourcentageBlancR,xPositionPourcentageNoirT,xPositionPourcentageBlancT : SInt16; 
    s : str255;
    oldport : grafPtr;
    rubanRect : rect;
begin
  if windowStatOpen then
    begin
      if StatistiquesSontEcritesDansLaFenetreNormale() then
        begin
          GetPort(oldPort);
          SetPortByWindow(wStatPtr);
        end;
      
        
		  xPositionCoup := DecH+10;
		  xPositionNombreParties := DecH+40;
		  xPositionPourcentageNoirR := DecH+100;
		  xPositionPourcentageBlancR := DecH+134;
		  xPositionPourcentageNoirT := DecH+183;
		  xPositionPourcentageBlancT := DecH+217;

      rubanRect := MakeRect(-2,-2,500,DecV+23);
      if gCassioUseQuartzAntialiasing & StatistiquesSontEcritesDansLaFenetreNormale() then
        begin
          EraseRect(rubanRect);
          EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),false);
        end;
        
      if StatistiquesSontEcritesDansLaFenetreNormale() then
        if DrawThemeWindowListViewHeader(rubanRect,kThemeStateActive) = NoErr then;
        
		  TextMode(srcOr);
		  TextFont(gCassioApplicationFont);
		  TextFace(normal); 
		  TextSize(gCassioSmallFontSize);
		  
		  
		  TextFace(bold);
		  yposition := DecV+10;
		  Moveto(xPositionCoup-4,yposition);
		  GetIndString(s,TextesStatistiquesID,1);
		  DrawString(s);
		  Moveto(xPositionPourcentageNoirR+10,yposition);
		  GetIndString(s,TextesStatistiquesID,2);
		  DrawString(s);
		  Moveto(xPositionPourcentageNoirT+5,yposition);
		  GetIndString(s,TextesStatistiquesID,3);
		  DrawString(s);
		  
		  if gCassioUseQuartzAntialiasing & StatistiquesSontEcritesDansLaFenetreNormale()
        then EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),true);
        
		  TextFace(normal); 
		  yposition := yposition+11;
		  Moveto(xPositionCoup-4,yposition);
		  GetIndString(s,TextesStatistiquesID,4);
		  DrawString(s);
		  Moveto(xPositionNombreParties,yposition);
		  GetIndString(s,TextesStatistiquesID,5);
		  DrawString(s);
		  Moveto(xPositionPourcentageNoirR-6,yposition);
		  GetIndString(s,TextesStatistiquesID,6);
		  DrawString(s);
		  Moveto(xPositionPourcentageNoirT-6,yposition);
		  DrawString(s);
		  Moveto(xPositionPourcentageBlancR-3,yposition);
		  GetIndString(s,TextesStatistiquesID,7);
		  DrawString(s);
		  Moveto(xPositionPourcentageBlancT-3,yposition);
		  DrawString(s);
		  PenPat(blackPattern);
		  Moveto(0,yposition+2);
		  Lineto(500,yposition+2);
		  
		  if gCassioUseQuartzAntialiasing & StatistiquesSontEcritesDansLaFenetreNormale() then
        EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),false);
        
      if StatistiquesSontEcritesDansLaFenetreNormale()
		    then SetPort(oldport);
		 end;
end;


procedure EcritRubanStatistiques;
var oldport : grafPtr;
begin
  if windowStatOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wStatPtr);
      SetStatistiquesSontEcritesDansLaFenetreNormale(true);
      DessineRubanStatistiques(0,0);
      SetPort(oldport);
    end;
end;

end.