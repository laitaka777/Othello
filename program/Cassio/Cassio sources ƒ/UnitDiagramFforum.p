UNIT UnitDiagramFforum;




INTERFACE







	USES
		UnitOth0;


	function DoDiagrammeFFORUM(ParametreTexte: str255; const chainePositionInitiale,chainePosition,chaineCoups : str255): boolean;
	function LargeurDiagrammeFFORUM() : SInt16; 
	function HauteurDiagrammeFFORUM() : SInt16; 
	function LargeurTexteSousDiagrammeFFORUM() : SInt16; 
	function HauteurTexteDansDiagrammeFFORUM() : SInt16; 
	function BlancAGaucheDiagrammeFFORUM() : SInt16; 
  function BlancADroiteDiagrammeFFORUM() : SInt16; 
	function QuickdrawColorToDiagramFforumColor(qdColor : SInt16) : SInt16; 
	function DiagramFforumColorToRGBColor(diagramForumColor : SInt16) : RGBColor;
	function QuickDrawColorToRGBColor(qdColor : SInt16) : RGBColor;
	function DoitGenererPostScriptCompatibleXPress() : boolean; 
	procedure SetValeursParDefautDiagFFORUM(var paramDiag: ParamDiagRec; typeDiagramme : SInt16);
	procedure SetValeursRevueAnglaise(var paramDiag: ParamDiagRec; typeDiagramme : SInt16);
	procedure ConstruitOthellierPicture;
	procedure ConstruitPositionPicture(chainePosition,chaineCoups : str255);
	procedure ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups : str255);
	procedure ConstruitPicturePionsDeltaCourants;
	function CopierPICTDansPressePapier(myPicture: PicHandle): OSErr;
	procedure CopierEnMacDraw;
	procedure CopierPucesNumerotees;
	procedure ConstruitPositionEtCoupDapresPartie(var PositionEtCoupStr: str185);
	procedure ConstruitPositionEtCoupPositionInitiale(var PositionEtCoupStr: str185);
	procedure ParserPositionEtCoupsOthello8x8(PositionEtCoupStr:str185; var chainePositionInitiale,chaineCoups : str255);
	function NbreCoupsDansChaineCoups(chaineCoups : str255) : SInt16; 
	function ConstruitChainePosition8x8(plat : plateauOthello) : str255;
  
  procedure SetTailleOthelloPourDiagrammeFForum(nbCasesH,nbCasesV : SInt16);
  procedure GetTailleOthelloPourDiagrammeFforum(var nbCasesH,nbCasesV : SInt16);
  

IMPLEMENTATION







  USES UnitPressePapier,UnitCarbonisation,UnitArbreDeJeuCourant,UnitOth2, UnitPierresDelta, UnitPostScript,
       UnitCouleur,UnitOth1,UnitJaponais,MyStrings,UnitDialog,SNStrings,UnitProblemeDePriseDeCoin,
       UnitFenetres,UnitJeu;


  var tailleVersionOthello : Point;
 

	procedure ConstruitPositionEtCoupDapresPartie(var PositionEtCoupStr: str185);
		var
			t : SInt16; 
			positionInitiale: plateauOthello;
			numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
	begin
		PositionEtCoupStr := '';
		GetPositionInitialeOfGameTree(positionInitiale, numeroPremierCoup, traitInitial,nbBlancsInitial,nbNoirsInitial);
		for t := 1 to 64 do
			case positionInitiale[othellier[t]] of
				pionNoir: 
					PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf('X'));
				pionBlanc: 
					PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf('O'));
				otherwise
					PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf('.'));
			end;
		for t := 1 to nbreCoup do
			begin
				case partie^^[t].trait of
					pionNoir: 
						PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf('N'));
					pionBlanc: 
						PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf('B'));
					otherwise
						PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf(' '));
				end;
				PositionEtCoupStr := Concat(PositionEtCoupStr, chr(GetNiemeCoupPartieCourante(t)));
			end;
		for t := nbreCoup + 1 to 60 do
			begin
				PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf(' '));
				PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf(' '));
			end;
	end;

	procedure ConstruitPositionEtCoupPositionInitiale(var PositionEtCoupStr: str185);
		var
			t : SInt16; 
			positionInitiale: plateauOthello;
			numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
	begin
		PositionEtCoupStr := '';
		GetPositionInitialeOfGameTree(positionInitiale, numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
		for t := 1 to 64 do
			case positionInitiale[othellier[t]] of
				pionNoir: 
					PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf('X'));
				pionBlanc: 
					PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf('O'));
				otherwise
					PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf('.'));
			end;
		for t := 1 to 60 do
			begin
				PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf(' '));
				PositionEtCoupStr := Concat(PositionEtCoupStr, StringOf(' '));
			end;
	end;
	

	procedure ParserPositionEtCoupsOthello8x8(PositionEtCoupStr:str185; var chainePositionInitiale,chaineCoups : str255);
	var t,aux,i,j : SInt16; 
	    plat : plateauOthello;
	begin
	  
	  chainePositionInitiale := TPCopy(PositionEtCoupStr,1,64);
	  {on traduit la chaine de la position initiale pour qu'elle soit ligne par ligne}
	  for t := 0 to 99 do
	    plat[t] := pionVide;
	  for t := 1 to 64 do
	    if chainePositionInitiale[t] <> '.' then
	      begin
	        aux := othellier[t];
	        if (chainePositionInitiale[t] = 'X') then plat[aux] := pionNoir else
	        if (chainePositionInitiale[t] = 'O') | 
	           (chainePositionInitiale[t] = '0') then plat[aux] := pionBlanc;
	      end;
	  chainePositionInitiale := '';
	  for i := 1 to 8 do
	    for j := 1 to 8 do
	      begin
	        case plat[10*i+j] of
	          pionNoir  : chainePositionInitiale := Concat(chainePositionInitiale, StringOf('X'));
	          pionBlanc : chainePositionInitiale := Concat(chainePositionInitiale, StringOf('O'));
	          otherwise   chainePositionInitiale := Concat(chainePositionInitiale, StringOf('.'));
	        end;
	      end;
	  
	  chaineCoups := '';
	  chaineCoups := TPCopy(PositionEtCoupStr,65,120);
	  {et on traduit la chaine des coups pour qu'ils soient dans l'intervale 1..100}
	  {NB : 0 represente toujours le coup impossible}
	  for t := 1 to (Length(chaineCoups) div 2) do
	    begin
	      aux := ord(chaineCoups[2*t]);
	      if aux <> 0 then
	        begin
			      i := platMod10[aux];
			      j := platDiv10[aux];
			      chaineCoups[2*t] := chr(1 + (j-1)*10 + (i-1));
			    end;
	    end;
	  
	end;
	
	
	function ConstruitChainePosition8x8(plat : plateauOthello) : str255;
	var i,j : SInt16; 
	    result : str255;
	begin
	  result := '';
	  for i := 1 to 8 do
	    for j := 1 to 8 do
	      case plat[i*10+j] of
	        pionNoir  : result := Concat(result, StringOf('X'));
	        pionBlanc : result := Concat(result, StringOf('O'));
	        otherwise   result := Concat(result, StringOf('.'));
	      end; {case}
	  ConstruitChainePosition8x8 := result;
	end;
	
function NbreCoupsDansChaineCoups(chaineCoups : str255) : SInt16; 
	var i,n,len : SInt16; 
	begin
	  n := 0;
	  len := Length(chaineCoups);
	  for i := 1 to 126 do
	    if (2*i <= len) & 
	       ((chaineCoups[2*i-1] = 'N') | (chaineCoups[2*i-1] = 'B'))
	      then n := i;
	  NbreCoupsDansChaineCoups := n;
	end;


function QuickdrawColorToDiagramFforumColor(qdColor : SInt16) : SInt16; 
	begin
		QuickdrawColorToDiagramFforumColor := kCouleurDiagramTransparent;
		case qdColor of
			whiteColor: 
				QuickdrawColorToDiagramFforumColor := kCouleurDiagramBlanc;
			GreenColor: 
				QuickdrawColorToDiagramFforumColor := kCouleurDiagramVert;
			BlueColor: 
				QuickdrawColorToDiagramFforumColor := kCouleurDiagramBleu;
			CyanColor: 
				QuickdrawColorToDiagramFforumColor := kCouleurDiagramCyan;
			MagentaColor: 
				QuickdrawColorToDiagramFforumColor := kCouleurDiagramMagenta;
			RedColor: 
				QuickdrawColorToDiagramFforumColor := kCouleurDiagramRouge;
			YellowColor: 
				QuickdrawColorToDiagramFforumColor := kCouleurDiagramJaune;
			BlackColor: 
				QuickdrawColorToDiagramFforumColor := kCouleurDiagramNoir;
		end;
	end;
	
	
function DiagramFforumColorToRGBColor(diagramForumColor : SInt16) : RGBColor;
begin
	case diagramForumColor of
	  kCouleurDiagramTransparent : DiagramFforumColorToRGBColor := gPurBlanc ;
	  kCouleurDiagramBlanc       : DiagramFforumColorToRGBColor := gPurBlanc ;
	  kCouleurDiagramVert        : DiagramFforumColorToRGBColor := gPurVert ;
	  kCouleurDiagramBleu        : DiagramFforumColorToRGBColor := gPurBleu ;
	  kCouleurDiagramCyan        : DiagramFforumColorToRGBColor := gPurCyan ;
	  kCouleurDiagramMagenta     : DiagramFforumColorToRGBColor := gPurMagenta ;
	  kCouleurDiagramRouge       : DiagramFforumColorToRGBColor := gPurRouge ;
	  kCouleurDiagramJaune       : DiagramFforumColorToRGBColor := gPurJaune ;
	  kCouleurDiagramNoir        : DiagramFforumColorToRGBColor := gPurNoir ;
	end;
end;


function QuickDrawColorToRGBColor(qdColor : SInt16) : RGBColor;
begin
  QuickDrawColorToRGBColor := DiagramFforumColorToRGBColor(QuickdrawColorToDiagramFforumColor(qdColor));
end;



function DoitGenererPostScriptCompatibleXPress() : boolean;
begin
  DoitGenererPostScriptCompatibleXPress := PostscriptCompatibleXPress;
end;


procedure SetValeursParDefautDiagFFORUM(var paramDiag: ParamDiagRec; typeDiagramme : SInt16);
	begin
		with ParamDiag do
			begin
				TypeDiagrammeFFORUM := typeDiagramme;
				DecalageHorFFORUM := 0;
				DecalageVertFFORUM := 0;
				tailleCaseFFORUM := 16;
				epaisseurCadreFFORUM := 1.4;
				distanceCadreFFORUM := 1;
				if typeDiagramme = DiagrammePosition then
					begin
						PionsEnDedansFFORUM := true;
						nbPixelDedansFFORUM := 2;
						FondOthellierPatternFFORUM := kBlackPattern;
						couleurOthellierFFORUM := kCouleurDiagramBlanc {was kCouleurDiagramTransparent};
					end
				else
					begin
						PionsEnDedansFFORUM := false;
						nbPixelDedansFFORUM := 1;
						FondOthellierPatternFFORUM := kBlackPattern;
						couleurOthellierFFORUM := kCouleurDiagramBlanc {was kCouleurDiagramTransparent};
					end;
				DessineCoinsDuCarreFFORUM := true;
				DessinePierresDeltaFFORUM := true;
				EcritApres37c7FFORUM := true;
				EcritNomTournoiFFORUM := true;
				EcritNomsJoueursFFORUM := true;
				PoliceFFORUMID := 2;      {New York}
				CoordonneesFFORUM := true;
				NumerosSeulementFFORUM := false;
				TraitsFinsFFORUM := true;
			end;
	end;

	procedure SetValeursRevueAnglaise(var paramDiag: ParamDiagRec; typeDiagramme : SInt16);
		var
			str: str255;
	begin
		with paramDiag do
			begin
				TypeDiagrammeFFORUM := typeDiagramme;
				DecalageHorFFORUM := 0;
				DecalageVertFFORUM := 0;
				epaisseurCadreFFORUM := 0.0;
				distanceCadreFFORUM := 0;
				if typeDiagramme = DiagrammePosition then
					begin
						PionsEnDedansFFORUM := true;
						nbPixelDedansFFORUM := 2;
					end
				else
					begin
						PionsEnDedansFFORUM := true;
						nbPixelDedansFFORUM := 2;
					end;
				DessineCoinsDuCarreFFORUM := false;
				DessinePierresDeltaFFORUM := true;
				EcritApres37c7FFORUM := false;
				if (CommentPositionFFORUM^^ = '') & (nbreCoup >= 1) then
					if DerniereCaseJouee() <> coupInconnu then
						begin
							NumToString(nbreCoup, str);
							str := 'After ' + str + CHR(96 + platmod10[DerniereCaseJouee()]) + CHR(48 + platdiv10[DerniereCaseJouee()]) + StringOf('.');
							CommentPositionFFORUM^^ := str;
						end;
				EcritNomTournoiFFORUM := true;
				EcritNomsJoueursFFORUM := true;
				PoliceFFORUMID := 2;      {New York}
				CoordonneesFFORUM := false;
				NumerosSeulementFFORUM := true;
				TraitsFinsFFORUM := true;
				FondOthellierPatternFFORUM := kBlackPattern;
				couleurOthellierFFORUM := kCouleurDiagramBlanc {was kCouleurDiagramTransparent};
			end;
	end;




	procedure TranslatePourPostScript(decX,decY : extended);
	begin
		SendPostscript(Concat(ReelEnString(decX), ' ', ReelEnString(decY), ' translate'));
	end;

	procedure UnTranslatePourPostScript(decX,decY : extended);
	begin
		SendPostscript(Concat(ReelEnString(-decX), ' ', ReelEnString(-decY), ' translate'));
	end;


	procedure SetLineThin;
	begin
		SetLineWidthPostscript(2, 5);
	end;

	procedure SetLineThick;
	begin
		SetLineWidthPostscript(5, 2);
		SetLineWidthPostscript(1, 1);
	end;



	procedure CalculeDecalagesDiagrammeFFORUM(var decalageH, decalageV : SInt16);
	var decalagePourLeCadre : SInt16; 
	    largeurTexteSousLeDiagramme : SInt16; 
	    largeurDiagrammeProjetee : SInt16; 
	begin
	  DisableQuartzAntiAliasing;
		with ParamDiagCourant do
			begin
			  decalagePourLeCadre := RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM;
				decalageH := decalagePourLeCadre + BlancAGaucheDiagrammeFFORUM();
				if typeDiagrammeFFORUM = DiagrammePourListe then
					decalageH := decalageH + 9;
					
			  largeurTexteSousLeDiagramme := LargeurTexteSousDiagrammeFFORUM();
			  largeurDiagrammeProjetee := (decalageH + TaillecaseFFORUM * tailleVersionOthello.h + decalagePourLeCadre + BlancADroiteDiagrammeFFORUM());
			  
			  if (largeurTexteSousLeDiagramme > largeurDiagrammeProjetee) & (typeDiagrammeFFORUM <> DiagrammePourListe)
			    then decalageH := decalageH + (largeurTexteSousLeDiagramme-largeurDiagrammeProjetee) div 2;
					

				if CoordonneesFFORUM then
					decalageV := RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + RoundToL(5.5 * TaillecaseFFORUM / 8.0)
				else
					decalageV := RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM;
				if (typeDiagrammeFFORUM = DiagrammePourListe) & EcritNomTournoiFFORUM then
					decalageV := decalageV + (3 * TaillecaseFFORUM) div 4;
			end;  {with}
	  EnableQuartzAntiAliasing(true);
	end;

	function LargeurDiagrammeFFORUM() : SInt16; 
		var
			decalageH, decalageV : SInt16; 
			largeurTexteSousLeDiagramme : SInt16; 
	    largeurDiagrammeProjetee : SInt16; 
	begin
	  DisableQuartzAntiAliasing;
		CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);
		with ParamDiagCourant do
		  begin
		    largeurDiagrammeProjetee := TaillecaseFFORUM * tailleVersionOthello.h + decalageH + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + BlancADroiteDiagrammeFFORUM();
		    largeurTexteSousLeDiagramme := LargeurTexteSousDiagrammeFFORUM();
		    
		    if (typeDiagrammeFFORUM = DiagrammePourListe)
		      then LargeurDiagrammeFFORUM := largeurDiagrammeProjetee
		      else LargeurDiagrammeFFORUM := Max(largeurDiagrammeProjetee,largeurTexteSousLeDiagramme);
			end;
	  EnableQuartzAntiAliasing(true);
	end;
	
  function BlancAGaucheDiagrammeFFORUM() : SInt16; 
  begin
    with ParamDiagCourant do
      if CoordonneesFFORUM 
        then BlancAGaucheDiagrammeFFORUM := (3 * TaillecaseFFORUM) div 4
        else BlancAGaucheDiagrammeFFORUM := 0;
  end;
  
  function BlancADroiteDiagrammeFFORUM() : SInt16; 
  begin
    BlancADroiteDiagrammeFFORUM := 2;
  end;


	function HauteurDiagrammeFFORUM() : SInt16; 
		var
			decalageH, decalageV : SInt16; 
	begin
		CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);
		with ParamDiagCourant do
			HauteurDiagrammeFFORUM := RoundToL(TaillecaseFFORUM * (1.0*tailleVersionOthello.v + 0.85)) + decalageV + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + 1;
	end;
	
	
	function LargeurTexteSousDiagrammeFFORUM() : SInt16; 
	  var 
	    str,str1 : str255;
	    aux,larg,larg1 : SInt16; 
	begin 
	  DisableQuartzAntiAliasing;
	  DisableQuartzAntiAliasingThisPort(qdThePort());
	  with ParamDiagCourant do
	    begin
			  str := '';
				str1 := '';
				larg := 0;
				larg1 := 0;
				
				case typeDiagrammeFFORUM of
					DiagrammePartie: 
						str := titreFForum^^;
					DiagrammePosition: 
						begin
						  if EcritApres37c7FFORUM then
								begin
									GetIndString(str, TextesImpressionID, 3);   {'Après ^0'}
									str := ParamStr(str, '', '', '', '');
									str := str + '\b37.c7';     {attention : ceci n'est qu'une approximation !}
								end
							else if CommentPositionFForum^^ <> '' then
								begin
									str := CommentPositionFForum^^;
								end;
						end;
					DiagrammePourListe: 
						if EcritNomsJoueursFFORUM then 
						  str := titreFForum^^;
				end;

	
				aux := Pos('\b', str);
				if aux > 0 then
					begin
						str1 := TPCopy(str, aux + 2, Length(str) - aux - 1);
						str := TPCopy(str, 1, aux - 1);
					end;						
						
						
						
				if (str <> '') | (str1 <> '') 
				  then
						begin
							TextFont(PoliceFForumID);
							TextSize(HauteurTexteDansDiagrammeFFORUM());
							TextMode(1);
							TextFace(normal);
							
							larg := StringWidth(str);
							TextFace(bold);
							larg1 := StringWidth(str1);
							
						end;
				LargeurTexteSousDiagrammeFFORUM := larg + larg1;
			end;
	  DisableQuartzAntiAliasingThisPort(qdThePort());
	  EnableQuartzAntiAliasing(true);
	end;
	
	function HauteurTexteDansDiagrammeFFORUM() : SInt16; 
	begin
	  with ParamDiagCourant do
	    HauteurTexteDansDiagrammeFFORUM := TaillecaseFFORUM div 2 + 1;
	end;

	procedure ConstruitRectangleTaillePicture;
		var
			unRect: rect;
	begin
		with ParamDiagCourant do
			SetRect(unRect, decalageHorFFORUM, decalageVertFFORUM, decalageHorFFORUM + LargeurDiagrammeFFORUM(), decalageVertFFORUM + HauteurDiagrammeFFORUM());
		PenPat(grayPattern);
		FrameRect(unRect);
		PenPat(blackPattern);
	end;

	procedure ConstruitOthellierPicture;
		var
			unRect: rect;
			i, a, b, aux  : SInt16; 
			bordExtr : Point;
			haut, diff, fontsize : SInt16; 
			decalageH, decalageV : SInt16; 
			InfosPolice: fontInfo;
			s : str255;
			theForeColor : RGBColor;
	begin
	  DisableQuartzAntiAliasingThisPort(qdThePort());
		with ParamDiagCourant do
			begin
				haut := HauteurTexteDansDiagrammeFFORUM();
				diff := TaillecaseFFORUM div 4;
				CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);


				PenSize(1, 1);
				PenPat(blackPattern);
				TextFont(PoliceFForumID);
				TextSize(haut);
				fontsize := haut;
				GetFontInfo(InfosPolice);
				TextMode(1);
				TextFace(normal);

				if PionsEnDedansFFORUM & odd(nbPixelDedansFFORUM) & TraitsFinsFFORUM then
					TranslatePourPostScript(0.5, 0.5);

				if epaisseurCadreFFORUM > 0.0 then
					begin
						SetRect(unRect, decalageHorFFORUM  + decalageH - RoundToL(epaisseurCadreFFORUM) - distanceCadreFFORUM, 
						                decalageVertFFORUM + decalageV - RoundToL(epaisseurCadreFFORUM) - distanceCadreFFORUM, 
						                decalageHorFFORUM  + decalageH + tailleVersionOthello.h * TaillecaseFFORUM + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + 1, 
						                decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + 1);
						if TraitsFinsFFORUM then
							begin
								SetLineWidthPostscript(RoundToL(epaisseurCadreFFORUM * 100.0), 100);
								FrameRect(unRect);
								SetLineWidthPostscript(100, RoundToL(epaisseurCadreFFORUM * 100.0));
                  {on cache le dessin quickdraw a PostScript}
								BeginPostScript;
								PenSize(RoundToL(epaisseurCadreFFORUM), RoundToL(epaisseurCadreFFORUM));
								FrameRect(unRect);
								EndPostScript;
							end
						else
							begin
								PenSize(RoundToL(epaisseurCadreFFORUM), RoundToL(epaisseurCadreFFORUM));
								FrameRect(unRect);
							end;
					end;

				SetRect(unRect, decalageHorFFORUM  + decalageH, 
				                decalageVertFFORUM + decalageV, 
				                decalageHorFFORUM  + decalageH + tailleVersionOthello.h * TaillecaseFFORUM + 1, 
				                decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM + 1);


				if (couleurOthellierFFORUM <> kCouleurDiagramTransparent) & (FondOthellierPatternFFORUM <> kTranslucidPattern) then
					begin
						case couleurOthellierFFORUM of
							kCouleurDiagramTransparent: 
								;
							kCouleurDiagramBlanc: 
								ForeColor(whiteColor);
							kCouleurDiagramVert: 
								ForeColor(GreenColor);
							kCouleurDiagramBleu: 
								ForeColor(BlueColor);
							kCouleurDiagramCyan: 
								ForeColor(CyanColor);
							kCouleurDiagramMagenta: 
								ForeColor(MagentaColor);
							kCouleurDiagramRouge: 
								ForeColor(RedColor);
							kCouleurDiagramJaune: 
								ForeColor(YellowColor);
							kCouleurDiagramNoir: 
								ForeColor(BlackColor);
						end;
						
						GetForeColor(theForeColor);
						case FondOthellierPatternFFORUM of
							kTranslucidPattern: 
								;
							kWhitePattern: 
								  FillRect(unRect, whitePattern);
							kLightGrayPattern: 
							  begin
							    theForeColor := EclaircirCouleur(theForeColor);
							    theForeColor := EclaircirCouleur(theForeColor);
							    theForeColor := EclaircirCouleur(theForeColor);
							    RGBForeColor(theForeColor);
							    FillRect(unRect, blackPattern);
								  {FillRect(unRect, lightGrayPattern);}
								end;
							kGrayPattern: 
							  begin
							    theForeColor := EclaircirCouleur(theForeColor);
							    theForeColor := EclaircirCouleur(theForeColor);
							    RGBForeColor(theForeColor);
							    FillRect(unRect, blackPattern);
								  {FillRect(unRect, grayPattern);}
								end;
							kDarkGrayPattern: 
							  begin
							    theForeColor := EclaircirCouleur(theForeColor);
							    RGBForeColor(theForeColor);
							    FillRect(unRect, blackPattern);
							    {
								  FillRect(unRect, darkGrayPattern);
								  }
								end;
							kBlackPattern: 
								FillRect(unRect, blackPattern);
						end;
						ForeColor(BlackColor);
					end;


				PenSize(1, 1);
				if TraitsFinsFFORUM then
					SetLineWidthPostscript(1, 3);
				PenSize(1, 1);
				FrameRect(unRect);
				bordExtr.h := tailleVersionOthello.h * TaillecaseFFORUM;
				bordExtr.v := tailleVersionOthello.v * TaillecaseFFORUM;
				for i := 1 to tailleVersionOthello.h-1 do
					begin
						a := i * TaillecaseFFORUM;
						SetRect(unRect, decalageHorFFORUM + decalageH + a, 
						                decalageVertFFORUM + decalageV, 
						                decalageHorFFORUM + decalageH + bordExtr.h + 1, 
						                decalageVertFFORUM + decalageV + bordExtr.v + 1);
						FrameRect(unRect);
					end;
			  for i := 1 to tailleVersionOthello.v-1 do
					begin
						a := i * TaillecaseFFORUM;
						SetRect(unRect, decalageHorFFORUM + decalageH, 
						                decalageVertFFORUM + decalageV + a, 
						                decalageHorFFORUM + decalageH + bordExtr.h + 1, 
						                decalageVertFFORUM + decalageV + bordExtr.v + 1);
						FrameRect(unRect);
					end;


				if TraitsFinsFFORUM then
					begin
						SetLineWidthPostscript(3, 1);
						SetLineWidthPostscript(1, 1);
					end;
				PenSize(1, 1);

				if CoordonneesFFORUM then
					begin
					  {TextMode(srcXor);}
					  for i := 1 to tailleVersionOthello.h do
							begin
								s := chr(96 + i);
								a := i * TaillecaseFFORUM - ((TaillecaseFFORUM + StringWidth(s) -1) div 2);
								Moveto(decalageHorFFORUM + decalageH + a, decalageVertFFORUM + decalageV - tailleCaseFFORUM div 4 + 1 -(distanceCadreFFORUM + RoundToL(epaisseurCadreFFORUM)));
								DrawString(s);  {colonne}
							end;
					  for i := 1 to tailleVersionOthello.v do
							begin
							  s := NumEnString(i);
							  a := decalageHorFFORUM + decalageH - haut - distanceCadreFFORUM - RoundToL(epaisseurCadreFFORUM);
							  if i>=10 then a := a-2;
							  if odd(TaillecaseFFORUM)
							    then b := decalageVertFFORUM + decalageV + i * TaillecaseFFORUM - diff - 1
							    else b := decalageVertFFORUM + decalageV + i * TaillecaseFFORUM - diff;
								{rangee}
								Moveto(a,b);
								if i < 10 
								  then DrawString(s)
								  else 
								    begin
								      DrawChar(s[1]);
								      Move(-1,0);
								      DrawChar(s[2]);
								    end;
								
							end;
					end;
				if DessineCoinsDuCarreFFORUM & (tailleVersionOthello.h >= 4) & (tailleVersionOthello.v >= 4) then
					begin
						if TraitsFinsFFORUM then
							SetLineThin;
						PenSize(1, 1);
						aux := TaillecaseFFORUM div 10;
						if aux = 0 then
							aux := 1;
						a := decalageHorFFORUM + decalageH + 2 * TaillecaseFFORUM;
						b := decalageVertFFORUM + decalageV + 2 * TaillecaseFFORUM;
						SetRect(unRect, a - aux, b - aux, a + aux + 1, b + aux + 1);
						FillOval(unRect, blackPattern);
						a := decalageHorFFORUM + decalageH + 2 * TaillecaseFFORUM;
						b := decalageVertFFORUM + decalageV + (tailleVersionOthello.v-2) * TaillecaseFFORUM;
						SetRect(unRect, a - aux, b - aux, a + aux + 1, b + aux + 1);
						FillOval(unRect, blackPattern);
						a := decalageHorFFORUM + decalageH + (tailleVersionOthello.h-2) * TaillecaseFFORUM;
						b := decalageVertFFORUM + decalageV + 2 * TaillecaseFFORUM;
						SetRect(unRect, a - aux, b - aux, a + aux + 1, b + aux + 1);
						FillOval(unRect, blackPattern);
						a := decalageHorFFORUM + decalageH + (tailleVersionOthello.h-2) * TaillecaseFFORUM;
						b := decalageVertFFORUM + decalageV + (tailleVersionOthello.v-2) * TaillecaseFFORUM;
						SetRect(unRect, a - aux, b - aux, a + aux + 1, b + aux + 1);
						FillOval(unRect, blackPattern);
						if TraitsFinsFFORUM then
							SetLineThick;
						PenSize(1, 1);
					end;

				if PionsEnDedansFFORUM & odd(nbPixelDedansFFORUM) & TraitsFinsFFORUM then
					UnTranslatePourPostScript(0.5, 0.5);
			end;
	  DisableQuartzAntiAliasingThisPort(qdThePort());
	end;

	procedure CalculeRectanglePionEnDedansFFORUM(var PionRect: rect; nbPixelDedansFFORUM : SInt16);
	begin
		if odd(nbPixelDedansFFORUM) then
			begin
				inc(PionRect.left);
				inc(PionRect.top);
			end;
		InsetRect(PionRect, nbPixelDedansFFORUM div 2, nbPixelDedansFFORUM div 2);
	end;

	procedure DessinePionNoirDiagrammeFforum(whichRect: rect);
	begin
		ForeColor(blackColor);
		if not(ParamDiagCourant.TraitsFinsFFORUM) then
			begin
				FillOval(whichRect, blackPattern);
			end
		else
			begin
				FrameOval(whichRect);
				InsetRect(whichRect, 1, 1);
				SetLineWidthPostscript(2, 1);
				FrameOval(whichRect);
				SetLineThin;
				FillOval(whichRect, blackPattern);
			end;
	end;
	
	procedure DessinePionBlancDiagrammeFforum(whichRect: rect);
	begin
		if ParamDiagCourant.couleurOthellierFFORUM <> kCouleurDiagramTransparent then
			begin
				BackColor(whiteColor);
				ForeColor(whiteColor);
				EraseOval(whichRect);
			end;
		ForeColor(blackColor);
		FrameOval(whichRect);
	end;



	procedure ConstruitPositionPicture(chainePosition,chaineCoups : str255);
		var
			unRect: rect;
			i, j, a, b, aux  : SInt16; 
			haut, diff, larg, larg1, fontsize : SInt16; 
			decalageH, decalageV : SInt16; 
			str, str1: str255;
			nbreCoupConstruction : SInt16; 
			nbreCasesPosition : SInt16; 
			InfosPolice: fontInfo;
	begin 
	  DisableQuartzAntiAliasingThisPort(qdThePort());
		with ParamDiagCourant do
			begin
				nbreCoupConstruction := NbreCoupsDansChaineCoups(chaineCoups);
				nbreCasesPosition := Length(chainePosition);
				haut := HauteurTexteDansDiagrammeFFORUM();
				diff := (TaillecaseFFORUM) div 4;
				CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);


				PenSize(1, 1);
				PenPat(blackPattern);
				TextMode(1);
				TextFont(PoliceFForumID);
				TextFace(normal);
				TextSize(haut);
				fontsize := haut;
				GetFontInfo(InfosPolice);

				ConstruitOthellierPicture;

				if TraitsFinsFFORUM then
					SetLineThin;
				PenSize(1, 1);
				aux := 0;
				for i := 1 to tailleVersionOthello.v do
					for j := 1 to tailleVersionOthello.h do
						begin
						  inc(aux);
							if (aux <= nbreCasesPosition) & (chainePosition[aux]<>'.') then
								begin
									a := decalageHorFFORUM + decalageH + j * TaillecaseFFORUM;
									b := decalageVertFFORUM + decalageV + i * TaillecaseFFORUM;
									SetRect(unRect, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
									if PionsEnDedansFFORUM then
										CalculeRectanglePionEnDedansFFORUM(unRect, nbPixelDedansFFORUM);
									if chainePosition[aux]='X' then
									  DessinePionNoirDiagrammeFforum(unRect) else
									if (chainePosition[aux]='O') | (chainePosition[aux]='0') then
										DessinePionBlancDiagrammeFforum(unRect);
								end;
						end;
				if TraitsFinsFFORUM then
					SetLineThick;
				PenSize(1, 1);



     {écriture de la ligne de texte sous le diagramme}
				str := '';
				str1 := '';
				if EcritApres37c7FFORUM then
					begin
						if nbreCoupConstruction >= 1 then
						  begin
						    aux := ord(chaineCoups[2 * nbreCoupConstruction]);
								if aux <> coupInconnu then
									begin
										GetIndString(str, TextesImpressionID, 3);   {'Après ^0'}
										str := ParamStr(str, '', '', '', '');
										NumToString(nbreCoupConstruction, str1);
										str1 := str1 + StringOf('.') + CHR(96 + (platmod10[aux-1]+1)) + CHR(48 + (platdiv10[aux-1]+1));
									end;
						  end;
					end
				else if CommentPositionFForum^^ <> '' then
					begin
						str := CommentPositionFForum^^;
						aux := Pos('\b', str);
						if aux > 0 then
							begin
								str1 := TPCopy(str, aux + 2, Length(str) - aux - 1);
								str := TPCopy(str, 1, aux - 1);
							end;
					end;
			  DisableQuartzAntiAliasing;
				if (str <> '') | (str1 <> '') then
					begin
						TextFont(PoliceFForumID);
						TextSize(haut);
						fontsize := haut;
						GetFontInfo(InfosPolice);
						TextMode(1);
						TextFace(normal);
						larg := StringWidth(str);
						TextFace(bold);
						larg1 := StringWidth(str1);
						if (larg + larg1) <= (tailleVersionOthello.h * TaillecaseFFORUM + RoundToL(2.0*epaisseurCadreFFORUM) + 2*distanceCadreFFORUM)
						  then 
						    {justification au centre de l'othellier}
						    a := decalageHorFFORUM  + decalageH + ((tailleVersionOthello.h * TaillecaseFFORUM) div 2) - (larg + larg1) div 2  
						  else 
						    if (BlancAGaucheDiagrammeFFORUM() > 0) & (BlancADroiteDiagrammeFFORUM() = 2)
						      then 
						        {justification à droite}
						        a := decalageHorFFORUM  + (LargeurDiagrammeFFORUM() - (larg + larg1))
						      else 
						        {justification au centre de toute l'image}
						        a := decalageHorFFORUM  + (LargeurDiagrammeFFORUM() - (larg + larg1)) div 2;
					  DisableQuartzAntiAliasing;
						Moveto(a,decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM + haut + diff - 1 + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM);
						TextFace(normal);
						DrawString(str);
						TextFace(bold);
						DrawString(str1);
					end;
        EnableQuartzAntiAliasing(true);
			end;
	  DisableQuartzAntiAliasingThisPort(qdThePort());
	end;

	procedure ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups : str255);
		var
			unRect: rect;
			i, j, t, a, b, aux  : SInt16; 
			x, y : SInt16; 
			haut, diff, larg, larg1, fontsize : SInt16; 
			decalageH, decalageV, centragevertical : SInt16; 
			str, str1: str255;
			nbreCoupConstruction : SInt16; 
			InfosPolice: fontInfo;
	begin
	  
		nbreCoupConstruction := NbreCoupsDansChaineCoups(chaineCoups);
		
		{
		WritelnDansRapport('chainePositionInitiale = '+chainePositionInitiale);
	  WritelnDansRapport('chaineCoups = '+chaineCoups);
		WritelnStringAndNumDansRapport('nbreCoupConstruction = ',nbreCoupConstruction);
		}
		
		DisableQuartzAntiAliasingThisPort(qdThePort());
		with ParamDiagCourant do
			begin
				haut := HauteurTexteDansDiagrammeFFORUM();
				diff := TaillecaseFFORUM div 4;
				CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);

				PenSize(1, 1);
				PenPat(blackPattern);
				TextFont(PoliceFForumID);
				TextFace(normal);
				TextSize(haut);
				fontsize := haut;
				GetFontInfo(InfosPolice);
				ConstruitOthellierPicture;
				TextFont(PoliceFForumID);

				if TraitsFinsFFORUM then
					SetLineThin;
				PenSize(1,1);
				for j := 1 to tailleVersionOthello.v  do
				  for i := 1 to tailleVersionOthello.h  do
				    begin
				      t := (j-1)*tailleVersionOthello.h + i;
							if chainePositionInitiale[t] <> '.' then
								begin
									a := decalageHorFFORUM + decalageH + i * TaillecaseFFORUM;
									b := decalageVertFFORUM + decalageV + j * TaillecaseFFORUM;
									SetRect(unRect, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
									if PionsEnDedansFFORUM then
										CalculeRectanglePionEnDedansFFORUM(unRect, nbPixelDedansFFORUM);
									if chainePositionInitiale[t] = 'X' then
										DessinePionNoirDiagrammeFforum(unRect) else
									if (chainePositionInitiale[t] = 'O') | (chainePositionInitiale[t] = '0') then
									  DessinePionBlancDiagrammeFforum(unRect);
								end;
						end;
				if TraitsFinsFFORUM then
					SetLineThick;
				PenSize(1, 1);

				TextFont(PoliceFForumID);
				if numerosSeulementFFORUM then
					begin
						fontsize := haut + 1;
						TextSize(fontsize);
						GetFontInfo(InfosPolice);
						centragevertical := (tailleCaseFFORUM - Min(fontsize, InfosPolice.ascent - InfosPolice.leading) + 1) div 2;

						for t := 1 to nbreCoupConstruction do
							begin
								aux := ord(chaineCoups[2 * t]);
								if aux <> coupInconnu then
										begin
											i := platmod10[aux-1] + 1;
											j := platdiv10[aux-1] + 1;
											TextMode(1);
											if t >= 100 
											  then TextFace(condense)
											  else TextFace(normal);
											  
											a := decalageH + i * TaillecaseFFORUM;
											b := decalageV + j * TaillecaseFFORUM;
											if (t >= 10) & (t <= 99) then
												begin
													NumToString(platmod10[t], str);
													NumToString(platdiv10[t], str1);
													larg := StringWidth(str);
													larg1 := StringWidth(str1);
													y := b - centragevertical;
													x := a -(TaillecaseFFORUM + larg + larg1 - 1) div 2;
													Moveto(decalageHorFFORUM + x, decalageVertFFORUM + y);
													DrawString(str1);
													x := a -(TaillecaseFFORUM - larg1 + larg) div 2;
													Moveto(decalageHorFFORUM + x, decalageVertFFORUM + y);
													DrawString(str);
												end
											else
												begin
													NumToString(t, str);
													y := b - centragevertical;
													x := a -(TaillecaseFFORUM + StringWidth(str) - 1) div 2;
													Moveto(decalageHorFFORUM + x, decalageVertFFORUM + y);
													DrawString(str);
												end;
										end;
							end;
					end
				else
					begin
						if PionsEnDedansFFORUM then
							fontsize := haut - (nbPixelDedansFFORUM div 2)
						else
							fontsize := haut;
						TextSize(fontsize);
						GetFontInfo(InfosPolice);
						centragevertical := (tailleCaseFFORUM - Min(fontsize, InfosPolice.ascent - InfosPolice.leading) + 1) div 2;

						if TraitsFinsFFORUM then
							SetLineThin;
						PenSize(1, 1);
						for t := 1 to nbreCoupConstruction do
							begin
								aux := ord(chaineCoups[2 * t]);
								if aux <> coupInconnu then
										begin
											i := platmod10[aux-1] + 1;
											j := platdiv10[aux-1] + 1;
											a := decalageHorFFORUM + decalageH + i * TaillecaseFFORUM;
											b := decalageVertFFORUM + decalageV + j * TaillecaseFFORUM;
											SetRect(unRect, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
											if PionsEnDedansFFORUM then
												CalculeRectanglePionEnDedansFFORUM(unRect, nbPixelDedansFFORUM);
												
											if chaineCoups[2*t - 1] = 'N' then  {pions noirs, avec le numero du coup en blanc}
												begin
													DessinePionNoirDiagrammeFforum(unRect);
                          
                          DisableQuartzAntiAliasing;
                          
													TextMode(3);
													if(PoliceFForumID = 0) & (haut >= 12) then
														TextFace(normal)        {Chicago est deja assez large}
													else
														TextFace(bold);
												  if t >= 100 then TextFace(condense);

													if (t >= 10) & (t <= 99) then
														begin
															NumToString(platmod10[t], str);
															NumToString(platdiv10[t], str1);
															larg := StringWidth(str);
															larg1 := StringWidth(str1);
															y := b - centragevertical;
															x := a - (TaillecaseFFORUM + larg + larg1) div 2 + 2;


															Moveto(x, y);
															PenPat(blackPattern);
															TextMode(3);
                              {DrawString(str1);}

															if TraitsFinsFFORUM then
																DrawTranslatedString(str1, +0.49, 0.0)
															else
																DrawString(str1);

                              
															x := a - (TaillecaseFFORUM - larg1 + larg) div 2;
															Moveto(x, y);
															PenPat(blackPattern);
															TextMode(3);
															DrawString(str);

                            {}
{                            if TraitsFinsFFORUM}
{                              then DrawTranslatedString(str,-0.49,0.0)}
{                              else DrawString(str);}
{                            }


														end
													else
														begin
															NumToString(t, str);
															y := b - centragevertical;
															x := a -(TaillecaseFFORUM + StringWidth(str) - 1) div 2;

															Moveto(x, y);
															PenPat(blackPattern);
															TextMode(3);
															if TraitsFinsFFORUM then
																DrawTranslatedString(str, +0.49, 0.0)
															else
																DrawString(str);

														end;
												  EnableQuartzAntiAliasing(true);
												end
											else if chaineCoups[2*t - 1] = 'B' then   {pions blancs, avec le numero du coup en noir}
												begin
													DessinePionBlancDiagrammeFforum(unRect);
													EnableQuartzAntiAliasing(true);
													TextMode(1);
													if t >= 100 
													  then TextFace(condense)
													  else TextFace(normal);
													if (t >= 10) & (t<=99) then
														begin
															NumToString(platmod10[t], str);
															NumToString(platdiv10[t], str1);
															larg := StringWidth(str);
															larg1 := StringWidth(str1);
															y := b - centragevertical;
															x := a -(TaillecaseFFORUM + larg + larg1 - 1) div 2;
															Moveto(x, y);
															DrawString(str1);
															x := a -(TaillecaseFFORUM - larg1 + larg + 1) div 2;
															Moveto(x, y);
															DrawString(str);
														end
													else
														begin
															NumToString(t, str);
															y := b - centragevertical;
															x := a - (TaillecaseFFORUM + StringWidth(str) + 1) div 2;
															Moveto(x, y);
															if TraitsFinsFFORUM then
																DrawTranslatedString(str, -0.49, 0.0)
															else
																DrawString(str);
														end;
												end;
										end;
							end;
					end;

     {écriture de la ligne de texte sous le diagramme}
        DisableQuartzAntiAliasing;
				str := '';
				str1 := '';
				if (titreFForum^^ <> '') then
					if (typeDiagrammeFFORUM = DiagrammePartie) | 
					   ((typeDiagrammeFFORUM = DiagrammePourListe) & EcritNomsJoueursFFORUM) then
						begin
							str := titreFForum^^;
							aux := Pos('\b', str);
							if aux > 0 then
								begin
									str1 := TPCopy(str, aux + 2, Length(str) - aux - 1);
									str := TPCopy(str, 1, aux - 1);
								end;
						end;
				if (str <> '') | (str1 <> '') then
					begin
						TextFont(PoliceFForumID);
						TextSize(haut);
						fontsize := haut;
						GetFontInfo(InfosPolice);
						TextMode(1);
						TextFace(normal);
						larg := StringWidth(str);
						TextFace(bold);
						larg1 := StringWidth(str1);
						
						
						if (larg + larg1) <= (tailleVersionOthello.h * TaillecaseFFORUM + RoundToL(2.0*epaisseurCadreFFORUM) + 2*distanceCadreFFORUM)
						  then 
						    {justification au centre de l'othellier}
						    a := decalageHorFFORUM  + decalageH + ((tailleVersionOthello.h * TaillecaseFFORUM) div 2) - (larg + larg1) div 2  
						  else 
						    if (BlancAGaucheDiagrammeFFORUM() > 0) & (BlancADroiteDiagrammeFFORUM() = 2)
						      then 
						        {justification à droite}
						        a := decalageHorFFORUM  + (LargeurDiagrammeFFORUM() - (larg + larg1))
						      else 
						        {justification au centre de toute l'image}
						        a := decalageHorFFORUM  + (LargeurDiagrammeFFORUM() - (larg + larg1)) div 2;
						Moveto(a,decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM + haut + diff - 1 + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM);

            DisableQuartzAntiAliasing;
						TextFace(normal);
						DrawString(str);
						TextFace(bold);
						DrawString(str1);
					end;

     {écriture des infos facultatives telles que Gain théorique, tournoi, etc.}
				TextFont(PoliceFForumID);
				TextSize(haut);
				fontsize := haut;
				GetFontInfo(InfosPolice);
				TextMode(1);
				TextFace(normal);
				if typeDiagrammeFFORUM = DiagrammePourListe then
					begin
						Moveto(decalageHorFFORUM  + decalageH + tailleVersionOthello.h * TaillecaseFFORUM + 2 + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM, 
						       decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM - 2);
						DrawString(GainTheoriqueFFORUM);
					end;
				if (CommentPositionFForum^^ <> '') then
					if ((typeDiagrammeFFORUM = DiagrammePourListe) & EcritNomTournoiFFORUM) then
						begin
							str := CommentPositionFForum^^;
							larg := StringWidth(str) div 2;
							Moveto(decalageHorFFORUM + decalageH + (tailleVersionOthello.h div 2) * TaillecaseFFORUM - larg, decalageVertFFORUM + haut + 1);
							DrawString(str);
						end;
			  
			  EnableQuartzAntiAliasing(true);
			end;
	  DisableQuartzAntiAliasingThisPort(qdThePort());
	end;

	function CalculeRectOfSquare2DDiagrammeFforum(quelleCase : SInt16): rect;
		var
			result: rect;
			a, b, i, j, decalageH, decalageV : SInt16; 
	begin
		with ParamDiagCourant do
			begin
				CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);
				i := (quellecase mod 10);
				j := (quellecase div 10);
				a := decalageHorFFORUM + decalageH + i * TaillecaseFFORUM;
				b := decalageVertFFORUM + decalageV + j * TaillecaseFFORUM;
				SetRect(result, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
				if PionsEnDedansFFORUM then
					CalculeRectanglePionEnDedansFFORUM(result, nbPixelDedansFFORUM);
			end;
		CalculeRectOfSquare2DDiagrammeFforum := result;
	end;

	function DoitDecalerRectPourQueLesDeltaSoientCentres(quellecase, genreDeMarqueSpeciale : SInt16): boolean;
		var
			result: rect;
	begin
		result := CalculeRectOfSquare2DDiagrammeFforum(quelleCase);
		if not(odd(result.right - result.left)) & 
		   InPropertyTypes(genreDeMarqueSpeciale,[LosangeWhiteProp, LosangeBlackProp, LosangeProp, DeltaWhiteProp, DeltaBlackProp, DeltaProp, LineProp, ArrowProp]) then
			DoitDecalerRectPourQueLesDeltaSoientCentres := true
		else
			DoitDecalerRectPourQueLesDeltaSoientCentres := false;
	end;


	function GetRectOfSquare2DDiagrammeFforum(quellecase, genreDeMarqueSpeciale : SInt16): rect;
		var
			result: rect;
	begin
		result := CalculeRectOfSquare2DDiagrammeFforum(quelleCase);
		if DoitDecalerRectPourQueLesDeltaSoientCentres(quellecase, genreDeMarqueSpeciale) then
			begin
				dec(result.left);
				dec(result.top);
			end;
		GetRectOfSquare2DDiagrammeFforum := result;
	end;


	function BidonGetRect3DFunc(foo, bar : SInt16): rect;
		var
			result: rect;
	begin
  {$UNUSED foo,bar}
		SetRect(result, 0, 0, 0, 0);
		BidonGetRect3DFunc := result;
	end;


	procedure DessinerPierresDeltaOfPropertyDiagrammeFforum(var prop: property);
		var
			whichSquare, i, j, whichSquare2 : SInt16; 
			RegionMarquee : PackedSquareSet;
	
	    procedure SetEpaisseurTraitEtTranslateCommeNecessaire(genre,square : SInt16);
	      var TraitMoyen,TraitFin,EstUnCercle : boolean;
	      begin
	        if ParamDiagCourant.TraitsFinsFFORUM then
	          begin
			        TraitMoyen  := InPropertyTypes(genre,[CarreWhiteProp, CarreBlackProp, CarreProp, ArrowProp, LineProp]) |
			                      ((genre=MarkedPointsProp) & (jeuCourant[square] = pionNoir));
			        TraitFin   := not(TraitMoyen);
			        EstUnCercle := InPropertyTypes(genre,[PetitCercleWhiteProp, PetitCercleBlackProp, PetitCercleProp]);
			        
			        if TraitMoyen 
			          then
			            begin
			              SetLineWidthPostscript(1, 2);
			              if not(EstUnCercle) then TranslatePourPostScript(0.25, 0.25);
			            end
			          else
			            begin
			              SetLineWidthPostscript(1, 3);
			              if not(EstUnCercle) then TranslatePourPostScript(0.33, 0.33);
			            end;
			        
			        if DoitDecalerRectPourQueLesDeltaSoientCentres(11, genre) 
			          then TranslatePourPostScript(0.5, 0.5);
			      end;
	      end;
	      
	      procedure UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,square : SInt16);
	      var TraitMoyen,TraitFin,EstUnCercle : boolean;
	      begin
	        if ParamDiagCourant.TraitsFinsFFORUM then
	          begin
			        TraitMoyen  := InPropertyTypes(genre,[CarreWhiteProp, CarreBlackProp, CarreProp, ArrowProp, LineProp]) |
			                      ((genre=MarkedPointsProp) &(jeuCourant[square] = pionNoir));
			        TraitFin   := not(TraitMoyen);
			        EstUnCercle := InPropertyTypes(genre,[PetitCercleWhiteProp, PetitCercleBlackProp, PetitCercleProp]);
			        
			        if TraitMoyen 
			          then
			            begin
			              SetLineWidthPostscript(2, 1);
			              SetLineWidthPostscript(1, 1);
			              if not(EstUnCercle) then UnTranslatePourPostScript(0.25, 0.25);
			            end
			          else
			            begin
			              SetLineWidthPostscript(3, 1);
			              SetLineWidthPostscript(1, 1);
			              if not(EstUnCercle) then UnTranslatePourPostScript(0.33, 0.33);
			            end;
			        
			        if DoitDecalerRectPourQueLesDeltaSoientCentres(11, genre) 
			          then UnTranslatePourPostScript(0.5, 0.5);
			      end;
	      end;
	    
	    
	      
	begin
		with prop do
			begin
				case stockage of
					StockageEnEnsembleDeCases: 
						begin
							RegionMarquee := GetPackedSquareSetOfProperty(prop);
							for i := 1 to 8 do
								for j := 1 to 8 do
									begin
										whichSquare := i * 10 + j;
										if SquareInPackedSquareSet(whichSquare, RegionMarquee) then
											begin
											  SetEpaisseurTraitEtTranslateCommeNecessaire(genre,whichSquare);
											  DessinerUnePierreDelta(jeuCourant, whichSquare, genre, GetRectOfSquare2DDiagrammeFforum, false, BidonGetRect3DFunc, BidonGetRect3DFunc);
									      UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,whichSquare);
									    end;
									end;
						end;
					StockageEnCaseOthello: 
					  begin
					    SetEpaisseurTraitEtTranslateCommeNecessaire(genre,GetOthelloSquareOfProperty(prop));
						  DessinerUnePierreDelta(jeuCourant, GetOthelloSquareOfProperty(prop), genre, GetRectOfSquare2DDiagrammeFforum, false, BidonGetRect3DFunc, BidonGetRect3DFunc);
					    UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,GetOthelloSquareOfProperty(prop));
					  end;
					StockageEnCaseOthelloAlpha: 
						begin
						  SetEpaisseurTraitEtTranslateCommeNecessaire(genre,GetOthelloSquareOfPropertyAlpha(prop));
						  DessinerUnePierreDelta(jeuCourant, GetOthelloSquareOfPropertyAlpha(prop), genre, GetRectOfSquare2DDiagrammeFforum, false, BidonGetRect3DFunc, BidonGetRect3DFunc);
				      UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,GetOthelloSquareOfPropertyAlpha(prop));
				    end;
				  StockageEnCoupleCases:
						begin
						  GetSquareCoupleOfProperty(prop, whichSquare, whichSquare2);
						  SetEpaisseurTraitEtTranslateCommeNecessaire(genre, whichSquare);
						  DessinerUnePierreDeltaDouble(jeuCourant, whichSquare, whichSquare2, genre,
                                           GetRectOfSquare2DDiagrammeFforum,
                                           false,
                                           BidonGetRect3DFunc,
                                           BidonGetRect3DFunc);
				      UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,whichSquare);
				    end;
				end; {case}
			end; {with}
	end;


	procedure ConstruitPicturePionsDeltaCourants;
	begin
		ItereSurPierresDeltaCourantes(DessinerPierresDeltaOfPropertyDiagrammeFforum);
	end;



	function CopierPICTDansPressePapier(myPicture: PicHandle): OSErr;
	begin
		HLockHi(Handle(myPicture));
		CopierPICTDansPressePapier := MyPutScrap(GetHandleSize(Handle(myPicture)), 'PICT', Ptr(myPicture^));
		HUnlock(Handle(myPicture));
	end;





	procedure CopierEnMacDraw;
		var
			aux: SInt32;
			saisie: rect;
			OthellierPicture: PicHandle;
			oldClipRgn: RgnHandle;
			PositionEtCoupStr: str185;
			oldPen: penState;
			chainePositionInitiale,chaineCoups : str255;
			chainePosition : str255;
			numeroProbleme : SInt32;
	begin
		if not(enSetUp) then
			begin
				if enRetour then
					ParamDiagCourant.TypeDiagrammeFFORUM := DiagrammePartie
				else
					ParamDiagCourant.TypeDiagrammeFFORUM := DiagrammePosition;

				GetPenState(oldPen);
				oldClipRgn := NewRgn();
				GetClip(oldClipRgn);
				SetRect(saisie, ParamDiagCourant.decalageHorFFORUM, 
				                ParamDiagCourant.decalageVertFFORUM, 
				                ParamDiagCourant.decalageHorFFORUM + LargeurDiagrammeFFORUM(), 
				                ParamDiagCourant.decalageVertFFORUM + HauteurDiagrammeFFORUM());
				ClipRect(saisie);
				OthellierPicture := OpenPicture(saisie);
				
				ConstruitPositionEtCoupDapresPartie(PositionEtCoupStr);
				ParserPositionEtCoupsOthello8x8(positionEtCoupStr,chainePositionInitiale,chaineCoups);
				chainePosition := ConstruitChainePosition8x8(jeuCourant);
				
				case ParamDiagCourant.typeDiagrammeFFORUM of
					DiagrammePartie: 
						ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
					DiagrammePosition: 
						begin
						  ConstruitPositionPicture(chainePosition,chaineCoups);
						  if not(ParamDiagCourant.EcritApres37c7FFORUM) then
						    if EstUnEnonceNumeroteDeProblemeDeCoin(ParamDiagCourant.CommentPositionFFORUM^^,numeroProbleme)
						      then
						        begin
						          SetDoitNumeroterProblemesDePriseDeCoin(true);
						          SetNumeroProblemeDePriseDeCoin(numeroProbleme);
				              SetPeutIncrementerNumerotationDiagrammeDePriseDeCoin(true);
				            end
				          else
				            SetDoitNumeroterProblemesDePriseDeCoin(false);
				    end;
					DiagrammePourListe: 
						ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
				end;
				if ParamDiagCourant.DessinePierresDeltaFFORUM then
					ConstruitPicturePionsDeltaCourants;
				ClosePicture;
				SetClip(oldclipRgn);
				DisposeRgn(oldclipRgn);

				aux := MyZeroScrap();
				aux := CopierPICTDansPressePapier(OthellierPicture);
				
				

				KillPicture(OthellierPicture);
				SetPenState(oldPen);
			end;
	end;


	procedure CopierPucesNumerotees;
		var
			aux: SInt32;
			saisie: rect;
			PucePicture: PicHandle;
			oldclipRgn: RgnHandle;
			oldPen: penState;

		procedure ConstruitPuce(numero : SInt16);
			var
				unRect: rect;
				a, b : SInt16; 
				x, y : SInt16; 
				haut, diff, larg, larg1, fontsize : SInt16; 
				centragevertical : SInt16; 
				str, str1: str255;
				InfosPolice: fontInfo;
		begin
		  DisableQuartzAntiAliasingThisPort(qdThePort());
			with ParamDiagCourant do
				begin
					haut := HauteurTexteDansDiagrammeFFORUM();
					diff := TaillecaseFFORUM div 4;

					PenSize(1, 1);
					PenPat(blackPattern);
					TextFont(PoliceFForumID);
					TextFace(normal);
					TextSize(haut);
					fontsize := haut;
					GetFontInfo(InfosPolice);

					fontsize := haut;
					TextSize(fontsize);
					GetFontInfo(InfosPolice);
					centragevertical := (tailleCaseFFORUM - Min(fontsize, InfosPolice.ascent - InfosPolice.leading) + 1) div 2;

					a := TaillecaseFFORUM;
					b := TaillecaseFFORUM;
					SetRect(unRect, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
					if odd(numero) then
						begin
							FillOval(unRect, blackPattern);

							TextMode(3);
							if(PoliceFForumID = 0) & (haut >= 12) then
								TextFace(normal)        {Chicago est deja assez large}
							else
								TextFace(bold);
						  if numero >= 100 then TextFace(condense);

							if (numero >= 10) & (numero <= 99) then
								begin
									NumToString(platmod10[numero], str);
									NumToString(platdiv10[numero], str1);
									larg := StringWidth(str);
									larg1 := StringWidth(str1);
									y := b - centragevertical;
									x := a -(TaillecaseFFORUM + larg + larg1) div 2 + 1;
									Moveto(x, y);
									DrawString(str1);
									x := a -(TaillecaseFFORUM - larg1 + larg) div 2;
									Moveto(x, y);
									DrawString(str);
								end
							else
								begin
									NumToString(numero, str);
									y := b - centragevertical;
									x := a -(TaillecaseFFORUM + StringWidth(str) - 1) div 2;
									Moveto(x, y);
									DrawString(str);
								end;
						end
					else if not(odd(numero)) then
						begin
							ForeColor(whiteColor);
							FillOval(unRect, blackPattern);
							ForeColor(BlackColor);
							FrameOval(unRect);
							TextMode(1);
							if numero >= 100 
							  then TextFace(condense)
							  else TextFace(normal);
							
							if (numero >= 10) & (numero <= 99) then
								begin
									NumToString(platmod10[numero], str);
									NumToString(platdiv10[numero], str1);
									larg := StringWidth(str);
									larg1 := StringWidth(str1);
									y := b - centragevertical;
									x := a -(TaillecaseFFORUM + larg + larg1 - 1) div 2;
									Moveto(x, y);
									DrawString(str1);
									x := a -(TaillecaseFFORUM - larg1 + larg + 1) div 2;
									Moveto(x, y);
									DrawString(str);
								end
							else
								begin
									NumToString(numero, str);
									y := b - centragevertical;
									x := a - (TaillecaseFFORUM + StringWidth(str) - 1) div 2;
									Moveto(x, y);
									DrawString(str);
								end;
						end;

				end;
		  DisableQuartzAntiAliasingThisPort(qdThePort());
		end;


	begin
		inc(numeroPuce);

		GetPenState(oldPen);
		oldClipRgn := NewRgn();
		GetClip(oldClipRgn);
		SetRect(saisie, 0, 0, ParamDiagCourant.TaillecaseFFORUM, ParamDiagCourant.TaillecaseFFORUM);
		ClipRect(saisie);
		PucePicture := OpenPicture(saisie);
		ConstruitPuce(numeroPuce);
		ClosePicture;
		SetClip(oldclipRgn);
		DisposeRgn(oldclipRgn);

		aux := MyZeroScrap();
		aux := CopierPICTDansPressePapier(PucePicture);

		KillPicture(PucePicture);
		SetPenState(oldPen);
	end;


	procedure DessineExamplePictureDiagFFORUM(dp : DialogPtr; const chainePositionInitiale,chainePosition,chaineCoups : str255);
	  const kPositionVerticaleExemple = 120;
	        kPositionHorizontaleExemple = 244; 
		var
			OthellierPicture: PicHandle;
			unRect, unrectDiag: rect;
			oldClipRgn: RgnHandle;
			oldDecH, oldDecV : SInt16; 
			zoneGrisee : rect;
	begin
	  DisableQuartzAntiAliasingThisPort(qdThePort());
	  DisableQuartzAntiAliasingThisPort(GetDialogPort(dp));
	  
		oldDecH := ParamDiagCourant.decalageHorFFORUM;
		oldDecV := ParamDiagCourant.decalageVertFFORUM;
		ParamDiagCourant.decalageHorFFORUM := 0;
		ParamDiagCourant.decalageVertFFORUM := 0;
		oldClipRgn := NewRgn();
		GetClip(oldClipRgn);
		ClipRect(QDGetPortBound());
		SetRect(unrectDiag, 0, 0, LargeurDiagrammeFFORUM(), HauteurDiagrammeFFORUM());
		
		{
		
		}
		
		OthellierPicture := OpenPicture(unrectDiag);
		DisableQuartzAntiAliasingThisPort(qdThePort());
		DisableQuartzAntiAliasingThisPort(GetDialogPort(dp));
		
		case ParamDiagCourant.typeDiagrammeFFORUM of
			DiagrammePartie: 
				ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
			DiagrammePosition: 
				ConstruitPositionPicture(chainePosition,chaineCoups);
			DiagrammePourListe: 
				ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
		end;
		if ParamDiagCourant.DessinePierresDeltaFFORUM then
			ConstruitPicturePionsDeltaCourants;
		ClosePicture;
		SetClip(oldclipRgn);
		DisposeRgn(oldclipRgn);


    SetRect(unRect, kPositionHorizontaleExemple, kPositionVerticaleExemple, QDGetPortBound().right+2, QDGetPortBound().bottom+2);
		EraseRect(unRect);

		SetRect(zoneGrisee, kPositionHorizontaleExemple, kPositionVerticaleExemple, QDGetPortBound().right-5, QDGetPortBound().bottom-5);
		if DrawThemeWindowListViewHeader(zoneGrisee,kThemeStateActive) = NoErr then;
		FrameRoundRect(zoneGrisee,0,0); 
		
		
		unRect := OthellierPicture^^.picframe;
		unRect := CenterRectInRect(unRect,zoneGrisee);
		if unRect.left < zoneGrisee.left then OffSetRect(unRect, zoneGrisee.left - unRect.left, 0);
		if unRect.top  < zoneGrisee.top then OffSetRect(unRect, 0, zoneGrisee.top - unRect.top);
		
		SetOrigin(-unRect.left, -unRect.top); 
		unRect := OthellierPicture^^.picframe;
		DisableQuartzAntiAliasing;
		DrawPicture(OthellierPicture, unRect);
		EnableQuartzAntiAliasing(true);
		KillPicture(OthellierPicture);
		SetOrigin(0, 0);
		ParamDiagCourant.decalageHorFFORUM := oldDecH;
		ParamDiagCourant.decalageVertFFORUM := oldDecV;
		TextSize(0);
		TextFont(systemFont);
		TextFace(normal);
		
		EnableQuartzAntiAliasingThisPort(NIL,true);
	end;

	function FiltreDialogueDiagramme(dlog : DialogPtr; var evt: eventrecord; var item : SInt16): boolean;
	begin
		FiltreDialogueDiagramme := false;
		if not(EvenementDuDialogue(dlog, evt)) then
			FiltreDialogueDiagramme := MyFiltreClassiqueRapide(dlog, evt, item)
		else
			case evt.what of
				updateEvt: 
					begin
						item := VirtualUpdateItemInDialog;
						FiltreDialogueDiagramme := true;
					end;
				otherwise
					FiltreDialogueDiagramme := MyFiltreClassiqueRapide(dlog, evt, item);
			end;  {case}
	end;


	function DoDiagrammeFFORUM(ParametreTexte: str255; const chainePositionInitiale,chainePosition,chaineCoups : str255): boolean;
		const
			PosiFFORUMDialogID = 146;
			DiagFFORUMDialogID = 147;
			ListFFORUMDialogID = 148;
			MenuFlottantPoliceID = 3000;
			MenuFlottantFondID = 3002;
			MenuFlottantIntensiteID = 3003;

			OK = 1;
			Annuler = 2;
			StyleAnglaisBouton = 3;
			ValeursStandardBouton = 4;
			LargeurText = 6;
			EpaisseurBordureText = 8;
			PoliceStaticText = 9;
			PoliceUserItemPopUp = 10;
			TitreRadio = 11;
			TitreText = 12;
			NomsJoueursBox = 11;
			NomTournoiBox = 12;
			TitreDuDialogueStatic = 13;
			ExempleStaticText = 14;
			CoordonneesBox = 16;
			CoinsDuCarreBox = 17;
			Pions1PixelBox = 18;
			PixelEnDedansText = 19;
			PixelEnDedansStatic = 20;
			TraitsFinsBox = 21;
			NumerosSeulementBox = 22;
			EcritureApresRadio = 22;
			FondStaticText = 24;
			FondUserItemPopUp = 25;
			DistanceBordureStatic = 26;
			DistanceBordureText = 27;
			IntensiteStaticText = 28;
			IntensiteUserItemPopUp = 29;
			PierresDeltaBox = 30;

		var
			dp : DialogPtr;
			itemHit : SInt16; 
			itemrect: rect;
			FiltreDialogueDiagrammeUPP: modalFilterUPP;
			err : OSErr;

			tailleCaseArrivee : SInt16; 
			epaisseurCadreArrivee: extended;
			distanceCadreArrivee : SInt16; 
			CoordonneesArrivee: boolean;
			TraitsFinsArrivee: boolean;
			NumerosSeulementArrivee: boolean;
			nbPixelDedansArrivee : SInt16; 
			PionsEnDedansArrivee: boolean;
			DessineCoinsDuCarreArrivee: boolean;
			DessinePierresDeltaArrivee: boolean;
			EcritApres37c7Arrivee: boolean;
			EcritNomsJoueursArrivee: boolean;
			EcritNomTournoiArrivee: boolean;
			PoliceArrivee : SInt16; 
			titreArrivee: str255;
			CommentPositionArrivee: str255;
			FondOthellierArrivee : SInt16; 
			CouleurOthellierArrivee : SInt16; 

			tailleCaseDessinee : SInt16; 
			epaisseurCadreDessinee: extended;
			distanceCadreDessinee : SInt16; 
			CoordonneesDessinee: boolean;
			TraitsFinsDessinee: boolean;
			NumerosSeulementDessinee: boolean;
			PionsEnDedansDessinee: boolean;
			nbPixelDedansDessinee : SInt16; 
			DessineCoinsDuCarreDessinee: boolean;
			DessinePierresDeltaDessinee: boolean;
			EcritApres37c7Dessinee: boolean;
			EcritNomsJoueursDessinee: boolean;
			EcritNomTournoiDessinee: boolean;
			PoliceDessinee : SInt16; 
			TitreDessinee: str255;
			CommentPositionDessinee: str255;
			FondOthellierDessinee : SInt16; 
			couleurOthellierDessinee : SInt16; 

			menuFlottantPolice: MenuRef;
			menuPoliceRect: rect;
			itemMenuPolice : SInt16; 
			menuFlottantFond: MenuRef;
			menuFondRect: rect;
			itemMenuFond : SInt16; 
			menuFlottantIntensite: MenuRef;
			menuIntensiteRect: rect;
			itemMenuIntensite : SInt16; 

			s, s1, s2: str255;
			scoreFinalDejaAfficheDansDialogue: boolean;

		procedure SauveValeursArrivee;
		begin
			with ParamDiagCourant do
				begin
					tailleCaseArrivee := tailleCaseFFORUM;
					epaisseurCadreArrivee := epaisseurCadreFFORUM;
					distanceCadreArrivee := distanceCadreFFORUM;
					PionsEnDedansArrivee := PionsEnDedansFFORUM;
					nbPixelDedansArrivee := nbPixelDedansFFORUM;
					DessineCoinsDuCarreArrivee := DessineCoinsDuCarreFFORUM;
					DessinePierresDeltaArrivee := DessinePierresDeltaFFORUM;
					EcritApres37c7Arrivee := EcritApres37c7FFORUM;
					EcritNomsJoueursArrivee := EcritNomsJoueursFFORUM;
					EcritNomTournoiArrivee := EcritNomTournoiFFORUM;
					PoliceArrivee := PoliceFForumID;
					CoordonneesArrivee := CoordonneesFFORUM;
					TraitsFinsArrivee := TraitsFinsFFORUM;
					NumerosSeulementArrivee := NumerosSeulementFFORUM;
					CommentPositionArrivee := CommentPositionFFORUM^^;
					TitreArrivee := titreFFORUM^^;
					FondOthellierArrivee := FondOthellierPatternFFORUM;
					CouleurOthellierArrivee := couleurOthellierFFORUM;

					tailleCaseDessinee := tailleCaseFFORUM;
					epaisseurCadreDessinee := 0;
					distanceCadreDessinee := 0;
					PionsEnDedansDessinee := false;
					nbPixelDedansDessinee := 0;
					DessineCoinsDuCarreDessinee := false;
					DessinePierresDeltaDessinee := false;
					EcritApres37c7Dessinee := false;
					EcritNomsJoueursDessinee := false;
					EcritNomTournoiDessinee := false;
					PoliceDessinee := 0;
					Coordonneesdessinee := false;
					TraitsFinsdessinee := false;
					NumerosSeulementdessinee := false;
					CommentPositiondessinee := '';
					TitreDessinee := '';
					FondOthellierDessinee := kWhitePattern;
					couleurOthellierDessinee := BlackColor;

				end;
		end;

		procedure RemetValeursArrivee;
		begin
			with ParamDiagCourant do
				begin
					tailleCaseFFORUM := tailleCaseArrivee;
					epaisseurCadreFFORUM := epaisseurCadreArrivee;
					distanceCadreFFORUM := distanceCadreArrivee;
					PionsEnDedansFFORUM := PionsEnDedansArrivee;
					nbPixelDedansFFORUM := nbPixelDedansArrivee;
					DessineCoinsDuCarreFFORUM := DessineCoinsDuCarreArrivee;
					DessinePierresDeltaFFORUM := DessinePierresDeltaArrivee;
					EcritApres37c7FFORUM := EcritApres37c7Arrivee;
					EcritNomsJoueursFFORUM := EcritNomsJoueursArrivee;
					EcritNomTournoiFFORUM := EcritNomTournoiArrivee;
					PoliceFForumID := PoliceArrivee;
					CoordonneesFFORUM := CoordonneesArrivee;
					TraitsFinsFFORUM := TraitsFinsArrivee;
					NumerosSeulementFFORUM := NumerosSeulementArrivee;
					FondOthellierPatternFFORUM := FondOthellierArrivee;
					couleurOthellierFFORUM := couleurOthellierArrivee;
					titreFFORUM^^ := titreArrivee;
					CommentPositionFFORUM^^ := CommentPositionArrivee;
				end;
		end;

		procedure AjusteDialogue(avecRemplissageEpaisseurBordureText: boolean);
		begin
			with ParamDiagCourant do
				begin


					if tailleCaseFFORUM > 0 then
						NumToString(tailleCaseFFORUM, s)
					else
						s := '';
					SetItemTextInDialog(dp, LargeurText, s);
					if avecRemplissageEpaisseurBordureText then
						begin
							if epaisseurCadreFFORUM > 0.0 then
								s := ReelEnString(epaisseurCadreFFORUM)
							else
								s := '';
							SetItemTextInDialog(dp, EpaisseurBordureText, s);
						end;
					if distanceCadreFFORUM > 0 then
						NumToString(distanceCadreFFORUM, s)
					else
						s := '';
					SetItemTextInDialog(dp, distanceBordureText, s);


					case TypeDiagrammeFFORUM of
						DiagrammePartie: 
							begin
								if gameOver & not(scoreFinalDejaAfficheDansDialogue) then
									begin
										GetItemTextInDialog(dp, ExempleStaticText, s);
										NumToString(nbreDePions[pionNoir], s1);
										NumToString(nbreDePions[pionBlanc], s2);
										s1 := s1 + StringOf('-') + s2;
										s2 := ReadStringFromRessource(TextesRapportID, 7);   {'score final ^0'}
										s := s + ' ** ' + ParamStr(s2, s1, '', '', '') + ' **';
										SetItemTextInDialog(dp, ExempleStaticText, s);
										scoreFinalDejaAfficheDansDialogue := true;
									end;
								s := titreFForum^^;
								SetItemTextInDialog(dp, TitreText, s);
								SetBoolCheckBox(dp, NumerosSeulementBox, NumerosSeulementFFORUM);
							end;
						DiagrammePosition: 
							begin
								SetBoolCheckBox(dp, EcritureApresRadio, EcritApres37c7FFORUM);
								SetBoolCheckBox(dp, TitreRadio, not(EcritApres37c7FFORUM));
								GetDialogItemRect(dp, TitreRadio, itemRect);

								if EcritApres37c7FFORUM then
									PenPat(grayPattern);
								s := CommentPositionFFORUM^^;
								SetItemTextInDialog(dp, TitreText, s);
								PenPat(blackPattern);
								InsetRect(itemrect, -3, -3);
								ValidRect(itemrect);
							end;
						DiagrammePourListe: 
							begin
								SetBoolCheckBox(dp, NomTournoiBox, EcritNomTournoiFFORUM);
								SetBoolCheckBox(dp, NomsJoueursBox, EcritNomsJoueursFFORUM);
								SetBoolCheckBox(dp, NumerosSeulementBox, NumerosSeulementFFORUM);
							end;
					end;  {case}

					if(nbPixelDedansFFORUM > 0) &(nbPixelDedansFFORUM < 100) then
						NumToString(nbPixelDedansFFORUM, s)
					else
						begin
							s := '';
							nbPixelDedansFFORUM := 0;
							PionsEnDedansFFORUM := false;
						end;
					if not(PionsEnDedansFFORUM) then
						PenPat(grayPattern);
					SetItemTextInDialog(dp, PixelEnDedansText, s);
					PenPat(blackPattern);
					InsetRect(itemrect, -3, -3);
					ValidRect(itemrect);

					SetBoolCheckBox(dp, TraitsFinsBox, TraitsFinsFFORUM);
					SetBoolCheckBox(dp, Pions1PixelBox, PionsEnDedansFFORUM);
					SetBoolCheckBox(dp, CoinsDuCarreBox, DessineCoinsDuCarreFFORUM);
					SetBoolCheckBox(dp, PierresDeltaBox, DessinePierresDeltaFFORUM);
					SetBoolCheckBox(dp, CoordonneesBox, CoordonneesFFORUM);

					if not(EventAvail(keydownmask + autokeymask, theEvent)) then
						if tailleCaseFFORUM >= 8 then
							begin
								if( tailleCaseDessinee <> tailleCaseFFORUM ) |
								  ( epaisseurCadreDessinee <> epaisseurCadreFFORUM ) |
								  ( distanceCadreDessinee <> distanceCadreFFORUM ) |
								  ( PionsEnDedansDessinee <> PionsEnDedansFFORUM ) |
								  ( nbPixelDedansDessinee <> nbPixelDedansFFORUM ) |
								  ( DessineCoinsDuCarreDessinee <> DessineCoinsDuCarreFFORUM ) |
								  ( DessinePierresDeltaDessinee <> DessinePierresDeltaFFORUM ) |
								  ( EcritApres37c7Dessinee <> EcritApres37c7FFORUM ) |
								  ( EcritNomsJoueursDessinee <> EcritNomsJoueursFFORUM ) |
								  ( EcritNomTournoiDessinee <> EcritNomTournoiFFORUM ) |
								  ( PoliceDessinee <> PoliceFForumID ) |
								  ( TitreDessinee <> TitreFFORUM^^ ) |
								  ( Coordonneesdessinee <> CoordonneesFFORUM ) |
								  ( TraitsFinsdessinee <> TraitsFinsFFORUM ) |
								  ( FondOthellierDessinee <> FondOthellierPatternFFORUM ) |
								  ( CouleurOthellierDessinee <> CouleurOthellierFFORUM ) |
								  ( NumerosSeulementdessinee <> NumerosSeulementFFORUM ) |
								  ( CommentPositiondessinee <> CommentPositionFFORUM^^ ) then
								begin
									DessineExamplePictureDiagFFORUM(dp,chainePositionInitiale,chainePosition,chaineCoups);
									tailleCaseDessinee := tailleCaseFFORUM;
									epaisseurCadreDessinee := epaisseurCadreFFORUM;
									distanceCadreDessinee := distanceCadreFFORUM;
									PionsEnDedansDessinee := PionsEnDedansFFORUM;
									nbPixelDedansDessinee := nbPixelDedansFFORUM;
									DessineCoinsDuCarreDessinee := DessineCoinsDuCarreFFORUM;
									DessinePierresDeltaDessinee := DessinePierresDeltaFFORUM;
									EcritApres37c7Dessinee := EcritApres37c7FFORUM;
									EcritNomsJoueursDessinee := EcritNomsJoueursFFORUM;
									EcritNomTournoiDessinee := EcritNomTournoiFFORUM;
									PoliceDessinee := PoliceFForumID;
									TitreDessinee := TitreFFORUM^^;
									Coordonneesdessinee := CoordonneesFFORUM;
									TraitsFinsdessinee := TraitsFinsFFORUM;
									FondOthellierDessinee := FondOthellierPatternFFORUM;
									CouleurOthellierDessinee := CouleurOthellierFFORUM;
									NumerosSeulementdessinee := NumerosSeulementFFORUM;
									CommentPositiondessinee := CommentPositionFFORUM^^;
								end;
							end;
					SetPortByDialog(dp);
					DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
					DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
					DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
				end;
		end;

		procedure InstalleMenuFlottantPolice;
		begin
			MenuFlottantPolice := NewMenu(MenuFlottantPoliceID, '');
			AppendResMenu(MenuFlottantPolice, 'FONT');
			InsertMenu(MenuFlottantPolice, -1);
			{AjouteEspacesItemsMenu(MenuFlottantPolice,2);}
		end;

		procedure InstalleMenuFlottantFond;
		begin
			MenuFlottantFond := MyGetMenu(MenuFlottantFondID);
			InsertMenu(MenuFlottantFond, -1);
		end;

		procedure InstalleMenuFlottantIntensite;
		begin
			MenuFlottantIntensite := MyGetMenu(MenuFlottantIntensiteID);
			InsertMenu(MenuFlottantIntensite, -1);
		end;


		procedure DesinstalleMenuFlottantPolice;
		begin
			DeleteMenu(MenuFlottantPoliceID);
			TerminateMenu(MenuFlottantPolice,false);
		end;

		procedure DesinstalleMenuFlottantFond;
		begin
			DeleteMenu(MenuFlottantFondID);
			TerminateMenu(MenuFlottantFond,true);
		end;

		procedure DesinstalleMenuFlottantIntensite;
		begin
			DeleteMenu(MenuFlottantIntensiteID);
			TerminateMenu(MenuFlottantIntensite,true);
		end;


		function MenuPoliceItemToPoliceID(item : SInt16) : SInt16; 
			var
				policeID : SInt16; 
		begin
			GetMenuItemText(MenuFlottantPolice, item, s);
			s := EnleveEspacesDeDroite(s);
			GetFNum(s, policeID);
			MenuPoliceItemToPoliceID := policeID;
		end;

		procedure MenuFondToCouleurOthellier(itemMenuFond : SInt16; var CouleurOthellierFFORUM : SInt16);
		begin
			CouleurOthellierFFORUM := itemMenuFond;
		end;

		procedure MenuIntensiteToOthellierPattern(itemMenuIntensite : SInt16; var FondOthellierPatternFFORUM : SInt16);
		begin
			FondOthellierPatternFFORUM := itemMenuIntensite + 2;
		end;

		procedure GetMenuPoliceItemAndRect;
			var
				i : SInt16; 
		begin
			GetDialogItemRect(dp, PoliceUserItemPopUp, menuPoliceRect);
			itemMenuPolice := 1;
			for i := 1 to MyCountMenuItems(MenuFlottantPolice) do
				if MenuPoliceItemToPoliceID(i) = ParamDiagCourant.PoliceFForumID then
					itemMenuPolice := i;
			ParamDiagCourant.PoliceFForumID := MenuPoliceItemToPoliceID(itemMenuPolice);
		end;

		procedure GetMenuFondItemAndRect;
		begin
			GetDialogItemRect(dp, FondUserItemPopUp, menuFondRect);
			itemMenuFond := ParamDiagCourant.CouleurOthellierFFORUM;
			if itemMenuFond < kCouleurDiagramTransparent then
				itemMenuFond := kCouleurDiagramTransparent;
			if itemMenuFond > kCouleurDiagramNoir then
				itemMenuFond := kCouleurDiagramNoir;
		end;

		procedure GetMenuIntensiteItemAndRect;
		begin
			GetDialogItemRect(dp, IntensiteUserItemPopUp, menuIntensiteRect);
			itemMenuIntensite := ParamDiagCourant.FondOthellierPatternFFORUM - 2;
			if itemMenuIntensite < 1 then
				itemMenuIntensite := 1;
			if itemMenuIntensite > 4 then
				itemMenuIntensite := 4;
		end;

	begin
		DoDiagrammeFFORUM := false;
		with ParamDiagCourant do
			begin
				BeginDialog;
				SwitchToScript(gLastScriptUsedInDialogs);
				FiltreDialogueDiagrammeUPP := NewModalFilterUPP(@FiltreDialogueDiagramme);
				case typeDiagrammeFFORUM of
					DiagrammePartie: 
						dp := MyGetNewDialog(DiagFFORUMDialogID, FenetreFictiveAvantPlan());
					DiagrammePosition: 
						dp := MyGetNewDialog(PosiFFORUMDialogID, FenetreFictiveAvantPlan());
					DiagrammePourListe: 
						dp := MyGetNewDialog(ListFFORUMDialogID, FenetreFictiveAvantPlan());
				end;
				if dp <> NIL then
					begin
						scoreFinalDejaAfficheDansDialogue := false;
						CenterTextInDialog(dp, ParametreTexte, TitreDuDialogueStatic);
						SauveValeursArrivee;
						InstalleMenuFlottantPolice;
						InstalleMenuFlottantFond;
						InstalleMenuFlottantIntensite;
						GetMenuPoliceItemAndRect;
						GetMenuFondItemAndRect;
						GetMenuIntensiteItemAndRect;
						ShowWindow(GetDialogWindow(dp));
						AjusteDialogue(true);
						MyDrawDialog(dp);
						DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
						DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
						DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
						if(typeDiagrammeFFORUM = DiagrammePartie) |(typeDiagrammeFFORUM = DiagrammePosition) then
							SelectDialogItemText(dp, TitreText, 0, MaxInt);
					  SelectWindow(GetDialogWindow(dp));
						NoUpdateThisWindow(GetDialogWindow(dp));
						err := SetDialogTracksCursor(dp,true);
						repeat
							ModalDialog(FiltreDialogueDiagrammeUPP, itemHit);
							SetPortByDialog(dp);
							case itemHit of
								VirtualUpdateItemInDialog: 
									begin
										BeginUpdate(GetDialogWindow(dp));
										SetPortByDialog(dp);
										MyDrawDialog(dp);
										DessineExamplePictureDiagFFORUM(dp,chainePositionInitiale,chainePosition,chaineCoups);
										DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
										DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
										DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
										OutlineOK(dp);
										EndUpdate(GetDialogWindow(dp));
									end;
								OK: 
									;
								Annuler: 
									;{RemetValeursArrivee}
								LargeurText: 
									begin
										GetItemTextInDialog(dp, itemHit, s1);
										s := SeulementLesChiffres(s1);
										SetItemTextInDialog(dp, LargeurText, s);
										if Length(s) > 0 then
											begin
												StringToNum(s, tailleCaseFFORUM);
                      {nbPixelDedansFFORUM := TaillecaseFFORUM div 20 +1;}
											end
										else
											tailleCaseFFORUM := 0;
									end;
								EpaisseurBordureText: 
									begin
										GetItemTextInDialog(dp, EpaisseurBordureText, s1);
										s := SeulementLesChiffresOuLesPoints(s1);
										if(s <> '') & not(EstUnReel(s)) then
											SysBeep(0);
										SetItemTextInDialog(dp, EpaisseurBordureText, s);
										if Length(s) > 0 then
											epaisseurCadreFFORUM := StringSimpleEnReel(s)
										else
											epaisseurCadreFFORUM := 0.0;
										{WritelnDansRapport(ReelEnStringAvecDecimales(epaisseurCadreFFORUM, 15));}
									end;
								DistanceBordureText: 
									begin
									    GetItemTextInDialog(dp, DistanceBordureText, s1);
										s := SeulementLesChiffres(s1);
										SetItemTextInDialog(dp, DistanceBordureText, s);
										if Length(s) > 0 then
											StringToNum(s, distanceCadreFFORUM)
										else
											distanceCadreFFORUM := 0;
									end;
								PixelEnDedansText: 
									begin
										GetItemTextInDialog(dp, itemHit, s1);
										s := SeulementLesChiffres(s1);
										if(Length(s) >= 2) then
											s := '';
										SetItemTextInDialog(dp, itemHit, s);
										StringToNum(s, nbPixelDedansFFORUM);
										if(Length(s) > 0) & (nbPixelDedansFFORUM < 10) then
											begin
												PionsEnDedansFFORUM := true;
												StringToNum(s, nbPixelDedansFFORUM)
											end
										else
											begin
												PionsEnDedansFFORUM := false;
												nbPixelDedansFFORUM := 0;
											end;
									end;

								ValeursStandardBouton: 
									begin
										SetValeursParDefautDiagFFORUM(ParamDiagCourant, typeDiagrammeFFORUM);
										GetMenuPoliceItemAndRect;
										GetMenuFondItemAndRect;
										GetMenuIntensiteItemAndRect;
										DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
										DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
										DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
										AjusteDialogue(true);
									end;
								StyleAnglaisBouton: 
									begin
										SetValeursRevueAnglaise(ParamDiagCourant, typeDiagrammeFFORUM);
										GetMenuPoliceItemAndRect;
										GetMenuFondItemAndRect;
										GetMenuIntensiteItemAndRect;
										DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
										DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
										DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
										AjusteDialogue(true);
									end;
								Pions1PixelBox, PixelEnDedansStatic: 
									begin
										PionsEnDedansFFORUM := not(PionsEnDedansFFORUM);
										if nbPixelDedansFFORUM <= 0 then
											nbPixelDedansFFORUM := 1;
                                        {if PionsEnDedansFFORUM then SelectDialogItemText(dp,PixelEnDedansText,0,MaxInt);}
									end;
								CoinsDuCarreBox: 
									DessineCoinsDuCarreFFORUM := not(DessineCoinsDuCarreFFORUM);
								PierresDeltaBox: 
									DessinePierresDeltaFFORUM := not(DessinePierresDeltaFFORUM);
								CoordonneesBox: 
									CoordonneesFFORUM := not(CoordonneesFFORUM);
								TraitsFinsBox: 
									TraitsFinsFFORUM := not(TraitsFinsFFORUM);
								EcritureApresRadio: 
									case typeDiagrammeFFORUM of
										DiagrammePartie: 
											numerosSeulementFFORUM := not(numerosSeulementFFORUM);
										DiagrammePosition: 
											EcritApres37c7FFORUM := true;
										DiagrammePourListe: 
											numerosSeulementFFORUM := not(numerosSeulementFFORUM);
									end;
								titreRadio
            {=NomsJoueursBox }
								: 
									case typeDiagrammeFFORUM of
										DiagrammePosition: 
											begin
												EcritApres37c7FFORUM := false;
												SelectDialogItemText(dp, TitreText, 0, MaxInt);
											end;
										DiagrammePourListe: 
											EcritNomsJoueursFFORUM := not(EcritNomsJoueursFFORUM);
									end;
								TitreText
            {=NomTournoiBox }
								: 
									begin
										case typeDiagrammeFFORUM of
											DiagrammePartie: 
												begin
													GetItemTextInDialog(dp, itemHit, s);
													titreFFORUM^^ := s;
												end;
											DiagrammePosition: 
												begin
													GetItemTextInDialog(dp, itemHit, s);
													commentPositionFFORUM^^ := s;
													EcritApres37c7FFORUM := false;
												end;
											DiagrammePourListe: 
												EcritNomTournoiFFORUM := not(EcritNomTournoiFFORUM);
										end; {case}
									end;
								PoliceUserItemPopUp: 
									begin
										if EventPopUpItemInDialog(dp, PoliceStaticText, MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true, true)
										  then PoliceFFORUMID := MenuPoliceItemToPoliceID(itemMenuPolice);
									end;
								FondUserItemPopUp: 
									begin
										if EventPopUpItemInDialog(dp, FondStaticText, MenuFlottantFond, itemMenuFond, menuFondRect, true, true)
										   then MenuFondToCouleurOthellier(itemMenuFond, CouleurOthellierFFORUM);
									end;
								IntensiteUserItemPopUp: 
									begin
										if EventPopUpItemInDialog(dp, IntensiteStaticText, MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true, true) 
										   then MenuIntensiteToOthellierPattern(itemMenuIntensite, FondOthellierPatternFFORUM);
									end;
              
							end; {case}
							if(itemHit <> OK) &(itemHit <> Annuler) &(itemHit <> VirtualUpdateItemInDialog) then
								AjusteDialogue(false);
							SetPortByDialog(dp);
						until(itemHit = OK) | (itemHit = Annuler);
						DoDiagrammeFFORUM := (itemHit <> Annuler);
						DesinstalleMenuFlottantPolice;
						DesinstalleMenuFlottantFond;
						DesinstalleMenuFlottantIntensite;
						MyDisposeDialog(dp);
						if itemHit = annuler then
							RemetValeursArrivee;
					end;
				MyDisposeModalFilterUPP(FiltreDialogueDiagrammeUPP);
				GetCurrentScript(gLastScriptUsedInDialogs);
        SwitchToRomanScript;
				EndDialog;
			end;
	end;
		

procedure SetTailleOthelloPourDiagrammeFforum(nbCasesH,nbCasesV : SInt16);
  begin
    tailleVersionOthello.h := nbCasesH;
    tailleVersionOthello.v := nbCasesV;
  end;

procedure GetTailleOthelloPourDiagrammeFforum(var nbCasesH,nbCasesV : SInt16);
begin
  nbCasesH := tailleVersionOthello.h;
  nbCasesV := tailleVersionOthello.v;
end;

end.