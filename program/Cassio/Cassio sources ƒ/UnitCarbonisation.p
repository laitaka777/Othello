UNIT UnitCarbonisation;


INTERFACE









USES Menus, Scrap, MacTypes, Events, OSUtils, MacMemory, QuickDraw, QuickdrawText,
	   Resources, MacWindows, Fonts, (* Packages,*) GestaltEqu, TextUtils, ToolUtils,
	   Files, Aliases, AppleEvents, Controls, ControlDefinitions, Dialogs, (* StandardFile,*)
     TextEdit, (*SegLoad,*) Sound,Scrap, (*Balloons,*) ConditionalMacros, MacHelp;

{$DEFINEC CARBONISATION_DE_CASSIO    TRUE }
{$DEFINEC TARGET_API_MAC_CARBON_DANS_CASSIO   TRUE }

{$DEFINEC REDEFINIR_ACCESSEURS   NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
(* {$SETC ACCESSOR_CALLS_ARE_FUNCTIONS := TARGET_API_MAC_CARBON_DANS_CASSIO } *)

{Menus}
procedure MyCheckItem(theMenu: MenuRef; item: SInt16; checked: BOOLEAN);
procedure MyDisableItem(theMenu: MenuRef; item: MenuItemIndex);
procedure MyEnableItem(theMenu: MenuRef; item: MenuItemIndex);
function  MyCountMenuItems(theMenu: MenuRef): UInt16;

{System tasks}
procedure MySystemTask;

{Scrap}
function GetScrapSize(flavor:ScrapFlavorType) : SInt32;
function MyGetScrap(destination: Handle; flavorType: ScrapFlavorType; VAR offset: SInt32): SInt32;
function MyZeroScrap() : OSStatus;
function MyPutScrap(sourceBufferByteCount: SInt32; flavorType: ScrapFlavorType; sourceBuffer: UnivPtr): OSStatus;


{Some of the following stuff comes from the "CarbonStuff.p" unit 
 on Pascal Central. Many thanks to the (unkown) author! }

{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
function HiWord(x: SInt32): SInt16; 
function LoWord(x: SInt32): SInt16; 
{$endc}


{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
procedure InvalRect(r : rect);
procedure InvalRgn(r : RgnHandle);
procedure ValidRect(r : rect);
procedure ValidRgn(r : RgnHandle);
{$endc}




function qdThePort() : CGrafPtr;





{$IFC REDEFINIR_ACCESSEURS }

{$ifc NOT(ACCESSOR_CALLS_ARE_FUNCTIONS) AND NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
function GetWindowPort(window: WindowPtr): CGrafPtr;
function GetDialogPort(dialog : DialogPtr): GrafPtr;
function GetDialogWindow(dialog : DialogPtr): WindowPtr;
function GetMenuID(menu: MenuRef): MenuID;
function GetWindowFromPort(port: univ GrafPtr): WindowPtr;
function GetWindowKind(window: WindowPtr): SInt16; 
function IsMenuItemEnabled(menu: MenuRef; item: MenuItemIndex): BOOLEAN;
function GetPortTextFont(port: CGrafPtr): SInt16; 
function GetPortTextFace(port: GrafPtr): StyleField;
function GetPortTextMode(port: GrafPtr): SInt16; 
function GetPortTextSize(port: GrafPtr): SInt16; 
function GetDialogDefaultItem(dialog : DialogPtr): SInt16; 
function GetDialogKeyboardFocusItem(dialog : DialogPtr): SInt16; 
function GetDialogTextEditHandle(dialog : DialogPtr): TEHandle;
function GetMenuWidth(menu: MenuRef): SInt16; 
function GetMenuHeight(menu: MenuRef): SInt16; 
function GetWindowStandardState(window: WindowRef; VAR rect: Rect): RectPtr;
function GetWindowUserState(window: WindowRef; VAR rect: Rect): RectPtr;
procedure SetWindowStandardState(window: WindowRef; {CONST}VAR rect: Rect);
procedure SetWindowUserState(window: WindowRef; {CONST}VAR rect: Rect);
function GetControlHilite(control: ControlRef): UInt16;
function AEGetDescDataSize({CONST}VAR theAEDesc: AEDesc): Size;
function AEGetDescData({CONST}VAR theAEDesc: AEDesc; dataPtr: UnivPtr; maximumSize: Size): OSErr;
procedure SetPortVisibleRegion(port: univ CGrafPtr; visRgn: RgnHandle);
function IsWindowVisible(window: WindowRef): BOOLEAN;
function IsWindowHilited(window: WindowRef): BOOLEAN;
function GetWindowSpareFlag(window: WindowPtr): BOOLEAN;
procedure SetQDGlobalsRandomSeed(value : SInt32);
function GetControlOwner(whichControl:ControlHandle) : WindowPtr;
function GetControlBounds(whichControl:ControlHandle; var bounds : rect):RectPtr;
function GetPortBitMapForCopyBits(port: CGrafPtr): BitMapPtr;
function GetQDGlobalsRandomSeed() : SInt32;
function GetQDGlobalsDarkGray(var thePat : pattern) : PatternPtr;
function GetQDGlobalsLightGray(var thePat : pattern) : PatternPtr;
function GetQDGlobalsGray(var thePat : pattern) : PatternPtr;
function GetQDGlobalsBlack(var thePat : pattern) : PatternPtr;
function GetQDGlobalsWhite(var thePat : pattern) : PatternPtr;
function GetPortPenMode(port: CGrafPtr): SInt32;
function IsWindowUpdatePending(window: WindowPtr) : boolean;
{$endc}

{$ENDC }  { REDEFINIR_ACCESSEURS}





function MyIsControlVisible(inControl: ControlRef): BOOLEAN;
function MyValidWindowRect(window: WindowRef; {CONST}VAR bounds: Rect): OSStatus;
function MyGetRegionRect(theregion : RgnHandle) : rect;
function MyGetNextWindow(theWindow: WindowRef) : WindowRef;
function MyGetRootControl(theWindow : WindowRef):ControlRef;
function GetWindowStructRect(theWindow : WindowRef) : rect;
function GetWindowContentRect(theWindow : WindowRef) : rect;
function GetWindowVisibleRegion(theWindow : WindowRef;visible : RgnHandle) : RgnHandle;

procedure GetDialogTextSelection(dlg : DialogPtr; var selStart,selEnd : SInt16);
function MyGetPortBounds(port: CGrafPtr): Rect;
function QDGetPortBound() : rect;

function GetScreenBounds() : rect;
function GetWindowPortRect(window : WindowPtr) : rect;
function GetDialogPortRect(dialog : DialogPtr) : rect;
procedure SetPortByWindow(window: WindowPtr);
procedure SetPortByDialog(dialog : DialogPtr);

{TextEdit protection}
function TEGetTextLength(text : TEHandle) : SInt32;
function TEGetViewRect(text : TEHandle) : rect;
function TEGetDestRect(text : TEHandle) : rect;
procedure TESetViewRect(text : TEHandle;theRect : rect);
procedure TESetDestRect(text : TEHandle;theRect : rect);


{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
procedure IUDatePString(dateTime: SInt32; longFlag: ByteParameter; VAR result: str255; intlHandle: Handle);
{$endc}	


IMPLEMENTATION







Uses
	MacTypes, QuickDraw, Events, MacWindows, Dialogs, Fonts, (*DiskInit,*) 
	Devices, TextEdit,  (*Traps,*)  MacMemory,  (*SegLoad,*) Scrap, ToolUtils, 
	Events,  OSUtils,   Menus, ControlDefinitions, GestaltEqu, Sound,
	UnitRapport, UnitMacExtras;


procedure MyCheckItem(theMenu: MenuRef; item: SInt16; checked: BOOLEAN);
begin
{$IFC CARBONISATION_DE_CASSIO AND ACCESSOR_CALLS_ARE_FUNCTIONS}
  CheckMenuItem(theMenu,item,checked);
{$ELSEC}
  CheckItem(theMenu,item,checked);
{$ENDC}
end;


procedure MyDisableItem(theMenu: MenuRef; item: MenuItemIndex);
begin
{$IFC CARBONISATION_DE_CASSIO AND ACCESSOR_CALLS_ARE_FUNCTIONS}
  if (theMenu <> NIL)
    then DisableMenuItem(theMenu,item);
{$ELSEC}
  DisableItem(theMenu,item);
{$ENDC}
end;


procedure MyEnableItem(theMenu: MenuRef; item: MenuItemIndex);
begin
{$IFC CARBONISATION_DE_CASSIO AND ACCESSOR_CALLS_ARE_FUNCTIONS}
  if (theMenu <> NIL) then
    EnableMenuItem(theMenu,item);
{$ELSEC}
  EnableItem(theMenu,item);
{$ENDC}
end;

function MyCountMenuItems(theMenu: MenuRef): UInt16;
begin
{$IFC CARBONISATION_DE_CASSIO AND ACCESSOR_CALLS_ARE_FUNCTIONS}
  if (theMenu <> NIL)
    then MyCountMenuItems := CountMenuItems(theMenu)
    else MyCountMenuItems := 0;
{$ELSEC}
  MyCountMenuItems := CountMItems(theMenu);
{$ENDC}
end;

procedure MySystemTask;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO}
{$ELSEC}
  SystemTask;
{$ENDC}
end;


function GetScrapSize(flavor:ScrapFlavorType) : SInt32;
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO}
var scrap:ScrapRef;
    err : OSStatus;
    flavorFlags: ScrapFlavorFlags;
    byteCount: Size;
begin 
  err := GetCurrentScrap(scrap);
  if err = NoErr then
    begin
		  err := GetScrapFlavorFlags(scrap,flavor,flavorFlags);
		  if (err = NoErr) then {Il y a des donnees de type flavorType dans le presse-papier}
		    begin
		      {on recupere la taille}
		      err := GetScrapFlavorSize(scrap,flavor,byteCount);
		    end;
		end;
  {WritelnStringAndNumDansRapport('dans GetScrapSize, err = ',err);}
  if (err <> NoErr)
    then GetScrapSize := 0
    else GetScrapSize := byteCount;
end;
{$ELSEC}
var infos:ScrapStuffPtr;
begin {$UNUSED flavor}
  infos := InfoScrap();
  if (infos <> NIL)
    then GetScrapSize := infos^.scrapSize
    else GetScrapSize := 0;
end;
{$ENDC}


{ MyGetScrap :
 MyGetScrap va chercher dans le presse-papier global les donnees de type flavorType,
 et les met dans le handle destination, qui est agrandi si necessaire.
 La fonction renvoie la taille des donnes de type flavorType dans le presse-papier,
 et est <0 si en cas d'echec
 }
function MyGetScrap(destination: Handle; flavorType: ScrapFlavorType; VAR offset: SInt32): SInt32;
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO}
var scrap:ScrapRef;
    err : OSStatus;
    flavorFlags: ScrapFlavorFlags;
    byteCount: Size;
    state:SInt8;
begin {$UNUSED offset}
  err := GetCurrentScrap(scrap);
  if err = NoErr then
    begin
		  err := GetScrapFlavorFlags(scrap,flavorType,flavorFlags);
		  if (err = NoErr) then {Il y a des donnees de type flavorType dans le presse-papier}
		    begin
		      {on recupere la taille}
		      err := GetScrapFlavorSize(scrap,flavorType,byteCount);
		      
		      if (err = NoErr) & (byteCount > 0) then
		        begin
		          {peut-etre faut-il redimensionner le handle de destination}
		          if (byteCount > GetHandleSize(destination)) then
		            begin
		              SetHandleSize(destination, byteCount);
		              err := MemError();
		            end;
		            
		          {on recupere les donnees}
		          if (err = NoErr) then
		            begin
		              state := HGetState(destination);
		              HLock(destination);
		              err := GetScrapFlavorData(scrap,flavorType,byteCount,destination^);
		              HSetState(destination,state);
		            end;
		        end;
		    end;
		end;
  {WritelnStringAndNumDansRapport('dans MyGetScrap, err = ',err);}
  if (err <> NoErr)
    then MyGetScrap := -1
    else MyGetScrap := byteCount;
end;
{$ELSEC}
begin
  MyGetScrap := GetScrap(destination,flavorType,offset);
end;
{$ENDC }


function MyZeroScrap() : OSStatus;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO}
  MyZeroScrap := ClearCurrentScrap();
{$ELSEC}
  MyZeroScrap := ZeroScrap();
{$ENDC }
end;


function MyPutScrap(sourceBufferByteCount: SInt32; flavorType: ScrapFlavorType; sourceBuffer: UnivPtr): OSStatus;
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO}
var scrap:ScrapRef;
    err : OSStatus;
begin
  err := GetCurrentScrap(scrap);
  if (err = NoErr) then
    err := PutScrapFlavor(scrap,flavorType,kScrapFlavorMaskNone,sourceBufferByteCount,sourceBuffer);
  {WritelnStringAndNumDansRapport('dans MyPutScrap, err = ',err);}
  MyPutScrap := err;
end;
{$ELSEC}
begin
  MyPutScrap := PutScrap(sourceBufferByteCount,flavorType,sourceBuffer);
end;
{$ENDC }



{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
function HiWord(x: SInt32): SInt16; 
begin
	x := BSR(x, 16);
	HiWord := BitAnd(x, $FFFF);
end;

function LoWord(x: SInt32): SInt16; 
begin
	LoWord := BitAnd(x, $FFFF);
end;

{$endc}


{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
procedure InvalRect(r : rect);
var err : OSErr;
begin
	err := InvalWindowRect(GetWindowFromPort(qdThePort),r);
end;

procedure InvalRgn(r : RgnHandle);
var err : OSErr;
begin
	err := InvalWindowRgn(GetWindowFromPort(qdThePort),r);
end;


procedure ValidRect(r : rect);
var err : OSErr;
begin
	err := ValidWindowRect(GetWindowFromPort(qdThePort),r);
end;

procedure ValidRgn(r : RgnHandle);
var err : OSErr;
begin
	err := ValidWindowRgn(GetWindowFromPort(qdThePort),r);
end;

{$endc}


function GetScreenBounds() : rect;
var theScreenBits:BitMap;
		ignore:BitMapPtr;
begin 
{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
	ignore := GetQDGlobalsScreenBits(theScreenBits); 
	GetScreenBounds := theScreenBits.Bounds;
{$elsec}
  {$UNUSED theScreenBits,ignore}
	GetScreenBounds := qd.ScreenBits.bounds;
{$endc}
end;


function GetWindowPortRect(window : WindowPtr) : rect;
begin
  if (window = NIL)
    then GetWindowPortRect := MakeRect(40,40,40,40)
    else GetWindowPortRect := MyGetPortBounds(GetWindowPort(window));
end;


function GetDialogPortRect(dialog : DialogPtr) : rect;
begin
  GetDialogPortRect := MyGetPortBounds(GetDialogPort(dialog));
end;


{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
function qdThePort() : CGrafPtr;
begin
	qdThePort := GetQDGlobalsThePort();
end;
{$elsec}
function qdThePort() : CGrafPtr;
begin
	qdThePort := CGrafPtr(qd.thePort);
end;
{$endc}


{$IFC REDEFINIR_ACCESSEURS }

{$ifc NOT(ACCESSOR_CALLS_ARE_FUNCTIONS) AND NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }


function GetWindowPort(window: WindowPtr): CGrafPtr;
begin
	GetWindowPort := CGrafPtr(window);
end;

function GetDialogPort(dialog : DialogPtr): GrafPtr;
begin
	GetDialogPort := GrafPtr(dialog);
end;

function GetDialogWindow(dialog : DialogPtr): WindowPtr;
begin
	GetDialogWindow := WindowPtr(dialog);
end;

function GetMenuID(menu: MenuRef): MenuID;
begin
	GetMenuID := menu^^.menuID;
end;

function GetWindowFromPort(port: univ GrafPtr): WindowPtr;
begin
	GetWindowFromPort := port;
end;

function GetWindowKind(window: WindowPtr): SInt16; 
begin
	GetWindowKind := WindowPeek(window)^.windowKind;
end;

function IsMenuItemEnabled(menu: MenuRef; item: MenuItemIndex): BOOLEAN;
begin
	IsMenuItemEnabled := BAND(BSR(menu^^.enableFlags, item), 1) <> 0
end;

function GetPortTextFont(port: CGrafPtr): SInt16; 
var theGrafPtr : grafPtr;
begin
  theGrafPtr := GrafPtr(port);
	GetPortTextFont := theGrafPtr^.txFont;
end;

function GetPortTextFace(port: GrafPtr): StyleField;
begin
	GetPortTextFace := port^.txFace;
end;

function GetPortTextMode(port: GrafPtr): SInt16; 
begin
	GetPortTextMode := port^.txMode;
end;

function GetPortTextSize(port: GrafPtr): SInt16; 
begin
	GetPortTextSize := port^.txSize;
end;

function GetDialogDefaultItem(dialog : DialogPtr): SInt16; 
begin
	GetDialogDefaultItem := DialogPeek(dialog)^.aDefItem;
end;

function GetDialogKeyboardFocusItem(dialog : DialogPtr): SInt16; 
begin
	GetDialogKeyboardFocusItem := DialogPeek(dialog)^.editField;
end;

function GetDialogTextEditHandle(dialog : DialogPtr): TEHandle;
begin
	GetDialogTextEditHandle := DialogPeek(dialog)^.textH;
end;

function GetMenuWidth(menu: MenuRef): SInt16; 
begin
	GetMenuWidth := menu^^.menuWidth;
end;

function GetMenuHeight(menu: MenuRef): SInt16; 
begin
	GetMenuHeight := menu^^.menuHeight;
end;

function GetWindowStandardState(window: WindowRef; VAR rect: Rect): RectPtr;
var theWStateDataHandle:WStateDataHandle;
begin
	theWStateDataHandle := WStateDataHandle(WindowPeek(window)^.dataHandle);
	rect := theWStateDataHandle^^.stdState;
	GetWindowStandardState := @rect;
end;

function GetWindowUserState(window: WindowRef; VAR rect: Rect): RectPtr;
var theWStateDataHandle:WStateDataHandle;
begin
	theWStateDataHandle := WStateDataHandle(WindowPeek(window)^.dataHandle);
	rect := theWStateDataHandle^^.userState;
	GetWindowUserState := @rect;
end;

procedure SetWindowStandardState(window: WindowRef; {CONST}VAR rect: Rect);
begin
	WStateDataHandle(WindowPeek(window)^.dataHandle)^^.stdState := rect;
end;

procedure SetWindowUserState(window: WindowRef; {CONST}VAR rect: Rect);
begin
	WStateDataHandle(WindowPeek(window)^.dataHandle)^^.userState := rect;
end;

function GetControlHilite(control: ControlRef): UInt16;
begin
	GetControlHilite := control^^.contrlHilite;
end;

function AEGetDescDataSize({CONST}VAR theAEDesc: AEDesc): Size;
begin
	AEGetDescDataSize := GetHandleSize(theAEDesc.dataHandle);
end;

function AEGetDescData({CONST}VAR theAEDesc: AEDesc; dataPtr: UnivPtr; maximumSize: Size): OSErr;
var theSize : SInt32;		
begin
	thesize := GetHandleSize(theAEDesc.dataHandle);
	if theSize > maximumSize then
		theSize := maximumSize;
	BlockMove(theAEDesc.datahandle^,dataPtr,theSize);
	AEGetDescData := noErr;
end;

procedure SetPortVisibleRegion(port: CGrafPtr; visRgn: RgnHandle);
begin
	CopyRgn(visRgn, port^.visRgn);
end;		

function IsWindowVisible(window: WindowRef): BOOLEAN;
begin
	IsWindowVisible := WindowPeek(window)^.visible;
end;

function IsWindowHilited(window: WindowRef): BOOLEAN;
begin
	IsWindowHilited := WindowPeek(window)^.hilited;
end;

function GetWindowSpareFlag(window: WindowPtr): BOOLEAN;
type pointPtr = ^point;	
var idealStandardState : rect;			
BEGIN
{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
	GetWindowSpareFlag := IsWindowInStandardState(window,NIL,@idealStandardState);
{$elsec}
  {$UNUSED idealStandardState}
	GetWindowSpareFlag := WindowPeek(window)^.spareFlag;
{$endc}	
END;

procedure SetQDGlobalsRandomSeed(value : SInt32);
begin
  qd.randseed := value;
end;

function GetQDGlobalsRandomSeed() : SInt32;
begin
  GetQDGlobalsRandomSeed := qd.randseed;
end;

function GetControlOwner(whichControl:ControlHandle) : WindowPtr;
begin
  GetControlOwner := whichControl^^.contrlOwner;
end;

function GetControlBounds(whichControl:ControlHandle; var bounds : rect):RectPtr;
begin
  bounds := whichControl^^.contrlRect;
  GetControlBounds := @whichControl^^.contrlRect;
end;


function GetPortBitMapForCopyBits(port: CGrafPtr): BitMapPtr;
var theGrafPtr : grafPtr;
begin
  theGrafPtr := GrafPtr(port);
  GetPortBitMapForCopyBits := @theGrafPtr^.portBits;
end;


function GetQDGlobalsDarkGray(var thePat : pattern) : PatternPtr;
begin
  thePat := qd.dkGray;
  GetQDGlobalsDarkGray := @qd.dkGray;
end;

function GetQDGlobalsLightGray(var thePat : pattern) : PatternPtr;
begin
  thePat := qd.ltGray;
  GetQDGlobalsLightGray := @qd.ltGray;
end;

function GetQDGlobalsGray(var thePat : pattern) : PatternPtr;
begin
  thePat := qd.Gray;
  GetQDGlobalsGray := @qd.Gray;
end;

function GetQDGlobalsBlack(var thePat : pattern) : PatternPtr;
begin
  thePat := qd.black;
  GetQDGlobalsBlack := @qd.black;
end;

function GetQDGlobalsWhite(var thePat : pattern) : PatternPtr;
begin
  thePat := qd.white;
  GetQDGlobalsWhite := @qd.white;
end;

function GetPortPenMode(port: CGrafPtr): SInt32;
begin
  GetPortPenMode := port^.pnMode;
end;
  
function IsWindowUpdatePending(theWindow: WindowPtr) : boolean;
var updateRegion : RgnHandle;
begin
  if (theWindow = NIL)
    then IsWindowUpdatePending := false
    else 
      begin
        updateRegion := WindowPeek(theWindow)^.updateRgn;
        if (updateRegion = NIL)
          then IsWindowUpdatePending := false
          else IsWindowUpdatePending := not(EmptyRgn(updateRegion));
      end;
end;

{$endc}

{$ENDC }   {REDEFINIR_ACCESSEURS}





function MyIsControlVisible(inControl: ControlRef): BOOLEAN;	
begin
{$ifc ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO}
	MyIsControlVisible := IsControlVisible(inControl);
{$elsec}
	MyIsControlVisible := Boolean(inControl^^.contrlvis);
{$endc}
end;

function MyValidWindowRect(window: WindowRef; {CONST}VAR bounds: Rect): OSStatus;
{ I do it this way to avoid any problems with multiple definition of}
{ ValidWindowRect}
{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
begin
	MyValidWindowRect := ValidWindowRect(window,bounds);
end;
{$elsec}
var oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(window);
	ValidRect(bounds);
	SetPort(oldPort);
	MyValidWindowRect := noErr;
end;
{$endc}

function MyGetRegionRect(theregion : RgnHandle) : rect;	
var theRect : rect;		
begin
{$ifc ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO }
	MyGetRegionRect := GetRegionBounds(theregion,theRect)^;
{$elsec}
  {$UNUSED theRect}
	MyGetRegionRect := theregion^^.rgnBBox;
{$endc}
end;

function MyGetNextWindow(theWindow: WindowRef) : WindowRef;
begin
{$IFC ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO}
  MyGetNextWindow := GetNextWindow(theWindow);
{$ELSEC}
  if theWindow = NIL
    then MyGetNextWindow := NIL
    else MyGetNextWindow := WindowPtr(WindowPeek(theWindow)^.nextWindow);
{$ENDC}
end;

function MyGetRootControl(theWindow : WindowRef):ControlRef;
var outControl:ControlRef;
begin
{$IFC ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO}
  if GetRootControl(theWindow, outControl) = NoErr
    then MyGetRootControl := outControl
    else MyGetRootControl := NIL;
{$ELSEC}
  {$UNUSED outControl}
  if theWindow = NIL
    then MyGetRootControl := NIL
    else MyGetRootControl := ControlHandle(WindowPeek(theWindow)^.controlList);
{$ENDC}
end;

function GetWindowStructRect(theWindow : WindowRef) : rect;
var outRect : rect;
begin
{$IFC ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO}
  if GetWindowBounds(theWindow, kWindowStructureRgn, outRect) = NoErr
    then GetWindowStructRect := outRect
    else GetWindowStructRect := MakeRect(0,0,0,0);
{$ELSEC}
  {$UNUSED outRect}
  if theWindow = NIL
    then GetWindowStructRect := MakeRect(0,0,0,0)
    else GetWindowStructRect := MyGetRegionRect(WindowPeek(theWindow)^.strucRgn);
{$ENDC}
end;


function GetWindowContentRect(theWindow : WindowRef) : rect;
var outRect : rect;
begin
{$IFC ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO}
  if GetWindowBounds(theWindow, kWindowContentRgn, outRect) = NoErr
    then GetWindowContentRect := outRect
    else GetWindowContentRect := MakeRect(0,0,0,0);
{$ELSEC}
  {$UNUSED outRect}
  if theWindow = NIL
    then GetWindowContentRect := MakeRect(0,0,0,0)
    else GetWindowContentRect := MyGetRegionRect(WindowPeek(theWindow)^.contRgn);
{$ENDC}
end;

function GetWindowVisibleRegion(theWindow : WindowRef;visible : RgnHandle) : RgnHandle;
begin
{$IFC ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO}
  GetWindowVisibleRegion := GetPortVisibleRegion(GetWindowPort(theWindow), visible);
{$ELSEC}
  if (theWindow <> NIL) & (visible <> NIL) 
    then CopyRgn(theWindow^.visRgn,visible);
  GetWindowVisibleRegion := visible;
{$ENDC}
end;



procedure GetDialogTextSelection(dlg : DialogPtr; var selStart,selEnd : SInt16);
var theText : TEHandle;		
begin
{$ifc ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO }
	theText := GetDialogTextEditHandle(dlg);
	selStart := theText^^.selStart;
	selEnd := theText^^.selEnd;
{$elsec}
  {$UNUSED theText}
	selStart := DialogPeek(dlg)^.textH^^.selStart;
	selEnd := DialogPeek(dlg)^.textH^^.selEnd;
{$endc}
end;


function MyGetPortBounds(port: CGrafPtr): Rect;
var arect : rect;
		ignore:RectPtr;
begin
{$ifc ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO }
	ignore := GetPortBounds(CGrafPtr(port),arect);
	MyGetPortBounds := arect;
{$elsec}
  {$UNUSED arect,ignore}
	MyGetPortBounds := port^.portRect;
{$endc}
end;

function QDGetPortBound() : rect;
begin
  QDGetPortBound := MyGetPortBounds(qdThePort())
end;

procedure SetPortByWindow(window: WindowPtr);
begin
  SetPort(GrafPtr(GetWindowPort(window)));
end;

procedure SetPortByDialog(dialog : DialogPtr);
begin
  SetPort(GrafPtr(GetDialogPort(dialog)));
end;


{$ifc ACCESSOR_CALLS_ARE_FUNCTIONS OR TARGET_API_MAC_CARBON_DANS_CASSIO}
function MyGetPortBitMapForCopyBits(port: CGrafPtr): BitMap;
begin
	MyGetPortBitMapForCopyBits := GetPortBitMapForCopyBits(port)^;
end;	
{$elsec}
function MyGetPortBitMapForCopyBits(port: GrafPtr): BitMap;
begin
	MyGetPortBitMapForCopyBits := port^.portBits;
end;	
{$endc}



{$ifc TARGET_API_MAC_CARBON_DANS_CASSIO}
procedure IUDatePString(dateTime: SInt32; longFlag: ByteParameter; VAR result: str255; intlHandle: Handle);
begin
	DateString(dateTime, longFlag, result,intlHandle);
end;
{$endc}	


function TEGetTextLength(text : TEHandle) : SInt32;
begin
  if (text = NIL)
    then TEGetTextLength := 0
    else TEGetTextLength := text^^.TELength;
end;

function TEGetViewRect(text : TEHandle) : rect;
begin
  if (text = NIL)
    then TEGetViewRect := MakeRect(0,0,-1,-1)
    else TEGetViewRect := text^^.viewRect;
end;

function TEGetDestRect(text : TEHandle) : rect;
begin
  if (text = NIL)
    then TEGetDestRect := MakeRect(0,0,-1,-1)
    else TEGetDestRect := text^^.destRect;
end;

procedure TESetViewRect(text : TEHandle;theRect : rect);
begin
  if (text <> NIL)
    then text^^.viewRect := theRect;
end;

procedure TESetDestRect(text : TEHandle;theRect : rect);
begin
  if (text <> NIL)
    then text^^.destRect := theRect;
end;


END.