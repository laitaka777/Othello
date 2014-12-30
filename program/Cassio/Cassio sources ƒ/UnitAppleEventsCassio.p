UNIT UnitAppleEventsCassio;


INTERFACE







USES UnitMacExtras,GestaltEqu,AppleEvents;


var  gHasAppleEvents : boolean;

     gHandleOAppUPP : AEEventHandlerUPP;
     gHandleDocUPP  : AEEventHandlerUPP;
     gHandleQuitUPP : AEEventHandlerUPP;


procedure InitUnitAppleEventsCassio;
procedure CheckAppleEvents;
function GotRequiredParameters(var theAppleEvent:AppleEvent) : OSErr;
function HandleOpenApplicationAppleEvent(var theAppleEvent, reply: AppleEvent; refCon: SInt32): OSErr;
function HandleDocumentAppleEvent(var theAppleEvent,reply:AppleEvent; refCon : SInt32) : OSErr;
function HandleQuitApplicationAppleEvent (var theAppleEvent, reply: AppleEvent; refCon: SInt32): OSErr;



IMPLEMENTATION







USES UnitTraceLog,UnitRapport,UnitActions,UnitOth1,UnitPrint;


procedure CheckAppleEvents;
var gestaltResponse : SInt32;
begin
	gHasAppleEvents := false;
	if GestaltImplemented then
	  if (Gestalt(gestaltAppleEventsAttr, gestaltResponse) = noErr) then
			gHasAppleEvents := BTST(gestaltResponse, gestaltAppleEventsPresent);
end;




function GotRequiredParameters(var theAppleEvent:AppleEvent) : OSErr;
var
	 myError,result : OSErr;
	 returnedType : DescType;
	 actualSize : Size;
begin
	myError := AEGetAttributePtr(theAppleEvent, keyMissedKeywordAttr, typeWildCard, @returnedType, NIL, 0, @actualSize);
	if (myError = errAEDescNotFound) 
	  then result := NoErr
		else 
		  if (myError = noErr)
		    then result := errAEParamMissed
		    else result := myError;
  GotRequiredParameters := result;
  
  {WritelnStringAndNumDansRapport('GotRequiredParameters : result=',result);}
end;


function HandleOpenApplicationAppleEvent (var theAppleEvent, reply: AppleEvent; refCon: SInt32): OSErr;
var err : OSErr;
begin
  {$UNUSED reply , refCon}
  
  err := GotRequiredParameters(theAppleEvent);
  {What am I supposed to do here?}
  HandleOpenApplicationAppleEvent := err;
  
  {WritelnStringAndNumDansRapport('HandleOpenApplicationAppleEvent : err=',err);}
end;


function HandleDocumentAppleEvent(var theAppleEvent,reply:AppleEvent; refCon : SInt32) : OSErr;
var theError : OSErr;
    docList:AEDescList;
    itemsInList : SInt32;
    index : SInt32;
    Keyword : AEKeyword;
    returnedType : DescType;
    theFileSpec : FSSpec;
    actualSize : Size;
    bidErr : OSErr;
begin	
	{$UNUSED reply}
	theError := AEGetParamDesc(theAppleEvent, keyDirectObject, typeAEList,  docList);
	if (theError = noErr) then
	  begin
		  theError := GotRequiredParameters(theAppleEvent);
		  if (theError = noErr) then
		    begin
			    theError := AECountItems(docList, itemsInList);
			    if (theError = noErr) then
			      begin
				     for index := 1 to itemsInList do
				       begin
					       theError := AEGetNthPtr(docList, index, typeFSS, @keyword, @returnedType, @theFileSpec, sizeof(theFileSpec), @actualSize);
					       if (theError = noErr) then
					         begin
						        if (refCon = SInt32('odoc'))   {kAEOpenDocuments}
						          then 
							          begin
							            bidErr := OuvrirFichierPartieFSp(theFileSpec,true);
							            Leave;  {Cassio est monodocument !}
							          end
						          else 
						        if (refCon = SInt32('pdoc'))   {kAEPrintDocuments}
							        then
							          begin
							            if OuvrirFichierPartieFSp(theFileSpec,true)=NoErr then
							              DoDialogueApercuAvantImpression;
							            Leave;  {Cassio est monodocument !}
							          end
					         end;
				       end;
			     end;
		   end;
		bidErr := AEDisposeDesc(docList);
	end;
	HandleDocumentAppleEvent := theError;
end;

 

function HandleQuitApplicationAppleEvent (var theAppleEvent, reply: AppleEvent; refCon: SInt32): OSErr;
var theError : OSErr;
begin
  {$UNUSED reply,refCon}
  
  theError := GotRequiredParameters(theAppleEvent);
  if (theError=NoErr) then
    begin
      {WritelnStringAndNumDansRapport('HandleQuitApplicationAppleEvent ',0);}
      DoQuit;
      if not(Quitter) then theError := userCanceledErr;
    end;
    
  HandleQuitApplicationAppleEvent := theError;      
end;


function InstallRequiredAppleEvents() : OSErr;
var result : OSErr;
begin
	
	gHandleOAppUPP := NewAEEventHandlerUPP(AEEventHandlerProcPtr(@HandleOpenApplicationAppleEvent));
	gHandleDocUPP := NewAEEventHandlerUPP(AEEventHandlerProcPtr(@HandleDocumentAppleEvent));
	gHandleQuitUPP := NewAEEventHandlerUPP(AEEventHandlerProcPtr(@HandleQuitApplicationAppleEvent));

  {TraceLog('InstallRequiredAppleEvents');}
  
	result := AEInstallEventHandler('aevt','oapp',gHandleOAppUPP, 0, false);
	result := AEInstallEventHandler(kCoreEventClass, kAEQuitApplication,gHandleQuitUPP, 0, false);
	result := AEInstallEventHandler('aevt','odoc',gHandleDocUPP,SInt32('odoc'), false);
	result := AEInstallEventHandler('aevt','pdoc',gHandleDocUPP,SInt32('pdoc'), false);
	
	
	{WritelnStringAndNumDansRapport('InstallRequiredAppleEvents : result=',result);}
	
	InstallRequiredAppleEvents := result;
end;


procedure InitUnitAppleEventsCassio;
var err : OSErr;
begin

  {TraceLog('InitUnitAppleEventsCassio');}
  
  err := -1;
  CheckAppleEvents;
	if gHasAppleEvents then 
	  err := InstallRequiredAppleEvents();
	
	{WritelnStringAndNumDansRapport('InitUnitAppleEventsCassio : err=',err);}
end;



END.