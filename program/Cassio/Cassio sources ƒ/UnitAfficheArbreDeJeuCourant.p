UNIT UnitAfficheArbreDeJeuCourant;




INTERFACE







USES UnitOth0,UnitSquareSet,UnitImagettesMeteo;


const espaceEntreProperties=4;
      espaceEntreLignesProperties=14;

      kAucunePropriete            = 0;
      kAideDebutant               = 1;
      kNumerosCoups               = 2;
      kPierresDeltas              = 4;
      kProchainCoup               = 8;
      kCommentaires               = 16;
      kNoeudDansFenetreArbreDeJeu = 32;
      kAnglesCarreCentral         = 64;
      kNotesCassioSurLesCases     = 128;
      kInfosApprentissage         = 256;
      kBibliotheque               = 512;
      kSuggestionDeCassio         = 1024;
      kNotesZebraSurLesCases      = 2048;
      kToutesLesProprietes        = $FFFFFFFF;

{initialisation et destruction de l'unité}
procedure InitUnitAfficheArbreJeuCourant;
procedure LibereMemoireUnitAfficheArbreJeuCourant;

{fonctions d'affichage des infos courantes à l'ecran}
procedure SetAffichageProprietesOfCurrentNode(flags : SInt32);
procedure SetEffacageProprietesOfCurrentNode(flags : SInt32);
function GetAffichageProprietesOfCurrentNode() : SInt32;
function GetEffacageProprietesOfCurrentNode() : SInt32;
procedure SetPhaseCalculListePositionsProperties(flag : boolean);
procedure VideListePositionsProperties;
procedure EcritProchainsCoupsSurOthellier(G : GameTree;trait : SInt16; avecSignesDiacritiques : boolean;surQuellesCases : SquareSet);
procedure EffaceProchainsCoupsSurOthellier(G : GameTree;trait : SInt16);
procedure AfficheProprietesOfCurrentNode(dessinerAideDebutantSiNecessaire : boolean;surQuellesCases : SquareSet; const fonctionAppelante : str255);
procedure EffaceProprietesOfCurrentNode;
procedure AfficheProprietes(G : GameTree;surQuellesCases : SquareSet);
procedure EffaceProprietes(G : GameTree);
procedure EcritCommentaires(G : GameTree);
procedure EcritCommentairesOfCurrentNode;
procedure SetTexteFenetreArbreDeJeuFromArbreDeJeu(G : GameTree;redessineCommentaires : boolean; var commentaireChange : boolean);
function EstVisibleDansFenetreArbreDeJeu(G : GameTree) : boolean;
function GetSignesDiacritiques(G : GameTree) : str255;

{fonctions d'affichage dans la fenetre « arbre de jeu »}
procedure DessineCoupDansFenetreArbreDeJeu(L : PropertyList;numeroDuCoup : SInt16; var positionHorizontale : SInt32);
procedure EcritNoeudDansFenetreArbreDeJeu(G : GameTree;avecEcritureDesFils : boolean);
procedure EcritCurrentNodeDansFenetreArbreDeJeu(avecEcritureDesFils,DoitEffacerPremiereLigneDeLaFenetre : boolean);
procedure EffaceNoeudDansFenetreArbreDeJeu;
procedure EffacePremiereLigneFenetreArbreDeJeu;
procedure ValideZoneCommentaireDansFenetreArbreDeJeu;
procedure InverserLeNiemeFilsDansFenetreArbreDeJeu(N : SInt16);

{fonction de dessin des icones des proprietes}
function InterligneArbreFenetreArbreDeJeu() : SInt16; 
procedure DessinePetiteIconeFenetreArbreDeJeu(IconeID : SInt32;where : Point; var dimension : Point);
procedure DessineImagetteFenetreArbreDeJeu(quelleImage:TypeImagette;where : Point; var dimension : Point);
function DessineIconeProperty(prop : Property;where : Point; var dimension : Point) : boolean;
procedure EcritChaineOfProperty(const s : str255; var largeur : SInt16);

{fonction de destruction}
procedure DetruireCeFilsOfCurrentNode(var whichSon : GameTree);

{fonction de test de souris}
function PropertyPointeeParSouris() : PropertyPtr;
function SurIconeInterversion(whichPoint : Point; var noeudCorrespondant : GameTree) : boolean;

{fonction d'affichage du commentaire dans le rapport}
procedure AfficheCommentaireOfNodeDansRapport(var G : GameTree; var numeroDuCoup : SInt32; var commentaireVide : boolean);
procedure AfficheCommentairePartieDansRapport;


IMPLEMENTATION







USES UnitOth1,UnitServicesDialogs,UnitFenetres,UnitRapport,UnitArbreDeJeuCourant,
     UnitPierresDelta,UnitRapportImplementation,UnitJaponais,UnitAffichageReflexion,
     UnitImagettesMeteo,Zebra_to_Cassio,UnitScannerOthellistique,SNStrings,UnitCouleur;


var DernierNoeudDontOnAAfficheLesCommentaires : GameTree;
    gAffichageProprietesOfCurrentNode : SInt32;
    gEffacageProprietesOfCurrentNode : SInt32;
    phaseCalculListePositionsProperties : boolean;
    listePositionsProperties : PropertyList;
    gNoeudQuOnDessineSurCetteLigne : GameTree;
    gCouleurDuCoupDeCetteLigne : SInt32;


procedure InitUnitAfficheArbreJeuCourant;
begin
  DernierNoeudDontOnAAfficheLesCommentaires := NIL;
  SetAffichageProprietesOfCurrentNode(kToutesLesProprietes);
  SetEffacageProprietesOfCurrentNode(kToutesLesProprietes);
  SetPhaseCalculListePositionsProperties(false);
  listePositionsProperties := NIL;
  gNoeudQuOnDessineSurCetteLigne := NIL;
  gCouleurDuCoupDeCetteLigne := pionVide;
end;

procedure LibereMemoireUnitAfficheArbreJeuCourant;
begin
  DisposePropertyList(listePositionsProperties);
  listePositionsProperties := NIL;
end;

procedure SetAffichageProprietesOfCurrentNode(flags : SInt32);
begin
  gAffichageProprietesOfCurrentNode := flags;
end;

function GetAffichageProprietesOfCurrentNode() : SInt32;
begin
  GetAffichageProprietesOfCurrentNode := gAffichageProprietesOfCurrentNode;
end;

procedure SetEffacageProprietesOfCurrentNode(flags : SInt32);
begin
  gEffacageProprietesOfCurrentNode := flags;
end;

function GetEffacageProprietesOfCurrentNode() : SInt32;
begin
  GetEffacageProprietesOfCurrentNode := gEffacageProprietesOfCurrentNode;
end;

procedure SetPhaseCalculListePositionsProperties(flag : boolean);
begin
  phaseCalculListePositionsProperties := flag;
end;

procedure VideListePositionsProperties;
begin
  DisposePropertyList(listePositionsProperties);
  listePositionsProperties := NIL;
end;

procedure EcritProchainsCoupsSurOthellier(G : GameTree;trait : SInt16; avecSignesDiacritiques : boolean;surQuellesCases : SquareSet);
var L,L1,L2 : PropertyList;
    theSon : GameTree;
    codeAsciiCaractere,whichSquare : SInt16; 
    tempoBool,bidbool : boolean;
    oldPort : grafPtr;
    s : str255;
    imagetteADessiner:TypeImagette;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      
      {on met le drapeau doitEffacerSousLesTextesSurOthellier a true pour eviter que
       Quartz ne bave sur les textes quand on ecrit plusieurs fois de suite les textes
       dans les cases }
       
      tempoBool := doitEffacerSousLesTextesSurOthellier;
      doitEffacerSousLesTextesSurOthellier := true;
      
      L := MakeListOfMovePropertyOfSons(trait,G);
      if (L <> NIL) then
        begin
          L1 := L;
	        codeAsciiCaractere := ord('a');
	        while L1 <> NIL do
	          begin
	            whichSquare := GetOthelloSquareOfProperty(L1^.head);
	            
	            
	            s := Concat('',chr(codeAsciiCaractere));
	                
              theSon := SelectFirstSubtreeWithThisProperty(L1^.head,G);
              if theSon = NIL then
                begin
                  AlerteSimple('erreur : fils non trouvé EcritProchainsCoupsSurOthellier !! Prévenez Stéphane');
                  exit(EcritProchainsCoupsSurOthellier);
                end;
              
              imagetteADessiner := kAucuneImagette;
                  
              if IsARealNode(theSon) then
                begin
                  if avecSignesDiacritiques then
	                  begin
	                    
	                    L2 := theSon^.properties;
	                    while L2 <> NIL do
	                      begin
	                        case L2^.head.genre of
	                          TesujiProp : 
	                            begin
	                              if GetTripleOfProperty(L2^.head).nbTriples >= 2
	                                then s := s+'!!'
	                                else s := s+'!';
	                            end;
	                          BadMoveProp :
	                            begin
	                              if GetTripleOfProperty(L2^.head).nbTriples >= 2
	                                then 
  	                                begin
  	                                  s := s+'??';
  	                                  imagetteADessiner := kAlertBig;
  	                                end
  	                              else s := s+'?';
  	                          end;
	                          InterestingMoveProp :
	                            begin
	                              {s := s+'!?';}
	                              imagetteADessiner := kSunCloudBig;
	                            end;
	                          DubiousMoveProp :
	                            begin
	                              {s := s+'?!';}
	                              imagetteADessiner := kThunderstormBig;
	                            end;
	                          ExoticMoveProp : 
	                            begin
	                              s := s+'?!';
	                            end;
	                        end; {case}
	                        if L2^.tail=L2 then
			                      begin
			                        AlerteSimple('erreur : boucle infinie sur L1 dans EcritProchainsCoupsSurOthellier !! Prévenez Stéphane');
			                        exit(EcritProchainsCoupsSurOthellier);
			                      end;
	                        L2 := L2^.tail;
	                      end;
	                    if L1^.tail=L1 then
	                      begin
	                        AlerteSimple('erreur : boucle infinie sur L1 dans EcritProchainsCoupsSurOthellier !! Prévenez Stéphane');
	                        exit(EcritProchainsCoupsSurOthellier);
	                      end;
	                  end;
                
                  if whichSquare in surQuellesCases then
		                case L1^.head.genre of
			                WhiteMoveProp : if not(gCouleurOthellier.estTresClaire)
			                                 then DessineStringOnSquare(whichSquare,pionBlanc,s,bidbool)
			                                 else DessineStringOnSquare(whichSquare,pionNoir,s,bidbool);
			                BlackMoveProp : DessineStringOnSquare(whichSquare,pionNoir,s,bidbool);
			                otherwise       DessineStringOnSquare(whichSquare,pionNoir,s,bidbool);
			              end;
			            
			            if (imagetteADessiner <> kAucuneImagette) then
			              DrawImagetteMeteoOnSquare(imagetteADessiner,whichSquare);
			              
		              inc(codeAsciiCaractere);
		            end;
	            
	            
	            L1 := L1^.tail; 
	          end;
	      end;
      DisposePropertyList(L);
      
      
      doitEffacerSousLesTextesSurOthellier := tempoBool;
      SetPort(oldPort);
    end;
end;

procedure EffaceProchainsCoupsSurOthellier(G : GameTree;trait : SInt16);
var L : PropertyList;
    oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      
      L := MakeListOfMovePropertyOfSons(trait,G);
      if (L <> NIL) then
        EffaceCasesDeLaListe(L);
      DisposePropertyList(L);
      
      SetPort(oldPort);
    end;
end;


procedure WritelnRacineDeLaPartieDansRapport;
var G : GameTree;
begin
  G := GetRacineDeLaPartie();
  WritelnStringAndGameTreeDansRapport('racine='+chr(13),G);
end;

procedure WritelnGameTreeCourantDansRapport;
var G : GameTree;
begin
  G := GetCurrentNode();
  WritelnStringAndGameTreeDansRapport('GameTreeCourant='+chr(13),G);
end;

procedure AfficheProprietes(G : GameTree;surQuellesCases : SquareSet);
begin

  {WritelnDansRapport('AfficheProprietes');}
  
  if affichePierresDelta & (BAND(gAffichageProprietesOfCurrentNode,kPierresDeltas) <> 0)
    then DesssinePierresDelta(G,surQuellesCases);
    
  if afficheProchainsCoups & (BAND(gAffichageProprietesOfCurrentNode,kProchainCoup) <> 0)
    then EcritProchainsCoupsSurOthellier(G,0,afficheSignesDiacritiques,surQuellesCases);
        
  if (BAND(gAffichageProprietesOfCurrentNode,kCommentaires) <> 0) 
    then EcritCommentaires(G);
  
  if (BAND(gAffichageProprietesOfCurrentNode,kNoeudDansFenetreArbreDeJeu) <> 0)
    then EcritNoeudDansFenetreArbreDeJeu(G,true);
  
  
  
  if (BAND(gAffichageProprietesOfCurrentNode,kCommentaires + kNoeudDansFenetreArbreDeJeu) <> 0) then
    if QDIsPortBuffered(GetWindowPort(GetArbreDeJeuWindow())) then 
       QDFlushPortBuffer(GetWindowPort(GetArbreDeJeuWindow()), NIL);
       
       
  {
  WritelnStringAndNumDansRapport('adresse de G = ',SInt32(G));
  WritelnStringAndNumDansRapport('adresse de la racine = ',SInt32(GetRacineDeLaPartie()));
  WritelnStringAndPropertyListDansRapport('proprietes de G = ',G^.properties);
  WritelnStringAndPropertyListDansRapport('proprietes de la racine = ',GetRacineDeLaPartie()^.properties);
  }
end;

procedure EffaceProprietes(G : GameTree);
begin
  {WritelnDansRapport('EffaceProprietes');}
  EffaceProchainsCoupsSurOthellier(G,0);
  if affichePierresDelta then EffacePierresDelta(G);
  EffaceNoeudDansFenetreArbreDeJeu;
end;

procedure AfficheProprietesOfCurrentNode(dessinerAideDebutantSiNecessaire : boolean;surQuellesCases : SquareSet; const fonctionAppelante : str255);
var G : GameTree;
begin  {$UNUSED fonctionAppelante}
  if (gAffichageProprietesOfCurrentNode <> kAucunePropriete) then
    begin
		  if dessinerAideDebutantSiNecessaire & aideDebutant
		    then
		      begin
		        if BAND(gAffichageProprietesOfCurrentNode,kAideDebutant) <> 0
		          then DessineAideDebutant(true,surQuellesCases)  {ceci inclut un appel recursif AfficheProprietesOfCurrentNode(false,surQuellesCases)}
		      end
		    else
		      begin
		        G := GetCurrentNode();
		        AfficheProprietes(G,surQuellesCases);
		      end;
		end;
end;


procedure EffaceProprietesOfCurrentNode;
var G : GameTree;
begin
  if (gEffacageProprietesOfCurrentNode <> 0) then
    begin
      {WritelnDansRapport('EffaceProprietesOfCurrentNode');}
      G := GetCurrentNode();
      EffaceProprietes(G);
    end;
end;


procedure EcritCommentaires(G : GameTree);
var commentaireChange : boolean;
begin
  if (G <> NIL) then
    begin
      {WritelnDansRapport('EcritCommentaires');}
      SetTexteFenetreArbreDeJeuFromArbreDeJeu(G,false,commentaireChange);
      if not(commentaireChange)
        then DessineRubanDuCommentaireDansFenetreArbreDeJeu(false)
        else DessineZoneDeTexteDansFenetreArbreDeJeu(false);
    end;
end;


procedure EcritCommentairesOfCurrentNode;
begin
  EcritCommentaires(GetCurrentNode());
end;


procedure SetTexteFenetreArbreDeJeuFromArbreDeJeu(G : GameTree;redessineCommentaires : boolean; var commentaireChange : boolean);
var myText : TEHandle;
    texte : Ptr;
    longueur,longueurCouranteCommentaire : SInt32;
begin
 if arbreDeJeu.windowOpen & (GetArbreDeJeuWindow() <> NIL) then
    begin
      myText := GetDialogTextEditHandle(arbreDeJeu.theDialog);
      if myText <> NIL then
        begin
          commentaireChange := false;
          GetCommentaireDeCeNoeud(G,texte,longueur);
          if (longueur>0) & (texte <> NIL)
            then 
              begin
                TESetText(texte,longueur,myText);
                commentaireChange := true;
              end
            else
              begin
                longueurCouranteCommentaire := TEGetTextLength(myText);
                {WritelnStringAndNumDansRapport('longueurCouranteCommentaire=',longueurCouranteCommentaire);}
                if longueurCouranteCommentaire>0 then
                  begin
                    TESetSelect(0,MaxLongint,myText);
                    TEDelete(myText);
                    commentaireChange := true;
                  end;
              end;
          {WritelnStringAndBoolDansRapport('commentaireChange=',commentaireChange);}
          if redessineCommentaires & commentaireChange 
            then DessineZoneDeTexteDansFenetreArbreDeJeu(false)
            else DessineRubanDuCommentaireDansFenetreArbreDeJeu(false);
        end;
    end;
end;


function EstVisibleDansFenetreArbreDeJeu(G : GameTree) : boolean;
var theCurrentNode : GameTree;
begin
  if G = NIL
    then 
      EstVisibleDansFenetreArbreDeJeu := false
    else
      begin
        theCurrentNode := GetCurrentNode();
        EstVisibleDansFenetreArbreDeJeu := (G = theCurrentNode) | 
                                           ((G^.father <> NIL) & (G^.father = theCurrentNode));
      end;
end;

function GetSignesDiacritiques(G : GameTree) : str255;
var s : str255;
    L : PropertyList;
    aux : PropertyPtr;
begin
  s := '';
  L := GetPropertyList(G);
  aux := SelectFirstPropertyOfTypes([TesujiProp,BadMoveProp,InterestingMoveProp,DubiousMoveProp,ExoticMoveProp],L);
  if (aux <> NIL) then
    case aux^.genre of
      TesujiProp : 
	      if GetTripleOfProperty(aux^).nbTriples >= 2
	        then s := s+'!!'
	        else s := s+'!';
	    BadMoveProp :
	      if GetTripleOfProperty(aux^).nbTriples >= 2
	        then s := s+'??'
	        else s := s+'?';
	    InterestingMoveProp :
	      begin
	        {s := s+'!?';}
	      end;
	    DubiousMoveProp :
	      begin
	        {s := s+'?!';}
	      end;
	    ExoticMoveProp :
	      begin
	        s := s + '?!';
	      end;
    end;
  GetSignesDiacritiques := s;
end;


function DoitInverserLesScoresDeCetteCouleur(couleur : SInt32) : boolean;
begin
  DoitInverserLesScoresDeCetteCouleur := (couleur = -gCouleurDuCoupDeCetteLigne);
end;


procedure DessineGraphiquementTemperatureBibliothequeZebra(prop : Property;where : Point; var dimension : Point);
var theRect : rect;
    couleur,signe : SInt16; 
    valeurEntiere,centiemes : SInt16; 
    valeur : SInt32;
begin
  SetPt(dimension,12,12);
  theRect := MakeRect(where.h,where.v+2,where.h+dimension.h,where.v+dimension.v+2);
  
  GetOthelloValueOfProperty(prop,couleur,signe,valeurEntiere,centiemes);
  
  valeur := valeurEntiere;
  valeur := 100*valeur+centiemes;
  if DoitInverserLesScoresDeCetteCouleur(couleur) then valeur := -valeur;
  
  DessineCouleurDeZebraBookDansRect(theRect,gCouleurDuCoupDeCetteLigne,valeur);
end;


procedure DessinePropertyDansFenetreArbreDeJeu(var prop : Property; var positionHorizontale : SInt32; var continuer : boolean);
var largeur,couleur,signe : SInt16; 
    valeurEntiere,centiemes : SInt16; 
    oldPositionHorizontale,n1,n2 : SInt32;
    s : str255;
    dimension,positionDessinIcone : Point;
    propertyBox : rect;
    description : Property;
    inversion : boolean;
begin
  largeur := 0;
  GetPen(positionDessinIcone);
  positionDessinIcone.v := positionDessinIcone.v-12;
  case prop.genre of
    {BlackMoveProp,WhiteMoveProp: 
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        Move(dimension.h,0);
        s := CoupEnString(GetOthelloSquareOfProperty(prop),CassioUtiliseDesMajuscules);
        TextFace(bold);
        Move(2,0);
        DrawString(s);
        Move(espaceEntreProperties,0);
        largeur := dimension.h+StringWidth(s)+2;
        TextFace(normal);
      end;}
    GoodForWhiteProp:
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    GoodForBlackProp:
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    DrawMarkProp:
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    InterestingMoveProp,DubiousMoveProp:
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    ExoticMoveProp:
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
        {EcritChaineOfProperty('!?',largeur);}
      end;
    BadMoveProp:
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    {TesujiProp:
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;}
    UnclearPositionProp:
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    NodeNameProp:
      begin
        s := Concat(' «',GetStringInfoOfProperty(prop),'» ');
        EcritChaineOfProperty(s,largeur);
      end;
    NodeValueProp,
    ComputerEvaluationProp,
    ZebraBookProp,
    PerfectScoreProp:
      begin
        GetOthelloValueOfProperty(prop,couleur,signe,valeurEntiere,centiemes);
        if (valeurEntiere = 0) & (centiemes = 0) &
           (prop.genre <> ComputerEvaluationProp) & (prop.genre <> ZebraBookProp)
          then 
            begin
              GetIndString(s,TextesReflexionID,20);                {'Nulle'}
              s := Concat(' ',s,' ');
            end
          else
            begin
            
              inversion := DoitInverserLesScoresDeCetteCouleur(couleur);
              if (prop.genre = ZebraBookProp) & inversion then
                begin
                  couleur := -couleur;
                  signe := -signe;
                end;
            
	            if (prop.genre = ComputerEvaluationProp) | (prop.genre = ZebraBookProp)
	              then
	                begin
	                  case couleur of
      	              pionNoir  : {GetIndString(s,TextesSolitairesID,19);}   {'Noir'}
      	                          s := CaracterePourNoir;
      	              pionBlanc : {GetIndString(s,TextesSolitairesID,20);}   {'Blanc'}
      	                          s := CaracterePourBlanc;
      	              otherwise   s := '';
      	            end;
	                  if (signe >= 0)
	                    then s := Concat(' ',s,NoteEnString(valeurEntiere*100+centiemes,true,0,2),' ')
	                    else s := Concat(' ',s,NoteEnString(-(valeurEntiere*100+centiemes),true,0,2),' ')
	                end
	              else
			            begin
			              case couleur of
      	              pionNoir  : GetIndString(s,TextesSolitairesID,19);   {'Noir'}
      	              pionBlanc : GetIndString(s,TextesSolitairesID,20);   {'Blanc'}
      	              otherwise   s := '';
      	            end;
			              if (valeurEntiere >= 0)
			                then 
			                  if signe >= 0
			                    then s := Concat(' ',s,'+',NumEnString(valeurEntiere),' ')
			                    else s := Concat(' ',s,'-',NumEnString(valeurEntiere),' ')
			                else 
			                  if signe >= 0
			                    then s := Concat(' ',s,'-',NumEnString(-valeurEntiere),' ')
			                    else s := Concat(' ',s,'+',NumEnString(-valeurEntiere),' ');
			            end;
	          end;
        
        SetPt(dimension,0,0);
        if (prop.genre = ZebraBookProp) & ZebraBookACetteOption(kAfficherCouleursZebraDansArbre) then
          DessineGraphiquementTemperatureBibliothequeZebra(prop,positionDessinIcone,dimension);
        
        Move(dimension.h,0);
        EcritChaineOfProperty(s,largeur);
        largeur := largeur + dimension.h;
        
      end;
    OpeningNameProp:
      begin
        s := Concat('«',GetStringInfoOfProperty(prop),'»');
        EcritChaineOfProperty(s,largeur);
      end;
    TranspositionProp:
      begin
        if DessineIconeProperty(prop,positionDessinIcone,dimension) then
		      begin
		        largeur := dimension.h;
		        Move(largeur+espaceEntreProperties,0);
		      end;
      end;
    TranspositionRangeProp:
      begin
        GetCoupleLongintOfProperty(prop,n1,n2);
        s := NumEnString(n1) + '/' + NumEnString(n2);
        EcritChaineOfProperty(s,largeur);
      end;
    AddBlackStoneProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    AddWhiteStoneProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    RemoveStoneProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    CheckMarkProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    FigureProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    CommentProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    GameCommentProp:
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    SigmaProp:
      begin
        case GetTripleOfProperty(prop).nbTriples of
          1 : s := '∑';
          2 : s := '∑∑';
          otherwise s := ''{s := 'virtual'};
        end;
        if (s <> '') then
          EcritChaineOfProperty(s,largeur);
      end;
  end; {case}
  
  
  
  if largeur <> 0 then
    begin
      oldPositionHorizontale := positionHorizontale;
      positionHorizontale := positionHorizontale+largeur+espaceEntreProperties;
      if phaseCalculListePositionsProperties then
		    begin
		      propertyBox := MakeRect(oldPositionHorizontale-1,positionDessinIcone.v,positionHorizontale-1,positionDessinIcone.v+14);
		      {FrameRect(propertyBox);}
		      description := MakePointeurPropertyProperty(PointeurPropertyProp,gNoeudQuOnDessineSurCetteLigne,@prop,propertyBox);
		      AddPropertyInFrontOfList(description,ListePositionsProperties);
		      DisposePropertyStuff(description);
		    end;
		end;
  
  continuer := true;
end;


{si le noeud est un embranchement, on dessine la marque d'embranchement}
{si le noeud est une feuille de l'arbre, on dessine la marque terminale}
procedure EcritIconesDeStructureDeLArbre(var G : GameTree;traiteEmbranchement,traiteFeuille : boolean; var positionHorizontale : SInt32);
const IconeEnbranchementID = 1158;
      IconeNoeudTerminalID = 1159;
var positionDessinIcone,dimension : Point;
    oldPositionHorizontale : SInt32;
    description : Property;
    propertyBox : rect;
    
begin
  oldPositionHorizontale := positionHorizontale;
  if traiteEmbranchement & (NumberOfSons(G) >= 2) then
    begin
      GetPen(positionDessinIcone);
      positionDessinIcone.v := positionDessinIcone.v-12;
      DessinePetiteIconeFenetreArbreDeJeu(IconeEnbranchementID,positionDessinIcone,dimension);
      Move(dimension.h+espaceEntreProperties,0);
      positionHorizontale := positionHorizontale+dimension.h+espaceEntreProperties;
      if phaseCalculListePositionsProperties then
		    begin
		      propertyBox := MakeRect(oldPositionHorizontale-1,positionDessinIcone.v,positionHorizontale-1,positionDessinIcone.v+14);
		      {FrameRect(propertyBox);}
		      description := MakePointeurPropertyProperty(EmbranchementProp,G,NIL,propertyBox);
		      AddPropertyInFrontOfList(description,ListePositionsProperties);
		      DisposePropertyStuff(description);
		    end;
    end else
  if traiteFeuille & not(HasSons(G)) then
    begin
      GetPen(positionDessinIcone);
      positionDessinIcone.v := positionDessinIcone.v-11;
      DessinePetiteIconeFenetreArbreDeJeu(IconeNoeudTerminalID,positionDessinIcone,dimension);
      Move(dimension.h+espaceEntreProperties,0);
      positionHorizontale := positionHorizontale+dimension.h+espaceEntreProperties;
      if phaseCalculListePositionsProperties then
		    begin
		      propertyBox := MakeRect(oldPositionHorizontale-1,positionDessinIcone.v,positionHorizontale-1,positionDessinIcone.v+14);
		      {FrameRect(propertyBox);}
		      description := MakePointeurPropertyProperty(FinVarianteProp,G,NIL,propertyBox);
		      AddPropertyInFrontOfList(description,ListePositionsProperties);
		      DisposePropertyStuff(description);
		    end;
    end;
end;


procedure EcritProprietesDeCeFilsHorizontalement(var G : GameTree; var positionVerticale : SInt32; var continuer : boolean);
var positionHorizontale : SInt32;
    effacement : rect;
begin
  positionHorizontale := 23;
  Moveto(positionHorizontale,positionVerticale);
  
  gNoeudQuOnDessineSurCetteLigne := G;
  if nbreCoup <= 0  {on est à la racine de la partie}
    then DessineCoupDansFenetreArbreDeJeu(G^.properties,nbreCoup+1,positionHorizontale)
    else DessineCoupDansFenetreArbreDeJeu(G^.properties,-1,positionHorizontale);
  ForEachPropertyInListDoAvecResult(G^.properties,DessinePropertyDansFenetreArbreDeJeu,positionHorizontale);
  
  EcritIconesDeStructureDeLArbre(G,true,true,positionHorizontale);
  
  if not(phaseCalculListePositionsProperties) then
    begin
      effacement := MakeRect(positionHorizontale,positionVerticale-espaceEntreLignesProperties+3,positionHorizontale+80,positionVerticale+1);
      EraseRect(effacement);
    end;
  
  positionVerticale := positionVerticale+espaceEntreLignesProperties;
  continuer := (positionVerticale <= arbreDeJeu.EditionRect.top-12);
end;


procedure EcritProprietesDeCeNoeudHorizontalement(var G : GameTree; var positionVerticale : SInt32; var continuer : boolean);
var positionHorizontale : SInt32;
    effacement : rect;
begin
  positionHorizontale := 3;
  Moveto(positionHorizontale,positionVerticale);
  
  gNoeudQuOnDessineSurCetteLigne := G;
  DessineCoupDansFenetreArbreDeJeu(G^.properties,nbreCoup,positionHorizontale);
  ForEachPropertyInListDoAvecResult(G^.properties,DessinePropertyDansFenetreArbreDeJeu,positionHorizontale);
  
  EcritIconesDeStructureDeLArbre(G,false,true,positionHorizontale);
  
  if not(phaseCalculListePositionsProperties) then
    begin
      effacement := MakeRect(positionHorizontale,positionVerticale-espaceEntreLignesProperties+3,positionHorizontale+80,positionVerticale+1);
      EraseRect(effacement);
    end;
  
  positionVerticale := positionVerticale+espaceEntreLignesProperties;
  continuer := (positionVerticale <= arbreDeJeu.EditionRect.top-12);
end;


procedure EcritNoeudDansFenetreArbreDeJeu(G : GameTree;avecEcritureDesFils : boolean);
var positionVerticale : SInt32;
    oldPort : grafPtr;
    continuer : boolean;
begin
  if arbreDeJeu.windowOpen & (G <> NIL) then
    begin
      {WritelnDansRapport('EcritNoeudDansFenetreArbreDeJeu');}
      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow());
      
      positionVerticale := espaceEntreLignesProperties-1;
      continuer := (positionVerticale<=arbreDeJeu.EditionRect.top-12);
      if continuer then
        begin
          EcritProprietesDeCeNoeudHorizontalement(G,positionVerticale,continuer);
		      if continuer & avecEcritureDesFils then
		        ForEachSonDoAvecResult(G,EcritProprietesDeCeFilsHorizontalement,positionVerticale);
		    end;
      
      SetPort(oldPort);
    end;
end;

procedure EcritCurrentNodeDansFenetreArbreDeJeu(avecEcritureDesFils,DoitEffacerPremiereLigneDeLaFenetre : boolean);
begin
  {WritelnDansRapport('EcritCurrentNodeDansFenetreArbreDeJeu');}
  if DoitEffacerPremiereLigneDeLaFenetre then EffacePremiereLigneFenetreArbreDeJeu;
  EcritNoeudDansFenetreArbreDeJeu(GetCurrentNode(),avecEcritureDesFils);
end;


procedure EffaceNoeudDansFenetreArbreDeJeu;
var EffacageRect : rect;
    oldPort : grafPtr;
begin
  if arbreDeJeu.windowOpen then
    begin
      {WritelnDansRapport('EffaceNoeudDansFenetreArbreDeJeu');}
      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow());
      
      SetRect(EffacageRect,0,0,arbreDeJeu.EditionRect.right+4,arbreDeJeu.EditionRect.top-12);
      EraseRect(EffacageRect);
    
      SetPort(oldPort);
    end;
end;

procedure EffacePremiereLigneFenetreArbreDeJeu;
var EffacageRect : rect;
    oldPort : grafPtr;
begin
  if arbreDeJeu.windowOpen then
    begin
      {WritelnDansRapport('EffacePremiereLigneFenetreArbreDeJeu');}
      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow());
      
      SetRect(EffacageRect,0,0,arbreDeJeu.EditionRect.right+4,espaceEntreLignesProperties+1);
      EraseRect(EffacageRect);
    
      SetPort(oldPort);
    end;
end;


procedure ValideZoneCommentaireDansFenetreArbreDeJeu;
var myText : TEHandle;
begin
  with arbreDeJeu do
   begin
     if enModeEdition then
       begin
         enModeEdition := false;
         if not(EnTraitementDeTexte) then
           arbreDeJeu.doitResterEnModeEdition := false;
         GetCurrentScript(gLastScriptUsedInDialogs);
         SwitchToRomanScript;
       end;
	   if windowOpen & (theDialog <> NIL) then
	     begin
	       myText := GetDialogTextEditHandle(theDialog);
	       if myText <> NIL then TEDeactivate(myText);
	       DessineZoneDeTexteDansFenetreArbreDeJeu(false);
		     EcritCurrentNodeDansFenetreArbreDeJeu(false,true);  {on affiche ou non la petite incone de texte}
	     end;
   end;
end;

function InterligneArbreFenetreArbreDeJeu() : SInt16; 
begin
  InterligneArbreFenetreArbreDeJeu := espaceEntreLignesProperties;
end;

procedure DessinePetiteIconeFenetreArbreDeJeu(IconeID : SInt32;where : Point; var dimension : Point);
var UnePicture:PicHandle;
    unRect : rect;
begin
  UnePicture := GetPicture(IconeID);
  unRect := UnePicture^^.picframe;
  dimension.h := unRect.right-unRect.left;
  dimension.v := unRect.bottom-unRect.top;
  if not(phaseCalculListePositionsProperties) then
    begin
      OffsetRect(unRect,where.h,where.v);
      DrawPicture(UnePicture,unRect);
    end;
  ReleaseResource(Handle(UnePicture));
end;


procedure DessineImagetteFenetreArbreDeJeu(quelleImage:TypeImagette;where : Point; var dimension : Point);
var bounds : rect;
begin
  dimension.h := 16;
  dimension.v := 16;
  bounds := MakeRect(where.h, where.v-1, where.h+dimension.h, where.v + dimension.v-1);
  
  if not(phaseCalculListePositionsProperties) then
    DrawImagetteMeteo(quelleImage,GetArbreDeJeuWindow(),bounds,'DessineImagetteFenetreArbreDeJeu');
end;


function DessineIconeProperty(prop : Property;where : Point; var dimension : Point) : boolean;
var PictureADessinerID : SInt32;
    imagetteADessiner:TypeImagette;
const IconeInformationID             = 1129;
      IconeCommentairesID            = 1130;
      IconeNodeNameID                = 1131;
      IconeSquareRootMarkID          = 1132;
      IconeDoubleSquareRootMarkID    = 1133;
      IconeExclamationMarkID         = 1134;
      IconeDoubleExclamationID       = 1135;
      IconeInterrogationMarkID       = 1136;
      IconeDoubleInterrogationMarkID = 1137;
      IconeCoupDouteuxID             = 1138;
      IconeCoupInteressantID         = 1139;
      IconeAvantageNoirID            = 1140;
      IconeGrosAvantageNoirID        = 1141;
      IconeAvantageBlancID           = 1142;
      IconeGrosAvantageBlancID       = 1143;
      IconeEgalID                    = 1144;
      IconeTresEgalID                = 1145;
      IconeInfiniID                  = 1146;
      IconeDoubleInfiniID            = 1147;
      IconeFinDeVarianteID           = 1148;
      IconeSigmaMarkID               = 1149;
      IconeDoubleSigmaMarkID         = 1150;
      IconePositionRemarquableID     = 1151;
      IconePositionTresRemarquableID = 1152;
      IconePosePionNoirsID           = 1153;
      IconePosePionsBlancsID         = 1154;
      IconeEnlevePionsID             = 1155;
      IconeRondNoirID                = 1156;
      IconeRondBlancID               = 1157;
      IconeEnbranchementID           = 1158;
      IconeNoeudTerminalID           = 1159;
      IconeInterversion1ID           = 1160;
      IconeInterversion2ID           = 1161;
      IconeMoinsBlancID              = 1162;
      IconeMoinsNoirID               = 1163;
begin
  PictureADessinerID := 0;
  imagetteADessiner  := kAucuneImagette;
  
  case prop.genre of
    BlackMoveProp                : PictureADessinerID := IconeRondNoirID;
    WhiteMoveProp                : PictureADessinerID := IconeRondBlancID;
    AddBlackStoneProp            : PictureADessinerID := IconePosePionNoirsID;
    AddWhiteStoneProp            : PictureADessinerID := IconePosePionsBlancsID;
    RemoveStoneProp              : PictureADessinerID := IconeEnlevePionsID;
    GoodForBlackProp             : if GetTripleOfProperty(prop).nbTriples < 2
                                       then 
                                         begin
                                           case gCouleurDuCoupDeCetteLigne of
                                             pionNoir  : begin
                                                           PictureADessinerID := IconeAvantageNoirID;
                                                           {imagetteADessiner := kSunSmall;}
                                                         end;
                                             {pionBlanc : PictureADessinerID := IconeMoinsBlancID;}
                                             otherwise   PictureADessinerID := IconeAvantageNoirID;
                                           end;
                                           
                                         end
                                       else PictureADessinerID := IconeGrosAvantageNoirID;
    GoodForWhiteProp             : if GetTripleOfProperty(prop).nbTriples < 2
                                       then 
                                         begin
                                           case gCouleurDuCoupDeCetteLigne of
                                             {pionNoir  : PictureADessinerID := IconeMoinsNoirID;}
                                             pionBlanc : begin
                                                            PictureADessinerID := IconeAvantageBlancID;
                                                            {imagetteADessiner := kSunSmall;}
                                                         end;
                                             otherwise   PictureADessinerID := IconeAvantageBlancID;
                                           end;
                                           
                                         end
                                       else PictureADessinerID := IconeGrosAvantageBlancID;
    DrawMarkProp                 : if GetTripleOfProperty(prop).nbTriples < 2
                                       then PictureADessinerID := IconeEgalID
                                       else PictureADessinerID := IconeTresEgalID;
    TesujiProp                   : if GetTripleOfProperty(prop).nbTriples < 2
                                       then PictureADessinerID := IconeExclamationMarkID
                                       else PictureADessinerID := IconeDoubleExclamationID;
    BadMoveProp                  : if GetTripleOfProperty(prop).nbTriples < 2
                                       then 
                                         begin
                                           {PictureADessinerID := IconeInterrogationMarkID;}
                                         end
                                       else 
                                         begin
                                           {PictureADessinerID := IconeDoubleInterrogationMarkID;}
                                           imagetteADessiner := kAlertSmall;
                                         end;
    InterestingMoveProp          : begin
                                     {PictureADessinerID := IconeCoupInteressantID;}
                                     imagetteADessiner := kSunCloudSmall;
                                   end;
    DubiousMoveProp              : begin
                                     {PictureADessinerID := IconeCoupDouteuxID;}
                                     imagetteADessiner := kThunderstormSmall;
                                   end;
    ExoticMoveProp               : PictureADessinerID := IconeCoupDouteuxID;
    UnclearPositionProp          : if GetTripleOfProperty(prop).nbTriples < 2
                                       then PictureADessinerID := IconeInfiniID
                                       else PictureADessinerID := IconeDoubleInfiniID;
    CheckMarkProp                : if GetTripleOfProperty(prop).nbTriples < 2
                                       then PictureADessinerID := IconeSquareRootMarkID
                                       else PictureADessinerID := IconeDoubleSquareRootMarkID;
    FigureProp                   : PictureADessinerID := IconePositionRemarquableID;
    CommentProp                  : PictureADessinerID := IconeCommentairesID;
    GameCommentProp              : PictureADessinerID := IconeCommentairesID;
    TranspositionProp            : PictureADessinerID := IconeInterversion1ID;
    EventProp,RoundProp,
    DateProp,PlaceProp,
    BlackPlayerNameProp,
    WhitePlayerNameProp,
    UserProp,SourceProp,
    WhiteTeamProp,
    BlackTeamProp                : PictureADessinerID := IconeInformationID;
    
  end;{case}
  
  if (PictureADessinerID = 0) & (imagetteADessiner = kAucuneImagette) 
    then
      begin
        SetPt(dimension,0,0);
        DessineIconeProperty := false;
      end
    else
	    begin
	      if (PictureADessinerID <> 0) then 
	        DessinePetiteIconeFenetreArbreDeJeu(PictureADessinerID,where,dimension);
	        
	      if (imagetteADessiner <> kAucuneImagette) then 
	        DessineImagetteFenetreArbreDeJeu(imagetteADessiner,where,dimension);
	        
	      DessineIconeProperty := true;
	    end;
end;

procedure EcritChaineOfProperty(const s : str255; var largeur : SInt16);
var penLocation : Point;
begin
  TextFont(gCassioApplicationFont);
  TextSize(10);
  
  if gCassioUseQuartzAntialiasing then
    begin
      if SetAntiAliasedTextEnabled(true,9) = NoErr then;
	    EnableQuartzAntiAliasingThisPort(GetDialogPort(arbreDeJeu.theDialog),true);
    end;
    
  largeur := StringWidth(s);
  if phaseCalculListePositionsProperties
    then
      Move(largeur+espaceEntreProperties,0)
    else
      begin
        if gCassioUseQuartzAntialiasing & (GetPortPenLocation(qdThePort(), penLocation) <> NIL) then
          EraseRect(MakeRect(penLocation.h,
                             penLocation.v - espaceEntreLignesProperties + 3,
                             penLocation.h + largeur+1,
                             penLocation.v+2));
        DrawString(s);
        Move(espaceEntreProperties,0);
      end;
  TextSize(9);
end;

procedure DessineCoupDansFenetreArbreDeJeu(L : PropertyList;numeroDuCoup : SInt16; var positionHorizontale : SInt32);
var s : str255;
    prop : PropertyPtr;
    description : Property;
    dimension,positionDessinIcone : Point;
    largeur : SInt16; 
    oldPositionHorizontale : SInt32;
    propertyBox : rect;
begin
  prop := SelectFirstPropertyOfTypes([BlackMoveProp,WhiteMoveProp],L);
  if prop = NIL
    then
      gCouleurDuCoupDeCetteLigne := pionVide
    else
	    begin
	      if prop^.genre = BlackMoveProp
	        then gCouleurDuCoupDeCetteLigne := pionNoir
	        else gCouleurDuCoupDeCetteLigne := pionBlanc;
	      oldPositionHorizontale := positionHorizontale;
	      GetPen(positionDessinIcone);
	      positionDessinIcone.v := positionDessinIcone.v-12;
	      if DessineIconeProperty(prop^,positionDessinIcone,dimension) then
	        begin
	          Move(dimension.h,0);
	          positionHorizontale := positionHorizontale+dimension.h;
	          
	          if (numeroDuCoup>0) & (numeroDuCoup<=64) 
	            then s := NumEnString(numeroDuCoup)+'.'
	            else s := '';
	          s := s+CoupEnString(GetOthelloSquareOfProperty(prop^),CassioUtiliseDesMajuscules);
	          
	          prop := SelectFirstPropertyOfTypes([TesujiProp,BadMoveProp,InterestingMoveProp,DubiousMoveProp,ExoticMoveProp],L);
	          if prop <> NIL then
	            case prop^.genre of
	              TesujiProp : 
	                if GetTripleOfProperty(prop^).nbTriples>=2
	                  then s := s+'!!'
	                  else s := s+'!';
	              BadMoveProp :
	                if GetTripleOfProperty(prop^).nbTriples>=2
	                  then s := s+'??'
	                  else s := s+'?';
	              InterestingMoveProp :
	                begin
	                  {s := s+'!?';}
	                end;
	              DubiousMoveProp :
	                begin
	                  {s := s+'?!';}
	                end;
	              ExoticMoveProp :
	                begin
	                  {s := s+'?!';}
	                end;
	            end; {case}
	          
	          TextFace(bold);
	          Move(4,0);
	          positionHorizontale := positionHorizontale+4;
	          
	          EcritChaineOfProperty(s,largeur);
	          
	          TextFace(normal);
	          positionHorizontale := positionHorizontale+largeur+espaceEntreProperties;
	          
	          if phaseCalculListePositionsProperties then
					    begin
					      propertyBox := MakeRect(oldPositionHorizontale-1,positionDessinIcone.v,positionHorizontale-1,positionDessinIcone.v+14);
					      {FrameRect(propertyBox);}
					      description := MakePointeurPropertyProperty(PointeurPropertyProp,gNoeudQuOnDessineSurCetteLigne,prop,propertyBox);
					      AddPropertyInFrontOfList(description,ListePositionsProperties);
					      DisposePropertyStuff(description);
					    end;
	        end;
	    end;
end;


procedure DetruireCeFilsOfCurrentNode(var whichSon : GameTree);
begin
  EffaceProprietesOfCurrentNode;
  DeleteThisSon(GetCurrentNode(),whichSon);
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier);
  AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DetruireCeFilsOfCurrentNode');
  SetNiveauTeteDeMort(0);
  AjusteCurseur;
  GarbageCollectionDansTableHashageInterversions;
end;

procedure InverserLeNiemeFilsDansFenetreArbreDeJeu(N : SInt16);
var unRect : rect;
    minimum : SInt16; 
    oldport : grafPtr;
begin
  with arbreDeJeu do
    begin
		  GetPort(oldport);
		  SetPortByWindow(GetArbreDeJeuWindow());
		  minimum := backMoveRect.bottom+espaceEntreLignesProperties*(N-1);
		  SetRect(unRect,0,minimum-1,400,minimum+12);
		  HiliteRect(unRect);
		  SetPort(oldport);
		end;
end;

procedure CalculePropertiesDescriptionList;
begin
  VideListePositionsProperties;
  SetPhaseCalculListePositionsProperties(true);
  EcritNoeudDansFenetreArbreDeJeu(GetCurrentNode(),true);
  SetPhaseCalculListePositionsProperties(false);
end;

function PtInPropertyRect(var prop : Property; var mouseLocEnLongint : SInt32) : boolean;
begin
  PtInPropertyRect := PtInRect(Point(mouseLocEnLongint),GetRectangleAffichageOfProperty(prop));
end;

function PropertyPointeeParSouris() : PropertyPtr;
var mouseLoc : Point;
begin
  if not(PhaseCalculListePositionsProperties) then { pas d'appel recursif }
    begin
      GetMouse(mouseLoc);
      {WritelnDansRapport('avant MakePropertiesDescriptionList dans PropertyPointeeParSouris');}
      CalculePropertiesDescriptionList;
      PropertyPointeeParSouris := SelectInPropertList(listePositionsProperties,PtInPropertyRect,SInt32(mouseLoc));
      {PropertyPointeeParSouris := NIL;}
      VideListePositionsProperties;
    end;
end;

function SurIconeInterversion(whichPoint : Point; var noeudCorrespondant : GameTree) : boolean;
var description,prop : PropertyPtr;
begin
  SurIconeInterversion := false;
  noeudCorrespondant := NIL;
  if not(phaseCalculListePositionsProperties) then { pas d'appel recursif }
    begin
      CalculePropertiesDescriptionList;
      description := SelectInPropertList(listePositionsProperties,PtInPropertyRect,SInt32(whichPoint));
      if (description <> NIL) then
        begin
          prop := GetPropertyPtrOfProperty(description^);
          noeudCorrespondant := GetPossesseurOfPointeurPropertyProperty(description^);
          SurIconeInterversion := (prop <> NIL) & 
                                  ((prop^.genre=TranspositionProp) | (prop^.genre=TranspositionRangeProp));
        end;
      VideListePositionsProperties;
    end;
end;


procedure AfficheCommentaireOfNodeDansRapport(var G : GameTree; var numeroDuCoup : SInt32; var commentaireVide : boolean);
var texte : Ptr;
    coup : SInt32;
    longueurDuCommentaire : SInt32;
begin 
  longueurDuCommentaire := 0;
  commentaireVide := true;
  if NoeudHasCommentaire(G) then
    begin
      commentaireVide := false;
      if not(EstLaRacineDeLaPartie(G)) & GetSquareOfMoveInNode(G,coup) then
        begin
          ChangeFontSizeDansRapport(gCassioRapportBoldSize);
          ChangeFontDansRapport(gCassioRapportBoldFont);
          ChangeFontFaceDansRapport(bold);
          WriteDansRapport(NumEnString(numeroDuCoup)+'.'+CoupEnString(coup,CassioUtiliseDesMajuscules)+' ');
          TextNormalDansRapport;
          WriteDansRapport(': ');
        end;
      GetCommentaireDeCeNoeud(G,texte,longueurDuCommentaire);
      InsereTexteDansRapport(texte,longueurDuCommentaire);
      WritelnDansRapport('');
    end;
end;

procedure AfficheCommentairePartieDansRapport;
var partieEnAlpha,s : str255;
    positionCourante : PositionEtTraitRec;
begin
  if CreatePartieEnAlphaJusqua(GetCurrentNode(),partieEnAlpha,positionCourante) then
    begin
      s := ReadStringFromRessource(10020,9) + partieEnAlpha;  {'Commentaires de '}
      
      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
      ChangeFontFaceDansRapport(bold);
      WritelnDansRapport(s);
      TextNormalDansRapport;
      
      ForEachPositionOnPathToCurrentNodeDo(AfficheCommentaireOfNodeDansRapport);
    end;
end;

end.