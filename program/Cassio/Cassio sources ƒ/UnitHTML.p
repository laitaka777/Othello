UNIT UnitHTML;




INTERFACE







USES UnitZoneMemoire,UnitPositionEtTrait;


{fonctions pour generer du code HTML correspondant � un diagramme}
function StringEnHTML(s : str255) : str255;
function WritelnEnHTMLDansZoneMemoire(var theZone : ZoneMemoire;s : str255) : OSErr;
function WritePositionEtTraitPageWebFFODansZoneMemoire(position : PositionEtTraitRec;legende : str255; var theZone : ZoneMemoire) : OSErr;
function WritePositionEtTraitEnHTMLDansZoneMemoire(position : PositionEtTraitRec;
                                               var theZone : ZoneMemoire;
                                               chainePrologue : str255;
                                               chaineEpilogue : str255;
                                               chainePionsNoirs : str255;
                                               chainePionsBlancs : str255;
                                               chaineCoupsLegauxBlancs : str255;
                                               chaineCoupsLegauxNoirs : str255;
                                               chaineAutresCasesVides : str255;
                                               chaineTop : str255;
                                               chaineBottom : str255;
                                               chaineBordureGauche : str255;
                                               chaineBordureDroite : str255;
                                               chaineLegende : str255
                                               ) : OSErr;
                                               

{quelques fonctions pour generer les images utilisees dans le code HTML}
procedure ConvertPICTtoJPEGandExportToFile(thePicHandle: PicHandle;fileSpec: FSSpec);
procedure QTGraph_ShowImageFromFile(whichWindow : CGrafPtr;whichBounds : rect; var theFSSpec : FSSpec);
procedure QTGraph_ShowImageWithTransparenceFromFile(whichWindow : CGrafPtr;transparentColor : RGBColor;whichBounds : rect; var theFSSpec : FSSpec);
procedure CreateJPEGImageOfPosition(position : PositionEtTraitRec;fileSpec: FSSpec);




IMPLEMENTATION







USES UnitDiagramFforum,UnitStrategie,UnitFichiersTEXT,MacTypes,Menus,UnitOth2,
     UnitScannerOthellistique,SNStrings,UnitMacExtras,ImageCompression,QuickTimeComponents;


function StringEnHTML(s : str255) : str255;
var i : SInt32;
    c : char;
    result : str255;
begin
  result := '';
  for i := 1 to Length(s) do
    begin
      c := s[i];
      case c of
        '�' : result := result + '&nbsp;';
        '�' : result := result + '&sect;';
        '�' : result := result + '&ulm;';
        '�' : result := result + '&acute;';
        '�' : result := result + '&aelig;';
        
        '�' : result := result + '&Agrave;';
        '�' : result := result + '&Acirc;';
        '�' : result := result + '&Egrave;';
        '�' : result := result + '&Euml;';
        '�' : result := result + '&Ecirc;';
        '�' : result := result + '&Eacute;';
        '�' : result := result + '&Icirc;';
        
        '�' : result := result + '&Ntilde;';
        '�' : result := result + '&ntilde;';
        
        '�' : result := result + '&copy;';
        '�' : result := result + '&reg;';
        
        '�' : result := result + '&eacute;';
        '�' : result := result + '&egrave;';
        '�' : result := result + '&ecirc;';
        '�' : result := result + '&euml;';
        
        '�' : result := result + '&iuml;';
        '�' : result := result + '&icirc;';
        '�' : result := result + '&igrave;';
        
        '�' : result := result + '&agrave;';
        '�' : result := result + '&acirc;';
        '�' : result := result + '&auml;';
        
        '�' : result := result + '&ocirc;';
        '�' : result := result + '&ograve;';
        '�' : result := result + '&oulm;';
        
        '�' : result := result + '&ugrave;';
        '�' : result := result + '&ucirc;';
        
        '�' : result := result + '&ccedil;';
        '�' : result := result + '&laquo;';
        '�' : result := result + '&raquo;';
        '�' : result := result + '&deg;';
        otherwise result := result + StringOf(c);
      end;
    end;
  StringEnHTML := result;
end;


function WritelnEnHTMLDansZoneMemoire(var theZone : ZoneMemoire;s : str255) : OSErr;
var i : SInt32;
    c : char;
    err : OSErr;
begin
  for i := 1 to Length(s) do
    begin
      c := s[i];
      case c of
        '�' : err := WriteDansZoneMemoire(theZone,'&nbsp;');
        '�' : err := WriteDansZoneMemoire(theZone,'&sect;');
        '�' : err := WriteDansZoneMemoire(theZone,'&ulm;');
        '�' : err := WriteDansZoneMemoire(theZone,'&acute;');
        '�' : err := WriteDansZoneMemoire(theZone,'&aelig;');
        
        '�' : err := WriteDansZoneMemoire(theZone,'&Agrave;');
        '�' : err := WriteDansZoneMemoire(theZone,'&Acirc;');
        '�' : err := WriteDansZoneMemoire(theZone,'&Egrave;');
        '�' : err := WriteDansZoneMemoire(theZone,'&Euml;');
        '�' : err := WriteDansZoneMemoire(theZone,'&Ecirc;');
        '�' : err := WriteDansZoneMemoire(theZone,'&Eacute;');
        '�' : err := WriteDansZoneMemoire(theZone,'&Icirc;');
        
        '�' : err := WriteDansZoneMemoire(theZone,'&Ntilde;');
        '�' : err := WriteDansZoneMemoire(theZone,'&ntilde;');
        
        '�' : err := WriteDansZoneMemoire(theZone,'&copy;');
        '�' : err := WriteDansZoneMemoire(theZone,'&reg;');
        
        '�' : err := WriteDansZoneMemoire(theZone,'&eacute;');
        '�' : err := WriteDansZoneMemoire(theZone,'&egrave;');
        '�' : err := WriteDansZoneMemoire(theZone,'&ecirc;');
        '�' : err := WriteDansZoneMemoire(theZone,'&euml;');
        
        '�' : err := WriteDansZoneMemoire(theZone,'&iuml;');
        '�' : err := WriteDansZoneMemoire(theZone,'&icirc;');
        '�' : err := WriteDansZoneMemoire(theZone,'&igrave;');
        
        '�' : err := WriteDansZoneMemoire(theZone,'&agrave;');
        '�' : err := WriteDansZoneMemoire(theZone,'&acirc;');
        '�' : err := WriteDansZoneMemoire(theZone,'&auml;');
        
        '�' : err := WriteDansZoneMemoire(theZone,'&ocirc;');
        '�' : err := WriteDansZoneMemoire(theZone,'&ograve;');
        '�' : err := WriteDansZoneMemoire(theZone,'&oulm;');
        
        '�' : err := WriteDansZoneMemoire(theZone,'&ugrave;');
        '�' : err := WriteDansZoneMemoire(theZone,'&ucirc;');
        
        '�' : err := WriteDansZoneMemoire(theZone,'&ccedil;');
        '�' : err := WriteDansZoneMemoire(theZone,'&laquo;');
        '�' : err := WriteDansZoneMemoire(theZone,'&raquo;');
        '�' : err := WriteDansZoneMemoire(theZone,'&deg;');
        otherwise err := WriteDansZoneMemoire(theZone,StringOf(c));
      end;
    end;
  err := WritelnDansZoneMemoire(theZone,'');
  WritelnEnHTMLDansZoneMemoire := err;
end;

function WritePositionEtTraitEnHTMLDansZoneMemoire(position : PositionEtTraitRec;
                                               var theZone : ZoneMemoire;
                                               chainePrologue : str255;
                                               chaineEpilogue : str255;
                                               chainePionsNoirs : str255;
                                               chainePionsBlancs : str255;
                                               chaineCoupsLegauxBlancs : str255;
                                               chaineCoupsLegauxNoirs : str255;
                                               chaineAutresCasesVides : str255;
                                               chaineTop : str255;
                                               chaineBottom : str255;
                                               chaineBordureGauche : str255;
                                               chaineBordureDroite : str255;
                                               chaineLegende : str255
                                               ) : OSErr;
var fichierEtaitOuvertEnArrivant : boolean;
    ligneStr,squareStr : str255;
    err : OSErr;
    i,j : SInt32;
    square : SInt32;
    fic : FichierTEXT;
begin
  err := NoErr;
  
  fichierEtaitOuvertEnArrivant := false;
  if (GetFichierTEXTOfZoneMemoirePtr(@theZone,fic) = NoErr) then
    begin
      fichierEtaitOuvertEnArrivant := FichierTexteEstOuvert(fic);
      if not(fichierEtaitOuvertEnArrivant) then err := OuvreFichierTexte(fic);
    end;
  
  
  err := WritelnDansZoneMemoire(theZone,chainePrologue);
  err := WriteDansZoneMemoire(theZone,chaineTop);
  for i := 1 to 8 do
    begin
      ligneStr := NumEnString(i);
      err := WriteDansZoneMemoire(theZone,ParamStr(chaineBordureGauche,ligneStr,ligneStr,ligneStr,ligneStr));
      for j := 1 to 8 do
        begin
          square := i*10+j;
          squareStr := CoupEnStringEnMinuscules(square);
          case position.position[square] of
            pionBlanc : err := WriteDansZoneMemoire(theZone,ParamStr(chainePionsBlancs,squareStr,squareStr,squareStr,squareStr));
            pionNoir  : err := WriteDansZoneMemoire(theZone,ParamStr(chainePionsNoirs,squareStr,squareStr,squareStr,squareStr));
            pionVide  : begin
                          if PeutJouerIci(pionBlanc,square,position.position) & (Pos('^0',chaineCoupsLegauxBlancs) > 0)
                            then err := WriteDansZoneMemoire(theZone,ParamStr(chaineCoupsLegauxBlancs,squareStr,squareStr,squareStr,squareStr)) else
                          if PeutJouerIci(pionNoir,square,position.position) & (Pos('^0',chaineCoupsLegauxNoirs) > 0)
                            then err := WriteDansZoneMemoire(theZone,ParamStr(chaineCoupsLegauxNoirs,squareStr,squareStr,squareStr,squareStr))
                            else err := WriteDansZoneMemoire(theZone,ParamStr(chaineAutresCasesVides,squareStr,squareStr,squareStr,squareStr));
                        end;
          end; {case}
        end;
      err := WritelnDansZoneMemoire(theZone,ParamStr(chaineBordureDroite,ligneStr,ligneStr,ligneStr,ligneStr));
    end;
  err := WriteDansZoneMemoire(theZone,chaineBottom);
  err := WriteDansZoneMemoire(theZone,chaineLegende);
  err := WritelnDansZoneMemoire(theZone,chaineEpilogue);
  

  if (GetFichierTEXTOfZoneMemoirePtr(@theZone,fic) = NoErr) & not(fichierEtaitOuvertEnArrivant)
    then err := FermeFichierTexte(fic);
    
  
  WritePositionEtTraitEnHTMLDansZoneMemoire := err;
end;


function WritePositionEtTraitPageWebFFODansZoneMemoire(position : PositionEtTraitRec;legende : str255; var theZone : ZoneMemoire) : OSErr;
begin
  WritePositionEtTraitPageWebFFODansZoneMemoire :=
     WritePositionEtTraitEnHTMLDansZoneMemoire(position,theZone,
                                           '<div class="diagramme">',
                                           '</div>',
                                           '<img src="bb.gif" width="24" height="24">',
                                           '<img src="ww.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="top.gif" width="224" height="16">',
                                           '<img src="top.gif" width="224" height="16"><br />',
                                           '<img src="^0^1.gif" width="16" height="24">',
                                           '<img src="^0^1.gif" width="16" height="24"><br />',
                                           legende
                                          );
end;




{refer to QuickTime 4 reference p 573 for more info.}
procedure ConvertPICTtoJPEGandExportToFile(thePicHandle: PicHandle;fileSpec: FSSpec);
var
    result:ComponentResult;
    ge:GraphicsExportComponent;
    myError : OSErr;
    ActualSize : UInt32;
begin
  myError := OpenADefaultComponent(GraphicsExporterComponentType,kQTFileTypeJPEG, ge);
  result := GraphicsExportSetInputPicture(ge,thePicHandle);
  result := GraphicsExportSetOutputFileTypeAndCreator(ge,kQTFileTypeJPEG,'GKON'); {GKON is GraphicConverter}
  result := GraphicsExportSetOutputFile(ge,fileSpec);
  result := GraphicsExportDoExport(ge,ActualSize);
  myError := CloseComponent(ge);
end;


procedure QTGraph_ShowImageFromFile(whichWindow : CGrafPtr;whichBounds : rect; var theFSSpec : FSSpec);
var       
  myImporter : GraphicsImportComponent;
  myRect : Rect;
  err : OSErr;
  oldPort : GrafPtr;
begin
  myImporter := NIL;
  
  err := GetGraphicsImporterForFile(theFSSpec, myImporter);
  if (myImporter <> NIL) then
    begin
      err := GraphicsImportGetNaturalBounds(myImporter, myRect);
      if (whichWindow <> NIL) & (err = NoErr) then
        begin
          GetPort(oldPort);
          SetPort(whichWindow);
          err := GraphicsImportSetGWorld(myImporter, whichWindow, NIL);
          err := GraphicsImportSetBoundsRect(myImporter, whichBounds);
          err := GraphicsImportDraw(myImporter);
          err := CloseComponent(myImporter);
          SetPort(oldPort);
        end;
     end;
end;

procedure QTGraph_ShowImageWithTransparenceFromFile(whichWindow : CGrafPtr;transparentColor : RGBColor;whichBounds : rect; var theFSSpec : FSSpec);
var       
  myImporter : GraphicsImportComponent;
  myRect : Rect;
  err : OSErr;
  oldPort : GrafPtr;
begin
  myImporter := NIL;
  
  err := GetGraphicsImporterForFile(theFSSpec, myImporter);
  if (myImporter <> NIL) then
    begin
      err := GraphicsImportGetNaturalBounds(myImporter, myRect);
      if (whichWindow <> NIL) & (err = NoErr) then
        begin
          GetPort(oldPort);
          SetPort(whichWindow);
          err := GraphicsImportSetGWorld(myImporter, whichWindow, NIL);
          err := GraphicsImportSetBoundsRect(myImporter, whichBounds);
          err := GraphicsImportSetGraphicsMode(myImporter,transparent, transparentColor);
          err := GraphicsImportDraw(myImporter);
          err := CloseComponent(myImporter);
          SetPort(oldPort);
        end;
     end;
end;

procedure CreateJPEGImageOfPosition(position : PositionEtTraitRec;fileSpec: FSSpec);
const kTailleCase = 12;
      kLargeurBordure = 8;
var i,j,square : SInt32;
    erreurES : OSErr;
    fic : FichierTEXT;
    bounds : rect;
    marge : Point;
    myPicture:PicHandle;
    
    procedure MyDrawPicture(nom : str255;whichBounds : rect);
    begin
      erreurES := FichierTexteDeCassioExiste(nom,fic);
      if (erreurES = NoErr) & (wPlateauPtr <> NIL) then
        QTGraph_ShowImageFromFile(GetWindowPort(wPlateauPtr),whichBounds,fic.theFSSpec);
    end;
    
begin
  
  SetPt(marge,0,0);
  
  with marge do
    begin
    
      myPicture := OpenPicture(MakeRect(h, 
                                        v,
                                        h + 2*kLargeurBordure + 8*kTailleCase,
                                        v + 2*kLargeurBordure + 8*kTailleCase));
                               
      
      bounds := MakeRect(h,v,h + 2*kLargeurBordure + 8*kTailleCase,v+kLargeurBordure);
      MyDrawPicture('top.gif',bounds);
      
      for i := 1 to 8 do
        begin
        
          bounds := MakeRect(h, 
                             v + kLargeurBordure + (i-1)*kTailleCase,
                             h + kLargeurBordure,
                             v + kLargeurBordure + i*kTailleCase);
          MyDrawPicture(ParamStr('^0^1.gif',NumEnString(i),NumEnString(i),'',''),bounds);
      
          for j := 1 to 8 do
            begin
              square := i*10+j;
              bounds := MakeRect( h + kLargeurBordure + (j-1)*kTailleCase , 
                                  v + kLargeurBordure + (i-1)*kTailleCase , 
                                  h + kLargeurBordure + j*kTailleCase,
                                  v + kLargeurBordure + i*kTailleCase);
              case position.position[square] of
                pionBlanc : MyDrawPicture('ww.gif',bounds);
                pionNoir  : MyDrawPicture('bb.gif',bounds);
                pionVide  : MyDrawPicture('ee.gif',bounds);
              end;

            end;
          
          bounds := MakeRect(h + kLargeurBordure + 8*kTailleCase, 
                             v + kLargeurBordure + (i-1)*kTailleCase,
                             h + 2*kLargeurBordure + 8*kTailleCase,
                             v + kLargeurBordure + i*kTailleCase);
          MyDrawPicture(ParamStr('^0^1.gif',NumEnString(i),NumEnString(i),'',''),bounds);
          
        end;
      
      
      bounds := MakeRect(h, 
                         v + kLargeurBordure + 8*kTailleCase,
                         h + 2*kLargeurBordure + 8*kTailleCase,
                         v + 2*kLargeurBordure + 8*kTailleCase);
      MyDrawPicture('top.gif',bounds);
      
      ClosePicture;
      ConvertPICTtoJPEGandExportToFile(myPicture,fileSpec);
      KillPicture(myPicture);
    end;
end;



end.











































