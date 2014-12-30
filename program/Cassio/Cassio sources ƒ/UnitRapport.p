UNIT UnitRapport;


INTERFACE







USES UnitServicesRapport,UnitOth0,UnitOthelloGeneralise;

 
{insertion de texte dans le rapport}
{procedure InsereTexteDansRapportSync(text : Ptr;length : SInt32;scrollerSynchronisation : boolean);}
procedure InsereStringDansRapportSync(s : str255;scrollerSynchronisation : boolean);
procedure InsereStringlnDansRapportSync(s : str255;scrollerSynchronisation : boolean);
procedure WriteDansRapportSync(s : str255;scrollerSynchronisation : boolean);
procedure WritelnDansRapportSync(s : str255;scrollerSynchronisation : boolean);
procedure InsereTexteDansRapport(text : Ptr;length : SInt32);
procedure InsereStringDansRapport(s : str255);
procedure InsereStringlnDansRapport(s : str255);
procedure WriteDansRapport(s : str255);  
procedure WritelnDansRapport(s : str255); 
procedure WritelnDansRapportEtAttendFrappeClavier(s : str255;bip : boolean);

{des synonymes de fonctions declarees plus haut…}
procedure WriteStringDansRapport(s : string);
procedure WritelnStringDansRapport(s : string);
procedure WritelnInterruptionDansRapport(uneInterruption : SInt16);
procedure EcritTypeInterruptionDansRapport(uneinterruption : SInt16);

{ecriture des numeriques dans le rapport}
procedure WriteNumDansRapport(num : SInt32);
procedure WritelnNumDansRapport(num : SInt32);
procedure WriteStringAndNumDansRapport(s : string;num : SInt32);
procedure WritelnStringAndNumDansRapport(s : string;num : SInt32); 

{ecriture des numeriques dans le rapport, en separant les chiffres par groupe de trois}
procedure WriteNumEnSeparantLesMilliersDansRapport(num : SInt32);
procedure WritelnNumEnSeparantLesMilliersDansRapport(num : SInt32);
procedure WriteStringAndNumEnSeparantLesMilliersDansRapport(s : string;num : SInt32);
procedure WritelnStringAndNumEnSeparantLesMilliersDansRapport(s : string;num : SInt32);

{ecriture des reels dans le rapport}
procedure WriteReelDansRapport(x : extended;nbDecimales : SInt16);
procedure WritelnReelDansRapport(x : extended;nbDecimales : SInt16);
procedure WriteStringAndReelDansRapport(s : string;x : extended;nbDecimales : SInt16);
procedure WritelnStringAndReelDansRapport(s : string;x : extended;nbDecimales : SInt16);

{ecriture des positions dans le rapport}
procedure WritelnPositionDansRapport(var position : plateauOthello);
procedure WritelnPositionEtTraitDansRapport(var position : plateauOthello;trait : SInt32);
procedure WritelnPlatValeurDansRapport(var plateau : platValeur);
procedure WritelnBigOthelloDansRapport(var position : BigOthelloRec);

{ecriture des coups dans le rapport}
procedure WriteCoupDansRapport(square : SInt16);
procedure WritelnCoupDansRapport(square : SInt16);
procedure WriteStringAndCoupDansRapport(s : string;square : SInt16);
procedure WritelnStringAndCoupDansRapport(s : string;square : SInt16); 

{ecriture des booleens dans le rapport}
procedure WriteBooleenDansRapport(b : boolean);
procedure WritelnBooleenDansRapport(b : boolean);
procedure WriteStringAndBooleenDansRapport(s : string;b : boolean);
procedure WritelnStringAndBooleenDansRapport(s : string;b : boolean);
{des synonymes…}
procedure WriteBooleanDansRapport(b : boolean);
procedure WritelnBooleanDansRapport(b : boolean);
procedure WriteStringAndBooleanDansRapport(s : string;b : boolean);
procedure WritelnStringAndBooleanDansRapport(s : string;b : boolean);
procedure WriteBoolDansRapport(b : boolean);
procedure WritelnBoolDansRapport(b : boolean);
procedure WriteStringAndBoolDansRapport(s : string;b : boolean);  
procedure WritelnStringAndBoolDansRapport(s : string;b : boolean); 

{ecriture dans le rapport, mais seulement s'il est ouvert}
procedure WritelnDansRapportOuvert(s : string);
procedure WritelnStringAndNumDansRapportOuvert(s : string;num : SInt32);




IMPLEMENTATION







USES UnitMacExtras,UnitRapportImplementation,UnitScannerOthellistique,SNStrings;


procedure InsereStringDansRapportSync(s : str255;scrollerSynchronisation : boolean);
var longueur : SInt32;
begin
  longueur := Length(s);
  InsereTexteDansRapportSync(@s[1],longueur,scrollerSynchronisation);
end;

procedure InsereStringlnDansRapportSync(s : str255;scrollerSynchronisation : boolean);
var longueur : SInt32;
begin
  s := s+chr(13);
  longueur := Length(s);
  InsereTexteDansRapportSync(@s[1],longueur,scrollerSynchronisation);
end;

procedure WriteDansRapportSync(s : str255;scrollerSynchronisation : boolean);
var longueur : SInt32;
    longueurRapport,selectionDebut,selectionFin : SInt32;
begin
  if GetRapportTextHandle() <> NIL then
    begin
	    longueurRapport := GetTailleRapport();
	    selectionDebut := GetDebutSelectionRapport();
	    selectionFin := GetFinSelectionRapport();
	    if (selectionDebut <> selectionFin) | (selectionDebut <> longueurRapport)
	      then SelectionnerTexteDansRapport(longueurRapport,longueurRapport);
	    longueur := Length(s);
	    InsereTexteDansRapportSync(@s[1],longueur,scrollerSynchronisation);
	  end;
end;

procedure WritelnDansRapportSync(s : str255;scrollerSynchronisation : boolean);
begin
  s := s+chr(13);
  WriteDansRapportSync(s,scrollerSynchronisation);
end;

procedure InsereTexteDansRapport(text : Ptr;length : SInt32);
begin
  InsereTexteDansRapportSync(text,length,true);
end;

procedure InsereStringDansRapport(s : str255);
begin
  InsereStringDansRapportSync(s,true);
end;

procedure InsereStringlnDansRapport(s : str255);
begin
  InsereStringlnDansRapportSync(s,true);
end;


procedure WriteDansRapport(s : str255);
begin
  WriteDansRapportSync(s,true);
end;

procedure WritelnDansRapport(s : str255);
begin
  WritelnDansRapportSync(s,true);
end;

procedure WritelnDansRapportEtAttendFrappeClavier(s : str255;bip : boolean);
begin
  WritelnDansRapport(s);
  if bip then SysBeep(0);
  AttendFrappeClavier;
end;

procedure WriteStringDansRapport(s : string);
begin
  WriteDansRapport(s);
end;

procedure WriteBooleenDansRapport(b : boolean);
begin
  if b
    then WriteDansRapport('true')
    else WriteDansRapport('false');
end;


procedure WritelnBooleenDansRapport(b : boolean);
begin
  if b
    then WritelnDansRapport('true')
    else WritelnDansRapport('false');
end;

procedure WriteStringAndBooleenDansRapport(s : string;b : boolean);
begin
   if b
    then WriteDansRapport(s+'true')
    else WriteDansRapport(s+'false');
end;

procedure WritelnStringAndBooleenDansRapport(s : string;b : boolean);
begin
   if b
    then WritelnDansRapport(s+'true')
    else WritelnDansRapport(s+'false');
end;

procedure WriteBooleanDansRapport(b : boolean);
begin
  WriteBooleenDansRapport(b);
end;

procedure WritelnBooleanDansRapport(b : boolean);
begin
  WritelnBooleenDansRapport(b);
end;

procedure WriteStringAndBooleanDansRapport(s : string;b : boolean);
begin
  WriteStringAndBooleenDansRapport(s,b);
end;

procedure WritelnStringAndBooleanDansRapport(s : string;b : boolean);
begin
  WritelnStringAndBooleenDansRapport(s,b);
end;


procedure WriteBoolDansRapport(b : boolean);
begin
  WriteBooleenDansRapport(b);
end;

procedure WritelnBoolDansRapport(b : boolean);
begin
  WritelnBooleenDansRapport(b);
end;

procedure WriteStringAndBoolDansRapport(s : string;b : boolean);
begin
  WriteStringAndBooleenDansRapport(s,b);
end;

procedure WritelnStringAndBoolDansRapport(s : string;b : boolean);
begin
  WritelnStringAndBooleenDansRapport(s,b);
end;

procedure EcritTypeInterruptionDansRapport(uneinterruption : SInt16);
begin
  case uneInterruption of
     pasdinterruption                   : WritelnDansRapport('pas d''interruption');
     interruptionSimple                 : WritelnDansRapport('interruption = interruption simple');
     kHumainVeutChangerCouleur          : WritelnDansRapport('interruption = kHumainVeutChangerCouleur');
     kHumainVeutChargerBase             : WritelnDansRapport('interruption = kHumainVeutChargerBase');
     kHumainVeutAnalyserFinale          : WritelnDansRapport('interruption = kHumainVeutAnalyserFinale');
     kHumainVeutJouerSolitaires         : WritelnDansRapport('interruption = kHumainVeutJouerSolitaires');
     kHumainVeutChangerHumCtreHum       : WritelnDansRapport('interruption = kHumainVeutChangerHumCtreHum');
     kHumainVeutChangerCoulEtHumCtreHum : WritelnDansRapport('interruption = kHumainVeutChangerCoulEtHumCtreHum');
     interruptionDepassementTemps       : WritelnDansRapport('interruption = interruptionDepassementTemps');
     otherwise                            WritelnStringAndNumDansRapport('interruption inconnue !!!!!!!!!!!!!! ',uneInterruption);
  end;
end;

procedure WritelnInterruptionDansRapport(uneInterruption : SInt16);
begin
  EcritTypeInterruptionDansRapport(uneInterruption);
end;


procedure WriteNumDansRapport(num : SInt32);
var s1 : str255;
begin
  NumToString(num,s1);
  WriteDansRapport(s1);
end;


procedure WriteStringAndNumDansRapport(s : string;num : SInt32);
var s1 : str255;
begin
  NumToString(num,s1);
  WriteDansRapport(s+s1);
end;

procedure WritelnStringDansRapport(s : string);
begin
  WritelnDansRapport(s);
end;

procedure WritelnNumDansRapport(num : SInt32);
var s1 : str255;
begin
  NumToString(num,s1);
  WritelnDansRapport(s1);
end;


procedure WritelnStringAndNumDansRapport(s : string;num : SInt32);
var s1 : str255;
begin
  NumToString(num,s1);
  WritelnDansRapport(s+s1);
end;

procedure WriteNumEnSeparantLesMilliersDansRapport(num : SInt32);
var s1 : str255;
begin
  NumToString(num,s1);
  WriteDansRapport(SeparerLesChiffresParTrois(s1));
end;

procedure WritelnNumEnSeparantLesMilliersDansRapport(num : SInt32);
var s1 : str255;
begin
  NumToString(num,s1);
  WritelnDansRapport(SeparerLesChiffresParTrois(s1));
end;

procedure WriteStringAndNumEnSeparantLesMilliersDansRapport(s : string;num : SInt32);
var s1 : str255;
begin
  NumToString(num,s1);
  WriteDansRapport(s+SeparerLesChiffresParTrois(s1));
end;

procedure WritelnStringAndNumEnSeparantLesMilliersDansRapport(s : string;num : SInt32);
var s1 : str255;
begin
  NumToString(num,s1);
  WritelnDansRapport(s+SeparerLesChiffresParTrois(s1));
end;

procedure WriteReelDansRapport(x : extended;nbDecimales : SInt16);
var s1 : str255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  WriteDansRapport(s1);
end;

procedure WritelnReelDansRapport(x : extended;nbDecimales : SInt16);
var s1 : str255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  WritelnDansRapport(s1);
end;

procedure WriteStringAndReelDansRapport(s : string;x : extended;nbDecimales : SInt16);
var s1 : str255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  WriteDansRapport(s+s1);
end;

procedure WritelnStringAndReelDansRapport(s : string;x : extended;nbDecimales : SInt16);
var s1 : str255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  WritelnDansRapport(s+s1);
end;


procedure WritelnPositionDansRapport(var position : plateauOthello);
var i,j,x : SInt16; 
    s : str255;
begin
  ChangeFontDansRapport(MonacoID);
  for j := 1 to 8 do
    begin
      s := '';
      for i := 1 to 8 do
        begin
          x := position[10*j+i];
          if x = pionNoir then s := s+'X ' else
	      if x = pionBlanc then s := s+'O ' else
	      if x = pionVide then s := s+'. ';
        end;
      WritelnDansRapport(s);
    end;
end;

procedure WritelnPositionEtTraitDansRapport(var position : plateauOthello;trait : SInt32);
var i,j,x : SInt16; 
    s : str255;
begin
  ChangeFontDansRapport(MonacoID);
  for j := 1 to 8 do
    begin
      s := '';
      for i := 1 to 8 do
        begin
          x := position[10*j+i];
          if x = pionNoir then s := s+'X ' else
	      if x = pionBlanc then s := s+'O ' else
	      if x = pionVide then s := s+'. ';
        end;
      if j=8 then
        case trait of 
          pionNoir : s := s+'     trait à X';
          pionBlanc: s := s+'     trait à O';
          otherwise  s := s+'     trait = ??'+'('+NumEnString(trait)+')';
        end; {case}
      WritelnDansRapport(s);
    end;
end;

procedure WritelnBigOthelloDansRapport(var position : BigOthelloRec);
var i,j,x : SInt16; 
    s : str255;
begin
  ChangeFontDansRapport(MonacoID);
  for j := 1 to position.size.v do
    begin
      s := '';
      for i := 1 to position.size.h do
        begin
          s := '';
          x := position.plateau[i,j];
          if x = pionNoir then s := s+'X ' else
	      if x = pionBlanc then s := s+'O ' else
	      if x = pionVide then s := s+'. ';
	      WriteDansRapport(s);
        end;
      if (j < position.size.v)
        then WritelnDansRapport('')
        else
          case position.trait of 
            pionNoir : WritelnDansRapport('     trait à X');
            pionBlanc: WritelnDansRapport('     trait à O');
            otherwise  WritelnDansRapport('     trait = ??');
          end;
    end;
end;


procedure WritelnPlatValeurDansRapport(var plateau : platValeur);
var i,j,x : SInt16; 
    s : str255;
begin
  for j := 1 to 8 do
    begin
      s := '';
      for i := 1 to 8 do
        begin
          x := plateau[10*j+i];
          s := Concat(s,NumEnString(x),' ');
        end;
      WritelnDansRapport(s);
    end;
end;

procedure WriteCoupDansRapport(square : SInt16);
begin
  WriteDansRapport(CoupEnString(square,true));
end;

procedure WritelnCoupDansRapport(square : SInt16);
begin
  WritelnDansRapport(CoupEnString(square,true));
end;

procedure WriteStringAndCoupDansRapport(s : string;square : SInt16);
begin
  if (square >= 11) & (square <= 88)
    then WriteDansRapport(s+CoupEnString(square,true))
    else WriteDansRapport(s+CoupEnString(square,true)+'(='+NumEnString(square)+')');
end;

procedure WritelnStringAndCoupDansRapport(s : string;square : SInt16);
begin
  if (square >= 11) & (square <= 88)
    then WritelnDansRapport(s+CoupEnString(square,true))
    else WritelnDansRapport(s+CoupEnString(square,true)+'(='+NumEnString(square)+')');
end;


procedure WritelnDansRapportOuvert(s : string);
begin
  if FenetreRapportEstOuverte() then
      WritelnDansRapport(s);
end;

procedure WritelnStringAndNumDansRapportOuvert(s : string;num : SInt32);
begin
  if FenetreRapportEstOuverte() then
      WritelnStringAndNumDansRapport(s,num);
end;



end.

















































