UNIT UnitSaisiePartie;



INTERFACE







USES MacTypes,UnitOth0;
     

const 
  kNbJoueursMenuSaisie = 35;  {attention! ne pas depasser 35. Ou alors changer UnitPrefs}
  kNbTournoisMenuSaisie = 35;

var 
  gInfosSaisiePartie :
    record
      tableDerniersJoueurs : array[1..kNbJoueursMenuSaisie] of SInt32;
      tableDerniersTournois : array[1..kNbTournoisMenuSaisie] of SInt32;
      derniereAnnee : SInt32;
      dernierJoueurNoir : SInt32;
      dernierJoueurBlanc : SInt32;
      dernierTournoi : SInt32;
      derniereDistribution : SInt32;
      enregistrementAutomatique : boolean;
      
      picture:PicHandle;
      parametresOthellier:ParamDiagRec;
      positionEtCoupSaisieStr:str185;
    end;

procedure InitUnitSaisiePartie;
procedure LibereMemoireUnitSaisiePartie;

procedure AjouteNouveauJoueurTableSaisiePartie(nroJoueur : SInt32);
procedure AjouteNouveauTournoiTableSaisiePartie(nroTournoi : SInt32);
procedure SetNiemeJoueurTableSaisiePartie(N,nroJoueur : SInt32);
function GetNiemeJoueurTableSaisiePartie(N : SInt32) : SInt32;
procedure SetNiemeTournoiTableSaisiePartie(N,nroTournoi : SInt32);
function GetNiemeTournoiTableSaisiePartie(N : SInt32) : SInt32;

procedure CreatePopUpMenuJoueurs;
procedure MetLesNomsDansPopUpMenuJoueurs;
procedure KillPopUpMenuJoueurs;
procedure CreatePopUpMenuTournois;
procedure MetLesNomsDansPopUpMenuTournois;
procedure KillPopUpMenuTournois;
procedure CreatePopUpMenuBases;
procedure KillPopUpMenuBases;

procedure DialogueSaisiePartie;


IMPLEMENTATION







USES UnitBaseNouveauFormat,UnitEntreesSortiesListe,UnitCarbonisation,UnitAccesStructuresNouvFormat,
     UnitUtilitaires,UnitJaponais,MyFileSystemUtils,UnitListe,MyEvents,UnitMacExtras,UnitDialog,UnitOth2,
     UnitNewGeneral,UnitDiagramFforum,MyStrings,SNStrings,UnitRapport,UnitFenetres;


const
  {dialogue de saisie}
  SaisiePartieID = 132;
  OK = 1;
  Annuler = 2;
  PartieRentreeStatic = 3;
  NoirEditableText = 6;
  BlancEditableText = 7;
  TournoiEditableText = 8;
  AnneeEditableText = 9;
  NoirStaticText = 10;
  BlancStaticText = 11;
  TournoiStaticText = 12;
  AnneeStaticText = 13;
  MenuNoirUserItemPopUp = 14;
  MenuBlancUserItemPopUp = 15;
  MenuTournoiUserItemPopUp = 16;
  AjouterAutomatiquementCheckBox = 17;
  NomBaseUserItemPopUp = 18;
  
  VirtualSelectAllItemInDialog = 2001;

const
  {menus des joueurs et des tournois}
  MenuSaisieJoueursNoirsID = 3007;
  MenuSaisieTournoisID = 3008;
  MenuSaisieJoueursBlancsID = 3009;
  MenuSaisieBasesID = 3010;

var menuNoirsFlottant : MenuRef;
    menuNoirsRect: rect;
    menuBlancsFlottant : MenuRef;
    menuBlancsRect : rect;
    menuTournoisFlottant : MenuRef;
    menuTournoisRect : rect;
    popUpBasesSaisie : menuFlottantBasesRec;
    dialogueSaisie  : DialogPtr;
    focus : SInt32;    {item actif dans le dialogue}
    dernierEventSaisie : EventRecord;
    dernierNoirDessine : SInt32;
    dernierBlancDessine : SInt32;
    dernierTournoiDessine : SInt32;
    derniereAnneeDessinee : SInt32;
    chaineAvantDeleteDlgSaisie : str255;
    
    debuggage_saisiePartie : boolean;

procedure InitUnitSaisiePartie;
var i : SInt32;
    myDate : DateTimeRec;
begin
  with gInfosSaisiePartie do
    begin
		  for i := 1 to kNbJoueursMenuSaisie do
		    tableDerniersJoueurs[i] := i-1;
		  for i := 1 to kNbTournoisMenuSaisie do
		    tableDerniersTournois[i] := i-1;
		  GetTime(myDate);
		  derniereAnnee := myDate.year;
		  dernierJoueurNoir := 0;
		  dernierJoueurBlanc := 0;
		  dernierTournoi := 0;
		  derniereDistribution := 0;
		  enregistrementAutomatique := false;
		  
		  picture := NIL;
		  positionEtCoupSaisieStr := '';
		  
		  NewParamDiag(parametresOthellier);
		  SetValeursParDefautDiagFFORUM(parametresOthellier,DiagrammePosition);
		  parametresOthellier.tailleCaseFFORUM := 20;
      parametresOthellier.TraitsFinsFFORUM := true;
      parametresOthellier.epaisseurCadreFFORUM := 2.0;
      parametresOthellier.PionsEnDedansFFORUM := false;
      parametresOthellier.EcritNomTournoiFFORUM := false;
      parametresOthellier.EcritNomsJoueursFFORUM := true;
      parametresOthellier.EcritApres37c7FFORUM := false;
      parametresOthellier.FondOthellierPatternFFORUM := kGrayPattern;
			parametresOthellier.couleurOthellierFFORUM := kCouleurDiagramVert;
      
      
		end;
  
  dialogueSaisie := NIL;
  
  debuggage_saisiePartie := false;
end;

procedure LibereMemoireUnitSaisiePartie;
begin
  DisposeParamDiag(gInfosSaisiePartie.parametresOthellier);

  dialogueSaisie := NIL;
end;

function PasLaDistributionWThor(nroDistribution : SInt16) : boolean;
begin
  PasLaDistributionWThor := (nroDistribution >= 1) & 
                            (nroDistribution <= DistributionsNouveauFormat.nbDistributions) &
                            EstUneDistributionDeParties(nroDistribution) & 
                            (Pos('WThor',GetNomUsuelDistribution(nroDistribution)) <= 0);
end;

procedure AjouteNouveauJoueurTableSaisiePartie(nroJoueur : SInt32);
var i,k : SInt32;
    dejaDansTable : boolean;
begin
  if debuggage_saisiePartie then
    WritelnStringAndNumDansRapport('entree dans AjouteNouveauJoueurTableSaisiePartie, nroJoueur = ',nroJoueur);
  
  if debuggage_saisiePartie then
    begin
      WritelnDansRapport('  …table avant l''insertion :');
      for i := 1 to kNbJoueursMenuSaisie do
        begin
          WriteStringAndNumDansRapport('tableDerniersJoueurs[',i);
          WriteStringAndNumDansRapport('] = ',gInfosSaisiePartie.tableDerniersJoueurs[i]);
          WritelnDansRapport('  -> '+GetNomJoueur(gInfosSaisiePartie.tableDerniersJoueurs[i]));
        end;
    end;
  
  with gInfosSaisiePartie do
    if nroJoueur >= 0 then
	    begin
			  dejaDansTable := false;
			  for i := 1 to kNbJoueursMenuSaisie do
			    if (tableDerniersJoueurs[i] = nroJoueur) & not(dejaDansTable) then
			      begin
			        dejaDansTable := true;
			        if i > 1 then
			          begin
			            {on le promeut en tete}
			            for k := i downto 2 do
			              tableDerniersJoueurs[k] := tableDerniersJoueurs[k-1];
			            tableDerniersJoueurs[1] := nroJoueur;
			          end;
			      end;
			  if not(dejaDansTable) then
			    begin
			      {on le rajoute en tete, last in first out}
			      for k := kNbJoueursMenuSaisie downto 2 do
			         tableDerniersJoueurs[k] := tableDerniersJoueurs[k-1];
			      tableDerniersJoueurs[1] := nroJoueur;
			    end;
			end;
	
	if debuggage_saisiePartie then
    begin
    	WritelnDansRapport('  …table apres l''insertion :');
      for i := 1 to kNbJoueursMenuSaisie do
        begin
          WriteStringAndNumDansRapport('tableDerniersJoueurs[',i);
          WriteStringAndNumDansRapport('] = ',gInfosSaisiePartie.tableDerniersJoueurs[i]);
          WritelnDansRapport('  -> '+GetNomJoueur(gInfosSaisiePartie.tableDerniersJoueurs[i]));
        end;
    end;
    
  if debuggage_saisiePartie then
    WritelnStringAndNumDansRapport('sortie de AjouteNouveauJoueurTableSaisiePartie, nroJoueur = ',nroJoueur);
  
end;

procedure AjouteNouveauTournoiTableSaisiePartie(nroTournoi : SInt32);
var i,k : SInt32;
    dejaDansTable : boolean;
begin
  with gInfosSaisiePartie do
    if nroTournoi >= 0 then
	    begin
			  dejaDansTable := false;
			  for i := 1 to kNbTournoisMenuSaisie do
			    if (tableDerniersTournois[i] = nroTournoi) & not(dejaDansTable) then
			      begin
			        dejaDansTable := true;
			        if i > 1 then
			          begin
			            {on le promeut en tete}
			            for k := i downto 2 do
			              tableDerniersTournois[k] := tableDerniersTournois[k-1];
			            tableDerniersTournois[1] := nroTournoi;
			          end;
			      end;
			  if not(dejaDansTable) then
			    begin
			      {on le rajoute en tete, last in first out}
			      for k := kNbTournoisMenuSaisie downto 2 do
			         tableDerniersTournois[k] := tableDerniersTournois[k-1];
			      tableDerniersTournois[1] := nroTournoi;
			    end;
			end;
end;

procedure SetNiemeJoueurTableSaisiePartie(N,nroJoueur : SInt32);
begin
  if (N >= 1) & (N <= kNbJoueursMenuSaisie) then
    gInfosSaisiePartie.tableDerniersJoueurs[N] := nroJoueur;
end;

function GetNiemeJoueurTableSaisiePartie(N : SInt32) : SInt32;
begin
  if (N >= 1) & (N <= kNbJoueursMenuSaisie)
    then GetNiemeJoueurTableSaisiePartie := gInfosSaisiePartie.tableDerniersJoueurs[N]
    else GetNiemeJoueurTableSaisiePartie := -1;
end;

procedure SetNiemeTournoiTableSaisiePartie(N,nroTournoi : SInt32);
begin
  if (N >= 1) & (N <= kNbTournoisMenuSaisie) then
    gInfosSaisiePartie.tableDerniersTournois[N] := nroTournoi;
end;

function GetNiemeTournoiTableSaisiePartie(N : SInt32) : SInt32;
begin
  if (N >= 1) & (N <= kNbTournoisMenuSaisie)
    then GetNiemeTournoiTableSaisiePartie := gInfosSaisiePartie.tableDerniersTournois[N]
    else GetNiemeTournoiTableSaisiePartie := -1;
end;

procedure CreatePopUpMenuJoueurs;
begin

  GetDialogItemRect(dialogueSaisie,MenuNoirUserItemPopUp,menuNoirsRect);
  menuNoirsFlottant := MyGetMenu(MenuSaisieJoueursNoirsID);
  InsertMenu(menuNoirsFlottant, -1);
  
  GetDialogItemRect(dialogueSaisie,MenuBlancUserItemPopUp,menuBlancsRect);
  menuBlancsFlottant := MyGetMenu(MenuSaisieJoueursBlancsID);
  InsertMenu(menuBlancsFlottant, -1);
  
end;

procedure MetLesNomsDansPopUpMenuJoueurs;
var nbItem,N,k,numero : SInt32;
    menuItemString,s : str255;
begin
    begin
      if menuBlancsFlottant <> NIL then
        begin
          MyUnlockMenu(menuBlancsFlottant);
          nbItem := MyCountMenuItems(menuBlancsFlottant);
          for N := nbItem downto 3 do
            DeleteMenuItem(menuBlancsFlottant,N);
          for N := 1 to kNbJoueursMenuSaisie do
            begin
              numero := GetNiemeJoueurTableSaisiePartie(N);
              s := GetNomJoueur(numero);
              menuItemString := '';
              for k := 1 to Length(s) do
                if s[k] = '(' then menuItemString := menuItemString + '[' else
                if s[k] = ')' then menuItemString := menuItemString + ']' else
                if s[k] = '<' then menuItemString := menuItemString + '«' else
                if s[k] = '>' then menuItemString := menuItemString + '»' else
                if s[k] = '-' then menuItemString := menuItemString + '–' else
                if s[k] = ';' then menuItemString := menuItemString + ',' else
                if s[k] = '^' then menuItemString := menuItemString + '*' else
                if s[k] = '/' then menuItemString := menuItemString + '\' else
                if s[k] = '!' then menuItemString := menuItemString + '?' else
                  menuItemString := menuItemString + s[k];
              AppendMenu(menuBlancsFlottant,menuItemString);
            end;
        end;
    end;
  
    begin
      if menuNoirsFlottant <> NIL then
        begin
          MyUnlockMenu(menuNoirsFlottant);
          nbItem := MyCountMenuItems(menuNoirsFlottant);
          for N := nbItem downto 3 do
            DeleteMenuItem(menuNoirsFlottant,N);
          for N := 1 to kNbJoueursMenuSaisie do
            begin
              numero := GetNiemeJoueurTableSaisiePartie(N);
              s := GetNomJoueur(numero);
              menuItemString := '';
              for k := 1 to Length(s) do
                if s[k] = '(' then menuItemString := menuItemString + '[' else
                if s[k] = ')' then menuItemString := menuItemString + ']' else
                if s[k] = '<' then menuItemString := menuItemString + '«' else
                if s[k] = '>' then menuItemString := menuItemString + '»' else
                if s[k] = '-' then menuItemString := menuItemString + '–' else
                if s[k] = ';' then menuItemString := menuItemString + ',' else
                if s[k] = '^' then menuItemString := menuItemString + '*' else
                if s[k] = '/' then menuItemString := menuItemString + '\' else
                if s[k] = '!' then menuItemString := menuItemString + '?' else
                  menuItemString := menuItemString + s[k];
              AppendMenu(menuNoirsFlottant,menuItemString);
            end;
          
        end;
    end;
end;

procedure KillPopUpMenuJoueurs;
begin
  DeleteMenu(MenuSaisieJoueursNoirsID);
  TerminateMenu(menuNoirsFlottant,true);
  
  DeleteMenu(MenuSaisieJoueursBlancsID);
  TerminateMenu(menuBlancsFlottant,true);
end;

procedure CreatePopUpMenuTournois;
begin
  GetDialogItemRect(dialogueSaisie,MenuTournoiUserItemPopUp,menuTournoisRect);
  menuTournoisFlottant := MyGetMenu(MenuSaisieTournoisID);
  InsertMenu(menuTournoisFlottant, -1);
end;

procedure MetLesNomsDansPopUpMenuTournois;
var nbItem,N,k,numero : SInt32;
    menuItemString,s : str255;
begin
  begin
      if menuTournoisFlottant <> NIL then
        begin
          MyUnlockMenu(menuTournoisFlottant);
          nbItem := MyCountMenuItems(menuTournoisFlottant);
          for N := nbItem downto 3 do
            DeleteMenuItem(menuTournoisFlottant,N);
          for N := 1 to kNbTournoisMenuSaisie do
            begin
              numero := GetNiemeTournoiTableSaisiePartie(N);
              s := GetNomTournoi(numero);
              menuItemString := '';
              for k := 1 to Length(s) do
                if s[k] = '(' then menuItemString := menuItemString + '[' else
                if s[k] = ')' then menuItemString := menuItemString + ']' else
                if s[k] = '<' then menuItemString := menuItemString + '«' else
                if s[k] = '>' then menuItemString := menuItemString + '»' else
                if s[k] = '-' then menuItemString := menuItemString + '–' else
                if s[k] = ';' then menuItemString := menuItemString + ',' else
                if s[k] = '^' then menuItemString := menuItemString + '*' else
                if s[k] = '/' then menuItemString := menuItemString + '\' else
                if s[k] = '!' then menuItemString := menuItemString + '?' else
                  menuItemString := menuItemString + s[k];
              AppendMenu(menuTournoisFlottant,menuItemString);
            end;
        end;
    end;
end;

procedure KillPopUpMenuTournois;
begin
  DeleteMenu(MenuSaisieTournoisID);
  TerminateMenu(menuTournoisFlottant,true);
end;


procedure CreatePopUpMenuBases;
begin
  with popUpBasesSaisie do
    begin
      GetDialogItemRect(dialogueSaisie,NomBaseUserItemPopUp,menuBasesRect);
      InstalleMenuFlottantBases(popUpBasesSaisie,MenuSaisieBasesID,PasLaDistributionWThor);
    end;
end;

procedure KillPopUpMenuBases;
begin
  DesinstalleMenuFlottantBases(popUpBasesSaisie);
end;

procedure InvalidateDerniersParametresDessines;
begin
  dernierNoirDessine := -1;
  dernierBlancDessine := -1;
  dernierTournoiDessine := -1;
  derniereAnneeDessinee := -1;
end;

procedure DessineExamplePictureSaisie;
var oldParamDiagrammes:ParamDiagRec;
    oldPort : grafPtr;
    chainePositionInitiale,chaineCoups,s : str255;
    oldClipRgn : RgnHandle;
    unRect : rect;
    newPort : CGrafPtr;
    nbPionsNoirs : SInt32;
    tempo : boolean;
begin
  with gInfosSaisiePartie do
    if (dialogueSaisie <> NIL) &
       ((dernierJoueurNoir <> dernierNoirDessine) | (dernierJoueurBlanc <> dernierBlancDessine) |
        (dernierTournoi <> dernierTournoiDessine) | (derniereAnnee <> derniereAnneeDessinee)) then
    begin
      GetPort(oldport);
			SetPortByDialog(dialogueSaisie);
					
			NewParamDiag(oldParamDiagrammes);
		  GetParamDiag(oldParamDiagrammes);
		  SetParamDiag(parametresOthellier);
		  
		  if debuggage_saisiePartie then WritelnDansRapport('avant ConstruitPositionEtCoupDapresPartie');
		  
		  ConstruitPositionEtCoupDapresPartie(positionEtCoupSaisieStr);
		  ParserPositionEtCoupsOthello8x8(positionEtCoupSaisieStr,chainePositionInitiale,chaineCoups);
		  
		  

		  
		  tempo := differencierLesFreres;
		  differencierLesFreres := true;
		  if nbreDePions[pionNoir] > nbreDePions[pionBlanc] then nbPionsNoirs := 64 - nbreDePions[pionBlanc] else
		  if nbreDePions[pionNoir] = nbreDePions[pionBlanc] then nbPionsNoirs := 32 else
		  if nbreDePions[pionNoir] < nbreDePions[pionBlanc] then nbPionsNoirs := nbreDePions[pionNoir];
		  ConstruitTitrePartie(GetNomJoueurSansPrenom(dernierJoueurNoir),GetNomJoueurSansPrenom(dernierJoueurBlanc),true,nbPionsNoirs,s);
		  ParamDiagCourant.CommentPositionFFORUM^^ := s;
		  ParamDiagCourant.titreFFORUM^^ := EnleveEspacesDeDroite(GetNomTournoi(dernierTournoi))+' '+NumEnString(derniereAnnee);
		  differencierLesFreres := tempo;
		  
		  {WritelnDansRapport('chainePositionInitiale = '+chainePositionInitiale);
		   WritelnDansRapport('chaineCoups = '+chaineCoups);}
		  
		  if debuggage_saisiePartie then WritelnDansRapport('avant NewRgn');
		  
		  {d'abord dessiner la position finale}
		  if (dernierJoueurNoir <> dernierNoirDessine) | (dernierJoueurBlanc <> dernierBlancDessine) then
		    begin
		      ParamDiagCourant.typeDiagrammeFFORUM := DiagrammePosition;
				  
				  newPort := CreateNewPort();
				  SetPort(GrafPtr(newPort));
				  oldClipRgn := NewRgn();
				  Getclip(oldClipRgn);
				  ClipRect(QDGetPortBound());
				  SetRect(unrect,0,0,LargeurDiagrammeFFORUM(), HauteurDiagrammeFFORUM());
				  
				  picture := OpenPicture(unrect);
				  ConstruitPositionPicture(ConstruitChainePosition8x8(jeuCourant),chaineCoups);
				  ClosePicture;
				  SetClip(oldclipRgn);
				  DisposeRgn(oldclipRgn);
				  SetPortByDialog(dialogueSaisie);
				  DisposePort(newPort);
				  
				  
				  if picture <> NIL then
				    begin
						  SetRect(unRect, 80, 50, 299, 255);
				      EraseRect(unRect);
				      SetOrigin(-unRect.left, -unRect.top);
				      unRect := picture^^.picframe;
						  DrawPicture(picture,unRect);
						  SetOrigin(0, 0);
				      KillPicture(picture);
				      picture := NIL;
						end;
		    end;
		  
		  {puis le transcript}
		  if (dernierTournoi <> dernierTournoiDessine) | (derniereAnnee <> derniereAnneeDessinee) then
		    begin
				  ParamDiagCourant.typeDiagrammeFFORUM := DiagrammePartie;
				  
				  newPort := CreateNewPort();
				  SetPort(GrafPtr(newPort));
				  oldClipRgn := NewRgn();
				  Getclip(oldClipRgn);
				  ClipRect(QDGetPortBound());
				  SetRect(unRect,0,0,LargeurDiagrammeFFORUM(), HauteurDiagrammeFFORUM());
				  
				  if debuggage_saisiePartie then WritelnDansRapport('avant OpenPicture');
				  
				  picture := OpenPicture(unRect);
				  ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
				  ClosePicture;
				  SetClip(oldclipRgn);
				  DisposeRgn(oldclipRgn);
				  SetPortByDialog(dialogueSaisie);
				  DisposePort(newPort);
				  
				
				  if picture <> NIL then
				    begin
				      SetRect(unRect, 300, 50, 1000, 255);
				      EraseRect(unRect);
				      SetOrigin(-unRect.left, -unRect.top);
				      unRect := picture^^.picframe;
						  DrawPicture(picture,unRect);
						  SetOrigin(0, 0);
				      KillPicture(picture);
				      picture := NIL;
				    end;
		    end;
		  
		  if debuggage_saisiePartie then WritelnDansRapport('avant SetParamDiag(oldParamDiagrammes)');
		  
		  SetParamDiag(oldParamDiagrammes);
		  DisposeParamDiag(oldParamDiagrammes);
		  SetPort(oldport);
		  
		  dernierNoirDessine := dernierJoueurNoir;
      dernierBlancDessine := dernierJoueurBlanc;
      dernierTournoiDessine := dernierTournoi;
      derniereAnneeDessinee := derniereAnnee;
		end;
end;


function FiltreDialogueSaisie(dlog : DialogPtr; var evt: eventrecord; var item : SInt16): boolean;
begin
  
  {
  if debuggage_saisiePartie then
    begin
      writelnDansRapport('dans FiltreDialogueSaisie');
      xClavier;
    end;
  }
  
	FiltreDialogueSaisie := false;
	if not(EvenementDuDialogue(dlog, evt)) then
		FiltreDialogueSaisie := MyFiltreClassiqueRapide(dlog, evt, item)
	else
		begin
		  dernierEventSaisie := evt;
		  case evt.what of
				updateEvt: 
					begin
						item := VirtualUpdateItemInDialog;
						FiltreDialogueSaisie := true;
					end;
			  keyDown :
			    { commande-'A'  => on selectionne tout }
			    if EventHasCommandKey(evt) &
			       ((BAND(evt.message,charcodemask)=ord('a')) | (BAND(evt.message,charcodemask)=ord('A')))
			      then
			        begin
			          item := VirtualSelectAllItemInDialog;
						    FiltreDialogueSaisie := true;
			        end
			      else
			    if not(EventHasCommandKey(evt)) & (BAND(evt.message,charcodemask)=RetourArriereKey)
			      then
			        begin
			          case focus of
			            NoirEditableText,BlancEditableText,TournoiEditableText,AnneeEditableText :
			              GetItemTextInDialog(dialogueSaisie,focus,chaineAvantDeleteDlgSaisie);
			            otherwise
			              chaineAvantDeleteDlgSaisie := '';
			          end; {case}
			          FiltreDialogueSaisie := MyFiltreClassiqueRapide(dlog, evt, item);
			        end
			      else
			        FiltreDialogueSaisie := MyFiltreClassiqueRapide(dlog, evt, item);
			  mouseDown: 
					begin
						FiltreDialogueSaisie := MyFiltreClassiqueRapide(dlog, evt, item);
					end;
			  mouseUp: 
					begin
						FiltreDialogueSaisie := MyFiltreClassiqueRapide(dlog, evt, item);
					end;
				otherwise
					FiltreDialogueSaisie := MyFiltreClassiqueRapide(dlog, evt, item);
			end; {case}
		end;
end;

procedure DessineDialogueSaisie;
var oldPort : grafPtr;
begin
  if dialogueSaisie <> NIL then
    begin
      GetPort(oldPort);
		  SetPortByDialog(dialogueSaisie);
		  MyDrawDialog(dialogueSaisie);
			DrawPUItem(menuNoirsFlottant, 1, menuNoirsRect, false);
			DrawPUItem(menuBlancsFlottant, 1, menuBlancsRect, false);
			DrawPUItem(menuTournoisFlottant, 1, menuTournoisRect, false);
			DrawPUItem(popUpBasesSaisie.menuFlottantBases,popUpBasesSaisie.itemCourantMenuBases,popUpBasesSaisie.menuBasesRect,false);
			DessineExamplePictureSaisie;
			OutlineOK(dialogueSaisie);
			SetPort(oldPort);
		end;
end;

procedure ChangeFocusDialogueSaisie(newFocus : SInt32);
var oldFocus : SInt32;
begin
  oldFocus := focus;
  if newFocus <> oldFocus then
    begin
      if debuggage_saisiePartie then WritelnDansRapport('dans ChangeFocusDialogueSaisie');
		    
      focus := newFocus;
      if oldFocus = NoirEditableText then
        AjouteNouveauJoueurTableSaisiePartie(gInfosSaisiePartie.dernierJoueurNoir);
      if oldFocus = BlancEditableText then
        AjouteNouveauJoueurTableSaisiePartie(gInfosSaisiePartie.dernierJoueurBlanc);
      if oldFocus = TournoiEditableText then
        AjouteNouveauTournoiTableSaisiePartie(gInfosSaisiePartie.dernierTournoi);
			MetLesNomsDansPopUpMenuJoueurs;
			MetLesNomsDansPopUpMenuTournois;
    end;
end;

procedure DialogueSaisiePartie;
var FiltreDialogueSaisieUPP : modalFilterUPP;
    dernierCaractereEtaitFautif : boolean;
    itemHit,i,menuItem : SInt16; 
    nbItem,numero : SInt32;
    numeroReferencePartie : SInt32;
    nbCoupsIdentiques : SInt32;
	  s,s1 : str255;
	  nomBase,pathBase,prompt : str255;
	  mySpec : FSSpec;
	  err : OSErr;
	  oldPort : grafPtr;
	  partieRec:t_PartieRecNouveauFormat;
	  reply : SFReply;
	  dansListe : boolean;
	  action:ActionEcraserPartie;
begin
  if debuggage_saisiePartie then SetEcritToutDansRapportLog(true);

  if not(JoueursEtTournoisEnMemoire) &
     avecGestionBase & not(problemeMemoireBase) then
     DoLectureJoueursEtTournoi(false);
  if not(JoueursNouveauFormat.dejaTriesAlphabetiquement) then
    begin
      TrierAlphabetiquementJoueursNouveauFormat;
      if gVersionJaponaiseDeCassio & gHasJapaneseScript
        then err := LitNomsDesJoueursEnJaponais();
    end;
     
  itemHit := -1;
  BeginDialog;
  SwitchToScript(gLastScriptUsedInDialogs);
  FiltreDialogueSaisieUPP := NewModalFilterUPP(@FiltreDialogueSaisie);
  dialogueSaisie := MyGetNewDialog(SaisiePartieID,FenetreFictiveAvantPlan());
  if dialogueSaisie <> NIL then
    begin
      CreatePopUpMenuJoueurs;
      CreatePopUpMenuTournois;
      CreatePopUpMenuBases;
      
      with gInfosSaisiePartie do
        begin
          if (DernierePartieCompatibleEnMemoire(nbCoupsIdentiques,numeroReferencePartie) <> '') &
             (nbCoupsIdentiques >= 30) then
               begin
                 dernierJoueurNoir  := GetNroJoueurNoirParNroRefPartie(numeroReferencePartie);
                 dernierJoueurBlanc := GetNroJoueurBlancParNroRefPartie(numeroReferencePartie);
                 dernierTournoi     := GetNroTournoiParNroRefPartie(numeroReferencePartie);
                 derniereAnnee      := GetAnneePartieParNroRefPartie(numeroReferencePartie);
               end;
        
  		    SetItemTextInDialog(dialogueSaisie,NoirEditableText,GetNomJoueur(dernierJoueurNoir));
  	      SetItemTextInDialog(dialogueSaisie,BlancEditableText,GetNomJoueur(dernierJoueurBlanc));
  	      SetItemTextInDialog(dialogueSaisie,TournoiEditableText,GetNomTournoi(dernierTournoi));
  	      SetItemTextInDialog(dialogueSaisie,AnneeEditableText,NumEnString(derniereAnnee));
  	      with popUpBasesSaisie do
  	        begin
  	          itemCourantMenuBases := Max(NroDistribToItemNumber(popUpBasesSaisie,derniereDistribution), nbreItemsAvantListeDesBases + 1);
  	          derniereDistribution := ItemNumberToNroDistrib(popUpBasesSaisie,itemCourantMenuBases);
  	          SetItemMark(menuFlottantBases,itemCourantMenuBases,chr(checkMark));
  	        end;
  	      SetBoolCheckBox(dialogueSaisie,AjouterAutomatiquementCheckBox,enregistrementAutomatique);
  	      SelectDialogItemText(dialogueSaisie,NoirEditableText,0,MaxInt);
	    end;
      
      focus := 0;
      InvalidateDerniersParametresDessines;
      numeroDerniereComplementationDansTable := 0;
      dernierCaractereEtaitFautif := false;
      ChangeFocusDialogueSaisie(NoirEditableText);
      DessineDialogueSaisie;
      NoUpdateThisWindow(GetDialogWindow(dialogueSaisie));
      err := SetDialogTracksCursor(dialogueSaisie,true);
      repeat
		    ModalDialog(FiltreDialogueSaisieUPP,itemHit);
        GetPort(oldPort);
			  SetPortByDialog(dialogueSaisie);
         
		    case itemHit of
					VirtualUpdateItemInDialog: 
						begin
						  InvalidateDerniersParametresDessines;
							BeginUpdate(GetDialogWindow(dialogueSaisie));
							DessineDialogueSaisie;
							EndUpdate(GetDialogWindow(dialogueSaisie));
						end;
				  OK:
				    ;
				  Annuler:
				    ;
      
				  MenuNoirUserItemPopUp:
				    begin
				      if debuggage_saisiePartie then WritelnDansRapport('dans DialogueSaisiePartie, appel de EventPopUpItem(Noirs)');
				      menuItem := 1;
				      if focus <> NoirEditableText then
				        begin
				          SelectDialogItemText(dialogueSaisie,NoirEditableText,0,MaxInt);
				          ChangeFocusDialogueSaisie(NoirEditableText);
				        end;
				      if EventPopUpItem(menuNoirsFlottant, menuItem, menuNoirsRect, false, false) then
								begin
								  {WritelnDansRapport('EventPopUpItemMenuFlottant = OK');}
								  if menuItem >= 3 then
								    begin
								      ChangeFocusDialogueSaisie(NoirEditableText);
										  if debuggage_saisiePartie then WritelnStringAndNumDansRapport('menuItem = ',menuItem);
								      nbItem := MyCountMenuItems(menuNoirsFlottant);
								      if debuggage_saisiePartie then WritelnStringAndNumDansRapport('nbItem = ',nbItem);
								      numero := GetNiemeJoueurTableSaisiePartie(menuItem-2);
								      if debuggage_saisiePartie then WritelnStringAndNumDansRapport('numero = ',numero);
		                  s := GetNomJoueur(numero);
		                  if debuggage_saisiePartie then WritelnDansRapport('nom = '+s);
		                  gInfosSaisiePartie.dernierJoueurNoir := numero;
		                  AjouteNouveauJoueurTableSaisiePartie(numero);
		                  MetLesNomsDansPopUpMenuJoueurs;
		                  SelectDialogItemText(dialogueSaisie,NoirEditableText,0,0);
		                  SetItemTextInDialog(dialogueSaisie,NoirEditableText,s);
                      SelectDialogItemText(dialogueSaisie,NoirEditableText,0,MaxInt);
                      ChangeFocusDialogueSaisie(NoirEditableText);
                      DessineDialogueSaisie;
		                end;
								end;
						end;
          MenuBlancUserItemPopUp:
            begin
						  if debuggage_saisiePartie then WritelnDansRapport('dans DialogueSaisiePartie, appel de EventPopUpItem(Blancs)');
				      if focus <> BlancEditableText then
				        begin
				          SelectDialogItemText(dialogueSaisie,BlancEditableText,0,MaxInt);
				          ChangeFocusDialogueSaisie(BlancEditableText);
				        end;
				      menuItem := 1;
				      if EventPopUpItem(menuBlancsFlottant, menuItem, menuBlancsRect, false, false) then
								begin
								  {WritelnDansRapport('EventPopUpItemMenuFlottant = OK');}
								  if menuItem >= 3 then
								    begin
								      ChangeFocusDialogueSaisie(BlancEditableText);
										  if debuggage_saisiePartie then WritelnStringAndNumDansRapport('menuItem = ',menuItem);
								      nbItem := MyCountMenuItems(menuBlancsFlottant);
								      if debuggage_saisiePartie then WritelnStringAndNumDansRapport('nbItem = ',nbItem);
								      numero := GetNiemeJoueurTableSaisiePartie(menuItem-2);
								      if debuggage_saisiePartie then WritelnStringAndNumDansRapport('numero = ',numero);
		                  s := GetNomJoueur(numero);
		                  if debuggage_saisiePartie then WritelnDansRapport('nom = '+s);
		                  gInfosSaisiePartie.dernierJoueurBlanc := numero;
		                  AjouteNouveauJoueurTableSaisiePartie(numero);
		                  MetLesNomsDansPopUpMenuJoueurs;
		                  SelectDialogItemText(dialogueSaisie,BlancEditableText,0,0);
                      SetItemTextInDialog(dialogueSaisie,BlancEditableText,s);
                      SelectDialogItemText(dialogueSaisie,BlancEditableText,0,MaxInt);
                      ChangeFocusDialogueSaisie(BlancEditableText);
                      DessineDialogueSaisie;
		                end;
								end;
						end;
          MenuTournoiUserItemPopUp:
            begin
						  if debuggage_saisiePartie then WritelnDansRapport('dans DialogueSaisiePartie, appel de EventPopUpItem(Tournois)');
						  if focus <> TournoiEditableText then
				        begin
				          SelectDialogItemText(dialogueSaisie,TournoiEditableText,0,MaxInt);
				          ChangeFocusDialogueSaisie(TournoiEditableText);
				        end;
				      menuItem := 1;
				      if EventPopUpItem(menuTournoisFlottant, menuItem, menuTournoisRect, false, false) then
								begin
								  {WritelnDansRapport('EventPopUpItemMenuFlottant = OK');}
								  if menuItem >= 3 then
								    begin
								      ChangeFocusDialogueSaisie(TournoiEditableText);
										  if debuggage_saisiePartie then WritelnStringAndNumDansRapport('menuItem = ',menuItem);
								      nbItem := MyCountMenuItems(menuTournoisFlottant);
								      if debuggage_saisiePartie then WritelnStringAndNumDansRapport('nbItem = ',nbItem);
								      numero := GetNiemeTournoiTableSaisiePartie(menuItem-2);
								      if debuggage_saisiePartie then WritelnStringAndNumDansRapport('numero = ',numero);
		                  s := GetNomTournoi(numero);
		                  if debuggage_saisiePartie then WritelnDansRapport('nom = '+s);
		                  gInfosSaisiePartie.dernierTournoi := numero;
		                  AjouteNouveauTournoiTableSaisiePartie(numero);
		                  MetLesNomsDansPopUpMenuTournois;
		                  SelectDialogItemText(dialogueSaisie,TournoiEditableText,0,0); 
                      SetItemTextInDialog(dialogueSaisie,TournoiEditableText,s);
                      SelectDialogItemText(dialogueSaisie,TournoiEditableText,0,MaxInt); 
                      ChangeFocusDialogueSaisie(TournoiEditableText);
		                  DessineDialogueSaisie;
		                end;
								end;
						end;
						
						
					NoirEditableText,BlancEditableText,TournoiEditableText:
	          begin
	            with dernierEventSaisie do
	              if (focus <> itemHit) & not((what = mouseDown) & ((Tickcount() - when) >= 15))
	                then SelectDialogItemText(dialogueSaisie,itemHit,0,MaxInt);
	            
	            {l'utilisateur a-t-il appuye sur delete ?}
	            if not(EventHasCommandKey(dernierEventSaisie)) & 
	               (BAND(dernierEventSaisie.message,charcodemask)=RetourArriereKey) &
	               (chaineAvantDeleteDlgSaisie <> '')
	              then
	                begin
	                  GetItemTextInDialog(dialogueSaisie,itemHit,s1);
	                  if (length(chaineAvantDeleteDlgSaisie) >= length(s1) +1) & not(dernierCaractereEtaitFautif)
	                    then s := TPCopy(s1,1,Length(s1)-1)
	                    else s := s1;
	                end
	              else
	                begin
	                  GetItemTextInDialog(dialogueSaisie,itemHit,s1);
	                  s := s1;
	                end;
	            
	            {l'utilisateur a-t-il appuyé sur '=' ?  => completion}
	            if (s[Length(s)]='=') then s := TPCopy(s,1,Length(s)-1);
	            
	            dernierCaractereEtaitFautif := false;
              case itemHit of
                NoirEditableText : 
                  begin
                    if (EnleveEspacesDeGauche(s1) = '') | (EnleveEspacesDeGauche(s) = '')
                      then 
                        begin
                          numeroDerniereComplementationDansTable := 0;
                          s := GetNomJoueur(0);
                          i := 0; 
                        end
                      else
                        s := Complemente(complementationJoueurNoir,s,i);
                    if s = GetNomJoueur(numeroDerniereComplementationDansTable) then
                      begin
                        numero := GetNroJoueurDansSonFichier(numeroDerniereComplementationDansTable);
                        {WritelnDansRapport('s = '+s);
                        WritelnStringAndNumDansRapport('numero = ',numero);
                        WritelnDansRapport('GetNomJoueur(numero) = '+GetNomJoueur(numero));}
                        gInfosSaisiePartie.dernierJoueurNoir := numero;
                      end
                      else
                        begin
                          SysBeep(0);
                          dernierCaractereEtaitFautif := true;
                        end;
                  end;
                BlancEditableText: 
                  begin
                    if (EnleveEspacesDeGauche(s1) = '') | (EnleveEspacesDeGauche(s) = '')
                      then 
                        begin
                          numeroDerniereComplementationDansTable := 0;
                          s := GetNomJoueur(0);
                          i := 0;
                        end
                      else
                        s := Complemente(complementationJoueurBlanc,s,i);
                    if s = GetNomJoueur(numeroDerniereComplementationDansTable) then
                      begin
                        numero := GetNroJoueurDansSonFichier(numeroDerniereComplementationDansTable);
                        {WritelnDansRapport('s = '+s);
                        WritelnStringAndNumDansRapport('numero = ',numero);
                        WritelnDansRapport('GetNomJoueur(numero) = '+GetNomJoueur(numero));}
                        gInfosSaisiePartie.dernierJoueurBlanc := numero;
                      end
                      else 
                        begin
                          SysBeep(0);
                          dernierCaractereEtaitFautif := true;
                        end;
                  end;
                TournoiEditableText : 
                  begin
                    if (EnleveEspacesDeGauche(s1) = '') | (EnleveEspacesDeGauche(s) = '')
                      then 
                        begin
                          numeroDerniereComplementationDansTable := 0;
                          s := GetNomTournoi(0);
                          i := 0;
                        end
                      else
                        s := Complemente(complementationTournoi,s,i);
                    if s = GetNomTournoi(numeroDerniereComplementationDansTable) then
                      begin
                        numero := GetNroTournoiDansSonFichier(numeroDerniereComplementationDansTable);
                        {WritelnDansRapport('s = '+s);
                        WritelnStringAndNumDansRapport('numero = ',numero);
                        WritelnDansRapport('GetNomTournoi(numero) = '+GetNomTournoi(numero));}
                        gInfosSaisiePartie.dernierTournoi := numero;
                      end
                      else 
                        begin
                          SysBeep(0);
                          dernierCaractereEtaitFautif := true;
                        end;
                  end;
              end;
              if (s <> s1) then
                begin
                  SetItemTextInDialog(dialogueSaisie,itemHit,s);
                  SelectDialogItemText(dialogueSaisie,itemHit,i,MaxInt);
                end;
              DessineDialogueSaisie;
              ChangeFocusDialogueSaisie(itemHit);
	          end;
	          
	        AnneeEditableText:
	          begin
	            with dernierEventSaisie do
	              if (focus <> AnneeEditableText) & not((what = mouseDown) & ((Tickcount() - when) >= 15)) then 
	                SelectDialogItemText(dialogueSaisie,AnneeEditableText,0,MaxInt);
	            GetItemTextInDialog(dialogueSaisie,AnneeEditableText,s1);
	            s := SeulementLesChiffres(s1);
              SetItemTextInDialog(dialogueSaisie,AnneeEditableText,s);
              gInfosSaisiePartie.derniereAnnee := ChaineEnLongint(s);
              DessineDialogueSaisie;
	            ChangeFocusDialogueSaisie(AnneeEditableText);
	          end;
	        
	        AjouterAutomatiquementCheckBox:
	          begin
	            with gInfosSaisiePartie do
	              begin
	                enregistrementAutomatique := not(enregistrementAutomatique);
	                SetBoolCheckBox(dialogueSaisie,AjouterAutomatiquementCheckBox,enregistrementAutomatique);
	              end;
	          end;
	        
	        NomBaseUserItemPopUp:
	          begin
	            with popUpBasesSaisie, gInfosSaisiePartie do
	              begin
	                menuItem := itemCourantMenuBases;
		              if EventPopUpItem(menuFlottantBases, menuItem, menuBasesRect, true, true) then
		                begin
		                  if (menuItem > nbreItemsAvantListeDesBases) 
		                    then 
		                      begin
		                        itemCourantMenuBases := menuItem;
		                        derniereDistribution := ItemNumberToNroDistrib(popUpBasesSaisie,itemCourantMenuBases);
		                        if not(enregistrementAutomatique) then
					                    begin
					                      enregistrementAutomatique := not(enregistrementAutomatique);
					                      SetBoolCheckBox(dialogueSaisie,AjouterAutomatiquementCheckBox,enregistrementAutomatique);
					                    end;
		                      end
		                    else 
		                      begin
		                        
		                        BeginDialog;
													  GetIndString(s,TextesDiversID,2);      {'sans titre'}
													  reply.fname := s;
													  GetIndString(prompt,TextesNouveauFormatID,3); {'nom de la base à créer ?'}
													  if MakeFileName(reply,prompt,mySpec) then;
													  EndDialog;
													  
													  if reply.good then {pas annulation ?}
												      begin
												        
												        nomBase := EnleveEspacesDeDroite(reply.fname) + ' XXXX.wtb';
												        pathBase := GetFullPathOfFSSpec(mySpec);
												        pathBase := LeftOfString(pathBase,LastPos(':',pathBase));
												        
												        if debuggage_saisiePartie then
												          begin
												            WritelnDansRapport('nomBase = '+nomBase);
												            WritelnDansRapport('pathBase = '+pathBase);
												          end;
												        
												        if EstUneDistributionConnue(nomBase,pathBase,i) 
												          then
												            begin
												              if PasLaDistributionWThor(i) then 
												                begin
												                  derniereDistribution := i;
												                  itemCourantMenuBases := NroDistribToItemNumber(popUpBasesSaisie,derniereDistribution);
												                end
												            end
												          else
												            begin
												              AjouterDistributionNouveauFormat(nomBase,pathBase,kFicPartiesNouveauFormat);
												              KillPopUpMenuBases;
				                              CreatePopUpMenuBases;
				                              if PasLaDistributionWThor(DistributionsNouveauFormat.nbDistributions) then 
				                                derniereDistribution := DistributionsNouveauFormat.nbDistributions;
			                                itemCourantMenuBases := NroDistribToItemNumber(popUpBasesSaisie,derniereDistribution);
			                              end;
			                          
			                          if not(enregistrementAutomatique) then
							                    begin
							                      enregistrementAutomatique := not(enregistrementAutomatique);
							                      SetBoolCheckBox(dialogueSaisie,AjouterAutomatiquementCheckBox,enregistrementAutomatique);
							                    end;
			                        end;
				                    
				                    derniereDistribution := ItemNumberToNroDistrib(popUpBasesSaisie,itemCourantMenuBases);
				                    DrawPUItem(menuFlottantBases,itemCourantMenuBases,menuBasesRect,false);
		                      end;
		                  
		                end;
		            end;
	          end;
	        
	        VirtualSelectAllItemInDialog :
	          begin
	            if (focus = NoirEditableText) |
	               (focus = BlancEditableText) |
	               (focus = TournoiEditableText) |
	               (focus = AnneeEditableText) then 
	              SelectDialogItemText(dialogueSaisie,focus,0,MaxInt);
	          end;
				end; {case}
				
		    SetPort(oldPort);
		    
		  until (itemHit = OK) | (itemHit = Annuler);

		  if focus = NoirEditableText then
        AjouteNouveauJoueurTableSaisiePartie(gInfosSaisiePartie.dernierJoueurNoir);
      if focus = BlancEditableText then
        AjouteNouveauJoueurTableSaisiePartie(gInfosSaisiePartie.dernierJoueurBlanc);
      if focus = TournoiEditableText then
        AjouteNouveauTournoiTableSaisiePartie(gInfosSaisiePartie.dernierTournoi);
      
 
		  KillPopUpMenuJoueurs;
		  KillPopUpMenuTournois;
		  KillPopUpMenuBases;
		  MyDisposeDialog(dialogueSaisie);
    end;
  MyDisposeModalFilterUPP(FiltreDialogueSaisieUPP);
  GetCurrentScript(gLastScriptUsedInDialogs);
  SwitchToRomanScript;
  EndDialog;
  
  {on ajoute la partie si l'utilisateur a clique sur OK}
  if (itemHit = OK) then
    with gInfosSaisiePartie do
      begin
      
        action := ActionCreerAutrePartie;
        
        if (DernierePartieCompatibleEnMemoire(nbCoupsIdentiques,numeroReferencePartie) <> '') & (nbCoupsIdentiques >= 30)
          then action := ConfirmationEcraserPartie(numeroReferencePartie,nbCoupsIdentiques);
        
        case action of
          ActionRemplacer :
            begin
              dansListe := ChangerPartieCouranteDansListe(dernierJoueurNoir,dernierJoueurBlanc,dernierTournoi,derniereAnnee,true,partieRec,numeroReferencePartie);
            end;
          ActionCreerAutrePartie:
            begin
              dansListe := AjouterPartieCouranteDansListe(dernierJoueurNoir,dernierJoueurBlanc,dernierTournoi,derniereAnnee,true,partieRec,numeroReferencePartie);
              if enregistrementAutomatique then
                 if (AjouterPartieDansCetteDistribution(partieRec,derniereDistribution,derniereAnnee) = NoErr) then
                   begin
                     if (numeroReferencePartie >= 1) & (numeroReferencePartie <= nbPartiesChargees) then
                       begin
                         SetNroDistributionParNroRefPartie(numeroReferencePartie,gInfosSaisiePartie.derniereDistribution);
                         SetPartieDansListeDoitEtreSauvegardee(numeroReferencePartie,false);
                       end;
                   end;
            end;
          ActionAnnuler:
            begin
              {nothing}
            end;
        end; {case}
            
        EcritListeParties(false,'DialogueSaisiePartie');
      end;
  
  if debuggage_saisiePartie then SetEcritToutDansRapportLog(true);
end;

END.