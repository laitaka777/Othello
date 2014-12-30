UNIT UnitSound;


INTERFACE







USES MacTypes, QuickDraw, Events, MacWindows, Dialogs, Fonts,  Files, 
     TextEdit,  Devices, UnitServicesMemoire,  Scrap, ToolUtils, OSUtils, Menus, Resources,
     Controls, Processes, AppleEvents, Sound;



   procedure OpenChannel(var theChannel : SndChannelPtr);
   procedure CloseChannel(var theChannel : SndChannelPtr);
   procedure FlushChannel(var theChannel : SndChannelPtr);
   procedure QuietChannel(var theChannel : SndChannelPtr);
   procedure HUnlockSoundRessource(SoundID : SInt16);

   procedure PlaySoundSynchrone(soundID: SInt16);
   procedure PlaySoundAsynchrone(soundID: SInt16; theChannel : SndChannelPtr);
   
   procedure SetSoundVolumeOfChannel(theChannel : SndChannelPtr;volume : SInt32);
   
{

  procedure SetSoundVol (level: SInt16);
  procedure GetSoundVol (var level: SInt16);
  procedure StartSound (synthRec: Ptr; numBytes: SInt32; completionRtn: ProcPtr);
  procedure StopSound;
  function SoundDone: BOOLEAN;
}


 


IMPLEMENTATION







 
 procedure OpenChannel(var theChannel : SndChannelPtr);
  begin
    theChannel := NIL;
    if SndNewChannel(theChannel,sampledSynth,initStereo,NIL)<>noErr then;
  end;

 procedure CloseChannel(var theChannel : SndChannelPtr);
   begin
     if SndDisposeChannel(theChannel,true)<>noErr then;
   end;
   
 procedure FlushChannel(var theChannel : SndChannelPtr);
 var sc:SndCommand;
  begin
    sc.cmd := flushCmd;
    if SndDoImmediate(theChannel,sc)=noErr then;
  end;
   
 procedure QuietChannel(var theChannel : SndChannelPtr);
 var sc:SndCommand;
  begin
    sc.cmd := flushCmd;
    if SndDoImmediate(theChannel,sc)=noErr then;
    sc.cmd := quietCmd;
    if SndDoImmediate(theChannel,sc)=noErr then;
  end;

 procedure HUnlockSoundRessource(SoundID : SInt16);
	var MySoundHandle : handle;
	begin
	  MySoundHandle := GetResource('snd ', SoundID);
	  if MySoundHandle <> NIL then
	     begin
	       HUnlock(MySoundHandle);
	       ReleaseResource(MySoundHandle);
	     end;
	end;
	
	
procedure PlaySoundSynchrone(soundID: SInt16);
var
  err: SInt16; 
  sndInPlay: Handle;
  sndInPlayState: SignedByte;
begin
  sndInPlay := GetResource('snd ', soundID);
  if sndInPlay <> NIL then
    begin
      HLockHi(sndInPlay);
      sndInPlayState := HGetState(sndInPlay);
      err := SndPlay(NIL, SndListHandle(sndInPlay), false);
      HUnlock(sndInPlay);
      ReleaseResource(sndInPlay);
    end;
end;


procedure PlaySoundAsynchrone(soundID: SInt16; theChannel : SndChannelPtr);
var
  err: SInt16; 
  sndInPlay: Handle;
  sndInPlayState: SignedByte;
begin
  sndInPlay := GetResource('snd ', soundID);
  if sndInPlay <> NIL then
    begin
      HLockHi(sndInPlay);
      sndInPlayState := HGetState(sndInPlay);
      err := SndPlay(theChannel, SndListHandle(sndInPlay), true);
    end;
end;


{ SetSoundVolumeOfChannel()
  Changement du volume, sur une echelle allant de 0 ˆ 512. (256 = volume normal) 
  }
procedure SetSoundVolumeOfChannel(theChannel : SndChannelPtr;volume : SInt32);
var theCmd:SndCommand;
begin

  theCmd.param1 := 0;
  theCmd.param2 := volume + volume*65536;  {droite et gauche}
  theCmd.cmd := volumeCmd;
  
  if SndDoImmediate(theChannel,theCmd) = noErr then; 
end;



end.

