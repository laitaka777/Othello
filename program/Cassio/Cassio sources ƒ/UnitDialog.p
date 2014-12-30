UNIT UnitDialog;



INTERFACE







USES MyTypes,UnitSound,UnitMacExtras,Navigation;
  
  const TopDocumentKey=1;
        EntreeKey=3;
        BottomDocumentKey=4;
        HelpAndInsertKey=5;
        RetourArriereKey=8;
        TabulationKey=9;
        LineFeedKey=10;
        PageUpKey=11;
        PageDownKey=12;
        ReturnKey=13;
        EscapeKey=27;
        FlecheGaucheKey=28;
        FlecheDroiteKey=29;
        FlecheHautKey=30;
        FlecheBasKey=31;
        SuppressionKey=127;
        
        VirtualUpdateItemInDialog=1000;
  
  type 
    RadioRec=
        RECORD
          firstbutton : SInt16; 
          lastbutton : SInt16; 
          selection : SInt16; 
        END;
    CheckSet=set of 0..255;
    ChecksRecord=
        RECORD
          firstCheck : SInt16; 
          lastCheck : SInt16; 
          selections:CheckSet;
        END;
    SetOfItemNumber= set of 0..255;
    
    BoutonDrawingProc = procedure(boutonRect : rect;rayonCoins : SInt32);
    
  {
  var EventHandlerPtr:procPtr;
  }
  
  var EventHandler:ProcedureType;
      EventHandlerEstInitialise : boolean;
      FiltreClassiqueUPP : ModalFilterUPP;
      FiltreClassiqueAlerteUPP : ModalFilterUPP;

procedure InitDialogUnit;
procedure LibereMemoireDialogUnit;

procedure ToggleCheck(ch : handle); 
function CheckOn(ch : handle) : boolean;
procedure OutlineOK(dp : DialogPtr);
function IsCheckBoxOn(dp : DialogPtr;ItemNumber : SInt16) : boolean;

procedure GetIntegerEditableText(dp : DialogPtr;ItemNumber : SInt16; var result : SInt16);
procedure SetIntegerEditableText(dp : DialogPtr;ItemNumber : SInt16; value : SInt16);
procedure GetLongintEditableText(dp : DialogPtr;ItemNumber : SInt16; var result : SInt32);
procedure SetLongintEditableText(dp : DialogPtr;ItemNumber : SInt16; value : SInt32);
procedure GetItemTextInDialog(dp : DialogPtr;ItemNumber : SInt16; var s : str255);
procedure SetItemTextInDialog(dp : DialogPtr;ItemNumber : SInt16; s : str255);
procedure GetBoolCheckBox(dp : DialogPtr;ItemNumber : SInt16; var result : boolean);
procedure SetBoolCheckBox(dp : DialogPtr;ItemNumber : SInt16; value : boolean);
function GetCheckBoxValue(dp : DialogPtr;ItemNumber : SInt16) : boolean;
procedure GetBoolRadio(dp : DialogPtr;ItemNumber : SInt16; var result : boolean);
procedure SetBoolRadio(dp : DialogPtr;ItemNumber : SInt16; value : boolean);
procedure ToggleCheckBox(dp : DialogPtr;ItemNumber : SInt16);
procedure HiliteControlInDialog(dp : DialogPtr;itemNumber,hiliteState : SInt16);
procedure GetDialogItemRect(dp : DialogPtr;itemNumber : SInt16; var itemRect : rect);
procedure SetDialogItemRect(dp : DialogPtr;itemNumber : SInt16; itemRect : rect);
procedure GetControlTitleInDialog(dp : DialogPtr;itemNumber : SInt16; var title : str255);
procedure SetControlTitleInDialog(dp : DialogPtr;itemNumber : SInt16; var title : str255);


procedure CenterTextInDialog(dp : DialogPtr;s : str255;ItemNumber : SInt16);
procedure FiltrerChiffreInEditText(dp : DialogPtr;ItemNumber : SInt16);
procedure SetWhiteColorForEditText(dp : DialogPtr;ItemNumber : SInt16);


function Hcenter(width : SInt16) : SInt16; 
function Vcenter(height : SInt16) : SInt16; 

procedure FlashItem(dlog : DialogPtr;ItemNumber : SInt16);
procedure MyInvertRoundRect(theRect : rect;radius : SInt32);
procedure DessineBouton(window : WindowRef;left,top,bottom : SInt16; s : string; var boutonRect : rect);
function AppuieBouton(boutonRect : rect;rayonCoin : SInt16; mouseLoc : Point;drawDownState,drawUpState:BoutonDrawingProc) : boolean;
function GetBoutonRectParControlManager(left,top,bottom,marge : SInt16; title : string) : rect;
procedure DessineBoutonParControlManager(buttonState:ThemeDrawState;left,top,bottom,marge : SInt16; title : string; var boutonRect : rect);
function AppuieBoutonParControlManager(titre : string;boutonRect : rect;marge : SInt16; mouseLoc : Point) : boolean;
procedure DessineBoutonPicture(window : WindowRef;pictureID : SInt32;position : Point; var boutonRect : rect);
function AppuieBoutonPicture(window : WindowRef;boutonNormalPictID,boutonEnfoncePictID : SInt32;boutonRect : rect;mouseLoc : Point) : boolean;


function MakeFileName(var reply : SFReply;prompt : str255; var whichSpec : FSSpec) : boolean;
function GetFileName(var reply : SFReply;fileKind1,fileKind2,fileKind3,fileKind4 : OSType; var whichSpec : FSSpec) : boolean;
function ChooseFolder(prompt : str255; var whichSpec : FSSpec) : boolean;

function NewRadios(PremierBouton,DernierBouton,BoutonSelectione : SInt16) : RadioRec;
procedure PushRadio(dp : DialogPtr; var Radios : RadioRec;itemHit : SInt16);
procedure InitRadios(dp : DialogPtr; var Radios : RadioRec);

procedure CheckBox(dp : DialogPtr; var checks:ChecksRecord;itemHit : SInt16);
procedure InitChecks(dp : DialogPtr; var checks:ChecksRecord);


function FiltreClassique(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
function FiltreClassiqueAlerte(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
function EvenementDuDialogue(dlog : DialogPtr; var evt : eventRecord) : boolean;
{procedure MyDisposeRoutineDescriptor(var theProcPtr:UniversalProcPtr);}
procedure MyDisposeModalFilterUPP(var userUPP: ModalFilterUPP);
procedure MyDisposeControlActionUPP(var userUPP: ControlActionUPP);
procedure InstalleEventHandler(aRoutine:ProcedureType);

procedure IncrementeCompteurDeMouseEvents;
function GetCompteurDeMouseEvents() : SInt32;

function MyAlert(alertID : SInt16; filterProc : ModalFilterUPP;acceptationSet:SetOfItemNumber) : SInt16; 
procedure MyDrawDialog(dp : DialogPtr);


function MyGetNewDialog(dialogID : SInt16; behind : WindowPtr) : DialogPtr;
procedure MyDisposeDialog(var dlog : DialogPtr);

procedure BeginDialog;
procedure EndDialog;
function UnDialogueEstAffiche() : boolean; 


IMPLEMENTATION







USES NavigationServicesIntf,UnitCarbonisation,UnitRapport,MyFileSystemUtils,UnitOth1,UnitProgressBar,
     UnitFenetres,SNStrings,UnitLiveUndo,UnitCouleur;




const avecDialoguesAquatiques = false;

var InfosPourBeginEndDialog:
      record 
        NiveauRecursion : SInt16; 
        PaletteAfficheeAvantBeginDialog : array[0..10] of boolean;
        oldPortBeforeDialog : array[0..10] of GrafPtr; {ceci permet jusqu'à 11 dialogues emboites}
      end;
    
    InfosPourDrawingButton:
      record
        oldClipRegion : RgnHandle;
        buttonRegion  : RgnHandle;
      end;
    
    compteurDeMouseEvents : SInt32;


function inRange2(n,minimum,maximum : SInt32) : boolean;
  begin
    inrange2 := (minimum<=n) & (n<=maximum);
  end;

procedure ToggleCheck(ch : handle);
  var n : SInt16; 
  begin
    n := GetControlValue(ControlHandle(ch));
    if n=0 then n := 1 else n := 0;
    SetControlValue(ControlHandle(ch),n);
  end;

procedure ToggleCheckBox(dp : DialogPtr;ItemNumber : SInt16);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
  begin
    GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
    ToggleCheck(itemHandle);
  end;

function CheckOn(ch : handle) : boolean;
  begin
    CheckOn := GetControlValue(ControlHandle(ch)) <> 0;
  end;
  
function IsCheckBoxOn(dp : DialogPtr;ItemNumber : SInt16) : boolean;
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  IsCheckBoxOn := CheckOn(itemHandle);
end;

procedure GetIntegerEditableText(dp : DialogPtr;ItemNumber : SInt16; var result : SInt16);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
    s : str255;
    aux : SInt32;
begin
  result := 0;
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  GetDialogItemText(itemHandle,s);
  StringToNum(s,aux);
  result := aux;
end;

procedure SetIntegerEditableText(dp : DialogPtr;ItemNumber : SInt16; value : SInt16);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
    s : str255;
    aux : SInt32;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  aux := value;
  NumToString(aux,s);
  SetDialogItemText(itemHandle,s);
end;

procedure GetLongintEditableText(dp : DialogPtr;ItemNumber : SInt16; var result : SInt32);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
    s : str255;
    aux : SInt32;
begin
  result := 0;
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  GetDialogItemText(itemHandle,s);
  StringToNum(s,aux);
  result := aux;
end;

procedure SetLongintEditableText(dp : DialogPtr;ItemNumber : SInt16; value : SInt32);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
    s : str255;
    aux : SInt32;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  aux := value;
  NumToString(aux,s);
  SetDialogItemText(itemHandle,s);
end;



procedure GetBoolCheckBox(dp : DialogPtr;ItemNumber : SInt16; var result : boolean);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  result := GetControlValue(ControlHandle(itemHandle)) <> 0;
end;

function GetCheckBoxValue(dp : DialogPtr;ItemNumber : SInt16) : boolean;
var result : boolean;
begin
  GetBoolCheckBox(dp,ItemNumber,result);
  GetCheckBoxValue := result;
end;

procedure SetBoolCheckBox(dp : DialogPtr;ItemNumber : SInt16; value : boolean);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  if value 
    then SetControlValue(ControlHandle(itemHandle),1)
    else SetControlValue(ControlHandle(itemHandle),0);
end;

procedure GetBoolRadio(dp : DialogPtr;ItemNumber : SInt16; var result : boolean);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  result := GetControlValue(ControlHandle(itemHandle)) <> 0;
end;

procedure SetBoolRadio(dp : DialogPtr;ItemNumber : SInt16; value : boolean);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  if value 
    then SetControlValue(ControlHandle(itemHandle),1)
    else SetControlValue(ControlHandle(itemHandle),0);
end;


procedure GetItemTextInDialog(dp : DialogPtr;ItemNumber : SInt16; var s : str255);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  s := '';
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  GetDialogItemText(itemHandle,s);
end;


procedure SetItemTextInDialog(dp : DialogPtr;ItemNumber : SInt16; s : str255);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  SetDialogItemText(itemHandle,s);
end;

procedure HiliteControlInDialog(dp : DialogPtr;ItemNumber,HiliteState : SInt16);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  HiliteControl(ControlHandle(itemHandle),HiliteState);
end;

procedure GetDialogItemRect(dp : DialogPtr;itemNumber : SInt16; var itemRect : rect);
var itemType : SInt16; 
    itemHandle : handle;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
end;

procedure SetDialogItemRect(dp : DialogPtr;itemNumber : SInt16; itemRect : rect);
var itemType : SInt16; 
    itemHandle : handle;
    oldRect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,oldRect);
  SetDialogItem(dp,ItemNumber,itemType,itemHandle,itemRect);
end;

procedure GetControlTitleInDialog(dp : DialogPtr;itemNumber : SInt16; var title : str255);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  GetControlTitle(ControlHandle(itemHandle),title);
end;

procedure SetControlTitleInDialog(dp : DialogPtr;itemNumber : SInt16; var title : str255);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  SetControlTitle(ControlHandle(itemHandle),title);
end;




procedure CenterTextInDialog(dp : DialogPtr;s : str255;ItemNumber : SInt16);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
    oldport : grafPtr;
    larg : SInt16; 
begin
  GetPort(oldport);
  SetPortByDialog(dp);
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  if (s='') 
    then GetDialogItemText(itemHandle,s)
    else SetDialogItemText(itemHandle,'');
  with QDGetPortBound() do
    larg := itemrect.left-((left+right-StringWidth(s)) div 2);
  EraseRect(itemRect);
  OffsetRect(itemrect,-larg,0);
  SetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  if (s<>'') then SetDialogItemText(itemHandle,s);
  SetPort(oldport);
end;

procedure FiltrerChiffreInEditText(dp : DialogPtr;ItemNumber : SInt16);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
    s,s1 : str255;
    unlong : SInt32;
begin
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  GetDialogItemText(itemHandle,s);
  s1 := SeulementLesChiffres(s);
  if Length(s1)>0 then
    begin
      StringToNum(s1,unlong);
      NumToString(unlong,s1);
      if (unlong=0) & (Length(s1)=0) then s1 := '';
    end;
  if s1<>s then SetDialogItemText(itemhandle,s1);
    
  if avecDialoguesAquatiques & gIsRunningUnderMacOSX 
    then SetWhiteColorForEditText(dp,ItemNumber);
    
  
end;

procedure SetWhiteColorForEditText(dp : DialogPtr;ItemNumber : SInt16);
var oldport : grafPtr;
    itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
    state : ThemeDrawingState;
    err : OSStatus;
begin

  GetPort(oldport);
  SetPortByDialog(dp);
  GetDialogItem(dp,ItemNumber,itemType,itemHandle,itemrect);
  
  err := GetThemeDrawingState(state);
	err := NormalizeThemeDrawingState();
	
	{err := SetThemeBackground(kThemeBrushFinderWindowBackground,ProfondeurMainDevice(),true);}
	InSetRect(itemRect,-1,-1);
	ClipRect(itemrect);
	EraseRect(itemrect);
	DrawDialog(dp);
  {
  err := SetThemeWindowBackground(GetDialogWindow(dp),kThemeBrushMovableModalBackground,true); 
  }
  err := SetThemeDrawingState( state, true );
  ClipRect(GetWindowPortRect(GetDialogWindow(dp)));
  {
  err := SetThemeWindowBackground(GetDialogWindow(dp),kThemeBrushMovableModalBackground,true); 
  }
  SetPort(oldPort);
end;

procedure OutlineOK(dp : DialogPtr);
  var oldport : grafPtr;
      itemType : SInt16; 
      itemHandle : handle;
      itemrect : rect;
      oldPen:penState;
      err : OSErr;
  begin
    GetPort(oldport);
    SetPortByDialog(dp);
    
    if gIsRunningUnderMacOSX
      then
        err := SetDialogDefaultItem(dp,1)
      else
		    begin
		      GetDialogItem(dp,1,itemtype,itemhandle,itemrect);
			    if itemHandle <> NIL then
				    begin
				      GetPenState(oldpen);
				      PenPat(blackPattern);
				      PenSize(3,3);
				      InsetRect(itemrect,-4,-4);
				      FrameRoundRect(itemrect,16,16);
				      SetPenState(oldpen);
				    end;
				end;
    
    SetPort(oldport);
  end;



function Hcenter(width : SInt16) : SInt16; 
begin
    Hcenter := (GetScreenBounds().right-width) div 2;
end;

function Vcenter(height : SInt16) : SInt16; 
begin
    Vcenter := (GetScreenBounds().bottom-height) div 2;
end;




function MakeFileNameSansNavigationServices(var reply : SFReply;prompt : str255; var whichSpec : FSSpec) : boolean;
const
  DlogWidth=304;
  Dlogheight=184;
var where : Point;
    s : str255;
    erreurES : OSErr;
begin
  
  erreurES := NoErr;
  
  s := 'sans nom';
  s := reply.fname;
  SetPt(where,Hcenter(DlogWidth),Vcenter(Dlogheight));
  MySFPutFile(where,@prompt,s,NIL,reply);
  
  (*  Je ne sais pas si il est necessaire d'appeler SetVol sous Carbon *)
  (* 
  if reply.good then 
    erreurES := SetVol(NIL,reply.vrefNum);
  *)
  
  (*
  with reply do
    begin
	    WritelnStringAndNumDansRapport('erreurES = ',erreurES);
	    WritelnStringAndBoolDansRapport('good = ',good);
	    WritelnStringAndBoolDansRapport('copy = ',copy);
	    WritelnStringAndNumDansRapport('vRefNum = ',vRefNum);
	    WritelnStringAndNumDansRapport('version = ',version);
	    WritelnDansRapport('fName = '+fName);
    end;
  *)
  
  whichSpec := MyMakeFSSpec(reply.vRefNum, 0, reply.fname);
  
  MakeFileNameSansNavigationServices := reply.good & (erreurES = NoErr);
end;



function MakeFileName(var reply : SFReply;prompt : str255; var whichSpec : FSSpec) : boolean;
{$IFC CARBONISATION_DE_CASSIO}
  var fileSpec : FSSpec;
      erreurES : OSStatus;
      stationery : boolean;
      replacing : boolean;
      navReply:NavReplyRecord;
      s,fullPath : str255;
      bidErr : OSErr;
  begin
    
    (*
    if not(gIsRunningUnderMacOSX)
      then
        begin
          erreurES := -1;
          if MakeFileNameSansNavigationServices(reply, prompt, whichSpec) 
			      then erreurES := NoErr;
        end
      else *)
        begin
			    erreurES := NoErr;
			    s := reply.fName;
			    
			    erreurES := SaveFileDialog(@s,@prompt,'SNXM','TEXT', fileSpec, stationery ,replacing, navReply);
			    
			    if (erreurES <> NoErr) & debuggage.entreesSortiesUnitFichiersTEXT
			      then WritelnStringAndNumDansRapport('MakeFileName : erreurES = ',erreurES);
			    
			    whichSpec := fileSpec;
			    
			    if navReply.validRecord
			      then bidErr := FSSpecToFullPath(fileSpec,fullPath);
			    
			    if navReply.validRecord & replacing 
			      then bidErr := FSpDelete(fileSpec);
			    
			    with reply do
			      begin
			        good    := navReply.validRecord;
			        copy    := false;
			        fType   := 'TEXT';
			        version := 0;
			        
			        vRefNum := fileSpec.vRefNum;
			        fName   := fileSpec.name;
			        
			        {
			        WritelnStringAndNumDansRapport('erreurES = ',erreurES);
			        WritelnStringAndBoolDansRapport('good = ',good);
			        WritelnStringAndBoolDansRapport('copy = ',copy);
			        WritelnStringAndNumDansRapport('version = ',version);
			        WritelnStringAndNumDansRapport('fileSpec.vRefNum = ',vRefNum);
			        WritelnStringAndNumDansRapport('fileSpec.parID = ',fileSpec.parID);
			        WritelnDansRapport('fileSpec.fName = '+fName);
			        WritelnDansRapport('fullPath = '+fullPath);
			        }
			        
			      end;
			    
			    (* Hack désespéré : si l'appel normal utilisant les Navigation Services
			       s'est mal déroulé, on essaye les routines du système 7...            *)
			    if not(MyNavServicesAvailable()) & not(gIsRunningUnderMacOSX) then
			      begin
			        if MakeFileNameSansNavigationServices(reply, prompt, whichSpec) 
			          then erreurES := NoErr;
			      end;
			  end;
    
    MakeFileName := reply.good & (erreurES = NoErr);
  end;

{$ELSEC}
  begin
    MakeFileName := MakeFileNameSansNavigationServices(reply,prompt,whichSpec);
  end;
{$ENDC}


function DoChooseAFolderDialog(prompt : str255; var theFileSpec : FSSpec) : OSErr;
var
  dialogOptions : NavDialogOptions;
  navEventFunctionUPP : NavEventUPP;
  osError : OSErr;
  theNavReply : NavReplyRecord;
  fileSpec : FSSpec;
  resultDesc : AEDesc;
  defaultLocation : AEDesc;
  ignoredErr : OSErr;
begin
  
  osError := NavGetDefaultDialogOptions(dialogOptions);
  dialogOptions.message := prompt;
  navEventFunctionUPP := NewNavEventUPP(MyNavEventProc);
  
  defaultLocation.descriptorType := FourCharCode(UInt32(0));
  defaultLocation.dataHandle := NIL;
  
  osError := NavChooseFolder(NIL{@defaultLocation}, theNavReply, @dialogOptions, navEventFunctionUPP,nil, nil);
  
  DisposeNavEventUPP(navEventFunctionUPP);
  if (theNavReply.validRecord and (osError = noErr)) then
    begin
      osError := AECoerceDesc(theNavReply.selection, typeFSS, resultDesc);
      if (osError = noErr) then
        begin
          BlockMoveData(resultDesc.dataHandle^, @fileSpec, sizeof(FSSpec));
          ignoredErr := FSMakeFSSpec(fileSpec.vRefNum, fileSpec.parID ,fileSpec.name,theFileSpec);
        end;
      ignoredErr := AEDisposeDesc(resultDesc);
      ignoredErr := NavDisposeReply(theNavReply);
    end;
  DoChooseAFolderDialog := osError;
end; { of function DoChooseAFolderDialog }



function ChooseFolder(prompt : str255; var whichSpec : FSSpec) : boolean;
var erreurES : OSStatus;
begin
  if not(MyNavServicesAvailable())
    then ChooseFolder        := false
    else
      begin
        erreurES := DoChooseAFolderDialog(prompt,whichSpec);
        ChooseFolder := (erreurES = noErr);
      end;
end;



function GetFileNameSansNavigationServices(var reply : SFReply;fileKind1,fileKind2,fileKind3,fileKind4 : OSType; var whichSpec : FSSpec) : boolean;
const
  DlogWidth=348;
  Dlogheight=200;
var where : Point;
    typelist:SFTypeList;
    str : str255;
    n : SInt16; 
    erreurES : OSErr;
begin

  erreurES := NoErr;

  SetPt(where,Hcenter(dlogwidth),Vcenter(dlogheight));
  n := 0;
  if fileKind1<>'????' then 
    begin
      typelist[n] := filekind1;
      inc(n);
    end;
  if fileKind2<>'????' then 
    begin
      typelist[n] := filekind2;
      inc(n);
    end;
  if fileKind3<>'????' then 
    begin
      typelist[n] := filekind3;
      inc(n);
    end;
  if fileKind4<>'????' then 
    begin
      typelist[n] := filekind4;
      inc(n);
    end;
  str := 'sans nom';
  if fileKind1='????'
    then MySFGetFile(where,str,NIL,-1,@typelist,NIL,reply)
    else MySFGetFile(where,str,NIL,n,@typelist,NIL,reply);
  
  (*
  if reply.good then
    erreurES := SetVol(NIL,reply.vrefNum);
  *)
  
  whichSpec := MyMakeFSSpec(reply.vRefNum, 0, reply.fname);
    
  GetFileNameSansNavigationServices := reply.good & (erreurES = NoErr);
end;


function GetFileName(var reply : SFReply;fileKind1,fileKind2,fileKind3,fileKind4 : OSType; var whichSpec : FSSpec) : boolean;
{$IFC CARBONISATION_DE_CASSIO}
  var typelist:SFTypeList;
      n : SInt16; 
      erreurES : OSStatus;
  begin
  
    BeginDialog;
    
    (*
    if not(gIsRunningUnderMacOSX)
      then 
        begin
          erreurES := -1;
          if GetFileNameSansNavigationServices(reply,fileKind1,fileKind2,fileKind3,fileKind4,whichSpec) then 
	          if reply.good then erreurES := NoErr;
        end
      else *)
        begin
			    n := 0;
			    if fileKind1<>'????' then 
			      begin
			        typelist[n] := filekind1;
			        inc(n);
			      end;
			    if fileKind2<>'????' then 
			      begin
			        typelist[n] := filekind2;
			        inc(n);
			      end;
			    if fileKind3<>'????' then 
			      begin
			        typelist[n] := filekind3;
			        inc(n);
			      end;
			    if fileKind4<> '????' then 
			      begin
			        typelist[n] := filekind4;
			        inc(n);
			      end;
			    erreurES := OpenOneFileDialog('SNX4',n,@typelist,whichSpec);
			    
			    if (erreurES <> NoErr) & debuggage.entreesSortiesUnitFichiersTEXT
			      then WritelnStringAndNumDansRapport('GetFileName : erreurES = ',erreurES);
			    
			    (* Hack désespéré : si l'appel normal utilisant les Navigation Services
             s'est mal déroulé, on essaye les routines du système 7...            *)
			    if not(MyNavServicesAvailable()) & not(gIsRunningUnderMacOSX) then
			      begin
			        if GetFileNameSansNavigationServices(reply,fileKind1,fileKind2,fileKind3,fileKind4,whichSpec) then 
			          if reply.good
			            then erreurES := NoErr
			            else erreurES := -1;
			      end;
			  end;
    
    if (erreurES <> NoErr)
      then
        begin
          reply.good := false;
          reply.fName := '';
          GetFileName := false; 
        end
      else
        begin
          reply.good := true;
          reply.fName := whichSpec.name;
          GetFileName := true; 
        end;
    
    EndDialog;
  end;
{$ELSEC}
  begin
    BeginDialog;
    GetFileName := GetFileNameSansNavigationServices(reply,fileKind1,fileKind2,fileKind3,fileKind4,whichSpec);
    EndDialog;
  end;
{$ENDC}


function NewRadios(PremierBouton,DernierBouton,BoutonSelectione : SInt16) : RadioRec;
var aux : RadioRec;
begin
  with aux do
    begin
      firstButton := PremierBouton;
      lastButton := DernierBouton;
      selection := BoutonSelectione;
      if selection<firstButton then selection := firstButton;
      if selection>lastButton then selection := lastButton;
    end;
  NewRadios := aux;
end;

procedure PushRadio(dp : DialogPtr; var Radios : RadioRec;itemHit : SInt16);
  var itemType : SInt16; 
      itemHandle : handle;
      itemrect : rect;
  begin
    with Radios do
      if inrange2(itemHit,firstButton,lastButton) then
        begin
          if inrange2(selection,firstButton,lastButton) then
          begin
            GetDialogItem(dp,selection,itemtype,itemhandle,itemrect);
            SetControlValue(ControlHandle(itemhandle),0);
          end;
          GetDialogItem(dp,itemHit,itemtype,itemhandle,itemrect);
          SetControlValue(ControlHandle(itemhandle),1);
          selection := itemHit;
        end;
  end;
  
procedure InitRadios(dp : DialogPtr; var Radios : RadioRec);
  begin
    PushRadio(dp,Radios,Radios.selection);
  end;

procedure CheckBox(dp : DialogPtr; var checks:ChecksRecord;itemHit : SInt16);
  var itemType : SInt16; 
  itemhandle : handle;
  itemrect : rect;
  begin
    with checks do
      if inrange2(itemHit,firstCheck,lastCheck) then
      begin
        GetDialogItem(dp,itemHit,itemType,itemHandle,itemrect);
        ToggleCheck(itemhandle);
        if CheckOn(itemHandle)
          then selections := selections+[itemHit]
          else selections := selections-[itemHit];
      end;
  end;

procedure InitChecks(dp : DialogPtr; var checks:ChecksRecord);
  var checkNumber : SInt16; 
  begin
    with checks do
      for checkNumber := firstCheck to lastCheck do
        if checkNumber in selections
          then CheckBox(dp,checks,checkNumber);
  end;

procedure FlashItem(dlog : DialogPtr;ItemNumber : SInt16);
var itemType : SInt16; 
    itemHandle : handle;
    itemrect : rect;
    finalticks : UInt32;
begin
   GetDialogItem(dlog,ItemNumber,itemType,itemHandle,itemrect);
   HiliteControl(ControlHandle(itemHandle),1);
   Delay(7,finalticks);
   HiliteControl(ControlHandle(itemHandle),0);
end;


function FiltreClassique(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
var codeEvt : SInt16; 
    limiteRect : rect;
    whichWindow : WindowRef;
    standardProc : ModalFilterUPP;
    err : OSErr;
begin
  FiltreClassique := false;
  if not(EvenementDuDialogue(dlog,evt)) 
    then
      begin
        if (evt.what = UpdateEvt) then
          if EventHandlerEstInitialise then
            begin
              theEvent := evt;
              EventHandler;
              FiltreClassique := true;
              item := -10;
              exit(FiltreClassique);
            end;
        if (evt.what = mouseDown) then
          begin
            IncrementeCompteurDeMouseEvents;
            codeEvt := FindWindow(evt.where,whichWindow);
            if codeEvt=InMenuBar then
              if EventHandlerEstInitialise then
              begin
                theEvent := evt;
                EventHandler;
                FiltreClassique := true;
                item := -10;
                exit(FiltreClassique);
              end;
          end;
        if (evt.what = mouseUp) then EndLiveUndo;
      end
    else
      case evt.what of
        keyDown,autoKey :
          with evt do
          if (BAND(message,charcodemask)=ReturnKey) |
             (BAND(message,charcodemask)=EntreeKey) 
            then
              begin
                item := 1;
                FlashItem(dlog,item);
                FiltreClassique := true;
              end
            else 
              if (BAND(message,charcodemask)=EscapeKey) |
                 ((BAND(message,charcodemask)=ord('.')) & (BAND(modifiers,cmdKey) <> 0))
                then
                  begin
                    item := 2;
                    FlashItem(dlog,item);
                    FiltreClassique := true;
                  end;
        updateEvt : 
          begin
            SetPortByDialog(dlog);
            OutlineOK(dlog);
          end;
        mouseDown :
          begin
            IncrementeCompteurDeMouseEvents;
            codeEvt := FindWindow(evt.where,whichWindow);
            if codeEvt=InDrag then
              begin
                SetRect(limiteRect,-20000,20,20000,20000);
                DragWindow(whichWindow,evt.where,@limiteRect);
                FiltreClassique := true;
              end;
          end;
        otherwise
          begin
            err := GetStdFilterProc(standardProc);
            FiltreClassique := InvokeModalFilterUPP(dlog,evt,item,standardProc);
          end;
      end {case}
end;

function FiltreClassiqueAlerte(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
var codeEvt : SInt16; 
    limiteRect : rect;
    whichWindow : WindowRef;
    standardProc : ModalFilterUPP;
    err : OSErr;
begin
  FiltreClassiqueAlerte := false;
  if not(EvenementDuDialogue(dlog,evt)) 
    then
      begin
        if evt.what=UpdateEvt then
          if EventHandlerEstInitialise then
            begin
              theEvent := evt;
              EventHandler;
              FiltreClassiqueAlerte := false;
              item := -10;
              exit(FiltreClassiqueAlerte);
            end;
        if (evt.what = mouseDown) then 
          begin
            IncrementeCompteurDeMouseEvents;
            SysBeep(0);
          end;
      end
    else
      case evt.what of
        keyDown,autoKey :
          with evt do
          if (BAND(message,charcodemask)=ReturnKey) |
             (BAND(message,charcodemask)=EntreeKey) 
            then
              begin
                item := 1;
                FlashItem(dlog,item);
                FiltreClassiqueAlerte := true;
              end
            else 
              if (BAND(message,charcodemask)=EscapeKey) |
                 ((BAND(message,charcodemask)=ord('.')) & (BAND(modifiers,cmdKey) <> 0))
                then
                  begin
                    item := 2;
                    FlashItem(dlog,item);
                    FiltreClassiqueAlerte := true;
                  end;
        updateEvt : 
          begin
            SetPortByDialog(dlog);
            OutlineOK(dlog);
          end;
        mouseDown :
          begin
            IncrementeCompteurDeMouseEvents;
            codeEvt := FindWindow(evt.where,whichWindow);
            if codeEvt=InDrag then
              begin
                SetRect(limiteRect,-20000,20,20000,20000);
                DragWindow(whichWindow,evt.where,@limiteRect);
                FiltreClassiqueAlerte := true;
              end;
          end;
        otherwise
          begin
            err := GetStdFilterProc(standardProc);
            FiltreClassiqueAlerte := InvokeModalFilterUPP(dlog,evt,item,standardProc);
          end;
      end {case}
end;



procedure DessineBouton(window : WindowRef;left,top,bottom : SInt16; s : string; var boutonRect : rect);
var a : SInt16; 
    haut : SInt16; 
    hautReduite : boolean;
begin {$UNUSED window}

  haut := 12;
  hautReduite := false;
  if haut>(bottom-top)-5
    then 
      begin
        haut := bottom-top-5;
        hautReduite := true;
      end;
  TextSize(haut);  
  
  if (TrebuchetMSID <> 0) & gIsRunningUnderMacOSX
    then 
      begin
        TextFont(TrebuchetMSID);
        TextFace(bold);
      end
    else 
      begin
        TextFont(systemFont);
        TextFace(normal);
      end;
  
  TextMode(srcOr);
  a := StringWidth(s);
  SetRect(BoutonRect,left,top,left+16+a,bottom);
  
  FillRoundRect(BoutonRect,13,13,whitePattern);
  {FrameRoundRect(BoutonRect,13,13);}
  if not(hautreduite) 
    then Moveto(left+8,bottom-5)
    else Moveto(left+8,bottom-3);
  DrawString(s);
 
end;


procedure MyInvertRoundRect(theRect : rect;radius : SInt32);
begin
  InvertRoundRect(theRect,radius,radius);
end;


function AppuieBouton(boutonRect : rect;rayonCoin : SInt16; mouseLoc : Point;drawDownState,drawUpState:BoutonDrawingProc) : boolean;
var resultat,testdedans : boolean;
begin
  resultat := false;
  if PtInRect(mouseLoc,boutonRect) then
    begin
      resultat := true;
      drawDownState(boutonRect,rayonCoin);
      if not(Button())
       then drawUpState(boutonRect,rayonCoin)
       else
         begin
           while Button() do
             begin
               GetMouse(mouseLoc);           
               testDedans := PtInRect(mouseLoc,boutonRect);
               if resultat & not(testDedans) then
                 begin
                   resultat := false;
                   drawUpState(boutonRect,rayonCoin);
                 end;
               if not(resultat) & testDedans then
                 begin
                   resultat := true;
                   drawDownState(boutonRect,rayonCoin);
                 end;
               ShareTimeWithOtherProcesses(2);
             end;         
           if resultat then drawUpState(boutonRect,rayonCoin);
           GetMouse(mouseLoc);
           resultat := PtInRect(mouseLoc,boutonRect);
         end;
    end;
  ShareTimeWithOtherProcesses(2);
  AppuieBouton := resultat;
end;


function GetBoutonRectParControlManager(left,top,bottom,marge : SInt16; title : string) : rect;
var boutonRect : rect;
    a : SInt16; 
begin
  TextSize(12);  
  TextFont(systemFont);
  TextFace(normal);
  a := StringWidth(title);
  SetRect(boutonRect,left,top,left+marge+a,bottom);
  
  GetBoutonRectParControlManager := boutonRect;
end;


procedure DessineBoutonParControlManager(buttonState:ThemeDrawState;left,top,bottom,marge : SInt16; title : string; var boutonRect : rect);
var a : SInt16; 
    myRect : rect;
    buttonTitle: CFStringRef;
    err : OSStatus;
    inNewInfo:ThemeButtonDrawInfo;
begin 

  TextSize(12);  
  TextFont(systemFont);
  TextFace(normal);
  a := StringWidth(title);
  SetRect(boutonRect,left,top,left+marge+a,bottom);
  
  myRect := boutonRect;
    
  buttonTitle := MakeCFSTR(title);
  
  with inNewInfo do
    begin
      state     := buttonState;          {kThemeStateActive or kThemeStatePressed}
      value     := kThemeButtonOn;
      adornment := kThemeAdornmentNone;
    end;
      
  err := DrawThemeButton(myRect,kThemePushButton,inNewInfo,NIL,NIL,NIL,0);
  OffSetRect(myRect,0, 2);
  err := DrawThemeTextBox(buttonTitle,kThemeSystemFont,kThemeStateActive,false,myRect,teJustCenter,NIL);
 
  CFRelease(CFTypeRef(buttonTitle));
end;


function AppuieBoutonParControlManager(titre : string;boutonRect : rect;marge : SInt16; mouseLoc : Point) : boolean;
var pressed,testdedans : boolean;
    
    
  procedure DessineBoutonLocal(pressed : boolean);
  var state:ThemeDrawState;
  begin
    if pressed
      then state := kThemeStatePressed
      else state := kThemeStateActive;
    with boutonRect do
      DessineBoutonParControlManager(state,left,top,bottom,marge,titre,boutonRect);
  end;
    
    
begin
  pressed := false;
  if PtInRect(mouseLoc,boutonRect) then
    begin
      pressed := true;
      DessineBoutonLocal(true);      
      if not(Button())
       then DessineBoutonLocal(false)
       else
         begin
           while Button() do
             begin
               GetMouse(mouseLoc);           
               testDedans := PtInRect(mouseLoc,boutonRect);
               if pressed & not(testDedans) then
                 begin
                   pressed := false;
                   DessineBoutonLocal(false);
                 end;
               if not(pressed) & testDedans then
                 begin
                   pressed := true;
                   DessineBoutonLocal(true);
                 end;
               ShareTimeWithOtherProcesses(2);
             end;         
           if pressed then DessineBoutonLocal(false);
           GetMouse(mouseLoc);
           pressed := PtInRect(mouseLoc,boutonRect);
         end;
    end;
  ShareTimeWithOtherProcesses(2);
  AppuieBoutonParControlManager := pressed;
end;



procedure DessineBoutonPicture(window : WindowRef;pictureID : SInt32;position : Point; var boutonRect : rect);
var boutonPicture:picHandle;
begin {$UNUSED window}
  boutonPicture := GetPicture(pictureID);
  boutonRect := boutonPicture^^.picframe;
  OffsetRect(boutonRect,position.h,position.v);
  DrawPicture(boutonPicture,boutonRect);
  ReleaseResource(Handle(boutonPicture));
end;


function AppuieBoutonPicture(window : WindowRef;boutonNormalPictID,boutonEnfoncePictID : SInt32;boutonRect : rect;mouseLoc : Point) : boolean;
var resultat,testdedans : boolean;
    unRect : rect;
begin 
  resultat := false;
  if PtInRect(mouseLoc,boutonRect) then
    begin
      resultat := true;
      DessineBoutonPicture(window,boutonEnfoncePictID,boutonRect.topleft,unRect);
      if not(Button())
       then DessineBoutonPicture(window,boutonNormalPictID,boutonRect.topleft,unRect)
       else
         begin
           while Button() do
             begin
               GetMouse(mouseLoc);           
               testDedans := PtInRect(mouseLoc,boutonRect);
               if resultat & not(testDedans) then
                 begin
                   resultat := false;
                   DessineBoutonPicture(window,boutonNormalPictID,boutonRect.topleft,unRect);
                 end;
               if not(resultat) & testDedans then
                 begin
                   resultat := true;
                   DessineBoutonPicture(window,boutonEnfoncePictID,boutonRect.topleft,unRect);
                 end;
               ShareTimeWithOtherProcesses(2);
             end;         
           if resultat then DessineBoutonPicture(window,boutonEnfoncePictID,boutonRect.topleft,unRect);
           GetMouse(mouseLoc);
           resultat := PtInRect(mouseLoc,boutonRect);
         end;
    end;
  ShareTimeWithOtherProcesses(2);
  AppuieBoutonPicture := resultat;
end;



function EvenementDuDialogue(dlog : DialogPtr; var evt : eventRecord) : boolean;
var codeEvt : SInt16; 
    whichWindow : WindowRef;
    oldPort : grafPtr;
    process:ProcessSerialNumber;
    err : OSErr;
    activate : boolean;
begin
  if FrontWindow() = NIL 
    then EvenementDuDialogue := false
    else 
      begin
        GetPort(oldPort);
        SetPortByDialog(dlog);
        case evt.what of
          mouseDown : begin
                        IncrementeCompteurDeMouseEvents;
                        codeEvt := FindWindow(evt.where,whichWindow);
                        if (whichWindow=GetDialogWindow(dlog))
                          then 
                            begin
                              EvenementDuDialogue := true;
                              { Make us the front process : this brings all the windows to the front }
                              if (GetCurrentProcess(process) = NoErr) then
                                err := SetFrontProcess(process);
                            end
                          else
                            begin
                              EvenementDuDialogue := false;
                            end;
                      end;
          updateEvt : begin
                        whichWindow := WindowPtr(evt.message);
                        EvenementDuDialogue := (whichWindow=GetDialogWindow(dlog));
                      end;
          activateEvt : begin
                          whichWindow := WindowPtr(evt.message);
                          activate := BAND(evt.modifiers,activeflag) <> 0;
                          
                          { Make us the front process : this brings all the windows to the front }
                          if activate & (GetCurrentProcess(process) = NoErr) then
                            err := SetFrontProcess(process);
                            
                          EvenementDuDialogue := IsDialogEvent(evt);
                        end;
          otherwise   begin
                        EvenementDuDialogue := IsDialogEvent(evt);
                      end;
        end; {case}
        SetPort(oldPort);
      end;
end;

{
procedure MyDisposeRoutineDescriptor(var theProcPtr:UniversalProcPtr);
begin
  if theProcPtr <> NIL then 
    begin
      DisposeRoutineDescriptor(theProcPtr);
      theProcPtr := NIL;
    end;
end;
}

procedure MyDisposeModalFilterUPP(var userUPP: ModalFilterUPP);
begin
  if userUPP <> NIL then 
    begin
      DisposeModalFilterUPP(userUPP);
      userUPP := NIL;
    end;
end;


procedure MyDisposeControlActionUPP(var userUPP: ControlActionUPP);
begin
  if userUPP <> NIL then 
    begin
      DisposeControlActionUPP(userUPP);
      userUPP := NIL;
    end;
end;




procedure BidProc;
begin
end;

procedure InitDialogUnit;  
var k : SInt32;
begin
  EventHandlerEstInitialise := false;
  EventHandler := BidProc;
  FiltreClassiqueUPP := NewModalFilterUPP(@FiltreClassique);
  FiltreClassiqueAlerteUPP := NewModalFilterUPP(@FiltreClassiqueAlerte);
  
  compteurDeMouseEvents := 0;
  
  InfosPourBeginEndDialog.NiveauRecursion := -1;
  for k := 0 to 10 do
    InfosPourBeginEndDialog.PaletteAfficheeAvantBeginDialog[k] := false;
   
end;

procedure LibereMemoireDialogUnit;
begin
  MyDisposeModalFilterUPP(FiltreClassiqueUPP);
  MyDisposeModalFilterUPP(FiltreClassiqueAlerteUPP);
end;

procedure InstalleEventHandler(aRoutine:ProcedureType);
begin
  EventHandlerEstInitialise := true;
  EventHandler := aRoutine;
end;


procedure IncrementeCompteurDeMouseEvents;
begin
  inc(compteurDeMouseEvents);
  if (compteurDeMouseEvents < 1) then compteurDeMouseEvents := 1;
  EndLiveUndo;
end;


function GetCompteurDeMouseEvents() : SInt32;
begin
  GetCompteurDeMouseEvents := compteurDeMouseEvents;
end;


function MyAlert(alertID : SInt16; filterProc : ModalFilterUPP;acceptationSet:SetOfItemNumber) : SInt16; 
var item : SInt16; 
begin
 repeat
    item := Alert(alertID,filterProc);
  until (item = -1) | (item in acceptationSet); 
  MyAlert := item;
end;


procedure MyDrawDialog(dp : DialogPtr);
var state : ThemeDrawingState;
    err : OSStatus;
    zoneGrisee : Rect;
    zoneNonGrisee : Rect;
    oldPort : grafPtr;
begin  {$UNUSED zoneGrisee}
  
  GetPort(oldPort);
	SetPort(GetDialogPort(dp));
	
	
	if avecDialoguesAquatiques & gIsRunningUnderMacOSX
	  then
	    begin
				err := GetThemeDrawingState(state);
				
				(* d'abord on dessine le bas du dialogue du dialogue, avec le theme Aqua *)
				zoneNonGrisee := MakeRect(-2,57, QDGetPortBound().right+2, QDGetPortBound().bottom+2);
			  ClipRect(zoneNonGrisee);
			  DrawDialog(dp);
			  
				(* puis on dessine le ruban blanc en haut du dialogue *)
				zoneGrisee := MakeRect(-2,-2, QDGetPortBound().right+2, 55);
				err := NormalizeThemeDrawingState();
				 
				ClipRect(zoneGrisee);
				EraseRect(zoneGrisee);
				RGBForeColor(EclaircirCouleurDeCetteQuantite(gPurNoir,50000));
			  FrameRect(zoneGrisee); 
				RGBForeColor(gPurNoir);
				
				err := NormalizeThemeDrawingState();
			  DrawDialog(dp);
			  ClipRect(GetWindowPortRect(GetDialogWindow(dp)));
			  err := SetThemeDrawingState( state, true );
			end
	  else
	    DrawDialog(dp);
  
  SetPort(oldPort);
end;




function MyGetNewDialog(dialogID : SInt16; behind : WindowPtr) : DialogPtr;
var dp : DialogPtr;
    {systemFont : SInt32;}
    err : OSStatus;
    state : ThemeDrawingState;
begin  {$UNUSED state}
  dp := GetNewDialog(dialogID,NIL,behind);
  if (dp <> NIL) then
    begin
      if PaletteEstSurCeDialogue(dp) & IsWindowVisible(wPalettePtr) & 
         InfosPourBeginEndDialog.PaletteAfficheeAvantBeginDialog[InfosPourBeginEndDialog.NiveauRecursion] 
        then ShowHide(wPalettePtr,false);
         
      InitCursor;
      SetPortByDialog(dp);
      EnableQuartzAntiAliasingThisPort(GetDialogPort(dp),true);
       
      
      if avecDialoguesAquatiques & gIsRunningUnderMacOSX then
        begin
		      {err := SetThemePen(kThemeTextColorBlack,ProfondeurMainDevice(),true);
		      err := SetThemeTextColor(kThemeTextColorBlack,ProfondeurMainDevice(),true);
		      err := GetThemeDrawingState(state);}
		      err := SetThemeWindowBackground(GetDialogWindow(dp),kThemeBrushMovableModalBackground,true); 
		      {err := SetThemeBackground(kThemeBrushMovableModalBackground,ProfondeurMainDevice(),true);
		      err := SetThemeDrawingState( state, true );}
		      if IsWindowVisible(GetDialogWindow(dp)) then MyDrawDialog(dp);
        end;
      
      OutlineOK(dp);
    end;
  MyGetNewDialog := dp;
end;




procedure MyDisposeDialog(var dlog : DialogPtr);
begin
  if dlog <> NIL then DisposeDialog(dlog);
  dlog := NIL;
  EssaieSetPortWindowPlateau;
end;


procedure BeginDialog;
var whichWindow : WindowRef;
begin
  with InfosPourBeginEndDialog do
    begin
      EnableQuartzAntiAliasing(true);
      inc(NiveauRecursion);
			GetPort(oldPortBeforeDialog[NiveauRecursion]);
			whichWindow := FrontWindowSaufPalette();
			if whichWindow <> NIL then
			  begin
			    HiliteWindow(whichWindow,false);
			    DoActivateWindow(whichWindow,false);
			    InitCursor;
			  end;
			
			if windowPaletteOpen & (wPalettePtr <> NIL) & IsWindowVisible(wPalettePtr) then
			  begin
			    PaletteAfficheeAvantBeginDialog[NiveauRecursion] := true;
			    
			  end;
	 end;
end;

procedure EndDialog;
var whichWindow : WindowRef;
begin
   with InfosPourBeginEndDialog do
    begin
		  whichWindow := FrontWindowSaufPalette();
		  if whichWindow <> NIL then
		    begin
		      HiliteWindow(whichWindow,true);
		      DoActivateWindow(whichWindow,true);
		    end;
		  if EssaieUpdateEventsWindowPlateauProcEstInitialise
		    then EssaieUpdateEventsWindowPlateauProc;
		  AjusteCurseur;
		  DrawMenuBar;
		  
		  {on remet eventuellement la palette}
		  if (wPalettePtr <> NIL) & PaletteAfficheeAvantBeginDialog[NiveauRecursion] then
		    ShowHide(wPalettePtr,true);
		  {et on reinitialise le boolean pour la prochaine fois}
		  PaletteAfficheeAvantBeginDialog[NiveauRecursion] := false;
		  
		  SetPort(oldPortBeforeDialog[NiveauRecursion]);
		  if not(UnDialogueEstAffiche()) & not(gCassioUseQuartzAntialiasing) 
		    then DisableQuartzAntiAliasing;
		    
		  dec(NiveauRecursion);
		end;
end;


function UnDialogueEstAffiche() : boolean;
begin
  UnDialogueEstAffiche := (InfosPourBeginEndDialog.NiveauRecursion >= 0)
end;


end.
