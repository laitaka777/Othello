UNIT UnitTestZoneMemoire;



INTERFACE







USES UnitZoneMemoire;


procedure WritelnZoneMemoireDansRapport(theZone : ZoneMemoire);
procedure WritelnStringAndZoneMemoireDansRapport(s : str255;theZone : ZoneMemoire);

procedure TesteZoneMemoire;

IMPLEMENTATION







USES UnitOth1,UnitRapport,SNStrings;

procedure WritelnZoneMemoireDansRapport(theZone : ZoneMemoire);
begin
  with TheZone do
    begin
      WritelnDansRapport('theZone.infos = '+NumEnString(SInt32(infos)));
      WritelnDansRapport('theZone.tailleMaximalePossible = '+NumEnString(tailleMaximalePossible));
      WritelnDansRapport('theZone.nbOctetsOccupes = '+NumEnString(nbOctetsOccupes));
      WritelnDansRapport('theZone.position = '+NumEnString(position));
      WritelnDansRapport('theZone.tailleMaximalePossible = '+NumEnString(tailleMaximalePossible));
      WritelnDansRapport('theZone.genre = '+NumEnString(SInt32(genre)));
      WritelnDansRapport('');
    end;
end;



procedure WritelnStringAndZoneMemoireDansRapport(s : str255;theZone : ZoneMemoire);
begin
  WritelnDansRapport(s);
  WritelnZoneMemoireDansRapport(theZone);
end;



procedure TesteZoneMemoire;
var Z1,Z2,Z3,Z4,Z5 : ZoneMemoire;
    s : str255;
    err : OSErr;
    borne,i,tick : SInt32;
    c : char;
begin

  SetDebuggageUnitFichiersTexte(false);
  
  Z1 := NewEmptyZoneMemoire;
  Z2 := NewEmptyZoneMemoire;
  Z3 := NewEmptyZoneMemoire;
  Z4 := NewEmptyZoneMemoire;
  Z5 := NewEmptyZoneMemoire;

  
  
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  {WritelnStringAndZoneMemoireDansRapport('Z2=',Z2);
  WritelnStringAndZoneMemoireDansRapport('Z3=',Z3);
  WritelnStringAndZoneMemoireDansRapport('Z4=',Z4);
  WritelnStringAndZoneMemoireDansRapport('Z5=',Z5);}
  
  
  Z1 := MakeZoneMemoireFichier('toto est grand',0);
  
  {
  name := 'Bonifacio:CW9 Gold:Cassio 3.5.68k.CW9 Ä:sans titre';
  Z2 := MakeZoneMemoireFichier(name,0);
  
  }
  
  Z3 := MakeZoneMemoireEnMemoire(-1);
  Z4 := MakeZoneMemoireEnMemoire(1000);
  
  
  {name := 'PrŽfŽrences Cassio 3.5 (68k)';
  Z5 := MakeZoneMemoireFichier(name,volumeRefCassio);}
  
  
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
 { WritelnStringAndZoneMemoireDansRapport('Z2=',Z2);
 }
  WritelnStringAndZoneMemoireDansRapport('Z3=',Z3);
  WritelnStringAndZoneMemoireDansRapport('Z4=',Z4);
  {
  WritelnStringAndZoneMemoireDansRapport('Z5=',Z5);}
  
  
  err := ViderZoneMemoire(Z1);
  {
  err := ViderZoneMemoire(Z2);
  }
  err := ViderZoneMemoire(Z3);
  err := ViderZoneMemoire(Z4);
  {
  err := ViderZoneMemoire(Z5);
  }
  
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := WritelnDansZoneMemoire(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  
  err := SetPositionMarqueurZoneMemoire(Z1,0);
  
  tick := TickCount();
  
  borne := Z1.nbOctetsOccupes;
  for i := 1 to borne+10 do
    begin
      err := GetNextCharOfZoneMemoire(Z1,c);
      {
      WritelnDansRapport('err['+NumEnString(i)+']='+NumEnString(Err));
      WritelnDansRapport('ord(c)='+NumEnString(ord(c))+' et c ='+c);
      }
    end;
  
  WritelnStringAndNumDansRapport('temps pour lire '+NumEnString(borne+10)+' octets = ',TickCount()-tick);
  
  err := ReadlnDansZoneMemoire(Z1,s);
  WritelnDansRapport('');
  WritelnStringAndNumDansRapport('err = ',err);
  WritelnDansRapport('ligne lue = '+s);
  
  err := ReadlnDansZoneMemoire(Z1,s);
  WritelnDansRapport('');
  WritelnStringAndNumDansRapport('err = ',err);
  WritelnDansRapport('ligne lue = '+s);
  
  err := ReadlnDansZoneMemoire(Z1,s);
  WritelnDansRapport('');
  WritelnStringAndNumDansRapport('err = ',err);
  WritelnDansRapport('ligne lue = '+s);
  
  
  
  DisposeZoneMemoire(Z1);
  DisposeZoneMemoire(Z2);
  
  DisposeZoneMemoire(Z3);
  DisposeZoneMemoire(Z4);
  
  DisposeZoneMemoire(Z5);
  
  {WritelnStringAndZoneMemoireDansRapport('Z1=',Z1);
  WritelnStringAndZoneMemoireDansRapport('Z2=',Z2);
  WritelnStringAndZoneMemoireDansRapport('Z3=',Z3);
  WritelnStringAndZoneMemoireDansRapport('Z4=',Z4);
  WritelnStringAndZoneMemoireDansRapport('Z5=',Z5);}
  
  
  SetDebuggageUnitFichiersTexte(false);
  
end;

end.