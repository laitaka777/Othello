UNIT UnitMacExtras;


INTERFACE







 USES
    MacTypes, fp, QuickDraw, Events, MacWindows, Dialogs, Fonts, ToolUtils, Devices, Resources,
		Processes, (*Traps,*) GestaltEqu, SmartScrollAPI, MyMathUtils, Controls,
		TextUtils, FixMath, Sound, MyMemory, UnitServicesMemoire, ControlDefinitions,
		UnitCarbonisation, Menus, CFBase;

	const
		AppleID = 1;
		AboutCmd = 1;

		EditID = 3;
		UndoCmd = 1;
       {------}
		CutCmd = 3;
		CopyCmd = 4;
		PasteCmd = 5;
		ClearCmd = 6;


		ScBarWidth = 15;        {largeur d'un ascenseur }
		menuBarWidth = 18;
		maxmenucmds = 127;
		stdSmallIcons = 128;    { ressource 'SICN' }
		
		
		growBox = 4;            { case d'agrandissement/réduction des fenêtres }
		padlock = 5;            { cadenas }

		hilite = 50;
		pHiliteBit = 0;

		EscapeKey = 27;

		_WaitNextEvent = $A860;

   {constant to use to create popupMenus as controls}
    popupTitleBold      = $0100;
		popupTitleItalic    = $0200;
		popupTitleUnderline = $0400;
		popupTitleOutline   = $0800;
		popupTitleShadow    = $1000;
		popupTitleCondense  = $2000;
		popupTitleExtend    = $4000;
		popupTitleNoStyle   = $0800;
		
		popupFixedWidth				= 1 * (2**(0));
	  popupVariableWidth		= 1 * (2**(1));
	  popupUseAddResMenu		= 1 * (2**(2));
	  popupUseWFont				  = 1 * (2**(3));

		popupTitleLeftJust   = $0000;
		popupTitleCenterJust = $0001;
		popupTitleRightJust  = $00FF;
		
		popupMenuProc = 1008;
		

	const
		kZoomOut = 1;
		kZoomIn = 2;
		kLinear = 3;

		kDragVerticalLine = 1;
		kDragHorizontalLine = 2;

		DragLineHorizontalCurseurID = 139;
		DragLineVerticalCurseurID   = 140;
		DigitCurseurID              = 146;
				
  var
		theEvent: eventrecord;

		GenevaID: SInt16; 
		CourierID: SInt16; 
		MonacoID: SInt16; 
		TimesID: SInt16; 
		NewYorkID: SInt16; 
		PalatinoID : SInt16; 
		SymbolID: SInt16; 
		TimesNewRomanID: SInt16; 
		TrebuchetMSID: SInt16; 
		EpsiSansID : SInt16; 
		HelveticaID : SInt16; 
		
		gWindowsHaveThickBorders : boolean;
    gEpaisseurBorduresFenetres : SInt16; 


	type
		menuCmdSet = set of 1..maxmenucmds;
		myKeyMap = packed array[0..15] of byte;
		TwoBytesArray = packed array[0..1] of 0..255;
		FourBytesArray = packed array[0..3] of 0..255;

		MenuFlottantRec = record
				theID: SInt32;
				theMenu: MenuRef;
				theControl: ControlHandle;
				theWindow: WindowPtr;
				theRect: rect;
				theMenuWidth : SInt32;
				theItem: SInt16; 
				checkedItems: menuCmdSet;
				provientDUneResource : boolean;
				installe : boolean;
			end;

		ProcedureTypeWithLongint = procedure(var param: SInt32);

  procedure InitUnitMacExtras(debugageUnit : boolean);
	procedure InitMacintoshManagers;
	procedure GetClassicalFontsID;
	function GetWindowSize(window : WindowPtr) : Point;
	function WindowsHaveThickBorders(var epaisseurBorduresFenetres: SInt16): boolean;
	{procedure ClipWindowStructFromWMPort(window: WindowPtr);}
	procedure HiliteRect(unRect: rect);
	procedure ZoomRect(source, dest: rect; mode, nbreDeRectSimultanes: SInt16; faster: boolean);
	procedure PondreLaFenetreCommeUneGouttedEau(windowRect: rect; arriveeDeLaFenetre: boolean);
	function InRange(n, minimum, maximum: SInt32): boolean;
	function MyTrunc(x : double_t) : SInt32;
	function RealToLongint(r : extended) : SInt32;
{$IFC NOT(CARBONISATION_DE_CASSIO) }
	function TrapExists(theTrap: SInt16): boolean;
{$ENDC}
	function HasGestaltAttr(itsAttr: OStype; itsBit: SInt16): boolean;
	procedure Pause;
	function InMenuCmdSet(item : SInt16; commands: menuCmdSet) : boolean;
	procedure EnableMenu(mh: MenuRef; commands: menuCmdSet);
	procedure DisableMenu(mh: MenuRef; commands: menuCmdSet);
	procedure FixEditMenu(enablecommands: boolean);
	procedure CloseDAwindow;
	function GetAppleMenu() : MenuRef;
	function GetFileMenu() : MenuRef;
	function GetEditMenu() : MenuRef;
	procedure SetAppleMenu(whichMenu : MenuRef);
  procedure SetFileMenu(whichMenu : MenuRef);
  procedure SetEditMenu(whichMenu : MenuRef);
  procedure SafeSetCursor(myCursor:CursHandle);
  function RegionEstVide(whichRegion : RgnHandle) : boolean;
	procedure InvalidateWindow(whichWindow: WindowPtr);
	procedure GetPortSize(var width, height: SInt16);
	function MakeRect(left, top, right, bottom: SInt32): Rect;
	function MakePoint(h,v : SInt32) : Point;
	function CentreDuRectangle(theRect : rect) : Point;
	procedure LocalToGlobalRect(var myrect: rect);
	procedure GlobalToLocalRect(var myrect: rect);
	procedure CalculateControlRects(whichWindow: WindowPtr; var hbarrect, vbarrect, gbrect: rect);
	function TextHeight(wptr: WindowPtr): SInt16; 
	procedure CenterString(h, v, w: SInt16; s: str255);
	function CenterRectInRect(original,bigRect : rect) : rect;
	procedure DisplayAboutBox;
	
	
	function MyGetMenu(resourceID : SInt16) : MenuRef;
	procedure MyLockMenu(theMenu : MenuRef);
  procedure MyUnlockMenu(theMenu : MenuRef);
	procedure TerminateMenu(var theMenu: MenuRef;provientDUneResource : boolean);
	
	procedure DoAppleMenuCommands(cmdnumber: SInt16);
	procedure AjouteEspacesItemsMenu(theMenu : MenuRef;nbEspaces : SInt16);
  procedure EnleveEspacesDeDroiteItemsMenu(theMenu : MenuRef);
	function EventPopUpItem(theMenu: MenuRef; var numItem: SInt16; menuRect: Rect; drawChoice, checkChoice: Boolean) : boolean;
	function EventPopUpItemInDialog(dp : DialogPtr; menuTitleItem: SInt16; theMenu: MenuRef; var numItem: SInt16; menuRect: Rect; drawChoice, checkChoice: Boolean) : boolean;
	procedure DrawPUItem(theMenu: MenuRef; item: SInt16; loc: Rect; drawMark: boolean);
(*	function IsMenuItemEnable(menu: MenuRef; item: SInt16): Boolean; *)
	function NewMenuFlottant(whichID: SInt32; whichrect: Rect; whichItem: SInt16): MenuFlottantRec;
	procedure SetItemMenuFlottant(var whichMenuFlottant:MenuFlottantRec;whichItem : SInt16; var change : boolean);
  procedure CheckOnlyThisItem(var whichMenuFlottant: MenuFlottantRec;whichItem : SInt16);
  procedure EffaceMenuFlottant(var whichMenuFlottant:MenuFlottantRec);
  procedure CalculateMenuFlottantSize(var whichMenuFlottant:MenuFlottantRec);
  procedure DrawPUItemMenuFlottant(var whichMenuFlottant: MenuFlottantRec; drawMark: boolean);
  procedure CalculateMenuFlottantControl(var whichMenuFlottant: MenuFlottantRec;whichWindow : WindowPtr);
	procedure InstalleMenuFlottant(var whichMenuFlottant: MenuFlottantRec;whichWindow : WindowPtr);
	procedure DesinstalleMenuFlottant(var whichMenuFlottant: MenuFlottantRec);
	function EventPopUpItemMenuFlottant(var whichMenuFlottant: MenuFlottantRec; drawChoice, checkChoiceBefore,checkChoiceAfter: Boolean) : boolean;


(* 	procedure PlotSmallIcon(r: Rect; hdl: Handle; index: SInt16);
	procedure Plot16ColorSmallIcon(r: rect; h: UnivHandle); *)
	function GetWDName(WDRefNum: SInt16): string;
	function ChangeDir(pathName: string): OSErr;
	function GetApplicationName(default: str255): str255;
	function GetUserName(): str255;
	procedure ShareTimeWithOtherProcesses(quantity : SInt32);
	procedure AttendFrappeClavier;
	procedure AttendFrappeClavierOuSouris(var isKeyEvent: boolean);
	function RandomLongint() : SInt32;
	procedure RandomizeTimer;
	function RandomEntreBornes(a,b : SInt16) : SInt16; 
	function RandomLongintEntreBornes(a,b : SInt32) : SInt32;
	function PChancesSurN(P,N : SInt32) : boolean;
  function UneChanceSur(N : SInt32) : boolean;
	{function Min(a,b : SInt32) : SInt32;
	function Max(a,b : SInt32) : SInt32;}
	function Signe(n : SInt32) : SInt32;
	function InterpolationLineaire(x,x1,y1,x2,y2 : SInt32) : SInt32;
	function SafeAdd(x,y,bornesuperieure : SInt32) : SInt32;
	function EscapeDansQueue() : boolean;
	procedure EnableAppleMenuForDialog(nombreItemsAGriser: SInt16);
	procedure MyGetKeys(var theKeys: myKeyMap);
	function ToucheAppuyee(KeyCode: SInt16): boolean;
	function MemesTouchesAppuyees(var keyMap1, keyMap2: myKeyMap): boolean;
	
	function DateCouranteEnString() : string;
	function DateEnString(const whichDate : DateTimeRec) : string;
	
	procedure SetFileCreator(fichier: FSSpec; QuelType: OSType);
	procedure SetFileType(fichier: FSSpec; QuelType: OSType);
{ valable pour CW Pro...}
{function MySwapInteger(TwoBytes: UNIV TwoBytesArray) : SInt16; }
{function MySwapLongint(FourBytes: UNIV FourBytesArray) : SInt32;}
{}
	function MySwapInteger(num: SInt16): SInt16; 
	function MySwapLongint(num: SInt32): SInt32;
	function BooleanXor(b1, b2: boolean): boolean;
	function ProfondeurMainDevice(): SInt16; 
	function EstUnAscenseurAvecDoubleScroll(theScroller: ControlHandle; var contourAscenseurRect, regionGriseeRect: rect; var estHorizontal: boolean): boolean;
	function SmartScrollEstInstalle(theScroller: ControlHandle; var proportion: fixed): boolean;
	function EgalitePolymorphe(ptr1, ptr2: univ PackedArrayOfCharPtr; tailleDonnees: SInt32): boolean;
	function QuelCaractereDeControle(c : char; enMajuscule: boolean) : char;
	procedure EmuleToucheCommandeParControleDansEvent(var myEvent: eventrecord);
	procedure DragLine(whichWindow : WindowPtr;orientation: SInt16; UtiliseHiliteMode: boolean; minimum, maximum, step: SInt32; var positionSouris, index: SInt32; Action: ProcedureTypeWithLongint);
	procedure DessineLigne(source,dest : Point);
  procedure DessineFleche(source,dest : Point;longueur_max_pointe : double_t);
  procedure DessineOmbreRoundRect(theRect : rect;ovalWidth,ovalHeight : SInt16; targetColor : RGBColor;tailleOmbre,forceDuGradient,ombrageMinimum,typeOmbrage : SInt32);
	function BoutonAppuye(whichWindow: WindowPtr; Rectangle: rect): boolean;
	procedure IdentiteSurN(var N: SInt32);
	function FonctionTrue(): boolean;
	function FonctionFalse(): boolean;
	function PuissanceReelle(x,exposant : extended) : extended;
	function Puissance(r : extended;n : SInt32) : extended;
	function NewMagicCookie() : SInt32;
	function MicrosecondesToSecondes(microTicks:unsignedWide) : extended;
  function MakeCFSTR(s : str255):CFStringRef;
  function LoadFrameworkBundle(inFrameworkName:CFStringRef; var outBundleRef:CFBundleRef) : OSStatus;
  function GetFunctionPointerFromBundle(const whichBundle,functionName : str255) : Ptr;
  
  procedure EnableQuartzAntiAliasing(useQuartzMetrics : boolean);
  procedure EnableQuartzAntiAliasingThisPort(port : CGrafPtr;useQuartzMetrics : boolean);
  procedure DisableQuartzAntiAliasing;
  procedure DisableQuartzAntiAliasingThisPort(port : CGrafPtr);
  function InitialiseQuartzAntiAliasing() : OSErr;
  
  function MyGetFontNum(nomPolice : str255) : SInt16; 
  
  
  
  (* on rajoute ces definitions, qui ne sont pas dans Carbon *)
  
  type  SFReplyPtr = ^SFReply;
        SFReply = RECORD
		                good:					BOOLEAN;
		                copy:					BOOLEAN;
		                fType:					OSType;
		                vRefNum:				INTEGER;
		                version:				INTEGER;
		                fName:					StrFileName;							{  a Str63 on MacOS  }
	                END;
	      DlgHookUPP             = UniversalProcPtr;
        FileFilterUPP          = UniversalProcPtr;
        SFTypeList							= ARRAY [0..3] OF OSType;
        ConstSFTypeListPtr			= ^OSType;
	{	
	    The GetFile "typeList" parameter type has changed from "SFTypeList" to "ConstSFTypeListPtr".
	    For C, this will add "const" and make it an in-only parameter.
	    For Pascal, this will require client code to use the @ operator, but make it easier to specify long lists.
	
	    ConstSFTypeListPtr is a pointer to an array of OSTypes.
		}
	
  
  
  procedure MySFPutFile(where: Point; prompt: ConstStringPtr; origName: str255; dlgHook: DlgHookUPP; var reply: SFReply);
  procedure MySFGetFile(where: Point; prompt: str255; fileFilter: FileFilterUPP; numTypes: SInt16; typeList: ConstSFTypeListPtr; dlgHook: DlgHookUPP; var reply: SFReply);


IMPLEMENTATION







  USES UnitRapport,UnitCarbonisation,Menus,Folders,UnitTraceLog,SNStrings,UnitCouleur,UnitFenetres;

  const 
    unit_MacExtras_initialisee : boolean = false;
    unit_MacExtras_magicCookieSeed : SInt32 = 0;

	const
		applemenu : MenuRef = NIL;
		filemenu  : MenuRef = NIL;
		editmenu  : MenuRef = NIL;  

  var unit_MacExtras_debuggage : boolean;
  
  procedure InitUnitMacExtras(debugageUnit : boolean);
  begin
    gWindowsHaveThickBorders := WindowsHaveThickBorders(gEpaisseurBorduresFenetres);
    GetClassicalFontsID;
    
    unit_MacExtras_initialisee := true;
    unit_MacExtras_magicCookieSeed := 0;
    unit_MacExtras_debuggage := debugageUnit;
  end;

	procedure InitMacintoshManagers;
	begin
	
	
{$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO)}
		InitGraf(@qd.theport);
		InitFonts;
		InitWindows;
		InitMenus;
		TEInit;
		InitDialogs(NIL);
{$ENDC}		

		if (TEFromScrap() = noErr) then;
		InitCursor;
		FlushEvents(everyEvent - diskEvt, 0);
	end;
    
    
	procedure GetClassicalFontsID;
	begin
		GenevaID := 0;
		CourierID := 0;
		TimesID := 0;
		MonacoID := 0;
		NewYorkID := 0;
		PalatinoID := 0;
		SymbolID := 0;
		TimesNewRomanID := 0;
		TrebuchetMSID := 0;
		EpsiSansID := 0;
		HelveticaID := 0;

		GetFNum('Geneva', GenevaID);
		GetFNum('Courier', CourierID);
		GetFNum('Times', TimesID);
		GetFNum('Monaco', MonacoID);
		GetFNum('New York', NewYorkID);
		GetFNum('Palatino', PalatinoID);
		GetFNum('Symbol', SymbolID);
		GetFNum('Times New Roman', TimesNewRomanID);
		GetFNum('Trebuchet MS', TrebuchetMSID);
		GetFNum('Espi Sans', EpsiSansID);
		GetFNum('Helvetica', HelveticaID);
	end;


	
	function GetWindowSize(window : WindowPtr) : Point;
	var result : Point;
	begin
	  result.h := -1;
	  result.v := -1;
	  if window <> NIL then
	    with GetWindowPortRect(window) do
	      begin
	        result.h := right - left;
	        result.v := bottom - top;
	      end;
	  GetWindowSize := result;
	end;

	function WindowsHaveThickBorders(var epaisseurBorduresFenetres: SInt16): boolean;
		var
			structureRect, contentRect: rect;
			aWindow: WindowPtr;
			aRect: rect;
			oldport: GrafPtr;
	begin
		GetPort(oldport);
		SetRect(aRect, 31000, 31000, 31150, 31150);
		aWindow := NewCWindow(NIL, aRect, '', true, zoomDocProc, NIL, true, 0);
		structureRect := GetWindowStructRect(aWindow);
		contentRect   := GetWindowContentRect(aWindow);
		DisposeWindow(aWindow);
		SetPort(oldport);
		epaisseurBorduresFenetres := (structureRect.right - structureRect.left) -(contentRect.right - contentRect.left);
		WindowsHaveThickBorders := (epaisseurBorduresFenetres >= 10);
	end;

 (*
	procedure ClipWindowStructFromWMPort(window: WindowPtr);
		var
			oldClipRgn: RgnHandle;
			RegionCouverteParRegion: RgnHandle;
			oldport: GrafPtr;
			windowManagerPort: GrafPtr;
	begin
		GetPort(oldport);
		GetWMgrPort(windowManagerPort);
		SetPort(windowManagerPort);
		oldclipRgn := NewRgn();
		GetClip(oldClipRgn);

		RegionCouverteParRegion := NewRgn();
		(window, RegionCouverteParRegion);
		InvertRgn(RegionCouverteParRegion);
		DisposeRgn(RegionCouverteParRegion);

		DisposeRgn(oldClipRgn);
		SetPort(oldport);
	end;
	*)

procedure HiliteRect(unRect: rect);
  var hiliteMode: ByteParameter;
	begin
	  EraseRect(unRect);
	  hiliteMode := LMGetHiliteMode;
    BitClr(@hiliteMode,pHiliteBit);
    LMSetHiliteMode(hiliteMode);

		InvertRect(unRect);
	end;



(* ZoomRect sans utiliser des fixed *)
procedure ZoomRect(source, dest: rect; mode, nbreDeRectSimultanes: SInt16; faster: boolean);
{$IFC NOT(CARBONISATION_DE_CASSIO) }
	var
		oldport: GrafPtr;
		zoomPort: CGrafPtr;
		tempRect: array[0..30] of rect;
		deltas: array[0..3] of extended;
		numberOfSteps: SInt16; 
		percentComplete, acceleration: extended;
		dasTicks, wait: SInt32;
		k, conditionArret: SInt16; 
    ev: eventrecord;
    dummy: boolean;

begin

(*

	GetPort(oldPort);
	zoomPort := CreateNewPort();
	SetPort(GrafPtr(zoomPort));
	PenPat(grayPattern);
	PenMode(patXor);
	numberOfSteps := 15;
	wait := 1;
		
	ShareTimeWithOtherProcesses(80);
	ShareTimeWithOtherProcesses(80);
	{ShareTimeWithOtherProcesses(60);
	ShareTimeWithOtherProcesses(60);}
	
	dasTicks := TickCount() + 1;

	case mode of
		kZoomOut: 
			begin
				acceleration := 100.0 / 80.5;
				percentComplete := 0.0351843;   { =(1/acceleration) puissance numberOfSteps }
				conditionArret := 0;
			end;
		kZoomIn: 
			begin
				tempRect[0] := source;
				source := dest;
				dest := temprect[0];
				acceleration := 80.0 / 100.0;
				{percentComplete := 1.00;}
				percentComplete := 1.0 - 0.0351843;   { = 1.0 - ((1/acceleration) puissance numberOfSteps) }
				conditionArret := -nbreDeRectSimultanes + 1;
			end;
		klinear: 
			begin
				acceleration := 1.0 / numberOfSteps;
				percentComplete := acceleration;
				conditionArret := 0;
			end;
	end;  {case}

  {comme on n'en affiche qu'un sur deux si faster=true, on double nbreDeRectSimultanes}
	if faster then
		nbreDeRectSimultanes := 2 * nbreDeRectSimultanes;


	deltas[0] := dest.top - source.top;
	deltas[1] := dest.left - source.left;
	deltas[2] := dest.bottom - source.bottom;
	deltas[3] := dest.right - source.right;

	for k := 1 to nbreDeRectSimultanes do
		SetRect(temprect[k], 0, 0, 0, 0);


	
	repeat
		temprect[0] := source;
		with temprect[0] do
			begin
				top := top + RoundToL(deltas[0] * percentComplete);
				left := left + RoundToL(deltas[1] * percentComplete);
				bottom := bottom + RoundToL(deltas[2] * percentComplete);
				right := right + RoundToL(deltas[3] * percentComplete);
			end;

		if not(faster) | not(odd(numberOfSteps)) then
			begin
				with temprect[0] do
					if (right - left > 0) | (top - bottom > 0) then
						FrameRect(temprect[0]);

				with temprect[nbreDeRectSimultanes] do
					if (right - left > 0) | (top - bottom > 0) then
						FrameRect(temprect[nbreDeRectSimultanes]);

				while (dasTicks >= TickCount()) do
					{ShareTimeWithOtherProcesses(2)};
				dasTicks := dasTicks + wait;

			end;



		for k := nbreDeRectSimultanes downto 1 do
			temprect[k] := temprect[k - 1];

		case mode of
			kZoomOut, kZoomIn: 
				percentComplete := percentcomplete * acceleration;
			kLinear: 
				percentComplete := percentComplete + acceleration;
		end;

		numberOfSteps := numberOfSteps - 1;

	until(numberOfSteps < conditionArret);

	for k := nbreDeRectSimultanes downto 1 do
		begin
			if not(faster) | odd(k + conditionArret) then
				begin
					with temprect[k] do
						if (right - left > 0) |(top - bottom > 0) then
							FrameRect(temprect[k]);

					while(dasTicks >= TickCount()) do
						{ShareTimeWithOtherProcesses(2);};
					dasTicks := dasTicks + wait;
				end;
		end;

	SetPort(oldPort);
	DisposePort(zoomPort);
	*)
end;  {ZoomRect}
{$ELSEC }
begin  {ZoomRect}
  {$UNUSED source, dest, mode, nbreDeRectSimultanes, faster }
end;  {ZoomRect}
{$ENDC }



procedure PondreLaFenetreCommeUneGouttedEau(windowRect: rect; arriveeDeLaFenetre: boolean);
	const
		largeurPetitRect = 14;
		hauteurMenuBar = 20;
	var
		menuTinyRect, centralTinyRect: rect;
begin
	SetRect(menuTinyRect, 0, 0, 2, 2);
	OffsetRect(menuTinyRect,(GetScreenBounds().right) div 2, hauteurMenuBar);
	centralTinyRect := menuTinyRect;
	OffsetRect(centralTinyRect, 0,(GetScreenBounds().bottom - hauteurMenuBar) div 2);
	InsetRect(centralTinyRect, -(largeurPetitRect div 2), -(largeurPetitRect div 2));

	if arriveeDeLaFenetre then
		begin
			ZoomRect(menuTinyRect, centralTinyRect, klinear, 5, false);
			ZoomRect(centralTinyRect, windowRect, kZoomOut, 5, false);
		end
	else
		begin
			ZoomRect(windowRect, centralTinyRect, kZoomIn, 5, false);
			ZoomRect(centralTinyRect, menuTinyRect, klinear, 5, false);
		end;
end;


procedure AttendFrappeClavier;
	var
		event: eventRecord;
begin
	FlushEvents(everyEvent, 0);
	repeat
		MySystemTask;
	until GetNextEvent(KeyDownMask + MDownMask, event);
	FlushEvents(everyEvent, 0);
end;

procedure AttendFrappeClavierOuSouris(var isKeyEvent: boolean);
	var
		event: eventRecord;
begin
	FlushEvents(everyEvent, 0);
	repeat
		MySystemTask;
	until GetNextEvent(KeyDownMask + MDownMask, event);
	isKeyEvent := (event.what = keyDown) | (event.what = autoKey);
	FlushEvents(everyEvent, 0);
end;



function InRange(n, minimum, maximum: SInt32): boolean;
begin
	InRange := (n >= minimum) & (n <= maximum);
end;



{$IFC NOT(CARBONISATION_DE_CASSIO) }

function NumToolboxTraps(): SInt16; 
	const
		_InitGraf = $A86E;
begin
	if NGetTrapAddress(_InitGraf, ToolTrap) = NGetTrapAddress($AA6E, ToolTrap) then
		NumToolboxTraps := $200
	else
		NumToolboxTraps := $400;
end;

function GetTrapType(theTrap: SInt16): Traptype;
	const
		TrapMask = $0800;
begin
	if (BAND(TheTrap, TrapMask) > 0) then
		GetTrapType := ToolTrap
	else
		GetTrapType := OSTrap;
end;

function TrapExists(theTrap: SInt16): boolean;
	const
		_Unimplemented = $A89F;
	var
		tType: TrapType;
begin
	tType := GetTrapType(theTrap);
	if tType = ToolTrap then
		begin
			theTrap := BAND(theTrap, $07FF);
			if theTrap >= NumToolBoxTraps then
				theTrap := _Unimplemented;
		end;
	TrapExists := NGetTrapAddress(theTrap, tType) <> NGetTrapAddress(_Unimplemented, ToolTrap);
end;

{$ENDC}


function HasGestaltAttr(itsAttr: OStype; itsBit: SInt16): boolean;
	var
		response: SInt32;
begin
	HasGestaltAttr := (Gestalt(itsAttr, response) = noErr) & (BTST(response, itsBit));
end;


procedure Pause;
begin
	while Button() do
		MySystemTask;
	while not Button() do
		MySystemTask;
	FlushEvents(MDownmask + MupMask, 0);
end;

function InMenuCmdSet(item : SInt16; commands: menuCmdSet) : boolean;
begin
  InMenuCmdSet := (item in commands);
end;

procedure EnableMenu(mh: MenuRef; commands: menuCmdSet);
	var
		thecommand: 1..maxmenucmds;
begin
	for thecommand := 1 to maxmenucmds do
		if thecommand in commands then
			MyEnableItem(mh, thecommand);
end;

procedure DisableMenu(mh: MenuRef; commands: menuCmdSet);
	var
		thecommand: 1..maxmenucmds;
begin
	for thecommand := 1 to maxmenucmds do
		if thecommand in commands then
			MyDisableItem(mh, thecommand);
end;

procedure FixEditMenu(enablecommands: boolean);
	var
		editset: menuCmdSet;
begin
	editset := [UndoCmd, CutCmd, CopyCmd, PasteCmd, ClearCmd];
	if enablecommands then
		EnableMenu(editmenu, editset)
	else
		DisableMenu(editmenu, editset);
end;

{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
procedure CloseDAwindow;
begin
end;
{$ELSEC}
procedure CloseDAwindow;
	var
		DAnumber: SInt16; 
begin
	DAnumber := GetWindowKind(FrontWindow());
	CloseDeskAcc(DAnumber);
end;
{$ENDC}

function GetAppleMenu() : MenuRef;
begin
  GetAppleMenu := applemenu;
end;

function GetFileMenu() : MenuRef;
begin
  GetFileMenu := filemenu;
end;
	
function GetEditMenu() : MenuRef;
begin
  GetEditMenu := editmenu;
end;

procedure SetAppleMenu(whichMenu : MenuRef);
begin
  applemenu := whichMenu;
end;

procedure SetFileMenu(whichMenu : MenuRef);
begin
  filemenu := whichMenu;
end;
	
procedure SetEditMenu(whichMenu : MenuRef);
begin
  editmenu := whichMenu;
end;

procedure SafeSetCursor(myCursor:CursHandle);
var cursorData : Cursor;
begin
  if (myCursor = NIL) | (myCursor^ = NIL)
    then InitCursor
    else 
      begin
        cursorData := myCursor^^;
        SetCursor(cursorData);
      end;
end;

function RegionEstVide(whichRegion : RgnHandle) : boolean;
begin
  if (whichRegion = NIL)
    then RegionEstVide := true
    else RegionEstVide := EmptyRgn(whichRegion);
end;

procedure InvalidateWindow(whichWindow: WindowPtr);
	var
		oldport: GrafPtr;
begin
	if whichWindow <> NIL then
		begin
			GetPort(oldport);
			SetPortByWindow(whichWindow);
			InvalRect(QDGetPortBound());
			SetPort(oldport);
		end;
end;

procedure GetPortSize(var width, height: SInt16);
begin
	with QDGetPortBound() do
		begin
			width := right - left;
			height := bottom - top;
		end;
end;

function MakeRect(left, top, right, bottom: SInt32): Rect;
	var
		result: Rect;
begin
	SetRect(result, left, top, right, bottom);
	MakeRect := result;
end;

function MakePoint(h,v : SInt32) : Point;
var result : Point;
begin
  result.h := h;
  result.v := v;
  MakePoint := result;
end;

function CentreDuRectangle(theRect : rect) : Point;
var result : Point;
begin
  result.h := (theRect.left+theRect.right) div 2;
  result.v := (theRect.top+theRect.bottom) div 2;
  CentreDuRectangle := result;
end;


procedure LocalToGlobalRect(var myrect: rect);
begin
	LocalToGlobal(myrect.topLeft);
	LocalToGlobal(myrect.botRight);
end;

procedure GlobalToLocalRect(var myrect: rect);
begin
	GlobalToLocal(myrect.topLeft);
	GlobalToLocal(myrect.botRight);
end;

procedure CalculateControlRects;
begin
	with GetWindowPortRect(whichWindow) do
		begin

			gbrect.top := bottom - scbarwidth;
			gbrect.left := right - scbarwidth;
			gbrect.bottom := bottom;
			gbrect.right := right;

			hbarrect := gbrect;
			hbarrect.left := left;
			hbarrect.right := gbrect.left;

			vbarrect := gbrect;
			vbarrect.top := top;
			vbarrect.bottom := gbrect.top;

		end;
end;


function TextHeight(wptr: WindowPtr): SInt16; 
	var
		InfosPolice: fontinfo;
		oldport: GrafPtr;
begin
	GetPort(oldport);
	SetPortByWindow(wptr);
	GetFontInfo(InfosPolice);
	with InfosPolice do
		TextHeight := ascent + descent + leading;
	SetPort(oldport);
end;

procedure CenterString;
begin
	w := w - StringWidth(s);
	if w < 0 then
		w := 0;
	Moveto(h +(w div 2), v);
	DrawString(s);
end;

function CenterRectInRect(original,bigRect : rect) : rect;
var largeur,hauteur : SInt32;
    a,b : SInt32;
begin
  largeur := original.right - original.left;
  hauteur := original.bottom - original.top;
  
  a := (bigRect.left + bigRect.right  - largeur) div 2;
  b := (bigRect.top  + bigRect.bottom - hauteur) div 2;
  
  CenterRectInRect := MakeRect(a,b,a+largeur,b+hauteur);
end;

procedure DisplayAboutBox;
{ necessite une ressource de type STR$ à 6 items , d'ID 1 :}
{     STR$ 1 = nom du programe}
{     STR$ 2 = auteur}
{     STR$ 3 = version}
{     STR$ 4 = copyright}
{     STR$ 5 = Adresse}
{     STR$ 6 = telephone}
{     STR$ 7 = copyright}
{     STR$ 8 = suite du précédent}
{}
	const
		strlistID = 1;
		ValseHongroiseID = 20000;
	var
		oldport: GrafPtr;
		wp: WindowPtr;
		wr: rect;
		i: SInt16; 
		messages: array[1..6] of str255;
  (* theChannel : SndChannelPtr; *)
begin
(*OpenChannel(theChannel); *)
	for i := 1 to 6 do
		GetIndString(messages[i], strlistID, i);

	wr := GetScreenBounds();
	InsetRect(wr,(wr.right - wr.left - 300) div 2,(wr.bottom - wr.top - 180) div 2);
	wp := NewCWindow(NIL, wr, '', true, altdboxproc, FenetreFictiveAvantPlan(), false, 0);

	if wp <> NIL then
		with GetWindowPortRect(wp) do
			begin
				GetPort(oldport);
				SetPortByWindow(wp);

				TextFont(systemFont);
				TextSize(0);
				CenterString(0, 30, right, messages[1]);

				TextFont(GenevaID);
				TextSize(9);
				CenterString(0, 60, right, messages[2]);
				CenterString(0, 90, right, messages[3]);
				CenterString(0, bottom - 50, right, messages[4]);
				CenterString(0, bottom - 35, right, messages[5]);
				CenterString(0, bottom - 20, right, messages[6]);

				while Button() do
					begin
					  ShareTimeWithOtherProcesses(2);
						MySystemTask;
				(*	FlushChannel(theChannel);
						PlaySoundAsynchrone(ValseHongroiseID, theChannel);  *)
					end;
				while not(Button()) do
					begin
					  ShareTimeWithOtherProcesses(2);
						MySystemTask;
			(*		FlushChannel(theChannel);
						PlaySoundAsynchrone(ValseHongroiseID, theChannel); *)
					end;
				FlushEvents(MDownmask + MupMask, 0);

				DisposeWindow(wp);
				SetPort(oldport);
	(*		QuietChannel(theChannel);
				closeChannel(theChannel); *)
			end;
end;

procedure DoAppleMenuCommands;
	var
		DAName: str255;
		result: SInt16;    {ignore}
begin {$UNUSED DAName, result}
	if cmdNumber = aboutCmd then
		DisplayAboutBox
	else
		begin
      {$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
			GetMenuItemText(applemenu, cmdNumber, daName);
			result := OpenDeskAcc(DAname);
			{$ENDC }
		end;
end;


procedure TerminateMenu(var theMenu: MenuRef;provientDUneResource : boolean);
begin {$UNUSED provientDUneResource}
  if (theMenu <> NIL) then
    begin    
{$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
      HUnlock(Handle(theMenu));
      if provientDUneResource
		    then ReleaseResource(Handle(theMenu))
		    else DisposeMenu(theMenu);
	    theMenu := NIL;	  
{$ELSEC}
      DisposeMenu(theMenu); 
      theMenu := NIL;
{$ENDC}
    end;
end;

procedure MyLockMenu(theMenu : MenuRef);
begin {$UNUSED theMenu}
{$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
  MyUnlockMenu(theMenu);
  MoveHHI(Handle(theMenu));
  HLockHi(Handle(theMenu));
{$ENDC}
end;

procedure MyUnlockMenu(theMenu : MenuRef);
begin {$UNUSED theMenu}
{$IFC NOT(TARGET_API_MAC_CARBON_DANS_CASSIO) }
  HUnlock(Handle(theMenu));
{$ENDC}
end;

function MyGetMenu(resourceID : SInt16) : MenuRef;
begin
  MyGetMenu := GetMenu(resourceID);
end;



procedure AjouteEspacesItemsMenu(theMenu : MenuRef;nbEspaces : SInt16);
var i,n : SInt16; 
    s : str255;
begin
  if not(unit_MacExtras_initialisee) then
    InitUnitMacExtras(false);
    
  if (theMenu <> NIL) then
    for i := 1 to MyCountMenuItems(theMenu) do
      begin
        GetMenuItemText(theMenu,i,s);
        s := EnleveEspacesDeDroite(s);
        for n := 1 to nbEspaces do
          if gWindowsHaveThickBorders | gIsRunningUnderMacOSX {Appearence extension present ?}
            then s := Concat(s,StringOf(' '))
            else s := Concat(s,StringOf('  '));
        SetMenuItemText(theMenu,i,s);
      end;
end;

procedure EnleveEspacesDeDroiteItemsMenu(theMenu : MenuRef);
var i,nbEspacesEnleves : SInt16; 
    s : str255;
begin
  if (theMenu <> NIL) then
    for i := 1 to MyCountMenuItems(theMenu) do
      begin
        GetMenuItemText(theMenu,i,s);
        EnleveEtCompteEspacesDeDroite(s,nbEspacesEnleves);
        if (nbEspacesEnleves > 0) then
          SetMenuItemText(theMenu,i,s);
      end;
end;




function EventPopUpItem(theMenu: MenuRef; var numItem: SInt16; menuRect: Rect; drawChoice: Boolean; checkChoice: boolean) : boolean;
	var
		r: Rect;
		c: SInt16; 
		choice: SInt32;
		ps: PenState;
		alreadyInList: Boolean;
		{savedState: SignedByte;}
begin
	GetPenState(ps);
	PenNormal;
	
	if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant LoadRessource');
	
	MyLockMenu(theMenu);
	
	if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant PopUpMenuSelect');
	
	alreadyInList := (GetMenuHandle(GetMenuID(theMenu)) <> NIL);
	
	if unit_MacExtras_debuggage then WritelnStringAndBoolDansRapport('dans EventPopUpItem : alreadyInList = ',alreadyInList);
	
	if not alreadyInList then
		InsertMenu(theMenu, -1);
	r := menuRect;
	LocalToGlobal(r.topLeft);
	c := numItem;
	if checkChoice then
		MyCheckItem(theMenu, c, True);

  if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant HSetState');
		
  MyUnlockMenu(theMenu);
  
  if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant AjouteEspacesItemsMenu');
  
  {if not(gIsRunningUnderMacOSX) then}
    AjouteEspacesItemsMenu(theMenu,1);
  
  if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant PopUpMenuSelect');
  if unit_MacExtras_debuggage then WritelnStringAndNumDansRapport('  …avant PopUpMenuSelect , theMenu = ',SInt32(theMenu));
  if unit_MacExtras_debuggage then WritelnStringAndNumDansRapport('  …avant PopUpMenuSelect , r.top = ',r.top);
  if unit_MacExtras_debuggage then WritelnStringAndNumDansRapport('  …avant PopUpMenuSelect , r.left = ',r.left);
  if unit_MacExtras_debuggage then WritelnStringAndNumDansRapport('  …avant PopUpMenuSelect , numItem = ',numItem);
  
	choice := PopUpMenuSelect(theMenu, r.top, r.left, numItem);
	
	if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant EnleveEspacesDeDroiteItemsMenu');
	
	EnleveEspacesDeDroiteItemsMenu(theMenu);
	
	if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant HLockState');
	
	MyLockMenu(theMenu);
	
	if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant MyCheckItem');
	
	if checkChoice then
		MyCheckItem(theMenu, c, False);
  
  if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant if HiWrd(choice) = theMenu^^.menuId');
  
	if (HiWrd(choice) = GetMenuID(theMenu)) & (LoWrd(choice) <> 0) 
	  then 
	    begin
	      if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant EventPopUpItem := true');
	      numItem := LoWrd(choice);
	      EventPopUpItem := true;
	    end
	  else 
	    begin
	      if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant EventPopUpItem := false');
	      EventPopUpItem := false;
	    end;
	
	if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant DrawPUItem');
	
	if drawChoice then
		DrawPUItem(theMenu, numItem, menuRect, true);

  if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant DeleteMenu');
  
	if not alreadyInList then
		DeleteMenu(GetMenuID(theMenu));
		
	MyUnlockMenu(theMenu);
	
	SetPenState(ps);
	
	if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : sortie');
	
end;


function EventPopUpItemInDialog(dp : DialogPtr; menuTitleItem: SInt16; theMenu: MenuRef; var numItem: SInt16; menuRect: Rect; drawChoice: Boolean; checkChoice: Boolean) : boolean;
	var
		itemType: SInt16; 
		itemHandle: handle;
		titleRect: rect;
begin
	GetDialogItem(dp, menuTitleItem, itemType, itemHandle, titleRect);
	if false & not(gIsRunningUnderMacOSX) then
	  begin
	    titleRect.left := titleRect.left - 2;
	    InvertRect(titleRect);
	  end;
	EventPopUpItemInDialog := EventPopUpItem(theMenu, numItem, menuRect, drawChoice, checkchoice);
	if false & not(gIsRunningUnderMacOSX) then InvertRect(titleRect);
end;


procedure DrawPUItem(theMenu: MenuRef; item: SInt16; loc: Rect; drawMark: boolean);
var theMenuID : SInt16; 
    currentPort : grafPtr;
    myControl:ControlHandle;
begin  {$UNUSED drawMark}
  GetPort(currentPort);
  if (theMenu <> NIL) & (currentPort <> NIL) then
    begin
      theMenuID := GetMenuID(theMenu);
      CalcMenuSize(theMenu);
			loc.right := loc.left + GetMenuWidth(theMenu) + 7;
			loc.bottom := loc.top + 19;
			OffsetRect(loc,-1,0);
      myControl := NewControl(GetWindowFromPort(CGrafPtr(currentPort)),loc,'',false,popupTitleRightJust,theMenuID,0,popupMenuProc,0);
      OffsetRect(loc,1,0);
      if myControl <> NIL then
        begin
          {SysBeep(0);attendfrappeclavier;}
          SetControlValue(myControl,item);
          ShowControl(myControl);
          InsetRect(loc,-3,-3);
          if SetControlVisibility(myControl,false,false) = NoErr then;
          SizeControl(myControl,0,0);
          DisposeControl(myControl);
          ValidRect(loc);
        end;
    end;
end;

{Vous etes-vous rappelé de rajouter un espace au plus long item du menu avec Resedit ? :-) }
{procedure DrawPUItem(theMenu: MenuRef; item: SInt16; loc: Rect; drawMark: boolean);
	var
		iStrg: str255;
		chStyle: Style;
		InfosPolice: FontInfo;
		mark : char;
		UnePicture: PicHandle;
		r: Rect;
		ps: PenState;
		font, size: SInt16; 
		face: Style;

begin
	if theMenu <> NIL then
		begin
			GetPenState(ps);
			font := qdThePort()^.txFont;
			size := qdThePort()^.txSize;
			face := qdThePort()^.txFace;
			GetMenuItemText(theMenu, item, iStrg);
			TextMode(srcOr);
			TextFont(systemFont);
			TextSize(0);
			TextFace(normal);
			GetFontInfo(InfosPolice);
			CalcMenuSize(theMenu);
			loc.right := loc.left + theMenu^^.menuWidth;
			loc.bottom := loc.top + 16;
			InsetRect(loc, -1, -1);
			Moveto(loc.left + 2, loc.bottom);
			Lineto(loc.right, loc.bottom);
			Lineto(loc.right, loc.top + 2);
			EraseRect(loc);
			FrameRect(loc);
			GetItemMark(theMenu, item, mark);
			if drawMark & (Ord(mark) <> noMark) then
				begin
					Moveto(loc.left + 3, loc.top + Succ(InfosPolice.ascent));
					DrawString(mark);
				end;

			Moveto(loc.left + InfosPolice.widMax + 1, loc.top + Succ(InfosPolice.ascent));
			if item > 0 then
				begin
					GetItemStyle(theMenu, item, chStyle);
					TextFace(chStyle);
				end;
			DrawString(iStrg);
			TextFace(normal);
			if not IsMenuItemEnable(theMenu, item) | not odd(theMenu^^.EnableFlags) then
				begin
					PenPat(grayPattern);
					PenMode(patBic);
					r := loc;
					InsetRect(r, 1, 1);
					PaintRect(r);
				end;
			if odd(theMenu^^.EnableFlags) & (MyCountMenuItems(theMenu) > 1) then
				begin
					UnePicture := GetPicture(132);
					if UnePicture <> NIL then
						begin
							r := UnePicture^^.picframe;
							OffsetRect(r, Loc.right - 19, Loc.top);
							PenMode(patOr);
							DrawPicture(UnePicture, r);
							ReleaseResource(Handle(UnePicture));
						end;
				end;
			TextFont(font);
			TextSize(size);
			TextFace(face);
			SetPenState(ps);
		end;
end;
}

(*
function IsMenuItemEnable(menu: MenuRef; item: SInt16): Boolean;
	var
		bitNum: SInt16; 
begin
	if item > 31 then
		IsMenuItemEnable := True
	else
		begin
			bitNum := 31 - item;
			IsMenuItemEnable := BitTst(@menu^^.EnableFlags, bitNum);
		end;
end;
*)

function NewMenuFlottant(whichID: SInt32; whichrect: Rect; whichItem: SInt16): MenuFlottantRec;
	var
		aux: MenuFlottantRec;
begin
	with aux do
		begin
			theID := whichID;
			theMenu := NIL;
			theControl := NIL;
			theWindow := NIL;
			theRect := whichRect;
			theMenuWidth := 0;
			theItem := whichItem;
			checkedItems := [];
			provientDUneResource := false;
			installe := false;
		end;
	NewMenuFlottant := aux;
end;

procedure SetItemMenuFlottant(var whichMenuFlottant:MenuFlottantRec;whichItem : SInt16; var change : boolean);
var oldItem : SInt16; 
begin
  with whichMenuFlottant do
    begin
		  oldItem := theItem;
		  if oldItem<>whichItem then
		    begin
		      theItem := whichItem;
		      change := true;
		    end;
		  if theControl <> NIL then SetControlValue(theControl,theItem);
    end;
end;

procedure EffaceMenuFlottant(var whichMenuFlottant:MenuFlottantRec);
var unRect : rect;
begin
  unRect := whichMenuFlottant.theRect;
	if gIsRunningUnderMacOSX
	  then 
	    begin
	      InsetRect(unRect,-5,-3);
	      OffSetRect(unRect,4,1);
	    end
	  else InsetRect(unRect,-2,-2);
	EraseRect(unRect);
end;

procedure CalculateMenuFlottantSize(var whichMenuFlottant:MenuFlottantRec);
begin 
  with whichMenuFlottant do
    if (theMenu <> NIL) then
      begin
        CalcMenuSize(theMenu);
        theMenuWidth := GetMenuWidth(theMenu) + 5;
      end;
end;

procedure DrawPUItemMenuFlottant(var whichMenuFlottant: MenuFlottantRec; drawMark: boolean);
var oldPort : grafPtr;
begin
  with whichMenuFlottant do
    if theMenu <> NIL then
	    begin
	      if (theWindow = NIL) | (theControl = NIL)
	        then 
	          DrawPUItem(theMenu, theItem, theRect, drawMark)
	        else
	          begin
	            GetPort(oldPort);
	            SetPortByWindow(theWindow);
	            if SetControlVisibility(theControl,true,true) = NoErr then;
	            Draw1Control(theControl);
	            SetPort(oldPort);
	          end;
			end;
end;

procedure CalculateMenuFlottantControl(var whichMenuFlottant: MenuFlottantRec;whichWindow : WindowPtr);
var theMenuID : SInt16; 
    myRect : rect;
begin

  if not(unit_MacExtras_initialisee) then
    InitUnitMacExtras(false);

  with whichMenuFlottant do
    if (whichWindow <> NIL) & (theMenu <> NIL) then
		  begin
		    theWindow := whichWindow;
		    
		    theMenuID := GetMenuID(theMenu);
		    myRect := theRect;
		    if gWindowsHaveThickBorders | gIsRunningUnderMacOSX {Appearence extension present ?}
		      then myRect.right := myRect.left + theMenuWidth + 2
		      else myRect.right := myRect.left + theMenuWidth + 6;
				myRect.bottom := myRect.top + 19;
				OffsetRect(myRect,-1,-1);
	      theControl := NewControl(whichWindow,myRect,'',false,popupTitleRightJust,theMenuID,0,popupMenuProc,0);
	      if theControl <> NIL then 
	        begin
	          SetControlValue(theControl,theItem);
	        end;
		  end;
end;

procedure InstalleMenuFlottant(var whichMenuFlottant: MenuFlottantRec;whichWindow : WindowPtr);
begin
	with whichMenuFlottant do
		begin
			theMenu := MyGetMenu(theID);
			if theMenu <> NIL then
			  begin
			    provientDUneResource := true;
			    installe := true;
			    EnleveEspacesDeDroiteItemsMenu(theMenu);
			    InsertMenu(theMenu, -1);
			    CalculateMenuFlottantSize(whichMenuFlottant);
			    CalculateMenuFlottantControl(whichMenuFlottant,whichWindow);
			  end;
		end;
end;


procedure DesinstalleMenuFlottant(var whichMenuFlottant: MenuFlottantRec);
begin
	with whichMenuFlottant do
	  begin
	    if installe & (theMenu <> NIL) then
				begin
				  if not(installe) then 
				    TraceLog('WARNING : desinstallation d''un menu non installe !');
				  DeleteMenu(theID);
				  TerminateMenu(theMenu,provientDUneResource);
				end;
			if theControl <> NIL then
			  begin
			    if SetControlVisibility(theControl,false,false) = NoErr then;
			    DisposeControl(theControl);
			    theControl := NIL;
			  end;
	 end;
end;

function EventPopUpItemMenuFlottant(var whichMenuFlottant: MenuFlottantRec; drawChoice, checkChoiceBefore,checkChoiceAfter: Boolean) : boolean;
var result : boolean;
begin
  if unit_MacExtras_debuggage then WritelnDansRapport('entree dans EventPopUpItemMenuFlottant');
	with whichMenuFlottant do
		begin
		  if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItemMenuFlottant : avant EventPopUpItem');
			result := EventPopUpItem(theMenu, theItem, theRect, drawChoice, checkChoiceBefore);
			if result & (theItem > 0) & (theControl <> NIL) then SetControlValue(theControl,theItem);
			if checkChoiceAfter & result & (theItem > 0) & (theItem < 127) then
				begin
				  if theItem in checkedItems then
						begin
							checkedItems := checkedItems - [theItem];
							MyCheckItem(theMenu, theItem, False);
						end
					else
						begin
							checkedItems := checkedItems + [theItem];
							MyCheckItem(theMenu, theItem, true);
						end;
				end;
		  EventPopUpItemMenuFlottant := result;
		end;
  if unit_MacExtras_debuggage then WritelnDansRapport('sortie de EventPopUpItemMenuFlottant');
end;

procedure CheckOnlyThisItem(var whichMenuFlottant: MenuFlottantRec;whichItem : SInt16);
var i : SInt16; 
begin
  with whichMenuFlottant do
    begin
      for i := 1 to MyCountMenuItems(theMenu) do
        if (i=whichItem)
          then MyCheckItem(theMenu,i,true)
          else MyCheckItem(theMenu,i,false);
      checkedItems := [whichItem];
    end;
end;

(*
{Dessine la petite icone pointee par hdl(16*16*1) en position r.}
{ L'index commence a 0 (s'il est superieur, hdl doit etre une 'SICN'). }
procedure PlotSmallIcon(r: Rect; hdl: Handle; index: SInt16);
	var
		bit: BitMap;
begin
	HLockHi(hdl);
	with bit do
		begin
			SetRect(bounds, 0, 0, 16, 16);
			rowBytes := 2;
			baseAddr := hdl^;
			baseAddr := Ptr(Ord4(baseAddr) +(index * 32));
		end;
	CopyBits(bit, qdThePort()^.portBits, bit.bounds, r, qdThePort()^.pnMode, NIL);
end;
*)

(*
{dessine la petite icone 16 couleur pointee par hdl(16*16) en position r.}
procedure Plot16ColorSmallIcon(r: rect; h: UnivHandle);
	type
		bmHandle = ^bmPtr;
		bmPtr = ^BitMap;
	var
		pix: PixMapHandle;
		gDevice: GDHandle;
		oldpm: CTabHandle;
begin
	pix := NewPixMap;
	HLock(Handle(pix));
	with pix^^ do
		begin
			baseAddr := h^;
			rowBytes := $8008;  {16*4 = 64 bits = 8 octets}
			SetRect(bounds, 0, 0, 16, 16);
			gDevice := GetGDevice;
			oldPm := pmTable;
			pmTable := gDevice^^.gdPMap^^.pmTable;
		end;
	CopyBits(bmHandle(pix)^^, qdThePort()^.portBits, pix^^.bounds, r, qdThePort()^.pnMode, NIL);
	pix^^.pmTable := oldpm;
	DisposePixMap(pix);
end;
*)


function GetWDName(WDRefNum: SInt16): string;
	var
		parmBlock: CInfoPBRec;
		OSError: OSErr;
		fileName, pathName: string;
		done: boolean;
begin
	pathName := '';
	done := false;
	with parmBlock do
		begin
			ioCompletion := NIL;
			ioNamePtr := @fileName;
			ioVrefNum := WDRefNum;
			ioFDirIndex := -1;
			ioDirID := 0;
		end;
	OSError := PBGetCatInfoSync(@parmBlock);
	if OSError = noErr then
		begin
			fileName := Concat(fileName, ':');
			insert(fileName, pathName, 1);
		end;
	repeat
		with parmBlock do
			begin
				ioCompletion := NIL;
				ioNamePtr := @fileName;
				ioVRefNum := WDRefNum;
				ioFDirIndex := -1;
				ioDirID := ioDrParId;
			end;
		OSError := PBGetCatInfoSync(@parmBlock);
		if OSError = noErr then
			begin
				filename := Concat(filename, ':');
				insert(filename, pathname, 1);
			end;
	until OSError <> 0;
	GetWDName := pathName;
end;

function ChangeDir(pathName: string): OSErr;
	var
		parmBlock: WDPBRec;
begin
	with parmBlock do
		begin
			ioCompletion := NIL;
			ioNamePtr := @pathName;
			ioVRefNum := 0;
			ioWDDirID := 0;
		end;
	changeDir := PBHSetVolSync(@parmBlock);
end;

function GetApplicationName(default: str255): str255;
	var
		CurrentPSN: ProcessSerialNumber;
		ProcessInfo: ProcessInfoRec;
		err: OSErr;
		myFSSpec: FSSpec;
		myString: str255;
begin
	GetApplicationName := default;  {nom par défaut si le reste ne marche pas, e.g. sur un PC}

	if not(HasGestaltAttr(gestaltOSAttr, gestaltLaunchControl)) then
		exit(GetApplicationName);

	CurrentPSN.highLongOfPSN := 0;
	CurrentPSN.lowLongOfPSN := kCurrentProcess;

	err := GetCurrentProcess(CurrentPSN);
	if err <> 0 then
		exit(GetApplicationName);

	ProcessInfo.processInfoLength := sizeof(ProcessInfoRec);
	ProcessInfo.processName := @myString;
	ProcessInfo.processAppSpec := @myFSSpec;

	err := GetProcessInformation(CurrentPSN, ProcessInfo);
	if err <> 0 then
		exit(GetApplicationName)
	else
		GetApplicationName := ProcessInfo.processname^;
end;


function GetUserName(): str255;
var result : str255;
    textStringRef:CFStringRef;
    useShortName : boolean;
begin
  result := '';
  
  useShortName := true;
  textStringRef := CSCopyUserName(useShortName); 
  if (textStringRef <> NIL) then
    begin
      if CFStringGetPascalString(textStringRef,@result,256,CFStringGetSystemEncoding()) then;
      
      if (textStringRef <> NIL) then CFRelease(CFTypeRef(textStringRef));
    end;
  
  GetUserName := result;
end;

procedure ShareTimeWithOtherProcesses(quantity : SInt32);
var bidbool : boolean;
    bidEvent : eventRecord;
begin
  bidbool := WaitNextEvent(0,bidEvent,quantity,NIL);
end;

function MyTrunc(x : double_t) : SInt32;
begin
  MyTrunc := roundtol(Trunc(x));
end;

function RealToLongint(r : extended) : SInt32;
begin
  RealToLongint := MyTrunc(r);
end;

function RandomLongint() : SInt32;
var aux1,aux2 : SInt32;
begin
  aux1 := Random();
  aux2 := Random();
  RandomLongint := aux1+aux2*65536;
end;

procedure RandomizeTimer;
var alea : SInt32;
begin
  alea := Random();
  if (alea = 0) then alea := 1;
  alea := alea + NewMagicCookie();
  SetQDGlobalsRandomSeed(TickCount()+alea);
end;

{function Min(a, b: SInt32): SInt32;
begin
	if a < b then
		min := a
	else
		min := b;
end;}

{function Max(a, b: SInt32): SInt32;
begin
	if a > b then
		max := a
	else
		max := b;
end;}

function Signe(n : SInt32) : SInt32;
begin
  if n>0 then Signe := 1 else
  if n=0 then Signe := 0 else
  Signe := -1;
end;

{renvoie la valeur de y pour que (x,y) soit sur la droite(x1,y1),(x2,y2) }
function InterpolationLineaire(x, x1, y1, x2, y2: SInt32): SInt32;
begin
	if x1 = x2 then
		InterpolationLineaire := (y1 + y2) div 2    { should never happen !!! }
	else
		InterpolationLineaire := y1 + (((x - x1) * (y2 - y1)) div (x2 - x1));
end;

{renvoie la valeur de x+y en faisant attention a de pas depasser bornesuperieure }
{x,y,bornesuperieure sont supposes etre vaguement positifs}
function SafeAdd(x,y,bornesuperieure : SInt32) : SInt32;
begin
  if (x >(bornesuperieure - y)) | (y >(bornesuperieure - x))
    then SafeAdd := bornesuperieure
    else SafeAdd := x+y;
end;

function RandomEntreBornes(a, b: SInt16): SInt16; 
	var
		len: SInt16; 
begin
	len := (b - a + 1);
	if len <= 0 then
		RandomEntreBornes := -1
	else
		RandomEntreBornes := a +(Abs(Random()) mod len)
end;

function RandomLongintEntreBornes(a, b: SInt32): SInt32;
	var
		len: SInt32;
begin
	len := (b - a + 1);
	if len <= 0 then
		RandomLongintEntreBornes := -1
	else
		RandomLongintEntreBornes := a +(Abs(RandomLongint()) mod len)
end;

function PChancesSurN(P,N : SInt32) : boolean;
begin
  if (0<=P) & (P<=N) & (0<N)
    then
      begin
        RandomizeTimer;
        PChancesSurN := ((Abs(RandomLongint()) mod N) < P);
      end
    else 
      begin
        SysBeep(0);
        PChancesSurN := false;
      end;
end;

function UneChanceSur(N : SInt32) : boolean;
begin
  UneChanceSur := PChancesSurN(1,N);
end;


function EscapeDansQueue() : boolean;
	var
		myLocalEvent: eventrecord;
begin
	EscapeDansQueue := false;
	if EventAvail(KeyDownMask+AutoKey, myLocalEvent) then
		begin
			if BAND(myLocalEvent.message, charCodeMask) = EscapeKey then   {27=escape}
				begin
					EscapeDansQueue := true;
					exit(EscapeDansQueue);
				end;
				
			if BAND(myLocalEvent.modifiers, cmdKey) <> 0 then        {commande-point}
				if BAND(myLocalEvent.message, charCodeMask) = ord('.') then
					begin
						EscapeDansQueue := true;
						exit(EscapeDansQueue);
					end;
		  
		  if BAND(myLocalEvent.modifiers, cmdKey) <> 0 then        {commande-q}
				if BAND(myLocalEvent.message, charCodeMask) = ord('q') then
					begin
						EscapeDansQueue := true;
						exit(EscapeDansQueue);
					end;
					
			if BAND(myLocalEvent.modifiers, cmdKey) <> 0 then        {commande-Q}
				if BAND(myLocalEvent.message, charCodeMask) = ord('Q') then
					begin
						EscapeDansQueue := true;
						exit(EscapeDansQueue);
					end;
		end;
end;



procedure EnableAppleMenuForDialog;
	var
		i: SInt16; 
begin
	if applemenu <> NIL then
		begin
			MyEnableItem(applemenu, 0);
			for i := 1 to nombreItemsAGriser do
				MyDisableItem(applemenu, i);
		end;
end;



procedure MyGetKeys(var theKeys: myKeyMap);
	type
		myKeyMapPtr = ^myKeyMap;
	var
		aux: KeyMap;
		aux2: myKeyMapPtr;
begin
	GetKeys(aux);
	aux2 := myKeyMapPtr(@aux);
	theKeys := aux2^;
end;

function ToucheAppuyee(KeyCode: SInt16): boolean;
	var
		theKeys: myKeyMap;
		i, j: SInt16; 
		b, masque: SInt16; 
begin
	MyGetKeys(theKeys);
	i := keyCode div 8;
	j := keyCode mod 8;
	b := theKeys[i];
	masque := BSL(1, j);
	ToucheAppuyee := BAND(b, masque) <> 0;
end;

function MemesTouchesAppuyees(var keyMap1, keyMap2: myKeyMap): boolean;
	var
		i: SInt16; 
begin
	for i := 0 to 15 do
		if keyMap1[i] <> keyMap2[i] then
			begin
				MemesTouchesAppuyees := false;
				exit(MemesTouchesAppuyees);
			end;
	MemesTouchesAppuyees := true;
end;


function DateEnString(const whichDate : DateTimeRec) : string;
var s : str255;
begin
  with whichDate do
    s := NumEnStringAvecFormat(year,4) + 
         NumEnStringAvecFormat(month,2) + 
         NumEnStringAvecFormat(day,2) + 
         NumEnStringAvecFormat(hour,2) +
         NumEnStringAvecFormat(minute,2) + 
         NumEnStringAvecFormat(second,2);
  DateEnString := s;
end;


function DateCouranteEnString() : string;
var myDate : DateTimeRec;
begin
  GetTime(myDate);
  DateCouranteEnString := DateEnString(myDate);
end;



procedure SetFileCreator(fichier: FSSpec; QuelType: OSType);
	var
		InfosFinder: FInfo;
		err: OSErr;
begin
	err := FSpGetFInfo(fichier, InfosFinder);
	InfosFinder.fdCreator := QuelType;
	err := FSpSetFInfo(fichier, InfosFinder);
end;

procedure SetFileType(fichier: FSSpec; QuelType: OSType);
	var
		InfosFinder: FInfo;
		err: OSErr;
begin
	err := FSpGetFInfo(fichier, InfosFinder);
	InfosFinder.fdType := QuelType;
	err := FSpSetFInfo(fichier, InfosFinder);
end;


function MySwapInteger(num: SInt16): SInt16; 
	type
		TwoBytesArray = packed array[0..1] of byte;
	var
		twoBytes: ^TwoBytesArray;
		result,aux : SInt32;
begin
	twoBytes := @num;
	result := 0;
	
	aux := twoBytes^[0];
	result := result + aux;
	aux := twoBytes^[1];
	aux := aux*256;
	result := result + aux;
	
	mySwapInteger := result;
end;


function MySwapLongint(num: SInt32): SInt32;
	var
		FourBytes: ^FourBytesArray;
		result,aux : SInt32;
begin
	FourBytes := @num;
	result := 0;
	
	aux := FourBytes^[0];
	result := result + aux;
	aux := FourBytes^[1];
	aux := aux*256;
	result := result + aux;
	aux := FourBytes^[2];
	aux := aux*65536;
	result := result + aux;
	aux := FourBytes^[3];
	aux := aux*16777216;
	result := result + aux;
	
	mySwapLongint := result;
end;

{}
{function MySwapInteger(twoBytes: UNIV TwoBytesArray) : SInt16; }
{begin}
{  mySwapInteger := 256*twoBytes[1]+twoBytes[0];}
{end;}
{}
{function MySwapLongint(FourBytes: UNIV FourBytesArray) : SInt32;}
{begin}
{  mySwapLongint := 16777216*FourBytes[3]+}
{                 65536   *FourBytes[2]+}
{                 256     *FourBytes[1]+}
{                          FourBytes[0];}
{end;}
{}

function BooleanXor(b1, b2: boolean): boolean;
begin
	BooleanXor := (b1 & not(b2)) | (b2 & not(b1));
end;

function ProfondeurMainDevice(): SInt16; 
	var
		mainDev: GDHandle;
		depth: SInt16; 
begin
	mainDev := GetMainDevice();
	depth := mainDev^^.gdPMap^^.pixelSize;
	ProfondeurMainDevice := depth;
end;

function EstUnAscenseurAvecDoubleScroll(theScroller: ControlHandle; var contourAscenseurRect, regionGriseeRect: rect; var estHorizontal: boolean): boolean;
	var
		testPoint: point;
		oldport: GrafPtr;
		offset: SInt16; 
		ignoreRectPtr:RectPtr;
begin
	EstUnAscenseurAvecDoubleScroll := false;

	if (theScroller <> NIL) then
		begin
			GetPort(oldport);
			SetPortByWindow(GetControlOwner(theScroller));
			ignoreRectPtr := GetControlBounds(theScroller,contourAscenseurRect);
			with contourAscenseurRect do
				if right - left > bottom - top then
					begin
						EstHorizontal := true;
						testpoint.v := (contourAscenseurRect.top + contourAscenseurRect.bottom) div 2;
						testpoint.h := contourAscenseurRect.left + 24;
						if testControl(theScroller, testpoint) = kControlDownButtonPart then
							begin
								EstUnAscenseurAvecDoubleScroll := true;
								offset := 32;
							end
						else
							begin
								EstUnAscenseurAvecDoubleScroll := false;
								offset := 16;
							end;
						regionGriseeRect := contourAscenseurRect;
						regionGriseeRect.left := regionGriseeRect.left + offset;
						regionGriseeRect.right := regionGriseeRect.right - offset;
					end
				else
					begin
						EstHorizontal := false;
						testpoint.h := (contourAscenseurRect.left + contourAscenseurRect.right) div 2;
						testpoint.v := contourAscenseurRect.top + 24;
						if testControl(theScroller, testpoint) = kControlDownButtonPart then
							begin
								EstUnAscenseurAvecDoubleScroll := true;
								offset := 32;
							end
						else
							begin
								EstUnAscenseurAvecDoubleScroll := false;
								offset := 16;
							end;
						regionGriseeRect := contourAscenseurRect;
						regionGriseeRect.top := regionGriseeRect.top + offset;
						regionGriseeRect.bottom := regionGriseeRect.bottom - offset;
					end;
			SetPort(oldport);
		end;
end;


function SmartScrollEstInstalle(theScroller: ControlHandle; var proportion: fixed): boolean;
	var
		propFract: Fract;
begin
{$IFC TARGET_API_MAC_CARBON_DANS_CASSIO }
  {$UNUSED propFract, theScroller, proportion}
  SmartScrollEstInstalle := false;
{$ELSEC }
	propFract := GetSmartScrollProp(theScroller);
	proportion := Frac2Fix(propFract);
	SmartScrollEstInstalle := propFract <> 0;
{$ENDC}
end;

function EgalitePolymorphe(ptr1, ptr2: univ PackedArrayOfCharPtr; tailleDonnees: SInt32): boolean;
	var
		i: SInt32;
begin
	for i := 0 to tailleDonnees - 1 do
		if ptr1^[i] <> ptr2^[i] then
			begin
				EgalitePolymorphe := false;
				exit(EgalitePolymorphe);
			end;
	EgalitePolymorphe := true;
end;

function QuelCaractereDeControle(c : char; enMajuscule: boolean) : char;  { si c= ^H, QuelCaractereDeControle(c)=H  etc.}
	var
		codeAscii: SInt16; 
begin
	codeAscii := ord(c);
	if (codeAscii < 1) | (codeAscii > 26) then
		QuelCaractereDeControle := c
	else if enMajuscule then
		QuelCaractereDeControle := chr(codeAscii + ord('A') - 1)
	else
		QuelCaractereDeControle := chr(codeAscii + ord('a') - 1);
end;


function CreerCaractereAvecOption(c : char) : char;   {si c=T, CreerCaractereAvecOption(c)=option-T=™   etc.}
begin
	case c of
		'a': 
			CreerCaractereAvecOption := 'æ';
		'b': 
			CreerCaractereAvecOption := 'ß';
		'c': 
			CreerCaractereAvecOption := '©';
		'd': 
			CreerCaractereAvecOption := '∂';
		'e': 
			CreerCaractereAvecOption := 'ê';
		'f': 
			CreerCaractereAvecOption := 'ƒ';
		'g': 
			CreerCaractereAvecOption := 'ﬁ';
		'h': 
			CreerCaractereAvecOption := 'Ì';
		'i': 
			CreerCaractereAvecOption := 'î';
		'j': 
			CreerCaractereAvecOption := 'Ï';
		'k': 
			CreerCaractereAvecOption := 'È';
		'l': 
			CreerCaractereAvecOption := '¬';
		'm': 
			CreerCaractereAvecOption := 'µ';
		'n': 
			CreerCaractereAvecOption := '~';
		'o': 
			CreerCaractereAvecOption := 'œ';
		'p': 
			CreerCaractereAvecOption := 'π';
		'q': 
			CreerCaractereAvecOption := '‡';
		'r': 
			CreerCaractereAvecOption := '®';
		's': 
			CreerCaractereAvecOption := 'Ò';
		't': 
			CreerCaractereAvecOption := '†';
		'u': 
			CreerCaractereAvecOption := 'º';
		'v': 
			CreerCaractereAvecOption := '◊';
		'w': 
			CreerCaractereAvecOption := '‹';
		'x': 
			CreerCaractereAvecOption := '≈';
		'y': 
			CreerCaractereAvecOption := 'Ú';
		'z': 
			CreerCaractereAvecOption := 'Â';
		'A': 
			CreerCaractereAvecOption := 'Æ';
		'B': 
			CreerCaractereAvecOption := '∫';
		'C': 
			CreerCaractereAvecOption := '¢';
		'D': 
			CreerCaractereAvecOption := '∆';
		'E': 
			CreerCaractereAvecOption := 'Ê';
		'F': 
			CreerCaractereAvecOption := '·';
		'G': 
			CreerCaractereAvecOption := 'ﬂ';
		'H': 
			CreerCaractereAvecOption := 'Î';
		'I': 
			CreerCaractereAvecOption := 'ï';
		'J': 
			CreerCaractereAvecOption := 'Í';
		'K': 
			CreerCaractereAvecOption := 'Ë';
		'L': 
			CreerCaractereAvecOption := '|';
		'M': 
			CreerCaractereAvecOption := 'Ó';
		'N': 
			CreerCaractereAvecOption := 'ı';
		'O': 
			CreerCaractereAvecOption := 'Œ';
		'P': 
			CreerCaractereAvecOption := '∏';
		'Q': 
			CreerCaractereAvecOption := 'Ω';
		'R': 
			CreerCaractereAvecOption := '€';
		'S': 
			CreerCaractereAvecOption := '∑';
		'T': 
			CreerCaractereAvecOption := '™';
		'U': 
			CreerCaractereAvecOption := 'ª';
		'V': 
			CreerCaractereAvecOption := '√';
		'W': 
			CreerCaractereAvecOption := '›';
		'X': 
			CreerCaractereAvecOption := '⁄';
		'Y': 
			CreerCaractereAvecOption := 'Ÿ';
		'Z': 
			CreerCaractereAvecOption := 'Å';
		otherwise
			CreerCaractereAvecOption := c;
	end; {case}
end;


procedure EmuleToucheCommandeParControleDansEvent(var myEvent: eventrecord);  {émulation de la pomme avec la touche ctrl}
	var
		option, shift, verouillage: boolean;
		ch, aux : char;
begin
	if (BAND(myEvent.modifiers, controlKey) <> 0) & (BAND(myEvent.modifiers, cmdKey) = 0) then
		begin
			shift := BAND(myEvent.modifiers, shiftKey) <> 0;
			verouillage := BAND(myEvent.modifiers, alphaLock) <> 0;
			option := BAND(myEvent.modifiers, optionKey) <> 0;

      {modification de l'evenement}
			myEvent.modifiers := BitXor(myEvent.modifiers, controlKey);
			myEvent.modifiers := BitXor(myEvent.modifiers, cmdKey);

			if (myEvent.what = keyDown) | (myEvent.what = autoKey) | (myEvent.what = keyUp) then
				begin
					ch := chr(BAND(myEvent.message, charCodeMask));
					aux := QuelCaractereDeControle(ch, shift | verouillage);
					if option & (((aux >= 'a') & (aux <= 'z')) | ((aux >= 'A') & (aux <= 'Z'))) then
						aux := CreerCaractereAvecOption(aux);

					myEvent.message := BitAnd(myEvent.message, BitNot(charCodeMask));
					myEvent.message := BitOr(myEvent.message, ord(aux));
				end;

		end;
end;



procedure DragLine(whichWindow : WindowPtr; orientation: SInt16; UtiliseHiliteMode: boolean; minimum, maximum, step: SInt32; var positionSouris, index: SInt32; Action: ProcedureTypeWithLongint);
	var
		epaisseur: SInt16; 
		mouseLoc: Point;
		DernierePositionDessinee: SInt32;
		DragCursor: CursHandle;
		oldPort : grafPtr;

	procedure DrawLine(position: SInt32);
		var
			unRect: rect;
	begin
	  SetPortByWindow(whichWindow);
	  
		if orientation = kDragVerticalLine then
			SetRect(unRect, position, 0, position + epaisseur, QDGetPortBound().bottom)
		else
			SetRect(unRect, 0, position, QDGetPortBound().right, position + epaisseur);
		if UtiliseHiliteMode then
			HiliteRect(unRect)
		else
			begin
				Moveto(unRect.left, unRect.top);
				Lineto(unRect.right, unRect.bottom);
			end;
		DernierepositionDessinee := position;
	end;

begin
  GetPort(oldPort);
  
	if (step <= 0) then
		step := 1;
	if (maximum < minimum) then
		maximum := minimum;

	if positionSouris < minimum then
		positionSouris := minimum;
	if positionSouris > maximum then
		positionSouris := maximum;

	index := (positionSouris - minimum) div step;

	if StillDown() then
		begin
		  SetPortByWindow(whichWindow);
			if UtiliseHiliteMode then
				epaisseur := 2
			else
				begin
					PenPat(grayPattern);
					PenSize(2, 2);
					PenMode(PatXor);
					epaisseur := 0;
				end;

			if orientation = kDragVerticalLine then
				DragCursor := GetCursor(DragLineVerticalCurseurID)
			else
				DragCursor := GetCursor(DragLineHorizontalCurseurID);
			SafeSetCursor(DragCursor);

			DrawLine(positionSouris);
			ShareTimeWithOtherProcesses(2);    {draw !}
			
			while Button() do
				begin
					GetMouse(mouseLoc);
					if orientation = kDragVerticalLine then
						positionSouris := mouseLoc.h
					else
						positionSouris := mouseLoc.v;
					if positionSouris < minimum then
						positionSouris := minimum;
					if positionSouris > maximum then
						positionSouris := maximum;
					if step < 4 then
						index := (positionSouris - minimum) div step
					else
						index := (positionSouris - minimum +(step div 2)) div step; { +(step div 2) : pour centrer les sauts}
					positionSouris := minimum + index * step;
					if positionSouris > maximum then
						positionSouris := maximum;

					if positionSouris <> DernierePositionDessinee then
						begin
							DrawLine(DernierePositionDessinee);
							DrawLine(positionSouris);
							Action(index);
							ShareTimeWithOtherProcesses(2); {draw !}
						end;
				end;
			DrawLine(dernierePositionDessinee);
			PenNormal;
			InitCursor;
			ShareTimeWithOtherProcesses(2); {draw !}
		end;
  SetPort(oldPort);
end;

procedure DessineLigne(source,dest : Point);
begin
  Moveto(source.h,source.v);
  Lineto(dest.h,dest.v);
end;

procedure DessineFleche(source,dest : Point;longueur_max_pointe : double_t);
var x,y,theta : double_t;
    angle_pointe_fleche : double_t;
    longueur_pointe_fleche : double_t;
    x0,y0 : SInt32;
begin
  
  DessineLigne(source,dest);
  
  x := dest.h - source.h;
  y := dest.v - source.v;
  
  theta := atan2(y,x);
  
  angle_pointe_fleche := 0.5;  {0.5 radians}
  
  longueur_pointe_fleche := 0.25 * sqrt(x*x + y*y);  
  if longueur_pointe_fleche > longueur_max_pointe then
    longueur_pointe_fleche := longueur_max_pointe; 
  
  x0 := RoundToL(dest.h - cos(theta + angle_pointe_fleche) * longueur_pointe_fleche);
  y0 := RoundToL(dest.v - sin(theta + angle_pointe_fleche) * longueur_pointe_fleche);
  DessineLigne(MakePoint(x0,y0),dest);
  
  x0 := RoundToL(dest.h - cos(theta - angle_pointe_fleche) * longueur_pointe_fleche);
  y0 := RoundToL(dest.v - sin(theta - angle_pointe_fleche) * longueur_pointe_fleche);
  DessineLigne(MakePoint(x0,y0),dest);
  
end;


function BoutonAppuye(whichWindow: WindowPtr; Rectangle: rect): boolean;
	var
		test: boolean;
		oldPort: GrafPtr;
		mouseLoc: point;
begin
	test := false;
	if Button() then
		begin
			GetPort(oldPort);
			SetPortByWindow(whichWindow);
			GetMouse(mouseLoc);
			test := PtInRect(mouseLoc, rectangle);
			SetPort(oldPort);
			ShareTimeWithOtherProcesses(2);
		end;
	BoutonAppuye := test;
end;

procedure IdentiteSurN(var N: SInt32);
begin
  {$UNUSED N}
end;

function FonctionTrue(): boolean;
begin
	FonctionTrue := true;
end;

function FonctionFalse(): boolean;
begin
	FonctionFalse := false;
end;

function PuissanceReelle(x,exposant : extended) : extended;
begin
  if x <= 0.0
    then PuissanceReelle := 0.0
    else PuissanceReelle := exp( exposant * ln(x));
end;


function Puissance(r : extended;n : SInt32) : extended;
var i : SInt16; 
    aux : extended;
begin
  aux := 1.0;
  for i := 1 to n do
    aux := aux*r;
  Puissance := aux;
end;



{donne un identificateur unique et positif
 la periode est de 2^31 }
function NewMagicCookie() : SInt32;
begin
  inc(unit_MacExtras_magicCookieSeed);
  if unit_MacExtras_magicCookieSeed <= 0 
    then unit_MacExtras_magicCookieSeed := 1;
  NewMagicCookie := unit_MacExtras_magicCookieSeed;
end;

function MicrosecondesToSecondes(microTicks:unsignedWide) : extended;
var result : extended;
begin
  result := 0.0;
  MicrosecondesToSecondes := microTicks.lo*0.000001 + microTicks.hi*4294.967296;
end;


function MakeCFSTR(s : str255):CFStringRef;
begin
  MakeCFSTR := CFStringCreateWithPascalString(NIL, s, kCFStringEncodingMacRoman);
end;


function LoadFrameworkBundle(inFrameworkName:CFStringRef; var outBundleRef:CFBundleRef) : OSStatus;
var
	frameworksFolderRef : FSRef	;
	baseURL : CFURLRef ;
	bundleURL : CFURLRef ;
	err : OSStatus ;
label cleanup;
begin

  baseURL := NIL;
  bundleURL := NIL;
  
	outBundleRef := NIL ;

	(*	find the Frameworks folder *)
	err := FSFindFolder(kOnAppropriateDisk, kFrameworksFolderType, kDontCreateFolder, frameworksFolderRef);
	if (err <> NoErr) then
	begin
		goto cleanup ;
	end;

	(*	convert the FSRef into a URL *)
	err := coreFoundationUnknownErr ;
	{ baseURL := CFURLCreateFromFSRef(kCFAllocatorSystemDefault, frameworksFolderRef)); }
	baseURL := CFURLCreateFromFSRef(NIL, frameworksFolderRef);
	if (baseURL = NIL) then
	begin
		goto cleanup ;
	end;

	(*	append the name of the framework to the base URL *)
	{bundleURL := CFURLCreateCopyAppendingPathComponent(kCFAllocatorSystemDefault, baseURL, inFrameworkName, false);}
	bundleURL := CFURLCreateCopyAppendingPathComponent(NIL, baseURL, inFrameworkName, false);
	if (bundleURL = NIL) then
	begin
		goto cleanup ;
	end;

	(*	create a bundle based on that URL *)
	{outBundleRef := CFBundleCreate(kCFAllocatorSystemDefault, bundleURL);}
	outBundleRef := CFBundleCreate(NIL, bundleURL);
	if (outBundleRef = NIL) then
	begin
		goto cleanup ;
	end;

	(*	load the bundle *)
	if NOT(CFBundleLoadExecutable(outBundleRef)) then
	begin
		goto cleanup ;
	end;

	(*	clear result code *)
	err := noErr ;

cleanup :
	(*	clean up *)
	if (err <> noErr) then
	begin
		if (outBundleRef <> NIL) then
		begin
			CFRelease(CFTypeRef(outBundleRef)) ;
			outBundleRef := NIL ;
		end;
	end;

	if (bundleURL <> NIL) then
	begin
		CFRelease(CFTypeRef(bundleURL)) ;
		bundleURL := NIL ;
	end;

	if (baseURL <> NIL) then
	begin
		CFRelease(CFTypeRef(baseURL)) ;
		baseURL := NIL ;
	end;

	(*	return result code *)
	LoadFrameworkBundle := err ;
end;


function GetFunctionPointerFromBundle(const whichBundle,functionName : str255) : Ptr;
var err : OSStatus;
    bundleRef : CFBundleRef;
    myCFRef:CFStringRef;
begin
  (*	load the framework *)
	  
  myCFRef := MakeCFSTR(whichBundle);
  err :=  LoadFrameworkBundle(myCFRef, bundleRef);
  CFRelease(CFTypeRef(myCFRef));
  
  if (err <> NoErr) then
    begin
      GetFunctionPointerFromBundle := NIL;
      exit(GetFunctionPointerFromBundle);
    end;
  
  myCFRef := MakeCFSTR(functionName);
	GetFunctionPointerFromBundle := CFBundleGetFunctionPointerForName(bundleRef,myCFRef);
	CFRelease(CFTypeRef(myCFRef));
end;


type SwapQDTextFlagsProcPtr = function(newFlags : UInt32) : UInt32;
type QDSwapPortTextFlagsPtr = function(port : CGrafPtr;newFlags : UInt32) : UInt32;

const SwapQDTextFlagsProcInitialise : boolean = false;
const QDSwapPortTextFlagsInitialise : boolean = false;
      

var MySwapQDTextFlagsProc : SwapQDTextFlagsProcPtr;
var MyQDSwapPortTextFlagsProc : QDSwapPortTextFlagsPtr;
    
    
const kQDUseTrueTypeScalerGlyphs = 1;
      kQDUseCGTextRendering = 2;
      kQDUseCGTextMetrics = 4;


procedure EnableQuartzAntiAliasing(useQuartzMetrics : boolean);
var savedFlags : UInt32;
    newFlags : UInt32;
begin
	(*	enable Quartz text rendering globaly, for the whole application *)
	
	if useQuartzMetrics
	  then newFlags := kQDUseTrueTypeScalerGlyphs + kQDUseCGTextRendering + kQDUseCGTextMetrics
	  else newFlags := kQDUseTrueTypeScalerGlyphs + kQDUseCGTextRendering ;
	  
	if SwapQDTextFlagsProcInitialise then
    savedFlags := MySwapQDTextFlagsProc(newFlags);
end;

procedure DisableQuartzAntiAliasing;
var savedFlags : UInt32;
begin
	(*	disable Quartz text rendering globaly, for the whole application *)
	  
	if SwapQDTextFlagsProcInitialise then
    savedFlags := MySwapQDTextFlagsProc(0);
end;
  
procedure EnableQuartzAntiAliasingThisPort(port : CGrafPtr;useQuartzMetrics : boolean);
var savedFlags : UInt32;
    newFlags : UInt32;
begin
	(*	enable Quartz text rendering for this port *)
	
	if useQuartzMetrics
	  then newFlags := kQDUseTrueTypeScalerGlyphs + kQDUseCGTextRendering + kQDUseCGTextMetrics
	  else newFlags := kQDUseTrueTypeScalerGlyphs + kQDUseCGTextRendering;
	  
	if QDSwapPortTextFlagsInitialise then
    savedFlags := MyQDSwapPortTextFlagsProc(port,newFlags);
end;

procedure DisableQuartzAntiAliasingThisPort(port : CGrafPtr);
var savedFlags : UInt32;
begin
	(*	disable Quartz text rendering for this port *)
	  
	if QDSwapPortTextFlagsInitialise then
    savedFlags := MyQDSwapPortTextFlagsProc(port,0);
end;
 
      
function InitialiseQuartzAntiAliasing() : OSErr;
var bundleRef : CFBundleRef;
    err : OSStatus;
    myCFRef:CFStringRef;
label cleanUp;
begin
  bundleRef := NIL;
  err := -1;
  
  if gIsRunningUnderMacOSX then
    begin
    
		  (*	load the ApplicationServices framework *)
		  
		  myCFRef := MakeCFSTR('ApplicationServices.framework');
		  err :=  LoadFrameworkBundle(myCFRef, bundleRef);
		  CFRelease(CFTypeRef(myCFRef));
		  
			if (err <> NoErr) then 
			  goto cleanUp;
			
			
			(*	get a pointer to the SwapQDTextFlags function *)
			err := coreFoundationUnknownErr ;
			
			myCFRef := MakeCFSTR('SwapQDTextFlags');
			MySwapQDTextFlagsProc := SwapQDTextFlagsProcPtr(CFBundleGetFunctionPointerForName(bundleRef,myCFRef));
			CFRelease(CFTypeRef(myCFRef));
			
			if (MySwapQDTextFlagsProc = NIL) 
			  then goto cleanUp
			  else SwapQDTextFlagsProcInitialise := true;
			
			
			(*	get a pointer to the SwapQDTextFlags function *)
			err := coreFoundationUnknownErr ;
			
			myCFRef := MakeCFSTR('QDSwapPortTextFlags');
			MyQDSwapPortTextFlagsProc := QDSwapPortTextFlagsPtr(CFBundleGetFunctionPointerForName(bundleRef,myCFRef));
			CFRelease(CFTypeRef(myCFRef));
			
			if (MyQDSwapPortTextFlagsProc = NIL) 
			  then goto cleanUp
			  else QDSwapPortTextFlagsInitialise := true;
			  
			

			(*	clear result code *)
			err := noErr ;
	
    end;
  
    
  cleanUp :
  InitialiseQuartzAntiAliasing := err;
  
end;


function MyGetFontNum(nomPolice : str255) : SInt16; 
var result : SInt16; 
begin
  GetFNum(nomPolice,result);
  MyGetFontNum := result;
end;


type SFPutFileProcPtr = procedure(where: Point; prompt: ConstStringPtr; origName: str255; dlgHook: DlgHookUPP; VAR reply: SFReply);


procedure MySFPutFile(where: Point; prompt: ConstStringPtr; origName: str255; dlgHook: DlgHookUPP; VAR reply: SFReply);
{$IFC CARBONISATION_DE_CASSIO}
var err : OSErr;
    connID : CFragConnectionID;
    MySFPutFileProc : SFPutFileProcPtr;
    mainAddr : Ptr;
    errMessage : str255;
    symClass : CFragSymbolClassPtr;
    symAddr : symAddrPtr;
begin
  connID := NIL;  {kInvalidID}
  MySFPutFileProc := NIL;
  mainAddr := NIL;

  err := GetSharedLibrary( "InterfaceLib", kCompiledCFragArch, kReferenceCFrag, connID, mainAddr, errMessage );
  
  {WritelnStringAndNumDansRapport('MySFPutFile : après GetSharedLibrary, err = ',err);}
                                            
  if (err = noErr) then
    begin
      err := FindSymbol( connID, "SFPutFile", symAddr, symClass);
    end;

  {WritelnStringAndNumDansRapport('MySFPutFile : après FindSymbol, err = ',err);}
  
  if (err = NoErr) then
    begin
      MySFPutFileProc := SFPutFileProcPtr(symAddr);
      
      {WritelnStringAndNumDansRapport('MySFPutFile : avant l''appel de MySFPutFileProc, err = ',err);}
      
      MySFPutFileProc(where, prompt, origName, dlgHook, reply);
      
      {WritelnStringAndNumDansRapport('MySFPutFile : après l''appel de MySFPutFileProc, err = ',err);}
    end;                                         
end;
{$ELSEC}
begin
  SFPutFile(where, prompt, origName, dlgHook, reply);
end;
{$ENDC}



type SFGetFileProcPtr = procedure(where: Point; prompt: str255; fileFilter: FileFilterUPP; numTypes: SInt16; typeList: ConstSFTypeListPtr; dlgHook: DlgHookUPP; var reply: SFReply);

procedure MySFGetFile(where: Point; prompt: str255; fileFilter: FileFilterUPP; numTypes: SInt16; typeList: ConstSFTypeListPtr; dlgHook: DlgHookUPP; var reply: SFReply);
{$IFC CARBONISATION_DE_CASSIO}
var err : OSErr;
    connID : CFragConnectionID;
    MySFGetFileProc : SFGetFileProcPtr;
    mainAddr : Ptr;
    errMessage : str255;
    symClass : CFragSymbolClassPtr;
    symAddr : symAddrPtr;
begin
  connID := NIL;  {kInvalidID}
  MySFGetFileProc := NIL;
  mainAddr := NIL;

  err := GetSharedLibrary( "InterfaceLib", kCompiledCFragArch, kReferenceCFrag, connID, mainAddr, errMessage );
  
  (* WritelnStringAndNumDansRapport('MySFGetFile : après GetSharedLibrary, err = ',err); *)
                                            
  if (err = noErr) then
    begin
      err := FindSymbol( connID, "SFGetFile", symAddr, symClass);
    end;

  (* WritelnStringAndNumDansRapport('MySFGetFile : après FindSymbol, err = ',err); *)
  
  if (err = NoErr) then
    begin
      MySFGetFileProc := SFGetFileProcPtr(symAddr);
      
      (* WritelnStringAndNumDansRapport('MySFGetFile : avant l''appel de MySFGetFileProc, err = ',err); *)
      
      MySFGetFileProc(where, prompt, fileFilter, numTypes, typeList, dlgHook, reply);
      
      (* WritelnStringAndNumDansRapport('MySFGetFile : après l''appel de MySFGetFileProc, err = ',err); *)
    end;                                         
end;
{$ELSEC}
begin
  SFGetFile(where, prompt, fileFilter, numTypes, typeList, dlgHook, reply);
end;
{$ENDC}


procedure DessineOmbreRoundRect(theRect : rect;ovalWidth,ovalHeight : SInt16; targetColor : RGBColor;tailleOmbre,forceDuGradient,ombrageMinimum,typeOmbrage : SInt32);
var ombre : rect;
    i,force : SInt32;
begin

  PenMode(patCopy);
  PenSize(1,1);

  for i := tailleOmbre downto 2 do
    begin
      
      with theRect do
        ombre := MakeRect(left {+ 4*(i div 4)}, top {+ 4*(i div 4)} , right + i , bottom + i);
  
        case (typeOmbrage mod 4) of
          0 : force := (tailleOmbre-i)*(forceDuGradient div 4);
          1 : force := ombrageMinimum + (tailleOmbre-i)*forceDuGradient;
          2 : force := (ombrageMinimum div 4 + (tailleOmbre-i)*forceDuGradient) div 4;
          3 : force := (tailleOmbre-i)*forceDuGradient div 4;
        end; {case}
        
        if (typeOmbrage >= 4) {legerement en creux}
          then
            begin
              RGBForeColor(EclaircirCouleurDeCetteQuantite(targetColor,force));
              RGBBackColor(EclaircirCouleurDeCetteQuantite(targetColor,force));
            end
          else
            begin
              RGBForeColor(NoircirCouleurDeCetteQuantite(targetColor,force));
              RGBBackColor(NoircirCouleurDeCetteQuantite(targetColor,force));
            end;
               
        FrameRoundRect(ombre,ovalWidth,ovalHeight);
        if tailleOmbre > 2 then
          begin
            dec(ombre.right);
            FrameRoundRect(ombre,ovalWidth,ovalHeight);
          end;
        
    end;
  
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
  PenSize(1,1);
end;  



end.





