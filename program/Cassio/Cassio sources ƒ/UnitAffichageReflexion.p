UNIT UnitAffichageReflexion;



INTERFACE







uses UnitOth0;


const kValeurSpecialeDansReflPourPerdant = -1;
      kCertitudeSpecialPourPointInterrogation = -999;


{ Fenetre de reflexion }
procedure EffaceReflexion;
procedure ReinitilaliseInfosAffichageReflexion;
procedure SetNbLignesScoresCompletsCetteProf(var reflexionInfos:ReflexRec;nbLignes : SInt16);
procedure SetNbLignesScoresCompletsProfPrecedente(var reflexionInfos:ReflexRec;nbLignes : SInt16);
function GetNbLignesScoresCompletsCetteProf(var reflexionInfos:ReflexRec) : SInt16; 
function GetNbLignesScoresCompletsProfPrecedente(var reflexionInfos:ReflexRec) : SInt16; 
function DeltaFinaleEnChaine(delta : SInt32) : str255;
procedure EcritReflexion;      
procedure LanceDemandeAffichageReflexion(forcerAffichageImmediat : boolean);
procedure SetDemandeAffichageReflexionEnSuspend(flag : boolean);


{ Fenetre de gestion du temps }
procedure SetValeursGestionTemps(alloue,effectif,prevu : SInt32;divergence : extended;prof,suivante : SInt16);
procedure EcritGestionTemps;
procedure LanceChronoCetteProf;
procedure LanceChrono;
procedure LanceDecompteDesNoeuds;
procedure AffichageNbreNoeuds;   


{ Meilleure suite en dessous de l'othellier }
procedure SauvegardeMeilleureSuiteParOptimalite(var bonPourAfficher : boolean);
procedure EffaceMeilleureSuite;
procedure VideMeilleureSuiteInfos;
procedure GetMeilleureSuiteInfos(var infos:meilleureSuiteInfosRec);
procedure SetMeilleureSuiteInfos(var infos:meilleureSuiteInfosRec);
function GetMeilleureSuite() : str255;
procedure SetMeilleureSuite(s : str255);
procedure DetruitMeilleureSuite;
function NoteEnString(note : SInt32;avecSignePlus : boolean;nbEspacesDevant,nbDecimales : SInt16) : str255;
function MeilleureSuiteInfosEnChaine(nbEspacesEntreCoups : SInt16; avecScore,avecNumeroPremierCoup,enMajuscules,RemplacerScoreIncompletParEtc : boolean;WhichScore : SInt16) : str255;
function MeilleureSuiteEtNoteEnChaine(coul,note,profondeur : SInt16) : str255;
procedure EcritMeilleureSuite;
procedure EcritMeilleureSuiteParOptimalite;
function GetStatutMeilleureSuite() : SInt32;
procedure SetStatutMeilleureSuite(leStatut : SInt32);


IMPLEMENTATION







USES UnitMoveRecords,UnitMacExtras,UnitRapport,UnitStrategie,UnitTroisiemeDimension,
     UnitEntreeTranscript,UnitScannerOthellistique,UnitOth1,SNStrings,UnitFenetres,
     UnitCouleur,UnitJeu;


procedure SetDemandeAffichageReflexionEnSuspend(flag : boolean);
begin
  affichageReflexion.demandeEnSuspend := flag;
end;


procedure EffaceReflexion;
var oldport : grafPtr;
begin
 if windowReflexOpen then
  begin
    GetPort(oldport);
    SetPortByWindow(wReflexPtr);
    EraseRect(QDGetPortBound());
    DessineBoiteDeTaille(wReflexPtr);
    SetPort(oldport);
    SetDemandeAffichageReflexionEnSuspend(false);
    
    {pour reafficher immediatement au prochain appel de LanceDemandeAffichageReflexion; }
    affichageReflexion.tickDernierAffichageReflexion := 0; 
  end;
end;     

procedure LanceDemandeAffichageReflexion(forcerAffichageImmediat : boolean);
begin
  with affichageReflexion do
    begin 
      {plus d'une demi-seconde ?}
      forcerAffichageImmediat := forcerAffichageImmediat | ((Tickcount() - tickDernierAffichageReflexion) >= 25);
      if doitAfficher & forcerAffichageImmediat
        then EcritReflexion  
        else SetDemandeAffichageReflexionEnSuspend(true);
    end;
end;

procedure ReinitilaliseInfosAffichageReflexion;
begin
  if ReflexData <> NIL then
    begin
		  SetValReflex(ReflexData^.class,0,0,0,0,0,0,0);
		  SetNbLignesScoresCompletsCetteProf(ReflexData^,0);
		  SetNbLignesScoresCompletsProfPrecedente(ReflexData^,0);
    end;
end;


procedure SetNbLignesScoresCompletsCetteProf(var reflexionInfos:ReflexRec;nbLignes : SInt16);
begin
  reflexionInfos.nbLignesScoresCompletsCetteProf := nbLignes;
end;

function GetNbLignesScoresCompletsCetteProf(var reflexionInfos:ReflexRec) : SInt16; 
begin
  GetNbLignesScoresCompletsCetteProf := reflexionInfos.nbLignesScoresCompletsCetteProf;
end;

procedure SetNbLignesScoresCompletsProfPrecedente(var reflexionInfos:ReflexRec;nbLignes : SInt16);
begin
  reflexionInfos.nbLignesScoresCompletsProfPrecedente := nbLignes;
end;

function GetNbLignesScoresCompletsProfPrecedente(var reflexionInfos:ReflexRec) : SInt16; 
begin
  GetNbLignesScoresCompletsProfPrecedente := reflexionInfos.nbLignesScoresCompletsProfPrecedente;
end;


function DeltaFinaleEnChaine(delta : SInt32) : str255;
var s : str255;
begin
  s := '';
  if delta=kDeltaFinaleInfini then s := 'µ=∞' else
  if delta=kTypeMilieuDePartie then s := 'µ=-∞' 
   else
     begin
       s := 'µ='+NumEnString(delta div 100);
       if (delta mod 100) <> 0
         then s := s+'.'+NumEnString(delta mod 100);
     end;
  DeltaFinaleEnChaine := s;
end;

function DefenseEnString(theDefense : SInt32) : str255;
var s : str255;
begin
  s := CoupEnString(theDefense,CassioUtiliseDesMajuscules);
  if (s = '') 
    then DefenseEnString := '    '
    else DefenseEnString := s;
end;

procedure EcritCoupEnCoursdAnalyse(numligne,xposition,ypositionDebutListe : SInt16);
  var note,coupAnalyse,defense,certitude,delta,typeDeFleche,typeDonnees : SInt32;
      coupStr,infoStr,flecheStr,strAux:str255Ptr;
      a,b : SInt16; 
      ligneRect : rect;
      afficheeCommeNoteDeMilieu : boolean;
  const flecheLargeStr='  ==> ';
        flecheEtroiteStr='=> ';
        flecheTresEtroiteStr='=>';
        flecheTresTresEtroiteStr='=>';
        kFlecheTresTresEtroite=1;
        kFlecheTresEtroite=2;
        kFlecheEtroite=3;
        kFlecheLarge=4;
  begin
  
    coupStr := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
    infoStr := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
    flecheStr := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
    strAux := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
  
    a := xposition;
    b := ypositionDebutListe+(numligne)*12;
    typeDeFleche := kFlecheLarge;
    afficheeCommeNoteDeMilieu := false;
    
    coupAnalyse := ReflexData^.class[numligne].x;
    defense := ReflexData^.class[numligne].theDefense;
    certitude := ReflexData^.class[numligne].pourcentageCertitude;
    delta := ReflexData^.class[numligne].delta;
    note := ReflexData^.class[numligne].note;
    typeDonnees := ReflexData^.typeDonnees;
    
    coupStr^ := CoupEnString(coupAnalyse,CassioUtiliseDesMajuscules)+' ';
    infoStr^ := '';
    strAux^ := '';
    if (typeDonnees=ReflParfaitPhaseRechScore) | 
       (typeDonnees=ReflRetrogradeParfaitPhaseRechScore)
     then
      begin
        coupStr^ := coupStr^+DefenseEnString(defense)+' ';
        typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
        if note<0 {perd de ^0}
          then infoStr^ := infoStr^+ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
        if note=0 {annule}
          then infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,18);
        if note>0 {gagne de +^0}
          then infoStr^ := infoStr^+ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');                                          
        if (certitude=100) {& (note>ReflexData^.class[1].note+8) }
          then infoStr^ := infoStr^+'…';
      end
     else
      if (numligne=1)
       then
         begin
          if (note>0) then 
            begin
              if not(odd(note)) & (typeDonnees<>ReflRetrogradeParfaitPhaseGagnant) & (typeDonnees<>ReflParfaitPhaseGagnant)
                then
                  begin
                    coupStr^ := coupStr^+DefenseEnString(defense)+' ';
{gagne de +^0}      infoStr^ := infoStr^+ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','',''); 
                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                  end
                else
                  begin
{gagnant}           infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,7);  
                    if note<>+1 then infoStr^ := infoStr^ + '(+' + NumEnString(note) + ')';
                  end;
            end;
          if note<0 then 
            begin
              if not(odd(note)) & (typeDonnees<>ReflRetrogradeParfaitPhaseGagnant) & (typeDonnees<>ReflParfaitPhaseGagnant)
                then
                  begin
{perd de ^0}        coupStr^ := coupStr^+DefenseEnString(defense)+' ';
                    infoStr^ := infoStr^+ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                  end
                else
                  begin
                    coupStr^ := coupStr^+DefenseEnString(defense)+' ';
{perdant}           infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,9);
                    if note<>-1 then infoStr^ := infoStr^+'(' + NumEnString(note) + ')';
                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                  end;
             end;
          if note=0     
            then 
              begin
                coupStr^ := coupStr^+DefenseEnString(defense)+' ';
{nulle}         infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,11);  
                typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
              end;
         end
       else
         if note<=ReflexData^.class[1].note
          then 
            begin
              case typeDonnees of
                ReflGagnant,ReflRetrogradeGagnant,
                ReflRetrogradeParfaitPhaseGagnant,ReflParfaitPhaseGagnant:
                  if (note >= -1) 
                    then
		                  begin
		                    coupStr^ := coupStr^+DefenseEnString(defense)+' ';
		                    if (note = kValeurSpecialeDansReflPourPerdant)
		                      then infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,9)    {perdant}
		                      else infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,16);  {pas mieux}
		                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
		                  end 
		                else
		                  infoStr^ := infoStr^+'???';
		            ReflParfait,ReflParfaitPhaseRechScore,
		            ReflRetrogradeParfait,ReflRetrogradeParfaitPhaseRechScore :
		              if (note>=-64)
                    then
		                  begin
		                    coupStr^ := coupStr^+DefenseEnString(defense)+' ';
		                    infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,16);    {pas mieux}
		                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
		                  end
		                else
		                  infoStr^ := infoStr^+'???';
		            ReflMilieu :
		                begin
		                  infoStr^ := infoStr^+'???';
		                  afficheeCommeNoteDeMilieu:=true;
		                end;
                otherwise 
                    infoStr^ := infoStr^+'???';
              end; {case}
            end
          else
            begin { note>=ReflexData^.class[1].note }
              case typeDonnees of
                ReflParfait,
                ReflRetrogradeParfait:
                  if (note = kValeurSpecialeDansReflPourPerdant)
                    then
                      begin
                        coupStr^ := coupStr^+DefenseEnString(defense)+' ';
                        infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,9);  {perdant}
                        if note<>-1 then infoStr^ := infoStr^+'(' + NumEnString(note) + ')' ;
                        typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                      end
                    else
		                  if (note>0) & (ReflexData^.class[1].note<=0)
		                    then 
		                      begin
		                        if odd(note)
		                          then
		                            begin  {gagnant}
		                              infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,7);
		                              if note<>+1 then infoStr^ := infoStr^+'(+' + NumEnString(note) + ')' ;
		                            end
		                          else
		                            begin  {gagne de +^0}
		                              coupStr^ := coupStr^+DefenseEnString(defense)+' ';
		                              infoStr^ := infoStr^+ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','',''); 
		                              typeDeFleche := Min(kFlecheEtroite,typeDeFleche); 
		                            end;
		                      end
		                    else 
                          begin
                            infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,14);   {est meilleur}
                            if note > ReflexData^.class[1].note + 2 then
                              begin
		                            if note>0
		                              then infoStr^ := infoStr^+'(+' + NumEnString(note) + ')';
		                            if note=0
		                              then infoStr^ := infoStr^+'(' + NumEnString(note) + ')';
		                            if note<0
		                              then infoStr^ := infoStr^+'(' + NumEnString(note) + ')';
		                          end;
                            typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                          end;
                ReflParfaitPhaseGagnant,ReflRetrogradeParfaitPhaseGagnant,
                ReflGagnant,ReflRetrogradeGagnant:
                  begin
                    if note>0 {est gagnant}
                      then infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,12); 
                    if note=0 then {annule}
                      begin
                        coupStr^ := coupStr^+DefenseEnString(defense)+' ';
                        infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,18); 
                        typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                      end;
                    if note<0 then {perdant}
                      begin
                        coupStr^ := coupStr^+DefenseEnString(defense)+' ';
                        infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,9);  {perdant}
                        typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                      end;
                  end;
                ReflMilieu :
		                begin
		                  infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,14); {est meilleur}
		                  afficheeCommeNoteDeMilieu := true;
		                end;
                otherwise 
                    begin
                      infoStr^ := infoStr^+ReadStringFromRessource(TextesReflexionID,14); {est meilleur}
                    end;
              end;
            end;
            
    if Pos('???',infoStr^)=0 then
      begin
        if certitude = kCertitudeSpecialPourPointInterrogation
          then
            infoStr^ := infoStr^+'?'
          else
				    if (certitude>0) & (certitude<100) then
				      begin
				        infoStr^ := infoStr^+'?';
				        strAux^ := strAux^+' ['+NumEnString(certitude)+'%]';
				      end;
        if (delta>=0) & (delta<kDeltaFinaleInfini) & (Pos('?',infoStr^)=0)
          then infoStr^ := infoStr^+'?';
        if not(afficheeCommeNoteDeMilieu | (delta=kDeltaFinaleInfini) | (delta=kTypeMilieuDePartie))
          then strAux^ := strAux^+' ['+DeltaFinaleEnChaine(delta)+']';
        if afficheGestionTemps then
          begin
		        if (certitude<=0) | (certitude>=100) 
		          then strAux^ := strAux^+' (' + NumEnString((30+ReflexData^.class[numligne].temps) div 60) + ' s)' 
		          else
		            begin
		              strAux^ := strAux^+'(' + NumEnString((30+ReflexData^.class[numligne].temps) div 60) + ' s)' ;
		              typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
		            end;
		      end;
		    
		    {if (certitude>0) & (certitude<100) & (typeDeFleche=kFlecheEtroite) then
			      typeDeFleche := kFlecheTresEtroite;
			   }
      end;
      
    
    case typeDeFleche of
        kFlecheTresTresEtroite : flecheStr^ := flecheTresTresEtroiteStr;
        kFlecheTresEtroite     : flecheStr^ := flecheTresEtroiteStr;
        kFlecheEtroite         : flecheStr^ := flecheEtroiteStr;
        kFlecheLarge           : flecheStr^ := flecheLargeStr;
        otherwise                flecheStr^ := '';
    end; {case}
    SetRect(lignerect,a,b-10,QDGetPortBound().right,b+2);
    EraseRect(lignerect);
    Moveto(a,b);
    TextFace(bold);
    DrawString(coupStr^+flecheStr^+infoStr^);
    TextFace(normal); 
    DrawString(strAux^);
    
    DessineBoiteDeTaille(wReflexPtr);
    
    DisposeMemoryPtr(Ptr(coupStr));
    DisposeMemoryPtr(Ptr(infoStr));
    DisposeMemoryPtr(Ptr(flecheStr));
    DisposeMemoryPtr(Ptr(strAux));
end;



procedure ConstruitChaineLigneReflexion(nroLigne,coup,note,delta,noteLignePrecedente : SInt32;avecFleche : boolean;s2:str255Ptr);
var afficheeCommeNoteDeMilieu : boolean;

  function NoteEnStringLocal(note : SInt32) : str255;
  begin
    afficheeCommeNoteDeMilieu := true;
    NoteEnStringLocal := NoteEnString(note,false,0,2);
  end;

  function ChaineGagnantAvecScore(note : SInt32) : str255;
  var aux : str255;
  begin
    aux := ReadStringFromRessource(TextesReflexionID,7);        {gagnant}
		if note<>+1 then aux := aux + '(+' + NumEnString(note) + ')';
		ChaineGagnantAvecScore := aux;
  end;
  
  function ChainePerdantAvecScore(note : SInt32) : str255;
  var aux : str255;
  begin
    aux := ReadStringFromRessource(TextesReflexionID,9);  {perdant}
		if note<>-1 then aux := aux + '('+NumEnString(note) + ')';
		ChainePerdantAvecScore := aux;
  end;

begin
  with ReflexData^ do
    begin
		  afficheeCommeNoteDeMilieu := false;
		  
		  if (note = kValeurSpecialeDansReflPourPerdant) &
		     (delta <> kTypeMilieuDePartie) & 
		     ((typeDonnees = ReflParfait) | 
		      (typeDonnees = ReflParfaitExhaustif) |
		   { (typeDonnees  = ReflParfaitPhaseGagnant) |}
		     (typeDonnees  = ReflParfaitPhaseRechScore) |
		     (typeDonnees  = ReflRetrogradeParfait) |
		   { (typeDonnees  = ReflRetrogradeParfaitPhaseGagnant)|}
		     (typeDonnees  = ReflRetrogradeParfaitPhaseRechScore)) 
		    then 
		      s2^ := ReadStringFromRessource(TextesReflexionID,9)     {'perdant'}
		    else  
				  case typeDonnees of
				     ReflTriGagnant,
				     ReflTriParfait,
				     ReflAnnonceParfait,
				     ReflAnnonceGagnant:
				       if note<=-30000 
				         then s2^ := '              '
				         else s2^ := NoteEnStringLocal(note);
				     ReflMilieu    : 
				       if note<=-30000 
				         then s2^ := '              '
				         else
				           begin
				             if (nroLigne<=nbLignesScoresCompletsCetteProf) then s2^ := Concat(' ',NoteEnStringLocal(note)) else
					           if (nroLigne<=nbCoupsEnTete) then s2^ := Concat(' ',NoteEnStringLocal(note)) else
					           if (note=noteLignePrecedente) & (nroLigne>1)
					               then s2^ := Concat(' ',ReadStringFromRessource(TextesReflexionID,16))  {pas mieux}
					               else s2^ := Concat(' ',NoteEnStringLocal(note));
					           afficheeCommeNoteDeMilieu:=true;
					         end;
				     ReflMilieuExhaustif : 
				       if note<=-30000 
				         then s2^ := '              '
				         else s2^ := Concat(' ',NoteEnStringLocal(note));
				     ReflParfait,ReflParfaitPhaseGagnant,ReflParfaitPhaseRechScore:   
				       if (nroLigne=1)
				         then
				           begin
				             if odd(note) | (typeDonnees=ReflParfaitPhaseGagnant)
				               then
				                 begin
				                   if note<0 then s2^ := ReadStringFromRessource(TextesReflexionID,9) else  {perdant} 
				                   if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,11) else {nulle}
				                   if note>0 then s2^ := ReadStringFromRessource(TextesReflexionID,7);      {gagnant}
				                 end
				               else
				                 begin
				   {perd de ^0}   if note<0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
				   {annule }      if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,18);
				   {gagne de +^0} if note>0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
				                 end
				           end
				         else
				           begin
				             if odd(note) 
				               then 
				                 begin
				                   if (note=noteLignePrecedente) | (note=ReflexData^.class[1].note)
				                     then 
				                       if (note=-1) & (typeDonnees=ReflParfaitPhaseGagnant)
				                         then s2^ := ReadStringFromRessource(TextesReflexionID,9)  {perdant}
				                         else s2^ := ReadStringFromRessource(TextesReflexionID,16) {pas mieux}
				                     else
				                       begin
				                         if note<0 then s2^ := ChainePerdantAvecScore(note) else        {perdant}
				                         if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,11) else {nulle}
				                         if note>0 then s2^ := ChaineGagnantAvecScore(note);            {gagnant}
				                       end;
				                 end
				               else 
				                 begin
				   {pas mieux}    if (note=noteLignePrecedente) | (note=ReflexData^.class[1].note) then s2^ := ReadStringFromRessource(TextesReflexionID,16) else
				   {perd de ^0}   if note<0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','') else
				   {annule }      if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,18) else
				   {gagne de +^0} if note>0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
				                 end
				           end;
				     ReflGagnant,ReflRetrogradeGagnant: 
				       if (nroLigne=1)
				         then
				           begin
		{perdant}        if note<0 then s2^ := ReadStringFromRessource(TextesReflexionID,9) else
		{nulle}          if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,11) else
		{gagnant}        if note>0 then s2^ := ReadStringFromRessource(TextesReflexionID,7);
				           end
				         else
				           begin
		{pas mieux}      if ((note=noteLignePrecedente) | (note=ReflexData^.class[1].note)) & (note>=0) 
		                    then s2^ := ReadStringFromRessource(TextesReflexionID,16)
		{perdant}           else if note<0 then s2^ := ReadStringFromRessource(TextesReflexionID,9)
		{nulle}                else if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,11)
		{gagnant}                else if note>0 then s2^ := ReadStringFromRessource(TextesReflexionID,7);
				           end;
				     ReflRetrogradeParfait,ReflRetrogradeParfaitPhaseGagnant,ReflRetrogradeParfaitPhaseRechScore:
				       if (coup=coupAnalyseRetrograde) & not(odd(scoreAnalyseRetrograde)) 
				         then
				           begin
		{perd de ^0}     if scoreAnalyseRetrograde<0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(scoreAnalyseRetrograde),'','','')
		{annule}           else if scoreAnalyseRetrograde=0 then s2^ := ReadStringFromRessource(TextesReflexionID,18) 
		{gagne de +^0}       else if scoreAnalyseRetrograde>0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(scoreAnalyseRetrograde),'','','');
				           end
				         else
				           begin
							       if (nroLigne=1)
							         then
							           begin
							             if odd(note) | (typeDonnees=ReflRetrogradeParfaitPhaseGagnant)
							               then
							                 begin
		{perdant}			               if note<0 then s2^ := ChainePerdantAvecScore(note) else
		{nulle}					             if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,11) else
		{gagnant}			               if note>0 then s2^ := ChaineGagnantAvecScore(note);
							                 end
							               else
		{perd de ^0}               if note<0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','')
		{annule}     					       else if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,18) 
		{gagne de +^0}   					     else if note>0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
							           end
							         else
							           begin
							             if (note=noteLignePrecedente) | (note=ReflexData^.class[1].note)
							             then 
							               if odd(note) & (note<0) & (note=-1)
		{perdant}                  then s2^ := ReadStringFromRessource(TextesReflexionID,9)      
		{pas mieux}                else s2^ := ReadStringFromRessource(TextesReflexionID,16)     
							             else 
							               if odd(note) 
							                 then 
							                   begin
{perdant}	  		                   if note<0 then s2^ := ChainePerdantAvecScore(note) else
{nulle}                            if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,11) else
{gagnant}                          if note>0 then s2^ := ChaineGagnantAvecScore(note);
							                   end
							                 else 
		{pas mieux}                  if (note>noteLignePrecedente) & (note=ReflexData^.class[1].note) then 
		                                 s2^ := ReadStringFromRessource(TextesReflexionID,16) else
		{perd de ^0}  					       if note<0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','')  
		{annule}      					         else if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,18) 
		{gagne de ^0}   					         else if note>0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
							           end;
							     end;
				     ReflParfaitExhaustif,ReflParfaitExhaustPhaseGagnant:
				{perd de ^0}    if note<0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','')
				{annule}          else if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,18) 
				{gagne de +^0}      else if note>0 then s2^ := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
				     ReflGagnantExhaustif:
{perdant}	  	 if note<0 then s2^ := ChainePerdantAvecScore(note) else
{nulle}        if note=0 then s2^ := ReadStringFromRessource(TextesReflexionID,11) else
{gagnant}      if note>0 then s2^ := ChaineGagnantAvecScore(note);                                            
				     otherwise  
				       s2^ := '';
				   end; {case}
		   
		   if (s2^<>'') & not(ASeulementCeCaractere(' ',s2^)) then
		     begin
		       
		       if (delta=kTypeMilieuDePartie) & not(afficheeCommeNoteDeMilieu)
		           then
		{pas exploré} s2^ := ReadStringFromRessource(TextesReflexionID,21) 
		           else
		             if not((delta=kDeltaFinaleInfini) | (delta=kTypeMilieuDePartie)) 
		               then s2^ := s2^+'  ['+DeltaFinaleEnChaine(delta)+']';
		       
		       if avecFleche 
		         then s2^ := '  => '+s2^;
		       
		     end; 
    end;
end;

procedure EcritReflexion;
var yposition,xposition,ypositionDebutListe,j : SInt16; 
    s,s1,s2,s3,espaceEntreCoup,ChainePourLigneVide:str255Ptr;
    a,b : SInt16; 
    noteDerniereLigneAffichee : SInt32;
    oldport : grafPtr;
    ligneRect : rect;
    
    
   procedure UpdateNoteDerniereLigneAffichee;
   begin
     with ReflexData^ do
       if (class[j].x=coupAnalyseRetrograde) & not(odd(scoreAnalyseRetrograde))
         then noteDerniereLigneAffichee := scoreAnalyseRetrograde
         else 
           if class[j].note > -30000 then
             noteDerniereLigneAffichee := class[j].note;
   end;
    
    
begin
 if windowReflexOpen & (ReflexData^.longClass>0) then
  begin
    s := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
    s1 := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
    s2 := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
    s3 := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
    espaceEntreCoup := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
    ChainePourLigneVide := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
    ChainePourLigneVide^ := '  =>              ';
    
    GetPort(oldport);
    SetPortByWindow(wReflexPtr);
    if interruptionReflexion = pasdinterruption then
      begin
       with ReflexData^ do
        begin
         TextMode(1);
         TextFont(gCassioApplicationFont);
         TextFace(normal); 
         TextSize(gCassioSmallFontSize);
         xposition := 3;
         yposition := 0;
         SetRect(lignerect,xposition,yposition,512,yposition+27);
         EraseRect(lignerect);
         
         if (typeDonnees=ReflMilieu) | 
            (typeDonnees=ReflMilieuExhaustif) |
            (typeDonnees=ReflAnnonceParfait) | 
            (typeDonnees=ReflAnnonceGagnant) |
            (typeDonnees=ReflTriGagnant) |
            (typeDonnees=ReflTriParfait)
           then espaceEntreCoup^ := '  '
           else espaceEntreCoup^ := '  ';
         
         
         
         s^ := ReadStringFromRessource(TextesReflexionID,22);       {'coup ^0, couleur = ^1'}
         case couleur of
           pionNoir  : s1^ := ReadStringFromRessource(TextesListeID,7); {'Noir'}
           pionBlanc : s1^ := ReadStringFromRessource(TextesListeID,8); {'Blanc'} 
           otherwise   s1^ := '******';
         end;
         s^ := ParamStr(s^,s1^,NumEnString(numeroDuCoup),'','');
         Moveto(xposition,yposition+13);
         DrawString(s^);
         
         case typeDonnees of
           ReflAnnonceParfait                 : s^ := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflAnnonceGagnant                 : s^ := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflParfait                        : s^ := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflParfaitExhaustif               : s^ := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflParfaitPhaseGagnant            : s^ := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflParfaitPhaseRechScore          : s^ := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflGagnant                        : s^ := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflGagnantExhaustif               : s^ := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflRetrogradeGagnant              : s^ := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflRetrogradeParfait              : s^ := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflRetrogradeParfaitPhaseGagnant  : s^ := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflRetrogradeParfaitPhaseRechScore: s^ := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflTriParfait                     : s^ := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflTriGagnant                     : s^ := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflMilieu                         : begin
                                                  s^ := ReadStringFromRessource(TextesReflexionID,5); {'profondeur='}
                                                  s^ := ParamStr(s^,NumEnString(prof+1),'','','');
                                                end;
           ReflMilieuExhaustif                : begin
                                                  s^ := ReadStringFromRessource(TextesReflexionID,5); {'profondeur='}
                                                  s^ := ParamStr(s^,NumEnString(prof+1),'','','');        
                                                end;
           otherwise                            s^ := '';
         end; {case}
         Moveto(xposition,yposition+25);
         DrawString(s^);
         ypositionDebutListe := yposition+25;
         
         
         if (typeDonnees=ReflTriGagnant) |
            (typeDonnees=ReflTriParfait) 
           then 
	           begin
	             s^ := ReadStringFromRessource(TextesReflexionID,4);      {'tri des coups (prof= ^0)'}
	             s^ := ParamStr(s^,NumEnString(prof+1),'','','');
	           end
           else
	           begin
	             s^ := ReadStringFromRessource(TextesReflexionID,6);       {'coup n°^0 (sur ^1)'}
	             s^ := ParamStr(s^,NumEnString(Compteur),NumEnString(longClass),'','');
	           end;
         ypositionDebutListe := ypositionDebutListe+12;
	       a := xposition;
	       b := ypositionDebutListe;
	       SetRect(lignerect,a,b-10,QDGetPortBound().right,b+2);
	       EraseRect(lignerect);
	       Moveto(a,b);
	       DrawString(s^);
         
        
         if FALSE then
           begin
		         case typeDonnees of
		           ReflAnnonceParfait                 : s^ := 'ReflAnnonceParfait';
		           ReflAnnonceGagnant                 : s^ := 'ReflAnnonceGagnant';
		           ReflParfait                        : s^ := 'ReflParfait';
		           ReflParfaitExhaustif               : s^ := 'ReflParfaitExhaustif';
		           ReflParfaitExhaustPhaseGagnant     : s^ := 'ReflParfaitExhaustPhaseGagnant';
		           ReflParfaitPhaseGagnant            : s^ := 'ReflParfaitPhaseGagnant';
		           ReflParfaitPhaseRechScore          : s^ := 'ReflParfaitPhaseRechScore';
		           ReflGagnant                        : s^ := 'ReflGagnant';
		           ReflGagnantExhaustif               : s^ := 'ReflGagnantExhaustif';
		           ReflRetrogradeGagnant              : s^ := 'ReflRetrogradeGagnant';
		           ReflRetrogradeParfait              : s^ := 'ReflRetrogradeParfait';
		           ReflRetrogradeParfaitPhaseGagnant  : s^ := 'ReflRetrogradeParfaitPhaseGagnant';
		           ReflRetrogradeParfaitPhaseRechScore: s^ := 'ReflRetrogradeParfaitPhaseRechScore';
		           ReflTriParfait                     : s^ := 'ReflTriParfait';
		           ReflTriGagnant                     : s^ := 'ReflTriGagnant';
		           ReflMilieu                         : s^ := 'ReflMilieu';
		           ReflMilieuExhaustif                : s^ := 'ReflMilieuExhaustif';
		           otherwise                            s^ := 'type donnees inconnu !!';
		         end; 
		         ypositionDebutListe := ypositionDebutListe+12;
		         a := xposition;
		         b := ypositionDebutListe;
		         SetRect(lignerect,a,b-10,QDGetPortBound().right,b+2);
		         EraseRect(lignerect);
		         Moveto(a,b);
		         DrawString(s^);
		       end;
         
         noteDerniereLigneAffichee := -12736364;  {ou n'importe quoi d'aberrant}
         for j := 1 to compteur do
           if j=IndexCoupEnCours
             then 
               begin
                 EcritCoupEnCoursdAnalyse(j,xposition,ypositionDebutListe);
                 UpdateNoteDerniereLigneAffichee;
               end
             else
               begin
                 a := xposition;
                 b := ypositionDebutListe+j*12;
                 
                 ConstruitChaineLigneReflexion(j,class[j].x,class[j].note,class[j].delta,noteDerniereLigneAffichee,true,s2);
                 UpdateNoteDerniereLigneAffichee;
                 
                 if afficheGestionTemps & (s2^<>ChainePourLigneVide^)
                   then s3^ := ' (' + NumEnString((30+class[j].temps) div 60) + ' s)' 
                   else s3^ := '';
                 s^ := CoupEnString(class[j].x,CassioUtiliseDesMajuscules);
                 if (class[j].theDefense>=11) & (class[j].theDefense<=88) & (prof+1<>1)
                   then s1^ := DefenseEnString(class[j].theDefense)
                   else s1^ := '    ';
                 s^ := s^+espaceEntreCoup^+s1^+s2^+s3^;
                 SetRect(lignerect,a,b-10,QDGetPortBound().right,b+2);
                 EraseRect(lignerect);
                 Moveto(a,b);
                 if (class[j].x=coupAnalyseRetrograde) 
                   then 
                     begin
                       TextFace(italic);
                       DrawString(s^);
                       TextFace(normal);
                     end
                   else
                     DrawString(s^);
               end;
         for j := compteur+1 to longClass do
           if j=IndexCoupEnCours
             then 
               begin
                 EcritCoupEnCoursdAnalyse(j,xposition,ypositionDebutListe);
                 
               end
             else
               begin       
                 a := xposition;
                 b := ypositionDebutListe+j*12;
                 
                 if (typeDonnees <> ReflMilieu) 
                   then 
                     begin
                       ConstruitChaineLigneReflexion(j,class[j].x,class[j].note,class[j].delta,noteDerniereLigneAffichee,false,s2);
                       UpdateNoteDerniereLigneAffichee;
                     end
                   else
                     if (j<=nbCoupsEnTete) then s2^ := NoteEnString(class[j].note,false,1,2) else
                     if (j<=nbLignesScoresCompletsProfPrecedente) then s2^ := NoteEnString(class[j].note,false,1,2) else
                     if (class[j].note=class[j-1].note) | ((j=IndexCoupEnCours+1) & ((j=longClass) | (class[j].note=class[j+1].note)))
                       then s2^ := StringOf(' ')+ReadStringFromRessource(TextesReflexionID,16) {pas mieux}
                       else s2^ := NoteEnString(class[j].note,false,1,2);

                 if (typeDonnees=ReflMilieu) | 
                    (typeDonnees=ReflMilieuExhaustif) |
                    (typeDonnees=ReflAnnonceParfait) | 
                    (typeDonnees=ReflAnnonceGagnant) |
                    (typeDonnees=ReflTriGagnant) |
                    (typeDonnees=ReflTriParfait) then
                   if (class[j].note<=-30000) then
                     s2^ := '             ';
                 if afficheGestionTemps & (s2^<>'             ')
                   then s3^ := ' (' + NumEnString((30+class[j].temps) div 60) + ' s)' 
                   else s3^ := '';
                 s^ := CoupEnString(class[j].x,CassioUtiliseDesMajuscules);
                 if (class[j].theDefense>=11) & (class[j].theDefense<=88) 
                   then s1^ := DefenseEnString(class[j].theDefense)+'  => '
                   else s1^ := '    '+'  => ';
                 s^ := s^+espaceEntreCoup^+s1^+s2^+s3^;
                 SetRect(lignerect,a,b-10,QDGetPortBound().right,b+2);
                 EraseRect(lignerect);
                 Moveto(a,b);
                 if (class[j].x>=11) & (class[j].x<=88) & (prof <> 0) then
                   if (class[j].x=coupAnalyseRetrograde) 
	                   then 
	                     begin
	                       TextFace(italic);
	                       DrawString(s^);
	                       TextFace(normal);
	                     end
	                   else
	                     DrawString(s^);
               end;
         b := ypositionDebutListe+(longClass+1)*12;
         EraseRect(MakeRect(xposition,b-10,QDGetPortBound().right,b+2));
       end;
     end;
   
   ValidRect(GetWindowPortRect(wReflexPtr));
   SetPort(oldport);
   
   DisposeMemoryPtr(Ptr(s));
   DisposeMemoryPtr(Ptr(s1));
   DisposeMemoryPtr(Ptr(s2));
   DisposeMemoryPtr(Ptr(s3));
   DisposeMemoryPtr(Ptr(espaceEntreCoup));
   DisposeMemoryPtr(Ptr(chainePourLigneVide));
   
   SetDemandeAffichageReflexionEnSuspend(false);
   affichageReflexion.tickDernierAffichageReflexion := TickCount();
  end;
  DessineBoiteDeTaille(wReflexPtr);
end;



procedure SetValeursGestionTemps(alloue,effectif,prevu : SInt32;divergence : extended;prof,suivante : SInt16);
begin
  gestionRec.alloue := alloue;
  gestionRec.prevu := prevu;
  gestionRec.effectif := effectif;
  gestionRec.divergence := divergence;
  gestionRec.prof := prof;
  gestionRec.profSuivante := suivante;
end;


procedure EcritGestionTemps;
var oldport : grafPtr;
    s : string;
    posH : SInt32;
    lignerect : rect;
    divergAffichee : extended;
begin
  if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);
      TextSize(gCassioSmallFontSize);
      TextFont(gCassioApplicationFont);
      TextMode(1);
      TextFace(normal);
      posH := 4;
      
      with gestionRec do
       begin
           GetIndString(s,TextesGestionID,1);
           if alloue = minutes10000000 {temps infini}
             then s := ParamStr(s,NumEnString(1000000000),'','','')  
             else s := ParamStr(s,NumEnString(alloue),'','','');
           Moveto(posH,13);
           SetRect(ligneRect,posH,13-8,300,13+2);
           EraseRect(lignerect);
           DrawString(s);
           GetIndString(s,TextesGestionID,2);
           s := ParamStr(s,NumEnString(prof),NumEnString(effectif div 60),'','');
           Moveto(posH,25);
           SetRect(ligneRect,posH,25-8,300,25+2);
           EraseRect(lignerect);
           DrawString(s);
           GetIndString(s,TextesGestionID,3);
           s := ParamStr(s,NumEnString(profsuivante),NumEnString(prevu div 60),'','');
           Moveto(posH,37);
           SetRect(ligneRect,posH,37-8,300,37+2);
           EraseRect(lignerect);
           DrawString(s);
           divergAffichee := gestionRec.divergence;
           GetIndString(s,TextesGestionID,4);
           s := s+NumEnString(MyTrunc(divergAffichee))+StringOf('.')+NumEnString(MyTrunc(10*(divergAffichee-MyTrunc(divergAffichee))));
           SetRect(ligneRect,posH,49-8,300,49+2);
           EraseRect(lignerect);
           Moveto(posH,49); 
           DrawString(s);
        end;  {with}
      DessineBoiteDeTaille(wGestionPtr);
      SetPort(oldport);
    end;
end;

procedure LanceChronoCetteProf;
begin
  tempsReflexionCetteProf := 0;
end;

procedure LanceChrono;
begin
  tempsReflexionMac := 0;
end;

procedure LanceDecompteDesNoeuds;
begin
  nbreToursFeuillesMilieu := 0;
  nbreFeuillesMilieu := 0;
  SommeNbEvaluationsRecursives := 0;
  nbreToursNoeudsGeneresMilieu := 0;
  nbreNoeudsGeneresMilieu := 0;
  lastNbreNoeudsGeneres := 0;
  DebutComptageFeuilles := TickCount();
end;

procedure AffichageNbreNoeuds;
var oldPort : grafPtr;
    aux,nsec,i : SInt32; 
    NodeCounter,TickCounter : UInt32;
    unRect : rect;
    s : str255;
begin
 if not(HumCtreHum) then
  if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);
      
      if phaseDeLaPartie>=phaseFinale
        then
          begin
            SetRect(unRect,0,50,300,81);
            EraseRect(unRect);
            DessineBoiteDeTaille(wGestionPtr);
            (*if nbreToursNoeudsGeneresFinale>0 then 
              begin
                GetIndString(s,TextesGestionID,5); { "nbre tours du compteur : " }
                WriteStringAndNumEnSeparantLesMilliersAt(s,nbreToursNoeudsGeneresFinale,4,88);
              end;
            *)
            GetIndString(s,TextesGestionID,6);     { "nbre nœuds : " }
            WriteStringAndBigNumEnSeparantLesMilliersAt(s,nbreToursNoeudsGeneresFinale,nbreNoeudsGeneresFinale,4,76);
            
            with NbreDeNoeudsMoyensFinale do
              begin
                if index<0 then index := 0;
                if index>9 then index := 9;
                nbreNoeudsCetteSeconde[index] := (nbreNoeudsGeneresFinale-lastNbreNoeudsFinale);
                nbreTicksCetteSeconde[index] := (TickCount()-lastNbreTicksFinale);
                lastNbreNoeudsFinale := nbreNoeudsGeneresFinale;
                lastNbreTicksFinale := TickCount();
                index := (index+1) mod 10;
                
                NodeCounter := 0;
                TickCounter := 0;
                
                {faire deux sommations separees pour eviter les overflow dans NodeCounter}
                for i := 0 to 9 do
                  if (nbreNoeudsCetteSeconde[i]>0) & 
                     (nbreTicksCetteSeconde[i]>0) &
                     (nbreTicksCetteSeconde[i]<1000)
                    then TickCounter := TickCounter + nbreTicksCetteSeconde[i];
                
                if TickCounter > 0 then
	                begin
	                  for i := 0 to 9 do
		                  if (nbreNoeudsCetteSeconde[i]>0) & 
		                     (nbreTicksCetteSeconde[i]>0) &
		                     (nbreTicksCetteSeconde[i]<1000)
		                    then NodeCounter := NodeCounter + (nbreNoeudsCetteSeconde[i] div TickCounter);
		                NodeCounter := NodeCounter * 60;
		                
		                if (NodeCounter < 1200) then
	                    begin
			                  for i := 0 to 9 do
				                  if (nbreNoeudsCetteSeconde[i]>0) & 
				                     (nbreTicksCetteSeconde[i]>0) &
				                     (nbreTicksCetteSeconde[i]<1000)
				                    then NodeCounter := NodeCounter + nbreNoeudsCetteSeconde[i];
				                NodeCounter := (60*NodeCounter) div TickCounter;
			                end;
			            end;
                
                GetIndString(s,TextesGestionID,8);  {"nbre noeuds par sec"}
                if TickCounter>0 
                  then WriteStringAndNumEnSeparantLesMilliersAt(s,NodeCounter,4,65)
                  else WriteStringAndNumAt(s,0,4,65);
              end;
            
          end
        else
          begin
            TextSize(gCassioSmallFontSize);
            TextFont(gCassioApplicationFont);
            nsec := (TickCount()-DebutComptageFeuilles) div 60;
            
            if (nsec > 0)
              then 
                begin
                  aux := nbreToursNoeudsGeneresMilieu*(1000000000 div nsec);
                  aux := aux + (nbreNoeudsGeneresMilieu div nsec);
                end
              else 
                aux := 0;
                
            if (nbreNoeudsGeneresMilieu <> lastNbreNoeudsGeneres) & (aux > 0)
              then
                begin
                  GetIndString(s,TextesGestionID,7);  { "nb feuilles par sec : " }
                  WriteStringAndNumEnSeparantLesMilliersAt(s,(nbreToursFeuillesMilieu*(1000000000 div nsec)) + (nbreFeuillesMilieu div nsec),4,64);
                  GetIndString(s,TextesGestionID,8);  { "nb nœuds par sec : " }
                  WriteStringAndNumEnSeparantLesMilliersAt(s,aux,4,76); 
                end
              else   {on écrit des zeros comme nb de noeuds par sec}
                begin
                  SetRect(unRect,0,50,200,81);
                  EraseRect(unRect);
                  DessineBoiteDeTaille(wGestionPtr);
                  GetIndString(s,TextesGestionID,7);   { "nb feuilles par sec : " }
                  WriteStringAndNumAt(s,0,4,64);
                  GetIndString(s,TextesGestionID,8);   { "nb nœuds par sec : " }
                  WriteStringAndNumAt(s,0,4,76); 
                end;
            lastNbreNoeudsGeneres := nbreNoeudsGeneresMilieu;
          end;
      SetPort(oldport);
    end;
end;



procedure SauvegardeMeilleureSuiteParOptimalite(var bonPourAfficher : boolean);
var i,coup,aux,ChoixX,MeilleurDef : SInt32;
    ok,LigneOptimaleJusquaLaFin : boolean;
    plat : plateauOthello;
    nBla,nNoi,aqui : SInt32;
    coupPossible : boolean;
begin

  if debuggage.calculFinaleOptimaleParOptimalite then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('Entrée de SauvegardeMeilleureSuiteParOptimalite');
    end;
      
  
  bonPourAfficher := false;
  ChoixX := 44; 
  MeilleurDef := 44;
  ok := not(gameOver) & (nbreCoup<60) & (interruptionReflexion = pasdinterruption);
  ok := ok & (not(CassioEstEnModeSolitaire()) | (aQuiDeJouer=-couleurMacintosh));
  if ok then for i := 1 to nbreCoup do
                 ok := (ok & (GetNiemeCoupPartieCourante(i)=partie^^[i].coupParfait));
  if ok then ok := (ok & partie^^[nbreCoup+1].optimal);
  if ok then
    begin
      coup := partie^^[nbreCoup+1].coupParfait;
      aux := partie^^[nbreCoup+2].coupParfait;
      if (coup<11) | (coup>88) then ok := false;
      if ok & possibleMove[coup] 
         then
           begin
             ChoixX := coup;
             if partie^^[nbreCoup+2].optimal then
               if (aux>=11) & (aux<=88) then 
                 MeilleurDef := aux;
           end
         else
           ok := false;
    end;    
 
 if ok then
   begin
     LigneOptimaleJusquaLaFin := true;
     for i := nbreCoup+1 to 60 do
       begin
         coup := partie^^[i].coupParfait;
         if (coup>=11) & (coup<=88) then
           LigneOptimaleJusquaLaFin := LigneOptimaleJusquaLaFin & partie^^[i].optimal;
       end;
     if LigneOptimaleJusquaLaFin then
       begin
         bonPourAfficher := true;
         VideMeilleureSuiteInfos;
         plat := jeuCourant;
         nBla := nbreDePions[pionBlanc];
         nNoi := nbreDePions[pionNoir]; 
         Aqui := aQuiDeJouer;
         with meilleureSuiteInfos do
         begin
           for i := nbreCoup+1 to 60 do
             begin
               coup := partie^^[i].coupParfait;
               if (coup>=11) & (coup<=88) then
                 begin
                   ligne[i-(nbreCoup+1)] := coup;
                   coupPossible := ModifPlatFin(Coup,aQui,plat,nBla,nNoi);
                   if coupPossible 
                     then aQui := -Aqui
                     else coupPossible := ModifPlatFin(Coup,-aQui,plat,nBla,nNoi);
                 end;
             end;
           statut := NeSaitPas;
           numeroCoup := nbreCoup;
           couleur := aQuiDeJouer;
           score.noir := nNoi;
           score.Blanc := nBla;
           
         end;
       end;
   end;
end;


procedure EffaceMeilleureSuite;
var oldPort : grafPtr;
    ligneRect : rect;
    a : SInt32;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);   
      if CassioEstEn3D()
        then 
          begin
            if posVMeilleureSuite+2>=GetWindowPortRect(wPlateauPtr).bottom-19 
              then SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,QDGetPortBound().right-16,posVMeilleureSuite+3)
              else SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,QDGetPortBound().right,posVMeilleureSuite+3);
            EraseRectDansWindowPlateau(lignerect); 
            EcritPromptFenetreReflexion;
          end
        else 
          begin
            if avecSystemeCoordonnees 
              then a := aireDeJeu.right + EpaisseurBordureOthellier()
              else a := posHMeilleureSuite;
            if aireDeJeu.bottom+11>=GetWindowPortRect(wPlateauPtr).bottom-19
              then SetRect(lignerect,a,aireDeJeu.bottom+1,QDGetPortBound().right-16,posVMeilleureSuite)
              else SetRect(lignerect,a,aireDeJeu.bottom+1,QDGetPortBound().right,posVMeilleureSuite);
            if (gCouleurOthellier.nomFichierTexture = 'Photographique') then OffsetRect(lignerect,0,1); 
            if not(EnModeEntreeTranscript()) then EraseRectDansWindowPlateau(lignerect); 
            if avecSystemeCoordonnees then DessineBordureDuPlateau2D(kBordureDuBas); 
          end;
      DessineBoiteDeTaille(wPlateauPtr);
      MeilleureSuiteEffacee := true;
      SetPort(oldPort);
    end;
end;

procedure VideMeilleureSuiteInfos;
begin
  MemoryFillChar(@meilleureSuiteInfos,sizeof(meilleureSuiteInfos),chr(0));
end;

procedure GetMeilleureSuiteInfos(var infos:meilleureSuiteInfosRec);
begin
  infos := meilleureSuiteInfos;
end;

procedure SetMeilleureSuiteInfos(var infos:meilleureSuiteInfosRec);
begin
  meilleureSuiteInfos := infos;
end;

function GetMeilleureSuite() : str255;
begin
  if (meilleureSuiteStr <> NIL)
    then GetMeilleureSuite := meilleureSuiteStr^^
    else GetMeilleureSuite := '';
end;

procedure SetMeilleureSuite(s : str255);
begin
  if (meilleureSuiteStr <> NIL)
    then meilleureSuiteStr^^ := s;
end;

procedure DetruitMeilleureSuite;
begin
  meilleureSuiteInfos.statut := NeSaitPas;
  meilleureSuiteInfos.numeroCoup := nbreCoup;
  VideMeilleureSuiteInfos;
  SetMeilleureSuite('');
  EffaceMeilleureSuite;
  MeilleureSuiteEffacee := true;
end;



function MeilleureSuiteInfosEnChaine(nbEspacesEntreCoups : SInt16; avecScore,avecNumeroPremierCoup,enMajuscules,RemplacerScoreIncompletParEtc : boolean;WhichScore : SInt16) : str255;
var i,coup : SInt16; 
    s,s1,s2 : string;
    espaces:str5;
    doitAfficherSi,doitAfficherNumeroCoup : boolean;
    forcerDoitAfficherSi,forcerNePasAfficherSi : boolean;
    chaineMeilleureSuite : str255;
    
    
    function SuiteDesCoups(indexDebut,indexFin : SInt16) : str255;
    var i,coup : SInt16; 
        s,result : str255;
    begin
      with meilleureSuiteInfos do 
        begin
          result := '';
          i := indexDebut;
          while (ligne[i] <> 0) & (i<indexFin) do
		        begin
		         coup := ligne[i];
		         if coup <> 0 then
		           begin
		             if enMajuscules
		               then s := CoupEnStringEnMajuscules(coup)
		               else s := CoupEnStringEnMinuscules(coup);
		             result := result+s+espaces;
		           end;
		         i := i+1;
		        end;
		    end;
      SuiteDesCoups := result;
    end;
    
begin
 chaineMeilleureSuite := '';
 if (Abs(meilleureSuiteInfos.numeroCoup-nbreCoup)>=20) | (nbreCoup=0)
   then 
     VideMeilleureSuiteInfos
   else
     begin 
         with meilleureSuiteInfos do
           begin
              espaces := '';
              for i := 1 to nbEspacesEntreCoups do
                espaces := espaces+StringOf(' ');
                
              
              if debuggage.calculFinaleOptimaleParOptimalite then
                begin
                  WritelnDansRapport('');
                  WritelnDansRapport('Entrée dans MeilleureSuiteInfosEnChaine…');
                  if kNbMaxNiveaux >= -1
                    then
                      begin
	                      for i := -1 to kNbMaxNiveaux do
	                        begin
	                          coup := ligne[i];
	                          WriteDansRapport(CoupEnString(coup,enMajuscules)+' ');
	                        end;
                        WritelnDansRapport('');
                      end
                    else
                      WritelnStringAndNumDansRapport('kNbMaxNiveaux=',kNbMaxNiveaux);
                end;
              
              forcerDoitAfficherSi := false;
              if (statut=ToutEstPerdant) |
                 (statut=ToutEstProbablementPerdant) |
                 (statut=Nulle) |
                 (statut=VictoireBlanche) |
                 (statut=VictoireNoire) 
                then forcerDoitAfficherSi := true;
                
              forcerNePasAfficherSi := false;
              if (nbreCoup > finDePartieOptimale) &
                 (phaseDeLaPartie>=phaseFinale) & 
                 ((statut=ReflAnnonceGagnant) |
                  (statut=ReflAnnonceParfait) |
                  (statut=NeSaitPas))
                then forcerNePasAfficherSi := true;
             
              doitAfficherSi := ((numeroCoup-2<=finDePartieOptimale) & 
                                 (nbreCoup<=finDePartieOptimale) &
                                 (nbreCoup=numeroCoup-2));
                                 
              (* WritelnStringAndBoolDansRapport('au tout début, doitAfficherSi = ',doitAfficherSi); *)
              
              if forcerNePasAfficherSi then doitAfficherSi := false;
              if forcerDoitAfficherSi then doitAfficherSi := true;
                 
              (*
              WritelnStringAndNumDansRapport('numeroCoup = ',numeroCoup);
              WritelnStringAndNumDansRapport('finDePartieOptimale = ',finDePartieOptimale);
              WritelnStringAndNumDansRapport('nbreCoup = ',nbreCoup);
              WritelnStringAndBoolDansRapport('forcerNePasAfficherSi = ',forcerNePasAfficherSi);
              WritelnStringAndBoolDansRapport('forcerDoitAfficherSi = ',forcerDoitAfficherSi);
              WritelnStringAndBoolDansRapport('donc au milieu, doitAfficherSi = ',doitAfficherSi);
              *)
                                
              {doitAfficherNumeroCoup := (phaseDeLaPartie<phaseFinale);}
              doitAfficherNumeroCoup := avecNumeroPremierCoup;
                         
              if RefleSurTempsJoueur &
                 (statut<>ReflAnnonceGagnant) &
                 (statut<>ReflAnnonceParfait) then
              begin
                coup := ligne[-1];
                if (coup<11) | (coup>88)  then coup := 44;
                if doitAfficherSi & partie^^[numeroCoup-1].optimal & (partie^^[numeroCoup-1].coupParfait=coup)
                  then doitAfficherSi := false;
                if forcerNePasAfficherSi then doitAfficherSi := false;
                if forcerDoitAfficherSi then doitAfficherSi := true;
                  
                (*
                WritelnStringAndCoupDansRapport('coup = ',coup);
                WritelnStringAndBoolDansRapport('partie^^[numeroCoup-1].optimal = ',partie^^[numeroCoup-1].optimal);
                WritelnStringAndCoupDansRapport('partie^^[numeroCoup-1].coupParfait = ',partie^^[numeroCoup-1].coupParfait);
                WritelnStringAndBoolDansRapport('donc ensuite, doitAfficherSi = ',doitAfficherSi);
                *)
                
                if (ligne[-1]=ligne[0]) then 
                  begin
                    coup := 44;
                    if doitAfficherSi then
                      begin
                        GetIndString(s,TextesPlateauID,10);  {si}
                        NumToString(numeroCoup-1,s1);
                        chaineMeilleureSuite := s+StringOf(' ')+s1+StringOf('.');
                      end;
                  end;
                if PossibleMove[coup] then
                  begin
                    if enMajuscules
                      then s2 := CoupEnStringEnMajuscules(coup)
                      else s2 := CoupEnStringEnMinuscules(coup);
                    if doitAfficherSi 
                      then 
                        begin
                          GetIndString(s,TextesPlateauID,10);  {si}
                          NumToString(numeroCoup-1,s1);
                          chaineMeilleureSuite := s+StringOf(' ')+s1+StringOf('.')+s2+', ';
                        end
                      else chaineMeilleureSuite := chaineMeilleureSuite+s2+espaces;
                  end;
              end;
              
              if (statut=ToutEstPerdant) | 
                 (statut=ReflAnnonceGagnant) | 
                 (statut=ReflAnnonceParfait) |
                 (statut=ToutEstProbablementPerdant)
                then
                  begin
                    case statut of
                      ReflAnnonceGagnant        : GetIndString(s,TextesPlateauID,7);  {rech. coup gagnant (finale)}
                      ReflAnnonceParfait        : GetIndString(s,TextesPlateauID,8);  {rech. meilleur coup (finale)}
                      ToutEstPerdant            : 
                        if avecScore 
                          then
		                        begin  {'tous les coups ^0 sont perdants'}
		                          GetIndString(s,TextesPlateauID,11);
		                          s := ParamStr(s,PourcentageEntierEnString(numeroCoup),'','','');
		                        end
		                      else
		                        s := '';
                      ToutEstProbablementPerdant: 
                        if avecScore
                          then
		                        begin  {'tous les coups ^0 sont probablement perdants'}
		                          GetIndString(s,TextesPlateauID,12);
		                          s := ParamStr(s,PourcentageEntierEnString(numeroCoup),'','','');
		                        end
		                      else
		                        s := '';
                    end;
                    chaineMeilleureSuite := chaineMeilleureSuite+s;
                  end
                else
                  begin
                   
                    if doitAfficherNumeroCoup & 
                       not((Statut=NeSaitPas) & (phaseDeLaPartie>=phaseFinale)) then 
                      begin
                        NumToString(numeroCoup,s1);
                        chaineMeilleureSuite := chaineMeilleureSuite+s1+StringOf('.');
                      end;
                  
                    coup := ligne[0];
                    if (coup>=11) & (coup<=88) then
                      begin
                        if enMajuscules
                          then s := CoupEnStringEnMajuscules(coup)
                          else s := CoupEnStringEnMinuscules(coup);
                        chaineMeilleureSuite := chaineMeilleureSuite+s+espaces;
                      end;
                    
                    if (statut=NeSaitPas)  
                      then
	                      begin
	                        chaineMeilleureSuite := chaineMeilleureSuite + SuiteDesCoups(1,kNbMaxNiveaux);
	                        
	                        if avecScore & (phaseDeLaPartie>=phaseFinale) & (score.noir+score.blanc > 0) then
	                          begin
		                          if RemplacerScoreIncompletParEtc & (score.noir+score.blanc < 64)
		                            then 
		                              begin
		                                chaineMeilleureSuite := chaineMeilleureSuite+'etc.';
		                                if WhichScore > 0 
		                                   then chaineMeilleureSuite := Concat('+',NumEnString(WhichScore),' : ',chaineMeilleureSuite);
		                                if WhichScore = 0 
		                                   then chaineMeilleureSuite := Concat('= : ',chaineMeilleureSuite);
		                                if WhichScore < 0 
		                                   then chaineMeilleureSuite := Concat(NumEnString(WhichScore),' : ',chaineMeilleureSuite);
		                              end
		                            else
			                            begin
			                              NumToString(score.noir,s);
			                              NumToString(score.blanc,s1);
			                              s := StringOf(' ')+s+StringOf('-')+s1;
			                              chaineMeilleureSuite := chaineMeilleureSuite+s;
			                            end;
				                    end; 
	                      end
                      else
                        begin
                          if avecScore then
                            begin
                              s := '';
		                          if statut=Nulle 
                                 then GetIndString(s,TextesPlateauID,13)  {annule}
                                 else
                                   begin
                                     if ((statut=VictoireNoire) & (couleur = pionNoir)) |
                                        ((statut=VictoireBlanche) & (couleur = pionBlanc))
                                        then GetIndString(s,TextesPlateauID,14)  {est gagnant}
                                        else GetIndString(s,TextesPlateauID,15); {est perdant}
                                   end;
		                           chaineMeilleureSuite := chaineMeilleureSuite + s;
		                           
		                           
		                           s := NumEnString(numeroCoup) + StringOf('.') + SuiteDesCoups(0,kNbMaxNiveaux);
		                           if RemplacerScoreIncompletParEtc
		                             then s := ' (' + s + 'etc.)'
		                             else s := ' (' + s + ')';
		                             
		                           chaineMeilleureSuite := chaineMeilleureSuite + s;
		                         end;
                        end;
                  end;
          end;
     end;
  MeilleureSuiteInfosEnChaine := chaineMeilleureSuite;
end;

function MeilleureSuiteEtNoteEnChaine(coul,note,profondeur : SInt16) : str255;
var s,s1 : str255;
    penaliteAjoutee,aux : SInt32;
begin
  s := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0);
  if odd(profondeur)
    then penaliteAjoutee := penalitePourTraitAff
    else penaliteAjoutee := -penalitePourTraitAff;
  note := note+penaliteAjoutee;
  if coul = pionNoir
    then s := s+': '+CaracterePourNoir
    else s := s+': '+CaracterePourBlanc;
  if note>=0 
    then s := s+'+'
    else 
      begin
        s := s+'-';
        note := -note;
      end;
  if utilisationNouvelleEval
    then
      begin
        aux := note div 100;
        NumToString(aux,s1);
        s := s+s1+'.';
        note := note - (aux*100);
        NumToString(note,s1);
        if note < 10 then s1 := StringOf('0')+s1;
      end
    else NumToString(note,s1);
  MeilleureSuiteEtNoteEnChaine := s+s1;
end;


{ nbDecimales doit etre 1 ou 2 }
function NoteEnString(note : SInt32;avecSignePlus : boolean;nbEspacesDevant,nbDecimales : SInt16) : str255;
var s : str255;
    aux : SInt32;
begin
  s := '';
  for aux := 1 to nbEspacesDevant do 
     s := s+' ';
  if note<0 
    then
      begin
        s := s+'-';
        note := -note;
      end
    else
      if avecSignePlus 
        then s := s+'+';
  if utilisationNouvelleEval
    then
      begin
        if nbDecimales=2
          then
            begin
              aux := note div 100;
			        note := note-aux*100;
			        if note<10
			          then NoteEnString := s+NumEnString(aux)+'.0'+NumEnString(note)
			          else NoteEnString := s+NumEnString(aux)+'.'+NumEnString(note);
            end
          else
            begin
              aux := note div 100;
			        note := note-aux*100;
			        NoteEnString := s+NumEnString(aux)+'.'+NumEnString(note div 10)
            end;
      end
    else
      NoteEnString := s+NumEnString(note);
end;


procedure EcritMeilleureSuite;
var marge,a : SInt32;
    s : string;
    oldPort : grafPtr;
    ligneRect : rect;
begin
         
 if (Abs(meilleureSuiteInfos.numeroCoup-nbreCoup) >= 20) | (nbreCoup = 0)
   then
     begin
       DetruitMeilleureSuite;
     end
   else
     begin
       if windowPlateauOpen then
         begin
           GetPort(oldPort);
           SetPortByWindow(wPlateauPtr);
           
           if CassioEstEn3D()
             then
               begin
                 if posVMeilleureSuite+2>=GetWindowPortRect(wPlateauPtr).bottom-19
                   then SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,GetWindowPortRect(wPlateauPtr).right-16,posVMeilleureSuite+3)
                   else SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,5000,posVMeilleureSuite+3);
                 EraseRectDansWindowPlateau(lignerect);
                 EcritPromptFenetreReflexion;
                 marge := posHMeilleureSuite;
               end
             else
               begin
                 if avecSystemeCoordonnees 
			              then a := aireDeJeu.right + EpaisseurBordureOthellier()
			              else a := 0;
                 if aireDeJeu.bottom+11>=GetWindowPortRect(wPlateauPtr).bottom-19
                   then SetRect(lignerect,a,aireDeJeu.bottom+1,GetWindowPortRect(wPlateauPtr).right-16,posVMeilleureSuite)
                   else SetRect(lignerect,a,aireDeJeu.bottom+1,aireDeJeu.right+230,posVMeilleureSuite);
                 if (gCouleurOthellier.nomFichierTexture = 'Photographique') then OffsetRect(lignerect,0,1);  
                 if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
                   then marge := aireDeJeu.left+3
                   else marge := aireDeJeu.left+3;
                 if not(EnModeEntreeTranscript()) then EraseRectDansWindowPlateau(lignerect);
                 if avecSystemeCoordonnees then DessineBordureDuPlateau2D(kBordureDuBas); 
               end;   
          
           s := GetMeilleureSuite();
           s := s + ' ';
           
           PrepareTexteStatePourMeilleureSuite;
           Moveto(marge,lignerect.bottom-2);
           DrawString(s);
           MeilleureSuiteEffacee := false;
           
           if gCassioUseQuartzAntialiasing then
             if (SetAntiAliasedTextEnabled(true,9) = NoErr) then;
          
           SetPort(oldPort);
         end;
     end;
  
end;

procedure EcritMeilleureSuiteParOptimalite;
var ok : boolean;
begin
  SauvegardeMeilleureSuiteParOptimalite(ok);
  if ok then SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0));
  if afficheMeilleureSuite & ok then EcritMeilleureSuite;
end;

function GetStatutMeilleureSuite() : SInt32;
begin
  GetStatutMeilleureSuite := meilleureSuiteInfos.statut;
end;

procedure SetStatutMeilleureSuite(leStatut : SInt32);
begin
  meilleureSuiteInfos.statut := leStatut;
end;

END.