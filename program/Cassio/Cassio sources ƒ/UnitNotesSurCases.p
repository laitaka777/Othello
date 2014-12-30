UNIT UnitNotesSurCases;



INTERFACE







USES UnitOth0,UnitSquareSet;

const 
      kNotesDeCassio        = 1;
      kNotesDeZebra         = 2;
      kNotesDeCassioEtZebra = 255;

      (* Attention, il est critique que les quatre constantes
         ci-dessous soient des multiples de 100 *)
      kNoteSurCaseNonDisponible     = -10000000;
      kNoteSpecialeSurCasePourPerte = -2000000;
      kNoteSpecialeSurCasePourNulle =  0;
      kNoteSpecialeSurCasePourGain  =  2000000;
      
      

{initialisation}
procedure InitUnitNotesSurCases;
procedure LibereMemoireUnitNotesSurCases;

{activation/desactivation}
procedure SetAvecAffichageNotesSurCases(origine : SInt32;flag : boolean);
procedure SetPoliceNameNotesSurCases(origine : SInt32;whichPoliceName : str255);
procedure SetTailleNotesSurCases(origine : SInt32;whichTaille : SInt16);
function GetAvecAffichageNotesSurCases(origine : SInt32) : boolean;
function GetPoliceNameNotesSurCases(origine : SInt32) : str255;
function GetPoliceIDNotesSurCases(origine : SInt32) : SInt16; 
function GetTailleNotesSurCases(origine : SInt32) : SInt16; 

{procedures d'ecriture}
procedure ViderNotesSurCases(origine : SInt32;effacer : boolean;surQuellesCases : SquareSet);
procedure SetNoteSurCase(origine : SInt32;whichSquare : SInt16; whichNote : SInt32);
procedure SetNoteMilieuSurCase(origine : SInt32;whichSquare : SInt16; whichNote : SInt32);
procedure SetMeilleureNoteSurCase(origine : SInt32;whichSquare : SInt16; whichNote : SInt32);
procedure SetMeilleureNoteMilieuSurCase(origine : SInt32;whichSquare : SInt16; whichNote : SInt32);

{procedures de lecture}
function GetNoteSurCase(origine : SInt32;whichSquare : SInt16) : SInt32;
function GetSquareOfMeilleureNoteSurCase(origine : SInt32; var whichSquare : SInt16; var whichNote : SInt32) : boolean;
function EstLaMeilleureCaseDesNotesSurCase(origine : SInt32;whichSquare : SInt16) : boolean;
function CaseALaMeilleureDesNotes(origine : SInt32;whichSquare : SInt16) : boolean;
function EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(whichNote : SInt32) : boolean;

{procedures de dessin}
procedure EffaceNoteSurCases(origine : SInt32;surQuellesCases : SquareSet);
procedure DessineNoteSurCases(origine : SInt32;surQuellesCases : SquareSet);
function GetRectAffichageCouleurZebra(whichSquare : SInt32) : rect;


IMPLEMENTATION







USES UnitOth1,UnitBufferedPICT,UnitRapport,UnitTroisiemeDimension,SNStrings,
     Zebra_to_Cassio,UnitAfficheArbreDeJeuCourant,UnitGestionDuTemps,UnitCouleur;

type NotesDurCaseRec = record
                       meilleureCase : SInt16; 
                       meilleureNote : SInt32;
                       table_notes : array[11..88] of SInt32;
                       policeName : str255;
                       policeID : SInt16; 
                       policeSize : SInt16; 
                       doitAfficher : boolean;
                     end;

var gNotesSurCases : array[kNotesDeCassio..kNotesDeZebra] of NotesDurCaseRec;
    
                     

procedure InitUnitNotesSurCases;
begin
  ViderNotesSurCases(kNotesDeCassio,false,othellierToutEntier);
  SetPoliceNameNotesSurCases(kNotesDeCassio,'Geneva');
  SetTailleNotesSurCases(kNotesDeCassio,9);  {par defaut}
  
  ViderNotesSurCases(kNotesDeZebra,false,othellierToutEntier);
  SetPoliceNameNotesSurCases(kNotesDeZebra,'Geneva');
  SetTailleNotesSurCases(kNotesDeZebra,9);  {par defaut}
end;

procedure LibereMemoireUnitNotesSurCases;
begin
end;

procedure SetPoliceIDNotesSurCases(origine : SInt32;whichPolice : SInt16);
begin
  gNotesSurCases[origine].policeID := whichPolice;
end;

procedure SetPoliceNameNotesSurCases(origine : SInt32;whichPoliceName : str255);
var theID : SInt16; 
begin
  EnleveEspacesDeGaucheSurPlace(whichPoliceName);
  if (whichPoliceName <> '') then
    begin
		  GetFNum(whichPoliceName, theID);
		  
		  gNotesSurCases[origine].policeName := whichPoliceName;
		  SetPoliceIDNotesSurCases(origine,theID);
		end;
end;

procedure SetTailleNotesSurCases(origine : SInt32;whichTaille : SInt16);
begin
  if (whichTaille > 4) then
    gNotesSurCases[origine].policeSize := whichTaille;
end;

function GetPoliceIDNotesSurCases(origine : SInt32) : SInt16; 
begin
  GetPoliceIDNotesSurCases := gNotesSurCases[origine].policeID;
end;

function GetPoliceNameNotesSurCases(origine : SInt32) : str255;
begin
  GetPoliceNameNotesSurCases := gNotesSurCases[origine].policeName;
end;

function GetTailleNotesSurCases(origine : SInt32) : SInt16; 
begin
  GetTailleNotesSurCases := gNotesSurCases[origine].policeSize;
end;



procedure SetAvecAffichageNotesSurCases(origine : SInt32;flag : boolean);
begin
  gNotesSurCases[origine].doitAfficher := flag;
end;


function GetAvecAffichageNotesSurCases(origine : SInt32) : boolean;
begin
  if (origine = kNotesDeCassioEtZebra)
    then GetAvecAffichageNotesSurCases := GetAvecAffichageNotesSurCases(kNotesDeCassio) | 
                                          GetAvecAffichageNotesSurCases(kNotesDeZebra)
    else GetAvecAffichageNotesSurCases := gNotesSurCases[origine].doitAfficher;
end;


procedure ViderNotesSurCases(origine : SInt32;effacer : boolean;surQuellesCases : SquareSet);
var i : SInt32;
    accumulateur : SquareSet;
begin

 {WritelnDansRapport('Je suis dans ViderNotesSurCases');
  WritelnStringAndNumDansRapport('origine = ',origine);}

  if (origine = kNotesDeCassioEtZebra)
    then
      begin
        ViderNotesSurCases(kNotesDeCassio,effacer,surQuellesCases);
        ViderNotesSurCases(kNotesDeZebra,effacer,surQuellesCases);
      end
    else
      begin
        with gNotesSurCases[origine] do
          begin
            meilleureCase := 0;
            meilleureNote := kNoteSurCaseNonDisponible;
            
            accumulateur := [];
            for i := 11 to 88 do
              begin
                
                if effacer & (i in surQuellesCases) & 
                   GetAvecAffichageNotesSurCases(origine) &
                   (table_notes[i] <> kNoteSurCaseNonDisponible)
                  then accumulateur := accumulateur + [i];
                  
                table_notes[i] := kNoteSurCaseNonDisponible;
              end;
            
            if (accumulateur <> []) then
              EffaceNoteSurCases(origine,accumulateur);
          end;
        end;
end;



procedure SetNoteSurCase(origine : SInt32;whichSquare : SInt16; whichNote : SInt32);
var oldMeilleureCase : SInt16; 
    old_note,oldMeilleureNote : SInt32;
begin
  with gNotesSurCases[origine] do
  if (whichSquare >= 11) & (whichSquare <= 88) &
     ((whichNote = kNoteSurCaseNonDisponible) |
      (whichNote = kNoteSpecialeSurCasePourPerte) |
      (whichNote = kNoteSpecialeSurCasePourNulle) |
      (whichNote = kNoteSpecialeSurCasePourGain) |
      ((whichNote >= -6400) & (whichNote <= 6400)))
    then
	    begin
	      old_note := table_notes[whichSquare];
	      table_notes[whichSquare] := whichNote;
	      
	      if whichNote > meilleureNote then
	        begin
	          oldMeilleureCase := meilleureCase;
	          oldMeilleureNote := meilleureNote;
	          
	          meilleureNote := whichNote;
	          meilleureCase := whichSquare;
	          
	          if GetAvecAffichageNotesSurCases(origine) & 
	             ((oldMeilleureNote <> kNoteSurCaseNonDisponible) | 
	              (meilleureCase = oldMeilleureCase) & (meilleureNote <> kNoteSurCaseNonDisponible))  then
	            begin
	            
	              if (oldMeilleureNote <> meilleureNote) |
	                 (oldMeilleureCase <> meilleureCase)
	                then EffaceNoteSurCases(origine,[oldMeilleureCase]);
	                
	              if (meilleureCase <> oldMeilleureCase) 
	                then DessineNoteSurCases(origine,[oldMeilleureCase]);
	                
	            end;
	        end;
	       
	      if GetAvecAffichageNotesSurCases(origine) then 
	        begin
	        
	          if (old_note <> kNoteSurCaseNonDisponible) &
	             (old_note <> whichNote) 
	            then EffaceNoteSurCases(origine,[whichSquare]);
	            
	          if (whichNote <> kNoteSurCaseNonDisponible) 
	            then DessineNoteSurCases(origine,[whichSquare]);
	            
	        end;
     end;
end;

procedure SetNoteMilieuSurCase(origine : SInt32;whichSquare : SInt16; whichNote : SInt32);
begin
  if (origine = kNotesDeCassio) 
    then
      begin
        if (whichNote = 0) 
          then whichNote := 1;      {on remplace 0.00 par O.O1 pour eviter les pb de nulle}
      end
    else
  if (origine = kNotesDeZebra)
    then
      begin
        if (whichNote mod 100 = 0) then 
          if whichNote >= 0
            then dec(whichNote)
            else inc(whichNote);
      end;
  
  SetNoteSurCase(origine,whichSquare,whichNote);
end;


function GetNoteSurCase(origine : SInt32;whichSquare : SInt16) : SInt32;
begin
  with gNotesSurCases[origine] do
    begin
		  if (whichSquare >= 11) & (whichSquare <= 88)
		    then GetNoteSurCase := table_notes[whichSquare]
		    else GetNoteSurCase := kNoteSurCaseNonDisponible;
		end;
end;

procedure SetMeilleureNoteSurCase(origine : SInt32;whichSquare : SInt16; whichNote : SInt32);
var oldMeilleureCase : SInt16; 
    oldMeilleureNote : SInt32;
begin
  with gNotesSurCases[origine] do
    begin
      oldMeilleureNote := meilleureNote;
      oldMeilleureCase := meilleureCase;
      
		  if (whichSquare >= 11) & (whichSquare <= 88) &
		     ((whichNote = kNoteSurCaseNonDisponible) |
          (whichNote = kNoteSpecialeSurCasePourPerte) |
          (whichNote = kNoteSpecialeSurCasePourNulle) |
          (whichNote = kNoteSpecialeSurCasePourGain) |
          ((whichNote >= -6400) & (whichNote <= 6400)))
		    then table_notes[whichSquare] := whichNote
		    else whichNote := kNoteSurCaseNonDisponible;
		    
		  meilleureNote := whichNote;
		  meilleureCase := whichSquare;
		  
		  if GetAvecAffichageNotesSurCases(origine) then
		    begin
		    
    		  if (oldMeilleureNote <> meilleureNote) |
	           (oldMeilleureCase <> meilleureCase)
	          then EffaceNoteSurCases(origine,[oldMeilleureCase]);
	          
          if (meilleureCase <> oldMeilleureCase) & 
             (GetNoteSurCase(origine,oldMeilleureCase) <> kNoteSurCaseNonDisponible)
            then DessineNoteSurCases(origine,[oldMeilleureCase]);
            
        end;
		
		
		  if GetAvecAffichageNotesSurCases(origine) then 
		    begin
		    
		      if (oldMeilleureNote <> meilleureNote) |
			       (oldMeilleureCase <> meilleureCase)
			      then EffaceNoteSurCases(origine,[whichSquare]);
			      
		      if (whichNote <> kNoteSurCaseNonDisponible)
		        then DessineNoteSurCases(origine,[whichSquare]);
		        
		    end;
		    
    end;
end;

procedure SetMeilleureNoteMilieuSurCase(origine : SInt32;whichSquare : SInt16; whichNote : SInt32);
begin
  if (origine = kNotesDeCassio)
    then
      begin
        if whichNote = 0 then whichNote := 1;        {0.00 -> 0.01 pour eviter les pb de nulle}
      end
    else
      begin
        if (whichNote mod 100 = 0) then 
          if whichNote >= 0
            then dec(whichNote)
            else inc(whichNote);
      end;
  
  SetMeilleureNoteSurCase(origine,whichSquare,whichNote);
end;

function GetSquareOfMeilleureNoteSurCase(origine : SInt32; var whichSquare : SInt16; var whichNote : SInt32) : boolean;
begin
  with gNotesSurCases[origine] do
    begin
      if (meilleureCase >= 11) & (meilleureCase <= 88)
        then
          begin
            GetSquareOfMeilleureNoteSurCase := true;
            whichSquare := meilleureCase;
            whichNote := meilleureNote;
          end
        else
          begin
            GetSquareOfMeilleureNoteSurCase := false;
            whichSquare := 0;
            whichNote := kNoteSurCaseNonDisponible;
          end;
    end;
end;


function EstLaMeilleureCaseDesNotesSurCase(origine : SInt32;whichSquare : SInt16) : boolean;
begin
  with gNotesSurCases[origine] do
    begin
      if (meilleureCase >= 11) & (meilleureCase <= 88)
        then EstLaMeilleureCaseDesNotesSurCase := (whichSquare = meilleureCase)
        else EstLaMeilleureCaseDesNotesSurCase := false;
    end;
end;


function CaseALaMeilleureDesNotes(origine : SInt32;whichSquare : SInt16) : boolean;
begin
  with gNotesSurCases[origine] do
    begin
      if (meilleureCase >= 11) & (meilleureCase <= 88) & (meilleureNote <> kNoteSurCaseNonDisponible)
        then CaseALaMeilleureDesNotes := (table_notes[whichSquare] = meilleureNote)
        else CaseALaMeilleureDesNotes := false;
    end;
end;


function EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(whichNote : SInt32) : boolean;
begin
  EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra := (whichNote mod 100) <> 0;
end;



procedure EffaceNoteSurCases(origine : SInt32;surQuellesCases : SquareSet);
var i : SInt32;
    tempoDoitAfficherNotesSurCases : boolean;
    accumulateur : SquareSet;
begin

  
 {WritelnDansRapport('entree dans EffaceNoteSurCases : ');
  WritelnStringAndNumDansRapport('  origine = ',origine);
  WriteDansRapport('  surQuellesCases = ');
  WritelnDansRapport(SquareSetEnString(surQuellesCases));}
  
  
  case origine of
    kNotesDeCassio : if (BitAnd(GetEffacageProprietesOfCurrentNode(),kNotesCassioSurLesCases) = 0) then exit(EffaceNoteSurCases);
    kNotesDeZebra  : if (BitAnd(GetEffacageProprietesOfCurrentNode(),kNotesZebraSurLesCases) = 0)  then exit(EffaceNoteSurCases);
  end; {case}
  

  with gNotesSurCases[origine] do
    begin
      accumulateur := [];
      
      for i := 11 to 88 do
        if (i in surQuellesCases) & (JeuCourant[i] = pionVide) & (GetOthellierEstSale(i)) then
          begin
            accumulateur := accumulateur + [i];
          end;
          
      
      if (accumulateur <> []) then
        begin
		      tempoDoitAfficherNotesSurCases := GetAvecAffichageNotesSurCases(origine);
		      SetAvecAffichageNotesSurCases(origine,false);
		      
		      for i := 11 to 88 do
		        if i in accumulateur then
		          InvalidateDessinEnTraceDeRayon(i);
		          
		      if aideDebutant
				    then DessineAideDebutant(true,accumulateur)
				    else EffaceAideDebutant(true,true,accumulateur);
				    
				  SetAvecAffichageNotesSurCases(origine,tempoDoitAfficherNotesSurCases);
				end;
    end;
  
  
 {WriteDansRapport('  -> accumulateur = ');
  WritelnDansRapport(SquareSetEnString(accumulateur));
  WritelnDansRapport('sortie dans EffaceNoteSurCases : ');}
  
  
end;


function NoteSurCaseEnString(origine : SInt32;valeur : SInt32) : str255;
var s,s1,s2 : str255;
    v,v1,v2 : SInt32;
begin

  s := '';
	            
  if (valeur <> kNoteSurCaseNonDisponible) then
    begin
      if (origine = kNotesDeCassio)
        then
          begin
            if valeur = kNoteSpecialeSurCasePourNulle then GetIndString(s,TextesPlateauID,28) else  {gagne}
            if valeur = kNoteSpecialeSurCasePourGain  then GetIndString(s,TextesPlateauID,26) else  {perd}
            if valeur = kNoteSpecialeSurCasePourPerte then GetIndString(s,TextesPlateauID,27)  {nulle}
              else 
                begin
                  s := NumEnString((Abs(valeur) + 49) div 100);
                  if (valeur < 0) & (s <> '0') then
                    s := Concat('-',s);
                end;
          end else
      if (origine = kNotesDeZebra)
        then
          begin
            if valeur = kNoteSpecialeSurCasePourNulle then GetIndString(s,TextesPlateauID,28) else  {gagne}
            if valeur = kNoteSpecialeSurCasePourGain  then GetIndString(s,TextesPlateauID,26) else  {perd}
            if valeur = kNoteSpecialeSurCasePourPerte then GetIndString(s,TextesPlateauID,27)  {nulle}
              else 
                begin
    	            v := Abs(valeur);
    	            
    	            v1 := v div 100;
    	            v2 := v mod 100;
    	            
    	            if (v2 = 0)
    	              then s := NumEnString(v1)
    	              else
    	                begin
    	                  if (v2 = 1) then v2 := 0 else
    	                  if (v2 = 99) then 
    	                    begin
    	                      inc(v1);
    	                      v2 := 0;
    	                    end;
    	                    
          	            s1 := NumEnString(v1);
          	            if (v2 >= 5) 
          	              then 
          	                begin
          	                  if (v2 <= 85)
          	                    then s2 := NumEnString((v2 + 5) div 10)
          	                    else s2 := '9';
          	                end
          	              else s2 := '0' {+ NumEnString(v2)};
          	            
          	            s := s1 + '.' + s2;
          	          end;
    	            
    	            
    	            if (valeur < 0) & (s <> '0.0') then
    	               s := Concat('-',s);
    	          end;
          end;
    end;
  
  
  NoteSurCaseEnString := s;
end;


procedure EcritNoteSurCase(origine,whichSquare,valeur : SInt32; var s : str255);
var oldPort : grafPtr;
    noteCassio,noteZebra : SInt32;
    pasAfficherCassio,pasAfficherZebra : boolean;
    noteSurLePionDore : boolean;
    myRect : rect;
begin

  with gNotesSurCases[origine] do
    begin
    
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      
      
      noteSurLePionDore := false;
      if (GetValeurDessinEnTraceDeRayon(whichSquare) = pionSuggestionDeCassio) |
         ((BAND(GetAffichageProprietesOfCurrentNode(),kSuggestionDeCassio) <> 0) &
          (afficheSuggestionDeCassio | gDoitJouerMeilleureReponse | SuggestionAnalyseDeFinaleEstDessinee()) & 
          (GetBestSuggestionDeCassio() = whichSquare))
        then noteSurLePionDore := true;
        
          
      if CassioEstEn3D() & noteSurLePionDore
        then myRect := GetRect3DDessus(whichSquare)
        else myRect := GetBoundingRectOfSquare(whichSquare);
      if (myRect.bottom - myRect.top) >= 32 then InSetRect(myRect,0,1);
      if CassioEstEn3D()
        then InSetRect(myRect,4,0)
        else InSetRect(myRect,1,0);
      if noteSurLePionDore & not(CassioEstEn3D()) then 
        if Length(s) >= 4
          then OffSetRect(myRect,0,-6)
          else OffSetRect(myRect,0,-4);
        
      
      if EstLaMeilleureCaseDesNotesSurCase(origine,whichSquare) |
         ((origine = kNotesDeZebra) & CaseALaMeilleureDesNotes(origine,whichSquare) & EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(valeur))
        then 
          begin
            if {not(noteSurLePionDore) & }
               (CassioEstEn3D() | gCouleurOthellier.estUneTexture | RGBColorEstFoncee(gCouleurOthellier.RGB,20000))
              then ForeColor(cyanColor)  {pour les fonds foncŽs : note en bleu}
              else ForeColor(redColor);  {pour les fonds clairs : note en rouge}
          end
        else
          begin
            if valeur >= 0
              then ForeColor(yellowColor)
              else ForeColor(whiteColor);
          end;

      {TextSize(policeSize+3);}
      TextSize(policeSize);
      TextFont(policeID);
      TextFace(bold);
        
      
      noteCassio := GetNoteSurCase(kNotesDeCassio,whichSquare);
      noteZebra := GetNoteSurCase(kNotesDeZebra,whichSquare);
      
      
      pasAfficherZebra  := (noteZebra = kNoteSurCaseNonDisponible) | 
                           not(ZebraBookACetteOption(kAfficherNotesZebraSurOthellier)) |
                           (BAND(GetAffichageProprietesOfCurrentNode(),kNotesZebraSurLesCases) = 0);
                           
      pasAfficherCassio := {(noteCassio = kNoteSurCaseNonDisponible) |}
                           (BAND(GetAffichageProprietesOfCurrentNode(),kNotesCassioSurLesCases) = 0);
      
      
        
      if (noteCassio = noteZebra) | 
         ((origine = kNotesDeCassio) & pasAfficherZebra) | 
         ((origine = kNotesDeZebra) & pasAfficherCassio {& not(EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(valeur))})
        then
          DrawJustifiedStringInRect(myRect,pionNoir,s,kJusticationCentreHori+kJusticationBas,whichSquare)
        else
          if (origine = kNotesDeCassio)
            then DrawJustifiedStringInRect(myRect,pionNoir,s,kJusticationGauche+kJusticationBas,whichSquare)
            else DrawJustifiedStringInRect(myRect,pionNoir,s,kJusticationDroite+kJusticationBas,whichSquare);
            
       ForeColor(BlackColor);
    	 SetPort(oldPort);
  
  end;
end;


function GetRectAffichageCouleurZebra(whichSquare : SInt32) : rect;
var theRect : rect;
    retrecissement : SInt32;
begin
  theRect := GetBoundingRectOfSquare(whichSquare);
  retrecissement := Min(15, GetTailleCaseCourante() div 4);
  if CassioEstEn3D()
    then
      begin
        InsetRect(theRect,retrecissement-2,retrecissement-3);
        OffSetRect(theRect,0,1);
      end
    else
      InsetRect(theRect,retrecissement,retrecissement);
  GetRectAffichageCouleurZebra := theRect;
end;


procedure DessineCouleurDeZebraDansSaCase(whichSquare,valeur : SInt32);
var oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(wPlateauPtr);
  DessineCouleurDeZebraBookDansRect(GetRectAffichageCouleurZebra(whichSquare),aQuiDeJouer,valeur);
  SetPort(oldPort);
end;

procedure DessineNoteSurCases(origine : SInt32;surQuellesCases : SquareSet);
var valeur,tempo : SInt32;
    i : SInt16; 
    s : str255;
    accumulateur : SquareSet;
    casesColorees : SquareSet;
    err : OSErr;
    
begin

  case origine of
    kNotesDeCassio : 
      begin
        if (BitAnd(GetAffichageProprietesOfCurrentNode(),kNotesCassioSurLesCases) = 0) then exit(DessineNoteSurCases);
      end;
    kNotesDeZebra  : 
      begin
        if (BitAnd(GetAffichageProprietesOfCurrentNode(),kNotesZebraSurLesCases) = 0)  then exit(DessineNoteSurCases);
        if not(ZebraBookACetteOption(kAfficherNotesZebraSurOthellier+kAfficherCouleursZebraSurOthellier)) then exit(DessineNoteSurCases);
      end;
  end; {case}


  with gNotesSurCases[origine] do
    if windowPlateauOpen & (wPlateauPtr <> NIL) then
	    begin
	      if gCassioUseQuartzAntialiasing then
	        begin
	          err := SetAntiAliasedTextEnabled(false,9);
	          DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	        end;
	      
	      accumulateur := [];
	      casesColorees := [];
	      
	      for i := 11 to 88 do
	        if (i in surQuellesCases) & (JeuCourant[i] = pionVide) then
	          begin
	            valeur := GetNoteSurCase(origine,i);
	            s := NoteSurCaseEnString(origine,valeur);
	              
	            if (s = '') & GetOthellierEstSale(i)
	              then
	                accumulateur := accumulateur + [i]
	              else
		              begin
				            SetOthellierEstSale(i,true);
				            
				            if (origine = kNotesDeZebra) & 
    				           ZebraBookACetteOption(kAfficherNotesZebraSurOthellier)
				              then EcritNoteSurCase(origine,i,valeur,s);
				            
				            if (origine = kNotesDeCassio)
    				          then EcritNoteSurCase(origine,i,valeur,s);
    				        
    				        if (origine = kNotesDeZebra) & 
    				           ZebraBookACetteOption(kAfficherCouleursZebraSurOthellier) &
    				           EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(valeur) then
    				          begin
    				            casesColorees := casesColorees + [i];
    				            DessineCouleurDeZebraDansSaCase(i,valeur);
    				          end;
				            
				            
				          end;
	            
	          end;
	          
	      if gCassioUseQuartzAntialiasing then
	        begin
	          err := SetAntiAliasedTextEnabled(true,9);
	          EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);
	        end;
	        
	      if (accumulateur <> []) then
	        EffaceNoteSurCases(origine,accumulateur);
	        
	      if (casesColorees <> []) then
	        begin
	          tempo := GetAffichageProprietesOfCurrentNode();
		        SetAffichageProprietesOfCurrentNode(kAideDebutant + kPierresDeltas + kBibliotheque + kProchainCoup);
	          AfficheProprietesOfCurrentNode(false,casesColorees,'DessineAutresInfosSurCasesAideDebutant');
	          SetAffichageProprietesOfCurrentNode(tempo);
	        end;
	        
	      if gCassioUseQuartzAntialiasing then
	        begin
	          err := SetAntiAliasedTextEnabled(true,9);
	          EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);
	        end;
      end;
end;







END.