UNIT UnitFichierPhotos;



INTERFACE 







USES UnitOth0,UnitFichiersTEXT,UnitCalculCouleurCassio;



type 
  FichierPictureRec = 
       record
         typeFichier   : SInt16; 
         whichMenuID   : SInt16; 
         whichMenuItem : SInt16; 
         couleurPions  : SInt16; 
         nomComplet  : str255Ptr;
         nomDansMenu : str255Ptr;
       end;

const   
 {type des fichiers d'images d'othellier}
  kFichierPictureInconnu = 0;
  kFichierPicture2D      = 1;
  kFichierPicture3D      = 2;
  kFichierBordure        = 3;
  kFichierPictureMeteo   = 4;
  
 {couleurs possibles des pions de l'image}
  kAucuneEnParticulier = -8253;  {ou n'importe quelle valeur bizarre}
  kFichierCoordonees   = 1000;
  kImagePionsNoirs     = pionNoir;
  kImagePionsVides     = pionVide;
  kImagePionsBlancs    = pionBlanc;
  kImageCoupsLegaux    = pionMontreCoupLegal;
  kImagePionSuggestion = pionSuggestionDeCassio;
  
  
 {nbre max de fichiers de textures d'othellier}
  kMaxFichiersOthelliers = 100;

var 
  gFichiersPicture :
      record
        nbFichiers  : SInt16; 
        fic : array[0..kMaxFichiersOthelliers] of FichierPictureRec;
      end;


procedure InitUnitFichierPhotos;
procedure LibereMemoireUnitFichierPhotos;

function FichierPhotosExisteSurLeDisque(pathCompletFichierPhoto : str255; var fic : FichierTEXT) : boolean;
function FichierPhotosExisteEnMemoire(pathComplet : str255; var numeroFic : SInt16) : boolean;
function FichierPhotosExisteDansMenu(nomFichierDansMenu : str255; var numeroFic : SInt16) : boolean;


function GetPathCompletFichierPionsPourCetteTexture(var whichTexture:CouleurOthellierRec) : str255;
function GetPathCompletFichierBordurePourCetteTexture(var whichTexture:CouleurOthellierRec) : str255;
function GetNomDansMenuPourCetteTexture(var whichTexture:CouleurOthellierRec) : str255;
function LitFichierCoordoneesImages3D(var quelleTexture:CouleurOthellierRec) : OSErr;

function GetPathCompletFichierParNumero(numeroFic : SInt16) : str255;
function GetNomDansMenuParNumero(numeroFic : SInt16) : str255;


function PathFichierPicture3DDeCetteFamille(nomFichierDansMenu : str255;coul : SInt16) : str255;


procedure AlerteFichierPhotosNonTrouve(nomFichier : str255);

procedure AjouterFichierOthellierPicture(fs : FSSpec;typeFichierGraphique : SInt16);
procedure LecturePreparatoireDossierOthelliers(vRefNum : SInt16);

procedure TestUnitFichierPhotos;




IMPLEMENTATION







USES UnitRapport,UnitOth2,UnitTroisiemeDimension,UnitGeometrie,Unit3DPovRayPicts,UnitCarbonisation,SNStrings,
     MyFileSystemUtils,Aliases,UnitOth0,UnitMenus,UnitDialog,UnitScannerOthellistique,UnitCouleur,UnitFenetres;




procedure InitUnitFichierPhotos;
var i : SInt16; 
begin
  with gFichiersPicture do
    begin
      nbFichiers := 0;
      for i := 0 to kMaxFichiersOthelliers do
        with fic[i] do
		      begin
		        typeFichier   := kFichierPictureInconnu;
		        whichMenuID   := 0;
		        whichMenuItem := 0;
		        couleurPions  := kAucuneEnParticulier;
		        nomComplet  := NIL;
		        nomDansMenu := NIL;
		      end;
		end;
end;


procedure LibereMemoireUnitFichierPhotos;
var i : SInt16; 
begin
  with gFichiersPicture do
    begin
      nbFichiers := 0;
		  for i := 0 to kMaxFichiersOthelliers do
		    with fic[i] do
		      begin
		        typeFichier := kFichierPictureInconnu;
		        whichMenuID := 0;
		        whichMenuItem := 0;
		        couleurPions  := kAucuneEnParticulier;
		        if nomComplet <> NIL then 
		          begin
		            DisposeMemoryPtr(Ptr(nomComplet));
		            nomComplet := NIL;
		          end;
		        if nomDansMenu <> NIL then 
		          begin
		            DisposeMemoryPtr(Ptr(nomDansMenu));
		            nomDansMenu := NIL;
		          end;
		      end;
		end;
end;


function FichierPhotosExisteSurLeDisque(pathCompletFichierPhoto : str255; var fic : FichierTEXT) : boolean;
var err : OSErr;
begin
  if pathCompletFichierPhoto = '' then 
    begin
      FichierPhotosExisteSurLeDisque := false;
      exit(FichierPhotosExisteSurLeDisque);
    end;
    
  err := FichierTexteExiste(pathCompletFichierPhoto,0,fic);
  FichierPhotosExisteSurLeDisque := (err=NoErr);
end;


function FichierPhotosExisteEnMemoire(pathComplet : str255; var numeroFic : SInt16) : boolean;
var i : SInt16; 
begin
  FichierPhotosExisteEnMemoire := false;
  numeroFic := 0;
  
  if (pathComplet<>'') &
     (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       if (gFichiersPicture.fic[i].nomComplet <> NIL) &
          (pathComplet = gFichiersPicture.fic[i].nomComplet^) then
         begin
           FichierPhotosExisteEnMemoire := true;
           numeroFic := i;
           exit(FichierPhotosExisteEnMemoire);
         end;
end;


function FichierPhotosExisteDansMenu(nomFichierDansMenu : str255; var numeroFic : SInt16) : boolean;
var i : SInt16; 
begin
  FichierPhotosExisteDansMenu := false;
  numeroFic := 0;
  
  if (nomFichierDansMenu <> '') &
     (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       if (gFichiersPicture.fic[i].nomDansMenu <> NIL) &
          (nomFichierDansMenu = gFichiersPicture.fic[i].nomDansMenu^) then
         begin
           FichierPhotosExisteDansMenu := true;
           numeroFic := i;
           exit(FichierPhotosExisteDansMenu);
         end;
end;


function GetPathCompletFichierPionsPourCetteTexture(var whichTexture:CouleurOthellierRec) : str255;
var i : SInt16; 
begin
  GetPathCompletFichierPionsPourCetteTexture := '';  {defaut, par exemple pour une couleur simple}
  
  {on cherche dans tous les fichiers de texture celui qui a les menuID et menuItem de la whichTexture}
  if (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       with gFichiersPicture.fic[i] do
	       if (whichMenuID = whichTexture.menuID) & 
	          (whichMenuItem = whichTexture.menuCmd) & 
	          (nomComplet <> NIL) & 
	          (nomComplet^ <> '') then
	         begin
	           GetPathCompletFichierPionsPourCetteTexture := nomComplet^;
	           exit(GetPathCompletFichierPionsPourCetteTexture);
	         end;
end;


function GetPathCompletFichierBordurePourCetteTexture(var whichTexture:CouleurOthellierRec) : str255;
var i : SInt16; 
begin  {$UNUSED whichTexture}
  GetPathCompletFichierBordurePourCetteTexture := '';  {defaut, par exemple pour une couleur simple}
  
  {on cherche le premier de tous les fichiers de bordure}
  {FIXME : on devrait plutot pouvoir associer une bordure à une texture d'othellier, non ?}
  if (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       with gFichiersPicture.fic[i] do
	       if (typeFichier = kFichierBordure) & 
	          (nomComplet <> NIL) & 
	          (nomComplet^ <> '') then
	         begin
	           GetPathCompletFichierBordurePourCetteTexture := nomComplet^;
	           exit(GetPathCompletFichierBordurePourCetteTexture);
	         end;
end;


function GetNomDansMenuPourCetteTexture(var whichTexture:CouleurOthellierRec) : str255;
var i : SInt16; 
begin
  GetNomDansMenuPourCetteTexture := '';  {defaut, par exemple pour une couleur simple}
  
  {on cherche dans tous les fichiers de texture celui qui a les menuID et menuItem de la whichTexture}
  if (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       with gFichiersPicture.fic[i] do
	       if (whichMenuID = whichTexture.menuID) & 
	          (whichMenuItem = whichTexture.menuCmd) & 
	          (nomDansMenu <> NIL) & 
	          (nomDansMenu^ <> '') then
	         begin
	           GetNomDansMenuPourCetteTexture := nomDansMenu^;
	           exit(GetNomDansMenuPourCetteTexture);
	         end;
end;


function GetPathCompletFichierParNumero(numeroFic : SInt16) : str255;
begin
  if (numeroFic >= 1) & (numeroFic <= gFichiersPicture.nbFichiers) &
     (gFichiersPicture.fic[numeroFic].nomComplet <> NIL) 
    then GetPathCompletFichierParNumero := gFichiersPicture.fic[numeroFic].nomComplet^
    else GetPathCompletFichierParNumero := '';
end;



function GetNomDansMenuParNumero(numeroFic : SInt16) : str255;
begin
  if (numeroFic >= 1) & (numeroFic <= gFichiersPicture.nbFichiers) &
     (gFichiersPicture.fic[numeroFic].nomDansMenu <> NIL) 
    then GetNomDansMenuParNumero := gFichiersPicture.fic[numeroFic].nomDansMenu^
    else GetNomDansMenuParNumero := '';
end;




function PathFichierPicture3DDeCetteFamille(nomFichierDansMenu : str255;coul : SInt16) : str255;
var k : SInt16; 
begin
  PathFichierPicture3DDeCetteFamille := '';

  for k := 1 to gFichiersPicture.nbFichiers do
    with gFichiersPicture.fic[k] do
     if (couleurPions = coul) & 
        (typeFichier = kFichierPicture3D) & (whichMenuID = Picture3DID) & 
        (nomDansMenu <> NIL) & (nomDansMenu^ = nomFichierDansMenu) &
        (nomComplet <> NIL)
       then 
         begin
           PathFichierPicture3DDeCetteFamille := nomComplet^;
           exit(PathFichierPicture3DDeCetteFamille);
         end;
end;




procedure AlerteFichierPhotosNonTrouve(nomFichier : str255);
const OK=1;
      FichierPhotoNonTrouveID=154;
var URL : str255;
    dp : DialogPtr;
    itemHit : SInt16; 
    err : OSErr;
begin
  URL := '<http://cassio.free.fr>';
  
  WritelnDansRapport('');
  WritelnDansRapport(URL);
  WritelnDansRapport('');
  
  BeginDialog;
  dp := MyGetNewDialog(FichierPhotoNonTrouveID,FenetreFictiveAvantPlan());
  if dp <> NIL then
    begin
      ParamText(URL,nomFichier,'','');
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit=OK);
      MyDisposeDialog(dp);
    end;
  EndDialog;
end;


function TransformeNomFichierPicture2D(ancienNom : str255) : str255;
var s : str255;
begin
  ancienNom := ReplaceStringByStringInString('photos Cassio',' ',ancienNom);
  ancienNom := ReplaceStringByStringInString('Photos Cassio',' ',ancienNom);
  
  repeat
    s := ancienNom;
    ancienNom := ReplaceStringByStringInString('alias',' ',ancienNom);
    ancienNom := ReplaceStringByStringInString('(',' ',ancienNom);
    ancienNom := ReplaceStringByStringInString(')',' ',ancienNom);
    ancienNom := ReplaceStringByStringInString('-',' ',ancienNom);
    ancienNom := ReplaceStringByStringInString('[',' ',ancienNom);
    ancienNom := ReplaceStringByStringInString(']',' ',ancienNom);
    EnleveEspacesDeGaucheSurPlace(ancienNom);
    EnleveEspacesDeDroiteSurPlace(ancienNom);
    if ancienNom = '' then ancienNom := 'Photos';
  until (s = ancienNom);
  
  TransformeNomFichierPicture2D := ancienNom;
end;


function TransformeNomFichierPicture3D(ancienNom : str255) : str255;
var s : str255;
begin
  
  repeat
    s := ancienNom;
    ancienNom := ReplaceStringByStringInString('.pict'       ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('[rect].txt'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('[rects].txt' ,' '  ,ancienNom);
    
    ancienNom := ReplaceStringByStringInString('Noirs'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('noirs'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Noir'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('noir'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Vides'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('vides'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Vide'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('vide'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Legaux' ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('legaux' ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Légaux' ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('légaux' ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Aides'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('aides'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Aide'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('aide'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Blancs' ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('blancs' ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Blanc'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('blanc'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Black'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('black'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('White'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('white'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Empty'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('empty'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Legal'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('legal'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Hints'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('hints'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('Hint'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringByStringInString('hint'   ,' '  ,ancienNom);
    
    ancienNom := ReplaceStringByStringInString('alias'  ,' '  ,ancienNom);
    
    ancienNom := ReplaceStringByStringInString('(',' ',ancienNom);
    ancienNom := ReplaceStringByStringInString(')',' ',ancienNom);
    ancienNom := ReplaceStringByStringInString('-',' ',ancienNom);
    ancienNom := ReplaceStringByStringInString('[',' ',ancienNom);
    ancienNom := ReplaceStringByStringInString(']',' ',ancienNom);
    EnleveEspacesDeGaucheSurPlace(ancienNom);
    EnleveEspacesDeDroiteSurPlace(ancienNom);
    if ancienNom = '' then ancienNom := 'Standard';
  until (s = ancienNom);
  
  TransformeNomFichierPicture3D := ancienNom;
end;



function CouleurPionsImage3D(path : str255) : SInt16; 
begin
  CouleurPionsImage3D := kAucuneEnParticulier;
  
  path := MyUpperString(path,false);
  if (Pos('[NOIRS]',path)  > 0) then CouleurPionsImage3D := kImagePionsNoirs     else
  if (Pos('[NOIR]',path)   > 0) then CouleurPionsImage3D := kImagePionsNoirs     else
  if (Pos('[BLANCS]',path) > 0) then CouleurPionsImage3D := kImagePionsBlancs    else
  if (Pos('[BLANC]',path)  > 0) then CouleurPionsImage3D := kImagePionsBlancs    else
  if (Pos('[VIDES]',path)  > 0) then CouleurPionsImage3D := kImagePionsVides     else
  if (Pos('[VIDE]',path)   > 0) then CouleurPionsImage3D := kImagePionsVides     else
  if (Pos('[LEGAUX]',path) > 0) then CouleurPionsImage3D := kImageCoupsLegaux    else
  if (Pos('[AIDE]',path)   > 0) then CouleurPionsImage3D := kImagePionSuggestion else
  if (Pos('[AIDES]',path)  > 0) then CouleurPionsImage3D := kImagePionSuggestion else
  if (Pos('[BLACK]',path)  > 0) then CouleurPionsImage3D := kImagePionsNoirs     else
  if (Pos('[WHITE]',path)  > 0) then CouleurPionsImage3D := kImagePionsBlancs    else
  if (Pos('[EMPTY]',path)  > 0) then CouleurPionsImage3D := kImagePionsVides     else
  if (Pos('[LEGAL]',path)  > 0) then CouleurPionsImage3D := kImageCoupsLegaux    else
  if (Pos('[HINT]',path)   > 0) then CouleurPionsImage3D := kImagePionSuggestion else
  if (Pos('[HINTS]',path)  > 0) then CouleurPionsImage3D := kImagePionSuggestion else
  if (Pos('[COOR]',path)   > 0) then CouleurPionsImage3D := kFichierCoordonees   else
  if (Pos('[RECT]',path)   > 0) then CouleurPionsImage3D := kFichierCoordonees   else
  if (Pos('[RECTS]',path)  > 0) then CouleurPionsImage3D := kFichierCoordonees;
    
end;



procedure AjouterFichierOthellierPicture(fs : FSSpec;typeFichierGraphique : SInt16);
var codeErreur : OSErr;
    path : str255;
    textePourMenu : str255;
    dejaDansListe,dejaDansMenu : boolean;
    nbItemsDansMenu,num : SInt16; 
begin
   with gFichiersPicture do
	    begin
	      codeErreur := FSSpecToFullPath(fs,path);
	      
	      if (fs.name[1] <> '.') then
	        begin
	      
			      case typeFichierGraphique of
			        kFichierPicture2D    : textePourMenu := TransformeNomFichierPicture2D(fs.name);
			        kFichierPicture3D    : textePourMenu := TransformeNomFichierPicture3D(fs.name);
			        kFichierBordure      : textePourMenu := fs.name;
			        kFichierPictureMeteo : textePourMenu := fs.name;
			        otherwise              textePourMenu := fs.name;
			      end; {case}
			      
			      
			      dejaDansListe := FichierPhotosExisteEnMemoire(path,num);
			      dejaDansMenu  := FichierPhotosExisteDansMenu(textePourMenu,num);
			      
			      if not(dejaDansListe) & (nbFichiers < kMaxFichiersOthelliers)  then
			        begin
							  inc(nbFichiers);
							  with fic[nbFichiers] do
						      begin
						        typeFichier   := typeFichierGraphique;
						        
						        case typeFichier of
						          kFichierPicture2D    : couleurPions  := kAucuneEnParticulier;
						          kFichierPicture3D    : couleurPions  := CouleurPionsImage3D(path);
						          kFichierBordure      : couleurPions  := kAucuneEnParticulier;
						          kFichierPictureMeteo : couleurPions  := kAucuneEnParticulier;
			                otherwise              couleurPions  := kAucuneEnParticulier;
						        end;
						        
						        nomComplet  := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
						        nomDansMenu := str255Ptr(AllocateMemoryPtr(sizeof(str255)));
						        
						        if nomComplet  <> NIL then nomComplet^  := path;
						        if nomDansMenu <> NIL then nomDansMenu^ := textePourMenu;
						        
						        if nomDansMenu <> NIL then
							        case typeFichierGraphique of
							          kFichierPicture2D :
							            begin
							              nbItemsDansMenu := MyCountMenuItems(Picture2DMenu);
							              whichMenuID     := Picture2DID;
							              whichMenuItem   := nbItemsDansMenu + 1;
							              InsertMenuItem(Picture2DMenu,nomDansMenu^,whichMenuItem); 
							            end;
							          kFichierPicture3D :
							            begin
							              if dejaDansMenu
							                then
							                  begin {tous les fichiers de la meme famille partage le meme whichMenuItem}
							                    whichMenuID   := fic[num].whichMenuID;
							                    whichMenuItem := fic[num].whichMenuItem;
							                  end
							                else    {le premier de la famille}
								                begin
										              nbItemsDansMenu := MyCountMenuItems(Picture3DMenu);
										              whichMenuID     := Picture3DID;
										              whichMenuItem   := nbItemsDansMenu + 1;
										              InsertMenuItem(Picture3DMenu,nomDansMenu^,whichMenuItem); 
										            end;
							            end;
							        end; {case}
						        
						      end; {with fic[nbFichiers]}
							end;
				  end;
	    end;
end;

function TraiteFichierPictureEtRecursion(var fs : FSSpec;isFolder : boolean;path : str255; var pb:CInfoPBRec) : boolean;
begin
 {$UNUSED pb}
 
 if not(isFolder) then
   begin
     if (Pos('Meteo',path) <> 0)
       then AjouterFichierOthellierPicture(fs,kFichierPictureMeteo) else
     if (Pos('2D',path) <> 0) & ('Bordure' = fs.name)
       then AjouterFichierOthellierPicture(fs,kFichierBordure)      else
     if (Pos('2D',path) <> 0) & (Pos('Bordure',fs.name) <= 0)
       then AjouterFichierOthellierPicture(fs,kFichierPicture2D)    else
     if (Pos('3D',path) <> 0)
       then AjouterFichierOthellierPicture(fs,kFichierPicture3D);
   end;

  TraiteFichierPictureEtRecursion := isFolder; {on cherche recursivement}
end;


procedure CherchePicturesOthelliersDansDossier(vRefNum : SInt16; NomDossier : str255; var dossierTrouve : boolean);
var directoryDepart : FSSpec;
    codeErreur : OSErr;
    cheminDirectoryDepartRecursion : str255;
begin
  cheminDirectoryDepartRecursion := GetWDName(vRefNum)+NomDossier+':';
    
  codeErreur := MyFSMakeFSSpec(vRefNum,vRefNum,cheminDirectoryDepartRecursion,directoryDepart);
  
  codeErreur := SetPathOfScannedDirectory(directoryDepart);
  
  if (codeErreur = 0) then
    codeErreur := ScanDirectory(directoryDepart,TraiteFichierPictureEtRecursion);
  
  dossierTrouve := (codeErreur=0);
end;


procedure LecturePreparatoireDossierOthelliers(vRefNum : SInt16);
var trouve : boolean;
begin
  
  CherchePicturesOthelliersDansDossier(vRefNum,'Othelliers Cassio',trouve);
  if not(trouve) then CherchePicturesOthelliersDansDossier(vRefNum,'Othelliers Cassio (alias)',trouve);
  if not(trouve) then CherchePicturesOthelliersDansDossier(vRefNum,'Othelliers',trouve);
  if not(trouve) then CherchePicturesOthelliersDansDossier(vRefNum,'Othelliers (alias)',trouve);
  if not(trouve) then CherchePicturesOthelliersDansDossier(vRefNum,'Boards',trouve);
  if not(trouve) then CherchePicturesOthelliersDansDossier(vRefNum,'Boards Cassio',trouve);
  if not(trouve) then CherchePicturesOthelliersDansDossier(vRefNum,'Boards Cassio (alias)',trouve);
  
end;


function LitFichierCoordoneesImages3D(var quelleTexture:CouleurOthellierRec) : OSErr;
var erreurES : OSErr;
    nomDansMenu,path,ligne : str255;
    fic : FichierTEXT;
    unRect : rect;
    unPoint : Point;
    s0,s1,s2,s3,s4,s : str255;
    i,k,square : SInt16; 
begin
  nomDansMenu := GetNomDansMenuPourCetteTexture(quelleTexture);
  
  path := PathFichierPicture3DDeCetteFamille(nomDansMenu,kFichierCoordonees);
  
  erreurES := FichierTexteExiste(path,0,fic);
  if (erreurES <> NoErr) then 
    begin
      LitFichierCoordoneesImages3D := erreurES;
      exit(LitFichierCoordoneesImages3D);
    end;
  
  erreurES := OuvreFichierTexte(fic);
  if (erreurES <> NoErr) then 
    begin
      LitFichierCoordoneesImages3D := erreurES;
      exit(LitFichierCoordoneesImages3D);
    end;
  
  SetRect(unRect,0,0,0,0);
  for k := 11 to 88 do
    begin
      SetBoundingRect3D(k,unRect);
      SetRect3DDessus(k,unRect);
      SetRect3DDessous(k,unRect);
    end;
  SetDebugBoundingRects3DPovRay(false);
  SetDebugLegalMovesRects3DPovRay(false);
  SetDebugUpSideFacesRects3DPovRay(false);
      
  while (erreurES=NoErr) & not(EOFFichierTexte(fic,erreurES)) do
    begin
      erreurES := ReadlnDansFichierTexte(fic,ligne);
      {WritelnDansRapport(ligne);}
      if (erreurES=NoErr) & (ligne <> '') & (ligne[1] <> '%') then
        begin
          Parser3(ligne,s0,s1,s2,s);
          if (s1 = '=') & (s2 <> '{') then
            begin
              s0 := MyUpperString(s0,false);
              s2 := MyUpperString(s2,false);
              
              {parser les booleens}
              if (Pos('DEBUG_BOUNDING_RECTANGLES',s0) > 0) | 
                 (Pos('DEBUG_UPPER_RECTANGLES',s0) > 0) | 
                 (Pos('DEBUG_DOWN_RECTANGLES',s0) > 0) then
                begin
		              if Pos('DEBUG_BOUNDING_RECTANGLES',s0) > 0 then SetDebugBoundingRects3DPovRay(s2='TRUE') else
		              if Pos('DEBUG_UPPER_RECTANGLES',s0)    > 0 then SetDebugUpSideFacesRects3DPovRay(s2='TRUE') else
		              if Pos('DEBUG_DOWN_RECTANGLES',s0)     > 0 then SetDebugLegalMovesRects3DPovRay(s2='TRUE');
		            end;
            end else
          if (s1 = '=') & (s2 = '{') then
            begin
              s0 := MyUpperString(s0,false);
		            
              {parser les rectangles}
              if (Pos('BOUNDING_RECT',s0) > 0) | 
                 (Pos('UP_RECT',s0) > 0) | 
                 (Pos('DOWN_RECT',s0) > 0) then
                begin
		              Parser4(s,s1,s2,s3,s4,s);
		              SetRect(unRect,ChaineEnInteger(s1),ChaineEnInteger(s2),ChaineEnInteger(s3),ChaineEnInteger(s4));
		              
		              (*
		              with unRect do
		                begin
		                  WriteDansRapport(ligne+' { ');
		                  WriteStringAndNumDansRapport(' ',(left*8 + 2) div 5);
		                  WriteStringAndNumDansRapport(' ',(top*8 + 2) div 5);
		                  WriteStringAndNumDansRapport(' ',(right*8 + 2) div 5);
		                  WriteStringAndNumDansRapport(' ',(bottom*8 + 2) div 5);
		                  WritelnDansRapport(' } ');
		                end;
		              *)
		              
		              square := StringEnCoup(s0);
		              if Pos('BOUNDING_RECT',s0) > 0 then SetBoundingRect3D(square,unRect) else
		              if Pos('UP_RECT',s0)       > 0 then SetRect3DDessus(square,unRect)   else
		              if Pos('DOWN_RECT',s0)     > 0 then SetRect3DDessous(square,unRect);
		            end;
		            
		          {parser les points}
			        if (Pos('IMAGE_SIZE',s0) > 0) |
			           (Pos('BLACK_SCORE_POSITION',s0) > 0) |
			           (Pos('WHITE_SCORE_POSITION',s0) > 0) |
			           (Pos('BEST_LINE_POSITION',s0) > 0) |
			           (Pos('YOUR_MOVE_PLEASE_POSITION',s0) > 0) then
			            begin
			              Parser2(s,s1,s2,s);
			              unPoint.h := ChaineEnInteger(s1);
			              unPoint.v := ChaineEnInteger(s2);
			              
			              (*
			              with unPoint do
			                begin
			                  WriteDansRapport(ligne+' { ');
			                  WriteStringAndNumDansRapport(' ',(h*8 + 2) div 5);
			                  WriteStringAndNumDansRapport(' ',(v*8 + 2) div 5);
			                  WritelnDansRapport(' } ');
			                end;
			              *)
			              
			              if Pos('IMAGE_SIZE',s0) > 0                then SetTailleImagesPovRay(unPoint) else
			              if Pos('BLACK_SCORE_POSITION',s0) > 0      then SetPositionScorePovRay3D(pionNoir,unPoint) else
			              if Pos('WHITE_SCORE_POSITION',s0) > 0      then SetPositionScorePovRay3D(pionBlanc,unPoint) else
		                if Pos('BEST_LINE_POSITION',s0) > 0        then SetPositionMeilleureSuitePovRay3D(unPoint) else
		                if Pos('YOUR_MOVE_PLEASE_POSITION',s0) > 0 then SetPositionDemandeCoupPovRay3D(unPoint);
			            end;
			      end;
        end;
    end;
  
  
  for i := 1 to 8 do
    for k := 1 to 6 do 
      begin
        square := i*10 + k + 1;
        unRect := InterpolerRectangles(GetBoundingRect3D(i*10+1),GetBoundingRect3D(i*10+8),7,k);
        SetBoundingRect3D(square,unRect);
        
        unRect := InterpolerRectangles(GetRect3DDessus(i*10+1),GetRect3DDessus(i*10+8),7,k);
        SetRect3DDessus(square,unRect);
        
        unRect := InterpolerRectangles(GetRect3DDessous(i*10+1),GetRect3DDessous(i*10+8),7,k);
        SetRect3DDessous(square,unRect);
      end;
  
  
  erreurES := FermeFichierTexte(fic);
  LitFichierCoordoneesImages3D := erreurES;
end;


procedure TestUnitFichierPhotos;
var fic : FichierTEXT;
    temp : boolean;
begin
  temp := GetDebuggageUnitFichiersTexte;
  SetDebuggageUnitFichiersTexte(true);

  if FichierPhotosExisteSurLeDisque('Photos Cassio',fic) 
    then
      WritelnDansRapport('Le fichier des photos a été trouvé !')
    else
      WritelnDansRapport('Le fichier des photos est introuvable !');
 
  SetDebuggageUnitFichiersTexte(temp);
 end;
 
 
 
 END.