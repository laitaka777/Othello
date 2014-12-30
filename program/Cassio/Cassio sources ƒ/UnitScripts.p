UNIT UnitScripts;


INTERFACE







USES MyTypes,UnitPositionEtTrait;


var dernierProblemeStepnanovAffiche : SInt32;

{Initialisation et libération de l'unité}
procedure InitUnitScripts;
procedure LibereMemoireUnitScripts;


{Gestion des fichiers au format Othello script}
function EstUnScriptDeFinales(nomFichier : str255;vRefNum : SInt16) : boolean;
function CreateEndgameScript(nomDeLaBase : str255) : OSErr;
function OuvrirEndgameScript(nomScript : str255) : OSErr;
function ScriptDeFinaleEnCours() : boolean;


{Quelques utilitaires}
function ExtraitPositionEtTraitDeLaListeEnString(numeroReference : SInt32;apresQuelCoup : SInt32; var typeErreur : SInt32) : str255;
function CreateResultStringForScript(score : SInt32; var positionEtTrait : PositionEtTraitRec;endgameSolveFlags : SInt32) : str255;


{Problemes de Stepanov}
procedure GenererCycleDesProblemesDeStepanov;
function ProcessProblemesStepanov(nomScript : str255;quelProbleme : SInt32) : OSErr;
procedure AfficheProchainProblemeStepanov;
procedure CreerQuizEnPHP(nomQuizGenerique : str255;numeroQuiz : SInt32;positionQuiz : PositionEtTraitRec;coupSolution : SInt32;commentaire : str255);
procedure CreerPositionQuizzEnJPEG(nomJPEG : str255;positionQuiz : PositionEtTraitRec);



IMPLEMENTATION







USES UnitAffichageReflexion,UnitAccesStructuresNouvFormat,UnitSetUp,UnitEPS,UnitHTML,
     UnitDialog,MyFileSystemUtils,UnitServicesDialogs,MyStrings,UnitOth2,UnitOth1,SNStrings,
     UnitRapport,UnitFinalePourPositionEtTrait,UnitFichiersTEXT,UnitScannerOthellistique,
     UnitNouvelleEval,UnitGestionDuTemps;


const kNbTotalDeQuiz = 100;

var pathFichierProblemesStepanov : str255;
    permutationDesNumerosDeQuiz : array[1..kNbTotalDeQuiz] of SInt32;
    gScriptDeFinaleEnCours : boolean;


procedure GenererCycleDesProblemesDeStepanov;
const kValeurSpeciale = -100; 
      kCelluleVide = -1;
var i,a,n,compteur,j,premierAntecedant : SInt32;
begin

  {generer le cycle aleatoire pour la page FFO}
    
  for i := 1 to kNbTotalDeQuiz do 
    permutationDesNumerosDeQuiz[i] := kCelluleVide;
  SetQDGlobalsRandomSeed(2);  {initialiser le generateur aleatoire}
  
  a := kValeurSpeciale;
  for i := 1 to kNbTotalDeQuiz do
    begin
      n := RandomEntreBornes(1,kNbTotalDeQuiz-i+1);
      
      compteur := 0;
      j := 1;
      repeat
        if permutationDesNumerosDeQuiz[j] = kCelluleVide then inc(compteur);
        if (compteur < n) then inc(j);
      until (j >= kNbTotalDeQuiz) | (compteur >= n);
      
      permutationDesNumerosDeQuiz[j] := a;
      if a = kValeurSpeciale then premierAntecedant := j;
      a := j;
      
    end;
  
  permutationDesNumerosDeQuiz[premierAntecedant] := a;
    
  RandomizeTimer;
end;


procedure InitUnitScripts;

begin
  dernierProblemeStepnanovAffiche := 0;
  pathFichierProblemesStepanov := '';
  gScriptDeFinaleEnCours := false;
  
  GenererCycleDesProblemesDeStepanov;
end;


procedure LibereMemoireUnitScripts;
begin
end;

function EstUnScriptDeFinales(nomFichier : str255;vRefNum : SInt16) : boolean;
begin
  {$UNUSED vRefNum}
  EstUnScriptDeFinales := NoCasePos('.script',nomFichier) > 0;
end;


function ExtraitPositionEtTraitDeLaListeEnString(numeroReference : SInt32;apresQuelCoup : SInt32; var typeErreur : SInt32) : str255;
var s60 : PackedThorGame;
begin
  ExtraitPositionEtTraitDeLaListeEnString := '';
  typeErreur := kPartieOK;
  
  if (numeroReference>0) & (numeroReference<=nbPartiesActives) then
    begin
      ExtraitPartieTableStockageParties(numeroReference,s60);
      ExtraitPositionEtTraitDeLaListeEnString := PositionEtTraitAfterMoveEnString(s60,apresQuelCoup,typeErreur);
    end;
end; 
          
  

function CreateEndgameScript(nomDeLaBase : str255) : OSErr;
const kApresQuelCoup=40;
var n,k : SInt32;
    script : FichierTEXT;
    err : OSErr;
    reply : SFReply;
    nomfichier,theLine,s : str255;
    mySpec : FSSpec;
    myDate : DateTimeRec;
    explicationRejetPartie : SInt32;
begin
  err := -1;
  if windowListeOpen & (nbPartiesActives>0) then
    begin
		  s := ReadStringFromRessource(TextesDiversID,2);   {'sans titre'}
		  reply.fname := s;
		  if MakeFileName(reply,'Nom de la base à scripter ?',mySpec) then
		      begin
		        
		        nomDeLaBase := reply.fName;
		        
		        nomfichier := reply.fName+'.script';
		        err := FichierTexteExisteFSp(MyMakeFSSpec(mySpec.vRefNum,mySpec.parID,nomfichier),script);
		        if err=fnfErr then err := CreeFichierTexteFSp(MyMakeFSSpec(mySpec.vRefNum,mySpec.parID,nomfichier),script);
		        if err=0 then
		          begin
		            err := OuvreFichierTexte(script);
		            err := VideFichierTexte(script);
		          end;
		        if err <> 0 then
		          begin
		            AlerteSimpleFichierTexte(nomFichier,err);
		            err := FermeFichierTexte(script);
		            CreateEndgameScript := err;
		            exit(CreateEndgameScript);
		          end;
		          
		        
		        theLine := '% File '+nomfichier;
		        err := WritelnDansFichierTexte(script,theLine);
		        GetTime(myDate);
		        theLine := '% Endgame script created by '+GetApplicationName('Cassio');
		        err := WritelnDansFichierTexte(script,theLine);
		        theLine := '% '+NumEnString(myDate.year)+'-'+
		                      NumEnString(myDate.month)+'-'+
		                      NumEnString(myDate.day);
		        err := WritelnDansFichierTexte(script,theLine);
		        theLine := '% All positions in this script are generated after move '+NumEnString(kApresQuelCoup)+', but this is not a requirement of the script format';
		        err := WritelnDansFichierTexte(script,theLine);
		        err := WritelnDansFichierTexte(script,'%');
		        
		        watch := GetCursor(watchcursor);
            SafeSetCursor(watch);
		          
		        for k := 1 to Min(1000,nbPartiesActives) do
		          begin
		            
		            
		           {n := k;}
		            n := RandomLongintEntreBornes(1,nbPartiesActives);
		            
		            theLine := ExtraitPositionEtTraitDeLaListeEnString(n,kApresQuelCoup,explicationRejetPartie);
		            
		            if (theLine<>'') & (explicationRejetPartie=kPartieOK)
		              then 
		                err := WritelnDansFichierTexte(script,theLine+' % '+nomDeLaBase+' after '+NumEnString(kApresQuelCoup)+' #'+NumEnString(n))
		              else
		                begin
		                  (*
		                  case explicationRejetPartie of
		                    kPartieIllegale :
		                      err := WritelnDansFichierTexte(script,'% illegal game : '+nomDeLaBase+' #'+NumEnString(n));
		                    kPartieTropCourte :
		                      err := WritelnDansFichierTexte(script,'% game too short : '+nomDeLaBase+' #'+NumEnString(n));
		                  end;
		                  *)
		                end;
		          end;
		        
		        err := WritelnDansFichierTexte(script,'%');
		        err := WritelnDansFichierTexte(script,'% End of the endgame script');
		          
		        err := FermeFichierTexte(script);
		        SetFileCreatorFichierTexte(script,'CWIE'); 
		        SetFileTypeFichierTexte(script,'TEXT');
		      end;
		end;
  AjusteCurseur;
  CreateEndgameScript := err;
end;





function CreateResultStringForScript(score : SInt32; var positionEtTrait : PositionEtTraitRec;endgameSolveFlags : SInt32) : str255;
var result,s1,s2 : str255;
    scorePourNoir : SInt32;
    onlyWLD,withOptimalLine : boolean;
begin

  onlyWLD            := BitAnd(endgameSolveFlags,kEndgameSolveOnlyWLD) <> 0;
  withOptimalLine    := BitAnd(endgameSolveFlags,kEndgameSolveToujoursRamenerLaSuite) <> 0;
      
  result := '';
  if GetTraitOfPosition(positionEtTrait) = pionNoir
    then scorePourNoir := score
    else scorePourNoir := -score;
  
  if onlyWLD
    then
      begin
			  if scorePourNoir>0 then result := 'Black win      ' else
			  if scorePourNoir=0 then result := 'Draw           ' else
			  if scorePourNoir<0 then result := 'White win      ';
      end
    else
      begin
			  s1 := NumEnString(32+(scorePourNoir div 2));
			  if Length(s1)=1 then s1 := Concat(' ',s1);
			  s2 := NumEnString(32-(scorePourNoir div 2));
			  if Length(s2)=1 then s2 := Concat(' ',s2);
			  result := s1+' - '+s2+'      ';
      end;
  
  if withOptimalLine then
    result := result + MeilleureSuiteInfosEnChaine(1,false,false,false,false,0)+'      ';
  
  CreateResultStringForScript := result;
end;


function OuvrirEndgameScript(nomScript : str255) : OSErr;
{ attention! On doit être dans le bon repertoire, ou nomfichier doit etre un path complet }
const kCassioCommandPrompt = '% TELL CASSIO : ';
var ligne,NomOutputScript,comment,s,result : str255;
    erreurES : OSErr;
    inputScript,outputScript : FichierTEXT;
    score,positionCommentaire : SInt32;
    positionEtTrait : PositionEtTraitRec;
    ticks,tempsPourCettePositionsEnSecondes,tempsTotalEnSecondes : SInt32;
    tempsMaximumEnSecondes,nbPositionsResolues : SInt32;
    endgameSolveFlags : SInt32;
    
    
  procedure InterpreterCommandePourCassioDansFichierScript(ligne : str255);
  begin
    if (Pos(kCassioCommandPrompt,ligne) > 0) then
      begin
        ligne := TPCopy(ligne,Pos(kCassioCommandPrompt,ligne) + Length(kCassioCommandPrompt),255);
        
        if (Pos('WRITE ',ligne) > 0) then
          WritelnDansRapport(TPCopy(ligne,Pos('WRITE ',ligne) + Length('WRITE '),255));
        
        if (Pos('SET WLD = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveOnlyWLD) = 0 
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveOnlyWLD;
        
        if (Pos('SET WLD = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveOnlyWLD) <> 0 
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveOnlyWLD;
        
        if (Pos('SET EXACT = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveOnlyWLD) = 0 
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveOnlyWLD;
        
        if (Pos('SET EXACT = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveOnlyWLD) <> 0 
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveOnlyWLD;
        
        if (Pos('SET LINE = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveToujoursRamenerLaSuite) = 0 
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveToujoursRamenerLaSuite;
        
        if (Pos('SET LINE = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveToujoursRamenerLaSuite) <> 0 
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveToujoursRamenerLaSuite;
        
        if (Pos('SET POSITION = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveEcrirePositionDansRapport) = 0 
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveEcrirePositionDansRapport;
        
        if (Pos('SET POSITION = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveEcrirePositionDansRapport) <> 0 
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveEcrirePositionDansRapport;
        
        if (Pos('SET ECHO = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveEcrireInfosTechniquesDansRapport) = 0 
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveEcrireInfosTechniquesDansRapport;
        
        if (Pos('SET ECHO = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveEcrireInfosTechniquesDansRapport) <> 0 
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveEcrireInfosTechniquesDansRapport;
        
      end;
  end;
  
begin
  OuvrirEndgameScript := NoErr;  {pas encore de gestion d'erreurs :-( }
  
  
  if CassioEstEnTrainDeReflechir() then
    begin
      AlerteDoitInterompreReflexionPourFaireScript;
      exit(OuvrirEndgameScript);
    end;
  
  
  (* On met les valeurs par défaut pour les drapeaux de résolution de la finale.
     Ces valeurs pourront être changées par des commandes trouvées dans le 
     script lui-même.
   *)
  
  endgameSolveFlags := 0;
					        
  if (nbreCoup > 20) & (phaseDeLaPartie < phaseFinaleParfaite) then
    endgameSolveFlags := endgameSolveFlags + kEndgameSolveOnlyWLD;
  
  if afficheMeilleureSuite then
    endgameSolveFlags := endgameSolveFlags + kEndgameSolveToujoursRamenerLaSuite; 
  
  if InfosTechniquesDansRapport then
    endgameSolveFlags := endgameSolveFlags + kEndgameSolveEcrireInfosTechniquesDansRapport;
					          
  
  if ScriptDeFinaleEnCours() | 
     not(PeutArreterAnalyseRetrograde()) then 
    exit(OuvrirEndgameScript);

  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  
  if not(GetNouvelleEvalDejaChargee()) then
    EssayerLireFichiersEvaluationDeCassio;
  
  if (nomScript = '') then 
    begin
      AlerteSimpleFichierTexte(nomScript,0);
      exit(OuvrirEndgameScript);
    end;
  {SetDebuggageUnitFichiersTexte(false);}
  
  NomOutputScript := nomScript+'.output';

  erreurES := FichierTexteExiste(nomScript,0,inputScript);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomScript,erreurES);
      exit(OuvrirEndgameScript);
    end;
     
  erreurES := OuvreFichierTexte(inputScript);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomScript,erreurES);
      exit(OuvrirEndgameScript);
    end;
  
  erreurES := FichierTexteExiste(NomOutputScript,0,outputScript);
  if erreurES=fnfErr then erreurES := CreeFichierTexte(NomOutputScript,0,outputScript);
  if erreurES=0 then
    begin
      erreurES := OuvreFichierTexte(outputScript);
      erreurES := VideFichierTexte(outputScript);
    end;
  if erreurES <> 0 then
    begin
      AlerteSimpleFichierTexte(NomOutputScript,erreurES);
      erreurES := FermeFichierTexte(outputScript);
      exit(OuvrirEndgameScript);
    end;
		          
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(NomOutputScript,erreurES);
      exit(OuvrirEndgameScript);
    end;
   
   
  gScriptDeFinaleEnCours := true;
  nbPositionsResolues := 0;
  tempsTotalEnSecondes := 0;
  tempsMaximumEnSecondes := 0;
  erreurES := NoErr;
  ligne := '';
  while not(EOFFichierTexte(inputScript,erreurES)) &
        (Pos('% End of the endgame script',ligne)=0) &
        not(EscapeDansQueue()) do
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
  
      erreurES := ReadlnDansFichierTexte(inputScript,s);
      ligne := s;
      ligne := EnleveEspacesDeGauche(ligne);
      if (ligne='') | (ligne[1]='%') 
        then
          begin
            erreurES := WritelnDansFichierTexte(outputScript,s);
            if (Pos(kCassioCommandPrompt,ligne) > 0) then InterpreterCommandePourCassioDansFichierScript(ligne);
          end
        else
          begin
            if ParsePositionEtTrait(ligne,positionEtTrait) & (GetTraitOfPosition(positionEtTrait) <> pionVide)
              then
                begin
                  positionCommentaire := Pos('%',ligne);
                  if positionCommentaire>0
                    then comment := TPCopy(ligne,positionCommentaire,Length(ligne)-positionCommentaire+1)
                    else comment := '';
                   
                  
                  ticks := TickCount();
                  if Quitter
                    then score := -1000     {or any impossible score <-64 or > 64}
                    else score := DoEndgameSolve(positionEtTrait,endgameSolveFlags);
                  
                  
                  if (interruptionReflexion <> pasdinterruption) | Quitter | (score<-64) | (score>64)
                    then result := '?? - ??      '
                    else
                      begin
                        
                        result := CreateResultStringForScript(score,positionEtTrait,endgameSolveFlags);
                        
                        inc(nbPositionsResolues);
                        tempsPourCettePositionsEnSecondes := (TickCount()-ticks) div 60;
                        tempsTotalEnSecondes := tempsTotalEnSecondes+tempsPourCettePositionsEnSecondes;
                        if tempsPourCettePositionsEnSecondes>tempsMaximumEnSecondes then tempsMaximumEnSecondes := tempsPourCettePositionsEnSecondes;
                        
                        if (nbPositionsResolues <> 0) & ((nbPositionsResolues mod 50)=0) then
                          begin
                            WritelnDansRapport('après '+NumEnString(nbPositionsResolues)+' positions résolues :');
                            WritelnStringAndReelDansRapport('   temps moyen en sec : ',1.0*tempsTotalEnSecondes/nbPositionsResolues,3);
                            WritelnStringAndNumDansRapport('   temps maximum en sec : ',tempsMaximumEnSecondes);
                          end;
                        
                      end;
                  erreurES := WritelnDansFichierTexte(outputScript,result+comment);
                end
              else
                begin
                  erreurES := WritelnDansFichierTexte(outputScript,'% Parse error for the following line :');
                  erreurES := WritelnDansFichierTexte(outputScript,'% '+s);
                end;
          end;
    end;
  
  erreurES := FermeFichierTexte(inputScript);
  erreurES := FermeFichierTexte(outputScript);
  
  gScriptDeFinaleEnCours := false;
  AjusteCurseur;
end;


function ScriptDeFinaleEnCours() : boolean;
begin
  ScriptDeFinaleEnCours := gScriptDeFinaleEnCours;
end;


procedure CreerQuizEnPHP(nomQuizGenerique : str255;numeroQuiz : SInt32;positionQuiz : PositionEtTraitRec;coupSolution : SInt32;commentaire : str255);
var fichierPHP : FichierTEXT;
    zoneMemoirePHP : ZoneMemoire;
    erreurES : OSErr;
    s,nom_solution : str255;
    a : SInt32;
    nomQuiz : str255;
    positionSolution : PositionEtTraitRec;
    positionEssai : PositionEtTraitRec;
    i,j,square : SInt32;
    
    
  function FabriquerNomAutreQuiz(numero : SInt32) : str255;
  var s : str255;
  begin
    s := ParamStr('stepanov_^0.php',NumEnString(numero),'','','');
    FabriquerNomAutreQuiz := s;
  end;
    
    
    
begin {CreerQuizEnPHP}

  a := permutationDesNumerosDeQuiz[numeroQuiz];
  
  nomQuizGenerique := ReplaceStringByStringInString('problemes_stepanov','stepanov',nomQuizGenerique);
  nomQuiz := ParamStr(nomQuizGenerique,NumEnString(numeroQuiz),'','','');
  
  
  erreurES := FichierTexteExiste(nomQuiz,0,fichierPHP);
  if erreurES=fnfErr then erreurES := CreeFichierTexte(nomQuiz,0,fichierPHP);
  if erreurES=0 then
    begin
      erreurES := OuvreFichierTexte(fichierPHP);
      erreurES := VideFichierTexte(fichierPHP);
      
      
      erreurES := FSSpecToFullPath(fichierPHP.theFSSpec,s);
      s := ReplaceStringByStringInString(fichierPHP.theFSSpec.name,'quiz_prologue.php',s);
      erreurES := InsererFichierDansFichierTexte(fichierPHP,s);
      
      
      nom_solution := ReplaceStringByStringInString('.php','_^0.php',fichierPHP.theFSSpec.name);
     
     
     
      
      FermerFichierEtFabriquerZoneMemoire(fichierPHP,zoneMemoirePHP);
      
      if GetTraitOfPosition(positionQuiz) = pionBlanc
        then erreurES := WritePositionEtTraitEnHTMLDansZoneMemoire(positionQuiz,zoneMemoirePHP,
                                           '<div class="diagramme">',
                                           '</div>',
                                           '<img src="bb.gif" width="24" height="24">',
                                           '<img src="ww.gif" width="24" height="24">',
                                           '<a href="'+nom_solution+'"><img src="ee.gif" width="24" height="24" border="0"></a>',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="top.gif" width="224" height="16">',
                                           '<img src="top.gif" width="224" height="16"><br />',
                                           '<img src="^0^1.gif" width="16" height="24">',
                                           '<img src="^0^1.gif" width="16" height="24"><br />',
                                           '<span><br><b>Probl&egrave;me '+NumEnString(numeroQuiz)+'</b></span>'
                                          )
         else erreurES := WritePositionEtTraitEnHTMLDansZoneMemoire(positionQuiz,zoneMemoirePHP,
                                           '<div class="diagramme">',
                                           '</div>',
                                           '<img src="bb.gif" width="24" height="24">',
                                           '<img src="ww.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<a href="'+nom_solution+'"><img src="ee.gif" width="24" height="24" border="0"></a>',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="top.gif" width="224" height="16">',
                                           '<img src="top.gif" width="224" height="16"><br />',
                                           '<img src="^0^1.gif" width="16" height="24">',
                                           '<img src="^0^1.gif" width="16" height="24"><br />',
                                           '<span><br><b>Probl&egrave;me '+NumEnString(numeroQuiz)+'</b></span>'
                                          );
      
      DisposeZoneMemoireEtOuvrirFichier(fichierPHP,zoneMemoirePHP);                              
      
      ErreurES := WritelnDansFichierTexte(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');
      
      ErreurES := WritelnDansFichierTexte(fichierPHP,'</td>');
                                     
      
      ErreurES := WritelnDansFichierTexte(fichierPHP,'<td width="15">');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'</td>');

      ErreurES := WritelnDansFichierTexte(fichierPHP,'<td valign="top">');
      
      ErreurES := WritelnDansFichierTexte(fichierPHP,'<p align="center">&nbsp;</p>');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'<p align="center">&nbsp;</p>');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'<p align="center">&nbsp;</p>');
      
      ErreurES := WritelnDansFichierTexte(fichierPHP,'<p>');
      if GetTraitOfPosition(positionQuiz) = pionNoir
        then ErreurES := WritelnDansFichierTexte(fichierPHP,'Trait &agrave; <b>Noir</b>.')
        else ErreurES := WritelnDansFichierTexte(fichierPHP,'Trait &agrave; <b>Blanc</b>.');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'Cliquez sur le bon coup !</p>');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'</td>');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'</tr>');
      
      ErreurES := WritelnDansFichierTexte(fichierPHP,'</table>');

                  
      ErreurES := WritelnDansFichierTexte(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');

      ErreurES := WritelnDansFichierTexte(fichierPHP,'<hr>');

      ErreurES := WritelnDansFichierTexte(fichierPHP,'<p class="menu-navigation-rapide">');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'[<a href="'+FabriquerNomAutreQuiz(permutationDesNumerosDeQuiz[numeroQuiz])+'">Autre quiz</a>] - [<a href="../index.php">Retour &agrave; l''accueil');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'</a>]');
      ErreurES := WritelnDansFichierTexte(fichierPHP,'</p>');

                                  
                                          
      erreurES := FSSpecToFullPath(fichierPHP.theFSSpec,s);
      s := ReplaceStringByStringInString(fichierPHP.theFSSpec.name,'quiz_epilogue.php',s);
      erreurES := InsererFichierDansFichierTexte(fichierPHP,s);
      
      erreurES := FermeFichierTexte(fichierPHP);
    end;
    
  
    
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        square := i*10 + j;
        positionEssai    := positionQuiz;
        positionSolution := positionQuiz;
        
        if UpdatePositionEtTrait(positionEssai,square) & UpdatePositionEtTrait(positionSolution,coupSolution) then
          begin
            
            
            nomQuiz := ParamStr(nomQuizGenerique,NumEnString(numeroQuiz)+'_'+CoupEnStringEnMinuscules(square),'','','');
  
  
            erreurES := FichierTexteExiste(nomQuiz,0,fichierPHP);
            if erreurES=fnfErr then erreurES := CreeFichierTexte(nomQuiz,0,fichierPHP);
            if erreurES=0 then
              begin
                erreurES := OuvreFichierTexte(fichierPHP);
                erreurES := VideFichierTexte(fichierPHP);
                
                
                erreurES := FSSpecToFullPath(fichierPHP.theFSSpec,s);
                s := ReplaceStringByStringInString(fichierPHP.theFSSpec.name,'quiz_prologue.php',s);
                erreurES := InsererFichierDansFichierTexte(fichierPHP,s);
                
                
                nom_solution := ReplaceStringByStringInString('.php','_^0.php',fichierPHP.theFSSpec.name);
               
               


                if (square = CoupSolution) 
                  then
                    begin
                    
                    
                      FermerFichierEtFabriquerZoneMemoire(fichierPHP,zoneMemoirePHP);
                      erreurES := WritePositionEtTraitPageWebFFODansZoneMemoire(positionEssai,'<span><br><b>Bravo !</b></span>',zoneMemoirePHP);
                      DisposeZoneMemoireEtOuvrirFichier(fichierPHP,zoneMemoirePHP);    
                      
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');  
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');
                      
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'</td>');
      
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<td width="15">');
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'</td>');
                    
                    
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<td valign="top">');
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<p align="center">&nbsp;</p>');
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<p align="center">&nbsp;</p>');
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<p align="center">&nbsp;</p>');
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<p><b>Bravo</b> !');
                      
                      FermerFichierEtFabriquerZoneMemoire(fichierPHP,zoneMemoirePHP);
                      ErreurES := WritelnEnHTMLDansZoneMemoire(zoneMemoirePHP,commentaire);
                      DisposeZoneMemoireEtOuvrirFichier(fichierPHP,zoneMemoirePHP);  
                      
                      
      
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'</td>');
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'</tr>');
                      
                      
                    end
                  else
                    begin
                    
                      FermerFichierEtFabriquerZoneMemoire(fichierPHP,zoneMemoirePHP);
                      erreurES := WritePositionEtTraitPageWebFFODansZoneMemoire(positionEssai,'<span><br><b>Rat&eacute;</b></span>',zoneMemoirePHP);
                      DisposeZoneMemoireEtOuvrirFichier(fichierPHP,zoneMemoirePHP);    
                      
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');
                      
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'</td>');
                    
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'<td width="50%" valign="top">');
                      
                      FermerFichierEtFabriquerZoneMemoire(fichierPHP,zoneMemoirePHP);
                      erreurES := WritePositionEtTraitPageWebFFODansZoneMemoire(positionSolution,'<span><br />'+StringEnHTML(commentaire)+'</span>',zoneMemoirePHP);
                      DisposeZoneMemoireEtOuvrirFichier(fichierPHP,zoneMemoirePHP);  
                                                     
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'</td>');
                      
                      ErreurES := WritelnDansFichierTexte(fichierPHP,'</tr>');
                    
                      
                    end;
                
                              
                ErreurES := WritelnDansFichierTexte(fichierPHP,'</table>');
                
                

                ErreurES := WritelnDansFichierTexte(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');

                ErreurES := WritelnDansFichierTexte(fichierPHP,'<hr>');

                ErreurES := WritelnDansFichierTexte(fichierPHP,'<p class="menu-navigation-rapide">');
                ErreurES := WritelnDansFichierTexte(fichierPHP,'[<a href="'+FabriquerNomAutreQuiz(permutationDesNumerosDeQuiz[numeroQuiz])+'">Autre quiz</a>] - [<a href="../index.php">Retour &agrave; l''accueil');
                ErreurES := WritelnDansFichierTexte(fichierPHP,'</a>]');
                ErreurES := WritelnDansFichierTexte(fichierPHP,'</p>');
                                                    
                                            
                                                    
                erreurES := FSSpecToFullPath(fichierPHP.theFSSpec,s);
                s := ReplaceStringByStringInString(fichierPHP.theFSSpec.name,'quiz_epilogue.php',s);
                erreurES := InsererFichierDansFichierTexte(fichierPHP,s);
                
                erreurES := FermeFichierTexte(fichierPHP);
              end;
    
          end;
      end;   
end;



procedure CreerPositionQuizzEnJPEG(nomJPEG : str255;positionQuiz : PositionEtTraitRec);
var fichierJPEG : FichierTEXT;
    erreurES : OSErr;
    path : str255;
begin
  SplitRightBy(nomJPEG,':',path,nomJPEG);
  WritelnDansRapport('nomJPEG = '+nomJPEG);
  
  erreurES := FichierTexteDeCassioExiste(nomJPEG,fichierJPEG);
  if erreurES=fnfErr then erreurES := CreeFichierTexteDeCassio(nomJPEG,fichierJPEG);
  if erreurES=0 then
    begin
      erreurES := OuvreFichierTexte(fichierJPEG);
      erreurES := VideFichierTexte(fichierJPEG);
      erreurES := FermeFichierTexte(fichierJPEG);
      
      WritelnStringAndNumDansRapport('CreerPositionQuizzEnJPEG : avant CreateJPEGImageOfPosition, erreurES = ',erreurES);
      CreateJPEGImageOfPosition(positionQuiz,fichierJPEG.theFSSpec);
    end;
end;



function ProcessProblemesStepanov(nomScript : str255;quelProbleme : SInt32) : OSErr;
var ligne,comment : str255;
    s1,s2,s3,s4,s5,s6,reste : str255;
    erreurES : OSErr;
    inputScript : FichierTEXT;
    (* fichierEPS : FichierTEXT;
    nomFichierEPS : str255; *)
    nomFichierPHP : str255;
    positionCommentaire : SInt32;
    positionEtTrait : PositionEtTraitRec;
    ticks,tempsPourCettePositionsEnSecondes,tempsTotalEnSecondes : SInt32;
    tempsMaximumEnSecondes,nbProblemesTraites : SInt32;
    arretPoblemesStepanov : boolean;
    foo : SInt16; 
    coupDeLaSolution : SInt32;
    traitDeLaSolution : SInt32;
    buffer : packed array[0..1023] of char;
    count,nbEspacesEnleves : SInt32;
begin
   ProcessProblemesStepanov := NoErr;  {pas encore de gestion d'erreurs :-( }
  
  if not(PeutArreterAnalyseRetrograde()) then 
    exit(ProcessProblemesStepanov);
    
    
  if nomScript='' then 
    begin
      AlerteSimpleFichierTexte(nomScript,0);
      exit(ProcessProblemesStepanov);
    end;
  {SetDebuggageUnitFichiersTexte(false);}
  

  erreurES := FichierTexteExiste(nomScript,0,inputScript);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomScript,erreurES);
      exit(ProcessProblemesStepanov);
    end;
     
  erreurES := OuvreFichierTexte(inputScript);
  if erreurES<>NoErr then 
    begin
      AlerteSimpleFichierTexte(nomScript,erreurES);
      exit(ProcessProblemesStepanov);
    end;
  
		          
  
  pathFichierProblemesStepanov := nomScript;
   
  nbProblemesTraites := 0;
  tempsTotalEnSecondes := 0;
  tempsMaximumEnSecondes := 0;
  erreurES := NoErr;
  ligne := '';
  arretPoblemesStepanov := false;
  while not(arretPoblemesStepanov) &
        not(EOFFichierTexte(inputScript,erreurES)) &
        (Pos('% End of the endgame script',ligne)=0) do
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
      
      
      count := 1024;
      erreurES := ReadlnBufferDansFichierTexte(inputScript,@buffer[0],count);
      
      {on enleve les espaces au debut de la ligne}
      EnleveEtCompteCeCaractereAGaucheDansBuffer(@buffer[0],count,' ',nbEspacesEnleves);
  
      
      if (count >= 70) & (buffer[0]<>'%')  then
          begin
          
            ligne := BufferToPascalString(@buffer[0],0, 69);
            
            {WritelnDansRapport(ligne);}
            if ParsePositionEtTrait(ligne,positionEtTrait) & (GetTraitOfPosition(positionEtTrait) <> pionVide)
              then
                begin
                
                
                  comment := BufferToPascalString(@buffer[0], 66, count-1);
                  
                  
                  positionCommentaire := Pos('%',comment);
                  if positionCommentaire>0
                    then 
                      begin
                        
                        
                        comment := TPCopy(comment,positionCommentaire,Length(comment)-positionCommentaire+1);
                        
                        Parser6(comment,s1,s2,s3,s4,s5,s6,reste);
                        
                        coupDeLaSolution := ScannerStringPourTrouverCoup(1,s3,foo);
                        traitDeLaSolution := GetTraitOfPosition(positionEtTrait);
                        
                        {WritelnDansRapport(reste);}
                        Parser5(reste,s1,s2,s3,s4,s5,reste);
                        {WritelnDansRapport(reste);}
                        
                      end
                    else 
                      begin
                        comment := '';
                        reste := '';
                        coupDeLaSolution := -1;
                      end;
                   
                  
                  
                  inc(nbProblemesTraites);
                  
                  
                  
                  ticks := TickCount();
                  
                  if not(Quitter) & (nbProblemesTraites = quelProbleme) then 
                    begin
                      dernierProblemeStepnanovAffiche := quelProbleme;
                      PlaquerPosition(positionEtTrait.position,GetTraitOfPosition(positionEtTrait),kRedessineEcran);
                      
                      WritelnStringAndNumDansRapport('Problème numéro ',nbProblemesTraites);
                      {WritelnDansRapport('   commentaire = ' + comment);}
                      
                      tempsPourCettePositionsEnSecondes := (TickCount()-ticks) div 60;
                      tempsTotalEnSecondes := tempsTotalEnSecondes+tempsPourCettePositionsEnSecondes;
                      if tempsPourCettePositionsEnSecondes>tempsMaximumEnSecondes then tempsMaximumEnSecondes := tempsPourCettePositionsEnSecondes;
                      
                      
                      (* On ecrit le diagramme de la position dans un fichier EPS *)
                      (*
                      nomFichierEPS := ReplaceStringByStringInString('.script','_',nomScript);
                      nomFichierEPS := nomFichierEPS + NumEnString(nbProblemesTraites) + '.eps';
                      
                      erreurES := FichierTexteExiste(nomFichierEPS,0,fichierEPS);
										  if erreurES=fnfErr then erreurES := CreeFichierTexte(nomFichierEPS,0,fichierEPS);
										  if erreurES=0 then
										    begin
										      erreurES := OuvreFichierTexte(fichierEPS);
										      erreurES := VideFichierTexte(fichierEPS);
										      erreurES := WritePositionEtTraitEnEPSDansFichier(positionEtTrait,fichierEPS);
										      erreurES := FermeFichierTexte(fichierEPS);
										    end;
                      *)
                      
                      (* On ecrit le diagramme de la position dans un fichier quiz PHP *)
                      nomFichierPHP := ReplaceStringByStringInString('.script','_^0.php',nomScript);
                      CreerQuizEnPHP(nomFichierPHP,nbProblemesTraites,positionEtTrait,coupDeLaSolution,reste);
                      
                      (* On cree l'imagette JPEG de la solution *)
                      (*
                      CreerPositionQuizzEnJPEG(ParamStr(ReplaceStringByStringInString('.script','_^0.jpg',nomScript),NumEnString(nbProblemesTraites),'','',''),positionEtTrait); 
                      *)
                      
                      
                      (* On écrit le diagramme de la solution dans un autre fichier EPS *)
                      (*
                      if UpdatePositionEtTrait(positionEtTrait, coupDeLaSolution)
                        then
                          begin
			                      nomFichierEPS := ReplaceStringByStringInString('.script','_sol_',nomScript);
			                      nomFichierEPS := nomFichierEPS + NumEnString(nbProblemesTraites) + '.eps';
			                      
			                      erreurES := FichierTexteExiste(nomFichierEPS,0,fichierEsPS);
													  if erreurES=fnfErr then erreurES := CreeFichierTexte(nomFichierEPS,0,fichierEPS);
													  if erreurES=0 then
													    begin
													      erreurES := OuvreFichierTexte(fichierEPS);
													      erreurES := VideFichierTexte(fichierEPS);
													      erreurES := WritePositionEtTraitEnEPSDansFichier(positionEtTrait,fichierEPS);
													      erreurES := FermeFichierTexte(fichierEPS);
													    end;
													end
											  else
											    begin
											      WritelnStringAndNumDansRapport('WARNING : solution illégale ('+CoupEnStringEnMinuscules(coupDeLaSolution)+') dans le problème numéro ', nbProblemesTraites);
											    end;
										 *)
											    
                        
                     (* Ecriture du code TeX dans le rapport *)
                     (*
                     WritelnDansRapport('\includegraphics[scale=1.75]{problemes_stepanov_'+NumEnString(nbProblemesTraites)+'}');
                     case traitDeLaSolution of
                       pionNoir  : WritelnDansRapport('\\ Noir');
                       pionBlanc : WritelnDansRapport('\\ Blanc');
                     end;
                     WritelnDansRapport('\newpage');
                     WritelnDansRapport('\includegraphics[scale=0.75]{problemes_stepanov_sol_'+NumEnString(nbProblemesTraites)+'}');
                     WritelnDansRapport('\\ '+reste);
                     WritelnDansRapport('\vspace{0.75in}');
                     WritelnDansRapport('');
                     *)
                     
                      
                      if (nbProblemesTraites >= quelProbleme)
                        then arretPoblemesStepanov := true;
                    end;
                    
                  
                  
                end
              else
                begin
                  WritelnDansRapport('% Parse error for the following line :');
                  WriteDansRapport('% ');
                  InsereTexteDansRapport(@buffer[0],count);
                  WritelnDansRapport('');
                end;
          end;
    end;
  
  erreurES := FermeFichierTexte(inputScript);
  
  AjusteCurseur;
end;


procedure AfficheProchainProblemeStepanov;
var err : OSErr;
begin
  err := ProcessProblemesStepanov(pathFichierProblemesStepanov,dernierProblemeStepnanovAffiche + 1);
end;

END.