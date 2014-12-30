UNIT  UnitPrint;

INTERFACE







USES UnitNewGeneral,UnitListe,UnitDiagramFforum,UnitCarbonisation;


CONST kPasAssezDeMemoireError=10000;
      kNoPrinterError=10001;


{Initialisation de l'unite}
function AlloueMemoireImpression() : OSErr;
function ImpressionEstPossible() : boolean;
procedure LibereMemoireUnitPrint;

{session}
function OuvreSessionImpression() : boolean;
procedure FermeSessionImpression;
procedure ValiderEnregistrementImpression;
function UtilisateurAccepteDialogueImpression(jobTitle: str255) : boolean;

{document}
procedure OuvrirDocumentDansSessionImpression;
procedure FermerDocumentDansSessionImpression;
procedure OuvrirPageDansSessionImpression;
procedure FermerPageDansSessionImpression;

{fonction d'acces}
function GetPrintingPageRect() : rect;
function GetPrintingPaperRect() : rect;
function GetPrintingFirstPage() : SInt32;
function GetPrintingLastPage() : SInt32;
function GetPrintingCopyNumber() : SInt32;
function MethodeDImpressionEstDifferee() : boolean;
function ErreurImpression() : OSStatus;

{fonctions externes}
function DoDialogueImpression() : boolean;
function FiltreApercuAvantImpression(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
procedure DoDialogueFormatImpression;
procedure DoDialogueApercuAvantImpression;
procedure DoProcessPrinting(usePrintDialog: boolean);


{fonction de Cassio}
procedure DrawTitre(pageNum : SInt32);
procedure EffaceTitre(pageNum : SInt32);
procedure DrawPage(pageNum : SInt32;impressionEcran : boolean;PageEcranPtr:rectPtr);
function CountPages(): SInt32;
function TitreDocImpression() : str255;


IMPLEMENTATION








USES UnitBibl,PMCore,UnitCarbonisation,CarbonPrinting,Printing,UnitUtilitaires,UnitOth1,UnitJaponais,
     UnitStatistiques,UnitMenus,UnitDialog,SNStrings,UnitRapport,UnitCouleur,UnitFenetres;


{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
var g_CassioPrintingOK : boolean;
{$ELSEC }
var g_CassioPrintHdl  : THPrint;           { enregistrement d'impression }
    g_CassioPrintPort : TPPrPort;          { port d'impression }
{$ENDC}


function AlloueMemoireImpression() : OSErr;
var error : OSErr;
begin
  error := NoErr;
  
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  error := InitializePrintingSupport();
  g_CassioPrintingOK := (error = NoErr);
{$ELSEC}
  g_CassioPrintHdl := NIL;
  g_CassioPrintHdl := THPrint(AllocateMemoryHdl(SizeOf(TPrint)));
  if g_CassioPrintHdl = NIL 
    then
      begin
        SysBeep(0);
        WriteStringAt('pas assez de mémoire pour allouer g_CassioPrintHdl',10,40);
        AttendFrappeClavier;
        error := kPasAssezDeMemoireError;
      end
    else
      begin
        if OuvreSessionImpression() then
          begin
		        error := PrError();
		        if error<>NoErr then error := kNoPrinterError;
		        PrintDefault(g_CassioPrintHdl);
          end;
        FermeSessionImpression;
      end;  
{$ENDC}

  
  
  AlloueMemoireImpression := error;
end;

procedure ValiderEnregistrementImpression;
var result : boolean;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }

  {FIXME => est-ce que l'appel suivant a PMSessionValidatePageFormat est correct ? !!!}  
  if PMSessionValidatePageFormat(g_PrintSession, g_PageFormat, @result) = NoErr then;
  
{$ELSEC }
  {$UNUSED result}
  if PrValidate(g_CassioPrintHdl) then;
{$ENDC}
end;

function UtilisateurAccepteDialogueImpression(jobTitle: str255) : boolean;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  UtilisateurAccepteDialogueImpression := HandlePrintWindow(g_PrintSettings,jobTitle);
{$ELSEC }
  {$UNUSED jobTitle}
  UtilisateurAccepteDialogueImpression := PrJobDialog(g_CassioPrintHdl);
{$ENDC}
end;


function ImpressionEstPossible() : boolean;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  ImpressionEstPossible := g_CassioPrintingOK;
{$ELSEC }
  ImpressionEstPossible := (g_CassioPrintHdl <> NIL);
{$ENDC}
end;

function EnregistrementImpressionEstCorrect() : boolean;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  EnregistrementImpressionEstCorrect := g_CassioPrintingOK;
{$ELSEC }
  EnregistrementImpressionEstCorrect := (g_CassioPrintHdl <> NIL);
{$ENDC}
end;

procedure LibereMemoireUnitPrint;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  if (PMRelease(PMObject(g_PrintSession)) = NoErr) then;
  if (PMRelease(PMObject(g_PageFormat)) = NoErr) then;
  if (PMRelease(PMObject(g_PrintSettings)) = NoErr) then;
  g_CassioPrintingOK := false;
{$ELSEC}
  if g_CassioPrintHdl <> NIL then DisposeMemoryHdl(Handle(g_CassioPrintHdl));
  g_CassioPrintHdl := NIL;
{$ENDC}
end;

procedure DoDialogueFormatImpression;
begin
  if EnregistrementImpressionEstCorrect() then
    begin
      InitCursor;
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
      if OuvreSessionImpression() & HandlePageSetup() then ;
      FermeSessionImpression; 
{$ELSEC}
      if OuvreSessionImpression() then                   { Ouverture de la session }
        begin
          ValiderEnregistrementImpression;               { Validation des parametres d'impressions}
          if PrStlDialog(g_CassioPrintHdl) then;         { Utilisation du Page Set Dialog }
        end;
      FermeSessionImpression;                            { Fermeture de la session }
{$ENDC}
      DejaFormatImpression := true;
      AjusteCurseur;
    end;
end;

procedure DrawTitre(pageNum : SInt32);
var PageRect : rect;
    yPosition : SInt32;
    s : str255;
begin
  pageRect := GetPrintingPageRect();  
  with pageRect,PageImpr do
    begin
      TextSize(FontSizeTitre);
      TextFace(bold);
      TextFont(gCassioApplicationFont);
      s := titreImpression^^;
      yPosition := MargeTitre-((MargeTitre-FontSizeTitre) div 2);
      Moveto(left+(right-left-StringWidth(s)) div 2,yPosition);
      DrawString(s);
      if NumeroterPagesImpr then
        begin
          TextFace(normal);
          TextSize(9);
          NumToString(pageNum,s);
          Moveto(right-35,yPosition);
          DrawString(ParamStr(ReadStringFromRessource(TextesImpressionID,5),s,'','',''));
        end;
    end;
end;

procedure EffaceTitre(pageNum : SInt32);
var pageRect,unRect : rect;
begin
  {$UNUSED pageNum}
  
  pageRect := GetPrintingPageRect();  
  unRect := pageRect;
  unRect.bottom := PageImpr.MargeTitre;
  EraseRect(unRect);
  PenPat(grayPattern);
  PenSize(1,1);
  FrameRect(pagerect);
  PenNormal;
end;


procedure DrawPage(pageNum : SInt32;impressionEcran : boolean;PageEcranPtr:rectPtr);
var PageRect : rect;
    nbUnitesParPage : SInt32;
    UniteDebut,uniteFin : SInt32;
    UniteH,UniteV : SInt32;
    i,j,nroPartie : SInt32;
    intervaleH,IntervaleV : SInt32;
    PositionEtCoupStr:str185;
    chainePositionInitiale,chaineCoups : str255;
    chainePosition : str255;
    tempoCommentPosition,tempoTitre:str120;
    pagePicture:PicHandle;
    oldclipRgn : RgnHandle;
    oldPort : grafPtr;
    tempoStat : boolean;

  procedure OuvreImageReduite;
  begin
    oldClipRgn := NewRgn();
    Getclip(oldClipRgn);
    ClipRect(PageRect);
    pagePicture := OpenPicture(PageRect);
  end;
  
  procedure FermeImageReduite;
  begin
    ClosePicture;
    SetClip(oldclipRgn);
    DisposeRgn(oldclipRgn);
    DrawPicture(pagePicture,PageEcranPtr^);   
    KillPicture(pagePicture);
  end;
  
  
begin
  
  GetPort(oldPort);
  
  pageRect := GetPrintingPageRect(); 
  
  
  if impressionEcran then OuvreImageReduite;
  DrawTitre(pagenum);
  if impressionEcran then FermeImageReduite;
  
  
  Case PageImpr.QuoiImprimer of
    ImprimerPosition:     with pageRect,ParamDiagCourant do
                            begin
                              typeDiagrammeFFORUM := DiagrammePosition;
                              
                              decalageHorFFORUM := (right-left-LargeurDiagrammeFFORUM()) div 2;
                              decalageVertFFORUM := PageImpr.margeTitre+100+(bottom-top-PageImpr.margeTitre-HauteurDiagrammeFFORUM()-100) div 2;
                              if decalageHorFFORUM<0 then decalageHorFFORUM := 0;
                              if decalageVertFFORUM<PageImpr.margeTitre then decalageVertFFORUM := PageImpr.margeTitre;
                              if decalageVertFFORUM>100 then decalageVertFFORUM := 100;
                              
                              ConstruitPositionEtCoupDapresPartie(PositionEtCoupStr);
                              ParserPositionEtCoupsOthello8x8(PositionEtCoupStr,chainePositionInitiale,chaineCoups);
                              chainePosition := ConstruitChainePosition8x8(jeuCourant);
                              
                              if impressionEcran then OuvreImageReduite;
                              ConstruitPositionPicture(chainePosition,chaineCoups);
                              if DessinePierresDeltaFFORUM then ConstruitPicturePionsDeltaCourants;
                              if impressionEcran then FermeImageReduite;
                              
                            end;
                            
    ImprimerDiagramme:    with pageRect,ParamDiagCourant do
                            begin
                              typeDiagrammeFFORUM := DiagrammePartie;
                            
                              decalageHorFFORUM := (right-left-LargeurDiagrammeFFORUM()) div 2;
                              decalageVertFFORUM := PageImpr.margeTitre+100+(bottom-top-PageImpr.margeTitre-HauteurDiagrammeFFORUM()-100) div 2;
                              if decalageHorFFORUM<0 then decalageHorFFORUM := 0;
                              if decalageVertFFORUM<PageImpr.margeTitre then decalageVertFFORUM := PageImpr.margeTitre;
                              if decalageVertFFORUM>100 then decalageVertFFORUM := 100;
                              
                              ConstruitPositionEtCoupDapresPartie(PositionEtCoupStr);
                              ParserPositionEtCoupsOthello8x8(PositionEtCoupStr,chainePositionInitiale,chaineCoups);
                            
                              if impressionEcran then OuvreImageReduite;
                              ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
                              if DessinePierresDeltaFFORUM then ConstruitPicturePionsDeltaCourants;
                              if impressionEcran then FermeImageReduite;
                            end;
    ImprimerStatistiques: begin
                            if impressionEcran then OuvreImageReduite;
                            tempoStat := StatistiquesSontEcritesDansLaFenetreNormale();
                            SetStatistiquesSontEcritesDansLaFenetreNormale(false);
                            
                            DessineRubanStatistiques(20,PageImpr.margeTitre+50);
                            DessineStatistiques(false,20,PageImpr.margeTitre+50,false);
                            
                            SetStatistiquesSontEcritesDansLaFenetreNormale(tempoStat);
                            if impressionEcran then FermeImageReduite;
                          end;
    ImprimerListe:       with pageRect do
                          begin
                            
                            ParamDiagCourant.typeDiagrammeFFORUM := DiagrammePourListe;
                            
                            UniteH := (right-left) div LargeurDiagrammeFFORUM();
                            UniteV := (bottom-top-PageImpr.margeTitre) div HauteurDiagrammeFFORUM();
                            nbUnitesParPage := UniteH*UniteV;
                            UniteDebut := (PageNum-1)*nbUnitesParPage +1;
                            intervaleH := (right-left-uniteH*LargeurDiagrammeFFORUM()) div (uniteH +1);
                            IntervaleV := (bottom-top-PageImpr.margeTitre -UniteV*HauteurDiagrammeFFORUM()) div (uniteV+1);
                            
                            tempoTitre := ParamDiagCourant.TitreFFORUM^^;
                            tempoCommentPosition := ParamDiagCourant.CommentPositionFFORUM^^;
                            for j := 1 to UniteV do
                              for i := 1 to UniteH do
                                begin
                                  nroPartie := UniteDebut+(i-1)+(j-1)*UniteH;
                                  if (1<=nroPartie) and (nroPartie<=nbPartiesActives) then
                                    if not(EscapeDansQueue() and not(impressionEcran)) then
                                    begin
                                      ParamDiagCourant.decalageHorFFORUM := intervaleH+(i-1)*(intervaleH+LargeurDiagrammeFFORUM());
                                      ParamDiagCourant.decalageVertFFORUM := PageImpr.margeTitre+intervaleV+(j-1)*(intervaleV+HauteurDiagrammeFFORUM());
                                      ConstruitPositionEtCoupDapresListe(nroPartie,PositionEtCoupStr);
                                      ParserPositionEtCoupsOthello8x8(PositionEtCoupStr,chainePositionInitiale,chaineCoups);
                                      EssayerConstruireTitreDapresListe(nroPartie);
                                       
                                      if impressionEcran then OuvreImageReduite;
                                      ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
                                      {if DessinePierresDeltaFFORUM then ConstruitPicturePionsDeltaCourants;}
                                      {ConstruitRectangleTaillePicture;}
                                      if impressionEcran then FermeImageReduite;
                                    end;
                                end;
                            ParamDiagCourant.TitreFFORUM^^ := tempoTitre;
                            ParamDiagCourant.CommentPositionFFORUM^^ := tempoCommentPosition;
                            
                          end;
    ImprimerNotation:   with pageRect do
                          begin
                            TextFace(normal);
                            TextSize(9);
                            ParamDiagCourant.typeDiagrammeFFORUM := DiagrammePartie;
                            UniteH := (right-left) div LargeurDiagrammeFFORUM();
                            UniteV := (bottom-top-PageImpr.margeTitre) div HauteurDiagrammeFFORUM();
                            nbUnitesParPage := UniteH*UniteV;
                            intervaleH := (right-left-uniteH*LargeurDiagrammeFFORUM()) div (uniteH +1);
                            IntervaleV := (bottom-top-PageImpr.margeTitre -UniteV*HauteurDiagrammeFFORUM()) div (uniteV+1);
                            ConstruitPositionEtCoupDapresPartie(PositionEtCoupStr);
                            ParserPositionEtCoupsOthello8x8(PositionEtCoupStr,chainePositionInitiale,chaineCoups);
                            for i := 1 to UniteH do
                              for j := 1 to UniteV do
                                begin
                                  ParamDiagCourant.decalageHorFFORUM := intervaleH+(i-1)*(intervaleH+LargeurDiagrammeFFORUM());
                                  ParamDiagCourant.decalageVertFFORUM := PageImpr.margeTitre+intervaleV+(j-1)*(intervaleV+HauteurDiagrammeFFORUM());
                                  
                                  if impressionEcran then OuvreImageReduite;
                                  ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
                                  if ParamDiagCourant.DessinePierresDeltaFFORUM then ConstruitPicturePionsDeltaCourants;
                                  if impressionEcran then FermeImageReduite;
                                end;
                          end;
    ImprimerBibliotheque: begin
                            TextFace(normal);
                            TextSize(9);
                            nbUnitesParPage := (pageRect.bottom-pageRect.top-PageImpr.margeTitre) div 12 -1;
                            UniteDebut := (PageNum-1)*nbUnitesParPage +1;
                            uniteFin  := PageNum*nbUnitesParPage;
                            
                            if impressionEcran then OuvreImageReduite;
                            DessineBibliotheque(UniteDebut,UniteFin,10,PageImpr.margeTitre);
                            if impressionEcran then FermeImageReduite;
                          end;
   end;
  SetPort(oldPort);
end;


function OuvreSessionImpression() : boolean;
begin
  {$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  OuvreSessionImpression := (PMCreateSession(g_PrintSession) = NoErr) & (ErreurImpression() = NoErr);
  {$ELSEC}
  PrOpen;
  OuvreSessionImpression := (ErreurImpression() = NoErr);
  {$ENDC}
end;


procedure FermeSessionImpression;
begin
  {$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  if (PMRelease(PMObject(g_PrintSession)) = NoErr) then;
  {$ELSEC}
  PrClose;
  {$ENDC}
end;

procedure OuvrirDocumentDansSessionImpression;
begin
  {$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  ReadyPrintingNoPageOpen(g_PrintSettings);
  {$ELSEC}
  g_CassioPrintPort := PrOpenDoc(g_CassioPrintHdl, NIL, NIL); 
  {$ENDC}
end;

procedure FermerDocumentDansSessionImpression;
begin
  {$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  if PrintingCloseDocument() then;
  {$ELSEC}
  PrCloseDoc(g_CassioPrintPort);      
  {$ENDC}
end;


procedure OuvrirPageDansSessionImpression;
var drawingRect : rect;
begin
  {$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  drawingRect := PrintingOpenNextPage();
  {$ELSEC}
  {$UNUSED drawingRect}
  PrOpenPage(g_CassioPrintPort, NIL);   
  {$ENDC}
end;

procedure FermerPageDansSessionImpression;
begin
  {$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  if PrintingClosePage() then;
  {$ELSEC}
  PrClosePage(g_CassioPrintPort);       
  {$ENDC}
end;



function GetPrintingPageRect() : rect;
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
var thePMRect:PMRect;
    result : rect;
begin
  if PMGetAdjustedPageRect(g_PageFormat,thePMRect) = NoErr then;
  result.left   := MyTrunc(thePMRect.left);
  result.top    := MyTrunc(thePMRect.top);
  result.right  := MyTrunc(thePMRect.right);
  result.bottom := MyTrunc(thePMRect.bottom);
  GetPrintingPageRect := result;
end;  
{$ELSEC }
begin
  GetPrintingPageRect := g_CassioPrintHdl^^.prInfo.rPage;
end;
{$ENDC }

function GetPrintingPaperRect() : rect;
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
var thePMRect:PMRect;
    result : rect;
begin
  if PMGetAdjustedPaperRect(g_PageFormat,thePMRect) = NoErr then;
  result.left   := MyTrunc(thePMRect.left);
  result.top    := MyTrunc(thePMRect.top);
  result.right  := MyTrunc(thePMRect.right);
  result.bottom := MyTrunc(thePMRect.bottom);
  GetPrintingPaperRect := result;
end;  
{$ELSEC }
begin
  GetPrintingPaperRect := g_CassioPrintHdl^^.rpaper;
end;
{$ENDC }


function GetPrintingFirstPage() : SInt32;
var first : UInt32;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  if (PMGetFirstPage(g_PrintSettings,first) = NoErr) 
    then GetPrintingFirstPage := first
    else GetPrintingFirstPage := 0;
{$ELSEC }
  {$UNUSED first}
  GetPrintingFirstPage := g_CassioPrintHdl^^.prJob.iFstPage;
{$ENDC }
end;

function GetPrintingLastPage() : SInt32;
var last : UInt32;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  if (PMGetLastPage(g_PrintSettings,last) = NoErr) 
    then GetPrintingLastPage := last
    else GetPrintingLastPage := -1;
{$ELSEC }
  {$UNUSED last}
  GetPrintingLastPage := g_CassioPrintHdl^^.prJob.iLstPage;
{$ENDC }
end;

function GetPrintingCopyNumber() : SInt32;
var copies : UInt32;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  if (PMGetCopies(g_PrintSettings,copies) = NoErr) 
    then GetPrintingCopyNumber := copies
    else GetPrintingCopyNumber := 0;
{$ELSEC }
  {$UNUSED copies}
  GetPrintingCopyNumber := g_CassioPrintHdl^^.prJob.iCopies;
{$ENDC }
end;

function MethodeDImpressionEstDifferee() : boolean;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  MethodeDImpressionEstDifferee := false;
{$ELSEC }
  MethodeDImpressionEstDifferee := g_CassioPrintHdl^^.prJob.bjDocLoop=bSpoolLoop;
{$ENDC }
end;


function ErreurImpression() : OSStatus;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  ErreurImpression := PMSessionError(g_PrintSession);
{$ELSEC }
  ErreurImpression := PrError();
{$ENDC }
end;


function CountPages(): SInt32;
var PageRect : rect;
    nbUnitesParPage : SInt32;
begin
  pageRect := GetPrintingPageRect();
   case PageImpr.QuoiImprimer of
    ImprimerPosition      : CountPages := 1;
    ImprimerDiagramme     : CountPages := 1;
    ImprimerStatistiques  : CountPages := 1;
    ImprimerListe         : begin
                              nbUnitesParPage := ((pageRect.right-pageRect.left)
                                                 div LargeurDiagrammeFFORUM())*
                                               ((pageRect.bottom-pageRect.top-PageImpr.margeTitre) 
                                                 div HauteurDiagrammeFFORUM());
                              if (nbPartiesActives mod nbUnitesParPage)=0
                                then CountPages := nbPartiesActives div nbUnitesParPage
                                else CountPages := nbPartiesActives div nbUnitesParPage+1;
                            end;
    ImprimerBibliotheque  : begin
                              nbUnitesParPage := (pageRect.bottom-pageRect.top-PageImpr.margeTitre) div 12 -1;
                              if (nbreLignesEnBibl mod nbUnitesParPage)=0
                                then CountPages := nbreLignesEnBibl div nbUnitesParPage
                                else CountPages := nbreLignesEnBibl div nbUnitesParPage+1;
                            end;
    ImprimerNotation      : CountPages := 1;
    otherwise CountPages := 1;
  end;
end;

function TitreDocImpression() : str255;
var s,s1 : str255;
begin
  case PageImpr.QuoiImprimer of
    ImprimerPosition      : s := ReadStringFromRessource(TextesImpressionID,7);
    ImprimerDiagramme     : s := ReadStringFromRessource(TextesImpressionID,8);
    ImprimerStatistiques  : s := ReadStringFromRessource(TextesImpressionID,9);
    ImprimerListe         : s := ReadStringFromRessource(TextesImpressionID,10);
    ImprimerBibliotheque  : s := ReadStringFromRessource(TextesImpressionID,11);
    ImprimerNotation      : s := ReadStringFromRessource(TextesImpressionID,12);
    otherwise               s := '^0';
  end;
  s1 := PageImpr.TitreImpression^^;
  TitreDocImpression := ParamStr(s,s1,'','','');
end;

function DoDialogueImpression() : boolean;
begin
  DoDialogueImpression := false;
  if EnregistrementImpressionEstCorrect() then
    begin
      if OuvreSessionImpression() then
        begin
		      ValiderEnregistrementImpression;                                 
		      DoDialogueImpression := UtilisateurAccepteDialogueImpression('Cassio');
        end;
      FermeSessionImpression;
    end;
end; 


procedure DoProcessPrinting(usePrintDialog: boolean);
  var
   curPort: GrafPtr;
   nbPages, page, firstPage, lastPage : SInt32;
   nbCopies {, copies}: SInt32;
   ImpressionAnnulee : boolean;
   titre : str255;
   fenetreImpression : WindowPtr;
   unRect : rect;
   oldParamDiag:ParamDiagRec;
{$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
   status:TPrStatus;
   statusPtr:TPPrStatus;
{$ENDC}

  procedure EcritIntervalePages;
  var oldport : grafPtr;
  begin
    GetPort(oldport);
    SetPortByWindow(fenetreImpression);
    WriteStringAndNumAt('firstPage=',firstPage,15,20);
    WriteStringAndNumAt('lastPage=',lastPage,15,40);
    SetPort(oldport);
  end;
  
  
begin {DoProcessPrinting}
  if EnregistrementImpressionEstCorrect() then
    begin
      {if not(DejaFormatImpression) then DoDialogueFormatImpression;}
      GetPort(curPort);           
      NewParamDiag(oldParamDiag);
      GetParamDiag(oldParamDiag);
      CopyCommentParamDiag(oldParamDiag,ParamDiagImpr);
      SetParamDiag(ParamDiagImpr);  
      if OuvreSessionImpression() then              { Ouverture de la session }  
        begin
		      ValiderEnregistrementImpression;                          
		      fenetreImpression := NIL;
		      titre := TitreDocImpression();
		      
		      impressionAnnulee := false;
		      if usePrintDialog 
		        then impressionAnnulee := not(UtilisateurAccepteDialogueImpression(titre));  
		        
		      if not(impressionAnnulee) then
		        begin
		          watch := GetCursor(watchcursor);
		          SafeSetCursor(watch);
		          unRect := GetScreenBounds();
		          InsetRect(unRect,(unRect.right-unRect.left-430) div 2,
		                           (unRect.bottom-unRect.top-80) div 2);
		          
		          fenetreImpression := NewCWindow(NIL,unRect,titre,true,1,FenetreFictiveAvantPlan(),false,0);
		          if fenetreImpression <> NIL then
		            begin
		              ShowWindow(fenetreImpression);
		              SetPortByWindow(fenetreImpression);
		              TextFont(systemFont);
		              TextSize(0);
		              Moveto(15,20);
		              DrawString(ParamStr(ReadStringFromRessource(TextesImpressionID,6),titre,'','',''));{'Impression de «titre»'}
		              Moveto(15,60);
		              DrawString(ReadStringFromRessource(TextesImpressionID,13));  {'Pour annuler, tapez Escape ou -point (.).'}
		            end;
		          
		          OuvrirDocumentDansSessionImpression;   { Ouverture du port d'impression }
		          if (ErreurImpression() = NoErr) then
		            begin
		            
		              { Attention : il semble qu'il faille *toujours* appeler la fonction GetPrintingCopyNumber(),
		                            meme si on n'utilise pas sa valeur ensuite, sinon BOUM }
		              nbCopies := GetPrintingCopyNumber();
		              {if gIsRunningUnderMacOSX then nbCopies := 1;}
		              
		            
		              firstPage := GetPrintingFirstPage();
		              lastPage := GetPrintingLastPage();
		              nbPages := CountPages();
		              if lastPage > nbPages then lastPage := nbPages;
		              
		              
		              {WritelnStringAndNumDansRapport('nbCopies = ',nbCopies);}
		              {WritelnStringAndNumDansRapport('nbPages = ',nbPages);}
		              
		              
		              (* for copies := 1 to nbCopies do *)
		                begin                                    { Impression de l'intervalle de page [firstPage..lastPage] }
		                  for page := 1 to nbPages do
		                    if (ErreurImpression() = NoErr) then
		                      begin
		                        OuvrirPageDansSessionImpression;   { Ouverture de la page courante }
		                        if (ErreurImpression() = NoErr) then
		                          if (page>=firstPage) and (page <= lastPage) and not(EscapeDansQueue())
		                            then DrawPage(page,false,NIL); { Impression du contenu de la page courante }
		                        FermerPageDansSessionImpression;   { Fermeture de la page courante }
		                      end;
		                end;
		            end;
		          FermerDocumentDansSessionImpression;  { Fermeture du port d'impression }
		                   
		          {$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
		            if (ErreurImpression() = NoErr ) & MethodeDImpressionEstDifferee() then  { Methode differee }
		                begin
		                  statusPtr := @status;
		                  {$IFC UNIVERSAL_INTERFACES_VERSION >= $0301 }
		                  PrPicFile(g_CassioPrintHdl,NIL,NIL,NIL,statusPtr);
		                  {$ELSEC }
		                  PrPicFile(g_CassioPrintHdl,NIL,NIL,NIL,status);
		                  {$ENDC }
		                end;
		          {$ENDC}
		           
		        end;   
		      if fenetreImpression <> NIL then DisposeWindow(fenetreImpression);
		      (** EcritResourceImpression; **)
        end;
      FermeSessionImpression;                       { Fermeture de la session }
      GetParamDiag(paramDiagImpr);
      SetParamDiag(oldParamDiag);
      DisposeParamDiag(oldParamDiag);
      SetPort(curPort);
      AjusteCurseur;
      FlushEvents(keyDown+autoKey,0);
  end;
end;

const ApercuImpressionID=144;
      impressionButton=1;
      FermerButton=2;
      ParametreButton=3;
      PositionActuelleRadio=5;  {=ImprimerPosition}
      DiagrammeRadio=6;         {=ImprimerDiagramme}
      StatistiquesRadio=7;      {=ImprimerStatistiques}
      ListePartiesRadio=8;      {=ImprimerListe}
      BibliothequeRadio=9;      {=ImprimerBibliotheque}
      NotationRadio=10;         {=ImprimerNotation}
      TitrePageText=11;
      FormatButton=13;
      NumeroPagesBox=14;
      NombrePagesStaticText=16;


function FiltreApercuAvantImpression(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
var ch,cmdChar : char;
begin
  FiltreApercuAvantImpression := false;
  if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(evt);
  if not(EvenementDuDialogue(dlog,evt))
    then FiltreApercuAvantImpression := MyFiltreClassique(dlog,evt,item)
    else 
      case evt.what of
        keyDown,autoKey:
        if (BAND(evt.modifiers,cmdKey) <> 0)
           then
             begin
               ch := chr(BAND(evt.message,charCodemask));
               if (ch='w') or (ch='W') then
                 begin
                   item := FermerButton;
                   FlashItem(dlog,item);
                   FiltreApercuAvantImpression := true;
                   exit(FiltreApercuAvantImpression);
                 end;
               GetItemCmd(EditionMenu,ParamPressePapiercmd,cmdChar);
               if ord(cmdchar)>0 then
               if (ch=cmdChar) or (ch=chr(ord(cmdChar)+32)) then
                 begin
                   item := ParametreButton;
                   FlashItem(dlog,item);
                   FiltreApercuAvantImpression := true;
                   exit(FiltreApercuAvantImpression);
                 end;
               GetItemCmd(GetFileMenu(),FormatImpressionCmd,cmdChar);
               if ord(cmdchar)>0 then
               if (ch=cmdChar) or (ch=chr(ord(cmdChar)+32)) then
                 begin
                   item := FormatButton;
                   FlashItem(dlog,item);
                   FiltreApercuAvantImpression := true;
                   exit(FiltreApercuAvantImpression);
                 end;
               GetItemCmd(GetFileMenu(),ImprimerCmd,cmdChar);
               if ord(cmdchar)>0 then
               if (ch=cmdChar) or (ch=chr(ord(cmdChar)+32)) then
                 begin
                   item := impressionButton;
                   FlashItem(dlog,item);
                   FiltreApercuAvantImpression := true;
                   exit(FiltreApercuAvantImpression);
                 end;
               FiltreApercuAvantImpression := MyFiltreClassique(dlog,evt,item);
             end
           else
             FiltreApercuAvantImpression := MyFiltreClassique(dlog,evt,item);
       updateEvt:
         begin
           item := VirtualUpdateItemInDialog;
           FiltreApercuAvantImpression := true;
         end;
       otherwise
         FiltreApercuAvantImpression := MyFiltreClassique(dlog,evt,item);
   end;  {case}
end;


procedure DoDialogueApercuAvantImpression;
const TitreSeulement=1;
      TouteLaPage=2;
var
 dp : DialogPtr;
 itemHit : SInt16; 
 FiltreApercuAvantImpressionUPP : ModalFilterUPP;
 err : OSErr;
 oldParamDiag:ParamDiagRec;
 tailleEcran : rect;
 dialogRect : rect;
 targetRect : rect;
 pagerect,PapierRect : rect;
 PageEcran,PapierEcran : rect;
 ZoneGrise : rect;
 rapportH,rapportV,rapportUtil : extended;
 margesZoneGrise : Point;
 s : str255;
 PositionEtCoupStr:str185;
 chainePositionInitiale,chainePosition,chaineCoups : str255;
 tempoCommentPosition,tempoTitre:str120;
 miseajour : boolean;
 
 procedure CalculerRectanglesPage;
  begin
    SetPortByDialog(dp);
    SetRect(ZoneGrise,150,35,QDGetPortBound().right-5,QDGetPortBound().bottom-5);
    margesZoneGrise.h := 10;
    margesZoneGrise.v := 6;
    pageRect := GetPrintingPageRect();
    papierRect := GetPrintingPaperRect();
    rapportH := (PapierRect.right-PapierRect.left)/(zoneGrise.right-zoneGrise.left-2*margesZoneGrise.h);
    rapportV := (PapierRect.bottom-PapierRect.top)/(zoneGrise.bottom-zoneGrise.top-2*margesZoneGrise.v);
    if rapportH>rapportV 
      then rapportUtil := rapportH
      else rapportUtil := rapportV;
    if rapportUtil<1.0 then rapportUtil := 1.0;
    PapierEcran := PapierRect;
    with PapierEcran do 
      begin
        right := RoundToL((right-left)/rapportUtil);
        bottom := RoundToL((bottom-top)/rapportUtil);
        left := 0;
        top := 0;
      end; 
    OffsetRect(PapierEcran,zonegrise.left+margesZoneGrise.h,
                           zoneGrise.top+margesZoneGrise.v);
    PageEcran := PageRect;
    MapRect(PageEcran,PapierRect,PapierEcran);
  end;

 procedure DessinePage(PageNumber,PartieDeLaPage : SInt32;fonctionAppelante : str255);
 var PagePicture:PicHandle;
     oldclipRgn : RgnHandle;
     taillePicture : SInt32;
     s : str255;
     oldPort : grafPtr;
     myRect : rect;
 begin  {$UNUSED fonctionAppelante}
   
   {TraceLog('DessinePage : fonction appelante = ' + fonctionAppelante);}
   
   GetPort(oldPort);
   SetPortDialogPort(dp);
   
   GetDialogItemRect(dp,NombrePagesStaticText,myRect);
   EraseRect(myRect);
   NumToString(CountPages(),s);
   s := ParamStr(ReadStringFromRessource(TextesImpressionID,4),s,'','','');
   SetItemTextInDialog(dp,NombrePagesStaticText,s);
   

   if PartieDeLaPage=TitreSeulement
     then 
       begin
         
         oldClipRgn := NewRgn();
         Getclip(oldClipRgn);
         ClipRect(Pagerect);
         
         pagePicture := OpenPicture(PageRect);
         EffaceTitre(pageNumber);
         DrawTitre(pageNumber);
         ClosePicture;
         
         SetClip(oldclipRgn);
         DisposeRgn(oldclipRgn);
         
         taillePicture := GetHandleSize(Handle(pagePicture));
         DrawPicture(pagePicture,PageEcran);   
         KillPicture(pagePicture);
         
       end
     else 
       begin
         if PageImpr.QuoiImprimer=ImprimerListe then 
           begin
             watch := GetCursor(watchcursor);
             SafeSetCursor(watch);
           end;
         DrawPage(pagenumber,true,rectPtr(Ptr(@pageEcran)));
       end;
	
       
   TextSize(12);
   TextFont(systemFont);
   TextFace(normal);
   
   InitCursor;
   {WriteStringAndNumAt('taille picture=',taillePicture,200,100);}
   SetPort(oldPort);
 end;
 
 procedure FrameRectInGray(theRect : rect);
 var myGray : RGBColor;
 begin
   if gHasColorQuickDraw
     then
       begin
         SetRGBColor(myGray,40000,40000,40000);
         RGBForeColor(myGray);
         PenPat(blackPattern);
         FrameRect(theRect);
         ForeColor(BlackColor);
       end
     else
       begin
         PenPat(grayPattern);
			   FrameRect(theRect);
			   PenPat(blackPattern);
       end;
 end;
 
 procedure FillRectInGray(theRect : rect);
 var myGray : RGBColor;
 begin
   if gHasColorQuickDraw
     then
       begin
         SetRGBColor(myGray,40000,40000,40000);
         RGBForeColor(myGray);
         FillRect(theRect,blackPattern);
         ForeColor(BlackColor);
       end
     else
       begin
         FillRect(theRect,grayPattern);
       end;
 end;

 
 procedure EffacePage;
 begin
   OffsetRect(PapierEcran,1,1);
   FrameRect(PapierEcran);
   OffsetRect(PapierEcran,-1,-1);
   FillRect(PapierEcran,whitePattern);
   FrameRectInGray(pageEcran);
   FrameRect(PapierEcran);
 end;
 
 procedure DessineZoneGrise;
 var unRect : rect;
 begin
   OutlineOK(dp);
   unRect := ZoneGrise;
   if PapierEcran.left>unRect.left then unRect.right := PapierEcran.left;
   FillRectInGray(unRect);
   unRect := ZoneGrise;
   if PapierEcran.right<unRect.right then unRect.left := PapierEcran.right;
   FillRectInGray(unRect);
   unRect := ZoneGrise;
   if PapierEcran.bottom<unRect.bottom then unRect.top := PapierEcran.bottom;
   FillRectInGray(unRect);
   unRect := ZoneGrise;
   if PapierEcran.top>unRect.top then unRect.bottom := PapierEcran.top;
   FillRectInGray(unRect);
   FrameRect(ZoneGrise);
   FrameRectInGray(pageEcran);
   FrameRect(PapierEcran);
   Moveto(PapierEcran.left+1,PapierEcran.bottom);
   Lineto(PapierEcran.right,PapierEcran.bottom);
   Lineto(PapierEcran.right,PapierEcran.top+1);
 end;
 
 procedure AjusteControles;
 begin
   SetBoolRadio(dp,PageImpr.QuoiImprimer,true);
   s := PageImpr.TitreImpression^^;
   SetItemTextInDialog(dp,TitrePageText,s);
   SetBoolCheckBox(dp,NumeroPagesBox, PageImpr.NumeroterPagesImpr);
 end;
 
 procedure SetHiliteStateControles;
 begin
   if (PageImpr.QuoiImprimer=ImprimerStatistiques) or 
      (PageImpr.QuoiImprimer=ImprimerBibliotheque) or
      ((PageImpr.QuoiImprimer=ImprimerListe) and (nbPartiesActives<=0))
     then HiliteControlInDialog(dp,ParametreButton,255)
     else HiliteControlInDialog(dp,ParametreButton,0);
 end;

 procedure RedessinePourUpdateEvent;
 begin
   SetPortByDialog(dp);
   if gIsRunningUnderMacOSX then EraseRect(MyGetPortBounds(GetDialogPort(dp)));
   MyDrawDialog(dp);
   DessineZoneGrise;
   DessinePage(1,TouteLaPage,'RedessinePourUpdateEvent');
 end;
 
begin  {DoDialogueApercuAvantImpression}
  if ImpressionEstPossible() then
    begin     
      NewParamDiag(oldParamDiag);
      GetParamDiag(oldParamDiag);
      CopyCommentParamDiag(oldParamDiag,ParamDiagImpr);
      SetParamDiag(ParamDiagImpr); 
      
      SwitchToScript(gLastScriptUsedInDialogs);
      BeginDialog;
      FiltreApercuAvantImpressionUPP := NewModalFilterUPP(@FiltreApercuAvantImpression);
      dp := MyGetNewDialog(ApercuImpressionID,FenetreFictiveAvantPlan());
      if dp <> NIL then
        begin
          tailleEcran := GetScreenBounds();
          
          if gIsRunningUnderMacOSX 
            then
              begin  {on centre la fenetre, et on s'assure qu'elle n'est pas trop grande}
                dialogRect := tailleEcran;
                with dialogRect do
                  begin
                    InSetRect(dialogRect,20,58);
                    if (right - left > 1000) then right := left + 1000;
                    if (bottom - top > 750) then bottom := top + 750;
                    targetRect := CenterRectInRect(dialogRect,tailleEcran);
                    SizeWindow(GetDialogWindow(dp),targetRect.right-targetRect.left,targetRect.bottom-targetRect.top,false);
                    MoveWindow(GetDialogWindow(dp),targetRect.left,targetRect.top,false);
                  end;
                
              end
            else
              begin
		            with tailleEcran do
		              SizeWindow(GetDialogWindow(dp),right-left-20,bottom-top-38,false);
		          end;
            
            
          ShowWindow(GetDialogWindow(dp));
          SelectWindow(GetDialogWindow(dp));
          
          
          
          SetPortByDialog(dp);
          CalculerRectanglesPage;
          if enRetour then PageImpr.QuoiImprimer := ImprimerDiagramme;
          AjusteControles;
          SetHiliteStateControles;
          RedessinePourUpdateEvent;
          ValidRect(QDGetPortBound());
          err := SetDialogTracksCursor(dp,true);
          repeat
            ModalDialog(FiltreApercuAvantImpressionUPP,itemHit);
            case itemHit of
              VirtualUpdateItemInDialog: begin
                                           BeginUpdate(GetDialogWindow(dp));
                                           RedessinePourUpdateEvent;
                                           EndUpdate(GetDialogWindow(dp));
                                         end;
              impressionButton:begin
                                 SetWTitle(GetDialogWindow(dp),TitreDocImpression());
                                 if DoDialogueImpression() then
                                   begin
                                     RedessinePourUpdateEvent;
                                     GetParamDiag(paramDiagImpr);
                                     DoProcessPrinting(false);
                                   end;
                               end;
              FormatButton:begin
                             DoDialogueFormatImpression;
                             CalculerRectanglesPage;
                             SetPortByDialog(dp);
                             MyDrawDialog(dp);
                             DessineZoneGrise;
                             EffacePage;
                             DessinePage(1,TouteLaPage,'DoDialogueApercuAvantImpression (FormatButton)');
                             ValidRect(QDGetPortBound());
                           end;
              FermerButton:;
              PositionActuelleRadio,
              DiagrammeRadio,
              StatistiquesRadio,
              ListePartiesRadio,
              BibliothequeRadio,
              NotationRadio   : if PageImpr.QuoiImprimer<>ItemHit then
                                   begin
                                     SetBoolRadio(dp,PageImpr.QuoiImprimer,false);
                                     PageImpr.QuoiImprimer := ItemHit;
                                     SetBoolRadio(dp,PageImpr.QuoiImprimer,true);
                                     SetHiliteStateControles;
                                     SetPortByDialog(dp);
                                     DessineZoneGrise;
                                     EffacePage;
                                     DessinePage(1,TouteLaPage,'DoDialogueApercuAvantImpression (NotationRadio)');
                                   end;
              ParametreButton:begin
                                if PageImpr.QuoiImprimer=ImprimerListe
                                  then
                                    begin
                                      tempoTitre := ParamDiagCourant.TitreFFORUM^^;
                                      tempoCommentPosition := ParamDiagCourant.CommentPositionFFORUM^^;
                                      ConstruitPositionEtCoupDapresListe(1,PositionEtCoupStr);
                                      EssayerConstruireTitreDapresListe(1);
                                      
                                      ParserPositionEtCoupsOthello8x8(positionEtCoupStr,chainePositionInitiale,chaineCoups);
		                                  chainePosition := ConstruitChainePosition8x8(jeuCourant);
                                      
                                      GetIndString(s,TextesImpressionID,2);
                                      miseajour := DoDiagrammeFFORUM(s,chainePositionInitiale,chainePosition,chaineCoups);
                                      ParamDiagCourant.TitreFFORUM^^ := tempoTitre;
                                      ParamDiagCourant.CommentPositionFFORUM^^ := tempoCommentPosition;
                                    end
                                  else
                                    begin
                                      ConstruitPositionEtCoupDapresPartie(PositionEtCoupStr);
                                      
                                      ParserPositionEtCoupsOthello8x8(positionEtCoupStr,chainePositionInitiale,chaineCoups);
		                                  chainePosition := ConstruitChainePosition8x8(jeuCourant);
		
                                      GetIndString(s,TextesImpressionID,2);
                                      miseajour := DoDiagrammeFFORUM(s,chainePositionInitiale,chainePosition,chaineCoups);
                                    end;
                                SetPortByDialog(dp);
                                MyDrawDialog(dp);
                                DessineZoneGrise;
                                if miseajour then EffacePage;
                                DessinePage(1,TouteLaPage,'DoDialogueApercuAvantImpression (ParametreButton)');
                                ValidRect(QDGetPortBound());
                              end;
              TitrePageText:begin
                              GetItemTextInDialog(dp,TitrePageText,s);
                              if PageImpr.TitreImpression^^<>s then
                                begin
                                  PageImpr.TitreImpression^^ := s;
                                  SetPortByDialog(dp);
                                  DessinePage(1,TitreSeulement,'DoDialogueApercuAvantImpression (TitrePageText)');
                                end;
                            end;
              NumeroPagesBox:begin
                               PageImpr.NumeroterPagesImpr := not(PageImpr.NumeroterPagesImpr);
                               SetBoolCheckBox(dp,NumeroPagesBox,PageImpr.NumeroterPagesImpr);
                               SetPortByDialog(dp);
                               DessinePage(1,TitreSeulement,'DoDialogueApercuAvantImpression (NumeroPagesBox)');
                             end;
            end; 

          until (itemHit=FermerButton);
          MyDisposeDialog(dp);
        end;
      GetParamDiag(paramDiagImpr);
      CopyCommentParamDiag(paramDiagImpr,oldParamDiag);
      SetParamDiag(oldParamDiag);
      DisposeParamDiag(oldParamDiag);
      MyDisposeModalFilterUPP(FiltreApercuAvantImpressionUPP);
      GetCurrentScript(gLastScriptUsedInDialogs);
      SwitchToRomanScript;
      EndDialog;
   end;
end; {DoDialogueApercuAvantImpression}

end.
