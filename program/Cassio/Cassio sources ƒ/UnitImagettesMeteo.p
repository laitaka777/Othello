UNIT UnitImagettesMeteo;




INTERFACE







USES MacTypes,QuickDraw;

type TypeImagette = SInt32;

const kAucuneImagette = 0;
      kAlertSmall     = 1;
      kAlertBig       = 2;
      kSunCloudSmall  = 3;
      kSunCloudBig    = 4;
      kSunSmall       = 5;
      kSunBig         = 6;
      kThunderstormSmall = 7;
      kThunderstormBig   = 8;
      kUnknownSmall      = 9;
      kUnknownBig        = 10;
                     

function GetCheminAccesImagette(quelleImage:TypeImagette; var CheminAccesImagette : str255; var numeroDuFichierImage : SInt16) : boolean;
procedure DrawImagetteMeteo(quelleImage:TypeImagette;whichWindow : WindowPtr;whichBounds : rect;fonctionAppelante : str255);
procedure DrawImagetteMeteoOnSquare(quelleImage:TypeImagette;quelleCase : SInt16);



IMPLEMENTATION







USES UnitFichierPhotos,UnitFichiersTEXT,UnitHTML,UnitOth1,UnitRapport,UnitBufferedPICT,UnitCouleur;


function GetCheminAccesImagette(quelleImage:TypeImagette; var CheminAccesImagette : str255; var numeroDuFichierImage : SInt16) : boolean;
var s : str255;
    i : SInt16; 
begin
  s := 'aucune imagettersgsgdvdghfsdghfdsg';
  case quelleImage of
    kAlertSmall        : s := 'Small:Alert.tiff';
    kAlertBig          : s := 'Big:Alert.tiff';
    kSunCloudSmall     : s := 'Small:Sun-Cloud-1.tiff';
    kSunCloudBig       : s := 'Big:Sun-Cloud-1.tiff';
    kSunSmall          : s := 'Small:Sun.tiff';
    kSunBig            : s := 'Big:Sun.tiff';
    kThunderstormSmall : s := 'Small:Thunderstorm.tiff';
    kThunderstormBig   : s := 'Big:Thunderstorm.tiff';
    kUnknownSmall      : s := 'Small:Unknown.tiff';
    kUnknownBig        : s := 'Big:Unknown.tiff';
  end; {case}
  
  with gFichiersPicture do
    begin
      for i := 1 to nbFichiers do
        with fic[i] do
          if (typeFichier = kFichierPictureMeteo) &
             (nomComplet <> NIL) &
             (Pos(s,nomComplet^) > 0) then
           begin
             GetCheminAccesImagette := true;
             numeroDuFichierImage   := i;
             CheminAccesImagette    := nomComplet^;
             
             exit(GetCheminAccesImagette);
           end;
    end;
  
  {par defaut : non trouve :-( }
  
  GetCheminAccesImagette := false;
  numeroDuFichierImage   := 0;
  CheminAccesImagette    := s;
end;


procedure DrawImagetteMeteo(quelleImage:TypeImagette;whichWindow : WindowPtr;whichBounds : rect;fonctionAppelante : str255);
var path : str255;
    numeroImage : SInt16; 
    fic : FichierTEXT;
    erreurES : OSErr;
begin {$UNUSED fonctionAppelante}
  if GetCheminAccesImagette(quelleImage,path,numeroImage) then
    begin
      {WritelnStringDansRapport('path = '+ path+', fonctionAppelante = '+fonctionAppelante);}
      erreurES := FichierTexteExiste(path,0,fic);
      if (erreurES = NoErr) & (whichWindow <> NIL) then
        QTGraph_ShowImageWithTransparenceFromFile(GetWindowPort(whichWindow),gPurNoir,whichBounds,fic.theFSSpec);
    end;
end;



procedure DrawImagetteMeteoOnSquare(quelleImage:TypeImagette;quelleCase : SInt16);
var bounds : rect;
    largeur,hauteur : SInt32;
begin
  if (quelleCase >= 11) & (quelleCase <= 88) then
    begin
      bounds := GetBoundingRectOfSquare(quelleCase);
      largeur := bounds.right - bounds.left;
      hauteur := bounds.bottom - bounds.top;
      OffsetRect(bounds,(largeur div 3) - 2,hauteur div 3);
      DrawImagetteMeteo(quelleImage,wPlateauPtr,bounds,'DrawImagetteMeteoOnSquare');
      InvalidateDessinEnTraceDeRayon(quelleCase);
		  SetOthellierEstSale(quelleCase,true);
    end;
end;




















END.