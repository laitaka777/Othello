UNIT UnitMenus;





INTERFACE







USES UnitOth0;


const  

   { items du menu Pomme }
     FFOCmd = 2;
     {--------}
     PreferencesDansPommeCmd = 4;    { attention, seulement valable sous Mac OS X ! }

   FileID=2;
     NouvellePartieCmd = 1;
     OuvrirCmd = 2;
     ReouvrirCmd = 3;
     CloseCmd = 4;
     ImporterUnRepertoireCmd = 5;
     {-------}
     EnregistrerPartieCmd = 7;
     EnregistrerArbreCmd = 8;
     {-------}
     ApercuAvantImpressionCmd = 10;
     FormatImpressionCmd = 11;    
     ImprimerCmd = 12;    
     {-------}
     IconisationCmd = 14;
     PreferencesCmd = 15;
     {-------}
     QuitCmd = 17;
   
   EditionID=3;
     AnnulerCmd = 1;
     {--------}
     CouperCmd = 3;
     CopierCmd = 4;
     CopierSpecialCmd = 5;
     CollerCmd = 6;
     EffacerCmd = 7;
     ToutSelectionnerCmd = 8;
     {---------}
     ParamPressePapierCmd = 10;
     {---------}
     RaccourcisCmd = 12;
     
   
   PartieID=4;
     RevenirCmd = 1;
     DebutCmd = 2;
     {-------}
     BackCmd = 4;
     ForwardCmd = 5;
     DoubleBackCmd = 6;
     DoubleForwardCmd = 7;
     {--------}
     PoserMarqueCmd = 9;
     AvanceMarqueCmd = 10;
     ReculeMarqueCmd = 11;
     {-------}
     DiagrameCmd = 13;
     TaperUnDiagrammeCmd = 14;
     {-------}
     MakeMainBranchCmd = 16;
     DeleteMoveCmd = 17;
     SetUpCmd = 18;
     {-------}
     ForceCmd = 20;
   
   ModeID=5;
     CadenceCmd = 1;
     ReflSurTempsAdverseCmd = 2;
     {------}
     BiblActiveCmd = 4;
     VarierOuverturesCmd = 5;
     {-------}
     MilieuDeJeuNormalCmd = 7;
     MilieuDeJeuNMeilleursCoupsCmd = 8;
     MilieuDeJeuAnalyseCmd = 9;
     FinaleGagnanteCmd = 10;
     FinaleOptimaleCmd = 11;
     {-------}
     CoeffEvalCmd = 13;
     {-------}
     ParametrerAnalyseRetrogradeCmd = 15;
     AnalyseRetrogradeCmd = 16;
   
   
   JoueursID=6;
     HumCreHumCmd = 1;
     {-------}
     MacNoirsCmd = 3;
     MacBlancsCmd = 4;
     {-------}
     MinuteNoirCmd = 6;
     MinuteBlancCmd = 7;
   
   
   AffichageID=7;
     ChangerEn3DCmd = 1;
     CouleurCmd = 2;
     {-------}
     Symetrie_A8_H1Cmd = 4;
     Symetrie_A1_H8Cmd = 5;
     DemiTourCmd = 6;
     {-------}
     ConfigurerAffichageCmd = 8;
     {-------}
     PaletteFlottanteCmd = 10;
     RapportCmd = 11;
     ReflexionsCmd = 12;
     GestionTempsCmd = 13;
     CommentairesCmd = 14;
     CourbeCmd = 15;
     {-------}
     SonCmd = 17;
     
     
   BaseID=8;
     ChargerDesPartiesCmd = 1;
     EnregistrerPartiesBaseCmd = 2;
     {-------}
     OuvrirSelectionneeCmd = 4; 
     JouerSelectionneCmd = 5;
     JouerMajoritaireCmd = 6;
     {-------}
     StatistiqueCmd = 8;
     ListePartiesCmd = 9;
     {-------}
     SousSelectionActiveCmd = 11;
     CriteresCmd = 12;
     {-------}
     AjouterPartieDansListeCmd = 14;
     TrierCmd = 15;
     ChangerOrdreCmd = 16;
     {-------}
     AjouterGroupeCmd = 18;
     ListerGroupesCmd = 19;
     {------Ñ}
     InterversionCmd = 21;
     AlerteInterversionCmd = 22;
   
   SolitairesID=10;
     JouerNouveauSolitaireCmd = 1;
     ConfigurationSolitaireCmd = 2;
     EcrireSolutionSolitaireCmd = 3;
     EstSolitaireCmd = 4;
     {-------}
     ChercherNouveauProblemeDeCoinCmd = 6;
     ChercherProblemeDeCoinDansListeCmd = 7;
     EstProblemeDeCoinCmd = 8;
   
   CouleurID=100;
   (* Picture2DCmd = 1;  {les couleurs sont definies dans UnitCouleur.p}
      Picture3DCmd = 2;
      {----------}
     VertCmd = 4;
     VertPaleCmd = 5;
     VertSapinCmd = 6;
     VertPommeCmd = 7;
     VertTurquoiseCmd = 8;
     VertKakiCmd = 9;
     BleuCmd = 10;
     BleuPaleCmd = 11;
     MarronCmd = 12;
     RougePaleCmd = 13;
     OrangeCmd = 14;
     JauneCmd = 15;
     JaunePaleCmd = 16;
     MarineCmd = 17;
     MarinePaleCmd = 18;
     VioletCmd = 19;
     MagentaCmd = 20;
     MagentaPaleCmd = 21;
     AutreCouleurCmd = 22;
      {-------------}
      NoirCmd  = -1;    {valeur speciale : item impossible}
      BlancCmd = -2;    {valeur speciale : item impossible}
      RougeCmd = 1000;  {valeur speciale : item impossible pour pouvoir avoir le rouge en RGB}
    *)
     
   TriID=101;
     TriParDatabaseCmd = 1;
     TriParDateCmd = 2;
     TriParJoueurNoirCmd = 3;
     TriParJoueurBlancCmd = 4;
     TriParOuvertureCmd = 5;
     TriParTheoriqueCmd = 6;
     TriParReelCmd = 7;

   CopierSpecialID=102;
     CopierSequenceCoupsEnTEXTCmd = 1;
     CopierDiagrammePartieEnTEXTCmd = 2;
     CopierPositionCouranteEnTEXTCmd = 3;
     CopierPositionCouranteEnHTMLCmd = 4;
     CopierPositionPourEndgameScriptCmd = 5;
     {---------------------}
     CopierDiagramme10x10Cmd = 7;
   
   ReouvrirID=103;
   
   
   NMeilleursCoupID=104;
     MeilleuresNotes2Cmd = 1;
     MeilleuresNotes3Cmd = 2;
     MeilleuresNotes4Cmd = 3;
     MeilleuresNotes5Cmd = 4;
     MeilleuresNotes6Cmd = 5;
     MeilleuresNotes7Cmd = 6;
     MeilleuresNotes8Cmd = 7;
     MeilleuresNotes9Cmd = 8;
     MeilleuresNotes10Cmd = 9;
     MeilleuresNotes11Cmd = 10;
     MeilleuresNotes12Cmd = 11;
     
   {pour l'instant on ne se sert pas de ce sous-menu}
   NbMeilleuresNotesRetrogradeID=105;
     MeilleureNoteRetroCmd = 1;
     Meilleures2NotesRetroCmd = 2;
     Meilleures3Notes3RetroCmd = 3;
     Meilleures4Notes4RetroCmd = 4;
     Meilleures5NotesRetroCmd = 5;
     Meilleures6NotesRetroCmd = 6;
     Meilleures7NotesRetroCmd = 7;
     Meilleures8NotesRetroCmd = 8;
     ToutesNotesRetroCmd = 10;
     
   
   ProfondeurID=106;
     Profondeur3Cmd = 1;
     Profondeur5Cmd = 2;
     Profondeur7Cmd = 3;
     Profondeur9Cmd = 4;
     Profondeur11Cmd = 5;
     Profondeur13Cmd = 6;
     Profondeur15Cmd = 7;
     Profondeur17Cmd = 8;
     Profondeur19Cmd = 9;
     Profondeur21Cmd = 10;
     Profondeur23Cmd = 11;
     DixSecParCoupCmd = 13;
     VingtSecParCoupCmd = 14;
     TrenteSecParCoupCmd = 15;
     UneMinParCoupCmd = 16;
     DeuxMinParCoupCmd = 17;
     CinqMinParCoupCmd = 18;
     QuinzeMinParCoupCmd = 19;
     UneHeureParCoupCmd = 20;
   
   
   DureeAnalyseID=107;
     Pendant1MinCmd = 1;
     Pendant2MinCmd = 2;
     Pendant5MinCmd = 3;
     Pendant10MinCmd = 4;
     Pendant30MinCmd = 5;
     Pendant1HeureCmd = 6;
     Pendant2HeuresCmd = 7;
     Pendant6HeuresCmd = 8;
     Pendant12HeuresCmd = 9;
     Jusque45Cmd = 11;
     Jusque40Cmd = 12;
     Jusque35Cmd = 13;
     Jusque30Cmd = 14;
     Jusque25Cmd = 15;
     Jusque20Cmd = 16;
     Jusque15Cmd = 17;
     FinDesTempsCmd = 19;
     
   FormatBaseID=108;
     FormatWTBCmd = 1;
     FormatPARCmd = 2;
     FormatTexteCmd = 3;
     FormatHTMLCmd = 4;
     FormatPGNCmd = 5;
     FormatXOFCmd = 6;
   
   Picture2DID=109;
   
   Picture3DID=110;
   
   GestionBaseWThorID=111;
     ChangerTournoiCmd = 1;
     ChangerJoueurNoirCmd = 2;
     ChangerJoueurBlancCmd = 3;
     SelectionnerTheoriqueEgalReelCmd = 5;
     CalculerScoreTheoriqueCmd = 6;
     CreerTournoiCmd = 8;
     CreerJoueurCmd = 9;
   
   ProgrammationID=9;
     AjusterModeleLineaireCmd = 1;
     ChercherSolitairesListeCmd = 2;
     VariablesSpecialesCmd = 3;
     OuvrirBiblCmd = 4;
     GestionBaseWThorCmd = 5;
     NettoyerGrapheCmd = 6;
     CompterPartiesGrapheCmd = 7;
     effetspecial1Cmd = 8;
     effetspecial2Cmd = 9;
     Unused2Cmd = 10;
     Unused3Cmd = 11;
     Unused4Cmd = 12;
     Unused5Cmd = 13;
     AffCelluleApprentissaCmd = 14;
     EcrireDansRapportLogCmd = 15;
     UtiliserNouvelleEvalCmd = 16;
     TraitementDeTexteCmd = 17;
     DemoCmd = 18;
     ArrondirEvaluationsCmd = 19;
     UtiliserScoresArbreCmd = 20;
     
   OuvertureID=3001;
   
   TypeAnalyseID=3006;
     RetrogradeParfaiteCmd = 1;
     RetrogradeGagnanteCmd = 2;
     RetrogradeMilieuCmd = 3;
     RienDuToutCmd = 5;

type MenuCmdRec =
       record
         theMenu : SInt16; 
         theCmd : SInt16; 
       end;

var gLastTexture2D:MenuCmdRec;
    gLastTexture3D:MenuCmdRec;
     
function MyMenuKey(ch : char) : SInt32;

procedure EnableItemPourCassio(whichMenu : MenuRef;whichItem : SInt16);
procedure EssaieDisableForceCmd;
procedure FixeMarqueSurMenuMode(n : SInt16);
procedure FixeMarqueSurMenuBase;
procedure DisableItemTousMenus;
procedure EnableItemTousMenus;
procedure FixeMarquesSurMenus;

function NomLongDejaCalculeDansMenuReouvrir(path : str255; var theLongName : str255) : boolean;
procedure SetReouvrirItem(nomFichier : str255;numeroItem : SInt16);
function GetNomCompletFichierDansMenuReouvrir(numeroItem : SInt16) : str255;
procedure AjoutePartieDansMenuReouvrir(CheminEtNomFichier : str255);
procedure CleanReouvrirMenu;

procedure SetMenusChangeant(modifiers : SInt16);
procedure DisableTitlesOfMenusForRetour;
procedure EnableAllTitlesOfMenus;

procedure BeginHiliteMenu(menuID : SInt16);
procedure EndHiliteMenu(tickDepart : SInt32;delai : SInt32;sansAttente : boolean);

  
  
IMPLEMENTATION







USES UnitRapport,UnitTroisiemeDimension,UnitNotesSurCases,UnitUtilitaires,MyStrings,SNStrings,
     UnitPressePapier,UnitPrint,UnitCarbonisation,UnitOth1,UnitEntreeTranscript,UnitGestionDuTemps,
     Timer,UnitNormalisation,UnitCouleur,UnitJeu;




function EquivalentClavierEstDansCeMenu(ch : char;whichMenu : MenuRef; var whichItem : SInt16) : boolean;
var i : SInt16; 
    cmdChar : char;
begin
  EquivalentClavierEstDansCeMenu := false;
  whichItem := 0;
  for i := 1 to MyCountMenuItems(whichMenu) do
    if IsMenuItemEnabled(whichMenu,i) then
      begin
        GetItemCmd(whichMenu,i,cmdChar);
        if (ord(cmdChar)>0) & ((ch=cmdChar) | (ch=chr(ord(cmdChar)+32))) then
          begin
            EquivalentClavierEstDansCeMenu := true;
            whichItem := i;
            exit(EquivalentClavierEstDansCeMenu);
          end;
      end;
end;

function MyMenuKey(ch : char) : SInt32;
var res : SInt32;
    item : SInt16; 
begin
  res := 0;
  if EquivalentClavierEstDansCeMenu(ch,GetAppleMenu(),item)      then res := item + 65536*AppleID            else
  if EquivalentClavierEstDansCeMenu(ch,GetFileMenu(),item)       then res := item + 65536*FileID             else
  if EquivalentClavierEstDansCeMenu(ch,EditionMenu,item)         then res := item + 65536*EditionID          else
  if EquivalentClavierEstDansCeMenu(ch,PartieMenu,item)          then res := item + 65536*PartieID           else
  if EquivalentClavierEstDansCeMenu(ch,ModeMenu,item)            then res := item + 65536*ModeID             else
  if EquivalentClavierEstDansCeMenu(ch,JoueursMenu,item)         then res := item + 65536*JoueursID          else
  if EquivalentClavierEstDansCeMenu(ch,AffichageMenu,item)       then res := item + 65536*AffichageID        else
  if EquivalentClavierEstDansCeMenu(ch,BaseMenu,item)            then res := item + 65536*BaseID             else
  if EquivalentClavierEstDansCeMenu(ch,SolitairesMenu,item)      then res := item + 65536*SolitairesID       else
  if EquivalentClavierEstDansCeMenu(ch,CouleurMenu,item)         then res := item + 65536*CouleurID          else
  if EquivalentClavierEstDansCeMenu(ch,TriMenu,item)             then res := item + 65536*TriID              else
  if EquivalentClavierEstDansCeMenu(ch,FormatBaseMenu,item)      then res := item + 65536*FormatBaseID       else
  if EquivalentClavierEstDansCeMenu(ch,Picture2DMenu,item)       then res := item + 65536*Picture2DID        else
  if EquivalentClavierEstDansCeMenu(ch,Picture3DMenu,item)       then res := item + 65536*Picture3DID        else
  if EquivalentClavierEstDansCeMenu(ch,CopierSpecialMenu,item)   then res := item + 65536*CopierSpecialID    else
  if EquivalentClavierEstDansCeMenu(ch,GestionBaseWThorMenu,item)then res := item + 65536*GestionBaseWThorID else
  if EquivalentClavierEstDansCeMenu(ch,NMeilleursCoupsMenu,item) then res := item + 65536*NMeilleursCoupID   else
  if EquivalentClavierEstDansCeMenu(ch,ReouvrirMenu,item)        then res := item + 65536*ReouvrirID         else
  if avecProgrammation & 
     EquivalentClavierEstDansCeMenu(ch,ProgrammationMenu,item)   then res := item + 65536*ProgrammationID;      
  
  if res <> 0 then BeginHiliteMenu(res div 65536);
  MyMenuKey := res;
end;
  
procedure EnableItemPourCassio(whichMenu : MenuRef;whichItem : SInt16);
begin
  if not(iconisationDeCassio.encours) then
    MyEnableItem(whichMenu,whichItem);
end;
  
procedure EssaieDisableForceCmd;
begin
  if RefleSurTempsJoueur | HumCtreHum | (aQuiDeJouer<>couleurMacintosh)
     then MyDisableItem(PartieMenu,ForceCmd);
end;




procedure FixeMarqueSurMenuMode(n : SInt16);
begin
  
  MyCheckItem(NMeilleursCoupsMenu,1,not(avecEvaluationTotale) & (nbCoupsEnTete=2));
  MyCheckItem(NMeilleursCoupsMenu,2,not(avecEvaluationTotale) & (nbCoupsEnTete=3));
  MyCheckItem(NMeilleursCoupsMenu,3,not(avecEvaluationTotale) & (nbCoupsEnTete=4));
  MyCheckItem(NMeilleursCoupsMenu,4,not(avecEvaluationTotale) & (nbCoupsEnTete=5));
  MyCheckItem(NMeilleursCoupsMenu,5,not(avecEvaluationTotale) & (nbCoupsEnTete=6));
  MyCheckItem(NMeilleursCoupsMenu,6,not(avecEvaluationTotale) & (nbCoupsEnTete=7));
  MyCheckItem(NMeilleursCoupsMenu,7,not(avecEvaluationTotale) & (nbCoupsEnTete=8));
  MyCheckItem(NMeilleursCoupsMenu,8,not(avecEvaluationTotale) & (nbCoupsEnTete=9));
  MyCheckItem(NMeilleursCoupsMenu,9,not(avecEvaluationTotale) & (nbCoupsEnTete=10));
  MyCheckItem(NMeilleursCoupsMenu,10,not(avecEvaluationTotale) & (nbCoupsEnTete=11));
  MyCheckItem(NMeilleursCoupsMenu,11,not(avecEvaluationTotale) & (nbCoupsEnTete=12));

  MyCheckItem(ModeMenu,ReflSurTempsAdverseCmd,not(sansReflexionSurTempsAdverse));
  MyCheckItem(ModeMenu,BiblActiveCmd,avecBibl & bibliothequeLisible);
  MyCheckItem(ModeMenu,VarierOuverturesCmd,gEntrainementOuvertures.CassioVarieSesCoups & (GetCadence() <= gEntrainementOuvertures.varierJusquaCetteCadence));
  if InRange(n,0,finDePartie-1) then
    begin
      MyCheckItem(ModeMenu,MilieuDeJeuNormalCmd,not(avecEvaluationTotale) & (nbCoupsEnTete<=1));
      MyCheckItem(ModeMenu,MilieuDeJeuAnalyseCmd,avecEvaluationTotale);
      MyCheckItem(ModeMenu,FinaleGagnanteCmd,false);
      MyCheckItem(ModeMenu,FinaleOptimaleCmd,false);
    end;
  if InRange(n,finDePartie,finDePartieOptimale-1) then
    begin
      MyCheckItem(ModeMenu,MilieuDeJeuNormalCmd,false);
      MyCheckItem(ModeMenu,MilieuDeJeuAnalyseCmd,false);
      MyCheckItem(ModeMenu,FinaleGagnanteCmd,true);
      MyCheckItem(ModeMenu,FinaleOptimaleCmd,false);
    end;
  if InRange(n,finDePartieOptimale,65) then
    begin
      MyCheckItem(ModeMenu,MilieuDeJeuNormalCmd,false);
      MyCheckItem(ModeMenu,MilieuDeJeuAnalyseCmd,false);
      MyCheckItem(ModeMenu,FinaleGagnanteCmd,false);
      MyCheckItem(ModeMenu,FinaleOptimaleCmd,true);
    end;
  if ((60-n) <= kNbMaxNiveaux-1) & not(iconisationDeCassio.encours) & not(enSetUp) & not(enRetour) then
     begin
      MyEnableItem(ModeMenu,MilieuDeJeuNormalCmd);
      MyEnableItem(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd);
      MyEnableItem(ModeMenu,MilieuDeJeuAnalyseCmd);
      MyEnableItem(ModeMenu,FinaleGagnanteCmd);
      MyEnableItem(ModeMenu,FinaleOptimaleCmd);
     end
   else
     begin
      if not(iconisationDeCassio.encours) & not(enSetUp) & not(enRetour) then
        begin
          MyEnableItem(ModeMenu,MilieuDeJeuNormalCmd);
          MyEnableItem(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd);
          MyEnableItem(ModeMenu,MilieuDeJeuAnalyseCmd);
        end;
      MyDisableItem(ModeMenu,FinaleGagnanteCmd);
      MyDisableItem(ModeMenu,FinaleOptimaleCmd);
     end;
     
  if analyseRetrograde.enCours | (enSetUp | enRetour | iconisationDeCassio.encours)
    then MyDisableItem(ModeMenu,ParametrerAnalyseRetrogradeCmd)
    else EnableItemPourCassio(ModeMenu,ParametrerAnalyseRetrogradeCmd);
  if (nroDernierCoupAtteint >= 20) & not(analyseRetrograde.enCours) & not(enSetUp | enRetour | iconisationDeCassio.encours)
    then EnableItemPourCassio(ModeMenu,AnalyseRetrogradeCmd)
    else MyDisableItem(ModeMenu,AnalyseRetrogradeCmd);
  
  if (n >= 1) & not(enSetUp | enRetour | iconisationDeCassio.encours)
    then EnableItemPourCassio(PartieMenu,MakeMainBranchCmd)
    else MyDisableItem(PartieMenu,MakeMainBranchCmd);
  
    
  if (nbreCoup < nroDernierCoupAtteint) & not(iconisationDeCassio.encours) & not(enSetUp) & not(enRetour)
    then 
      begin
        MyEnableItem(PartieMenu,ForwardCmd);
        MyEnableItem(PartieMenu,AvanceMarqueCmd);
      end
    else 
      begin
        MyDisableItem(PartieMenu,ForwardCmd);
        MyDisableItem(PartieMenu,AvanceMarqueCmd);
      end;
  if ((nbreCoup+1) < nroDernierCoupAtteint) & not(enSetUp) & not(enRetour)
    then 
      begin
        EnableItemPourCassio(PartieMenu,DoubleForwardCmd);
      end
    else 
      begin
        MyDisableItem(PartieMenu,DoubleForwardCmd);
      end;
  if (nbreCoup>0) & not(iconisationDeCassio.encours)
    then MyEnableItem(EditionMenu,AnnulerCmd)
    else MyDisableItem(EditionMenu,AnnulerCmd);
  if (nbreCoup>0) & not(iconisationDeCassio.encours) & not(enSetUp) & not(enRetour)
    then 
      begin
        MyEnableItem(PartieMenu,BackCmd);
        MyEnableItem(PartieMenu,ReculeMarqueCmd);
        MyEnableItem(PartieMenu,RevenirCmd);
        MyEnableItem(PartieMenu,DebutCmd);
        MyEnableItem(PartieMenu,DeleteMoveCmd);
      end
    else 
      begin
        MyDisableItem(PartieMenu,BackCmd);
        MyDisableItem(PartieMenu,ReculeMarqueCmd);
        MyDisableItem(PartieMenu,RevenirCmd);
        MyDisableItem(PartieMenu,DebutCmd);
        MyDisableItem(PartieMenu,DeleteMoveCmd);
      end;
   if (nbreCoup>1) & not(iconisationDeCassio.encours) & not(enSetUp) & not(enRetour)
    then 
      begin
        MyEnableItem(PartieMenu,DoubleBackCmd);
      end
    else 
      begin
        MyDisableItem(PartieMenu,DoubleBackCmd);
      end;
      
   if ((60-n) <= 30) & not(enSetUp) & not(enRetour)
    then EnableItemPourCassio(SolitairesMenu,EstSolitaireCmd) 
    else MyDisableItem(SolitairesMenu,EstSolitaireCmd);
    
   if CassioEstEnModeSolitaire() & not(enSetUp) & not(enRetour)
     then EnableItemPourCassio(SolitairesMenu,EcrireSolutionSolitaireCmd)
     else MyDisableItem(SolitairesMenu,EcrireSolutionSolitaireCmd);
end;


procedure FixeMarqueSurMenuBase;
begin
   if windowListeOpen & (nbPartiesActives>0) & not(iconisationDeCassio.encours) 
     then EnableItemPourCassio(BaseMenu,EnregistrerPartiesBaseCmd)
     else MyDisableItem(BaseMenu,EnregistrerPartiesBaseCmd);
   if {windowListeOpen & }not(positionFeerique) & gameOver & not(enSetUp | enRetour | iconisationDeCassio.encours)
     then EnableItemPourCassio(BaseMenu,AjouterPartieDansListeCmd)
     else MyDisableItem(BaseMenu,AjouterPartieDansListeCmd);
   if windowListeOpen & not(enSetUp | enRetour | iconisationDeCassio.encours)
     then EnableItemPourCassio(BaseMenu,TrierCmd)
     else MyDisableItem(BaseMenu,TrierCmd);
   if windowListeOpen & (nbPartiesActives>0) & not(iconisationDeCassio.encours) 
    then
      begin
        MyEnableItem(BaseMenu,ChangerOrdreCmd);
        MyEnableItem(BaseMenu,OuvrirSelectionneeCmd);
      end
    else
      begin
        MyDisableItem(BaseMenu,ChangerOrdreCmd);
        MyDisableItem(BaseMenu,OuvrirSelectionneeCmd);
      end;
   if windowListeOpen & (nbPartiesActives>0) & not(gameOver) & not(iconisationDeCassio.encours) 
     then MyEnableItem(BaseMenu,JouerSelectionneCmd)
     else MyDisableItem(BaseMenu,JouerSelectionneCmd);
   if windowStatOpen & (nbPartiesActives>0) & not(gameOver) & not(iconisationDeCassio.encours) 
     then MyEnableItem(BaseMenu,JouerMajoritaireCmd)
     else MyDisableItem(BaseMenu,JouerMajoritaireCmd);
end;



procedure DisableItemTousMenus;
  begin
   MyDisableItem(GetFileMenu(),nouvellePartieCmd);
   MyDisableItem(GetFileMenu(),OuvrirCmd);
   MyDisableItem(GetFileMenu(),ReouvrirCmd);
   MyDisableItem(GetFileMenu(),CloseCmd);
   MyDisableItem(GetFileMenu(),ImporterUnRepertoireCmd);
   MyDisableItem(GetFileMenu(),EnregistrerPartieCmd);
   MyDisableItem(GetFileMenu(),EnregistrerArbreCmd);
   if not(enRetour) | iconisationDeCassio.encours then
     begin
       MyDisableItem(GetFileMenu(),ApercuAvantImpressionCmd);
       MyDisableItem(GetFileMenu(),FormatImpressionCmd);
       MyDisableItem(GetFileMenu(),ImprimerCmd);
     end;
   MyDisableItem(GetFileMenu(),PreferencesCmd);
   if enSetUp then MyDisableItem(GetFileMenu(),IconisationCmd);
  
   
   if iconisationDeCassio.encours then
     MyDisableItem(EditionMenu,AnnulerCmd); 
   MyDisableItem(EditionMenu,CollerCmd);
   MyDisableItem(EditionMenu,EffacerCmd);
   if not(enRetour) | iconisationDeCassio.encours
     then 
       begin
         MyDisableItem(EditionMenu,CopierCmd);
         MyDisableItem(EditionMenu,CouperCmd);
       end;
   MyDisableItem(EditionMenu,ToutselectionnerCmd);
   if enSetUp | iconisationDeCassio.encours  then 
     MyDisableItem(EditionMenu,ParamPressePapierCmd);
   MyDisableItem(EditionMenu,RaccourcisCmd);
   
   
   
   MyDisableItem(PartieMenu,RevenirCmd);
   MyDisableItem(PartieMenu,DebutCmd);
   MyDisableItem(PartieMenu,BackCmd);
   MyDisableItem(PartieMenu,ForwardCmd);
   MyDisableItem(PartieMenu,DoubleBackCmd);
   MyDisableItem(PartieMenu,DoubleForwardCmd);
   MyDisableItem(PartieMenu,DiagrameCmd);
   MyDisableItem(PartieMenu,TaperUnDiagrammeCmd);
   MyDisableItem(PartieMenu,MakeMainBranchCmd);
   MyDisableItem(PartieMenu,DeleteMoveCmd);
   MyDisableItem(PartieMenu,SetUpCmd);
   MyDisableItem(PartieMenu,ForceCmd);
   MyDisableItem(PartieMenu,PoserMarqueCmd);
   MyDisableItem(PartieMenu,ReculeMarqueCmd);
   MyDisableItem(PartieMenu,AvanceMarqueCmd);
   
   MyDisableItem(ModeMenu,CadenceCmd);
   MyDisableItem(ModeMenu,ReflSurTempsAdverseCmd);
   MyDisableItem(ModeMenu,BiblActiveCmd);
   MyDisableItem(ModeMenu,VarierOuverturesCmd);
   MyDisableItem(ModeMenu,MilieuDeJeuNormalCmd);
   MyDisableItem(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd);
   MyDisableItem(ModeMenu,MilieuDeJeuAnalyseCmd);
   MyDisableItem(ModeMenu,FinaleGagnanteCmd);
   MyDisableItem(ModeMenu,FinaleOptimaleCmd);
   MyDisableItem(ModeMenu,CoeffEvalCmd);
   MyDisableItem(ModeMenu,ParametrerAnalyseRetrogradeCmd);
   MyDisableItem(ModeMenu,AnalyseRetrogradeCmd);
   
   
   MyDisableItem(JoueursMenu,HumCreHumCmd);
   MyDisableItem(JoueursMenu,MacNoirsCmd);
   MyDisableItem(JoueursMenu,MacBlancsCmd);
   MyDisableItem(JoueursMenu,MinuteNoirCmd);
   MyDisableItem(JoueursMenu,MinuteBlancCmd);
   
   MyDisableItem(AffichageMenu,ChangerEn3DCmd);
   if not(enRetour) | iconisationDeCassio.encours then
     begin
       MyDisableItem(AffichageMenu,Symetrie_A1_H8Cmd);
       MyDisableItem(AffichageMenu,Symetrie_A8_H1Cmd);
       MyDisableItem(AffichageMenu,DemiTourCmd);
     end;
   MyDisableItem(AffichageMenu,ConfigurerAffichageCmd);
   MyDisableItem(AffichageMenu,ReflexionsCmd);
   MyDisableItem(AffichageMenu,RapportCmd);
   MyDisableItem(AffichageMenu,GestionTempsCmd);
   MyDisableItem(AffichageMenu,CommentairesCmd);
   MyDisableItem(AffichageMenu,CourbeCmd);
   MyDisableItem(AffichageMenu,PaletteFlottanteCmd);
   MyDisableItem(AffichageMenu,CouleurCmd);
   MyDisableItem(AffichageMenu,SonCmd);
   
   MyDisableItem(SolitairesMenu,JouerNouveauSolitaireCmd);
   MyDisableItem(SolitairesMenu,ConfigurationSolitaireCmd);
   MyDisableItem(SolitairesMenu,EcrireSolutionSolitaireCmd);
   MyDisableItem(SolitairesMenu,EstSolitaireCmd);
   MyDisableItem(SolitairesMenu,ChercherNouveauProblemeDeCoinCmd);
   MyDisableItem(SolitairesMenu,ChercherProblemeDeCoinDansListeCmd);
   MyDisableItem(SolitairesMenu,EstProblemeDeCoinCmd);
   
   MyDisableItem(BaseMenu,ChargerDesPartiesCmd);
   MyDisableItem(BaseMenu,OuvrirSelectionneeCmd);
   MyDisableItem(BaseMenu,JouerSelectionneCmd);
   MyDisableItem(BaseMenu,JouerMajoritaireCmd);
   MyDisableItem(BaseMenu,StatistiqueCmd);
   MyDisableItem(BaseMenu,ListePartiesCmd);
   MyDisableItem(BaseMenu,SousSelectionActiveCmd);
   MyDisableItem(BaseMenu,CriteresCmd);
   MyDisableItem(BaseMenu,AjouterPartieDansListeCmd);
   MyDisableItem(BaseMenu,TrierCmd);
   MyDisableItem(BaseMenu,ChangerOrdreCmd);
   MyDisableItem(BaseMenu,AjouterGroupeCmd);
   MyDisableItem(BaseMenu,ListerGroupesCmd);
   MyDisableItem(BaseMenu,InterversionCmd);
   MyDisableItem(BaseMenu,AlerteInterversionCmd);
   
  end;
  
function SousMenuReouvrirEstVide() : boolean;
var k : SInt16; 
begin
  for k := 1 to NbMaxItemsReouvrirMenu do
    if (nomDuFichierAReouvrir[k] <> NIL) & (nomDuFichierAReouvrir[k]^^<>'') then
      begin
        SousMenuReouvrirEstVide := false;
        exit(SousMenuReouvrirEstVide);
      end;
  SousMenuReouvrirEstVide := true;
end;
  
procedure EnableItemTousMenus;
  begin
   MyEnableItem(GetFileMenu(),nouvellePartieCmd);
   MyEnableItem(GetFileMenu(),OuvrirCmd);
   
   if SousMenuReouvrirEstVide()
     then MyDisableItem(GetFileMenu(),reouvrirCmd)
     else MyEnableItem(GetFileMenu(),reouvrirCmd);
   
   
   if (NIL <> FrontWindow()) then
     begin
	      if (FrontWindow() <> wPlateauPtr) then
	        begin
	          if not(enSetUp | enRetour) 
	            then MyEnableItem(GetFileMenu(),CloseCmd);
	        end;
     end;
     
   
   MyEnableItem(GetFileMenu(),EnregistrerPartieCmd);
   MyEnableItem(GetFileMenu(),EnregistrerArbreCmd);  
   MyEnableItem(GetFileMenu(),ImporterUnRepertoireCmd);
  
   if windowPlateauOpen & ImpressionEstPossible()
     then
       begin
         MyEnableItem(GetFileMenu(),ApercuAvantImpressionCmd);
         MyEnableItem(GetFileMenu(),FormatImpressionCmd);
         MyEnableItem(GetFileMenu(),ImprimerCmd);
       end
     else
       begin
         MyDisableItem(GetFileMenu(),ApercuAvantImpressionCmd);
         MyDisableItem(GetFileMenu(),FormatImpressionCmd);
         MyDisableItem(GetFileMenu(),ImprimerCmd);
       end;
   MyEnableItem(GetFileMenu(),PreferencesCmd);
   if iconisationDeCassio.possible
     then MyEnableItem(GetFileMenu(),IconisationCmd)
     else MyDisableItem(GetFileMenu(),IconisationCmd);
       
   MyEnableItem(EditionMenu,AnnulerCmd);
   MyEnableItem(EditionMenu,CouperCmd);
   MyEnableItem(EditionMenu,CopierCmd);
   MyEnableItem(EditionMenu,CollerCmd);
   MyEnableItem(EditionMenu,EffacerCmd);
   MyEnableItem(EditionMenu,ToutSelectionnerCmd);
   MyEnableItem(EditionMenu,ParamPressePapierCmd);
   MyEnableItem(EditionMenu,RaccourcisCmd);
   
   MyEnableItem(PartieMenu,RevenirCmd);
   MyEnableItem(PartieMenu,DebutCmd);
   MyEnableItem(PartieMenu,BackCmd);
   MyEnableItem(PartieMenu,DoubleBackCmd);
   MyEnableItem(PartieMenu,DoubleForwardCmd);
   MyEnableItem(PartieMenu,DiagrameCmd);
   if not(analyseRetrograde.enCours)
     then MyEnableItem(PartieMenu,TaperUnDiagrammeCmd)
     else MyDisableItem(PartieMenu,TaperUnDiagrammeCmd);
   MyEnableItem(PartieMenu,MakeMainBranchCmd);
   MyEnableItem(PartieMenu,DeleteMoveCmd);
   if not(EnModeEntreeTranscript())
     then MyEnableItem(PartieMenu,SetUpCmd)
     else MyDisableItem(PartieMenu,SetUpCmd);
   if not(RefleSurTempsJoueur) & not(HumCtreHum) then MyEnableItem(PartieMenu,ForceCmd);
   MyEnableItem(PartieMenu,PoserMarqueCmd);
   MyEnableItem(PartieMenu,ReculeMarqueCmd);
   MyEnableItem(PartieMenu,AvanceMarqueCmd);
  
   MyEnableItem(ModeMenu,CadenceCmd);
   MyEnableItem(ModeMenu,ReflSurTempsAdverseCmd);
   if bibliothequeLisible
     then MyEnableItem(ModeMenu,BiblActiveCmd)
     else MyDisableItem(ModeMenu,BiblActiveCmd);
   if (GetCadence() < minutes5)
     then MyEnableItem(ModeMenu,VarierOuverturesCmd)
     else MyDisableItem(ModeMenu,VarierOuverturesCmd);
   MyEnableItem(ModeMenu,MilieuDeJeuNormalCmd);
   MyEnableItem(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd);
   MyEnableItem(ModeMenu,MilieuDeJeuAnalyseCmd);
   MyEnableItem(ModeMenu,FinaleGagnanteCmd);
   MyEnableItem(ModeMenu,FinaleOptimaleCmd);
   MyEnableItem(ModeMenu,CoeffEvalCmd);
   MyEnableItem(ModeMenu,ParametrerAnalyseRetrogradeCmd);
   MyEnableItem(ModeMenu,AnalyseRetrogradeCmd);
   FixeMarqueSurMenuMode(nbreCoup);
   
   
   MyEnableItem(JoueursMenu,HumCreHumCmd);
   MyEnableItem(JoueursMenu,MacNoirsCmd);
   MyEnableItem(JoueursMenu,MacBlancsCmd);
   MyEnableItem(JoueursMenu,MinuteNoirCmd);
   MyEnableItem(JoueursMenu,MinuteBlancCmd);
   
   MyEnableItem(AffichageMenu,ChangerEn3DCmd);
   MyEnableItem(AffichageMenu,Symetrie_A1_H8Cmd);
   MyEnableItem(AffichageMenu,Symetrie_A8_H1Cmd);
   MyEnableItem(AffichageMenu,DemiTourCmd);
   MyEnableItem(AffichageMenu,ConfigurerAffichageCmd);
   MyEnableItem(AffichageMenu,ReflexionsCmd);
   MyEnableItem(AffichageMenu,RapportCmd);
   MyEnableItem(AffichageMenu,GestionTempsCmd);
   MyEnableItem(AffichageMenu,CommentairesCmd);
   MyEnableItem(AffichageMenu,CourbeCmd);
   MyEnableItem(AffichageMenu,PaletteFlottanteCmd);
   MyEnableItem(AffichageMenu,CouleurCmd);
   MyEnableItem(AffichageMenu,SonCmd);   
   
   MyEnableItem(SolitairesMenu,JouerNouveauSolitaireCmd);
   MyEnableItem(SolitairesMenu,ConfigurationSolitaireCmd);
   if (60-nbreCoup)<=20
    then MyEnableItem(SolitairesMenu,EstSolitaireCmd)
    else MyDisableItem(SolitairesMenu,EstSolitaireCmd);
   if CassioEstEnModeSolitaire() 
     then MyEnableItem(SolitairesMenu,EcrireSolutionSolitaireCmd)
     else MyDisableItem(SolitairesMenu,EcrireSolutionSolitaireCmd);
   MyEnableItem(SolitairesMenu,ChercherNouveauProblemeDeCoinCmd);
   MyEnableItem(SolitairesMenu,ChercherProblemeDeCoinDansListeCmd);
   MyEnableItem(SolitairesMenu,EstProblemeDeCoinCmd);
   
   if avecGestionBase then
     begin
       MyEnableItem(BaseMenu,ChargerDesPartiesCmd);
       if windowListeOpen & (nbPartiesActives>0) then MyEnableItem(BaseMenu,ChangerOrdreCmd);
       if {windowListeOpen & }not(positionFeerique) & gameOver then EnableItemPourCassio(BaseMenu,AjouterPartieDansListeCmd);
       if windowListeOpen then MyEnableItem(BaseMenu,TrierCmd);
       if windowListeOpen & (nbPartiesActives>0) then MyEnableItem(BaseMenu,OuvrirSelectionneeCmd);
       if windowListeOpen & (nbPartiesActives>0) & not(gameOver) then MyEnableItem(BaseMenu,JouerSelectionneCmd);
       if windowStatOpen & (nbPartiesActives>0) & not(gameOver) then MyEnableItem(BaseMenu,JouerMajoritaireCmd);
       MyEnableItem(BaseMenu,StatistiqueCmd);
       MyEnableItem(BaseMenu,ListePartiesCmd);
       if JoueursEtTournoisEnMemoire then MyEnableItem(BaseMenu,CriteresCmd);
       if JoueursEtTournoisEnMemoire then MyEnableItem(BaseMenu,SousSelectionActiveCmd);
       MyEnableItem(BaseMenu,ListerGroupesCmd);
       MyEnableItem(BaseMenu,AjouterGroupeCmd);
       MyEnableItem(BaseMenu,InterversionCmd);
       MyEnableItem(BaseMenu,AlerteInterversionCmd);
     end;
   
  end;
 


procedure FixeMarquesSurMenus;
var coupUn,i : SInt16; 
  begin
  
    if (FrontWindow() <> NIL) & (FrontWindow()<>wPlateauPtr) & not(enSetUp | enRetour | iconisationDeCassio.encours)
      then MyEnableItem(GetFileMenu(),CloseCmd)
      else MyDisableItem(GetFileMenu(),CloseCmd);
    
    if not(EnModeEntreeTranscript()) & not(enSetUp | enRetour | iconisationDeCassio.encours)
     then MyEnableItem(PartieMenu,SetUpCmd)
     else MyDisableItem(PartieMenu,SetUpCmd);
  
    if not(analyseRetrograde.enCours)
     then MyEnableItem(PartieMenu,TaperUnDiagrammeCmd)
     else MyDisableItem(PartieMenu,TaperUnDiagrammeCmd);
    
    MyCheckItem(ModeMenu,ReflSurTempsAdverseCmd,not(sansReflexionSurTempsAdverse));
    MyCheckItem(ModeMenu,BiblActiveCmd,avecBibl & bibliothequeLisible);
    MyCheckItem(ModeMenu,VarierOuverturesCmd,gEntrainementOuvertures.CassioVarieSesCoups & (GetCadence() <= gEntrainementOuvertures.varierJusquaCetteCadence));
    if (GetCadence() <= minutes5) & not(enSetUp | enRetour | iconisationDeCassio.encours)
      then MyEnableItem(ModeMenu,VarierOuverturesCmd)
      else MyDisableItem(ModeMenu,VarierOuverturesCmd);
    MyCheckItem(JoueursMenu,HumCreHumCmd,HumCtreHum);
    if couleurMacintosh = pionBlanc 
      then
        begin
          MyCheckItem(JoueursMenu,MacBlancsCmd,true);
          MyCheckItem(JoueursMenu,MacNoirsCmd,false);
        end
      else
        begin
          MyCheckItem(JoueursMenu,MacBlancsCmd,false);
          MyCheckItem(JoueursMenu,MacNoirsCmd,true);
        end;
        
    MyCheckItem(AffichageMenu,ReflexionsCmd,affichageReflexion.doitAfficher);
    MyCheckItem(AffichageMenu,RapportCmd,windowRapportOpen);
    MyCheckItem(AffichageMenu,GestionTempsCmd,afficheGestionTemps);
    MyCheckItem(AffichageMenu,CommentairesCmd,arbreDeJeu.windowOpen);
    MyCheckItem(AffichageMenu,CourbeCmd,windowCourbeOpen);
    MyCheckItem(AffichageMenu,PaletteFlottanteCmd,windowPaletteOpen);
    MyCheckItem(EditionMenu,RaccourcisCmd,windowAideOpen);
    MyCheckItem(AffichageMenu,SonCmd,avecSon);
    if not(positionfeerique) {& (nroDernierCoupAtteint >= 1)} then
      begin
        if (nroDernierCoupAtteint >= 1)
          then coupUn := GetNiemeCoupPartieCourante(1)
          else coupUn := GetPremierCoupParDefaut();
        if coupUn<>DernierCoupPourMenuAff then
          begin
            case CoupUn of
              56:begin
                   SetMenuItemText(AffichageMenu,Symetrie_A8_H1Cmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,7),'F5-->E6','','',''));
                   SetMenuItemText(AffichageMenu,Symetrie_A1_H8Cmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,7),'F5-->D3','','',''));
                   SetMenuItemText(AffichageMenu,DemiTourCmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,8),'F5-->C4','','',''));
                 end;
              65:begin
                   SetMenuItemText(AffichageMenu,Symetrie_A8_H1Cmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,7),'E6-->F5','','',''));
                   SetMenuItemText(AffichageMenu,Symetrie_A1_H8Cmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,7),'E6-->C4','','',''));
                   SetMenuItemText(AffichageMenu,DemiTourCmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,8),'E6-->D3','','',''));
                 end;
              43:begin
                   SetMenuItemText(AffichageMenu,Symetrie_A8_H1Cmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,7),'C4-->D3','','',''));
                   SetMenuItemText(AffichageMenu,Symetrie_A1_H8Cmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,7),'C4-->E6','','',''));
                   SetMenuItemText(AffichageMenu,DemiTourCmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,8),'C4-->F5','','',''));
                 end;
              34:begin
                   SetMenuItemText(AffichageMenu,Symetrie_A8_H1Cmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,7),'D3-->C4','','',''));
                   SetMenuItemText(AffichageMenu,Symetrie_A1_H8Cmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,7),'D3-->F5','','',''));
                   SetMenuItemText(AffichageMenu,DemiTourCmd,
                           ParamStr(ReadStringFromRessource(MenusChangeantsID,8),'D3-->E6','','',''));
                 end;
            end;
            DernierCoupPourMenuAff := coupUn;
          end;
      end;
    
    
    if {windowListeOpen & }not(positionFeerique) & gameOver & not(enSetUp | enRetour | iconisationDeCassio.encours)
      then EnableItemPourCassio(BaseMenu,AjouterPartieDansListeCmd);
    MyCheckItem(BaseMenu,StatistiqueCmd,windowStatOpen);
    MyCheckItem(BaseMenu,ListePartiesCmd,windowListeOpen);
    MyCheckItem(BaseMenu,SousSelectionActiveCmd,sousSelectionActive);
    MyCheckItem(BaseMenu,InterversionCmd,avecInterversions);
    MyCheckItem(BaseMenu,AlerteInterversionCmd,avecAlerteNouvInterversion);

         
    for i := VertCmd to AutreCouleurCmd do
      MyCheckItem(CouleurMenu,i,gEcranCouleur & (gCouleurOthellier.menuID = CouleurID) & (gCouleurOthellier.menuCmd = i));
      
    for i := 1 to MyCountMenuItems(Picture2DMenu) do
      MyCheckItem(Picture2DMenu,i,(gCouleurOthellier.menuID = Picture2DID) & (gCouleurOthellier.menuCmd = i)); 
    
    for i := 1 to MyCountMenuItems(Picture3DMenu) do
      MyCheckItem(Picture3DMenu,i,(gCouleurOthellier.menuID = Picture3DID) & (gCouleurOthellier.menuCmd = i)); 
      
    MyCheckItem(TriMenu,TriParDatabaseCmd,    (gGenreDeTriListe=TriParDistribution));
    MyCheckItem(TriMenu,TriParDateCmd,        (gGenreDeTriListe=TriParDate));
    MyCheckItem(TriMenu,TriParJoueurNoirCmd,  (gGenreDeTriListe=TriParJoueurNoir));
    MyCheckItem(TriMenu,TriParJoueurBlancCmd, (gGenreDeTriListe=TriParJoueurBlanc));
    MyCheckItem(TriMenu,TriParOuvertureCmd,   (gGenreDeTriListe=TriParOuverture));
    MyCheckItem(TriMenu,TriParTheoriqueCmd,   (gGenreDeTriListe=TriParScoreTheorique));
    MyCheckItem(TriMenu,TriParReelCmd,        (gGenreDeTriListe=TriParScoreReel));

    if avecProgrammation then
      begin
        MyCheckItem(ProgrammationMenu,effetspecial1Cmd,GetEffetSpecial());
        MyCheckItem(ProgrammationMenu,effetspecial2Cmd,effetspecial2);
        MyCheckItem(ProgrammationMenu,DemoCmd,demo);
        MyCheckItem(ProgrammationMenu,EcrireDansRapportLogCmd,GetEcritToutDansRapportLog());
        MyCheckItem(ProgrammationMenu,UtiliserNouvelleEvalCmd,utilisationNouvelleEval);
        MyCheckItem(ProgrammationMenu,TraitementDeTexteCmd,EnTraitementDeTexte);
        MyCheckItem(ProgrammationMenu,ArrondirEvaluationsCmd,utilisateurVeutDiscretiserEvaluation);
        MyCheckItem(ProgrammationMenu,UtiliserScoresArbreCmd,not(seMefierDesScoresDeLArbre));
        
        if HumCtreHum & (interruptionReflexion = pasdinterruption) & (nbPartiesActives>0) & not(enSetUp | enRetour | iconisationDeCassio.encours)
          then MyEnableItem(ProgrammationMenu,ChercherSolitairesListeCmd)
          else MyDisableItem(ProgrammationMenu,ChercherSolitairesListeCmd);
      end;
  end;


function NomLongDejaCalculeDansMenuReouvrir(path : str255; var theLongName : str255) : boolean;
var k : SInt32;
begin

  for k := 1 to NbMaxItemsReouvrirMenu do
    if (nomDuFichierAReouvrir[k] <> NIL) & 
       (nomLongDuFichierAReouvrir[k] <> NIL) &
       (nomDuFichierAReouvrir[k]^^ = path) then
      begin
        theLongName := nomLongDuFichierAReouvrir[k]^^;
        NomLongDejaCalculeDansMenuReouvrir := true;
        exit(NomLongDejaCalculeDansMenuReouvrir);
      end;
      
  NomLongDejaCalculeDansMenuReouvrir := false;
end;

  
procedure SetReouvrirItem(pathFichier : str255;numeroItem : SInt16);
var NbItemsDansMenu,k : SInt16; 
    nomFichier,aux : str255;
    nomLongDuFichier : str255;
begin
  if (numeroItem>=1) & (numeroItem<=NbMaxItemsReouvrirMenu) &
     (nomDuFichierAReouvrir[numeroItem] <> NIL) then
    begin
    
      nomFichier := pathFichier;
	    while Pos(':',nomFichier) <> 0 do
	      nomFichier := TPCopy(nomfichier,Pos(':',nomFichier)+1,Length(nomFichier)-Pos(':',nomFichier));
	      
	    
	    nomLongDuFichier := nomFichier;
	    
	    
	    if EstUnNomDeFichierTronquePourPanther(nomFichier) 
	       & not(NomLongDejaCalculeDansMenuReouvrir(pathFichier,nomLongDuFichier)) 
	       & (PathCompletToLongName(pathFichier,aux) = NoErr)
	      then nomLongDuFichier := aux;
	    
	    
	    if (nomDuFichierAReouvrir[numeroItem] <> NIL)     then nomDuFichierAReouvrir[numeroItem]^^     := pathFichier;
	    if (nomLongDuFichierAReouvrir[numeroItem] <> NIL) then nomLongDuFichierAReouvrir[numeroItem]^^ := nomLongDuFichier;
	    
	    
	    NbItemsDansMenu := MyCountMenuItems(ReouvrirMenu);
	    if NbItemsDansMenu < numeroItem then
	      for k := NbItemsDansMenu+1 to numeroItem do
	        InsertMenuItem(ReouvrirMenu,'vide',k);
	        
	    if (nomFichier = '')
	      then
	        begin
	          SetMenuItemText(ReouvrirMenu,numeroItem,'vide');
	          MyDisableItem(ReouvrirMenu,numeroItem);
	        end
	      else
	        begin
	          SetMenuItemText(ReouvrirMenu,numeroItem,nomLongDuFichier); 
	          MyEnableItem(ReouvrirMenu,numeroItem);
	          MyEnableItem(GetFileMenu(),ReouvrirCmd);
	        end;
	   end;
end;
  
function GetNomCompletFichierDansMenuReouvrir(numeroItem : SInt16) : str255;
var k,compteur : SInt16; 
    result : str255;
begin
  result := '';
  compteur := 0;
  for k := 1 to NbMaxItemsReouvrirMenu do
    if (nomDuFichierAReouvrir[k] <> NIL) & (nomDuFichierAReouvrir[k]^^ <> '') then
      begin
        inc(compteur);
        if (compteur = numeroItem) then result := nomDuFichierAReouvrir[k]^^;
      end;
  GetNomCompletFichierDansMenuReouvrir := result;
end;


procedure CleanReouvrirMenu;
var k : SInt32;
begin
  for k := NbMaxItemsReouvrirMenu downto 1 do
    if (nomDuFichierAReouvrir[k] <> NIL) & (nomDuFichierAReouvrir[k]^^ = '')
      then DeleteMenuItem(ReouvrirMenu,k);
end;
  
  
procedure AjoutePartieDansMenuReouvrir(CheminEtNomFichier : str255);
var k,i : SInt16; 
    PlusDePlaceDansMenu : boolean;
    s : str255;
  begin
    if (CheminEtNomFichier = '') | EstUnNomDeFichierTemporaireDePressePapier(CheminEtNomFichier)
      then exit(AjoutePartieDansMenuReouvrir);
    
    {si la partie est deja dans le menu, on la met en tete}
    for i := 1 to NbMaxItemsReouvrirMenu do
      if (nomDuFichierAReouvrir[i] <> NIL) & (nomDuFichierAReouvrir[i]^^=CheminEtNomFichier) then
        begin
          {on decale tout vers le bas jusqu'a i}
          for k := i-1 downto 1 do
            begin
              if (nomDuFichierAReouvrir[k] <> NIL) 
                then s := nomDuFichierAReouvrir[k]^^
                else s := '';
              SetReouvrirItem(s,k+1);
            end;
          SetReouvrirItem(CheminEtNomFichier,1);
          CleanReouvrirMenu;
          exit(AjoutePartieDansMenuReouvrir);
        end;
    
    {reste-t-il de la place ?}
    PlusDePlaceDansMenu := true;
    for k := 1 to NbMaxItemsReouvrirMenu do
      if (nomDuFichierAReouvrir[k] <> NIL) & (nomDuFichierAReouvrir[k]^^='') then 
        PlusDePlaceDansMenu := false;
    
    if PlusDePlaceDansMenu 
      then  {on ecrase le premier en FIFO }
        begin
          for k := NbMaxItemsReouvrirMenu-1 downto 1 do
            begin
              if nomDuFichierAReouvrir[k] <> NIL
                then s := nomDuFichierAReouvrir[k]^^
                else s := '';
              SetReouvrirItem(s,k+1);
            end;
          SetReouvrirItem(CheminEtNomFichier,1);
        end
      else  {on rajoute au debut en decalant tout vers le bas}
        begin  
          for k := NbMaxItemsReouvrirMenu-1 downto 1 do
            begin
              if (nomDuFichierAReouvrir[k] <> NIL) 
                then s := nomDuFichierAReouvrir[k]^^
                else s := '';
              SetReouvrirItem(s,k+1);
            end;
          SetReouvrirItem(CheminEtNomFichier,1);
        end;
    
    CleanReouvrirMenu;
  end;
  
  
  
  
procedure SetMenusChangeant(modifiers : SInt16);
var option,command,shift,control : boolean;
  begin
    shift := BAND(modifiers,shiftKey) <> 0;
    command := BAND(modifiers,cmdKey) <> 0;
    option := BAND(modifiers,optionKey) <> 0;
    control := BAND(modifiers,controlKey) <> 0;
    
    if option
      then
        begin
          SetMenuItemText(GetFileMenu(),CloseCmd,ReadStringFromRessource(MenusChangeantsID,2));
          SetMenuItemText(GetFileMenu(),EnregistrerPartieCmd,ReadStringFromRessource(MenusChangeantsID,34));
          SetMenuItemText(JoueursMenu,MinuteNoirCmd,ReadStringFromRessource(MenusChangeantsID,4));
          SetMenuItemText(JoueursMenu,MinuteBlancCmd,ReadStringFromRessource(MenusChangeantsID,6));
          SetMenuItemText(SolitairesMenu,JouerNouveauSolitaireCmd,ReadStringFromRessource(MenusChangeantsID,10));
          SetMenuItemText(SolitairesMenu,EcrireSolutionSolitaireCmd,ReadStringFromRessource(MenusChangeantsID,20)); 
          SetMenuItemText(BaseMenu,SousSelectionActiveCmd,ReadStringFromRessource(MenusChangeantsID,12)); 
        end
      else
        begin
          SetMenuItemText(GetFileMenu(),CloseCmd,ReadStringFromRessource(MenusChangeantsID,1));
          SetMenuItemText(GetFileMenu(),EnregistrerPartieCmd,ReadStringFromRessource(MenusChangeantsID,33));
          SetMenuItemText(JoueursMenu,MinuteNoirCmd,ReadStringFromRessource(MenusChangeantsID,3));
          SetMenuItemText(JoueursMenu,MinuteBlancCmd,ReadStringFromRessource(MenusChangeantsID,5));
          SetMenuItemText(SolitairesMenu,JouerNouveauSolitaireCmd,ReadStringFromRessource(MenusChangeantsID,9));
          SetMenuItemText(SolitairesMenu,EcrireSolutionSolitaireCmd,ReadStringFromRessource(MenusChangeantsID,19)); 
          SetMenuItemText(BaseMenu,SousSelectionActiveCmd,ReadStringFromRessource(MenusChangeantsID,11));
        end;
    
    if CassioEstEn3D()
      then SetMenuItemText(AffichageMenu,ChangerEn3DCmd,ReadStringFromRessource(MenusChangeantsID,32))
      else SetMenuItemText(AffichageMenu,ChangerEn3DCmd,ReadStringFromRessource(MenusChangeantsID,31));
  end;
  
  
procedure BeginHiliteMenu(menuID : SInt16);
  begin
    HiliteMenu(menuID);
  end;


procedure EndHiliteMenu(tickDepart : SInt32;delai : SInt32;sansAttente : boolean);  
  begin
    if not(sansAttente) then 
      begin
        while (TickCount() < (tickDepart+delai)) do
          begin
            MySystemTask;
            if EventAvail(everyEvent,theEvent) then;
          end;
      end;
    HiliteMenu(0);
  end;


procedure DisableTitlesOfMenusForRetour;
  begin
    {AlerteSimple('appel de DisableTitlesOfMenusForRetour');}
  end;

procedure EnableAllTitlesOfMenus;
  begin
    {AlerteSimple('appel de EnableAllTitlesOfMenus');}
  end;
  
end.
