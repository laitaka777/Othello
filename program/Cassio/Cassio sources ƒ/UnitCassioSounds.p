UNIT UnitCassioSounds;



INTERFACE







USES UnitSound, UnitOth0;


procedure InitUnitCassioSounds; 
procedure LibereMemoireUnitCassioSounds;

procedure PlayZamfirSound(const fonctionAppelante : str255);
procedure PlayPosePionSound;
procedure PlayRetournementDePionSound;


IMPLEMENTATION







USES UnitRapport;

const        
  ZamfirID=1350;
  
  
  
var 
  SoundChannelPosePion : SndChannelPtr;
  SoundChannelRetournementPion : SndChannelPtr;
  PosePionSound:SndListHandle;
  RetournementPionSound:SndListHandle;



procedure InitUnitCassioSounds;
begin

  OpenChannel(SoundChannelPosePion);
  OpenChannel(SoundChannelRetournementPion);
  FlushChannel(SoundChannelPosePion);
  FlushChannel(SoundChannelRetournementPion);
  
  {on baisse le niveau sur les canaux de retournement de pion}
  SetSoundVolumeOfChannel(SoundChannelPosePion,80);
  SetSoundVolumeOfChannel(SoundChannelRetournementPion,80);
  
  PosePionSound := NIL;
  RetournementPionSound := NIL;
  PosePionSound := SndListHandle(GetResource('snd ', kSonTickID));
  RetournementPionSound := SndListHandle(GetResource('snd ', kSonTockID));
  HLockHi(Handle(PosePionSound));
  HLockHi(Handle(RetournementPionSound));

end;


procedure LibereMemoireUnitCassioSounds;
begin
end;



procedure PlayZamfirSound(const fonctionAppelante : str255);
var theChannel : SndChannelPtr;
    err: SInt16; 
	  sndInPlay: Handle;
	  sndInPlayState: SignedByte;
begin 
  {$unused fonctionAppelante}
  
  {on remplace PlaySoundSynchrone(ZamfirID) par le code suivant, qui a l'avantage
   de moduler le volume du son stocke en ressource, qui etait trop fort}
   
  if avecSon & not(gameOver) & not(analyseRetrograde.enCours) then
    begin
    
      OpenChannel(theChannel);
                
      sndInPlay := GetResource('snd ', ZamfirID);
      if sndInPlay <> NIL then
        begin
          HLockHi(sndInPlay);
          sndInPlayState := HGetState(sndInPlay);
					
          SetSoundVolumeOfChannel(theChannel,80);
          err := SndPlay(theChannel, SndListHandle(sndInPlay), false);
          SetSoundVolumeOfChannel(theChannel,80);
					
          HUnlock(sndInPlay);
          ReleaseResource(sndInPlay);
        end;
			
      CloseChannel(theChannel);
      
    end;
end;

procedure PlayPosePionSound;
var err: SInt16; 
begin
  if PosePionSound <> NIL then
    begin
      QuietChannel(SoundChannelPosePion);
      SetSoundVolumeOfChannel(SoundChannelPosePion,80);
      err := SndPlay(SoundChannelPosePion, PosePionSound, demo);
      SetSoundVolumeOfChannel(SoundChannelPosePion,80);
    end;
end;


procedure PlayRetournementDePionSound;
var err: SInt16; 
begin
  if RetournementPionSound <> NIL then
    begin
      QuietChannel(SoundChannelRetournementPion);
      SetSoundVolumeOfChannel(SoundChannelRetournementPion,80);
      err := SndPlay(SoundChannelRetournementPion, RetournementPionSound, false);
      SetSoundVolumeOfChannel(SoundChannelRetournementPion,80);
    end;
end;


END.