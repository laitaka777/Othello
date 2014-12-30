UNIT UnitVieilOthelliste;

INTERFACE








type PagesAide = (kAideGenerale,kAideListe,kAideDiverse,kAideTranscripts);

var gAideCourante : PagesAide;
    gAideTranscriptsDejaPresentee : boolean;

 
procedure InitUnitVieilOthelliste;
procedure LibereMemoireVieilOthelliste;

procedure DerouleMaster;
procedure DisplayCassioAboutBox;
{ necessite une ressource de type STR$ à 6 items , d'ID 10014 :
     STR$ 1 = nom du programe
     STR$ 2 = auteur
     STR$ 3 = version
     STR$ 4 = copyright
     STR$ 5 = Adresse
     STR$ 6 = telephone
     STR$ 7 = copyright
     STR$ 8 = suite du précédent
  et une ressource de son d'ID 20000 (par exemple la valse hongroise)
}

procedure DessineAide(quellePage:PagesAide);
function NextPageDansAide(current:PagesAide):PagesAide;
function PreviousPageDansAide(current:PagesAide):PagesAide;


IMPLEMENTATION







USES UnitCarbonisation,UnitOth1,UnitListe,UnitSound,UnitDialog,SNStrings,UnitOth2,UnitFenetres;

const ValseHongroiseID  = 20000;
      HelpStringsID     = 1000;
      kNombreDeStringsDansRaccourcis = 171;
      
      
      
procedure InitUnitVieilOthelliste;
begin
  gAideCourante := kAideGenerale;
  gAideTranscriptsDejaPresentee := false;
end;


procedure LibereMemoireVieilOthelliste;
begin
end;


procedure AttendFrappeClavierEtJoueSonEnBoucle(SoundID : SInt16; theChannel  : SndChannelPtr);
var event : eventRecord;
begin
 if theChannel <> NIL then
   begin
     FlushChannel(theChannel);
     SetSoundVolumeOfChannel(theChannel,100);
     PlaySoundAsynchrone(SoundID,theChannel);
     SetSoundVolumeOfChannel(theChannel,100);
   end;
 FlushEvents(everyEvent,0);
  repeat
    MySystemTask;
    if ((TickCount() mod 60) = 0) then 
      if (theChannel <> NIL) then
        begin
          FlushChannel(theChannel);
          SetSoundVolumeOfChannel(theChannel,100);
          PlaySoundAsynchrone(SoundID,theChannel);
          SetSoundVolumeOfChannel(theChannel,100);
        end;
  until GetNextEvent(KeyDownMask+MDownMask,event);
end;



procedure DerouleMaster;
var unRect,windowRect,unrectBis,rect3,horlogerect : rect;
    Master:picHandle;
    uneRgn : RgnHandle;
    a,i,vitesse : SInt16; 
    tick : SInt32;
    masque : SInt32;
    newPort : CGrafPtr;
    uneFenetre : WindowPtr;
    PosRejoignez,posQuin,posPenloup,posFrancaise : SInt16; 
    posTelephoneFede,posEcritPar,posAdresseFede : SInt16; 
    compteurPixel : SInt32;
    Ecran512,clic : boolean;
    theChannel  : SndChannelPtr;
    EnvoyezLaMusique : boolean;
    ChaineNicolet,ChaineQuin,ChainePenloup : str255;
    ChaineRejoignez,ChaineFFO,ChaineTelephone,ChaineAdresse : str255;
    sortie : boolean;
    err : OSErr;
    
begin
  BeginDialog;
  {EnvoyezLaMusique := HumCtreHum | gameOver | (nbreCoup=0);}
  sortie := false;
  EnvoyezLaMusique := true;
  if EnvoyezLaMusique 
    then OpenChannel(theChannel)
    else theChannel := NIL;
  clic := false;
  Ecran512 := (GetScreenBounds().right-GetScreenBounds().left=512);
  if Ecran512
    then
      begin
        SetRect(unRect,-10,0,560,400);
        uneFenetre := NewCWindow(NIL,unRect,'',false,kWindowModalDialogProc,FenetreFictiveAvantPlan(),false,0);
        SetPortByWindow(uneFenetre);
        BackPat(blackPattern);
        FillRect(unRect,blackPattern);
        ShowWindow(uneFenetre);
        FillRect(unRect,blackPattern);
        newPort := CreateNewPort();
        SetPort(GrafPtr(newPort));
        masque := MDownMask+keyDownMask;
        SetRect(unRect,-10,0,500,300);
        Master := openPicture(unRect);
        ClosePicture;
        SetRect(unRect,-200,-200,750,600);
        uneRgn := NewRgn();
        OpenRgn;
        FrameRect(unRect);
        CloseRgn(uneRgn);
        ClipRect(unRect);
      end
    else
      begin
        a := (GetScreenBounds().right-512) div 2;
        i := (GetScreenBounds().bottom-342) div 2 + 14;
        SetRect(unRect,a,i,a+512,i+342);
        windowRect := unRect;
        PondreLaFenetreCommeUneGouttedEau(windowRect,true);
        uneFenetre := NewCWindow(NIL,windowRect,'',false,1,FenetreFictiveAvantPlan(),false,0);
        SetPortByWindow(uneFenetre);
        BackPat(blackPattern);
        SetRect(unRect,0,0,512,342);
        FillRect(unRect,blackPattern);
        ShowWindow(uneFenetre);
        FillRect(unRect,blackPattern);
        masque := MDownMask+keyDownMask;
        SetRect(unRect,-10,0,500,300);
        Master := openPicture(unRect);
        ClosePicture;
        SetRect(unRect,-200,-200,750,600);
        uneRgn := NewRgn();
        OpenRgn;
        FrameRect(unRect);
        CloseRgn(uneRgn);
        ClipRect(unRect);
      end;
  
  
  BackPat(blackPattern);
  master := GetPicture(137);  
  DrawPicture(master,master^^.picframe);
  unRect := master^^.picframe;
  unrectBis := unRect;
  OffsetRect(unrectBis,0,-(unRect.bottom-unRect.top));
  if Ecran512 then HideCursor;
  SetRect(rect3,0,-100,512,342);
  DrawPicture(master,unrectBis);
  
  GetIndString(ChaineRejoignez,TextesFederationID,1);
  GetIndString(ChaineFFO,TextesFederationID,2);
  GetIndString(ChaineTelephone,TextesFederationID,3);
  GetIndString(ChaineAdresse,TextesFederationID,4);
  GetIndString(ChaineNicolet,TextesFederationID,6);
  GetIndString(ChaineQuin,TextesFederationID,7);
  GetIndString(ChainePenloup,TextesFederationID,8);
  
  TextMode(3);
  TextFont(NewYorkID);
  TextSize(24);
  TextFace(underLine + bold);
  posRejoignez := (512-StringWidth(ChaineRejoignez)) div 2;
  
  TextSize(12);
  TextFace(bold);
  posQuin :=       (512-StringWidth(ChaineQuin)) div 2;
  posPenloup :=    (512-StringWidth(ChainePenloup)) div 2;
  posFrancaise :=  (512-StringWidth(ChaineFFO)) div 2;
  posAdresseFede := (512-StringWidth(ChaineAdresse)) div 2;
  posTelephoneFede := (512-StringWidth(ChaineTelephone)) div 2;
  
  TextFace( bold + underline );
  posEcritPar :=   (512-StringWidth(ChaineNicolet)) div 2;
  
  if EnvoyezLaMusique
    then AttendFrappeClavierEtJoueSonEnBoucle(ValseHongroiseID,theChannel)
    else AttendFrappeClavier;
  TextMode(3); 
  TextFont(NewYorkID);
  vitesse := 2;
  FlushEvents(everyEvent,0);
  SetRect(horlogerect,440,12,515,25);
  
  
  compteurPixel := 0;
  tick := TickCount();
  
REPEAT 
  if EnvoyezLaMusique then
    begin
      FlushChannel(theChannel);
      SetSoundVolumeOfChannel(theChannel,100);
      PlaySoundAsynchrone(ValseHongroiseID,theChannel);
      SetSoundVolumeOfChannel(theChannel,100);
    end;
  compteurPixel := compteurPixel+Abs(vitesse);
  
  OffsetRect(unrectbis,0,vitesse); 
  {DrawPicture(master,unrectbis);}
  
  repeat 
    if WaitNextEvent(masque,theEvent,0,NIL) then sortie := true;
  until sortie | (TickCount() > tick + 4);
  
  ScrollRect(rect3,0,vitesse,uneRgn);
  
  {
  if vitesse>0 then EraseRect(horlogerect);
  }
  
  err := SetAntiAliasedTextEnabled(false,9);
  
  if vitesse>0 then
    begin
      a := unrectbis.bottom-130;
      case a of 
        10..23:
         begin
           TextSize(12);
           TextFace( underLine + bold );
           Moveto(posEcritpar,a-10);
           DrawString(ChaineNicolet);
         end;
        -7..6:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posQuin,a+7);
           DrawString(ChaineQuin);
         end;
         -22..-9:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posPenloup,a+22);
           DrawString(ChainePenloup);
         end;
        150..170:
         begin
           TextSize(24);
           TextFace( underLine + bold );
           Moveto(posRejoignez,a-150);
           DrawString(ChaineRejoignez);
         end;
         124..136:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posFrancaise,a-124);
           DrawString(ChaineFFO);
         end;
         112..123:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posTelephoneFede,a-112);
           DrawString(ChaineTelephone);
         end;
         100..111:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posAdresseFede,a-100);
           DrawString(ChaineAdresse);
         end;
      end;
    end
  else
    begin
      a := unrectbis.bottom+342+130;
      case a of 
        10..23:
         begin
           TextSize(12);
           TextFace( underLine + bold );
           Moveto(posEcritPar,a-10);
           DrawString(ChaineNicolet);
         end;
        150..170:
         begin
           TextSize(24);
           TextFace( underLine + bold );
           Moveto(posRejoignez,a-150);
           DrawString(ChaineRejoignez);
         end;
         124..136:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posFrancaise,a-124);
           DrawString(ChaineFFO);
         end;
         112..123:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posTelephoneFede,a-112);
           DrawString(ChaineTelephone);
         end;
         100..111:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posAdresseFede,a-100);
           DrawString(ChaineAdresse);
         end;
      end;
    end;
  tick := TickCount();
  
  if compteurPixel>=(master^^.picframe.bottom-master^^.picframe.top) then 
  begin
    
    
    TextFont(gCassioApplicationFont);
    TextSize(gCassioSmallFontSize);
    TextFace(normal);
    CenterString(0,325,512,'Othello® est une marque déposée en France par Mattel™');
    
    if EnvoyezLaMusique then
      begin
        FlushChannel(theChannel);
        SetSoundVolumeOfChannel(theChannel,100);
        PlaySoundAsynchrone(ValseHongroiseID,theChannel);
        SetSoundVolumeOfChannel(theChannel,100);
      end;
    tick := TickCount();
    repeat 
      clic := clic or WaitNextEvent(masque,theEvent,0,NIL);
    until (TickCount()-tick > 460) or clic;
    
    SetRect(unrectBis,0,0,unRect.left,unRect.right);
    DrawPicture(master,master^^.picframe);
    unRect := master^^.picframe;
    unrectBis := unRect;
    OffsetRect(unrectBis,0,-(unRect.bottom-unRect.top));
    
    if EnvoyezLaMusique then
      begin
        FlushChannel(theChannel);
        SetSoundVolumeOfChannel(theChannel,100);
        PlaySoundAsynchrone(ValseHongroiseID,theChannel);
        SetSoundVolumeOfChannel(theChannel,100);
      end;
    tick := TickCount();
    repeat 
      clic := clic or WaitNextEvent(masque,theEvent,0,NIL);
    until (TickCount()-tick>250) or clic;
    
    TextFont(NewYorkID);
    compteurPixel := 0;
  end;
UNTIL WaitNextEvent(masque,theEvent,0,NIL) or clic or sortie;
  
 if EnvoyezLaMusique
    then AttendFrappeClavierEtJoueSonEnBoucle(ValseHongroiseID,theChannel)
    else AttendFrappeClavier;
 if EnvoyezLaMusique then 
   begin
     QuietChannel(theChannel);
     CloseChannel(theChannel);
     HUnlockSoundRessource(ValseHongroiseID);
   end;
 ReleaseResource(Handle(master));
 if ecran512 then DisposePort(newPort);
 ShowCursor;
 DrawMenuBar;
 DisposeWindow(unefenetre);
 EndDialog;
 if not(ecran512) then PondreLaFenetreCommeUneGouttedEau(windowRect,false);
 
 if gCassioUseQuartzAntialiasing then 
   err := SetAntiAliasedTextEnabled(true,9);
 
end;

procedure DisplayCassioAboutBox;
{ necessite une ressource de type STR$ à 6 items , d'ID 10014 :
     STR$ 1 = nom du programe
     STR$ 2 = auteur
     STR$ 3 = version
     STR$ 4 = copyright
     STR$ 5 = Adresse
     STR$ 6 = telephone
     STR$ 7 = copyright
     STR$ 8 = suite du précédent
}
const strlistID=10014;
var   oldport : grafPtr;
      wp : WindowPtr;
      windowRect : rect;
      i : SInt16; 
      messages : array[1..6] of str255;
      theChannel  : SndChannelPtr;
      EnvoyezLaMusique : boolean;
begin
  BeginDialog;
  {EnvoyezLaMusique := HumCtreHum or gameOver or (nbreCoup=0);}
  EnvoyezLaMusique := true;
  if EnvoyezLaMusique 
    then OpenChannel(theChannel)
    else theChannel := NIL;
    
    
  for i := 1 to 6 do
    GetIndString(messages[i],strlistID,i);
    
  { Cas particulier de la chaine de version : on remplace eventuellment ^0 par 
    le numero de version courant }
  if (Pos('^0',messages[3]) > 0) 
    then messages[3] := ParamStr(messages[3],VersionDeCassioEnString(),"","","");
    
  windowRect := GetScreenBounds();
  InsetRect(windowRect,(windowRect.right-windowRect.left-300) div 2,(windowRect.bottom-windowRect.top-180) div 2);
  PondreLaFenetreCommeUneGouttedEau(windowRect,true);
  wp := NewCWindow(NIL,windowRect,'',true,kWindowModalDialogProc{altdboxproc},FenetreFictiveAvantPlan(),false,0);
  
  if wp <> NIL then 
  with GetWindowPortRect(wp) do
  begin
    GetPort(oldport);
    SetPortByWindow(wp);
    
    TextFont(systemFont);
    TextSize(0);
    TextFace(bold);
    CenterString(0,30,right,messages[1]);
    
    
    TextFont(GenevaID);
    TextSize(9);
    TextFace(normal);
    CenterString(0,60,right,messages[2]);
    CenterString(0,90,right,messages[3]);
    CenterString(0,bottom-50,right,messages[4]);
    CenterString(0,bottom-35,right,messages[5]);
    CenterString(0,bottom-20,right,messages[6]);
    
    while Button() do 
      begin
        ShareTimeWithOtherProcesses(2);
        MySystemTask;
        if EnvoyezLaMusique then
          begin
            FlushChannel(theChannel);
            SetSoundVolumeOfChannel(theChannel,100);
            PlaySoundAsynchrone(ValseHongroiseID,theChannel);
            SetSoundVolumeOfChannel(theChannel,100);
          end;
      end;
    while not(Button()) do 
      begin
        ShareTimeWithOtherProcesses(2);
        MySystemTask;
        if EnvoyezLaMusique then
          begin
            FlushChannel(theChannel);
            SetSoundVolumeOfChannel(theChannel,100);
            PlaySoundAsynchrone(ValseHongroiseID,theChannel);
            SetSoundVolumeOfChannel(theChannel,100);
          end;
      end; 
    FlushEvents(MDownmask+MupMask,0);
    if EnvoyezLaMusique then 
      begin
        QuietChannel(theChannel);
        CloseChannel(theChannel);
        HUnlockSoundRessource(ValseHongroiseID);
      end;
      
    DisposeWindow(wp);
    SetPort(oldport);
    EndDialog;
    PondreLaFenetreCommeUneGouttedEau(windowRect,false);
  end;
end;




procedure DessineHelpDialogue;
var windowRect : rect;
    a,i,b : SInt16; 
    newPort : CGrafPtr;
    uneFenetre : WindowPtr;
    Ecran512 : boolean;
    invite,s1,s2 : str255;
    theChannel : SndChannelPtr;
    EnvoyezLaMusique : boolean;
    err : OSErr;
      
 procedure EcritInviteRaccourcis;
 begin
   TextSize(gCassioSmallFontSize);
   TextFont(gCassioApplicationFont);
   TextFace(bold);
   b := 16;
   CenterString(0,b,512,invite);
   b := 40;
   ShareTimeWithOtherProcesses(2);
 end;
 
 
begin
  err := SetAntiAliasedTextEnabled(false,9);
  
  BeginDialog;
  {EnvoyezLaMusique := HumCtreHum or gameOver or (nbreCoup=0);}
  EnvoyezLaMusique := true;
  if EnvoyezLaMusique 
    then OpenChannel(theChannel)
    else theChannel := NIL;
  Ecran512 := (GetScreenBounds().right-GetScreenBounds().left=512);
  if Ecran512
    then
      begin
        SetRect(windowRect,-10,0,560,400);
        uneFenetre := NewCWindow(NIL,windowRect,'',false,0,FenetreFictiveAvantPlan(),false,0);
        SetPortByWindow(uneFenetre);
        ShowWindow(uneFenetre);
        newPort := CreateNewPort();
        SetPort(GrafPtr(newPort))
      end
    else
      begin
        a := (GetScreenBounds().right-512) div 2;
        i := (GetScreenBounds().bottom-342) div 2 + 14;
        SetRect(windowRect,a,i,a+512,i+342);
        PondreLaFenetreCommeUneGouttedEau(windowRect,true);
        uneFenetre := NewCWindow(NIL,windowRect,'',false,1,FenetreFictiveAvantPlan(),false,0);
        SetPortByWindow(uneFenetre);
        ShowWindow(uneFenetre);
      end;
  
  
  GetIndString(invite,HelpStringsID,1);
  EcritInviteRaccourcis;
  
  i := 1;
  repeat
    GetIndString(s1,HelpStringsID,i*2);
    GetIndString(s2,HelpStringsID,i*2+1);
    
    if (s1<>'\newpage') and (s2<>'\newpage') then
      if (s1<>'') or (s2<>'') then
        begin
          if s2=''
            then
              begin
                TextFace(bold);
                WriteStringAt(s1,10,b);
              end
            else
              begin
                TextFace(bold);
                WriteStringAt(s1,38,b);
                TextFace(normal);
                WriteStringAt(s2,194,b);
              end;
        end;
    
    b := b+12;
    i := i+1;
    
    if (s1='\newpage') or (s2='\newpage') or
       ((b>355) and (i<=(kNombreDeStringsDansRaccourcis div 2))) then
      begin
        ShareTimeWithOtherProcesses(2);
        if EnvoyezLaMusique
			    then AttendFrappeClavierEtJoueSonEnBoucle(ValseHongroiseID,theChannel)
			    else AttendFrappeClavier;
        SetPortByWindow(uneFenetre);
        EraseRect(QDGetPortBound());
        EcritInviteRaccourcis;
        ShareTimeWithOtherProcesses(2);
      end;
      
  until (i>(kNombreDeStringsDansRaccourcis div 2));
  
  if EnvoyezLaMusique
    then AttendFrappeClavierEtJoueSonEnBoucle(ValseHongroiseID,theChannel)
    else AttendFrappeClavier;
  
  if EnvoyezLaMusique then 
   begin
     QuietChannel(theChannel);
     CloseChannel(theChannel);
     HUnlockSoundRessource(ValseHongroiseID);
   end;
   
  if ecran512 then DisposePort(newPort);
  ShowCursor;
  DrawMenuBar;
  DisposeWindow(unefenetre);
  EndDialog;
  if not(ecran512) then PondreLaFenetreCommeUneGouttedEau(windowRect,false);
  
  if gCassioUseQuartzAntialiasing then 
    err := SetAntiAliasedTextEnabled(true,9);
end;



procedure DessineAide(quellePage:PagesAide);
var i,b : SInt32;
    invite,s1,s2 : str255;
    oldPort : grafPtr;
    err : OSErr;
    compteurDePage:PagesAide;
      
 procedure EcritInviteAide;
 var theRect : rect;
 begin
   theRect := QDGetPortBound();
   InSetRect(theRect,-10,-10);
   if DrawThemeWindowListViewHeader(theRect,kThemeStateActive) = NoErr then;
   TextSize(gCassioSmallFontSize);
   TextFont(gCassioApplicationFont);
   TextFace(bold);
   TextMode(1);
   b := 16;
   GetIndString(invite,HelpStringsID,1);
   invite := invite + ' ('+NumEnString(1+ord(compteurDePage))+'/'+NumEnString(1+ord(kAideTranscripts))+')';
   err := SetAntiAliasedTextEnabled(false,9);
   CenterString(0,b,512,invite);
   b := 40;
 end;
 
 
begin

  if windowAideOpen & (wAidePtr <> NIL) then
    begin
      
      GetPort(oldPort);   
      SetPortByWindow(wAidePtr);
      
      err := SetAntiAliasedTextEnabled(false,9);
      
      compteurDePage := kAideGenerale;
      EcritInviteAide;
      
      i := 1;
      repeat
        GetIndString(s1,HelpStringsID,i*2);
        GetIndString(s2,HelpStringsID,i*2+1);
        
        if (compteurDePage = quellePage) then
          begin
            if (s1 <> '\newpage') and (s2 <> '\newpage') then
              if (s1 <> '') or (s2 <> '') then
                begin
                  if s2=''
                    then
                      begin
                        TextFace(bold);
                        WriteStringAtWithoutErase(s1,10,b);
                      end
                    else
                      begin
                        TextFace(bold);
                        WriteStringAtWithoutErase(s1,38,b);
                        TextFace(normal);
                        WriteStringAtWithoutErase(s2,194,b);
                      end;
                end;
          end;
        
        b := b+12;
        i := i+1;
        
        if (s1 = '\newpage') or (s2 = '\newpage') or
           ((b > 565) and (i <= (kNombreDeStringsDansRaccourcis div 2))) then
          begin
            inc(compteurDePage);
            if (compteurDePage <= quellePage) then
              begin
    			      SetPortByWindow(wAidePtr);
                EcritInviteAide;
              end;
            
          end;
          
      until (i>(kNombreDeStringsDansRaccourcis div 2));
      
      ShowCursor;
      DrawMenuBar;
      
      if gCassioUseQuartzAntialiasing then 
        err := SetAntiAliasedTextEnabled(true,9);
      
      SetPort(oldPort);
  
    end;
end;


function NextPageDansAide(current:PagesAide):PagesAide;
begin
  if current = kAideTranscripts
    then NextPageDansAide := kAideGenerale
    else NextPageDansAide := succ(current);
end;


function PreviousPageDansAide(current:PagesAide):PagesAide;
begin
  if current = kAideGenerale
    then PreviousPageDansAide := kAideTranscripts
    else PreviousPageDansAide := pred(current);
end;




end.






