UNIT UnitProgressBar;


INTERFACE







USES UnitMacExtras;


var kSteelBlueRGB : RGBColor; {une couleur que l'on peut utiliser pour dessiner des barres de progression}


procedure InitUnitProgressBar;
procedure InitProgressIndicator(whichWindow: WindowRef; r: rect; maximum: SInt32; PourKaleidoscope: boolean);
procedure SetProgress(absoluteAmount : SInt32);
procedure DrawProgressBar;
function SetProgressDelta(delta : SInt32) : boolean;
procedure UpdateProgressBar;
procedure DrawEmptyProgressBar;



IMPLEMENTATION







USES UnitCarbonisation,UnitOth0;

var  ProgressWindow : WindowRef;
     ProgressRect : rect;
     ProgressMax : SInt32;
     ProgressCurrent : SInt32;
     ProgressLastCurrent : SInt32;
     ProgressLastBorder : SInt16; 

var kBlackRGB,kWhiteRGB,kDarkGreyRGB : RGBColor;
    ProgressUsesColor : boolean;
    
    
    
procedure InitUnitProgressBar;
begin
  kSteelBlueRGB.red := $CCCC;       
  kSteelBlueRGB.green := $CCCC;       
  kSteelBlueRGB.blue := $FFFF;
end;

procedure SetFrameColor;
begin
  if ProgressUsesColor
    then
      begin
        RGBForeColor(kBlackRGB);
        RGBBackColor(kWhiteRGB);
      end
    else
      PenPat(blackPattern);
end;

procedure SetDoneColor;
begin
  if ProgressUsesColor
    then
      begin
        RGBForeColor(kDarkGreyRGB);
        RGBBackColor(kWhiteRGB);
      end
    else
      PenPat(blackPattern);
end;


procedure SetToDoColor;
begin
  if ProgressUsesColor
    then
      begin
        RGBForeColor(kSteelBlueRGB);
        RGBBackColor(kBlackRGB);
      end
    else
      PenPat(whitePattern);
end;


procedure InitProgressIndicator(whichWindow : WindowRef; r : rect; maximum : SInt32; PourKaleidoscope : boolean);
begin
  ProgressWindow := whichWindow;
  ProgressRect := r;
  if PourKaleidoscope then ProgressRect.bottom := ProgressRect.top+12;
  ProgressMax := maximum;
  ProgressCurrent := 0;
  ProgressLastCurrent := 0;
  ProgressLastBorder := 0;
  
  kBlackRGB.red := $0000;           kBlackRGB.green := $0000;            kBlackRGB.blue := $0000;
  kWhiteRGB.red := $FFFF;           kWhiteRGB.green := $FFFF;            kWhiteRGB.blue := $FFFF;
  kDarkGreyRGB.red := $4000;        kDarkGreyRGB.green := $4000;         kDarkGreyRGB.blue := $4000;
  kSteelBlueRGB.red := $CCCC;       kSteelBlueRGB.green := $CCCC;        kSteelBlueRGB.blue := $FFFF;
  
{$IFC CARBONISATION_DE_CASSIO }
  ProgressUsesColor := true;
{$ELSEC}
  ProgressUsesColor := (NGetTrapAddress($AA1E, toolTrap) <> NGetTrapAddress($A89F, toolTrap)) &
                              (ProfondeurMainDevice()>2);
{$ENDC}
  
  DrawEmptyProgressBar;
end;


procedure SetProgress(absoluteAmount : SInt32);
begin
  ProgressCurrent := absoluteAmount;
  DrawProgressBar;
end;

function SetProgressDelta(delta : SInt32) : boolean;
begin
  ProgressCurrent := ProgressCurrent+delta;
  DrawProgressBar;
  SetProgressDelta := (ProgressCurrent>=ProgressMax);
end;


procedure DrawProgressBar;
var border,rectWidth : SInt32;
begin
  if (ProgressWindow <> NIL) & 
     (ProgressLastCurrent<>ProgressCurrent) & 
     (ProgressCurrent <= ProgressMax) then
    begin
      ProgressLastCurrent := ProgressCurrent;
      rectWidth := ProgressRect.right-ProgressRect.left-2;
      border := ProgressRect.left+1+(rectwidth*ProgressCurrent) div ProgressMax;
      if ProgressLastBorder<>border then
        begin
          ProgressLastBorder := border;
          UpdateProgressBar;
        end;
    end;
end;


procedure UpdateProgressBar;
var oldport : grafPtr;
    oldForeColor,oldBackColor : RGBColor;
    doneRect,todoRect : rect;
begin
  if (ProgressWindow <> NIL) then
    begin
      doneRect := ProgressRect;
      InsetRect(doneRect,1,1);
      todoRect := doneRect;
      donerect.right := ProgressLastBorder;
      if donerect.left<donerect.right-10 then donerect.left := donerect.right-10;
      todoRect.left := ProgressLastBorder;
      
      GetPort(oldport);
      SetPortByWindow(ProgressWindow);
      GetForeColor(oldForeColor);
      GetBackColor(oldBackColor);
      PenNormal;
      
      SetFrameColor;
      FrameRect(ProgressRect);
      
      
      if ProgressUsesColor 
        then
          begin
            SetDoneColor;
            PaintRect(doneRect);
    	    
            {SetToDoColor;
            PaintRect(todoRect); 
            } 
          end
        else
          begin
            SetDoneColor;
            FillRect(doneRect,darkGrayPattern);
          { SetToDoColor;
            FillRect(doneRect,lightGrayPattern);}
          end;
      
      if (QDIsPortBuffered(GetWindowPort(ProgressWindow))) then
         QDFlushPortBuffer(GetWindowPort(ProgressWindow), NIL);
      
      RGBForeColor(oldForeColor);
      RGBBackColor(oldBackColor);
      SetPort(oldport);
    end;
end;

procedure DrawEmptyProgressBar;
var oldport : grafPtr;
    oldForeColor,oldBackColor : RGBColor;
    toDoRect : rect;
begin
  if (ProgressWindow <> NIL) then
    begin
      todoRect := ProgressRect;
      InsetRect(todoRect,1,1);
      
      GetPort(oldport);
      SetPortByWindow(ProgressWindow);
      GetForeColor(oldForeColor);
      GetBackColor(oldBackColor);
      PenNormal;
      
      SetFrameColor;
      FrameRect(ProgressRect);
      
      if ProgressUsesColor 
        then
          begin
            SetToDoColor;
            PaintRect(toDoRect);
          end
        else
          begin
            SetToDoColor;
            FillRect(toDoRect,lightGrayPattern);
          end;
      
      if (QDIsPortBuffered(GetWindowPort(ProgressWindow))) then
         QDFlushPortBuffer(GetWindowPort(ProgressWindow), NIL);
      
      
      RGBForeColor(oldForeColor);
      RGBBackColor(oldBackColor);
      SetPort(oldport);
    end;
end;



end.