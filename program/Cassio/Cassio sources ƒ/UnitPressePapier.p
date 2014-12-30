UNIT UnitPressePapier;


INTERFACE







USES UnitOth0,UnitFichiersTEXT;

function PeutCollerPartie(var positionStandard : boolean; var partieEnAlpha : str255) : boolean; 
function DumpPressePapierToFile(var fic : FichierTEXT) : OSErr;
function EstUnNomDeFichierTemporaireDePressePapier(const nom : str255) : boolean;



IMPLEMENTATION







USES UnitScannerOthellistique,UnitOth2,UnitSetUp,UnitNormalisation,UnitRapport,UnitCarbonisation,
     UnitServicesDialogs,MyStrings,UnitServicesMemoire,UnitMacExtras,UnitOth1,UnitPhasesPartie,SNStrings;



function PeutCollerPartie(var positionStandard : boolean; var partieEnAlpha : str255) : boolean; 
type DeuxChar = packed array[0..1] of char;
var result : SInt32;
    hdest : handle;
    pointeurDeCaractere:^DeuxChar;
    offset : SInt32;
    longueur,longueurMaximale : SInt32;
    i,compteur : SInt32;
    dernierCaractereRecu,c : char;
    attendUneLettre,attendUnChiffre : boolean;
    CollerPartieOK : boolean;
    partieRecue,texteBrut : str255;
    err : OSErr;
    longueurDuTexteDansLePressePapier : SInt32;
    longueur1,longueur2,longueur3,longueur4 : SInt32;
    
		 procedure RecoitCaractere(c : char);
		 begin
		   if IsLower(c) then c := chr(ord(c)-32);
		   if attendUneLettre 
		     then
		       begin
		         if CharInRange(c,'A','H') then 
		           begin
		             attendUneLettre := false;
		             attendUnChiffre := true;
		           end
		       end
		     else
		       begin
		         if CharInRange(c,'1','8') & CharInRange(dernierCaractereRecu,'A','H') then 
		           begin
		             partieRecue     := partieRecue + dernierCaractereRecu + c;
		             attendUneLettre := true;
		             attendUnChiffre := false;
		           end
		       end;
		   dernierCaractereRecu := c;
		 end;
 
 
    function NombreCoupsRejouables(chaine : str255) : SInt32;
    begin
      if EstUnePartieOthelloAvecMiroir(chaine)
        then NombreCoupsRejouables := Length(chaine) div 2
        else NombreCoupsRejouables := 0;
    end;
 
 
		function InterpreterPartie(chaine : str255) : OSErr;
		begin
		  {WritelnDansRapport('dans interpreterPartie , chaine = '+chaine);}
		  InterpreterPartie := -1;
			if EstUnePartieOthelloAvecMiroir(chaine)
		    then 
		      begin
		        InterpreterPartie := NoErr;
		        if PeutArreterAnalyseRetrograde() then
		          begin
		            PlaquerPartieLegale(chaine,kNePasRejouerLesCoupsEnDirect);
		            if not(HumCtreHum) & not(CassioEstEnModeAnalyse()) then DoChangeHumCtreHum;
		            
		            positionStandard := true;
		            partieEnAlpha := chaine;
		          end;
		      end
		end;

begin
  CollerPartieOK := false;
  positionStandard := true;
  partieEnAlpha := '';
  longueurDuTexteDansLePressePapier := GetScrapSize('TEXT');
  
  if enRetour | enSetUp | (longueurDuTexteDansLePressePapier <= 0) then
    begin
      PeutCollerPartie := true;
      exit(PeutCollerPartie);
    end;
    
  if not(enRetour | enSetUp) then
    begin
      hdest := AllocateMemoryHdl(3000);
      if (hdest <> NIL)
        then 
          result := MyGetScrap(hdest,'TEXT',offset)
        else 
          begin
            result := -1;
            AlerteSimple('Je ne peux pas allouer la mémoire pour lire le presse-papier');
          end;
      if (result < 0)  {data of that type doesn't exist in the scrap}
        then 
          begin
            PeutCollerPartie := false;
            exit(PeutCollerPartie);
          end
        else 
          begin
            attendUneLettre := true;
            attendUnChiffre := false;
            partieRecue     := '';
            texteBrut       := '';
            compteur        := 0;
            
            HLockHi(hdest);
            longueur := result;
            pointeurDeCaractere := MakeMemoryPointer(ord4(hdest^));
            
            if (longueurDuTexteDansLePressePapier <= 2900) then
	            for i := 0 to longueurDuTexteDansLePressePapier do
                begin
                  c :=  pointeurDeCaractere^[i];
                  if (compteur < 255) & (CharInRange(c,'1','8') | CharInRange(c,'a','h') | CharInRange(c,'A','H')) then 
                    begin
                      inc(compteur);
                      texteBrut := texteBrut + c;
                    end;
                end;
            
            dernierCaractereRecu := chr(0);
            for i := 1 to (longueur div 2) do
              begin
                RecoitCaractere(pointeurDeCaractere^[0]);
                RecoitCaractere(pointeurDeCaractere^[1]);
                pointeurDeCaractere := MakeMemoryPointer(ord4(pointeurDeCaractere)+2);
              end;
            if odd(longueur) then
              RecoitCaractere(pointeurDeCaractere^[0]);
            HUnlock(hdest);
            
            
            if (longueurDuTexteDansLePressePapier <= 0)
              then CollerPartieOK := true
              else
                begin
			            err := -1;
			            
			            { On essaie maintenant de rejouer la partie. Parmi toutes les 
			              possibilites, on essaie de rejouer la plus longue }
			            longueur1 := 0;
			            longueur2 := 0;
			            longueur3 := 0;
			            longueur4 := 0;
			            
			            if (Length(texteBrut) >= 2)   then longueur1 := NombreCoupsRejouables(texteBrut);
	                if (Length(texteBrut) >= 2)   then longueur2 := NombreCoupsRejouables(PartiePourPressePapier(false,false,nbreCoup)+texteBrut);
			            if (Length(partieRecue) >= 2) then longueur3 := NombreCoupsRejouables(partieRecue);
			            if (Length(partieRecue) >= 2) then longueur4 := NombreCoupsRejouables(PartiePourPressePapier(false,false,nbreCoup)+partieRecue);	
			            
			            longueurMaximale := Max(Max(longueur1,longueur2),Max(longueur3,longueur4));
			            
			            if (longueurMaximale > 0) then
			              begin
    			            if (err <> 0) & (longueurMaximale = longueur1) then err := InterpreterPartie(texteBrut);
    	                if (err <> 0) & (longueurMaximale = longueur2) then err := InterpreterPartie(PartiePourPressePapier(false,false,nbreCoup)+texteBrut);
    			            if (err <> 0) & (longueurMaximale = longueur3) then err := InterpreterPartie(partieRecue);
    			            if (err <> 0) & (longueurMaximale = longueur4) then err := InterpreterPartie(PartiePourPressePapier(false,false,nbreCoup)+partieRecue);		
			              end;
			            	            
			            CollerPartieOK := (err = 0);
			          end;
            
          end;
      if (hdest <> NIL) then DisposeMemoryHdl(hdest);
    end;
   PeutCollerPartie := CollerPartieOK;
end;


procedure InfosPressePapierDansRapport;
{$IFC CARBONISATION_DE_CASSIO }
begin
end;
{$ELSEC}
var infos:ScrapStuffPtr;
begin
  WritelnDansRapport('avant UnloadScrap()');
  infos := NIL;
  

  infos := InfoScrap();


  if infos <> NIL then
    with infos^ do
    begin
      WritelnStringAndNumDansRapport('scrapSize = ',scrapSize);
      WritelnStringAndNumDansRapport('scrapHandle = ',SInt32(scrapHandle));
      WritelnStringAndNumDansRapport('scrapCount = ',scrapCount);
      WritelnStringAndNumDansRapport('scrapState = ',scrapState);
      if (scrapName = NIL)
        then WritelnStringDansRapport('scrapName = NIL')
        else WritelnStringDansRapport('scrapName = '+scrapName^);
    end;
  
  if (UnloadScrap() = NoErr) then;
  
  WritelnDansRapport('après UnloadScrap()');


  infos := InfoScrap();

  
  if infos <> NIL then
    with infos^ do
    begin
      WritelnStringAndNumDansRapport('scrapSize = ',scrapSize);
      WritelnStringAndNumDansRapport('scrapHandle = ',SInt32(scrapHandle));
      WritelnStringAndNumDansRapport('scrapCount = ',scrapCount);
      WritelnStringAndNumDansRapport('scrapState = ',scrapState);
      if (scrapName = NIL)
        then WritelnStringDansRapport('scrapName = NIL')
        else WritelnStringDansRapport('scrapName = '+scrapName^);
    end;
    
end;
{$ENDC}



function DumpPressePapierToFile(var fic : FichierTEXT) : OSErr;
var longRand,taille,nouvelleTaille : SInt32;
    offset,count : SInt32;
    myError : OSErr;
    name : str255;
    hdest : handle;
    dataPtr : Ptr;
    state : SignedByte;
begin
  myError := -1;
  
  {InfosPressePapierDansRapport;}
  
  taille := GetScrapSize('TEXT');
  if (taille > 0) then
    begin
      {fabriquer un nom de fichier nouveau}
      RandomizeTimer;
      longRand := RandomLongint();
      name := 'clipboard_'+NumEnString(Abs(longRand));
      
      {decharger le presse papier sur le disque}
      if (UnloadScrap() = NoErr) then;
      
      {allouer un petit handle, qui sera agrandi si necessaire}
      hdest := AllocateMemoryHdl(100);
      
      nouvelleTaille := -1;
      if (hdest <> NIL)
        then nouvelleTaille := MyGetScrap(hdest,'TEXT',offset);
      
      
      if (nouvelleTaille < 0)
        then
          begin  {echec !}
            myError := nouvelleTaille;
          end 
        else
          begin  {ok, nouvelleTaille est la taille des donnes de type TEXT dans le presse-papier}
            state := HGetState(hdest);
            HLock(hdest);
            dataPtr := Ptr(Ord4(@hdest^^));
            
            count := nouvelleTaille;
            
            myError := CreeFichierTexteDeCassio(name,fic);
            {WritelnStringAndNumDansRapport('apres CreeFichierTexteDeCassio('+name+'), myError = ',myError);}
            
            if (myError = NoErr) then myError := OuvreFichierTexte(fic);
            {WritelnStringAndNumDansRapport('apres OuvreFichierTexte('+name+'), myError = ',myError);}
            
            if (myError = NoErr) then myError := WriteBufferDansFichierTexte(fic,dataPtr,count);
            {WritelnStringAndNumDansRapport('apres WriteBufferDansFichierTexte('+name+'), myError = ',myError);}
            
            if (myError = NoErr) then myError := FermeFichierTexte(fic);
            {WritelnStringAndNumDansRapport('apres FermeFichierTexte('+name+'), myError = ',myError);}
            
            HSetState(hdest,state);
          end;
          
      if (hdest <> NIL) then DisposeMemoryHdl(hdest);
    end;
    
  DumpPressePapierToFile := myError;
end;


function EstUnNomDeFichierTemporaireDePressePapier(const nom : str255) : boolean;
begin
  EstUnNomDeFichierTemporaireDePressePapier := (Pos('clipboard_',nom) > 0);
end;











END.