UNIT UnitFichiersTEXT;



INTERFACE







USES MacTypes, Files;
   

   
TYPE  

     {FIXME : on risque de perturber InfosFichiersNouveauFormat dans le
              fichier UnitDefinitionsNouveauFormat (tableau trop gros)
              si on rajoute des gros champs à FichierTEXT... }
     FichierTEXT=             
          record 
            nomFichier : str255;                  {private}
            uniqueID : SInt32;                   {private}
            parID : SInt32;                      {private}
            refNum : SInt16;                     {private}
            vRefNum : SInt16;                    {private}
            ressourceForkRefNum : SInt32;        {private}
            dataForkOuvertCorrectement : SInt32; {private}
            rsrcForkOuvertCorrectement : SInt32; {private}
            theFSSpec : FSSpec;                   {private}
          end;
      
      
     {type fonctionnel pour ForEachLineInFileDo}
     LineOfFileProc = procedure(var ligne : str255; var result : SInt32);


function FichierTexteExiste(nom : str255;vRefNum : SInt16; var fic : FichierTEXT) : OSErr;
function FichierTexteExisteFSp(mySpec : FSSpec; var fic : FichierTEXT) : OSErr;
function CreeFichierTexte(nom : str255;vRefNum : SInt16; var fic : FichierTEXT) : OSErr;
function CreeFichierTexteFSp(mySpec : FSSpec; var fic : FichierTEXT) : OSErr;
function GetFichierTexte(fileKind1,fileKind2,fileKind3,fileKind4 : OSType; var fic : FichierTEXT) : OSErr;


function OuvreFichierTexte(var fic : FichierTEXT) : OSErr;
function FermeFichierTexte(var fic : FichierTEXT) : OSErr;
function EffaceFichierTexte(var fic : FichierTEXT) : OSErr;
function FichierTexteEstOuvert(var fic : FichierTEXT) : boolean;
function GetUniqueIDFichierTexte(var fic : FichierTEXT) : SInt32;
function GetTailleFichierTexte(var fic : FichierTEXT; var taille : SInt32) : OSErr;
function SetPositionTeteLectureFichierTexte(var fic : FichierTEXT;position : SInt32) : OSErr;
function SetPositionTeteLectureFinFichierTexte(var fic : FichierTEXT) : OSErr;
function GetPositionTeteLectureFichierTexte(var fic : FichierTEXT; var position : SInt32) : OSErr;
function EOFFichierTexte(var fic : FichierTEXT; var erreurES : OSErr) : boolean;
function SetEOFFichierTexte(var fic : FichierTEXT;posEOF : SInt32) : OSErr;
function VideFichierTexte(var fic : FichierTEXT) : OSErr;


function WriteBufferDansFichierTexte(var fic : FichierTEXT;buffPtr : Ptr; var count : SInt32) : OSErr;
function WriteDansFichierTexte(var fic : FichierTEXT;s : str255) : OSErr;
function WritelnDansFichierTexte(var fic : FichierTEXT;s : str255) : OSErr;
function WriteLongintDansFichierTexte(var fic : FichierTEXT;value : SInt32) : OSErr;
function ReadBufferDansFichierTexte(var fic : FichierTEXT;buffPtr : Ptr; var count : SInt32) : OSErr;
function ReadDansFichierTexte(var fic : FichierTEXT;nbOctets : SInt16; var s : str255) : OSErr;
function ReadlnDansFichierTexte(var fic : FichierTEXT; var s : str255) : OSErr;
function ReadlnBufferDansFichierTexte(var fic : FichierTEXT; buffPtr : Ptr; var count : SInt32) : OSErr;
function ReadLongintDansFichierTexte(var fic : FichierTEXT; var value : SInt32) : OSErr;


procedure ForEachLineInFileDo(whichFile : FSSpec;DoWhat : LineOfFileProc; var result : SInt32);
function InsererFichierDansFichierTexte(var fic : FichierTEXT;pathFichierAInserer : str255) : OSErr;
function InsererFichierTexteDansFichierTexte(var insere,receptacle : FichierTEXT) : OSErr;


procedure SetFileCreatorFichierTexte(var fic : FichierTEXT;QuelType : OSType);
procedure SetFileTypeFichierTexte(var fic : FichierTEXT;QuelType : OSType);
function GetFileCreatorFichierTexte(var fic : FichierTEXT) : OSType;
function GetFileTypeFichierTexte(var fic : FichierTEXT) : OSType;


function GetCreationDateFichierTexte(var fic : FichierTEXT; var theDate : DateTimeRec) : OSErr;
function SetCreationDateFichierTexte(var fic : FichierTEXT; const theDate : DateTimeRec) : OSErr;
function GetModificationDateFichierTexte(var fic : FichierTEXT; var theDate : DateTimeRec) : OSErr;
function SetModificationDateFichierTexte(var fic : FichierTEXT; const theDate : DateTimeRec) : OSErr;


function CreerRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
function OuvreRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
function FermeRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
function UseRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;


procedure SetDebuggageUnitFichiersTexte(flag : boolean);
function  GetDebuggageUnitFichiersTexte() : boolean;


function CreeSortieStandardEnFichierTexte(var fic : FichierTEXT) : OSErr;
function FSSpecToLongName(whichFile : FSSpec; var theLongName : str255) : OSErr;
function PathCompletToLongName(path : str255; var theLongName : str255) : OSErr;


  (* Installation des procedure pour l'affichage de message :
     sur la sortie standard par defaut. On peut installer des
     routines personalisees d'impression de messages et d'alerte 
     juste apres l'appel a InitUnitFichierTexte *)

TYPE  MessageDisplayerProc = procedure(msg : string);
      MessageAndNumDisplayerProc = procedure(msg : string;num : SInt32);
      


procedure InitUnitFichierTexte;
procedure InstalleMessageDisplayerFichierTexte(theProc : MessageDisplayerProc);
procedure InstalleMessageAndNumDisplayerFichierTexte(theProc : MessageAndNumDisplayerProc);
procedure InstalleAlerteFichierTexte(theProc : MessageAndNumDisplayerProc);

procedure DisplayMessageInConsole(s : string);
procedure DisplayMessageWithNumInConsole(s : string;num : SInt32);
procedure DisplayAlerteWithNumInConsole(s : string;num : SInt32);




IMPLEMENTATION







USES MyStrings,UnitDialog,MyFileSystemUtils,UnitHashing,UnitTraceLog,UnitRapport,
     UnitRapportImplementation,SNStrings;


const unit_initialisee : boolean = false;
      avecDebuggageUnitFichiersTexte : boolean = false;
      
var useStandardConsole : boolean;
    CustomDisplayMessage : MessageDisplayerProc;
    CustomDisplayMessageWithNum : MessageAndNumDisplayerProc;
    CustomDisplayAlerteWithNum : MessageAndNumDisplayerProc;
    nomSortieStandardDansRapport : str255;
 
procedure StandardConsoleDisplayer(s : string);
begin
  Writeln(s);
end;

procedure StandardConsoleDisplayerWithNum(s : string;num : SInt32);
begin
  Writeln(s,num);
end;

procedure StandardConsoleAlertWithNum(s : string;num : SInt32);
begin
  Writeln('### WARNING ### '+s+' ',num);
end;


procedure DisplayMessageInConsole(s : string);
begin
  if unit_initialisee
    then CustomDisplayMessage(s)
    else StandardConsoleDisplayer(s);
end;

procedure DisplayMessageWithNumInConsole(s : string;num : SInt32);
begin
  if unit_initialisee
    then CustomDisplayMessageWithNum(s,num)
    else StandardConsoleDisplayerWithNum(s,num);
end;

procedure DisplayAlerteWithNumInConsole(s : string;num : SInt32);
begin
  if unit_initialisee
    then CustomDisplayAlerteWithNum(s,num)
    else StandardConsoleAlertWithNum(s,num)
end;



function ResolveAliasInFullName(var fullName : str255) : OSErr;
var debut,reste,resolvedDebut : str255;
    myFSSpec : FSSpec;
    err : OSErr;
    posDeuxPoints : SInt16; 
begin
  debut := '';
  reste := fullName;
  err := 0;
  
  while (reste<>'') & (err=0) do
    begin
      posDeuxPoints := Pos(':',reste);
      if posDeuxPoints>0
        then
          begin
            debut := debut+TPCopy(reste,1,posDeuxPoints);
            reste := TPCopy(reste,posDeuxPoints+1,Length(reste)-posDeuxPoints);
          end
        else
          begin
            debut := debut+reste;
            reste := '';
          end;
          
      err := MyFSMakeFSSpec(0,0,debut,myFSSpec);
      MyResolveAliasFile(myFSSpec);
      resolvedDebut := debut;
      err := FSSpecToFullPath(myFSSpec,resolvedDebut);
      if err=0 then 
        begin
          if EndsWithDeuxPoints(debut) & not(EndsWithDeuxPoints(resolvedDebut))
            then debut := resolvedDebut+':'
            else debut := resolvedDebut;
        end;
    end;
  if err=0 then fullName := debut;
  
  ResolveAliasInFullName := err;
end;


function FichierTexteEstLeRapport(var fic : FichierTEXT) : boolean;
begin
  FichierTexteEstLeRapport := (fic.vRefNum = 0) &
                              (fic.parID = 0) &
                              (fic.refNum = 0) &
                              (fic.nomFichier = nomSortieStandardDansRapport);
end;


function InitialiseFichierTexte(var nom : str255; var vRefNum : SInt16) : FichierTEXT;
var fic : FichierTEXT;
    nomDirectory : str255;
    len : SInt16; 
    err : OSErr;
begin
  
  if (Pos(':',nom) > 0) & (vRefNum <> 0)
    then 
      begin
        nomDirectory := GetWDName(vRefNum);
        len := Length(nomDirectory);
        if (len>0) & (nomDirectory <> ':') & ((len+Length(nom)) <= 220) then
          begin
            if (nom[1] = ':') & EndsWithDeuxPoints(nomDirectory)
              then nom := TPCopy(nomDirectory,1,len-1)+nom
              else nom := nomDirectory+nom;
            err := ResolveAliasInFullName(nom);
            vRefNum := 0;
          end;
      end;
      
  fic.nomFichier := nom;
  fic.vRefNum := vRefNum;
  fic.parID := 0;
  fic.refNum := 0;
  fic.uniqueID := 0;  {not yet initialised, we'll do it in CreateFFSpecAndResolveAlias}
  with fic.theFSSpec do
    begin
      name := '';
      vRefNum := 0;
      parID := 0;
    end;
  fic.ressourceForkRefNum := -1;
  fic.dataForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}
  InitialiseFichierTexte := fic;
end;


function InitialiseFichierTexteFSp(mySpec : FSSpec) : FichierTEXT;
var fic : FichierTEXT;
begin
      
  fic.nomFichier := mySpec.name;
  fic.vRefNum    := mySpec.vRefNum;
  fic.parID      := mySpec.parID;
  fic.refNum     := 0;
  fic.uniqueID   := 0;  {not yet initialised, we'll do it in CreateFFSpecAndResolveAlias}
  fic.theFSSpec  := mySpec;
  fic.ressourceForkRefNum := -1;
  fic.dataForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}
  InitialiseFichierTexteFSp := fic;
end;


type FSCopyAliasInfoPtr = function(inAlias : AliasHandle; 
                                   targetName :  HFSUniStr255Ptr; 
                                   volumeName :  HFSUniStr255Ptr;
                                   pathString : CFStringRefPtr; 
                                   whichInfo : Ptr; {should be FSAliasInfoBitmap^ }
                                   info : Ptr       {should be FSAliasInfo^ }
                                   ) : OSStatus;


function FSSpecToLongName(whichFile : FSSpec; var theLongName : str255) : OSErr;
var err : OSErr;
    MacVersion : SInt32;
    MySFCopyAlias : FSCopyAliasInfoPtr;
    targetName : HFSUniStr255;
    fileRef : FSRef;
    theAlias : aliasHandle;
    str : CFStringRef;
    pascalName : str255;
label cleanUp;
begin
  err := -1;
  theLongName := whichFile.name;
  
  if (Gestalt(gestaltSystemVersion, MacVersion) = noErr) &
     (MacVersion >= $1020)  (* au moins Mac OS X 10.2 *)
    then
      begin
			
  			MySFCopyAlias := FSCopyAliasInfoPtr(GetFunctionPointerFromBundle('CoreServices.framework','FSCopyAliasInfo'));
  			
  			if (MySFCopyAlias <> NIL) then
  			  begin
  			    err := FSpMakeFSRef(whichFile,fileRef);
  			    
            if (err <> NoErr) then 
              goto cleanUp;
            
            err := FSNewAlias(NIL,fileRef,theAlias);
            
            if (err <> NoErr) then 
              goto cleanUp;
            
            if (theAlias <> NIL) then
              err := MySFCopyAlias(theAlias,@targetName, NIL, NIL, NIL, NIL);
              
            if (err <> NoErr) then 
              goto cleanUp;
            
            str := CFStringCreateWithCharacters( NIL {kCFAllocatorDefault}, @targetName.unicode[0], targetName.length );
            
            if CFStringGetPascalString(str, @pascalName, 256, kTextEncodingMacRoman)
              then theLongName := pascalName
              else err := -1;
              
            CFRelease(CFTypeRef(str));

  			  end;
      end;
  
  cleanUp : 
  FSSpecToLongName := err;
end;


function PathCompletToLongName(path : str255; var theLongName : str255) : OSErr;
var err : OSErr;
    myFSSpec : FSSpec;
begin
   err := MyFSMakeFSSpec(0,0,path,myFSSpec);
   if err <> NoErr
     then PathCompletToLongName := err
     else PathCompletToLongName := FSSpecToLongName(myFSSpec,theLongName);
end;


function CreateFFSpecAndResolveAlias(var fic : FichierTEXT) : OSErr;
var err,bidLongint : OSErr;
    fullName : str255;
begin
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' avant MyFSMakeFSSpec dans CreateFFSpecAndResolveAlias :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
    end;
    
  if FichierTexteEstLeRapport(fic) then
    begin
      CreateFFSpecAndResolveAlias := NoErr;
      exit(CreateFFSpecAndResolveAlias);
    end;
    
  with fic do
    begin
      err := MyFSMakeFSSpec(vRefNum,parID,nomFichier,theFSSpec);
      fullName := nomFichier;
      if (err=NoErr) then 
        begin
          MyResolveAliasFile(theFSSpec);
          
          err := FSSpecToFullPath(theFSSpec,fullName);

        end else
      if (err=fnfErr) then {-43 : File Not Found, mais le FSSpec est valable}
        bidlongint := FSSpecToFullPath(theFSSpec,fullName);
      parID      := theFSSpec.parID;
      nomFichier := fullName;
      uniqueID   := HashString(fullName);
      
      {DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('Length(fic.fullName)=',Length(fullName));
      DisplayMessageWithNumInConsole('hashing -> uniqueID=',uniqueID);}
    end;
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSMakeFSSpec dans CreateFFSpecAndResolveAlias :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  CreateFFSpecAndResolveAlias := err;
end;


function FichierTexteExiste(nom : str255;vRefNum : SInt16; var fic : FichierTEXT) : OSErr;
var err1,err2 : OSErr;
    FinderInfos:FInfo;
begin

  if (nom = '') then
    begin
      DisplayMessageInConsole('WARNING ! (nom = '''') dans FichierTexteExiste');
      FichierTexteExiste := -1;
      exit(FichierTexteExiste);
    end;
  
  {TraceLog('FichierTexteExiste : nom =' + nom);}
    
  fic := InitialiseFichierTexte(nom,vRefNum);
  
  if FichierTexteEstLeRapport(fic) then
    begin
      FichierTexteExiste := NoErr; 
      exit(FichierTexteExiste);
    end;
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres InitialiseFichierTexte dans FichierTexteExiste :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
    end;
    
  err2 := CreateFFSpecAndResolveAlias(fic);
			  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans FichierTexteExiste :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err2=',err2);
    end;
  
  if (err2 <> NoErr)
    then
      FichierTexteExiste := err2
    else
      begin
			  err1 := FSpGetFInfo(fic.theFSSpec,FinderInfos);
			  
			  if avecDebuggageUnitFichiersTexte then
			    begin
			      DisplayMessageInConsole('');
			      DisplayMessageInConsole(' apres FSpGetFInfo dans FichierTexteExiste :');
			      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
			      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
			      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
			      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
			      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
			      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
			      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
			      DisplayMessageWithNumInConsole('   ==> Err1=',err1);
			    end;
			  
			  FichierTexteExiste := err1;
			end;
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' a la fin de FichierTexteExiste :');
      DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement=',fic.dataForkOuvertCorrectement);
    end;
end;


function FichierTexteExisteFSp(mySpec : FSSpec; var fic : FichierTEXT) : OSErr;
var err1,err2 : OSErr;
    FinderInfos:FInfo;
begin
  if (mySpec.name = '') then
    begin
      DisplayMessageInConsole('WARNING ! (mySpec.name = '''') dans FichierTexteExisteFSp');
      FichierTexteExisteFSp := -1;
      exit(FichierTexteExisteFSp);
    end;
    
    
  fic := InitialiseFichierTexteFSp(mySpec);
  
  if FichierTexteEstLeRapport(fic) then
    begin
      FichierTexteExisteFSp := NoErr;
      exit(FichierTexteExisteFSp);
    end;
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres InitialiseFichierTexte dans FichierTexteExisteFSp :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
    end;
    
  err2 := CreateFFSpecAndResolveAlias(fic);
			  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans FichierTexteExisteFSp :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err2=',err2);
    end;
  
  if (err2 <> NoErr)
    then
      FichierTexteExisteFSp := err2
    else
      begin
			  err1 := FSpGetFInfo(fic.theFSSpec,FinderInfos);
			  
			  if avecDebuggageUnitFichiersTexte then
			    begin
			      DisplayMessageInConsole('');
			      DisplayMessageInConsole(' apres FSpGetFInfo dans FichierTexteExiste :');
			      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
			      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
			      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
			      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
			      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
			      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
			      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
			      DisplayMessageWithNumInConsole('   ==> Err1=',err1);
			    end;
			  
			  FichierTexteExisteFSp := err1;
			end;
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' a la fin de FichierTexteExiste :');
      DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement=',fic.dataForkOuvertCorrectement);
    end;
end;


function CreeFichierTexte(nom : str255;vRefNum : SInt16; var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin
  fic := InitialiseFichierTexte(nom,vRefNum);
  err := CreateFFSpecAndResolveAlias(fic);
  
  if FichierTexteEstLeRapport(fic) then
    begin
      CreeFichierTexte := NoErr;
      exit(CreeFichierTexte);
    end;
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans CreeFichierTexte :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  err := FSpCreate(fic.TheFSSpec,'????','TEXT',0);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreate dans CreeFichierTexte :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  CreeFichierTexte := err;
end;

function CreeFichierTexteFSp(mySpec : FSSpec; var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin
  fic := InitialiseFichierTexteFSp(mySpec);
  err := CreateFFSpecAndResolveAlias(fic);
  
  if FichierTexteEstLeRapport(fic) then
    begin
      CreeFichierTexteFSp := NoErr;
      exit(CreeFichierTexteFSp);
    end;
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans CreeFichierTexteFSp :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  err := FSpCreate(fic.TheFSSpec,'????','TEXT',0);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreate dans CreeFichierTexteFSp :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  CreeFichierTexteFSp := err;
end;

function GetFichierTexte(fileKind1,fileKind2,fileKind3,fileKind4 : OSType; var fic : FichierTEXT) : OSErr;
var reply : SFReply;
    err : OSErr;
    mySpec : FSSpec;
begin
  err := -1;
  
  if GetFileName(reply,fileKind1,fileKind2,fileKind3,fileKind4,mySpec) then
    err := FichierTexteExisteFSp(mySpec,fic);
    
  GetFichierTexte := err;
end;


function OuvreFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      OuvreFichierTexte := NoErr;
      exit(OuvreFichierTexte);
    end;

  if fic.dataForkOuvertCorrectement <> -1 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut ouvrir le data Fork d''un fichier dont fic.dataForkOuvertCorrectement<>-1 !');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageInConsole('fic.theFSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement=',fic.dataForkOuvertCorrectement);
      DisplayMessageInConsole('');
      OuvreFichierTexte := -1;
      exit(OuvreFichierTexte);
    end;
  
  err := -1;

(*
  with fic do  {on essaie l'ouverture avec les anciennes routines}
    err := FSOpen(nomFichier,vRefNum,refNum); 
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSOpen dans OuvreFichierTexte :');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
*)
  
  if err<>NoErr then  {on essaie avec les routines du systeme 7 et le FSSpec}
    with fic do
      begin
        err := FSpOpenDF(theFSSpec,fsCurPerm,refNum);
        
        if avecDebuggageUnitFichiersTexte then
			    begin
			      DisplayMessageInConsole('');
			      DisplayMessageInConsole(' apres FSpOpenDF dans OuvreFichierTexte :');
			      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
			      DisplayMessageWithNumInConsole('fic.vRefNum=',fic.vRefNum);
			      DisplayMessageWithNumInConsole('fic.parID=',fic.parID);
			      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
			      DisplayMessageInConsole('FSSpec.name='+fic.theFSSpec.name);
			      DisplayMessageWithNumInConsole('FSSpec.vRefNum=',fic.theFSSpec.vRefNum);
			      DisplayMessageWithNumInConsole('FSSpec.parID=',fic.theFSSpec.parID);
			      DisplayMessageWithNumInConsole('   ==> Err=',err);
			    end;
      end;
  
  if err=NoErr then
    begin
      inc(fic.dataForkOuvertCorrectement);
      if fic.dataForkOuvertCorrectement <> 0 then
        begin
          SysBeep(0);
          DisplayMessageInConsole('');
          DisplayMessageInConsole('## WARNING : après une ouverture réussie, dataForkOuvertCorrectement <> 0 !');
          DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
          DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement',fic.dataForkOuvertCorrectement);
          DisplayMessageInConsole('');
        end;
    end;
    
  OuvreFichierTexte := err;
end;


function FermeFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      FermeFichierTexte := NoErr;
      exit(FermeFichierTexte);
    end;
  
  if fic.dataForkOuvertCorrectement <> 0 then 
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut fermer le data Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageInConsole('fic.theFSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
      DisplayMessageInConsole('');
      FermeFichierTexte := -1;
      
      (* ForconsLePlantageDeCassio; *)
      
      exit(FermeFichierTexte);
    end;

  err := FSClose(fic.refNum);
   
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSClose dans FermeFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  if err=NoErr then
      begin
        dec(fic.dataForkOuvertCorrectement);
        if (fic.dataForkOuvertCorrectement <> -1) then
          begin
            SysBeep(0);
            DisplayMessageInConsole('');
            DisplayMessageInConsole('## WARNING : après une fermeture correcte du data fork d''un fichier, dataForkOuvertCorrectement<>-1 !');
            DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
            DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement=',fic.dataForkOuvertCorrectement);
            DisplayMessageInConsole('');
          end;
      end;
    
  FermeFichierTexte := err;
end;


function EffaceFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      EffaceFichierTexte := NoErr;
      exit(EffaceFichierTexte);
    end;

  (*
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' entree dans EffaceFichierTexte :');
      DisplayMessageInConsole('     appel de FermeFichierTexte :');
    end;
    
  err := FermeFichierTexte(fic);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FermeFichierTexte dans EffaceFichierTexte :');
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  *)
  
  err := -1;
  (*
  with fic do  {on essaie avec les anciennes routines}
    err := FSDelete(nomFichier,vRefNum); 
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSDelete dans EffaceFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  *)
  
  if err<>NoErr then  {on essaie avec les routines du systeme 7 et le FSSpec}
    with fic do
      begin
        err := FSpDelete(theFSSpec);
        
        if avecDebuggageUnitFichiersTexte then
			    begin
			      DisplayMessageInConsole('');
            DisplayMessageInConsole(' apres FSpDelete dans EffaceFichierTexte :');
            DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
            DisplayMessageWithNumInConsole('   ==> Err=',err);
			    end;
      end;
        
  EffaceFichierTexte := err;
end;

function FichierTexteEstOuvert(var fic : FichierTEXT) : boolean;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      FichierTexteEstOuvert := true;
      exit(FichierTexteEstOuvert);
    end;

  FichierTexteEstOuvert := (fic.dataForkOuvertCorrectement = 0);
end;

function GetUniqueIDFichierTexte(var fic : FichierTEXT) : SInt32;
begin
  GetUniqueIDFichierTexte := fic.uniqueID;
end;

function GetTailleFichierTexte(var fic : FichierTEXT; var taille : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      taille := GetTailleRapport();
      GetTailleFichierTexte := NoErr;
      exit(GetTailleFichierTexte);
    end;

  err := GetEOF(fic.refNum,taille);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetEOF dans GetTailleFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('taille=',taille);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  GetTailleFichierTexte := err;
end;


function SetPositionTeteLectureFichierTexte(var fic : FichierTEXT;position : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      SetDebutSelectionRapport(position);
      SetFinSelectionRapport(position);
      SetPositionTeteLectureFichierTexte := NoErr;
      exit(SetPositionTeteLectureFichierTexte);
    end;
    
  err := SetFPos(fic.refNum,fsFromStart,position);
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetFPos dans SetPositionTeteLectureFichierTexte :');
      DisplayMessageWithNumInConsole(' pos = ',position);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    

  SetPositionTeteLectureFichierTexte := err;
end;

function SetPositionTeteLectureFinFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      FinRapport;
      SetPositionTeteLectureFinFichierTexte := NoErr;
      exit(SetPositionTeteLectureFinFichierTexte);
    end;

  err := SetFPos(fic.refNum,fsFromLEOF,0);
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetFPos dans SetPositionTeteLectureFinFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  SetPositionTeteLectureFinFichierTexte := err;
end;


function GetPositionTeteLectureFichierTexte(var fic : FichierTEXT; var position : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      position := GetDebutSelectionRapport();
      GetPositionTeteLectureFichierTexte := NoErr;
      exit(GetPositionTeteLectureFichierTexte);
    end;
    
  err := GetFPos(fic.refNum,position);
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetFPos dans GetPositionTeteLectureFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  GetPositionTeteLectureFichierTexte := err;
end;


function EOFFichierTexte(var fic : FichierTEXT; var erreurES : OSErr) : boolean;
var position,logicalEOF : SInt32;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      position := GetDebutSelectionRapport();
      EOFFichierTexte := (position >= GetTailleRapport());
      exit(EOFFichierTexte);
    end;
    
    
  EOFFichierTexte := true;
  
  erreurES := GetFPos(fic.refNum,position);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetFPos dans EOFFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('position=',position);
      DisplayMessageWithNumInConsole('   ==> Err=',erreurES);
    end;
  
  if erreurES<>NoErr then exit(EOFFichierTexte);
  erreurES := GetEOF(fic.refNum,logicalEOF);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetEOF dans EOFFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('logicalEOF=',logicalEOF);
      DisplayMessageWithNumInConsole('   ==> Err=',erreurES);
    end;
    
  if erreurES<>NoErr then exit(EOFFichierTexte);
  EOFFichierTexte := ( position >= logicalEOF);
end;

function SetEOFFichierTexte(var fic : FichierTEXT;posEOF : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      SetEOFFichierTexte := NoErr;
      exit(SetEOFFichierTexte);
    end;
    
  err := SetEOF(fic.refNum,posEOF);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetEOF dans SetEOFFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  SetEOFFichierTexte := err;
end;


function VideFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin
  
  if FichierTexteEstLeRapport(fic) then
    begin
      DetruireTexteDansRapport(0,maxlongint,true);
      VideFichierTexte := NoErr;
      exit(VideFichierTexte);
    end;

  err := SetEOFFichierTexte(fic,0);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetEOFFichierTexte dans VideFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  VideFichierTexte := err;
end;



function WriteBufferDansFichierTexte(var fic : FichierTEXT;buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      InsereTexteDansRapport(buffPtr,count);
      WriteBufferDansFichierTexte := NoErr;
      exit(WriteBufferDansFichierTexte);
    end;
    
  err := FSWrite(fic.refNum,count,buffPtr);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSWrite dans WriteBufferDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  WriteBufferDansFichierTexte := err;
end;

function WriteDansFichierTexte(var fic : FichierTEXT;s : str255) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      WriteDansRapport(s);
      WriteDansFichierTexte := NoErr;
      exit(WriteDansFichierTexte);
    end;
    
  err := MyFSWriteString(fic.refNum,s);
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSWriteString dans WriteDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  WriteDansFichierTexte := err;
end;


function WritelnDansFichierTexte(var fic : FichierTEXT;s : str255) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      WritelnDansRapport(s);
      WritelnDansFichierTexte := NoErr;
      exit(WritelnDansFichierTexte);
    end;
    
  err := MyFSWriteString(fic.refnum,s+chr(13));
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSWriteString dans WritelnDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  WritelnDansFichierTexte := err;
end;


function WriteLongintDansFichierTexte(var fic : FichierTEXT;value : SInt32) : OSErr;
var err : OSErr;
    count : SInt32;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      InsereTexteDansRapport(@value,4);
      WriteLongintDansFichierTexte := NoErr;
      exit(WriteLongintDansFichierTexte);
    end;
    
  count := 4;
  err := FSWrite(fic.refNum,count,@value);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSWrite dans WriteLongintDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  WriteLongintDansFichierTexte := err;
end;

function ReadBufferDansFichierTexte(var fic : FichierTEXT;buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      ReadBufferDansFichierTexte := -1;
      exit(ReadBufferDansFichierTexte);
    end;
    
  err := FSRead(fic.refNum,count,buffPtr);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadBufferDansFichierTexte :');
      DisplayMessageWithNumInConsole('count=',count);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  ReadBufferDansFichierTexte := err;
end;


function ReadDansFichierTexte(var fic : FichierTEXT;nbOctets : SInt16; var s : str255) : OSErr;
var len : SInt32;
    err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      ReadDansFichierTexte := -1;
      exit(ReadDansFichierTexte);
    end;
    
  len := nbOctets;
  if len > 255 then len := 255;
  if len < 0 then len := 0;
  
  err := FSRead(fic.refnum,len,@s[1]);
  s[0] := chr(len);
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  ReadDansFichierTexte := err;
end;


function ReadlnDansFichierTexte(var fic : FichierTEXT; var s : str255) : OSErr;
var err : OSErr;
    i,len,longueurLigne : SInt32;
    positionTeteDeLecture : SInt32; 
    retourCharriotTrouve : boolean;
    buffer : packed array[0..300] of char;
begin
  s := '';
  
  if FichierTexteEstLeRapport(fic) then
    begin
      ReadlnDansFichierTexte := -1;
      exit(ReadlnDansFichierTexte);
    end;
    
  {
  err := MyFSReadLine(fic.refnum,s);
  }
  
  err := GetPositionTeteLectureFichierTexte(fic,positionTeteDeLecture);
  
  {on essaie de lire 258 caracteres dans le buffer}
  len := 258;
  err := FSRead(fic.refnum,len,@buffer[1]);
  for i := len+1 to 258 do buffer[i] := chr(0);
  
  {on cherche le premier retour charriot dans le buffer}
  len := Min(256,len);
  longueurLigne := Min(255,len);
  retourCharriotTrouve := false;
  for i := len downto 1 do
    if (buffer[i] = cr) | (buffer[i] = lf) then 
      begin
        longueurLigne := i-1;
        retourCharriotTrouve := true;
      end;
  
  {on ajuste en consequence la longueur de s, et on recopie la chaine}
  for i := 1 to longueurLigne do s[i] := buffer[i];
  for i := longueurLigne + 1 to 255 do s[i] := chr(0);
  s[0] := chr(longueurLigne);
 
  {on gere les retours charriots DOS, UNIX, Mac, etc}
  if retourCharriotTrouve then
    begin
      if ((buffer[longueurLigne+1] = cr) & (buffer[longueurLigne+2] = lf)) |
         ((buffer[longueurLigne+1] = lf) & (buffer[longueurLigne+2] = cr)) 
         then inc(longueurLigne);
    end;
  
  {on deplace la tete de lecture}
  if retourCharriotTrouve
    then positionTeteDeLecture := 1 + positionTeteDeLecture + longueurLigne
    else positionTeteDeLecture :=     positionTeteDeLecture + longueurLigne;
  err := SetPositionTeteLectureFichierTexte(fic,positionTeteDeLecture);

  {
  WriteStringAndBoolDansRapport(s+' ',retourCharriotTrouve);
  WritelnStringAndNumDansRapport(' ==>  err = ',err);
  }
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadlnDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  ReadlnDansFichierTexte := err;
end;



{Lit un fichier jusqu'au premier retour charriot et met le resultat dans buffer.
   -> En entree, count est la taille du buffer.
   -> En sortie, count contient le nombre de caracteres jusqu'au premier 
                 retour charriot, si on en a trouve un... }
function ReadlnBufferDansFichierTexte(var fic : FichierTEXT; buffPtr : Ptr; var count : SInt32) : OSErr;
type charArray = packed array[0..0] of char;
     charArrayPtr = ^charArray;
var err : OSErr;
    i,len,longueurLigne : SInt32;
    positionTeteDeLecture : SInt32; 
    retourCharriotTrouve : boolean;
    localBuffer:charArrayPtr;
begin
  
  if FichierTexteEstLeRapport(fic) then
    begin
      ReadlnBufferDansFichierTexte := -1;
      exit(ReadlnBufferDansFichierTexte);
    end;
    
  err := GetPositionTeteLectureFichierTexte(fic,positionTeteDeLecture);
  
  {on essaie de lire count caracteres dans buffPtr}
  len := count;
  err := FSRead(fic.refnum,count,buffPtr);
  localBuffer := charArrayPtr(buffPtr);
  
  {on cherche le premier retour charriot dans buffPtr}
  longueurLigne := Min(len,count);
  retourCharriotTrouve := false;
  for i := count-1 downto 0 do
    if (localBuffer^[i] = cr) | (localBuffer^[i] = lf) then 
      begin
        longueurLigne := i;
        count := i;
        retourCharriotTrouve := true;
      end;
  
  
  {on deplace la tete de lecture}
  if retourCharriotTrouve
    then positionTeteDeLecture := 1 + positionTeteDeLecture + longueurLigne
    else positionTeteDeLecture :=     positionTeteDeLecture + longueurLigne;
  err := SetPositionTeteLectureFichierTexte(fic,positionTeteDeLecture);

  {
  WriteStringAndBoolDansRapport(s+' ',retourCharriotTrouve);
  WritelnStringAndNumDansRapport(' ==>  err = ',err);
  }
    
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadlnBufferDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  ReadlnBufferDansFichierTexte := err;
end;

function ReadLongintDansFichierTexte(var fic : FichierTEXT; var value : SInt32) : OSErr;
var err : OSErr;
    count : SInt32;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      ReadLongintDansFichierTexte := -1;
      exit(ReadLongintDansFichierTexte);
    end;
    
  count := 4;
  err := FSRead(fic.refNum,count,@value);
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadLongintDansFichierTexte :');
      DisplayMessageWithNumInConsole('count=',count);
      DisplayMessageWithNumInConsole('fic.refNum=',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
  
  ReadLongintDansFichierTexte := err;
end;


procedure ForEachLineInFileDo(whichFile : FSSpec;DoWhat : LineOfFileProc; var result : SInt32);
var theFic : FichierTEXT;
    erreurES : OSErr;
    ligne : str255;
begin
  erreurES := FichierTexteExisteFSp(whichFile,theFic);
  if (erreurES <> NoErr) then exit(ForEachLineInFileDo);
  
  erreurES := OuvreFichierTexte(theFic);
  if (erreurES <> NoErr) then exit(ForEachLineInFileDo);
  
  ligne := '';
  while not(EOFFichierTexte(theFic,erreurES)) do
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
  
      erreurES := ReadlnDansFichierTexte(theFic,ligne);
      
      DoWhat(ligne,result);
    end;
  
  erreurES := FermeFichierTexte(theFic);
end;



function InsererFichierDansFichierTexte(var fic : FichierTEXT;pathFichierAInserer : str255);
var insertion : FichierTEXT;
    err,err2 : OSErr;
begin
  err := FichierTexteExiste(pathFichierAInserer,0,insertion);
  if err=NoErr then
    begin
      err := OuvreFichierTexte(insertion);
      err := InsererFichierTexteDansFichierTexte(insertion,fic);
      err2 := FermeFichierTexte(insertion);
    end;
  
  InsererFichierDansFichierTexte := err;
end;


function InsererFichierTexteDansFichierTexte(var insere,receptacle : FichierTEXT) : OSErr;
const kTailleBufferCopie = 10000;
var err,err2 : OSErr;
    fichierInsereOuvert : boolean;
    fichierReceptacleOuvert : boolean;
    buffer : packed array[0.. (kTailleBufferCopie-1) ] of char;
    longueurInsertion : SInt32;
    count,nbOctetsCopies : SInt32;
begin

  err := NoErr;
  err2 := NoErr;

  fichierInsereOuvert := FichierTexteEstOuvert(insere);
  if not(fichierInsereOuvert) then err := OuvreFichierTexte(insere);
  err := SetPositionTeteLectureFichierTexte(insere,0);
  
  fichierReceptacleOuvert := FichierTexteEstOuvert(receptacle);
  if not(fichierReceptacleOuvert) then 
    begin  {ouvrir le fichier et placer le curseur à la fin}
      err2 := OuvreFichierTexte(receptacle);
      err2 := SetPositionTeteLectureFinFichierTexte(receptacle);
    end;
  
  if (err = NoErr) & (err2 = NoErr) then
    begin
      err := GetTailleFichierTexte(insere,longueurInsertion);
      
      nbOctetsCopies := 0;
      
      repeat
        count := Min(kTailleBufferCopie, longueurInsertion-nbOctetsCopies);
        err  := ReadBufferDansFichierTexte(insere,@buffer[0],count);
        err2 := WriteBufferDansFichierTexte(receptacle,@buffer[0],count);
        nbOctetsCopies := nbOctetsCopies + count;
      until (err <> NoErr) | (err2 <> NoErr) | (nbOctetsCopies >= longueurInsertion);
      
    end;
  
  if not(fichierInsereOuvert)     then err  := FermeFichierTexte(insere);
  if not(fichierReceptacleOuvert) then err2 := FermeFichierTexte(receptacle);
  
  if (err <> NoErr) 
    then InsererFichierTexteDansFichierTexte := err
    else InsererFichierTexteDansFichierTexte := err2;
    
end;

function CreerRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
var err : OSErr;
    creator,fileType: OSType;
begin

  creator := GetFileCreatorFichierTexte(fic);
  fileType := GetFileTypeFichierTexte(fic);

  FSpCreateResFile(fic.TheFSSpec,creator,fileType,smSystemScript);
  err := ResError();
  
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreateResFile dans CreerRessourceForkFichierTEXT :');
      DisplayMessageWithNumInConsole('   ==> Err=',err);
    end;
    
  CreerRessourceForkFichierTEXT := err;
end;


function OuvreRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
var NroRef : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      OuvreRessourceForkFichierTEXT := -1;
      exit(OuvreRessourceForkFichierTEXT);
    end;

  if fic.rsrcForkOuvertCorrectement <> -1 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut ouvrir le ressource Fork d''un fichier dont fic.rsrcForkOuvertCorrectement<>-1 !');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageInConsole('fic.theFSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement=',fic.rsrcForkOuvertCorrectement);
      DisplayMessageInConsole('');
      OuvreRessourceForkFichierTEXT := -1;
      exit(OuvreRessourceForkFichierTEXT);
    end;

  NroRef := FSpOpenResFile(fic.TheFSSpec,4);
  if NroRef=-1
    then OuvreRessourceForkFichierTEXT := -1  {Error !}
    else 
      begin
        fic.ressourceForkRefNum := NroRef;
        OuvreRessourceForkFichierTEXT := NoErr;  
        
        inc(fic.rsrcForkOuvertCorrectement);
        if (fic.rsrcForkOuvertCorrectement <> 0) then
          begin
            SysBeep(0);
            DisplayMessageInConsole('');
            DisplayMessageInConsole('## WARNING : après une ouverture correcte du ressource fork d''un fichier, rsrcForkOuvertCorrectement <> 0 !');
            DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
            DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement=',fic.rsrcForkOuvertCorrectement);
            DisplayMessageInConsole('');
          end;
      end;      
end;


function UseRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      UseRessourceForkFichierTEXT := -1;
      exit(UseRessourceForkFichierTEXT);
    end;
    
  if fic.rsrcForkOuvertCorrectement <> 0 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut utiliser le ressource Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageInConsole('fic.theFSSpec.name='+fic.theFSSpec.name);
      DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement=',fic.rsrcForkOuvertCorrectement);
      DisplayMessageInConsole('');
      UseRessourceForkFichierTEXT := -1;
      exit(UseRessourceForkFichierTEXT);
    end;
    
  UseResFile(fic.ressourceForkRefNum);
  err := ResError();
  {DisplayMessageWithNumInConsole('err=',err);}
  
  UseRessourceForkFichierTEXT := err;
end;

function FermeRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin
  
  if FichierTexteEstLeRapport(fic) then
    begin
      FermeRessourceForkFichierTEXT := -1;
      exit(FermeRessourceForkFichierTEXT);
    end;
  
  if fic.rsrcForkOuvertCorrectement <> 0 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut fermer le ressource Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement=',fic.rsrcForkOuvertCorrectement);
      DisplayMessageInConsole('');
      FermeRessourceForkFichierTEXT := -1;
      exit(FermeRessourceForkFichierTEXT);
    end;
    
  if fic.ressourceForkRefNum <> 0 
    then 
      begin
        CloseResFile(fic.ressourceForkRefNum);
        err := ResError();
        {DisplayMessageWithNumInConsole('err=',err);}
        
        FermeRessourceForkFichierTEXT := err;
        
        if err=NoErr then
          begin
            dec(fic.rsrcForkOuvertCorrectement);
            if (fic.rsrcForkOuvertCorrectement<>-1) then
              begin
                SysBeep(0);
                DisplayMessageInConsole('');
                DisplayMessageInConsole('## WARNING : après une fermeture correcte du ressource fork d''un fichier, rsrcForkOuvertCorrectement<>-1 !');
                DisplayMessageInConsole('fic.nomFichier='+fic.nomFichier);
                DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement=',fic.rsrcForkOuvertCorrectement);
                DisplayMessageInConsole('');
              end;
          end;
      end
    else
      FermeRessourceForkFichierTEXT := -1;  {erreur, on a failli fermer le fichier systeme !}
end;



procedure SetFileCreatorFichierTexte(var fic : FichierTEXT;QuelType : OSType);
var InfosFinder:FInfo;
    err : OSErr;
begin
  if FichierTexteEstLeRapport(fic)
    then exit(SetFileCreatorFichierTexte);

  err := FSpGetFInfo(fic.theFSSpec,InfosFinder);
  InfosFinder.fdCreator := QuelType;
  err := FSpSetFInfo(fic.theFSSpec,InfosFinder);
end;


procedure SetFileTypeFichierTexte(var fic : FichierTEXT;QuelType : OSType);
var InfosFinder:FInfo;
    err : OSErr;
begin
  if FichierTexteEstLeRapport(fic)
    then exit(SetFileTypeFichierTexte);
    
  err := FSpGetFInfo(fic.theFSSpec,InfosFinder);
  InfosFinder.fdType := QuelType;
  err := FSpSetFInfo(fic.theFSSpec,InfosFinder);
end; 


function GetFileCreatorFichierTexte(var fic : FichierTEXT) : OSType;
var InfosFinder:FInfo;
    err : OSErr;
begin
  GetFileCreatorFichierTexte := '????';
  
  if FichierTexteEstLeRapport(fic) then
    begin
      GetFileCreatorFichierTexte := NoErr;
      exit(GetFileCreatorFichierTexte);
    end;
  
  err := FSpGetFInfo(fic.theFSSpec,InfosFinder);
  GetFileCreatorFichierTexte := InfosFinder.fdCreator;
end; 


function GetFileTypeFichierTexte(var fic : FichierTEXT) : OSType;
var InfosFinder:FInfo;
    err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      GetFileTypeFichierTexte := NoErr;
      exit(GetFileTypeFichierTexte);
    end;
    
  GetFileTypeFichierTexte := '????';
  err := FSpGetFInfo(fic.theFSSpec,InfosFinder);
  GetFileTypeFichierTexte := InfosFinder.fdType;
end; 

{kFSCatInfoCreateDate = 0x00000020,
   kFSCatInfoContentMod = 0x00000040
   }

function GetCreationDateFichierTexte(var fic : FichierTEXT; var theDate : DateTimeRec) : OSErr;
var err : OSErr;
    fileRef : FSRef;
    catalogInfo: FSCatalogInfo;
begin
  if FichierTexteEstLeRapport(fic) then
    begin
      GetCreationDateFichierTexte := -1;
      exit(GetCreationDateFichierTexte);
    end;
  
  err := FSpMakeFSRef(fic.theFSSpec,fileRef);
  
  if err = NoErr then
    begin
      err := FSGetCatalogInfo(fileRef,kFSCatInfoCreateDate,@catalogInfo,NIL,NIL,NIL);
      if (err = NoErr) then SecondsToDate(catalogInfo.createDate.lowSeconds,theDate);
    end;
  
  GetCreationDateFichierTexte := err;
end;


function SetCreationDateFichierTexte(var fic : FichierTEXT; const theDate : DateTimeRec) : OSErr;
var err : OSErr;
    {fileRef : FSRef;
    catalogInfo: FSCatalogInfo;}
begin {$UNUSED theDate}
  if FichierTexteEstLeRapport(fic) then
    begin
      SetCreationDateFichierTexte := -1;
      exit(SetCreationDateFichierTexte);
    end;
  
  err := -1;
  
  SetCreationDateFichierTexte := err;
end;


function GetModificationDateFichierTexte(var fic : FichierTEXT; var theDate : DateTimeRec) : OSErr;
var err : OSErr;
    fileRef : FSRef;
    catalogInfo : FSCatalogInfo;
begin
  if FichierTexteEstLeRapport(fic) then
    begin
      GetModificationDateFichierTexte := -1;
      exit(GetModificationDateFichierTexte);
    end;
  
  err := FSpMakeFSRef(fic.theFSSpec,fileRef);
  
  if err = NoErr then
    begin
      err := FSGetCatalogInfo(fileRef,kFSCatInfoContentMod,@catalogInfo,NIL,NIL,NIL);
      if (err = NoErr) then SecondsToDate(catalogInfo.contentModDate.lowSeconds,theDate);
    end;
  
  GetModificationDateFichierTexte := err;
end;


function SetModificationDateFichierTexte(var fic : FichierTEXT; const theDate : DateTimeRec) : OSErr;
var err : OSErr;
begin {$UNUSED theDate}
  if FichierTexteEstLeRapport(fic) then
    begin
      SetModificationDateFichierTexte := -1;
      exit(SetModificationDateFichierTexte);
    end;
  
  err := -1;
  
  SetModificationDateFichierTexte := err;
end;


procedure InstalleMessageDisplayerFichierTexte(theProc : MessageDisplayerProc);
begin
  CustomDisplayMessage := theProc;
  useStandardConsole := false;
end;

procedure InstalleMessageAndNumDisplayerFichierTexte(theProc : MessageAndNumDisplayerProc);
begin
  CustomDisplayMessageWithNum := theProc;
  useStandardConsole := false;
end;

procedure InstalleAlerteFichierTexte(theProc : MessageAndNumDisplayerProc);
begin
  CustomDisplayAlerteWithNum := theProc;
  useStandardConsole := false;
end;

procedure InitUnitFichierTexte;
begin
  SetDebuggageUnitFichiersTexte(false);
  
  (* installation des procedure pour l'affichage de message :
     sur la sortie standard par defaut. On peut installer des
     routines personalisees d'impression de messages et d'alerte 
     juste apres l'appel a InitUnitFichierTexte *)
  InstalleMessageDisplayerFichierTexte(StandardConsoleDisplayer);
  InstalleMessageAndNumDisplayerFichierTexte(StandardConsoleDisplayerWithNum);
  InstalleAlerteFichierTexte(StandardConsoleAlertWithNum);
  useStandardConsole := true;
  
  nomSortieStandardDansRapport := 'Rapport-stdErr-fake-Cassio';
  
  unit_initialisee := true;
end;


function CreeSortieStandardEnFichierTexte(var fic : FichierTEXT) : OSErr;
begin
  if not(unit_initialisee) then InitUnitFichierTexte;
  CreeSortieStandardEnFichierTexte := CreeFichierTexte(nomSortieStandardDansRapport,0,fic);
end;


procedure SetDebuggageUnitFichiersTexte(flag : boolean);
begin
  avecDebuggageUnitFichiersTexte := flag;
end;

function GetDebuggageUnitFichiersTexte() : boolean;
begin
  GetDebuggageUnitFichiersTexte := avecDebuggageUnitFichiersTexte;
end;


end.