UNIT UnitEPS;




INTERFACE







USES UnitFichiersTEXT,UnitPositionEtTrait;


function WritePositionEtTraitEnEPSDansFichier(position : PositionEtTraitRec;fic : FichierTEXT) : OSErr;


IMPLEMENTATION







USES UnitDiagramFforum,{UnitOth1,}UnitScannerOthellistique;


function WritePrologueEPSDansFichier(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin
  err := WritelnDansFichierTexte(fic,'%!PS-Adobe-3.0 EPSF-3.0');
  err := WritelnDansFichierTexte(fic,'%%Creator: Cassio');
  err := WritelnDansFichierTexte(fic,'%%CreationDate: 22/01/2004 14:49:04');
  err := WritelnDansFichierTexte(fic,'%%BoundingBox: 0 0 200 200');
  err := WritelnDansFichierTexte(fic,'');
  err := WritelnDansFichierTexte(fic,'%%BeginProlog');
  err := WritelnDansFichierTexte(fic,'');
  err := WritelnDansFichierTexte(fic,'% othello coordinates');
  err := WritelnDansFichierTexte(fic,'/A1 {40 160} def /A2 {40 140} def /A3 {40 120} def /A4 {40 100} def /A5 {40 80} def /A6 {40 60} def /A7 {40 40} def /A8 {40 20} def');
  err := WritelnDansFichierTexte(fic,'/B1 {60 160} def /B2 {60 140} def /B3 {60 120} def /B4 {60 100} def /B5 {60 80} def /B6 {60 60} def /B7 {60 40} def /B8 {60 20} def');
  err := WritelnDansFichierTexte(fic,'/C1 {80 160} def /C2 {80 140} def /C3 {80 120} def /C4 {80 100} def /C5 {80 80} def /C6 {80 60} def /C7 {80 40} def /C8 {80 20} def');
  err := WritelnDansFichierTexte(fic,'/D1 {100 160} def /D2 {100 140} def /D3 {100 120} def /D4 {100 100} def /D5 {100 80} def /D6 {100 60} def /D7 {100 40} def /D8 {100 20} def');
  err := WritelnDansFichierTexte(fic,'/E1 {120 160} def /E2 {120 140} def /E3 {120 120} def /E4 {120 100} def /E5 {120 80} def /E6 {120 60} def /E7 {120 40} def /E8 {120 20} def');
  err := WritelnDansFichierTexte(fic,'/F1 {140 160} def /F2 {140 140} def /F3 {140 120} def /F4 {140 100} def /F5 {140 80} def /F6 {140 60} def /F7 {140 40} def /F8 {140 20} def');
  err := WritelnDansFichierTexte(fic,'/G1 {160 160} def /G2 {160 140} def /G3 {160 120} def /G4 {160 100} def /G5 {160 80} def /G6 {160 60} def /G7 {160 40} def /G8 {160 20} def');
  err := WritelnDansFichierTexte(fic,'/H1 {180 160} def /H2 {180 140} def /H3 {180 120} def /H4 {180 100} def /H5 {180 80} def /H6 {180 60} def /H7 {180 40} def /H8 {180 20} def');
  err := WritelnDansFichierTexte(fic,'');
  err := WritelnDansFichierTexte(fic,'% draw a black disc');
  err := WritelnDansFichierTexte(fic,'/disc_black{');
  err := WritelnDansFichierTexte(fic,'	newpath');
  err := WritelnDansFichierTexte(fic,'	8.5 0 360 arc');
  err := WritelnDansFichierTexte(fic,'	fill');
  err := WritelnDansFichierTexte(fic,'} def');
  err := WritelnDansFichierTexte(fic,'');
  err := WritelnDansFichierTexte(fic,'% draw a white disc');
  err := WritelnDansFichierTexte(fic,'/disc_white{');
	err := WritelnDansFichierTexte(fic,'newpath');
	err := WritelnDansFichierTexte(fic,'	0.5 setlinewidth');
	err := WritelnDansFichierTexte(fic,'	8.5 0 360 arc');
	err := WritelnDansFichierTexte(fic,'	stroke');
	err := WritelnDansFichierTexte(fic,'} def');
	err := WritelnDansFichierTexte(fic,'');
	err := WritelnDansFichierTexte(fic,'% draw a black move');
	err := WritelnDansFichierTexte(fic,'/move_black{');
	err := WritelnDansFichierTexte(fic,'	/y exch def');
	err := WritelnDansFichierTexte(fic,'	/x exch def');
	err := WritelnDansFichierTexte(fic,'	newpath');
	err := WritelnDansFichierTexte(fic,'	x y 8.5 0 360 arc');
	err := WritelnDansFichierTexte(fic,'	fill');
	err := WritelnDansFichierTexte(fic,'	1 setgray');
	err := WritelnDansFichierTexte(fic,'	x y moveto dup stringwidth pop 2 div neg -4.5 rmoveto');
	err := WritelnDansFichierTexte(fic,'	show');
	err := WritelnDansFichierTexte(fic,'	0 setgray');
	err := WritelnDansFichierTexte(fic,'} def');
	err := WritelnDansFichierTexte(fic,'');
	err := WritelnDansFichierTexte(fic,'% draw a white move');
	err := WritelnDansFichierTexte(fic,'/move_white{');
	err := WritelnDansFichierTexte(fic,'	/y exch def');
	err := WritelnDansFichierTexte(fic,'	/x exch def');
	err := WritelnDansFichierTexte(fic,'	newpath');
	err := WritelnDansFichierTexte(fic,'	0.5 setlinewidth');
	err := WritelnDansFichierTexte(fic,'	x y 8.5 0 360 arc');
	err := WritelnDansFichierTexte(fic,'	stroke');
	err := WritelnDansFichierTexte(fic,'	x y moveto dup stringwidth pop 2 div neg -4.5 rmoveto');
	err := WritelnDansFichierTexte(fic,'	show');
	err := WritelnDansFichierTexte(fic,'} def');
	err := WritelnDansFichierTexte(fic,'');
	err := WritelnDansFichierTexte(fic,'% draw the grid');
	err := WritelnDansFichierTexte(fic,'/board_grid{');
	err := WritelnDansFichierTexte(fic,'	newpath');
	err := WritelnDansFichierTexte(fic,'');
	err := WritelnDansFichierTexte(fic,'	%border');
	err := WritelnDansFichierTexte(fic,'	1.5 setlinewidth');
	err := WritelnDansFichierTexte(fic,'	  27   7 moveto');
	err := WritelnDansFichierTexte(fic,'	 166   0 rlineto');
	err := WritelnDansFichierTexte(fic,'	   0 166 rlineto');
	err := WritelnDansFichierTexte(fic,'	-166   0 rlineto');
	err := WritelnDansFichierTexte(fic,'	closepath');
	err := WritelnDansFichierTexte(fic,'	stroke');
	err := WritelnDansFichierTexte(fic,'');
	err := WritelnDansFichierTexte(fic,'	%vertical lines');
	err := WritelnDansFichierTexte(fic,'	0.5 setlinewidth');
	err := WritelnDansFichierTexte(fic,'	30 10 moveto');
	err := WritelnDansFichierTexte(fic,'	0 1 8{');
	err := WritelnDansFichierTexte(fic,'		 0  160 rlineto');
	err := WritelnDansFichierTexte(fic,'		20 -160 rmoveto');
	err := WritelnDansFichierTexte(fic,'	}for');
	err := WritelnDansFichierTexte(fic,'');
	err := WritelnDansFichierTexte(fic,'	%horizontal lines');
	err := WritelnDansFichierTexte(fic,'	30 10 moveto');
	err := WritelnDansFichierTexte(fic,'	0 1 8{');
	err := WritelnDansFichierTexte(fic,'		 160  0 rlineto');
	err := WritelnDansFichierTexte(fic,'		-160 20 rmoveto');
	err := WritelnDansFichierTexte(fic,'	}for');
	err := WritelnDansFichierTexte(fic,'	stroke');
	err := WritelnDansFichierTexte(fic,'');
	err := WritelnDansFichierTexte(fic,'	%marks');
	err := WritelnDansFichierTexte(fic,'	 70  50 2 0 360 arc fill');
	err := WritelnDansFichierTexte(fic,'	150  50 2 0 360 arc fill');
	err := WritelnDansFichierTexte(fic,'	 70 130 2 0 360 arc fill');
	err := WritelnDansFichierTexte(fic,'	150 130 2 0 360 arc fill');
	err := WritelnDansFichierTexte(fic,'}def');
	err := WritelnDansFichierTexte(fic,'');
	err := WritelnDansFichierTexte(fic,'% draw coordinates');
	err := WritelnDansFichierTexte(fic,'/board_coord{');
	err := WritelnDansFichierTexte(fic,'	/NewCenturySchoolbook-Roman findfont 15 scalefont setfont');
	err := WritelnDansFichierTexte(fic,'	newpath');
	err := WritelnDansFichierTexte(fic,'	(a)  35 180 moveto show');
	err := WritelnDansFichierTexte(fic,'	(b)  55 180 moveto show');
	err := WritelnDansFichierTexte(fic,'	(c)  75 180 moveto show');
	err := WritelnDansFichierTexte(fic,'	(d)  95 180 moveto show');
	err := WritelnDansFichierTexte(fic,'	(e) 115 180 moveto show');
	err := WritelnDansFichierTexte(fic,'	(f) 135 180 moveto show');
	err := WritelnDansFichierTexte(fic,'	(g) 155 180 moveto show');
	err := WritelnDansFichierTexte(fic,'	(h) 175 180 moveto show');
	err := WritelnDansFichierTexte(fic,'	(1)  14 155 moveto show');
	err := WritelnDansFichierTexte(fic,'	(2)  14 135 moveto show');
	err := WritelnDansFichierTexte(fic,'	(3)  14 115 moveto show');
	err := WritelnDansFichierTexte(fic,'	(4)  14  95 moveto show');
	err := WritelnDansFichierTexte(fic,'	(5)  14  75 moveto show');
	err := WritelnDansFichierTexte(fic,'	(6)  14  55 moveto show');
	err := WritelnDansFichierTexte(fic,'	(7)  14  35 moveto show');
	err := WritelnDansFichierTexte(fic,'	(8)  14  15 moveto show');
	err := WritelnDansFichierTexte(fic,'}def');
	err := WritelnDansFichierTexte(fic,'%%EndProlog');
  err := WritelnDansFichierTexte(fic,'');
  
  WritePrologueEPSDansFichier := err;
end;


function WriteDescriptionPositionEPSDansFichier(position : PositionEtTraitRec; var fic : FichierTEXT) : OSErr;
var i,j : SInt32;
    err : OSErr;
begin
  err := WritelnDansFichierTexte(fic,'	% draw the discs');
  for i := 1 to 8 do
    for j := 1 to 8 do
      case position.position[i*10+j] of
        pionBlanc : err := WritelnDansFichierTexte(fic,'	'+CoupEnStringEnMajuscules(i*10+j)+' disc_white');
        pionNoir  : err := WritelnDansFichierTexte(fic,'	'+CoupEnStringEnMajuscules(i*10+j)+' disc_black');
        pionVide  : ;
      end;
  err := WritelnDansFichierTexte(fic,'');
  WriteDescriptionPositionEPSDansFichier := err;
end;



function WriteCoupsPartieEPSDansFichier(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin
  err := WritelnDansFichierTexte(fic,'	% draw the moves');
  err := WritelnDansFichierTexte(fic,'	/Utopia-Bold findfont 12 scalefont setfont');
  err := WritelnDansFichierTexte(fic,'	(1) E6 move_black');
  err := WritelnDansFichierTexte(fic,'	(2) F4 move_white');
  err := WritelnDansFichierTexte(fic,'	(3) C3 move_black');
  err := WritelnDansFichierTexte(fic,'	(4) C4 move_white');
  err := WritelnDansFichierTexte(fic,'	(5) D3 move_black');
  err := WritelnDansFichierTexte(fic,'	(6) D6 move_white');
  err := WritelnDansFichierTexte(fic,'	(7) E3 move_black');
  err := WritelnDansFichierTexte(fic,'	(8) C2 move_white');
  err := WritelnDansFichierTexte(fic,'	(9) B3 move_black');
  err := WritelnDansFichierTexte(fic,'');
  
  WriteCoupsPartieEPSDansFichier := err;
end;



function WritePositionEtTraitEnEPSDansFichier(position : PositionEtTraitRec;fic : FichierTEXT) : OSErr;
var fichierEtaitOuvertEnArrivant : boolean;
    err : OSErr;
begin
  err := NoErr;
  
  fichierEtaitOuvertEnArrivant := FichierTexteEstOuvert(fic);
  if not(fichierEtaitOuvertEnArrivant) then err := OuvreFichierTexte(fic);
  
  err := WritePrologueEPSDansFichier(fic);
  
  err := WritelnDansFichierTexte(fic,'% do the drawing');
  err := WritelnDansFichierTexte(fic,'gsave');
  err := WritelnDansFichierTexte(fic,'');
  err := WritelnDansFichierTexte(fic,'	% draw an empty board');
  err := WritelnDansFichierTexte(fic,'	board_coord');
  err := WritelnDansFichierTexte(fic,'	board_grid');
  err := WritelnDansFichierTexte(fic,'');
  
  err := WriteDescriptionPositionEPSDansFichier(position,fic);
  {err := WriteCoupsPartieEPSDansFichier(fic);}
  
  
  err := WritelnDansFichierTexte(fic,'grestore');

  if not(fichierEtaitOuvertEnArrivant) then err := FermeFichierTexte(fic);
    
  
  WritePositionEtTraitEnEPSDansFichier := err;
end;


end.